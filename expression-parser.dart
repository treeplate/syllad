import 'dart:math';

import 'lexer.dart';
import 'parser-core.dart';
import 'expressions.dart';

Expression parseLiterals(TokenIterator tokens, TypeValidator scope) {
  switch (tokens.current.runtimeType) {
    case IntToken:
      return IntLiteralExpression(
          tokens.integer, tokens.current.line, tokens.current.col, tokens.file);
    case IdentToken:
      if (tokens.currentIdent == 'super') {
        tokens.moveNext();
        tokens.expectChar(TokenType.period);
        String member = tokens.currentIdent;
        return SuperExpression(
          member,
          scope,
          tokens.current.line,
          tokens.current.col,
          tokens.file,
        );
      }
      scope.getVar(
        tokens.currentIdent,
        0,
        sharedSupertype,
        tokens.current.line,
        tokens.current.col,
        tokens.file,
      );
      return GetExpr(tokens.currentIdent, scope, tokens.current.line,
          tokens.current.col, tokens.file);
    case StringToken:
      return StringLiteralExpression(
          tokens.string, tokens.current.line, tokens.current.col, tokens.file);
    case CharToken:
      if (tokens.currentChar == TokenType.openSquare) {
        tokens.moveNext();
        List<Expression> arguments = [];
        ValueType type = ValueType(
            null, "Dog", tokens.current.line, tokens.current.col, tokens.file);
        while (tokens.current is! CharToken ||
            tokens.currentChar != TokenType.closeSquare) {
          Expression expr = parseExpression(tokens, scope, sharedSupertype);
          if (tokens.currentChar != TokenType.closeSquare) {
            tokens.expectChar(TokenType.comma);
          }
          arguments.add(expr);
          if (type ==
              ValueType(null, "Dog", tokens.current.line, tokens.current.col,
                  tokens.file)) {
            type = expr.type;
          } else if (expr.type ==
              ValueType(null, "Whatever", tokens.current.line,
                  tokens.current.col, tokens.file)) {
            // has been cast()-ed
          } else if (type != expr.type) {
            type = sharedSupertype;
          }
        }
        if (type ==
            ValueType(null, "Dog", tokens.current.line, tokens.current.col,
                tokens.file)) {
          type = ValueType(sharedSupertype, "Whatever", tokens.current.line,
              tokens.current.col, tokens.file);
        }
        return ListLiteralExpression(
          arguments,
          type,
          tokens.current.line,
          tokens.current.col,
          tokens.file,
        );
      }
      if (tokens.currentChar == TokenType.openParen) {
        tokens.moveNext();
        return parseExpression(tokens, scope, sharedSupertype);
      }
      throw FileInvalid(
        "Unexpected token ${tokens.current} on line ${tokens.current.line} column ${tokens.current.col} file ${tokens.file}",
      );
  }
  assert(false);
  return IntLiteralExpression(
      null as int, tokens.current.line, tokens.current.col, tokens.file);
}

Expression parseBitOr(TokenIterator tokens, TypeValidator scope) {
  Expression operandA = parseBitXor(tokens, scope);
  if (tokens.current is CharToken && tokens.currentChar == TokenType.bitOr) {
    tokens.moveNext();
    Expression operandB = parseBitOr(tokens, scope);
    return BitOrExpression(
      operandA,
      operandB,
      tokens.current.line,
      tokens.current.col,
      tokens.file,
    );
  }
  return operandA;
}

Expression parseOr(TokenIterator tokens, TypeValidator scope) {
  Expression operandA = parseAnd(tokens, scope);
  if (tokens.current is CharToken && tokens.currentChar == TokenType.oror) {
    tokens.moveNext();
    Expression operandB = parseOr(tokens, scope);
    return OrExpression(
      operandA,
      operandB,
      tokens.current.line,
      tokens.current.col,
      tokens.file,
    );
  }
  return operandA;
}

Expression parseAnd(TokenIterator tokens, TypeValidator scope) {
  Expression operandA = parseBitOr(tokens, scope);
  if (tokens.current is CharToken && tokens.currentChar == TokenType.andand) {
    tokens.moveNext();
    Expression operandB = parseAnd(tokens, scope);
    return AndExpression(
      operandA,
      operandB,
      tokens.current.line,
      tokens.current.col,
      tokens.file,
    );
  }
  return operandA;
}

Expression parseFunCalls(TokenIterator tokens, TypeValidator scope) {
  Expression operandA = parseLiterals(tokens, scope);
  tokens.moveNext();
  if (tokens.current is CharToken) {
    if (tokens.currentChar == TokenType.openSquare ||
        tokens.currentChar == TokenType.openParen ||
        tokens.currentChar == TokenType.period ||
        tokens.currentChar == TokenType.bang) {
      Expression result = operandA;
      while (tokens.current is CharToken &&
          (tokens.currentChar == TokenType.openSquare ||
              tokens.currentChar == TokenType.openParen ||
              tokens.currentChar == TokenType.period ||
              tokens.currentChar == TokenType.bang)) {
        if (tokens.currentChar == TokenType.openSquare) {
          tokens.moveNext();
          Expression operandB = parseExpression(tokens, scope, integerType);
          tokens.expectChar(TokenType.closeSquare);
          if (!result.type.isSubtypeOf(ListValueType(sharedSupertype))) {
            throw FileInvalid(
                "tried to subscript ${result.type} ($result) on line ${tokens.current.line} column ${tokens.current.col} file ${tokens.file}");
          }
          result = SubscriptExpression(
            result,
            operandB,
            tokens.current.line,
            tokens.current.col,
            tokens.file,
          );
        } else if (tokens.currentChar == TokenType.period) {
          if (result.type is! ClassValueType &&
              result.type.name != 'Whatever') {
            throw FileInvalid(
                "tried to access member of ${result.type} on line ${tokens.current.line} column ${tokens.current.col} file ${tokens.file}");
          }
          tokens.moveNext();
          String operandB = tokens.currentIdent;
          if (result.type.name != 'Whatever' &&
              !(result.type as ClassValueType)
                  .properties
                  .types
                  .containsKey(operandB)) {
            throw FileInvalid(
                "tried to access nonexistent member '$operandB' of ${result.type} on line ${tokens.current.line} column ${tokens.current.col} file ${tokens.file}");
          }
          tokens.moveNext();
          result = MemberAccessExpression(result, operandB, tokens.current.line,
              tokens.current.col, tokens.file);
        } else if (tokens.currentChar == TokenType.bang) {
          tokens.moveNext();
          if (result.type is! NullableValueType) {
            throw FileInvalid(
                "Attempted unwrap of non-nullable type (${result.type}) on line ${tokens.current.line} column ${tokens.current.col} file ${tokens.file}");
          }
          result = UnwrapExpression(
              result, tokens.current.line, tokens.current.col, tokens.file);
        } else {
          if (!result.type
              .isSubtypeOf(GenericFunctionValueType(sharedSupertype))) {
            throw FileInvalid(
                "tried to call ${result.type} ($result) on line ${tokens.current.line} column ${tokens.current.col} file ${tokens.file}");
          }
          tokens.moveNext();
          List<Expression> arguments = [];
          while (tokens.current is! CharToken ||
              tokens.currentChar != TokenType.closeParen) {
            if ((result.type is FunctionValueType) &&
                (result.type as FunctionValueType).parameters
                    is! InfiniteIterable &&
                (result.type as FunctionValueType).parameters.length <=
                    arguments.length) {
              throw FileInvalid(
                  "Too many arguments to $result line ${tokens.current.line} col ${tokens.current.col} file ${tokens.file}");
            }
            Expression expr = parseExpression(
              tokens,
              scope,
              result.type is! FunctionValueType
                  ? sharedSupertype
                  : (result.type as FunctionValueType)
                      .parameters
                      .elementAt(arguments.length),
            );
            if (tokens.currentChar != TokenType.closeParen) {
              tokens.expectChar(TokenType.comma);
            }
            arguments.add(expr);
          }
          if (result.type is FunctionValueType &&
              (result.type as FunctionValueType).parameters
                  is! InfiniteIterable &&
              (result.type as FunctionValueType).parameters.length !=
                  arguments.length) {
            throw FileInvalid(
                "Not enough arguments to $result line ${tokens.current.line} column ${tokens.current.col} file ${tokens.file}");
          }
          tokens.moveNext();
          result = FunctionCallExpr(
            result,
            arguments,
            scope,
            tokens.current.line,
            tokens.current.col,
            tokens.file,
          );
        }
      }
      return result;
    }
  }
  return operandA;
}

Expression parseExpression(
    TokenIterator tokens, TypeValidator scope, ValueType type) {
  Expression expr = parseOr(tokens, scope);
  if (!expr.type.isSubtypeOf(type)) {
    throw FileInvalid(
        "Expected $type, got $expr (a ${expr.type}) line ${tokens.current.line} column ${tokens.current.col} file ${tokens.file}");
  }
  return expr;
}

Expression parseMulDivRem(TokenIterator tokens, TypeValidator scope) {
  Expression operandA = parseNots(tokens, scope);
  if (tokens.current is CharToken) {
    if (tokens.currentChar == TokenType.multiply) {
      tokens.moveNext();
      Expression operandB = parseMulDivRem(tokens, scope);
      return MultiplyExpression(
        operandA,
        operandB,
        tokens.current.line,
        tokens.current.col,
        tokens.file,
      );
    } else if (tokens.currentChar == TokenType.divide) {
      tokens.moveNext();
      Expression operandB = parseMulDivRem(tokens, scope);
      return DivideExpression(
        operandA,
        operandB,
        tokens.current.line,
        tokens.current.col,
        tokens.file,
      );
    } else if (tokens.currentChar == TokenType.remainder) {
      tokens.moveNext();
      Expression operandB = parseMulDivRem(tokens, scope);
      return RemainderExpression(
        operandA,
        operandB,
        tokens.current.line,
        tokens.current.col,
        tokens.file,
      );
    }
  }
  return operandA;
}

Expression parseNots(TokenIterator tokens, TypeValidator scope) {
  if (tokens.current is CharToken) {
    if (tokens.currentChar == TokenType.bang) {
      tokens.moveNext();
      Expression operandA = parseNots(tokens, scope);
      return NotExpression(
        operandA,
        tokens.current.line,
        tokens.current.col,
        tokens.file,
      );
    } else if (tokens.currentChar == TokenType.tilde) {
      tokens.moveNext();
      Expression operandA = parseNots(tokens, scope);
      return BitNotExpression(
        operandA,
        tokens.current.line,
        tokens.current.col,
        tokens.file,
      );
    } else if (tokens.currentChar == TokenType.minus) {
      tokens.moveNext();
      Expression operand = parseNots(tokens, scope);
      return SubtractExpression(
        IntLiteralExpression(
            0, tokens.current.line, tokens.current.col, tokens.file),
        operand,
        tokens.current.line,
        tokens.current.col,
        tokens.file,
      );
    } else if (tokens.currentChar == TokenType.plus) {
      tokens.moveNext();
      return parseNots(tokens, scope);
    }
  }
  Expression operand = parseFunCalls(tokens, scope);
  if (tokens.current is IdentToken && tokens.currentIdent == 'is') {
    tokens.moveNext();
    ValueType type = ValueType(null, tokens.currentIdent, tokens.current.line,
        tokens.current.col, tokens.file);
    tokens.moveNext();
    return IsExpr(
      operand,
      type,
      tokens.current.line,
      tokens.current.col,
      tokens.file,
    );
  }
  if (tokens.current is IdentToken && tokens.currentIdent == 'as') {
    tokens.moveNext();
    ValueType type = ValueType(null, tokens.currentIdent, tokens.current.line,
        tokens.current.col, tokens.file);
    tokens.moveNext();
    return AsExpr(
      operand,
      type,
      tokens.current.line,
      tokens.current.col,
      tokens.file,
    );
  }
  return operand;
}

Expression parseAddSub(TokenIterator tokens, TypeValidator scope) {
  Expression operandA = parseMulDivRem(tokens, scope);
  if (tokens.current is CharToken) {
    if (tokens.currentChar == TokenType.plus) {
      tokens.moveNext();
      Expression operandB = parseAddSub(tokens, scope);
      return AddExpression(
        operandA,
        operandB,
        tokens.current.line,
        tokens.current.col,
        tokens.file,
      );
    } else if (tokens.currentChar == TokenType.minus) {
      tokens.moveNext();
      Expression operandB = parseAddSub(tokens, scope);
      return SubtractExpression(
        operandA,
        operandB,
        tokens.current.line,
        tokens.current.col,
        tokens.file,
      );
    }
  }
  return operandA;
}

Expression parseBitShifts(TokenIterator tokens, TypeValidator scope) {
  Expression operandA = parseAddSub(tokens, scope);
  if (tokens.current is CharToken) {
    if (tokens.currentChar == TokenType.leftShift) {
      tokens.moveNext();
      Expression operandB = parseBitShifts(tokens, scope);
      return ShiftLeftExpression(
        operandA,
        operandB,
        tokens.current.line,
        tokens.current.col,
        tokens.file,
      );
    } else if (tokens.currentChar == TokenType.rightShift) {
      tokens.moveNext();
      Expression operandB = parseBitShifts(tokens, scope);
      return ShiftRightExpression(
        operandA,
        operandB,
        tokens.current.line,
        tokens.current.col,
        tokens.file,
      );
    }
  }
  return operandA;
}

Expression parseRelOp(TokenIterator tokens, TypeValidator scope) {
  Expression operandA = parseBitShifts(tokens, scope);
  if (tokens.current is CharToken) {
    if (tokens.currentChar == TokenType.less) {
      tokens.moveNext();
      Expression operandB = parseRelOp(tokens, scope);
      return LessExpression(
        operandA,
        operandB,
        tokens.current.line,
        tokens.current.col,
        tokens.file,
      );
    } else if (tokens.currentChar == TokenType.lessEqual) {
      tokens.moveNext();
      Expression operandB = parseRelOp(tokens, scope);
      return OrExpression(
        LessExpression(
          operandA,
          operandB,
          tokens.current.line,
          tokens.current.col,
          tokens.file,
        ),
        EqualsExpression(
          operandA,
          operandB,
          tokens.current.line,
          tokens.current.col,
          tokens.file,
        ),
        tokens.current.line,
        tokens.current.col,
        tokens.file,
      );
    } else if (tokens.currentChar == TokenType.greater) {
      tokens.moveNext();
      Expression operandB = parseRelOp(tokens, scope);
      return GreaterExpression(
        operandA,
        operandB,
        tokens.current.line,
        tokens.current.col,
        tokens.file,
      );
    } else if (tokens.currentChar == TokenType.greaterEqual) {
      tokens.moveNext();
      Expression operandB = parseRelOp(tokens, scope);
      return OrExpression(
        GreaterExpression(
          operandA,
          operandB,
          tokens.current.line,
          tokens.current.col,
          tokens.file,
        ),
        EqualsExpression(
          operandA,
          operandB,
          tokens.current.line,
          tokens.current.col,
          tokens.file,
        ),
        tokens.current.line,
        tokens.current.col,
        tokens.file,
      );
    }
  }
  return operandA;
}

Expression parseEqNeq(TokenIterator tokens, TypeValidator scope) {
  Expression operandA = parseRelOp(tokens, scope);
  if (tokens.current is CharToken) {
    if (tokens.currentChar == TokenType.equals) {
      tokens.moveNext();
      Expression operandB = parseEqNeq(tokens, scope);
      /*if (operandA.type != sharedSupertype &&
          operandA.type.name != "Whatever" &&
          operandB.type != sharedSupertype &&
          operandB.type.name != "Whatever" &&
          (!operandA.type.isSubtypeOf(operandB.type) ||
              !operandB.type.isSubtypeOf(operandA.type))) {
        return BoringExpr(false, booleanType);
      }*/
      return EqualsExpression(
        operandA,
        operandB,
        tokens.current.line,
        tokens.current.col,
        tokens.file,
      );
    } else if (tokens.currentChar == TokenType.notEquals) {
      tokens.moveNext();
      Expression operandB = parseEqNeq(tokens, scope);
      return NotExpression(
        EqualsExpression(
          operandA,
          operandB,
          tokens.current.line,
          tokens.current.col,
          tokens.file,
        ),
        tokens.current.line,
        tokens.current.col,
        tokens.file,
      );
    }
  }
  return operandA;
}

Expression parseBitAnd(TokenIterator tokens, TypeValidator scope) {
  Expression operandA = parseEqNeq(tokens, scope);
  if (tokens.current is CharToken && tokens.currentChar == TokenType.bitAnd) {
    tokens.moveNext();
    Expression operandB = parseBitAnd(tokens, scope);
    return BitAndExpression(
      operandA,
      operandB,
      tokens.current.line,
      tokens.current.col,
      tokens.file,
    );
  }
  return operandA;
}

Expression parseBitXor(TokenIterator tokens, TypeValidator scope) {
  Expression operandA = parseBitAnd(tokens, scope);
  if (tokens.current is CharToken && tokens.currentChar == TokenType.bitXor) {
    tokens.moveNext();
    Expression operandB = parseBitXor(tokens, scope);
    return BitXorExpression(
      operandA,
      operandB,
      tokens.current.line,
      tokens.current.col,
      tokens.file,
    );
  }
  return operandA;
}
