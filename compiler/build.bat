@ECHO OFF
REM Compiles the first argument using [compiler.exe], then runs it with no arguments.
REM IF %LEAVEEXE% equals 1, the resulting executable is at [%~1.exe].

REM TODO: build should only build, not also manage the program execution

SETLOCAL EnableDelayedExpansion

SET TIMETRAVEL=1

REM LLVM, MASM, FASM
SET COMPILATIONMODE=LLVM

IF %COMPILATIONMODE% == MASM (
  SET EXTENSION=ASM
) ELSE (
  IF %COMPILATIONMODE% == FASM (
    SET EXTENSION=ASM
  ) ELSE (
    IF %COMPILATIONMODE% == LLVM (
      SET EXTENSION=ll
    ) ELSE (
      ECHO INVALID COMPILATION MODE
      EXIT /B 1
    )
  )
)

IF NOT "%WindowsSdkDir%"=="" GOTO RUN
ECHO CONFIGURING ENVIRONMENT...
CALL "C:\Program Files\Microsoft Visual Studio\2022\Community\VC\Auxiliary\Build\vcvars64.bat" > NUL
:RUN
ECHO COMPILING...

SET TEMPFILE=%TEMP%\%DATE:~0,4%%DATE:~5,2%%DATE:~8,2%%TIME:~0,2%%TIME:~3,2%%TIME:~6,2%%TIME:~9,2%.$$$
SET TEMPFILE=%TEMPFILE: =0%
CALL "compiler.exe" --mode=%COMPILATIONMODE% %1 > %TEMPFILE%
IF NOT !ERRORLEVEL! == 0 (
    ECHO Compilation failed with exit code %ERRORLEVEL%
    IF !ERRORLEVEL! == -1073741510 ECHO "0xC000013A: STATUS_CONTROL_C_EXIT"
    ECHO == FAILED ==
    ECHO compiler exit code: %ERRORLEVEL%
    EXIT /B %ERRORLEVEL%
) ELSE (
    MOVE /Y %TEMPFILE% "%~1.%EXTENSION%" > NUL
    IF NOT !ERRORLEVEL! == 0 (
        ECHO Could not update "%~1.%EXTENSION%", error %ERRORLEVEL%
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
    IF %COMPILATIONMODE% == MASM (
      ML64 /Zd /Zi /Fo "%~1.obj" /Fe "%~1.exe" "%~1.%EXTENSION%"
    ) ELSE (
      IF %COMPILATIONMODE% == FASM (
        C:/dev/fasm/fasm "%~1.%EXTENSION%" "%~1.exe"
      ) ELSE (
        IF %COMPILATIONMODE% == LLVM (
          REM TODO: WHAT ABOUT MORE DEFAULT LIBS??
          REM LLD knows how to read .drectve, we should put the /defaultlib arguments there
          REM but how do we add a .drectve section to a .ll file?
          CLANG -v -nostdlib -g -gcodeview -fuse-ld=lld --for-linker /subsystem:console --for-linker /entry:main --for-linker /defaultlib:KERNEL32 --for-linker /defaultlib:SHELL32 "%~1.%EXTENSION%" --for-linker "C:\Program Files\Microsoft Visual Studio\2022\Community\VC\Tools\MSVC\14.30.30705\lib\x64\chkstk.obj" --for-linker /out:"%~1.EXE"
        ) ELSE (
          ECHO INVALID COMPILATION MODE
          EXIT /B 1
        )
      )
    )
    IF NOT !ERRORLEVEL! == 0 (
        ECHO Could not assemble "%~1.%EXTENSION%", error !ERRORLEVEL!
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
        IF !ERRORLEVEL! == -2147483645 ECHO 0x80000003: STATUS_BREAKPOINT
        IF !ERRORLEVEL! == -2147467259 ECHO 0x80004005: Unspecified failure - debugger exit?
        IF !ERRORLEVEL! == -1073741819 ECHO 0xC0000005: Access Violation
        IF !ERRORLEVEL! == -1073741571 ECHO 0xC00000FD: Stack overflow
        IF !ERRORLEVEL! == -1073740972 ECHO 0xC0000354: STATUS_DEBUGGER_INACTIVE
        IF !ERRORLEVEL! == -1073741515 ECHO 0xC0000135: STATUS_DLL_NOT_FOUND
        IF "%TIMETRAVEL%" == "1" GOTO TIMETRAVEL
        IF EXIST "%~1.%EXTENSION%" DEL "%~1.%EXTENSION%" > NUL
        IF EXIST "%~1.ilk" DEL "%~1.ilk" > NUL
        IF EXIST "%~1.pdb" DEL "%~1.pdb" > NUL
        IF EXIST "%~1.obj" DEL "%~1.obj" > NUL
        IF "%LEAVEEXE%" == "1" GOTO FINISHED
        IF EXIST "%~1.exe" DEL "%~1.exe" > NUL
        GOTO FINISHED
        :TIMETRAVEL
        ECHO TIME TRAVEL MODE ENABLED - NOT DELETING FILES
        :FINISHED
        ECHO == DONE ==
        EXIT /B 0
    ) ELSE (
        ECHO == FAILED ==
        ECHO (TO CREATE EXECUTABLE)
        EXIT /B 1
    )
)