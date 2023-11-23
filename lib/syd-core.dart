import 'dart:collection';
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

class VariableLazyString extends LazyString {
  final Identifier variable;

  String toString() => variable.name;

  VariableLazyString(this.variable);
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

abstract class Expression {
  Expression(this.line, this.col, this.file, this.tv);
  final int line, col;
  final String file;
  final TypeValidator tv;
  Object? eval(Scope scope);
  bool isLValue(TypeValidator scope);

  void write(Object? value, bool isConstant, Scope scope) {
    throw StateError('write of $runtimeType is not defined');
  }

  ValueType get staticType;
  ValueType get asType => throw StateError('asType of $runtimeType is not defined');
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

abstract class Statement {
  Statement(this.line, this.col);

  StatementResult run(Scope scope);
  final int line;
  final int col;
}

class LazyString {}

const Identifier whateverVariable = Identifier("Whatever");
const Identifier classMethodsVariable = Identifier("~class~methods");
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
    if (exitCode == -2) {
      return BSCException(message, scope);
    } else if (exitCode == -3) {
      return AssertException(message, scope);
    } else if (exitCode == -4) {
      return ThrowException(message, scope);
    } else {
      throw FormatException("Invalid exit code $exitCode");
    }
  }
}

class AssertException extends SydException {
  AssertException(String message, VariableGroup scope) : super._(message, scope);

  int get exitCode => -3;
}

class ThrowException extends SydException {
  ThrowException(String message, VariableGroup scope) : super._(message, scope);

  int get exitCode => -4;
}

class BSCException extends SydException {
  // stands for "Bad Source Code"
  BSCException(String message, VariableGroup scope) : super._(message, scope);

  int get exitCode => -2;
}

Never throwWithStack(Scope scope, List<LazyString> stack, String value) {
  SydFunction<Never> thrower = scope.getVar(throwVariable, -2, 0, 'in throwWithStack while throwing $value', null) as SydFunction<Never>;
  return thrower.function([value, -2], stack);
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
  final T Function(List<Object?> args, List<LazyString>, [Scope?, ValueType?]) function;
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
    return iterable.toString();
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
  final List<List<bool>> subtypeTable = []; // subtypeTable[a][b] is equivalent to a.isSubtypeOf(b) (xxx this should go in environment)
  int currentId = 0; // xxx this should go in environment
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
  final TypeTable typeTable;
  final Map<String, Scope> filesRan;
  final Map<String, TypeValidator> loadedGlobalScopes;
  final Map<Identifier, MapEntry<Stopwatch, int>> profile;
  final Map<String, MapEntry<List<Statement>, TypeValidator>> filesLoaded;
  final List<String> filesStartedLoading;
  final IOSink stderr;

  Environment copyWith(TypeTable typeTable) {
    return Environment(typeTable, stderr, filesRan, loadedGlobalScopes, profile, filesLoaded, filesStartedLoading);
  }

  Environment(this.typeTable, this.stderr,
      [Map<String, Scope>? filesRan,
      Map<String, TypeValidator>? loadedGlobalScopes,
      Map<Identifier, MapEntry<Stopwatch, int>>? profile,
      Map<String, MapEntry<List<Statement>, TypeValidator>>? filesLoaded,
      List<String>? filesStartedLoading])
      : this.filesRan = filesRan ?? {},
        this.loadedGlobalScopes = loadedGlobalScopes ?? {},
        this.profile = profile ?? {},
        this.filesLoaded = filesLoaded ?? {},
        this.filesStartedLoading = filesStartedLoading ?? [];
}

class TVProp {
  final bool isFwd;
  final ValueType type;
  final bool validForSuper;

  TVProp(this.isFwd, this.type, this.validForSuper);

  ValueType? notFwd() {
    return isFwd ? null : type;
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
  final LazyString debugName;
  bool isClass;
  bool isClassOf;
  ValueType? returnType;
  final bool isStaticMethod;
  TypeValidator get intrinsics => parents.isEmpty ? this : parents.first.intrinsics;
  final MapEntry<List<Statement>, TypeValidator>? rtl;
  final Map<String, Identifier> identifiers;
  final Environment environment;

  bool get indirectlyStaticMethod {
    if (isStaticMethod) {
      return true;
    }
    return parents.map((e) => e.indirectlyStaticMethod).firstWhere((e) => e, orElse: () => false);
  }

  String toString() => "$debugName";

  TypeValidator(this.parents, this.debugName, this.isClass, this.isClassOf, this.isStaticMethod, this.rtl, this.identifiers, this.environment) {
    if (parents.any((element) => element.isClass)) isClass = true;
    if (parents.any((element) => element.isClassOf)) isClassOf = true;
    returnType = parents.where((element) => element.returnType != null).firstOrNull?.returnType;
  }
  final List<TypeValidator> parents;
  Map<Identifier, TypeValidator> classes = {};
  List<Identifier> nonconst = [];
  ValueType get currentClassType =>
      currentClassScope?.igv(thisVariable, true, -2, 0, 'thisshouldnotmatter', true, false) ??
      (throw ("Super called outside class (stack trace is dart stack trace, not syd stack trace)"));
  TypeValidator? get currentClassScope {
    if (isClass) {
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
      throw BSCException(
        "Attempted to set non-lvalue $expression to expr of type $value ${formatCursorPosition(line, col, file)}",
        this,
      );
    }
    if (!value.isSubtypeOf(expression.staticType)) {
      throw BSCException(
        "Attempted to set $expression to expr of type $value but expected ${expression.staticType} ${formatCursorPosition(line, col, file)}",
        this,
      );
    }
  }

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
      throw BSCException(
        'Attempted redeclare of existing variable ${name.name} ${formatCursorPosition(line, col, file)}',
        this,
      );
    }
    types[name] = TVProp(
      isFwd,
      type,
      validForSuper,
    );
    directVars.add(name);
    if (!constant) {
      nonconst.add(name);
    }
  }

  ValueType getVar(Identifier expr, int line, int col, String file, String context, bool canBeType) {
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
        environment.anythingType,
        expr,
        file,
        this,
      );
      if (canBeType && type != null) {
        return type;
      }
      throw BSCException(
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
    assert(!checkParent || escapeClass || isClass || isClassOf, '${this.debugName}');
    if (addToUsedVars && !usedVars.contains(name)) {
      usedVars.add(name);
    }
    assert(!parents.contains(this));
    ValueType? result = (acceptFwd && (!forSuper || (types[name]?.validForSuper ?? false))
            ? types[name]?.type
            : (!forSuper || (types[name]?.validForSuper ?? false))
                ? types[name]?.notFwd()
                : null) ??
        (checkParent
            ? parents
                .map<ValueType?>((e) => e.isClass || e.isClassOf || escapeClass
                    ? e.igv(name, addToUsedVars, debugLine, debugCol, debugFile, checkParent, escapeClass, acceptFwd)
                    : null)
                .firstWhere((e) => e != null, orElse: () => null)
            : null);
    return result;
  }

  bool igvnc(Identifier name) {
    return nonconst.contains(name) || !types.containsKey(name) && parents.map((e) => e.igvnc(name)).firstWhere((e) => e, orElse: () => false);
  }

  TypeValidator copy() {
    return TypeValidator(
        parents.toList(), ConcatenateLazyString(debugName, NotLazyString(' copy')), isClass, isClassOf, isStaticMethod, rtl, identifiers, environment)
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
    buffer.write("\n${' ' * (indent + 2)}isClass: $isClass");
    buffer.write("\n${' ' * (indent + 2)}isClassOf: $isClassOf");
    buffer.write("\n${' ' * (indent + 2)}isStaticMethod: $isStaticMethod");
    buffer.write(
      "${types.entries.map((kv) => '\n${' ' * (indent + 2)}${kv.key.name}: ${kv.value.type}\n${' ' * (indent + 4)}nonconst: ${nonconst.contains(kv.key)}\n${' ' * (indent + 4)}direct: ${directVars.contains(kv.key)}\n${' ' * (indent + 4)}used: ${usedVars.contains(kv.key)}\n${' ' * (indent + 4)}fwd-declared: ${kv.value.isFwd}').join('')}",
    );
    buffer.write("\n${' ' * (indent + 2)}parents: ${parents.map((e) => '\n${e.dumpIndent(indent + 4)}').join('')}");
    return buffer.toString();
  }
}

class ClassTypeValidator extends TypeValidator {
  final TypeValidator fwdProps;
  ClassTypeValidator(
      this.fwdProps, super.parents, super.debugName, super.isClass, super.isClassOf, super.isStaticMethod, super.rtl, super.identifiers, super.environment) {}

  @override
  ValueType? igv(Identifier name, bool addToUsedVars,
      [int line = -2, int col = 0, String file = '', bool checkParent = true, bool escapeClass = true, bool acceptFwd = true, bool forSuper = false]) {
    ValueType? result = super.igv(name, addToUsedVars, line, col, file, false, false, false, forSuper);
    if (result != null) {
      return result;
    }
    if (acceptFwd) {
      return fwdProps.igv(name, addToUsedVars, line, col, file, checkParent, escapeClass, acceptFwd, forSuper) ??
          super.igv(name, addToUsedVars, line, col, file, checkParent, escapeClass, acceptFwd, forSuper);
    }
    return super.igv(name, addToUsedVars, line, col, file, checkParent, escapeClass, acceptFwd, forSuper);
  }
}

class MaybeConstantValueWrapper {
  final Object? value;
  final bool isConstant;

  MaybeConstantValueWrapper(this.value, this.isConstant);
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
    required this.stack,
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
  final List<LazyString> stack;
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

  String toString() {
    throw "called Scope.toString()";
  }

  String toStringWithStack(List<LazyString> stack2, int line, int col, String file, bool rethrowErrors) {
    try {
      return values.containsKey(identifiers['toString'])
          ? (values[identifiers['toString']]!.value as SydFunction<Object?>).function([], stack2 + [NotLazyString("implicit toString")]) as String
          : "<${values[identifiers['className']]?.value ?? '($debugName: stack: $stack)'}>";
    } on SydException {
      if (rethrowErrors) rethrow;
      return '<$debugName>';
    }
  }

  final Map<Identifier, MaybeConstantValueWrapper> values = HashMap();

  void setVar(Expression expr, Object? value, bool isConstant, int line, int col, String file) {
    expr.write(value, isConstant, this);
  }

  (bool, Object?) internal_getVar(Identifier name) {
      var localResult = values[name];
    if (localResult != null) {
      return (true, localResult.value);
    }
    for (Scope parent in parents) {
      (bool, Object?) subResult = parent.internal_getVar(name);
      if (subResult.$1) {
        return subResult;
      }
    }
    return (false, null);
  }

  Object? getVar(Identifier name, int line, int column, String file, TypeValidator? validator) {
    var val = internal_getVar(name);
    return val.$1
        ? val.$2
        : (validator?.classes.containsKey(name) ?? false
            ? (throw BSCException("class ${name.name} has not yet been defined ${formatCursorPosition(line, column, file)}", this))
            : (throw BSCException("${name.name} nonexistent ${formatCursorPosition(line, column, file)} ${stack.reversed.join("\n")}", this)));
  }

  bool recursiveContains(Identifier variable) {
    if (values.containsKey(variable)) {
      return true;
    }
    for (Scope parent in parents) {
      if (parent.recursiveContains(variable)) {
        return true;
      }
    }
    return false;
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
    buffer.write(
      "${values.entries.map<String>((kv) => '\n${' ' * (indent + 2)}${kv.key.name}: ${toStringWithStackerNullable(kv.value.value, stack, -2, 0, 'file', false, environment) ?? 'uninitialized'}\n${' ' * (indent + 4)}type: ${kv.value.value is SydSentinel ? '<sentinel>' : (kv.value.value is Scope && (kv.value.value as Scope).typeIfClass == null) ? '<no type>' : getType(kv.value.value, this, -2, 0, 'in dumpIndent')}\n${' ' * (indent + 4)}isConstant: ${kv.value.isConstant}').join('')}",
    );
    buffer.write("\n${' ' * (indent + 2)}parents: ${parents.map((e) => '\n${e.dumpIndent(indent + 4)}').join('')}");
    return buffer.toString();
  }
}

ValueType getType(Object? value, VariableGroup scope, int line, int col, String file) {
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
    case SydSentinel():
      throw BSCException('Tried to access uninitalized value ${formatCursorPosition(line, col, file)}', scope);
    case TypedValue(type: ValueType type):
      return type;
    default:
      throw ('unknown value ${value.runtimeType}');
  }
}

class ValueType<T extends Object?> {
  final ValueType? parent;
  final Identifier name;

  late int id = environment.typeTable.currentId++;

  bool memberAccesible() {
    // whether this is a valid reciever for member access
    return _memberAccesible;
  }

  final bool _memberAccesible;

  String toString() => name.name;
  bool operator ==(x) => x is ValueType && this.isSubtypeOf(x) && x.isSubtypeOf(this);
  final Environment environment;

  ValueType.internal(this.parent, this.name, String file, this._memberAccesible, TypeValidator tv, this.environment) {
    if (environment.typeTable.types[name] != null) {
      throw BSCException("Repeated creation of ${name.name} (file $file)", StringVariableGroup(StackTrace.current.toString(), tv.environment));
    }
    if (environment.typeTable.types.keys.any((e) => e.name == name.name)) {
      throw StateError("Repeated creation of variable ${name.name} (file $file)");
    }
    environment.typeTable.types[name] = this;
    tv.types[tv.identifiers['~type${name.name}'] ??= Identifier('~type${name.name}')] = TVProp(false, this, false);
    tv.igv(tv.identifiers['~type${name.name}']!, true);
    assert(environment.typeTable.subtypeTable.length == id);
    environment.typeTable.subtypeTable.add([]);
    for (ValueType type in environment.typeTable.types.values) {
      assert(type.id == environment.typeTable.subtypeTable[id].length);
      environment.typeTable.subtypeTable[id].add(internal_isSubtypeOf(type));
      if (type.id == id) continue;
      assert(id == environment.typeTable.subtypeTable[type.id].length);
      environment.typeTable.subtypeTable[type.id].add(type.internal_isSubtypeOf(this));
    }
  }

  static ValueType create(ValueType? parent, Identifier name, int line, int col, String file, TypeValidator tv) {
    return createNullable(parent, name, file, tv) ??
        (throw BSCException("'${name.name}' type doesn't exist ${formatCursorPosition(line, col, file)}", NoDataVG(tv.environment)));
  }

  static ValueType? createNullable(ValueType? parent, Identifier name, String file, TypeValidator tv) {
    //print(name.name + types.keys.map((e) => e.name).toList().toString());
    if (tv.environment.typeTable.types[name] != null && tv.igv(tv.identifiers['~type${name.name}'] ??= Identifier('~type${name.name}'), true) != null)
      return tv.environment.typeTable.types[name];
    if (name.name.endsWith("Class")) {
      return null;
    }
    if (name.name.endsWith("Iterable")) {
      var iterableOrNull = ValueType.createNullable(
        tv.environment.anythingType,
        tv.identifiers[name.name.substring(0, name.name.length - 8)] ??= Identifier(name.name.substring(0, name.name.length - 8)),
        file,
        tv,
      );
      if (iterableOrNull == null) return null;
      return IterableValueType<Object?>(
        iterableOrNull,
        file,
        tv,
      );
    }
    if (name.name.endsWith("Iterator")) {
      var iteratorOrNull = ValueType.createNullable(
        tv.environment.anythingType,
        tv.identifiers[name.name.substring(0, name.name.length - 8)] ??= Identifier(name.name.substring(0, name.name.length - 8)),
        file,
        tv,
      );
      if (iteratorOrNull == null) return null;
      return IteratorValueType(
        iteratorOrNull,
        file,
        tv,
      );
    }
    if (name.name.endsWith('List')) {
      var listOrNull = ValueType.createNullable(
        tv.environment.anythingType,
        tv.identifiers[name.name.substring(0, name.name.length - 4)] ??= Identifier(name.name.substring(0, name.name.length - 4)),
        file,
        tv,
      );
      if (listOrNull == null) return null;
      return ListValueType<Object?>(
        listOrNull,
        file,
        tv,
      );
    }
    if (name.name.endsWith('Array')) {
      var arrayOrNull = ValueType.createNullable(
        tv.environment.anythingType,
        tv.identifiers[name.name.substring(0, name.name.length - 5)] ??= Identifier(name.name.substring(0, name.name.length - 5)),
        file,
        tv,
      );
      if (arrayOrNull == null) return null;
      return ArrayValueType(
        arrayOrNull,
        file,
        tv,
      );
    }
    if (name.name.endsWith("Function")) {
      var functionOrNull = ValueType.createNullable(
        tv.environment.anythingType,
        tv.identifiers[name.name.substring(0, name.name.length - 8)] ??= Identifier(name.name.substring(0, name.name.length - 8)),
        file,
        tv,
      );
      if (functionOrNull == null) return null;
      return GenericFunctionValueType(
        functionOrNull,
        file,
        tv,
      );
    }
    if (name.name.endsWith("Nullable")) {
      var nullableOrNull = ValueType.createNullable(
        tv.environment.anythingType,
        tv.identifiers[name.name.substring(0, name.name.length - 8)] ??= Identifier(name.name.substring(0, name.name.length - 8)),
        file,
        tv,
      );
      if (nullableOrNull == null) return null;
      if (nullableOrNull is NullableValueType ||
          nullableOrNull == tv.environment.nullType ||
          nullableOrNull == tv.environment.anythingType ||
          nullableOrNull.name == whateverVariable) {
        throw BSCException("Type $nullableOrNull is already nullable, cannot make nullable version ${name.name}", NoDataVG(tv.environment));
      }
      return NullableValueType<Object?>(
        nullableOrNull as ValueType<Object>,
        file,
        tv,
      );
    }
    return basicTypes(name, parent, file, tv);
  }

  bool internal_isSubtypeOf(ValueType possibleParent) {
    return name == possibleParent.name ||
        (parent != null && parent!.internal_isSubtypeOf(possibleParent)) ||
        name == whateverVariable ||
        possibleParent.name == whateverVariable ||
        (possibleParent is NullableValueType && internal_isSubtypeOf(possibleParent.genericParam));
  }

  bool isSubtypeOf(ValueType possibleParent) {
    return environment.typeTable.subtypeTable[id][possibleParent.id];
  }

  ValueType withReturnType(ValueType x, String file) {
    throw UnsupportedError("err");
  }
}

class ClassValueType extends ValueType<Scope> {
  ClassValueType.internal(Identifier name, this.supertype, this.properties, String file, TypeValidator tv)
      : super.internal(supertype ?? tv.environment.rootClassType, name, file, false, tv, tv.environment);
  factory ClassValueType(Identifier name, ClassValueType? supertype, TypeValidator properties, String file, bool fwdDeclared, TypeValidator tv) {
    if (tv.environment.typeTable.types[name] is! ClassValueType?) {
      throw BSCException("Tried to make class named ${name.name} but that is an existing non-class type (file: $file)", properties);
    }
    return ((tv.environment.typeTable.types[name] ??= ClassValueType.internal(name, supertype, properties, file, tv)) as ClassValueType)
      ..fwdDeclared = fwdDeclared;
  }
  final TypeValidator properties;
  final ClassValueType? supertype;
  final List<ClassValueType> subtypes = [];
  bool fwdDeclared = true; // set to false when the class is fully declared

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

String toStringWithStacker(Object? x, List<LazyString> s, int line, int col, String file, bool rethrowErrors, Environment environment) {
  if (getType(x, NoDataVG(environment), line, col, file) is ClassValueType) {
    return (x as Scope).toStringWithStack(s, line, col, file, rethrowErrors);
  } else {
    return x.toString();
  }
}

String? toStringWithStackerNullable(Object? x, List<LazyString> s, int line, int col, String file, bool rethrowErrors, Environment environment) {
  if (x is Scope) {
    return x.toStringWithStack(s, line, col, file, rethrowErrors);
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

  factory ClassOfValueType(ClassValueType classType, TypeValidator staticMembers, GenericFunctionValueType constructor, String file, TypeValidator tv) {
    if (classType.environment.typeTable.types[tv.identifiers['${classType.name.name}Class'] ??= Identifier('${classType.name.name}Class')] != null) {
      return classType.environment.typeTable.types[tv.identifiers['${classType.name.name}Class']!] as ClassOfValueType;
    }
    return ClassOfValueType.internal(classType, staticMembers, constructor, file, tv);
  }

  ClassOfValueType.internal(this.classType, this.staticMembers, this.constructor, String /*super.*/ file, TypeValidator tv)
      : super.internal(tv.environment.anythingType, tv.identifiers['${classType.name.name}Class']!, file, false, tv, tv.environment);

  @override
  bool memberAccesible() {
    return true;
  }
}

class EnumValueType extends ValueType<SydEnum> {
  final TypeValidator staticMembers;
  final EnumPropertyValueType propertyType;

  EnumValueType(Identifier name, this.staticMembers, String file, this.propertyType, TypeValidator tv)
      : super.internal(tv.environment.anythingType, tv.identifiers[name.name + 'Enum'] ??= Identifier(name.name + 'Enum'), file, false, tv, tv.environment) {}

  @override
  bool memberAccesible() {
    return true;
  }
}

class EnumPropertyValueType extends ValueType<SydEnumValue> {
  EnumPropertyValueType(Identifier name, String file, TypeValidator tv) : super.internal(tv.environment.anythingType, name, file, false, tv, tv.environment) {}
}

class NullType extends ValueType<Null> {
  NullType.internal(ValueType anythingType, TypeValidator tv)
      : super.internal(tv.environment.anythingType, tv.identifiers['Null'] ??= Identifier('Null'), 'interr', false, tv, tv.environment);

  bool internal_isSubtypeOf(ValueType possibleParent) {
    return possibleParent is NullableValueType || super.internal_isSubtypeOf(possibleParent);
  }
}

ValueType? basicTypes(Identifier name, ValueType? parent, String file, TypeValidator tv) {
  final Identifier? sentinel = tv.identifiers['~sentinel'];
  switch (name) {
    case whateverVariable:
    case classMethodsVariable:
      if (tv.environment.typeTable.types[name] != null) return tv.environment.typeTable.types[name];
      return ValueType.internal(parent, name, file, name == whateverVariable, tv, tv.environment);
    default:
      if (name == sentinel) {
        if (tv.environment.typeTable.types[name] != null) return tv.environment.typeTable.types[name];
        return ValueType.internal(parent, name, file, name == whateverVariable, tv, tv.environment);
      }
      return null;
  }
}

class NullableValueType<T> extends ValueType<T?> {
  final ValueType<T> genericParam;

  NullableValueType.internal(this.genericParam, String file, TypeValidator tv)
      : super.internal(tv.environment.anythingType, tv.identifiers[genericParam.name.name + 'Nullable'] ??= Identifier(genericParam.name.name + 'Nullable'), file,
            false, tv, tv.environment);
  factory NullableValueType(ValueType<Object> genericParam, String file, TypeValidator tv) {
    return (tv.environment.typeTable.types[tv.identifiers["${genericParam}Nullable"] ??= Identifier("${genericParam}Nullable")] ??=
        NullableValueType.internal(genericParam, file, tv)) as NullableValueType<T>;
  }

  bool internal_isSubtypeOf(ValueType other) {
    return super.internal_isSubtypeOf(other) || (other is NullableValueType && genericParam.internal_isSubtypeOf(other.genericParam));
  }
}

class GenericFunctionValueType<T> extends ValueType<SydFunction<T>> {
  final TypeValidator tv;
  GenericFunctionValueType.internal(this.returnType, String file, this.tv)
      : super.internal(
            tv.environment.anythingType, tv.identifiers["${returnType}Function"] ??= Identifier("${returnType}Function"), file, false, tv, tv.environment);
  final ValueType returnType;
  factory GenericFunctionValueType(ValueType returnType, String file, TypeValidator tv) {
    return (tv.environment.typeTable.types[tv.identifiers["${returnType}Function"] ??= Identifier("${returnType}Function")] ??=
        GenericFunctionValueType<T>.internal(returnType, file, tv)) as GenericFunctionValueType<T>;
  }
  @override
  bool internal_isSubtypeOf(final ValueType possibleParent) {
    return super.internal_isSubtypeOf(possibleParent) ||
        ((possibleParent is GenericFunctionValueType && (this is! FunctionValueType || possibleParent is! FunctionValueType)) &&
            returnType.internal_isSubtypeOf(possibleParent.returnType));
  }

  GenericFunctionValueType withReturnType(ValueType rt, String file) {
    return GenericFunctionValueType(rt, file, tv);
  }
}

class IterableValueType<T> extends ValueType<SydIterable<T>> {
  IterableValueType.internal(this.genericParameter, String file, TypeValidator tv)
      : super.internal(tv.environment.anythingType, tv.identifiers["${genericParameter}Iterable"] ??= Identifier("${genericParameter}Iterable"), file, false, tv,
            tv.environment);
  factory IterableValueType(ValueType<T> genericParameter, String file, TypeValidator tv) {
    return tv.environment.typeTable.types[tv.identifiers["${genericParameter}Iterable"] ??= Identifier("${genericParameter}Iterable")] as IterableValueType<T>? ??
        IterableValueType<T>.internal(genericParameter, file, tv);
  }
  final ValueType<T> genericParameter;
  @override
  bool internal_isSubtypeOf(ValueType possibleParent) {
    return super.internal_isSubtypeOf(possibleParent) ||
        (possibleParent is IterableValueType && genericParameter.internal_isSubtypeOf(possibleParent.genericParameter));
  }
}

class IteratorValueType<T> extends ValueType<SydIterator<T>> {
  IteratorValueType.internal(this.genericParameter, String file, TypeValidator tv)
      : super.internal(tv.environment.anythingType, tv.identifiers["${genericParameter}Iterator"] ??= Identifier("${genericParameter}Iterator"), file, false, tv,
            tv.environment);
  factory IteratorValueType(ValueType<T> genericParameter, String file, TypeValidator tv) {
    return tv.environment.typeTable.types[tv.identifiers["${genericParameter}Iterator"] ??= Identifier("${genericParameter}Iterator")] as IteratorValueType<T>? ??
        IteratorValueType<T>.internal(genericParameter, file, tv);
  }
  final ValueType<T> genericParameter;
  @override
  bool internal_isSubtypeOf(ValueType possibleParent) {
    return super.internal_isSubtypeOf(possibleParent) ||
        (possibleParent is IteratorValueType && genericParameter.internal_isSubtypeOf(possibleParent.genericParameter));
  }
}

class ListValueType<T> extends ValueType<SydList<T>> {
  final TypeValidator tv;
  ListValueType.internal(this.genericParameter, String file, this.tv)
      : super.internal(
            tv.environment.anythingType, tv.identifiers["${genericParameter}List"] ??= Identifier("${genericParameter}List"), file, false, tv, tv.environment);
  late Identifier name = tv.identifiers["${genericParameter}List"] ??= Identifier("${genericParameter}List");
  factory ListValueType(ValueType<T> genericParameter, String file, TypeValidator tv) {
    return tv.environment.typeTable.types[tv.identifiers["${genericParameter}List"] ??= Identifier("${genericParameter}List")] as ListValueType<T>? ??
        ListValueType<T>.internal(genericParameter, file, tv);
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
  final TypeValidator tv;
  ArrayValueType.internal(this.genericParameter, String file, this.tv)
      : super.internal(
            tv.environment.anythingType, tv.identifiers["${genericParameter}Array"] ??= Identifier("${genericParameter}Array"), file, false, tv, tv.environment);
  late Identifier name = tv.identifiers["${genericParameter}Array"] ??= Identifier("${genericParameter}Array");
  factory ArrayValueType(ValueType genericParameter, String file, TypeValidator tv) {
    return tv.environment.typeTable.types[tv.identifiers["${genericParameter}Array"] ??= Identifier("${genericParameter}Array")] as ArrayValueType<T>? ??
        ArrayValueType<T>.internal(genericParameter, file, tv);
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
  late final Identifier name = tv.identifiers["${returnType}Function(${stringParams.substring(1, stringParams.length - 1)})"] ??=
      Identifier("${returnType}Function(${stringParams.substring(1, stringParams.length - 1)})");

  FunctionValueType.internal(this.returnType, this.parameters, String file, TypeValidator tv) : super.internal(returnType, file, tv);
  FunctionValueType withReturnType(ValueType rt, String file) {
    return FunctionValueType(rt, parameters, file, tv);
  }

  factory FunctionValueType(ValueType returnType, Iterable<ValueType> parameters, String file, TypeValidator tv) {
    return tv.environment.typeTable.types[tv.identifiers["${returnType}Function(${parameters.toString().substring(1, parameters.toString().length - 1)})"] ??=
        Identifier("${returnType}Function(${parameters.toString().substring(1, parameters.toString().length - 1)})")] = tv.environment.typeTable.types[
            tv.identifiers["${returnType}Function(${parameters.toString().substring(1, parameters.toString().length - 1)})"] ??=
                Identifier("${returnType}Function(${parameters.toString().substring(1, parameters.toString().length - 1)})")] as FunctionValueType<T>? ??
        FunctionValueType<T>.internal(returnType, parameters, file, tv);
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
