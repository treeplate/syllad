import 'dart:convert';
import 'dart:io';
import 'syd-core.dart';
import 'package:characters/characters.dart';
import 'syd-lexer.dart';
import 'syd-statement-parser.dart';

// this program relies on current working directory being the directory with tests/ and lib/, because `dart test` makes Platform.script be somewhere outside of this directory
Scope runProgram(List<Statement> ast, String filename, String workspace, Scope? intrinsics, Scope? rtl, TypeValidator tv, bool profileMode, bool debugMode,
    IOSink stdout, IOSink stderr, void Function(int) exit,
    [List<String>? args, List<LazyString>? stack, Scope? parent]) {
  if (intrinsics == null) {
    ValueType whateverIterableType = IterableValueType(ValueType.create(null, whateverVariable, -2, 0, 'interr', 'intrinsics', tv), 'intrinsics', tv);
    ListValueType anythingListType = ListValueType<Object?>(tv.environment.anythingType, 'intrinsics', tv);
    assert(parent == null);
    assert(stack == null);
    intrinsics = Scope(false, false, rtl, tv.environment,
        variables: tv.variables,
        debugName: NotLazyString('intrinsics'),
        stack: [NotLazyString('intrinsics')],
        profileMode: profileMode,
        debugMode: debugMode,
        intrinsics: null /* we ARE the intrinsics*/)
      ..values.addAll({
        "true": true,
        "false": false,
        "null": null,
        "args": args!.map((e) => ValueWrapper(tv.environment.stringType, e, 'argument of program')).toList(),
        "print": (List<ValueWrapper> l, List<LazyString> s, [Scope? thisScope, ValueType? thisType]) {
          stdout.write(l
              .map((e) => e.toStringWithStack(
                    s,
                    -2,
                    0,
                    workspace,
                    'interr',
                    true,
                    tv.environment,
                  ))
              .join(' '));
          return ValueWrapper(tv.environment.integerType, 0, 'print rtv');
        },
        "debug": (List<ValueWrapper> l, List<LazyString> s, [Scope? thisScope, ValueType? thisType]) {
          return ValueWrapper(
              tv.environment.stringType,
              l.single
                  .valueC<Scope>(
                    null,
                    s,
                    0,
                    0,
                    workspace,
                    filename,
                    tv.environment,
                  )
                  .dump(),
              'debug rtv');
        },
        "stderr": (List<ValueWrapper> l, List<LazyString> s, [Scope? thisScope, ValueType? thisType]) {
          stderr.writeln(l
              .map((e) => e.toStringWithStack(
                    s,
                    -2,
                    0,
                    workspace,
                    'interr',
                    true,
                    tv.environment,
                  ))
              .join(' '));
          return ValueWrapper(tv.environment.integerType, 0, 'stderr rtv');
        },
        "concat": (List<ValueWrapper> l, List<LazyString> s, [Scope? thisScope, ValueType? thisType]) {
          return ValueWrapper(
              tv.environment.stringType,
              l
                  .map((x) => x.toStringWithStack(
                        s,
                        -2,
                        0,
                        'interr',
                        'todo',
                        true,
                        tv.environment,
                      ))
                  .join(''),
              'concat rtv');
        },
        "addLists": (List<ValueWrapper> l, List<LazyString> s, [Scope? thisScope, ValueType? thisType]) {
          return ValueWrapper(
              ListValueType(tv.environment.anythingType, 'intrinsics', tv),
              l
                  .expand<ValueWrapper>((element) => element.valueC(
                        null,
                        s,
                        -2,
                        0,
                        'interr',
                        'interr',
                        tv.environment,
                      ))
                  .toList(),
              'addLists rtv');
        },
        "parseInt": (List<ValueWrapper> l, List<LazyString> s, [Scope? thisScope, ValueType? thisType]) {
          return ValueWrapper(
            tv.environment.integerType,
            int.parse(l.single.valueC(
              null,
              s,
              -2,
              0,
              'interr',
              'interr',
              tv.environment,
            )),
            'parseInt rtv',
          );
        },
        "split": (List<ValueWrapper> l, List<LazyString> s, [Scope? thisScope, ValueType? thisType]) {
          if (l.first.valueC(
                null,
                s,
                -2,
                0,
                'interr',
                'interr',
                tv.environment,
              ) ==
              '') {
            return ValueWrapper(ListValueType(tv.environment.stringType, 'intrinsics', tv), [l.first], 'split rtv special case');
          }
          return ValueWrapper(
            ListValueType(tv.environment.stringType, 'intrinsics', tv),
            l.first
                .valueC<String>(
                  null,
                  s,
                  -2,
                  0,
                  'interr',
                  'interr',
                  tv.environment,
                )
                .split(
                  l.last.valueC(
                    null,
                    s,
                    -2,
                    0,
                    'interr',
                    'interr',
                    tv.environment,
                  ),
                )
                .map<ValueWrapper>((e) => ValueWrapper(tv.environment.stringType, e, 'split rtv element'))
                .toList(),
            'split rtv',
          );
        },
        "charsOf": (List<ValueWrapper> l, List<LazyString> s, [Scope? thisScope, ValueType? thisType]) {
          return ValueWrapper(
            IterableValueType(tv.environment.stringType, 'intrinsics', tv),
            (l.single.valueC(
              null,
              s,
              -2,
              0,
              'interr',
              'interr',
              tv.environment,
            ) as String)
                .characters
                .map((e) => ValueWrapper(tv.environment.stringType, e, 'charsOf char')),
            'charsOf rtv',
          );
        },
        "scalarValues": (List<ValueWrapper> l, List<LazyString> s, [Scope? thisScope, ValueType? thisType]) {
          return ValueWrapper(
            IterableValueType(tv.environment.integerType, 'intrinsics', tv),
            l.single
                .valueC<String>(
                  null,
                  s,
                  -2,
                  0,
                  'interr',
                  'interr',
                  tv.environment,
                )
                .runes
                .map((e) => ValueWrapper(tv.environment.integerType, e, 'scalarValues char')),
            'scalarValues rtv',
          );
        },
        'filledList': (List<ValueWrapper> l, List<LazyString> s, [Scope? thisScope, ValueType? thisType]) {
          return ValueWrapper<List<ValueWrapper>>(
              anythingListType,
              List.filled(
                  l.first.valueC<int>(
                    null,
                    s,
                    -2,
                    0,
                    'interr',
                    'interr',
                    tv.environment,
                  ),
                  l.last,
                  growable: true),
              'filledList rtv');
        },
        'sizedList': (List<ValueWrapper> l, List<LazyString> s, [Scope? thisScope, ValueType? thisType]) {
          return ValueWrapper<List<ValueWrapper>>(
              anythingListType,
              List.filled(
                  l.first.valueC(
                    null,
                    s,
                    -2,
                    0,
                    'interr',
                    'interr',
                    tv.environment,
                  ),
                  ValueWrapper<String>(tv.environment.typeTable.types[tv.variables['Sentinel'] ??= Variable('Sentinel')] as ValueType<String>, "sizedList sentinel value",
                      'sizedList sentinel'),
                  growable: true),
              'sizedList rtv');
        },
        "len": (List<ValueWrapper> l, List<LazyString> s, [Scope? thisScope, ValueType? thisType]) {
          if (!l.single
              .typeC(
                null,
                s,
                -2,
                0,
                'interr',
                'interr',
                tv.environment,
              )
              .isSubtypeOf(whateverIterableType)) {
            throw BSCException(
                'len() takes a list as its argument, not a ${l.single.typeC(
                  null,
                  s,
                  -2,
                  0,
                  'interr',
                  'interr',
                  tv.environment,
                )} ${s.reversed.join('\n')}',
                NoDataVG(tv.environment));
          }
          return ValueWrapper(
              tv.environment.integerType,
              l.single
                  .valueC<Iterable<ValueWrapper>>(
                    null,
                    s,
                    -2,
                    0,
                    'interr',
                    'interr',
                    tv.environment,
                  )
                  .length,
              'len rtv');
        },
        "input": (List<ValueWrapper> l, List<LazyString> s, [Scope? thisScope, ValueType? thisType]) {
          return ValueWrapper(tv.environment.stringType, stdin.readLineSync(), 'input rtv');
        },
        "append": (List<ValueWrapper> l, List<LazyString> s, [Scope? thisScope, ValueType? thisType]) {
          if (!l.last
              .typeC(
                null,
                s,
                -2,
                0,
                'interr',
                'interr',
                tv.environment,
              )
              .isSubtypeOf((l.first.typeC(
                null,
                s,
                -2,
                0,
                'interr',
                'interr',
                tv.environment,
              ) as ListValueType)
                  .genericParameter)) {
            throw BSCException(
                "You cannot append a ${l.last.typeC(
                  null,
                  s,
                  -2,
                  0,
                  'interr',
                  'interr',
                  tv.environment,
                )} to a ${l.first.typeC(
                  null,
                  s,
                  -2,
                  0,
                  'interr',
                  'interr',
                  tv.environment,
                )}!\n${s.reversed.join('\n')}",
                NoDataVG(tv.environment));
          }
          l.first
              .valueC<List>(
                null,
                s,
                -2,
                0,
                'interr',
                'interr',
                tv.environment,
              )
              .add(l.last);
          return l.last;
        },
        "pop": (List<ValueWrapper> l, List<LazyString> s, [Scope? thisScope, ValueType? thisType]) {
          List<ValueWrapper> list = l.first.valueC(
            null,
            s,
            -2,
            0,
            'interr',
            'interr',
            tv.environment,
          );
          if (list.isEmpty) {
            throw BSCException("Cannot pop from an empty list!\n${s.reversed.join('\n')}", NoDataVG(tv.environment));
          }
          return list.removeLast();
        },
        "iterator": (List<ValueWrapper> l, List<LazyString> s, [Scope? thisScope, ValueType? thisType]) {
          return ValueWrapper(
              IteratorValueType(tv.environment.anythingType, 'intrinsics', tv),
              l.single
                  .valueC<Iterable>(
                    null,
                    s,
                    -2,
                    0,
                    'interr',
                    'interr',
                    tv.environment,
                  )
                  .iterator,
              'iterator rtv');
        },
        "next": (List<ValueWrapper> l, List<LazyString> s, [Scope? thisScope, ValueType? thisType]) {
          return ValueWrapper(
              tv.environment.booleanType,
              l.single
                  .valueC<Iterator>(
                    null,
                    s,
                    -2,
                    0,
                    'interr',
                    'interr',
                    tv.environment,
                  )
                  .moveNext(),
              'next rtv');
        },
        "current": (List<ValueWrapper> l, List<LazyString> s, [Scope? thisScope, ValueType? thisType]) {
          return l.single
              .valueC<Iterator<ValueWrapper>>(
                null,
                s,
                -2,
                0,
                'interr',
                'interr',
                tv.environment,
              )
              .current;
        },
        "stringTimes": (List<ValueWrapper> l, List<LazyString> s, [Scope? thisScope, ValueType? thisType]) {
          return ValueWrapper(
            tv.environment.stringType,
            l.first.valueC<String>(
                  null,
                  s,
                  -2,
                  0,
                  'interr',
                  'interr',
                  tv.environment,
                ) *
                l.last.valueC<int>(
                  null,
                  s,
                  -2,
                  0,
                  'interr',
                  'interr',
                  tv.environment,
                ),
            'stringTimes rtv',
          );
        },
        "copy": (List<ValueWrapper> l, List<LazyString> s, [Scope? thisScope, ValueType? thisType]) {
          return ValueWrapper(
            anythingListType,
            l.single
                .valueC<Iterable<ValueWrapper>>(
                  null,
                  s,
                  -2,
                  0,
                  'interr',
                  'interr',
                  tv.environment,
                )
                .toList(),
            'copy rtv',
          );
        },
        "clear": (List<ValueWrapper> l, List<LazyString> s, [Scope? thisScope, ValueType? thisType]) {
          l.single
              .valueC<List<ValueWrapper>>(
                null,
                s,
                -2,
                0,
                'interr',
                'interr',
                tv.environment,
              )
              .clear();
          return ValueWrapper(tv.environment.integerType, 0, 'clear rtv');
        },
        "hex": (List<ValueWrapper> l, List<LazyString> s, [Scope? thisScope, ValueType? thisType]) {
          return ValueWrapper(
              tv.environment.stringType,
              l.single
                  .valueC<int>(
                    null,
                    s,
                    -2,
                    0,
                    'interr',
                    'interr',
                    tv.environment,
                  )
                  .toRadixString(16),
              'hex rtv');
        },
        "chr": (List<ValueWrapper> l, List<LazyString> s, [Scope? thisScope, ValueType? thisType]) {
          return ValueWrapper(
              tv.environment.stringType,
              String.fromCharCode(l.single.valueC(
                null,
                s,
                -2,
                0,
                'interr',
                'interr',
                tv.environment,
              )),
              'chr rtv');
        },
        "exit": (List<ValueWrapper> l, List<LazyString> s, [Scope? thisScope, ValueType? thisType]) {
          exit(l.single.valueC(
            null,
            s,
            -2,
            0,
            'interr',
            'interr',
            tv.environment,
          ));
          return ValueWrapper(tv.environment.nullType, null, 'exit rtv');
        },
        "fileExists": (List<ValueWrapper> l, List<LazyString> s, [Scope? thisScope, ValueType? thisType]) {
          File file = File('${l.single.valueC(
            null,
            s,
            -2,
            0,
            'interr',
            'interr',
            tv.environment,
          )}');
          return ValueWrapper(tv.environment.booleanType, file.existsSync(), 'fileExists rtv');
        },
        "openFile": (List<ValueWrapper> l, List<LazyString> s, [Scope? thisScope, ValueType? thisType]) {
          File file = File('${l.first.valueC(
            null,
            s,
            -2,
            0,
            'interr',
            'interr',
            tv.environment,
          )}');
          FileMode mode = switch (l.last.valueC<int>(
            null,
            s,
            -2,
            0,
            'interr',
            'interr',
            tv.environment,
          )) {
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
          return ValueWrapper(tv.environment.fileType, SydFile(file.openSync(mode: mode), mode == FileMode.writeOnlyAppend), 'openFile rtv');
        },
        "fileModeRead": 0,
        "fileModeWrite": 1,
        "fileModeAppend": 2,
        "readFileBytes": (List<ValueWrapper> l, List<LazyString> s, [Scope? thisScope, ValueType? thisType]) {
          try {
            SydFile file = l.single.valueC(
              null,
              s,
              -2,
              0,
              'interr',
              'interr',
              tv.environment,
            );
            int length = file.file.lengthSync();
            if (file.used) {
              throw BSCException('${file.file.path} was read twice ${s.reversed.join('\n')}', NoDataVG(tv.environment));
            }
            file.used = true;
            return ValueWrapper(ListValueType<int>(tv.environment.integerType, 'interr', tv), file.file.readSync(length), 'readFileBytes rtv');
          } catch (e) {
            rethrow;
          }
        },
        "writeFile": (List<ValueWrapper> l, List<LazyString> s, [Scope? thisScope, ValueType? thisType]) {
          try {
            SydFile file = l.first.valueC(
              null,
              s,
              -2,
              0,
              'interr',
              'interr',
              tv.environment,
            );
            if (file.used && !file.appendMode) {
              throw BSCException('${file.file.path} was written to twice ${s.reversed.join('\n')}', NoDataVG(tv.environment));
            }
            file.file.writeStringSync(l.last.valueC(
              null,
              s,
              -2,
              0,
              'interr',
              'interr',
              tv.environment,
            ));
            file.used = true;
            return ValueWrapper(tv.environment.nullType, null, 'writeFile rtv');
          } catch (e) {
            rethrow;
          }
        },
        "closeFile": (List<ValueWrapper> l, List<LazyString> s, [Scope? thisScope, ValueType? thisType]) {
          try {
            SydFile file = l.single.valueC(
              null,
              s,
              -2,
              0,
              'interr',
              'interr',
              tv.environment,
            );
            file.file.closeSync();
            return ValueWrapper(tv.environment.nullType, null, 'closeFile rtv');
          } catch (e) {
            rethrow;
          }
        },
        "deleteFile": (List<ValueWrapper> l, List<LazyString> s, [Scope? thisScope, ValueType? thisType]) {
          File file = File(l.single.valueC<String>(
            null,
            s,
            -2,
            0,
            'interr',
            'interr',
            tv.environment,
          ));
          file.deleteSync();
          return ValueWrapper(tv.environment.nullType, null, 'deleteFile rtv');
        },
        "utf8Decode": (List<ValueWrapper> l, List<LazyString> s, [Scope? thisScope, ValueType? thisType]) {
          try {
            List<int> input = l.single.valueC(
              null,
              s,
              -2,
              0,
              'interr',
              'interr',
              tv.environment,
            );
            return ValueWrapper(tv.environment.stringType, utf8.decode(input), 'utf8Decode rtv');
          } catch (e) {
            throw BSCException(
                'error $e when reading file ${l.single.valueC(
                  null,
                  s,
                  -2,
                  0,
                  'interr',
                  'interr',
                  tv.environment,
                )}\n${s.reversed.join('\n')}',
                NoDataVG(tv.environment));
          }
        },
        "println": (List<ValueWrapper> l, List<LazyString> s, [Scope? thisScope, ValueType? thisType]) {
          stdout.writeln(l
              .map(((e) => e.toStringWithStack(
                    s + [NotLazyString('println calling toString()')],
                    -2,
                    0,
                    'interr',
                    'interr',
                    true,
                    tv.environment,
                  )))
              .join(' '));
          return ValueWrapper(tv.environment.integerType, 0, 'println rtv');
        },
        "throw": (List<ValueWrapper> l, List<LazyString> s, [Scope? thisScope, ValueType? thisType]) {
          if (l.length > 1) {
            throw SydException(
                l.first.valueC<String>(
                      null,
                      s,
                      -2,
                      0,
                      'interr',
                      'interr',
                      tv.environment,
                    ) +
                    "\nstack:\n" +
                    s.reversed.join('\n'),
                l.last.valueC(
                  null,
                  s,
                  -2,
                  0,
                  'interr',
                  'interr',
                  tv.environment,
                ),
                NoDataVG(tv.environment));
          }
          throw ThrowException(
              l.single.valueC<String>(
                    null,
                    s,
                    -2,
                    0,
                    'interr',
                    'interr',
                    tv.environment,
                  ) +
                  "\nstack:\n" +
                  s.reversed.join('\n'),
              NoDataVG(tv.environment));
        },
        "substring": (List<ValueWrapper> l, List<LazyString> s, [Scope? thisScope, ValueType? thisType]) {
          if (l[1].valueC(
                null,
                s,
                -2,
                0,
                'interr',
                'interr',
                tv.environment,
              ) as int >
              (l[2].valueC(
                null,
                s,
                -2,
                0,
                'interr',
                'interr',
                tv.environment,
              ) as int)) {
            throw BSCException("Cannot substring when the start (${l[1]}) is more than the end (${l[2]})!\n${s.reversed.join('\n')}", NoDataVG(tv.environment));
          }
          if (l[1].valueC(
                null,
                s,
                -2,
                0,
                'interr',
                'interr',
                tv.environment,
              ) as int <
              0) {
            throw BSCException("Cannot substring when the start (${l[1]}) is less than 0!\n${s.reversed.join('\n')}", NoDataVG(tv.environment));
          }
          if (l[2].valueC(
                null,
                s,
                -2,
                0,
                'interr',
                'interr',
                tv.environment,
              ) as int >
              l[0]
                  .valueC<String>(
                    null,
                    s,
                    -2,
                    0,
                    'interr',
                    'interr',
                    tv.environment,
                  )
                  .length) {
            throw BSCException(
                "Cannot substring when the end (${l[2]}) is more than the length of the string (${l[1]})!\n${s.reversed.join('\n')}", NoDataVG(tv.environment));
          }
          return ValueWrapper(
              tv.environment.stringType,
              (l[0].valueC(
                null,
                s,
                -2,
                0,
                'interr',
                'interr',
                tv.environment,
              ) as String)
                  .substring(
                      l[1].valueC(
                        null,
                        s,
                        -2,
                        0,
                        'interr',
                        'interr',
                        tv.environment,
                      ) as int,
                      l[2].valueC(
                        null,
                        s,
                        -2,
                        0,
                        'interr',
                        'interr',
                        tv.environment,
                      ) as int),
              'substring rtv');
        },
        "sublist": (List<ValueWrapper> l, List<LazyString> s, [Scope? thisScope, ValueType? thisType]) {
          if (l[2].valueC<int>(
                null,
                s,
                -2,
                0,
                'interr',
                'interr',
                tv.environment,
              ) <
              l[1].valueC(
                null,
                s,
                -2,
                0,
                'interr',
                'interr',
                tv.environment,
              )) {
            throw BSCException("sublist called with ${l[2]} (end arg) < ${l[1]} (start arg) ${s.reversed.join('\n')}", NoDataVG(tv.environment));
          }
          return ValueWrapper(
              l.first.typeC(
                null,
                s,
                -2,
                0,
                'interr',
                'interr',
                tv.environment,
              ),
              (l[0].valueC(
                null,
                s,
                -2,
                0,
                'interr',
                'interr',
                tv.environment,
              ) as List<ValueWrapper>)
                  .sublist(
                      l[1].valueC(
                        null,
                        s,
                        -2,
                        0,
                        'interr',
                        'interr',
                        tv.environment,
                      ) as int,
                      l[2].valueC(
                        null,
                        s,
                        -2,
                        0,
                        'interr',
                        'interr',
                        tv.environment,
                      ) as int),
              'sublist rtv');
        },
        "stackTrace": (List<ValueWrapper> l, List<LazyString> s, [Scope? thisScope, ValueType? thisType]) {
          return ValueWrapper(tv.environment.stringType, s.reversed.join('\n'), 'stackTrace rtv');
        },
        "containsString": (List<ValueWrapper> l, List<LazyString> s, [Scope? thisScope, ValueType? thisType]) {
          return ValueWrapper(
              tv.environment.booleanType,
              l.first
                  .valueC<String>(
                    null,
                    s,
                    -2,
                    0,
                    workspace,
                    filename,
                    tv.environment,
                  )
                  .contains(l.last.valueC<String>(
                    null,
                    s,
                    -2,
                    0,
                    workspace,
                    filename,
                    tv.environment,
                  )),
              'stringContains rtv');
        },
        "debugName": (List<ValueWrapper> l, List<LazyString> s, [Scope? thisScope, ValueType? thisType]) {
          return ValueWrapper(
              tv.environment.stringType,
              (l.single.valueC(
                null,
                s,
                -2,
                0,
                workspace,
                filename,
                tv.environment,
              ) as Scope)
                  .debugName,
              'debugName rtv');
        },
        'createStringBuffer': (List<ValueWrapper> l, List<LazyString> s, [Scope? thisScope, ValueType? thisType]) {
          return ValueWrapper(tv.environment.stringBufferType, StringBuffer(), 'createStringBuffer rtv');
        },
        'writeStringBuffer': (List<ValueWrapper> l, List<LazyString> s, [Scope? thisScope, ValueType? thisType]) {
          StringBuffer buffer = l.first.valueC(
            null,
            s,
            -2,
            0,
            workspace,
            filename,
            tv.environment,
          );
          buffer.write(l.last.valueC(
            null,
            s,
            -2,
            0,
            workspace,
            filename,
            tv.environment,
          ));
          return ValueWrapper(tv.environment.nullType, null, 'writeStringBuffer rtv');
        },
        'readStringBuffer': (List<ValueWrapper> l, List<LazyString> s, [Scope? thisScope, ValueType? thisType]) {
          StringBuffer buffer = l.first.valueC(
            null,
            s,
            -2,
            0,
            workspace,
            filename,
            tv.environment,
          );
          return ValueWrapper(tv.environment.stringType, buffer.toString(), 'readStringBuffer rtv');
        },
      }.map((key, value) => MapEntry(tv.variables[key] ??= Variable(key),
          MaybeConstantValueWrapper(ValueWrapper(tv.igv(tv.variables[key]!, false), value, '$key from intrinsics'), true))));
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

Environment runFile(String fileContents, String rtlPath, String workspace, String file, bool profileMode, bool debugMode, List<String> args, IOSink stdout, IOSink stderr,
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

  var rtl = parse(lex(File(rtlPath).readAsStringSync(), '.', rtlPath, environment), '.', rtlPath, null, false, variables, environment);
  var parseResult = parse(
    lex(
      fileContents,
      workspace,
      file,
      environment,
    ).toList(),
    workspace,
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
    '.',
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
    workspace,
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
