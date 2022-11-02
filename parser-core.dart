import 'lexer.dart';

Map<String, TypeValidator> loadedGlobalScopes = {};

class TypeValidator {
  TypeValidator(this.parent);
  final TypeValidator? parent;
  Map<String, TypeValidator> classes = {};
  List<String> nonconst = [];
  ValueType get currentClass =>
      types['this'] ?? (throw FileInvalid("Super called outside class"));
  Map<String, ValueType> types = {
    "true": booleanType,
    "false": booleanType,
    "null": nullType,
    "print": FunctionValueType(
        integerType, InfiniteIterable(sharedSupertype), 'intrinsics'),
    "stderr": FunctionValueType(
        integerType, InfiniteIterable(sharedSupertype), 'intrinsics'),
    "concat": FunctionValueType(
        stringType, InfiniteIterable(sharedSupertype), 'intrinsics'),
    "parseInt": FunctionValueType(integerType, [stringType], 'intrinsics'),
    'addLists': FunctionValueType(
        ListValueType(sharedSupertype, 'intrinsics'),
        InfiniteIterable(ListValueType(
            ValueType(null, "Whatever", -2, 0, 'interr', 'intrinsics'),
            'intrinsics')),
        'intrinsics'),
    'charsOf': FunctionValueType(IterableValueType(stringType, 'intrinsics'),
        [stringType], 'intrinsics'),
    'scalarValues': FunctionValueType(
        IterableValueType(integerType, 'intrinsics'),
        [stringType],
        'intrinsics'),
    'len': FunctionValueType(
        integerType,
        [
          ListValueType(
              ValueType(null, "Whatever", -2, 0, 'interr', 'intrinsics'),
              'intrinsics')
        ],
        'intrinsics'),
    'input': FunctionValueType(stringType, [], 'intrinsics'),
    'append': FunctionValueType(
        sharedSupertype,
        [
          ListValueType(
              ValueType(null, "Whatever", -2, 0, 'interr', 'intrinsics'),
              'intrinsics'),
          sharedSupertype
        ],
        'intrinsics'),
    'iterator': FunctionValueType(
        IteratorValueType(sharedSupertype, 'intrinsics'),
        [
          IterableValueType(
              ValueType(null, "Whatever", -2, 0, 'interr', 'intrinsics'),
              'intrinsics')
        ],
        'intrinsics'),
    'next': FunctionValueType(booleanType,
        [IteratorValueType(sharedSupertype, 'intrinsics')], 'intrinsics'),
    'current': FunctionValueType(sharedSupertype,
        [IteratorValueType(sharedSupertype, 'intrinsics')], 'intrinsics'),
    'stringTimes':
        FunctionValueType(stringType, [stringType, integerType], 'intrinsics'),
    'copy': FunctionValueType(
        ListValueType(
            ValueType(null, "Whatever", -2, 0, 'interr', 'intrinsics'),
            'intrinsics'),
        [
          IterableValueType(
              ValueType(null, "Whatever", -2, 0, 'interr', 'intrinsics'),
              'intrinsics')
        ],
        'intrinsics'),
    'first': FunctionValueType(
        sharedSupertype,
        [
          IterableValueType(
              ValueType(null, "Whatever", -2, 0, 'interr', 'intrinsics'),
              'intrinsics')
        ],
        'intrinsics'),
    'last': FunctionValueType(
        sharedSupertype,
        [
          IterableValueType(
              ValueType(null, "Whatever", -2, 0, 'interr', 'intrinsics'),
              'intrinsics')
        ],
        'intrinsics'),
    'single': FunctionValueType(
        sharedSupertype,
        [
          IterableValueType(
              ValueType(null, "Whatever", -2, 0, 'interr', 'intrinsics'),
              'intrinsics')
        ],
        'intrinsics'),
    'hex': FunctionValueType(stringType, [integerType], 'intrinsics'),
    'chr': FunctionValueType(stringType, [integerType], 'intrinsics'),
    'exit': FunctionValueType(nullType, [integerType], 'intrinsics'),
    'readFile': FunctionValueType(stringType, [stringType], 'intrinsics'),
    'readFileBytes': FunctionValueType(
        ListValueType(integerType, 'intrinsics'), [stringType], 'intrinsics'),
    'println': FunctionValueType(
        integerType, InfiniteIterable(sharedSupertype), 'intrinsics'),
    'throw': FunctionValueType(nullType, [stringType], 'intrinsics'),
    'cast': FunctionValueType(
        ValueType(null, "Whatever", -2, 0, 'interr', 'intrinsics'),
        [sharedSupertype],
        'intrinsics'),
    'joinList': FunctionValueType(
        stringType,
        [
          ListValueType(
              ValueType(null, "Whatever", -2, 0, 'interr', 'intrinsics'),
              'intrinsics')
        ],
        'intrinsics'),
    'className': stringType,
    'pop': FunctionValueType(nullType, [], 'intrinsics'),
    'substring': FunctionValueType(
        stringType, [stringType, integerType, integerType], 'intrinsics'),
    'sublist': FunctionValueType(
        ListValueType(
            ValueType(null, "Whatever", -2, 0, 'interr', 'intrinsics'),
            'intrinsics'),
        [
          ListValueType(
              ValueType(null, "Whatever", -2, 0, 'interr', 'intrinsics'),
              'intrinsics'),
          integerType,
          integerType
        ],
        'intrinsics'),
    'stackTrace': FunctionValueType(stringType, [], 'intrinsics'),
  };

  List<String> directVars = ['true', 'false', 'null'];

  List<String> usedVars = [];

  void setVar(String name, int subscripts, ValueType value, int line, int col,
      String workspace, String file) {
    if (!types.containsKey(name)) {
      throw FileInvalid(
          "Cannot assign to $name, an undeclared variable ${formatCursorPosition(line, col, workspace, file)}");
    }
    if (!nonconst.contains(name) && subscripts == 0) {
      throw FileInvalid(
        "Cannot reassign $name ${formatCursorPosition(line, col, workspace, file)}",
      );
    }
    int oldSubs = subscripts;
    ValueType type = types[name]!;
    while (subscripts > 0) {
      if (type is! ListValueType) {
        throw FileInvalid(
          "Expected a list, got $type when trying to subscript $name ${formatCursorPosition(line, col, workspace, file)}",
        );
      }
      type = type.genericParameter;
      subscripts--;
    }
    if (!value.isSubtypeOf(type)) {
      throw FileInvalid(
        "Expected $type, got $value while setting $name${"[...]" * oldSubs} to $value ${formatCursorPosition(line, col, workspace, file)}",
      );
    }
  }

  void newVar(String name, ValueType type, int line, int col, String workspace,
      String file,
      [bool constant = false]) {
    if (directVars.contains(name)) {
      throw FileInvalid(
        'Attempted redeclare of existing variable $name ${formatCursorPosition(line, col, workspace, file)}',
      );
    }
    types[name] = type;
    directVars.add(name);
    if (!constant) {
      nonconst.add(name);
    }
  }

  ValueType getVar(String name, int subscripts, int line, int col,
      String workspace, String file, String context) {
    ValueType? realtype = types[name];
    if (realtype == null) {
      String? filename;
      for (MapEntry<String, TypeValidator> e in loadedGlobalScopes.entries) {
        if (e.value.types.containsKey(name)) {
          filename = e.key;
        }
      }
      throw FileInvalid(
          "Attempted to retrieve $name ($context), which is undefined. ${filename == null ? '' : '(maybe you meant to import $filename?) '}${formatCursorPosition(line, col, workspace, file)}");
    } else {
      usedVars.add(name);
      if (parent?.types.containsKey(name) ?? false) {
        parent!.getVar(name, subscripts, line, col, workspace, file, 'error');
      }
    }
    while (subscripts > 0) {
      if (realtype is! ListValueType) {
        throw FileInvalid(
          "Expected a list, but got $realtype when trying to subscript $name ${formatCursorPosition(line, col, workspace, file)}",
        );
      }
      realtype = realtype.genericParameter;
      subscripts--;
    }
    return realtype!;
  }

  TypeValidator copy() {
    return TypeValidator(parent)
      ..types = Map.of(types)
      ..nonconst = nonconst.toList();
  }
}

void throwWithStack(Scope scope, List<String> stack, String value) {
  ValueWrapper thrower = scope.getVar(
      'throw', -2, 0, 'in throwWithStack', 'while throwing $value', null);
  thrower._value([ValueWrapper(stringType, value, 'string to throw')], stack);
}

class ValueWrapper {
  final ValueType? _type;
  final dynamic _value;
  final String debugCreationDescription;
  final bool canBeRead;
  ValueType typeC(Scope? scope, List<String> stack, int line, int col,
      String workspace, String filename) {
    if (canBeRead) {
      return _type!;
    } else {
      return valueC(scope, stack, line, col, workspace, filename);
    }
  }

  dynamic valueC(Scope? scope, List<String> stack, int line, int col,
      String workspace, String filename) {
    if (canBeRead) {
      return _value;
    } else {
      scope == null
          ? (throw FileInvalid(
              "$debugCreationDescription was attempted to be read while uninititalized ${formatCursorPosition(line, col, workspace, filename)}\n${stack.reversed.join('\n')}"))
          : throwWithStack(
              scope,
              stack,
              "$debugCreationDescription was attempted to be read while uninititalized ${formatCursorPosition(line, col, workspace, filename)}",
            );
      throw (FileInvalid('internal error: throw did not exit'));
    }
  }

  ValueWrapper(this._type, this._value, this.debugCreationDescription,
      [this.canBeRead = true]);

  String toString() => toStringWithStack(
      ['internal error: ValueWrapper.toString() called'],
      -2,
      0,
      'interr',
      'interrr');

  String toStringWithStack(
      List<String> s, int line, int col, String workspace, String file) {
    return _value is Function
        ? "<function ($debugCreationDescription)>"
        : toStringWithStacker(this, s, line, col, workspace, file);
  }
}

class NamespaceScope implements Scope {
  final Scope deferTarget;
  final String namespace;

  NamespaceScope(this.deferTarget, this.namespace);

  @override
  Map<String, ValueWrapper> get values =>
      throw UnsupportedError("NamespaceScope.values");

  @override
  void addParent(Scope scope) {
    deferTarget.addParent(scope);
  }

  @override
  ClassValueType get currentClass => deferTarget.currentClass;

  @override
  String get debugName => 'namespace $namespace of $deferTarget';

  @override
  ClassValueType? get declaringClass => deferTarget.declaringClass;

  @override
  ValueWrapper getVar(String name, int line, int column, String workspace,
      String file, TypeValidator? validator) {
    ValueWrapper? val = internal_getVar(name);
    if (val == null) throw FileInvalid('TODO');
    return val;
  }

  @override
  ValueWrapper? internal_getVar(String name) {
    // TODO: implement internal_getVar
    throw UnimplementedError();
  }

  @override
  // TODO: implement intrinsics
  Scope? get intrinsics => throw UnimplementedError();

  @override
  // TODO: implement parents
  List<Scope> get parents => throw UnimplementedError();

  @override
  void setVar(String name, List<int> subscripts, ValueWrapper value, int line,
      int col, String workspace, String file) {
    // TODO: implement setVar
  }

  @override
  // TODO: implement stack
  List<String> get stack => throw UnimplementedError();

  @override
  String toStringWithStack(
      List<String> stack2, int line, int col, String workspace, String file) {
    // TODO: implement toStringWithStack
    throw UnimplementedError();
  }
}

Map<String, int> fileTypes = {};

class ValueType {
  final ValueType? parent;
  final String name;

  String toString() => name;
  bool operator ==(x) =>
      x is ValueType && this.isSubtypeOf(x) && x.isSubtypeOf(this);

  ValueType.internal(this.parent, this.name, String file) {
    if (types[name] != null) {
      throw FileInvalid("Repeated creation of $name");
    }
    types[name] = this;
    fileTypes[file] = (fileTypes[file] ?? 0) + 1;
  }
  static final Map<String, ValueType> types = {};
  factory ValueType(ValueType? parent, String name, int line, int col,
      String workspace, String file) {
    return types[name] ??
        (name.endsWith("Iterable")
            ? IterableValueType(
                ValueType(
                  sharedSupertype,
                  name.substring(0, name.length - 8),
                  line,
                  col,
                  workspace,
                  file,
                ),
                file,
              )
            : name.endsWith("Iterator")
                ? IteratorValueType(
                    ValueType(
                      sharedSupertype,
                      name.substring(0, name.length - 8),
                      line,
                      col,
                      workspace,
                      file,
                    ),
                    file,
                  )
                : name.endsWith("List")
                    ? ListValueType(
                        ValueType(
                          sharedSupertype,
                          name.substring(0, name.length - 4),
                          line,
                          col,
                          workspace,
                          file,
                        ),
                        file,
                      )
                    : name.endsWith("Function")
                        ? GenericFunctionValueType(
                            ValueType(
                              sharedSupertype,
                              name.substring(0, name.length - 8),
                              line,
                              col,
                              workspace,
                              file,
                            ),
                            file,
                          )
                        : name.endsWith("Nullable")
                            ? NullableValueType(
                                name.substring(0, name.length - 8),
                                ValueType(
                                  sharedSupertype,
                                  name.substring(0, name.length - 8),
                                  line,
                                  col,
                                  workspace,
                                  file,
                                ),
                                file)
                            : basicTypes(
                                name, parent, line, col, workspace, file));
  }
  bool isSubtypeOf(ValueType possibleParent) {
    var bool = name == possibleParent.name ||
        (parent != null && parent!.isSubtypeOf(possibleParent)) ||
        name == 'Whatever' ||
        possibleParent.name == 'Whatever' ||
        (name == 'Null' && possibleParent is NullableValueType) ||
        (possibleParent is NullableValueType &&
            isSubtypeOf(possibleParent.genericParam));
    return bool;
  }

  GenericFunctionValueType withReturnType(ValueType x, String file) {
    throw UnimplementedError("err");
  }
}

class NullableValueType extends ValueType {
  final ValueType genericParam;

  NullableValueType(String name, this.genericParam, String file)
      : super.internal(sharedSupertype, name + 'Nullable', file);

  bool isSubtypeOf(ValueType other) {
    return super.isSubtypeOf(other) ||
        (other is NullableValueType &&
            genericParam.isSubtypeOf(other.genericParam));
  }
}

class ClassValueType extends ValueType {
  ClassValueType.internal(
      String name, this.supertype, this.properties, String file)
      : super.internal(supertype ?? sharedSupertype, "$name", file);
  factory ClassValueType(String name, ClassValueType? supertype,
      TypeValidator properties, String file) {
    return (ValueType.types[name] ??=
            ClassValueType.internal(name, supertype, properties, file))
        as ClassValueType;
  }
  final TypeValidator properties;
  final ClassValueType? supertype;
  final List<ClassValueType> subtypes = [];

  Iterable<ClassValueType> get allDescendants => subtypes
      .expand((element) => element.allDescendants.followedBy([element]));
  ValueType? recursiveLookup(String v) {
    return properties.types[v] ?? supertype?.recursiveLookup(v);
  }
}

class GenericFunctionValueType extends ValueType {
  GenericFunctionValueType.internal(this.returnType, String file)
      : super.internal(sharedSupertype, "${returnType}Function", file);
  final ValueType returnType;
  factory GenericFunctionValueType(ValueType returnType, String file) {
    return (ValueType.types["${returnType}Function"] ??=
            GenericFunctionValueType.internal(returnType, file))
        as GenericFunctionValueType;
  }
  @override
  bool isSubtypeOf(final ValueType possibleParent) {
    return super.isSubtypeOf(possibleParent) ||
        ((possibleParent is! FunctionValueType &&
                possibleParent is GenericFunctionValueType) &&
            returnType.isSubtypeOf(possibleParent.returnType));
  }

  GenericFunctionValueType withReturnType(ValueType rt, String file) {
    return GenericFunctionValueType(rt, file);
  }
}

class IterableValueType extends ValueType {
  IterableValueType.internal(this.genericParameter, String file)
      : super.internal(sharedSupertype, "${genericParameter}Iterable", file);
  factory IterableValueType(ValueType genericParameter, String file) {
    return ValueType.types["${genericParameter}Iterable"]
            as IterableValueType? ??
        IterableValueType.internal(genericParameter, file);
  }
  final ValueType genericParameter;
  @override
  bool isSubtypeOf(ValueType possibleParent) {
    return super.isSubtypeOf(possibleParent) ||
        (possibleParent is IterableValueType &&
            genericParameter.isSubtypeOf(possibleParent.genericParameter));
  }
}

class IteratorValueType extends ValueType {
  IteratorValueType.internal(this.genericParameter, String file)
      : super.internal(sharedSupertype, "${genericParameter}Iterator", file);
  factory IteratorValueType(ValueType genericParameter, String file) {
    return ValueType.types["${genericParameter}Iterator"]
            as IteratorValueType? ??
        IteratorValueType.internal(genericParameter, file);
  }
  final ValueType genericParameter;
  @override
  bool isSubtypeOf(ValueType possibleParent) {
    return super.isSubtypeOf(possibleParent) ||
        (possibleParent is IteratorValueType &&
            genericParameter.isSubtypeOf(possibleParent.genericParameter));
  }
}

class ListValueType extends IterableValueType {
  ListValueType.internal(this.genericParameter, String file)
      : super.internal(IterableValueType(genericParameter, file), file);
  String get name => "${genericParameter}List";
  factory ListValueType(ValueType genericParameter, String file) {
    return ValueType.types["${genericParameter}List"] as ListValueType? ??
        ListValueType.internal(genericParameter, file);
  }
  final ValueType genericParameter;
  @override
  bool isSubtypeOf(ValueType possibleParent) {
    return name == possibleParent.name ||
        (parent != null && parent!.isSubtypeOf(possibleParent)) ||
        (possibleParent is IterableValueType &&
            genericParameter == possibleParent.genericParameter) ||
        (possibleParent is NullableValueType &&
            isSubtypeOf(possibleParent.genericParam));
  }
}

class Parameter {
  final ValueType type;
  final String name;

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

  StatementResult(this.type, [this.value]);
}

class StrWrapper {
  String toString() => x;
  final String x;

  StrWrapper(this.x);
}

class Scope {
  Scope(
      {this.intrinsics,
      Scope? parent,
      required this.stack,
      this.declaringClass,
      required this.debugName})
      : parents = [if (parent != null) parent];
  final String debugName;
  final List<Scope> parents;
  final List<String> stack;
  final Scope? intrinsics;

  final ClassValueType? declaringClass;

  ClassValueType get currentClass {
    Scope node = this;
    while (node.declaringClass == null) {
      if (node.parents.isEmpty) {
        throw FileInvalid("Internal error A");
      }
      node = node.parents.first;
    }
    return node.declaringClass!;
  }

  String toString() =>
      toStringWithStack(['internal error'], -2, 0, 'interr', 'interr');

  String toStringWithStack(
      List<String> stack2, int line, int col, String workspace, String file) {
    return values.containsKey('toString')
        ? values['toString']!
            .valueC(this, stack2 + ["implicit toString"], line, col, workspace,
                file)(<ValueWrapper>[], stack2 + ["implicit toString"])
            .value
            .valueC(this, stack2 + ["implicit toString"], line, col, workspace,
                file)
        : "<${values['className']?.valueC(this, stack2, line, col, workspace, file) ?? '($debugName: stack: $stack)'}>";
  }

  final Map<String, ValueWrapper> values = {};
  static final Map<String, ValueType> tv_types = TypeValidator(null).types;
  void setVar(String name, List<int> subscripts, ValueWrapper value, int line,
      int col, String workspace, String file) {
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
      if (!values.containsKey(name))
        throw FileInvalid(
            "attempted $name${subscripts.map((e) => '[$e]').join()} = $value but $name did not exist");
      List<ValueWrapper> list =
          values[name]!.valueC(this, stack, line, col, workspace, file);
      while (subscripts.length > 1) {
        list = list[subscripts.first]
            .valueC(this, stack, line, col, workspace, file);
        subscripts.removeAt(0);
      }
      list[subscripts.single] = value;
    }
  }

  ValueWrapper? internal_getVar(String name) {
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

  ValueWrapper getVar(String name, int line, int column, String workspace,
      String file, TypeValidator? validator) {
    var val = internal_getVar(name);
    return val ??
        (validator?.classes.containsKey(name) ?? false
            ? (throw FileInvalid(
                "class $name has not yet been defined ${formatCursorPosition(line, column, workspace, file)}"))
            : (throw FileInvalid(
                "$name nonexistent ${formatCursorPosition(line, column, workspace, file)}")));
  }

  void addParent(Scope scope) {
    parents.add(scope);
  }
}

class FunctionValueType extends GenericFunctionValueType {
  Iterable<ValueType> parameters;
  ValueType returnType;
  late final String stringParams = parameters.toString();
  late final String name =
      "${returnType}Function(${stringParams.substring(1, stringParams.length - 1)})";

  FunctionValueType.internal(this.returnType, this.parameters, String file)
      : super.internal(returnType, file);
  FunctionValueType withReturnType(ValueType rt, String file) {
    return FunctionValueType(rt, parameters, file);
  }

  factory FunctionValueType(
      ValueType returnType, Iterable<ValueType> parameters, String file) {
    String str = parameters.toString();
    return ValueType.types[
            "${returnType}Function(${str.substring(1, str.length - 1)})"] =
        ValueType.types[
                    "${returnType}Function(${str.substring(1, str.length - 1)})"]
                as FunctionValueType? ??
            FunctionValueType.internal(returnType, parameters, file);
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
    if (possibleParent.parameters is InfiniteIterable ||
        parameters is InfiniteIterable) {
      if (possibleParent.parameters is! InfiniteIterable ||
          parameters is! InfiniteIterable) return false;
    } else if (parameters.length != possibleParent.parameters.length) {
      return false;
    }
    int i = 0;
    return possibleParent.parameters.every(
      (element) => element.isSubtypeOf(parameters.elementAt(i++)),
    );
  }
}

final ValueType sharedSupertype =
    ValueType.internal(null, 'Anything', 'intrinsics');
final ValueType integerType =
    ValueType.internal(sharedSupertype, 'Integer', 'intrinsics');
final ValueType stringType =
    ValueType.internal(sharedSupertype, 'String', 'intrinsics');
final ValueType booleanType =
    ValueType.internal(sharedSupertype, 'Boolean', 'intrinsics');
final ValueType nullType =
    ValueType.internal(sharedSupertype, 'Null', 'intrinsics');

ValueType basicTypes(String name, ValueType? parent, int line, int col,
    String workspace, String file) {
  switch (name) {
    case 'Whatever':
    case '~class_methods':
      return ValueType.internal(parent, name, file);
    default:
      throw FileInvalid(
          "'$name' type doesn't exist ${formatCursorPosition(line, col, workspace, file)}");
  }
}

List<T> parseArgList<T>(
    TokenIterator tokens, T Function(TokenIterator) parseArg) {
  tokens.expectChar(TokenType.openParen);
  List<T> params = [];
  while (tokens.current is! CharToken ||
      tokens.currentChar != TokenType.closeParen) {
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
    // TODO: implement any
    throw UnimplementedError();
  }

  @override
  Iterable<R> cast<R>() {
    // TODO: implement cast
    throw UnimplementedError();
  }

  @override
  bool contains(Object? element) {
    // TODO: implement contains
    throw UnimplementedError();
  }

  @override
  E elementAt(int index) {
    return value;
  }

  @override
  bool every(bool Function(E element) test) {
    // TODO: implement every
    throw UnimplementedError();
  }

  @override
  Iterable<T> expand<T>(Iterable<T> Function(E element) toElements) {
    // TODO: implement expand
    throw UnimplementedError();
  }

  @override
  E get first => value;

  @override
  E firstWhere(bool Function(E element) test, {E Function()? orElse}) {
    // TODO: implement firstWhere
    throw UnimplementedError();
  }

  @override
  T fold<T>(T initialValue, T Function(T previousValue, E element) combine) {
    // TODO: implement fold
    throw UnimplementedError();
  }

  @override
  Iterable<E> followedBy(Iterable<E> other) {
    throw UnsupportedError("$InfiniteIterable cannot be followed by anything");
  }

  @override
  void forEach(void Function(E element) action) {
    throw UnsupportedError("$InfiniteIterable iteration goes on forever");
  }

  @override
  // TODO: implement isEmpty
  bool get isEmpty => throw UnimplementedError();

  @override
  // TODO: implement isNotEmpty
  bool get isNotEmpty => throw UnimplementedError();

  @override
  String join([String separator = ""]) {
    throw UnsupportedError("$InfiniteIterable cannot be joined together");
  }

  @override
  // TODO: implement last
  E get last => throw UnimplementedError();

  @override
  E lastWhere(bool Function(E element) test, {E Function()? orElse}) {
    // TODO: implement lastWhere
    throw UnimplementedError();
  }

  @override
  // TODO: implement length
  int get length => throw UnsupportedError("$this got length called on it");

  @override
  E reduce(E Function(E value, E element) combine) {
    throw UnsupportedError("$InfiniteIterable cannot be reduced");
  }

  @override
  // TODO: implement single
  E get single => throw StateError(
      "$InfiniteIterable has more than one element when calling 'single'");

  @override
  E singleWhere(bool Function(E element) test, {E Function()? orElse}) {
    throw UnsupportedError("$InfiniteIterable.singleWhere");
  }

  @override
  Iterable<E> skip(int count) {
    // TODO: implement skip
    throw UnimplementedError();
  }

  @override
  Iterable<E> skipWhile(bool Function(E value) test) {
    // TODO: implement skipWhile
    throw UnimplementedError();
  }

  @override
  Iterable<E> take(int count) {
    // TODO: implement take
    throw UnimplementedError();
  }

  @override
  Iterable<E> takeWhile(bool Function(E value) test) {
    // TODO: implement takeWhile
    throw UnimplementedError();
  }

  @override
  List<E> toList({bool growable = true}) {
    throw StateError("$InfiniteIterable cannot be converted to $List<$E>");
  }

  @override
  Set<E> toSet() {
    throw StateError("$InfiniteIterable cannot be converted to $Set<$E>");
  }

  @override
  Iterable<E> where(bool Function(E element) test) {
    // TODO: implement where
    throw UnimplementedError();
  }

  @override
  Iterable<T> whereType<T>() {
    // TODO: implement whereType
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

String toStringWithStacker(ValueWrapper x, List<String> s, int line, int col,
    String workspace, String file) {
  if (x.typeC(null, s, line, col, workspace, file) is ClassValueType) {
    return x
        .valueC(null, s, line, col, workspace, file)
        .toStringWithStack(s, line, col, workspace, file);
  } else {
    return x.valueC(null, s, line, col, workspace, file).toString();
  }
}
