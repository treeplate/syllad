import 'syd-statements.dart';
import 'syd-lexer.dart';
import 'syd-core.dart';
import 'syd-expressions.dart';
import 'syd-expression-parser.dart';
import 'dart:io';
import 'package:path/path.dart' as path;

List<Statement> parseBlock(TokenIterator tokens, TypeValidator scope, [bool acceptCB = true]) {
  List<Statement> block = [];
  while (tokens.current is! CharToken ||
      ((tokens.current as CharToken).type != TokenType.endOfFile && ((tokens.current as CharToken).type != TokenType.closeBrace || !acceptCB))) {
    block.add(parseStatement(tokens, scope));
  }
  return block;
}

ClassStatement parseClass(TokenIterator tokens, TypeValidator scope, bool ignoreUnused) {
  tokens.moveNext();
  Identifier name = tokens.currentIdent;
  if (ValueType.hasTypeSuffix(name)) {
    throw CompileTimeSydException('Cannot declare class type with reserved type name ${name.name} ${formatCursorPositionFromTokens(tokens)}', scope);
  }
  tokens.moveNext();
  Identifier? superclass;
  if (tokens.current is IdentToken && tokens.currentIdent == scope.identifiers['extends']) {
    tokens.moveNext();
    superclass = tokens.currentIdent;
    scope.getVar(superclass, tokens.current.line, tokens.current.col, tokens.file, 'for subclassing');
    tokens.moveNext();
  }
  tokens.expectChar(TokenType.openBrace);
  ValueType? supertype = superclass == null
      ? null
      : ValueType.create(
          superclass,
          tokens.current.line,
          tokens.current.col,
          tokens.file,
          scope.environment,
          scope.typeTable,
        );
  if (supertype is! ClassValueType?) {
    throw CompileTimeSydException('${superclass!.name} not a class while trying to have ${name.name} extend it. ${formatCursorPositionFromTokens(tokens)}', scope);
  } else if (supertype?.notFullyDeclared ?? false) {
    throw CompileTimeSydException(
      'Class ${name.name} is defined as subtyping ${supertype!.name.name}, but that has not been declared yet, merely forward-declared. ${formatCursorPositionFromTokens(tokens)}',
      scope,
    );
  }
  TypeValidator newScope = superclass == null
      ? TypeValidator([scope], ConcatenateLazyString(NotLazyString('root class '), IdentifierLazyString(name)), true, false, false, scope.rtl,
          scope.identifiers, scope.environment, false, false, false)
      : TypeValidator([scope], ConcatenateLazyString(NotLazyString('subclass '), IdentifierLazyString(name)), true, false, false, scope.rtl, scope.identifiers,
          scope.environment, false, false, false);
  if (superclass != null) {
    for (MapEntry<Identifier, TVProp> property in supertype!.properties.types.entries) {
      newScope.newVar(property.key, property.value.type, tokens.current.line, tokens.current.col, tokens.file, !supertype.properties.igvnc(property.key),
          property.value.isFwd, property.value.validForSuper);
      assert(newScope.igv(property.key, false, -2, 0, '', true, false, true) == property.value.type);
    }
  }
  ClassValueType type = ClassValueType(name, supertype, newScope, tokens.file, false, scope.environment, scope.typeTable);
  if (newScope != type.properties) {
    if (supertype != type.supertype) {
      throw CompileTimeSydException(
        '${name.name} does not have the same supertype ($supertype) as forward declaration (${type.supertype}) ${formatCursorPositionFromTokens(tokens)}',
        scope,
      );
    }
  }
  TypeValidator fwdProps = type.properties.copy();
  bool hasFwdDecl = newScope != type.properties;
  if (hasFwdDecl && !type.forwardDeclared) {
    throw CompileTimeSydException(
      '${name.name} was declared twice ${formatCursorPositionFromTokens(tokens)}',
      scope,
    );
  }
  type.properties.types = newScope.types;
  type.properties.nonconst = newScope.nonconst..addAll(fwdProps.nonconst);
  newScope.usedVars = type.properties.usedVars;
  if (superclass == null) {
    newScope.newVar(
      thisVariable,
      type,
      tokens.current.line,
      tokens.current.col,
      tokens.file,
    );
    newScope.newVar(
      classNameVariable,
      scope.environment.stringType,
      tokens.current.line,
      tokens.current.col,
      tokens.file,
    );
  } else {
    newScope.directVars.clear();
    newScope.types[thisVariable] = TVProp(false, type, true, newScope.types[thisVariable]!.index);
  }
  newScope.usedVars.add(thisVariable);
  newScope.usedVars.add(classNameVariable);
  newScope.usedVars.add(toStringVariable);

  for (MapEntry<Identifier, TVProp> property in fwdProps.types.entries) {
    if (!newScope.types.containsKey(property.key)) {
      newScope.newVar(property.key, property.value.type, tokens.current.line, tokens.current.col, tokens.file, !fwdProps.igvnc(property.key),
          property.value.isFwd, property.value.validForSuper);
    }
  }
  newScope.directVars.clear();
  List<Statement> block = parseBlock(tokens, newScope);
  ValueType? supertype1 = superclass != null ? scope.igv(scope.identifiers['${superclass.name}']!, true) : null;
  if (supertype1 is FunctionValueType) {
    throw CompileTimeSydException('Cannot extend an class that has not been defined yet.', scope);
  }
  TypeValidator staticMembers = TypeValidator(
      [if (superclass != null) (supertype1 as ClassOfValueType).staticMembers else scope],
      ConcatenateLazyString(NotLazyString('static members of '), IdentifierLazyString(name)),
      false,
      true,
      false,
      scope.rtl,
      scope.identifiers,
      scope.environment,
      false, false, false);
  for (Statement statement in block) {
    if (statement is StaticFieldStatement) {
      if (!statement.val.staticType.isSubtypeOf(
          staticMembers.igv(statement.name, false, tokens.current.line, tokens.current.col, tokens.file, true, false) ?? scope.environment.anythingType)) {
        throw CompileTimeSydException(
          'Invalid override of static member ${statement.name.name} - expected ${staticMembers.igv(statement.name, false, tokens.current.line, tokens.current.col, tokens.file, true, false)} but got ${statement.val.staticType} ${formatCursorPositionFromTokens(tokens)}',
          scope,
        );
      }
      staticMembers.newVar(
        statement.name,
        statement.val.staticType,
        statement.line,
        statement.col,
        tokens.file,
      );
    }
    if (statement is FunctionStatement && statement.static) {
      if (!statement.type.isSubtypeOf(
          staticMembers.igv(statement.name, false, tokens.current.line, tokens.current.col, tokens.file, true, false) ?? scope.environment.anythingType)) {
        throw CompileTimeSydException(
          'Invalid override of static member ${statement.name.name} - expected ${staticMembers.igv(statement.name, false, tokens.current.line, tokens.current.col, tokens.file, true, false)} but got ${statement.type} ${formatCursorPositionFromTokens(tokens)}',
          scope,
        );
      }
      staticMembers.newVar(
        statement.name,
        statement.type,
        statement.line,
        statement.col,
        tokens.file,
      );
    }
  }
  if (!(newScope.igv(constructorVariable, true)?.isSubtypeOf(GenericFunctionValueType(scope.environment.nullType, tokens.file, scope.environment, scope.typeTable)) ?? true)) {
    throw CompileTimeSydException('Bad constructor type: ${newScope.igv(constructorVariable, true)} ${formatCursorPositionFromTokens(tokens)}', scope);
  }
  if (!hasFwdDecl) {
    if (supertype != null) {
      for (MapEntry<Identifier, TVProp> property in newScope.types.entries) {
        if (!property.value.type.isSubtypeOf(
              supertype.properties.igv(
                    property.key,
                    false,
                    -2,
                    0,
                    'err',
                    true,
                    false,
                  ) ??
                  scope.environment.anythingType,
            ) &&
            property.key != constructorVariable &&
            property.value.runtimeType != GenericFunctionValueType) {
          throw CompileTimeSydException(
            '${name.name} type has invalid override of ${superclass!.name}.${property.key.name} (expected ${supertype.properties.igv(property.key, false)}, got ${property.value.type} ${formatCursorPositionFromTokens(tokens)}',
            scope,
          );
        }
      }
    }
  }
  if (hasFwdDecl) {
    for (MapEntry<Identifier, TVProp> value in fwdProps.types.entries) {
      if (value.key == constructorVariable) {
        if ((newScope.igv(value.key, false, -2, 0, '', true, false, false) ?? FunctionValueType(scope.environment.nullType, [], 'xxx', scope.environment, scope.typeTable)) !=
            value.value.type) {
          throw CompileTimeSydException(
              '${name.name}\'s constructor (${newScope.igv(value.key, false, -2, 0, '', true, false, false) ?? 'NullFunction() - default'}) does not match forward declaration (${value.value.type}) ${formatCursorPositionFromTokens(tokens)}',
              scope);
        }
      } else {
        ValueType? newType = newScope.igv(value.key, false, -2, 0, '', true, false, false);
        if (newType != value.value.type) {
          throw CompileTimeSydException(
              '${name.name}.${value.key.name} (a ${newType}) does not match forward declaration (a ${value.value.type}) ${formatCursorPositionFromTokens(tokens)}',
              scope);
        } else if (newType is FunctionValueType && value.value.type is! FunctionValueType) {
          // this will break when we get function types with arguments specifiable by fields
          throw CompileTimeSydException(
              '${name.name}.${value.key.name} was forward-declared with a fwdclassfield but is a method ${formatCursorPositionFromTokens(tokens)}', scope);
        } else if (newType is! FunctionValueType && value.value.type is FunctionValueType) {
          // this will break when we get function types with arguments specifiable by fields
          throw CompileTimeSydException(
              '${name.name}.${value.key.name} was forward-declared with a fwdclassmethod but is a field ${formatCursorPositionFromTokens(tokens)}', scope);
        }
      }
    }
  }
  scope.classes[name] = newScope;
  if (hasFwdDecl) {
    scope.directVars.remove(name); // will be re-added in a few lines
  }
  GenericFunctionValueType constructorType = (type.recursiveLookup(constructorVariable)?.key is FunctionValueType?
      ? FunctionValueType(type, (type.recursiveLookup(constructorVariable)?.key as FunctionValueType?)?.parameters ?? [], tokens.file, scope.environment, scope.typeTable)
      : GenericFunctionValueType(type, tokens.file, scope.environment, scope.typeTable));
  ClassOfValueType classOfType = ClassOfValueType(
    type,
    staticMembers,
    constructorType,
    tokens.file,
    scope.environment,
    scope.typeTable,
  );
  if (!hasFwdDecl) {
    scope.newVar(
      name,
      classOfType,
      tokens.current.line,
      tokens.current.col,
      tokens.file,
    );
  }
  if (ignoreUnused) {
    scope.igv(name, true);
  }
  scope.nonconst.remove(name);
  tokens.expectChar(TokenType.closeBrace);
  return ClassStatement(name, superclass, block, type, tokens.current.line, tokens.current.col, tokens.file, classOfType, scope);
}

Statement parseNonKeywordStatement(TokenIterator tokens, TypeValidator scope) {
  bool overriden = false;
  bool ignoreUnused = false;
  if (tokens.current is CommentFeatureToken) {
    String feature = (tokens.current as CommentFeatureToken).feature;
    if (feature == 'override') {
      overriden = true;
      tokens.moveNext();
    } else if (feature == 'ignore_unused') {
      ignoreUnused = true;
      tokens.moveNext();
    }
  }
  if (tokens.current is CommentFeatureToken) {
    String feature = (tokens.current as CommentFeatureToken).feature;
    if (feature == 'override') {
      if (overriden) {
        throw CompileTimeSydException('Duplicate override comment feature ${formatCursorPositionFromTokens(tokens)}', scope);
      }
      overriden = true;
      tokens.moveNext();
    } else if (feature == 'ignore_unused') {
      if (ignoreUnused) {
        throw CompileTimeSydException('Duplicate ignore_unused comment feature ${formatCursorPositionFromTokens(tokens)}', scope);
      }
      ignoreUnused = true;
      tokens.moveNext();
    }
  }
  int line = tokens.current.line;
  int col = tokens.current.col;
  bool static = false;
  if (tokens.current is IdentToken && tokens.currentIdent == scope.identifiers['static']) {
    static = true;
    tokens.moveNext();
  }
  Expression expr;
  if (!tokens.next2Idents) {
    if (tokens.current is IdentToken && scope.igv(tokens.currentIdent, false) != null && !scope.usedVars.contains(tokens.currentIdent)) {
      expr = parseExpression(tokens, scope);
      scope.usedVars.remove(expr is GetExpr ? expr.name : null);
    } else {
      expr = parseExpression(tokens, scope);
    }
    if (expr is SubscriptExpression && expr.a.staticType is ArrayValueType && tokens.currentChar != TokenType.endOfStatement) {
      throw CompileTimeSydException('Tried to modify array ${formatCursorPositionFromTokens(tokens)}', scope);
    }
    if (!tokens.next2Idents && tokens.current is CharToken && tokens.currentChar == TokenType.endOfStatement) {
      if (overriden || ignoreUnused)
        throw CompileTimeSydException('Comment features are currently pointless for expression statements ${formatCursorPositionFromTokens(tokens)}', scope);
      if (static) {
        throw CompileTimeSydException('static expression statements make no sense ${formatCursorPositionFromTokens(tokens)}', scope);
      }
      if (expr is GetExpr) {
        scope.usedVars.add(expr.name);
      }
      tokens.expectChar(TokenType.endOfStatement);
      return ExpressionStatement(expr, line, col);
    }
    if (tokens.current is CharToken) {
      if (overriden || ignoreUnused)
        throw CompileTimeSydException('Comment features are currently pointless for x++, x+=y, x--, x-=y, x=y, etc ${formatCursorPositionFromTokens(tokens)}', scope);
      if (static) {
        throw CompileTimeSydException('static x++, x+=y, x--, x-=y, x=y, etc make no sense ${formatCursorPositionFromTokens(tokens)}', scope);
      }
      if (tokens.currentChar == TokenType.set) {
        tokens.moveNext();
        Expression value = parseExpression(tokens, scope);
        if (!expr.isLValue(scope)) {
          throw CompileTimeSydException('$expr is not an lvalue for = ${formatCursorPositionFromTokens(tokens)}', scope);
        }
        if (!value.staticType.isSubtypeOf(expr.staticType)) {
          throw CompileTimeSydException('attempted $expr=$value but $value was not a ${expr.staticType} ${formatCursorPositionFromTokens(tokens)}', scope);
        }
        tokens.expectChar(TokenType.endOfStatement);
        return SetStatement(expr, value, line, col, tokens.file);
      }
      if (tokens.currentChar == TokenType.plusEquals) {
        if (!expr.staticType.isSubtypeOf(scope.environment.integerType)) {
          throw CompileTimeSydException('Attempted $expr (not an integer!) += ... ${formatCursorPositionFromTokens(tokens)}', scope);
        }
        tokens.moveNext();
        Expression value = parseExpression(tokens, scope);
        if (!value.staticType.isSubtypeOf(scope.environment.integerType)) {
          throw CompileTimeSydException(
            'attempted $expr+=$value but $value was not an integer ${formatCursorPositionFromTokens(tokens)}',
            scope,
          );
        }
        tokens.expectChar(TokenType.endOfStatement);
        if (!expr.isLValue(scope)) {
          throw CompileTimeSydException('$expr is not an lvalue for += ${formatCursorPositionFromTokens(tokens)}', scope);
        }
        return SetStatement(
          expr,
          AddExpression(
            expr,
            value,
            line,
            col,
            tokens.file,
            scope,
          ),
          line,
          col,
          tokens.file,
        );
      } else if (tokens.currentChar == TokenType.plusPlus) {
        if (!expr.staticType.isSubtypeOf(scope.environment.integerType)) {
          throw CompileTimeSydException('Attempted $expr (not an integer!) ++ ... ${formatCursorPositionFromTokens(tokens)}', scope);
        }
        tokens.expectChar(TokenType.plusPlus);
        tokens.expectChar(TokenType.endOfStatement);
        assert(expr.isLValue(scope));
        return SetStatement(
          expr,
          AddExpression(
            expr,
            IntLiteralExpression(
              1,
              line,
              col,
              tokens.file,
              scope,
            ),
            line,
            col,
            tokens.file,
            scope,
          ),
          line,
          col,
          tokens.file,
        );
      } else if (tokens.currentChar == TokenType.minusEquals) {
        if (!expr.staticType.isSubtypeOf(scope.environment.integerType)) {
          throw CompileTimeSydException('Attempted $expr (not an integer!) -= ... ${formatCursorPositionFromTokens(tokens)}', scope);
        }
        tokens.moveNext();
        Expression value = parseExpression(tokens, scope);
        if (!value.staticType.isSubtypeOf(scope.environment.integerType)) {
          throw CompileTimeSydException(
            'attempted $expr-=$value but $value was not an integer ${formatCursorPositionFromTokens(tokens)}',
            scope,
          );
        }
        tokens.expectChar(TokenType.endOfStatement);
        if (!expr.isLValue(scope)) {
          throw CompileTimeSydException('$expr is not valid l-value; attempted to do -=', scope);
        }
        return SetStatement(
          expr,
          SubtractExpression(
            expr,
            value,
            line,
            col,
            tokens.file,
            scope,
          ),
          line,
          col,
          tokens.file,
        );
      } else if (tokens.currentChar == TokenType.minusMinus) {
        if (!expr.staticType.isSubtypeOf(scope.environment.integerType)) {
          throw CompileTimeSydException('Attempted $expr (not an integer!) -- ... ${formatCursorPositionFromTokens(tokens)}', scope);
        }
        tokens.expectChar(TokenType.minusMinus);
        tokens.expectChar(TokenType.endOfStatement);
        assert(expr.isLValue(scope));
        return SetStatement(
          expr,
          SubtractExpression(
            expr,
            IntLiteralExpression(
              1,
              line,
              col,
              tokens.file,
              scope,
            ),
            line,
            col,
            tokens.file,
            scope,
          ),
          line,
          col,
          tokens.file,
        );
      } else if (tokens.currentChar == TokenType.bitOrEquals) {
        if (!expr.staticType.isSubtypeOf(scope.environment.integerType)) {
          throw CompileTimeSydException('Attempted $expr (not an integer!) |= ... ${formatCursorPositionFromTokens(tokens)}', scope);
        }
        tokens.moveNext();
        Expression value = parseExpression(tokens, scope);
        if (!value.staticType.isSubtypeOf(scope.environment.integerType)) {
          throw CompileTimeSydException(
            'attempted $expr|=$value but $value was not an integer ${formatCursorPositionFromTokens(tokens)}',
            scope,
          );
        }
        tokens.expectChar(TokenType.endOfStatement);
        if (!expr.isLValue(scope)) {
          throw CompileTimeSydException('$expr is not valid l-value; attempted to do |=', scope);
        }
        return SetStatement(
          expr,
          BitOrExpression(
            expr,
            value,
            line,
            col,
            tokens.file,
            scope,
          ),
          line,
          col,
          tokens.file,
        );
      } else if (tokens.currentChar == TokenType.bitAndEquals) {
        if (!expr.staticType.isSubtypeOf(scope.environment.integerType)) {
          throw CompileTimeSydException('Attempted $expr (not an integer!) &= ... ${formatCursorPositionFromTokens(tokens)}', scope);
        }
        tokens.moveNext();
        Expression value = parseExpression(tokens, scope);
        if (!value.staticType.isSubtypeOf(scope.environment.integerType)) {
          throw CompileTimeSydException(
            'attempted $expr&=$value but $value was not an integer ${formatCursorPositionFromTokens(tokens)}',
            scope,
          );
        }
        tokens.expectChar(TokenType.endOfStatement);
        if (!expr.isLValue(scope)) {
          throw CompileTimeSydException('$expr is not valid l-value; attempted to do &=', scope);
        }
        return SetStatement(
          expr,
          BitAndExpression(
            expr,
            value,
            scope,
            line,
            col,
            tokens.file,
          ),
          line,
          col,
          tokens.file,
        );
      } else if (tokens.currentChar == TokenType.bitXorEquals) {
        if (!expr.staticType.isSubtypeOf(scope.environment.integerType)) {
          throw CompileTimeSydException('Attempted $expr (not an integer!) ^= ... ${formatCursorPositionFromTokens(tokens)}', scope);
        }
        tokens.moveNext();
        Expression value = parseExpression(tokens, scope);
        if (!value.staticType.isSubtypeOf(scope.environment.integerType)) {
          throw CompileTimeSydException(
            'attempted $expr^=$value but $value was not an integer ${formatCursorPositionFromTokens(tokens)}',
            scope,
          );
        }
        tokens.expectChar(TokenType.endOfStatement);
        if (!expr.isLValue(scope)) {
          throw CompileTimeSydException('$expr is not valid l-value; attempted to do ^=', scope);
        }
        return SetStatement(
          expr,
          BitXorExpression(
            expr,
            value,
            scope,
            line,
            col,
            tokens.file,
          ),
          line,
          col,
          tokens.file,
        );
      } else if (tokens.currentChar == TokenType.andandEquals) {
        if (!expr.staticType.isSubtypeOf(scope.environment.booleanType)) {
          throw CompileTimeSydException('Attempted $expr (not an boolean!) &&= ... ${formatCursorPositionFromTokens(tokens)}', scope);
        }
        tokens.moveNext();
        Expression value = parseExpression(tokens, scope);
        if (!value.staticType.isSubtypeOf(scope.environment.booleanType)) {
          throw CompileTimeSydException(
            'attempted $expr&&=$value but $value was not an boolean ${formatCursorPositionFromTokens(tokens)}',
            scope,
          );
        }
        tokens.expectChar(TokenType.endOfStatement);
        if (!expr.isLValue(scope)) {
          throw CompileTimeSydException('$expr is not valid l-value; attempted to do &&=', scope);
        }
        return SetStatement(
          expr,
          AndExpression(
            expr,
            value,
            line,
            col,
            tokens.file,
            scope,
          ),
          line,
          col,
          tokens.file,
        );
      } else if (tokens.currentChar == TokenType.ororEquals) {
        if (!expr.staticType.isSubtypeOf(scope.environment.booleanType)) {
          throw CompileTimeSydException('Attempted $expr (not an boolean!) ||= ... ${formatCursorPositionFromTokens(tokens)}', scope);
        }
        tokens.moveNext();
        Expression value = parseExpression(tokens, scope);
        if (!value.staticType.isSubtypeOf(scope.environment.booleanType)) {
          throw CompileTimeSydException(
            'attempted $expr||=$value but $value was not an boolean ${formatCursorPositionFromTokens(tokens)}',
            scope,
          );
        }
        tokens.expectChar(TokenType.endOfStatement);
        if (!expr.isLValue(scope)) {
          throw CompileTimeSydException('$expr is not valid l-value; attempted to do ||=', scope);
        }
        return SetStatement(
          expr,
          OrExpression(
            expr,
            value,
            line,
            col,
            tokens.file,
            scope,
          ),
          line,
          col,
          tokens.file,
        );
      } else if (tokens.currentChar == TokenType.divideEquals) {
        if (!expr.staticType.isSubtypeOf(scope.environment.integerType)) {
          throw CompileTimeSydException('Attempted $expr (not an integer!) /= ... ${formatCursorPositionFromTokens(tokens)}', scope);
        }
        tokens.moveNext();
        Expression value = parseExpression(tokens, scope);
        if (!value.staticType.isSubtypeOf(scope.environment.integerType)) {
          throw CompileTimeSydException(
            'attempted $expr/=$value but $value was not an integer ${formatCursorPositionFromTokens(tokens)}',
            scope,
          );
        }
        tokens.expectChar(TokenType.endOfStatement);
        if (!expr.isLValue(scope)) {
          throw CompileTimeSydException('$expr is not valid l-value; attempted to do /=', scope);
        }
        return SetStatement(
          expr,
          DivideExpression(
            expr,
            value,
            line,
            col,
            tokens.file,
            scope,
          ),
          line,
          col,
          tokens.file,
        );
      } else if (tokens.currentChar == TokenType.starEquals) {
        if (!expr.staticType.isSubtypeOf(scope.environment.integerType)) {
          throw CompileTimeSydException('Attempted $expr (not an integer!) *= ... ${formatCursorPositionFromTokens(tokens)}', scope);
        }
        tokens.moveNext();
        Expression value = parseExpression(tokens, scope);
        if (!value.staticType.isSubtypeOf(scope.environment.integerType)) {
          throw CompileTimeSydException(
            'attempted $expr*=$value but $value was not an integer ${formatCursorPositionFromTokens(tokens)}',
            scope,
          );
        }
        tokens.expectChar(TokenType.endOfStatement);
        if (!expr.isLValue(scope)) {
          throw CompileTimeSydException('$expr is not valid l-value; attempted to do *=', scope);
        }
        return SetStatement(
          expr,
          MultiplyExpression(
            expr,
            value,
            line,
            col,
            tokens.file,
            scope,
          ),
          line,
          col,
          tokens.file,
        );
      } else if (tokens.currentChar == TokenType.remainderEquals) {
        if (!expr.staticType.isSubtypeOf(scope.environment.integerType)) {
          throw CompileTimeSydException('Attempted $expr (not an integer!) %= ... ${formatCursorPositionFromTokens(tokens)}', scope);
        }
        tokens.moveNext();
        Expression value = parseExpression(tokens, scope);
        if (!value.staticType.isSubtypeOf(scope.environment.integerType)) {
          throw CompileTimeSydException(
            'attempted $expr%=$value but $value was not an integer ${formatCursorPositionFromTokens(tokens)}',
            scope,
          );
        }
        tokens.expectChar(TokenType.endOfStatement);
        if (!expr.isLValue(scope)) {
          throw CompileTimeSydException('$expr is not valid l-value; attempted to do %=', scope);
        }
        return SetStatement(
          expr,
          RemainderExpression(
            expr,
            value,
            line,
            col,
            tokens.file,
            scope,
          ),
          line,
          col,
          tokens.file,
        );
      } else {
        throw CompileTimeSydException('unexpected token <${tokens.current}> after <$expr>, ${formatCursorPositionFromTokens(tokens)}', scope);
      }
    } else {
      throw CompileTimeSydException('unexpected token <${tokens.current}> after <$expr>, ${formatCursorPositionFromTokens(tokens)}', scope);
    }
  }
  ValueType type = ValueType.create(tokens.currentIdent, line, col, tokens.file, scope.environment, scope.typeTable);
  tokens.moveNext();
  Identifier ident2 = tokens.currentIdent;
  tokens.moveNext();
  if (tokens.currentChar == TokenType.set) {
    tokens.expectChar(TokenType.set);
    Expression expr2 = parseExpression(tokens, scope);
    if (!expr2.staticType.isSubtypeOf(
      type,
    )) {
      throw CompileTimeSydException(
        '$expr2 is not of type $type, which is expected by ${ident2.name}. (it\'s a ${expr2.staticType}) ${formatCursorPositionFromTokens(tokens)}',
        scope,
      );
    }
    if (!static) {
      scope.newVar(
        ident2,
        type,
        line,
        col,
        tokens.file,
      );
    }
    tokens.expectChar(TokenType.endOfStatement);
    if (ignoreUnused) {
      scope.igv(ident2, true);
    }
    if (static) {
      return StaticFieldStatement(ident2, expr2, line, col, false);
    }
    return NewVarStatement(ident2, expr2, line, col, tokens.file, false, type, scope);
  }
  if (tokens.currentChar == TokenType.endOfStatement) {
    tokens.expectChar(TokenType.endOfStatement);
    scope.newVar(
      ident2,
      type,
      line,
      col,
      tokens.file,
    );
    if (ignoreUnused) {
      scope.igv(ident2, true);
    }
    if (static) {
      throw CompileTimeSydException('static declarations must have values ${formatCursorPositionFromTokens(tokens)}', scope);
    }
    return NewVarStatement(ident2, null, line, col, tokens.file, false, type, scope);
  }
  if (!static) {
    if ((!scope.inClass && !scope.inStaticClass) || scope.igv(ident2, false, -3, 0, '', true, false, false) == null) {
      if (overriden) {
        throw CompileTimeSydException('${ident2.name} incorrectly defined as override ${formatCursorPositionFromTokens(tokens)}', scope);
      }
    } else if (!overriden && ident2 != constructorVariable) {
      throw CompileTimeSydException(
          '${ident2.name} should be defined as override (write //#override before the function declaration) ${formatCursorPositionFromTokens(tokens)}', scope);
    }
  }
  bool isVararg = false;
  bool isNormal = false;
  Set<Identifier> debugParams = {};
  Iterable<Parameter> params = parseArgList(tokens, (TokenIterator tokens) {
    Identifier type = tokens.currentIdent;
    tokens.moveNext();
    if (tokens.current is CharToken && tokens.currentChar == TokenType.ellipsis) {
      tokens.moveNext();
      if (isVararg) {
        throw CompileTimeSydException('${ident2.name} had 2 varargs ${formatCursorPositionFromTokens(tokens)}', scope);
      }
      if (isNormal) {
        throw CompileTimeSydException('${ident2.name} had regular arguments before a vararg ${formatCursorPositionFromTokens(tokens)}', scope);
      }
      isVararg = true;
    } else {
      isNormal = true;
    }
    Identifier name = tokens.currentIdent;
    if (debugParams.contains(name)) {
      throw CompileTimeSydException('${ident2.name} had duplicate parameter ${name.name} ${formatCursorPositionFromTokens(tokens)}', scope);
    }
    debugParams.add(name);
    tokens.moveNext();
    return Parameter(
        ValueType.create(
          type,
          line,
          col,
          tokens.file,
          scope.environment,
          scope.typeTable,
        ),
        name);
  });
  if (isVararg && params.length > 1) {
    throw CompileTimeSydException('${ident2.name} had ${params.length - 1} regular arguments and a vararg ${formatCursorPositionFromTokens(tokens)}', scope);
  }
  if (isVararg) {
    params = InfiniteIterable(params.single);
  }
  tokens.expectChar(TokenType.openBrace);
  Iterable<ValueType> typeParams = isVararg ? InfiniteIterable(params.first.type) : params.map((e) => e.type);
  ValueType functionType = FunctionValueType(type, typeParams, tokens.file, scope.environment, scope.typeTable);
  if (!static) {
    scope.newVar(
      ident2,
      functionType,
      line,
      col,
      tokens.file,
      true,
      false,
      true,
    );
  }
  TypeValidator tv = TypeValidator([scope], ConcatenateLazyString(NotLazyString('function '), IdentifierLazyString(ident2)), false, false, static, scope.rtl,
      scope.identifiers, scope.environment, false, false, true);
  for (Parameter param in isVararg ? [params.first] : params) {
    tv.newVar(param.name, isVararg ? ArrayValueType(param.type, tokens.file, tv.environment, tv.typeTable) : param.type, line, col, tokens.file, true);
  }
  tv.returnType = type;
  List<Statement> body = parseBlock(tokens, tv);
  List<String> unusedFuncVars = tv.types.keys
      .where((element) => !tv.usedVars.contains(element) && element != ident2 && !params.any((e) => element == e.name))
      .map((e) => e.name)
      .toList();
  if (!unusedFuncVars.isEmpty) {
    throw CompileTimeSydException('Unused vars for ${tv.debugName}:\n  ${unusedFuncVars.join('\n  ')}', tv);
  }
  tokens.expectChar(TokenType.closeBrace);
  if (ignoreUnused) {
    scope.igv(ident2, true);
  }
  scope.nonconst.remove(ident2);
  return FunctionStatement(type, ident2, params, body, line, col, tokens.file, static, functionType, scope);
}

MapEntry<List<Statement>, TypeValidator> parse(Iterable<Token> rtokens, String file, MapEntry<List<Statement>, TypeValidator>? rtl, bool isMain,
    Map<String, Identifier> identifiers, Environment environment) {
  TokenIterator tokens = TokenIterator(rtokens.iterator, file, identifiers, environment);

  tokens.moveNext();
  TypeValidator intrinsics = TypeValidator([], NotLazyString('intrinsics'), false, false, false, rtl, identifiers, environment, true, false, false, environment.rootTypeTable);
  environment.intrinsics.forEach((String name, Object? value) {
    intrinsics.newVar(
      environment.identifiers[name] ??= Identifier(name),
      getType(value, NoDataVG(environment), -1, -1, 'intrinsics', false),
      -1,
      -1,
      'intrinsics',
      true,
    );
  });
  TypeValidator validator = TypeValidator([if (rtl == null) intrinsics, if (rtl != null) rtl.value],
      ConcatenateLazyString(NotLazyString('file '), NotLazyString(file)), false, false, false, rtl, identifiers, environment, true, false, false, TypeTable([environment.rootTypeTable]));

  List<Statement> ast = parseBlock(tokens, validator, false);
  if (isMain) {
    List<Identifier> unusedGlobalscopeVars = validator.types.keys.where((element) => !validator.usedVars.contains(element)).toList();
    if (!unusedGlobalscopeVars.isEmpty) {
      throw CompileTimeSydException('Unused vars:\n  ${unusedGlobalscopeVars.map((e) => e.name).join('\n  ')}', validator);
    }
    for (TypeValidator classTv in validator.classes.values) {
      List<Identifier> unusedClassVars = classTv.types.keys
          .where((element) => !classTv.usedVars.contains(element) && !classTv.parents.any((element2) => element2.igv(element, false) != null))
          .toList();
      if (!unusedClassVars.isEmpty) {
        //throw CompileTimeSydException('Unused vars for ${classTv.debugName}:\n  ${unusedClassVars.map((e) => e.name).join('\n  ')}', classTv); TODO: fix unused vars for classes
      }
    }
  }
  return MapEntry(ast, validator);
}

WhileStatement parseWhile(TokenIterator tokens, TypeValidator scope) {
  tokens.moveNext();
  tokens.expectChar(TokenType.openParen);
  Expression value = parseExpression(tokens, scope);
  if (!value.staticType.isSubtypeOf(scope.environment.booleanType)) {
    throw CompileTimeSydException(
      'The while condition ($value, a ${value.staticType}) is not a Boolean       ${formatCursorPositionFromTokens(tokens)}',
      scope,
    );
  }
  tokens.expectChar(TokenType.closeParen);
  tokens.expectChar(TokenType.openBrace);
  TypeValidator tv = TypeValidator([scope], NotLazyString('while loop'), false, false, false, scope.rtl, scope.identifiers, scope.environment, false, true, false);
  List<Statement> body = parseBlock(tokens, tv);
  List<String> unusedWhileLoopVars = tv.types.keys.where((element) => !tv.usedVars.contains(element)).map((e) => e.name).toList();
  if (!unusedWhileLoopVars.isEmpty) {
    throw CompileTimeSydException('Unused vars for while loop: ${formatCursorPositionFromTokens(tokens)}\n  ${unusedWhileLoopVars.join('\n  ')}', tv);
  }
  tokens.expectChar(TokenType.closeBrace);
  return WhileStatement(
    value,
    body,
    tokens.current.line,
    tokens.current.col,
    tokens.file,
    'while',
    true,
  );
}

ImportStatement parseImport(TokenIterator tokens, TypeValidator scope) {
  if (tokens.doneImports) {
    throw CompileTimeSydException(
      'cannot have import statement after non-import ${formatCursorPositionFromTokens(tokens)}',
      scope,
    );
  }
  tokens.moveNext();
  String str = tokens.string;
  if (scope.environment.filesStartedLoading.contains(str)) {
    throw CompileTimeSydException(
      'Import loop detected at ${formatCursorPositionFromTokens(tokens)}',
      scope,
    );
  }
  scope.environment.filesStartedLoading.add(str);
  if (!File('${path.dirname(tokens.file)}/$str').existsSync()) {
    throw CompileTimeSydException('Attempted import of nonexistent file ${formatCursorPositionFromTokens(tokens)}', scope);
  }
  tokens.moveNext();
  tokens.expectChar(TokenType.endOfStatement);

  MapEntry<List<Statement>, TypeValidator> result = scope.environment.filesLoaded[str] ??
      (scope.environment.filesLoaded[str] = parse(
          lex(File('${path.dirname(tokens.file)}/$str').readAsStringSync(), '${path.dirname(tokens.file)}/$str', scope.environment),
          '${path.dirname(tokens.file)}/$str',
          scope.rtl,
          false,
          scope.identifiers,
          scope.environment));
  scope.environment.loadedGlobalScopes[str] = result.value;
  scope.environment.filesStartedLoading.remove(str);
  scope.parents.add(result.value);
  scope.typeTable.parents.add(result.value.typeTable);
  tokens.getPrevious();
  return ImportStatement(result.key, '${path.dirname(tokens.file)}/$str', tokens.current.line, tokens.current.col, (tokens..moveNext()).file, scope);
}

class ValueTypePlaceholder {
  final Identifier name;
  final int line;
  final int col;

  final String file;
  ValueTypePlaceholder(this.name, this.line, this.col, this.file);
  @override
  String toString() => 'VTP($name)';

  ValueType toVT(TypeValidator scope) {
    return ValueType.create(name, line, col, file, scope.environment, scope.typeTable);
  }
}

Statement parseStatement(TokenIterator tokens, TypeValidator scope) {
  bool commentFeature = false;
  bool overriden = false;
  bool ignoreUnused = false;
  if (tokens.current is! IdentToken) {
    if (tokens.current is CommentFeatureToken) {
      String feature = (tokens.current as CommentFeatureToken).feature;
      if (feature == 'override') {
        overriden = true;
      } else if (feature == 'ignore_unused') {
        ignoreUnused = true;
      }
      tokens.moveNext();
      commentFeature = true;
    } else {
      tokens.doneImports = true;
      return parseNonKeywordStatement(tokens, scope);
    }
  }
  if (tokens.current is CharToken && tokens.currentChar == TokenType.endOfFile) {
    throw CompileTimeSydException('comment feature at end of file ${tokens.file}', scope);
  }
  if (tokens.current is! IdentToken) {
    tokens.getPrevious();
    tokens.doneImports = true;
    return parseNonKeywordStatement(tokens, scope);
  }
  switch (tokens.currentIdent) {
    case fwdclassVariable:
      if (overriden) {
        throw CompileTimeSydException('Can\'t override classes ${formatCursorPositionFromTokens(tokens)}', scope);
      }
      tokens.moveNext();
      Identifier cln = tokens.currentIdent;
      tokens.moveNext();
      List<ValueTypePlaceholder>? parameters;
      parameters = parseArgList(tokens, (TokenIterator tokens) {
        ValueTypePlaceholder result = ValueTypePlaceholder(
          tokens.currentIdent,
          tokens.current.line,
          tokens.current.col,
          tokens.file,
        );
        tokens.moveNext();
        return result;
      });
      ClassValueType? spt;
      TypeValidator props;
      if (tokens.current is IdentToken && tokens.currentIdent == scope.identifiers['extends']) {
        spt = ValueType.create((tokens..moveNext()).currentIdent, tokens.current.line, tokens.current.col, tokens.file, scope.environment, scope.typeTable) as ClassValueType;
        props = TypeValidator([spt.properties], ConcatenateLazyString(NotLazyString('forward-declared subclass '), IdentifierLazyString(cln)), true, false,
            false, scope.rtl, scope.identifiers, scope.environment, false, false, false);
        tokens.moveNext();
      } else {
        props = TypeValidator([scope], ConcatenateLazyString(NotLazyString('forward-declared root class '), IdentifierLazyString(cln)), true, false, false,
            scope.rtl, scope.identifiers, scope.environment, false, false, false);
      }
      ClassValueType x = ClassValueType(cln, spt, props, tokens.file, true, scope.environment, scope.typeTable);
      FunctionValueType? constructorType;
      constructorType = FunctionValueType(scope.environment.nullType, parameters.map((e) => e.toVT(scope)), tokens.file, scope.environment, scope.typeTable);

      props.newVar(constructorVariable, constructorType, tokens.current.line, tokens.current.col, tokens.file, true, true, true);
      constructorType = constructorType.withReturnType(x, tokens.file);
      ClassOfValueType y = ClassOfValueType(
        x,
        TypeValidator([
          scope,
          if (spt != null)
            (ValueType.create(scope.identifiers[spt.name.name + 'Class'] ??= Identifier(spt.name.name + 'Class'), tokens.current.line, tokens.current.col,
                    tokens.file, scope.environment, scope.typeTable) as ClassOfValueType)
                .staticMembers,
        ], NotLazyString('static members'), false, true, false, scope.rtl, scope.identifiers, scope.environment, false, false, false),
        constructorType,
        tokens.file,
        scope.environment,
        scope.typeTable,
      );
      spt?.subtypes.add(x);
      scope.newVar(x.name, y, tokens.current.line, tokens.current.col, tokens.file, true);
      x.properties.newVar(thisVariable, x, tokens.current.line, tokens.current.col, tokens.file); // xxx maybe this should be constant?
      if (ignoreUnused) {
        scope.igv(cln, true);
      }
      tokens.expectChar(TokenType.endOfStatement);
      return ForwardClassStatement(cln, y, tokens.current.line, tokens.current.col);
    case fwdclassfieldVariable:
      ValueType type = ValueType.create((tokens..moveNext()).currentIdent, tokens.current.line, tokens.current.col, tokens.file, scope.environment, scope.typeTable);
      ValueType reciever = ValueType.create((tokens..moveNext()).currentIdent, tokens.current.line, tokens.current.col, tokens.file, scope.environment, scope.typeTable);
      if (reciever is! ClassValueType) {
        throw CompileTimeSydException('fwdclassfields should only be defined on classes ${formatCursorPositionFromTokens(tokens)}', scope);
      }
      if (!reciever.notFullyDeclared) {
        throw CompileTimeSydException(
            'fwdclassfields should only be defined on forward-declared classes, before the real class is created ${formatCursorPositionFromTokens(tokens)}',
            scope);
      }
      ClassValueType cl = reciever;
      tokens..moveNext();
      tokens.expectChar(TokenType.period);
      if (overriden) {
        throw CompileTimeSydException('fwdclassfields should never be defined as override ${formatCursorPositionFromTokens(tokens)}', scope);
      }
      if (cl.properties.types[tokens.currentIdent] != null) {
        throw CompileTimeSydException('fwdclassfields should only be defined once per class ${formatCursorPositionFromTokens(tokens)}', scope);
      }
      cl.properties.newVar(tokens.currentIdent, type, tokens.current.line, tokens.current.col, tokens.file, false, true, true);
      if (ignoreUnused) {
        cl.properties.igv(tokens.currentIdent, true);
      }
      tokens.moveNext();
      tokens.expectChar(TokenType.endOfStatement);
      return NopStatement();
    case fwdclassmethodVariable:
      ValueType returnType = ValueType.create((tokens..moveNext()).currentIdent, tokens.current.line, tokens.current.col, tokens.file, scope.environment, scope.typeTable);
      ValueType reciever = ValueType.create((tokens..moveNext()).currentIdent, tokens.current.line, tokens.current.col, tokens.file, scope.environment, scope.typeTable);
      if (reciever is! ClassValueType) {
        throw CompileTimeSydException('fwdclassmethods should only be defined on classes ${formatCursorPositionFromTokens(tokens)}', scope);
      }
      if (!reciever.notFullyDeclared) {
        throw CompileTimeSydException(
            'fwdclassmethods should only be defined on forward-declared classes, before the real class is created ${formatCursorPositionFromTokens(tokens)}',
            scope);
      }
      ClassValueType cl = reciever;
      tokens..moveNext();
      tokens.expectChar(TokenType.period);
      if (overriden) {
        throw CompileTimeSydException('fwdclassmethods should never be defined as override ${formatCursorPositionFromTokens(tokens)}', scope);
      }
      if (cl.properties.types[tokens.currentIdent] != null) {
        throw CompileTimeSydException('fwdclassmethods should only be defined once per class ${formatCursorPositionFromTokens(tokens)}', scope);
      }
      Identifier methodName = tokens.currentIdent;
      tokens.moveNext();
      List<ValueType> parameters = parseArgList(tokens, (tokens) {
        Identifier name = tokens.currentIdent;
        tokens.moveNext();
        return ValueType.create(name, tokens.current.line, tokens.current.col, tokens.file, scope.environment, scope.typeTable);
      });
      ValueType type = FunctionValueType(returnType, parameters, tokens.file, scope.environment, scope.typeTable);
      cl.properties.newVar(methodName, type, tokens.current.line, tokens.current.col, tokens.file, true, true, true);
      if (ignoreUnused) {
        cl.properties.igv(methodName, true);
      }
      tokens.expectChar(TokenType.endOfStatement);
      return NopStatement();
    case fwdstaticfieldVariable:
      ValueType type = ValueType.create((tokens..moveNext()).currentIdent, tokens.current.line, tokens.current.col, tokens.file, scope.environment, scope.typeTable);
      ClassOfValueType cl = (ValueType.create(
          scope.identifiers[(tokens..moveNext()).currentIdent.name + 'Class'] ??= Identifier((tokens..moveNext()).currentIdent.name + 'Class'),
          tokens.current.line,
          tokens.current.col,
          tokens.file,
          scope.environment, scope.typeTable) as ClassOfValueType);
      tokens..moveNext();
      tokens.expectChar(TokenType.period);
      if (overriden) {
        throw CompileTimeSydException('fwdstaticfields should never be defined as override ${formatCursorPositionFromTokens(tokens)}', scope);
      }
      cl.staticMembers.newVar(tokens.currentIdent, type, tokens.current.line, tokens.current.col, tokens.file);
      if (ignoreUnused) {
        cl.staticMembers.igv(tokens.currentIdent, true);
      }
      tokens.moveNext();
      tokens.expectChar(TokenType.endOfStatement);
      return NopStatement();
    case fwdstaticmethodVariable:
      ValueType returnType = ValueType.create((tokens..moveNext()).currentIdent, tokens.current.line, tokens.current.col, tokens.file, scope.environment, scope.typeTable);
      ClassValueType cl =
          (ValueType.create((tokens..moveNext()).currentIdent, tokens.current.line, tokens.current.col, tokens.file, scope.environment, scope.typeTable) as ClassValueType);
      tokens..moveNext();
      tokens.expectChar(TokenType.period);
      if (overriden) {
        throw CompileTimeSydException('fwdstaticmethods should never be defined as override ${formatCursorPositionFromTokens(tokens)}', scope);
      }
      Identifier methodName = tokens.currentIdent;
      tokens.moveNext();
      List<ValueType> parameters = parseArgList(tokens, (tokens) {
        Identifier name = tokens.currentIdent;
        tokens.moveNext();
        return ValueType.create(name, tokens.current.line, tokens.current.col, tokens.file, scope.environment, scope.typeTable);
      });
      ValueType type = FunctionValueType(returnType, parameters, tokens.file, scope.environment, scope.typeTable);
      cl.properties.newVar(methodName, type, tokens.current.line, tokens.current.col, tokens.file);
      if (ignoreUnused) {
        cl.properties.igv(methodName, true);
      }
      for (ClassValueType cvt in cl.allDescendants) {
        cvt.properties.newVar(methodName, type, tokens.current.line, tokens.current.col, tokens.file);
        if (ignoreUnused) {
          cvt.properties.igv(methodName, true);
        }
      }
      tokens.moveNext();
      tokens.expectChar(TokenType.endOfStatement);
      return NopStatement();
    case classVariable:
      if (overriden) {
        throw CompileTimeSydException('Can\'t override classes ${formatCursorPositionFromTokens(tokens)}', scope);
      }
      return parseClass(tokens, scope, ignoreUnused);

    case importVariable:
      if (overriden) {
        throw CompileTimeSydException('Overriding an import makes no sense, like, what does that mean ${formatCursorPositionFromTokens(tokens)}', scope);
      }
      if (ignoreUnused) {
        throw CompileTimeSydException('Instead of this, ignore_unused on all the unused components of the library ${formatCursorPositionFromTokens(tokens)}', scope);
      }
      return parseImport(tokens, scope);
    case whileVariable:
      tokens.doneImports = true;
      if (overriden) {
        throw CompileTimeSydException('Can\'t override whiles ${formatCursorPositionFromTokens(tokens)}', scope);
      }
      if (ignoreUnused) {
        throw CompileTimeSydException('What does that even mean for a while loop (look at this and previous line) ${formatCursorPositionFromTokens(tokens)}', scope);
      }
      return parseWhile(tokens, scope);
    case breakVariable:
      if (overriden) {
        throw CompileTimeSydException('Can\'t override breaks ${formatCursorPositionFromTokens(tokens)}', scope);
      }
      if (ignoreUnused) {
        throw CompileTimeSydException('What does that even mean for a break statement (look at this and previous line) ${formatCursorPositionFromTokens(tokens)}', scope);
      }
      tokens.doneImports = true;
      return BreakStatement.parse(tokens, scope);
    case continueVariable:
      tokens.doneImports = true;
      if (overriden) {
        throw CompileTimeSydException('Can\'t override continues ${formatCursorPositionFromTokens(tokens)}', scope);
      }
      if (ignoreUnused) {
        throw CompileTimeSydException('What does that even mean for a continue statement (look at this and previous line) ${formatCursorPositionFromTokens(tokens)}', scope);
      }
      return ContinueStatement.parse(tokens, scope);
    case returnVariable:
      tokens.doneImports = true;
      if (overriden) {
        throw CompileTimeSydException('Can\'t override returns ${formatCursorPositionFromTokens(tokens)}', scope);
      }
      if (ignoreUnused) {
        throw CompileTimeSydException('What does that even mean for a return statement (look at this and previous line) ${formatCursorPositionFromTokens(tokens)}', scope);
      }
      return ReturnStatement.parse(tokens, scope);
    case ifVariable:
      tokens.doneImports = true;
      if (overriden) {
        throw CompileTimeSydException('Can\'t override if statements ${formatCursorPositionFromTokens(tokens)}', scope);
      }
      if (ignoreUnused) {
        throw CompileTimeSydException('What does that even mean for a if statement (look at this and previous line) ${formatCursorPositionFromTokens(tokens)}', scope);
      }
      return parseIf(tokens, scope);
    case enumVariable:
      if (overriden) {
        throw CompileTimeSydException('Can\'t override enums ${formatCursorPositionFromTokens(tokens)}', scope);
      }
      if (ignoreUnused) {
        throw CompileTimeSydException('why do you not need every value of an enum ${formatCursorPositionFromTokens(tokens)}', scope);
      }
      tokens.doneImports = true;
      return parseEnum(tokens, scope);
    case forVariable:
      tokens.doneImports = true;
      if (overriden) {
        throw CompileTimeSydException('Can\'t override fors ${formatCursorPositionFromTokens(tokens)}', scope);
      }
      return parseForIn(tokens, scope, ignoreUnused);
    case constVariable:
      tokens.doneImports = true;

      if (overriden) {
        throw CompileTimeSydException('Can\'t override consts ${formatCursorPositionFromTokens(tokens)}', scope);
      }
      return parseConst(tokens, scope, ignoreUnused);
    default:
      if (commentFeature) {
        tokens.getPrevious();
      }
      tokens.doneImports = true;
      return parseNonKeywordStatement(tokens, scope);
  }
}

Statement parseConst(TokenIterator tokens, TypeValidator scope, bool ignoreUnused) {
  tokens.moveNext();
  bool static = false;
  Token start = tokens.current;
  if (tokens.current is IdentToken && tokens.currentIdent == scope.identifiers['static']) {
    tokens.moveNext();
    static = true;
  }
  ValueType type = ValueType.create(tokens.currentIdent, tokens.current.line, tokens.current.col, tokens.file, scope.environment, scope.typeTable);
  tokens.moveNext();
  Identifier name = tokens.currentIdent;
  tokens.moveNext();
  tokens.expectChar(TokenType.set);
  Expression expr = parseExpression(
    tokens,
    scope,
  );
  if (!expr.staticType.isSubtypeOf(type)) {
    throw CompileTimeSydException('attempted to assign $expr (a ${expr.staticType}) to $name, which is a const $type ${formatCursorPositionFromTokens(tokens)}', scope);
  }
  tokens.expectChar(TokenType.endOfStatement);
  if (!static) scope.newVar(name, type, tokens.current.line, tokens.current.col, tokens.file, true);
  if (ignoreUnused) {
    scope.igv(name, true);
  }
  if (static) {
    return StaticFieldStatement(name, expr, start.line, start.col, true);
  }
  return NewVarStatement(name, expr, start.line, start.col, tokens.file, true, type, scope);
}

Statement parseForIn(TokenIterator tokens, TypeValidator scope, bool ignoreUnused) {
  tokens.moveNext();
  tokens.expectChar(TokenType.openParen);
  Identifier currentName = tokens.currentIdent;
  tokens.moveNext();
  if (tokens.currentIdent != (scope.identifiers['in'] ??= Identifier('in'))) {
    throw CompileTimeSydException('no \'in\' after name of new variable in the for loop ${formatCursorPositionFromTokens(tokens)}', scope);
  }
  tokens.moveNext();
  Expression iterable = parseExpression(
    tokens,
    scope,
  );
  if (!iterable.staticType.isSubtypeOf(ValueType.create(
      scope.identifiers['WhateverIterable'] ??= Identifier('WhateverIterable'), tokens.current.line, tokens.current.col, tokens.file, scope.environment, scope.typeTable))) {
    throw CompileTimeSydException('tried to for loop over non-iterable (iterated over ${iterable.staticType}) ${formatCursorPositionFromTokens(tokens)}', scope);
  }
  TypeValidator innerScope = TypeValidator([scope], NotLazyString('for loop'), false, false, false, scope.rtl, scope.identifiers, scope.environment, false, true, false);
  innerScope.newVar(
    currentName,
    iterable.staticType is IterableValueType
        ? (iterable.staticType as IterableValueType).genericParameter
        : iterable.staticType is ListValueType
            ? (iterable.staticType as ListValueType).genericParameter
            : iterable.staticType is ArrayValueType
                ? (iterable.staticType as ArrayValueType).genericParameter
                : scope.environment.anythingType,
    tokens.current.line,
    tokens.current.col,
    tokens.file,
    true,
  );
  if (ignoreUnused) {
    innerScope.igv(currentName, true);
  }
  tokens.expectChar(TokenType.closeParen);
  tokens.expectChar(TokenType.openBrace);
  List<Statement> body = parseBlock(tokens, innerScope);
  List<String> unusedForLoopVars = innerScope.types.keys.where((element) => !innerScope.usedVars.contains(element)).toList().map((e) => e.name).toList();
  if (!unusedForLoopVars.isEmpty) {
    throw CompileTimeSydException('Unused vars for for loop: ${formatCursorPositionFromTokens(tokens)}\n  ${unusedForLoopVars.join('\n  ')}', innerScope);
  }
  tokens.expectChar(TokenType.closeBrace);
  return ForStatement(
    iterable,
    body,
    tokens.current.line,
    tokens.current.col,
    currentName,
    tokens.file,
    scope,
  );
}

Statement parseEnum(TokenIterator tokens, TypeValidator scope) {
  tokens.moveNext();
  Identifier name = tokens.currentIdent;
  tokens.moveNext();
  List<Identifier> body = [];
  TypeValidator tv = TypeValidator([scope], ConcatenateLazyString(IdentifierLazyString(name), NotLazyString('-enum')), false, false, false, scope.rtl,
      scope.identifiers, scope.environment, false, false, false);
      if (ValueType.hasTypeSuffix(name)) {
        throw CompileTimeSydException('Cannot declare enum type with reserved type name ${name.name} ${formatCursorPositionFromTokens(tokens)}', scope);
      }
  EnumPropertyValueType propType = EnumPropertyValueType(name, tokens.file, scope.environment, scope.typeTable);
  EnumValueType type = EnumValueType(name, tv, tokens.file, propType, scope.environment, scope.typeTable);
  tokens.expectChar(TokenType.openBrace);
  while (tokens.current is! CharToken || tokens.currentChar != TokenType.closeBrace) {
    tv.newVar(
      tokens.currentIdent,
      propType,
      tokens.current.line,
      tokens.current.col,
      tokens.file,
    );
    body.add(
      tokens.currentIdent,
    );
    tokens.moveNext();
  }
  tokens.moveNext();
  scope.newVar(
    name,
    type,
    tokens.current.line,
    tokens.current.col,
    tokens.file,
  );
  return EnumStatement(
    name,
    body,
    type,
    tokens.current.line,
    tokens.current.col,
    tokens.file,
    scope,
  );
}

IfStatement parseIf(TokenIterator tokens, TypeValidator scope) {
  tokens.moveNext();
  tokens.expectChar(TokenType.openParen);
  Expression value = parseExpression(tokens, scope);
  tokens.expectChar(TokenType.closeParen);
  if (!value.staticType.isSubtypeOf(scope.environment.booleanType)) {
    throw CompileTimeSydException(
      'The if condition ($value, a ${value.staticType}) is not a Boolean        ${formatCursorPositionFromTokens(tokens)}',
      scope,
    );
  }
  tokens.expectChar(TokenType.openBrace);
  TypeValidator innerScope = TypeValidator([scope], NotLazyString('if statement'), false, false, false, scope.rtl, scope.identifiers, scope.environment, false, false, false);
  List<Statement> body = parseBlock(tokens, innerScope);
  List<String> unusedForLoopVars = innerScope.types.keys.where((element) => !innerScope.usedVars.contains(element)).map((e) => e.name).toList();
  if (!unusedForLoopVars.isEmpty) {
    throw CompileTimeSydException('Unused vars for if statement: ${formatCursorPositionFromTokens(tokens)}\n  ${unusedForLoopVars.join('\n  ')}', innerScope);
  }
  List<Statement> elseBody = [];
  tokens.expectChar(TokenType.closeBrace);
  if (tokens.current is IdentToken && tokens.currentIdent == scope.identifiers['else']) {
    tokens.moveNext();
    if (tokens.current is IdentToken && tokens.currentIdent == scope.identifiers['if']) {
      TypeValidator elseBlock =
          TypeValidator([scope], NotLazyString('if statement - else block'), false, false, false, scope.rtl, scope.identifiers, scope.environment, false, false, false);
      IfStatement parsedIf = parseIf(tokens, elseBlock);
      elseBody = [parsedIf];
    } else {
      tokens.expectChar(TokenType.openBrace);
      TypeValidator elseBlock =
          TypeValidator([scope], NotLazyString('if statement - else block'), false, false, false, scope.rtl, scope.identifiers, scope.environment, false, false, false);
      elseBody = parseBlock(tokens, elseBlock);
      List<String> unusedForLoopVars = elseBlock.types.keys.where((element) => !elseBlock.usedVars.contains(element)).map((e) => e.name).toList();
      if (!unusedForLoopVars.isEmpty) {
        throw CompileTimeSydException('Unused vars for if statement (else block): ${formatCursorPositionFromTokens(tokens)}\n  ${unusedForLoopVars.join('\n  ')}', scope);
      }
      tokens.expectChar(TokenType.closeBrace);
    }
  }
  return IfStatement(
    value,
    body,
    elseBody,
    tokens.current.line,
    tokens.current.col,
    tokens.file,
  );
}
