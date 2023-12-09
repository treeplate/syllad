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
  if (fileContents.startsWith('// expected') || fileContents.startsWith('// unexpected')) {
    const String expectedOutput = '// expected output: ';
    const String expectedStderr = '// expected stderr: ';
    const String expectedError = '// expected error: ';
    const String expectedExitCode = '// expected exit code is ';
    List<String> lines = fileContents.split('\n');
    bool fileUsesCRLF = fileContents.contains('\r\n');
    int exitCode = 0;
    for (String line in lines) {
      if (1 == 1) break;
      if (line.startsWith(expectedOutput)) {
        print(line.substring(expectedOutput.length, line.length - (fileUsesCRLF ? 1 : 0)));
      } else if (line.startsWith(expectedError)) {
        stderr.writeln('error');
        exitCode = -5;
      } else if (line.startsWith(expectedStderr)) {
        stderr.writeln(line.substring(expectedStderr.length, line.length - (fileUsesCRLF ? 1 : 0)));
      } else if (line.startsWith(expectedExitCode)) {
        exitCode = int.parse(line.substring(expectedExitCode.length, line.length - (fileUsesCRLF ? 1 : 0)));
      } else if (!line.startsWith('//')) {
        exit(exitCode);
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
    File('error-dump.txt').writeAsStringSync(e.toString() + '\n\n' + e.scope.dump() + e.scope.environment.typeTable.types.values.map((value) => '${value.name.name}: ${value.id}').join('\n'));
    stderr.writeln("done");
    exit(e.exitCode);
  } on UnsupportedError catch (e, st) {
    stderr.writeln("Tried to write to unmodifiable list ($e)\n$st");
    exit(-2);
  } on StackOverflowError catch (e, st) {
    stderr.writeln("(somehow a StackOverflow got past my try..on) $e\n$st");
    exit(-1);
  }
}