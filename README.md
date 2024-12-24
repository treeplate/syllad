# Syllad (programming language)
## Tokens
### Whitespace
Whitespace is ignored, except for separating identifiers/integers.
### Strings
Strings are backslash-escaped can be double-quoted or single quoted.
The special escapes are as follows:
- `\0` is a null byte
- `\n` is a newline
- `\t` is a tab
- `\r` is a carriage return
### Integers
Integers start with one of `0123456789` and then any number of `0123456789xabcdefXABCDEF`. If the resulting string is `9223372036854775808`, the result is 0x8000000000000000, otherwise, it's the same as Dart's `int.parse` (if that throws an exception, then it's an invalid program)
<!-- TODO: redefine to not rely on other language -->
### Identifiers
Identifiers start with one character out of `a`-`z`, `A`-`Z`, `_`, then any number of those characters or any of `0123456789`.
"is" and "as" are *keywords*, and do not count as identifiers.
### Comments
Comments are `//` for single-line comments, and `/*` ... `*/` for multi-line comments. Text after a //# (to the next whitespace) is a *comment feature*, as discussed later.
### Other characters
`;`, `(`, `)`, `[`, `]`, `{`, `}`, `,`, `.`, `...`, `!`, `+`, `+=`, `++`, `-`, `-=`, `--`, `/`, `/=`, `*`, `*=`, `**`, `,`, `%`, `%=`, `==`, `!=`, `>`, `>=`, `<=`, `<`, `&&`, `&&=`, `||`, `||=`, `&`, `&=`, `|`, `|=`, `^`, `^=`, `~`, `~=`, `<<`, `<<=`, `>>`, `>>=`, `=`, `:`

## Program structure
A program is a list of *imports*, followed by a list of *statements*.
### Imports
Imports consist of the identifier `import`, followed by a string (the path to the imported file), followed by a semicolon. This runs the file in a new scope (if not already ran), and imports everything declared there in global scope.
### Statements
There are two types of statements: semicolon statements and block statements. Semicolon statements end with a `;`; whereas block statements end with a `{`, optionally some statements, and a `}`.
### Semicolon statements
In the following, [square brackets] mean optional parts of the statement.
- Assignment statement: *variable*`=`*expression*`;`
- Variable declaration statement: *type* *identifier* [`=` *expression*]`;` 
- Expression statement: *expression*`;`
- more
<!-- TODO: finish this -->
## Valid compiler extensions
A implementation of Syllad is valid if:
- it passes all the tests. If this specification contradicts one of the tests, please report it at https://github.com/treeplate/syllad/issues.
- it produces the same output regardless of comments (with the exception of comment features)