import 'statements.dart';
import 'lexer.dart';
import 'parser-core.dart';
import 'expressions.dart';
import 'expression-parser.dart';
import 'dart:io';

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
  if (tokens.current is IdentToken && tokens.currentIdent == variables['extends']) {
    tokens.moveNext();
    superclass = tokens.currentIdent;
    scope.getVar(superclass, tokens.current.line, tokens.current.col, tokens.workspace, tokens.file, 'for subclassing', false);
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
          tokens.workspace,
          tokens.file,
        );
  if (superclass != null && !scope.classes.containsKey(superclass)) {
    throw BSCException("${superclass.name} nonexistent while trying to have ${name.name} extend it. ${formatCursorPositionFromTokens(tokens)}", scope);
  }
  TypeValidator newScope = superclass == null
      ? TypeValidator([scope], ConcatenateLazyString(NotLazyString('root class '), VariableLazyString(name)), true, false, false, scope.rtl)
      : TypeValidator(
          [scope.classes[superclass]!, scope], ConcatenateLazyString(NotLazyString('subclass '), VariableLazyString(name)), true, false, false, scope.rtl);
  ClassValueType type = ClassValueType(name, supertype as ClassValueType?, newScope, tokens.file, false);
  if (newScope != type.properties) {
    if (supertype != type.supertype) {
      throw BSCException(
        "${name.name} does not have the same supertype ($supertype) as forward declaration (${type.supertype}) ${formatCursorPositionFromTokens(tokens)}",
        scope,
      );
    }
  }
  TypeValidator fwdProps = type.properties.copy();
  bool hasFwdDecl = newScope != type.properties;
  // newScope = type.properties..parents.addAll([scope]);
  newScope = ClassTypeValidator(fwdProps, newScope.parents, type.properties.debugName, true, false, false, scope.rtl);
  type.properties.types = newScope.types;
  newScope.usedVars = type.properties.usedVars;
  type.properties.parents.add(fwdProps);
  newScope.newVar(
    thisVariable,
    type,
    tokens.current.line,
    tokens.current.col,
    tokens.workspace,
    tokens.file,
  );
  newScope.newVar(
    classNameVariable,
    stringType,
    tokens.current.line,
    tokens.current.col,
    tokens.workspace,
    tokens.file,
  );
  newScope.usedVars.add(thisVariable);
  newScope.usedVars.add(classNameVariable);
  newScope.usedVars.add(toStringVariable);
  List<Statement> block = parseBlock(tokens, newScope);
  ValueType? supertype1 = superclass != null ? scope.igv(variables["${superclass.name}"]!, true) : null;
  if (supertype1 is FunctionValueType) {
    throw BSCException("Cannot extend an class that has not been defined yet.", scope);
  }
  TypeValidator staticMembers = TypeValidator([if (superclass != null) (supertype1 as ClassOfValueType).staticMembers],
      ConcatenateLazyString(NotLazyString('static members of '), VariableLazyString(name)), false, true, false, scope.rtl);
  for (Statement statement in block) {
    if (statement is StaticFieldStatement) {
      if (!statement.val.type.isSubtypeOf(
          staticMembers.igv(statement.name, false, tokens.current.line, tokens.current.col, tokens.workspace, tokens.file, true, false) ?? anythingType)) {
        throw BSCException(
          "Invalid override of static member ${statement.name.name} - expected ${staticMembers.igv(statement.name, false, tokens.current.line, tokens.current.col, tokens.workspace, tokens.file, true, false)} but got ${statement.val.type} ${formatCursorPositionFromTokens(tokens)}",
          scope,
        );
      }
      staticMembers.newVar(
        statement.name,
        statement.val.type,
        statement.line,
        statement.col,
        tokens.workspace,
        tokens.file,
      );
    }
    if (statement is FunctionStatement && statement.static) {
      if (!statement.type.isSubtypeOf(
          staticMembers.igv(statement.name, false, tokens.current.line, tokens.current.col, tokens.workspace, tokens.file, true, false) ?? anythingType)) {
        throw BSCException(
          "Invalid override of static member ${statement.name.name} - expected ${staticMembers.igv(statement.name, false, tokens.current.line, tokens.current.col, tokens.workspace, tokens.file, true, false)} but got ${statement.type} ${formatCursorPositionFromTokens(tokens)}",
          scope,
        );
      }
      staticMembers.newVar(
        statement.name,
        statement.type,
        statement.line,
        statement.col,
        tokens.workspace,
        tokens.file,
      );
    }
  }
  if (!(newScope.igv(constructorVariable, true)?.isSubtypeOf(GenericFunctionValueType(nullType, tokens.file)) ?? true)) {
    throw BSCException('Bad constructor type: ${newScope.igv(constructorVariable, true)} ${formatCursorPositionFromTokens(tokens)}', scope);
  }
  if (!hasFwdDecl) {
    if (supertype != null) {
      for (MapEntry<Variable, TVProp> property in newScope.types.entries) {
        if (!property.value.type.isSubtypeOf(supertype.properties.igv(
                  property.key,
                  false,
                  -2,
                  0,
                  'err',
                  'err2',
                  true,
                  false,
                ) ??
                anythingType) &&
            property.key != constructorVariable &&
            property.value.runtimeType != GenericFunctionValueType) {
          throw BSCException(
            "${name.name} type has invalid override of ${superclass!.name}.${property.key.name} (expected ${supertype.properties.igv(property.key, false)}, got ${property.value.type} ${formatCursorPositionFromTokens(tokens)}",
            scope,
          );
        }
      }
    }
  }
  if (hasFwdDecl) {
    for (MapEntry<Variable, TVProp> value in fwdProps.types.entries) {
      if (value.key == constructorVariable) {
        if (newScope.igv(value.key, false, -2, 0, '', '', true, false, false) != value.value.type) {
          throw BSCException(
              "${name.name}'s constructor (${newScope.igv(value.key, false, -2, 0, '', '', true, false, false)}) does not match forward declaration (${value.value.type}) ${formatCursorPositionFromTokens(tokens)}",
              scope);
        }
      }
      if (newScope.igv(value.key, false, -2, 0, '', '', true, false, false) == null) {
        throw BSCException(
            "${name.name}.${value.key.name} (nonexistent) does not match forward declaration (a ${value.value.type}) ${formatCursorPositionFromTokens(tokens)}",
            scope);
      }
      if (newScope.igv(value.key, false, -2, 0, '', '', true, false, false) != value.value.type) {
        if (!(value.value is GenericFunctionValueType &&
            value.value is! FunctionValueType &&
            newScope.igv(value.key, false) is FunctionValueType &&
            (newScope.igv(value.key, false) as GenericFunctionValueType).returnType == (value.value as GenericFunctionValueType).returnType)) {
          throw BSCException(
              "${name.name}.${value.key.name} (a ${newScope.igv(value.key, false)}) does not match forward declaration (a ${value.value.type}) ${formatCursorPositionFromTokens(tokens)}",
              scope);
        }
      }
    }
  }
  scope.classes[name] = newScope;
  if (hasFwdDecl) {
    scope.directVars.remove(name); // will be re-added in a few lines
  }
  GenericFunctionValueType constructorType = type.recursiveLookup(constructorVariable)?.key is FunctionValueType?
      ? FunctionValueType(type, (type.recursiveLookup(constructorVariable)?.key as FunctionValueType?)?.parameters ?? [], tokens.file)
      : GenericFunctionValueType(type, tokens.file);
  ClassOfValueType classOfType = ClassOfValueType(
    type,
    staticMembers,
    constructorType,
    tokens.file,
  );
  scope.newVar(
    name,
    classOfType,
    tokens.current.line,
    tokens.current.col,
    tokens.workspace,
    tokens.file,
  );
  if (ignoreUnused) {
    scope.igv(name, true);
  }
  scope.nonconst.remove(name);
  tokens.expectChar(TokenType.closeBrace);
  return ClassStatement(name, superclass, block, type, tokens.current.line, tokens.current.col, tokens.workspace, tokens.file, classOfType);
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
    } else {
      stderr.writeln("Unknown comment feature: $feature ${formatCursorPositionFromTokens(tokens)}");
      tokens.moveNext();
    }
  }
  if (tokens.current is CommentFeatureToken) {
    String feature = (tokens.current as CommentFeatureToken).feature;
    if (feature == 'override') {
      if (overriden) {
        stderr.writeln("Duplicate override comment feature ${formatCursorPositionFromTokens(tokens)}");
      }
      overriden = true;
      tokens.moveNext();
    } else if (feature == 'ignore_unused') {
      if (ignoreUnused) {
        stderr.writeln("Duplicate ignore_unused comment feature ${formatCursorPositionFromTokens(tokens)}");
      }
      ignoreUnused = true;
      tokens.moveNext();
    } else {
      stderr.writeln("Unknown comment feature after comment feature: $feature ${formatCursorPositionFromTokens(tokens)}");
      tokens.moveNext();
    }
  }
  int line = tokens.current.line;
  int col = tokens.current.col;
  bool static = false;
  if (tokens.current is IdentToken && tokens.currentIdent == variables['static']) {
    static = true;
    tokens.moveNext();
  }
  Expression expr = parseExpression(tokens, scope);
  if (tokens.current is CharToken && tokens.currentChar == TokenType.endOfStatement) {
    if (overriden || ignoreUnused)
      stderr.writeln("Comment features are currently pointless for expression statements ${formatCursorPositionFromTokens(tokens)}");
    if (static) {
      throw BSCException("static expression statements make no sense ${formatCursorPositionFromTokens(tokens)}", scope);
    }
    tokens.expectChar(TokenType.endOfStatement);
    return ExpressionStatement(expr, line, col);
  }
  if (tokens.current is CharToken) {
    if (overriden || ignoreUnused)
      stderr.writeln("Comment features are currently pointless for x++, x+=y, x--, x-=y, x=y, etc ${formatCursorPositionFromTokens(tokens)}");
    if (static) {
      throw BSCException("static x++, x+=y, x--, x-=y, x=y, etc make no sense ${formatCursorPositionFromTokens(tokens)}", scope);
    }
    if (tokens.currentChar == TokenType.set) {
      tokens.moveNext();
      Expression value = parseExpression(tokens, scope);
      if (!expr.isLValue(scope)) {
        throw BSCException("$expr is not an lvalue for = ${formatCursorPositionFromTokens(tokens)}", scope);
      }
      if (!value.type.isSubtypeOf(expr.type)) {
        throw BSCException("attempted $expr=$value but $value was not a ${expr.type} ${formatCursorPositionFromTokens(tokens)}", scope);
      }
      tokens.expectChar(TokenType.endOfStatement);
      return SetStatement(expr, value, line, col, tokens.workspace, tokens.file);
    }
    if (tokens.currentChar == TokenType.plusEquals) {
      if (!expr.type.isSubtypeOf(integerType)) {
        throw BSCException("Attempted $expr (not an integer!) += ... ${formatCursorPositionFromTokens(tokens)}", scope);
      }
      tokens.moveNext();
      Expression value = parseExpression(tokens, scope);
      if (!value.type.isSubtypeOf(integerType)) {
        throw BSCException(
          "attempted $expr+=$value but $value was not an integer ${formatCursorPositionFromTokens(tokens)}",
          scope,
        );
      }
      tokens.expectChar(TokenType.endOfStatement);
      if (!expr.isLValue(scope)) {
        throw BSCException("$expr is not an lvalue for += ${formatCursorPositionFromTokens(tokens)}", scope);
      }
      return SetStatement(
        expr,
        AddExpression(
          expr,
          value,
          line,
          col,
          tokens.workspace,
          tokens.file,
        ),
        line,
        col,
        tokens.workspace,
        tokens.file,
      );
    } else if (tokens.currentChar == TokenType.plusPlus) {
      if (!expr.type.isSubtypeOf(integerType)) {
        throw BSCException("Attempted $expr (not an integer!) ++ ... ${formatCursorPositionFromTokens(tokens)}", scope);
      }
      tokens.expectChar(TokenType.plusPlus);
      tokens.expectChar(TokenType.endOfStatement);
      assert(expr.isLValue(scope));
      return SetStatement(
        expr,
        AddExpression(
          expr,
          IntLiteralExpression(1, line, col, tokens.workspace, tokens.file),
          line,
          col,
          tokens.workspace,
          tokens.file,
        ),
        line,
        col,
        tokens.workspace,
        tokens.file,
      );
    } else if (tokens.currentChar == TokenType.minusEquals) {
      if (!expr.type.isSubtypeOf(integerType)) {
        throw BSCException("Attempted $expr (not an integer!) -= ... ${formatCursorPositionFromTokens(tokens)}", scope);
      }
      tokens.moveNext();
      Expression value = parseExpression(tokens, scope);
      if (!value.type.isSubtypeOf(integerType)) {
        throw BSCException(
          "attempted $expr-=$value but $value was not an integer ${formatCursorPositionFromTokens(tokens)}",
          scope,
        );
      }
      tokens.expectChar(TokenType.endOfStatement);
      if (!expr.isLValue(scope)) {
        throw BSCException("$expr is not valid l-value; attempted to do -=", scope);
      }
      return SetStatement(
        expr,
        SubtractExpression(
          expr,
          value,
          line,
          col,
          tokens.workspace,
          tokens.file,
        ),
        line,
        col,
        tokens.workspace,
        tokens.file,
      );
    } else if (tokens.currentChar == TokenType.minusMinus) {
      if (!expr.type.isSubtypeOf(integerType)) {
        throw BSCException("Attempted $expr (not an integer!) -- ... ${formatCursorPositionFromTokens(tokens)}", scope);
      }
      tokens.expectChar(TokenType.minusMinus);
      tokens.expectChar(TokenType.endOfStatement);
      assert(expr.isLValue(scope));
      return SetStatement(
        expr,
        SubtractExpression(
          expr,
          IntLiteralExpression(1, line, col, tokens.workspace, tokens.file),
          line,
          col,
          tokens.workspace,
          tokens.file,
        ),
        line,
        col,
        tokens.workspace,
        tokens.file,
      );
    } else if (tokens.currentChar == TokenType.bitOrEquals) {
      if (!expr.type.isSubtypeOf(integerType)) {
        throw BSCException("Attempted $expr (not an integer!) |= ... ${formatCursorPositionFromTokens(tokens)}", scope);
      }
      tokens.moveNext();
      Expression value = parseExpression(tokens, scope);
      if (!value.type.isSubtypeOf(integerType)) {
        throw BSCException(
          "attempted $expr|=$value but $value was not an integer ${formatCursorPositionFromTokens(tokens)}",
          scope,
        );
      }
      tokens.expectChar(TokenType.endOfStatement);
      if (!expr.isLValue(scope)) {
        throw BSCException("$expr is not valid l-value; attempted to do |=", scope);
      }
      return SetStatement(
        expr,
        BitOrExpression(
          expr,
          value,
          line,
          col,
          tokens.workspace,
          tokens.file,
        ),
        line,
        col,
        tokens.workspace,
        tokens.file,
      );
    } else if (tokens.currentChar == TokenType.bitAndEquals) {
      if (!expr.type.isSubtypeOf(integerType)) {
        throw BSCException("Attempted $expr (not an integer!) &= ... ${formatCursorPositionFromTokens(tokens)}", scope);
      }
      tokens.moveNext();
      Expression value = parseExpression(tokens, scope);
      if (!value.type.isSubtypeOf(integerType)) {
        throw BSCException(
          "attempted $expr&=$value but $value was not an integer ${formatCursorPositionFromTokens(tokens)}",
          scope,
        );
      }
      tokens.expectChar(TokenType.endOfStatement);
      if (!expr.isLValue(scope)) {
        throw BSCException("$expr is not valid l-value; attempted to do &=", scope);
      }
      return SetStatement(
        expr,
        BitAndExpression(
          expr,
          value,
          line,
          col,
          tokens.workspace,
          tokens.file,
        ),
        line,
        col,
        tokens.workspace,
        tokens.file,
      );
    } else if (tokens.currentChar == TokenType.bitXorEquals) {
      if (!expr.type.isSubtypeOf(integerType)) {
        throw BSCException("Attempted $expr (not an integer!) ^= ... ${formatCursorPositionFromTokens(tokens)}", scope);
      }
      tokens.moveNext();
      Expression value = parseExpression(tokens, scope);
      if (!value.type.isSubtypeOf(integerType)) {
        throw BSCException(
          "attempted $expr^=$value but $value was not an integer ${formatCursorPositionFromTokens(tokens)}",
          scope,
        );
      }
      tokens.expectChar(TokenType.endOfStatement);
      if (!expr.isLValue(scope)) {
        throw BSCException("$expr is not valid l-value; attempted to do ^=", scope);
      }
      return SetStatement(
        expr,
        BitXorExpression(
          expr,
          value,
          line,
          col,
          tokens.workspace,
          tokens.file,
        ),
        line,
        col,
        tokens.workspace,
        tokens.file,
      );
    } else if (tokens.currentChar == TokenType.andandEquals) {
      if (!expr.type.isSubtypeOf(booleanType)) {
        throw BSCException("Attempted $expr (not an boolean!) &&= ... ${formatCursorPositionFromTokens(tokens)}", scope);
      }
      tokens.moveNext();
      Expression value = parseExpression(tokens, scope);
      if (!value.type.isSubtypeOf(booleanType)) {
        throw BSCException(
          "attempted $expr&&=$value but $value was not an boolean ${formatCursorPositionFromTokens(tokens)}",
          scope,
        );
      }
      tokens.expectChar(TokenType.endOfStatement);
      if (!expr.isLValue(scope)) {
        throw BSCException("$expr is not valid l-value; attempted to do &&=", scope);
      }
      return SetStatement(
        expr,
        AndExpression(
          expr,
          value,
          line,
          col,
          tokens.workspace,
          tokens.file,
        ),
        line,
        col,
        tokens.workspace,
        tokens.file,
      );
    } else if (tokens.currentChar == TokenType.ororEquals) {
      if (!expr.type.isSubtypeOf(booleanType)) {
        throw BSCException("Attempted $expr (not an boolean!) ||= ... ${formatCursorPositionFromTokens(tokens)}", scope);
      }
      tokens.moveNext();
      Expression value = parseExpression(tokens, scope);
      if (!value.type.isSubtypeOf(booleanType)) {
        throw BSCException(
          "attempted $expr||=$value but $value was not an boolean ${formatCursorPositionFromTokens(tokens)}",
          scope,
        );
      }
      tokens.expectChar(TokenType.endOfStatement);
      if (!expr.isLValue(scope)) {
        throw BSCException("$expr is not valid l-value; attempted to do ||=", scope);
      }
      return SetStatement(
        expr,
        OrExpression(
          expr,
          value,
          line,
          col,
          tokens.workspace,
          tokens.file,
        ),
        line,
        col,
        tokens.workspace,
        tokens.file,
      );
    } else if (tokens.currentChar == TokenType.divideEquals) {
      if (!expr.type.isSubtypeOf(integerType)) {
        throw BSCException("Attempted $expr (not an integer!) /= ... ${formatCursorPositionFromTokens(tokens)}", scope);
      }
      tokens.moveNext();
      Expression value = parseExpression(tokens, scope);
      if (!value.type.isSubtypeOf(integerType)) {
        throw BSCException(
          "attempted $expr/=$value but $value was not an integer ${formatCursorPositionFromTokens(tokens)}",
          scope,
        );
      }
      tokens.expectChar(TokenType.endOfStatement);
      if (!expr.isLValue(scope)) {
        throw BSCException("$expr is not valid l-value; attempted to do /=", scope);
      }
      return SetStatement(
        expr,
        DivideExpression(
          expr,
          value,
          line,
          col,
          tokens.workspace,
          tokens.file,
        ),
        line,
        col,
        tokens.workspace,
        tokens.file,
      );
    } else if (tokens.currentChar == TokenType.starEquals) {
      if (!expr.type.isSubtypeOf(integerType)) {
        throw BSCException("Attempted $expr (not an integer!) *= ... ${formatCursorPositionFromTokens(tokens)}", scope);
      }
      tokens.moveNext();
      Expression value = parseExpression(tokens, scope);
      if (!value.type.isSubtypeOf(integerType)) {
        throw BSCException(
          "attempted $expr*=$value but $value was not an integer ${formatCursorPositionFromTokens(tokens)}",
          scope,
        );
      }
      tokens.expectChar(TokenType.endOfStatement);
      if (!expr.isLValue(scope)) {
        throw BSCException("$expr is not valid l-value; attempted to do *=", scope);
      }
      return SetStatement(
        expr,
        MultiplyExpression(
          expr,
          value,
          line,
          col,
          tokens.workspace,
          tokens.file,
        ),
        line,
        col,
        tokens.workspace,
        tokens.file,
      );
    } else if (tokens.currentChar == TokenType.remainderEquals) {
      if (!expr.type.isSubtypeOf(integerType)) {
        throw BSCException("Attempted $expr (not an integer!) %= ... ${formatCursorPositionFromTokens(tokens)}", scope);
      }
      tokens.moveNext();
      Expression value = parseExpression(tokens, scope);
      if (!value.type.isSubtypeOf(integerType)) {
        throw BSCException(
          "attempted $expr%=$value but $value was not an integer ${formatCursorPositionFromTokens(tokens)}",
          scope,
        );
      }
      tokens.expectChar(TokenType.endOfStatement);
      if (!expr.isLValue(scope)) {
        throw BSCException("$expr is not valid l-value; attempted to do %=", scope);
      }
      return SetStatement(
        expr,
        RemainderExpression(
          expr,
          value,
          line,
          col,
          tokens.workspace,
          tokens.file,
        ),
        line,
        col,
        tokens.workspace,
        tokens.file,
      );
    }
  }
  Variable ident2 = tokens.currentIdent;
  tokens.moveNext();
  if (tokens.currentChar == TokenType.set) {
    tokens.expectChar(TokenType.set);
    Expression expr2 = parseExpression(tokens, scope);
    if (!expr2.type.isSubtypeOf(
      expr.asType,
    )) {
      throw BSCException(
        "$expr2 is not of type $expr, which is expected by ${ident2.name}. (it's a ${expr2.type}) ${formatCursorPositionFromTokens(tokens)}",
        scope,
      );
    }
    if (!static) {
      scope.newVar(
        ident2,
        expr.asType,
        line,
        col,
        tokens.workspace,
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
    return NewVarStatement(ident2, expr2, line, col, tokens.workspace, tokens.file, false, expr.asType);
  }
  if (tokens.currentChar == TokenType.endOfStatement) {
    tokens.expectChar(TokenType.endOfStatement);
    scope.newVar(
      ident2,
      expr.asType,
      line,
      col,
      tokens.workspace,
      tokens.file,
    );
    if (ignoreUnused) {
      scope.igv(ident2, true);
    }
    if (static) {
      throw BSCException("static declarations must have values ${formatCursorPositionFromTokens(tokens)}", scope);
    }
    return NewVarStatement(ident2, null, line, col, tokens.workspace, tokens.file, false, expr.asType);
  }
  if (!static) {
    if ((!scope.isClass && !scope.isClassOf) || scope.igv(ident2, false, -3, 0, '', '', true, false, false) == null) {
      if (overriden) {
        stderr.writeln('(lint) ${ident2.name} incorrectly defined as override ${formatCursorPositionFromTokens(tokens)}');
      }
    } else if (!overriden && ident2 != constructorVariable) {
      stderr.writeln(
          '(lint) ${ident2.name} should be defined as override (write //#override before the function declaration) ${formatCursorPositionFromTokens(tokens)}');
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
        throw BSCException("$ident2 had 2 varargs ${formatCursorPositionFromTokens(tokens)}", scope);
      }
      if (isNormal) {
        throw BSCException("$ident2 had regular arguments before a vararg ${formatCursorPositionFromTokens(tokens)}", scope);
      }
      isVararg = true;
    } else {
      isNormal = true;
    }
    Variable name = tokens.currentIdent;
    if (debugParams.contains(name)) {
      throw BSCException("$ident2 had duplicate parameter ${name.name} ${formatCursorPositionFromTokens(tokens)}", scope);
    }
    debugParams.add(name);
    tokens.moveNext();
    return Parameter(
        ValueType.create(
          null,
          type,
          line,
          col,
          tokens.workspace,
          tokens.file,
        ),
        name);
  });
  if (isVararg && params.length > 1) {
    throw BSCException("$ident2 had ${params.length - 1} regular arguments and a vararg ${formatCursorPositionFromTokens(tokens)}", scope);
  }
  //if (params.isEmpty && ident2.name == 'constructor') {
  //print('no constructor args :( ${scope.debugName}');
  //}
  if (isVararg) {
    params = InfiniteIterable(params.single);
  }
  tokens.expectChar(TokenType.openBrace);
  Iterable<ValueType> typeParams = isVararg ? InfiniteIterable(params.first.type) : params.map((e) => e.type);
  TypeValidator tv = TypeValidator([scope], ConcatenateLazyString(NotLazyString('function '), VariableLazyString(ident2)), false, false, static, scope.rtl)
    ..types.addAll(isVararg
        ? {params.first.name: TVProp(false, ListValueType(params.first.type, 'internal'), false)}
        : Map.fromEntries(params.map((e) => MapEntry(e.name, TVProp(false, e.type, false)))))
    ..types[ident2] = TVProp(
        false,
        FunctionValueType(
          expr.asType,
          typeParams,
          tokens.file,
        ),
        false /* it's a function, but super.ident2 shouldn't get to THIS TVProp, but the one in the main scope */)
    ..directVars.addAll([ident2, if (isVararg) params.first.name, if (!isVararg) ...params.map((e) => e.name)]);
  List<Statement> body = parseBlock(tokens, tv);
  List<String> unusedFuncVars = tv.types.keys
      .where((element) => !tv.usedVars.contains(element) && element != ident2 && !params.any((e) => element == e.name))
      .map((e) => e.name)
      .toList();
  if (!unusedFuncVars.isEmpty) {
    stderr.writeln("Unused vars for ${tv.debugName}:\n  ${unusedFuncVars.join('\n  ')}");
  }
  tokens.expectChar(TokenType.closeBrace);
  ValueType type = FunctionValueType(expr.asType, typeParams, tokens.file);
  if (!static) {
    scope.newVar(
      ident2,
      type,
      line,
      col,
      tokens.workspace,
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
  return FunctionStatement(
    expr.asType,
    ident2,
    params,
    body,
    line,
    col,
    tokens.workspace,
    tokens.file,
    static,
    type,
  );
}

MapEntry<List<Statement>, TypeValidator> parse(
    Iterable<Token> rtokens, String workspace, String file, MapEntry<List<Statement>, TypeValidator>? rtl, bool isMain) {
  TokenIterator tokens = TokenIterator(rtokens.iterator, workspace, file);

  tokens.moveNext();
  TypeValidator intrinsics = TypeValidator([], NotLazyString('intrinsics'), false, false, false, rtl)
    ..types = <String, ValueType>{
      "true": booleanType,
      "false": booleanType,
      "null": nullType,
      "args": ListValueType(stringType, 'intrinsics'),
      "print": FunctionValueType(integerType, InfiniteIterable(anythingType), 'intrinsics'),
      "stderr": FunctionValueType(integerType, InfiniteIterable(anythingType), 'intrinsics'),
      "concat": FunctionValueType(stringType, InfiniteIterable(anythingType), 'intrinsics'),
      "parseInt": FunctionValueType(integerType, [stringType], 'intrinsics'),
      'addLists': FunctionValueType(ListValueType(anythingType, 'intrinsics'),
          InfiniteIterable(ListValueType(ValueType.create(null, whateverVariable, -2, 0, 'interr', 'intrinsics'), 'intrinsics')), 'intrinsics'),
      'charsOf': FunctionValueType(IterableValueType(stringType, 'intrinsics'), [stringType], 'intrinsics'),
      'scalarValues': FunctionValueType(IterableValueType(integerType, 'intrinsics'), [stringType], 'intrinsics'),
      'split': FunctionValueType(ListValueType(stringType, 'intrinsics'), [stringType, stringType], 'intrinsics'),
      'len': FunctionValueType(
          integerType, [IterableValueType(ValueType.create(null, whateverVariable, -2, 0, 'interr', 'intrinsics'), 'intrinsics')], 'intrinsics'),
      'input': FunctionValueType(stringType, [], 'intrinsics'),
      'append': FunctionValueType(
          anythingType, [ListValueType(ValueType.create(null, whateverVariable, -2, 0, 'interr', 'intrinsics'), 'intrinsics'), anythingType], 'intrinsics'),
      'iterator': FunctionValueType(IteratorValueType(anythingType, 'intrinsics'),
          [IterableValueType(ValueType.create(null, whateverVariable, -2, 0, 'interr', 'intrinsics'), 'intrinsics')], 'intrinsics'),
      'next': FunctionValueType(booleanType, [IteratorValueType(anythingType, 'intrinsics')], 'intrinsics'),
      'current': FunctionValueType(anythingType, [IteratorValueType(anythingType, 'intrinsics')], 'intrinsics'),
      'stringTimes': FunctionValueType(stringType, [stringType, integerType], 'intrinsics'),
      'copy': FunctionValueType(ListValueType(ValueType.create(null, whateverVariable, -2, 0, 'interr', 'intrinsics'), 'intrinsics'),
          [IterableValueType(ValueType.create(null, whateverVariable, -2, 0, 'interr', 'intrinsics'), 'intrinsics')], 'intrinsics'),
      'hex': FunctionValueType(stringType, [integerType], 'intrinsics'),
      'chr': FunctionValueType(stringType, [integerType], 'intrinsics'),
      'exit': FunctionValueType(nullType, [integerType], 'intrinsics'),
      'readFile': FunctionValueType(stringType, [stringType], 'intrinsics'),
      'readFileBytes': FunctionValueType(ListValueType(integerType, 'intrinsics'), [stringType], 'intrinsics'),
      'containsString': FunctionValueType(booleanType, [stringType, stringType], 'intrinsics'),
      'println': FunctionValueType(integerType, InfiniteIterable(anythingType), 'intrinsics'),
      'clear':
          FunctionValueType(integerType, [ListValueType(ValueType.create(null, whateverVariable, -2, 0, 'interr', 'intrinsics'), 'intrinsics')], 'intrinsics'),
      'debug': FunctionValueType(stringType, [rootClassType], 'intrinsics'),
      'throw': FunctionValueType(nullType, [stringType], 'intrinsics'),
      'cast': FunctionValueType(ValueType.create(null, whateverVariable, -2, 0, 'interr', 'intrinsics'), [anythingType], 'intrinsics'),
      'pop':
          FunctionValueType(anythingType, [ListValueType(ValueType.create(null, whateverVariable, -2, 0, 'interr', 'intrinsics'), 'intrinsics')], 'intrinsics'),
      'substring': FunctionValueType(stringType, [stringType, integerType, integerType], 'intrinsics'),
      'sublist': FunctionValueType(ListValueType(ValueType.create(null, whateverVariable, -2, 0, 'interr', 'intrinsics'), 'intrinsics'),
          [ListValueType(ValueType.create(null, whateverVariable, -2, 0, 'interr', 'intrinsics'), 'intrinsics'), integerType, integerType], 'intrinsics'),
      'stackTrace': FunctionValueType(stringType, [], 'intrinsics'),
      'debugName': FunctionValueType(stringType, [rootClassType], 'intrinsics'),
      'createStringBuffer': FunctionValueType(stringBufferType, [], 'intrinsics'),
      'writeStringBuffer': FunctionValueType(nullType, [stringBufferType, stringType], 'intrinsics'),
      'readStringBuffer': FunctionValueType(stringType, [stringBufferType], 'intrinsics'),
    }.map(
      (key, value) => MapEntry(
        variables[key] ??= Variable(key),
        TVProp(false, value, false /* none of them are methods */),
      ),
    );
  intrinsics.directVars.addAll(intrinsics.types.keys);

  TypeValidator validator = TypeValidator([intrinsics], ConcatenateLazyString(NotLazyString('file '), NotLazyString(file)), false, false, false, rtl);
  if (rtl != null) {
    validator.types.addAll(rtl.value.types);
    validator.classes.addAll(rtl.value.classes);
    validator.usedVars.addAll(rtl.value.usedVars);
  }
  List<Statement> ast = parseBlock(tokens, validator, false);
  if (isMain) {
    List<Variable> unusedGlobalscopeVars = validator.types.keys.where((element) => !validator.usedVars.contains(element)).toList();
    if (!unusedGlobalscopeVars.isEmpty) {
      stderr.writeln("Unused vars:\n  ${unusedGlobalscopeVars.map((e) => e.name).join('\n  ')}");
    }
    for (TypeValidator classTv in validator.classes.values) {
      List<Variable> unusedClassVars = classTv.types.keys
          .where((element) => !classTv.usedVars.contains(element) && !classTv.parents.any((element2) => element2.igv(element, false) != null))
          .toList();
      if (!unusedClassVars.isEmpty) {
        stderr.writeln("Unused vars for ${classTv.debugName}:\n  ${unusedClassVars.map((e) => e.name).join('\n  ')}");
      }
    }
  }
  return MapEntry(ast, validator);
}

WhileStatement parseWhile(TokenIterator tokens, TypeValidator scope) {
  tokens.moveNext();
  tokens.expectChar(TokenType.openParen);
  Expression value = parseExpression(tokens, scope);
  if (!value.type.isSubtypeOf(booleanType)) {
    throw BSCException(
      "The while condition ($value, a ${value.type}) is not a Boolean       ${formatCursorPositionFromTokens(tokens)}",
      scope,
    );
  }
  tokens.expectChar(TokenType.closeParen);
  tokens.expectChar(TokenType.openBrace);
  TypeValidator tv = TypeValidator([scope], NotLazyString('while loop'), false, false, false, scope.rtl);
  List<Statement> body = parseBlock(tokens, tv);
  List<String> unusedWhileLoopVars = tv.types.keys.where((element) => !tv.usedVars.contains(element)).map((e) => e.name).toList();
  if (!unusedWhileLoopVars.isEmpty) {
    stderr.writeln("Unused vars for while loop: ${formatCursorPositionFromTokens(tokens)}\n  ${unusedWhileLoopVars.join('\n  ')}");
  }
  tokens.expectChar(TokenType.closeBrace);
  return WhileStatement(
    value,
    body,
    tokens.current.line,
    tokens.current.col,
    tokens.workspace,
    tokens.file,
    'while',
    true,
  );
}

Map<String, MapEntry<List<Statement>, TypeValidator>> filesLoaded = {};
List<String> filesStartedLoading = [];
ImportStatement parseImport(TokenIterator tokens, TypeValidator scope) {
  if (tokens.doneImports) {
    throw BSCException(
      "cannot have import statement after non-import ${formatCursorPositionFromTokens(tokens)}",
      scope,
    );
  }
  tokens.moveNext();
  String str = tokens.string;
  if (filesStartedLoading.contains(str)) {
    throw BSCException(
      "Import loop detected at ${formatCursorPositionFromTokens(tokens)}",
      scope,
    );
  }
  filesStartedLoading.add(str);
  if (!File('${tokens.workspace}/$str').existsSync()) {
    throw BSCException("Attempted import of nonexistent file $str ${formatCursorPositionFromTokens(tokens)}", scope);
  }
  tokens.moveNext();
  tokens.expectChar(TokenType.endOfStatement);

  MapEntry<List<Statement>, TypeValidator> result = filesLoaded[str] ??
      (filesLoaded[str] = parse(lex(File('${tokens.workspace}/$str').readAsStringSync(), tokens.workspace, str), tokens.workspace, str, scope.rtl, false));
  loadedGlobalScopes[str] = result.value;
  filesStartedLoading.remove(str);
  scope.types.addAll(result.value.types);
  scope.classes.addAll(result.value.classes);
  scope.usedVars.addAll(result.value.usedVars);
  tokens.getPrevious();
  return ImportStatement(result.key, str, tokens.current.line, tokens.current.col, tokens.workspace, (tokens..moveNext()).file, scope);
}

class ValueTypePlaceholder {
  final ValueType? parent;
  final Variable name;
  final int line;
  final int col;
  final String workspace;
  final String file;
  ValueTypePlaceholder(this.parent, this.name, this.line, this.col, this.workspace, this.file);
  @override
  String toString() => 'VTP($name)';

  ValueType toVT() {
    return ValueType.create(parent, name, line, col, workspace, file);
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
      } else {
        stderr.writeln("Unknown comment feature: $feature ${formatCursorPositionFromTokens(tokens)}");
      }
      tokens.moveNext();
      commentFeature = true;
    } else {
      tokens.doneImports = true;
      return parseNonKeywordStatement(tokens, scope);
    }
  }
  if (tokens.current is! IdentToken) {
    tokens.getPrevious();
    tokens.doneImports = true;
    return parseNonKeywordStatement(tokens, scope);
  }
  switch (tokens.currentIdent) {
    case fwdclassVariable:
      if (overriden) {
        stderr.writeln('Can\'t override classes ${formatCursorPositionFromTokens(tokens)}');
      }
      tokens.moveNext();
      Variable cln = tokens.currentIdent;
      tokens.moveNext();
      List<ValueTypePlaceholder>? parameters;
      if (tokens.current is CharToken && tokens.currentChar != TokenType.endOfStatement) {
        parameters = parseArgList(tokens, (TokenIterator tokens) {
          ValueTypePlaceholder result = ValueTypePlaceholder(
            null,
            tokens.currentIdent,
            tokens.current.line,
            tokens.current.col,
            tokens.workspace,
            tokens.file,
          );
          tokens.moveNext();
          return result;
        });
      }
      ClassValueType? spt;
      TypeValidator props;
      if (tokens.current is IdentToken && tokens.currentIdent == variables['extends']) {
        spt =
            ValueType.create(null, (tokens..moveNext()).currentIdent, tokens.current.line, tokens.current.col, tokens.workspace, tokens.file) as ClassValueType;
        props = TypeValidator(
            [spt.properties], ConcatenateLazyString(NotLazyString('forward-declared subclass '), VariableLazyString(cln)), true, false, false, scope.rtl);
        tokens.moveNext();
      } else {
        props = TypeValidator(
            [scope], ConcatenateLazyString(NotLazyString('forward-declared root class '), VariableLazyString(cln)), true, false, false, scope.rtl);
      }
      ClassValueType x = ClassValueType(cln, spt, props, tokens.file, true);
      FunctionValueType? constructorType;
      if (parameters != null) {
        constructorType = FunctionValueType(nullType, parameters.map((e) => e.toVT()), tokens.file);
      }
      if (constructorType != null) {
        props.types[constructorVariable] = TVProp(true, constructorType, false);
      }
      spt?.subtypes.add(x);

      x.properties.types[thisVariable] = TVProp(true, x, false);
      scope.newVar(
        cln,
        (constructorType ?? spt?.properties.types[constructorVariable]?.type ?? FunctionValueType(nullType, [], tokens.file)).withReturnType(x, tokens.file),
        tokens.current.line,
        tokens.current.col,
        tokens.workspace,
        tokens.file,
        false,
        true,
      );
      if (ignoreUnused) {
        scope.igv(cln, true);
      }
      tokens.expectChar(TokenType.endOfStatement);
      scope.classes[cln] = x.properties;
      return NopStatement();
    case fwdclasspropVariable:
      ValueType type = ValueType.create(null, (tokens..moveNext()).currentIdent, tokens.current.line, tokens.current.col, tokens.workspace, tokens.file);
      ClassValueType cl =
          (ValueType.create(null, (tokens..moveNext()).currentIdent, tokens.current.line, tokens.current.col, tokens.workspace, tokens.file) as ClassValueType);
      tokens..moveNext();
      tokens.expectChar(TokenType.period);
      if (overriden) {
        stderr.writeln('fwdclassprops should never be defined as override ${formatCursorPositionFromTokens(tokens)}');
      }
      cl.properties.types[tokens.currentIdent] = TVProp(true, type, false);
      if (ignoreUnused) {
        cl.properties.igv(tokens.currentIdent, true);
      }
      for (ClassValueType cvt in cl.allDescendants) {
        cvt.properties.types[tokens.currentIdent] = TVProp(true, type, false);
        if (ignoreUnused) {
          cvt.properties.igv(tokens.currentIdent, true);
        }
      }
      tokens.moveNext();
      tokens.expectChar(TokenType.endOfStatement);
      return NopStatement();
    case fwdstaticpropVariable:
      ValueType type = ValueType.create(null, (tokens..moveNext()).currentIdent, tokens.current.line, tokens.current.col, tokens.workspace, tokens.file);
      ClassValueType cl =
          (ValueType.create(null, (tokens..moveNext()).currentIdent, tokens.current.line, tokens.current.col, tokens.workspace, tokens.file) as ClassValueType);
      tokens..moveNext();
      tokens.expectChar(TokenType.period);
      if (overriden) {
        stderr.writeln('fwdstaticprops should never be defined as override ${formatCursorPositionFromTokens(tokens)}');
      }
      cl.properties.types[tokens.currentIdent] = TVProp(true, type, false);
      if (ignoreUnused) {
        cl.properties.igv(tokens.currentIdent, true);
      }
      for (ClassValueType cvt in cl.allDescendants) {
        cvt.properties.types[tokens.currentIdent] = TVProp(true, type, false);
        if (ignoreUnused) {
          cvt.properties.igv(tokens.currentIdent, true);
        }
      }
      tokens.moveNext();
      tokens.expectChar(TokenType.endOfStatement);
      return NopStatement();
    case classVariable:
      if (overriden) {
        stderr.writeln('Can\'t override classes ${formatCursorPositionFromTokens(tokens)}');
      }
      return parseClass(tokens, scope, ignoreUnused);
    case namespaceVariable:
      if (overriden) {
        stderr.writeln('Can\'t override namespaces ${formatCursorPositionFromTokens(tokens)}');
      }
      if (ignoreUnused) {
        stderr.writeln('What does that even mean (look at this and previous line) ${formatCursorPositionFromTokens(tokens)}');
      }
      return parseNamespace(tokens, scope);
    case importVariable:
      if (overriden) {
        stderr.writeln('Overriding an import makes no sense, like, what does that mean ${formatCursorPositionFromTokens(tokens)}');
      }
      if (ignoreUnused) {
        stderr.writeln('Instead of this, ignore_unused on all the unused components of the library ${formatCursorPositionFromTokens(tokens)}');
      }
      return parseImport(tokens, scope);
    case whileVariable:
      tokens.doneImports = true;
      if (overriden) {
        stderr.writeln('Can\'t override whiles ${formatCursorPositionFromTokens(tokens)}');
      }
      if (ignoreUnused) {
        stderr.writeln('What does that even mean for a while loop (look at this and previous line) ${formatCursorPositionFromTokens(tokens)}');
      }
      return parseWhile(tokens, scope);
    case breakVariable:
      if (overriden) {
        stderr.writeln('Can\'t override breaks ${formatCursorPositionFromTokens(tokens)}');
      }
      if (ignoreUnused) {
        stderr.writeln('What does that even mean for a break statement (look at this and previous line) ${formatCursorPositionFromTokens(tokens)}');
      }
      tokens.doneImports = true;
      return BreakStatement.parse(tokens, scope);
    case continueVariable:
      tokens.doneImports = true;
      if (overriden) {
        stderr.writeln('Can\'t override continues ${formatCursorPositionFromTokens(tokens)}');
      }
      if (ignoreUnused) {
        stderr.writeln('What does that even mean for a continue statement (look at this and previous line) ${formatCursorPositionFromTokens(tokens)}');
      }
      return ContinueStatement.parse(tokens, scope);
    case returnVariable:
      tokens.doneImports = true;
      if (overriden) {
        stderr.writeln('Can\'t override returns ${formatCursorPositionFromTokens(tokens)}');
      }
      if (ignoreUnused) {
        stderr.writeln('What does that even mean for a return statement (look at this and previous line) ${formatCursorPositionFromTokens(tokens)}');
      }
      return ReturnStatement.parse(tokens, scope);
    case ifVariable:
      tokens.doneImports = true;
      if (overriden) {
        stderr.writeln('Can\'t override if statements ${formatCursorPositionFromTokens(tokens)}');
      }
      if (ignoreUnused) {
        stderr.writeln('What does that even mean for a if statement (look at this and previous line) ${formatCursorPositionFromTokens(tokens)}');
      }
      return parseIf(tokens, scope);
    case enumVariable:
      if (overriden) {
        stderr.writeln('Can\'t override enums ${formatCursorPositionFromTokens(tokens)}');
      }
      if (ignoreUnused) {
        stderr.writeln('why do you not need every value of an enum ${formatCursorPositionFromTokens(tokens)}');
      }
      tokens.doneImports = true;
      return parseEnum(tokens, scope);
    case forVariable:
      tokens.doneImports = true;
      if (overriden) {
        stderr.writeln('Can\'t override fors ${formatCursorPositionFromTokens(tokens)}');
      }
      return parseForIn(tokens, scope, ignoreUnused);
    case constVariable:
      tokens.doneImports = true;

      if (overriden) {
        stderr.writeln('Can\'t override consts ${formatCursorPositionFromTokens(tokens)}');
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
  if (tokens.current is IdentToken && tokens.currentIdent == variables['static']) {
    tokens.moveNext();
    static = true;
  }
  ValueType type = ValueType.create(null, tokens.currentIdent, tokens.current.line, tokens.current.col, tokens.workspace, tokens.file);
  tokens.moveNext();
  Variable name = tokens.currentIdent;
  tokens.moveNext();
  tokens.expectChar(TokenType.set);
  Expression expr = parseExpression(
    tokens,
    scope,
  );
  if (!expr.type.isSubtypeOf(type)) {
    throw BSCException("attempted to assign $expr (a ${expr.type}) to $name, which is a const $type ${formatCursorPositionFromTokens(tokens)}", scope);
  }
  tokens.expectChar(TokenType.endOfStatement);
  if (!static) scope.types[name] = TVProp(false, type, false);
  if (ignoreUnused) {
    scope.igv(name, true);
    tokens.moveNext();
  }
  if (static) {
    return StaticFieldStatement(name, expr, tokens.current.line, tokens.current.col, true);
  }
  return NewVarStatement(name, expr, tokens.current.line, tokens.current.col, tokens.workspace, tokens.file, true, type);
}

Statement parseNamespace(TokenIterator tokens, TypeValidator scope) {
  tokens.moveNext();
  tokens.expectChar(TokenType.openParen);
  Variable namespace = tokens.currentIdent;
  tokens.moveNext();
  tokens.expectChar(TokenType.closeParen);
  TypeValidator innerScope = NamespaceTypeValidator(scope, namespace, scope.rtl);
  tokens.expectChar(TokenType.openBrace);
  List<Statement> body = parseBlock(tokens, innerScope);
  List<Variable> unusedNamespaceVars = innerScope.types.keys.where((element) => !innerScope.usedVars.contains(element)).toList();
  if (!unusedNamespaceVars.isEmpty) {
    stderr.writeln("Unused vars for namespace: ${formatCursorPositionFromTokens(tokens)}\n  ${unusedNamespaceVars.join('\n  ')}");
  }
  tokens.expectChar(TokenType.closeBrace);
  return NamespaceStatement(
    body,
    tokens.current.line,
    tokens.current.col,
    tokens.workspace,
    tokens.file,
    namespace,
  );
}

Statement parseForIn(TokenIterator tokens, TypeValidator scope, bool ignoreUnused) {
  tokens.moveNext();
  tokens.expectChar(TokenType.openParen);
  Variable currentName = tokens.currentIdent;
  tokens.moveNext();
  if (tokens.currentIdent != (variables['in'] ??= Variable('in'))) {
    throw BSCException("no 'in' after name of new variable in the for loop ${formatCursorPositionFromTokens(tokens)}", scope);
  }
  tokens.moveNext();
  Expression iterable = parseExpression(
    tokens,
    scope,
  );
  if (!iterable.type.isSubtypeOf(ValueType.create(
      null, variables["WhateverIterable"] ??= Variable("WhateverIterable"), tokens.current.line, tokens.current.col, tokens.workspace, tokens.file))) {
    throw BSCException("tried to for loop over non-iterable (iterated over ${iterable.type}) ${formatCursorPositionFromTokens(tokens)}", scope);
  }
  TypeValidator innerScope = TypeValidator([scope], NotLazyString('for loop'), false, false, false, scope.rtl);
  innerScope.newVar(
    currentName,
    iterable.type is IterableValueType ? (iterable.type as IterableValueType).genericParameter : anythingType,
    tokens.current.line,
    tokens.current.col,
    tokens.workspace,
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
    stderr.writeln("Unused vars for for loop: ${formatCursorPositionFromTokens(tokens)}\n  ${unusedForLoopVars.join('\n  ')}");
  }
  tokens.expectChar(TokenType.closeBrace);
  return ForStatement(
    iterable,
    body,
    tokens.current.line,
    tokens.current.col,
    currentName,
    tokens.workspace,
    tokens.file,
  );
}

Statement parseEnum(TokenIterator tokens, TypeValidator scope) {
  tokens.moveNext();
  Variable name = tokens.currentIdent;
  tokens.moveNext();
  List<Variable> body = [];
  TypeValidator tv = TypeValidator([], ConcatenateLazyString(VariableLazyString(name), NotLazyString('-enum')), false, false, false, scope.rtl);
  EnumPropertyValueType propType = EnumPropertyValueType(
    name,
    tokens.file,
  );
  EnumValueType type = EnumValueType(name, tv, tokens.file, propType);
  tokens.expectChar(TokenType.openBrace);
  while (tokens.current is! CharToken || tokens.currentChar != TokenType.closeBrace) {
    tv.newVar(
      tokens.currentIdent,
      propType,
      tokens.current.line,
      tokens.current.col,
      tokens.workspace,
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
    tokens.workspace,
    tokens.file,
  );
  return EnumStatement(
    name,
    body,
    type,
    tokens.current.line,
    tokens.current.col,
    tokens.workspace,
    tokens.file,
  );
}

int elseN = 0;

IfStatement parseIf(TokenIterator tokens, TypeValidator scope) {
  tokens.moveNext();
  tokens.expectChar(TokenType.openParen);
  Expression value = parseExpression(tokens, scope);
  if (!value.type.isSubtypeOf(booleanType)) {
    throw BSCException(
      "The if condition ($value, a ${value.type}) is not a Boolean        ${formatCursorPositionFromTokens(tokens)}",
      scope,
    );
  }
  tokens.expectChar(TokenType.closeParen);
  tokens.expectChar(TokenType.openBrace);
  TypeValidator innerScope = TypeValidator([scope], NotLazyString('if statement'), false, false, false, scope.rtl);
  List<Statement> body = parseBlock(tokens, innerScope);
  List<String> unusedForLoopVars = innerScope.types.keys.where((element) => !innerScope.usedVars.contains(element)).map((e) => e.name).toList();
  if (!unusedForLoopVars.isEmpty) {
    stderr.writeln("Unused vars for if statement: ${formatCursorPositionFromTokens(tokens)}\n  ${unusedForLoopVars.join('\n  ')}");
  }
  List<Statement> elseBody = [];
  tokens.expectChar(TokenType.closeBrace);
  if (tokens.current is IdentToken && tokens.currentIdent == variables["else"]) {
    tokens.moveNext();
    if (tokens.current is IdentToken && tokens.currentIdent == variables["if"]) {
      IfStatement parsedIf = parseIf(tokens, scope);
      elseBody = [parsedIf];
    } else {
      tokens.expectChar(TokenType.openBrace);
      elseBody = parseBlock(tokens, TypeValidator([scope], NotLazyString('if statement - else block'), false, false, false, scope.rtl));
      tokens.expectChar(TokenType.closeBrace);
    }
  }
  return IfStatement(
    value,
    body,
    elseBody,
    tokens.current.line,
    tokens.current.col,
    tokens.workspace,
    tokens.file,
  );
}
