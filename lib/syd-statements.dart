import 'dart:io';

import 'syd-lexer.dart';
import 'syd-core.dart';
import 'syd-expressions.dart';
import 'syd-expression-parser.dart';
import 'syd-runner.dart'; // for import

class SetStatement extends Statement {
  final Expression l;

  final Expression val;
  final String file;
  final String workspace;

  SetStatement(this.l, this.val, int line, int col, this.workspace, this.file) : super(line, col);

  @override
  StatementResult run(Scope scope) {
    var right = val.eval(scope);
    scope.setVar(l, right, false, line, col, workspace, file);
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

  @override
  StatementResult run(Scope scope) {
    List<LazyString> newStack = scope.stack.toList();
    newStack[newStack.length - 1] = ConcatenateLazyString(newStack.last, CursorPositionLazyString('', line, col, workspace, currentFilename));
    scope.addParent((scope.environment.filesRan[filename] ??
        (scope.environment.filesRan[filename] = runProgram(file, filename, workspace, scope.intrinsics, scope.rtl, typeValidator, false,
            false /* debug and profile mode are only for the main program */, stdout, stderr, exit, ['INTERPRETER ERROR'], newStack))));
    return StatementResult(StatementResultType.nothing);
  }
}

class NewVarStatement extends Statement {
  final Variable name;
  final bool isConstant;

  final Expression? val;
  final ValueType type;

  final String workspace;
  final String file;

  final TypeValidator tv;

  String toString() => "var $name = $val";

  NewVarStatement(this.name, this.val, int line, int col, this.workspace, this.file, this.isConstant, this.type, this.tv) : super(line, col);

  @override
  StatementResult run(Scope scope) {
    ValueWrapper<Object?>? eval = val?.eval(scope);
    if (eval != null) {
      if (!eval.typeC(scope, scope.stack, line, col, workspace, file, scope.environment).isSubtypeOf(type)) {
        throw BSCException(
            "Variable ${name.name} of type $type cannot be initialized to a value of type ${eval.typeC(scope, scope.stack, line, col, workspace, file, scope.environment)} ${formatCursorPosition(line, col, workspace, file)}",
            scope);
      }
    }
    scope.values[name] = MaybeConstantValueWrapper(
        eval ??
            ValueWrapper(ValueType.createNullable(null, scope.variables['Sentinel'] ??= Variable('Sentinel'), 'iddk', tv)!, "Sentinull",
                VariableLazyString(name), false),
        isConstant);
    return StatementResult(StatementResultType.nothing);
  }
}

class StaticFieldStatement extends Statement {
  final Variable name;
  final bool isConstant;

  final Expression val;

  String toString() => "static $name = $val";

  StaticFieldStatement(this.name, this.val, int line, int col, this.isConstant) : super(line, col);

  @override
  StatementResult run(Scope scope) {
    return StatementResult(StatementResultType.nothing); // StaticMemberStatement is dealt with specially
  }
}

class FunctionStatement extends Statement {
  FunctionStatement(this.returnType, this.name, this.params, this.body, int line, int col, this.workspace, this.file, this.static, this.type, this.tv)
      : super(line, col);
  final ValueType returnType;
  final Variable name;
  final String workspace;
  final String file;
  final Iterable<Parameter> params;
  final List<Statement> body;
  final bool static;
  final ValueType type;
  final TypeValidator tv;
  @override
  StatementResult run(Scope scope) {
    SydFunction<Object?> _value = (List<ValueWrapper> a, List<LazyString> stack, [Scope? thisScope, ValueType? thisType]) {
      LazyString fromClass;
      if (static) {
        fromClass = ConcatenateLazyString(
          ConcatenateLazyString(
            NotLazyString('static '),
            NotLazyString(scope.currentStaticClass?.staticClassName ?? 'ierror'),
          ),
          NotLazyString('.'),
        );
      } else if (thisScope == null || scope.currentClass == null) {
        fromClass = NotLazyString('');
      } else {
        fromClass = ConcatenateLazyString(
          NotLazyString(scope.currentClass!.name.name),
          NotLazyString('.'),
        );
      }
      Variable? ourProfile;
      if ((scope.intrinsics ?? scope).profileMode!) {
        ourProfile = scope.variables["${fromClass}${name.name}"] ??= Variable("${fromClass}${name.name}");

        scope.environment.profile[ourProfile] ??= MapEntry(Stopwatch(), 0);
        scope.environment.profile[ourProfile]!.key.start();
        scope.environment.profile[ourProfile] = MapEntry(scope.environment.profile[ourProfile]!.key, scope.environment.profile[ourProfile]!.value + 1);
      }
      int i = 0;
      if (params is! InfiniteIterable && a.length != params.length) {
        throw BSCException(
            "Wrong number of arguments to ${fromClass}${name.name}: args ${a.map((e) => e.toStringWithStack(stack, line, col, workspace, file, false, scope.environment))}, params $params ${formatCursorPosition(line, col, workspace, file)}\n ${stack.reversed.join('\n')} ",
            scope);
      }
      Scope funscope = Scope(
        false,
        false,
        scope.rtl,
        scope.environment,
        parent: thisScope ?? scope,
        stack: stack + [ConcatenateLazyString(fromClass, VariableLazyString(name))],
        declaringClass: scope.declaringClass,
        debugName: ConcatenateLazyString(fromClass, VariableLazyString(name)),
        intrinsics: scope.intrinsics,
        variables: scope.variables,
      );
      if (params is List) {
        for (ValueWrapper aSub in a) {
          if (!aSub.typeC(funscope, funscope.stack, line, col, workspace, file, scope.environment).isSubtypeOf(params.elementAt(i).type)) {
            throw BSCException(
                "Argument $i of ${name.name}, ${aSub.toStringWithStack(funscope.stack, line, col, workspace, file, false, scope.environment)}, of wrong type (${aSub.typeC(funscope, funscope.stack, line, col, workspace, file, scope.environment)}) expected ${params.elementAt(i).type} ${formatCursorPosition(line, col, workspace, file)}",
                scope);
          }
          funscope.values[(params as List)[i++].name] = MaybeConstantValueWrapper(aSub, true);
        }
      } else {
        funscope.values[params.first.name] = MaybeConstantValueWrapper(
            ValueWrapper(
              ArrayValueType(params.first.type, 'internal', tv),
              List<ValueWrapper>.unmodifiable(a),
              'varargs',
            ),
            true);
      }
      for (Statement statement in body) {
        StatementResult value = statement.run(funscope);
        switch (value.type) {
          case StatementResultType.nothing:
            break;
          case StatementResultType.returnFunction:
            if ((scope.intrinsics ?? scope).profileMode!) {
              scope.environment.profile[ourProfile]!.key.stop();
            }

            if (value.value!.typeC(funscope, funscope.stack, line, col, workspace, file, scope.environment).isSubtypeOf(returnType)) return value.value!;
            throw BSCException(
                "You cannot return a ${value.value!.typeC(funscope, funscope.stack, line, col, workspace, file, scope.environment)} (${value.value!.toStringWithStack(funscope.stack, line, col, workspace, file, false, scope.environment)}) from ${fromClass}${name.name}, which is supposed to return a $returnType!     ${formatCursorPosition(line, col, workspace, file)}\n${funscope.stack.reversed.join('\n')} ",
                scope);
          case StatementResultType.breakWhile:
            throw BSCException("Break outside while", scope);
          case StatementResultType.continueWhile:
            throw BSCException("Continue outside while", scope);
          case StatementResultType.unwindAndThrow:
            if ((scope.intrinsics ?? scope).profileMode!) {
              scope.environment.profile[scope.variables["${fromClass}${name.name}"] ??= Variable("${fromClass}${name.name}")]!.key.stop();
            }
            throw value.value!;
        }
      }
      if (!scope.environment.nullType.isSubtypeOf(returnType)) {
        throw BSCException("${name.name} has no return statement ${formatCursorPosition(line, col, workspace, file)}", scope);
      }
      if ((scope.intrinsics ?? scope).profileMode!) {
        scope.environment.profile[ourProfile]!.key.stop();
      }
      return ValueWrapper<Null>(scope.environment.nullType, null, 'default return value of functions');
    };
    scope.values[name] = MaybeConstantValueWrapper(
        ValueWrapper<SydFunction<Object?>>(
            FunctionValueType(returnType, params.map((e) => e.type), file, tv), _value, LazyInterpolatorSpace(VariableLazyString(name), 'function')),
        true);
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
    while (cond.eval(scope).valueC(scope, scope.stack, line, col, workspace, file, scope.environment)) {
      Scope whileScope = createParentScope
          ? Scope(
              false,
              false,
              scope.rtl,
              scope.environment,
              parent: scope,
              stack: scope.stack,
              debugName: CursorPositionLazyString('while loop', line, col, workspace, file),
              intrinsics: scope.intrinsics,
              variables: scope.variables,
            )
          : scope;
      block:
      for (Statement statement in body) {
        StatementResult statementResult = statement.run(whileScope);
        switch (statementResult.type) {
          case StatementResultType.nothing:
            break;
          case StatementResultType.breakWhile:
            if (statementResult.value!.valueC(whileScope, whileScope.stack, line, col, workspace, file, scope.environment) || catchReturns)
              return StatementResult(StatementResultType.nothing);
            return statementResult;
          case StatementResultType.continueWhile:
            if (statementResult.value!.valueC(whileScope, whileScope.stack, line, col, workspace, file, scope.environment) || catchReturns) break block;
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

  IfStatement(this.cond, this.body, this.elseBody, int line, int col, this.workspace, this.file) : super(line, col);
  final Expression cond;
  final List<Statement> body;
  final List<Statement>? elseBody;
  final String file;
  @override
  StatementResult run(Scope scope) {
    if (cond.eval(scope).valueC(scope, scope.stack, line, col, workspace, file, scope.environment)) {
      Scope ifScope = Scope(false, false, scope.rtl, scope.environment,
          parent: scope,
          stack: scope.stack,
          debugName: CursorPositionLazyString(
            'if statement - \'if\' segment scope',
            line,
            col,
            workspace,
            file,
          ),
          intrinsics: scope.intrinsics,
          variables: scope.variables);
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
      Scope elseScope = Scope(false, false, scope.rtl, scope.environment,
          parent: scope,
          stack: scope.stack,
          debugName: CursorPositionLazyString(
            'if statement - \'else\' segment scope',
            line,
            col,
            workspace,
            file,
          ),
          intrinsics: scope.intrinsics,
          variables: scope.variables);
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
  ForStatement(this.list, this.body, int line, int col, this.ident, this.workspace, this.file, this.tv, [this.catchBreakContinue = true]) : super(line, col);
  final Expression list;
  final Variable ident;
  final List<Statement> body;
  final bool catchBreakContinue;
  final String file;
  final String workspace;
  final TypeValidator tv;

  late ValueType whateverIterableType =
      IterableValueType<Object?>(ValueType.create(null, whateverVariable, -2, 0, 'interr', 'intrinsics', tv), 'TODO FORS', tv);

  @override
  StatementResult run(Scope scope) {
    ValueWrapper listVal = list.eval(scope);
    if (!listVal.typeC(scope, scope.stack, line, col, workspace, file, scope.environment).isSubtypeOf(whateverIterableType)) {
      throw BSCException(
          "$listVal ($list) is not a list - is a ${listVal.typeC(scope, scope.stack, line, col, workspace, file, scope.environment)} (tried to do a for statement) ${formatCursorPosition(line, col, workspace, file)}",
          scope);
    }
    for (ValueWrapper identVal in listVal.valueC(scope, scope.stack, line, col, workspace, file, scope.environment)) {
      Scope forScope = Scope(false, false, scope.rtl, scope.environment,
          parent: scope,
          stack: scope.stack,
          debugName: CursorPositionLazyString(
            'for statement scope',
            line,
            col,
            workspace,
            file,
          ),
          intrinsics: scope.intrinsics,
          variables: scope.variables);
      forScope.values[ident] = MaybeConstantValueWrapper(identVal, true);
      block:
      for (Statement statement in body) {
        StatementResult statementResult = statement.run(forScope);
        switch (statementResult.type) {
          case StatementResultType.nothing:
            break;
          case StatementResultType.breakWhile:
            if (statementResult.value!.valueC(forScope, forScope.stack, line, col, workspace, file, scope.environment) || catchBreakContinue)
              return StatementResult(StatementResultType.nothing);
            return statementResult;
          case StatementResultType.continueWhile:
            if (statementResult.value!.valueC(forScope, forScope.stack, line, col, workspace, file, scope.environment) || catchBreakContinue) break block;
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
    return StatementResult(StatementResultType.breakWhile, ValueWrapper(scope.environment.booleanType, alwaysBreakCurrent, 'internal'));
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
    return StatementResult(StatementResultType.continueWhile, ValueWrapper(scope.environment.booleanType, alwaysContinueCurrent, 'internal'));
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
        BoringExpr(null, scope.environment.nullType, scope),
        tokens.current.line,
        tokens.current.col,
      );
    }
    Expression expr = parseExpression(tokens, scope);
    if (!expr.type
        .isSubtypeOf(scope.returnType ?? (throw BSCException('Cannot return from outside a function ${formatCursorPositionFromTokens(tokens)}', scope)))) {
      throw BSCException('Cannot return a ${expr.type} from a function that returns a ${scope.returnType} ${formatCursorPositionFromTokens(tokens)}', scope);
    }
    tokens.expectChar(TokenType.endOfStatement);
    return ReturnStatement(
      expr,
      tokens.current.line,
      tokens.current.col,
    );
  }
}

class EnumStatement extends Statement {
  final Variable name;
  final EnumValueType type;
  final List<Variable> fields;
  final String workspace;
  final String file;
  final TypeValidator tv;

  EnumStatement(this.name, this.fields, this.type, super.line, super.col, this.file, this.workspace, this.tv);

  @override
  StatementResult run(Scope scope) {
    Scope newScope = Scope(false, false, scope.rtl, scope.environment,
        intrinsics: scope.intrinsics,
        parent: scope,
        stack: scope.stack + [ConcatenateLazyString(NotLazyString('enum '), VariableLazyString(name))],
        debugName: CursorPositionLazyString(
          'enum scope',
          line,
          col,
          workspace,
          file,
        ),
        variables: scope.variables);
    scope.values[name] = MaybeConstantValueWrapper(
      ValueWrapper(
        type,
        Enum(newScope),
        VariableLazyString(name),
      ),
      true,
    );
    for (Variable field in fields) {
      newScope.values[field] = MaybeConstantValueWrapper(
        ValueWrapper(
          ValueType.create(null, name, -2, 0, 'interr', "_internal", tv),
          Concat(VariableLazyString(name), Concat('.', field.name)),
          LazyInterpolatorSpace('enum field', VariableLazyString(field)),
        ),
        true,
      );
    }
    return StatementResult(StatementResultType.nothing);
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
  final ClassOfValueType classOfType;
  final TypeValidator tv;
  ClassStatement(this.name, this.superclass, this.block, this.type, int line, int col, this.workspace, this.file, this.classOfType, this.tv) : super(line, col);

  @override
  StatementResult run(Scope scope) {
    Scope methods = Scope(false, false, scope.rtl, scope.environment,
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
        intrinsics: scope.intrinsics,
        variables: scope.variables);
    ValueWrapper? superConst = superclass == null ? null : scope.internal_getVar(scope.variables['${superclass!.name}'] ??= Variable('${superclass!.name}'));
    Scope staticMembers = Scope(false, true, scope.rtl, scope.environment,
        parent: superclass == null ? null : superConst!.valueC<Class>(scope, scope.stack, line, col, workspace, file, scope.environment).staticMembers,
        stack: [ConcatenateLazyString(NotLazyString('staticMembersOf'), VariableLazyString(name))],
        debugName: ConcatenateLazyString(NotLazyString('staticMembersOf'), VariableLazyString(name)),
        staticClassName: '${name.name}',
        intrinsics: scope.intrinsics,
        variables: scope.variables);
    for (Statement s in block) {
      if (s is FunctionStatement) {
        if (s.static) {
          s.run(staticMembers);
        } else {
          s.run(methods);
        }
      }
      if (s is StaticFieldStatement) {
        staticMembers.values[s.name] = MaybeConstantValueWrapper(s.val.eval(scope), s.isConstant);
      }
    }
    scope.values[scope.variables['~${name.name}~methods'] ??= Variable('~${name.name}~methods')] = MaybeConstantValueWrapper(
      ValueWrapper(
        ValueType.create(null, classMethodsVariable, -2, 0, 'interr', "_internal", tv),
        methods,
        'internal',
      ),
      true,
    );
    Variable constructorsClassName = name;
    if (methods.internal_getVar(constructorVariable) == null) {
      if (superclass != null &&
          scope.internal_getVar(
                scope.variables['~${superclass!.name}~methods'] ??= Variable('~${superclass!.name}~methods'),
              ) ==
              null) {
        throwWithStack(
            scope,
            [
              CursorPositionLazyString('main', 1, 0, workspace, file),
              CursorPositionLazyString(
                'defining ${name.name} which extends ${superclass?.name}',
                line,
                col,
                workspace,
                file,
              ),
              NotLazyString('inheriting constructor'),
            ],
            'have not defined superclass ${superclass?.name}');
      }
      if (superclass == null) {
        methods.values[constructorVariable] = MaybeConstantValueWrapper(
            ValueWrapper(FunctionValueType(type, [], file, tv), (List<ValueWrapper> args, List<LazyString> stack, [Scope? thisScope, ValueType? thisType]) {
              if (args.length != 0) {
                throwWithStack(
                  scope,
                  stack,
                  'default constructor takes no arguments - passed ${args.length} arguments ${StackTrace.current}',
                );
              }
              return ValueWrapper<Null>(scope.environment.nullType, null, 'null from default constructor a');
            }, 'default constructor - aaaa'),
            true);
      } else {
        constructorsClassName =
            type.recursiveLookup(constructorVariable)?.value.name ?? (scope.variables['default constructor - bbbb'] ??= Variable('default constructor - bbbb'));
        ;
        methods.values[constructorVariable] = MaybeConstantValueWrapper(
          scope
              .getVar(
                  scope.variables['~${superclass!.name}~methods'] ??= Variable('~${superclass!.name}~methods'), line, col, 'interr', 'TODO ($file) TODO', null)
              .valueC<Scope>(scope, scope.stack, line, col, workspace, file, scope.environment)
              .getVar(constructorVariable, line, col, 'td', 'TODO TODO', null),
          true,
        );
      }
    }
    scope.values[scope.variables['~${name.name}'] ??= Variable('~${name.name}')] = MaybeConstantValueWrapper(
        ValueWrapper(FunctionValueType(type, [], file, tv), (List<ValueWrapper> args, List<LazyString> stack, [Scope? thisScope, ValueType? thisType]) {
          if (superclass != null) {
            scope
                    .getVar(scope.variables['~${superclass!.name}'] ??= Variable('~${superclass!.name}'), line, col, workspace, 'TODO', null)
                    .valueC<SydFunction>(scope, scope.stack, line, col, workspace, file, scope.environment)(
                <ValueWrapper>[], stack + [NotLazyString('~${superclass!.name}')], thisScope, thisType);
          }

          thisScope!.values[thisVariable] = MaybeConstantValueWrapper(ValueWrapper(thisType, thisScope, '\'this\' property'), true);
          for (Statement s in block) {
            if (s is NewVarStatement || s is FunctionStatement) {
              if (s is FunctionStatement && methods.values.keys.contains(s.name)) {
                MaybeConstantValueWrapper value = methods.values[s.name]!;
                thisScope.values[s.name] = MaybeConstantValueWrapper(
                    ValueWrapper(value.value.typeC(scope, scope.stack, line, col, workspace, file, scope.environment),
                        (List<ValueWrapper> args2, List<LazyString> stack2, [Scope? thisScope2, ValueType? thisType2]) {
                      return (value.value.valueC<SydFunction<Object?>>(scope, scope.stack, line, col, workspace, file, scope.environment))(
                          args2, stack2, thisScope, thisType);
                    }, 'method ${s.name == constructorVariable ? constructorsClassName.name : name.name}.${s.name.name}'),
                    true);
                continue;
              }
              StatementResult sr = s.run(thisScope);
              switch (sr.type) {
                case StatementResultType.nothing:
                  break;
                case StatementResultType.breakWhile:
                case StatementResultType.continueWhile:
                case StatementResultType.returnFunction:
                  throw BSCException('Internal error', scope);
                case StatementResultType.unwindAndThrow:
                  throw sr.value!;
              }
            }
          }
          return ValueWrapper(scope.environment.nullType, null, Concat('return value of ~', VariableLazyString(name)));
        }, 'internal'),
        true);
    bool hasConstructor = block.any((element) => element is FunctionStatement && element.name == constructorVariable);
    scope.values[name] = MaybeConstantValueWrapper(
        ValueWrapper(
            classOfType,
            Class(
              staticMembers,
              ValueWrapper(
                FunctionValueType(
                    type,
                    hasConstructor
                        ? block.whereType<FunctionStatement>().firstWhere((element) => element.name == constructorVariable).params.map((e) => e.type)
                        : superclass == null
                            ? []
                            : (scope
                                    .internal_getVar(scope.variables['~${superclass!.name}~methods'] ??= Variable('~${superclass!.name}~methods'))
                                    ?.valueC<Scope>(scope, scope.stack, line, col, workspace, file, scope.environment)
                                    .internal_getVar(constructorVariable)
                                    ?.typeC(scope, scope.stack, line, col, workspace, file, scope.environment) as FunctionValueType)
                                .parameters,
                    file,
                    tv),
                (List<ValueWrapper> args, List<LazyString> stack, [Scope? thisScope, ValueType? thisType]) {
                  Scope thisScope = Scope(
                    true,
                    false,
                    scope.rtl,
                    scope.environment,
                    parent: scope,
                    stack: stack + [NotLazyString('${name.name}-instance')],
                    debugName: NotLazyString('instance of ${name.name}'),
                    typeIfClass: type,
                    intrinsics: scope.intrinsics,
                    variables: scope.variables,
                  );
                  thisScope.values[classNameVariable] = MaybeConstantValueWrapper(ValueWrapper(scope.environment.stringType, name.name, 'className'), true);
                  scope
                          .getVar(scope.variables['~${name.name}'] ??= Variable('~${name.name}'), line, col, 'tdo', 'TODO', null)
                          .valueC<SydFunction>(scope, scope.stack, line, col, workspace, file, scope.environment)(
                      <ValueWrapper>[], stack + [ConcatenateLazyString(NotLazyString('~'), VariableLazyString(name))], thisScope, type);
                  var constructorFunc = thisScope
                          .internal_getVar(constructorVariable)
                          ?.valueC<SydFunction<Object?>>(scope, scope.stack, line, col, workspace, file, scope.environment) ??
                      (superclass == null
                          ? (List<ValueWrapper> args, List<LazyString> stack, [Scope? thisScope, ValueType? thisType]) {
                              return ValueWrapper<Null>(scope.environment.nullType, null, 'null from default constructor');
                            }
                          : (scope
                                  .internal_getVar(scope.variables['~${superclass!.name}~methods'] ??= Variable('~${superclass!.name}~methods'))!
                                  .valueC<Scope>(scope, scope.stack, line, col, workspace, file, scope.environment)
                                  .internal_getVar(constructorVariable)!)
                              .valueC<SydFunction<Object?>>(scope, stack, line, col, workspace, file, scope.environment));
                  constructorFunc(args, stack + [NotLazyString('${name.name}.constructor (from generated constructor)')], thisScope, type);
                  return ValueWrapper<Scope>(type, thisScope, 'instance of ${name.name}');
                },
                VariableLazyString(constructorVariable),
              ),
            ),
            NotLazyString('line ~638')),
        true);
    return StatementResult(StatementResultType.nothing);
  }
}

class NopStatement extends Statement {
  NopStatement() : super(-2, 0);

  @override
  StatementResult run(Scope scope) {
    // it's a NOP
    return StatementResult(StatementResultType.nothing);
  }
}
