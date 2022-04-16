import 'lexer.dart';

Map<String, TypeValidator> loadedGlobalScopes = {};
String formatCursorPositionFromTokens(TokenIterator tokens) {
  return formatCursorPosition(
      tokens.current.line, tokens.current.col, tokens.file);
}

String formatCursorPosition(int line, int col, String file) {
  return "$file:$line:$col";
}

class TypeValidator {
  Map<String, TypeValidator> classes = {};
  List<String> nonconst = [];
  ValueType get currentClass =>
      types['this'] ?? (throw FileInvalid("Super called outside class"));
  Map<String, ValueType> types = {
    "true": booleanType,
    "false": booleanType,
    "null": ValueType(sharedSupertype, 'Null', -2, 0, 'rtl'),
    "print": FunctionValueType(
        integerType, InfiniteIterable(sharedSupertype), 'rtl'),
    "stderr": FunctionValueType(
        integerType, InfiniteIterable(sharedSupertype), 'rtl'),
    "concat":
        FunctionValueType(stringType, InfiniteIterable(sharedSupertype), 'rtl'),
    "parseInt": FunctionValueType(integerType, [stringType], 'rtl'),
    'addLists': FunctionValueType(
        ListValueType(sharedSupertype, 'rtl'),
        InfiniteIterable(
            ListValueType(ValueType(null, "Whatever", -2, 0, 'rtl'), 'rtl')),
        'rtl'),
    'charsOf': FunctionValueType(
        IterableValueType(stringType, 'rtl'), [stringType], 'rtl'),
    'scalarValues': FunctionValueType(
        IterableValueType(integerType, 'rtl'), [stringType], 'rtl'),
    'len': FunctionValueType(
        integerType,
        [ListValueType(ValueType(null, "Whatever", -2, 0, 'rtl'), 'rtl')],
        'rtl'),
    'input': FunctionValueType(stringType, [], 'rtl'),
    'append': FunctionValueType(
        sharedSupertype,
        [
          ListValueType(ValueType(null, "Whatever", -2, 0, 'rtl'), 'rtl'),
          sharedSupertype
        ],
        'rtl'),
    'iterator': FunctionValueType(
        IteratorValueType(sharedSupertype, 'rtl'),
        [IterableValueType(ValueType(null, "Whatever", -2, 0, 'rtl'), 'rtl')],
        'rtl'),
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
        sharedSupertype,
        [IterableValueType(ValueType(null, "Whatever", -2, 0, 'rtl'), 'rtl')],
        'rtl'),
    'hex': FunctionValueType(stringType, [integerType], 'rtl'),
    'chr': FunctionValueType(stringType, [integerType], 'rtl'),
    'exit': FunctionValueType(
        ValueType(sharedSupertype, "Null", -2, 0, 'rtl'), [integerType], 'rtl'),
    'readFile': FunctionValueType(stringType, [stringType], 'rtl'),
    'readFileBytes': FunctionValueType(
        ListValueType(integerType, 'rtl'), [stringType], 'rtl'),
    'println': FunctionValueType(
        integerType, InfiniteIterable(sharedSupertype), 'rtl'),
    'throw': FunctionValueType(
        ValueType(sharedSupertype, "Null", -2, 0, 'rtl'), [stringType], 'rtl'),
    'cast': FunctionValueType(
        ValueType(null, "Whatever", -2, 0, 'rtl'), [sharedSupertype], 'rtl'),
    'joinList': FunctionValueType(
        stringType,
        [ListValueType(ValueType(null, "Whatever", -2, 0, 'rtl'), 'rtl')],
        'rtl'),
    'className': stringType,
  };

  List<String> directVars = ['true', 'false', 'null'];

  void setVar(String name, int subscripts, ValueType value, int line, int col,
      String file) {
    if (!types.containsKey(name)) {
      throw FileInvalid(
          "Cannot assign to $name, an undeclared variable ${formatCursorPosition(line, col, file)}");
    }
    if (!nonconst.contains(name) && subscripts == 0) {
      throw FileInvalid(
        "Cannot reassign $name ${formatCursorPosition(line, col, file)}",
      );
    }
    int oldSubs = subscripts;
    ValueType type = types[name]!;
    while (subscripts > 0) {
      if (type is! ListValueType) {
        throw FileInvalid(
          "Expected a list, got $type when trying to subscript $name ${formatCursorPosition(line, col, file)}",
        );
      }
      type = type.genericParameter;
      subscripts--;
    }
    if (!value.isSubtypeOf(type)) {
      print(value);
      print(type);
      throw FileInvalid(
        "Expected $type, got $value while setting $name${"[...]" * oldSubs} to $value ${formatCursorPosition(line, col, file)}",
      );
    }
  }

  void newVar(String name, ValueType type, int line, int col, String file,
      [bool constant = false]) {
    if (directVars.contains(name)) {
      throw FileInvalid(
        'Attempted redeclare of existing variable $name ${formatCursorPosition(line, col, file)}',
      );
    }
    types[name] = type;
    directVars.add(name);
    if (!constant) {
      nonconst.add(name);
    }
  }

  ValueType getVar(
      String name, int subscripts, int line, int col, String file) {
    ValueType? realtype = types[name];
    if (realtype == null) {
      String? filename;
      for (MapEntry<String, TypeValidator> e in loadedGlobalScopes.entries) {
        if (e.value.types.containsKey(name)) {
          filename = e.key;
        }
      }
      throw FileInvalid(
          "Attempted to retrieve $name, which is undefined. ${filename == null ? '' : '(maybe you meant to import $filename?) '}${formatCursorPosition(line, col, file)}");
    }
    while (subscripts > 0) {
      if (realtype is! ListValueType) {
        throw FileInvalid(
          "Expected a list, but got $realtype when trying to subscript $name ${formatCursorPosition(line, col, file)}",
        );
      }
      realtype = realtype.genericParameter;
      subscripts--;
    }
    return realtype!;
  }

  TypeValidator copy() {
    return TypeValidator()
      ..types = Map.of(types)
      ..nonconst = nonconst.toList();
  }
}

void throwWithStack(Scope scope, List<String> stack, String value) {
  ValueWrapper thrower = scope.getVar('throw', -2, 0, 'while throwing $value');
  thrower._value([ValueWrapper(stringType, value, 'string to throw')], stack);
}

class ValueWrapper {
  final ValueType? _type;
  final dynamic _value;
  final String debugCreationDescription;
  final bool canBeRead;
  ValueType typeC(Scope? scope, List<String> stack) {
    if (canBeRead) {
      return _type!;
    } else {
      return valueC(scope, stack);
    }
  }

  dynamic valueC(Scope? scope, List<String> stack, [bool readingType = false]) {
    if (canBeRead) {
      return _value;
    } else {
      scope == null
          ? (throw FileInvalid(
              "$debugCreationDescription was attempted to be read while unititalized (reading type: $readingType)\n${stack.reversed.join('\n')}"))
          : throwWithStack(
              scope,
              stack,
              "$debugCreationDescription was attempted to be read while unititalized (reading type: $readingType)",
            );
      assert(false, 'throw did not exit');
    }
  }

  ValueWrapper(this._type, this._value, this.debugCreationDescription,
      [this.canBeRead = true]);

  String toString() =>
      toStringWithStack(['internal error: ValueWrapper.toString() called']);

  String toStringWithStack(List<String> s) {
    return _value is Function
        ? "<function ($debugCreationDescription)>"
        : toStringWithStacker(this, s);
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
  ClassValueType.internal(
      String name, this.supertype, this.properties, String file)
      : super.internal(supertype ?? sharedSupertype, "$name", file);
  factory ClassValueType(String name, ClassValueType? supertype,
      TypeValidator properties, String file) {
    return (ValueType.types["$name"] ??=
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

  String toString() => toStringWithStack(['internal error']);

  String toStringWithStack(List<String> stack2) {
    return values.containsKey('toString')
        ? values['toString']!
            .valueC(this, stack2 + ["implicit toString"])
            (<ValueWrapper>[], stack2 + ["implicit toString"])
            .value
            .valueC(this, stack2 + ["implicit toString"])
        : "<${values['className']?.valueC(this, stack2) ?? '(instance of class: stack: $stack)'}>";
  }

  Map<String, ValueWrapper> values = {};
  static final Map<String, ValueType> tv_types = TypeValidator().types;
  void setVar(String name, List<int> subscripts, ValueWrapper value) {
    if (!values.containsKey(name) && parent?.internal_getVar(name) != null) {
      parent!.setVar(name, subscripts, value);
      return;
    }
    if (subscripts.length == 0) {
      values[name] = value;
    } else {
      if (!values.containsKey(name))
        throw FileInvalid(
            "attempted $name${subscripts.map((e) => '[$e]').join()} = $value but $name did not exist");
      List<ValueWrapper> list = values[name]!.valueC(this, stack);
      while (subscripts.length > 1) {
        list = list[subscripts.first].valueC(this, stack);
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
            "$name nonexistent ${formatCursorPosition(line, column, file)}"));
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
    case 'Whatever':
    case '~class_methods':
    case 'unassigned':
      return ValueType.internal(parent, name, file);
    default:
      throw FileInvalid(
          "'$name' type doesn't exist ${formatCursorPosition(line, col, file)}");
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

String toStringWithStacker(ValueWrapper x, List<String> s) {
  if (x.typeC(null, s) is ClassValueType) {
    return x.valueC(null, s).toStringWithStack(s);
  } else {
    return x.valueC(null, s).toString();
  }
}
