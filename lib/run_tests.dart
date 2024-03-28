// make sure to turn off timetravel mode in [build.bat] before running this
// also make sure that ../compiler/compiler.exe is the compiler you want to test

import 'dart:io' hide exitCode;
import 'package:path/path.dart' as path;

void main() {
  Stopwatch stopwatch = Stopwatch()..start();
  final TestRunner interpreter = InterpreterRunner();
  final TestRunner compiler = CompilerRunner();
  final List<File> files = Directory('tests')
    .listSync(recursive: true)
    .whereType<File>()
    .where((File file) => file.path.endsWith('.syd') && !path.split(file.path).contains('test-manually'))
    .toList()
    ..sort((File a, File b) => a.path.compareTo(b.path));
  int failedCount = interpreter.runTestSuite(files) + compiler.runTestSuite(files);
  print('Total time: ${stopwatch.elapsed}');
  if (failedCount > 0) {
    exit(1);
  }
}

abstract class TestRunner {
  String get description;

  bool shouldSkipTest(File file) => false;

  TestResult executeTest(File file);

  int runTestSuite(List<File> tests) {
    int skippedCount = 0;
    int failedCount = 0;
    int passedCount = 0;
    int newPasses = 0;
    int newFailures = 0;
    int remaining = tests.length;
    print('Running ${tests.length} tests for $description...');
    for (File file in tests) {
      print(
        '$passedCount passed ($newPasses new), $failedCount failed ($newFailures new), $skippedCount skipped; testing ${path.basename(file.path)} ($remaining remaining)',
      );
      final StringBuffer message = StringBuffer();
      if (shouldSkipTest(file)) {
        skippedCount += 1;
      } else {
        bool result = runAndEvaluateTest(file, message);
        if (result) {
          assert(message.isEmpty);
          passedCount += 1;
          if (path.split(file.path).contains('not yet passing in $description') || path.split(file.path).contains('not yet passing anywhere')) {
            newPasses += 1;
            print('NEW PASS: ${file.path}');
          }
        } else {
          assert(message.isNotEmpty);
          failedCount += 1;
          if (!path.split(file.path).contains('not yet passing in $description') && !path.split(file.path).contains('not yet passing anywhere')) {
            newFailures += 1;
            print('');
            print('NEW FAILURE: ./${file.path}');
            print(message.toString().trimRight());
            print('');
          } else {
            print('EXPECTED FAILURE: ${file.path}');
          }
        }
      }
      remaining -= 1;
    }
    print('\nResults for $description:');
    print('  ${tests.length} tests; $skippedCount skipped');
    print('  $failedCount errors (+$newFailures new)');
    print('  $passedCount passed (+$newPasses new)');
    print('');
    return failedCount;
  }

  // returns whether the test succeeded or not
  // message contains any diagnostics to print when returning false
  // message must be non-empty when returning false
  // message must be empty when returning true
  bool runAndEvaluateTest(File file, StringBuffer message) {
    // PARSE TEST TO FIND EXPECTATIONS
    List<String> lines = file.readAsLinesSync();
    int? expectExitCode;
    final List<String> expectOutput = <String>[];
    bool expectedOutputIsExact = true;
    final List<String> unexpectOutput = <String>[];
    final List<String> expectStderr = <String>[];
    bool expectedStderrIsExact = true;
    final List<String> unexpectStderr = <String>[];
    bool expectCompileTimeError = false;
    bool expectRuntimeError = false;
    bool sawExpectation = false;
    for (String line in lines) {
      const String expectedOutput = '// expected output: ';
      const String expectNoNewlineAtEndOfOutput = '// expect no newline at end of output';
      const String expectedOutputMayContainOtherText = '// expected output may contain other text';
      const String unexpectedOutput = '// unexpected output: ';
      const String expectedStderr = '// expected stderr: ';
      const String expectNoNewlineAtEndOfStderr = '// expect no newline at end of stderr';
      const String expectedStderrMayContainOtherText = '// expected stderr may contain other text';
      const String unexpectedStderr = '// unexpected stderr: ';
      const String expectedCompileTimeError = '// expected compile-time error: '; // exact remainder of line is informative not prescriptive
      const String expectedRuntimeError = '// expected runtime error: '; // exact remainder of line is informative not prescriptive
      const String expectedExitCode = '// expected exit code is ';
      if (line.startsWith(expectedOutput)) {
        expectOutput.add('${line.substring(expectedOutput.length)}\n');
        sawExpectation = true;
      } else if (line == expectNoNewlineAtEndOfOutput) {
        if (expectOutput.isEmpty) {
          message.writeln('"$line" specified before specifying "$expectedOutput"');
          return false;
        }
        if (!expectOutput.last.endsWith('\n')) {
          message.writeln('"$line" specified multiple times');
          return false;
        }
        expectOutput.last = expectOutput.last.substring(0, expectOutput.last.length - 1);
      } else if (line == expectedOutputMayContainOtherText) {
        if (expectOutput.isEmpty) {
          message.writeln('"$line" specified before specifying "$expectedOutput"');
          return false;
        }
        if (!expectedOutputIsExact) {
          message.writeln('"$line" specified multiple times');
          return false;
        }
        expectedOutputIsExact = false;
      } else if (line.startsWith(unexpectedOutput)) {
        unexpectOutput.add('${line.substring(unexpectedOutput.length)}\n');
        sawExpectation = true;
      } else if (line.startsWith(expectedStderr)) {
        expectStderr.add('${line.substring(expectedStderr.length)}\n');
        sawExpectation = true;
      } else if (line == expectNoNewlineAtEndOfStderr) {
        if (expectStderr.isEmpty) {
          message.writeln('"$line" specified before specifying "$expectedStderr"');
          return false;
        }
        if (!expectStderr.last.endsWith('\n')) {
          message.writeln('"$line" specified multiple times');
          return false;
        }
        expectStderr.last = expectStderr.last.substring(0, expectStderr.last.length - 1);
      } else if (line == expectedStderrMayContainOtherText) {
        if (expectStderr.isEmpty) {
          message.writeln('"$line" specified before specifying "$expectedStderr"');
          return false;
        }
        if (!expectedStderrIsExact) {
          message.writeln('"$line" specified multiple times');
          return false;
        }
        expectedStderrIsExact = false;
      } else if (line.startsWith(unexpectedStderr)) {
        unexpectStderr.add('${line.substring(unexpectedStderr.length)}\n');
        sawExpectation = true;
      } else if (line.startsWith(expectedCompileTimeError)) {
        expectCompileTimeError = true; // means we want host stderr to not be empty, this has to be checked by the host runner
        sawExpectation = true;
      } else if (line.startsWith(expectedRuntimeError)) {
        expectRuntimeError = true; // we want test to throw or assert
        sawExpectation = true;
      } else if (line.startsWith(expectedExitCode)) {
        expectExitCode = int.parse(line.substring(expectedExitCode.length));
        sawExpectation = true;
      } else if (line.startsWith('//')) {
        message.writeln('Unrecognized test expectation comment at top of file: $line');
        return false;
      } else if (line.isEmpty) {
        break;
      }
    }
    if (!sawExpectation) {
      message.writeln('File has no specified expectations.');
      return false;
    }
    if (expectCompileTimeError) {
      if (expectOutput.isNotEmpty || unexpectOutput.isNotEmpty || expectStderr.isNotEmpty || unexpectStderr.isNotEmpty) {
        message.writeln('Test cannot expect both a compiler-time error and care about the test output.');
        return false;
      }
      if (expectExitCode != null) {
        message.writeln('Test cannot expect both a compiler-time error and care about the test exit code.');
        return false;
      }
    }
    if (expectRuntimeError) {
      if (expectCompileTimeError) {
        message.writeln('Test cannot expect both a compile-time error and a runtime error.');
        return false;
      }
      if (expectExitCode != null) {
        message.writeln('Test cannot expect both a runtime error and care about the test exit code.');
        return false;
      }
    }

    // RUN TEST
    final TestResult result = executeTest(file);

    // VERIFY EXPECTATIONS
    switch (result.result) {
      case ResultCode.hostFailed:
        message.writeln('Host failure.');
        message.writeln(result.hostOutput);
        return false;
      case ResultCode.testCompileTimeError:
        if (expectCompileTimeError) {
          return true;
        }
        message.writeln('Unexpected compile-time error.');
        message.writeln(result.hostOutput);
        return false;
      case ResultCode.testRuntimeError:
        if (expectRuntimeError) {
          assert(result.testExitCode != 0, 'contract violation');
          assert(expectExitCode == null, 'invariant violation');
          expectExitCode = result.testExitCode;
          continue testRan;
        }
        if (expectCompileTimeError) {
          message.writeln('Compile time error manifested at runtime instead of compile time.');
          result.describeInto(message);
          return false;
        }
        message.writeln('Unexpected runtime error.');
        result.describeInto(message);
        return false;
      testRan:
      case ResultCode.testRan:
        // Process output to make \r look like actual console output.
        final String actualOutput = result.testStdout.split('\n').map((String line) {
          List<String> sublines = line.split('\r');
          String result = '';
          for (String subline in sublines) {
            if (result.length < subline.length) {
              result = subline;
            } else {
              result = result.replaceRange(0, subline.length, subline);
            }
          }
          return result;
        }).join('\n');
        final String actualStderr = result.testStderr;
        bool failed = false;
        if (expectCompileTimeError) {
          message.writeln('Expected compile-time error did not occur.');
          failed = true;
        }
        if (expectRuntimeError && result.result != ResultCode.testRuntimeError) {
          message.writeln('Expected runtime error did not occur.');
          failed = true;
        }
        if (!_checkOutputExpectation(actualOutput, expectOutput.join(''), expectedOutputIsExact, 'stdout', message)) {
          failed = true;
        }
        if (!_checkOutputUnexpectation(actualOutput, unexpectOutput, 'stdout', message)) {
          failed = true;
        }
        if (!_checkOutputExpectation(actualStderr, expectStderr.join(''), expectedStderrIsExact, 'stderr', message)) {
          failed = true;
        }
        if (!_checkOutputUnexpectation(actualStderr, unexpectStderr, 'stderr', message)) {
          failed = true;
        }
        if (expectExitCode != null) {
          if (result.testExitCode != expectExitCode) {
            message.writeln('Exit code did not match expectation ($expectExitCode).');
            failed = true;
          }
        } else {
          if (result.testExitCode != 0) {
            message.writeln('Exit code was not zero.');
            failed = true;
          }
        }
        if (failed) {
          result.describeInto(message);
        }
        return !failed;
    }
  }

  bool _checkOutputExpectation(String actual, String expected, bool isExact, String label, StringBuffer message) {
    if (expected.isEmpty) {
      return true;
    }
    if ((actual != expected) && (isExact || !actual.contains(expected))) {
      String actualLinesMessage = describeLineCount(actual);
      String expectedLinesMessage = describeLineCount(expected);
      String but;
      if (actualLinesMessage != expectedLinesMessage) {
        but = 'but';
      } else {
        but = 'and indeed';
      }
      message.writeln('$label did not match expected output (expected $expectedLinesMessage, $but saw $actualLinesMessage):');
      message.writeln(prettify(expected).split('\n').map((String line) => 'expect: $line').join('\n'));
      return false;
    }
    return true;
  }

  bool _checkOutputUnexpectation(String actual, List<String> unexpected, String label, StringBuffer message) {
    if (unexpected.isEmpty) {
      return true;
    }
    bool failed = false;
    for (String unexpected in unexpected) {
      if (actual.contains(unexpected)) {
        message.writeln('$label contained unexpected output:');
        message.writeln(prettify(unexpected).split('\n').map((String line) => 'unexpected: $line').join('\n'));
        failed = true;
      }
    }
    return !failed;
  }
}

enum ResultCode {
  hostFailed, // interpreter or compiler itself had an internal error (definite fail)
  testCompileTimeError, // test itself was found to have an error and could not be run (could be intentional)
  testRuntimeError, // test threw or asserted (could be intentional)
  testRan, // test completed, expectations should be verified
}

class TestResult {
  const TestResult.testRan({
    required bool runtimeError,
    required this.testStdout,
    required this.testStderr,
    required this.testExitCode,
  }) : result = runtimeError ? ResultCode.testRuntimeError : ResultCode.testRan, hostOutput = '';

  const TestResult.hostFailed(this.hostOutput) : result = ResultCode.hostFailed, testStdout = '', testStderr = '', testExitCode = 0;

  const TestResult.compilationFailed(this.hostOutput) : result = ResultCode.testCompileTimeError, testStdout = '', testStderr = '', testExitCode = 0;

  final ResultCode result;
  final String hostOutput;
  final String testStdout;
  final String testStderr;
  final int testExitCode;

  void describeInto(StringBuffer message) {
    String exitDescription = switch (testExitCode) {
      -2147483645 => 'STATUS_BREAKPOINT', // 0x80000003
      -2147467259 => 'Unspecified failure - debugger exit?', // 0x80004005
      -1073741819 => 'Access Violation', // 0xC0000005
      -1073741571 => 'Stack overflow', // 0xC00000FD
      -1073740972 => 'STATUS_DEBUGGER_INACTIVE', // 0xC0000354
      -1073741515 => 'STATUS_DLL_NOT_FOUND', // 0xC0000135
      -1 => 'interpreter reported compile-time error', // interpreter-specific
      -2 => 'interpreter reported runtime error', // interpreter-specific
      -3 => 'interpreted program asserted', // interpreter-specific
      -4 => 'interpreted program threw', // interpreter-specific
      0 => '"success"',
      1 => '"failure"',
      254 => 'Dart reported compile-time error', // Dart-specific
      255 => 'Dart reported runtime error', // Dart-specific
      _ => 'unknown exit code',
    };
    int positiveExitCode = testExitCode >= 0 ? testExitCode : 0x100000000 + testExitCode;
    message.writeln(prettify(testStdout).split('\n').map((String line) => 'stdout: $line').join('\n'));
    message.writeln(prettify(testStderr).split('\n').map((String line) => 'stderr: $line').join('\n'));
    message.writeln('exit code: $testExitCode (0x${positiveExitCode.toRadixString(16).padLeft(8, "0")}, $exitDescription)');
  }

  String toString() => '$testExitCode => $result';
}

String prettify(String s) {
  if (s.isEmpty) {
    return '<empty>';
  }
  return s.replaceAllMapped(RegExp(r'[^ -\x5B\x5D-\x7F]'), (Match match) {
    if (match.group(0) == '\r') {
      return '\\r';
    }
    if (match.group(0) == '\n') {
      if (match.end == s.length) {
        return '\\n';
      }
      return '\\n\n';
    }
    if (match.group(0) == '\\') {
      return '\\\\';
    }
    final String hex = match.group(0)!.runes.single.toRadixString(16).padLeft(4, '0');
    return '\\u$hex';
  });
}

String describeLineCount(String s) {
  if (s.isEmpty) {
    return 'nothing';
  }
  int lineCount = s.split('\n').length;
  if (s.endsWith('\n')) {
    lineCount -= 1;
  }
  if (lineCount == 1) {
    return 'one line';
  }
  return '${lineCount} lines';
}

class InterpreterRunner extends TestRunner {
  InterpreterRunner() {
    final ProcessResult result = Process.runSync('dart', ['compile', 'exe', 'lib/syd-main.dart']);
    if (result.exitCode != 0) {
      print(result.stdout);
      print(result.stderr);
      throw Exception('Could not compile interpreter.');
    }
  }

  @override
  String get description => 'interpreter';

  @override
  bool shouldSkipTest(File file) {
    return path.split(file.path).contains('compiler-specific');
  }

  @override
  TestResult executeTest(File file) {
    final ProcessResult result = Process.runSync(
      'lib/syd-main.exe',
      ['--debug', './' + file.path],
    );
    switch (result.exitCode) {
      case -1:
        return TestResult.compilationFailed('Stderr:\n${prettify(result.stderr)}');
      case -2: // general test runtime error
      case -3: // test assert
      case -4: // test throw
        return TestResult.testRan(runtimeError: true, testStdout: result.stdout, testStderr: result.stderr, testExitCode: result.exitCode);
      case 255:
        return TestResult.hostFailed('Stderr:\n${prettify(result.stderr)}');
      default:
        return TestResult.testRan(runtimeError: false, testStdout: result.stdout, testStderr: result.stderr, testExitCode: result.exitCode);
    }
  }
}

class TranspilerRunner extends TestRunner {
  @override
  String get description => 'transpiler';

  @override
  bool shouldSkipTest(File file) {
    return path.split(file.path).contains('compiler-specific');
  }

  @override
  TestResult executeTest(File file) {
    final ProcessResult transpilationResult = Process.runSync(
      'dart',
      ['run', 'lib/syd-transpiler.dart', './' + file.path],
    );
    switch (transpilationResult.exitCode) {
      case -1:
        return TestResult.compilationFailed('Transpiler stdout:\n${transpilationResult.stdout}\nTranspiler stderr:\n${transpilationResult.stderr}');
      case 0:
        break;
      default:
        return TestResult.hostFailed(
          'Transpiler stdout:\n${transpilationResult.stdout}\n'
          'Transpiler stderr:\n${transpilationResult.stderr}\n'
          'Transpiler exit code:\n${transpilationResult.exitCode}'
        );
    }
    final ProcessResult runResult = Process.runSync(
      'dart',
      ['run', '--enable-asserts', 'lib/transpiler-output.dart'],
    );
    switch (runResult.exitCode) {
      case 254:
        return TestResult.hostFailed('Stderr:\n${prettify(runResult.stderr)}'); // test itself was found to have an error and could not be run, which means transpiler messed up
      case 255:
        return TestResult.testRan(runtimeError: true, testStdout: runResult.stdout, testStderr: runResult.stderr, testExitCode: runResult.exitCode); // test runtime error
      default:
        return TestResult.testRan(runtimeError: false, testStdout: runResult.stdout, testStderr: runResult.stderr, testExitCode: runResult.exitCode); // test completed

    }
  }
}

class CompilerRunner extends TestRunner {
  @override
  String get description => 'compiler';

  @override
  bool shouldSkipTest(File file) {
    return path.split(file.path).contains('interpreter-specific');
  }

  @override
  TestResult executeTest(File file) {
    // COMPILE TEST
    final ProcessResult compilationResult = Process.runSync('cmd.exe', ['/C', 'build.bat', '../${file.path}'], workingDirectory: 'compiler');
    final String normalizedCompilerStdout = compilationResult.stdout.replaceAll('\r\n', '\n');
    final String normalizedCompilerStderr = compilationResult.stderr.replaceAll('\r\n', '\n');
    final String compilerOutput = 'stdout:\n$normalizedCompilerStdout\nstderr:\n$normalizedCompilerStderr\n';
    switch (compilationResult.exitCode) {
      case 0: // compiled successfully
        break;
      case 2: // test compilation error
        return TestResult.compilationFailed(compilerOutput);
      default:
        return TestResult.hostFailed(compilerOutput);
    }

    // RUN TEST
    final ProcessResult testResult = Process.runSync('${file.path}.EXE', []);
    final String normalizedTestStdout = testResult.stdout.replaceAll('\r\n', '\n');
    final String normalizedTestStderr = testResult.stderr.replaceAll('\r\n', '\n');
    return TestResult.testRan(
      runtimeError: testResult.exitCode < 0 || testResult.exitCode == 1,
      testStdout: normalizedTestStdout,
      testStderr: normalizedTestStderr,
      testExitCode: testResult.exitCode,
    );
  }
}