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
  typeTable    db 03fh, 010h, 010h, 010h, 010h, 010h, 010h, 010h, 010h, 010h, 010h, 010h, 030h, 010h, 011h, 012h, 014h, 018h, 000h, 000h, 000h, 000h, 000h, 000h ; Type table
   ; Columns: Null'14 Boolean'15 Integer'16 String'17 Anything'18 WhateverReadOnlyList'19
   ; 1 1 1 1 1 1   <sentinel>'0
   ; 0 0 0 0 1 0   NullFunction(String)'1
   ; 0 0 0 0 1 0   NullFunction(Integer)'2
   ; 0 0 0 0 1 0   IntegerFunction(WhateverReadOnlyList)'3
   ; 0 0 0 0 1 0   NullFunction()'4
   ; 0 0 0 0 1 0   IntegerFunction()'5
   ; 0 0 0 0 1 0   IntegerFunction(Integer, Integer, Integer)'6
   ; 0 0 0 0 1 0   IntegerFunction(Integer)'7
   ; 0 0 0 0 1 0   NullFunction(Integer, Integer)'8
   ; 0 0 0 0 1 0   StringFunction(String)'9
   ; 0 0 0 0 1 0   StringFunction(Anything)'10
   ; 0 0 0 0 1 0   NullFunction(Anything...)'11
   ; 0 0 0 0 1 1   AnythingReadOnlyList'12
   ; 0 0 0 0 1 0   BooleanFunction(Integer)'13
   ; 1 0 0 0 1 0   Null'14
   ; 0 1 0 0 1 0   Boolean'15
   ; 0 0 1 0 1 0   Integer'16
   ; 0 0 0 1 1 0   String'17

  parameterCountCheckFailureMessage dq -01h                      ; String constant (reference count)
               dq 88                                             ; Length
               db "error: function call received the wrong number of parameters (expected %d, received %d)", 0ah ; line 224 column 25 in file syd-compiler.syd
               db 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h         ; padding to align to 8-byte boundary
  parameterTypeCheckFailureMessage dq -01h                       ; String constant (reference count)
               dq 71                                             ; Length
               db "error: type mismatch for function %s parameter %d, expected %s, got %s", 0ah ; line 229 column 25 in file syd-compiler.syd
               db 00h                                            ; padding to align to 8-byte boundary
  returnValueTypeCheckFailureMessage dq -01h                     ; String constant (reference count)
               dq 68                                             ; Length
               db "error: type mismatch for function return value, expected %s, got %s", 0ah ; line 234 column 25 in file syd-compiler.syd
               db 00h, 00h, 00h, 00h                             ; padding to align to 8-byte boundary
  operandTypeCheckFailureMessage dq -01h                         ; String constant (reference count)
               dq 54                                             ; Length
               db "error: type mismatch for operand, expected %s, got %s", 0ah ; line 239 column 25 in file syd-compiler.syd
               db 00h, 00h                                       ; padding to align to 8-byte boundary
  asOperatorFailureMessage dq -01h                               ; String constant (reference count)
               dq 58                                             ; Length
               db "error: type mismatch for as operator, expected %s, got %s", 0ah ; line 244 column 25 in file syd-compiler.syd
               db 00h, 00h, 00h, 00h, 00h, 00h                   ; padding to align to 8-byte boundary
  boundsFailureMessage dq -01h                                   ; String constant (reference count)
               dq 64                                             ; Length
               db "error: subscript index out of range (%d is not in range %d..%d)", 0ah ; line 249 column 25 in file syd-compiler.syd
               db 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h         ; padding to align to 8-byte boundary
  string$7     dq -01h                                           ; String constant (reference count)
               dq 20                                             ; Length
               db "allocated a pointer!"                         ; line 7 column 32 in file temp.syd
               db 00h, 00h, 00h, 00h                             ; padding to align to 8-byte boundary
  string$8     dq -01h                                           ; String constant (reference count)
               dq 16                                             ; Length
               db "freed a pointer!"                             ; line 14 column 28 in file temp.syd
               db 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h         ; padding to align to 8-byte boundary
  string       dq -01h                                           ; String constant (reference count)
               dq 4                                              ; Length
               db "true"                                         ; line 96 column 19 in file runtime library
               db 00h, 00h, 00h, 00h                             ; padding to align to 8-byte boundary
  string$1     dq -01h                                           ; String constant (reference count)
               dq 5                                              ; Length
               db "false"                                        ; line 98 column 18 in file runtime library
               db 00h, 00h, 00h                                  ; padding to align to 8-byte boundary
  string$2     dq -01h                                           ; String constant (reference count)
               dq 4                                              ; Length
               db "null"                                         ; line 101 column 17 in file runtime library
               db 00h, 00h, 00h, 00h                             ; padding to align to 8-byte boundary
  string$3     dq -01h                                           ; String constant (reference count)
               dq 28                                             ; Length
               db "value cannot be stringified", 0ah             ; line 106 column 41 in file runtime library
               db 00h, 00h, 00h, 00h                             ; padding to align to 8-byte boundary
  string$4     dq -01h                                           ; String constant (reference count)
               dq 1                                              ; Length
               db " "                                            ; line 115 column 17 in file runtime library
               db 00h, 00h, 00h, 00h, 00h, 00h, 00h              ; padding to align to 8-byte boundary
  string$5     dq -01h                                           ; String constant (reference count)
               dq 1                                              ; Length
               db 0ah                                            ; line 134 column 14 in file runtime library
               db 00h, 00h, 00h, 00h, 00h, 00h, 00h              ; padding to align to 8-byte boundary
  string$6     dq -01h                                           ; String constant (reference count)
               dq 36                                             ; Length
               db "failed to free pointer, error code: "         ; line 144 column 50 in file runtime library
               db 00h, 00h, 00h, 00h                             ; padding to align to 8-byte boundary

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
  ; Line 5: Integer _heapHandle = __getProcessHeap();
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
  sub rsp, 01b0h                                                 ; allocate space for stack
  lea rbp, [rsp+01b0h]                                           ; set up frame pointer
  ; Line 5: Integer ptr = _alloc(24 /* 0x18 */);
  mov [rbp+010h], rcx                                            ; save rcx in shadow space
  mov [rbp+018h], rdx                                            ; save rdx in shadow space
  mov [rbp+020h], r8                                             ; save r8 in shadow space
  mov [rbp+028h], r9                                             ; save r9 in shadow space
  push 000000018h                                                ; value of argument #1
  push 000000010h                                                ; type of argument #1
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
  ; Line 6: if (ptr > 0) { ...
  mov rax, global0Type$1                                         ; load the dynamic type of ptr into rax
  lea r10, typeTable                                             ; move type table offset into r10
  add rax, r10                                                   ; adjust rax to point to the type table
  bt qword ptr [rax], 2                                          ; check that ptr is Integer'16
  jc tempSyd$ptr$TypeMatch                                       ; skip next block if the type matches
    ; Error handling block for ptr
    ;  - print(operandTypeCheckFailureMessage)
    mov [rbp+010h], rcx                                          ; save rcx in shadow space
    mov [rbp+018h], rdx                                          ; save rdx in shadow space
    mov [rbp+020h], r8                                           ; save r8 in shadow space
    mov [rbp+028h], r9                                           ; save r9 in shadow space
    mov r11, offset operandTypeCheckFailureMessage               ; value of argument #1
    push r11                                                     ; (indirect via r11 because "operandTypeCheckFailureMessage" is an imm64)
    push 000000011h                                              ; type of argument #1
    lea r10, [rbp-018h]                                          ; pointer to return value (and type, 8 bytes earlier)
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
    push 000000010h                                              ; type of argument #1
    lea r10, [rbp-028h]                                          ; pointer to return value (and type, 8 bytes earlier)
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
  mov qword ptr [rbp-058h], 000000000h                           ; clear > operator result
  cmp qword ptr global0Value$1, 000000000h                       ; compare ptr to 0
  setg byte ptr [rbp-058h]                                       ; store result in > operator result
  mov qword ptr [rbp-060h], 00000000fh                           ; > operator result is a Boolean
  cmp qword ptr [rbp-058h], 000000000h                           ; compare > operator result to false
  je tempSyd$if$continuation                                     ; ptr > 0
    ; Line 7: println('allocated a pointer!');
    mov [rbp+010h], rcx                                          ; save rcx in shadow space
    mov [rbp+018h], rdx                                          ; save rdx in shadow space
    mov [rbp+020h], r8                                           ; save r8 in shadow space
    mov [rbp+028h], r9                                           ; save r9 in shadow space
    mov r11, offset string$7                                     ; value of argument #1
    push r11                                                     ; (indirect via r11 because "string$7" is an imm64)
    push 000000011h                                              ; type of argument #1
    lea r10, [rbp-068h]                                          ; pointer to return value (and type, 8 bytes earlier)
    push r10                                                     ; (that pointer is the last value pushed to the stack)
    mov qword ptr r9, 0h                                         ; pointer to this
    mov qword ptr r8, 000000000h                                 ; type of this
    mov qword ptr rdx, 0h                                        ; pointer to closure
    mov rcx, 1                                                   ; number of arguments
    sub rsp, 20h                                                 ; allocate shadow space
    call offset func$println                                     ; jump to subroutine
    add rsp, 038h                                                ; release shadow space and arguments
    mov rcx, [rbp+010h]                                          ; restore rcx from shadow space
    mov rdx, [rbp+018h]                                          ; restore rdx from shadow space
    mov r8, [rbp+020h]                                           ; restore r8 from shadow space
    mov r9, [rbp+028h]                                           ; restore r9 from shadow space
  tempSyd$if$continuation:                                       ; end of if
  ; Line 9: __writeToAddress(ptr, 0 - 1);
  mov qword ptr r10, 000000000h                                  ; sub mutates first operand, so indirect via register
  sub r10, 000000001h                                            ; - operator
  mov [rbp-0b8h], r10                                            ; store result
  mov qword ptr [rbp-0c0h], 000000010h                           ; store type
  mov r10, global0Value$1                                        ; value of ptr
  mov r11, [rbp-0b8h]                                            ; put - operator result in ptr
  mov [r10], r11                                                 ; (indirect via r11 because mov can't do memory-to-memory)
  ; Line 10: __writeToAddress(ptr + 8, 3);
  mov rax, global0Type$1                                         ; load the dynamic type of ptr into rax
  lea r10, typeTable                                             ; move type table offset into r10
  add rax, r10                                                   ; adjust rax to point to the type table
  bt qword ptr [rax], 2                                          ; check that ptr is Integer'16
  jc tempSyd$ptr$TypeMatch$1                                     ; skip next block if the type matches
    ; Error handling block for ptr
    ;  - print(operandTypeCheckFailureMessage)
    mov [rbp+010h], rcx                                          ; save rcx in shadow space
    mov [rbp+018h], rdx                                          ; save rdx in shadow space
    mov [rbp+020h], r8                                           ; save r8 in shadow space
    mov [rbp+028h], r9                                           ; save r9 in shadow space
    mov r11, offset operandTypeCheckFailureMessage               ; value of argument #1
    push r11                                                     ; (indirect via r11 because "operandTypeCheckFailureMessage" is an imm64)
    push 000000011h                                              ; type of argument #1
    lea r10, [rbp-0c8h]                                          ; pointer to return value (and type, 8 bytes earlier)
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
    push 000000010h                                              ; type of argument #1
    lea r10, [rbp-0d8h]                                          ; pointer to return value (and type, 8 bytes earlier)
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
  add r10, 000000008h                                            ; + operator
  mov [rbp-0108h], r10                                           ; store result
  mov qword ptr [rbp-0110h], 000000010h                          ; store type
  mov r10, [rbp-0108h]                                           ; value of + operator result
  mov qword ptr [r10], 000000003h                                ; put 3 in + operator result
  ; Line 11: __writeToAddress(ptr + 16 /* 0x10 */, 3472328296232149347 /* 0x3...
  mov rax, global0Type$1                                         ; load the dynamic type of ptr into rax
  lea r10, typeTable                                             ; move type table offset into r10
  add rax, r10                                                   ; adjust rax to point to the type table
  bt qword ptr [rax], 2                                          ; check that ptr is Integer'16
  jc tempSyd$ptr$TypeMatch$2                                     ; skip next block if the type matches
    ; Error handling block for ptr
    ;  - print(operandTypeCheckFailureMessage)
    mov [rbp+010h], rcx                                          ; save rcx in shadow space
    mov [rbp+018h], rdx                                          ; save rdx in shadow space
    mov [rbp+020h], r8                                           ; save r8 in shadow space
    mov [rbp+028h], r9                                           ; save r9 in shadow space
    mov r11, offset operandTypeCheckFailureMessage               ; value of argument #1
    push r11                                                     ; (indirect via r11 because "operandTypeCheckFailureMessage" is an imm64)
    push 000000011h                                              ; type of argument #1
    lea r10, [rbp-0118h]                                         ; pointer to return value (and type, 8 bytes earlier)
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
    push 000000010h                                              ; type of argument #1
    lea r10, [rbp-0128h]                                         ; pointer to return value (and type, 8 bytes earlier)
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
  mov [rbp-0158h], r10                                           ; store result
  mov qword ptr [rbp-0160h], 000000010h                          ; store type
  mov r10, [rbp-0158h]                                           ; value of + operator result
  mov r11, 03030303030746163h                                    ; put 3472328296232149347 /* 0x3030303030746163 */ in + operator result
  mov [r10], r11                                                 ; (indirect via r11 because "03030303030746163h" is an imm64)
  ; Line 12: println(ptr __as__ String);
  mov r11, global0Value$1                                        ; value of force cast of ptr to String
  mov [rbp-0168h], r11                                           ; (indirect via r11 because mov can't do memory-to-memory)
  mov qword ptr [rbp-0170h], 000000011h                          ; new type of force cast of ptr to String
  mov [rbp+010h], rcx                                            ; save rcx in shadow space
  mov [rbp+018h], rdx                                            ; save rdx in shadow space
  mov [rbp+020h], r8                                             ; save r8 in shadow space
  mov [rbp+028h], r9                                             ; save r9 in shadow space
  push [rbp-0168h]                                               ; value of argument #1
  push [rbp-0170h]                                               ; type of argument #1
  lea r10, [rbp-0178h]                                           ; pointer to return value (and type, 8 bytes earlier)
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
  ; Line 13: if (_free(ptr)) { ...
  mov [rbp+010h], rcx                                            ; save rcx in shadow space
  mov [rbp+018h], rdx                                            ; save rdx in shadow space
  mov [rbp+020h], r8                                             ; save r8 in shadow space
  mov [rbp+028h], r9                                             ; save r9 in shadow space
  push global0Value$1                                            ; value of argument #1
  push global0Type$1                                             ; type of argument #1
  lea r10, [rbp-0188h]                                           ; pointer to return value (and type, 8 bytes earlier)
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
  cmp qword ptr [rbp-0188h], 000000000h                          ; compare return value to false
  je tempSyd$if$continuation$1                                   ; _free(ptr)
    ; Line 14: println('freed a pointer!');
    mov [rbp+010h], rcx                                          ; save rcx in shadow space
    mov [rbp+018h], rdx                                          ; save rdx in shadow space
    mov [rbp+020h], r8                                           ; save r8 in shadow space
    mov [rbp+028h], r9                                           ; save r9 in shadow space
    mov r11, offset string$8                                     ; value of argument #1
    push r11                                                     ; (indirect via r11 because "string$8" is an imm64)
    push 000000011h                                              ; type of argument #1
    lea r10, [rbp-0198h]                                         ; pointer to return value (and type, 8 bytes earlier)
    push r10                                                     ; (that pointer is the last value pushed to the stack)
    mov qword ptr r9, 0h                                         ; pointer to this
    mov qword ptr r8, 000000000h                                 ; type of this
    mov qword ptr rdx, 0h                                        ; pointer to closure
    mov rcx, 1                                                   ; number of arguments
    sub rsp, 20h                                                 ; allocate shadow space
    call offset func$println                                     ; jump to subroutine
    add rsp, 038h                                                ; release shadow space and arguments
    mov rcx, [rbp+010h]                                          ; restore rcx from shadow space
    mov rdx, [rbp+018h]                                          ; restore rdx from shadow space
    mov r8, [rbp+020h]                                           ; restore r8 from shadow space
    mov r9, [rbp+028h]                                           ; restore r9 from shadow space
  tempSyd$if$continuation$1:                                     ; end of if
  ; Terminate application - call exit(0)
  mov [rbp+010h], rcx                                            ; save rcx in shadow space
  mov [rbp+018h], rdx                                            ; save rdx in shadow space
  mov [rbp+020h], r8                                             ; save r8 in shadow space
  mov [rbp+028h], r9                                             ; save r9 in shadow space
  push 000000000h                                                ; value of argument #1
  push 000000010h                                                ; type of argument #1
  lea r10, [rbp-01a8h]                                           ; pointer to return value (and type, 8 bytes earlier)
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
  add rsp, 01b0h                                                 ; free space for stack
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
    push 000000011h                                              ; type of argument #1
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
    push 000000010h                                              ; type of argument #1
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
  bt qword ptr [rax], 3                                          ; check that message to print to console is String'17
  jc func$__print$messageToPrintToConsole$TypeMatch              ; skip next block if the type matches
    ; Error handling block for message to print to console
    ;  - print(parameterTypeCheckFailureMessage)
    mov [rbp+018h], rcx                                          ; save rcx in shadow space
    mov [rbp+020h], rdx                                          ; save rdx in shadow space
    mov [rbp+028h], r8                                           ; save r8 in shadow space
    mov [rbp+030h], r9                                           ; save r9 in shadow space
    mov r11, offset parameterTypeCheckFailureMessage             ; value of argument #1
    push r11                                                     ; (indirect via r11 because "parameterTypeCheckFailureMessage" is an imm64)
    push 000000011h                                              ; type of argument #1
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
    push 000000010h                                              ; type of argument #1
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
    push 000000011h                                              ; type of argument #1
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
    push 000000010h                                              ; type of argument #1
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
  bt qword ptr [rax], 2                                          ; check that exit code parameter is Integer'16
  jc func$exit$exitCodeParameter$TypeMatch                       ; skip next block if the type matches
    ; Error handling block for exit code parameter
    ;  - print(parameterTypeCheckFailureMessage)
    mov [rbp+018h], rcx                                          ; save rcx in shadow space
    mov [rbp+020h], rdx                                          ; save rdx in shadow space
    mov [rbp+028h], r8                                           ; save r8 in shadow space
    mov [rbp+030h], r9                                           ; save r9 in shadow space
    mov r11, offset parameterTypeCheckFailureMessage             ; value of argument #1
    push r11                                                     ; (indirect via r11 because "parameterTypeCheckFailureMessage" is an imm64)
    push 000000011h                                              ; type of argument #1
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
    push 000000010h                                              ; type of argument #1
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
    push 000000011h                                              ; type of argument #1
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
    push 000000010h                                              ; type of argument #1
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
  bt qword ptr [rax], 5                                          ; check that list is WhateverReadOnlyList'19
  jc func$len$list$TypeMatch                                     ; skip next block if the type matches
    ; Error handling block for list
    ;  - print(parameterTypeCheckFailureMessage)
    mov [rbp+018h], rcx                                          ; save rcx in shadow space
    mov [rbp+020h], rdx                                          ; save rdx in shadow space
    mov [rbp+028h], r8                                           ; save r8 in shadow space
    mov [rbp+030h], r9                                           ; save r9 in shadow space
    mov r11, offset parameterTypeCheckFailureMessage             ; value of argument #1
    push r11                                                     ; (indirect via r11 because "parameterTypeCheckFailureMessage" is an imm64)
    push 000000011h                                              ; type of argument #1
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
    push 000000010h                                              ; type of argument #1
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
    push 000000011h                                              ; type of argument #1
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
    push 000000010h                                              ; type of argument #1
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
    push 000000011h                                              ; type of argument #1
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
    push 000000010h                                              ; type of argument #1
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
  mov qword ptr [r15-08h], 000000010h                            ; heap handle is an integer
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
    push 000000011h                                              ; type of argument #1
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
    push 000000010h                                              ; type of argument #1
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
  bt qword ptr [rax], 2                                          ; check that heapHandle is Integer'16
  jc func$__heapAlloc$heaphandle$TypeMatch                       ; skip next block if the type matches
    ; Error handling block for heapHandle
    ;  - print(parameterTypeCheckFailureMessage)
    mov [rbp+018h], rcx                                          ; save rcx in shadow space
    mov [rbp+020h], rdx                                          ; save rdx in shadow space
    mov [rbp+028h], r8                                           ; save r8 in shadow space
    mov [rbp+030h], r9                                           ; save r9 in shadow space
    mov r11, offset parameterTypeCheckFailureMessage             ; value of argument #1
    push r11                                                     ; (indirect via r11 because "parameterTypeCheckFailureMessage" is an imm64)
    push 000000011h                                              ; type of argument #1
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
    push 000000010h                                              ; type of argument #1
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
  bt qword ptr [rax], 2                                          ; check that flags is Integer'16
  jc func$__heapAlloc$flags$TypeMatch                            ; skip next block if the type matches
    ; Error handling block for flags
    ;  - print(parameterTypeCheckFailureMessage)
    mov [rbp+018h], rcx                                          ; save rcx in shadow space
    mov [rbp+020h], rdx                                          ; save rdx in shadow space
    mov [rbp+028h], r8                                           ; save r8 in shadow space
    mov [rbp+030h], r9                                           ; save r9 in shadow space
    mov r11, offset parameterTypeCheckFailureMessage             ; value of argument #1
    push r11                                                     ; (indirect via r11 because "parameterTypeCheckFailureMessage" is an imm64)
    push 000000011h                                              ; type of argument #1
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
    push 000000010h                                              ; type of argument #1
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
  bt qword ptr [rax], 2                                          ; check that size is Integer'16
  jc func$__heapAlloc$size$TypeMatch                             ; skip next block if the type matches
    ; Error handling block for size
    ;  - print(parameterTypeCheckFailureMessage)
    mov [rbp+018h], rcx                                          ; save rcx in shadow space
    mov [rbp+020h], rdx                                          ; save rdx in shadow space
    mov [rbp+028h], r8                                           ; save r8 in shadow space
    mov [rbp+030h], r9                                           ; save r9 in shadow space
    mov r11, offset parameterTypeCheckFailureMessage             ; value of argument #1
    push r11                                                     ; (indirect via r11 because "parameterTypeCheckFailureMessage" is an imm64)
    push 000000011h                                              ; type of argument #1
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
    push 000000010h                                              ; type of argument #1
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
  mov qword ptr [r15-08h], 000000010h                            ; pointer is an integer
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
    push 000000011h                                              ; type of argument #1
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
    push 000000010h                                              ; type of argument #1
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
  bt qword ptr [rax], 2                                          ; check that heapHandle is Integer'16
  jc func$__heapFree$heaphandle$TypeMatch                        ; skip next block if the type matches
    ; Error handling block for heapHandle
    ;  - print(parameterTypeCheckFailureMessage)
    mov [rbp+018h], rcx                                          ; save rcx in shadow space
    mov [rbp+020h], rdx                                          ; save rdx in shadow space
    mov [rbp+028h], r8                                           ; save r8 in shadow space
    mov [rbp+030h], r9                                           ; save r9 in shadow space
    mov r11, offset parameterTypeCheckFailureMessage             ; value of argument #1
    push r11                                                     ; (indirect via r11 because "parameterTypeCheckFailureMessage" is an imm64)
    push 000000011h                                              ; type of argument #1
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
    push 000000010h                                              ; type of argument #1
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
  bt qword ptr [rax], 2                                          ; check that flags is Integer'16
  jc func$__heapFree$flags$TypeMatch                             ; skip next block if the type matches
    ; Error handling block for flags
    ;  - print(parameterTypeCheckFailureMessage)
    mov [rbp+018h], rcx                                          ; save rcx in shadow space
    mov [rbp+020h], rdx                                          ; save rdx in shadow space
    mov [rbp+028h], r8                                           ; save r8 in shadow space
    mov [rbp+030h], r9                                           ; save r9 in shadow space
    mov r11, offset parameterTypeCheckFailureMessage             ; value of argument #1
    push r11                                                     ; (indirect via r11 because "parameterTypeCheckFailureMessage" is an imm64)
    push 000000011h                                              ; type of argument #1
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
    push 000000010h                                              ; type of argument #1
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
  bt qword ptr [rax], 2                                          ; check that pointer is Integer'16
  jc func$__heapFree$pointer$TypeMatch                           ; skip next block if the type matches
    ; Error handling block for pointer
    ;  - print(parameterTypeCheckFailureMessage)
    mov [rbp+018h], rcx                                          ; save rcx in shadow space
    mov [rbp+020h], rdx                                          ; save rdx in shadow space
    mov [rbp+028h], r8                                           ; save r8 in shadow space
    mov [rbp+030h], r9                                           ; save r9 in shadow space
    mov r11, offset parameterTypeCheckFailureMessage             ; value of argument #1
    push r11                                                     ; (indirect via r11 because "parameterTypeCheckFailureMessage" is an imm64)
    push 000000011h                                              ; type of argument #1
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
    push 000000010h                                              ; type of argument #1
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
  mov qword ptr [r15-08h], 000000010h                            ; result is an integer
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
    push 000000011h                                              ; type of argument #1
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
    push 000000010h                                              ; type of argument #1
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
  mov qword ptr [r15-08h], 000000010h                            ; error code is an integer
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
    push 000000011h                                              ; type of argument #1
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
    push 000000010h                                              ; type of argument #1
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
  bt qword ptr [rax], 2                                          ; check that address is Integer'16
  jc func$__readFromAddress$address$TypeMatch                    ; skip next block if the type matches
    ; Error handling block for address
    ;  - print(parameterTypeCheckFailureMessage)
    mov [rbp+018h], rcx                                          ; save rcx in shadow space
    mov [rbp+020h], rdx                                          ; save rdx in shadow space
    mov [rbp+028h], r8                                           ; save r8 in shadow space
    mov [rbp+030h], r9                                           ; save r9 in shadow space
    mov r11, offset parameterTypeCheckFailureMessage             ; value of argument #1
    push r11                                                     ; (indirect via r11 because "parameterTypeCheckFailureMessage" is an imm64)
    push 000000011h                                              ; type of argument #1
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
    push 000000010h                                              ; type of argument #1
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
    push 000000011h                                              ; type of argument #1
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
    push 000000010h                                              ; type of argument #1
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
  bt qword ptr [rax], 2                                          ; check that address is Integer'16
  jc func$__writeToAddress$address$TypeMatch                     ; skip next block if the type matches
    ; Error handling block for address
    ;  - print(parameterTypeCheckFailureMessage)
    mov [rbp+018h], rcx                                          ; save rcx in shadow space
    mov [rbp+020h], rdx                                          ; save rdx in shadow space
    mov [rbp+028h], r8                                           ; save r8 in shadow space
    mov [rbp+030h], r9                                           ; save r9 in shadow space
    mov r11, offset parameterTypeCheckFailureMessage             ; value of argument #1
    push r11                                                     ; (indirect via r11 because "parameterTypeCheckFailureMessage" is an imm64)
    push 000000011h                                              ; type of argument #1
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
    push 000000010h                                              ; type of argument #1
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
  bt qword ptr [rax], 2                                          ; check that value is Integer'16
  jc func$__writeToAddress$value$TypeMatch                       ; skip next block if the type matches
    ; Error handling block for value
    ;  - print(parameterTypeCheckFailureMessage)
    mov [rbp+018h], rcx                                          ; save rcx in shadow space
    mov [rbp+020h], rdx                                          ; save rdx in shadow space
    mov [rbp+028h], r8                                           ; save r8 in shadow space
    mov [rbp+030h], r9                                           ; save r9 in shadow space
    mov r11, offset parameterTypeCheckFailureMessage             ; value of argument #1
    push r11                                                     ; (indirect via r11 because "parameterTypeCheckFailureMessage" is an imm64)
    push 000000011h                                              ; type of argument #1
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
    push 000000010h                                              ; type of argument #1
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
    push 000000011h                                              ; type of argument #1
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
    push 000000010h                                              ; type of argument #1
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
  bt qword ptr [rax], 2                                          ; check that size is Integer'16
  jc func$_alloc$size$TypeMatch                                  ; skip next block if the type matches
    ; Error handling block for size
    ;  - print(parameterTypeCheckFailureMessage)
    mov [rbp+018h], rcx                                          ; save rcx in shadow space
    mov [rbp+020h], rdx                                          ; save rdx in shadow space
    mov [rbp+028h], r8                                           ; save r8 in shadow space
    mov [rbp+030h], r9                                           ; save r9 in shadow space
    mov r11, offset parameterTypeCheckFailureMessage             ; value of argument #1
    push r11                                                     ; (indirect via r11 because "parameterTypeCheckFailureMessage" is an imm64)
    push 000000011h                                              ; type of argument #1
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
    push 000000010h                                              ; type of argument #1
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
  ; Line 11: return __heapAlloc(_heapHandle, 0, size);
  mov [rbp+018h], rcx                                            ; save rcx in shadow space
  mov [rbp+020h], rdx                                            ; save rdx in shadow space
  mov [rbp+028h], r8                                             ; save r8 in shadow space
  mov [rbp+030h], r9                                             ; save r9 in shadow space
  push [rbp+048h]                                                ; value of argument #3
  push [rbp+040h]                                                ; type of argument #3
  push 000000000h                                                ; value of argument #2
  push 000000010h                                                ; type of argument #2
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
  bt qword ptr [rax], 2                                          ; check that return value of _alloc is Integer'16
  jc func$_alloc$returnValueOfAlloc$TypeMatch                    ; skip next block if the type matches
    ; Error handling block for return value of _alloc
    ;  - print(returnValueTypeCheckFailureMessage)
    mov [rbp+018h], rcx                                          ; save rcx in shadow space
    mov [rbp+020h], rdx                                          ; save rdx in shadow space
    mov [rbp+028h], r8                                           ; save r8 in shadow space
    mov [rbp+030h], r9                                           ; save r9 in shadow space
    mov r11, offset returnValueTypeCheckFailureMessage           ; value of argument #1
    push r11                                                     ; (indirect via r11 because "returnValueTypeCheckFailureMessage" is an imm64)
    push 000000011h                                              ; type of argument #1
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
    push 000000010h                                              ; type of argument #1
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

; _stringAllocLength
func$_stringAllocLength:
  ; Prolog
  push rbp                                                       ; save non-volatile registers
  push r15                                                       ; save non-volatile registers
  sub rsp, 0e0h                                                  ; allocate space for stack
  lea rbp, [rsp+0e0h]                                            ; set up frame pointer
  mov r15, [rbp+038h]                                            ; prepare return value
  ; Check parameter count
  cmp qword ptr rcx, 000000001h                                  ; compare parameter count to integers
  je func$_stringAllocLength$parameterCount$continuation         ; check number of parameters is as expected
    ; Error handling block for parameter count
    ;  - print(parameterCountCheckFailureMessage)
    mov [rbp+018h], rcx                                          ; save rcx in shadow space
    mov [rbp+020h], rdx                                          ; save rdx in shadow space
    mov [rbp+028h], r8                                           ; save r8 in shadow space
    mov [rbp+030h], r9                                           ; save r9 in shadow space
    mov r11, offset parameterCountCheckFailureMessage            ; value of argument #1
    push r11                                                     ; (indirect via r11 because "parameterCountCheckFailureMessage" is an imm64)
    push 000000011h                                              ; type of argument #1
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
    push 000000010h                                              ; type of argument #1
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
  func$_stringAllocLength$parameterCount$continuation:           ; end of parameter count
  ; Check type of parameter 0, data (expecting String)
  mov rax, [rbp+040h]                                            ; load the dynamic type of data into rax
  lea r10, typeTable                                             ; move type table offset into r10
  add rax, r10                                                   ; adjust rax to point to the type table
  bt qword ptr [rax], 3                                          ; check that data is String'17
  jc func$_stringAllocLength$data$TypeMatch                      ; skip next block if the type matches
    ; Error handling block for data
    ;  - print(parameterTypeCheckFailureMessage)
    mov [rbp+018h], rcx                                          ; save rcx in shadow space
    mov [rbp+020h], rdx                                          ; save rdx in shadow space
    mov [rbp+028h], r8                                           ; save r8 in shadow space
    mov [rbp+030h], r9                                           ; save r9 in shadow space
    mov r11, offset parameterTypeCheckFailureMessage             ; value of argument #1
    push r11                                                     ; (indirect via r11 because "parameterTypeCheckFailureMessage" is an imm64)
    push 000000011h                                              ; type of argument #1
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
    push 000000010h                                              ; type of argument #1
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
  func$_stringAllocLength$data$TypeMatch:
  ; Line 15: Integer pointer = data __as__ Integer;
  mov r11, [rbp+048h]                                            ; value of force cast of data to Integer
  mov [rbp-048h], r11                                            ; (indirect via r11 because mov can't do memory-to-memory)
  mov qword ptr [rbp-050h], 000000010h                           ; new type of force cast of data to Integer
  mov r11, [rbp-048h]                                            ; value of pointer
  mov [rbp-058h], r11                                            ; (indirect via r11 because mov can't do memory-to-memory)
  mov r11, [rbp-050h]                                            ; type of pointer
  mov [rbp-060h], r11                                            ; (indirect via r11 because mov can't do memory-to-memory)
  ; Line 16: return __readFromAddress(pointer + 8);
  mov rax, [rbp-060h]                                            ; load the dynamic type of pointer into rax
  lea r10, typeTable                                             ; move type table offset into r10
  add rax, r10                                                   ; adjust rax to point to the type table
  bt qword ptr [rax], 2                                          ; check that pointer is Integer'16
  jc func$_stringAllocLength$pointer$TypeMatch                   ; skip next block if the type matches
    ; Error handling block for pointer
    ;  - print(operandTypeCheckFailureMessage)
    mov [rbp+018h], rcx                                          ; save rcx in shadow space
    mov [rbp+020h], rdx                                          ; save rdx in shadow space
    mov [rbp+028h], r8                                           ; save r8 in shadow space
    mov [rbp+030h], r9                                           ; save r9 in shadow space
    mov r11, offset operandTypeCheckFailureMessage               ; value of argument #1
    push r11                                                     ; (indirect via r11 because "operandTypeCheckFailureMessage" is an imm64)
    push 000000011h                                              ; type of argument #1
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
    push 000000010h                                              ; type of argument #1
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
  func$_stringAllocLength$pointer$TypeMatch:
  mov r10, [rbp-058h]                                            ; add mutates first operand, so indirect via register
  add r10, 000000008h                                            ; + operator
  mov [rbp-0a8h], r10                                            ; store result
  mov qword ptr [rbp-0b0h], 000000010h                           ; store type
  mov r10, [rbp-0a8h]                                            ; value of + operator result
  mov r11, [r10]                                                 ; dereference + operator result and put result in address of + operator result
  mov [rbp-0b8h], r11                                            ; (indirect via r11 because mov can't do memory-to-memory)
  mov qword ptr [rbp-0c0h], 000000010h                           ; type of address of + operator result
  mov rax, [rbp-0c0h]                                            ; load the dynamic type of return value of _stringAllocLength into rax
  lea r10, typeTable                                             ; move type table offset into r10
  add rax, r10                                                   ; adjust rax to point to the type table
  bt qword ptr [rax], 3                                          ; check that return value of _stringAllocLength is String'17
  jc func$_stringAllocLength$returnValueOfStringalloclength$TypeMatch ; skip next block if the type matches
    ; Error handling block for return value of _stringAllocLength
    ;  - print(returnValueTypeCheckFailureMessage)
    mov [rbp+018h], rcx                                          ; save rcx in shadow space
    mov [rbp+020h], rdx                                          ; save rdx in shadow space
    mov [rbp+028h], r8                                           ; save r8 in shadow space
    mov [rbp+030h], r9                                           ; save r9 in shadow space
    mov r11, offset returnValueTypeCheckFailureMessage           ; value of argument #1
    push r11                                                     ; (indirect via r11 because "returnValueTypeCheckFailureMessage" is an imm64)
    push 000000011h                                              ; type of argument #1
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
    push 000000010h                                              ; type of argument #1
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
  func$_stringAllocLength$returnValueOfStringalloclength$TypeMatch:
  mov r11, [rbp-0b8h]                                            ; value of return value
  mov [r15], r11                                                 ; (indirect via r11 because mov can't do memory-to-memory)
  mov r11, [rbp-0c0h]                                            ; type of return value
  mov [r15-08h], r11                                             ; (indirect via r11 because mov can't do memory-to-memory)
  jmp func$_stringAllocLength$epilog                             ; return
  func$_stringAllocLength$epilog:
  mov rax, r15                                                   ; report address of return value
  ; Epilog
  add rsp, 0e0h                                                  ; free space for stack
  pop r15                                                        ; restore non-volatile registers
  pop rbp                                                        ; restore non-volatile registers
  ret                                                            ; return from subroutine

; _stringify
func$_stringify:
  ; Prolog
  push rbp                                                       ; save non-volatile registers
  push r15                                                       ; save non-volatile registers
  sub rsp, 0110h                                                 ; allocate space for stack
  lea rbp, [rsp+0110h]                                           ; set up frame pointer
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
    push 000000011h                                              ; type of argument #1
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
    push 000000010h                                              ; type of argument #1
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
  bt qword ptr [rax], 4                                          ; check that arg is Anything'18
  jc func$_stringify$arg$TypeMatch                               ; skip next block if the type matches
    ; Error handling block for arg
    ;  - print(parameterTypeCheckFailureMessage)
    mov [rbp+018h], rcx                                          ; save rcx in shadow space
    mov [rbp+020h], rdx                                          ; save rdx in shadow space
    mov [rbp+028h], r8                                           ; save r8 in shadow space
    mov [rbp+030h], r9                                           ; save r9 in shadow space
    mov r11, offset parameterTypeCheckFailureMessage             ; value of argument #1
    push r11                                                     ; (indirect via r11 because "parameterTypeCheckFailureMessage" is an imm64)
    push 000000011h                                              ; type of argument #1
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
    push 000000010h                                              ; type of argument #1
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
  ; Line 91: if (arg is String) { ...
  mov rax, [rbp+040h]                                            ; load the dynamic type of arg into rax
  lea r10, typeTable                                             ; move type table offset into r10
  add rax, r10                                                   ; adjust rax to point to the type table
  bt qword ptr [rax], 3                                          ; check that arg is String'17
  mov qword ptr [rbp-048h], 000000000h                           ; clear is expression result
  setc byte ptr [rbp-048h]                                       ; store result in is expression result
  mov qword ptr [rbp-050h], 00000000fh                           ; is expression result is a Boolean
  cmp qword ptr [rbp-048h], 000000000h                           ; compare is expression result to false
  je func$_stringify$if$continuation                             ; arg is String
    ; Line 92: return arg;
    mov rax, [rbp+040h]                                          ; load the dynamic type of return value of _stringify into rax
    lea r10, typeTable                                           ; move type table offset into r10
    add rax, r10                                                 ; adjust rax to point to the type table
    bt qword ptr [rax], 3                                        ; check that return value of _stringify is String'17
    jc func$_stringify$Stringify$if$block$returnValueOfStringify$TypeMatch ; skip next block if the type matches
      ; Error handling block for return value of _stringify
      ;  - print(returnValueTypeCheckFailureMessage)
      mov [rbp+018h], rcx                                        ; save rcx in shadow space
      mov [rbp+020h], rdx                                        ; save rdx in shadow space
      mov [rbp+028h], r8                                         ; save r8 in shadow space
      mov [rbp+030h], r9                                         ; save r9 in shadow space
      mov r11, offset returnValueTypeCheckFailureMessage         ; value of argument #1
      push r11                                                   ; (indirect via r11 because "returnValueTypeCheckFailureMessage" is an imm64)
      push 000000011h                                            ; type of argument #1
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
      push 000000010h                                            ; type of argument #1
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
  ; Line 94: if (arg is Boolean) { ...
  mov rax, [rbp+040h]                                            ; load the dynamic type of arg into rax
  lea r10, typeTable                                             ; move type table offset into r10
  add rax, r10                                                   ; adjust rax to point to the type table
  bt qword ptr [rax], 1                                          ; check that arg is Boolean'15
  mov qword ptr [rbp-078h], 000000000h                           ; clear is expression result
  setc byte ptr [rbp-078h]                                       ; store result in is expression result
  mov qword ptr [rbp-080h], 00000000fh                           ; is expression result is a Boolean
  cmp qword ptr [rbp-078h], 000000000h                           ; compare is expression result to false
  je func$_stringify$if$continuation$1                           ; arg is Boolean
    ; Line 95: if (arg) { ...
    cmp qword ptr [rbp+048h], 000000000h                         ; compare arg to false
    je func$_stringify$Stringify$if$block$1$if$continuation      ; arg
      ; Line 96: return 'true';
      mov r11, offset string                                     ; value of return value
      mov [r15], r11                                             ; (indirect via r11 because "string" is an imm64)
      mov qword ptr [r15-08h], 000000011h                        ; type of return value
      jmp func$_stringify$epilog                                 ; return
    func$_stringify$Stringify$if$block$1$if$continuation:        ; end of if
    ; Line 98: return 'false';
    mov r11, offset string$1                                     ; value of return value
    mov [r15], r11                                               ; (indirect via r11 because "string$1" is an imm64)
    mov qword ptr [r15-08h], 000000011h                          ; type of return value
    jmp func$_stringify$epilog                                   ; return
  func$_stringify$if$continuation$1:                             ; end of if
  ; Line 100: if (arg is Null) { ...
  mov rax, [rbp+040h]                                            ; load the dynamic type of arg into rax
  lea r10, typeTable                                             ; move type table offset into r10
  add rax, r10                                                   ; adjust rax to point to the type table
  bt qword ptr [rax], 0                                          ; check that arg is Null'14
  mov qword ptr [rbp-0c8h], 000000000h                           ; clear is expression result
  setc byte ptr [rbp-0c8h]                                       ; store result in is expression result
  mov qword ptr [rbp-0d0h], 00000000fh                           ; is expression result is a Boolean
  cmp qword ptr [rbp-0c8h], 000000000h                           ; compare is expression result to false
  je func$_stringify$if$continuation$2                           ; arg is Null
    ; Line 101: return 'null';
    mov r11, offset string$2                                     ; value of return value
    mov [r15], r11                                               ; (indirect via r11 because "string$2" is an imm64)
    mov qword ptr [r15-08h], 000000011h                          ; type of return value
    jmp func$_stringify$epilog                                   ; return
  func$_stringify$if$continuation$2:                             ; end of if
  ; Line 106: __print('value cannot be stringified\n');
  mov [rbp+018h], rcx                                            ; save rcx in shadow space
  mov [rbp+020h], rdx                                            ; save rdx in shadow space
  mov [rbp+028h], r8                                             ; save r8 in shadow space
  mov [rbp+030h], r9                                             ; save r9 in shadow space
  mov r11, offset string$3                                       ; value of argument #1
  push r11                                                       ; (indirect via r11 because "string$3" is an imm64)
  push 000000011h                                                ; type of argument #1
  lea r10, [rbp-0f8h]                                            ; pointer to return value (and type, 8 bytes earlier)
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
  ; Line 107: exit(1);
  mov [rbp+018h], rcx                                            ; save rcx in shadow space
  mov [rbp+020h], rdx                                            ; save rdx in shadow space
  mov [rbp+028h], r8                                             ; save r8 in shadow space
  mov [rbp+030h], r9                                             ; save r9 in shadow space
  push 000000001h                                                ; value of argument #1
  push 000000010h                                                ; type of argument #1
  lea r10, [rbp-0108h]                                           ; pointer to return value (and type, 8 bytes earlier)
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
  add rsp, 0110h                                                 ; free space for stack
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
    bt qword ptr [rax], 4                                        ; check that vararg types is Anything'18
    jc func$print$varargTypeChecks$TypeMatch                     ; skip next block if the type matches
      ; Error handling block for vararg types
      ;  - print(parameterTypeCheckFailureMessage)
      mov [rbp+028h], rcx                                        ; save rcx in shadow space
      mov [rbp+030h], rdx                                        ; save rdx in shadow space
      mov [rbp+038h], r8                                         ; save r8 in shadow space
      mov [rbp+040h], r9                                         ; save r9 in shadow space
      mov r11, offset parameterTypeCheckFailureMessage           ; value of argument #1
      push r11                                                   ; (indirect via r11 because "parameterTypeCheckFailureMessage" is an imm64)
      push 000000011h                                            ; type of argument #1
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
      push 000000010h                                            ; type of argument #1
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
  ; Line 111: Boolean first = true;
  mov qword ptr [rbp-028h], 000000001h                           ; value of first
  mov qword ptr [rbp-030h], 00000000fh                           ; type of first
  ; Line 112: Integer index = 0;
  mov qword ptr [rbp-038h], 000000000h                           ; value of index
  mov qword ptr [rbp-040h], 000000010h                           ; type of index
  ; Line 113: while (index < len(parts)) { ...
  func$print$while$top:
    mov rax, [rbp-040h]                                          ; load the dynamic type of index into rax
    lea r10, typeTable                                           ; move type table offset into r10
    add rax, r10                                                 ; adjust rax to point to the type table
    bt qword ptr [rax], 2                                        ; check that index is Integer'16
    jc func$print$while$index$TypeMatch                          ; skip next block if the type matches
      ; Error handling block for index
      ;  - print(operandTypeCheckFailureMessage)
      mov [rbp+028h], rcx                                        ; save rcx in shadow space
      mov [rbp+030h], rdx                                        ; save rdx in shadow space
      mov [rbp+038h], r8                                         ; save r8 in shadow space
      mov [rbp+040h], r9                                         ; save r9 in shadow space
      mov r11, offset operandTypeCheckFailureMessage             ; value of argument #1
      push r11                                                   ; (indirect via r11 because "operandTypeCheckFailureMessage" is an imm64)
      push 000000011h                                            ; type of argument #1
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
      push 000000010h                                            ; type of argument #1
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
    mov qword ptr [rbp-090h], 00000000fh                         ; < operator result is a Boolean
    cmp qword ptr [rbp-088h], 000000000h                         ; compare < operator result to false
    je func$print$while$bottom                                   ; while condition
    ; Line 114: if (first == false) { ...
    xor r10, r10                                                 ; prepare r10 for result of value comparison
    cmp qword ptr [rbp-028h], 000000000h                         ; compare first to false
    sete byte ptr r10b                                           ; store result in r10
    xor rax, rax                                                 ; prepare rax for result of type comparison
    cmp qword ptr [rbp-030h], 00000000fh                         ; compare type of first to type of false
    sete byte ptr al                                             ; store result in rax
    and r10, rax                                                 ; true if type and value are both equal; result goes into r10
    mov [rbp-098h], r10                                          ; store result in == operator result
    mov qword ptr [rbp-0a0h], 00000000fh                         ; == operator result is a Boolean
    cmp qword ptr [rbp-098h], 000000000h                         ; compare == operator result to false
    je func$print$while$if$continuation                          ; first == false
      ; Line 115: __print(' ');
      mov [rbp+028h], rcx                                        ; save rcx in shadow space
      mov [rbp+030h], rdx                                        ; save rdx in shadow space
      mov [rbp+038h], r8                                         ; save r8 in shadow space
      mov [rbp+040h], r9                                         ; save r9 in shadow space
      mov r11, offset string$4                                   ; value of argument #1
      push r11                                                   ; (indirect via r11 because "string$4" is an imm64)
      push 000000011h                                            ; type of argument #1
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
    ; Line 117: __print(_stringify(parts[index]));
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
      push 000000011h                                            ; type of argument #1
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
      push 000000010h                                            ; type of argument #1
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
    ; Line 118: first = false;
    mov qword ptr [rbp-028h], 000000000h                         ; value of first
    mov qword ptr [rbp-030h], 00000000fh                         ; type of first
    ; Line 119: index += 1;
    mov rax, [rbp-040h]                                          ; load the dynamic type of <index: Integer at null; compile-time constant> into rax
    lea r10, typeTable                                           ; move type table offset into r10
    add rax, r10                                                 ; adjust rax to point to the type table
    bt qword ptr [rax], 2                                        ; check that <index: Integer at null; compile-time constant> is Integer'16
    jc func$print$while$IndexINtegerAtNullCompileTimeConstant$TypeMatch ; skip next block if the type matches
      ; Error handling block for <index: Integer at null; compile-time constant>
      ;  - print(operandTypeCheckFailureMessage)
      mov [rbp+028h], rcx                                        ; save rcx in shadow space
      mov [rbp+030h], rdx                                        ; save rdx in shadow space
      mov [rbp+038h], r8                                         ; save r8 in shadow space
      mov [rbp+040h], r9                                         ; save r9 in shadow space
      mov r11, offset operandTypeCheckFailureMessage             ; value of argument #1
      push r11                                                   ; (indirect via r11 because "operandTypeCheckFailureMessage" is an imm64)
      push 000000011h                                            ; type of argument #1
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
      push 000000010h                                            ; type of argument #1
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
    mov qword ptr [rbp-0110h], 000000010h                        ; store type
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
    bt qword ptr [rax], 4                                        ; check that vararg types is Anything'18
    jc func$println$varargTypeChecks$TypeMatch                   ; skip next block if the type matches
      ; Error handling block for vararg types
      ;  - print(parameterTypeCheckFailureMessage)
      mov [rbp+028h], rcx                                        ; save rcx in shadow space
      mov [rbp+030h], rdx                                        ; save rdx in shadow space
      mov [rbp+038h], r8                                         ; save r8 in shadow space
      mov [rbp+040h], r9                                         ; save r9 in shadow space
      mov r11, offset parameterTypeCheckFailureMessage           ; value of argument #1
      push r11                                                   ; (indirect via r11 because "parameterTypeCheckFailureMessage" is an imm64)
      push 000000011h                                            ; type of argument #1
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
      push 000000010h                                            ; type of argument #1
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
  ; Line 124: Boolean first = true;
  mov qword ptr [rbp-028h], 000000001h                           ; value of first
  mov qword ptr [rbp-030h], 00000000fh                           ; type of first
  ; Line 125: Integer index = 0;
  mov qword ptr [rbp-038h], 000000000h                           ; value of index
  mov qword ptr [rbp-040h], 000000010h                           ; type of index
  ; Line 126: while (index < len(parts)) { ...
  func$println$while$top:
    mov rax, [rbp-040h]                                          ; load the dynamic type of index into rax
    lea r10, typeTable                                           ; move type table offset into r10
    add rax, r10                                                 ; adjust rax to point to the type table
    bt qword ptr [rax], 2                                        ; check that index is Integer'16
    jc func$println$while$index$TypeMatch                        ; skip next block if the type matches
      ; Error handling block for index
      ;  - print(operandTypeCheckFailureMessage)
      mov [rbp+028h], rcx                                        ; save rcx in shadow space
      mov [rbp+030h], rdx                                        ; save rdx in shadow space
      mov [rbp+038h], r8                                         ; save r8 in shadow space
      mov [rbp+040h], r9                                         ; save r9 in shadow space
      mov r11, offset operandTypeCheckFailureMessage             ; value of argument #1
      push r11                                                   ; (indirect via r11 because "operandTypeCheckFailureMessage" is an imm64)
      push 000000011h                                            ; type of argument #1
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
      push 000000010h                                            ; type of argument #1
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
    mov qword ptr [rbp-090h], 00000000fh                         ; < operator result is a Boolean
    cmp qword ptr [rbp-088h], 000000000h                         ; compare < operator result to false
    je func$println$while$bottom                                 ; while condition
    ; Line 127: if (first == false) { ...
    xor r10, r10                                                 ; prepare r10 for result of value comparison
    cmp qword ptr [rbp-028h], 000000000h                         ; compare first to false
    sete byte ptr r10b                                           ; store result in r10
    xor rax, rax                                                 ; prepare rax for result of type comparison
    cmp qword ptr [rbp-030h], 00000000fh                         ; compare type of first to type of false
    sete byte ptr al                                             ; store result in rax
    and r10, rax                                                 ; true if type and value are both equal; result goes into r10
    mov [rbp-098h], r10                                          ; store result in == operator result
    mov qword ptr [rbp-0a0h], 00000000fh                         ; == operator result is a Boolean
    cmp qword ptr [rbp-098h], 000000000h                         ; compare == operator result to false
    je func$println$while$if$continuation                        ; first == false
      ; Line 128: __print(' ');
      mov [rbp+028h], rcx                                        ; save rcx in shadow space
      mov [rbp+030h], rdx                                        ; save rdx in shadow space
      mov [rbp+038h], r8                                         ; save r8 in shadow space
      mov [rbp+040h], r9                                         ; save r9 in shadow space
      mov r11, offset string$4                                   ; value of argument #1
      push r11                                                   ; (indirect via r11 because "string$4" is an imm64)
      push 000000011h                                            ; type of argument #1
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
    ; Line 130: __print(_stringify(parts[index]));
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
      push 000000011h                                            ; type of argument #1
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
      push 000000010h                                            ; type of argument #1
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
    ; Line 131: first = false;
    mov qword ptr [rbp-028h], 000000000h                         ; value of first
    mov qword ptr [rbp-030h], 00000000fh                         ; type of first
    ; Line 132: index += 1;
    mov rax, [rbp-040h]                                          ; load the dynamic type of <index: Integer at null; compile-time constant> into rax
    lea r10, typeTable                                           ; move type table offset into r10
    add rax, r10                                                 ; adjust rax to point to the type table
    bt qword ptr [rax], 2                                        ; check that <index: Integer at null; compile-time constant> is Integer'16
    jc func$println$while$IndexINtegerAtNullCompileTimeConstant$TypeMatch ; skip next block if the type matches
      ; Error handling block for <index: Integer at null; compile-time constant>
      ;  - print(operandTypeCheckFailureMessage)
      mov [rbp+028h], rcx                                        ; save rcx in shadow space
      mov [rbp+030h], rdx                                        ; save rdx in shadow space
      mov [rbp+038h], r8                                         ; save r8 in shadow space
      mov [rbp+040h], r9                                         ; save r9 in shadow space
      mov r11, offset operandTypeCheckFailureMessage             ; value of argument #1
      push r11                                                   ; (indirect via r11 because "operandTypeCheckFailureMessage" is an imm64)
      push 000000011h                                            ; type of argument #1
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
      push 000000010h                                            ; type of argument #1
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
    mov qword ptr [rbp-0110h], 000000010h                        ; store type
    mov r11, [rbp-0108h]                                         ; value of index
    mov [rbp-038h], r11                                          ; (indirect via r11 because mov can't do memory-to-memory)
    mov r11, [rbp-0110h]                                         ; type of index
    mov [rbp-040h], r11                                          ; (indirect via r11 because mov can't do memory-to-memory)
    jmp func$println$while$top                                   ; return to top of while
  func$println$while$bottom:
  ; Line 134: __print('\n');
  mov [rbp+028h], rcx                                            ; save rcx in shadow space
  mov [rbp+030h], rdx                                            ; save rdx in shadow space
  mov [rbp+038h], r8                                             ; save r8 in shadow space
  mov [rbp+040h], r9                                             ; save r9 in shadow space
  mov r11, offset string$5                                       ; value of argument #1
  push r11                                                       ; (indirect via r11 because "string$5" is an imm64)
  push 000000011h                                                ; type of argument #1
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

; _free
func$_free:
  ; Prolog
  push rbp                                                       ; save non-volatile registers
  push r15                                                       ; save non-volatile registers
  sub rsp, 0b0h                                                  ; allocate space for stack
  lea rbp, [rsp+0b0h]                                            ; set up frame pointer
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
    push 000000011h                                              ; type of argument #1
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
    push 000000010h                                              ; type of argument #1
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
  bt qword ptr [rax], 2                                          ; check that pointer is Integer'16
  jc func$_free$pointer$TypeMatch                                ; skip next block if the type matches
    ; Error handling block for pointer
    ;  - print(parameterTypeCheckFailureMessage)
    mov [rbp+018h], rcx                                          ; save rcx in shadow space
    mov [rbp+020h], rdx                                          ; save rdx in shadow space
    mov [rbp+028h], r8                                           ; save r8 in shadow space
    mov [rbp+030h], r9                                           ; save r9 in shadow space
    mov r11, offset parameterTypeCheckFailureMessage             ; value of argument #1
    push r11                                                     ; (indirect via r11 because "parameterTypeCheckFailureMessage" is an imm64)
    push 000000011h                                              ; type of argument #1
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
    push 000000010h                                              ; type of argument #1
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
  ; Line 143: if (__heapFree(_heapHandle, 0, pointer) == 0) { ...
  mov [rbp+018h], rcx                                            ; save rcx in shadow space
  mov [rbp+020h], rdx                                            ; save rdx in shadow space
  mov [rbp+028h], r8                                             ; save r8 in shadow space
  mov [rbp+030h], r9                                             ; save r9 in shadow space
  push [rbp+048h]                                                ; value of argument #3
  push [rbp+040h]                                                ; type of argument #3
  push 000000000h                                                ; value of argument #2
  push 000000010h                                                ; type of argument #2
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
  cmp qword ptr [rbp-050h], 000000010h                           ; compare type of return value to type of 0
  sete byte ptr al                                               ; store result in rax
  and r10, rax                                                   ; true if type and value are both equal; result goes into r10
  mov [rbp-058h], r10                                            ; store result in == operator result
  mov qword ptr [rbp-060h], 00000000fh                           ; == operator result is a Boolean
  cmp qword ptr [rbp-058h], 000000000h                           ; compare == operator result to false
  je func$_free$if$continuation                                  ; __heapFree(_heapHandle, 0, pointer) == 0
    ; Line 144: println('failed to free pointer, error code: ', __getLastError()...
    mov [rbp+018h], rcx                                          ; save rcx in shadow space
    mov [rbp+020h], rdx                                          ; save rdx in shadow space
    mov [rbp+028h], r8                                           ; save r8 in shadow space
    mov [rbp+030h], r9                                           ; save r9 in shadow space
    lea r10, [rbp-068h]                                          ; pointer to return value (and type, 8 bytes earlier)
    push r10                                                     ; (that pointer is the last value pushed to the stack)
    mov qword ptr r9, 0h                                         ; pointer to this
    mov qword ptr r8, 000000000h                                 ; type of this
    mov qword ptr rdx, 0h                                        ; pointer to closure
    mov rcx, 0                                                   ; number of arguments
    sub rsp, 20h                                                 ; allocate shadow space
    call offset func$__getLastError                              ; jump to subroutine
    add rsp, 028h                                                ; release shadow space and arguments
    mov rcx, [rbp+018h]                                          ; restore rcx from shadow space
    mov rdx, [rbp+020h]                                          ; restore rdx from shadow space
    mov r8, [rbp+028h]                                           ; restore r8 from shadow space
    mov r9, [rbp+030h]                                           ; restore r9 from shadow space
    mov [rbp+018h], rcx                                          ; save rcx in shadow space
    mov [rbp+020h], rdx                                          ; save rdx in shadow space
    mov [rbp+028h], r8                                           ; save r8 in shadow space
    mov [rbp+030h], r9                                           ; save r9 in shadow space
    push [rbp-068h]                                              ; value of argument #2
    push [rbp-070h]                                              ; type of argument #2
    mov r11, offset string$6                                     ; value of argument #1
    push r11                                                     ; (indirect via r11 because "string$6" is an imm64)
    push 000000011h                                              ; type of argument #1
    lea r10, [rbp-078h]                                          ; pointer to return value (and type, 8 bytes earlier)
    push r10                                                     ; (that pointer is the last value pushed to the stack)
    mov qword ptr r9, 0h                                         ; pointer to this
    mov qword ptr r8, 000000000h                                 ; type of this
    mov qword ptr rdx, 0h                                        ; pointer to closure
    mov rcx, 2                                                   ; number of arguments
    sub rsp, 20h                                                 ; allocate shadow space
    call offset func$println                                     ; jump to subroutine
    add rsp, 048h                                                ; release shadow space and arguments
    mov rcx, [rbp+018h]                                          ; restore rcx from shadow space
    mov rdx, [rbp+020h]                                          ; restore rdx from shadow space
    mov r8, [rbp+028h]                                           ; restore r8 from shadow space
    mov r9, [rbp+030h]                                           ; restore r9 from shadow space
    ; Line 145: exit(1);
    mov [rbp+018h], rcx                                          ; save rcx in shadow space
    mov [rbp+020h], rdx                                          ; save rdx in shadow space
    mov [rbp+028h], r8                                           ; save r8 in shadow space
    mov [rbp+030h], r9                                           ; save r9 in shadow space
    push 000000001h                                              ; value of argument #1
    push 000000010h                                              ; type of argument #1
    lea r10, [rbp-088h]                                          ; pointer to return value (and type, 8 bytes earlier)
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
  ; Line 147: return true;
  mov qword ptr [r15], 000000001h                                ; value of return value
  mov qword ptr [r15-08h], 00000000fh                            ; type of return value
  jmp func$_free$epilog                                          ; return
  func$_free$epilog:
  mov rax, r15                                                   ; report address of return value
  ; Epilog
  add rsp, 0b0h                                                  ; free space for stack
  pop r15                                                        ; restore non-volatile registers
  pop rbp                                                        ; restore non-volatile registers
  ret                                                            ; return from subroutine


end

