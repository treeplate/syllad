@ECHO OFF
REM Uses [syd.transpiler.dart] to compile [../compiler/syd.syd], resulting executable can be found at [../compiler/compiler.exe].
REM Run this in the lib/ directory.
REM D(T(C))

CALL dart run syd-transpiler.dart ../compiler/syd.syd
CALL dart compile exe transpiler-output.dart
MOVE transpiler-output.exe ../compiler/compiler.exe