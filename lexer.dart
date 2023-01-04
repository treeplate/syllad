import 'parser-core.dart';

String formatCursorPosition(int line, int col, String workspace, String file) {
  return "$workspace/$file:$line:$col";
}

String formatCursorPositionFromTokens(TokenIterator tokens) {
  return formatCursorPosition(tokens.current.line, tokens.current.col, tokens.workspace, tokens.file);
}

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
  star, // *
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
  starEquals,
  starStar,
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
  star,
  commentHash,
}

Iterable<Token> lex(String file, String workspace, String filename) sync* {
  // /* to (\\ or */) multi-line comment, # or // single-line comments (\\ to end comment)

  _LexerState state = _LexerState.top;
  StringBuffer buffer = StringBuffer();
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
      // 0x24 is $, not a valid character for top-level
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
        state = _LexerState.star;
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
      // 0x3f is ?, not a valid character for top-level
      // 0x40 is @, not a valid character for top-level
      // 0x41 - 0x5a, A-Z, are done later
      case 0x5b:
        yield CharToken(TokenType.openSquare, line, col);
        break;
      case 0x5d:
        yield CharToken(TokenType.closeSquare, line, col);
        break;
      case 0x5e:
        yield CharToken(TokenType.bitXor, line, col);
        break;
      // 0x5f is _, done later
      // 0x60 is `, not a valid character for top-level
      // 0x61 - 0x7a, a-z, are done later
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
          buffer.writeCharCode(rune);
          state = _LexerState.integer;
        } else if ((rune >= 0x61 && rune <= 0x7a) || (rune >= 0x41 && rune <= 0x5a) || rune == 0x5f) {
          buffer.writeCharCode(rune);

          state = _LexerState.identifier;
        } else {
          throw BSCException(
            //print(
            "Unrecognized ${String.fromCharCode(rune)} at ${formatCursorPosition(line, col, workspace, filename)} (U+${rune.toRadixString(16)} in Unicode)",
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
          buffer.writeCharCode(rune);
        } else {
          yield IntToken(int.tryParse(buffer.toString()) ?? (throw BSCException('bad integer: $buffer')), line, col);
          buffer = StringBuffer();
          state = _LexerState.top;
          yield* parseRuneFromTop(rune);
        }
        break;
      case _LexerState.stringDq:
        if (rune == 0x22) {
          yield StringToken(buffer.toString(), line, col);
          buffer = StringBuffer();
          state = _LexerState.top;
        } else if (rune == 0x5c) {
          state = _LexerState.stringDqBackslash;
        } else {
          buffer.writeCharCode(rune);
        }
        break;
      case _LexerState.identifier:
        if ((rune - 0x30 >= 0 && rune - 0x30 <= 9) || (rune >= 0x61 && rune <= 0x7a) || (rune >= 0x41 && rune <= 0x5a) || rune == 0x5f) {
          buffer.writeCharCode(rune);
        } else {
          yield IdentToken(buffer.toString(), line, col);
          buffer = StringBuffer();
          state = _LexerState.top;

          yield* parseRuneFromTop(rune);
        }

        break;
      case _LexerState.stringSq:
        if (rune == 0x27) {
          yield StringToken(buffer.toString(), line, col);
          buffer = StringBuffer();
          state = _LexerState.top;
        } else if (rune == 0x5c) {
          state = _LexerState.stringSqBackslash;
        } else {
          buffer.writeCharCode(rune);
        }
        break;
      case _LexerState.stringSq:
        if (rune == 0x27) {
          yield StringToken(buffer.toString(), line, col);
          buffer = StringBuffer();
          state = _LexerState.top;
        } else if (rune == 0x5c) {
          state = _LexerState.stringSqBackslash;
        } else {
          buffer.writeCharCode(rune);
        }
        break;
      case _LexerState.and:
        if (rune == 0x26) {
          // &
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
          // |
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
          // =
          yield CharToken(TokenType.greaterEqual, line, col);
          state = _LexerState.top;
        } else if (rune == 0x3e) {
          // >
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
          state = _LexerState.top;
        }
        if (rune == 0x5c) {
          state = _LexerState.commentBackslash;
        }
        if (rune == 0x23) {
          state = _LexerState.commentHash;
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
          buffer.write("\n");
        } else if (rune == 0x72) {
          buffer.write("\r");
        } else if (rune == 0x74) {
          buffer.write("\t");
        } else {
          buffer.writeCharCode(rune);
        }
        state = _LexerState.stringDq;
        break;
      case _LexerState.stringSqBackslash:
        if (rune == 0x6e) {
          buffer.write("\n");
        } else if (rune == 0x72) {
          buffer.write("\r");
        } else if (rune == 0x74) {
          buffer.write("\t");
        } else {
          buffer.writeCharCode(rune);
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
          print("TWO PERIODS ${formatCursorPosition(line, col, workspace, filename)}");
          yield CharToken(TokenType.period, line, col);
          yield CharToken(TokenType.period, line, col);
          state = _LexerState.top;
          yield* parseRuneFromTop(rune);
        }
        break;
      case _LexerState.star:
        if (rune == 0x3d) {
          yield CharToken(TokenType.starEquals, line, col);
          state = _LexerState.top;
          break;
        }
        if (rune == 0x2a) {
          yield CharToken(TokenType.starStar, line, col);
          state = _LexerState.top;
          break;
        }
        yield CharToken(TokenType.star, line, col);
        state = _LexerState.top;
        yield* parseRuneFromTop(rune);
        break;
      case _LexerState.commentHash:
        if ((rune - 0x30 >= 0 && rune - 0x30 <= 9) || (rune >= 0x61 && rune <= 0x7a) || (rune >= 0x41 && rune <= 0x5a) || rune == 0x5f) {
          buffer.writeCharCode(rune);
        } else {
          yield CommentFeatureToken(buffer.toString(), line, col);
          buffer = StringBuffer();
          if (rune == 0x23) {
            state = _LexerState.commentHash;
          } else if (rune == 0xa) {
            state = _LexerState.top;
          } else if (rune == 0x5c) {
            state = _LexerState.commentBackslash;
          } else {
            state = _LexerState.comment;
          }
        }
        break;
    }
    col++;
  }
  switch (state) {
    case _LexerState.stringDq:
      throw BSCException("Unterminated double-quoted string '${buffer.toString()}'");
    case _LexerState.stringSq:
      throw BSCException("Unterminated single-quoted string '${buffer.toString()}'");
    case _LexerState.comment:
      break;
    case _LexerState.multiLineComment:
      break; // multi-line comments can be unterminated
    case _LexerState.top:
      break;
    case _LexerState.integer:
      yield IntToken(int.tryParse(buffer.toString()) ?? (throw BSCException('bad integer: $buffer')), line, col);
      break;
    case _LexerState.identifier:
      yield IdentToken(buffer.toString(), line, col);
      break;
    case _LexerState.and:
      yield CharToken(TokenType.bitAnd, line, col);
      break;
    case _LexerState.or:
      yield CharToken(TokenType.bitOr, line, col);
      break;
    case _LexerState.greaterThan:
      yield CharToken(TokenType.greater, line, col);
      break;
    case _LexerState.lessThan:
      yield CharToken(TokenType.less, line, col);
      break;
    case _LexerState.equalTo:
      yield CharToken(TokenType.set, line, col);
      break;
    case _LexerState.period:
      yield CharToken(TokenType.period, line, col);
      break;
    case _LexerState.periodperiod:
      print("TWO PERIODS BEFORE EOF $workspace/$filename");
      yield CharToken(TokenType.period, line, col);
      yield CharToken(TokenType.period, line, col);
      break;
    case _LexerState.exclamationPoint:
      yield CharToken(TokenType.bang, line, col);
      break;
    case _LexerState.commentBackslash:
      break;
    case _LexerState.slash:
      yield CharToken(TokenType.divide, line, col);
      break;
    case _LexerState.stringDqBackslash:
      throw BSCException("Unterminated double-quoted string ending in backslash '${buffer.toString()}'");
    case _LexerState.stringSqBackslash:
      throw BSCException("Unterminated single-quoted string ending in backslash '${buffer.toString()}'");
    case _LexerState.multiLineCommentBackslash:
      break;
    case _LexerState.multiLineCommentStar:
      break;
    case _LexerState.star:
      yield CharToken(TokenType.star, line, col);
      break;
    case _LexerState.commentHash:
      yield CommentFeatureToken(buffer.toString(), line, col);
      break;
  }
  if (buffer.isNotEmpty) {
    throw BSCException("Unterminated string '${buffer.toString()}'");
  }
  if (buffer.isNotEmpty) {
    yield IdentToken(buffer.toString(), line, col);
  }
  yield CharToken(TokenType.endOfFile, line, col);
}

class CommentFeatureToken extends Token {
  CommentFeatureToken(this.feature, int line, int col) : super(line, col);

  final String feature;

  String toString() => "CommentFeatureToken($feature)";
}

abstract class SydException implements Exception {
  SydException(this.message);
  final String message;
  String toString() => message;
  int get exitCode;
}

class AssertException extends SydException {
  AssertException(String message) : super(message);

  int get exitCode => -3;
}

class ThrowException extends SydException {
  ThrowException(String message) : super(message);

  int get exitCode => -4;
}

class BSCException extends SydException {
  // stands for "Bad Source Code"
  BSCException(String message) : super(message);

  int get exitCode => -2;
}

class TokenIterator extends Iterator<Token> {
  TokenIterator(this.tokens, this.workspace, this.file);

  final Iterator<Token> tokens;
  bool doneImports = false;

  final String workspace;
  final String file;

  @override
  Token get current => doingPrevious ? previous! : tokens.current;
  Variable get currentIdent {
    if (current is IdentToken) {
      return variables[(current as IdentToken).ident] ??= Variable((current as IdentToken).ident);
    }
    throw BSCException("Expected identifier, got $current on ${formatCursorPositionFromTokens(this)}");
  }

  TokenType get currentChar {
    if (current is! CharToken) {
      throw BSCException("Expected character, got $current on ${formatCursorPositionFromTokens(this)}");
    }
    return (current as CharToken).type;
  }

  int get integer {
    if (current is IntToken) {
      return (current as IntToken).integer;
    }
    throw BSCException("Expected integer, got $current on ${formatCursorPositionFromTokens(this)}");
  }

  String get string {
    if (current is StringToken) {
      return (current as StringToken).str;
    }
    throw BSCException("Expected string, got $current on ${formatCursorPositionFromTokens(this)}");
  }

  String get commentFeature {
    if (current is CommentFeatureToken) {
      return (current as CommentFeatureToken).feature;
    }
    throw BSCException("Expected comment feature (//#), got $current on ${formatCursorPositionFromTokens(this)}");
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
    if (current is! CharToken || char != currentChar) {
      throw BSCException("Expected $char, got $current on ${formatCursorPositionFromTokens(this)}");
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
