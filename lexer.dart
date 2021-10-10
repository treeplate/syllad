enum TokenType {
  endOfStatement, // ;

  openParen, // (
  closeParen, // )
  openBrace, // {
  closeBrace, // }

  comma, // ,

  plus, // +
  minus, // -
  divide, // /
  multiply, // *

  equals, // ==
  notEquals, // !=
  greater, // >
  less, // <

  set, // =
}

abstract class Token {}

abstract class CharToken {
  TokenType get type;
}

abstract class IdentToken {
  // cat, dog, etc
  String get ident;
}

abstract class StringToken {
  // "str" or 'str' (with \n and \\)
  String get str;
}

abstract class IntToken {
  // 3 or -3 or 34, etc
  int get integer;
}

List<Token> lex(String file) {
  // /* - (\\ or */) multi-line comment, # or // single-line comments (\\ to end comment)
  throw UnimplementedError();
}
