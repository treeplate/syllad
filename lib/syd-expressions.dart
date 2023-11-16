import 'dart:math';

import 'syd-core.dart';

class AssertExpression extends Expression {
  final Expression condition;
  final Expression comment;

  bool isLValue(TypeValidator scope) => false;

  @override
  ValueType get type => tv.environment.nullType;

  String toString() => 'assert($condition, $comment)';

  AssertExpression(this.condition, this.comment, TypeValidator tv, int line, int col, String workspace, String file) : super(line, col, workspace, file, tv);
  @override
  ValueWrapper eval(Scope scope) {
    if (!(scope.intrinsics ?? scope).debugMode!) {
      return ValueWrapper(tv.environment.nullType, null, 'rtv of non-debug-mode assert');
    }
    ValueWrapper conditionEval = condition.eval(scope);
    if (!conditionEval.typeC(scope, scope.stack, line, col, workspace, file, scope.environment).isSubtypeOf(tv.environment.booleanType)) {
      throw BSCException(
        'argument 0 of assert, ${conditionEval.toStringWithStack(scope.stack, line, col, workspace, file, false, scope.environment)} ($condition), of wrong type (${conditionEval.typeC(scope, scope.stack, line, col, workspace, file, scope.environment)}) expected boolean ${formatCursorPosition(line, col, workspace, file)}\n${scope.stack.reversed.join('\n')}',
        scope,
      );
    }
    if (!conditionEval.valueC(scope, scope.stack, line, col, workspace, file, scope.environment)) {
      ValueWrapper commentEval = comment.eval(scope);
      if (!commentEval.typeC(scope, scope.stack, line, col, workspace, file, scope.environment).isSubtypeOf(tv.environment.stringType)) {
        throw BSCException(
          'argument 1 of assert, $commentEval ($comment), of wrong type (${commentEval.typeC(scope, scope.stack, line, col, workspace, file, scope.environment)}) expected string ${formatCursorPosition(line, col, workspace, file)}\n${scope.stack.reversed.join('\n')}',
          scope,
        );
      }
      throw AssertException(
        commentEval.valueC<String>(scope, scope.stack, line, col, workspace, file, scope.environment) +
            ' ($condition was not true) ${formatCursorPosition(line, col, workspace, file)}\n${scope.stack.reversed.join('\n')}',
        scope,
      );
    }
    return ValueWrapper(tv.environment.nullType, null, 'rtv of debug-mode assert');
  }
}

class GetExpr extends Expression {
  final Variable name;
  late final ValueType type;

  bool isLValue(TypeValidator scope) => tv.igvnc(name); // xxx scope may not be needed

  GetExpr(this.name, TypeValidator tv, int line, col, String workspace, file) : super(line, col, workspace, file, tv) {
    type = tv.getVar(name, line, col, workspace, file, 'for a get expression', true);
  }

  void write(ValueWrapper value, bool isConstant, Scope scope) {
    if (scope.values[name]?.isConstant ?? false) {
      throw BSCException(
        'Cannot write to constant variable ${name.name} ${formatCursorPosition(line, col, workspace, file)} ${scope.stack.reversed.join('\n')}',
        scope,
      );
    }
    if (scope.values.containsKey(name)) {
      if (!value.typeC(scope, scope.stack, line, col, workspace, file, scope.environment).isSubtypeOf(type)) {
        // xxx shadowed variables
        throw BSCException(
            'Tried to assign ${value.toStringWithStack(scope.stack, line, col, workspace, file, false, scope.environment)} to ${name.name} but the new type, ${value.typeC(scope, scope.stack, line, col, workspace, file, scope.environment)}, is not a subtype of the variable\'s type, $type ${formatCursorPosition(line, col, workspace, file)}',
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
      'Tried to write to nonexistent variable ${name.name} ${scope.recursiveContains(name)} ${formatCursorPosition(line, col, workspace, file)} ${scope.stack.reversed.join('\n')}',
      scope,
    );
  }

  @override
  ValueType get asType => ValueType.create(tv.environment.anythingType, name, line, col, workspace, file, tv);

  @override
  eval(Scope scope) {
    return scope.getVar(name, line, col, workspace, file, tv);
  }

  String toString() => name.name;
}

class EqualsExpression extends Expression {
  final Expression a;
  final Expression b;

  bool isLValue(TypeValidator scope) => false;

  EqualsExpression(this.a, this.b, TypeValidator tv, int line, int col, String workspace, file) : super(line, col, workspace, file, tv);
  @override
  ValueWrapper eval(Scope scope) {
    ValueWrapper ea = a.eval(scope);
    ValueWrapper eb = b.eval(scope);
    ValueWrapper result = ValueWrapper(
        tv.environment.booleanType,
        ea.typeC(scope, scope.stack, line, col, workspace, file, scope.environment) ==
                eb.typeC(scope, scope.stack, line, col, workspace, file, scope.environment) &&
            ea.valueC<Object?>(scope, scope.stack, line, col, workspace, file, scope.environment) ==
                eb.valueC<Object?>(scope, scope.stack, line, col, workspace, file, scope.environment),
        LazyInterpolatorSpace(this, 'result'));
    return result;
  }

  String toString() => '$a == $b';

  ValueType get type => tv.environment.booleanType;
}

class BitAndExpression extends Expression {
  final Expression a;
  final Expression b;
  bool isLValue(TypeValidator scope) => false;

  BitAndExpression(this.a, this.b, TypeValidator tv, int line, col, String workspace, file) : super(line, col, workspace, file, tv);
  @override
  ValueWrapper eval(Scope scope) {
    ValueWrapper av = a.eval(scope);
    ValueWrapper bv = b.eval(scope);
    if (!(av.typeC(scope, scope.stack, line, col, workspace, file, scope.environment).isSubtypeOf(tv.environment.integerType) &&
        bv.typeC(scope, scope.stack, line, col, workspace, file, scope.environment).isSubtypeOf(tv.environment.integerType))) {
      throw BSCException(
        '$av ($a) or $bv ($b) is not an integer; attempted $a (a ${av.typeC(scope, scope.stack, line, col, workspace, file, scope.environment)}) & $b (a ${bv.typeC(scope, scope.stack, line, col, workspace, file, scope.environment)}) ${formatCursorPosition(line, col, workspace, file)}\n ${scope.stack.reversed.join('\n')}',
        scope,
      );
    }
    return ValueWrapper(
        tv.environment.integerType,
        av.valueC<int>(scope, scope.stack, line, col, workspace, file, scope.environment) &
            bv.valueC(scope, scope.stack, line, col, workspace, file, scope.environment),
        '$this result');
  }

  String toString() => '$a & $b';

  ValueType get type => tv.environment.integerType;
}

class BitXorExpression extends Expression {
  final Expression a;
  final Expression b;

  bool isLValue(TypeValidator scope) => false;
  BitXorExpression(this.a, this.b, TypeValidator tv, int line, int col, String workspace, String file) : super(line, col, workspace, file, tv);
  @override
  ValueWrapper eval(Scope scope) {
    ValueWrapper av = a.eval(scope);
    ValueWrapper bv = b.eval(scope);
    if (!(av.typeC(scope, scope.stack, line, col, workspace, file, scope.environment).isSubtypeOf(tv.environment.integerType) &&
        bv.typeC(scope, scope.stack, line, col, workspace, file, scope.environment).isSubtypeOf(tv.environment.integerType))) {
      throw BSCException(
        '$av ($a) or $bv ($b) is not an integer; attempted $a (a ${av.typeC(scope, scope.stack, line, col, workspace, file, scope.environment)}) & $b (a ${bv.typeC(scope, scope.stack, line, col, workspace, file, scope.environment)}) ${formatCursorPosition(line, col, workspace, file)}\n ${scope.stack.reversed.join('\n')}',
        scope,
      );
    }
    return ValueWrapper(
      tv.environment.integerType,
      av.valueC<int>(scope, scope.stack, line, col, workspace, file, scope.environment) ^
          bv.valueC(scope, scope.stack, line, col, workspace, file, scope.environment),
      LazyInterpolatorSpace(this, 'result'),
    );
  }

  String toString() => '$a ^ $b';

  ValueType get type => tv.environment.integerType;
}

class SubscriptExpression extends Expression {
  final Expression a;
  final Expression b;

  bool isLValue(TypeValidator scope) => true;
  ValueType get type => a.type.name == whateverVariable
      ? ValueType.create(null, whateverVariable, -2, 0, 'interr', '_', tv)
      : a.type is ListValueType
          ? (a.type as ListValueType).genericParameter
          : (a.type as ArrayValueType).genericParameter;
  String toString() => '$a[$b]';

  SubscriptExpression(this.a, this.b, int line, col, String workspace, file, TypeValidator tv) : super(line, col, workspace, file, tv);
  @override
  eval(Scope scope) {
    ValueWrapper list = a.eval(scope);
    ValueWrapper iV = b.eval(scope);
    if (iV.valueC(scope, scope.stack, line, col, workspace, file, scope.environment) is! int)
      throw BSCException(
        '$b is not integer, is ${iV.typeC(scope, scope.stack, line, col, workspace, file, scope.environment)} ${formatCursorPosition(line, col, workspace, file)}\n${scope.stack.reversed.join('\n')}',
        scope,
      );
    int index = iV.valueC(scope, scope.stack, line, col, workspace, file, scope.environment);
    return fancySubscript(list, index, scope);
  }

  void write(ValueWrapper value, bool isConstant, Scope scope) {
    ValueWrapper list = a.eval(scope);
    ValueWrapper iV = b.eval(scope);
    if (iV.valueC(scope, scope.stack, line, col, workspace, file, scope.environment) is! int)
      throw BSCException(
        '$b is not integer, is ${iV.typeC(scope, scope.stack, line, col, workspace, file, scope.environment)} ${formatCursorPosition(line, col, workspace, file)}\n${scope.stack.reversed.join('\n')}',
        scope,
      );
    int index = iV.valueC(scope, scope.stack, line, col, workspace, file, scope.environment);
    Object? listValue = list.valueC(scope, scope.stack, line, col, workspace, file, scope.environment);
    Object? listType = list.typeC(scope, scope.stack, line, col, workspace, file, scope.environment);
    if (listValue is! List) {
      throw BSCException(
        '$a is not a list ${formatCursorPosition(line, col, workspace, file)}\n${scope.stack.reversed.join('\n')}',
        scope,
      );
    }
    if (listType is ArrayValueType) {
      throw BSCException(
        '$a is an array which cannot be modified ${formatCursorPosition(line, col, workspace, file)}\n${scope.stack.reversed.join('\n')}',
        scope,
      );
    }
    if (listValue.length <= index || index < 0) {
      throw BSCException(
        'RangeError: ${list.toStringWithStack(scope.stack, line, col, workspace, file, false, scope.environment)} ($a) has ${listValue.length} elements, but it was subscripted with element $index. ${formatCursorPosition(line, col, workspace, file)}\n${scope.stack.reversed.join('\n')}',
        scope,
      );
    }
    listValue[index] = value;
  }

  ValueWrapper fancySubscript(ValueWrapper list, int index, Scope scope) {
    Object? listValue = list.valueC(scope, scope.stack, line, col, workspace, file, scope.environment);
    if (listValue is! List) {
      throw BSCException(
        '$a is not list ${formatCursorPosition(line, col, workspace, file)}',
        scope,
      );
    }
    if (listValue.length <= index || index < 0) {
      throw BSCException(
        'RangeError: ${list.toStringWithStack(scope.stack, line, col, workspace, file, false, scope.environment)} ($a) has ${listValue.length} elements, but it was subscripted with element $index. ${formatCursorPosition(line, col, workspace, file)}\n${scope.stack.reversed.join('\n')}',
        scope,
      );
    }
    return listValue[index];
  }
}

class MemberAccessExpression extends Expression {
  final Expression a;
  final Variable b;
  bool isLValue(TypeValidator scope) => false;

  late ValueType type = () {
    if (a.type is ClassOfValueType) {
      return (a.type as ClassOfValueType).staticMembers.igv(b, true, line, col, workspace, file, true, false)!;
    }
    if (a.type is EnumValueType) {
      return (a.type as EnumValueType).staticMembers.igv(b, true, line, col, workspace, file, false, false)!;
    }
    return a.type.name != whateverVariable
        ? (a.type as ClassValueType).properties.igv(b, true, line, col, workspace, file, true, false)!
        : tv.environment.anythingType;
  }();

  MemberAccessExpression(this.a, this.b, int l, int c, String workspace, file, TypeValidator tv) : super(l, c, workspace, file, tv);
  @override
  eval(Scope scope) {
    ValueWrapper thisScopeWrapper = a.eval(scope);
    ValueType type2 = thisScopeWrapper.typeC(scope, scope.stack, line, col, workspace, file, scope.environment);
    if (type2 is! ClassValueType && type2 is! ClassOfValueType && type2 is! EnumValueType) {
      throw BSCException(
        '$thisScopeWrapper ($a) is not an instance of a class or a class or an enum, it\'s a $type2 ${formatCursorPosition(line, col, workspace, file)}\n${scope.stack.reversed.join('\n')}',
        scope,
      );
    }
    Object thisThing = thisScopeWrapper.valueC(scope, scope.stack, line, col, workspace, file, scope.environment);
    if (type2 is ClassOfValueType) {
      thisThing = (thisThing as Class).staticMembers;
    }
    if (type2 is EnumValueType) {
      thisThing = (thisThing as Enum).staticMembers;
    }
    Scope thisScope = thisThing as Scope;
    return thisScope.getVar(b, line, col, workspace, file, null);
  }

  String toString() => '$a.${b.name}';
}

class IsExpr extends Expression {
  final Expression operand;
  final ValueType isType;
  bool isLValue(TypeValidator scope) => false;

  IsExpr(this.operand, this.isType, int l, c, String workspace, file, TypeValidator tv) : super(l, c, workspace, file, tv);

  String toString() => '$operand is $isType';

  ValueType get type => tv.environment.booleanType;

  @override
  ValueWrapper eval(Scope scope) {
    ValueType possibleChildType = operand.eval(scope).typeC(scope, scope.stack, line, col, workspace, file, scope.environment);
    return ValueWrapper(tv.environment.booleanType, possibleChildType.isSubtypeOf(isType), '$this result');
  }
}

class AsExpr extends Expression {
  final Expression operand;
  final ValueType isType;

  bool isLValue(TypeValidator scope) => false;
  AsExpr(this.operand, this.isType, int l, c, String workspace, file, TypeValidator tv) : super(l, c, workspace, file, tv);

  String toString() => '$operand as $isType';

  late ValueType type = isType;

  ValueWrapper? iterableCast<T extends ValueType<Iterable<ValueWrapper>>>(Scope scope, ValueType possibleChildType, Object? possibleChildValue) {
    if (possibleChildType is T && isType is T && !possibleChildType.isSubtypeOf(isType)) {
      ValueType genericParameter = (isType as dynamic).genericParameter;
      for (ValueWrapper x in possibleChildValue as Iterable) {
        ValueType xType = x.typeC(scope, scope.stack, line, col, workspace, file, scope.environment);
        if (!xType.isSubtypeOf(genericParameter)) {
          throw BSCException(
            '$this had invalid element type; expected $genericParameter got $x (a $xType) ${formatCursorPosition(line, col, workspace, file)}',
            scope,
          );
        }
      }
      return ValueWrapper(isType, possibleChildValue, 'as (iterable.cast style)');
    }
    return null;
  }

  @override
  ValueWrapper eval(Scope scope) {
    ValueWrapper op = operand.eval(scope);
    ValueType possibleChildType = op.typeC(scope, scope.stack, line, col, workspace, file, scope.environment);
    Object? possibleChildValue = op.valueC(scope, scope.stack, line, col, workspace, file, scope.environment);
    return iterableCast<IterableValueType>(scope, possibleChildType, possibleChildValue) ??
        iterableCast<ListValueType>(scope, possibleChildType, possibleChildValue) ??
        iterableCast<ArrayValueType>(scope, possibleChildType, possibleChildValue) ??
        () {
          if (!possibleChildType.isSubtypeOf(isType)) {
            throw BSCException(
              'as failed; expected $isType got ${op.toStringWithStack(scope.stack, line, col, workspace, file, false, scope.environment)} (a $possibleChildType) \n${formatCursorPosition(line, col, workspace, file)} ${scope.stack.reversed.join('\n')}',
              scope,
            );
          }
          return op;
        }();
  }
}

class NotExpression extends Expression {
  final Expression a;

  bool isLValue(TypeValidator scope) => false;
  NotExpression(this.a, int line, int col, String workspace, file, TypeValidator tv) : super(line, col, workspace, file, tv);

  String toString() => '!$a';
  @override
  ValueWrapper eval(Scope scope) {
    ValueWrapper aEval = a.eval(scope);
    if (!aEval.typeC(scope, scope.stack, line, col, workspace, file, scope.environment).isSubtypeOf(tv.environment.booleanType)) {
      throw BSCException(
        'Attempted !$a but ${aEval.toStringWithStack(scope.stack, line, col, workspace, file, false, scope.environment)} was not a boolean (was ${aEval.typeC(scope, scope.stack, line, col, workspace, file, scope.environment)}) ${formatCursorPosition(line, col, workspace, file)}\n${scope.stack.reversed.join('\n')}}',
        scope,
      );
    }
    return ValueWrapper(
        tv.environment.booleanType, !aEval.valueC(scope, scope.stack, line, col, workspace, file, scope.environment), LazyInterpolatorSpace(this, 'result'));
  }

  ValueType get type => tv.environment.booleanType;
}

class BitNotExpression extends Expression {
  final Expression a;
  bool isLValue(TypeValidator scope) => false;

  BitNotExpression(this.a, int line, int col, String workspace, file, TypeValidator tv) : super(line, col, workspace, file, tv);
  @override
  ValueWrapper eval(Scope scope) {
    ValueWrapper aEval = a.eval(scope);
    if (!aEval.typeC(scope, scope.stack, line, col, workspace, file, scope.environment).isSubtypeOf(tv.environment.integerType)) {
      throw BSCException(
        'Attempted !$a but $aEval was not an integer (was ${aEval.typeC(scope, scope.stack, line, col, workspace, file, scope.environment)}) ${formatCursorPosition(line, col, workspace, file)}\n${scope.stack.reversed.join('\n')}}',
        scope,
      );
    }
    return ValueWrapper(tv.environment.integerType, ~aEval.valueC<int>(scope, scope.stack, line, col, workspace, file, scope.environment), '$this result');
  }

  String toString() => '~$a';

  ValueType get type => tv.environment.integerType;
}

class TypeOfExpression extends Expression {
  final Expression a;
  bool isLValue(TypeValidator scope) => false;

  TypeOfExpression(this.a, int line, int col, String workspace, file, TypeValidator tv) : super(line, col, workspace, file, tv);
  @override
  ValueWrapper eval(Scope scope) {
    ValueWrapper aEval = a.eval(scope);
    return ValueWrapper(tv.environment.integerType, aEval.typeC(scope, scope.stack, line, col, workspace, file, scope.environment).id, '$this result');
  }

  String toString() => '~$a';

  ValueType get type => tv.environment.integerType;
}

class MultiplyExpression extends Expression {
  final Expression a;
  final Expression b;
  String toString() => '$a * $b';
  bool isLValue(TypeValidator scope) => false;

  MultiplyExpression(this.a, this.b, int line, int col, String workspace, file, TypeValidator tv) : super(line, col, workspace, file, tv);
  @override
  ValueWrapper eval(Scope scope) {
    ValueWrapper aEval = a.eval(scope);
    if (!aEval.typeC(scope, scope.stack, line, col, workspace, file, scope.environment).isSubtypeOf(tv.environment.integerType)) {
      throw BSCException(
          'Attempted $a*$b but $aEval was not an integer (was ${aEval.typeC(scope, scope.stack, line, col, workspace, file, scope.environment)}) ${formatCursorPosition(line, col, workspace, file)}\n${scope.stack.reversed.join('\n')}}',
          scope);
    }
    ValueWrapper bEval = b.eval(scope);
    if (!bEval.typeC(scope, scope.stack, line, col, workspace, file, scope.environment).isSubtypeOf(tv.environment.integerType)) {
      throw BSCException(
          'Attempted $a*$b but $bEval was not an integer (was ${bEval.typeC(scope, scope.stack, line, col, workspace, file, scope.environment)}) ${formatCursorPosition(line, col, workspace, file)}\n${scope.stack.reversed.join('\n')}}',
          scope);
    }
    return ValueWrapper(
        tv.environment.integerType,
        aEval.valueC<int>(scope, scope.stack, line, col, workspace, file, scope.environment) *
            bEval.valueC<int>(scope, scope.stack, line, col, workspace, file, scope.environment),
        '$this result');
  }

  ValueType get type => tv.environment.integerType;
}

class DivideExpression extends Expression {
  final Expression a;
  final Expression b;
  bool isLValue(TypeValidator scope) => false;

  DivideExpression(this.a, this.b, int line, int col, String workspace, file, TypeValidator tv) : super(line, col, workspace, file, tv);
  @override
  ValueWrapper eval(Scope scope) {
    ValueWrapper av = a.eval(scope);
    ValueWrapper bv = b.eval(scope);
    if (!(av.typeC(scope, scope.stack, line, col, workspace, file, scope.environment).isSubtypeOf(tv.environment.integerType) &&
        bv.typeC(scope, scope.stack, line, col, workspace, file, scope.environment).isSubtypeOf(tv.environment.integerType))) {
      throw BSCException(
          '$av ($a) or $bv ($b) is not an integer; attempted $a/$b ${formatCursorPosition(line, col, workspace, file)}\n ${scope.stack.reversed.join('\n')}',
          scope);
    }
    return ValueWrapper(
        tv.environment.integerType,
        av.valueC<int>(scope, scope.stack, line, col, workspace, file, scope.environment) ~/
            bv.valueC<int>(scope, scope.stack, line, col, workspace, file, scope.environment),
        '$this result');
  }

  ValueType get type => tv.environment.integerType;
}

class PowExpression extends Expression {
  final Expression a;
  final Expression b;
  bool isLValue(TypeValidator scope) => false;

  PowExpression(this.a, this.b, int line, int col, String workspace, file, TypeValidator tv) : super(line, col, workspace, file, tv);
  @override
  ValueWrapper eval(Scope scope) {
    return ValueWrapper(
      tv.environment.integerType,
      pow(
        a.eval(scope).valueC(scope, scope.stack, line, col, workspace, file, scope.environment),
        b.eval(scope).valueC(scope, scope.stack, line, col, workspace, file, scope.environment),
      ),
      '$this result',
    );
  }

  ValueType get type => tv.environment.integerType;
}

class RemainderExpression extends Expression {
  final Expression a;
  final Expression b;
  bool isLValue(TypeValidator scope) => false;

  String toString() => '$a % $b';

  RemainderExpression(this.a, this.b, int line, int col, String workspace, file, TypeValidator tv) : super(line, col, workspace, file, tv);
  @override
  ValueWrapper eval(Scope scope) {
    ValueWrapper av = a.eval(scope);
    ValueWrapper bv = b.eval(scope);
    if (!(av.typeC(scope, scope.stack, line, col, workspace, file, scope.environment).isSubtypeOf(tv.environment.integerType) &&
        bv.typeC(scope, scope.stack, line, col, workspace, file, scope.environment).isSubtypeOf(tv.environment.integerType))) {
      throw BSCException(
          '$av ($a) or $bv ($b) is not an integer; attempted $a%$b ${formatCursorPosition(line, col, workspace, file)}\n ${scope.stack.reversed.join('\n')}',
          scope);
    }
    if (bv.valueC(scope, scope.stack, line, col, workspace, file, scope.environment) == 0) {
      throw BSCException(
          '$a (${av.valueC(scope, scope.stack, line, col, workspace, file, scope.environment)}) % $b (0) attempted ${formatCursorPosition(line, col, workspace, file)} stack ${scope.stack.join('\n')}',
          scope);
    }
    return ValueWrapper(
        tv.environment.integerType,
        av.valueC<int>(scope, scope.stack, line, col, workspace, file, scope.environment) %
            bv.valueC<int>(scope, scope.stack, line, col, workspace, file, scope.environment),
        Concat(this, ' result'));
  }

  ValueType get type => tv.environment.integerType;
}

class SubtractExpression extends Expression {
  final Expression a;
  final Expression b;
  bool isLValue(TypeValidator scope) => false;

  SubtractExpression(this.a, this.b, int line, int col, String workspace, file, TypeValidator tv) : super(line, col, workspace, file, tv);
  @override
  ValueWrapper eval(Scope scope) {
    ValueWrapper av = a.eval(scope);
    ValueWrapper bv = b.eval(scope);
    if (!(av.typeC(scope, scope.stack, line, col, workspace, file, scope.environment).isSubtypeOf(tv.environment.integerType) &&
        bv.typeC(scope, scope.stack, line, col, workspace, file, scope.environment).isSubtypeOf(tv.environment.integerType))) {
      throw BSCException(
          '$av ($a) or $bv ($b) is not an integer; attempted $a-$b ${formatCursorPosition(line, col, workspace, file)}\n ${scope.stack.reversed.join('\n')}',
          scope);
    }
    return ValueWrapper(
        tv.environment.integerType,
        av.valueC<int>(scope, scope.stack, line, col, workspace, file, scope.environment) -
            bv.valueC<int>(scope, scope.stack, line, col, workspace, file, scope.environment),
        Concat(this, ' result'));
  }

  String toString() => '($a) - ($b)';

  ValueType get type => tv.environment.integerType;
}

class AddExpression extends Expression {
  final Expression a;
  bool isLValue(TypeValidator scope) => false;
  final Expression b;

  AddExpression(this.a, this.b, int line, int col, String workspace, file, TypeValidator tv) : super(line, col, workspace, file, tv);
  @override
  ValueWrapper eval(Scope scope) {
    ValueWrapper av = a.eval(scope);
    ValueWrapper bv = b.eval(scope);
    if (!(av.typeC(scope, scope.stack, line, col, workspace, file, scope.environment).isSubtypeOf(tv.environment.integerType) &&
        bv.typeC(scope, scope.stack, line, col, workspace, file, scope.environment).isSubtypeOf(tv.environment.integerType))) {
      throw BSCException(
          '${av.toStringWithStack(scope.stack, line, col, workspace, file, false, scope.environment)} ($a) or ${bv.toStringWithStack(scope.stack, line, col, workspace, file, false, scope.environment)} ($b) is not an integer; attempted $a+$b ${formatCursorPosition(line, col, workspace, file)}\n ${scope.stack.reversed.join('\n')}',
          scope);
    }
    return ValueWrapper(
      tv.environment.integerType,
      av.valueC<int>(scope, scope.stack, line, col, workspace, file, scope.environment) +
          bv.valueC<int>(scope, scope.stack, line, col, workspace, file, scope.environment),
      LazyInterpolatorSpace(this, 'result'),
    );
  }

  String toString() => '$a + $b';

  ValueType get type => tv.environment.integerType;
}

class SuperExpression extends Expression {
  SuperExpression(this.member, int line, int col, String workspace, file, this.static, TypeValidator tv) : super(line, col, workspace, file, tv);
  final Variable member;
  final bool static;
  bool isLValue(TypeValidator scope) => false;

  @override
  ValueWrapper eval(Scope scope) {
    // throw BSCException('Called super expression outside class\n${stack.reversed.join('\n')}', scope);
    ClassValueType? classType = scope.currentClass;
    if (classType == null) {
      Scope? staticClass = scope.currentStaticClass;
      if (staticClass == null) {
        throw BSCException('Called super expression outside class\n${scope.stack.reversed.join('\n')}', scope);
      }
      return staticClass.parents.single.getVar(member, line, col, workspace, file, tv);
    }

    ClassValueType parent = classType;
    Scope superMethods;
    if (classType.supertype == null) {
      throw BSCException('super expression used in a root class', scope);
    }
    do {
      parent = parent.supertype ?? (throw BSCException('super expression failed to find $member in ${classType.supertype!} or supertypes', scope));
      superMethods = scope
          .getVar(tv.variables['~${parent.name.name}~methods'] ??= Variable('~${parent.name.name}~methods'), line, col, 'interr',
              '<internal error: no methods>', tv)
          .valueC(scope, scope.stack, line, col, workspace, file, scope.environment);
    } while (!superMethods.values.containsKey(member));
    ValueWrapper superMethod = superMethods.getVar(member, line, col, workspace, file, tv);
    ValueType<Object?> superMethodType = superMethod.typeC(scope, scope.stack, line, col, workspace, file, scope.environment);
    Object superMethodValue = superMethod.valueC(scope, scope.stack, line, col, workspace, file, scope.environment);
    superMethods.getVar(member, line, col, workspace, file, tv);
    assert(superMethodValue is SydFunction);
    assert(superMethodType is FunctionValueType);
    ValueWrapper x = ValueWrapper(superMethodType, (List<ValueWrapper> args, List<LazyString> stack, [Scope? thisScope, ValueType? thisType]) {
      return (superMethodValue as SydFunction)(args, stack, scope.getClass()!, classType);
    }, 'super.${member.name}', true);
    return x;
  }

  String toString() => 'super.${member.name}';

  @override
  ValueType get type => static
      ? ValueType.create(null, whateverVariable, 0, 0, '', '', tv)
      : (tv.currentClassType.parent is ClassValueType
              ? tv.currentClassType.parent as ClassValueType
              : (throw BSCException('${tv.currentClassType} has no supertype ${formatCursorPosition(line, col, workspace, file)}', tv)))
          .properties
          .igv(member, true, line, col, workspace, file, true, false)!;
}

class IntLiteralExpression extends Expression {
  IntLiteralExpression(this.n, int line, int col, String workspace, file, TypeValidator tv) : super(line, col, workspace, file, tv);
  final int n;
  ValueWrapper eval(Scope scope) => ValueWrapper(tv.environment.integerType, n, 'literal');
  String toString() => '$n';
  bool isLValue(TypeValidator scope) => false;

  ValueType get type => tv.environment.integerType;
}

class StringLiteralExpression extends Expression {
  StringLiteralExpression(this.n, int line, int col, String workspace, file, TypeValidator tv) : super(line, col, workspace, file, tv);
  final String n;
  ValueWrapper eval(Scope scope) => ValueWrapper(tv.environment.stringType, n, 'literal');
  String toString() => '\'$n\'';
  ValueType get type => tv.environment.stringType;
  bool isLValue(TypeValidator scope) => false;
}

class BoringExpr extends Expression {
  final Object? value;
  bool isLValue(TypeValidator scope) => false;

  final ValueType type;

  BoringExpr(this.value, this.type, TypeValidator tv) : super(-2, 0, 'TODO', 'TODO (boring expr line,column, filename)', tv);
  @override
  eval(Scope scope) {
    return ValueWrapper(type, value, '<todo boring expr vw desc>');
  }

  String toString() => '$value**';
}

class UnwrapExpression extends Expression {
  UnwrapExpression(this.a, int line, int col, String workspace, file, TypeValidator tv) : super(line, col, workspace, file, tv);
  final Expression a;
  bool isLValue(TypeValidator scope) => false;
  @override
  ValueWrapper eval(Scope scope) {
    ValueWrapper aval = a.eval(scope);
    if (aval.valueC(scope, scope.stack, line, col, workspace, file, scope.environment) == null) {
      throw BSCException('Failed unwrap of null ($a) ${formatCursorPosition(line, col, workspace, file)}\n${scope.stack.reversed.join('\n')}', scope);
    }
    return aval;
  }

  String toString() => '$a!';

  @override
  ValueType get type => a.type is NullableValueType ? (a.type as NullableValueType).genericParam : a.type;
}

class FunctionCallExpr extends Expression {
  final Expression a;
  final List<Expression> b;
  bool isLValue(TypeValidator scope) => false;

  final TypeValidator validator;

  @override
  ValueType get type {
    if (a.type is ClassOfValueType) {
      return (a.type as ClassOfValueType).constructor.returnType;
    }
    return a.type.name.name != 'Whatever' ? (a.type as GenericFunctionValueType).returnType : tv.environment.anythingType;
  }

  String toString() => '$a(${b.join(', ')})';
  late ValueType anythingFunctionType = GenericFunctionValueType(tv.environment.anythingType, 'interr', validator);
  FunctionCallExpr(this.a, this.b, this.validator, int line, int col, String workspace, file, TypeValidator tv) : super(line, col, workspace, file, tv);
  @override
  ValueWrapper eval(Scope scope) {
    //print('calling $a...');
    ValueWrapper aEval = a.eval(scope);
    ValueType type2 = aEval.typeC(scope, scope.stack, line, col, workspace, file, scope.environment);
    if (!type2.isSubtypeOf(anythingFunctionType) && !(type2 is ClassOfValueType)) {
      throw BSCException('tried to call non-function: $aEval, ${formatCursorPosition(line, col, workspace, file)}\n${scope.stack.reversed.join('\n')}', scope);
    }
    List<ValueWrapper> args = b.map((x) => x.eval(scope)).toList();
    for (int i = 0; i < args.length; i++) {
      if (a.type is FunctionValueType &&
          !args[i].typeC(scope, scope.stack, line, col, workspace, file, scope.environment).isSubtypeOf((type2 as FunctionValueType).parameters.elementAt(i))) {
        throw BSCException(
            'argument #$i of $a, ${args[i].toStringWithStack(scope.stack, line, col, workspace, file, false, scope.environment)} (${b[i]}), of wrong type (${args[i].typeC(scope, scope.stack, line, col, workspace, file, scope.environment)}) expected ${type2.parameters.elementAt(i)} ${formatCursorPosition(line, col, workspace, file)}\n${scope.stack.reversed.join('\n')}',
            scope);
      }
    }
    //print('evaluated arguments...');
    List<LazyString> newStack = scope.stack.toList();
    if (newStack.last is NotLazyString) {
      newStack[newStack.length - 1] = CursorPositionLazyString((newStack.last as NotLazyString).str, line, col, workspace, file);
    } else {
      newStack[newStack.length - 1] = ConcatenateLazyString(newStack.last, CursorPositionLazyString('', line, col, workspace, file));
    }
    try {
      if (type2 is ClassOfValueType) {
        aEval = (aEval.valueC(scope, scope.stack, line, col, workspace, file, scope.environment) as Class).constructor;
      }
      return aEval.valueC<SydFunction>(scope, scope.stack, line, col, workspace, file, scope.environment)(args, newStack);
    } on StackOverflowError {
      throw BSCException('Stack Overflow ${formatCursorPosition(line, col, workspace, file)}\n${scope.stack.reversed.join('\n')}', scope);
    }
  }
}

class ListLiteralExpression extends Expression {
  ListLiteralExpression(this.n, this.genParam, int line, int col, String workspace, file, TypeValidator tv) : super(line, col, workspace, file, tv);
  final List<Expression> n;
  final ValueType genParam;
  ValueType get type => ListValueType(genParam, file, tv);
  String toString() => '$n:$genParam';
  bool isLValue(TypeValidator scope) => false;
  ValueWrapper eval(Scope scope) {
    List<ValueWrapper> params = n.map((e) => e.eval(scope)).toList();
    for (ValueWrapper param in params) {
      if (!param.typeC(scope, scope.stack, line, col, workspace, file, scope.environment).isSubtypeOf(genParam)) {
        throw BSCException(
            'List literal element ${param.toStringWithStack(scope.stack, line, col, workspace, file, false, scope.environment)} (${param.typeC(scope, scope.stack, line, col, workspace, file, scope.environment)}) is not a subtype of $genParam ${formatCursorPosition(line, col, workspace, file)}\n${scope.stack.reversed.join('\n')}',
            scope);
      }
    }
    return ValueWrapper(ListValueType(genParam, file, tv), params, 'literal');
  }
}

class ShiftRightExpression extends Expression {
  final Expression a;
  final Expression b;
  bool isLValue(TypeValidator scope) => false;

  String toString() => '$a >> $b';

  ShiftRightExpression(this.a, this.b, int line, int col, String workspace, file, TypeValidator tv) : super(line, col, workspace, file, tv);
  @override
  ValueWrapper eval(Scope scope) {
    ValueWrapper av = a.eval(scope);
    ValueWrapper bv = b.eval(scope);
    if (!(av.typeC(scope, scope.stack, line, col, workspace, file, scope.environment).isSubtypeOf(tv.environment.integerType) &&
        bv.typeC(scope, scope.stack, line, col, workspace, file, scope.environment).isSubtypeOf(tv.environment.integerType))) {
      throw BSCException(
          '$av ($a) or $bv ($b) is not an integer; attempted $a>>$b ${formatCursorPosition(line, col, workspace, file)}\n ${scope.stack.reversed.join('\n')}',
          scope);
    }
    return ValueWrapper(
        tv.environment.integerType,
        av.valueC<int>(scope, scope.stack, line, col, workspace, file, scope.environment) >>
            bv.valueC<int>(scope, scope.stack, line, col, workspace, file, scope.environment),
        '$this result');
  }

  ValueType get type => tv.environment.integerType;
}

class ShiftLeftExpression extends Expression {
  final Expression a;
  final Expression b;
  bool isLValue(TypeValidator scope) => false;

  String toString() {
    return '$a << $b';
  }

  ShiftLeftExpression(this.a, this.b, int line, int col, String workspace, file, TypeValidator tv) : super(line, col, workspace, file, tv);
  @override
  ValueWrapper eval(Scope scope) {
    ValueWrapper av = a.eval(scope);
    ValueWrapper bv = b.eval(scope);
    if (!(av.typeC(scope, scope.stack, line, col, workspace, file, scope.environment).isSubtypeOf(tv.environment.integerType) &&
        bv.typeC(scope, scope.stack, line, col, workspace, file, scope.environment).isSubtypeOf(tv.environment.integerType))) {
      throw BSCException(
          '$av ($a) or $bv ($b) is not an integer; attempted $a<<$b ${formatCursorPosition(line, col, workspace, file)}\n ${scope.stack.reversed.join('\n')}',
          scope);
    }
    return ValueWrapper(
        tv.environment.integerType,
        av.valueC<int>(scope, scope.stack, line, col, workspace, file, scope.environment) <<
            bv.valueC<int>(scope, scope.stack, line, col, workspace, file, scope.environment),
        Concat(this, ' result'));
  }

  ValueType get type => tv.environment.integerType;
}

class GreaterExpression extends Expression {
  final Expression a;
  final Expression b;

  bool isLValue(TypeValidator scope) => false;
  GreaterExpression(this.a, this.b, int line, int col, String workspace, file, TypeValidator tv) : super(line, col, workspace, file, tv);
  @override
  ValueWrapper eval(Scope scope) {
    ValueWrapper av = a.eval(scope);
    ValueWrapper bv = b.eval(scope);
    if (!(av.typeC(scope, scope.stack, line, col, workspace, file, scope.environment).isSubtypeOf(tv.environment.integerType) &&
        bv.typeC(scope, scope.stack, line, col, workspace, file, scope.environment).isSubtypeOf(tv.environment.integerType))) {
      throw BSCException(
          '$av ($a) or $bv ($b) is not an integer; attempted $a>$b ${formatCursorPosition(line, col, workspace, file)}\n ${scope.stack.reversed.join('\n')}',
          scope);
    }
    return ValueWrapper(
        tv.environment.booleanType,
        av.valueC<int>(scope, scope.stack, line, col, workspace, file, scope.environment) >
            bv.valueC<int>(scope, scope.stack, line, col, workspace, file, scope.environment),
        '$this result');
  }

  String toString() => '$a > $b';

  ValueType get type => tv.environment.booleanType;
}

class LessExpression extends Expression {
  final Expression a;
  final Expression b;

  String toString() => '$a < $b';

  bool isLValue(TypeValidator scope) => false;
  LessExpression(this.a, this.b, int line, int col, String workspace, file, TypeValidator tv) : super(line, col, workspace, file, tv);
  @override
  ValueWrapper eval(Scope scope) {
    ValueWrapper av = a.eval(scope);
    ValueWrapper bv = b.eval(scope);
    if (!(av.typeC(scope, scope.stack, line, col, workspace, file, scope.environment).isSubtypeOf(tv.environment.integerType) &&
        bv.typeC(scope, scope.stack, line, col, workspace, file, scope.environment).isSubtypeOf(tv.environment.integerType))) {
      throw BSCException(
          '${av.toStringWithStack(scope.stack, line, col, workspace, file, false, scope.environment)} ($a) or ${bv.toStringWithStack(scope.stack, line, col, workspace, file, false, scope.environment)} ($b) is not an integer; attempted $a<$b ${formatCursorPosition(line, col, workspace, file)}\n ${scope.stack.reversed.join('\n')}',
          scope);
    }
    return ValueWrapper(
        tv.environment.booleanType,
        av.valueC<int>(scope, scope.stack, line, col, workspace, file, scope.environment) <
            bv.valueC<int>(scope, scope.stack, line, col, workspace, file, scope.environment),
        LazyInterpolatorSpace(this, 'result'));
  }

  ValueType get type => tv.environment.booleanType;
}

class BitOrExpression extends Expression {
  final Expression a;
  final Expression b;
  bool isLValue(TypeValidator scope) => false;

  ValueType get type => tv.environment.integerType;

  String toString() => '$a | $b';

  BitOrExpression(this.a, this.b, int line, int col, String workspace, file, TypeValidator tv) : super(line, col, workspace, file, tv);
  @override
  ValueWrapper eval(Scope scope) {
    ValueWrapper av = a.eval(scope);
    ValueWrapper bv = b.eval(scope);
    if (!(av.typeC(scope, scope.stack, line, col, workspace, file, scope.environment).isSubtypeOf(tv.environment.integerType) &&
        bv.typeC(scope, scope.stack, line, col, workspace, file, scope.environment).isSubtypeOf(tv.environment.integerType))) {
      throw BSCException(
          '${av.toStringWithStack(scope.stack, line, col, workspace, file, false, scope.environment)} ($a) or ${bv.toStringWithStack(scope.stack, line, col, workspace, file, false, scope.environment)} ($b) is not an integer; attempted $a|$b ${formatCursorPosition(line, col, workspace, file)}\n${scope.stack.reversed.join('\n')}',
          scope);
    }
    return ValueWrapper(
        tv.environment.integerType,
        av.valueC<int>(scope, scope.stack, line, col, workspace, file, scope.environment) |
            bv.valueC<int>(scope, scope.stack, line, col, workspace, file, scope.environment),
        '$this result');
  }
}

class AndExpression extends Expression {
  final Expression a;
  final Expression b;

  bool isLValue(TypeValidator scope) => false;
  String toString() => '$a && $b';

  AndExpression(this.a, this.b, int line, int col, String workspace, file, TypeValidator tv) : super(line, col, workspace, file, tv);
  @override
  ValueWrapper eval(Scope scope) {
    ValueWrapper av = a.eval(scope);
    if (!av.typeC(scope, scope.stack, line, col, workspace, file, scope.environment).isSubtypeOf(tv.environment.booleanType)) {
      throw BSCException(
          '$av ($a) is not an boolean; attempted $a&&$b ${formatCursorPosition(line, col, workspace, file)}\n ${scope.stack.reversed.join('\n')}', scope);
    }
    if (!av.valueC(scope, scope.stack, line, col, workspace, file, scope.environment)) {
      return av;
    }
    ValueWrapper bv = b.eval(scope);
    if (!bv.typeC(scope, scope.stack, line, col, workspace, file, scope.environment).isSubtypeOf(tv.environment.booleanType)) {
      throw BSCException(
          '$bv ($b) is not an boolean; attempted $a&&$b ${formatCursorPosition(line, col, workspace, file)}\n ${scope.stack.reversed.join('\n')}', scope);
    }
    return bv;
  }

  ValueType get type => tv.environment.booleanType;
}

class OrExpression extends Expression {
  final Expression a;
  final Expression b;
  bool isLValue(TypeValidator scope) => false;

  OrExpression(this.a, this.b, int line, int col, String workspace, file, TypeValidator tv) : super(line, col, workspace, file, tv);
  @override
  ValueWrapper eval(Scope scope) {
    ValueWrapper av = a.eval(scope);
    if (!av.typeC(scope, scope.stack, line, col, workspace, file, scope.environment).isSubtypeOf(tv.environment.booleanType)) {
      throw BSCException(
          '$av ($a) is not an boolean; attempted $a||$b ${formatCursorPosition(line, col, workspace, file)}\n ${scope.stack.reversed.join('\n')}', scope);
    }
    if (av.valueC(scope, scope.stack, line, col, workspace, file, scope.environment)) {
      return av;
    }
    ValueWrapper bv = b.eval(scope);
    if (!bv.typeC(scope, scope.stack, line, col, workspace, file, scope.environment).isSubtypeOf(tv.environment.booleanType)) {
      throw BSCException(
          '${bv.toStringWithStack(scope.stack, line, col, workspace, file, false, scope.environment)} ($b) is not an boolean; attempted $a||$b ${formatCursorPosition(line, col, workspace, file)}\n ${scope.stack.reversed.join('\n')}',
          scope);
    }
    return bv;
  }

  String toString() => '$a || $b';

  ValueType get type => tv.environment.booleanType;
}
