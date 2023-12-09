import 'dart:io';
import 'syd-core.dart';
import 'syd-lexer.dart';
import 'syd-statement-parser.dart';

// this program relies on current working directory being the directory with tests/ and lib/, because `dart test` makes Platform.script be somewhere outside of this directory
Scope runProgram(List<Statement> ast, String filename, Scope? intrinsics, Scope? rtl, TypeValidator tv, bool profileMode, bool debugMode, IOSink stdout,
    IOSink stderr, void Function(int) exit,
    [List<String>? args, List<LazyString>? stack, Scope? parent]) {
  if (intrinsics == null) {
    assert(parent == null);
    assert(stack == null);
    intrinsics = Scope(
      false,
      false,
      rtl,
      tv.environment,
      identifiers: tv.identifiers,
      debugName: NotLazyString('intrinsics'),
      profileMode: profileMode,
      debugMode: debugMode,
      intrinsics: null /* we ARE the intrinsics*/,
    );
    tv.environment.intrinsics.forEach((String name, Object? value) {
      intrinsics!.newVar(tv.environment.identifiers[name] ??= Identifier(name), value);
    });
  }
  Scope scope = Scope(false, false, rtl, tv.environment,
      intrinsics: intrinsics, parent: parent ?? rtl ?? intrinsics, debugName: NotLazyString('$filename global scope'), identifiers: tv.identifiers);
  for (Statement statement in ast) {
    StatementResult sr = statement.run(scope);
    switch (sr.type) {
      case StatementResultType.nothing:
        break;
      case StatementResultType.breakWhile:
        throw BSCException('Break outside while', scope);
      case StatementResultType.continueWhile:
        throw BSCException('Continue outside while', scope);
      case StatementResultType.returnFunction:
        throw BSCException('Returned ${sr.value} outside function', scope);
      case StatementResultType.unwindAndThrow:
        stderr.writeln(sr.value);
        exit(1);
    }
  }
  return scope;
}

Environment runFile(String fileContents, String rtlPath, String file, bool profileMode, bool debugMode, List<String> commandLineArguments, IOSink stdout,
    IOSink stderr, void Function(int) exit) {
  final Environment environment = Environment(TypeTable(), stdout, stderr, commandLineArguments, exit);
  final Map<String, Identifier> identifiers = environment.identifiers;

  var rtl = parse(lex(File(rtlPath).readAsStringSync(), rtlPath, environment), rtlPath, null, false, identifiers, environment);
  var parseResult = parse(
    lex(
      fileContents,
      file,
      environment,
    ).toList(),
    file,
    rtl,
    true,
    identifiers,
    environment,
  );
  for (ValueType type in environment.typeTable.types.values) {
    if (type is ClassValueType && type.notFullyDeclared) {
      throw BSCException('$type forward-declared but never declared', parseResult.value);
    }
  }
  Scope rtl2 = runProgram(
    rtl.key,
    rtlPath,
    null,
    null,
    rtl.value,
    profileMode,
    debugMode,
    stdout,
    stderr,
    exit,
    commandLineArguments,
  );
  runProgram(
    parseResult.key,
    file,
    null,
    rtl2,
    parseResult.value,
    profileMode,
    debugMode,
    stdout,
    stderr,
    exit,
    commandLineArguments,
  );
  return environment;
}
