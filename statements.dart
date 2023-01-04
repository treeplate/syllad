import 'lexer.dart';
import 'parser-core.dart';
import 'expressions.dart';
import 'expression-parser.dart';
import 'runner.dart'; // for import

class SetStatement extends Statement {
  final Variable name;

  final Expression val;
  final List<Expression> subscripts;
  final String file;
  final String workspace;

  SetStatement(this.name, this.val, this.subscripts, int line, int col, this.workspace, this.file) : super(line, col);

  @override
  StatementResult run(Scope scope) {
    var right = val.eval(scope);
    List<int> list = subscripts.map((e) => e.eval(scope).valueC(scope, scope.stack, line, col, workspace, file)).cast<int>().toList();
    scope.setVar(name, list, right, line, col, workspace, file);
    return StatementResult(StatementResultType.nothing);
  }
}

class ImportStatement extends Statement {
  final List<Statement> file;
  final String workspace;
  final String filename;
  final String currentFilename;
  final TypeValidator typeValidator;

  ImportStatement(this.file, this.filename, int line, int col, this.workspace, this.currentFilename, this.typeValidator) : super(line, col);

  static Map<String, Scope> filesRan = {};

  @override
  StatementResult run(Scope scope) {
    List<LazyString> newStack = scope.stack.toList();
    if (newStack.last is NotLazyString) {
      newStack[newStack.length - 1] = CursorPositionLazyString((newStack.last as NotLazyString).str, line, col, workspace, currentFilename);
    }
    scope.addParent((filesRan[filename] ?? (filesRan[filename] = runProgram(file, filename, workspace, scope.intrinsics, typeValidator, null, newStack))));
    return StatementResult(StatementResultType.nothing);
  }
}

class NewVarStatement extends Statement {
  final Variable name;

  final Expression? val;

  String toString() => "var $name = $val";

  NewVarStatement(this.name, this.val, int line, int col) : super(line, col);

  @override
  StatementResult run(Scope scope) {
    scope.values[name] = val?.eval(scope) ?? ValueWrapper(null, null, name, false);
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
  final Variable name;
  final String workspace;
  final String file;
  final Iterable<Parameter> params;
  final List<Statement> body;
  @override
  StatementResult run(Scope scope) {
    SydFunction<Object?> _value = (List<ValueWrapper> a, List<LazyString> stack, [Scope? thisScope, ValueType? thisType]) {
      String fromClass;
      if (thisScope == null) {
        fromClass = '';
      } else {
        fromClass = '${scope.declaringClass!.name.name}.';
      }
      profile[variables["${fromClass}${name.name}"] ??= Variable("${fromClass}${name.name}")] ??= MapEntry(Stopwatch(), 0);
      profile[variables["${fromClass}${name.name}"] ??= Variable("${fromClass}${name.name}")]!.key.start();
      profile[variables["${fromClass}${name.name}"] ??= Variable("${fromClass}${name.name}")] = MapEntry(
          profile[variables["${fromClass}${name.name}"] ??= Variable("${fromClass}${name.name}")]!.key,
          profile[variables["${fromClass}${name.name}"] ??= Variable("${fromClass}${name.name}")]!.value + 1);
      int i = 0;
      if (params is! InfiniteIterable && a.length != params.length) {
        throw BSCException(
            "Wrong number of arguments to ${fromClass}${name.name}: args $a, params $params ${formatCursorPosition(line, col, workspace, file)}\n ${stack.reversed.join('\n')} ");
      }
      Scope funscope = Scope(false,
          parent: thisScope ?? scope,
          stack: stack + [NotLazyString("${fromClass}${name.name}")],
          declaringClass: scope.declaringClass,
          debugName: NotLazyString("${fromClass}${name.name}"));
      if (params is List) {
        for (ValueWrapper aSub in a) {
          if (!aSub.typeC(funscope, funscope.stack, line, col, workspace, file).isSubtypeOf(params.elementAt(i).type)) {
            throw BSCException(
                "Argument $i of $name, $aSub, of wrong type (${aSub.typeC(funscope, funscope.stack, line, col, workspace, file)}) expected ${params.elementAt(i).type} ${formatCursorPosition(line, col, workspace, file)}");
          }
          funscope.values[(params as List)[i++].name] = aSub;
        }
      } else {
        funscope.values[params.first.name] = ValueWrapper(
          ListValueType(sharedSupertype, 'internal'),
          List<ValueWrapper>.unmodifiable(a),
          'varargs',
        );
      }
      for (Statement statement in body) {
        StatementResult value = statement.run(funscope);
        switch (value.type) {
          case StatementResultType.nothing:
            break;
          case StatementResultType.returnFunction:
            profile[variables["${fromClass}${name.name}"] ??= Variable("${fromClass}${name.name}")]!.key.stop();

            if (value.value!.typeC(funscope, funscope.stack, line, col, workspace, file).isSubtypeOf(returnType)) return value.value!;
            throw BSCException(
                "You cannot return a ${value.value!.typeC(funscope, funscope.stack, line, col, workspace, file)} (${value.value!}) from ${fromClass}${name.name}, which is supposed to return a $returnType!     ${formatCursorPosition(line, col, workspace, file)}\n${funscope.stack.reversed.join('\n')} ");
          case StatementResultType.breakWhile:
            throw BSCException("Break outside while");
          case StatementResultType.continueWhile:
            throw BSCException("Continue outside while");
          case StatementResultType.unwindAndThrow:
            profile[variables["${fromClass}${name.name}"] ??= Variable("${fromClass}${name.name}")]!.key.stop();

            throw value.value!;
        }
      }
      if (!nullType.isSubtypeOf(returnType)) {
        throw BSCException("$name has no return statement ${formatCursorPosition(line, col, workspace, file)}");
      }
      profile[variables["${fromClass}${name.name}"] ??= Variable("${fromClass}${name.name}")]!.key.stop();

      return ValueWrapper<Null>(nullType, null, 'default return value of functions');
    };
    scope.values[name] = ValueWrapper<SydFunction<Object?>>(FunctionValueType(returnType, params.map((e) => e.type), file), _value, '$name function');
    return StatementResult(StatementResultType.nothing);
  }
}

class WhileStatement extends Statement {
  final bool createParentScope;
  final String kind;
  final String workspace;
  final String file;

  WhileStatement(this.cond, this.body, int line, int col, this.kind, this.workspace, this.file, [this.catchReturns = true, this.createParentScope = true])
      : super(line, col);
  final Expression cond;
  final List<Statement> body;
  final bool catchReturns;
  @override
  StatementResult run(Scope scope) {
    Scope whileScope = createParentScope
        ? Scope(
            false,
            parent: scope,
            stack: scope.stack,
            debugName: CursorPositionLazyString('while loop', line, col, workspace, file),
          )
        : scope;
    while (cond.eval(scope).valueC(whileScope, whileScope.stack, line, col, workspace, file)) {
      block:
      for (Statement statement in body) {
        StatementResult statementResult = statement.run(whileScope);
        switch (statementResult.type) {
          case StatementResultType.nothing:
            break;
          case StatementResultType.breakWhile:
            if (statementResult.value!.valueC(whileScope, whileScope.stack, line, col, workspace, file) || catchReturns)
              return StatementResult(StatementResultType.nothing);
            return statementResult;
          case StatementResultType.continueWhile:
            if (statementResult.value!.valueC(whileScope, whileScope.stack, line, col, workspace, file) || catchReturns) break block;
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

class NamespaceStatement extends Statement {
  final String workspace;
  final String file;
  final Variable namespace;

  NamespaceStatement(
    this.body,
    int line,
    int col,
    this.workspace,
    this.file,
    this.namespace,
  ) : super(line, col);
  final List<Statement> body;
  @override
  StatementResult run(Scope scope) {
    Scope whileScope = NamespaceScope(
      scope,
      namespace,
    );
    for (Statement statement in body) {
      StatementResult statementResult = statement.run(whileScope);
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
    return StatementResult(StatementResultType.nothing);
  }
}

class IfStatement extends Statement {
  final String workspace;

  IfStatement(this.cond, this.body, this.elseBody, int line, int col, this.workspace, this.file) : super(line, col);
  final Expression cond;
  final List<Statement> body;
  final List<Statement>? elseBody;
  final String file;
  @override
  StatementResult run(Scope scope) {
    if (cond.eval(scope).valueC(scope, scope.stack, line, col, workspace, file)) {
      Scope ifScope = Scope(
        false,
        parent: scope,
        stack: scope.stack,
        debugName: CursorPositionLazyString(
          'if statement - \'if\' segment scope',
          line,
          col,
          workspace,
          file,
        ),
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
        false,
        parent: scope,
        stack: scope.stack,
        debugName: CursorPositionLazyString(
          'if statement - \'else\' segment scope',
          line,
          col,
          workspace,
          file,
        ),
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
  ForStatement(this.list, this.body, int line, int col, this.ident, this.workspace, this.file, [this.catchBreakContinue = true]) : super(line, col);
  final Expression list;
  final Variable ident;
  final List<Statement> body;
  final bool catchBreakContinue;
  final String file;
  final String workspace;
  @override
  StatementResult run(Scope scope) {
    ValueWrapper listVal = list.eval(scope);
    if (!listVal
        .typeC(scope, scope.stack, line, col, workspace, file)
        .isSubtypeOf(IterableValueType(ValueType.create(null, whateverVariable, -2, 0, 'interr', 'intrinsics'), 'TODO FORS'))) {
      throw BSCException(
          "$listVal ($list) is not a list - is a ${listVal.typeC(scope, scope.stack, line, col, workspace, file)} (tried to do a for statement) ${formatCursorPosition(line, col, workspace, file)}");
    }
    for (ValueWrapper identVal in listVal.valueC(scope, scope.stack, line, col, workspace, file)) {
      Scope whileScope = Scope(
        false,
        parent: scope,
        stack: scope.stack,
        debugName: CursorPositionLazyString(
          'for statement scope',
          line,
          col,
          workspace,
          file,
        ),
      );
      whileScope.values[ident] = identVal;
      block:
      for (Statement statement in body) {
        StatementResult statementResult = statement.run(whileScope);
        switch (statementResult.type) {
          case StatementResultType.nothing:
            break;
          case StatementResultType.breakWhile:
            if (statementResult.value!.valueC(whileScope, whileScope.stack, line, col, workspace, file) || catchBreakContinue)
              return StatementResult(StatementResultType.nothing);
            return statementResult;
          case StatementResultType.continueWhile:
            if (statementResult.value!.valueC(whileScope, whileScope.stack, line, col, workspace, file) || catchBreakContinue) break block;
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
    return StatementResult(StatementResultType.breakWhile, ValueWrapper(booleanType, alwaysBreakCurrent, 'internal'));
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
  ContinueStatement(this.alwaysContinueCurrent, int line, int col) : super(line, col);
  final bool alwaysContinueCurrent;
  @override
  StatementResult run(Scope scope) {
    return StatementResult(StatementResultType.continueWhile, ValueWrapper(booleanType, alwaysContinueCurrent, 'internal'));
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
    return StatementResult(StatementResultType.returnFunction, value.eval(scope));
  }

  factory ReturnStatement.parse(TokenIterator tokens, TypeValidator scope) {
    tokens.moveNext();
    if (tokens.current is CharToken && tokens.currentChar == TokenType.endOfStatement) {
      tokens.moveNext();
      return ReturnStatement(
        BoringExpr(null, nullType),
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
  final Variable name;
  final ClassValueType type;
  final Variable? superclass;
  final String workspace;
  final String file;
  ClassStatement(this.name, this.superclass, this.block, this.type, int line, int col, this.workspace, this.file) : super(line, col);

  @override
  StatementResult run(Scope scope) {
    Scope methods = Scope(
      false,
      parent: scope,
      stack: [NotLazyString('${name.name}-methods')],
      declaringClass: type,
      debugName: CursorPositionLazyString(
        'class statement - methods scope',
        line,
        col,
        workspace,
        file,
      ),
    );
    for (Statement s in block) {
      if (s is FunctionStatement) {
        s.run(methods);
      }
    }
    scope.setVar(
      variables['~${name.name}~methods'] ??= Variable('~${name.name}~methods'),
      [],
      ValueWrapper(
        ValueType.create(null, classMethodsVariable, -2, 0, 'interr', "_internal"),
        methods,
        'internal',
      ),
      line,
      col,
      workspace,
      file,
    );
    Variable constructorsClassName = name;
    if (methods.internal_getVar(constructorVariable) == null) {
      if (superclass != null &&
          scope.internal_getVar(
                variables['~${superclass!.name}~methods'] ??= Variable('~${superclass!.name}~methods'),
              ) ==
              null) {
        throwWithStack(
            scope,
            [
              CursorPositionLazyString('main', 1, 0, file, workspace),
              CursorPositionLazyString(
                'defining $name which extends $superclass',
                line,
                col,
                file,
                workspace,
              ),
              NotLazyString('inheriting constructor'),
            ],
            'have not defined superclass $superclass');
      }
      if (superclass == null) {
        methods.setVar(
          constructorVariable,
          [],
          ValueWrapper(FunctionValueType(type, [], file), (List<ValueWrapper> args, List<LazyString> stack, [Scope? thisScope, ValueType? thisType]) {
            if (args.length != 0) {
              throwWithStack(
                scope,
                stack,
                'default constructor takes no arguments - passed ${args.length} arguments ${StackTrace.current}',
              );
            }
            return ValueWrapper<Null>(nullType, null, 'null from default constructor a');
          }, 'default constructor - aaaa'),
          line,
          col,
          workspace,
          file,
        );
      } else {
        constructorsClassName =
            type.recursiveLookup(constructorVariable)?.value.name ?? (variables['default constructor - bbbb'] ??= Variable('default constructor - bbbb'));
        ;
        methods.setVar(
          constructorVariable,
          [],
          scope
              .getVar(variables['~${superclass!.name}~methods'] ??= Variable('~${superclass!.name}~methods'), line, col, 'interr', 'TODO ($file) TODO', null)
              .valueC<Scope>(scope, scope.stack, line, col, workspace, file)
              .getVar(constructorVariable, line, col, 'td', 'TODO TODO', null),
          line,
          col,
          workspace,
          file,
        );
      }
    }
    scope.setVar(
        variables['~${name.name}'] ??= Variable('~${name.name}'),
        [],
        ValueWrapper(FunctionValueType(type, [], file), (List<ValueWrapper> args, List<LazyString> stack, [Scope? thisScope, ValueType? thisType]) {
          if (superclass != null) {
            scope.getVar(variables['~${superclass!.name}'] ??= Variable('~${superclass!.name}'), line, col, workspace, 'TODO', null).valueC<SydFunction>(
                scope, scope.stack, line, col, workspace, file)(<ValueWrapper>[], stack + [NotLazyString('~${superclass!.name}')], thisScope, thisType);
          }
          for (MapEntry<Variable, ValueWrapper?> x in methods.values.entries) {
            thisScope!.values[x.key] = ValueWrapper(x.value!.typeC(scope, scope.stack, line, col, workspace, file),
                (List<ValueWrapper> args2, List<LazyString> stack2, [Scope? thisScope2, ValueType? thisType2]) {
              return (x.value!.valueC<SydFunction<Object?>>(scope, scope.stack, line, col, workspace, file))(args2, stack2, thisScope, thisType);
            }, 'method ${x.key == constructorVariable ? constructorsClassName.name : name.name}.${x.key.name}');
            thisScope.values[thisVariable] = ValueWrapper(thisType, thisScope, '\'this\' property');
          }
          for (Statement s in block) {
            if (s is NewVarStatement) {
              StatementResult sr = s.run(thisScope!);
              switch (sr.type) {
                case StatementResultType.nothing:
                  break;
                case StatementResultType.breakWhile:
                case StatementResultType.continueWhile:
                case StatementResultType.returnFunction:
                  throw BSCException('Internal error');
                case StatementResultType.unwindAndThrow:
                  throw sr.value!;
              }
            }
          }
          return ValueWrapper(nullType, null, 'return value of ~$name');
        }, 'internal'),
        line,
        col,
        workspace,
        file);
    bool hasConstructor = block.any((element) => element is FunctionStatement && element.name == constructorVariable);
    scope.setVar(
        name,
        [],
        ValueWrapper(
          FunctionValueType(
              type,
              hasConstructor
                  ? block.whereType<FunctionStatement>().firstWhere((element) => element.name == constructorVariable).params.map((e) => e.type)
                  : superclass == null
                      ? []
                      : (scope
                              .internal_getVar(variables['~${superclass!.name}~methods'] ?? Variable('~${superclass!.name}~methods'))
                              ?.valueC<Scope>(scope, scope.stack, line, col, workspace, file)
                              .internal_getVar(constructorVariable)
                              ?.typeC(scope, scope.stack, line, col, workspace, file) as FunctionValueType)
                          .parameters,
              file),
          (List<ValueWrapper> args, List<LazyString> stack, [Scope? thisScope, ValueType? thisType]) {
            Scope thisScope = Scope(
              true,
              parent: scope,
              stack: stack + [NotLazyString('${name.name}-instance')],
              debugName: NotLazyString('instance of ${name.name}'),
              typeIfClass: type,
            );
            thisScope.values[classNameVariable] = ValueWrapper(stringType, name.name, 'className');
            scope
                .getVar(variables['~${name.name}'] ??= Variable('~${name.name}'), line, col, 'tdo', 'TODO', null)
                .valueC<SydFunction>(scope, scope.stack, line, col, workspace, file)(<ValueWrapper>[], stack + [NotLazyString('~$name')], thisScope, type);
            var constructorFunc =
                thisScope.internal_getVar(constructorVariable)?.valueC<SydFunction<Object?>>(scope, scope.stack, line, col, workspace, file) ??
                    (superclass == null
                        ? (List<ValueWrapper> args, List<LazyString> stack, [Scope? thisScope, ValueType? thisType]) {
                            return ValueWrapper<Null>(nullType, null, 'null from default constructor');
                          }
                        : (scope
                                .internal_getVar(variables['~${superclass!.name}~methods'] ?? Variable('~${superclass!.name}~methods'))!
                                .valueC<Scope>(scope, scope.stack, line, col, workspace, file)
                                .internal_getVar(constructorVariable)!)
                            .valueC<SydFunction<Object?>>(scope, stack, line, col, workspace, file));
            constructorFunc(args, stack + [NotLazyString('${name.name}.constructor (from generated constructor)')], thisScope, type);
            return ValueWrapper<Scope>(type, thisScope, 'instance of ${name.name}');
          },
          constructorVariable,
        ),
        line,
        col,
        workspace,
        file);
    return StatementResult(StatementResultType.nothing);
  }
}
