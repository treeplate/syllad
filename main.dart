import 'lexer.dart';
import 'dart:io';
import 'parser.dart';

void main() {
  try {
    runProgram(
        parse(lex(File('syd.syd').readAsStringSync()).toList(), 'syd.syd').key);
  } on FileInvalid catch (e) {
    print("$e");
    exit(1);
  }
}
