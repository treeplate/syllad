import 'dart:io';

import 'parser-core.dart';
import 'statements.dart';
import 'package:characters/characters.dart';
import 'lexer.dart';

Scope runProgram(List<Statement> ast, String filename,
    [List<String> stack = const []]) {
  Scope scope = Scope(stack: stack + ['$filename'])
    ..values = {
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
        return ValueWrapper(stringType,
            l.map((x) => toStringWithStack(x, s)).join(''), 'concat rtv');
      },
      "addLists": (List<ValueWrapper> l, List<String> s) {
        return ValueWrapper(ListValueType(sharedSupertype, 'rtl'),
            l.expand((element) => element.value).toList(), 'addLists rtv');
      },
      "parseInt": (List<ValueWrapper> l, List<String> s) {
        return ValueWrapper(
          integerType,
          int.parse(l.single.value),
          'parseInt rtv',
        );
      },
      "charsOf": (List<ValueWrapper> l, List<String> s) {
        return ValueWrapper(
          IterableValueType(stringType, 'rtl'),
          (l.single.value as String)
              .characters
              .map((e) => ValueWrapper(stringType, e, 'charsOf char')),
          'charsOf rtv',
        );
      },
      "scalarValues": (List<ValueWrapper> l, List<String> s) {
        return ValueWrapper(
          IterableValueType(integerType, 'rtl'),
          l.single.value.runes
              .map((e) => ValueWrapper(integerType, e, 'scalarValues char')),
          'scalarValues rtv',
        );
      },
      "len": (List<ValueWrapper> l, List<String> s) {
        return ValueWrapper(integerType, l.single.value.length, 'len rtv');
      },
      "input": (List<ValueWrapper> l, List<String> s) {
        return ValueWrapper(stringType, stdin.readLineSync(), 'input rtv');
      },
      "append": (List<ValueWrapper> l, List<String> s) {
        if (!l.last.type
            .isSubtypeOf((l.first.type as ListValueType).genericParameter)) {
          throw FileInvalid(
              "You cannot append a ${l.last.type} to a ${l.first.type}!\n${s.reversed.join('\n')}");
        }
        l.first.value.add(l.last);
        return l.last;
      },
      "iterator": (List<ValueWrapper> l, List<String> s) {
        return ValueWrapper(IteratorValueType(sharedSupertype, 'rtl'),
            l.single.value.iterator, 'iterator rtv');
      },
      "next": (List<ValueWrapper> l, List<String> s) {
        return ValueWrapper(booleanType, l.single.value.moveNext(), 'next rtv');
      },
      "current": (List<ValueWrapper> l, List<String> s) {
        return l.single.value.current;
      },
      "stringTimes": (List<ValueWrapper> l, List<String> s) {
        return ValueWrapper(
          stringType,
          l.first.value * l.last.value,
          'stringTimes rtv',
        );
      },
      "copy": (List<ValueWrapper> l, List<String> s) {
        return ValueWrapper(
          ListValueType(sharedSupertype, 'rtl'),
          l.single.value.toList(),
          'copy rtv',
        );
      },
      "first": (List<ValueWrapper> l, List<String> s) {
        return l.single.value.first;
      },
      "last": (List<ValueWrapper> l, List<String> s) {
        return l.single.value.last;
      },
      "single": (List<ValueWrapper> l, List<String> s) {
        return l.single.value.single;
      },
      "hex": (List<ValueWrapper> l, List<String> s) {
        return ValueWrapper(
            stringType, l.single.value.toRadixString(16), 'hex rtv');
      },
      "chr": (List<ValueWrapper> l, List<String> s) {
        return ValueWrapper(
            stringType, String.fromCharCode(l.single.value), 'chr rtv');
      },
      "exit": (List<ValueWrapper> l, List<String> s) {
        exit(l.single.value);
      },
      "readFile": (List<ValueWrapper> l, List<String> s) {
        return ValueWrapper(
            stringType,
            File('compiler/${l.single.value}').readAsStringSync(),
            'readFile rtv');
      },
      "readFileBytes": (List<ValueWrapper> l, List<String> s) {
        if (l.length == 0)
          throw FileInvalid("readFileBytes called with no args");
        File file = File('compiler/${l.single.value}');
        return file.existsSync()
            ? ValueWrapper(
                stringType, file.readAsBytesSync(), 'readFileBytes rtv')
            : throw FileInvalid("${l.single} is not a existing file");
      },
      "println": (List<ValueWrapper> l, List<String> s) {
        stdout.writeln(l.join(' '));
        return ValueWrapper(integerType, 0, 'println rtv');
      },
      "throw": (List<ValueWrapper> l, List<String> s) {
        throw FileInvalid(
            l.single.value + "\nstack:\n" + s.reversed.join('\n'));
      },
      "joinList": (List<ValueWrapper> l, List<String> s) {
        return ValueWrapper(
            stringType, l.single.value.join(''), 'joinList rtv');
      },
      "cast": (List<ValueWrapper> l, List<String> s) {
        return l.single;
      }
    }.map((key, value) => MapEntry(
        key, ValueWrapper(Scope.tv_types[key]!, value, '$key from rtl')));
  ;
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

String toStringWithStack(ValueWrapper x, List<String> s) {
  if (x.type is ClassValueType) {
    return x.value.toStringWithStack(s);
  } else {
    return x.value.toString();
  }
}
