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
extern GetProcessHeap : proc

.const
  typeTable    db 01fh, 010h, 010h, 010h, 010h, 010h, 010h, 010h, 010h, 010h, 010h, 010h, 011h, 012h, 014h, 018h ; Type table
   ; Columns: Null'12 Boolean'13 Integer'14 String'15 Anything'16
   ; 1 1 1 1 1   <sentinel>'0
   ; 0 0 0 0 1   NullFunction(String)'1
   ; 0 0 0 0 1   NullFunction(Integer)'2
   ; 0 0 0 0 1   IntegerFunction(WhateverReadOnlyList)'3
   ; 0 0 0 0 1   IntegerFunction()'4
   ; 0 0 0 0 1   IntegerFunction(Integer)'5
   ; 0 0 0 0 1   StringFunction(Anything)'6
   ; 0 0 0 0 1   NullFunction(String...)'7
   ; 0 0 0 0 1   StringReadOnlyList'8
   ; 0 0 0 0 1   NullFunction(String...)'9
   ; 0 0 0 0 1   StringReadOnlyList'10
   ; 0 0 0 0 1   IntegerFunction(String)'11
   ; 1 0 0 0 1   Null'12
   ; 0 1 0 0 1   Boolean'13
   ; 0 0 1 0 1   Integer'14
   ; 0 0 0 1 1   String'15

  parameterCountCheckFailureMessage dq -01h                      ; String constant (reference count)
               dq 88                                             ; Length
               db "error: function call received the wrong number of parameters (expected %d, received %d)", 0ah ; line 209 column 25 in file syd-compiler.syd
               db 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h         ; padding to align to 8-byte boundary
  parameterTypeCheckFailureMessage dq -01h                       ; String constant (reference count)
               dq 71                                             ; Length
               db "error: type mismatch for function %s parameter %d, expected %s, got %s", 0ah ; line 214 column 25 in file syd-compiler.syd
               db 00h                                            ; padding to align to 8-byte boundary
  returnValueTypeCheckFailureMessage dq -01h                     ; String constant (reference count)
               dq 68                                             ; Length
               db "error: type mismatch for function return value, expected %s, got %s", 0ah ; line 219 column 25 in file syd-compiler.syd
               db 00h, 00h, 00h, 00h                             ; padding to align to 8-byte boundary
  operandTypeCheckFailureMessage dq -01h                         ; String constant (reference count)
               dq 54                                             ; Length
               db "error: type mismatch for operand, expected %s, got %s", 0ah ; line 224 column 25 in file syd-compiler.syd
               db 00h, 00h                                       ; padding to align to 8-byte boundary
  asOperatorFailureMessage dq -01h                               ; String constant (reference count)
               dq 58                                             ; Length
               db "error: type mismatch for as operator, expected %s, got %s", 0ah ; line 229 column 25 in file syd-compiler.syd
               db 00h, 00h, 00h, 00h, 00h, 00h                   ; padding to align to 8-byte boundary
  boundsFailureMessage dq -01h                                   ; String constant (reference count)
               dq 64                                             ; Length
               db "error: subscript index out of range (%d is not in range %d..%d)", 0ah ; line 234 column 25 in file syd-compiler.syd
               db 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h         ; padding to align to 8-byte boundary
  string$6     dq -01h                                           ; String constant (reference count)
               dq 5                                              ; Length
               db "hello"                                        ; line 3 column 18 in file temp.syd
               db 00h, 00h, 00h                                  ; padding to align to 8-byte boundary
  string       dq -01h                                           ; String constant (reference count)
               dq 4                                              ; Length
               db "true"                                         ; line 90 column 19 in file runtime library
               db 00h, 00h, 00h, 00h                             ; padding to align to 8-byte boundary
  string$1     dq -01h                                           ; String constant (reference count)
               dq 5                                              ; Length
               db "false"                                        ; line 92 column 18 in file runtime library
               db 00h, 00h, 00h                                  ; padding to align to 8-byte boundary
  string$2     dq -01h                                           ; String constant (reference count)
               dq 4                                              ; Length
               db "null"                                         ; line 95 column 17 in file runtime library
               db 00h, 00h, 00h, 00h                             ; padding to align to 8-byte boundary
  string$3     dq -01h                                           ; String constant (reference count)
               dq 28                                             ; Length
               db "value cannot be stringified", 0ah             ; line 100 column 41 in file runtime library
               db 00h, 00h, 00h, 00h                             ; padding to align to 8-byte boundary
  string$4     dq -01h                                           ; String constant (reference count)
               dq 1                                              ; Length
               db " "                                            ; line 109 column 17 in file runtime library
               db 00h, 00h, 00h, 00h, 00h, 00h, 00h              ; padding to align to 8-byte boundary
  string$5     dq -01h                                           ; String constant (reference count)
               dq 1                                              ; Length
               db 0ah                                            ; line 128 column 14 in file runtime library
               db 00h, 00h, 00h, 00h, 00h, 00h, 00h              ; padding to align to 8-byte boundary

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
  mov r11, offset string$6                                       ; value of argument #1
  push r11                                                       ; (indirect via r11 because "string$6" is an imm64)
  push 00000000fh                                                ; type of argument #1
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
  push 00000000eh                                                ; type of argument #1
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

; __print
func$__print:
  ; Prolog
  push rbp                                                       ; save non-volatile registers
  push r15                                                       ; save non-volatile registers
  sub rsp, 0a8h                                                  ; allocate space for stack
  lea rbp, [rsp+0a8h]                                            ; set up frame pointer
  mov r15, [rbp+038h]                                            ; prepare return value
  ; Check parameter count
  cmp qword ptr rcx, 000000001h                                  ; compare parameter count to integers
  je func$__print$parameterCount$continuation                    ; check number of parameters is as expected
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
    push 00000000fh                                              ; type of argument #1
    lea r10, [rbp-028h]                                          ; pointer to return value (and type, 8 bytes earlier)
    push r10                                                     ; (that pointer is the last value pushed to the stack)
    lea r9, [rbp-010h]                                           ; pointer to this
    mov r8, [rbp-018h]                                           ; type of this
    lea rdx, [rbp-020h]                                          ; pointer to closure
    mov rcx, 1                                                   ; number of arguments
    sub rsp, 20h                                                 ; allocate shadow space
    call offset func$__print                                     ; jump to subroutine
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
    push 00000000eh                                              ; type of argument #1
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
  func$__print$parameterCount$continuation:                      ; end of parameter count
  ; Check type of parameter 0, message to print to console (expecting String)
  mov rax, [rbp+040h]                                            ; load the dynamic type of message to print to console into rax
  lea r10, typeTable                                             ; move type table offset into r10
  add rax, r10                                                   ; adjust rax to point to the type table
  bt qword ptr [rax], 3                                          ; check that message to print to console is String'15
  jc func$__print$messageToPrintToConsole$TypeMatch              ; skip next block if the type matches
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
    push 00000000fh                                              ; type of argument #1
    lea r10, [rbp-078h]                                          ; pointer to return value (and type, 8 bytes earlier)
    push r10                                                     ; (that pointer is the last value pushed to the stack)
    lea r9, [rbp-060h]                                           ; pointer to this
    mov r8, [rbp-068h]                                           ; type of this
    lea rdx, [rbp-070h]                                          ; pointer to closure
    mov rcx, 1                                                   ; number of arguments
    sub rsp, 20h                                                 ; allocate shadow space
    call offset func$__print                                     ; jump to subroutine
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
    push 00000000eh                                              ; type of argument #1
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
  func$__print$messageToPrintToConsole$TypeMatch:
  mov [rbp+018h], rcx                                            ; save rcx in shadow space
  mov [rbp+020h], rdx                                            ; save rdx in shadow space
  mov [rbp+028h], r8                                             ; save r8 in shadow space
  mov [rbp+030h], r9                                             ; save r9 in shadow space
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
  mov rcx, [rbp+018h]                                            ; restore rcx from shadow space
  mov rdx, [rbp+020h]                                            ; restore rdx from shadow space
  mov r8, [rbp+028h]                                             ; restore r8 from shadow space
  mov r9, [rbp+030h]                                             ; restore r9 from shadow space
  func$__print$epilog:
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
    push 00000000fh                                              ; type of argument #1
    lea r10, [rbp-020h]                                          ; pointer to return value (and type, 8 bytes earlier)
    push r10                                                     ; (that pointer is the last value pushed to the stack)
    lea r9, [rbp-008h]                                           ; pointer to this
    mov r8, [rbp-010h]                                           ; type of this
    lea rdx, [rbp-018h]                                          ; pointer to closure
    mov rcx, 1                                                   ; number of arguments
    sub rsp, 20h                                                 ; allocate shadow space
    call offset func$__print                                     ; jump to subroutine
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
    push 00000000eh                                              ; type of argument #1
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
  bt qword ptr [rax], 2                                          ; check that exit code parameter is Integer'14
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
    push 00000000fh                                              ; type of argument #1
    lea r10, [rbp-070h]                                          ; pointer to return value (and type, 8 bytes earlier)
    push r10                                                     ; (that pointer is the last value pushed to the stack)
    lea r9, [rbp-058h]                                           ; pointer to this
    mov r8, [rbp-060h]                                           ; type of this
    lea rdx, [rbp-068h]                                          ; pointer to closure
    mov rcx, 1                                                   ; number of arguments
    sub rsp, 20h                                                 ; allocate shadow space
    call offset func$__print                                     ; jump to subroutine
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
    push 00000000eh                                              ; type of argument #1
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
  mov [rbp+018h], rcx                                            ; save rcx in shadow space
  mov [rbp+020h], rdx                                            ; save rdx in shadow space
  mov [rbp+028h], r8                                             ; save r8 in shadow space
  mov [rbp+030h], r9                                             ; save r9 in shadow space
  ; Calling ExitProcess
  mov rcx, [rbp+048h]                                            ; exit code
  sub rsp, 20h                                                   ; allocate shadow space
  call ExitProcess                                               ; process should terminate at this point
  add rsp, 20h                                                   ; release shadow space
  mov rcx, [rbp+018h]                                            ; restore rcx from shadow space
  mov rdx, [rbp+020h]                                            ; restore rdx from shadow space
  mov r8, [rbp+028h]                                             ; restore r8 from shadow space
  mov r9, [rbp+030h]                                             ; restore r9 from shadow space
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
  ; TODO: implement "len" function
  func$len$epilog:
  mov rax, r15                                                   ; report address of return value
  ; Epilog
  pop r15                                                        ; restore non-volatile registers
  pop rbp                                                        ; restore non-volatile registers
  ret                                                            ; return from subroutine

; __getProcessHeap
func$__getProcessHeap:
  ; Prolog
  push rbp                                                       ; save non-volatile registers
  push r15                                                       ; save non-volatile registers
  lea rbp, [rsp+000h]                                            ; set up frame pointer
  mov r15, [rbp+038h]                                            ; prepare return value
  mov [rbp+018h], rcx                                            ; save rcx in shadow space
  mov [rbp+020h], rdx                                            ; save rdx in shadow space
  mov [rbp+028h], r8                                             ; save r8 in shadow space
  mov [rbp+030h], r9                                             ; save r9 in shadow space
  ; Calling GetProcessHeap
  call GetProcessHeap                                            ; handle returned in rax
  mov [r15], rax                                                 ; heap handle
  mov qword ptr [r15-08h], 00000000eh                            ; heap handle is an integer
  mov rcx, [rbp+018h]                                            ; restore rcx from shadow space
  mov rdx, [rbp+020h]                                            ; restore rdx from shadow space
  mov r8, [rbp+028h]                                             ; restore r8 from shadow space
  mov r9, [rbp+030h]                                             ; restore r9 from shadow space
  func$__getProcessHeap$epilog:
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

; _stringify
func$_stringify:
  ; Prolog
  push rbp                                                       ; save non-volatile registers
  push r15                                                       ; save non-volatile registers
  sub rsp, 0260h                                                 ; allocate space for stack
  lea rbp, [rsp+0260h]                                           ; set up frame pointer
  mov r15, [rbp+038h]                                            ; prepare return value
  ; Check parameter count
  cmp qword ptr rcx, 000000001h                                  ; compare parameter count to integers
  je func$_stringify$parameterCount$continuation                 ; check number of parameters is as expected
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
    push 00000000fh                                              ; type of argument #1
    lea r10, [rbp-020h]                                          ; pointer to return value (and type, 8 bytes earlier)
    push r10                                                     ; (that pointer is the last value pushed to the stack)
    lea r9, [rbp-008h]                                           ; pointer to this
    mov r8, [rbp-010h]                                           ; type of this
    lea rdx, [rbp-018h]                                          ; pointer to closure
    mov rcx, 1                                                   ; number of arguments
    sub rsp, 20h                                                 ; allocate shadow space
    call offset func$__print                                     ; jump to subroutine
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
    push 00000000eh                                              ; type of argument #1
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
  func$_stringify$parameterCount$continuation:                   ; end of parameter count
  ; Check type of parameter 0, arg (expecting Anything)
  mov rax, [rbp+040h]                                            ; load the dynamic type of arg into rax
  lea r10, typeTable                                             ; move type table offset into r10
  add rax, r10                                                   ; adjust rax to point to the type table
  bt qword ptr [rax], 4                                          ; check that arg is Anything'16
  jc func$_stringify$arg$TypeMatch                               ; skip next block if the type matches
    ; Error handling block for arg
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
    push 00000000fh                                              ; type of argument #1
    lea r10, [rbp-070h]                                          ; pointer to return value (and type, 8 bytes earlier)
    push r10                                                     ; (that pointer is the last value pushed to the stack)
    lea r9, [rbp-058h]                                           ; pointer to this
    mov r8, [rbp-060h]                                           ; type of this
    lea rdx, [rbp-068h]                                          ; pointer to closure
    mov rcx, 1                                                   ; number of arguments
    sub rsp, 20h                                                 ; allocate shadow space
    call offset func$__print                                     ; jump to subroutine
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
    push 00000000eh                                              ; type of argument #1
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
  func$_stringify$arg$TypeMatch:
  ; Line 85: if (arg is String) { ...
  mov rax, [rbp+040h]                                            ; load the dynamic type of arg into rax
  lea r10, typeTable                                             ; move type table offset into r10
  add rax, r10                                                   ; adjust rax to point to the type table
  bt qword ptr [rax], 3                                          ; check that arg is String'15
  mov qword ptr [rbp-0a8h], 000000000h                           ; clear is expression result
  setc byte ptr [rbp-0a8h]                                       ; store result in is expression result
  mov qword ptr [rbp-0b0h], 00000000dh                           ; is expression result is a Boolean
  cmp qword ptr [rbp-0a8h], 000000000h                           ; compare is expression result to false
  je func$_stringify$if$continuation                             ; arg is String
    ; Line 86: return arg;
    mov rax, [rbp+040h]                                          ; load the dynamic type of return value of _stringify into rax
    lea r10, typeTable                                           ; move type table offset into r10
    add rax, r10                                                 ; adjust rax to point to the type table
    bt qword ptr [rax], 3                                        ; check that return value of _stringify is String'15
    jc func$_stringify$Stringify$if$block$returnValueOfStringify$TypeMatch ; skip next block if the type matches
      ; Error handling block for return value of _stringify
      ;  - print(returnValueTypeCheckFailureMessage)
      mov qword ptr [rbp-0b8h], 0h                               ; value of this pointer for function call (placeholder)
      mov qword ptr [rbp-0c0h], 000000000h                       ; type of this pointer for function call (placeholder)
      mov qword ptr [rbp-0c8h], 0h                               ; value of closure pointer for function call (placeholder)
      mov [rbp+018h], rcx                                        ; save rcx in shadow space
      mov [rbp+020h], rdx                                        ; save rdx in shadow space
      mov [rbp+028h], r8                                         ; save r8 in shadow space
      mov [rbp+030h], r9                                         ; save r9 in shadow space
      mov r11, offset returnValueTypeCheckFailureMessage         ; value of argument #1
      push r11                                                   ; (indirect via r11 because "returnValueTypeCheckFailureMessage" is an imm64)
      push 00000000fh                                            ; type of argument #1
      lea r10, [rbp-0d0h]                                        ; pointer to return value (and type, 8 bytes earlier)
      push r10                                                   ; (that pointer is the last value pushed to the stack)
      lea r9, [rbp-0b8h]                                         ; pointer to this
      mov r8, [rbp-0c0h]                                         ; type of this
      lea rdx, [rbp-0c8h]                                        ; pointer to closure
      mov rcx, 1                                                 ; number of arguments
      sub rsp, 20h                                               ; allocate shadow space
      call offset func$__print                                   ; jump to subroutine
      add rsp, 038h                                              ; release shadow space and arguments
      mov rcx, [rbp+018h]                                        ; restore rcx from shadow space
      mov rdx, [rbp+020h]                                        ; restore rdx from shadow space
      mov r8, [rbp+028h]                                         ; restore r8 from shadow space
      mov r9, [rbp+030h]                                         ; restore r9 from shadow space
      ;  - exit(1)
      mov qword ptr [rbp-0e0h], 0h                               ; value of this pointer for function call (placeholder)
      mov qword ptr [rbp-0e8h], 000000000h                       ; type of this pointer for function call (placeholder)
      mov qword ptr [rbp-0f0h], 0h                               ; value of closure pointer for function call (placeholder)
      mov [rbp+018h], rcx                                        ; save rcx in shadow space
      mov [rbp+020h], rdx                                        ; save rdx in shadow space
      mov [rbp+028h], r8                                         ; save r8 in shadow space
      mov [rbp+030h], r9                                         ; save r9 in shadow space
      push 000000001h                                            ; value of argument #1
      push 00000000eh                                            ; type of argument #1
      lea r10, [rbp-0f8h]                                        ; pointer to return value (and type, 8 bytes earlier)
      push r10                                                   ; (that pointer is the last value pushed to the stack)
      lea r9, [rbp-0e0h]                                         ; pointer to this
      mov r8, [rbp-0e8h]                                         ; type of this
      lea rdx, [rbp-0f0h]                                        ; pointer to closure
      mov rcx, 1                                                 ; number of arguments
      sub rsp, 20h                                               ; allocate shadow space
      call offset func$exit                                      ; jump to subroutine
      add rsp, 038h                                              ; release shadow space and arguments
      mov rcx, [rbp+018h]                                        ; restore rcx from shadow space
      mov rdx, [rbp+020h]                                        ; restore rdx from shadow space
      mov r8, [rbp+028h]                                         ; restore r8 from shadow space
      mov r9, [rbp+030h]                                         ; restore r9 from shadow space
    func$_stringify$Stringify$if$block$returnValueOfStringify$TypeMatch:
    mov r11, [rbp+048h]                                          ; value of return value
    mov [r15], r11                                               ; (indirect via r11 because mov can't do memory-to-memory)
    mov r11, [rbp+040h]                                          ; type of return value
    mov [r15-08h], r11                                           ; (indirect via r11 because mov can't do memory-to-memory)
    jmp func$_stringify$epilog                                   ; return
  func$_stringify$if$continuation:                               ; end of if
  ; Line 88: if (arg is Boolean) { ...
  mov rax, [rbp+040h]                                            ; load the dynamic type of arg into rax
  lea r10, typeTable                                             ; move type table offset into r10
  add rax, r10                                                   ; adjust rax to point to the type table
  bt qword ptr [rax], 1                                          ; check that arg is Boolean'13
  mov qword ptr [rbp-0108h], 000000000h                          ; clear is expression result
  setc byte ptr [rbp-0108h]                                      ; store result in is expression result
  mov qword ptr [rbp-0110h], 00000000dh                          ; is expression result is a Boolean
  cmp qword ptr [rbp-0108h], 000000000h                          ; compare is expression result to false
  je func$_stringify$if$continuation$1                           ; arg is Boolean
    ; Line 89: if (arg) { ...
    cmp qword ptr [rbp+048h], 000000000h                         ; compare arg to false
    je func$_stringify$Stringify$if$block$1$if$continuation      ; arg
      ; Line 90: return 'true';
      mov r11, offset string                                     ; value of return value
      mov [r15], r11                                             ; (indirect via r11 because "string" is an imm64)
      mov qword ptr [r15-08h], 00000000fh                        ; type of return value
      jmp func$_stringify$epilog                                 ; return
    func$_stringify$Stringify$if$block$1$if$continuation:        ; end of if
    ; Line 92: return 'false';
    mov r11, offset string$1                                     ; value of return value
    mov [r15], r11                                               ; (indirect via r11 because "string$1" is an imm64)
    mov qword ptr [r15-08h], 00000000fh                          ; type of return value
    jmp func$_stringify$epilog                                   ; return
  func$_stringify$if$continuation$1:                             ; end of if
  ; Line 94: if (arg is Null) { ...
  mov rax, [rbp+040h]                                            ; load the dynamic type of arg into rax
  lea r10, typeTable                                             ; move type table offset into r10
  add rax, r10                                                   ; adjust rax to point to the type table
  bt qword ptr [rax], 0                                          ; check that arg is Null'12
  mov qword ptr [rbp-01b8h], 000000000h                          ; clear is expression result
  setc byte ptr [rbp-01b8h]                                      ; store result in is expression result
  mov qword ptr [rbp-01c0h], 00000000dh                          ; is expression result is a Boolean
  cmp qword ptr [rbp-01b8h], 000000000h                          ; compare is expression result to false
  je func$_stringify$if$continuation$2                           ; arg is Null
    ; Line 95: return 'null';
    mov r11, offset string$2                                     ; value of return value
    mov [r15], r11                                               ; (indirect via r11 because "string$2" is an imm64)
    mov qword ptr [r15-08h], 00000000fh                          ; type of return value
    jmp func$_stringify$epilog                                   ; return
  func$_stringify$if$continuation$2:                             ; end of if
  ; Line 100: __print('value cannot be stringified\n');
  mov qword ptr [rbp-0218h], 0h                                  ; value of this pointer for function call (placeholder)
  mov qword ptr [rbp-0220h], 000000000h                          ; type of this pointer for function call (placeholder)
  mov qword ptr [rbp-0228h], 0h                                  ; value of closure pointer for function call (placeholder)
  mov [rbp+018h], rcx                                            ; save rcx in shadow space
  mov [rbp+020h], rdx                                            ; save rdx in shadow space
  mov [rbp+028h], r8                                             ; save r8 in shadow space
  mov [rbp+030h], r9                                             ; save r9 in shadow space
  mov r11, offset string$3                                       ; value of argument #1
  push r11                                                       ; (indirect via r11 because "string$3" is an imm64)
  push 00000000fh                                                ; type of argument #1
  lea r10, [rbp-0230h]                                           ; pointer to return value (and type, 8 bytes earlier)
  push r10                                                       ; (that pointer is the last value pushed to the stack)
  lea r9, [rbp-0218h]                                            ; pointer to this
  mov r8, [rbp-0220h]                                            ; type of this
  lea rdx, [rbp-0228h]                                           ; pointer to closure
  mov rcx, 1                                                     ; number of arguments
  sub rsp, 20h                                                   ; allocate shadow space
  call offset func$__print                                       ; jump to subroutine
  add rsp, 038h                                                  ; release shadow space and arguments
  mov rcx, [rbp+018h]                                            ; restore rcx from shadow space
  mov rdx, [rbp+020h]                                            ; restore rdx from shadow space
  mov r8, [rbp+028h]                                             ; restore r8 from shadow space
  mov r9, [rbp+030h]                                             ; restore r9 from shadow space
  ; Line 101: exit(1);
  mov qword ptr [rbp-0240h], 0h                                  ; value of this pointer for function call (placeholder)
  mov qword ptr [rbp-0248h], 000000000h                          ; type of this pointer for function call (placeholder)
  mov qword ptr [rbp-0250h], 0h                                  ; value of closure pointer for function call (placeholder)
  mov [rbp+018h], rcx                                            ; save rcx in shadow space
  mov [rbp+020h], rdx                                            ; save rdx in shadow space
  mov [rbp+028h], r8                                             ; save r8 in shadow space
  mov [rbp+030h], r9                                             ; save r9 in shadow space
  push 000000001h                                                ; value of argument #1
  push 00000000eh                                                ; type of argument #1
  lea r10, [rbp-0258h]                                           ; pointer to return value (and type, 8 bytes earlier)
  push r10                                                       ; (that pointer is the last value pushed to the stack)
  lea r9, [rbp-0240h]                                            ; pointer to this
  mov r8, [rbp-0248h]                                            ; type of this
  lea rdx, [rbp-0250h]                                           ; pointer to closure
  mov rcx, 1                                                     ; number of arguments
  sub rsp, 20h                                                   ; allocate shadow space
  call offset func$exit                                          ; jump to subroutine
  add rsp, 038h                                                  ; release shadow space and arguments
  mov rcx, [rbp+018h]                                            ; restore rcx from shadow space
  mov rdx, [rbp+020h]                                            ; restore rdx from shadow space
  mov r8, [rbp+028h]                                             ; restore r8 from shadow space
  mov r9, [rbp+030h]                                             ; restore r9 from shadow space
  func$_stringify$epilog:
  mov rax, r15                                                   ; report address of return value
  ; Epilog
  add rsp, 0260h                                                 ; free space for stack
  pop r15                                                        ; restore non-volatile registers
  pop rbp                                                        ; restore non-volatile registers
  ret                                                            ; return from subroutine

; print
func$print:
  ; Prolog
  push rbp                                                       ; save non-volatile registers
  push r15                                                       ; save non-volatile registers
  push rsi                                                       ; save non-volatile registers
  push rdi                                                       ; save non-volatile registers
  sub rsp, 02b8h                                                 ; allocate space for stack
  lea rbp, [rsp+02b8h]                                           ; set up frame pointer
  mov r15, [rbp+048h]                                            ; prepare return value
  lea rsi, [rbp+00000000000000058h]                              ; initial index pointing to value of first argument
  mov rdi, rcx                                                   ; end of loop is the number of arguments...
  shl rdi, 5                                                     ; ...times the width of each argument (010h)...
  add rdi, rsi                                                   ; ...offset from the initial index
  func$print$varargTypeChecks$Loop:
    cmp rsi, rdi                                                 ; compare pointer to current argument to end of loop
    je func$print$varargTypeChecks$TypesAllMatch                 ; we have type-checked all the arguments
    mov rax, [rsi-008h]                                          ; load the dynamic type of vararg types into rax
    lea r10, typeTable                                           ; move type table offset into r10
    add rax, r10                                                 ; adjust rax to point to the type table
    bt qword ptr [rax], 3                                        ; check that vararg types is String'15
    jc func$print$varargTypeChecks$TypeMatch                     ; skip next block if the type matches
      ; Error handling block for vararg types
      ;  - print(parameterTypeCheckFailureMessage)
      mov qword ptr [rbp-008h], 0h                               ; value of this pointer for function call (placeholder)
      mov qword ptr [rbp-010h], 000000000h                       ; type of this pointer for function call (placeholder)
      mov qword ptr [rbp-018h], 0h                               ; value of closure pointer for function call (placeholder)
      mov [rbp+028h], rcx                                        ; save rcx in shadow space
      mov [rbp+030h], rdx                                        ; save rdx in shadow space
      mov [rbp+038h], r8                                         ; save r8 in shadow space
      mov [rbp+040h], r9                                         ; save r9 in shadow space
      mov r11, offset parameterTypeCheckFailureMessage           ; value of argument #1
      push r11                                                   ; (indirect via r11 because "parameterTypeCheckFailureMessage" is an imm64)
      push 00000000fh                                            ; type of argument #1
      lea r10, [rbp-020h]                                        ; pointer to return value (and type, 8 bytes earlier)
      push r10                                                   ; (that pointer is the last value pushed to the stack)
      lea r9, [rbp-008h]                                         ; pointer to this
      mov r8, [rbp-010h]                                         ; type of this
      lea rdx, [rbp-018h]                                        ; pointer to closure
      mov rcx, 1                                                 ; number of arguments
      sub rsp, 20h                                               ; allocate shadow space
      call offset func$__print                                   ; jump to subroutine
      add rsp, 038h                                              ; release shadow space and arguments
      mov rcx, [rbp+028h]                                        ; restore rcx from shadow space
      mov rdx, [rbp+030h]                                        ; restore rdx from shadow space
      mov r8, [rbp+038h]                                         ; restore r8 from shadow space
      mov r9, [rbp+040h]                                         ; restore r9 from shadow space
      ;  - exit(1)
      mov qword ptr [rbp-030h], 0h                               ; value of this pointer for function call (placeholder)
      mov qword ptr [rbp-038h], 000000000h                       ; type of this pointer for function call (placeholder)
      mov qword ptr [rbp-040h], 0h                               ; value of closure pointer for function call (placeholder)
      mov [rbp+028h], rcx                                        ; save rcx in shadow space
      mov [rbp+030h], rdx                                        ; save rdx in shadow space
      mov [rbp+038h], r8                                         ; save r8 in shadow space
      mov [rbp+040h], r9                                         ; save r9 in shadow space
      push 000000001h                                            ; value of argument #1
      push 00000000eh                                            ; type of argument #1
      lea r10, [rbp-048h]                                        ; pointer to return value (and type, 8 bytes earlier)
      push r10                                                   ; (that pointer is the last value pushed to the stack)
      lea r9, [rbp-030h]                                         ; pointer to this
      mov r8, [rbp-038h]                                         ; type of this
      lea rdx, [rbp-040h]                                        ; pointer to closure
      mov rcx, 1                                                 ; number of arguments
      sub rsp, 20h                                               ; allocate shadow space
      call offset func$exit                                      ; jump to subroutine
      add rsp, 038h                                              ; release shadow space and arguments
      mov rcx, [rbp+028h]                                        ; restore rcx from shadow space
      mov rdx, [rbp+030h]                                        ; restore rdx from shadow space
      mov r8, [rbp+038h]                                         ; restore r8 from shadow space
      mov r9, [rbp+040h]                                         ; restore r9 from shadow space
    func$print$varargTypeChecks$TypeMatch:
    add rsi, 010h                                                ; next argument
    jmp func$print$varargTypeChecks$Loop                         ; return to top of loop
  func$print$varargTypeChecks$TypesAllMatch:
  ; Line 105: Boolean first = true;
  mov qword ptr [rbp-058h], 000000001h                           ; value of first
  mov qword ptr [rbp-060h], 00000000dh                           ; type of first
  ; Line 106: Integer index = 0;
  mov qword ptr [rbp-068h], 000000000h                           ; value of index
  mov qword ptr [rbp-070h], 00000000eh                           ; type of index
  ; Line 107: while (index < len(parts)) { ...
  func$print$while$top:
    mov rax, [rbp-070h]                                          ; load the dynamic type of index into rax
    lea r10, typeTable                                           ; move type table offset into r10
    add rax, r10                                                 ; adjust rax to point to the type table
    bt qword ptr [rax], 2                                        ; check that index is Integer'14
    jc func$print$while$index$TypeMatch                          ; skip next block if the type matches
      ; Error handling block for index
      ;  - print(operandTypeCheckFailureMessage)
      mov qword ptr [rbp-078h], 0h                               ; value of this pointer for function call (placeholder)
      mov qword ptr [rbp-080h], 000000000h                       ; type of this pointer for function call (placeholder)
      mov qword ptr [rbp-088h], 0h                               ; value of closure pointer for function call (placeholder)
      mov [rbp+028h], rcx                                        ; save rcx in shadow space
      mov [rbp+030h], rdx                                        ; save rdx in shadow space
      mov [rbp+038h], r8                                         ; save r8 in shadow space
      mov [rbp+040h], r9                                         ; save r9 in shadow space
      mov r11, offset operandTypeCheckFailureMessage             ; value of argument #1
      push r11                                                   ; (indirect via r11 because "operandTypeCheckFailureMessage" is an imm64)
      push 00000000fh                                            ; type of argument #1
      lea r10, [rbp-090h]                                        ; pointer to return value (and type, 8 bytes earlier)
      push r10                                                   ; (that pointer is the last value pushed to the stack)
      lea r9, [rbp-078h]                                         ; pointer to this
      mov r8, [rbp-080h]                                         ; type of this
      lea rdx, [rbp-088h]                                        ; pointer to closure
      mov rcx, 1                                                 ; number of arguments
      sub rsp, 20h                                               ; allocate shadow space
      call offset func$__print                                   ; jump to subroutine
      add rsp, 038h                                              ; release shadow space and arguments
      mov rcx, [rbp+028h]                                        ; restore rcx from shadow space
      mov rdx, [rbp+030h]                                        ; restore rdx from shadow space
      mov r8, [rbp+038h]                                         ; restore r8 from shadow space
      mov r9, [rbp+040h]                                         ; restore r9 from shadow space
      ;  - exit(1)
      mov qword ptr [rbp-0a0h], 0h                               ; value of this pointer for function call (placeholder)
      mov qword ptr [rbp-0a8h], 000000000h                       ; type of this pointer for function call (placeholder)
      mov qword ptr [rbp-0b0h], 0h                               ; value of closure pointer for function call (placeholder)
      mov [rbp+028h], rcx                                        ; save rcx in shadow space
      mov [rbp+030h], rdx                                        ; save rdx in shadow space
      mov [rbp+038h], r8                                         ; save r8 in shadow space
      mov [rbp+040h], r9                                         ; save r9 in shadow space
      push 000000001h                                            ; value of argument #1
      push 00000000eh                                            ; type of argument #1
      lea r10, [rbp-0b8h]                                        ; pointer to return value (and type, 8 bytes earlier)
      push r10                                                   ; (that pointer is the last value pushed to the stack)
      lea r9, [rbp-0a0h]                                         ; pointer to this
      mov r8, [rbp-0a8h]                                         ; type of this
      lea rdx, [rbp-0b0h]                                        ; pointer to closure
      mov rcx, 1                                                 ; number of arguments
      sub rsp, 20h                                               ; allocate shadow space
      call offset func$exit                                      ; jump to subroutine
      add rsp, 038h                                              ; release shadow space and arguments
      mov rcx, [rbp+028h]                                        ; restore rcx from shadow space
      mov rdx, [rbp+030h]                                        ; restore rdx from shadow space
      mov r8, [rbp+038h]                                         ; restore r8 from shadow space
      mov r9, [rbp+040h]                                         ; restore r9 from shadow space
    func$print$while$index$TypeMatch:
    mov qword ptr [rbp-0118h], 000000000h                        ; clear < operator result
    cmp [rbp-068h], rcx                                          ; compare index to parameter count
    setl byte ptr [rbp-0118h]                                    ; store result in < operator result
    mov qword ptr [rbp-0120h], 00000000dh                        ; < operator result is a Boolean
    cmp qword ptr [rbp-0118h], 000000000h                        ; compare < operator result to false
    je func$print$while$bottom                                   ; while condition
    ; Line 108: if (first == false) { ...
    xor r10, r10                                                 ; prepare r10 for result of value comparison
    cmp qword ptr [rbp-058h], 000000000h                         ; compare first to false
    sete byte ptr r10b                                           ; store result in r10
    xor rax, rax                                                 ; prepare rax for result of type comparison
    cmp qword ptr [rbp-060h], 00000000dh                         ; compare type of first to type of false
    sete byte ptr al                                             ; store result in rax
    and r10, rax                                                 ; true if type and value are both equal; result goes into r10
    mov [rbp-0128h], r10                                         ; store result in == operator result
    mov qword ptr [rbp-0130h], 00000000dh                        ; == operator result is a Boolean
    cmp qword ptr [rbp-0128h], 000000000h                        ; compare == operator result to false
    je func$print$while$if$continuation                          ; first == false
      ; Line 109: __print(' ');
      mov qword ptr [rbp-0138h], 0h                              ; value of this pointer for function call (placeholder)
      mov qword ptr [rbp-0140h], 000000000h                      ; type of this pointer for function call (placeholder)
      mov qword ptr [rbp-0148h], 0h                              ; value of closure pointer for function call (placeholder)
      mov [rbp+028h], rcx                                        ; save rcx in shadow space
      mov [rbp+030h], rdx                                        ; save rdx in shadow space
      mov [rbp+038h], r8                                         ; save r8 in shadow space
      mov [rbp+040h], r9                                         ; save r9 in shadow space
      mov r11, offset string$4                                   ; value of argument #1
      push r11                                                   ; (indirect via r11 because "string$4" is an imm64)
      push 00000000fh                                            ; type of argument #1
      lea r10, [rbp-0150h]                                       ; pointer to return value (and type, 8 bytes earlier)
      push r10                                                   ; (that pointer is the last value pushed to the stack)
      lea r9, [rbp-0138h]                                        ; pointer to this
      mov r8, [rbp-0140h]                                        ; type of this
      lea rdx, [rbp-0148h]                                       ; pointer to closure
      mov rcx, 1                                                 ; number of arguments
      sub rsp, 20h                                               ; allocate shadow space
      call offset func$__print                                   ; jump to subroutine
      add rsp, 038h                                              ; release shadow space and arguments
      mov rcx, [rbp+028h]                                        ; restore rcx from shadow space
      mov rdx, [rbp+030h]                                        ; restore rdx from shadow space
      mov r8, [rbp+038h]                                         ; restore r8 from shadow space
      mov r9, [rbp+040h]                                         ; restore r9 from shadow space
    func$print$while$if$continuation:                            ; end of if
    ; Line 111: __print(_stringify(parts[index]));
    lea r10, [rbp+058h]                                          ; base address of varargs
    mov rax, [rbp-068h]                                          ; index into list
    cmp rax, rcx                                                 ; compare index into varargs to number of arguments
    jge func$print$while$subscript$boundsError                   ; index out of range (too high)
    cmp qword ptr rax, 000000000h                                ; compare index into varargs to zero
    jns func$print$while$subscript$inBounds                      ; index not out of range (not negative)
    func$print$while$subscript$boundsError:
      ; Error handling block for subscript bounds error
      ;  - print(boundsFailureMessage)
      mov qword ptr [rbp-0170h], 0h                              ; value of this pointer for function call (placeholder)
      mov qword ptr [rbp-0178h], 000000000h                      ; type of this pointer for function call (placeholder)
      mov qword ptr [rbp-0180h], 0h                              ; value of closure pointer for function call (placeholder)
      mov [rbp+028h], rcx                                        ; save rcx in shadow space
      mov [rbp+030h], rdx                                        ; save rdx in shadow space
      mov [rbp+038h], r8                                         ; save r8 in shadow space
      mov [rbp+040h], r9                                         ; save r9 in shadow space
      mov r11, offset boundsFailureMessage                       ; value of argument #1
      push r11                                                   ; (indirect via r11 because "boundsFailureMessage" is an imm64)
      push 00000000fh                                            ; type of argument #1
      lea r10, [rbp-0188h]                                       ; pointer to return value (and type, 8 bytes earlier)
      push r10                                                   ; (that pointer is the last value pushed to the stack)
      lea r9, [rbp-0170h]                                        ; pointer to this
      mov r8, [rbp-0178h]                                        ; type of this
      lea rdx, [rbp-0180h]                                       ; pointer to closure
      mov rcx, 1                                                 ; number of arguments
      sub rsp, 20h                                               ; allocate shadow space
      call offset func$__print                                   ; jump to subroutine
      add rsp, 038h                                              ; release shadow space and arguments
      mov rcx, [rbp+028h]                                        ; restore rcx from shadow space
      mov rdx, [rbp+030h]                                        ; restore rdx from shadow space
      mov r8, [rbp+038h]                                         ; restore r8 from shadow space
      mov r9, [rbp+040h]                                         ; restore r9 from shadow space
      ;  - exit(1)
      mov qword ptr [rbp-0198h], 0h                              ; value of this pointer for function call (placeholder)
      mov qword ptr [rbp-01a0h], 000000000h                      ; type of this pointer for function call (placeholder)
      mov qword ptr [rbp-01a8h], 0h                              ; value of closure pointer for function call (placeholder)
      mov [rbp+028h], rcx                                        ; save rcx in shadow space
      mov [rbp+030h], rdx                                        ; save rdx in shadow space
      mov [rbp+038h], r8                                         ; save r8 in shadow space
      mov [rbp+040h], r9                                         ; save r9 in shadow space
      push 000000001h                                            ; value of argument #1
      push 00000000eh                                            ; type of argument #1
      lea r10, [rbp-01b0h]                                       ; pointer to return value (and type, 8 bytes earlier)
      push r10                                                   ; (that pointer is the last value pushed to the stack)
      lea r9, [rbp-0198h]                                        ; pointer to this
      mov r8, [rbp-01a0h]                                        ; type of this
      lea rdx, [rbp-01a8h]                                       ; pointer to closure
      mov rcx, 1                                                 ; number of arguments
      sub rsp, 20h                                               ; allocate shadow space
      call offset func$exit                                      ; jump to subroutine
      add rsp, 038h                                              ; release shadow space and arguments
      mov rcx, [rbp+028h]                                        ; restore rcx from shadow space
      mov rdx, [rbp+030h]                                        ; restore rdx from shadow space
      mov r8, [rbp+038h]                                         ; restore r8 from shadow space
      mov r9, [rbp+040h]                                         ; restore r9 from shadow space
    func$print$while$subscript$inBounds:
    shl rax, 4                                                   ; multiply by 8 * 2 to get to value
    mov r11, [r10+rax]                                           ; store value
    mov [rbp-0160h], r11                                         ; (indirect via r11 because mov can't do memory-to-memory)
    sub rax, 8                                                   ; subtract 8 to get to the type
    mov r11, [r10+rax]                                           ; store type
    mov [rbp-0168h], r11                                         ; (indirect via r11 because mov can't do memory-to-memory)
    mov qword ptr [rbp-01c0h], 0h                                ; value of this pointer for function call (placeholder)
    mov qword ptr [rbp-01c8h], 000000000h                        ; type of this pointer for function call (placeholder)
    mov qword ptr [rbp-01d0h], 0h                                ; value of closure pointer for function call (placeholder)
    mov [rbp+028h], rcx                                          ; save rcx in shadow space
    mov [rbp+030h], rdx                                          ; save rdx in shadow space
    mov [rbp+038h], r8                                           ; save r8 in shadow space
    mov [rbp+040h], r9                                           ; save r9 in shadow space
    push [rbp-0160h]                                             ; value of argument #1
    push [rbp-0168h]                                             ; type of argument #1
    lea r10, [rbp-01d8h]                                         ; pointer to return value (and type, 8 bytes earlier)
    push r10                                                     ; (that pointer is the last value pushed to the stack)
    lea r9, [rbp-01c0h]                                          ; pointer to this
    mov r8, [rbp-01c8h]                                          ; type of this
    lea rdx, [rbp-01d0h]                                         ; pointer to closure
    mov rcx, 1                                                   ; number of arguments
    sub rsp, 20h                                                 ; allocate shadow space
    call offset func$_stringify                                  ; jump to subroutine
    add rsp, 038h                                                ; release shadow space and arguments
    mov rcx, [rbp+028h]                                          ; restore rcx from shadow space
    mov rdx, [rbp+030h]                                          ; restore rdx from shadow space
    mov r8, [rbp+038h]                                           ; restore r8 from shadow space
    mov r9, [rbp+040h]                                           ; restore r9 from shadow space
    mov qword ptr [rbp-01e8h], 0h                                ; value of this pointer for function call (placeholder)
    mov qword ptr [rbp-01f0h], 000000000h                        ; type of this pointer for function call (placeholder)
    mov qword ptr [rbp-01f8h], 0h                                ; value of closure pointer for function call (placeholder)
    mov [rbp+028h], rcx                                          ; save rcx in shadow space
    mov [rbp+030h], rdx                                          ; save rdx in shadow space
    mov [rbp+038h], r8                                           ; save r8 in shadow space
    mov [rbp+040h], r9                                           ; save r9 in shadow space
    push [rbp-01d8h]                                             ; value of argument #1
    push [rbp-01e0h]                                             ; type of argument #1
    lea r10, [rbp-0200h]                                         ; pointer to return value (and type, 8 bytes earlier)
    push r10                                                     ; (that pointer is the last value pushed to the stack)
    lea r9, [rbp-01e8h]                                          ; pointer to this
    mov r8, [rbp-01f0h]                                          ; type of this
    lea rdx, [rbp-01f8h]                                         ; pointer to closure
    mov rcx, 1                                                   ; number of arguments
    sub rsp, 20h                                                 ; allocate shadow space
    call offset func$__print                                     ; jump to subroutine
    add rsp, 038h                                                ; release shadow space and arguments
    mov rcx, [rbp+028h]                                          ; restore rcx from shadow space
    mov rdx, [rbp+030h]                                          ; restore rdx from shadow space
    mov r8, [rbp+038h]                                           ; restore r8 from shadow space
    mov r9, [rbp+040h]                                           ; restore r9 from shadow space
    ; Line 112: first = false;
    mov qword ptr [rbp-058h], 000000000h                         ; value of first
    mov qword ptr [rbp-060h], 00000000dh                         ; type of first
    ; Line 113: index += 1;
    mov rax, [rbp-070h]                                          ; load the dynamic type of <index: Integer at null> into rax
    lea r10, typeTable                                           ; move type table offset into r10
    add rax, r10                                                 ; adjust rax to point to the type table
    bt qword ptr [rax], 2                                        ; check that <index: Integer at null> is Integer'14
    jc func$print$while$IndexINtegerAtNull$TypeMatch             ; skip next block if the type matches
      ; Error handling block for <index: Integer at null>
      ;  - print(operandTypeCheckFailureMessage)
      mov qword ptr [rbp-0220h], 0h                              ; value of this pointer for function call (placeholder)
      mov qword ptr [rbp-0228h], 000000000h                      ; type of this pointer for function call (placeholder)
      mov qword ptr [rbp-0230h], 0h                              ; value of closure pointer for function call (placeholder)
      mov [rbp+028h], rcx                                        ; save rcx in shadow space
      mov [rbp+030h], rdx                                        ; save rdx in shadow space
      mov [rbp+038h], r8                                         ; save r8 in shadow space
      mov [rbp+040h], r9                                         ; save r9 in shadow space
      mov r11, offset operandTypeCheckFailureMessage             ; value of argument #1
      push r11                                                   ; (indirect via r11 because "operandTypeCheckFailureMessage" is an imm64)
      push 00000000fh                                            ; type of argument #1
      lea r10, [rbp-0238h]                                       ; pointer to return value (and type, 8 bytes earlier)
      push r10                                                   ; (that pointer is the last value pushed to the stack)
      lea r9, [rbp-0220h]                                        ; pointer to this
      mov r8, [rbp-0228h]                                        ; type of this
      lea rdx, [rbp-0230h]                                       ; pointer to closure
      mov rcx, 1                                                 ; number of arguments
      sub rsp, 20h                                               ; allocate shadow space
      call offset func$__print                                   ; jump to subroutine
      add rsp, 038h                                              ; release shadow space and arguments
      mov rcx, [rbp+028h]                                        ; restore rcx from shadow space
      mov rdx, [rbp+030h]                                        ; restore rdx from shadow space
      mov r8, [rbp+038h]                                         ; restore r8 from shadow space
      mov r9, [rbp+040h]                                         ; restore r9 from shadow space
      ;  - exit(1)
      mov qword ptr [rbp-0248h], 0h                              ; value of this pointer for function call (placeholder)
      mov qword ptr [rbp-0250h], 000000000h                      ; type of this pointer for function call (placeholder)
      mov qword ptr [rbp-0258h], 0h                              ; value of closure pointer for function call (placeholder)
      mov [rbp+028h], rcx                                        ; save rcx in shadow space
      mov [rbp+030h], rdx                                        ; save rdx in shadow space
      mov [rbp+038h], r8                                         ; save r8 in shadow space
      mov [rbp+040h], r9                                         ; save r9 in shadow space
      push 000000001h                                            ; value of argument #1
      push 00000000eh                                            ; type of argument #1
      lea r10, [rbp-0260h]                                       ; pointer to return value (and type, 8 bytes earlier)
      push r10                                                   ; (that pointer is the last value pushed to the stack)
      lea r9, [rbp-0248h]                                        ; pointer to this
      mov r8, [rbp-0250h]                                        ; type of this
      lea rdx, [rbp-0258h]                                       ; pointer to closure
      mov rcx, 1                                                 ; number of arguments
      sub rsp, 20h                                               ; allocate shadow space
      call offset func$exit                                      ; jump to subroutine
      add rsp, 038h                                              ; release shadow space and arguments
      mov rcx, [rbp+028h]                                        ; restore rcx from shadow space
      mov rdx, [rbp+030h]                                        ; restore rdx from shadow space
      mov r8, [rbp+038h]                                         ; restore r8 from shadow space
      mov r9, [rbp+040h]                                         ; restore r9 from shadow space
    func$print$while$IndexINtegerAtNull$TypeMatch:
    mov r10, [rbp-068h]                                          ; add mutates first operand, so indirect via register
    add r10, 000000001h                                          ; += operator
    mov [rbp-0210h], r10                                         ; store result
    mov qword ptr [rbp-0218h], 00000000eh                        ; store type
    mov r11, [rbp-0210h]                                         ; value of index
    mov [rbp-068h], r11                                          ; (indirect via r11 because mov can't do memory-to-memory)
    mov r11, [rbp-0218h]                                         ; type of index
    mov [rbp-070h], r11                                          ; (indirect via r11 because mov can't do memory-to-memory)
    jmp func$print$while$top                                     ; return to top of while
  func$print$while$bottom:
  func$print$epilog:
  mov rax, r15                                                   ; report address of return value
  ; Epilog
  add rsp, 02b8h                                                 ; free space for stack
  pop rdi                                                        ; restore non-volatile registers
  pop rsi                                                        ; restore non-volatile registers
  pop r15                                                        ; restore non-volatile registers
  pop rbp                                                        ; restore non-volatile registers
  ret                                                            ; return from subroutine

; println
func$println:
  ; Prolog
  push rbp                                                       ; save non-volatile registers
  push r15                                                       ; save non-volatile registers
  push rsi                                                       ; save non-volatile registers
  push rdi                                                       ; save non-volatile registers
  sub rsp, 02e0h                                                 ; allocate space for stack
  lea rbp, [rsp+02e0h]                                           ; set up frame pointer
  mov r15, [rbp+048h]                                            ; prepare return value
  lea rsi, [rbp+00000000000000058h]                              ; initial index pointing to value of first argument
  mov rdi, rcx                                                   ; end of loop is the number of arguments...
  shl rdi, 5                                                     ; ...times the width of each argument (010h)...
  add rdi, rsi                                                   ; ...offset from the initial index
  func$println$varargTypeChecks$Loop:
    cmp rsi, rdi                                                 ; compare pointer to current argument to end of loop
    je func$println$varargTypeChecks$TypesAllMatch               ; we have type-checked all the arguments
    mov rax, [rsi-008h]                                          ; load the dynamic type of vararg types into rax
    lea r10, typeTable                                           ; move type table offset into r10
    add rax, r10                                                 ; adjust rax to point to the type table
    bt qword ptr [rax], 3                                        ; check that vararg types is String'15
    jc func$println$varargTypeChecks$TypeMatch                   ; skip next block if the type matches
      ; Error handling block for vararg types
      ;  - print(parameterTypeCheckFailureMessage)
      mov qword ptr [rbp-008h], 0h                               ; value of this pointer for function call (placeholder)
      mov qword ptr [rbp-010h], 000000000h                       ; type of this pointer for function call (placeholder)
      mov qword ptr [rbp-018h], 0h                               ; value of closure pointer for function call (placeholder)
      mov [rbp+028h], rcx                                        ; save rcx in shadow space
      mov [rbp+030h], rdx                                        ; save rdx in shadow space
      mov [rbp+038h], r8                                         ; save r8 in shadow space
      mov [rbp+040h], r9                                         ; save r9 in shadow space
      mov r11, offset parameterTypeCheckFailureMessage           ; value of argument #1
      push r11                                                   ; (indirect via r11 because "parameterTypeCheckFailureMessage" is an imm64)
      push 00000000fh                                            ; type of argument #1
      lea r10, [rbp-020h]                                        ; pointer to return value (and type, 8 bytes earlier)
      push r10                                                   ; (that pointer is the last value pushed to the stack)
      lea r9, [rbp-008h]                                         ; pointer to this
      mov r8, [rbp-010h]                                         ; type of this
      lea rdx, [rbp-018h]                                        ; pointer to closure
      mov rcx, 1                                                 ; number of arguments
      sub rsp, 20h                                               ; allocate shadow space
      call offset func$__print                                   ; jump to subroutine
      add rsp, 038h                                              ; release shadow space and arguments
      mov rcx, [rbp+028h]                                        ; restore rcx from shadow space
      mov rdx, [rbp+030h]                                        ; restore rdx from shadow space
      mov r8, [rbp+038h]                                         ; restore r8 from shadow space
      mov r9, [rbp+040h]                                         ; restore r9 from shadow space
      ;  - exit(1)
      mov qword ptr [rbp-030h], 0h                               ; value of this pointer for function call (placeholder)
      mov qword ptr [rbp-038h], 000000000h                       ; type of this pointer for function call (placeholder)
      mov qword ptr [rbp-040h], 0h                               ; value of closure pointer for function call (placeholder)
      mov [rbp+028h], rcx                                        ; save rcx in shadow space
      mov [rbp+030h], rdx                                        ; save rdx in shadow space
      mov [rbp+038h], r8                                         ; save r8 in shadow space
      mov [rbp+040h], r9                                         ; save r9 in shadow space
      push 000000001h                                            ; value of argument #1
      push 00000000eh                                            ; type of argument #1
      lea r10, [rbp-048h]                                        ; pointer to return value (and type, 8 bytes earlier)
      push r10                                                   ; (that pointer is the last value pushed to the stack)
      lea r9, [rbp-030h]                                         ; pointer to this
      mov r8, [rbp-038h]                                         ; type of this
      lea rdx, [rbp-040h]                                        ; pointer to closure
      mov rcx, 1                                                 ; number of arguments
      sub rsp, 20h                                               ; allocate shadow space
      call offset func$exit                                      ; jump to subroutine
      add rsp, 038h                                              ; release shadow space and arguments
      mov rcx, [rbp+028h]                                        ; restore rcx from shadow space
      mov rdx, [rbp+030h]                                        ; restore rdx from shadow space
      mov r8, [rbp+038h]                                         ; restore r8 from shadow space
      mov r9, [rbp+040h]                                         ; restore r9 from shadow space
    func$println$varargTypeChecks$TypeMatch:
    add rsi, 010h                                                ; next argument
    jmp func$println$varargTypeChecks$Loop                       ; return to top of loop
  func$println$varargTypeChecks$TypesAllMatch:
  ; Line 118: Boolean first = true;
  mov qword ptr [rbp-058h], 000000001h                           ; value of first
  mov qword ptr [rbp-060h], 00000000dh                           ; type of first
  ; Line 119: Integer index = 0;
  mov qword ptr [rbp-068h], 000000000h                           ; value of index
  mov qword ptr [rbp-070h], 00000000eh                           ; type of index
  ; Line 120: while (index < len(parts)) { ...
  func$println$while$top:
    mov rax, [rbp-070h]                                          ; load the dynamic type of index into rax
    lea r10, typeTable                                           ; move type table offset into r10
    add rax, r10                                                 ; adjust rax to point to the type table
    bt qword ptr [rax], 2                                        ; check that index is Integer'14
    jc func$println$while$index$TypeMatch                        ; skip next block if the type matches
      ; Error handling block for index
      ;  - print(operandTypeCheckFailureMessage)
      mov qword ptr [rbp-078h], 0h                               ; value of this pointer for function call (placeholder)
      mov qword ptr [rbp-080h], 000000000h                       ; type of this pointer for function call (placeholder)
      mov qword ptr [rbp-088h], 0h                               ; value of closure pointer for function call (placeholder)
      mov [rbp+028h], rcx                                        ; save rcx in shadow space
      mov [rbp+030h], rdx                                        ; save rdx in shadow space
      mov [rbp+038h], r8                                         ; save r8 in shadow space
      mov [rbp+040h], r9                                         ; save r9 in shadow space
      mov r11, offset operandTypeCheckFailureMessage             ; value of argument #1
      push r11                                                   ; (indirect via r11 because "operandTypeCheckFailureMessage" is an imm64)
      push 00000000fh                                            ; type of argument #1
      lea r10, [rbp-090h]                                        ; pointer to return value (and type, 8 bytes earlier)
      push r10                                                   ; (that pointer is the last value pushed to the stack)
      lea r9, [rbp-078h]                                         ; pointer to this
      mov r8, [rbp-080h]                                         ; type of this
      lea rdx, [rbp-088h]                                        ; pointer to closure
      mov rcx, 1                                                 ; number of arguments
      sub rsp, 20h                                               ; allocate shadow space
      call offset func$__print                                   ; jump to subroutine
      add rsp, 038h                                              ; release shadow space and arguments
      mov rcx, [rbp+028h]                                        ; restore rcx from shadow space
      mov rdx, [rbp+030h]                                        ; restore rdx from shadow space
      mov r8, [rbp+038h]                                         ; restore r8 from shadow space
      mov r9, [rbp+040h]                                         ; restore r9 from shadow space
      ;  - exit(1)
      mov qword ptr [rbp-0a0h], 0h                               ; value of this pointer for function call (placeholder)
      mov qword ptr [rbp-0a8h], 000000000h                       ; type of this pointer for function call (placeholder)
      mov qword ptr [rbp-0b0h], 0h                               ; value of closure pointer for function call (placeholder)
      mov [rbp+028h], rcx                                        ; save rcx in shadow space
      mov [rbp+030h], rdx                                        ; save rdx in shadow space
      mov [rbp+038h], r8                                         ; save r8 in shadow space
      mov [rbp+040h], r9                                         ; save r9 in shadow space
      push 000000001h                                            ; value of argument #1
      push 00000000eh                                            ; type of argument #1
      lea r10, [rbp-0b8h]                                        ; pointer to return value (and type, 8 bytes earlier)
      push r10                                                   ; (that pointer is the last value pushed to the stack)
      lea r9, [rbp-0a0h]                                         ; pointer to this
      mov r8, [rbp-0a8h]                                         ; type of this
      lea rdx, [rbp-0b0h]                                        ; pointer to closure
      mov rcx, 1                                                 ; number of arguments
      sub rsp, 20h                                               ; allocate shadow space
      call offset func$exit                                      ; jump to subroutine
      add rsp, 038h                                              ; release shadow space and arguments
      mov rcx, [rbp+028h]                                        ; restore rcx from shadow space
      mov rdx, [rbp+030h]                                        ; restore rdx from shadow space
      mov r8, [rbp+038h]                                         ; restore r8 from shadow space
      mov r9, [rbp+040h]                                         ; restore r9 from shadow space
    func$println$while$index$TypeMatch:
    mov qword ptr [rbp-0118h], 000000000h                        ; clear < operator result
    cmp [rbp-068h], rcx                                          ; compare index to parameter count
    setl byte ptr [rbp-0118h]                                    ; store result in < operator result
    mov qword ptr [rbp-0120h], 00000000dh                        ; < operator result is a Boolean
    cmp qword ptr [rbp-0118h], 000000000h                        ; compare < operator result to false
    je func$println$while$bottom                                 ; while condition
    ; Line 121: if (first == false) { ...
    xor r10, r10                                                 ; prepare r10 for result of value comparison
    cmp qword ptr [rbp-058h], 000000000h                         ; compare first to false
    sete byte ptr r10b                                           ; store result in r10
    xor rax, rax                                                 ; prepare rax for result of type comparison
    cmp qword ptr [rbp-060h], 00000000dh                         ; compare type of first to type of false
    sete byte ptr al                                             ; store result in rax
    and r10, rax                                                 ; true if type and value are both equal; result goes into r10
    mov [rbp-0128h], r10                                         ; store result in == operator result
    mov qword ptr [rbp-0130h], 00000000dh                        ; == operator result is a Boolean
    cmp qword ptr [rbp-0128h], 000000000h                        ; compare == operator result to false
    je func$println$while$if$continuation                        ; first == false
      ; Line 122: __print(' ');
      mov qword ptr [rbp-0138h], 0h                              ; value of this pointer for function call (placeholder)
      mov qword ptr [rbp-0140h], 000000000h                      ; type of this pointer for function call (placeholder)
      mov qword ptr [rbp-0148h], 0h                              ; value of closure pointer for function call (placeholder)
      mov [rbp+028h], rcx                                        ; save rcx in shadow space
      mov [rbp+030h], rdx                                        ; save rdx in shadow space
      mov [rbp+038h], r8                                         ; save r8 in shadow space
      mov [rbp+040h], r9                                         ; save r9 in shadow space
      mov r11, offset string$4                                   ; value of argument #1
      push r11                                                   ; (indirect via r11 because "string$4" is an imm64)
      push 00000000fh                                            ; type of argument #1
      lea r10, [rbp-0150h]                                       ; pointer to return value (and type, 8 bytes earlier)
      push r10                                                   ; (that pointer is the last value pushed to the stack)
      lea r9, [rbp-0138h]                                        ; pointer to this
      mov r8, [rbp-0140h]                                        ; type of this
      lea rdx, [rbp-0148h]                                       ; pointer to closure
      mov rcx, 1                                                 ; number of arguments
      sub rsp, 20h                                               ; allocate shadow space
      call offset func$__print                                   ; jump to subroutine
      add rsp, 038h                                              ; release shadow space and arguments
      mov rcx, [rbp+028h]                                        ; restore rcx from shadow space
      mov rdx, [rbp+030h]                                        ; restore rdx from shadow space
      mov r8, [rbp+038h]                                         ; restore r8 from shadow space
      mov r9, [rbp+040h]                                         ; restore r9 from shadow space
    func$println$while$if$continuation:                          ; end of if
    ; Line 124: __print(_stringify(parts[index]));
    lea r10, [rbp+058h]                                          ; base address of varargs
    mov rax, [rbp-068h]                                          ; index into list
    cmp rax, rcx                                                 ; compare index into varargs to number of arguments
    jge func$println$while$subscript$boundsError                 ; index out of range (too high)
    cmp qword ptr rax, 000000000h                                ; compare index into varargs to zero
    jns func$println$while$subscript$inBounds                    ; index not out of range (not negative)
    func$println$while$subscript$boundsError:
      ; Error handling block for subscript bounds error
      ;  - print(boundsFailureMessage)
      mov qword ptr [rbp-0170h], 0h                              ; value of this pointer for function call (placeholder)
      mov qword ptr [rbp-0178h], 000000000h                      ; type of this pointer for function call (placeholder)
      mov qword ptr [rbp-0180h], 0h                              ; value of closure pointer for function call (placeholder)
      mov [rbp+028h], rcx                                        ; save rcx in shadow space
      mov [rbp+030h], rdx                                        ; save rdx in shadow space
      mov [rbp+038h], r8                                         ; save r8 in shadow space
      mov [rbp+040h], r9                                         ; save r9 in shadow space
      mov r11, offset boundsFailureMessage                       ; value of argument #1
      push r11                                                   ; (indirect via r11 because "boundsFailureMessage" is an imm64)
      push 00000000fh                                            ; type of argument #1
      lea r10, [rbp-0188h]                                       ; pointer to return value (and type, 8 bytes earlier)
      push r10                                                   ; (that pointer is the last value pushed to the stack)
      lea r9, [rbp-0170h]                                        ; pointer to this
      mov r8, [rbp-0178h]                                        ; type of this
      lea rdx, [rbp-0180h]                                       ; pointer to closure
      mov rcx, 1                                                 ; number of arguments
      sub rsp, 20h                                               ; allocate shadow space
      call offset func$__print                                   ; jump to subroutine
      add rsp, 038h                                              ; release shadow space and arguments
      mov rcx, [rbp+028h]                                        ; restore rcx from shadow space
      mov rdx, [rbp+030h]                                        ; restore rdx from shadow space
      mov r8, [rbp+038h]                                         ; restore r8 from shadow space
      mov r9, [rbp+040h]                                         ; restore r9 from shadow space
      ;  - exit(1)
      mov qword ptr [rbp-0198h], 0h                              ; value of this pointer for function call (placeholder)
      mov qword ptr [rbp-01a0h], 000000000h                      ; type of this pointer for function call (placeholder)
      mov qword ptr [rbp-01a8h], 0h                              ; value of closure pointer for function call (placeholder)
      mov [rbp+028h], rcx                                        ; save rcx in shadow space
      mov [rbp+030h], rdx                                        ; save rdx in shadow space
      mov [rbp+038h], r8                                         ; save r8 in shadow space
      mov [rbp+040h], r9                                         ; save r9 in shadow space
      push 000000001h                                            ; value of argument #1
      push 00000000eh                                            ; type of argument #1
      lea r10, [rbp-01b0h]                                       ; pointer to return value (and type, 8 bytes earlier)
      push r10                                                   ; (that pointer is the last value pushed to the stack)
      lea r9, [rbp-0198h]                                        ; pointer to this
      mov r8, [rbp-01a0h]                                        ; type of this
      lea rdx, [rbp-01a8h]                                       ; pointer to closure
      mov rcx, 1                                                 ; number of arguments
      sub rsp, 20h                                               ; allocate shadow space
      call offset func$exit                                      ; jump to subroutine
      add rsp, 038h                                              ; release shadow space and arguments
      mov rcx, [rbp+028h]                                        ; restore rcx from shadow space
      mov rdx, [rbp+030h]                                        ; restore rdx from shadow space
      mov r8, [rbp+038h]                                         ; restore r8 from shadow space
      mov r9, [rbp+040h]                                         ; restore r9 from shadow space
    func$println$while$subscript$inBounds:
    shl rax, 4                                                   ; multiply by 8 * 2 to get to value
    mov r11, [r10+rax]                                           ; store value
    mov [rbp-0160h], r11                                         ; (indirect via r11 because mov can't do memory-to-memory)
    sub rax, 8                                                   ; subtract 8 to get to the type
    mov r11, [r10+rax]                                           ; store type
    mov [rbp-0168h], r11                                         ; (indirect via r11 because mov can't do memory-to-memory)
    mov qword ptr [rbp-01c0h], 0h                                ; value of this pointer for function call (placeholder)
    mov qword ptr [rbp-01c8h], 000000000h                        ; type of this pointer for function call (placeholder)
    mov qword ptr [rbp-01d0h], 0h                                ; value of closure pointer for function call (placeholder)
    mov [rbp+028h], rcx                                          ; save rcx in shadow space
    mov [rbp+030h], rdx                                          ; save rdx in shadow space
    mov [rbp+038h], r8                                           ; save r8 in shadow space
    mov [rbp+040h], r9                                           ; save r9 in shadow space
    push [rbp-0160h]                                             ; value of argument #1
    push [rbp-0168h]                                             ; type of argument #1
    lea r10, [rbp-01d8h]                                         ; pointer to return value (and type, 8 bytes earlier)
    push r10                                                     ; (that pointer is the last value pushed to the stack)
    lea r9, [rbp-01c0h]                                          ; pointer to this
    mov r8, [rbp-01c8h]                                          ; type of this
    lea rdx, [rbp-01d0h]                                         ; pointer to closure
    mov rcx, 1                                                   ; number of arguments
    sub rsp, 20h                                                 ; allocate shadow space
    call offset func$_stringify                                  ; jump to subroutine
    add rsp, 038h                                                ; release shadow space and arguments
    mov rcx, [rbp+028h]                                          ; restore rcx from shadow space
    mov rdx, [rbp+030h]                                          ; restore rdx from shadow space
    mov r8, [rbp+038h]                                           ; restore r8 from shadow space
    mov r9, [rbp+040h]                                           ; restore r9 from shadow space
    mov qword ptr [rbp-01e8h], 0h                                ; value of this pointer for function call (placeholder)
    mov qword ptr [rbp-01f0h], 000000000h                        ; type of this pointer for function call (placeholder)
    mov qword ptr [rbp-01f8h], 0h                                ; value of closure pointer for function call (placeholder)
    mov [rbp+028h], rcx                                          ; save rcx in shadow space
    mov [rbp+030h], rdx                                          ; save rdx in shadow space
    mov [rbp+038h], r8                                           ; save r8 in shadow space
    mov [rbp+040h], r9                                           ; save r9 in shadow space
    push [rbp-01d8h]                                             ; value of argument #1
    push [rbp-01e0h]                                             ; type of argument #1
    lea r10, [rbp-0200h]                                         ; pointer to return value (and type, 8 bytes earlier)
    push r10                                                     ; (that pointer is the last value pushed to the stack)
    lea r9, [rbp-01e8h]                                          ; pointer to this
    mov r8, [rbp-01f0h]                                          ; type of this
    lea rdx, [rbp-01f8h]                                         ; pointer to closure
    mov rcx, 1                                                   ; number of arguments
    sub rsp, 20h                                                 ; allocate shadow space
    call offset func$__print                                     ; jump to subroutine
    add rsp, 038h                                                ; release shadow space and arguments
    mov rcx, [rbp+028h]                                          ; restore rcx from shadow space
    mov rdx, [rbp+030h]                                          ; restore rdx from shadow space
    mov r8, [rbp+038h]                                           ; restore r8 from shadow space
    mov r9, [rbp+040h]                                           ; restore r9 from shadow space
    ; Line 125: first = false;
    mov qword ptr [rbp-058h], 000000000h                         ; value of first
    mov qword ptr [rbp-060h], 00000000dh                         ; type of first
    ; Line 126: index += 1;
    mov rax, [rbp-070h]                                          ; load the dynamic type of <index: Integer at null> into rax
    lea r10, typeTable                                           ; move type table offset into r10
    add rax, r10                                                 ; adjust rax to point to the type table
    bt qword ptr [rax], 2                                        ; check that <index: Integer at null> is Integer'14
    jc func$println$while$IndexINtegerAtNull$TypeMatch           ; skip next block if the type matches
      ; Error handling block for <index: Integer at null>
      ;  - print(operandTypeCheckFailureMessage)
      mov qword ptr [rbp-0220h], 0h                              ; value of this pointer for function call (placeholder)
      mov qword ptr [rbp-0228h], 000000000h                      ; type of this pointer for function call (placeholder)
      mov qword ptr [rbp-0230h], 0h                              ; value of closure pointer for function call (placeholder)
      mov [rbp+028h], rcx                                        ; save rcx in shadow space
      mov [rbp+030h], rdx                                        ; save rdx in shadow space
      mov [rbp+038h], r8                                         ; save r8 in shadow space
      mov [rbp+040h], r9                                         ; save r9 in shadow space
      mov r11, offset operandTypeCheckFailureMessage             ; value of argument #1
      push r11                                                   ; (indirect via r11 because "operandTypeCheckFailureMessage" is an imm64)
      push 00000000fh                                            ; type of argument #1
      lea r10, [rbp-0238h]                                       ; pointer to return value (and type, 8 bytes earlier)
      push r10                                                   ; (that pointer is the last value pushed to the stack)
      lea r9, [rbp-0220h]                                        ; pointer to this
      mov r8, [rbp-0228h]                                        ; type of this
      lea rdx, [rbp-0230h]                                       ; pointer to closure
      mov rcx, 1                                                 ; number of arguments
      sub rsp, 20h                                               ; allocate shadow space
      call offset func$__print                                   ; jump to subroutine
      add rsp, 038h                                              ; release shadow space and arguments
      mov rcx, [rbp+028h]                                        ; restore rcx from shadow space
      mov rdx, [rbp+030h]                                        ; restore rdx from shadow space
      mov r8, [rbp+038h]                                         ; restore r8 from shadow space
      mov r9, [rbp+040h]                                         ; restore r9 from shadow space
      ;  - exit(1)
      mov qword ptr [rbp-0248h], 0h                              ; value of this pointer for function call (placeholder)
      mov qword ptr [rbp-0250h], 000000000h                      ; type of this pointer for function call (placeholder)
      mov qword ptr [rbp-0258h], 0h                              ; value of closure pointer for function call (placeholder)
      mov [rbp+028h], rcx                                        ; save rcx in shadow space
      mov [rbp+030h], rdx                                        ; save rdx in shadow space
      mov [rbp+038h], r8                                         ; save r8 in shadow space
      mov [rbp+040h], r9                                         ; save r9 in shadow space
      push 000000001h                                            ; value of argument #1
      push 00000000eh                                            ; type of argument #1
      lea r10, [rbp-0260h]                                       ; pointer to return value (and type, 8 bytes earlier)
      push r10                                                   ; (that pointer is the last value pushed to the stack)
      lea r9, [rbp-0248h]                                        ; pointer to this
      mov r8, [rbp-0250h]                                        ; type of this
      lea rdx, [rbp-0258h]                                       ; pointer to closure
      mov rcx, 1                                                 ; number of arguments
      sub rsp, 20h                                               ; allocate shadow space
      call offset func$exit                                      ; jump to subroutine
      add rsp, 038h                                              ; release shadow space and arguments
      mov rcx, [rbp+028h]                                        ; restore rcx from shadow space
      mov rdx, [rbp+030h]                                        ; restore rdx from shadow space
      mov r8, [rbp+038h]                                         ; restore r8 from shadow space
      mov r9, [rbp+040h]                                         ; restore r9 from shadow space
    func$println$while$IndexINtegerAtNull$TypeMatch:
    mov r10, [rbp-068h]                                          ; add mutates first operand, so indirect via register
    add r10, 000000001h                                          ; += operator
    mov [rbp-0210h], r10                                         ; store result
    mov qword ptr [rbp-0218h], 00000000eh                        ; store type
    mov r11, [rbp-0210h]                                         ; value of index
    mov [rbp-068h], r11                                          ; (indirect via r11 because mov can't do memory-to-memory)
    mov r11, [rbp-0218h]                                         ; type of index
    mov [rbp-070h], r11                                          ; (indirect via r11 because mov can't do memory-to-memory)
    jmp func$println$while$top                                   ; return to top of while
  func$println$while$bottom:
  ; Line 128: __print('\n');
  mov qword ptr [rbp-02c0h], 0h                                  ; value of this pointer for function call (placeholder)
  mov qword ptr [rbp-02c8h], 000000000h                          ; type of this pointer for function call (placeholder)
  mov qword ptr [rbp-02d0h], 0h                                  ; value of closure pointer for function call (placeholder)
  mov [rbp+028h], rcx                                            ; save rcx in shadow space
  mov [rbp+030h], rdx                                            ; save rdx in shadow space
  mov [rbp+038h], r8                                             ; save r8 in shadow space
  mov [rbp+040h], r9                                             ; save r9 in shadow space
  mov r11, offset string$5                                       ; value of argument #1
  push r11                                                       ; (indirect via r11 because "string$5" is an imm64)
  push 00000000fh                                                ; type of argument #1
  lea r10, [rbp-02d8h]                                           ; pointer to return value (and type, 8 bytes earlier)
  push r10                                                       ; (that pointer is the last value pushed to the stack)
  lea r9, [rbp-02c0h]                                            ; pointer to this
  mov r8, [rbp-02c8h]                                            ; type of this
  lea rdx, [rbp-02d0h]                                           ; pointer to closure
  mov rcx, 1                                                     ; number of arguments
  sub rsp, 20h                                                   ; allocate shadow space
  call offset func$__print                                       ; jump to subroutine
  add rsp, 038h                                                  ; release shadow space and arguments
  mov rcx, [rbp+028h]                                            ; restore rcx from shadow space
  mov rdx, [rbp+030h]                                            ; restore rdx from shadow space
  mov r8, [rbp+038h]                                             ; restore r8 from shadow space
  mov r9, [rbp+040h]                                             ; restore r9 from shadow space
  func$println$epilog:
  mov rax, r15                                                   ; report address of return value
  ; Epilog
  add rsp, 02e0h                                                 ; free space for stack
  pop rdi                                                        ; restore non-volatile registers
  pop rsi                                                        ; restore non-volatile registers
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
    push 00000000fh                                              ; type of argument #1
    lea r10, [rbp-020h]                                          ; pointer to return value (and type, 8 bytes earlier)
    push r10                                                     ; (that pointer is the last value pushed to the stack)
    lea r9, [rbp-008h]                                           ; pointer to this
    mov r8, [rbp-010h]                                           ; type of this
    lea rdx, [rbp-018h]                                          ; pointer to closure
    mov rcx, 1                                                   ; number of arguments
    sub rsp, 20h                                                 ; allocate shadow space
    call offset func$__print                                     ; jump to subroutine
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
    push 00000000eh                                              ; type of argument #1
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
  bt qword ptr [rax], 3                                          ; check that data is String'15
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
    push 00000000fh                                              ; type of argument #1
    lea r10, [rbp-070h]                                          ; pointer to return value (and type, 8 bytes earlier)
    push r10                                                     ; (that pointer is the last value pushed to the stack)
    lea r9, [rbp-058h]                                           ; pointer to this
    mov r8, [rbp-060h]                                           ; type of this
    lea rdx, [rbp-068h]                                          ; pointer to closure
    mov rcx, 1                                                   ; number of arguments
    sub rsp, 20h                                                 ; allocate shadow space
    call offset func$__print                                     ; jump to subroutine
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
    push 00000000eh                                              ; type of argument #1
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
  mov qword ptr [rbp-0b0h], 00000000eh                           ; new type of force cast of data to Integer
  ; Line 7: return __readFromAddress(pointer + 8);
  mov rax, [rbp-0b0h]                                            ; load the dynamic type of pointer into rax
  lea r10, typeTable                                             ; move type table offset into r10
  add rax, r10                                                   ; adjust rax to point to the type table
  bt qword ptr [rax], 2                                          ; check that pointer is Integer'14
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
    push 00000000fh                                              ; type of argument #1
    lea r10, [rbp-0d0h]                                          ; pointer to return value (and type, 8 bytes earlier)
    push r10                                                     ; (that pointer is the last value pushed to the stack)
    lea r9, [rbp-0b8h]                                           ; pointer to this
    mov r8, [rbp-0c0h]                                           ; type of this
    lea rdx, [rbp-0c8h]                                          ; pointer to closure
    mov rcx, 1                                                   ; number of arguments
    sub rsp, 20h                                                 ; allocate shadow space
    call offset func$__print                                     ; jump to subroutine
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
    push 00000000eh                                              ; type of argument #1
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
  mov qword ptr [rbp-0160h], 00000000eh                          ; store type
  mov r10, [rbp-0158h]                                           ; value of + operator result
  mov r11, [r10]                                                 ; dereference + operator result and put result in address of + operator result
  mov [rbp-0168h], r11                                           ; (indirect via r11 because mov can't do memory-to-memory)
  mov qword ptr [rbp-0170h], 00000000eh                          ; type of address of + operator result
  mov rax, [rbp-0170h]                                           ; load the dynamic type of return value of _stringAllocLength into rax
  lea r10, typeTable                                             ; move type table offset into r10
  add rax, r10                                                   ; adjust rax to point to the type table
  bt qword ptr [rax], 2                                          ; check that return value of _stringAllocLength is Integer'14
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
    push 00000000fh                                              ; type of argument #1
    lea r10, [rbp-0190h]                                         ; pointer to return value (and type, 8 bytes earlier)
    push r10                                                     ; (that pointer is the last value pushed to the stack)
    lea r9, [rbp-0178h]                                          ; pointer to this
    mov r8, [rbp-0180h]                                          ; type of this
    lea rdx, [rbp-0188h]                                         ; pointer to closure
    mov rcx, 1                                                   ; number of arguments
    sub rsp, 20h                                                 ; allocate shadow space
    call offset func$__print                                     ; jump to subroutine
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
    push 00000000eh                                              ; type of argument #1
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

