import 'dart:io';

import 'parser-core.dart';
import 'statements.dart';
import 'package:characters/characters.dart';
import 'lexer.dart';

Scope runProgram(List<Statement> ast, String filename, String workspace, Scope? intrinsics, TypeValidator tv,
    [List<String>? args, List<LazyString>? stack, Scope? parent]) {
  if (intrinsics == null) {
    assert(parent == null);
    assert(stack == null);
    intrinsics = Scope(false, debugName: NotLazyString('intrinsics'), stack: [NotLazyString('intrinsics')])
      ..values.addAll({
        "true": true,
        "false": false,
        "null": null,
        "args": args!.map((e) => ValueWrapper(stringType, e, 'argument of program')).toList(),
        "print": (List<ValueWrapper> l, List<LazyString> s, [Scope? thisScope, ValueType? thisType]) {
          stdout.write(l.join(' '));
          return ValueWrapper(integerType, 0, 'print rtv');
        },
        "stderr": (List<ValueWrapper> l, List<LazyString> s, [Scope? thisScope, ValueType? thisType]) {
          stderr.writeln(l.join(' '));
          return ValueWrapper(integerType, 0, 'stderr rtv');
        },
        "concat": (List<ValueWrapper> l, List<LazyString> s, [Scope? thisScope, ValueType? thisType]) {
          return ValueWrapper(stringType, l.map((x) => x.toStringWithStack(s, -2, 0, 'interr', 'todo')).join(''), 'concat rtv');
        },
        "addLists": (List<ValueWrapper> l, List<LazyString> s, [Scope? thisScope, ValueType? thisType]) {
          return ValueWrapper(ListValueType(sharedSupertype, 'intrinsics'),
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
            throw BSCException('len() takes a list as its argument, not a ${l.single.typeC(null, s, -2, 0, 'interr', 'interr')} ${s.reversed.join('\n')}');
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
                "You cannot append a ${l.last.typeC(null, s, -2, 0, 'interr', 'interr')} to a ${l.first.typeC(null, s, -2, 0, 'interr', 'interr')}!\n${s.reversed.join('\n')}");
          }
          l.first.valueC<List>(null, s, -2, 0, 'interr', 'interr').add(l.last);
          return l.last;
        },
        "pop": (List<ValueWrapper> l, List<LazyString> s, [Scope? thisScope, ValueType? thisType]) {
          List<ValueWrapper> list = l.first.valueC(null, s, -2, 0, 'interr', 'interr');
          if (list.isEmpty) {
            throw BSCException("Cannot pop from an empty list!\n${s.reversed.join('\n')}");
          }
          return list.removeLast();
        },
        "iterator": (List<ValueWrapper> l, List<LazyString> s, [Scope? thisScope, ValueType? thisType]) {
          return ValueWrapper(
              IteratorValueType(sharedSupertype, 'intrinsics'), l.single.valueC<Iterable>(null, s, -2, 0, 'interr', 'interr').iterator, 'iterator rtv');
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
            ListValueType(sharedSupertype, 'intrinsics'),
            l.single.valueC<Iterable<ValueWrapper>>(null, s, -2, 0, 'interr', 'interr').toList(),
            'copy rtv',
          );
        },
        "first": (List<ValueWrapper> l, List<LazyString> s, [Scope? thisScope, ValueType? thisType]) {
          return l.single.valueC<Iterable<ValueWrapper>>(null, s, -2, 0, 'interr', 'interr').first;
        },
        "last": (List<ValueWrapper> l, List<LazyString> s, [Scope? thisScope, ValueType? thisType]) {
          return l.single.valueC<Iterable<ValueWrapper>>(null, s, -2, 0, 'interr', 'interr').last;
        },
        "single": (List<ValueWrapper> l, List<LazyString> s, [Scope? thisScope, ValueType? thisType]) {
          return l.single.valueC<Iterable<ValueWrapper>>(null, s, -2, 0, 'interr', 'interr').single;
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
          return ValueWrapper(stringType, File('$workspace/${l.single.valueC(null, s, -2, 0, 'interr', 'interr')}').readAsStringSync(), 'readFile rtv');
        },
        "readFileBytes": (List<ValueWrapper> l, List<LazyString> s, [Scope? thisScope, ValueType? thisType]) {
          if (l.length == 0) throw BSCException("readFileBytes called with no args");
          File file = File('$workspace/${l.single.valueC(null, s, -2, 0, 'interr', 'interr')}');
          return file.existsSync()
              ? ValueWrapper(stringType, file.readAsBytesSync(), 'readFileBytes rtv')
              : throw BSCException("${l.single} is not a existing file");
        },
        "println": (List<ValueWrapper> l, List<LazyString> s, [Scope? thisScope, ValueType? thisType]) {
          stdout.writeln(l.map(((e) => e.toStringWithStack(s + [NotLazyString('println calling toString()')], -2, 0, 'interr', 'interr'))).join(' '));
          return ValueWrapper(integerType, 0, 'println rtv');
        },
        "throw": (List<ValueWrapper> l, List<LazyString> s, [Scope? thisScope, ValueType? thisType]) {
          throw ThrowException(l.single.valueC<String>(null, s, -2, 0, 'interr', 'interr') + "\nstack:\n" + s.reversed.join('\n'));
        },
        "joinList": (List<ValueWrapper> l, List<LazyString> s, [Scope? thisScope, ValueType? thisType]) {
          return ValueWrapper(stringType, l.single.valueC<List>(null, s, -2, 0, 'interr', 'interr').join(''), 'joinList rtv');
        },
        "cast": (List<ValueWrapper> l, List<LazyString> s, [Scope? thisScope, ValueType? thisType]) {
          return l.single;
        },
        "substring": (List<ValueWrapper> l, List<LazyString> s, [Scope? thisScope, ValueType? thisType]) {
          if (l[1].valueC(null, s, -2, 0, 'interr', 'interr') as int > (l[2].valueC(null, s, -2, 0, 'interr', 'interr') as int)) {
            throw BSCException("Cannot substring when the start (${l[1]}) is more than the end (${l[2]})!\n${s.reversed.join('\n')}");
          }
          if (l[1].valueC(null, s, -2, 0, 'interr', 'interr') as int < 0) {
            throw BSCException("Cannot substring when the start (${l[1]}) is less than 0!\n${s.reversed.join('\n')}");
          }
          if (l[2].valueC(null, s, -2, 0, 'interr', 'interr') as int > l[0].valueC<String>(null, s, -2, 0, 'interr', 'interr').length) {
            throw BSCException("Cannot substring when the end (${l[2]}) is more than the length of the string (${l[1]})!\n${s.reversed.join('\n')}");
          }
          return ValueWrapper(
              stringType,
              (l[0].valueC(null, s, -2, 0, 'interr', 'interr') as String)
                  .substring(l[1].valueC(null, s, -2, 0, 'interr', 'interr') as int, l[2].valueC(null, s, -2, 0, 'interr', 'interr') as int),
              'substring rtv');
        },
        "sublist": (List<ValueWrapper> l, List<LazyString> s, [Scope? thisScope, ValueType? thisType]) {
          if (l[2].valueC<int>(null, s, -2, 0, 'interr', 'interr') < l[1].valueC(null, s, -2, 0, 'interr', 'interr')) {
            throw BSCException("sublist called with ${l[2]} (end arg) < ${l[1]} (start arg) ${s.reversed.join('\n')}");
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
      }.map((key, value) => MapEntry(variables[key] ??= Variable(key), ValueWrapper(tv.igv(variables[key]!, false), value, '$key from intrinsics'))));
  }
  Scope scope = Scope(false,
      intrinsics: intrinsics,
      parent: parent ?? intrinsics,
      stack: (stack ?? []) + [NotLazyString('$filename')],
      debugName: NotLazyString('$filename global scope'));
  for (Statement statement in ast) {
    StatementResult sr = statement.run(scope);
    switch (sr.type) {
      case StatementResultType.nothing:
        break;
      case StatementResultType.breakWhile:
        throw BSCException("Break outside while");
      case StatementResultType.continueWhile:
        throw BSCException("Continue outside while");
      case StatementResultType.returnFunction:
        throw BSCException("Returned ${sr.value} outside function");
      case StatementResultType.unwindAndThrow:
        stderr.writeln(sr.value);
        exit(1);
    }
  }
  return scope;
}
