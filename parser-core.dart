import 'lexer.dart';

class TypeValidator {
  Map<String, TypeValidator> classes = {};
  List<String> nonconst = [];
  ValueType get currentClass =>
      types['this'] ?? (throw FileInvalid("Super called outside class"));
  Map<String, ValueType> types = {
    "true": booleanType,
    "false": booleanType,
    "null": ValueType(sharedSupertype, 'Null', 0, 0, 'internalintrnl'),
    "print": FunctionValueType(integerType, InfiniteIterable(sharedSupertype)),
    "stderr": FunctionValueType(integerType, InfiniteIterable(sharedSupertype)),
    "concat": FunctionValueType(stringType, InfiniteIterable(sharedSupertype)),
    "parseInt": FunctionValueType(integerType, [stringType]),
    'addLists': FunctionValueType(ListValueType(sharedSupertype),
        InfiniteIterable(ListValueType(sharedSupertype))),
    'charsOf': FunctionValueType(IterableValueType(stringType), [stringType]),
    'scalarValues':
        FunctionValueType(IterableValueType(integerType), [stringType]),
    'len': FunctionValueType(integerType, [ListValueType(sharedSupertype)]),
    'input': FunctionValueType(stringType, []),
    'append': FunctionValueType(
        sharedSupertype, [ListValueType(sharedSupertype), sharedSupertype]),
    'iterator': FunctionValueType(IteratorValueType(sharedSupertype),
        [IterableValueType(sharedSupertype)]),
    'next':
        FunctionValueType(booleanType, [IteratorValueType(sharedSupertype)]),
    'current': FunctionValueType(
        sharedSupertype, [IteratorValueType(sharedSupertype)]),
    'stringTimes': FunctionValueType(stringType, [stringType, integerType]),
    'copy': FunctionValueType(
        ListValueType(sharedSupertype), [IterableValueType(sharedSupertype)]),
    'first': FunctionValueType(
        sharedSupertype, [IterableValueType(sharedSupertype)]),
    'last': FunctionValueType(
        sharedSupertype, [IterableValueType(sharedSupertype)]),
    'single': FunctionValueType(
        sharedSupertype, [IterableValueType(sharedSupertype)]),
    'assert': FunctionValueType(booleanType, [booleanType, stringType]),
    'padLeft':
        FunctionValueType(stringType, [stringType, integerType, stringType]),
    'hex': FunctionValueType(stringType, [integerType]),
    'chr': FunctionValueType(stringType, [integerType]),
    'exit': FunctionValueType(
        ValueType(sharedSupertype, "Cat", 0, 0, 'internl'), [integerType]),
    'readFile': FunctionValueType(stringType, [stringType]),
    'readFileBytes':
        FunctionValueType(ListValueType(integerType), [stringType]),
    'println':
        FunctionValueType(integerType, InfiniteIterable(sharedSupertype)),
    'throw': FunctionValueType(
        ValueType(sharedSupertype, "Cat", 0, 0, 'intrnal'), [stringType]),
    'cast': FunctionValueType(
        ValueType(null, "Whatever", 0, 0, 'internalinternal'),
        [sharedSupertype]),
    'joinList': FunctionValueType(stringType, [ListValueType(sharedSupertype)]),
    'gv': FunctionValueType(
        ValueType(sharedSupertype, "Cat", 0, 0, 'internal'), [stringType]),
    'className': stringType,
  };

  List<String> directVars = ['true', 'false', 'null'];

  void setVar(String name, int subscripts, ValueType value, int line, int col,
      String file) {
    if (!nonconst.contains(name) && subscripts == 0) {
      throw FileInvalid("Cannot reassign $name (line $line column $col $file)");
    }
    int oldSubs = subscripts;
    if (!types.containsKey(name)) {
      throw FileInvalid(
          "$name nonexistent on line $line column $col file $file");
    }
    ValueType type = types[name]!;
    while (subscripts > 0) {
      if (type is! ListValueType) {
        throw FileInvalid(
          "Expected a list, got $type on line $line column $col file $file",
        );
      }
      type = type.genericParameter;
      subscripts--;
    }
    if (!value.isSubtypeOf(type)) {
      throw FileInvalid(
          "Expected $type, got $value while setting $name${"[...]" * oldSubs} to $value on line $line column $col file $file");
    }
  }

  void newVar(String name, ValueType type, int line, int col, String file,
      [bool constant = false]) {
    if (directVars.contains(name)) {
      throw FileInvalid(
          "$name already exists! (line $line, column $col, $file)");
    }
    types[name] = type;
    directVars.add(name);
    if (!constant) {
      nonconst.add(name);
    }
  }

  void getVar(String name, int subscripts, ValueType type, int line, int col,
      String file) {
    ValueType? realtype = types[name];
    if (realtype == null) {
      throw FileInvalid(
          "$name nonexistent on line $line column $col file $file");
    }
    while (subscripts > 0) {
      if (realtype is! ListValueType) {
        throw FileInvalid(
          "Expected a list, but got $realtype on line $line column $col file $file",
        );
      }
      realtype = realtype.genericParameter;
      subscripts--;
    }
    if (!realtype!.isSubtypeOf(type)) {
      throw FileInvalid(
        "Expected $type, got $realtype on line $line column $col file $file",
      );
    }
  }
}

class ValueWrapper {
  final ValueType type;
  final dynamic value;
  final String debugCreationDescription;

  ValueWrapper(this.type, this.value, this.debugCreationDescription);

  String toString() =>
      value is Function ? "<function ($debugCreationDescription)>" : "$value";
}

class ValueType {
  final ValueType? parent;
  final String name;

  String toString() => name;
  bool operator ==(x) =>
      x is ValueType && this.isSubtypeOf(x) && x.isSubtypeOf(this);

  ValueType.internal(this.parent, this.name) {
    if (types[name] != null) {
      throw FileInvalid("Repeated creation of $name");
    }
    types[name] = this;
  }
  static final Map<String, ValueType> types = {};
  factory ValueType(
      ValueType? parent, String name, int line, int col, String file) {
    return types[name] ??
        (name.endsWith("Iterable")
            ? IterableValueType(
                ValueType(
                  sharedSupertype,
                  name.substring(0, name.length - 8),
                  line,
                  col,
                  file,
                ),
              )
            : name.endsWith("Iterator")
                ? IteratorValueType(
                    ValueType(
                      sharedSupertype,
                      name.substring(0, name.length - 8),
                      line,
                      col,
                      file,
                    ),
                  )
                : name.endsWith("List")
                    ? ListValueType(
                        ValueType(
                          sharedSupertype,
                          name.substring(0, name.length - 4),
                          line,
                          col,
                          file,
                        ),
                      )
                    : name.endsWith("Function")
                        ? GenericFunctionValueType(
                            ValueType(
                              sharedSupertype,
                              name.substring(0, name.length - 8),
                              line,
                              col,
                              file,
                            ),
                          )
                        : name.endsWith("Nullable")
                            ? NullableValueType(
                                name.substring(0, name.length - 8),
                                ValueType(
                                  sharedSupertype,
                                  name.substring(0, name.length - 8),
                                  line,
                                  col,
                                  file,
                                ),
                              )
                            : basicTypes(name, parent, line, col, file));
  }
  bool isSubtypeOf(ValueType possibleParent) {
    var bool = this.name == possibleParent.name ||
        (parent != null && parent!.isSubtypeOf(possibleParent)) ||
        name == 'Whatever' ||
        possibleParent.name == 'Whatever' ||
        (name == 'Null' && possibleParent is NullableValueType) ||
        (possibleParent is NullableValueType &&
            isSubtypeOf(possibleParent.genericParam));
    return bool;
  }
}

class NullableValueType extends ValueType {
  final ValueType genericParam;

  NullableValueType(String name, this.genericParam)
      : super.internal(sharedSupertype, name + 'Nullable');

  bool isSubtypeOf(ValueType other) {
    return super.isSubtypeOf(other) ||
        (other is NullableValueType &&
            genericParam.isSubtypeOf(other.genericParam));
  }
}

class ClassValueType extends ValueType {
  ClassValueType(String name, this.supertype, this.properties)
      : super.internal(supertype ?? sharedSupertype, "$name");
  final TypeValidator properties;
  final ClassValueType? supertype;
  ValueType? recursiveLookup(String v) {
    return properties.types[v] ?? supertype?.recursiveLookup(v);
  }
}

class GenericFunctionValueType extends ValueType {
  GenericFunctionValueType.internal(this.returnType)
      : super.internal(sharedSupertype, "${returnType}Function");
  final ValueType returnType;
  factory GenericFunctionValueType(ValueType returnType) {
    return (ValueType.types["${returnType}Function"] ??=
            GenericFunctionValueType.internal(returnType))
        as GenericFunctionValueType;
  }
  @override
  bool isSubtypeOf(final ValueType possibleParent) {
    if (possibleParent is GenericFunctionValueType) {}
    return super.isSubtypeOf(possibleParent) ||
        ((possibleParent is GenericFunctionValueType) &&
            returnType.isSubtypeOf(possibleParent.returnType));
  }
}

class IterableValueType extends ValueType {
  IterableValueType.internal(this.genericParameter)
      : super.internal(sharedSupertype, "${genericParameter}Iterable");
  factory IterableValueType(ValueType genericParameter) {
    return ValueType.types["${genericParameter}Iterable"]
            as IterableValueType? ??
        IterableValueType.internal(genericParameter);
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
  IteratorValueType.internal(this.genericParameter)
      : super.internal(sharedSupertype, "${genericParameter}Iterator");
  factory IteratorValueType(ValueType genericParameter) {
    return ValueType.types["${genericParameter}Iterator"]
            as IteratorValueType? ??
        IteratorValueType.internal(genericParameter);
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
  ListValueType.internal(this.genericParameter)
      : super.internal(IterableValueType(genericParameter));
  String get name => "${genericParameter}List";
  factory ListValueType(ValueType genericParameter) {
    return ValueType.types["${genericParameter}List"] as ListValueType? ??
        ListValueType.internal(genericParameter);
  }
  final ValueType genericParameter;
  @override
  bool isSubtypeOf(ValueType possibleParent) {
    return name == possibleParent.name ||
        (parent != null && parent!.isSubtypeOf(possibleParent)) ||
        (possibleParent is IterableValueType &&
            genericParameter.isSubtypeOf(possibleParent.genericParameter));
  }
}

class Parameter {
  final ValueType type;
  final String name;

  String toString() => "$type $name";

  Parameter(this.type, this.name);
}

enum StatementResultType { nothing, breakWhile, continueWhile, returnFunction }

class StatementResult {
  final StatementResultType type;
  final ValueWrapper? value;

  StatementResult(this.type, [this.value]);
}

Object startingValueOfVar = Object();
Object notInScope = Object();

class Scope {
  Scope({this.parent, required this.stack, this.declaringClass});

  final Scope? parent;
  final List<String> stack;

  final ClassValueType? declaringClass;

  ClassValueType get currentClass {
    Scope node = this;
    while (node.declaringClass == null) {
      node = node.parent ?? (throw FileInvalid("Internal error A"));
    }
    return node.declaringClass!;
  }

  String toString() => values.containsKey('toString')
      ? values['toString']!.value(<ValueWrapper>[], ["toString"]).value.value
      : "<${values['className']?.value ?? 'instance of class'}>";

  Map<String, ValueWrapper> values = {};
  static final Map<String, ValueType> tv_types = TypeValidator().types;
  void setVar(String name, List<int> subscripts, ValueWrapper value) {
    if (parent?.internal_getVar(name) != null) {
      parent!.setVar(name, subscripts, value);
      return;
    }
    if (subscripts.length == 0) {
      values[name] = value;
    } else {
      if (!values.containsKey(name))
        throw FileInvalid(
            "attempted $name${subscripts.map((e) => '[$e]').join()} = $value but $name did not exist");
      List<ValueWrapper> list = values[name]!.value;
      while (subscripts.length > 1) {
        list = list[subscripts.first].value;
        subscripts.removeAt(0);
      }
      list[subscripts.single] = value;
    }
  }

  ValueWrapper? internal_getVar(String name) {
    return values[name] ?? parent?.internal_getVar(name);
  }

  ValueWrapper getVar(String name, int line, int column, String file) {
    var val = internal_getVar(name);
    return val ??
        (throw FileInvalid(
            "$name nonexistent line $line column $column file $file"));
  }

  Scope copy() {
    return Scope(stack: this.stack, parent: parent)..values = Map.of(values);
  }
}

class FunctionValueType extends GenericFunctionValueType {
  Iterable<ValueType> parameters;
  ValueType returnType;
  late final String stringParams = parameters.toString();
  late final String name =
      "${returnType}Function(${stringParams.substring(1, stringParams.length - 1)})";

  FunctionValueType.internal(this.returnType, this.parameters)
      : super.internal(returnType);

  factory FunctionValueType(
      ValueType returnType, Iterable<ValueType> parameters) {
    String str = parameters.toString();
    return ValueType.types[
            "${returnType}Function(${str.substring(1, str.length - 1)})"] =
        ValueType.types[
                    "${returnType}Function(${str.substring(1, str.length - 1)})"]
                as FunctionValueType? ??
            FunctionValueType.internal(returnType, parameters);
  }
  @override
  bool isSubtypeOf(ValueType possibleParent) {
    int i = 0;
    bool parentOk = super.isSubtypeOf(possibleParent);
    if (!parentOk) {}
    return possibleParent == parent ||
        parentOk &&
            (possibleParent is! FunctionValueType ||
                (possibleParent.parameters is InfiniteIterable
                    ? parameters is InfiniteIterable &&
                        parameters.first == possibleParent.parameters.first
                    : (parameters.length == possibleParent.parameters.length ||
                            parameters is InfiniteIterable) &&
                        (possibleParent.parameters.every((element) =>
                            parameters.elementAt(i++).isSubtypeOf(element)))));
  }
}

final ValueType sharedSupertype = ValueType.internal(
  null,
  'Anything',
);
final ValueType integerType = ValueType.internal(
  sharedSupertype,
  'Integer',
);
final ValueType stringType = ValueType.internal(
  sharedSupertype,
  'String',
);
final ValueType booleanType = ValueType.internal(
  sharedSupertype,
  'Boolean',
);

ValueType basicTypes(
    String name, ValueType? parent, int line, int col, String file) {
  switch (name) {
    case 'Null':
    case 'Cat':
    case 'Dog':
    case 'Whatever':
    case '~class_methods':
    case 'unassigned':
      return ValueType.internal(parent, name);
    default:
      throw FileInvalid(
          "'$name' type doesn't exist (line $line col $col file $file)");
  }
}

class InfiniteIterable<T> extends Iterable<T> {
  InfiniteIterable(this.value);

  final T value;

  @override
  InfiniteIterator<T> get iterator => InfiniteIterator<T>(value);
}

class InfiniteIterator<T> extends Iterator<T> {
  final T value;

  InfiniteIterator(this.value);

  @override
  T get current => value;

  @override
  bool moveNext() => true;
}
