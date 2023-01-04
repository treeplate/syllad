import 'lexer.dart';
import 'dart:io';
import 'parser-core.dart';
import 'runner.dart';
import 'statement-parser.dart';

void main(List<String> args) {
  if (!(args.length == 0 || args.length >= 2)) {
    stderr.writeln("This program takes 2+ arguments: the workspace of the file, and the filename, and then the arguments to the program it is running.");
    exit(1);
  }
  String workspace = args.isEmpty ? './compiler' : args.first;
  String file = args.isEmpty ? 'syd.syd' : args[1];
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
    handleVariable(throwVariable);
    handleVariable(Variable('Anything'));
    handleVariable(Variable('Integer'));
    handleVariable(Variable('String'));
    handleVariable(Variable('Boolean'));
    handleVariable(Variable('Null'));
    var parseResult = parse(
        lex(
          File(workspace + '/' + file).readAsStringSync(),
          workspace,
          file,
        ).toList(),
        workspace,
        file,
        false,
        true);
    runProgram(
      parseResult.key,
      file,
      workspace,
      null,
      parseResult.value,
      args.isEmpty ? [] : args.skip(2).toList(),
    );
    File('profile.txt').writeAsStringSync((profile.entries.toList()
          ..sort((kv2, kv1) => kv1.value.key.elapsedMilliseconds.compareTo(kv2.value.key.elapsedMilliseconds)))
        .map((kv) => '${kv.key.name} took ${kv.value.key.elapsedMilliseconds} milliseconds total across ${kv.value.value} calls.')
        .join('\n'));
  } on SydException catch (e) {
    stderr.writeln("$e");
    exit(e.exitCode);
  } on StackOverflowError catch (e, st) {
    stderr.writeln("$e\n$st");
    exit(-1);
  }
}
