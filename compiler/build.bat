@ECHO OFF
IF NOT "%WindowsSdkDir%"=="" GOTO RUN
ECHO CONFIGURING ENVIRONMENT
CALL "C:\Program Files\Microsoft Visual Studio\2022\Community\VC\Auxiliary\Build\vcvars64.bat"
:RUN
ECHO RUNNING INTERPRETED COMPILER TO GENERATE COMPILER
CD ..
CALL "C:\dev\flutter\bin\dart.bat" main.dart > compiler\syd.asm
CD compiler
ECHO ======
TYPE syd.asm
ECHO ======
ECHO ASSEMBLING AND LINKING COMPILER
ML64 syd.asm
ECHO RUNNING COMPILED COMPILER
syd.exe
ECHO DONE