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
        'argument 0 of assert, ${toStringWithStacker(conditionEval, scope.stack, line, col, file, false, scope.environment)} ($condition), of wrong type (${getType(conditionEval, scope, line, col, file)}) expected boolean ${formatCursorPosition(line, col, file)}\n${scope.stack.reversed.join('\n')}',
        scope,
      );
    }
    if (!conditionEval) {
      Object? commentEval = comment.eval(scope);
      if (!getType(commentEval, scope, line, col, file).isSubtypeOf(tv.environment.stringType)) {
        throw BSCException(
          'argument 1 of assert, $commentEval ($comment), of wrong type (${getType(commentEval, scope, line, col, file)}) expected string ${formatCursorPosition(line, col, file)}\n${scope.stack.reversed.join('\n')}',
          scope,
        );
      }
      throw AssertException(
        (commentEval as String) + ' ($condition was not true) ${formatCursorPosition(line, col, file)}\n${scope.stack.reversed.join('\n')}',
        scope,
      );
    }
    return null;
  }
}

class GetExpr extends Expression {
  final Variable name;
  late final ValueType staticType;

  bool isLValue(TypeValidator scope) => tv.igvnc(name); // xxx scope may not be needed

  GetExpr(this.name, TypeValidator tv, int line, col, String file) : super(line, col, file, tv) {
    staticType = tv.getVar(name, line, col, file, 'for a get expression', true);
  }

  void write(Object? value, bool isConstant, Scope scope) {
    if (scope.values[name]?.isConstant ?? false) {
      throw BSCException(
        'Cannot write to constant variable ${name.name} ${formatCursorPosition(line, col, file)} ${scope.stack.reversed.join('\n')}',
        scope,
      );
    }
    if (scope.values.containsKey(name)) {
      if (!getType(value, scope, line, col, file).isSubtypeOf(staticType)) {
        // xxx shadowed variables
        throw BSCException(
            'Tried to assign ${toStringWithStacker(value, scope.stack, line, col, file, false, scope.environment)} to ${name.name} but the new type, ${getType(value, scope, line, col, file)}, is not a subtype of the variable\'s type, $staticType ${formatCursorPosition(line, col, file)}',
            scope);
      }
      scope.values[name] = MaybeConstantValueWrapper(value, isConstant);
      return;
    } else {
      for (Scope parent in scope.parents) {
        if (parent.recursiveContains(name)) {
          write(value, isConstant, parent);
          return;
        }
      }
    }
    throw BSCException(
      'Tried to write to nonexistent variable ${name.name} ${scope.recursiveContains(name)} ${formatCursorPosition(line, col, file)} ${scope.stack.reversed.join('\n')}',
      scope,
    );
  }

  @override
  ValueType get asType => ValueType.create(tv.environment.anythingType, name, line, col, file, tv);

  @override
  eval(Scope scope) {
    return scope.getVar(name, line, col, file, tv);
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
    bool result = getType(ea, scope, line, col, file) == getType(eb, scope, line, col, file) && ea == eb;
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
      ? ValueType.create(null, whateverVariable, -2, 0, '_', tv)
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

  void write(Object? value, bool isConstant, Scope scope) {
    Object? listValue = a.eval(scope);
    int index = b.eval(scope) as int;
    Object? listType = getType(listValue, scope, line, col, file);
    if (listValue is! SydList) {
      throw BSCException(
        '$a is not a list ${formatCursorPosition(line, col, file)}\n${scope.stack.reversed.join('\n')}',
        scope,
      );
    }
    if (listType is ArrayValueType) {
      throw BSCException(
        '$a is an array which cannot be modified ${formatCursorPosition(line, col, file)}\n${scope.stack.reversed.join('\n')}',
        scope,
      );
    }
    if (listValue.list.length <= index || index < 0) {
      throw BSCException(
        'RangeError: ${toStringWithStacker(listValue, scope.stack, line, col, file, false, scope.environment)} ($a) has ${listValue.list.length} elements, but it was subscripted with element $index. ${formatCursorPosition(line, col, file)}\n${scope.stack.reversed.join('\n')}',
        scope,
      );
    }
    listValue.list[index] = value;
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
        'RangeError: ${toStringWithStacker(list, scope.stack, line, col, file, false, scope.environment)} ($a) has ${list.array.length} elements, but it was subscripted with element $index. ${formatCursorPosition(line, col, file)}\n${scope.stack.reversed.join('\n')}',
        scope,
      );
    }
    return list.array[index];
  }
}

class MemberAccessExpression extends Expression {
  final Expression a;
  final Variable b;
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
  eval(Scope scope) {
    Object? thisScopeWrapper = a.eval(scope);
    ValueType type2 = getType(thisScopeWrapper, scope, line, col, file);
    if (type2 is! ClassValueType && type2 is! ClassOfValueType && type2 is! EnumValueType) {
      throw BSCException(
        '$thisScopeWrapper ($a) is not an instance of a class or a class or an enum, it\'s a $type2 ${formatCursorPosition(line, col, file)}\n${scope.stack.reversed.join('\n')}',
        scope,
      );
    }
    Object? thisThing = thisScopeWrapper;
    if (type2 is ClassOfValueType) {
      thisThing = (thisThing as Class).staticMembers;
    }
    if (type2 is EnumValueType) {
      thisThing = (thisThing as SydEnum).staticMembers;
    }
    Scope thisScope = thisThing as Scope;
    return thisScope.getVar(b, line, col, file, null);
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
    ValueType possibleChildType = getType(operand.eval(scope), scope, line, col, file);
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
        ValueType xType = getType(x, scope, line, col, file);
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
    ValueType possibleChildType = getType(possibleChildValue, scope, line, col, file);
    return iterableCast<IterableValueType>(scope, possibleChildType, possibleChildValue) ??
        iterableCast<ListValueType>(scope, possibleChildType, possibleChildValue) ??
        iterableCast<ArrayValueType>(scope, possibleChildType, possibleChildValue) ??
        () {
          if (!possibleChildType.isSubtypeOf(isType)) {
            throw BSCException(
              'as failed; expected $isType got ${toStringWithStacker(possibleChildValue, scope.stack, line, col, file, false, scope.environment)} (a $possibleChildType) \n${formatCursorPosition(line, col, file)} ${scope.stack.reversed.join('\n')}',
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
    return getType(a.eval(scope), scope, line, col, file).id;
  }

  String toString() => '~$a';

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
    int aEval = a.eval(scope) as int;
    int bEval = b.eval(scope) as int;
    return aEval * bEval;
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
    if (!(getType(av, scope, line, col, file).isSubtypeOf(tv.environment.integerType) &&
        getType(bv, scope, line, col, file).isSubtypeOf(tv.environment.integerType))) {
      throw BSCException(
          '$av ($a) or $bv ($b) is not an integer; attempted $a%$b ${formatCursorPosition(line, col, file)}\n ${scope.stack.reversed.join('\n')}', scope);
    }
    if (bv == 0) {
      throw BSCException('$a ($av) % $b (0) attempted ${formatCursorPosition(line, col, file)} stack ${scope.stack.join('\n')}', scope);
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
    if (!(getType(av, scope, line, col, file).isSubtypeOf(tv.environment.integerType) &&
        getType(bv, scope, line, col, file).isSubtypeOf(tv.environment.integerType))) {
      throw BSCException(
          '$av ($a) or $bv ($b) is not an integer; attempted $a-$b ${formatCursorPosition(line, col, file)}\n ${scope.stack.reversed.join('\n')}', scope);
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
    if (!(getType(av, scope, line, col, file).isSubtypeOf(tv.environment.integerType) &&
        getType(bv, scope, line, col, file).isSubtypeOf(tv.environment.integerType))) {
      throw BSCException(
          '${toStringWithStacker(av, scope.stack, line, col, file, false, scope.environment)} ($a) or ${toStringWithStacker(bv, scope.stack, line, col, file, false, scope.environment)} ($b) is not an integer; attempted $a+$b ${formatCursorPosition(line, col, file)}\n ${scope.stack.reversed.join('\n')}',
          scope);
    }
    return av + bv;
  }

  String toString() => '$a + $b';

  ValueType get staticType => tv.environment.integerType;
}

class SuperExpression extends Expression {
  SuperExpression(this.member, int line, int col, String file, this.static, TypeValidator tv) : super(line, col, file, tv);
  final Variable member;
  final bool static;
  bool isLValue(TypeValidator scope) => false;

  @override
  Object? eval(Scope scope) {
    // throw BSCException('Called super expression outside class\n${stack.reversed.join('\n')}', scope);
    ClassValueType? classType = scope.currentClass;
    if (classType == null) {
      Scope? staticClass = scope.currentStaticClass;
      if (staticClass == null) {
        throw BSCException('Called super expression outside class\n${scope.stack.reversed.join('\n')}', scope);
      }
      return staticClass.parents.single.getVar(member, line, col, file, tv);
    }

    ClassValueType parent = classType;
    Scope superMethods;
    if (classType.supertype == null) {
      throw BSCException('super expression used in a root class', scope);
    }
    do {
      parent = parent.supertype ?? (throw BSCException('super expression failed to find $member in ${classType.supertype!} or supertypes', scope));
      superMethods = scope.getVar(
          tv.variables['~${parent.name.name}~methods'] ??= Variable('~${parent.name.name}~methods'), line, col, '<internal error: no methods>', tv) as Scope;
    } while (!superMethods.values.containsKey(member));
    Object? superMethod = superMethods.getVar(member, line, col, file, tv);
    FunctionValueType superMethodType = getType(superMethod, scope, line, col, file) as FunctionValueType;
    superMethods.getVar(member, line, col, file, tv);
    assert(superMethod is SydFunction);
    Object? x = SydFunction((List args, List<LazyString> stack, [Scope? thisScope, ValueType? thisType]) {
      return (superMethod as SydFunction).function(args, stack, scope.getClass()!, classType);
    }, superMethodType, Concat('super.', member.name));
    return x;
  }

  String toString() => 'super.${member.name}';

  @override
  ValueType get staticType => static
      ? ValueType.create(null, whateverVariable, 0, 0, '', tv)
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
      throw BSCException('Failed unwrap of null ($a) ${formatCursorPosition(line, col, file)}\n${scope.stack.reversed.join('\n')}', scope);
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
  late ValueType anythingFunctionType = GenericFunctionValueType(tv.environment.anythingType, 'interr', validator);
  FunctionCallExpr(this.a, this.b, this.validator, int line, int col, String file, TypeValidator tv) : super(line, col, file, tv);
  @override
  Object? eval(Scope scope) {
    //print('calling $a...');
    Object? aEval = a.eval(scope);
    ValueType type2 = getType(aEval, scope, line, col, file);
    if (!type2.isSubtypeOf(anythingFunctionType) && !(type2 is ClassOfValueType)) {
      throw BSCException('tried to call non-function: $aEval, ${formatCursorPosition(line, col, file)}\n${scope.stack.reversed.join('\n')}', scope);
    }
    List<Object?> args = b.map((x) => x.eval(scope)).toList();
    for (int i = 0; i < args.length; i++) {
      if (a.staticType is FunctionValueType && !getType(args[i], scope, line, col, file).isSubtypeOf((type2 as FunctionValueType).parameters.elementAt(i))) {
        throw BSCException(
            'argument #$i of $a, ${toStringWithStacker(args[i], scope.stack, line, col, file, false, scope.environment)} (${b[i]}), of wrong type (${getType(args[i], scope, line, col, file)}) expected ${type2.parameters.elementAt(i)} ${formatCursorPosition(line, col, file)}\n${scope.stack.reversed.join('\n')}',
            scope);
      }
    }
    //print('evaluated arguments...');
    List<LazyString> newStack = scope.stack.toList();
    if (newStack.last is NotLazyString) {
      newStack[newStack.length - 1] = CursorPositionLazyString((newStack.last as NotLazyString).str, line, col, file);
    } else {
      newStack[newStack.length - 1] = ConcatenateLazyString(newStack.last, CursorPositionLazyString('', line, col, file));
    }
    try {
      if (type2 is ClassOfValueType) {
        aEval = (aEval as Class).constructor;
      }
      return (aEval as SydFunction).function(args, newStack);
    } on StackOverflowError {
      throw BSCException('Stack Overflow ${formatCursorPosition(line, col, file)}\n${scope.stack.reversed.join('\n')}', scope);
    }
  }
}

class ListLiteralExpression extends Expression {
  ListLiteralExpression(this.n, this.genParam, int line, int col, String file, TypeValidator tv) : super(line, col, file, tv);
  final List<Expression> n;
  final ValueType genParam;
  ValueType get staticType => ListValueType(genParam, file, tv);
  String toString() => '$n:$genParam';
  bool isLValue(TypeValidator scope) => false;
  SydList<Object?> eval(Scope scope) {
    List<Object?> params = n.map((e) => e.eval(scope)).toList();
    for (Object? param in params) {
      if (!getType(param, scope, line, col, file).isSubtypeOf(genParam)) {
        throw BSCException(
            'List literal element ${toStringWithStacker(param, scope.stack, line, col, file, false, scope.environment)} (${getType(param, scope, line, col, file)}) is not a subtype of $genParam ${formatCursorPosition(line, col, file)}\n${scope.stack.reversed.join('\n')}',
            scope);
      }
    }
    return SydList(
      params,
      ListValueType(genParam, file, tv),
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
