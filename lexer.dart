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

  isIdent,
  asIdent,

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
  plusEquals, // +=
  plusPlus, // ++
  minus, // -
  minusEquals, // -=
  minusMinus, // --
  divide, // /
  divideEquals, // /=
  star, // *
  starEquals, // *=
  starStar,
  remainder, // %
  remainderEquals, // %=

  equals, // ==
  notEquals, // !=
  greater, // >
  greaterEqual, // >=
  lessEqual, // <=
  less, // <

  andand, // &&
  andandEquals, // &&=
  oror, // ||
  ororEquals, // ||=

  bitAnd, // &
  bitAndEquals, // &=
  bitOr, // |
  bitOrEquals, // |=
  bitXor, // ^
  bitXorEquals, // ^=
  tilde, // ~
  tildeEquals, // ~=
  leftShift, // <<
  leftShiftEquals, // <<=
  rightShift, // >>
  rightShiftEquals, // >>=

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
  oror,
  andand,
  xor,
  tilde,
  remainder,
  shiftL,
  shiftR,
  greaterThan,
  lessThan,
  equalTo,
  period,
  periodperiod,
  exclamationPoint,
  comment,
  slash,
  plus,
  minus,
  star,
  stringDqBackslash,
  stringSqBackslash,
  multiLineComment,
  multiLineCommentStar,
  commentHash,
}

Iterable<Token> lex(String file, String workspace, String filename) sync* {
  // /* to */ multi-line comment, # or // single-line comments

  _LexerState state = _LexerState.top;
  StringBuffer buffer = StringBuffer();
  int line = 1;
  int col = 1;
  int startline = 1;
  int startcol = 1;
  Iterable<Token> parseRuneFromTop(int rune) sync* {
    switch (rune) {
      case 0xa:
        line++;
        col = 0; // incremented at end of loop
      case 0xd: // carriage return
      case 0x20: // space
        break;
      case 0x21:
        startline = line;
        startcol = col;
        state = _LexerState.exclamationPoint;

      case 0x22:
        startline = line;
        startcol = col;
        state = _LexerState.stringDq;

      case 0x23:
        startline = line;
        startcol = col;
        state = _LexerState.comment;

      // 0x24 is $, not a valid character for top-level
      case 0x25:
        startline = line;
        startcol = col;
        state = _LexerState.remainder;

      case 0x26:
        startline = line;
        startcol = col;
        state = _LexerState.and;

      case 0x27:
        startline = line;
        startcol = col;
        state = _LexerState.stringSq;

      case 0x28:
        yield CharToken(TokenType.openParen, startline, startcol);
        startline = line;
        startcol = col;

      case 0x29:
        yield CharToken(TokenType.closeParen, startline, startcol);
        startline = line;
        startcol = col;

      case 0x2a:
        startline = line;
        startcol = col;
        state = _LexerState.star;

      case 0x2b:
        startline = line;
        startcol = col;
        state = _LexerState.plus;

      case 0x2c:
        yield CharToken(TokenType.comma, startline, startcol);
        startline = line;
        startcol = col;

      case 0x2d:
        startline = line;
        startcol = col;
        state = _LexerState.minus;

      case 0x2e:
        startline = line;
        startcol = col;
        state = _LexerState.period;

      case 0x2f:
        startline = line;
        startcol = col;
        state = _LexerState.slash;

      // 0-9 are done later
      case 0x3a:
        yield CharToken(TokenType.colon, startline, startcol);
        startline = line;
        startcol = col;

      case 0x3b:
        yield CharToken(TokenType.endOfStatement, startline, startcol);
        startline = line;
        startcol = col;

      case 0x3c:
        startline = line;
        startcol = col;
        state = _LexerState.lessThan;

      case 0x3d:
        startline = line;
        startcol = col;
        state = _LexerState.equalTo;

      case 0x3e:
        startline = line;
        startcol = col;
        state = _LexerState.greaterThan;

      // 0x3f is ?, not a valid character for top-level
      // 0x40 is @, not a valid character for top-level
      // 0x41 - 0x5a, A-Z, are done later
      case 0x5b:
        yield CharToken(TokenType.openSquare, startline, startcol);
        startline = line;
        startcol = col;

      case 0x5d:
        yield CharToken(TokenType.closeSquare, startline, startcol);
        startline = line;
        startcol = col;

      case 0x5e:
        startline = line;
        startcol = col;
        state = _LexerState.xor;

      // 0x5f is _, done later
      // 0x60 is `, not a valid character for top-level
      // 0x61 - 0x7a, a-z, are done later
      case 0x7b:
        yield CharToken(TokenType.openBrace, startline, startcol);
        startline = line;
        startcol = col;

      case 0x7c:
        startline = line;
        startcol = col;
        state = _LexerState.or;

      case 0x7d:
        yield CharToken(TokenType.closeBrace, startline, startcol);
        startline = line;
        startcol = col;

      case 0x7e:
        startline = line;
        startcol = col;
        state = _LexerState.tilde;

      default:
        if (rune - 0x30 >= 0 && rune - 0x30 <= 9) {
          buffer.writeCharCode(rune);
          startline = line;
          startcol = col;
          state = _LexerState.integer;
        } else if ((rune >= 0x61 && rune <= 0x7a) || (rune >= 0x41 && rune <= 0x5a) || rune == 0x5f) {
          buffer.writeCharCode(rune);
          startline = line;
          startcol = col;
          state = _LexerState.identifier;
        } else {
          throw BSCException(
            "Unrecognized ${String.fromCharCode(rune)} at ${formatCursorPosition(line, col, workspace, filename)} (U+${rune.toRadixString(16)} in Unicode)",
            NoDataVG(),
          );
        }
    }
  }

  loop: for (int rune in file.runes) {
    switch (state) {
      case _LexerState.top:
        yield* parseRuneFromTop(rune);

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
          yield IntToken(
              int.tryParse(buffer.toString()) ??
                  (throw BSCException(
                    'bad integer: $buffer',
                    NoDataVG(),
                  )),
              line,
              col);
          buffer = StringBuffer();
          startline = line;
          startcol = col;
          state = _LexerState.top;
          yield* parseRuneFromTop(rune);
        }

      case _LexerState.stringDq:
        if (rune == 0x22) {
          yield StringToken(buffer.toString(), startline, startcol);
          startline = line;
          startcol = col;
          buffer = StringBuffer();
          startline = line;
          startcol = col;
          state = _LexerState.top;
        } else if (rune == 0x5c) {
          startline = line;
          startcol = col;
          state = _LexerState.stringDqBackslash;
        } else if (rune == 0xa) {
          line++;
          buffer.writeCharCode(rune);
        } else {
          buffer.writeCharCode(rune);
        }

      case _LexerState.identifier:
        if ((rune - 0x30 >= 0 && rune - 0x30 <= 9) || (rune >= 0x61 && rune <= 0x7a) || (rune >= 0x41 && rune <= 0x5a) || rune == 0x5f) {
          buffer.writeCharCode(rune);
        } else {
          String str = buffer.toString();
          if (str == 'is') {
            yield CharToken(TokenType.isIdent, startline, startcol);
            startline = line;
            startcol = col;
            state = _LexerState.top;
            buffer = StringBuffer();

            yield* parseRuneFromTop(rune);
          } else if (str == 'as') {
            yield CharToken(TokenType.asIdent, startline, startcol);
            startline = line;
            startcol = col;
            state = _LexerState.top;
            buffer = StringBuffer();

            yield* parseRuneFromTop(rune);
          } else {
            yield IdentToken(buffer.toString(), startline, startcol);
            startline = line;
            startcol = col;
            buffer = StringBuffer();
            startline = line;
            startcol = col;
            state = _LexerState.top;

            yield* parseRuneFromTop(rune);
          }
        }

      case _LexerState.stringSq:
        if (rune == 0x27) {
          yield StringToken(buffer.toString(), startline, startcol);
          startline = line;
          startcol = col;
          buffer = StringBuffer();
          startline = line;
          startcol = col;
          state = _LexerState.top;
        } else if (rune == 0x5c) {
          startline = line;
          startcol = col;
          state = _LexerState.stringSqBackslash;
        } else if (rune == 0xa) {
          line++;
          buffer.writeCharCode(rune);
        } else {
          buffer.writeCharCode(rune);
        }

      case _LexerState.and:
        if (rune == 0x26) {
          startline = line;
          startcol = col;
          state = _LexerState.andand;
        } else if (rune == 0x3d) {
          yield CharToken(TokenType.bitAndEquals, startline, startcol);
          startline = line;
          startcol = col;
          startline = line;
          startcol = col;
          state = _LexerState.top;
        } else {
          yield CharToken(TokenType.bitAnd, startline, startcol);
          startline = line;
          startcol = col;
          startline = line;
          startcol = col;
          state = _LexerState.top;

          yield* parseRuneFromTop(rune);
        }

      case _LexerState.or:
        if (rune == 0x7c) {
          startline = line;
          startcol = col;
          state = _LexerState.oror;
        } else if (rune == 0x3d) {
          yield CharToken(TokenType.bitOrEquals, startline, startcol);
          startline = line;
          startcol = col;
          startline = line;
          startcol = col;
          state = _LexerState.top;
        } else {
          yield CharToken(TokenType.bitOr, startline, startcol);
          startline = line;
          startcol = col;
          startline = line;
          startcol = col;
          state = _LexerState.top;
          yield* parseRuneFromTop(rune);
        }

      case _LexerState.greaterThan:
        if (rune == 0x3d) {
          // =
          yield CharToken(TokenType.greaterEqual, startline, startcol);
          startline = line;
          startcol = col;
          startline = line;
          startcol = col;
          state = _LexerState.top;
        } else if (rune == 0x3e) {
          // >
          yield CharToken(TokenType.rightShift, startline, startcol);
          startline = line;
          startcol = col;
          startline = line;
          startcol = col;
          state = _LexerState.top;
        } else {
          yield CharToken(TokenType.greater, startline, startcol);
          startline = line;
          startcol = col;
          startline = line;
          startcol = col;
          state = _LexerState.top;
          yield* parseRuneFromTop(rune);
        }

      case _LexerState.lessThan:
        if (rune == 0x3d) {
          yield CharToken(TokenType.lessEqual, startline, startcol);
          startline = line;
          startcol = col;
          startline = line;
          startcol = col;
          state = _LexerState.top;
        } else if (rune == 0x3c) {
          yield CharToken(TokenType.leftShift, startline, startcol);
          startline = line;
          startcol = col;
          startline = line;
          startcol = col;
          state = _LexerState.top;
        } else {
          yield CharToken(TokenType.less, startline, startcol);
          startline = line;
          startcol = col;
          startline = line;
          startcol = col;
          state = _LexerState.top;
          yield* parseRuneFromTop(rune);
        }

      case _LexerState.equalTo:
        if (rune == 0x3d) {
          yield CharToken(TokenType.equals, startline, startcol);
          startline = line;
          startcol = col;
          startline = line;
          startcol = col;
          state = _LexerState.top;
        } else {
          yield CharToken(TokenType.set, startline, startcol);
          startline = line;
          startcol = col;
          startline = line;
          startcol = col;
          state = _LexerState.top;
          yield* parseRuneFromTop(rune);
        }

      case _LexerState.exclamationPoint:
        if (rune == 0x3d) {
          yield CharToken(TokenType.notEquals, startline, startcol);
          startline = line;
          startcol = col;
          startline = line;
          startcol = col;
          state = _LexerState.top;
        } else {
          yield CharToken(TokenType.bang, startline, startcol);
          startline = line;
          startcol = col;
          startline = line;
          startcol = col;
          state = _LexerState.top;
          yield* parseRuneFromTop(rune);
        }

      case _LexerState.comment:
        if (rune == 0xa) {
          line++;
          col = 1;
          startline = line;
          startcol = col;
          state = _LexerState.top;
          continue loop;
        }
        if (rune == 0x23) {
          startline = line;
          startcol = col;
          state = _LexerState.commentHash;
        }

      case _LexerState.slash:
        if (rune == 0x2f) {
          startline = line;
          startcol = col;
          state = _LexerState.comment;
        } else if (rune == 0x2a) {
          startline = line;
          startcol = col;
          state = _LexerState.multiLineComment;
        } else if (rune == 0x3d) {
          yield CharToken(TokenType.divideEquals, startline, startcol);
          startline = line;
          startcol = col;
          startline = line;
          startcol = col;
          state = _LexerState.top;
        } else {
          yield CharToken(TokenType.divide, startline, startcol);
          startline = line;
          startcol = col;
          startline = line;
          startcol = col;
          state = _LexerState.top;
          yield* parseRuneFromTop(rune);
        }

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
        startline = line;
        startcol = col;
        state = _LexerState.stringDq;

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
        startline = line;
        startcol = col;
        state = _LexerState.stringSq;

      case _LexerState.multiLineComment:
        if (rune == 0x2a) {
          startline = line;
          startcol = col;
          state = _LexerState.multiLineCommentStar;
        }
        if (rune == 0xa) {
          line++;
          col = 1;
          continue loop;
        }

      case _LexerState.multiLineCommentStar:
        if (rune == 0x2f) {
          startline = line;
          startcol = col;
          state = _LexerState.top;
        } else if (rune != 0x2a) {
          startline = line;
          startcol = col;
          state = _LexerState.multiLineComment;
        }
        if (rune == 0xa) {
          line++;
          col = 1;
          continue loop;
        }

      case _LexerState.period:
        if (rune == 0x2e) {
          startline = line;
          startcol = col;
          state = _LexerState.periodperiod;
        } else {
          yield CharToken(TokenType.period, startline, startcol);
          startline = line;
          startcol = col;
          startline = line;
          startcol = col;
          state = _LexerState.top;
          yield* parseRuneFromTop(rune);
        }

      case _LexerState.periodperiod:
        if (rune == 0x2e) {
          yield CharToken(TokenType.ellipsis, startline, startcol);
          startline = line;
          startcol = col;
          startline = line;
          startcol = col;
          state = _LexerState.top;
        } else {
          print("TWO PERIODS ${formatCursorPosition(line, col, workspace, filename)}");
          yield CharToken(TokenType.period, startline, startcol);
          startline = line;
          startcol = col;
          yield CharToken(TokenType.period, startline, startcol);
          startline = line;
          startcol = col;
          startline = line;
          startcol = col;
          state = _LexerState.top;
          yield* parseRuneFromTop(rune);
        }

      case _LexerState.star:
        if (rune == 0x3d) {
          yield CharToken(TokenType.starEquals, startline, startcol);
          startline = line;
          startcol = col;
          startline = line;
          startcol = col;
          state = _LexerState.top;
          break;
        }
        if (rune == 0x2a) {
          yield CharToken(TokenType.starStar, startline, startcol);
          startline = line;
          startcol = col;
          startline = line;
          startcol = col;
          state = _LexerState.top;
          break;
        }
        yield CharToken(TokenType.star, startline, startcol);
        startline = line;
        startcol = col;
        startline = line;
        startcol = col;
        state = _LexerState.top;
        yield* parseRuneFromTop(rune);

      case _LexerState.commentHash:
        if ((rune - 0x30 >= 0 && rune - 0x30 <= 9) || (rune >= 0x61 && rune <= 0x7a) || (rune >= 0x41 && rune <= 0x5a) || rune == 0x5f) {
          buffer.writeCharCode(rune);
        } else {
          yield CommentFeatureToken(buffer.toString(), startline, startcol);
          startline = line;
          startcol = col;
          buffer = StringBuffer();
          if (rune == 0x23) {
            startline = line;
            startcol = col;
            state = _LexerState.commentHash;
          } else if (rune == 0xa) {
            startline = line;
            startcol = col;
            state = _LexerState.top;
          } else {
            startline = line;
            startcol = col;
            state = _LexerState.comment;
          }
        }

      case _LexerState.plus:
        if (rune == 0x3d) {
          yield CharToken(TokenType.plusEquals, startline, startcol);
          startline = line;
          startcol = col;
          startline = line;
          startcol = col;
          state = _LexerState.top;
        } else if (rune == 0x2b) {
          yield CharToken(TokenType.plusPlus, startline, startcol);
          startline = line;
          startcol = col;
          startline = line;
          startcol = col;
          state = _LexerState.top;
        } else {
          yield CharToken(TokenType.plus, startline, startcol);
          startline = line;
          startcol = col;
          startline = line;
          startcol = col;
          state = _LexerState.top;
          yield* parseRuneFromTop(rune);
        }
      case _LexerState.minus:
        if (rune == 0x3d) {
          yield CharToken(TokenType.minusEquals, startline, startcol);
          startline = line;
          startcol = col;
          startline = line;
          startcol = col;
          state = _LexerState.top;
        } else if (rune == 0x2d) {
          yield CharToken(TokenType.minusMinus, startline, startcol);
          startline = line;
          startcol = col;
          startline = line;
          startcol = col;
          state = _LexerState.top;
        } else {
          yield CharToken(TokenType.minus, startline, startcol);
          startline = line;
          startcol = col;
          startline = line;
          startcol = col;
          state = _LexerState.top;
          yield* parseRuneFromTop(rune);
        }
      case _LexerState.oror:
        if (rune == 0x3d) {
          yield CharToken(TokenType.ororEquals, startline, startcol);
          startline = line;
          startcol = col;
          startline = line;
          startcol = col;
          state = _LexerState.top;
        } else {
          yield CharToken(TokenType.oror, startline, startcol);
          startline = line;
          startcol = col;
          startline = line;
          startcol = col;
          state = _LexerState.top;
          yield* parseRuneFromTop(rune);
        }
      case _LexerState.andand:
        if (rune == 0x3d) {
          yield CharToken(TokenType.andandEquals, startline, startcol);
          startline = line;
          startcol = col;
          startline = line;
          startcol = col;
          state = _LexerState.top;
        } else {
          yield CharToken(TokenType.andand, startline, startcol);
          startline = line;
          startcol = col;
          startline = line;
          startcol = col;
          state = _LexerState.top;
          yield* parseRuneFromTop(rune);
        }
      case _LexerState.xor:
        if (rune == 0x3d) {
          yield CharToken(TokenType.bitXorEquals, startline, startcol);
          startline = line;
          startcol = col;
          startline = line;
          startcol = col;
          state = _LexerState.top;
        } else {
          yield CharToken(TokenType.bitXor, startline, startcol);
          startline = line;
          startcol = col;
          startline = line;
          startcol = col;
          state = _LexerState.top;
          yield* parseRuneFromTop(rune);
        }
      case _LexerState.tilde:
        if (rune == 0x3d) {
          yield CharToken(TokenType.tildeEquals, startline, startcol);
          startline = line;
          startcol = col;
          startline = line;
          startcol = col;
          state = _LexerState.top;
        } else {
          yield CharToken(TokenType.tilde, startline, startcol);
          startline = line;
          startcol = col;
          startline = line;
          startcol = col;
          state = _LexerState.top;
          yield* parseRuneFromTop(rune);
        }
      case _LexerState.remainder:
        if (rune == 0x3d) {
          yield CharToken(TokenType.remainderEquals, startline, startcol);
          startline = line;
          startcol = col;
          startline = line;
          startcol = col;
          state = _LexerState.top;
        } else {
          yield CharToken(TokenType.remainder, startline, startcol);
          startline = line;
          startcol = col;
          startline = line;
          startcol = col;
          state = _LexerState.top;
          yield* parseRuneFromTop(rune);
        }
      case _LexerState.shiftL:
        if (rune == 0x3d) {
          yield CharToken(TokenType.leftShiftEquals, startline, startcol);
          startline = line;
          startcol = col;
          startline = line;
          startcol = col;
          state = _LexerState.top;
        } else {
          yield CharToken(TokenType.leftShift, startline, startcol);
          startline = line;
          startcol = col;
          startline = line;
          startcol = col;
          state = _LexerState.top;
          yield* parseRuneFromTop(rune);
        }
      case _LexerState.shiftR:
        if (rune == 0x3d) {
          yield CharToken(TokenType.rightShiftEquals, startline, startcol);
          startline = line;
          startcol = col;
          startline = line;
          startcol = col;
          state = _LexerState.top;
        } else {
          yield CharToken(TokenType.rightShift, startline, startcol);
          startline = line;
          startcol = col;
          startline = line;
          startcol = col;
          state = _LexerState.top;
          yield* parseRuneFromTop(rune);
        }
    }
    col++;
  }
  switch (state) {
    case _LexerState.stringDq:
      throw BSCException("Unterminated double-quoted string '${buffer.toString()}'", NoDataVG());
    case _LexerState.stringSq:
      throw BSCException("Unterminated single-quoted string '${buffer.toString()}'", NoDataVG());
    case _LexerState.comment:
    case _LexerState.multiLineComment:
    // multi-line comments can be unterminated
    case _LexerState.top:
      break;
    case _LexerState.integer:
      yield IntToken(
        int.tryParse(buffer.toString()) ?? (throw BSCException('bad integer: $buffer', NoDataVG())),
        line,
        col,
      );

    case _LexerState.identifier:
      yield IdentToken(buffer.toString(), startline, startcol);
      startline = line;
      startcol = col;

    case _LexerState.and:
      yield CharToken(TokenType.bitAnd, startline, startcol);
      startline = line;
      startcol = col;

    case _LexerState.or:
      yield CharToken(TokenType.bitOr, startline, startcol);
      startline = line;
      startcol = col;

    case _LexerState.greaterThan:
      yield CharToken(TokenType.greater, startline, startcol);
      startline = line;
      startcol = col;

    case _LexerState.lessThan:
      yield CharToken(TokenType.less, startline, startcol);
      startline = line;
      startcol = col;

    case _LexerState.equalTo:
      yield CharToken(TokenType.set, startline, startcol);
      startline = line;
      startcol = col;

    case _LexerState.period:
      yield CharToken(TokenType.period, startline, startcol);
      startline = line;
      startcol = col;

    case _LexerState.periodperiod:
      print("TWO PERIODS BEFORE EOF $workspace/$filename");
      yield CharToken(TokenType.period, startline, startcol);
      startline = line;
      startcol = col;
      yield CharToken(TokenType.period, startline, startcol);
      startline = line;
      startcol = col;

    case _LexerState.exclamationPoint:
      yield CharToken(TokenType.bang, startline, startcol);
      startline = line;
      startcol = col;

    case _LexerState.slash:
      yield CharToken(TokenType.divide, startline, startcol);
      startline = line;
      startcol = col;

    case _LexerState.stringDqBackslash:
      throw BSCException("Unterminated double-quoted string ending in backslash '${buffer.toString()}'", NoDataVG());
    case _LexerState.stringSqBackslash:
      throw BSCException("Unterminated single-quoted string ending in backslash '${buffer.toString()}'", NoDataVG());
    case _LexerState.multiLineCommentStar:
      break;
    case _LexerState.star:
      yield CharToken(TokenType.star, startline, startcol);
      startline = line;
      startcol = col;

    case _LexerState.commentHash:
      yield CommentFeatureToken(buffer.toString(), startline, startcol);
      startline = line;
      startcol = col;

    case _LexerState.plus:
      yield CharToken(TokenType.plus, startline, startcol);
      startline = line;
      startcol = col;

    case _LexerState.minus:
      yield CharToken(TokenType.minus, startline, startcol);
      startline = line;
      startcol = col;

    case _LexerState.oror:
      yield CharToken(TokenType.oror, startline, startcol);
      startline = line;
      startcol = col;
    case _LexerState.andand:
      yield CharToken(TokenType.andand, startline, startcol);
      startline = line;
      startcol = col;
    case _LexerState.xor:
      yield CharToken(TokenType.bitXor, startline, startcol);
      startline = line;
      startcol = col;
    case _LexerState.tilde:
      yield CharToken(TokenType.tilde, startline, startcol);
      startline = line;
      startcol = col;
    case _LexerState.remainder:
      yield CharToken(TokenType.remainder, startline, startcol);
      startline = line;
      startcol = col;
    case _LexerState.shiftL:
      yield CharToken(TokenType.leftShift, startline, startcol);
      startline = line;
      startcol = col;
    case _LexerState.shiftR:
      yield CharToken(TokenType.rightShift, startline, startcol);
      startline = line;
      startcol = col;
  }
  if (buffer.isNotEmpty) {
    throw BSCException("Unterminated string '${buffer.toString()}'", NoDataVG());
  }
  if (buffer.isNotEmpty) {
    yield IdentToken(buffer.toString(), startline, startcol);
    startline = line;
    startcol = col;
  }
  yield CharToken(TokenType.endOfFile, startline, startcol);
  startline = line;
  startcol = col;
}

class CommentFeatureToken extends Token {
  CommentFeatureToken(this.feature, int line, int col) : super(line, col);

  final String feature;

  String toString() => "CommentFeatureToken($feature)";
}

class TokenIterator implements Iterator<Token> {
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
    throw BSCException("Expected identifier, got $current on ${formatCursorPositionFromTokens(this)}", NoDataVG());
  }

  TokenType get currentChar {
    if (current is! CharToken) {
      throw BSCException("Expected character, got $current on ${formatCursorPositionFromTokens(this)}", NoDataVG());
    }
    return (current as CharToken).type;
  }

  int get integer {
    if (current is IntToken) {
      return (current as IntToken).integer;
    }
    throw BSCException("Expected integer, got $current on ${formatCursorPositionFromTokens(this)}", NoDataVG());
  }

  String get string {
    if (current is StringToken) {
      return (current as StringToken).str;
    }
    throw BSCException("Expected string, got $current on ${formatCursorPositionFromTokens(this)}", NoDataVG());
  }

  String get commentFeature {
    if (current is CommentFeatureToken) {
      return (current as CommentFeatureToken).feature;
    }
    throw BSCException("Expected comment feature (//#), got $current on ${formatCursorPositionFromTokens(this)}", NoDataVG());
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
      throw BSCException("Expected $char, got $current on ${formatCursorPositionFromTokens(this)}", NoDataVG());
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
