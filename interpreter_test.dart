import 'dart:async';
import 'dart:convert';
import 'dart:io' hide exitCode;
import 'package:path/path.dart' as path;
import 'package:test/test.dart';
import 'package:syllad/syd-core.dart';
import 'package:syllad/syd-runner.dart';
import 'package:syllad/run_tests.dart';

void main() {
  TestRunner runner = OurInterpreterRunner();
  for (File file in Directory('tests').listSync(recursive: true).whereType<File>().where((File file) => file.path.endsWith('.syd')).toList()
    ..sort((File a, File b) => a.path.compareTo(b.path))) {
    test(
      skip: path.split(file.path).contains('compiler-specific') || path.split(file.path).contains('test-manually'),
      '${file.path}',
      () {
        StringBuffer output = StringBuffer();
        bool testResult = runner.runAndEvaluateTest(
            file,
            output,
          );
        if(output.isNotEmpty) {
          print('testrunner message:\n$output');
        }
        expect(
          testResult,
          isNot(false),
        );
      },
    );
  }
}

class OurInterpreterRunner extends TestRunner {
  String get description => 'interpreter';
  TestResult executeTest(File file) {
    TestOutput errorOutput = TestOutput();
    TestOutput output = TestOutput(errorOutput);
    int exitCode = 0;
    try {
      runFile(file.readAsStringSync(), 'lib/rtl.syd', file.path, false, true, [file.path], output, errorOutput, (e) {
        exitCode = e;
      });
    } on SydException catch (e) {
      errorOutput.writeln(e);
      switch (e.exitCode) {
      case -1:
        return TestResult.compilationFailed('Stderr:\n${prettify(errorOutput.output.toString())}');
      case -2: // general test runtime error
      case -3: // test assert
      case -4: // test throw
        return TestResult.testRan(runtimeError: true, testStdout: output.output.toString(), testStderr: errorOutput.output.toString(), testExitCode: e.exitCode);
        default:
          throw 'Invalid exit code ${e.exitCode}';
      }
    } catch (e, st) {
      output.addError(e, st);
      return TestResult.hostFailed('Stderr:\n${prettify(errorOutput.output.toString())}',);
    }
    return TestResult.testRan(runtimeError: false, testStdout: output.output.toString(), testStderr: errorOutput.output.toString(), testExitCode: exitCode);
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
