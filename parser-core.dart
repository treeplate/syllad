import 'lexer.dart';

Map<String, TypeValidator> loadedGlobalScopes = {};
Map<Variable, MapEntry<Stopwatch, int>> profile = {};
const Variable whateverVariable = Variable("Whatever");
const Variable classMethodsVariable = Variable("~class~methods");
const Variable fwdclassVariable = Variable("fwdclass");
const Variable fwdclasspropVariable = Variable("fwdclassprop");
const Variable classVariable = Variable("class");
const Variable namespaceVariable = Variable("namespace");
const Variable importVariable = Variable("import");
const Variable whileVariable = Variable("while");
const Variable breakVariable = Variable("break");
const Variable continueVariable = Variable("continue");
const Variable returnVariable = Variable("return");
const Variable ifVariable = Variable("if");
const Variable enumVariable = Variable("enum");
const Variable forVariable = Variable("for");
const Variable constVariable = Variable("const");
Variable classNameVariable = Variable("className");
Variable constructorVariable = Variable("constructor");
Variable thisVariable = Variable("this");
Variable throwVariable = Variable("throw");

Null handleVariable(Variable variable) {
  if (variables[variable.name] == null) {
    variables[variable.name] = variable;
  } else {
    throw "Attempted to create duplicate variable $variable";
  }
}

class LazyInterpolator {
  final Object a;
  final Object b;

  String toString() => '$a $b';

  LazyInterpolator(this.a, this.b);
}

Map<String, Variable> variables = {};

class Variable {
  final String name;

  String toString() => '{$name varvar}';

  const Variable(this.name);
}

class TypeValidator {
  final String debugName;
  TypeValidator get intrinsics => parents.isEmpty ? this : parents.first.intrinsics;

  TypeValidator(this.parents, this.debugName);
  final List<TypeValidator> parents;
  Map<Variable, TypeValidator> classes = {};
  List<Variable> nonconst = [];
  ValueType get currentClass => igv(thisVariable, true) ?? (throw ("Super called outside class (stack trace is dart stack trace, not syd stack trace)"));
  Map<Variable, ValueType> types = {};

  List<Variable> directVars = sdv.toList();
  static List<Variable> sdv = [Variable('true'), Variable('false'), Variable('null')];

  Set<Variable> usedVars = {};

  void setVar(Variable name, int subscripts, ValueType value, int line, int col, String workspace, String file) {
    if (igv(name, false, line, col, workspace, file) == null) {
      throw BSCException("Cannot assign to $name, an undeclared variable ${formatCursorPosition(line, col, workspace, file)}");
    }
    if (!igvnc(name) && subscripts == 0) {
      throw BSCException(
        "Cannot reassign $name ${formatCursorPosition(line, col, workspace, file)}",
      );
    }
    int oldSubs = subscripts;
    ValueType type = igv(name, false, line, col, workspace, file)!;
    while (subscripts > 0) {
      if (type is! ListValueType) {
        throw BSCException(
          "Expected a list, got $type when trying to subscript $name ${formatCursorPosition(line, col, workspace, file)}",
        );
      }
      type = type.genericParameter;
      subscripts--;
    }
    if (!value.isSubtypeOf(type)) {
      throw BSCException(
        "Expected $type, got $value while setting $name${"[...]" * oldSubs} to $value ${formatCursorPosition(line, col, workspace, file)}",
      );
    }
  }

  void newVar(Variable name, ValueType type, int line, int col, String workspace, String file, [bool constant = false]) {
    if (directVars.contains(name)) {
      throw BSCException(
        'Attempted redeclare of existing variable $name ${formatCursorPosition(line, col, workspace, file)}',
      );
    }
    types[name] = type;
    directVars.add(name);
    if (!constant) {
      nonconst.add(name);
    }
  }

  ValueType getVar(Variable name, int subscripts, int line, int col, String workspace, String file, String context) {
    ValueType? realtype = igv(name, true, line, col, workspace, file);
    if (realtype == null) {
      String? filename;
      for (MapEntry<String, TypeValidator> e in loadedGlobalScopes.entries) {
        if (e.value.igv(name, true, line, col, workspace, file) != null) {
          filename = e.key;
        }
      }
      throw BSCException(
          "Attempted to retrieve $name ($context), which is undefined. ${filename == null ? '' : '(maybe you meant to import $filename?) '}${formatCursorPosition(line, col, workspace, file)}");
    }
    while (subscripts > 0) {
      if (realtype is! ListValueType) {
        throw BSCException(
          "Expected a list, but got $realtype when trying to subscript $name ${formatCursorPosition(line, col, workspace, file)}",
        );
      }
      realtype = realtype.genericParameter;
      subscripts--;
    }
    return realtype!;
  }

  ValueType? igv(Variable name, bool addToUsedVars, [int line = -2, int col = 0, String workspace = '', String file = '']) {
    if (addToUsedVars) usedVars.add(name);
    return types[name] ?? parents.map((e) => e.igv(name, addToUsedVars, line, col, workspace, file)).firstWhere((e) => e != null, orElse: () => null);
  }

  bool igvnc(Variable name) {
    return nonconst.contains(name) || parents.map((e) => e.igvnc(name)).firstWhere((e) => e, orElse: () => false);
  }

  TypeValidator copy() {
    return TypeValidator(parents, debugName + ' copy')..nonconst = nonconst.toList();
  }
}

T? orElse<T>(T? a, T? b) {
  if (a != null) {
    return a;
  }
  return b;
}

class NamespaceTypeValidator extends TypeValidator {
  final TypeValidator deferTarget;
  final Variable namespace;

  NamespaceTypeValidator(this.deferTarget, this.namespace) : super([deferTarget], 'namespace of $namespace');
  @override
  late Map<Variable, TypeValidator> classes = deferTarget.classes;

  @override
  List<Variable> directVars = [];

  @override
  late List<Variable> nonconst = [];

  @override
  Map<Variable, ValueType> types = {};

  @override
  Set<Variable> usedVars = {};

  @override
  TypeValidator copy() {
    return NamespaceTypeValidator(deferTarget, namespace);
  }

  @override
  ValueType get currentClass => deferTarget.currentClass;

  @override
  ValueType? igv(Variable name, bool addToUsedVars, [int line = -2, int col = 0, String workspace = '', String file = '']) {
    if (addToUsedVars) usedVars.add(name);
    return types[name] ??
        deferTarget.igv(variables[namespace.name + name.name] ??= Variable(namespace.name + name.name), addToUsedVars, line, col, workspace, file) ??
        deferTarget.igv(name, addToUsedVars, line, col, workspace, file);
  }
}

void throwWithStack(Scope scope, List<LazyString> stack, String value) {
  ValueWrapper thrower = scope.getVar(throwVariable, -2, 0, 'in throwWithStack', 'while throwing $value', null);
  thrower.valueC<void Function(List<ValueWrapper>, List<LazyString>)>(scope, stack, -2, 0, 'in throwWithStack', 'while throwing $value')(
      [ValueWrapper(stringType, value, 'string to throw')], stack);
}

class ValueWrapper<T extends Object?> {
  final ValueType<T>? _type;
  final T? _value;
  final Object debugCreationDescription;
  final bool canBeRead;
  ValueType typeC(Scope? scope, List<LazyString> stack, int line, int col, String workspace, String filename) {
    if (canBeRead) {
      return _type!;
    } else {
      return valueC(scope, stack, line, col, workspace, filename) as ValueType;
    }
  }

  /// This function gets the value of the wrapper, and throws an error if the value wrapper is sentinel
  R valueC<R>(Scope? scope, List<LazyString> stack, int line, int col, String workspace, String filename) {
    if (canBeRead) {
      R rtv = _value as R;
      return rtv;
    } else {
      scope == null
          ? (throw BSCException(
              "$debugCreationDescription was attempted to be read while uninititalized ${formatCursorPosition(line, col, workspace, filename)}\n${stack.reversed.join('\n')}"))
          : throwWithStack(
              scope,
              stack,
              "$debugCreationDescription was attempted to be read while uninititalized ${formatCursorPosition(line, col, workspace, filename)}",
            );
      throw (BSCException('internal error: throw did not exit'));
    }
  }

  ValueWrapper(this._type, this._value, this.debugCreationDescription, [this.canBeRead = true]) : assert(_value.runtimeType != TA);

  String toString() => toStringWithStack([NotLazyString('internal error: ValueWrapper.toString() called')], -2, 0, 'interr', 'interrr');

  String toStringWithStack(List<LazyString> s, int line, int col, String workspace, String file) {
    return _value is Function ? "<function ($debugCreationDescription)>" : toStringWithStacker(this, s, line, col, workspace, file);
  }
}

typedef TA = dynamic Function(List<ValueWrapper> args, List<LazyString>, [Scope?, ValueType?]);

class NamespaceScope implements Scope {
  final Scope deferTarget;
  final Variable namespace;

  NamespaceScope(this.deferTarget, this.namespace);

  @override
  Map<Variable, ValueWrapper> values = {};

  @override
  void addParent(Scope scope) {
    deferTarget.addParent(scope);
  }

  @override
  ClassValueType get currentClass => deferTarget.currentClass;

  @override
  LazyString get debugName => NotLazyString('namespace $namespace of $deferTarget');

  @override
  ClassValueType? get declaringClass => deferTarget.declaringClass;

  @override
  ValueWrapper getVar(Variable name, int line, int column, String workspace, String file, TypeValidator? validator) {
    ValueWrapper? val = internal_getVar(name);
    if (val == null) throw BSCException('tried to access nonexistent $name from namespace scope  ${formatCursorPosition(line, column, workspace, file)}');
    return val;
  }

  @override
  ValueWrapper? internal_getVar(Variable name) {
    return values[name] ??
        deferTarget.internal_getVar(variables[namespace.name + name.name] ??= Variable(namespace.name + name.name)) ??
        deferTarget.internal_getVar(name);
  }

  @override
  Scope? get intrinsics => deferTarget.intrinsics;

  @override
  List<Scope> get parents => [deferTarget];

  @override
  void setVar(Variable name, List<int> subscripts, ValueWrapper value, int line, int col, String workspace, String file) {
    if (deferTarget.internal_getVar(variables[namespace.name + name.name] ??= Variable(namespace.name + name.name)) != null) {
      deferTarget.setVar(variables[namespace.name + name.name] ??= Variable(namespace.name + name.name), subscripts, value, line, col, workspace, file);
    }
    deferTarget.setVar(name, subscripts, value, line, col, workspace, file);
  }

  @override
  late List<LazyString> stack = deferTarget.stack + [NotLazyString('namespace of $namespace')]; // xxx optimize

  @override
  String toStringWithStack(List<LazyString> stack2, int line, int col, String workspace, String file) {
    return deferTarget.toStringWithStack(stack2, line, col, workspace, file);
  }

  @override
  bool get isClass => false;

  @override
  ClassValueType? get typeIfClass => null;
}

Map<String, int> fileTypes = {};

class ValueType<T extends Object?> {
  final ValueType? parent;
  final Variable name;

  String toString() => name.name;
  bool operator ==(x) => x is ValueType && this.isSubtypeOf(x) && x.isSubtypeOf(this);

  ValueType.internal(this.parent, this.name, String file) {
    if (types[name] != null) {
      throw BSCException("Repeated creation of ${name.name}");
    }
    types[name] = this;
    fileTypes[file] = (fileTypes[file] ?? 0) + 1;
  }
  static final Map<Variable, ValueType> types = {};
  static ValueType create(ValueType? parent, Variable name, int line, int col, String workspace, String file) {
    return types[name] ??
        (name.name.endsWith("Iterable")
            ? IterableValueType(
                ValueType.create(
                  sharedSupertype,
                  variables[name.name.substring(0, name.name.length - 8)] ?? Variable(name.name.substring(0, name.name.length - 8)),
                  line,
                  col,
                  workspace,
                  file,
                ),
                file,
              )
            : name.name.endsWith("Iterator")
                ? IteratorValueType(
                    ValueType.create(
                      sharedSupertype,
                      variables[name.name.substring(0, name.name.length - 8)] ?? Variable(name.name.substring(0, name.name.length - 8)),
                      line,
                      col,
                      workspace,
                      file,
                    ),
                    file,
                  )
                : name.name.endsWith("List")
                    ? ListValueType(
                        ValueType.create(
                          sharedSupertype,
                          variables[name.name.substring(0, name.name.length - 4)] ?? Variable(name.name.substring(0, name.name.length - 4)),
                          line,
                          col,
                          workspace,
                          file,
                        ),
                        file,
                      )
                    : name.name.endsWith("Function")
                        ? GenericFunctionValueType(
                            ValueType.create(
                              sharedSupertype,
                              variables[name.name.substring(0, name.name.length - 8)] ?? Variable(name.name.substring(0, name.name.length - 8)),
                              line,
                              col,
                              workspace,
                              file,
                            ),
                            file,
                          )
                        : name.name.endsWith("Nullable")
                            ? NullableValueType<Object?>(
                                ValueType.create(
                                  sharedSupertype,
                                  variables[name.name.substring(0, name.name.length - 8)] ?? Variable(name.name.substring(0, name.name.length - 8)),
                                  line,
                                  col,
                                  workspace,
                                  file,
                                ),
                                file)
                            : basicTypes(name, parent, line, col, workspace, file));
  }

  bool isSubtypeOf(ValueType possibleParent) {
    var bool = name == possibleParent.name ||
        (parent != null && parent!.isSubtypeOf(possibleParent)) ||
        name == whateverVariable ||
        possibleParent.name == whateverVariable ||
        (name == nullType.name && possibleParent is NullableValueType) ||
        (possibleParent is NullableValueType && isSubtypeOf(possibleParent.genericParam));
    return bool;
  }

  GenericFunctionValueType withReturnType(ValueType x, String file) {
    throw UnimplementedError("err");
  }
}

class NullableValueType<T> extends ValueType<T?> {
  final ValueType<T> genericParam;

  NullableValueType(this.genericParam, String file)
      : super.internal(sharedSupertype, variables[genericParam.name.name + 'Nullable'] ??= Variable(genericParam.name.name + 'Nullable'), file);

  bool isSubtypeOf(ValueType other) {
    return super.isSubtypeOf(other) || (other is NullableValueType && genericParam.isSubtypeOf(other.genericParam));
  }
}

class ClassValueType extends ValueType<Scope> {
  ClassValueType.internal(Variable name, this.supertype, this.properties, String file) : super.internal(supertype ?? sharedSupertype, name, file);
  factory ClassValueType(Variable name, ClassValueType? supertype, TypeValidator properties, String file) {
    return (ValueType.types[name] ??= ClassValueType.internal(name, supertype, properties, file)) as ClassValueType;
  }
  final TypeValidator properties;
  final ClassValueType? supertype;
  final List<ClassValueType> subtypes = [];

  Iterable<ClassValueType> get allDescendants => subtypes.expand((element) => element.allDescendants.followedBy([element]));
  MapEntry<ValueType, ClassValueType>? recursiveLookup(Variable v) {
    return properties.igv(v, true) != null ? MapEntry(properties.igv(v, true)!, this) : supertype?.recursiveLookup(v);
  }
}

class GenericFunctionValueType<T> extends ValueType<SydFunction<T>> {
  GenericFunctionValueType.internal(this.returnType, String file)
      : super.internal(sharedSupertype, variables["${returnType}Function"] ??= Variable("${returnType}Function"), file);
  final ValueType returnType;
  factory GenericFunctionValueType(ValueType returnType, String file) {
    return (ValueType.types[variables["${returnType}Function"] ??= Variable("${returnType}Function")] ??=
        GenericFunctionValueType<T>.internal(returnType, file)) as GenericFunctionValueType<T>;
  }
  @override
  bool isSubtypeOf(final ValueType possibleParent) {
    return super.isSubtypeOf(possibleParent) || ((possibleParent is GenericFunctionValueType) && returnType.isSubtypeOf(possibleParent.returnType));
  }

  GenericFunctionValueType withReturnType(ValueType rt, String file) {
    return GenericFunctionValueType(rt, file);
  }
}

class IterableValueType<T, RT extends Iterable<T>> extends ValueType<RT> {
  IterableValueType.internal(this.genericParameter, String file)
      : super.internal(sharedSupertype, variables["${genericParameter}Iterable"] ??= Variable("${genericParameter}Iterable"), file);
  factory IterableValueType(ValueType genericParameter, String file) {
    return ValueType.types[variables["${genericParameter}Iterable"] ??= Variable("${genericParameter}Iterable")] as IterableValueType<T, RT>? ??
        IterableValueType<T, RT>.internal(genericParameter, file);
  }
  final ValueType genericParameter;
  @override
  bool isSubtypeOf(ValueType possibleParent) {
    return super.isSubtypeOf(possibleParent) || (possibleParent is IterableValueType && genericParameter.isSubtypeOf(possibleParent.genericParameter));
  }
}

class IteratorValueType<T> extends ValueType<Iterator<T>> {
  IteratorValueType.internal(this.genericParameter, String file)
      : super.internal(sharedSupertype, variables["${genericParameter}Iterator"] ??= Variable("${genericParameter}Iterator"), file);
  factory IteratorValueType(ValueType genericParameter, String file) {
    return ValueType.types[variables["${genericParameter}Iterator"] ??= Variable("${genericParameter}Iterator")] as IteratorValueType<T>? ??
        IteratorValueType<T>.internal(genericParameter, file);
  }
  final ValueType genericParameter;
  @override
  bool isSubtypeOf(ValueType possibleParent) {
    return super.isSubtypeOf(possibleParent) || (possibleParent is IteratorValueType && genericParameter.isSubtypeOf(possibleParent.genericParameter));
  }
}

class ListValueType<T> extends IterableValueType<T, List<T>> {
  ListValueType.internal(this.genericParameter, String file) : super.internal(IterableValueType(genericParameter, file), file);
  late Variable name = variables["${genericParameter}List"] ??= Variable("${genericParameter}List");
  factory ListValueType(ValueType genericParameter, String file) {
    return ValueType.types[variables["${genericParameter}List"] ??= Variable("${genericParameter}List")] as ListValueType<T>? ??
        ListValueType<T>.internal(genericParameter, file);
  }
  final ValueType genericParameter;
  @override
  bool isSubtypeOf(ValueType possibleParent) {
    return name == possibleParent.name ||
        (parent != null && parent!.isSubtypeOf(possibleParent)) ||
        (possibleParent is IterableValueType && genericParameter == possibleParent.genericParameter) ||
        (possibleParent is NullableValueType && isSubtypeOf(possibleParent.genericParam));
  }
}

class Parameter {
  final ValueType type;
  final Variable name;

  String toString() => "$type $name";

  Parameter(this.type, this.name);
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

class LazyString {}

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

typedef SydFunction<T extends Object?> = ValueWrapper<T> Function(List<ValueWrapper> args, List<LazyString>, [Scope?, ValueType?]);

class Scope {
  Scope(this.isClass, {this.intrinsics, Scope? parent, required this.stack, this.declaringClass, required this.debugName, this.typeIfClass})
      : parents = [if (parent != null) parent];
  final LazyString debugName;
  final List<Scope> parents;
  final List<LazyString> stack;
  final Scope? intrinsics;

  final ClassValueType? declaringClass;
  final bool isClass;
  final ClassValueType? typeIfClass;

  ClassValueType get currentClass {
    Scope node = this;
    while (node.declaringClass == null && !node.isClass) {
      if (node.parents.isEmpty) {
        throw BSCException("Called super expression outside class (in $this)");
      }
      node = node.parents.first;
    }
    return node.declaringClass ?? node.typeIfClass!;
  }

  String toString() {
    try {
      return toStringWithStack([NotLazyString('internal error')], -2, 0, 'interr', 'interr');
    } on SydException catch (e) {
      return 'ToString fail - debugName: $debugName (error: $e)';
    }
  }

  String toStringWithStack(List<LazyString> stack2, int line, int col, String workspace, String file) {
    return values.containsKey(variables['toString'])
        ? values[variables['toString']]!
            .valueC<SydFunction>(this, stack2 + [NotLazyString("implicit toString")], line, col, workspace, file)
            (<ValueWrapper>[], stack2 + [NotLazyString("implicit toString")])
            .valueC(this, stack2 + [NotLazyString("implicit toString")], line, col, workspace, file)
        : "<${values[variables['className']]?.valueC(this, stack2, line, col, workspace, file) ?? '($debugName: stack: $stack)'}>";
  }

  final Map<Variable, ValueWrapper> values = {};

  void setVar(Variable name, List<int> subscripts, ValueWrapper value, int line, int col, String workspace, String file) {
    if (!values.containsKey(name)) {
      for (Scope parent in parents) {
        if (parent.internal_getVar(name) != null) {
          parent.setVar(name, subscripts, value, line, col, workspace, file);
          return;
        }
      }
    }
    if (subscripts.length == 0) {
      values[name] = value;
    } else {
      if (!values.containsKey(name)) throw BSCException("attempted $name${subscripts.map((e) => '[$e]').join()} = $value but $name did not exist");
      List<ValueWrapper> list = values[name]!.valueC(this, stack, line, col, workspace, file);
      while (subscripts.length > 1) {
        list = list[subscripts.first].valueC(this, stack, line, col, workspace, file);
        subscripts.removeAt(0);
      }
      list[subscripts.single] = value;
    }
  }

  ValueWrapper? internal_getVar(Variable name) {
    if (values[name] != null) {
      return values[name];
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
            ? (throw BSCException("class ${name.name} has not yet been defined ${formatCursorPosition(line, column, workspace, file)}"))
            : (throw BSCException("${name.name} nonexistent ${formatCursorPosition(line, column, workspace, file)} ${stack.reversed.join("\n")}")));
  }

  void addParent(Scope scope) {
    parents.add(scope);
  }
}

class FunctionValueType<T extends Object?> extends GenericFunctionValueType<T> {
  Iterable<ValueType> parameters;
  ValueType returnType;
  late final String stringParams = parameters.toString();
  late final Variable name = variables["${returnType}Function(${stringParams.substring(1, stringParams.length - 1)})"] ??=
      Variable("${returnType}Function(${stringParams.substring(1, stringParams.length - 1)})");

  FunctionValueType.internal(this.returnType, this.parameters, String file) : super.internal(returnType, file);
  FunctionValueType withReturnType(ValueType rt, String file) {
    return FunctionValueType(rt, parameters, file);
  }

  factory FunctionValueType(ValueType returnType, Iterable<ValueType> parameters, String file) {
    return ValueType.types[variables["${returnType}Function(${parameters.toString().substring(1, parameters.toString().length - 1)})"] ??=
        Variable("${returnType}Function(${parameters.toString().substring(1, parameters.toString().length - 1)})")] = ValueType.types[
            variables["${returnType}Function(${parameters.toString().substring(1, parameters.toString().length - 1)})"] ??=
                Variable("${returnType}Function(${parameters.toString().substring(1, parameters.toString().length - 1)})")] as FunctionValueType<T>? ??
        FunctionValueType<T>.internal(returnType, parameters, file);
  }
  @override
  bool isSubtypeOf(ValueType possibleParent) {
    if (super.isSubtypeOf(possibleParent)) {
      return true;
    }
    if (possibleParent is! FunctionValueType) {
      return false;
    }
    if (!returnType.isSubtypeOf(possibleParent.returnType)) {
      return false;
    }
    if (possibleParent.parameters is InfiniteIterable || parameters is InfiniteIterable) {
      if (possibleParent.parameters is! InfiniteIterable || parameters is! InfiniteIterable) return false;
    } else if (parameters.length != possibleParent.parameters.length) {
      return false;
    }
    int i = 0;
    return possibleParent.parameters.every(
      (element) => element.isSubtypeOf(parameters.elementAt(i++)),
    );
  }
}

final ValueType sharedSupertype = ValueType.internal(null, variables['Anything']!, 'intrinsics');
final ValueType<int> integerType = ValueType.internal(sharedSupertype, variables['Integer']!, 'intrinsics');
final ValueType<String> stringType = ValueType.internal(sharedSupertype, variables['String']!, 'intrinsics');
final ValueType<bool> booleanType = ValueType.internal(sharedSupertype, variables['Boolean']!, 'intrinsics');
final ValueType<Null> nullType = ValueType.internal(sharedSupertype, variables['Null']!, 'intrinsics');

ValueType basicTypes(Variable name, ValueType? parent, int line, int col, String workspace, String file) {
  switch (name) {
    case whateverVariable:
    case classMethodsVariable:
      return ValueType.internal(parent, name, file);
    default:
      throw BSCException("'${name.name}' type doesn't exist ${formatCursorPosition(line, col, workspace, file)}");
  }
}

List<T> parseArgList<T>(TokenIterator tokens, T Function(TokenIterator) parseArg) {
  tokens.expectChar(TokenType.openParen);
  List<T> params = [];
  while (tokens.current is! CharToken || tokens.currentChar != TokenType.closeParen) {
    params.add(parseArg(tokens));
    if (tokens.currentChar != TokenType.closeParen) {
      tokens.expectChar(TokenType.comma);
    }
  }
  tokens.expectChar(TokenType.closeParen);
  return params;
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
    // waiting for someone to use
    throw UnimplementedError();
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
      // xxx should we call for all elements or is just one fine?
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

class InfiniteIterator<T> extends Iterator<T> {
  final T value;

  InfiniteIterator(this.value);

  @override
  T get current => value;

  @override
  bool moveNext() {
    return true;
  }
}

String toStringWithStacker(ValueWrapper x, List<LazyString> s, int line, int col, String workspace, String file) {
  if (x.typeC(null, s, line, col, workspace, file) is ClassValueType) {
    return x.valueC<Scope>(null, s, line, col, workspace, file).toStringWithStack(s, line, col, workspace, file);
  } else {
    return x.valueC(null, s, line, col, workspace, file).toString();
  }
}
