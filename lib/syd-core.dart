import 'dart:collection';
import 'dart:convert';
import 'package:characters/characters.dart';
import 'package:collection/collection.dart';
import 'dart:io';

class Concat {
  final Object? left;
  final Object? right;

  String toString() => left.toString() + right.toString();

  Concat(this.left, this.right) {
    assert(left is! Identifier);
    assert(right is! Identifier);
  }
}

class NotLazyString extends LazyString {
  final String str;

  String toString() => str;

  NotLazyString(this.str);
}

class CursorPositionLazyString extends LazyString {
  final String str;
  final int line;
  final int col;
  final String file;

  String toString() => '$str ${formatCursorPosition(line, col, file)}';

  CursorPositionLazyString(this.str, this.line, this.col, this.file);
}

class IdentifierLazyString extends LazyString {
  final Identifier variable;

  String toString() => variable.name;

  IdentifierLazyString(this.variable);
}

class ConcatenateLazyString extends LazyString {
  final LazyString left;
  final LazyString right;

  String toString() => left.toString() + right.toString();

  ConcatenateLazyString(this.left, this.right);
}

String formatCursorPosition(int line, int col, String file) {
  return '$file:$line:$col';
}

// this should be sealed
abstract class Expression {
  Expression(this.line, this.col, this.file, this.tv);
  final int line, col;
  final String file;
  final TypeValidator tv;
  Object? eval(Scope scope);
  bool isLValue(TypeValidator scope);

  void write(Object? value, Scope scope) {
    throw StateError('write of $runtimeType is not defined');
  }

  ValueType get staticType;
  Expression get internal => this;
}

enum StatementResultType {
  nothing,
  breakWhile,
  continueWhile,
  returnFunction,
  unwindAndThrow,
}

class StatementResult {
  final StatementResultType type;
  final Object? value;

  String toString() => 'StatementResult.${type.name}($value)';

  StatementResult(this.type, [this.value]);
}

// this should be sealed
abstract class Statement {
  Statement(this.line, this.col);

  StatementResult run(Scope scope);
  final int line;
  final int col;
  TypeValidator? get tv => null;
}

class LazyString {}

const Identifier whateverVariable = Identifier("Whatever");
const Identifier fwdclassVariable = Identifier("fwdclass");
const Identifier fwdclassfieldVariable = Identifier("fwdclassfield");
const Identifier fwdclassmethodVariable = Identifier("fwdclassmethod");
const Identifier fwdstaticfieldVariable = Identifier("fwdstaticfield");
const Identifier fwdstaticmethodVariable = Identifier("fwdstaticmethod");
const Identifier classVariable = Identifier("class");
const Identifier importVariable = Identifier("import");
const Identifier whileVariable = Identifier("while");
const Identifier breakVariable = Identifier("break");
const Identifier continueVariable = Identifier("continue");
const Identifier returnVariable = Identifier("return");
const Identifier ifVariable = Identifier("if");
const Identifier enumVariable = Identifier("enum");
const Identifier forVariable = Identifier("for");
const Identifier constVariable = Identifier("const");
const Identifier classNameVariable = Identifier("className");
const Identifier constructorVariable = Identifier("constructor");
const Identifier thisVariable = Identifier("this");
const Identifier toStringVariable = Identifier("toString");
const Identifier throwVariable = Identifier("throw");
const Identifier stringBufferVariable = Identifier("StringBuffer");
const Identifier fileVariable = Identifier("File");

void handleVariable(Identifier variable, Map<String, Identifier> identifiers) {
  if (identifiers[variable.name] == null) {
    identifiers[variable.name] = variable;
  } else {
    throw "Attempted to create duplicate variable ${variable.name}";
  }
}

abstract class SydException implements Exception {
  SydException._(this.message, this.scope);
  final String message;
  final VariableGroup scope;
  String toString() => message;
  int get exitCode;

  factory SydException(String message, int exitCode, VariableGroup scope) {
    if (exitCode == -1) {
      return CompileTimeSydException(message, scope);
    } else if (exitCode == -2) {
      return RuntimeSydException(message, scope);
    } else if (exitCode == -3) {
      return AssertException(message, scope);
    } else if (exitCode == -4) {
      return ThrowException(message, scope);
    } else {
      throw FormatException("Invalid exit code $exitCode");
    }
  }
}

class CompileTimeSydException extends SydException {
  CompileTimeSydException(String message, VariableGroup scope) : super._(message, scope);

  int get exitCode => -1;
}

class RuntimeSydException extends SydException {
  RuntimeSydException(String message, VariableGroup scope) : super._(message, scope);

  int get exitCode => -2;
}

class AssertException extends SydException {
  AssertException(String message, VariableGroup scope) : super._(message, scope);

  int get exitCode => -3;
}

class ThrowException extends SydException {
  ThrowException(String message, VariableGroup scope) : super._(message, scope);

  int get exitCode => -4;
}

class Identifier {
  final String name;

  String toString() => throw "Temp: tried to tostring variable $name";

  const Identifier(this.name);
}

abstract class TypedValue<T> {
  ValueType<T> get type;
}

class SydFunction<T extends Object?> extends TypedValue<SydFunction<T>> {
  final T Function(List<Object?> args, [Scope?, ValueType?]) function;
  final ValueType<SydFunction<T>> type;
  final Object? debugName;

  String toString() => '<function ($debugName)>';

  SydFunction(this.function, this.type, this.debugName);
}

class SydIterator<T extends Object?> extends TypedValue<SydIterator<T>> {
  final Iterator<T> iterator;
  final ValueType<SydIterator<T>> type;

  SydIterator(this.iterator, this.type);
}

class SydIterable<T extends Object?> extends TypedValue<SydIterable<T>> {
  final Iterable<T> iterable;
  final ValueType<SydIterable<T>> type;

  String toString() {
    throw 'Don\'t call SydIterable.toString';
  }

  SydIterable(this.iterable, this.type);
}

class SydArray<T extends Object?> extends SydIterable<T> {
  final List<T> array;

  SydArray(this.array, ValueType<SydArray<T>> type) : super(array, type);
}

class SydList<T extends Object?> extends SydArray<T> {
  final List<T> list;

  SydList(this.list, ValueType<SydList<T>> type) : super(list, type);
}

class SydSentinel extends TypedValue<SydSentinel> {
  final ValueType<SydSentinel> type;
  SydSentinel(Environment env) : type = env.sentinelType;

  String toString() => '<internal error - sentinel should not be tostringed>';
}

class SydFile extends TypedValue<SydFile> {
  final RandomAccessFile file;
  final bool appendMode;
  bool used = false;
  final ValueType<SydFile> type;

  SydFile(this.file, this.appendMode, this.type);
}

ValueType elementTypeOf(ValueType<SydIterable> iterable) {
  switch (iterable) {
    case IterableValueType x:
      return x.genericParameter;
    case ArrayValueType x:
      return x.genericParameter;
    case ListValueType x:
      return x.genericParameter;
    default:
      throw 'Unknown iterable type $iterable';
  }
}

class TypeTable {
  final Map<Identifier, ValueType> types = {};
  final List<TypeTable> parents;

  operator [](Identifier key) {
    return types[key] ?? parents.reversed.firstWhereOrNull((element) => element[key] != null)?[key];
  }

  operator []=(Identifier key, ValueType value) {
    types[key] = value;
  }

  TypeTable(this.parents);
}

class Environment {
  late final ValueType anythingType;
  late final ValueType<int> integerType;
  late final ValueType<String> stringType;
  late final ValueType<bool> booleanType;
  late final ValueType<Null> nullType;
  late final ValueType<Scope> rootClassType;
  late final ValueType<StringBuffer> stringBufferType;
  late final ValueType<SydFile> fileType;
  late final ValueType<SydSentinel> sentinelType;
  late final ValueType<Stopwatch> timerType;
  final List<BoolList> subtypeTable = []; // subtypeTable[a][b] is equivalent to a.isSubtypeOf(b)
  int currentTypeId = 0;
  final List<LazyString> stack = [NotLazyString('main')];
  final List<ValueType> allTypes = [];
  final Map<String, Scope> filesRan = {};
  final Map<String, TypeValidator> loadedGlobalScopes = {};
  final Map<Identifier, MapEntry<Stopwatch, int>> profile = {};
  final Map<String, MapEntry<List<Statement>, TypeValidator>> filesLoaded = {};
  final Map<Identifier, Object?> globals = {};
  final List<String> filesStartedLoading = [];
  final IOSink stdout;
  final IOSink stderr;
  final List<String> commandLineArguments;
  final void Function(int) exit;
  final TypeTable rootTypeTable;

  Environment(this.rootTypeTable, this.stdout, this.stderr, this.commandLineArguments, this.exit) {
    initIntrinsics();
  }

  final Map<String, Identifier> identifiers = {};
  late final Map<String, Object?> intrinsics;

  void initIntrinsics() {
    handleVariable(whateverVariable, identifiers);
    handleVariable(fwdclassVariable, identifiers);
    handleVariable(fwdclassfieldVariable, identifiers);
    handleVariable(fwdstaticfieldVariable, identifiers);
    handleVariable(fwdstaticmethodVariable, identifiers);
    handleVariable(fwdclassmethodVariable, identifiers);
    handleVariable(classVariable, identifiers);
    handleVariable(importVariable, identifiers);
    handleVariable(whileVariable, identifiers);
    handleVariable(breakVariable, identifiers);
    handleVariable(continueVariable, identifiers);
    handleVariable(returnVariable, identifiers);
    handleVariable(ifVariable, identifiers);
    handleVariable(enumVariable, identifiers);
    handleVariable(forVariable, identifiers);
    handleVariable(constVariable, identifiers);
    handleVariable(classNameVariable, identifiers);
    handleVariable(constructorVariable, identifiers);
    handleVariable(thisVariable, identifiers);
    handleVariable(toStringVariable, identifiers);
    handleVariable(throwVariable, identifiers);
    handleVariable(stringBufferVariable, identifiers);
    handleVariable(fileVariable, identifiers);
    handleVariable(Identifier('Anything'), identifiers);
    handleVariable(Identifier('Integer'), identifiers);
    handleVariable(Identifier('String'), identifiers);
    handleVariable(Identifier('Boolean'), identifiers);
    handleVariable(Identifier('Null'), identifiers);
    handleVariable(Identifier('~root_class'), identifiers);
    handleVariable(Identifier('~sentinel'), identifiers);
    handleVariable(Identifier('Timer'), identifiers);
    anythingType = ValueType.internal(null, identifiers['Anything']!, 'intrinsics', false, this, rootTypeTable);
    integerType = ValueType.internal(anythingType, identifiers['Integer']!, 'intrinsics', false, this, rootTypeTable);
    stringType = ValueType.internal(anythingType, identifiers['String']!, 'intrinsics', false, this, rootTypeTable);
    booleanType = ValueType.internal(anythingType, identifiers['Boolean']!, 'intrinsics', false, this, rootTypeTable);
    nullType = NullValueType.internal(anythingType, this, rootTypeTable);
    rootClassType = ValueType.internal(anythingType, identifiers['~root_class']!, 'intrinsics', false, this, rootTypeTable);
    stringBufferType = ValueType.internal(anythingType, identifiers['StringBuffer']!, 'intrinsics', false, this, rootTypeTable);
    fileType = ValueType.internal(anythingType, identifiers['File']!, 'intrinsics', false, this, rootTypeTable);
    sentinelType = ValueType.internal(anythingType, identifiers['~sentinel']!, 'intrinsics', false, this, rootTypeTable);
    timerType = ValueType.internal(anythingType, identifiers['Timer']!, 'intrinsics', false, this, rootTypeTable);
    VariableGroup dummyVariableGroup = NoDataVG(this);
    intrinsics = {
      'true': true,
      'false': false,
      'null': null,
      'args': SydList(commandLineArguments, ListValueType<String>(stringType, 'intrinsics', this, rootTypeTable)),
      'print': SydFunction(
        (List<Object?> args, [Scope? thisScope, ValueType? thisType]) {
          stdout.write(args
              .map((e) => toStringWithStacker(
                    e,
                    -2,
                    0,
                    'interr',
                    true,
                  ))
              .join(' '));
          return 0;
        },
        FunctionValueType(integerType, InfiniteIterable(anythingType), 'intrinsics', this, rootTypeTable),
        'print intrinsic',
      ),
      'debug': SydFunction(
        (List<Object?> args, [Scope? thisScope, ValueType? thisType]) {
          return (args.single as Scope).dump();
        },
        FunctionValueType(stringType, [rootClassType], 'intrinsics', this, rootTypeTable),
        'debug intrinsic',
      ),
      'stderr': SydFunction(
        (List<Object?> args, [Scope? thisScope, ValueType? thisType]) {
          stderr.writeln(args
              .map((e) => toStringWithStacker(
                    e,
                    -2,
                    0,
                    'interr',
                    true,
                  ))
              .join(' '));
          return 0;
        },
        FunctionValueType(integerType, InfiniteIterable(anythingType), 'intrinsics', this, rootTypeTable),
        'stderr intrinsic',
      ),
      'println': SydFunction(
        (List<Object?> args, [Scope? thisScope, ValueType? thisType]) {
          stdout.writeln(args
              .map((e) => toStringWithStacker(
                    e,
                    -2,
                    0,
                    'interr',
                    true,
                  ))
              .join(' '));
          return 0;
        },
        FunctionValueType(integerType, InfiniteIterable(anythingType), 'intrinsics', this, rootTypeTable),
        'println intrinsic',
      ),
      'concat': SydFunction(
        (List<Object?> args, [Scope? thisScope, ValueType? thisType]) {
          return args
              .map((x) => toStringWithStacker(
                    x,
                    -2,
                    0,
                    'interr',
                    true,
                  ))
              .join('');
        },
        FunctionValueType(stringType, InfiniteIterable(anythingType), 'intrinsics', this, rootTypeTable),
        'concat intrinsic',
      ),
      'addLists': SydFunction(
        (List<Object?> args, [Scope? thisScope, ValueType? thisType]) {
          return SydList(args.expand((element) => (element as SydArray).array).toList(), ListValueType(anythingType, 'intrinsics', this, rootTypeTable));
        },
        FunctionValueType(
            ListValueType(anythingType, 'intrinsics', this, rootTypeTable),
            InfiniteIterable(ArrayValueType(ValueType.create(whateverVariable, -2, 0, 'intrinsics', this, rootTypeTable), 'intrinsics', this, rootTypeTable)),
            'intrinsics',
            this,
            rootTypeTable),
        'addLists intrinsic',
      ),
      'parseInt': SydFunction(
        (List<Object?> args, [Scope? thisScope, ValueType? thisType]) {
          return int.parse(args.single as String);
        },
        FunctionValueType(integerType, [stringType], 'intrinsics', this, rootTypeTable),
        'parseInt intrinsic',
      ),
      'split': SydFunction(
        (List<Object?> args, [Scope? thisScope, ValueType? thisType]) {
          if (args.first == '') {
            return SydList(
              [args.first],
              ListValueType(stringType, 'intrinsics', this, rootTypeTable),
            );
          }
          return SydList(
            (args.first as String)
                .split(
                  args.last as String,
                )
                .toList(),
            ListValueType(stringType, 'intrinsics', this, rootTypeTable),
          );
        },
        FunctionValueType(ListValueType(stringType, 'intrinsics', this, rootTypeTable), [stringType, stringType], 'intrinsics', this, rootTypeTable),
        'split intrinsic',
      ),
      'charsOf': SydFunction(
        (List<Object?> args, [Scope? thisScope, ValueType? thisType]) {
          return SydIterable(
            (args.single as String).characters,
            IterableValueType(stringType, 'intrinsics', this, rootTypeTable),
          );
        },
        FunctionValueType(IterableValueType<String>(stringType, 'intrinsics', this, rootTypeTable), [stringType], 'intrinsics', this, rootTypeTable),
        'charsOf intrinsic',
      ),
      'scalarValues': SydFunction(
        (List<Object?> args, [Scope? thisScope, ValueType? thisType]) {
          return SydIterable(
            (args.single as String).runes,
            IterableValueType(integerType, 'intrinsics', this, rootTypeTable),
          );
        },
        FunctionValueType(IterableValueType<int>(integerType, 'intrinsics', this, rootTypeTable), [stringType], 'intrinsics', this, rootTypeTable),
        'scalarValues intrinsic',
      ),
      'filledList': SydFunction(
        (List<Object?> args, [Scope? thisScope, ValueType? thisType]) {
          return SydList<Object?>(
              List.filled(args.first as int, args.last, growable: true), ListValueType<Object?>(anythingType, 'intrinsics', this, rootTypeTable));
        },
        FunctionValueType(ListValueType(ValueType.create(whateverVariable, -2, 0, 'intrinsics', this, rootTypeTable), 'intrinsics', this, rootTypeTable),
            [integerType, anythingType], 'intrinsics', this, rootTypeTable),
        'filledList intrinsic',
      ),
      'sizedList': SydFunction(
        (List<Object?> args, [Scope? thisScope, ValueType? thisType]) {
          return SydList<Object?>(
            List.filled(args.first as int, SydSentinel(this), growable: true),
            ListValueType<Object?>(anythingType, 'intrinsics', this, rootTypeTable),
          );
        },
        FunctionValueType(ListValueType(ValueType.create(whateverVariable, -2, 0, 'intrinsics', this, rootTypeTable), 'intrinsics', this, rootTypeTable),
            [integerType], 'intrinsics', this, rootTypeTable),
        'sizedList intrinsic',
      ),
      'len': SydFunction(
        (List<Object?> args, [Scope? thisScope, ValueType? thisType]) {
          stack.add(NotLazyString('len'));
          if (!getType(args.single, dummyVariableGroup, -2, 0, 'intrinsics', false).isSubtypeOf(
              IterableValueType(ValueType.create(whateverVariable, -2, 0, 'intrinsics', this, rootTypeTable), 'intrinsics', this, rootTypeTable))) {
            throw RuntimeSydException(
                'len() takes an iterable as its argument, not a ${getType(args.single, dummyVariableGroup, -2, 0, 'intrinsics', false)} ${stack.reversed.join('\n')}',
                dummyVariableGroup);
          }
          stack.removeLast();
          return (args.single as SydIterable).iterable.length;
        },
        FunctionValueType(
            integerType,
            [IterableValueType<Object?>(ValueType.create(whateverVariable, -2, 0, 'intrinsics', this, rootTypeTable), 'intrinsics', this, rootTypeTable)],
            'intrinsics',
            this,
            rootTypeTable),
        'len intrinsic',
      ),
      'input': SydFunction(
        (List<Object?> args, [Scope? thisScope, ValueType? thisType]) {
          return stdin.readLineSync();
        },
        FunctionValueType(stringType, [], 'intrinsics', this, rootTypeTable),
        'input intrinsic',
      ),
      'append': SydFunction(
        (List<Object?> args, [Scope? thisScope, ValueType? thisType]) {
          stack.add(NotLazyString('append'));
          if (!getType(args.last, dummyVariableGroup, -2, 0, 'intrinsics', false)
              .isSubtypeOf((getType(args.first, dummyVariableGroup, -2, 0, 'intrinsics', false) as ListValueType).genericParameter)) {
            throw RuntimeSydException(
                'You cannot append a ${getType(args.last, dummyVariableGroup, -2, 0, 'intrinsics', false)} to a ${getType(args.first, dummyVariableGroup, -2, 0, 'intrinsics', false)}!\n${stack.reversed.join('\n')}',
                dummyVariableGroup);
          }
          (args.first as SydList).list.add(args.last);
          stack.removeLast();
          return args.last;
        },
        FunctionValueType(
            anythingType,
            [ListValueType(ValueType.create(whateverVariable, -2, 0, 'intrinsics', this, rootTypeTable), 'intrinsics', this, rootTypeTable), anythingType],
            'intrinsics',
            this,
            rootTypeTable),
        'append intrinsic',
      ),
      'insert': SydFunction(
        (List<Object?> args, [Scope? thisScope, ValueType? thisType]) {
          stack.add(NotLazyString('insert'));
          if (!getType(args.last, dummyVariableGroup, -2, 0, 'intrinsics', false)
              .isSubtypeOf((getType(args.first, dummyVariableGroup, -2, 0, 'intrinsics', false) as ListValueType).genericParameter)) {
            throw RuntimeSydException(
                'You cannot insert a ${getType(args.last, dummyVariableGroup, -2, 0, 'intrinsics', false)} into a ${getType(args.first, dummyVariableGroup, -2, 0, 'intrinsics', false)}!\n${stack.reversed.join('\n')}',
                dummyVariableGroup);
          }
          (args.first as SydList).list.insert(args[1] as int, args.last);
          stack.removeLast();
          return args.last;
        },
        FunctionValueType(
          anythingType,
          [ListValueType(ValueType.create(whateverVariable, -2, 0, 'intrinsics', this, rootTypeTable), 'intrinsics', this, rootTypeTable), integerType, anythingType],
          'intrinsics',
          this,
          rootTypeTable,
        ),
        'insert intrinsic',
      ),
      'pop': SydFunction(
        (List<Object?> args, [Scope? thisScope, ValueType? thisType]) {
          SydList list = args.first as SydList;
          if (list.list.isEmpty) {
            throw RuntimeSydException('Cannot pop from an empty list!\n${stack.reversed.join('\n')}', dummyVariableGroup);
          }
          return list.list.removeLast();
        },
        FunctionValueType(
            anythingType,
            [ListValueType(ValueType.create(whateverVariable, -2, 0, 'intrinsics', this, rootTypeTable), 'intrinsics', this, rootTypeTable)],
            'intrinsics',
            this,
            rootTypeTable),
        'pop intrinsic',
      ),
      'removeAt': SydFunction(
        (List<Object?> args, [Scope? thisScope, ValueType? thisType]) {
          SydList list = args.first as SydList;
          if (list.list.isEmpty) {
            throw RuntimeSydException('Cannot remove from an empty list!\n${stack.reversed.join('\n')}', dummyVariableGroup);
          }
          return list.list.removeAt(args.last as int);
        },
        FunctionValueType(
            anythingType,
            [ListValueType(ValueType.create(whateverVariable, -2, 0, 'intrinsics', this, rootTypeTable), 'intrinsics', this, rootTypeTable), integerType],
            'intrinsics',
            this,
            rootTypeTable),
        'pop intrinsic',
      ),
      'iterator': SydFunction(
        (List<Object?> args, [Scope? thisScope, ValueType? thisType]) {
          return SydIterator((args.single as SydIterable).iterable.iterator,
              IteratorValueType(elementTypeOf((args.single as SydIterable).type), 'intrinsics', this, rootTypeTable));
        },
        FunctionValueType(
            IteratorValueType(anythingType, 'intrinsics', this, rootTypeTable),
            [IterableValueType<Object?>(ValueType.create(whateverVariable, -2, 0, 'intrinsics', this, rootTypeTable), 'intrinsics', this, rootTypeTable)],
            'intrinsics',
            this,
            rootTypeTable),
        'iterator intrinsic',
      ),
      'next': SydFunction(
        (List<Object?> args, [Scope? thisScope, ValueType? thisType]) {
          return (args.single as SydIterator).iterator.moveNext();
        },
        FunctionValueType(booleanType, [IteratorValueType(anythingType, 'intrinsics', this, rootTypeTable)], 'intrinsics', this, rootTypeTable),
        'next intrinsic',
      ),
      'current': SydFunction(
        (List<Object?> args, [Scope? thisScope, ValueType? thisType]) {
          return (args.single as SydIterator).iterator.current;
        },
        FunctionValueType(anythingType, [IteratorValueType(anythingType, 'intrinsics', this, rootTypeTable)], 'intrinsics', this, rootTypeTable),
        'current intrinsic',
      ),
      'stringTimes': SydFunction(
        (List<Object?> args, [Scope? thisScope, ValueType? thisType]) {
          return (args.first as String) * (args.last as int);
        },
        FunctionValueType(stringType, [stringType, integerType], 'intrinsics', this, rootTypeTable),
        'stringTimes intrinsic',
      ),
      'copy': SydFunction(
        (List<Object?> args, [Scope? thisScope, ValueType? thisType]) {
          return SydList(
            (args.single as SydIterable).iterable.toList(),
            ListValueType<Object?>(elementTypeOf((args.single as SydIterable).type), 'intrinsics', this, rootTypeTable),
          );
        },
        FunctionValueType(
            ListValueType(ValueType.create(whateverVariable, -2, 0, 'intrinsics', this, rootTypeTable), 'intrinsics', this, rootTypeTable),
            [IterableValueType<Object?>(ValueType.create(whateverVariable, -2, 0, 'intrinsics', this, rootTypeTable), 'intrinsics', this, rootTypeTable)],
            'intrinsics',
            this,
            rootTypeTable),
        'copy intrinsic',
      ),
      'clear': SydFunction(
        (List<Object?> args, [Scope? thisScope, ValueType? thisType]) {
          (args.single as SydList).list.clear();
          return 0;
        },
        FunctionValueType(
            integerType,
            [ListValueType(ValueType.create(whateverVariable, -2, 0, 'intrinsics', this, rootTypeTable), 'intrinsics', this, rootTypeTable)],
            'intrinsics',
            this,
            rootTypeTable),
        'clear intrinsic',
      ),
      'hex': SydFunction(
        (List<Object?> args, [Scope? thisScope, ValueType? thisType]) {
          return (args.single as int).toRadixString(16);
        },
        FunctionValueType(stringType, [integerType], 'intrinsics', this, rootTypeTable),
        'hex intrinsic',
      ),
      'chr': SydFunction(
        (List<Object?> args, [Scope? thisScope, ValueType? thisType]) {
          return String.fromCharCode(args.single as int);
        },
        FunctionValueType(stringType, [integerType], 'intrinsics', this, rootTypeTable),
        'chr intrinsic',
      ),
      'exit': SydFunction(
        (List<Object?> args, [Scope? thisScope, ValueType? thisType]) {
          exit(args.single as int);
        },
        FunctionValueType(nullType, [integerType], 'intrinsics', this, rootTypeTable),
        'exit intrinsic',
      ),
      'fileExists': SydFunction(
        (List<Object?> args, [Scope? thisScope, ValueType? thisType]) {
          File file = File(args.single as String);
          return file.existsSync();
        },
        FunctionValueType(booleanType, [stringType], 'intrinsics', this, rootTypeTable),
        'fileExists intrinsic',
      ),
      'openFile': SydFunction(
        (List<Object?> args, [Scope? thisScope, ValueType? thisType]) {
          File file = File('${args.first}');
          FileMode mode = switch (args.last as int) {
            0 => FileMode.read,
            1 => FileMode.writeOnly,
            2 => FileMode.writeOnlyAppend,
            int x => throw RuntimeSydException(
                'openFile mode $x is not a valid mode\n${stack.reversed.join('\n')}',
                StringVariableGroup(
                  '$file',
                  this,
                )),
          };
          return SydFile(file.openSync(mode: mode), mode == FileMode.writeOnlyAppend, fileType);
        },
        FunctionValueType(fileType, [stringType, integerType], 'intrinsics', this, rootTypeTable),
        'openFile intrinsic',
      ),
      'fileModeRead': 0,
      'fileModeWrite': 1,
      'fileModeAppend': 2,
      'readFileBytes': SydFunction(
        (List<Object?> args, [Scope? thisScope, ValueType? thisType]) {
          try {
            SydFile file = args.single as SydFile;
            int length = file.file.lengthSync();
            if (file.used) {
              throw RuntimeSydException('${file.file.path} was read twice ${stack.reversed.join('\n')}', dummyVariableGroup);
            }
            file.used = true;
            return SydArray(
              file.file.readSync(length),
              ArrayValueType<int>(integerType, 'interr', this, rootTypeTable),
            );
          } catch (e) {
            rethrow;
          }
        },
        FunctionValueType(ArrayValueType<int>(integerType, 'intrinsics', this, rootTypeTable), [fileType], 'intrinsics', this, rootTypeTable),
        'readFileBytes intrinsic',
      ),
      'writeFileBytes': SydFunction(
        (List<Object?> args, [Scope? thisScope, ValueType? thisType]) {
          try {
            SydFile file = args.first as SydFile;
            if (file.used && !file.appendMode) {
              throw RuntimeSydException('${file.file.path} was written to twice ${stack.reversed.join('\n')}', dummyVariableGroup);
            }
            file.file.writeFromSync((args.last as SydArray).array as List<int>);
            file.used = true;
            return null;
          } catch (e) {
            rethrow;
          }
        },
        FunctionValueType(nullType, [fileType, ArrayValueType<int>(integerType, 'intrinsics', this, rootTypeTable)], 'intrinsics', this, rootTypeTable),
        'writeFileBytes intrinsic',
      ),
      'closeFile': SydFunction(
        (List<Object?> args, [Scope? thisScope, ValueType? thisType]) {
          try {
            SydFile file = args.single as SydFile;
            file.file.closeSync();
            return null;
          } catch (e) {
            rethrow;
          }
        },
        FunctionValueType(nullType, [fileType], 'intrinsics', this, rootTypeTable),
        'closeFile intrinsic',
      ),
      'deleteFile': SydFunction(
        (List<Object?> args, [Scope? thisScope, ValueType? thisType]) {
          File file = File(args.single as String);
          file.deleteSync();
          return null;
        },
        FunctionValueType(nullType, [stringType], 'intrinsics', this, rootTypeTable),
        'deleteFile intrinsic',
      ),
      'utf8Decode': SydFunction(
        (List<Object?> args, [Scope? thisScope, ValueType? thisType]) {
          try {
            SydArray<Object?> input = args.single as SydArray<Object?>;
            return utf8.decode(input.array.cast(), allowMalformed: true);
          } catch (e) {
            throw RuntimeSydException(
                'error $e when decoding utf8 ${toStringWithStacker(args.single, -2, 0, 'file', false)}\n${stack.reversed.join('\n')}', dummyVariableGroup);
          }
        },
        FunctionValueType(stringType, [ArrayValueType(integerType, 'intrinsics', this, rootTypeTable)], 'intrinsics', this, rootTypeTable),
        'utf8Decode intrinsic',
      ),
      'utf8Encode': SydFunction(
        (List<Object?> args, [Scope? thisScope, ValueType? thisType]) {
          try {
            return SydArray<int>(utf8.encode(args.single as String), ArrayValueType(integerType, 'intrinsics', this, rootTypeTable));
          } catch (e) {
            throw RuntimeSydException(
                'error $e when encoding utf8 ${toStringWithStacker(args.single, -2, 0, 'file', false)}\n${stack.reversed.join('\n')}', dummyVariableGroup);
          }
        },
        FunctionValueType(IterableValueType(integerType, 'intrinsics', this, rootTypeTable), [stringType], 'intrinsics', this, rootTypeTable),
        'utf8Decode intrinsic',
      ),
      'throw': SydFunction(
        (List<Object?> args, [Scope? thisScope, ValueType? thisType]) {
          if (args.length > 1) {
            throw SydException((args.first as String) + '\nstack:\n' + stack.reversed.join('\n'), args.last as int, dummyVariableGroup);
          }
          throw ThrowException((args.single as String) + '\nstack:\n' + stack.reversed.join('\n'), dummyVariableGroup);
        },
        FunctionValueType(nullType, [stringType], 'intrinsics', this, rootTypeTable),
        'throw intrinsic',
      ),
      'substring': SydFunction(
        (List<Object?> args, [Scope? thisScope, ValueType? thisType]) {
          stack.add(NotLazyString('substring'));
          if (args[1] as int > (args[2] as int)) {
            throw RuntimeSydException(
                'Cannot substring when the start (${args[1]}) is more than the end (${args[2]})!\n${stack.reversed.join('\n')}', dummyVariableGroup);
          }
          if (args[1] as int < 0) {
            throw RuntimeSydException('Cannot substring when the start (${args[1]}) is less than 0!\n${stack.reversed.join('\n')}', dummyVariableGroup);
          }
          if (args[2] as int > (args[0] as String).length) {
            throw RuntimeSydException('Cannot substring when the end (${args[2]}) is more than the length of the string (${args[1]})!\n${stack.reversed.join('\n')}',
                dummyVariableGroup);
          }
          stack.removeLast();
          return (args[0] as String).substring(args[1] as int, args[2] as int);
        },
        FunctionValueType(stringType, [stringType, integerType, integerType], 'intrinsics', this, rootTypeTable),
        'substring intrinsic',
      ),
      'sublist': SydFunction(
        (List<Object?> args, [Scope? thisScope, ValueType? thisType]) {
          stack.add(NotLazyString('substring'));
          if (args[2] as int < (args[1] as int)) {
            throw RuntimeSydException('sublist called with ${args[2]} (end arg) < ${args[1]} (start arg) ${stack.reversed.join('\n')}', dummyVariableGroup);
          }
          SydList result = SydList(
            (args[0] as SydArray<Object?>).array.sublist(args[1] as int, args[2] as int),
            getType(args.first, dummyVariableGroup, -2, 0, 'intrinsics', true) as ValueType<SydList>,
          );

          stack.removeLast();
          return result;
        },
        FunctionValueType(
            ListValueType(ValueType.create(whateverVariable, -2, 0, 'intrinsics', this, rootTypeTable), 'intrinsics', this, rootTypeTable),
            [
              ArrayValueType(ValueType.create(whateverVariable, -2, 0, 'intrinsics', this, rootTypeTable), 'intrinsics', this, rootTypeTable),
              integerType,
              integerType
            ],
            'intrinsics',
            this,
            rootTypeTable),
        'sublist intrinsic',
      ),
      'stackTrace': SydFunction(
        (List<Object?> args, [Scope? thisScope, ValueType? thisType]) {
          return stack.reversed.join('\n');
        },
        FunctionValueType(stringType, [], 'intrinsics', this, rootTypeTable),
        'stackTrace intrinsic',
      ),
      'containsString': SydFunction(
        (List<Object?> args, [Scope? thisScope, ValueType? thisType]) {
          return (args.first as String).contains(args.last as String);
        },
        FunctionValueType(booleanType, [stringType, stringType], 'intrinsics', this, rootTypeTable),
        'containsString intrinsic',
      ),
      'debugName': SydFunction(
        (List<Object?> args, [Scope? thisScope, ValueType? thisType]) {
          return (args.single as Scope).debugName;
        },
        FunctionValueType(stringType, [rootClassType], 'intrinsics', this, rootTypeTable),
        'debugName intrinsic',
      ),
      'createStringBuffer': SydFunction(
        (List<Object?> args, [Scope? thisScope, ValueType? thisType]) {
          return StringBuffer();
        },
        FunctionValueType(stringBufferType, [], 'intrinsics', this, rootTypeTable),
        'createStringBuffer intrinsic',
      ),
      'writeStringBuffer': SydFunction(
        (List<Object?> args, [Scope? thisScope, ValueType? thisType]) {
          StringBuffer buffer = args.first as StringBuffer;
          buffer.write(args.last);
          return null;
        },
        FunctionValueType(nullType, [stringBufferType, stringType], 'intrinsics', this, rootTypeTable),
        'writeStringBuffer intrinsic',
      ),
      'readStringBuffer': SydFunction(
        (List<Object?> args, [Scope? thisScope, ValueType? thisType]) {
          StringBuffer buffer = args.first as StringBuffer;
          return buffer.toString();
        },
        FunctionValueType(stringType, [stringBufferType], 'intrinsics', this, rootTypeTable),
        'readStringBuffer intrinsic',
      ),
      'startTimer': SydFunction(
        (List<Object?> args, [Scope? thisScope, ValueType? thisType]) {
          return Stopwatch()..start();
        },
        FunctionValueType(timerType, [], 'intrinsics', this, rootTypeTable),
        'startTime intrinsic',
      ),
      'timerElapsed': SydFunction(
        (List<Object?> args, [Scope? thisScope, ValueType? thisType]) {
          return (args.first as Stopwatch).elapsed.inMilliseconds;
        },
        FunctionValueType(integerType, [timerType], 'intrinsics', this, rootTypeTable),
        'timeElapsed intrinsic',
      ),
    };
  }
}

class TVProp {
  final bool isFwd;
  final ValueType type;
  final bool validForSuper;
  final int index;

  TVProp(this.isFwd, this.type, this.validForSuper, this.index);

  ValueType? notFwd() {
    return isFwd ? null : type;
  }

  String toString() {
    return '<$type / ${isFwd ? '1' : '0'}${validForSuper ? '1' : '0'}>';
  }
}

sealed class VariableGroup {
  String dump();

  Environment get environment;
}

class StringVariableGroup extends VariableGroup {
  final String value;

  StringVariableGroup(this.value, this.environment);
  final Environment environment;

  @override
  String dump() {
    return value;
  }
}

class NoDataVG extends VariableGroup {
  final Environment environment;

  NoDataVG(this.environment);
  @override
  String dump() {
    return '<no data available>';
  }
}

class TypeValidator extends VariableGroup {
  static int currentId = 0;
  late int id = currentId++;
  final LazyString debugName;
  late bool inClass; // whether this scope is inside a class
  late bool inStaticClass; // whether this scope is inside a static class
  final bool globalScope;
  ValueType? returnType;
  final bool isStaticMethod;
  final bool isLoop;
  final bool isFunction;
  TypeValidator get intrinsics => parents.isEmpty ? this : parents.first.intrinsics;
  final MapEntry<List<Statement>, TypeValidator>? rtl;
  final Map<String, Identifier> identifiers;
  final Environment environment;
  late final TypeTable typeTable;

  bool get indirectlyStaticMethod {
    if (isStaticMethod) {
      return true;
    }
    return parents.any((e) => e.indirectlyStaticMethod);
  }

  bool get inLoop => isLoop || !isFunction && parents.any((element) => element.inLoop);

  String toString() => "$debugName";

  TypeValidator(
      this.parents, this.debugName, this.inClass, this.inStaticClass, this.isStaticMethod, this.rtl, this.identifiers, this.environment, this.globalScope, this.isLoop, this.isFunction,
      [TypeTable? table]) {
    if (parents.any((element) => element.inClass)) inClass = true;
    if (parents.any((element) => element.inStaticClass)) inStaticClass = true;
    returnType = parents.where((element) => element.returnType != null).firstOrNull?.returnType;
    typeTable = table ?? parents.first.typeTable;
  }
  final List<TypeValidator> parents;
  Map<Identifier, TypeValidator> classes = {};
  List<Identifier> nonconst = [];
  ValueType get currentClassType =>
      currentClassScope?.igv(thisVariable, true, -2, 0, 'thisshouldnotmatter', true, false) ??
      (throw ("Super called outside class (stack trace is dart stack trace, not syd stack trace)"));
  TypeValidator? get currentClassScope {
    if (inClass) {
      return this;
    }
    return (parents.cast<TypeValidator?>()).firstWhere((element) => element!.currentClassScope != null, orElse: () => null)?.currentClassScope!;
  }

  Map<Identifier, TVProp> types = {};

  List<Identifier> directVars = standardDirectVars.toList();
  static final List<Identifier> standardDirectVars = [Identifier('true'), Identifier('false'), Identifier('null')];

  Set<Identifier> usedVars = {};

  void setVar(Expression expression, ValueType value, int line, int col, String file) {
    if (!expression.isLValue(this)) {
      throw CompileTimeSydException(
        "Attempted to set non-lvalue $expression to expr of type $value ${formatCursorPosition(line, col, file)}",
        this,
      );
    }
    if (!value.isSubtypeOf(expression.staticType)) {
      throw CompileTimeSydException(
        "Attempted to set $expression to expr of type $value but expected ${expression.staticType} ${formatCursorPosition(line, col, file)}",
        this,
      );
    }
  }

  int currentIndex = 0;

  void newVar(
    Identifier name,
    ValueType type,
    int line,
    int col,
    String file, [
    bool constant = false,
    bool isFwd = false,
    bool validForSuper = false,
  ]) {
    if (directVars.contains(name)) {
      throw CompileTimeSydException(
        'Attempted redeclare of existing variable ${name.name} ${formatCursorPosition(line, col, file)}',
        this,
      );
    }
    if (types.containsKey(name) && nonconst.contains(name) && constant) {
      throw CompileTimeSydException(
          'Cannot override non-constant variable ${name.name} with constant variable ${types[name]} ${nonconst.map((e) => e.name)} $this ${formatCursorPosition(line, col, file)}',
          this);
    }
    types[name] = TVProp(
      isFwd,
      type,
      validForSuper,
      currentIndex++,
    );
    directVars.add(name);
    if (!constant) {
      nonconst.add(name);
    }
  }

  ValueType getVar(Identifier expr, int line, int col, String file, String context) {
    ValueType? realtype = igv(expr, true, line, col, file);
    if (realtype == null) {
      List<String> filenamesList = [];
      for (MapEntry<String, TypeValidator> e in environment.loadedGlobalScopes.entries) {
        if (e.value.igv(expr, true, line, col, file) != null) {
          filenamesList.add(e.key);
        }
      }
      String filenames;
      switch (filenamesList.length) {
        case 0:
          filenames = '';
          break;
        case 1:
          filenames = filenamesList.first;
          break;
        default:
          filenames = filenamesList.sublist(0, filenamesList.length - 1).join(', ') + ' or ' + filenamesList.last;
      }
      ValueType? type = ValueType.createNullable(
        expr,
        file,
        environment,
        typeTable,
      );
      throw CompileTimeSydException(
        "Attempted to retrieve ${expr.name}, which is undefined.  ${filenames.isEmpty ? '' : '(maybe you meant to import $filenames?) '}${type == null ? '' : '(that\'s a type, in case it helps) '}${formatCursorPosition(line, col, file)}",
        this,
      );
    }
    return realtype;
  }

  ValueType? igv(Identifier name, bool addToUsedVars,
      [int debugLine = -2,
      int debugCol = 0,
      String debugFile = '',
      bool checkParent = true,
      bool escapeClass = true,
      bool acceptFwd = true,
      bool forSuper = false]) {
    assert(!checkParent || escapeClass || inClass || inStaticClass, '${this.debugName}');
    if (addToUsedVars && !usedVars.contains(name)) {
      usedVars.add(name);
    }
    assert(!parents.contains(this));
    TVProp? result = types[name];
    if (!acceptFwd && result != null && result.isFwd) {
      result = null;
    }
    if (forSuper && result != null && !result.validForSuper) {
      result = null;
    }
    if (result != null) return result.type;
    if (!checkParent) return null;
    for (TypeValidator parent in parents.reversed) {
      if (!escapeClass && !parent.inClass && !parent.inStaticClass) {
        continue;
      }
      ValueType? result = parent.igv(name, addToUsedVars, debugLine, debugCol, debugFile, checkParent, escapeClass, acceptFwd);
      if (result != null) return result;
    }
    return null;
  }

  List<int> findPathFor(Identifier name) {
    assert(igv(name, false) != null);
    List<int> result = [];
    TypeValidator currentScope = this;
    while (!currentScope.types.containsKey(name)) {
      int index = currentScope.parents.indexWhere((element) => element.igv(name, false) != null);
      if (index == -1) {
        throw StateError('${name.name} in ${currentScope.debugName} but not in any parent ${currentScope.types.keys.map((e) => e.name)}');
      }
      currentScope = currentScope.parents[index];
      //print(currentScope);
      result.add(index);
    }
    if (currentScope.inClass && currentScope.parents.every((element) => !element.inClass)) {
      return const [-1];
    }
    result.add(currentScope.types[name]!.index);
    if (currentScope.globalScope) {
      return const [-2];
    }
    return result;
  }

  TypeValidator followPathToScope(List<int> path) {
    TypeValidator currentScope = this;
    int index = 0;
    while (index < path.length - 1) {
      currentScope = currentScope.parents[path[index]];
      index += 1;
    }
    return currentScope;
  }

  bool igvnc(Identifier name) {
    return nonconst.contains(name) || !types.containsKey(name) && parents.map((e) => e.igvnc(name)).firstWhere((e) => e, orElse: () => false);
  }

  TypeValidator copy() {
    return TypeValidator(parents.toList(), ConcatenateLazyString(debugName, NotLazyString(' copy')), inClass, inStaticClass, isStaticMethod, rtl, identifiers,
        environment, globalScope, isLoop, isFunction)
      ..nonconst = nonconst.toList()
      ..types = types.map((key, value) => MapEntry(key, value));
  }

  @override
  String dump() {
    return dumpIndent(0);
  }

  String dumpIndent(int indent) {
    StringBuffer buffer = StringBuffer();
    buffer.write("${' ' * indent}$debugName");
    buffer.write("\n${' ' * (indent + 2)}isClass: $inClass");
    buffer.write("\n${' ' * (indent + 2)}isClassOf: $inStaticClass");
    buffer.write("\n${' ' * (indent + 2)}isStaticMethod: $isStaticMethod");
    buffer.write(
      "${types.entries.map((kv) => '\n${' ' * (indent + 2)}${kv.key.name}: ${kv.value.type}\n${' ' * (indent + 4)}nonconst: ${nonconst.contains(kv.key)}\n${' ' * (indent + 4)}direct: ${directVars.contains(kv.key)}\n${' ' * (indent + 4)}used: ${usedVars.contains(kv.key)}\n${' ' * (indent + 4)}fwd-declared: ${kv.value.isFwd}').join('')}",
    );
    buffer.write("\n${' ' * (indent + 2)}parents: ${parents.map((e) => '\n${e.dumpIndent(indent + 4)}').join('')}");
    return buffer.toString();
  }
}

class Scope extends VariableGroup implements TypedValue<Scope> {
  final bool? profileMode;
  final bool? debugMode;
  final Map<String, Identifier> identifiers;
  final Environment environment;
  ValueType<Scope> get type => typeIfClass!;

  Scope(
    this.isClass,
    this.isStaticClass,
    this.rtl,
    this.environment, {
    required this.intrinsics,
    Scope? parent,
    this.declaringClass,
    required this.debugName,
    this.typeIfClass,
    this.staticClassName,
    this.profileMode,
    this.debugMode,
    required this.identifiers,
  }) : parents = [if (parent != null) parent];
  final LazyString debugName;
  final List<Scope> parents;
  final Scope? intrinsics;
  final Scope? rtl;
  final bool isStaticClass;
  final String? staticClassName;
  final ClassValueType? declaringClass;
  final bool isClass;
  final ClassValueType? typeIfClass;

  ClassValueType? get currentClass {
    if (declaringClass == null && !isClass) {
      if (parents.isEmpty) {
        return null;
      }
      return parents.where((element) => element.currentClass != null).firstOrNull?.currentClass;
    }
    return declaringClass ?? typeIfClass!;
  }

  Scope? get currentStaticClass {
    Scope node = this;
    while (!node.isStaticClass) {
      if (node.parents.isEmpty) {
        return null;
      }
      node = node.parents.first;
    }
    return node;
  }

  Scope? get currentClassScope {
    Scope node = this;
    while (!node.isClass) {
      if (node.parents.isEmpty) {
        return null;
      }
      node = node.parents.first;
    }
    return node;
  }

  String toString() {
    throw "called Scope.toString()";
  }

  String toStringWithStack(int line, int col, String file, bool rethrowErrors) {
    try {
      if (!directlyContains(identifiers['toString']!)) {
        return '<$debugName>';
      }
      return (getVarByName(identifiers['toString']!) as SydFunction<Object?>).function([]) as String;
    } on SydException {
      if (rethrowErrors) rethrow;
      return '<$debugName>';
    }
  }

  final Map<Identifier, int> _valueIndicies = HashMap();

  final List<Object?> _values = [];

  bool directlyContains(Identifier name) {
    return _valueIndicies.containsKey(name);
  }

  void newVar(Identifier name, Object? value) {
    _valueIndicies[name] = _values.length;
    _values.add(value);
    if (environment.globals[name] == null) {
      environment.globals[name] = value;
    }
  }

  void writeTo(Identifier name, List<int> path, Object? value) {
    Scope currentScope = this;
    int index = 0;
    while (index < path.length - 1) {
      currentScope = currentScope.parents[path[index]];
      index += 1;
    }
    currentScope._values[path[index]] = value;
  }

  void writeToByName(Identifier name, Object? value) {
    _values[_valueIndicies[name]!] = value;
  }

  Object? getVar(List<int> path) {
    Scope currentScope = this;
    int index = 0;
    while (index < path.length - 1) {
      currentScope = currentScope.parents[path[index]];
      index += 1;
    }
    return currentScope._values[path[index]];
  }

  Object? getVarByName(Identifier name) {
    assert(_valueIndicies.containsKey(name), '${name.name} not found: ${_valueIndicies.keys.map((e) => e.name)}');
    return _values[_valueIndicies[name]!];
  }

  void addParent(Scope scope) {
    parents.add(scope);
  }

  Scope? getClass() {
    Scope node = this;
    while (!node.isClass) {
      if (node.parents.isEmpty) {
        return null;
      }
      node = node.parents.first;
    }
    return node;
  }

  @override
  String dump() {
    return dumpIndent(0);
  }

  String dumpIndent(int indent) {
    StringBuffer buffer = StringBuffer();
    buffer.write("${' ' * indent}$debugName");
    buffer.write("\n${' ' * (indent + 2)}isClass: $isClass");
    buffer.write("\n${' ' * (indent + 2)}isStaticClass: $isStaticClass");
    buffer.write("\n${' ' * (indent + 2)}staticClassName: $staticClassName");
    buffer.write("\n${' ' * (indent + 2)}declaringClass: $declaringClass");
    buffer.write("\n${' ' * (indent + 2)}typeIfClass: $typeIfClass");
    for (Identifier name in _valueIndicies.keys) {
      buffer.write(
          '\n${' ' * (indent + 2)}${name.name}: ${toStringWithStacker(getVarByName(name), -2, 0, 'internal', false)} (type: ${getType(getVarByName(name), this, -2, 0, 'internal', false)})');
    }
    buffer.write("\n${' ' * (indent + 2)}parents: ${parents.map((e) => '\n${e.dumpIndent(indent + 4)}').join('')}");
    return buffer.toString();
  }
}

ValueType getType(Object? value, VariableGroup scope, int line, int col, String file, bool checkForSentinel) {
  switch (value) {
    case bool():
      return scope.environment.booleanType;
    case int():
      return scope.environment.integerType;
    case Null():
      return scope.environment.nullType;
    case String():
      return scope.environment.stringType;
    case StringBuffer():
      return scope.environment.stringBufferType;
    case Stopwatch():
      return scope.environment.timerType;
    case SydSentinel(type: ValueType type):
      if (!checkForSentinel) return type;
      throw RuntimeSydException('Tried to access uninitalized value ${formatCursorPosition(line, col, file)} ${scope.environment.stack.reversed.join('\n')}', scope);
    case TypedValue(type: ValueType type):
      return type;
    default:
      throw ('unknown value ${value.runtimeType}');
  }
}

class ValueType<T extends Object?> {
  final ValueType? parent;
  final Identifier name;

  late int id = environment.currentTypeId++;

  bool memberAccesible() {
    // whether this is a valid reciever for member access
    return _memberAccesible;
  }

  final bool _memberAccesible;

  String toString() => name.name;
  bool operator ==(x) => x is ValueType && this.isSubtypeOf(x) && x.isSubtypeOf(this);
  final Environment environment;

  ValueType.internal(this.parent, this.name, String file, this._memberAccesible, this.environment, TypeTable typeTable) {
    if (typeTable[name] != null) {
      throw CompileTimeSydException("Repeated creation of ${name.name} (file $file)", StringVariableGroup(StackTrace.current.toString(), environment));
    }
    typeTable[name] = this;
    environment.allTypes.add(this);
    assert(environment.subtypeTable.length == id);
    environment.subtypeTable.add(BoolList(id + 1, growable: true));
    for (ValueType type in environment.allTypes) {
      environment.subtypeTable[id][type.id] = internal_isSubtypeOf(type);
      if (type.id == id) continue;
      assert(id == environment.subtypeTable[type.id].length);
      environment.subtypeTable[type.id].add(type.internal_isSubtypeOf(this));
    }
  }

  static ValueType create(Identifier name, int line, int col, String file, Environment environment, TypeTable typeTable) {
    return createNullable(name, file, environment, typeTable) ??
        (throw CompileTimeSydException(
            "'${name.name}' type doesn't exist ${formatCursorPosition(line, col, file)}", StringVariableGroup(StackTrace.current.toString(), environment)));
  }

  static bool hasTypeSuffix(Identifier name) {
    return name.name.endsWith("Class") ||
        name.name.endsWith("Iterable") ||
        name.name.endsWith("Iterator") ||
        name.name.endsWith('List') ||
        name.name.endsWith('Array') ||
        name.name.endsWith("Function") ||
        name.name.endsWith("Nullable");
  }

  static ValueType? createNullable(Identifier name, String file, Environment environment, TypeTable typeTable) {
    if (typeTable[name] != null) return typeTable[name];
    if (name.name.endsWith("Class")) {
      return null;
    }
    if (name.name.endsWith("Iterable")) {
      var iterableOrNull = ValueType.createNullable(
        environment.identifiers[name.name.substring(0, name.name.length - 8)] ??= Identifier(name.name.substring(0, name.name.length - 8)),
        file,
        environment,
        typeTable,
      );
      if (iterableOrNull == null) return null;
      return IterableValueType<Object?>(
        iterableOrNull,
        file,
        environment,
        typeTable,
      );
    }
    if (name.name.endsWith("Iterator")) {
      var iteratorOrNull = ValueType.createNullable(
        environment.identifiers[name.name.substring(0, name.name.length - 8)] ??= Identifier(name.name.substring(0, name.name.length - 8)),
        file,
        environment,
        typeTable,
      );
      if (iteratorOrNull == null) return null;
      return IteratorValueType(
        iteratorOrNull,
        file,
        environment,
        typeTable,
      );
    }
    if (name.name.endsWith('List')) {
      var listOrNull = ValueType.createNullable(
        environment.identifiers[name.name.substring(0, name.name.length - 4)] ??= Identifier(name.name.substring(0, name.name.length - 4)),
        file,
        environment,
        typeTable,
      );
      if (listOrNull == null) return null;
      return ListValueType<Object?>(
        listOrNull,
        file,
        environment,
        typeTable,
      );
    }
    if (name.name.endsWith('Array')) {
      var arrayOrNull = ValueType.createNullable(
        environment.identifiers[name.name.substring(0, name.name.length - 5)] ??= Identifier(name.name.substring(0, name.name.length - 5)),
        file,
        environment,
        typeTable,
      );
      if (arrayOrNull == null) return null;
      return ArrayValueType(
        arrayOrNull,
        file,
        environment,
        typeTable,
      );
    }
    if (name.name.endsWith("Function")) {
      var functionOrNull = ValueType.createNullable(
        environment.identifiers[name.name.substring(0, name.name.length - 8)] ??= Identifier(name.name.substring(0, name.name.length - 8)),
        file,
        environment,
        typeTable,
      );
      if (functionOrNull == null) return null;
      return GenericFunctionValueType(
        functionOrNull,
        file,
        environment,
        typeTable,
      );
    }
    if (name.name.endsWith("Nullable")) {
      var nullableOrNull = ValueType.createNullable(
        environment.identifiers[name.name.substring(0, name.name.length - 8)] ??= Identifier(name.name.substring(0, name.name.length - 8)),
        file,
        environment,
        typeTable,
      );
      if (nullableOrNull == null) return null;
      if (nullableOrNull is NullableValueType ||
          nullableOrNull == environment.nullType ||
          nullableOrNull == environment.anythingType ||
          nullableOrNull.name == whateverVariable) {
        throw CompileTimeSydException("Type $nullableOrNull is already nullable, cannot make nullable version ${name.name}", NoDataVG(environment));
      }
      return NullableValueType<Object?>(
        nullableOrNull as ValueType<Object>,
        file,
        environment,
        typeTable,
      );
    }
    return basicTypes(name, file, environment, typeTable);
  }

  bool internal_isSubtypeOf(ValueType possibleParent) {
    return name == possibleParent.name ||
        (parent != null && parent!.internal_isSubtypeOf(possibleParent)) ||
        name == whateverVariable ||
        possibleParent.name == whateverVariable ||
        (possibleParent is NullableValueType && internal_isSubtypeOf(possibleParent.genericParam));
  }

  bool isSubtypeOf(ValueType possibleParent) {
    return environment.subtypeTable[id][possibleParent.id];
  }

  ValueType withReturnType(ValueType x, String file) {
    throw UnsupportedError("err");
  }
}

class ClassValueType extends ValueType<Scope> {
  final TypeTable typeTable;

  ClassValueType.internal(Identifier name, this.supertype, this.properties, String file, Environment environment, this.typeTable)
      : super.internal(supertype ?? environment.rootClassType, name, file, false, environment, typeTable);
  factory ClassValueType(
      Identifier name, ClassValueType? supertype, TypeValidator properties, String file, bool fwdDeclared, Environment environment, TypeTable typeTable) {
    if (typeTable[name] is! ClassValueType?) {
      throw CompileTimeSydException("Tried to make class named ${name.name} but that is an existing non-class type (file: $file)", properties);
    }
    ClassValueType classValueType =
        ((typeTable[name] ??= ClassValueType.internal(name, supertype, properties, file, environment, typeTable)) as ClassValueType);
    classValueType.forwardDeclared = classValueType.forwardDeclared || fwdDeclared;
    return classValueType..notFullyDeclared = fwdDeclared;
  }
  final TypeValidator properties;
  final ClassValueType? supertype;
  final List<ClassValueType> subtypes = [];
  Scope? methods;
  late final SydFunction fieldInitializer;
  Class? generatedConstructor;
  bool notFullyDeclared = true; // set to false at parsetime when the class is fully   declared
  bool forwardDeclared = false; // set to true  at parsetime when the class is forward declared

  @override
  bool memberAccesible() {
    return true;
  }

  Iterable<ClassValueType> get allDescendants => subtypes.expand((element) => element.allDescendants.followedBy([element]));
  MapEntry<ValueType, ClassValueType>? recursiveLookup(Identifier v) {
    return properties.igv(v, true, -2, 0, '446/parsercore', true, false) != null
        ? MapEntry(properties.igv(v, true, -2, 0, '446/parsercore', true, false)!, this)
        : supertype?.recursiveLookup(v);
  }
}

String toStringWithStacker(Object? x, int line, int col, String file, bool rethrowErrors) {
  if (x is Scope) {
    return x.toStringWithStack(line, col, file, rethrowErrors);
  } else if (x is SydIterable) {
    StringBuffer result = StringBuffer();
    if (x is SydArray) {
      result.write('[');
    } else {
      result.write('(');
    }
    result.write(x.iterable.map((e) => toStringWithStacker(e, line, col, file, rethrowErrors)).join(', '));
    if (x is SydArray) {
      result.write(']');
    } else {
      result.write(')');
    }
    return result.toString();
  } else if (x is Iterable) {
    throw StateError('don\'t pass iterables to toStringWithStacker');
  } else {
    return x.toString();
  }
}

class ClassOfValueType extends ValueType<Class> {
  final ClassValueType classType;
  final TypeValidator staticMembers;
  final GenericFunctionValueType constructor;

  bool internal_isSubtypeOf(ValueType possibleParent) {
    return super.internal_isSubtypeOf(possibleParent) || (possibleParent is ClassOfValueType && classType.internal_isSubtypeOf(possibleParent.classType));
  }

  factory ClassOfValueType(
      ClassValueType classType, TypeValidator staticMembers, GenericFunctionValueType constructor, String file, Environment environment, TypeTable typeTable) {
    if (classType.typeTable[environment.identifiers['${classType.name.name}Class'] ??= Identifier('${classType.name.name}Class')] != null) {
      return classType.typeTable[environment.identifiers['${classType.name.name}Class']!] as ClassOfValueType;
    }
    return ClassOfValueType.internal(classType, staticMembers, constructor, file, environment, typeTable);
  }

  ClassOfValueType.internal(this.classType, this.staticMembers, this.constructor, String /*super.*/ file, Environment environment, TypeTable typeTable)
      : super.internal(environment.anythingType, environment.identifiers['${classType.name.name}Class']!, file, false, environment, typeTable);

  @override
  bool memberAccesible() {
    return true;
  }
}

class EnumValueType extends ValueType<SydEnum> {
  final TypeValidator staticMembers;
  final EnumPropertyValueType propertyType;

  EnumValueType(Identifier name, this.staticMembers, String file, this.propertyType, Environment environment, TypeTable typeTable)
      : super.internal(
            environment.anythingType, environment.identifiers[name.name + 'Enum'] ??= Identifier(name.name + 'Enum'), file, false, environment, typeTable);

  @override
  bool memberAccesible() {
    return true;
  }
}

class EnumPropertyValueType extends ValueType<SydEnumValue> {
  EnumPropertyValueType(Identifier name, String file, Environment environment, TypeTable typeTable)
      : super.internal(environment.anythingType, name, file, false, environment, typeTable);
}

class NullValueType extends ValueType<Null> {
  NullValueType.internal(ValueType anythingType, Environment environment, TypeTable typeTable)
      : super.internal(environment.anythingType, environment.identifiers['Null'] ??= Identifier('Null'), 'interr', false, environment, typeTable);

  bool internal_isSubtypeOf(ValueType possibleParent) {
    return possibleParent is NullableValueType || super.internal_isSubtypeOf(possibleParent);
  }
}

ValueType? basicTypes(Identifier name, String file, Environment environment, TypeTable typeTable) {
  final Identifier? sentinel = environment.identifiers['~sentinel'];
  switch (name) {
    case whateverVariable:
      if (typeTable[name] != null) return typeTable[name];
      return ValueType.internal(environment.anythingType, name, file, name == whateverVariable, environment, typeTable);
    default:
      if (name == sentinel) {
        if (typeTable[name] != null) return typeTable[name];
        return ValueType.internal(environment.anythingType, name, file, name == whateverVariable, environment, typeTable);
      }
      return null;
  }
}

class NullableValueType<T> extends ValueType<T?> {
  final ValueType<T> genericParam;

  NullableValueType.internal(this.genericParam, String file, Environment environment, TypeTable typeTable)
      : super.internal(
            environment.anythingType,
            environment.identifiers[genericParam.name.name + 'Nullable'] ??= Identifier(genericParam.name.name + 'Nullable'),
            file,
            false,
            environment,
            typeTable);
  factory NullableValueType(ValueType<Object> genericParam, String file, Environment environment, TypeTable typeTable) {
    return (typeTable[environment.identifiers["${genericParam}Nullable"] ??= Identifier("${genericParam}Nullable")] ??=
        NullableValueType.internal(genericParam, file, environment, typeTable)) as NullableValueType<T>;
  }

  bool internal_isSubtypeOf(ValueType other) {
    return super.internal_isSubtypeOf(other) || (other is NullableValueType && genericParam.internal_isSubtypeOf(other.genericParam));
  }
}

class GenericFunctionValueType<T> extends ValueType<SydFunction<T>> {
  GenericFunctionValueType.internal(this.returnType, String file, Environment environment, this.typeTable)
      : super.internal(environment.anythingType, environment.identifiers["${returnType}Function"] ??= Identifier("${returnType}Function"), file, false,
            environment, typeTable);
  final ValueType returnType;
  final TypeTable typeTable;
  factory GenericFunctionValueType(ValueType returnType, String file, Environment environment, TypeTable typeTable) {
    return (typeTable[environment.identifiers["${returnType}Function"] ??= Identifier("${returnType}Function")] ??=
        GenericFunctionValueType<T>.internal(returnType, file, environment, typeTable)) as GenericFunctionValueType<T>;
  }
  @override
  bool internal_isSubtypeOf(final ValueType possibleParent) {
    return super.internal_isSubtypeOf(possibleParent) ||
        ((possibleParent is GenericFunctionValueType && (this is! FunctionValueType || possibleParent is! FunctionValueType)) &&
            returnType.internal_isSubtypeOf(possibleParent.returnType));
  }

  GenericFunctionValueType withReturnType(ValueType rt, String file) {
    return GenericFunctionValueType(rt, file, environment, typeTable);
  }
}

class IterableValueType<T> extends ValueType<SydIterable<T>> {
  IterableValueType.internal(this.genericParameter, String file, Environment environment, TypeTable typeTable)
      : super.internal(environment.anythingType, environment.identifiers["${genericParameter}Iterable"] ??= Identifier("${genericParameter}Iterable"), file,
            false, environment, typeTable);
  factory IterableValueType(ValueType<T> genericParameter, String file, Environment environment, TypeTable typeTable) {
    return typeTable[environment.identifiers["${genericParameter}Iterable"] ??= Identifier("${genericParameter}Iterable")] as IterableValueType<T>? ??
        IterableValueType<T>.internal(genericParameter, file, environment, typeTable);
  }
  final ValueType<T> genericParameter;
  @override
  bool internal_isSubtypeOf(ValueType possibleParent) {
    return super.internal_isSubtypeOf(possibleParent) ||
        (possibleParent is IterableValueType && genericParameter.internal_isSubtypeOf(possibleParent.genericParameter));
  }
}

class IteratorValueType<T> extends ValueType<SydIterator<T>> {
  IteratorValueType.internal(this.genericParameter, String file, Environment environment, TypeTable typeTable)
      : super.internal(environment.anythingType, environment.identifiers["${genericParameter}Iterator"] ??= Identifier("${genericParameter}Iterator"), file,
            false, environment, typeTable);
  factory IteratorValueType(ValueType<T> genericParameter, String file, Environment environment, TypeTable typeTable) {
    return typeTable[environment.identifiers["${genericParameter}Iterator"] ??= Identifier("${genericParameter}Iterator")] as IteratorValueType<T>? ??
        IteratorValueType<T>.internal(genericParameter, file, environment, typeTable);
  }
  final ValueType<T> genericParameter;
  @override
  bool internal_isSubtypeOf(ValueType possibleParent) {
    return super.internal_isSubtypeOf(possibleParent) ||
        (possibleParent is IteratorValueType && genericParameter.internal_isSubtypeOf(possibleParent.genericParameter));
  }
}

class ListValueType<T> extends ValueType<SydList<T>> {
  ListValueType.internal(this.genericParameter, String file, Environment environment, TypeTable typeTable)
      : name = environment.identifiers["${genericParameter}List"] ??= Identifier("${genericParameter}List"),
        super.internal(environment.anythingType, environment.identifiers["${genericParameter}List"] ??= Identifier("${genericParameter}List"), file, false,
            environment, typeTable);
  final Identifier name;
  factory ListValueType(ValueType<T> genericParameter, String file, Environment environment, TypeTable typeTable) {
    return typeTable[environment.identifiers["${genericParameter}List"] ??= Identifier("${genericParameter}List")] as ListValueType<T>? ??
        ListValueType<T>.internal(genericParameter, file, environment, typeTable);
  }
  final ValueType<T> genericParameter;
  @override
  bool internal_isSubtypeOf(ValueType possibleParent) {
    return name == possibleParent.name ||
        (parent != null && parent!.internal_isSubtypeOf(possibleParent)) ||
        (possibleParent is IterableValueType && genericParameter == possibleParent.genericParameter) ||
        (possibleParent is ArrayValueType && genericParameter == possibleParent.genericParameter) ||
        (possibleParent is ListValueType && genericParameter == possibleParent.genericParameter) ||
        (possibleParent is NullableValueType && internal_isSubtypeOf(possibleParent.genericParam));
  }
}

class ArrayValueType<T> extends ValueType<SydList<T>> {
  ArrayValueType.internal(this.genericParameter, String file, Environment environment, TypeTable typeTable)
      : super.internal(environment.anythingType, environment.identifiers["${genericParameter}Array"] ??= Identifier("${genericParameter}Array"), file, false,
            environment, typeTable);
  late Identifier name = environment.identifiers["${genericParameter}Array"] ??= Identifier("${genericParameter}Array");
  factory ArrayValueType(ValueType genericParameter, String file, Environment environment, TypeTable typeTable) {
    return typeTable[environment.identifiers["${genericParameter}Array"] ??= Identifier("${genericParameter}Array")] as ArrayValueType<T>? ??
        ArrayValueType<T>.internal(genericParameter, file, environment, typeTable);
  }
  final ValueType genericParameter;
  @override
  bool internal_isSubtypeOf(ValueType possibleParent) {
    return name == possibleParent.name ||
        (parent != null && parent!.internal_isSubtypeOf(possibleParent)) ||
        (possibleParent is IterableValueType && genericParameter == possibleParent.genericParameter) ||
        (possibleParent is ArrayValueType && genericParameter == possibleParent.genericParameter) ||
        (possibleParent is NullableValueType && internal_isSubtypeOf(possibleParent.genericParam));
  }
}

class FunctionValueType<T extends Object?> extends GenericFunctionValueType<T> {
  Iterable<ValueType> parameters;
  ValueType returnType;
  late final String stringParams = parameters.toString();
  late final Identifier name = environment.identifiers["${returnType}Function(${parameters is InfiniteIterable ? '${parameters.first}...' : parameters.join(', ')})"] ??=
      Identifier("${returnType}Function(${parameters is InfiniteIterable ? '${parameters.first}...' : parameters.join(', ')})");

  FunctionValueType.internal(this.returnType, this.parameters, String file, Environment environment, TypeTable typeTable)
      : super.internal(returnType, file, environment, typeTable);
  FunctionValueType withReturnType(ValueType rt, String file) {
    return FunctionValueType(rt, parameters, file, environment, typeTable);
  }

  factory FunctionValueType(ValueType returnType, Iterable<ValueType> parameters, String file, Environment environment, TypeTable typeTable) {
    String name = "${returnType}Function(${parameters is InfiniteIterable ? '${parameters.first}...' : parameters.join(', ')})";
    return typeTable[environment.identifiers[name] ??=
        Identifier(name)] = typeTable[
            environment.identifiers[name] ??=
                Identifier(name)] as FunctionValueType<T>? ??
        FunctionValueType<T>.internal(returnType, parameters, file, environment, typeTable);
  }
  @override
  bool internal_isSubtypeOf(ValueType possibleParent) {
    if (super.internal_isSubtypeOf(possibleParent)) {
      return true;
    }
    if (possibleParent is! FunctionValueType) {
      return false;
    }
    if (!returnType.internal_isSubtypeOf(possibleParent.returnType)) {
      return false;
    }
    if (possibleParent.parameters is InfiniteIterable || parameters is InfiniteIterable) {
      if (possibleParent.parameters is! InfiniteIterable || parameters is! InfiniteIterable) return false;
    } else if (parameters.length != possibleParent.parameters.length) {
      return false;
    }
    int i = 0;
    return possibleParent.parameters.every(
      (element) => element.internal_isSubtypeOf(parameters.elementAt(i++)),
    );
  }
}

class InfiniteIterable<E> implements Iterable<E> {
  InfiniteIterable(this.value);

  final E value;

  String toString() => '($value...)';

  InfiniteIterable<T> map<T>(T Function(E) mapper) {
    return InfiniteIterable(mapper(value));
  }

  @override
  InfiniteIterator<E> get iterator => InfiniteIterator<E>(value);

  @override
  bool any(bool Function(E element) test) {
    return test(value);
  }

  @override
  Iterable<R> cast<R>() {
    // waiting for someone to use
    throw UnimplementedError();
  }

  @override
  bool contains(Object? element) {
    // waiting for someone to use
    throw UnimplementedError();
  }

  @override
  E elementAt(int index) {
    return value;
  }

  @override
  bool every(bool Function(E element) test) {
    return test(value);
  }

  @override
  Iterable<T> expand<T>(Iterable<T> Function(E element) toElements) {
    throw UnsupportedError(
      "$InfiniteIterable cannot expand(), would need to call toElements() an infinite amount of times",
    );
  }

  @override
  E get first => value;

  @override
  E firstWhere(bool Function(E element) test, {E Function()? orElse}) {
    // waiting for someone to use
    throw UnimplementedError();
  }

  @override
  T fold<T>(T initialValue, T Function(T previousValue, E element) combine) {
    throw UnsupportedError(
      "$InfiniteIterable cannot fold(), would need to call combine() an infinite amount of times",
    );
  }

  @override
  Iterable<E> followedBy(Iterable<E> other) {
    throw UnsupportedError("$InfiniteIterable cannot be followed by anything");
  }

  @override
  void forEach(void Function(E element) action) {
    throw UnsupportedError(
      "$InfiniteIterable forEach() iteration goes on forever",
    );
  }

  @override
  // waiting for someone to use
  bool get isEmpty => throw UnimplementedError();

  @override
  // waiting for someone to use
  bool get isNotEmpty => throw UnimplementedError();

  @override
  String join([String separator = ""]) {
    throw UnsupportedError("$InfiniteIterable cannot be joined together - result would be an infinite string");
  }

  @override
  E get last => throw UnsupportedError("$InfiniteIterable has no last element");

  @override
  E lastWhere(bool Function(E element) test, {E Function()? orElse}) {
    if (!test(value)) {
      // should we call for all elements or is just one fine?
      return (orElse == null
          ? () {
              throw Exception("No orElse, but test() returned false on $this");
            }
          : () {
              // waiting for use
              throw UnimplementedError();
            })();
    }
    throw UnsupportedError("$InfiniteIterable has no last element");
  }

  @override
  int get length => throw UnsupportedError("$InfiniteIterable has an infinite length, which is not an integer");

  @override
  E reduce(E Function(E value, E element) combine) {
    throw UnsupportedError("$InfiniteIterable cannot be reduced");
  }

  @override
  E get single => throw StateError("$this has more than one element when calling 'single'");

  @override
  E singleWhere(bool Function(E element) test, {E Function()? orElse}) {
    throw UnsupportedError("$InfiniteIterable.singleWhere");
  }

  @override
  Iterable<E> skip(int count) {
    // waiting for use
    throw UnimplementedError();
  }

  @override
  Iterable<E> skipWhile(bool Function(E value) test) {
    // waiting for use
    throw UnimplementedError();
  }

  @override
  Iterable<E> take(int count) {
    // waiting for use
    throw UnimplementedError();
  }

  @override
  Iterable<E> takeWhile(bool Function(E value) test) {
    // waiting for use
    throw UnimplementedError();
  }

  @override
  List<E> toList({bool growable = true}) {
    throw StateError("$InfiniteIterable cannot be converted to $List<$E> - would be an infinite list");
  }

  @override
  Set<E> toSet() {
    throw StateError("$InfiniteIterable cannot be converted to $Set<$E> - would be an infinite set");
  }

  @override
  Iterable<E> where(bool Function(E element) test) {
    // waiting for use
    throw UnimplementedError();
  }

  @override
  Iterable<T> whereType<T>() {
    // waiting for use
    throw UnimplementedError();
  }
}

class InfiniteIterator<T> implements Iterator<T> {
  final T value;

  InfiniteIterator(this.value);

  @override
  T get current => value;

  @override
  bool moveNext() {
    return true;
  }
}

class LazyInterpolatorSpace {
  final Object a;
  final Object b;

  String toString() => '$a $b';

  LazyInterpolatorSpace(this.a, this.b);
}

class Parameter {
  final ValueType type;
  final Identifier name;

  String toString() => "$type ${name.name}";

  Parameter(this.type, this.name);
}

class Class extends TypedValue<Class> {
  final Scope staticMembers;
  final SydFunction constructor;
  final ValueType<Class> type;

  Class(this.staticMembers, this.constructor, this.type);
}

class SydEnum extends TypedValue<SydEnum> {
  final Scope staticMembers;

  final ValueType<SydEnum> type;

  final Identifier name;

  String toString() {
    return '${name.name}';
  }

  SydEnum(this.staticMembers, this.type, this.name);
}

class SydEnumValue extends TypedValue<SydEnumValue> {
  final Object? value;
  final ValueType<SydEnumValue> type;

  String toString() {
    return value.toString();
  }

  SydEnumValue(this.value, this.type);
}
