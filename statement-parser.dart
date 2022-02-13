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
          tokens.file,
        );
  if (superclass != null && !scope.classes.containsKey(superclass)) {
    throw FileInvalid(
        "$superclass not in scope ${scope.hashCode} of line ${tokens.current.line}, column ${tokens.current.col}, file ${tokens.file} while trying to have $name extend it.");
  }
  TypeValidator newScope = superclass == null
      ? (TypeValidator()
        ..types = Map.of(scope.types)
        ..nonconst.addAll(scope.nonconst))
      : (TypeValidator()
        ..types.addAll(Map.of(scope.classes[superclass]!.types))
        ..nonconst.addAll(List.of(scope.classes[superclass]!.nonconst))
        ..types.addAll(scope.types)
        ..nonconst.addAll(scope.nonconst));
  ClassValueType type =
      ClassValueType(name, supertype as ClassValueType?, newScope, tokens.file);
  newScope.newVar(
    'this',
    type,
    tokens.current.line,
    tokens.current.col,
    tokens.file,
  );

  List<Statement> block = parseBlock(tokens, newScope);
  if (supertype != null) {
    for (MapEntry<String, ValueType> property in newScope.types.entries) {
      if (!property.value.isSubtypeOf(
              supertype.properties.types[property.key] ?? sharedSupertype) &&
          property.key != 'constructor') {
        throw FileInvalid(
            "$name type has invalid override of $superclass.${property.key} (expected ${supertype.properties.types[property.key]}, got ${property.value} line ${tokens.current.line}, column ${tokens.current.col}, file ${tokens.file})");
      }
    }
  }
  scope.classes[name] = newScope;
  scope.newVar(
    name,
    FunctionValueType(
        type,
        (type.recursiveLookup('constructor') as FunctionValueType?)
                ?.parameters ??
            [],
        tokens.file),
    tokens.current.line,
    tokens.current.col,
    tokens.file,
  );
  tokens.expectChar(TokenType.closeBrace);
  return ClassStatement(name, superclass, block, type, tokens.current.line,
      tokens.current.col, tokens.file);
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
        subscripts.add(parseExpression(tokens, scope, integerType));
        tokens.expectChar(TokenType.closeSquare);
      }
      if (tokens.current is CharToken) {
        if (tokens.currentChar == TokenType.plus) {
          tokens.expectChar(TokenType.plus);
          scope.getVar(
            ident1,
            subscripts.length,
            integerType,
            tokens.current.line,
            tokens.current.col,
            tokens.file,
          );
          if (tokens.currentChar == TokenType.set) {
            tokens.moveNext();
            Expression value = parseExpression(tokens, scope, integerType);
            tokens.expectChar(TokenType.endOfStatement);
            return SetStatement(
              ident1,
              AddExpression(
                subscriptsToExpr(ident1, subscripts, tokens.current.line,
                    tokens.current.col, tokens.file, scope),
                value,
                tokens.current.line,
                tokens.current.col,
                tokens.file,
              ),
              subscripts,
              tokens.current.line,
              tokens.current.col,
            );
          }
          tokens.expectChar(TokenType.plus);
          tokens.expectChar(TokenType.endOfStatement);
          return SetStatement(
            ident1,
            AddExpression(
              GetExpr(ident1, scope, tokens.current.line, tokens.current.col,
                  tokens.file),
              IntLiteralExpression(
                  1, tokens.current.line, tokens.current.col, tokens.file),
              tokens.current.line,
              tokens.current.col,
              tokens.file,
            ),
            subscripts,
            tokens.current.line,
            tokens.current.col,
          );
        }
        if (tokens.currentChar == TokenType.minus) {
          tokens.expectChar(TokenType.minus);
          scope.getVar(
            ident1,
            subscripts.length,
            integerType,
            tokens.current.line,
            tokens.current.col,
            tokens.file,
          );
          if (tokens.currentChar == TokenType.set) {
            tokens.moveNext();
            Expression value = parseExpression(tokens, scope, integerType);
            tokens.expectChar(TokenType.endOfStatement);
            return SetStatement(
              ident1,
              SubtractExpression(
                subscriptsToExpr(ident1, subscripts, tokens.current.line,
                    tokens.current.col, tokens.file, scope),
                value,
                tokens.current.line,
                tokens.current.col,
                tokens.file,
              ),
              subscripts,
              tokens.current.line,
              tokens.current.col,
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
                tokens.file,
              ),
              IntLiteralExpression(
                  1, tokens.current.line, tokens.current.col, tokens.file),
              tokens.current.line,
              tokens.current.col,
              tokens.file,
            ),
            subscripts,
            tokens.current.line,
            tokens.current.col,
          );
        }
        if (tokens.currentChar == TokenType.set) {
          tokens.expectChar(TokenType.set);
          Expression expr = parseExpression(tokens, scope, sharedSupertype);
          tokens.expectChar(TokenType.endOfStatement);
          scope.setVar(
            ident1,
            subscripts.length,
            expr.type,
            tokens.current.line,
            tokens.current.col,
            tokens.file,
          );
          return SetStatement(
            ident1,
            expr,
            subscripts,
            tokens.current.line,
            tokens.current.col,
          );
        }
        tokens.getPrevious();
        break;
      }
      String ident2 = tokens.currentIdent;
      tokens.moveNext();
      if (tokens.currentChar == TokenType.set) {
        tokens.expectChar(TokenType.set);
        Expression expr = parseExpression(tokens, scope, sharedSupertype);
        if (!expr.type.isSubtypeOf(
          ValueType(null, ident1, tokens.current.line, tokens.current.col,
              tokens.file),
        )) {
          throw FileInvalid(
              "$expr is not of type $ident1, which is expected by $ident2. (line ${tokens.current.line} col ${tokens.current.col} file ${tokens.file})");
        }
        scope.newVar(
          ident2,
          ValueType(null, ident1, tokens.current.line, tokens.current.col,
              tokens.file),
          tokens.current.line,
          tokens.current.col,
          tokens.file,
        );
        if (subscripts.isNotEmpty) {
          throw FileInvalid(
              "type $ident1${subscripts.map((e) => '[$e]')} contains square brackets line ${tokens.current.line} col ${tokens.current.col} file ${tokens.file}");
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
            tokens.file,
          ),
          tokens.current.line,
          tokens.current.col,
          tokens.file,
        );
        if (subscripts.isNotEmpty) {
          throw FileInvalid(
              "type $ident1${subscripts.map((e) => '[$e]')} contains square brackets line ${tokens.current.line} col ${tokens.current.col}");
        }
        return NewVarStatement(
          ident2,
          BoringExpr(
              startingValueOfVar,
              ValueType(sharedSupertype, 'unassigned', tokens.current.line,
                  tokens.current.col, tokens.file)),
          tokens.current.line,
          tokens.current.col,
        );
      }
      tokens.expectChar(TokenType.openParen);
      List<Parameter> params = [];
      while (tokens.current is! CharToken ||
          tokens.currentChar != TokenType.closeParen) {
        String type = tokens.currentIdent;
        tokens.moveNext();
        String name = tokens.currentIdent;
        tokens.moveNext();
        if (tokens.currentChar != TokenType.closeParen) {
          tokens.expectChar(TokenType.comma);
        }
        params.add(Parameter(
            ValueType(null, type, tokens.current.line, tokens.current.col,
                tokens.file),
            name));
      }
      tokens.expectChar(TokenType.closeParen);
      tokens.expectChar(TokenType.openBrace);
      List<Statement> body = parseBlock(
          tokens,
          TypeValidator()
            ..types.addAll(scope.types)
            ..nonconst.addAll(scope.nonconst)
            ..types.addAll(
                Map.fromEntries(params.map((e) => MapEntry(e.name, e.type))))
            ..types[ident2] = FunctionValueType(
                ValueType(null, ident1, tokens.current.line, tokens.current.col,
                    tokens.file),
                params.map((e) => e.type),
                tokens.file));
      tokens.expectChar(TokenType.closeBrace);
      scope.newVar(
        ident2,
        FunctionValueType(
            ValueType(null, ident1, tokens.current.line, tokens.current.col,
                tokens.file),
            params.map((e) => e.type),
            tokens.file),
        tokens.current.line,
        tokens.current.col,
        tokens.file,
        true,
      );
      return FunctionStatement(
        ValueType(
            null, ident1, tokens.current.line, tokens.current.col, tokens.file),
        ident2,
        params,
        body,
        tokens.current.line,
        tokens.current.col,
        tokens.file,
      );
    }
  } while (false);
  Expression expr = parseExpression(tokens, scope, sharedSupertype);
  tokens.expectChar(TokenType.endOfStatement);
  return ExpressionStatement(expr, tokens.current.line, tokens.current.col);
}

Expression subscriptsToExpr(String ident1, List<Expression> subscripts,
    int line, int col, String file, TypeValidator validator) {
  return subscripts.length > 0
      ? SubscriptExpression(
          subscriptsToExpr(ident1, subscripts.toList()..removeLast(), line, col,
              file, validator),
          subscripts.last,
          line,
          col,
          file)
      : GetExpr(ident1, validator, line, col, file);
}

MapEntry<List<Statement>, TypeValidator> parse(
    Iterable<Token> rtokens, String file) {
  TokenIterator tokens = TokenIterator(rtokens.iterator, file);
  tokens.moveNext();
  TypeValidator validator = TypeValidator();
  List<Statement> ast = parseBlock(tokens, validator, false);
  return MapEntry(ast, validator);
}

WhileStatement parseWhile(TokenIterator tokens, TypeValidator scope) {
  tokens.moveNext();
  tokens.expectChar(TokenType.openParen);
  Expression expression = parseExpression(tokens, scope, booleanType);
  tokens.expectChar(TokenType.closeParen);
  tokens.expectChar(TokenType.openBrace);
  List<Statement> body = parseBlock(
      tokens,
      TypeValidator()
        ..types = scope.types
        ..nonconst = scope.nonconst);
  tokens.expectChar(TokenType.closeBrace);
  return WhileStatement(
    expression,
    body,
    tokens.current.line,
    tokens.current.col,
    'while',
    true,
  );
}

Map<String, MapEntry<List<Statement>, TypeValidator>> filesLoaded = {};
List<String> filesStartedLoading = [];
ImportStatement parseImport(TokenIterator tokens, TypeValidator scope) {
  if (tokens.doneImports) {
    throw FileInvalid(
        "cannot have import statement after non-import line ${tokens.current.line} column ${tokens.current.col} file ${tokens.file}");
  }
  tokens.moveNext();
  String str = tokens.string;
  if (filesStartedLoading.contains(str)) {
    throw FileInvalid(
        "Import loop detected at line ${tokens.current.line}, column ${tokens.current.col}, file ${tokens.file}");
  }
  filesStartedLoading.add(str);
  if (!File('compiler/$str').existsSync()) {
    throw FileInvalid("Attempted import of nonexistent file $str");
  }
  tokens.moveNext();
  tokens.expectChar(TokenType.endOfStatement);

  MapEntry<List<Statement>, TypeValidator> result = filesLoaded[str] ??
      (filesLoaded[str] = parse(
        lex(File('compiler/$str').readAsStringSync()),
        str,
      ));
  filesStartedLoading.remove(str);
  scope.types.addAll(result.value.types);
  scope.classes.addAll(result.value.classes);
  return ImportStatement(result.key, str);
}

Statement parseStatement(TokenIterator tokens, TypeValidator scope) {
  if (tokens.current is! IdentToken) {
    tokens.doneImports = true;
    return parseNonKeywordStatement(tokens, scope);
  }
  switch (tokens.currentIdent) {
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
    default:
      tokens.doneImports = true;
      return parseNonKeywordStatement(tokens, scope);
  }
}

Statement parseForIn(TokenIterator tokens, TypeValidator scope) {
  tokens.moveNext();
  tokens.expectChar(TokenType.openParen);
  String currentName = tokens.currentIdent;
  tokens.moveNext();
  if (tokens.currentIdent != 'in') {
    throw FileInvalid(
        "no 'in' after name of new variable in the for loop on line ${tokens.current.line} column ${tokens.current.col} file ${tokens.file}");
  }
  int __itn = _itn++;
  tokens.moveNext();
  Expression iterable = parseExpression(
      tokens, scope, IterableValueType(sharedSupertype, tokens.file));
  TypeValidator innerScope = TypeValidator()
    ..types.addAll(scope.types)
    ..nonconst.addAll(scope.nonconst);
  innerScope.newVar(
    currentName,
    iterable.type is IterableValueType
        ? (iterable.type as IterableValueType).genericParameter
        : sharedSupertype,
    tokens.current.line,
    tokens.current.col,
    tokens.file,
  );
  tokens.expectChar(TokenType.closeParen);
  tokens.expectChar(TokenType.openBrace);
  List<Statement> body = parseBlock(tokens, innerScope);
  tokens.expectChar(TokenType.closeBrace);
  return WhileStatement(
    BoringExpr(true, booleanType),
    [
      SetStatement(
        '~iter$__itn',
        FunctionCallExpr(
          GetExpr('iterator', scope, -1, -1, tokens.file),
          [iterable],
          innerScope,
          tokens.current.line,
          tokens.current.col,
          tokens.file,
        ),
        [],
        -1,
        -1,
      ),
      WhileStatement(
        FunctionCallExpr(
          GetExpr('next', scope, -1, -1, tokens.file),
          [GetExpr('~iter$__itn', scope, -1, -1, tokens.file)],
          innerScope,
          tokens.current.line,
          tokens.current.col,
          tokens.file,
        ),
        <Statement>[
              NewVarStatement(
                currentName,
                FunctionCallExpr(
                    GetExpr('current', innerScope, -1, -1, tokens.file),
                    [GetExpr('~iter$__itn', innerScope, -1, -1, tokens.file)],
                    innerScope,
                    -1,
                    -1,
                    '_int'),
                -1,
                -1,
              ),
            ] +
            body,
        -1,
        -1,
        'for-in inner',
        true,
      ),
      BreakStatement(
        true,
        -1,
        -1,
      )
    ],
    -1,
    -1,
    'for-in outer',
    false,
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
          tokens.file),
      tokens.current.line,
      tokens.current.col,
      tokens.file,
    );
    body.add(
      SetStatement(
        name + tokens.currentIdent,
        BoringExpr(
            name + tokens.currentIdent,
            ValueType(sharedSupertype, name, tokens.current.line,
                tokens.current.col, tokens.file)),
        [],
        -1,
        -1,
      ),
    );
    tokens.moveNext();
  }
  tokens.moveNext();
  body.add(BreakStatement(
    false,
    -1,
    -1,
  ));
  return WhileStatement(
    BoringExpr(true, booleanType),
    body,
    -1,
    -1,
    'enum',
    true,
    false,
  );
}

int elseN = 0;

WhileStatement parseIf(TokenIterator tokens, TypeValidator scope) {
  tokens.moveNext();
  tokens.expectChar(TokenType.openParen);
  Expression expression = parseExpression(tokens, scope, booleanType);
  tokens.expectChar(TokenType.closeParen);
  tokens.expectChar(TokenType.openBrace);
  int localElseN = elseN++;
  List<Statement> body = [
    SetStatement(
      "~else$localElseN",
      GetExpr("false", scope, -1, -1, 'false was overriden'),
      [],
      -1,
      -1,
    ),
    ...parseBlock(
        tokens,
        TypeValidator()
          ..types.addAll(scope.types)
          ..nonconst.addAll(scope.nonconst)),
    BreakStatement(
      true,
      -1,
      -1,
    ),
  ];
  List<Statement> elseBody = [];
  tokens.expectChar(TokenType.closeBrace);
  if (tokens.current is IdentToken && tokens.currentIdent == "else") {
    tokens.moveNext();
    if (tokens.current is IdentToken && tokens.currentIdent == "if") {
      var parsedIf = parseIf(tokens, scope);
      elseBody = parsedIf.body;
    } else {
      tokens.expectChar(TokenType.openBrace);
      elseBody = parseBlock(
          tokens,
          TypeValidator()
            ..types.addAll(scope.types)
            ..nonconst.addAll(scope.nonconst));
      tokens.expectChar(TokenType.closeBrace);
    }
  }
  elseBody.add(BreakStatement(
    true,
    -1,
    -1,
  ));
  scope.types["~else$localElseN"] = booleanType;
  return WhileStatement(
    BoringExpr(true, booleanType),
    [
      SetStatement(
        "~else$localElseN",
        BoringExpr(true, booleanType),
        [],
        -1,
        -1,
      ),
      WhileStatement(
        expression,
        body,
        -1,
        -1,
        'if-a',
        false,
      ),
      WhileStatement(
        GetExpr("~else$localElseN", scope, -1, -1, 'interr-if statement'),
        elseBody,
        -1,
        -1,
        'if-b',
        false,
      ),
      BreakStatement(
        true,
        -1,
        -1,
      ),
    ],
    -1,
    -1,
    'if-c',
    false,
  );
}

int _itn = 0;
