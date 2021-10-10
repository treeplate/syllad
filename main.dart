import 'lexer.dart';

void main() {
  try {
    lex("hhhhh");
  } catch (e) {
    print(e);
  }
}
