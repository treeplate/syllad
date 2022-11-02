import 'lexer.dart';
import 'parser-core.dart';
import 'expressions.dart';
import 'expression-parser.dart';
import 'runner.dart'; // for import

class SetStatement extends Statement {
  final String name;

  final Expression val;
  final List<Expression> subscripts;
  final String file;
  final String workspace;

  SetStatement(this.name, this.val, this.subscripts, int line, int col,
      this.workspace, this.file)
      : super(line, col);

  @override
  StatementResult run(Scope scope) {
    var right = val.eval(scope);
    List<int> list = subscripts
        .map((e) => e
            .eval(scope)
            .valueC(scope, scope.stack, line, col, workspace, file))
        .cast<int>()
        .toList();
    scope.setVar(name, list, right, line, col, workspace, file);
    return StatementResult(StatementResultType.nothing);
  }
}

class ImportStatement extends Statement {
  final List<Statement> file;
  final String workspace;
  final String filename;
  final String currentFilename;

  ImportStatement(this.file, this.filename, int line, int col, this.workspace,
      this.currentFilename)
      : super(line, col);

  static Map<String, Scope> filesRan = {};

  @override
  StatementResult run(Scope scope) {
    List<String> newStack = scope.stack.toList();
    newStack[newStack.length - 1] +=
        " ${formatCursorPosition(line, col, workspace, currentFilename)}";
    scope.addParent((filesRan[filename] ??
        (filesRan[filename] =
            runProgram(file, filename, scope.intrinsics, newStack))));
    return StatementResult(StatementResultType.nothing);
  }
}

class NewVarStatement extends Statement {
  final String name;

  final Expression? val;

  String toString() => "var $name = $val";

  NewVarStatement(this.name, this.val, int line, int col) : super(line, col);

  @override
  StatementResult run(Scope scope) {
    scope.values[name] =
        val?.eval(scope) ?? ValueWrapper(null, null, name, false);
    return StatementResult(StatementResultType.nothing);
  }
}

abstract class Statement {
  Statement(this.line, this.col);

  StatementResult run(Scope scope);
  final int line;
  final int col;
}

class FunctionStatement extends Statement {
  FunctionStatement(
    this.returnType,
    this.name,
    this.params,
    this.body,
    int line,
    int col,
    this.workspace,
    this.file,
  ) : super(line, col);
  final ValueType returnType;
  final String name;
  final String workspace;
  final String file;
  final Iterable<Parameter> params;
  final List<Statement> body;
  @override
  StatementResult run(Scope scope) {
    scope.values[name] = ValueWrapper(
        FunctionValueType(returnType, params.map((e) => e.type), file),
        (List<ValueWrapper> a, List<String> stack,
            [Scope? thisScope, ValueType? thisType]) {
      //print("$name called...");
      int i = 0;
      if (params is! InfiniteIterable && a.length != params.length) {
        throw FileInvalid(
            "Wrong number of arguments to $name: args $a, params $params\n${stack.reversed.join('\n')}");
      }
      String fromClass;
      if (thisScope == null) {
        fromClass = '';
      } else {
        fromClass = '${scope.declaringClass!.name}.';
      }
      Scope funscope = Scope(
          parent: thisScope ?? scope,
          stack: stack + ["$fromClass$name"],
          declaringClass: scope.declaringClass,
          debugName: "$fromClass$name");
      if (thisScope != null) {
        funscope.values['this'] =
            ValueWrapper(thisType!, thisScope, 'this (funstatement)');
      }
      if (params is List) {
        for (ValueWrapper aSub in a) {
          if (!aSub
              .typeC(funscope, funscope.stack, line, col, workspace, file)
              .isSubtypeOf(params.elementAt(i).type)) {
            throw FileInvalid(
                "Argument $i of $name, $aSub, of wrong type (${aSub.typeC(funscope, funscope.stack, line, col, workspace, file)}) expected ${params.elementAt(i).type} ${formatCursorPosition(line, col, workspace, file)}");
          }
          funscope.values[(params as List)[i++].name] = aSub;
        }
      } else {
        funscope.values[params.first.name] = ValueWrapper(
          ListValueType(sharedSupertype, 'internal'),
          List.unmodifiable(a),
          'varargs',
        );
      }
      for (Statement statement in body) {
        StatementResult value = statement.run(funscope);
        switch (value.type) {
          case StatementResultType.nothing:
            break;
          case StatementResultType.returnFunction:
            if (value.value!
                .typeC(funscope, funscope.stack, line, col, workspace, file)
                .isSubtypeOf(returnType)) return value;
            throw FileInvalid(
                "You cannot return a ${value.value!.typeC(funscope, funscope.stack, line, col, workspace, file)} (${value.value!.valueC(funscope, funscope.stack, line, col, workspace, file)}) from $fromClass$name, which is supposed to return a $returnType!     ${formatCursorPosition(line, col, workspace, file)}\n${funscope.stack.reversed.join('\n')} ");
          case StatementResultType.breakWhile:
            throw FileInvalid("Break outside while");
          case StatementResultType.continueWhile:
            throw FileInvalid("Continue outside while");
          case StatementResultType.unwindAndThrow:
            return value;
        }
      }
      if (!ValueType(null, 'Null', -2, 0, 'iterr', 'intrenal')
          .isSubtypeOf(returnType)) {
        throw FileInvalid(
            "$name has no return statement ${formatCursorPosition(line, col, workspace, file)}");
      }
      return ValueWrapper(ValueType(null, 'Null', -2, 0, 'itter', 'intrenal'),
          null, 'default return value of functions');
    }, '$name function');
    return StatementResult(StatementResultType.nothing);
  }
}

class WhileStatement extends Statement {
  final bool createParentScope;
  final String kind;
  final String workspace;
  final String file;

  WhileStatement(this.cond, this.body, int line, int col, this.kind,
      this.workspace, this.file,
      [this.catchReturns = true, this.createParentScope = true])
      : super(line, col);
  final Expression cond;
  final List<Statement> body;
  final bool catchReturns;
  @override
  StatementResult run(Scope scope) {
    Scope whileScope = createParentScope
        ? Scope(
            parent: scope,
            stack: scope.stack,
            debugName:
                'while loop ${formatCursorPosition(line, col, workspace, file)}')
        : scope;
    while (cond
        .eval(scope)
        .valueC(whileScope, whileScope.stack, line, col, workspace, file)) {
      block:
      for (Statement statement in body) {
        StatementResult statementResult = statement.run(whileScope);
        switch (statementResult.type) {
          case StatementResultType.nothing:
            break;
          case StatementResultType.breakWhile:
            if (statementResult.value!.valueC(
                    whileScope, whileScope.stack, line, col, workspace, file) ||
                catchReturns)
              return StatementResult(StatementResultType.nothing);
            return statementResult;
          case StatementResultType.continueWhile:
            if (statementResult.value!.valueC(
                    whileScope, whileScope.stack, line, col, workspace, file) ||
                catchReturns) break block;
            return statementResult;
          case StatementResultType.returnFunction:
          case StatementResultType.unwindAndThrow:
            return statementResult;
        }
      }
    }
    return StatementResult(StatementResultType.nothing);
  }
}

class IfStatement extends Statement {
  final String workspace;

  IfStatement(this.cond, this.body, this.elseBody, int line, int col,
      this.workspace, this.file)
      : super(line, col);
  final Expression cond;
  final List<Statement> body;
  final List<Statement>? elseBody;
  final String file;
  @override
  StatementResult run(Scope scope) {
    if (cond
        .eval(scope)
        .valueC(scope, scope.stack, line, col, workspace, file)) {
      Scope ifScope = Scope(
        parent: scope,
        stack: scope.stack,
        debugName:
            'if statement - \'if\' segment scope ${formatCursorPosition(line, col, workspace, file)}',
      );
      for (Statement statement in body) {
        StatementResult statementResult = statement.run(ifScope);
        switch (statementResult.type) {
          case StatementResultType.nothing:
            break;
          case StatementResultType.breakWhile:
          case StatementResultType.continueWhile:
          case StatementResultType.returnFunction:
          case StatementResultType.unwindAndThrow:
            return statementResult;
        }
      }
    } else if (elseBody != null) {
      Scope elseScope = Scope(
        parent: scope,
        stack: scope.stack,
        debugName:
            'if statement - \'if\' segment scope ${formatCursorPosition(line, col, workspace, file)}',
      );
      for (Statement statement in elseBody!) {
        StatementResult statementResult = statement.run(elseScope);
        switch (statementResult.type) {
          case StatementResultType.nothing:
            break;
          case StatementResultType.breakWhile:
          case StatementResultType.continueWhile:
          case StatementResultType.returnFunction:
          case StatementResultType.unwindAndThrow:
            return statementResult;
        }
      }
    }
    return StatementResult(StatementResultType.nothing);
  }
}

class ForStatement extends Statement {
  ForStatement(this.list, this.body, int line, int col, this.ident,
      this.workspace, this.file,
      [this.catchBreakContinue = true])
      : super(line, col);
  final Expression list;
  final String ident;
  final List<Statement> body;
  final bool catchBreakContinue;
  final String file;
  final String workspace;
  @override
  StatementResult run(Scope scope) {
    ValueWrapper listVal = list.eval(scope);
    if (!listVal
        .typeC(scope, scope.stack, line, col, workspace, file)
        .isSubtypeOf(IterableValueType(
            ValueType(null, "Whatever", -2, 0, 'interr', 'intrinsics'),
            'TODO FORS'))) {
      throw FileInvalid(
          "$listVal ($list) is not a list (tried to do a for statement)");
    }
    for (ValueWrapper identVal
        in listVal.valueC(scope, scope.stack, line, col, workspace, file)) {
      Scope whileScope = Scope(
          parent: scope,
          stack: scope.stack,
          debugName:
              'for statement scope ${formatCursorPosition(line, col, workspace, file)}');
      whileScope.values[ident] = identVal;
      block:
      for (Statement statement in body) {
        StatementResult statementResult = statement.run(whileScope);
        switch (statementResult.type) {
          case StatementResultType.nothing:
            break;
          case StatementResultType.breakWhile:
            if (statementResult.value!.valueC(
                    whileScope, whileScope.stack, line, col, workspace, file) ||
                catchBreakContinue)
              return StatementResult(StatementResultType.nothing);
            return statementResult;
          case StatementResultType.continueWhile:
            if (statementResult.value!.valueC(
                    whileScope, whileScope.stack, line, col, workspace, file) ||
                catchBreakContinue) break block;
            return statementResult;
          case StatementResultType.returnFunction:
          case StatementResultType.unwindAndThrow:
            return statementResult;
        }
      }
    }
    return StatementResult(StatementResultType.nothing);
  }
}

class BreakStatement extends Statement {
  BreakStatement(this.alwaysBreakCurrent, int line, int col) : super(line, col);
  final bool alwaysBreakCurrent;
  @override
  StatementResult run(Scope scope) {
    return StatementResult(StatementResultType.breakWhile,
        ValueWrapper(booleanType, alwaysBreakCurrent, 'internal'));
  }

  factory BreakStatement.parse(TokenIterator tokens, TypeValidator scope) {
    tokens.moveNext();
    tokens.expectChar(TokenType.endOfStatement);
    return BreakStatement(
      false,
      tokens.current.line,
      tokens.current.col,
    );
  }
}

class ContinueStatement extends Statement {
  ContinueStatement(this.alwaysContinueCurrent, int line, int col)
      : super(line, col);
  final bool alwaysContinueCurrent;
  @override
  StatementResult run(Scope scope) {
    return StatementResult(StatementResultType.continueWhile,
        ValueWrapper(booleanType, alwaysContinueCurrent, 'internal'));
  }

  factory ContinueStatement.parse(TokenIterator tokens, TypeValidator scope) {
    tokens.moveNext();
    tokens.expectChar(TokenType.endOfStatement);
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
        BoringExpr(
            null,
            ValueType(null, "Null", tokens.current.line, tokens.current.col,
                tokens.workspace, tokens.file)),
        tokens.current.line,
        tokens.current.col,
      );
    }
    Expression expr = parseExpression(tokens, scope);
    tokens.expectChar(TokenType.endOfStatement);
    return ReturnStatement(
      expr,
      tokens.current.line,
      tokens.current.col,
    );
  }
}

class ExpressionStatement extends Statement {
  final Expression expr;

  ExpressionStatement(this.expr, int line, int col) : super(line, col);

  @override
  StatementResult run(Scope scope) {
    expr.eval(scope);
    return StatementResult(StatementResultType.nothing);
  }
}

class ClassStatement extends Statement {
  final List<Statement> block;
  final String name;
  final ClassValueType type;
  final String? superclass;
  final String workspace;
  final String file;
  ClassStatement(this.name, this.superclass, this.block, this.type, int line,
      int col, this.workspace, this.file)
      : super(line, col);

  @override
  StatementResult run(Scope scope) {
    Scope methods = Scope(
        parent: scope,
        stack: ['$name-methods'],
        declaringClass: type,
        debugName:
            'class statement - methods scope ${formatCursorPosition(line, col, workspace, file)}');
    for (Statement s in block) {
      if (s is FunctionStatement) {
        s.run(methods);
      }
    }
    scope.setVar(
      '~$name~methods',
      [],
      ValueWrapper(
        ValueType(null, '~class_methods', -2, 0, 'interr', "_internal"),
        methods,
        'internal',
      ),
      line,
      col,
      workspace,
      file,
    );
    if (methods.internal_getVar('constructor') == null) {
      if (superclass == null) {
        methods.setVar(
          'constructor',
          [],
          ValueWrapper(
              FunctionValueType(type, [], file),
              (List<ValueWrapper> args, List<String> stack, Scope thisScope,
                  ValueType thisType) {},
              'default constructor'),
          line,
          col,
          workspace,
          file,
        );
      } else {
        methods.setVar(
          'constructor',
          [],
          scope
              .getVar('~$superclass~methods', line, col, 'interr',
                  'TODO ($file) TODO', null)
              .valueC(scope, scope.stack, line, col, workspace, file)
              .getVar('constructor', line, col, 'td', 'TODO TODO', null),
          line,
          col,
          workspace,
          file,
        );
      }
    }
    scope.setVar(
        '~$name',
        [],
        ValueWrapper(FunctionValueType(type, [], file),
            (List<ValueWrapper> args, List<String> stack, Scope thisScope,
                ValueType thisType) {
          if (superclass != null) {
            scope
                    .getVar('~$superclass', line, col, workspace, 'TODO', null)
                    .valueC(scope, scope.stack, line, col, workspace, file)(
                <ValueWrapper>[],
                stack + ['~$superclass'],
                thisScope,
                thisType);
          }
          for (MapEntry<String, ValueWrapper?> x in methods.values.entries) {
            thisScope.values[x.key] = ValueWrapper(
                x.value!.typeC(scope, scope.stack, line, col, workspace, file),
                (List<ValueWrapper> args2, List<String> stack2) {
              return (x.value!
                      .valueC(scope, scope.stack, line, col, workspace, file)
                  as Function)(args2, stack2, thisScope, thisType);
            }, 'method $name.${x.key}');
          }
          for (Statement s in block) {
            if (s is NewVarStatement) {
              StatementResult sr = s.run(thisScope);
              switch (sr.type) {
                case StatementResultType.nothing:
                  break;
                case StatementResultType.breakWhile:
                case StatementResultType.continueWhile:
                case StatementResultType.returnFunction:
                  throw FileInvalid('Internal error');
                case StatementResultType.unwindAndThrow:
                  return sr;
              }
            }
          }
        }, 'internal'),
        line,
        col,
        workspace,
        file);
    bool hasConstructor = block.any((element) =>
        element is FunctionStatement && element.name == 'constructor');
    scope.setVar(
        name,
        [],
        ValueWrapper(
          FunctionValueType(
              type,
              hasConstructor
                  ? block
                      .whereType<FunctionStatement>()
                      .firstWhere((element) => element.name == 'constructor')
                      .params
                      .map((e) => e.type)
                  : superclass == null
                      ? []
                      : scope
                          .internal_getVar('~$superclass~methods')!
                          .valueC(
                              scope, scope.stack, line, col, workspace, file)
                          .internal_getVar('constructor')
                          .typeC(scope, scope.stack, line, col, workspace, file)
                          .parameters,
              file),
          (List<ValueWrapper> args, List<String> stack) {
            Scope thisScope = Scope(
                parent: scope,
                stack: stack + ['$name-instance'],
                debugName: 'instance of class');
            thisScope.values['className'] =
                ValueWrapper(stringType, name, 'className');
            scope
                    .getVar('~$name', line, col, 'tdo', 'TODO', null)
                    .valueC(scope, scope.stack, line, col, workspace, file)(
                <ValueWrapper>[], stack + ['~$name'], thisScope, type);
            (thisScope
                    .internal_getVar('constructor')
                    ?.valueC(scope, scope.stack, line, col, workspace, file) ??
                (superclass == null
                        ? (List<ValueWrapper> args, List<String> stack,
                            Scope thisScope) {}
                        : scope
                            .internal_getVar('~$superclass~methods')!
                            .valueC(
                                scope, scope.stack, line, col, workspace, file)
                            .getVar('constructor'))
                    .value)(args, stack + ['$name.constructor']);
            return ValueWrapper(type, thisScope, 'instance of $name');
          },
          'constructor',
        ),
        line,
        col,
        workspace,
        file);
    return StatementResult(StatementResultType.nothing);
  }
}
