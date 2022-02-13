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
  typeTable    db 000h, 000h, 000h, 000h, 000h, 000h, 000h, 001h, 002h ; Type table
   ; Columns: Integer'7 String'8
   ; 0 0   <object>'0
   ; 0 0   <closure>'1
   ; 0 0   Null'2
   ; 0 0   Boolean'3
   ; 0 0   NullFunction(Anything...)'4
   ; 0 0   NullFunction(Integer)'5
   ; 0 0   NullFunction(String)'6
   ; 1 0   Integer'7
   ; 0 1   String'8

  parameterCountCheckFailureMessage dq -01h                        ; String constant (reference count)
               dq 88                                               ; Length
               db "error: function call received the wrong number of parameters (expected %d, received %d)", 0ah ; line 1126 column 25 in file syd-compiler.syd
  parameterTypeCheckFailureMessage dq -01h                         ; String constant (reference count)
               dq 71                                               ; Length
               db "error: type mismatch for function %s parameter %d, expected %s, got %s", 0ah ; line 1131 column 25 in file syd-compiler.syd
  string       dq -01h                                             ; String constant (reference count)
               dq 13                                               ; Length
               db "Hello World", 0dh, 0ah                          ; line 4 column 22 in file temp.syd
  string$1     dq -01h                                             ; String constant (reference count)
               dq 2                                                ; Length
               db 0dh, 0ah                                         ; line 6 column 11 in file temp.syd
  string$2     dq -01h                                             ; String constant (reference count)
               dq 30                                               ; Length
               db "ERROR! THIS SHOULD NOT PRINT", 0dh, 0ah         ; line 9 column 40 in file temp.syd

.code

public main
main:
  ; rtl
  ; ===
  ; Prolog
  push rbp                                                         ; save volatile registers
  lea rbp, [rsp+000h]                                              ; set up frame pointer
  ; Epilog
  pop rbp                                                          ; restore volatile registers

  ; temp.syd
  ; ========
  ; Prolog
  push rbp                                                         ; save volatile registers
  sub rsp, 0f0h                                                    ; allocate space for stack
  lea rbp, [rsp+0f0h]                                              ; set up frame pointer
  ; Line 1: Null test(String message) { ...
  ; Line 4: test('Hello World\r\n');
  mov dword ptr [rbp-008h], 0h                                     ; value of this pointer
  mov dword ptr [rbp-010h], 000000000h                             ; type of this pointer
  mov dword ptr [rbp-018h], 0h                                     ; value of closure pointer
  ; Calling func$test with 1 arguments
  mov r11, offset string                                           ; value of argument #1
  push r11                                                         ; (indirect via r11 because "offset string" cannot be used with push)
  push 000000008h                                                  ; type of argument #1
  lea r11, [rbp-020h]                                              ; pointer to return value (and type, 8 bytes later)
  push r11                                                         ; (that pointer is the last value pushed to the stack)
  lea r9, [rbp-008h]                                               ; pointer to this
  mov r8, [rbp-010h]                                               ; type of this
  lea rdx, [rbp-018h]                                              ; pointer to closure
  mov rcx, 1                                                       ; number of arguments
  sub rsp, 20h                                                     ; allocate shadow space
  call func$test                                                   ; jump to subroutine
  add rsp, 038h                                                    ; release shadow space and arguments
  ; Line 5: test(3 /* 0x3 */);
  mov dword ptr [rbp-030h], 0h                                     ; value of this pointer
  mov dword ptr [rbp-038h], 000000000h                             ; type of this pointer
  mov dword ptr [rbp-040h], 0h                                     ; value of closure pointer
  ; Calling func$test with 1 arguments
  push 000000003h                                                  ; value of argument #1
  push 000000007h                                                  ; type of argument #1
  lea r11, [rbp-048h]                                              ; pointer to return value (and type, 8 bytes later)
  push r11                                                         ; (that pointer is the last value pushed to the stack)
  lea r9, [rbp-030h]                                               ; pointer to this
  mov r8, [rbp-038h]                                               ; type of this
  lea rdx, [rbp-040h]                                              ; pointer to closure
  mov rcx, 1                                                       ; number of arguments
  sub rsp, 20h                                                     ; allocate shadow space
  call func$test                                                   ; jump to subroutine
  add rsp, 038h                                                    ; release shadow space and arguments
  ; Line 6: test('\r\n');
  mov dword ptr [rbp-058h], 0h                                     ; value of this pointer
  mov dword ptr [rbp-060h], 000000000h                             ; type of this pointer
  mov dword ptr [rbp-068h], 0h                                     ; value of closure pointer
  ; Calling func$test with 1 arguments
  mov r11, offset string$1                                         ; value of argument #1
  push r11                                                         ; (indirect via r11 because "offset string$1" cannot be used with push)
  push 000000008h                                                  ; type of argument #1
  lea r11, [rbp-070h]                                              ; pointer to return value (and type, 8 bytes later)
  push r11                                                         ; (that pointer is the last value pushed to the stack)
  lea r9, [rbp-058h]                                               ; pointer to this
  mov r8, [rbp-060h]                                               ; type of this
  lea rdx, [rbp-068h]                                              ; pointer to closure
  mov rcx, 1                                                       ; number of arguments
  sub rsp, 20h                                                     ; allocate shadow space
  call func$test                                                   ; jump to subroutine
  add rsp, 038h                                                    ; release shadow space and arguments
  ; Line 7: exit(3 /* 0x3 */);
  mov dword ptr [rbp-080h], 0h                                     ; value of this pointer
  mov dword ptr [rbp-088h], 000000000h                             ; type of this pointer
  mov dword ptr [rbp-090h], 0h                                     ; value of closure pointer
  ; Calling func$exit with 1 arguments
  push 000000003h                                                  ; value of argument #1
  push 000000007h                                                  ; type of argument #1
  lea r11, [rbp-098h]                                              ; pointer to return value (and type, 8 bytes later)
  push r11                                                         ; (that pointer is the last value pushed to the stack)
  lea r9, [rbp-080h]                                               ; pointer to this
  mov r8, [rbp-088h]                                               ; type of this
  lea rdx, [rbp-090h]                                              ; pointer to closure
  mov rcx, 1                                                       ; number of arguments
  sub rsp, 20h                                                     ; allocate shadow space
  call func$exit                                                   ; jump to subroutine
  add rsp, 038h                                                    ; release shadow space and arguments
  ; Line 9: print('ERROR! THIS SHOULD NOT PRINT\r\n');
  mov dword ptr [rbp-0a8h], 0h                                     ; value of this pointer
  mov dword ptr [rbp-0b0h], 000000000h                             ; type of this pointer
  mov dword ptr [rbp-0b8h], 0h                                     ; value of closure pointer
  ; Calling func$print with 1 arguments
  mov r11, offset string$2                                         ; value of argument #1
  push r11                                                         ; (indirect via r11 because "offset string$2" cannot be used with push)
  push 000000008h                                                  ; type of argument #1
  lea r11, [rbp-0c0h]                                              ; pointer to return value (and type, 8 bytes later)
  push r11                                                         ; (that pointer is the last value pushed to the stack)
  lea r9, [rbp-0a8h]                                               ; pointer to this
  mov r8, [rbp-0b0h]                                               ; type of this
  lea rdx, [rbp-0b8h]                                              ; pointer to closure
  mov rcx, 1                                                       ; number of arguments
  sub rsp, 20h                                                     ; allocate shadow space
  call func$print                                                  ; jump to subroutine
  add rsp, 038h                                                    ; release shadow space and arguments
  mov dword ptr [rbp-0d0h], 0h                                     ; value of this pointer
  mov dword ptr [rbp-0d8h], 000000000h                             ; type of this pointer
  mov dword ptr [rbp-0e0h], 0h                                     ; value of closure pointer
  ; Calling func$exit with 1 arguments
  push 000000000h                                                  ; value of argument #1
  push 000000007h                                                  ; type of argument #1
  lea r11, [rbp-0e8h]                                              ; pointer to return value (and type, 8 bytes later)
  push r11                                                         ; (that pointer is the last value pushed to the stack)
  lea r9, [rbp-0d0h]                                               ; pointer to this
  mov r8, [rbp-0d8h]                                               ; type of this
  lea rdx, [rbp-0e0h]                                              ; pointer to closure
  mov rcx, 1                                                       ; number of arguments
  sub rsp, 20h                                                     ; allocate shadow space
  call func$exit                                                   ; jump to subroutine
  add rsp, 038h                                                    ; release shadow space and arguments
  ; Epilog
  add rsp, 0f0h                                                    ; free space for stack
  pop rbp                                                          ; restore volatile registers
  ret                                                              ; exit application

; print
func$print:
  ; Prolog
  push rbp                                                         ; save volatile registers
  sub rsp, 0a8h                                                    ; allocate space for stack
  lea rbp, [rsp+0a8h]                                              ; set up frame pointer
  ; Check parameter count
  cmp rcx, 000000001h                                              ; check number of parameters is as expected
  je func$print$paramCountGood                                     ; skip next block if they are equal
    mov dword ptr [rbp-010h], 0h                                   ; value of this pointer
    mov dword ptr [rbp-018h], 000000000h                           ; type of this pointer
    mov dword ptr [rbp-020h], 0h                                   ; value of closure pointer
    ; Calling func$print with 1 arguments
    mov r11, offset parameterCountCheckFailureMessage              ; value of argument #1
    push r11                                                       ; (indirect via r11 because "offset parameterCountCheckFailureMessage" cannot be used with push)
    push 000000008h                                                ; type of argument #1
    lea r11, [rbp-028h]                                            ; pointer to return value (and type, 8 bytes later)
    push r11                                                       ; (that pointer is the last value pushed to the stack)
    lea r9, [rbp-010h]                                             ; pointer to this
    mov r8, [rbp-018h]                                             ; type of this
    lea rdx, [rbp-020h]                                            ; pointer to closure
    mov rcx, 1                                                     ; number of arguments
    sub rsp, 20h                                                   ; allocate shadow space
    call func$print                                                ; jump to subroutine
    add rsp, 038h                                                  ; release shadow space and arguments
    mov dword ptr [rbp-038h], 0h                                   ; value of this pointer
    mov dword ptr [rbp-040h], 000000000h                           ; type of this pointer
    mov dword ptr [rbp-048h], 0h                                   ; value of closure pointer
    ; Calling func$exit with 1 arguments
    push 000000001h                                                ; value of argument #1
    push 000000007h                                                ; type of argument #1
    lea r11, [rbp-050h]                                            ; pointer to return value (and type, 8 bytes later)
    push r11                                                       ; (that pointer is the last value pushed to the stack)
    lea r9, [rbp-038h]                                             ; pointer to this
    mov r8, [rbp-040h]                                             ; type of this
    lea rdx, [rbp-048h]                                            ; pointer to closure
    mov rcx, 1                                                     ; number of arguments
    sub rsp, 20h                                                   ; allocate shadow space
    call func$exit                                                 ; jump to subroutine
    add rsp, 038h                                                  ; release shadow space and arguments
  func$print$paramCountGood:
  ; Check type of parameter 0, message to print to console (expecting String)
  mov rax, [rbp+038h]                                              ; load the dynamic type of message to print to console into rax
  lea r10, typeTable                                               ; move type table offset into r10
  add rax, r10                                                     ; adjust rax to point to the type table
  bt dword ptr [rax], 1                                            ; check that message to print to console is String'8
  jc func$print$param1$TypeGood                                    ; skip next block if the type matches
    mov dword ptr [rbp-060h], 0h                                   ; value of this pointer
    mov dword ptr [rbp-068h], 000000000h                           ; type of this pointer
    mov dword ptr [rbp-070h], 0h                                   ; value of closure pointer
    ; Calling func$print with 1 arguments
    mov r11, offset parameterTypeCheckFailureMessage               ; value of argument #1
    push r11                                                       ; (indirect via r11 because "offset parameterTypeCheckFailureMessage" cannot be used with push)
    push 000000008h                                                ; type of argument #1
    lea r11, [rbp-078h]                                            ; pointer to return value (and type, 8 bytes later)
    push r11                                                       ; (that pointer is the last value pushed to the stack)
    lea r9, [rbp-060h]                                             ; pointer to this
    mov r8, [rbp-068h]                                             ; type of this
    lea rdx, [rbp-070h]                                            ; pointer to closure
    mov rcx, 1                                                     ; number of arguments
    sub rsp, 20h                                                   ; allocate shadow space
    call func$print                                                ; jump to subroutine
    add rsp, 038h                                                  ; release shadow space and arguments
    mov dword ptr [rbp-088h], 0h                                   ; value of this pointer
    mov dword ptr [rbp-090h], 000000000h                           ; type of this pointer
    mov dword ptr [rbp-098h], 0h                                   ; value of closure pointer
    ; Calling func$exit with 1 arguments
    push 000000001h                                                ; value of argument #1
    push 000000007h                                                ; type of argument #1
    lea r11, [rbp-0a0h]                                            ; pointer to return value (and type, 8 bytes later)
    push r11                                                       ; (that pointer is the last value pushed to the stack)
    lea r9, [rbp-088h]                                             ; pointer to this
    mov r8, [rbp-090h]                                             ; type of this
    lea rdx, [rbp-098h]                                            ; pointer to closure
    mov rcx, 1                                                     ; number of arguments
    sub rsp, 20h                                                   ; allocate shadow space
    call func$exit                                                 ; jump to subroutine
    add rsp, 038h                                                  ; release shadow space and arguments
  func$print$param1$TypeGood:
  ; Calling GetStdHandle
  mov rcx, -11                                                     ; argument #1: STD_OUTPUT_HANDLE
  call GetStdHandle                                                ; handle returned in rax
  ; Calling WriteConsoleA
  push 0                                                           ; argument #5: Reserved, must be NULL (lpReserved)
  lea r9, [rbp-008h]                                               ; argument #4: Number of characters written (lpNumberOfCharsWritten)
  mov r10, [rbp+040h]                                              ; get address of string structure
  mov r8, [r10+08h]                                                ; argument #3: Length of buffer (nNumberOfCharsToWrite), from string structure
  lea rdx, [r10+10h]                                               ; argument #2: Pointer to buffer to write (*lpBuffer)
  mov rcx, rax                                                     ; argument #1: Handle from GetStdHandle (hConsoleOutput)
  sub rsp, 20h                                                     ; allocate shadow space
  call WriteConsoleA                                               ; returns boolean representing success in rax
  add rsp, 28h                                                     ; release shadow space and arguments
  ; Epilog
  add rsp, 0a8h                                                    ; free space for stack
  pop rbp                                                          ; restore volatile registers
  ret                                                              ; return from subroutine

; exit
func$exit:
  ; Prolog
  push rbp                                                         ; save volatile registers
  sub rsp, 0a0h                                                    ; allocate space for stack
  lea rbp, [rsp+0a0h]                                              ; set up frame pointer
  ; Check parameter count
  cmp rcx, 000000001h                                              ; check number of parameters is as expected
  je func$exit$paramCountGood                                      ; skip next block if they are equal
    mov dword ptr [rbp-008h], 0h                                   ; value of this pointer
    mov dword ptr [rbp-010h], 000000000h                           ; type of this pointer
    mov dword ptr [rbp-018h], 0h                                   ; value of closure pointer
    ; Calling func$print with 1 arguments
    mov r11, offset parameterCountCheckFailureMessage              ; value of argument #1
    push r11                                                       ; (indirect via r11 because "offset parameterCountCheckFailureMessage" cannot be used with push)
    push 000000008h                                                ; type of argument #1
    lea r11, [rbp-020h]                                            ; pointer to return value (and type, 8 bytes later)
    push r11                                                       ; (that pointer is the last value pushed to the stack)
    lea r9, [rbp-008h]                                             ; pointer to this
    mov r8, [rbp-010h]                                             ; type of this
    lea rdx, [rbp-018h]                                            ; pointer to closure
    mov rcx, 1                                                     ; number of arguments
    sub rsp, 20h                                                   ; allocate shadow space
    call func$print                                                ; jump to subroutine
    add rsp, 038h                                                  ; release shadow space and arguments
    mov dword ptr [rbp-030h], 0h                                   ; value of this pointer
    mov dword ptr [rbp-038h], 000000000h                           ; type of this pointer
    mov dword ptr [rbp-040h], 0h                                   ; value of closure pointer
    ; Calling func$exit with 1 arguments
    push 000000001h                                                ; value of argument #1
    push 000000007h                                                ; type of argument #1
    lea r11, [rbp-048h]                                            ; pointer to return value (and type, 8 bytes later)
    push r11                                                       ; (that pointer is the last value pushed to the stack)
    lea r9, [rbp-030h]                                             ; pointer to this
    mov r8, [rbp-038h]                                             ; type of this
    lea rdx, [rbp-040h]                                            ; pointer to closure
    mov rcx, 1                                                     ; number of arguments
    sub rsp, 20h                                                   ; allocate shadow space
    call func$exit                                                 ; jump to subroutine
    add rsp, 038h                                                  ; release shadow space and arguments
  func$exit$paramCountGood:
  ; Check type of parameter 0, exit code parameter (expecting Integer)
  mov rax, [rbp+038h]                                              ; load the dynamic type of exit code parameter into rax
  lea r10, typeTable                                               ; move type table offset into r10
  add rax, r10                                                     ; adjust rax to point to the type table
  bt dword ptr [rax], 0                                            ; check that exit code parameter is Integer'7
  jc func$exit$param1$TypeGood                                     ; skip next block if the type matches
    mov dword ptr [rbp-058h], 0h                                   ; value of this pointer
    mov dword ptr [rbp-060h], 000000000h                           ; type of this pointer
    mov dword ptr [rbp-068h], 0h                                   ; value of closure pointer
    ; Calling func$print with 1 arguments
    mov r11, offset parameterTypeCheckFailureMessage               ; value of argument #1
    push r11                                                       ; (indirect via r11 because "offset parameterTypeCheckFailureMessage" cannot be used with push)
    push 000000008h                                                ; type of argument #1
    lea r11, [rbp-070h]                                            ; pointer to return value (and type, 8 bytes later)
    push r11                                                       ; (that pointer is the last value pushed to the stack)
    lea r9, [rbp-058h]                                             ; pointer to this
    mov r8, [rbp-060h]                                             ; type of this
    lea rdx, [rbp-068h]                                            ; pointer to closure
    mov rcx, 1                                                     ; number of arguments
    sub rsp, 20h                                                   ; allocate shadow space
    call func$print                                                ; jump to subroutine
    add rsp, 038h                                                  ; release shadow space and arguments
    mov dword ptr [rbp-080h], 0h                                   ; value of this pointer
    mov dword ptr [rbp-088h], 000000000h                           ; type of this pointer
    mov dword ptr [rbp-090h], 0h                                   ; value of closure pointer
    ; Calling func$exit with 1 arguments
    push 000000001h                                                ; value of argument #1
    push 000000007h                                                ; type of argument #1
    lea r11, [rbp-098h]                                            ; pointer to return value (and type, 8 bytes later)
    push r11                                                       ; (that pointer is the last value pushed to the stack)
    lea r9, [rbp-080h]                                             ; pointer to this
    mov r8, [rbp-088h]                                             ; type of this
    lea rdx, [rbp-090h]                                            ; pointer to closure
    mov rcx, 1                                                     ; number of arguments
    sub rsp, 20h                                                   ; allocate shadow space
    call func$exit                                                 ; jump to subroutine
    add rsp, 038h                                                  ; release shadow space and arguments
  func$exit$param1$TypeGood:
  ; Calling ExitProcess
  mov rcx, [rbp+040h]                                              ; exit code
  sub rsp, 20h                                                     ; allocate shadow space
  call ExitProcess                                                 ; process should terminate at this point
  add rsp, 20h                                                     ; release shadow space
  ; Epilog
  add rsp, 0a0h                                                    ; free space for stack
  pop rbp                                                          ; restore volatile registers
  ret                                                              ; return from subroutine

; test
func$test:
  ; Prolog
  push rbp                                                         ; save volatile registers
  sub rsp, 0c8h                                                    ; allocate space for stack
  lea rbp, [rsp+0c8h]                                              ; set up frame pointer
  ; Check parameter count
  cmp rcx, 000000001h                                              ; check number of parameters is as expected
  je func$test$paramCountGood                                      ; skip next block if they are equal
    mov dword ptr [rbp-008h], 0h                                   ; value of this pointer
    mov dword ptr [rbp-010h], 000000000h                           ; type of this pointer
    mov dword ptr [rbp-018h], 0h                                   ; value of closure pointer
    ; Calling func$print with 1 arguments
    mov r11, offset parameterCountCheckFailureMessage              ; value of argument #1
    push r11                                                       ; (indirect via r11 because "offset parameterCountCheckFailureMessage" cannot be used with push)
    push 000000008h                                                ; type of argument #1
    lea r11, [rbp-020h]                                            ; pointer to return value (and type, 8 bytes later)
    push r11                                                       ; (that pointer is the last value pushed to the stack)
    lea r9, [rbp-008h]                                             ; pointer to this
    mov r8, [rbp-010h]                                             ; type of this
    lea rdx, [rbp-018h]                                            ; pointer to closure
    mov rcx, 1                                                     ; number of arguments
    sub rsp, 20h                                                   ; allocate shadow space
    call func$print                                                ; jump to subroutine
    add rsp, 038h                                                  ; release shadow space and arguments
    mov dword ptr [rbp-030h], 0h                                   ; value of this pointer
    mov dword ptr [rbp-038h], 000000000h                           ; type of this pointer
    mov dword ptr [rbp-040h], 0h                                   ; value of closure pointer
    ; Calling func$exit with 1 arguments
    push 000000001h                                                ; value of argument #1
    push 000000007h                                                ; type of argument #1
    lea r11, [rbp-048h]                                            ; pointer to return value (and type, 8 bytes later)
    push r11                                                       ; (that pointer is the last value pushed to the stack)
    lea r9, [rbp-030h]                                             ; pointer to this
    mov r8, [rbp-038h]                                             ; type of this
    lea rdx, [rbp-040h]                                            ; pointer to closure
    mov rcx, 1                                                     ; number of arguments
    sub rsp, 20h                                                   ; allocate shadow space
    call func$exit                                                 ; jump to subroutine
    add rsp, 038h                                                  ; release shadow space and arguments
  func$test$paramCountGood:
  ; Check type of parameter 0, message (expecting String)
  mov rax, [rbp+038h]                                              ; load the dynamic type of message into rax
  lea r10, typeTable                                               ; move type table offset into r10
  add rax, r10                                                     ; adjust rax to point to the type table
  bt dword ptr [rax], 1                                            ; check that message is String'8
  jc func$test$param1$TypeGood                                     ; skip next block if the type matches
    mov dword ptr [rbp-058h], 0h                                   ; value of this pointer
    mov dword ptr [rbp-060h], 000000000h                           ; type of this pointer
    mov dword ptr [rbp-068h], 0h                                   ; value of closure pointer
    ; Calling func$print with 1 arguments
    mov r11, offset parameterTypeCheckFailureMessage               ; value of argument #1
    push r11                                                       ; (indirect via r11 because "offset parameterTypeCheckFailureMessage" cannot be used with push)
    push 000000008h                                                ; type of argument #1
    lea r11, [rbp-070h]                                            ; pointer to return value (and type, 8 bytes later)
    push r11                                                       ; (that pointer is the last value pushed to the stack)
    lea r9, [rbp-058h]                                             ; pointer to this
    mov r8, [rbp-060h]                                             ; type of this
    lea rdx, [rbp-068h]                                            ; pointer to closure
    mov rcx, 1                                                     ; number of arguments
    sub rsp, 20h                                                   ; allocate shadow space
    call func$print                                                ; jump to subroutine
    add rsp, 038h                                                  ; release shadow space and arguments
    mov dword ptr [rbp-080h], 0h                                   ; value of this pointer
    mov dword ptr [rbp-088h], 000000000h                           ; type of this pointer
    mov dword ptr [rbp-090h], 0h                                   ; value of closure pointer
    ; Calling func$exit with 1 arguments
    push 000000001h                                                ; value of argument #1
    push 000000007h                                                ; type of argument #1
    lea r11, [rbp-098h]                                            ; pointer to return value (and type, 8 bytes later)
    push r11                                                       ; (that pointer is the last value pushed to the stack)
    lea r9, [rbp-080h]                                             ; pointer to this
    mov r8, [rbp-088h]                                             ; type of this
    lea rdx, [rbp-090h]                                            ; pointer to closure
    mov rcx, 1                                                     ; number of arguments
    sub rsp, 20h                                                   ; allocate shadow space
    call func$exit                                                 ; jump to subroutine
    add rsp, 038h                                                  ; release shadow space and arguments
  func$test$param1$TypeGood:
  ; Line 2: print(message);
  mov dword ptr [rbp-0a8h], 0h                                     ; value of this pointer
  mov dword ptr [rbp-0b0h], 000000000h                             ; type of this pointer
  mov dword ptr [rbp-0b8h], 0h                                     ; value of closure pointer
  ; Calling func$print with 1 arguments
  push [rbp+040h]                                                  ; value of argument #1
  push [rbp+038h]                                                  ; type of argument #1
  lea r11, [rbp-0c0h]                                              ; pointer to return value (and type, 8 bytes later)
  push r11                                                         ; (that pointer is the last value pushed to the stack)
  lea r9, [rbp-0a8h]                                               ; pointer to this
  mov r8, [rbp-0b0h]                                               ; type of this
  lea rdx, [rbp-0b8h]                                              ; pointer to closure
  mov rcx, 1                                                       ; number of arguments
  sub rsp, 20h                                                     ; allocate shadow space
  call func$print                                                  ; jump to subroutine
  add rsp, 038h                                                    ; release shadow space and arguments
  ; Epilog
  add rsp, 0c8h                                                    ; free space for stack
  pop rbp                                                          ; restore volatile registers
  ret                                                              ; return from subroutine


end

