import 'parser-core.dart';
import 'lexer.dart';

abstract class Expression {
  Expression(this.line, this.col, this.file);
  final int line, col;
  final String file;
  ValueWrapper eval(Scope scope);

  ValueType get type;
  Expression get internal => this;
}

class GetExpr<T> extends Expression {
  final String name;

  GetExpr(this.name, this.typeValidator, int line, int col, String file)
      : super(line, col, file);

  final TypeValidator typeValidator;

  ValueType get type =>
      typeValidator.types[name] ?? (throw "$name does not exist");

  @override
  eval(Scope scope) {
    return scope.getVar(name, line, col, "unknown");
  }

  String toString() => name;
}

class EqualsExpression extends Expression {
  final Expression a;
  final Expression b;

  EqualsExpression(this.a, this.b, int line, int col, String file)
      : super(line, col, file);
  @override
  ValueWrapper eval(Scope scope) {
    ValueWrapper ea = a.eval(scope);
    ValueWrapper eb = b.eval(scope);
    ValueWrapper result = ValueWrapper(booleanType,
        ea.type == eb.type && ea.value == eb.value, '$this result');
    return result;
  }

  String toString() => "$a == $b";

  ValueType get type => booleanType;
}

class BitAndExpression extends Expression {
  final Expression a;
  final Expression b;

  BitAndExpression(this.a, this.b, int line, int col, String file)
      : super(line, col, file);
  @override
  ValueWrapper eval(Scope scope) {
    return ValueWrapper(
        integerType, a.eval(scope).value & b.eval(scope).value, '$this result');
  }

  ValueType get type => integerType;
}

class BitXorExpression extends Expression {
  final Expression a;
  final Expression b;

  BitXorExpression(this.a, this.b, int line, int col, String file)
      : super(line, col, file);
  @override
  ValueWrapper eval(Scope scope) {
    return ValueWrapper(
        integerType, a.eval(scope).value ^ b.eval(scope).value, '$this result');
  }

  ValueType get type => integerType;
}

class SubscriptExpression extends Expression {
  final Expression a;
  final Expression b;

  ValueType get type => a.type.name == "Whatever"
      ? ValueType(null, "Whatever", -2, 0, '_')
      : (a.type as ListValueType).genericParameter;

  String toString() => "$a[$b]";

  SubscriptExpression(this.a, this.b, int line, int col, String file)
      : super(line, col, file);
  @override
  eval(Scope scope) {
    ValueWrapper list = a.eval(scope);
    ValueWrapper iV = b.eval(scope);
    if (iV.value is! int)
      throw FileInvalid(
          '$b is not integer, is ${iV.type} ${formatCursorPosition(line, col, file)}\n${scope.stack.reversed.join('\n')}');
    int index = iV.value;
    return fancySubscript(list, index, scope);
  }

  ValueWrapper fancySubscript(ValueWrapper list, int index, Scope scope) {
    if (list.value is! List) {
      throw FileInvalid(
          "$a is not list ${formatCursorPosition(line, col, file)}");
    }
    if (list.value.length <= index || index < 0) {
      throw FileInvalid(
          "RangeError: $list ($a) has ${list.value.length} elements, but it was subscripted with element $index. ${formatCursorPosition(line, col, file)}");
    }
    return list.type == stringType
        ? ValueWrapper(stringType, list.value[index], 'subscript expr result')
        : list.value[index];
  }
}

class MemberAccessExpression extends Expression {
  final Expression a;
  final String b;

  ValueType get type => a.type.name != 'Whatever'
      ? (a.type as ClassValueType).properties.types[b]!
      : sharedSupertype;

  MemberAccessExpression(this.a, this.b, int l, int c, String file)
      : super(l, c, file);
  @override
  eval(Scope scope) {
    ValueWrapper thisScopeWrapper = a.eval(scope);
    if (thisScopeWrapper.type is! ClassValueType) {
      throw FileInvalid(
          "$thisScopeWrapper ($a) is not an instance of a class, it's a ${thisScopeWrapper.type} ${formatCursorPosition(line, col, file)}\n${scope.stack.reversed.join('\n')}");
    }
    Scope thisScope = thisScopeWrapper.value;
    return thisScope.getVar(b, line, col, file);
  }

  String toString() => "$a.$b";
}

class IsExpr extends Expression {
  final Expression operand;
  final ValueType isType;

  IsExpr(this.operand, this.isType, int l, c, String file) : super(l, c, file);

  String toString() => "$operand is $isType";

  ValueType type = booleanType;

  @override
  ValueWrapper eval(Scope scope) {
    ValueType possibleChildType = operand.eval(scope).type;
    return ValueWrapper(
        booleanType, possibleChildType.isSubtypeOf(isType), '$this result');
  }
}

class AsExpr extends Expression {
  final Expression operand;
  final ValueType isType;

  AsExpr(this.operand, this.isType, int l, c, String file) : super(l, c, file);

  String toString() => "$operand as $isType";

  late ValueType type = isType;

  @override
  ValueWrapper eval(Scope scope) {
    ValueWrapper op = operand.eval(scope);
    ValueType possibleChildType = op.type;
    if (possibleChildType is IterableValueType &&
        isType is IterableValueType &&
        !possibleChildType.isSubtypeOf(isType)) {
      for (ValueWrapper x in op.value) {
        if (!x.type
            .isSubtypeOf((isType as IterableValueType).genericParameter)) {
          throw FileInvalid(
              "${operand.type} as ${isType} had invalid element type; expected ${(isType as IterableValueType).genericParameter} got $x (a ${x.type}) ${formatCursorPosition(line, col, file)}");
        }
      }
      return ValueWrapper(isType, op.value, 'as (list.cast style)');
    }
    if (!possibleChildType.isSubtypeOf(isType)) {
      throw FileInvalid(
          "as failed; expected $isType got $op (a $possibleChildType) ${formatCursorPosition(line, col, file)}");
    }
    return op;
  }
}

class NotExpression extends Expression {
  final Expression a;

  NotExpression(this.a, int line, int col, String file)
      : super(line, col, file);
  @override
  ValueWrapper eval(Scope scope) {
    return ValueWrapper(booleanType, !a.eval(scope).value, '$this result');
  }

  ValueType get type => booleanType;
}

class BitNotExpression extends Expression {
  final Expression a;

  BitNotExpression(this.a, int line, int col, String file)
      : super(line, col, file);
  @override
  ValueWrapper eval(Scope scope) {
    return ValueWrapper(integerType, ~a.eval(scope).value, '$this result');
  }

  ValueType get type => integerType;
}

class MultiplyExpression extends Expression {
  final Expression a;
  final Expression b;

  MultiplyExpression(this.a, this.b, int line, int col, String file)
      : super(line, col, file);
  @override
  ValueWrapper eval(Scope scope) {
    return ValueWrapper(
        integerType, a.eval(scope).value * b.eval(scope).value, '$this result');
  }

  ValueType get type => integerType;
}

class DivideExpression extends Expression {
  final Expression a;
  final Expression b;

  DivideExpression(this.a, this.b, int line, int col, String file)
      : super(line, col, file);
  @override
  ValueWrapper eval(Scope scope) {
    ValueWrapper av = a.eval(scope);
    ValueWrapper bv = b.eval(scope);
    if (!(av.type.isSubtypeOf(integerType) &&
        bv.type.isSubtypeOf(integerType))) {
      throw FileInvalid(
          "$av ($a) or $bv ($b) is not an integer; attempted $a/$b ${formatCursorPosition(line, col, file)}\n ${scope.stack.reversed.join('\n')}");
    }
    return ValueWrapper(integerType, av.value ~/ bv.value, '$this result');
  }

  ValueType get type => integerType;
}

class RemainderExpression extends Expression {
  final Expression a;
  final Expression b;

  RemainderExpression(this.a, this.b, int line, int col, String file)
      : super(line, col, file);
  @override
  ValueWrapper eval(Scope scope) {
    ValueWrapper av = a.eval(scope);
    ValueWrapper bv = b.eval(scope);
    if (!(av.type.isSubtypeOf(integerType) &&
        bv.type.isSubtypeOf(integerType))) {
      throw FileInvalid(
          "$av ($a) or $bv ($b) is not an integer; attempted $a%$b ${formatCursorPosition(line, col, file)}\n ${scope.stack.reversed.join('\n')}");
    }
    if (bv.value == 0) {
      throw FileInvalid(
          "$a (${av.value}) % $b (0) attempted ${formatCursorPosition(line, col, file)} stack ${scope.stack.join('\n')}");
    }
    return ValueWrapper(integerType, av.value % bv.value, '$this result');
  }

  ValueType get type => integerType;
}

class SubtractExpression extends Expression {
  final Expression a;
  final Expression b;

  SubtractExpression(this.a, this.b, int line, int col, String file)
      : super(line, col, file);
  @override
  ValueWrapper eval(Scope scope) {
    ValueWrapper av = a.eval(scope);
    ValueWrapper bv = b.eval(scope);
    if (!(av.type.isSubtypeOf(integerType) &&
        bv.type.isSubtypeOf(integerType))) {
      throw FileInvalid(
          "$av ($a) or $bv ($b) is not an integer; attempted $a-$b ${formatCursorPosition(line, col, file)}\n ${scope.stack.reversed.join('\n')}");
    }
    return ValueWrapper(integerType, av.value - bv.value, '$this result');
  }

  String toString() => "($a) - ($b)";

  ValueType get type => integerType;
}

class AddExpression extends Expression {
  final Expression a;
  final Expression b;

  AddExpression(this.a, this.b, int line, int col, String file)
      : super(line, col, file);
  @override
  ValueWrapper eval(Scope scope) {
    ValueWrapper av = a.eval(scope);
    ValueWrapper bv = b.eval(scope);
    if (!(av.type.isSubtypeOf(integerType) &&
        bv.type.isSubtypeOf(integerType))) {
      throw FileInvalid(
          "$av ($a) or $bv ($b) is not an integer; attempted $a+$b ${formatCursorPosition(line, col, file)}\n ${scope.stack.reversed.join('\n')}");
    }
    return ValueWrapper(integerType, av.value + bv.value, '$this result');
  }

  String toString() => "$a + $b";

  ValueType get type => integerType;
}

class SuperExpression extends Expression {
  SuperExpression(this.member, this.tv, int line, int col, String file)
      : super(line, col, file);
  final String member;
  final TypeValidator tv;

  @override
  ValueWrapper eval(Scope scope) {
    ClassValueType classType = scope.currentClass;
    ValueWrapper thisScopeVW =
        scope.getVar('this', line, col, '<internal error: no this>');
    Scope thisScope = thisScopeVW.value;
    ClassValueType parent = classType;
    Scope superMethods;
    do {
      parent = parent.parent as ClassValueType;
      superMethods = scope
          .getVar('~${parent.name}~methods', line, col,
              '<internal error: no methods>')
          .value;
    } while (!superMethods.values.containsKey(member));
    ValueWrapper x = superMethods.getVar(member, line, col, 'TODO');
    return ValueWrapper(
        x.type,
        (List<ValueWrapper> args2, List<String> stack2) =>
            (x.value as Function)(args2, stack2, thisScope, thisScopeVW.type),
        '${classType.name}.super.$member');
  }

  String toString() => "super.$member";

  @override
  ValueType get type => (tv.currentClass.parent is ClassValueType
          ? tv.currentClass.parent as ClassValueType
          : (throw FileInvalid(
              "${tv.currentClass} has no supertype ${formatCursorPosition(line, col, file)}")))
      .properties
      .types[member]!;
}

class IntLiteralExpression extends Expression {
  IntLiteralExpression(this.n, int line, int col, String file)
      : super(line, col, file);
  final int n;
  ValueWrapper eval(Scope scope) => ValueWrapper(integerType, n, 'literal');
  String toString() => "$n";

  ValueType get type => integerType;
}

class StringLiteralExpression extends Expression {
  StringLiteralExpression(this.n, int line, int col, String file)
      : super(line, col, file);
  final String n;
  ValueWrapper eval(Scope scope) => ValueWrapper(stringType, n, 'literal');
  String toString() => "'$n'";
  ValueType get type => stringType;
}

class BoringExpr extends Expression {
  final value;

  final ValueType type;

  BoringExpr(this.value, this.type)
      : super(-2, 0, 'TODO (boring expr line,column, filename)');
  @override
  eval(Scope scope) {
    return ValueWrapper(type, value, '<todo boring expr vw desc>');
  }

  String toString() => "$value**";
}

class UnwrapExpression extends Expression {
  UnwrapExpression(this.a, int line, int col, String file)
      : super(line, col, file);
  final Expression a;
  @override
  ValueWrapper eval(Scope scope) {
    ValueWrapper aval = a.eval(scope);
    if (aval.value == null) {
      throw FileInvalid(
          "Failed unwrap of $aval ${formatCursorPosition(line, col, file)}\n${scope.stack.reversed.join('\n')}");
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
  ValueType get type => a.type.name != 'Whatever'
      ? (a.type as GenericFunctionValueType).returnType
      : sharedSupertype;

  String toString() => "$a(${b.join(', ')})";

  FunctionCallExpr(
      this.a, this.b, this.validator, int line, int col, String file)
      : super(line, col, file);
  @override
  ValueWrapper eval(Scope scope) {
    List<ValueWrapper> args = b.map((x) => x.eval(scope)).toList();
    for (int i = 0; i < args.length; i++) {
      if (a.type is FunctionValueType &&
          !args[i].type.isSubtypeOf(
              (a.type as FunctionValueType).parameters.elementAt(i))) {
        throw FileInvalid(
            "argument #$i of $a, ${args[i]} (${b[i]}), of wrong type (${args[i].type}) expected ${(a.type as FunctionValueType).parameters.elementAt(i)} ${formatCursorPosition(line, col, file)}\n${scope.stack.reversed.join('\n')}");
      }
    }
    List<String> newStack = scope.stack.toList();
    newStack[newStack.length - 1] +=
        " ${formatCursorPosition(line, col, file)}";
    dynamic result = (a.eval(scope).value as Function)(args, newStack);
    if (result is StatementResult) {
      switch (result.type) {
        case StatementResultType.nothing:
        case StatementResultType.breakWhile:
        case StatementResultType.continueWhile:
          throw "Internal error with functions";
        case StatementResultType.returnFunction:
          return result.value!;
        case StatementResultType.unwindAndThrow:
          throw FileInvalid('${result.value}');
      }
    } else if (result is ValueWrapper) {
      return result;
    } else {
      throw "Internal error ($a => $result )";
    }
  }
}

class ListLiteralExpression extends Expression {
  ListLiteralExpression(this.n, this.genParam, int line, int col, String file)
      : super(line, col, file);
  final List<Expression> n;
  final ValueType genParam;
  ValueType get type => ListValueType(genParam, file);
  String toString() => "$n:$genParam";
  ValueWrapper eval(Scope scope) => ValueWrapper(ListValueType(genParam, file),
      n.map((e) => e.eval(scope)).toList(), 'literal');
}

class ShiftRightExpression extends Expression {
  final Expression a;
  final Expression b;

  ShiftRightExpression(this.a, this.b, int line, int col, String file)
      : super(line, col, file);
  @override
  ValueWrapper eval(Scope scope) {
    return ValueWrapper(integerType, a.eval(scope).value >> b.eval(scope).value,
        '$this result');
  }

  ValueType get type => integerType;
}

class ShiftLeftExpression extends Expression {
  final Expression a;
  final Expression b;

  ShiftLeftExpression(this.a, this.b, int line, int col, String file)
      : super(line, col, file);
  @override
  ValueWrapper eval(Scope scope) {
    return ValueWrapper(integerType, a.eval(scope).value << b.eval(scope).value,
        '$this result');
  }

  ValueType get type => integerType;
}

class GreaterExpression extends Expression {
  final Expression a;
  final Expression b;

  GreaterExpression(this.a, this.b, int line, int col, String file)
      : super(line, col, file);
  @override
  ValueWrapper eval(Scope scope) {
    ValueWrapper av = a.eval(scope);
    ValueWrapper bv = b.eval(scope);
    if (!(av.type.isSubtypeOf(integerType) &&
        bv.type.isSubtypeOf(integerType))) {
      throw FileInvalid(
          "$av ($a) or $bv ($b) is not an integer; attempted $a>$b ${formatCursorPosition(line, col, file)}\n ${scope.stack.reversed.join('\n')}");
    }
    return ValueWrapper(booleanType, av.value > bv.value, '$this result');
  }

  String toString() => "$a > $b";

  ValueType get type => booleanType;
}

class LessExpression extends Expression {
  final Expression a;
  final Expression b;

  LessExpression(this.a, this.b, int line, int col, String file)
      : super(line, col, file);
  @override
  ValueWrapper eval(Scope scope) {
    return ValueWrapper(
        booleanType, a.eval(scope).value < b.eval(scope).value, '$this result');
  }

  ValueType get type => booleanType;
}

class BitOrExpression extends Expression {
  final Expression a;
  final Expression b;

  ValueType type = integerType;

  BitOrExpression(this.a, this.b, int line, int col, String file)
      : super(line, col, file);
  @override
  ValueWrapper eval(Scope scope) {
    return ValueWrapper(
        integerType, a.eval(scope).value | b.eval(scope).value, '$this result');
  }
}

class AndExpression extends Expression {
  final Expression a;
  final Expression b;

  AndExpression(this.a, this.b, int line, int col, String file)
      : super(line, col, file);
  @override
  ValueWrapper eval(Scope scope) {
    return ValueWrapper(booleanType, a.eval(scope).value && b.eval(scope).value,
        '$this result');
  }

  ValueType get type => booleanType;
}

class OrExpression extends Expression {
  final Expression a;
  final Expression b;

  OrExpression(this.a, this.b, int line, int col, String file)
      : super(line, col, file);
  @override
  ValueWrapper eval(Scope scope) {
    return ValueWrapper(booleanType, a.eval(scope).value || b.eval(scope).value,
        '$this result');
  }

  String toString() => "$a || $b";

  ValueType get type => booleanType;
}
