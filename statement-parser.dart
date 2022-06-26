import 'statements.dart';
import 'lexer.dart';
import 'parser-core.dart';
import 'expressions.dart';
import 'expression-parser.dart';
import 'dart:io'; // for parse()

List<Statement> parseBlock(TokenIterator tokens, TypeValidator scope,
    [bool acceptCB = true]) {
  List<Statement> block = [];
  while (tokens.current is! CharToken ||
      ((tokens.current as CharToken).type != TokenType.endOfFile &&
          ((tokens.current as CharToken).type != TokenType.closeBrace ||
              !acceptCB))) {
    block.add(parseStatement(tokens, scope));
  }
  return block;
}

ClassStatement parseClass(TokenIterator tokens, TypeValidator scope) {
  tokens.moveNext();
  String name = tokens.currentIdent;
  tokens.moveNext();
  String? superclass;
  if (tokens.current is IdentToken && tokens.currentIdent == 'extends') {
    tokens.moveNext();
    superclass = tokens.currentIdent;
    scope.getVar(superclass, 0, tokens.current.line, tokens.current.col,
        tokens.workspace, tokens.file, 'for subclassing');
    tokens.moveNext();
  }
  tokens.expectChar(TokenType.openBrace);
  ValueType? supertype = superclass == null
      ? null
      : ValueType(
          null,
          superclass,
          tokens.current.line,
          tokens.current.col,
          tokens.workspace,
          tokens.file,
        );
  if (superclass != null && !scope.classes.containsKey(superclass)) {
    throw FileInvalid(
        "$superclass nonexistent while trying to have $name extend it. ${formatCursorPositionFromTokens(tokens)}");
  }
  TypeValidator newScope = superclass == null
      ? (TypeValidator(scope))
      : (TypeValidator(scope)
        ..types.addAll(Map.of(scope.classes[superclass]!.types))
        ..nonconst.addAll(List.of(scope.classes[superclass]!.nonconst)));
  ClassValueType type =
      ClassValueType(name, supertype as ClassValueType?, newScope, tokens.file);
  if (newScope != type.properties) {
    if (supertype != type.parent) {
      throw FileInvalid(
          "$name does not have the same supertype ($supertype) as forward declaration (${type.parent}) ${formatCursorPositionFromTokens(tokens)}");
    }
  }
  TypeValidator fwdProps = type.properties.copy();
  bool hasFwdDecl = newScope != type.properties;
  newScope = type.properties
    ..types.addAll(scope.types)
    ..nonconst.addAll(scope.nonconst)
    ..types.addAll(supertype?.properties.types ?? {})
    ..nonconst.addAll(supertype?.properties.nonconst ?? []);
  newScope.newVar(
    'this',
    type,
    tokens.current.line,
    tokens.current.col,
    tokens.workspace,
    tokens.file,
  );

  List<Statement> block = parseBlock(tokens, newScope);
  if (!hasFwdDecl) {
    if (supertype != null) {
      for (MapEntry<String, ValueType> property in newScope.types.entries) {
        if (!property.value.isSubtypeOf(
                supertype.properties.types[property.key] ?? sharedSupertype) &&
            property.key != 'constructor') {
          throw FileInvalid(
              "$name type has invalid override of $superclass.${property.key} (expected ${supertype.properties.types[property.key]}, got ${property.value} ${formatCursorPositionFromTokens(tokens)}");
        }
      }
    }
  }
  if (hasFwdDecl)
    for (MapEntry<String, ValueType> value in fwdProps.types.entries) {
      if (newScope.types[value.key] != value.value) {
        if (value.value is GenericFunctionValueType &&
            newScope.types[value.key] is FunctionValueType &&
            (newScope.types[value.key] as GenericFunctionValueType)
                    .returnType ==
                (value.value as GenericFunctionValueType).returnType) {
          continue;
        }
        throw FileInvalid(
            "$name.${value.key} (a ${newScope.types[value.key]}) does not match forward declaration (a ${value.value}) ${formatCursorPositionFromTokens(tokens)}");
      }
    }
  scope.classes[name] = newScope;
  scope.newVar(
    name,
    type.recursiveLookup('constructor') is FunctionValueType?
        ? FunctionValueType(
            type,
            (type.recursiveLookup('constructor') as FunctionValueType?)
                    ?.parameters ??
                [],
            tokens.file)
        : GenericFunctionValueType(type, tokens.file),
    tokens.current.line,
    tokens.current.col,
    tokens.workspace,
    tokens.file,
  );
  tokens.expectChar(TokenType.closeBrace);
  return ClassStatement(name, superclass, block, type, tokens.current.line,
      tokens.current.col, tokens.workspace, tokens.file);
}

Statement parseNonKeywordStatement(TokenIterator tokens, TypeValidator scope) {
  do {
    if (tokens.current is IdentToken) {
      String ident1 = tokens.currentIdent;
      tokens.moveNext();
      List<Expression> subscripts = [];
      while (tokens.current is CharToken &&
          tokens.currentChar == TokenType.openSquare) {
        tokens.moveNext();
        Expression expr = parseExpression(tokens, scope);
        if (!expr.type.isSubtypeOf(integerType)) {
          throw FileInvalid(
            "attempted $ident1${subscripts.map((e) => '[$e]')}[$expr] but $expr was not an integer ${formatCursorPositionFromTokens(tokens)}",
          );
        }
        subscripts.add(expr);
        tokens.expectChar(TokenType.closeSquare);
      }
      if (tokens.current is CharToken) {
        if (tokens.currentChar == TokenType.plus) {
          tokens.expectChar(TokenType.plus);
          if (!scope
              .getVar(
                ident1,
                subscripts.length,
                tokens.current.line,
                tokens.current.col,
                tokens.workspace,
                tokens.file,
                'plus-equals or plus-plus',
              )
              .isSubtypeOf(integerType)) {
            throw FileInvalid(
                "Attempted $ident1 (not an integer!) +... ${formatCursorPositionFromTokens(tokens)}");
          }

          if (tokens.currentChar == TokenType.set) {
            tokens.moveNext();
            Expression value = parseExpression(tokens, scope);
            if (!value.type.isSubtypeOf(integerType)) {
              throw FileInvalid(
                "attempted $ident1+=$value but $value was not an integer ${formatCursorPositionFromTokens(tokens)}",
              );
            }
            tokens.expectChar(TokenType.endOfStatement);
            return SetStatement(
              ident1,
              AddExpression(
                subscriptsToExpr(ident1, subscripts, tokens.current.line,
                    tokens.current.col, tokens.workspace, tokens.file, scope),
                value,
                tokens.current.line,
                tokens.current.col,
                tokens.workspace,
                tokens.file,
              ),
              subscripts,
              tokens.current.line,
              tokens.current.col,
              tokens.workspace,
              tokens.file,
            );
          }
          tokens.expectChar(TokenType.plus);
          tokens.expectChar(TokenType.endOfStatement);
          return SetStatement(
            ident1,
            AddExpression(
              GetExpr(ident1, scope, tokens.current.line, tokens.current.col,
                  tokens.workspace, tokens.file),
              IntLiteralExpression(1, tokens.current.line, tokens.current.col,
                  tokens.workspace, tokens.file),
              tokens.current.line,
              tokens.current.col,
              tokens.workspace,
              tokens.file,
            ),
            subscripts,
            tokens.current.line,
            tokens.current.col,
            tokens.workspace,
            tokens.file,
          );
        }
        if (tokens.currentChar == TokenType.minus) {
          tokens.expectChar(TokenType.minus);
          if (!scope
              .getVar(ident1, subscripts.length, tokens.current.line,
                  tokens.current.col, tokens.workspace, tokens.file, '-= or --')
              .isSubtypeOf(integerType)) {
            throw FileInvalid(
                "Attempted $ident1 (not an integer!) -... ${formatCursorPositionFromTokens(tokens)}");
          }
          if (tokens.currentChar == TokenType.set) {
            tokens.moveNext();
            Expression value = parseExpression(tokens, scope);
            if (!value.type.isSubtypeOf(integerType)) {
              throw FileInvalid(
                "attempted $ident1-=$value but $value was not an integer ${formatCursorPositionFromTokens(tokens)}",
              );
            }
            tokens.expectChar(TokenType.endOfStatement);
            return SetStatement(
              ident1,
              SubtractExpression(
                subscriptsToExpr(ident1, subscripts, tokens.current.line,
                    tokens.current.col, tokens.workspace, tokens.file, scope),
                value,
                tokens.current.line,
                tokens.current.col,
                tokens.workspace,
                tokens.file,
              ),
              subscripts,
              tokens.current.line,
              tokens.current.col,
              tokens.workspace,
              tokens.file,
            );
          }
          tokens.expectChar(TokenType.minus);
          tokens.expectChar(TokenType.endOfStatement);
          return SetStatement(
            ident1,
            SubtractExpression(
              GetExpr(
                ident1,
                scope,
                tokens.current.line,
                tokens.current.col,
                tokens.workspace,
                tokens.file,
              ),
              IntLiteralExpression(1, tokens.current.line, tokens.current.col,
                  tokens.workspace, tokens.file),
              tokens.current.line,
              tokens.current.col,
              tokens.workspace,
              tokens.file,
            ),
            subscripts,
            tokens.current.line,
            tokens.current.col,
            tokens.workspace,
            tokens.file,
          );
        }
        if (tokens.currentChar == TokenType.set) {
          tokens.expectChar(TokenType.set);
          Expression expr = parseExpression(tokens, scope);
          tokens.expectChar(TokenType.endOfStatement);
          scope.setVar(
            ident1,
            subscripts.length,
            expr.type,
            tokens.current.line,
            tokens.current.col,
            tokens.workspace,
            tokens.file,
          );
          return SetStatement(
            ident1,
            expr,
            subscripts,
            tokens.current.line,
            tokens.current.col,
            tokens.workspace,
            tokens.file,
          );
        }
        tokens.getPrevious();
        break;
      }
      String ident2 = tokens.currentIdent;
      tokens.moveNext();
      if (tokens.currentChar == TokenType.set) {
        tokens.expectChar(TokenType.set);
        Expression expr = parseExpression(tokens, scope);
        if (!expr.type.isSubtypeOf(
          ValueType(
            null,
            ident1,
            tokens.current.line,
            tokens.current.col,
            tokens.workspace,
            tokens.file,
          ),
        )) {
          throw FileInvalid(
              "$expr is not of type $ident1, which is expected by $ident2. (it's a ${expr.type}) ${formatCursorPositionFromTokens(tokens)}");
        }
        scope.newVar(
          ident2,
          ValueType(null, ident1, tokens.current.line, tokens.current.col,
              tokens.workspace, tokens.file),
          tokens.current.line,
          tokens.current.col,
          tokens.workspace,
          tokens.file,
        );
        if (subscripts.isNotEmpty) {
          throw FileInvalid(
              "type $ident1${subscripts.map((e) => '[$e]')} contains square brackets ${formatCursorPositionFromTokens(tokens)}");
        }
        tokens.expectChar(TokenType.endOfStatement);
        return NewVarStatement(
          ident2,
          expr,
          tokens.current.line,
          tokens.current.col,
        );
      }
      if (tokens.currentChar == TokenType.endOfStatement) {
        tokens.expectChar(TokenType.endOfStatement);
        scope.newVar(
          ident2,
          ValueType(
            null,
            ident1,
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
        if (subscripts.isNotEmpty) {
          throw FileInvalid(
              "type $ident1${subscripts.map((e) => '[$e]')} contains square brackets ${formatCursorPositionFromTokens(tokens)}");
        }
        return NewVarStatement(
          ident2,
          null,
          tokens.current.line,
          tokens.current.col,
        );
      }
      bool isVararg = false;
      bool isNormal = false;
      Iterable<Parameter> params = parseArgList(tokens, (TokenIterator tokens) {
        String type = tokens.currentIdent;
        tokens.moveNext();
        if (tokens.current is CharToken &&
            tokens.currentChar == TokenType.ellipsis) {
          tokens.moveNext();
          if (isVararg) {
            throw FileInvalid(
                "$ident2 had 2 varargs ${formatCursorPositionFromTokens(tokens)}");
          }
          if (isNormal) {
            throw FileInvalid(
                "$ident2 had regular arguments before a vararg ${formatCursorPositionFromTokens(tokens)}");
          }
          isVararg = true;
        } else {
          isNormal = true;
        }
        String name = tokens.currentIdent;
        tokens.moveNext();
        return Parameter(
            ValueType(
              null,
              type,
              tokens.current.line,
              tokens.current.col,
              tokens.workspace,
              tokens.file,
            ),
            name);
      });
      if (isVararg && params.length > 1) {
        throw FileInvalid(
            "$ident2 had ${params.length - 1} regular arguments and a vararg ${formatCursorPositionFromTokens(tokens)}");
      }
      if (isVararg) {
        params = InfiniteIterable(params.single);
      }
      tokens.expectChar(TokenType.openBrace);
      Iterable<ValueType> typeParams = isVararg
          ? InfiniteIterable(params.first.type)
          : params.map((e) => e.type);
      TypeValidator tv = TypeValidator(scope)
        ..types.addAll(scope.types)
        ..nonconst.addAll(scope.nonconst)
        ..types.addAll(isVararg
            ? {params.first.name: ListValueType(params.first.type, 'internal')}
            : Map.fromEntries(params.map((e) => MapEntry(e.name, e.type))))
        ..types[ident2] = FunctionValueType(
          ValueType(
            null,
            ident1,
            tokens.current.line,
            tokens.current.col,
            tokens.workspace,
            tokens.file,
          ),
          typeParams,
          tokens.file,
        );
      List<Statement> body = parseBlock(tokens, tv);
      tokens.expectChar(TokenType.closeBrace);
      scope.newVar(
        ident2,
        FunctionValueType(
            ValueType(null, ident1, tokens.current.line, tokens.current.col,
                tokens.workspace, tokens.file),
            typeParams,
            tokens.file),
        tokens.current.line,
        tokens.current.col,
        tokens.workspace,
        tokens.file,
        true,
      );
      return FunctionStatement(
        ValueType(null, ident1, tokens.current.line, tokens.current.col,
            tokens.workspace, tokens.file),
        ident2,
        params,
        body,
        tokens.current.line,
        tokens.current.col,
        tokens.workspace,
        tokens.file,
      );
    }
  } while (false);
  Expression expr = parseExpression(tokens, scope);
  tokens.expectChar(TokenType.endOfStatement);
  return ExpressionStatement(expr, tokens.current.line, tokens.current.col);
}

Expression subscriptsToExpr(String ident1, List<Expression> subscripts,
    int line, int col, String workspace, String file, TypeValidator validator) {
  return subscripts.length > 0
      ? SubscriptExpression(
          subscriptsToExpr(ident1, subscripts.toList()..removeLast(), line, col,
              workspace, file, validator),
          subscripts.last,
          line,
          col,
          workspace,
          file)
      : GetExpr(ident1, validator, line, col, workspace, file);
}

MapEntry<List<Statement>, TypeValidator> parse(
    Iterable<Token> rtokens, String workspace, String file, bool isRtl) {
  TokenIterator tokens = TokenIterator(
      (isRtl
              ? <Token>[]
              : [
                  IdentToken('import', -1, 6),
                  StringToken(
                      ('../' * workspace.allMatches('/').length) + 'rtl.syd',
                      -1,
                      19),
                  CharToken(TokenType.endOfStatement, -1, 20)
                ])
          .followedBy(rtokens)
          .iterator,
      workspace,
      file);

  tokens.moveNext();
  TypeValidator validator = TypeValidator(null);

  List<Statement> ast = parseBlock(tokens, validator, false);
  if (file == 'syd.syd') {
    List<String> unusedGlobalscopeVars = validator.types.keys
        .where((element) =>
            !validator.usedVars.contains(element) &&
            !TypeValidator(null).types.containsKey(element))
        .toList();
    if (!unusedGlobalscopeVars.isEmpty) {
      stderr.writeln("Unused vars:\n  ${unusedGlobalscopeVars.join('\n  ')}");
    }
  }
  return MapEntry(ast, validator);
}

WhileStatement parseWhile(TokenIterator tokens, TypeValidator scope) {
  tokens.moveNext();
  tokens.expectChar(TokenType.openParen);
  Expression value = parseExpression(tokens, scope);
  if (!value.type.isSubtypeOf(booleanType)) {
    throw FileInvalid(
      "The while condition ($value, a ${value.type}) is not a Boolean       ${formatCursorPositionFromTokens(tokens)}",
    );
  }
  tokens.expectChar(TokenType.closeParen);
  tokens.expectChar(TokenType.openBrace);
  List<Statement> body = parseBlock(
      tokens,
      TypeValidator(scope)
        ..types = scope.types
        ..nonconst = scope.nonconst);
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
    throw FileInvalid(
      "cannot have import statement after non-import ${formatCursorPositionFromTokens(tokens)}",
    );
  }
  tokens.moveNext();
  String str = tokens.string;
  if (filesStartedLoading.contains(str)) {
    throw FileInvalid(
      "Import loop detected at ${formatCursorPositionFromTokens(tokens)}",
    );
  }
  filesStartedLoading.add(str);
  if (!File('${tokens.workspace}/$str').existsSync()) {
    throw FileInvalid(
        "Attempted import of nonexistent file $str ${formatCursorPositionFromTokens(tokens)}");
  }
  tokens.moveNext();
  tokens.expectChar(TokenType.endOfStatement);

  MapEntry<List<Statement>, TypeValidator> result = filesLoaded[str] ??
      (filesLoaded[str] = parse(
          lex(File('${tokens.workspace}/$str').readAsStringSync(),
              tokens.workspace, str),
          tokens.workspace,
          str,
          str.contains('rtl.syd')));
  loadedGlobalScopes[str] = result.value;
  filesStartedLoading.remove(str);
  scope.types.addAll(result.value.types);
  scope.classes.addAll(result.value.classes);
  scope.usedVars.addAll(result.value.usedVars);
  tokens.getPrevious();
  return ImportStatement(result.key, str, tokens.current.line,
      tokens.current.col, tokens.workspace, (tokens..moveNext()).file);
}

Statement parseStatement(TokenIterator tokens, TypeValidator scope) {
  if (tokens.current is! IdentToken) {
    tokens.doneImports = true;
    return parseNonKeywordStatement(tokens, scope);
  }
  switch (tokens.currentIdent) {
    case 'fwdclass':
      tokens.moveNext();
      String cln = tokens.currentIdent;
      tokens.moveNext();
      FunctionValueType? constructorType;
      if (tokens.current is CharToken) {
        List<ValueType> parameters =
            parseArgList(tokens, (TokenIterator tokens) {
          ValueType result = ValueType(
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
        constructorType = FunctionValueType(nullType, parameters, tokens.file);
      }
      if (tokens.currentIdent != 'extends') {
        throw FileInvalid(
            "Invalid fwdclass: expected 'extends' got ${tokens.currentIdent} ${formatCursorPositionFromTokens(tokens)}");
      }
      ClassValueType spt = ValueType(
          null,
          (tokens..moveNext()).currentIdent,
          tokens.current.line,
          tokens.current.col,
          tokens.workspace,
          tokens.file) as ClassValueType;
      TypeValidator props = TypeValidator(scope)
        ..types.addAll(spt.properties.types)
        ..usedVars.addAll(spt.properties.usedVars)
        ..nonconst.addAll(spt.properties.nonconst);
      if (constructorType != null) {
        props.types['constructor'] = constructorType;
      }
      ClassValueType x = ClassValueType(cln, spt, props, tokens.file);
      spt.subtypes.add(x);
      x.properties.types['this'] = x;
      scope.types[cln] =
          (constructorType ?? spt.properties.types['constructor']!)
              .withReturnType(x, tokens.file);
      tokens.moveNext();
      tokens.expectChar(TokenType.endOfStatement);
      scope.classes[cln] = x.properties;
      return NopStatement();
    case 'fwdclassprop':
      ValueType type = ValueType(
          null,
          (tokens..moveNext()).currentIdent,
          tokens.current.line,
          tokens.current.col,
          tokens.workspace,
          tokens.file);
      ClassValueType cl = (ValueType(
          null,
          (tokens..moveNext()).currentIdent,
          tokens.current.line,
          tokens.current.col,
          tokens.workspace,
          tokens.file) as ClassValueType);
      tokens.moveNext();
      tokens.expectChar(TokenType.period);
      cl.properties.types[tokens.currentIdent] = type;
      for (ClassValueType cvt in cl.allDescendants) {
        cvt.properties.types[tokens.currentIdent] = type;
      }
      tokens.moveNext();
      tokens.expectChar(TokenType.endOfStatement);
      return NopStatement();
    case 'class':
      return parseClass(tokens, scope);
    case 'import':
      return parseImport(tokens, scope);
    case "while":
      tokens.doneImports = true;
      return parseWhile(tokens, scope);
    case "break":
      tokens.doneImports = true;
      return BreakStatement.parse(tokens, scope);
    case "continue":
      tokens.doneImports = true;
      return ContinueStatement.parse(tokens, scope);
    case "return":
      tokens.doneImports = true;
      return ReturnStatement.parse(tokens, scope);
    case "if":
      tokens.doneImports = true;
      return parseIf(tokens, scope);
    case "enum":
      tokens.doneImports = true;
      return parseEnum(tokens, scope);
    case 'for':
      tokens.doneImports = true;
      return parseForIn(tokens, scope);
    case 'const':
      tokens.doneImports = true;
      return parseConst(tokens, scope);
    default:
      tokens.doneImports = true;
      return parseNonKeywordStatement(tokens, scope);
  }
}

Statement parseConst(TokenIterator tokens, TypeValidator scope) {
  tokens.moveNext();
  ValueType type = ValueType(null, tokens.currentIdent, tokens.current.line,
      tokens.current.col, tokens.workspace, tokens.file);
  tokens.moveNext();
  String name = tokens.currentIdent;
  tokens.moveNext();
  tokens.expectChar(TokenType.set);
  Expression expr = parseExpression(
    tokens,
    scope,
  );
  if (!expr.type.isSubtypeOf(type)) {
    throw FileInvalid(
        "attempted to assign $expr (a ${expr.type}) to $name, which is a const $type ${formatCursorPositionFromTokens(tokens)}");
  }
  tokens.expectChar(TokenType.endOfStatement);
  scope.types[name] = type;
  return NewVarStatement(name, expr, tokens.current.line, tokens.current.col);
}

class NopStatement extends Statement {
  NopStatement() : super(-2, 0);

  @override
  StatementResult run(Scope scope) {
    // it's a NOP
    return StatementResult(StatementResultType.nothing);
  }
}

Statement parseForIn(TokenIterator tokens, TypeValidator scope) {
  tokens.moveNext();
  tokens.expectChar(TokenType.openParen);
  String currentName = tokens.currentIdent;
  tokens.moveNext();
  if (tokens.currentIdent != 'in') {
    throw FileInvalid(
        "no 'in' after name of new variable in the for loop ${formatCursorPositionFromTokens(tokens)}");
  }
  tokens.moveNext();
  Expression iterable = parseExpression(
    tokens,
    scope,
  );
  if (!iterable.type.isSubtypeOf(ValueType(
      null,
      "WhateverIterable",
      tokens.current.line,
      tokens.current.col,
      tokens.workspace,
      tokens.file))) {
    throw FileInvalid(
        "tried to for loop over non-iterable (iterated over ${iterable.type}) ${formatCursorPositionFromTokens(tokens)}");
  }
  TypeValidator innerScope = TypeValidator(scope)
    ..types.addAll(scope.types)
    ..nonconst.addAll(scope.nonconst);
  innerScope.newVar(
    currentName,
    iterable.type is IterableValueType
        ? (iterable.type as IterableValueType).genericParameter
        : sharedSupertype,
    tokens.current.line,
    tokens.current.col,
    tokens.workspace,
    tokens.file,
  );
  tokens.expectChar(TokenType.closeParen);
  tokens.expectChar(TokenType.openBrace);
  List<Statement> body = parseBlock(tokens, innerScope);
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
  String name = tokens.currentIdent;
  tokens.moveNext();
  List<Statement> body = [];
  ValueType.internal(sharedSupertype, name, tokens.file); //declaring type
  tokens.expectChar(TokenType.openBrace);
  while (tokens.current is! CharToken ||
      tokens.currentChar != TokenType.closeBrace) {
    scope.newVar(
      name + tokens.currentIdent,
      ValueType(sharedSupertype, name, tokens.current.line, tokens.current.col,
          tokens.workspace, tokens.file),
      tokens.current.line,
      tokens.current.col,
      tokens.workspace,
      tokens.file,
    );
    body.add(
      SetStatement(
          name + tokens.currentIdent,
          BoringExpr(
              name + tokens.currentIdent,
              ValueType(
                sharedSupertype,
                name,
                tokens.current.line,
                tokens.current.col,
                tokens.workspace,
                tokens.file,
              )),
          [],
          -2,
          0,
          tokens.workspace,
          'todox'),
    );
    tokens.moveNext();
  }
  tokens.moveNext();
  body.add(BreakStatement(
    false,
    -2,
    0,
  ));
  return WhileStatement(
    BoringExpr(true, booleanType),
    body,
    -2,
    0,
    tokens.file,
    tokens.workspace,
    'enum',
    true,
    false,
  );
}

int elseN = 0;

IfStatement parseIf(TokenIterator tokens, TypeValidator scope) {
  tokens.moveNext();
  tokens.expectChar(TokenType.openParen);
  Expression value = parseExpression(tokens, scope);
  if (!value.type.isSubtypeOf(booleanType)) {
    throw FileInvalid(
      "The if condition ($value, a ${value.type}) is not a Boolean        ${formatCursorPositionFromTokens(tokens)}",
    );
  }
  tokens.expectChar(TokenType.closeParen);
  tokens.expectChar(TokenType.openBrace);
  List<Statement> body = parseBlock(
      tokens,
      TypeValidator(scope)
        ..types.addAll(scope.types)
        ..nonconst.addAll(scope.nonconst));
  List<Statement> elseBody = [];
  tokens.expectChar(TokenType.closeBrace);
  if (tokens.current is IdentToken && tokens.currentIdent == "else") {
    tokens.moveNext();
    if (tokens.current is IdentToken && tokens.currentIdent == "if") {
      IfStatement parsedIf = parseIf(tokens, scope);
      elseBody = [parsedIf];
    } else {
      tokens.expectChar(TokenType.openBrace);
      elseBody = parseBlock(
          tokens,
          TypeValidator(scope)
            ..types.addAll(scope.types)
            ..nonconst.addAll(scope.nonconst));
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
