import 'dart:math';

import 'syd-core.dart';

class AssertExpression extends Expression {
  final Expression condition;
  final Expression comment;

  bool isLValue(TypeValidator scope) => false;

  @override
  ValueType get staticType => tv.environment.nullType;

  String toString() => 'assert($condition, $comment)';

  AssertExpression(this.condition, this.comment, TypeValidator tv, int line, int col, String file) : super(line, col, file, tv);
  @override
  Null eval(Scope scope) {
    if (!(scope.intrinsics ?? scope).debugMode!) {
      return null;
    }
    Object? conditionEval = condition.eval(scope);
    if (conditionEval is! bool) {
      throw BSCException(
        'argument 0 of assert, ${toStringWithStacker(conditionEval, line, col, file, false)} ($condition), of wrong type (${getType(conditionEval, scope, line, col, file, false)}) expected boolean ${formatCursorPosition(line, col, file)}\n${scope.environment.stack.reversed.join('\n')}',
        scope,
      );
    }
    if (!conditionEval) {
      Object? commentEval = comment.eval(scope);
      if (!getType(commentEval, scope, line, col, file, false).isSubtypeOf(tv.environment.stringType)) {
        throw BSCException(
          'argument 1 of assert, $commentEval ($comment), of wrong type (${getType(commentEval, scope, line, col, file, false)}) expected string ${formatCursorPosition(line, col, file)}\n${scope.environment.stack.reversed.join('\n')}',
          scope,
        );
      }
      throw AssertException(
        (commentEval as String) + ' ($condition was not true) ${formatCursorPosition(line, col, file)}\n${scope.environment.stack.reversed.join('\n')}',
        scope,
      );
    }
    return null;
  }
}

class GetExpr extends Expression {
  late final List<int> variablePath;
  late final bool _isLValue;
  late final ValueType staticType;
  final Identifier name;

  bool isLValue(TypeValidator scope) => _isLValue; // xxx scope may not be needed

  GetExpr(this.name, TypeValidator tv, int line, col, String file) : super(line, col, file, tv) {
    _isLValue = tv.igvnc(name);
    staticType = tv.getVar(name, line, col, file, 'for a get expression');
    variablePath = tv.findPathFor(name);
    if (name == tv.identifiers['Happy']) {
      print(variablePath);
    }
  }

  void write(Object? value, Scope scope) {
    if (variablePath.first == -1) {
      scope.currentClassScope!.writeToByName(name, value);
    } else if (variablePath.first == -2) {
      scope.environment.globals[name] = value;
    } else {
      scope.writeTo(name, variablePath, value);
    }
  }

  @override
  Object? eval(Scope scope) {
    if (variablePath.first == -1) {
      if (scope.currentClassScope == null) {
        print('${scope.debugName}, ${tv.debugName}, ${tv.parents}');
      }
      return scope.currentClassScope!.getVarByName(name);
    }
    if (variablePath.first == -2) {
      return scope.environment.globals[name];
    }
    return scope.getVar(variablePath);
  }

  String toString() => name.name;
}

class EqualsExpression extends Expression {
  final Expression a;
  final Expression b;

  bool isLValue(TypeValidator scope) => false;

  EqualsExpression(this.a, this.b, TypeValidator tv, int line, int col, String file) : super(line, col, file, tv);
  @override
  bool eval(Scope scope) {
    Object? ea = a.eval(scope);
    Object? eb = b.eval(scope);
    bool result = getType(ea, scope, line, col, file, true) == getType(eb, scope, line, col, file, true) && ea == eb;
    return result;
  }

  String toString() => '$a == $b';

  ValueType get staticType => tv.environment.booleanType;
}

class BitAndExpression extends Expression {
  final Expression a;
  final Expression b;
  bool isLValue(TypeValidator scope) => false;

  BitAndExpression(this.a, this.b, TypeValidator tv, int line, col, String file) : super(line, col, file, tv);
  @override
  Object? eval(Scope scope) {
    int av = a.eval(scope) as int;
    int bv = b.eval(scope) as int;
    return av & bv;
  }

  String toString() => '$a & $b';

  ValueType get staticType => tv.environment.integerType;
}

class BitXorExpression extends Expression {
  final Expression a;
  final Expression b;

  bool isLValue(TypeValidator scope) => false;
  BitXorExpression(this.a, this.b, TypeValidator tv, int line, int col, String file) : super(line, col, file, tv);
  @override
  int eval(Scope scope) {
    int av = a.eval(scope) as int;
    int bv = b.eval(scope) as int;
    return av ^ bv;
  }

  String toString() => '$a ^ $b';

  ValueType get staticType => tv.environment.integerType;
}

class SubscriptExpression extends Expression {
  final Expression a;
  final Expression b;

  bool isLValue(TypeValidator scope) => true;
  ValueType get staticType => a.staticType.name == whateverVariable
      ? ValueType.create(whateverVariable, -2, 0, '_', tv.environment, tv.typeTable)
      : a.staticType is ListValueType
          ? (a.staticType as ListValueType).genericParameter
          : (a.staticType as ArrayValueType).genericParameter;
  String toString() => '$a[$b]';

  SubscriptExpression(this.a, this.b, int line, col, String file, TypeValidator tv) : super(line, col, file, tv);
  @override
  eval(Scope scope) {
    Object? list = a.eval(scope);
    int index = b.eval(scope) as int;
    return fancySubscript(list, index, scope);
  }

  void write(Object? value, Scope scope) {
    Object? listValue = a.eval(scope);
    int index = b.eval(scope) as int;
    Object? listType = getType(listValue, scope, line, col, file, false);
    if (listValue is! SydArray) {
      throw BSCException(
        '$a is not a list ${formatCursorPosition(line, col, file)}\n${scope.environment.stack.reversed.join('\n')}',
        scope,
      );
    }
    if (listType is ArrayValueType) {
      throw BSCException(
        '$a is an array which cannot be modified ${formatCursorPosition(line, col, file)}\n${scope.environment.stack.reversed.join('\n')}',
        scope,
      );
    }
    if (listValue.array.length <= index || index < 0) {
      throw BSCException(
        'RangeError: ${toStringWithStacker(listValue, line, col, file, false)} ($a) has ${listValue.array.length} elements, but it was subscripted with element $index. ${formatCursorPosition(line, col, file)}\n${scope.environment.stack.reversed.join('\n')}',
        scope,
      );
    }
    listValue.array[index] = value;
  }

  Object? fancySubscript(Object? list, int index, Scope scope) {
    if (list is! SydArray) {
      throw BSCException(
        '$a is not list ${formatCursorPosition(line, col, file)}',
        scope,
      );
    }
    if (list.array.length <= index || index < 0) {
      throw BSCException(
        'RangeError: ${toStringWithStacker(list, line, col, file, false)} ($a) has ${list.array.length} elements, but it was subscripted with element $index. ${formatCursorPosition(line, col, file)}\n${scope.environment.stack.reversed.join('\n')}',
        scope,
      );
    }
    return list.array[index];
  }
}

class MemberAccessExpression extends Expression {
  final Expression a;
  final Identifier b;
  bool isLValue(TypeValidator scope) => false;

  late ValueType staticType = () {
    if (a.staticType is ClassOfValueType) {
      return (a.staticType as ClassOfValueType).staticMembers.igv(b, true, line, col, file, true, false)!;
    }
    if (a.staticType is EnumValueType) {
      return (a.staticType as EnumValueType).staticMembers.igv(b, true, line, col, file, false, false)!;
    }
    return a.staticType.name != whateverVariable
        ? (a.staticType as ClassValueType).properties.igv(b, true, line, col, file, true, false)!
        : tv.environment.anythingType;
  }();

  MemberAccessExpression(this.a, this.b, int l, int c, String file, TypeValidator tv) : super(l, c, file, tv);
  @override
  Object? eval(Scope scope) {
    Object? thisScope = a.eval(scope);
    ValueType type2 = getType(thisScope, scope, line, col, file, false);
    if (type2 is! ClassValueType && type2 is! ClassOfValueType && type2 is! EnumValueType) {
      throw BSCException(
        '$thisScope ($a) is not an instance of a class or a class or an enum, it\'s a $type2 ${formatCursorPosition(line, col, file)}\n${scope.environment.stack.reversed.join('\n')}',
        scope,
      );
    }
    if (type2 is ClassOfValueType) {
      thisScope = (thisScope as Class).staticMembers;
    }
    if (type2 is EnumValueType) {
      thisScope = (thisScope as SydEnum).staticMembers;
    }
    return (thisScope as Scope).getVarByName(b);
  }

  String toString() => '$a.${b.name}';
}

class IsExpr extends Expression {
  final Expression operand;
  final ValueType isType;
  bool isLValue(TypeValidator scope) => false;

  IsExpr(this.operand, this.isType, int l, c, String file, TypeValidator tv) : super(l, c, file, tv);

  String toString() => '$operand is $isType';

  ValueType get staticType => tv.environment.booleanType;

  @override
  bool eval(Scope scope) {
    ValueType possibleChildType = getType(operand.eval(scope), scope, line, col, file, true);
    return possibleChildType.isSubtypeOf(isType);
  }
}

class AsExpr extends Expression {
  final Expression operand;
  final ValueType isType;

  bool isLValue(TypeValidator scope) => false;
  AsExpr(this.operand, this.isType, int l, c, String file, TypeValidator tv) : super(l, c, file, tv);

  String toString() => '$operand as $isType';

  late ValueType staticType = isType;

  Object? iterableCast<T extends ValueType<SydIterable>>(Scope scope, ValueType possibleChildType, Object? possibleChildValue) {
    if (possibleChildType is T && isType is T && !possibleChildType.isSubtypeOf(isType)) {
      ValueType genericParameter = (isType as dynamic).genericParameter;
      for (Object? x in (possibleChildValue as SydIterable).iterable) {
        ValueType xType = getType(x, scope, line, col, file, false);
        if (!xType.isSubtypeOf(genericParameter)) {
          throw BSCException(
            '$this had invalid element type; expected $genericParameter got $x (a $xType) ${formatCursorPosition(line, col, file)}',
            scope,
          );
        }
      }
      switch (possibleChildType) {
        case ValueType<SydList>():
          return SydList((possibleChildValue as SydList).list, isType as ListValueType);
        case ValueType<SydArray>():
          return SydArray((possibleChildValue as SydArray).array, isType as ArrayValueType);
        case ValueType<SydIterable>():
          return SydIterable(possibleChildValue.iterable, isType as IterableValueType);
      }
    }
    return null;
  }

  @override
  Object? eval(Scope scope) {
    Object? possibleChildValue = operand.eval(scope);
    ValueType possibleChildType = getType(possibleChildValue, scope, line, col, file, true);
    return iterableCast<IterableValueType>(scope, possibleChildType, possibleChildValue) ??
        iterableCast<ListValueType>(scope, possibleChildType, possibleChildValue) ??
        iterableCast<ArrayValueType>(scope, possibleChildType, possibleChildValue) ??
        () {
          if (!possibleChildType.isSubtypeOf(isType)) {
            throw BSCException(
              'as failed; expected $isType got ${toStringWithStacker(possibleChildValue, line, col, file, false)} (a $possibleChildType) \n${formatCursorPosition(line, col, file)} ${scope.environment.stack.reversed.join('\n')}',
              scope,
            );
          }
          return possibleChildValue;
        }();
  }
}

class NotExpression extends Expression {
  final Expression a;

  bool isLValue(TypeValidator scope) => false;
  NotExpression(this.a, int line, int col, String file, TypeValidator tv) : super(line, col, file, tv);

  String toString() => '!$a';
  @override
  bool eval(Scope scope) {
    bool aEval = a.eval(scope) as bool;
    return !aEval;
  }

  ValueType get staticType => tv.environment.booleanType;
}

class BitNotExpression extends Expression {
  final Expression a;
  bool isLValue(TypeValidator scope) => false;

  BitNotExpression(this.a, int line, int col, String file, TypeValidator tv) : super(line, col, file, tv);
  @override
  int eval(Scope scope) {
    int aEval = a.eval(scope) as int;
    return ~aEval;
  }

  String toString() => '~$a';

  ValueType get staticType => tv.environment.integerType;
}

class TypeOfExpression extends Expression {
  final Expression a;
  bool isLValue(TypeValidator scope) => false;

  TypeOfExpression(this.a, int line, int col, String file, TypeValidator tv) : super(line, col, file, tv);
  @override
  int eval(Scope scope) {
    return getType(a.eval(scope), scope, line, col, file, false).id;
  }

  String toString() => '__typeOf $a';

  ValueType get staticType => tv.environment.integerType;
}

class MultiplyExpression extends Expression {
  final Expression a;
  final Expression b;
  String toString() => '$a * $b';
  bool isLValue(TypeValidator scope) => false;

  MultiplyExpression(this.a, this.b, int line, int col, String file, TypeValidator tv) : super(line, col, file, tv);
  @override
  int eval(Scope scope) {
    Object? aval = a.eval(scope);
    if (aval is! int) {
      throw BSCException(
          '$aval ($a), a ${getType(aval, scope, line, col, file, false)}, is not an integer ${formatCursorPosition(line, col, file)} ${scope.environment.stack.reversed.join('\n')}',
          scope);
    }
    Object? bval = b.eval(scope);
    if (bval is! int) {
      throw BSCException(
          '$bval ($b), a ${getType(bval, scope, line, col, file, false)}, is not an integer ${formatCursorPosition(line, col, file)} ${scope.environment.stack.reversed.join('\n')}',
          scope);
    }
    return aval * bval;
  }

  ValueType get staticType => tv.environment.integerType;
}

class DivideExpression extends Expression {
  final Expression a;
  final Expression b;
  bool isLValue(TypeValidator scope) => false;

  DivideExpression(this.a, this.b, int line, int col, String file, TypeValidator tv) : super(line, col, file, tv);
  @override
  int eval(Scope scope) {
    int av = a.eval(scope) as int;
    int bv = b.eval(scope) as int;
    return av ~/ bv;
  }

  ValueType get staticType => tv.environment.integerType;
}

class PowExpression extends Expression {
  final Expression a;
  final Expression b;
  bool isLValue(TypeValidator scope) => false;

  PowExpression(this.a, this.b, int line, int col, String file, TypeValidator tv) : super(line, col, file, tv);
  @override
  int eval(Scope scope) {
    return pow(
      a.eval(scope) as int,
      b.eval(scope) as int,
    ) as int;
  }

  ValueType get staticType => tv.environment.integerType;
}

class RemainderExpression extends Expression {
  final Expression a;
  final Expression b;
  bool isLValue(TypeValidator scope) => false;

  String toString() => '$a % $b';

  RemainderExpression(this.a, this.b, int line, int col, String file, TypeValidator tv) : super(line, col, file, tv);
  @override
  int eval(Scope scope) {
    int av = a.eval(scope) as int;
    int bv = b.eval(scope) as int;
    if (!(getType(av, scope, line, col, file, false).isSubtypeOf(tv.environment.integerType) &&
        getType(bv, scope, line, col, file, false).isSubtypeOf(tv.environment.integerType))) {
      throw BSCException(
          '$av ($a) or $bv ($b) is not an integer; attempted $a%$b ${formatCursorPosition(line, col, file)}\n ${scope.environment.stack.reversed.join('\n')}',
          scope);
    }
    if (bv == 0) {
      throw BSCException('$a ($av) % $b (0) attempted ${formatCursorPosition(line, col, file)} stack ${scope.environment.stack.reversed.join('\n')}', scope);
    }
    return av % bv;
  }

  ValueType get staticType => tv.environment.integerType;
}

class SubtractExpression extends Expression {
  final Expression a;
  final Expression b;
  bool isLValue(TypeValidator scope) => false;

  SubtractExpression(this.a, this.b, int line, int col, String file, TypeValidator tv) : super(line, col, file, tv);
  @override
  int eval(Scope scope) {
    int av = a.eval(scope) as int;
    int bv = b.eval(scope) as int;
    if (!(getType(av, scope, line, col, file, false).isSubtypeOf(tv.environment.integerType) &&
        getType(bv, scope, line, col, file, false).isSubtypeOf(tv.environment.integerType))) {
      throw BSCException(
          '$av ($a) or $bv ($b) is not an integer; attempted $a-$b ${formatCursorPosition(line, col, file)}\n ${scope.environment.stack.reversed.join('\n')}',
          scope);
    }
    return av - bv;
  }

  String toString() => '($a) - ($b)';

  ValueType get staticType => tv.environment.integerType;
}

class AddExpression extends Expression {
  final Expression a;
  bool isLValue(TypeValidator scope) => false;
  final Expression b;

  AddExpression(this.a, this.b, int line, int col, String file, TypeValidator tv) : super(line, col, file, tv);
  @override
  int eval(Scope scope) {
    int av = a.eval(scope) as int;
    int bv = b.eval(scope) as int;
    if (!(getType(av, scope, line, col, file, false).isSubtypeOf(tv.environment.integerType) &&
        getType(bv, scope, line, col, file, false).isSubtypeOf(tv.environment.integerType))) {
      throw BSCException(
          '${toStringWithStacker(av, line, col, file, false)} ($a) or ${toStringWithStacker(bv, line, col, file, false)} ($b) is not an integer; attempted $a+$b ${formatCursorPosition(line, col, file)}\n ${scope.environment.stack.reversed.join('\n')}',
          scope);
    }
    return av + bv;
  }

  String toString() => '$a + $b';

  ValueType get staticType => tv.environment.integerType;
}

class SuperExpression extends Expression {
  SuperExpression(this.member, int line, int col, String file, this.static, TypeValidator tv) : super(line, col, file, tv);
  final Identifier member;
  final bool static;
  bool isLValue(TypeValidator scope) => false;

  @override
  Object? eval(Scope scope) {
    ClassValueType? classType = scope.currentClass;
    if (classType == null) {
      Scope? staticClass = scope.currentStaticClass;
      if (staticClass == null) {
        throw BSCException('Called super expression outside class\n${scope.environment.stack.reversed.join('\n')}', scope);
      }
      return staticClass.parents.single.getVarByName(member);
    }
    ClassValueType parent = classType;
    Scope superMethods;
    if (classType.supertype == null) {
      throw BSCException('super expression used in a root class', scope);
    }
    do {
      parent = parent.supertype ?? (throw BSCException('super expression failed to find $member in ${classType.supertype!} or supertypes', scope));
      superMethods = parent.methods!;
    } while (!superMethods.directlyContains(member));
    Object? superMethod = superMethods.getVarByName(member);
    FunctionValueType superMethodType = getType(superMethod, scope, line, col, file, false) as FunctionValueType;
    assert(superMethod is SydFunction);
    return SydFunction((List args, [Scope? thisScope, ValueType? thisType]) {
      return (superMethod as SydFunction).function(args, scope.getClass()!, classType);
    }, superMethodType, Concat(parent.name.name, Concat('.', member.name)));
  }

  String toString() => 'super.${member.name}';

  @override
  ValueType get staticType => static
      ? ValueType.create(whateverVariable, 0, 0, '', tv.environment, tv.typeTable)
      : (tv.currentClassType.parent is ClassValueType
              ? tv.currentClassType.parent as ClassValueType
              : (throw BSCException('${tv.currentClassType} has no supertype ${formatCursorPosition(line, col, file)}', tv)))
          .properties
          .igv(member, true, line, col, file, true, false)!;
}

class IntLiteralExpression extends Expression {
  IntLiteralExpression(this.n, int line, int col, String file, TypeValidator tv) : super(line, col, file, tv);
  final int n;
  int eval(Scope scope) => n;
  String toString() => '$n';
  bool isLValue(TypeValidator scope) => false;

  ValueType get staticType => tv.environment.integerType;
}

class StringLiteralExpression extends Expression {
  StringLiteralExpression(this.n, int line, int col, String file, TypeValidator tv) : super(line, col, file, tv);
  final String n;
  String eval(Scope scope) => n;
  String toString() => '\'$n\'';
  ValueType get staticType => tv.environment.stringType;
  bool isLValue(TypeValidator scope) => false;
}

class BoringExpr extends Expression {
  final Object? value;
  bool isLValue(TypeValidator scope) => false;

  final ValueType staticType;

  BoringExpr(this.value, this.staticType, TypeValidator tv) : super(-2, 0, 'TODO (boring expr line,column, filename)', tv);

  @override
  eval(Scope scope) {
    return value;
  }

  String toString() => '$value**';
}

class UnwrapExpression extends Expression {
  UnwrapExpression(this.a, int line, int col, String file, TypeValidator tv) : super(line, col, file, tv);
  final Expression a;
  bool isLValue(TypeValidator scope) => false;
  @override
  Object eval(Scope scope) {
    Object? aval = a.eval(scope);
    if (aval == null) {
      throw BSCException('Failed unwrap of null ($a) ${formatCursorPosition(line, col, file)}\n${scope.environment.stack.reversed.join('\n')}', scope);
    }
    return aval;
  }

  String toString() => '$a!';

  @override
  ValueType get staticType => a.staticType is NullableValueType ? (a.staticType as NullableValueType).genericParam : a.staticType;
}

class FunctionCallExpr extends Expression {
  final Expression a;
  final List<Expression> b;
  bool isLValue(TypeValidator scope) => false;

  final TypeValidator validator;

  @override
  ValueType get staticType {
    if (a.staticType is ClassOfValueType) {
      return (a.staticType as ClassOfValueType).constructor.returnType;
    }
    return a.staticType.name.name != 'Whatever' ? (a.staticType as GenericFunctionValueType).returnType : tv.environment.anythingType;
  }

  String toString() => '$a(${b.join(', ')})';
  late ValueType anythingFunctionType = GenericFunctionValueType(tv.environment.anythingType, 'interr', validator.environment, validator.typeTable);
  FunctionCallExpr(this.a, this.b, this.validator, int line, int col, String file, TypeValidator tv) : super(line, col, file, tv);
  @override
  Object? eval(Scope scope) {
    //print('calling $a...');
    Object? aEval = a.eval(scope);
    if (aEval is Class) {
      aEval = aEval.constructor;
    }
    ValueType type = getType(aEval, scope, line, col, file, false);
    if (!type.isSubtypeOf(anythingFunctionType) && !(type is ClassOfValueType)) {
      throw BSCException('tried to call non-function: $aEval, ${formatCursorPosition(line, col, file)}\n${scope.environment.stack.reversed.join('\n')}', scope);
    }
    List<Object?> args = b.map((x) => x.eval(scope)).toList();
    if (type is FunctionValueType) {
      if (type.parameters is! InfiniteIterable && type.parameters.length != args.length) {
        throw BSCException(
            'tried to call function $aEval with wrong number of arguments: passed in ${args.length} (${args.map((e) => toStringWithStacker(e, line, col, file, false))}), expected ${type.parameters.length} ${formatCursorPosition(line, col, file)}\n${scope.environment.stack.reversed.join('\n')}',
            scope);
      }
      for (int i = 0; i < args.length; i++) {
        if (!getType(args[i], scope, line, col, file, false).isSubtypeOf(type.parameters.elementAt(i))) {
          throw BSCException(
              'argument #$i of $a (${toStringWithStacker(aEval, line, col, file, false)}), ${toStringWithStacker(args[i], line, col, file, false)} (${b[i]}), of wrong type (${getType(args[i], scope, line, col, file, false)}) expected ${type.parameters.elementAt(i)} ${formatCursorPosition(line, col, file)}\n${scope.environment.stack.reversed.join('\n')}',
              scope);
        }
      }
    }
    List<LazyString> stack = scope.environment.stack;
    stack[stack.length - 1] = ConcatenateLazyString(stack.last, CursorPositionLazyString('', line, col, file));
    try {
      Object? result = (aEval as SydFunction).function(args);
      stack[stack.length - 1] = (stack.last as ConcatenateLazyString).left;
      return result;
    } on StackOverflowError {
      throw BSCException('Stack Overflow ${formatCursorPosition(line, col, file)}\n${scope.environment.stack.reversed.join('\n')}', scope);
    }
  }
}

class ListLiteralExpression extends Expression {
  ListLiteralExpression(this.n, this.genParam, int line, int col, String file, TypeValidator tv) : super(line, col, file, tv);
  final List<Expression> n;
  final ValueType genParam;
  ValueType get staticType => ListValueType(genParam, file, tv.environment, tv.typeTable);
  String toString() => '$n:$genParam';
  bool isLValue(TypeValidator scope) => false;
  SydList<Object?> eval(Scope scope) {
    List<Object?> params = n.map((e) => e.eval(scope)).toList();
    for (Object? param in params) {
      if (!getType(param, scope, line, col, file, false).isSubtypeOf(genParam)) {
        throw BSCException(
            'List literal element ${toStringWithStacker(param, line, col, file, false)} (${getType(param, scope, line, col, file, false)}) is not a subtype of $genParam ${formatCursorPosition(line, col, file)}\n${scope.environment.stack.reversed.join('\n')}',
            scope);
      }
    }
    return SydList(
      params,
      ListValueType(genParam, file, tv.environment, tv.typeTable),
    );
  }
}

class ShiftRightExpression extends Expression {
  final Expression a;
  final Expression b;
  bool isLValue(TypeValidator scope) => false;

  String toString() => '$a >> $b';

  ShiftRightExpression(this.a, this.b, int line, int col, String file, TypeValidator tv) : super(line, col, file, tv);
  @override
  int eval(Scope scope) {
    int av = a.eval(scope) as int;
    int bv = b.eval(scope) as int;
    return av >> bv;
  }

  ValueType get staticType => tv.environment.integerType;
}

class ShiftLeftExpression extends Expression {
  final Expression a;
  final Expression b;
  bool isLValue(TypeValidator scope) => false;

  String toString() {
    return '$a << $b';
  }

  ShiftLeftExpression(this.a, this.b, int line, int col, String file, TypeValidator tv) : super(line, col, file, tv);
  @override
  int eval(Scope scope) {
    int av = a.eval(scope) as int;
    int bv = b.eval(scope) as int;
    return av << bv;
  }

  ValueType get staticType => tv.environment.integerType;
}

class GreaterExpression extends Expression {
  final Expression a;
  final Expression b;

  bool isLValue(TypeValidator scope) => false;
  GreaterExpression(this.a, this.b, int line, int col, String file, TypeValidator tv) : super(line, col, file, tv);
  @override
  bool eval(Scope scope) {
    int av = a.eval(scope) as int;
    int bv = b.eval(scope) as int;
    return av > bv;
  }

  String toString() => '$a > $b';

  ValueType get staticType => tv.environment.booleanType;
}

class LessExpression extends Expression {
  final Expression a;
  final Expression b;

  String toString() => '$a < $b';

  bool isLValue(TypeValidator scope) => false;
  LessExpression(this.a, this.b, int line, int col, String file, TypeValidator tv) : super(line, col, file, tv);
  @override
  bool eval(Scope scope) {
    int av = a.eval(scope) as int;
    int bv = b.eval(scope) as int;
    return av < bv;
  }

  ValueType get staticType => tv.environment.booleanType;
}

class BitOrExpression extends Expression {
  final Expression a;
  final Expression b;
  bool isLValue(TypeValidator scope) => false;

  ValueType get staticType => tv.environment.integerType;

  String toString() => '$a | $b';

  BitOrExpression(this.a, this.b, int line, int col, String file, TypeValidator tv) : super(line, col, file, tv);
  @override
  int eval(Scope scope) {
    int av = a.eval(scope) as int;
    int bv = b.eval(scope) as int;
    return av | bv;
  }
}

class AndExpression extends Expression {
  final Expression a;
  final Expression b;

  bool isLValue(TypeValidator scope) => false;
  String toString() => '$a && $b';

  AndExpression(this.a, this.b, int line, int col, String file, TypeValidator tv) : super(line, col, file, tv);
  @override
  bool eval(Scope scope) {
    return a.eval(scope) as bool && b.eval(scope) as bool;
  }

  ValueType get staticType => tv.environment.booleanType;
}

class OrExpression extends Expression {
  final Expression a;
  final Expression b;
  bool isLValue(TypeValidator scope) => false;

  OrExpression(this.a, this.b, int line, int col, String file, TypeValidator tv) : super(line, col, file, tv);
  @override
  bool eval(Scope scope) {
    return a.eval(scope) as bool || b.eval(scope) as bool;
  }

  String toString() => '$a || $b';

  ValueType get staticType => tv.environment.booleanType;
}
