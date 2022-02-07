import 'lexer.dart';

class TypeValidator {
  Map<String, TypeValidator> classes = {};
  List<String> nonconst = [];
  ValueType get currentClass =>
      types['this'] ?? (throw FileInvalid("Super called outside class"));
  Map<String, ValueType> types = {
    "true": booleanType,
    "false": booleanType,
    "null": ValueType(sharedSupertype, 'Null', 0, 0, 'rtl'),
    "print": FunctionValueType(
        integerType, InfiniteIterable(sharedSupertype), 'rtl'),
    "stderr": FunctionValueType(
        integerType, InfiniteIterable(sharedSupertype), 'rtl'),
    "concat":
        FunctionValueType(stringType, InfiniteIterable(sharedSupertype), 'rtl'),
    "parseInt": FunctionValueType(integerType, [stringType], 'rtl'),
    'addLists': FunctionValueType(ListValueType(sharedSupertype, 'rtl'),
        InfiniteIterable(ListValueType(sharedSupertype, 'rtl')), 'rtl'),
    'charsOf': FunctionValueType(
        IterableValueType(stringType, 'rtl'), [stringType], 'rtl'),
    'scalarValues': FunctionValueType(
        IterableValueType(integerType, 'rtl'), [stringType], 'rtl'),
    'len': FunctionValueType(
        integerType, [ListValueType(sharedSupertype, 'rtl')], 'rtl'),
    'input': FunctionValueType(stringType, [], 'rtl'),
    'append': FunctionValueType(sharedSupertype,
        [ListValueType(sharedSupertype, 'rtl'), sharedSupertype], 'rtl'),
    'iterator': FunctionValueType(IteratorValueType(sharedSupertype, 'rtl'),
        [IterableValueType(sharedSupertype, 'rtl')], 'rtl'),
    'next': FunctionValueType(
        booleanType, [IteratorValueType(sharedSupertype, 'rtl')], 'rtl'),
    'current': FunctionValueType(
        sharedSupertype, [IteratorValueType(sharedSupertype, 'rtl')], 'rtl'),
    'stringTimes':
        FunctionValueType(stringType, [stringType, integerType], 'rtl'),
    'copy': FunctionValueType(ListValueType(sharedSupertype, 'rtl'),
        [IterableValueType(sharedSupertype, 'rtl')], 'rtl'),
    'first': FunctionValueType(
        sharedSupertype, [IterableValueType(sharedSupertype, 'rtl')], 'rtl'),
    'last': FunctionValueType(
        sharedSupertype, [IterableValueType(sharedSupertype, 'rtl')], 'rtl'),
    'single': FunctionValueType(
        sharedSupertype, [IterableValueType(sharedSupertype, 'rtl')], 'rtl'),
    'assert': FunctionValueType(booleanType, [booleanType, stringType], 'rtl'),
    'padLeft': FunctionValueType(
        stringType, [stringType, integerType, stringType], 'rtl'),
    'hex': FunctionValueType(stringType, [integerType], 'rtl'),
    'chr': FunctionValueType(stringType, [integerType], 'rtl'),
    'exit': FunctionValueType(
        ValueType(sharedSupertype, "Null", 0, 0, 'rtl'), [integerType], 'rtl'),
    'readFile': FunctionValueType(stringType, [stringType], 'rtl'),
    'readFileBytes': FunctionValueType(
        ListValueType(integerType, 'rtl'), [stringType], 'rtl'),
    'println': FunctionValueType(
        integerType, InfiniteIterable(sharedSupertype), 'rtl'),
    'throw': FunctionValueType(
        ValueType(sharedSupertype, "Null", 0, 0, 'rtl'), [stringType], 'rtl'),
    'cast': FunctionValueType(
        ValueType(null, "Whatever", 0, 0, 'rtl'), [sharedSupertype], 'rtl'),
    'joinList': FunctionValueType(
        stringType, [ListValueType(sharedSupertype, 'rtl')], 'rtl'),
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
                file,
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
                    file,
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
                        file,
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
                                  file,
                                ),
                                file)
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

  NullableValueType(String name, this.genericParam, String file)
      : super.internal(sharedSupertype, name + 'Nullable', file);

  bool isSubtypeOf(ValueType other) {
    return super.isSubtypeOf(other) ||
        (other is NullableValueType &&
            genericParam.isSubtypeOf(other.genericParam));
  }
}

class ClassValueType extends ValueType {
  ClassValueType(String name, this.supertype, this.properties, String file)
      : super.internal(supertype ?? sharedSupertype, "$name", file);
  final TypeValidator properties;
  final ClassValueType? supertype;
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
            genericParameter.isSubtypeOf(possibleParent.genericParameter));
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

StrWrapper startingValueOfVar = StrWrapper("<uninitialized>");

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

  FunctionValueType.internal(this.returnType, this.parameters, String file)
      : super.internal(returnType, file);

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
      return false; //TODO
    }
    if (parameters.length != possibleParent.parameters.length) {
      return false;
    }
    int i = 0;
    return possibleParent.parameters.every(
      (element) => element.isSubtypeOf(parameters.elementAt(i++)),
    );
  }
}

final ValueType sharedSupertype = ValueType.internal(null, 'Anything', 'rtl');
final ValueType integerType =
    ValueType.internal(sharedSupertype, 'Integer', 'rtl');
final ValueType stringType =
    ValueType.internal(sharedSupertype, 'String', 'rtl');
final ValueType booleanType =
    ValueType.internal(sharedSupertype, 'Boolean', 'rtl');

ValueType basicTypes(
    String name, ValueType? parent, int line, int col, String file) {
  switch (name) {
    case 'Null':
    case 'Dog':
    case 'Whatever':
    case '~class_methods':
    case 'unassigned':
      return ValueType.internal(parent, name, file);
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
