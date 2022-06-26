import 'lexer.dart';
import 'parser-core.dart';
import 'expressions.dart';

Expression parseLiterals(TokenIterator tokens, TypeValidator scope) {
  switch (tokens.current.runtimeType) {
    case IntToken:
      int i = tokens.integer;
      tokens.moveNext();
      return IntLiteralExpression(
        i,
        tokens.current.line,
        tokens.current.col,
        tokens.workspace,
        tokens.file,
      );
    case IdentToken:
      if (tokens.currentIdent == 'super') {
        tokens.moveNext();
        tokens.expectChar(TokenType.period);
        String member = tokens.currentIdent;
        ValueType? superclass = scope.currentClass.parent;
        if (superclass is! ClassValueType) {
          throw FileInvalid(
              '${scope.currentClass.name} has no superclass; attempted \'super.$member\' ${formatCursorPositionFromTokens(tokens)}');
        }
        if (!superclass.properties.types.containsKey(member)) {
          throw FileInvalid(
              '${scope.currentClass.name}\'s superclass (${superclass.name}) has no member $member; attempted \'super.$member\' ${formatCursorPositionFromTokens(tokens)}');
        }
        tokens.moveNext();
        return SuperExpression(
          member,
          scope,
          tokens.current.line,
          tokens.current.col,
          tokens.workspace,
          tokens.file,
        );
      } else if (tokens.currentIdent == 'assert') {
        tokens.moveNext();
        tokens.expectChar(TokenType.openParen);
        Expression condition = parseExpression(tokens, scope);
        tokens.expectChar(TokenType.comma);
        Expression comment = parseExpression(tokens, scope);
        if (tokens.currentChar == TokenType.comma) {
          tokens.moveNext();
        }
        tokens.expectChar(TokenType.closeParen);
        return AssertExpression(
          condition,
          comment,
          tokens.current.line,
          tokens.current.col,
          tokens.workspace,
          tokens.file,
        );
      } else if (tokens.currentIdent == '__LINE__') {
        tokens.moveNext();
        return IntLiteralExpression(tokens.current.line, tokens.current.line,
            tokens.current.col, tokens.workspace, tokens.file);
      } else if (tokens.currentIdent == '__COL__') {
        tokens.moveNext();
        return IntLiteralExpression(tokens.current.col, tokens.current.line,
            tokens.current.col, tokens.workspace, tokens.file);
      } else if (tokens.currentIdent == '__FILE__') {
        tokens.moveNext();
        return StringLiteralExpression(tokens.file, tokens.current.line,
            tokens.current.col, tokens.workspace, tokens.file);
      }
      scope.getVar(
        tokens.currentIdent,
        0,
        tokens.current.line,
        tokens.current.col,
        tokens.workspace,
        tokens.file,
        'as an expression',
      );
      String i = tokens.currentIdent;
      tokens.moveNext();
      return GetExpr(
        i,
        scope,
        tokens.current.line,
        tokens.current.col,
        tokens.workspace,
        tokens.file,
      );
    case StringToken:
      String s = tokens.string;
      tokens.moveNext();
      return StringLiteralExpression(s, tokens.current.line, tokens.current.col,
          tokens.workspace, tokens.file);
    case CharToken:
      if (tokens.currentChar == TokenType.openSquare) {
        tokens.moveNext();
        List<Expression> elements = [];
        ValueType? type = null;
        while (tokens.current is! CharToken ||
            tokens.currentChar != TokenType.closeSquare) {
          Expression expr = parseExpression(tokens, scope);
          if (tokens.currentChar != TokenType.closeSquare) {
            tokens.expectChar(TokenType.comma);
          }
          elements.add(expr);
          if (type == null) {
            type = expr.type;
          } else if (expr.type.name == "Whatever") {
            // has been cast()-ed
          } else if (type != expr.type) {
            type = sharedSupertype;
          }
        }
        if (type == null) {
          type = sharedSupertype;
        }
        tokens.moveNext();
        if (tokens.current is CharToken &&
            tokens.currentChar == TokenType.colon) {
          tokens.moveNext();
          ValueType t = ValueType(
              null,
              tokens.currentIdent,
              tokens.current.line,
              tokens.current.col,
              tokens.workspace,
              tokens.file);
          if (!type.isSubtypeOf(t) && elements.isNotEmpty)
            throw FileInvalid(
                'Invalid explicit list type (inferred type $type, provided type $t) ${formatCursorPositionFromTokens(tokens)}');
          type = t;
          tokens.moveNext();
        }
        return ListLiteralExpression(
          elements,
          type,
          tokens.current.line,
          tokens.current.col,
          tokens.workspace,
          tokens.file,
        );
      }
      if (tokens.currentChar == TokenType.openParen) {
        tokens.moveNext();
        Expression r = parseExpression(tokens, scope);
        tokens.moveNext();
        return r;
      }
      throw FileInvalid(
        "Unexpected token ${tokens.current} on ${formatCursorPositionFromTokens(tokens)}",
      );
  }
  assert(false);
  return IntLiteralExpression(null as int, tokens.current.line,
      tokens.current.col, tokens.workspace, tokens.file);
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
      tokens.workspace,
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
      tokens.workspace,
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
      tokens.workspace,
      tokens.file,
    );
  }
  return operandA;
}

Expression parseFunCalls(TokenIterator tokens, TypeValidator scope) {
  Expression operandA = parseLiterals(tokens, scope);
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
          Expression operandB = parseExpression(tokens, scope);
          if (!operandB.type.isSubtypeOf(integerType)) {
            throw FileInvalid(
                "Attempted to subscript using non-integer index: $operandB. ${formatCursorPositionFromTokens(tokens)}");
          }
          tokens.expectChar(TokenType.closeSquare);
          if (!result.type.isSubtypeOf(ListValueType(
              ValueType(null, "Whatever", -2, 0, 'interr', 'internal'),
              'internal'))) {
            throw FileInvalid(
                "tried to subscript ${result.type} ($result) ${formatCursorPositionFromTokens(tokens)}");
          }
          result = SubscriptExpression(
            result,
            operandB,
            tokens.current.line,
            tokens.current.col,
            tokens.workspace,
            tokens.file,
          );
        } else if (tokens.currentChar == TokenType.period) {
          if (result.type is! ClassValueType &&
              result.type.name != 'Whatever') {
            throw FileInvalid(
                "tried to access member of ${result.type} ${formatCursorPositionFromTokens(tokens)}");
          }
          tokens.moveNext();
          String operandB = tokens.currentIdent;
          if (result.type.name != 'Whatever' &&
              !(result.type as ClassValueType)
                  .properties
                  .types
                  .containsKey(operandB)) {
            throw FileInvalid(
                "tried to access nonexistent member '$operandB' of ${result.type} ${formatCursorPositionFromTokens(tokens)}");
          }
          tokens.moveNext();
          result = MemberAccessExpression(
            result,
            operandB,
            tokens.current.line,
            tokens.current.col,
            tokens.workspace,
            tokens.file,
          );
        } else if (tokens.currentChar == TokenType.bang) {
          tokens.moveNext();
          if (result.type is! NullableValueType) {
            throw FileInvalid(
                "Attempted unwrap of non-nullable type (${result.type}) ${formatCursorPositionFromTokens(tokens)}");
          }
          result = UnwrapExpression(
            result,
            tokens.current.line,
            tokens.current.col,
            tokens.workspace,
            tokens.file,
          );
        } else {
          if (!result.type.isSubtypeOf(
              GenericFunctionValueType(sharedSupertype, tokens.file))) {
            throw FileInvalid(
                "tried to call ${result.type} ($result) ${formatCursorPositionFromTokens(tokens)}");
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
                  "Too many arguments to $result ${formatCursorPositionFromTokens(tokens)}");
            }
            Expression expr = parseExpression(
              tokens,
              scope,
            );
            if (result.type is FunctionValueType) {
              if (!expr.type.isSubtypeOf((result.type as FunctionValueType)
                  .parameters
                  .elementAt(arguments.length))) {
                throw FileInvalid(
                    "parameter ${arguments.length} of $result expects type ${(result.type as FunctionValueType).parameters.elementAt(arguments.length)} got $expr (a ${expr.type}) ${formatCursorPositionFromTokens(tokens)}");
              }
            }
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
                "Not enough arguments to $result (expected ${(result.type as FunctionValueType).parameters}, got $arguments) ${formatCursorPositionFromTokens(tokens)}");
          }
          tokens.moveNext();
          result = FunctionCallExpr(
            result,
            arguments,
            scope,
            tokens.current.line,
            tokens.current.col,
            tokens.workspace,
            tokens.file,
          );
        }
      }
      return result;
    }
  }
  return operandA;
}

Expression parseExpression(TokenIterator tokens, TypeValidator scope) {
  Expression expr = parseOr(tokens, scope);
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
        tokens.workspace,
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
        tokens.workspace,
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
        tokens.workspace,
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
        tokens.workspace,
        tokens.file,
      );
    } else if (tokens.currentChar == TokenType.tilde) {
      tokens.moveNext();
      Expression operandA = parseNots(tokens, scope);
      return BitNotExpression(
        operandA,
        tokens.current.line,
        tokens.current.col,
        tokens.workspace,
        tokens.file,
      );
    } else if (tokens.currentChar == TokenType.minus) {
      tokens.moveNext();
      Expression operand = parseNots(tokens, scope);
      return SubtractExpression(
        IntLiteralExpression(0, tokens.current.line, tokens.current.col,
            tokens.workspace, tokens.file),
        operand,
        tokens.current.line,
        tokens.current.col,
        tokens.workspace,
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
        tokens.current.col, tokens.workspace, tokens.file);
    tokens.moveNext();
    return IsExpr(
      operand,
      type,
      tokens.current.line,
      tokens.current.col,
      tokens.workspace,
      tokens.file,
    );
  }
  if (tokens.current is IdentToken && tokens.currentIdent == 'as') {
    tokens.moveNext();
    ValueType type = ValueType(null, tokens.currentIdent, tokens.current.line,
        tokens.current.col, tokens.workspace, tokens.file);
    tokens.moveNext();
    return AsExpr(
      operand,
      type,
      tokens.current.line,
      tokens.current.col,
      tokens.workspace,
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
        tokens.workspace,
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
        tokens.workspace,
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
        tokens.workspace,
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
        tokens.workspace,
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
      if (!operandA.type.isSubtypeOf(integerType)) {
        throw FileInvalid("lhs of < is not an integer (is a $operandA)");
      }
      if (!operandB.type.isSubtypeOf(integerType)) {
        throw FileInvalid("rhs of < is not an integer (is a $operandB)");
      }
      return LessExpression(
        operandA,
        operandB,
        tokens.current.line,
        tokens.current.col,
        tokens.workspace,
        tokens.file,
      );
    } else if (tokens.currentChar == TokenType.lessEqual) {
      tokens.moveNext();
      Expression operandB = parseRelOp(tokens, scope);
      if (!operandA.type.isSubtypeOf(integerType)) {
        throw FileInvalid("lhs of <= is not an integer (is a $operandA)");
      }
      if (!operandB.type.isSubtypeOf(integerType)) {
        throw FileInvalid("rhs of <= is not an integer (is a $operandB)");
      }
      return OrExpression(
        LessExpression(
          operandA,
          operandB,
          tokens.current.line,
          tokens.current.col,
          tokens.workspace,
          tokens.file,
        ),
        EqualsExpression(
          operandA,
          operandB,
          tokens.current.line,
          tokens.current.col,
          tokens.workspace,
          tokens.file,
        ),
        tokens.current.line,
        tokens.current.col,
        tokens.workspace,
        tokens.file,
      );
    } else if (tokens.currentChar == TokenType.greater) {
      tokens.moveNext();
      Expression operandB = parseRelOp(tokens, scope);
      if (!operandA.type.isSubtypeOf(integerType)) {
        throw FileInvalid("lhs of > is not an integer (is a $operandA)");
      }
      if (!operandB.type.isSubtypeOf(integerType)) {
        throw FileInvalid("rhs of > is not an integer (is a $operandB)");
      }
      return GreaterExpression(
        operandA,
        operandB,
        tokens.current.line,
        tokens.current.col,
        tokens.workspace,
        tokens.file,
      );
    } else if (tokens.currentChar == TokenType.greaterEqual) {
      tokens.moveNext();
      Expression operandB = parseRelOp(tokens, scope);
      if (!operandA.type.isSubtypeOf(integerType)) {
        throw FileInvalid("lhs of >= is not an integer (is a $operandA)");
      }
      if (!operandB.type.isSubtypeOf(integerType)) {
        throw FileInvalid(
            "rhs of >= is not an integer (is a $operandB ${formatCursorPositionFromTokens(tokens)})");
      }
      return OrExpression(
        GreaterExpression(
          operandA,
          operandB,
          tokens.current.line,
          tokens.current.col,
          tokens.workspace,
          tokens.file,
        ),
        EqualsExpression(
          operandA,
          operandB,
          tokens.current.line,
          tokens.current.col,
          tokens.workspace,
          tokens.file,
        ),
        tokens.current.line,
        tokens.current.col,
        tokens.workspace,
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
        tokens.workspace,
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
          tokens.workspace,
          tokens.file,
        ),
        tokens.current.line,
        tokens.current.col,
        tokens.workspace,
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
    if (!operandA.type.isSubtypeOf(integerType)) {
      throw FileInvalid(
          "lhs of & is not an integer (is $operandA, a ${operandA.type} ${formatCursorPositionFromTokens(tokens)})");
    }
    if (!operandB.type.isSubtypeOf(integerType)) {
      throw FileInvalid(
          "rhs of & is not an integer (is $operandB, a ${operandB.type} ${formatCursorPositionFromTokens(tokens)})");
    }
    return BitAndExpression(
      operandA,
      operandB,
      tokens.current.line,
      tokens.current.col,
      tokens.workspace,
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
    if (!operandA.type.isSubtypeOf(integerType)) {
      throw FileInvalid(
          "lhs of ^ is not an integer (is $operandA, a ${operandA.type} ${formatCursorPositionFromTokens(tokens)})");
    }
    if (!operandB.type.isSubtypeOf(integerType)) {
      throw FileInvalid(
          "rhs of ^ is not an integer (is $operandB, a ${operandB.type} ${formatCursorPositionFromTokens(tokens)})");
    }
    return BitXorExpression(
      operandA,
      operandB,
      tokens.current.line,
      tokens.current.col,
      tokens.workspace,
      tokens.file,
    );
  }
  return operandA;
}
