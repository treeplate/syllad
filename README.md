<!-- This file is out of date (e.g., there's more tokens, integer parsing is different)-->
# SYLLAD
Whitespace is purely cosmetic, except for separating identifiers and/or integers.
```
<import>*
<statement>*
```
## TOKENS
### STRINGS
Strings start with `"` or `'` (the 'quote character'), {set *buffer* to empty} then one of:
- the quote character, which ends the string. {The resulting string has content *buffer*}
- `\`, then a character {append a newline to *buffer* if the character is `n`, otherwise append the character to *buffer*}. This character will not end the string if it is the quote character, and not escape the character after if it's `\`.
- any other character. {append it to *buffer*}
### INTEGERS
Integers start with one of `0123456789` {set *buffer* to that character} and then any number of:
`0123456789xabcdefXABCDEF` {add each character tokenized to *buffer*, the resulting integer has content of the result of calling dart's int.tryParse method with *buffer* as the only argument, if it returns null it is an invalid integer}.
### IDENTIFIERS
Identifiers start with one character out of `a`-`z`, `A`-`Z`, `_` {set *buffer* to that character}, then any number of those characters or any of `0123456789` {add each character tokenized to *buffer*, the resulting identifier has content *buffer*}
### OTHER STUFF
  semicolon, `;`
  EOF

  openParen, `(`
  closeParen, `)`
  openSquare, `[`
  closeSquare, `]`
  openBrace, `{`
  closeBrace, `}`

  comma, `,`
  period, `.`
  ellipsis, `...`
  bang, `!`

  plus, `+`
  minus, `-`
  divide, `/`
  multiply, `*`
  remainder, `%`

  equals, `==`
  notEquals, `!=`
  greater, `>`
  greaterEqual, `>=`
  lessEqual, `<=`
  less, `<`

  andand, `&&`
  oror, `||`

  bitAnd, `&`
  bitOr, `|`
  bitXor, `^`
  tilde, `~`
  leftShift, `<<`
  rightShift, `>>`

  set, `=`
## IMPORTS
Imports consist of the IDENTIFIER `import`, followed by a STRING {*path*}, followed by SEMICOLON.
{This runs the file *path* and adds the resulting variables to the current file scope, as well as *path*'s own file scope if *path* hasn't been}
