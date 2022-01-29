_drectve segment info alias(".drectve")
  db ' /ENTRY:main '
_drectve ends
option casemap:none

; includes
includelib kernel32.lib
includelib kernel32.lib

; externs
extern GetStdHandle : proc
extern WriteConsoleA : proc
extern ExitProcess : proc

.data


.code

public main
main:
  ; rtl
  ; ===
  ; Prolog
  push rbp                                                         ; save volatile registers
  mov rbp, rsp                                                     ; set up frame pointer
  ; Epilog
  pop rbp                                                          ; restore volatile registers

  ; temp.syd
  ; ========
  ; Prolog
  push rbp                                                         ; save volatile registers
  sub rsp, 050h                                                    ; allocate space for stack
  mov rbp, rsp                                                     ; set up frame pointer
  ; Line 1: print(45 /* 0x2d */);
  mov dword ptr [rbp+040h], 0h                                     ; value of this pointer
  mov dword ptr [rbp+048h], 000000001h                             ; type of this pointer
  mov dword ptr [rbp+038h], 0h                                     ; value of closure pointer
  ; Calling print with 1 arguments
  push 00000002dh                                                  ; value of argument #1
  push 000000007h                                                  ; type of argument #1
  lea r11, [rbp+028h]                                              ; pointer to return value (and type, 8 bytes later)
  push r11                                                         ; (that pointer is the last value pushed to the stack)
  lea r9, [rbp+040h]                                               ; pointer to this
  mov r8, [rbp+048h]                                               ; type of this
  lea rdx, [rbp+038h]                                              ; pointer to closure
  mov rcx, 1                                                       ; number of arguments
  sub rsp, 20h                                                     ; allocate shadow space
  call print                                                       ; jump to subroutine
  add rsp, 038h                                                    ; release shadow space and arguments
  mov dword ptr [rbp+018h], 0h                                     ; value of this pointer
  mov dword ptr [rbp+020h], 000000001h                             ; type of this pointer
  mov dword ptr [rbp+010h], 0h                                     ; value of closure pointer
  ; Calling exit with 1 arguments
  push 000000000h                                                  ; value of argument #1
  push 000000007h                                                  ; type of argument #1
  lea r11, [rbp+000h]                                              ; pointer to return value (and type, 8 bytes later)
  push r11                                                         ; (that pointer is the last value pushed to the stack)
  lea r9, [rbp+018h]                                               ; pointer to this
  mov r8, [rbp+020h]                                               ; type of this
  lea rdx, [rbp+010h]                                              ; pointer to closure
  mov rcx, 1                                                       ; number of arguments
  sub rsp, 20h                                                     ; allocate shadow space
  call exit                                                        ; jump to subroutine
  add rsp, 038h                                                    ; release shadow space and arguments
  ; Epilog
  add rsp, 050h                                                    ; free space for stack
  pop rbp                                                          ; restore volatile registers
  ret                                                              ; exit application

print:
  ; Prolog
  push rbp                                                         ; save volatile registers
  sub rsp, 008h                                                    ; allocate space for stack
  mov rbp, rsp                                                     ; set up frame pointer
  ; TODO: check type of argument
  ; Calling GetStdHandle
  mov rcx, -11                                                     ; argument #1: STD_OUTPUT_HANDLE
  call GetStdHandle                                                ; handle returned in rax
  ; Calling WriteConsoleA
  push 0                                                           ; argument #5: Reserved, must be NULL (lpReserved)
  lea r9, [rbp+000h]                                               ; argument #4: Number of characters written (lpNumberOfCharsWritten)
  mov r10, [rbp+48h]                                               ; get address of string structure
  mov r8, [r10+08h]                                                ; argument #3: Length of buffer (nNumberOfCharsToWrite), from string structure
  lea rdx, [r10+10h]                                               ; argument #2: Pointer to buffer to write (*lpBuffer)
  mov rcx, rax                                                     ; argument #1: Handle from GetStdHandle (hConsoleOutput)
  sub rsp, 20h                                                     ; allocate shadow space
  call WriteConsoleA                                               ; returns boolean representing success in rax
  add rsp, 28h                                                     ; release shadow space and arguments
  ; Epilog
  add rsp, 008h                                                    ; free space for stack
  pop rbp                                                          ; restore volatile registers
  ret                                                              ; return from subroutine

exit:
  ; Prolog
  push rbp                                                         ; save volatile registers
  mov rbp, rsp                                                     ; set up frame pointer
  ; Calling ExitProcess
  mov rcx, [rbp+40h]                                               ; exit code
  sub rsp, 20h                                                     ; allocate shadow space
  call ExitProcess                                                 ; process should terminate at this point
  add rsp, 20h                                                     ; release shadow space
  ; Epilog
  pop rbp                                                          ; restore volatile registers
  ret                                                              ; return from subroutine


end

