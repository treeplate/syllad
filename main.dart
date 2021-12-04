import 'lexer.dart';
import 'dart:io';
import 'parser.dart';

void main() {
  try {
    runProgram(
        parse(lex(File('eqm.syd').readAsStringSync()).toList(), 'eqm.syd').key);
  } on FileInvalid catch (e, st) {
    print("$e\n$st");
    exit(1);
  } on StackOverflowError catch (e, st) {
    print("$e\n$st");
  }
}
