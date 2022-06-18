import 'dart:io';

import 'parser-core.dart';
import 'statements.dart';
import 'package:characters/characters.dart';
import 'lexer.dart';

Scope runProgram(List<Statement> ast, String filename, Scope? intrinsics,
    [List<String>? stack, Scope? parent]) {
  if (intrinsics == null) {
    assert(parent == null);
    assert(stack == null);
    intrinsics = Scope(debugName: 'intrinsics', stack: ['intrinsics'])
      ..values.addAll({
        "true": true,
        "false": false,
        "null": null,
        "print": (List<ValueWrapper> l, List<String> s) {
          stdout.write(l.join(' '));
          return ValueWrapper(integerType, 0, 'print rtv');
        },
        "stderr": (List<ValueWrapper> l, List<String> s) {
          stderr.writeln(l.join(' '));
          return ValueWrapper(integerType, 0, 'stderr rtv');
        },
        "concat": (List<ValueWrapper> l, List<String> s) {
          return ValueWrapper(
              stringType,
              l.map((x) => x.toStringWithStack(s, -2, 0, 'todo')).join(''),
              'concat rtv');
        },
        "addLists": (List<ValueWrapper> l, List<String> s) {
          return ValueWrapper(
              ListValueType(sharedSupertype, 'intrinsics'),
              l
                  .expand((element) => element.valueC(null, s, -2, 0, 'interr'))
                  .toList(),
              'addLists rtv');
        },
        "parseInt": (List<ValueWrapper> l, List<String> s) {
          return ValueWrapper(
            integerType,
            int.parse(l.single.valueC(null, s, -2, 0, 'interr')),
            'parseInt rtv',
          );
        },
        "charsOf": (List<ValueWrapper> l, List<String> s) {
          return ValueWrapper(
            IterableValueType(stringType, 'intrinsics'),
            (l.single.valueC(null, s, -2, 0, 'interr') as String)
                .characters
                .map((e) => ValueWrapper(stringType, e, 'charsOf char')),
            'charsOf rtv',
          );
        },
        "scalarValues": (List<ValueWrapper> l, List<String> s) {
          return ValueWrapper(
            IterableValueType(integerType, 'intrinsics'),
            l.single
                .valueC(null, s, -2, 0, 'interr')
                .runes
                .map((e) => ValueWrapper(integerType, e, 'scalarValues char')),
            'scalarValues rtv',
          );
        },
        "len": (List<ValueWrapper> l, List<String> s) {
          return ValueWrapper(integerType,
              l.single.valueC(null, s, -2, 0, 'interr').length, 'len rtv');
        },
        "input": (List<ValueWrapper> l, List<String> s) {
          return ValueWrapper(stringType, stdin.readLineSync(), 'input rtv');
        },
        "append": (List<ValueWrapper> l, List<String> s) {
          if (!l.last.typeC(null, s, -2, 0, 'interr').isSubtypeOf(
              (l.first.typeC(null, s, -2, 0, 'interr') as ListValueType)
                  .genericParameter)) {
            throw FileInvalid(
                "You cannot append a ${l.last.typeC(null, s, -2, 0, 'interr')} to a ${l.first.typeC(null, s, -2, 0, 'interr')}!\n${s.reversed.join('\n')}");
          }
          l.first.valueC(null, s, -2, 0, 'interr').add(l.last);
          return l.last;
        },
        "pop": (List<ValueWrapper> l, List<String> s) {
          List<ValueWrapper> list = l.first.valueC(null, s, -2, 0, 'interr');
          if (list.isEmpty) {
            throw FileInvalid(
                "Cannot pop from an empty list!\n${s.reversed.join('\n')}");
          }
          list.removeLast();
        },
        "iterator": (List<ValueWrapper> l, List<String> s) {
          return ValueWrapper(
              IteratorValueType(sharedSupertype, 'intrinsics'),
              l.single.valueC(null, s, -2, 0, 'interr').iterator,
              'iterator rtv');
        },
        "next": (List<ValueWrapper> l, List<String> s) {
          return ValueWrapper(booleanType,
              l.single.valueC(null, s, -2, 0, 'interr').moveNext(), 'next rtv');
        },
        "current": (List<ValueWrapper> l, List<String> s) {
          return l.single.valueC(null, s, -2, 0, 'interr').current;
        },
        "stringTimes": (List<ValueWrapper> l, List<String> s) {
          return ValueWrapper(
            stringType,
            l.first.valueC(null, s, -2, 0, 'interr') *
                l.last.valueC(null, s, -2, 0, 'interr'),
            'stringTimes rtv',
          );
        },
        "copy": (List<ValueWrapper> l, List<String> s) {
          return ValueWrapper(
            ListValueType(sharedSupertype, 'intrinsics'),
            l.single.valueC(null, s, -2, 0, 'interr').toList(),
            'copy rtv',
          );
        },
        "first": (List<ValueWrapper> l, List<String> s) {
          return l.single.valueC(null, s, -2, 0, 'interr').first;
        },
        "last": (List<ValueWrapper> l, List<String> s) {
          return l.single.valueC(null, s, -2, 0, 'interr').last;
        },
        "single": (List<ValueWrapper> l, List<String> s) {
          return l.single.valueC(null, s, -2, 0, 'interr').single;
        },
        "hex": (List<ValueWrapper> l, List<String> s) {
          return ValueWrapper(
              stringType,
              l.single.valueC(null, s, -2, 0, 'interr').toRadixString(16),
              'hex rtv');
        },
        "chr": (List<ValueWrapper> l, List<String> s) {
          return ValueWrapper(
              stringType,
              String.fromCharCode(l.single.valueC(null, s, -2, 0, 'interr')),
              'chr rtv');
        },
        "exit": (List<ValueWrapper> l, List<String> s) {
          exit(l.single.valueC(null, s, -2, 0, 'interr'));
        },
        "readFile": (List<ValueWrapper> l, List<String> s) {
          return ValueWrapper(
              stringType,
              File('compiler/${l.single.valueC(null, s, -2, 0, 'interr')}')
                  .readAsStringSync(),
              'readFile rtv');
        },
        "readFileBytes": (List<ValueWrapper> l, List<String> s) {
          if (l.length == 0)
            throw FileInvalid("readFileBytes called with no args");
          File file =
              File('compiler/${l.single.valueC(null, s, -2, 0, 'interr')}');
          return file.existsSync()
              ? ValueWrapper(
                  stringType, file.readAsBytesSync(), 'readFileBytes rtv')
              : throw FileInvalid("${l.single} is not a existing file");
        },
        "println": (List<ValueWrapper> l, List<String> s) {
          stdout.writeln(l
              .map(((e) => e.toStringWithStack(
                  s + ['println calling toString()'], -2, 0, 'interr')))
              .join(' '));
          return ValueWrapper(integerType, 0, 'println rtv');
        },
        "throw": (List<ValueWrapper> l, List<String> s) {
          throw FileInvalid(l.single.valueC(null, s, -2, 0, 'interr') +
              "\nstack:\n" +
              s.reversed.join('\n'));
        },
        "joinList": (List<ValueWrapper> l, List<String> s) {
          return ValueWrapper(
              stringType,
              l.single.valueC(null, s, -2, 0, 'interr').join(''),
              'joinList rtv');
        },
        "cast": (List<ValueWrapper> l, List<String> s) {
          return l.single;
        },
        "substring": (List<ValueWrapper> l, List<String> s) {
          return ValueWrapper(
              stringType,
              (l[0].valueC(null, s, -2, 0, 'interr') as String).substring(
                  l[1].valueC(null, s, -2, 0, 'interr') as int,
                  l[2].valueC(null, s, -2, 0, 'interr') as int),
              'substring rtv');
        },
        "sublist": (List<ValueWrapper> l, List<String> s) {
          if (l[2].valueC(null, s, -2, 0, 'interr') <
              l[1].valueC(null, s, -2, 0, 'interr')) {
            throw FileInvalid(
                "sublist called with ${l[2]} (end arg) < ${l[1]} (start arg) ${s.reversed.join('\n')}");
          }
          return ValueWrapper(
              l.first.typeC(null, s, -2, 0, 'interr'),
              (l[0].valueC(null, s, -2, 0, 'interr') as List<ValueWrapper>)
                  .sublist(l[1].valueC(null, s, -2, 0, 'interr') as int,
                      l[2].valueC(null, s, -2, 0, 'interr') as int),
              'sublist rtv');
        },
        "stackTrace": (List<ValueWrapper> l, List<String> s) {
          return ValueWrapper(
              stringType, s.reversed.join('\n'), 'stackTrace rtv');
        },
      }.map((key, value) => MapEntry(key,
          ValueWrapper(Scope.tv_types[key]!, value, '$key from intrinsics'))));
    ;
  }
  Scope scope = Scope(
      intrinsics: intrinsics,
      parent: parent ?? intrinsics,
      stack: (stack ?? []) + ['$filename'],
      debugName: '$filename global scope');
  for (Statement statement in ast) {
    StatementResult sr = statement.run(scope);
    switch (sr.type) {
      case StatementResultType.nothing:
        break;
      case StatementResultType.breakWhile:
        throw FileInvalid("Break outside while");
      case StatementResultType.continueWhile:
        throw FileInvalid("Continue outside while");
      case StatementResultType.returnFunction:
        throw FileInvalid("Returned ${sr.value} outside function");
      case StatementResultType.unwindAndThrow:
        print(sr.value);
        exit(1);
    }
  }
  return scope;
}
