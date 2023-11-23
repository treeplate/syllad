import 'dart:convert';
import 'dart:io';
import 'syd-core.dart';
import 'package:characters/characters.dart';
import 'syd-lexer.dart';
import 'syd-statement-parser.dart';

// this program relies on current working directory being the directory with tests/ and lib/, because `dart test` makes Platform.script be somewhere outside of this directory
Scope runProgram(List<Statement> ast, String filename, Scope? intrinsics, Scope? rtl, TypeValidator tv, bool profileMode, bool debugMode, IOSink stdout,
    IOSink stderr, void Function(int) exit,
    [List<String>? args, List<LazyString>? stack, Scope? parent]) {
  if (intrinsics == null) {
    ValueType whateverIterableType = IterableValueType(ValueType.create(null, whateverVariable, -2, 0, 'intrinsics', tv), 'intrinsics', tv);
    ListValueType anythingListType = ListValueType<Object?>(tv.environment.anythingType, 'intrinsics', tv);
    ListValueType stringListType = ListValueType<String>(tv.environment.stringType, 'intrinsics', tv);
    assert(parent == null);
    assert(stack == null);
    intrinsics = Scope(false, false, rtl, tv.environment,
        variables: tv.variables,
        debugName: NotLazyString('intrinsics'),
        stack: [NotLazyString('intrinsics')],
        profileMode: profileMode,
        debugMode: debugMode,
        intrinsics: null /* we ARE the intrinsics*/)
      ..values.addAll(
        {
          'true': true,
          'false': false,
          'null': null,
          'args': SydList(args!, stringListType),
          'print': (List<Object?> l, List<LazyString> s, [Scope? thisScope, ValueType? thisType]) {
            stdout.write(l
                .map((e) => toStringWithStacker(
                      e,
                      s,
                      -2,
                      0,
                      'interr',
                      true,
                      tv.environment,
                    ))
                .join(' '));
            return 0;
          },
          'debug': (List<Object?> l, List<LazyString> s, [Scope? thisScope, ValueType? thisType]) {
            return (l.single as Scope).dump();
          },
          'stderr': (List<Object?> l, List<LazyString> s, [Scope? thisScope, ValueType? thisType]) {
            stderr.writeln(l
                .map((e) => toStringWithStacker(
                      e,
                      s,
                      -2,
                      0,
                      'interr',
                      true,
                      tv.environment,
                    ))
                .join(' '));
            return 0;
          },
          'println': (List<Object?> l, List<LazyString> s, [Scope? thisScope, ValueType? thisType]) {
            stdout.writeln(l
                .map((e) => toStringWithStacker(
                      e,
                      s,
                      -2,
                      0,
                      'interr',
                      true,
                      tv.environment,
                    ))
                .join(' '));
            return 0;
          },
          'concat': (List<Object?> l, List<LazyString> s, [Scope? thisScope, ValueType? thisType]) {
            return l
                .map((x) => toStringWithStacker(
                      x,
                      s,
                      -2,
                      0,
                      'interr',
                      true,
                      tv.environment,
                    ))
                .join('');
          },
          'addLists': (List<Object?> l, List<LazyString> s, [Scope? thisScope, ValueType? thisType]) {
            return SydList(l.expand((element) => (element as SydArray).array).toList(), ListValueType(tv.environment.anythingType, 'intrinsics', tv));
          },
          'parseInt': (List<Object?> l, List<LazyString> s, [Scope? thisScope, ValueType? thisType]) {
            return int.parse(l.single as String);
          },
          'split': (List<Object?> l, List<LazyString> s, [Scope? thisScope, ValueType? thisType]) {
            if (l.first == '') {
              return SydList(
                [l.first],
                ListValueType(tv.environment.stringType, 'intrinsics', tv),
              );
            }
            return SydList(
              (l.first as String)
                  .split(
                    l.last as String,
                  )
                  .toList(),
              ListValueType(tv.environment.stringType, 'intrinsics', tv),
            );
          },
          'charsOf': (List<Object?> l, List<LazyString> s, [Scope? thisScope, ValueType? thisType]) {
            return SydIterable(
              (l.single as String).characters,
              IterableValueType(tv.environment.stringType, 'intrinsics', tv),
            );
          },
          'scalarValues': (List<Object?> l, List<LazyString> s, [Scope? thisScope, ValueType? thisType]) {
            return SydIterable(
              (l.single as String).runes,
              IterableValueType(tv.environment.integerType, 'intrinsics', tv),
            );
          },
          'filledList': (List<Object?> l, List<LazyString> s, [Scope? thisScope, ValueType? thisType]) {
            return SydList<Object?>(List.filled(l.first as int, l.last, growable: true), anythingListType);
          },
          'sizedList': (List<Object?> l, List<LazyString> s, [Scope? thisScope, ValueType? thisType]) {
            return SydList<Object?>(
              List.filled(l.first as int, SydSentinel(tv.environment), growable: true),
              anythingListType,
            );
          },
          'len': (List<Object?> l, List<LazyString> s, [Scope? thisScope, ValueType? thisType]) {
            if (!getType(l.single, tv, -2, 0, 'intrinsics').isSubtypeOf(whateverIterableType)) {
              throw BSCException(
                  'len() takes a list as its argument, not a ${getType(l.single, tv, -2, 0, 'intrinsics')} ${s.reversed.join('\n')}', NoDataVG(tv.environment));
            }
            return (l.single as SydIterable).iterable.length;
          },
          'input': (List<Object?> l, List<LazyString> s, [Scope? thisScope, ValueType? thisType]) {
            return stdin.readLineSync();
          },
          'append': (List<Object?> l, List<LazyString> s, [Scope? thisScope, ValueType? thisType]) {
            if (!getType(l.last, tv, -2, 0, 'intrinsics').isSubtypeOf((getType(l.first, tv, -2, 0, 'intrinsics') as ListValueType).genericParameter)) {
              throw BSCException(
                  'You cannot append a ${getType(l.last, tv, -2, 0, 'intrinsics')} to a ${getType(l.first, tv, -2, 0, 'intrinsics')}!\n${s.reversed.join('\n')}',
                  NoDataVG(tv.environment));
            }
            (l.first as SydList).list.add(l.last);
            return l.last;
          },
          'pop': (List<Object?> l, List<LazyString> s, [Scope? thisScope, ValueType? thisType]) {
            SydList list = l.first as SydList;
            if (list.list.isEmpty) {
              throw BSCException('Cannot pop from an empty list!\n${s.reversed.join('\n')}', NoDataVG(tv.environment));
            }
            return list.list.removeLast();
          },
          'iterator': (List<Object?> l, List<LazyString> s, [Scope? thisScope, ValueType? thisType]) {
            return SydIterator((l.single as SydIterable).iterable.iterator, IteratorValueType(elementTypeOf((l.single as SydIterable).type), filename, tv));
          },
          'next': (List<Object?> l, List<LazyString> s, [Scope? thisScope, ValueType? thisType]) {
            return (l.single as SydIterator).iterator.moveNext();
          },
          'current': (List<Object?> l, List<LazyString> s, [Scope? thisScope, ValueType? thisType]) {
            return (l.single as SydIterator).iterator.current;
          },
          'stringTimes': (List<Object?> l, List<LazyString> s, [Scope? thisScope, ValueType? thisType]) {
            return (l.first as String) * (l.last as int);
          },
          'copy': (List<Object?> l, List<LazyString> s, [Scope? thisScope, ValueType? thisType]) {
            return SydList(
              (l.single as SydIterable).iterable.toList(),
              anythingListType,
            );
          },
          'clear': (List<Object?> l, List<LazyString> s, [Scope? thisScope, ValueType? thisType]) {
            (l.single as SydList).list.clear();
            return 0;
          },
          'hex': (List<Object?> l, List<LazyString> s, [Scope? thisScope, ValueType? thisType]) {
            return (l.single as int).toRadixString(16);
          },
          'chr': (List<Object?> l, List<LazyString> s, [Scope? thisScope, ValueType? thisType]) {
            return String.fromCharCode(l.single as int);
          },
          'exit': (List<Object?> l, List<LazyString> s, [Scope? thisScope, ValueType? thisType]) {
            exit(l.single as int);
            return null;
          },
          'fileExists': (List<Object?> l, List<LazyString> s, [Scope? thisScope, ValueType? thisType]) {
            File file = File(l.single as String);
            return file.existsSync();
          },
          'openFile': (List<Object?> l, List<LazyString> s, [Scope? thisScope, ValueType? thisType]) {
            File file = File('${l.first}');
            FileMode mode = switch (l.last as int) {
              0 => FileMode.read,
              1 => FileMode.writeOnly,
              2 => FileMode.writeOnlyAppend,
              int x => throw BSCException(
                  'openFile mode $x is not a valid mode\n${s.reversed.join('\n')}',
                  StringVariableGroup(
                    '$file',
                    tv.environment,
                  )),
            };
            return SydFile(file.openSync(mode: mode), mode == FileMode.writeOnlyAppend, tv.environment.fileType);
          },
          'fileModeRead': 0,
          'fileModeWrite': 1,
          'fileModeAppend': 2,
          'readFileBytes': (List<Object?> l, List<LazyString> s, [Scope? thisScope, ValueType? thisType]) {
            try {
              SydFile file = l.single as SydFile;
              int length = file.file.lengthSync();
              if (file.used) {
                throw BSCException('${file.file.path} was read twice ${s.reversed.join('\n')}', NoDataVG(tv.environment));
              }
              file.used = true;
              return SydList(
                file.file.readSync(length),
                ListValueType<int>(tv.environment.integerType, 'interr', tv),
              );
            } catch (e) {
              rethrow;
            }
          },
          'writeFile': (List<Object?> l, List<LazyString> s, [Scope? thisScope, ValueType? thisType]) {
            try {
              SydFile file = l.first as SydFile;
              if (file.used && !file.appendMode) {
                throw BSCException('${file.file.path} was written to twice ${s.reversed.join('\n')}', NoDataVG(tv.environment));
              }
              file.file.writeStringSync(l.last as String);
              file.used = true;
              return null;
            } catch (e) {
              rethrow;
            }
          },
          'closeFile': (List<Object?> l, List<LazyString> s, [Scope? thisScope, ValueType? thisType]) {
            try {
              SydFile file = l.single as SydFile;
              file.file.closeSync();
              return null;
            } catch (e) {
              rethrow;
            }
          },
          'deleteFile': (List<Object?> l, List<LazyString> s, [Scope? thisScope, ValueType? thisType]) {
            File file = File(l.single as String);
            file.deleteSync();
            return null;
          },
          'utf8Decode': (List<Object?> l, List<LazyString> s, [Scope? thisScope, ValueType? thisType]) {
            try {
              SydArray<int> input = l.single as SydArray<int>;
              return utf8.decode(input.array);
            } catch (e) {
              throw BSCException('error $e when decoding utf8 ${l.single}\n${s.reversed.join('\n')}', NoDataVG(tv.environment));
            }
          },
          'throw': (List<Object?> l, List<LazyString> s, [Scope? thisScope, ValueType? thisType]) {
            if (l.length > 1) {
              throw SydException((l.first as String) + '\nstack:\n' + s.reversed.join('\n'), l.last as int, NoDataVG(tv.environment));
            }
            throw ThrowException((l.single as String) + '\nstack:\n' + s.reversed.join('\n'), NoDataVG(tv.environment));
          },
          'substring': (List<Object?> l, List<LazyString> s, [Scope? thisScope, ValueType? thisType]) {
            if (l[1] as int > (l[2] as int)) {
              throw BSCException(
                  'Cannot substring when the start (${l[1]}) is more than the end (${l[2]})!\n${s.reversed.join('\n')}', NoDataVG(tv.environment));
            }
            if (l[1] as int < 0) {
              throw BSCException('Cannot substring when the start (${l[1]}) is less than 0!\n${s.reversed.join('\n')}', NoDataVG(tv.environment));
            }
            if (l[2] as int > (l[0] as String).length) {
              throw BSCException('Cannot substring when the end (${l[2]}) is more than the length of the string (${l[1]})!\n${s.reversed.join('\n')}',
                  NoDataVG(tv.environment));
            }
            return (l[0] as String).substring(l[1] as int, l[2] as int);
          },
          'sublist': (List<Object?> l, List<LazyString> s, [Scope? thisScope, ValueType? thisType]) {
            if (l[2] as int < (l[1] as int)) {
              throw BSCException('sublist called with ${l[2]} (end arg) < ${l[1]} (start arg) ${s.reversed.join('\n')}', NoDataVG(tv.environment));
            }
            return SydList(
              (l[0] as List<Object?>).sublist(l[1] as int, l[2] as int),
              getType(l.first, tv, -2, 0, 'intrinsics') as ValueType<SydList>,
            );
          },
          'stackTrace': (List<Object?> l, List<LazyString> s, [Scope? thisScope, ValueType? thisType]) {
            return s.reversed.join('\n');
          },
          'containsString': (List<Object?> l, List<LazyString> s, [Scope? thisScope, ValueType? thisType]) {
            return (l.first as String).contains(l.last as String);
          },
          'debugName': (List<Object?> l, List<LazyString> s, [Scope? thisScope, ValueType? thisType]) {
            return (l.single as Scope).debugName;
          },
          'createStringBuffer': (List<Object?> l, List<LazyString> s, [Scope? thisScope, ValueType? thisType]) {
            return StringBuffer();
          },
          'writeStringBuffer': (List<Object?> l, List<LazyString> s, [Scope? thisScope, ValueType? thisType]) {
            StringBuffer buffer = l.first as StringBuffer;
            buffer.write(l.last);
            return null;
          },
          'readStringBuffer': (List<Object?> l, List<LazyString> s, [Scope? thisScope, ValueType? thisType]) {
            StringBuffer buffer = l.first as StringBuffer;
            return buffer.toString();
          },
        }.map(
          (key, value) => MapEntry(
            tv.variables[key] ??= Variable(key),
            MaybeConstantValueWrapper(
                value is Function ? SydFunction(
                  value as Object? Function(List<Object?>, List<LazyString>, [Scope?, ValueType?]),
                  tv.igv(tv.variables[key]!, false) as ValueType<SydFunction>,
                  'intrinsics::$key'
                ) : value,
                true),
          ),
        ),
      );
  }
  Scope scope = Scope(false, false, rtl, tv.environment,
      intrinsics: intrinsics,
      parent: parent ?? rtl ?? intrinsics,
      stack: (stack ?? []) + [NotLazyString('$filename')],
      debugName: NotLazyString('$filename global scope'),
      variables: tv.variables);
  for (Statement statement in ast) {
    StatementResult sr = statement.run(scope);
    switch (sr.type) {
      case StatementResultType.nothing:
        break;
      case StatementResultType.breakWhile:
        throw BSCException('Break outside while', scope);
      case StatementResultType.continueWhile:
        throw BSCException('Continue outside while', scope);
      case StatementResultType.returnFunction:
        throw BSCException('Returned ${sr.value} outside function', scope);
      case StatementResultType.unwindAndThrow:
        stderr.writeln(sr.value);
        exit(1);
    }
  }
  return scope;
}

Environment runFile(String fileContents, String rtlPath, String file, bool profileMode, bool debugMode, List<String> args, IOSink stdout, IOSink stderr,
    void Function(int) exit) {
  Map<String, Variable> variables = {};
  Environment environment = Environment(TypeTable(), stderr);
  handleVariable(whateverVariable, variables);
  handleVariable(classMethodsVariable, variables);
  handleVariable(fwdclassVariable, variables);
  handleVariable(fwdclassfieldVariable, variables);
  handleVariable(fwdstaticfieldVariable, variables);
  handleVariable(fwdstaticmethodVariable, variables);
  handleVariable(fwdclassmethodVariable, variables);
  handleVariable(classVariable, variables);
  handleVariable(importVariable, variables);
  handleVariable(whileVariable, variables);
  handleVariable(breakVariable, variables);
  handleVariable(continueVariable, variables);
  handleVariable(returnVariable, variables);
  handleVariable(ifVariable, variables);
  handleVariable(enumVariable, variables);
  handleVariable(forVariable, variables);
  handleVariable(constVariable, variables);
  handleVariable(classNameVariable, variables);
  handleVariable(constructorVariable, variables);
  handleVariable(thisVariable, variables);
  handleVariable(toStringVariable, variables);
  handleVariable(throwVariable, variables);
  handleVariable(stringBufferVariable, variables);
  handleVariable(fileVariable, variables);
  handleVariable(Variable('Anything'), variables);
  handleVariable(Variable('Integer'), variables);
  handleVariable(Variable('String'), variables);
  handleVariable(Variable('Boolean'), variables);
  handleVariable(Variable('Null'), variables);
  handleVariable(Variable('~root_class'), variables);
  handleVariable(Variable('~sentinel'), variables);

  var rtl = parse(lex(File(rtlPath).readAsStringSync(), rtlPath, environment), rtlPath, null, false, variables, environment);
  var parseResult = parse(
    lex(
      fileContents,
      file,
      environment,
    ).toList(),
    file,
    rtl,
    true,
    variables,
    environment,
  );
  for (ValueType type in environment.typeTable.types.values) {
    if (type is ClassValueType && type.fwdDeclared) {
      throw BSCException('$type forward-declared but never declared', parseResult.value);
    }
  }
  Scope rtl2 = runProgram(
    rtl.key,
    rtlPath,
    null,
    null,
    rtl.value,
    profileMode,
    debugMode,
    stdout,
    stderr,
    exit,
    args,
  );
  runProgram(
    parseResult.key,
    file,
    null,
    rtl2,
    parseResult.value,
    profileMode,
    debugMode,
    stdout,
    stderr,
    exit,
    args,
  );
  return environment;
}
