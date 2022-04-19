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
extern HeapAlloc : proc
extern HeapFree : proc
extern GetLastError : proc

.const
  typeTable    db 03fh, 010h, 010h, 010h, 010h, 010h, 010h, 010h, 010h, 010h, 010h, 010h, 010h, 010h, 030h, 010h, 010h, 010h, 030h, 011h, 012h, 014h, 018h, 000h ; Type table
   ; Columns: Null'19 Boolean'20 Integer'21 String'22 Anything'23 WhateverReadOnlyList'24
   ; 1 1 1 1 1 1   <sentinel>'0
   ; 0 0 0 0 1 0   NullFunction(String)'1
   ; 0 0 0 0 1 0   NullFunction(Integer)'2
   ; 0 0 0 0 1 0   IntegerFunction(WhateverReadOnlyList)'3
   ; 0 0 0 0 1 0   NullFunction()'4
   ; 0 0 0 0 1 0   IntegerFunction()'5
   ; 0 0 0 0 1 0   IntegerFunction(Integer, Integer, Integer)'6
   ; 0 0 0 0 1 0   IntegerFunction(Integer)'7
   ; 0 0 0 0 1 0   NullFunction(Integer, Integer)'8
   ; 0 0 0 0 1 0   NullFunction(Boolean, String)'9
   ; 0 0 0 0 1 0   IntegerFunction(String)'10
   ; 0 0 0 0 1 0   BooleanFunction(Integer)'11
   ; 0 0 0 0 1 0   NullFunction(Integer, Integer, Integer)'12
   ; 0 0 0 0 1 0   StringFunction(String...)'13
   ; 0 0 0 0 1 1   StringReadOnlyList'14
   ; 0 0 0 0 1 0   StringFunction(Integer)'15
   ; 0 0 0 0 1 0   StringFunction(Anything)'16
   ; 0 0 0 0 1 0   NullFunction(Anything...)'17
   ; 0 0 0 0 1 1   AnythingReadOnlyList'18
   ; 1 0 0 0 1 0   Null'19
   ; 0 1 0 0 1 0   Boolean'20
   ; 0 0 1 0 1 0   Integer'21
   ; 0 0 0 1 1 0   String'22

  parameterCountCheckFailureMessage dq -01h                      ; String constant (reference count)
               dq 88                                             ; Length
               db "error: function call received the wrong number of parameters (expected %d, received %d)", 0ah ; line 222 column 25 in file syd-compiler.syd
               db 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h         ; padding to align to 8-byte boundary
  parameterTypeCheckFailureMessage dq -01h                       ; String constant (reference count)
               dq 71                                             ; Length
               db "error: type mismatch for function %s parameter %d, expected %s, got %s", 0ah ; line 227 column 25 in file syd-compiler.syd
               db 00h                                            ; padding to align to 8-byte boundary
  returnValueTypeCheckFailureMessage dq -01h                     ; String constant (reference count)
               dq 68                                             ; Length
               db "error: type mismatch for function return value, expected %s, got %s", 0ah ; line 232 column 25 in file syd-compiler.syd
               db 00h, 00h, 00h, 00h                             ; padding to align to 8-byte boundary
  operandTypeCheckFailureMessage dq -01h                         ; String constant (reference count)
               dq 54                                             ; Length
               db "error: type mismatch for operand, expected %s, got %s", 0ah ; line 237 column 25 in file syd-compiler.syd
               db 00h, 00h                                       ; padding to align to 8-byte boundary
  asOperatorFailureMessage dq -01h                               ; String constant (reference count)
               dq 58                                             ; Length
               db "error: type mismatch for as operator, expected %s, got %s", 0ah ; line 242 column 25 in file syd-compiler.syd
               db 00h, 00h, 00h, 00h, 00h, 00h                   ; padding to align to 8-byte boundary
  boundsFailureMessage dq -01h                                   ; String constant (reference count)
               dq 64                                             ; Length
               db "error: subscript index out of range (%d is not in range %d..%d)", 0ah ; line 247 column 25 in file syd-compiler.syd
               db 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h         ; padding to align to 8-byte boundary
  string       dq -01h                                           ; String constant (reference count)
               dq 1                                              ; Length
               db 0ah                                            ; line 8 column 16 in file runtime library
               db 00h, 00h, 00h, 00h, 00h, 00h, 00h              ; padding to align to 8-byte boundary
  string$1     dq -01h                                           ; String constant (reference count)
               dq 51                                             ; Length
               db "_moveBytes expects positive number of bytes to copy" ; line 42 column 74 in file runtime library
               db 00h, 00h, 00h, 00h, 00h                        ; padding to align to 8-byte boundary
  string$2     dq -01h                                           ; String constant (reference count)
               dq 61                                             ; Length
               db "internal error: zero extra bytes but fromCursor is before end" ; line 57 column 90 in file runtime library
               db 00h, 00h, 00h                                  ; padding to align to 8-byte boundary
  string$3     dq -01h                                           ; String constant (reference count)
               dq 39                                             ; Length
               db "internal error: more than 7 extra bytes"      ; line 58 column 68 in file runtime library
               db 00h                                            ; padding to align to 8-byte boundary
  string$4     dq -01h                                           ; String constant (reference count)
               dq 1                                              ; Length
               db "0"                                            ; line 93 column 14 in file runtime library
               db 00h, 00h, 00h, 00h, 00h, 00h, 00h              ; padding to align to 8-byte boundary
  string$5     dq -01h                                           ; String constant (reference count)
               dq 1                                              ; Length
               db "1"                                            ; line 96 column 14 in file runtime library
               db 00h, 00h, 00h, 00h, 00h, 00h, 00h              ; padding to align to 8-byte boundary
  string$6     dq -01h                                           ; String constant (reference count)
               dq 1                                              ; Length
               db "2"                                            ; line 99 column 14 in file runtime library
               db 00h, 00h, 00h, 00h, 00h, 00h, 00h              ; padding to align to 8-byte boundary
  string$7     dq -01h                                           ; String constant (reference count)
               dq 1                                              ; Length
               db "3"                                            ; line 102 column 14 in file runtime library
               db 00h, 00h, 00h, 00h, 00h, 00h, 00h              ; padding to align to 8-byte boundary
  string$8     dq -01h                                           ; String constant (reference count)
               dq 1                                              ; Length
               db "4"                                            ; line 105 column 14 in file runtime library
               db 00h, 00h, 00h, 00h, 00h, 00h, 00h              ; padding to align to 8-byte boundary
  string$9     dq -01h                                           ; String constant (reference count)
               dq 1                                              ; Length
               db "5"                                            ; line 108 column 14 in file runtime library
               db 00h, 00h, 00h, 00h, 00h, 00h, 00h              ; padding to align to 8-byte boundary
  string$10    dq -01h                                           ; String constant (reference count)
               dq 1                                              ; Length
               db "6"                                            ; line 111 column 14 in file runtime library
               db 00h, 00h, 00h, 00h, 00h, 00h, 00h              ; padding to align to 8-byte boundary
  string$11    dq -01h                                           ; String constant (reference count)
               dq 1                                              ; Length
               db "7"                                            ; line 114 column 14 in file runtime library
               db 00h, 00h, 00h, 00h, 00h, 00h, 00h              ; padding to align to 8-byte boundary
  string$12    dq -01h                                           ; String constant (reference count)
               dq 1                                              ; Length
               db "8"                                            ; line 117 column 14 in file runtime library
               db 00h, 00h, 00h, 00h, 00h, 00h, 00h              ; padding to align to 8-byte boundary
  string$13    dq -01h                                           ; String constant (reference count)
               dq 1                                              ; Length
               db "9"                                            ; line 120 column 14 in file runtime library
               db 00h, 00h, 00h, 00h, 00h, 00h, 00h              ; padding to align to 8-byte boundary
  string$14    dq -01h                                           ; String constant (reference count)
               dq 57                                             ; Length
               db "Invalid digit passed to digitToStr (digit as exit code) ", 0ah ; line 122 column 70 in file runtime library
               db 00h, 00h, 00h, 00h, 00h, 00h, 00h              ; padding to align to 8-byte boundary
  string$15    dq -01h                                           ; String constant (reference count)
               dq 0                                              ; Length
  string$16    dq -01h                                           ; String constant (reference count)
               dq 4                                              ; Length
               db "true"                                         ; line 147 column 19 in file runtime library
               db 00h, 00h, 00h, 00h                             ; padding to align to 8-byte boundary
  string$17    dq -01h                                           ; String constant (reference count)
               dq 5                                              ; Length
               db "false"                                        ; line 149 column 18 in file runtime library
               db 00h, 00h, 00h                                  ; padding to align to 8-byte boundary
  string$18    dq -01h                                           ; String constant (reference count)
               dq 4                                              ; Length
               db "null"                                         ; line 152 column 17 in file runtime library
               db 00h, 00h, 00h, 00h                             ; padding to align to 8-byte boundary
  string$19    dq -01h                                           ; String constant (reference count)
               dq 28                                             ; Length
               db "value cannot be stringified", 0ah             ; line 157 column 41 in file runtime library
               db 00h, 00h, 00h, 00h                             ; padding to align to 8-byte boundary
  string$20    dq -01h                                           ; String constant (reference count)
               dq 1                                              ; Length
               db " "                                            ; line 166 column 17 in file runtime library
               db 00h, 00h, 00h, 00h, 00h, 00h, 00h              ; padding to align to 8-byte boundary

.data


_BSS segment
  global0Value dq ?                                              ; _heapHandle
  global0Type dq ?                                               ; dynamic type of _heapHandle
  global0Value$1 dq ?                                            ; ptr
  global0Type$1 dq ?                                             ; dynamic type of ptr

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
  sub rsp, 010h                                                  ; allocate space for stack
  lea rbp, [rsp+010h]                                            ; set up frame pointer
  ; Line 13: Integer _heapHandle = __getProcessHeap();
  mov [rbp+010h], rcx                                            ; save rcx in shadow space
  mov [rbp+018h], rdx                                            ; save rdx in shadow space
  mov [rbp+020h], r8                                             ; save r8 in shadow space
  mov [rbp+028h], r9                                             ; save r9 in shadow space
  lea r10, [rbp-008h]                                            ; pointer to return value (and type, 8 bytes earlier)
  push r10                                                       ; (that pointer is the last value pushed to the stack)
  mov qword ptr r9, 0h                                           ; pointer to this
  mov qword ptr r8, 000000000h                                   ; type of this
  mov qword ptr rdx, 0h                                          ; pointer to closure
  mov rcx, 0                                                     ; number of arguments
  sub rsp, 20h                                                   ; allocate shadow space
  call offset func$__getProcessHeap                              ; jump to subroutine
  add rsp, 028h                                                  ; release shadow space and arguments
  mov rcx, [rbp+010h]                                            ; restore rcx from shadow space
  mov rdx, [rbp+018h]                                            ; restore rdx from shadow space
  mov r8, [rbp+020h]                                             ; restore r8 from shadow space
  mov r9, [rbp+028h]                                             ; restore r9 from shadow space
  mov r11, [rbp-008h]                                            ; value of _heapHandle
  mov global0Value, r11                                          ; (indirect via r11 because mov can't do memory-to-memory)
  mov r11, [rbp-010h]                                            ; type of _heapHandle
  mov global0Type, r11                                           ; (indirect via r11 because mov can't do memory-to-memory)
  ; Epilog
  add rsp, 010h                                                  ; free space for stack
  pop rbp                                                        ; restore non-volatile registers

  ; temp.syd
  ; ========
  ; Prolog
  push rbp                                                       ; save non-volatile registers
  sub rsp, 01d0h                                                 ; allocate space for stack
  lea rbp, [rsp+01d0h]                                           ; set up frame pointer
  ; Line 3: Integer ptr = _alloc(24 /* 0x18 */);
  mov [rbp+010h], rcx                                            ; save rcx in shadow space
  mov [rbp+018h], rdx                                            ; save rdx in shadow space
  mov [rbp+020h], r8                                             ; save r8 in shadow space
  mov [rbp+028h], r9                                             ; save r9 in shadow space
  push 000000018h                                                ; value of argument #1
  push 000000015h                                                ; type of argument #1
  lea r10, [rbp-008h]                                            ; pointer to return value (and type, 8 bytes earlier)
  push r10                                                       ; (that pointer is the last value pushed to the stack)
  mov qword ptr r9, 0h                                           ; pointer to this
  mov qword ptr r8, 000000000h                                   ; type of this
  mov qword ptr rdx, 0h                                          ; pointer to closure
  mov rcx, 1                                                     ; number of arguments
  sub rsp, 20h                                                   ; allocate shadow space
  call offset func$_alloc                                        ; jump to subroutine
  add rsp, 038h                                                  ; release shadow space and arguments
  mov rcx, [rbp+010h]                                            ; restore rcx from shadow space
  mov rdx, [rbp+018h]                                            ; restore rdx from shadow space
  mov r8, [rbp+020h]                                             ; restore r8 from shadow space
  mov r9, [rbp+028h]                                             ; restore r9 from shadow space
  mov r11, [rbp-008h]                                            ; value of ptr
  mov global0Value$1, r11                                        ; (indirect via r11 because mov can't do memory-to-memory)
  mov r11, [rbp-010h]                                            ; type of ptr
  mov global0Type$1, r11                                         ; (indirect via r11 because mov can't do memory-to-memory)
  ; Line 4: __writeToAddress(ptr, -1);
  mov qword ptr [rbp-038h], 000000001h                           ; move operand into location for result of neg
  not qword ptr[rbp-038h]                                        ; - unary operator
  mov qword ptr [rbp-040h], 000000015h                           ; store type
  mov r10, global0Value$1                                        ; value of ptr
  mov r11, [rbp-038h]                                            ; put - unary operator result in ptr
  mov [r10], r11                                                 ; (indirect via r11 because mov can't do memory-to-memory)
  ; Line 5: __writeToAddress(ptr + 8, 6);
  mov rax, global0Type$1                                         ; load the dynamic type of ptr into rax
  lea r10, typeTable                                             ; move type table offset into r10
  add rax, r10                                                   ; adjust rax to point to the type table
  bt qword ptr [rax], 2                                          ; check that ptr is Integer'21
  jc tempSyd$ptr$TypeMatch                                       ; skip next block if the type matches
    ; Error handling block for ptr
    ;  - print(operandTypeCheckFailureMessage)
    mov [rbp+010h], rcx                                          ; save rcx in shadow space
    mov [rbp+018h], rdx                                          ; save rdx in shadow space
    mov [rbp+020h], r8                                           ; save r8 in shadow space
    mov [rbp+028h], r9                                           ; save r9 in shadow space
    mov r11, offset operandTypeCheckFailureMessage               ; value of argument #1
    push r11                                                     ; (indirect via r11 because "operandTypeCheckFailureMessage" is an imm64)
    push 000000016h                                              ; type of argument #1
    lea r10, [rbp-048h]                                          ; pointer to return value (and type, 8 bytes earlier)
    push r10                                                     ; (that pointer is the last value pushed to the stack)
    mov qword ptr r9, 0h                                         ; pointer to this
    mov qword ptr r8, 000000000h                                 ; type of this
    mov qword ptr rdx, 0h                                        ; pointer to closure
    mov rcx, 1                                                   ; number of arguments
    sub rsp, 20h                                                 ; allocate shadow space
    call offset func$__print                                     ; jump to subroutine
    add rsp, 038h                                                ; release shadow space and arguments
    mov rcx, [rbp+010h]                                          ; restore rcx from shadow space
    mov rdx, [rbp+018h]                                          ; restore rdx from shadow space
    mov r8, [rbp+020h]                                           ; restore r8 from shadow space
    mov r9, [rbp+028h]                                           ; restore r9 from shadow space
    ;  - exit(1)
    mov [rbp+010h], rcx                                          ; save rcx in shadow space
    mov [rbp+018h], rdx                                          ; save rdx in shadow space
    mov [rbp+020h], r8                                           ; save r8 in shadow space
    mov [rbp+028h], r9                                           ; save r9 in shadow space
    push 000000001h                                              ; value of argument #1
    push 000000015h                                              ; type of argument #1
    lea r10, [rbp-058h]                                          ; pointer to return value (and type, 8 bytes earlier)
    push r10                                                     ; (that pointer is the last value pushed to the stack)
    mov qword ptr r9, 0h                                         ; pointer to this
    mov qword ptr r8, 000000000h                                 ; type of this
    mov qword ptr rdx, 0h                                        ; pointer to closure
    mov rcx, 1                                                   ; number of arguments
    sub rsp, 20h                                                 ; allocate shadow space
    call offset func$exit                                        ; jump to subroutine
    add rsp, 038h                                                ; release shadow space and arguments
    mov rcx, [rbp+010h]                                          ; restore rcx from shadow space
    mov rdx, [rbp+018h]                                          ; restore rdx from shadow space
    mov r8, [rbp+020h]                                           ; restore r8 from shadow space
    mov r9, [rbp+028h]                                           ; restore r9 from shadow space
  tempSyd$ptr$TypeMatch:
  mov r10, global0Value$1                                        ; add mutates first operand, so indirect via register
  add r10, 000000008h                                            ; + operator
  mov [rbp-088h], r10                                            ; store result
  mov qword ptr [rbp-090h], 000000015h                           ; store type
  mov r10, [rbp-088h]                                            ; value of + operator result
  mov qword ptr [r10], 000000006h                                ; put 6 in + operator result
  ; Line 6: __writeToAddress(ptr + 16 /* 0x10 */, 3472328296232149347 /* 0x3...
  mov rax, global0Type$1                                         ; load the dynamic type of ptr into rax
  lea r10, typeTable                                             ; move type table offset into r10
  add rax, r10                                                   ; adjust rax to point to the type table
  bt qword ptr [rax], 2                                          ; check that ptr is Integer'21
  jc tempSyd$ptr$TypeMatch$1                                     ; skip next block if the type matches
    ; Error handling block for ptr
    ;  - print(operandTypeCheckFailureMessage)
    mov [rbp+010h], rcx                                          ; save rcx in shadow space
    mov [rbp+018h], rdx                                          ; save rdx in shadow space
    mov [rbp+020h], r8                                           ; save r8 in shadow space
    mov [rbp+028h], r9                                           ; save r9 in shadow space
    mov r11, offset operandTypeCheckFailureMessage               ; value of argument #1
    push r11                                                     ; (indirect via r11 because "operandTypeCheckFailureMessage" is an imm64)
    push 000000016h                                              ; type of argument #1
    lea r10, [rbp-098h]                                          ; pointer to return value (and type, 8 bytes earlier)
    push r10                                                     ; (that pointer is the last value pushed to the stack)
    mov qword ptr r9, 0h                                         ; pointer to this
    mov qword ptr r8, 000000000h                                 ; type of this
    mov qword ptr rdx, 0h                                        ; pointer to closure
    mov rcx, 1                                                   ; number of arguments
    sub rsp, 20h                                                 ; allocate shadow space
    call offset func$__print                                     ; jump to subroutine
    add rsp, 038h                                                ; release shadow space and arguments
    mov rcx, [rbp+010h]                                          ; restore rcx from shadow space
    mov rdx, [rbp+018h]                                          ; restore rdx from shadow space
    mov r8, [rbp+020h]                                           ; restore r8 from shadow space
    mov r9, [rbp+028h]                                           ; restore r9 from shadow space
    ;  - exit(1)
    mov [rbp+010h], rcx                                          ; save rcx in shadow space
    mov [rbp+018h], rdx                                          ; save rdx in shadow space
    mov [rbp+020h], r8                                           ; save r8 in shadow space
    mov [rbp+028h], r9                                           ; save r9 in shadow space
    push 000000001h                                              ; value of argument #1
    push 000000015h                                              ; type of argument #1
    lea r10, [rbp-0a8h]                                          ; pointer to return value (and type, 8 bytes earlier)
    push r10                                                     ; (that pointer is the last value pushed to the stack)
    mov qword ptr r9, 0h                                         ; pointer to this
    mov qword ptr r8, 000000000h                                 ; type of this
    mov qword ptr rdx, 0h                                        ; pointer to closure
    mov rcx, 1                                                   ; number of arguments
    sub rsp, 20h                                                 ; allocate shadow space
    call offset func$exit                                        ; jump to subroutine
    add rsp, 038h                                                ; release shadow space and arguments
    mov rcx, [rbp+010h]                                          ; restore rcx from shadow space
    mov rdx, [rbp+018h]                                          ; restore rdx from shadow space
    mov r8, [rbp+020h]                                           ; restore r8 from shadow space
    mov r9, [rbp+028h]                                           ; restore r9 from shadow space
  tempSyd$ptr$TypeMatch$1:
  mov r10, global0Value$1                                        ; add mutates first operand, so indirect via register
  add r10, 000000010h                                            ; + operator
  mov [rbp-0d8h], r10                                            ; store result
  mov qword ptr [rbp-0e0h], 000000015h                           ; store type
  mov r10, [rbp-0d8h]                                            ; value of + operator result
  mov r11, 03030303030746163h                                    ; put 3472328296232149347 /* 0x3030303030746163 */ in + operator result
  mov [r10], r11                                                 ; (indirect via r11 because "03030303030746163h" is an imm64)
  ; Line 7: _moveBytes(ptr + 16 /* 0x10 */, ptr + 19 /* 0x13 */, 3);
  mov rax, global0Type$1                                         ; load the dynamic type of ptr into rax
  lea r10, typeTable                                             ; move type table offset into r10
  add rax, r10                                                   ; adjust rax to point to the type table
  bt qword ptr [rax], 2                                          ; check that ptr is Integer'21
  jc tempSyd$ptr$TypeMatch$2                                     ; skip next block if the type matches
    ; Error handling block for ptr
    ;  - print(operandTypeCheckFailureMessage)
    mov [rbp+010h], rcx                                          ; save rcx in shadow space
    mov [rbp+018h], rdx                                          ; save rdx in shadow space
    mov [rbp+020h], r8                                           ; save r8 in shadow space
    mov [rbp+028h], r9                                           ; save r9 in shadow space
    mov r11, offset operandTypeCheckFailureMessage               ; value of argument #1
    push r11                                                     ; (indirect via r11 because "operandTypeCheckFailureMessage" is an imm64)
    push 000000016h                                              ; type of argument #1
    lea r10, [rbp-0e8h]                                          ; pointer to return value (and type, 8 bytes earlier)
    push r10                                                     ; (that pointer is the last value pushed to the stack)
    mov qword ptr r9, 0h                                         ; pointer to this
    mov qword ptr r8, 000000000h                                 ; type of this
    mov qword ptr rdx, 0h                                        ; pointer to closure
    mov rcx, 1                                                   ; number of arguments
    sub rsp, 20h                                                 ; allocate shadow space
    call offset func$__print                                     ; jump to subroutine
    add rsp, 038h                                                ; release shadow space and arguments
    mov rcx, [rbp+010h]                                          ; restore rcx from shadow space
    mov rdx, [rbp+018h]                                          ; restore rdx from shadow space
    mov r8, [rbp+020h]                                           ; restore r8 from shadow space
    mov r9, [rbp+028h]                                           ; restore r9 from shadow space
    ;  - exit(1)
    mov [rbp+010h], rcx                                          ; save rcx in shadow space
    mov [rbp+018h], rdx                                          ; save rdx in shadow space
    mov [rbp+020h], r8                                           ; save r8 in shadow space
    mov [rbp+028h], r9                                           ; save r9 in shadow space
    push 000000001h                                              ; value of argument #1
    push 000000015h                                              ; type of argument #1
    lea r10, [rbp-0f8h]                                          ; pointer to return value (and type, 8 bytes earlier)
    push r10                                                     ; (that pointer is the last value pushed to the stack)
    mov qword ptr r9, 0h                                         ; pointer to this
    mov qword ptr r8, 000000000h                                 ; type of this
    mov qword ptr rdx, 0h                                        ; pointer to closure
    mov rcx, 1                                                   ; number of arguments
    sub rsp, 20h                                                 ; allocate shadow space
    call offset func$exit                                        ; jump to subroutine
    add rsp, 038h                                                ; release shadow space and arguments
    mov rcx, [rbp+010h]                                          ; restore rcx from shadow space
    mov rdx, [rbp+018h]                                          ; restore rdx from shadow space
    mov r8, [rbp+020h]                                           ; restore r8 from shadow space
    mov r9, [rbp+028h]                                           ; restore r9 from shadow space
  tempSyd$ptr$TypeMatch$2:
  mov r10, global0Value$1                                        ; add mutates first operand, so indirect via register
  add r10, 000000010h                                            ; + operator
  mov [rbp-0128h], r10                                           ; store result
  mov qword ptr [rbp-0130h], 000000015h                          ; store type
  mov rax, global0Type$1                                         ; load the dynamic type of ptr into rax
  lea r10, typeTable                                             ; move type table offset into r10
  add rax, r10                                                   ; adjust rax to point to the type table
  bt qword ptr [rax], 2                                          ; check that ptr is Integer'21
  jc tempSyd$ptr$TypeMatch$3                                     ; skip next block if the type matches
    ; Error handling block for ptr
    ;  - print(operandTypeCheckFailureMessage)
    mov [rbp+010h], rcx                                          ; save rcx in shadow space
    mov [rbp+018h], rdx                                          ; save rdx in shadow space
    mov [rbp+020h], r8                                           ; save r8 in shadow space
    mov [rbp+028h], r9                                           ; save r9 in shadow space
    mov r11, offset operandTypeCheckFailureMessage               ; value of argument #1
    push r11                                                     ; (indirect via r11 because "operandTypeCheckFailureMessage" is an imm64)
    push 000000016h                                              ; type of argument #1
    lea r10, [rbp-0138h]                                         ; pointer to return value (and type, 8 bytes earlier)
    push r10                                                     ; (that pointer is the last value pushed to the stack)
    mov qword ptr r9, 0h                                         ; pointer to this
    mov qword ptr r8, 000000000h                                 ; type of this
    mov qword ptr rdx, 0h                                        ; pointer to closure
    mov rcx, 1                                                   ; number of arguments
    sub rsp, 20h                                                 ; allocate shadow space
    call offset func$__print                                     ; jump to subroutine
    add rsp, 038h                                                ; release shadow space and arguments
    mov rcx, [rbp+010h]                                          ; restore rcx from shadow space
    mov rdx, [rbp+018h]                                          ; restore rdx from shadow space
    mov r8, [rbp+020h]                                           ; restore r8 from shadow space
    mov r9, [rbp+028h]                                           ; restore r9 from shadow space
    ;  - exit(1)
    mov [rbp+010h], rcx                                          ; save rcx in shadow space
    mov [rbp+018h], rdx                                          ; save rdx in shadow space
    mov [rbp+020h], r8                                           ; save r8 in shadow space
    mov [rbp+028h], r9                                           ; save r9 in shadow space
    push 000000001h                                              ; value of argument #1
    push 000000015h                                              ; type of argument #1
    lea r10, [rbp-0148h]                                         ; pointer to return value (and type, 8 bytes earlier)
    push r10                                                     ; (that pointer is the last value pushed to the stack)
    mov qword ptr r9, 0h                                         ; pointer to this
    mov qword ptr r8, 000000000h                                 ; type of this
    mov qword ptr rdx, 0h                                        ; pointer to closure
    mov rcx, 1                                                   ; number of arguments
    sub rsp, 20h                                                 ; allocate shadow space
    call offset func$exit                                        ; jump to subroutine
    add rsp, 038h                                                ; release shadow space and arguments
    mov rcx, [rbp+010h]                                          ; restore rcx from shadow space
    mov rdx, [rbp+018h]                                          ; restore rdx from shadow space
    mov r8, [rbp+020h]                                           ; restore r8 from shadow space
    mov r9, [rbp+028h]                                           ; restore r9 from shadow space
  tempSyd$ptr$TypeMatch$3:
  mov r10, global0Value$1                                        ; add mutates first operand, so indirect via register
  add r10, 000000013h                                            ; + operator
  mov [rbp-0178h], r10                                           ; store result
  mov qword ptr [rbp-0180h], 000000015h                          ; store type
  mov [rbp+010h], rcx                                            ; save rcx in shadow space
  mov [rbp+018h], rdx                                            ; save rdx in shadow space
  mov [rbp+020h], r8                                             ; save r8 in shadow space
  mov [rbp+028h], r9                                             ; save r9 in shadow space
  push 000000003h                                                ; value of argument #3
  push 000000015h                                                ; type of argument #3
  push [rbp-0178h]                                               ; value of argument #2
  push [rbp-0180h]                                               ; type of argument #2
  push [rbp-0128h]                                               ; value of argument #1
  push [rbp-0130h]                                               ; type of argument #1
  lea r10, [rbp-0188h]                                           ; pointer to return value (and type, 8 bytes earlier)
  push r10                                                       ; (that pointer is the last value pushed to the stack)
  mov qword ptr r9, 0h                                           ; pointer to this
  mov qword ptr r8, 000000000h                                   ; type of this
  mov qword ptr rdx, 0h                                          ; pointer to closure
  mov rcx, 3                                                     ; number of arguments
  sub rsp, 20h                                                   ; allocate shadow space
  call offset func$_moveBytes                                    ; jump to subroutine
  add rsp, 058h                                                  ; release shadow space and arguments
  mov rcx, [rbp+010h]                                            ; restore rcx from shadow space
  mov rdx, [rbp+018h]                                            ; restore rdx from shadow space
  mov r8, [rbp+020h]                                             ; restore r8 from shadow space
  mov r9, [rbp+028h]                                             ; restore r9 from shadow space
  ; Line 8: println(ptr __as__ String);
  mov r11, global0Value$1                                        ; value of force cast of ptr to String
  mov [rbp-0198h], r11                                           ; (indirect via r11 because mov can't do memory-to-memory)
  mov qword ptr [rbp-01a0h], 000000016h                          ; new type of force cast of ptr to String
  mov [rbp+010h], rcx                                            ; save rcx in shadow space
  mov [rbp+018h], rdx                                            ; save rdx in shadow space
  mov [rbp+020h], r8                                             ; save r8 in shadow space
  mov [rbp+028h], r9                                             ; save r9 in shadow space
  push [rbp-0198h]                                               ; value of argument #1
  push [rbp-01a0h]                                               ; type of argument #1
  lea r10, [rbp-01a8h]                                           ; pointer to return value (and type, 8 bytes earlier)
  push r10                                                       ; (that pointer is the last value pushed to the stack)
  mov qword ptr r9, 0h                                           ; pointer to this
  mov qword ptr r8, 000000000h                                   ; type of this
  mov qword ptr rdx, 0h                                          ; pointer to closure
  mov rcx, 1                                                     ; number of arguments
  sub rsp, 20h                                                   ; allocate shadow space
  call offset func$println                                       ; jump to subroutine
  add rsp, 038h                                                  ; release shadow space and arguments
  mov rcx, [rbp+010h]                                            ; restore rcx from shadow space
  mov rdx, [rbp+018h]                                            ; restore rdx from shadow space
  mov r8, [rbp+020h]                                             ; restore r8 from shadow space
  mov r9, [rbp+028h]                                             ; restore r9 from shadow space
  ; Line 9: _free(ptr);
  mov [rbp+010h], rcx                                            ; save rcx in shadow space
  mov [rbp+018h], rdx                                            ; save rdx in shadow space
  mov [rbp+020h], r8                                             ; save r8 in shadow space
  mov [rbp+028h], r9                                             ; save r9 in shadow space
  push global0Value$1                                            ; value of argument #1
  push global0Type$1                                             ; type of argument #1
  lea r10, [rbp-01b8h]                                           ; pointer to return value (and type, 8 bytes earlier)
  push r10                                                       ; (that pointer is the last value pushed to the stack)
  mov qword ptr r9, 0h                                           ; pointer to this
  mov qword ptr r8, 000000000h                                   ; type of this
  mov qword ptr rdx, 0h                                          ; pointer to closure
  mov rcx, 1                                                     ; number of arguments
  sub rsp, 20h                                                   ; allocate shadow space
  call offset func$_free                                         ; jump to subroutine
  add rsp, 038h                                                  ; release shadow space and arguments
  mov rcx, [rbp+010h]                                            ; restore rcx from shadow space
  mov rdx, [rbp+018h]                                            ; restore rdx from shadow space
  mov r8, [rbp+020h]                                             ; restore r8 from shadow space
  mov r9, [rbp+028h]                                             ; restore r9 from shadow space
  ; Terminate application - call exit(0)
  mov [rbp+010h], rcx                                            ; save rcx in shadow space
  mov [rbp+018h], rdx                                            ; save rdx in shadow space
  mov [rbp+020h], r8                                             ; save r8 in shadow space
  mov [rbp+028h], r9                                             ; save r9 in shadow space
  push 000000000h                                                ; value of argument #1
  push 000000015h                                                ; type of argument #1
  lea r10, [rbp-01c8h]                                           ; pointer to return value (and type, 8 bytes earlier)
  push r10                                                       ; (that pointer is the last value pushed to the stack)
  mov qword ptr r9, 0h                                           ; pointer to this
  mov qword ptr r8, 000000000h                                   ; type of this
  mov qword ptr rdx, 0h                                          ; pointer to closure
  mov rcx, 1                                                     ; number of arguments
  sub rsp, 20h                                                   ; allocate shadow space
  call offset func$exit                                          ; jump to subroutine
  add rsp, 038h                                                  ; release shadow space and arguments
  mov rcx, [rbp+010h]                                            ; restore rcx from shadow space
  mov rdx, [rbp+018h]                                            ; restore rdx from shadow space
  mov r8, [rbp+020h]                                             ; restore r8 from shadow space
  mov r9, [rbp+028h]                                             ; restore r9 from shadow space
  ; Epilog
  add rsp, 01d0h                                                 ; free space for stack
  pop rbp                                                        ; restore non-volatile registers
  ; End of global scope
  ret                                                            ; exit application

; __print
func$__print:
  ; Prolog
  push rbp                                                       ; save non-volatile registers
  push r15                                                       ; save non-volatile registers
  sub rsp, 048h                                                  ; allocate space for stack
  lea rbp, [rsp+048h]                                            ; set up frame pointer
  mov r15, [rbp+038h]                                            ; prepare return value
  ; Check parameter count
  cmp qword ptr rcx, 000000001h                                  ; compare parameter count to integers
  je func$__print$parameterCount$continuation                    ; check number of parameters is as expected
    ; Error handling block for parameter count
    ;  - print(parameterCountCheckFailureMessage)
    mov [rbp+018h], rcx                                          ; save rcx in shadow space
    mov [rbp+020h], rdx                                          ; save rdx in shadow space
    mov [rbp+028h], r8                                           ; save r8 in shadow space
    mov [rbp+030h], r9                                           ; save r9 in shadow space
    mov r11, offset parameterCountCheckFailureMessage            ; value of argument #1
    push r11                                                     ; (indirect via r11 because "parameterCountCheckFailureMessage" is an imm64)
    push 000000016h                                              ; type of argument #1
    lea r10, [rbp-008h]                                          ; pointer to return value (and type, 8 bytes earlier)
    push r10                                                     ; (that pointer is the last value pushed to the stack)
    mov qword ptr r9, 0h                                         ; pointer to this
    mov qword ptr r8, 000000000h                                 ; type of this
    mov qword ptr rdx, 0h                                        ; pointer to closure
    mov rcx, 1                                                   ; number of arguments
    sub rsp, 20h                                                 ; allocate shadow space
    call offset func$__print                                     ; jump to subroutine
    add rsp, 038h                                                ; release shadow space and arguments
    mov rcx, [rbp+018h]                                          ; restore rcx from shadow space
    mov rdx, [rbp+020h]                                          ; restore rdx from shadow space
    mov r8, [rbp+028h]                                           ; restore r8 from shadow space
    mov r9, [rbp+030h]                                           ; restore r9 from shadow space
    ;  - exit(1)
    mov [rbp+018h], rcx                                          ; save rcx in shadow space
    mov [rbp+020h], rdx                                          ; save rdx in shadow space
    mov [rbp+028h], r8                                           ; save r8 in shadow space
    mov [rbp+030h], r9                                           ; save r9 in shadow space
    push 000000001h                                              ; value of argument #1
    push 000000015h                                              ; type of argument #1
    lea r10, [rbp-018h]                                          ; pointer to return value (and type, 8 bytes earlier)
    push r10                                                     ; (that pointer is the last value pushed to the stack)
    mov qword ptr r9, 0h                                         ; pointer to this
    mov qword ptr r8, 000000000h                                 ; type of this
    mov qword ptr rdx, 0h                                        ; pointer to closure
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
  bt qword ptr [rax], 3                                          ; check that message to print to console is String'22
  jc func$__print$messageToPrintToConsole$TypeMatch              ; skip next block if the type matches
    ; Error handling block for message to print to console
    ;  - print(parameterTypeCheckFailureMessage)
    mov [rbp+018h], rcx                                          ; save rcx in shadow space
    mov [rbp+020h], rdx                                          ; save rdx in shadow space
    mov [rbp+028h], r8                                           ; save r8 in shadow space
    mov [rbp+030h], r9                                           ; save r9 in shadow space
    mov r11, offset parameterTypeCheckFailureMessage             ; value of argument #1
    push r11                                                     ; (indirect via r11 because "parameterTypeCheckFailureMessage" is an imm64)
    push 000000016h                                              ; type of argument #1
    lea r10, [rbp-028h]                                          ; pointer to return value (and type, 8 bytes earlier)
    push r10                                                     ; (that pointer is the last value pushed to the stack)
    mov qword ptr r9, 0h                                         ; pointer to this
    mov qword ptr r8, 000000000h                                 ; type of this
    mov qword ptr rdx, 0h                                        ; pointer to closure
    mov rcx, 1                                                   ; number of arguments
    sub rsp, 20h                                                 ; allocate shadow space
    call offset func$__print                                     ; jump to subroutine
    add rsp, 038h                                                ; release shadow space and arguments
    mov rcx, [rbp+018h]                                          ; restore rcx from shadow space
    mov rdx, [rbp+020h]                                          ; restore rdx from shadow space
    mov r8, [rbp+028h]                                           ; restore r8 from shadow space
    mov r9, [rbp+030h]                                           ; restore r9 from shadow space
    ;  - exit(1)
    mov [rbp+018h], rcx                                          ; save rcx in shadow space
    mov [rbp+020h], rdx                                          ; save rdx in shadow space
    mov [rbp+028h], r8                                           ; save r8 in shadow space
    mov [rbp+030h], r9                                           ; save r9 in shadow space
    push 000000001h                                              ; value of argument #1
    push 000000015h                                              ; type of argument #1
    lea r10, [rbp-038h]                                          ; pointer to return value (and type, 8 bytes earlier)
    push r10                                                     ; (that pointer is the last value pushed to the stack)
    mov qword ptr r9, 0h                                         ; pointer to this
    mov qword ptr r8, 000000000h                                 ; type of this
    mov qword ptr rdx, 0h                                        ; pointer to closure
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
  sub rsp, 20h                                                   ; allocate shadow space
  call GetStdHandle                                              ; handle returned in rax
  add rsp, 20h                                                   ; release shadow space
  ; Calling WriteConsoleA
  push 0                                                         ; argument #5: Reserved, must be NULL (lpReserved)
  lea r9, [rbp-048h]                                             ; argument #4: Number of characters written (lpNumberOfCharsWritten)
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
  add rsp, 048h                                                  ; free space for stack
  pop r15                                                        ; restore non-volatile registers
  pop rbp                                                        ; restore non-volatile registers
  ret                                                            ; return from subroutine

; exit
func$exit:
  ; Prolog
  push rbp                                                       ; save non-volatile registers
  push r15                                                       ; save non-volatile registers
  sub rsp, 040h                                                  ; allocate space for stack
  lea rbp, [rsp+040h]                                            ; set up frame pointer
  mov r15, [rbp+038h]                                            ; prepare return value
  ; Check parameter count
  cmp qword ptr rcx, 000000001h                                  ; compare parameter count to integers
  je func$exit$parameterCount$continuation                       ; check number of parameters is as expected
    ; Error handling block for parameter count
    ;  - print(parameterCountCheckFailureMessage)
    mov [rbp+018h], rcx                                          ; save rcx in shadow space
    mov [rbp+020h], rdx                                          ; save rdx in shadow space
    mov [rbp+028h], r8                                           ; save r8 in shadow space
    mov [rbp+030h], r9                                           ; save r9 in shadow space
    mov r11, offset parameterCountCheckFailureMessage            ; value of argument #1
    push r11                                                     ; (indirect via r11 because "parameterCountCheckFailureMessage" is an imm64)
    push 000000016h                                              ; type of argument #1
    lea r10, [rbp-008h]                                          ; pointer to return value (and type, 8 bytes earlier)
    push r10                                                     ; (that pointer is the last value pushed to the stack)
    mov qword ptr r9, 0h                                         ; pointer to this
    mov qword ptr r8, 000000000h                                 ; type of this
    mov qword ptr rdx, 0h                                        ; pointer to closure
    mov rcx, 1                                                   ; number of arguments
    sub rsp, 20h                                                 ; allocate shadow space
    call offset func$__print                                     ; jump to subroutine
    add rsp, 038h                                                ; release shadow space and arguments
    mov rcx, [rbp+018h]                                          ; restore rcx from shadow space
    mov rdx, [rbp+020h]                                          ; restore rdx from shadow space
    mov r8, [rbp+028h]                                           ; restore r8 from shadow space
    mov r9, [rbp+030h]                                           ; restore r9 from shadow space
    ;  - exit(1)
    mov [rbp+018h], rcx                                          ; save rcx in shadow space
    mov [rbp+020h], rdx                                          ; save rdx in shadow space
    mov [rbp+028h], r8                                           ; save r8 in shadow space
    mov [rbp+030h], r9                                           ; save r9 in shadow space
    push 000000001h                                              ; value of argument #1
    push 000000015h                                              ; type of argument #1
    lea r10, [rbp-018h]                                          ; pointer to return value (and type, 8 bytes earlier)
    push r10                                                     ; (that pointer is the last value pushed to the stack)
    mov qword ptr r9, 0h                                         ; pointer to this
    mov qword ptr r8, 000000000h                                 ; type of this
    mov qword ptr rdx, 0h                                        ; pointer to closure
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
  bt qword ptr [rax], 2                                          ; check that exit code parameter is Integer'21
  jc func$exit$exitCodeParameter$TypeMatch                       ; skip next block if the type matches
    ; Error handling block for exit code parameter
    ;  - print(parameterTypeCheckFailureMessage)
    mov [rbp+018h], rcx                                          ; save rcx in shadow space
    mov [rbp+020h], rdx                                          ; save rdx in shadow space
    mov [rbp+028h], r8                                           ; save r8 in shadow space
    mov [rbp+030h], r9                                           ; save r9 in shadow space
    mov r11, offset parameterTypeCheckFailureMessage             ; value of argument #1
    push r11                                                     ; (indirect via r11 because "parameterTypeCheckFailureMessage" is an imm64)
    push 000000016h                                              ; type of argument #1
    lea r10, [rbp-028h]                                          ; pointer to return value (and type, 8 bytes earlier)
    push r10                                                     ; (that pointer is the last value pushed to the stack)
    mov qword ptr r9, 0h                                         ; pointer to this
    mov qword ptr r8, 000000000h                                 ; type of this
    mov qword ptr rdx, 0h                                        ; pointer to closure
    mov rcx, 1                                                   ; number of arguments
    sub rsp, 20h                                                 ; allocate shadow space
    call offset func$__print                                     ; jump to subroutine
    add rsp, 038h                                                ; release shadow space and arguments
    mov rcx, [rbp+018h]                                          ; restore rcx from shadow space
    mov rdx, [rbp+020h]                                          ; restore rdx from shadow space
    mov r8, [rbp+028h]                                           ; restore r8 from shadow space
    mov r9, [rbp+030h]                                           ; restore r9 from shadow space
    ;  - exit(1)
    mov [rbp+018h], rcx                                          ; save rcx in shadow space
    mov [rbp+020h], rdx                                          ; save rdx in shadow space
    mov [rbp+028h], r8                                           ; save r8 in shadow space
    mov [rbp+030h], r9                                           ; save r9 in shadow space
    push 000000001h                                              ; value of argument #1
    push 000000015h                                              ; type of argument #1
    lea r10, [rbp-038h]                                          ; pointer to return value (and type, 8 bytes earlier)
    push r10                                                     ; (that pointer is the last value pushed to the stack)
    mov qword ptr r9, 0h                                         ; pointer to this
    mov qword ptr r8, 000000000h                                 ; type of this
    mov qword ptr rdx, 0h                                        ; pointer to closure
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
  add rsp, 040h                                                  ; free space for stack
  pop r15                                                        ; restore non-volatile registers
  pop rbp                                                        ; restore non-volatile registers
  ret                                                            ; return from subroutine

; len
func$len:
  ; Prolog
  push rbp                                                       ; save non-volatile registers
  push r15                                                       ; save non-volatile registers
  sub rsp, 040h                                                  ; allocate space for stack
  lea rbp, [rsp+040h]                                            ; set up frame pointer
  mov r15, [rbp+038h]                                            ; prepare return value
  ; Check parameter count
  cmp qword ptr rcx, 000000001h                                  ; compare parameter count to integers
  je func$len$parameterCount$continuation                        ; check number of parameters is as expected
    ; Error handling block for parameter count
    ;  - print(parameterCountCheckFailureMessage)
    mov [rbp+018h], rcx                                          ; save rcx in shadow space
    mov [rbp+020h], rdx                                          ; save rdx in shadow space
    mov [rbp+028h], r8                                           ; save r8 in shadow space
    mov [rbp+030h], r9                                           ; save r9 in shadow space
    mov r11, offset parameterCountCheckFailureMessage            ; value of argument #1
    push r11                                                     ; (indirect via r11 because "parameterCountCheckFailureMessage" is an imm64)
    push 000000016h                                              ; type of argument #1
    lea r10, [rbp-008h]                                          ; pointer to return value (and type, 8 bytes earlier)
    push r10                                                     ; (that pointer is the last value pushed to the stack)
    mov qword ptr r9, 0h                                         ; pointer to this
    mov qword ptr r8, 000000000h                                 ; type of this
    mov qword ptr rdx, 0h                                        ; pointer to closure
    mov rcx, 1                                                   ; number of arguments
    sub rsp, 20h                                                 ; allocate shadow space
    call offset func$__print                                     ; jump to subroutine
    add rsp, 038h                                                ; release shadow space and arguments
    mov rcx, [rbp+018h]                                          ; restore rcx from shadow space
    mov rdx, [rbp+020h]                                          ; restore rdx from shadow space
    mov r8, [rbp+028h]                                           ; restore r8 from shadow space
    mov r9, [rbp+030h]                                           ; restore r9 from shadow space
    ;  - exit(1)
    mov [rbp+018h], rcx                                          ; save rcx in shadow space
    mov [rbp+020h], rdx                                          ; save rdx in shadow space
    mov [rbp+028h], r8                                           ; save r8 in shadow space
    mov [rbp+030h], r9                                           ; save r9 in shadow space
    push 000000001h                                              ; value of argument #1
    push 000000015h                                              ; type of argument #1
    lea r10, [rbp-018h]                                          ; pointer to return value (and type, 8 bytes earlier)
    push r10                                                     ; (that pointer is the last value pushed to the stack)
    mov qword ptr r9, 0h                                         ; pointer to this
    mov qword ptr r8, 000000000h                                 ; type of this
    mov qword ptr rdx, 0h                                        ; pointer to closure
    mov rcx, 1                                                   ; number of arguments
    sub rsp, 20h                                                 ; allocate shadow space
    call offset func$exit                                        ; jump to subroutine
    add rsp, 038h                                                ; release shadow space and arguments
    mov rcx, [rbp+018h]                                          ; restore rcx from shadow space
    mov rdx, [rbp+020h]                                          ; restore rdx from shadow space
    mov r8, [rbp+028h]                                           ; restore r8 from shadow space
    mov r9, [rbp+030h]                                           ; restore r9 from shadow space
  func$len$parameterCount$continuation:                          ; end of parameter count
  ; Check type of parameter 0, list (expecting WhateverReadOnlyList)
  mov rax, [rbp+040h]                                            ; load the dynamic type of list into rax
  lea r10, typeTable                                             ; move type table offset into r10
  add rax, r10                                                   ; adjust rax to point to the type table
  bt qword ptr [rax], 5                                          ; check that list is WhateverReadOnlyList'24
  jc func$len$list$TypeMatch                                     ; skip next block if the type matches
    ; Error handling block for list
    ;  - print(parameterTypeCheckFailureMessage)
    mov [rbp+018h], rcx                                          ; save rcx in shadow space
    mov [rbp+020h], rdx                                          ; save rdx in shadow space
    mov [rbp+028h], r8                                           ; save r8 in shadow space
    mov [rbp+030h], r9                                           ; save r9 in shadow space
    mov r11, offset parameterTypeCheckFailureMessage             ; value of argument #1
    push r11                                                     ; (indirect via r11 because "parameterTypeCheckFailureMessage" is an imm64)
    push 000000016h                                              ; type of argument #1
    lea r10, [rbp-028h]                                          ; pointer to return value (and type, 8 bytes earlier)
    push r10                                                     ; (that pointer is the last value pushed to the stack)
    mov qword ptr r9, 0h                                         ; pointer to this
    mov qword ptr r8, 000000000h                                 ; type of this
    mov qword ptr rdx, 0h                                        ; pointer to closure
    mov rcx, 1                                                   ; number of arguments
    sub rsp, 20h                                                 ; allocate shadow space
    call offset func$__print                                     ; jump to subroutine
    add rsp, 038h                                                ; release shadow space and arguments
    mov rcx, [rbp+018h]                                          ; restore rcx from shadow space
    mov rdx, [rbp+020h]                                          ; restore rdx from shadow space
    mov r8, [rbp+028h]                                           ; restore r8 from shadow space
    mov r9, [rbp+030h]                                           ; restore r9 from shadow space
    ;  - exit(1)
    mov [rbp+018h], rcx                                          ; save rcx in shadow space
    mov [rbp+020h], rdx                                          ; save rdx in shadow space
    mov [rbp+028h], r8                                           ; save r8 in shadow space
    mov [rbp+030h], r9                                           ; save r9 in shadow space
    push 000000001h                                              ; value of argument #1
    push 000000015h                                              ; type of argument #1
    lea r10, [rbp-038h]                                          ; pointer to return value (and type, 8 bytes earlier)
    push r10                                                     ; (that pointer is the last value pushed to the stack)
    mov qword ptr r9, 0h                                         ; pointer to this
    mov qword ptr r8, 000000000h                                 ; type of this
    mov qword ptr rdx, 0h                                        ; pointer to closure
    mov rcx, 1                                                   ; number of arguments
    sub rsp, 20h                                                 ; allocate shadow space
    call offset func$exit                                        ; jump to subroutine
    add rsp, 038h                                                ; release shadow space and arguments
    mov rcx, [rbp+018h]                                          ; restore rcx from shadow space
    mov rdx, [rbp+020h]                                          ; restore rdx from shadow space
    mov r8, [rbp+028h]                                           ; restore r8 from shadow space
    mov r9, [rbp+030h]                                           ; restore r9 from shadow space
  func$len$list$TypeMatch:
  ; TODO: implement "len" function
  func$len$epilog:
  mov rax, r15                                                   ; report address of return value
  ; Epilog
  add rsp, 040h                                                  ; free space for stack
  pop r15                                                        ; restore non-volatile registers
  pop rbp                                                        ; restore non-volatile registers
  ret                                                            ; return from subroutine

; __debugger
func$__debugger:
  ; Prolog
  push rbp                                                       ; save non-volatile registers
  push r15                                                       ; save non-volatile registers
  sub rsp, 020h                                                  ; allocate space for stack
  lea rbp, [rsp+020h]                                            ; set up frame pointer
  mov r15, [rbp+038h]                                            ; prepare return value
  ; Check parameter count
  cmp qword ptr rcx, 000000000h                                  ; compare parameter count to integers
  je func$__debugger$parameterCount$continuation                 ; check number of parameters is as expected
    ; Error handling block for parameter count
    ;  - print(parameterCountCheckFailureMessage)
    mov [rbp+018h], rcx                                          ; save rcx in shadow space
    mov [rbp+020h], rdx                                          ; save rdx in shadow space
    mov [rbp+028h], r8                                           ; save r8 in shadow space
    mov [rbp+030h], r9                                           ; save r9 in shadow space
    mov r11, offset parameterCountCheckFailureMessage            ; value of argument #1
    push r11                                                     ; (indirect via r11 because "parameterCountCheckFailureMessage" is an imm64)
    push 000000016h                                              ; type of argument #1
    lea r10, [rbp-008h]                                          ; pointer to return value (and type, 8 bytes earlier)
    push r10                                                     ; (that pointer is the last value pushed to the stack)
    mov qword ptr r9, 0h                                         ; pointer to this
    mov qword ptr r8, 000000000h                                 ; type of this
    mov qword ptr rdx, 0h                                        ; pointer to closure
    mov rcx, 1                                                   ; number of arguments
    sub rsp, 20h                                                 ; allocate shadow space
    call offset func$__print                                     ; jump to subroutine
    add rsp, 038h                                                ; release shadow space and arguments
    mov rcx, [rbp+018h]                                          ; restore rcx from shadow space
    mov rdx, [rbp+020h]                                          ; restore rdx from shadow space
    mov r8, [rbp+028h]                                           ; restore r8 from shadow space
    mov r9, [rbp+030h]                                           ; restore r9 from shadow space
    ;  - exit(1)
    mov [rbp+018h], rcx                                          ; save rcx in shadow space
    mov [rbp+020h], rdx                                          ; save rdx in shadow space
    mov [rbp+028h], r8                                           ; save r8 in shadow space
    mov [rbp+030h], r9                                           ; save r9 in shadow space
    push 000000001h                                              ; value of argument #1
    push 000000015h                                              ; type of argument #1
    lea r10, [rbp-018h]                                          ; pointer to return value (and type, 8 bytes earlier)
    push r10                                                     ; (that pointer is the last value pushed to the stack)
    mov qword ptr r9, 0h                                         ; pointer to this
    mov qword ptr r8, 000000000h                                 ; type of this
    mov qword ptr rdx, 0h                                        ; pointer to closure
    mov rcx, 1                                                   ; number of arguments
    sub rsp, 20h                                                 ; allocate shadow space
    call offset func$exit                                        ; jump to subroutine
    add rsp, 038h                                                ; release shadow space and arguments
    mov rcx, [rbp+018h]                                          ; restore rcx from shadow space
    mov rdx, [rbp+020h]                                          ; restore rdx from shadow space
    mov r8, [rbp+028h]                                           ; restore r8 from shadow space
    mov r9, [rbp+030h]                                           ; restore r9 from shadow space
  func$__debugger$parameterCount$continuation:                   ; end of parameter count
  ; TODO: implement "debugger" function
  func$__debugger$epilog:
  mov rax, r15                                                   ; report address of return value
  ; Epilog
  add rsp, 020h                                                  ; free space for stack
  pop r15                                                        ; restore non-volatile registers
  pop rbp                                                        ; restore non-volatile registers
  ret                                                            ; return from subroutine

; __getProcessHeap
func$__getProcessHeap:
  ; Prolog
  push rbp                                                       ; save non-volatile registers
  push r15                                                       ; save non-volatile registers
  sub rsp, 020h                                                  ; allocate space for stack
  lea rbp, [rsp+020h]                                            ; set up frame pointer
  mov r15, [rbp+038h]                                            ; prepare return value
  ; Check parameter count
  cmp qword ptr rcx, 000000000h                                  ; compare parameter count to integers
  je func$__getProcessHeap$parameterCount$continuation           ; check number of parameters is as expected
    ; Error handling block for parameter count
    ;  - print(parameterCountCheckFailureMessage)
    mov [rbp+018h], rcx                                          ; save rcx in shadow space
    mov [rbp+020h], rdx                                          ; save rdx in shadow space
    mov [rbp+028h], r8                                           ; save r8 in shadow space
    mov [rbp+030h], r9                                           ; save r9 in shadow space
    mov r11, offset parameterCountCheckFailureMessage            ; value of argument #1
    push r11                                                     ; (indirect via r11 because "parameterCountCheckFailureMessage" is an imm64)
    push 000000016h                                              ; type of argument #1
    lea r10, [rbp-008h]                                          ; pointer to return value (and type, 8 bytes earlier)
    push r10                                                     ; (that pointer is the last value pushed to the stack)
    mov qword ptr r9, 0h                                         ; pointer to this
    mov qword ptr r8, 000000000h                                 ; type of this
    mov qword ptr rdx, 0h                                        ; pointer to closure
    mov rcx, 1                                                   ; number of arguments
    sub rsp, 20h                                                 ; allocate shadow space
    call offset func$__print                                     ; jump to subroutine
    add rsp, 038h                                                ; release shadow space and arguments
    mov rcx, [rbp+018h]                                          ; restore rcx from shadow space
    mov rdx, [rbp+020h]                                          ; restore rdx from shadow space
    mov r8, [rbp+028h]                                           ; restore r8 from shadow space
    mov r9, [rbp+030h]                                           ; restore r9 from shadow space
    ;  - exit(1)
    mov [rbp+018h], rcx                                          ; save rcx in shadow space
    mov [rbp+020h], rdx                                          ; save rdx in shadow space
    mov [rbp+028h], r8                                           ; save r8 in shadow space
    mov [rbp+030h], r9                                           ; save r9 in shadow space
    push 000000001h                                              ; value of argument #1
    push 000000015h                                              ; type of argument #1
    lea r10, [rbp-018h]                                          ; pointer to return value (and type, 8 bytes earlier)
    push r10                                                     ; (that pointer is the last value pushed to the stack)
    mov qword ptr r9, 0h                                         ; pointer to this
    mov qword ptr r8, 000000000h                                 ; type of this
    mov qword ptr rdx, 0h                                        ; pointer to closure
    mov rcx, 1                                                   ; number of arguments
    sub rsp, 20h                                                 ; allocate shadow space
    call offset func$exit                                        ; jump to subroutine
    add rsp, 038h                                                ; release shadow space and arguments
    mov rcx, [rbp+018h]                                          ; restore rcx from shadow space
    mov rdx, [rbp+020h]                                          ; restore rdx from shadow space
    mov r8, [rbp+028h]                                           ; restore r8 from shadow space
    mov r9, [rbp+030h]                                           ; restore r9 from shadow space
  func$__getProcessHeap$parameterCount$continuation:             ; end of parameter count
  mov [rbp+018h], rcx                                            ; save rcx in shadow space
  mov [rbp+020h], rdx                                            ; save rdx in shadow space
  mov [rbp+028h], r8                                             ; save r8 in shadow space
  mov [rbp+030h], r9                                             ; save r9 in shadow space
  ; Calling GetProcessHeap
  sub rsp, 20h                                                   ; allocate shadow space
  call GetProcessHeap                                            ; handle returned in rax
  add rsp, 20h                                                   ; release shadow space
  mov [r15], rax                                                 ; heap handle
  mov qword ptr [r15-08h], 000000015h                            ; heap handle is an integer
  mov rcx, [rbp+018h]                                            ; restore rcx from shadow space
  mov rdx, [rbp+020h]                                            ; restore rdx from shadow space
  mov r8, [rbp+028h]                                             ; restore r8 from shadow space
  mov r9, [rbp+030h]                                             ; restore r9 from shadow space
  func$__getProcessHeap$epilog:
  mov rax, r15                                                   ; report address of return value
  ; Epilog
  add rsp, 020h                                                  ; free space for stack
  pop r15                                                        ; restore non-volatile registers
  pop rbp                                                        ; restore non-volatile registers
  ret                                                            ; return from subroutine

; __heapAlloc
func$__heapAlloc:
  ; Prolog
  push rbp                                                       ; save non-volatile registers
  push r15                                                       ; save non-volatile registers
  sub rsp, 080h                                                  ; allocate space for stack
  lea rbp, [rsp+080h]                                            ; set up frame pointer
  mov r15, [rbp+038h]                                            ; prepare return value
  ; Check parameter count
  cmp qword ptr rcx, 000000003h                                  ; compare parameter count to integers
  je func$__heapAlloc$parameterCount$continuation                ; check number of parameters is as expected
    ; Error handling block for parameter count
    ;  - print(parameterCountCheckFailureMessage)
    mov [rbp+018h], rcx                                          ; save rcx in shadow space
    mov [rbp+020h], rdx                                          ; save rdx in shadow space
    mov [rbp+028h], r8                                           ; save r8 in shadow space
    mov [rbp+030h], r9                                           ; save r9 in shadow space
    mov r11, offset parameterCountCheckFailureMessage            ; value of argument #1
    push r11                                                     ; (indirect via r11 because "parameterCountCheckFailureMessage" is an imm64)
    push 000000016h                                              ; type of argument #1
    lea r10, [rbp-008h]                                          ; pointer to return value (and type, 8 bytes earlier)
    push r10                                                     ; (that pointer is the last value pushed to the stack)
    mov qword ptr r9, 0h                                         ; pointer to this
    mov qword ptr r8, 000000000h                                 ; type of this
    mov qword ptr rdx, 0h                                        ; pointer to closure
    mov rcx, 1                                                   ; number of arguments
    sub rsp, 20h                                                 ; allocate shadow space
    call offset func$__print                                     ; jump to subroutine
    add rsp, 038h                                                ; release shadow space and arguments
    mov rcx, [rbp+018h]                                          ; restore rcx from shadow space
    mov rdx, [rbp+020h]                                          ; restore rdx from shadow space
    mov r8, [rbp+028h]                                           ; restore r8 from shadow space
    mov r9, [rbp+030h]                                           ; restore r9 from shadow space
    ;  - exit(1)
    mov [rbp+018h], rcx                                          ; save rcx in shadow space
    mov [rbp+020h], rdx                                          ; save rdx in shadow space
    mov [rbp+028h], r8                                           ; save r8 in shadow space
    mov [rbp+030h], r9                                           ; save r9 in shadow space
    push 000000001h                                              ; value of argument #1
    push 000000015h                                              ; type of argument #1
    lea r10, [rbp-018h]                                          ; pointer to return value (and type, 8 bytes earlier)
    push r10                                                     ; (that pointer is the last value pushed to the stack)
    mov qword ptr r9, 0h                                         ; pointer to this
    mov qword ptr r8, 000000000h                                 ; type of this
    mov qword ptr rdx, 0h                                        ; pointer to closure
    mov rcx, 1                                                   ; number of arguments
    sub rsp, 20h                                                 ; allocate shadow space
    call offset func$exit                                        ; jump to subroutine
    add rsp, 038h                                                ; release shadow space and arguments
    mov rcx, [rbp+018h]                                          ; restore rcx from shadow space
    mov rdx, [rbp+020h]                                          ; restore rdx from shadow space
    mov r8, [rbp+028h]                                           ; restore r8 from shadow space
    mov r9, [rbp+030h]                                           ; restore r9 from shadow space
  func$__heapAlloc$parameterCount$continuation:                  ; end of parameter count
  ; Check type of parameter 0, heapHandle (expecting Integer)
  mov rax, [rbp+040h]                                            ; load the dynamic type of heapHandle into rax
  lea r10, typeTable                                             ; move type table offset into r10
  add rax, r10                                                   ; adjust rax to point to the type table
  bt qword ptr [rax], 2                                          ; check that heapHandle is Integer'21
  jc func$__heapAlloc$heaphandle$TypeMatch                       ; skip next block if the type matches
    ; Error handling block for heapHandle
    ;  - print(parameterTypeCheckFailureMessage)
    mov [rbp+018h], rcx                                          ; save rcx in shadow space
    mov [rbp+020h], rdx                                          ; save rdx in shadow space
    mov [rbp+028h], r8                                           ; save r8 in shadow space
    mov [rbp+030h], r9                                           ; save r9 in shadow space
    mov r11, offset parameterTypeCheckFailureMessage             ; value of argument #1
    push r11                                                     ; (indirect via r11 because "parameterTypeCheckFailureMessage" is an imm64)
    push 000000016h                                              ; type of argument #1
    lea r10, [rbp-028h]                                          ; pointer to return value (and type, 8 bytes earlier)
    push r10                                                     ; (that pointer is the last value pushed to the stack)
    mov qword ptr r9, 0h                                         ; pointer to this
    mov qword ptr r8, 000000000h                                 ; type of this
    mov qword ptr rdx, 0h                                        ; pointer to closure
    mov rcx, 1                                                   ; number of arguments
    sub rsp, 20h                                                 ; allocate shadow space
    call offset func$__print                                     ; jump to subroutine
    add rsp, 038h                                                ; release shadow space and arguments
    mov rcx, [rbp+018h]                                          ; restore rcx from shadow space
    mov rdx, [rbp+020h]                                          ; restore rdx from shadow space
    mov r8, [rbp+028h]                                           ; restore r8 from shadow space
    mov r9, [rbp+030h]                                           ; restore r9 from shadow space
    ;  - exit(1)
    mov [rbp+018h], rcx                                          ; save rcx in shadow space
    mov [rbp+020h], rdx                                          ; save rdx in shadow space
    mov [rbp+028h], r8                                           ; save r8 in shadow space
    mov [rbp+030h], r9                                           ; save r9 in shadow space
    push 000000001h                                              ; value of argument #1
    push 000000015h                                              ; type of argument #1
    lea r10, [rbp-038h]                                          ; pointer to return value (and type, 8 bytes earlier)
    push r10                                                     ; (that pointer is the last value pushed to the stack)
    mov qword ptr r9, 0h                                         ; pointer to this
    mov qword ptr r8, 000000000h                                 ; type of this
    mov qword ptr rdx, 0h                                        ; pointer to closure
    mov rcx, 1                                                   ; number of arguments
    sub rsp, 20h                                                 ; allocate shadow space
    call offset func$exit                                        ; jump to subroutine
    add rsp, 038h                                                ; release shadow space and arguments
    mov rcx, [rbp+018h]                                          ; restore rcx from shadow space
    mov rdx, [rbp+020h]                                          ; restore rdx from shadow space
    mov r8, [rbp+028h]                                           ; restore r8 from shadow space
    mov r9, [rbp+030h]                                           ; restore r9 from shadow space
  func$__heapAlloc$heaphandle$TypeMatch:
  ; Check type of parameter 1, flags (expecting Integer)
  mov rax, [rbp+050h]                                            ; load the dynamic type of flags into rax
  lea r10, typeTable                                             ; move type table offset into r10
  add rax, r10                                                   ; adjust rax to point to the type table
  bt qword ptr [rax], 2                                          ; check that flags is Integer'21
  jc func$__heapAlloc$flags$TypeMatch                            ; skip next block if the type matches
    ; Error handling block for flags
    ;  - print(parameterTypeCheckFailureMessage)
    mov [rbp+018h], rcx                                          ; save rcx in shadow space
    mov [rbp+020h], rdx                                          ; save rdx in shadow space
    mov [rbp+028h], r8                                           ; save r8 in shadow space
    mov [rbp+030h], r9                                           ; save r9 in shadow space
    mov r11, offset parameterTypeCheckFailureMessage             ; value of argument #1
    push r11                                                     ; (indirect via r11 because "parameterTypeCheckFailureMessage" is an imm64)
    push 000000016h                                              ; type of argument #1
    lea r10, [rbp-048h]                                          ; pointer to return value (and type, 8 bytes earlier)
    push r10                                                     ; (that pointer is the last value pushed to the stack)
    mov qword ptr r9, 0h                                         ; pointer to this
    mov qword ptr r8, 000000000h                                 ; type of this
    mov qword ptr rdx, 0h                                        ; pointer to closure
    mov rcx, 1                                                   ; number of arguments
    sub rsp, 20h                                                 ; allocate shadow space
    call offset func$__print                                     ; jump to subroutine
    add rsp, 038h                                                ; release shadow space and arguments
    mov rcx, [rbp+018h]                                          ; restore rcx from shadow space
    mov rdx, [rbp+020h]                                          ; restore rdx from shadow space
    mov r8, [rbp+028h]                                           ; restore r8 from shadow space
    mov r9, [rbp+030h]                                           ; restore r9 from shadow space
    ;  - exit(1)
    mov [rbp+018h], rcx                                          ; save rcx in shadow space
    mov [rbp+020h], rdx                                          ; save rdx in shadow space
    mov [rbp+028h], r8                                           ; save r8 in shadow space
    mov [rbp+030h], r9                                           ; save r9 in shadow space
    push 000000001h                                              ; value of argument #1
    push 000000015h                                              ; type of argument #1
    lea r10, [rbp-058h]                                          ; pointer to return value (and type, 8 bytes earlier)
    push r10                                                     ; (that pointer is the last value pushed to the stack)
    mov qword ptr r9, 0h                                         ; pointer to this
    mov qword ptr r8, 000000000h                                 ; type of this
    mov qword ptr rdx, 0h                                        ; pointer to closure
    mov rcx, 1                                                   ; number of arguments
    sub rsp, 20h                                                 ; allocate shadow space
    call offset func$exit                                        ; jump to subroutine
    add rsp, 038h                                                ; release shadow space and arguments
    mov rcx, [rbp+018h]                                          ; restore rcx from shadow space
    mov rdx, [rbp+020h]                                          ; restore rdx from shadow space
    mov r8, [rbp+028h]                                           ; restore r8 from shadow space
    mov r9, [rbp+030h]                                           ; restore r9 from shadow space
  func$__heapAlloc$flags$TypeMatch:
  ; Check type of parameter 2, size (expecting Integer)
  mov rax, [rbp+060h]                                            ; load the dynamic type of size into rax
  lea r10, typeTable                                             ; move type table offset into r10
  add rax, r10                                                   ; adjust rax to point to the type table
  bt qword ptr [rax], 2                                          ; check that size is Integer'21
  jc func$__heapAlloc$size$TypeMatch                             ; skip next block if the type matches
    ; Error handling block for size
    ;  - print(parameterTypeCheckFailureMessage)
    mov [rbp+018h], rcx                                          ; save rcx in shadow space
    mov [rbp+020h], rdx                                          ; save rdx in shadow space
    mov [rbp+028h], r8                                           ; save r8 in shadow space
    mov [rbp+030h], r9                                           ; save r9 in shadow space
    mov r11, offset parameterTypeCheckFailureMessage             ; value of argument #1
    push r11                                                     ; (indirect via r11 because "parameterTypeCheckFailureMessage" is an imm64)
    push 000000016h                                              ; type of argument #1
    lea r10, [rbp-068h]                                          ; pointer to return value (and type, 8 bytes earlier)
    push r10                                                     ; (that pointer is the last value pushed to the stack)
    mov qword ptr r9, 0h                                         ; pointer to this
    mov qword ptr r8, 000000000h                                 ; type of this
    mov qword ptr rdx, 0h                                        ; pointer to closure
    mov rcx, 1                                                   ; number of arguments
    sub rsp, 20h                                                 ; allocate shadow space
    call offset func$__print                                     ; jump to subroutine
    add rsp, 038h                                                ; release shadow space and arguments
    mov rcx, [rbp+018h]                                          ; restore rcx from shadow space
    mov rdx, [rbp+020h]                                          ; restore rdx from shadow space
    mov r8, [rbp+028h]                                           ; restore r8 from shadow space
    mov r9, [rbp+030h]                                           ; restore r9 from shadow space
    ;  - exit(1)
    mov [rbp+018h], rcx                                          ; save rcx in shadow space
    mov [rbp+020h], rdx                                          ; save rdx in shadow space
    mov [rbp+028h], r8                                           ; save r8 in shadow space
    mov [rbp+030h], r9                                           ; save r9 in shadow space
    push 000000001h                                              ; value of argument #1
    push 000000015h                                              ; type of argument #1
    lea r10, [rbp-078h]                                          ; pointer to return value (and type, 8 bytes earlier)
    push r10                                                     ; (that pointer is the last value pushed to the stack)
    mov qword ptr r9, 0h                                         ; pointer to this
    mov qword ptr r8, 000000000h                                 ; type of this
    mov qword ptr rdx, 0h                                        ; pointer to closure
    mov rcx, 1                                                   ; number of arguments
    sub rsp, 20h                                                 ; allocate shadow space
    call offset func$exit                                        ; jump to subroutine
    add rsp, 038h                                                ; release shadow space and arguments
    mov rcx, [rbp+018h]                                          ; restore rcx from shadow space
    mov rdx, [rbp+020h]                                          ; restore rdx from shadow space
    mov r8, [rbp+028h]                                           ; restore r8 from shadow space
    mov r9, [rbp+030h]                                           ; restore r9 from shadow space
  func$__heapAlloc$size$TypeMatch:
  mov [rbp+018h], rcx                                            ; save rcx in shadow space
  mov [rbp+020h], rdx                                            ; save rdx in shadow space
  mov [rbp+028h], r8                                             ; save r8 in shadow space
  mov [rbp+030h], r9                                             ; save r9 in shadow space
  ; Calling HeapAlloc
  mov rcx, [rbp+048h]                                            ; hHeap argument
  mov rdx, [rbp+058h]                                            ; dwFlags argument
  mov r8, [rbp+068h]                                             ; dwBytes argument
  sub rsp, 20h                                                   ; allocate shadow space
  call HeapAlloc                                                 ; pointer returned in rax
  add rsp, 20h                                                   ; release shadow space
  mov [r15], rax                                                 ; pointer
  mov qword ptr [r15-08h], 000000015h                            ; pointer is an integer
  mov rcx, [rbp+018h]                                            ; restore rcx from shadow space
  mov rdx, [rbp+020h]                                            ; restore rdx from shadow space
  mov r8, [rbp+028h]                                             ; restore r8 from shadow space
  mov r9, [rbp+030h]                                             ; restore r9 from shadow space
  func$__heapAlloc$epilog:
  mov rax, r15                                                   ; report address of return value
  ; Epilog
  add rsp, 080h                                                  ; free space for stack
  pop r15                                                        ; restore non-volatile registers
  pop rbp                                                        ; restore non-volatile registers
  ret                                                            ; return from subroutine

; __heapFree
func$__heapFree:
  ; Prolog
  push rbp                                                       ; save non-volatile registers
  push r15                                                       ; save non-volatile registers
  sub rsp, 080h                                                  ; allocate space for stack
  lea rbp, [rsp+080h]                                            ; set up frame pointer
  mov r15, [rbp+038h]                                            ; prepare return value
  ; Check parameter count
  cmp qword ptr rcx, 000000003h                                  ; compare parameter count to integers
  je func$__heapFree$parameterCount$continuation                 ; check number of parameters is as expected
    ; Error handling block for parameter count
    ;  - print(parameterCountCheckFailureMessage)
    mov [rbp+018h], rcx                                          ; save rcx in shadow space
    mov [rbp+020h], rdx                                          ; save rdx in shadow space
    mov [rbp+028h], r8                                           ; save r8 in shadow space
    mov [rbp+030h], r9                                           ; save r9 in shadow space
    mov r11, offset parameterCountCheckFailureMessage            ; value of argument #1
    push r11                                                     ; (indirect via r11 because "parameterCountCheckFailureMessage" is an imm64)
    push 000000016h                                              ; type of argument #1
    lea r10, [rbp-008h]                                          ; pointer to return value (and type, 8 bytes earlier)
    push r10                                                     ; (that pointer is the last value pushed to the stack)
    mov qword ptr r9, 0h                                         ; pointer to this
    mov qword ptr r8, 000000000h                                 ; type of this
    mov qword ptr rdx, 0h                                        ; pointer to closure
    mov rcx, 1                                                   ; number of arguments
    sub rsp, 20h                                                 ; allocate shadow space
    call offset func$__print                                     ; jump to subroutine
    add rsp, 038h                                                ; release shadow space and arguments
    mov rcx, [rbp+018h]                                          ; restore rcx from shadow space
    mov rdx, [rbp+020h]                                          ; restore rdx from shadow space
    mov r8, [rbp+028h]                                           ; restore r8 from shadow space
    mov r9, [rbp+030h]                                           ; restore r9 from shadow space
    ;  - exit(1)
    mov [rbp+018h], rcx                                          ; save rcx in shadow space
    mov [rbp+020h], rdx                                          ; save rdx in shadow space
    mov [rbp+028h], r8                                           ; save r8 in shadow space
    mov [rbp+030h], r9                                           ; save r9 in shadow space
    push 000000001h                                              ; value of argument #1
    push 000000015h                                              ; type of argument #1
    lea r10, [rbp-018h]                                          ; pointer to return value (and type, 8 bytes earlier)
    push r10                                                     ; (that pointer is the last value pushed to the stack)
    mov qword ptr r9, 0h                                         ; pointer to this
    mov qword ptr r8, 000000000h                                 ; type of this
    mov qword ptr rdx, 0h                                        ; pointer to closure
    mov rcx, 1                                                   ; number of arguments
    sub rsp, 20h                                                 ; allocate shadow space
    call offset func$exit                                        ; jump to subroutine
    add rsp, 038h                                                ; release shadow space and arguments
    mov rcx, [rbp+018h]                                          ; restore rcx from shadow space
    mov rdx, [rbp+020h]                                          ; restore rdx from shadow space
    mov r8, [rbp+028h]                                           ; restore r8 from shadow space
    mov r9, [rbp+030h]                                           ; restore r9 from shadow space
  func$__heapFree$parameterCount$continuation:                   ; end of parameter count
  ; Check type of parameter 0, heapHandle (expecting Integer)
  mov rax, [rbp+040h]                                            ; load the dynamic type of heapHandle into rax
  lea r10, typeTable                                             ; move type table offset into r10
  add rax, r10                                                   ; adjust rax to point to the type table
  bt qword ptr [rax], 2                                          ; check that heapHandle is Integer'21
  jc func$__heapFree$heaphandle$TypeMatch                        ; skip next block if the type matches
    ; Error handling block for heapHandle
    ;  - print(parameterTypeCheckFailureMessage)
    mov [rbp+018h], rcx                                          ; save rcx in shadow space
    mov [rbp+020h], rdx                                          ; save rdx in shadow space
    mov [rbp+028h], r8                                           ; save r8 in shadow space
    mov [rbp+030h], r9                                           ; save r9 in shadow space
    mov r11, offset parameterTypeCheckFailureMessage             ; value of argument #1
    push r11                                                     ; (indirect via r11 because "parameterTypeCheckFailureMessage" is an imm64)
    push 000000016h                                              ; type of argument #1
    lea r10, [rbp-028h]                                          ; pointer to return value (and type, 8 bytes earlier)
    push r10                                                     ; (that pointer is the last value pushed to the stack)
    mov qword ptr r9, 0h                                         ; pointer to this
    mov qword ptr r8, 000000000h                                 ; type of this
    mov qword ptr rdx, 0h                                        ; pointer to closure
    mov rcx, 1                                                   ; number of arguments
    sub rsp, 20h                                                 ; allocate shadow space
    call offset func$__print                                     ; jump to subroutine
    add rsp, 038h                                                ; release shadow space and arguments
    mov rcx, [rbp+018h]                                          ; restore rcx from shadow space
    mov rdx, [rbp+020h]                                          ; restore rdx from shadow space
    mov r8, [rbp+028h]                                           ; restore r8 from shadow space
    mov r9, [rbp+030h]                                           ; restore r9 from shadow space
    ;  - exit(1)
    mov [rbp+018h], rcx                                          ; save rcx in shadow space
    mov [rbp+020h], rdx                                          ; save rdx in shadow space
    mov [rbp+028h], r8                                           ; save r8 in shadow space
    mov [rbp+030h], r9                                           ; save r9 in shadow space
    push 000000001h                                              ; value of argument #1
    push 000000015h                                              ; type of argument #1
    lea r10, [rbp-038h]                                          ; pointer to return value (and type, 8 bytes earlier)
    push r10                                                     ; (that pointer is the last value pushed to the stack)
    mov qword ptr r9, 0h                                         ; pointer to this
    mov qword ptr r8, 000000000h                                 ; type of this
    mov qword ptr rdx, 0h                                        ; pointer to closure
    mov rcx, 1                                                   ; number of arguments
    sub rsp, 20h                                                 ; allocate shadow space
    call offset func$exit                                        ; jump to subroutine
    add rsp, 038h                                                ; release shadow space and arguments
    mov rcx, [rbp+018h]                                          ; restore rcx from shadow space
    mov rdx, [rbp+020h]                                          ; restore rdx from shadow space
    mov r8, [rbp+028h]                                           ; restore r8 from shadow space
    mov r9, [rbp+030h]                                           ; restore r9 from shadow space
  func$__heapFree$heaphandle$TypeMatch:
  ; Check type of parameter 1, flags (expecting Integer)
  mov rax, [rbp+050h]                                            ; load the dynamic type of flags into rax
  lea r10, typeTable                                             ; move type table offset into r10
  add rax, r10                                                   ; adjust rax to point to the type table
  bt qword ptr [rax], 2                                          ; check that flags is Integer'21
  jc func$__heapFree$flags$TypeMatch                             ; skip next block if the type matches
    ; Error handling block for flags
    ;  - print(parameterTypeCheckFailureMessage)
    mov [rbp+018h], rcx                                          ; save rcx in shadow space
    mov [rbp+020h], rdx                                          ; save rdx in shadow space
    mov [rbp+028h], r8                                           ; save r8 in shadow space
    mov [rbp+030h], r9                                           ; save r9 in shadow space
    mov r11, offset parameterTypeCheckFailureMessage             ; value of argument #1
    push r11                                                     ; (indirect via r11 because "parameterTypeCheckFailureMessage" is an imm64)
    push 000000016h                                              ; type of argument #1
    lea r10, [rbp-048h]                                          ; pointer to return value (and type, 8 bytes earlier)
    push r10                                                     ; (that pointer is the last value pushed to the stack)
    mov qword ptr r9, 0h                                         ; pointer to this
    mov qword ptr r8, 000000000h                                 ; type of this
    mov qword ptr rdx, 0h                                        ; pointer to closure
    mov rcx, 1                                                   ; number of arguments
    sub rsp, 20h                                                 ; allocate shadow space
    call offset func$__print                                     ; jump to subroutine
    add rsp, 038h                                                ; release shadow space and arguments
    mov rcx, [rbp+018h]                                          ; restore rcx from shadow space
    mov rdx, [rbp+020h]                                          ; restore rdx from shadow space
    mov r8, [rbp+028h]                                           ; restore r8 from shadow space
    mov r9, [rbp+030h]                                           ; restore r9 from shadow space
    ;  - exit(1)
    mov [rbp+018h], rcx                                          ; save rcx in shadow space
    mov [rbp+020h], rdx                                          ; save rdx in shadow space
    mov [rbp+028h], r8                                           ; save r8 in shadow space
    mov [rbp+030h], r9                                           ; save r9 in shadow space
    push 000000001h                                              ; value of argument #1
    push 000000015h                                              ; type of argument #1
    lea r10, [rbp-058h]                                          ; pointer to return value (and type, 8 bytes earlier)
    push r10                                                     ; (that pointer is the last value pushed to the stack)
    mov qword ptr r9, 0h                                         ; pointer to this
    mov qword ptr r8, 000000000h                                 ; type of this
    mov qword ptr rdx, 0h                                        ; pointer to closure
    mov rcx, 1                                                   ; number of arguments
    sub rsp, 20h                                                 ; allocate shadow space
    call offset func$exit                                        ; jump to subroutine
    add rsp, 038h                                                ; release shadow space and arguments
    mov rcx, [rbp+018h]                                          ; restore rcx from shadow space
    mov rdx, [rbp+020h]                                          ; restore rdx from shadow space
    mov r8, [rbp+028h]                                           ; restore r8 from shadow space
    mov r9, [rbp+030h]                                           ; restore r9 from shadow space
  func$__heapFree$flags$TypeMatch:
  ; Check type of parameter 2, pointer (expecting Integer)
  mov rax, [rbp+060h]                                            ; load the dynamic type of pointer into rax
  lea r10, typeTable                                             ; move type table offset into r10
  add rax, r10                                                   ; adjust rax to point to the type table
  bt qword ptr [rax], 2                                          ; check that pointer is Integer'21
  jc func$__heapFree$pointer$TypeMatch                           ; skip next block if the type matches
    ; Error handling block for pointer
    ;  - print(parameterTypeCheckFailureMessage)
    mov [rbp+018h], rcx                                          ; save rcx in shadow space
    mov [rbp+020h], rdx                                          ; save rdx in shadow space
    mov [rbp+028h], r8                                           ; save r8 in shadow space
    mov [rbp+030h], r9                                           ; save r9 in shadow space
    mov r11, offset parameterTypeCheckFailureMessage             ; value of argument #1
    push r11                                                     ; (indirect via r11 because "parameterTypeCheckFailureMessage" is an imm64)
    push 000000016h                                              ; type of argument #1
    lea r10, [rbp-068h]                                          ; pointer to return value (and type, 8 bytes earlier)
    push r10                                                     ; (that pointer is the last value pushed to the stack)
    mov qword ptr r9, 0h                                         ; pointer to this
    mov qword ptr r8, 000000000h                                 ; type of this
    mov qword ptr rdx, 0h                                        ; pointer to closure
    mov rcx, 1                                                   ; number of arguments
    sub rsp, 20h                                                 ; allocate shadow space
    call offset func$__print                                     ; jump to subroutine
    add rsp, 038h                                                ; release shadow space and arguments
    mov rcx, [rbp+018h]                                          ; restore rcx from shadow space
    mov rdx, [rbp+020h]                                          ; restore rdx from shadow space
    mov r8, [rbp+028h]                                           ; restore r8 from shadow space
    mov r9, [rbp+030h]                                           ; restore r9 from shadow space
    ;  - exit(1)
    mov [rbp+018h], rcx                                          ; save rcx in shadow space
    mov [rbp+020h], rdx                                          ; save rdx in shadow space
    mov [rbp+028h], r8                                           ; save r8 in shadow space
    mov [rbp+030h], r9                                           ; save r9 in shadow space
    push 000000001h                                              ; value of argument #1
    push 000000015h                                              ; type of argument #1
    lea r10, [rbp-078h]                                          ; pointer to return value (and type, 8 bytes earlier)
    push r10                                                     ; (that pointer is the last value pushed to the stack)
    mov qword ptr r9, 0h                                         ; pointer to this
    mov qword ptr r8, 000000000h                                 ; type of this
    mov qword ptr rdx, 0h                                        ; pointer to closure
    mov rcx, 1                                                   ; number of arguments
    sub rsp, 20h                                                 ; allocate shadow space
    call offset func$exit                                        ; jump to subroutine
    add rsp, 038h                                                ; release shadow space and arguments
    mov rcx, [rbp+018h]                                          ; restore rcx from shadow space
    mov rdx, [rbp+020h]                                          ; restore rdx from shadow space
    mov r8, [rbp+028h]                                           ; restore r8 from shadow space
    mov r9, [rbp+030h]                                           ; restore r9 from shadow space
  func$__heapFree$pointer$TypeMatch:
  mov [rbp+018h], rcx                                            ; save rcx in shadow space
  mov [rbp+020h], rdx                                            ; save rdx in shadow space
  mov [rbp+028h], r8                                             ; save r8 in shadow space
  mov [rbp+030h], r9                                             ; save r9 in shadow space
  ; Calling HeapFree
  mov rcx, [rbp+048h]                                            ; hHeap argument
  mov rdx, [rbp+058h]                                            ; dwFlags argument
  mov r8, [rbp+068h]                                             ; lpMem argument
  sub rsp, 20h                                                   ; allocate shadow space
  call HeapFree                                                  ; result (positive for success, zero for failure) is in rax
  add rsp, 20h                                                   ; release shadow space
  mov [r15], rax                                                 ; result (positive for success, zero for failure)
  mov qword ptr [r15-08h], 000000015h                            ; result is an integer
  mov rcx, [rbp+018h]                                            ; restore rcx from shadow space
  mov rdx, [rbp+020h]                                            ; restore rdx from shadow space
  mov r8, [rbp+028h]                                             ; restore r8 from shadow space
  mov r9, [rbp+030h]                                             ; restore r9 from shadow space
  func$__heapFree$epilog:
  mov rax, r15                                                   ; report address of return value
  ; Epilog
  add rsp, 080h                                                  ; free space for stack
  pop r15                                                        ; restore non-volatile registers
  pop rbp                                                        ; restore non-volatile registers
  ret                                                            ; return from subroutine

; __getLastError
func$__getLastError:
  ; Prolog
  push rbp                                                       ; save non-volatile registers
  push r15                                                       ; save non-volatile registers
  sub rsp, 020h                                                  ; allocate space for stack
  lea rbp, [rsp+020h]                                            ; set up frame pointer
  mov r15, [rbp+038h]                                            ; prepare return value
  ; Check parameter count
  cmp qword ptr rcx, 000000000h                                  ; compare parameter count to integers
  je func$__getLastError$parameterCount$continuation             ; check number of parameters is as expected
    ; Error handling block for parameter count
    ;  - print(parameterCountCheckFailureMessage)
    mov [rbp+018h], rcx                                          ; save rcx in shadow space
    mov [rbp+020h], rdx                                          ; save rdx in shadow space
    mov [rbp+028h], r8                                           ; save r8 in shadow space
    mov [rbp+030h], r9                                           ; save r9 in shadow space
    mov r11, offset parameterCountCheckFailureMessage            ; value of argument #1
    push r11                                                     ; (indirect via r11 because "parameterCountCheckFailureMessage" is an imm64)
    push 000000016h                                              ; type of argument #1
    lea r10, [rbp-008h]                                          ; pointer to return value (and type, 8 bytes earlier)
    push r10                                                     ; (that pointer is the last value pushed to the stack)
    mov qword ptr r9, 0h                                         ; pointer to this
    mov qword ptr r8, 000000000h                                 ; type of this
    mov qword ptr rdx, 0h                                        ; pointer to closure
    mov rcx, 1                                                   ; number of arguments
    sub rsp, 20h                                                 ; allocate shadow space
    call offset func$__print                                     ; jump to subroutine
    add rsp, 038h                                                ; release shadow space and arguments
    mov rcx, [rbp+018h]                                          ; restore rcx from shadow space
    mov rdx, [rbp+020h]                                          ; restore rdx from shadow space
    mov r8, [rbp+028h]                                           ; restore r8 from shadow space
    mov r9, [rbp+030h]                                           ; restore r9 from shadow space
    ;  - exit(1)
    mov [rbp+018h], rcx                                          ; save rcx in shadow space
    mov [rbp+020h], rdx                                          ; save rdx in shadow space
    mov [rbp+028h], r8                                           ; save r8 in shadow space
    mov [rbp+030h], r9                                           ; save r9 in shadow space
    push 000000001h                                              ; value of argument #1
    push 000000015h                                              ; type of argument #1
    lea r10, [rbp-018h]                                          ; pointer to return value (and type, 8 bytes earlier)
    push r10                                                     ; (that pointer is the last value pushed to the stack)
    mov qword ptr r9, 0h                                         ; pointer to this
    mov qword ptr r8, 000000000h                                 ; type of this
    mov qword ptr rdx, 0h                                        ; pointer to closure
    mov rcx, 1                                                   ; number of arguments
    sub rsp, 20h                                                 ; allocate shadow space
    call offset func$exit                                        ; jump to subroutine
    add rsp, 038h                                                ; release shadow space and arguments
    mov rcx, [rbp+018h]                                          ; restore rcx from shadow space
    mov rdx, [rbp+020h]                                          ; restore rdx from shadow space
    mov r8, [rbp+028h]                                           ; restore r8 from shadow space
    mov r9, [rbp+030h]                                           ; restore r9 from shadow space
  func$__getLastError$parameterCount$continuation:               ; end of parameter count
  mov [rbp+018h], rcx                                            ; save rcx in shadow space
  mov [rbp+020h], rdx                                            ; save rdx in shadow space
  mov [rbp+028h], r8                                             ; save r8 in shadow space
  mov [rbp+030h], r9                                             ; save r9 in shadow space
  ; Calling GetLastError
  sub rsp, 20h                                                   ; allocate shadow space
  call GetLastError                                              ; error code returned in rax
  add rsp, 20h                                                   ; release shadow space
  mov [r15], rax                                                 ; error code
  mov qword ptr [r15-08h], 000000015h                            ; error code is an integer
  mov rcx, [rbp+018h]                                            ; restore rcx from shadow space
  mov rdx, [rbp+020h]                                            ; restore rdx from shadow space
  mov r8, [rbp+028h]                                             ; restore r8 from shadow space
  mov r9, [rbp+030h]                                             ; restore r9 from shadow space
  func$__getLastError$epilog:
  mov rax, r15                                                   ; report address of return value
  ; Epilog
  add rsp, 020h                                                  ; free space for stack
  pop r15                                                        ; restore non-volatile registers
  pop rbp                                                        ; restore non-volatile registers
  ret                                                            ; return from subroutine

; __readFromAddress
func$__readFromAddress:
  ; Prolog
  push rbp                                                       ; save non-volatile registers
  push r15                                                       ; save non-volatile registers
  sub rsp, 040h                                                  ; allocate space for stack
  lea rbp, [rsp+040h]                                            ; set up frame pointer
  mov r15, [rbp+038h]                                            ; prepare return value
  ; Check parameter count
  cmp qword ptr rcx, 000000001h                                  ; compare parameter count to integers
  je func$__readFromAddress$parameterCount$continuation          ; check number of parameters is as expected
    ; Error handling block for parameter count
    ;  - print(parameterCountCheckFailureMessage)
    mov [rbp+018h], rcx                                          ; save rcx in shadow space
    mov [rbp+020h], rdx                                          ; save rdx in shadow space
    mov [rbp+028h], r8                                           ; save r8 in shadow space
    mov [rbp+030h], r9                                           ; save r9 in shadow space
    mov r11, offset parameterCountCheckFailureMessage            ; value of argument #1
    push r11                                                     ; (indirect via r11 because "parameterCountCheckFailureMessage" is an imm64)
    push 000000016h                                              ; type of argument #1
    lea r10, [rbp-008h]                                          ; pointer to return value (and type, 8 bytes earlier)
    push r10                                                     ; (that pointer is the last value pushed to the stack)
    mov qword ptr r9, 0h                                         ; pointer to this
    mov qword ptr r8, 000000000h                                 ; type of this
    mov qword ptr rdx, 0h                                        ; pointer to closure
    mov rcx, 1                                                   ; number of arguments
    sub rsp, 20h                                                 ; allocate shadow space
    call offset func$__print                                     ; jump to subroutine
    add rsp, 038h                                                ; release shadow space and arguments
    mov rcx, [rbp+018h]                                          ; restore rcx from shadow space
    mov rdx, [rbp+020h]                                          ; restore rdx from shadow space
    mov r8, [rbp+028h]                                           ; restore r8 from shadow space
    mov r9, [rbp+030h]                                           ; restore r9 from shadow space
    ;  - exit(1)
    mov [rbp+018h], rcx                                          ; save rcx in shadow space
    mov [rbp+020h], rdx                                          ; save rdx in shadow space
    mov [rbp+028h], r8                                           ; save r8 in shadow space
    mov [rbp+030h], r9                                           ; save r9 in shadow space
    push 000000001h                                              ; value of argument #1
    push 000000015h                                              ; type of argument #1
    lea r10, [rbp-018h]                                          ; pointer to return value (and type, 8 bytes earlier)
    push r10                                                     ; (that pointer is the last value pushed to the stack)
    mov qword ptr r9, 0h                                         ; pointer to this
    mov qword ptr r8, 000000000h                                 ; type of this
    mov qword ptr rdx, 0h                                        ; pointer to closure
    mov rcx, 1                                                   ; number of arguments
    sub rsp, 20h                                                 ; allocate shadow space
    call offset func$exit                                        ; jump to subroutine
    add rsp, 038h                                                ; release shadow space and arguments
    mov rcx, [rbp+018h]                                          ; restore rcx from shadow space
    mov rdx, [rbp+020h]                                          ; restore rdx from shadow space
    mov r8, [rbp+028h]                                           ; restore r8 from shadow space
    mov r9, [rbp+030h]                                           ; restore r9 from shadow space
  func$__readFromAddress$parameterCount$continuation:            ; end of parameter count
  ; Check type of parameter 0, address (expecting Integer)
  mov rax, [rbp+040h]                                            ; load the dynamic type of address into rax
  lea r10, typeTable                                             ; move type table offset into r10
  add rax, r10                                                   ; adjust rax to point to the type table
  bt qword ptr [rax], 2                                          ; check that address is Integer'21
  jc func$__readFromAddress$address$TypeMatch                    ; skip next block if the type matches
    ; Error handling block for address
    ;  - print(parameterTypeCheckFailureMessage)
    mov [rbp+018h], rcx                                          ; save rcx in shadow space
    mov [rbp+020h], rdx                                          ; save rdx in shadow space
    mov [rbp+028h], r8                                           ; save r8 in shadow space
    mov [rbp+030h], r9                                           ; save r9 in shadow space
    mov r11, offset parameterTypeCheckFailureMessage             ; value of argument #1
    push r11                                                     ; (indirect via r11 because "parameterTypeCheckFailureMessage" is an imm64)
    push 000000016h                                              ; type of argument #1
    lea r10, [rbp-028h]                                          ; pointer to return value (and type, 8 bytes earlier)
    push r10                                                     ; (that pointer is the last value pushed to the stack)
    mov qword ptr r9, 0h                                         ; pointer to this
    mov qword ptr r8, 000000000h                                 ; type of this
    mov qword ptr rdx, 0h                                        ; pointer to closure
    mov rcx, 1                                                   ; number of arguments
    sub rsp, 20h                                                 ; allocate shadow space
    call offset func$__print                                     ; jump to subroutine
    add rsp, 038h                                                ; release shadow space and arguments
    mov rcx, [rbp+018h]                                          ; restore rcx from shadow space
    mov rdx, [rbp+020h]                                          ; restore rdx from shadow space
    mov r8, [rbp+028h]                                           ; restore r8 from shadow space
    mov r9, [rbp+030h]                                           ; restore r9 from shadow space
    ;  - exit(1)
    mov [rbp+018h], rcx                                          ; save rcx in shadow space
    mov [rbp+020h], rdx                                          ; save rdx in shadow space
    mov [rbp+028h], r8                                           ; save r8 in shadow space
    mov [rbp+030h], r9                                           ; save r9 in shadow space
    push 000000001h                                              ; value of argument #1
    push 000000015h                                              ; type of argument #1
    lea r10, [rbp-038h]                                          ; pointer to return value (and type, 8 bytes earlier)
    push r10                                                     ; (that pointer is the last value pushed to the stack)
    mov qword ptr r9, 0h                                         ; pointer to this
    mov qword ptr r8, 000000000h                                 ; type of this
    mov qword ptr rdx, 0h                                        ; pointer to closure
    mov rcx, 1                                                   ; number of arguments
    sub rsp, 20h                                                 ; allocate shadow space
    call offset func$exit                                        ; jump to subroutine
    add rsp, 038h                                                ; release shadow space and arguments
    mov rcx, [rbp+018h]                                          ; restore rcx from shadow space
    mov rdx, [rbp+020h]                                          ; restore rdx from shadow space
    mov r8, [rbp+028h]                                           ; restore r8 from shadow space
    mov r9, [rbp+030h]                                           ; restore r9 from shadow space
  func$__readFromAddress$address$TypeMatch:
  func$__readFromAddress$epilog:
  mov rax, r15                                                   ; report address of return value
  ; Epilog
  add rsp, 040h                                                  ; free space for stack
  pop r15                                                        ; restore non-volatile registers
  pop rbp                                                        ; restore non-volatile registers
  ret                                                            ; return from subroutine

; __writeToAddress
func$__writeToAddress:
  ; Prolog
  push rbp                                                       ; save non-volatile registers
  push r15                                                       ; save non-volatile registers
  sub rsp, 060h                                                  ; allocate space for stack
  lea rbp, [rsp+060h]                                            ; set up frame pointer
  mov r15, [rbp+038h]                                            ; prepare return value
  ; Check parameter count
  cmp qword ptr rcx, 000000002h                                  ; compare parameter count to integers
  je func$__writeToAddress$parameterCount$continuation           ; check number of parameters is as expected
    ; Error handling block for parameter count
    ;  - print(parameterCountCheckFailureMessage)
    mov [rbp+018h], rcx                                          ; save rcx in shadow space
    mov [rbp+020h], rdx                                          ; save rdx in shadow space
    mov [rbp+028h], r8                                           ; save r8 in shadow space
    mov [rbp+030h], r9                                           ; save r9 in shadow space
    mov r11, offset parameterCountCheckFailureMessage            ; value of argument #1
    push r11                                                     ; (indirect via r11 because "parameterCountCheckFailureMessage" is an imm64)
    push 000000016h                                              ; type of argument #1
    lea r10, [rbp-008h]                                          ; pointer to return value (and type, 8 bytes earlier)
    push r10                                                     ; (that pointer is the last value pushed to the stack)
    mov qword ptr r9, 0h                                         ; pointer to this
    mov qword ptr r8, 000000000h                                 ; type of this
    mov qword ptr rdx, 0h                                        ; pointer to closure
    mov rcx, 1                                                   ; number of arguments
    sub rsp, 20h                                                 ; allocate shadow space
    call offset func$__print                                     ; jump to subroutine
    add rsp, 038h                                                ; release shadow space and arguments
    mov rcx, [rbp+018h]                                          ; restore rcx from shadow space
    mov rdx, [rbp+020h]                                          ; restore rdx from shadow space
    mov r8, [rbp+028h]                                           ; restore r8 from shadow space
    mov r9, [rbp+030h]                                           ; restore r9 from shadow space
    ;  - exit(1)
    mov [rbp+018h], rcx                                          ; save rcx in shadow space
    mov [rbp+020h], rdx                                          ; save rdx in shadow space
    mov [rbp+028h], r8                                           ; save r8 in shadow space
    mov [rbp+030h], r9                                           ; save r9 in shadow space
    push 000000001h                                              ; value of argument #1
    push 000000015h                                              ; type of argument #1
    lea r10, [rbp-018h]                                          ; pointer to return value (and type, 8 bytes earlier)
    push r10                                                     ; (that pointer is the last value pushed to the stack)
    mov qword ptr r9, 0h                                         ; pointer to this
    mov qword ptr r8, 000000000h                                 ; type of this
    mov qword ptr rdx, 0h                                        ; pointer to closure
    mov rcx, 1                                                   ; number of arguments
    sub rsp, 20h                                                 ; allocate shadow space
    call offset func$exit                                        ; jump to subroutine
    add rsp, 038h                                                ; release shadow space and arguments
    mov rcx, [rbp+018h]                                          ; restore rcx from shadow space
    mov rdx, [rbp+020h]                                          ; restore rdx from shadow space
    mov r8, [rbp+028h]                                           ; restore r8 from shadow space
    mov r9, [rbp+030h]                                           ; restore r9 from shadow space
  func$__writeToAddress$parameterCount$continuation:             ; end of parameter count
  ; Check type of parameter 0, address (expecting Integer)
  mov rax, [rbp+040h]                                            ; load the dynamic type of address into rax
  lea r10, typeTable                                             ; move type table offset into r10
  add rax, r10                                                   ; adjust rax to point to the type table
  bt qword ptr [rax], 2                                          ; check that address is Integer'21
  jc func$__writeToAddress$address$TypeMatch                     ; skip next block if the type matches
    ; Error handling block for address
    ;  - print(parameterTypeCheckFailureMessage)
    mov [rbp+018h], rcx                                          ; save rcx in shadow space
    mov [rbp+020h], rdx                                          ; save rdx in shadow space
    mov [rbp+028h], r8                                           ; save r8 in shadow space
    mov [rbp+030h], r9                                           ; save r9 in shadow space
    mov r11, offset parameterTypeCheckFailureMessage             ; value of argument #1
    push r11                                                     ; (indirect via r11 because "parameterTypeCheckFailureMessage" is an imm64)
    push 000000016h                                              ; type of argument #1
    lea r10, [rbp-028h]                                          ; pointer to return value (and type, 8 bytes earlier)
    push r10                                                     ; (that pointer is the last value pushed to the stack)
    mov qword ptr r9, 0h                                         ; pointer to this
    mov qword ptr r8, 000000000h                                 ; type of this
    mov qword ptr rdx, 0h                                        ; pointer to closure
    mov rcx, 1                                                   ; number of arguments
    sub rsp, 20h                                                 ; allocate shadow space
    call offset func$__print                                     ; jump to subroutine
    add rsp, 038h                                                ; release shadow space and arguments
    mov rcx, [rbp+018h]                                          ; restore rcx from shadow space
    mov rdx, [rbp+020h]                                          ; restore rdx from shadow space
    mov r8, [rbp+028h]                                           ; restore r8 from shadow space
    mov r9, [rbp+030h]                                           ; restore r9 from shadow space
    ;  - exit(1)
    mov [rbp+018h], rcx                                          ; save rcx in shadow space
    mov [rbp+020h], rdx                                          ; save rdx in shadow space
    mov [rbp+028h], r8                                           ; save r8 in shadow space
    mov [rbp+030h], r9                                           ; save r9 in shadow space
    push 000000001h                                              ; value of argument #1
    push 000000015h                                              ; type of argument #1
    lea r10, [rbp-038h]                                          ; pointer to return value (and type, 8 bytes earlier)
    push r10                                                     ; (that pointer is the last value pushed to the stack)
    mov qword ptr r9, 0h                                         ; pointer to this
    mov qword ptr r8, 000000000h                                 ; type of this
    mov qword ptr rdx, 0h                                        ; pointer to closure
    mov rcx, 1                                                   ; number of arguments
    sub rsp, 20h                                                 ; allocate shadow space
    call offset func$exit                                        ; jump to subroutine
    add rsp, 038h                                                ; release shadow space and arguments
    mov rcx, [rbp+018h]                                          ; restore rcx from shadow space
    mov rdx, [rbp+020h]                                          ; restore rdx from shadow space
    mov r8, [rbp+028h]                                           ; restore r8 from shadow space
    mov r9, [rbp+030h]                                           ; restore r9 from shadow space
  func$__writeToAddress$address$TypeMatch:
  ; Check type of parameter 1, value (expecting Integer)
  mov rax, [rbp+050h]                                            ; load the dynamic type of value into rax
  lea r10, typeTable                                             ; move type table offset into r10
  add rax, r10                                                   ; adjust rax to point to the type table
  bt qword ptr [rax], 2                                          ; check that value is Integer'21
  jc func$__writeToAddress$value$TypeMatch                       ; skip next block if the type matches
    ; Error handling block for value
    ;  - print(parameterTypeCheckFailureMessage)
    mov [rbp+018h], rcx                                          ; save rcx in shadow space
    mov [rbp+020h], rdx                                          ; save rdx in shadow space
    mov [rbp+028h], r8                                           ; save r8 in shadow space
    mov [rbp+030h], r9                                           ; save r9 in shadow space
    mov r11, offset parameterTypeCheckFailureMessage             ; value of argument #1
    push r11                                                     ; (indirect via r11 because "parameterTypeCheckFailureMessage" is an imm64)
    push 000000016h                                              ; type of argument #1
    lea r10, [rbp-048h]                                          ; pointer to return value (and type, 8 bytes earlier)
    push r10                                                     ; (that pointer is the last value pushed to the stack)
    mov qword ptr r9, 0h                                         ; pointer to this
    mov qword ptr r8, 000000000h                                 ; type of this
    mov qword ptr rdx, 0h                                        ; pointer to closure
    mov rcx, 1                                                   ; number of arguments
    sub rsp, 20h                                                 ; allocate shadow space
    call offset func$__print                                     ; jump to subroutine
    add rsp, 038h                                                ; release shadow space and arguments
    mov rcx, [rbp+018h]                                          ; restore rcx from shadow space
    mov rdx, [rbp+020h]                                          ; restore rdx from shadow space
    mov r8, [rbp+028h]                                           ; restore r8 from shadow space
    mov r9, [rbp+030h]                                           ; restore r9 from shadow space
    ;  - exit(1)
    mov [rbp+018h], rcx                                          ; save rcx in shadow space
    mov [rbp+020h], rdx                                          ; save rdx in shadow space
    mov [rbp+028h], r8                                           ; save r8 in shadow space
    mov [rbp+030h], r9                                           ; save r9 in shadow space
    push 000000001h                                              ; value of argument #1
    push 000000015h                                              ; type of argument #1
    lea r10, [rbp-058h]                                          ; pointer to return value (and type, 8 bytes earlier)
    push r10                                                     ; (that pointer is the last value pushed to the stack)
    mov qword ptr r9, 0h                                         ; pointer to this
    mov qword ptr r8, 000000000h                                 ; type of this
    mov qword ptr rdx, 0h                                        ; pointer to closure
    mov rcx, 1                                                   ; number of arguments
    sub rsp, 20h                                                 ; allocate shadow space
    call offset func$exit                                        ; jump to subroutine
    add rsp, 038h                                                ; release shadow space and arguments
    mov rcx, [rbp+018h]                                          ; restore rcx from shadow space
    mov rdx, [rbp+020h]                                          ; restore rdx from shadow space
    mov r8, [rbp+028h]                                           ; restore r8 from shadow space
    mov r9, [rbp+030h]                                           ; restore r9 from shadow space
  func$__writeToAddress$value$TypeMatch:
  func$__writeToAddress$epilog:
  mov rax, r15                                                   ; report address of return value
  ; Epilog
  add rsp, 060h                                                  ; free space for stack
  pop r15                                                        ; restore non-volatile registers
  pop rbp                                                        ; restore non-volatile registers
  ret                                                            ; return from subroutine

; assert
func$assert:
  ; Prolog
  push rbp                                                       ; save non-volatile registers
  push r15                                                       ; save non-volatile registers
  sub rsp, 0c0h                                                  ; allocate space for stack
  lea rbp, [rsp+0c0h]                                            ; set up frame pointer
  mov r15, [rbp+038h]                                            ; prepare return value
  ; Check parameter count
  cmp qword ptr rcx, 000000002h                                  ; compare parameter count to integers
  je func$assert$parameterCount$continuation                     ; check number of parameters is as expected
    ; Error handling block for parameter count
    ;  - print(parameterCountCheckFailureMessage)
    mov [rbp+018h], rcx                                          ; save rcx in shadow space
    mov [rbp+020h], rdx                                          ; save rdx in shadow space
    mov [rbp+028h], r8                                           ; save r8 in shadow space
    mov [rbp+030h], r9                                           ; save r9 in shadow space
    mov r11, offset parameterCountCheckFailureMessage            ; value of argument #1
    push r11                                                     ; (indirect via r11 because "parameterCountCheckFailureMessage" is an imm64)
    push 000000016h                                              ; type of argument #1
    lea r10, [rbp-008h]                                          ; pointer to return value (and type, 8 bytes earlier)
    push r10                                                     ; (that pointer is the last value pushed to the stack)
    mov qword ptr r9, 0h                                         ; pointer to this
    mov qword ptr r8, 000000000h                                 ; type of this
    mov qword ptr rdx, 0h                                        ; pointer to closure
    mov rcx, 1                                                   ; number of arguments
    sub rsp, 20h                                                 ; allocate shadow space
    call offset func$__print                                     ; jump to subroutine
    add rsp, 038h                                                ; release shadow space and arguments
    mov rcx, [rbp+018h]                                          ; restore rcx from shadow space
    mov rdx, [rbp+020h]                                          ; restore rdx from shadow space
    mov r8, [rbp+028h]                                           ; restore r8 from shadow space
    mov r9, [rbp+030h]                                           ; restore r9 from shadow space
    ;  - exit(1)
    mov [rbp+018h], rcx                                          ; save rcx in shadow space
    mov [rbp+020h], rdx                                          ; save rdx in shadow space
    mov [rbp+028h], r8                                           ; save r8 in shadow space
    mov [rbp+030h], r9                                           ; save r9 in shadow space
    push 000000001h                                              ; value of argument #1
    push 000000015h                                              ; type of argument #1
    lea r10, [rbp-018h]                                          ; pointer to return value (and type, 8 bytes earlier)
    push r10                                                     ; (that pointer is the last value pushed to the stack)
    mov qword ptr r9, 0h                                         ; pointer to this
    mov qword ptr r8, 000000000h                                 ; type of this
    mov qword ptr rdx, 0h                                        ; pointer to closure
    mov rcx, 1                                                   ; number of arguments
    sub rsp, 20h                                                 ; allocate shadow space
    call offset func$exit                                        ; jump to subroutine
    add rsp, 038h                                                ; release shadow space and arguments
    mov rcx, [rbp+018h]                                          ; restore rcx from shadow space
    mov rdx, [rbp+020h]                                          ; restore rdx from shadow space
    mov r8, [rbp+028h]                                           ; restore r8 from shadow space
    mov r9, [rbp+030h]                                           ; restore r9 from shadow space
  func$assert$parameterCount$continuation:                       ; end of parameter count
  ; Check type of parameter 0, condition (expecting Boolean)
  mov rax, [rbp+040h]                                            ; load the dynamic type of condition into rax
  lea r10, typeTable                                             ; move type table offset into r10
  add rax, r10                                                   ; adjust rax to point to the type table
  bt qword ptr [rax], 1                                          ; check that condition is Boolean'20
  jc func$assert$condition$TypeMatch                             ; skip next block if the type matches
    ; Error handling block for condition
    ;  - print(parameterTypeCheckFailureMessage)
    mov [rbp+018h], rcx                                          ; save rcx in shadow space
    mov [rbp+020h], rdx                                          ; save rdx in shadow space
    mov [rbp+028h], r8                                           ; save r8 in shadow space
    mov [rbp+030h], r9                                           ; save r9 in shadow space
    mov r11, offset parameterTypeCheckFailureMessage             ; value of argument #1
    push r11                                                     ; (indirect via r11 because "parameterTypeCheckFailureMessage" is an imm64)
    push 000000016h                                              ; type of argument #1
    lea r10, [rbp-028h]                                          ; pointer to return value (and type, 8 bytes earlier)
    push r10                                                     ; (that pointer is the last value pushed to the stack)
    mov qword ptr r9, 0h                                         ; pointer to this
    mov qword ptr r8, 000000000h                                 ; type of this
    mov qword ptr rdx, 0h                                        ; pointer to closure
    mov rcx, 1                                                   ; number of arguments
    sub rsp, 20h                                                 ; allocate shadow space
    call offset func$__print                                     ; jump to subroutine
    add rsp, 038h                                                ; release shadow space and arguments
    mov rcx, [rbp+018h]                                          ; restore rcx from shadow space
    mov rdx, [rbp+020h]                                          ; restore rdx from shadow space
    mov r8, [rbp+028h]                                           ; restore r8 from shadow space
    mov r9, [rbp+030h]                                           ; restore r9 from shadow space
    ;  - exit(1)
    mov [rbp+018h], rcx                                          ; save rcx in shadow space
    mov [rbp+020h], rdx                                          ; save rdx in shadow space
    mov [rbp+028h], r8                                           ; save r8 in shadow space
    mov [rbp+030h], r9                                           ; save r9 in shadow space
    push 000000001h                                              ; value of argument #1
    push 000000015h                                              ; type of argument #1
    lea r10, [rbp-038h]                                          ; pointer to return value (and type, 8 bytes earlier)
    push r10                                                     ; (that pointer is the last value pushed to the stack)
    mov qword ptr r9, 0h                                         ; pointer to this
    mov qword ptr r8, 000000000h                                 ; type of this
    mov qword ptr rdx, 0h                                        ; pointer to closure
    mov rcx, 1                                                   ; number of arguments
    sub rsp, 20h                                                 ; allocate shadow space
    call offset func$exit                                        ; jump to subroutine
    add rsp, 038h                                                ; release shadow space and arguments
    mov rcx, [rbp+018h]                                          ; restore rcx from shadow space
    mov rdx, [rbp+020h]                                          ; restore rdx from shadow space
    mov r8, [rbp+028h]                                           ; restore r8 from shadow space
    mov r9, [rbp+030h]                                           ; restore r9 from shadow space
  func$assert$condition$TypeMatch:
  ; Check type of parameter 1, message (expecting String)
  mov rax, [rbp+050h]                                            ; load the dynamic type of message into rax
  lea r10, typeTable                                             ; move type table offset into r10
  add rax, r10                                                   ; adjust rax to point to the type table
  bt qword ptr [rax], 3                                          ; check that message is String'22
  jc func$assert$message$TypeMatch                               ; skip next block if the type matches
    ; Error handling block for message
    ;  - print(parameterTypeCheckFailureMessage)
    mov [rbp+018h], rcx                                          ; save rcx in shadow space
    mov [rbp+020h], rdx                                          ; save rdx in shadow space
    mov [rbp+028h], r8                                           ; save r8 in shadow space
    mov [rbp+030h], r9                                           ; save r9 in shadow space
    mov r11, offset parameterTypeCheckFailureMessage             ; value of argument #1
    push r11                                                     ; (indirect via r11 because "parameterTypeCheckFailureMessage" is an imm64)
    push 000000016h                                              ; type of argument #1
    lea r10, [rbp-048h]                                          ; pointer to return value (and type, 8 bytes earlier)
    push r10                                                     ; (that pointer is the last value pushed to the stack)
    mov qword ptr r9, 0h                                         ; pointer to this
    mov qword ptr r8, 000000000h                                 ; type of this
    mov qword ptr rdx, 0h                                        ; pointer to closure
    mov rcx, 1                                                   ; number of arguments
    sub rsp, 20h                                                 ; allocate shadow space
    call offset func$__print                                     ; jump to subroutine
    add rsp, 038h                                                ; release shadow space and arguments
    mov rcx, [rbp+018h]                                          ; restore rcx from shadow space
    mov rdx, [rbp+020h]                                          ; restore rdx from shadow space
    mov r8, [rbp+028h]                                           ; restore r8 from shadow space
    mov r9, [rbp+030h]                                           ; restore r9 from shadow space
    ;  - exit(1)
    mov [rbp+018h], rcx                                          ; save rcx in shadow space
    mov [rbp+020h], rdx                                          ; save rdx in shadow space
    mov [rbp+028h], r8                                           ; save r8 in shadow space
    mov [rbp+030h], r9                                           ; save r9 in shadow space
    push 000000001h                                              ; value of argument #1
    push 000000015h                                              ; type of argument #1
    lea r10, [rbp-058h]                                          ; pointer to return value (and type, 8 bytes earlier)
    push r10                                                     ; (that pointer is the last value pushed to the stack)
    mov qword ptr r9, 0h                                         ; pointer to this
    mov qword ptr r8, 000000000h                                 ; type of this
    mov qword ptr rdx, 0h                                        ; pointer to closure
    mov rcx, 1                                                   ; number of arguments
    sub rsp, 20h                                                 ; allocate shadow space
    call offset func$exit                                        ; jump to subroutine
    add rsp, 038h                                                ; release shadow space and arguments
    mov rcx, [rbp+018h]                                          ; restore rcx from shadow space
    mov rdx, [rbp+020h]                                          ; restore rdx from shadow space
    mov r8, [rbp+028h]                                           ; restore r8 from shadow space
    mov r9, [rbp+030h]                                           ; restore r9 from shadow space
  func$assert$message$TypeMatch:
  ; Line 6: if (!condition) { ...
  mov rax, [rbp+040h]                                            ; load the dynamic type of condition into rax
  lea r10, typeTable                                             ; move type table offset into r10
  add rax, r10                                                   ; adjust rax to point to the type table
  bt qword ptr [rax], 1                                          ; check that condition is Boolean'20
  jc func$assert$condition$TypeMatch$1                           ; skip next block if the type matches
    ; Error handling block for condition
    ;  - print(operandTypeCheckFailureMessage)
    mov [rbp+018h], rcx                                          ; save rcx in shadow space
    mov [rbp+020h], rdx                                          ; save rdx in shadow space
    mov [rbp+028h], r8                                           ; save r8 in shadow space
    mov [rbp+030h], r9                                           ; save r9 in shadow space
    mov r11, offset operandTypeCheckFailureMessage               ; value of argument #1
    push r11                                                     ; (indirect via r11 because "operandTypeCheckFailureMessage" is an imm64)
    push 000000016h                                              ; type of argument #1
    lea r10, [rbp-068h]                                          ; pointer to return value (and type, 8 bytes earlier)
    push r10                                                     ; (that pointer is the last value pushed to the stack)
    mov qword ptr r9, 0h                                         ; pointer to this
    mov qword ptr r8, 000000000h                                 ; type of this
    mov qword ptr rdx, 0h                                        ; pointer to closure
    mov rcx, 1                                                   ; number of arguments
    sub rsp, 20h                                                 ; allocate shadow space
    call offset func$__print                                     ; jump to subroutine
    add rsp, 038h                                                ; release shadow space and arguments
    mov rcx, [rbp+018h]                                          ; restore rcx from shadow space
    mov rdx, [rbp+020h]                                          ; restore rdx from shadow space
    mov r8, [rbp+028h]                                           ; restore r8 from shadow space
    mov r9, [rbp+030h]                                           ; restore r9 from shadow space
    ;  - exit(1)
    mov [rbp+018h], rcx                                          ; save rcx in shadow space
    mov [rbp+020h], rdx                                          ; save rdx in shadow space
    mov [rbp+028h], r8                                           ; save r8 in shadow space
    mov [rbp+030h], r9                                           ; save r9 in shadow space
    push 000000001h                                              ; value of argument #1
    push 000000015h                                              ; type of argument #1
    lea r10, [rbp-078h]                                          ; pointer to return value (and type, 8 bytes earlier)
    push r10                                                     ; (that pointer is the last value pushed to the stack)
    mov qword ptr r9, 0h                                         ; pointer to this
    mov qword ptr r8, 000000000h                                 ; type of this
    mov qword ptr rdx, 0h                                        ; pointer to closure
    mov rcx, 1                                                   ; number of arguments
    sub rsp, 20h                                                 ; allocate shadow space
    call offset func$exit                                        ; jump to subroutine
    add rsp, 038h                                                ; release shadow space and arguments
    mov rcx, [rbp+018h]                                          ; restore rcx from shadow space
    mov rdx, [rbp+020h]                                          ; restore rdx from shadow space
    mov r8, [rbp+028h]                                           ; restore r8 from shadow space
    mov r9, [rbp+030h]                                           ; restore r9 from shadow space
  func$assert$condition$TypeMatch$1:
  xor r10, r10                                                   ; zero r10
  mov r11, [rbp+048h]                                            ; compare condition...
  test r11, [rbp+048h]                                           ; ...to condition
  sete byte ptr r10b                                             ; ! unary operator
  mov [rbp-088h], r10                                            ; store result
  mov qword ptr [rbp-090h], 000000014h                           ; store type
  cmp qword ptr [rbp-088h], 000000000h                           ; compare ! unary operator result to false
  je func$assert$if$continuation                                 ; !condition
    ; Line 7: __print(message);
    mov [rbp+018h], rcx                                          ; save rcx in shadow space
    mov [rbp+020h], rdx                                          ; save rdx in shadow space
    mov [rbp+028h], r8                                           ; save r8 in shadow space
    mov [rbp+030h], r9                                           ; save r9 in shadow space
    push [rbp+058h]                                              ; value of argument #1
    push [rbp+050h]                                              ; type of argument #1
    lea r10, [rbp-098h]                                          ; pointer to return value (and type, 8 bytes earlier)
    push r10                                                     ; (that pointer is the last value pushed to the stack)
    mov qword ptr r9, 0h                                         ; pointer to this
    mov qword ptr r8, 000000000h                                 ; type of this
    mov qword ptr rdx, 0h                                        ; pointer to closure
    mov rcx, 1                                                   ; number of arguments
    sub rsp, 20h                                                 ; allocate shadow space
    call offset func$__print                                     ; jump to subroutine
    add rsp, 038h                                                ; release shadow space and arguments
    mov rcx, [rbp+018h]                                          ; restore rcx from shadow space
    mov rdx, [rbp+020h]                                          ; restore rdx from shadow space
    mov r8, [rbp+028h]                                           ; restore r8 from shadow space
    mov r9, [rbp+030h]                                           ; restore r9 from shadow space
    ; Line 8: __print('\n');
    mov [rbp+018h], rcx                                          ; save rcx in shadow space
    mov [rbp+020h], rdx                                          ; save rdx in shadow space
    mov [rbp+028h], r8                                           ; save r8 in shadow space
    mov [rbp+030h], r9                                           ; save r9 in shadow space
    mov r11, offset string                                       ; value of argument #1
    push r11                                                     ; (indirect via r11 because "string" is an imm64)
    push 000000016h                                              ; type of argument #1
    lea r10, [rbp-0a8h]                                          ; pointer to return value (and type, 8 bytes earlier)
    push r10                                                     ; (that pointer is the last value pushed to the stack)
    mov qword ptr r9, 0h                                         ; pointer to this
    mov qword ptr r8, 000000000h                                 ; type of this
    mov qword ptr rdx, 0h                                        ; pointer to closure
    mov rcx, 1                                                   ; number of arguments
    sub rsp, 20h                                                 ; allocate shadow space
    call offset func$__print                                     ; jump to subroutine
    add rsp, 038h                                                ; release shadow space and arguments
    mov rcx, [rbp+018h]                                          ; restore rcx from shadow space
    mov rdx, [rbp+020h]                                          ; restore rdx from shadow space
    mov r8, [rbp+028h]                                           ; restore r8 from shadow space
    mov r9, [rbp+030h]                                           ; restore r9 from shadow space
    ; Line 9: exit(1);
    mov [rbp+018h], rcx                                          ; save rcx in shadow space
    mov [rbp+020h], rdx                                          ; save rdx in shadow space
    mov [rbp+028h], r8                                           ; save r8 in shadow space
    mov [rbp+030h], r9                                           ; save r9 in shadow space
    push 000000001h                                              ; value of argument #1
    push 000000015h                                              ; type of argument #1
    lea r10, [rbp-0b8h]                                          ; pointer to return value (and type, 8 bytes earlier)
    push r10                                                     ; (that pointer is the last value pushed to the stack)
    mov qword ptr r9, 0h                                         ; pointer to this
    mov qword ptr r8, 000000000h                                 ; type of this
    mov qword ptr rdx, 0h                                        ; pointer to closure
    mov rcx, 1                                                   ; number of arguments
    sub rsp, 20h                                                 ; allocate shadow space
    call offset func$exit                                        ; jump to subroutine
    add rsp, 038h                                                ; release shadow space and arguments
    mov rcx, [rbp+018h]                                          ; restore rcx from shadow space
    mov rdx, [rbp+020h]                                          ; restore rdx from shadow space
    mov r8, [rbp+028h]                                           ; restore r8 from shadow space
    mov r9, [rbp+030h]                                           ; restore r9 from shadow space
  func$assert$if$continuation:                                   ; end of if
  func$assert$epilog:
  mov rax, r15                                                   ; report address of return value
  ; Epilog
  add rsp, 0c0h                                                  ; free space for stack
  pop r15                                                        ; restore non-volatile registers
  pop rbp                                                        ; restore non-volatile registers
  ret                                                            ; return from subroutine

; _alloc
func$_alloc:
  ; Prolog
  push rbp                                                       ; save non-volatile registers
  push r15                                                       ; save non-volatile registers
  sub rsp, 070h                                                  ; allocate space for stack
  lea rbp, [rsp+070h]                                            ; set up frame pointer
  mov r15, [rbp+038h]                                            ; prepare return value
  ; Check parameter count
  cmp qword ptr rcx, 000000001h                                  ; compare parameter count to integers
  je func$_alloc$parameterCount$continuation                     ; check number of parameters is as expected
    ; Error handling block for parameter count
    ;  - print(parameterCountCheckFailureMessage)
    mov [rbp+018h], rcx                                          ; save rcx in shadow space
    mov [rbp+020h], rdx                                          ; save rdx in shadow space
    mov [rbp+028h], r8                                           ; save r8 in shadow space
    mov [rbp+030h], r9                                           ; save r9 in shadow space
    mov r11, offset parameterCountCheckFailureMessage            ; value of argument #1
    push r11                                                     ; (indirect via r11 because "parameterCountCheckFailureMessage" is an imm64)
    push 000000016h                                              ; type of argument #1
    lea r10, [rbp-008h]                                          ; pointer to return value (and type, 8 bytes earlier)
    push r10                                                     ; (that pointer is the last value pushed to the stack)
    mov qword ptr r9, 0h                                         ; pointer to this
    mov qword ptr r8, 000000000h                                 ; type of this
    mov qword ptr rdx, 0h                                        ; pointer to closure
    mov rcx, 1                                                   ; number of arguments
    sub rsp, 20h                                                 ; allocate shadow space
    call offset func$__print                                     ; jump to subroutine
    add rsp, 038h                                                ; release shadow space and arguments
    mov rcx, [rbp+018h]                                          ; restore rcx from shadow space
    mov rdx, [rbp+020h]                                          ; restore rdx from shadow space
    mov r8, [rbp+028h]                                           ; restore r8 from shadow space
    mov r9, [rbp+030h]                                           ; restore r9 from shadow space
    ;  - exit(1)
    mov [rbp+018h], rcx                                          ; save rcx in shadow space
    mov [rbp+020h], rdx                                          ; save rdx in shadow space
    mov [rbp+028h], r8                                           ; save r8 in shadow space
    mov [rbp+030h], r9                                           ; save r9 in shadow space
    push 000000001h                                              ; value of argument #1
    push 000000015h                                              ; type of argument #1
    lea r10, [rbp-018h]                                          ; pointer to return value (and type, 8 bytes earlier)
    push r10                                                     ; (that pointer is the last value pushed to the stack)
    mov qword ptr r9, 0h                                         ; pointer to this
    mov qword ptr r8, 000000000h                                 ; type of this
    mov qword ptr rdx, 0h                                        ; pointer to closure
    mov rcx, 1                                                   ; number of arguments
    sub rsp, 20h                                                 ; allocate shadow space
    call offset func$exit                                        ; jump to subroutine
    add rsp, 038h                                                ; release shadow space and arguments
    mov rcx, [rbp+018h]                                          ; restore rcx from shadow space
    mov rdx, [rbp+020h]                                          ; restore rdx from shadow space
    mov r8, [rbp+028h]                                           ; restore r8 from shadow space
    mov r9, [rbp+030h]                                           ; restore r9 from shadow space
  func$_alloc$parameterCount$continuation:                       ; end of parameter count
  ; Check type of parameter 0, size (expecting Integer)
  mov rax, [rbp+040h]                                            ; load the dynamic type of size into rax
  lea r10, typeTable                                             ; move type table offset into r10
  add rax, r10                                                   ; adjust rax to point to the type table
  bt qword ptr [rax], 2                                          ; check that size is Integer'21
  jc func$_alloc$size$TypeMatch                                  ; skip next block if the type matches
    ; Error handling block for size
    ;  - print(parameterTypeCheckFailureMessage)
    mov [rbp+018h], rcx                                          ; save rcx in shadow space
    mov [rbp+020h], rdx                                          ; save rdx in shadow space
    mov [rbp+028h], r8                                           ; save r8 in shadow space
    mov [rbp+030h], r9                                           ; save r9 in shadow space
    mov r11, offset parameterTypeCheckFailureMessage             ; value of argument #1
    push r11                                                     ; (indirect via r11 because "parameterTypeCheckFailureMessage" is an imm64)
    push 000000016h                                              ; type of argument #1
    lea r10, [rbp-028h]                                          ; pointer to return value (and type, 8 bytes earlier)
    push r10                                                     ; (that pointer is the last value pushed to the stack)
    mov qword ptr r9, 0h                                         ; pointer to this
    mov qword ptr r8, 000000000h                                 ; type of this
    mov qword ptr rdx, 0h                                        ; pointer to closure
    mov rcx, 1                                                   ; number of arguments
    sub rsp, 20h                                                 ; allocate shadow space
    call offset func$__print                                     ; jump to subroutine
    add rsp, 038h                                                ; release shadow space and arguments
    mov rcx, [rbp+018h]                                          ; restore rcx from shadow space
    mov rdx, [rbp+020h]                                          ; restore rdx from shadow space
    mov r8, [rbp+028h]                                           ; restore r8 from shadow space
    mov r9, [rbp+030h]                                           ; restore r9 from shadow space
    ;  - exit(1)
    mov [rbp+018h], rcx                                          ; save rcx in shadow space
    mov [rbp+020h], rdx                                          ; save rdx in shadow space
    mov [rbp+028h], r8                                           ; save r8 in shadow space
    mov [rbp+030h], r9                                           ; save r9 in shadow space
    push 000000001h                                              ; value of argument #1
    push 000000015h                                              ; type of argument #1
    lea r10, [rbp-038h]                                          ; pointer to return value (and type, 8 bytes earlier)
    push r10                                                     ; (that pointer is the last value pushed to the stack)
    mov qword ptr r9, 0h                                         ; pointer to this
    mov qword ptr r8, 000000000h                                 ; type of this
    mov qword ptr rdx, 0h                                        ; pointer to closure
    mov rcx, 1                                                   ; number of arguments
    sub rsp, 20h                                                 ; allocate shadow space
    call offset func$exit                                        ; jump to subroutine
    add rsp, 038h                                                ; release shadow space and arguments
    mov rcx, [rbp+018h]                                          ; restore rcx from shadow space
    mov rdx, [rbp+020h]                                          ; restore rdx from shadow space
    mov r8, [rbp+028h]                                           ; restore r8 from shadow space
    mov r9, [rbp+030h]                                           ; restore r9 from shadow space
  func$_alloc$size$TypeMatch:
  ; Line 19: return __heapAlloc(_heapHandle, 0, size);
  mov [rbp+018h], rcx                                            ; save rcx in shadow space
  mov [rbp+020h], rdx                                            ; save rdx in shadow space
  mov [rbp+028h], r8                                             ; save r8 in shadow space
  mov [rbp+030h], r9                                             ; save r9 in shadow space
  push [rbp+048h]                                                ; value of argument #3
  push [rbp+040h]                                                ; type of argument #3
  push 000000000h                                                ; value of argument #2
  push 000000015h                                                ; type of argument #2
  push global0Value                                              ; value of argument #1
  push global0Type                                               ; type of argument #1
  lea r10, [rbp-048h]                                            ; pointer to return value (and type, 8 bytes earlier)
  push r10                                                       ; (that pointer is the last value pushed to the stack)
  mov qword ptr r9, 0h                                           ; pointer to this
  mov qword ptr r8, 000000000h                                   ; type of this
  mov qword ptr rdx, 0h                                          ; pointer to closure
  mov rcx, 3                                                     ; number of arguments
  sub rsp, 20h                                                   ; allocate shadow space
  call offset func$__heapAlloc                                   ; jump to subroutine
  add rsp, 058h                                                  ; release shadow space and arguments
  mov rcx, [rbp+018h]                                            ; restore rcx from shadow space
  mov rdx, [rbp+020h]                                            ; restore rdx from shadow space
  mov r8, [rbp+028h]                                             ; restore r8 from shadow space
  mov r9, [rbp+030h]                                             ; restore r9 from shadow space
  mov rax, [rbp-050h]                                            ; load the dynamic type of return value of _alloc into rax
  lea r10, typeTable                                             ; move type table offset into r10
  add rax, r10                                                   ; adjust rax to point to the type table
  bt qword ptr [rax], 2                                          ; check that return value of _alloc is Integer'21
  jc func$_alloc$returnValueOfAlloc$TypeMatch                    ; skip next block if the type matches
    ; Error handling block for return value of _alloc
    ;  - print(returnValueTypeCheckFailureMessage)
    mov [rbp+018h], rcx                                          ; save rcx in shadow space
    mov [rbp+020h], rdx                                          ; save rdx in shadow space
    mov [rbp+028h], r8                                           ; save r8 in shadow space
    mov [rbp+030h], r9                                           ; save r9 in shadow space
    mov r11, offset returnValueTypeCheckFailureMessage           ; value of argument #1
    push r11                                                     ; (indirect via r11 because "returnValueTypeCheckFailureMessage" is an imm64)
    push 000000016h                                              ; type of argument #1
    lea r10, [rbp-058h]                                          ; pointer to return value (and type, 8 bytes earlier)
    push r10                                                     ; (that pointer is the last value pushed to the stack)
    mov qword ptr r9, 0h                                         ; pointer to this
    mov qword ptr r8, 000000000h                                 ; type of this
    mov qword ptr rdx, 0h                                        ; pointer to closure
    mov rcx, 1                                                   ; number of arguments
    sub rsp, 20h                                                 ; allocate shadow space
    call offset func$__print                                     ; jump to subroutine
    add rsp, 038h                                                ; release shadow space and arguments
    mov rcx, [rbp+018h]                                          ; restore rcx from shadow space
    mov rdx, [rbp+020h]                                          ; restore rdx from shadow space
    mov r8, [rbp+028h]                                           ; restore r8 from shadow space
    mov r9, [rbp+030h]                                           ; restore r9 from shadow space
    ;  - exit(1)
    mov [rbp+018h], rcx                                          ; save rcx in shadow space
    mov [rbp+020h], rdx                                          ; save rdx in shadow space
    mov [rbp+028h], r8                                           ; save r8 in shadow space
    mov [rbp+030h], r9                                           ; save r9 in shadow space
    push 000000001h                                              ; value of argument #1
    push 000000015h                                              ; type of argument #1
    lea r10, [rbp-068h]                                          ; pointer to return value (and type, 8 bytes earlier)
    push r10                                                     ; (that pointer is the last value pushed to the stack)
    mov qword ptr r9, 0h                                         ; pointer to this
    mov qword ptr r8, 000000000h                                 ; type of this
    mov qword ptr rdx, 0h                                        ; pointer to closure
    mov rcx, 1                                                   ; number of arguments
    sub rsp, 20h                                                 ; allocate shadow space
    call offset func$exit                                        ; jump to subroutine
    add rsp, 038h                                                ; release shadow space and arguments
    mov rcx, [rbp+018h]                                          ; restore rcx from shadow space
    mov rdx, [rbp+020h]                                          ; restore rdx from shadow space
    mov r8, [rbp+028h]                                           ; restore r8 from shadow space
    mov r9, [rbp+030h]                                           ; restore r9 from shadow space
  func$_alloc$returnValueOfAlloc$TypeMatch:
  mov r11, [rbp-048h]                                            ; value of return value
  mov [r15], r11                                                 ; (indirect via r11 because mov can't do memory-to-memory)
  mov r11, [rbp-050h]                                            ; type of return value
  mov [r15-08h], r11                                             ; (indirect via r11 because mov can't do memory-to-memory)
  jmp func$_alloc$epilog                                         ; return
  func$_alloc$epilog:
  mov rax, r15                                                   ; report address of return value
  ; Epilog
  add rsp, 070h                                                  ; free space for stack
  pop r15                                                        ; restore non-volatile registers
  pop rbp                                                        ; restore non-volatile registers
  ret                                                            ; return from subroutine

; _stringByteLength
func$_stringByteLength:
  ; Prolog
  push rbp                                                       ; save non-volatile registers
  push r15                                                       ; save non-volatile registers
  sub rsp, 0e0h                                                  ; allocate space for stack
  lea rbp, [rsp+0e0h]                                            ; set up frame pointer
  mov r15, [rbp+038h]                                            ; prepare return value
  ; Check parameter count
  cmp qword ptr rcx, 000000001h                                  ; compare parameter count to integers
  je func$_stringByteLength$parameterCount$continuation          ; check number of parameters is as expected
    ; Error handling block for parameter count
    ;  - print(parameterCountCheckFailureMessage)
    mov [rbp+018h], rcx                                          ; save rcx in shadow space
    mov [rbp+020h], rdx                                          ; save rdx in shadow space
    mov [rbp+028h], r8                                           ; save r8 in shadow space
    mov [rbp+030h], r9                                           ; save r9 in shadow space
    mov r11, offset parameterCountCheckFailureMessage            ; value of argument #1
    push r11                                                     ; (indirect via r11 because "parameterCountCheckFailureMessage" is an imm64)
    push 000000016h                                              ; type of argument #1
    lea r10, [rbp-008h]                                          ; pointer to return value (and type, 8 bytes earlier)
    push r10                                                     ; (that pointer is the last value pushed to the stack)
    mov qword ptr r9, 0h                                         ; pointer to this
    mov qword ptr r8, 000000000h                                 ; type of this
    mov qword ptr rdx, 0h                                        ; pointer to closure
    mov rcx, 1                                                   ; number of arguments
    sub rsp, 20h                                                 ; allocate shadow space
    call offset func$__print                                     ; jump to subroutine
    add rsp, 038h                                                ; release shadow space and arguments
    mov rcx, [rbp+018h]                                          ; restore rcx from shadow space
    mov rdx, [rbp+020h]                                          ; restore rdx from shadow space
    mov r8, [rbp+028h]                                           ; restore r8 from shadow space
    mov r9, [rbp+030h]                                           ; restore r9 from shadow space
    ;  - exit(1)
    mov [rbp+018h], rcx                                          ; save rcx in shadow space
    mov [rbp+020h], rdx                                          ; save rdx in shadow space
    mov [rbp+028h], r8                                           ; save r8 in shadow space
    mov [rbp+030h], r9                                           ; save r9 in shadow space
    push 000000001h                                              ; value of argument #1
    push 000000015h                                              ; type of argument #1
    lea r10, [rbp-018h]                                          ; pointer to return value (and type, 8 bytes earlier)
    push r10                                                     ; (that pointer is the last value pushed to the stack)
    mov qword ptr r9, 0h                                         ; pointer to this
    mov qword ptr r8, 000000000h                                 ; type of this
    mov qword ptr rdx, 0h                                        ; pointer to closure
    mov rcx, 1                                                   ; number of arguments
    sub rsp, 20h                                                 ; allocate shadow space
    call offset func$exit                                        ; jump to subroutine
    add rsp, 038h                                                ; release shadow space and arguments
    mov rcx, [rbp+018h]                                          ; restore rcx from shadow space
    mov rdx, [rbp+020h]                                          ; restore rdx from shadow space
    mov r8, [rbp+028h]                                           ; restore r8 from shadow space
    mov r9, [rbp+030h]                                           ; restore r9 from shadow space
  func$_stringByteLength$parameterCount$continuation:            ; end of parameter count
  ; Check type of parameter 0, data (expecting String)
  mov rax, [rbp+040h]                                            ; load the dynamic type of data into rax
  lea r10, typeTable                                             ; move type table offset into r10
  add rax, r10                                                   ; adjust rax to point to the type table
  bt qword ptr [rax], 3                                          ; check that data is String'22
  jc func$_stringByteLength$data$TypeMatch                       ; skip next block if the type matches
    ; Error handling block for data
    ;  - print(parameterTypeCheckFailureMessage)
    mov [rbp+018h], rcx                                          ; save rcx in shadow space
    mov [rbp+020h], rdx                                          ; save rdx in shadow space
    mov [rbp+028h], r8                                           ; save r8 in shadow space
    mov [rbp+030h], r9                                           ; save r9 in shadow space
    mov r11, offset parameterTypeCheckFailureMessage             ; value of argument #1
    push r11                                                     ; (indirect via r11 because "parameterTypeCheckFailureMessage" is an imm64)
    push 000000016h                                              ; type of argument #1
    lea r10, [rbp-028h]                                          ; pointer to return value (and type, 8 bytes earlier)
    push r10                                                     ; (that pointer is the last value pushed to the stack)
    mov qword ptr r9, 0h                                         ; pointer to this
    mov qword ptr r8, 000000000h                                 ; type of this
    mov qword ptr rdx, 0h                                        ; pointer to closure
    mov rcx, 1                                                   ; number of arguments
    sub rsp, 20h                                                 ; allocate shadow space
    call offset func$__print                                     ; jump to subroutine
    add rsp, 038h                                                ; release shadow space and arguments
    mov rcx, [rbp+018h]                                          ; restore rcx from shadow space
    mov rdx, [rbp+020h]                                          ; restore rdx from shadow space
    mov r8, [rbp+028h]                                           ; restore r8 from shadow space
    mov r9, [rbp+030h]                                           ; restore r9 from shadow space
    ;  - exit(1)
    mov [rbp+018h], rcx                                          ; save rcx in shadow space
    mov [rbp+020h], rdx                                          ; save rdx in shadow space
    mov [rbp+028h], r8                                           ; save r8 in shadow space
    mov [rbp+030h], r9                                           ; save r9 in shadow space
    push 000000001h                                              ; value of argument #1
    push 000000015h                                              ; type of argument #1
    lea r10, [rbp-038h]                                          ; pointer to return value (and type, 8 bytes earlier)
    push r10                                                     ; (that pointer is the last value pushed to the stack)
    mov qword ptr r9, 0h                                         ; pointer to this
    mov qword ptr r8, 000000000h                                 ; type of this
    mov qword ptr rdx, 0h                                        ; pointer to closure
    mov rcx, 1                                                   ; number of arguments
    sub rsp, 20h                                                 ; allocate shadow space
    call offset func$exit                                        ; jump to subroutine
    add rsp, 038h                                                ; release shadow space and arguments
    mov rcx, [rbp+018h]                                          ; restore rcx from shadow space
    mov rdx, [rbp+020h]                                          ; restore rdx from shadow space
    mov r8, [rbp+028h]                                           ; restore r8 from shadow space
    mov r9, [rbp+030h]                                           ; restore r9 from shadow space
  func$_stringByteLength$data$TypeMatch:
  ; Line 23: Integer pointer = data __as__ Integer;
  mov r11, [rbp+048h]                                            ; value of force cast of data to Integer
  mov [rbp-048h], r11                                            ; (indirect via r11 because mov can't do memory-to-memory)
  mov qword ptr [rbp-050h], 000000015h                           ; new type of force cast of data to Integer
  mov r11, [rbp-048h]                                            ; value of pointer
  mov [rbp-058h], r11                                            ; (indirect via r11 because mov can't do memory-to-memory)
  mov r11, [rbp-050h]                                            ; type of pointer
  mov [rbp-060h], r11                                            ; (indirect via r11 because mov can't do memory-to-memory)
  ; Line 24: return __readFromAddress(pointer + 8);
  mov rax, [rbp-060h]                                            ; load the dynamic type of pointer into rax
  lea r10, typeTable                                             ; move type table offset into r10
  add rax, r10                                                   ; adjust rax to point to the type table
  bt qword ptr [rax], 2                                          ; check that pointer is Integer'21
  jc func$_stringByteLength$pointer$TypeMatch                    ; skip next block if the type matches
    ; Error handling block for pointer
    ;  - print(operandTypeCheckFailureMessage)
    mov [rbp+018h], rcx                                          ; save rcx in shadow space
    mov [rbp+020h], rdx                                          ; save rdx in shadow space
    mov [rbp+028h], r8                                           ; save r8 in shadow space
    mov [rbp+030h], r9                                           ; save r9 in shadow space
    mov r11, offset operandTypeCheckFailureMessage               ; value of argument #1
    push r11                                                     ; (indirect via r11 because "operandTypeCheckFailureMessage" is an imm64)
    push 000000016h                                              ; type of argument #1
    lea r10, [rbp-068h]                                          ; pointer to return value (and type, 8 bytes earlier)
    push r10                                                     ; (that pointer is the last value pushed to the stack)
    mov qword ptr r9, 0h                                         ; pointer to this
    mov qword ptr r8, 000000000h                                 ; type of this
    mov qword ptr rdx, 0h                                        ; pointer to closure
    mov rcx, 1                                                   ; number of arguments
    sub rsp, 20h                                                 ; allocate shadow space
    call offset func$__print                                     ; jump to subroutine
    add rsp, 038h                                                ; release shadow space and arguments
    mov rcx, [rbp+018h]                                          ; restore rcx from shadow space
    mov rdx, [rbp+020h]                                          ; restore rdx from shadow space
    mov r8, [rbp+028h]                                           ; restore r8 from shadow space
    mov r9, [rbp+030h]                                           ; restore r9 from shadow space
    ;  - exit(1)
    mov [rbp+018h], rcx                                          ; save rcx in shadow space
    mov [rbp+020h], rdx                                          ; save rdx in shadow space
    mov [rbp+028h], r8                                           ; save r8 in shadow space
    mov [rbp+030h], r9                                           ; save r9 in shadow space
    push 000000001h                                              ; value of argument #1
    push 000000015h                                              ; type of argument #1
    lea r10, [rbp-078h]                                          ; pointer to return value (and type, 8 bytes earlier)
    push r10                                                     ; (that pointer is the last value pushed to the stack)
    mov qword ptr r9, 0h                                         ; pointer to this
    mov qword ptr r8, 000000000h                                 ; type of this
    mov qword ptr rdx, 0h                                        ; pointer to closure
    mov rcx, 1                                                   ; number of arguments
    sub rsp, 20h                                                 ; allocate shadow space
    call offset func$exit                                        ; jump to subroutine
    add rsp, 038h                                                ; release shadow space and arguments
    mov rcx, [rbp+018h]                                          ; restore rcx from shadow space
    mov rdx, [rbp+020h]                                          ; restore rdx from shadow space
    mov r8, [rbp+028h]                                           ; restore r8 from shadow space
    mov r9, [rbp+030h]                                           ; restore r9 from shadow space
  func$_stringByteLength$pointer$TypeMatch:
  mov r10, [rbp-058h]                                            ; add mutates first operand, so indirect via register
  add r10, 000000008h                                            ; + operator
  mov [rbp-0a8h], r10                                            ; store result
  mov qword ptr [rbp-0b0h], 000000015h                           ; store type
  mov r10, [rbp-0a8h]                                            ; value of + operator result
  mov r11, [r10]                                                 ; dereference + operator result and put result in address of + operator result
  mov [rbp-0b8h], r11                                            ; (indirect via r11 because mov can't do memory-to-memory)
  mov qword ptr [rbp-0c0h], 000000015h                           ; type of address of + operator result
  mov rax, [rbp-0c0h]                                            ; load the dynamic type of return value of _stringByteLength into rax
  lea r10, typeTable                                             ; move type table offset into r10
  add rax, r10                                                   ; adjust rax to point to the type table
  bt qword ptr [rax], 2                                          ; check that return value of _stringByteLength is Integer'21
  jc func$_stringByteLength$returnValueOfStringbytelength$TypeMatch ; skip next block if the type matches
    ; Error handling block for return value of _stringByteLength
    ;  - print(returnValueTypeCheckFailureMessage)
    mov [rbp+018h], rcx                                          ; save rcx in shadow space
    mov [rbp+020h], rdx                                          ; save rdx in shadow space
    mov [rbp+028h], r8                                           ; save r8 in shadow space
    mov [rbp+030h], r9                                           ; save r9 in shadow space
    mov r11, offset returnValueTypeCheckFailureMessage           ; value of argument #1
    push r11                                                     ; (indirect via r11 because "returnValueTypeCheckFailureMessage" is an imm64)
    push 000000016h                                              ; type of argument #1
    lea r10, [rbp-0c8h]                                          ; pointer to return value (and type, 8 bytes earlier)
    push r10                                                     ; (that pointer is the last value pushed to the stack)
    mov qword ptr r9, 0h                                         ; pointer to this
    mov qword ptr r8, 000000000h                                 ; type of this
    mov qword ptr rdx, 0h                                        ; pointer to closure
    mov rcx, 1                                                   ; number of arguments
    sub rsp, 20h                                                 ; allocate shadow space
    call offset func$__print                                     ; jump to subroutine
    add rsp, 038h                                                ; release shadow space and arguments
    mov rcx, [rbp+018h]                                          ; restore rcx from shadow space
    mov rdx, [rbp+020h]                                          ; restore rdx from shadow space
    mov r8, [rbp+028h]                                           ; restore r8 from shadow space
    mov r9, [rbp+030h]                                           ; restore r9 from shadow space
    ;  - exit(1)
    mov [rbp+018h], rcx                                          ; save rcx in shadow space
    mov [rbp+020h], rdx                                          ; save rdx in shadow space
    mov [rbp+028h], r8                                           ; save r8 in shadow space
    mov [rbp+030h], r9                                           ; save r9 in shadow space
    push 000000001h                                              ; value of argument #1
    push 000000015h                                              ; type of argument #1
    lea r10, [rbp-0d8h]                                          ; pointer to return value (and type, 8 bytes earlier)
    push r10                                                     ; (that pointer is the last value pushed to the stack)
    mov qword ptr r9, 0h                                         ; pointer to this
    mov qword ptr r8, 000000000h                                 ; type of this
    mov qword ptr rdx, 0h                                        ; pointer to closure
    mov rcx, 1                                                   ; number of arguments
    sub rsp, 20h                                                 ; allocate shadow space
    call offset func$exit                                        ; jump to subroutine
    add rsp, 038h                                                ; release shadow space and arguments
    mov rcx, [rbp+018h]                                          ; restore rcx from shadow space
    mov rdx, [rbp+020h]                                          ; restore rdx from shadow space
    mov r8, [rbp+028h]                                           ; restore r8 from shadow space
    mov r9, [rbp+030h]                                           ; restore r9 from shadow space
  func$_stringByteLength$returnValueOfStringbytelength$TypeMatch:
  mov r11, [rbp-0b8h]                                            ; value of return value
  mov [r15], r11                                                 ; (indirect via r11 because mov can't do memory-to-memory)
  mov r11, [rbp-0c0h]                                            ; type of return value
  mov [r15-08h], r11                                             ; (indirect via r11 because mov can't do memory-to-memory)
  jmp func$_stringByteLength$epilog                              ; return
  func$_stringByteLength$epilog:
  mov rax, r15                                                   ; report address of return value
  ; Epilog
  add rsp, 0e0h                                                  ; free space for stack
  pop r15                                                        ; restore non-volatile registers
  pop rbp                                                        ; restore non-volatile registers
  ret                                                            ; return from subroutine

; _free
func$_free:
  ; Prolog
  push rbp                                                       ; save non-volatile registers
  push r15                                                       ; save non-volatile registers
  sub rsp, 090h                                                  ; allocate space for stack
  lea rbp, [rsp+090h]                                            ; set up frame pointer
  mov r15, [rbp+038h]                                            ; prepare return value
  ; Check parameter count
  cmp qword ptr rcx, 000000001h                                  ; compare parameter count to integers
  je func$_free$parameterCount$continuation                      ; check number of parameters is as expected
    ; Error handling block for parameter count
    ;  - print(parameterCountCheckFailureMessage)
    mov [rbp+018h], rcx                                          ; save rcx in shadow space
    mov [rbp+020h], rdx                                          ; save rdx in shadow space
    mov [rbp+028h], r8                                           ; save r8 in shadow space
    mov [rbp+030h], r9                                           ; save r9 in shadow space
    mov r11, offset parameterCountCheckFailureMessage            ; value of argument #1
    push r11                                                     ; (indirect via r11 because "parameterCountCheckFailureMessage" is an imm64)
    push 000000016h                                              ; type of argument #1
    lea r10, [rbp-008h]                                          ; pointer to return value (and type, 8 bytes earlier)
    push r10                                                     ; (that pointer is the last value pushed to the stack)
    mov qword ptr r9, 0h                                         ; pointer to this
    mov qword ptr r8, 000000000h                                 ; type of this
    mov qword ptr rdx, 0h                                        ; pointer to closure
    mov rcx, 1                                                   ; number of arguments
    sub rsp, 20h                                                 ; allocate shadow space
    call offset func$__print                                     ; jump to subroutine
    add rsp, 038h                                                ; release shadow space and arguments
    mov rcx, [rbp+018h]                                          ; restore rcx from shadow space
    mov rdx, [rbp+020h]                                          ; restore rdx from shadow space
    mov r8, [rbp+028h]                                           ; restore r8 from shadow space
    mov r9, [rbp+030h]                                           ; restore r9 from shadow space
    ;  - exit(1)
    mov [rbp+018h], rcx                                          ; save rcx in shadow space
    mov [rbp+020h], rdx                                          ; save rdx in shadow space
    mov [rbp+028h], r8                                           ; save r8 in shadow space
    mov [rbp+030h], r9                                           ; save r9 in shadow space
    push 000000001h                                              ; value of argument #1
    push 000000015h                                              ; type of argument #1
    lea r10, [rbp-018h]                                          ; pointer to return value (and type, 8 bytes earlier)
    push r10                                                     ; (that pointer is the last value pushed to the stack)
    mov qword ptr r9, 0h                                         ; pointer to this
    mov qword ptr r8, 000000000h                                 ; type of this
    mov qword ptr rdx, 0h                                        ; pointer to closure
    mov rcx, 1                                                   ; number of arguments
    sub rsp, 20h                                                 ; allocate shadow space
    call offset func$exit                                        ; jump to subroutine
    add rsp, 038h                                                ; release shadow space and arguments
    mov rcx, [rbp+018h]                                          ; restore rcx from shadow space
    mov rdx, [rbp+020h]                                          ; restore rdx from shadow space
    mov r8, [rbp+028h]                                           ; restore r8 from shadow space
    mov r9, [rbp+030h]                                           ; restore r9 from shadow space
  func$_free$parameterCount$continuation:                        ; end of parameter count
  ; Check type of parameter 0, pointer (expecting Integer)
  mov rax, [rbp+040h]                                            ; load the dynamic type of pointer into rax
  lea r10, typeTable                                             ; move type table offset into r10
  add rax, r10                                                   ; adjust rax to point to the type table
  bt qword ptr [rax], 2                                          ; check that pointer is Integer'21
  jc func$_free$pointer$TypeMatch                                ; skip next block if the type matches
    ; Error handling block for pointer
    ;  - print(parameterTypeCheckFailureMessage)
    mov [rbp+018h], rcx                                          ; save rcx in shadow space
    mov [rbp+020h], rdx                                          ; save rdx in shadow space
    mov [rbp+028h], r8                                           ; save r8 in shadow space
    mov [rbp+030h], r9                                           ; save r9 in shadow space
    mov r11, offset parameterTypeCheckFailureMessage             ; value of argument #1
    push r11                                                     ; (indirect via r11 because "parameterTypeCheckFailureMessage" is an imm64)
    push 000000016h                                              ; type of argument #1
    lea r10, [rbp-028h]                                          ; pointer to return value (and type, 8 bytes earlier)
    push r10                                                     ; (that pointer is the last value pushed to the stack)
    mov qword ptr r9, 0h                                         ; pointer to this
    mov qword ptr r8, 000000000h                                 ; type of this
    mov qword ptr rdx, 0h                                        ; pointer to closure
    mov rcx, 1                                                   ; number of arguments
    sub rsp, 20h                                                 ; allocate shadow space
    call offset func$__print                                     ; jump to subroutine
    add rsp, 038h                                                ; release shadow space and arguments
    mov rcx, [rbp+018h]                                          ; restore rcx from shadow space
    mov rdx, [rbp+020h]                                          ; restore rdx from shadow space
    mov r8, [rbp+028h]                                           ; restore r8 from shadow space
    mov r9, [rbp+030h]                                           ; restore r9 from shadow space
    ;  - exit(1)
    mov [rbp+018h], rcx                                          ; save rcx in shadow space
    mov [rbp+020h], rdx                                          ; save rdx in shadow space
    mov [rbp+028h], r8                                           ; save r8 in shadow space
    mov [rbp+030h], r9                                           ; save r9 in shadow space
    push 000000001h                                              ; value of argument #1
    push 000000015h                                              ; type of argument #1
    lea r10, [rbp-038h]                                          ; pointer to return value (and type, 8 bytes earlier)
    push r10                                                     ; (that pointer is the last value pushed to the stack)
    mov qword ptr r9, 0h                                         ; pointer to this
    mov qword ptr r8, 000000000h                                 ; type of this
    mov qword ptr rdx, 0h                                        ; pointer to closure
    mov rcx, 1                                                   ; number of arguments
    sub rsp, 20h                                                 ; allocate shadow space
    call offset func$exit                                        ; jump to subroutine
    add rsp, 038h                                                ; release shadow space and arguments
    mov rcx, [rbp+018h]                                          ; restore rcx from shadow space
    mov rdx, [rbp+020h]                                          ; restore rdx from shadow space
    mov r8, [rbp+028h]                                           ; restore r8 from shadow space
    mov r9, [rbp+030h]                                           ; restore r9 from shadow space
  func$_free$pointer$TypeMatch:
  ; Line 33: if (__heapFree(_heapHandle, 0, pointer) == 0) { ...
  mov [rbp+018h], rcx                                            ; save rcx in shadow space
  mov [rbp+020h], rdx                                            ; save rdx in shadow space
  mov [rbp+028h], r8                                             ; save r8 in shadow space
  mov [rbp+030h], r9                                             ; save r9 in shadow space
  push [rbp+048h]                                                ; value of argument #3
  push [rbp+040h]                                                ; type of argument #3
  push 000000000h                                                ; value of argument #2
  push 000000015h                                                ; type of argument #2
  push global0Value                                              ; value of argument #1
  push global0Type                                               ; type of argument #1
  lea r10, [rbp-048h]                                            ; pointer to return value (and type, 8 bytes earlier)
  push r10                                                       ; (that pointer is the last value pushed to the stack)
  mov qword ptr r9, 0h                                           ; pointer to this
  mov qword ptr r8, 000000000h                                   ; type of this
  mov qword ptr rdx, 0h                                          ; pointer to closure
  mov rcx, 3                                                     ; number of arguments
  sub rsp, 20h                                                   ; allocate shadow space
  call offset func$__heapFree                                    ; jump to subroutine
  add rsp, 058h                                                  ; release shadow space and arguments
  mov rcx, [rbp+018h]                                            ; restore rcx from shadow space
  mov rdx, [rbp+020h]                                            ; restore rdx from shadow space
  mov r8, [rbp+028h]                                             ; restore r8 from shadow space
  mov r9, [rbp+030h]                                             ; restore r9 from shadow space
  xor r10, r10                                                   ; prepare r10 for result of value comparison
  cmp qword ptr [rbp-048h], 000000000h                           ; compare return value to 0
  sete byte ptr r10b                                             ; store result in r10
  xor rax, rax                                                   ; prepare rax for result of type comparison
  cmp qword ptr [rbp-050h], 000000015h                           ; compare type of return value to type of 0
  sete byte ptr al                                               ; store result in rax
  and r10, rax                                                   ; true if type and value are both equal; result goes into r10
  mov [rbp-058h], r10                                            ; store result in == operator result
  mov qword ptr [rbp-060h], 000000014h                           ; == operator result is a Boolean
  cmp qword ptr [rbp-058h], 000000000h                           ; compare == operator result to false
  je func$_free$if$continuation                                  ; __heapFree(_heapHandle, 0, pointer) == 0
    ; Line 35: exit(1);
    mov [rbp+018h], rcx                                          ; save rcx in shadow space
    mov [rbp+020h], rdx                                          ; save rdx in shadow space
    mov [rbp+028h], r8                                           ; save r8 in shadow space
    mov [rbp+030h], r9                                           ; save r9 in shadow space
    push 000000001h                                              ; value of argument #1
    push 000000015h                                              ; type of argument #1
    lea r10, [rbp-068h]                                          ; pointer to return value (and type, 8 bytes earlier)
    push r10                                                     ; (that pointer is the last value pushed to the stack)
    mov qword ptr r9, 0h                                         ; pointer to this
    mov qword ptr r8, 000000000h                                 ; type of this
    mov qword ptr rdx, 0h                                        ; pointer to closure
    mov rcx, 1                                                   ; number of arguments
    sub rsp, 20h                                                 ; allocate shadow space
    call offset func$exit                                        ; jump to subroutine
    add rsp, 038h                                                ; release shadow space and arguments
    mov rcx, [rbp+018h]                                          ; restore rcx from shadow space
    mov rdx, [rbp+020h]                                          ; restore rdx from shadow space
    mov r8, [rbp+028h]                                           ; restore r8 from shadow space
    mov r9, [rbp+030h]                                           ; restore r9 from shadow space
  func$_free$if$continuation:                                    ; end of if
  ; Line 37: return true;
  mov qword ptr [r15], 000000001h                                ; value of return value
  mov qword ptr [r15-08h], 000000014h                            ; type of return value
  jmp func$_free$epilog                                          ; return
  func$_free$epilog:
  mov rax, r15                                                   ; report address of return value
  ; Epilog
  add rsp, 090h                                                  ; free space for stack
  pop r15                                                        ; restore non-volatile registers
  pop rbp                                                        ; restore non-volatile registers
  ret                                                            ; return from subroutine

; _moveBytes
func$_moveBytes:
  ; Prolog
  push rbp                                                       ; save non-volatile registers
  push r15                                                       ; save non-volatile registers
  sub rsp, 06f0h                                                 ; allocate space for stack
  lea rbp, [rsp+06f0h]                                           ; set up frame pointer
  mov r15, [rbp+038h]                                            ; prepare return value
  ; Check parameter count
  cmp qword ptr rcx, 000000003h                                  ; compare parameter count to integers
  je func$_moveBytes$parameterCount$continuation                 ; check number of parameters is as expected
    ; Error handling block for parameter count
    ;  - print(parameterCountCheckFailureMessage)
    mov [rbp+018h], rcx                                          ; save rcx in shadow space
    mov [rbp+020h], rdx                                          ; save rdx in shadow space
    mov [rbp+028h], r8                                           ; save r8 in shadow space
    mov [rbp+030h], r9                                           ; save r9 in shadow space
    mov r11, offset parameterCountCheckFailureMessage            ; value of argument #1
    push r11                                                     ; (indirect via r11 because "parameterCountCheckFailureMessage" is an imm64)
    push 000000016h                                              ; type of argument #1
    lea r10, [rbp-008h]                                          ; pointer to return value (and type, 8 bytes earlier)
    push r10                                                     ; (that pointer is the last value pushed to the stack)
    mov qword ptr r9, 0h                                         ; pointer to this
    mov qword ptr r8, 000000000h                                 ; type of this
    mov qword ptr rdx, 0h                                        ; pointer to closure
    mov rcx, 1                                                   ; number of arguments
    sub rsp, 20h                                                 ; allocate shadow space
    call offset func$__print                                     ; jump to subroutine
    add rsp, 038h                                                ; release shadow space and arguments
    mov rcx, [rbp+018h]                                          ; restore rcx from shadow space
    mov rdx, [rbp+020h]                                          ; restore rdx from shadow space
    mov r8, [rbp+028h]                                           ; restore r8 from shadow space
    mov r9, [rbp+030h]                                           ; restore r9 from shadow space
    ;  - exit(1)
    mov [rbp+018h], rcx                                          ; save rcx in shadow space
    mov [rbp+020h], rdx                                          ; save rdx in shadow space
    mov [rbp+028h], r8                                           ; save r8 in shadow space
    mov [rbp+030h], r9                                           ; save r9 in shadow space
    push 000000001h                                              ; value of argument #1
    push 000000015h                                              ; type of argument #1
    lea r10, [rbp-018h]                                          ; pointer to return value (and type, 8 bytes earlier)
    push r10                                                     ; (that pointer is the last value pushed to the stack)
    mov qword ptr r9, 0h                                         ; pointer to this
    mov qword ptr r8, 000000000h                                 ; type of this
    mov qword ptr rdx, 0h                                        ; pointer to closure
    mov rcx, 1                                                   ; number of arguments
    sub rsp, 20h                                                 ; allocate shadow space
    call offset func$exit                                        ; jump to subroutine
    add rsp, 038h                                                ; release shadow space and arguments
    mov rcx, [rbp+018h]                                          ; restore rcx from shadow space
    mov rdx, [rbp+020h]                                          ; restore rdx from shadow space
    mov r8, [rbp+028h]                                           ; restore r8 from shadow space
    mov r9, [rbp+030h]                                           ; restore r9 from shadow space
  func$_moveBytes$parameterCount$continuation:                   ; end of parameter count
  ; Check type of parameter 0, from (expecting Integer)
  mov rax, [rbp+040h]                                            ; load the dynamic type of from into rax
  lea r10, typeTable                                             ; move type table offset into r10
  add rax, r10                                                   ; adjust rax to point to the type table
  bt qword ptr [rax], 2                                          ; check that from is Integer'21
  jc func$_moveBytes$from$TypeMatch                              ; skip next block if the type matches
    ; Error handling block for from
    ;  - print(parameterTypeCheckFailureMessage)
    mov [rbp+018h], rcx                                          ; save rcx in shadow space
    mov [rbp+020h], rdx                                          ; save rdx in shadow space
    mov [rbp+028h], r8                                           ; save r8 in shadow space
    mov [rbp+030h], r9                                           ; save r9 in shadow space
    mov r11, offset parameterTypeCheckFailureMessage             ; value of argument #1
    push r11                                                     ; (indirect via r11 because "parameterTypeCheckFailureMessage" is an imm64)
    push 000000016h                                              ; type of argument #1
    lea r10, [rbp-028h]                                          ; pointer to return value (and type, 8 bytes earlier)
    push r10                                                     ; (that pointer is the last value pushed to the stack)
    mov qword ptr r9, 0h                                         ; pointer to this
    mov qword ptr r8, 000000000h                                 ; type of this
    mov qword ptr rdx, 0h                                        ; pointer to closure
    mov rcx, 1                                                   ; number of arguments
    sub rsp, 20h                                                 ; allocate shadow space
    call offset func$__print                                     ; jump to subroutine
    add rsp, 038h                                                ; release shadow space and arguments
    mov rcx, [rbp+018h]                                          ; restore rcx from shadow space
    mov rdx, [rbp+020h]                                          ; restore rdx from shadow space
    mov r8, [rbp+028h]                                           ; restore r8 from shadow space
    mov r9, [rbp+030h]                                           ; restore r9 from shadow space
    ;  - exit(1)
    mov [rbp+018h], rcx                                          ; save rcx in shadow space
    mov [rbp+020h], rdx                                          ; save rdx in shadow space
    mov [rbp+028h], r8                                           ; save r8 in shadow space
    mov [rbp+030h], r9                                           ; save r9 in shadow space
    push 000000001h                                              ; value of argument #1
    push 000000015h                                              ; type of argument #1
    lea r10, [rbp-038h]                                          ; pointer to return value (and type, 8 bytes earlier)
    push r10                                                     ; (that pointer is the last value pushed to the stack)
    mov qword ptr r9, 0h                                         ; pointer to this
    mov qword ptr r8, 000000000h                                 ; type of this
    mov qword ptr rdx, 0h                                        ; pointer to closure
    mov rcx, 1                                                   ; number of arguments
    sub rsp, 20h                                                 ; allocate shadow space
    call offset func$exit                                        ; jump to subroutine
    add rsp, 038h                                                ; release shadow space and arguments
    mov rcx, [rbp+018h]                                          ; restore rcx from shadow space
    mov rdx, [rbp+020h]                                          ; restore rdx from shadow space
    mov r8, [rbp+028h]                                           ; restore r8 from shadow space
    mov r9, [rbp+030h]                                           ; restore r9 from shadow space
  func$_moveBytes$from$TypeMatch:
  ; Check type of parameter 1, to (expecting Integer)
  mov rax, [rbp+050h]                                            ; load the dynamic type of to into rax
  lea r10, typeTable                                             ; move type table offset into r10
  add rax, r10                                                   ; adjust rax to point to the type table
  bt qword ptr [rax], 2                                          ; check that to is Integer'21
  jc func$_moveBytes$to$TypeMatch                                ; skip next block if the type matches
    ; Error handling block for to
    ;  - print(parameterTypeCheckFailureMessage)
    mov [rbp+018h], rcx                                          ; save rcx in shadow space
    mov [rbp+020h], rdx                                          ; save rdx in shadow space
    mov [rbp+028h], r8                                           ; save r8 in shadow space
    mov [rbp+030h], r9                                           ; save r9 in shadow space
    mov r11, offset parameterTypeCheckFailureMessage             ; value of argument #1
    push r11                                                     ; (indirect via r11 because "parameterTypeCheckFailureMessage" is an imm64)
    push 000000016h                                              ; type of argument #1
    lea r10, [rbp-048h]                                          ; pointer to return value (and type, 8 bytes earlier)
    push r10                                                     ; (that pointer is the last value pushed to the stack)
    mov qword ptr r9, 0h                                         ; pointer to this
    mov qword ptr r8, 000000000h                                 ; type of this
    mov qword ptr rdx, 0h                                        ; pointer to closure
    mov rcx, 1                                                   ; number of arguments
    sub rsp, 20h                                                 ; allocate shadow space
    call offset func$__print                                     ; jump to subroutine
    add rsp, 038h                                                ; release shadow space and arguments
    mov rcx, [rbp+018h]                                          ; restore rcx from shadow space
    mov rdx, [rbp+020h]                                          ; restore rdx from shadow space
    mov r8, [rbp+028h]                                           ; restore r8 from shadow space
    mov r9, [rbp+030h]                                           ; restore r9 from shadow space
    ;  - exit(1)
    mov [rbp+018h], rcx                                          ; save rcx in shadow space
    mov [rbp+020h], rdx                                          ; save rdx in shadow space
    mov [rbp+028h], r8                                           ; save r8 in shadow space
    mov [rbp+030h], r9                                           ; save r9 in shadow space
    push 000000001h                                              ; value of argument #1
    push 000000015h                                              ; type of argument #1
    lea r10, [rbp-058h]                                          ; pointer to return value (and type, 8 bytes earlier)
    push r10                                                     ; (that pointer is the last value pushed to the stack)
    mov qword ptr r9, 0h                                         ; pointer to this
    mov qword ptr r8, 000000000h                                 ; type of this
    mov qword ptr rdx, 0h                                        ; pointer to closure
    mov rcx, 1                                                   ; number of arguments
    sub rsp, 20h                                                 ; allocate shadow space
    call offset func$exit                                        ; jump to subroutine
    add rsp, 038h                                                ; release shadow space and arguments
    mov rcx, [rbp+018h]                                          ; restore rcx from shadow space
    mov rdx, [rbp+020h]                                          ; restore rdx from shadow space
    mov r8, [rbp+028h]                                           ; restore r8 from shadow space
    mov r9, [rbp+030h]                                           ; restore r9 from shadow space
  func$_moveBytes$to$TypeMatch:
  ; Check type of parameter 2, length (expecting Integer)
  mov rax, [rbp+060h]                                            ; load the dynamic type of length into rax
  lea r10, typeTable                                             ; move type table offset into r10
  add rax, r10                                                   ; adjust rax to point to the type table
  bt qword ptr [rax], 2                                          ; check that length is Integer'21
  jc func$_moveBytes$length$TypeMatch                            ; skip next block if the type matches
    ; Error handling block for length
    ;  - print(parameterTypeCheckFailureMessage)
    mov [rbp+018h], rcx                                          ; save rcx in shadow space
    mov [rbp+020h], rdx                                          ; save rdx in shadow space
    mov [rbp+028h], r8                                           ; save r8 in shadow space
    mov [rbp+030h], r9                                           ; save r9 in shadow space
    mov r11, offset parameterTypeCheckFailureMessage             ; value of argument #1
    push r11                                                     ; (indirect via r11 because "parameterTypeCheckFailureMessage" is an imm64)
    push 000000016h                                              ; type of argument #1
    lea r10, [rbp-068h]                                          ; pointer to return value (and type, 8 bytes earlier)
    push r10                                                     ; (that pointer is the last value pushed to the stack)
    mov qword ptr r9, 0h                                         ; pointer to this
    mov qword ptr r8, 000000000h                                 ; type of this
    mov qword ptr rdx, 0h                                        ; pointer to closure
    mov rcx, 1                                                   ; number of arguments
    sub rsp, 20h                                                 ; allocate shadow space
    call offset func$__print                                     ; jump to subroutine
    add rsp, 038h                                                ; release shadow space and arguments
    mov rcx, [rbp+018h]                                          ; restore rcx from shadow space
    mov rdx, [rbp+020h]                                          ; restore rdx from shadow space
    mov r8, [rbp+028h]                                           ; restore r8 from shadow space
    mov r9, [rbp+030h]                                           ; restore r9 from shadow space
    ;  - exit(1)
    mov [rbp+018h], rcx                                          ; save rcx in shadow space
    mov [rbp+020h], rdx                                          ; save rdx in shadow space
    mov [rbp+028h], r8                                           ; save r8 in shadow space
    mov [rbp+030h], r9                                           ; save r9 in shadow space
    push 000000001h                                              ; value of argument #1
    push 000000015h                                              ; type of argument #1
    lea r10, [rbp-078h]                                          ; pointer to return value (and type, 8 bytes earlier)
    push r10                                                     ; (that pointer is the last value pushed to the stack)
    mov qword ptr r9, 0h                                         ; pointer to this
    mov qword ptr r8, 000000000h                                 ; type of this
    mov qword ptr rdx, 0h                                        ; pointer to closure
    mov rcx, 1                                                   ; number of arguments
    sub rsp, 20h                                                 ; allocate shadow space
    call offset func$exit                                        ; jump to subroutine
    add rsp, 038h                                                ; release shadow space and arguments
    mov rcx, [rbp+018h]                                          ; restore rcx from shadow space
    mov rdx, [rbp+020h]                                          ; restore rdx from shadow space
    mov r8, [rbp+028h]                                           ; restore r8 from shadow space
    mov r9, [rbp+030h]                                           ; restore r9 from shadow space
  func$_moveBytes$length$TypeMatch:
  ; Line 42: assert(length > 0, '_moveBytes expects positive number of bytes ...
  mov rax, [rbp+060h]                                            ; load the dynamic type of length into rax
  lea r10, typeTable                                             ; move type table offset into r10
  add rax, r10                                                   ; adjust rax to point to the type table
  bt qword ptr [rax], 2                                          ; check that length is Integer'21
  jc func$_moveBytes$length$TypeMatch$1                          ; skip next block if the type matches
    ; Error handling block for length
    ;  - print(operandTypeCheckFailureMessage)
    mov [rbp+018h], rcx                                          ; save rcx in shadow space
    mov [rbp+020h], rdx                                          ; save rdx in shadow space
    mov [rbp+028h], r8                                           ; save r8 in shadow space
    mov [rbp+030h], r9                                           ; save r9 in shadow space
    mov r11, offset operandTypeCheckFailureMessage               ; value of argument #1
    push r11                                                     ; (indirect via r11 because "operandTypeCheckFailureMessage" is an imm64)
    push 000000016h                                              ; type of argument #1
    lea r10, [rbp-088h]                                          ; pointer to return value (and type, 8 bytes earlier)
    push r10                                                     ; (that pointer is the last value pushed to the stack)
    mov qword ptr r9, 0h                                         ; pointer to this
    mov qword ptr r8, 000000000h                                 ; type of this
    mov qword ptr rdx, 0h                                        ; pointer to closure
    mov rcx, 1                                                   ; number of arguments
    sub rsp, 20h                                                 ; allocate shadow space
    call offset func$__print                                     ; jump to subroutine
    add rsp, 038h                                                ; release shadow space and arguments
    mov rcx, [rbp+018h]                                          ; restore rcx from shadow space
    mov rdx, [rbp+020h]                                          ; restore rdx from shadow space
    mov r8, [rbp+028h]                                           ; restore r8 from shadow space
    mov r9, [rbp+030h]                                           ; restore r9 from shadow space
    ;  - exit(1)
    mov [rbp+018h], rcx                                          ; save rcx in shadow space
    mov [rbp+020h], rdx                                          ; save rdx in shadow space
    mov [rbp+028h], r8                                           ; save r8 in shadow space
    mov [rbp+030h], r9                                           ; save r9 in shadow space
    push 000000001h                                              ; value of argument #1
    push 000000015h                                              ; type of argument #1
    lea r10, [rbp-098h]                                          ; pointer to return value (and type, 8 bytes earlier)
    push r10                                                     ; (that pointer is the last value pushed to the stack)
    mov qword ptr r9, 0h                                         ; pointer to this
    mov qword ptr r8, 000000000h                                 ; type of this
    mov qword ptr rdx, 0h                                        ; pointer to closure
    mov rcx, 1                                                   ; number of arguments
    sub rsp, 20h                                                 ; allocate shadow space
    call offset func$exit                                        ; jump to subroutine
    add rsp, 038h                                                ; release shadow space and arguments
    mov rcx, [rbp+018h]                                          ; restore rcx from shadow space
    mov rdx, [rbp+020h]                                          ; restore rdx from shadow space
    mov r8, [rbp+028h]                                           ; restore r8 from shadow space
    mov r9, [rbp+030h]                                           ; restore r9 from shadow space
  func$_moveBytes$length$TypeMatch$1:
  mov qword ptr [rbp-0c8h], 000000000h                           ; clear > operator result
  cmp qword ptr [rbp+068h], 000000000h                           ; compare length to 0
  setg byte ptr [rbp-0c8h]                                       ; store result in > operator result
  mov qword ptr [rbp-0d0h], 000000014h                           ; > operator result is a Boolean
  mov [rbp+018h], rcx                                            ; save rcx in shadow space
  mov [rbp+020h], rdx                                            ; save rdx in shadow space
  mov [rbp+028h], r8                                             ; save r8 in shadow space
  mov [rbp+030h], r9                                             ; save r9 in shadow space
  mov r11, offset string$1                                       ; value of argument #2
  push r11                                                       ; (indirect via r11 because "string$1" is an imm64)
  push 000000016h                                                ; type of argument #2
  push [rbp-0c8h]                                                ; value of argument #1
  push [rbp-0d0h]                                                ; type of argument #1
  lea r10, [rbp-0d8h]                                            ; pointer to return value (and type, 8 bytes earlier)
  push r10                                                       ; (that pointer is the last value pushed to the stack)
  mov qword ptr r9, 0h                                           ; pointer to this
  mov qword ptr r8, 000000000h                                   ; type of this
  mov qword ptr rdx, 0h                                          ; pointer to closure
  mov rcx, 2                                                     ; number of arguments
  sub rsp, 20h                                                   ; allocate shadow space
  call offset func$assert                                        ; jump to subroutine
  add rsp, 048h                                                  ; release shadow space and arguments
  mov rcx, [rbp+018h]                                            ; restore rcx from shadow space
  mov rdx, [rbp+020h]                                            ; restore rdx from shadow space
  mov r8, [rbp+028h]                                             ; restore r8 from shadow space
  mov r9, [rbp+030h]                                             ; restore r9 from shadow space
  ; Line 43: Integer fromCursor = from;
  mov r11, [rbp+048h]                                            ; value of fromCursor
  mov [rbp-0e8h], r11                                            ; (indirect via r11 because mov can't do memory-to-memory)
  mov r11, [rbp+040h]                                            ; type of fromCursor
  mov [rbp-0f0h], r11                                            ; (indirect via r11 because mov can't do memory-to-memory)
  ; Line 44: Integer toCursor = to;
  mov r11, [rbp+058h]                                            ; value of toCursor
  mov [rbp-0f8h], r11                                            ; (indirect via r11 because mov can't do memory-to-memory)
  mov r11, [rbp+050h]                                            ; type of toCursor
  mov [rbp-0100h], r11                                           ; (indirect via r11 because mov can't do memory-to-memory)
  ; Line 45: Integer end = from + length / 8 * 8;
  mov rax, [rbp+060h]                                            ; load the dynamic type of length into rax
  lea r10, typeTable                                             ; move type table offset into r10
  add rax, r10                                                   ; adjust rax to point to the type table
  bt qword ptr [rax], 2                                          ; check that length is Integer'21
  jc func$_moveBytes$length$TypeMatch$2                          ; skip next block if the type matches
    ; Error handling block for length
    ;  - print(operandTypeCheckFailureMessage)
    mov [rbp+018h], rcx                                          ; save rcx in shadow space
    mov [rbp+020h], rdx                                          ; save rdx in shadow space
    mov [rbp+028h], r8                                           ; save r8 in shadow space
    mov [rbp+030h], r9                                           ; save r9 in shadow space
    mov r11, offset operandTypeCheckFailureMessage               ; value of argument #1
    push r11                                                     ; (indirect via r11 because "operandTypeCheckFailureMessage" is an imm64)
    push 000000016h                                              ; type of argument #1
    lea r10, [rbp-0108h]                                         ; pointer to return value (and type, 8 bytes earlier)
    push r10                                                     ; (that pointer is the last value pushed to the stack)
    mov qword ptr r9, 0h                                         ; pointer to this
    mov qword ptr r8, 000000000h                                 ; type of this
    mov qword ptr rdx, 0h                                        ; pointer to closure
    mov rcx, 1                                                   ; number of arguments
    sub rsp, 20h                                                 ; allocate shadow space
    call offset func$__print                                     ; jump to subroutine
    add rsp, 038h                                                ; release shadow space and arguments
    mov rcx, [rbp+018h]                                          ; restore rcx from shadow space
    mov rdx, [rbp+020h]                                          ; restore rdx from shadow space
    mov r8, [rbp+028h]                                           ; restore r8 from shadow space
    mov r9, [rbp+030h]                                           ; restore r9 from shadow space
    ;  - exit(1)
    mov [rbp+018h], rcx                                          ; save rcx in shadow space
    mov [rbp+020h], rdx                                          ; save rdx in shadow space
    mov [rbp+028h], r8                                           ; save r8 in shadow space
    mov [rbp+030h], r9                                           ; save r9 in shadow space
    push 000000001h                                              ; value of argument #1
    push 000000015h                                              ; type of argument #1
    lea r10, [rbp-0118h]                                         ; pointer to return value (and type, 8 bytes earlier)
    push r10                                                     ; (that pointer is the last value pushed to the stack)
    mov qword ptr r9, 0h                                         ; pointer to this
    mov qword ptr r8, 000000000h                                 ; type of this
    mov qword ptr rdx, 0h                                        ; pointer to closure
    mov rcx, 1                                                   ; number of arguments
    sub rsp, 20h                                                 ; allocate shadow space
    call offset func$exit                                        ; jump to subroutine
    add rsp, 038h                                                ; release shadow space and arguments
    mov rcx, [rbp+018h]                                          ; restore rcx from shadow space
    mov rdx, [rbp+020h]                                          ; restore rdx from shadow space
    mov r8, [rbp+028h]                                           ; restore r8 from shadow space
    mov r9, [rbp+030h]                                           ; restore r9 from shadow space
  func$_moveBytes$length$TypeMatch$2:
  mov [rbp+020h], rdx                                            ; save rdx
  mov rax, [rbp+068h]                                            ; prepare dividend
  xor rdx, rdx                                                   ; zero-extend dividend
  mov qword ptr r10, 000000008h                                  ; indirect via r10
  idiv r10                                                       ; / operator
  mov [rbp-0148h], rax                                           ; store result
  mov qword ptr [rbp-0150h], 000000015h                          ; store type
  mov rdx, [rbp+020h]                                            ; restore rdx
  mov rax, [rbp-0150h]                                           ; load the dynamic type of length / 8 into rax
  lea r10, typeTable                                             ; move type table offset into r10
  add rax, r10                                                   ; adjust rax to point to the type table
  bt qword ptr [rax], 2                                          ; check that length / 8 is Integer'21
  jc func$_moveBytes$length8$TypeMatch                           ; skip next block if the type matches
    ; Error handling block for length / 8
    ;  - print(operandTypeCheckFailureMessage)
    mov [rbp+018h], rcx                                          ; save rcx in shadow space
    mov [rbp+020h], rdx                                          ; save rdx in shadow space
    mov [rbp+028h], r8                                           ; save r8 in shadow space
    mov [rbp+030h], r9                                           ; save r9 in shadow space
    mov r11, offset operandTypeCheckFailureMessage               ; value of argument #1
    push r11                                                     ; (indirect via r11 because "operandTypeCheckFailureMessage" is an imm64)
    push 000000016h                                              ; type of argument #1
    lea r10, [rbp-0158h]                                         ; pointer to return value (and type, 8 bytes earlier)
    push r10                                                     ; (that pointer is the last value pushed to the stack)
    mov qword ptr r9, 0h                                         ; pointer to this
    mov qword ptr r8, 000000000h                                 ; type of this
    mov qword ptr rdx, 0h                                        ; pointer to closure
    mov rcx, 1                                                   ; number of arguments
    sub rsp, 20h                                                 ; allocate shadow space
    call offset func$__print                                     ; jump to subroutine
    add rsp, 038h                                                ; release shadow space and arguments
    mov rcx, [rbp+018h]                                          ; restore rcx from shadow space
    mov rdx, [rbp+020h]                                          ; restore rdx from shadow space
    mov r8, [rbp+028h]                                           ; restore r8 from shadow space
    mov r9, [rbp+030h]                                           ; restore r9 from shadow space
    ;  - exit(1)
    mov [rbp+018h], rcx                                          ; save rcx in shadow space
    mov [rbp+020h], rdx                                          ; save rdx in shadow space
    mov [rbp+028h], r8                                           ; save r8 in shadow space
    mov [rbp+030h], r9                                           ; save r9 in shadow space
    push 000000001h                                              ; value of argument #1
    push 000000015h                                              ; type of argument #1
    lea r10, [rbp-0168h]                                         ; pointer to return value (and type, 8 bytes earlier)
    push r10                                                     ; (that pointer is the last value pushed to the stack)
    mov qword ptr r9, 0h                                         ; pointer to this
    mov qword ptr r8, 000000000h                                 ; type of this
    mov qword ptr rdx, 0h                                        ; pointer to closure
    mov rcx, 1                                                   ; number of arguments
    sub rsp, 20h                                                 ; allocate shadow space
    call offset func$exit                                        ; jump to subroutine
    add rsp, 038h                                                ; release shadow space and arguments
    mov rcx, [rbp+018h]                                          ; restore rcx from shadow space
    mov rdx, [rbp+020h]                                          ; restore rdx from shadow space
    mov r8, [rbp+028h]                                           ; restore r8 from shadow space
    mov r9, [rbp+030h]                                           ; restore r9 from shadow space
  func$_moveBytes$length8$TypeMatch:
  mov r10, [rbp-0148h]                                           ; imul mutates first operand, so indirect via register
  imul r10, 000000008h                                           ; * operator
  mov [rbp-0198h], r10                                           ; store result
  mov qword ptr [rbp-01a0h], 000000015h                          ; store type
  mov rax, [rbp+040h]                                            ; load the dynamic type of from into rax
  lea r10, typeTable                                             ; move type table offset into r10
  add rax, r10                                                   ; adjust rax to point to the type table
  bt qword ptr [rax], 2                                          ; check that from is Integer'21
  jc func$_moveBytes$from$TypeMatch$1                            ; skip next block if the type matches
    ; Error handling block for from
    ;  - print(operandTypeCheckFailureMessage)
    mov [rbp+018h], rcx                                          ; save rcx in shadow space
    mov [rbp+020h], rdx                                          ; save rdx in shadow space
    mov [rbp+028h], r8                                           ; save r8 in shadow space
    mov [rbp+030h], r9                                           ; save r9 in shadow space
    mov r11, offset operandTypeCheckFailureMessage               ; value of argument #1
    push r11                                                     ; (indirect via r11 because "operandTypeCheckFailureMessage" is an imm64)
    push 000000016h                                              ; type of argument #1
    lea r10, [rbp-01a8h]                                         ; pointer to return value (and type, 8 bytes earlier)
    push r10                                                     ; (that pointer is the last value pushed to the stack)
    mov qword ptr r9, 0h                                         ; pointer to this
    mov qword ptr r8, 000000000h                                 ; type of this
    mov qword ptr rdx, 0h                                        ; pointer to closure
    mov rcx, 1                                                   ; number of arguments
    sub rsp, 20h                                                 ; allocate shadow space
    call offset func$__print                                     ; jump to subroutine
    add rsp, 038h                                                ; release shadow space and arguments
    mov rcx, [rbp+018h]                                          ; restore rcx from shadow space
    mov rdx, [rbp+020h]                                          ; restore rdx from shadow space
    mov r8, [rbp+028h]                                           ; restore r8 from shadow space
    mov r9, [rbp+030h]                                           ; restore r9 from shadow space
    ;  - exit(1)
    mov [rbp+018h], rcx                                          ; save rcx in shadow space
    mov [rbp+020h], rdx                                          ; save rdx in shadow space
    mov [rbp+028h], r8                                           ; save r8 in shadow space
    mov [rbp+030h], r9                                           ; save r9 in shadow space
    push 000000001h                                              ; value of argument #1
    push 000000015h                                              ; type of argument #1
    lea r10, [rbp-01b8h]                                         ; pointer to return value (and type, 8 bytes earlier)
    push r10                                                     ; (that pointer is the last value pushed to the stack)
    mov qword ptr r9, 0h                                         ; pointer to this
    mov qword ptr r8, 000000000h                                 ; type of this
    mov qword ptr rdx, 0h                                        ; pointer to closure
    mov rcx, 1                                                   ; number of arguments
    sub rsp, 20h                                                 ; allocate shadow space
    call offset func$exit                                        ; jump to subroutine
    add rsp, 038h                                                ; release shadow space and arguments
    mov rcx, [rbp+018h]                                          ; restore rcx from shadow space
    mov rdx, [rbp+020h]                                          ; restore rdx from shadow space
    mov r8, [rbp+028h]                                           ; restore r8 from shadow space
    mov r9, [rbp+030h]                                           ; restore r9 from shadow space
  func$_moveBytes$from$TypeMatch$1:
  mov rax, [rbp-01a0h]                                           ; load the dynamic type of length / 8 * 8 into rax
  lea r10, typeTable                                             ; move type table offset into r10
  add rax, r10                                                   ; adjust rax to point to the type table
  bt qword ptr [rax], 2                                          ; check that length / 8 * 8 is Integer'21
  jc func$_moveBytes$length88$TypeMatch                          ; skip next block if the type matches
    ; Error handling block for length / 8 * 8
    ;  - print(operandTypeCheckFailureMessage)
    mov [rbp+018h], rcx                                          ; save rcx in shadow space
    mov [rbp+020h], rdx                                          ; save rdx in shadow space
    mov [rbp+028h], r8                                           ; save r8 in shadow space
    mov [rbp+030h], r9                                           ; save r9 in shadow space
    mov r11, offset operandTypeCheckFailureMessage               ; value of argument #1
    push r11                                                     ; (indirect via r11 because "operandTypeCheckFailureMessage" is an imm64)
    push 000000016h                                              ; type of argument #1
    lea r10, [rbp-01c8h]                                         ; pointer to return value (and type, 8 bytes earlier)
    push r10                                                     ; (that pointer is the last value pushed to the stack)
    mov qword ptr r9, 0h                                         ; pointer to this
    mov qword ptr r8, 000000000h                                 ; type of this
    mov qword ptr rdx, 0h                                        ; pointer to closure
    mov rcx, 1                                                   ; number of arguments
    sub rsp, 20h                                                 ; allocate shadow space
    call offset func$__print                                     ; jump to subroutine
    add rsp, 038h                                                ; release shadow space and arguments
    mov rcx, [rbp+018h]                                          ; restore rcx from shadow space
    mov rdx, [rbp+020h]                                          ; restore rdx from shadow space
    mov r8, [rbp+028h]                                           ; restore r8 from shadow space
    mov r9, [rbp+030h]                                           ; restore r9 from shadow space
    ;  - exit(1)
    mov [rbp+018h], rcx                                          ; save rcx in shadow space
    mov [rbp+020h], rdx                                          ; save rdx in shadow space
    mov [rbp+028h], r8                                           ; save r8 in shadow space
    mov [rbp+030h], r9                                           ; save r9 in shadow space
    push 000000001h                                              ; value of argument #1
    push 000000015h                                              ; type of argument #1
    lea r10, [rbp-01d8h]                                         ; pointer to return value (and type, 8 bytes earlier)
    push r10                                                     ; (that pointer is the last value pushed to the stack)
    mov qword ptr r9, 0h                                         ; pointer to this
    mov qword ptr r8, 000000000h                                 ; type of this
    mov qword ptr rdx, 0h                                        ; pointer to closure
    mov rcx, 1                                                   ; number of arguments
    sub rsp, 20h                                                 ; allocate shadow space
    call offset func$exit                                        ; jump to subroutine
    add rsp, 038h                                                ; release shadow space and arguments
    mov rcx, [rbp+018h]                                          ; restore rcx from shadow space
    mov rdx, [rbp+020h]                                          ; restore rdx from shadow space
    mov r8, [rbp+028h]                                           ; restore r8 from shadow space
    mov r9, [rbp+030h]                                           ; restore r9 from shadow space
  func$_moveBytes$length88$TypeMatch:
  mov r10, [rbp+048h]                                            ; add mutates first operand, so indirect via register
  add r10, [rbp-0198h]                                           ; + operator
  mov [rbp-01e8h], r10                                           ; store result
  mov qword ptr [rbp-01f0h], 000000015h                          ; store type
  mov r11, [rbp-01e8h]                                           ; value of end
  mov [rbp-01f8h], r11                                           ; (indirect via r11 because mov can't do memory-to-memory)
  mov r11, [rbp-01f0h]                                           ; type of end
  mov [rbp-0200h], r11                                           ; (indirect via r11 because mov can't do memory-to-memory)
  ; Line 46: while (fromCursor < end) { ...
  func$_moveBytes$while$top:
    mov rax, [rbp-0f0h]                                          ; load the dynamic type of fromCursor into rax
    lea r10, typeTable                                           ; move type table offset into r10
    add rax, r10                                                 ; adjust rax to point to the type table
    bt qword ptr [rax], 2                                        ; check that fromCursor is Integer'21
    jc func$_moveBytes$while$fromcursor$TypeMatch                ; skip next block if the type matches
      ; Error handling block for fromCursor
      ;  - print(operandTypeCheckFailureMessage)
      mov [rbp+018h], rcx                                        ; save rcx in shadow space
      mov [rbp+020h], rdx                                        ; save rdx in shadow space
      mov [rbp+028h], r8                                         ; save r8 in shadow space
      mov [rbp+030h], r9                                         ; save r9 in shadow space
      mov r11, offset operandTypeCheckFailureMessage             ; value of argument #1
      push r11                                                   ; (indirect via r11 because "operandTypeCheckFailureMessage" is an imm64)
      push 000000016h                                            ; type of argument #1
      lea r10, [rbp-0208h]                                       ; pointer to return value (and type, 8 bytes earlier)
      push r10                                                   ; (that pointer is the last value pushed to the stack)
      mov qword ptr r9, 0h                                       ; pointer to this
      mov qword ptr r8, 000000000h                               ; type of this
      mov qword ptr rdx, 0h                                      ; pointer to closure
      mov rcx, 1                                                 ; number of arguments
      sub rsp, 20h                                               ; allocate shadow space
      call offset func$__print                                   ; jump to subroutine
      add rsp, 038h                                              ; release shadow space and arguments
      mov rcx, [rbp+018h]                                        ; restore rcx from shadow space
      mov rdx, [rbp+020h]                                        ; restore rdx from shadow space
      mov r8, [rbp+028h]                                         ; restore r8 from shadow space
      mov r9, [rbp+030h]                                         ; restore r9 from shadow space
      ;  - exit(1)
      mov [rbp+018h], rcx                                        ; save rcx in shadow space
      mov [rbp+020h], rdx                                        ; save rdx in shadow space
      mov [rbp+028h], r8                                         ; save r8 in shadow space
      mov [rbp+030h], r9                                         ; save r9 in shadow space
      push 000000001h                                            ; value of argument #1
      push 000000015h                                            ; type of argument #1
      lea r10, [rbp-0218h]                                       ; pointer to return value (and type, 8 bytes earlier)
      push r10                                                   ; (that pointer is the last value pushed to the stack)
      mov qword ptr r9, 0h                                       ; pointer to this
      mov qword ptr r8, 000000000h                               ; type of this
      mov qword ptr rdx, 0h                                      ; pointer to closure
      mov rcx, 1                                                 ; number of arguments
      sub rsp, 20h                                               ; allocate shadow space
      call offset func$exit                                      ; jump to subroutine
      add rsp, 038h                                              ; release shadow space and arguments
      mov rcx, [rbp+018h]                                        ; restore rcx from shadow space
      mov rdx, [rbp+020h]                                        ; restore rdx from shadow space
      mov r8, [rbp+028h]                                         ; restore r8 from shadow space
      mov r9, [rbp+030h]                                         ; restore r9 from shadow space
    func$_moveBytes$while$fromcursor$TypeMatch:
    mov rax, [rbp-0200h]                                         ; load the dynamic type of end into rax
    lea r10, typeTable                                           ; move type table offset into r10
    add rax, r10                                                 ; adjust rax to point to the type table
    bt qword ptr [rax], 2                                        ; check that end is Integer'21
    jc func$_moveBytes$while$end$TypeMatch                       ; skip next block if the type matches
      ; Error handling block for end
      ;  - print(operandTypeCheckFailureMessage)
      mov [rbp+018h], rcx                                        ; save rcx in shadow space
      mov [rbp+020h], rdx                                        ; save rdx in shadow space
      mov [rbp+028h], r8                                         ; save r8 in shadow space
      mov [rbp+030h], r9                                         ; save r9 in shadow space
      mov r11, offset operandTypeCheckFailureMessage             ; value of argument #1
      push r11                                                   ; (indirect via r11 because "operandTypeCheckFailureMessage" is an imm64)
      push 000000016h                                            ; type of argument #1
      lea r10, [rbp-0228h]                                       ; pointer to return value (and type, 8 bytes earlier)
      push r10                                                   ; (that pointer is the last value pushed to the stack)
      mov qword ptr r9, 0h                                       ; pointer to this
      mov qword ptr r8, 000000000h                               ; type of this
      mov qword ptr rdx, 0h                                      ; pointer to closure
      mov rcx, 1                                                 ; number of arguments
      sub rsp, 20h                                               ; allocate shadow space
      call offset func$__print                                   ; jump to subroutine
      add rsp, 038h                                              ; release shadow space and arguments
      mov rcx, [rbp+018h]                                        ; restore rcx from shadow space
      mov rdx, [rbp+020h]                                        ; restore rdx from shadow space
      mov r8, [rbp+028h]                                         ; restore r8 from shadow space
      mov r9, [rbp+030h]                                         ; restore r9 from shadow space
      ;  - exit(1)
      mov [rbp+018h], rcx                                        ; save rcx in shadow space
      mov [rbp+020h], rdx                                        ; save rdx in shadow space
      mov [rbp+028h], r8                                         ; save r8 in shadow space
      mov [rbp+030h], r9                                         ; save r9 in shadow space
      push 000000001h                                            ; value of argument #1
      push 000000015h                                            ; type of argument #1
      lea r10, [rbp-0238h]                                       ; pointer to return value (and type, 8 bytes earlier)
      push r10                                                   ; (that pointer is the last value pushed to the stack)
      mov qword ptr r9, 0h                                       ; pointer to this
      mov qword ptr r8, 000000000h                               ; type of this
      mov qword ptr rdx, 0h                                      ; pointer to closure
      mov rcx, 1                                                 ; number of arguments
      sub rsp, 20h                                               ; allocate shadow space
      call offset func$exit                                      ; jump to subroutine
      add rsp, 038h                                              ; release shadow space and arguments
      mov rcx, [rbp+018h]                                        ; restore rcx from shadow space
      mov rdx, [rbp+020h]                                        ; restore rdx from shadow space
      mov r8, [rbp+028h]                                         ; restore r8 from shadow space
      mov r9, [rbp+030h]                                         ; restore r9 from shadow space
    func$_moveBytes$while$end$TypeMatch:
    mov qword ptr [rbp-0248h], 000000000h                        ; clear < operator result
    mov r11, [rbp-0e8h]                                          ; compare fromCursor...
    cmp r11, [rbp-01f8h]                                         ; ...to end
    setl byte ptr [rbp-0248h]                                    ; store result in < operator result
    mov qword ptr [rbp-0250h], 000000014h                        ; < operator result is a Boolean
    cmp qword ptr [rbp-0248h], 000000000h                        ; compare < operator result to false
    je func$_moveBytes$while$bottom                              ; while condition
    ; Line 47: Integer value = __readFromAddress(fromCursor);
    mov r10, [rbp-0e8h]                                          ; value of fromCursor
    mov r11, [r10]                                               ; dereference fromCursor and put result in address of fromCursor
    mov [rbp-0258h], r11                                         ; (indirect via r11 because mov can't do memory-to-memory)
    mov qword ptr [rbp-0260h], 000000015h                        ; type of address of fromCursor
    mov r11, [rbp-0258h]                                         ; value of value
    mov [rbp-0268h], r11                                         ; (indirect via r11 because mov can't do memory-to-memory)
    mov r11, [rbp-0260h]                                         ; type of value
    mov [rbp-0270h], r11                                         ; (indirect via r11 because mov can't do memory-to-memory)
    ; Line 48: __writeToAddress(toCursor, value);
    mov r10, [rbp-0f8h]                                          ; value of toCursor
    mov r11, [rbp-0268h]                                         ; put value in toCursor
    mov [r10], r11                                               ; (indirect via r11 because mov can't do memory-to-memory)
    ; Line 49: fromCursor += 8;
    mov rax, [rbp-0f0h]                                          ; load the dynamic type of <fromCursor: Integer at null; compile-time constant> into rax
    lea r10, typeTable                                           ; move type table offset into r10
    add rax, r10                                                 ; adjust rax to point to the type table
    bt qword ptr [rax], 2                                        ; check that <fromCursor: Integer at null; compile-time constant> is Integer'21
    jc func$_moveBytes$while$FromcursorINtegerAtNullCompileTimeConstant$TypeMatch ; skip next block if the type matches
      ; Error handling block for <fromCursor: Integer at null; compile-time constant>
      ;  - print(operandTypeCheckFailureMessage)
      mov [rbp+018h], rcx                                        ; save rcx in shadow space
      mov [rbp+020h], rdx                                        ; save rdx in shadow space
      mov [rbp+028h], r8                                         ; save r8 in shadow space
      mov [rbp+030h], r9                                         ; save r9 in shadow space
      mov r11, offset operandTypeCheckFailureMessage             ; value of argument #1
      push r11                                                   ; (indirect via r11 because "operandTypeCheckFailureMessage" is an imm64)
      push 000000016h                                            ; type of argument #1
      lea r10, [rbp-0288h]                                       ; pointer to return value (and type, 8 bytes earlier)
      push r10                                                   ; (that pointer is the last value pushed to the stack)
      mov qword ptr r9, 0h                                       ; pointer to this
      mov qword ptr r8, 000000000h                               ; type of this
      mov qword ptr rdx, 0h                                      ; pointer to closure
      mov rcx, 1                                                 ; number of arguments
      sub rsp, 20h                                               ; allocate shadow space
      call offset func$__print                                   ; jump to subroutine
      add rsp, 038h                                              ; release shadow space and arguments
      mov rcx, [rbp+018h]                                        ; restore rcx from shadow space
      mov rdx, [rbp+020h]                                        ; restore rdx from shadow space
      mov r8, [rbp+028h]                                         ; restore r8 from shadow space
      mov r9, [rbp+030h]                                         ; restore r9 from shadow space
      ;  - exit(1)
      mov [rbp+018h], rcx                                        ; save rcx in shadow space
      mov [rbp+020h], rdx                                        ; save rdx in shadow space
      mov [rbp+028h], r8                                         ; save r8 in shadow space
      mov [rbp+030h], r9                                         ; save r9 in shadow space
      push 000000001h                                            ; value of argument #1
      push 000000015h                                            ; type of argument #1
      lea r10, [rbp-0298h]                                       ; pointer to return value (and type, 8 bytes earlier)
      push r10                                                   ; (that pointer is the last value pushed to the stack)
      mov qword ptr r9, 0h                                       ; pointer to this
      mov qword ptr r8, 000000000h                               ; type of this
      mov qword ptr rdx, 0h                                      ; pointer to closure
      mov rcx, 1                                                 ; number of arguments
      sub rsp, 20h                                               ; allocate shadow space
      call offset func$exit                                      ; jump to subroutine
      add rsp, 038h                                              ; release shadow space and arguments
      mov rcx, [rbp+018h]                                        ; restore rcx from shadow space
      mov rdx, [rbp+020h]                                        ; restore rdx from shadow space
      mov r8, [rbp+028h]                                         ; restore r8 from shadow space
      mov r9, [rbp+030h]                                         ; restore r9 from shadow space
    func$_moveBytes$while$FromcursorINtegerAtNullCompileTimeConstant$TypeMatch:
    mov r10, [rbp-0e8h]                                          ; add mutates first operand, so indirect via register
    add r10, 000000008h                                          ; += operator
    mov [rbp-0278h], r10                                         ; store result
    mov qword ptr [rbp-0280h], 000000015h                        ; store type
    mov r11, [rbp-0278h]                                         ; value of fromCursor
    mov [rbp-0e8h], r11                                          ; (indirect via r11 because mov can't do memory-to-memory)
    mov r11, [rbp-0280h]                                         ; type of fromCursor
    mov [rbp-0f0h], r11                                          ; (indirect via r11 because mov can't do memory-to-memory)
    ; Line 50: toCursor += 8;
    mov rax, [rbp-0100h]                                         ; load the dynamic type of <toCursor: Integer at null; compile-time constant> into rax
    lea r10, typeTable                                           ; move type table offset into r10
    add rax, r10                                                 ; adjust rax to point to the type table
    bt qword ptr [rax], 2                                        ; check that <toCursor: Integer at null; compile-time constant> is Integer'21
    jc func$_moveBytes$while$TocursorINtegerAtNullCompileTimeConstant$TypeMatch ; skip next block if the type matches
      ; Error handling block for <toCursor: Integer at null; compile-time constant>
      ;  - print(operandTypeCheckFailureMessage)
      mov [rbp+018h], rcx                                        ; save rcx in shadow space
      mov [rbp+020h], rdx                                        ; save rdx in shadow space
      mov [rbp+028h], r8                                         ; save r8 in shadow space
      mov [rbp+030h], r9                                         ; save r9 in shadow space
      mov r11, offset operandTypeCheckFailureMessage             ; value of argument #1
      push r11                                                   ; (indirect via r11 because "operandTypeCheckFailureMessage" is an imm64)
      push 000000016h                                            ; type of argument #1
      lea r10, [rbp-02d8h]                                       ; pointer to return value (and type, 8 bytes earlier)
      push r10                                                   ; (that pointer is the last value pushed to the stack)
      mov qword ptr r9, 0h                                       ; pointer to this
      mov qword ptr r8, 000000000h                               ; type of this
      mov qword ptr rdx, 0h                                      ; pointer to closure
      mov rcx, 1                                                 ; number of arguments
      sub rsp, 20h                                               ; allocate shadow space
      call offset func$__print                                   ; jump to subroutine
      add rsp, 038h                                              ; release shadow space and arguments
      mov rcx, [rbp+018h]                                        ; restore rcx from shadow space
      mov rdx, [rbp+020h]                                        ; restore rdx from shadow space
      mov r8, [rbp+028h]                                         ; restore r8 from shadow space
      mov r9, [rbp+030h]                                         ; restore r9 from shadow space
      ;  - exit(1)
      mov [rbp+018h], rcx                                        ; save rcx in shadow space
      mov [rbp+020h], rdx                                        ; save rdx in shadow space
      mov [rbp+028h], r8                                         ; save r8 in shadow space
      mov [rbp+030h], r9                                         ; save r9 in shadow space
      push 000000001h                                            ; value of argument #1
      push 000000015h                                            ; type of argument #1
      lea r10, [rbp-02e8h]                                       ; pointer to return value (and type, 8 bytes earlier)
      push r10                                                   ; (that pointer is the last value pushed to the stack)
      mov qword ptr r9, 0h                                       ; pointer to this
      mov qword ptr r8, 000000000h                               ; type of this
      mov qword ptr rdx, 0h                                      ; pointer to closure
      mov rcx, 1                                                 ; number of arguments
      sub rsp, 20h                                               ; allocate shadow space
      call offset func$exit                                      ; jump to subroutine
      add rsp, 038h                                              ; release shadow space and arguments
      mov rcx, [rbp+018h]                                        ; restore rcx from shadow space
      mov rdx, [rbp+020h]                                        ; restore rdx from shadow space
      mov r8, [rbp+028h]                                         ; restore r8 from shadow space
      mov r9, [rbp+030h]                                         ; restore r9 from shadow space
    func$_moveBytes$while$TocursorINtegerAtNullCompileTimeConstant$TypeMatch:
    mov r10, [rbp-0f8h]                                          ; add mutates first operand, so indirect via register
    add r10, 000000008h                                          ; += operator
    mov [rbp-02c8h], r10                                         ; store result
    mov qword ptr [rbp-02d0h], 000000015h                        ; store type
    mov r11, [rbp-02c8h]                                         ; value of toCursor
    mov [rbp-0f8h], r11                                          ; (indirect via r11 because mov can't do memory-to-memory)
    mov r11, [rbp-02d0h]                                         ; type of toCursor
    mov [rbp-0100h], r11                                         ; (indirect via r11 because mov can't do memory-to-memory)
    jmp func$_moveBytes$while$top                                ; return to top of while
  func$_moveBytes$while$bottom:
  ; Line 52: end = from + length;
  mov rax, [rbp+040h]                                            ; load the dynamic type of from into rax
  lea r10, typeTable                                             ; move type table offset into r10
  add rax, r10                                                   ; adjust rax to point to the type table
  bt qword ptr [rax], 2                                          ; check that from is Integer'21
  jc func$_moveBytes$from$TypeMatch$2                            ; skip next block if the type matches
    ; Error handling block for from
    ;  - print(operandTypeCheckFailureMessage)
    mov [rbp+018h], rcx                                          ; save rcx in shadow space
    mov [rbp+020h], rdx                                          ; save rdx in shadow space
    mov [rbp+028h], r8                                           ; save r8 in shadow space
    mov [rbp+030h], r9                                           ; save r9 in shadow space
    mov r11, offset operandTypeCheckFailureMessage               ; value of argument #1
    push r11                                                     ; (indirect via r11 because "operandTypeCheckFailureMessage" is an imm64)
    push 000000016h                                              ; type of argument #1
    lea r10, [rbp-0318h]                                         ; pointer to return value (and type, 8 bytes earlier)
    push r10                                                     ; (that pointer is the last value pushed to the stack)
    mov qword ptr r9, 0h                                         ; pointer to this
    mov qword ptr r8, 000000000h                                 ; type of this
    mov qword ptr rdx, 0h                                        ; pointer to closure
    mov rcx, 1                                                   ; number of arguments
    sub rsp, 20h                                                 ; allocate shadow space
    call offset func$__print                                     ; jump to subroutine
    add rsp, 038h                                                ; release shadow space and arguments
    mov rcx, [rbp+018h]                                          ; restore rcx from shadow space
    mov rdx, [rbp+020h]                                          ; restore rdx from shadow space
    mov r8, [rbp+028h]                                           ; restore r8 from shadow space
    mov r9, [rbp+030h]                                           ; restore r9 from shadow space
    ;  - exit(1)
    mov [rbp+018h], rcx                                          ; save rcx in shadow space
    mov [rbp+020h], rdx                                          ; save rdx in shadow space
    mov [rbp+028h], r8                                           ; save r8 in shadow space
    mov [rbp+030h], r9                                           ; save r9 in shadow space
    push 000000001h                                              ; value of argument #1
    push 000000015h                                              ; type of argument #1
    lea r10, [rbp-0328h]                                         ; pointer to return value (and type, 8 bytes earlier)
    push r10                                                     ; (that pointer is the last value pushed to the stack)
    mov qword ptr r9, 0h                                         ; pointer to this
    mov qword ptr r8, 000000000h                                 ; type of this
    mov qword ptr rdx, 0h                                        ; pointer to closure
    mov rcx, 1                                                   ; number of arguments
    sub rsp, 20h                                                 ; allocate shadow space
    call offset func$exit                                        ; jump to subroutine
    add rsp, 038h                                                ; release shadow space and arguments
    mov rcx, [rbp+018h]                                          ; restore rcx from shadow space
    mov rdx, [rbp+020h]                                          ; restore rdx from shadow space
    mov r8, [rbp+028h]                                           ; restore r8 from shadow space
    mov r9, [rbp+030h]                                           ; restore r9 from shadow space
  func$_moveBytes$from$TypeMatch$2:
  mov rax, [rbp+060h]                                            ; load the dynamic type of length into rax
  lea r10, typeTable                                             ; move type table offset into r10
  add rax, r10                                                   ; adjust rax to point to the type table
  bt qword ptr [rax], 2                                          ; check that length is Integer'21
  jc func$_moveBytes$length$TypeMatch$3                          ; skip next block if the type matches
    ; Error handling block for length
    ;  - print(operandTypeCheckFailureMessage)
    mov [rbp+018h], rcx                                          ; save rcx in shadow space
    mov [rbp+020h], rdx                                          ; save rdx in shadow space
    mov [rbp+028h], r8                                           ; save r8 in shadow space
    mov [rbp+030h], r9                                           ; save r9 in shadow space
    mov r11, offset operandTypeCheckFailureMessage               ; value of argument #1
    push r11                                                     ; (indirect via r11 because "operandTypeCheckFailureMessage" is an imm64)
    push 000000016h                                              ; type of argument #1
    lea r10, [rbp-0338h]                                         ; pointer to return value (and type, 8 bytes earlier)
    push r10                                                     ; (that pointer is the last value pushed to the stack)
    mov qword ptr r9, 0h                                         ; pointer to this
    mov qword ptr r8, 000000000h                                 ; type of this
    mov qword ptr rdx, 0h                                        ; pointer to closure
    mov rcx, 1                                                   ; number of arguments
    sub rsp, 20h                                                 ; allocate shadow space
    call offset func$__print                                     ; jump to subroutine
    add rsp, 038h                                                ; release shadow space and arguments
    mov rcx, [rbp+018h]                                          ; restore rcx from shadow space
    mov rdx, [rbp+020h]                                          ; restore rdx from shadow space
    mov r8, [rbp+028h]                                           ; restore r8 from shadow space
    mov r9, [rbp+030h]                                           ; restore r9 from shadow space
    ;  - exit(1)
    mov [rbp+018h], rcx                                          ; save rcx in shadow space
    mov [rbp+020h], rdx                                          ; save rdx in shadow space
    mov [rbp+028h], r8                                           ; save r8 in shadow space
    mov [rbp+030h], r9                                           ; save r9 in shadow space
    push 000000001h                                              ; value of argument #1
    push 000000015h                                              ; type of argument #1
    lea r10, [rbp-0348h]                                         ; pointer to return value (and type, 8 bytes earlier)
    push r10                                                     ; (that pointer is the last value pushed to the stack)
    mov qword ptr r9, 0h                                         ; pointer to this
    mov qword ptr r8, 000000000h                                 ; type of this
    mov qword ptr rdx, 0h                                        ; pointer to closure
    mov rcx, 1                                                   ; number of arguments
    sub rsp, 20h                                                 ; allocate shadow space
    call offset func$exit                                        ; jump to subroutine
    add rsp, 038h                                                ; release shadow space and arguments
    mov rcx, [rbp+018h]                                          ; restore rcx from shadow space
    mov rdx, [rbp+020h]                                          ; restore rdx from shadow space
    mov r8, [rbp+028h]                                           ; restore r8 from shadow space
    mov r9, [rbp+030h]                                           ; restore r9 from shadow space
  func$_moveBytes$length$TypeMatch$3:
  mov r10, [rbp+048h]                                            ; add mutates first operand, so indirect via register
  add r10, [rbp+068h]                                            ; + operator
  mov [rbp-0358h], r10                                           ; store result
  mov qword ptr [rbp-0360h], 000000015h                          ; store type
  mov r11, [rbp-0358h]                                           ; value of end
  mov [rbp-01f8h], r11                                           ; (indirect via r11 because mov can't do memory-to-memory)
  mov r11, [rbp-0360h]                                           ; type of end
  mov [rbp-0200h], r11                                           ; (indirect via r11 because mov can't do memory-to-memory)
  ; Line 53: if (fromCursor < end) { ...
  mov rax, [rbp-0f0h]                                            ; load the dynamic type of fromCursor into rax
  lea r10, typeTable                                             ; move type table offset into r10
  add rax, r10                                                   ; adjust rax to point to the type table
  bt qword ptr [rax], 2                                          ; check that fromCursor is Integer'21
  jc func$_moveBytes$fromcursor$TypeMatch                        ; skip next block if the type matches
    ; Error handling block for fromCursor
    ;  - print(operandTypeCheckFailureMessage)
    mov [rbp+018h], rcx                                          ; save rcx in shadow space
    mov [rbp+020h], rdx                                          ; save rdx in shadow space
    mov [rbp+028h], r8                                           ; save r8 in shadow space
    mov [rbp+030h], r9                                           ; save r9 in shadow space
    mov r11, offset operandTypeCheckFailureMessage               ; value of argument #1
    push r11                                                     ; (indirect via r11 because "operandTypeCheckFailureMessage" is an imm64)
    push 000000016h                                              ; type of argument #1
    lea r10, [rbp-0368h]                                         ; pointer to return value (and type, 8 bytes earlier)
    push r10                                                     ; (that pointer is the last value pushed to the stack)
    mov qword ptr r9, 0h                                         ; pointer to this
    mov qword ptr r8, 000000000h                                 ; type of this
    mov qword ptr rdx, 0h                                        ; pointer to closure
    mov rcx, 1                                                   ; number of arguments
    sub rsp, 20h                                                 ; allocate shadow space
    call offset func$__print                                     ; jump to subroutine
    add rsp, 038h                                                ; release shadow space and arguments
    mov rcx, [rbp+018h]                                          ; restore rcx from shadow space
    mov rdx, [rbp+020h]                                          ; restore rdx from shadow space
    mov r8, [rbp+028h]                                           ; restore r8 from shadow space
    mov r9, [rbp+030h]                                           ; restore r9 from shadow space
    ;  - exit(1)
    mov [rbp+018h], rcx                                          ; save rcx in shadow space
    mov [rbp+020h], rdx                                          ; save rdx in shadow space
    mov [rbp+028h], r8                                           ; save r8 in shadow space
    mov [rbp+030h], r9                                           ; save r9 in shadow space
    push 000000001h                                              ; value of argument #1
    push 000000015h                                              ; type of argument #1
    lea r10, [rbp-0378h]                                         ; pointer to return value (and type, 8 bytes earlier)
    push r10                                                     ; (that pointer is the last value pushed to the stack)
    mov qword ptr r9, 0h                                         ; pointer to this
    mov qword ptr r8, 000000000h                                 ; type of this
    mov qword ptr rdx, 0h                                        ; pointer to closure
    mov rcx, 1                                                   ; number of arguments
    sub rsp, 20h                                                 ; allocate shadow space
    call offset func$exit                                        ; jump to subroutine
    add rsp, 038h                                                ; release shadow space and arguments
    mov rcx, [rbp+018h]                                          ; restore rcx from shadow space
    mov rdx, [rbp+020h]                                          ; restore rdx from shadow space
    mov r8, [rbp+028h]                                           ; restore r8 from shadow space
    mov r9, [rbp+030h]                                           ; restore r9 from shadow space
  func$_moveBytes$fromcursor$TypeMatch:
  mov rax, [rbp-0200h]                                           ; load the dynamic type of end into rax
  lea r10, typeTable                                             ; move type table offset into r10
  add rax, r10                                                   ; adjust rax to point to the type table
  bt qword ptr [rax], 2                                          ; check that end is Integer'21
  jc func$_moveBytes$end$TypeMatch                               ; skip next block if the type matches
    ; Error handling block for end
    ;  - print(operandTypeCheckFailureMessage)
    mov [rbp+018h], rcx                                          ; save rcx in shadow space
    mov [rbp+020h], rdx                                          ; save rdx in shadow space
    mov [rbp+028h], r8                                           ; save r8 in shadow space
    mov [rbp+030h], r9                                           ; save r9 in shadow space
    mov r11, offset operandTypeCheckFailureMessage               ; value of argument #1
    push r11                                                     ; (indirect via r11 because "operandTypeCheckFailureMessage" is an imm64)
    push 000000016h                                              ; type of argument #1
    lea r10, [rbp-0388h]                                         ; pointer to return value (and type, 8 bytes earlier)
    push r10                                                     ; (that pointer is the last value pushed to the stack)
    mov qword ptr r9, 0h                                         ; pointer to this
    mov qword ptr r8, 000000000h                                 ; type of this
    mov qword ptr rdx, 0h                                        ; pointer to closure
    mov rcx, 1                                                   ; number of arguments
    sub rsp, 20h                                                 ; allocate shadow space
    call offset func$__print                                     ; jump to subroutine
    add rsp, 038h                                                ; release shadow space and arguments
    mov rcx, [rbp+018h]                                          ; restore rcx from shadow space
    mov rdx, [rbp+020h]                                          ; restore rdx from shadow space
    mov r8, [rbp+028h]                                           ; restore r8 from shadow space
    mov r9, [rbp+030h]                                           ; restore r9 from shadow space
    ;  - exit(1)
    mov [rbp+018h], rcx                                          ; save rcx in shadow space
    mov [rbp+020h], rdx                                          ; save rdx in shadow space
    mov [rbp+028h], r8                                           ; save r8 in shadow space
    mov [rbp+030h], r9                                           ; save r9 in shadow space
    push 000000001h                                              ; value of argument #1
    push 000000015h                                              ; type of argument #1
    lea r10, [rbp-0398h]                                         ; pointer to return value (and type, 8 bytes earlier)
    push r10                                                     ; (that pointer is the last value pushed to the stack)
    mov qword ptr r9, 0h                                         ; pointer to this
    mov qword ptr r8, 000000000h                                 ; type of this
    mov qword ptr rdx, 0h                                        ; pointer to closure
    mov rcx, 1                                                   ; number of arguments
    sub rsp, 20h                                                 ; allocate shadow space
    call offset func$exit                                        ; jump to subroutine
    add rsp, 038h                                                ; release shadow space and arguments
    mov rcx, [rbp+018h]                                          ; restore rcx from shadow space
    mov rdx, [rbp+020h]                                          ; restore rdx from shadow space
    mov r8, [rbp+028h]                                           ; restore r8 from shadow space
    mov r9, [rbp+030h]                                           ; restore r9 from shadow space
  func$_moveBytes$end$TypeMatch:
  mov qword ptr [rbp-03a8h], 000000000h                          ; clear < operator result
  mov r11, [rbp-0e8h]                                            ; compare fromCursor...
  cmp r11, [rbp-01f8h]                                           ; ...to end
  setl byte ptr [rbp-03a8h]                                      ; store result in < operator result
  mov qword ptr [rbp-03b0h], 000000014h                          ; < operator result is a Boolean
  cmp qword ptr [rbp-03a8h], 000000000h                          ; compare < operator result to false
  je func$_moveBytes$if$continuation                             ; fromCursor < end
    ; Line 54: Integer newValue = __readFromAddress(fromCursor);
    mov r10, [rbp-0e8h]                                          ; value of fromCursor
    mov r11, [r10]                                               ; dereference fromCursor and put result in address of fromCursor
    mov [rbp-03b8h], r11                                         ; (indirect via r11 because mov can't do memory-to-memory)
    mov qword ptr [rbp-03c0h], 000000015h                        ; type of address of fromCursor
    mov r11, [rbp-03b8h]                                         ; value of newValue
    mov [rbp-03c8h], r11                                         ; (indirect via r11 because mov can't do memory-to-memory)
    mov r11, [rbp-03c0h]                                         ; type of newValue
    mov [rbp-03d0h], r11                                         ; (indirect via r11 because mov can't do memory-to-memory)
    ; Line 55: Integer oldValue = __readFromAddress(toCursor);
    mov r10, [rbp-0f8h]                                          ; value of toCursor
    mov r11, [r10]                                               ; dereference toCursor and put result in address of toCursor
    mov [rbp-03d8h], r11                                         ; (indirect via r11 because mov can't do memory-to-memory)
    mov qword ptr [rbp-03e0h], 000000015h                        ; type of address of toCursor
    mov r11, [rbp-03d8h]                                         ; value of oldValue
    mov [rbp-03e8h], r11                                         ; (indirect via r11 because mov can't do memory-to-memory)
    mov r11, [rbp-03e0h]                                         ; type of oldValue
    mov [rbp-03f0h], r11                                         ; (indirect via r11 because mov can't do memory-to-memory)
    ; Line 56: Integer extraBytes = end - fromCursor;
    mov rax, [rbp-0200h]                                         ; load the dynamic type of end into rax
    lea r10, typeTable                                           ; move type table offset into r10
    add rax, r10                                                 ; adjust rax to point to the type table
    bt qword ptr [rax], 2                                        ; check that end is Integer'21
    jc func$_moveBytes$Movebytes$if$block$end$TypeMatch          ; skip next block if the type matches
      ; Error handling block for end
      ;  - print(operandTypeCheckFailureMessage)
      mov [rbp+018h], rcx                                        ; save rcx in shadow space
      mov [rbp+020h], rdx                                        ; save rdx in shadow space
      mov [rbp+028h], r8                                         ; save r8 in shadow space
      mov [rbp+030h], r9                                         ; save r9 in shadow space
      mov r11, offset operandTypeCheckFailureMessage             ; value of argument #1
      push r11                                                   ; (indirect via r11 because "operandTypeCheckFailureMessage" is an imm64)
      push 000000016h                                            ; type of argument #1
      lea r10, [rbp-03f8h]                                       ; pointer to return value (and type, 8 bytes earlier)
      push r10                                                   ; (that pointer is the last value pushed to the stack)
      mov qword ptr r9, 0h                                       ; pointer to this
      mov qword ptr r8, 000000000h                               ; type of this
      mov qword ptr rdx, 0h                                      ; pointer to closure
      mov rcx, 1                                                 ; number of arguments
      sub rsp, 20h                                               ; allocate shadow space
      call offset func$__print                                   ; jump to subroutine
      add rsp, 038h                                              ; release shadow space and arguments
      mov rcx, [rbp+018h]                                        ; restore rcx from shadow space
      mov rdx, [rbp+020h]                                        ; restore rdx from shadow space
      mov r8, [rbp+028h]                                         ; restore r8 from shadow space
      mov r9, [rbp+030h]                                         ; restore r9 from shadow space
      ;  - exit(1)
      mov [rbp+018h], rcx                                        ; save rcx in shadow space
      mov [rbp+020h], rdx                                        ; save rdx in shadow space
      mov [rbp+028h], r8                                         ; save r8 in shadow space
      mov [rbp+030h], r9                                         ; save r9 in shadow space
      push 000000001h                                            ; value of argument #1
      push 000000015h                                            ; type of argument #1
      lea r10, [rbp-0408h]                                       ; pointer to return value (and type, 8 bytes earlier)
      push r10                                                   ; (that pointer is the last value pushed to the stack)
      mov qword ptr r9, 0h                                       ; pointer to this
      mov qword ptr r8, 000000000h                               ; type of this
      mov qword ptr rdx, 0h                                      ; pointer to closure
      mov rcx, 1                                                 ; number of arguments
      sub rsp, 20h                                               ; allocate shadow space
      call offset func$exit                                      ; jump to subroutine
      add rsp, 038h                                              ; release shadow space and arguments
      mov rcx, [rbp+018h]                                        ; restore rcx from shadow space
      mov rdx, [rbp+020h]                                        ; restore rdx from shadow space
      mov r8, [rbp+028h]                                         ; restore r8 from shadow space
      mov r9, [rbp+030h]                                         ; restore r9 from shadow space
    func$_moveBytes$Movebytes$if$block$end$TypeMatch:
    mov rax, [rbp-0f0h]                                          ; load the dynamic type of fromCursor into rax
    lea r10, typeTable                                           ; move type table offset into r10
    add rax, r10                                                 ; adjust rax to point to the type table
    bt qword ptr [rax], 2                                        ; check that fromCursor is Integer'21
    jc func$_moveBytes$Movebytes$if$block$fromcursor$TypeMatch   ; skip next block if the type matches
      ; Error handling block for fromCursor
      ;  - print(operandTypeCheckFailureMessage)
      mov [rbp+018h], rcx                                        ; save rcx in shadow space
      mov [rbp+020h], rdx                                        ; save rdx in shadow space
      mov [rbp+028h], r8                                         ; save r8 in shadow space
      mov [rbp+030h], r9                                         ; save r9 in shadow space
      mov r11, offset operandTypeCheckFailureMessage             ; value of argument #1
      push r11                                                   ; (indirect via r11 because "operandTypeCheckFailureMessage" is an imm64)
      push 000000016h                                            ; type of argument #1
      lea r10, [rbp-0418h]                                       ; pointer to return value (and type, 8 bytes earlier)
      push r10                                                   ; (that pointer is the last value pushed to the stack)
      mov qword ptr r9, 0h                                       ; pointer to this
      mov qword ptr r8, 000000000h                               ; type of this
      mov qword ptr rdx, 0h                                      ; pointer to closure
      mov rcx, 1                                                 ; number of arguments
      sub rsp, 20h                                               ; allocate shadow space
      call offset func$__print                                   ; jump to subroutine
      add rsp, 038h                                              ; release shadow space and arguments
      mov rcx, [rbp+018h]                                        ; restore rcx from shadow space
      mov rdx, [rbp+020h]                                        ; restore rdx from shadow space
      mov r8, [rbp+028h]                                         ; restore r8 from shadow space
      mov r9, [rbp+030h]                                         ; restore r9 from shadow space
      ;  - exit(1)
      mov [rbp+018h], rcx                                        ; save rcx in shadow space
      mov [rbp+020h], rdx                                        ; save rdx in shadow space
      mov [rbp+028h], r8                                         ; save r8 in shadow space
      mov [rbp+030h], r9                                         ; save r9 in shadow space
      push 000000001h                                            ; value of argument #1
      push 000000015h                                            ; type of argument #1
      lea r10, [rbp-0428h]                                       ; pointer to return value (and type, 8 bytes earlier)
      push r10                                                   ; (that pointer is the last value pushed to the stack)
      mov qword ptr r9, 0h                                       ; pointer to this
      mov qword ptr r8, 000000000h                               ; type of this
      mov qword ptr rdx, 0h                                      ; pointer to closure
      mov rcx, 1                                                 ; number of arguments
      sub rsp, 20h                                               ; allocate shadow space
      call offset func$exit                                      ; jump to subroutine
      add rsp, 038h                                              ; release shadow space and arguments
      mov rcx, [rbp+018h]                                        ; restore rcx from shadow space
      mov rdx, [rbp+020h]                                        ; restore rdx from shadow space
      mov r8, [rbp+028h]                                         ; restore r8 from shadow space
      mov r9, [rbp+030h]                                         ; restore r9 from shadow space
    func$_moveBytes$Movebytes$if$block$fromcursor$TypeMatch:
    mov r10, [rbp-01f8h]                                         ; sub mutates first operand, so indirect via register
    sub r10, [rbp-0e8h]                                          ; - operator
    mov [rbp-0438h], r10                                         ; store result
    mov qword ptr [rbp-0440h], 000000015h                        ; store type
    mov r11, [rbp-0438h]                                         ; value of extraBytes
    mov [rbp-0448h], r11                                         ; (indirect via r11 because mov can't do memory-to-memory)
    mov r11, [rbp-0440h]                                         ; type of extraBytes
    mov [rbp-0450h], r11                                         ; (indirect via r11 because mov can't do memory-to-memory)
    ; Line 57: assert(extraBytes > 0, 'internal error: zero extra bytes but fro...
    mov rax, [rbp-0450h]                                         ; load the dynamic type of extraBytes into rax
    lea r10, typeTable                                           ; move type table offset into r10
    add rax, r10                                                 ; adjust rax to point to the type table
    bt qword ptr [rax], 2                                        ; check that extraBytes is Integer'21
    jc func$_moveBytes$Movebytes$if$block$extrabytes$TypeMatch   ; skip next block if the type matches
      ; Error handling block for extraBytes
      ;  - print(operandTypeCheckFailureMessage)
      mov [rbp+018h], rcx                                        ; save rcx in shadow space
      mov [rbp+020h], rdx                                        ; save rdx in shadow space
      mov [rbp+028h], r8                                         ; save r8 in shadow space
      mov [rbp+030h], r9                                         ; save r9 in shadow space
      mov r11, offset operandTypeCheckFailureMessage             ; value of argument #1
      push r11                                                   ; (indirect via r11 because "operandTypeCheckFailureMessage" is an imm64)
      push 000000016h                                            ; type of argument #1
      lea r10, [rbp-0458h]                                       ; pointer to return value (and type, 8 bytes earlier)
      push r10                                                   ; (that pointer is the last value pushed to the stack)
      mov qword ptr r9, 0h                                       ; pointer to this
      mov qword ptr r8, 000000000h                               ; type of this
      mov qword ptr rdx, 0h                                      ; pointer to closure
      mov rcx, 1                                                 ; number of arguments
      sub rsp, 20h                                               ; allocate shadow space
      call offset func$__print                                   ; jump to subroutine
      add rsp, 038h                                              ; release shadow space and arguments
      mov rcx, [rbp+018h]                                        ; restore rcx from shadow space
      mov rdx, [rbp+020h]                                        ; restore rdx from shadow space
      mov r8, [rbp+028h]                                         ; restore r8 from shadow space
      mov r9, [rbp+030h]                                         ; restore r9 from shadow space
      ;  - exit(1)
      mov [rbp+018h], rcx                                        ; save rcx in shadow space
      mov [rbp+020h], rdx                                        ; save rdx in shadow space
      mov [rbp+028h], r8                                         ; save r8 in shadow space
      mov [rbp+030h], r9                                         ; save r9 in shadow space
      push 000000001h                                            ; value of argument #1
      push 000000015h                                            ; type of argument #1
      lea r10, [rbp-0468h]                                       ; pointer to return value (and type, 8 bytes earlier)
      push r10                                                   ; (that pointer is the last value pushed to the stack)
      mov qword ptr r9, 0h                                       ; pointer to this
      mov qword ptr r8, 000000000h                               ; type of this
      mov qword ptr rdx, 0h                                      ; pointer to closure
      mov rcx, 1                                                 ; number of arguments
      sub rsp, 20h                                               ; allocate shadow space
      call offset func$exit                                      ; jump to subroutine
      add rsp, 038h                                              ; release shadow space and arguments
      mov rcx, [rbp+018h]                                        ; restore rcx from shadow space
      mov rdx, [rbp+020h]                                        ; restore rdx from shadow space
      mov r8, [rbp+028h]                                         ; restore r8 from shadow space
      mov r9, [rbp+030h]                                         ; restore r9 from shadow space
    func$_moveBytes$Movebytes$if$block$extrabytes$TypeMatch:
    mov qword ptr [rbp-0498h], 000000000h                        ; clear > operator result
    cmp qword ptr [rbp-0448h], 000000000h                        ; compare extraBytes to 0
    setg byte ptr [rbp-0498h]                                    ; store result in > operator result
    mov qword ptr [rbp-04a0h], 000000014h                        ; > operator result is a Boolean
    mov [rbp+018h], rcx                                          ; save rcx in shadow space
    mov [rbp+020h], rdx                                          ; save rdx in shadow space
    mov [rbp+028h], r8                                           ; save r8 in shadow space
    mov [rbp+030h], r9                                           ; save r9 in shadow space
    mov r11, offset string$2                                     ; value of argument #2
    push r11                                                     ; (indirect via r11 because "string$2" is an imm64)
    push 000000016h                                              ; type of argument #2
    push [rbp-0498h]                                             ; value of argument #1
    push [rbp-04a0h]                                             ; type of argument #1
    lea r10, [rbp-04a8h]                                         ; pointer to return value (and type, 8 bytes earlier)
    push r10                                                     ; (that pointer is the last value pushed to the stack)
    mov qword ptr r9, 0h                                         ; pointer to this
    mov qword ptr r8, 000000000h                                 ; type of this
    mov qword ptr rdx, 0h                                        ; pointer to closure
    mov rcx, 2                                                   ; number of arguments
    sub rsp, 20h                                                 ; allocate shadow space
    call offset func$assert                                      ; jump to subroutine
    add rsp, 048h                                                ; release shadow space and arguments
    mov rcx, [rbp+018h]                                          ; restore rcx from shadow space
    mov rdx, [rbp+020h]                                          ; restore rdx from shadow space
    mov r8, [rbp+028h]                                           ; restore r8 from shadow space
    mov r9, [rbp+030h]                                           ; restore r9 from shadow space
    ; Line 58: assert(extraBytes < 8, 'internal error: more than 7 extra bytes'...
    mov rax, [rbp-0450h]                                         ; load the dynamic type of extraBytes into rax
    lea r10, typeTable                                           ; move type table offset into r10
    add rax, r10                                                 ; adjust rax to point to the type table
    bt qword ptr [rax], 2                                        ; check that extraBytes is Integer'21
    jc func$_moveBytes$Movebytes$if$block$extrabytes$TypeMatch$1 ; skip next block if the type matches
      ; Error handling block for extraBytes
      ;  - print(operandTypeCheckFailureMessage)
      mov [rbp+018h], rcx                                        ; save rcx in shadow space
      mov [rbp+020h], rdx                                        ; save rdx in shadow space
      mov [rbp+028h], r8                                         ; save r8 in shadow space
      mov [rbp+030h], r9                                         ; save r9 in shadow space
      mov r11, offset operandTypeCheckFailureMessage             ; value of argument #1
      push r11                                                   ; (indirect via r11 because "operandTypeCheckFailureMessage" is an imm64)
      push 000000016h                                            ; type of argument #1
      lea r10, [rbp-04b8h]                                       ; pointer to return value (and type, 8 bytes earlier)
      push r10                                                   ; (that pointer is the last value pushed to the stack)
      mov qword ptr r9, 0h                                       ; pointer to this
      mov qword ptr r8, 000000000h                               ; type of this
      mov qword ptr rdx, 0h                                      ; pointer to closure
      mov rcx, 1                                                 ; number of arguments
      sub rsp, 20h                                               ; allocate shadow space
      call offset func$__print                                   ; jump to subroutine
      add rsp, 038h                                              ; release shadow space and arguments
      mov rcx, [rbp+018h]                                        ; restore rcx from shadow space
      mov rdx, [rbp+020h]                                        ; restore rdx from shadow space
      mov r8, [rbp+028h]                                         ; restore r8 from shadow space
      mov r9, [rbp+030h]                                         ; restore r9 from shadow space
      ;  - exit(1)
      mov [rbp+018h], rcx                                        ; save rcx in shadow space
      mov [rbp+020h], rdx                                        ; save rdx in shadow space
      mov [rbp+028h], r8                                         ; save r8 in shadow space
      mov [rbp+030h], r9                                         ; save r9 in shadow space
      push 000000001h                                            ; value of argument #1
      push 000000015h                                            ; type of argument #1
      lea r10, [rbp-04c8h]                                       ; pointer to return value (and type, 8 bytes earlier)
      push r10                                                   ; (that pointer is the last value pushed to the stack)
      mov qword ptr r9, 0h                                       ; pointer to this
      mov qword ptr r8, 000000000h                               ; type of this
      mov qword ptr rdx, 0h                                      ; pointer to closure
      mov rcx, 1                                                 ; number of arguments
      sub rsp, 20h                                               ; allocate shadow space
      call offset func$exit                                      ; jump to subroutine
      add rsp, 038h                                              ; release shadow space and arguments
      mov rcx, [rbp+018h]                                        ; restore rcx from shadow space
      mov rdx, [rbp+020h]                                        ; restore rdx from shadow space
      mov r8, [rbp+028h]                                         ; restore r8 from shadow space
      mov r9, [rbp+030h]                                         ; restore r9 from shadow space
    func$_moveBytes$Movebytes$if$block$extrabytes$TypeMatch$1:
    mov qword ptr [rbp-04f8h], 000000000h                        ; clear < operator result
    cmp qword ptr [rbp-0448h], 000000008h                        ; compare extraBytes to 8
    setl byte ptr [rbp-04f8h]                                    ; store result in < operator result
    mov qword ptr [rbp-0500h], 000000014h                        ; < operator result is a Boolean
    mov [rbp+018h], rcx                                          ; save rcx in shadow space
    mov [rbp+020h], rdx                                          ; save rdx in shadow space
    mov [rbp+028h], r8                                           ; save r8 in shadow space
    mov [rbp+030h], r9                                           ; save r9 in shadow space
    mov r11, offset string$3                                     ; value of argument #2
    push r11                                                     ; (indirect via r11 because "string$3" is an imm64)
    push 000000016h                                              ; type of argument #2
    push [rbp-04f8h]                                             ; value of argument #1
    push [rbp-0500h]                                             ; type of argument #1
    lea r10, [rbp-0508h]                                         ; pointer to return value (and type, 8 bytes earlier)
    push r10                                                     ; (that pointer is the last value pushed to the stack)
    mov qword ptr r9, 0h                                         ; pointer to this
    mov qword ptr r8, 000000000h                                 ; type of this
    mov qword ptr rdx, 0h                                        ; pointer to closure
    mov rcx, 2                                                   ; number of arguments
    sub rsp, 20h                                                 ; allocate shadow space
    call offset func$assert                                      ; jump to subroutine
    add rsp, 048h                                                ; release shadow space and arguments
    mov rcx, [rbp+018h]                                          ; restore rcx from shadow space
    mov rdx, [rbp+020h]                                          ; restore rdx from shadow space
    mov r8, [rbp+028h]                                           ; restore r8 from shadow space
    mov r9, [rbp+030h]                                           ; restore r9 from shadow space
    ; Line 59: Integer mask = -1 << extraBytes * 8;
    mov rax, [rbp-0450h]                                         ; load the dynamic type of extraBytes into rax
    lea r10, typeTable                                           ; move type table offset into r10
    add rax, r10                                                 ; adjust rax to point to the type table
    bt qword ptr [rax], 2                                        ; check that extraBytes is Integer'21
    jc func$_moveBytes$Movebytes$if$block$extrabytes$TypeMatch$2 ; skip next block if the type matches
      ; Error handling block for extraBytes
      ;  - print(operandTypeCheckFailureMessage)
      mov [rbp+018h], rcx                                        ; save rcx in shadow space
      mov [rbp+020h], rdx                                        ; save rdx in shadow space
      mov [rbp+028h], r8                                         ; save r8 in shadow space
      mov [rbp+030h], r9                                         ; save r9 in shadow space
      mov r11, offset operandTypeCheckFailureMessage             ; value of argument #1
      push r11                                                   ; (indirect via r11 because "operandTypeCheckFailureMessage" is an imm64)
      push 000000016h                                            ; type of argument #1
      lea r10, [rbp-0518h]                                       ; pointer to return value (and type, 8 bytes earlier)
      push r10                                                   ; (that pointer is the last value pushed to the stack)
      mov qword ptr r9, 0h                                       ; pointer to this
      mov qword ptr r8, 000000000h                               ; type of this
      mov qword ptr rdx, 0h                                      ; pointer to closure
      mov rcx, 1                                                 ; number of arguments
      sub rsp, 20h                                               ; allocate shadow space
      call offset func$__print                                   ; jump to subroutine
      add rsp, 038h                                              ; release shadow space and arguments
      mov rcx, [rbp+018h]                                        ; restore rcx from shadow space
      mov rdx, [rbp+020h]                                        ; restore rdx from shadow space
      mov r8, [rbp+028h]                                         ; restore r8 from shadow space
      mov r9, [rbp+030h]                                         ; restore r9 from shadow space
      ;  - exit(1)
      mov [rbp+018h], rcx                                        ; save rcx in shadow space
      mov [rbp+020h], rdx                                        ; save rdx in shadow space
      mov [rbp+028h], r8                                         ; save r8 in shadow space
      mov [rbp+030h], r9                                         ; save r9 in shadow space
      push 000000001h                                            ; value of argument #1
      push 000000015h                                            ; type of argument #1
      lea r10, [rbp-0528h]                                       ; pointer to return value (and type, 8 bytes earlier)
      push r10                                                   ; (that pointer is the last value pushed to the stack)
      mov qword ptr r9, 0h                                       ; pointer to this
      mov qword ptr r8, 000000000h                               ; type of this
      mov qword ptr rdx, 0h                                      ; pointer to closure
      mov rcx, 1                                                 ; number of arguments
      sub rsp, 20h                                               ; allocate shadow space
      call offset func$exit                                      ; jump to subroutine
      add rsp, 038h                                              ; release shadow space and arguments
      mov rcx, [rbp+018h]                                        ; restore rcx from shadow space
      mov rdx, [rbp+020h]                                        ; restore rdx from shadow space
      mov r8, [rbp+028h]                                         ; restore r8 from shadow space
      mov r9, [rbp+030h]                                         ; restore r9 from shadow space
    func$_moveBytes$Movebytes$if$block$extrabytes$TypeMatch$2:
    mov r10, [rbp-0448h]                                         ; imul mutates first operand, so indirect via register
    imul r10, 000000008h                                         ; * operator
    mov [rbp-0558h], r10                                         ; store result
    mov qword ptr [rbp-0560h], 000000015h                        ; store type
    mov rax, [rbp-0560h]                                         ; load the dynamic type of extraBytes * 8 into rax
    lea r10, typeTable                                           ; move type table offset into r10
    add rax, r10                                                 ; adjust rax to point to the type table
    bt qword ptr [rax], 2                                        ; check that extraBytes * 8 is Integer'21
    jc func$_moveBytes$Movebytes$if$block$extrabytes8$TypeMatch  ; skip next block if the type matches
      ; Error handling block for extraBytes * 8
      ;  - print(operandTypeCheckFailureMessage)
      mov [rbp+018h], rcx                                        ; save rcx in shadow space
      mov [rbp+020h], rdx                                        ; save rdx in shadow space
      mov [rbp+028h], r8                                         ; save r8 in shadow space
      mov [rbp+030h], r9                                         ; save r9 in shadow space
      mov r11, offset operandTypeCheckFailureMessage             ; value of argument #1
      push r11                                                   ; (indirect via r11 because "operandTypeCheckFailureMessage" is an imm64)
      push 000000016h                                            ; type of argument #1
      lea r10, [rbp-0588h]                                       ; pointer to return value (and type, 8 bytes earlier)
      push r10                                                   ; (that pointer is the last value pushed to the stack)
      mov qword ptr r9, 0h                                       ; pointer to this
      mov qword ptr r8, 000000000h                               ; type of this
      mov qword ptr rdx, 0h                                      ; pointer to closure
      mov rcx, 1                                                 ; number of arguments
      sub rsp, 20h                                               ; allocate shadow space
      call offset func$__print                                   ; jump to subroutine
      add rsp, 038h                                              ; release shadow space and arguments
      mov rcx, [rbp+018h]                                        ; restore rcx from shadow space
      mov rdx, [rbp+020h]                                        ; restore rdx from shadow space
      mov r8, [rbp+028h]                                         ; restore r8 from shadow space
      mov r9, [rbp+030h]                                         ; restore r9 from shadow space
      ;  - exit(1)
      mov [rbp+018h], rcx                                        ; save rcx in shadow space
      mov [rbp+020h], rdx                                        ; save rdx in shadow space
      mov [rbp+028h], r8                                         ; save r8 in shadow space
      mov [rbp+030h], r9                                         ; save r9 in shadow space
      push 000000001h                                            ; value of argument #1
      push 000000015h                                            ; type of argument #1
      lea r10, [rbp-0598h]                                       ; pointer to return value (and type, 8 bytes earlier)
      push r10                                                   ; (that pointer is the last value pushed to the stack)
      mov qword ptr r9, 0h                                       ; pointer to this
      mov qword ptr r8, 000000000h                               ; type of this
      mov qword ptr rdx, 0h                                      ; pointer to closure
      mov rcx, 1                                                 ; number of arguments
      sub rsp, 20h                                               ; allocate shadow space
      call offset func$exit                                      ; jump to subroutine
      add rsp, 038h                                              ; release shadow space and arguments
      mov rcx, [rbp+018h]                                        ; restore rcx from shadow space
      mov rdx, [rbp+020h]                                        ; restore rdx from shadow space
      mov r8, [rbp+028h]                                         ; restore r8 from shadow space
      mov r9, [rbp+030h]                                         ; restore r9 from shadow space
    func$_moveBytes$Movebytes$if$block$extrabytes8$TypeMatch:
    mov qword ptr r10, -000000001h                               ; shl mutates first operand, so indirect via register
    mov [rbp+018h], rcx                                          ; save rcx
    mov rcx, [rbp-0558h]                                         ; shl uses rcx
    mov qword ptr r10, -000000001h                               ; shl mutates first operand, so indirect via register
    shl r10, cl                                                  ; << operator
    mov rcx, [rbp+018h]                                          ; restore rcx
    mov [rbp-05a8h], r10                                         ; store result
    mov qword ptr [rbp-05b0h], 000000015h                        ; store type
    mov r11, [rbp-05a8h]                                         ; value of mask
    mov [rbp-05b8h], r11                                         ; (indirect via r11 because mov can't do memory-to-memory)
    mov r11, [rbp-05b0h]                                         ; type of mask
    mov [rbp-05c0h], r11                                         ; (indirect via r11 because mov can't do memory-to-memory)
    ; Line 60: Integer finalValue = newValue & ~mask | oldValue & mask;
    mov rax, [rbp-05c0h]                                         ; load the dynamic type of mask into rax
    lea r10, typeTable                                           ; move type table offset into r10
    add rax, r10                                                 ; adjust rax to point to the type table
    bt qword ptr [rax], 2                                        ; check that mask is Integer'21
    jc func$_moveBytes$Movebytes$if$block$mask$TypeMatch         ; skip next block if the type matches
      ; Error handling block for mask
      ;  - print(operandTypeCheckFailureMessage)
      mov [rbp+018h], rcx                                        ; save rcx in shadow space
      mov [rbp+020h], rdx                                        ; save rdx in shadow space
      mov [rbp+028h], r8                                         ; save r8 in shadow space
      mov [rbp+030h], r9                                         ; save r9 in shadow space
      mov r11, offset operandTypeCheckFailureMessage             ; value of argument #1
      push r11                                                   ; (indirect via r11 because "operandTypeCheckFailureMessage" is an imm64)
      push 000000016h                                            ; type of argument #1
      lea r10, [rbp-05c8h]                                       ; pointer to return value (and type, 8 bytes earlier)
      push r10                                                   ; (that pointer is the last value pushed to the stack)
      mov qword ptr r9, 0h                                       ; pointer to this
      mov qword ptr r8, 000000000h                               ; type of this
      mov qword ptr rdx, 0h                                      ; pointer to closure
      mov rcx, 1                                                 ; number of arguments
      sub rsp, 20h                                               ; allocate shadow space
      call offset func$__print                                   ; jump to subroutine
      add rsp, 038h                                              ; release shadow space and arguments
      mov rcx, [rbp+018h]                                        ; restore rcx from shadow space
      mov rdx, [rbp+020h]                                        ; restore rdx from shadow space
      mov r8, [rbp+028h]                                         ; restore r8 from shadow space
      mov r9, [rbp+030h]                                         ; restore r9 from shadow space
      ;  - exit(1)
      mov [rbp+018h], rcx                                        ; save rcx in shadow space
      mov [rbp+020h], rdx                                        ; save rdx in shadow space
      mov [rbp+028h], r8                                         ; save r8 in shadow space
      mov [rbp+030h], r9                                         ; save r9 in shadow space
      push 000000001h                                            ; value of argument #1
      push 000000015h                                            ; type of argument #1
      lea r10, [rbp-05d8h]                                       ; pointer to return value (and type, 8 bytes earlier)
      push r10                                                   ; (that pointer is the last value pushed to the stack)
      mov qword ptr r9, 0h                                       ; pointer to this
      mov qword ptr r8, 000000000h                               ; type of this
      mov qword ptr rdx, 0h                                      ; pointer to closure
      mov rcx, 1                                                 ; number of arguments
      sub rsp, 20h                                               ; allocate shadow space
      call offset func$exit                                      ; jump to subroutine
      add rsp, 038h                                              ; release shadow space and arguments
      mov rcx, [rbp+018h]                                        ; restore rcx from shadow space
      mov rdx, [rbp+020h]                                        ; restore rdx from shadow space
      mov r8, [rbp+028h]                                         ; restore r8 from shadow space
      mov r9, [rbp+030h]                                         ; restore r9 from shadow space
    func$_moveBytes$Movebytes$if$block$mask$TypeMatch:
    mov r11, [rbp-05b8h]                                         ; move operand into location for result of not
    mov [rbp-05e8h], r11                                         ; (indirect via r11 because mov can't do memory-to-memory)
    not qword ptr[rbp-05e8h]                                     ; ~ unary operator
    mov qword ptr [rbp-05f0h], 000000015h                        ; store type
    mov rax, [rbp-03d0h]                                         ; load the dynamic type of newValue into rax
    lea r10, typeTable                                           ; move type table offset into r10
    add rax, r10                                                 ; adjust rax to point to the type table
    bt qword ptr [rax], 2                                        ; check that newValue is Integer'21
    jc func$_moveBytes$Movebytes$if$block$newvalue$TypeMatch     ; skip next block if the type matches
      ; Error handling block for newValue
      ;  - print(operandTypeCheckFailureMessage)
      mov [rbp+018h], rcx                                        ; save rcx in shadow space
      mov [rbp+020h], rdx                                        ; save rdx in shadow space
      mov [rbp+028h], r8                                         ; save r8 in shadow space
      mov [rbp+030h], r9                                         ; save r9 in shadow space
      mov r11, offset operandTypeCheckFailureMessage             ; value of argument #1
      push r11                                                   ; (indirect via r11 because "operandTypeCheckFailureMessage" is an imm64)
      push 000000016h                                            ; type of argument #1
      lea r10, [rbp-05f8h]                                       ; pointer to return value (and type, 8 bytes earlier)
      push r10                                                   ; (that pointer is the last value pushed to the stack)
      mov qword ptr r9, 0h                                       ; pointer to this
      mov qword ptr r8, 000000000h                               ; type of this
      mov qword ptr rdx, 0h                                      ; pointer to closure
      mov rcx, 1                                                 ; number of arguments
      sub rsp, 20h                                               ; allocate shadow space
      call offset func$__print                                   ; jump to subroutine
      add rsp, 038h                                              ; release shadow space and arguments
      mov rcx, [rbp+018h]                                        ; restore rcx from shadow space
      mov rdx, [rbp+020h]                                        ; restore rdx from shadow space
      mov r8, [rbp+028h]                                         ; restore r8 from shadow space
      mov r9, [rbp+030h]                                         ; restore r9 from shadow space
      ;  - exit(1)
      mov [rbp+018h], rcx                                        ; save rcx in shadow space
      mov [rbp+020h], rdx                                        ; save rdx in shadow space
      mov [rbp+028h], r8                                         ; save r8 in shadow space
      mov [rbp+030h], r9                                         ; save r9 in shadow space
      push 000000001h                                            ; value of argument #1
      push 000000015h                                            ; type of argument #1
      lea r10, [rbp-0608h]                                       ; pointer to return value (and type, 8 bytes earlier)
      push r10                                                   ; (that pointer is the last value pushed to the stack)
      mov qword ptr r9, 0h                                       ; pointer to this
      mov qword ptr r8, 000000000h                               ; type of this
      mov qword ptr rdx, 0h                                      ; pointer to closure
      mov rcx, 1                                                 ; number of arguments
      sub rsp, 20h                                               ; allocate shadow space
      call offset func$exit                                      ; jump to subroutine
      add rsp, 038h                                              ; release shadow space and arguments
      mov rcx, [rbp+018h]                                        ; restore rcx from shadow space
      mov rdx, [rbp+020h]                                        ; restore rdx from shadow space
      mov r8, [rbp+028h]                                         ; restore r8 from shadow space
      mov r9, [rbp+030h]                                         ; restore r9 from shadow space
    func$_moveBytes$Movebytes$if$block$newvalue$TypeMatch:
    mov rax, [rbp-05f0h]                                         ; load the dynamic type of ~mask into rax
    lea r10, typeTable                                           ; move type table offset into r10
    add rax, r10                                                 ; adjust rax to point to the type table
    bt qword ptr [rax], 2                                        ; check that ~mask is Integer'21
    jc func$_moveBytes$Movebytes$if$block$Mask$TypeMatch         ; skip next block if the type matches
      ; Error handling block for ~mask
      ;  - print(operandTypeCheckFailureMessage)
      mov [rbp+018h], rcx                                        ; save rcx in shadow space
      mov [rbp+020h], rdx                                        ; save rdx in shadow space
      mov [rbp+028h], r8                                         ; save r8 in shadow space
      mov [rbp+030h], r9                                         ; save r9 in shadow space
      mov r11, offset operandTypeCheckFailureMessage             ; value of argument #1
      push r11                                                   ; (indirect via r11 because "operandTypeCheckFailureMessage" is an imm64)
      push 000000016h                                            ; type of argument #1
      lea r10, [rbp-0618h]                                       ; pointer to return value (and type, 8 bytes earlier)
      push r10                                                   ; (that pointer is the last value pushed to the stack)
      mov qword ptr r9, 0h                                       ; pointer to this
      mov qword ptr r8, 000000000h                               ; type of this
      mov qword ptr rdx, 0h                                      ; pointer to closure
      mov rcx, 1                                                 ; number of arguments
      sub rsp, 20h                                               ; allocate shadow space
      call offset func$__print                                   ; jump to subroutine
      add rsp, 038h                                              ; release shadow space and arguments
      mov rcx, [rbp+018h]                                        ; restore rcx from shadow space
      mov rdx, [rbp+020h]                                        ; restore rdx from shadow space
      mov r8, [rbp+028h]                                         ; restore r8 from shadow space
      mov r9, [rbp+030h]                                         ; restore r9 from shadow space
      ;  - exit(1)
      mov [rbp+018h], rcx                                        ; save rcx in shadow space
      mov [rbp+020h], rdx                                        ; save rdx in shadow space
      mov [rbp+028h], r8                                         ; save r8 in shadow space
      mov [rbp+030h], r9                                         ; save r9 in shadow space
      push 000000001h                                            ; value of argument #1
      push 000000015h                                            ; type of argument #1
      lea r10, [rbp-0628h]                                       ; pointer to return value (and type, 8 bytes earlier)
      push r10                                                   ; (that pointer is the last value pushed to the stack)
      mov qword ptr r9, 0h                                       ; pointer to this
      mov qword ptr r8, 000000000h                               ; type of this
      mov qword ptr rdx, 0h                                      ; pointer to closure
      mov rcx, 1                                                 ; number of arguments
      sub rsp, 20h                                               ; allocate shadow space
      call offset func$exit                                      ; jump to subroutine
      add rsp, 038h                                              ; release shadow space and arguments
      mov rcx, [rbp+018h]                                        ; restore rcx from shadow space
      mov rdx, [rbp+020h]                                        ; restore rdx from shadow space
      mov r8, [rbp+028h]                                         ; restore r8 from shadow space
      mov r9, [rbp+030h]                                         ; restore r9 from shadow space
    func$_moveBytes$Movebytes$if$block$Mask$TypeMatch:
    mov r10, [rbp-03c8h]                                         ; and mutates first operand, so indirect via register
    and r10, [rbp-05e8h]                                         ; & operator
    mov [rbp-0638h], r10                                         ; store result
    mov qword ptr [rbp-0640h], 000000015h                        ; store type
    mov rax, [rbp-03f0h]                                         ; load the dynamic type of oldValue into rax
    lea r10, typeTable                                           ; move type table offset into r10
    add rax, r10                                                 ; adjust rax to point to the type table
    bt qword ptr [rax], 2                                        ; check that oldValue is Integer'21
    jc func$_moveBytes$Movebytes$if$block$oldvalue$TypeMatch     ; skip next block if the type matches
      ; Error handling block for oldValue
      ;  - print(operandTypeCheckFailureMessage)
      mov [rbp+018h], rcx                                        ; save rcx in shadow space
      mov [rbp+020h], rdx                                        ; save rdx in shadow space
      mov [rbp+028h], r8                                         ; save r8 in shadow space
      mov [rbp+030h], r9                                         ; save r9 in shadow space
      mov r11, offset operandTypeCheckFailureMessage             ; value of argument #1
      push r11                                                   ; (indirect via r11 because "operandTypeCheckFailureMessage" is an imm64)
      push 000000016h                                            ; type of argument #1
      lea r10, [rbp-0648h]                                       ; pointer to return value (and type, 8 bytes earlier)
      push r10                                                   ; (that pointer is the last value pushed to the stack)
      mov qword ptr r9, 0h                                       ; pointer to this
      mov qword ptr r8, 000000000h                               ; type of this
      mov qword ptr rdx, 0h                                      ; pointer to closure
      mov rcx, 1                                                 ; number of arguments
      sub rsp, 20h                                               ; allocate shadow space
      call offset func$__print                                   ; jump to subroutine
      add rsp, 038h                                              ; release shadow space and arguments
      mov rcx, [rbp+018h]                                        ; restore rcx from shadow space
      mov rdx, [rbp+020h]                                        ; restore rdx from shadow space
      mov r8, [rbp+028h]                                         ; restore r8 from shadow space
      mov r9, [rbp+030h]                                         ; restore r9 from shadow space
      ;  - exit(1)
      mov [rbp+018h], rcx                                        ; save rcx in shadow space
      mov [rbp+020h], rdx                                        ; save rdx in shadow space
      mov [rbp+028h], r8                                         ; save r8 in shadow space
      mov [rbp+030h], r9                                         ; save r9 in shadow space
      push 000000001h                                            ; value of argument #1
      push 000000015h                                            ; type of argument #1
      lea r10, [rbp-0658h]                                       ; pointer to return value (and type, 8 bytes earlier)
      push r10                                                   ; (that pointer is the last value pushed to the stack)
      mov qword ptr r9, 0h                                       ; pointer to this
      mov qword ptr r8, 000000000h                               ; type of this
      mov qword ptr rdx, 0h                                      ; pointer to closure
      mov rcx, 1                                                 ; number of arguments
      sub rsp, 20h                                               ; allocate shadow space
      call offset func$exit                                      ; jump to subroutine
      add rsp, 038h                                              ; release shadow space and arguments
      mov rcx, [rbp+018h]                                        ; restore rcx from shadow space
      mov rdx, [rbp+020h]                                        ; restore rdx from shadow space
      mov r8, [rbp+028h]                                         ; restore r8 from shadow space
      mov r9, [rbp+030h]                                         ; restore r9 from shadow space
    func$_moveBytes$Movebytes$if$block$oldvalue$TypeMatch:
    mov rax, [rbp-05c0h]                                         ; load the dynamic type of mask into rax
    lea r10, typeTable                                           ; move type table offset into r10
    add rax, r10                                                 ; adjust rax to point to the type table
    bt qword ptr [rax], 2                                        ; check that mask is Integer'21
    jc func$_moveBytes$Movebytes$if$block$mask$TypeMatch$1       ; skip next block if the type matches
      ; Error handling block for mask
      ;  - print(operandTypeCheckFailureMessage)
      mov [rbp+018h], rcx                                        ; save rcx in shadow space
      mov [rbp+020h], rdx                                        ; save rdx in shadow space
      mov [rbp+028h], r8                                         ; save r8 in shadow space
      mov [rbp+030h], r9                                         ; save r9 in shadow space
      mov r11, offset operandTypeCheckFailureMessage             ; value of argument #1
      push r11                                                   ; (indirect via r11 because "operandTypeCheckFailureMessage" is an imm64)
      push 000000016h                                            ; type of argument #1
      lea r10, [rbp-0668h]                                       ; pointer to return value (and type, 8 bytes earlier)
      push r10                                                   ; (that pointer is the last value pushed to the stack)
      mov qword ptr r9, 0h                                       ; pointer to this
      mov qword ptr r8, 000000000h                               ; type of this
      mov qword ptr rdx, 0h                                      ; pointer to closure
      mov rcx, 1                                                 ; number of arguments
      sub rsp, 20h                                               ; allocate shadow space
      call offset func$__print                                   ; jump to subroutine
      add rsp, 038h                                              ; release shadow space and arguments
      mov rcx, [rbp+018h]                                        ; restore rcx from shadow space
      mov rdx, [rbp+020h]                                        ; restore rdx from shadow space
      mov r8, [rbp+028h]                                         ; restore r8 from shadow space
      mov r9, [rbp+030h]                                         ; restore r9 from shadow space
      ;  - exit(1)
      mov [rbp+018h], rcx                                        ; save rcx in shadow space
      mov [rbp+020h], rdx                                        ; save rdx in shadow space
      mov [rbp+028h], r8                                         ; save r8 in shadow space
      mov [rbp+030h], r9                                         ; save r9 in shadow space
      push 000000001h                                            ; value of argument #1
      push 000000015h                                            ; type of argument #1
      lea r10, [rbp-0678h]                                       ; pointer to return value (and type, 8 bytes earlier)
      push r10                                                   ; (that pointer is the last value pushed to the stack)
      mov qword ptr r9, 0h                                       ; pointer to this
      mov qword ptr r8, 000000000h                               ; type of this
      mov qword ptr rdx, 0h                                      ; pointer to closure
      mov rcx, 1                                                 ; number of arguments
      sub rsp, 20h                                               ; allocate shadow space
      call offset func$exit                                      ; jump to subroutine
      add rsp, 038h                                              ; release shadow space and arguments
      mov rcx, [rbp+018h]                                        ; restore rcx from shadow space
      mov rdx, [rbp+020h]                                        ; restore rdx from shadow space
      mov r8, [rbp+028h]                                         ; restore r8 from shadow space
      mov r9, [rbp+030h]                                         ; restore r9 from shadow space
    func$_moveBytes$Movebytes$if$block$mask$TypeMatch$1:
    mov r10, [rbp-03e8h]                                         ; and mutates first operand, so indirect via register
    and r10, [rbp-05b8h]                                         ; & operator
    mov [rbp-0688h], r10                                         ; store result
    mov qword ptr [rbp-0690h], 000000015h                        ; store type
    mov rax, [rbp-0640h]                                         ; load the dynamic type of newValue & ~mask into rax
    lea r10, typeTable                                           ; move type table offset into r10
    add rax, r10                                                 ; adjust rax to point to the type table
    bt qword ptr [rax], 2                                        ; check that newValue & ~mask is Integer'21
    jc func$_moveBytes$Movebytes$if$block$newvalueMask$TypeMatch ; skip next block if the type matches
      ; Error handling block for newValue & ~mask
      ;  - print(operandTypeCheckFailureMessage)
      mov [rbp+018h], rcx                                        ; save rcx in shadow space
      mov [rbp+020h], rdx                                        ; save rdx in shadow space
      mov [rbp+028h], r8                                         ; save r8 in shadow space
      mov [rbp+030h], r9                                         ; save r9 in shadow space
      mov r11, offset operandTypeCheckFailureMessage             ; value of argument #1
      push r11                                                   ; (indirect via r11 because "operandTypeCheckFailureMessage" is an imm64)
      push 000000016h                                            ; type of argument #1
      lea r10, [rbp-0698h]                                       ; pointer to return value (and type, 8 bytes earlier)
      push r10                                                   ; (that pointer is the last value pushed to the stack)
      mov qword ptr r9, 0h                                       ; pointer to this
      mov qword ptr r8, 000000000h                               ; type of this
      mov qword ptr rdx, 0h                                      ; pointer to closure
      mov rcx, 1                                                 ; number of arguments
      sub rsp, 20h                                               ; allocate shadow space
      call offset func$__print                                   ; jump to subroutine
      add rsp, 038h                                              ; release shadow space and arguments
      mov rcx, [rbp+018h]                                        ; restore rcx from shadow space
      mov rdx, [rbp+020h]                                        ; restore rdx from shadow space
      mov r8, [rbp+028h]                                         ; restore r8 from shadow space
      mov r9, [rbp+030h]                                         ; restore r9 from shadow space
      ;  - exit(1)
      mov [rbp+018h], rcx                                        ; save rcx in shadow space
      mov [rbp+020h], rdx                                        ; save rdx in shadow space
      mov [rbp+028h], r8                                         ; save r8 in shadow space
      mov [rbp+030h], r9                                         ; save r9 in shadow space
      push 000000001h                                            ; value of argument #1
      push 000000015h                                            ; type of argument #1
      lea r10, [rbp-06a8h]                                       ; pointer to return value (and type, 8 bytes earlier)
      push r10                                                   ; (that pointer is the last value pushed to the stack)
      mov qword ptr r9, 0h                                       ; pointer to this
      mov qword ptr r8, 000000000h                               ; type of this
      mov qword ptr rdx, 0h                                      ; pointer to closure
      mov rcx, 1                                                 ; number of arguments
      sub rsp, 20h                                               ; allocate shadow space
      call offset func$exit                                      ; jump to subroutine
      add rsp, 038h                                              ; release shadow space and arguments
      mov rcx, [rbp+018h]                                        ; restore rcx from shadow space
      mov rdx, [rbp+020h]                                        ; restore rdx from shadow space
      mov r8, [rbp+028h]                                         ; restore r8 from shadow space
      mov r9, [rbp+030h]                                         ; restore r9 from shadow space
    func$_moveBytes$Movebytes$if$block$newvalueMask$TypeMatch:
    mov rax, [rbp-0690h]                                         ; load the dynamic type of oldValue & mask into rax
    lea r10, typeTable                                           ; move type table offset into r10
    add rax, r10                                                 ; adjust rax to point to the type table
    bt qword ptr [rax], 2                                        ; check that oldValue & mask is Integer'21
    jc func$_moveBytes$Movebytes$if$block$oldvalueMask$TypeMatch ; skip next block if the type matches
      ; Error handling block for oldValue & mask
      ;  - print(operandTypeCheckFailureMessage)
      mov [rbp+018h], rcx                                        ; save rcx in shadow space
      mov [rbp+020h], rdx                                        ; save rdx in shadow space
      mov [rbp+028h], r8                                         ; save r8 in shadow space
      mov [rbp+030h], r9                                         ; save r9 in shadow space
      mov r11, offset operandTypeCheckFailureMessage             ; value of argument #1
      push r11                                                   ; (indirect via r11 because "operandTypeCheckFailureMessage" is an imm64)
      push 000000016h                                            ; type of argument #1
      lea r10, [rbp-06b8h]                                       ; pointer to return value (and type, 8 bytes earlier)
      push r10                                                   ; (that pointer is the last value pushed to the stack)
      mov qword ptr r9, 0h                                       ; pointer to this
      mov qword ptr r8, 000000000h                               ; type of this
      mov qword ptr rdx, 0h                                      ; pointer to closure
      mov rcx, 1                                                 ; number of arguments
      sub rsp, 20h                                               ; allocate shadow space
      call offset func$__print                                   ; jump to subroutine
      add rsp, 038h                                              ; release shadow space and arguments
      mov rcx, [rbp+018h]                                        ; restore rcx from shadow space
      mov rdx, [rbp+020h]                                        ; restore rdx from shadow space
      mov r8, [rbp+028h]                                         ; restore r8 from shadow space
      mov r9, [rbp+030h]                                         ; restore r9 from shadow space
      ;  - exit(1)
      mov [rbp+018h], rcx                                        ; save rcx in shadow space
      mov [rbp+020h], rdx                                        ; save rdx in shadow space
      mov [rbp+028h], r8                                         ; save r8 in shadow space
      mov [rbp+030h], r9                                         ; save r9 in shadow space
      push 000000001h                                            ; value of argument #1
      push 000000015h                                            ; type of argument #1
      lea r10, [rbp-06c8h]                                       ; pointer to return value (and type, 8 bytes earlier)
      push r10                                                   ; (that pointer is the last value pushed to the stack)
      mov qword ptr r9, 0h                                       ; pointer to this
      mov qword ptr r8, 000000000h                               ; type of this
      mov qword ptr rdx, 0h                                      ; pointer to closure
      mov rcx, 1                                                 ; number of arguments
      sub rsp, 20h                                               ; allocate shadow space
      call offset func$exit                                      ; jump to subroutine
      add rsp, 038h                                              ; release shadow space and arguments
      mov rcx, [rbp+018h]                                        ; restore rcx from shadow space
      mov rdx, [rbp+020h]                                        ; restore rdx from shadow space
      mov r8, [rbp+028h]                                         ; restore r8 from shadow space
      mov r9, [rbp+030h]                                         ; restore r9 from shadow space
    func$_moveBytes$Movebytes$if$block$oldvalueMask$TypeMatch:
    mov r10, [rbp-0638h]                                         ; or mutates first operand, so indirect via register
    or r10, [rbp-0688h]                                          ; | operator
    mov [rbp-06d8h], r10                                         ; store result
    mov qword ptr [rbp-06e0h], 000000015h                        ; store type
    mov r11, [rbp-06d8h]                                         ; value of finalValue
    mov [rbp-06e8h], r11                                         ; (indirect via r11 because mov can't do memory-to-memory)
    mov r11, [rbp-06e0h]                                         ; type of finalValue
    mov [rbp-06f0h], r11                                         ; (indirect via r11 because mov can't do memory-to-memory)
    ; Line 61: __writeToAddress(toCursor, finalValue);
    mov r10, [rbp-0f8h]                                          ; value of toCursor
    mov r11, [rbp-06e8h]                                         ; put finalValue in toCursor
    mov [r10], r11                                               ; (indirect via r11 because mov can't do memory-to-memory)
  func$_moveBytes$if$continuation:                               ; end of if
  func$_moveBytes$epilog:
  mov rax, r15                                                   ; report address of return value
  ; Epilog
  add rsp, 06f0h                                                 ; free space for stack
  pop r15                                                        ; restore non-volatile registers
  pop rbp                                                        ; restore non-volatile registers
  ret                                                            ; return from subroutine

; concat
func$concat:
  ; Prolog
  push rbp                                                       ; save non-volatile registers
  push r15                                                       ; save non-volatile registers
  push rsi                                                       ; save non-volatile registers
  push rdi                                                       ; save non-volatile registers
  sub rsp, 04e0h                                                 ; allocate space for stack
  lea rbp, [rsp+04e0h]                                           ; set up frame pointer
  mov r15, [rbp+048h]                                            ; prepare return value
  lea rsi, [rbp+058h]                                            ; initial index pointing to value of first argument
  mov rdi, rcx                                                   ; end of loop is the number of arguments...
  shl rdi, 4                                                     ; ...times the width of each argument (010h)...
  add rdi, rsi                                                   ; ...offset from the initial index
  func$concat$varargTypeChecks$Loop:
    cmp rsi, rdi                                                 ; compare pointer to current argument to end of loop
    je func$concat$varargTypeChecks$TypesAllMatch                ; we have type-checked all the arguments
    mov rax, [rsi-008h]                                          ; load the dynamic type of vararg types into rax
    lea r10, typeTable                                           ; move type table offset into r10
    add rax, r10                                                 ; adjust rax to point to the type table
    bt qword ptr [rax], 3                                        ; check that vararg types is String'22
    jc func$concat$varargTypeChecks$TypeMatch                    ; skip next block if the type matches
      ; Error handling block for vararg types
      ;  - print(parameterTypeCheckFailureMessage)
      mov [rbp+028h], rcx                                        ; save rcx in shadow space
      mov [rbp+030h], rdx                                        ; save rdx in shadow space
      mov [rbp+038h], r8                                         ; save r8 in shadow space
      mov [rbp+040h], r9                                         ; save r9 in shadow space
      mov r11, offset parameterTypeCheckFailureMessage           ; value of argument #1
      push r11                                                   ; (indirect via r11 because "parameterTypeCheckFailureMessage" is an imm64)
      push 000000016h                                            ; type of argument #1
      lea r10, [rbp-008h]                                        ; pointer to return value (and type, 8 bytes earlier)
      push r10                                                   ; (that pointer is the last value pushed to the stack)
      mov qword ptr r9, 0h                                       ; pointer to this
      mov qword ptr r8, 000000000h                               ; type of this
      mov qword ptr rdx, 0h                                      ; pointer to closure
      mov rcx, 1                                                 ; number of arguments
      sub rsp, 20h                                               ; allocate shadow space
      call offset func$__print                                   ; jump to subroutine
      add rsp, 038h                                              ; release shadow space and arguments
      mov rcx, [rbp+028h]                                        ; restore rcx from shadow space
      mov rdx, [rbp+030h]                                        ; restore rdx from shadow space
      mov r8, [rbp+038h]                                         ; restore r8 from shadow space
      mov r9, [rbp+040h]                                         ; restore r9 from shadow space
      ;  - exit(1)
      mov [rbp+028h], rcx                                        ; save rcx in shadow space
      mov [rbp+030h], rdx                                        ; save rdx in shadow space
      mov [rbp+038h], r8                                         ; save r8 in shadow space
      mov [rbp+040h], r9                                         ; save r9 in shadow space
      push 000000001h                                            ; value of argument #1
      push 000000015h                                            ; type of argument #1
      lea r10, [rbp-018h]                                        ; pointer to return value (and type, 8 bytes earlier)
      push r10                                                   ; (that pointer is the last value pushed to the stack)
      mov qword ptr r9, 0h                                       ; pointer to this
      mov qword ptr r8, 000000000h                               ; type of this
      mov qword ptr rdx, 0h                                      ; pointer to closure
      mov rcx, 1                                                 ; number of arguments
      sub rsp, 20h                                               ; allocate shadow space
      call offset func$exit                                      ; jump to subroutine
      add rsp, 038h                                              ; release shadow space and arguments
      mov rcx, [rbp+028h]                                        ; restore rcx from shadow space
      mov rdx, [rbp+030h]                                        ; restore rdx from shadow space
      mov r8, [rbp+038h]                                         ; restore r8 from shadow space
      mov r9, [rbp+040h]                                         ; restore r9 from shadow space
    func$concat$varargTypeChecks$TypeMatch:
    add rsi, 010h                                                ; next argument
    jmp func$concat$varargTypeChecks$Loop                        ; return to top of loop
  func$concat$varargTypeChecks$TypesAllMatch:
  ; Line 67: Integer length = 0;
  mov qword ptr [rbp-028h], 000000000h                           ; value of length
  mov qword ptr [rbp-030h], 000000015h                           ; type of length
  ; Line 68: Integer index = 0;
  mov qword ptr [rbp-038h], 000000000h                           ; value of index
  mov qword ptr [rbp-040h], 000000015h                           ; type of index
  ; Line 69: while (index < len(arguments)) { ...
  func$concat$while$top:
    mov rax, [rbp-040h]                                          ; load the dynamic type of index into rax
    lea r10, typeTable                                           ; move type table offset into r10
    add rax, r10                                                 ; adjust rax to point to the type table
    bt qword ptr [rax], 2                                        ; check that index is Integer'21
    jc func$concat$while$index$TypeMatch                         ; skip next block if the type matches
      ; Error handling block for index
      ;  - print(operandTypeCheckFailureMessage)
      mov [rbp+028h], rcx                                        ; save rcx in shadow space
      mov [rbp+030h], rdx                                        ; save rdx in shadow space
      mov [rbp+038h], r8                                         ; save r8 in shadow space
      mov [rbp+040h], r9                                         ; save r9 in shadow space
      mov r11, offset operandTypeCheckFailureMessage             ; value of argument #1
      push r11                                                   ; (indirect via r11 because "operandTypeCheckFailureMessage" is an imm64)
      push 000000016h                                            ; type of argument #1
      lea r10, [rbp-048h]                                        ; pointer to return value (and type, 8 bytes earlier)
      push r10                                                   ; (that pointer is the last value pushed to the stack)
      mov qword ptr r9, 0h                                       ; pointer to this
      mov qword ptr r8, 000000000h                               ; type of this
      mov qword ptr rdx, 0h                                      ; pointer to closure
      mov rcx, 1                                                 ; number of arguments
      sub rsp, 20h                                               ; allocate shadow space
      call offset func$__print                                   ; jump to subroutine
      add rsp, 038h                                              ; release shadow space and arguments
      mov rcx, [rbp+028h]                                        ; restore rcx from shadow space
      mov rdx, [rbp+030h]                                        ; restore rdx from shadow space
      mov r8, [rbp+038h]                                         ; restore r8 from shadow space
      mov r9, [rbp+040h]                                         ; restore r9 from shadow space
      ;  - exit(1)
      mov [rbp+028h], rcx                                        ; save rcx in shadow space
      mov [rbp+030h], rdx                                        ; save rdx in shadow space
      mov [rbp+038h], r8                                         ; save r8 in shadow space
      mov [rbp+040h], r9                                         ; save r9 in shadow space
      push 000000001h                                            ; value of argument #1
      push 000000015h                                            ; type of argument #1
      lea r10, [rbp-058h]                                        ; pointer to return value (and type, 8 bytes earlier)
      push r10                                                   ; (that pointer is the last value pushed to the stack)
      mov qword ptr r9, 0h                                       ; pointer to this
      mov qword ptr r8, 000000000h                               ; type of this
      mov qword ptr rdx, 0h                                      ; pointer to closure
      mov rcx, 1                                                 ; number of arguments
      sub rsp, 20h                                               ; allocate shadow space
      call offset func$exit                                      ; jump to subroutine
      add rsp, 038h                                              ; release shadow space and arguments
      mov rcx, [rbp+028h]                                        ; restore rcx from shadow space
      mov rdx, [rbp+030h]                                        ; restore rdx from shadow space
      mov r8, [rbp+038h]                                         ; restore r8 from shadow space
      mov r9, [rbp+040h]                                         ; restore r9 from shadow space
    func$concat$while$index$TypeMatch:
    mov qword ptr [rbp-088h], 000000000h                         ; clear < operator result
    cmp [rbp-038h], rcx                                          ; compare index to parameter count
    setl byte ptr [rbp-088h]                                     ; store result in < operator result
    mov qword ptr [rbp-090h], 000000014h                         ; < operator result is a Boolean
    cmp qword ptr [rbp-088h], 000000000h                         ; compare < operator result to false
    je func$concat$while$bottom                                  ; while condition
    ; Line 70: length += _stringByteLength(arguments[index]);
    lea r10, [rbp+058h]                                          ; base address of varargs
    mov rax, [rbp-038h]                                          ; index into list
    cmp rax, rcx                                                 ; compare index into varargs to number of arguments
    jge func$concat$while$subscript$boundsError                  ; index out of range (too high)
    cmp qword ptr rax, 000000000h                                ; compare index into varargs to zero
    jns func$concat$while$subscript$inBounds                     ; index not out of range (not negative)
    func$concat$while$subscript$boundsError:
      ; Error handling block for subscript bounds error
      ;  - print(boundsFailureMessage)
      mov [rbp+028h], rcx                                        ; save rcx in shadow space
      mov [rbp+030h], rdx                                        ; save rdx in shadow space
      mov [rbp+038h], r8                                         ; save r8 in shadow space
      mov [rbp+040h], r9                                         ; save r9 in shadow space
      mov r11, offset boundsFailureMessage                       ; value of argument #1
      push r11                                                   ; (indirect via r11 because "boundsFailureMessage" is an imm64)
      push 000000016h                                            ; type of argument #1
      lea r10, [rbp-0a8h]                                        ; pointer to return value (and type, 8 bytes earlier)
      push r10                                                   ; (that pointer is the last value pushed to the stack)
      mov qword ptr r9, 0h                                       ; pointer to this
      mov qword ptr r8, 000000000h                               ; type of this
      mov qword ptr rdx, 0h                                      ; pointer to closure
      mov rcx, 1                                                 ; number of arguments
      sub rsp, 20h                                               ; allocate shadow space
      call offset func$__print                                   ; jump to subroutine
      add rsp, 038h                                              ; release shadow space and arguments
      mov rcx, [rbp+028h]                                        ; restore rcx from shadow space
      mov rdx, [rbp+030h]                                        ; restore rdx from shadow space
      mov r8, [rbp+038h]                                         ; restore r8 from shadow space
      mov r9, [rbp+040h]                                         ; restore r9 from shadow space
      ;  - exit(1)
      mov [rbp+028h], rcx                                        ; save rcx in shadow space
      mov [rbp+030h], rdx                                        ; save rdx in shadow space
      mov [rbp+038h], r8                                         ; save r8 in shadow space
      mov [rbp+040h], r9                                         ; save r9 in shadow space
      push 000000001h                                            ; value of argument #1
      push 000000015h                                            ; type of argument #1
      lea r10, [rbp-0b8h]                                        ; pointer to return value (and type, 8 bytes earlier)
      push r10                                                   ; (that pointer is the last value pushed to the stack)
      mov qword ptr r9, 0h                                       ; pointer to this
      mov qword ptr r8, 000000000h                               ; type of this
      mov qword ptr rdx, 0h                                      ; pointer to closure
      mov rcx, 1                                                 ; number of arguments
      sub rsp, 20h                                               ; allocate shadow space
      call offset func$exit                                      ; jump to subroutine
      add rsp, 038h                                              ; release shadow space and arguments
      mov rcx, [rbp+028h]                                        ; restore rcx from shadow space
      mov rdx, [rbp+030h]                                        ; restore rdx from shadow space
      mov r8, [rbp+038h]                                         ; restore r8 from shadow space
      mov r9, [rbp+040h]                                         ; restore r9 from shadow space
    func$concat$while$subscript$inBounds:
    shl rax, 4                                                   ; multiply by 8 * 2 to get to value
    mov r11, [r10+rax]                                           ; store value
    mov [rbp-098h], r11                                          ; (indirect via r11 because mov can't do memory-to-memory)
    sub rax, 8                                                   ; subtract 8 to get to the type
    mov r11, [r10+rax]                                           ; store type
    mov [rbp-0a0h], r11                                          ; (indirect via r11 because mov can't do memory-to-memory)
    mov [rbp+028h], rcx                                          ; save rcx in shadow space
    mov [rbp+030h], rdx                                          ; save rdx in shadow space
    mov [rbp+038h], r8                                           ; save r8 in shadow space
    mov [rbp+040h], r9                                           ; save r9 in shadow space
    push [rbp-098h]                                              ; value of argument #1
    push [rbp-0a0h]                                              ; type of argument #1
    lea r10, [rbp-0c8h]                                          ; pointer to return value (and type, 8 bytes earlier)
    push r10                                                     ; (that pointer is the last value pushed to the stack)
    mov qword ptr r9, 0h                                         ; pointer to this
    mov qword ptr r8, 000000000h                                 ; type of this
    mov qword ptr rdx, 0h                                        ; pointer to closure
    mov rcx, 1                                                   ; number of arguments
    sub rsp, 20h                                                 ; allocate shadow space
    call offset func$_stringByteLength                           ; jump to subroutine
    add rsp, 038h                                                ; release shadow space and arguments
    mov rcx, [rbp+028h]                                          ; restore rcx from shadow space
    mov rdx, [rbp+030h]                                          ; restore rdx from shadow space
    mov r8, [rbp+038h]                                           ; restore r8 from shadow space
    mov r9, [rbp+040h]                                           ; restore r9 from shadow space
    mov rax, [rbp-030h]                                          ; load the dynamic type of <length: Integer at null; compile-time constant> into rax
    lea r10, typeTable                                           ; move type table offset into r10
    add rax, r10                                                 ; adjust rax to point to the type table
    bt qword ptr [rax], 2                                        ; check that <length: Integer at null; compile-time constant> is Integer'21
    jc func$concat$while$LengthINtegerAtNullCompileTimeConstant$TypeMatch ; skip next block if the type matches
      ; Error handling block for <length: Integer at null; compile-time constant>
      ;  - print(operandTypeCheckFailureMessage)
      mov [rbp+028h], rcx                                        ; save rcx in shadow space
      mov [rbp+030h], rdx                                        ; save rdx in shadow space
      mov [rbp+038h], r8                                         ; save r8 in shadow space
      mov [rbp+040h], r9                                         ; save r9 in shadow space
      mov r11, offset operandTypeCheckFailureMessage             ; value of argument #1
      push r11                                                   ; (indirect via r11 because "operandTypeCheckFailureMessage" is an imm64)
      push 000000016h                                            ; type of argument #1
      lea r10, [rbp-0e8h]                                        ; pointer to return value (and type, 8 bytes earlier)
      push r10                                                   ; (that pointer is the last value pushed to the stack)
      mov qword ptr r9, 0h                                       ; pointer to this
      mov qword ptr r8, 000000000h                               ; type of this
      mov qword ptr rdx, 0h                                      ; pointer to closure
      mov rcx, 1                                                 ; number of arguments
      sub rsp, 20h                                               ; allocate shadow space
      call offset func$__print                                   ; jump to subroutine
      add rsp, 038h                                              ; release shadow space and arguments
      mov rcx, [rbp+028h]                                        ; restore rcx from shadow space
      mov rdx, [rbp+030h]                                        ; restore rdx from shadow space
      mov r8, [rbp+038h]                                         ; restore r8 from shadow space
      mov r9, [rbp+040h]                                         ; restore r9 from shadow space
      ;  - exit(1)
      mov [rbp+028h], rcx                                        ; save rcx in shadow space
      mov [rbp+030h], rdx                                        ; save rdx in shadow space
      mov [rbp+038h], r8                                         ; save r8 in shadow space
      mov [rbp+040h], r9                                         ; save r9 in shadow space
      push 000000001h                                            ; value of argument #1
      push 000000015h                                            ; type of argument #1
      lea r10, [rbp-0f8h]                                        ; pointer to return value (and type, 8 bytes earlier)
      push r10                                                   ; (that pointer is the last value pushed to the stack)
      mov qword ptr r9, 0h                                       ; pointer to this
      mov qword ptr r8, 000000000h                               ; type of this
      mov qword ptr rdx, 0h                                      ; pointer to closure
      mov rcx, 1                                                 ; number of arguments
      sub rsp, 20h                                               ; allocate shadow space
      call offset func$exit                                      ; jump to subroutine
      add rsp, 038h                                              ; release shadow space and arguments
      mov rcx, [rbp+028h]                                        ; restore rcx from shadow space
      mov rdx, [rbp+030h]                                        ; restore rdx from shadow space
      mov r8, [rbp+038h]                                         ; restore r8 from shadow space
      mov r9, [rbp+040h]                                         ; restore r9 from shadow space
    func$concat$while$LengthINtegerAtNullCompileTimeConstant$TypeMatch:
    mov rax, [rbp-0d0h]                                          ; load the dynamic type of <return value: Integer at null; compile-time constant> into rax
    lea r10, typeTable                                           ; move type table offset into r10
    add rax, r10                                                 ; adjust rax to point to the type table
    bt qword ptr [rax], 2                                        ; check that <return value: Integer at null; compile-time constant> is Integer'21
    jc func$concat$while$ReturnValueINtegerAtNullCompileTimeConstant$TypeMatch ; skip next block if the type matches
      ; Error handling block for <return value: Integer at null; compile-time constant>
      ;  - print(operandTypeCheckFailureMessage)
      mov [rbp+028h], rcx                                        ; save rcx in shadow space
      mov [rbp+030h], rdx                                        ; save rdx in shadow space
      mov [rbp+038h], r8                                         ; save r8 in shadow space
      mov [rbp+040h], r9                                         ; save r9 in shadow space
      mov r11, offset operandTypeCheckFailureMessage             ; value of argument #1
      push r11                                                   ; (indirect via r11 because "operandTypeCheckFailureMessage" is an imm64)
      push 000000016h                                            ; type of argument #1
      lea r10, [rbp-0108h]                                       ; pointer to return value (and type, 8 bytes earlier)
      push r10                                                   ; (that pointer is the last value pushed to the stack)
      mov qword ptr r9, 0h                                       ; pointer to this
      mov qword ptr r8, 000000000h                               ; type of this
      mov qword ptr rdx, 0h                                      ; pointer to closure
      mov rcx, 1                                                 ; number of arguments
      sub rsp, 20h                                               ; allocate shadow space
      call offset func$__print                                   ; jump to subroutine
      add rsp, 038h                                              ; release shadow space and arguments
      mov rcx, [rbp+028h]                                        ; restore rcx from shadow space
      mov rdx, [rbp+030h]                                        ; restore rdx from shadow space
      mov r8, [rbp+038h]                                         ; restore r8 from shadow space
      mov r9, [rbp+040h]                                         ; restore r9 from shadow space
      ;  - exit(1)
      mov [rbp+028h], rcx                                        ; save rcx in shadow space
      mov [rbp+030h], rdx                                        ; save rdx in shadow space
      mov [rbp+038h], r8                                         ; save r8 in shadow space
      mov [rbp+040h], r9                                         ; save r9 in shadow space
      push 000000001h                                            ; value of argument #1
      push 000000015h                                            ; type of argument #1
      lea r10, [rbp-0118h]                                       ; pointer to return value (and type, 8 bytes earlier)
      push r10                                                   ; (that pointer is the last value pushed to the stack)
      mov qword ptr r9, 0h                                       ; pointer to this
      mov qword ptr r8, 000000000h                               ; type of this
      mov qword ptr rdx, 0h                                      ; pointer to closure
      mov rcx, 1                                                 ; number of arguments
      sub rsp, 20h                                               ; allocate shadow space
      call offset func$exit                                      ; jump to subroutine
      add rsp, 038h                                              ; release shadow space and arguments
      mov rcx, [rbp+028h]                                        ; restore rcx from shadow space
      mov rdx, [rbp+030h]                                        ; restore rdx from shadow space
      mov r8, [rbp+038h]                                         ; restore r8 from shadow space
      mov r9, [rbp+040h]                                         ; restore r9 from shadow space
    func$concat$while$ReturnValueINtegerAtNullCompileTimeConstant$TypeMatch:
    mov r10, [rbp-028h]                                          ; add mutates first operand, so indirect via register
    add r10, [rbp-0c8h]                                          ; += operator
    mov [rbp-0d8h], r10                                          ; store result
    mov qword ptr [rbp-0e0h], 000000015h                         ; store type
    mov r11, [rbp-0d8h]                                          ; value of length
    mov [rbp-028h], r11                                          ; (indirect via r11 because mov can't do memory-to-memory)
    mov r11, [rbp-0e0h]                                          ; type of length
    mov [rbp-030h], r11                                          ; (indirect via r11 because mov can't do memory-to-memory)
    ; Line 71: index += 1;
    mov rax, [rbp-040h]                                          ; load the dynamic type of <index: Integer at null; compile-time constant> into rax
    lea r10, typeTable                                           ; move type table offset into r10
    add rax, r10                                                 ; adjust rax to point to the type table
    bt qword ptr [rax], 2                                        ; check that <index: Integer at null; compile-time constant> is Integer'21
    jc func$concat$while$IndexINtegerAtNullCompileTimeConstant$TypeMatch ; skip next block if the type matches
      ; Error handling block for <index: Integer at null; compile-time constant>
      ;  - print(operandTypeCheckFailureMessage)
      mov [rbp+028h], rcx                                        ; save rcx in shadow space
      mov [rbp+030h], rdx                                        ; save rdx in shadow space
      mov [rbp+038h], r8                                         ; save r8 in shadow space
      mov [rbp+040h], r9                                         ; save r9 in shadow space
      mov r11, offset operandTypeCheckFailureMessage             ; value of argument #1
      push r11                                                   ; (indirect via r11 because "operandTypeCheckFailureMessage" is an imm64)
      push 000000016h                                            ; type of argument #1
      lea r10, [rbp-0138h]                                       ; pointer to return value (and type, 8 bytes earlier)
      push r10                                                   ; (that pointer is the last value pushed to the stack)
      mov qword ptr r9, 0h                                       ; pointer to this
      mov qword ptr r8, 000000000h                               ; type of this
      mov qword ptr rdx, 0h                                      ; pointer to closure
      mov rcx, 1                                                 ; number of arguments
      sub rsp, 20h                                               ; allocate shadow space
      call offset func$__print                                   ; jump to subroutine
      add rsp, 038h                                              ; release shadow space and arguments
      mov rcx, [rbp+028h]                                        ; restore rcx from shadow space
      mov rdx, [rbp+030h]                                        ; restore rdx from shadow space
      mov r8, [rbp+038h]                                         ; restore r8 from shadow space
      mov r9, [rbp+040h]                                         ; restore r9 from shadow space
      ;  - exit(1)
      mov [rbp+028h], rcx                                        ; save rcx in shadow space
      mov [rbp+030h], rdx                                        ; save rdx in shadow space
      mov [rbp+038h], r8                                         ; save r8 in shadow space
      mov [rbp+040h], r9                                         ; save r9 in shadow space
      push 000000001h                                            ; value of argument #1
      push 000000015h                                            ; type of argument #1
      lea r10, [rbp-0148h]                                       ; pointer to return value (and type, 8 bytes earlier)
      push r10                                                   ; (that pointer is the last value pushed to the stack)
      mov qword ptr r9, 0h                                       ; pointer to this
      mov qword ptr r8, 000000000h                               ; type of this
      mov qword ptr rdx, 0h                                      ; pointer to closure
      mov rcx, 1                                                 ; number of arguments
      sub rsp, 20h                                               ; allocate shadow space
      call offset func$exit                                      ; jump to subroutine
      add rsp, 038h                                              ; release shadow space and arguments
      mov rcx, [rbp+028h]                                        ; restore rcx from shadow space
      mov rdx, [rbp+030h]                                        ; restore rdx from shadow space
      mov r8, [rbp+038h]                                         ; restore r8 from shadow space
      mov r9, [rbp+040h]                                         ; restore r9 from shadow space
    func$concat$while$IndexINtegerAtNullCompileTimeConstant$TypeMatch:
    mov r10, [rbp-038h]                                          ; add mutates first operand, so indirect via register
    add r10, 000000001h                                          ; += operator
    mov [rbp-0128h], r10                                         ; store result
    mov qword ptr [rbp-0130h], 000000015h                        ; store type
    mov r11, [rbp-0128h]                                         ; value of index
    mov [rbp-038h], r11                                          ; (indirect via r11 because mov can't do memory-to-memory)
    mov r11, [rbp-0130h]                                         ; type of index
    mov [rbp-040h], r11                                          ; (indirect via r11 because mov can't do memory-to-memory)
    jmp func$concat$while$top                                    ; return to top of while
  func$concat$while$bottom:
  ; Line 73: Integer resultPointer = _alloc(16 /* 0x10 */ + length);
  mov rax, [rbp-030h]                                            ; load the dynamic type of length into rax
  lea r10, typeTable                                             ; move type table offset into r10
  add rax, r10                                                   ; adjust rax to point to the type table
  bt qword ptr [rax], 2                                          ; check that length is Integer'21
  jc func$concat$length$TypeMatch                                ; skip next block if the type matches
    ; Error handling block for length
    ;  - print(operandTypeCheckFailureMessage)
    mov [rbp+028h], rcx                                          ; save rcx in shadow space
    mov [rbp+030h], rdx                                          ; save rdx in shadow space
    mov [rbp+038h], r8                                           ; save r8 in shadow space
    mov [rbp+040h], r9                                           ; save r9 in shadow space
    mov r11, offset operandTypeCheckFailureMessage               ; value of argument #1
    push r11                                                     ; (indirect via r11 because "operandTypeCheckFailureMessage" is an imm64)
    push 000000016h                                              ; type of argument #1
    lea r10, [rbp-0198h]                                         ; pointer to return value (and type, 8 bytes earlier)
    push r10                                                     ; (that pointer is the last value pushed to the stack)
    mov qword ptr r9, 0h                                         ; pointer to this
    mov qword ptr r8, 000000000h                                 ; type of this
    mov qword ptr rdx, 0h                                        ; pointer to closure
    mov rcx, 1                                                   ; number of arguments
    sub rsp, 20h                                                 ; allocate shadow space
    call offset func$__print                                     ; jump to subroutine
    add rsp, 038h                                                ; release shadow space and arguments
    mov rcx, [rbp+028h]                                          ; restore rcx from shadow space
    mov rdx, [rbp+030h]                                          ; restore rdx from shadow space
    mov r8, [rbp+038h]                                           ; restore r8 from shadow space
    mov r9, [rbp+040h]                                           ; restore r9 from shadow space
    ;  - exit(1)
    mov [rbp+028h], rcx                                          ; save rcx in shadow space
    mov [rbp+030h], rdx                                          ; save rdx in shadow space
    mov [rbp+038h], r8                                           ; save r8 in shadow space
    mov [rbp+040h], r9                                           ; save r9 in shadow space
    push 000000001h                                              ; value of argument #1
    push 000000015h                                              ; type of argument #1
    lea r10, [rbp-01a8h]                                         ; pointer to return value (and type, 8 bytes earlier)
    push r10                                                     ; (that pointer is the last value pushed to the stack)
    mov qword ptr r9, 0h                                         ; pointer to this
    mov qword ptr r8, 000000000h                                 ; type of this
    mov qword ptr rdx, 0h                                        ; pointer to closure
    mov rcx, 1                                                   ; number of arguments
    sub rsp, 20h                                                 ; allocate shadow space
    call offset func$exit                                        ; jump to subroutine
    add rsp, 038h                                                ; release shadow space and arguments
    mov rcx, [rbp+028h]                                          ; restore rcx from shadow space
    mov rdx, [rbp+030h]                                          ; restore rdx from shadow space
    mov r8, [rbp+038h]                                           ; restore r8 from shadow space
    mov r9, [rbp+040h]                                           ; restore r9 from shadow space
  func$concat$length$TypeMatch:
  mov qword ptr r10, 000000010h                                  ; add mutates first operand, so indirect via register
  add r10, [rbp-028h]                                            ; + operator
  mov [rbp-01b8h], r10                                           ; store result
  mov qword ptr [rbp-01c0h], 000000015h                          ; store type
  mov [rbp+028h], rcx                                            ; save rcx in shadow space
  mov [rbp+030h], rdx                                            ; save rdx in shadow space
  mov [rbp+038h], r8                                             ; save r8 in shadow space
  mov [rbp+040h], r9                                             ; save r9 in shadow space
  push [rbp-01b8h]                                               ; value of argument #1
  push [rbp-01c0h]                                               ; type of argument #1
  lea r10, [rbp-01c8h]                                           ; pointer to return value (and type, 8 bytes earlier)
  push r10                                                       ; (that pointer is the last value pushed to the stack)
  mov qword ptr r9, 0h                                           ; pointer to this
  mov qword ptr r8, 000000000h                                   ; type of this
  mov qword ptr rdx, 0h                                          ; pointer to closure
  mov rcx, 1                                                     ; number of arguments
  sub rsp, 20h                                                   ; allocate shadow space
  call offset func$_alloc                                        ; jump to subroutine
  add rsp, 038h                                                  ; release shadow space and arguments
  mov rcx, [rbp+028h]                                            ; restore rcx from shadow space
  mov rdx, [rbp+030h]                                            ; restore rdx from shadow space
  mov r8, [rbp+038h]                                             ; restore r8 from shadow space
  mov r9, [rbp+040h]                                             ; restore r9 from shadow space
  mov r11, [rbp-01c8h]                                           ; value of resultPointer
  mov [rbp-01d8h], r11                                           ; (indirect via r11 because mov can't do memory-to-memory)
  mov r11, [rbp-01d0h]                                           ; type of resultPointer
  mov [rbp-01e0h], r11                                           ; (indirect via r11 because mov can't do memory-to-memory)
  ; Line 74: __writeToAddress(resultPointer, 1);
  mov r10, [rbp-01d8h]                                           ; value of resultPointer
  mov qword ptr [r10], 000000001h                                ; put 1 in resultPointer
  ; Line 75: __writeToAddress(resultPointer + 8, length);
  mov rax, [rbp-01e0h]                                           ; load the dynamic type of resultPointer into rax
  lea r10, typeTable                                             ; move type table offset into r10
  add rax, r10                                                   ; adjust rax to point to the type table
  bt qword ptr [rax], 2                                          ; check that resultPointer is Integer'21
  jc func$concat$resultpointer$TypeMatch                         ; skip next block if the type matches
    ; Error handling block for resultPointer
    ;  - print(operandTypeCheckFailureMessage)
    mov [rbp+028h], rcx                                          ; save rcx in shadow space
    mov [rbp+030h], rdx                                          ; save rdx in shadow space
    mov [rbp+038h], r8                                           ; save r8 in shadow space
    mov [rbp+040h], r9                                           ; save r9 in shadow space
    mov r11, offset operandTypeCheckFailureMessage               ; value of argument #1
    push r11                                                     ; (indirect via r11 because "operandTypeCheckFailureMessage" is an imm64)
    push 000000016h                                              ; type of argument #1
    lea r10, [rbp-01e8h]                                         ; pointer to return value (and type, 8 bytes earlier)
    push r10                                                     ; (that pointer is the last value pushed to the stack)
    mov qword ptr r9, 0h                                         ; pointer to this
    mov qword ptr r8, 000000000h                                 ; type of this
    mov qword ptr rdx, 0h                                        ; pointer to closure
    mov rcx, 1                                                   ; number of arguments
    sub rsp, 20h                                                 ; allocate shadow space
    call offset func$__print                                     ; jump to subroutine
    add rsp, 038h                                                ; release shadow space and arguments
    mov rcx, [rbp+028h]                                          ; restore rcx from shadow space
    mov rdx, [rbp+030h]                                          ; restore rdx from shadow space
    mov r8, [rbp+038h]                                           ; restore r8 from shadow space
    mov r9, [rbp+040h]                                           ; restore r9 from shadow space
    ;  - exit(1)
    mov [rbp+028h], rcx                                          ; save rcx in shadow space
    mov [rbp+030h], rdx                                          ; save rdx in shadow space
    mov [rbp+038h], r8                                           ; save r8 in shadow space
    mov [rbp+040h], r9                                           ; save r9 in shadow space
    push 000000001h                                              ; value of argument #1
    push 000000015h                                              ; type of argument #1
    lea r10, [rbp-01f8h]                                         ; pointer to return value (and type, 8 bytes earlier)
    push r10                                                     ; (that pointer is the last value pushed to the stack)
    mov qword ptr r9, 0h                                         ; pointer to this
    mov qword ptr r8, 000000000h                                 ; type of this
    mov qword ptr rdx, 0h                                        ; pointer to closure
    mov rcx, 1                                                   ; number of arguments
    sub rsp, 20h                                                 ; allocate shadow space
    call offset func$exit                                        ; jump to subroutine
    add rsp, 038h                                                ; release shadow space and arguments
    mov rcx, [rbp+028h]                                          ; restore rcx from shadow space
    mov rdx, [rbp+030h]                                          ; restore rdx from shadow space
    mov r8, [rbp+038h]                                           ; restore r8 from shadow space
    mov r9, [rbp+040h]                                           ; restore r9 from shadow space
  func$concat$resultpointer$TypeMatch:
  mov r10, [rbp-01d8h]                                           ; add mutates first operand, so indirect via register
  add r10, 000000008h                                            ; + operator
  mov [rbp-0228h], r10                                           ; store result
  mov qword ptr [rbp-0230h], 000000015h                          ; store type
  mov r10, [rbp-0228h]                                           ; value of + operator result
  mov r11, [rbp-028h]                                            ; put length in + operator result
  mov [r10], r11                                                 ; (indirect via r11 because mov can't do memory-to-memory)
  ; Line 76: Integer cursor = resultPointer + 16 /* 0x10 */;
  mov rax, [rbp-01e0h]                                           ; load the dynamic type of resultPointer into rax
  lea r10, typeTable                                             ; move type table offset into r10
  add rax, r10                                                   ; adjust rax to point to the type table
  bt qword ptr [rax], 2                                          ; check that resultPointer is Integer'21
  jc func$concat$resultpointer$TypeMatch$1                       ; skip next block if the type matches
    ; Error handling block for resultPointer
    ;  - print(operandTypeCheckFailureMessage)
    mov [rbp+028h], rcx                                          ; save rcx in shadow space
    mov [rbp+030h], rdx                                          ; save rdx in shadow space
    mov [rbp+038h], r8                                           ; save r8 in shadow space
    mov [rbp+040h], r9                                           ; save r9 in shadow space
    mov r11, offset operandTypeCheckFailureMessage               ; value of argument #1
    push r11                                                     ; (indirect via r11 because "operandTypeCheckFailureMessage" is an imm64)
    push 000000016h                                              ; type of argument #1
    lea r10, [rbp-0238h]                                         ; pointer to return value (and type, 8 bytes earlier)
    push r10                                                     ; (that pointer is the last value pushed to the stack)
    mov qword ptr r9, 0h                                         ; pointer to this
    mov qword ptr r8, 000000000h                                 ; type of this
    mov qword ptr rdx, 0h                                        ; pointer to closure
    mov rcx, 1                                                   ; number of arguments
    sub rsp, 20h                                                 ; allocate shadow space
    call offset func$__print                                     ; jump to subroutine
    add rsp, 038h                                                ; release shadow space and arguments
    mov rcx, [rbp+028h]                                          ; restore rcx from shadow space
    mov rdx, [rbp+030h]                                          ; restore rdx from shadow space
    mov r8, [rbp+038h]                                           ; restore r8 from shadow space
    mov r9, [rbp+040h]                                           ; restore r9 from shadow space
    ;  - exit(1)
    mov [rbp+028h], rcx                                          ; save rcx in shadow space
    mov [rbp+030h], rdx                                          ; save rdx in shadow space
    mov [rbp+038h], r8                                           ; save r8 in shadow space
    mov [rbp+040h], r9                                           ; save r9 in shadow space
    push 000000001h                                              ; value of argument #1
    push 000000015h                                              ; type of argument #1
    lea r10, [rbp-0248h]                                         ; pointer to return value (and type, 8 bytes earlier)
    push r10                                                     ; (that pointer is the last value pushed to the stack)
    mov qword ptr r9, 0h                                         ; pointer to this
    mov qword ptr r8, 000000000h                                 ; type of this
    mov qword ptr rdx, 0h                                        ; pointer to closure
    mov rcx, 1                                                   ; number of arguments
    sub rsp, 20h                                                 ; allocate shadow space
    call offset func$exit                                        ; jump to subroutine
    add rsp, 038h                                                ; release shadow space and arguments
    mov rcx, [rbp+028h]                                          ; restore rcx from shadow space
    mov rdx, [rbp+030h]                                          ; restore rdx from shadow space
    mov r8, [rbp+038h]                                           ; restore r8 from shadow space
    mov r9, [rbp+040h]                                           ; restore r9 from shadow space
  func$concat$resultpointer$TypeMatch$1:
  mov r10, [rbp-01d8h]                                           ; add mutates first operand, so indirect via register
  add r10, 000000010h                                            ; + operator
  mov [rbp-0278h], r10                                           ; store result
  mov qword ptr [rbp-0280h], 000000015h                          ; store type
  mov r11, [rbp-0278h]                                           ; value of cursor
  mov [rbp-0288h], r11                                           ; (indirect via r11 because mov can't do memory-to-memory)
  mov r11, [rbp-0280h]                                           ; type of cursor
  mov [rbp-0290h], r11                                           ; (indirect via r11 because mov can't do memory-to-memory)
  ; Line 77: index = 0;
  mov qword ptr [rbp-038h], 000000000h                           ; value of index
  mov qword ptr [rbp-040h], 000000015h                           ; type of index
  ; Line 78: while (index < len(arguments)) { ...
  func$concat$while$top$1:
    mov rax, [rbp-040h]                                          ; load the dynamic type of index into rax
    lea r10, typeTable                                           ; move type table offset into r10
    add rax, r10                                                 ; adjust rax to point to the type table
    bt qword ptr [rax], 2                                        ; check that index is Integer'21
    jc func$concat$while$index$TypeMatch$1                       ; skip next block if the type matches
      ; Error handling block for index
      ;  - print(operandTypeCheckFailureMessage)
      mov [rbp+028h], rcx                                        ; save rcx in shadow space
      mov [rbp+030h], rdx                                        ; save rdx in shadow space
      mov [rbp+038h], r8                                         ; save r8 in shadow space
      mov [rbp+040h], r9                                         ; save r9 in shadow space
      mov r11, offset operandTypeCheckFailureMessage             ; value of argument #1
      push r11                                                   ; (indirect via r11 because "operandTypeCheckFailureMessage" is an imm64)
      push 000000016h                                            ; type of argument #1
      lea r10, [rbp-0298h]                                       ; pointer to return value (and type, 8 bytes earlier)
      push r10                                                   ; (that pointer is the last value pushed to the stack)
      mov qword ptr r9, 0h                                       ; pointer to this
      mov qword ptr r8, 000000000h                               ; type of this
      mov qword ptr rdx, 0h                                      ; pointer to closure
      mov rcx, 1                                                 ; number of arguments
      sub rsp, 20h                                               ; allocate shadow space
      call offset func$__print                                   ; jump to subroutine
      add rsp, 038h                                              ; release shadow space and arguments
      mov rcx, [rbp+028h]                                        ; restore rcx from shadow space
      mov rdx, [rbp+030h]                                        ; restore rdx from shadow space
      mov r8, [rbp+038h]                                         ; restore r8 from shadow space
      mov r9, [rbp+040h]                                         ; restore r9 from shadow space
      ;  - exit(1)
      mov [rbp+028h], rcx                                        ; save rcx in shadow space
      mov [rbp+030h], rdx                                        ; save rdx in shadow space
      mov [rbp+038h], r8                                         ; save r8 in shadow space
      mov [rbp+040h], r9                                         ; save r9 in shadow space
      push 000000001h                                            ; value of argument #1
      push 000000015h                                            ; type of argument #1
      lea r10, [rbp-02a8h]                                       ; pointer to return value (and type, 8 bytes earlier)
      push r10                                                   ; (that pointer is the last value pushed to the stack)
      mov qword ptr r9, 0h                                       ; pointer to this
      mov qword ptr r8, 000000000h                               ; type of this
      mov qword ptr rdx, 0h                                      ; pointer to closure
      mov rcx, 1                                                 ; number of arguments
      sub rsp, 20h                                               ; allocate shadow space
      call offset func$exit                                      ; jump to subroutine
      add rsp, 038h                                              ; release shadow space and arguments
      mov rcx, [rbp+028h]                                        ; restore rcx from shadow space
      mov rdx, [rbp+030h]                                        ; restore rdx from shadow space
      mov r8, [rbp+038h]                                         ; restore r8 from shadow space
      mov r9, [rbp+040h]                                         ; restore r9 from shadow space
    func$concat$while$index$TypeMatch$1:
    mov qword ptr [rbp-02d8h], 000000000h                        ; clear < operator result
    cmp [rbp-038h], rcx                                          ; compare index to parameter count
    setl byte ptr [rbp-02d8h]                                    ; store result in < operator result
    mov qword ptr [rbp-02e0h], 000000014h                        ; < operator result is a Boolean
    cmp qword ptr [rbp-02d8h], 000000000h                        ; compare < operator result to false
    je func$concat$while$bottom$1                                ; while condition
    ; Line 79: String segment = arguments[index];
    lea r10, [rbp+058h]                                          ; base address of varargs
    mov rax, [rbp-038h]                                          ; index into list
    cmp rax, rcx                                                 ; compare index into varargs to number of arguments
    jge func$concat$while$subscript$boundsError$1                ; index out of range (too high)
    cmp qword ptr rax, 000000000h                                ; compare index into varargs to zero
    jns func$concat$while$subscript$inBounds$1                   ; index not out of range (not negative)
    func$concat$while$subscript$boundsError$1:
      ; Error handling block for subscript bounds error
      ;  - print(boundsFailureMessage)
      mov [rbp+028h], rcx                                        ; save rcx in shadow space
      mov [rbp+030h], rdx                                        ; save rdx in shadow space
      mov [rbp+038h], r8                                         ; save r8 in shadow space
      mov [rbp+040h], r9                                         ; save r9 in shadow space
      mov r11, offset boundsFailureMessage                       ; value of argument #1
      push r11                                                   ; (indirect via r11 because "boundsFailureMessage" is an imm64)
      push 000000016h                                            ; type of argument #1
      lea r10, [rbp-02f8h]                                       ; pointer to return value (and type, 8 bytes earlier)
      push r10                                                   ; (that pointer is the last value pushed to the stack)
      mov qword ptr r9, 0h                                       ; pointer to this
      mov qword ptr r8, 000000000h                               ; type of this
      mov qword ptr rdx, 0h                                      ; pointer to closure
      mov rcx, 1                                                 ; number of arguments
      sub rsp, 20h                                               ; allocate shadow space
      call offset func$__print                                   ; jump to subroutine
      add rsp, 038h                                              ; release shadow space and arguments
      mov rcx, [rbp+028h]                                        ; restore rcx from shadow space
      mov rdx, [rbp+030h]                                        ; restore rdx from shadow space
      mov r8, [rbp+038h]                                         ; restore r8 from shadow space
      mov r9, [rbp+040h]                                         ; restore r9 from shadow space
      ;  - exit(1)
      mov [rbp+028h], rcx                                        ; save rcx in shadow space
      mov [rbp+030h], rdx                                        ; save rdx in shadow space
      mov [rbp+038h], r8                                         ; save r8 in shadow space
      mov [rbp+040h], r9                                         ; save r9 in shadow space
      push 000000001h                                            ; value of argument #1
      push 000000015h                                            ; type of argument #1
      lea r10, [rbp-0308h]                                       ; pointer to return value (and type, 8 bytes earlier)
      push r10                                                   ; (that pointer is the last value pushed to the stack)
      mov qword ptr r9, 0h                                       ; pointer to this
      mov qword ptr r8, 000000000h                               ; type of this
      mov qword ptr rdx, 0h                                      ; pointer to closure
      mov rcx, 1                                                 ; number of arguments
      sub rsp, 20h                                               ; allocate shadow space
      call offset func$exit                                      ; jump to subroutine
      add rsp, 038h                                              ; release shadow space and arguments
      mov rcx, [rbp+028h]                                        ; restore rcx from shadow space
      mov rdx, [rbp+030h]                                        ; restore rdx from shadow space
      mov r8, [rbp+038h]                                         ; restore r8 from shadow space
      mov r9, [rbp+040h]                                         ; restore r9 from shadow space
    func$concat$while$subscript$inBounds$1:
    shl rax, 4                                                   ; multiply by 8 * 2 to get to value
    mov r11, [r10+rax]                                           ; store value
    mov [rbp-02e8h], r11                                         ; (indirect via r11 because mov can't do memory-to-memory)
    sub rax, 8                                                   ; subtract 8 to get to the type
    mov r11, [r10+rax]                                           ; store type
    mov [rbp-02f0h], r11                                         ; (indirect via r11 because mov can't do memory-to-memory)
    mov r11, [rbp-02e8h]                                         ; value of segment
    mov [rbp-0318h], r11                                         ; (indirect via r11 because mov can't do memory-to-memory)
    mov r11, [rbp-02f0h]                                         ; type of segment
    mov [rbp-0320h], r11                                         ; (indirect via r11 because mov can't do memory-to-memory)
    ; Line 80: Integer segmentLength = _stringByteLength(segment);
    mov [rbp+028h], rcx                                          ; save rcx in shadow space
    mov [rbp+030h], rdx                                          ; save rdx in shadow space
    mov [rbp+038h], r8                                           ; save r8 in shadow space
    mov [rbp+040h], r9                                           ; save r9 in shadow space
    push [rbp-0318h]                                             ; value of argument #1
    push [rbp-0320h]                                             ; type of argument #1
    lea r10, [rbp-0328h]                                         ; pointer to return value (and type, 8 bytes earlier)
    push r10                                                     ; (that pointer is the last value pushed to the stack)
    mov qword ptr r9, 0h                                         ; pointer to this
    mov qword ptr r8, 000000000h                                 ; type of this
    mov qword ptr rdx, 0h                                        ; pointer to closure
    mov rcx, 1                                                   ; number of arguments
    sub rsp, 20h                                                 ; allocate shadow space
    call offset func$_stringByteLength                           ; jump to subroutine
    add rsp, 038h                                                ; release shadow space and arguments
    mov rcx, [rbp+028h]                                          ; restore rcx from shadow space
    mov rdx, [rbp+030h]                                          ; restore rdx from shadow space
    mov r8, [rbp+038h]                                           ; restore r8 from shadow space
    mov r9, [rbp+040h]                                           ; restore r9 from shadow space
    mov r11, [rbp-0328h]                                         ; value of segmentLength
    mov [rbp-0338h], r11                                         ; (indirect via r11 because mov can't do memory-to-memory)
    mov r11, [rbp-0330h]                                         ; type of segmentLength
    mov [rbp-0340h], r11                                         ; (indirect via r11 because mov can't do memory-to-memory)
    ; Line 81: if (segmentLength > 0) { ...
    mov rax, [rbp-0340h]                                         ; load the dynamic type of segmentLength into rax
    lea r10, typeTable                                           ; move type table offset into r10
    add rax, r10                                                 ; adjust rax to point to the type table
    bt qword ptr [rax], 2                                        ; check that segmentLength is Integer'21
    jc func$concat$while$segmentlength$TypeMatch                 ; skip next block if the type matches
      ; Error handling block for segmentLength
      ;  - print(operandTypeCheckFailureMessage)
      mov [rbp+028h], rcx                                        ; save rcx in shadow space
      mov [rbp+030h], rdx                                        ; save rdx in shadow space
      mov [rbp+038h], r8                                         ; save r8 in shadow space
      mov [rbp+040h], r9                                         ; save r9 in shadow space
      mov r11, offset operandTypeCheckFailureMessage             ; value of argument #1
      push r11                                                   ; (indirect via r11 because "operandTypeCheckFailureMessage" is an imm64)
      push 000000016h                                            ; type of argument #1
      lea r10, [rbp-0348h]                                       ; pointer to return value (and type, 8 bytes earlier)
      push r10                                                   ; (that pointer is the last value pushed to the stack)
      mov qword ptr r9, 0h                                       ; pointer to this
      mov qword ptr r8, 000000000h                               ; type of this
      mov qword ptr rdx, 0h                                      ; pointer to closure
      mov rcx, 1                                                 ; number of arguments
      sub rsp, 20h                                               ; allocate shadow space
      call offset func$__print                                   ; jump to subroutine
      add rsp, 038h                                              ; release shadow space and arguments
      mov rcx, [rbp+028h]                                        ; restore rcx from shadow space
      mov rdx, [rbp+030h]                                        ; restore rdx from shadow space
      mov r8, [rbp+038h]                                         ; restore r8 from shadow space
      mov r9, [rbp+040h]                                         ; restore r9 from shadow space
      ;  - exit(1)
      mov [rbp+028h], rcx                                        ; save rcx in shadow space
      mov [rbp+030h], rdx                                        ; save rdx in shadow space
      mov [rbp+038h], r8                                         ; save r8 in shadow space
      mov [rbp+040h], r9                                         ; save r9 in shadow space
      push 000000001h                                            ; value of argument #1
      push 000000015h                                            ; type of argument #1
      lea r10, [rbp-0358h]                                       ; pointer to return value (and type, 8 bytes earlier)
      push r10                                                   ; (that pointer is the last value pushed to the stack)
      mov qword ptr r9, 0h                                       ; pointer to this
      mov qword ptr r8, 000000000h                               ; type of this
      mov qword ptr rdx, 0h                                      ; pointer to closure
      mov rcx, 1                                                 ; number of arguments
      sub rsp, 20h                                               ; allocate shadow space
      call offset func$exit                                      ; jump to subroutine
      add rsp, 038h                                              ; release shadow space and arguments
      mov rcx, [rbp+028h]                                        ; restore rcx from shadow space
      mov rdx, [rbp+030h]                                        ; restore rdx from shadow space
      mov r8, [rbp+038h]                                         ; restore r8 from shadow space
      mov r9, [rbp+040h]                                         ; restore r9 from shadow space
    func$concat$while$segmentlength$TypeMatch:
    mov qword ptr [rbp-0388h], 000000000h                        ; clear > operator result
    cmp qword ptr [rbp-0338h], 000000000h                        ; compare segmentLength to 0
    setg byte ptr [rbp-0388h]                                    ; store result in > operator result
    mov qword ptr [rbp-0390h], 000000014h                        ; > operator result is a Boolean
    cmp qword ptr [rbp-0388h], 000000000h                        ; compare > operator result to false
    je func$concat$while$if$continuation                         ; segmentLength > 0
      ; Line 82: Integer segmentPointer = segment __as__ Integer;
      mov r11, [rbp-0318h]                                       ; value of force cast of segment to Integer
      mov [rbp-0398h], r11                                       ; (indirect via r11 because mov can't do memory-to-memory)
      mov qword ptr [rbp-03a0h], 000000015h                      ; new type of force cast of segment to Integer
      mov r11, [rbp-0398h]                                       ; value of segmentPointer
      mov [rbp-03a8h], r11                                       ; (indirect via r11 because mov can't do memory-to-memory)
      mov r11, [rbp-03a0h]                                       ; type of segmentPointer
      mov [rbp-03b0h], r11                                       ; (indirect via r11 because mov can't do memory-to-memory)
      ; Line 83: _moveBytes(segmentPointer + 16 /* 0x10 */, cursor, segmentLength...
      mov rax, [rbp-03b0h]                                       ; load the dynamic type of segmentPointer into rax
      lea r10, typeTable                                         ; move type table offset into r10
      add rax, r10                                               ; adjust rax to point to the type table
      bt qword ptr [rax], 2                                      ; check that segmentPointer is Integer'21
      jc func$concat$while$while$if$block$segmentpointer$TypeMatch ; skip next block if the type matches
        ; Error handling block for segmentPointer
        ;  - print(operandTypeCheckFailureMessage)
        mov [rbp+028h], rcx                                      ; save rcx in shadow space
        mov [rbp+030h], rdx                                      ; save rdx in shadow space
        mov [rbp+038h], r8                                       ; save r8 in shadow space
        mov [rbp+040h], r9                                       ; save r9 in shadow space
        mov r11, offset operandTypeCheckFailureMessage           ; value of argument #1
        push r11                                                 ; (indirect via r11 because "operandTypeCheckFailureMessage" is an imm64)
        push 000000016h                                          ; type of argument #1
        lea r10, [rbp-03b8h]                                     ; pointer to return value (and type, 8 bytes earlier)
        push r10                                                 ; (that pointer is the last value pushed to the stack)
        mov qword ptr r9, 0h                                     ; pointer to this
        mov qword ptr r8, 000000000h                             ; type of this
        mov qword ptr rdx, 0h                                    ; pointer to closure
        mov rcx, 1                                               ; number of arguments
        sub rsp, 20h                                             ; allocate shadow space
        call offset func$__print                                 ; jump to subroutine
        add rsp, 038h                                            ; release shadow space and arguments
        mov rcx, [rbp+028h]                                      ; restore rcx from shadow space
        mov rdx, [rbp+030h]                                      ; restore rdx from shadow space
        mov r8, [rbp+038h]                                       ; restore r8 from shadow space
        mov r9, [rbp+040h]                                       ; restore r9 from shadow space
        ;  - exit(1)
        mov [rbp+028h], rcx                                      ; save rcx in shadow space
        mov [rbp+030h], rdx                                      ; save rdx in shadow space
        mov [rbp+038h], r8                                       ; save r8 in shadow space
        mov [rbp+040h], r9                                       ; save r9 in shadow space
        push 000000001h                                          ; value of argument #1
        push 000000015h                                          ; type of argument #1
        lea r10, [rbp-03c8h]                                     ; pointer to return value (and type, 8 bytes earlier)
        push r10                                                 ; (that pointer is the last value pushed to the stack)
        mov qword ptr r9, 0h                                     ; pointer to this
        mov qword ptr r8, 000000000h                             ; type of this
        mov qword ptr rdx, 0h                                    ; pointer to closure
        mov rcx, 1                                               ; number of arguments
        sub rsp, 20h                                             ; allocate shadow space
        call offset func$exit                                    ; jump to subroutine
        add rsp, 038h                                            ; release shadow space and arguments
        mov rcx, [rbp+028h]                                      ; restore rcx from shadow space
        mov rdx, [rbp+030h]                                      ; restore rdx from shadow space
        mov r8, [rbp+038h]                                       ; restore r8 from shadow space
        mov r9, [rbp+040h]                                       ; restore r9 from shadow space
      func$concat$while$while$if$block$segmentpointer$TypeMatch:
      mov r10, [rbp-03a8h]                                       ; add mutates first operand, so indirect via register
      add r10, 000000010h                                        ; + operator
      mov [rbp-03f8h], r10                                       ; store result
      mov qword ptr [rbp-0400h], 000000015h                      ; store type
      mov [rbp+028h], rcx                                        ; save rcx in shadow space
      mov [rbp+030h], rdx                                        ; save rdx in shadow space
      mov [rbp+038h], r8                                         ; save r8 in shadow space
      mov [rbp+040h], r9                                         ; save r9 in shadow space
      push [rbp-0338h]                                           ; value of argument #3
      push [rbp-0340h]                                           ; type of argument #3
      push [rbp-0288h]                                           ; value of argument #2
      push [rbp-0290h]                                           ; type of argument #2
      push [rbp-03f8h]                                           ; value of argument #1
      push [rbp-0400h]                                           ; type of argument #1
      lea r10, [rbp-0408h]                                       ; pointer to return value (and type, 8 bytes earlier)
      push r10                                                   ; (that pointer is the last value pushed to the stack)
      mov qword ptr r9, 0h                                       ; pointer to this
      mov qword ptr r8, 000000000h                               ; type of this
      mov qword ptr rdx, 0h                                      ; pointer to closure
      mov rcx, 3                                                 ; number of arguments
      sub rsp, 20h                                               ; allocate shadow space
      call offset func$_moveBytes                                ; jump to subroutine
      add rsp, 058h                                              ; release shadow space and arguments
      mov rcx, [rbp+028h]                                        ; restore rcx from shadow space
      mov rdx, [rbp+030h]                                        ; restore rdx from shadow space
      mov r8, [rbp+038h]                                         ; restore r8 from shadow space
      mov r9, [rbp+040h]                                         ; restore r9 from shadow space
      ; Line 84: cursor += segmentLength;
      mov rax, [rbp-0290h]                                       ; load the dynamic type of <cursor: Integer at null; compile-time constant> into rax
      lea r10, typeTable                                         ; move type table offset into r10
      add rax, r10                                               ; adjust rax to point to the type table
      bt qword ptr [rax], 2                                      ; check that <cursor: Integer at null; compile-time constant> is Integer'21
      jc func$concat$while$while$if$block$CursorINtegerAtNullCompileTimeConstant$TypeMatch ; skip next block if the type matches
        ; Error handling block for <cursor: Integer at null; compile-time constant>
        ;  - print(operandTypeCheckFailureMessage)
        mov [rbp+028h], rcx                                      ; save rcx in shadow space
        mov [rbp+030h], rdx                                      ; save rdx in shadow space
        mov [rbp+038h], r8                                       ; save r8 in shadow space
        mov [rbp+040h], r9                                       ; save r9 in shadow space
        mov r11, offset operandTypeCheckFailureMessage           ; value of argument #1
        push r11                                                 ; (indirect via r11 because "operandTypeCheckFailureMessage" is an imm64)
        push 000000016h                                          ; type of argument #1
        lea r10, [rbp-0428h]                                     ; pointer to return value (and type, 8 bytes earlier)
        push r10                                                 ; (that pointer is the last value pushed to the stack)
        mov qword ptr r9, 0h                                     ; pointer to this
        mov qword ptr r8, 000000000h                             ; type of this
        mov qword ptr rdx, 0h                                    ; pointer to closure
        mov rcx, 1                                               ; number of arguments
        sub rsp, 20h                                             ; allocate shadow space
        call offset func$__print                                 ; jump to subroutine
        add rsp, 038h                                            ; release shadow space and arguments
        mov rcx, [rbp+028h]                                      ; restore rcx from shadow space
        mov rdx, [rbp+030h]                                      ; restore rdx from shadow space
        mov r8, [rbp+038h]                                       ; restore r8 from shadow space
        mov r9, [rbp+040h]                                       ; restore r9 from shadow space
        ;  - exit(1)
        mov [rbp+028h], rcx                                      ; save rcx in shadow space
        mov [rbp+030h], rdx                                      ; save rdx in shadow space
        mov [rbp+038h], r8                                       ; save r8 in shadow space
        mov [rbp+040h], r9                                       ; save r9 in shadow space
        push 000000001h                                          ; value of argument #1
        push 000000015h                                          ; type of argument #1
        lea r10, [rbp-0438h]                                     ; pointer to return value (and type, 8 bytes earlier)
        push r10                                                 ; (that pointer is the last value pushed to the stack)
        mov qword ptr r9, 0h                                     ; pointer to this
        mov qword ptr r8, 000000000h                             ; type of this
        mov qword ptr rdx, 0h                                    ; pointer to closure
        mov rcx, 1                                               ; number of arguments
        sub rsp, 20h                                             ; allocate shadow space
        call offset func$exit                                    ; jump to subroutine
        add rsp, 038h                                            ; release shadow space and arguments
        mov rcx, [rbp+028h]                                      ; restore rcx from shadow space
        mov rdx, [rbp+030h]                                      ; restore rdx from shadow space
        mov r8, [rbp+038h]                                       ; restore r8 from shadow space
        mov r9, [rbp+040h]                                       ; restore r9 from shadow space
      func$concat$while$while$if$block$CursorINtegerAtNullCompileTimeConstant$TypeMatch:
      mov rax, [rbp-0340h]                                       ; load the dynamic type of <segmentLength: Integer at null; compile-time constant> into rax
      lea r10, typeTable                                         ; move type table offset into r10
      add rax, r10                                               ; adjust rax to point to the type table
      bt qword ptr [rax], 2                                      ; check that <segmentLength: Integer at null; compile-time constant> is Integer'21
      jc func$concat$while$while$if$block$SegmentlengthINtegerAtNullCompileTimeConstant$TypeMatch ; skip next block if the type matches
        ; Error handling block for <segmentLength: Integer at null; compile-time constant>
        ;  - print(operandTypeCheckFailureMessage)
        mov [rbp+028h], rcx                                      ; save rcx in shadow space
        mov [rbp+030h], rdx                                      ; save rdx in shadow space
        mov [rbp+038h], r8                                       ; save r8 in shadow space
        mov [rbp+040h], r9                                       ; save r9 in shadow space
        mov r11, offset operandTypeCheckFailureMessage           ; value of argument #1
        push r11                                                 ; (indirect via r11 because "operandTypeCheckFailureMessage" is an imm64)
        push 000000016h                                          ; type of argument #1
        lea r10, [rbp-0448h]                                     ; pointer to return value (and type, 8 bytes earlier)
        push r10                                                 ; (that pointer is the last value pushed to the stack)
        mov qword ptr r9, 0h                                     ; pointer to this
        mov qword ptr r8, 000000000h                             ; type of this
        mov qword ptr rdx, 0h                                    ; pointer to closure
        mov rcx, 1                                               ; number of arguments
        sub rsp, 20h                                             ; allocate shadow space
        call offset func$__print                                 ; jump to subroutine
        add rsp, 038h                                            ; release shadow space and arguments
        mov rcx, [rbp+028h]                                      ; restore rcx from shadow space
        mov rdx, [rbp+030h]                                      ; restore rdx from shadow space
        mov r8, [rbp+038h]                                       ; restore r8 from shadow space
        mov r9, [rbp+040h]                                       ; restore r9 from shadow space
        ;  - exit(1)
        mov [rbp+028h], rcx                                      ; save rcx in shadow space
        mov [rbp+030h], rdx                                      ; save rdx in shadow space
        mov [rbp+038h], r8                                       ; save r8 in shadow space
        mov [rbp+040h], r9                                       ; save r9 in shadow space
        push 000000001h                                          ; value of argument #1
        push 000000015h                                          ; type of argument #1
        lea r10, [rbp-0458h]                                     ; pointer to return value (and type, 8 bytes earlier)
        push r10                                                 ; (that pointer is the last value pushed to the stack)
        mov qword ptr r9, 0h                                     ; pointer to this
        mov qword ptr r8, 000000000h                             ; type of this
        mov qword ptr rdx, 0h                                    ; pointer to closure
        mov rcx, 1                                               ; number of arguments
        sub rsp, 20h                                             ; allocate shadow space
        call offset func$exit                                    ; jump to subroutine
        add rsp, 038h                                            ; release shadow space and arguments
        mov rcx, [rbp+028h]                                      ; restore rcx from shadow space
        mov rdx, [rbp+030h]                                      ; restore rdx from shadow space
        mov r8, [rbp+038h]                                       ; restore r8 from shadow space
        mov r9, [rbp+040h]                                       ; restore r9 from shadow space
      func$concat$while$while$if$block$SegmentlengthINtegerAtNullCompileTimeConstant$TypeMatch:
      mov r10, [rbp-0288h]                                       ; add mutates first operand, so indirect via register
      add r10, [rbp-0338h]                                       ; += operator
      mov [rbp-0418h], r10                                       ; store result
      mov qword ptr [rbp-0420h], 000000015h                      ; store type
      mov r11, [rbp-0418h]                                       ; value of cursor
      mov [rbp-0288h], r11                                       ; (indirect via r11 because mov can't do memory-to-memory)
      mov r11, [rbp-0420h]                                       ; type of cursor
      mov [rbp-0290h], r11                                       ; (indirect via r11 because mov can't do memory-to-memory)
    func$concat$while$if$continuation:                           ; end of if
    ; Line 86: index += 1;
    mov rax, [rbp-040h]                                          ; load the dynamic type of <index: Integer at null; compile-time constant> into rax
    lea r10, typeTable                                           ; move type table offset into r10
    add rax, r10                                                 ; adjust rax to point to the type table
    bt qword ptr [rax], 2                                        ; check that <index: Integer at null; compile-time constant> is Integer'21
    jc func$concat$while$IndexINtegerAtNullCompileTimeConstant$TypeMatch$1 ; skip next block if the type matches
      ; Error handling block for <index: Integer at null; compile-time constant>
      ;  - print(operandTypeCheckFailureMessage)
      mov [rbp+028h], rcx                                        ; save rcx in shadow space
      mov [rbp+030h], rdx                                        ; save rdx in shadow space
      mov [rbp+038h], r8                                         ; save r8 in shadow space
      mov [rbp+040h], r9                                         ; save r9 in shadow space
      mov r11, offset operandTypeCheckFailureMessage             ; value of argument #1
      push r11                                                   ; (indirect via r11 because "operandTypeCheckFailureMessage" is an imm64)
      push 000000016h                                            ; type of argument #1
      lea r10, [rbp-0478h]                                       ; pointer to return value (and type, 8 bytes earlier)
      push r10                                                   ; (that pointer is the last value pushed to the stack)
      mov qword ptr r9, 0h                                       ; pointer to this
      mov qword ptr r8, 000000000h                               ; type of this
      mov qword ptr rdx, 0h                                      ; pointer to closure
      mov rcx, 1                                                 ; number of arguments
      sub rsp, 20h                                               ; allocate shadow space
      call offset func$__print                                   ; jump to subroutine
      add rsp, 038h                                              ; release shadow space and arguments
      mov rcx, [rbp+028h]                                        ; restore rcx from shadow space
      mov rdx, [rbp+030h]                                        ; restore rdx from shadow space
      mov r8, [rbp+038h]                                         ; restore r8 from shadow space
      mov r9, [rbp+040h]                                         ; restore r9 from shadow space
      ;  - exit(1)
      mov [rbp+028h], rcx                                        ; save rcx in shadow space
      mov [rbp+030h], rdx                                        ; save rdx in shadow space
      mov [rbp+038h], r8                                         ; save r8 in shadow space
      mov [rbp+040h], r9                                         ; save r9 in shadow space
      push 000000001h                                            ; value of argument #1
      push 000000015h                                            ; type of argument #1
      lea r10, [rbp-0488h]                                       ; pointer to return value (and type, 8 bytes earlier)
      push r10                                                   ; (that pointer is the last value pushed to the stack)
      mov qword ptr r9, 0h                                       ; pointer to this
      mov qword ptr r8, 000000000h                               ; type of this
      mov qword ptr rdx, 0h                                      ; pointer to closure
      mov rcx, 1                                                 ; number of arguments
      sub rsp, 20h                                               ; allocate shadow space
      call offset func$exit                                      ; jump to subroutine
      add rsp, 038h                                              ; release shadow space and arguments
      mov rcx, [rbp+028h]                                        ; restore rcx from shadow space
      mov rdx, [rbp+030h]                                        ; restore rdx from shadow space
      mov r8, [rbp+038h]                                         ; restore r8 from shadow space
      mov r9, [rbp+040h]                                         ; restore r9 from shadow space
    func$concat$while$IndexINtegerAtNullCompileTimeConstant$TypeMatch$1:
    mov r10, [rbp-038h]                                          ; add mutates first operand, so indirect via register
    add r10, 000000001h                                          ; += operator
    mov [rbp-0468h], r10                                         ; store result
    mov qword ptr [rbp-0470h], 000000015h                        ; store type
    mov r11, [rbp-0468h]                                         ; value of index
    mov [rbp-038h], r11                                          ; (indirect via r11 because mov can't do memory-to-memory)
    mov r11, [rbp-0470h]                                         ; type of index
    mov [rbp-040h], r11                                          ; (indirect via r11 because mov can't do memory-to-memory)
    jmp func$concat$while$top$1                                  ; return to top of while
  func$concat$while$bottom$1:
  ; Line 88: return resultPointer __as__ String;
  mov r11, [rbp-01d8h]                                           ; value of force cast of resultPointer to String
  mov [rbp-04b8h], r11                                           ; (indirect via r11 because mov can't do memory-to-memory)
  mov qword ptr [rbp-04c0h], 000000016h                          ; new type of force cast of resultPointer to String
  mov rax, [rbp-04c0h]                                           ; load the dynamic type of return value of concat into rax
  lea r10, typeTable                                             ; move type table offset into r10
  add rax, r10                                                   ; adjust rax to point to the type table
  bt qword ptr [rax], 3                                          ; check that return value of concat is String'22
  jc func$concat$returnValueOfConcat$TypeMatch                   ; skip next block if the type matches
    ; Error handling block for return value of concat
    ;  - print(returnValueTypeCheckFailureMessage)
    mov [rbp+028h], rcx                                          ; save rcx in shadow space
    mov [rbp+030h], rdx                                          ; save rdx in shadow space
    mov [rbp+038h], r8                                           ; save r8 in shadow space
    mov [rbp+040h], r9                                           ; save r9 in shadow space
    mov r11, offset returnValueTypeCheckFailureMessage           ; value of argument #1
    push r11                                                     ; (indirect via r11 because "returnValueTypeCheckFailureMessage" is an imm64)
    push 000000016h                                              ; type of argument #1
    lea r10, [rbp-04c8h]                                         ; pointer to return value (and type, 8 bytes earlier)
    push r10                                                     ; (that pointer is the last value pushed to the stack)
    mov qword ptr r9, 0h                                         ; pointer to this
    mov qword ptr r8, 000000000h                                 ; type of this
    mov qword ptr rdx, 0h                                        ; pointer to closure
    mov rcx, 1                                                   ; number of arguments
    sub rsp, 20h                                                 ; allocate shadow space
    call offset func$__print                                     ; jump to subroutine
    add rsp, 038h                                                ; release shadow space and arguments
    mov rcx, [rbp+028h]                                          ; restore rcx from shadow space
    mov rdx, [rbp+030h]                                          ; restore rdx from shadow space
    mov r8, [rbp+038h]                                           ; restore r8 from shadow space
    mov r9, [rbp+040h]                                           ; restore r9 from shadow space
    ;  - exit(1)
    mov [rbp+028h], rcx                                          ; save rcx in shadow space
    mov [rbp+030h], rdx                                          ; save rdx in shadow space
    mov [rbp+038h], r8                                           ; save r8 in shadow space
    mov [rbp+040h], r9                                           ; save r9 in shadow space
    push 000000001h                                              ; value of argument #1
    push 000000015h                                              ; type of argument #1
    lea r10, [rbp-04d8h]                                         ; pointer to return value (and type, 8 bytes earlier)
    push r10                                                     ; (that pointer is the last value pushed to the stack)
    mov qword ptr r9, 0h                                         ; pointer to this
    mov qword ptr r8, 000000000h                                 ; type of this
    mov qword ptr rdx, 0h                                        ; pointer to closure
    mov rcx, 1                                                   ; number of arguments
    sub rsp, 20h                                                 ; allocate shadow space
    call offset func$exit                                        ; jump to subroutine
    add rsp, 038h                                                ; release shadow space and arguments
    mov rcx, [rbp+028h]                                          ; restore rcx from shadow space
    mov rdx, [rbp+030h]                                          ; restore rdx from shadow space
    mov r8, [rbp+038h]                                           ; restore r8 from shadow space
    mov r9, [rbp+040h]                                           ; restore r9 from shadow space
  func$concat$returnValueOfConcat$TypeMatch:
  mov r11, [rbp-04b8h]                                           ; value of return value
  mov [r15], r11                                                 ; (indirect via r11 because mov can't do memory-to-memory)
  mov r11, [rbp-04c0h]                                           ; type of return value
  mov [r15-08h], r11                                             ; (indirect via r11 because mov can't do memory-to-memory)
  jmp func$concat$epilog                                         ; return
  func$concat$epilog:
  mov rax, r15                                                   ; report address of return value
  ; Epilog
  add rsp, 04e0h                                                 ; free space for stack
  pop rdi                                                        ; restore non-volatile registers
  pop rsi                                                        ; restore non-volatile registers
  pop r15                                                        ; restore non-volatile registers
  pop rbp                                                        ; restore non-volatile registers
  ret                                                            ; return from subroutine

; digitToStr
func$digitToStr:
  ; Prolog
  push rbp                                                       ; save non-volatile registers
  push r15                                                       ; save non-volatile registers
  sub rsp, 0240h                                                 ; allocate space for stack
  lea rbp, [rsp+0240h]                                           ; set up frame pointer
  mov r15, [rbp+038h]                                            ; prepare return value
  ; Check parameter count
  cmp qword ptr rcx, 000000001h                                  ; compare parameter count to integers
  je func$digitToStr$parameterCount$continuation                 ; check number of parameters is as expected
    ; Error handling block for parameter count
    ;  - print(parameterCountCheckFailureMessage)
    mov [rbp+018h], rcx                                          ; save rcx in shadow space
    mov [rbp+020h], rdx                                          ; save rdx in shadow space
    mov [rbp+028h], r8                                           ; save r8 in shadow space
    mov [rbp+030h], r9                                           ; save r9 in shadow space
    mov r11, offset parameterCountCheckFailureMessage            ; value of argument #1
    push r11                                                     ; (indirect via r11 because "parameterCountCheckFailureMessage" is an imm64)
    push 000000016h                                              ; type of argument #1
    lea r10, [rbp-008h]                                          ; pointer to return value (and type, 8 bytes earlier)
    push r10                                                     ; (that pointer is the last value pushed to the stack)
    mov qword ptr r9, 0h                                         ; pointer to this
    mov qword ptr r8, 000000000h                                 ; type of this
    mov qword ptr rdx, 0h                                        ; pointer to closure
    mov rcx, 1                                                   ; number of arguments
    sub rsp, 20h                                                 ; allocate shadow space
    call offset func$__print                                     ; jump to subroutine
    add rsp, 038h                                                ; release shadow space and arguments
    mov rcx, [rbp+018h]                                          ; restore rcx from shadow space
    mov rdx, [rbp+020h]                                          ; restore rdx from shadow space
    mov r8, [rbp+028h]                                           ; restore r8 from shadow space
    mov r9, [rbp+030h]                                           ; restore r9 from shadow space
    ;  - exit(1)
    mov [rbp+018h], rcx                                          ; save rcx in shadow space
    mov [rbp+020h], rdx                                          ; save rdx in shadow space
    mov [rbp+028h], r8                                           ; save r8 in shadow space
    mov [rbp+030h], r9                                           ; save r9 in shadow space
    push 000000001h                                              ; value of argument #1
    push 000000015h                                              ; type of argument #1
    lea r10, [rbp-018h]                                          ; pointer to return value (and type, 8 bytes earlier)
    push r10                                                     ; (that pointer is the last value pushed to the stack)
    mov qword ptr r9, 0h                                         ; pointer to this
    mov qword ptr r8, 000000000h                                 ; type of this
    mov qword ptr rdx, 0h                                        ; pointer to closure
    mov rcx, 1                                                   ; number of arguments
    sub rsp, 20h                                                 ; allocate shadow space
    call offset func$exit                                        ; jump to subroutine
    add rsp, 038h                                                ; release shadow space and arguments
    mov rcx, [rbp+018h]                                          ; restore rcx from shadow space
    mov rdx, [rbp+020h]                                          ; restore rdx from shadow space
    mov r8, [rbp+028h]                                           ; restore r8 from shadow space
    mov r9, [rbp+030h]                                           ; restore r9 from shadow space
  func$digitToStr$parameterCount$continuation:                   ; end of parameter count
  ; Check type of parameter 0, digit (expecting Integer)
  mov rax, [rbp+040h]                                            ; load the dynamic type of digit into rax
  lea r10, typeTable                                             ; move type table offset into r10
  add rax, r10                                                   ; adjust rax to point to the type table
  bt qword ptr [rax], 2                                          ; check that digit is Integer'21
  jc func$digitToStr$digit$TypeMatch                             ; skip next block if the type matches
    ; Error handling block for digit
    ;  - print(parameterTypeCheckFailureMessage)
    mov [rbp+018h], rcx                                          ; save rcx in shadow space
    mov [rbp+020h], rdx                                          ; save rdx in shadow space
    mov [rbp+028h], r8                                           ; save r8 in shadow space
    mov [rbp+030h], r9                                           ; save r9 in shadow space
    mov r11, offset parameterTypeCheckFailureMessage             ; value of argument #1
    push r11                                                     ; (indirect via r11 because "parameterTypeCheckFailureMessage" is an imm64)
    push 000000016h                                              ; type of argument #1
    lea r10, [rbp-028h]                                          ; pointer to return value (and type, 8 bytes earlier)
    push r10                                                     ; (that pointer is the last value pushed to the stack)
    mov qword ptr r9, 0h                                         ; pointer to this
    mov qword ptr r8, 000000000h                                 ; type of this
    mov qword ptr rdx, 0h                                        ; pointer to closure
    mov rcx, 1                                                   ; number of arguments
    sub rsp, 20h                                                 ; allocate shadow space
    call offset func$__print                                     ; jump to subroutine
    add rsp, 038h                                                ; release shadow space and arguments
    mov rcx, [rbp+018h]                                          ; restore rcx from shadow space
    mov rdx, [rbp+020h]                                          ; restore rdx from shadow space
    mov r8, [rbp+028h]                                           ; restore r8 from shadow space
    mov r9, [rbp+030h]                                           ; restore r9 from shadow space
    ;  - exit(1)
    mov [rbp+018h], rcx                                          ; save rcx in shadow space
    mov [rbp+020h], rdx                                          ; save rdx in shadow space
    mov [rbp+028h], r8                                           ; save r8 in shadow space
    mov [rbp+030h], r9                                           ; save r9 in shadow space
    push 000000001h                                              ; value of argument #1
    push 000000015h                                              ; type of argument #1
    lea r10, [rbp-038h]                                          ; pointer to return value (and type, 8 bytes earlier)
    push r10                                                     ; (that pointer is the last value pushed to the stack)
    mov qword ptr r9, 0h                                         ; pointer to this
    mov qword ptr r8, 000000000h                                 ; type of this
    mov qword ptr rdx, 0h                                        ; pointer to closure
    mov rcx, 1                                                   ; number of arguments
    sub rsp, 20h                                                 ; allocate shadow space
    call offset func$exit                                        ; jump to subroutine
    add rsp, 038h                                                ; release shadow space and arguments
    mov rcx, [rbp+018h]                                          ; restore rcx from shadow space
    mov rdx, [rbp+020h]                                          ; restore rdx from shadow space
    mov r8, [rbp+028h]                                           ; restore r8 from shadow space
    mov r9, [rbp+030h]                                           ; restore r9 from shadow space
  func$digitToStr$digit$TypeMatch:
  ; Line 92: if (digit == 0) { ...
  xor r10, r10                                                   ; prepare r10 for result of value comparison
  cmp qword ptr [rbp+048h], 000000000h                           ; compare digit to 0
  sete byte ptr r10b                                             ; store result in r10
  xor rax, rax                                                   ; prepare rax for result of type comparison
  cmp qword ptr [rbp+040h], 000000015h                           ; compare type of digit to type of 0
  sete byte ptr al                                               ; store result in rax
  and r10, rax                                                   ; true if type and value are both equal; result goes into r10
  mov [rbp-048h], r10                                            ; store result in == operator result
  mov qword ptr [rbp-050h], 000000014h                           ; == operator result is a Boolean
  cmp qword ptr [rbp-048h], 000000000h                           ; compare == operator result to false
  je func$digitToStr$if$continuation                             ; digit == 0
    ; Line 93: return '0';
    mov r11, offset string$4                                     ; value of return value
    mov [r15], r11                                               ; (indirect via r11 because "string$4" is an imm64)
    mov qword ptr [r15-08h], 000000016h                          ; type of return value
    jmp func$digitToStr$epilog                                   ; return
  func$digitToStr$if$continuation:                               ; end of if
  ; Line 95: if (digit == 1) { ...
  xor r10, r10                                                   ; prepare r10 for result of value comparison
  cmp qword ptr [rbp+048h], 000000001h                           ; compare digit to 1
  sete byte ptr r10b                                             ; store result in r10
  xor rax, rax                                                   ; prepare rax for result of type comparison
  cmp qword ptr [rbp+040h], 000000015h                           ; compare type of digit to type of 1
  sete byte ptr al                                               ; store result in rax
  and r10, rax                                                   ; true if type and value are both equal; result goes into r10
  mov [rbp-078h], r10                                            ; store result in == operator result
  mov qword ptr [rbp-080h], 000000014h                           ; == operator result is a Boolean
  cmp qword ptr [rbp-078h], 000000000h                           ; compare == operator result to false
  je func$digitToStr$if$continuation$1                           ; digit == 1
    ; Line 96: return '1';
    mov r11, offset string$5                                     ; value of return value
    mov [r15], r11                                               ; (indirect via r11 because "string$5" is an imm64)
    mov qword ptr [r15-08h], 000000016h                          ; type of return value
    jmp func$digitToStr$epilog                                   ; return
  func$digitToStr$if$continuation$1:                             ; end of if
  ; Line 98: if (digit == 2) { ...
  xor r10, r10                                                   ; prepare r10 for result of value comparison
  cmp qword ptr [rbp+048h], 000000002h                           ; compare digit to 2
  sete byte ptr r10b                                             ; store result in r10
  xor rax, rax                                                   ; prepare rax for result of type comparison
  cmp qword ptr [rbp+040h], 000000015h                           ; compare type of digit to type of 2
  sete byte ptr al                                               ; store result in rax
  and r10, rax                                                   ; true if type and value are both equal; result goes into r10
  mov [rbp-0a8h], r10                                            ; store result in == operator result
  mov qword ptr [rbp-0b0h], 000000014h                           ; == operator result is a Boolean
  cmp qword ptr [rbp-0a8h], 000000000h                           ; compare == operator result to false
  je func$digitToStr$if$continuation$2                           ; digit == 2
    ; Line 99: return '2';
    mov r11, offset string$6                                     ; value of return value
    mov [r15], r11                                               ; (indirect via r11 because "string$6" is an imm64)
    mov qword ptr [r15-08h], 000000016h                          ; type of return value
    jmp func$digitToStr$epilog                                   ; return
  func$digitToStr$if$continuation$2:                             ; end of if
  ; Line 101: if (digit == 3) { ...
  xor r10, r10                                                   ; prepare r10 for result of value comparison
  cmp qword ptr [rbp+048h], 000000003h                           ; compare digit to 3
  sete byte ptr r10b                                             ; store result in r10
  xor rax, rax                                                   ; prepare rax for result of type comparison
  cmp qword ptr [rbp+040h], 000000015h                           ; compare type of digit to type of 3
  sete byte ptr al                                               ; store result in rax
  and r10, rax                                                   ; true if type and value are both equal; result goes into r10
  mov [rbp-0d8h], r10                                            ; store result in == operator result
  mov qword ptr [rbp-0e0h], 000000014h                           ; == operator result is a Boolean
  cmp qword ptr [rbp-0d8h], 000000000h                           ; compare == operator result to false
  je func$digitToStr$if$continuation$3                           ; digit == 3
    ; Line 102: return '3';
    mov r11, offset string$7                                     ; value of return value
    mov [r15], r11                                               ; (indirect via r11 because "string$7" is an imm64)
    mov qword ptr [r15-08h], 000000016h                          ; type of return value
    jmp func$digitToStr$epilog                                   ; return
  func$digitToStr$if$continuation$3:                             ; end of if
  ; Line 104: if (digit == 4) { ...
  xor r10, r10                                                   ; prepare r10 for result of value comparison
  cmp qword ptr [rbp+048h], 000000004h                           ; compare digit to 4
  sete byte ptr r10b                                             ; store result in r10
  xor rax, rax                                                   ; prepare rax for result of type comparison
  cmp qword ptr [rbp+040h], 000000015h                           ; compare type of digit to type of 4
  sete byte ptr al                                               ; store result in rax
  and r10, rax                                                   ; true if type and value are both equal; result goes into r10
  mov [rbp-0108h], r10                                           ; store result in == operator result
  mov qword ptr [rbp-0110h], 000000014h                          ; == operator result is a Boolean
  cmp qword ptr [rbp-0108h], 000000000h                          ; compare == operator result to false
  je func$digitToStr$if$continuation$4                           ; digit == 4
    ; Line 105: return '4';
    mov r11, offset string$8                                     ; value of return value
    mov [r15], r11                                               ; (indirect via r11 because "string$8" is an imm64)
    mov qword ptr [r15-08h], 000000016h                          ; type of return value
    jmp func$digitToStr$epilog                                   ; return
  func$digitToStr$if$continuation$4:                             ; end of if
  ; Line 107: if (digit == 5) { ...
  xor r10, r10                                                   ; prepare r10 for result of value comparison
  cmp qword ptr [rbp+048h], 000000005h                           ; compare digit to 5
  sete byte ptr r10b                                             ; store result in r10
  xor rax, rax                                                   ; prepare rax for result of type comparison
  cmp qword ptr [rbp+040h], 000000015h                           ; compare type of digit to type of 5
  sete byte ptr al                                               ; store result in rax
  and r10, rax                                                   ; true if type and value are both equal; result goes into r10
  mov [rbp-0138h], r10                                           ; store result in == operator result
  mov qword ptr [rbp-0140h], 000000014h                          ; == operator result is a Boolean
  cmp qword ptr [rbp-0138h], 000000000h                          ; compare == operator result to false
  je func$digitToStr$if$continuation$5                           ; digit == 5
    ; Line 108: return '5';
    mov r11, offset string$9                                     ; value of return value
    mov [r15], r11                                               ; (indirect via r11 because "string$9" is an imm64)
    mov qword ptr [r15-08h], 000000016h                          ; type of return value
    jmp func$digitToStr$epilog                                   ; return
  func$digitToStr$if$continuation$5:                             ; end of if
  ; Line 110: if (digit == 6) { ...
  xor r10, r10                                                   ; prepare r10 for result of value comparison
  cmp qword ptr [rbp+048h], 000000006h                           ; compare digit to 6
  sete byte ptr r10b                                             ; store result in r10
  xor rax, rax                                                   ; prepare rax for result of type comparison
  cmp qword ptr [rbp+040h], 000000015h                           ; compare type of digit to type of 6
  sete byte ptr al                                               ; store result in rax
  and r10, rax                                                   ; true if type and value are both equal; result goes into r10
  mov [rbp-0168h], r10                                           ; store result in == operator result
  mov qword ptr [rbp-0170h], 000000014h                          ; == operator result is a Boolean
  cmp qword ptr [rbp-0168h], 000000000h                          ; compare == operator result to false
  je func$digitToStr$if$continuation$6                           ; digit == 6
    ; Line 111: return '6';
    mov r11, offset string$10                                    ; value of return value
    mov [r15], r11                                               ; (indirect via r11 because "string$10" is an imm64)
    mov qword ptr [r15-08h], 000000016h                          ; type of return value
    jmp func$digitToStr$epilog                                   ; return
  func$digitToStr$if$continuation$6:                             ; end of if
  ; Line 113: if (digit == 7) { ...
  xor r10, r10                                                   ; prepare r10 for result of value comparison
  cmp qword ptr [rbp+048h], 000000007h                           ; compare digit to 7
  sete byte ptr r10b                                             ; store result in r10
  xor rax, rax                                                   ; prepare rax for result of type comparison
  cmp qword ptr [rbp+040h], 000000015h                           ; compare type of digit to type of 7
  sete byte ptr al                                               ; store result in rax
  and r10, rax                                                   ; true if type and value are both equal; result goes into r10
  mov [rbp-0198h], r10                                           ; store result in == operator result
  mov qword ptr [rbp-01a0h], 000000014h                          ; == operator result is a Boolean
  cmp qword ptr [rbp-0198h], 000000000h                          ; compare == operator result to false
  je func$digitToStr$if$continuation$7                           ; digit == 7
    ; Line 114: return '7';
    mov r11, offset string$11                                    ; value of return value
    mov [r15], r11                                               ; (indirect via r11 because "string$11" is an imm64)
    mov qword ptr [r15-08h], 000000016h                          ; type of return value
    jmp func$digitToStr$epilog                                   ; return
  func$digitToStr$if$continuation$7:                             ; end of if
  ; Line 116: if (digit == 8) { ...
  xor r10, r10                                                   ; prepare r10 for result of value comparison
  cmp qword ptr [rbp+048h], 000000008h                           ; compare digit to 8
  sete byte ptr r10b                                             ; store result in r10
  xor rax, rax                                                   ; prepare rax for result of type comparison
  cmp qword ptr [rbp+040h], 000000015h                           ; compare type of digit to type of 8
  sete byte ptr al                                               ; store result in rax
  and r10, rax                                                   ; true if type and value are both equal; result goes into r10
  mov [rbp-01c8h], r10                                           ; store result in == operator result
  mov qword ptr [rbp-01d0h], 000000014h                          ; == operator result is a Boolean
  cmp qword ptr [rbp-01c8h], 000000000h                          ; compare == operator result to false
  je func$digitToStr$if$continuation$8                           ; digit == 8
    ; Line 117: return '8';
    mov r11, offset string$12                                    ; value of return value
    mov [r15], r11                                               ; (indirect via r11 because "string$12" is an imm64)
    mov qword ptr [r15-08h], 000000016h                          ; type of return value
    jmp func$digitToStr$epilog                                   ; return
  func$digitToStr$if$continuation$8:                             ; end of if
  ; Line 119: if (digit == 9) { ...
  xor r10, r10                                                   ; prepare r10 for result of value comparison
  cmp qword ptr [rbp+048h], 000000009h                           ; compare digit to 9
  sete byte ptr r10b                                             ; store result in r10
  xor rax, rax                                                   ; prepare rax for result of type comparison
  cmp qword ptr [rbp+040h], 000000015h                           ; compare type of digit to type of 9
  sete byte ptr al                                               ; store result in rax
  and r10, rax                                                   ; true if type and value are both equal; result goes into r10
  mov [rbp-01f8h], r10                                           ; store result in == operator result
  mov qword ptr [rbp-0200h], 000000014h                          ; == operator result is a Boolean
  cmp qword ptr [rbp-01f8h], 000000000h                          ; compare == operator result to false
  je func$digitToStr$if$continuation$9                           ; digit == 9
    ; Line 120: return '9';
    mov r11, offset string$13                                    ; value of return value
    mov [r15], r11                                               ; (indirect via r11 because "string$13" is an imm64)
    mov qword ptr [r15-08h], 000000016h                          ; type of return value
    jmp func$digitToStr$epilog                                   ; return
  func$digitToStr$if$continuation$9:                             ; end of if
  ; Line 122: __print('Invalid digit passed to digitToStr (digit as exit code)...
  mov [rbp+018h], rcx                                            ; save rcx in shadow space
  mov [rbp+020h], rdx                                            ; save rdx in shadow space
  mov [rbp+028h], r8                                             ; save r8 in shadow space
  mov [rbp+030h], r9                                             ; save r9 in shadow space
  mov r11, offset string$14                                      ; value of argument #1
  push r11                                                       ; (indirect via r11 because "string$14" is an imm64)
  push 000000016h                                                ; type of argument #1
  lea r10, [rbp-0228h]                                           ; pointer to return value (and type, 8 bytes earlier)
  push r10                                                       ; (that pointer is the last value pushed to the stack)
  mov qword ptr r9, 0h                                           ; pointer to this
  mov qword ptr r8, 000000000h                                   ; type of this
  mov qword ptr rdx, 0h                                          ; pointer to closure
  mov rcx, 1                                                     ; number of arguments
  sub rsp, 20h                                                   ; allocate shadow space
  call offset func$__print                                       ; jump to subroutine
  add rsp, 038h                                                  ; release shadow space and arguments
  mov rcx, [rbp+018h]                                            ; restore rcx from shadow space
  mov rdx, [rbp+020h]                                            ; restore rdx from shadow space
  mov r8, [rbp+028h]                                             ; restore r8 from shadow space
  mov r9, [rbp+030h]                                             ; restore r9 from shadow space
  ; Line 123: exit(digit);
  mov [rbp+018h], rcx                                            ; save rcx in shadow space
  mov [rbp+020h], rdx                                            ; save rdx in shadow space
  mov [rbp+028h], r8                                             ; save r8 in shadow space
  mov [rbp+030h], r9                                             ; save r9 in shadow space
  push [rbp+048h]                                                ; value of argument #1
  push [rbp+040h]                                                ; type of argument #1
  lea r10, [rbp-0238h]                                           ; pointer to return value (and type, 8 bytes earlier)
  push r10                                                       ; (that pointer is the last value pushed to the stack)
  mov qword ptr r9, 0h                                           ; pointer to this
  mov qword ptr r8, 000000000h                                   ; type of this
  mov qword ptr rdx, 0h                                          ; pointer to closure
  mov rcx, 1                                                     ; number of arguments
  sub rsp, 20h                                                   ; allocate shadow space
  call offset func$exit                                          ; jump to subroutine
  add rsp, 038h                                                  ; release shadow space and arguments
  mov rcx, [rbp+018h]                                            ; restore rcx from shadow space
  mov rdx, [rbp+020h]                                            ; restore rdx from shadow space
  mov r8, [rbp+028h]                                             ; restore r8 from shadow space
  mov r9, [rbp+030h]                                             ; restore r9 from shadow space
  func$digitToStr$epilog:
  mov rax, r15                                                   ; report address of return value
  ; Epilog
  add rsp, 0240h                                                 ; free space for stack
  pop r15                                                        ; restore non-volatile registers
  pop rbp                                                        ; restore non-volatile registers
  ret                                                            ; return from subroutine

; intToStr
func$intToStr:
  ; Prolog
  push rbp                                                       ; save non-volatile registers
  push r15                                                       ; save non-volatile registers
  sub rsp, 01d0h                                                 ; allocate space for stack
  lea rbp, [rsp+01d0h]                                           ; set up frame pointer
  mov r15, [rbp+038h]                                            ; prepare return value
  ; Check parameter count
  cmp qword ptr rcx, 000000001h                                  ; compare parameter count to integers
  je func$intToStr$parameterCount$continuation                   ; check number of parameters is as expected
    ; Error handling block for parameter count
    ;  - print(parameterCountCheckFailureMessage)
    mov [rbp+018h], rcx                                          ; save rcx in shadow space
    mov [rbp+020h], rdx                                          ; save rdx in shadow space
    mov [rbp+028h], r8                                           ; save r8 in shadow space
    mov [rbp+030h], r9                                           ; save r9 in shadow space
    mov r11, offset parameterCountCheckFailureMessage            ; value of argument #1
    push r11                                                     ; (indirect via r11 because "parameterCountCheckFailureMessage" is an imm64)
    push 000000016h                                              ; type of argument #1
    lea r10, [rbp-008h]                                          ; pointer to return value (and type, 8 bytes earlier)
    push r10                                                     ; (that pointer is the last value pushed to the stack)
    mov qword ptr r9, 0h                                         ; pointer to this
    mov qword ptr r8, 000000000h                                 ; type of this
    mov qword ptr rdx, 0h                                        ; pointer to closure
    mov rcx, 1                                                   ; number of arguments
    sub rsp, 20h                                                 ; allocate shadow space
    call offset func$__print                                     ; jump to subroutine
    add rsp, 038h                                                ; release shadow space and arguments
    mov rcx, [rbp+018h]                                          ; restore rcx from shadow space
    mov rdx, [rbp+020h]                                          ; restore rdx from shadow space
    mov r8, [rbp+028h]                                           ; restore r8 from shadow space
    mov r9, [rbp+030h]                                           ; restore r9 from shadow space
    ;  - exit(1)
    mov [rbp+018h], rcx                                          ; save rcx in shadow space
    mov [rbp+020h], rdx                                          ; save rdx in shadow space
    mov [rbp+028h], r8                                           ; save r8 in shadow space
    mov [rbp+030h], r9                                           ; save r9 in shadow space
    push 000000001h                                              ; value of argument #1
    push 000000015h                                              ; type of argument #1
    lea r10, [rbp-018h]                                          ; pointer to return value (and type, 8 bytes earlier)
    push r10                                                     ; (that pointer is the last value pushed to the stack)
    mov qword ptr r9, 0h                                         ; pointer to this
    mov qword ptr r8, 000000000h                                 ; type of this
    mov qword ptr rdx, 0h                                        ; pointer to closure
    mov rcx, 1                                                   ; number of arguments
    sub rsp, 20h                                                 ; allocate shadow space
    call offset func$exit                                        ; jump to subroutine
    add rsp, 038h                                                ; release shadow space and arguments
    mov rcx, [rbp+018h]                                          ; restore rcx from shadow space
    mov rdx, [rbp+020h]                                          ; restore rdx from shadow space
    mov r8, [rbp+028h]                                           ; restore r8 from shadow space
    mov r9, [rbp+030h]                                           ; restore r9 from shadow space
  func$intToStr$parameterCount$continuation:                     ; end of parameter count
  ; Check type of parameter 0, value (expecting Integer)
  mov rax, [rbp+040h]                                            ; load the dynamic type of value into rax
  lea r10, typeTable                                             ; move type table offset into r10
  add rax, r10                                                   ; adjust rax to point to the type table
  bt qword ptr [rax], 2                                          ; check that value is Integer'21
  jc func$intToStr$value$TypeMatch                               ; skip next block if the type matches
    ; Error handling block for value
    ;  - print(parameterTypeCheckFailureMessage)
    mov [rbp+018h], rcx                                          ; save rcx in shadow space
    mov [rbp+020h], rdx                                          ; save rdx in shadow space
    mov [rbp+028h], r8                                           ; save r8 in shadow space
    mov [rbp+030h], r9                                           ; save r9 in shadow space
    mov r11, offset parameterTypeCheckFailureMessage             ; value of argument #1
    push r11                                                     ; (indirect via r11 because "parameterTypeCheckFailureMessage" is an imm64)
    push 000000016h                                              ; type of argument #1
    lea r10, [rbp-028h]                                          ; pointer to return value (and type, 8 bytes earlier)
    push r10                                                     ; (that pointer is the last value pushed to the stack)
    mov qword ptr r9, 0h                                         ; pointer to this
    mov qword ptr r8, 000000000h                                 ; type of this
    mov qword ptr rdx, 0h                                        ; pointer to closure
    mov rcx, 1                                                   ; number of arguments
    sub rsp, 20h                                                 ; allocate shadow space
    call offset func$__print                                     ; jump to subroutine
    add rsp, 038h                                                ; release shadow space and arguments
    mov rcx, [rbp+018h]                                          ; restore rcx from shadow space
    mov rdx, [rbp+020h]                                          ; restore rdx from shadow space
    mov r8, [rbp+028h]                                           ; restore r8 from shadow space
    mov r9, [rbp+030h]                                           ; restore r9 from shadow space
    ;  - exit(1)
    mov [rbp+018h], rcx                                          ; save rcx in shadow space
    mov [rbp+020h], rdx                                          ; save rdx in shadow space
    mov [rbp+028h], r8                                           ; save r8 in shadow space
    mov [rbp+030h], r9                                           ; save r9 in shadow space
    push 000000001h                                              ; value of argument #1
    push 000000015h                                              ; type of argument #1
    lea r10, [rbp-038h]                                          ; pointer to return value (and type, 8 bytes earlier)
    push r10                                                     ; (that pointer is the last value pushed to the stack)
    mov qword ptr r9, 0h                                         ; pointer to this
    mov qword ptr r8, 000000000h                                 ; type of this
    mov qword ptr rdx, 0h                                        ; pointer to closure
    mov rcx, 1                                                   ; number of arguments
    sub rsp, 20h                                                 ; allocate shadow space
    call offset func$exit                                        ; jump to subroutine
    add rsp, 038h                                                ; release shadow space and arguments
    mov rcx, [rbp+018h]                                          ; restore rcx from shadow space
    mov rdx, [rbp+020h]                                          ; restore rdx from shadow space
    mov r8, [rbp+028h]                                           ; restore r8 from shadow space
    mov r9, [rbp+030h]                                           ; restore r9 from shadow space
  func$intToStr$value$TypeMatch:
  ; Line 127: if (value == 0) { ...
  xor r10, r10                                                   ; prepare r10 for result of value comparison
  cmp qword ptr [rbp+048h], 000000000h                           ; compare value to 0
  sete byte ptr r10b                                             ; store result in r10
  xor rax, rax                                                   ; prepare rax for result of type comparison
  cmp qword ptr [rbp+040h], 000000015h                           ; compare type of value to type of 0
  sete byte ptr al                                               ; store result in rax
  and r10, rax                                                   ; true if type and value are both equal; result goes into r10
  mov [rbp-048h], r10                                            ; store result in == operator result
  mov qword ptr [rbp-050h], 000000014h                           ; == operator result is a Boolean
  cmp qword ptr [rbp-048h], 000000000h                           ; compare == operator result to false
  je func$intToStr$if$continuation                               ; value == 0
    ; Line 128: return '0';
    mov r11, offset string$4                                     ; value of return value
    mov [r15], r11                                               ; (indirect via r11 because "string$4" is an imm64)
    mov qword ptr [r15-08h], 000000016h                          ; type of return value
    jmp func$intToStr$epilog                                     ; return
  func$intToStr$if$continuation:                                 ; end of if
  ; Line 130: String buffer = '';
  mov r11, offset string$15                                      ; value of buffer
  mov [rbp-078h], r11                                            ; (indirect via r11 because "string$15" is an imm64)
  mov qword ptr [rbp-080h], 000000016h                           ; type of buffer
  ; Line 131: Integer newValue = value;
  mov r11, [rbp+048h]                                            ; value of newValue
  mov [rbp-088h], r11                                            ; (indirect via r11 because mov can't do memory-to-memory)
  mov r11, [rbp+040h]                                            ; type of newValue
  mov [rbp-090h], r11                                            ; (indirect via r11 because mov can't do memory-to-memory)
  ; Line 132: while (newValue > 0) { ...
  func$intToStr$while$top:
    mov rax, [rbp-090h]                                          ; load the dynamic type of newValue into rax
    lea r10, typeTable                                           ; move type table offset into r10
    add rax, r10                                                 ; adjust rax to point to the type table
    bt qword ptr [rax], 2                                        ; check that newValue is Integer'21
    jc func$intToStr$while$newvalue$TypeMatch                    ; skip next block if the type matches
      ; Error handling block for newValue
      ;  - print(operandTypeCheckFailureMessage)
      mov [rbp+018h], rcx                                        ; save rcx in shadow space
      mov [rbp+020h], rdx                                        ; save rdx in shadow space
      mov [rbp+028h], r8                                         ; save r8 in shadow space
      mov [rbp+030h], r9                                         ; save r9 in shadow space
      mov r11, offset operandTypeCheckFailureMessage             ; value of argument #1
      push r11                                                   ; (indirect via r11 because "operandTypeCheckFailureMessage" is an imm64)
      push 000000016h                                            ; type of argument #1
      lea r10, [rbp-098h]                                        ; pointer to return value (and type, 8 bytes earlier)
      push r10                                                   ; (that pointer is the last value pushed to the stack)
      mov qword ptr r9, 0h                                       ; pointer to this
      mov qword ptr r8, 000000000h                               ; type of this
      mov qword ptr rdx, 0h                                      ; pointer to closure
      mov rcx, 1                                                 ; number of arguments
      sub rsp, 20h                                               ; allocate shadow space
      call offset func$__print                                   ; jump to subroutine
      add rsp, 038h                                              ; release shadow space and arguments
      mov rcx, [rbp+018h]                                        ; restore rcx from shadow space
      mov rdx, [rbp+020h]                                        ; restore rdx from shadow space
      mov r8, [rbp+028h]                                         ; restore r8 from shadow space
      mov r9, [rbp+030h]                                         ; restore r9 from shadow space
      ;  - exit(1)
      mov [rbp+018h], rcx                                        ; save rcx in shadow space
      mov [rbp+020h], rdx                                        ; save rdx in shadow space
      mov [rbp+028h], r8                                         ; save r8 in shadow space
      mov [rbp+030h], r9                                         ; save r9 in shadow space
      push 000000001h                                            ; value of argument #1
      push 000000015h                                            ; type of argument #1
      lea r10, [rbp-0a8h]                                        ; pointer to return value (and type, 8 bytes earlier)
      push r10                                                   ; (that pointer is the last value pushed to the stack)
      mov qword ptr r9, 0h                                       ; pointer to this
      mov qword ptr r8, 000000000h                               ; type of this
      mov qword ptr rdx, 0h                                      ; pointer to closure
      mov rcx, 1                                                 ; number of arguments
      sub rsp, 20h                                               ; allocate shadow space
      call offset func$exit                                      ; jump to subroutine
      add rsp, 038h                                              ; release shadow space and arguments
      mov rcx, [rbp+018h]                                        ; restore rcx from shadow space
      mov rdx, [rbp+020h]                                        ; restore rdx from shadow space
      mov r8, [rbp+028h]                                         ; restore r8 from shadow space
      mov r9, [rbp+030h]                                         ; restore r9 from shadow space
    func$intToStr$while$newvalue$TypeMatch:
    mov qword ptr [rbp-0d8h], 000000000h                         ; clear > operator result
    cmp qword ptr [rbp-088h], 000000000h                         ; compare newValue to 0
    setg byte ptr [rbp-0d8h]                                     ; store result in > operator result
    mov qword ptr [rbp-0e0h], 000000014h                         ; > operator result is a Boolean
    cmp qword ptr [rbp-0d8h], 000000000h                         ; compare > operator result to false
    je func$intToStr$while$bottom                                ; while condition
    ; Line 133: Integer digit = newValue % 10 /* 0xa */;
    mov rax, [rbp-090h]                                          ; load the dynamic type of newValue into rax
    lea r10, typeTable                                           ; move type table offset into r10
    add rax, r10                                                 ; adjust rax to point to the type table
    bt qword ptr [rax], 2                                        ; check that newValue is Integer'21
    jc func$intToStr$while$newvalue$TypeMatch$1                  ; skip next block if the type matches
      ; Error handling block for newValue
      ;  - print(operandTypeCheckFailureMessage)
      mov [rbp+018h], rcx                                        ; save rcx in shadow space
      mov [rbp+020h], rdx                                        ; save rdx in shadow space
      mov [rbp+028h], r8                                         ; save r8 in shadow space
      mov [rbp+030h], r9                                         ; save r9 in shadow space
      mov r11, offset operandTypeCheckFailureMessage             ; value of argument #1
      push r11                                                   ; (indirect via r11 because "operandTypeCheckFailureMessage" is an imm64)
      push 000000016h                                            ; type of argument #1
      lea r10, [rbp-0e8h]                                        ; pointer to return value (and type, 8 bytes earlier)
      push r10                                                   ; (that pointer is the last value pushed to the stack)
      mov qword ptr r9, 0h                                       ; pointer to this
      mov qword ptr r8, 000000000h                               ; type of this
      mov qword ptr rdx, 0h                                      ; pointer to closure
      mov rcx, 1                                                 ; number of arguments
      sub rsp, 20h                                               ; allocate shadow space
      call offset func$__print                                   ; jump to subroutine
      add rsp, 038h                                              ; release shadow space and arguments
      mov rcx, [rbp+018h]                                        ; restore rcx from shadow space
      mov rdx, [rbp+020h]                                        ; restore rdx from shadow space
      mov r8, [rbp+028h]                                         ; restore r8 from shadow space
      mov r9, [rbp+030h]                                         ; restore r9 from shadow space
      ;  - exit(1)
      mov [rbp+018h], rcx                                        ; save rcx in shadow space
      mov [rbp+020h], rdx                                        ; save rdx in shadow space
      mov [rbp+028h], r8                                         ; save r8 in shadow space
      mov [rbp+030h], r9                                         ; save r9 in shadow space
      push 000000001h                                            ; value of argument #1
      push 000000015h                                            ; type of argument #1
      lea r10, [rbp-0f8h]                                        ; pointer to return value (and type, 8 bytes earlier)
      push r10                                                   ; (that pointer is the last value pushed to the stack)
      mov qword ptr r9, 0h                                       ; pointer to this
      mov qword ptr r8, 000000000h                               ; type of this
      mov qword ptr rdx, 0h                                      ; pointer to closure
      mov rcx, 1                                                 ; number of arguments
      sub rsp, 20h                                               ; allocate shadow space
      call offset func$exit                                      ; jump to subroutine
      add rsp, 038h                                              ; release shadow space and arguments
      mov rcx, [rbp+018h]                                        ; restore rcx from shadow space
      mov rdx, [rbp+020h]                                        ; restore rdx from shadow space
      mov r8, [rbp+028h]                                         ; restore r8 from shadow space
      mov r9, [rbp+030h]                                         ; restore r9 from shadow space
    func$intToStr$while$newvalue$TypeMatch$1:
    mov [rbp+020h], rdx                                          ; save rdx
    mov rax, [rbp-088h]                                          ; prepare dividend
    xor rdx, rdx                                                 ; zero-extend dividend
    mov qword ptr r10, 00000000ah                                ; indirect via r10
    idiv r10                                                     ; % operator
    mov [rbp-0128h], rdx                                         ; store result
    mov qword ptr [rbp-0130h], 000000015h                        ; store type
    mov rdx, [rbp+020h]                                          ; restore rdx
    mov r11, [rbp-0128h]                                         ; value of digit
    mov [rbp-0138h], r11                                         ; (indirect via r11 because mov can't do memory-to-memory)
    mov r11, [rbp-0130h]                                         ; type of digit
    mov [rbp-0140h], r11                                         ; (indirect via r11 because mov can't do memory-to-memory)
    ; Line 134: newValue = newValue / 10 /* 0xa */;
    mov rax, [rbp-090h]                                          ; load the dynamic type of newValue into rax
    lea r10, typeTable                                           ; move type table offset into r10
    add rax, r10                                                 ; adjust rax to point to the type table
    bt qword ptr [rax], 2                                        ; check that newValue is Integer'21
    jc func$intToStr$while$newvalue$TypeMatch$2                  ; skip next block if the type matches
      ; Error handling block for newValue
      ;  - print(operandTypeCheckFailureMessage)
      mov [rbp+018h], rcx                                        ; save rcx in shadow space
      mov [rbp+020h], rdx                                        ; save rdx in shadow space
      mov [rbp+028h], r8                                         ; save r8 in shadow space
      mov [rbp+030h], r9                                         ; save r9 in shadow space
      mov r11, offset operandTypeCheckFailureMessage             ; value of argument #1
      push r11                                                   ; (indirect via r11 because "operandTypeCheckFailureMessage" is an imm64)
      push 000000016h                                            ; type of argument #1
      lea r10, [rbp-0148h]                                       ; pointer to return value (and type, 8 bytes earlier)
      push r10                                                   ; (that pointer is the last value pushed to the stack)
      mov qword ptr r9, 0h                                       ; pointer to this
      mov qword ptr r8, 000000000h                               ; type of this
      mov qword ptr rdx, 0h                                      ; pointer to closure
      mov rcx, 1                                                 ; number of arguments
      sub rsp, 20h                                               ; allocate shadow space
      call offset func$__print                                   ; jump to subroutine
      add rsp, 038h                                              ; release shadow space and arguments
      mov rcx, [rbp+018h]                                        ; restore rcx from shadow space
      mov rdx, [rbp+020h]                                        ; restore rdx from shadow space
      mov r8, [rbp+028h]                                         ; restore r8 from shadow space
      mov r9, [rbp+030h]                                         ; restore r9 from shadow space
      ;  - exit(1)
      mov [rbp+018h], rcx                                        ; save rcx in shadow space
      mov [rbp+020h], rdx                                        ; save rdx in shadow space
      mov [rbp+028h], r8                                         ; save r8 in shadow space
      mov [rbp+030h], r9                                         ; save r9 in shadow space
      push 000000001h                                            ; value of argument #1
      push 000000015h                                            ; type of argument #1
      lea r10, [rbp-0158h]                                       ; pointer to return value (and type, 8 bytes earlier)
      push r10                                                   ; (that pointer is the last value pushed to the stack)
      mov qword ptr r9, 0h                                       ; pointer to this
      mov qword ptr r8, 000000000h                               ; type of this
      mov qword ptr rdx, 0h                                      ; pointer to closure
      mov rcx, 1                                                 ; number of arguments
      sub rsp, 20h                                               ; allocate shadow space
      call offset func$exit                                      ; jump to subroutine
      add rsp, 038h                                              ; release shadow space and arguments
      mov rcx, [rbp+018h]                                        ; restore rcx from shadow space
      mov rdx, [rbp+020h]                                        ; restore rdx from shadow space
      mov r8, [rbp+028h]                                         ; restore r8 from shadow space
      mov r9, [rbp+030h]                                         ; restore r9 from shadow space
    func$intToStr$while$newvalue$TypeMatch$2:
    mov [rbp+020h], rdx                                          ; save rdx
    mov rax, [rbp-088h]                                          ; prepare dividend
    xor rdx, rdx                                                 ; zero-extend dividend
    mov qword ptr r10, 00000000ah                                ; indirect via r10
    idiv r10                                                     ; / operator
    mov [rbp-0188h], rax                                         ; store result
    mov qword ptr [rbp-0190h], 000000015h                        ; store type
    mov rdx, [rbp+020h]                                          ; restore rdx
    mov r11, [rbp-0188h]                                         ; value of newValue
    mov [rbp-088h], r11                                          ; (indirect via r11 because mov can't do memory-to-memory)
    mov r11, [rbp-0190h]                                         ; type of newValue
    mov [rbp-090h], r11                                          ; (indirect via r11 because mov can't do memory-to-memory)
    ; Line 135: buffer = concat(digitToStr(digit), buffer);
    mov [rbp+018h], rcx                                          ; save rcx in shadow space
    mov [rbp+020h], rdx                                          ; save rdx in shadow space
    mov [rbp+028h], r8                                           ; save r8 in shadow space
    mov [rbp+030h], r9                                           ; save r9 in shadow space
    push [rbp-0138h]                                             ; value of argument #1
    push [rbp-0140h]                                             ; type of argument #1
    lea r10, [rbp-0198h]                                         ; pointer to return value (and type, 8 bytes earlier)
    push r10                                                     ; (that pointer is the last value pushed to the stack)
    mov qword ptr r9, 0h                                         ; pointer to this
    mov qword ptr r8, 000000000h                                 ; type of this
    mov qword ptr rdx, 0h                                        ; pointer to closure
    mov rcx, 1                                                   ; number of arguments
    sub rsp, 20h                                                 ; allocate shadow space
    call offset func$digitToStr                                  ; jump to subroutine
    add rsp, 038h                                                ; release shadow space and arguments
    mov rcx, [rbp+018h]                                          ; restore rcx from shadow space
    mov rdx, [rbp+020h]                                          ; restore rdx from shadow space
    mov r8, [rbp+028h]                                           ; restore r8 from shadow space
    mov r9, [rbp+030h]                                           ; restore r9 from shadow space
    mov [rbp+018h], rcx                                          ; save rcx in shadow space
    mov [rbp+020h], rdx                                          ; save rdx in shadow space
    mov [rbp+028h], r8                                           ; save r8 in shadow space
    mov [rbp+030h], r9                                           ; save r9 in shadow space
    push [rbp-078h]                                              ; value of argument #2
    push [rbp-080h]                                              ; type of argument #2
    push [rbp-0198h]                                             ; value of argument #1
    push [rbp-01a0h]                                             ; type of argument #1
    lea r10, [rbp-01a8h]                                         ; pointer to return value (and type, 8 bytes earlier)
    push r10                                                     ; (that pointer is the last value pushed to the stack)
    mov qword ptr r9, 0h                                         ; pointer to this
    mov qword ptr r8, 000000000h                                 ; type of this
    mov qword ptr rdx, 0h                                        ; pointer to closure
    mov rcx, 2                                                   ; number of arguments
    sub rsp, 20h                                                 ; allocate shadow space
    call offset func$concat                                      ; jump to subroutine
    add rsp, 048h                                                ; release shadow space and arguments
    mov rcx, [rbp+018h]                                          ; restore rcx from shadow space
    mov rdx, [rbp+020h]                                          ; restore rdx from shadow space
    mov r8, [rbp+028h]                                           ; restore r8 from shadow space
    mov r9, [rbp+030h]                                           ; restore r9 from shadow space
    mov r11, [rbp-01a8h]                                         ; value of buffer
    mov [rbp-078h], r11                                          ; (indirect via r11 because mov can't do memory-to-memory)
    mov r11, [rbp-01b0h]                                         ; type of buffer
    mov [rbp-080h], r11                                          ; (indirect via r11 because mov can't do memory-to-memory)
    jmp func$intToStr$while$top                                  ; return to top of while
  func$intToStr$while$bottom:
  ; Line 137: return buffer;
  mov rax, [rbp-080h]                                            ; load the dynamic type of return value of intToStr into rax
  lea r10, typeTable                                             ; move type table offset into r10
  add rax, r10                                                   ; adjust rax to point to the type table
  bt qword ptr [rax], 3                                          ; check that return value of intToStr is String'22
  jc func$intToStr$returnValueOfInttostr$TypeMatch               ; skip next block if the type matches
    ; Error handling block for return value of intToStr
    ;  - print(returnValueTypeCheckFailureMessage)
    mov [rbp+018h], rcx                                          ; save rcx in shadow space
    mov [rbp+020h], rdx                                          ; save rdx in shadow space
    mov [rbp+028h], r8                                           ; save r8 in shadow space
    mov [rbp+030h], r9                                           ; save r9 in shadow space
    mov r11, offset returnValueTypeCheckFailureMessage           ; value of argument #1
    push r11                                                     ; (indirect via r11 because "returnValueTypeCheckFailureMessage" is an imm64)
    push 000000016h                                              ; type of argument #1
    lea r10, [rbp-01b8h]                                         ; pointer to return value (and type, 8 bytes earlier)
    push r10                                                     ; (that pointer is the last value pushed to the stack)
    mov qword ptr r9, 0h                                         ; pointer to this
    mov qword ptr r8, 000000000h                                 ; type of this
    mov qword ptr rdx, 0h                                        ; pointer to closure
    mov rcx, 1                                                   ; number of arguments
    sub rsp, 20h                                                 ; allocate shadow space
    call offset func$__print                                     ; jump to subroutine
    add rsp, 038h                                                ; release shadow space and arguments
    mov rcx, [rbp+018h]                                          ; restore rcx from shadow space
    mov rdx, [rbp+020h]                                          ; restore rdx from shadow space
    mov r8, [rbp+028h]                                           ; restore r8 from shadow space
    mov r9, [rbp+030h]                                           ; restore r9 from shadow space
    ;  - exit(1)
    mov [rbp+018h], rcx                                          ; save rcx in shadow space
    mov [rbp+020h], rdx                                          ; save rdx in shadow space
    mov [rbp+028h], r8                                           ; save r8 in shadow space
    mov [rbp+030h], r9                                           ; save r9 in shadow space
    push 000000001h                                              ; value of argument #1
    push 000000015h                                              ; type of argument #1
    lea r10, [rbp-01c8h]                                         ; pointer to return value (and type, 8 bytes earlier)
    push r10                                                     ; (that pointer is the last value pushed to the stack)
    mov qword ptr r9, 0h                                         ; pointer to this
    mov qword ptr r8, 000000000h                                 ; type of this
    mov qword ptr rdx, 0h                                        ; pointer to closure
    mov rcx, 1                                                   ; number of arguments
    sub rsp, 20h                                                 ; allocate shadow space
    call offset func$exit                                        ; jump to subroutine
    add rsp, 038h                                                ; release shadow space and arguments
    mov rcx, [rbp+018h]                                          ; restore rcx from shadow space
    mov rdx, [rbp+020h]                                          ; restore rdx from shadow space
    mov r8, [rbp+028h]                                           ; restore r8 from shadow space
    mov r9, [rbp+030h]                                           ; restore r9 from shadow space
  func$intToStr$returnValueOfInttostr$TypeMatch:
  mov r11, [rbp-078h]                                            ; value of return value
  mov [r15], r11                                                 ; (indirect via r11 because mov can't do memory-to-memory)
  mov r11, [rbp-080h]                                            ; type of return value
  mov [r15-08h], r11                                             ; (indirect via r11 because mov can't do memory-to-memory)
  jmp func$intToStr$epilog                                       ; return
  func$intToStr$epilog:
  mov rax, r15                                                   ; report address of return value
  ; Epilog
  add rsp, 01d0h                                                 ; free space for stack
  pop r15                                                        ; restore non-volatile registers
  pop rbp                                                        ; restore non-volatile registers
  ret                                                            ; return from subroutine

; _stringify
func$_stringify:
  ; Prolog
  push rbp                                                       ; save non-volatile registers
  push r15                                                       ; save non-volatile registers
  sub rsp, 0170h                                                 ; allocate space for stack
  lea rbp, [rsp+0170h]                                           ; set up frame pointer
  mov r15, [rbp+038h]                                            ; prepare return value
  ; Check parameter count
  cmp qword ptr rcx, 000000001h                                  ; compare parameter count to integers
  je func$_stringify$parameterCount$continuation                 ; check number of parameters is as expected
    ; Error handling block for parameter count
    ;  - print(parameterCountCheckFailureMessage)
    mov [rbp+018h], rcx                                          ; save rcx in shadow space
    mov [rbp+020h], rdx                                          ; save rdx in shadow space
    mov [rbp+028h], r8                                           ; save r8 in shadow space
    mov [rbp+030h], r9                                           ; save r9 in shadow space
    mov r11, offset parameterCountCheckFailureMessage            ; value of argument #1
    push r11                                                     ; (indirect via r11 because "parameterCountCheckFailureMessage" is an imm64)
    push 000000016h                                              ; type of argument #1
    lea r10, [rbp-008h]                                          ; pointer to return value (and type, 8 bytes earlier)
    push r10                                                     ; (that pointer is the last value pushed to the stack)
    mov qword ptr r9, 0h                                         ; pointer to this
    mov qword ptr r8, 000000000h                                 ; type of this
    mov qword ptr rdx, 0h                                        ; pointer to closure
    mov rcx, 1                                                   ; number of arguments
    sub rsp, 20h                                                 ; allocate shadow space
    call offset func$__print                                     ; jump to subroutine
    add rsp, 038h                                                ; release shadow space and arguments
    mov rcx, [rbp+018h]                                          ; restore rcx from shadow space
    mov rdx, [rbp+020h]                                          ; restore rdx from shadow space
    mov r8, [rbp+028h]                                           ; restore r8 from shadow space
    mov r9, [rbp+030h]                                           ; restore r9 from shadow space
    ;  - exit(1)
    mov [rbp+018h], rcx                                          ; save rcx in shadow space
    mov [rbp+020h], rdx                                          ; save rdx in shadow space
    mov [rbp+028h], r8                                           ; save r8 in shadow space
    mov [rbp+030h], r9                                           ; save r9 in shadow space
    push 000000001h                                              ; value of argument #1
    push 000000015h                                              ; type of argument #1
    lea r10, [rbp-018h]                                          ; pointer to return value (and type, 8 bytes earlier)
    push r10                                                     ; (that pointer is the last value pushed to the stack)
    mov qword ptr r9, 0h                                         ; pointer to this
    mov qword ptr r8, 000000000h                                 ; type of this
    mov qword ptr rdx, 0h                                        ; pointer to closure
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
  bt qword ptr [rax], 4                                          ; check that arg is Anything'23
  jc func$_stringify$arg$TypeMatch                               ; skip next block if the type matches
    ; Error handling block for arg
    ;  - print(parameterTypeCheckFailureMessage)
    mov [rbp+018h], rcx                                          ; save rcx in shadow space
    mov [rbp+020h], rdx                                          ; save rdx in shadow space
    mov [rbp+028h], r8                                           ; save r8 in shadow space
    mov [rbp+030h], r9                                           ; save r9 in shadow space
    mov r11, offset parameterTypeCheckFailureMessage             ; value of argument #1
    push r11                                                     ; (indirect via r11 because "parameterTypeCheckFailureMessage" is an imm64)
    push 000000016h                                              ; type of argument #1
    lea r10, [rbp-028h]                                          ; pointer to return value (and type, 8 bytes earlier)
    push r10                                                     ; (that pointer is the last value pushed to the stack)
    mov qword ptr r9, 0h                                         ; pointer to this
    mov qword ptr r8, 000000000h                                 ; type of this
    mov qword ptr rdx, 0h                                        ; pointer to closure
    mov rcx, 1                                                   ; number of arguments
    sub rsp, 20h                                                 ; allocate shadow space
    call offset func$__print                                     ; jump to subroutine
    add rsp, 038h                                                ; release shadow space and arguments
    mov rcx, [rbp+018h]                                          ; restore rcx from shadow space
    mov rdx, [rbp+020h]                                          ; restore rdx from shadow space
    mov r8, [rbp+028h]                                           ; restore r8 from shadow space
    mov r9, [rbp+030h]                                           ; restore r9 from shadow space
    ;  - exit(1)
    mov [rbp+018h], rcx                                          ; save rcx in shadow space
    mov [rbp+020h], rdx                                          ; save rdx in shadow space
    mov [rbp+028h], r8                                           ; save r8 in shadow space
    mov [rbp+030h], r9                                           ; save r9 in shadow space
    push 000000001h                                              ; value of argument #1
    push 000000015h                                              ; type of argument #1
    lea r10, [rbp-038h]                                          ; pointer to return value (and type, 8 bytes earlier)
    push r10                                                     ; (that pointer is the last value pushed to the stack)
    mov qword ptr r9, 0h                                         ; pointer to this
    mov qword ptr r8, 000000000h                                 ; type of this
    mov qword ptr rdx, 0h                                        ; pointer to closure
    mov rcx, 1                                                   ; number of arguments
    sub rsp, 20h                                                 ; allocate shadow space
    call offset func$exit                                        ; jump to subroutine
    add rsp, 038h                                                ; release shadow space and arguments
    mov rcx, [rbp+018h]                                          ; restore rcx from shadow space
    mov rdx, [rbp+020h]                                          ; restore rdx from shadow space
    mov r8, [rbp+028h]                                           ; restore r8 from shadow space
    mov r9, [rbp+030h]                                           ; restore r9 from shadow space
  func$_stringify$arg$TypeMatch:
  ; Line 142: if (arg is String) { ...
  mov rax, [rbp+040h]                                            ; load the dynamic type of arg into rax
  lea r10, typeTable                                             ; move type table offset into r10
  add rax, r10                                                   ; adjust rax to point to the type table
  bt qword ptr [rax], 3                                          ; check that arg is String'22
  mov qword ptr [rbp-048h], 000000000h                           ; clear is expression result
  setc byte ptr [rbp-048h]                                       ; store result in is expression result
  mov qword ptr [rbp-050h], 000000014h                           ; is expression result is a Boolean
  cmp qword ptr [rbp-048h], 000000000h                           ; compare is expression result to false
  je func$_stringify$if$continuation                             ; arg is String
    ; Line 143: return arg;
    mov rax, [rbp+040h]                                          ; load the dynamic type of return value of _stringify into rax
    lea r10, typeTable                                           ; move type table offset into r10
    add rax, r10                                                 ; adjust rax to point to the type table
    bt qword ptr [rax], 3                                        ; check that return value of _stringify is String'22
    jc func$_stringify$Stringify$if$block$returnValueOfStringify$TypeMatch ; skip next block if the type matches
      ; Error handling block for return value of _stringify
      ;  - print(returnValueTypeCheckFailureMessage)
      mov [rbp+018h], rcx                                        ; save rcx in shadow space
      mov [rbp+020h], rdx                                        ; save rdx in shadow space
      mov [rbp+028h], r8                                         ; save r8 in shadow space
      mov [rbp+030h], r9                                         ; save r9 in shadow space
      mov r11, offset returnValueTypeCheckFailureMessage         ; value of argument #1
      push r11                                                   ; (indirect via r11 because "returnValueTypeCheckFailureMessage" is an imm64)
      push 000000016h                                            ; type of argument #1
      lea r10, [rbp-058h]                                        ; pointer to return value (and type, 8 bytes earlier)
      push r10                                                   ; (that pointer is the last value pushed to the stack)
      mov qword ptr r9, 0h                                       ; pointer to this
      mov qword ptr r8, 000000000h                               ; type of this
      mov qword ptr rdx, 0h                                      ; pointer to closure
      mov rcx, 1                                                 ; number of arguments
      sub rsp, 20h                                               ; allocate shadow space
      call offset func$__print                                   ; jump to subroutine
      add rsp, 038h                                              ; release shadow space and arguments
      mov rcx, [rbp+018h]                                        ; restore rcx from shadow space
      mov rdx, [rbp+020h]                                        ; restore rdx from shadow space
      mov r8, [rbp+028h]                                         ; restore r8 from shadow space
      mov r9, [rbp+030h]                                         ; restore r9 from shadow space
      ;  - exit(1)
      mov [rbp+018h], rcx                                        ; save rcx in shadow space
      mov [rbp+020h], rdx                                        ; save rdx in shadow space
      mov [rbp+028h], r8                                         ; save r8 in shadow space
      mov [rbp+030h], r9                                         ; save r9 in shadow space
      push 000000001h                                            ; value of argument #1
      push 000000015h                                            ; type of argument #1
      lea r10, [rbp-068h]                                        ; pointer to return value (and type, 8 bytes earlier)
      push r10                                                   ; (that pointer is the last value pushed to the stack)
      mov qword ptr r9, 0h                                       ; pointer to this
      mov qword ptr r8, 000000000h                               ; type of this
      mov qword ptr rdx, 0h                                      ; pointer to closure
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
  ; Line 145: if (arg is Boolean) { ...
  mov rax, [rbp+040h]                                            ; load the dynamic type of arg into rax
  lea r10, typeTable                                             ; move type table offset into r10
  add rax, r10                                                   ; adjust rax to point to the type table
  bt qword ptr [rax], 1                                          ; check that arg is Boolean'20
  mov qword ptr [rbp-078h], 000000000h                           ; clear is expression result
  setc byte ptr [rbp-078h]                                       ; store result in is expression result
  mov qword ptr [rbp-080h], 000000014h                           ; is expression result is a Boolean
  cmp qword ptr [rbp-078h], 000000000h                           ; compare is expression result to false
  je func$_stringify$if$continuation$1                           ; arg is Boolean
    ; Line 146: if (arg) { ...
    cmp qword ptr [rbp+048h], 000000000h                         ; compare arg to false
    je func$_stringify$Stringify$if$block$1$if$continuation      ; arg
      ; Line 147: return 'true';
      mov r11, offset string$16                                  ; value of return value
      mov [r15], r11                                             ; (indirect via r11 because "string$16" is an imm64)
      mov qword ptr [r15-08h], 000000016h                        ; type of return value
      jmp func$_stringify$epilog                                 ; return
    func$_stringify$Stringify$if$block$1$if$continuation:        ; end of if
    ; Line 149: return 'false';
    mov r11, offset string$17                                    ; value of return value
    mov [r15], r11                                               ; (indirect via r11 because "string$17" is an imm64)
    mov qword ptr [r15-08h], 000000016h                          ; type of return value
    jmp func$_stringify$epilog                                   ; return
  func$_stringify$if$continuation$1:                             ; end of if
  ; Line 151: if (arg is Null) { ...
  mov rax, [rbp+040h]                                            ; load the dynamic type of arg into rax
  lea r10, typeTable                                             ; move type table offset into r10
  add rax, r10                                                   ; adjust rax to point to the type table
  bt qword ptr [rax], 0                                          ; check that arg is Null'19
  mov qword ptr [rbp-0c8h], 000000000h                           ; clear is expression result
  setc byte ptr [rbp-0c8h]                                       ; store result in is expression result
  mov qword ptr [rbp-0d0h], 000000014h                           ; is expression result is a Boolean
  cmp qword ptr [rbp-0c8h], 000000000h                           ; compare is expression result to false
  je func$_stringify$if$continuation$2                           ; arg is Null
    ; Line 152: return 'null';
    mov r11, offset string$18                                    ; value of return value
    mov [r15], r11                                               ; (indirect via r11 because "string$18" is an imm64)
    mov qword ptr [r15-08h], 000000016h                          ; type of return value
    jmp func$_stringify$epilog                                   ; return
  func$_stringify$if$continuation$2:                             ; end of if
  ; Line 154: if (arg is Integer) { ...
  mov rax, [rbp+040h]                                            ; load the dynamic type of arg into rax
  lea r10, typeTable                                             ; move type table offset into r10
  add rax, r10                                                   ; adjust rax to point to the type table
  bt qword ptr [rax], 2                                          ; check that arg is Integer'21
  mov qword ptr [rbp-0f8h], 000000000h                           ; clear is expression result
  setc byte ptr [rbp-0f8h]                                       ; store result in is expression result
  mov qword ptr [rbp-0100h], 000000014h                          ; is expression result is a Boolean
  cmp qword ptr [rbp-0f8h], 000000000h                           ; compare is expression result to false
  je func$_stringify$if$continuation$3                           ; arg is Integer
    ; Line 155: return intToStr(arg as Integer);
    mov rax, [rbp+040h]                                          ; load the dynamic type of arg as Integer into rax
    lea r10, typeTable                                           ; move type table offset into r10
    add rax, r10                                                 ; adjust rax to point to the type table
    bt qword ptr [rax], 2                                        ; check that arg as Integer is Integer'21
    jc func$_stringify$Stringify$if$block$3$argAsINteger$TypeMatch ; skip next block if the type matches
      ; Error handling block for arg as Integer
      ;  - print(asOperatorFailureMessage)
      mov [rbp+018h], rcx                                        ; save rcx in shadow space
      mov [rbp+020h], rdx                                        ; save rdx in shadow space
      mov [rbp+028h], r8                                         ; save r8 in shadow space
      mov [rbp+030h], r9                                         ; save r9 in shadow space
      mov r11, offset asOperatorFailureMessage                   ; value of argument #1
      push r11                                                   ; (indirect via r11 because "asOperatorFailureMessage" is an imm64)
      push 000000016h                                            ; type of argument #1
      lea r10, [rbp-0108h]                                       ; pointer to return value (and type, 8 bytes earlier)
      push r10                                                   ; (that pointer is the last value pushed to the stack)
      mov qword ptr r9, 0h                                       ; pointer to this
      mov qword ptr r8, 000000000h                               ; type of this
      mov qword ptr rdx, 0h                                      ; pointer to closure
      mov rcx, 1                                                 ; number of arguments
      sub rsp, 20h                                               ; allocate shadow space
      call offset func$__print                                   ; jump to subroutine
      add rsp, 038h                                              ; release shadow space and arguments
      mov rcx, [rbp+018h]                                        ; restore rcx from shadow space
      mov rdx, [rbp+020h]                                        ; restore rdx from shadow space
      mov r8, [rbp+028h]                                         ; restore r8 from shadow space
      mov r9, [rbp+030h]                                         ; restore r9 from shadow space
      ;  - exit(1)
      mov [rbp+018h], rcx                                        ; save rcx in shadow space
      mov [rbp+020h], rdx                                        ; save rdx in shadow space
      mov [rbp+028h], r8                                         ; save r8 in shadow space
      mov [rbp+030h], r9                                         ; save r9 in shadow space
      push 000000001h                                            ; value of argument #1
      push 000000015h                                            ; type of argument #1
      lea r10, [rbp-0118h]                                       ; pointer to return value (and type, 8 bytes earlier)
      push r10                                                   ; (that pointer is the last value pushed to the stack)
      mov qword ptr r9, 0h                                       ; pointer to this
      mov qword ptr r8, 000000000h                               ; type of this
      mov qword ptr rdx, 0h                                      ; pointer to closure
      mov rcx, 1                                                 ; number of arguments
      sub rsp, 20h                                               ; allocate shadow space
      call offset func$exit                                      ; jump to subroutine
      add rsp, 038h                                              ; release shadow space and arguments
      mov rcx, [rbp+018h]                                        ; restore rcx from shadow space
      mov rdx, [rbp+020h]                                        ; restore rdx from shadow space
      mov r8, [rbp+028h]                                         ; restore r8 from shadow space
      mov r9, [rbp+030h]                                         ; restore r9 from shadow space
    func$_stringify$Stringify$if$block$3$argAsINteger$TypeMatch:
    mov [rbp+018h], rcx                                          ; save rcx in shadow space
    mov [rbp+020h], rdx                                          ; save rdx in shadow space
    mov [rbp+028h], r8                                           ; save r8 in shadow space
    mov [rbp+030h], r9                                           ; save r9 in shadow space
    push [rbp+048h]                                              ; value of argument #1
    push [rbp+040h]                                              ; type of argument #1
    lea r10, [rbp-0128h]                                         ; pointer to return value (and type, 8 bytes earlier)
    push r10                                                     ; (that pointer is the last value pushed to the stack)
    mov qword ptr r9, 0h                                         ; pointer to this
    mov qword ptr r8, 000000000h                                 ; type of this
    mov qword ptr rdx, 0h                                        ; pointer to closure
    mov rcx, 1                                                   ; number of arguments
    sub rsp, 20h                                                 ; allocate shadow space
    call offset func$intToStr                                    ; jump to subroutine
    add rsp, 038h                                                ; release shadow space and arguments
    mov rcx, [rbp+018h]                                          ; restore rcx from shadow space
    mov rdx, [rbp+020h]                                          ; restore rdx from shadow space
    mov r8, [rbp+028h]                                           ; restore r8 from shadow space
    mov r9, [rbp+030h]                                           ; restore r9 from shadow space
    mov rax, [rbp-0130h]                                         ; load the dynamic type of return value of _stringify into rax
    lea r10, typeTable                                           ; move type table offset into r10
    add rax, r10                                                 ; adjust rax to point to the type table
    bt qword ptr [rax], 3                                        ; check that return value of _stringify is String'22
    jc func$_stringify$Stringify$if$block$3$returnValueOfStringify$TypeMatch ; skip next block if the type matches
      ; Error handling block for return value of _stringify
      ;  - print(returnValueTypeCheckFailureMessage)
      mov [rbp+018h], rcx                                        ; save rcx in shadow space
      mov [rbp+020h], rdx                                        ; save rdx in shadow space
      mov [rbp+028h], r8                                         ; save r8 in shadow space
      mov [rbp+030h], r9                                         ; save r9 in shadow space
      mov r11, offset returnValueTypeCheckFailureMessage         ; value of argument #1
      push r11                                                   ; (indirect via r11 because "returnValueTypeCheckFailureMessage" is an imm64)
      push 000000016h                                            ; type of argument #1
      lea r10, [rbp-0138h]                                       ; pointer to return value (and type, 8 bytes earlier)
      push r10                                                   ; (that pointer is the last value pushed to the stack)
      mov qword ptr r9, 0h                                       ; pointer to this
      mov qword ptr r8, 000000000h                               ; type of this
      mov qword ptr rdx, 0h                                      ; pointer to closure
      mov rcx, 1                                                 ; number of arguments
      sub rsp, 20h                                               ; allocate shadow space
      call offset func$__print                                   ; jump to subroutine
      add rsp, 038h                                              ; release shadow space and arguments
      mov rcx, [rbp+018h]                                        ; restore rcx from shadow space
      mov rdx, [rbp+020h]                                        ; restore rdx from shadow space
      mov r8, [rbp+028h]                                         ; restore r8 from shadow space
      mov r9, [rbp+030h]                                         ; restore r9 from shadow space
      ;  - exit(1)
      mov [rbp+018h], rcx                                        ; save rcx in shadow space
      mov [rbp+020h], rdx                                        ; save rdx in shadow space
      mov [rbp+028h], r8                                         ; save r8 in shadow space
      mov [rbp+030h], r9                                         ; save r9 in shadow space
      push 000000001h                                            ; value of argument #1
      push 000000015h                                            ; type of argument #1
      lea r10, [rbp-0148h]                                       ; pointer to return value (and type, 8 bytes earlier)
      push r10                                                   ; (that pointer is the last value pushed to the stack)
      mov qword ptr r9, 0h                                       ; pointer to this
      mov qword ptr r8, 000000000h                               ; type of this
      mov qword ptr rdx, 0h                                      ; pointer to closure
      mov rcx, 1                                                 ; number of arguments
      sub rsp, 20h                                               ; allocate shadow space
      call offset func$exit                                      ; jump to subroutine
      add rsp, 038h                                              ; release shadow space and arguments
      mov rcx, [rbp+018h]                                        ; restore rcx from shadow space
      mov rdx, [rbp+020h]                                        ; restore rdx from shadow space
      mov r8, [rbp+028h]                                         ; restore r8 from shadow space
      mov r9, [rbp+030h]                                         ; restore r9 from shadow space
    func$_stringify$Stringify$if$block$3$returnValueOfStringify$TypeMatch:
    mov r11, [rbp-0128h]                                         ; value of return value
    mov [r15], r11                                               ; (indirect via r11 because mov can't do memory-to-memory)
    mov r11, [rbp-0130h]                                         ; type of return value
    mov [r15-08h], r11                                           ; (indirect via r11 because mov can't do memory-to-memory)
    jmp func$_stringify$epilog                                   ; return
  func$_stringify$if$continuation$3:                             ; end of if
  ; Line 157: __print('value cannot be stringified\n');
  mov [rbp+018h], rcx                                            ; save rcx in shadow space
  mov [rbp+020h], rdx                                            ; save rdx in shadow space
  mov [rbp+028h], r8                                             ; save r8 in shadow space
  mov [rbp+030h], r9                                             ; save r9 in shadow space
  mov r11, offset string$19                                      ; value of argument #1
  push r11                                                       ; (indirect via r11 because "string$19" is an imm64)
  push 000000016h                                                ; type of argument #1
  lea r10, [rbp-0158h]                                           ; pointer to return value (and type, 8 bytes earlier)
  push r10                                                       ; (that pointer is the last value pushed to the stack)
  mov qword ptr r9, 0h                                           ; pointer to this
  mov qword ptr r8, 000000000h                                   ; type of this
  mov qword ptr rdx, 0h                                          ; pointer to closure
  mov rcx, 1                                                     ; number of arguments
  sub rsp, 20h                                                   ; allocate shadow space
  call offset func$__print                                       ; jump to subroutine
  add rsp, 038h                                                  ; release shadow space and arguments
  mov rcx, [rbp+018h]                                            ; restore rcx from shadow space
  mov rdx, [rbp+020h]                                            ; restore rdx from shadow space
  mov r8, [rbp+028h]                                             ; restore r8 from shadow space
  mov r9, [rbp+030h]                                             ; restore r9 from shadow space
  ; Line 158: exit(1);
  mov [rbp+018h], rcx                                            ; save rcx in shadow space
  mov [rbp+020h], rdx                                            ; save rdx in shadow space
  mov [rbp+028h], r8                                             ; save r8 in shadow space
  mov [rbp+030h], r9                                             ; save r9 in shadow space
  push 000000001h                                                ; value of argument #1
  push 000000015h                                                ; type of argument #1
  lea r10, [rbp-0168h]                                           ; pointer to return value (and type, 8 bytes earlier)
  push r10                                                       ; (that pointer is the last value pushed to the stack)
  mov qword ptr r9, 0h                                           ; pointer to this
  mov qword ptr r8, 000000000h                                   ; type of this
  mov qword ptr rdx, 0h                                          ; pointer to closure
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
  add rsp, 0170h                                                 ; free space for stack
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
  sub rsp, 0150h                                                 ; allocate space for stack
  lea rbp, [rsp+0150h]                                           ; set up frame pointer
  mov r15, [rbp+048h]                                            ; prepare return value
  lea rsi, [rbp+058h]                                            ; initial index pointing to value of first argument
  mov rdi, rcx                                                   ; end of loop is the number of arguments...
  shl rdi, 4                                                     ; ...times the width of each argument (010h)...
  add rdi, rsi                                                   ; ...offset from the initial index
  func$print$varargTypeChecks$Loop:
    cmp rsi, rdi                                                 ; compare pointer to current argument to end of loop
    je func$print$varargTypeChecks$TypesAllMatch                 ; we have type-checked all the arguments
    mov rax, [rsi-008h]                                          ; load the dynamic type of vararg types into rax
    lea r10, typeTable                                           ; move type table offset into r10
    add rax, r10                                                 ; adjust rax to point to the type table
    bt qword ptr [rax], 4                                        ; check that vararg types is Anything'23
    jc func$print$varargTypeChecks$TypeMatch                     ; skip next block if the type matches
      ; Error handling block for vararg types
      ;  - print(parameterTypeCheckFailureMessage)
      mov [rbp+028h], rcx                                        ; save rcx in shadow space
      mov [rbp+030h], rdx                                        ; save rdx in shadow space
      mov [rbp+038h], r8                                         ; save r8 in shadow space
      mov [rbp+040h], r9                                         ; save r9 in shadow space
      mov r11, offset parameterTypeCheckFailureMessage           ; value of argument #1
      push r11                                                   ; (indirect via r11 because "parameterTypeCheckFailureMessage" is an imm64)
      push 000000016h                                            ; type of argument #1
      lea r10, [rbp-008h]                                        ; pointer to return value (and type, 8 bytes earlier)
      push r10                                                   ; (that pointer is the last value pushed to the stack)
      mov qword ptr r9, 0h                                       ; pointer to this
      mov qword ptr r8, 000000000h                               ; type of this
      mov qword ptr rdx, 0h                                      ; pointer to closure
      mov rcx, 1                                                 ; number of arguments
      sub rsp, 20h                                               ; allocate shadow space
      call offset func$__print                                   ; jump to subroutine
      add rsp, 038h                                              ; release shadow space and arguments
      mov rcx, [rbp+028h]                                        ; restore rcx from shadow space
      mov rdx, [rbp+030h]                                        ; restore rdx from shadow space
      mov r8, [rbp+038h]                                         ; restore r8 from shadow space
      mov r9, [rbp+040h]                                         ; restore r9 from shadow space
      ;  - exit(1)
      mov [rbp+028h], rcx                                        ; save rcx in shadow space
      mov [rbp+030h], rdx                                        ; save rdx in shadow space
      mov [rbp+038h], r8                                         ; save r8 in shadow space
      mov [rbp+040h], r9                                         ; save r9 in shadow space
      push 000000001h                                            ; value of argument #1
      push 000000015h                                            ; type of argument #1
      lea r10, [rbp-018h]                                        ; pointer to return value (and type, 8 bytes earlier)
      push r10                                                   ; (that pointer is the last value pushed to the stack)
      mov qword ptr r9, 0h                                       ; pointer to this
      mov qword ptr r8, 000000000h                               ; type of this
      mov qword ptr rdx, 0h                                      ; pointer to closure
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
  ; Line 162: Boolean first = true;
  mov qword ptr [rbp-028h], 000000001h                           ; value of first
  mov qword ptr [rbp-030h], 000000014h                           ; type of first
  ; Line 163: Integer index = 0;
  mov qword ptr [rbp-038h], 000000000h                           ; value of index
  mov qword ptr [rbp-040h], 000000015h                           ; type of index
  ; Line 164: while (index < len(parts)) { ...
  func$print$while$top:
    mov rax, [rbp-040h]                                          ; load the dynamic type of index into rax
    lea r10, typeTable                                           ; move type table offset into r10
    add rax, r10                                                 ; adjust rax to point to the type table
    bt qword ptr [rax], 2                                        ; check that index is Integer'21
    jc func$print$while$index$TypeMatch                          ; skip next block if the type matches
      ; Error handling block for index
      ;  - print(operandTypeCheckFailureMessage)
      mov [rbp+028h], rcx                                        ; save rcx in shadow space
      mov [rbp+030h], rdx                                        ; save rdx in shadow space
      mov [rbp+038h], r8                                         ; save r8 in shadow space
      mov [rbp+040h], r9                                         ; save r9 in shadow space
      mov r11, offset operandTypeCheckFailureMessage             ; value of argument #1
      push r11                                                   ; (indirect via r11 because "operandTypeCheckFailureMessage" is an imm64)
      push 000000016h                                            ; type of argument #1
      lea r10, [rbp-048h]                                        ; pointer to return value (and type, 8 bytes earlier)
      push r10                                                   ; (that pointer is the last value pushed to the stack)
      mov qword ptr r9, 0h                                       ; pointer to this
      mov qword ptr r8, 000000000h                               ; type of this
      mov qword ptr rdx, 0h                                      ; pointer to closure
      mov rcx, 1                                                 ; number of arguments
      sub rsp, 20h                                               ; allocate shadow space
      call offset func$__print                                   ; jump to subroutine
      add rsp, 038h                                              ; release shadow space and arguments
      mov rcx, [rbp+028h]                                        ; restore rcx from shadow space
      mov rdx, [rbp+030h]                                        ; restore rdx from shadow space
      mov r8, [rbp+038h]                                         ; restore r8 from shadow space
      mov r9, [rbp+040h]                                         ; restore r9 from shadow space
      ;  - exit(1)
      mov [rbp+028h], rcx                                        ; save rcx in shadow space
      mov [rbp+030h], rdx                                        ; save rdx in shadow space
      mov [rbp+038h], r8                                         ; save r8 in shadow space
      mov [rbp+040h], r9                                         ; save r9 in shadow space
      push 000000001h                                            ; value of argument #1
      push 000000015h                                            ; type of argument #1
      lea r10, [rbp-058h]                                        ; pointer to return value (and type, 8 bytes earlier)
      push r10                                                   ; (that pointer is the last value pushed to the stack)
      mov qword ptr r9, 0h                                       ; pointer to this
      mov qword ptr r8, 000000000h                               ; type of this
      mov qword ptr rdx, 0h                                      ; pointer to closure
      mov rcx, 1                                                 ; number of arguments
      sub rsp, 20h                                               ; allocate shadow space
      call offset func$exit                                      ; jump to subroutine
      add rsp, 038h                                              ; release shadow space and arguments
      mov rcx, [rbp+028h]                                        ; restore rcx from shadow space
      mov rdx, [rbp+030h]                                        ; restore rdx from shadow space
      mov r8, [rbp+038h]                                         ; restore r8 from shadow space
      mov r9, [rbp+040h]                                         ; restore r9 from shadow space
    func$print$while$index$TypeMatch:
    mov qword ptr [rbp-088h], 000000000h                         ; clear < operator result
    cmp [rbp-038h], rcx                                          ; compare index to parameter count
    setl byte ptr [rbp-088h]                                     ; store result in < operator result
    mov qword ptr [rbp-090h], 000000014h                         ; < operator result is a Boolean
    cmp qword ptr [rbp-088h], 000000000h                         ; compare < operator result to false
    je func$print$while$bottom                                   ; while condition
    ; Line 165: if (first == false) { ...
    xor r10, r10                                                 ; prepare r10 for result of value comparison
    cmp qword ptr [rbp-028h], 000000000h                         ; compare first to false
    sete byte ptr r10b                                           ; store result in r10
    xor rax, rax                                                 ; prepare rax for result of type comparison
    cmp qword ptr [rbp-030h], 000000014h                         ; compare type of first to type of false
    sete byte ptr al                                             ; store result in rax
    and r10, rax                                                 ; true if type and value are both equal; result goes into r10
    mov [rbp-098h], r10                                          ; store result in == operator result
    mov qword ptr [rbp-0a0h], 000000014h                         ; == operator result is a Boolean
    cmp qword ptr [rbp-098h], 000000000h                         ; compare == operator result to false
    je func$print$while$if$continuation                          ; first == false
      ; Line 166: __print(' ');
      mov [rbp+028h], rcx                                        ; save rcx in shadow space
      mov [rbp+030h], rdx                                        ; save rdx in shadow space
      mov [rbp+038h], r8                                         ; save r8 in shadow space
      mov [rbp+040h], r9                                         ; save r9 in shadow space
      mov r11, offset string$20                                  ; value of argument #1
      push r11                                                   ; (indirect via r11 because "string$20" is an imm64)
      push 000000016h                                            ; type of argument #1
      lea r10, [rbp-0a8h]                                        ; pointer to return value (and type, 8 bytes earlier)
      push r10                                                   ; (that pointer is the last value pushed to the stack)
      mov qword ptr r9, 0h                                       ; pointer to this
      mov qword ptr r8, 000000000h                               ; type of this
      mov qword ptr rdx, 0h                                      ; pointer to closure
      mov rcx, 1                                                 ; number of arguments
      sub rsp, 20h                                               ; allocate shadow space
      call offset func$__print                                   ; jump to subroutine
      add rsp, 038h                                              ; release shadow space and arguments
      mov rcx, [rbp+028h]                                        ; restore rcx from shadow space
      mov rdx, [rbp+030h]                                        ; restore rdx from shadow space
      mov r8, [rbp+038h]                                         ; restore r8 from shadow space
      mov r9, [rbp+040h]                                         ; restore r9 from shadow space
    func$print$while$if$continuation:                            ; end of if
    ; Line 168: __print(_stringify(parts[index]));
    lea r10, [rbp+058h]                                          ; base address of varargs
    mov rax, [rbp-038h]                                          ; index into list
    cmp rax, rcx                                                 ; compare index into varargs to number of arguments
    jge func$print$while$subscript$boundsError                   ; index out of range (too high)
    cmp qword ptr rax, 000000000h                                ; compare index into varargs to zero
    jns func$print$while$subscript$inBounds                      ; index not out of range (not negative)
    func$print$while$subscript$boundsError:
      ; Error handling block for subscript bounds error
      ;  - print(boundsFailureMessage)
      mov [rbp+028h], rcx                                        ; save rcx in shadow space
      mov [rbp+030h], rdx                                        ; save rdx in shadow space
      mov [rbp+038h], r8                                         ; save r8 in shadow space
      mov [rbp+040h], r9                                         ; save r9 in shadow space
      mov r11, offset boundsFailureMessage                       ; value of argument #1
      push r11                                                   ; (indirect via r11 because "boundsFailureMessage" is an imm64)
      push 000000016h                                            ; type of argument #1
      lea r10, [rbp-0c8h]                                        ; pointer to return value (and type, 8 bytes earlier)
      push r10                                                   ; (that pointer is the last value pushed to the stack)
      mov qword ptr r9, 0h                                       ; pointer to this
      mov qword ptr r8, 000000000h                               ; type of this
      mov qword ptr rdx, 0h                                      ; pointer to closure
      mov rcx, 1                                                 ; number of arguments
      sub rsp, 20h                                               ; allocate shadow space
      call offset func$__print                                   ; jump to subroutine
      add rsp, 038h                                              ; release shadow space and arguments
      mov rcx, [rbp+028h]                                        ; restore rcx from shadow space
      mov rdx, [rbp+030h]                                        ; restore rdx from shadow space
      mov r8, [rbp+038h]                                         ; restore r8 from shadow space
      mov r9, [rbp+040h]                                         ; restore r9 from shadow space
      ;  - exit(1)
      mov [rbp+028h], rcx                                        ; save rcx in shadow space
      mov [rbp+030h], rdx                                        ; save rdx in shadow space
      mov [rbp+038h], r8                                         ; save r8 in shadow space
      mov [rbp+040h], r9                                         ; save r9 in shadow space
      push 000000001h                                            ; value of argument #1
      push 000000015h                                            ; type of argument #1
      lea r10, [rbp-0d8h]                                        ; pointer to return value (and type, 8 bytes earlier)
      push r10                                                   ; (that pointer is the last value pushed to the stack)
      mov qword ptr r9, 0h                                       ; pointer to this
      mov qword ptr r8, 000000000h                               ; type of this
      mov qword ptr rdx, 0h                                      ; pointer to closure
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
    mov [rbp-0b8h], r11                                          ; (indirect via r11 because mov can't do memory-to-memory)
    sub rax, 8                                                   ; subtract 8 to get to the type
    mov r11, [r10+rax]                                           ; store type
    mov [rbp-0c0h], r11                                          ; (indirect via r11 because mov can't do memory-to-memory)
    mov [rbp+028h], rcx                                          ; save rcx in shadow space
    mov [rbp+030h], rdx                                          ; save rdx in shadow space
    mov [rbp+038h], r8                                           ; save r8 in shadow space
    mov [rbp+040h], r9                                           ; save r9 in shadow space
    push [rbp-0b8h]                                              ; value of argument #1
    push [rbp-0c0h]                                              ; type of argument #1
    lea r10, [rbp-0e8h]                                          ; pointer to return value (and type, 8 bytes earlier)
    push r10                                                     ; (that pointer is the last value pushed to the stack)
    mov qword ptr r9, 0h                                         ; pointer to this
    mov qword ptr r8, 000000000h                                 ; type of this
    mov qword ptr rdx, 0h                                        ; pointer to closure
    mov rcx, 1                                                   ; number of arguments
    sub rsp, 20h                                                 ; allocate shadow space
    call offset func$_stringify                                  ; jump to subroutine
    add rsp, 038h                                                ; release shadow space and arguments
    mov rcx, [rbp+028h]                                          ; restore rcx from shadow space
    mov rdx, [rbp+030h]                                          ; restore rdx from shadow space
    mov r8, [rbp+038h]                                           ; restore r8 from shadow space
    mov r9, [rbp+040h]                                           ; restore r9 from shadow space
    mov [rbp+028h], rcx                                          ; save rcx in shadow space
    mov [rbp+030h], rdx                                          ; save rdx in shadow space
    mov [rbp+038h], r8                                           ; save r8 in shadow space
    mov [rbp+040h], r9                                           ; save r9 in shadow space
    push [rbp-0e8h]                                              ; value of argument #1
    push [rbp-0f0h]                                              ; type of argument #1
    lea r10, [rbp-0f8h]                                          ; pointer to return value (and type, 8 bytes earlier)
    push r10                                                     ; (that pointer is the last value pushed to the stack)
    mov qword ptr r9, 0h                                         ; pointer to this
    mov qword ptr r8, 000000000h                                 ; type of this
    mov qword ptr rdx, 0h                                        ; pointer to closure
    mov rcx, 1                                                   ; number of arguments
    sub rsp, 20h                                                 ; allocate shadow space
    call offset func$__print                                     ; jump to subroutine
    add rsp, 038h                                                ; release shadow space and arguments
    mov rcx, [rbp+028h]                                          ; restore rcx from shadow space
    mov rdx, [rbp+030h]                                          ; restore rdx from shadow space
    mov r8, [rbp+038h]                                           ; restore r8 from shadow space
    mov r9, [rbp+040h]                                           ; restore r9 from shadow space
    ; Line 169: first = false;
    mov qword ptr [rbp-028h], 000000000h                         ; value of first
    mov qword ptr [rbp-030h], 000000014h                         ; type of first
    ; Line 170: index += 1;
    mov rax, [rbp-040h]                                          ; load the dynamic type of <index: Integer at null; compile-time constant> into rax
    lea r10, typeTable                                           ; move type table offset into r10
    add rax, r10                                                 ; adjust rax to point to the type table
    bt qword ptr [rax], 2                                        ; check that <index: Integer at null; compile-time constant> is Integer'21
    jc func$print$while$IndexINtegerAtNullCompileTimeConstant$TypeMatch ; skip next block if the type matches
      ; Error handling block for <index: Integer at null; compile-time constant>
      ;  - print(operandTypeCheckFailureMessage)
      mov [rbp+028h], rcx                                        ; save rcx in shadow space
      mov [rbp+030h], rdx                                        ; save rdx in shadow space
      mov [rbp+038h], r8                                         ; save r8 in shadow space
      mov [rbp+040h], r9                                         ; save r9 in shadow space
      mov r11, offset operandTypeCheckFailureMessage             ; value of argument #1
      push r11                                                   ; (indirect via r11 because "operandTypeCheckFailureMessage" is an imm64)
      push 000000016h                                            ; type of argument #1
      lea r10, [rbp-0118h]                                       ; pointer to return value (and type, 8 bytes earlier)
      push r10                                                   ; (that pointer is the last value pushed to the stack)
      mov qword ptr r9, 0h                                       ; pointer to this
      mov qword ptr r8, 000000000h                               ; type of this
      mov qword ptr rdx, 0h                                      ; pointer to closure
      mov rcx, 1                                                 ; number of arguments
      sub rsp, 20h                                               ; allocate shadow space
      call offset func$__print                                   ; jump to subroutine
      add rsp, 038h                                              ; release shadow space and arguments
      mov rcx, [rbp+028h]                                        ; restore rcx from shadow space
      mov rdx, [rbp+030h]                                        ; restore rdx from shadow space
      mov r8, [rbp+038h]                                         ; restore r8 from shadow space
      mov r9, [rbp+040h]                                         ; restore r9 from shadow space
      ;  - exit(1)
      mov [rbp+028h], rcx                                        ; save rcx in shadow space
      mov [rbp+030h], rdx                                        ; save rdx in shadow space
      mov [rbp+038h], r8                                         ; save r8 in shadow space
      mov [rbp+040h], r9                                         ; save r9 in shadow space
      push 000000001h                                            ; value of argument #1
      push 000000015h                                            ; type of argument #1
      lea r10, [rbp-0128h]                                       ; pointer to return value (and type, 8 bytes earlier)
      push r10                                                   ; (that pointer is the last value pushed to the stack)
      mov qword ptr r9, 0h                                       ; pointer to this
      mov qword ptr r8, 000000000h                               ; type of this
      mov qword ptr rdx, 0h                                      ; pointer to closure
      mov rcx, 1                                                 ; number of arguments
      sub rsp, 20h                                               ; allocate shadow space
      call offset func$exit                                      ; jump to subroutine
      add rsp, 038h                                              ; release shadow space and arguments
      mov rcx, [rbp+028h]                                        ; restore rcx from shadow space
      mov rdx, [rbp+030h]                                        ; restore rdx from shadow space
      mov r8, [rbp+038h]                                         ; restore r8 from shadow space
      mov r9, [rbp+040h]                                         ; restore r9 from shadow space
    func$print$while$IndexINtegerAtNullCompileTimeConstant$TypeMatch:
    mov r10, [rbp-038h]                                          ; add mutates first operand, so indirect via register
    add r10, 000000001h                                          ; += operator
    mov [rbp-0108h], r10                                         ; store result
    mov qword ptr [rbp-0110h], 000000015h                        ; store type
    mov r11, [rbp-0108h]                                         ; value of index
    mov [rbp-038h], r11                                          ; (indirect via r11 because mov can't do memory-to-memory)
    mov r11, [rbp-0110h]                                         ; type of index
    mov [rbp-040h], r11                                          ; (indirect via r11 because mov can't do memory-to-memory)
    jmp func$print$while$top                                     ; return to top of while
  func$print$while$bottom:
  func$print$epilog:
  mov rax, r15                                                   ; report address of return value
  ; Epilog
  add rsp, 0150h                                                 ; free space for stack
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
  sub rsp, 0160h                                                 ; allocate space for stack
  lea rbp, [rsp+0160h]                                           ; set up frame pointer
  mov r15, [rbp+048h]                                            ; prepare return value
  lea rsi, [rbp+058h]                                            ; initial index pointing to value of first argument
  mov rdi, rcx                                                   ; end of loop is the number of arguments...
  shl rdi, 4                                                     ; ...times the width of each argument (010h)...
  add rdi, rsi                                                   ; ...offset from the initial index
  func$println$varargTypeChecks$Loop:
    cmp rsi, rdi                                                 ; compare pointer to current argument to end of loop
    je func$println$varargTypeChecks$TypesAllMatch               ; we have type-checked all the arguments
    mov rax, [rsi-008h]                                          ; load the dynamic type of vararg types into rax
    lea r10, typeTable                                           ; move type table offset into r10
    add rax, r10                                                 ; adjust rax to point to the type table
    bt qword ptr [rax], 4                                        ; check that vararg types is Anything'23
    jc func$println$varargTypeChecks$TypeMatch                   ; skip next block if the type matches
      ; Error handling block for vararg types
      ;  - print(parameterTypeCheckFailureMessage)
      mov [rbp+028h], rcx                                        ; save rcx in shadow space
      mov [rbp+030h], rdx                                        ; save rdx in shadow space
      mov [rbp+038h], r8                                         ; save r8 in shadow space
      mov [rbp+040h], r9                                         ; save r9 in shadow space
      mov r11, offset parameterTypeCheckFailureMessage           ; value of argument #1
      push r11                                                   ; (indirect via r11 because "parameterTypeCheckFailureMessage" is an imm64)
      push 000000016h                                            ; type of argument #1
      lea r10, [rbp-008h]                                        ; pointer to return value (and type, 8 bytes earlier)
      push r10                                                   ; (that pointer is the last value pushed to the stack)
      mov qword ptr r9, 0h                                       ; pointer to this
      mov qword ptr r8, 000000000h                               ; type of this
      mov qword ptr rdx, 0h                                      ; pointer to closure
      mov rcx, 1                                                 ; number of arguments
      sub rsp, 20h                                               ; allocate shadow space
      call offset func$__print                                   ; jump to subroutine
      add rsp, 038h                                              ; release shadow space and arguments
      mov rcx, [rbp+028h]                                        ; restore rcx from shadow space
      mov rdx, [rbp+030h]                                        ; restore rdx from shadow space
      mov r8, [rbp+038h]                                         ; restore r8 from shadow space
      mov r9, [rbp+040h]                                         ; restore r9 from shadow space
      ;  - exit(1)
      mov [rbp+028h], rcx                                        ; save rcx in shadow space
      mov [rbp+030h], rdx                                        ; save rdx in shadow space
      mov [rbp+038h], r8                                         ; save r8 in shadow space
      mov [rbp+040h], r9                                         ; save r9 in shadow space
      push 000000001h                                            ; value of argument #1
      push 000000015h                                            ; type of argument #1
      lea r10, [rbp-018h]                                        ; pointer to return value (and type, 8 bytes earlier)
      push r10                                                   ; (that pointer is the last value pushed to the stack)
      mov qword ptr r9, 0h                                       ; pointer to this
      mov qword ptr r8, 000000000h                               ; type of this
      mov qword ptr rdx, 0h                                      ; pointer to closure
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
  ; Line 175: Boolean first = true;
  mov qword ptr [rbp-028h], 000000001h                           ; value of first
  mov qword ptr [rbp-030h], 000000014h                           ; type of first
  ; Line 176: Integer index = 0;
  mov qword ptr [rbp-038h], 000000000h                           ; value of index
  mov qword ptr [rbp-040h], 000000015h                           ; type of index
  ; Line 177: while (index < len(parts)) { ...
  func$println$while$top:
    mov rax, [rbp-040h]                                          ; load the dynamic type of index into rax
    lea r10, typeTable                                           ; move type table offset into r10
    add rax, r10                                                 ; adjust rax to point to the type table
    bt qword ptr [rax], 2                                        ; check that index is Integer'21
    jc func$println$while$index$TypeMatch                        ; skip next block if the type matches
      ; Error handling block for index
      ;  - print(operandTypeCheckFailureMessage)
      mov [rbp+028h], rcx                                        ; save rcx in shadow space
      mov [rbp+030h], rdx                                        ; save rdx in shadow space
      mov [rbp+038h], r8                                         ; save r8 in shadow space
      mov [rbp+040h], r9                                         ; save r9 in shadow space
      mov r11, offset operandTypeCheckFailureMessage             ; value of argument #1
      push r11                                                   ; (indirect via r11 because "operandTypeCheckFailureMessage" is an imm64)
      push 000000016h                                            ; type of argument #1
      lea r10, [rbp-048h]                                        ; pointer to return value (and type, 8 bytes earlier)
      push r10                                                   ; (that pointer is the last value pushed to the stack)
      mov qword ptr r9, 0h                                       ; pointer to this
      mov qword ptr r8, 000000000h                               ; type of this
      mov qword ptr rdx, 0h                                      ; pointer to closure
      mov rcx, 1                                                 ; number of arguments
      sub rsp, 20h                                               ; allocate shadow space
      call offset func$__print                                   ; jump to subroutine
      add rsp, 038h                                              ; release shadow space and arguments
      mov rcx, [rbp+028h]                                        ; restore rcx from shadow space
      mov rdx, [rbp+030h]                                        ; restore rdx from shadow space
      mov r8, [rbp+038h]                                         ; restore r8 from shadow space
      mov r9, [rbp+040h]                                         ; restore r9 from shadow space
      ;  - exit(1)
      mov [rbp+028h], rcx                                        ; save rcx in shadow space
      mov [rbp+030h], rdx                                        ; save rdx in shadow space
      mov [rbp+038h], r8                                         ; save r8 in shadow space
      mov [rbp+040h], r9                                         ; save r9 in shadow space
      push 000000001h                                            ; value of argument #1
      push 000000015h                                            ; type of argument #1
      lea r10, [rbp-058h]                                        ; pointer to return value (and type, 8 bytes earlier)
      push r10                                                   ; (that pointer is the last value pushed to the stack)
      mov qword ptr r9, 0h                                       ; pointer to this
      mov qword ptr r8, 000000000h                               ; type of this
      mov qword ptr rdx, 0h                                      ; pointer to closure
      mov rcx, 1                                                 ; number of arguments
      sub rsp, 20h                                               ; allocate shadow space
      call offset func$exit                                      ; jump to subroutine
      add rsp, 038h                                              ; release shadow space and arguments
      mov rcx, [rbp+028h]                                        ; restore rcx from shadow space
      mov rdx, [rbp+030h]                                        ; restore rdx from shadow space
      mov r8, [rbp+038h]                                         ; restore r8 from shadow space
      mov r9, [rbp+040h]                                         ; restore r9 from shadow space
    func$println$while$index$TypeMatch:
    mov qword ptr [rbp-088h], 000000000h                         ; clear < operator result
    cmp [rbp-038h], rcx                                          ; compare index to parameter count
    setl byte ptr [rbp-088h]                                     ; store result in < operator result
    mov qword ptr [rbp-090h], 000000014h                         ; < operator result is a Boolean
    cmp qword ptr [rbp-088h], 000000000h                         ; compare < operator result to false
    je func$println$while$bottom                                 ; while condition
    ; Line 178: if (first == false) { ...
    xor r10, r10                                                 ; prepare r10 for result of value comparison
    cmp qword ptr [rbp-028h], 000000000h                         ; compare first to false
    sete byte ptr r10b                                           ; store result in r10
    xor rax, rax                                                 ; prepare rax for result of type comparison
    cmp qword ptr [rbp-030h], 000000014h                         ; compare type of first to type of false
    sete byte ptr al                                             ; store result in rax
    and r10, rax                                                 ; true if type and value are both equal; result goes into r10
    mov [rbp-098h], r10                                          ; store result in == operator result
    mov qword ptr [rbp-0a0h], 000000014h                         ; == operator result is a Boolean
    cmp qword ptr [rbp-098h], 000000000h                         ; compare == operator result to false
    je func$println$while$if$continuation                        ; first == false
      ; Line 179: __print(' ');
      mov [rbp+028h], rcx                                        ; save rcx in shadow space
      mov [rbp+030h], rdx                                        ; save rdx in shadow space
      mov [rbp+038h], r8                                         ; save r8 in shadow space
      mov [rbp+040h], r9                                         ; save r9 in shadow space
      mov r11, offset string$20                                  ; value of argument #1
      push r11                                                   ; (indirect via r11 because "string$20" is an imm64)
      push 000000016h                                            ; type of argument #1
      lea r10, [rbp-0a8h]                                        ; pointer to return value (and type, 8 bytes earlier)
      push r10                                                   ; (that pointer is the last value pushed to the stack)
      mov qword ptr r9, 0h                                       ; pointer to this
      mov qword ptr r8, 000000000h                               ; type of this
      mov qword ptr rdx, 0h                                      ; pointer to closure
      mov rcx, 1                                                 ; number of arguments
      sub rsp, 20h                                               ; allocate shadow space
      call offset func$__print                                   ; jump to subroutine
      add rsp, 038h                                              ; release shadow space and arguments
      mov rcx, [rbp+028h]                                        ; restore rcx from shadow space
      mov rdx, [rbp+030h]                                        ; restore rdx from shadow space
      mov r8, [rbp+038h]                                         ; restore r8 from shadow space
      mov r9, [rbp+040h]                                         ; restore r9 from shadow space
    func$println$while$if$continuation:                          ; end of if
    ; Line 181: __print(_stringify(parts[index]));
    lea r10, [rbp+058h]                                          ; base address of varargs
    mov rax, [rbp-038h]                                          ; index into list
    cmp rax, rcx                                                 ; compare index into varargs to number of arguments
    jge func$println$while$subscript$boundsError                 ; index out of range (too high)
    cmp qword ptr rax, 000000000h                                ; compare index into varargs to zero
    jns func$println$while$subscript$inBounds                    ; index not out of range (not negative)
    func$println$while$subscript$boundsError:
      ; Error handling block for subscript bounds error
      ;  - print(boundsFailureMessage)
      mov [rbp+028h], rcx                                        ; save rcx in shadow space
      mov [rbp+030h], rdx                                        ; save rdx in shadow space
      mov [rbp+038h], r8                                         ; save r8 in shadow space
      mov [rbp+040h], r9                                         ; save r9 in shadow space
      mov r11, offset boundsFailureMessage                       ; value of argument #1
      push r11                                                   ; (indirect via r11 because "boundsFailureMessage" is an imm64)
      push 000000016h                                            ; type of argument #1
      lea r10, [rbp-0c8h]                                        ; pointer to return value (and type, 8 bytes earlier)
      push r10                                                   ; (that pointer is the last value pushed to the stack)
      mov qword ptr r9, 0h                                       ; pointer to this
      mov qword ptr r8, 000000000h                               ; type of this
      mov qword ptr rdx, 0h                                      ; pointer to closure
      mov rcx, 1                                                 ; number of arguments
      sub rsp, 20h                                               ; allocate shadow space
      call offset func$__print                                   ; jump to subroutine
      add rsp, 038h                                              ; release shadow space and arguments
      mov rcx, [rbp+028h]                                        ; restore rcx from shadow space
      mov rdx, [rbp+030h]                                        ; restore rdx from shadow space
      mov r8, [rbp+038h]                                         ; restore r8 from shadow space
      mov r9, [rbp+040h]                                         ; restore r9 from shadow space
      ;  - exit(1)
      mov [rbp+028h], rcx                                        ; save rcx in shadow space
      mov [rbp+030h], rdx                                        ; save rdx in shadow space
      mov [rbp+038h], r8                                         ; save r8 in shadow space
      mov [rbp+040h], r9                                         ; save r9 in shadow space
      push 000000001h                                            ; value of argument #1
      push 000000015h                                            ; type of argument #1
      lea r10, [rbp-0d8h]                                        ; pointer to return value (and type, 8 bytes earlier)
      push r10                                                   ; (that pointer is the last value pushed to the stack)
      mov qword ptr r9, 0h                                       ; pointer to this
      mov qword ptr r8, 000000000h                               ; type of this
      mov qword ptr rdx, 0h                                      ; pointer to closure
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
    mov [rbp-0b8h], r11                                          ; (indirect via r11 because mov can't do memory-to-memory)
    sub rax, 8                                                   ; subtract 8 to get to the type
    mov r11, [r10+rax]                                           ; store type
    mov [rbp-0c0h], r11                                          ; (indirect via r11 because mov can't do memory-to-memory)
    mov [rbp+028h], rcx                                          ; save rcx in shadow space
    mov [rbp+030h], rdx                                          ; save rdx in shadow space
    mov [rbp+038h], r8                                           ; save r8 in shadow space
    mov [rbp+040h], r9                                           ; save r9 in shadow space
    push [rbp-0b8h]                                              ; value of argument #1
    push [rbp-0c0h]                                              ; type of argument #1
    lea r10, [rbp-0e8h]                                          ; pointer to return value (and type, 8 bytes earlier)
    push r10                                                     ; (that pointer is the last value pushed to the stack)
    mov qword ptr r9, 0h                                         ; pointer to this
    mov qword ptr r8, 000000000h                                 ; type of this
    mov qword ptr rdx, 0h                                        ; pointer to closure
    mov rcx, 1                                                   ; number of arguments
    sub rsp, 20h                                                 ; allocate shadow space
    call offset func$_stringify                                  ; jump to subroutine
    add rsp, 038h                                                ; release shadow space and arguments
    mov rcx, [rbp+028h]                                          ; restore rcx from shadow space
    mov rdx, [rbp+030h]                                          ; restore rdx from shadow space
    mov r8, [rbp+038h]                                           ; restore r8 from shadow space
    mov r9, [rbp+040h]                                           ; restore r9 from shadow space
    mov [rbp+028h], rcx                                          ; save rcx in shadow space
    mov [rbp+030h], rdx                                          ; save rdx in shadow space
    mov [rbp+038h], r8                                           ; save r8 in shadow space
    mov [rbp+040h], r9                                           ; save r9 in shadow space
    push [rbp-0e8h]                                              ; value of argument #1
    push [rbp-0f0h]                                              ; type of argument #1
    lea r10, [rbp-0f8h]                                          ; pointer to return value (and type, 8 bytes earlier)
    push r10                                                     ; (that pointer is the last value pushed to the stack)
    mov qword ptr r9, 0h                                         ; pointer to this
    mov qword ptr r8, 000000000h                                 ; type of this
    mov qword ptr rdx, 0h                                        ; pointer to closure
    mov rcx, 1                                                   ; number of arguments
    sub rsp, 20h                                                 ; allocate shadow space
    call offset func$__print                                     ; jump to subroutine
    add rsp, 038h                                                ; release shadow space and arguments
    mov rcx, [rbp+028h]                                          ; restore rcx from shadow space
    mov rdx, [rbp+030h]                                          ; restore rdx from shadow space
    mov r8, [rbp+038h]                                           ; restore r8 from shadow space
    mov r9, [rbp+040h]                                           ; restore r9 from shadow space
    ; Line 182: first = false;
    mov qword ptr [rbp-028h], 000000000h                         ; value of first
    mov qword ptr [rbp-030h], 000000014h                         ; type of first
    ; Line 183: index += 1;
    mov rax, [rbp-040h]                                          ; load the dynamic type of <index: Integer at null; compile-time constant> into rax
    lea r10, typeTable                                           ; move type table offset into r10
    add rax, r10                                                 ; adjust rax to point to the type table
    bt qword ptr [rax], 2                                        ; check that <index: Integer at null; compile-time constant> is Integer'21
    jc func$println$while$IndexINtegerAtNullCompileTimeConstant$TypeMatch ; skip next block if the type matches
      ; Error handling block for <index: Integer at null; compile-time constant>
      ;  - print(operandTypeCheckFailureMessage)
      mov [rbp+028h], rcx                                        ; save rcx in shadow space
      mov [rbp+030h], rdx                                        ; save rdx in shadow space
      mov [rbp+038h], r8                                         ; save r8 in shadow space
      mov [rbp+040h], r9                                         ; save r9 in shadow space
      mov r11, offset operandTypeCheckFailureMessage             ; value of argument #1
      push r11                                                   ; (indirect via r11 because "operandTypeCheckFailureMessage" is an imm64)
      push 000000016h                                            ; type of argument #1
      lea r10, [rbp-0118h]                                       ; pointer to return value (and type, 8 bytes earlier)
      push r10                                                   ; (that pointer is the last value pushed to the stack)
      mov qword ptr r9, 0h                                       ; pointer to this
      mov qword ptr r8, 000000000h                               ; type of this
      mov qword ptr rdx, 0h                                      ; pointer to closure
      mov rcx, 1                                                 ; number of arguments
      sub rsp, 20h                                               ; allocate shadow space
      call offset func$__print                                   ; jump to subroutine
      add rsp, 038h                                              ; release shadow space and arguments
      mov rcx, [rbp+028h]                                        ; restore rcx from shadow space
      mov rdx, [rbp+030h]                                        ; restore rdx from shadow space
      mov r8, [rbp+038h]                                         ; restore r8 from shadow space
      mov r9, [rbp+040h]                                         ; restore r9 from shadow space
      ;  - exit(1)
      mov [rbp+028h], rcx                                        ; save rcx in shadow space
      mov [rbp+030h], rdx                                        ; save rdx in shadow space
      mov [rbp+038h], r8                                         ; save r8 in shadow space
      mov [rbp+040h], r9                                         ; save r9 in shadow space
      push 000000001h                                            ; value of argument #1
      push 000000015h                                            ; type of argument #1
      lea r10, [rbp-0128h]                                       ; pointer to return value (and type, 8 bytes earlier)
      push r10                                                   ; (that pointer is the last value pushed to the stack)
      mov qword ptr r9, 0h                                       ; pointer to this
      mov qword ptr r8, 000000000h                               ; type of this
      mov qword ptr rdx, 0h                                      ; pointer to closure
      mov rcx, 1                                                 ; number of arguments
      sub rsp, 20h                                               ; allocate shadow space
      call offset func$exit                                      ; jump to subroutine
      add rsp, 038h                                              ; release shadow space and arguments
      mov rcx, [rbp+028h]                                        ; restore rcx from shadow space
      mov rdx, [rbp+030h]                                        ; restore rdx from shadow space
      mov r8, [rbp+038h]                                         ; restore r8 from shadow space
      mov r9, [rbp+040h]                                         ; restore r9 from shadow space
    func$println$while$IndexINtegerAtNullCompileTimeConstant$TypeMatch:
    mov r10, [rbp-038h]                                          ; add mutates first operand, so indirect via register
    add r10, 000000001h                                          ; += operator
    mov [rbp-0108h], r10                                         ; store result
    mov qword ptr [rbp-0110h], 000000015h                        ; store type
    mov r11, [rbp-0108h]                                         ; value of index
    mov [rbp-038h], r11                                          ; (indirect via r11 because mov can't do memory-to-memory)
    mov r11, [rbp-0110h]                                         ; type of index
    mov [rbp-040h], r11                                          ; (indirect via r11 because mov can't do memory-to-memory)
    jmp func$println$while$top                                   ; return to top of while
  func$println$while$bottom:
  ; Line 185: __print('\n');
  mov [rbp+028h], rcx                                            ; save rcx in shadow space
  mov [rbp+030h], rdx                                            ; save rdx in shadow space
  mov [rbp+038h], r8                                             ; save r8 in shadow space
  mov [rbp+040h], r9                                             ; save r9 in shadow space
  mov r11, offset string                                         ; value of argument #1
  push r11                                                       ; (indirect via r11 because "string" is an imm64)
  push 000000016h                                                ; type of argument #1
  lea r10, [rbp-0158h]                                           ; pointer to return value (and type, 8 bytes earlier)
  push r10                                                       ; (that pointer is the last value pushed to the stack)
  mov qword ptr r9, 0h                                           ; pointer to this
  mov qword ptr r8, 000000000h                                   ; type of this
  mov qword ptr rdx, 0h                                          ; pointer to closure
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
  add rsp, 0160h                                                 ; free space for stack
  pop rdi                                                        ; restore non-volatile registers
  pop rsi                                                        ; restore non-volatile registers
  pop r15                                                        ; restore non-volatile registers
  pop rbp                                                        ; restore non-volatile registers
  ret                                                            ; return from subroutine


end

