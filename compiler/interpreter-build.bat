@ECHO OFF
REM Interprets [syd.syd] using [../lib/syd-main.dart], passing it the first argument, and runs the resulting executable.
REM prefer build.bat or fullbuild.bat - they use the transpiler so they are faster.
REM I(C, X)()

SETLOCAL EnableDelayedExpansion

SET TIMETRAVEL=1

IF NOT "%WindowsSdkDir%"=="" GOTO RUN
ECHO CONFIGURING ENVIRONMENT...
CALL "C:\Program Files\Microsoft Visual Studio\2022\Community\VC\Auxiliary\Build\vcvars64.bat" > NUL
:RUN
ECHO COMPILING...

SET TEMPFILE=%TEMP%\%DATE:~0,4%%DATE:~5,2%%DATE:~8,2%%TIME:~0,2%%TIME:~3,2%%TIME:~6,2%%TIME:~9,2%.$$$
SET TEMPFILE=%TEMPFILE: =0%
REM add --observe to profile
CALL "..\lib\syd-main.exe" --debug syd.syd %1 > %TEMPFILE%
IF NOT !ERRORLEVEL! == 0 (
    ECHO Compilation failed with exit code %ERRORLEVEL%
    IF !ERRORLEVEL! == -1073741510 ECHO "0xC000013A: STATUS_CONTROL_C_EXIT"
    ECHO == FAILED ==
    ECHO compiler exit code: %ERRORLEVEL%
    EXIT /B 0
) ELSE (
    MOVE /Y %TEMPFILE% "%~1.asm" > NUL
    IF NOT !ERRORLEVEL! == 0 (
        ECHO Could not update "%~1.asm", error %ERRORLEVEL%
        ECHO == FAILED ==
        EXIT /B %ERRORLEVEL%
    )
    ECHO ASSEMBLING AND LINKING...
    IF EXIST "%~1.exe" (
        DEL "%~1.exe"
        IF NOT !ERRORLEVEL! == 0 (
            ECHO Could not delete "%~1.exe", error %ERRORLEVEL%
            ECHO == FAILED ==
            EXIT /B %ERRORLEVEL%
        )
    )
    ECHO ML64 /Zd /Zi /Fo "%~1.obj" /Fe "%~1.exe" "%~1.asm"
    ML64 /Zd /Zi /Fo "%~1.obj" /Fe "%~1.exe" "%~1.asm"
    IF NOT !ERRORLEVEL! == 0 (
        ECHO Could not assemble "%~1.asm", error %ERRORLEVEL%
        ECHO == FAILED ==
        EXIT /B %ERRORLEVEL%
    )
    IF EXIST "%~1.exe" (
        ECHO EXECUTING...
        ECHO = START STDOUT =================
        ECHO = START STDERR =================1>&2
        "%~1.exe"
        ECHO = END STDOUT ===================
        ECHO = END STDERR ===================1>&2
        ECHO test exit code: !ERRORLEVEL!
        IF !ERRORLEVEL! == -2147483645 ECHO "0x80000003: STATUS_BREAKPOINT"
        IF !ERRORLEVEL! == -2147467259 ECHO "0x80004005: Unspecified failure (debugger exit?)"
        IF !ERRORLEVEL! == -1073741819 ECHO "0xC0000005: Access Violation"
        IF !ERRORLEVEL! == -1073741571 ECHO "0xC00000FD: Stack overflow"
        IF !ERRORLEVEL! == -1073740972 ECHO "0xC0000354: STATUS_DEBUGGER_INACTIVE"
        IF "%TIMETRAVEL%" == "1" GOTO TIMETRAVEL
        IF EXIST "%~1.asm" DEL "%~1.asm" > NUL
        IF EXIST "%~1.exe" DEL "%~1.exe" > NUL
        IF EXIST "%~1.ilk" DEL "%~1.ilk" > NUL
        IF EXIST "%~1.pdb" DEL "%~1.pdb" > NUL
        IF EXIST "%~1.obj" DEL "%~1.obj" > NUL
        GOTO FINISHED
        :TIMETRAVEL
        ECHO TIME TRAVEL MODE ENABLED - NOT DELETING FILES
        :FINISHED
        ECHO == DONE ==
        EXIT /B 0
    ) ELSE (
        ECHO == FAILED ==
        EXIT /B 1
    )
)