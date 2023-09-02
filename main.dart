import 'lexer.dart';
import 'dart:io';
import 'parser-core.dart';
import 'runner.dart';
import 'statement-parser.dart';

void main(List<String> args) {
  bool profileMode = false;
  if (args.first == '--profile') {
    profileMode = true;
    args = args.skip(1).toList();
  }
  bool debugMode = false;
  if (args.first == '--debug') {
    debugMode = true;
    args = args.skip(1).toList();
  }
  if (args.first == '--profile') {
    profileMode = true;
    args = args.skip(1).toList();
  }
  if (!(args.length >= 2)) {
    stderr.writeln(
        "This program takes 2+ arguments: the workspace of the file, and the filename, and then the arguments to the program it is running. You have passed in ${args.length}: ${args.map((e) => '|$e|').join(', ')}");
    exit(1);
  }
  String workspace = args.first;
  String file = args[1];
  String fileContents = File(workspace + '/' + file).readAsStringSync();
  if (fileContents.startsWith('// expected') || fileContents.startsWith('// unexpected')) {
    const String expectedOutput = '// expected output: ';
    const String expectedStderr = '// expected stderr: ';
    const String expectedError = '// expected error: ';
    const String expectedExitCode = '// expected exit code is ';
    List<String> lines = fileContents.split('\n');
    bool fileUsesCRLF = fileContents.contains('\r\n');
    int exitCode = 0;
    for (String line in lines) {
      if (1 == 1) break;
      if (line.startsWith(expectedOutput)) {
        print(line.substring(expectedOutput.length, line.length - (fileUsesCRLF ? 1 : 0)));
      } else if (line.startsWith(expectedError)) {
        stderr.writeln('error');
        exitCode = -5;
      } else if (line.startsWith(expectedStderr)) {
        stderr.writeln(line.substring(expectedStderr.length, line.length - (fileUsesCRLF ? 1 : 0)));
      } else if (line.startsWith(expectedExitCode)) {
        exitCode = int.parse(line.substring(expectedExitCode.length, line.length - (fileUsesCRLF ? 1 : 0)));
      } else if (!line.startsWith('//')) {
        exit(exitCode);
      }
    }
  }
  try {
    handleVariable(whateverVariable);
    handleVariable(classMethodsVariable);
    handleVariable(fwdclassVariable);
    handleVariable(fwdclasspropVariable);
    handleVariable(classVariable);
    handleVariable(namespaceVariable);
    handleVariable(importVariable);
    handleVariable(whileVariable);
    handleVariable(breakVariable);
    handleVariable(continueVariable);
    handleVariable(returnVariable);
    handleVariable(ifVariable);
    handleVariable(enumVariable);
    handleVariable(forVariable);
    handleVariable(constVariable);
    handleVariable(classNameVariable);
    handleVariable(constructorVariable);
    handleVariable(thisVariable);
    handleVariable(toStringVariable);
    handleVariable(throwVariable);
    handleVariable(Variable('Anything'));
    handleVariable(Variable('Integer'));
    handleVariable(Variable('String'));
    handleVariable(Variable('Boolean'));
    handleVariable(Variable('Null'));
    handleVariable(Variable('~root_class'));
    var parseResult = parse(
        lex(
          fileContents,
          workspace,
          file,
        ).toList(),
        workspace,
        file,
        false,
        true);
    for (ValueType type in ValueType.types.values) {
      if (type is ClassValueType && type.fwdDeclared) {
        throw BSCException('$type forward-declared but never declared', parseResult.value);
      }
    }
    runProgram(
      parseResult.key,
      file,
      workspace,
      null,
      parseResult.value,
      profileMode,
      debugMode,
      args.skip(2).toList(),
    );
    File('profile.txt').writeAsStringSync((profile.entries.toList()
          ..sort((kv2, kv1) => kv1.value.key.elapsedMilliseconds.compareTo(kv2.value.key.elapsedMilliseconds)))
        .map((kv) => '${kv.key.name} took ${kv.value.key.elapsedMilliseconds} milliseconds total across ${kv.value.value} calls.')
        .join('\n'));
  } on SydException catch (e) {
    stderr.writeln("$e");
    stderr.writeln("generating scope dump...");
    File('error-dump.txt').writeAsStringSync(e.toString() + '\n\n' + e.scope.dump());
    stderr.writeln("done");
    exit(e.exitCode);
  } on StackOverflowError catch (e, st) {
    stderr.writeln("(somehow a StackOverflow got past my try..on) $e\n$st");
    exit(-1);
  }
}
