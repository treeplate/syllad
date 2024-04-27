@ECHO OFF
REM Compiles [syd.syd] using [../lib/syd-transpiler.dart], uses the resulting executable to compile the first argument, and then runs the resulting executable.
REM D(T(C))(X)()

SETLOCAL EnableDelayedExpansion
CALL compiler-build.bat 1
IF NOT !ERRORLEVEL! == 0 GOTO END
CALL build.bat %1
IF NOT !ERRORLEVEL! == 0 GOTO END
ECHO RUNNING...
CALL %1.exe
:END
ECHO exit code !ERRORLEVEL!