import 'dart:math';

import 'parser-core.dart';
import 'lexer.dart';

abstract class Expression {
  Expression(this.line, this.col, this.workspace, this.file);
  final int line, col;
  final String workspace, file;
  ValueWrapper eval(Scope scope);

  ValueType get type;
  Expression get internal => this;
}

class AssertExpression extends Expression {
  final Expression condition;
  final Expression comment;

  @override
  ValueType get type => nullType;

  String toString() => "assert($condition, $comment)";

  AssertExpression(this.condition, this.comment, int line, int col, String workspace, String file) : super(line, col, workspace, file);
  @override
  ValueWrapper eval(Scope scope) {
    ValueWrapper conditionEval = condition.eval(scope);
    if (!conditionEval.typeC(scope, scope.stack, line, col, workspace, file).isSubtypeOf(booleanType)) {
      throw BSCException(
        "argument 0 of assert, $conditionEval ($condition), of wrong type (${conditionEval.typeC(scope, scope.stack, line, col, workspace, file)}) expected boolean ${formatCursorPosition(line, col, workspace, file)}\n${scope.stack.reversed.join('\n')}",
      );
    }
    if (!conditionEval.valueC(scope, scope.stack, line, col, workspace, file)) {
      ValueWrapper commentEval = comment.eval(scope);
      if (!commentEval.typeC(scope, scope.stack, line, col, workspace, file).isSubtypeOf(stringType)) {
        throw BSCException(
          "argument 1 of assert, $commentEval ($comment), of wrong type (${commentEval.typeC(scope, scope.stack, line, col, workspace, file)}) expected string ${formatCursorPosition(line, col, workspace, file)}\n${scope.stack.reversed.join('\n')}",
        );
      }
      throw AssertException(
        commentEval.valueC<String>(scope, scope.stack, line, col, workspace, file) +
            ' ($condition was not true) ${formatCursorPosition(line, col, workspace, file)}\n${scope.stack.reversed.join('\n')}',
      );
    }
    return ValueWrapper(nullType, null, 'rtv of assert');
  }
}

class GetExpr extends Expression {
  final Variable name;

  GetExpr(this.name, this.typeValidator, int line, col, String workspace, file) : super(line, col, workspace, file) {
    typeValidator.getVar(name, 0, line, col, workspace, file, 'getexpr constructor');
  }

  final TypeValidator typeValidator;

  ValueType get type => typeValidator.igv(name, true, line, col, workspace, file) ?? (throw "$name does not exist");

  @override
  eval(Scope scope) {
    return scope.getVar(name, line, col, workspace, file, typeValidator);
  }

  String toString() => name.name;
}

class EqualsExpression extends Expression {
  final Expression a;
  final Expression b;

  EqualsExpression(this.a, this.b, int line, int col, String workspace, file) : super(line, col, workspace, file);
  @override
  ValueWrapper eval(Scope scope) {
    ValueWrapper ea = a.eval(scope);
    ValueWrapper eb = b.eval(scope);
    ValueWrapper result = ValueWrapper(
        booleanType,
        ea.typeC(scope, scope.stack, line, col, workspace, file) == eb.typeC(scope, scope.stack, line, col, workspace, file) &&
            ea.valueC<Object?>(scope, scope.stack, line, col, workspace, file) == eb.valueC<Object?>(scope, scope.stack, line, col, workspace, file),
        LazyInterpolator(this, 'result'));
    return result;
  }

  String toString() => "$a == $b";

  ValueType get type => booleanType;
}

class BitAndExpression extends Expression {
  final Expression a;
  final Expression b;

  BitAndExpression(this.a, this.b, int line, col, String workspace, file) : super(line, col, workspace, file);
  @override
  ValueWrapper eval(Scope scope) {
    ValueWrapper av = a.eval(scope);
    ValueWrapper bv = b.eval(scope);
    if (!(av.typeC(scope, scope.stack, line, col, workspace, file).isSubtypeOf(integerType) &&
        bv.typeC(scope, scope.stack, line, col, workspace, file).isSubtypeOf(integerType))) {
      throw BSCException(
          "$av ($a) or $bv ($b) is not an integer; attempted $a (a ${av.typeC(scope, scope.stack, line, col, workspace, file)}) & $b (a ${bv.typeC(scope, scope.stack, line, col, workspace, file)}) ${formatCursorPosition(line, col, workspace, file)}\n ${scope.stack.reversed.join('\n')}");
    }
    return ValueWrapper(integerType, av.valueC<int>(scope, scope.stack, line, col, workspace, file) & bv.valueC(scope, scope.stack, line, col, workspace, file),
        '$this result');
  }

  String toString() => "$a & $b";

  ValueType get type => integerType;
}

class BitXorExpression extends Expression {
  final Expression a;
  final Expression b;

  BitXorExpression(this.a, this.b, int line, int col, String workspace, String file) : super(line, col, workspace, file);
  @override
  ValueWrapper eval(Scope scope) {
    ValueWrapper av = a.eval(scope);
    ValueWrapper bv = b.eval(scope);
    if (!(av.typeC(scope, scope.stack, line, col, workspace, file).isSubtypeOf(integerType) &&
        bv.typeC(scope, scope.stack, line, col, workspace, file).isSubtypeOf(integerType))) {
      throw BSCException(
          "$av ($a) or $bv ($b) is not an integer; attempted $a (a ${av.typeC(scope, scope.stack, line, col, workspace, file)}) & $b (a ${bv.typeC(scope, scope.stack, line, col, workspace, file)}) ${formatCursorPosition(line, col, workspace, file)}\n ${scope.stack.reversed.join('\n')}");
    }
    return ValueWrapper(
      integerType,
      av.valueC<int>(scope, scope.stack, line, col, workspace, file) ^ bv.valueC(scope, scope.stack, line, col, workspace, file),
      LazyInterpolator(this, 'result'),
    );
  }

  String toString() => "$a ^ $b";

  ValueType get type => integerType;
}

class SubscriptExpression extends Expression {
  final Expression a;
  final Expression b;

  ValueType get type =>
      a.type.name == whateverVariable ? ValueType.create(null, whateverVariable, -2, 0, 'interr', '_') : (a.type as ListValueType).genericParameter;

  String toString() => "$a[$b]";

  SubscriptExpression(this.a, this.b, int line, col, String workspace, file) : super(line, col, workspace, file);
  @override
  eval(Scope scope) {
    ValueWrapper list = a.eval(scope);
    ValueWrapper iV = b.eval(scope);
    if (iV.valueC(scope, scope.stack, line, col, workspace, file) is! int)
      throw BSCException(
          '$b is not integer, is ${iV.typeC(scope, scope.stack, line, col, workspace, file)} ${formatCursorPosition(line, col, workspace, file)}\n${scope.stack.reversed.join('\n')}');
    int index = iV.valueC(scope, scope.stack, line, col, workspace, file);
    return fancySubscript(list, index, scope);
  }

  ValueWrapper fancySubscript(ValueWrapper list, int index, Scope scope) {
    Object? listValue = list.valueC(scope, scope.stack, line, col, workspace, file);
    if (listValue is! List) {
      throw BSCException(
        "$a is not list ${formatCursorPosition(line, col, workspace, file)}",
      );
    }
    if (listValue.length <= index || index < 0) {
      throw BSCException(
        "RangeError: $list ($a) has ${listValue.length} elements, but it was subscripted with element $index. ${formatCursorPosition(line, col, workspace, file)}\n${scope.stack.reversed.join('\n')}",
      );
    }
    return list.typeC(scope, scope.stack, line, col, workspace, file) == stringType
        ? ValueWrapper(stringType, listValue[index], 'subscript expr result')
        : listValue[index];
  }
}

class MemberAccessExpression extends Expression {
  final Expression a;
  final Variable b;

  ValueType get type => a.type.name != whateverVariable ? (a.type as ClassValueType).properties.igv(b, true, line, col, workspace, file)! : sharedSupertype;

  MemberAccessExpression(this.a, this.b, int l, int c, String workspace, file) : super(l, c, workspace, file);
  @override
  eval(Scope scope) {
    ValueWrapper thisScopeWrapper = a.eval(scope);
    if (thisScopeWrapper.typeC(scope, scope.stack, line, col, workspace, file) is! ClassValueType) {
      throw BSCException(
          "$thisScopeWrapper ($a) is not an instance of a class, it's a ${thisScopeWrapper.typeC(scope, scope.stack, line, col, workspace, file)} ${formatCursorPosition(line, col, workspace, file)}\n${scope.stack.reversed.join('\n')}");
    }
    Scope thisScope = thisScopeWrapper.valueC(scope, scope.stack, line, col, workspace, file);
    return thisScope.getVar(b, line, col, workspace, file, null);
  }

  String toString() => "$a.$b";
}

class IsExpr extends Expression {
  final Expression operand;
  final ValueType isType;

  IsExpr(this.operand, this.isType, int l, c, String workspace, file) : super(l, c, workspace, file);

  String toString() => "$operand is $isType";

  ValueType type = booleanType;

  @override
  ValueWrapper eval(Scope scope) {
    ValueType possibleChildType = operand.eval(scope).typeC(scope, scope.stack, line, col, workspace, file);
    return ValueWrapper(booleanType, possibleChildType.isSubtypeOf(isType), '$this result');
  }
}

class AsExpr extends Expression {
  final Expression operand;
  final ValueType isType;

  AsExpr(this.operand, this.isType, int l, c, String workspace, file) : super(l, c, workspace, file);

  String toString() => "$operand as $isType";

  late ValueType type = isType;

  @override
  ValueWrapper eval(Scope scope) {
    ValueWrapper op = operand.eval(scope);
    ValueType possibleChildType = op.typeC(scope, scope.stack, line, col, workspace, file);
    if (possibleChildType is IterableValueType && isType is IterableValueType && !possibleChildType.isSubtypeOf(isType)) {
      for (ValueWrapper x in op.valueC(scope, scope.stack, line, col, workspace, file)) {
        if (!x.typeC(scope, scope.stack, line, col, workspace, file).isSubtypeOf((isType as IterableValueType).genericParameter)) {
          throw BSCException(
              "${operand.type} as ${isType} had invalid element type; expected ${(isType as IterableValueType).genericParameter} got $x (a ${x.typeC(scope, scope.stack, line, col, workspace, file)}) ${formatCursorPosition(line, col, workspace, file)}");
        }
      }
      return ValueWrapper(isType, op.valueC(scope, scope.stack, line, col, workspace, file), 'as (list.cast style)');
    }
    if (!possibleChildType.isSubtypeOf(isType)) {
      throw BSCException("as failed; expected $isType got $op (a $possibleChildType) ${formatCursorPosition(line, col, workspace, file)}");
    }
    return op;
  }
}

class NotExpression extends Expression {
  final Expression a;

  NotExpression(this.a, int line, int col, String workspace, file) : super(line, col, workspace, file);

  String toString() => '!$a';
  @override
  ValueWrapper eval(Scope scope) {
    ValueWrapper aEval = a.eval(scope);
    if (!aEval.typeC(scope, scope.stack, line, col, workspace, file).isSubtypeOf(booleanType)) {
      throw BSCException(
          'Attempted !$a but $aEval was not a boolean (was ${aEval.typeC(scope, scope.stack, line, col, workspace, file)}) ${formatCursorPosition(line, col, workspace, file)}\n${scope.stack.reversed.join('\n')}}');
    }
    return ValueWrapper(booleanType, !aEval.valueC(scope, scope.stack, line, col, workspace, file), '$this result');
  }

  ValueType get type => booleanType;
}

class BitNotExpression extends Expression {
  final Expression a;

  BitNotExpression(this.a, int line, int col, String workspace, file) : super(line, col, workspace, file);
  @override
  ValueWrapper eval(Scope scope) {
    ValueWrapper aEval = a.eval(scope);
    if (!aEval.typeC(scope, scope.stack, line, col, workspace, file).isSubtypeOf(integerType)) {
      throw BSCException(
          'Attempted !$a but $aEval was not an integer (was ${aEval.typeC(scope, scope.stack, line, col, workspace, file)}) ${formatCursorPosition(line, col, workspace, file)}\n${scope.stack.reversed.join('\n')}}');
    }
    return ValueWrapper(integerType, ~a.eval(scope).valueC<int>(scope, scope.stack, line, col, workspace, file), '$this result');
  }

  String toString() => "~$a";

  ValueType get type => integerType;
}

class MultiplyExpression extends Expression {
  final Expression a;
  final Expression b;
  String toString() => "$a * $b";

  MultiplyExpression(this.a, this.b, int line, int col, String workspace, file) : super(line, col, workspace, file);
  @override
  ValueWrapper eval(Scope scope) {
    ValueWrapper aEval = a.eval(scope);
    if (!aEval.typeC(scope, scope.stack, line, col, workspace, file).isSubtypeOf(integerType)) {
      throw BSCException(
          'Attempted $a*$b but $aEval was not an integer (was ${aEval.typeC(scope, scope.stack, line, col, workspace, file)}) ${formatCursorPosition(line, col, workspace, file)}\n${scope.stack.reversed.join('\n')}}');
    }
    ValueWrapper bEval = b.eval(scope);
    if (!bEval.typeC(scope, scope.stack, line, col, workspace, file).isSubtypeOf(integerType)) {
      throw BSCException(
          'Attempted $a*$b but $bEval was not an integer (was ${bEval.typeC(scope, scope.stack, line, col, workspace, file)}) ${formatCursorPosition(line, col, workspace, file)}\n${scope.stack.reversed.join('\n')}}');
    }
    return ValueWrapper(integerType,
        aEval.valueC<int>(scope, scope.stack, line, col, workspace, file) * bEval.valueC<int>(scope, scope.stack, line, col, workspace, file), '$this result');
  }

  ValueType get type => integerType;
}

class DivideExpression extends Expression {
  final Expression a;
  final Expression b;

  DivideExpression(this.a, this.b, int line, int col, String workspace, file) : super(line, col, workspace, file);
  @override
  ValueWrapper eval(Scope scope) {
    ValueWrapper av = a.eval(scope);
    ValueWrapper bv = b.eval(scope);
    if (!(av.typeC(scope, scope.stack, line, col, workspace, file).isSubtypeOf(integerType) &&
        bv.typeC(scope, scope.stack, line, col, workspace, file).isSubtypeOf(integerType))) {
      throw BSCException(
          "$av ($a) or $bv ($b) is not an integer; attempted $a/$b ${formatCursorPosition(line, col, workspace, file)}\n ${scope.stack.reversed.join('\n')}");
    }
    return ValueWrapper(integerType,
        av.valueC<int>(scope, scope.stack, line, col, workspace, file) ~/ bv.valueC<int>(scope, scope.stack, line, col, workspace, file), '$this result');
  }

  ValueType get type => integerType;
}

class PowExpression extends Expression {
  final Expression a;
  final Expression b;

  PowExpression(this.a, this.b, int line, int col, String workspace, file) : super(line, col, workspace, file);
  @override
  ValueWrapper eval(Scope scope) {
    return ValueWrapper(
        integerType,
        pow(a.eval(scope).valueC(scope, scope.stack, line, col, workspace, file), b.eval(scope).valueC(scope, scope.stack, line, col, workspace, file)),
        '$this result');
  }

  ValueType get type => integerType;
}

class RemainderExpression extends Expression {
  final Expression a;
  final Expression b;

  String toString() => "$a % $b";

  RemainderExpression(this.a, this.b, int line, int col, String workspace, file) : super(line, col, workspace, file);
  @override
  ValueWrapper eval(Scope scope) {
    ValueWrapper av = a.eval(scope);
    ValueWrapper bv = b.eval(scope);
    if (!(av.typeC(scope, scope.stack, line, col, workspace, file).isSubtypeOf(integerType) &&
        bv.typeC(scope, scope.stack, line, col, workspace, file).isSubtypeOf(integerType))) {
      throw BSCException(
          "$av ($a) or $bv ($b) is not an integer; attempted $a%$b ${formatCursorPosition(line, col, workspace, file)}\n ${scope.stack.reversed.join('\n')}");
    }
    if (bv.valueC(scope, scope.stack, line, col, workspace, file) == 0) {
      throw BSCException(
          "$a (${av.valueC(scope, scope.stack, line, col, workspace, file)}) % $b (0) attempted ${formatCursorPosition(line, col, workspace, file)} stack ${scope.stack.join('\n')}");
    }
    return ValueWrapper(integerType,
        av.valueC<int>(scope, scope.stack, line, col, workspace, file) % bv.valueC<int>(scope, scope.stack, line, col, workspace, file), '$this result');
  }

  ValueType get type => integerType;
}

class SubtractExpression extends Expression {
  final Expression a;
  final Expression b;

  SubtractExpression(this.a, this.b, int line, int col, String workspace, file) : super(line, col, workspace, file);
  @override
  ValueWrapper eval(Scope scope) {
    ValueWrapper av = a.eval(scope);
    ValueWrapper bv = b.eval(scope);
    if (!(av.typeC(scope, scope.stack, line, col, workspace, file).isSubtypeOf(integerType) &&
        bv.typeC(scope, scope.stack, line, col, workspace, file).isSubtypeOf(integerType))) {
      throw BSCException(
          "$av ($a) or $bv ($b) is not an integer; attempted $a-$b ${formatCursorPosition(line, col, workspace, file)}\n ${scope.stack.reversed.join('\n')}");
    }
    return ValueWrapper(integerType,
        av.valueC<int>(scope, scope.stack, line, col, workspace, file) - bv.valueC<int>(scope, scope.stack, line, col, workspace, file), '$this result');
  }

  String toString() => "($a) - ($b)";

  ValueType get type => integerType;
}

class AddExpression extends Expression {
  final Expression a;
  final Expression b;

  AddExpression(this.a, this.b, int line, int col, String workspace, file) : super(line, col, workspace, file);
  @override
  ValueWrapper eval(Scope scope) {
    ValueWrapper av = a.eval(scope);
    ValueWrapper bv = b.eval(scope);
    if (!(av.typeC(scope, scope.stack, line, col, workspace, file).isSubtypeOf(integerType) &&
        bv.typeC(scope, scope.stack, line, col, workspace, file).isSubtypeOf(integerType))) {
      throw BSCException(
          "$av ($a) or $bv ($b) is not an integer; attempted $a+$b ${formatCursorPosition(line, col, workspace, file)}\n ${scope.stack.reversed.join('\n')}");
    }
    return ValueWrapper(
      integerType,
      av.valueC<int>(scope, scope.stack, line, col, workspace, file) + bv.valueC<int>(scope, scope.stack, line, col, workspace, file),
      LazyInterpolator(this, 'result'),
    );
  }

  String toString() => "$a + $b";

  ValueType get type => integerType;
}

class SuperExpression extends Expression {
  SuperExpression(this.member, this.tv, int line, int col, String workspace, file) : super(line, col, workspace, file);
  final Variable member;
  final TypeValidator tv;

  @override
  ValueWrapper eval(Scope scope) {
    ClassValueType classType = scope.currentClass;
    ValueWrapper thisScopeVW = scope.getVar(thisVariable, line, col, 'interr', '<internal error: no this>', tv);
    Scope thisScope = thisScopeVW.valueC(scope, scope.stack, line, col, workspace, file);
    ClassValueType parent = classType;
    Scope superMethods;
    if (classType.supertype == null) {
      throw BSCException("super expression used in a root class");
    }
    do {
      parent = parent.supertype ?? (throw BSCException("super expression failed to find $member in ${classType.supertype!} or supertypes"));
      superMethods = scope
          .getVar(
              variables['~${parent.name.name}~methods'] ?? Variable('~${parent.name.name}~methods'), line, col, 'interr', '<internal error: no methods>', tv)
          .valueC(scope, scope.stack, line, col, workspace, file);
    } while (!superMethods.values.containsKey(member));
    ValueWrapper x = superMethods.getVar(member, line, col, workspace, file, tv);
    return ValueWrapper(
        x.typeC(scope, scope.stack, line, col, workspace, file),
        (List<ValueWrapper> args2, List<LazyString> stack2, [Scope? thisScope2, ValueType? thisType]) => x.valueC<SydFunction>(
            scope, scope.stack, line, col, workspace, file)(args2, stack2, thisScope, thisScopeVW.typeC(scope, scope.stack, line, col, workspace, file)),
        '${classType.name}.super.${member.name}');
  }

  String toString() => "super.${member.name}";

  @override
  ValueType get type => (tv.currentClass.parent is ClassValueType
          ? tv.currentClass.parent as ClassValueType
          : (throw BSCException("${tv.currentClass} has no supertype ${formatCursorPosition(line, col, workspace, file)}")))
      .properties
      .igv(member, true, line, col, workspace, file)!;
}

class IntLiteralExpression extends Expression {
  IntLiteralExpression(this.n, int line, int col, String workspace, file) : super(line, col, workspace, file);
  final int n;
  ValueWrapper eval(Scope scope) => ValueWrapper(integerType, n, 'literal');
  String toString() => "$n";

  ValueType get type => integerType;
}

class StringLiteralExpression extends Expression {
  StringLiteralExpression(this.n, int line, int col, String workspace, file) : super(line, col, workspace, file);
  final String n;
  ValueWrapper eval(Scope scope) => ValueWrapper(stringType, n, 'literal');
  String toString() => "'$n'";
  ValueType get type => stringType;
}

class BoringExpr extends Expression {
  final value;

  final ValueType type;

  BoringExpr(this.value, this.type) : super(-2, 0, 'TODO', 'TODO (boring expr line,column, filename)');
  @override
  eval(Scope scope) {
    return ValueWrapper(type, value, '<todo boring expr vw desc>');
  }

  String toString() => "$value**";
}

class UnwrapExpression extends Expression {
  UnwrapExpression(this.a, int line, int col, String workspace, file) : super(line, col, workspace, file);
  final Expression a;
  @override
  ValueWrapper eval(Scope scope) {
    ValueWrapper aval = a.eval(scope);
    if (aval.valueC(scope, scope.stack, line, col, workspace, file) == null) {
      throw BSCException("Failed unwrap of null ($a) ${formatCursorPosition(line, col, workspace, file)}\n${scope.stack.reversed.join('\n')}");
    }
    return aval;
  }

  String toString() => "$a!";

  @override
  ValueType get type => (a.type as NullableValueType).genericParam;
}

class FunctionCallExpr extends Expression {
  final Expression a;
  final List<Expression> b;

  final TypeValidator validator;

  @override
  ValueType get type => a.type.name.name != 'Whatever' ? (a.type as GenericFunctionValueType).returnType : sharedSupertype;

  String toString() => "$a(${b.join(', ')})";

  FunctionCallExpr(this.a, this.b, this.validator, int line, int col, String workspace, file) : super(line, col, workspace, file);
  @override
  ValueWrapper eval(Scope scope) {
    //print("calling $a...");
    List<ValueWrapper> args = b.map((x) => x.eval(scope)).toList();
    for (int i = 0; i < args.length; i++) {
      if (a.type is FunctionValueType &&
          !args[i].typeC(scope, scope.stack, line, col, workspace, file).isSubtypeOf((a.type as FunctionValueType).parameters.elementAt(i))) {
        throw BSCException(
            "argument #$i of $a, ${args[i]} (${b[i]}), of wrong type (${args[i].typeC(scope, scope.stack, line, col, workspace, file)}) expected ${(a.type as FunctionValueType).parameters.elementAt(i)} ${formatCursorPosition(line, col, workspace, file)}\n${scope.stack.reversed.join('\n')}");
      }
    }
    //print("evaluated arguments...");
    List<LazyString> newStack = scope.stack.toList();
    if (newStack.last is NotLazyString) {
      newStack[newStack.length - 1] = CursorPositionLazyString((newStack.last as NotLazyString).str, line, col, workspace, file);
    }
    ValueWrapper aEval = a.eval(scope);
    if (!aEval.typeC(scope, scope.stack, line, col, workspace, file).isSubtypeOf(GenericFunctionValueType(sharedSupertype, '__test'))) {
      throw BSCException('tried to call non-function: $aEval, ${formatCursorPosition(line, col, workspace, file)}\n${scope.stack.reversed.join('\n')}');
    }
    return aEval.valueC<SydFunction>(scope, scope.stack, line, col, workspace, file)(args, newStack);
  }
}

class ListLiteralExpression extends Expression {
  ListLiteralExpression(this.n, this.genParam, int line, int col, String workspace, file) : super(line, col, workspace, file);
  final List<Expression> n;
  final ValueType genParam;
  ValueType get type => ListValueType(genParam, file);
  String toString() => "$n:$genParam";
  ValueWrapper eval(Scope scope) => ValueWrapper(ListValueType(genParam, file), n.map((e) => e.eval(scope)).toList(), 'literal');
}

class ShiftRightExpression extends Expression {
  final Expression a;
  final Expression b;

  ShiftRightExpression(this.a, this.b, int line, int col, String workspace, file) : super(line, col, workspace, file);
  @override
  ValueWrapper eval(Scope scope) {
    ValueWrapper av = a.eval(scope);
    ValueWrapper bv = b.eval(scope);
    if (!(av.typeC(scope, scope.stack, line, col, workspace, file).isSubtypeOf(integerType) &&
        bv.typeC(scope, scope.stack, line, col, workspace, file).isSubtypeOf(integerType))) {
      throw BSCException(
          "$av ($a) or $bv ($b) is not an integer; attempted $a>>$b ${formatCursorPosition(line, col, workspace, file)}\n ${scope.stack.reversed.join('\n')}");
    }
    return ValueWrapper(integerType,
        av.valueC<int>(scope, scope.stack, line, col, workspace, file) >> bv.valueC<int>(scope, scope.stack, line, col, workspace, file), '$this result');
  }

  ValueType get type => integerType;
}

class ShiftLeftExpression extends Expression {
  final Expression a;
  final Expression b;

  ShiftLeftExpression(this.a, this.b, int line, int col, String workspace, file) : super(line, col, workspace, file);
  @override
  ValueWrapper eval(Scope scope) {
    ValueWrapper av = a.eval(scope);
    ValueWrapper bv = b.eval(scope);
    if (!(av.typeC(scope, scope.stack, line, col, workspace, file).isSubtypeOf(integerType) &&
        bv.typeC(scope, scope.stack, line, col, workspace, file).isSubtypeOf(integerType))) {
      throw BSCException(
          "$av ($a) or $bv ($b) is not an integer; attempted $a<<$b ${formatCursorPosition(line, col, workspace, file)}\n ${scope.stack.reversed.join('\n')}");
    }
    return ValueWrapper(integerType,
        av.valueC<int>(scope, scope.stack, line, col, workspace, file) << bv.valueC<int>(scope, scope.stack, line, col, workspace, file), '$this result');
  }

  ValueType get type => integerType;
}

class GreaterExpression extends Expression {
  final Expression a;
  final Expression b;

  GreaterExpression(this.a, this.b, int line, int col, String workspace, file) : super(line, col, workspace, file);
  @override
  ValueWrapper eval(Scope scope) {
    ValueWrapper av = a.eval(scope);
    ValueWrapper bv = b.eval(scope);
    if (!(av.typeC(scope, scope.stack, line, col, workspace, file).isSubtypeOf(integerType) &&
        bv.typeC(scope, scope.stack, line, col, workspace, file).isSubtypeOf(integerType))) {
      throw BSCException(
          "$av ($a) or $bv ($b) is not an integer; attempted $a>$b ${formatCursorPosition(line, col, workspace, file)}\n ${scope.stack.reversed.join('\n')}");
    }
    return ValueWrapper(booleanType,
        av.valueC<int>(scope, scope.stack, line, col, workspace, file) > bv.valueC<int>(scope, scope.stack, line, col, workspace, file), '$this result');
  }

  String toString() => "$a > $b";

  ValueType get type => booleanType;
}

class LessExpression extends Expression {
  final Expression a;
  final Expression b;

  LessExpression(this.a, this.b, int line, int col, String workspace, file) : super(line, col, workspace, file);
  @override
  ValueWrapper eval(Scope scope) {
    ValueWrapper av = a.eval(scope);
    ValueWrapper bv = b.eval(scope);
    if (!(av.typeC(scope, scope.stack, line, col, workspace, file).isSubtypeOf(integerType) &&
        bv.typeC(scope, scope.stack, line, col, workspace, file).isSubtypeOf(integerType))) {
      throw BSCException(
          "$av ($a) or $bv ($b) is not an integer; attempted $a<$b ${formatCursorPosition(line, col, workspace, file)}\n ${scope.stack.reversed.join('\n')}");
    }
    return ValueWrapper(booleanType,
        av.valueC<int>(scope, scope.stack, line, col, workspace, file) < bv.valueC<int>(scope, scope.stack, line, col, workspace, file), '$this result');
  }

  ValueType get type => booleanType;
}

class BitOrExpression extends Expression {
  final Expression a;
  final Expression b;

  ValueType type = integerType;

  String toString() => "$a | $b";

  BitOrExpression(this.a, this.b, int line, int col, String workspace, file) : super(line, col, workspace, file);
  @override
  ValueWrapper eval(Scope scope) {
    ValueWrapper av = a.eval(scope);
    ValueWrapper bv = b.eval(scope);
    if (!(av.typeC(scope, scope.stack, line, col, workspace, file).isSubtypeOf(integerType) &&
        bv.typeC(scope, scope.stack, line, col, workspace, file).isSubtypeOf(integerType))) {
      throw BSCException(
          "$av ($a) or $bv ($b) is not an integer; attempted $a|$b ${formatCursorPosition(line, col, workspace, file)}\n${scope.stack.reversed.join('\n')}");
    }
    return ValueWrapper(integerType,
        av.valueC<int>(scope, scope.stack, line, col, workspace, file) | bv.valueC<int>(scope, scope.stack, line, col, workspace, file), '$this result');
  }
}

class AndExpression extends Expression {
  final Expression a;
  final Expression b;

  String toString() => '$a && $b';

  AndExpression(this.a, this.b, int line, int col, String workspace, file) : super(line, col, workspace, file);
  @override
  ValueWrapper eval(Scope scope) {
    ValueWrapper av = a.eval(scope);
    if (!av.typeC(scope, scope.stack, line, col, workspace, file).isSubtypeOf(booleanType)) {
      throw BSCException(
          "$av ($a) is not an boolean; attempted $a&&$b ${formatCursorPosition(line, col, workspace, file)}\n ${scope.stack.reversed.join('\n')}");
    }
    if (!av.valueC(scope, scope.stack, line, col, workspace, file)) {
      return av;
    }
    ValueWrapper bv = b.eval(scope);
    if (!bv.typeC(scope, scope.stack, line, col, workspace, file).isSubtypeOf(booleanType)) {
      throw BSCException(
          "$bv ($b) is not an boolean; attempted $a&&$b ${formatCursorPosition(line, col, workspace, file)}\n ${scope.stack.reversed.join('\n')}");
    }
    return bv;
  }

  ValueType get type => booleanType;
}

class OrExpression extends Expression {
  final Expression a;
  final Expression b;

  OrExpression(this.a, this.b, int line, int col, String workspace, file) : super(line, col, workspace, file);
  @override
  ValueWrapper eval(Scope scope) {
    ValueWrapper av = a.eval(scope);
    if (!av.typeC(scope, scope.stack, line, col, workspace, file).isSubtypeOf(booleanType)) {
      throw BSCException(
          "$av ($a) is not an boolean; attempted $a||$b ${formatCursorPosition(line, col, workspace, file)}\n ${scope.stack.reversed.join('\n')}");
    }
    if (av.valueC(scope, scope.stack, line, col, workspace, file)) {
      return av;
    }
    ValueWrapper bv = b.eval(scope);
    if (!bv.typeC(scope, scope.stack, line, col, workspace, file).isSubtypeOf(booleanType)) {
      throw BSCException(
          "$bv ($b) is not an boolean; attempted $a||$b ${formatCursorPosition(line, col, workspace, file)}\n ${scope.stack.reversed.join('\n')}");
    }
    return bv;
  }

  String toString() => "$a || $b";

  ValueType get type => booleanType;
}
