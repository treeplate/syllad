_drectve segment info alias(".drectve")
  db ' /ENTRY:main '
_drectve ends
option casemap:none

; includes
includelib kernel32.lib

; externs
extern GetStdHandle : proc
extern WriteConsoleA : proc
extern ExitProcess : proc

.const
  typeTable    db 003h, 000h, 000h, 000h, 000h, 000h, 000h, 000h, 001h, 002h, 000h, 000h, 000h, 000h, 000h, 000h ; Type table
   ; Columns: Integer'8 String'9
   ; 1 1   <sentinel>'0
   ; 0 0   Null'1
   ; 0 0   Boolean'2
   ; 0 0   NullFunction(String)'3
   ; 0 0   NullFunction(Integer)'4
   ; 0 0   IntegerFunction(WhateverReadOnlyList)'5
   ; 0 0   IntegerFunction(Integer)'6
   ; 0 0   IntegerFunction(String)'7
   ; 1 0   Integer'8
   ; 0 1   String'9

  parameterCountCheckFailureMessage dq -01h                      ; String constant (reference count)
               dq 88                                             ; Length
               db "error: function call received the wrong number of parameters (expected %d, received %d)", 0ah ; line 206 column 25 in file syd-compiler.syd
               db 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h         ; padding to align to 8-byte boundary
  parameterTypeCheckFailureMessage dq -01h                       ; String constant (reference count)
               dq 71                                             ; Length
               db "error: type mismatch for function %s parameter %d, expected %s, got %s", 0ah ; line 211 column 25 in file syd-compiler.syd
               db 00h                                            ; padding to align to 8-byte boundary
  returnValueTypeCheckFailureMessage dq -01h                     ; String constant (reference count)
               dq 68                                             ; Length
               db "error: type mismatch for function return value, expected %s, got %s", 0ah ; line 216 column 25 in file syd-compiler.syd
               db 00h, 00h, 00h, 00h                             ; padding to align to 8-byte boundary
  operandTypeCheckFailureMessage dq -01h                         ; String constant (reference count)
               dq 54                                             ; Length
               db "error: type mismatch for operand, expected %s, got %s", 0ah ; line 221 column 25 in file syd-compiler.syd
               db 00h, 00h                                       ; padding to align to 8-byte boundary
  asOperatorFailureMessage dq -01h                               ; String constant (reference count)
               dq 58                                             ; Length
               db "error: type mismatch for as operator, expected %s, got %s", 0ah ; line 226 column 25 in file syd-compiler.syd
               db 00h, 00h, 00h, 00h, 00h, 00h                   ; padding to align to 8-byte boundary
  boundsFailureMessage dq -01h                                   ; String constant (reference count)
               dq 64                                             ; Length
               db "error: subscript index out of range (%d is not in range %d..%d)", 0ah ; line 231 column 25 in file syd-compiler.syd
               db 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h         ; padding to align to 8-byte boundary
  string       dq -01h                                           ; String constant (reference count)
               dq 5                                              ; Length
               db "hello"                                        ; line 3 column 18 in file temp.syd
               db 00h, 00h, 00h                                  ; padding to align to 8-byte boundary

.data


_BSS segment


.code

public main
main:
  ; intrinsics
  ; ==========
  ; Prolog
  push rbp                                                       ; save non-volatile registers
  lea rbp, [rsp+000h]                                            ; set up frame pointer
  ; Epilog
  pop rbp                                                        ; restore non-volatile registers

  ; runtime library
  ; ===============
  ; Prolog
  push rbp                                                       ; save non-volatile registers
  lea rbp, [rsp+000h]                                            ; set up frame pointer
  ; Epilog
  pop rbp                                                        ; restore non-volatile registers

  ; temp.syd
  ; ========
  ; Prolog
  push rbp                                                       ; save non-volatile registers
  sub rsp, 078h                                                  ; allocate space for stack
  lea rbp, [rsp+078h]                                            ; set up frame pointer
  ; Line 10: Integer stringLength = _stringAllocLength(s);
  mov qword ptr [rbp-008h], 0h                                   ; value of this pointer for function call (placeholder)
  mov qword ptr [rbp-010h], 000000000h                           ; type of this pointer for function call (placeholder)
  mov qword ptr [rbp-018h], 0h                                   ; value of closure pointer for function call (placeholder)
  mov [rbp+010h], rcx                                            ; save rcx in shadow space
  mov [rbp+018h], rdx                                            ; save rdx in shadow space
  mov [rbp+020h], r8                                             ; save r8 in shadow space
  mov [rbp+028h], r9                                             ; save r9 in shadow space
  mov r11, offset string                                         ; value of argument #1
  push r11                                                       ; (indirect via r11 because "string" is an imm64)
  push 000000009h                                                ; type of argument #1
  lea r10, [rbp-020h]                                            ; pointer to return value (and type, 8 bytes earlier)
  push r10                                                       ; (that pointer is the last value pushed to the stack)
  lea r9, [rbp-008h]                                             ; pointer to this
  mov r8, [rbp-010h]                                             ; type of this
  lea rdx, [rbp-018h]                                            ; pointer to closure
  mov rcx, 1                                                     ; number of arguments
  sub rsp, 20h                                                   ; allocate shadow space
  call offset func$_stringAllocLength                            ; jump to subroutine
  add rsp, 038h                                                  ; release shadow space and arguments
  mov rcx, [rbp+010h]                                            ; restore rcx from shadow space
  mov rdx, [rbp+018h]                                            ; restore rdx from shadow space
  mov r8, [rbp+020h]                                             ; restore r8 from shadow space
  mov r9, [rbp+028h]                                             ; restore r9 from shadow space
  ; Line 12: exit(stringLength);
  mov qword ptr [rbp-030h], 0h                                   ; value of this pointer for function call (placeholder)
  mov qword ptr [rbp-038h], 000000000h                           ; type of this pointer for function call (placeholder)
  mov qword ptr [rbp-040h], 0h                                   ; value of closure pointer for function call (placeholder)
  mov [rbp+010h], rcx                                            ; save rcx in shadow space
  mov [rbp+018h], rdx                                            ; save rdx in shadow space
  mov [rbp+020h], r8                                             ; save r8 in shadow space
  mov [rbp+028h], r9                                             ; save r9 in shadow space
  push [rbp-020h]                                                ; value of argument #1
  push [rbp-028h]                                                ; type of argument #1
  lea r10, [rbp-048h]                                            ; pointer to return value (and type, 8 bytes earlier)
  push r10                                                       ; (that pointer is the last value pushed to the stack)
  lea r9, [rbp-030h]                                             ; pointer to this
  mov r8, [rbp-038h]                                             ; type of this
  lea rdx, [rbp-040h]                                            ; pointer to closure
  mov rcx, 1                                                     ; number of arguments
  sub rsp, 20h                                                   ; allocate shadow space
  call offset func$exit                                          ; jump to subroutine
  add rsp, 038h                                                  ; release shadow space and arguments
  mov rcx, [rbp+010h]                                            ; restore rcx from shadow space
  mov rdx, [rbp+018h]                                            ; restore rdx from shadow space
  mov r8, [rbp+020h]                                             ; restore r8 from shadow space
  mov r9, [rbp+028h]                                             ; restore r9 from shadow space
  ; Terminate application - call exit(0)
  mov qword ptr [rbp-058h], 0h                                   ; value of this pointer for function call (placeholder)
  mov qword ptr [rbp-060h], 000000000h                           ; type of this pointer for function call (placeholder)
  mov qword ptr [rbp-068h], 0h                                   ; value of closure pointer for function call (placeholder)
  mov [rbp+010h], rcx                                            ; save rcx in shadow space
  mov [rbp+018h], rdx                                            ; save rdx in shadow space
  mov [rbp+020h], r8                                             ; save r8 in shadow space
  mov [rbp+028h], r9                                             ; save r9 in shadow space
  push 000000000h                                                ; value of argument #1
  push 000000008h                                                ; type of argument #1
  lea r10, [rbp-070h]                                            ; pointer to return value (and type, 8 bytes earlier)
  push r10                                                       ; (that pointer is the last value pushed to the stack)
  lea r9, [rbp-058h]                                             ; pointer to this
  mov r8, [rbp-060h]                                             ; type of this
  lea rdx, [rbp-068h]                                            ; pointer to closure
  mov rcx, 1                                                     ; number of arguments
  sub rsp, 20h                                                   ; allocate shadow space
  call offset func$exit                                          ; jump to subroutine
  add rsp, 038h                                                  ; release shadow space and arguments
  mov rcx, [rbp+010h]                                            ; restore rcx from shadow space
  mov rdx, [rbp+018h]                                            ; restore rdx from shadow space
  mov r8, [rbp+020h]                                             ; restore r8 from shadow space
  mov r9, [rbp+028h]                                             ; restore r9 from shadow space
  ; Epilog
  add rsp, 078h                                                  ; free space for stack
  pop rbp                                                        ; restore non-volatile registers
  ; End of global scope
  ret                                                            ; exit application

; print
func$print:
  ; Prolog
  push rbp                                                       ; save non-volatile registers
  push r15                                                       ; save non-volatile registers
  sub rsp, 0a8h                                                  ; allocate space for stack
  lea rbp, [rsp+0a8h]                                            ; set up frame pointer
  mov r15, [rbp+038h]                                            ; prepare return value
  ; Check parameter count
  cmp qword ptr rcx, 000000001h                                  ; compare parameter count to integers
  je func$print$parameterCount$continuation                      ; check number of parameters is as expected
    ; Error handling block for parameter count
    ;  - print(parameterCountCheckFailureMessage)
    mov qword ptr [rbp-010h], 0h                                 ; value of this pointer for function call (placeholder)
    mov qword ptr [rbp-018h], 000000000h                         ; type of this pointer for function call (placeholder)
    mov qword ptr [rbp-020h], 0h                                 ; value of closure pointer for function call (placeholder)
    mov [rbp+018h], rcx                                          ; save rcx in shadow space
    mov [rbp+020h], rdx                                          ; save rdx in shadow space
    mov [rbp+028h], r8                                           ; save r8 in shadow space
    mov [rbp+030h], r9                                           ; save r9 in shadow space
    mov r11, offset parameterCountCheckFailureMessage            ; value of argument #1
    push r11                                                     ; (indirect via r11 because "parameterCountCheckFailureMessage" is an imm64)
    push 000000009h                                              ; type of argument #1
    lea r10, [rbp-028h]                                          ; pointer to return value (and type, 8 bytes earlier)
    push r10                                                     ; (that pointer is the last value pushed to the stack)
    lea r9, [rbp-010h]                                           ; pointer to this
    mov r8, [rbp-018h]                                           ; type of this
    lea rdx, [rbp-020h]                                          ; pointer to closure
    mov rcx, 1                                                   ; number of arguments
    sub rsp, 20h                                                 ; allocate shadow space
    call offset func$print                                       ; jump to subroutine
    add rsp, 038h                                                ; release shadow space and arguments
    mov rcx, [rbp+018h]                                          ; restore rcx from shadow space
    mov rdx, [rbp+020h]                                          ; restore rdx from shadow space
    mov r8, [rbp+028h]                                           ; restore r8 from shadow space
    mov r9, [rbp+030h]                                           ; restore r9 from shadow space
    ;  - exit(1)
    mov qword ptr [rbp-038h], 0h                                 ; value of this pointer for function call (placeholder)
    mov qword ptr [rbp-040h], 000000000h                         ; type of this pointer for function call (placeholder)
    mov qword ptr [rbp-048h], 0h                                 ; value of closure pointer for function call (placeholder)
    mov [rbp+018h], rcx                                          ; save rcx in shadow space
    mov [rbp+020h], rdx                                          ; save rdx in shadow space
    mov [rbp+028h], r8                                           ; save r8 in shadow space
    mov [rbp+030h], r9                                           ; save r9 in shadow space
    push 000000001h                                              ; value of argument #1
    push 000000008h                                              ; type of argument #1
    lea r10, [rbp-050h]                                          ; pointer to return value (and type, 8 bytes earlier)
    push r10                                                     ; (that pointer is the last value pushed to the stack)
    lea r9, [rbp-038h]                                           ; pointer to this
    mov r8, [rbp-040h]                                           ; type of this
    lea rdx, [rbp-048h]                                          ; pointer to closure
    mov rcx, 1                                                   ; number of arguments
    sub rsp, 20h                                                 ; allocate shadow space
    call offset func$exit                                        ; jump to subroutine
    add rsp, 038h                                                ; release shadow space and arguments
    mov rcx, [rbp+018h]                                          ; restore rcx from shadow space
    mov rdx, [rbp+020h]                                          ; restore rdx from shadow space
    mov r8, [rbp+028h]                                           ; restore r8 from shadow space
    mov r9, [rbp+030h]                                           ; restore r9 from shadow space
  func$print$parameterCount$continuation:                        ; end of parameter count
  ; Check type of parameter 0, message to print to console (expecting String)
  mov rax, [rbp+040h]                                            ; load the dynamic type of message to print to console into rax
  lea r10, typeTable                                             ; move type table offset into r10
  add rax, r10                                                   ; adjust rax to point to the type table
  bt qword ptr [rax], 1                                          ; check that message to print to console is String'9
  jc func$print$messageToPrintToConsole$TypeMatch                ; skip next block if the type matches
    ; Error handling block for message to print to console
    ;  - print(parameterTypeCheckFailureMessage)
    mov qword ptr [rbp-060h], 0h                                 ; value of this pointer for function call (placeholder)
    mov qword ptr [rbp-068h], 000000000h                         ; type of this pointer for function call (placeholder)
    mov qword ptr [rbp-070h], 0h                                 ; value of closure pointer for function call (placeholder)
    mov [rbp+018h], rcx                                          ; save rcx in shadow space
    mov [rbp+020h], rdx                                          ; save rdx in shadow space
    mov [rbp+028h], r8                                           ; save r8 in shadow space
    mov [rbp+030h], r9                                           ; save r9 in shadow space
    mov r11, offset parameterTypeCheckFailureMessage             ; value of argument #1
    push r11                                                     ; (indirect via r11 because "parameterTypeCheckFailureMessage" is an imm64)
    push 000000009h                                              ; type of argument #1
    lea r10, [rbp-078h]                                          ; pointer to return value (and type, 8 bytes earlier)
    push r10                                                     ; (that pointer is the last value pushed to the stack)
    lea r9, [rbp-060h]                                           ; pointer to this
    mov r8, [rbp-068h]                                           ; type of this
    lea rdx, [rbp-070h]                                          ; pointer to closure
    mov rcx, 1                                                   ; number of arguments
    sub rsp, 20h                                                 ; allocate shadow space
    call offset func$print                                       ; jump to subroutine
    add rsp, 038h                                                ; release shadow space and arguments
    mov rcx, [rbp+018h]                                          ; restore rcx from shadow space
    mov rdx, [rbp+020h]                                          ; restore rdx from shadow space
    mov r8, [rbp+028h]                                           ; restore r8 from shadow space
    mov r9, [rbp+030h]                                           ; restore r9 from shadow space
    ;  - exit(1)
    mov qword ptr [rbp-088h], 0h                                 ; value of this pointer for function call (placeholder)
    mov qword ptr [rbp-090h], 000000000h                         ; type of this pointer for function call (placeholder)
    mov qword ptr [rbp-098h], 0h                                 ; value of closure pointer for function call (placeholder)
    mov [rbp+018h], rcx                                          ; save rcx in shadow space
    mov [rbp+020h], rdx                                          ; save rdx in shadow space
    mov [rbp+028h], r8                                           ; save r8 in shadow space
    mov [rbp+030h], r9                                           ; save r9 in shadow space
    push 000000001h                                              ; value of argument #1
    push 000000008h                                              ; type of argument #1
    lea r10, [rbp-0a0h]                                          ; pointer to return value (and type, 8 bytes earlier)
    push r10                                                     ; (that pointer is the last value pushed to the stack)
    lea r9, [rbp-088h]                                           ; pointer to this
    mov r8, [rbp-090h]                                           ; type of this
    lea rdx, [rbp-098h]                                          ; pointer to closure
    mov rcx, 1                                                   ; number of arguments
    sub rsp, 20h                                                 ; allocate shadow space
    call offset func$exit                                        ; jump to subroutine
    add rsp, 038h                                                ; release shadow space and arguments
    mov rcx, [rbp+018h]                                          ; restore rcx from shadow space
    mov rdx, [rbp+020h]                                          ; restore rdx from shadow space
    mov r8, [rbp+028h]                                           ; restore r8 from shadow space
    mov r9, [rbp+030h]                                           ; restore r9 from shadow space
  func$print$messageToPrintToConsole$TypeMatch:
  ; Calling GetStdHandle
  mov rcx, -11                                                   ; argument #1: STD_OUTPUT_HANDLE
  call GetStdHandle                                              ; handle returned in rax
  ; Calling WriteConsoleA
  push 0                                                         ; argument #5: Reserved, must be NULL (lpReserved)
  lea r9, [rbp-008h]                                             ; argument #4: Number of characters written (lpNumberOfCharsWritten)
  mov r10, [rbp+048h]                                            ; get address of string structure
  mov r8, [r10+08h]                                              ; argument #3: Length of buffer (nNumberOfCharsToWrite), from string structure
  lea rdx, [r10+10h]                                             ; argument #2: Pointer to buffer to write (*lpBuffer)
  mov rcx, rax                                                   ; argument #1: Handle from GetStdHandle (hConsoleOutput)
  sub rsp, 20h                                                   ; allocate shadow space
  call WriteConsoleA                                             ; returns boolean representing success in rax
  add rsp, 28h                                                   ; release shadow space and arguments
  func$print$epilog:
  mov rax, r15                                                   ; report address of return value
  ; Epilog
  add rsp, 0a8h                                                  ; free space for stack
  pop r15                                                        ; restore non-volatile registers
  pop rbp                                                        ; restore non-volatile registers
  ret                                                            ; return from subroutine

; exit
func$exit:
  ; Prolog
  push rbp                                                       ; save non-volatile registers
  push r15                                                       ; save non-volatile registers
  sub rsp, 0a0h                                                  ; allocate space for stack
  lea rbp, [rsp+0a0h]                                            ; set up frame pointer
  mov r15, [rbp+038h]                                            ; prepare return value
  ; Check parameter count
  cmp qword ptr rcx, 000000001h                                  ; compare parameter count to integers
  je func$exit$parameterCount$continuation                       ; check number of parameters is as expected
    ; Error handling block for parameter count
    ;  - print(parameterCountCheckFailureMessage)
    mov qword ptr [rbp-008h], 0h                                 ; value of this pointer for function call (placeholder)
    mov qword ptr [rbp-010h], 000000000h                         ; type of this pointer for function call (placeholder)
    mov qword ptr [rbp-018h], 0h                                 ; value of closure pointer for function call (placeholder)
    mov [rbp+018h], rcx                                          ; save rcx in shadow space
    mov [rbp+020h], rdx                                          ; save rdx in shadow space
    mov [rbp+028h], r8                                           ; save r8 in shadow space
    mov [rbp+030h], r9                                           ; save r9 in shadow space
    mov r11, offset parameterCountCheckFailureMessage            ; value of argument #1
    push r11                                                     ; (indirect via r11 because "parameterCountCheckFailureMessage" is an imm64)
    push 000000009h                                              ; type of argument #1
    lea r10, [rbp-020h]                                          ; pointer to return value (and type, 8 bytes earlier)
    push r10                                                     ; (that pointer is the last value pushed to the stack)
    lea r9, [rbp-008h]                                           ; pointer to this
    mov r8, [rbp-010h]                                           ; type of this
    lea rdx, [rbp-018h]                                          ; pointer to closure
    mov rcx, 1                                                   ; number of arguments
    sub rsp, 20h                                                 ; allocate shadow space
    call offset func$print                                       ; jump to subroutine
    add rsp, 038h                                                ; release shadow space and arguments
    mov rcx, [rbp+018h]                                          ; restore rcx from shadow space
    mov rdx, [rbp+020h]                                          ; restore rdx from shadow space
    mov r8, [rbp+028h]                                           ; restore r8 from shadow space
    mov r9, [rbp+030h]                                           ; restore r9 from shadow space
    ;  - exit(1)
    mov qword ptr [rbp-030h], 0h                                 ; value of this pointer for function call (placeholder)
    mov qword ptr [rbp-038h], 000000000h                         ; type of this pointer for function call (placeholder)
    mov qword ptr [rbp-040h], 0h                                 ; value of closure pointer for function call (placeholder)
    mov [rbp+018h], rcx                                          ; save rcx in shadow space
    mov [rbp+020h], rdx                                          ; save rdx in shadow space
    mov [rbp+028h], r8                                           ; save r8 in shadow space
    mov [rbp+030h], r9                                           ; save r9 in shadow space
    push 000000001h                                              ; value of argument #1
    push 000000008h                                              ; type of argument #1
    lea r10, [rbp-048h]                                          ; pointer to return value (and type, 8 bytes earlier)
    push r10                                                     ; (that pointer is the last value pushed to the stack)
    lea r9, [rbp-030h]                                           ; pointer to this
    mov r8, [rbp-038h]                                           ; type of this
    lea rdx, [rbp-040h]                                          ; pointer to closure
    mov rcx, 1                                                   ; number of arguments
    sub rsp, 20h                                                 ; allocate shadow space
    call offset func$exit                                        ; jump to subroutine
    add rsp, 038h                                                ; release shadow space and arguments
    mov rcx, [rbp+018h]                                          ; restore rcx from shadow space
    mov rdx, [rbp+020h]                                          ; restore rdx from shadow space
    mov r8, [rbp+028h]                                           ; restore r8 from shadow space
    mov r9, [rbp+030h]                                           ; restore r9 from shadow space
  func$exit$parameterCount$continuation:                         ; end of parameter count
  ; Check type of parameter 0, exit code parameter (expecting Integer)
  mov rax, [rbp+040h]                                            ; load the dynamic type of exit code parameter into rax
  lea r10, typeTable                                             ; move type table offset into r10
  add rax, r10                                                   ; adjust rax to point to the type table
  bt qword ptr [rax], 0                                          ; check that exit code parameter is Integer'8
  jc func$exit$exitCodeParameter$TypeMatch                       ; skip next block if the type matches
    ; Error handling block for exit code parameter
    ;  - print(parameterTypeCheckFailureMessage)
    mov qword ptr [rbp-058h], 0h                                 ; value of this pointer for function call (placeholder)
    mov qword ptr [rbp-060h], 000000000h                         ; type of this pointer for function call (placeholder)
    mov qword ptr [rbp-068h], 0h                                 ; value of closure pointer for function call (placeholder)
    mov [rbp+018h], rcx                                          ; save rcx in shadow space
    mov [rbp+020h], rdx                                          ; save rdx in shadow space
    mov [rbp+028h], r8                                           ; save r8 in shadow space
    mov [rbp+030h], r9                                           ; save r9 in shadow space
    mov r11, offset parameterTypeCheckFailureMessage             ; value of argument #1
    push r11                                                     ; (indirect via r11 because "parameterTypeCheckFailureMessage" is an imm64)
    push 000000009h                                              ; type of argument #1
    lea r10, [rbp-070h]                                          ; pointer to return value (and type, 8 bytes earlier)
    push r10                                                     ; (that pointer is the last value pushed to the stack)
    lea r9, [rbp-058h]                                           ; pointer to this
    mov r8, [rbp-060h]                                           ; type of this
    lea rdx, [rbp-068h]                                          ; pointer to closure
    mov rcx, 1                                                   ; number of arguments
    sub rsp, 20h                                                 ; allocate shadow space
    call offset func$print                                       ; jump to subroutine
    add rsp, 038h                                                ; release shadow space and arguments
    mov rcx, [rbp+018h]                                          ; restore rcx from shadow space
    mov rdx, [rbp+020h]                                          ; restore rdx from shadow space
    mov r8, [rbp+028h]                                           ; restore r8 from shadow space
    mov r9, [rbp+030h]                                           ; restore r9 from shadow space
    ;  - exit(1)
    mov qword ptr [rbp-080h], 0h                                 ; value of this pointer for function call (placeholder)
    mov qword ptr [rbp-088h], 000000000h                         ; type of this pointer for function call (placeholder)
    mov qword ptr [rbp-090h], 0h                                 ; value of closure pointer for function call (placeholder)
    mov [rbp+018h], rcx                                          ; save rcx in shadow space
    mov [rbp+020h], rdx                                          ; save rdx in shadow space
    mov [rbp+028h], r8                                           ; save r8 in shadow space
    mov [rbp+030h], r9                                           ; save r9 in shadow space
    push 000000001h                                              ; value of argument #1
    push 000000008h                                              ; type of argument #1
    lea r10, [rbp-098h]                                          ; pointer to return value (and type, 8 bytes earlier)
    push r10                                                     ; (that pointer is the last value pushed to the stack)
    lea r9, [rbp-080h]                                           ; pointer to this
    mov r8, [rbp-088h]                                           ; type of this
    lea rdx, [rbp-090h]                                          ; pointer to closure
    mov rcx, 1                                                   ; number of arguments
    sub rsp, 20h                                                 ; allocate shadow space
    call offset func$exit                                        ; jump to subroutine
    add rsp, 038h                                                ; release shadow space and arguments
    mov rcx, [rbp+018h]                                          ; restore rcx from shadow space
    mov rdx, [rbp+020h]                                          ; restore rdx from shadow space
    mov r8, [rbp+028h]                                           ; restore r8 from shadow space
    mov r9, [rbp+030h]                                           ; restore r9 from shadow space
  func$exit$exitCodeParameter$TypeMatch:
  ; Calling ExitProcess
  mov rcx, [rbp+048h]                                            ; exit code
  sub rsp, 20h                                                   ; allocate shadow space
  call ExitProcess                                               ; process should terminate at this point
  add rsp, 20h                                                   ; release shadow space
  func$exit$epilog:
  mov rax, r15                                                   ; report address of return value
  ; Epilog
  add rsp, 0a0h                                                  ; free space for stack
  pop r15                                                        ; restore non-volatile registers
  pop rbp                                                        ; restore non-volatile registers
  ret                                                            ; return from subroutine

; len
func$len:
  ; Prolog
  push rbp                                                       ; save non-volatile registers
  push r15                                                       ; save non-volatile registers
  lea rbp, [rsp+000h]                                            ; set up frame pointer
  mov r15, [rbp+038h]                                            ; prepare return value
  func$len$epilog:
  mov rax, r15                                                   ; report address of return value
  ; Epilog
  pop r15                                                        ; restore non-volatile registers
  pop rbp                                                        ; restore non-volatile registers
  ret                                                            ; return from subroutine

; __readFromAddress
func$__readFromAddress:
  ; Prolog
  push rbp                                                       ; save non-volatile registers
  push r15                                                       ; save non-volatile registers
  lea rbp, [rsp+000h]                                            ; set up frame pointer
  mov r15, [rbp+038h]                                            ; prepare return value
  func$__readFromAddress$epilog:
  mov rax, r15                                                   ; report address of return value
  ; Epilog
  pop r15                                                        ; restore non-volatile registers
  pop rbp                                                        ; restore non-volatile registers
  ret                                                            ; return from subroutine

; _stringAllocLength
func$_stringAllocLength:
  ; Prolog
  push rbp                                                       ; save non-volatile registers
  push r15                                                       ; save non-volatile registers
  sub rsp, 01c0h                                                 ; allocate space for stack
  lea rbp, [rsp+01c0h]                                           ; set up frame pointer
  mov r15, [rbp+038h]                                            ; prepare return value
  ; Check parameter count
  cmp qword ptr rcx, 000000001h                                  ; compare parameter count to integers
  je func$_stringAllocLength$parameterCount$continuation         ; check number of parameters is as expected
    ; Error handling block for parameter count
    ;  - print(parameterCountCheckFailureMessage)
    mov qword ptr [rbp-008h], 0h                                 ; value of this pointer for function call (placeholder)
    mov qword ptr [rbp-010h], 000000000h                         ; type of this pointer for function call (placeholder)
    mov qword ptr [rbp-018h], 0h                                 ; value of closure pointer for function call (placeholder)
    mov [rbp+018h], rcx                                          ; save rcx in shadow space
    mov [rbp+020h], rdx                                          ; save rdx in shadow space
    mov [rbp+028h], r8                                           ; save r8 in shadow space
    mov [rbp+030h], r9                                           ; save r9 in shadow space
    mov r11, offset parameterCountCheckFailureMessage            ; value of argument #1
    push r11                                                     ; (indirect via r11 because "parameterCountCheckFailureMessage" is an imm64)
    push 000000009h                                              ; type of argument #1
    lea r10, [rbp-020h]                                          ; pointer to return value (and type, 8 bytes earlier)
    push r10                                                     ; (that pointer is the last value pushed to the stack)
    lea r9, [rbp-008h]                                           ; pointer to this
    mov r8, [rbp-010h]                                           ; type of this
    lea rdx, [rbp-018h]                                          ; pointer to closure
    mov rcx, 1                                                   ; number of arguments
    sub rsp, 20h                                                 ; allocate shadow space
    call offset func$print                                       ; jump to subroutine
    add rsp, 038h                                                ; release shadow space and arguments
    mov rcx, [rbp+018h]                                          ; restore rcx from shadow space
    mov rdx, [rbp+020h]                                          ; restore rdx from shadow space
    mov r8, [rbp+028h]                                           ; restore r8 from shadow space
    mov r9, [rbp+030h]                                           ; restore r9 from shadow space
    ;  - exit(1)
    mov qword ptr [rbp-030h], 0h                                 ; value of this pointer for function call (placeholder)
    mov qword ptr [rbp-038h], 000000000h                         ; type of this pointer for function call (placeholder)
    mov qword ptr [rbp-040h], 0h                                 ; value of closure pointer for function call (placeholder)
    mov [rbp+018h], rcx                                          ; save rcx in shadow space
    mov [rbp+020h], rdx                                          ; save rdx in shadow space
    mov [rbp+028h], r8                                           ; save r8 in shadow space
    mov [rbp+030h], r9                                           ; save r9 in shadow space
    push 000000001h                                              ; value of argument #1
    push 000000008h                                              ; type of argument #1
    lea r10, [rbp-048h]                                          ; pointer to return value (and type, 8 bytes earlier)
    push r10                                                     ; (that pointer is the last value pushed to the stack)
    lea r9, [rbp-030h]                                           ; pointer to this
    mov r8, [rbp-038h]                                           ; type of this
    lea rdx, [rbp-040h]                                          ; pointer to closure
    mov rcx, 1                                                   ; number of arguments
    sub rsp, 20h                                                 ; allocate shadow space
    call offset func$exit                                        ; jump to subroutine
    add rsp, 038h                                                ; release shadow space and arguments
    mov rcx, [rbp+018h]                                          ; restore rcx from shadow space
    mov rdx, [rbp+020h]                                          ; restore rdx from shadow space
    mov r8, [rbp+028h]                                           ; restore r8 from shadow space
    mov r9, [rbp+030h]                                           ; restore r9 from shadow space
  func$_stringAllocLength$parameterCount$continuation:           ; end of parameter count
  ; Check type of parameter 0, data (expecting String)
  mov rax, [rbp+040h]                                            ; load the dynamic type of data into rax
  lea r10, typeTable                                             ; move type table offset into r10
  add rax, r10                                                   ; adjust rax to point to the type table
  bt qword ptr [rax], 1                                          ; check that data is String'9
  jc func$_stringAllocLength$data$TypeMatch                      ; skip next block if the type matches
    ; Error handling block for data
    ;  - print(parameterTypeCheckFailureMessage)
    mov qword ptr [rbp-058h], 0h                                 ; value of this pointer for function call (placeholder)
    mov qword ptr [rbp-060h], 000000000h                         ; type of this pointer for function call (placeholder)
    mov qword ptr [rbp-068h], 0h                                 ; value of closure pointer for function call (placeholder)
    mov [rbp+018h], rcx                                          ; save rcx in shadow space
    mov [rbp+020h], rdx                                          ; save rdx in shadow space
    mov [rbp+028h], r8                                           ; save r8 in shadow space
    mov [rbp+030h], r9                                           ; save r9 in shadow space
    mov r11, offset parameterTypeCheckFailureMessage             ; value of argument #1
    push r11                                                     ; (indirect via r11 because "parameterTypeCheckFailureMessage" is an imm64)
    push 000000009h                                              ; type of argument #1
    lea r10, [rbp-070h]                                          ; pointer to return value (and type, 8 bytes earlier)
    push r10                                                     ; (that pointer is the last value pushed to the stack)
    lea r9, [rbp-058h]                                           ; pointer to this
    mov r8, [rbp-060h]                                           ; type of this
    lea rdx, [rbp-068h]                                          ; pointer to closure
    mov rcx, 1                                                   ; number of arguments
    sub rsp, 20h                                                 ; allocate shadow space
    call offset func$print                                       ; jump to subroutine
    add rsp, 038h                                                ; release shadow space and arguments
    mov rcx, [rbp+018h]                                          ; restore rcx from shadow space
    mov rdx, [rbp+020h]                                          ; restore rdx from shadow space
    mov r8, [rbp+028h]                                           ; restore r8 from shadow space
    mov r9, [rbp+030h]                                           ; restore r9 from shadow space
    ;  - exit(1)
    mov qword ptr [rbp-080h], 0h                                 ; value of this pointer for function call (placeholder)
    mov qword ptr [rbp-088h], 000000000h                         ; type of this pointer for function call (placeholder)
    mov qword ptr [rbp-090h], 0h                                 ; value of closure pointer for function call (placeholder)
    mov [rbp+018h], rcx                                          ; save rcx in shadow space
    mov [rbp+020h], rdx                                          ; save rdx in shadow space
    mov [rbp+028h], r8                                           ; save r8 in shadow space
    mov [rbp+030h], r9                                           ; save r9 in shadow space
    push 000000001h                                              ; value of argument #1
    push 000000008h                                              ; type of argument #1
    lea r10, [rbp-098h]                                          ; pointer to return value (and type, 8 bytes earlier)
    push r10                                                     ; (that pointer is the last value pushed to the stack)
    lea r9, [rbp-080h]                                           ; pointer to this
    mov r8, [rbp-088h]                                           ; type of this
    lea rdx, [rbp-090h]                                          ; pointer to closure
    mov rcx, 1                                                   ; number of arguments
    sub rsp, 20h                                                 ; allocate shadow space
    call offset func$exit                                        ; jump to subroutine
    add rsp, 038h                                                ; release shadow space and arguments
    mov rcx, [rbp+018h]                                          ; restore rcx from shadow space
    mov rdx, [rbp+020h]                                          ; restore rdx from shadow space
    mov r8, [rbp+028h]                                           ; restore r8 from shadow space
    mov r9, [rbp+030h]                                           ; restore r9 from shadow space
  func$_stringAllocLength$data$TypeMatch:
  ; Line 6: Integer pointer = data __as__ Integer;
  mov r11, [rbp+048h]                                            ; value of force cast of data to Integer
  mov [rbp-0a8h], r11                                            ; (indirect via r11 because mov can't do memory-to-memory)
  mov qword ptr [rbp-0b0h], 000000008h                           ; new type of force cast of data to Integer
  ; Line 7: return __readFromAddress(pointer + 8);
  mov rax, [rbp-0b0h]                                            ; load the dynamic type of pointer into rax
  lea r10, typeTable                                             ; move type table offset into r10
  add rax, r10                                                   ; adjust rax to point to the type table
  bt qword ptr [rax], 0                                          ; check that pointer is Integer'8
  jc func$_stringAllocLength$pointer$TypeMatch                   ; skip next block if the type matches
    ; Error handling block for pointer
    ;  - print(operandTypeCheckFailureMessage)
    mov qword ptr [rbp-0b8h], 0h                                 ; value of this pointer for function call (placeholder)
    mov qword ptr [rbp-0c0h], 000000000h                         ; type of this pointer for function call (placeholder)
    mov qword ptr [rbp-0c8h], 0h                                 ; value of closure pointer for function call (placeholder)
    mov [rbp+018h], rcx                                          ; save rcx in shadow space
    mov [rbp+020h], rdx                                          ; save rdx in shadow space
    mov [rbp+028h], r8                                           ; save r8 in shadow space
    mov [rbp+030h], r9                                           ; save r9 in shadow space
    mov r11, offset operandTypeCheckFailureMessage               ; value of argument #1
    push r11                                                     ; (indirect via r11 because "operandTypeCheckFailureMessage" is an imm64)
    push 000000009h                                              ; type of argument #1
    lea r10, [rbp-0d0h]                                          ; pointer to return value (and type, 8 bytes earlier)
    push r10                                                     ; (that pointer is the last value pushed to the stack)
    lea r9, [rbp-0b8h]                                           ; pointer to this
    mov r8, [rbp-0c0h]                                           ; type of this
    lea rdx, [rbp-0c8h]                                          ; pointer to closure
    mov rcx, 1                                                   ; number of arguments
    sub rsp, 20h                                                 ; allocate shadow space
    call offset func$print                                       ; jump to subroutine
    add rsp, 038h                                                ; release shadow space and arguments
    mov rcx, [rbp+018h]                                          ; restore rcx from shadow space
    mov rdx, [rbp+020h]                                          ; restore rdx from shadow space
    mov r8, [rbp+028h]                                           ; restore r8 from shadow space
    mov r9, [rbp+030h]                                           ; restore r9 from shadow space
    ;  - exit(1)
    mov qword ptr [rbp-0e0h], 0h                                 ; value of this pointer for function call (placeholder)
    mov qword ptr [rbp-0e8h], 000000000h                         ; type of this pointer for function call (placeholder)
    mov qword ptr [rbp-0f0h], 0h                                 ; value of closure pointer for function call (placeholder)
    mov [rbp+018h], rcx                                          ; save rcx in shadow space
    mov [rbp+020h], rdx                                          ; save rdx in shadow space
    mov [rbp+028h], r8                                           ; save r8 in shadow space
    mov [rbp+030h], r9                                           ; save r9 in shadow space
    push 000000001h                                              ; value of argument #1
    push 000000008h                                              ; type of argument #1
    lea r10, [rbp-0f8h]                                          ; pointer to return value (and type, 8 bytes earlier)
    push r10                                                     ; (that pointer is the last value pushed to the stack)
    lea r9, [rbp-0e0h]                                           ; pointer to this
    mov r8, [rbp-0e8h]                                           ; type of this
    lea rdx, [rbp-0f0h]                                          ; pointer to closure
    mov rcx, 1                                                   ; number of arguments
    sub rsp, 20h                                                 ; allocate shadow space
    call offset func$exit                                        ; jump to subroutine
    add rsp, 038h                                                ; release shadow space and arguments
    mov rcx, [rbp+018h]                                          ; restore rcx from shadow space
    mov rdx, [rbp+020h]                                          ; restore rdx from shadow space
    mov r8, [rbp+028h]                                           ; restore r8 from shadow space
    mov r9, [rbp+030h]                                           ; restore r9 from shadow space
  func$_stringAllocLength$pointer$TypeMatch:
  mov r10, [rbp-0a8h]                                            ; add mutates first operand, so indirect via register
  add r10, 000000008h                                            ; + operator
  mov [rbp-0158h], r10                                           ; store result
  mov qword ptr [rbp-0160h], 000000008h                          ; store type
  mov r10, [rbp-0158h]                                           ; value of + operator result
  mov r11, [r10]                                                 ; dereference + operator result and put result in address of + operator result
  mov [rbp-0168h], r11                                           ; (indirect via r11 because mov can't do memory-to-memory)
  mov qword ptr [rbp-0170h], 000000008h                          ; type of address of + operator result
  mov rax, [rbp-0170h]                                           ; load the dynamic type of return value of _stringAllocLength into rax
  lea r10, typeTable                                             ; move type table offset into r10
  add rax, r10                                                   ; adjust rax to point to the type table
  bt qword ptr [rax], 0                                          ; check that return value of _stringAllocLength is Integer'8
  jc func$_stringAllocLength$returnValueOfStringalloclength$TypeMatch ; skip next block if the type matches
    ; Error handling block for return value of _stringAllocLength
    ;  - print(returnValueTypeCheckFailureMessage)
    mov qword ptr [rbp-0178h], 0h                                ; value of this pointer for function call (placeholder)
    mov qword ptr [rbp-0180h], 000000000h                        ; type of this pointer for function call (placeholder)
    mov qword ptr [rbp-0188h], 0h                                ; value of closure pointer for function call (placeholder)
    mov [rbp+018h], rcx                                          ; save rcx in shadow space
    mov [rbp+020h], rdx                                          ; save rdx in shadow space
    mov [rbp+028h], r8                                           ; save r8 in shadow space
    mov [rbp+030h], r9                                           ; save r9 in shadow space
    mov r11, offset returnValueTypeCheckFailureMessage           ; value of argument #1
    push r11                                                     ; (indirect via r11 because "returnValueTypeCheckFailureMessage" is an imm64)
    push 000000009h                                              ; type of argument #1
    lea r10, [rbp-0190h]                                         ; pointer to return value (and type, 8 bytes earlier)
    push r10                                                     ; (that pointer is the last value pushed to the stack)
    lea r9, [rbp-0178h]                                          ; pointer to this
    mov r8, [rbp-0180h]                                          ; type of this
    lea rdx, [rbp-0188h]                                         ; pointer to closure
    mov rcx, 1                                                   ; number of arguments
    sub rsp, 20h                                                 ; allocate shadow space
    call offset func$print                                       ; jump to subroutine
    add rsp, 038h                                                ; release shadow space and arguments
    mov rcx, [rbp+018h]                                          ; restore rcx from shadow space
    mov rdx, [rbp+020h]                                          ; restore rdx from shadow space
    mov r8, [rbp+028h]                                           ; restore r8 from shadow space
    mov r9, [rbp+030h]                                           ; restore r9 from shadow space
    ;  - exit(1)
    mov qword ptr [rbp-01a0h], 0h                                ; value of this pointer for function call (placeholder)
    mov qword ptr [rbp-01a8h], 000000000h                        ; type of this pointer for function call (placeholder)
    mov qword ptr [rbp-01b0h], 0h                                ; value of closure pointer for function call (placeholder)
    mov [rbp+018h], rcx                                          ; save rcx in shadow space
    mov [rbp+020h], rdx                                          ; save rdx in shadow space
    mov [rbp+028h], r8                                           ; save r8 in shadow space
    mov [rbp+030h], r9                                           ; save r9 in shadow space
    push 000000001h                                              ; value of argument #1
    push 000000008h                                              ; type of argument #1
    lea r10, [rbp-01b8h]                                         ; pointer to return value (and type, 8 bytes earlier)
    push r10                                                     ; (that pointer is the last value pushed to the stack)
    lea r9, [rbp-01a0h]                                          ; pointer to this
    mov r8, [rbp-01a8h]                                          ; type of this
    lea rdx, [rbp-01b0h]                                         ; pointer to closure
    mov rcx, 1                                                   ; number of arguments
    sub rsp, 20h                                                 ; allocate shadow space
    call offset func$exit                                        ; jump to subroutine
    add rsp, 038h                                                ; release shadow space and arguments
    mov rcx, [rbp+018h]                                          ; restore rcx from shadow space
    mov rdx, [rbp+020h]                                          ; restore rdx from shadow space
    mov r8, [rbp+028h]                                           ; restore r8 from shadow space
    mov r9, [rbp+030h]                                           ; restore r9 from shadow space
  func$_stringAllocLength$returnValueOfStringalloclength$TypeMatch:
  mov r11, [rbp-0168h]                                           ; value of return value
  mov [r15], r11                                                 ; (indirect via r11 because mov can't do memory-to-memory)
  mov r11, [rbp-0170h]                                           ; type of return value
  mov [r15-08h], r11                                             ; (indirect via r11 because mov can't do memory-to-memory)
  jmp func$_stringAllocLength$epilog                             ; return
  func$_stringAllocLength$epilog:
  mov rax, r15                                                   ; report address of return value
  ; Epilog
  add rsp, 01c0h                                                 ; free space for stack
  pop r15                                                        ; restore non-volatile registers
  pop rbp                                                        ; restore non-volatile registers
  ret                                                            ; return from subroutine


end

