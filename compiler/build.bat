@ECHO OFF
REM Compiles the first argument using [compiler.exe].

SETLOCAL EnableDelayedExpansion

REM EXE, INTERPRETER
SET HOST=EXE

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
      ECHO INVALID COMPILATION MODE: %COMPILATIONMODE%
      EXIT /B 1
    )
  )
)

ECHO COMPILING...

SET TEMPFILE=%TEMP%\%DATE:~0,4%%DATE:~5,2%%DATE:~8,2%%TIME:~0,2%%TIME:~3,2%%TIME:~6,2%%TIME:~9,2%.$$$
SET TEMPFILE=%TEMPFILE: =0%
IF %HOST% == EXE (
  CALL "compiler.exe" --mode=%COMPILATIONMODE% %1 > %TEMPFILE%
) ELSE (
  IF %HOST% == INTERPRETER (
    CALL "..\lib\syd-main.exe" --debug syd.syd --mode=%COMPILATIONMODE% %1 > %TEMPFILE%
  ) ELSE (
    ECHO INVALID HOST: %HOST%
    EXIT /B 1
  )
)
IF NOT !ERRORLEVEL! == 0 (
    ECHO Compilation failed with exit code %ERRORLEVEL%
    IF !ERRORLEVEL! == -1073741510 ECHO "0xC000013A: STATUS_CONTROL_C_EXIT"
    EXIT /B %ERRORLEVEL%
) ELSE (
    MOVE /Y %TEMPFILE% "%~1.%EXTENSION%" > NUL
    IF NOT !ERRORLEVEL! == 0 (
        ECHO Could not update "%~1.%EXTENSION%", error %ERRORLEVEL%
        EXIT /B %ERRORLEVEL%
    )
    ECHO ASSEMBLING AND LINKING...
    IF EXIST "%~1.exe" (
        DEL "%~1.exe"
        IF NOT !ERRORLEVEL! == 0 (
            ECHO Could not delete "%~1.exe", error %ERRORLEVEL%
            EXIT /B %ERRORLEVEL%
        )
    )
    IF %COMPILATIONMODE% == MASM (
      IF NOT "%WindowsSdkDir%"=="" GOTO RUN
      ECHO CONFIGURING ENVIRONMENT...
      CALL "C:\Program Files\Microsoft Visual Studio\2022\Community\VC\Auxiliary\Build\vcvars64.bat" > NUL
      :RUN
      ML64 /Zd /Zi /Fo "%~1.obj" /Fe "%~1.exe" "%~1.%EXTENSION%"
    ) ELSE (
      IF %COMPILATIONMODE% == FASM (
        C:/dev/fasm/fasm "%~1.%EXTENSION%" "%~1.exe"
      ) ELSE (
        IF %COMPILATIONMODE% == LLVM (
          CLANG -v -nostdlib -g -gcodeview -O3 -fuse-ld=lld --for-linker /subsystem:console "%~1.%EXTENSION%" --for-linker "C:\Program Files\Microsoft Visual Studio\2022\Community\VC\Tools\MSVC\14.30.30705\lib\x64\chkstk.obj" --for-linker /out:"%~1.EXE"
        ) ELSE (
          ECHO INVALID COMPILATION MODE
          EXIT /B 1
        )
      )
    )
    IF NOT !ERRORLEVEL! == 0 (
        ECHO Could not assemble "%~1.%EXTENSION%", error !ERRORLEVEL!
        EXIT /B %ERRORLEVEL%
    )
    IF NOT EXIST "%~1.exe" (
        ECHO Failed to create executable.
        EXIT /B 1
    )
)