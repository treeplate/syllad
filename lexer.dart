enum TokenType {
  endOfStatement, // ;
  endOfFile, // EOF

  openParen, // (
  closeParen, // )
  openSquare, // [
  closeSquare, // ]
  openBrace, // {
  closeBrace, // }

  comma, // ,
  period, // .
  ellipsis, // ...
  bang, // !

  plus, // +
  minus, // -
  divide, // /
  multiply, // *
  remainder, // %

  equals, // ==
  notEquals, // !=
  greater, // >
  greaterEqual, // >=
  lessEqual, // <=
  less, // <

  andand, // &&
  oror, // ||

  bitAnd, // &
  bitOr, // |
  bitXor, // ^
  tilde, // ~
  leftShift, // <<
  rightShift, // >>

  set, // =
  colon,
}

abstract class Token {
  Token(this.line, this.col);
  final int line;
  final int col;
}

class CharToken extends Token {
  CharToken(this.type, int line, int col) : super(line, col);

  final TokenType type;

  String toString() => "$type";
}

class IdentToken extends Token {
  // catDog, cat_dog, catdog, etc

  final String ident;

  IdentToken(this.ident, int line, int col) : super(line, col);

  String toString() => "$ident";
}

class StringToken extends Token {
  // "str" or 'str'

  final String str;

  StringToken(this.str, int line, int col) : super(line, col);

  String toString() => "'$str'";
}

class IntToken extends Token {
  // catDog, cat_dog, catdog, etc

  final int integer;

  String toString() => '$integer';

  IntToken(this.integer, int line, int col) : super(line, col);
}

enum _LexerState {
  top,
  integer,
  stringDq,
  stringSq,
  identifier,
  and,
  or,
  greaterThan,
  lessThan,
  equalTo,
  period,
  periodperiod,
  exclamationPoint,
  comment,
  commentBackslash,
  slash,
  stringDqBackslash,
  stringSqBackslash,
  multiLineComment,
  multiLineCommentBackslash,
  multiLineCommentStar,
}

Iterable<Token> lex(String file, String filename) sync* {
  // /* to (\\ or */) multi-line comment, # or // single-line comments (\\ to end comment)
  _LexerState state = _LexerState.top;
  StringBuffer intVal = StringBuffer();
  StringBuffer identVal = StringBuffer();
  StringBuffer strVal = StringBuffer();
  int line = 1;
  int col = 1;
  Iterable<Token> parseRuneFromTop(int rune) sync* {
    switch (rune) {
      case 0xa:
        line++;
        col = 1;
        break;
      case 0xd:
      case 0x20:
        break;
      case 0x21:
        state = _LexerState.exclamationPoint;
        break;
      case 0x22:
        state = _LexerState.stringDq;
        break;
      case 0x23:
        state = _LexerState.comment;
        break;
      case 0x25:
        yield CharToken(TokenType.remainder, line, col);
        break;
      case 0x26:
        state = _LexerState.and;
        break;
      case 0x27:
        state = _LexerState.stringSq;
        break;
      case 0x28:
        yield CharToken(TokenType.openParen, line, col);
        break;
      case 0x29:
        yield CharToken(TokenType.closeParen, line, col);
        break;
      case 0x2a:
        yield CharToken(TokenType.multiply, line, col);
        break;
      case 0x2b:
        yield CharToken(TokenType.plus, line, col);
        break;
      case 0x2c:
        yield CharToken(TokenType.comma, line, col);
        break;
      case 0x2d:
        yield CharToken(TokenType.minus, line, col);
        break;
      case 0x2e:
        state = _LexerState.period;
        break;
      case 0x2f:
        state = _LexerState.slash;
        break;
      // 0-9 are done later
      case 0x3a:
        yield CharToken(TokenType.colon, line, col);
        break;
      case 0x3b:
        yield CharToken(TokenType.endOfStatement, line, col);
        break;
      case 0x3c:
        state = _LexerState.lessThan;
        break;
      case 0x3d:
        state = _LexerState.equalTo;
        break;
      case 0x3e:
        state = _LexerState.greaterThan;
        break;
      // so are letters, and _
      case 0x5b:
        yield CharToken(TokenType.openSquare, line, col);
        break;
      case 0x5d:
        yield CharToken(TokenType.closeSquare, line, col);
        break;
      case 0x5e:
        yield CharToken(TokenType.bitXor, line, col);
        break;
      case 0x7b:
        yield CharToken(TokenType.openBrace, line, col);
        break;
      case 0x7c:
        state = _LexerState.or;
        break;
      case 0x7d:
        yield CharToken(TokenType.closeBrace, line, col);
        break;
      case 0x7e:
        yield CharToken(TokenType.tilde, line, col);
        break;
      default:
        if (rune - 0x30 >= 0 && rune - 0x30 <= 9) {
          intVal.writeCharCode(rune);
          state = _LexerState.integer;
        } else if ((rune >= 0x61 && rune <= 0x7a) ||
            (rune >= 0x41 && rune <= 0x5a) ||
            rune == 0x5f) {
          identVal.writeCharCode(rune);

          state = _LexerState.identifier;
        } else {
          throw FileInvalid(
            //print(
            "Unrecognized ${String.fromCharCode(rune)} at line $line column $col (U+${rune.toRadixString(16)} in Unicode)",
            //);
          );
        }
    }
  }

  for (int rune in file.runes) {
    switch (state) {
      case _LexerState.top:
        yield* parseRuneFromTop(rune);
        break;
      case _LexerState.integer:
        if (rune - 0x30 >= 0 && rune - 0x30 <= 9 ||
            rune == 0x78 ||
            rune == 0x61 ||
            rune == 0x62 ||
            rune == 0x63 ||
            rune == 0x64 ||
            rune == 0x65 ||
            rune == 0x66 ||
            rune == 0x58 ||
            rune == 0x41 ||
            rune == 0x42 ||
            rune == 0x43 ||
            rune == 0x44 ||
            rune == 0x45 ||
            rune == 0x46) {
          intVal.writeCharCode(rune);
        } else {
          yield IntToken(int.parse(intVal.toString()), line, col);
          intVal = StringBuffer();
          state = _LexerState.top;
          yield* parseRuneFromTop(rune);
        }
        break;
      case _LexerState.stringDq:
        if (rune == 0x22) {
          yield StringToken(strVal.toString(), line, col);
          strVal = StringBuffer();
          state = _LexerState.top;
        } else if (rune == 0x5c) {
          state = _LexerState.stringDqBackslash;
        } else {
          strVal.writeCharCode(rune);
        }
        break;
      case _LexerState.identifier:
        if ((rune - 0x30 >= 0 && rune - 0x30 <= 9) ||
            (rune >= 0x61 && rune <= 0x7a) ||
            (rune >= 0x41 && rune <= 0x5a) ||
            rune == 0x5f) {
          identVal.writeCharCode(rune);
        } else {
          yield IdentToken(identVal.toString(), line, col);
          identVal = StringBuffer();
          state = _LexerState.top;

          yield* parseRuneFromTop(rune);
        }

        break;
      case _LexerState.stringSq:
        if (rune == 0x27) {
          yield StringToken(strVal.toString(), line, col);
          strVal = StringBuffer();
          state = _LexerState.top;
        } else if (rune == 0x5c) {
          state = _LexerState.stringSqBackslash;
        } else {
          strVal.writeCharCode(rune);
        }
        break;
      case _LexerState.and:
        if (rune == 0x26) {
          yield CharToken(TokenType.andand, line, col);
          state = _LexerState.top;
        } else {
          yield CharToken(TokenType.bitAnd, line, col);
          state = _LexerState.top;

          yield* parseRuneFromTop(rune);
        }
        break;
      case _LexerState.or:
        if (rune == 0x7c) {
          yield CharToken(TokenType.oror, line, col);
          state = _LexerState.top;
        } else {
          yield CharToken(TokenType.bitOr, line, col);
          state = _LexerState.top;
          yield* parseRuneFromTop(rune);
        }
        break;
      case _LexerState.greaterThan:
        if (rune == 0x3d) {
          yield CharToken(TokenType.greaterEqual, line, col);
          state = _LexerState.top;
        } else if (rune == 0x3e) {
          yield CharToken(TokenType.rightShift, line, col);
          state = _LexerState.top;
        } else {
          yield CharToken(TokenType.greater, line, col);
          state = _LexerState.top;
          yield* parseRuneFromTop(rune);
        }
        break;
      case _LexerState.lessThan:
        if (rune == 0x3d) {
          yield CharToken(TokenType.lessEqual, line, col);
          state = _LexerState.top;
        } else if (rune == 0x3c) {
          yield CharToken(TokenType.leftShift, line, col);
          state = _LexerState.top;
        } else {
          yield CharToken(TokenType.less, line, col);
          state = _LexerState.top;
          yield* parseRuneFromTop(rune);
        }
        break;
      case _LexerState.equalTo:
        if (rune == 0x3d) {
          yield CharToken(TokenType.equals, line, col);
          state = _LexerState.top;
        } else {
          yield CharToken(TokenType.set, line, col);
          state = _LexerState.top;
          yield* parseRuneFromTop(rune);
        }
        break;
      case _LexerState.exclamationPoint:
        if (rune == 0x3d) {
          yield CharToken(TokenType.notEquals, line, col);
          state = _LexerState.top;
        } else {
          yield CharToken(TokenType.bang, line, col);
          state = _LexerState.top;
          yield* parseRuneFromTop(rune);
        }
        break;
      case _LexerState.comment:
        if (rune == 0xa) {
          line++;
          col = 0;
        }
        if (rune == 0x5c) {
          state = _LexerState.commentBackslash;
        }
        if (rune == 0xa) {
          state = _LexerState.top;
        }
        break;
      case _LexerState.slash:
        if (rune == 0x2f) {
          state = _LexerState.comment;
        } else if (rune == 0x2a) {
          state = _LexerState.multiLineComment;
        } else {
          yield CharToken(TokenType.divide, line, col);
          state = _LexerState.top;
          yield* parseRuneFromTop(rune);
        }
        break;
      case _LexerState.stringDqBackslash:
        if (rune == 0x6e) {
          strVal.write("\n");
        } else if (rune == 0x72) {
          strVal.write("\r");
        } else {
          strVal.writeCharCode(rune);
        }
        state = _LexerState.stringDq;
        break;
      case _LexerState.stringSqBackslash:
        if (rune == 0x6e) {
          strVal.write("\n");
        } else if (rune == 0x72) {
          strVal.write("\r");
        } else {
          strVal.writeCharCode(rune);
        }
        state = _LexerState.stringSq;
        break;
      case _LexerState.multiLineComment:
        if (rune == 0x2a) {
          state = _LexerState.multiLineCommentStar;
        }
        if (rune == 0x5c) {
          state = _LexerState.multiLineCommentBackslash;
        }
        if (rune == 0xa) {
          line++;
          col = 0;
        }
        break;
      case _LexerState.multiLineCommentStar:
        if (rune == 0x2f) {
          state = _LexerState.top;
        } else {
          state = _LexerState.multiLineComment;
        }
        if (rune == 0xa) {
          line++;
          col = 0;
        }
        break;
      case _LexerState.commentBackslash:
        if (rune == 0x40) {
          state = _LexerState.top;
        } else {
          state = _LexerState.comment;
        }
        break;
      case _LexerState.multiLineCommentBackslash:
        if (rune == 0x40) {
          state = _LexerState.top;
        } else {
          state = _LexerState.multiLineComment;
        }
        break;
      case _LexerState.period:
        if (rune == 0x2e) {
          state = _LexerState.periodperiod;
        } else {
          yield CharToken(TokenType.period, line, col);
          state = _LexerState.top;
          yield* parseRuneFromTop(rune);
        }
        break;
      case _LexerState.periodperiod:
        if (rune == 0x2e) {
          yield CharToken(TokenType.ellipsis, line, col);
          state = _LexerState.top;
        } else {
          print("TWO PERIODS $line $col $filename");
          yield CharToken(TokenType.period, line, col);
          yield CharToken(TokenType.period, line, col);
          state = _LexerState.top;
          yield* parseRuneFromTop(rune);
        }
        break;
    }
    col++;
  }
  if (strVal.isNotEmpty) {
    throw FileInvalid("Unterminated string '${strVal.toString()}'");
  }
  if (identVal.isNotEmpty) {
    yield IdentToken(identVal.toString(), line, col);
  }
  if (intVal.isNotEmpty) {
    yield IntToken(int.parse(intVal.toString()), line, col);
  }
  yield CharToken(TokenType.endOfFile, line, col);
}

class FileInvalid implements Exception {
  FileInvalid(this.message);
  final String message;
  String toString() => message;
}

class TokenIterator extends Iterator<Token> {
  TokenIterator(this.tokens, this.file);

  final Iterator<Token> tokens;
  bool doneImports = false;

  final String file;

  @override
  Token get current => doingPrevious ? previous! : tokens.current;
  String get currentIdent {
    if (current is IdentToken) {
      return (current as IdentToken).ident;
    }
    throw FileInvalid(
        "Expected identifier, got $current on line ${current.line} column ${current.col} file $file");
  }

  TokenType get currentChar {
    if (current is! CharToken) {
      throw FileInvalid(
          "Expected character, got $current on line ${current.line} column ${current.col} file $file");
    }
    return (current as CharToken).type;
  }

  int get integer {
    if (current is IntToken) {
      return (current as IntToken).integer;
    }
    throw FileInvalid(
        "Expected integer, got $current on line ${current.line} column ${current.col} file $file");
  }

  String get string {
    if (current is StringToken) {
      return (current as StringToken).str;
    }
    throw FileInvalid(
        "Expected string, got $current on line ${current.line} column ${current.col} file $file");
  }

  Token? previous = null;

  bool movedNext = false;

  @override
  bool moveNext() {
    if (doingPrevious) {
      doingPrevious = false;
      return true;
    }
    if (movedNext) previous = current;
    movedNext = true;
    return tokens.moveNext();
  }

  void expectChar(TokenType char) {
    if (char != currentChar) {
      throw FileInvalid(
          "Expected $char, got $current on line ${current.line} column ${current.col} file $file");
    }
    moveNext();
  }

  bool doingPrevious = false;

  void getPrevious() {
    if (doingPrevious) {
      throw UnimplementedError("saving 2 back");
    }
    doingPrevious = true;
  }
}
