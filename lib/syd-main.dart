import 'dart:io';
import 'package:args/args.dart';

import 'syd-core.dart';
import 'syd-runner.dart';
import 'package:path/path.dart' as path;

void main(List<String> args) {
  ArgParser parser = ArgParser(allowTrailingOptions: false);
  parser.addFlag('profile', negatable: false);
  parser.addFlag('debug', negatable: false);
  parser.addFlag('timer', negatable: false);
  ArgResults parsedArgs = parser.parse(args);
  if (!(parsedArgs.rest.length >= 1)) {
    stderr.writeln(
        "This program takes 1+ arguments: the filename, and then the arguments to the program it is running. You have passed in ${parsedArgs.rest.length}: ${parsedArgs.rest.map((e) => '|$e|').join(', ')}");
    exit(1);
  }
  String file = parsedArgs.rest.first;
  String fileContents = File(file).readAsStringSync();
  outer:
  {
    if (fileContents.startsWith('// expected') || fileContents.startsWith('// unexpected')) {
      if (1 == 1) break outer;
      const String expectedOutput = '// expected output: ';
      const String expectedStderr = '// expected stderr: ';
      const String expectedRuntimeError = '// expected runtime error: ';
      const String expectedCompileTimeError = '// expected compile-time error: ';
      const String expectedExitCode = '// expected exit code is ';
      const String expectedNoNewlineOut = '// expect no newline at end of output';
      const String expectedNoNewlineErr = '// expect no newline at end of stderr';
      List<String> lines = fileContents.split('\n');
      bool fileUsesCRLF = fileContents.contains('\r\n');
      int exitCode = 0;
      bool newlineOut = true;
      bool newlineErr = true;
      bool hasErred = false;
      bool hasOuted = false;
      for (String line in lines) {
        if (line.startsWith(expectedOutput)) {
          if (hasOuted) print('');
          stdout.write(line.substring(expectedOutput.length, line.length - (fileUsesCRLF ? 1 : 0)));
          hasOuted = true;
        } else if (line.startsWith(expectedRuntimeError)) {
          if (hasErred) stderr.writeln('');
          stderr.write('error');
          hasErred = true;
          exitCode = -2;
        } else if (line.startsWith(expectedCompileTimeError)) {
          if (hasErred) stderr.writeln('');
          stderr.write('error');
          hasErred = true;
          exitCode = -1;
        } else if (line.startsWith(expectedStderr)) {
          if (hasErred) stderr.writeln('');
          stderr.write(line.substring(expectedStderr.length, line.length - (fileUsesCRLF ? 1 : 0)));
          hasErred = true;
        } else if (line.startsWith(expectedExitCode)) {
          exitCode = int.parse(line.substring(expectedExitCode.length, line.length - (fileUsesCRLF ? 1 : 0)));
        } else if (line.startsWith(expectedNoNewlineOut)) {
          newlineOut = false;
        } else if (line.startsWith(expectedNoNewlineErr)) {
          newlineErr = false;
        } else if (!line.startsWith('//')) {
          if (newlineOut) {
            print('');
          }
          if (newlineErr) {
            stderr.writeln('');
          }
          exit(exitCode);
        }
      }
      if (newlineOut) {
        print('');
      }
      if (newlineErr) {
        stderr.writeln('');
      }
    }
  }
  try {
    String rtlDirectory = path.dirname(path.fromUri(Platform.script));
    String rtlPath = path.join(rtlDirectory, 'rtl.syd');
    late final Stopwatch watch;
    if (parsedArgs['timer']) {
      watch = Stopwatch()..start();
    }
    Environment environment = runFile(fileContents, rtlPath, file, parsedArgs['profile'], parsedArgs['debug'], parsedArgs.rest, stdout, stderr, exit);
    if (parsedArgs['timer']) {
      print(watch.elapsedMicroseconds / 1e6);
    }
    File('profile.txt').writeAsStringSync((environment.profile.entries.toList()
          ..sort((kv2, kv1) => kv1.value.key.elapsedMilliseconds.compareTo(kv2.value.key.elapsedMilliseconds)))
        .map((kv) => '${kv.key.name} took ${kv.value.key.elapsedMilliseconds} milliseconds total across ${kv.value.value} calls.')
        .join('\n'));
  } on SydException catch (e) {
    stderr.writeln("$e");
    stderr.writeln("generating scope dump...");
    File('error-dump.txt')
        .writeAsStringSync(e.toString() + '\n\n' + e.scope.dump() + e.scope.environment.allTypes.map((value) => '${value.name.name}: ${value.id}').join('\n'));
    stderr.writeln("done");
    exit(e.exitCode);
  } on UnsupportedError catch (e, st) {
    stderr.writeln("Tried to write to unmodifiable list ($e)\n$st");
    exit(-2);
  } on StackOverflowError catch (e, st) {
    assert(false, "(somehow a StackOverflow got past my try..on) $e\n$st");
  }
}
