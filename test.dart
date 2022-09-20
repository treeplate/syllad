class F {}

void main() {
  var foo = [(String a) {}, (int b) {}];
  print(foo.runtimeType);
  var bar = [() => 'a', () => 1];
  print(bar.runtimeType);
}
