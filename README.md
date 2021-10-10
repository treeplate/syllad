# This is a WIP programming language called Sylladexian.
## Whitespace
Whitespace is ignored by Sylladexian, however it is useful to both make the code look nice and to seperate certain tokens.
## Imports
At the start of a .syd or .run file, you can have any number of `import '<file>.syd';`s.
This lets you use the <file> sylladex in your code.
## Types
A type is either a primitive type (int, string, etc) or a sylladex type
## .syd (Sylladex File)
This defines a type of 'sylladex'.
A sylladex is a data structure used by other files.
Sylladexes can have functions and variables in them (see below in .run for what functions are)
Sylladexes also have some methods (you choose how many arguments):
### Method syntax
The method syntax is:
```syd
<method>([<typeA> <a>, <typeB> <b>, ...]) {
  <statements>
}
```
where <a>, <b>, ... are optional arguments, <typeA>, <typeB>, ... are their types, <method> is the name of the method, and <statements> is basically just a .run file where imports aren't allowed but a return statement global-scope is.
### read
This method returns a value in the sylladex found by using the arguments specified.
### pop
Same as `read`, but it also pops it from the data structure.
### write
Returns nothing. Adds/changes a value in the sylladex.
### Internal data
They also have an internal data structure, which is is a collection of variables (some of which are declared in the constructor call and others are declared in the file) saved between method calls.
## .run (Runnable File)
This is a file you can run.
There are many things you can do:
### Values
- a declared variable (e.g bar, baz, list, etc)
- a raw value (e.g "foo", 42, true, etc)
- a sylladex constructor call (e.g List<int>(3, 2), Map<int, String>(), IntStack(), etc)
- a function call (e.g cat(3), dog(), bunny(a), etc)
- a method call (e.g bob.read(4), bob.write(3, 5, 6), bob.pop(2, 4), etc)
- a combination of values (e.g "{a} feet under the sea", 3+2, b == 10, etc)
### Print
Syntax: `print <a>;` where <a> is a string.
Behavior: prints <a>.
### Variable declarations
Syntax: `<typeA> <a> = <b>;` where <a> is an undeclared variable, <typeA> is the type, and <b> is what you want to set it to.
Behavior: declares <a> of type <typeA> and sets it to <b>
### Function definitions
Functions are private to a file.

Syntax: `<typeA> <a>([<typeB> <b>, <typeC> <c>, ...]) {<statements>}` same as a method, but with a return type at the start.
Behavior: declares a function <a> with arguments <b>, <c>, ... (if present) of types <typeB>, <typeC>, ... and returns a <typeA>
### If Then Else
Syntax: `if (<a>) {<statements>} [else if(<b>) {<s2s>} else if ...] [else {<s3s>}]` where <a>, <b>, .... are booleans (all but <a> are optional) and <statements>, <s2s>, <s3s>, ... are lists of statements (where all but <statements> are optional).
Behavior: If <a>, executes <statements>, otherwise if <b>, execute <s2s> if present, ..., otherwise execute <s3s> if present.
### Statement function/method calls
If a function or method does not return, you can use a function/method call of it as a statement.
### While
Syntax: `while (<a>) {<statements>}` where <a> is a boolean and <statements> is a list of statements.
Behavior: (x) if <a> { executes <statements> goto x }