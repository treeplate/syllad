import 'lexer.dart';
import 'dart:io';
import 'runner.dart';
import 'statement-parser.dart';

void main(List<String> args) {
  if (!(args.length == 0 || args.length == 2)) {
    print(
        "This program either takes no args or takes 2: the workspace of the file, and the filename.");
    exit(1);
  }
  String workspace = args.isEmpty ? './compiler' : args.first;
  String arg = args.isEmpty ? 'syd.syd' : args.last;
  try {
    runProgram(
        parse(
                lex(
                  File(workspace + '/' + arg).readAsStringSync(),
                  workspace,
                  arg,
                ).toList(),
                workspace,
                arg,
                false)
            .key,
        arg,
        null);
  } on FileInvalid catch (e) {
    print("$e");
    exit(1);
  } on StackOverflowError catch (e, st) {
    print("$e\n$st");
  }
}
