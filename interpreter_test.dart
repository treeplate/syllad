import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:test/test.dart';
import 'package:syllad/syd-core.dart';
import 'package:syllad/syd-runner.dart';
import 'package:syllad/run_tests.dart';

void main() {
  for (File file in Directory('tests').listSync(recursive: true).whereType<File>().where((File file) => file.path.endsWith('.syd')).toList()
    ..sort((File a, File b) => a.path.compareTo(b.path))) {
    if(file.path.contains('compiler-specific')) {
      continue;
    }
    test(
      '${file.path}',
      () {
        expect(
          runTest(file, (File file) {
            TestOutput errorOutput = TestOutput();
            TestOutput output = TestOutput(errorOutput);
            int exitCode = 0;
            try {
              runFile(file.readAsStringSync(), 'lib/rtl.syd', '.', file.path, false, true, [file.path], output, errorOutput, (e) {
                exitCode = e;
              });
            } on SydException catch (e) {
              errorOutput.writeln(e);
              ResultCode resultCode;
              switch (e.exitCode) {
                case -1:
                case -2:
                  resultCode = ResultCode.testSourceError; // test itself was found to have an error and could not be run
                case -3:
                case -4:
                  resultCode = ResultCode.testFailed; // test reported an error (threw or asserted)
                default:
                  throw 'Invalid exit code ${e.exitCode}';
              }
              return TestResult(output.output.toString(), errorOutput.output.toString(), e.exitCode, interpretation: resultCode);
            } catch (e,st) {
              stderr.writeln(e);
              stderr.writeln(st);
              output.addError(e,st);
              return TestResult(output.output.toString(), errorOutput.output.toString(), e.hashCode, interpretation: ResultCode.executerError);
            }
            return TestResult(output.output.toString(), errorOutput.output.toString(), exitCode, interpretation: ResultCode.unknown);
          }),
          isNot(false),
        );
      },
    );
  }
}

class TestOutput implements IOSink {
  late final IOSink stderr;

  StringBuffer output = StringBuffer();

  @override
  Encoding encoding = utf8;

  TestOutput([IOSink? stderr]) {
    this.stderr = stderr ?? this;
  }

  @override
  void add(List<int> data) {
    output.write(encoding.decode(data));
  }

  @override
  void addError(Object error, [StackTrace? stackTrace]) {
    stderr.writeln(error);
    stderr.writeln(stackTrace);
  }

  @override
  Future addStream(Stream<List<int>> stream) {
    return stream.reduce((a, b) => a.followedBy(b).toList()).then((value) => write(value));
  }

  @override
  Future close() {
    return done;
  }

  @override
  Future get done => Completer().future;

  @override
  Future flush() {
    return Future.value();
  }

  @override
  void write(Object? object) {
    output.write(object);
  }

  @override
  void writeAll(Iterable objects, [String separator = ""]) {
    output.writeAll(objects, separator);
  }

  @override
  void writeCharCode(int charCode) {
    output.writeCharCode(charCode);
  }

  @override
  void writeln([Object? object = ""]) {
    output.writeln(object);
  }
}
