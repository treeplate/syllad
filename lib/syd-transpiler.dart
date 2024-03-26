import 'dart:io';
import 'package:args/args.dart';
import 'package:path/path.dart' as path;
import 'package:syllad/syd-expressions.dart';

import 'package:syllad/syd-lexer.dart';
import 'package:syllad/syd-statements.dart';
import 'syd-statement-parser.dart';
import 'syd-core.dart';

late RandomAccessFile file = File('transpiler-output.dart').openSync(mode: FileMode.writeOnlyAppend);

void print(String contents) {
  file.writeStringSync('$contents\n');
}

Map<ClassValueType, String> constructorNames = {};
int currentConstructor = 0;

String transpileType(ValueType type) {
  switch (type) {
    case ClassValueType():
    case EnumPropertyValueType():
      return type.name.name;
    case ListValueType(genericParameter: ValueType elementType):
      return 'core.List<${transpileType(elementType)}>';
    case ArrayValueType(genericParameter: ValueType elementType):
      return 'core.List<${transpileType(elementType)}>';
    case IterableValueType(genericParameter: ValueType elementType):
      return 'core.Iterable<${transpileType(elementType)}>';
    case IteratorValueType(genericParameter: ValueType elementType):
      return 'core.Iterator<${transpileType(elementType)}>';
    case GenericFunctionValueType():
      return 'core.Function';
    case NullableValueType(genericParam: ValueType elementType):
      return '${transpileType(elementType)}?';
    case NullValueType():
      return 'core.Null';
    case ValueType(name: Identifier name):
      switch (name.name) {
        case 'String':
        case 'StringBuffer':
          return 'core.${name.name}';
        case 'Integer':
          return 'core.int';
        case 'Boolean':
          return 'core.bool';
        case 'File':
          return 'File';
        case 'Anything':
          return 'core.Object?';
        case 'Whatever':
          return 'core.dynamic';
        default:
          throw StateError('unknown type ${name.name}');
      }
  }
}

String transpileExpression(Expression expression) {
  switch (expression) {
    case GetExpr(name: Identifier name, staticType: ValueType type, variablePath: List<int> path):
      if (type is ClassOfValueType) {
        return '${name.name}()..${constructorNames[type.classType]!}';
      }
      if (path.first == -1 && name != thisVariable) {
        return 'this.${name.name}';
      }
      if (path.first != -1 && path.first != -2 && expression.tv.followPathToScope(path).parents.isNotEmpty &&
          expression.tv.followPathToScope(path).igvnc(name) &&
          type is! EnumValueType) {
        return '${name.name}\$${expression.tv.followPathToScope(path).id}';
      }
      return name.name;
    case AddExpression(a: Expression lhs, b: Expression rhs):
      return '(${transpileExpression(lhs)}) + (${transpileExpression(rhs)})';
    case SubtractExpression(a: Expression lhs, b: Expression rhs):
      return '(${transpileExpression(lhs)}) - (${transpileExpression(rhs)})';
    case MultiplyExpression(a: Expression lhs, b: Expression rhs):
      return '(${transpileExpression(lhs)}) * (${transpileExpression(rhs)})';
    case DivideExpression(a: Expression lhs, b: Expression rhs):
      return '(${transpileExpression(lhs)}) ~/ (${transpileExpression(rhs)})';
    case RemainderExpression(a: Expression lhs, b: Expression rhs):
      return '(${transpileExpression(lhs)}) % (${transpileExpression(rhs)})';
    case ShiftLeftExpression(a: Expression lhs, b: Expression rhs):
      return '(${transpileExpression(lhs)}) << (${transpileExpression(rhs)})';
    case ShiftRightExpression(a: Expression lhs, b: Expression rhs):
      return '(${transpileExpression(lhs)}) >> (${transpileExpression(rhs)})';
    case PowExpression(a: Expression lhs, b: Expression rhs):
      return 'math.pow(${transpileExpression(lhs)}, ${transpileExpression(rhs)})';
    case LessExpression(a: Expression lhs, b: Expression rhs):
      return '(${transpileExpression(lhs)}) < (${transpileExpression(rhs)})';
    case GreaterExpression(a: Expression lhs, b: Expression rhs):
      return '(${transpileExpression(lhs)}) > (${transpileExpression(rhs)})';
    case AndExpression(a: Expression lhs, b: Expression rhs):
      return '(${transpileExpression(lhs)}) && (${transpileExpression(rhs)})';
    case BitAndExpression(a: Expression lhs, b: Expression rhs):
      return '(${transpileExpression(lhs)}) & (${transpileExpression(rhs)})';
    case OrExpression(a: Expression lhs, b: Expression rhs):
      return '(${transpileExpression(lhs)}) || (${transpileExpression(rhs)})';
    case BitOrExpression(a: Expression lhs, b: Expression rhs):
      return '(${transpileExpression(lhs)}) | (${transpileExpression(rhs)})';
    case BitXorExpression(a: Expression lhs, b: Expression rhs):
      return '(${transpileExpression(lhs)}) ^ (${transpileExpression(rhs)})';
    case EqualsExpression(a: Expression lhs, b: Expression rhs):
      return '(${transpileExpression(lhs)}) == (${transpileExpression(rhs)})';
    case IsExpr(operand: Expression lhs, isType: ValueType rhs):
      return '(${transpileExpression(lhs)}) is ${transpileType(rhs)}';
    case AsExpr(operand: Expression lhs, isType: ValueType rhs):
      if (lhs.staticType is ListValueType && rhs is ListValueType) {
        return '${transpileExpression(lhs)}.cast()';
      }
      return '(${transpileExpression(lhs)}) as ${transpileType(rhs)}';
    case NotExpression(a: Expression rhs):
      return '!(${transpileExpression(rhs)})';
    case BitNotExpression(a: Expression rhs):
      return '~(${transpileExpression(rhs)})';
    case UnwrapExpression(a: Expression lhs):
      return '(${transpileExpression(lhs)})!';
    case SubscriptExpression(a: Expression lhs, b: Expression rhs):
      return '(${transpileExpression(lhs)})[${transpileExpression(rhs)}]';
    case MemberAccessExpression(a: Expression lhs, b: Identifier rhs):
      return '${lhs is GetExpr ? transpileExpression(lhs) : '(${transpileExpression(lhs)})'}.${rhs.name}';
    case FunctionCallExpr(a: Expression func, b: List<Expression> args):
      ValueType type = func.staticType;
      if (type is FunctionValueType && type.parameters is InfiniteIterable ||
          type is ClassOfValueType && (type.constructor as FunctionValueType).parameters is InfiniteIterable) {
        return '${transpileExpression(func)}(core.List.unmodifiable([${args.map((e) => transpileExpression(e)).join(', ')}]))';
      } else {
        return '${transpileExpression(func)}(${args.map((e) => transpileExpression(e)).join(', ')})';
      }
    case AssertExpression(condition: Expression arg1, comment: Expression arg2, line: int line, col: int col, file: String file):
      String message = '\${${transpileExpression(arg2)}} (${arg1.toString().replaceAll('\\', '\\\\').replaceAll('\'', '\\\'').replaceAll('\n', '\\n').replaceAll('\r', '\\r').replaceAll('\x00', '\\x00').replaceAll('\$', '\\\$')} was not true) ${formatCursorPosition(line, col, file)}';
      return '() {if(!(${transpileExpression(arg1)})) {throw (\'$message\');}}()';
    case IntLiteralExpression(n: int value):
      return '$value';
    case StringLiteralExpression(n: String value):
      return '\'${value.replaceAll('\\', '\\\\').replaceAll('\'', '\\\'').replaceAll('\n', '\\n').replaceAll('\r', '\\r').replaceAll('\x00', '\\x00').replaceAll('\$', '\\\$')}\'';
    case ListLiteralExpression(n: List<Expression> value, genParam: ValueType type):
      return '<${transpileType(type)}>[${value.map((e) => transpileExpression(e)).join(', ')}]';
    case SuperExpression(member: Identifier rhs):
      if (rhs == constructorVariable) {
        return '${constructorNames[(ValueType.create(expression.tv.identifiers[classType!.name.name]!, expression.line, expression.col, expression.file, expression.tv.environment, expression.tv.typeTable) as ClassValueType).supertype!]!}';
      }
      return 'super.${rhs.name}';
    default:
      throw StateError('unknown expression $expression');
  }
}

void transpileStatement(Statement statement, Environment env, int indent) {
  switch (statement) {
    case ImportStatement():
    case ClassStatement():
    case EnumStatement():
      throw StateError('non-globalscope import/class/enum $statement');
    case ForwardClassStatement():
      break;
    case ExpressionStatement(expr: Expression expr):
      print('${'  ' * indent}${transpileExpression(expr)};');
    case SetStatement(l: Expression lhs, val: Expression rhs):
      print('${'  ' * indent}${transpileExpression(lhs)} = ${transpileExpression(rhs)};');
    case NewVarStatement(type: ValueType type, name: Identifier lhs, val: Expression? rhs):
      print(
          '${'  ' * indent}${rhs == null ? 'late ' : ''}${transpileType(type)} ${lhs.name}${!statement.tv.inClass || !statement.tv.parents.every((element) => !element.inClass) ? '\$${statement.tv.id}' : ''}${rhs == null ? '' : ' = ${transpileExpression(rhs)}'};');
    case WhileStatement(cond: Expression condition, body: List<Statement> statements):
      print('${'  ' * indent}while (${transpileExpression(condition)}) {');
      for (Statement statement in statements) {
        transpileStatement(statement, env, indent + 1);
      }
      print('${'  ' * indent}}');
    case ForStatement(ident: Identifier ident, list: Expression list, body: List<Statement> statements):
      print('${'  ' * indent}for (${transpileType(elementTypeOf(list.staticType as ValueType<SydIterable>))} ${ident.name} in ${transpileExpression(list)}) {');
      for (Statement statement in statements) {
        transpileStatement(statement, env, indent + 1);
      }
      print('${'  ' * indent}}');
    case IfStatement(cond: Expression condition, body: List<Statement> ifBlock, elseBody: List<Statement> elseBlock):
      print('${'  ' * indent}if (${transpileExpression(condition)}) {');
      for (Statement statement in ifBlock) {
        transpileStatement(statement, env, indent + 1);
      }
      print('${'  ' * indent}}${elseBlock.isEmpty ? '' : ' else {'}');
      for (Statement statement in elseBlock) {
        transpileStatement(statement, env, indent + 1);
      }
      if (!elseBlock.isEmpty) {
        print('${'  ' * indent}}');
      }
    case FunctionStatement(returnType: ValueType returnType, name: Identifier name, params: Iterable<Parameter> params, body: List<Statement> body):
      if (params is InfiniteIterable) {
        params = [Parameter(ListValueType(params.first.type, statement.file, env, statement.tv.typeTable), params.first.name)];
      }
      if (name.name == 'abstract' || name.name == 'unimplemented') {
        print('${'  ' * indent}core.Never ${name.name}(${params.map((e) => '${transpileType(e.type)} ${e.name.name}').join(', ')}) {');
      } else if (name == constructorVariable && classType != null) {
        constructorCreated = true;
        print(
            '${'  ' * indent}${transpileType(returnType)} ${constructorNames[classType!]!}(${params.map((e) => '${transpileType(e.type)} ${e.name.name}').join(', ')}) {');
      } else {
        print('${'  ' * indent}${transpileType(returnType)} ${name.name}(${params.map((e) => '${transpileType(e.type)} ${e.name.name}').join(', ')}) {');
      }
      for (Statement statement in body) {
        transpileStatement(statement, env, indent + 1);
      }
      print('${'  ' * indent}}');
    case ContinueStatement():
      print('${'  ' * indent}continue;');
    case BreakStatement():
      print('${'  ' * indent}break;');
    case ReturnStatement(value: Expression rtv):
      if (rtv is NullExpr) {
        print('${'  ' * indent}return;');
      } else {
        print('${'  ' * indent}return ${transpileExpression(rtv)};');
      }
    default:
      throw StateError('unknown statement $statement');
  }
}

void transpileFile(List<Statement> statements, List<Statement> mainscope, Environment env) {
  for (Statement statement in statements) {
    switch (statement) {
      case ImportStatement():
      case ClassStatement():
      case EnumStatement():
      case FunctionStatement():
      case NewVarStatement():
        transpileGlobalscopeStatement(statement, mainscope, env);
      case ExpressionStatement():
      case SetStatement():
      case WhileStatement():
      case ForStatement():
      case IfStatement():
        mainscope.add(statement);
      case ForwardClassStatement():
      case NopStatement():
        break;
      default:
        throw StateError('unknown statement $statement');
    }
  }
}
void transpileGlobalscopeStatement(Statement statement,  List<Statement> mainscope, Environment env) {
  switch (statement) {
    case ImportStatement(file: List<Statement> file, filename: String filename):
      if (env.filesRan[filename] == null) {
        env.filesRan[filename] = Scope(false, false, null, env, intrinsics: null, debugName: NotLazyString('emptyscope'), identifiers: env.identifiers);
        transpileFile(file, mainscope, env);
      }
    case FunctionStatement(returnType: ValueType returnType, name: Identifier name, params: Iterable<Parameter> params, body: List<Statement> body):
      if (params is InfiniteIterable) {
        params = [Parameter(ListValueType(params.first.type, statement.file, env, statement.tv.typeTable), params.first.name)];
      }
      print('${name.name == 'compileeSourceError' ? 'core.Never' : transpileType(returnType)} ${name.name}(${params.map((e) => '${transpileType(e.type)} ${e.name.name}').join(', ')}) {');
      for (Statement statement in body) {
        transpileStatement(statement, env, 1);
      }
      print('}');
    case EnumStatement(fields: List<Identifier> values, name: Identifier name):
      print('enum ${name.name} {');
      for (Identifier value in values) {
        print('  ${value.name},');
      }
      print('}');
    case ClassStatement(name: Identifier name, superclass: Identifier? superclass, block: List<Statement> body, type: ClassValueType type,):
      classType = type;
      constructorCreated = false;
      print(
        'class ${name.name} extends ${superclass == null ? 'core.Object' : transpileType(ValueType.create(superclass, statement.line, statement.col, statement.file, env, statement.tv.typeTable))} {',
      );
      print('  final core.String className = \'${classType!.name.name}\';');
      for (final Statement statement in body) {
        transpileStatement(statement, env, 1);
      }
      if (constructorCreated == false) {
        ClassOfValueType type =
            ValueType.create(statement.tv.identifiers[name.name + 'Class']!, statement.line, statement.col, statement.file, env, statement.tv.typeTable)
                as ClassOfValueType;
        Iterable<ValueType> params = (type.constructor as FunctionValueType).parameters;
        if (params is InfiniteIterable) {
          params = [ListValueType(params.first, statement.file, env, statement.tv.typeTable)];
        }
        int i = 0;
        print('  core.Null ${constructorNames[classType]!}(${params.map((e) => '${transpileType(e)} arg${i++}').join(', ')}) {');
        i = 0;
        print('    ${constructorNames[type.classType.supertype!]}(${params.map((e) => 'arg${i++}').join(', ')});');
        print('  }');
      }
      print('}');
      classType = null;
    case NewVarStatement(type: ValueType type, name: Identifier lhs, val: Expression? rhs):
      print('late ${transpileType(type)} ${lhs.name};');
      if (rhs != null) mainscope.add(SetStatement(GetExpr(lhs, statement.tv, statement.line, statement.col, statement.file), rhs, statement.line, statement.col, statement.file));
    default:
      throw StateError('unknown globalscope statement $statement');
  }
}

ClassValueType? classType;
bool constructorCreated = false;

void transpile(String fileContents, String rtlPath, String fileName) {
  final Environment environment = Environment(TypeTable([]), stderr, stderr, ['error'], exit);
  final Map<String, Identifier> identifiers = environment.identifiers;
  var rtl = parse(lex(File(rtlPath).readAsStringSync(), rtlPath, environment), rtlPath, null, false, identifiers, environment);
  var parseResult = parse(
    lex(
      fileContents,
      fileName,
      environment,
    ).toList(),
    fileName,
    rtl,
    true,
    identifiers,
    environment,
  );
  for (ValueType type in environment.allTypes) {
    if (type is ClassValueType) {
      constructorNames[type] = 'constructor${currentConstructor++}';
    }
  }
  List<Statement> mainscope = [];
  print('import \'dart:core\' as core;');
  print('import \'dart:math\' as math;');
  print('import \'transpiler-intrinsics.dart\';');
  print('// ignore_for_file: unnecessary_cast');
  print('// ignore_for_file: unused_element');
  print('// ignore_for_file: unused_local_variable');
  print('// ignore_for_file: unnecessary_non_null_assertion');
  print('// ignore_for_file: dead_code');
  print('late core.List<core.String> args;');
  transpileFile(rtl.key, mainscope, environment);
  transpileFile(parseResult.key, mainscope, environment);
  print('void main(core.List<core.String> args2) {');
  print('args = [\$arg0, ...args2];');
  for (Statement statement in mainscope) {
    transpileStatement(statement, environment, 1);
  }
  print('}');
}

void main(List<String> args) async {
  File('transpiler-output.dart').writeAsStringSync('');
  ArgParser parser = ArgParser(allowTrailingOptions: false);
  ArgResults parsedArgs = parser.parse(args);
  if (parsedArgs.rest.length != 1) {
    stderr
        .writeln("This program takes 1 argument: the filename. You have passed in ${parsedArgs.rest.length}: ${parsedArgs.rest.map((e) => '|$e|').join(', ')}");
    exit(1);
  }
  String file = parsedArgs.rest.single;
  String fileContents = File(file).readAsStringSync();
  try {
    String rtlDirectory = path.dirname(path.fromUri(Platform.script));
    String rtlPath = path.join(rtlDirectory, 'rtl.syd');
    transpile(fileContents, rtlPath, file);
  } on SydException catch (e) {
    stderr.writeln("$e");
    stderr.writeln("generating scope dump...");
    File('error-dump.txt')
        .writeAsStringSync(e.toString() + '\n\n' + e.scope.dump() + e.scope.environment.allTypes.map((value) => '${value.name.name}: ${value.id}').join('\n'));
    stderr.writeln("done");
    exit(e.exitCode);
  }
}
