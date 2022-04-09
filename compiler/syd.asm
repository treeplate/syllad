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
  typeTable    db 003h, 000h, 000h, 000h, 000h, 000h, 001h, 002h ; Type table
   ; Columns: Integer'6 String'7
   ; 1 1   <sentinel>'0
   ; 0 0   Null'1
   ; 0 0   Boolean'2
   ; 0 0   NullFunction(String)'3
   ; 0 0   NullFunction(Integer)'4
   ; 0 0   IntegerFunction(WhateverReadOnlyList)'5
   ; 1 0   Integer'6
   ; 0 1   String'7

  parameterCountCheckFailureMessage dq -01h                      ; String constant (reference count)
               dq 88                                             ; Length
               db "error: function call received the wrong number of parameters (expected %d, received %d)", 0ah ; line 200 column 25 in file syd-compiler.syd
               db 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h         ; padding to align to 8-byte boundary
  parameterTypeCheckFailureMessage dq -01h                       ; String constant (reference count)
               dq 71                                             ; Length
               db "error: type mismatch for function %s parameter %d, expected %s, got %s", 0ah ; line 205 column 25 in file syd-compiler.syd
               db 00h                                            ; padding to align to 8-byte boundary
  returnValueTypeCheckFailureMessage dq -01h                     ; String constant (reference count)
               dq 68                                             ; Length
               db "error: type mismatch for function return value, expected %s, got %s", 0ah ; line 210 column 25 in file syd-compiler.syd
               db 00h, 00h, 00h, 00h                             ; padding to align to 8-byte boundary
  operandTypeCheckFailureMessage dq -01h                         ; String constant (reference count)
               dq 54                                             ; Length
               db "error: type mismatch for operand, expected %s, got %s", 0ah ; line 215 column 25 in file syd-compiler.syd
               db 00h, 00h                                       ; padding to align to 8-byte boundary
  asOperatorFailureMessage dq -01h                               ; String constant (reference count)
               dq 58                                             ; Length
               db "error: type mismatch for as operator, expected %s, got %s", 0ah ; line 220 column 25 in file syd-compiler.syd
               db 00h, 00h, 00h, 00h, 00h, 00h                   ; padding to align to 8-byte boundary
  boundsFailureMessage dq -01h                                   ; String constant (reference count)
               dq 64                                             ; Length
               db "error: subscript index out of range (%d is not in range %d..%d)", 0ah ; line 225 column 25 in file syd-compiler.syd
               db 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h         ; padding to align to 8-byte boundary
  string       dq -01h                                           ; String constant (reference count)
               dq 3                                              ; Length
               db "Foo"                                          ; line 5 column 5 in file temp.syd
               db 00h, 00h, 00h, 00h, 00h                        ; padding to align to 8-byte boundary
  string$1     dq -01h                                           ; String constant (reference count)
               dq 1                                              ; Length
               db "a"                                            ; line 6 column 15 in file temp.syd
               db 00h, 00h, 00h, 00h, 00h, 00h, 00h              ; padding to align to 8-byte boundary
  string$2     dq -01h                                           ; String constant (reference count)
               dq 1                                              ; Length
               db "b"                                            ; line 7 column 15 in file temp.syd
               db 00h, 00h, 00h, 00h, 00h, 00h, 00h              ; padding to align to 8-byte boundary
  string$3     dq -01h                                           ; String constant (reference count)
               dq 21                                             ; Length
               db "strings are in order", 0ah                    ; line 9 column 32 in file temp.syd
               db 00h, 00h, 00h                                  ; padding to align to 8-byte boundary
  string$4     dq -01h                                           ; String constant (reference count)
               dq 32                                             ; Length
               db "strings are aligned as expected", 0ah         ; line 12 column 43 in file temp.syd
               db 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h         ; padding to align to 8-byte boundary

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
  sub rsp, 0368h                                                 ; allocate space for stack
  lea rbp, [rsp+0368h]                                           ; set up frame pointer
  ; Line 6: Integer a = 'a' __as__ Integer;
  mov r11, offset string$1                                       ; value of force cast of 'a' to Integer
  mov [rbp-008h], r11                                            ; (indirect via r11 because "string$1" is an imm64)
  mov qword ptr [rbp-010h], 000000006h                           ; new type of force cast of 'a' to Integer
  ; Line 7: Integer b = 'b' __as__ Integer;
  mov r11, offset string$2                                       ; value of force cast of 'b' to Integer
  mov [rbp-018h], r11                                            ; (indirect via r11 because "string$2" is an imm64)
  mov qword ptr [rbp-020h], 000000006h                           ; new type of force cast of 'b' to Integer
  ; Line 8: if (a < b) { ...
  mov rax, [rbp-010h]                                            ; load the dynamic type of a into rax
  lea r10, typeTable                                             ; move type table offset into r10
  add rax, r10                                                   ; adjust rax to point to the type table
  bt qword ptr [rax], 0                                          ; check that a is Integer'6
  jc tempSyd$a$TypeMatch                                         ; skip next block if the type matches
    ; Error handling block for a
    ;  - print(operandTypeCheckFailureMessage)
    mov qword ptr [rbp-028h], 0h                                 ; value of this pointer for function call (placeholder)
    mov qword ptr [rbp-030h], 000000000h                         ; type of this pointer for function call (placeholder)
    mov qword ptr [rbp-038h], 0h                                 ; value of closure pointer for function call (placeholder)
    mov [rbp+010h], rcx                                          ; save rcx in shadow space
    mov [rbp+018h], rdx                                          ; save rdx in shadow space
    mov [rbp+020h], r8                                           ; save r8 in shadow space
    mov [rbp+028h], r9                                           ; save r9 in shadow space
    mov r11, offset operandTypeCheckFailureMessage               ; value of argument #1
    push r11                                                     ; (indirect via r11 because "operandTypeCheckFailureMessage" is an imm64)
    push 000000007h                                              ; type of argument #1
    lea r10, [rbp-040h]                                          ; pointer to return value (and type, 8 bytes earlier)
    push r10                                                     ; (that pointer is the last value pushed to the stack)
    lea r9, [rbp-028h]                                           ; pointer to this
    mov r8, [rbp-030h]                                           ; type of this
    lea rdx, [rbp-038h]                                          ; pointer to closure
    mov rcx, 1                                                   ; number of arguments
    sub rsp, 20h                                                 ; allocate shadow space
    call offset func$print                                       ; jump to subroutine
    add rsp, 038h                                                ; release shadow space and arguments
    mov rcx, [rbp+010h]                                          ; restore rcx from shadow space
    mov rdx, [rbp+018h]                                          ; restore rdx from shadow space
    mov r8, [rbp+020h]                                           ; restore r8 from shadow space
    mov r9, [rbp+028h]                                           ; restore r9 from shadow space
    ;  - exit(1)
    mov qword ptr [rbp-050h], 0h                                 ; value of this pointer for function call (placeholder)
    mov qword ptr [rbp-058h], 000000000h                         ; type of this pointer for function call (placeholder)
    mov qword ptr [rbp-060h], 0h                                 ; value of closure pointer for function call (placeholder)
    mov [rbp+010h], rcx                                          ; save rcx in shadow space
    mov [rbp+018h], rdx                                          ; save rdx in shadow space
    mov [rbp+020h], r8                                           ; save r8 in shadow space
    mov [rbp+028h], r9                                           ; save r9 in shadow space
    push 000000001h                                              ; value of argument #1
    push 000000006h                                              ; type of argument #1
    lea r10, [rbp-068h]                                          ; pointer to return value (and type, 8 bytes earlier)
    push r10                                                     ; (that pointer is the last value pushed to the stack)
    lea r9, [rbp-050h]                                           ; pointer to this
    mov r8, [rbp-058h]                                           ; type of this
    lea rdx, [rbp-060h]                                          ; pointer to closure
    mov rcx, 1                                                   ; number of arguments
    sub rsp, 20h                                                 ; allocate shadow space
    call offset func$exit                                        ; jump to subroutine
    add rsp, 038h                                                ; release shadow space and arguments
    mov rcx, [rbp+010h]                                          ; restore rcx from shadow space
    mov rdx, [rbp+018h]                                          ; restore rdx from shadow space
    mov r8, [rbp+020h]                                           ; restore r8 from shadow space
    mov r9, [rbp+028h]                                           ; restore r9 from shadow space
  tempSyd$a$TypeMatch:
  mov rax, [rbp-020h]                                            ; load the dynamic type of b into rax
  lea r10, typeTable                                             ; move type table offset into r10
  add rax, r10                                                   ; adjust rax to point to the type table
  bt qword ptr [rax], 0                                          ; check that b is Integer'6
  jc tempSyd$b$TypeMatch                                         ; skip next block if the type matches
    ; Error handling block for b
    ;  - print(operandTypeCheckFailureMessage)
    mov qword ptr [rbp-078h], 0h                                 ; value of this pointer for function call (placeholder)
    mov qword ptr [rbp-080h], 000000000h                         ; type of this pointer for function call (placeholder)
    mov qword ptr [rbp-088h], 0h                                 ; value of closure pointer for function call (placeholder)
    mov [rbp+010h], rcx                                          ; save rcx in shadow space
    mov [rbp+018h], rdx                                          ; save rdx in shadow space
    mov [rbp+020h], r8                                           ; save r8 in shadow space
    mov [rbp+028h], r9                                           ; save r9 in shadow space
    mov r11, offset operandTypeCheckFailureMessage               ; value of argument #1
    push r11                                                     ; (indirect via r11 because "operandTypeCheckFailureMessage" is an imm64)
    push 000000007h                                              ; type of argument #1
    lea r10, [rbp-090h]                                          ; pointer to return value (and type, 8 bytes earlier)
    push r10                                                     ; (that pointer is the last value pushed to the stack)
    lea r9, [rbp-078h]                                           ; pointer to this
    mov r8, [rbp-080h]                                           ; type of this
    lea rdx, [rbp-088h]                                          ; pointer to closure
    mov rcx, 1                                                   ; number of arguments
    sub rsp, 20h                                                 ; allocate shadow space
    call offset func$print                                       ; jump to subroutine
    add rsp, 038h                                                ; release shadow space and arguments
    mov rcx, [rbp+010h]                                          ; restore rcx from shadow space
    mov rdx, [rbp+018h]                                          ; restore rdx from shadow space
    mov r8, [rbp+020h]                                           ; restore r8 from shadow space
    mov r9, [rbp+028h]                                           ; restore r9 from shadow space
    ;  - exit(1)
    mov qword ptr [rbp-0a0h], 0h                                 ; value of this pointer for function call (placeholder)
    mov qword ptr [rbp-0a8h], 000000000h                         ; type of this pointer for function call (placeholder)
    mov qword ptr [rbp-0b0h], 0h                                 ; value of closure pointer for function call (placeholder)
    mov [rbp+010h], rcx                                          ; save rcx in shadow space
    mov [rbp+018h], rdx                                          ; save rdx in shadow space
    mov [rbp+020h], r8                                           ; save r8 in shadow space
    mov [rbp+028h], r9                                           ; save r9 in shadow space
    push 000000001h                                              ; value of argument #1
    push 000000006h                                              ; type of argument #1
    lea r10, [rbp-0b8h]                                          ; pointer to return value (and type, 8 bytes earlier)
    push r10                                                     ; (that pointer is the last value pushed to the stack)
    lea r9, [rbp-0a0h]                                           ; pointer to this
    mov r8, [rbp-0a8h]                                           ; type of this
    lea rdx, [rbp-0b0h]                                          ; pointer to closure
    mov rcx, 1                                                   ; number of arguments
    sub rsp, 20h                                                 ; allocate shadow space
    call offset func$exit                                        ; jump to subroutine
    add rsp, 038h                                                ; release shadow space and arguments
    mov rcx, [rbp+010h]                                          ; restore rcx from shadow space
    mov rdx, [rbp+018h]                                          ; restore rdx from shadow space
    mov r8, [rbp+020h]                                           ; restore r8 from shadow space
    mov r9, [rbp+028h]                                           ; restore r9 from shadow space
  tempSyd$b$TypeMatch:
  mov qword ptr [rbp-0c8h], 000000000h                           ; clear < operator result
  mov r11, [rbp-008h]                                            ; compare a...
  cmp r11, [rbp-018h]                                            ; ...to b
  setl byte ptr [rbp-0c8h]                                       ; store result in < operator result
  mov qword ptr [rbp-0d0h], 000000002h                           ; < operator result is a Boolean
  cmp qword ptr [rbp-0c8h], 000000000h                           ; compare < operator result to false
  je tempSyd$if$continuation                                     ; a < b
    ; Line 9: print('strings are in order\n');
    mov qword ptr [rbp-0d8h], 0h                                 ; value of this pointer for function call (placeholder)
    mov qword ptr [rbp-0e0h], 000000000h                         ; type of this pointer for function call (placeholder)
    mov qword ptr [rbp-0e8h], 0h                                 ; value of closure pointer for function call (placeholder)
    mov [rbp+010h], rcx                                          ; save rcx in shadow space
    mov [rbp+018h], rdx                                          ; save rdx in shadow space
    mov [rbp+020h], r8                                           ; save r8 in shadow space
    mov [rbp+028h], r9                                           ; save r9 in shadow space
    mov r11, offset string$3                                     ; value of argument #1
    push r11                                                     ; (indirect via r11 because "string$3" is an imm64)
    push 000000007h                                              ; type of argument #1
    lea r10, [rbp-0f0h]                                          ; pointer to return value (and type, 8 bytes earlier)
    push r10                                                     ; (that pointer is the last value pushed to the stack)
    lea r9, [rbp-0d8h]                                           ; pointer to this
    mov r8, [rbp-0e0h]                                           ; type of this
    lea rdx, [rbp-0e8h]                                          ; pointer to closure
    mov rcx, 1                                                   ; number of arguments
    sub rsp, 20h                                                 ; allocate shadow space
    call offset func$print                                       ; jump to subroutine
    add rsp, 038h                                                ; release shadow space and arguments
    mov rcx, [rbp+010h]                                          ; restore rcx from shadow space
    mov rdx, [rbp+018h]                                          ; restore rdx from shadow space
    mov r8, [rbp+020h]                                           ; restore r8 from shadow space
    mov r9, [rbp+028h]                                           ; restore r9 from shadow space
  tempSyd$if$continuation:                                       ; end of if
  ; Line 11: if (a + 8 + 8 + 8 == b) { ...
  mov rax, [rbp-010h]                                            ; load the dynamic type of a into rax
  lea r10, typeTable                                             ; move type table offset into r10
  add rax, r10                                                   ; adjust rax to point to the type table
  bt qword ptr [rax], 0                                          ; check that a is Integer'6
  jc tempSyd$a$TypeMatch$1                                       ; skip next block if the type matches
    ; Error handling block for a
    ;  - print(operandTypeCheckFailureMessage)
    mov qword ptr [rbp-0100h], 0h                                ; value of this pointer for function call (placeholder)
    mov qword ptr [rbp-0108h], 000000000h                        ; type of this pointer for function call (placeholder)
    mov qword ptr [rbp-0110h], 0h                                ; value of closure pointer for function call (placeholder)
    mov [rbp+010h], rcx                                          ; save rcx in shadow space
    mov [rbp+018h], rdx                                          ; save rdx in shadow space
    mov [rbp+020h], r8                                           ; save r8 in shadow space
    mov [rbp+028h], r9                                           ; save r9 in shadow space
    mov r11, offset operandTypeCheckFailureMessage               ; value of argument #1
    push r11                                                     ; (indirect via r11 because "operandTypeCheckFailureMessage" is an imm64)
    push 000000007h                                              ; type of argument #1
    lea r10, [rbp-0118h]                                         ; pointer to return value (and type, 8 bytes earlier)
    push r10                                                     ; (that pointer is the last value pushed to the stack)
    lea r9, [rbp-0100h]                                          ; pointer to this
    mov r8, [rbp-0108h]                                          ; type of this
    lea rdx, [rbp-0110h]                                         ; pointer to closure
    mov rcx, 1                                                   ; number of arguments
    sub rsp, 20h                                                 ; allocate shadow space
    call offset func$print                                       ; jump to subroutine
    add rsp, 038h                                                ; release shadow space and arguments
    mov rcx, [rbp+010h]                                          ; restore rcx from shadow space
    mov rdx, [rbp+018h]                                          ; restore rdx from shadow space
    mov r8, [rbp+020h]                                           ; restore r8 from shadow space
    mov r9, [rbp+028h]                                           ; restore r9 from shadow space
    ;  - exit(1)
    mov qword ptr [rbp-0128h], 0h                                ; value of this pointer for function call (placeholder)
    mov qword ptr [rbp-0130h], 000000000h                        ; type of this pointer for function call (placeholder)
    mov qword ptr [rbp-0138h], 0h                                ; value of closure pointer for function call (placeholder)
    mov [rbp+010h], rcx                                          ; save rcx in shadow space
    mov [rbp+018h], rdx                                          ; save rdx in shadow space
    mov [rbp+020h], r8                                           ; save r8 in shadow space
    mov [rbp+028h], r9                                           ; save r9 in shadow space
    push 000000001h                                              ; value of argument #1
    push 000000006h                                              ; type of argument #1
    lea r10, [rbp-0140h]                                         ; pointer to return value (and type, 8 bytes earlier)
    push r10                                                     ; (that pointer is the last value pushed to the stack)
    lea r9, [rbp-0128h]                                          ; pointer to this
    mov r8, [rbp-0130h]                                          ; type of this
    lea rdx, [rbp-0138h]                                         ; pointer to closure
    mov rcx, 1                                                   ; number of arguments
    sub rsp, 20h                                                 ; allocate shadow space
    call offset func$exit                                        ; jump to subroutine
    add rsp, 038h                                                ; release shadow space and arguments
    mov rcx, [rbp+010h]                                          ; restore rcx from shadow space
    mov rdx, [rbp+018h]                                          ; restore rdx from shadow space
    mov r8, [rbp+020h]                                           ; restore r8 from shadow space
    mov r9, [rbp+028h]                                           ; restore r9 from shadow space
  tempSyd$a$TypeMatch$1:
  mov r10, [rbp-008h]                                            ; add mutates first operand, so indirect via register
  add r10, 000000008h                                            ; + operator
  mov [rbp-01a0h], r10                                           ; store result
  mov qword ptr [rbp-01a8h], 000000006h                          ; store type
  mov rax, [rbp-01a8h]                                           ; load the dynamic type of a + 8 into rax
  lea r10, typeTable                                             ; move type table offset into r10
  add rax, r10                                                   ; adjust rax to point to the type table
  bt qword ptr [rax], 0                                          ; check that a + 8 is Integer'6
  jc tempSyd$a8$TypeMatch                                        ; skip next block if the type matches
    ; Error handling block for a + 8
    ;  - print(operandTypeCheckFailureMessage)
    mov qword ptr [rbp-01b0h], 0h                                ; value of this pointer for function call (placeholder)
    mov qword ptr [rbp-01b8h], 000000000h                        ; type of this pointer for function call (placeholder)
    mov qword ptr [rbp-01c0h], 0h                                ; value of closure pointer for function call (placeholder)
    mov [rbp+010h], rcx                                          ; save rcx in shadow space
    mov [rbp+018h], rdx                                          ; save rdx in shadow space
    mov [rbp+020h], r8                                           ; save r8 in shadow space
    mov [rbp+028h], r9                                           ; save r9 in shadow space
    mov r11, offset operandTypeCheckFailureMessage               ; value of argument #1
    push r11                                                     ; (indirect via r11 because "operandTypeCheckFailureMessage" is an imm64)
    push 000000007h                                              ; type of argument #1
    lea r10, [rbp-01c8h]                                         ; pointer to return value (and type, 8 bytes earlier)
    push r10                                                     ; (that pointer is the last value pushed to the stack)
    lea r9, [rbp-01b0h]                                          ; pointer to this
    mov r8, [rbp-01b8h]                                          ; type of this
    lea rdx, [rbp-01c0h]                                         ; pointer to closure
    mov rcx, 1                                                   ; number of arguments
    sub rsp, 20h                                                 ; allocate shadow space
    call offset func$print                                       ; jump to subroutine
    add rsp, 038h                                                ; release shadow space and arguments
    mov rcx, [rbp+010h]                                          ; restore rcx from shadow space
    mov rdx, [rbp+018h]                                          ; restore rdx from shadow space
    mov r8, [rbp+020h]                                           ; restore r8 from shadow space
    mov r9, [rbp+028h]                                           ; restore r9 from shadow space
    ;  - exit(1)
    mov qword ptr [rbp-01d8h], 0h                                ; value of this pointer for function call (placeholder)
    mov qword ptr [rbp-01e0h], 000000000h                        ; type of this pointer for function call (placeholder)
    mov qword ptr [rbp-01e8h], 0h                                ; value of closure pointer for function call (placeholder)
    mov [rbp+010h], rcx                                          ; save rcx in shadow space
    mov [rbp+018h], rdx                                          ; save rdx in shadow space
    mov [rbp+020h], r8                                           ; save r8 in shadow space
    mov [rbp+028h], r9                                           ; save r9 in shadow space
    push 000000001h                                              ; value of argument #1
    push 000000006h                                              ; type of argument #1
    lea r10, [rbp-01f0h]                                         ; pointer to return value (and type, 8 bytes earlier)
    push r10                                                     ; (that pointer is the last value pushed to the stack)
    lea r9, [rbp-01d8h]                                          ; pointer to this
    mov r8, [rbp-01e0h]                                          ; type of this
    lea rdx, [rbp-01e8h]                                         ; pointer to closure
    mov rcx, 1                                                   ; number of arguments
    sub rsp, 20h                                                 ; allocate shadow space
    call offset func$exit                                        ; jump to subroutine
    add rsp, 038h                                                ; release shadow space and arguments
    mov rcx, [rbp+010h]                                          ; restore rcx from shadow space
    mov rdx, [rbp+018h]                                          ; restore rdx from shadow space
    mov r8, [rbp+020h]                                           ; restore r8 from shadow space
    mov r9, [rbp+028h]                                           ; restore r9 from shadow space
  tempSyd$a8$TypeMatch:
  mov r10, [rbp-01a0h]                                           ; add mutates first operand, so indirect via register
  add r10, 000000008h                                            ; + operator
  mov [rbp-0250h], r10                                           ; store result
  mov qword ptr [rbp-0258h], 000000006h                          ; store type
  mov rax, [rbp-0258h]                                           ; load the dynamic type of a + 8 + 8 into rax
  lea r10, typeTable                                             ; move type table offset into r10
  add rax, r10                                                   ; adjust rax to point to the type table
  bt qword ptr [rax], 0                                          ; check that a + 8 + 8 is Integer'6
  jc tempSyd$a88$TypeMatch                                       ; skip next block if the type matches
    ; Error handling block for a + 8 + 8
    ;  - print(operandTypeCheckFailureMessage)
    mov qword ptr [rbp-0260h], 0h                                ; value of this pointer for function call (placeholder)
    mov qword ptr [rbp-0268h], 000000000h                        ; type of this pointer for function call (placeholder)
    mov qword ptr [rbp-0270h], 0h                                ; value of closure pointer for function call (placeholder)
    mov [rbp+010h], rcx                                          ; save rcx in shadow space
    mov [rbp+018h], rdx                                          ; save rdx in shadow space
    mov [rbp+020h], r8                                           ; save r8 in shadow space
    mov [rbp+028h], r9                                           ; save r9 in shadow space
    mov r11, offset operandTypeCheckFailureMessage               ; value of argument #1
    push r11                                                     ; (indirect via r11 because "operandTypeCheckFailureMessage" is an imm64)
    push 000000007h                                              ; type of argument #1
    lea r10, [rbp-0278h]                                         ; pointer to return value (and type, 8 bytes earlier)
    push r10                                                     ; (that pointer is the last value pushed to the stack)
    lea r9, [rbp-0260h]                                          ; pointer to this
    mov r8, [rbp-0268h]                                          ; type of this
    lea rdx, [rbp-0270h]                                         ; pointer to closure
    mov rcx, 1                                                   ; number of arguments
    sub rsp, 20h                                                 ; allocate shadow space
    call offset func$print                                       ; jump to subroutine
    add rsp, 038h                                                ; release shadow space and arguments
    mov rcx, [rbp+010h]                                          ; restore rcx from shadow space
    mov rdx, [rbp+018h]                                          ; restore rdx from shadow space
    mov r8, [rbp+020h]                                           ; restore r8 from shadow space
    mov r9, [rbp+028h]                                           ; restore r9 from shadow space
    ;  - exit(1)
    mov qword ptr [rbp-0288h], 0h                                ; value of this pointer for function call (placeholder)
    mov qword ptr [rbp-0290h], 000000000h                        ; type of this pointer for function call (placeholder)
    mov qword ptr [rbp-0298h], 0h                                ; value of closure pointer for function call (placeholder)
    mov [rbp+010h], rcx                                          ; save rcx in shadow space
    mov [rbp+018h], rdx                                          ; save rdx in shadow space
    mov [rbp+020h], r8                                           ; save r8 in shadow space
    mov [rbp+028h], r9                                           ; save r9 in shadow space
    push 000000001h                                              ; value of argument #1
    push 000000006h                                              ; type of argument #1
    lea r10, [rbp-02a0h]                                         ; pointer to return value (and type, 8 bytes earlier)
    push r10                                                     ; (that pointer is the last value pushed to the stack)
    lea r9, [rbp-0288h]                                          ; pointer to this
    mov r8, [rbp-0290h]                                          ; type of this
    lea rdx, [rbp-0298h]                                         ; pointer to closure
    mov rcx, 1                                                   ; number of arguments
    sub rsp, 20h                                                 ; allocate shadow space
    call offset func$exit                                        ; jump to subroutine
    add rsp, 038h                                                ; release shadow space and arguments
    mov rcx, [rbp+010h]                                          ; restore rcx from shadow space
    mov rdx, [rbp+018h]                                          ; restore rdx from shadow space
    mov r8, [rbp+020h]                                           ; restore r8 from shadow space
    mov r9, [rbp+028h]                                           ; restore r9 from shadow space
  tempSyd$a88$TypeMatch:
  mov r10, [rbp-0250h]                                           ; add mutates first operand, so indirect via register
  add r10, 000000008h                                            ; + operator
  mov [rbp-0300h], r10                                           ; store result
  mov qword ptr [rbp-0308h], 000000006h                          ; store type
  xor r10, r10                                                   ; prepare r10 for result of value comparison
  mov r11, [rbp-0300h]                                           ; compare + operator result...
  cmp r11, [rbp-018h]                                            ; ...to b
  sete byte ptr r10b                                             ; store result in r10
  xor rax, rax                                                   ; prepare rax for result of type comparison
  mov r11, [rbp-0308h]                                           ; compare type of + operator result...
  cmp r11, [rbp-020h]                                            ; ...to type of b
  sete byte ptr al                                               ; store result in rax
  and r10, rax                                                   ; true if type and value are both equal; result goes into r10
  mov [rbp-0310h], r10                                           ; store result in == operator result
  mov qword ptr [rbp-0318h], 000000002h                          ; == operator result is a Boolean
  cmp qword ptr [rbp-0310h], 000000000h                          ; compare == operator result to false
  je tempSyd$if$continuation$1                                   ; a + 8 + 8 + 8 == b
    ; Line 12: print('strings are aligned as expected\n');
    mov qword ptr [rbp-0320h], 0h                                ; value of this pointer for function call (placeholder)
    mov qword ptr [rbp-0328h], 000000000h                        ; type of this pointer for function call (placeholder)
    mov qword ptr [rbp-0330h], 0h                                ; value of closure pointer for function call (placeholder)
    mov [rbp+010h], rcx                                          ; save rcx in shadow space
    mov [rbp+018h], rdx                                          ; save rdx in shadow space
    mov [rbp+020h], r8                                           ; save r8 in shadow space
    mov [rbp+028h], r9                                           ; save r9 in shadow space
    mov r11, offset string$4                                     ; value of argument #1
    push r11                                                     ; (indirect via r11 because "string$4" is an imm64)
    push 000000007h                                              ; type of argument #1
    lea r10, [rbp-0338h]                                         ; pointer to return value (and type, 8 bytes earlier)
    push r10                                                     ; (that pointer is the last value pushed to the stack)
    lea r9, [rbp-0320h]                                          ; pointer to this
    mov r8, [rbp-0328h]                                          ; type of this
    lea rdx, [rbp-0330h]                                         ; pointer to closure
    mov rcx, 1                                                   ; number of arguments
    sub rsp, 20h                                                 ; allocate shadow space
    call offset func$print                                       ; jump to subroutine
    add rsp, 038h                                                ; release shadow space and arguments
    mov rcx, [rbp+010h]                                          ; restore rcx from shadow space
    mov rdx, [rbp+018h]                                          ; restore rdx from shadow space
    mov r8, [rbp+020h]                                           ; restore r8 from shadow space
    mov r9, [rbp+028h]                                           ; restore r9 from shadow space
  tempSyd$if$continuation$1:                                     ; end of if
  ; Terminate application - call exit(0)
  mov qword ptr [rbp-0348h], 0h                                  ; value of this pointer for function call (placeholder)
  mov qword ptr [rbp-0350h], 000000000h                          ; type of this pointer for function call (placeholder)
  mov qword ptr [rbp-0358h], 0h                                  ; value of closure pointer for function call (placeholder)
  mov [rbp+010h], rcx                                            ; save rcx in shadow space
  mov [rbp+018h], rdx                                            ; save rdx in shadow space
  mov [rbp+020h], r8                                             ; save r8 in shadow space
  mov [rbp+028h], r9                                             ; save r9 in shadow space
  push 000000000h                                                ; value of argument #1
  push 000000006h                                                ; type of argument #1
  lea r10, [rbp-0360h]                                           ; pointer to return value (and type, 8 bytes earlier)
  push r10                                                       ; (that pointer is the last value pushed to the stack)
  lea r9, [rbp-0348h]                                            ; pointer to this
  mov r8, [rbp-0350h]                                            ; type of this
  lea rdx, [rbp-0358h]                                           ; pointer to closure
  mov rcx, 1                                                     ; number of arguments
  sub rsp, 20h                                                   ; allocate shadow space
  call offset func$exit                                          ; jump to subroutine
  add rsp, 038h                                                  ; release shadow space and arguments
  mov rcx, [rbp+010h]                                            ; restore rcx from shadow space
  mov rdx, [rbp+018h]                                            ; restore rdx from shadow space
  mov r8, [rbp+020h]                                             ; restore r8 from shadow space
  mov r9, [rbp+028h]                                             ; restore r9 from shadow space
  ; Epilog
  add rsp, 0368h                                                 ; free space for stack
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
    push 000000007h                                              ; type of argument #1
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
    push 000000006h                                              ; type of argument #1
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
  bt qword ptr [rax], 1                                          ; check that message to print to console is String'7
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
    push 000000007h                                              ; type of argument #1
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
    push 000000006h                                              ; type of argument #1
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
    push 000000007h                                              ; type of argument #1
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
    push 000000006h                                              ; type of argument #1
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
  bt qword ptr [rax], 0                                          ; check that exit code parameter is Integer'6
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
    push 000000007h                                              ; type of argument #1
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
    push 000000006h                                              ; type of argument #1
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


end

