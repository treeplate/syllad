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

  SetStatement(this.l, this.val, int line, int col, this.file) : super(line, col);

  @override
  StatementResult run(Scope scope) {
    var right = val.eval(scope);
    scope.setVar(l, right, false, line, col, file);
    return StatementResult(StatementResultType.nothing);
  }
}

class ImportStatement extends Statement {
  final List<Statement> file;

  final String filename;
  final String currentFilename;
  final TypeValidator typeValidator;

  ImportStatement(this.file, this.filename, int line, int col, this.currentFilename, this.typeValidator) : super(line, col);

  @override
  StatementResult run(Scope scope) {
    List<LazyString> newStack = scope.stack.toList();
    newStack[newStack.length - 1] = ConcatenateLazyString(newStack.last, CursorPositionLazyString('', line, col, currentFilename));
    scope.addParent((scope.environment.filesRan[filename] ??
        (scope.environment.filesRan[filename] = runProgram(file, filename, scope.intrinsics, scope.rtl, typeValidator, false,
            false /* debug and profile mode are only for the main program */, stdout, stderr, exit, ['INTERPRETER ERROR'], newStack))));
    return StatementResult(StatementResultType.nothing);
  }
}

class NewVarStatement extends Statement {
  final Identifier name;
  final bool isConstant;

  final Expression? val;
  final ValueType type;

  final String file;

  final TypeValidator tv;

  String toString() => "var $name = $val";

  NewVarStatement(this.name, this.val, int line, int col, this.file, this.isConstant, this.type, this.tv) : super(line, col);

  @override
  StatementResult run(Scope scope) {
    if (val == null) {
      scope.values[name] = MaybeConstantValueWrapper(SydSentinel(scope.environment), isConstant);
    } else {
      Object? eval = val!.eval(scope);
      if (!getType(eval, scope, line, col, file).isSubtypeOf(type)) {
        throw BSCException(
            "Variable ${name.name} of type $type cannot be initialized to a value of type ${getType(eval, scope, line, col, file)} ${formatCursorPosition(line, col, file)}",
            scope);
      }

      scope.values[name] = MaybeConstantValueWrapper(eval, isConstant);
    }
    return StatementResult(StatementResultType.nothing);
  }
}

class StaticFieldStatement extends Statement {
  final Identifier name;
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
  FunctionStatement(this.returnType, this.name, this.params, this.body, int line, int col, this.file, this.static, this.type, this.tv) : super(line, col);
  final ValueType returnType;
  final Identifier name;

  final String file;
  final Iterable<Parameter> params;
  final List<Statement> body;
  final bool static;
  final ValueType type;
  final TypeValidator tv;
  @override
  StatementResult run(Scope scope) {
    Object? Function(List<Object?> args, List<LazyString>, [Scope?, ValueType?]) _value =
        (List<Object?> a, List<LazyString> stack, [Scope? thisScope, ValueType? thisType]) {
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
      Identifier? ourProfile;
      if ((scope.intrinsics ?? scope).profileMode!) {
        ourProfile = scope.identifiers["${fromClass}${name.name}"] ??= Identifier("${fromClass}${name.name}");

        scope.environment.profile[ourProfile] ??= MapEntry(Stopwatch(), 0);
        scope.environment.profile[ourProfile]!.key.start();
        scope.environment.profile[ourProfile] = MapEntry(scope.environment.profile[ourProfile]!.key, scope.environment.profile[ourProfile]!.value + 1);
      }
      int i = 0;
      if (params is! InfiniteIterable && a.length != params.length) {
        throw BSCException(
            "Wrong number of arguments to ${fromClass}${name.name}: args ${a.map((e) => toStringWithStacker(e, stack, line, col, file, false, scope.environment))}, params $params ${formatCursorPosition(line, col, file)}\n ${stack.reversed.join('\n')} ",
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
        identifiers: scope.identifiers,
      );
      if (params is List) {
        for (Object? aSub in a) {
          if (!getType(aSub, scope, line, col, file).isSubtypeOf(params.elementAt(i).type)) {
            throw BSCException(
                "Argument $i of ${name.name}, ${toStringWithStacker(aSub, funscope.stack, line, col, file, false, scope.environment)}, of wrong type (${getType(aSub, scope, line, col, file)}) expected ${params.elementAt(i).type} ${formatCursorPosition(line, col, file)}",
                scope);
          }
          funscope.values[(params as List)[i++].name] = MaybeConstantValueWrapper(aSub, true);
        }
      } else {
        funscope.values[params.first.name] = MaybeConstantValueWrapper(
            SydArray(
              List<Object?>.unmodifiable(a),
              ArrayValueType(params.first.type, 'internal', tv),
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

            if (getType(value.value, scope, line, col, file).isSubtypeOf(returnType)) return value.value;
            throw BSCException(
                "You cannot return a ${getType(value.value!, scope, line, col, file)} (${toStringWithStacker(value.value!, funscope.stack, line, col, file, false, scope.environment)}) from ${fromClass}${name.name}, which is supposed to return a $returnType!     ${formatCursorPosition(line, col, file)}\n${funscope.stack.reversed.join('\n')} ",
                scope);
          case StatementResultType.breakWhile:
            throw BSCException("Break outside while", scope);
          case StatementResultType.continueWhile:
            throw BSCException("Continue outside while", scope);
          case StatementResultType.unwindAndThrow:
            if ((scope.intrinsics ?? scope).profileMode!) {
              scope.environment.profile[scope.identifiers["${fromClass}${name.name}"] ??= Identifier("${fromClass}${name.name}")]!.key.stop();
            }
            throw value.value!;
        }
      }
      if (!scope.environment.nullType.isSubtypeOf(returnType)) {
        throw BSCException("${name.name} has no return statement ${formatCursorPosition(line, col, file)}", scope);
      }
      if ((scope.intrinsics ?? scope).profileMode!) {
        scope.environment.profile[ourProfile]!.key.stop();
      }
      return null;
    };
    scope.values[name] = MaybeConstantValueWrapper(
        SydFunction<Object?>(
          _value,
          FunctionValueType(returnType, params.map((e) => e.type), file, tv),
          Concat(file, Concat('::', name.name)),
        ),
        true);
    return StatementResult(StatementResultType.nothing);
  }
}

class WhileStatement extends Statement {
  final bool createParentScope;
  final String kind;

  final String file;

  WhileStatement(this.cond, this.body, int line, int col, this.kind, this.file, [this.catchReturns = true, this.createParentScope = true]) : super(line, col);
  final Expression cond;
  final List<Statement> body;
  final bool catchReturns;
  @override
  StatementResult run(Scope scope) {
    while (cond.eval(scope) as bool) {
      Scope whileScope = createParentScope
          ? Scope(
              false,
              false,
              scope.rtl,
              scope.environment,
              parent: scope,
              stack: scope.stack,
              debugName: CursorPositionLazyString('while loop', line, col, file),
              intrinsics: scope.intrinsics,
              identifiers: scope.identifiers,
            )
          : scope;
      block:
      for (Statement statement in body) {
        StatementResult statementResult = statement.run(whileScope);
        switch (statementResult.type) {
          case StatementResultType.nothing:
            break;
          case StatementResultType.breakWhile:
            if (statementResult.value as bool || catchReturns) return StatementResult(StatementResultType.nothing);
            return statementResult;
          case StatementResultType.continueWhile:
            if (statementResult.value as bool || catchReturns) break block;
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
  IfStatement(this.cond, this.body, this.elseBody, int line, int col, this.file) : super(line, col);
  final Expression cond;
  final List<Statement> body;
  final List<Statement>? elseBody;
  final String file;
  @override
  StatementResult run(Scope scope) {
    if (cond.eval(scope) as bool) {
      Scope ifScope = Scope(false, false, scope.rtl, scope.environment,
          parent: scope,
          stack: scope.stack,
          debugName: CursorPositionLazyString(
            'if statement - \'if\' segment scope',
            line,
            col,
            file,
          ),
          intrinsics: scope.intrinsics,
          identifiers: scope.identifiers);
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
            file,
          ),
          intrinsics: scope.intrinsics,
          identifiers: scope.identifiers);
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
  ForStatement(this.list, this.body, int line, int col, this.ident, this.file, this.tv, [this.catchBreakContinue = true]) : super(line, col);
  final Expression list;
  final Identifier ident;
  final List<Statement> body;
  final bool catchBreakContinue;
  final String file;

  final TypeValidator tv;

  late ValueType whateverIterableType = IterableValueType<Object?>(ValueType.create(null, whateverVariable, -2, 0, 'intrinsics', tv), 'TODO FORS', tv);

  @override
  StatementResult run(Scope scope) {
    SydIterable listVal = list.eval(scope) as SydIterable;
    if (!getType(listVal, scope, line, col, file).isSubtypeOf(whateverIterableType)) {
      throw BSCException(
          "$listVal ($list) is not a list - is a ${getType(listVal, scope, line, col, file)} (tried to do a for statement) ${formatCursorPosition(line, col, file)}",
          scope);
    }
    for (Object? identVal in listVal.iterable) {
      Scope forScope = Scope(false, false, scope.rtl, scope.environment,
          parent: scope,
          stack: scope.stack,
          debugName: CursorPositionLazyString(
            'for statement scope',
            line,
            col,
            file,
          ),
          intrinsics: scope.intrinsics,
          identifiers: scope.identifiers);
      forScope.values[ident] = MaybeConstantValueWrapper(identVal, true);
      block:
      for (Statement statement in body) {
        StatementResult statementResult = statement.run(forScope);
        switch (statementResult.type) {
          case StatementResultType.nothing:
            break;
          case StatementResultType.breakWhile:
            if (statementResult.value! as bool || catchBreakContinue) return StatementResult(StatementResultType.nothing);
            return statementResult;
          case StatementResultType.continueWhile:
            if (statementResult.value! as bool || catchBreakContinue) break block;
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
    return StatementResult(
      StatementResultType.breakWhile,
      alwaysBreakCurrent,
    );
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
    return StatementResult(
      StatementResultType.continueWhile,
      alwaysContinueCurrent,
    );
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
    if (!expr.staticType
        .isSubtypeOf(scope.returnType ?? (throw BSCException('Cannot return from outside a function ${formatCursorPositionFromTokens(tokens)}', scope)))) {
      throw BSCException(
          'Cannot return a ${expr.staticType} from a function that returns a ${scope.returnType} ${formatCursorPositionFromTokens(tokens)}', scope);
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
  final Identifier name;
  final EnumValueType type;
  final List<Identifier> fields;

  final String file;
  final TypeValidator tv;

  EnumStatement(this.name, this.fields, this.type, super.line, super.col, this.file, this.tv);

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
          file,
        ),
        identifiers: scope.identifiers);
    scope.values[name] = MaybeConstantValueWrapper(
      SydEnum(newScope, type, name),
      true,
    );
    for (Identifier field in fields) {
      newScope.values[field] = MaybeConstantValueWrapper(
        SydEnumValue(
          Concat(VariableLazyString(name), Concat('.', field.name)),
          type.propertyType,
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
  final Identifier name;
  final ClassValueType type;
  final Identifier? superclass;

  final String file;
  final ClassOfValueType classOfType;
  final TypeValidator tv;
  ClassStatement(this.name, this.superclass, this.block, this.type, int line, int col, this.file, this.classOfType, this.tv) : super(line, col);

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
          file,
        ),
        intrinsics: scope.intrinsics,
        identifiers: scope.identifiers);
    Object? superConst = superclass == null ? null : scope.internal_getVar(scope.identifiers['${superclass!.name}'] ??= Identifier('${superclass!.name}')).$2;
    Scope staticMembers = Scope(false, true, scope.rtl, scope.environment,
        parent: superclass == null ? null : (superConst as Class).staticMembers,
        stack: [ConcatenateLazyString(NotLazyString('staticMembersOf'), VariableLazyString(name))],
        debugName: ConcatenateLazyString(NotLazyString('staticMembersOf'), VariableLazyString(name)),
        staticClassName: '${name.name}',
        intrinsics: scope.intrinsics,
        identifiers: scope.identifiers);
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
    scope.values[scope.identifiers['~${name.name}~methods'] ??= Identifier('~${name.name}~methods')] = MaybeConstantValueWrapper(
      methods,
      true,
    );
    if (!methods.internal_getVar(constructorVariable).$1) {
      if (superclass != null &&
          !scope
              .internal_getVar(
                scope.identifiers['~${superclass!.name}~methods'] ??= Identifier('~${superclass!.name}~methods'),
              )
              .$1) {
        throwWithStack(
            scope,
            [
              CursorPositionLazyString('main', 1, 0, file),
              CursorPositionLazyString(
                'defining ${name.name} which extends ${superclass?.name}',
                line,
                col,
                file,
              ),
              NotLazyString('inheriting constructor'),
            ],
            'have not defined superclass ${superclass?.name}');
      }
      if (superclass == null) {
        methods.values[constructorVariable] = MaybeConstantValueWrapper(
            SydFunction(
              (List<Object?> args, List<LazyString> stack, [Scope? thisScope, ValueType? thisType]) {
                if (args.length != 0) {
                  throwWithStack(
                    scope,
                    stack,
                    'default constructor takes no arguments - passed ${args.length} arguments ${StackTrace.current}',
                  );
                }
                return null;
              },
              FunctionValueType(type, [], file, tv),
              Concat(name.name, '.defaultconstructor'),
            ),
            true);
      } else {
        methods.values[constructorVariable] = MaybeConstantValueWrapper(
          (scope.getVar(scope.identifiers['~${superclass!.name}~methods'] ??= Identifier('~${superclass!.name}~methods'), line, col, 'TODO ($file) TODO', null)
                  as Scope)
              .getVar(constructorVariable, line, col, 'TODO TODO', null),
          true,
        );
      }
    }
    scope.values[scope.identifiers['~${name.name}'] ??= Identifier('~${name.name}')] = MaybeConstantValueWrapper(
        SydFunction(
          (List<Object?> args, List<LazyString> stack, [Scope? thisScope, ValueType? thisType]) {
            if (superclass != null) {
              (scope.getVar(scope.identifiers['~${superclass!.name}'] ??= Identifier('~${superclass!.name}'), line, col, 'TODO', null) as SydFunction)
                  .function(<Object?>[], stack + [NotLazyString('~${superclass!.name}')], thisScope, thisType);
            }

            thisScope!.values[thisVariable] = MaybeConstantValueWrapper(thisScope, true);
            for (Statement s in block) {
              if (s is NewVarStatement || s is FunctionStatement) {
                if (s is FunctionStatement && methods.values.keys.contains(s.name)) {
                  MaybeConstantValueWrapper value = methods.values[s.name]!;
                  thisScope.values[s.name] = MaybeConstantValueWrapper(
                      SydFunction(
                        (List<Object?> args2, List<LazyString> stack2, [Scope? thisScope2, ValueType? thisType2]) {
                          return (value.value as SydFunction).function(args2, stack2, thisScope, thisType);
                        },
                        getType(value.value, scope, line, col, file) as ValueType<SydFunction>,
                        Concat(name.name, Concat('.', s.name.name)),
                      ),
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
            return null;
          },
          FunctionValueType(type, [], file, tv),
          Concat('~', name.name),
        ),
        true);
    bool hasConstructor = block.any((element) => element is FunctionStatement && element.name == constructorVariable);
    Iterable<ValueType> constructorParameters;
    if (hasConstructor) {
      constructorParameters = block.whereType<FunctionStatement>().firstWhere((element) => element.name == constructorVariable).params.map((e) => e.type);
    } else {
      constructorParameters = superclass == null
          ? []
          : (getType(
                  (scope.internal_getVar(scope.identifiers['~${superclass!.name}~methods'] ??= Identifier('~${superclass!.name}~methods')).$2 as Scope)
                      .internal_getVar(constructorVariable)
                      .$2,
                  scope,
                  line,
                  col,
                  file) as FunctionValueType)
              .parameters;
    }
    scope.values[name] = MaybeConstantValueWrapper(
      Class(
        staticMembers,
        SydFunction(
          (List<Object?> args, List<LazyString> stack, [Scope? thisScope, ValueType? thisType]) {
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
              identifiers: scope.identifiers,
            );
            thisScope.values[classNameVariable] = MaybeConstantValueWrapper(name.name, true);
            (scope.getVar(scope.identifiers['~${name.name}'] ??= Identifier('~${name.name}'), line, col, 'TODO', null) as SydFunction)
                .function(<Object?>[], stack + [ConcatenateLazyString(NotLazyString('~'), VariableLazyString(name))], thisScope, type);
            (bool, Object?) constructor = thisScope.internal_getVar(constructorVariable);
            SydFunction constructorFunc;
            if (constructor.$1) {
              constructorFunc = constructor.$2 as SydFunction;
            } else if (superclass == null) {
              constructorFunc = SydFunction(
                (List<Object?> args, List<LazyString> stack, [Scope? thisScope, ValueType? thisType]) {
                  return null;
                },
                FunctionValueType(scope.environment.nullType, [], file, tv),
                Concat(name.name, '.default-constructor'),
              );
            } else {
              constructorFunc =
                  (scope.internal_getVar(scope.identifiers['~${superclass!.name}~methods'] ??= Identifier('~${superclass!.name}~methods')).$2 as Scope)
                      .internal_getVar(constructorVariable)
                      .$2 as SydFunction;
            }
            constructorFunc.function(args, stack + [NotLazyString('${name.name}.constructor (from generated constructor)')], thisScope, type);
            return thisScope;
          },
          FunctionValueType(type, constructorParameters, file, tv),
          Concat(name.name, '.generatedconstructor'),
        ),
        classOfType,
      ),
      true,
    );
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
