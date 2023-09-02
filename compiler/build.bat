@ECHO OFF
SETLOCAL EnableDelayedExpansion

IF NOT "%WindowsSdkDir%"=="" GOTO RUN
ECHO CONFIGURING ENVIRONMENT...
CALL "C:\Program Files\Microsoft Visual Studio\2022\Community\VC\Auxiliary\Build\vcvars64.bat" > NUL
:RUN
ECHO COMPILING...
CD ..

SET TEMPFILE=%TEMP%\%DATE:~0,4%%DATE:~5,2%%DATE:~8,2%%TIME:~0,2%%TIME:~3,2%%TIME:~6,2%%TIME:~9,2%.$$$
SET TEMPFILE=%TEMPFILE: =0%
REM add --observe to profile
CALL "C:\dev\flutter\bin\dart.bat" run main.dart --debug ./compiler syd.syd %1 > %TEMPFILE%
IF NOT !ERRORLEVEL! == 0 (
    ECHO Compilation failed with exit code %ERRORLEVEL%
    IF !ERRORLEVEL! == -1073741510 ECHO "0xC000013A: STATUS_CONTROL_C_EXIT"
    ECHO == FAILED ==
    ECHO compiler exit code: %ERRORLEVEL%
    EXIT /B 0
) ELSE (
    MOVE /Y %TEMPFILE% compiler\syd.asm > NUL
    IF NOT !ERRORLEVEL! == 0 (
        ECHO Could not update syd.asm, error %ERRORLEVEL%
        ECHO == FAILED ==
        EXIT /B %ERRORLEVEL%
    )
    CD compiler
    ECHO ASSEMBLING AND LINKING...
    IF EXIST "syd.exe" (
        DEL syd.exe
        IF NOT !ERRORLEVEL! == 0 (
            ECHO Could not delete syd.exe, error %ERRORLEVEL%
            ECHO == FAILED ==
            EXIT /B %ERRORLEVEL%
        )
    )
    ML64 /Zd /Zi syd.asm
    IF NOT !ERRORLEVEL! == 0 (
        ECHO Could not assemble syd.asm, error %ERRORLEVEL%
        ECHO == FAILED ==
        EXIT /B %ERRORLEVEL%
    )
    IF EXIST "syd.exe" (
        ECHO EXECUTING...
        ECHO = START STDOUT =================
        ECHO = START STDERR =================1>&2
        syd.exe
        ECHO = END STDOUT ===================
        ECHO = END STDERR ===================1>&2
        ECHO test exit code: !ERRORLEVEL!
        IF !ERRORLEVEL! == -2147483645 ECHO "0x80000003: STATUS_BREAKPOINT"
        IF !ERRORLEVEL! == -2147467259 ECHO "0x80004005: Unspecified failure (debugger exit?)"
        IF !ERRORLEVEL! == -1073741819 ECHO "0xC0000005: Access Violation"
        IF !ERRORLEVEL! == -1073741571 ECHO "0xC00000FD: Stack overflow"
        IF !ERRORLEVEL! == -1073740972 ECHO "0xC0000354: STATUS_DEBUGGER_INACTIVE"
        ECHO DONE
        EXIT /B 0
    ) ELSE (
        ECHO == FAILED ==
        EXIT /B 1
    )
)