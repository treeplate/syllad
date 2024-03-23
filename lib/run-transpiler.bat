@ECHO OFF
REM Uses [syd.transpiler.dart] to compile and run the first argument (with the third argument as the current working directory, passing the second argument as an argument to the executable), resulting executable can be found at [%1.exe]
REM Run this in the lib/ directory.

SETLOCAL EnableDelayedExpansion
CALL dart run syd-transpiler.dart %1
IF NOT !ERRORLEVEL! == 0 GOTO END
CALL dart compile exe transpiler-output.dart
IF NOT !ERRORLEVEL! == 0 GOTO END
MOVE transpiler-output.exe %1.exe 
cd %3
%1.exe %2
:END
ECHO exit code !ERRORLEVEL!