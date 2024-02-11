@ECHO OFF
REM Compiles [syd.syd] using [../lib/syd-transpiler.dart], uses the resulting executable to compile the first argument, and then runs the resulting executable.
REM D(T(C))(X)()

SETLOCAL EnableDelayedExpansion
CD ..\lib
CALL transpile-compiler.bat
IF NOT !ERRORLEVEL! == 0 GOTO END
CD ..\compiler
CALL build.bat %1
:END
ECHO exit code !ERRORLEVEL!