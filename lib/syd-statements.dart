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
    l.write(right, scope);
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
    scope.addParent((scope.environment.filesRan[filename] ??
        (scope.environment.filesRan[filename] = runProgram(file, filename, scope.intrinsics, scope.rtl, typeValidator, false,
            false /* debug and profile mode are only for the main program */, stdout, stderr, exit, ['INTERPRETER ERROR']))));
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

  NewVarStatement(this.name, this.val, int line, int col, this.file, this.isConstant, this.type, this.tv) : super(line, col) {
    if (name == constructorVariable && tv.inClass) {
      throw BSCException('Constructor cannot be a field. ${formatCursorPosition(line, col, file)}', tv);
    }
  }

  @override
  StatementResult run(Scope scope) {
    Object? value;
    if (val == null) {
      value = SydSentinel(scope.environment);
    } else {
      Object? eval = val!.eval(scope);
      if (!getType(eval, scope, line, col, file, false).isSubtypeOf(type)) {
        throw BSCException(
            "Variable ${name.name} of type $type cannot be initialized to a value of type ${getType(eval, scope, line, col, file, false)} ${formatCursorPosition(line, col, file)}",
            scope);
      }
      value = eval;
    }
    if (tv.globalScope) {
      scope.environment.globals[name] = value;
    } else {
      scope.newVar(name, value);
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
    late SydFunction function;
    Object? Function(List<Object?> args, [Scope?, ValueType?]) _value = (List<Object?> a, [Scope? thisScope, ValueType? thisType]) {
      assert(tv.inClass == (scope.currentClassScope != null || thisScope != null));
      scope.environment.stack.add(IdentifierLazyString(name));
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
            "Wrong number of arguments to ${fromClass}${name.name}: args ${a.map((e) => toStringWithStacker(
                  e,
                  line,
                  col,
                  file,
                  false,
                ))}, params $params ${formatCursorPosition(line, col, file)}\n ${scope.environment.stack.reversed.join('\n')} ",
            scope);
      }
      Scope funscope = Scope(
        false,
        false,
        scope.rtl,
        scope.environment,
        parent: thisScope ?? scope,
        declaringClass: scope.declaringClass,
        debugName: ConcatenateLazyString(fromClass, IdentifierLazyString(name)),
        intrinsics: scope.intrinsics,
        identifiers: scope.identifiers,
      );
      if (params is List) {
        for (Object? aSub in a) {
          if (!getType(aSub, scope, line, col, file, false).isSubtypeOf(params.elementAt(i).type)) {
            throw BSCException(
                "Argument $i of ${name.name}, ${toStringWithStacker(aSub, line, col, file, false)}, of wrong type (${getType(aSub, scope, line, col, file, false)}) expected ${params.elementAt(i).type} ${formatCursorPosition(line, col, file)}",
                scope);
          }
          funscope.newVar((params as List)[i++].name, aSub);
        }
      } else {
        for (Object? aSub in a) {
          if (!getType(aSub, scope, line, col, file, false).isSubtypeOf(params.first.type)) {
            throw BSCException(
                "Argument $i of ${name.name}, ${toStringWithStacker(aSub, line, col, file, false)}, of wrong type (${getType(aSub, scope, line, col, file, false)}) expected ${params.first.type} ${formatCursorPosition(line, col, file)}",
                scope);
          }
        }
        funscope.newVar(
          params.first.name,
          SydArray(
            List<Object?>.unmodifiable(a),
            ArrayValueType(params.first.type, 'internal', tv.environment, tv.typeTable),
          ),
        );
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
            scope.environment.stack.removeLast();
            if (getType(value.value, scope, line, col, file, false).isSubtypeOf(returnType)) return value.value;
            throw BSCException(
                "You cannot return a ${getType(value.value!, scope, line, col, file, false)} (${toStringWithStacker(value.value!, line, col, file, false)}) from ${fromClass}${name.name}, which is supposed to return a $returnType!     ${formatCursorPosition(line, col, file)}\n${funscope.environment.stack.reversed.join('\n')} ",
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
      scope.environment.stack.removeLast();
      return null;
    };
    function = SydFunction<Object?>(
      _value,
      FunctionValueType(returnType, params.map((e) => e.type), file, tv.environment, tv.typeTable),
      Concat(file, Concat('::', name.name)),
    );
    scope.newVar(
      name,
      function,
    );
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

  late ValueType whateverIterableType =
      IterableValueType<Object?>(ValueType.create(whateverVariable, -2, 0, 'intrinsics', tv.environment, tv.typeTable), 'TODO FORS', tv.environment, tv.typeTable);

  @override
  StatementResult run(Scope scope) {
    Object? listVal = list.eval(scope);
    if (listVal is! SydIterable) {
      throw BSCException(
          'Tried to iterate (for loop) over a ${getType(listVal, scope, line, col, file, false)}, which is not an iterable at ${formatCursorPosition(line, col, file)} \n${scope.environment.stack.reversed.join('\n')}',
          scope);
    }
    for (Object? identVal in listVal.iterable) {
      Scope forScope = Scope(false, false, scope.rtl, scope.environment,
          parent: scope,
          debugName: CursorPositionLazyString(
            'for statement scope',
            line,
            col,
            file,
          ),
          intrinsics: scope.intrinsics,
          identifiers: scope.identifiers);
      forScope.newVar(ident, identVal);
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
        debugName: CursorPositionLazyString(
          'enum scope',
          line,
          col,
          file,
        ),
        identifiers: scope.identifiers);
    scope.newVar(name, SydEnum(newScope, type, name));
    for (Identifier field in fields) {
      newScope.newVar(
        field,
        SydEnumValue(
          Concat(IdentifierLazyString(name), Concat('.', field.name)),
          type.propertyType,
        ),
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
        declaringClass: type,
        debugName: CursorPositionLazyString(
          'class statement - methods scope',
          line,
          col,
          file,
        ),
        intrinsics: scope.intrinsics,
        identifiers: scope.identifiers);
    Scope staticMembers = Scope(false, true, scope.rtl, scope.environment,
        parent: superclass == null
            ? null
            : type.supertype!.generatedConstructor?.staticMembers ??
                (throw BSCException(
                    'Class ${name.name} is defined as subtyping ${type.supertype!.name.name}, but that has not been declared yet, merely forward-declared. ${formatCursorPosition(line, col, file)} ${scope.environment.stack.reversed.join('\n')}',
                    scope)),
        debugName: ConcatenateLazyString(NotLazyString('staticMembersOf'), IdentifierLazyString(name)),
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
        staticMembers.newVar(s.name, s.val.eval(scope));
      }
    }
    type.methods = methods;
    if (type.supertype != null) {
      // check that "fwdclass A; class B extends A { }" fails
      if (type.supertype!.methods == null) {
        throw BSCException('ERROR', scope);
      }
    }
    SydFunction? userConstructor;
    if (!methods.directlyContains(constructorVariable)) {
      if (superclass == null) {
        // root class default constructor
        userConstructor = SydFunction(
          (List<Object?> args, [Scope? thisScope, ValueType? thisType]) {
            if (args.length != 0) {
              throw Exception(
                'default constructor takes no arguments - passed ${args.length} arguments ${formatCursorPosition(line, col, file)} ${scope.environment.stack.reversed.join('\n')}',
                //scope,
              );
            }
            return null;
          },
          FunctionValueType(type, [], file, tv.environment, tv.typeTable),
          Concat(name.name, '.defaultconstructor'),
        );
      } else {
        userConstructor = type.supertype!.methods!.getVarByName(constructorVariable) as SydFunction;
      }
    } else {
      Object? method = methods.getVarByName(constructorVariable);

      userConstructor = method as SydFunction;
    }
    methods.newVar(constructorVariable, userConstructor);
    // Class Field Initializer (internal method)
    type.fieldInitializer = SydFunction(
      (List<Object?> args, [Scope? thisScope, ValueType? thisType]) {
        if (superclass != null) {
          type.supertype!.fieldInitializer.function(<Object?>[], thisScope, thisType);
        }
        for (Statement s in block) {
          if (s is NewVarStatement || s is FunctionStatement) {
            if (s is FunctionStatement && methods.directlyContains(s.name)) {
              Object? value = methods.getVarByName(s.name);
              thisScope!.newVar(
                s.name,
                SydFunction(
                  (List<Object?> args2, [Scope? thisScope2, ValueType? thisType2]) {
                    return (value as SydFunction).function(args2, thisScope, thisType);
                  },
                  getType(value, scope, line, col, file, false) as ValueType<SydFunction>,
                  Concat(name.name, Concat('.', s.name.name)),
                ),
              );
              continue;
            }
            StatementResult sr = s.run(thisScope!);
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
      FunctionValueType(type, [], file, tv.environment, tv.typeTable),
      Concat('~', name.name),
    );
    // Generated Constructor
    type.generatedConstructor = Class(
      staticMembers,
      SydFunction(
        (List<Object?> args, [Scope? thisScope, ValueType? thisType]) {
          Scope thisScope = Scope(
            true,
            false,
            scope.rtl,
            scope.environment,
            parent: scope,
            debugName: NotLazyString('${name.name}'),
            typeIfClass: type,
            intrinsics: scope.intrinsics,
            identifiers: scope.identifiers,
          );
          thisScope.newVar(
            thisVariable,
            thisScope,
          );
          thisScope.newVar(classNameVariable, name.name);
          type.fieldInitializer.function(<Object?>[], thisScope, type);
          if (userConstructor == null) {
            userConstructor = thisScope.getVarByName(constructorVariable) as SydFunction;
          }
          userConstructor!.function(args, thisScope, type);
          return thisScope;
        },
        FunctionValueType(type, InfiniteIterable(tv.environment.anythingType), file, tv.environment, tv.typeTable),
        Concat(name.name, '.generatedconstructor'),
      ),
      classOfType,
    );
    if (type.forwardDeclared) {
      if (tv.globalScope) {
        scope.environment.globals[name] = type.generatedConstructor;
      } else {
        scope.writeToByName(
          name,
          type.generatedConstructor,
        );
      }
    } else {
      scope.newVar(
        name,
        type.generatedConstructor,
      );
    }
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

class ForwardClassStatement extends Statement {
  final Identifier className;
  final ValueType type;
  ForwardClassStatement(this.className, this.type, super.line, super.col);

  @override
  StatementResult run(Scope scope) {
    scope.newVar(className, SydSentinel(scope.environment));
    return StatementResult(StatementResultType.nothing);
  }
}
