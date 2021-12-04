import 'dart:io';

import 'lexer.dart';

import 'package:characters/characters.dart';

bool quirksMode = false;

final ValueType sharedSupertype = ValueType._(
  null,
  'Anything',
);
final ValueType integerType = ValueType._(
  sharedSupertype,
  'Integer',
);
final ValueType stringType = ValueType._(
  sharedSupertype,
  'String',
);
final ValueType booleanType = ValueType._(
  sharedSupertype,
  'Boolean',
);

class GenericFunctionValueType extends ValueType {
  GenericFunctionValueType._(this.returnType)
      : super._(sharedSupertype, "${returnType}Function");
  final ValueType returnType;
  factory GenericFunctionValueType(ValueType returnType) {
    return (ValueType.types["${returnType}Function"] ??=
        GenericFunctionValueType._(returnType)) as GenericFunctionValueType;
  }
  @override
  bool isSubtypeOf(final ValueType possibleParent) {
    if (possibleParent is GenericFunctionValueType) {}
    return super.isSubtypeOf(possibleParent) ||
        ((possibleParent is GenericFunctionValueType) &&
            returnType.isSubtypeOf(possibleParent.returnType));
  }
}

class IterableValueType extends ValueType {
  IterableValueType._(this.genericParameter)
      : super._(sharedSupertype, "${genericParameter}Iterable");
  factory IterableValueType(ValueType genericParameter) {
    return ValueType.types["${genericParameter}Iterable"]
            as IterableValueType? ??
        IterableValueType._(genericParameter);
  }
  final ValueType genericParameter;
  @override
  bool isSubtypeOf(ValueType possibleParent) {
    return super.isSubtypeOf(possibleParent) ||
        (possibleParent is IterableValueType &&
            genericParameter.isSubtypeOf(possibleParent.genericParameter));
  }
}

class IteratorValueType extends ValueType {
  IteratorValueType._(this.genericParameter)
      : super._(sharedSupertype, "${genericParameter}Iterator");
  factory IteratorValueType(ValueType genericParameter) {
    return ValueType.types["${genericParameter}Iterator"]
            as IteratorValueType? ??
        IteratorValueType._(genericParameter);
  }
  final ValueType genericParameter;
  @override
  bool isSubtypeOf(ValueType possibleParent) {
    return super.isSubtypeOf(possibleParent) ||
        (possibleParent is IteratorValueType &&
            genericParameter.isSubtypeOf(possibleParent.genericParameter));
  }
}

class ListValueType extends IterableValueType {
  ListValueType._(this.genericParameter)
      : super._(IterableValueType(genericParameter));
  String get name => "${genericParameter}List";
  factory ListValueType(ValueType genericParameter) {
    return ValueType.types["${genericParameter}List"] as ListValueType? ??
        ListValueType._(genericParameter);
  }
  final ValueType genericParameter;
  @override
  bool isSubtypeOf(ValueType possibleParent) {
    return name == possibleParent.name ||
        (parent != null && parent!.isSubtypeOf(possibleParent)) ||
        (possibleParent is IterableValueType &&
            genericParameter.isSubtypeOf(possibleParent.genericParameter));
  }
}

class FunctionValueType extends GenericFunctionValueType {
  Iterable<ValueType> parameters;
  ValueType returnType;
  late final String stringParams = parameters.toString();
  late final String name =
      "${returnType}Function(${stringParams.substring(1, stringParams.length - 1)})";

  FunctionValueType._(this.returnType, this.parameters) : super._(returnType);

  factory FunctionValueType(
      ValueType returnType, Iterable<ValueType> parameters) {
    String str = parameters.toString();
    return ValueType.types[
            "${returnType}Function(${str.substring(1, str.length - 1)})"] =
        ValueType.types[
                    "${returnType}Function(${str.substring(1, str.length - 1)})"]
                as FunctionValueType? ??
            FunctionValueType._(returnType, parameters);
  }
  @override
  bool isSubtypeOf(ValueType possibleParent) {
    int i = 0;
    bool parentOk = super.isSubtypeOf(possibleParent);
    if (!parentOk) {}
    return possibleParent == parent ||
        parentOk &&
            (possibleParent is GenericFunctionValueType ||
                possibleParent is FunctionValueType &&
                    (possibleParent.parameters is InfiniteIterable
                        ? parameters is InfiniteIterable &&
                            parameters.first == possibleParent.parameters.first
                        : possibleParent.parameters.every((element) =>
                            parameters.elementAt(i++).isSubtypeOf(element))));
  }
}

MapEntry<List<Statement>, TypeValidator> parse(
    Iterable<Token> rtokens, String file) {
  TokenIterator tokens = TokenIterator(rtokens.iterator, file);
  tokens.moveNext();
  if (rtokens.first is CharToken &&
      (rtokens.first as CharToken).type == TokenType.set) {
    quirksMode = true;
    tokens.moveNext();
  }
  TypeValidator validator = TypeValidator();
  List<Statement> ast = parseBlock(tokens, validator, false);
  return MapEntry(ast, validator);
}

Scope runProgram(List<Statement> ast) {
  Scope scope = Scope(stack: ["main"]);
  for (Statement statement in ast) {
    statement.run(scope);
  }
  return scope;
}

Statement parseStatement(TokenIterator tokens, TypeValidator scope) {
  switch (tokens.currentIdent) {
    // TODO: support classes
    case 'import':
      return ImportStatement.parse(tokens, scope);
    case "while":
      doneImports = true;
      return WhileStatement.parse(tokens, scope);
    case "break":
      doneImports = true;
      return BreakStatement.parse(tokens, scope);
    case "continue":
      doneImports = true;
      return ContinueStatement.parse(tokens, scope);
    case "return":
      doneImports = true;
      return ReturnStatement.parse(tokens, scope);
    case "if":
      doneImports = true;
      return parseIf(tokens, scope);
    case "enum":
      doneImports = true;
      return parseEnum(tokens, scope);
    case 'for':
      doneImports = true;
      return parseForIn(tokens, scope);
    default:
      doneImports = true;
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
  tokens.moveNext();
  Expression iterable =
      parseExpression(tokens, scope, IterableValueType(sharedSupertype));
  TypeValidator innerScope = TypeValidator()..types.addAll(scope.types);
  innerScope.newVar(
    currentName,
    (iterable.type as IterableValueType).genericParameter,
    BoringExpr(-1, (iterable.type as IterableValueType).genericParameter),
    tokens.current.line,
    tokens.current.col,
    tokens.file,
  );
  tokens.expectChar(TokenType.closeParen);
  tokens.expectChar(TokenType.openBrace);
  List<Statement> body = parseBlock(tokens, innerScope);
  tokens.expectChar(TokenType.closeBrace);
  return WhileStatement(
    coerce(BoringExpr(true, booleanType), 'INTERR', booleanType),
    [
      SetStatement(
        '~iter',
        FunctionCallExpr(
          coerce(
              GetExpr('iterator', scope, -1, -1),
              "iterator was overriden",
              FunctionValueType(IteratorValueType(sharedSupertype),
                  [IterableValueType(sharedSupertype)])),
          [iterable],
          innerScope,
          tokens.current.line,
          tokens.current.col,
        ),
        [],
        -1,
        -1,
      ),
      WhileStatement(
        coerce(
          FunctionCallExpr(
            coerce(
                GetExpr('next', scope, -1, -1),
                "next was overriden",
                FunctionValueType(
                    booleanType, [IteratorValueType(sharedSupertype)])),
            [GetExpr('~iter', scope, -1, -1)],
            innerScope,
            tokens.current.line,
            tokens.current.col,
          ),
          'next was overriden',
          booleanType,
        ),
        <Statement>[
              SetStatement(
                currentName,
                FunctionCallExpr(
                  coerce(
                      GetExpr('current', innerScope, -1, -1),
                      "current was overriden",
                      FunctionValueType(sharedSupertype,
                          [IteratorValueType(sharedSupertype)])),
                  [GetExpr('~iter', innerScope, -1, -1)],
                  innerScope,
                  -1,
                  -1,
                ),
                [],
                -1,
                -1,
              ),
            ] +
            body,
        -1,
        -1,
        'for-in inner',
        true,
        false,
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
    false,
  );
}

Statement parseEnum(TokenIterator tokens, TypeValidator scope) {
  tokens.moveNext();
  String name = tokens.currentIdent;
  tokens.moveNext();
  List<Statement> body = [];
  ValueType._(sharedSupertype, name);
  tokens.expectChar(TokenType.openBrace);
  while (tokens.current is! CharToken ||
      tokens.currentChar != TokenType.closeBrace) {
    scope.newVar(
      name + tokens.currentIdent,
      ValueType(sharedSupertype, name),
      BoringExpr(0, ValueType(sharedSupertype, name)),
      tokens.current.line,
      tokens.current.col,
      tokens.file,
    );
    body.add(
      SetStatement(
        name + tokens.currentIdent,
        BoringExpr(
            name + tokens.currentIdent, ValueType(sharedSupertype, name)),
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
    coerce(BoringExpr(true, booleanType), 'INTERNAL ERROR', booleanType),
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
      GetExpr("false", scope, -1, -1),
      [],
      -1,
      -1,
    ),
    ...parseBlock(tokens, TypeValidator()..types.addAll(scope.types)),
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
      elseBody = parseBlock(tokens, TypeValidator()..types.addAll(scope.types));
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
    coerce(
      BoringExpr(true, booleanType),
      "(internal error with if statement)",
      booleanType,
    ),
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
        false,
      ),
      WhileStatement(
        coerce(GetExpr("~else$localElseN", scope, -1, -1),
            "(internal error with if statement)", booleanType),
        elseBody,
        -1,
        -1,
        'if-b',
        false,
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
    false,
  );
}

bool deepContains(List<ValueWrapper> a, Object b) {
  if (a.any((x) => x.value == b)) return true;
  for (ValueWrapper e in a) {
    if (e.type.isSubtypeOf(ListValueType(sharedSupertype)) &&
        deepContains(e.value, b)) {
      return true;
    }
  }
  return false;
}

class ValueWrapper {
  final ValueType type;
  final dynamic value;

  ValueWrapper(this.type, this.value);

  String toString() => "$value";
}

class Scope {
  Scope({this.parent, required this.stack});

  final Scope? parent;
  final List<String> stack;

  late Map<String, ValueWrapper> values = {
    "true": true,
    "false": false,
    "null": null,
    "print": (List<ValueWrapper> l, Scope s) {
      stdout.write(l.map((e) => e.value).join(' '));
      return ValueWrapper(integerType, 0);
    },
    "concat": (List<ValueWrapper> l, Scope s) {
      return ValueWrapper(stringType, l.map((e) => e.value).join(''));
    },
    "addLists": (List<ValueWrapper> l, Scope s) {
      return ValueWrapper(ListValueType(sharedSupertype),
          l.expand((element) => element.value).toList());
    },
    "parseInt": (List<ValueWrapper> l, Scope s) {
      return ValueWrapper(
        integerType,
        quirksMode
            ? int.tryParse(l.single.value) ?? -1
            : int.parse(l.single.value),
      );
    },
    "charsOf": (List<ValueWrapper> l, Scope s) {
      return ValueWrapper(
          IterableValueType(stringType),
          (l.single.value as String)
              .characters
              .map((e) => ValueWrapper(stringType, e)));
    },
    "scalarValues": (List<ValueWrapper> l, Scope s) {
      return ValueWrapper(IterableValueType(integerType),
          l.single.value.runes.map((e) => ValueWrapper(integerType, e)));
    },
    "len": (List<ValueWrapper> l, Scope s) {
      return ValueWrapper(integerType, l.single.value.length);
    },
    "input": (List<ValueWrapper> l, Scope s) {
      return ValueWrapper(stringType, stdin.readLineSync());
    },
    "append": (List<ValueWrapper> l, Scope s) {
      if (l.first.value == l.last.value) {
        throw FileInvalid("A list cannot be appended to itself!");
      } else if (l.last.type.isSubtypeOf(ListValueType(sharedSupertype)) &&
          deepContains(l.last.value, l.first.value)) {
        throw FileInvalid(
            "A list cannot be appended to something in itself, indirectly or directly!");
      } else if (!l.last.type
          .isSubtypeOf((l.first.type as ListValueType).genericParameter)) {
        throw FileInvalid(
            "You cannot append a ${l.last.type} to a ${l.first.type}!");
      }
      l.first.value.add(l.last);
      return l.last;
    },
    "iterator": (List<ValueWrapper> l, Scope s) {
      return ValueWrapper(
          IteratorValueType(sharedSupertype), l.single.value.iterator);
    },
    "next": (List<ValueWrapper> l, Scope s) {
      return ValueWrapper(booleanType, l.single.value.moveNext());
    },
    "current": (List<ValueWrapper> l, Scope s) {
      return l.single.value.current;
    },
    "stringTimes": (List<ValueWrapper> l, Scope s) {
      return ValueWrapper(stringType, l.first.value * l.last.value);
    },
    "copy": (List<ValueWrapper> l, Scope s) {
      return ValueWrapper(
          ListValueType(sharedSupertype), l.single.value.toList());
    },
    "first": (List<ValueWrapper> l, Scope s) {
      return l.single.value.first;
    },
    "last": (List<ValueWrapper> l, Scope s) {
      return l.single.value.last;
    },
    "gv": (List<ValueWrapper> l, Scope s) {
      if (!quirksMode) throw FileInvalid("gv nonexistent");
      return getVar(l.first.value.toString());
    },
    "single": (List<ValueWrapper> l, Scope s) {
      return l.single.value.single;
    },
    'assert': (List<ValueWrapper> l, Scope s) {
      return l.length == 1
          ? l.single.value
              ? ValueWrapper(booleanType, true)
              : throw FileInvalid(
                  "Assertion failed (stack: ${s.stack.join(" > ")}}).")
          : l.first.value
              ? ValueWrapper(booleanType, true)
              : throw FileInvalid(
                  "Assertion failed: ${l.last.value}. (stack: ${s.stack.join(" > ")}})");
    },
    "padLeft": (List<ValueWrapper> l, Scope s) {
      return ValueWrapper(
          stringType, l.first.value.padLeft(l[1].value, l[2].value));
    },
    "hex": (List<ValueWrapper> l, Scope s) {
      return ValueWrapper(stringType, l.single.value.toRadixString(16));
    },
    "chr": (List<ValueWrapper> l, Scope s) {
      return ValueWrapper(stringType, String.fromCharCode(l.single.value));
    },
    "exit": (List<ValueWrapper> l, Scope s) {
      exit(l.single.value);
    },
    "readFile": (List<ValueWrapper> l, Scope s) {
      return ValueWrapper(stringType, File(l.single.value).readAsStringSync());
    },
    "readFileBytes": (List<ValueWrapper> l, Scope s) {
      if (l.length == 0) throw FileInvalid("readFileBytes called with no args");
      File file = File(l.single.value);
      return file.existsSync()
          ? ValueWrapper(stringType, file.readAsBytesSync())
          : throw FileInvalid("${l.single} is not a existing file");
    },
    "println": (List<ValueWrapper> l, Scope s) {
      stdout.writeln(l.map((e) => e.value).join(' '));
      return ValueWrapper(integerType, 0);
    },
    "throw": (List<ValueWrapper> l, Scope s) {
      throw FileInvalid(
          l.single.value + "\nstack:\n" + s.stack.reversed.join('\n'));
    },
    "joinList": (List<ValueWrapper> l, Scope s) {
      return ValueWrapper(stringType, l.single.value.join(''));
    },
    "cast": (List<ValueWrapper> l, Scope s) {
      return l.single;
    }
  }.map((key, value) => MapEntry(key, ValueWrapper(_tv_types[key]!, value)));
  static final Map<String, ValueType> _tv_types = TypeValidator().types;
  void setVar(String name, List<int> subscripts, ValueWrapper value) {
    if (parent?.getVar(name, true) != null) {
      parent!.setVar(name, subscripts, value);
    }
    if (subscripts.length == 0) {
      values[name] = value;
    } else {
      List<ValueWrapper> list = values[name]!.value;
      while (subscripts.length > 1) {
        list = list[subscripts.first].value;
        subscripts.removeAt(0);
      }
      if (list == value.value) {
        throw FileInvalid("A list cannot be $subscripts=ed to itself!");
      } else if (value.value is List && deepContains(value.value, list)) {
        throw FileInvalid(
            "A list cannot be $subscripts=ed to something that is in, indirectly or directly, itself!");
      }
      list[subscripts.single] = value;
    }
  }

  ValueWrapper getVar(String name, [bool settingVar = false]) {
    return values[name] ??
        parent?.getVar(name, settingVar) ??
        (quirksMode
            ? ValueWrapper(stringType, "INTnalERROR")
            : throw "Internal err");
  }
}

class NopStatement extends Statement {
  NopStatement(int line, int col) : super(line, col);

  @override
  StatementResult run(Scope scope) =>
      StatementResult(StatementResultType.nothing);
}

class TypeValidator {
  Map<String, ValueType> types = {
    "true": booleanType,
    "false": booleanType,
    'null': ValueType(
      sharedSupertype,
      'Null',
    ),
    "print": FunctionValueType(integerType, InfiniteIterable(sharedSupertype)),
    "concat": FunctionValueType(stringType, InfiniteIterable(sharedSupertype)),
    "parseInt": FunctionValueType(integerType, [stringType]),
    'addLists': FunctionValueType(ListValueType(sharedSupertype),
        InfiniteIterable(ListValueType(sharedSupertype))),
    'charsOf': FunctionValueType(IterableValueType(stringType), [stringType]),
    'scalarValues':
        FunctionValueType(IterableValueType(integerType), [stringType]),
    'len': FunctionValueType(integerType, [ListValueType(sharedSupertype)]),
    'input': FunctionValueType(stringType, []),
    'append': FunctionValueType(
        sharedSupertype, [ListValueType(sharedSupertype), sharedSupertype]),
    'iterator': FunctionValueType(IteratorValueType(sharedSupertype),
        [IterableValueType(sharedSupertype)]),
    'next':
        FunctionValueType(booleanType, [IteratorValueType(sharedSupertype)]),
    'current': FunctionValueType(
        sharedSupertype, [IteratorValueType(sharedSupertype)]),
    'stringTimes': FunctionValueType(stringType, [stringType, integerType]),
    'copy': FunctionValueType(
        ListValueType(sharedSupertype), [IterableValueType(sharedSupertype)]),
    'first': FunctionValueType(
        sharedSupertype, [IterableValueType(sharedSupertype)]),
    'last': FunctionValueType(
        sharedSupertype, [IterableValueType(sharedSupertype)]),
    'single': FunctionValueType(
        sharedSupertype, [IterableValueType(sharedSupertype)]),
    'assert': FunctionValueType(booleanType, [booleanType, stringType]),
    'padLeft':
        FunctionValueType(stringType, [stringType, integerType, stringType]),
    'hex': FunctionValueType(stringType, [integerType]),
    'chr': FunctionValueType(stringType, [integerType]),
    'exit': FunctionValueType(ValueType(sharedSupertype, "Cat"), [integerType]),
    'readFile': FunctionValueType(stringType, [stringType]),
    'readFileBytes':
        FunctionValueType(ListValueType(integerType), [stringType]),
    'println':
        FunctionValueType(integerType, InfiniteIterable(sharedSupertype)),
    'throw': FunctionValueType(ValueType(sharedSupertype, "Cat"), [stringType]),
    'cast': FunctionValueType(ValueType(null, "Whatever"), [sharedSupertype]),
    'joinList': FunctionValueType(stringType, [ListValueType(sharedSupertype)]),
    'gv': FunctionValueType(ValueType(sharedSupertype, "Cat"), [stringType]),
  };

  void setVar(String name, int subscripts, Expression value, int line, int col,
      String file) {
    int oldSubs = subscripts;
    if (!types.containsKey(name)) {
      throw FileInvalid(
          "$name nonexistent on line $line column $col file $file");
    }
    ValueType type = types[name]!;
    while (subscripts > 0) {
      if (type is! ListValueType) {
        throw FileInvalid(
          "Expected a list, got $type on line $line column $col file $file",
        );
      }
      type = type.genericParameter;
      subscripts--;
    }
    coerce(
        value,
        "while setting $name${"[...]" * oldSubs} to $value on line $line column $col file $file",
        type);
  }

  void newVar(String name, ValueType type, Expression value, int line, int col,
      String file) {
    coerce(
        value,
        'while setting $name, a new variable, to $value on line $line column $col file $file',
        type);
    types[name] = type;
  }

  void getVar(String name, int subscripts, ValueType type, int line, int col,
      String file) {
    ValueType? realtype = types[name];
    if (realtype == null) {
      throw FileInvalid(
          "$name nonexistent on line $line column $col file $file");
    }
    while (subscripts > 0) {
      if (realtype is! ListValueType) {
        throw FileInvalid(
          "Expected a list, but got $realtype on line $line column $col file $file",
        );
      }
      realtype = realtype.genericParameter;
      subscripts--;
    }
    if (!realtype!.isSubtypeOf(type)) {
      if (!quirksMode)
        throw FileInvalid(
          "Expected $type, got ${types[name]} on line $line column $col file $file",
        );
    }
  }
}

class SetStatement extends Statement {
  final String name;

  final Expression val;
  final List<Expression> subscripts;

  SetStatement(this.name, this.val, this.subscripts, int line, int col)
      : super(line, col);

  @override
  StatementResult run(Scope scope) {
    var right = val.eval(scope);
    List<int> list =
        subscripts.map((e) => e.eval(scope).value).cast<int>().toList();
    scope.setVar(
      name,
      list,
      right,
    );
    return StatementResult(StatementResultType.nothing);
  }
}

class GetExpr<T> extends Expression {
  final String name;

  GetExpr(this.name, this.typeValidator, int line, int col) : super(line, col);

  final TypeValidator typeValidator;

  ValueType get type =>
      typeValidator.types[name] ?? (throw "$name does not exist");

  @override
  eval(Scope scope) {
    return scope.getVar(name);
  }

  String toString() => name;
}

Statement parseNonKeywordStatement(TokenIterator tokens, TypeValidator scope) {
  do {
    if (tokens.current is IdentToken || quirksMode) {
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
            if (!quirksMode) tokens.expectChar(TokenType.endOfStatement);
            return SetStatement(
              ident1,
              AddExpression(
                coerce(
                    GetExpr(
                        ident1, scope, tokens.current.line, tokens.current.col),
                    "(internal error parsing +=)",
                    integerType),
                value,
                tokens.current.line,
                tokens.current.col,
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
              coerce(
                GetExpr(ident1, scope, tokens.current.line, tokens.current.col),
                "(internal error with TypeValidator.getVar)",
                integerType,
              ),
              IntLiteralExpression(1, -1, -1),
              tokens.current.line,
              tokens.current.col,
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
            if (!quirksMode) tokens.expectChar(TokenType.endOfStatement);
            return SetStatement(
              ident1,
              SubtractExpression(
                coerce(
                  GetExpr(
                      ident1, scope, tokens.current.line, tokens.current.col),
                  "(internal error parsing -=)",
                  integerType,
                ),
                value,
                tokens.current.line,
                tokens.current.col,
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
              coerce(
                GetExpr(ident1, scope, tokens.current.line, tokens.current.col),
                "(internal error with TypeValidator.getVar)",
                integerType,
              ),
              IntLiteralExpression(1, -1, -1),
              tokens.current.line,
              tokens.current.col,
            ),
            subscripts,
            tokens.current.line,
            tokens.current.col,
          );
        }
        if (tokens.currentChar == TokenType.set) {
          tokens.expectChar(TokenType.set);
          Expression expr = parseExpression(tokens, scope, sharedSupertype);
          if (!quirksMode) tokens.expectChar(TokenType.endOfStatement);
          scope.setVar(
            ident1,
            subscripts.length,
            expr,
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
        if (!quirksMode) tokens.expectChar(TokenType.endOfStatement);
        scope.newVar(
          ident2,
          ValueType(null, ident1, tokens.current.line, tokens.current.col,
              tokens.file),
          expr,
          tokens.current.line,
          tokens.current.col,
          tokens.file,
        );
        if (subscripts.isNotEmpty) {
          throw FileInvalid(
              "type $ident1${subscripts.map((e) => '[$e]')} contains square brackets line ${tokens.current.line} col ${tokens.current.col}");
        }
        return SetStatement(
          ident2,
          expr,
          [],
          tokens.current.line,
          tokens.current.col,
        );
      }
      if (tokens.currentChar == TokenType.endOfStatement) {
        tokens.expectChar(TokenType.endOfStatement);
        scope.newVar(
          ident2,
          ValueType(null, ident1),
          BoringExpr(null, ValueType(null, ident1)),
          tokens.current.line,
          tokens.current.col,
          tokens.file,
        );
        if (subscripts.isNotEmpty) {
          throw FileInvalid(
              "type $ident1${subscripts.map((e) => '[$e]')} contains square brackets line ${tokens.current.line} col ${tokens.current.col}");
        }
        return SetStatement(
          ident2,
          BoringExpr(null, ValueType(sharedSupertype, 'Null')),
          [],
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
        params.add(Parameter(ValueType(null, type), name));
      }
      tokens.expectChar(TokenType.closeParen);
      tokens.expectChar(TokenType.openBrace);
      List<Statement> body = parseBlock(
          tokens,
          TypeValidator()
            ..types.addAll(scope.types)
            ..types.addAll(
                Map.fromEntries(params.map((e) => MapEntry(e.name, e.type))))
            ..types[ident2] = FunctionValueType(
                ValueType(null, ident1, tokens.current.line, tokens.current.col,
                    tokens.file),
                params.map((e) => e.type)));
      tokens.expectChar(TokenType.closeBrace);
      scope.newVar(
        ident2,
        FunctionValueType(
            ValueType(null, ident1, tokens.current.line, tokens.current.col,
                tokens.file),
            params.map((e) => e.type)),
        BoringExpr(
          (List<ValueWrapper> a, Scope b) {},
          FunctionValueType(
            ValueType(null, ident1, tokens.current.line, tokens.current.col,
                tokens.file),
            params.map((e) => e.type),
          ),
        ),
        tokens.current.line,
        tokens.current.col,
        tokens.file,
      );
      return FunctionStatement(
          ValueType(null, ident1, tokens.current.line, tokens.current.col,
              tokens.file),
          ident2,
          params,
          body);
    }
  } while (false);
  Expression expr = parseExpression(tokens, scope, sharedSupertype);
  if (!quirksMode) tokens.expectChar(TokenType.endOfStatement);
  return expr;
}

class FunctionStatement extends Statement {
  FunctionStatement(this.type, this.name, this.params, this.body) : super(0, 0);
  final ValueType type;
  final String name;
  final List<Parameter> params;
  final List<Statement> body;
  @override
  StatementResult run(Scope scope) {
    scope.setVar(
        name,
        [],
        ValueWrapper(GenericFunctionValueType(sharedSupertype),
            (List<ValueWrapper> a, Scope b) {
          int i = 0;
          if (a.length != params.length) {
            throw FileInvalid(
                "Wrong number of arguments to $name: args $a, params $params");
          }
          for (ValueWrapper aSub in a) {
            b.values[params[i++].name] = aSub;
          }
          for (Statement statement in body) {
            StatementResult value = statement.run(b);
            switch (value.type) {
              case StatementResultType.nothing:
                break;
              default:
                if (value.value!.type.isSubtypeOf(type)) return value;
                throw FileInvalid(
                    "You cannot return a ${value.value!.type} from a function that is supposed to return a $type!");
            }
          }
          return ValueWrapper(ValueType(null, 'Null'), null);
        }));
    return StatementResult(StatementResultType.nothing);
  }
}

enum StatementResultType { nothing, breakWhile, continueWhile, returnFunction }

class StatementResult {
  final StatementResultType type;
  final ValueWrapper? value;

  StatementResult(this.type, [this.value]);
}

class WhileStatement extends Statement {
  final bool createParentScope;
  final String kind;

  WhileStatement(this.cond, this.body, int line, int col, this.kind,
      [this.catchReturns = true, this.createParentScope = true])
      : super(line, col);
  final Expression cond;
  final List<Statement> body;
  final bool catchReturns;
  @override
  StatementResult run(Scope scope) {
    while (cond.eval(scope).value) {
      block:
      for (Statement statement in body) {
        StatementResult statementResult = statement.run(createParentScope
            ? Scope(parent: scope, stack: scope.stack)
            : scope);
        switch (statementResult.type) {
          case StatementResultType.nothing:
            break;
          case StatementResultType.breakWhile:
            if (statementResult.value!.value || catchReturns)
              return StatementResult(StatementResultType.nothing);
            return statementResult;
          case StatementResultType.continueWhile:
            break block;
          case StatementResultType.returnFunction:
            return statementResult;
        }
      }
    }
    return StatementResult(StatementResultType.nothing);
  }

  factory WhileStatement.parse(TokenIterator tokens, TypeValidator scope) {
    tokens.moveNext();
    tokens.expectChar(TokenType.openParen);
    Expression expression = parseExpression(tokens, scope, booleanType);
    tokens.expectChar(TokenType.closeParen);
    tokens.expectChar(TokenType.openBrace);
    List<Statement> body =
        parseBlock(tokens, TypeValidator()..types = scope.types);
    tokens.expectChar(TokenType.closeBrace);
    return WhileStatement(expression, body, tokens.current.line,
        tokens.current.col, 'while', true, false);
  }
}

class Break extends FileInvalid {
  Break(this.alwaysBreakCurrent) : super("This shouldn't appear");
  final bool alwaysBreakCurrent;
  String toString() => "break outside while or for-in";
}

class BreakStatement extends Statement {
  BreakStatement(this.alwaysBreakCurrent, int line, int col) : super(line, col);
  final bool alwaysBreakCurrent;
  @override
  StatementResult run(Scope scope) {
    return StatementResult(StatementResultType.breakWhile,
        ValueWrapper(booleanType, alwaysBreakCurrent));
  }

  factory BreakStatement.parse(TokenIterator tokens, TypeValidator scope) {
    tokens.moveNext();
    if (!quirksMode) tokens.expectChar(TokenType.endOfStatement);
    return BreakStatement(
      false,
      tokens.current.line,
      tokens.current.col,
    );
  }
}

class Continue extends FileInvalid {
  Continue(this.alwaysContinueCurrent) : super("This shouldn't appear");
  final bool alwaysContinueCurrent;
  String toString() => "continue outside while or for-in";
}

class ContinueStatement extends Statement {
  ContinueStatement(this.alwaysContinueCurrent, int line, int col)
      : super(line, col);
  final bool alwaysContinueCurrent;
  @override
  StatementResult run(Scope scope) {
    return StatementResult(StatementResultType.continueWhile,
        ValueWrapper(booleanType, alwaysContinueCurrent));
  }

  factory ContinueStatement.parse(TokenIterator tokens, TypeValidator scope) {
    tokens.moveNext();
    if (!quirksMode) tokens.expectChar(TokenType.endOfStatement);
    return ContinueStatement(
      false,
      tokens.current.line,
      tokens.current.col,
    );
  }
}

class ReturnStatement extends Statement {
  ReturnStatement(this.value, int line, int col) : super(line, col);
  final Expression value;
  @override
  StatementResult run(Scope scope) {
    return StatementResult(
        StatementResultType.returnFunction, value.eval(scope));
  }

  factory ReturnStatement.parse(TokenIterator tokens, TypeValidator scope) {
    tokens.moveNext();
    if (tokens.current is CharToken &&
        tokens.currentChar == TokenType.endOfStatement) {
      tokens.moveNext();
      return ReturnStatement(
        BoringExpr(null, ValueType(null, "Null")),
        tokens.current.line,
        tokens.current.col,
      );
    }
    Expression expr = parseExpression(tokens, scope, sharedSupertype);
    if (!quirksMode) tokens.expectChar(TokenType.endOfStatement);
    return ReturnStatement(
      expr,
      tokens.current.line,
      tokens.current.col,
    );
  }
}

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

class Parameter {
  final ValueType type;
  final String name;

  String toString() => "$type $name";

  Parameter(this.type, this.name);
}

abstract class Expression extends Statement {
  Expression(int line, int col) : super(line, col);

  ValueWrapper eval(Scope scope);
  StatementResult run(Scope scope) {
    eval(scope);
    return StatementResult(StatementResultType.nothing);
  }

  ValueType get type;
  Expression get internal => this;
}

class BoringExpr extends Expression {
  final value;

  final ValueType type;

  BoringExpr(this.value, this.type) : super(0, 0);
  @override
  eval(Scope scope) {
    return ValueWrapper(type, value);
  }

  String toString() => "$value**";
}

Expression coerce(Expression operand, String message, ValueType type) {
  if (!operand.type.isSubtypeOf(type)) {
    if (quirksMode) return CastExpr(operand, type);
    throw FileInvalid("Expected $type, got ${operand.type} $message");
  }
  return CastExpr(operand, type);
}

class ValueType {
  final ValueType? parent;
  final String name;

  String toString() => name;
  bool operator ==(x) =>
      x is ValueType && this.isSubtypeOf(x) && x.isSubtypeOf(this);

  ValueType._(this.parent, this.name) {
    if (types[name] != null) {
      throw FileInvalid("Repeated creation of $name");
    }
    types[name] = this;
  }
  static final Map<String, ValueType> types = {};
  factory ValueType(ValueType? parent, String name,
      [int line = -1, int col = -1, String file = "???"]) {
    return types[name] ??
        (name.endsWith("Iterable")
            ? IterableValueType(
                ValueType(
                  sharedSupertype,
                  name.substring(0, name.length - 8),
                ),
              )
            : name.endsWith("Iterator")
                ? IteratorValueType(
                    ValueType(
                      sharedSupertype,
                      name.substring(0, name.length - 8),
                    ),
                  )
                : name.endsWith("List")
                    ? ListValueType(
                        ValueType(
                          sharedSupertype,
                          name.substring(0, name.length - 4),
                        ),
                      )
                    : name.endsWith("Function")
                        ? GenericFunctionValueType(
                            ValueType(
                              sharedSupertype,
                              name.substring(0, name.length - 8),
                            ),
                          )
                        : basicTypes(name, parent, line, col, file));
  }
  bool isSubtypeOf(ValueType possibleParent) {
    var bool = this.name == possibleParent.name ||
        (parent != null && parent!.isSubtypeOf(possibleParent)) ||
        name == 'Whatever' ||
        possibleParent.name == 'Whatever';
    return bool;
  }
}

ValueType basicTypes(
    String name, ValueType? parent, int line, int col, String file) {
  switch (name) {
    case 'Null':
    case 'Cat':
    case 'Dog':
    case 'Whatever':
      return ValueType._(parent, name);
    default:
      throw FileInvalid(
          "$name type doesn't exist (line $line col $col file $file)");
  }
}

class CastExpr extends Expression {
  final Expression operand;
  final ValueType T;

  CastExpr(this.operand, this.T) : super(-1, -1);

  Expression get internal => operand.internal;

  String toString() => "[$T]$internal";

  @override
  ValueWrapper eval(Scope scope) {
    ValueWrapper value = operand.eval(scope);
    if (quirksMode) {
      return coerceTo(value);
    } else {
      return value;
    }
  }

  ValueType get type {
    return operand.type.isSubtypeOf(T) ? operand.type : T;
  }

  ValueWrapper coerceTo(ValueWrapper value) {
    if (value.type == T) return value;
    if (T == stringType)
      return ValueWrapper(stringType, value.value.toString());
    if (T.isSubtypeOf(ListValueType(sharedSupertype)))
      return ValueWrapper(ListValueType(value.type), [value]);
    if (value.type == stringType && T == integerType) {
      return ValueWrapper(integerType, int.tryParse(value.value) ?? -1);
    }
    if (value.type.isSubtypeOf(ListValueType(sharedSupertype)) &&
        T == integerType) {
      return ValueWrapper(
          integerType, int.tryParse(value.value.join(', ')) ?? -1);
    }
    if (T == booleanType && value.type == stringType) {
      return ValueWrapper(booleanType, value.value != "");
    }
    return value;
  }
}

Expression parseLiterals(TokenIterator tokens, TypeValidator scope) {
  switch (tokens.current.runtimeType) {
    case IntToken:
      return IntLiteralExpression(
        tokens.integer,
        tokens.current.line,
        tokens.current.col,
      );
    case IdentToken:
      scope.getVar(
        tokens.currentIdent,
        0,
        sharedSupertype,
        tokens.current.line,
        tokens.current.col,
        tokens.file,
      );
      return GetExpr(
          tokens.currentIdent, scope, tokens.current.line, tokens.current.col);
    case StringToken:
      return StringLiteralExpression(
        tokens.string,
        tokens.current.line,
        tokens.current.col,
      );
    case CharToken:
      if (tokens.currentChar == TokenType.openSquare) {
        tokens.moveNext();
        List<Expression> arguments = [];
        ValueType type = ValueType(null, "Dog");
        while (tokens.current is! CharToken ||
            tokens.currentChar != TokenType.closeSquare) {
          Expression expr = parseExpression(tokens, scope, sharedSupertype);
          if (tokens.currentChar != TokenType.closeSquare) {
            tokens.expectChar(TokenType.comma);
          }
          arguments.add(expr);
          if (type == ValueType(null, "Dog")) {
            type = expr.type;
          } else if (expr.type == ValueType(null, "Whatever")) {
            // has been cast()-ed
          } else if (type != expr.type) {
            type = sharedSupertype;
          }
        }
        if (type == ValueType(null, "Dog")) {
          type = ValueType(sharedSupertype, "Whatever");
        }
        return ListLiteralExpression(
          arguments,
          type,
          tokens.current.line,
          tokens.current.col,
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
  return IntLiteralExpression(null as int, -1, -1);
}

class IntLiteralExpression extends Expression {
  IntLiteralExpression(this.n, int line, int col) : super(line, col);
  final int n;
  ValueWrapper eval(Scope scope) => ValueWrapper(integerType, n);
  String toString() => "$n";

  ValueType get type => integerType;
}

class StringLiteralExpression extends Expression {
  StringLiteralExpression(this.n, int line, int col) : super(line, col);
  final String n;
  ValueWrapper eval(Scope scope) => ValueWrapper(stringType, n);
  String toString() => "'$n'";
  ValueType get type => stringType;
}

class ListLiteralExpression extends Expression {
  ListLiteralExpression(this.n, this.genParam, int line, int col)
      : super(line, col);
  final List<Expression> n;
  final ValueType genParam;
  ValueType get type => ListValueType(genParam);
  String toString() => "<$type>$n";
  ValueWrapper eval(Scope scope) => ValueWrapper(
      ListValueType(genParam), n.map((e) => e.eval(scope)).toList());
}

Expression parseFunCalls(TokenIterator tokens, TypeValidator scope) {
  Expression operandA = parseLiterals(tokens, scope);
  tokens.moveNext();
  if (tokens.current is CharToken) {
    if (tokens.currentChar == TokenType.openSquare ||
        tokens.currentChar == TokenType.openParen) {
      Expression result = operandA;
      while (tokens.current is CharToken &&
          (tokens.currentChar == TokenType.openSquare ||
              tokens.currentChar == TokenType.openParen)) {
        if (tokens.currentChar == TokenType.openSquare) {
          tokens.moveNext();
          Expression operandB = parseExpression(tokens, scope, integerType);
          tokens.expectChar(TokenType.closeSquare);
          result = SubscriptExpression(
            coerce(
              result,
              "while trying to subscript list on line ${tokens.current.line} column ${tokens.current.col} file ${tokens.file}",
              ListValueType(sharedSupertype),
            ),
            operandB,
            tokens.current.line,
            tokens.current.col,
          );
        } else {
          Expression funOp = coerce(
            result,
            "while trying to call $result on line ${tokens.current.line} column ${tokens.current.col} file ${tokens.file}",
            GenericFunctionValueType(
              sharedSupertype,
            ),
          );
          tokens.moveNext();
          List<Expression> arguments = [];
          while (tokens.current is! CharToken ||
              tokens.currentChar != TokenType.closeParen) {
            if (!quirksMode &&
                (result.type is! GenericFunctionValueType) &&
                (result.type as FunctionValueType).parameters
                    is! InfiniteIterable &&
                (result.type as FunctionValueType).parameters.length <=
                    arguments.length) {
              throw FileInvalid(
                  "Too many arguments to $result line ${tokens.current.line} col ${tokens.current.col}");
            }
            Expression expr = parseExpression(
              tokens,
              scope,
              quirksMode
                  ? sharedSupertype
                  : result.type is GenericFunctionValueType
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
          if (!quirksMode &&
              result.type is! GenericFunctionValueType &&
              (result.type as FunctionValueType).parameters
                  is! InfiniteIterable &&
              (result.type as FunctionValueType).parameters.length !=
                  arguments.length) {
            throw FileInvalid(
                "Not enough arguments to $result line ${tokens.current.line} col ${tokens.current.col}");
          }
          tokens.moveNext();
          result = FunctionCallExpr(
            funOp,
            arguments,
            scope,
            tokens.current.line,
            tokens.current.col,
          );
        }
      }
      return result;
    } else if (tokens.currentChar == TokenType.period) {
      tokens.moveNext();
      String operandB = tokens.currentIdent;
      tokens.moveNext();
      return MemberAccessExpression(operandA, operandB);
    }
  }
  return operandA;
}

class FunctionCallExpr extends Expression {
  final Expression a;
  final List<Expression> b;

  final TypeValidator validator;

  @override
  ValueType get type => (a.type as GenericFunctionValueType).returnType;

  String toString() => "$a(${b.join(', ')})";

  FunctionCallExpr(this.a, this.b, this.validator, int line, int col)
      : super(line, col);
  @override
  ValueWrapper eval(Scope scope) {
    dynamic result = (a.eval(scope).value as Function)(
      b.map((x) => x.eval(scope)).toList(),
      Scope(
        parent: scope.parent ?? scope,
        stack: scope.stack + ["$a"],
      ),
    );
    if (result is StatementResult &&
        result.type == StatementResultType.returnFunction) {
      return result.value!;
    } else if (result is ValueWrapper) {
      return result;
    } else {
      throw "Internal error ($a => $result)";
    }
  }
}

class Return {
  final value;

  Return(this.value);
  String toString() => "Returned $value outside function";
}

class SubscriptExpression extends Expression {
  final Expression a;
  final Expression b;

  ValueType get type => a.type == ValueType(null, "Whatever")
      ? a.type
      : (a.type as ListValueType).genericParameter;

  String toString() => "$a[$b]";

  SubscriptExpression(this.a, this.b, int line, int col) : super(line, col);
  @override
  eval(Scope scope) {
    ValueWrapper list = a.eval(scope);
    int index = b.eval(scope).value;
    return fancySubscript(list, index, scope);
  }

  ValueWrapper fancySubscript(ValueWrapper list, int index, Scope scope) {
    if (list.value.length <= index || index < 0) {
      if (quirksMode) {
        if (index == -3) return scope.getVar('gv');
        if (type == stringType) {
          return ValueWrapper(stringType,
              "RangeError because $index is an invalid index for $list (too high or too low)");
        }
        if (type == integerType || type == sharedSupertype) {
          return ValueWrapper(stringType, "NANRE$index/$list");
        }
        if (list.type == stringType || list.value.isEmpty)
          return ValueWrapper(stringType,
              "RangeError because $index is an invalid index for $list (too high or too low)");
        return fancySubscript(list.value.first, index, scope);
      }
      throw FileInvalid(
          "RangeError because $index is an invalid index for $list (too high or too low)");
    }
    return list.type == stringType
        ? ValueWrapper(stringType, list.value[index])
        : list.value[index];
  }
}

class MemberAccessExpression extends Expression {
  final Expression a;
  final String b;

  ValueType get type => throw FileInvalid("member access is unimplemented");

  MemberAccessExpression(this.a, this.b) : super(0, 0);
  @override
  eval(Scope scope) {
    //TODO: implement member access
    throw FileInvalid("member access is unimplemented");
  }

  String toString() => "$a.$b";
}

Expression parseNots(TokenIterator tokens, TypeValidator scope) {
  if (tokens.current is CharToken) {
    if (tokens.currentChar == TokenType.bang) {
      tokens.moveNext();
      Expression operandA = parseNots(tokens, scope);
      return NotExpression(
        coerce(
            operandA,
            "while trying to parse !$operandA on line ${tokens.current.line} column ${tokens.current.col} file ${tokens.file}",
            booleanType),
        tokens.current.line,
        tokens.current.col,
      );
    } else if (tokens.currentChar == TokenType.tilde) {
      tokens.moveNext();
      Expression operandA = parseNots(tokens, scope);
      return BitNotExpression(
        coerce(
            operandA,
            "while trying to parse ~$operandA on line ${tokens.current.line} column ${tokens.current.col} file ${tokens.file}",
            integerType),
        tokens.current.line,
        tokens.current.col,
      );
    } else if (tokens.currentChar == TokenType.minus) {
      tokens.moveNext();
      Expression operand = coerce(
          parseNots(tokens, scope),
          "while trying to parse unary minus on line ${tokens.current.line} column ${tokens.current.col} file ${tokens.file}",
          integerType);
      return SubtractExpression(
        IntLiteralExpression(0, -1, -1),
        operand,
        tokens.current.line,
        tokens.current.col,
      );
    } else if (tokens.currentChar == TokenType.plus) {
      tokens.moveNext();
      return coerce(
          parseNots(tokens, scope),
          "while trying to parse unary plus on line ${tokens.current.line} column ${tokens.current.col} file ${tokens.file}",
          integerType);
    }
  }
  Expression operand = parseFunCalls(tokens, scope);
  return operand;
}

class NotExpression extends Expression {
  final Expression a;

  NotExpression(this.a, int line, int col) : super(line, col);
  @override
  ValueWrapper eval(Scope scope) {
    return ValueWrapper(booleanType, !a.eval(scope).value);
  }

  ValueType get type => booleanType;
}

class BitNotExpression extends Expression {
  final Expression a;

  BitNotExpression(this.a, int line, int col) : super(line, col);
  @override
  ValueWrapper eval(Scope scope) {
    return ValueWrapper(integerType, ~a.eval(scope).value);
  }

  ValueType get type => integerType;
}

Expression parseMulDivRem(TokenIterator tokens, TypeValidator scope) {
  Expression operandA = parseNots(tokens, scope);
  if (tokens.current is CharToken) {
    if (tokens.currentChar == TokenType.multiply) {
      tokens.moveNext();
      Expression operandB = parseMulDivRem(tokens, scope);
      return MultiplyExpression(
        coerce(
          operandA,
          "while trying to parse $operandA*$operandB on line ${tokens.current.line} column ${tokens.current.col} file ${tokens.file}",
          integerType,
        ),
        coerce(
          operandB,
          "while trying to parse $operandA*$operandB on line ${tokens.current.line} column ${tokens.current.col} file ${tokens.file}",
          integerType,
        ),
        tokens.current.line,
        tokens.current.col,
      );
    } else if (tokens.currentChar == TokenType.divide) {
      tokens.moveNext();
      Expression operandB = parseMulDivRem(tokens, scope);
      return DivideExpression(
        coerce(
          operandA,
          "while trying to parse $operandA/$operandB on line ${tokens.current.line} column ${tokens.current.col} file ${tokens.file}",
          integerType,
        ),
        coerce(
          operandB,
          "while trying to parse $operandA/$operandB on line ${tokens.current.line} column ${tokens.current.col} file ${tokens.file}",
          integerType,
        ),
        tokens.current.line,
        tokens.current.col,
      );
    } else if (tokens.currentChar == TokenType.remainder) {
      tokens.moveNext();
      Expression operandB = parseMulDivRem(tokens, scope);
      return RemainderExpression(
        coerce(
          operandA,
          "while trying to parse $operandA%$operandB on line ${tokens.current.line} column ${tokens.current.col} file ${tokens.file}",
          integerType,
        ),
        coerce(
          operandB,
          "while trying to parse $operandA%$operandB on line ${tokens.current.line} column ${tokens.current.col} file ${tokens.file}",
          integerType,
        ),
        tokens.current.line,
        tokens.current.col,
      );
    }
  }
  return operandA;
}

class MultiplyExpression extends Expression {
  final Expression a;
  final Expression b;

  MultiplyExpression(this.a, this.b, int line, int col) : super(line, col);
  @override
  ValueWrapper eval(Scope scope) {
    return ValueWrapper(integerType, a.eval(scope).value * b.eval(scope).value);
  }

  ValueType get type => integerType;
}

class DivideExpression extends Expression {
  final Expression a;
  final Expression b;

  DivideExpression(this.a, this.b, int line, int col) : super(line, col);
  @override
  ValueWrapper eval(Scope scope) {
    return ValueWrapper(
        integerType, a.eval(scope).value ~/ b.eval(scope).value);
  }

  ValueType get type => integerType;
}

class RemainderExpression extends Expression {
  final Expression a;
  final Expression b;

  RemainderExpression(this.a, this.b, int line, int col) : super(line, col);
  @override
  ValueWrapper eval(Scope scope) {
    ValueWrapper bVal = b.eval(scope);
    ValueWrapper aVal = a.eval(scope);
    if (bVal.value == 0) {
      throw FileInvalid(
          "$a (${aVal.value}) % $b (0) attempted line $line col $col stack ${scope.stack.join('\n')}");
    }
    return ValueWrapper(integerType, aVal.value % bVal.value);
  }

  ValueType get type => integerType;
}

Expression parseAddSub(TokenIterator tokens, TypeValidator scope) {
  Expression operandA = parseMulDivRem(tokens, scope);
  if (tokens.current is CharToken) {
    if (tokens.currentChar == TokenType.plus) {
      tokens.moveNext();
      Expression operandB = parseAddSub(tokens, scope);
      return AddExpression(
        quirksMode
            ? operandA
            : coerce(
                operandA,
                "while trying to parse $operandA+$operandB on line ${tokens.current.line} column ${tokens.current.col} file ${tokens.file}",
                integerType,
              ),
        quirksMode
            ? operandB
            : coerce(
                operandB,
                "while trying to parse $operandA+$operandB on line ${tokens.current.line} column ${tokens.current.col} file ${tokens.file}",
                integerType,
              ),
        tokens.current.line,
        tokens.current.col,
      );
    } else if (tokens.currentChar == TokenType.minus) {
      tokens.moveNext();
      Expression operandB = parseAddSub(tokens, scope);
      return SubtractExpression(
        coerce(
          operandA,
          "while trying to parse $operandA-$operandB on line ${tokens.current.line} column ${tokens.current.col} file ${tokens.file}",
          integerType,
        ),
        coerce(
          operandB,
          "while trying to parse $operandA-$operandB on line ${tokens.current.line} column ${tokens.current.col} file ${tokens.file}",
          integerType,
        ),
        tokens.current.line,
        tokens.current.col,
      );
    }
  }
  return operandA;
}

class SubtractExpression extends Expression {
  final Expression a;
  final Expression b;

  SubtractExpression(this.a, this.b, int line, int col) : super(line, col);
  @override
  ValueWrapper eval(Scope scope) {
    return ValueWrapper(integerType, a.eval(scope).value - b.eval(scope).value);
  }

  String toString() => "($a) - ($b)";

  ValueType get type => integerType;
}

class AddExpression extends Expression {
  final Expression a;
  final Expression b;

  AddExpression(this.a, this.b, int line, int col) : super(line, col);
  @override
  ValueWrapper eval(Scope scope) {
    ValueWrapper av = a.eval(scope);
    return ValueWrapper(av.type, av.value + b.eval(scope).value);
  }

  String toString() => "$a + $b";

  ValueType get type => integerType;
}

Expression parseBitShifts(TokenIterator tokens, TypeValidator scope) {
  Expression operandA = parseAddSub(tokens, scope);
  if (tokens.current is CharToken) {
    if (tokens.currentChar == TokenType.leftShift) {
      tokens.moveNext();
      Expression operandB = parseBitShifts(tokens, scope);
      return ShiftLeftExpression(
        coerce(
          operandA,
          "while trying to parse $operandA<<$operandB on line ${tokens.current.line} column ${tokens.current.col} file ${tokens.file}",
          integerType,
        ),
        coerce(
          operandB,
          "while trying to parse $operandA<<$operandB on line ${tokens.current.line} column ${tokens.current.col} file ${tokens.file}",
          integerType,
        ),
        tokens.current.line,
        tokens.current.col,
      );
    } else if (tokens.currentChar == TokenType.rightShift) {
      tokens.moveNext();
      Expression operandB = parseBitShifts(tokens, scope);
      return ShiftRightExpression(
        coerce(
          operandA,
          "while trying to parse $operandA>>$operandB on line ${tokens.current.line} column ${tokens.current.col} file ${tokens.file}",
          integerType,
        ),
        coerce(
          operandB,
          "while trying to parse $operandA>>$operandB on line ${tokens.current.line} column ${tokens.current.col} file ${tokens.file}",
          integerType,
        ),
        tokens.current.line,
        tokens.current.col,
      );
    }
  }
  return operandA;
}

class ShiftRightExpression extends Expression {
  final Expression a;
  final Expression b;

  ShiftRightExpression(this.a, this.b, int line, int col) : super(line, col);
  @override
  ValueWrapper eval(Scope scope) {
    return ValueWrapper(
        integerType, a.eval(scope).value >> b.eval(scope).value);
  }

  ValueType get type => integerType;
}

class ShiftLeftExpression extends Expression {
  final Expression a;
  final Expression b;

  ShiftLeftExpression(this.a, this.b, int line, int col) : super(line, col);
  @override
  ValueWrapper eval(Scope scope) {
    return ValueWrapper(
        integerType, a.eval(scope).value << b.eval(scope).value);
  }

  ValueType get type => integerType;
}

Expression parseRelOp(TokenIterator tokens, TypeValidator scope) {
  Expression operandA = parseBitShifts(tokens, scope);
  if (tokens.current is CharToken) {
    if (tokens.currentChar == TokenType.less) {
      tokens.moveNext();
      Expression operandB = parseRelOp(tokens, scope);
      return LessExpression(
        coerce(
          operandA,
          "while trying to parse $operandA<$operandB on line ${tokens.current.line} column ${tokens.current.col} file ${tokens.file}",
          integerType,
        ),
        coerce(
          operandB,
          "while trying to parse $operandA<$operandB on line ${tokens.current.line} column ${tokens.current.col} file ${tokens.file}",
          integerType,
        ),
        tokens.current.line,
        tokens.current.col,
      );
    } else if (tokens.currentChar == TokenType.lessEqual) {
      tokens.moveNext();
      Expression operandB = parseRelOp(tokens, scope);
      return OrExpression(
        LessExpression(
          coerce(
            operandA,
            "while trying to parse $operandA<=$operandB on line ${tokens.current.line} column ${tokens.current.col} file ${tokens.file}",
            integerType,
          ),
          coerce(
            operandB,
            "while trying to parse $operandA<=$operandB on line ${tokens.current.line} column ${tokens.current.col} file ${tokens.file}",
            integerType,
          ),
          tokens.current.line,
          tokens.current.col,
        ),
        EqualsExpression(
          coerce(
            operandA,
            "internal error",
            integerType,
          ),
          coerce(
            operandB,
            "internal error...",
            integerType,
          ),
          tokens.current.line,
          tokens.current.col,
        ),
        tokens.current.line,
        tokens.current.col,
      );
    } else if (tokens.currentChar == TokenType.greater) {
      tokens.moveNext();
      Expression operandB = parseRelOp(tokens, scope);
      return GreaterExpression(
        coerce(
          operandA,
          "while trying to parse $operandA*$operandB on line ${tokens.current.line} column ${tokens.current.col} file ${tokens.file}",
          integerType,
        ),
        coerce(
            operandB,
            "while trying to parse $operandA*$operandB on line ${tokens.current.line} column ${tokens.current.col} file ${tokens.file}",
            integerType),
        tokens.current.line,
        tokens.current.col,
      );
    } else if (tokens.currentChar == TokenType.greaterEqual) {
      tokens.moveNext();
      Expression operandB = parseRelOp(tokens, scope);
      return OrExpression(
        GreaterExpression(
          coerce(
            operandA,
            "while trying to parse $operandA>=$operandB on line ${tokens.current.line} column ${tokens.current.col} file ${tokens.file}",
            integerType,
          ),
          coerce(
            operandB,
            "while trying to parse $operandA>=$operandB on line ${tokens.current.line} column ${tokens.current.col} file ${tokens.file}",
            integerType,
          ),
          tokens.current.line,
          tokens.current.col,
        ),
        EqualsExpression(
          coerce(
            operandA,
            'Internal error',
            integerType,
          ),
          coerce(
            operandB,
            'Internal Error',
            integerType,
          ),
          tokens.current.line,
          tokens.current.col,
        ),
        tokens.current.line,
        tokens.current.col,
      );
    }
  }
  return operandA;
}

class GreaterExpression extends Expression {
  final Expression a;
  final Expression b;

  GreaterExpression(this.a, this.b, int line, int col) : super(line, col);
  @override
  ValueWrapper eval(Scope scope) {
    return ValueWrapper(booleanType, a.eval(scope).value > b.eval(scope).value);
  }

  String toString() => "$a > $b";

  ValueType get type => booleanType;
}

class LessExpression extends Expression {
  final Expression a;
  final Expression b;

  LessExpression(this.a, this.b, int line, int col) : super(line, col);
  @override
  ValueWrapper eval(Scope scope) {
    return ValueWrapper(booleanType, a.eval(scope).value < b.eval(scope).value);
  }

  ValueType get type => booleanType;
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
        ),
        tokens.current.line,
        tokens.current.col,
      );
    }
  }
  return operandA;
}

class EqualsExpression extends Expression {
  final Expression a;
  final Expression b;

  EqualsExpression(this.a, this.b, int line, int col) : super(line, col);
  @override
  ValueWrapper eval(Scope scope) {
    ValueWrapper ea = a.eval(scope);
    ValueWrapper eb = b.eval(scope);
    return ValueWrapper(
        booleanType, ea.type == eb.type && ea.value == eb.value);
  }

  String toString() => "$a == $b";

  ValueType get type => booleanType;
}

class BitAndExpression extends Expression {
  final Expression a;
  final Expression b;

  BitAndExpression(this.a, this.b, int line, int col) : super(line, col);
  @override
  ValueWrapper eval(Scope scope) {
    return ValueWrapper(integerType, a.eval(scope).value & b.eval(scope).value);
  }

  ValueType get type => integerType;

  static Expression parse(TokenIterator tokens, TypeValidator scope) {
    Expression operandA = parseEqNeq(tokens, scope);
    if (tokens.current is CharToken && tokens.currentChar == TokenType.bitAnd) {
      tokens.moveNext();
      Expression operandB = BitAndExpression.parse(tokens, scope);
      return BitAndExpression(
        coerce(operandA, 'while parsing $operandA&$operandB', integerType),
        coerce(operandB, 'while parsing $operandA&$operandB', integerType),
        tokens.current.line,
        tokens.current.col,
      );
    }
    return operandA;
  }
}

class BitXorExpression extends Expression {
  final Expression a;
  final Expression b;

  BitXorExpression(this.a, this.b, int line, int col) : super(line, col);
  @override
  ValueWrapper eval(Scope scope) {
    return ValueWrapper(integerType, a.eval(scope).value ^ b.eval(scope).value);
  }

  ValueType get type => integerType;

  static Expression parse(TokenIterator tokens, TypeValidator scope) {
    Expression operandA = BitAndExpression.parse(tokens, scope);
    if (tokens.current is CharToken && tokens.currentChar == TokenType.bitXor) {
      tokens.moveNext();
      Expression operandB = BitXorExpression.parse(tokens, scope);
      return BitXorExpression(
        coerce(
          operandA,
          'while parsing $operandA^$operandB',
          integerType,
        ),
        coerce(
          operandB,
          'while parsing $operandA^$operandB',
          integerType,
        ),
        tokens.current.line,
        tokens.current.col,
      );
    }
    return operandA;
  }
}

class BitOrExpression extends Expression {
  final Expression a;
  final Expression b;

  ValueType type = integerType;

  BitOrExpression(this.a, this.b, int line, int col) : super(line, col);
  @override
  ValueWrapper eval(Scope scope) {
    return ValueWrapper(integerType, a.eval(scope).value | b.eval(scope).value);
  }

  static Expression parse(TokenIterator tokens, TypeValidator scope) {
    Expression operandA = BitXorExpression.parse(tokens, scope);
    if (tokens.current is CharToken && tokens.currentChar == TokenType.bitOr) {
      tokens.moveNext();
      Expression operandB = BitOrExpression.parse(tokens, scope);
      return BitOrExpression(
        coerce(operandA, 'while parsing $operandA|$operandB', integerType),
        coerce(
          operandB,
          'while parsing $operandA|$operandB',
          integerType,
        ),
        tokens.current.line,
        tokens.current.col,
      );
    }
    return operandA;
  }
}

class AndExpression extends Expression {
  final Expression a;
  final Expression b;

  AndExpression(this.a, this.b, int line, int col) : super(line, col);
  @override
  ValueWrapper eval(Scope scope) {
    return ValueWrapper(
        booleanType, a.eval(scope).value && b.eval(scope).value);
  }

  ValueType get type => booleanType;

  static Expression parse(TokenIterator tokens, TypeValidator scope) {
    Expression operandA = BitOrExpression.parse(tokens, scope);
    if (tokens.current is CharToken && tokens.currentChar == TokenType.andand) {
      tokens.moveNext();
      Expression operandB = AndExpression.parse(tokens, scope);
      return AndExpression(
        coerce(
          operandA,
          'while parsing $operandA&&$operandB',
          booleanType,
        ),
        coerce(
          operandB,
          'while parsing $operandA&&$operandB',
          booleanType,
        ),
        tokens.current.line,
        tokens.current.col,
      );
    }
    return operandA;
  }
}

class OrExpression extends Expression {
  final Expression a;
  final Expression b;

  OrExpression(this.a, this.b, int line, int col) : super(line, col);
  @override
  ValueWrapper eval(Scope scope) {
    return ValueWrapper(
        booleanType, a.eval(scope).value || b.eval(scope).value);
  }

  String toString() => "$a || $b";

  ValueType get type => booleanType;

  static Expression parse(TokenIterator tokens, TypeValidator scope) {
    Expression operandA = AndExpression.parse(tokens, scope);
    if (tokens.current is CharToken && tokens.currentChar == TokenType.oror) {
      tokens.moveNext();
      Expression operandB = OrExpression.parse(tokens, scope);
      return OrExpression(
        coerce(
          operandA,
          'while parsing $operandA||$operandB',
          booleanType,
        ),
        coerce(
          operandB,
          'while parsing $operandA||$operandB',
          booleanType,
        ),
        tokens.current.line,
        tokens.current.col,
      );
    }
    return operandA;
  }
}

Expression parseExpression(
    TokenIterator tokens, TypeValidator scope, ValueType type) {
  Expression expr = OrExpression.parse(tokens, scope);
  return coerce(
    expr,
    "while parsing expression on line ${tokens.current.line} column ${tokens.current.col} file ${tokens.file}",
    type,
  );
}

abstract class Statement {
  Statement(this.line, this.col);

  StatementResult run(Scope scope);
  final int line;
  final int col;
}

bool doneImports = false;

class ImportStatement extends Statement {
  final List<Statement> file;
  final String filename;

  ImportStatement(this.file, this.filename) : super(0, 0);

  static Map<String, MapEntry<List<Statement>, TypeValidator>> filesLoaded = {};

  factory ImportStatement.parse(TokenIterator tokens, TypeValidator scope) {
    if (doneImports) {
      throw FileInvalid(
          "cannot have import statement after non-import ${tokens.current.line}");
    }
    tokens.moveNext();
    String str = tokens.string;
    tokens.moveNext();
    if (!quirksMode) {
      tokens.expectChar(TokenType.endOfStatement);
    }
    MapEntry<List<Statement>, TypeValidator> result = filesLoaded[str] ??
        (filesLoaded[str] = parse(
          lex(File(str).readAsStringSync()),
          str,
        ));
    scope.types.addAll(result.value.types);
    return ImportStatement(result.key, str);
  }

  static Map<String, Scope> filesRan = {};

  @override
  StatementResult run(Scope scope) {
    scope.values.addAll(
        (filesRan[filename] ?? (filesRan[filename] = runProgram(file))).values);
    return StatementResult(StatementResultType.nothing);
  }
}

class TokenIterator extends Iterator<Token> {
  TokenIterator(this.tokens, this.file);

  final Iterator<Token> tokens;

  final String file;

  @override
  Token get current => doingPrevious ? previous! : tokens.current;
  String get currentIdent {
    if (current is IdentToken) {
      return (current as IdentToken).ident;
    }
    if (quirksMode) {
      return parseExpression(this, TypeValidator(), stringType)
          .eval(Scope(stack: ["quirks_special_ident"]))
          .value;
    } else {
      throw FileInvalid(
          "Expected identifier, got $current on line ${current.line} column ${current.col} file $file");
    }
  }

  TokenType get currentChar {
    if (current is! CharToken) {
      throw FileInvalid(
          "Expected character, got $current on line ${current.line} column ${current.col} file $file");
    }
    return (current as CharToken).type;
  }

  int get integer {
    if (current is IntToken) {
      return (current as IntToken).integer;
    }
    if (quirksMode) {
      return parseExpression(this, TypeValidator(), integerType)
          .eval(Scope(stack: ["quirks_special_ident"]))
          .value;
    } else {
      throw FileInvalid(
          "Expected integer, got $current on line ${current.line} column ${current.col} file $file");
    }
  }

  String get string {
    if (current is StringToken) {
      return (current as StringToken).str;
    }
    if (quirksMode) {
      return parseExpression(this, TypeValidator(), stringType)
          .eval(Scope(stack: ["quirks_special_ident"]))
          .value;
    } else {
      throw FileInvalid(
          "Expected string, got $current on line ${current.line} column ${current.col} file $file");
    }
  }

  Token? previous = null;

  bool movedNext = false;

  @override
  bool moveNext() {
    if (doingPrevious) {
      doingPrevious = false;
      return true;
    }
    if (movedNext) previous = current;
    movedNext = true;
    return tokens.moveNext();
  }

  void expectChar(TokenType char) {
    if (char != currentChar) {
      throw FileInvalid(
          "Expected $char, got $current on line ${current.line} column ${current.col} file $file");
    }
    moveNext();
  }

  bool doingPrevious = false;

  void getPrevious() {
    if (doingPrevious) {
      throw UnimplementedError("saving 2 back");
    }
    doingPrevious = true;
  }
}

class InfiniteIterable<T> extends Iterable<T> {
  InfiniteIterable(this.value);

  final T value;

  @override
  InfiniteIterator<T> get iterator => InfiniteIterator<T>(value);
}

class InfiniteIterator<T> extends Iterator<T> {
  final T value;

  InfiniteIterator(this.value);

  @override
  T get current => value;

  @override
  bool moveNext() => true;
}
