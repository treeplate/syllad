@ECHO OFF
REM Compiles [syd.syd] using [../lib/syd-transpiler.dart], uses the resulting executable to compile [syd.syd] again, uses the resulting executable to compile the first argument, and then runs the resulting executable.
REM D(T(C))(C)(X)()

SETLOCAL EnableDelayedExpansion

ECHO Creating D(T(C))
CD ..\lib
CALL transpile-compiler.bat
IF NOT !ERRORLEVEL! == 0 GOTO END

ECHO Creating D(T(C))(C)
CD ..\compiler
SET LEAVEEXE=1
CALL build.bat syd.syd
IF NOT !ERRORLEVEL! == 0 GOTO END
MOVE compiler.exe compiler1.exe
MOVE syd.syd.exe compiler.exe

REM ECHO Creating D(T(C))(C)(C)
REM CALL build.bat syd.syd
REM IF NOT !ERRORLEVEL! == 0 GOTO END
REM MOVE compiler.exe compiler2.exe
REM MOVE syd.syd.exe compiler.exe

ECHO Creating D(T(C))(C)(C)( %1 )
CALL build.bat %1
IF NOT !ERRORLEVEL! == 0 GOTO END

:END
ECHO exit code !ERRORLEVEL!
