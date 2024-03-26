@ECHO OFF
REM Compiles [syd.syd] using [../lib/syd-transpiler.dart], and uses the resulting executable to compile [syd.syd] again.
REM D(T(C))(C)

SETLOCAL EnableDelayedExpansion

SET LEVEL=%1

IF "%LEVEL%" == "" (
  ECHO First argument to compiler-build should be how many levels to do.
)

ECHO Creating D(T(C))
CD ..\lib
CALL dart run syd-transpiler.dart ../compiler/syd.syd
CALL dart compile exe transpiler-output.dart
CD ..\compiler
MOVE ..\lib\transpiler-output.exe compiler.exe
IF NOT !ERRORLEVEL! == 0 GOTO END

IF %LEVEL% GEQ 2 (
  ECHO "Creating D(T(C))(C)"
  CALL build.bat syd.syd
  IF NOT !ERRORLEVEL! == 0 GOTO END
  MOVE compiler.exe compiler1.exe
  MOVE syd.syd.exe compiler.exe
)
IF %LEVEL% GEQ 3 (
  ECHO "Creating D(T(C))(C)(C)"
  CALL build.bat syd.syd
  IF NOT !ERRORLEVEL! == 0 GOTO END
  MOVE compiler.exe compiler2.exe
  MOVE syd.syd.exe compiler.exe
)
IF %LEVEL% GEQ 4 (
  ECHO Level 4 or greater not supported in compiler-build
)
:END
ECHO exit code !ERRORLEVEL!
