import 'dart:convert';
import 'dart:io' as io;
import 'dart:typed_data';
import 'package:characters/characters.dart';

String $arg0 = 'transpiler-output.dart';

Null append<T>(List<T> list, T element) {
  list.add(element);
}

bool containsString(String lhs, String rhs) {
  return lhs.contains(rhs);
}


String substring(String lhs, int start, int end) {
  return lhs.substring(start, end);
}

T pop<T>(List<T> list) {
  return list.removeLast();
}

String stackTrace() {
  return 'stack trace not implemented';
}

String concat(List<Object?> elements) {
  return elements.join('');
}

List<T> copy<T>(Iterable<T> list) {
  return list.toList();
}

List<String> split(String arg, String pattern) {
  if (arg == '') {
    return [''];
  }
  return arg.split(pattern);
}

Null stderr(List<Object?> output) {
  io.stderr.writeAll(output, ' ');
  io.stderr.writeln('');
}

Null print(List<Object?> output) {
  io.stdout.writeAll(output, ' ');
}

Null println(List<Object?> output) {
  io.stdout.writeAll(output, ' ');
  io.stdout.writeln('');
}

class File {
  final io.RandomAccessFile file;
  final bool appendMode;
  bool used = false;

  File(this.file, this.appendMode);
}

int fileModeRead = 0;
int fileModeWrite = 1;
int fileModeAppend = 2;

File openFile(String filename, int fileMode) {
  io.File file = io.File(filename);
  io.FileMode mode = switch (fileMode) {
    0 => io.FileMode.read,
    1 => io.FileMode.writeOnly,
    2 => io.FileMode.writeOnlyAppend,
    int x => throw FormatException(
        'openFile mode $x is not a valid mode\n',
      ),
  };
  return File(file.openSync(mode: mode), mode == io.FileMode.writeOnlyAppend);
}

Uint8List readFileBytes(File file) {
  int length = file.file.lengthSync();
  if (file.used) {
    throw StateError('${file.file.path} was read twice');
  }
  file.used = true;
  return file.file.readSync(length);
}

Null writeFileBytes(File file, List<int> bytes) {
  if (file.used && !file.appendMode) {
    throw StateError('${file.file.path} was written to twice');
  }
  file.file.writeFrom(bytes);
  file.used = true;
}

bool fileExists(String file) {
  return io.File(file).existsSync();
}

Iterable<int> scalarValues(String str) {
  return str.runes;
}

Never exit(int exitCode) {
  io.exit(exitCode);
}

int len(Iterable<Object?> list) {
  return list.length;
}

String utf8Decode(List<int> bytes) {
  return utf8.decode(bytes);
}

Uint8List utf8Encode(String string) {
  return utf8.encode(string);
}

Iterator<T> iterator<T>(Iterable<T> iterable) {
  return iterable.iterator;
}

bool next(Iterator iterator) {
  return iterator.moveNext();
}

T current<T>(Iterator<T> iterator) {
  return iterator.current;
}

StringBuffer createStringBuffer() {
  return StringBuffer();
}

Null writeStringBuffer(StringBuffer buf, String value) {
  buf.write(value);
}

String readStringBuffer(StringBuffer buf) {
  return buf.toString();
}

Iterable<String> charsOf(String str) {
  return str.characters;
}

List<T> filledList<T>(int length, T element) {
  return List.filled(length, element, growable: true);
}

String chr(int codepoint) {
  return String.fromCharCode(codepoint);
}

String hex(int num) {
  return num.toRadixString(16);
}