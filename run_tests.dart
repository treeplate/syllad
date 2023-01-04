import 'dart:io';
import 'package:path/path.dart' as path;

void main() {
  List<File> files = Directory('tests').listSync(recursive: true).whereType<File>().toList()..sort((File a, File b) => a.path.compareTo(b.path));
  int failedCount = runTestSuite(files, 'interpreter', runInterpreter) + runTestSuite(files, 'compiler', runCompiler);
  if (failedCount > 0) {
    exit(1);
  }
}

typedef TestRunner = TestResult? Function(File file);

enum ResultCode {
  sourceError, // interpreter or compiler itself could not be compiled (definite fail)
  executerError, // interpreter or compiler itself had an internal error (definite fail)
  testSourceError, // test itself was found to have an error and could not be run (could be intentional)
  testFailed, // test reported an error (definite fail)
  unknown, // test completed, exit code must be further analyzed
}

class TestResult {
  const TestResult(this.stdout, this.stderr, this.exitCode, {required this.interpretation});
  final String stdout;
  final String stderr;
  final int exitCode;
  final ResultCode interpretation;
}

String prettify(String s) {
  if (s.isEmpty) {
    return '<empty>';
  }
  if (s.endsWith('\n')) {
    return s.substring(0, s.length - 1);
  }
  return s;
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

int runTestSuite(List<File> files, String name, TestRunner testRunner) {
  int skippedCount = 0;
  int failedCount = 0;
  int passedCount = 0;
  print('Running ${files.length} tests for $name...');
  for (File file in files) {
    if (file.path.endsWith('.syd')) {
      bool? result = runTest(file, testRunner);
      if (result == null) {
        skippedCount += 1;
      } else if (result) {
        passedCount += 1;
      } else {
        failedCount += 1;
      }
      stdout.write('$passedCount passed, $failedCount failed, $skippedCount skipped\n');
    }
  }
  print('Results for $name:');
  print('  ${files.length} tests run');
  print('  $failedCount errors');
  print('  $passedCount passed');
  print('  $skippedCount skipped');
  print('');
  return failedCount;
}

bool? runTest(File file, TestRunner testRunner) {
  List<String> lines = file.readAsLinesSync();
  int expectExitCode = 0;
  String expectOutput = '';
  bool expectError = false;
  bool sawExpectation = false;
  for (String line in lines) {
    const String expectedOutput = '// expected output: ';
    const String expectedError = '// expected error: ';
    const String expectedExitCode = '// expected exit code is ';
    if (line.startsWith(expectedOutput)) {
      expectOutput += '${line.substring(expectedOutput.length)}\n';
      sawExpectation = true;
    } else if (line.startsWith(expectedError)) {
      expectError = true; // means we want stderr to be non-empty
      sawExpectation = true;
    } else if (line.startsWith(expectedExitCode)) {
      expectExitCode = int.parse(line.substring(expectedExitCode.length));
      sawExpectation = true;
    } else if (line.startsWith('//')) {
      throw FormatException('Test ${file.path} has an unrecognized comment: $line');
    } else if (line.isEmpty) {
      break;
    }
  }
  if (!sawExpectation) {
    throw FormatException('Test ${file.path} has no specified expectations.');
  }
  if (expectError && expectExitCode != 0) {
    throw FormatException('Test ${file.path} cannot expect both an error and a non-zero exit code.');
  }
  TestResult? result = testRunner(file);
  if (result == null) {
    return null;
  }

  // Process output to make \r look like actual console output.
  String actualOutput = result.stdout.split('\n').map((String line) {
    List<String> sublines = line.split('\r');
    String result = '';
    for (String subline in sublines) {
      if (result.length < subline.length) {
        result = subline;
      } else {
        result = result.replaceRange(0, subline.length, subline);
      }
    }
    if (result.isNotEmpty) {
      return '$result\n';
    }
    return '';
  }).join();

  StringBuffer message = StringBuffer();

  bool definitelyFailed;
  switch (result.interpretation) {
    case ResultCode.sourceError:
    case ResultCode.executerError:
      definitelyFailed = true;
      message.writeln('execution failed');
      break;
    case ResultCode.testFailed:
      definitelyFailed = true;
      message.writeln('test failed');
      break;
    case ResultCode.testSourceError:
      if (!expectError) {
        message.writeln('test compilation error');
        definitelyFailed = true;
      } else {
        definitelyFailed = false;
      }
      break;
    case ResultCode.unknown:
      definitelyFailed = false;
      break;
  }

  // Examine results
  if (expectOutput.isNotEmpty) {
    if (actualOutput != expectOutput) {
      String actualLinesMessage = describeLineCount(actualOutput);
      String expectedLinesMessage = describeLineCount(expectOutput);
      String but;
      if (actualLinesMessage != expectedLinesMessage) {
        but = 'but';
      } else {
        but = 'and indeed';
      }
      message.writeln('Output did not match expected output (expected $expectedLinesMessage, $but saw $actualLinesMessage):');
      message.writeln(prettify(expectOutput).split('\n').map((String line) => 'expect: $line').join('\n'));
      definitelyFailed = true;
    }
  }
  if (!expectError && expectExitCode != result.exitCode) {
    message.writeln('Exit code did not match expected exit code (${expectExitCode}).');
    definitelyFailed = true;
  }
  if (result.stderr.isNotEmpty && !expectError) {
    message.writeln('Non-empty output on standard error (but did not expect an error).');
    definitelyFailed = true;
  } else if (result.stderr.isEmpty && expectError) {
    message.writeln('Empty output on standard error but expected an error.');
    definitelyFailed = true;
  }
  if (definitelyFailed) {
    print('');
    print('Failure in ${file.path}');
    print('exit code: ${result.exitCode} (${result.interpretation})');
    print(prettify(actualOutput).split('\n').map((String line) => 'stdout: $line').join('\n'));
    print(prettify(result.stderr).split('\n').map((String line) => 'stderr: $line').join('\n'));
    print(message);
  }
  return !definitelyFailed;
}

TestResult? runInterpreter(File file) {
  if (path.split(file.path).contains('not yet passing in interpreter')) {
    return null;
  }
  if (path.split(file.path).contains('compiler-specific')) {
    return null;
  }
  ProcessResult result = Process.runSync(
    'dart',
    ['run', '--enable-asserts', 'main.dart', './' + path.posix.joinAll(path.split(path.dirname(file.path))), path.basename(file.path)],
  );
  ResultCode resultCode;
  switch (result.exitCode) {
    case 254:
      resultCode = ResultCode.sourceError;
      break; // interpreter itself could not be compiled
    case 255:
      resultCode = ResultCode.executerError;
      break; // interpreter failed during execution
    case -1:
    case -2:
      resultCode = ResultCode.testSourceError;
      break; // test itself was found to have an error and could not be run
    case -3:
    case -4:
      resultCode = ResultCode.testFailed;
      break; // test reported an error (threw or asserted)
    default:
      resultCode = ResultCode.unknown;
      break; // test completed
  }
  return TestResult(result.stdout, result.stderr, result.exitCode, interpretation: resultCode);
}

TestResult? runCompiler(File file) {
  if (path.split(file.path).contains('not yet passing in compiler')) {
    return null;
  }
  if (path.split(file.path).contains('interpreter-specific')) {
    return null;
  }
  File('compiler/temp.syd').writeAsStringSync(file.readAsStringSync());
  ProcessResult result = Process.runSync('cmd.exe', ['/C', 'build.bat'], workingDirectory: 'compiler');
  String normalizedStdout = result.stdout.replaceAll('\r\n', '\n');
  String normalizedStderr = result.stderr.replaceAll('\r\n', '\n');
  if (result.exitCode != 0) {
    return TestResult(normalizedStdout, '${normalizedStderr}\nbatch file returned non-zero exit code (${result.exitCode})', result.exitCode,
        interpretation: ResultCode.executerError);
  }

  List<String> normalizedStdoutLines = normalizedStdout.split('\n');
  if (normalizedStdoutLines.contains('== FAILED ==')) {
    String kCompilerExitCodeMessage = 'compiler exit code: ';
    int? exitCode;
    if (normalizedStdoutLines.any((String line) => line.startsWith(kCompilerExitCodeMessage))) {
      exitCode = int.tryParse(normalizedStdoutLines
          .firstWhere(
            (String line) => line.startsWith(kCompilerExitCodeMessage),
          )
          .substring(kCompilerExitCodeMessage.length));
    }
    ResultCode resultCode;
    switch (exitCode) {
      case -2: // compiler itself could not be compiled
        resultCode = ResultCode.sourceError;
        break;
      case -4: // test itself was found to have an error and could not be run
        resultCode = ResultCode.testSourceError;
        break;
      case 0:
        throw StateError('FAILED with zero exit code');
      case -3: // compiler itself had an internal error
      case -1: // stack overflow in interpreter while running compiler
      default: // compiler exit with unexpected error code
        resultCode = ResultCode.executerError;
        break;
    }
    return TestResult(normalizedStdout, normalizedStderr, result.exitCode,
        interpretation: resultCode); // failure is not set to true here because we might be expecting a failure
  }

  List<String> asm = File('compiler/syd.asm').readAsLinesSync();
  if (asm.isNotEmpty && asm.length < 1000) {
    return TestResult(normalizedStdout, '${normalizedStderr}\nsyd.asm contents:\n${asm.join('\n')}', result.exitCode, interpretation: ResultCode.executerError);
  }
  // STDOUT
  int startStdout = normalizedStdoutLines.indexOf('= START STDOUT =================');
  int endStdout = normalizedStdoutLines.indexOf('= END STDOUT ===================');
  if (startStdout == -1 || endStdout == -1) {
    print('stdout: $normalizedStdoutLines');
    return TestResult(normalizedStdout, '${normalizedStderr}\ncould not find start/end STDOUT markers (start=$startStdout, end=$endStdout)', result.exitCode,
        interpretation: ResultCode.executerError);
  }
  String filteredStdout = normalizedStdoutLines.sublist(startStdout + 1, endStdout).join('\n');
  // STDERR
  List<String> normalizedStderrLines = normalizedStderr.split('\n');
  int startStderr = normalizedStderrLines.indexOf('= START STDERR =================');
  int endStderr = normalizedStderrLines.indexOf('= END STDERR ===================');
  if (startStderr == -1 || endStderr == -1) {
    return TestResult(normalizedStdout, '${normalizedStderr}\ncould not find start/end STDERR markers (start=$startStderr, end=$endStderr)', result.exitCode,
        interpretation: ResultCode.executerError);
  }
  String filteredStderr = normalizedStderrLines.sublist(startStderr + 1, endStderr).join('\n');
  // EXIT CODE
  int? exitCode = int.tryParse(normalizedStdoutLines[endStdout + 1].substring('test exit code: '.length));
  if (exitCode == null) {
    return TestResult(normalizedStdout, '${normalizedStderr}\ncould not parse exit code ("${normalizedStdoutLines[endStdout + 1]}")', result.exitCode,
        interpretation: ResultCode.executerError);
  }
  return TestResult(filteredStdout, filteredStderr, exitCode, interpretation: ResultCode.unknown);
}
