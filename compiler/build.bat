@ECHO OFF
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
ML64 syd.asm
IF EXIST "syd.exe" (
    ECHO RUNNING COMPILED COMPILER
    syd.exe
    ECHO DONE
) ELSE (
    ECHO == FAILED ==
)