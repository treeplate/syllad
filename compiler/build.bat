@ECHO OFF
SETLOCAL EnableDelayedExpansion
IF NOT "%WindowsSdkDir%"=="" GOTO RUN
ECHO CONFIGURING ENVIRONMENT
CALL "C:\Program Files\Microsoft Visual Studio\2022\Community\VC\Auxiliary\Build\vcvars64.bat"
:RUN
DEL syd.exe
ECHO RUNNING INTERPRETED COMPILER TO GENERATE COMPILER
CD ..
CALL "C:\dev\flutter\bin\dart.bat" main.dart > compiler\syd.asm
CD compiler
ECHO ASSEMBLING AND LINKING COMPILER
ML64 /Zd /Zi syd.asm
IF EXIST "syd.exe" (
    ECHO RUNNING COMPILED COMPILER
    syd.exe
    ECHO exit code: !ERRORLEVEL!
    IF !ERRORLEVEL! == -1073741571 ECHO 0xC00000FD: Stack overflow
    IF !ERRORLEVEL! == -1073741819 ECHO 0xC0000005: Access Violation
    IF !ERRORLEVEL! == -2147467259 ECHO 0x80004005: Unspecified failure
    IF !ERRORLEVEL! == -2147483645 ECHO 0x80000003: STATUS_BREAKPOINT
    ECHO DONE
) ELSE (
    ECHO == FAILED ==
)