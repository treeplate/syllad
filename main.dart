import 'lexer.dart';
import 'dart:io';
import 'runner.dart';
import 'statement-parser.dart';

void main() {
  try {
    runProgram(
        parse(
                lex(File('compiler/syd.syd').readAsStringSync(), 'syd.syd')
                    .toList(),
                'syd.syd',
                false)
            .key,
        'syd.syd');
  } on FileInvalid catch (e) {
    print("$e");
    exit(1);
  } on StackOverflowError catch (e, st) {
    print("$e\n$st");
  }
}
