import 'syd-lexer.dart';
import 'syd-core.dart';
import 'syd-expressions.dart';

Expression parseLiterals(TokenIterator tokens, TypeValidator scope) {
  Token current = tokens.current;
  while (current is CommentFeatureToken) {
    tokens.moveNext();
    current = tokens.current;
  }
  switch (tokens.current.runtimeType) {
    case IntToken:
      int i = tokens.integer;
      tokens.moveNext();
      return IntLiteralExpression(i, current.line, current.col, tokens.file, scope);
    case IdentToken:
      if (tokens.currentIdent == scope.identifiers['super']) {
        tokens.moveNext();
        tokens.expectChar(TokenType.period);
        Identifier member = tokens.currentIdent;
        ValueType? superclass = scope.currentClassType.parent;
        if (superclass is! ClassValueType) {
          throw BSCException(
              '${scope.currentClassType} has no superclass; attempted \'super.${member.name}\' ${formatCursorPositionFromTokens(tokens)}', scope);
        }
        if (scope.indirectlyStaticMethod) {
          tokens.moveNext();
          return SuperExpression(member, current.line, current.col, tokens.file, true, scope);
        }
        TypeValidator props = superclass.properties;
        if (props.igv(member, true, current.line, current.col, tokens.file, true, false, false, true) == null) {
          throw BSCException(
            '${scope.currentClassType.name.name}\'s superclass (${superclass.name.name}) has no member ${member.name}; attempted \'super.${member.name}\' ${formatCursorPositionFromTokens(tokens)}',
            scope,
          );
        }
        tokens.moveNext();
        return SuperExpression(member, current.line, current.col, tokens.file, false, scope);
      } else if (tokens.currentIdent == (scope.identifiers['assert'] ??= Identifier('assert'))) {
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
          scope,
          current.line,
          current.col,
          tokens.file,
        );
      } else if (tokens.currentIdent == scope.identifiers['LINE']) {
        tokens.moveNext();
        return IntLiteralExpression(current.line, current.line, current.col, tokens.file, scope);
      } else if (tokens.currentIdent == scope.identifiers['COL']) {
        tokens.moveNext();
        return IntLiteralExpression(current.col, current.line, current.col, tokens.file, scope);
      } else if (tokens.currentIdent == scope.identifiers['FILE']) {
        tokens.moveNext();
        return StringLiteralExpression(tokens.file, current.line, current.col, tokens.file, scope);
      }
      Expression e = GetExpr(
        tokens.currentIdent,
        scope,
        current.line,
        current.col,
        tokens.file,
      );
      tokens.moveNext();
      return e;
    case StringToken:
      String s = tokens.string;
      tokens.moveNext();
      return StringLiteralExpression(s, current.line, current.col, tokens.file, scope);
    case CommentFeatureToken:
      assert(
        false,
        'comment feature was undetected by earlier loop ${formatCursorPositionFromTokens(tokens)}',
      );
    case CharToken:
      if (tokens.currentChar == TokenType.openSquare) {
        tokens.moveNext();
        List<Expression> elements = [];
        ValueType? type = null;
        while (tokens.current is! CharToken || tokens.currentChar != TokenType.closeSquare) {
          Expression expr = parseExpression(tokens, scope);
          if (tokens.currentChar != TokenType.closeSquare) {
            tokens.expectChar(TokenType.comma);
          }
          elements.add(expr);
          if (type == null && !(expr.staticType.name == whateverVariable)) {
            type = expr.staticType;
          } else if (expr.staticType.name == whateverVariable) {
            // has been cast()-ed
          } else if (type != expr.staticType) {
            type = scope.environment.anythingType;
          }
        }
        if (type == null) {
          type = scope.environment.anythingType;
        }
        tokens.moveNext();
        if (tokens.current is CharToken && tokens.currentChar == TokenType.colon) {
          tokens.moveNext();
          ValueType t = ValueType.create(tokens.currentIdent, current.line, current.col, tokens.file, scope);
          for (Expression expr in elements) {
            if (!expr.staticType.isSubtypeOf(t)) {
              throw BSCException(
                'Invalid explicit list type (inferred type $type, provided type $t) ${formatCursorPositionFromTokens(tokens)}',
                scope,
              );
            }
          }
          type = t;
          tokens.moveNext();
        }
        return ListLiteralExpression(
          elements,
          type,
          current.line,
          current.col,
          tokens.file,
          scope,
        );
      }
      if (tokens.currentChar == TokenType.openParen) {
        tokens.moveNext();
        Expression r = parseExpression(tokens, scope);
        tokens.expectChar(TokenType.closeParen);
        return r;
      }
      throw BSCException(
        "Unexpected token ${tokens.current} at start of expression   ${formatCursorPositionFromTokens(tokens)}",
        scope,
      );
  }
  assert(false, "unreachable - unknown token type ${tokens.current}");
  throw null as dynamic; // the perfect four-identifier statement
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
      scope,
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
      scope,
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
      scope,
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
          if (!operandB.staticType.isSubtypeOf(scope.environment.integerType)) {
            throw BSCException("Attempted to subscript using non-integer index: $operandB. ${formatCursorPositionFromTokens(tokens)}", scope);
          }
          tokens.expectChar(TokenType.closeSquare);
          if (!result.staticType.isSubtypeOf(ArrayValueType(ValueType.create(whateverVariable, -2, 0, 'internal', scope), 'internal', scope))) {
            throw BSCException("tried to subscript ${result.staticType} ($result) ${formatCursorPositionFromTokens(tokens)}", scope);
          }
          result = SubscriptExpression(
            result,
            operandB,
            tokens.current.line,
            tokens.current.col,
            tokens.file,
            scope,
          );
        } else if (tokens.currentChar == TokenType.period) {
          if (!result.staticType.memberAccesible()) {
            throw BSCException("tried to access member of ${result.staticType} ${formatCursorPositionFromTokens(tokens)}", scope);
          }
          tokens.moveNext();
          Identifier operandB = tokens.currentIdent;
          TypeValidator? properties;
          bool checkParent = false;
          if (result.staticType is ClassOfValueType) {
            properties = (result.staticType as ClassOfValueType).staticMembers;
            checkParent = true;
          }
          if (result.staticType is EnumValueType) {
            properties = (result.staticType as EnumValueType).staticMembers;
          }
          if (result.staticType is ClassValueType) {
            properties = (result.staticType as ClassValueType).properties;
            checkParent = true;
          }
          if (properties != null &&
              properties.igv(operandB, true, tokens.current.line, tokens.current.col, tokens.file, checkParent, false) == null) {
            throw BSCException(
              "tried to access nonexistent member '${operandB.name}' of ${result.staticType} ${properties.types.keys.map((e) => e.name)} ${formatCursorPositionFromTokens(tokens)}",
              scope,
            );
          }

          tokens.moveNext();
          result = MemberAccessExpression(
            result,
            operandB,
            tokens.current.line,
            tokens.current.col,
            tokens.file,
            scope,
          );
        } else if (tokens.currentChar == TokenType.bang) {
          tokens.moveNext();
          if (!scope.environment.nullType.isSubtypeOf(result.staticType)) {
            throw BSCException("Attempted unwrap of non-nullable type (${result.staticType}) ${formatCursorPositionFromTokens(tokens)}", scope);
          }
          result = UnwrapExpression(
            result,
            tokens.current.line,
            tokens.current.col,
            tokens.file,
            scope,
          );
        } else {
          if (result.staticType is! ClassOfValueType && !result.staticType.isSubtypeOf(GenericFunctionValueType(scope.environment.anythingType, tokens.file, scope))) {
            throw BSCException("tried to call ${result.staticType} ($result) ${formatCursorPositionFromTokens(tokens)}", scope);
          }
          tokens.moveNext();
          List<Expression> arguments = [];
          GenericFunctionValueType funType;
          if (result.staticType is ClassOfValueType) {
            funType = (result.staticType as ClassOfValueType).constructor;
          } else if (result.staticType is GenericFunctionValueType) {
            funType = result.staticType as GenericFunctionValueType;
          } else {
            funType = ValueType.create(scope.identifiers['AnythingFunction']!, 0, 0, '', scope) as GenericFunctionValueType;
          }
          while (tokens.current is! CharToken || tokens.currentChar != TokenType.closeParen) {
            Expression expr = parseExpression(
              tokens,
              scope,
            );
            if ((funType is FunctionValueType) && funType.parameters is! InfiniteIterable && funType.parameters.length <= arguments.length) {
              throw BSCException(
                "Too many arguments to $result, type is ${funType} - expected ${funType.parameters}, got extra argument $expr ${formatCursorPositionFromTokens(tokens)}",
                scope,
              );
            }
            if (funType is FunctionValueType) {
              if (!expr.staticType.isSubtypeOf(funType.parameters.elementAt(arguments.length))) {
                throw BSCException(
                  "parameter ${arguments.length} of $result expects type ${funType.parameters.elementAt(arguments.length)} got $expr (a ${expr.staticType}) ${formatCursorPositionFromTokens(tokens)}",
                  scope,
                );
              }
            }
            if (tokens.currentChar != TokenType.closeParen) {
              tokens.expectChar(TokenType.comma);
            }
            arguments.add(expr);
          }
          if (funType is FunctionValueType && funType.parameters is! InfiniteIterable && funType.parameters.length != arguments.length) {
            throw BSCException(
                "Not enough arguments to $result (expected ${funType.parameters}, got $arguments) ${formatCursorPositionFromTokens(tokens)}", scope);
          }
          tokens.moveNext();
          result = FunctionCallExpr(
            result,
            arguments,
            scope,
            tokens.current.line,
            tokens.current.col,
            tokens.file,
            scope,
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

Expression parseExponentiation(TokenIterator tokens, TypeValidator scope) {
  Expression operandA = parseUnaryOperators(tokens, scope);
  if (tokens.current is CharToken) {
    if (tokens.currentChar == TokenType.starStar) {
      tokens.moveNext();
      Expression operandB = parseExponentiation(tokens, scope);
      return PowExpression(
        operandA,
        operandB,
        tokens.current.line,
        tokens.current.col,
        tokens.file,
        scope,
      );
    }
  }
  return operandA;
}

Expression parseMulDivRem(TokenIterator tokens, TypeValidator scope) {
  Expression operandA = parseExponentiation(tokens, scope);
  while (tokens.current is CharToken) {
    if (tokens.currentChar == TokenType.star) {
      tokens.moveNext();
      Expression operandB = parseExponentiation(tokens, scope);
      operandA = MultiplyExpression(
        operandA,
        operandB,
        tokens.current.line,
        tokens.current.col,
        tokens.file,
        scope,
      );
    } else if (tokens.currentChar == TokenType.divide) {
      tokens.moveNext();
      Expression operandB = parseExponentiation(tokens, scope);
      operandA = DivideExpression(
        operandA,
        operandB,
        tokens.current.line,
        tokens.current.col,
        tokens.file,
        scope,
      );
    } else if (tokens.currentChar == TokenType.remainder) {
      tokens.moveNext();
      Expression operandB = parseExponentiation(tokens, scope);
      operandA = RemainderExpression(
        operandA,
        operandB,
        tokens.current.line,
        tokens.current.col,
        tokens.file,
        scope,
      );
    } else {
      break;
    }
  }
  return operandA;
}

Expression parseUnaryOperators(TokenIterator tokens, TypeValidator scope) {
  if (tokens.current is CharToken) {
    if (tokens.currentChar == TokenType.bang) {
      tokens.moveNext();
      Expression operandA = parseUnaryOperators(tokens, scope);
      return NotExpression(
        operandA,
        tokens.current.line,
        tokens.current.col,
        tokens.file,
        scope,
      );
    } else if (tokens.currentChar == TokenType.tilde) {
      tokens.moveNext();
      Expression operandA = parseUnaryOperators(tokens, scope);
      return BitNotExpression(
        operandA,
        tokens.current.line,
        tokens.current.col,
        tokens.file,
        scope,
      );
    } else if (tokens.currentChar == TokenType.minus) {
      tokens.moveNext();
      Expression operand = parseUnaryOperators(tokens, scope);
      return SubtractExpression(
        IntLiteralExpression(0, tokens.current.line, tokens.current.col, tokens.file, scope),
        operand,
        tokens.current.line,
        tokens.current.col,
        tokens.file,
        scope,
      );
    } else if (tokens.currentChar == TokenType.plus) {
      // xxx typecheck
      tokens.moveNext();
      return parseUnaryOperators(tokens, scope);
    } else if (tokens.currentChar == TokenType.typeOfIdent) {
      tokens.moveNext();
      Expression operand = parseUnaryOperators(tokens, scope);
      return TypeOfExpression(
        operand,
        tokens.current.line,
        tokens.current.col,
        tokens.file,
        scope,
      );
    } else if (tokens.currentChar == TokenType.typeCodeOfIdent) {
      tokens.moveNext();
      ValueType type = ValueType.create(tokens.currentIdent, tokens.current.line, tokens.current.col, tokens.file, scope);
      tokens.moveNext();
      return BoringExpr(type.id, scope.environment.integerType, scope);
    }
  }
  Expression operand = parseFunCalls(tokens, scope);
  if (tokens.current is CharToken && tokens.currentChar == TokenType.isIdent) {
    tokens.moveNext();
    ValueType type = ValueType.create(tokens.currentIdent, tokens.current.line, tokens.current.col, tokens.file, scope);
    tokens.moveNext();
    return IsExpr(
      operand,
      type,
      tokens.current.line,
      tokens.current.col,
      tokens.file,
      scope,
    );
  }
  if (tokens.current is CharToken && tokens.currentChar == TokenType.asIdent) {
    tokens.moveNext();
    ValueType type = ValueType.create(tokens.currentIdent, tokens.current.line, tokens.current.col, tokens.file, scope);
    tokens.moveNext();
    return AsExpr(
      operand,
      type,
      tokens.current.line,
      tokens.current.col,
      tokens.file,
      scope,
    );
  }
  return operand;
}

Expression parseAddSub(TokenIterator tokens, TypeValidator scope) {
  Expression result = parseMulDivRem(tokens, scope);
  while (tokens.current is CharToken && (tokens.currentChar == TokenType.minus || tokens.currentChar == TokenType.plus)) {
    if (tokens.current is CharToken) {
      if (tokens.currentChar == TokenType.plus) {
        tokens.moveNext();
        Expression operandB = parseMulDivRem(tokens, scope);
        result = AddExpression(
          result,
          operandB,
          tokens.current.line,
          tokens.current.col,
          tokens.file,
          scope,
        );
      } else if (tokens.currentChar == TokenType.minus) {
        tokens.moveNext();
        Expression operandB = parseMulDivRem(tokens, scope);
        result = SubtractExpression(
          result,
          operandB,
          tokens.current.line,
          tokens.current.col,
          tokens.file,
          scope,
        );
      }
    }
  }
  return result;
}

Expression parseBitShifts(TokenIterator tokens, TypeValidator scope) {
  Expression operandA = parseAddSub(tokens, scope);
  while (tokens.current is CharToken) {
    if (tokens.currentChar == TokenType.leftShift) {
      tokens.moveNext();
      Expression operandB = parseAddSub(tokens, scope);
      operandA = ShiftLeftExpression(
        operandA,
        operandB,
        tokens.current.line,
        tokens.current.col,
        tokens.file,
        scope,
      );
    } else if (tokens.currentChar == TokenType.rightShift) {
      tokens.moveNext();
      Expression operandB = parseAddSub(tokens, scope);
      operandA = ShiftRightExpression(
        operandA,
        operandB,
        tokens.current.line,
        tokens.current.col,
        tokens.file,
        scope,
      );
    } else {
      break;
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
      if (!operandA.staticType.isSubtypeOf(scope.environment.integerType)) {
        throw BSCException("lhs of < is not an integer (is a ${operandA.staticType}) ${formatCursorPositionFromTokens(tokens)}", scope);
      }
      if (!operandB.staticType.isSubtypeOf(scope.environment.integerType)) {
        throw BSCException("rhs of < is not an integer (is a ${operandB.staticType}) ${formatCursorPositionFromTokens(tokens)}", scope);
      }
      return LessExpression(
        operandA,
        operandB,
        tokens.current.line,
        tokens.current.col,
        tokens.file,
        scope,
      );
    } else if (tokens.currentChar == TokenType.lessEqual) {
      tokens.moveNext();
      Expression operandB = parseRelOp(tokens, scope);
      if (!operandA.staticType.isSubtypeOf(scope.environment.integerType)) {
        throw BSCException("lhs of <= is not an integer (is a $operandA)", scope);
      }
      if (!operandB.staticType.isSubtypeOf(scope.environment.integerType)) {
        throw BSCException("rhs of <= is not an integer (is a $operandB)", scope);
      }
      return OrExpression(
        LessExpression(
          operandA,
          operandB,
          tokens.current.line,
          tokens.current.col,
          tokens.file,
          scope,
        ),
        EqualsExpression(
          operandA,
          operandB,
          scope,
          tokens.current.line,
          tokens.current.col,
          tokens.file,
        ),
        tokens.current.line,
        tokens.current.col,
        tokens.file,
        scope,
      );
    } else if (tokens.currentChar == TokenType.greater) {
      tokens.moveNext();
      Expression operandB = parseRelOp(tokens, scope);
      if (!operandA.staticType.isSubtypeOf(scope.environment.integerType)) {
        throw BSCException("lhs of > is not an integer (is a $operandA)", scope);
      }
      if (!operandB.staticType.isSubtypeOf(scope.environment.integerType)) {
        throw BSCException("rhs of > is not an integer (is a $operandB)", scope);
      }
      return GreaterExpression(
        operandA,
        operandB,
        tokens.current.line,
        tokens.current.col,
        tokens.file,
        scope,
      );
    } else if (tokens.currentChar == TokenType.greaterEqual) {
      tokens.moveNext();
      Expression operandB = parseRelOp(tokens, scope);
      if (!operandA.staticType.isSubtypeOf(scope.environment.integerType)) {
        throw BSCException("lhs of >= is not an integer (is $operandA, a ${operandA.staticType}) ${formatCursorPositionFromTokens(tokens)}", scope);
      }
      if (!operandB.staticType.isSubtypeOf(scope.environment.integerType)) {
        throw BSCException("rhs of >= is not an integer (is a $operandB ${formatCursorPositionFromTokens(tokens)})", scope);
      }
      return OrExpression(
        GreaterExpression(
          operandA,
          operandB,
          tokens.current.line,
          tokens.current.col,
          tokens.file,
          scope,
        ),
        EqualsExpression(
          operandA,
          operandB,
          scope,
          tokens.current.line,
          tokens.current.col,
          tokens.file,
        ),
        tokens.current.line,
        tokens.current.col,
        tokens.file,
        scope,
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
      if (!operandA.staticType.isSubtypeOf(operandB.staticType) && !operandB.staticType.isSubtypeOf(operandA.staticType)) {
        throw BSCException(
          "lhs and rhs of == are not compatible types (lhs is $operandA, a ${operandA.staticType}, rhs is $operandB, a ${operandB.staticType}) ${formatCursorPositionFromTokens(tokens)}}",
          scope,
        );
      }
      return EqualsExpression(
        operandA,
        operandB,
        scope,
        tokens.current.line,
        tokens.current.col,
        tokens.file,
      );
    } else if (tokens.currentChar == TokenType.notEquals) {
      tokens.moveNext();
      Expression operandB = parseEqNeq(tokens, scope);
      if (!operandA.staticType.isSubtypeOf(operandB.staticType) && !operandB.staticType.isSubtypeOf(operandA.staticType)) {
        throw BSCException(
          "lhs and rhs of != are not compatible types (lhs is $operandA, a ${operandA.staticType}, rhs is $operandB, a ${operandB.staticType}) ${formatCursorPositionFromTokens(tokens)}}",
          scope,
        );
      }
      return NotExpression(
        EqualsExpression(
          operandA,
          operandB,
          scope,
          tokens.current.line,
          tokens.current.col,
          tokens.file,
        ),
        tokens.current.line,
        tokens.current.col,
        tokens.file,
        scope,
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
    if (!operandA.staticType.isSubtypeOf(scope.environment.integerType)) {
      throw BSCException("lhs of & is not an integer (is $operandA, a ${operandA.staticType} ${formatCursorPositionFromTokens(tokens)})", scope);
    }
    if (!operandB.staticType.isSubtypeOf(scope.environment.integerType)) {
      throw BSCException("rhs of & is not an integer (is $operandB, a ${operandB.staticType} ${formatCursorPositionFromTokens(tokens)})", scope);
    }
    return BitAndExpression(
      operandA,
      operandB,
      scope,
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
    if (!operandA.staticType.isSubtypeOf(scope.environment.integerType)) {
      throw BSCException("lhs of ^ is not an integer (is $operandA, a ${operandA.staticType} ${formatCursorPositionFromTokens(tokens)})", scope);
    }
    if (!operandB.staticType.isSubtypeOf(scope.environment.integerType)) {
      throw BSCException("rhs of ^ is not an integer (is $operandB, a ${operandB.staticType} ${formatCursorPositionFromTokens(tokens)})", scope);
    }
    return BitXorExpression(
      operandA,
      operandB,
      scope,
      tokens.current.line,
      tokens.current.col,
      tokens.file,
    );
  }
  return operandA;
}
