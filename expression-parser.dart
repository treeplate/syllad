import 'lexer.dart';
import 'parser-core.dart';
import 'expressions.dart';

Expression parseLiterals(TokenIterator tokens, TypeValidator scope) {
  Token current = tokens.current;
  switch (tokens.current.runtimeType) {
    case IntToken:
      int i = tokens.integer;
      tokens.moveNext();
      return IntLiteralExpression(
        i,
        current.line,
        current.col,
        tokens.workspace,
        tokens.file,
      );
    case IdentToken:
      if (tokens.currentIdent == variables['super']) {
        tokens.moveNext();
        tokens.expectChar(TokenType.period);
        Variable member = tokens.currentIdent;
        ValueType? superclass = scope.currentClassType.parent;
        if (superclass is! ClassValueType) {
          throw BSCException(
              '${scope.currentClassType} has no superclass; attempted \'super.${member.name}\' ${formatCursorPositionFromTokens(tokens)}', scope);
        }
        if (scope.indirectlyStaticMethod) {
          tokens.moveNext();
          return SuperExpression(
            member,
            scope,
            current.line,
            current.col,
            tokens.workspace,
            tokens.file,
            true,
          );
        }
        TypeValidator props = superclass.properties;
        if (props.igv(member, true, current.line, current.col, tokens.workspace, tokens.file, true, false, false, true) == null) {
          throw BSCException(
            '${scope.currentClassType.name.name}\'s superclass (${superclass.name.name}) has no member ${member.name}; attempted \'super.${member.name}\' ${formatCursorPositionFromTokens(tokens)}',
            scope,
          );
        }
        tokens.moveNext();
        return SuperExpression(
          member,
          scope,
          current.line,
          current.col,
          tokens.workspace,
          tokens.file,
          false,
        );
      } else if (tokens.currentIdent == (variables['assert'] ??= Variable('assert'))) {
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
          current.line,
          current.col,
          tokens.workspace,
          tokens.file,
        );
      } else if (tokens.currentIdent == variables['LINE']) {
        tokens.moveNext();
        return IntLiteralExpression(current.line, current.line, current.col, tokens.workspace, tokens.file);
      } else if (tokens.currentIdent == variables['COL']) {
        tokens.moveNext();
        return IntLiteralExpression(current.col, current.line, current.col, tokens.workspace, tokens.file);
      } else if (tokens.currentIdent == variables['FILE']) {
        tokens.moveNext();
        return StringLiteralExpression(tokens.file, current.line, current.col, tokens.workspace, tokens.file);
      }
      Expression e = GetExpr(
        tokens.currentIdent,
        scope,
        current.line,
        current.col,
        tokens.workspace,
        tokens.file,
      );
      tokens.moveNext();
      return e;
    case StringToken:
      String s = tokens.string;
      tokens.moveNext();
      return StringLiteralExpression(s, current.line, current.col, tokens.workspace, tokens.file);
    case CommentFeatureToken:
      throw BSCException(
        'Unexpected comment feature, remove please. ${formatCursorPositionFromTokens(tokens)}',
        scope,
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
          if (type == null && !(expr.type.name == whateverVariable)) {
            type = expr.type;
          } else if (expr.type.name == whateverVariable) {
            // has been cast()-ed
          } else if (type != expr.type) {
            type = anythingType;
          }
        }
        if (type == null) {
          type = anythingType;
        }
        tokens.moveNext();
        if (tokens.current is CharToken && tokens.currentChar == TokenType.colon) {
          tokens.moveNext();
          ValueType t = ValueType.create(null, tokens.currentIdent, current.line, current.col, tokens.workspace, tokens.file, scope);
          for (Expression expr in elements) {
            if (!expr.type.isSubtypeOf(t)) {
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
          tokens.workspace,
          tokens.file,scope,
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
            throw BSCException("Attempted to subscript using non-integer index: $operandB. ${formatCursorPositionFromTokens(tokens)}", scope);
          }
          tokens.expectChar(TokenType.closeSquare);
          if (!result.type.isSubtypeOf(ArrayValueType(ValueType.create(null, whateverVariable, -2, 0, 'interr', 'internal', scope), 'internal', scope))) {
            throw BSCException("tried to subscript ${result.type} ($result) ${formatCursorPositionFromTokens(tokens)}", scope);
          }
          result = SubscriptExpression(
            result,
            operandB,
            tokens.current.line,
            tokens.current.col,
            tokens.workspace,
            tokens.file,scope,
          );
        } else if (tokens.currentChar == TokenType.period) {
          if (!result.type.memberAccesible()) {
            throw BSCException("tried to access member of ${result.type} ${formatCursorPositionFromTokens(tokens)}", scope);
          }
          tokens.moveNext();
          Variable operandB = tokens.currentIdent;
          TypeValidator? properties;
          bool checkParent = false;
          if (result.type is ClassOfValueType) {
            properties = (result.type as ClassOfValueType).staticMembers;
            checkParent = true;
          }
          if (result.type is EnumValueType) {
            properties = (result.type as EnumValueType).staticMembers;
          }
          if (result.type is ClassValueType) {
            properties = (result.type as ClassValueType).properties;
            checkParent = true;
          }
          if (properties != null &&
              properties.igv(operandB, true, tokens.current.line, tokens.current.col, tokens.workspace, tokens.file, checkParent, false) == null) {
            throw BSCException(
              "tried to access nonexistent member '${operandB.name}' of ${result.type} ${properties.types.keys.map((e) => e.name)} ${formatCursorPositionFromTokens(tokens)}",
              scope,
            );
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
          if (!nullType.isSubtypeOf(result.type)) {
            throw BSCException("Attempted unwrap of non-nullable type (${result.type}) ${formatCursorPositionFromTokens(tokens)}", scope);
          }
          result = UnwrapExpression(
            result,
            tokens.current.line,
            tokens.current.col,
            tokens.workspace,
            tokens.file,
          );
        } else {
          if (result.type is! ClassOfValueType && !result.type.isSubtypeOf(GenericFunctionValueType(anythingType, tokens.file, scope))) {
            throw BSCException("tried to call ${result.type} ($result) ${formatCursorPositionFromTokens(tokens)}", scope);
          }
          tokens.moveNext();
          List<Expression> arguments = [];
          GenericFunctionValueType funType;
          if (result.type is ClassOfValueType) {
            funType = (result.type as ClassOfValueType).constructor;
          } else if (result.type is GenericFunctionValueType) {
            funType = result.type as GenericFunctionValueType;
          } else {
            funType = ValueType.create(anythingType, variables['AnythingFunction']!, 0, 0, '', '', scope) as GenericFunctionValueType;
          }
          while (tokens.current is! CharToken || tokens.currentChar != TokenType.closeParen) {
            if ((funType is FunctionValueType) && funType.parameters is! InfiniteIterable && funType.parameters.length <= arguments.length) {
              throw BSCException(
                "Too many arguments to $result, type is ${funType} - expected ${funType.parameters}, got $arguments ${formatCursorPositionFromTokens(tokens)}",
                scope,
              );
            }
            Expression expr = parseExpression(
              tokens,
              scope,
            );
            if (funType is FunctionValueType) {
              if (!expr.type.isSubtypeOf(funType.parameters.elementAt(arguments.length))) {
                throw BSCException(
                  "parameter ${arguments.length} of $result expects type ${funType.parameters.elementAt(arguments.length)} got $expr (a ${expr.type}) ${formatCursorPositionFromTokens(tokens)}",
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

Expression parseExponentiation(TokenIterator tokens, TypeValidator scope) {
  Expression operandA = parseNots(tokens, scope);
  if (tokens.current is CharToken) {
    if (tokens.currentChar == TokenType.starStar) {
      tokens.moveNext();
      Expression operandB = parseExponentiation(tokens, scope);
      return PowExpression(
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
        tokens.workspace,
        tokens.file,
      );
    } else if (tokens.currentChar == TokenType.divide) {
      tokens.moveNext();
      Expression operandB = parseExponentiation(tokens, scope);
      operandA = DivideExpression(
        operandA,
        operandB,
        tokens.current.line,
        tokens.current.col,
        tokens.workspace,
        tokens.file,
      );
    } else if (tokens.currentChar == TokenType.remainder) {
      tokens.moveNext();
      Expression operandB = parseExponentiation(tokens, scope);
      operandA = RemainderExpression(
        operandA,
        operandB,
        tokens.current.line,
        tokens.current.col,
        tokens.workspace,
        tokens.file,
      );
    } else {
      break;
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
        IntLiteralExpression(0, tokens.current.line, tokens.current.col, tokens.workspace, tokens.file),
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
  if (tokens.current is CharToken && tokens.currentChar == TokenType.isIdent) {
    tokens.moveNext();
    ValueType type = ValueType.create(null, tokens.currentIdent, tokens.current.line, tokens.current.col, tokens.workspace, tokens.file, scope);
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
  if (tokens.current is CharToken && tokens.currentChar == TokenType.asIdent) {
    tokens.moveNext();
    ValueType type = ValueType.create(null, tokens.currentIdent, tokens.current.line, tokens.current.col, tokens.workspace, tokens.file, scope);
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
          tokens.workspace,
          tokens.file,
        );
      } else if (tokens.currentChar == TokenType.minus) {
        tokens.moveNext();
        Expression operandB = parseMulDivRem(tokens, scope);
        result = SubtractExpression(
          result,
          operandB,
          tokens.current.line,
          tokens.current.col,
          tokens.workspace,
          tokens.file,
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
        tokens.workspace,
        tokens.file,
      );
    } else if (tokens.currentChar == TokenType.rightShift) {
      tokens.moveNext();
      Expression operandB = parseAddSub(tokens, scope);
      operandA = ShiftRightExpression(
        operandA,
        operandB,
        tokens.current.line,
        tokens.current.col,
        tokens.workspace,
        tokens.file,
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
      if (!operandA.type.isSubtypeOf(integerType)) {
        throw BSCException("lhs of < is not an integer (is a ${operandA.type}) ${formatCursorPositionFromTokens(tokens)}", scope);
      }
      if (!operandB.type.isSubtypeOf(integerType)) {
        throw BSCException("rhs of < is not an integer (is a ${operandB.type}) ${formatCursorPositionFromTokens(tokens)}", scope);
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
        throw BSCException("lhs of <= is not an integer (is a $operandA)", scope);
      }
      if (!operandB.type.isSubtypeOf(integerType)) {
        throw BSCException("rhs of <= is not an integer (is a $operandB)", scope);
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
        throw BSCException("lhs of > is not an integer (is a $operandA)", scope);
      }
      if (!operandB.type.isSubtypeOf(integerType)) {
        throw BSCException("rhs of > is not an integer (is a $operandB)", scope);
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
        throw BSCException("lhs of >= is not an integer (is $operandA, a ${operandA.type}) ${formatCursorPositionFromTokens(tokens)}", scope);
      }
      if (!operandB.type.isSubtypeOf(integerType)) {
        throw BSCException("rhs of >= is not an integer (is a $operandB ${formatCursorPositionFromTokens(tokens)})", scope);
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
      if (!operandA.type.isSubtypeOf(operandB.type) && !operandB.type.isSubtypeOf(operandA.type)) {
        throw BSCException(
          "lhs and rhs of == are not compatible types (lhs is $operandA, a ${operandA.type}, rhs is $operandB, a ${operandB.type}) ${formatCursorPositionFromTokens(tokens)}}",
          scope,
        );
      }
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
      if (!operandA.type.isSubtypeOf(operandB.type) && !operandB.type.isSubtypeOf(operandA.type)) {
        throw BSCException(
          "lhs and rhs of != are not compatible types (lhs is $operandA, a ${operandA.type}, rhs is $operandB, a ${operandB.type}) ${formatCursorPositionFromTokens(tokens)}}",
          scope,
        );
      }
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
      throw BSCException("lhs of & is not an integer (is $operandA, a ${operandA.type} ${formatCursorPositionFromTokens(tokens)})", scope);
    }
    if (!operandB.type.isSubtypeOf(integerType)) {
      throw BSCException("rhs of & is not an integer (is $operandB, a ${operandB.type} ${formatCursorPositionFromTokens(tokens)})", scope);
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
      throw BSCException("lhs of ^ is not an integer (is $operandA, a ${operandA.type} ${formatCursorPositionFromTokens(tokens)})", scope);
    }
    if (!operandB.type.isSubtypeOf(integerType)) {
      throw BSCException("rhs of ^ is not an integer (is $operandB, a ${operandB.type} ${formatCursorPositionFromTokens(tokens)})", scope);
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
