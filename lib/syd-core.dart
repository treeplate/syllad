import 'dart:collection';
import 'dart:io';

class Concat {
  final Object? left;
  final Object? right;

  String toString() => left.toString() + right.toString();

  Concat(this.left, this.right);
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
  final String workspace;

  String toString() => '$str ${formatCursorPosition(line, col, workspace, file)}';

  CursorPositionLazyString(this.str, this.line, this.col, this.workspace, this.file);
}

class VariableLazyString extends LazyString {
  final Variable variable;

  String toString() => variable.name;

  VariableLazyString(this.variable);
}

class ConcatenateLazyString extends LazyString {
  final LazyString left;
  final LazyString right;

  String toString() => left.toString() + right.toString();

  ConcatenateLazyString(this.left, this.right);
}

String formatCursorPosition(int line, int col, String workspace, String file) {
  return "$workspace/$file:$line:$col";
}

abstract class Expression {
  Expression(this.line, this.col, this.workspace, this.file, this.tv);
  final int line, col;
  final String workspace, file;
  final TypeValidator tv;
  ValueWrapper eval(Scope scope);
  bool isLValue(TypeValidator scope);

  void write(ValueWrapper value, bool isConstant, Scope scope) {
    throw StateError('write of $runtimeType is not defined');
  }

  ValueType get type;
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
  final ValueWrapper? value;

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
const Variable whateverVariable = Variable("Whatever");
const Variable classMethodsVariable = Variable("~class~methods");
const Variable fwdclassVariable = Variable("fwdclass");
const Variable fwdclassfieldVariable = Variable("fwdclassfield");
const Variable fwdclassmethodVariable = Variable("fwdclassmethod");
const Variable fwdstaticfieldVariable = Variable("fwdstaticfield");
const Variable fwdstaticmethodVariable = Variable("fwdstaticmethod");
const Variable classVariable = Variable("class");
const Variable importVariable = Variable("import");
const Variable whileVariable = Variable("while");
const Variable breakVariable = Variable("break");
const Variable continueVariable = Variable("continue");
const Variable returnVariable = Variable("return");
const Variable ifVariable = Variable("if");
const Variable enumVariable = Variable("enum");
const Variable forVariable = Variable("for");
const Variable constVariable = Variable("const");
const Variable classNameVariable = Variable("className");
const Variable constructorVariable = Variable("constructor");
const Variable thisVariable = Variable("this");
const Variable toStringVariable = Variable("toString");
const Variable throwVariable = Variable("throw");
const Variable stringBufferVariable = Variable("StringBuffer");
const Variable fileVariable = Variable("File");

void handleVariable(Variable variable, Map<String, Variable> variables) {
  if (variables[variable.name] == null) {
    variables[variable.name] = variable;
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
  ValueWrapper thrower = scope.getVar(throwVariable, -2, 0, 'in throwWithStack', 'while throwing $value', null);
  return thrower.valueC<Never Function(List<ValueWrapper>, List<LazyString>)>(
          scope, stack, -2, 0, 'in throwWithStack', 'while throwing $value', scope.environment)(
      [ValueWrapper(scope.environment.stringType, value, 'string to throw'), ValueWrapper(scope.environment.integerType, -2, 'exit code for throwing')], stack);
}

class Variable {
  final String name;

  String toString() => throw "Temp: tried to tostring variable $name";

  const Variable(this.name);
}
class ValueWrapper<T extends Object?> {
  final ValueType<T>? _type;
  final T? _value;
  final Object debugCreationDescription;
  final bool canBeRead;

  /// This function gets the type of the wrapper, and throws an error if the value wrapper is sentinel
  ValueType typeC(Scope? scope, List<LazyString> stack, int line, int col, String workspace, String filename, Environment environment) {
    if (canBeRead) {
      return _type ?? (throw debugCreationDescription);
    } else {
      return valueC(scope, stack, line, col, workspace, filename, environment) as ValueType;
    }
  }

  /// This function gets the value of the wrapper, and throws an error if the value wrapper is sentinel
  R valueC<R>(Scope? scope, List<LazyString> stack, int line, int col, String workspace, String filename, Environment environment) {
    if (canBeRead) {
      R rtv = _value as R;
      return rtv;
    } else {
      scope == null
          ? (throw BSCException(
              "$debugCreationDescription was attempted to be read while uninitialized ${formatCursorPosition(line, col, workspace, filename)}\n${stack.reversed.join('\n')}",
              NoDataVG(environment)))
          : throwWithStack(
              scope,
              stack,
              "$debugCreationDescription was attempted to be read while uninitialized ${formatCursorPosition(line, col, workspace, filename)}",
            );
    }
  }

  ValueWrapper(this._type, this._value, this.debugCreationDescription, [this.canBeRead = true]) {
    assert(debugCreationDescription is! Variable);
    assert(_value is! ValueWrapper);
  }

  String toString() =>
      throw 'internal error: ValueWrapper.toString() called'; // toStringWithStack([NotLazyString('internal error: ValueWrapper.toString() called')], -2, 0, 'interr', 'interrr');

  String toStringWithStack(List<LazyString> s, int line, int col, String workspace, String file, bool rethrowErrors, Environment environment) {
    return _value is Function
        ? "<function ($debugCreationDescription)>"
        : _value is Enum
            ? debugCreationDescription.toString()
            : toStringWithStacker(this, s, line, col, workspace, file, rethrowErrors, environment);
  }
}

typedef SydFunction<T extends Object?> = ValueWrapper<T> Function(List<ValueWrapper> args, List<LazyString>, [Scope?, ValueType?]);

class SydFile {
  final RandomAccessFile file;
  final bool appendMode;
  bool used = false;

  SydFile(this.file, this.appendMode);
}

class TypeTable {
  final Map<Variable, ValueType> types = {};
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
  final TypeTable typeTable;
  final Map<String, Scope> filesRan;
  final Map<String, TypeValidator> loadedGlobalScopes;
  final Map<Variable, MapEntry<Stopwatch, int>> profile;
  final Map<String, MapEntry<List<Statement>, TypeValidator>> filesLoaded;
  final List<String> filesStartedLoading;
  final IOSink stderr;

  Environment copyWith(TypeTable typeTable) {
    return Environment(typeTable, stderr, filesRan, loadedGlobalScopes, profile, filesLoaded, filesStartedLoading);
  }

  Environment(this.typeTable, this.stderr,
      [Map<String, Scope>? filesRan,
      Map<String, TypeValidator>? loadedGlobalScopes,
      Map<Variable, MapEntry<Stopwatch, int>>? profile,
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
  final Map<String, Variable> variables;
  final Environment environment;

  bool get indirectlyStaticMethod {
    if (isStaticMethod) {
      return true;
    }
    return parents.map((e) => e.indirectlyStaticMethod).firstWhere((e) => e, orElse: () => false);
  }

  String toString() => "$debugName";

  TypeValidator(this.parents, this.debugName, this.isClass, this.isClassOf, this.isStaticMethod, this.rtl, this.variables, this.environment) {
    if (parents.any((element) => element.isClass)) isClass = true;
    if (parents.any((element) => element.isClassOf)) isClassOf = true;
    returnType = parents.where((element) => element.returnType != null).firstOrNull?.returnType;
  }
  final List<TypeValidator> parents;
  Map<Variable, TypeValidator> classes = {};
  List<Variable> nonconst = [];
  ValueType get currentClassType =>
      currentClassScope?.igv(thisVariable, true, -2, 0, 'thisshould', 'notmatter', true, false) ??
      (throw ("Super called outside class (stack trace is dart stack trace, not syd stack trace)"));
  TypeValidator? get currentClassScope {
    if (isClass) {
      return this;
    }
    return (parents.cast<TypeValidator?>()).firstWhere((element) => element!.currentClassScope != null, orElse: () => null)?.currentClassScope!;
  }

  Map<Variable, TVProp> types = {};

  List<Variable> directVars = standardDirectVars.toList();
  static final List<Variable> standardDirectVars = [Variable('true'), Variable('false'), Variable('null')];

  Set<Variable> usedVars = {};

  void setVar(Expression expression, ValueType value, int line, int col, String workspace, String file) {
    if (!expression.isLValue(this)) {
      throw BSCException(
        "Attempted to set non-lvalue $expression to expr of type $value ${formatCursorPosition(line, col, workspace, file)}",
        this,
      );
    }
    if (!value.isSubtypeOf(expression.type)) {
      throw BSCException(
        "Attempted to set $expression to expr of type $value but expected ${expression.type} ${formatCursorPosition(line, col, workspace, file)}",
        this,
      );
    }
  }

  void newVar(
    Variable name,
    ValueType type,
    int line,
    int col,
    String workspace,
    String file, [
    bool constant = false,
    bool isFwd = false,
    bool validForSuper = false,
  ]) {
    if (directVars.contains(name)) {
      throw BSCException(
        'Attempted redeclare of existing variable ${name.name} ${formatCursorPosition(line, col, workspace, file)}',
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

  ValueType getVar(Variable expr, int line, int col, String workspace, String file, String context, bool canBeType) {
    ValueType? realtype = igv(expr, true, line, col, workspace, file);
    if (realtype == null) {
      List<String> filenamesList = [];
      for (MapEntry<String, TypeValidator> e in environment.loadedGlobalScopes.entries) {
        if (e.value.igv(expr, true, line, col, workspace, file) != null) {
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
        "Attempted to retrieve ${expr.name}, which is undefined.  ${filenames.isEmpty ? '' : '(maybe you meant to import $filenames?) '}${type == null ? '' : '(that\'s a type, in case it helps) '}${formatCursorPosition(line, col, workspace, file)}",
        this,
      );
    }
    return realtype;
  }

  ValueType? igv(Variable name, bool addToUsedVars,
      [int debugLine = -2,
      int debugCol = 0,
      String debugWorkspace = '',
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
                    ? e.igv(name, addToUsedVars, debugLine, debugCol, debugWorkspace, debugFile, checkParent, escapeClass, acceptFwd)
                    : null)
                .firstWhere((e) => e != null, orElse: () => null)
            : null);
    return result;
  }

  bool igvnc(Variable name) {
    return nonconst.contains(name) || !types.containsKey(name) && parents.map((e) => e.igvnc(name)).firstWhere((e) => e, orElse: () => false);
  }

  TypeValidator copy() {
    return TypeValidator(
        parents.toList(), ConcatenateLazyString(debugName, NotLazyString(' copy')), isClass, isClassOf, isStaticMethod, rtl, variables, environment)
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
      this.fwdProps, super.parents, super.debugName, super.isClass, super.isClassOf, super.isStaticMethod, super.rtl, super.variables, super.environment) {}

  @override
  ValueType? igv(Variable name, bool addToUsedVars,
      [int line = -2,
      int col = 0,
      String workspace = '',
      String file = '',
      bool checkParent = true,
      bool escapeClass = true,
      bool acceptFwd = true,
      bool forSuper = false]) {
    ValueType? result = super.igv(name, addToUsedVars, line, col, workspace, file, false, false, false, forSuper);
    if (result != null) {
      return result;
    }
    if (acceptFwd) {
      return fwdProps.igv(name, addToUsedVars, line, col, workspace, file, checkParent, escapeClass, acceptFwd, forSuper) ??
          super.igv(name, addToUsedVars, line, col, workspace, file, checkParent, escapeClass, acceptFwd, forSuper);
    }
    return super.igv(name, addToUsedVars, line, col, workspace, file, checkParent, escapeClass, acceptFwd, forSuper);
  }
}


class MaybeConstantValueWrapper {
  final ValueWrapper value;
  final bool isConstant;

  MaybeConstantValueWrapper(this.value, this.isConstant);
}

class Scope extends VariableGroup {
  final bool? profileMode;
  final bool? debugMode;
  final Map<String, Variable> variables;
  final Environment environment;

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
    required this.variables,
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

  String toStringWithStack(List<LazyString> stack2, int line, int col, String workspace, String file, bool rethrowErrors) {
    try {
      return values.containsKey(variables['toString'])
          ? values[variables['toString']]!
              .value
              .valueC<SydFunction>(this, stack2 + [NotLazyString("implicit toString")], line, col, workspace, file, environment)
              (<ValueWrapper>[], stack2 + [NotLazyString("implicit toString")])
              .valueC(this, stack2 + [NotLazyString("implicit toString")], line, col, workspace, file, environment)
          : "<${values[variables['className']]?.value.valueC(this, stack2, line, col, workspace, file, environment) ?? '($debugName: stack: $stack)'}>";
    } on SydException {
      if (rethrowErrors) rethrow;
      return '<$debugName>';
    }
  }

  final Map<Variable, MaybeConstantValueWrapper> values = HashMap();

  void setVar(Expression expr, ValueWrapper value, bool isConstant, int line, int col, String workspace, String file) {
    expr.write(value, isConstant, this);
  }

  ValueWrapper? internal_getVar(Variable name) {
    if (values[name] != null) {
      return values[name]?.value;
    }
    for (Scope parent in parents) {
      ValueWrapper? subResult = parent.internal_getVar(name);
      if (subResult != null) {
        return subResult;
      }
    }
    return null;
  }

  ValueWrapper getVar(Variable name, int line, int column, String workspace, String file, TypeValidator? validator) {
    var val = internal_getVar(name);
    return val ??
        (validator?.classes.containsKey(name) ?? false
            ? (throw BSCException("class ${name.name} has not yet been defined ${formatCursorPosition(line, column, workspace, file)}", this))
            : (throw BSCException("${name.name} nonexistent ${formatCursorPosition(line, column, workspace, file)} ${stack.reversed.join("\n")}", this)));
  }

  bool recursiveContains(Variable variable) {
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
      "${values.entries.map<String>((kv) => '\n${' ' * (indent + 2)}${kv.key.name}: ${toStringWithStackerNullable(kv.value.value, stack, -2, 0, 'internl', 'file', false, environment) ?? 'uninitialized'}\n${' ' * (indent + 4)}type: ${kv.value.value._type}\n${' ' * (indent + 4)}assigned: ${kv.value.value.canBeRead}\n${' ' * (indent + 4)}debugCreationDescription: ${kv.value.value.debugCreationDescription}\n${' ' * (indent + 4)}isConstant: ${kv.value.isConstant}').join('')}",
    );
    buffer.write("\n${' ' * (indent + 2)}parents: ${parents.map((e) => '\n${e.dumpIndent(indent + 4)}').join('')}");
    return buffer.toString();
  }
}

class ValueType<T extends Object?> {
  final ValueType? parent;
  final Variable name;

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
    tv.types[tv.variables['~type${name.name}'] ??= Variable('~type${name.name}')] = TVProp(false, this, false);
    tv.igv(tv.variables['~type${name.name}']!, true);
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

  static ValueType create(ValueType? parent, Variable name, int line, int col, String workspace, String file, TypeValidator tv) {
    return createNullable(parent, name, file, tv) ??
        (throw BSCException("'${name.name}' type doesn't exist ${formatCursorPosition(line, col, workspace, file)}", NoDataVG(tv.environment)));
  }

  static ValueType? createNullable(ValueType? parent, Variable name, String file, TypeValidator tv) {
    //print(name.name + types.keys.map((e) => e.name).toList().toString());
    if (tv.environment.typeTable.types[name] != null && tv.igv(tv.variables['~type${name.name}'] ??= Variable('~type${name.name}'), true) != null)
      return tv.environment.typeTable.types[name];
    if (name.name.endsWith("Class")) {
      return null;
    }
    if (name.name.endsWith("Iterable")) {
      var iterableOrNull = ValueType.createNullable(
        tv.environment.anythingType,
        tv.variables[name.name.substring(0, name.name.length - 8)] ??= Variable(name.name.substring(0, name.name.length - 8)),
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
        tv.variables[name.name.substring(0, name.name.length - 8)] ??= Variable(name.name.substring(0, name.name.length - 8)),
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
        tv.variables[name.name.substring(0, name.name.length - 4)] ??= Variable(name.name.substring(0, name.name.length - 4)),
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
        tv.variables[name.name.substring(0, name.name.length - 5)] ??= Variable(name.name.substring(0, name.name.length - 5)),
        file,
        tv,
      );
      if (arrayOrNull == null) return null;
      return ArrayValueType<ValueWrapper>(
        arrayOrNull,
        file,
        tv,
      );
    }
    if (name.name.endsWith("Function")) {
      var functionOrNull = ValueType.createNullable(
        tv.environment.anythingType,
        tv.variables[name.name.substring(0, name.name.length - 8)] ??= Variable(name.name.substring(0, name.name.length - 8)),
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
        tv.variables[name.name.substring(0, name.name.length - 8)] ??= Variable(name.name.substring(0, name.name.length - 8)),
        file,
        tv,
      );
      if (nullableOrNull == null) return null;
      if (nullableOrNull is NullableValueType || nullableOrNull == tv.environment.nullType || nullableOrNull == tv.environment.anythingType || nullableOrNull.name == whateverVariable) {
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
  ClassValueType.internal(Variable name, this.supertype, this.properties, String file, TypeValidator tv)
      : super.internal(supertype ?? tv.environment.rootClassType, name, file, false, tv, tv.environment);
  factory ClassValueType(Variable name, ClassValueType? supertype, TypeValidator properties, String file, bool fwdDeclared, TypeValidator tv) {
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
  MapEntry<ValueType, ClassValueType>? recursiveLookup(Variable v) {
    return properties.igv(v, true, -2, 0, '446', 'parsercore', true, false) != null
        ? MapEntry(properties.igv(v, true, -2, 0, '446', 'parsercore', true, false)!, this)
        : supertype?.recursiveLookup(v);
  }
}

String toStringWithStacker(ValueWrapper x, List<LazyString> s, int line, int col, String workspace, String file, bool rethrowErrors, Environment environment) {
  if (x.typeC(null, s, line, col, workspace, file, environment) is ClassValueType) {
    return x.valueC<Scope>(null, s, line, col, workspace, file, environment).toStringWithStack(s, line, col, workspace, file, rethrowErrors);
  } else {
    Object? v = x.valueC(null, s, line, col, workspace, file, environment);
    if (v is List<ValueWrapper>) {
      return v.map((e) => e.toStringWithStack(s, line, col, workspace, file, rethrowErrors, environment)).toList().toString();
    } else {
      return v.toString();
    }
  }
}

String? toStringWithStackerNullable(
    ValueWrapper x, List<LazyString> s, int line, int col, String workspace, String file, bool rethrowErrors, Environment environment) {
  if (!x.canBeRead) return null;
  var type = x.typeC(null, s, line, col, workspace, file, environment);
  if (type is ClassValueType || type.name == classMethodsVariable) {
    return x.valueC<Scope>(null, s, line, col, workspace, file, environment).toStringWithStack(s, line, col, workspace, file, rethrowErrors);
  } else {
    Object? v = x.valueC(null, s, line, col, workspace, file, environment);
    if (v is Iterable<ValueWrapper>) {
      return v.map((e) => e.toStringWithStack(s, line, col, workspace, file, rethrowErrors, environment)).toList().toString();
    } else {
      if (v is Scope) {
        throw '??? ${v.toStringWithStack(s, line, col, workspace, file, rethrowErrors)}';
      }
      return v.toString();
    }
  }
}

class ClassOfValueType extends ValueType {
  final ClassValueType classType;
  final TypeValidator staticMembers;
  final GenericFunctionValueType constructor;

  bool internal_isSubtypeOf(ValueType possibleParent) {
    return super.internal_isSubtypeOf(possibleParent) || (possibleParent is ClassOfValueType && classType.internal_isSubtypeOf(possibleParent.classType));
  }

  factory ClassOfValueType(ClassValueType classType, TypeValidator staticMembers, GenericFunctionValueType constructor, String file, TypeValidator tv) {
    if (classType.environment.typeTable.types[tv.variables['${classType.name.name}Class'] ??= Variable('${classType.name.name}Class')] != null) {
      return classType.environment.typeTable.types[tv.variables['${classType.name.name}Class']!] as ClassOfValueType;
    }
    return ClassOfValueType.internal(classType, staticMembers, constructor, file, tv);
  }

  ClassOfValueType.internal(this.classType, this.staticMembers, this.constructor, String /*super.*/ file, TypeValidator tv)
      : super.internal(tv.environment.anythingType, tv.variables['${classType.name.name}Class']!, file, false, tv, tv.environment);

  @override
  bool memberAccesible() {
    return true;
  }
}

class EnumValueType extends ValueType {
  final TypeValidator staticMembers;
  final EnumPropertyValueType propertyType;

  EnumValueType(Variable name, this.staticMembers, String file, this.propertyType, TypeValidator tv)
      : super.internal(tv.environment.anythingType, tv.variables[name.name + 'Enum'] ??= Variable(name.name + 'Enum'), file, false, tv, tv.environment) {}

  @override
  bool memberAccesible() {
    return true;
  }
}

class EnumPropertyValueType extends ValueType {
  EnumPropertyValueType(Variable name, String file, TypeValidator tv) : super.internal(tv.environment.anythingType, name, file, false, tv, tv.environment) {}
}

class NullType extends ValueType<Null> {
  NullType.internal(ValueType anythingType, TypeValidator tv)
      : super.internal(tv.environment.anythingType, tv.variables['Null'] ??= Variable('Null'), 'interr', false, tv, tv.environment);

  bool internal_isSubtypeOf(ValueType possibleParent) {
    return possibleParent is NullableValueType || super.internal_isSubtypeOf(possibleParent);
  }
}

ValueType? basicTypes(Variable name, ValueType? parent, String file, TypeValidator tv) {
  final Variable? sentinel = tv.variables['Sentinel'];
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
      : super.internal(
            tv.environment.anythingType, tv.variables[genericParam.name.name + 'Nullable'] ??= Variable(genericParam.name.name + 'Nullable'), file, false, tv, tv.environment);
  factory NullableValueType(ValueType<Object> genericParam, String file, TypeValidator tv) {
    return (tv.environment.typeTable.types[tv.variables["${genericParam}Nullable"] ??= Variable("${genericParam}Nullable")] ??=
        NullableValueType.internal(genericParam, file, tv)) as NullableValueType<T>;
  }

  bool internal_isSubtypeOf(ValueType other) {
    return super.internal_isSubtypeOf(other) || (other is NullableValueType && genericParam.internal_isSubtypeOf(other.genericParam));
  }
}

class GenericFunctionValueType<T> extends ValueType<SydFunction<T>> {
  final TypeValidator tv;
  GenericFunctionValueType.internal(this.returnType, String file, this.tv)
      : super.internal(tv.environment.anythingType, tv.variables["${returnType}Function"] ??= Variable("${returnType}Function"), file, false, tv, tv.environment);
  final ValueType returnType;
  factory GenericFunctionValueType(ValueType returnType, String file, TypeValidator tv) {
    return (tv.environment.typeTable.types[tv.variables["${returnType}Function"] ??= Variable("${returnType}Function")] ??=
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

class IterableValueType<T> extends ValueType<Iterable<ValueWrapper<T>>> {
  IterableValueType.internal(this.genericParameter, String file, TypeValidator tv)
      : super.internal(tv.environment.anythingType, tv.variables["${genericParameter}Iterable"] ??= Variable("${genericParameter}Iterable"), file, false, tv, tv.environment);
  factory IterableValueType(ValueType<T> genericParameter, String file, TypeValidator tv) {
    return tv.environment.typeTable.types[tv.variables["${genericParameter}Iterable"] ??= Variable("${genericParameter}Iterable")] as IterableValueType<T>? ??
        IterableValueType<T>.internal(genericParameter, file, tv);
  }
  final ValueType<T> genericParameter;
  @override
  bool internal_isSubtypeOf(ValueType possibleParent) {
    return super.internal_isSubtypeOf(possibleParent) || (possibleParent is IterableValueType && genericParameter.internal_isSubtypeOf(possibleParent.genericParameter));
  }
}

class IteratorValueType<T> extends ValueType<Iterator<ValueWrapper<T>>> {
  IteratorValueType.internal(this.genericParameter, String file, TypeValidator tv)
      : super.internal(tv.environment.anythingType, tv.variables["${genericParameter}Iterator"] ??= Variable("${genericParameter}Iterator"), file, false, tv, tv.environment);
  factory IteratorValueType(ValueType<T> genericParameter, String file, TypeValidator tv) {
    return tv.environment.typeTable.types[tv.variables["${genericParameter}Iterator"] ??= Variable("${genericParameter}Iterator")] as IteratorValueType<T>? ??
        IteratorValueType<T>.internal(genericParameter, file, tv);
  }
  final ValueType<T> genericParameter;
  @override
  bool internal_isSubtypeOf(ValueType possibleParent) {
    return super.internal_isSubtypeOf(possibleParent) || (possibleParent is IteratorValueType && genericParameter.internal_isSubtypeOf(possibleParent.genericParameter));
  }
}

class ListValueType<T> extends ValueType<List<ValueWrapper<T>>> {
  final TypeValidator tv;
  ListValueType.internal(this.genericParameter, String file, this.tv)
      : super.internal(tv.environment.anythingType, tv.variables["${genericParameter}List"] ??= Variable("${genericParameter}List"), file, false, tv, tv.environment);
  late Variable name = tv.variables["${genericParameter}List"] ??= Variable("${genericParameter}List");
  factory ListValueType(ValueType<T> genericParameter, String file, TypeValidator tv) {
    return tv.environment.typeTable.types[tv.variables["${genericParameter}List"] ??= Variable("${genericParameter}List")] as ListValueType<T>? ??
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

class ArrayValueType<T extends ValueWrapper> extends ValueType<List<T>> {
  final TypeValidator tv;
  ArrayValueType.internal(this.genericParameter, String file, this.tv)
      : super.internal(tv.environment.anythingType, tv.variables["${genericParameter}Array"] ??= Variable("${genericParameter}Array"), file, false, tv, tv.environment);
  late Variable name = tv.variables["${genericParameter}Array"] ??= Variable("${genericParameter}Array");
  factory ArrayValueType(ValueType genericParameter, String file, TypeValidator tv) {
    return tv.environment.typeTable.types[tv.variables["${genericParameter}Array"] ??= Variable("${genericParameter}Array")] as ArrayValueType<T>? ??
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
  late final Variable name = tv.variables["${returnType}Function(${stringParams.substring(1, stringParams.length - 1)})"] ??=
      Variable("${returnType}Function(${stringParams.substring(1, stringParams.length - 1)})");

  FunctionValueType.internal(this.returnType, this.parameters, String file, TypeValidator tv) : super.internal(returnType, file, tv);
  FunctionValueType withReturnType(ValueType rt, String file) {
    return FunctionValueType(rt, parameters, file, tv);
  }

  factory FunctionValueType(ValueType returnType, Iterable<ValueType> parameters, String file, TypeValidator tv) {
    return tv.environment.typeTable.types[tv.variables["${returnType}Function(${parameters.toString().substring(1, parameters.toString().length - 1)})"] ??=
        Variable("${returnType}Function(${parameters.toString().substring(1, parameters.toString().length - 1)})")] = tv.environment.typeTable.types[
            tv.variables["${returnType}Function(${parameters.toString().substring(1, parameters.toString().length - 1)})"] ??=
                Variable("${returnType}Function(${parameters.toString().substring(1, parameters.toString().length - 1)})")] as FunctionValueType<T>? ??
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
  final Variable name;

  String toString() => "$type ${name.name}";

  Parameter(this.type, this.name);
}

class Class {
  final Scope staticMembers;
  final ValueWrapper<SydFunction> constructor;

  Class(this.staticMembers, this.constructor);
}

class Enum {
  final Scope staticMembers;

  String toString() {
    return 'enum ${staticMembers.debugName}';
  }

  Enum(this.staticMembers);
}