import 'dart:io';

//import 'lexer.dart';
import 'parser-core.dart';
import 'statements.dart';
import 'package:characters/characters.dart';

Scope runProgram(List<Statement> ast, String filename, String workspace, Scope? intrinsics, Scope? rtl, TypeValidator tv, bool profileMode, bool debugMode,
    [List<String>? args, List<LazyString>? stack, Scope? parent]) {
  if (intrinsics == null) {
    assert(parent == null);
    assert(stack == null);
    intrinsics = Scope(false, false, rtl,
        debugName: NotLazyString('intrinsics'),
        stack: [NotLazyString('intrinsics')],
        profileMode: profileMode,
        debugMode: debugMode,
        intrinsics: null /* we ARE the intrinsics*/)
      ..values.addAll({
        "true": true,
        "false": false,
        "null": null,
        "args": args!.map((e) => ValueWrapper(stringType, e, 'argument of program')).toList(),
        "print": (List<ValueWrapper> l, List<LazyString> s, [Scope? thisScope, ValueType? thisType]) {
          stdout.write(l.map((e) => e.toStringWithStack(s, -2, 0, workspace, 'interr', true)).join(' '));
          return ValueWrapper(integerType, 0, 'print rtv');
        },
        "debug": (List<ValueWrapper> l, List<LazyString> s, [Scope? thisScope, ValueType? thisType]) {
          return ValueWrapper(stringType, l.single.valueC<Scope>(null, s, 0, 0, workspace, filename).dump(), 'debug rtv');
        },
        "stderr": (List<ValueWrapper> l, List<LazyString> s, [Scope? thisScope, ValueType? thisType]) {
          stderr.writeln(l.map((e) => e.toStringWithStack(s, -2, 0, workspace, 'interr', true)).join(' '));
          return ValueWrapper(integerType, 0, 'stderr rtv');
        },
        "concat": (List<ValueWrapper> l, List<LazyString> s, [Scope? thisScope, ValueType? thisType]) {
          return ValueWrapper(stringType, l.map((x) => x.toStringWithStack(s, -2, 0, 'interr', 'todo', true)).join(''), 'concat rtv');
        },
        "addLists": (List<ValueWrapper> l, List<LazyString> s, [Scope? thisScope, ValueType? thisType]) {
          return ValueWrapper(ListValueType(anythingType, 'intrinsics'),
              l.expand<ValueWrapper>((element) => element.valueC(null, s, -2, 0, 'interr', 'interr')).toList(), 'addLists rtv');
        },
        "parseInt": (List<ValueWrapper> l, List<LazyString> s, [Scope? thisScope, ValueType? thisType]) {
          return ValueWrapper(
            integerType,
            int.parse(l.single.valueC(null, s, -2, 0, 'interr', 'interr')),
            'parseInt rtv',
          );
        },
        "split": (List<ValueWrapper> l, List<LazyString> s, [Scope? thisScope, ValueType? thisType]) {
          return ValueWrapper(
            ListValueType(stringType, 'intrinsics'),
            l.first
                .valueC<String>(null, s, -2, 0, 'interr', 'interr')
                .split(
                  l.last.valueC(null, s, -2, 0, 'interr', 'interr'),
                )
                .map<ValueWrapper>((e) => ValueWrapper(stringType, e, 'split rtv element'))
                .toList(),
            'split rtv',
          );
        },
        "charsOf": (List<ValueWrapper> l, List<LazyString> s, [Scope? thisScope, ValueType? thisType]) {
          return ValueWrapper(
            IterableValueType(stringType, 'intrinsics'),
            (l.single.valueC(null, s, -2, 0, 'interr', 'interr') as String).characters.map((e) => ValueWrapper(stringType, e, 'charsOf char')),
            'charsOf rtv',
          );
        },
        "scalarValues": (List<ValueWrapper> l, List<LazyString> s, [Scope? thisScope, ValueType? thisType]) {
          return ValueWrapper(
            IterableValueType(integerType, 'intrinsics'),
            l.single.valueC<String>(null, s, -2, 0, 'interr', 'interr').runes.map((e) => ValueWrapper(integerType, e, 'scalarValues char')),
            'scalarValues rtv',
          );
        },
        "len": (List<ValueWrapper> l, List<LazyString> s, [Scope? thisScope, ValueType? thisType]) {
          if (l.single.typeC(null, s, -2, 0, 'interr', 'interr') is! IterableValueType) {
            throw BSCException(
                'len() takes a list as its argument, not a ${l.single.typeC(null, s, -2, 0, 'interr', 'interr')} ${s.reversed.join('\n')}', NoDataVG());
          }
          return ValueWrapper(integerType, l.single.valueC<Iterable<ValueWrapper>>(null, s, -2, 0, 'interr', 'interr').length, 'len rtv');
        },
        "input": (List<ValueWrapper> l, List<LazyString> s, [Scope? thisScope, ValueType? thisType]) {
          return ValueWrapper(stringType, stdin.readLineSync(), 'input rtv');
        },
        "append": (List<ValueWrapper> l, List<LazyString> s, [Scope? thisScope, ValueType? thisType]) {
          if (!l.last
              .typeC(null, s, -2, 0, 'interr', 'interr')
              .isSubtypeOf((l.first.typeC(null, s, -2, 0, 'interr', 'interr') as ListValueType).genericParameter)) {
            throw BSCException(
                "You cannot append a ${l.last.typeC(null, s, -2, 0, 'interr', 'interr')} to a ${l.first.typeC(null, s, -2, 0, 'interr', 'interr')}!\n${s.reversed.join('\n')}",
                NoDataVG());
          }
          l.first.valueC<List>(null, s, -2, 0, 'interr', 'interr').add(l.last);
          return l.last;
        },
        "pop": (List<ValueWrapper> l, List<LazyString> s, [Scope? thisScope, ValueType? thisType]) {
          List<ValueWrapper> list = l.first.valueC(null, s, -2, 0, 'interr', 'interr');
          if (list.isEmpty) {
            throw BSCException("Cannot pop from an empty list!\n${s.reversed.join('\n')}", NoDataVG());
          }
          return list.removeLast();
        },
        "iterator": (List<ValueWrapper> l, List<LazyString> s, [Scope? thisScope, ValueType? thisType]) {
          return ValueWrapper(
              IteratorValueType(anythingType, 'intrinsics'), l.single.valueC<Iterable>(null, s, -2, 0, 'interr', 'interr').iterator, 'iterator rtv');
        },
        "next": (List<ValueWrapper> l, List<LazyString> s, [Scope? thisScope, ValueType? thisType]) {
          return ValueWrapper(booleanType, l.single.valueC<Iterator>(null, s, -2, 0, 'interr', 'interr').moveNext(), 'next rtv');
        },
        "current": (List<ValueWrapper> l, List<LazyString> s, [Scope? thisScope, ValueType? thisType]) {
          return l.single.valueC<Iterator<ValueWrapper>>(null, s, -2, 0, 'interr', 'interr').current;
        },
        "stringTimes": (List<ValueWrapper> l, List<LazyString> s, [Scope? thisScope, ValueType? thisType]) {
          return ValueWrapper(
            stringType,
            l.first.valueC<String>(null, s, -2, 0, 'interr', 'interr') * l.last.valueC<int>(null, s, -2, 0, 'interr', 'interr'),
            'stringTimes rtv',
          );
        },
        "copy": (List<ValueWrapper> l, List<LazyString> s, [Scope? thisScope, ValueType? thisType]) {
          return ValueWrapper(
            ListValueType(anythingType, 'intrinsics'),
            l.single.valueC<Iterable<ValueWrapper>>(null, s, -2, 0, 'interr', 'interr').toList(),
            'copy rtv',
          );
        },
        "clear": (List<ValueWrapper> l, List<LazyString> s, [Scope? thisScope, ValueType? thisType]) {
          l.single.valueC<List<ValueWrapper>>(null, s, -2, 0, 'interr', 'interr').clear();
          return ValueWrapper(integerType, 0, 'clear rtv');
        },
        "hex": (List<ValueWrapper> l, List<LazyString> s, [Scope? thisScope, ValueType? thisType]) {
          return ValueWrapper(stringType, l.single.valueC<int>(null, s, -2, 0, 'interr', 'interr').toRadixString(16), 'hex rtv');
        },
        "chr": (List<ValueWrapper> l, List<LazyString> s, [Scope? thisScope, ValueType? thisType]) {
          return ValueWrapper(stringType, String.fromCharCode(l.single.valueC(null, s, -2, 0, 'interr', 'interr')), 'chr rtv');
        },
        "exit": (List<ValueWrapper> l, List<LazyString> s, [Scope? thisScope, ValueType? thisType]) {
          exit(l.single.valueC(null, s, -2, 0, 'interr', 'interr'));
        },
        "readFile": (List<ValueWrapper> l, List<LazyString> s, [Scope? thisScope, ValueType? thisType]) {
          
          try {
            File file =  File('${l.single.valueC(null, s, -2, 0, 'interr', 'interr')}');
            if(!file.existsSync()) {
              throw BSCException("${l.single.toStringWithStack(s, -2, 0, 'interr', 'interr', false)} is not a existing file\n${s.reversed.join('\n')}", StringVariableGroup('$workspace'));
            }
            return ValueWrapper(stringType, file.readAsStringSync(), 'readFile rtv');
          } on PathNotFoundException catch (e) {
            throw BSCException(e.message + ' when reading file ${l.single.valueC(null, s, -2, 0, 'interr', 'interr')}\n${s.reversed.join('\n')}', NoDataVG());
          }
        },
        "readFileBytes": (List<ValueWrapper> l, List<LazyString> s, [Scope? thisScope, ValueType? thisType]) {
          if (l.length == 0) throw BSCException("readFileBytes called with no args", NoDataVG());
          File file = File('$workspace/${l.single.valueC(null, s, -2, 0, 'interr', 'interr')}');
          return file.existsSync()
              ? ValueWrapper(stringType, file.readAsBytesSync(), 'readFileBytes rtv')
              : throw BSCException("${l.single} is not a existing file\n${s.reversed.join('\n')}", NoDataVG());
        },
        "println": (List<ValueWrapper> l, List<LazyString> s, [Scope? thisScope, ValueType? thisType]) {
          stdout.writeln(l.map(((e) => e.toStringWithStack(s + [NotLazyString('println calling toString()')], -2, 0, 'interr', 'interr', true))).join(' '));
          return ValueWrapper(integerType, 0, 'println rtv');
        },
        "throw": (List<ValueWrapper> l, List<LazyString> s, [Scope? thisScope, ValueType? thisType]) {
          if (l.length > 1) {
            throw SydException(l.first.valueC<String>(null, s, -2, 0, 'interr', 'interr') + "\nstack:\n" + s.reversed.join('\n'),
                l.last.valueC(null, s, -2, 0, 'interr', 'interr'), NoDataVG());
          }
          throw ThrowException(l.single.valueC<String>(null, s, -2, 0, 'interr', 'interr') + "\nstack:\n" + s.reversed.join('\n'), NoDataVG());
        },
        "cast": (List<ValueWrapper> l, List<LazyString> s, [Scope? thisScope, ValueType? thisType]) {
          return l.single;
        },
        "substring": (List<ValueWrapper> l, List<LazyString> s, [Scope? thisScope, ValueType? thisType]) {
          if (l[1].valueC(null, s, -2, 0, 'interr', 'interr') as int > (l[2].valueC(null, s, -2, 0, 'interr', 'interr') as int)) {
            throw BSCException("Cannot substring when the start (${l[1]}) is more than the end (${l[2]})!\n${s.reversed.join('\n')}", NoDataVG());
          }
          if (l[1].valueC(null, s, -2, 0, 'interr', 'interr') as int < 0) {
            throw BSCException("Cannot substring when the start (${l[1]}) is less than 0!\n${s.reversed.join('\n')}", NoDataVG());
          }
          if (l[2].valueC(null, s, -2, 0, 'interr', 'interr') as int > l[0].valueC<String>(null, s, -2, 0, 'interr', 'interr').length) {
            throw BSCException(
                "Cannot substring when the end (${l[2]}) is more than the length of the string (${l[1]})!\n${s.reversed.join('\n')}", NoDataVG());
          }
          return ValueWrapper(
              stringType,
              (l[0].valueC(null, s, -2, 0, 'interr', 'interr') as String)
                  .substring(l[1].valueC(null, s, -2, 0, 'interr', 'interr') as int, l[2].valueC(null, s, -2, 0, 'interr', 'interr') as int),
              'substring rtv');
        },
        "sublist": (List<ValueWrapper> l, List<LazyString> s, [Scope? thisScope, ValueType? thisType]) {
          if (l[2].valueC<int>(null, s, -2, 0, 'interr', 'interr') < l[1].valueC(null, s, -2, 0, 'interr', 'interr')) {
            throw BSCException("sublist called with ${l[2]} (end arg) < ${l[1]} (start arg) ${s.reversed.join('\n')}", NoDataVG());
          }
          return ValueWrapper(
              l.first.typeC(null, s, -2, 0, 'interr', 'interr'),
              (l[0].valueC(null, s, -2, 0, 'interr', 'interr') as List<ValueWrapper>)
                  .sublist(l[1].valueC(null, s, -2, 0, 'interr', 'interr') as int, l[2].valueC(null, s, -2, 0, 'interr', 'interr') as int),
              'sublist rtv');
        },
        "stackTrace": (List<ValueWrapper> l, List<LazyString> s, [Scope? thisScope, ValueType? thisType]) {
          return ValueWrapper(stringType, s.reversed.join('\n'), 'stackTrace rtv');
        },
        "containsString": (List<ValueWrapper> l, List<LazyString> s, [Scope? thisScope, ValueType? thisType]) {
          return ValueWrapper(
              booleanType,
              l.first.valueC<String>(null, s, -2, 0, workspace, filename).contains(l.last.valueC<String>(null, s, -2, 0, workspace, filename)),
              'stringContains rtv');
        },
        "debugName": (List<ValueWrapper> l, List<LazyString> s, [Scope? thisScope, ValueType? thisType]) {
          return ValueWrapper(stringType, (l.single.valueC(null, s, -2, 0, workspace, filename) as Scope).debugName, 'debugName rtv');
        },
        'createStringBuffer': (List<ValueWrapper> l, List<LazyString> s, [Scope? thisScope, ValueType? thisType]) {
          return ValueWrapper(stringBufferType, StringBuffer(), 'createStringBuffer rtv');
        },
        'writeStringBuffer': (List<ValueWrapper> l, List<LazyString> s, [Scope? thisScope, ValueType? thisType]) {
          StringBuffer buffer = l.first.valueC(null, s, -2, 0, workspace, filename);
          buffer.write(l.last.valueC(null, s, -2, 0, workspace, filename));
          return ValueWrapper(nullType, null, 'writeStringBuffer rtv');
        },
        'readStringBuffer': (List<ValueWrapper> l, List<LazyString> s, [Scope? thisScope, ValueType? thisType]) {
          StringBuffer buffer = l.first.valueC(null, s, -2, 0, workspace, filename);
          return ValueWrapper(stringType, buffer.toString(), 'readStringBuffer rtv');
        },
      }.map((key, value) => MapEntry(
          variables[key] ??= Variable(key), MaybeConstantValueWrapper(ValueWrapper(tv.igv(variables[key]!, false), value, '$key from intrinsics'), true))));
  }
  Scope scope = Scope(false, false, rtl,
      intrinsics: intrinsics,
      parent: parent ?? rtl ?? intrinsics,
      stack: (stack ?? []) + [NotLazyString('$filename')],
      debugName: NotLazyString('$filename global scope'));
  for (Statement statement in ast) {
    StatementResult sr = statement.run(scope);
    switch (sr.type) {
      case StatementResultType.nothing:
        break;
      case StatementResultType.breakWhile:
        throw BSCException("Break outside while", scope);
      case StatementResultType.continueWhile:
        throw BSCException("Continue outside while", scope);
      case StatementResultType.returnFunction:
        throw BSCException("Returned ${sr.value} outside function", scope);
      case StatementResultType.unwindAndThrow:
        stderr.writeln(sr.value);
        exit(1);
    }
  }
  return scope;
}
