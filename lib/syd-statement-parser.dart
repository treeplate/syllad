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
  Variable name = tokens.currentIdent;
  tokens.moveNext();
  Variable? superclass;
  if (tokens.current is IdentToken && tokens.currentIdent == scope.variables['extends']) {
    tokens.moveNext();
    superclass = tokens.currentIdent;
    scope.getVar(superclass, tokens.current.line, tokens.current.col, tokens.file, 'for subclassing', false);
    tokens.moveNext();
  }
  tokens.expectChar(TokenType.openBrace);
  ValueType? supertype = superclass == null
      ? null
      : ValueType.create(
          null,
          superclass,
          tokens.current.line,
          tokens.current.col,
          tokens.file,
          scope,
        );
  if (superclass != null && !scope.classes.containsKey(superclass)) {
    throw BSCException('${superclass.name} nonexistent while trying to have ${name.name} extend it. ${formatCursorPositionFromTokens(tokens)}', scope);
  }
  TypeValidator newScope = superclass == null
      ? TypeValidator([scope], ConcatenateLazyString(NotLazyString('root class '), VariableLazyString(name)), true, false, false, scope.rtl, scope.variables,
          scope.environment)
      : TypeValidator([scope.classes[superclass]!, scope], ConcatenateLazyString(NotLazyString('subclass '), VariableLazyString(name)), true, false, false,
          scope.rtl, scope.variables, scope.environment);
  ClassValueType type = ClassValueType(name, supertype as ClassValueType?, newScope, tokens.file, false, scope);
  if (newScope != type.properties) {
    if (supertype != type.supertype) {
      throw BSCException(
        '${name.name} does not have the same supertype ($supertype) as forward declaration (${type.supertype}) ${formatCursorPositionFromTokens(tokens)}',
        scope,
      );
    }
  }
  TypeValidator fwdProps = type.properties.copy();
  bool hasFwdDecl = newScope != type.properties;
  // newScope = type.properties..parents.addAll([scope]);
  newScope = ClassTypeValidator(fwdProps, newScope.parents, type.properties.debugName, true, false, false, scope.rtl, scope.variables, scope.environment);
  type.properties.types = newScope.types;
  newScope.usedVars = type.properties.usedVars;
  type.properties.parents.add(fwdProps);
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
  newScope.usedVars.add(thisVariable);
  newScope.usedVars.add(classNameVariable);
  newScope.usedVars.add(toStringVariable);
  List<Statement> block = parseBlock(tokens, newScope);
  ValueType? supertype1 = superclass != null ? scope.igv(scope.variables['${superclass.name}']!, true) : null;
  if (supertype1 is FunctionValueType) {
    throw BSCException('Cannot extend an class that has not been defined yet.', scope);
  }
  TypeValidator staticMembers = TypeValidator([if (superclass != null) (supertype1 as ClassOfValueType).staticMembers],
      ConcatenateLazyString(NotLazyString('static members of '), VariableLazyString(name)), false, true, false, scope.rtl, scope.variables, scope.environment);
  for (Statement statement in block) {
    if (statement is StaticFieldStatement) {
      if (!statement.val.staticType.isSubtypeOf(
          staticMembers.igv(statement.name, false, tokens.current.line, tokens.current.col, tokens.file, true, false) ??
              scope.environment.anythingType)) {
        throw BSCException(
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
          staticMembers.igv(statement.name, false, tokens.current.line, tokens.current.col, tokens.file, true, false) ??
              scope.environment.anythingType)) {
        throw BSCException(
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
  if (!(newScope.igv(constructorVariable, true)?.isSubtypeOf(GenericFunctionValueType(scope.environment.nullType, tokens.file, scope)) ?? true)) {
    throw BSCException('Bad constructor type: ${newScope.igv(constructorVariable, true)} ${formatCursorPositionFromTokens(tokens)}', scope);
  }
  if (!hasFwdDecl) {
    if (supertype != null) {
      for (MapEntry<Variable, TVProp> property in newScope.types.entries) {
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
          throw BSCException(
            '${name.name} type has invalid override of ${superclass!.name}.${property.key.name} (expected ${supertype.properties.igv(property.key, false)}, got ${property.value.type} ${formatCursorPositionFromTokens(tokens)}',
            scope,
          );
        }
      }
    }
  }
  if (hasFwdDecl) {
    for (MapEntry<Variable, TVProp> value in fwdProps.types.entries) {
      if (value.key == constructorVariable) {
        if ((newScope.igv(value.key, false, -2, 0, '',true, false, false) ?? FunctionValueType(scope.environment.nullType, [], 'xxx', scope)) !=
            value.value.type) {
          throw BSCException(
              '${name.name}\'s constructor (${newScope.igv(value.key, false, -2, 0, '', true, false, false) ?? FunctionValueType(scope.environment.nullType, [], 'xxx', scope)}) does not match forward declaration (${value.value.type}) ${formatCursorPositionFromTokens(tokens)}',
              scope);
        }
      } else {
        ValueType? newType = newScope.igv(value.key, false, -2, 0, '',true, false, false);
        if (newType != value.value.type) {
          throw BSCException(
              '${name.name}.${value.key.name} (a ${newScope.igv(value.key, false)}) does not match forward declaration (a ${value.value.type}) ${formatCursorPositionFromTokens(tokens)}',
              scope);
        } else if (newType is FunctionValueType && value.value.type is! FunctionValueType) {
          // this will break when we get function types with arguments specifiable by fields
          throw BSCException(
              '${name.name}.${value.key.name} was forward-declared with a fwdclassfield but is a method ${formatCursorPositionFromTokens(tokens)}', scope);
        } else if (newType is! FunctionValueType && value.value.type is FunctionValueType) {
          // this will break when we get function types with arguments specifiable by fields
          throw BSCException(
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
      ? FunctionValueType(type, (type.recursiveLookup(constructorVariable)?.key as FunctionValueType?)?.parameters ?? [], tokens.file, scope)
      : GenericFunctionValueType(type, tokens.file, scope));
  ClassOfValueType classOfType = ClassOfValueType(
    type,
    staticMembers,
    constructorType,
    tokens.file,
    scope,
  );
  scope.newVar(
    name,
    classOfType,
    tokens.current.line,
    tokens.current.col,
    tokens.file,
  );
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
        scope.environment.stderr.writeln('Duplicate override comment feature ${formatCursorPositionFromTokens(tokens)}');
      }
      overriden = true;
      tokens.moveNext();
    } else if (feature == 'ignore_unused') {
      if (ignoreUnused) {
        scope.environment.stderr.writeln('Duplicate ignore_unused comment feature ${formatCursorPositionFromTokens(tokens)}');
      }
      ignoreUnused = true;
      tokens.moveNext();
    }
  }
  int line = tokens.current.line;
  int col = tokens.current.col;
  bool static = false;
  if (tokens.current is IdentToken && tokens.currentIdent == scope.variables['static']) {
    static = true;
    tokens.moveNext();
  }
  Expression expr;
  if (tokens.current is IdentToken && scope.igv(tokens.currentIdent, false) != null && !scope.usedVars.contains(tokens.currentIdent)) {
    expr = parseExpression(tokens, scope);
    scope.usedVars.remove(expr is GetExpr ? expr.name : null);
  } else {
    expr = parseExpression(tokens, scope);
  }
  if (expr is SubscriptExpression && expr.a.staticType is ArrayValueType && tokens.currentChar != TokenType.endOfStatement) {
    throw BSCException('Tried to modify array ${formatCursorPositionFromTokens(tokens)}', scope);
  }
  if (tokens.current is CharToken && tokens.currentChar == TokenType.endOfStatement) {
    if (overriden || ignoreUnused)
      scope.environment.stderr.writeln('Comment features are currently pointless for expression statements ${formatCursorPositionFromTokens(tokens)}');
    if (static) {
      throw BSCException('static expression statements make no sense ${formatCursorPositionFromTokens(tokens)}', scope);
    }
    if (expr is GetExpr) {
      scope.usedVars.add(expr.name);
    }
    tokens.expectChar(TokenType.endOfStatement);
    return ExpressionStatement(expr, line, col);
  }
  if (tokens.current is CharToken) {
    if (overriden || ignoreUnused)
      scope.environment.stderr.writeln('Comment features are currently pointless for x++, x+=y, x--, x-=y, x=y, etc ${formatCursorPositionFromTokens(tokens)}');
    if (static) {
      throw BSCException('static x++, x+=y, x--, x-=y, x=y, etc make no sense ${formatCursorPositionFromTokens(tokens)}', scope);
    }
    if (tokens.currentChar == TokenType.set) {
      tokens.moveNext();
      Expression value = parseExpression(tokens, scope);
      if (!expr.isLValue(scope)) {
        throw BSCException('$expr is not an lvalue for = ${formatCursorPositionFromTokens(tokens)}', scope);
      }
      if (!value.staticType.isSubtypeOf(expr.staticType)) {
        throw BSCException('attempted $expr=$value but $value was not a ${expr.staticType} ${formatCursorPositionFromTokens(tokens)}', scope);
      }
      tokens.expectChar(TokenType.endOfStatement);
      return SetStatement(expr, value, line, col, tokens.file);
    }
    if (tokens.currentChar == TokenType.plusEquals) {
      if (!expr.staticType.isSubtypeOf(scope.environment.integerType)) {
        throw BSCException('Attempted $expr (not an integer!) += ... ${formatCursorPositionFromTokens(tokens)}', scope);
      }
      tokens.moveNext();
      Expression value = parseExpression(tokens, scope);
      if (!value.staticType.isSubtypeOf(scope.environment.integerType)) {
        throw BSCException(
          'attempted $expr+=$value but $value was not an integer ${formatCursorPositionFromTokens(tokens)}',
          scope,
        );
      }
      tokens.expectChar(TokenType.endOfStatement);
      if (!expr.isLValue(scope)) {
        throw BSCException('$expr is not an lvalue for += ${formatCursorPositionFromTokens(tokens)}', scope);
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
        throw BSCException('Attempted $expr (not an integer!) ++ ... ${formatCursorPositionFromTokens(tokens)}', scope);
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
        throw BSCException('Attempted $expr (not an integer!) -= ... ${formatCursorPositionFromTokens(tokens)}', scope);
      }
      tokens.moveNext();
      Expression value = parseExpression(tokens, scope);
      if (!value.staticType.isSubtypeOf(scope.environment.integerType)) {
        throw BSCException(
          'attempted $expr-=$value but $value was not an integer ${formatCursorPositionFromTokens(tokens)}',
          scope,
        );
      }
      tokens.expectChar(TokenType.endOfStatement);
      if (!expr.isLValue(scope)) {
        throw BSCException('$expr is not valid l-value; attempted to do -=', scope);
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
        throw BSCException('Attempted $expr (not an integer!) -- ... ${formatCursorPositionFromTokens(tokens)}', scope);
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
        throw BSCException('Attempted $expr (not an integer!) |= ... ${formatCursorPositionFromTokens(tokens)}', scope);
      }
      tokens.moveNext();
      Expression value = parseExpression(tokens, scope);
      if (!value.staticType.isSubtypeOf(scope.environment.integerType)) {
        throw BSCException(
          'attempted $expr|=$value but $value was not an integer ${formatCursorPositionFromTokens(tokens)}',
          scope,
        );
      }
      tokens.expectChar(TokenType.endOfStatement);
      if (!expr.isLValue(scope)) {
        throw BSCException('$expr is not valid l-value; attempted to do |=', scope);
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
        throw BSCException('Attempted $expr (not an integer!) &= ... ${formatCursorPositionFromTokens(tokens)}', scope);
      }
      tokens.moveNext();
      Expression value = parseExpression(tokens, scope);
      if (!value.staticType.isSubtypeOf(scope.environment.integerType)) {
        throw BSCException(
          'attempted $expr&=$value but $value was not an integer ${formatCursorPositionFromTokens(tokens)}',
          scope,
        );
      }
      tokens.expectChar(TokenType.endOfStatement);
      if (!expr.isLValue(scope)) {
        throw BSCException('$expr is not valid l-value; attempted to do &=', scope);
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
        throw BSCException('Attempted $expr (not an integer!) ^= ... ${formatCursorPositionFromTokens(tokens)}', scope);
      }
      tokens.moveNext();
      Expression value = parseExpression(tokens, scope);
      if (!value.staticType.isSubtypeOf(scope.environment.integerType)) {
        throw BSCException(
          'attempted $expr^=$value but $value was not an integer ${formatCursorPositionFromTokens(tokens)}',
          scope,
        );
      }
      tokens.expectChar(TokenType.endOfStatement);
      if (!expr.isLValue(scope)) {
        throw BSCException('$expr is not valid l-value; attempted to do ^=', scope);
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
        throw BSCException('Attempted $expr (not an boolean!) &&= ... ${formatCursorPositionFromTokens(tokens)}', scope);
      }
      tokens.moveNext();
      Expression value = parseExpression(tokens, scope);
      if (!value.staticType.isSubtypeOf(scope.environment.booleanType)) {
        throw BSCException(
          'attempted $expr&&=$value but $value was not an boolean ${formatCursorPositionFromTokens(tokens)}',
          scope,
        );
      }
      tokens.expectChar(TokenType.endOfStatement);
      if (!expr.isLValue(scope)) {
        throw BSCException('$expr is not valid l-value; attempted to do &&=', scope);
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
        throw BSCException('Attempted $expr (not an boolean!) ||= ... ${formatCursorPositionFromTokens(tokens)}', scope);
      }
      tokens.moveNext();
      Expression value = parseExpression(tokens, scope);
      if (!value.staticType.isSubtypeOf(scope.environment.booleanType)) {
        throw BSCException(
          'attempted $expr||=$value but $value was not an boolean ${formatCursorPositionFromTokens(tokens)}',
          scope,
        );
      }
      tokens.expectChar(TokenType.endOfStatement);
      if (!expr.isLValue(scope)) {
        throw BSCException('$expr is not valid l-value; attempted to do ||=', scope);
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
        throw BSCException('Attempted $expr (not an integer!) /= ... ${formatCursorPositionFromTokens(tokens)}', scope);
      }
      tokens.moveNext();
      Expression value = parseExpression(tokens, scope);
      if (!value.staticType.isSubtypeOf(scope.environment.integerType)) {
        throw BSCException(
          'attempted $expr/=$value but $value was not an integer ${formatCursorPositionFromTokens(tokens)}',
          scope,
        );
      }
      tokens.expectChar(TokenType.endOfStatement);
      if (!expr.isLValue(scope)) {
        throw BSCException('$expr is not valid l-value; attempted to do /=', scope);
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
        throw BSCException('Attempted $expr (not an integer!) *= ... ${formatCursorPositionFromTokens(tokens)}', scope);
      }
      tokens.moveNext();
      Expression value = parseExpression(tokens, scope);
      if (!value.staticType.isSubtypeOf(scope.environment.integerType)) {
        throw BSCException(
          'attempted $expr*=$value but $value was not an integer ${formatCursorPositionFromTokens(tokens)}',
          scope,
        );
      }
      tokens.expectChar(TokenType.endOfStatement);
      if (!expr.isLValue(scope)) {
        throw BSCException('$expr is not valid l-value; attempted to do *=', scope);
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
        throw BSCException('Attempted $expr (not an integer!) %= ... ${formatCursorPositionFromTokens(tokens)}', scope);
      }
      tokens.moveNext();
      Expression value = parseExpression(tokens, scope);
      if (!value.staticType.isSubtypeOf(scope.environment.integerType)) {
        throw BSCException(
          'attempted $expr%=$value but $value was not an integer ${formatCursorPositionFromTokens(tokens)}',
          scope,
        );
      }
      tokens.expectChar(TokenType.endOfStatement);
      if (!expr.isLValue(scope)) {
        throw BSCException('$expr is not valid l-value; attempted to do %=', scope);
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
    }
  }
  Variable ident2 = tokens.currentIdent;
  tokens.moveNext();
  if (tokens.currentChar == TokenType.set) {
    tokens.expectChar(TokenType.set);
    Expression expr2 = parseExpression(tokens, scope);
    if (!expr2.staticType.isSubtypeOf(
      expr.asType,
    )) {
      throw BSCException(
        '$expr2 is not of type $expr, which is expected by ${ident2.name}. (it\'s a ${expr2.staticType}) ${formatCursorPositionFromTokens(tokens)}',
        scope,
      );
    }
    if (!static) {
      scope.newVar(
        ident2,
        expr.asType,
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
    return NewVarStatement(ident2, expr2, line, col, tokens.file, false, expr.asType, scope);
  }
  if (tokens.currentChar == TokenType.endOfStatement) {
    tokens.expectChar(TokenType.endOfStatement);
    scope.newVar(
      ident2,
      expr.asType,
      line,
      col,
      tokens.file,
    );
    if (ignoreUnused) {
      scope.igv(ident2, true);
    }
    if (static) {
      throw BSCException('static declarations must have values ${formatCursorPositionFromTokens(tokens)}', scope);
    }
    return NewVarStatement(ident2, null, line, col, tokens.file, false, expr.asType, scope);
  }
  if (!static) {
    if ((!scope.isClass && !scope.isClassOf) || scope.igv(ident2, false, -3, 0, '', true, false, false) == null) {
      if (overriden) {
        throw BSCException('${ident2.name} incorrectly defined as override ${formatCursorPositionFromTokens(tokens)}', scope);
      }
    } else if (!overriden && ident2 != constructorVariable) {
      throw BSCException(
          '${ident2.name} should be defined as override (write //#override before the function declaration) ${formatCursorPositionFromTokens(tokens)}', scope);
    }
  }
  bool isVararg = false;
  bool isNormal = false;
  Set<Variable> debugParams = {};
  Iterable<Parameter> params = parseArgList(tokens, (TokenIterator tokens) {
    Variable type = tokens.currentIdent;
    tokens.moveNext();
    if (tokens.current is CharToken && tokens.currentChar == TokenType.ellipsis) {
      tokens.moveNext();
      if (isVararg) {
        throw BSCException('${ident2.name} had 2 varargs ${formatCursorPositionFromTokens(tokens)}', scope);
      }
      if (isNormal) {
        throw BSCException('${ident2.name} had regular arguments before a vararg ${formatCursorPositionFromTokens(tokens)}', scope);
      }
      isVararg = true;
    } else {
      isNormal = true;
    }
    Variable name = tokens.currentIdent;
    if (debugParams.contains(name)) {
      throw BSCException('${ident2.name} had duplicate parameter ${name.name} ${formatCursorPositionFromTokens(tokens)}', scope);
    }
    debugParams.add(name);
    tokens.moveNext();
    return Parameter(
        ValueType.create(
          null,
          type,
          line,
          col,
          tokens.file,
          scope,
        ),
        name);
  });
  if (isVararg && params.length > 1) {
    throw BSCException('${ident2.name} had ${params.length - 1} regular arguments and a vararg ${formatCursorPositionFromTokens(tokens)}', scope);
  }
  if (isVararg) {
    params = InfiniteIterable(params.single);
  }
  tokens.expectChar(TokenType.openBrace);
  Iterable<ValueType> typeParams = isVararg ? InfiniteIterable(params.first.type) : params.map((e) => e.type);
  TypeValidator tv = TypeValidator([scope], ConcatenateLazyString(NotLazyString('function '), VariableLazyString(ident2)), false, false, static, scope.rtl,
      scope.variables, scope.environment)
    ..types.addAll(isVararg
        ? {params.first.name: TVProp(false, ListValueType(params.first.type, 'internal', scope), false)}
        : Map.fromEntries(params.map((e) => MapEntry(e.name, TVProp(false, e.type, false)))))
    ..directVars.addAll([if (isVararg) params.first.name, if (!isVararg) ...params.map((e) => e.name)])
    ..newVar(
      ident2,
      FunctionValueType(
        expr.asType,
        typeParams,
        tokens.file,
        scope,
      ),
      line,
      col,
      tokens.file,
    );
  tv.returnType = expr.asType;
  List<Statement> body = parseBlock(tokens, tv);
  List<String> unusedFuncVars = tv.types.keys
      .where((element) => !tv.usedVars.contains(element) && element != ident2 && !params.any((e) => element == e.name))
      .map((e) => e.name)
      .toList();
  if (!unusedFuncVars.isEmpty) {
    scope.environment.stderr.writeln('Unused vars for ${tv.debugName}:\n  ${unusedFuncVars.join('\n  ')}');
  }
  tokens.expectChar(TokenType.closeBrace);
  ValueType type = FunctionValueType(expr.asType, typeParams, tokens.file, scope);
  if (!static) {
    scope.newVar(
      ident2,
      type,
      line,
      col,
      tokens.file,
      true,
      false,
      true,
    );
  }
  if (ignoreUnused) {
    scope.igv(ident2, true);
  }
  scope.nonconst.remove(ident2);
  return FunctionStatement(expr.asType, ident2, params, body, line, col, tokens.file, static, type, scope);
}

MapEntry<List<Statement>, TypeValidator> parse(Iterable<Token> rtokens, String file, MapEntry<List<Statement>, TypeValidator>? rtl,
    bool isMain, Map<String, Variable> variables, Environment environment) {
  TokenIterator tokens = TokenIterator(rtokens.iterator, file, variables, environment);

  tokens.moveNext();
  TypeValidator intrinsics = TypeValidator([], NotLazyString('intrinsics'), false, false, false, rtl, variables, environment);
  if (rtl == null) {
    try {
      environment.anythingType;
    } catch (e) {
      environment.anythingType = ValueType.internal(null, variables['Anything']!, 'intrinsics', false, intrinsics, environment);
      environment.integerType = ValueType.internal(environment.anythingType, variables['Integer']!, 'intrinsics', false, intrinsics, environment);
      environment.stringType = ValueType.internal(environment.anythingType, variables['String']!, 'intrinsics', false, intrinsics, environment);
      environment.booleanType = ValueType.internal(environment.anythingType, variables['Boolean']!, 'intrinsics', false, intrinsics, environment);
      environment.nullType = NullType.internal(environment.anythingType, intrinsics);
      environment.rootClassType = ValueType.internal(environment.anythingType, variables['~root_class']!, 'intrinsics', false, intrinsics, environment);
      environment.stringBufferType = ValueType.internal(environment.anythingType, variables['StringBuffer']!, 'intrinsics', false, intrinsics, environment);
      environment.fileType = ValueType.internal(environment.anythingType, variables['File']!, 'intrinsics', false, intrinsics, environment);
      environment.sentinelType = ValueType.internal(environment.anythingType, variables['~sentinel']!, 'intrinsics', false, intrinsics, environment);
    }
  }
  intrinsics.types = <String, ValueType>{
    'true': environment.booleanType,
    'false': environment.booleanType,
    'null': environment.nullType,
    'args': ListValueType<String>(environment.stringType, 'intrinsics', intrinsics),
    'print': FunctionValueType(environment.integerType, InfiniteIterable(environment.anythingType), 'intrinsics', intrinsics),
    'stderr': FunctionValueType(environment.integerType, InfiniteIterable(environment.anythingType), 'intrinsics', intrinsics),
    'concat': FunctionValueType(environment.stringType, InfiniteIterable(environment.anythingType), 'intrinsics', intrinsics),
    'parseInt': FunctionValueType(environment.integerType, [environment.stringType], 'intrinsics', intrinsics),
    'addLists': FunctionValueType(
        ListValueType(environment.anythingType, 'intrinsics', intrinsics),
        InfiniteIterable(
            ArrayValueType(ValueType.create(null, whateverVariable, -2, 0,  'intrinsics', intrinsics), 'intrinsics', intrinsics)),
        'intrinsics',
        intrinsics),
    'charsOf': FunctionValueType(IterableValueType<String>(environment.stringType, 'intrinsics', intrinsics), [environment.stringType], 'intrinsics', intrinsics),
    'scalarValues': FunctionValueType(IterableValueType<int>(environment.integerType, 'intrinsics', intrinsics), [environment.stringType], 'intrinsics', intrinsics),
    'split': FunctionValueType(ListValueType(environment.stringType, 'intrinsics', intrinsics), [environment.stringType, environment.stringType], 'intrinsics', intrinsics),
    'len': FunctionValueType(
        environment.integerType,
        [IterableValueType<Object?>(ValueType.create(null, whateverVariable, -2, 0, 'intrinsics', intrinsics), 'intrinsics', intrinsics)],
        'intrinsics',
        intrinsics),
    'input': FunctionValueType(environment.stringType, [], 'intrinsics', intrinsics),
    'append': FunctionValueType(
        environment.anythingType,
        [
          ListValueType(ValueType.create(null, whateverVariable, -2, 0, 'intrinsics', intrinsics), 'intrinsics', intrinsics),
          environment.anythingType
        ],
        'intrinsics',
        intrinsics),
    'iterator': FunctionValueType(
        IteratorValueType(environment.anythingType, 'intrinsics', intrinsics),
        [IterableValueType<Object?>(ValueType.create(null, whateverVariable, -2, 0, 'intrinsics', intrinsics), 'intrinsics', intrinsics)],
        'intrinsics',
        intrinsics),
    'next': FunctionValueType(environment.booleanType, [IteratorValueType(environment.anythingType, 'intrinsics', intrinsics)], 'intrinsics', intrinsics),
    'current': FunctionValueType(environment.anythingType, [IteratorValueType(environment.anythingType, 'intrinsics', intrinsics)], 'intrinsics', intrinsics),
    'stringTimes': FunctionValueType(environment.stringType, [environment.stringType, environment.integerType], 'intrinsics', intrinsics),
    'copy': FunctionValueType(
        ListValueType(ValueType.create(null, whateverVariable, -2, 0, 'intrinsics', intrinsics), 'intrinsics', intrinsics),
        [IterableValueType<Object?>(ValueType.create(null, whateverVariable, -2, 0, 'intrinsics', intrinsics), 'intrinsics', intrinsics)],
        'intrinsics',
        intrinsics),
    'hex': FunctionValueType(environment.stringType, [environment.integerType], 'intrinsics', intrinsics),
    'chr': FunctionValueType(environment.stringType, [environment.integerType], 'intrinsics', intrinsics),
    'exit': FunctionValueType(environment.nullType, [environment.integerType], 'intrinsics', intrinsics),
    'fileExists': FunctionValueType(environment.booleanType, [environment.stringType], 'intrinsics', intrinsics),
    'openFile': FunctionValueType(environment.fileType, [environment.stringType, environment.integerType], 'intrinsics', intrinsics),
    'fileModeAppend': environment.integerType,
    'fileModeRead': environment.integerType,
    'fileModeWrite': environment.integerType,
    'readFileBytes': FunctionValueType(ListValueType(environment.integerType, 'intrinsics', intrinsics), [environment.fileType], 'intrinsics', intrinsics),
    'writeFile': FunctionValueType(environment.nullType, [environment.fileType, environment.stringType], 'intrinsics', intrinsics),
    'closeFile': FunctionValueType(environment.nullType, [environment.fileType], 'intrinsics', intrinsics),
    'deleteFile': FunctionValueType(environment.nullType, [environment.stringType], 'intrinsics', intrinsics),
    'utf8Decode': FunctionValueType(environment.stringType, [ListValueType(environment.integerType, 'intrinsics', intrinsics)], 'intrinsics', intrinsics),
    'containsString': FunctionValueType(environment.booleanType, [environment.stringType, environment.stringType], 'intrinsics', intrinsics),
    'println': FunctionValueType(environment.integerType, InfiniteIterable(environment.anythingType), 'intrinsics', intrinsics),
    'clear': FunctionValueType(
        environment.integerType,
        [ListValueType(ValueType.create(null, whateverVariable, -2, 0, 'intrinsics', intrinsics), 'intrinsics', intrinsics)],
        'intrinsics',
        intrinsics),
    'debug': FunctionValueType(environment.stringType, [environment.rootClassType], 'intrinsics', intrinsics),
    'throw': FunctionValueType(environment.nullType, [environment.stringType], 'intrinsics', intrinsics),
    'pop': FunctionValueType(
        environment.anythingType,
        [ListValueType(ValueType.create(null, whateverVariable, -2, 0, 'intrinsics', intrinsics), 'intrinsics', intrinsics)],
        'intrinsics',
        intrinsics),
    'substring': FunctionValueType(environment.stringType, [environment.stringType, environment.integerType, environment.integerType], 'intrinsics', intrinsics),
    'sublist': FunctionValueType(
        ListValueType(ValueType.create(null, whateverVariable, -2, 0, 'intrinsics', intrinsics), 'intrinsics', intrinsics),
        [
          ArrayValueType(ValueType.create(null, whateverVariable, -2, 0, 'intrinsics', intrinsics), 'intrinsics', intrinsics),
          environment.integerType,
          environment.integerType
        ],
        'intrinsics',
        intrinsics),
    'filledList': FunctionValueType(
        ListValueType(ValueType.create(null, whateverVariable, -2, 0, 'intrinsics', intrinsics), 'intrinsics', intrinsics),
        [environment.integerType, environment.anythingType],
        'intrinsics',
        intrinsics),
    'sizedList': FunctionValueType(ListValueType(ValueType.create(null, whateverVariable, -2, 0, 'intrinsics', intrinsics), 'intrinsics', intrinsics),
        [environment.integerType], 'intrinsics', intrinsics),
    'stackTrace': FunctionValueType(environment.stringType, [], 'intrinsics', intrinsics),
    'debugName': FunctionValueType(environment.stringType, [environment.rootClassType], 'intrinsics', intrinsics),
    'createStringBuffer': FunctionValueType(environment.stringBufferType, [], 'intrinsics', intrinsics),
    'writeStringBuffer': FunctionValueType(environment.nullType, [environment.stringBufferType, environment.stringType], 'intrinsics', intrinsics),
    'readStringBuffer': FunctionValueType(environment.stringType, [environment.stringBufferType], 'intrinsics', intrinsics),
  }.map(
    (key, value) => MapEntry(
      variables[key] ??= Variable(key),
      TVProp(false, value, false /* none of them are methods */),
    ),
  );
  String v = '~type${environment.anythingType.name.name}';
  intrinsics.types[variables[v] ??= Variable(v)] = TVProp(false, environment.anythingType, false);
  v = '~type${environment.integerType.name.name}';
  intrinsics.types[variables[v] ??= Variable(v)] = TVProp(false, environment.integerType, false);
  v = '~type${environment.stringType.name.name}';
  intrinsics.types[variables[v] ??= Variable(v)] = TVProp(false, environment.stringType, false);
  v = '~type${environment.booleanType.name.name}';
  intrinsics.types[variables[v] ??= Variable(v)] = TVProp(false, environment.booleanType, false);
  v = '~type${environment.nullType.name.name}';
  intrinsics.types[variables[v] ??= Variable(v)] = TVProp(false, environment.nullType, false);
  v = '~type${environment.rootClassType.name.name}';
  intrinsics.types[variables[v] ??= Variable(v)] = TVProp(false, environment.rootClassType, false);
  v = '~type${environment.stringBufferType.name.name}';
  intrinsics.types[variables[v] ??= Variable(v)] = TVProp(false, environment.stringBufferType, false);
  v = '~type${environment.fileType.name.name}';
  intrinsics.types[variables[v] ??= Variable(v)] = TVProp(false, environment.fileType, false);
  v = '~type${environment.sentinelType.name.name}';
  intrinsics.types[variables[v] ??= Variable(v)] = TVProp(false, environment.sentinelType, false);
  intrinsics.directVars.addAll(intrinsics.types.keys);

  TypeValidator validator =
      TypeValidator([intrinsics], ConcatenateLazyString(NotLazyString('file '), NotLazyString(file)), false, false, false, rtl, variables, environment);
  if (rtl != null) {
    validator.types.addAll(rtl.value.types);
    validator.classes.addAll(rtl.value.classes);
    validator.usedVars.addAll(rtl.value.usedVars);
  }
  List<Statement> ast = parseBlock(tokens, validator, false);
  if (isMain) {
    List<Variable> unusedGlobalscopeVars = validator.types.keys.where((element) => !validator.usedVars.contains(element)).toList();
    if (!unusedGlobalscopeVars.isEmpty) {
      validator.environment.stderr.writeln('Unused vars:\n  ${unusedGlobalscopeVars.map((e) => e.name).join('\n  ')}');
    }
    for (TypeValidator classTv in validator.classes.values) {
      List<Variable> unusedClassVars = classTv.types.keys
          .where((element) => !classTv.usedVars.contains(element) && !classTv.parents.any((element2) => element2.igv(element, false) != null))
          .toList();
      if (!unusedClassVars.isEmpty) {
        validator.environment.stderr.writeln('Unused vars for ${classTv.debugName}:\n  ${unusedClassVars.map((e) => e.name).join('\n  ')}');
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
    throw BSCException(
      'The while condition ($value, a ${value.staticType}) is not a Boolean       ${formatCursorPositionFromTokens(tokens)}',
      scope,
    );
  }
  tokens.expectChar(TokenType.closeParen);
  tokens.expectChar(TokenType.openBrace);
  TypeValidator tv = TypeValidator([scope], NotLazyString('while loop'), false, false, false, scope.rtl, scope.variables, scope.environment);
  List<Statement> body = parseBlock(tokens, tv);
  List<String> unusedWhileLoopVars = tv.types.keys.where((element) => !tv.usedVars.contains(element)).map((e) => e.name).toList();
  if (!unusedWhileLoopVars.isEmpty) {
    scope.environment.stderr.writeln('Unused vars for while loop: ${formatCursorPositionFromTokens(tokens)}\n  ${unusedWhileLoopVars.join('\n  ')}');
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
    throw BSCException(
      'cannot have import statement after non-import ${formatCursorPositionFromTokens(tokens)}',
      scope,
    );
  }
  tokens.moveNext();
  String str = tokens.string;
  if (scope.environment.filesStartedLoading.contains(str)) {
    throw BSCException(
      'Import loop detected at ${formatCursorPositionFromTokens(tokens)}',
      scope,
    );
  }
  scope.environment.filesStartedLoading.add(str);
  if (!File('${path.dirname(tokens.file)}/$str').existsSync()) {
    throw BSCException('Attempted import of nonexistent file $str ${path.dirname(tokens.file)} ${tokens.file} $str ${formatCursorPositionFromTokens(tokens)}', scope);
  }
  tokens.moveNext();
  tokens.expectChar(TokenType.endOfStatement);

  MapEntry<List<Statement>, TypeValidator> result = scope.environment.filesLoaded[str] ??
      (scope.environment.filesLoaded[str] = parse(lex(File('${path.dirname(tokens.file)}/$str').readAsStringSync(), '${path.dirname(tokens.file)}/$str', scope.environment),
          '${path.dirname(tokens.file)}/$str', scope.rtl, false, scope.variables, scope.environment));
  scope.environment.loadedGlobalScopes[str] = result.value;
  scope.environment.filesStartedLoading.remove(str);
  scope.types.addAll(result.value.types);
  scope.classes.addAll(result.value.classes);
  scope.usedVars.addAll(result.value.usedVars);
  tokens.getPrevious();
  return ImportStatement(result.key, '${path.dirname(tokens.file)}/$str', tokens.current.line, tokens.current.col, (tokens..moveNext()).file, scope);
}

class ValueTypePlaceholder {
  final ValueType? parent;
  final Variable name;
  final int line;
  final int col;
  
  final String file;
  ValueTypePlaceholder(this.parent, this.name, this.line, this.col, this.file);
  @override
  String toString() => 'VTP($name)';

  ValueType toVT(TypeValidator scope) {
    return ValueType.create(parent, name, line, col, file, scope);
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
    throw BSCException('comment feature at end of file ${tokens.file}', scope);
  }
  if (tokens.current is! IdentToken) {
    tokens.getPrevious();
    tokens.doneImports = true;
    return parseNonKeywordStatement(tokens, scope);
  }
  switch (tokens.currentIdent) {
    case fwdclassVariable:
      if (overriden) {
        scope.environment.stderr.writeln('Can\'t override classes ${formatCursorPositionFromTokens(tokens)}');
      }
      tokens.moveNext();
      Variable cln = tokens.currentIdent;
      tokens.moveNext();
      List<ValueTypePlaceholder>? parameters;
      parameters = parseArgList(tokens, (TokenIterator tokens) {
        ValueTypePlaceholder result = ValueTypePlaceholder(
          null,
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
      if (tokens.current is IdentToken && tokens.currentIdent == scope.variables['extends']) {
        spt = ValueType.create(null, (tokens..moveNext()).currentIdent, tokens.current.line, tokens.current.col, tokens.file, scope)
            as ClassValueType;
        props = TypeValidator([spt.properties], ConcatenateLazyString(NotLazyString('forward-declared subclass '), VariableLazyString(cln)), true, false, false,
            scope.rtl, scope.variables, scope.environment);
        tokens.moveNext();
      } else {
        props = TypeValidator([scope], ConcatenateLazyString(NotLazyString('forward-declared root class '), VariableLazyString(cln)), true, false, false,
            scope.rtl, scope.variables, scope.environment);
      }
      ClassValueType x = ClassValueType(cln, spt, props, tokens.file, true, scope);
      FunctionValueType? constructorType;
      constructorType = FunctionValueType(scope.environment.nullType, parameters.map((e) => e.toVT(scope)), tokens.file, scope);

      props.types[constructorVariable] = TVProp(true, constructorType, false);
      constructorType = constructorType.withReturnType(x, tokens.file);
      ClassOfValueType y = ClassOfValueType(
        x,
        TypeValidator([
          scope,
          if (spt != null)
            (ValueType.create(null, scope.variables[spt.name.name + 'Class'] ??= Variable(spt.name.name + 'Class'), tokens.current.line, tokens.current.col,
                    tokens.file, scope) as ClassOfValueType)
                .staticMembers,
        ], NotLazyString('static members'), false, true, false, scope.rtl, scope.variables, scope.environment),
        constructorType,
        tokens.file,
        scope,
      );
      spt?.subtypes.add(x);
      scope.newVar(x.name, y, tokens.current.line, tokens.current.col, tokens.file);
      x.properties.types[thisVariable] = TVProp(true, x, false);
      if (ignoreUnused) {
        scope.igv(cln, true);
      }
      tokens.expectChar(TokenType.endOfStatement);
      return NopStatement();
    case fwdclassfieldVariable:
      ValueType type = ValueType.create(null, (tokens..moveNext()).currentIdent, tokens.current.line, tokens.current.col, tokens.file, scope);
      ValueType reciever =
          ValueType.create(null, (tokens..moveNext()).currentIdent, tokens.current.line, tokens.current.col, tokens.file, scope);
      if (reciever is! ClassValueType) {
        throw BSCException('fwdclassfields should only be defined on classes ${formatCursorPositionFromTokens(tokens)}', scope);
      }
      if (!reciever.fwdDeclared) {
        throw BSCException(
            'fwdclassfields should only be defined on forward-declared classes, before the real class is created ${formatCursorPositionFromTokens(tokens)}',
            scope);
      }
      ClassValueType cl = reciever;
      tokens..moveNext();
      tokens.expectChar(TokenType.period);
      if (overriden) {
        scope.environment.stderr.writeln('fwdclassfields should never be defined as override ${formatCursorPositionFromTokens(tokens)}');
      }
      if (cl.properties.types[tokens.currentIdent] != null) {
        throw BSCException('fwdclassfields should only be defined once per class ${formatCursorPositionFromTokens(tokens)}', scope);
      }
      cl.properties.types[tokens.currentIdent] = TVProp(true, type, false);
      if (ignoreUnused) {
        cl.properties.igv(tokens.currentIdent, true);
      }
      tokens.moveNext();
      tokens.expectChar(TokenType.endOfStatement);
      return NopStatement();
    case fwdclassmethodVariable:
      ValueType returnType =
          ValueType.create(null, (tokens..moveNext()).currentIdent, tokens.current.line, tokens.current.col, tokens.file, scope);
      ValueType reciever =
          ValueType.create(null, (tokens..moveNext()).currentIdent, tokens.current.line, tokens.current.col, tokens.file, scope);
      if (reciever is! ClassValueType) {
        throw BSCException('fwdclassmethods should only be defined on classes ${formatCursorPositionFromTokens(tokens)}', scope);
      }
      if (!reciever.fwdDeclared) {
        throw BSCException(
            'fwdclassmethods should only be defined on forward-declared classes, before the real class is created ${formatCursorPositionFromTokens(tokens)}',
            scope);
      }
      ClassValueType cl = reciever;
      tokens..moveNext();
      tokens.expectChar(TokenType.period);
      if (overriden) {
        scope.environment.stderr.writeln('fwdclassmethods should never be defined as override ${formatCursorPositionFromTokens(tokens)}');
      }
      if (cl.properties.types[tokens.currentIdent] != null) {
        throw BSCException('fwdclassmethods should only be defined once per class ${formatCursorPositionFromTokens(tokens)}', scope);
      }
      Variable methodName = tokens.currentIdent;
      tokens.moveNext();
      List<ValueType> parameters = parseArgList(tokens, (tokens) {
        Variable name = tokens.currentIdent;
        tokens.moveNext();
        return ValueType.create(null, name, tokens.current.line, tokens.current.col, tokens.file, scope);
      });
      ValueType type = FunctionValueType(returnType, parameters, tokens.file, scope);
      cl.properties.types[methodName] = TVProp(true, type, false);
      if (ignoreUnused) {
        cl.properties.igv(methodName, true);
      }
      tokens.expectChar(TokenType.endOfStatement);
      return NopStatement();
    case fwdstaticfieldVariable:
      ValueType type = ValueType.create(null, (tokens..moveNext()).currentIdent, tokens.current.line, tokens.current.col, tokens.file, scope);
      ClassOfValueType cl = (ValueType.create(
          null,
          scope.variables[(tokens..moveNext()).currentIdent.name + 'Class'] ??= Variable((tokens..moveNext()).currentIdent.name + 'Class'),
          tokens.current.line,
          tokens.current.col,
          tokens.file,
          scope) as ClassOfValueType);
      tokens..moveNext();
      tokens.expectChar(TokenType.period);
      if (overriden) {
        scope.environment.stderr.writeln('fwdstaticfields should never be defined as override ${formatCursorPositionFromTokens(tokens)}');
      }
      cl.staticMembers.types[tokens.currentIdent] = TVProp(true, type, false);
      if (ignoreUnused) {
        cl.staticMembers.igv(tokens.currentIdent, true);
      }
      tokens.moveNext();
      tokens.expectChar(TokenType.endOfStatement);
      return NopStatement();
    case fwdstaticmethodVariable:
      ValueType returnType =
          ValueType.create(null, (tokens..moveNext()).currentIdent, tokens.current.line, tokens.current.col, tokens.file, scope);
      ClassValueType cl =
          (ValueType.create(null, (tokens..moveNext()).currentIdent, tokens.current.line, tokens.current.col, tokens.file, scope)
              as ClassValueType);
      tokens..moveNext();
      tokens.expectChar(TokenType.period);
      if (overriden) {
        scope.environment.stderr.writeln('fwdstaticmethods should never be defined as override ${formatCursorPositionFromTokens(tokens)}');
      }
      Variable methodName = tokens.currentIdent;
      tokens.moveNext();
      List<ValueType> parameters = parseArgList(tokens, (tokens) {
        Variable name = tokens.currentIdent;
        tokens.moveNext();
        return ValueType.create(null, name, tokens.current.line, tokens.current.col, tokens.file, scope);
      });
      ValueType type = FunctionValueType(returnType, parameters, tokens.file, scope);
      cl.properties.types[methodName] = TVProp(true, type, false);
      if (ignoreUnused) {
        cl.properties.igv(methodName, true);
      }
      for (ClassValueType cvt in cl.allDescendants) {
        cvt.properties.types[methodName] = TVProp(true, type, false);
        if (ignoreUnused) {
          cvt.properties.igv(methodName, true);
        }
      }
      tokens.moveNext();
      tokens.expectChar(TokenType.endOfStatement);
      return NopStatement();
    case classVariable:
      if (overriden) {
        scope.environment.stderr.writeln('Can\'t override classes ${formatCursorPositionFromTokens(tokens)}');
      }
      return parseClass(tokens, scope, ignoreUnused);

    case importVariable:
      if (overriden) {
        scope.environment.stderr.writeln('Overriding an import makes no sense, like, what does that mean ${formatCursorPositionFromTokens(tokens)}');
      }
      if (ignoreUnused) {
        scope.environment.stderr.writeln('Instead of this, ignore_unused on all the unused components of the library ${formatCursorPositionFromTokens(tokens)}');
      }
      return parseImport(tokens, scope);
    case whileVariable:
      tokens.doneImports = true;
      if (overriden) {
        scope.environment.stderr.writeln('Can\'t override whiles ${formatCursorPositionFromTokens(tokens)}');
      }
      if (ignoreUnused) {
        scope.environment.stderr.writeln('What does that even mean for a while loop (look at this and previous line) ${formatCursorPositionFromTokens(tokens)}');
      }
      return parseWhile(tokens, scope);
    case breakVariable:
      if (overriden) {
        scope.environment.stderr.writeln('Can\'t override breaks ${formatCursorPositionFromTokens(tokens)}');
      }
      if (ignoreUnused) {
        scope.environment.stderr.writeln('What does that even mean for a break statement (look at this and previous line) ${formatCursorPositionFromTokens(tokens)}');
      }
      tokens.doneImports = true;
      return BreakStatement.parse(tokens, scope);
    case continueVariable:
      tokens.doneImports = true;
      if (overriden) {
        scope.environment.stderr.writeln('Can\'t override continues ${formatCursorPositionFromTokens(tokens)}');
      }
      if (ignoreUnused) {
        scope.environment.stderr.writeln('What does that even mean for a continue statement (look at this and previous line) ${formatCursorPositionFromTokens(tokens)}');
      }
      return ContinueStatement.parse(tokens, scope);
    case returnVariable:
      tokens.doneImports = true;
      if (overriden) {
        scope.environment.stderr.writeln('Can\'t override returns ${formatCursorPositionFromTokens(tokens)}');
      }
      if (ignoreUnused) {
        scope.environment.stderr.writeln('What does that even mean for a return statement (look at this and previous line) ${formatCursorPositionFromTokens(tokens)}');
      }
      return ReturnStatement.parse(tokens, scope);
    case ifVariable:
      tokens.doneImports = true;
      if (overriden) {
        scope.environment.stderr.writeln('Can\'t override if statements ${formatCursorPositionFromTokens(tokens)}');
      }
      if (ignoreUnused) {
        scope.environment.stderr.writeln('What does that even mean for a if statement (look at this and previous line) ${formatCursorPositionFromTokens(tokens)}');
      }
      return parseIf(tokens, scope);
    case enumVariable:
      if (overriden) {
        scope.environment.stderr.writeln('Can\'t override enums ${formatCursorPositionFromTokens(tokens)}');
      }
      if (ignoreUnused) {
        scope.environment.stderr.writeln('why do you not need every value of an enum ${formatCursorPositionFromTokens(tokens)}');
      }
      tokens.doneImports = true;
      return parseEnum(tokens, scope);
    case forVariable:
      tokens.doneImports = true;
      if (overriden) {
        scope.environment.stderr.writeln('Can\'t override fors ${formatCursorPositionFromTokens(tokens)}');
      }
      return parseForIn(tokens, scope, ignoreUnused);
    case constVariable:
      tokens.doneImports = true;

      if (overriden) {
        scope.environment.stderr.writeln('Can\'t override consts ${formatCursorPositionFromTokens(tokens)}');
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
  if (tokens.current is IdentToken && tokens.currentIdent == scope.variables['static']) {
    tokens.moveNext();
    static = true;
  }
  ValueType type = ValueType.create(null, tokens.currentIdent, tokens.current.line, tokens.current.col, tokens.file, scope);
  tokens.moveNext();
  Variable name = tokens.currentIdent;
  tokens.moveNext();
  tokens.expectChar(TokenType.set);
  Expression expr = parseExpression(
    tokens,
    scope,
  );
  if (!expr.staticType.isSubtypeOf(type)) {
    throw BSCException('attempted to assign $expr (a ${expr.staticType}) to $name, which is a const $type ${formatCursorPositionFromTokens(tokens)}', scope);
  }
  tokens.expectChar(TokenType.endOfStatement);
  if (!static) scope.types[name] = TVProp(false, type, false);
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
  Variable currentName = tokens.currentIdent;
  tokens.moveNext();
  if (tokens.currentIdent != (scope.variables['in'] ??= Variable('in'))) {
    throw BSCException('no \'in\' after name of new variable in the for loop ${formatCursorPositionFromTokens(tokens)}', scope);
  }
  tokens.moveNext();
  Expression iterable = parseExpression(
    tokens,
    scope,
  );
  if (!iterable.staticType.isSubtypeOf(ValueType.create(null, scope.variables['WhateverIterable'] ??= Variable('WhateverIterable'), tokens.current.line,
      tokens.current.col, tokens.file, scope))) {
    throw BSCException('tried to for loop over non-iterable (iterated over ${iterable.staticType}) ${formatCursorPositionFromTokens(tokens)}', scope);
  }
  TypeValidator innerScope = TypeValidator([scope], NotLazyString('for loop'), false, false, false, scope.rtl, scope.variables, scope.environment);
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
  );
  if (ignoreUnused) {
    innerScope.igv(currentName, true);
  }
  tokens.expectChar(TokenType.closeParen);
  tokens.expectChar(TokenType.openBrace);
  List<Statement> body = parseBlock(tokens, innerScope);
  List<String> unusedForLoopVars = innerScope.types.keys.where((element) => !innerScope.usedVars.contains(element)).toList().map((e) => e.name).toList();
  if (!unusedForLoopVars.isEmpty) {
    scope.environment.stderr.writeln('Unused vars for for loop: ${formatCursorPositionFromTokens(tokens)}\n  ${unusedForLoopVars.join('\n  ')}');
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
  Variable name = tokens.currentIdent;
  tokens.moveNext();
  List<Variable> body = [];
  TypeValidator tv = TypeValidator(
      [], ConcatenateLazyString(VariableLazyString(name), NotLazyString('-enum')), false, false, false, scope.rtl, scope.variables, scope.environment);
  EnumPropertyValueType propType = EnumPropertyValueType(name, tokens.file, scope);
  EnumValueType type = EnumValueType(name, tv, tokens.file, propType, scope);
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
    throw BSCException(
      'The if condition ($value, a ${value.staticType}) is not a Boolean        ${formatCursorPositionFromTokens(tokens)}',
      scope,
    );
  }
  tokens.expectChar(TokenType.openBrace);
  TypeValidator innerScope = TypeValidator([scope], NotLazyString('if statement'), false, false, false, scope.rtl, scope.variables, scope.environment);
  List<Statement> body = parseBlock(tokens, innerScope);
  List<String> unusedForLoopVars = innerScope.types.keys.where((element) => !innerScope.usedVars.contains(element)).map((e) => e.name).toList();
  if (!unusedForLoopVars.isEmpty) {
    scope.environment.stderr.writeln('Unused vars for if statement: ${formatCursorPositionFromTokens(tokens)}\n  ${unusedForLoopVars.join('\n  ')}');
  }
  List<Statement> elseBody = [];
  tokens.expectChar(TokenType.closeBrace);
  if (tokens.current is IdentToken && tokens.currentIdent == scope.variables['else']) {
    tokens.moveNext();
    if (tokens.current is IdentToken && tokens.currentIdent == scope.variables['if']) {
      IfStatement parsedIf = parseIf(tokens, scope);
      elseBody = [parsedIf];
    } else {
      tokens.expectChar(TokenType.openBrace);
      TypeValidator elseBlock =
          TypeValidator([scope], NotLazyString('if statement - else block'), false, false, false, scope.rtl, scope.variables, scope.environment);
      elseBody = parseBlock(tokens, elseBlock);
      List<String> unusedForLoopVars = elseBlock.types.keys.where((element) => !elseBlock.usedVars.contains(element)).map((e) => e.name).toList();
      if (!unusedForLoopVars.isEmpty) {
        scope.environment.stderr.writeln('Unused vars for if statement (else block): ${formatCursorPositionFromTokens(tokens)}\n  ${unusedForLoopVars.join('\n  ')}');
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
