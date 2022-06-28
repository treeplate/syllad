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
extern GetLastError : proc
extern GetProcessHeap : proc
extern HeapAlloc : proc
extern HeapFree : proc

.const
  typeTable    db 03fh, 010h, 010h, 010h, 010h, 010h, 010h, 010h, 010h, 010h, 010h, 010h, 010h, 030h, 010h, 010h, 010h, 030h, 010h, 011h, 012h, 014h, 018h, 000h ; Type table
   ; Columns: Null'19 Boolean'20 Integer'21 String'22 Anything'23 WhateverReadOnlyList'24
   ; 1 1 1 1 1 1   <sentinel>'0
   ; 0 0 0 0 1 0   NullFunction(String)'1
   ; 0 0 0 0 1 0   NullFunction(Integer)'2
   ; 0 0 0 0 1 0   IntegerFunction(WhateverReadOnlyList)'3
   ; 0 0 0 0 1 0   NullFunction()'4
   ; 0 0 0 0 1 0   IntegerFunction(Integer)'5
   ; 0 0 0 0 1 0   NullFunction(Integer, Integer)'6
   ; 0 0 0 0 1 0   NullFunction(Boolean, String)'7
   ; 0 0 0 0 1 0   IntegerFunction()'8
   ; 0 0 0 0 1 0   IntegerFunction(Integer, Integer, Integer)'9
   ; 0 0 0 0 1 0   NullFunction(Integer, Integer, Integer)'10
   ; 0 0 0 0 1 0   IntegerFunction(String)'11
   ; 0 0 0 0 1 0   StringFunction(String...)'12
   ; 0 0 0 0 1 1   StringReadOnlyList'13
   ; 0 0 0 0 1 0   StringFunction(Integer)'14
   ; 0 0 0 0 1 0   StringFunction(Anything)'15
   ; 0 0 0 0 1 0   NullFunction(Anything...)'16
   ; 0 0 0 0 1 1   AnythingReadOnlyList'17
   ; 0 0 0 0 1 0   StringFunction(Integer, String, String)'18
   ; 1 0 0 0 1 0   Null'19
   ; 0 1 0 0 1 0   Boolean'20
   ; 0 0 1 0 1 0   Integer'21
   ; 0 0 0 1 1 0   String'22

  parameterCountCheckFailureMessage dq -01h                      ; String constant (reference count)
               dq 88                                             ; Length
               db "error: function call received the wrong number of parameters (expected %d, received %d)", 0ah ; line 1629 column 25 in file syd-compiler.syd
               db 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h         ; padding to align to 8-byte boundary
  parameterTypeCheckFailureMessage dq -01h                       ; String constant (reference count)
               dq 71                                             ; Length
               db "error: type mismatch for function %s parameter %d, expected %s, got %s", 0ah ; line 1634 column 25 in file syd-compiler.syd
               db 00h                                            ; padding to align to 8-byte boundary
  returnValueTypeCheckFailureMessage dq -01h                     ; String constant (reference count)
               dq 68                                             ; Length
               db "error: type mismatch for function return value, expected %s, got %s", 0ah ; line 1639 column 25 in file syd-compiler.syd
               db 00h, 00h, 00h, 00h                             ; padding to align to 8-byte boundary
  operandTypeCheckFailureMessage dq -01h                         ; String constant (reference count)
               dq 54                                             ; Length
               db "error: type mismatch for operand, expected %s, got %s", 0ah ; line 1644 column 25 in file syd-compiler.syd
               db 00h, 00h                                       ; padding to align to 8-byte boundary
  asOperatorFailureMessage dq -01h                               ; String constant (reference count)
               dq 58                                             ; Length
               db "error: type mismatch for as operator, expected %s, got %s", 0ah ; line 1649 column 25 in file syd-compiler.syd
               db 00h, 00h, 00h, 00h, 00h, 00h                   ; padding to align to 8-byte boundary
  boundsFailureMessage dq -01h                                   ; String constant (reference count)
               dq 64                                             ; Length
               db "error: subscript index out of range (%d is not in range %d..%d)", 0ah ; line 1654 column 25 in file syd-compiler.syd
               db 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h         ; padding to align to 8-byte boundary
  string       dq -01h                                           ; String constant (reference count)
               dq 1                                              ; Length
               db 0ah                                            ; line 8 column 16 in file runtime library
               db 00h, 00h, 00h, 00h, 00h, 00h, 00h              ; padding to align to 8-byte boundary
  string$1     dq -01h                                           ; String constant (reference count)
               dq 51                                             ; Length
               db "_moveBytes expects positive number of bytes to copy" ; line 46 column 74 in file runtime library
               db 00h, 00h, 00h, 00h, 00h                        ; padding to align to 8-byte boundary
  string$2     dq -01h                                           ; String constant (reference count)
               dq 61                                             ; Length
               db "internal error: zero extra bytes but fromCursor is before end" ; line 65 column 90 in file runtime library
               db 00h, 00h, 00h                                  ; padding to align to 8-byte boundary
  string$3     dq -01h                                           ; String constant (reference count)
               dq 39                                             ; Length
               db "internal error: more than 7 extra bytes"      ; line 66 column 68 in file runtime library
               db 00h                                            ; padding to align to 8-byte boundary
  string$4     dq -01h                                           ; String constant (reference count)
               dq 1                                              ; Length
               db "0"                                            ; line 105 column 14 in file runtime library
               db 00h, 00h, 00h, 00h, 00h, 00h, 00h              ; padding to align to 8-byte boundary
  string$5     dq -01h                                           ; String constant (reference count)
               dq 1                                              ; Length
               db "1"                                            ; line 108 column 14 in file runtime library
               db 00h, 00h, 00h, 00h, 00h, 00h, 00h              ; padding to align to 8-byte boundary
  string$6     dq -01h                                           ; String constant (reference count)
               dq 1                                              ; Length
               db "2"                                            ; line 111 column 14 in file runtime library
               db 00h, 00h, 00h, 00h, 00h, 00h, 00h              ; padding to align to 8-byte boundary
  string$7     dq -01h                                           ; String constant (reference count)
               dq 1                                              ; Length
               db "3"                                            ; line 114 column 14 in file runtime library
               db 00h, 00h, 00h, 00h, 00h, 00h, 00h              ; padding to align to 8-byte boundary
  string$8     dq -01h                                           ; String constant (reference count)
               dq 1                                              ; Length
               db "4"                                            ; line 117 column 14 in file runtime library
               db 00h, 00h, 00h, 00h, 00h, 00h, 00h              ; padding to align to 8-byte boundary
  string$9     dq -01h                                           ; String constant (reference count)
               dq 1                                              ; Length
               db "5"                                            ; line 120 column 14 in file runtime library
               db 00h, 00h, 00h, 00h, 00h, 00h, 00h              ; padding to align to 8-byte boundary
  string$10    dq -01h                                           ; String constant (reference count)
               dq 1                                              ; Length
               db "6"                                            ; line 123 column 14 in file runtime library
               db 00h, 00h, 00h, 00h, 00h, 00h, 00h              ; padding to align to 8-byte boundary
  string$11    dq -01h                                           ; String constant (reference count)
               dq 1                                              ; Length
               db "7"                                            ; line 126 column 14 in file runtime library
               db 00h, 00h, 00h, 00h, 00h, 00h, 00h              ; padding to align to 8-byte boundary
  string$12    dq -01h                                           ; String constant (reference count)
               dq 1                                              ; Length
               db "8"                                            ; line 129 column 14 in file runtime library
               db 00h, 00h, 00h, 00h, 00h, 00h, 00h              ; padding to align to 8-byte boundary
  string$13    dq -01h                                           ; String constant (reference count)
               dq 1                                              ; Length
               db "9"                                            ; line 132 column 14 in file runtime library
               db 00h, 00h, 00h, 00h, 00h, 00h, 00h              ; padding to align to 8-byte boundary
  string$14    dq -01h                                           ; String constant (reference count)
               dq 56                                             ; Length
               db "Invalid digit passed to digitToStr (digit as exit code)", 0ah ; line 134 column 69 in file runtime library
               db 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h         ; padding to align to 8-byte boundary
  string$15    dq -01h                                           ; String constant (reference count)
               dq 0                                              ; Length
  string$16    dq -01h                                           ; String constant (reference count)
               dq 4                                              ; Length
               db "true"                                         ; line 158 column 19 in file runtime library
               db 00h, 00h, 00h, 00h                             ; padding to align to 8-byte boundary
  string$17    dq -01h                                           ; String constant (reference count)
               dq 5                                              ; Length
               db "false"                                        ; line 160 column 18 in file runtime library
               db 00h, 00h, 00h                                  ; padding to align to 8-byte boundary
  string$18    dq -01h                                           ; String constant (reference count)
               dq 4                                              ; Length
               db "null"                                         ; line 163 column 17 in file runtime library
               db 00h, 00h, 00h, 00h                             ; padding to align to 8-byte boundary
  string$19    dq -01h                                           ; String constant (reference count)
               dq 28                                             ; Length
               db "value cannot be stringified", 0ah             ; line 168 column 41 in file runtime library
               db 00h, 00h, 00h, 00h                             ; padding to align to 8-byte boundary
  string$20    dq -01h                                           ; String constant (reference count)
               dq 1                                              ; Length
               db " "                                            ; line 177 column 17 in file runtime library
               db 00h, 00h, 00h, 00h, 00h, 00h, 00h              ; padding to align to 8-byte boundary
  string$21    dq -01h                                           ; String constant (reference count)
               dq 18                                             ; Length
               db "No bottles of beer"                           ; line 10 column 31 in file temp.syd
               db 00h, 00h, 00h, 00h, 00h, 00h                   ; padding to align to 8-byte boundary
  string$22    dq -01h                                           ; String constant (reference count)
               dq 6                                              ; Length
               db "bottle"                                       ; line 12 column 62 in file temp.syd
               db 00h, 00h                                       ; padding to align to 8-byte boundary
  string$23    dq -01h                                           ; String constant (reference count)
               dq 7                                              ; Length
               db "bottles"                                      ; line 12 column 73 in file temp.syd
               db 00h                                            ; padding to align to 8-byte boundary
  string$24    dq -01h                                           ; String constant (reference count)
               dq 8                                              ; Length
               db " of beer"                                     ; line 12 column 86 in file temp.syd
               db 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h         ; padding to align to 8-byte boundary
  string$25    dq -01h                                           ; String constant (reference count)
               dq 12                                             ; Length
               db " on the wall"                                 ; line 16 column 46 in file temp.syd
               db 00h, 00h, 00h, 00h                             ; padding to align to 8-byte boundary
  string$26    dq -01h                                           ; String constant (reference count)
               dq 28                                             ; Length
               db "Take it down, pass it around"                 ; line 23 column 42 in file temp.syd
               db 00h, 00h, 00h, 00h                             ; padding to align to 8-byte boundary
  string$27    dq -01h                                           ; String constant (reference count)
               dq 29                                             ; Length
               db "Take one down, pass it around"                ; line 25 column 43 in file temp.syd
               db 00h, 00h, 00h                                  ; padding to align to 8-byte boundary
  string$28    dq -01h                                           ; String constant (reference count)
               dq 30                                             ; Length
               db "99 BOTTLES OF BEER ON THE WALL"               ; line 41 column 40 in file temp.syd
               db 00h, 00h                                       ; padding to align to 8-byte boundary
  string$29    dq -01h                                           ; String constant (reference count)
               dq 11                                             ; Length
               db "memory leak"                                  ; line 44 column 38 in file temp.syd
               db 00h, 00h, 00h, 00h, 00h                        ; padding to align to 8-byte boundary

.data


_BSS segment
  _heapHandleValue dq ?                                          ; _heapHandle variable
  _heapHandleType dq ?                                           ; dynamic type of _heapHandle variable
  _blockCountValue dq ?                                          ; _blockCount variable
  _blockCountType dq ?                                           ; dynamic type of _blockCount variable

.code

public main
; decref intrinsic; used to decrement the reference count of string variables
intrinsic$decref:
  ; variable's type is in rdx
  ; variable's value is in rcx
  ; if variable is a string then it is actually a pointer to the reference count
  cmp rdx, 22                                                    ; verify that the variable is a string
  jne intrinsic$decref$end                                       ; if not, abort
  ; check reference count is not negative
  cmp qword ptr [rcx], 0                                         ; if the refcount is negative then this is a constant, not reference counted
  js intrinsic$decref$end                                        ; ...so abort
  dec qword ptr [rcx]                                            ; decrement the reference count
  jnz intrinsic$decref$end                                       ; if we did not reach zero, then the string is still in use; abort
  ; String reached zero reference count, so we must free it.
  push rcx                                                       ; argument #1 value: pointer to block we want to free.
  push 21                                                        ; argument #1 type: integer
  lea r11, qword ptr [rsp + 018h]                                ; use rcx shadow space for the return value
  push r11                                                       ; internal argument 6: pointer to return value's value
  lea r11, qword ptr [rsp + 028h]                                ; use rdx shadow space for the return type
  push r11                                                       ; internal argument 5: pointer to return value's type
  sub rsp, 020h                                                  ; allocate shadow space
  mov r9, 000h                                                   ; internal argument 4: "this" pointer
  mov r8, 000h                                                   ; internal argument 3: "this" pointer type
  mov rdx, 000h                                                  ; internal argument 2: closure pointer
  mov rcx, 001h                                                  ; internal argument 1: number of actual arguments
  call func$_free                                                ; jump to subroutine
  add rsp, 040h                                                  ; release shadow space and arguments (result in stack pointer)
  intrinsic$decref$end: 
  ret                                                            ; return from subroutine

main:
  ; intrinsics
  ; ==========
  ; Prolog
  push rbp                                                       ; save non-volatile registers
  sub rsp, 008h                                                  ; allocate space for stack
  lea rbp, qword ptr [rsp + 010h]                                ; set up frame pointer
  ; Epilog
  add rsp, 008h                                                  ; free space for stack
  pop rbp                                                        ; restore non-volatile registers

  ; runtime library
  ; ===============
  ; Prolog
  push rbp                                                       ; save non-volatile registers
  sub rsp, 018h                                                  ; allocate space for stack
  lea rbp, qword ptr [rsp + 020h]                                ; set up frame pointer
  ; Line 17: Integer _heapHandle = __getProcessHeap();
  ; Call __getProcessHeap with 0 arguments
  lea r10, qword ptr [rsp + 008h]                                ; load address of return value's value
  push r10                                                       ; internal argument 6: pointer to return value slot's value
  lea r10, qword ptr [rsp + 008h]                                ; load address of return value's type
  push r10                                                       ; internal argument 5: pointer to return value slot's type
  sub rsp, 020h                                                  ; allocate shadow space
  mov r9, 000h                                                   ; internal argument 4: "this" pointer
  mov r8, 000h                                                   ; internal argument 3: "this" pointer type
  mov rdx, 000h                                                  ; internal argument 2: closure pointer
  mov rcx, 000h                                                  ; internal argument 1: number of actual arguments
  call func$__getProcessHeap                                     ; jump to subroutine
  add rsp, 030h                                                  ; release shadow space and arguments (result in stack pointer)
  mov r11, qword ptr [rsp + 008h]                                ; indirect through r11 because operand pair (qword ptr _heapHandleValue, stack operand #1) is not allowed with mov
  mov qword ptr _heapHandleValue, r11                            ; value initialization of variable declaration for _heapHandle variable (__getProcessHeap return value)
  mov r11, qword ptr [rsp + 000h]                                ; indirect through r11 because operand pair (qword ptr _heapHandleType, stack operand #2) is not allowed with mov
  mov qword ptr _heapHandleType, r11                             ; type initialization of variable declaration for _heapHandle variable
  ; Line 21: Integer _blockCount = 0;
  mov qword ptr _blockCountValue, 000h                           ; value initialization of variable declaration for _blockCount variable (0)
  mov qword ptr _blockCountType, 015h                            ; type initialization of variable declaration for _blockCount variable (Integer'21)
  ; Epilog
  add rsp, 018h                                                  ; free space for stack
  pop rbp                                                        ; restore non-volatile registers

  ; temp.syd
  ; ========
  ; Prolog
  push r15                                                       ; save non-volatile registers
  push rbx                                                       ; save non-volatile registers
  push rsi                                                       ; save non-volatile registers
  push rdi                                                       ; save non-volatile registers
  push rbp                                                       ; save non-volatile registers
  push r12                                                       ; save non-volatile registers
  push r13                                                       ; save non-volatile registers
  push r14                                                       ; save non-volatile registers
  sub rsp, 018h                                                  ; allocate space for stack
  lea rbp, qword ptr [rsp + 058h]                                ; set up frame pointer
  ; Line 41: println('99 BOTTLES OF BEER ON THE WALL');
  ; Call println with 1 arguments
  mov r10, offset string$28                                      ; reading string for push
  push r10                                                       ; value of argument #1 (string)
  push 016h                                                      ; type of argument #1 (String'22)
  lea rax, qword ptr [rsp + 018h]                                ; load address of return value's value
  push rax                                                       ; internal argument 6: pointer to return value slot's value
  lea rax, qword ptr [rsp + 018h]                                ; load address of return value's type
  push rax                                                       ; internal argument 5: pointer to return value slot's type
  sub rsp, 020h                                                  ; allocate shadow space
  mov r9, 000h                                                   ; internal argument 4: "this" pointer
  mov r8, 000h                                                   ; internal argument 3: "this" pointer type
  mov rdx, 000h                                                  ; internal argument 2: closure pointer
  mov rcx, 001h                                                  ; internal argument 1: number of actual arguments
  call func$println                                              ; jump to subroutine
  add rsp, 040h                                                  ; release shadow space and arguments (result in stack pointer)
  ; Line 42: println();
  ; Call println with 0 arguments
  lea rbx, qword ptr [rsp + 008h]                                ; load address of return value's value
  push rbx                                                       ; internal argument 6: pointer to return value slot's value
  lea rbx, qword ptr [rsp + 008h]                                ; load address of return value's type
  push rbx                                                       ; internal argument 5: pointer to return value slot's type
  sub rsp, 020h                                                  ; allocate shadow space
  mov r9, 000h                                                   ; internal argument 4: "this" pointer
  mov r8, 000h                                                   ; internal argument 3: "this" pointer type
  mov rdx, 000h                                                  ; internal argument 2: closure pointer
  mov rcx, 000h                                                  ; internal argument 1: number of actual arguments
  call func$println                                              ; jump to subroutine
  add rsp, 030h                                                  ; release shadow space and arguments (result in stack pointer)
  ; Line 43: allBottles();
  ; Call allBottles with 0 arguments
  lea rsi, qword ptr [rsp + 008h]                                ; load address of return value's value
  push rsi                                                       ; internal argument 6: pointer to return value slot's value
  lea rsi, qword ptr [rsp + 008h]                                ; load address of return value's type
  push rsi                                                       ; internal argument 5: pointer to return value slot's type
  sub rsp, 020h                                                  ; allocate shadow space
  mov r9, 000h                                                   ; internal argument 4: "this" pointer
  mov r8, 000h                                                   ; internal argument 3: "this" pointer type
  mov rdx, 000h                                                  ; internal argument 2: closure pointer
  mov rcx, 000h                                                  ; internal argument 1: number of actual arguments
  call func$allBottles                                           ; jump to subroutine
  add rsp, 030h                                                  ; release shadow space and arguments (result in stack pointer)
  ; Line 44: assert(_blockCount == 0, 'memory leak');
  xor rdi, rdi                                                   ; zero value result of == (testing _blockCount variable and 0) to put the boolean in
  cmp qword ptr _blockCountValue, 000h                           ; values equal?
  sete dil                                                       ; put result in value result of == (testing _blockCount variable and 0)
  mov r12, 014h                                                  ; value result of == (testing _blockCount variable and 0) is a Boolean'20
  xor r13, r13                                                   ; zero type result of == (testing _blockCount variable and 0) to put the boolean in
  cmp qword ptr _blockCountType, 015h                            ; types equal?
  sete r13b                                                      ; put result in type result of == (testing _blockCount variable and 0)
  mov r14, 014h                                                  ; type result of == (testing _blockCount variable and 0) is a Boolean'20
  mov r15, rdi                                                   ; assign value of value result of == (testing _blockCount variable and 0) to value of == operator result
  and r15, r13                                                   ; && type temp and value temp
  mov r10, 014h                                                  ; == operator result is of type Boolean'20
  ; Call assert with 2 arguments
  mov rax, offset string$29                                      ; reading string for push
  push rax                                                       ; value of argument #2 (string)
  push 016h                                                      ; type of argument #2 (String'22)
  push r15                                                       ; value of argument #1 (== operator result)
  push r10                                                       ; type of argument #1
  lea rbx, qword ptr [rsp + 028h]                                ; load address of return value's value
  push rbx                                                       ; internal argument 6: pointer to return value slot's value
  lea rbx, qword ptr [rsp + 028h]                                ; load address of return value's type
  push rbx                                                       ; internal argument 5: pointer to return value slot's type
  sub rsp, 020h                                                  ; allocate shadow space
  mov r9, 000h                                                   ; internal argument 4: "this" pointer
  mov r8, 000h                                                   ; internal argument 3: "this" pointer type
  mov rdx, 000h                                                  ; internal argument 2: closure pointer
  mov rcx, 002h                                                  ; internal argument 1: number of actual arguments
  call func$assert                                               ; jump to subroutine
  add rsp, 050h                                                  ; release shadow space and arguments (result in stack pointer)
  ; Terminate application - call exit(0)
  ; Call exit with 1 arguments
  push 000h                                                      ; value of argument #1 (0 (integer))
  push 015h                                                      ; type of argument #1 (Integer'21)
  lea rsi, qword ptr [rsp + 018h]                                ; load address of return value's value
  push rsi                                                       ; internal argument 6: pointer to return value slot's value
  lea rsi, qword ptr [rsp + 018h]                                ; load address of return value's type
  push rsi                                                       ; internal argument 5: pointer to return value slot's type
  sub rsp, 020h                                                  ; allocate shadow space
  mov r9, 000h                                                   ; internal argument 4: "this" pointer
  mov r8, 000h                                                   ; internal argument 3: "this" pointer type
  mov rdx, 000h                                                  ; internal argument 2: closure pointer
  mov rcx, 001h                                                  ; internal argument 1: number of actual arguments
  call func$exit                                                 ; jump to subroutine
  add rsp, 040h                                                  ; release shadow space and arguments (result in stack pointer)
  ; Epilog
  add rsp, 018h                                                  ; free space for stack
  pop r14                                                        ; restore non-volatile registers
  pop r13                                                        ; restore non-volatile registers
  pop r12                                                        ; restore non-volatile registers
  pop rbp                                                        ; restore non-volatile registers
  pop rdi                                                        ; restore non-volatile registers
  pop rsi                                                        ; restore non-volatile registers
  pop rbx                                                        ; restore non-volatile registers
  pop r15                                                        ; restore non-volatile registers

  ; End of global scope
  ret                                                            ; exit application

; __print
func$__print:
  ; Prolog
  push r15                                                       ; save non-volatile registers
  push rbx                                                       ; save non-volatile registers
  push rsi                                                       ; save non-volatile registers
  push rdi                                                       ; save non-volatile registers
  push rbp                                                       ; save non-volatile registers
  push r12                                                       ; save non-volatile registers
  push r13                                                       ; save non-volatile registers
  push r14                                                       ; save non-volatile registers
  sub rsp, 020h                                                  ; allocate space for stack
  lea rbp, qword ptr [rsp + 060h]                                ; set up frame pointer
  ; Check parameter count
  cmp rcx, 001h                                                  ; compare parameter count of __print to 1 (integer)
  je func$__print$parameterCountCheck$continuation               ; check number of parameters is as expected
    ; Error handling block for parameter count
    ;  - print(parameterCountCheckFailureMessage)
    ; Call __print with 1 arguments
    mov r10, offset parameterCountCheckFailureMessage            ; reading parameterCountCheckFailureMessage for push
    push r10                                                     ; value of argument #1 (parameterCountCheckFailureMessage)
    push 016h                                                    ; type of argument #1 (String'22)
    lea rax, qword ptr [rsp + 020h]                              ; load address of return value's value
    push rax                                                     ; internal argument 6: pointer to return value slot's value
    lea rax, qword ptr [rsp + 020h]                              ; load address of return value's type
    push rax                                                     ; internal argument 5: pointer to return value slot's type
    sub rsp, 020h                                                ; allocate shadow space
    mov r9, 000h                                                 ; internal argument 4: "this" pointer
    mov r8, 000h                                                 ; internal argument 3: "this" pointer type
    mov rdx, 000h                                                ; internal argument 2: closure pointer
    mov qword ptr [rsp + 040h], rcx                              ; move parameter count of __print value out of rcx
    mov rcx, 001h                                                ; internal argument 1: number of actual arguments
    call func$__print                                            ; jump to subroutine
    add rsp, 040h                                                ; release shadow space and arguments (result in stack pointer)
    ;  - exit(1)
    ; Call exit with 1 arguments
    push 001h                                                    ; value of argument #1 (1 (integer))
    push 015h                                                    ; type of argument #1 (Integer'21)
    lea rbx, qword ptr [rsp + 020h]                              ; load address of return value's value
    push rbx                                                     ; internal argument 6: pointer to return value slot's value
    lea rbx, qword ptr [rsp + 020h]                              ; load address of return value's type
    push rbx                                                     ; internal argument 5: pointer to return value slot's type
    sub rsp, 020h                                                ; allocate shadow space
    mov r9, 000h                                                 ; internal argument 4: "this" pointer
    mov r8, 000h                                                 ; internal argument 3: "this" pointer type
    mov rdx, 000h                                                ; internal argument 2: closure pointer
    mov rcx, 001h                                                ; internal argument 1: number of actual arguments
    call func$exit                                               ; jump to subroutine
    add rsp, 040h                                                ; release shadow space and arguments (result in stack pointer)
    mov rcx, qword ptr [rsp + 000h]                              ; restoring slots to previous scope state
  func$__print$parameterCountCheck$continuation:                 ; end of parameter count check
  ; Check type of parameter 0, message to print to console (expecting String)
  mov rsi, qword ptr [rbp + 038h]                                ; move type of message to print to console to testByte
  mov rax, rsi                                                   ; move testByte to testByte
  mov rdi, 001h                                                  ; read operand of mul (type table width in bytes) 
  mul rdi                                                        ; adjust to the relative start of that type's entry in the type table
  add rax, 000h                                                  ; adjust to the byte containing the bit to check against (result in testByte)
  mov r12, offset typeTable                                      ; read second operand of + (type table pointer)
  add rax, r12                                                   ; finally offset all of that by the start of the type table itself (result in testByte)
  bt qword ptr [rax], 003h                                       ; check that message to print to console is String
  jc func$__print$messageToPrintToConsole$TypeMatch              ; skip next block if the type matches
    ; Error handling block for message to print to console
    ;  - print(parameterTypeCheckFailureMessage)
    ; Call __print with 1 arguments
    mov r13, offset parameterTypeCheckFailureMessage             ; reading parameterTypeCheckFailureMessage for push
    push r13                                                     ; value of argument #1 (parameterTypeCheckFailureMessage)
    push 016h                                                    ; type of argument #1 (String'22)
    lea r14, qword ptr [rsp + 020h]                              ; load address of return value's value
    push r14                                                     ; internal argument 6: pointer to return value slot's value
    lea r14, qword ptr [rsp + 020h]                              ; load address of return value's type
    push r14                                                     ; internal argument 5: pointer to return value slot's type
    sub rsp, 020h                                                ; allocate shadow space
    mov r9, 000h                                                 ; internal argument 4: "this" pointer
    mov r8, 000h                                                 ; internal argument 3: "this" pointer type
    mov rdx, 000h                                                ; internal argument 2: closure pointer
    mov qword ptr [rsp + 040h], rcx                              ; move parameter count of __print value out of rcx
    mov rcx, 001h                                                ; internal argument 1: number of actual arguments
    call func$__print                                            ; jump to subroutine
    add rsp, 040h                                                ; release shadow space and arguments (result in stack pointer)
    ;  - exit(1)
    ; Call exit with 1 arguments
    push 001h                                                    ; value of argument #1 (1 (integer))
    push 015h                                                    ; type of argument #1 (Integer'21)
    lea r15, qword ptr [rsp + 020h]                              ; load address of return value's value
    push r15                                                     ; internal argument 6: pointer to return value slot's value
    lea r15, qword ptr [rsp + 020h]                              ; load address of return value's type
    push r15                                                     ; internal argument 5: pointer to return value slot's type
    sub rsp, 020h                                                ; allocate shadow space
    mov r9, 000h                                                 ; internal argument 4: "this" pointer
    mov r8, 000h                                                 ; internal argument 3: "this" pointer type
    mov rdx, 000h                                                ; internal argument 2: closure pointer
    mov rcx, 001h                                                ; internal argument 1: number of actual arguments
    call func$exit                                               ; jump to subroutine
    add rsp, 040h                                                ; release shadow space and arguments (result in stack pointer)
    mov rcx, qword ptr [rsp + 000h]                              ; restoring slots to previous scope state
  func$__print$messageToPrintToConsole$TypeMatch:                ; after block
  ; Calling GetStdHandle
  sub rsp, 020h                                                  ; allocate shadow space
  mov qword ptr [rsp + 010h], rcx                                ; move parameter count of __print value out of rcx
  mov rcx, -00bh                                                 ; argument #1: STD_OUTPUT_HANDLE
  call GetStdHandle                                              ; handle returned in rax
  add rsp, 020h                                                  ; release shadow space (result in stack pointer)
  ; Calling WriteConsoleA
  push 000h                                                      ; argument #5: Reserved, must be NULL (lpReserved)
  sub rsp, 020h                                                  ; allocate shadow space
  lea r9, qword ptr [rsp + 030h]                                 ; argument #4: Number of characters written (lpNumberOfCharsWritten)
  mov r10, qword ptr [rbp + 040h]                                ; get message to print to console into register to dereference it
  mov r8, qword ptr [r10 + 008h]                                 ; argument #3: Length of buffer (nNumberOfCharsToWrite), from string structure
  mov rdx, qword ptr [rbp + 040h]                                ; assign value of message to print to console to value of x64 calling convention arg #2
  add rdx, 010h                                                  ; argument #2: Pointer to buffer to write (*lpBuffer) (result in x64 calling convention arg #2)
  mov rcx, rax                                                   ; argument #1: Handle from GetStdHandle (hConsoleOutput)
  call WriteConsoleA                                             ; returns boolean representing success in rax
  add rsp, 028h                                                  ; release shadow space (result in stack pointer)
  ; Implicit return from __print
  mov rbx, qword ptr [rbp + 030h]                                ; get pointer to return value of __print into register to dereference it
  mov qword ptr [rbx], 000h                                      ; __print return value
  mov rsi, qword ptr [rbp + 028h]                                ; get pointer to return value type of __print into register to dereference it
  mov qword ptr [rsi], 013h                                      ; type of __print return value (Null'19)
  jmp func$__print$epilog                                        ; return
  func$__print$epilog: 
  mov rax, qword ptr [rbp + 030h]                                ; report address of return value
  ; Epilog
  add rsp, 020h                                                  ; free space for stack
  pop r14                                                        ; restore non-volatile registers
  pop r13                                                        ; restore non-volatile registers
  pop r12                                                        ; restore non-volatile registers
  pop rbp                                                        ; restore non-volatile registers
  pop rdi                                                        ; restore non-volatile registers
  pop rsi                                                        ; restore non-volatile registers
  pop rbx                                                        ; restore non-volatile registers
  pop r15                                                        ; restore non-volatile registers
  ret                                                            ; return from subroutine

; exit
func$exit:
  ; Prolog
  push r15                                                       ; save non-volatile registers
  push rbx                                                       ; save non-volatile registers
  push rsi                                                       ; save non-volatile registers
  push rdi                                                       ; save non-volatile registers
  push rbp                                                       ; save non-volatile registers
  push r12                                                       ; save non-volatile registers
  push r13                                                       ; save non-volatile registers
  push r14                                                       ; save non-volatile registers
  sub rsp, 020h                                                  ; allocate space for stack
  lea rbp, qword ptr [rsp + 060h]                                ; set up frame pointer
  ; Check parameter count
  cmp rcx, 001h                                                  ; compare parameter count of exit to 1 (integer)
  je func$exit$parameterCountCheck$continuation                  ; check number of parameters is as expected
    ; Error handling block for parameter count
    ;  - print(parameterCountCheckFailureMessage)
    ; Call __print with 1 arguments
    mov r10, offset parameterCountCheckFailureMessage            ; reading parameterCountCheckFailureMessage for push
    push r10                                                     ; value of argument #1 (parameterCountCheckFailureMessage)
    push 016h                                                    ; type of argument #1 (String'22)
    lea rax, qword ptr [rsp + 020h]                              ; load address of return value's value
    push rax                                                     ; internal argument 6: pointer to return value slot's value
    lea rax, qword ptr [rsp + 020h]                              ; load address of return value's type
    push rax                                                     ; internal argument 5: pointer to return value slot's type
    sub rsp, 020h                                                ; allocate shadow space
    mov r9, 000h                                                 ; internal argument 4: "this" pointer
    mov r8, 000h                                                 ; internal argument 3: "this" pointer type
    mov rdx, 000h                                                ; internal argument 2: closure pointer
    mov qword ptr [rsp + 040h], rcx                              ; move parameter count of exit value out of rcx
    mov rcx, 001h                                                ; internal argument 1: number of actual arguments
    call func$__print                                            ; jump to subroutine
    add rsp, 040h                                                ; release shadow space and arguments (result in stack pointer)
    ;  - exit(1)
    ; Call exit with 1 arguments
    push 001h                                                    ; value of argument #1 (1 (integer))
    push 015h                                                    ; type of argument #1 (Integer'21)
    lea rbx, qword ptr [rsp + 020h]                              ; load address of return value's value
    push rbx                                                     ; internal argument 6: pointer to return value slot's value
    lea rbx, qword ptr [rsp + 020h]                              ; load address of return value's type
    push rbx                                                     ; internal argument 5: pointer to return value slot's type
    sub rsp, 020h                                                ; allocate shadow space
    mov r9, 000h                                                 ; internal argument 4: "this" pointer
    mov r8, 000h                                                 ; internal argument 3: "this" pointer type
    mov rdx, 000h                                                ; internal argument 2: closure pointer
    mov rcx, 001h                                                ; internal argument 1: number of actual arguments
    call func$exit                                               ; jump to subroutine
    add rsp, 040h                                                ; release shadow space and arguments (result in stack pointer)
    mov rcx, qword ptr [rsp + 000h]                              ; restoring slots to previous scope state
  func$exit$parameterCountCheck$continuation:                    ; end of parameter count check
  ; Check type of parameter 0, exit code parameter (expecting Integer)
  mov rsi, qword ptr [rbp + 038h]                                ; move type of exit code parameter to testByte
  mov rax, rsi                                                   ; move testByte to testByte
  mov rdi, 001h                                                  ; read operand of mul (type table width in bytes) 
  mul rdi                                                        ; adjust to the relative start of that type's entry in the type table
  add rax, 000h                                                  ; adjust to the byte containing the bit to check against (result in testByte)
  mov r12, offset typeTable                                      ; read second operand of + (type table pointer)
  add rax, r12                                                   ; finally offset all of that by the start of the type table itself (result in testByte)
  bt qword ptr [rax], 002h                                       ; check that exit code parameter is Integer
  jc func$exit$exitCodeParameter$TypeMatch                       ; skip next block if the type matches
    ; Error handling block for exit code parameter
    ;  - print(parameterTypeCheckFailureMessage)
    ; Call __print with 1 arguments
    mov r13, offset parameterTypeCheckFailureMessage             ; reading parameterTypeCheckFailureMessage for push
    push r13                                                     ; value of argument #1 (parameterTypeCheckFailureMessage)
    push 016h                                                    ; type of argument #1 (String'22)
    lea r14, qword ptr [rsp + 020h]                              ; load address of return value's value
    push r14                                                     ; internal argument 6: pointer to return value slot's value
    lea r14, qword ptr [rsp + 020h]                              ; load address of return value's type
    push r14                                                     ; internal argument 5: pointer to return value slot's type
    sub rsp, 020h                                                ; allocate shadow space
    mov r9, 000h                                                 ; internal argument 4: "this" pointer
    mov r8, 000h                                                 ; internal argument 3: "this" pointer type
    mov rdx, 000h                                                ; internal argument 2: closure pointer
    mov qword ptr [rsp + 040h], rcx                              ; move parameter count of exit value out of rcx
    mov rcx, 001h                                                ; internal argument 1: number of actual arguments
    call func$__print                                            ; jump to subroutine
    add rsp, 040h                                                ; release shadow space and arguments (result in stack pointer)
    ;  - exit(1)
    ; Call exit with 1 arguments
    push 001h                                                    ; value of argument #1 (1 (integer))
    push 015h                                                    ; type of argument #1 (Integer'21)
    lea r15, qword ptr [rsp + 020h]                              ; load address of return value's value
    push r15                                                     ; internal argument 6: pointer to return value slot's value
    lea r15, qword ptr [rsp + 020h]                              ; load address of return value's type
    push r15                                                     ; internal argument 5: pointer to return value slot's type
    sub rsp, 020h                                                ; allocate shadow space
    mov r9, 000h                                                 ; internal argument 4: "this" pointer
    mov r8, 000h                                                 ; internal argument 3: "this" pointer type
    mov rdx, 000h                                                ; internal argument 2: closure pointer
    mov rcx, 001h                                                ; internal argument 1: number of actual arguments
    call func$exit                                               ; jump to subroutine
    add rsp, 040h                                                ; release shadow space and arguments (result in stack pointer)
    mov rcx, qword ptr [rsp + 000h]                              ; restoring slots to previous scope state
  func$exit$exitCodeParameter$TypeMatch:                         ; after block
  ; Calling ExitProcess
  sub rsp, 020h                                                  ; allocate shadow space
  mov qword ptr [rsp + 010h], rcx                                ; move parameter count of exit value out of rcx
  mov rcx, qword ptr [rbp + 040h]                                ; exit code
  call ExitProcess                                               ; process should terminate at this point
  add rsp, 020h                                                  ; release shadow space, just in case (result in stack pointer)
  ; Implicit return from exit
  mov r10, qword ptr [rbp + 030h]                                ; get pointer to return value of exit into register to dereference it
  mov qword ptr [r10], 000h                                      ; exit return value
  mov rbx, qword ptr [rbp + 028h]                                ; get pointer to return value type of exit into register to dereference it
  mov qword ptr [rbx], 013h                                      ; type of exit return value (Null'19)
  jmp func$exit$epilog                                           ; return
  func$exit$epilog: 
  mov rax, qword ptr [rbp + 030h]                                ; report address of return value
  ; Epilog
  add rsp, 020h                                                  ; free space for stack
  pop r14                                                        ; restore non-volatile registers
  pop r13                                                        ; restore non-volatile registers
  pop r12                                                        ; restore non-volatile registers
  pop rbp                                                        ; restore non-volatile registers
  pop rdi                                                        ; restore non-volatile registers
  pop rsi                                                        ; restore non-volatile registers
  pop rbx                                                        ; restore non-volatile registers
  pop r15                                                        ; restore non-volatile registers
  ret                                                            ; return from subroutine

; len
func$len:
  ; Prolog
  push r15                                                       ; save non-volatile registers
  push rbx                                                       ; save non-volatile registers
  push rsi                                                       ; save non-volatile registers
  push rdi                                                       ; save non-volatile registers
  push rbp                                                       ; save non-volatile registers
  push r12                                                       ; save non-volatile registers
  push r13                                                       ; save non-volatile registers
  push r14                                                       ; save non-volatile registers
  sub rsp, 020h                                                  ; allocate space for stack
  lea rbp, qword ptr [rsp + 060h]                                ; set up frame pointer
  ; Check parameter count
  cmp rcx, 001h                                                  ; compare parameter count of len to 1 (integer)
  je func$len$parameterCountCheck$continuation                   ; check number of parameters is as expected
    ; Error handling block for parameter count
    ;  - print(parameterCountCheckFailureMessage)
    ; Call __print with 1 arguments
    mov r10, offset parameterCountCheckFailureMessage            ; reading parameterCountCheckFailureMessage for push
    push r10                                                     ; value of argument #1 (parameterCountCheckFailureMessage)
    push 016h                                                    ; type of argument #1 (String'22)
    lea rax, qword ptr [rsp + 020h]                              ; load address of return value's value
    push rax                                                     ; internal argument 6: pointer to return value slot's value
    lea rax, qword ptr [rsp + 020h]                              ; load address of return value's type
    push rax                                                     ; internal argument 5: pointer to return value slot's type
    sub rsp, 020h                                                ; allocate shadow space
    mov r9, 000h                                                 ; internal argument 4: "this" pointer
    mov r8, 000h                                                 ; internal argument 3: "this" pointer type
    mov rdx, 000h                                                ; internal argument 2: closure pointer
    mov qword ptr [rsp + 040h], rcx                              ; move parameter count of len value out of rcx
    mov rcx, 001h                                                ; internal argument 1: number of actual arguments
    call func$__print                                            ; jump to subroutine
    add rsp, 040h                                                ; release shadow space and arguments (result in stack pointer)
    ;  - exit(1)
    ; Call exit with 1 arguments
    push 001h                                                    ; value of argument #1 (1 (integer))
    push 015h                                                    ; type of argument #1 (Integer'21)
    lea rbx, qword ptr [rsp + 020h]                              ; load address of return value's value
    push rbx                                                     ; internal argument 6: pointer to return value slot's value
    lea rbx, qword ptr [rsp + 020h]                              ; load address of return value's type
    push rbx                                                     ; internal argument 5: pointer to return value slot's type
    sub rsp, 020h                                                ; allocate shadow space
    mov r9, 000h                                                 ; internal argument 4: "this" pointer
    mov r8, 000h                                                 ; internal argument 3: "this" pointer type
    mov rdx, 000h                                                ; internal argument 2: closure pointer
    mov rcx, 001h                                                ; internal argument 1: number of actual arguments
    call func$exit                                               ; jump to subroutine
    add rsp, 040h                                                ; release shadow space and arguments (result in stack pointer)
    mov rcx, qword ptr [rsp + 000h]                              ; restoring slots to previous scope state
  func$len$parameterCountCheck$continuation:                     ; end of parameter count check
  ; Check type of parameter 0, list (expecting WhateverReadOnlyList)
  mov rsi, qword ptr [rbp + 038h]                                ; move type of list to testByte
  mov rax, rsi                                                   ; move testByte to testByte
  mov rdi, 001h                                                  ; read operand of mul (type table width in bytes) 
  mul rdi                                                        ; adjust to the relative start of that type's entry in the type table
  add rax, 000h                                                  ; adjust to the byte containing the bit to check against (result in testByte)
  mov r12, offset typeTable                                      ; read second operand of + (type table pointer)
  add rax, r12                                                   ; finally offset all of that by the start of the type table itself (result in testByte)
  bt qword ptr [rax], 005h                                       ; check that list is WhateverReadOnlyList
  jc func$len$list$TypeMatch                                     ; skip next block if the type matches
    ; Error handling block for list
    ;  - print(parameterTypeCheckFailureMessage)
    ; Call __print with 1 arguments
    mov r13, offset parameterTypeCheckFailureMessage             ; reading parameterTypeCheckFailureMessage for push
    push r13                                                     ; value of argument #1 (parameterTypeCheckFailureMessage)
    push 016h                                                    ; type of argument #1 (String'22)
    lea r14, qword ptr [rsp + 020h]                              ; load address of return value's value
    push r14                                                     ; internal argument 6: pointer to return value slot's value
    lea r14, qword ptr [rsp + 020h]                              ; load address of return value's type
    push r14                                                     ; internal argument 5: pointer to return value slot's type
    sub rsp, 020h                                                ; allocate shadow space
    mov r9, 000h                                                 ; internal argument 4: "this" pointer
    mov r8, 000h                                                 ; internal argument 3: "this" pointer type
    mov rdx, 000h                                                ; internal argument 2: closure pointer
    mov qword ptr [rsp + 040h], rcx                              ; move parameter count of len value out of rcx
    mov rcx, 001h                                                ; internal argument 1: number of actual arguments
    call func$__print                                            ; jump to subroutine
    add rsp, 040h                                                ; release shadow space and arguments (result in stack pointer)
    ;  - exit(1)
    ; Call exit with 1 arguments
    push 001h                                                    ; value of argument #1 (1 (integer))
    push 015h                                                    ; type of argument #1 (Integer'21)
    lea r15, qword ptr [rsp + 020h]                              ; load address of return value's value
    push r15                                                     ; internal argument 6: pointer to return value slot's value
    lea r15, qword ptr [rsp + 020h]                              ; load address of return value's type
    push r15                                                     ; internal argument 5: pointer to return value slot's type
    sub rsp, 020h                                                ; allocate shadow space
    mov r9, 000h                                                 ; internal argument 4: "this" pointer
    mov r8, 000h                                                 ; internal argument 3: "this" pointer type
    mov rdx, 000h                                                ; internal argument 2: closure pointer
    mov rcx, 001h                                                ; internal argument 1: number of actual arguments
    call func$exit                                               ; jump to subroutine
    add rsp, 040h                                                ; release shadow space and arguments (result in stack pointer)
    mov rcx, qword ptr [rsp + 000h]                              ; restoring slots to previous scope state
  func$len$list$TypeMatch:                                       ; after block
  ; TODO: implement 'len' function
  ; Implicit return from len
  mov r10, 013h                                                  ; move type of null to testByte
  mov rax, r10                                                   ; move testByte to testByte
  mov rbx, 001h                                                  ; read operand of mul (type table width in bytes) 
  mul rbx                                                        ; adjust to the relative start of that type's entry in the type table
  add rax, 000h                                                  ; adjust to the byte containing the bit to check against (result in testByte)
  mov rsi, offset typeTable                                      ; read second operand of + (type table pointer)
  add rax, rsi                                                   ; finally offset all of that by the start of the type table itself (result in testByte)
  bt qword ptr [rax], 002h                                       ; check that len return value is Integer
  jc func$len$lenReturnValue$TypeMatch                           ; skip next block if the type matches
    ; Error handling block for len return value
    ;  - print(returnValueTypeCheckFailureMessage)
    ; Call __print with 1 arguments
    mov rdi, offset returnValueTypeCheckFailureMessage           ; reading returnValueTypeCheckFailureMessage for push
    push rdi                                                     ; value of argument #1 (returnValueTypeCheckFailureMessage)
    push 016h                                                    ; type of argument #1 (String'22)
    lea r12, qword ptr [rsp + 020h]                              ; load address of return value's value
    push r12                                                     ; internal argument 6: pointer to return value slot's value
    lea r12, qword ptr [rsp + 020h]                              ; load address of return value's type
    push r12                                                     ; internal argument 5: pointer to return value slot's type
    sub rsp, 020h                                                ; allocate shadow space
    mov r9, 000h                                                 ; internal argument 4: "this" pointer
    mov r8, 000h                                                 ; internal argument 3: "this" pointer type
    mov rdx, 000h                                                ; internal argument 2: closure pointer
    mov qword ptr [rsp + 040h], rcx                              ; move parameter count of len value out of rcx
    mov rcx, 001h                                                ; internal argument 1: number of actual arguments
    call func$__print                                            ; jump to subroutine
    add rsp, 040h                                                ; release shadow space and arguments (result in stack pointer)
    ;  - exit(1)
    ; Call exit with 1 arguments
    push 001h                                                    ; value of argument #1 (1 (integer))
    push 015h                                                    ; type of argument #1 (Integer'21)
    lea r13, qword ptr [rsp + 020h]                              ; load address of return value's value
    push r13                                                     ; internal argument 6: pointer to return value slot's value
    lea r13, qword ptr [rsp + 020h]                              ; load address of return value's type
    push r13                                                     ; internal argument 5: pointer to return value slot's type
    sub rsp, 020h                                                ; allocate shadow space
    mov r9, 000h                                                 ; internal argument 4: "this" pointer
    mov r8, 000h                                                 ; internal argument 3: "this" pointer type
    mov rdx, 000h                                                ; internal argument 2: closure pointer
    mov rcx, 001h                                                ; internal argument 1: number of actual arguments
    call func$exit                                               ; jump to subroutine
    add rsp, 040h                                                ; release shadow space and arguments (result in stack pointer)
    mov rcx, qword ptr [rsp + 000h]                              ; restoring slots to previous scope state
  func$len$lenReturnValue$TypeMatch:                             ; after block
  mov r14, qword ptr [rbp + 030h]                                ; get pointer to return value of len into register to dereference it
  mov qword ptr [r14], 000h                                      ; len return value
  mov r15, qword ptr [rbp + 028h]                                ; get pointer to return value type of len into register to dereference it
  mov qword ptr [r15], 013h                                      ; type of len return value (Null'19)
  jmp func$len$epilog                                            ; return
  func$len$epilog: 
  mov rax, qword ptr [rbp + 030h]                                ; report address of return value
  ; Epilog
  add rsp, 020h                                                  ; free space for stack
  pop r14                                                        ; restore non-volatile registers
  pop r13                                                        ; restore non-volatile registers
  pop r12                                                        ; restore non-volatile registers
  pop rbp                                                        ; restore non-volatile registers
  pop rdi                                                        ; restore non-volatile registers
  pop rsi                                                        ; restore non-volatile registers
  pop rbx                                                        ; restore non-volatile registers
  pop r15                                                        ; restore non-volatile registers
  ret                                                            ; return from subroutine

; __debugger
func$__debugger:
  ; Prolog
  push rbx                                                       ; save non-volatile registers
  push rsi                                                       ; save non-volatile registers
  push rdi                                                       ; save non-volatile registers
  push rbp                                                       ; save non-volatile registers
  sub rsp, 020h                                                  ; allocate space for stack
  lea rbp, qword ptr [rsp + 040h]                                ; set up frame pointer
  ; Check parameter count
  cmp rcx, 000h                                                  ; compare parameter count of __debugger to 0 (integer)
  je func$__debugger$parameterCountCheck$continuation            ; check number of parameters is as expected
    ; Error handling block for parameter count
    ;  - print(parameterCountCheckFailureMessage)
    ; Call __print with 1 arguments
    mov r10, offset parameterCountCheckFailureMessage            ; reading parameterCountCheckFailureMessage for push
    push r10                                                     ; value of argument #1 (parameterCountCheckFailureMessage)
    push 016h                                                    ; type of argument #1 (String'22)
    lea rax, qword ptr [rsp + 020h]                              ; load address of return value's value
    push rax                                                     ; internal argument 6: pointer to return value slot's value
    lea rax, qword ptr [rsp + 020h]                              ; load address of return value's type
    push rax                                                     ; internal argument 5: pointer to return value slot's type
    sub rsp, 020h                                                ; allocate shadow space
    mov r9, 000h                                                 ; internal argument 4: "this" pointer
    mov r8, 000h                                                 ; internal argument 3: "this" pointer type
    mov rdx, 000h                                                ; internal argument 2: closure pointer
    mov qword ptr [rsp + 040h], rcx                              ; move parameter count of __debugger value out of rcx
    mov rcx, 001h                                                ; internal argument 1: number of actual arguments
    call func$__print                                            ; jump to subroutine
    add rsp, 040h                                                ; release shadow space and arguments (result in stack pointer)
    ;  - exit(1)
    ; Call exit with 1 arguments
    push 001h                                                    ; value of argument #1 (1 (integer))
    push 015h                                                    ; type of argument #1 (Integer'21)
    lea rbx, qword ptr [rsp + 020h]                              ; load address of return value's value
    push rbx                                                     ; internal argument 6: pointer to return value slot's value
    lea rbx, qword ptr [rsp + 020h]                              ; load address of return value's type
    push rbx                                                     ; internal argument 5: pointer to return value slot's type
    sub rsp, 020h                                                ; allocate shadow space
    mov r9, 000h                                                 ; internal argument 4: "this" pointer
    mov r8, 000h                                                 ; internal argument 3: "this" pointer type
    mov rdx, 000h                                                ; internal argument 2: closure pointer
    mov rcx, 001h                                                ; internal argument 1: number of actual arguments
    call func$exit                                               ; jump to subroutine
    add rsp, 040h                                                ; release shadow space and arguments (result in stack pointer)
    mov rcx, qword ptr [rsp + 000h]                              ; restoring slots to previous scope state
  func$__debugger$parameterCountCheck$continuation:              ; end of parameter count check
  ; TODO: implement "debugger" function
  ; Implicit return from __debugger
  mov rsi, qword ptr [rbp + 030h]                                ; get pointer to return value of __debugger into register to dereference it
  mov qword ptr [rsi], 000h                                      ; __debugger return value
  mov rdi, qword ptr [rbp + 028h]                                ; get pointer to return value type of __debugger into register to dereference it
  mov qword ptr [rdi], 013h                                      ; type of __debugger return value (Null'19)
  jmp func$__debugger$epilog                                     ; return
  func$__debugger$epilog: 
  mov rax, qword ptr [rbp + 030h]                                ; report address of return value
  ; Epilog
  add rsp, 020h                                                  ; free space for stack
  pop rbp                                                        ; restore non-volatile registers
  pop rdi                                                        ; restore non-volatile registers
  pop rsi                                                        ; restore non-volatile registers
  pop rbx                                                        ; restore non-volatile registers
  ret                                                            ; return from subroutine

; __readFromAddress
func$__readFromAddress:
  ; Prolog
  push r15                                                       ; save non-volatile registers
  push rbx                                                       ; save non-volatile registers
  push rsi                                                       ; save non-volatile registers
  push rdi                                                       ; save non-volatile registers
  push rbp                                                       ; save non-volatile registers
  push r12                                                       ; save non-volatile registers
  push r13                                                       ; save non-volatile registers
  push r14                                                       ; save non-volatile registers
  sub rsp, 020h                                                  ; allocate space for stack
  lea rbp, qword ptr [rsp + 060h]                                ; set up frame pointer
  ; Check parameter count
  cmp rcx, 001h                                                  ; compare parameter count of __readFromAddress to 1 (integer)
  je func$__readFromAddress$parameterCountCheck$continuation     ; check number of parameters is as expected
    ; Error handling block for parameter count
    ;  - print(parameterCountCheckFailureMessage)
    ; Call __print with 1 arguments
    mov r10, offset parameterCountCheckFailureMessage            ; reading parameterCountCheckFailureMessage for push
    push r10                                                     ; value of argument #1 (parameterCountCheckFailureMessage)
    push 016h                                                    ; type of argument #1 (String'22)
    lea rax, qword ptr [rsp + 020h]                              ; load address of return value's value
    push rax                                                     ; internal argument 6: pointer to return value slot's value
    lea rax, qword ptr [rsp + 020h]                              ; load address of return value's type
    push rax                                                     ; internal argument 5: pointer to return value slot's type
    sub rsp, 020h                                                ; allocate shadow space
    mov r9, 000h                                                 ; internal argument 4: "this" pointer
    mov r8, 000h                                                 ; internal argument 3: "this" pointer type
    mov rdx, 000h                                                ; internal argument 2: closure pointer
    mov qword ptr [rsp + 040h], rcx                              ; move parameter count of __readFromAddress value out of rcx
    mov rcx, 001h                                                ; internal argument 1: number of actual arguments
    call func$__print                                            ; jump to subroutine
    add rsp, 040h                                                ; release shadow space and arguments (result in stack pointer)
    ;  - exit(1)
    ; Call exit with 1 arguments
    push 001h                                                    ; value of argument #1 (1 (integer))
    push 015h                                                    ; type of argument #1 (Integer'21)
    lea rbx, qword ptr [rsp + 020h]                              ; load address of return value's value
    push rbx                                                     ; internal argument 6: pointer to return value slot's value
    lea rbx, qword ptr [rsp + 020h]                              ; load address of return value's type
    push rbx                                                     ; internal argument 5: pointer to return value slot's type
    sub rsp, 020h                                                ; allocate shadow space
    mov r9, 000h                                                 ; internal argument 4: "this" pointer
    mov r8, 000h                                                 ; internal argument 3: "this" pointer type
    mov rdx, 000h                                                ; internal argument 2: closure pointer
    mov rcx, 001h                                                ; internal argument 1: number of actual arguments
    call func$exit                                               ; jump to subroutine
    add rsp, 040h                                                ; release shadow space and arguments (result in stack pointer)
    mov rcx, qword ptr [rsp + 000h]                              ; restoring slots to previous scope state
  func$__readFromAddress$parameterCountCheck$continuation:       ; end of parameter count check
  ; Check type of parameter 0, address (expecting Integer)
  mov rsi, qword ptr [rbp + 038h]                                ; move type of address to testByte
  mov rax, rsi                                                   ; move testByte to testByte
  mov rdi, 001h                                                  ; read operand of mul (type table width in bytes) 
  mul rdi                                                        ; adjust to the relative start of that type's entry in the type table
  add rax, 000h                                                  ; adjust to the byte containing the bit to check against (result in testByte)
  mov r12, offset typeTable                                      ; read second operand of + (type table pointer)
  add rax, r12                                                   ; finally offset all of that by the start of the type table itself (result in testByte)
  bt qword ptr [rax], 002h                                       ; check that address is Integer
  jc func$__readFromAddress$address$TypeMatch                    ; skip next block if the type matches
    ; Error handling block for address
    ;  - print(parameterTypeCheckFailureMessage)
    ; Call __print with 1 arguments
    mov r13, offset parameterTypeCheckFailureMessage             ; reading parameterTypeCheckFailureMessage for push
    push r13                                                     ; value of argument #1 (parameterTypeCheckFailureMessage)
    push 016h                                                    ; type of argument #1 (String'22)
    lea r14, qword ptr [rsp + 020h]                              ; load address of return value's value
    push r14                                                     ; internal argument 6: pointer to return value slot's value
    lea r14, qword ptr [rsp + 020h]                              ; load address of return value's type
    push r14                                                     ; internal argument 5: pointer to return value slot's type
    sub rsp, 020h                                                ; allocate shadow space
    mov r9, 000h                                                 ; internal argument 4: "this" pointer
    mov r8, 000h                                                 ; internal argument 3: "this" pointer type
    mov rdx, 000h                                                ; internal argument 2: closure pointer
    mov qword ptr [rsp + 040h], rcx                              ; move parameter count of __readFromAddress value out of rcx
    mov rcx, 001h                                                ; internal argument 1: number of actual arguments
    call func$__print                                            ; jump to subroutine
    add rsp, 040h                                                ; release shadow space and arguments (result in stack pointer)
    ;  - exit(1)
    ; Call exit with 1 arguments
    push 001h                                                    ; value of argument #1 (1 (integer))
    push 015h                                                    ; type of argument #1 (Integer'21)
    lea r15, qword ptr [rsp + 020h]                              ; load address of return value's value
    push r15                                                     ; internal argument 6: pointer to return value slot's value
    lea r15, qword ptr [rsp + 020h]                              ; load address of return value's type
    push r15                                                     ; internal argument 5: pointer to return value slot's type
    sub rsp, 020h                                                ; allocate shadow space
    mov r9, 000h                                                 ; internal argument 4: "this" pointer
    mov r8, 000h                                                 ; internal argument 3: "this" pointer type
    mov rdx, 000h                                                ; internal argument 2: closure pointer
    mov rcx, 001h                                                ; internal argument 1: number of actual arguments
    call func$exit                                               ; jump to subroutine
    add rsp, 040h                                                ; release shadow space and arguments (result in stack pointer)
    mov rcx, qword ptr [rsp + 000h]                              ; restoring slots to previous scope state
  func$__readFromAddress$address$TypeMatch:                      ; after block
  ; Implicit return from __readFromAddress
  mov r10, 013h                                                  ; move type of null to testByte
  mov rax, r10                                                   ; move testByte to testByte
  mov rbx, 001h                                                  ; read operand of mul (type table width in bytes) 
  mul rbx                                                        ; adjust to the relative start of that type's entry in the type table
  add rax, 000h                                                  ; adjust to the byte containing the bit to check against (result in testByte)
  mov rsi, offset typeTable                                      ; read second operand of + (type table pointer)
  add rax, rsi                                                   ; finally offset all of that by the start of the type table itself (result in testByte)
  bt qword ptr [rax], 002h                                       ; check that __readFromAddress return value is Integer
  jc func$__readFromAddress$ReadfromaddressReturnValue$TypeMatch ; skip next block if the type matches
    ; Error handling block for __readFromAddress return value
    ;  - print(returnValueTypeCheckFailureMessage)
    ; Call __print with 1 arguments
    mov rdi, offset returnValueTypeCheckFailureMessage           ; reading returnValueTypeCheckFailureMessage for push
    push rdi                                                     ; value of argument #1 (returnValueTypeCheckFailureMessage)
    push 016h                                                    ; type of argument #1 (String'22)
    lea r12, qword ptr [rsp + 020h]                              ; load address of return value's value
    push r12                                                     ; internal argument 6: pointer to return value slot's value
    lea r12, qword ptr [rsp + 020h]                              ; load address of return value's type
    push r12                                                     ; internal argument 5: pointer to return value slot's type
    sub rsp, 020h                                                ; allocate shadow space
    mov r9, 000h                                                 ; internal argument 4: "this" pointer
    mov r8, 000h                                                 ; internal argument 3: "this" pointer type
    mov rdx, 000h                                                ; internal argument 2: closure pointer
    mov qword ptr [rsp + 040h], rcx                              ; move parameter count of __readFromAddress value out of rcx
    mov rcx, 001h                                                ; internal argument 1: number of actual arguments
    call func$__print                                            ; jump to subroutine
    add rsp, 040h                                                ; release shadow space and arguments (result in stack pointer)
    ;  - exit(1)
    ; Call exit with 1 arguments
    push 001h                                                    ; value of argument #1 (1 (integer))
    push 015h                                                    ; type of argument #1 (Integer'21)
    lea r13, qword ptr [rsp + 020h]                              ; load address of return value's value
    push r13                                                     ; internal argument 6: pointer to return value slot's value
    lea r13, qword ptr [rsp + 020h]                              ; load address of return value's type
    push r13                                                     ; internal argument 5: pointer to return value slot's type
    sub rsp, 020h                                                ; allocate shadow space
    mov r9, 000h                                                 ; internal argument 4: "this" pointer
    mov r8, 000h                                                 ; internal argument 3: "this" pointer type
    mov rdx, 000h                                                ; internal argument 2: closure pointer
    mov rcx, 001h                                                ; internal argument 1: number of actual arguments
    call func$exit                                               ; jump to subroutine
    add rsp, 040h                                                ; release shadow space and arguments (result in stack pointer)
    mov rcx, qword ptr [rsp + 000h]                              ; restoring slots to previous scope state
  func$__readFromAddress$ReadfromaddressReturnValue$TypeMatch:   ; after block
  mov r14, qword ptr [rbp + 030h]                                ; get pointer to return value of __readFromAddress into register to dereference it
  mov qword ptr [r14], 000h                                      ; __readFromAddress return value
  mov r15, qword ptr [rbp + 028h]                                ; get pointer to return value type of __readFromAddress into register to dereference it
  mov qword ptr [r15], 013h                                      ; type of __readFromAddress return value (Null'19)
  jmp func$__readFromAddress$epilog                              ; return
  func$__readFromAddress$epilog: 
  mov rax, qword ptr [rbp + 030h]                                ; report address of return value
  ; Epilog
  add rsp, 020h                                                  ; free space for stack
  pop r14                                                        ; restore non-volatile registers
  pop r13                                                        ; restore non-volatile registers
  pop r12                                                        ; restore non-volatile registers
  pop rbp                                                        ; restore non-volatile registers
  pop rdi                                                        ; restore non-volatile registers
  pop rsi                                                        ; restore non-volatile registers
  pop rbx                                                        ; restore non-volatile registers
  pop r15                                                        ; restore non-volatile registers
  ret                                                            ; return from subroutine

; __writeToAddress
func$__writeToAddress:
  ; Prolog
  push r15                                                       ; save non-volatile registers
  push rbx                                                       ; save non-volatile registers
  push rsi                                                       ; save non-volatile registers
  push rdi                                                       ; save non-volatile registers
  push rbp                                                       ; save non-volatile registers
  push r12                                                       ; save non-volatile registers
  push r13                                                       ; save non-volatile registers
  push r14                                                       ; save non-volatile registers
  sub rsp, 020h                                                  ; allocate space for stack
  lea rbp, qword ptr [rsp + 060h]                                ; set up frame pointer
  ; Check parameter count
  cmp rcx, 002h                                                  ; compare parameter count of __writeToAddress to 2 (integer)
  je func$__writeToAddress$parameterCountCheck$continuation      ; check number of parameters is as expected
    ; Error handling block for parameter count
    ;  - print(parameterCountCheckFailureMessage)
    ; Call __print with 1 arguments
    mov r10, offset parameterCountCheckFailureMessage            ; reading parameterCountCheckFailureMessage for push
    push r10                                                     ; value of argument #1 (parameterCountCheckFailureMessage)
    push 016h                                                    ; type of argument #1 (String'22)
    lea rax, qword ptr [rsp + 020h]                              ; load address of return value's value
    push rax                                                     ; internal argument 6: pointer to return value slot's value
    lea rax, qword ptr [rsp + 020h]                              ; load address of return value's type
    push rax                                                     ; internal argument 5: pointer to return value slot's type
    sub rsp, 020h                                                ; allocate shadow space
    mov r9, 000h                                                 ; internal argument 4: "this" pointer
    mov r8, 000h                                                 ; internal argument 3: "this" pointer type
    mov rdx, 000h                                                ; internal argument 2: closure pointer
    mov qword ptr [rsp + 040h], rcx                              ; move parameter count of __writeToAddress value out of rcx
    mov rcx, 001h                                                ; internal argument 1: number of actual arguments
    call func$__print                                            ; jump to subroutine
    add rsp, 040h                                                ; release shadow space and arguments (result in stack pointer)
    ;  - exit(1)
    ; Call exit with 1 arguments
    push 001h                                                    ; value of argument #1 (1 (integer))
    push 015h                                                    ; type of argument #1 (Integer'21)
    lea rbx, qword ptr [rsp + 020h]                              ; load address of return value's value
    push rbx                                                     ; internal argument 6: pointer to return value slot's value
    lea rbx, qword ptr [rsp + 020h]                              ; load address of return value's type
    push rbx                                                     ; internal argument 5: pointer to return value slot's type
    sub rsp, 020h                                                ; allocate shadow space
    mov r9, 000h                                                 ; internal argument 4: "this" pointer
    mov r8, 000h                                                 ; internal argument 3: "this" pointer type
    mov rdx, 000h                                                ; internal argument 2: closure pointer
    mov rcx, 001h                                                ; internal argument 1: number of actual arguments
    call func$exit                                               ; jump to subroutine
    add rsp, 040h                                                ; release shadow space and arguments (result in stack pointer)
    mov rcx, qword ptr [rsp + 000h]                              ; restoring slots to previous scope state
  func$__writeToAddress$parameterCountCheck$continuation:        ; end of parameter count check
  ; Check type of parameter 0, address (expecting Integer)
  mov rsi, qword ptr [rbp + 038h]                                ; move type of address to testByte
  mov rax, rsi                                                   ; move testByte to testByte
  mov rdi, 001h                                                  ; read operand of mul (type table width in bytes) 
  mul rdi                                                        ; adjust to the relative start of that type's entry in the type table
  add rax, 000h                                                  ; adjust to the byte containing the bit to check against (result in testByte)
  mov r12, offset typeTable                                      ; read second operand of + (type table pointer)
  add rax, r12                                                   ; finally offset all of that by the start of the type table itself (result in testByte)
  bt qword ptr [rax], 002h                                       ; check that address is Integer
  jc func$__writeToAddress$address$TypeMatch                     ; skip next block if the type matches
    ; Error handling block for address
    ;  - print(parameterTypeCheckFailureMessage)
    ; Call __print with 1 arguments
    mov r13, offset parameterTypeCheckFailureMessage             ; reading parameterTypeCheckFailureMessage for push
    push r13                                                     ; value of argument #1 (parameterTypeCheckFailureMessage)
    push 016h                                                    ; type of argument #1 (String'22)
    lea r14, qword ptr [rsp + 020h]                              ; load address of return value's value
    push r14                                                     ; internal argument 6: pointer to return value slot's value
    lea r14, qword ptr [rsp + 020h]                              ; load address of return value's type
    push r14                                                     ; internal argument 5: pointer to return value slot's type
    sub rsp, 020h                                                ; allocate shadow space
    mov r9, 000h                                                 ; internal argument 4: "this" pointer
    mov r8, 000h                                                 ; internal argument 3: "this" pointer type
    mov rdx, 000h                                                ; internal argument 2: closure pointer
    mov qword ptr [rsp + 040h], rcx                              ; move parameter count of __writeToAddress value out of rcx
    mov rcx, 001h                                                ; internal argument 1: number of actual arguments
    call func$__print                                            ; jump to subroutine
    add rsp, 040h                                                ; release shadow space and arguments (result in stack pointer)
    ;  - exit(1)
    ; Call exit with 1 arguments
    push 001h                                                    ; value of argument #1 (1 (integer))
    push 015h                                                    ; type of argument #1 (Integer'21)
    lea r15, qword ptr [rsp + 020h]                              ; load address of return value's value
    push r15                                                     ; internal argument 6: pointer to return value slot's value
    lea r15, qword ptr [rsp + 020h]                              ; load address of return value's type
    push r15                                                     ; internal argument 5: pointer to return value slot's type
    sub rsp, 020h                                                ; allocate shadow space
    mov r9, 000h                                                 ; internal argument 4: "this" pointer
    mov r8, 000h                                                 ; internal argument 3: "this" pointer type
    mov rdx, 000h                                                ; internal argument 2: closure pointer
    mov rcx, 001h                                                ; internal argument 1: number of actual arguments
    call func$exit                                               ; jump to subroutine
    add rsp, 040h                                                ; release shadow space and arguments (result in stack pointer)
    mov rcx, qword ptr [rsp + 000h]                              ; restoring slots to previous scope state
  func$__writeToAddress$address$TypeMatch:                       ; after block
  ; Check type of parameter 1, value (expecting Integer)
  mov r10, qword ptr [rbp + 048h]                                ; move type of value to testByte
  mov rax, r10                                                   ; move testByte to testByte
  mov rbx, 001h                                                  ; read operand of mul (type table width in bytes) 
  mul rbx                                                        ; adjust to the relative start of that type's entry in the type table
  add rax, 000h                                                  ; adjust to the byte containing the bit to check against (result in testByte)
  mov rsi, offset typeTable                                      ; read second operand of + (type table pointer)
  add rax, rsi                                                   ; finally offset all of that by the start of the type table itself (result in testByte)
  bt qword ptr [rax], 002h                                       ; check that value is Integer
  jc func$__writeToAddress$value$TypeMatch                       ; skip next block if the type matches
    ; Error handling block for value
    ;  - print(parameterTypeCheckFailureMessage)
    ; Call __print with 1 arguments
    mov rdi, offset parameterTypeCheckFailureMessage             ; reading parameterTypeCheckFailureMessage for push
    push rdi                                                     ; value of argument #1 (parameterTypeCheckFailureMessage)
    push 016h                                                    ; type of argument #1 (String'22)
    lea r12, qword ptr [rsp + 020h]                              ; load address of return value's value
    push r12                                                     ; internal argument 6: pointer to return value slot's value
    lea r12, qword ptr [rsp + 020h]                              ; load address of return value's type
    push r12                                                     ; internal argument 5: pointer to return value slot's type
    sub rsp, 020h                                                ; allocate shadow space
    mov r9, 000h                                                 ; internal argument 4: "this" pointer
    mov r8, 000h                                                 ; internal argument 3: "this" pointer type
    mov rdx, 000h                                                ; internal argument 2: closure pointer
    mov qword ptr [rsp + 040h], rcx                              ; move parameter count of __writeToAddress value out of rcx
    mov rcx, 001h                                                ; internal argument 1: number of actual arguments
    call func$__print                                            ; jump to subroutine
    add rsp, 040h                                                ; release shadow space and arguments (result in stack pointer)
    ;  - exit(1)
    ; Call exit with 1 arguments
    push 001h                                                    ; value of argument #1 (1 (integer))
    push 015h                                                    ; type of argument #1 (Integer'21)
    lea r13, qword ptr [rsp + 020h]                              ; load address of return value's value
    push r13                                                     ; internal argument 6: pointer to return value slot's value
    lea r13, qword ptr [rsp + 020h]                              ; load address of return value's type
    push r13                                                     ; internal argument 5: pointer to return value slot's type
    sub rsp, 020h                                                ; allocate shadow space
    mov r9, 000h                                                 ; internal argument 4: "this" pointer
    mov r8, 000h                                                 ; internal argument 3: "this" pointer type
    mov rdx, 000h                                                ; internal argument 2: closure pointer
    mov rcx, 001h                                                ; internal argument 1: number of actual arguments
    call func$exit                                               ; jump to subroutine
    add rsp, 040h                                                ; release shadow space and arguments (result in stack pointer)
    mov rcx, qword ptr [rsp + 000h]                              ; restoring slots to previous scope state
  func$__writeToAddress$value$TypeMatch:                         ; after block
  ; Implicit return from __writeToAddress
  mov r14, qword ptr [rbp + 030h]                                ; get pointer to return value of __writeToAddress into register to dereference it
  mov qword ptr [r14], 000h                                      ; __writeToAddress return value
  mov r15, qword ptr [rbp + 028h]                                ; get pointer to return value type of __writeToAddress into register to dereference it
  mov qword ptr [r15], 013h                                      ; type of __writeToAddress return value (Null'19)
  jmp func$__writeToAddress$epilog                               ; return
  func$__writeToAddress$epilog: 
  mov rax, qword ptr [rbp + 030h]                                ; report address of return value
  ; Epilog
  add rsp, 020h                                                  ; free space for stack
  pop r14                                                        ; restore non-volatile registers
  pop r13                                                        ; restore non-volatile registers
  pop r12                                                        ; restore non-volatile registers
  pop rbp                                                        ; restore non-volatile registers
  pop rdi                                                        ; restore non-volatile registers
  pop rsi                                                        ; restore non-volatile registers
  pop rbx                                                        ; restore non-volatile registers
  pop r15                                                        ; restore non-volatile registers
  ret                                                            ; return from subroutine

; assert
func$assert:
  ; Prolog
  push r15                                                       ; save non-volatile registers
  push rbx                                                       ; save non-volatile registers
  push rsi                                                       ; save non-volatile registers
  push rdi                                                       ; save non-volatile registers
  push rbp                                                       ; save non-volatile registers
  push r12                                                       ; save non-volatile registers
  push r13                                                       ; save non-volatile registers
  push r14                                                       ; save non-volatile registers
  sub rsp, 020h                                                  ; allocate space for stack
  lea rbp, qword ptr [rsp + 060h]                                ; set up frame pointer
  ; Check parameter count
  cmp rcx, 002h                                                  ; compare parameter count of assert to 2 (integer)
  je func$assert$parameterCountCheck$continuation                ; check number of parameters is as expected
    ; Error handling block for parameter count
    ;  - print(parameterCountCheckFailureMessage)
    ; Call __print with 1 arguments
    mov r10, offset parameterCountCheckFailureMessage            ; reading parameterCountCheckFailureMessage for push
    push r10                                                     ; value of argument #1 (parameterCountCheckFailureMessage)
    push 016h                                                    ; type of argument #1 (String'22)
    lea rax, qword ptr [rsp + 020h]                              ; load address of return value's value
    push rax                                                     ; internal argument 6: pointer to return value slot's value
    lea rax, qword ptr [rsp + 020h]                              ; load address of return value's type
    push rax                                                     ; internal argument 5: pointer to return value slot's type
    sub rsp, 020h                                                ; allocate shadow space
    mov r9, 000h                                                 ; internal argument 4: "this" pointer
    mov r8, 000h                                                 ; internal argument 3: "this" pointer type
    mov rdx, 000h                                                ; internal argument 2: closure pointer
    mov qword ptr [rsp + 040h], rcx                              ; move parameter count of assert value out of rcx
    mov rcx, 001h                                                ; internal argument 1: number of actual arguments
    call func$__print                                            ; jump to subroutine
    add rsp, 040h                                                ; release shadow space and arguments (result in stack pointer)
    ;  - exit(1)
    ; Call exit with 1 arguments
    push 001h                                                    ; value of argument #1 (1 (integer))
    push 015h                                                    ; type of argument #1 (Integer'21)
    lea rbx, qword ptr [rsp + 020h]                              ; load address of return value's value
    push rbx                                                     ; internal argument 6: pointer to return value slot's value
    lea rbx, qword ptr [rsp + 020h]                              ; load address of return value's type
    push rbx                                                     ; internal argument 5: pointer to return value slot's type
    sub rsp, 020h                                                ; allocate shadow space
    mov r9, 000h                                                 ; internal argument 4: "this" pointer
    mov r8, 000h                                                 ; internal argument 3: "this" pointer type
    mov rdx, 000h                                                ; internal argument 2: closure pointer
    mov rcx, 001h                                                ; internal argument 1: number of actual arguments
    call func$exit                                               ; jump to subroutine
    add rsp, 040h                                                ; release shadow space and arguments (result in stack pointer)
    mov rcx, qword ptr [rsp + 000h]                              ; restoring slots to previous scope state
  func$assert$parameterCountCheck$continuation:                  ; end of parameter count check
  ; Check type of parameter 0, condition (expecting Boolean)
  mov rsi, qword ptr [rbp + 038h]                                ; move type of condition to testByte
  mov rax, rsi                                                   ; move testByte to testByte
  mov rdi, 001h                                                  ; read operand of mul (type table width in bytes) 
  mul rdi                                                        ; adjust to the relative start of that type's entry in the type table
  add rax, 000h                                                  ; adjust to the byte containing the bit to check against (result in testByte)
  mov r12, offset typeTable                                      ; read second operand of + (type table pointer)
  add rax, r12                                                   ; finally offset all of that by the start of the type table itself (result in testByte)
  bt qword ptr [rax], 001h                                       ; check that condition is Boolean
  jc func$assert$condition$TypeMatch                             ; skip next block if the type matches
    ; Error handling block for condition
    ;  - print(parameterTypeCheckFailureMessage)
    ; Call __print with 1 arguments
    mov r13, offset parameterTypeCheckFailureMessage             ; reading parameterTypeCheckFailureMessage for push
    push r13                                                     ; value of argument #1 (parameterTypeCheckFailureMessage)
    push 016h                                                    ; type of argument #1 (String'22)
    lea r14, qword ptr [rsp + 020h]                              ; load address of return value's value
    push r14                                                     ; internal argument 6: pointer to return value slot's value
    lea r14, qword ptr [rsp + 020h]                              ; load address of return value's type
    push r14                                                     ; internal argument 5: pointer to return value slot's type
    sub rsp, 020h                                                ; allocate shadow space
    mov r9, 000h                                                 ; internal argument 4: "this" pointer
    mov r8, 000h                                                 ; internal argument 3: "this" pointer type
    mov rdx, 000h                                                ; internal argument 2: closure pointer
    mov qword ptr [rsp + 040h], rcx                              ; move parameter count of assert value out of rcx
    mov rcx, 001h                                                ; internal argument 1: number of actual arguments
    call func$__print                                            ; jump to subroutine
    add rsp, 040h                                                ; release shadow space and arguments (result in stack pointer)
    ;  - exit(1)
    ; Call exit with 1 arguments
    push 001h                                                    ; value of argument #1 (1 (integer))
    push 015h                                                    ; type of argument #1 (Integer'21)
    lea r15, qword ptr [rsp + 020h]                              ; load address of return value's value
    push r15                                                     ; internal argument 6: pointer to return value slot's value
    lea r15, qword ptr [rsp + 020h]                              ; load address of return value's type
    push r15                                                     ; internal argument 5: pointer to return value slot's type
    sub rsp, 020h                                                ; allocate shadow space
    mov r9, 000h                                                 ; internal argument 4: "this" pointer
    mov r8, 000h                                                 ; internal argument 3: "this" pointer type
    mov rdx, 000h                                                ; internal argument 2: closure pointer
    mov rcx, 001h                                                ; internal argument 1: number of actual arguments
    call func$exit                                               ; jump to subroutine
    add rsp, 040h                                                ; release shadow space and arguments (result in stack pointer)
    mov rcx, qword ptr [rsp + 000h]                              ; restoring slots to previous scope state
  func$assert$condition$TypeMatch:                               ; after block
  ; Check type of parameter 1, message (expecting String)
  mov r10, qword ptr [rbp + 048h]                                ; move type of message to testByte
  mov rax, r10                                                   ; move testByte to testByte
  mov rbx, 001h                                                  ; read operand of mul (type table width in bytes) 
  mul rbx                                                        ; adjust to the relative start of that type's entry in the type table
  add rax, 000h                                                  ; adjust to the byte containing the bit to check against (result in testByte)
  mov rsi, offset typeTable                                      ; read second operand of + (type table pointer)
  add rax, rsi                                                   ; finally offset all of that by the start of the type table itself (result in testByte)
  bt qword ptr [rax], 003h                                       ; check that message is String
  jc func$assert$message$TypeMatch                               ; skip next block if the type matches
    ; Error handling block for message
    ;  - print(parameterTypeCheckFailureMessage)
    ; Call __print with 1 arguments
    mov rdi, offset parameterTypeCheckFailureMessage             ; reading parameterTypeCheckFailureMessage for push
    push rdi                                                     ; value of argument #1 (parameterTypeCheckFailureMessage)
    push 016h                                                    ; type of argument #1 (String'22)
    lea r12, qword ptr [rsp + 020h]                              ; load address of return value's value
    push r12                                                     ; internal argument 6: pointer to return value slot's value
    lea r12, qword ptr [rsp + 020h]                              ; load address of return value's type
    push r12                                                     ; internal argument 5: pointer to return value slot's type
    sub rsp, 020h                                                ; allocate shadow space
    mov r9, 000h                                                 ; internal argument 4: "this" pointer
    mov r8, 000h                                                 ; internal argument 3: "this" pointer type
    mov rdx, 000h                                                ; internal argument 2: closure pointer
    mov qword ptr [rsp + 040h], rcx                              ; move parameter count of assert value out of rcx
    mov rcx, 001h                                                ; internal argument 1: number of actual arguments
    call func$__print                                            ; jump to subroutine
    add rsp, 040h                                                ; release shadow space and arguments (result in stack pointer)
    ;  - exit(1)
    ; Call exit with 1 arguments
    push 001h                                                    ; value of argument #1 (1 (integer))
    push 015h                                                    ; type of argument #1 (Integer'21)
    lea r13, qword ptr [rsp + 020h]                              ; load address of return value's value
    push r13                                                     ; internal argument 6: pointer to return value slot's value
    lea r13, qword ptr [rsp + 020h]                              ; load address of return value's type
    push r13                                                     ; internal argument 5: pointer to return value slot's type
    sub rsp, 020h                                                ; allocate shadow space
    mov r9, 000h                                                 ; internal argument 4: "this" pointer
    mov r8, 000h                                                 ; internal argument 3: "this" pointer type
    mov rdx, 000h                                                ; internal argument 2: closure pointer
    mov rcx, 001h                                                ; internal argument 1: number of actual arguments
    call func$exit                                               ; jump to subroutine
    add rsp, 040h                                                ; release shadow space and arguments (result in stack pointer)
    mov rcx, qword ptr [rsp + 000h]                              ; restoring slots to previous scope state
  func$assert$message$TypeMatch:                                 ; after block
  ; Line 6: if (!condition) { ...
  xor r14, r14                                                   ; zero ! unary operator result to put the boolean in
  cmp qword ptr [rbp + 040h], 000h                               ; ! unary operator
  sete r14b                                                      ; put result in ! unary operator result
  mov r15, 014h                                                  ; ! unary operator result is a Boolean'20
  mov r15, 014h                                                  ; ! unary operator result is of type Boolean'20
  cmp r14, 000h                                                  ; compare ! unary operator result to false
  je func$assert$if$continuation                                 ; !condition
    ; Line 7: __print(message);
    ; Call __print with 1 arguments
    push qword ptr [rbp + 050h]                                  ; value of argument #1 (message)
    push qword ptr [rbp + 048h]                                  ; type of argument #1
    lea r10, qword ptr [rsp + 020h]                              ; load address of return value's value
    push r10                                                     ; internal argument 6: pointer to return value slot's value
    lea r10, qword ptr [rsp + 020h]                              ; load address of return value's type
    push r10                                                     ; internal argument 5: pointer to return value slot's type
    sub rsp, 020h                                                ; allocate shadow space
    mov r9, 000h                                                 ; internal argument 4: "this" pointer
    mov r8, 000h                                                 ; internal argument 3: "this" pointer type
    mov rdx, 000h                                                ; internal argument 2: closure pointer
    mov qword ptr [rsp + 040h], rcx                              ; move parameter count of assert value out of rcx
    mov rcx, 001h                                                ; internal argument 1: number of actual arguments
    call func$__print                                            ; jump to subroutine
    add rsp, 040h                                                ; release shadow space and arguments (result in stack pointer)
    ; Line 8: __print('\n');
    ; Call __print with 1 arguments
    mov rax, offset string                                       ; reading string for push
    push rax                                                     ; value of argument #1 (string)
    push 016h                                                    ; type of argument #1 (String'22)
    lea rbx, qword ptr [rsp + 020h]                              ; load address of return value's value
    push rbx                                                     ; internal argument 6: pointer to return value slot's value
    lea rbx, qword ptr [rsp + 020h]                              ; load address of return value's type
    push rbx                                                     ; internal argument 5: pointer to return value slot's type
    sub rsp, 020h                                                ; allocate shadow space
    mov r9, 000h                                                 ; internal argument 4: "this" pointer
    mov r8, 000h                                                 ; internal argument 3: "this" pointer type
    mov rdx, 000h                                                ; internal argument 2: closure pointer
    mov rcx, 001h                                                ; internal argument 1: number of actual arguments
    call func$__print                                            ; jump to subroutine
    add rsp, 040h                                                ; release shadow space and arguments (result in stack pointer)
    ; Line 9: exit(1);
    ; Call exit with 1 arguments
    push 001h                                                    ; value of argument #1 (1)
    push 015h                                                    ; type of argument #1 (Integer'21)
    lea rsi, qword ptr [rsp + 020h]                              ; load address of return value's value
    push rsi                                                     ; internal argument 6: pointer to return value slot's value
    lea rsi, qword ptr [rsp + 020h]                              ; load address of return value's type
    push rsi                                                     ; internal argument 5: pointer to return value slot's type
    sub rsp, 020h                                                ; allocate shadow space
    mov r9, 000h                                                 ; internal argument 4: "this" pointer
    mov r8, 000h                                                 ; internal argument 3: "this" pointer type
    mov rdx, 000h                                                ; internal argument 2: closure pointer
    mov rcx, 001h                                                ; internal argument 1: number of actual arguments
    call func$exit                                               ; jump to subroutine
    add rsp, 040h                                                ; release shadow space and arguments (result in stack pointer)
    mov rcx, qword ptr [rsp + 000h]                              ; restoring slots to previous scope state
  func$assert$if$continuation:                                   ; end of if
  ; Implicit return from assert
  mov rdi, qword ptr [rbp + 030h]                                ; get pointer to return value of assert into register to dereference it
  mov qword ptr [rdi], 000h                                      ; assert return value
  mov r12, qword ptr [rbp + 028h]                                ; get pointer to return value type of assert into register to dereference it
  mov qword ptr [r12], 013h                                      ; type of assert return value (Null'19)
  jmp func$assert$epilog                                         ; return
  func$assert$epilog: 
  mov rax, qword ptr [rbp + 030h]                                ; report address of return value
  ; Epilog
  add rsp, 020h                                                  ; free space for stack
  pop r14                                                        ; restore non-volatile registers
  pop r13                                                        ; restore non-volatile registers
  pop r12                                                        ; restore non-volatile registers
  pop rbp                                                        ; restore non-volatile registers
  pop rdi                                                        ; restore non-volatile registers
  pop rsi                                                        ; restore non-volatile registers
  pop rbx                                                        ; restore non-volatile registers
  pop r15                                                        ; restore non-volatile registers
  ret                                                            ; return from subroutine

; __getLastError
func$__getLastError:
  ; Prolog
  push rbx                                                       ; save non-volatile registers
  push rsi                                                       ; save non-volatile registers
  push rdi                                                       ; save non-volatile registers
  push r12                                                       ; save non-volatile registers
  push rbp                                                       ; save non-volatile registers
  sub rsp, 020h                                                  ; allocate space for stack
  lea rbp, qword ptr [rsp + 048h]                                ; set up frame pointer
  ; Check parameter count
  cmp rcx, 000h                                                  ; compare parameter count of __getLastError to 0 (integer)
  je func$__getLastError$parameterCountCheck$continuation        ; check number of parameters is as expected
    ; Error handling block for parameter count
    ;  - print(parameterCountCheckFailureMessage)
    ; Call __print with 1 arguments
    mov r10, offset parameterCountCheckFailureMessage            ; reading parameterCountCheckFailureMessage for push
    push r10                                                     ; value of argument #1 (parameterCountCheckFailureMessage)
    push 016h                                                    ; type of argument #1 (String'22)
    lea rax, qword ptr [rsp + 020h]                              ; load address of return value's value
    push rax                                                     ; internal argument 6: pointer to return value slot's value
    lea rax, qword ptr [rsp + 020h]                              ; load address of return value's type
    push rax                                                     ; internal argument 5: pointer to return value slot's type
    sub rsp, 020h                                                ; allocate shadow space
    mov r9, 000h                                                 ; internal argument 4: "this" pointer
    mov r8, 000h                                                 ; internal argument 3: "this" pointer type
    mov rdx, 000h                                                ; internal argument 2: closure pointer
    mov qword ptr [rsp + 040h], rcx                              ; move parameter count of __getLastError value out of rcx
    mov rcx, 001h                                                ; internal argument 1: number of actual arguments
    call func$__print                                            ; jump to subroutine
    add rsp, 040h                                                ; release shadow space and arguments (result in stack pointer)
    ;  - exit(1)
    ; Call exit with 1 arguments
    push 001h                                                    ; value of argument #1 (1 (integer))
    push 015h                                                    ; type of argument #1 (Integer'21)
    lea rbx, qword ptr [rsp + 020h]                              ; load address of return value's value
    push rbx                                                     ; internal argument 6: pointer to return value slot's value
    lea rbx, qword ptr [rsp + 020h]                              ; load address of return value's type
    push rbx                                                     ; internal argument 5: pointer to return value slot's type
    sub rsp, 020h                                                ; allocate shadow space
    mov r9, 000h                                                 ; internal argument 4: "this" pointer
    mov r8, 000h                                                 ; internal argument 3: "this" pointer type
    mov rdx, 000h                                                ; internal argument 2: closure pointer
    mov rcx, 001h                                                ; internal argument 1: number of actual arguments
    call func$exit                                               ; jump to subroutine
    add rsp, 040h                                                ; release shadow space and arguments (result in stack pointer)
    mov rcx, qword ptr [rsp + 000h]                              ; restoring slots to previous scope state
  func$__getLastError$parameterCountCheck$continuation:          ; end of parameter count check
  ; Calling GetLastError
  sub rsp, 020h                                                  ; allocate shadow space
  mov qword ptr [rsp + 030h], rcx                                ; move parameter count of __getLastError value out of rcx
  call GetLastError                                              ; calls GetLastError from kernel32.lib
  mov rsi, 015h                                                  ; return value of GetLastError system call is of type Integer'21
  add rsp, 020h                                                  ; release shadow space and arguments if there were more than four (result in stack pointer)
  mov rdi, qword ptr [rbp + 030h]                                ; get pointer to return value of __getLastError into register to dereference it
  mov qword ptr [rdi], rax                                       ; __getLastError return value
  mov r12, qword ptr [rbp + 028h]                                ; get pointer to return value type of __getLastError into register to dereference it
  mov qword ptr [r12], rsi                                       ; type of __getLastError return value
  jmp func$__getLastError$epilog                                 ; return
  func$__getLastError$epilog: 
  mov rax, qword ptr [rbp + 030h]                                ; report address of return value
  ; Epilog
  add rsp, 020h                                                  ; free space for stack
  pop rbp                                                        ; restore non-volatile registers
  pop r12                                                        ; restore non-volatile registers
  pop rdi                                                        ; restore non-volatile registers
  pop rsi                                                        ; restore non-volatile registers
  pop rbx                                                        ; restore non-volatile registers
  ret                                                            ; return from subroutine

; __getProcessHeap
func$__getProcessHeap:
  ; Prolog
  push rbx                                                       ; save non-volatile registers
  push rsi                                                       ; save non-volatile registers
  push rdi                                                       ; save non-volatile registers
  push r12                                                       ; save non-volatile registers
  push rbp                                                       ; save non-volatile registers
  sub rsp, 020h                                                  ; allocate space for stack
  lea rbp, qword ptr [rsp + 048h]                                ; set up frame pointer
  ; Check parameter count
  cmp rcx, 000h                                                  ; compare parameter count of __getProcessHeap to 0 (integer)
  je func$__getProcessHeap$parameterCountCheck$continuation      ; check number of parameters is as expected
    ; Error handling block for parameter count
    ;  - print(parameterCountCheckFailureMessage)
    ; Call __print with 1 arguments
    mov r10, offset parameterCountCheckFailureMessage            ; reading parameterCountCheckFailureMessage for push
    push r10                                                     ; value of argument #1 (parameterCountCheckFailureMessage)
    push 016h                                                    ; type of argument #1 (String'22)
    lea rax, qword ptr [rsp + 020h]                              ; load address of return value's value
    push rax                                                     ; internal argument 6: pointer to return value slot's value
    lea rax, qword ptr [rsp + 020h]                              ; load address of return value's type
    push rax                                                     ; internal argument 5: pointer to return value slot's type
    sub rsp, 020h                                                ; allocate shadow space
    mov r9, 000h                                                 ; internal argument 4: "this" pointer
    mov r8, 000h                                                 ; internal argument 3: "this" pointer type
    mov rdx, 000h                                                ; internal argument 2: closure pointer
    mov qword ptr [rsp + 040h], rcx                              ; move parameter count of __getProcessHeap value out of rcx
    mov rcx, 001h                                                ; internal argument 1: number of actual arguments
    call func$__print                                            ; jump to subroutine
    add rsp, 040h                                                ; release shadow space and arguments (result in stack pointer)
    ;  - exit(1)
    ; Call exit with 1 arguments
    push 001h                                                    ; value of argument #1 (1 (integer))
    push 015h                                                    ; type of argument #1 (Integer'21)
    lea rbx, qword ptr [rsp + 020h]                              ; load address of return value's value
    push rbx                                                     ; internal argument 6: pointer to return value slot's value
    lea rbx, qword ptr [rsp + 020h]                              ; load address of return value's type
    push rbx                                                     ; internal argument 5: pointer to return value slot's type
    sub rsp, 020h                                                ; allocate shadow space
    mov r9, 000h                                                 ; internal argument 4: "this" pointer
    mov r8, 000h                                                 ; internal argument 3: "this" pointer type
    mov rdx, 000h                                                ; internal argument 2: closure pointer
    mov rcx, 001h                                                ; internal argument 1: number of actual arguments
    call func$exit                                               ; jump to subroutine
    add rsp, 040h                                                ; release shadow space and arguments (result in stack pointer)
    mov rcx, qword ptr [rsp + 000h]                              ; restoring slots to previous scope state
  func$__getProcessHeap$parameterCountCheck$continuation:        ; end of parameter count check
  ; Calling GetProcessHeap
  sub rsp, 020h                                                  ; allocate shadow space
  mov qword ptr [rsp + 030h], rcx                                ; move parameter count of __getProcessHeap value out of rcx
  call GetProcessHeap                                            ; calls GetProcessHeap from kernel32.lib
  mov rsi, 015h                                                  ; return value of GetProcessHeap system call is of type Integer'21
  add rsp, 020h                                                  ; release shadow space and arguments if there were more than four (result in stack pointer)
  mov rdi, qword ptr [rbp + 030h]                                ; get pointer to return value of __getProcessHeap into register to dereference it
  mov qword ptr [rdi], rax                                       ; __getProcessHeap return value
  mov r12, qword ptr [rbp + 028h]                                ; get pointer to return value type of __getProcessHeap into register to dereference it
  mov qword ptr [r12], rsi                                       ; type of __getProcessHeap return value
  jmp func$__getProcessHeap$epilog                               ; return
  func$__getProcessHeap$epilog: 
  mov rax, qword ptr [rbp + 030h]                                ; report address of return value
  ; Epilog
  add rsp, 020h                                                  ; free space for stack
  pop rbp                                                        ; restore non-volatile registers
  pop r12                                                        ; restore non-volatile registers
  pop rdi                                                        ; restore non-volatile registers
  pop rsi                                                        ; restore non-volatile registers
  pop rbx                                                        ; restore non-volatile registers
  ret                                                            ; return from subroutine

; __heapAlloc
func$__heapAlloc:
  ; Prolog
  push r15                                                       ; save non-volatile registers
  push rbx                                                       ; save non-volatile registers
  push rsi                                                       ; save non-volatile registers
  push rdi                                                       ; save non-volatile registers
  push rbp                                                       ; save non-volatile registers
  push r12                                                       ; save non-volatile registers
  push r13                                                       ; save non-volatile registers
  push r14                                                       ; save non-volatile registers
  sub rsp, 020h                                                  ; allocate space for stack
  lea rbp, qword ptr [rsp + 060h]                                ; set up frame pointer
  ; Check parameter count
  cmp rcx, 003h                                                  ; compare parameter count of __heapAlloc to 3 (integer)
  je func$__heapAlloc$parameterCountCheck$continuation           ; check number of parameters is as expected
    ; Error handling block for parameter count
    ;  - print(parameterCountCheckFailureMessage)
    ; Call __print with 1 arguments
    mov r10, offset parameterCountCheckFailureMessage            ; reading parameterCountCheckFailureMessage for push
    push r10                                                     ; value of argument #1 (parameterCountCheckFailureMessage)
    push 016h                                                    ; type of argument #1 (String'22)
    lea rax, qword ptr [rsp + 020h]                              ; load address of return value's value
    push rax                                                     ; internal argument 6: pointer to return value slot's value
    lea rax, qword ptr [rsp + 020h]                              ; load address of return value's type
    push rax                                                     ; internal argument 5: pointer to return value slot's type
    sub rsp, 020h                                                ; allocate shadow space
    mov r9, 000h                                                 ; internal argument 4: "this" pointer
    mov r8, 000h                                                 ; internal argument 3: "this" pointer type
    mov rdx, 000h                                                ; internal argument 2: closure pointer
    mov qword ptr [rsp + 040h], rcx                              ; move parameter count of __heapAlloc value out of rcx
    mov rcx, 001h                                                ; internal argument 1: number of actual arguments
    call func$__print                                            ; jump to subroutine
    add rsp, 040h                                                ; release shadow space and arguments (result in stack pointer)
    ;  - exit(1)
    ; Call exit with 1 arguments
    push 001h                                                    ; value of argument #1 (1 (integer))
    push 015h                                                    ; type of argument #1 (Integer'21)
    lea rbx, qword ptr [rsp + 020h]                              ; load address of return value's value
    push rbx                                                     ; internal argument 6: pointer to return value slot's value
    lea rbx, qword ptr [rsp + 020h]                              ; load address of return value's type
    push rbx                                                     ; internal argument 5: pointer to return value slot's type
    sub rsp, 020h                                                ; allocate shadow space
    mov r9, 000h                                                 ; internal argument 4: "this" pointer
    mov r8, 000h                                                 ; internal argument 3: "this" pointer type
    mov rdx, 000h                                                ; internal argument 2: closure pointer
    mov rcx, 001h                                                ; internal argument 1: number of actual arguments
    call func$exit                                               ; jump to subroutine
    add rsp, 040h                                                ; release shadow space and arguments (result in stack pointer)
    mov rcx, qword ptr [rsp + 000h]                              ; restoring slots to previous scope state
  func$__heapAlloc$parameterCountCheck$continuation:             ; end of parameter count check
  ; Check type of parameter 0, hHeap (expecting Integer)
  mov rsi, qword ptr [rbp + 038h]                                ; move type of hHeap to testByte
  mov rax, rsi                                                   ; move testByte to testByte
  mov rdi, 001h                                                  ; read operand of mul (type table width in bytes) 
  mul rdi                                                        ; adjust to the relative start of that type's entry in the type table
  add rax, 000h                                                  ; adjust to the byte containing the bit to check against (result in testByte)
  mov r12, offset typeTable                                      ; read second operand of + (type table pointer)
  add rax, r12                                                   ; finally offset all of that by the start of the type table itself (result in testByte)
  bt qword ptr [rax], 002h                                       ; check that hHeap is Integer
  jc func$__heapAlloc$hheap$TypeMatch                            ; skip next block if the type matches
    ; Error handling block for hHeap
    ;  - print(parameterTypeCheckFailureMessage)
    ; Call __print with 1 arguments
    mov r13, offset parameterTypeCheckFailureMessage             ; reading parameterTypeCheckFailureMessage for push
    push r13                                                     ; value of argument #1 (parameterTypeCheckFailureMessage)
    push 016h                                                    ; type of argument #1 (String'22)
    lea r14, qword ptr [rsp + 020h]                              ; load address of return value's value
    push r14                                                     ; internal argument 6: pointer to return value slot's value
    lea r14, qword ptr [rsp + 020h]                              ; load address of return value's type
    push r14                                                     ; internal argument 5: pointer to return value slot's type
    sub rsp, 020h                                                ; allocate shadow space
    mov r9, 000h                                                 ; internal argument 4: "this" pointer
    mov r8, 000h                                                 ; internal argument 3: "this" pointer type
    mov rdx, 000h                                                ; internal argument 2: closure pointer
    mov qword ptr [rsp + 040h], rcx                              ; move parameter count of __heapAlloc value out of rcx
    mov rcx, 001h                                                ; internal argument 1: number of actual arguments
    call func$__print                                            ; jump to subroutine
    add rsp, 040h                                                ; release shadow space and arguments (result in stack pointer)
    ;  - exit(1)
    ; Call exit with 1 arguments
    push 001h                                                    ; value of argument #1 (1 (integer))
    push 015h                                                    ; type of argument #1 (Integer'21)
    lea r15, qword ptr [rsp + 020h]                              ; load address of return value's value
    push r15                                                     ; internal argument 6: pointer to return value slot's value
    lea r15, qword ptr [rsp + 020h]                              ; load address of return value's type
    push r15                                                     ; internal argument 5: pointer to return value slot's type
    sub rsp, 020h                                                ; allocate shadow space
    mov r9, 000h                                                 ; internal argument 4: "this" pointer
    mov r8, 000h                                                 ; internal argument 3: "this" pointer type
    mov rdx, 000h                                                ; internal argument 2: closure pointer
    mov rcx, 001h                                                ; internal argument 1: number of actual arguments
    call func$exit                                               ; jump to subroutine
    add rsp, 040h                                                ; release shadow space and arguments (result in stack pointer)
    mov rcx, qword ptr [rsp + 000h]                              ; restoring slots to previous scope state
  func$__heapAlloc$hheap$TypeMatch:                              ; after block
  ; Check type of parameter 1, dwFlags (expecting Integer)
  mov r10, qword ptr [rbp + 048h]                                ; move type of dwFlags to testByte
  mov rax, r10                                                   ; move testByte to testByte
  mov rbx, 001h                                                  ; read operand of mul (type table width in bytes) 
  mul rbx                                                        ; adjust to the relative start of that type's entry in the type table
  add rax, 000h                                                  ; adjust to the byte containing the bit to check against (result in testByte)
  mov rsi, offset typeTable                                      ; read second operand of + (type table pointer)
  add rax, rsi                                                   ; finally offset all of that by the start of the type table itself (result in testByte)
  bt qword ptr [rax], 002h                                       ; check that dwFlags is Integer
  jc func$__heapAlloc$dwflags$TypeMatch                          ; skip next block if the type matches
    ; Error handling block for dwFlags
    ;  - print(parameterTypeCheckFailureMessage)
    ; Call __print with 1 arguments
    mov rdi, offset parameterTypeCheckFailureMessage             ; reading parameterTypeCheckFailureMessage for push
    push rdi                                                     ; value of argument #1 (parameterTypeCheckFailureMessage)
    push 016h                                                    ; type of argument #1 (String'22)
    lea r12, qword ptr [rsp + 020h]                              ; load address of return value's value
    push r12                                                     ; internal argument 6: pointer to return value slot's value
    lea r12, qword ptr [rsp + 020h]                              ; load address of return value's type
    push r12                                                     ; internal argument 5: pointer to return value slot's type
    sub rsp, 020h                                                ; allocate shadow space
    mov r9, 000h                                                 ; internal argument 4: "this" pointer
    mov r8, 000h                                                 ; internal argument 3: "this" pointer type
    mov rdx, 000h                                                ; internal argument 2: closure pointer
    mov qword ptr [rsp + 040h], rcx                              ; move parameter count of __heapAlloc value out of rcx
    mov rcx, 001h                                                ; internal argument 1: number of actual arguments
    call func$__print                                            ; jump to subroutine
    add rsp, 040h                                                ; release shadow space and arguments (result in stack pointer)
    ;  - exit(1)
    ; Call exit with 1 arguments
    push 001h                                                    ; value of argument #1 (1 (integer))
    push 015h                                                    ; type of argument #1 (Integer'21)
    lea r13, qword ptr [rsp + 020h]                              ; load address of return value's value
    push r13                                                     ; internal argument 6: pointer to return value slot's value
    lea r13, qword ptr [rsp + 020h]                              ; load address of return value's type
    push r13                                                     ; internal argument 5: pointer to return value slot's type
    sub rsp, 020h                                                ; allocate shadow space
    mov r9, 000h                                                 ; internal argument 4: "this" pointer
    mov r8, 000h                                                 ; internal argument 3: "this" pointer type
    mov rdx, 000h                                                ; internal argument 2: closure pointer
    mov rcx, 001h                                                ; internal argument 1: number of actual arguments
    call func$exit                                               ; jump to subroutine
    add rsp, 040h                                                ; release shadow space and arguments (result in stack pointer)
    mov rcx, qword ptr [rsp + 000h]                              ; restoring slots to previous scope state
  func$__heapAlloc$dwflags$TypeMatch:                            ; after block
  ; Check type of parameter 2, dwBytes (expecting Integer)
  mov r14, qword ptr [rbp + 058h]                                ; move type of dwBytes to testByte
  mov rax, r14                                                   ; move testByte to testByte
  mov r15, 001h                                                  ; read operand of mul (type table width in bytes) 
  mul r15                                                        ; adjust to the relative start of that type's entry in the type table
  add rax, 000h                                                  ; adjust to the byte containing the bit to check against (result in testByte)
  mov r10, offset typeTable                                      ; read second operand of + (type table pointer)
  add rax, r10                                                   ; finally offset all of that by the start of the type table itself (result in testByte)
  bt qword ptr [rax], 002h                                       ; check that dwBytes is Integer
  jc func$__heapAlloc$dwbytes$TypeMatch                          ; skip next block if the type matches
    ; Error handling block for dwBytes
    ;  - print(parameterTypeCheckFailureMessage)
    ; Call __print with 1 arguments
    mov rbx, offset parameterTypeCheckFailureMessage             ; reading parameterTypeCheckFailureMessage for push
    push rbx                                                     ; value of argument #1 (parameterTypeCheckFailureMessage)
    push 016h                                                    ; type of argument #1 (String'22)
    lea rsi, qword ptr [rsp + 020h]                              ; load address of return value's value
    push rsi                                                     ; internal argument 6: pointer to return value slot's value
    lea rsi, qword ptr [rsp + 020h]                              ; load address of return value's type
    push rsi                                                     ; internal argument 5: pointer to return value slot's type
    sub rsp, 020h                                                ; allocate shadow space
    mov r9, 000h                                                 ; internal argument 4: "this" pointer
    mov r8, 000h                                                 ; internal argument 3: "this" pointer type
    mov rdx, 000h                                                ; internal argument 2: closure pointer
    mov qword ptr [rsp + 040h], rcx                              ; move parameter count of __heapAlloc value out of rcx
    mov rcx, 001h                                                ; internal argument 1: number of actual arguments
    call func$__print                                            ; jump to subroutine
    add rsp, 040h                                                ; release shadow space and arguments (result in stack pointer)
    ;  - exit(1)
    ; Call exit with 1 arguments
    push 001h                                                    ; value of argument #1 (1 (integer))
    push 015h                                                    ; type of argument #1 (Integer'21)
    lea rdi, qword ptr [rsp + 020h]                              ; load address of return value's value
    push rdi                                                     ; internal argument 6: pointer to return value slot's value
    lea rdi, qword ptr [rsp + 020h]                              ; load address of return value's type
    push rdi                                                     ; internal argument 5: pointer to return value slot's type
    sub rsp, 020h                                                ; allocate shadow space
    mov r9, 000h                                                 ; internal argument 4: "this" pointer
    mov r8, 000h                                                 ; internal argument 3: "this" pointer type
    mov rdx, 000h                                                ; internal argument 2: closure pointer
    mov rcx, 001h                                                ; internal argument 1: number of actual arguments
    call func$exit                                               ; jump to subroutine
    add rsp, 040h                                                ; release shadow space and arguments (result in stack pointer)
    mov rcx, qword ptr [rsp + 000h]                              ; restoring slots to previous scope state
  func$__heapAlloc$dwbytes$TypeMatch:                            ; after block
  ; Calling HeapAlloc
  sub rsp, 020h                                                  ; allocate shadow space
  mov r8, qword ptr [rbp + 060h]                                 ; argument #3
  mov rdx, qword ptr [rbp + 050h]                                ; argument #2
  mov qword ptr [rsp + 030h], rcx                                ; move parameter count of __heapAlloc value out of rcx
  mov rcx, qword ptr [rbp + 040h]                                ; argument #1
  call HeapAlloc                                                 ; calls HeapAlloc from kernel32.lib
  mov r12, 015h                                                  ; return value of HeapAlloc system call is of type Integer'21
  add rsp, 020h                                                  ; release shadow space and arguments if there were more than four (result in stack pointer)
  mov r13, qword ptr [rbp + 030h]                                ; get pointer to return value of __heapAlloc into register to dereference it
  mov qword ptr [r13], rax                                       ; __heapAlloc return value
  mov r14, qword ptr [rbp + 028h]                                ; get pointer to return value type of __heapAlloc into register to dereference it
  mov qword ptr [r14], r12                                       ; type of __heapAlloc return value
  jmp func$__heapAlloc$epilog                                    ; return
  func$__heapAlloc$epilog: 
  mov rax, qword ptr [rbp + 030h]                                ; report address of return value
  ; Epilog
  add rsp, 020h                                                  ; free space for stack
  pop r14                                                        ; restore non-volatile registers
  pop r13                                                        ; restore non-volatile registers
  pop r12                                                        ; restore non-volatile registers
  pop rbp                                                        ; restore non-volatile registers
  pop rdi                                                        ; restore non-volatile registers
  pop rsi                                                        ; restore non-volatile registers
  pop rbx                                                        ; restore non-volatile registers
  pop r15                                                        ; restore non-volatile registers
  ret                                                            ; return from subroutine

; _alloc
func$_alloc:
  ; Prolog
  push r15                                                       ; save non-volatile registers
  push rbx                                                       ; save non-volatile registers
  push rsi                                                       ; save non-volatile registers
  push rdi                                                       ; save non-volatile registers
  push rbp                                                       ; save non-volatile registers
  push r12                                                       ; save non-volatile registers
  push r13                                                       ; save non-volatile registers
  push r14                                                       ; save non-volatile registers
  sub rsp, 020h                                                  ; allocate space for stack
  lea rbp, qword ptr [rsp + 060h]                                ; set up frame pointer
  ; Check parameter count
  cmp rcx, 001h                                                  ; compare parameter count of _alloc to 1 (integer)
  je func$_alloc$parameterCountCheck$continuation                ; check number of parameters is as expected
    ; Error handling block for parameter count
    ;  - print(parameterCountCheckFailureMessage)
    ; Call __print with 1 arguments
    mov r10, offset parameterCountCheckFailureMessage            ; reading parameterCountCheckFailureMessage for push
    push r10                                                     ; value of argument #1 (parameterCountCheckFailureMessage)
    push 016h                                                    ; type of argument #1 (String'22)
    lea rax, qword ptr [rsp + 020h]                              ; load address of return value's value
    push rax                                                     ; internal argument 6: pointer to return value slot's value
    lea rax, qword ptr [rsp + 020h]                              ; load address of return value's type
    push rax                                                     ; internal argument 5: pointer to return value slot's type
    sub rsp, 020h                                                ; allocate shadow space
    mov r9, 000h                                                 ; internal argument 4: "this" pointer
    mov r8, 000h                                                 ; internal argument 3: "this" pointer type
    mov rdx, 000h                                                ; internal argument 2: closure pointer
    mov qword ptr [rsp + 040h], rcx                              ; move parameter count of _alloc value out of rcx
    mov rcx, 001h                                                ; internal argument 1: number of actual arguments
    call func$__print                                            ; jump to subroutine
    add rsp, 040h                                                ; release shadow space and arguments (result in stack pointer)
    ;  - exit(1)
    ; Call exit with 1 arguments
    push 001h                                                    ; value of argument #1 (1 (integer))
    push 015h                                                    ; type of argument #1 (Integer'21)
    lea rbx, qword ptr [rsp + 020h]                              ; load address of return value's value
    push rbx                                                     ; internal argument 6: pointer to return value slot's value
    lea rbx, qword ptr [rsp + 020h]                              ; load address of return value's type
    push rbx                                                     ; internal argument 5: pointer to return value slot's type
    sub rsp, 020h                                                ; allocate shadow space
    mov r9, 000h                                                 ; internal argument 4: "this" pointer
    mov r8, 000h                                                 ; internal argument 3: "this" pointer type
    mov rdx, 000h                                                ; internal argument 2: closure pointer
    mov rcx, 001h                                                ; internal argument 1: number of actual arguments
    call func$exit                                               ; jump to subroutine
    add rsp, 040h                                                ; release shadow space and arguments (result in stack pointer)
    mov rcx, qword ptr [rsp + 000h]                              ; restoring slots to previous scope state
  func$_alloc$parameterCountCheck$continuation:                  ; end of parameter count check
  ; Check type of parameter 0, size (expecting Integer)
  mov rsi, qword ptr [rbp + 038h]                                ; move type of size to testByte
  mov rax, rsi                                                   ; move testByte to testByte
  mov rdi, 001h                                                  ; read operand of mul (type table width in bytes) 
  mul rdi                                                        ; adjust to the relative start of that type's entry in the type table
  add rax, 000h                                                  ; adjust to the byte containing the bit to check against (result in testByte)
  mov r12, offset typeTable                                      ; read second operand of + (type table pointer)
  add rax, r12                                                   ; finally offset all of that by the start of the type table itself (result in testByte)
  bt qword ptr [rax], 002h                                       ; check that size is Integer
  jc func$_alloc$size$TypeMatch                                  ; skip next block if the type matches
    ; Error handling block for size
    ;  - print(parameterTypeCheckFailureMessage)
    ; Call __print with 1 arguments
    mov r13, offset parameterTypeCheckFailureMessage             ; reading parameterTypeCheckFailureMessage for push
    push r13                                                     ; value of argument #1 (parameterTypeCheckFailureMessage)
    push 016h                                                    ; type of argument #1 (String'22)
    lea r14, qword ptr [rsp + 020h]                              ; load address of return value's value
    push r14                                                     ; internal argument 6: pointer to return value slot's value
    lea r14, qword ptr [rsp + 020h]                              ; load address of return value's type
    push r14                                                     ; internal argument 5: pointer to return value slot's type
    sub rsp, 020h                                                ; allocate shadow space
    mov r9, 000h                                                 ; internal argument 4: "this" pointer
    mov r8, 000h                                                 ; internal argument 3: "this" pointer type
    mov rdx, 000h                                                ; internal argument 2: closure pointer
    mov qword ptr [rsp + 040h], rcx                              ; move parameter count of _alloc value out of rcx
    mov rcx, 001h                                                ; internal argument 1: number of actual arguments
    call func$__print                                            ; jump to subroutine
    add rsp, 040h                                                ; release shadow space and arguments (result in stack pointer)
    ;  - exit(1)
    ; Call exit with 1 arguments
    push 001h                                                    ; value of argument #1 (1 (integer))
    push 015h                                                    ; type of argument #1 (Integer'21)
    lea r15, qword ptr [rsp + 020h]                              ; load address of return value's value
    push r15                                                     ; internal argument 6: pointer to return value slot's value
    lea r15, qword ptr [rsp + 020h]                              ; load address of return value's type
    push r15                                                     ; internal argument 5: pointer to return value slot's type
    sub rsp, 020h                                                ; allocate shadow space
    mov r9, 000h                                                 ; internal argument 4: "this" pointer
    mov r8, 000h                                                 ; internal argument 3: "this" pointer type
    mov rdx, 000h                                                ; internal argument 2: closure pointer
    mov rcx, 001h                                                ; internal argument 1: number of actual arguments
    call func$exit                                               ; jump to subroutine
    add rsp, 040h                                                ; release shadow space and arguments (result in stack pointer)
    mov rcx, qword ptr [rsp + 000h]                              ; restoring slots to previous scope state
  func$_alloc$size$TypeMatch:                                    ; after block
  ; Line 27: _blockCount += 1;
  mov r10, qword ptr _blockCountValue                            ; assign value of _blockCount variable to value of += operator result
  add r10, 001h                                                  ; += operator
  mov rbx, 015h                                                  ; += operator result is of type Integer'21
  mov qword ptr _blockCountValue, r10                            ; store value
  mov qword ptr _blockCountType, rbx                             ; store type
  ; Line 28: return __heapAlloc(_heapHandle, 0, size);
  ; Call __heapAlloc with 3 arguments
  push qword ptr [rbp + 040h]                                    ; value of argument #3 (size)
  push qword ptr [rbp + 038h]                                    ; type of argument #3
  push 000h                                                      ; value of argument #2 (0)
  push 015h                                                      ; type of argument #2 (Integer'21)
  push qword ptr _heapHandleValue                                ; value of argument #1 (_heapHandle variable)
  push qword ptr _heapHandleType                                 ; type of argument #1
  lea rsi, qword ptr [rsp + 040h]                                ; load address of return value's value
  push rsi                                                       ; internal argument 6: pointer to return value slot's value
  lea rsi, qword ptr [rsp + 040h]                                ; load address of return value's type
  push rsi                                                       ; internal argument 5: pointer to return value slot's type
  sub rsp, 020h                                                  ; allocate shadow space
  mov r9, 000h                                                   ; internal argument 4: "this" pointer
  mov r8, 000h                                                   ; internal argument 3: "this" pointer type
  mov rdx, 000h                                                  ; internal argument 2: closure pointer
  mov qword ptr [rsp + 060h], rcx                                ; move parameter count of _alloc value out of rcx
  mov rcx, 003h                                                  ; internal argument 1: number of actual arguments
  call func$__heapAlloc                                          ; jump to subroutine
  add rsp, 060h                                                  ; release shadow space and arguments (result in stack pointer)
  mov rax, qword ptr [rsp + 010h]                                ; read second operand of mov (__heapAlloc return value) for MoveToDerefInstruction
  mov rdi, qword ptr [rbp + 030h]                                ; get pointer to return value of _alloc into register to dereference it
  mov qword ptr [rdi], rax                                       ; _alloc return value
  mov r12, qword ptr [rsp + 008h]                                ; reading type of __heapAlloc return value
  mov r13, qword ptr [rbp + 028h]                                ; get pointer to return value type of _alloc into register to dereference it
  mov qword ptr [r13], r12                                       ; type of _alloc return value
  jmp func$_alloc$epilog                                         ; return
  func$_alloc$epilog: 
  mov rax, qword ptr [rbp + 030h]                                ; report address of return value
  ; Epilog
  add rsp, 020h                                                  ; free space for stack
  pop r14                                                        ; restore non-volatile registers
  pop r13                                                        ; restore non-volatile registers
  pop r12                                                        ; restore non-volatile registers
  pop rbp                                                        ; restore non-volatile registers
  pop rdi                                                        ; restore non-volatile registers
  pop rsi                                                        ; restore non-volatile registers
  pop rbx                                                        ; restore non-volatile registers
  pop r15                                                        ; restore non-volatile registers
  ret                                                            ; return from subroutine

; __heapFree
func$__heapFree:
  ; Prolog
  push r15                                                       ; save non-volatile registers
  push rbx                                                       ; save non-volatile registers
  push rsi                                                       ; save non-volatile registers
  push rdi                                                       ; save non-volatile registers
  push rbp                                                       ; save non-volatile registers
  push r12                                                       ; save non-volatile registers
  push r13                                                       ; save non-volatile registers
  push r14                                                       ; save non-volatile registers
  sub rsp, 020h                                                  ; allocate space for stack
  lea rbp, qword ptr [rsp + 060h]                                ; set up frame pointer
  ; Check parameter count
  cmp rcx, 003h                                                  ; compare parameter count of __heapFree to 3 (integer)
  je func$__heapFree$parameterCountCheck$continuation            ; check number of parameters is as expected
    ; Error handling block for parameter count
    ;  - print(parameterCountCheckFailureMessage)
    ; Call __print with 1 arguments
    mov r10, offset parameterCountCheckFailureMessage            ; reading parameterCountCheckFailureMessage for push
    push r10                                                     ; value of argument #1 (parameterCountCheckFailureMessage)
    push 016h                                                    ; type of argument #1 (String'22)
    lea rax, qword ptr [rsp + 020h]                              ; load address of return value's value
    push rax                                                     ; internal argument 6: pointer to return value slot's value
    lea rax, qword ptr [rsp + 020h]                              ; load address of return value's type
    push rax                                                     ; internal argument 5: pointer to return value slot's type
    sub rsp, 020h                                                ; allocate shadow space
    mov r9, 000h                                                 ; internal argument 4: "this" pointer
    mov r8, 000h                                                 ; internal argument 3: "this" pointer type
    mov rdx, 000h                                                ; internal argument 2: closure pointer
    mov qword ptr [rsp + 040h], rcx                              ; move parameter count of __heapFree value out of rcx
    mov rcx, 001h                                                ; internal argument 1: number of actual arguments
    call func$__print                                            ; jump to subroutine
    add rsp, 040h                                                ; release shadow space and arguments (result in stack pointer)
    ;  - exit(1)
    ; Call exit with 1 arguments
    push 001h                                                    ; value of argument #1 (1 (integer))
    push 015h                                                    ; type of argument #1 (Integer'21)
    lea rbx, qword ptr [rsp + 020h]                              ; load address of return value's value
    push rbx                                                     ; internal argument 6: pointer to return value slot's value
    lea rbx, qword ptr [rsp + 020h]                              ; load address of return value's type
    push rbx                                                     ; internal argument 5: pointer to return value slot's type
    sub rsp, 020h                                                ; allocate shadow space
    mov r9, 000h                                                 ; internal argument 4: "this" pointer
    mov r8, 000h                                                 ; internal argument 3: "this" pointer type
    mov rdx, 000h                                                ; internal argument 2: closure pointer
    mov rcx, 001h                                                ; internal argument 1: number of actual arguments
    call func$exit                                               ; jump to subroutine
    add rsp, 040h                                                ; release shadow space and arguments (result in stack pointer)
    mov rcx, qword ptr [rsp + 000h]                              ; restoring slots to previous scope state
  func$__heapFree$parameterCountCheck$continuation:              ; end of parameter count check
  ; Check type of parameter 0, hHeap (expecting Integer)
  mov rsi, qword ptr [rbp + 038h]                                ; move type of hHeap to testByte
  mov rax, rsi                                                   ; move testByte to testByte
  mov rdi, 001h                                                  ; read operand of mul (type table width in bytes) 
  mul rdi                                                        ; adjust to the relative start of that type's entry in the type table
  add rax, 000h                                                  ; adjust to the byte containing the bit to check against (result in testByte)
  mov r12, offset typeTable                                      ; read second operand of + (type table pointer)
  add rax, r12                                                   ; finally offset all of that by the start of the type table itself (result in testByte)
  bt qword ptr [rax], 002h                                       ; check that hHeap is Integer
  jc func$__heapFree$hheap$TypeMatch                             ; skip next block if the type matches
    ; Error handling block for hHeap
    ;  - print(parameterTypeCheckFailureMessage)
    ; Call __print with 1 arguments
    mov r13, offset parameterTypeCheckFailureMessage             ; reading parameterTypeCheckFailureMessage for push
    push r13                                                     ; value of argument #1 (parameterTypeCheckFailureMessage)
    push 016h                                                    ; type of argument #1 (String'22)
    lea r14, qword ptr [rsp + 020h]                              ; load address of return value's value
    push r14                                                     ; internal argument 6: pointer to return value slot's value
    lea r14, qword ptr [rsp + 020h]                              ; load address of return value's type
    push r14                                                     ; internal argument 5: pointer to return value slot's type
    sub rsp, 020h                                                ; allocate shadow space
    mov r9, 000h                                                 ; internal argument 4: "this" pointer
    mov r8, 000h                                                 ; internal argument 3: "this" pointer type
    mov rdx, 000h                                                ; internal argument 2: closure pointer
    mov qword ptr [rsp + 040h], rcx                              ; move parameter count of __heapFree value out of rcx
    mov rcx, 001h                                                ; internal argument 1: number of actual arguments
    call func$__print                                            ; jump to subroutine
    add rsp, 040h                                                ; release shadow space and arguments (result in stack pointer)
    ;  - exit(1)
    ; Call exit with 1 arguments
    push 001h                                                    ; value of argument #1 (1 (integer))
    push 015h                                                    ; type of argument #1 (Integer'21)
    lea r15, qword ptr [rsp + 020h]                              ; load address of return value's value
    push r15                                                     ; internal argument 6: pointer to return value slot's value
    lea r15, qword ptr [rsp + 020h]                              ; load address of return value's type
    push r15                                                     ; internal argument 5: pointer to return value slot's type
    sub rsp, 020h                                                ; allocate shadow space
    mov r9, 000h                                                 ; internal argument 4: "this" pointer
    mov r8, 000h                                                 ; internal argument 3: "this" pointer type
    mov rdx, 000h                                                ; internal argument 2: closure pointer
    mov rcx, 001h                                                ; internal argument 1: number of actual arguments
    call func$exit                                               ; jump to subroutine
    add rsp, 040h                                                ; release shadow space and arguments (result in stack pointer)
    mov rcx, qword ptr [rsp + 000h]                              ; restoring slots to previous scope state
  func$__heapFree$hheap$TypeMatch:                               ; after block
  ; Check type of parameter 1, dwFlags (expecting Integer)
  mov r10, qword ptr [rbp + 048h]                                ; move type of dwFlags to testByte
  mov rax, r10                                                   ; move testByte to testByte
  mov rbx, 001h                                                  ; read operand of mul (type table width in bytes) 
  mul rbx                                                        ; adjust to the relative start of that type's entry in the type table
  add rax, 000h                                                  ; adjust to the byte containing the bit to check against (result in testByte)
  mov rsi, offset typeTable                                      ; read second operand of + (type table pointer)
  add rax, rsi                                                   ; finally offset all of that by the start of the type table itself (result in testByte)
  bt qword ptr [rax], 002h                                       ; check that dwFlags is Integer
  jc func$__heapFree$dwflags$TypeMatch                           ; skip next block if the type matches
    ; Error handling block for dwFlags
    ;  - print(parameterTypeCheckFailureMessage)
    ; Call __print with 1 arguments
    mov rdi, offset parameterTypeCheckFailureMessage             ; reading parameterTypeCheckFailureMessage for push
    push rdi                                                     ; value of argument #1 (parameterTypeCheckFailureMessage)
    push 016h                                                    ; type of argument #1 (String'22)
    lea r12, qword ptr [rsp + 020h]                              ; load address of return value's value
    push r12                                                     ; internal argument 6: pointer to return value slot's value
    lea r12, qword ptr [rsp + 020h]                              ; load address of return value's type
    push r12                                                     ; internal argument 5: pointer to return value slot's type
    sub rsp, 020h                                                ; allocate shadow space
    mov r9, 000h                                                 ; internal argument 4: "this" pointer
    mov r8, 000h                                                 ; internal argument 3: "this" pointer type
    mov rdx, 000h                                                ; internal argument 2: closure pointer
    mov qword ptr [rsp + 040h], rcx                              ; move parameter count of __heapFree value out of rcx
    mov rcx, 001h                                                ; internal argument 1: number of actual arguments
    call func$__print                                            ; jump to subroutine
    add rsp, 040h                                                ; release shadow space and arguments (result in stack pointer)
    ;  - exit(1)
    ; Call exit with 1 arguments
    push 001h                                                    ; value of argument #1 (1 (integer))
    push 015h                                                    ; type of argument #1 (Integer'21)
    lea r13, qword ptr [rsp + 020h]                              ; load address of return value's value
    push r13                                                     ; internal argument 6: pointer to return value slot's value
    lea r13, qword ptr [rsp + 020h]                              ; load address of return value's type
    push r13                                                     ; internal argument 5: pointer to return value slot's type
    sub rsp, 020h                                                ; allocate shadow space
    mov r9, 000h                                                 ; internal argument 4: "this" pointer
    mov r8, 000h                                                 ; internal argument 3: "this" pointer type
    mov rdx, 000h                                                ; internal argument 2: closure pointer
    mov rcx, 001h                                                ; internal argument 1: number of actual arguments
    call func$exit                                               ; jump to subroutine
    add rsp, 040h                                                ; release shadow space and arguments (result in stack pointer)
    mov rcx, qword ptr [rsp + 000h]                              ; restoring slots to previous scope state
  func$__heapFree$dwflags$TypeMatch:                             ; after block
  ; Check type of parameter 2, lpMem (expecting Integer)
  mov r14, qword ptr [rbp + 058h]                                ; move type of lpMem to testByte
  mov rax, r14                                                   ; move testByte to testByte
  mov r15, 001h                                                  ; read operand of mul (type table width in bytes) 
  mul r15                                                        ; adjust to the relative start of that type's entry in the type table
  add rax, 000h                                                  ; adjust to the byte containing the bit to check against (result in testByte)
  mov r10, offset typeTable                                      ; read second operand of + (type table pointer)
  add rax, r10                                                   ; finally offset all of that by the start of the type table itself (result in testByte)
  bt qword ptr [rax], 002h                                       ; check that lpMem is Integer
  jc func$__heapFree$lpmem$TypeMatch                             ; skip next block if the type matches
    ; Error handling block for lpMem
    ;  - print(parameterTypeCheckFailureMessage)
    ; Call __print with 1 arguments
    mov rbx, offset parameterTypeCheckFailureMessage             ; reading parameterTypeCheckFailureMessage for push
    push rbx                                                     ; value of argument #1 (parameterTypeCheckFailureMessage)
    push 016h                                                    ; type of argument #1 (String'22)
    lea rsi, qword ptr [rsp + 020h]                              ; load address of return value's value
    push rsi                                                     ; internal argument 6: pointer to return value slot's value
    lea rsi, qword ptr [rsp + 020h]                              ; load address of return value's type
    push rsi                                                     ; internal argument 5: pointer to return value slot's type
    sub rsp, 020h                                                ; allocate shadow space
    mov r9, 000h                                                 ; internal argument 4: "this" pointer
    mov r8, 000h                                                 ; internal argument 3: "this" pointer type
    mov rdx, 000h                                                ; internal argument 2: closure pointer
    mov qword ptr [rsp + 040h], rcx                              ; move parameter count of __heapFree value out of rcx
    mov rcx, 001h                                                ; internal argument 1: number of actual arguments
    call func$__print                                            ; jump to subroutine
    add rsp, 040h                                                ; release shadow space and arguments (result in stack pointer)
    ;  - exit(1)
    ; Call exit with 1 arguments
    push 001h                                                    ; value of argument #1 (1 (integer))
    push 015h                                                    ; type of argument #1 (Integer'21)
    lea rdi, qword ptr [rsp + 020h]                              ; load address of return value's value
    push rdi                                                     ; internal argument 6: pointer to return value slot's value
    lea rdi, qword ptr [rsp + 020h]                              ; load address of return value's type
    push rdi                                                     ; internal argument 5: pointer to return value slot's type
    sub rsp, 020h                                                ; allocate shadow space
    mov r9, 000h                                                 ; internal argument 4: "this" pointer
    mov r8, 000h                                                 ; internal argument 3: "this" pointer type
    mov rdx, 000h                                                ; internal argument 2: closure pointer
    mov rcx, 001h                                                ; internal argument 1: number of actual arguments
    call func$exit                                               ; jump to subroutine
    add rsp, 040h                                                ; release shadow space and arguments (result in stack pointer)
    mov rcx, qword ptr [rsp + 000h]                              ; restoring slots to previous scope state
  func$__heapFree$lpmem$TypeMatch:                               ; after block
  ; Calling HeapFree
  sub rsp, 020h                                                  ; allocate shadow space
  mov r8, qword ptr [rbp + 060h]                                 ; argument #3
  mov rdx, qword ptr [rbp + 050h]                                ; argument #2
  mov qword ptr [rsp + 030h], rcx                                ; move parameter count of __heapFree value out of rcx
  mov rcx, qword ptr [rbp + 040h]                                ; argument #1
  call HeapFree                                                  ; calls HeapFree from kernel32.lib
  mov r12, 015h                                                  ; return value of HeapFree system call is of type Integer'21
  add rsp, 020h                                                  ; release shadow space and arguments if there were more than four (result in stack pointer)
  mov r13, qword ptr [rbp + 030h]                                ; get pointer to return value of __heapFree into register to dereference it
  mov qword ptr [r13], rax                                       ; __heapFree return value
  mov r14, qword ptr [rbp + 028h]                                ; get pointer to return value type of __heapFree into register to dereference it
  mov qword ptr [r14], r12                                       ; type of __heapFree return value
  jmp func$__heapFree$epilog                                     ; return
  func$__heapFree$epilog: 
  mov rax, qword ptr [rbp + 030h]                                ; report address of return value
  ; Epilog
  add rsp, 020h                                                  ; free space for stack
  pop r14                                                        ; restore non-volatile registers
  pop r13                                                        ; restore non-volatile registers
  pop r12                                                        ; restore non-volatile registers
  pop rbp                                                        ; restore non-volatile registers
  pop rdi                                                        ; restore non-volatile registers
  pop rsi                                                        ; restore non-volatile registers
  pop rbx                                                        ; restore non-volatile registers
  pop r15                                                        ; restore non-volatile registers
  ret                                                            ; return from subroutine

; _free
func$_free:
  ; Prolog
  push r15                                                       ; save non-volatile registers
  push rbx                                                       ; save non-volatile registers
  push rsi                                                       ; save non-volatile registers
  push rdi                                                       ; save non-volatile registers
  push rbp                                                       ; save non-volatile registers
  push r12                                                       ; save non-volatile registers
  push r13                                                       ; save non-volatile registers
  push r14                                                       ; save non-volatile registers
  sub rsp, 020h                                                  ; allocate space for stack
  lea rbp, qword ptr [rsp + 060h]                                ; set up frame pointer
  ; Check parameter count
  cmp rcx, 001h                                                  ; compare parameter count of _free to 1 (integer)
  je func$_free$parameterCountCheck$continuation                 ; check number of parameters is as expected
    ; Error handling block for parameter count
    ;  - print(parameterCountCheckFailureMessage)
    ; Call __print with 1 arguments
    mov r10, offset parameterCountCheckFailureMessage            ; reading parameterCountCheckFailureMessage for push
    push r10                                                     ; value of argument #1 (parameterCountCheckFailureMessage)
    push 016h                                                    ; type of argument #1 (String'22)
    lea rax, qword ptr [rsp + 020h]                              ; load address of return value's value
    push rax                                                     ; internal argument 6: pointer to return value slot's value
    lea rax, qword ptr [rsp + 020h]                              ; load address of return value's type
    push rax                                                     ; internal argument 5: pointer to return value slot's type
    sub rsp, 020h                                                ; allocate shadow space
    mov r9, 000h                                                 ; internal argument 4: "this" pointer
    mov r8, 000h                                                 ; internal argument 3: "this" pointer type
    mov rdx, 000h                                                ; internal argument 2: closure pointer
    mov qword ptr [rsp + 040h], rcx                              ; move parameter count of _free value out of rcx
    mov rcx, 001h                                                ; internal argument 1: number of actual arguments
    call func$__print                                            ; jump to subroutine
    add rsp, 040h                                                ; release shadow space and arguments (result in stack pointer)
    ;  - exit(1)
    ; Call exit with 1 arguments
    push 001h                                                    ; value of argument #1 (1 (integer))
    push 015h                                                    ; type of argument #1 (Integer'21)
    lea rbx, qword ptr [rsp + 020h]                              ; load address of return value's value
    push rbx                                                     ; internal argument 6: pointer to return value slot's value
    lea rbx, qword ptr [rsp + 020h]                              ; load address of return value's type
    push rbx                                                     ; internal argument 5: pointer to return value slot's type
    sub rsp, 020h                                                ; allocate shadow space
    mov r9, 000h                                                 ; internal argument 4: "this" pointer
    mov r8, 000h                                                 ; internal argument 3: "this" pointer type
    mov rdx, 000h                                                ; internal argument 2: closure pointer
    mov rcx, 001h                                                ; internal argument 1: number of actual arguments
    call func$exit                                               ; jump to subroutine
    add rsp, 040h                                                ; release shadow space and arguments (result in stack pointer)
    mov rcx, qword ptr [rsp + 000h]                              ; restoring slots to previous scope state
  func$_free$parameterCountCheck$continuation:                   ; end of parameter count check
  ; Check type of parameter 0, pointer (expecting Integer)
  mov rsi, qword ptr [rbp + 038h]                                ; move type of pointer to testByte
  mov rax, rsi                                                   ; move testByte to testByte
  mov rdi, 001h                                                  ; read operand of mul (type table width in bytes) 
  mul rdi                                                        ; adjust to the relative start of that type's entry in the type table
  add rax, 000h                                                  ; adjust to the byte containing the bit to check against (result in testByte)
  mov r12, offset typeTable                                      ; read second operand of + (type table pointer)
  add rax, r12                                                   ; finally offset all of that by the start of the type table itself (result in testByte)
  bt qword ptr [rax], 002h                                       ; check that pointer is Integer
  jc func$_free$pointer$TypeMatch                                ; skip next block if the type matches
    ; Error handling block for pointer
    ;  - print(parameterTypeCheckFailureMessage)
    ; Call __print with 1 arguments
    mov r13, offset parameterTypeCheckFailureMessage             ; reading parameterTypeCheckFailureMessage for push
    push r13                                                     ; value of argument #1 (parameterTypeCheckFailureMessage)
    push 016h                                                    ; type of argument #1 (String'22)
    lea r14, qword ptr [rsp + 020h]                              ; load address of return value's value
    push r14                                                     ; internal argument 6: pointer to return value slot's value
    lea r14, qword ptr [rsp + 020h]                              ; load address of return value's type
    push r14                                                     ; internal argument 5: pointer to return value slot's type
    sub rsp, 020h                                                ; allocate shadow space
    mov r9, 000h                                                 ; internal argument 4: "this" pointer
    mov r8, 000h                                                 ; internal argument 3: "this" pointer type
    mov rdx, 000h                                                ; internal argument 2: closure pointer
    mov qword ptr [rsp + 040h], rcx                              ; move parameter count of _free value out of rcx
    mov rcx, 001h                                                ; internal argument 1: number of actual arguments
    call func$__print                                            ; jump to subroutine
    add rsp, 040h                                                ; release shadow space and arguments (result in stack pointer)
    ;  - exit(1)
    ; Call exit with 1 arguments
    push 001h                                                    ; value of argument #1 (1 (integer))
    push 015h                                                    ; type of argument #1 (Integer'21)
    lea r15, qword ptr [rsp + 020h]                              ; load address of return value's value
    push r15                                                     ; internal argument 6: pointer to return value slot's value
    lea r15, qword ptr [rsp + 020h]                              ; load address of return value's type
    push r15                                                     ; internal argument 5: pointer to return value slot's type
    sub rsp, 020h                                                ; allocate shadow space
    mov r9, 000h                                                 ; internal argument 4: "this" pointer
    mov r8, 000h                                                 ; internal argument 3: "this" pointer type
    mov rdx, 000h                                                ; internal argument 2: closure pointer
    mov rcx, 001h                                                ; internal argument 1: number of actual arguments
    call func$exit                                               ; jump to subroutine
    add rsp, 040h                                                ; release shadow space and arguments (result in stack pointer)
    mov rcx, qword ptr [rsp + 000h]                              ; restoring slots to previous scope state
  func$_free$pointer$TypeMatch:                                  ; after block
  ; Line 36: _blockCount -= 1;
  mov r10, qword ptr _blockCountValue                            ; assign value of _blockCount variable to value of -= operator result
  sub r10, 001h                                                  ; -= operator
  mov rbx, 015h                                                  ; -= operator result is of type Integer'21
  mov qword ptr _blockCountValue, r10                            ; store value
  mov qword ptr _blockCountType, rbx                             ; store type
  ; Line 37: if (__heapFree(_heapHandle, 0, pointer) == 0) { ...
  ; Call __heapFree with 3 arguments
  push qword ptr [rbp + 040h]                                    ; value of argument #3 (pointer)
  push qword ptr [rbp + 038h]                                    ; type of argument #3
  push 000h                                                      ; value of argument #2 (0)
  push 015h                                                      ; type of argument #2 (Integer'21)
  push qword ptr _heapHandleValue                                ; value of argument #1 (_heapHandle variable)
  push qword ptr _heapHandleType                                 ; type of argument #1
  lea rsi, qword ptr [rsp + 040h]                                ; load address of return value's value
  push rsi                                                       ; internal argument 6: pointer to return value slot's value
  lea rsi, qword ptr [rsp + 040h]                                ; load address of return value's type
  push rsi                                                       ; internal argument 5: pointer to return value slot's type
  sub rsp, 020h                                                  ; allocate shadow space
  mov r9, 000h                                                   ; internal argument 4: "this" pointer
  mov r8, 000h                                                   ; internal argument 3: "this" pointer type
  mov rdx, 000h                                                  ; internal argument 2: closure pointer
  mov qword ptr [rsp + 060h], rcx                                ; move parameter count of _free value out of rcx
  mov rcx, 003h                                                  ; internal argument 1: number of actual arguments
  call func$__heapFree                                           ; jump to subroutine
  add rsp, 060h                                                  ; release shadow space and arguments (result in stack pointer)
  xor rax, rax                                                   ; zero value result of == (testing __heapFree return value and 0) to put the boolean in
  cmp qword ptr [rsp + 010h], 000h                               ; values equal?
  sete al                                                        ; put result in value result of == (testing __heapFree return value and 0)
  mov rdi, 014h                                                  ; value result of == (testing __heapFree return value and 0) is a Boolean'20
  xor r12, r12                                                   ; zero type result of == (testing __heapFree return value and 0) to put the boolean in
  cmp qword ptr [rsp + 008h], 015h                               ; types equal?
  sete r12b                                                      ; put result in type result of == (testing __heapFree return value and 0)
  mov r13, 014h                                                  ; type result of == (testing __heapFree return value and 0) is a Boolean'20
  mov r14, rax                                                   ; assign value of value result of == (testing __heapFree return value and 0) to value of == operator result
  and r14, r12                                                   ; && type temp and value temp
  mov r15, 014h                                                  ; == operator result is of type Boolean'20
  cmp r14, 000h                                                  ; compare == operator result to false
  je func$_free$if$continuation                                  ; __heapFree(_heapHandle, 0, pointer) == 0
    ; Line 39: exit(1);
    ; Call exit with 1 arguments
    push 001h                                                    ; value of argument #1 (1)
    push 015h                                                    ; type of argument #1 (Integer'21)
    lea r10, qword ptr [rsp + 020h]                              ; load address of return value's value
    push r10                                                     ; internal argument 6: pointer to return value slot's value
    lea r10, qword ptr [rsp + 020h]                              ; load address of return value's type
    push r10                                                     ; internal argument 5: pointer to return value slot's type
    sub rsp, 020h                                                ; allocate shadow space
    mov r9, 000h                                                 ; internal argument 4: "this" pointer
    mov r8, 000h                                                 ; internal argument 3: "this" pointer type
    mov rdx, 000h                                                ; internal argument 2: closure pointer
    mov rcx, 001h                                                ; internal argument 1: number of actual arguments
    call func$exit                                               ; jump to subroutine
    add rsp, 040h                                                ; release shadow space and arguments (result in stack pointer)
  func$_free$if$continuation:                                    ; end of if
  ; Implicit return from _free
  mov rbx, qword ptr [rbp + 030h]                                ; get pointer to return value of _free into register to dereference it
  mov qword ptr [rbx], 000h                                      ; _free return value
  mov rsi, qword ptr [rbp + 028h]                                ; get pointer to return value type of _free into register to dereference it
  mov qword ptr [rsi], 013h                                      ; type of _free return value (Null'19)
  jmp func$_free$epilog                                          ; return
  func$_free$epilog: 
  mov rax, qword ptr [rbp + 030h]                                ; report address of return value
  ; Epilog
  add rsp, 020h                                                  ; free space for stack
  pop r14                                                        ; restore non-volatile registers
  pop r13                                                        ; restore non-volatile registers
  pop r12                                                        ; restore non-volatile registers
  pop rbp                                                        ; restore non-volatile registers
  pop rdi                                                        ; restore non-volatile registers
  pop rsi                                                        ; restore non-volatile registers
  pop rbx                                                        ; restore non-volatile registers
  pop r15                                                        ; restore non-volatile registers
  ret                                                            ; return from subroutine

; _moveBytes
func$_moveBytes:
  ; Prolog
  push r15                                                       ; save non-volatile registers
  push rbx                                                       ; save non-volatile registers
  push rsi                                                       ; save non-volatile registers
  push rdi                                                       ; save non-volatile registers
  push rbp                                                       ; save non-volatile registers
  push r12                                                       ; save non-volatile registers
  push r13                                                       ; save non-volatile registers
  push r14                                                       ; save non-volatile registers
  sub rsp, 078h                                                  ; allocate space for stack
  lea rbp, qword ptr [rsp + 0b8h]                                ; set up frame pointer
  ; Check parameter count
  cmp rcx, 003h                                                  ; compare parameter count of _moveBytes to 3 (integer)
  je func$_moveBytes$parameterCountCheck$continuation            ; check number of parameters is as expected
    ; Error handling block for parameter count
    ;  - print(parameterCountCheckFailureMessage)
    ; Call __print with 1 arguments
    mov r10, offset parameterCountCheckFailureMessage            ; reading parameterCountCheckFailureMessage for push
    push r10                                                     ; value of argument #1 (parameterCountCheckFailureMessage)
    push 016h                                                    ; type of argument #1 (String'22)
    lea rax, qword ptr [rsp + 078h]                              ; load address of return value's value
    push rax                                                     ; internal argument 6: pointer to return value slot's value
    lea rax, qword ptr [rsp + 078h]                              ; load address of return value's type
    push rax                                                     ; internal argument 5: pointer to return value slot's type
    sub rsp, 020h                                                ; allocate shadow space
    mov r9, 000h                                                 ; internal argument 4: "this" pointer
    mov r8, 000h                                                 ; internal argument 3: "this" pointer type
    mov rdx, 000h                                                ; internal argument 2: closure pointer
    mov qword ptr [rsp + 098h], rcx                              ; move parameter count of _moveBytes value out of rcx
    mov rcx, 001h                                                ; internal argument 1: number of actual arguments
    call func$__print                                            ; jump to subroutine
    add rsp, 040h                                                ; release shadow space and arguments (result in stack pointer)
    ;  - exit(1)
    ; Call exit with 1 arguments
    push 001h                                                    ; value of argument #1 (1 (integer))
    push 015h                                                    ; type of argument #1 (Integer'21)
    lea rbx, qword ptr [rsp + 078h]                              ; load address of return value's value
    push rbx                                                     ; internal argument 6: pointer to return value slot's value
    lea rbx, qword ptr [rsp + 078h]                              ; load address of return value's type
    push rbx                                                     ; internal argument 5: pointer to return value slot's type
    sub rsp, 020h                                                ; allocate shadow space
    mov r9, 000h                                                 ; internal argument 4: "this" pointer
    mov r8, 000h                                                 ; internal argument 3: "this" pointer type
    mov rdx, 000h                                                ; internal argument 2: closure pointer
    mov rcx, 001h                                                ; internal argument 1: number of actual arguments
    call func$exit                                               ; jump to subroutine
    add rsp, 040h                                                ; release shadow space and arguments (result in stack pointer)
    mov rcx, qword ptr [rsp + 058h]                              ; restoring slots to previous scope state
  func$_moveBytes$parameterCountCheck$continuation:              ; end of parameter count check
  ; Check type of parameter 0, from (expecting Integer)
  mov rsi, qword ptr [rbp + 038h]                                ; move type of from to testByte
  mov rax, rsi                                                   ; move testByte to testByte
  mov rdi, 001h                                                  ; read operand of mul (type table width in bytes) 
  mul rdi                                                        ; adjust to the relative start of that type's entry in the type table
  add rax, 000h                                                  ; adjust to the byte containing the bit to check against (result in testByte)
  mov r12, offset typeTable                                      ; read second operand of + (type table pointer)
  add rax, r12                                                   ; finally offset all of that by the start of the type table itself (result in testByte)
  bt qword ptr [rax], 002h                                       ; check that from is Integer
  jc func$_moveBytes$from$TypeMatch                              ; skip next block if the type matches
    ; Error handling block for from
    ;  - print(parameterTypeCheckFailureMessage)
    ; Call __print with 1 arguments
    mov r13, offset parameterTypeCheckFailureMessage             ; reading parameterTypeCheckFailureMessage for push
    push r13                                                     ; value of argument #1 (parameterTypeCheckFailureMessage)
    push 016h                                                    ; type of argument #1 (String'22)
    lea r14, qword ptr [rsp + 078h]                              ; load address of return value's value
    push r14                                                     ; internal argument 6: pointer to return value slot's value
    lea r14, qword ptr [rsp + 078h]                              ; load address of return value's type
    push r14                                                     ; internal argument 5: pointer to return value slot's type
    sub rsp, 020h                                                ; allocate shadow space
    mov r9, 000h                                                 ; internal argument 4: "this" pointer
    mov r8, 000h                                                 ; internal argument 3: "this" pointer type
    mov rdx, 000h                                                ; internal argument 2: closure pointer
    mov qword ptr [rsp + 098h], rcx                              ; move parameter count of _moveBytes value out of rcx
    mov rcx, 001h                                                ; internal argument 1: number of actual arguments
    call func$__print                                            ; jump to subroutine
    add rsp, 040h                                                ; release shadow space and arguments (result in stack pointer)
    ;  - exit(1)
    ; Call exit with 1 arguments
    push 001h                                                    ; value of argument #1 (1 (integer))
    push 015h                                                    ; type of argument #1 (Integer'21)
    lea r15, qword ptr [rsp + 078h]                              ; load address of return value's value
    push r15                                                     ; internal argument 6: pointer to return value slot's value
    lea r15, qword ptr [rsp + 078h]                              ; load address of return value's type
    push r15                                                     ; internal argument 5: pointer to return value slot's type
    sub rsp, 020h                                                ; allocate shadow space
    mov r9, 000h                                                 ; internal argument 4: "this" pointer
    mov r8, 000h                                                 ; internal argument 3: "this" pointer type
    mov rdx, 000h                                                ; internal argument 2: closure pointer
    mov rcx, 001h                                                ; internal argument 1: number of actual arguments
    call func$exit                                               ; jump to subroutine
    add rsp, 040h                                                ; release shadow space and arguments (result in stack pointer)
    mov rcx, qword ptr [rsp + 058h]                              ; restoring slots to previous scope state
  func$_moveBytes$from$TypeMatch:                                ; after block
  ; Check type of parameter 1, to (expecting Integer)
  mov r10, qword ptr [rbp + 048h]                                ; move type of to to testByte
  mov rax, r10                                                   ; move testByte to testByte
  mov rbx, 001h                                                  ; read operand of mul (type table width in bytes) 
  mul rbx                                                        ; adjust to the relative start of that type's entry in the type table
  add rax, 000h                                                  ; adjust to the byte containing the bit to check against (result in testByte)
  mov rsi, offset typeTable                                      ; read second operand of + (type table pointer)
  add rax, rsi                                                   ; finally offset all of that by the start of the type table itself (result in testByte)
  bt qword ptr [rax], 002h                                       ; check that to is Integer
  jc func$_moveBytes$to$TypeMatch                                ; skip next block if the type matches
    ; Error handling block for to
    ;  - print(parameterTypeCheckFailureMessage)
    ; Call __print with 1 arguments
    mov rdi, offset parameterTypeCheckFailureMessage             ; reading parameterTypeCheckFailureMessage for push
    push rdi                                                     ; value of argument #1 (parameterTypeCheckFailureMessage)
    push 016h                                                    ; type of argument #1 (String'22)
    lea r12, qword ptr [rsp + 078h]                              ; load address of return value's value
    push r12                                                     ; internal argument 6: pointer to return value slot's value
    lea r12, qword ptr [rsp + 078h]                              ; load address of return value's type
    push r12                                                     ; internal argument 5: pointer to return value slot's type
    sub rsp, 020h                                                ; allocate shadow space
    mov r9, 000h                                                 ; internal argument 4: "this" pointer
    mov r8, 000h                                                 ; internal argument 3: "this" pointer type
    mov rdx, 000h                                                ; internal argument 2: closure pointer
    mov qword ptr [rsp + 098h], rcx                              ; move parameter count of _moveBytes value out of rcx
    mov rcx, 001h                                                ; internal argument 1: number of actual arguments
    call func$__print                                            ; jump to subroutine
    add rsp, 040h                                                ; release shadow space and arguments (result in stack pointer)
    ;  - exit(1)
    ; Call exit with 1 arguments
    push 001h                                                    ; value of argument #1 (1 (integer))
    push 015h                                                    ; type of argument #1 (Integer'21)
    lea r13, qword ptr [rsp + 078h]                              ; load address of return value's value
    push r13                                                     ; internal argument 6: pointer to return value slot's value
    lea r13, qword ptr [rsp + 078h]                              ; load address of return value's type
    push r13                                                     ; internal argument 5: pointer to return value slot's type
    sub rsp, 020h                                                ; allocate shadow space
    mov r9, 000h                                                 ; internal argument 4: "this" pointer
    mov r8, 000h                                                 ; internal argument 3: "this" pointer type
    mov rdx, 000h                                                ; internal argument 2: closure pointer
    mov rcx, 001h                                                ; internal argument 1: number of actual arguments
    call func$exit                                               ; jump to subroutine
    add rsp, 040h                                                ; release shadow space and arguments (result in stack pointer)
    mov rcx, qword ptr [rsp + 058h]                              ; restoring slots to previous scope state
  func$_moveBytes$to$TypeMatch:                                  ; after block
  ; Check type of parameter 2, length (expecting Integer)
  mov r14, qword ptr [rbp + 058h]                                ; move type of length to testByte
  mov rax, r14                                                   ; move testByte to testByte
  mov r15, 001h                                                  ; read operand of mul (type table width in bytes) 
  mul r15                                                        ; adjust to the relative start of that type's entry in the type table
  add rax, 000h                                                  ; adjust to the byte containing the bit to check against (result in testByte)
  mov r10, offset typeTable                                      ; read second operand of + (type table pointer)
  add rax, r10                                                   ; finally offset all of that by the start of the type table itself (result in testByte)
  bt qword ptr [rax], 002h                                       ; check that length is Integer
  jc func$_moveBytes$length$TypeMatch                            ; skip next block if the type matches
    ; Error handling block for length
    ;  - print(parameterTypeCheckFailureMessage)
    ; Call __print with 1 arguments
    mov rbx, offset parameterTypeCheckFailureMessage             ; reading parameterTypeCheckFailureMessage for push
    push rbx                                                     ; value of argument #1 (parameterTypeCheckFailureMessage)
    push 016h                                                    ; type of argument #1 (String'22)
    lea rsi, qword ptr [rsp + 078h]                              ; load address of return value's value
    push rsi                                                     ; internal argument 6: pointer to return value slot's value
    lea rsi, qword ptr [rsp + 078h]                              ; load address of return value's type
    push rsi                                                     ; internal argument 5: pointer to return value slot's type
    sub rsp, 020h                                                ; allocate shadow space
    mov r9, 000h                                                 ; internal argument 4: "this" pointer
    mov r8, 000h                                                 ; internal argument 3: "this" pointer type
    mov rdx, 000h                                                ; internal argument 2: closure pointer
    mov qword ptr [rsp + 098h], rcx                              ; move parameter count of _moveBytes value out of rcx
    mov rcx, 001h                                                ; internal argument 1: number of actual arguments
    call func$__print                                            ; jump to subroutine
    add rsp, 040h                                                ; release shadow space and arguments (result in stack pointer)
    ;  - exit(1)
    ; Call exit with 1 arguments
    push 001h                                                    ; value of argument #1 (1 (integer))
    push 015h                                                    ; type of argument #1 (Integer'21)
    lea rdi, qword ptr [rsp + 078h]                              ; load address of return value's value
    push rdi                                                     ; internal argument 6: pointer to return value slot's value
    lea rdi, qword ptr [rsp + 078h]                              ; load address of return value's type
    push rdi                                                     ; internal argument 5: pointer to return value slot's type
    sub rsp, 020h                                                ; allocate shadow space
    mov r9, 000h                                                 ; internal argument 4: "this" pointer
    mov r8, 000h                                                 ; internal argument 3: "this" pointer type
    mov rdx, 000h                                                ; internal argument 2: closure pointer
    mov rcx, 001h                                                ; internal argument 1: number of actual arguments
    call func$exit                                               ; jump to subroutine
    add rsp, 040h                                                ; release shadow space and arguments (result in stack pointer)
    mov rcx, qword ptr [rsp + 058h]                              ; restoring slots to previous scope state
  func$_moveBytes$length$TypeMatch:                              ; after block
  ; Line 46: assert(length > 0, '_moveBytes expects positive number of bytes ...
  xor r12, r12                                                   ; clear > operator result
  cmp qword ptr [rbp + 060h], 000h                               ; compare length with 0
  setg r12b                                                      ; store result in > operator result
  mov r13, 014h                                                  ; > operator result is of type Boolean'20
  ; Call assert with 2 arguments
  mov r14, offset string$1                                       ; reading string for push
  push r14                                                       ; value of argument #2 (string)
  push 016h                                                      ; type of argument #2 (String'22)
  push r12                                                       ; value of argument #1 (> operator result)
  push r13                                                       ; type of argument #1
  lea rax, qword ptr [rsp + 088h]                                ; load address of return value's value
  push rax                                                       ; internal argument 6: pointer to return value slot's value
  lea rax, qword ptr [rsp + 088h]                                ; load address of return value's type
  push rax                                                       ; internal argument 5: pointer to return value slot's type
  sub rsp, 020h                                                  ; allocate shadow space
  mov r9, 000h                                                   ; internal argument 4: "this" pointer
  mov r8, 000h                                                   ; internal argument 3: "this" pointer type
  mov rdx, 000h                                                  ; internal argument 2: closure pointer
  mov qword ptr [rsp + 0a8h], rcx                                ; move parameter count of _moveBytes value out of rcx
  mov rcx, 002h                                                  ; internal argument 1: number of actual arguments
  call func$assert                                               ; jump to subroutine
  add rsp, 050h                                                  ; release shadow space and arguments (result in stack pointer)
  ; Line 47: Integer fromCursor = from;
  mov r15, qword ptr [rbp + 040h]                                ; value initialization of variable declaration for fromCursor variable (from)
  mov r10, qword ptr [rbp + 038h]                                ; type initialization of variable declaration for fromCursor variable
  ; Line 48: Integer toCursor = to;
  mov rbx, qword ptr [rbp + 050h]                                ; value initialization of variable declaration for toCursor variable (to)
  mov rsi, qword ptr [rbp + 048h]                                ; type initialization of variable declaration for toCursor variable
  ; Line 49: Integer end = from + length / 8 * 8;
  mov rax, qword ptr [rbp + 060h]                                ; assign value of length to value of / operator result
  cqo                                                            ; zero-extend dividend
  mov rdi, 008h                                                  ; read operand of div (8) 
  idiv rdi                                                       ; compute (length) / (8) (result, / operator result, is in rax)
  mov r12, 015h                                                  ; / operator result is of type Integer'21
  imul r13, rax, 008h                                            ; compute (/ operator result) * (8) (result in * operator result)
  mov r14, 015h                                                  ; * operator result is of type Integer'21
  mov r9, qword ptr [rbp + 040h]                                 ; assign value of from to value of + operator result
  add r9, r13                                                    ; compute (from) + (* operator result) (result in + operator result)
  mov r8, 015h                                                   ; + operator result is of type Integer'21
  mov rdx, r9                                                    ; value initialization of variable declaration for end variable (+ operator result)
  mov rcx, r8                                                    ; type initialization of variable declaration for end variable
  func$_moveBytes$while$top:                                     ; top of while
    mov qword ptr [rsp + 068h], r10                              ; move fromCursor variable type out of r10
    xor r10, r10                                                 ; clear < operator result
    cmp r15, rdx                                                 ; compare fromCursor variable with end variable
    setl r10b                                                    ; store result in < operator result
    mov qword ptr [rsp + 060h], r15                              ; move fromCursor variable value out of r15
    mov r15, 014h                                                ; < operator result is of type Boolean'20
    cmp r10, 000h                                                ; compare < operator result to false
    jne func$_moveBytes$while$body                               ; while condition
    mov r15, qword ptr [rsp + 060h]                              ; restoring slots to previous scope state
    mov r10, qword ptr [rsp + 068h]                              ; restoring slots to previous scope state
    jmp func$_moveBytes$while$bottom                             ; break out of while
    func$_moveBytes$while$body:                                  ; start of while
    ; Line 54: Integer value = __readFromAddress(fromCursor);
    ; Call __readFromAddress with 1 arguments
    mov qword ptr [rsp + 050h], rbx                              ; move toCursor variable value out of rbx
    mov rbx, qword ptr [rsp + 060h]                              ; get fromCursor variable into register to dereference it
    mov qword ptr [rsp + 060h], rsi                              ; move toCursor variable type out of rsi
    mov rsi, qword ptr [rbx]                                     ; dereference first argument of __readFromAddress
    mov rax, 015h                                                ; dereferenced fromCursor variable is of type Integer'21
    mov rdi, rsi                                                 ; value initialization of variable declaration for value variable (dereferenced fromCursor variable)
    mov r12, rax                                                 ; type initialization of variable declaration for value variable
    ; Line 55: __writeToAddress(toCursor, value);
    ; Call __writeToAddress with 2 arguments
    mov r13, qword ptr [rsp + 050h]                              ; get toCursor variable into register to dereference it
    mov qword ptr [r13], rdi                                     ; __writeToAddress
    ; Line 56: fromCursor += 8;
    mov r14, rbx                                                 ; assign value of fromCursor variable to value of += operator result
    add r14, 008h                                                ; += operator
    mov r9, 015h                                                 ; += operator result is of type Integer'21
    mov rbx, r14                                                 ; store value
    mov qword ptr [rsp + 068h], r9                               ; store type
    ; Line 57: toCursor += 8;
    mov r8, r13                                                  ; assign value of toCursor variable to value of += operator result
    add r8, 008h                                                 ; += operator
    mov qword ptr [rsp + 050h], rdx                              ; move end variable value out of rdx
    mov rdx, 015h                                                ; += operator result is of type Integer'21
    mov r13, r8                                                  ; store value
    mov qword ptr [rsp + 060h], rdx                              ; store type
    mov r15, rbx                                                 ; restoring slots to previous scope state
    mov rbx, r13                                                 ; restoring slots to previous scope state
    mov rdx, qword ptr [rsp + 050h]                              ; restoring slots to previous scope state
    mov rsi, qword ptr [rsp + 060h]                              ; restoring slots to previous scope state
    mov r10, qword ptr [rsp + 068h]                              ; restoring slots to previous scope state
    jmp func$_moveBytes$while$top                                ; return to top of while
  func$_moveBytes$while$bottom:                                  ; bottom of while
  ; Line 59: end = from + length;
  mov qword ptr [rsp + 068h], rcx                                ; move end variable type out of rcx
  mov rcx, qword ptr [rbp + 040h]                                ; assign value of from to value of + operator result
  add rcx, qword ptr [rbp + 060h]                                ; compute (from) + (length) (result in + operator result)
  mov qword ptr [rsp + 060h], r10                                ; move fromCursor variable type out of r10
  mov r10, 015h                                                  ; + operator result is of type Integer'21
  mov rdx, rcx                                                   ; store value
  mov qword ptr [rsp + 068h], r10                                ; store type
  ; Line 61: if (fromCursor < end) { ...
  mov qword ptr [rsp + 050h], rbx                                ; move toCursor variable value out of rbx
  xor rbx, rbx                                                   ; clear < operator result
  cmp r15, rdx                                                   ; compare fromCursor variable with end variable
  setl bl                                                        ; store result in < operator result
  mov qword ptr [rsp + 048h], r15                                ; move fromCursor variable value out of r15
  mov r15, 014h                                                  ; < operator result is of type Boolean'20
  cmp rbx, 000h                                                  ; compare < operator result to false
  je func$_moveBytes$if$continuation                             ; fromCursor < end
    ; Line 62: Integer newValue = __readFromAddress(fromCursor);
    ; Call __readFromAddress with 1 arguments
    mov qword ptr [rsp + 040h], rsi                              ; move toCursor variable type out of rsi
    mov rsi, qword ptr [rsp + 048h]                              ; get fromCursor variable into register to dereference it
    mov rax, qword ptr [rsi]                                     ; dereference first argument of __readFromAddress
    mov rdi, 015h                                                ; dereferenced fromCursor variable is of type Integer'21
    mov r12, rax                                                 ; value initialization of variable declaration for newValue variable (dereferenced fromCursor variable)
    mov r13, rdi                                                 ; type initialization of variable declaration for newValue variable
    ; Line 63: Integer oldValue = __readFromAddress(toCursor);
    ; Call __readFromAddress with 1 arguments
    mov r14, qword ptr [rsp + 050h]                              ; get toCursor variable into register to dereference it
    mov r9, qword ptr [r14]                                      ; dereference first argument of __readFromAddress
    mov r8, 015h                                                 ; dereferenced toCursor variable is of type Integer'21
    mov qword ptr [rsp + 050h], rdx                              ; move end variable value out of rdx
    mov rdx, r9                                                  ; value initialization of variable declaration for oldValue variable (dereferenced toCursor variable)
    mov rcx, r8                                                  ; type initialization of variable declaration for oldValue variable
    ; Line 64: Integer extraBytes = end - fromCursor;
    mov r10, qword ptr [rsp + 050h]                              ; assign value of end variable to value of - operator result
    sub r10, rsi                                                 ; compute (end variable) - (fromCursor variable)
    mov rbx, 015h                                                ; - operator result is of type Integer'21
    mov r15, r10                                                 ; value initialization of variable declaration for extraBytes variable (- operator result)
    mov qword ptr [rsp + 048h], rsi                              ; move fromCursor variable value out of rsi
    mov rsi, rbx                                                 ; type initialization of variable declaration for extraBytes variable
    ; Line 65: assert(extraBytes > 0, 'internal error: zero extra bytes but fro...
    xor rax, rax                                                 ; clear > operator result
    cmp r15, 000h                                                ; compare extraBytes variable with 0
    setg al                                                      ; store result in > operator result
    mov rdi, 014h                                                ; > operator result is of type Boolean'20
    ; Call assert with 2 arguments
    mov qword ptr [rsp + 038h], r12                              ; move newValue variable value out of r12
    mov r12, offset string$2                                     ; reading string for push
    push r12                                                     ; value of argument #2 (string)
    push 016h                                                    ; type of argument #2 (String'22)
    push rax                                                     ; value of argument #1 (> operator result)
    push rdi                                                     ; type of argument #1
    mov qword ptr [rsp + 048h], r13                              ; move newValue variable type out of r13
    lea r13, qword ptr [rsp + 050h]                              ; load address of return value's value
    push r13                                                     ; internal argument 6: pointer to return value slot's value
    lea r13, qword ptr [rsp + 048h]                              ; load address of return value's type
    push r13                                                     ; internal argument 5: pointer to return value slot's type
    sub rsp, 020h                                                ; allocate shadow space
    mov r9, 000h                                                 ; internal argument 4: "this" pointer
    mov r8, 000h                                                 ; internal argument 3: "this" pointer type
    mov qword ptr [rsp + 068h], rdx                              ; move oldValue variable value out of rdx
    mov rdx, 000h                                                ; internal argument 2: closure pointer
    mov qword ptr [rsp + 060h], rcx                              ; move oldValue variable type out of rcx
    mov rcx, 002h                                                ; internal argument 1: number of actual arguments
    call func$assert                                             ; jump to subroutine
    add rsp, 050h                                                ; release shadow space and arguments (result in stack pointer)
    ; Line 66: assert(extraBytes < 8, 'internal error: more than 7 extra bytes'...
    mov qword ptr [rsp + 030h], r14                              ; move toCursor variable value out of r14
    xor r14, r14                                                 ; clear < operator result
    cmp r15, 008h                                                ; compare extraBytes variable with 8
    setl r14b                                                    ; store result in < operator result
    mov r10, 014h                                                ; < operator result is of type Boolean'20
    ; Call assert with 2 arguments
    mov rbx, offset string$3                                     ; reading string for push
    push rbx                                                     ; value of argument #2 (string)
    push 016h                                                    ; type of argument #2 (String'22)
    push r14                                                     ; value of argument #1 (< operator result)
    push r10                                                     ; type of argument #1
    mov qword ptr [rsp + 028h], r15                              ; move extraBytes variable value out of r15
    lea r15, qword ptr [rsp + 040h]                              ; load address of return value's value
    push r15                                                     ; internal argument 6: pointer to return value slot's value
    lea r15, qword ptr [rsp + 028h]                              ; load address of return value's type
    push r15                                                     ; internal argument 5: pointer to return value slot's type
    sub rsp, 020h                                                ; allocate shadow space
    mov r9, 000h                                                 ; internal argument 4: "this" pointer
    mov r8, 000h                                                 ; internal argument 3: "this" pointer type
    mov rdx, 000h                                                ; internal argument 2: closure pointer
    mov rcx, 002h                                                ; internal argument 1: number of actual arguments
    call func$assert                                             ; jump to subroutine
    add rsp, 050h                                                ; release shadow space and arguments (result in stack pointer)
    ; Line 67: Integer mask = -1 << extraBytes * 8;
    mov qword ptr [rsp + 020h], rsi                              ; move extraBytes variable type out of rsi
    mov rax, qword ptr [rsp + 008h]                              ; read left hand side operand of imul (extraBytes variable)
    imul rsi, rax, 008h                                          ; compute (extraBytes variable) * (8) (result in * operator result)
    mov rdi, 015h                                                ; * operator result is of type Integer'21
    mov rcx, rsi                                                 ; read <DynamicSlot:Integer'21 at [rsi]/[rdi] ("* operator result") (living: true)> into imm8 or cl forshl
    mov r12, -001h                                               ; assign value of -1 to value of << operator result
    shl r12, cl                                                  ; compute (-1) << (* operator result)
    mov r13, 015h                                                ; << operator result is of type Integer'21
    mov r14, r12                                                 ; value initialization of variable declaration for mask variable (<< operator result)
    mov r10, r13                                                 ; type initialization of variable declaration for mask variable
    ; Line 68: Integer finalValue = newValue & ~mask | oldValue & mask;
    mov rbx, r14                                                 ; assign value of mask variable to value of ~ unary operator result
    not rbx                                                      ; ~ unary operator
    mov r15, 015h                                                ; ~ unary operator result is of type Integer'21
    mov r9, qword ptr [rsp + 038h]                               ; assign value of newValue variable to value of & operator result
    and r9, rbx                                                  ; compute (newValue variable) & (~ unary operator result)
    mov r8, 015h                                                 ; & operator result is of type Integer'21
    mov rdx, qword ptr [rsp + 018h]                              ; assign value of oldValue variable to value of & operator result
    and rdx, r14                                                 ; compute (oldValue variable) & (mask variable)
    mov rsi, 015h                                                ; & operator result is of type Integer'21
    mov rax, r9                                                  ; assign value of & operator result to value of | operator result
    or rax, rdx                                                  ; compute (& operator result) | (& operator result)
    mov rdi, 015h                                                ; | operator result is of type Integer'21
    mov rcx, rax                                                 ; value initialization of variable declaration for finalValue variable (| operator result)
    mov r12, rdi                                                 ; type initialization of variable declaration for finalValue variable
    ; Line 69: __writeToAddress(toCursor, finalValue);
    ; Call __writeToAddress with 2 arguments
    mov r13, qword ptr [rsp + 030h]                              ; get toCursor variable into register to dereference it
    mov qword ptr [r13], rcx                                     ; __writeToAddress
    mov rdx, qword ptr [rsp + 050h]                              ; restoring slots to previous scope state
    mov qword ptr [rsp + 050h], r13                              ; restoring slots to previous scope state
    mov rsi, qword ptr [rsp + 040h]                              ; restoring slots to previous scope state
  func$_moveBytes$if$continuation:                               ; end of if
  ; Implicit return from _moveBytes
  mov r14, qword ptr [rbp + 030h]                                ; get pointer to return value of _moveBytes into register to dereference it
  mov qword ptr [r14], 000h                                      ; _moveBytes return value
  mov r10, qword ptr [rbp + 028h]                                ; get pointer to return value type of _moveBytes into register to dereference it
  mov qword ptr [r10], 013h                                      ; type of _moveBytes return value (Null'19)
  jmp func$_moveBytes$epilog                                     ; return
  func$_moveBytes$epilog: 
  mov rax, qword ptr [rbp + 030h]                                ; report address of return value
  ; Epilog
  add rsp, 078h                                                  ; free space for stack
  pop r14                                                        ; restore non-volatile registers
  pop r13                                                        ; restore non-volatile registers
  pop r12                                                        ; restore non-volatile registers
  pop rbp                                                        ; restore non-volatile registers
  pop rdi                                                        ; restore non-volatile registers
  pop rsi                                                        ; restore non-volatile registers
  pop rbx                                                        ; restore non-volatile registers
  pop r15                                                        ; restore non-volatile registers
  ret                                                            ; return from subroutine

; _stringByteLength
func$_stringByteLength:
  ; Prolog
  push r15                                                       ; save non-volatile registers
  push rbx                                                       ; save non-volatile registers
  push rsi                                                       ; save non-volatile registers
  push rdi                                                       ; save non-volatile registers
  push rbp                                                       ; save non-volatile registers
  push r12                                                       ; save non-volatile registers
  push r13                                                       ; save non-volatile registers
  push r14                                                       ; save non-volatile registers
  sub rsp, 020h                                                  ; allocate space for stack
  lea rbp, qword ptr [rsp + 060h]                                ; set up frame pointer
  ; Check parameter count
  cmp rcx, 001h                                                  ; compare parameter count of _stringByteLength to 1 (integer)
  je func$_stringByteLength$parameterCountCheck$continuation     ; check number of parameters is as expected
    ; Error handling block for parameter count
    ;  - print(parameterCountCheckFailureMessage)
    ; Call __print with 1 arguments
    mov r10, offset parameterCountCheckFailureMessage            ; reading parameterCountCheckFailureMessage for push
    push r10                                                     ; value of argument #1 (parameterCountCheckFailureMessage)
    push 016h                                                    ; type of argument #1 (String'22)
    lea rax, qword ptr [rsp + 020h]                              ; load address of return value's value
    push rax                                                     ; internal argument 6: pointer to return value slot's value
    lea rax, qword ptr [rsp + 020h]                              ; load address of return value's type
    push rax                                                     ; internal argument 5: pointer to return value slot's type
    sub rsp, 020h                                                ; allocate shadow space
    mov r9, 000h                                                 ; internal argument 4: "this" pointer
    mov r8, 000h                                                 ; internal argument 3: "this" pointer type
    mov rdx, 000h                                                ; internal argument 2: closure pointer
    mov qword ptr [rsp + 040h], rcx                              ; move parameter count of _stringByteLength value out of rcx
    mov rcx, 001h                                                ; internal argument 1: number of actual arguments
    call func$__print                                            ; jump to subroutine
    add rsp, 040h                                                ; release shadow space and arguments (result in stack pointer)
    ;  - exit(1)
    ; Call exit with 1 arguments
    push 001h                                                    ; value of argument #1 (1 (integer))
    push 015h                                                    ; type of argument #1 (Integer'21)
    lea rbx, qword ptr [rsp + 020h]                              ; load address of return value's value
    push rbx                                                     ; internal argument 6: pointer to return value slot's value
    lea rbx, qword ptr [rsp + 020h]                              ; load address of return value's type
    push rbx                                                     ; internal argument 5: pointer to return value slot's type
    sub rsp, 020h                                                ; allocate shadow space
    mov r9, 000h                                                 ; internal argument 4: "this" pointer
    mov r8, 000h                                                 ; internal argument 3: "this" pointer type
    mov rdx, 000h                                                ; internal argument 2: closure pointer
    mov rcx, 001h                                                ; internal argument 1: number of actual arguments
    call func$exit                                               ; jump to subroutine
    add rsp, 040h                                                ; release shadow space and arguments (result in stack pointer)
    mov rcx, qword ptr [rsp + 000h]                              ; restoring slots to previous scope state
  func$_stringByteLength$parameterCountCheck$continuation:       ; end of parameter count check
  ; Check type of parameter 0, data (expecting String)
  mov rsi, qword ptr [rbp + 038h]                                ; move type of data to testByte
  mov rax, rsi                                                   ; move testByte to testByte
  mov rdi, 001h                                                  ; read operand of mul (type table width in bytes) 
  mul rdi                                                        ; adjust to the relative start of that type's entry in the type table
  add rax, 000h                                                  ; adjust to the byte containing the bit to check against (result in testByte)
  mov r12, offset typeTable                                      ; read second operand of + (type table pointer)
  add rax, r12                                                   ; finally offset all of that by the start of the type table itself (result in testByte)
  bt qword ptr [rax], 003h                                       ; check that data is String
  jc func$_stringByteLength$data$TypeMatch                       ; skip next block if the type matches
    ; Error handling block for data
    ;  - print(parameterTypeCheckFailureMessage)
    ; Call __print with 1 arguments
    mov r13, offset parameterTypeCheckFailureMessage             ; reading parameterTypeCheckFailureMessage for push
    push r13                                                     ; value of argument #1 (parameterTypeCheckFailureMessage)
    push 016h                                                    ; type of argument #1 (String'22)
    lea r14, qword ptr [rsp + 020h]                              ; load address of return value's value
    push r14                                                     ; internal argument 6: pointer to return value slot's value
    lea r14, qword ptr [rsp + 020h]                              ; load address of return value's type
    push r14                                                     ; internal argument 5: pointer to return value slot's type
    sub rsp, 020h                                                ; allocate shadow space
    mov r9, 000h                                                 ; internal argument 4: "this" pointer
    mov r8, 000h                                                 ; internal argument 3: "this" pointer type
    mov rdx, 000h                                                ; internal argument 2: closure pointer
    mov qword ptr [rsp + 040h], rcx                              ; move parameter count of _stringByteLength value out of rcx
    mov rcx, 001h                                                ; internal argument 1: number of actual arguments
    call func$__print                                            ; jump to subroutine
    add rsp, 040h                                                ; release shadow space and arguments (result in stack pointer)
    ;  - exit(1)
    ; Call exit with 1 arguments
    push 001h                                                    ; value of argument #1 (1 (integer))
    push 015h                                                    ; type of argument #1 (Integer'21)
    lea r15, qword ptr [rsp + 020h]                              ; load address of return value's value
    push r15                                                     ; internal argument 6: pointer to return value slot's value
    lea r15, qword ptr [rsp + 020h]                              ; load address of return value's type
    push r15                                                     ; internal argument 5: pointer to return value slot's type
    sub rsp, 020h                                                ; allocate shadow space
    mov r9, 000h                                                 ; internal argument 4: "this" pointer
    mov r8, 000h                                                 ; internal argument 3: "this" pointer type
    mov rdx, 000h                                                ; internal argument 2: closure pointer
    mov rcx, 001h                                                ; internal argument 1: number of actual arguments
    call func$exit                                               ; jump to subroutine
    add rsp, 040h                                                ; release shadow space and arguments (result in stack pointer)
    mov rcx, qword ptr [rsp + 000h]                              ; restoring slots to previous scope state
  func$_stringByteLength$data$TypeMatch:                         ; after block
  ; Line 74: Integer pointer = data __as__ Integer;
  mov r10, qword ptr [rbp + 040h]                                ; force cast of data to Integer
  mov rbx, 015h                                                  ; force cast of data to Integer is of type Integer'21
  mov rsi, r10                                                   ; value initialization of variable declaration for pointer variable (force cast of data to Integer)
  mov rax, rbx                                                   ; type initialization of variable declaration for pointer variable
  ; Line 75: return __readFromAddress(pointer + 8);
  mov rdi, rsi                                                   ; assign value of pointer variable to value of + operator result
  add rdi, 008h                                                  ; compute (pointer variable) + (8) (result in + operator result)
  mov r12, 015h                                                  ; + operator result is of type Integer'21
  ; Call __readFromAddress with 1 arguments
  mov r13, qword ptr [rdi]                                       ; dereference first argument of __readFromAddress
  mov r14, 015h                                                  ; dereferenced + operator result is of type Integer'21
  mov r15, qword ptr [rbp + 030h]                                ; get pointer to return value of _stringByteLength into register to dereference it
  mov qword ptr [r15], r13                                       ; _stringByteLength return value
  mov r9, qword ptr [rbp + 028h]                                 ; get pointer to return value type of _stringByteLength into register to dereference it
  mov qword ptr [r9], r14                                        ; type of _stringByteLength return value
  jmp func$_stringByteLength$epilog                              ; return
  func$_stringByteLength$epilog: 
  mov rax, qword ptr [rbp + 030h]                                ; report address of return value
  ; Epilog
  add rsp, 020h                                                  ; free space for stack
  pop r14                                                        ; restore non-volatile registers
  pop r13                                                        ; restore non-volatile registers
  pop r12                                                        ; restore non-volatile registers
  pop rbp                                                        ; restore non-volatile registers
  pop rdi                                                        ; restore non-volatile registers
  pop rsi                                                        ; restore non-volatile registers
  pop rbx                                                        ; restore non-volatile registers
  pop r15                                                        ; restore non-volatile registers
  ret                                                            ; return from subroutine

; concat
func$concat:
  ; Prolog
  push r15                                                       ; save non-volatile registers
  push rbx                                                       ; save non-volatile registers
  push rsi                                                       ; save non-volatile registers
  push rdi                                                       ; save non-volatile registers
  push rbp                                                       ; save non-volatile registers
  push r12                                                       ; save non-volatile registers
  push r13                                                       ; save non-volatile registers
  push r14                                                       ; save non-volatile registers
  sub rsp, 070h                                                  ; allocate space for stack
  lea rbp, qword ptr [rsp + 0b0h]                                ; set up frame pointer
  ; Varargs parameter type check; expecting parameters to be String
  lea r10, qword ptr [rbp + 040h]                                ; get base address of varargs, where loop will start
  mov rax, rcx                                                   ; assign value of parameter count of concat to value of pointer to last argument
  mov rbx, 010h                                                  ; read operand of mul (10 (integer)) 
  mul rbx                                                        ; end of loop is the number of arguments times the width of each argument (010h)...
  add rax, r10                                                   ; ...offset from the initial index (result in pointer to last argument)
  func$concat$varargTypeChecks$Loop:                             ; top of loop
    mov qword ptr [rsp + 060h], 000h                             ; move pointer to indexth argument type into a mutable location
    cmp r10, rax                                                 ; compare pointer to indexth argument to pointer to last argument
    je func$concat$varargTypeChecks$TypesAllMatch                ; we have type-checked all the arguments
    mov rsi, qword ptr [r10 - 008h]                              ; load type of indexth argument into indexth argument
    mov rdi, rsi                                                 ; move type of indexth argument to testByte
    mov qword ptr [rsp + 058h], rax                              ; move pointer to last argument value out of rax
    mov rax, rdi                                                 ; move testByte to testByte
    mov r12, 001h                                                ; read operand of mul (type table width in bytes) 
    mul r12                                                      ; adjust to the relative start of that type's entry in the type table
    add rax, 000h                                                ; adjust to the byte containing the bit to check against (result in testByte)
    mov r13, offset typeTable                                    ; read second operand of + (type table pointer)
    add rax, r13                                                 ; finally offset all of that by the start of the type table itself (result in testByte)
    bt qword ptr [rax], 003h                                     ; check that vararg types is String
    jc func$concat$varargTypeChecks$TypeMatch                    ; skip next block if the type matches
      ; Error handling block for vararg types
      ;  - print(parameterTypeCheckFailureMessage)
      ; Call __print with 1 arguments
      mov r14, offset parameterTypeCheckFailureMessage           ; reading parameterTypeCheckFailureMessage for push
      push r14                                                   ; value of argument #1 (parameterTypeCheckFailureMessage)
      push 016h                                                  ; type of argument #1 (String'22)
      lea r15, qword ptr [rsp + 060h]                            ; load address of return value's value
      push r15                                                   ; internal argument 6: pointer to return value slot's value
      lea r15, qword ptr [rsp + 060h]                            ; load address of return value's type
      push r15                                                   ; internal argument 5: pointer to return value slot's type
      sub rsp, 020h                                              ; allocate shadow space
      mov r9, 000h                                               ; internal argument 4: "this" pointer
      mov r8, 000h                                               ; internal argument 3: "this" pointer type
      mov rdx, 000h                                              ; internal argument 2: closure pointer
      mov qword ptr [rsp + 080h], rcx                            ; move parameter count of concat value out of rcx
      mov rcx, 001h                                              ; internal argument 1: number of actual arguments
      mov qword ptr [rsp + 078h], r10                            ; move pointer to indexth argument value out of r10
      call func$__print                                          ; jump to subroutine
      add rsp, 040h                                              ; release shadow space and arguments (result in stack pointer)
      ;  - exit(1)
      ; Call exit with 1 arguments
      push 001h                                                  ; value of argument #1 (1 (integer))
      push 015h                                                  ; type of argument #1 (Integer'21)
      lea r10, qword ptr [rsp + 060h]                            ; load address of return value's value
      push r10                                                   ; internal argument 6: pointer to return value slot's value
      lea r10, qword ptr [rsp + 060h]                            ; load address of return value's type
      push r10                                                   ; internal argument 5: pointer to return value slot's type
      sub rsp, 020h                                              ; allocate shadow space
      mov r9, 000h                                               ; internal argument 4: "this" pointer
      mov r8, 000h                                               ; internal argument 3: "this" pointer type
      mov rdx, 000h                                              ; internal argument 2: closure pointer
      mov rcx, 001h                                              ; internal argument 1: number of actual arguments
      call func$exit                                             ; jump to subroutine
      add rsp, 040h                                              ; release shadow space and arguments (result in stack pointer)
      mov r10, qword ptr [rsp + 038h]                            ; restoring slots to previous scope state
      mov rcx, qword ptr [rsp + 040h]                            ; restoring slots to previous scope state
    func$concat$varargTypeChecks$TypeMatch:                      ; after block
    add r10, 010h                                                ; next argument (result in pointer to indexth argument)
    mov rax, qword ptr [rsp + 058h]                              ; restoring slots to previous scope state
    jmp func$concat$varargTypeChecks$Loop                        ; return to top of loop
    func$concat$varargTypeChecks$TypesAllMatch:                  ; after loop
    mov rax, qword ptr [rsp + 058h]                              ; restoring slots to previous scope state
  ; Line 79: Integer length = 0;
  mov rbx, 000h                                                  ; value initialization of variable declaration for length variable (0)
  mov rsi, 015h                                                  ; type initialization of variable declaration for length variable (Integer'21)
  ; Line 80: Integer index = 0;
  mov rdi, 000h                                                  ; value initialization of variable declaration for index variable (0)
  mov rax, 015h                                                  ; type initialization of variable declaration for index variable (Integer'21)
  func$concat$while$top:                                         ; top of while
    ; Call len with 1 arguments
    xor r12, r12                                                 ; clear < operator result
    cmp rdi, rcx                                                 ; compare index variable with parameter count of concat
    setl r12b                                                    ; store result in < operator result
    mov r13, 014h                                                ; < operator result is of type Boolean'20
    cmp r12, 000h                                                ; compare < operator result to false
    jne func$concat$while$body                                   ; while condition
    jmp func$concat$while$bottom                                 ; break out of while
    func$concat$while$body:                                      ; start of while
    ; Line 82: length += _stringByteLength(arguments[index]);
    cmp rdi, rcx                                                 ; compare index variable to parameter count of concat
    jge func$concat$while$subscript$boundsError                  ; index out of range (too high)
    cmp rdi, 000h                                                ; compare index variable to 0 (integer)
    jge func$concat$while$subscript$inBounds                     ; index not out of range (not negative)
    func$concat$while$subscript$boundsError:                     ; invalid index
      ; Error handling block for subscript bounds error
      ;  - print(boundsFailureMessage)
      ; Call __print with 1 arguments
      mov r14, offset boundsFailureMessage                       ; reading boundsFailureMessage for push
      push r14                                                   ; value of argument #1 (boundsFailureMessage)
      push 016h                                                  ; type of argument #1 (String'22)
      lea r15, qword ptr [rsp + 070h]                            ; load address of return value's value
      push r15                                                   ; internal argument 6: pointer to return value slot's value
      lea r15, qword ptr [rsp + 070h]                            ; load address of return value's type
      push r15                                                   ; internal argument 5: pointer to return value slot's type
      sub rsp, 020h                                              ; allocate shadow space
      mov r9, 000h                                               ; internal argument 4: "this" pointer
      mov r8, 000h                                               ; internal argument 3: "this" pointer type
      mov rdx, 000h                                              ; internal argument 2: closure pointer
      mov qword ptr [rsp + 090h], rcx                            ; move parameter count of concat value out of rcx
      mov rcx, 001h                                              ; internal argument 1: number of actual arguments
      mov qword ptr [rsp + 088h], rax                            ; move index variable type out of rax
      call func$__print                                          ; jump to subroutine
      add rsp, 040h                                              ; release shadow space and arguments (result in stack pointer)
      ;  - exit(1)
      ; Call exit with 1 arguments
      push 001h                                                  ; value of argument #1 (1 (integer))
      push 015h                                                  ; type of argument #1 (Integer'21)
      lea r10, qword ptr [rsp + 070h]                            ; load address of return value's value
      push r10                                                   ; internal argument 6: pointer to return value slot's value
      lea r10, qword ptr [rsp + 070h]                            ; load address of return value's type
      push r10                                                   ; internal argument 5: pointer to return value slot's type
      sub rsp, 020h                                              ; allocate shadow space
      mov r9, 000h                                               ; internal argument 4: "this" pointer
      mov r8, 000h                                               ; internal argument 3: "this" pointer type
      mov rdx, 000h                                              ; internal argument 2: closure pointer
      mov rcx, 001h                                              ; internal argument 1: number of actual arguments
      call func$exit                                             ; jump to subroutine
      add rsp, 040h                                              ; release shadow space and arguments (result in stack pointer)
      mov rax, qword ptr [rsp + 048h]                            ; restoring slots to previous scope state
      mov rcx, qword ptr [rsp + 050h]                            ; restoring slots to previous scope state
    func$concat$while$subscript$inBounds:                        ; valid index
    mov qword ptr [rsp + 060h], rbx                              ; move length variable value out of rbx
    lea rbx, qword ptr [rbp + 040h]                              ; base address of varargs
    mov qword ptr [rsp + 058h], rsi                              ; move length variable type out of rsi
    mov rsi, rdi                                                 ; assign value of index variable to value of index into list * 16
    shl rsi, 004h                                                ; multiply by 8*2
    mov qword ptr [rsp + 050h], rdi                              ; move index variable value out of rdi
    mov rdi, rbx                                                 ; assign value of base address of varargs to value of pointer to value (and type, later)
    add rdi, rsi                                                 ; get pointer to value (result in pointer to value (and type, later))
    mov qword ptr [rsp + 048h], rax                              ; move index variable type out of rax
    mov rax, qword ptr [rdi]                                     ; store value
    mov r12, qword ptr [rdi - 008h]                              ; store type
    ; increment reference count for arguments[index] if necessary
    cmp r12, 016h                                                ; if not a string, skip incref
    jne func$concat$while$AfterIncref
    mov r13, qword ptr [rax]                                     ; dereference string to get to ref count
    cmp r13, 0                                                   ; compare string refcount temporary to 0
    js func$concat$while$AfterIncref                             ; if ref count is negative (constant strings), skip incref
    add r13, 001h                                                ; increment ref count (result in string refcount temporary)
    mov qword ptr [rax], r13                                     ; put it back in the string
    func$concat$while$AfterIncref:                               ; after incref
    ; Call _stringByteLength with 1 arguments
    push rax                                                     ; value of argument #1 (arguments[index])
    push r12                                                     ; type of argument #1
    lea r14, qword ptr [rsp + 050h]                              ; load address of return value's value
    push r14                                                     ; internal argument 6: pointer to return value slot's value
    lea r14, qword ptr [rsp + 050h]                              ; load address of return value's type
    push r14                                                     ; internal argument 5: pointer to return value slot's type
    sub rsp, 020h                                                ; allocate shadow space
    mov r9, 000h                                                 ; internal argument 4: "this" pointer
    mov r8, 000h                                                 ; internal argument 3: "this" pointer type
    mov rdx, 000h                                                ; internal argument 2: closure pointer
    mov qword ptr [rsp + 070h], rcx                              ; move parameter count of concat value out of rcx
    mov rcx, 001h                                                ; internal argument 1: number of actual arguments
    mov qword ptr [rsp + 068h], rax                              ; move arguments[index] value out of rax
    call func$_stringByteLength                                  ; jump to subroutine
    add rsp, 040h                                                ; release shadow space and arguments (result in stack pointer)
    mov r15, qword ptr [rsp + 060h]                              ; assign value of length variable to value of += operator result
    add r15, qword ptr [rsp + 040h]                              ; += operator
    mov r10, 015h                                                ; += operator result is of type Integer'21
    mov qword ptr [rsp + 060h], r15                              ; store value
    mov qword ptr [rsp + 058h], r10                              ; store type
    ; Line 83: index += 1;
    mov rbx, qword ptr [rsp + 050h]                              ; assign value of index variable to value of += operator result
    add rbx, 001h                                                ; += operator
    mov rsi, 015h                                                ; += operator result is of type Integer'21
    mov qword ptr [rsp + 050h], rbx                              ; store value
    mov qword ptr [rsp + 048h], rsi                              ; store type
    ; Calling decref on arguments[index] (static type: String'22)
    sub rsp, 20h                                                 ; allocate shadow space for decref
    mov rdx, r12                                                 ; arg #2: type of potential string
    mov rcx, qword ptr [rsp + 048h]                              ; arg #1: value of potential string
    call intrinsic$decref                                        ; call decref
    add rsp, 20h                                                 ; free shadow space for decref
    mov rax, qword ptr [rsp + 048h]                              ; restoring slots to previous scope state
    mov rbx, qword ptr [rsp + 060h]                              ; restoring slots to previous scope state
    mov rcx, qword ptr [rsp + 030h]                              ; restoring slots to previous scope state
    mov rsi, qword ptr [rsp + 058h]                              ; restoring slots to previous scope state
    mov rdi, qword ptr [rsp + 050h]                              ; restoring slots to previous scope state
    jmp func$concat$while$top                                    ; return to top of while
  func$concat$while$bottom:                                      ; bottom of while
  ; Line 85: Integer resultPointer = _alloc(16 /* 0x10 */ + length);
  mov qword ptr [rsp + 060h], rdi                                ; move index variable value out of rdi
  mov rdi, 010h                                                  ; assign value of 16 /* 0x10 */ to value of + operator result
  add rdi, rbx                                                   ; compute (16 /* 0x10 */) + (length variable) (result in + operator result)
  mov qword ptr [rsp + 058h], rax                                ; move index variable type out of rax
  mov rax, 015h                                                  ; + operator result is of type Integer'21
  ; Call _alloc with 1 arguments
  push rdi                                                       ; value of argument #1 (+ operator result)
  push rax                                                       ; type of argument #1
  lea r12, qword ptr [rsp + 060h]                                ; load address of return value's value
  push r12                                                       ; internal argument 6: pointer to return value slot's value
  lea r12, qword ptr [rsp + 060h]                                ; load address of return value's type
  push r12                                                       ; internal argument 5: pointer to return value slot's type
  sub rsp, 020h                                                  ; allocate shadow space
  mov r9, 000h                                                   ; internal argument 4: "this" pointer
  mov r8, 000h                                                   ; internal argument 3: "this" pointer type
  mov rdx, 000h                                                  ; internal argument 2: closure pointer
  mov qword ptr [rsp + 080h], rcx                                ; move parameter count of concat value out of rcx
  mov rcx, 001h                                                  ; internal argument 1: number of actual arguments
  call func$_alloc                                               ; jump to subroutine
  add rsp, 040h                                                  ; release shadow space and arguments (result in stack pointer)
  mov r13, qword ptr [rsp + 050h]                                ; value initialization of variable declaration for resultPointer variable (_alloc return value)
  mov r14, qword ptr [rsp + 048h]                                ; type initialization of variable declaration for resultPointer variable
  ; Line 86: __writeToAddress(resultPointer, 1);
  ; Call __writeToAddress with 2 arguments
  mov qword ptr [r13], 001h                                      ; __writeToAddress
  ; Line 87: __writeToAddress(resultPointer + 8, length);
  mov r15, r13                                                   ; assign value of resultPointer variable to value of + operator result
  add r15, 008h                                                  ; compute (resultPointer variable) + (8) (result in + operator result)
  mov r10, 015h                                                  ; + operator result is of type Integer'21
  ; Call __writeToAddress with 2 arguments
  mov qword ptr [r15], rbx                                       ; __writeToAddress
  ; Line 88: Integer cursor = resultPointer + 16 /* 0x10 */;
  mov rbx, r13                                                   ; assign value of resultPointer variable to value of + operator result
  add rbx, 010h                                                  ; compute (resultPointer variable) + (16 /* 0x10 */) (result in + operator result)
  mov rsi, 015h                                                  ; + operator result is of type Integer'21
  mov rdi, rbx                                                   ; value initialization of variable declaration for cursor variable (+ operator result)
  mov rax, rsi                                                   ; type initialization of variable declaration for cursor variable
  ; Line 89: index = 0;
  mov qword ptr [rsp + 060h], 000h                               ; store value
  mov qword ptr [rsp + 058h], 015h                               ; store type (Integer'21)
  func$concat$while$top$1:                                       ; top of while
    ; Call len with 1 arguments
    mov r12, qword ptr [rsp + 040h]                              ; reading second value to compare (<DynamicSlot:Integer'21 at [rcx, stack operand #5, stack operand #5]/[015h, 015h, 015h] ("parameter count of concat") (living: true)>)
    xor r9, r9                                                   ; clear < operator result
    cmp qword ptr [rsp + 060h], r12                              ; compare index variable with parameter count of concat
    setl r9b                                                     ; store result in < operator result
    mov r8, 014h                                                 ; < operator result is of type Boolean'20
    cmp r9, 000h                                                 ; compare < operator result to false
    jne func$concat$while$body$1                                 ; while condition
    mov qword ptr [rsp + 040h], r12                              ; restoring slots to previous scope state
    jmp func$concat$while$bottom$1                               ; break out of while
    func$concat$while$body$1:                                    ; start of while
    ; Line 91: String segment = arguments[index];
    cmp qword ptr [rsp + 060h], r12                              ; compare index variable to parameter count of concat
    jge func$concat$while$subscript$boundsError$1                ; index out of range (too high)
    cmp qword ptr [rsp + 060h], 000h                             ; compare index variable to 0 (integer)
    jge func$concat$while$subscript$inBounds$1                   ; index not out of range (not negative)
    func$concat$while$subscript$boundsError$1:                   ; invalid index
      ; Error handling block for subscript bounds error
      ;  - print(boundsFailureMessage)
      ; Call __print with 1 arguments
      mov rdx, offset boundsFailureMessage                       ; reading boundsFailureMessage for push
      push rdx                                                   ; value of argument #1 (boundsFailureMessage)
      push 016h                                                  ; type of argument #1 (String'22)
      lea rcx, qword ptr [rsp + 060h]                            ; load address of return value's value
      push rcx                                                   ; internal argument 6: pointer to return value slot's value
      lea rcx, qword ptr [rsp + 060h]                            ; load address of return value's type
      push rcx                                                   ; internal argument 5: pointer to return value slot's type
      sub rsp, 020h                                              ; allocate shadow space
      mov r9, 000h                                               ; internal argument 4: "this" pointer
      mov r8, 000h                                               ; internal argument 3: "this" pointer type
      mov rdx, 000h                                              ; internal argument 2: closure pointer
      mov rcx, 001h                                              ; internal argument 1: number of actual arguments
      mov qword ptr [rsp + 080h], rax                            ; move cursor variable type out of rax
      call func$__print                                          ; jump to subroutine
      add rsp, 040h                                              ; release shadow space and arguments (result in stack pointer)
      ;  - exit(1)
      ; Call exit with 1 arguments
      push 001h                                                  ; value of argument #1 (1 (integer))
      push 015h                                                  ; type of argument #1 (Integer'21)
      mov qword ptr [rsp + 058h], r13                            ; move resultPointer variable value out of r13
      lea r13, qword ptr [rsp + 060h]                            ; load address of return value's value
      push r13                                                   ; internal argument 6: pointer to return value slot's value
      lea r13, qword ptr [rsp + 050h]                            ; load address of return value's type
      push r13                                                   ; internal argument 5: pointer to return value slot's type
      sub rsp, 020h                                              ; allocate shadow space
      mov r9, 000h                                               ; internal argument 4: "this" pointer
      mov r8, 000h                                               ; internal argument 3: "this" pointer type
      mov rdx, 000h                                              ; internal argument 2: closure pointer
      mov rcx, 001h                                              ; internal argument 1: number of actual arguments
      call func$exit                                             ; jump to subroutine
      add rsp, 040h                                              ; release shadow space and arguments (result in stack pointer)
      mov rax, qword ptr [rsp + 040h]                            ; restoring slots to previous scope state
      mov r13, qword ptr [rsp + 048h]                            ; restoring slots to previous scope state
    func$concat$while$subscript$inBounds$1:                      ; valid index
    mov qword ptr [rsp + 050h], r14                              ; move resultPointer variable type out of r14
    lea r14, qword ptr [rbp + 040h]                              ; base address of varargs
    mov r15, qword ptr [rsp + 060h]                              ; assign value of index variable to value of index into list * 16
    shl r15, 004h                                                ; multiply by 8*2
    mov r10, r14                                                 ; assign value of base address of varargs to value of pointer to value (and type, later)
    add r10, r15                                                 ; get pointer to value (result in pointer to value (and type, later))
    mov rbx, qword ptr [r10]                                     ; store value
    mov rsi, qword ptr [r10 - 008h]                              ; store type
    ; increment reference count for arguments[index] if necessary
    cmp rsi, 016h                                                ; if not a string, skip incref
    jne func$concat$while$AfterIncref$1
    mov qword ptr [rsp + 048h], rdi                              ; move cursor variable value out of rdi
    mov rdi, qword ptr [rbx]                                     ; dereference string to get to ref count
    cmp rdi, 0                                                   ; compare string refcount temporary to 0
    js func$concat$while$AfterIncref$1                           ; if ref count is negative (constant strings), skip incref
    add rdi, 001h                                                ; increment ref count (result in string refcount temporary)
    mov qword ptr [rbx], rdi                                     ; put it back in the string
    func$concat$while$AfterIncref$1:                             ; after incref
    mov qword ptr [rsp + 040h], rax                              ; move cursor variable type out of rax
    mov rax, rbx                                                 ; value initialization of variable declaration for segment variable (arguments[index])
    mov qword ptr [rsp + 038h], r12                              ; move parameter count of concat value out of r12
    mov r12, rsi                                                 ; type initialization of variable declaration for segment variable
    ; increment reference count for segment variable if necessary
    cmp r12, 016h                                                ; if not a string, skip incref
    jne func$concat$while$AfterIncref$2
    mov qword ptr [rsp + 030h], r13                              ; move resultPointer variable value out of r13
    mov r13, qword ptr [rax]                                     ; dereference string to get to ref count
    cmp r13, 0                                                   ; compare string refcount temporary to 0
    js func$concat$while$AfterIncref$2                           ; if ref count is negative (constant strings), skip incref
    add r13, 001h                                                ; increment ref count (result in string refcount temporary)
    mov qword ptr [rax], r13                                     ; put it back in the string
    func$concat$while$AfterIncref$2:                             ; after incref
    ; Line 92: Integer segmentLength = _stringByteLength(segment);
    ; Call _stringByteLength with 1 arguments
    push rax                                                     ; value of argument #1 (segment variable)
    push r12                                                     ; type of argument #1
    lea r9, qword ptr [rsp + 038h]                               ; load address of return value's value
    push r9                                                      ; internal argument 6: pointer to return value slot's value
    lea r9, qword ptr [rsp + 038h]                               ; load address of return value's type
    push r9                                                      ; internal argument 5: pointer to return value slot's type
    sub rsp, 020h                                                ; allocate shadow space
    mov r9, 000h                                                 ; internal argument 4: "this" pointer
    mov r8, 000h                                                 ; internal argument 3: "this" pointer type
    mov rdx, 000h                                                ; internal argument 2: closure pointer
    mov rcx, 001h                                                ; internal argument 1: number of actual arguments
    mov qword ptr [rsp + 058h], rax                              ; move segment variable value out of rax
    call func$_stringByteLength                                  ; jump to subroutine
    add rsp, 040h                                                ; release shadow space and arguments (result in stack pointer)
    mov r14, qword ptr [rsp + 028h]                              ; value initialization of variable declaration for segmentLength variable (_stringByteLength return value)
    mov r15, qword ptr [rsp + 020h]                              ; type initialization of variable declaration for segmentLength variable
    ; Line 93: if (segmentLength > 0) { ...
    xor r10, r10                                                 ; clear > operator result
    cmp r14, 000h                                                ; compare segmentLength variable with 0
    setg r10b                                                    ; store result in > operator result
    mov qword ptr [rsp + 028h], rbx                              ; move arguments[index] value out of rbx
    mov rbx, 014h                                                ; > operator result is of type Boolean'20
    cmp r10, 000h                                                ; compare > operator result to false
    je func$concat$while$if$continuation                         ; segmentLength > 0
      ; Line 94: Integer segmentPointer = segment __as__ Integer;
      mov qword ptr [rsp + 020h], rsi                            ; move arguments[index] type out of rsi
      mov rsi, qword ptr [rsp + 018h]                            ; force cast of segment variable to Integer
      mov rdi, 015h                                              ; force cast of segment variable to Integer is of type Integer'21
      mov rax, rsi                                               ; value initialization of variable declaration for segmentPointer variable (force cast of segment variable to Integer)
      mov qword ptr [rsp + 010h], r12                            ; move segment variable type out of r12
      mov r12, rdi                                               ; type initialization of variable declaration for segmentPointer variable
      ; Line 95: _moveBytes(segmentPointer + 16 /* 0x10 */, cursor, segmentLength...
      mov r13, rax                                               ; assign value of segmentPointer variable to value of + operator result
      add r13, 010h                                              ; compute (segmentPointer variable) + (16 /* 0x10 */) (result in + operator result)
      mov r9, 015h                                               ; + operator result is of type Integer'21
      ; Call _moveBytes with 3 arguments
      push r14                                                   ; value of argument #3 (segmentLength variable)
      push r15                                                   ; type of argument #3
      push qword ptr [rsp + 058h]                                ; value of argument #2 (cursor variable)
      push qword ptr [rsp + 058h]                                ; type of argument #2
      push r13                                                   ; value of argument #1 (+ operator result)
      push r9                                                    ; type of argument #1
      lea r8, qword ptr [rsp + 038h]                             ; load address of return value's value
      push r8                                                    ; internal argument 6: pointer to return value slot's value
      lea r8, qword ptr [rsp + 038h]                             ; load address of return value's type
      push r8                                                    ; internal argument 5: pointer to return value slot's type
      sub rsp, 020h                                              ; allocate shadow space
      mov r9, 000h                                               ; internal argument 4: "this" pointer
      mov r8, 000h                                               ; internal argument 3: "this" pointer type
      mov rdx, 000h                                              ; internal argument 2: closure pointer
      mov rcx, 003h                                              ; internal argument 1: number of actual arguments
      call func$_moveBytes                                       ; jump to subroutine
      add rsp, 060h                                              ; release shadow space and arguments (result in stack pointer)
      ; Line 96: cursor += segmentLength;
      mov qword ptr [rsp + 008h], r14                            ; move segmentLength variable value out of r14
      mov r14, qword ptr [rsp + 048h]                            ; assign value of cursor variable to value of += operator result
      add r14, qword ptr [rsp + 008h]                            ; += operator
      mov qword ptr [rsp + 000h], r15                            ; move segmentLength variable type out of r15
      mov r15, 015h                                              ; += operator result is of type Integer'21
      mov qword ptr [rsp + 048h], r14                            ; store value
      mov qword ptr [rsp + 040h], r15                            ; store type
      mov r14, qword ptr [rsp + 008h]                            ; restoring slots to previous scope state
      mov r15, qword ptr [rsp + 000h]                            ; restoring slots to previous scope state
      mov rsi, qword ptr [rsp + 020h]                            ; restoring slots to previous scope state
      mov r12, qword ptr [rsp + 010h]                            ; restoring slots to previous scope state
    func$concat$while$if$continuation:                           ; end of if
    ; Line 98: index += 1;
    mov r10, qword ptr [rsp + 060h]                              ; assign value of index variable to value of += operator result
    add r10, 001h                                                ; += operator
    mov rbx, 015h                                                ; += operator result is of type Integer'21
    mov qword ptr [rsp + 060h], r10                              ; store value
    mov qword ptr [rsp + 058h], rbx                              ; store type
    ; Calling decref on segment variable (static type: String'22)
    sub rsp, 20h                                                 ; allocate shadow space for decref
    mov rdx, r12                                                 ; arg #2: type of potential string
    mov rcx, qword ptr [rsp + 038h]                              ; arg #1: value of potential string
    call intrinsic$decref                                        ; call decref
    add rsp, 20h                                                 ; free shadow space for decref
    ; Calling decref on arguments[index] (static type: String'22)
    sub rsp, 20h                                                 ; allocate shadow space for decref
    mov rdx, rsi                                                 ; arg #2: type of potential string
    mov rcx, qword ptr [rsp + 048h]                              ; arg #1: value of potential string
    call intrinsic$decref                                        ; call decref
    add rsp, 20h                                                 ; free shadow space for decref
    mov rax, qword ptr [rsp + 040h]                              ; restoring slots to previous scope state
    mov r11, qword ptr [rsp + 038h]                              ; indirect through r11 because operand pair (stack operand #5, stack operand #6) is not allowed with mov
    mov qword ptr [rsp + 040h], r11                              ; restoring slots to previous scope state
    mov rdi, qword ptr [rsp + 048h]                              ; restoring slots to previous scope state
    mov r13, qword ptr [rsp + 030h]                              ; restoring slots to previous scope state
    mov r14, qword ptr [rsp + 050h]                              ; restoring slots to previous scope state
    jmp func$concat$while$top$1                                  ; return to top of while
  func$concat$while$bottom$1:                                    ; bottom of while
  ; Line 100: return resultPointer __as__ String;
  mov rsi, r13                                                   ; force cast of resultPointer variable to String
  mov rdi, 016h                                                  ; force cast of resultPointer variable to String is of type String'22
  mov rax, qword ptr [rbp + 030h]                                ; get pointer to return value of concat into register to dereference it
  mov qword ptr [rax], rsi                                       ; concat return value
  mov r12, qword ptr [rbp + 028h]                                ; get pointer to return value type of concat into register to dereference it
  mov qword ptr [r12], rdi                                       ; type of concat return value
  ; increment reference count for force cast of resultPointer variable to String if necessary
  cmp rdi, 016h                                                  ; if not a string, skip incref
  jne func$concat$AfterIncref
  mov r13, qword ptr [rsi]                                       ; dereference string to get to ref count
  cmp r13, 0                                                     ; compare string refcount temporary to 0
  js func$concat$AfterIncref                                     ; if ref count is negative (constant strings), skip incref
  add r13, 001h                                                  ; increment ref count (result in string refcount temporary)
  mov qword ptr [rsi], r13                                       ; put it back in the string
  func$concat$AfterIncref:                                       ; after incref
  ; Calling decref on force cast of resultPointer variable to String (static type: String'22)
  sub rsp, 20h                                                   ; allocate shadow space for decref
  mov rdx, rdi                                                   ; arg #2: type of potential string
  mov rcx, rsi                                                   ; arg #1: value of potential string
  call intrinsic$decref                                          ; call decref
  add rsp, 20h                                                   ; free shadow space for decref
  jmp func$concat$epilog                                         ; return
  func$concat$epilog: 
  mov rax, qword ptr [rbp + 030h]                                ; report address of return value
  ; Epilog
  add rsp, 070h                                                  ; free space for stack
  pop r14                                                        ; restore non-volatile registers
  pop r13                                                        ; restore non-volatile registers
  pop r12                                                        ; restore non-volatile registers
  pop rbp                                                        ; restore non-volatile registers
  pop rdi                                                        ; restore non-volatile registers
  pop rsi                                                        ; restore non-volatile registers
  pop rbx                                                        ; restore non-volatile registers
  pop r15                                                        ; restore non-volatile registers
  ret                                                            ; return from subroutine

; digitToStr
func$digitToStr:
  ; Prolog
  push r15                                                       ; save non-volatile registers
  push rbx                                                       ; save non-volatile registers
  push rsi                                                       ; save non-volatile registers
  push rdi                                                       ; save non-volatile registers
  push rbp                                                       ; save non-volatile registers
  push r12                                                       ; save non-volatile registers
  push r13                                                       ; save non-volatile registers
  push r14                                                       ; save non-volatile registers
  sub rsp, 020h                                                  ; allocate space for stack
  lea rbp, qword ptr [rsp + 060h]                                ; set up frame pointer
  ; Check parameter count
  cmp rcx, 001h                                                  ; compare parameter count of digitToStr to 1 (integer)
  je func$digitToStr$parameterCountCheck$continuation            ; check number of parameters is as expected
    ; Error handling block for parameter count
    ;  - print(parameterCountCheckFailureMessage)
    ; Call __print with 1 arguments
    mov r10, offset parameterCountCheckFailureMessage            ; reading parameterCountCheckFailureMessage for push
    push r10                                                     ; value of argument #1 (parameterCountCheckFailureMessage)
    push 016h                                                    ; type of argument #1 (String'22)
    lea rax, qword ptr [rsp + 020h]                              ; load address of return value's value
    push rax                                                     ; internal argument 6: pointer to return value slot's value
    lea rax, qword ptr [rsp + 020h]                              ; load address of return value's type
    push rax                                                     ; internal argument 5: pointer to return value slot's type
    sub rsp, 020h                                                ; allocate shadow space
    mov r9, 000h                                                 ; internal argument 4: "this" pointer
    mov r8, 000h                                                 ; internal argument 3: "this" pointer type
    mov rdx, 000h                                                ; internal argument 2: closure pointer
    mov qword ptr [rsp + 040h], rcx                              ; move parameter count of digitToStr value out of rcx
    mov rcx, 001h                                                ; internal argument 1: number of actual arguments
    call func$__print                                            ; jump to subroutine
    add rsp, 040h                                                ; release shadow space and arguments (result in stack pointer)
    ;  - exit(1)
    ; Call exit with 1 arguments
    push 001h                                                    ; value of argument #1 (1 (integer))
    push 015h                                                    ; type of argument #1 (Integer'21)
    lea rbx, qword ptr [rsp + 020h]                              ; load address of return value's value
    push rbx                                                     ; internal argument 6: pointer to return value slot's value
    lea rbx, qword ptr [rsp + 020h]                              ; load address of return value's type
    push rbx                                                     ; internal argument 5: pointer to return value slot's type
    sub rsp, 020h                                                ; allocate shadow space
    mov r9, 000h                                                 ; internal argument 4: "this" pointer
    mov r8, 000h                                                 ; internal argument 3: "this" pointer type
    mov rdx, 000h                                                ; internal argument 2: closure pointer
    mov rcx, 001h                                                ; internal argument 1: number of actual arguments
    call func$exit                                               ; jump to subroutine
    add rsp, 040h                                                ; release shadow space and arguments (result in stack pointer)
    mov rcx, qword ptr [rsp + 000h]                              ; restoring slots to previous scope state
  func$digitToStr$parameterCountCheck$continuation:              ; end of parameter count check
  ; Check type of parameter 0, digit (expecting Integer)
  mov rsi, qword ptr [rbp + 038h]                                ; move type of digit to testByte
  mov rax, rsi                                                   ; move testByte to testByte
  mov rdi, 001h                                                  ; read operand of mul (type table width in bytes) 
  mul rdi                                                        ; adjust to the relative start of that type's entry in the type table
  add rax, 000h                                                  ; adjust to the byte containing the bit to check against (result in testByte)
  mov r12, offset typeTable                                      ; read second operand of + (type table pointer)
  add rax, r12                                                   ; finally offset all of that by the start of the type table itself (result in testByte)
  bt qword ptr [rax], 002h                                       ; check that digit is Integer
  jc func$digitToStr$digit$TypeMatch                             ; skip next block if the type matches
    ; Error handling block for digit
    ;  - print(parameterTypeCheckFailureMessage)
    ; Call __print with 1 arguments
    mov r13, offset parameterTypeCheckFailureMessage             ; reading parameterTypeCheckFailureMessage for push
    push r13                                                     ; value of argument #1 (parameterTypeCheckFailureMessage)
    push 016h                                                    ; type of argument #1 (String'22)
    lea r14, qword ptr [rsp + 020h]                              ; load address of return value's value
    push r14                                                     ; internal argument 6: pointer to return value slot's value
    lea r14, qword ptr [rsp + 020h]                              ; load address of return value's type
    push r14                                                     ; internal argument 5: pointer to return value slot's type
    sub rsp, 020h                                                ; allocate shadow space
    mov r9, 000h                                                 ; internal argument 4: "this" pointer
    mov r8, 000h                                                 ; internal argument 3: "this" pointer type
    mov rdx, 000h                                                ; internal argument 2: closure pointer
    mov qword ptr [rsp + 040h], rcx                              ; move parameter count of digitToStr value out of rcx
    mov rcx, 001h                                                ; internal argument 1: number of actual arguments
    call func$__print                                            ; jump to subroutine
    add rsp, 040h                                                ; release shadow space and arguments (result in stack pointer)
    ;  - exit(1)
    ; Call exit with 1 arguments
    push 001h                                                    ; value of argument #1 (1 (integer))
    push 015h                                                    ; type of argument #1 (Integer'21)
    lea r15, qword ptr [rsp + 020h]                              ; load address of return value's value
    push r15                                                     ; internal argument 6: pointer to return value slot's value
    lea r15, qword ptr [rsp + 020h]                              ; load address of return value's type
    push r15                                                     ; internal argument 5: pointer to return value slot's type
    sub rsp, 020h                                                ; allocate shadow space
    mov r9, 000h                                                 ; internal argument 4: "this" pointer
    mov r8, 000h                                                 ; internal argument 3: "this" pointer type
    mov rdx, 000h                                                ; internal argument 2: closure pointer
    mov rcx, 001h                                                ; internal argument 1: number of actual arguments
    call func$exit                                               ; jump to subroutine
    add rsp, 040h                                                ; release shadow space and arguments (result in stack pointer)
    mov rcx, qword ptr [rsp + 000h]                              ; restoring slots to previous scope state
  func$digitToStr$digit$TypeMatch:                               ; after block
  ; Line 104: if (digit == 0) { ...
  xor r10, r10                                                   ; zero value result of == (testing digit and 0) to put the boolean in
  cmp qword ptr [rbp + 040h], 000h                               ; values equal?
  sete r10b                                                      ; put result in value result of == (testing digit and 0)
  mov rbx, 014h                                                  ; value result of == (testing digit and 0) is a Boolean'20
  xor rsi, rsi                                                   ; zero type result of == (testing digit and 0) to put the boolean in
  cmp qword ptr [rbp + 038h], 015h                               ; types equal?
  sete sil                                                       ; put result in type result of == (testing digit and 0)
  mov rax, 014h                                                  ; type result of == (testing digit and 0) is a Boolean'20
  mov rdi, r10                                                   ; assign value of value result of == (testing digit and 0) to value of == operator result
  and rdi, rsi                                                   ; && type temp and value temp
  mov r12, 014h                                                  ; == operator result is of type Boolean'20
  cmp rdi, 000h                                                  ; compare == operator result to false
  je func$digitToStr$if$continuation                             ; digit == 0
    ; Line 105: return '0';
    mov r13, offset string$4                                     ; read second operand of mov (string) for MoveToDerefInstruction
    mov r14, qword ptr [rbp + 030h]                              ; get pointer to return value of digitToStr into register to dereference it
    mov qword ptr [r14], r13                                     ; digitToStr return value
    mov r15, qword ptr [rbp + 028h]                              ; get pointer to return value type of digitToStr into register to dereference it
    mov qword ptr [r15], 016h                                    ; type of digitToStr return value (String'22)
    jmp func$digitToStr$epilog                                   ; return
  func$digitToStr$if$continuation:                               ; end of if
  ; Line 107: if (digit == 1) { ...
  xor r9, r9                                                     ; zero value result of == (testing digit and 1) to put the boolean in
  cmp qword ptr [rbp + 040h], 001h                               ; values equal?
  sete r9b                                                       ; put result in value result of == (testing digit and 1)
  mov r8, 014h                                                   ; value result of == (testing digit and 1) is a Boolean'20
  xor rdx, rdx                                                   ; zero type result of == (testing digit and 1) to put the boolean in
  cmp qword ptr [rbp + 038h], 015h                               ; types equal?
  sete dl                                                        ; put result in type result of == (testing digit and 1)
  mov qword ptr [rsp + 010h], rcx                                ; move parameter count of digitToStr value out of rcx
  mov rcx, 014h                                                  ; type result of == (testing digit and 1) is a Boolean'20
  mov r10, r9                                                    ; assign value of value result of == (testing digit and 1) to value of == operator result
  and r10, rdx                                                   ; && type temp and value temp
  mov rbx, 014h                                                  ; == operator result is of type Boolean'20
  cmp r10, 000h                                                  ; compare == operator result to false
  je func$digitToStr$if$continuation$1                           ; digit == 1
    ; Line 108: return '1';
    mov rsi, offset string$5                                     ; read second operand of mov (string) for MoveToDerefInstruction
    mov rax, qword ptr [rbp + 030h]                              ; get pointer to return value of digitToStr into register to dereference it
    mov qword ptr [rax], rsi                                     ; digitToStr return value
    mov rdi, qword ptr [rbp + 028h]                              ; get pointer to return value type of digitToStr into register to dereference it
    mov qword ptr [rdi], 016h                                    ; type of digitToStr return value (String'22)
    jmp func$digitToStr$epilog                                   ; return
  func$digitToStr$if$continuation$1:                             ; end of if
  ; Line 110: if (digit == 2) { ...
  xor r12, r12                                                   ; zero value result of == (testing digit and 2) to put the boolean in
  cmp qword ptr [rbp + 040h], 002h                               ; values equal?
  sete r12b                                                      ; put result in value result of == (testing digit and 2)
  mov r13, 014h                                                  ; value result of == (testing digit and 2) is a Boolean'20
  xor r14, r14                                                   ; zero type result of == (testing digit and 2) to put the boolean in
  cmp qword ptr [rbp + 038h], 015h                               ; types equal?
  sete r14b                                                      ; put result in type result of == (testing digit and 2)
  mov r15, 014h                                                  ; type result of == (testing digit and 2) is a Boolean'20
  mov r9, r12                                                    ; assign value of value result of == (testing digit and 2) to value of == operator result
  and r9, r14                                                    ; && type temp and value temp
  mov r8, 014h                                                   ; == operator result is of type Boolean'20
  cmp r9, 000h                                                   ; compare == operator result to false
  je func$digitToStr$if$continuation$2                           ; digit == 2
    ; Line 111: return '2';
    mov rdx, offset string$6                                     ; read second operand of mov (string) for MoveToDerefInstruction
    mov rcx, qword ptr [rbp + 030h]                              ; get pointer to return value of digitToStr into register to dereference it
    mov qword ptr [rcx], rdx                                     ; digitToStr return value
    mov r10, qword ptr [rbp + 028h]                              ; get pointer to return value type of digitToStr into register to dereference it
    mov qword ptr [r10], 016h                                    ; type of digitToStr return value (String'22)
    jmp func$digitToStr$epilog                                   ; return
  func$digitToStr$if$continuation$2:                             ; end of if
  ; Line 113: if (digit == 3) { ...
  xor rbx, rbx                                                   ; zero value result of == (testing digit and 3) to put the boolean in
  cmp qword ptr [rbp + 040h], 003h                               ; values equal?
  sete bl                                                        ; put result in value result of == (testing digit and 3)
  mov rsi, 014h                                                  ; value result of == (testing digit and 3) is a Boolean'20
  xor rax, rax                                                   ; zero type result of == (testing digit and 3) to put the boolean in
  cmp qword ptr [rbp + 038h], 015h                               ; types equal?
  sete al                                                        ; put result in type result of == (testing digit and 3)
  mov rdi, 014h                                                  ; type result of == (testing digit and 3) is a Boolean'20
  mov r12, rbx                                                   ; assign value of value result of == (testing digit and 3) to value of == operator result
  and r12, rax                                                   ; && type temp and value temp
  mov r13, 014h                                                  ; == operator result is of type Boolean'20
  cmp r12, 000h                                                  ; compare == operator result to false
  je func$digitToStr$if$continuation$3                           ; digit == 3
    ; Line 114: return '3';
    mov r14, offset string$7                                     ; read second operand of mov (string) for MoveToDerefInstruction
    mov r15, qword ptr [rbp + 030h]                              ; get pointer to return value of digitToStr into register to dereference it
    mov qword ptr [r15], r14                                     ; digitToStr return value
    mov r9, qword ptr [rbp + 028h]                               ; get pointer to return value type of digitToStr into register to dereference it
    mov qword ptr [r9], 016h                                     ; type of digitToStr return value (String'22)
    jmp func$digitToStr$epilog                                   ; return
  func$digitToStr$if$continuation$3:                             ; end of if
  ; Line 116: if (digit == 4) { ...
  xor r8, r8                                                     ; zero value result of == (testing digit and 4) to put the boolean in
  cmp qword ptr [rbp + 040h], 004h                               ; values equal?
  sete r8b                                                       ; put result in value result of == (testing digit and 4)
  mov rdx, 014h                                                  ; value result of == (testing digit and 4) is a Boolean'20
  xor rcx, rcx                                                   ; zero type result of == (testing digit and 4) to put the boolean in
  cmp qword ptr [rbp + 038h], 015h                               ; types equal?
  sete cl                                                        ; put result in type result of == (testing digit and 4)
  mov r10, 014h                                                  ; type result of == (testing digit and 4) is a Boolean'20
  mov rbx, r8                                                    ; assign value of value result of == (testing digit and 4) to value of == operator result
  and rbx, rcx                                                   ; && type temp and value temp
  mov rsi, 014h                                                  ; == operator result is of type Boolean'20
  cmp rbx, 000h                                                  ; compare == operator result to false
  je func$digitToStr$if$continuation$4                           ; digit == 4
    ; Line 117: return '4';
    mov rax, offset string$8                                     ; read second operand of mov (string) for MoveToDerefInstruction
    mov rdi, qword ptr [rbp + 030h]                              ; get pointer to return value of digitToStr into register to dereference it
    mov qword ptr [rdi], rax                                     ; digitToStr return value
    mov r12, qword ptr [rbp + 028h]                              ; get pointer to return value type of digitToStr into register to dereference it
    mov qword ptr [r12], 016h                                    ; type of digitToStr return value (String'22)
    jmp func$digitToStr$epilog                                   ; return
  func$digitToStr$if$continuation$4:                             ; end of if
  ; Line 119: if (digit == 5) { ...
  xor r13, r13                                                   ; zero value result of == (testing digit and 5) to put the boolean in
  cmp qword ptr [rbp + 040h], 005h                               ; values equal?
  sete r13b                                                      ; put result in value result of == (testing digit and 5)
  mov r14, 014h                                                  ; value result of == (testing digit and 5) is a Boolean'20
  xor r15, r15                                                   ; zero type result of == (testing digit and 5) to put the boolean in
  cmp qword ptr [rbp + 038h], 015h                               ; types equal?
  sete r15b                                                      ; put result in type result of == (testing digit and 5)
  mov r9, 014h                                                   ; type result of == (testing digit and 5) is a Boolean'20
  mov r8, r13                                                    ; assign value of value result of == (testing digit and 5) to value of == operator result
  and r8, r15                                                    ; && type temp and value temp
  mov rdx, 014h                                                  ; == operator result is of type Boolean'20
  cmp r8, 000h                                                   ; compare == operator result to false
  je func$digitToStr$if$continuation$5                           ; digit == 5
    ; Line 120: return '5';
    mov rcx, offset string$9                                     ; read second operand of mov (string) for MoveToDerefInstruction
    mov r10, qword ptr [rbp + 030h]                              ; get pointer to return value of digitToStr into register to dereference it
    mov qword ptr [r10], rcx                                     ; digitToStr return value
    mov rbx, qword ptr [rbp + 028h]                              ; get pointer to return value type of digitToStr into register to dereference it
    mov qword ptr [rbx], 016h                                    ; type of digitToStr return value (String'22)
    jmp func$digitToStr$epilog                                   ; return
  func$digitToStr$if$continuation$5:                             ; end of if
  ; Line 122: if (digit == 6) { ...
  xor rsi, rsi                                                   ; zero value result of == (testing digit and 6) to put the boolean in
  cmp qword ptr [rbp + 040h], 006h                               ; values equal?
  sete sil                                                       ; put result in value result of == (testing digit and 6)
  mov rax, 014h                                                  ; value result of == (testing digit and 6) is a Boolean'20
  xor rdi, rdi                                                   ; zero type result of == (testing digit and 6) to put the boolean in
  cmp qword ptr [rbp + 038h], 015h                               ; types equal?
  sete dil                                                       ; put result in type result of == (testing digit and 6)
  mov r12, 014h                                                  ; type result of == (testing digit and 6) is a Boolean'20
  mov r13, rsi                                                   ; assign value of value result of == (testing digit and 6) to value of == operator result
  and r13, rdi                                                   ; && type temp and value temp
  mov r14, 014h                                                  ; == operator result is of type Boolean'20
  cmp r13, 000h                                                  ; compare == operator result to false
  je func$digitToStr$if$continuation$6                           ; digit == 6
    ; Line 123: return '6';
    mov r15, offset string$10                                    ; read second operand of mov (string) for MoveToDerefInstruction
    mov r9, qword ptr [rbp + 030h]                               ; get pointer to return value of digitToStr into register to dereference it
    mov qword ptr [r9], r15                                      ; digitToStr return value
    mov r8, qword ptr [rbp + 028h]                               ; get pointer to return value type of digitToStr into register to dereference it
    mov qword ptr [r8], 016h                                     ; type of digitToStr return value (String'22)
    jmp func$digitToStr$epilog                                   ; return
  func$digitToStr$if$continuation$6:                             ; end of if
  ; Line 125: if (digit == 7) { ...
  xor rdx, rdx                                                   ; zero value result of == (testing digit and 7) to put the boolean in
  cmp qword ptr [rbp + 040h], 007h                               ; values equal?
  sete dl                                                        ; put result in value result of == (testing digit and 7)
  mov rcx, 014h                                                  ; value result of == (testing digit and 7) is a Boolean'20
  xor r10, r10                                                   ; zero type result of == (testing digit and 7) to put the boolean in
  cmp qword ptr [rbp + 038h], 015h                               ; types equal?
  sete r10b                                                      ; put result in type result of == (testing digit and 7)
  mov rbx, 014h                                                  ; type result of == (testing digit and 7) is a Boolean'20
  mov rsi, rdx                                                   ; assign value of value result of == (testing digit and 7) to value of == operator result
  and rsi, r10                                                   ; && type temp and value temp
  mov rax, 014h                                                  ; == operator result is of type Boolean'20
  cmp rsi, 000h                                                  ; compare == operator result to false
  je func$digitToStr$if$continuation$7                           ; digit == 7
    ; Line 126: return '7';
    mov rdi, offset string$11                                    ; read second operand of mov (string) for MoveToDerefInstruction
    mov r12, qword ptr [rbp + 030h]                              ; get pointer to return value of digitToStr into register to dereference it
    mov qword ptr [r12], rdi                                     ; digitToStr return value
    mov r13, qword ptr [rbp + 028h]                              ; get pointer to return value type of digitToStr into register to dereference it
    mov qword ptr [r13], 016h                                    ; type of digitToStr return value (String'22)
    jmp func$digitToStr$epilog                                   ; return
  func$digitToStr$if$continuation$7:                             ; end of if
  ; Line 128: if (digit == 8) { ...
  xor r14, r14                                                   ; zero value result of == (testing digit and 8) to put the boolean in
  cmp qword ptr [rbp + 040h], 008h                               ; values equal?
  sete r14b                                                      ; put result in value result of == (testing digit and 8)
  mov r15, 014h                                                  ; value result of == (testing digit and 8) is a Boolean'20
  xor r9, r9                                                     ; zero type result of == (testing digit and 8) to put the boolean in
  cmp qword ptr [rbp + 038h], 015h                               ; types equal?
  sete r9b                                                       ; put result in type result of == (testing digit and 8)
  mov r8, 014h                                                   ; type result of == (testing digit and 8) is a Boolean'20
  mov rdx, r14                                                   ; assign value of value result of == (testing digit and 8) to value of == operator result
  and rdx, r9                                                    ; && type temp and value temp
  mov rcx, 014h                                                  ; == operator result is of type Boolean'20
  cmp rdx, 000h                                                  ; compare == operator result to false
  je func$digitToStr$if$continuation$8                           ; digit == 8
    ; Line 129: return '8';
    mov r10, offset string$12                                    ; read second operand of mov (string) for MoveToDerefInstruction
    mov rbx, qword ptr [rbp + 030h]                              ; get pointer to return value of digitToStr into register to dereference it
    mov qword ptr [rbx], r10                                     ; digitToStr return value
    mov rsi, qword ptr [rbp + 028h]                              ; get pointer to return value type of digitToStr into register to dereference it
    mov qword ptr [rsi], 016h                                    ; type of digitToStr return value (String'22)
    jmp func$digitToStr$epilog                                   ; return
  func$digitToStr$if$continuation$8:                             ; end of if
  ; Line 131: if (digit == 9) { ...
  xor rax, rax                                                   ; zero value result of == (testing digit and 9) to put the boolean in
  cmp qword ptr [rbp + 040h], 009h                               ; values equal?
  sete al                                                        ; put result in value result of == (testing digit and 9)
  mov rdi, 014h                                                  ; value result of == (testing digit and 9) is a Boolean'20
  xor r12, r12                                                   ; zero type result of == (testing digit and 9) to put the boolean in
  cmp qword ptr [rbp + 038h], 015h                               ; types equal?
  sete r12b                                                      ; put result in type result of == (testing digit and 9)
  mov r13, 014h                                                  ; type result of == (testing digit and 9) is a Boolean'20
  mov r14, rax                                                   ; assign value of value result of == (testing digit and 9) to value of == operator result
  and r14, r12                                                   ; && type temp and value temp
  mov r15, 014h                                                  ; == operator result is of type Boolean'20
  cmp r14, 000h                                                  ; compare == operator result to false
  je func$digitToStr$if$continuation$9                           ; digit == 9
    ; Line 132: return '9';
    mov r9, offset string$13                                     ; read second operand of mov (string) for MoveToDerefInstruction
    mov r8, qword ptr [rbp + 030h]                               ; get pointer to return value of digitToStr into register to dereference it
    mov qword ptr [r8], r9                                       ; digitToStr return value
    mov rdx, qword ptr [rbp + 028h]                              ; get pointer to return value type of digitToStr into register to dereference it
    mov qword ptr [rdx], 016h                                    ; type of digitToStr return value (String'22)
    jmp func$digitToStr$epilog                                   ; return
  func$digitToStr$if$continuation$9:                             ; end of if
  ; Line 134: __print('Invalid digit passed to digitToStr (digit as exit code)...
  ; Call __print with 1 arguments
  mov rcx, offset string$14                                      ; reading string for push
  push rcx                                                       ; value of argument #1 (string)
  push 016h                                                      ; type of argument #1 (String'22)
  lea r10, qword ptr [rsp + 018h]                                ; load address of return value's value
  push r10                                                       ; internal argument 6: pointer to return value slot's value
  lea r10, qword ptr [rsp + 018h]                                ; load address of return value's type
  push r10                                                       ; internal argument 5: pointer to return value slot's type
  sub rsp, 020h                                                  ; allocate shadow space
  mov r9, 000h                                                   ; internal argument 4: "this" pointer
  mov r8, 000h                                                   ; internal argument 3: "this" pointer type
  mov rdx, 000h                                                  ; internal argument 2: closure pointer
  mov rcx, 001h                                                  ; internal argument 1: number of actual arguments
  call func$__print                                              ; jump to subroutine
  add rsp, 040h                                                  ; release shadow space and arguments (result in stack pointer)
  ; Line 135: exit(digit);
  ; Call exit with 1 arguments
  push qword ptr [rbp + 040h]                                    ; value of argument #1 (digit)
  push qword ptr [rbp + 038h]                                    ; type of argument #1
  lea rbx, qword ptr [rsp + 018h]                                ; load address of return value's value
  push rbx                                                       ; internal argument 6: pointer to return value slot's value
  lea rbx, qword ptr [rsp + 018h]                                ; load address of return value's type
  push rbx                                                       ; internal argument 5: pointer to return value slot's type
  sub rsp, 020h                                                  ; allocate shadow space
  mov r9, 000h                                                   ; internal argument 4: "this" pointer
  mov r8, 000h                                                   ; internal argument 3: "this" pointer type
  mov rdx, 000h                                                  ; internal argument 2: closure pointer
  mov rcx, 001h                                                  ; internal argument 1: number of actual arguments
  call func$exit                                                 ; jump to subroutine
  add rsp, 040h                                                  ; release shadow space and arguments (result in stack pointer)
  ; Implicit return from digitToStr
  mov rsi, 013h                                                  ; move type of null to testByte
  mov rax, rsi                                                   ; move testByte to testByte
  mov rdi, 001h                                                  ; read operand of mul (type table width in bytes) 
  mul rdi                                                        ; adjust to the relative start of that type's entry in the type table
  add rax, 000h                                                  ; adjust to the byte containing the bit to check against (result in testByte)
  mov r12, offset typeTable                                      ; read second operand of + (type table pointer)
  add rax, r12                                                   ; finally offset all of that by the start of the type table itself (result in testByte)
  bt qword ptr [rax], 003h                                       ; check that digitToStr return value is String
  jc func$digitToStr$digittostrReturnValue$TypeMatch             ; skip next block if the type matches
    ; Error handling block for digitToStr return value
    ;  - print(returnValueTypeCheckFailureMessage)
    ; Call __print with 1 arguments
    mov r13, offset returnValueTypeCheckFailureMessage           ; reading returnValueTypeCheckFailureMessage for push
    push r13                                                     ; value of argument #1 (returnValueTypeCheckFailureMessage)
    push 016h                                                    ; type of argument #1 (String'22)
    lea r14, qword ptr [rsp + 018h]                              ; load address of return value's value
    push r14                                                     ; internal argument 6: pointer to return value slot's value
    lea r14, qword ptr [rsp + 018h]                              ; load address of return value's type
    push r14                                                     ; internal argument 5: pointer to return value slot's type
    sub rsp, 020h                                                ; allocate shadow space
    mov r9, 000h                                                 ; internal argument 4: "this" pointer
    mov r8, 000h                                                 ; internal argument 3: "this" pointer type
    mov rdx, 000h                                                ; internal argument 2: closure pointer
    mov rcx, 001h                                                ; internal argument 1: number of actual arguments
    call func$__print                                            ; jump to subroutine
    add rsp, 040h                                                ; release shadow space and arguments (result in stack pointer)
    ;  - exit(1)
    ; Call exit with 1 arguments
    push 001h                                                    ; value of argument #1 (1 (integer))
    push 015h                                                    ; type of argument #1 (Integer'21)
    lea r15, qword ptr [rsp + 018h]                              ; load address of return value's value
    push r15                                                     ; internal argument 6: pointer to return value slot's value
    lea r15, qword ptr [rsp + 018h]                              ; load address of return value's type
    push r15                                                     ; internal argument 5: pointer to return value slot's type
    sub rsp, 020h                                                ; allocate shadow space
    mov r9, 000h                                                 ; internal argument 4: "this" pointer
    mov r8, 000h                                                 ; internal argument 3: "this" pointer type
    mov rdx, 000h                                                ; internal argument 2: closure pointer
    mov rcx, 001h                                                ; internal argument 1: number of actual arguments
    call func$exit                                               ; jump to subroutine
    add rsp, 040h                                                ; release shadow space and arguments (result in stack pointer)
  func$digitToStr$digittostrReturnValue$TypeMatch:               ; after block
  mov r10, qword ptr [rbp + 030h]                                ; get pointer to return value of digitToStr into register to dereference it
  mov qword ptr [r10], 000h                                      ; digitToStr return value
  mov rbx, qword ptr [rbp + 028h]                                ; get pointer to return value type of digitToStr into register to dereference it
  mov qword ptr [rbx], 013h                                      ; type of digitToStr return value (Null'19)
  jmp func$digitToStr$epilog                                     ; return
  func$digitToStr$epilog: 
  mov rax, qword ptr [rbp + 030h]                                ; report address of return value
  ; Epilog
  add rsp, 020h                                                  ; free space for stack
  pop r14                                                        ; restore non-volatile registers
  pop r13                                                        ; restore non-volatile registers
  pop r12                                                        ; restore non-volatile registers
  pop rbp                                                        ; restore non-volatile registers
  pop rdi                                                        ; restore non-volatile registers
  pop rsi                                                        ; restore non-volatile registers
  pop rbx                                                        ; restore non-volatile registers
  pop r15                                                        ; restore non-volatile registers
  ret                                                            ; return from subroutine

; intToStr
func$intToStr:
  ; Prolog
  push r15                                                       ; save non-volatile registers
  push rbx                                                       ; save non-volatile registers
  push rsi                                                       ; save non-volatile registers
  push rdi                                                       ; save non-volatile registers
  push rbp                                                       ; save non-volatile registers
  push r12                                                       ; save non-volatile registers
  push r13                                                       ; save non-volatile registers
  push r14                                                       ; save non-volatile registers
  sub rsp, 050h                                                  ; allocate space for stack
  lea rbp, qword ptr [rsp + 090h]                                ; set up frame pointer
  ; Check parameter count
  cmp rcx, 001h                                                  ; compare parameter count of intToStr to 1 (integer)
  je func$intToStr$parameterCountCheck$continuation              ; check number of parameters is as expected
    ; Error handling block for parameter count
    ;  - print(parameterCountCheckFailureMessage)
    ; Call __print with 1 arguments
    mov r10, offset parameterCountCheckFailureMessage            ; reading parameterCountCheckFailureMessage for push
    push r10                                                     ; value of argument #1 (parameterCountCheckFailureMessage)
    push 016h                                                    ; type of argument #1 (String'22)
    lea rax, qword ptr [rsp + 050h]                              ; load address of return value's value
    push rax                                                     ; internal argument 6: pointer to return value slot's value
    lea rax, qword ptr [rsp + 050h]                              ; load address of return value's type
    push rax                                                     ; internal argument 5: pointer to return value slot's type
    sub rsp, 020h                                                ; allocate shadow space
    mov r9, 000h                                                 ; internal argument 4: "this" pointer
    mov r8, 000h                                                 ; internal argument 3: "this" pointer type
    mov rdx, 000h                                                ; internal argument 2: closure pointer
    mov qword ptr [rsp + 070h], rcx                              ; move parameter count of intToStr value out of rcx
    mov rcx, 001h                                                ; internal argument 1: number of actual arguments
    call func$__print                                            ; jump to subroutine
    add rsp, 040h                                                ; release shadow space and arguments (result in stack pointer)
    ;  - exit(1)
    ; Call exit with 1 arguments
    push 001h                                                    ; value of argument #1 (1 (integer))
    push 015h                                                    ; type of argument #1 (Integer'21)
    lea rbx, qword ptr [rsp + 050h]                              ; load address of return value's value
    push rbx                                                     ; internal argument 6: pointer to return value slot's value
    lea rbx, qword ptr [rsp + 050h]                              ; load address of return value's type
    push rbx                                                     ; internal argument 5: pointer to return value slot's type
    sub rsp, 020h                                                ; allocate shadow space
    mov r9, 000h                                                 ; internal argument 4: "this" pointer
    mov r8, 000h                                                 ; internal argument 3: "this" pointer type
    mov rdx, 000h                                                ; internal argument 2: closure pointer
    mov rcx, 001h                                                ; internal argument 1: number of actual arguments
    call func$exit                                               ; jump to subroutine
    add rsp, 040h                                                ; release shadow space and arguments (result in stack pointer)
    mov rcx, qword ptr [rsp + 030h]                              ; restoring slots to previous scope state
  func$intToStr$parameterCountCheck$continuation:                ; end of parameter count check
  ; Check type of parameter 0, value (expecting Integer)
  mov rsi, qword ptr [rbp + 038h]                                ; move type of value to testByte
  mov rax, rsi                                                   ; move testByte to testByte
  mov rdi, 001h                                                  ; read operand of mul (type table width in bytes) 
  mul rdi                                                        ; adjust to the relative start of that type's entry in the type table
  add rax, 000h                                                  ; adjust to the byte containing the bit to check against (result in testByte)
  mov r12, offset typeTable                                      ; read second operand of + (type table pointer)
  add rax, r12                                                   ; finally offset all of that by the start of the type table itself (result in testByte)
  bt qword ptr [rax], 002h                                       ; check that value is Integer
  jc func$intToStr$value$TypeMatch                               ; skip next block if the type matches
    ; Error handling block for value
    ;  - print(parameterTypeCheckFailureMessage)
    ; Call __print with 1 arguments
    mov r13, offset parameterTypeCheckFailureMessage             ; reading parameterTypeCheckFailureMessage for push
    push r13                                                     ; value of argument #1 (parameterTypeCheckFailureMessage)
    push 016h                                                    ; type of argument #1 (String'22)
    lea r14, qword ptr [rsp + 050h]                              ; load address of return value's value
    push r14                                                     ; internal argument 6: pointer to return value slot's value
    lea r14, qword ptr [rsp + 050h]                              ; load address of return value's type
    push r14                                                     ; internal argument 5: pointer to return value slot's type
    sub rsp, 020h                                                ; allocate shadow space
    mov r9, 000h                                                 ; internal argument 4: "this" pointer
    mov r8, 000h                                                 ; internal argument 3: "this" pointer type
    mov rdx, 000h                                                ; internal argument 2: closure pointer
    mov qword ptr [rsp + 070h], rcx                              ; move parameter count of intToStr value out of rcx
    mov rcx, 001h                                                ; internal argument 1: number of actual arguments
    call func$__print                                            ; jump to subroutine
    add rsp, 040h                                                ; release shadow space and arguments (result in stack pointer)
    ;  - exit(1)
    ; Call exit with 1 arguments
    push 001h                                                    ; value of argument #1 (1 (integer))
    push 015h                                                    ; type of argument #1 (Integer'21)
    lea r15, qword ptr [rsp + 050h]                              ; load address of return value's value
    push r15                                                     ; internal argument 6: pointer to return value slot's value
    lea r15, qword ptr [rsp + 050h]                              ; load address of return value's type
    push r15                                                     ; internal argument 5: pointer to return value slot's type
    sub rsp, 020h                                                ; allocate shadow space
    mov r9, 000h                                                 ; internal argument 4: "this" pointer
    mov r8, 000h                                                 ; internal argument 3: "this" pointer type
    mov rdx, 000h                                                ; internal argument 2: closure pointer
    mov rcx, 001h                                                ; internal argument 1: number of actual arguments
    call func$exit                                               ; jump to subroutine
    add rsp, 040h                                                ; release shadow space and arguments (result in stack pointer)
    mov rcx, qword ptr [rsp + 030h]                              ; restoring slots to previous scope state
  func$intToStr$value$TypeMatch:                                 ; after block
  ; Line 139: if (value == 0) { ...
  xor r10, r10                                                   ; zero value result of == (testing value and 0) to put the boolean in
  cmp qword ptr [rbp + 040h], 000h                               ; values equal?
  sete r10b                                                      ; put result in value result of == (testing value and 0)
  mov rbx, 014h                                                  ; value result of == (testing value and 0) is a Boolean'20
  xor rsi, rsi                                                   ; zero type result of == (testing value and 0) to put the boolean in
  cmp qword ptr [rbp + 038h], 015h                               ; types equal?
  sete sil                                                       ; put result in type result of == (testing value and 0)
  mov rax, 014h                                                  ; type result of == (testing value and 0) is a Boolean'20
  mov rdi, r10                                                   ; assign value of value result of == (testing value and 0) to value of == operator result
  and rdi, rsi                                                   ; && type temp and value temp
  mov r12, 014h                                                  ; == operator result is of type Boolean'20
  cmp rdi, 000h                                                  ; compare == operator result to false
  je func$intToStr$if$continuation                               ; value == 0
    ; Line 140: return '0';
    mov r13, offset string$4                                     ; read second operand of mov (string) for MoveToDerefInstruction
    mov r14, qword ptr [rbp + 030h]                              ; get pointer to return value of intToStr into register to dereference it
    mov qword ptr [r14], r13                                     ; intToStr return value
    mov r15, qword ptr [rbp + 028h]                              ; get pointer to return value type of intToStr into register to dereference it
    mov qword ptr [r15], 016h                                    ; type of intToStr return value (String'22)
    jmp func$intToStr$epilog                                     ; return
  func$intToStr$if$continuation:                                 ; end of if
  ; Line 142: String buffer = '';
  mov r9, offset string$15                                       ; value initialization of variable declaration for buffer variable (string)
  mov r8, 016h                                                   ; type initialization of variable declaration for buffer variable (String'22)
  ; increment reference count for buffer variable if necessary
  cmp r8, 016h                                                   ; if not a string, skip incref
  jne func$intToStr$AfterIncref
  mov rdx, qword ptr [r9]                                        ; dereference string to get to ref count
  cmp rdx, 0                                                     ; compare string refcount temporary to 0
  js func$intToStr$AfterIncref                                   ; if ref count is negative (constant strings), skip incref
  add rdx, 001h                                                  ; increment ref count (result in string refcount temporary)
  mov qword ptr [r9], rdx                                        ; put it back in the string
  func$intToStr$AfterIncref:                                     ; after incref
  ; Line 143: Integer newValue = value;
  mov qword ptr [rsp + 040h], rcx                                ; move parameter count of intToStr value out of rcx
  mov rcx, qword ptr [rbp + 040h]                                ; value initialization of variable declaration for newValue variable (value)
  mov r10, qword ptr [rbp + 038h]                                ; type initialization of variable declaration for newValue variable
  func$intToStr$while$top:                                       ; top of while
    xor rbx, rbx                                                 ; clear > operator result
    cmp rcx, 000h                                                ; compare newValue variable with 0
    setg bl                                                      ; store result in > operator result
    mov rsi, 014h                                                ; > operator result is of type Boolean'20
    cmp rbx, 000h                                                ; compare > operator result to false
    jne func$intToStr$while$body                                 ; while condition
    jmp func$intToStr$while$bottom                               ; break out of while
    func$intToStr$while$body:                                    ; start of while
    ; Line 145: Integer digit = newValue % 10 /* 0xa */;
    mov rax, rcx                                                 ; put lhs of rdx division (<DynamicSlot:Integer'21 at [rcx, rcx]/[r10, r10] ("newValue variable") (living: true)>) in rax
    mov qword ptr [rsp + 038h], rax                              ; move newValue variable value out of rax
    cqo                                                          ; zero-extend dividend (rax into rdx:rax)
    mov rdi, 00ah                                                ; read visible operand of div (<ImmediateIntegerSlot:Integer'21 ("10 /* 0xa */")>) 
    idiv rdi                                                     ; compute (newValue variable) % (10 /* 0xa */) (result, % operator result, ends up in rdx)
    mov r12, 015h                                                ; % operator result is of type Integer'21
    mov r13, rdx                                                 ; value initialization of variable declaration for digit variable (% operator result)
    mov r14, r12                                                 ; type initialization of variable declaration for digit variable
    ; Line 146: newValue = newValue / 10 /* 0xa */;
    mov rax, qword ptr [rsp + 038h]                              ; assign value of newValue variable to value of / operator result
    cqo                                                          ; zero-extend dividend
    mov r15, 00ah                                                ; read operand of div (10 /* 0xa */) 
    idiv r15                                                     ; compute (newValue variable) / (10 /* 0xa */) (result, / operator result, is in rax)
    mov qword ptr [rsp + 030h], r9                               ; move buffer variable value out of r9
    mov r9, 015h                                                 ; / operator result is of type Integer'21
    mov qword ptr [rsp + 038h], rax                              ; store value
    mov r10, r9                                                  ; store type
    ; Line 147: buffer = concat(digitToStr(digit), buffer);
    ; Call digitToStr with 1 arguments
    push r13                                                     ; value of argument #1 (digit variable)
    push r14                                                     ; type of argument #1
    mov qword ptr [rsp + 030h], r8                               ; move buffer variable type out of r8
    lea r8, qword ptr [rsp + 038h]                               ; load address of return value's value
    push r8                                                      ; internal argument 6: pointer to return value slot's value
    lea r8, qword ptr [rsp + 030h]                               ; load address of return value's type
    push r8                                                      ; internal argument 5: pointer to return value slot's type
    sub rsp, 020h                                                ; allocate shadow space
    mov r9, 000h                                                 ; internal argument 4: "this" pointer
    mov r8, 000h                                                 ; internal argument 3: "this" pointer type
    mov rdx, 000h                                                ; internal argument 2: closure pointer
    mov rcx, 001h                                                ; internal argument 1: number of actual arguments
    mov qword ptr [rsp + 050h], r10                              ; move newValue variable type out of r10
    call func$digitToStr                                         ; jump to subroutine
    add rsp, 040h                                                ; release shadow space and arguments (result in stack pointer)
    ; Call concat with 2 arguments
    push qword ptr [rsp + 030h]                                  ; value of argument #2 (buffer variable)
    push qword ptr [rsp + 028h]                                  ; type of argument #2
    push qword ptr [rsp + 038h]                                  ; value of argument #1 (digitToStr return value)
    push qword ptr [rsp + 030h]                                  ; type of argument #1
    lea r10, qword ptr [rsp + 028h]                              ; load address of return value's value
    push r10                                                     ; internal argument 6: pointer to return value slot's value
    lea r10, qword ptr [rsp + 028h]                              ; load address of return value's type
    push r10                                                     ; internal argument 5: pointer to return value slot's type
    sub rsp, 020h                                                ; allocate shadow space
    mov r9, 000h                                                 ; internal argument 4: "this" pointer
    mov r8, 000h                                                 ; internal argument 3: "this" pointer type
    mov rdx, 000h                                                ; internal argument 2: closure pointer
    mov rcx, 002h                                                ; internal argument 1: number of actual arguments
    call func$concat                                             ; jump to subroutine
    add rsp, 050h                                                ; release shadow space and arguments (result in stack pointer)
    ; Calling decref on buffer variable (static type: String'22)
    sub rsp, 20h                                                 ; allocate shadow space for decref
    mov rdx, qword ptr [rsp + 040h]                              ; arg #2: type of potential string
    mov rcx, qword ptr [rsp + 050h]                              ; arg #1: value of potential string
    call intrinsic$decref                                        ; call decref
    add rsp, 20h                                                 ; free shadow space for decref
    mov r11, qword ptr [rsp + 008h]                              ; indirect through r11 because operand pair (stack operand #3, stack operand #8) is not allowed with mov
    mov qword ptr [rsp + 030h], r11                              ; store value
    mov r11, qword ptr [rsp + 000h]                              ; indirect through r11 because operand pair (stack operand #5, stack operand #9) is not allowed with mov
    mov qword ptr [rsp + 020h], r11                              ; store type
    ; increment reference count for buffer variable if necessary
    cmp qword ptr [rsp + 020h], 016h                             ; if not a string, skip incref
    jne func$intToStr$while$AfterIncref
    mov rbx, qword ptr [rsp + 030h]                              ; get buffer variable into register to dereference it
    mov rsi, qword ptr [rbx]                                     ; dereference string to get to ref count
    cmp rsi, 0                                                   ; compare string refcount temporary to 0
    js func$intToStr$while$AfterIncref                           ; if ref count is negative (constant strings), skip incref
    add rsi, 001h                                                ; increment ref count (result in string refcount temporary)
    mov qword ptr [rbx], rsi                                     ; put it back in the string
    func$intToStr$while$AfterIncref:                             ; after incref
    ; Calling decref on concat return value (static type: String'22)
    sub rsp, 20h                                                 ; allocate shadow space for decref
    mov rdx, qword ptr [rsp + 020h]                              ; arg #2: type of potential string
    mov rcx, qword ptr [rsp + 028h]                              ; arg #1: value of potential string
    call intrinsic$decref                                        ; call decref
    add rsp, 20h                                                 ; free shadow space for decref
    ; Calling decref on digitToStr return value (static type: String'22)
    sub rsp, 20h                                                 ; allocate shadow space for decref
    mov rdx, qword ptr [rsp + 038h]                              ; arg #2: type of potential string
    mov rcx, qword ptr [rsp + 048h]                              ; arg #1: value of potential string
    call intrinsic$decref                                        ; call decref
    add rsp, 20h                                                 ; free shadow space for decref
    mov r8, qword ptr [rsp + 020h]                               ; restoring slots to previous scope state
    mov r9, rbx                                                  ; restoring slots to previous scope state
    mov rcx, qword ptr [rsp + 038h]                              ; restoring slots to previous scope state
    mov r10, qword ptr [rsp + 010h]                              ; restoring slots to previous scope state
    jmp func$intToStr$while$top                                  ; return to top of while
  func$intToStr$while$bottom:                                    ; bottom of while
  ; Line 149: return buffer;
  mov rdi, qword ptr [rbp + 030h]                                ; get pointer to return value of intToStr into register to dereference it
  mov qword ptr [rdi], r9                                        ; intToStr return value
  mov r12, qword ptr [rbp + 028h]                                ; get pointer to return value type of intToStr into register to dereference it
  mov qword ptr [r12], r8                                        ; type of intToStr return value
  ; increment reference count for buffer variable if necessary
  cmp r8, 016h                                                   ; if not a string, skip incref
  jne func$intToStr$AfterIncref$1
  mov r13, qword ptr [r9]                                        ; dereference string to get to ref count
  cmp r13, 0                                                     ; compare string refcount temporary to 0
  js func$intToStr$AfterIncref$1                                 ; if ref count is negative (constant strings), skip incref
  add r13, 001h                                                  ; increment ref count (result in string refcount temporary)
  mov qword ptr [r9], r13                                        ; put it back in the string
  func$intToStr$AfterIncref$1:                                   ; after incref
  ; Calling decref on buffer variable (static type: String'22)
  sub rsp, 20h                                                   ; allocate shadow space for decref
  mov rdx, r8                                                    ; arg #2: type of potential string
  mov rcx, r9                                                    ; arg #1: value of potential string
  mov r14, rcx                                                   ; save value of potential string
  mov r15, rdx                                                   ; save type of potential string
  call intrinsic$decref                                          ; call decref
  add rsp, 20h                                                   ; free shadow space for decref
  jmp func$intToStr$epilog                                       ; return
  func$intToStr$epilog: 
  mov rax, qword ptr [rbp + 030h]                                ; report address of return value
  ; Epilog
  add rsp, 050h                                                  ; free space for stack
  pop r14                                                        ; restore non-volatile registers
  pop r13                                                        ; restore non-volatile registers
  pop r12                                                        ; restore non-volatile registers
  pop rbp                                                        ; restore non-volatile registers
  pop rdi                                                        ; restore non-volatile registers
  pop rsi                                                        ; restore non-volatile registers
  pop rbx                                                        ; restore non-volatile registers
  pop r15                                                        ; restore non-volatile registers
  ret                                                            ; return from subroutine

; _stringify
func$_stringify:
  ; Prolog
  push r15                                                       ; save non-volatile registers
  push rbx                                                       ; save non-volatile registers
  push rsi                                                       ; save non-volatile registers
  push rdi                                                       ; save non-volatile registers
  push rbp                                                       ; save non-volatile registers
  push r12                                                       ; save non-volatile registers
  push r13                                                       ; save non-volatile registers
  push r14                                                       ; save non-volatile registers
  sub rsp, 020h                                                  ; allocate space for stack
  lea rbp, qword ptr [rsp + 060h]                                ; set up frame pointer
  ; Check parameter count
  cmp rcx, 001h                                                  ; compare parameter count of _stringify to 1 (integer)
  je func$_stringify$parameterCountCheck$continuation            ; check number of parameters is as expected
    ; Error handling block for parameter count
    ;  - print(parameterCountCheckFailureMessage)
    ; Call __print with 1 arguments
    mov r10, offset parameterCountCheckFailureMessage            ; reading parameterCountCheckFailureMessage for push
    push r10                                                     ; value of argument #1 (parameterCountCheckFailureMessage)
    push 016h                                                    ; type of argument #1 (String'22)
    lea rax, qword ptr [rsp + 020h]                              ; load address of return value's value
    push rax                                                     ; internal argument 6: pointer to return value slot's value
    lea rax, qword ptr [rsp + 020h]                              ; load address of return value's type
    push rax                                                     ; internal argument 5: pointer to return value slot's type
    sub rsp, 020h                                                ; allocate shadow space
    mov r9, 000h                                                 ; internal argument 4: "this" pointer
    mov r8, 000h                                                 ; internal argument 3: "this" pointer type
    mov rdx, 000h                                                ; internal argument 2: closure pointer
    mov qword ptr [rsp + 040h], rcx                              ; move parameter count of _stringify value out of rcx
    mov rcx, 001h                                                ; internal argument 1: number of actual arguments
    call func$__print                                            ; jump to subroutine
    add rsp, 040h                                                ; release shadow space and arguments (result in stack pointer)
    ;  - exit(1)
    ; Call exit with 1 arguments
    push 001h                                                    ; value of argument #1 (1 (integer))
    push 015h                                                    ; type of argument #1 (Integer'21)
    lea rbx, qword ptr [rsp + 020h]                              ; load address of return value's value
    push rbx                                                     ; internal argument 6: pointer to return value slot's value
    lea rbx, qword ptr [rsp + 020h]                              ; load address of return value's type
    push rbx                                                     ; internal argument 5: pointer to return value slot's type
    sub rsp, 020h                                                ; allocate shadow space
    mov r9, 000h                                                 ; internal argument 4: "this" pointer
    mov r8, 000h                                                 ; internal argument 3: "this" pointer type
    mov rdx, 000h                                                ; internal argument 2: closure pointer
    mov rcx, 001h                                                ; internal argument 1: number of actual arguments
    call func$exit                                               ; jump to subroutine
    add rsp, 040h                                                ; release shadow space and arguments (result in stack pointer)
    mov rcx, qword ptr [rsp + 000h]                              ; restoring slots to previous scope state
  func$_stringify$parameterCountCheck$continuation:              ; end of parameter count check
  ; Check type of parameter 0, arg (expecting Anything)
  mov rsi, qword ptr [rbp + 038h]                                ; move type of arg to testByte
  mov rax, rsi                                                   ; move testByte to testByte
  mov rdi, 001h                                                  ; read operand of mul (type table width in bytes) 
  mul rdi                                                        ; adjust to the relative start of that type's entry in the type table
  add rax, 000h                                                  ; adjust to the byte containing the bit to check against (result in testByte)
  mov r12, offset typeTable                                      ; read second operand of + (type table pointer)
  add rax, r12                                                   ; finally offset all of that by the start of the type table itself (result in testByte)
  bt qword ptr [rax], 004h                                       ; check that arg is Anything
  jc func$_stringify$arg$TypeMatch                               ; skip next block if the type matches
    ; Error handling block for arg
    ;  - print(parameterTypeCheckFailureMessage)
    ; Call __print with 1 arguments
    mov r13, offset parameterTypeCheckFailureMessage             ; reading parameterTypeCheckFailureMessage for push
    push r13                                                     ; value of argument #1 (parameterTypeCheckFailureMessage)
    push 016h                                                    ; type of argument #1 (String'22)
    lea r14, qword ptr [rsp + 020h]                              ; load address of return value's value
    push r14                                                     ; internal argument 6: pointer to return value slot's value
    lea r14, qword ptr [rsp + 020h]                              ; load address of return value's type
    push r14                                                     ; internal argument 5: pointer to return value slot's type
    sub rsp, 020h                                                ; allocate shadow space
    mov r9, 000h                                                 ; internal argument 4: "this" pointer
    mov r8, 000h                                                 ; internal argument 3: "this" pointer type
    mov rdx, 000h                                                ; internal argument 2: closure pointer
    mov qword ptr [rsp + 040h], rcx                              ; move parameter count of _stringify value out of rcx
    mov rcx, 001h                                                ; internal argument 1: number of actual arguments
    call func$__print                                            ; jump to subroutine
    add rsp, 040h                                                ; release shadow space and arguments (result in stack pointer)
    ;  - exit(1)
    ; Call exit with 1 arguments
    push 001h                                                    ; value of argument #1 (1 (integer))
    push 015h                                                    ; type of argument #1 (Integer'21)
    lea r15, qword ptr [rsp + 020h]                              ; load address of return value's value
    push r15                                                     ; internal argument 6: pointer to return value slot's value
    lea r15, qword ptr [rsp + 020h]                              ; load address of return value's type
    push r15                                                     ; internal argument 5: pointer to return value slot's type
    sub rsp, 020h                                                ; allocate shadow space
    mov r9, 000h                                                 ; internal argument 4: "this" pointer
    mov r8, 000h                                                 ; internal argument 3: "this" pointer type
    mov rdx, 000h                                                ; internal argument 2: closure pointer
    mov rcx, 001h                                                ; internal argument 1: number of actual arguments
    call func$exit                                               ; jump to subroutine
    add rsp, 040h                                                ; release shadow space and arguments (result in stack pointer)
    mov rcx, qword ptr [rsp + 000h]                              ; restoring slots to previous scope state
  func$_stringify$arg$TypeMatch:                                 ; after block
  ; Line 153: if (arg is String) { ...
  mov r10, qword ptr [rbp + 038h]                                ; move type of arg to testByte
  mov rax, r10                                                   ; move testByte to testByte
  mov rbx, 001h                                                  ; read operand of mul (type table width in bytes) 
  mul rbx                                                        ; adjust to the relative start of that type's entry in the type table
  add rax, 000h                                                  ; adjust to the byte containing the bit to check against (result in testByte)
  mov rsi, offset typeTable                                      ; read second operand of + (type table pointer)
  add rax, rsi                                                   ; finally offset all of that by the start of the type table itself (result in testByte)
  bt qword ptr [rax], 003h                                       ; check that arg is String
  mov rdi, 000h                                                  ; clear is expression result
  setc dil                                                       ; store result in is expression result
  mov r12, 014h                                                  ; is expression result is of type Boolean'20
  cmp rdi, 000h                                                  ; compare is expression result to false
  je func$_stringify$if$continuation                             ; arg is String
    ; Line 154: return arg;
    mov r13, qword ptr [rbp + 038h]                              ; move type of arg to testByte
    mov rax, r13                                                 ; move testByte to testByte
    mov r14, 001h                                                ; read operand of mul (type table width in bytes) 
    mul r14                                                      ; adjust to the relative start of that type's entry in the type table
    add rax, 000h                                                ; adjust to the byte containing the bit to check against (result in testByte)
    mov r15, offset typeTable                                    ; read second operand of + (type table pointer)
    add rax, r15                                                 ; finally offset all of that by the start of the type table itself (result in testByte)
    bt qword ptr [rax], 003h                                     ; check that _stringify return value is String
    jc func$_stringify$Stringify$if$StringifyReturnValue$TypeMatch ; skip next block if the type matches
      ; Error handling block for _stringify return value
      ;  - print(returnValueTypeCheckFailureMessage)
      ; Call __print with 1 arguments
      mov r9, offset returnValueTypeCheckFailureMessage          ; reading returnValueTypeCheckFailureMessage for push
      push r9                                                    ; value of argument #1 (returnValueTypeCheckFailureMessage)
      push 016h                                                  ; type of argument #1 (String'22)
      lea r8, qword ptr [rsp + 020h]                             ; load address of return value's value
      push r8                                                    ; internal argument 6: pointer to return value slot's value
      lea r8, qword ptr [rsp + 020h]                             ; load address of return value's type
      push r8                                                    ; internal argument 5: pointer to return value slot's type
      sub rsp, 020h                                              ; allocate shadow space
      mov r9, 000h                                               ; internal argument 4: "this" pointer
      mov r8, 000h                                               ; internal argument 3: "this" pointer type
      mov rdx, 000h                                              ; internal argument 2: closure pointer
      mov qword ptr [rsp + 040h], rcx                            ; move parameter count of _stringify value out of rcx
      mov rcx, 001h                                              ; internal argument 1: number of actual arguments
      call func$__print                                          ; jump to subroutine
      add rsp, 040h                                              ; release shadow space and arguments (result in stack pointer)
      ;  - exit(1)
      ; Call exit with 1 arguments
      push 001h                                                  ; value of argument #1 (1 (integer))
      push 015h                                                  ; type of argument #1 (Integer'21)
      lea r10, qword ptr [rsp + 020h]                            ; load address of return value's value
      push r10                                                   ; internal argument 6: pointer to return value slot's value
      lea r10, qword ptr [rsp + 020h]                            ; load address of return value's type
      push r10                                                   ; internal argument 5: pointer to return value slot's type
      sub rsp, 020h                                              ; allocate shadow space
      mov r9, 000h                                               ; internal argument 4: "this" pointer
      mov r8, 000h                                               ; internal argument 3: "this" pointer type
      mov rdx, 000h                                              ; internal argument 2: closure pointer
      mov rcx, 001h                                              ; internal argument 1: number of actual arguments
      call func$exit                                             ; jump to subroutine
      add rsp, 040h                                              ; release shadow space and arguments (result in stack pointer)
      mov rcx, qword ptr [rsp + 000h]                            ; restoring slots to previous scope state
    func$_stringify$Stringify$if$StringifyReturnValue$TypeMatch:  ; after block
    mov rbx, qword ptr [rbp + 040h]                              ; read second operand of mov (arg) for MoveToDerefInstruction
    mov rsi, qword ptr [rbp + 030h]                              ; get pointer to return value of _stringify into register to dereference it
    mov qword ptr [rsi], rbx                                     ; _stringify return value
    mov rdi, qword ptr [rbp + 038h]                              ; reading type of arg
    mov r12, qword ptr [rbp + 028h]                              ; get pointer to return value type of _stringify into register to dereference it
    mov qword ptr [r12], rdi                                     ; type of _stringify return value
    ; increment reference count for arg if necessary
    cmp qword ptr [rbp + 038h], 016h                             ; if not a string, skip incref
    jne func$_stringify$Stringify$if$AfterIncref
    mov r13, qword ptr [rbp + 040h]                              ; get arg into register to dereference it
    mov rax, qword ptr [r13]                                     ; dereference string to get to ref count
    cmp rax, 0                                                   ; compare string refcount temporary to 0
    js func$_stringify$Stringify$if$AfterIncref                  ; if ref count is negative (constant strings), skip incref
    add rax, 001h                                                ; increment ref count (result in string refcount temporary)
    mov r14, qword ptr [rbp + 040h]                              ; get arg into register to dereference it
    mov qword ptr [r14], rax                                     ; put it back in the string
    func$_stringify$Stringify$if$AfterIncref:                    ; after incref
    jmp func$_stringify$epilog                                   ; return
  func$_stringify$if$continuation:                               ; end of if
  ; Line 156: if (arg is Boolean) { ...
  mov r15, qword ptr [rbp + 038h]                                ; move type of arg to testByte
  mov rax, r15                                                   ; move testByte to testByte
  mov r10, 001h                                                  ; read operand of mul (type table width in bytes) 
  mul r10                                                        ; adjust to the relative start of that type's entry in the type table
  add rax, 000h                                                  ; adjust to the byte containing the bit to check against (result in testByte)
  mov r9, offset typeTable                                       ; read second operand of + (type table pointer)
  add rax, r9                                                    ; finally offset all of that by the start of the type table itself (result in testByte)
  bt qword ptr [rax], 001h                                       ; check that arg is Boolean
  mov r8, 000h                                                   ; clear is expression result
  setc r8b                                                       ; store result in is expression result
  mov rdx, 014h                                                  ; is expression result is of type Boolean'20
  cmp r8, 000h                                                   ; compare is expression result to false
  je func$_stringify$if$continuation$1                           ; arg is Boolean
    ; Line 157: if (arg) { ...
    cmp qword ptr [rbp + 040h], 000h                             ; compare arg to false
    je func$_stringify$Stringify$if$1$if$continuation            ; arg
      ; Line 158: return 'true';
      mov qword ptr [rsp + 010h], rcx                            ; move parameter count of _stringify value out of rcx
      mov rcx, offset string$16                                  ; read second operand of mov (string) for MoveToDerefInstruction
      mov rbx, qword ptr [rbp + 030h]                            ; get pointer to return value of _stringify into register to dereference it
      mov qword ptr [rbx], rcx                                   ; _stringify return value
      mov rsi, qword ptr [rbp + 028h]                            ; get pointer to return value type of _stringify into register to dereference it
      mov qword ptr [rsi], 016h                                  ; type of _stringify return value (String'22)
      jmp func$_stringify$epilog                                 ; return
    func$_stringify$Stringify$if$1$if$continuation:              ; end of if
    ; Line 160: return 'false';
    mov rdi, offset string$17                                    ; read second operand of mov (string) for MoveToDerefInstruction
    mov r12, qword ptr [rbp + 030h]                              ; get pointer to return value of _stringify into register to dereference it
    mov qword ptr [r12], rdi                                     ; _stringify return value
    mov r13, qword ptr [rbp + 028h]                              ; get pointer to return value type of _stringify into register to dereference it
    mov qword ptr [r13], 016h                                    ; type of _stringify return value (String'22)
    jmp func$_stringify$epilog                                   ; return
  func$_stringify$if$continuation$1:                             ; end of if
  ; Line 162: if (arg is Null) { ...
  mov r14, qword ptr [rbp + 038h]                                ; move type of arg to testByte
  mov rax, r14                                                   ; move testByte to testByte
  mov r15, 001h                                                  ; read operand of mul (type table width in bytes) 
  mul r15                                                        ; adjust to the relative start of that type's entry in the type table
  add rax, 000h                                                  ; adjust to the byte containing the bit to check against (result in testByte)
  mov r10, offset typeTable                                      ; read second operand of + (type table pointer)
  add rax, r10                                                   ; finally offset all of that by the start of the type table itself (result in testByte)
  bt qword ptr [rax], 000h                                       ; check that arg is Null
  mov r9, 000h                                                   ; clear is expression result
  setc r9b                                                       ; store result in is expression result
  mov r8, 014h                                                   ; is expression result is of type Boolean'20
  cmp r9, 000h                                                   ; compare is expression result to false
  je func$_stringify$if$continuation$2                           ; arg is Null
    ; Line 163: return 'null';
    mov rdx, offset string$18                                    ; read second operand of mov (string) for MoveToDerefInstruction
    mov qword ptr [rsp + 010h], rcx                              ; move parameter count of _stringify value out of rcx
    mov rcx, qword ptr [rbp + 030h]                              ; get pointer to return value of _stringify into register to dereference it
    mov qword ptr [rcx], rdx                                     ; _stringify return value
    mov rbx, qword ptr [rbp + 028h]                              ; get pointer to return value type of _stringify into register to dereference it
    mov qword ptr [rbx], 016h                                    ; type of _stringify return value (String'22)
    jmp func$_stringify$epilog                                   ; return
  func$_stringify$if$continuation$2:                             ; end of if
  ; Line 165: if (arg is Integer) { ...
  mov rsi, qword ptr [rbp + 038h]                                ; move type of arg to testByte
  mov rax, rsi                                                   ; move testByte to testByte
  mov rdi, 001h                                                  ; read operand of mul (type table width in bytes) 
  mul rdi                                                        ; adjust to the relative start of that type's entry in the type table
  add rax, 000h                                                  ; adjust to the byte containing the bit to check against (result in testByte)
  mov r12, offset typeTable                                      ; read second operand of + (type table pointer)
  add rax, r12                                                   ; finally offset all of that by the start of the type table itself (result in testByte)
  bt qword ptr [rax], 002h                                       ; check that arg is Integer
  mov r13, 000h                                                  ; clear is expression result
  setc r13b                                                      ; store result in is expression result
  mov r14, 014h                                                  ; is expression result is of type Boolean'20
  cmp r13, 000h                                                  ; compare is expression result to false
  je func$_stringify$if$continuation$3                           ; arg is Integer
    ; Line 166: return intToStr(arg as Integer);
    mov r15, qword ptr [rbp + 038h]                              ; move type of arg to testByte
    mov rax, r15                                                 ; move testByte to testByte
    mov r10, 001h                                                ; read operand of mul (type table width in bytes) 
    mul r10                                                      ; adjust to the relative start of that type's entry in the type table
    add rax, 000h                                                ; adjust to the byte containing the bit to check against (result in testByte)
    mov r9, offset typeTable                                     ; read second operand of + (type table pointer)
    add rax, r9                                                  ; finally offset all of that by the start of the type table itself (result in testByte)
    bt qword ptr [rax], 002h                                     ; check that arg as Integer is Integer
    jc func$_stringify$Stringify$if$3$argAsINteger$TypeMatch     ; skip next block if the type matches
      ; Error handling block for arg as Integer
      ;  - print(asOperatorFailureMessage)
      ; Call __print with 1 arguments
      mov r8, offset asOperatorFailureMessage                    ; reading asOperatorFailureMessage for push
      push r8                                                    ; value of argument #1 (asOperatorFailureMessage)
      push 016h                                                  ; type of argument #1 (String'22)
      lea rdx, qword ptr [rsp + 020h]                            ; load address of return value's value
      push rdx                                                   ; internal argument 6: pointer to return value slot's value
      lea rdx, qword ptr [rsp + 020h]                            ; load address of return value's type
      push rdx                                                   ; internal argument 5: pointer to return value slot's type
      sub rsp, 020h                                              ; allocate shadow space
      mov r9, 000h                                               ; internal argument 4: "this" pointer
      mov r8, 000h                                               ; internal argument 3: "this" pointer type
      mov rdx, 000h                                              ; internal argument 2: closure pointer
      mov qword ptr [rsp + 040h], rcx                            ; move parameter count of _stringify value out of rcx
      mov rcx, 001h                                              ; internal argument 1: number of actual arguments
      call func$__print                                          ; jump to subroutine
      add rsp, 040h                                              ; release shadow space and arguments (result in stack pointer)
      ;  - exit(1)
      ; Call exit with 1 arguments
      push 001h                                                  ; value of argument #1 (1 (integer))
      push 015h                                                  ; type of argument #1 (Integer'21)
      lea rbx, qword ptr [rsp + 020h]                            ; load address of return value's value
      push rbx                                                   ; internal argument 6: pointer to return value slot's value
      lea rbx, qword ptr [rsp + 020h]                            ; load address of return value's type
      push rbx                                                   ; internal argument 5: pointer to return value slot's type
      sub rsp, 020h                                              ; allocate shadow space
      mov r9, 000h                                               ; internal argument 4: "this" pointer
      mov r8, 000h                                               ; internal argument 3: "this" pointer type
      mov rdx, 000h                                              ; internal argument 2: closure pointer
      mov rcx, 001h                                              ; internal argument 1: number of actual arguments
      call func$exit                                             ; jump to subroutine
      add rsp, 040h                                              ; release shadow space and arguments (result in stack pointer)
      mov rcx, qword ptr [rsp + 000h]                            ; restoring slots to previous scope state
    func$_stringify$Stringify$if$3$argAsINteger$TypeMatch:       ; after block
    ; Call intToStr with 1 arguments
    push qword ptr [rbp + 040h]                                  ; value of argument #1 (arg)
    push qword ptr [rbp + 038h]                                  ; type of argument #1
    lea rsi, qword ptr [rsp + 020h]                              ; load address of return value's value
    push rsi                                                     ; internal argument 6: pointer to return value slot's value
    lea rsi, qword ptr [rsp + 020h]                              ; load address of return value's type
    push rsi                                                     ; internal argument 5: pointer to return value slot's type
    sub rsp, 020h                                                ; allocate shadow space
    mov r9, 000h                                                 ; internal argument 4: "this" pointer
    mov r8, 000h                                                 ; internal argument 3: "this" pointer type
    mov rdx, 000h                                                ; internal argument 2: closure pointer
    mov qword ptr [rsp + 040h], rcx                              ; move parameter count of _stringify value out of rcx
    mov rcx, 001h                                                ; internal argument 1: number of actual arguments
    call func$intToStr                                           ; jump to subroutine
    add rsp, 040h                                                ; release shadow space and arguments (result in stack pointer)
    mov rdi, qword ptr [rsp + 010h]                              ; read second operand of mov (intToStr return value) for MoveToDerefInstruction
    mov r12, qword ptr [rbp + 030h]                              ; get pointer to return value of _stringify into register to dereference it
    mov qword ptr [r12], rdi                                     ; _stringify return value
    mov r13, qword ptr [rsp + 008h]                              ; reading type of intToStr return value
    mov r14, qword ptr [rbp + 028h]                              ; get pointer to return value type of _stringify into register to dereference it
    mov qword ptr [r14], r13                                     ; type of _stringify return value
    ; increment reference count for intToStr return value if necessary
    cmp r13, 016h                                                ; if not a string, skip incref
    jne func$_stringify$Stringify$if$3$AfterIncref
    mov r15, qword ptr [rdi]                                     ; dereference string to get to ref count
    cmp r15, 0                                                   ; compare string refcount temporary to 0
    js func$_stringify$Stringify$if$3$AfterIncref                ; if ref count is negative (constant strings), skip incref
    add r15, 001h                                                ; increment ref count (result in string refcount temporary)
    mov qword ptr [rdi], r15                                     ; put it back in the string
    func$_stringify$Stringify$if$3$AfterIncref:                  ; after incref
    ; Calling decref on intToStr return value (static type: String'22)
    sub rsp, 20h                                                 ; allocate shadow space for decref
    mov rdx, r13                                                 ; arg #2: type of potential string
    mov rcx, rdi                                                 ; arg #1: value of potential string
    call intrinsic$decref                                        ; call decref
    add rsp, 20h                                                 ; free shadow space for decref
    jmp func$_stringify$epilog                                   ; return
  func$_stringify$if$continuation$3:                             ; end of if
  ; Line 168: __print('value cannot be stringified\n');
  ; Call __print with 1 arguments
  mov rax, offset string$19                                      ; reading string for push
  push rax                                                       ; value of argument #1 (string)
  push 016h                                                      ; type of argument #1 (String'22)
  lea r10, qword ptr [rsp + 020h]                                ; load address of return value's value
  push r10                                                       ; internal argument 6: pointer to return value slot's value
  lea r10, qword ptr [rsp + 020h]                                ; load address of return value's type
  push r10                                                       ; internal argument 5: pointer to return value slot's type
  sub rsp, 020h                                                  ; allocate shadow space
  mov r9, 000h                                                   ; internal argument 4: "this" pointer
  mov r8, 000h                                                   ; internal argument 3: "this" pointer type
  mov rdx, 000h                                                  ; internal argument 2: closure pointer
  mov qword ptr [rsp + 040h], rcx                                ; move parameter count of _stringify value out of rcx
  mov rcx, 001h                                                  ; internal argument 1: number of actual arguments
  call func$__print                                              ; jump to subroutine
  add rsp, 040h                                                  ; release shadow space and arguments (result in stack pointer)
  ; Line 169: exit(1);
  ; Call exit with 1 arguments
  push 001h                                                      ; value of argument #1 (1)
  push 015h                                                      ; type of argument #1 (Integer'21)
  lea rbx, qword ptr [rsp + 020h]                                ; load address of return value's value
  push rbx                                                       ; internal argument 6: pointer to return value slot's value
  lea rbx, qword ptr [rsp + 020h]                                ; load address of return value's type
  push rbx                                                       ; internal argument 5: pointer to return value slot's type
  sub rsp, 020h                                                  ; allocate shadow space
  mov r9, 000h                                                   ; internal argument 4: "this" pointer
  mov r8, 000h                                                   ; internal argument 3: "this" pointer type
  mov rdx, 000h                                                  ; internal argument 2: closure pointer
  mov rcx, 001h                                                  ; internal argument 1: number of actual arguments
  call func$exit                                                 ; jump to subroutine
  add rsp, 040h                                                  ; release shadow space and arguments (result in stack pointer)
  ; Implicit return from _stringify
  mov rsi, 013h                                                  ; move type of null to testByte
  mov rax, rsi                                                   ; move testByte to testByte
  mov rdi, 001h                                                  ; read operand of mul (type table width in bytes) 
  mul rdi                                                        ; adjust to the relative start of that type's entry in the type table
  add rax, 000h                                                  ; adjust to the byte containing the bit to check against (result in testByte)
  mov r12, offset typeTable                                      ; read second operand of + (type table pointer)
  add rax, r12                                                   ; finally offset all of that by the start of the type table itself (result in testByte)
  bt qword ptr [rax], 003h                                       ; check that _stringify return value is String
  jc func$_stringify$StringifyReturnValue$TypeMatch              ; skip next block if the type matches
    ; Error handling block for _stringify return value
    ;  - print(returnValueTypeCheckFailureMessage)
    ; Call __print with 1 arguments
    mov r13, offset returnValueTypeCheckFailureMessage           ; reading returnValueTypeCheckFailureMessage for push
    push r13                                                     ; value of argument #1 (returnValueTypeCheckFailureMessage)
    push 016h                                                    ; type of argument #1 (String'22)
    lea r14, qword ptr [rsp + 020h]                              ; load address of return value's value
    push r14                                                     ; internal argument 6: pointer to return value slot's value
    lea r14, qword ptr [rsp + 020h]                              ; load address of return value's type
    push r14                                                     ; internal argument 5: pointer to return value slot's type
    sub rsp, 020h                                                ; allocate shadow space
    mov r9, 000h                                                 ; internal argument 4: "this" pointer
    mov r8, 000h                                                 ; internal argument 3: "this" pointer type
    mov rdx, 000h                                                ; internal argument 2: closure pointer
    mov rcx, 001h                                                ; internal argument 1: number of actual arguments
    call func$__print                                            ; jump to subroutine
    add rsp, 040h                                                ; release shadow space and arguments (result in stack pointer)
    ;  - exit(1)
    ; Call exit with 1 arguments
    push 001h                                                    ; value of argument #1 (1 (integer))
    push 015h                                                    ; type of argument #1 (Integer'21)
    lea r15, qword ptr [rsp + 020h]                              ; load address of return value's value
    push r15                                                     ; internal argument 6: pointer to return value slot's value
    lea r15, qword ptr [rsp + 020h]                              ; load address of return value's type
    push r15                                                     ; internal argument 5: pointer to return value slot's type
    sub rsp, 020h                                                ; allocate shadow space
    mov r9, 000h                                                 ; internal argument 4: "this" pointer
    mov r8, 000h                                                 ; internal argument 3: "this" pointer type
    mov rdx, 000h                                                ; internal argument 2: closure pointer
    mov rcx, 001h                                                ; internal argument 1: number of actual arguments
    call func$exit                                               ; jump to subroutine
    add rsp, 040h                                                ; release shadow space and arguments (result in stack pointer)
  func$_stringify$StringifyReturnValue$TypeMatch:                ; after block
  mov r10, qword ptr [rbp + 030h]                                ; get pointer to return value of _stringify into register to dereference it
  mov qword ptr [r10], 000h                                      ; _stringify return value
  mov rbx, qword ptr [rbp + 028h]                                ; get pointer to return value type of _stringify into register to dereference it
  mov qword ptr [rbx], 013h                                      ; type of _stringify return value (Null'19)
  jmp func$_stringify$epilog                                     ; return
  func$_stringify$epilog: 
  mov rax, qword ptr [rbp + 030h]                                ; report address of return value
  ; Epilog
  add rsp, 020h                                                  ; free space for stack
  pop r14                                                        ; restore non-volatile registers
  pop r13                                                        ; restore non-volatile registers
  pop r12                                                        ; restore non-volatile registers
  pop rbp                                                        ; restore non-volatile registers
  pop rdi                                                        ; restore non-volatile registers
  pop rsi                                                        ; restore non-volatile registers
  pop rbx                                                        ; restore non-volatile registers
  pop r15                                                        ; restore non-volatile registers
  ret                                                            ; return from subroutine

; print
func$print:
  ; Prolog
  push r15                                                       ; save non-volatile registers
  push rbx                                                       ; save non-volatile registers
  push rsi                                                       ; save non-volatile registers
  push rdi                                                       ; save non-volatile registers
  push rbp                                                       ; save non-volatile registers
  push r12                                                       ; save non-volatile registers
  push r13                                                       ; save non-volatile registers
  push r14                                                       ; save non-volatile registers
  sub rsp, 058h                                                  ; allocate space for stack
  lea rbp, qword ptr [rsp + 098h]                                ; set up frame pointer
  ; Varargs parameter type check; expecting parameters to be Anything
  lea r10, qword ptr [rbp + 040h]                                ; get base address of varargs, where loop will start
  mov rax, rcx                                                   ; assign value of parameter count of print to value of pointer to last argument
  mov rbx, 010h                                                  ; read operand of mul (10 (integer)) 
  mul rbx                                                        ; end of loop is the number of arguments times the width of each argument (010h)...
  add rax, r10                                                   ; ...offset from the initial index (result in pointer to last argument)
  func$print$varargTypeChecks$Loop:                              ; top of loop
    mov qword ptr [rsp + 048h], 000h                             ; move pointer to indexth argument type into a mutable location
    cmp r10, rax                                                 ; compare pointer to indexth argument to pointer to last argument
    je func$print$varargTypeChecks$TypesAllMatch                 ; we have type-checked all the arguments
    mov rsi, qword ptr [r10 - 008h]                              ; load type of indexth argument into indexth argument
    mov rdi, rsi                                                 ; move type of indexth argument to testByte
    mov qword ptr [rsp + 040h], rax                              ; move pointer to last argument value out of rax
    mov rax, rdi                                                 ; move testByte to testByte
    mov r12, 001h                                                ; read operand of mul (type table width in bytes) 
    mul r12                                                      ; adjust to the relative start of that type's entry in the type table
    add rax, 000h                                                ; adjust to the byte containing the bit to check against (result in testByte)
    mov r13, offset typeTable                                    ; read second operand of + (type table pointer)
    add rax, r13                                                 ; finally offset all of that by the start of the type table itself (result in testByte)
    bt qword ptr [rax], 004h                                     ; check that vararg types is Anything
    jc func$print$varargTypeChecks$TypeMatch                     ; skip next block if the type matches
      ; Error handling block for vararg types
      ;  - print(parameterTypeCheckFailureMessage)
      ; Call __print with 1 arguments
      mov r14, offset parameterTypeCheckFailureMessage           ; reading parameterTypeCheckFailureMessage for push
      push r14                                                   ; value of argument #1 (parameterTypeCheckFailureMessage)
      push 016h                                                  ; type of argument #1 (String'22)
      lea r15, qword ptr [rsp + 048h]                            ; load address of return value's value
      push r15                                                   ; internal argument 6: pointer to return value slot's value
      lea r15, qword ptr [rsp + 048h]                            ; load address of return value's type
      push r15                                                   ; internal argument 5: pointer to return value slot's type
      sub rsp, 020h                                              ; allocate shadow space
      mov r9, 000h                                               ; internal argument 4: "this" pointer
      mov r8, 000h                                               ; internal argument 3: "this" pointer type
      mov rdx, 000h                                              ; internal argument 2: closure pointer
      mov qword ptr [rsp + 068h], rcx                            ; move parameter count of print value out of rcx
      mov rcx, 001h                                              ; internal argument 1: number of actual arguments
      mov qword ptr [rsp + 060h], r10                            ; move pointer to indexth argument value out of r10
      call func$__print                                          ; jump to subroutine
      add rsp, 040h                                              ; release shadow space and arguments (result in stack pointer)
      ;  - exit(1)
      ; Call exit with 1 arguments
      push 001h                                                  ; value of argument #1 (1 (integer))
      push 015h                                                  ; type of argument #1 (Integer'21)
      lea r10, qword ptr [rsp + 048h]                            ; load address of return value's value
      push r10                                                   ; internal argument 6: pointer to return value slot's value
      lea r10, qword ptr [rsp + 048h]                            ; load address of return value's type
      push r10                                                   ; internal argument 5: pointer to return value slot's type
      sub rsp, 020h                                              ; allocate shadow space
      mov r9, 000h                                               ; internal argument 4: "this" pointer
      mov r8, 000h                                               ; internal argument 3: "this" pointer type
      mov rdx, 000h                                              ; internal argument 2: closure pointer
      mov rcx, 001h                                              ; internal argument 1: number of actual arguments
      call func$exit                                             ; jump to subroutine
      add rsp, 040h                                              ; release shadow space and arguments (result in stack pointer)
      mov r10, qword ptr [rsp + 020h]                            ; restoring slots to previous scope state
      mov rcx, qword ptr [rsp + 028h]                            ; restoring slots to previous scope state
    func$print$varargTypeChecks$TypeMatch:                       ; after block
    add r10, 010h                                                ; next argument (result in pointer to indexth argument)
    mov rax, qword ptr [rsp + 040h]                              ; restoring slots to previous scope state
    jmp func$print$varargTypeChecks$Loop                         ; return to top of loop
    func$print$varargTypeChecks$TypesAllMatch:                   ; after loop
    mov rax, qword ptr [rsp + 040h]                              ; restoring slots to previous scope state
  ; Line 173: Boolean first = true;
  mov rbx, 001h                                                  ; value initialization of variable declaration for first variable (true)
  mov rsi, 014h                                                  ; type initialization of variable declaration for first variable (Boolean'20)
  ; Line 174: Integer index = 0;
  mov rdi, 000h                                                  ; value initialization of variable declaration for index variable (0)
  mov rax, 015h                                                  ; type initialization of variable declaration for index variable (Integer'21)
  func$print$while$top:                                          ; top of while
    ; Call len with 1 arguments
    xor r12, r12                                                 ; clear < operator result
    cmp rdi, rcx                                                 ; compare index variable with parameter count of print
    setl r12b                                                    ; store result in < operator result
    mov r13, 014h                                                ; < operator result is of type Boolean'20
    cmp r12, 000h                                                ; compare < operator result to false
    jne func$print$while$body                                    ; while condition
    jmp func$print$while$bottom                                  ; break out of while
    func$print$while$body:                                       ; start of while
    ; Line 176: if (first == false) { ...
    xor r14, r14                                                 ; zero value result of == (testing first variable and false) to put the boolean in
    cmp rbx, 000h                                                ; values equal?
    sete r14b                                                    ; put result in value result of == (testing first variable and false)
    mov r15, 014h                                                ; value result of == (testing first variable and false) is a Boolean'20
    xor r10, r10                                                 ; zero type result of == (testing first variable and false) to put the boolean in
    cmp rsi, 014h                                                ; types equal?
    sete r10b                                                    ; put result in type result of == (testing first variable and false)
    mov r9, 014h                                                 ; type result of == (testing first variable and false) is a Boolean'20
    mov r8, r14                                                  ; assign value of value result of == (testing first variable and false) to value of == operator result
    and r8, r10                                                  ; && type temp and value temp
    mov rdx, 014h                                                ; == operator result is of type Boolean'20
    cmp r8, 000h                                                 ; compare == operator result to false
    je func$print$while$if$continuation                          ; first == false
      ; Line 177: __print(' ');
      ; Call __print with 1 arguments
      mov qword ptr [rsp + 048h], rcx                            ; move parameter count of print value out of rcx
      mov rcx, offset string$20                                  ; reading string for push
      push rcx                                                   ; value of argument #1 (string)
      push 016h                                                  ; type of argument #1 (String'22)
      mov qword ptr [rsp + 048h], rbx                            ; move first variable value out of rbx
      lea rbx, qword ptr [rsp + 050h]                            ; load address of return value's value
      push rbx                                                   ; internal argument 6: pointer to return value slot's value
      lea rbx, qword ptr [rsp + 048h]                            ; load address of return value's type
      push rbx                                                   ; internal argument 5: pointer to return value slot's type
      sub rsp, 020h                                              ; allocate shadow space
      mov r9, 000h                                               ; internal argument 4: "this" pointer
      mov r8, 000h                                               ; internal argument 3: "this" pointer type
      mov rdx, 000h                                              ; internal argument 2: closure pointer
      mov rcx, 001h                                              ; internal argument 1: number of actual arguments
      mov qword ptr [rsp + 068h], rax                            ; move index variable type out of rax
      call func$__print                                          ; jump to subroutine
      add rsp, 040h                                              ; release shadow space and arguments (result in stack pointer)
      mov rax, qword ptr [rsp + 028h]                            ; restoring slots to previous scope state
      mov rbx, qword ptr [rsp + 038h]                            ; restoring slots to previous scope state
      mov rcx, qword ptr [rsp + 048h]                            ; restoring slots to previous scope state
    func$print$while$if$continuation:                            ; end of if
    ; Line 179: __print(_stringify(parts[index]));
    cmp rdi, rcx                                                 ; compare index variable to parameter count of print
    jge func$print$while$subscript$boundsError                   ; index out of range (too high)
    cmp rdi, 000h                                                ; compare index variable to 0 (integer)
    jge func$print$while$subscript$inBounds                      ; index not out of range (not negative)
    func$print$while$subscript$boundsError:                      ; invalid index
      ; Error handling block for subscript bounds error
      ;  - print(boundsFailureMessage)
      ; Call __print with 1 arguments
      mov qword ptr [rsp + 048h], rsi                            ; move first variable type out of rsi
      mov rsi, offset boundsFailureMessage                       ; reading boundsFailureMessage for push
      push rsi                                                   ; value of argument #1 (boundsFailureMessage)
      push 016h                                                  ; type of argument #1 (String'22)
      mov qword ptr [rsp + 048h], rdi                            ; move index variable value out of rdi
      lea rdi, qword ptr [rsp + 050h]                            ; load address of return value's value
      push rdi                                                   ; internal argument 6: pointer to return value slot's value
      lea rdi, qword ptr [rsp + 048h]                            ; load address of return value's type
      push rdi                                                   ; internal argument 5: pointer to return value slot's type
      sub rsp, 020h                                              ; allocate shadow space
      mov r9, 000h                                               ; internal argument 4: "this" pointer
      mov r8, 000h                                               ; internal argument 3: "this" pointer type
      mov rdx, 000h                                              ; internal argument 2: closure pointer
      mov qword ptr [rsp + 068h], rcx                            ; move parameter count of print value out of rcx
      mov rcx, 001h                                              ; internal argument 1: number of actual arguments
      mov qword ptr [rsp + 060h], rax                            ; move index variable type out of rax
      call func$__print                                          ; jump to subroutine
      add rsp, 040h                                              ; release shadow space and arguments (result in stack pointer)
      ;  - exit(1)
      ; Call exit with 1 arguments
      push 001h                                                  ; value of argument #1 (1 (integer))
      push 015h                                                  ; type of argument #1 (Integer'21)
      lea rax, qword ptr [rsp + 050h]                            ; load address of return value's value
      push rax                                                   ; internal argument 6: pointer to return value slot's value
      lea rax, qword ptr [rsp + 048h]                            ; load address of return value's type
      push rax                                                   ; internal argument 5: pointer to return value slot's type
      sub rsp, 020h                                              ; allocate shadow space
      mov r9, 000h                                               ; internal argument 4: "this" pointer
      mov r8, 000h                                               ; internal argument 3: "this" pointer type
      mov rdx, 000h                                              ; internal argument 2: closure pointer
      mov rcx, 001h                                              ; internal argument 1: number of actual arguments
      call func$exit                                             ; jump to subroutine
      add rsp, 040h                                              ; release shadow space and arguments (result in stack pointer)
      mov rax, qword ptr [rsp + 020h]                            ; restoring slots to previous scope state
      mov rcx, qword ptr [rsp + 028h]                            ; restoring slots to previous scope state
      mov rsi, qword ptr [rsp + 048h]                            ; restoring slots to previous scope state
      mov rdi, qword ptr [rsp + 038h]                            ; restoring slots to previous scope state
    func$print$while$subscript$inBounds:                         ; valid index
    lea r12, qword ptr [rbp + 040h]                              ; base address of varargs
    mov r13, rdi                                                 ; assign value of index variable to value of index into list * 16
    shl r13, 004h                                                ; multiply by 8*2
    mov r14, r12                                                 ; assign value of base address of varargs to value of pointer to value (and type, later)
    add r14, r13                                                 ; get pointer to value (result in pointer to value (and type, later))
    mov r15, qword ptr [r14]                                     ; store value
    mov r10, qword ptr [r14 - 008h]                              ; store type
    ; increment reference count for parts[index] if necessary
    cmp r10, 016h                                                ; if not a string, skip incref
    jne func$print$while$AfterIncref
    mov qword ptr [rsp + 048h], rbx                              ; move first variable value out of rbx
    mov rbx, qword ptr [r15]                                     ; dereference string to get to ref count
    cmp rbx, 0                                                   ; compare string refcount temporary to 0
    js func$print$while$AfterIncref                              ; if ref count is negative (constant strings), skip incref
    add rbx, 001h                                                ; increment ref count (result in string refcount temporary)
    mov qword ptr [r15], rbx                                     ; put it back in the string
    func$print$while$AfterIncref:                                ; after incref
    ; Call _stringify with 1 arguments
    push r15                                                     ; value of argument #1 (parts[index])
    push r10                                                     ; type of argument #1
    mov qword ptr [rsp + 048h], rsi                              ; move first variable type out of rsi
    lea rsi, qword ptr [rsp + 050h]                              ; load address of return value's value
    push rsi                                                     ; internal argument 6: pointer to return value slot's value
    lea rsi, qword ptr [rsp + 048h]                              ; load address of return value's type
    push rsi                                                     ; internal argument 5: pointer to return value slot's type
    sub rsp, 020h                                                ; allocate shadow space
    mov r9, 000h                                                 ; internal argument 4: "this" pointer
    mov r8, 000h                                                 ; internal argument 3: "this" pointer type
    mov rdx, 000h                                                ; internal argument 2: closure pointer
    mov qword ptr [rsp + 068h], rcx                              ; move parameter count of print value out of rcx
    mov rcx, 001h                                                ; internal argument 1: number of actual arguments
    mov qword ptr [rsp + 060h], r10                              ; move parts[index] type out of r10
    mov qword ptr [rsp + 058h], rax                              ; move index variable type out of rax
    call func$_stringify                                         ; jump to subroutine
    add rsp, 040h                                                ; release shadow space and arguments (result in stack pointer)
    ; Call __print with 1 arguments
    push qword ptr [rsp + 040h]                                  ; value of argument #1 (_stringify return value)
    push qword ptr [rsp + 038h]                                  ; type of argument #1
    mov qword ptr [rsp + 018h], rdi                              ; move index variable value out of rdi
    lea rdi, qword ptr [rsp + 020h]                              ; load address of return value's value
    push rdi                                                     ; internal argument 6: pointer to return value slot's value
    lea rdi, qword ptr [rsp + 018h]                              ; load address of return value's type
    push rdi                                                     ; internal argument 5: pointer to return value slot's type
    sub rsp, 020h                                                ; allocate shadow space
    mov r9, 000h                                                 ; internal argument 4: "this" pointer
    mov r8, 000h                                                 ; internal argument 3: "this" pointer type
    mov rdx, 000h                                                ; internal argument 2: closure pointer
    mov rcx, 001h                                                ; internal argument 1: number of actual arguments
    call func$__print                                            ; jump to subroutine
    add rsp, 040h                                                ; release shadow space and arguments (result in stack pointer)
    ; Line 180: first = false;
    mov qword ptr [rsp + 048h], 000h                             ; store value
    mov qword ptr [rsp + 038h], 014h                             ; store type (Boolean'20)
    ; Line 181: index += 1;
    mov rax, qword ptr [rsp + 008h]                              ; assign value of index variable to value of += operator result
    add rax, 001h                                                ; += operator
    mov r12, 015h                                                ; += operator result is of type Integer'21
    mov qword ptr [rsp + 008h], rax                              ; store value
    mov qword ptr [rsp + 018h], r12                              ; store type
    ; Calling decref on _stringify return value (static type: String'22)
    sub rsp, 20h                                                 ; allocate shadow space for decref
    mov rdx, qword ptr [rsp + 050h]                              ; arg #2: type of potential string
    mov rcx, qword ptr [rsp + 060h]                              ; arg #1: value of potential string
    call intrinsic$decref                                        ; call decref
    add rsp, 20h                                                 ; free shadow space for decref
    ; Calling decref on parts[index] (static type: Anything'23)
    sub rsp, 20h                                                 ; allocate shadow space for decref
    mov rdx, qword ptr [rsp + 040h]                              ; arg #2: type of potential string
    mov rcx, r15                                                 ; arg #1: value of potential string
    call intrinsic$decref                                        ; call decref
    add rsp, 20h                                                 ; free shadow space for decref
    mov rax, qword ptr [rsp + 018h]                              ; restoring slots to previous scope state
    mov rbx, qword ptr [rsp + 048h]                              ; restoring slots to previous scope state
    mov rcx, qword ptr [rsp + 028h]                              ; restoring slots to previous scope state
    mov rsi, qword ptr [rsp + 038h]                              ; restoring slots to previous scope state
    mov rdi, qword ptr [rsp + 008h]                              ; restoring slots to previous scope state
    jmp func$print$while$top                                     ; return to top of while
  func$print$while$bottom:                                       ; bottom of while
  ; Implicit return from print
  mov r13, qword ptr [rbp + 030h]                                ; get pointer to return value of print into register to dereference it
  mov qword ptr [r13], 000h                                      ; print return value
  mov r14, qword ptr [rbp + 028h]                                ; get pointer to return value type of print into register to dereference it
  mov qword ptr [r14], 013h                                      ; type of print return value (Null'19)
  jmp func$print$epilog                                          ; return
  func$print$epilog: 
  mov rax, qword ptr [rbp + 030h]                                ; report address of return value
  ; Epilog
  add rsp, 058h                                                  ; free space for stack
  pop r14                                                        ; restore non-volatile registers
  pop r13                                                        ; restore non-volatile registers
  pop r12                                                        ; restore non-volatile registers
  pop rbp                                                        ; restore non-volatile registers
  pop rdi                                                        ; restore non-volatile registers
  pop rsi                                                        ; restore non-volatile registers
  pop rbx                                                        ; restore non-volatile registers
  pop r15                                                        ; restore non-volatile registers
  ret                                                            ; return from subroutine

; println
func$println:
  ; Prolog
  push r15                                                       ; save non-volatile registers
  push rbx                                                       ; save non-volatile registers
  push rsi                                                       ; save non-volatile registers
  push rdi                                                       ; save non-volatile registers
  push rbp                                                       ; save non-volatile registers
  push r12                                                       ; save non-volatile registers
  push r13                                                       ; save non-volatile registers
  push r14                                                       ; save non-volatile registers
  sub rsp, 058h                                                  ; allocate space for stack
  lea rbp, qword ptr [rsp + 098h]                                ; set up frame pointer
  ; Varargs parameter type check; expecting parameters to be Anything
  lea r10, qword ptr [rbp + 040h]                                ; get base address of varargs, where loop will start
  mov rax, rcx                                                   ; assign value of parameter count of println to value of pointer to last argument
  mov rbx, 010h                                                  ; read operand of mul (10 (integer)) 
  mul rbx                                                        ; end of loop is the number of arguments times the width of each argument (010h)...
  add rax, r10                                                   ; ...offset from the initial index (result in pointer to last argument)
  func$println$varargTypeChecks$Loop:                            ; top of loop
    mov qword ptr [rsp + 048h], 000h                             ; move pointer to indexth argument type into a mutable location
    cmp r10, rax                                                 ; compare pointer to indexth argument to pointer to last argument
    je func$println$varargTypeChecks$TypesAllMatch               ; we have type-checked all the arguments
    mov rsi, qword ptr [r10 - 008h]                              ; load type of indexth argument into indexth argument
    mov rdi, rsi                                                 ; move type of indexth argument to testByte
    mov qword ptr [rsp + 040h], rax                              ; move pointer to last argument value out of rax
    mov rax, rdi                                                 ; move testByte to testByte
    mov r12, 001h                                                ; read operand of mul (type table width in bytes) 
    mul r12                                                      ; adjust to the relative start of that type's entry in the type table
    add rax, 000h                                                ; adjust to the byte containing the bit to check against (result in testByte)
    mov r13, offset typeTable                                    ; read second operand of + (type table pointer)
    add rax, r13                                                 ; finally offset all of that by the start of the type table itself (result in testByte)
    bt qword ptr [rax], 004h                                     ; check that vararg types is Anything
    jc func$println$varargTypeChecks$TypeMatch                   ; skip next block if the type matches
      ; Error handling block for vararg types
      ;  - print(parameterTypeCheckFailureMessage)
      ; Call __print with 1 arguments
      mov r14, offset parameterTypeCheckFailureMessage           ; reading parameterTypeCheckFailureMessage for push
      push r14                                                   ; value of argument #1 (parameterTypeCheckFailureMessage)
      push 016h                                                  ; type of argument #1 (String'22)
      lea r15, qword ptr [rsp + 048h]                            ; load address of return value's value
      push r15                                                   ; internal argument 6: pointer to return value slot's value
      lea r15, qword ptr [rsp + 048h]                            ; load address of return value's type
      push r15                                                   ; internal argument 5: pointer to return value slot's type
      sub rsp, 020h                                              ; allocate shadow space
      mov r9, 000h                                               ; internal argument 4: "this" pointer
      mov r8, 000h                                               ; internal argument 3: "this" pointer type
      mov rdx, 000h                                              ; internal argument 2: closure pointer
      mov qword ptr [rsp + 068h], rcx                            ; move parameter count of println value out of rcx
      mov rcx, 001h                                              ; internal argument 1: number of actual arguments
      mov qword ptr [rsp + 060h], r10                            ; move pointer to indexth argument value out of r10
      call func$__print                                          ; jump to subroutine
      add rsp, 040h                                              ; release shadow space and arguments (result in stack pointer)
      ;  - exit(1)
      ; Call exit with 1 arguments
      push 001h                                                  ; value of argument #1 (1 (integer))
      push 015h                                                  ; type of argument #1 (Integer'21)
      lea r10, qword ptr [rsp + 048h]                            ; load address of return value's value
      push r10                                                   ; internal argument 6: pointer to return value slot's value
      lea r10, qword ptr [rsp + 048h]                            ; load address of return value's type
      push r10                                                   ; internal argument 5: pointer to return value slot's type
      sub rsp, 020h                                              ; allocate shadow space
      mov r9, 000h                                               ; internal argument 4: "this" pointer
      mov r8, 000h                                               ; internal argument 3: "this" pointer type
      mov rdx, 000h                                              ; internal argument 2: closure pointer
      mov rcx, 001h                                              ; internal argument 1: number of actual arguments
      call func$exit                                             ; jump to subroutine
      add rsp, 040h                                              ; release shadow space and arguments (result in stack pointer)
      mov r10, qword ptr [rsp + 020h]                            ; restoring slots to previous scope state
      mov rcx, qword ptr [rsp + 028h]                            ; restoring slots to previous scope state
    func$println$varargTypeChecks$TypeMatch:                     ; after block
    add r10, 010h                                                ; next argument (result in pointer to indexth argument)
    mov rax, qword ptr [rsp + 040h]                              ; restoring slots to previous scope state
    jmp func$println$varargTypeChecks$Loop                       ; return to top of loop
    func$println$varargTypeChecks$TypesAllMatch:                 ; after loop
    mov rax, qword ptr [rsp + 040h]                              ; restoring slots to previous scope state
  ; Line 186: Boolean first = true;
  mov rbx, 001h                                                  ; value initialization of variable declaration for first variable (true)
  mov rsi, 014h                                                  ; type initialization of variable declaration for first variable (Boolean'20)
  ; Line 187: Integer index = 0;
  mov rdi, 000h                                                  ; value initialization of variable declaration for index variable (0)
  mov rax, 015h                                                  ; type initialization of variable declaration for index variable (Integer'21)
  func$println$while$top:                                        ; top of while
    ; Call len with 1 arguments
    xor r12, r12                                                 ; clear < operator result
    cmp rdi, rcx                                                 ; compare index variable with parameter count of println
    setl r12b                                                    ; store result in < operator result
    mov r13, 014h                                                ; < operator result is of type Boolean'20
    cmp r12, 000h                                                ; compare < operator result to false
    jne func$println$while$body                                  ; while condition
    jmp func$println$while$bottom                                ; break out of while
    func$println$while$body:                                     ; start of while
    ; Line 189: if (first == false) { ...
    xor r14, r14                                                 ; zero value result of == (testing first variable and false) to put the boolean in
    cmp rbx, 000h                                                ; values equal?
    sete r14b                                                    ; put result in value result of == (testing first variable and false)
    mov r15, 014h                                                ; value result of == (testing first variable and false) is a Boolean'20
    xor r10, r10                                                 ; zero type result of == (testing first variable and false) to put the boolean in
    cmp rsi, 014h                                                ; types equal?
    sete r10b                                                    ; put result in type result of == (testing first variable and false)
    mov r9, 014h                                                 ; type result of == (testing first variable and false) is a Boolean'20
    mov r8, r14                                                  ; assign value of value result of == (testing first variable and false) to value of == operator result
    and r8, r10                                                  ; && type temp and value temp
    mov rdx, 014h                                                ; == operator result is of type Boolean'20
    cmp r8, 000h                                                 ; compare == operator result to false
    je func$println$while$if$continuation                        ; first == false
      ; Line 190: __print(' ');
      ; Call __print with 1 arguments
      mov qword ptr [rsp + 048h], rcx                            ; move parameter count of println value out of rcx
      mov rcx, offset string$20                                  ; reading string for push
      push rcx                                                   ; value of argument #1 (string)
      push 016h                                                  ; type of argument #1 (String'22)
      mov qword ptr [rsp + 048h], rbx                            ; move first variable value out of rbx
      lea rbx, qword ptr [rsp + 050h]                            ; load address of return value's value
      push rbx                                                   ; internal argument 6: pointer to return value slot's value
      lea rbx, qword ptr [rsp + 048h]                            ; load address of return value's type
      push rbx                                                   ; internal argument 5: pointer to return value slot's type
      sub rsp, 020h                                              ; allocate shadow space
      mov r9, 000h                                               ; internal argument 4: "this" pointer
      mov r8, 000h                                               ; internal argument 3: "this" pointer type
      mov rdx, 000h                                              ; internal argument 2: closure pointer
      mov rcx, 001h                                              ; internal argument 1: number of actual arguments
      mov qword ptr [rsp + 068h], rax                            ; move index variable type out of rax
      call func$__print                                          ; jump to subroutine
      add rsp, 040h                                              ; release shadow space and arguments (result in stack pointer)
      mov rax, qword ptr [rsp + 028h]                            ; restoring slots to previous scope state
      mov rbx, qword ptr [rsp + 038h]                            ; restoring slots to previous scope state
      mov rcx, qword ptr [rsp + 048h]                            ; restoring slots to previous scope state
    func$println$while$if$continuation:                          ; end of if
    ; Line 192: __print(_stringify(parts[index]));
    cmp rdi, rcx                                                 ; compare index variable to parameter count of println
    jge func$println$while$subscript$boundsError                 ; index out of range (too high)
    cmp rdi, 000h                                                ; compare index variable to 0 (integer)
    jge func$println$while$subscript$inBounds                    ; index not out of range (not negative)
    func$println$while$subscript$boundsError:                    ; invalid index
      ; Error handling block for subscript bounds error
      ;  - print(boundsFailureMessage)
      ; Call __print with 1 arguments
      mov qword ptr [rsp + 048h], rsi                            ; move first variable type out of rsi
      mov rsi, offset boundsFailureMessage                       ; reading boundsFailureMessage for push
      push rsi                                                   ; value of argument #1 (boundsFailureMessage)
      push 016h                                                  ; type of argument #1 (String'22)
      mov qword ptr [rsp + 048h], rdi                            ; move index variable value out of rdi
      lea rdi, qword ptr [rsp + 050h]                            ; load address of return value's value
      push rdi                                                   ; internal argument 6: pointer to return value slot's value
      lea rdi, qword ptr [rsp + 048h]                            ; load address of return value's type
      push rdi                                                   ; internal argument 5: pointer to return value slot's type
      sub rsp, 020h                                              ; allocate shadow space
      mov r9, 000h                                               ; internal argument 4: "this" pointer
      mov r8, 000h                                               ; internal argument 3: "this" pointer type
      mov rdx, 000h                                              ; internal argument 2: closure pointer
      mov qword ptr [rsp + 068h], rcx                            ; move parameter count of println value out of rcx
      mov rcx, 001h                                              ; internal argument 1: number of actual arguments
      mov qword ptr [rsp + 060h], rax                            ; move index variable type out of rax
      call func$__print                                          ; jump to subroutine
      add rsp, 040h                                              ; release shadow space and arguments (result in stack pointer)
      ;  - exit(1)
      ; Call exit with 1 arguments
      push 001h                                                  ; value of argument #1 (1 (integer))
      push 015h                                                  ; type of argument #1 (Integer'21)
      lea rax, qword ptr [rsp + 050h]                            ; load address of return value's value
      push rax                                                   ; internal argument 6: pointer to return value slot's value
      lea rax, qword ptr [rsp + 048h]                            ; load address of return value's type
      push rax                                                   ; internal argument 5: pointer to return value slot's type
      sub rsp, 020h                                              ; allocate shadow space
      mov r9, 000h                                               ; internal argument 4: "this" pointer
      mov r8, 000h                                               ; internal argument 3: "this" pointer type
      mov rdx, 000h                                              ; internal argument 2: closure pointer
      mov rcx, 001h                                              ; internal argument 1: number of actual arguments
      call func$exit                                             ; jump to subroutine
      add rsp, 040h                                              ; release shadow space and arguments (result in stack pointer)
      mov rax, qword ptr [rsp + 020h]                            ; restoring slots to previous scope state
      mov rcx, qword ptr [rsp + 028h]                            ; restoring slots to previous scope state
      mov rsi, qword ptr [rsp + 048h]                            ; restoring slots to previous scope state
      mov rdi, qword ptr [rsp + 038h]                            ; restoring slots to previous scope state
    func$println$while$subscript$inBounds:                       ; valid index
    lea r12, qword ptr [rbp + 040h]                              ; base address of varargs
    mov r13, rdi                                                 ; assign value of index variable to value of index into list * 16
    shl r13, 004h                                                ; multiply by 8*2
    mov r14, r12                                                 ; assign value of base address of varargs to value of pointer to value (and type, later)
    add r14, r13                                                 ; get pointer to value (result in pointer to value (and type, later))
    mov r15, qword ptr [r14]                                     ; store value
    mov r10, qword ptr [r14 - 008h]                              ; store type
    ; increment reference count for parts[index] if necessary
    cmp r10, 016h                                                ; if not a string, skip incref
    jne func$println$while$AfterIncref
    mov qword ptr [rsp + 048h], rbx                              ; move first variable value out of rbx
    mov rbx, qword ptr [r15]                                     ; dereference string to get to ref count
    cmp rbx, 0                                                   ; compare string refcount temporary to 0
    js func$println$while$AfterIncref                            ; if ref count is negative (constant strings), skip incref
    add rbx, 001h                                                ; increment ref count (result in string refcount temporary)
    mov qword ptr [r15], rbx                                     ; put it back in the string
    func$println$while$AfterIncref:                              ; after incref
    ; Call _stringify with 1 arguments
    push r15                                                     ; value of argument #1 (parts[index])
    push r10                                                     ; type of argument #1
    mov qword ptr [rsp + 048h], rsi                              ; move first variable type out of rsi
    lea rsi, qword ptr [rsp + 050h]                              ; load address of return value's value
    push rsi                                                     ; internal argument 6: pointer to return value slot's value
    lea rsi, qword ptr [rsp + 048h]                              ; load address of return value's type
    push rsi                                                     ; internal argument 5: pointer to return value slot's type
    sub rsp, 020h                                                ; allocate shadow space
    mov r9, 000h                                                 ; internal argument 4: "this" pointer
    mov r8, 000h                                                 ; internal argument 3: "this" pointer type
    mov rdx, 000h                                                ; internal argument 2: closure pointer
    mov qword ptr [rsp + 068h], rcx                              ; move parameter count of println value out of rcx
    mov rcx, 001h                                                ; internal argument 1: number of actual arguments
    mov qword ptr [rsp + 060h], r10                              ; move parts[index] type out of r10
    mov qword ptr [rsp + 058h], rax                              ; move index variable type out of rax
    call func$_stringify                                         ; jump to subroutine
    add rsp, 040h                                                ; release shadow space and arguments (result in stack pointer)
    ; Call __print with 1 arguments
    push qword ptr [rsp + 040h]                                  ; value of argument #1 (_stringify return value)
    push qword ptr [rsp + 038h]                                  ; type of argument #1
    mov qword ptr [rsp + 018h], rdi                              ; move index variable value out of rdi
    lea rdi, qword ptr [rsp + 020h]                              ; load address of return value's value
    push rdi                                                     ; internal argument 6: pointer to return value slot's value
    lea rdi, qword ptr [rsp + 018h]                              ; load address of return value's type
    push rdi                                                     ; internal argument 5: pointer to return value slot's type
    sub rsp, 020h                                                ; allocate shadow space
    mov r9, 000h                                                 ; internal argument 4: "this" pointer
    mov r8, 000h                                                 ; internal argument 3: "this" pointer type
    mov rdx, 000h                                                ; internal argument 2: closure pointer
    mov rcx, 001h                                                ; internal argument 1: number of actual arguments
    call func$__print                                            ; jump to subroutine
    add rsp, 040h                                                ; release shadow space and arguments (result in stack pointer)
    ; Line 193: first = false;
    mov qword ptr [rsp + 048h], 000h                             ; store value
    mov qword ptr [rsp + 038h], 014h                             ; store type (Boolean'20)
    ; Line 194: index += 1;
    mov rax, qword ptr [rsp + 008h]                              ; assign value of index variable to value of += operator result
    add rax, 001h                                                ; += operator
    mov r12, 015h                                                ; += operator result is of type Integer'21
    mov qword ptr [rsp + 008h], rax                              ; store value
    mov qword ptr [rsp + 018h], r12                              ; store type
    ; Calling decref on parts[index] (static type: Anything'23)
    sub rsp, 20h                                                 ; allocate shadow space for decref
    mov rdx, qword ptr [rsp + 040h]                              ; arg #2: type of potential string
    mov rcx, r15                                                 ; arg #1: value of potential string
    call intrinsic$decref                                        ; call decref
    add rsp, 20h                                                 ; free shadow space for decref
    ; Calling decref on _stringify return value (static type: String'22)
    sub rsp, 20h                                                 ; allocate shadow space for decref
    mov rdx, qword ptr [rsp + 050h]                              ; arg #2: type of potential string
    mov rcx, qword ptr [rsp + 060h]                              ; arg #1: value of potential string
    call intrinsic$decref                                        ; call decref
    add rsp, 20h                                                 ; free shadow space for decref
    mov rax, qword ptr [rsp + 018h]                              ; restoring slots to previous scope state
    mov rbx, qword ptr [rsp + 048h]                              ; restoring slots to previous scope state
    mov rcx, qword ptr [rsp + 028h]                              ; restoring slots to previous scope state
    mov rsi, qword ptr [rsp + 038h]                              ; restoring slots to previous scope state
    mov rdi, qword ptr [rsp + 008h]                              ; restoring slots to previous scope state
    jmp func$println$while$top                                   ; return to top of while
  func$println$while$bottom:                                     ; bottom of while
  ; Line 196: __print('\n');
  ; Call __print with 1 arguments
  mov r13, offset string                                         ; reading string for push
  push r13                                                       ; value of argument #1 (string)
  push 016h                                                      ; type of argument #1 (String'22)
  lea r14, qword ptr [rsp + 058h]                                ; load address of return value's value
  push r14                                                       ; internal argument 6: pointer to return value slot's value
  lea r14, qword ptr [rsp + 058h]                                ; load address of return value's type
  push r14                                                       ; internal argument 5: pointer to return value slot's type
  sub rsp, 020h                                                  ; allocate shadow space
  mov r9, 000h                                                   ; internal argument 4: "this" pointer
  mov r8, 000h                                                   ; internal argument 3: "this" pointer type
  mov rdx, 000h                                                  ; internal argument 2: closure pointer
  mov qword ptr [rsp + 078h], rcx                                ; move parameter count of println value out of rcx
  mov rcx, 001h                                                  ; internal argument 1: number of actual arguments
  call func$__print                                              ; jump to subroutine
  add rsp, 040h                                                  ; release shadow space and arguments (result in stack pointer)
  ; Implicit return from println
  mov r15, qword ptr [rbp + 030h]                                ; get pointer to return value of println into register to dereference it
  mov qword ptr [r15], 000h                                      ; println return value
  mov r10, qword ptr [rbp + 028h]                                ; get pointer to return value type of println into register to dereference it
  mov qword ptr [r10], 013h                                      ; type of println return value (Null'19)
  jmp func$println$epilog                                        ; return
  func$println$epilog: 
  mov rax, qword ptr [rbp + 030h]                                ; report address of return value
  ; Epilog
  add rsp, 058h                                                  ; free space for stack
  pop r14                                                        ; restore non-volatile registers
  pop r13                                                        ; restore non-volatile registers
  pop r12                                                        ; restore non-volatile registers
  pop rbp                                                        ; restore non-volatile registers
  pop rdi                                                        ; restore non-volatile registers
  pop rsi                                                        ; restore non-volatile registers
  pop rbx                                                        ; restore non-volatile registers
  pop r15                                                        ; restore non-volatile registers
  ret                                                            ; return from subroutine

; plural
func$plural:
  ; Prolog
  push r15                                                       ; save non-volatile registers
  push rbx                                                       ; save non-volatile registers
  push rsi                                                       ; save non-volatile registers
  push rdi                                                       ; save non-volatile registers
  push rbp                                                       ; save non-volatile registers
  push r12                                                       ; save non-volatile registers
  push r13                                                       ; save non-volatile registers
  push r14                                                       ; save non-volatile registers
  sub rsp, 020h                                                  ; allocate space for stack
  lea rbp, qword ptr [rsp + 060h]                                ; set up frame pointer
  ; Check parameter count
  cmp rcx, 003h                                                  ; compare parameter count of plural to 3 (integer)
  je func$plural$parameterCountCheck$continuation                ; check number of parameters is as expected
    ; Error handling block for parameter count
    ;  - print(parameterCountCheckFailureMessage)
    ; Call __print with 1 arguments
    mov r10, offset parameterCountCheckFailureMessage            ; reading parameterCountCheckFailureMessage for push
    push r10                                                     ; value of argument #1 (parameterCountCheckFailureMessage)
    push 016h                                                    ; type of argument #1 (String'22)
    lea rax, qword ptr [rsp + 020h]                              ; load address of return value's value
    push rax                                                     ; internal argument 6: pointer to return value slot's value
    lea rax, qword ptr [rsp + 020h]                              ; load address of return value's type
    push rax                                                     ; internal argument 5: pointer to return value slot's type
    sub rsp, 020h                                                ; allocate shadow space
    mov r9, 000h                                                 ; internal argument 4: "this" pointer
    mov r8, 000h                                                 ; internal argument 3: "this" pointer type
    mov rdx, 000h                                                ; internal argument 2: closure pointer
    mov qword ptr [rsp + 040h], rcx                              ; move parameter count of plural value out of rcx
    mov rcx, 001h                                                ; internal argument 1: number of actual arguments
    call func$__print                                            ; jump to subroutine
    add rsp, 040h                                                ; release shadow space and arguments (result in stack pointer)
    ;  - exit(1)
    ; Call exit with 1 arguments
    push 001h                                                    ; value of argument #1 (1 (integer))
    push 015h                                                    ; type of argument #1 (Integer'21)
    lea rbx, qword ptr [rsp + 020h]                              ; load address of return value's value
    push rbx                                                     ; internal argument 6: pointer to return value slot's value
    lea rbx, qword ptr [rsp + 020h]                              ; load address of return value's type
    push rbx                                                     ; internal argument 5: pointer to return value slot's type
    sub rsp, 020h                                                ; allocate shadow space
    mov r9, 000h                                                 ; internal argument 4: "this" pointer
    mov r8, 000h                                                 ; internal argument 3: "this" pointer type
    mov rdx, 000h                                                ; internal argument 2: closure pointer
    mov rcx, 001h                                                ; internal argument 1: number of actual arguments
    call func$exit                                               ; jump to subroutine
    add rsp, 040h                                                ; release shadow space and arguments (result in stack pointer)
    mov rcx, qword ptr [rsp + 000h]                              ; restoring slots to previous scope state
  func$plural$parameterCountCheck$continuation:                  ; end of parameter count check
  ; Check type of parameter 0, n (expecting Integer)
  mov rsi, qword ptr [rbp + 038h]                                ; move type of n to testByte
  mov rax, rsi                                                   ; move testByte to testByte
  mov rdi, 001h                                                  ; read operand of mul (type table width in bytes) 
  mul rdi                                                        ; adjust to the relative start of that type's entry in the type table
  add rax, 000h                                                  ; adjust to the byte containing the bit to check against (result in testByte)
  mov r12, offset typeTable                                      ; read second operand of + (type table pointer)
  add rax, r12                                                   ; finally offset all of that by the start of the type table itself (result in testByte)
  bt qword ptr [rax], 002h                                       ; check that n is Integer
  jc func$plural$n$TypeMatch                                     ; skip next block if the type matches
    ; Error handling block for n
    ;  - print(parameterTypeCheckFailureMessage)
    ; Call __print with 1 arguments
    mov r13, offset parameterTypeCheckFailureMessage             ; reading parameterTypeCheckFailureMessage for push
    push r13                                                     ; value of argument #1 (parameterTypeCheckFailureMessage)
    push 016h                                                    ; type of argument #1 (String'22)
    lea r14, qword ptr [rsp + 020h]                              ; load address of return value's value
    push r14                                                     ; internal argument 6: pointer to return value slot's value
    lea r14, qword ptr [rsp + 020h]                              ; load address of return value's type
    push r14                                                     ; internal argument 5: pointer to return value slot's type
    sub rsp, 020h                                                ; allocate shadow space
    mov r9, 000h                                                 ; internal argument 4: "this" pointer
    mov r8, 000h                                                 ; internal argument 3: "this" pointer type
    mov rdx, 000h                                                ; internal argument 2: closure pointer
    mov qword ptr [rsp + 040h], rcx                              ; move parameter count of plural value out of rcx
    mov rcx, 001h                                                ; internal argument 1: number of actual arguments
    call func$__print                                            ; jump to subroutine
    add rsp, 040h                                                ; release shadow space and arguments (result in stack pointer)
    ;  - exit(1)
    ; Call exit with 1 arguments
    push 001h                                                    ; value of argument #1 (1 (integer))
    push 015h                                                    ; type of argument #1 (Integer'21)
    lea r15, qword ptr [rsp + 020h]                              ; load address of return value's value
    push r15                                                     ; internal argument 6: pointer to return value slot's value
    lea r15, qword ptr [rsp + 020h]                              ; load address of return value's type
    push r15                                                     ; internal argument 5: pointer to return value slot's type
    sub rsp, 020h                                                ; allocate shadow space
    mov r9, 000h                                                 ; internal argument 4: "this" pointer
    mov r8, 000h                                                 ; internal argument 3: "this" pointer type
    mov rdx, 000h                                                ; internal argument 2: closure pointer
    mov rcx, 001h                                                ; internal argument 1: number of actual arguments
    call func$exit                                               ; jump to subroutine
    add rsp, 040h                                                ; release shadow space and arguments (result in stack pointer)
    mov rcx, qword ptr [rsp + 000h]                              ; restoring slots to previous scope state
  func$plural$n$TypeMatch:                                       ; after block
  ; Check type of parameter 1, singular (expecting String)
  mov r10, qword ptr [rbp + 048h]                                ; move type of singular to testByte
  mov rax, r10                                                   ; move testByte to testByte
  mov rbx, 001h                                                  ; read operand of mul (type table width in bytes) 
  mul rbx                                                        ; adjust to the relative start of that type's entry in the type table
  add rax, 000h                                                  ; adjust to the byte containing the bit to check against (result in testByte)
  mov rsi, offset typeTable                                      ; read second operand of + (type table pointer)
  add rax, rsi                                                   ; finally offset all of that by the start of the type table itself (result in testByte)
  bt qword ptr [rax], 003h                                       ; check that singular is String
  jc func$plural$singular$TypeMatch                              ; skip next block if the type matches
    ; Error handling block for singular
    ;  - print(parameterTypeCheckFailureMessage)
    ; Call __print with 1 arguments
    mov rdi, offset parameterTypeCheckFailureMessage             ; reading parameterTypeCheckFailureMessage for push
    push rdi                                                     ; value of argument #1 (parameterTypeCheckFailureMessage)
    push 016h                                                    ; type of argument #1 (String'22)
    lea r12, qword ptr [rsp + 020h]                              ; load address of return value's value
    push r12                                                     ; internal argument 6: pointer to return value slot's value
    lea r12, qword ptr [rsp + 020h]                              ; load address of return value's type
    push r12                                                     ; internal argument 5: pointer to return value slot's type
    sub rsp, 020h                                                ; allocate shadow space
    mov r9, 000h                                                 ; internal argument 4: "this" pointer
    mov r8, 000h                                                 ; internal argument 3: "this" pointer type
    mov rdx, 000h                                                ; internal argument 2: closure pointer
    mov qword ptr [rsp + 040h], rcx                              ; move parameter count of plural value out of rcx
    mov rcx, 001h                                                ; internal argument 1: number of actual arguments
    call func$__print                                            ; jump to subroutine
    add rsp, 040h                                                ; release shadow space and arguments (result in stack pointer)
    ;  - exit(1)
    ; Call exit with 1 arguments
    push 001h                                                    ; value of argument #1 (1 (integer))
    push 015h                                                    ; type of argument #1 (Integer'21)
    lea r13, qword ptr [rsp + 020h]                              ; load address of return value's value
    push r13                                                     ; internal argument 6: pointer to return value slot's value
    lea r13, qword ptr [rsp + 020h]                              ; load address of return value's type
    push r13                                                     ; internal argument 5: pointer to return value slot's type
    sub rsp, 020h                                                ; allocate shadow space
    mov r9, 000h                                                 ; internal argument 4: "this" pointer
    mov r8, 000h                                                 ; internal argument 3: "this" pointer type
    mov rdx, 000h                                                ; internal argument 2: closure pointer
    mov rcx, 001h                                                ; internal argument 1: number of actual arguments
    call func$exit                                               ; jump to subroutine
    add rsp, 040h                                                ; release shadow space and arguments (result in stack pointer)
    mov rcx, qword ptr [rsp + 000h]                              ; restoring slots to previous scope state
  func$plural$singular$TypeMatch:                                ; after block
  ; Check type of parameter 2, plural (expecting String)
  mov r14, qword ptr [rbp + 058h]                                ; move type of plural to testByte
  mov rax, r14                                                   ; move testByte to testByte
  mov r15, 001h                                                  ; read operand of mul (type table width in bytes) 
  mul r15                                                        ; adjust to the relative start of that type's entry in the type table
  add rax, 000h                                                  ; adjust to the byte containing the bit to check against (result in testByte)
  mov r10, offset typeTable                                      ; read second operand of + (type table pointer)
  add rax, r10                                                   ; finally offset all of that by the start of the type table itself (result in testByte)
  bt qword ptr [rax], 003h                                       ; check that plural is String
  jc func$plural$plural$TypeMatch                                ; skip next block if the type matches
    ; Error handling block for plural
    ;  - print(parameterTypeCheckFailureMessage)
    ; Call __print with 1 arguments
    mov rbx, offset parameterTypeCheckFailureMessage             ; reading parameterTypeCheckFailureMessage for push
    push rbx                                                     ; value of argument #1 (parameterTypeCheckFailureMessage)
    push 016h                                                    ; type of argument #1 (String'22)
    lea rsi, qword ptr [rsp + 020h]                              ; load address of return value's value
    push rsi                                                     ; internal argument 6: pointer to return value slot's value
    lea rsi, qword ptr [rsp + 020h]                              ; load address of return value's type
    push rsi                                                     ; internal argument 5: pointer to return value slot's type
    sub rsp, 020h                                                ; allocate shadow space
    mov r9, 000h                                                 ; internal argument 4: "this" pointer
    mov r8, 000h                                                 ; internal argument 3: "this" pointer type
    mov rdx, 000h                                                ; internal argument 2: closure pointer
    mov qword ptr [rsp + 040h], rcx                              ; move parameter count of plural value out of rcx
    mov rcx, 001h                                                ; internal argument 1: number of actual arguments
    call func$__print                                            ; jump to subroutine
    add rsp, 040h                                                ; release shadow space and arguments (result in stack pointer)
    ;  - exit(1)
    ; Call exit with 1 arguments
    push 001h                                                    ; value of argument #1 (1 (integer))
    push 015h                                                    ; type of argument #1 (Integer'21)
    lea rdi, qword ptr [rsp + 020h]                              ; load address of return value's value
    push rdi                                                     ; internal argument 6: pointer to return value slot's value
    lea rdi, qword ptr [rsp + 020h]                              ; load address of return value's type
    push rdi                                                     ; internal argument 5: pointer to return value slot's type
    sub rsp, 020h                                                ; allocate shadow space
    mov r9, 000h                                                 ; internal argument 4: "this" pointer
    mov r8, 000h                                                 ; internal argument 3: "this" pointer type
    mov rdx, 000h                                                ; internal argument 2: closure pointer
    mov rcx, 001h                                                ; internal argument 1: number of actual arguments
    call func$exit                                               ; jump to subroutine
    add rsp, 040h                                                ; release shadow space and arguments (result in stack pointer)
    mov rcx, qword ptr [rsp + 000h]                              ; restoring slots to previous scope state
  func$plural$plural$TypeMatch:                                  ; after block
  ; Line 2: if (n == 1) { ...
  xor r12, r12                                                   ; zero value result of == (testing n and 1) to put the boolean in
  cmp qword ptr [rbp + 040h], 001h                               ; values equal?
  sete r12b                                                      ; put result in value result of == (testing n and 1)
  mov r13, 014h                                                  ; value result of == (testing n and 1) is a Boolean'20
  xor r14, r14                                                   ; zero type result of == (testing n and 1) to put the boolean in
  cmp qword ptr [rbp + 038h], 015h                               ; types equal?
  sete r14b                                                      ; put result in type result of == (testing n and 1)
  mov rax, 014h                                                  ; type result of == (testing n and 1) is a Boolean'20
  mov r15, r12                                                   ; assign value of value result of == (testing n and 1) to value of == operator result
  and r15, r14                                                   ; && type temp and value temp
  mov r10, 014h                                                  ; == operator result is of type Boolean'20
  cmp r15, 000h                                                  ; compare == operator result to false
  je func$plural$if$continuation                                 ; n == 1
    ; Line 3: return singular;
    mov rbx, qword ptr [rbp + 050h]                              ; read second operand of mov (singular) for MoveToDerefInstruction
    mov rsi, qword ptr [rbp + 030h]                              ; get pointer to return value of plural into register to dereference it
    mov qword ptr [rsi], rbx                                     ; plural return value
    mov rdi, qword ptr [rbp + 048h]                              ; reading type of singular
    mov r9, qword ptr [rbp + 028h]                               ; get pointer to return value type of plural into register to dereference it
    mov qword ptr [r9], rdi                                      ; type of plural return value
    ; increment reference count for singular if necessary
    cmp qword ptr [rbp + 048h], 016h                             ; if not a string, skip incref
    jne func$plural$plural$if$AfterIncref
    mov r8, qword ptr [rbp + 050h]                               ; get singular into register to dereference it
    mov rdx, qword ptr [r8]                                      ; dereference string to get to ref count
    cmp rdx, 0                                                   ; compare string refcount temporary to 0
    js func$plural$plural$if$AfterIncref                         ; if ref count is negative (constant strings), skip incref
    add rdx, 001h                                                ; increment ref count (result in string refcount temporary)
    mov qword ptr [rsp + 010h], rcx                              ; move parameter count of plural value out of rcx
    mov rcx, qword ptr [rbp + 050h]                              ; get singular into register to dereference it
    mov qword ptr [rcx], rdx                                     ; put it back in the string
    func$plural$plural$if$AfterIncref:                           ; after incref
    jmp func$plural$epilog                                       ; return
  func$plural$if$continuation:                                   ; end of if
  ; Line 5: return plural;
  mov r12, qword ptr [rbp + 060h]                                ; read second operand of mov (plural) for MoveToDerefInstruction
  mov r13, qword ptr [rbp + 030h]                                ; get pointer to return value of plural into register to dereference it
  mov qword ptr [r13], r12                                       ; plural return value
  mov r14, qword ptr [rbp + 058h]                                ; reading type of plural
  mov rax, qword ptr [rbp + 028h]                                ; get pointer to return value type of plural into register to dereference it
  mov qword ptr [rax], r14                                       ; type of plural return value
  ; increment reference count for plural if necessary
  cmp qword ptr [rbp + 058h], 016h                               ; if not a string, skip incref
  jne func$plural$AfterIncref
  mov r15, qword ptr [rbp + 060h]                                ; get plural into register to dereference it
  mov r10, qword ptr [r15]                                       ; dereference string to get to ref count
  cmp r10, 0                                                     ; compare string refcount temporary to 0
  js func$plural$AfterIncref                                     ; if ref count is negative (constant strings), skip incref
  add r10, 001h                                                  ; increment ref count (result in string refcount temporary)
  mov rbx, qword ptr [rbp + 060h]                                ; get plural into register to dereference it
  mov qword ptr [rbx], r10                                       ; put it back in the string
  func$plural$AfterIncref:                                       ; after incref
  jmp func$plural$epilog                                         ; return
  func$plural$epilog: 
  mov rax, qword ptr [rbp + 030h]                                ; report address of return value
  ; Epilog
  add rsp, 020h                                                  ; free space for stack
  pop r14                                                        ; restore non-volatile registers
  pop r13                                                        ; restore non-volatile registers
  pop r12                                                        ; restore non-volatile registers
  pop rbp                                                        ; restore non-volatile registers
  pop rdi                                                        ; restore non-volatile registers
  pop rsi                                                        ; restore non-volatile registers
  pop rbx                                                        ; restore non-volatile registers
  pop r15                                                        ; restore non-volatile registers
  ret                                                            ; return from subroutine

; bottles
func$bottles:
  ; Prolog
  push r15                                                       ; save non-volatile registers
  push rbx                                                       ; save non-volatile registers
  push rsi                                                       ; save non-volatile registers
  push rdi                                                       ; save non-volatile registers
  push rbp                                                       ; save non-volatile registers
  push r12                                                       ; save non-volatile registers
  push r13                                                       ; save non-volatile registers
  push r14                                                       ; save non-volatile registers
  sub rsp, 040h                                                  ; allocate space for stack
  lea rbp, qword ptr [rsp + 080h]                                ; set up frame pointer
  ; Check parameter count
  cmp rcx, 001h                                                  ; compare parameter count of bottles to 1 (integer)
  je func$bottles$parameterCountCheck$continuation               ; check number of parameters is as expected
    ; Error handling block for parameter count
    ;  - print(parameterCountCheckFailureMessage)
    ; Call __print with 1 arguments
    mov r10, offset parameterCountCheckFailureMessage            ; reading parameterCountCheckFailureMessage for push
    push r10                                                     ; value of argument #1 (parameterCountCheckFailureMessage)
    push 016h                                                    ; type of argument #1 (String'22)
    lea rax, qword ptr [rsp + 040h]                              ; load address of return value's value
    push rax                                                     ; internal argument 6: pointer to return value slot's value
    lea rax, qword ptr [rsp + 040h]                              ; load address of return value's type
    push rax                                                     ; internal argument 5: pointer to return value slot's type
    sub rsp, 020h                                                ; allocate shadow space
    mov r9, 000h                                                 ; internal argument 4: "this" pointer
    mov r8, 000h                                                 ; internal argument 3: "this" pointer type
    mov rdx, 000h                                                ; internal argument 2: closure pointer
    mov qword ptr [rsp + 060h], rcx                              ; move parameter count of bottles value out of rcx
    mov rcx, 001h                                                ; internal argument 1: number of actual arguments
    call func$__print                                            ; jump to subroutine
    add rsp, 040h                                                ; release shadow space and arguments (result in stack pointer)
    ;  - exit(1)
    ; Call exit with 1 arguments
    push 001h                                                    ; value of argument #1 (1 (integer))
    push 015h                                                    ; type of argument #1 (Integer'21)
    lea rbx, qword ptr [rsp + 040h]                              ; load address of return value's value
    push rbx                                                     ; internal argument 6: pointer to return value slot's value
    lea rbx, qword ptr [rsp + 040h]                              ; load address of return value's type
    push rbx                                                     ; internal argument 5: pointer to return value slot's type
    sub rsp, 020h                                                ; allocate shadow space
    mov r9, 000h                                                 ; internal argument 4: "this" pointer
    mov r8, 000h                                                 ; internal argument 3: "this" pointer type
    mov rdx, 000h                                                ; internal argument 2: closure pointer
    mov rcx, 001h                                                ; internal argument 1: number of actual arguments
    call func$exit                                               ; jump to subroutine
    add rsp, 040h                                                ; release shadow space and arguments (result in stack pointer)
    mov rcx, qword ptr [rsp + 020h]                              ; restoring slots to previous scope state
  func$bottles$parameterCountCheck$continuation:                 ; end of parameter count check
  ; Check type of parameter 0, count (expecting Integer)
  mov rsi, qword ptr [rbp + 038h]                                ; move type of count to testByte
  mov rax, rsi                                                   ; move testByte to testByte
  mov rdi, 001h                                                  ; read operand of mul (type table width in bytes) 
  mul rdi                                                        ; adjust to the relative start of that type's entry in the type table
  add rax, 000h                                                  ; adjust to the byte containing the bit to check against (result in testByte)
  mov r12, offset typeTable                                      ; read second operand of + (type table pointer)
  add rax, r12                                                   ; finally offset all of that by the start of the type table itself (result in testByte)
  bt qword ptr [rax], 002h                                       ; check that count is Integer
  jc func$bottles$count$TypeMatch                                ; skip next block if the type matches
    ; Error handling block for count
    ;  - print(parameterTypeCheckFailureMessage)
    ; Call __print with 1 arguments
    mov r13, offset parameterTypeCheckFailureMessage             ; reading parameterTypeCheckFailureMessage for push
    push r13                                                     ; value of argument #1 (parameterTypeCheckFailureMessage)
    push 016h                                                    ; type of argument #1 (String'22)
    lea r14, qword ptr [rsp + 040h]                              ; load address of return value's value
    push r14                                                     ; internal argument 6: pointer to return value slot's value
    lea r14, qword ptr [rsp + 040h]                              ; load address of return value's type
    push r14                                                     ; internal argument 5: pointer to return value slot's type
    sub rsp, 020h                                                ; allocate shadow space
    mov r9, 000h                                                 ; internal argument 4: "this" pointer
    mov r8, 000h                                                 ; internal argument 3: "this" pointer type
    mov rdx, 000h                                                ; internal argument 2: closure pointer
    mov qword ptr [rsp + 060h], rcx                              ; move parameter count of bottles value out of rcx
    mov rcx, 001h                                                ; internal argument 1: number of actual arguments
    call func$__print                                            ; jump to subroutine
    add rsp, 040h                                                ; release shadow space and arguments (result in stack pointer)
    ;  - exit(1)
    ; Call exit with 1 arguments
    push 001h                                                    ; value of argument #1 (1 (integer))
    push 015h                                                    ; type of argument #1 (Integer'21)
    lea r15, qword ptr [rsp + 040h]                              ; load address of return value's value
    push r15                                                     ; internal argument 6: pointer to return value slot's value
    lea r15, qword ptr [rsp + 040h]                              ; load address of return value's type
    push r15                                                     ; internal argument 5: pointer to return value slot's type
    sub rsp, 020h                                                ; allocate shadow space
    mov r9, 000h                                                 ; internal argument 4: "this" pointer
    mov r8, 000h                                                 ; internal argument 3: "this" pointer type
    mov rdx, 000h                                                ; internal argument 2: closure pointer
    mov rcx, 001h                                                ; internal argument 1: number of actual arguments
    call func$exit                                               ; jump to subroutine
    add rsp, 040h                                                ; release shadow space and arguments (result in stack pointer)
    mov rcx, qword ptr [rsp + 020h]                              ; restoring slots to previous scope state
  func$bottles$count$TypeMatch:                                  ; after block
  ; Line 9: if (count == 0) { ...
  xor r10, r10                                                   ; zero value result of == (testing count and 0) to put the boolean in
  cmp qword ptr [rbp + 040h], 000h                               ; values equal?
  sete r10b                                                      ; put result in value result of == (testing count and 0)
  mov rbx, 014h                                                  ; value result of == (testing count and 0) is a Boolean'20
  xor rsi, rsi                                                   ; zero type result of == (testing count and 0) to put the boolean in
  cmp qword ptr [rbp + 038h], 015h                               ; types equal?
  sete sil                                                       ; put result in type result of == (testing count and 0)
  mov rax, 014h                                                  ; type result of == (testing count and 0) is a Boolean'20
  mov rdi, r10                                                   ; assign value of value result of == (testing count and 0) to value of == operator result
  and rdi, rsi                                                   ; && type temp and value temp
  mov r12, 014h                                                  ; == operator result is of type Boolean'20
  cmp rdi, 000h                                                  ; compare == operator result to false
  je func$bottles$if$continuation                                ; count == 0
    ; Line 10: return 'No bottles of beer';
    mov r13, offset string$21                                    ; read second operand of mov (string) for MoveToDerefInstruction
    mov r14, qword ptr [rbp + 030h]                              ; get pointer to return value of bottles into register to dereference it
    mov qword ptr [r14], r13                                     ; bottles return value
    mov r15, qword ptr [rbp + 028h]                              ; get pointer to return value type of bottles into register to dereference it
    mov qword ptr [r15], 016h                                    ; type of bottles return value (String'22)
    jmp func$bottles$epilog                                      ; return
  func$bottles$if$continuation:                                  ; end of if
  ; Line 12: return concat(_stringify(count), ' ', plural(count, 'bottle', 'b...
  ; Call _stringify with 1 arguments
  push qword ptr [rbp + 040h]                                    ; value of argument #1 (count)
  push qword ptr [rbp + 038h]                                    ; type of argument #1
  lea r9, qword ptr [rsp + 040h]                                 ; load address of return value's value
  push r9                                                        ; internal argument 6: pointer to return value slot's value
  lea r9, qword ptr [rsp + 040h]                                 ; load address of return value's type
  push r9                                                        ; internal argument 5: pointer to return value slot's type
  sub rsp, 020h                                                  ; allocate shadow space
  mov r9, 000h                                                   ; internal argument 4: "this" pointer
  mov r8, 000h                                                   ; internal argument 3: "this" pointer type
  mov rdx, 000h                                                  ; internal argument 2: closure pointer
  mov qword ptr [rsp + 060h], rcx                                ; move parameter count of bottles value out of rcx
  mov rcx, 001h                                                  ; internal argument 1: number of actual arguments
  call func$_stringify                                           ; jump to subroutine
  add rsp, 040h                                                  ; release shadow space and arguments (result in stack pointer)
  ; Call plural with 3 arguments
  mov r10, offset string$23                                      ; reading string for push
  push r10                                                       ; value of argument #3 (string)
  push 016h                                                      ; type of argument #3 (String'22)
  mov rbx, offset string$22                                      ; reading string for push
  push rbx                                                       ; value of argument #2 (string)
  push 016h                                                      ; type of argument #2 (String'22)
  push qword ptr [rbp + 040h]                                    ; value of argument #1 (count)
  push qword ptr [rbp + 038h]                                    ; type of argument #1
  lea rsi, qword ptr [rsp + 048h]                                ; load address of return value's value
  push rsi                                                       ; internal argument 6: pointer to return value slot's value
  lea rsi, qword ptr [rsp + 048h]                                ; load address of return value's type
  push rsi                                                       ; internal argument 5: pointer to return value slot's type
  sub rsp, 020h                                                  ; allocate shadow space
  mov r9, 000h                                                   ; internal argument 4: "this" pointer
  mov r8, 000h                                                   ; internal argument 3: "this" pointer type
  mov rdx, 000h                                                  ; internal argument 2: closure pointer
  mov rcx, 003h                                                  ; internal argument 1: number of actual arguments
  call func$plural                                               ; jump to subroutine
  add rsp, 060h                                                  ; release shadow space and arguments (result in stack pointer)
  ; Call concat with 4 arguments
  mov rax, offset string$24                                      ; reading string for push
  push rax                                                       ; value of argument #4 (string)
  push 016h                                                      ; type of argument #4 (String'22)
  push qword ptr [rsp + 028h]                                    ; value of argument #3 (plural return value)
  push qword ptr [rsp + 028h]                                    ; type of argument #3
  mov rdi, offset string$20                                      ; reading string for push
  push rdi                                                       ; value of argument #2 (string)
  push 016h                                                      ; type of argument #2 (String'22)
  push qword ptr [rsp + 060h]                                    ; value of argument #1 (_stringify return value)
  push qword ptr [rsp + 060h]                                    ; type of argument #1
  lea r12, qword ptr [rsp + 048h]                                ; load address of return value's value
  push r12                                                       ; internal argument 6: pointer to return value slot's value
  lea r12, qword ptr [rsp + 048h]                                ; load address of return value's type
  push r12                                                       ; internal argument 5: pointer to return value slot's type
  sub rsp, 020h                                                  ; allocate shadow space
  mov r9, 000h                                                   ; internal argument 4: "this" pointer
  mov r8, 000h                                                   ; internal argument 3: "this" pointer type
  mov rdx, 000h                                                  ; internal argument 2: closure pointer
  mov rcx, 004h                                                  ; internal argument 1: number of actual arguments
  call func$concat                                               ; jump to subroutine
  add rsp, 070h                                                  ; release shadow space and arguments (result in stack pointer)
  mov r13, qword ptr [rsp + 008h]                                ; read second operand of mov (concat return value) for MoveToDerefInstruction
  mov r14, qword ptr [rbp + 030h]                                ; get pointer to return value of bottles into register to dereference it
  mov qword ptr [r14], r13                                       ; bottles return value
  mov r15, qword ptr [rsp + 000h]                                ; reading type of concat return value
  mov r10, qword ptr [rbp + 028h]                                ; get pointer to return value type of bottles into register to dereference it
  mov qword ptr [r10], r15                                       ; type of bottles return value
  ; increment reference count for concat return value if necessary
  cmp r15, 016h                                                  ; if not a string, skip incref
  jne func$bottles$AfterIncref
  mov rbx, qword ptr [r13]                                       ; dereference string to get to ref count
  cmp rbx, 0                                                     ; compare string refcount temporary to 0
  js func$bottles$AfterIncref                                    ; if ref count is negative (constant strings), skip incref
  add rbx, 001h                                                  ; increment ref count (result in string refcount temporary)
  mov qword ptr [r13], rbx                                       ; put it back in the string
  func$bottles$AfterIncref:                                      ; after incref
  ; Calling decref on plural return value (static type: String'22)
  sub rsp, 20h                                                   ; allocate shadow space for decref
  mov rdx, qword ptr [rsp + 030h]                                ; arg #2: type of potential string
  mov rcx, qword ptr [rsp + 038h]                                ; arg #1: value of potential string
  call intrinsic$decref                                          ; call decref
  add rsp, 20h                                                   ; free shadow space for decref
  ; Calling decref on concat return value (static type: String'22)
  sub rsp, 20h                                                   ; allocate shadow space for decref
  mov rdx, r15                                                   ; arg #2: type of potential string
  mov rcx, r13                                                   ; arg #1: value of potential string
  call intrinsic$decref                                          ; call decref
  add rsp, 20h                                                   ; free shadow space for decref
  ; Calling decref on _stringify return value (static type: String'22)
  sub rsp, 20h                                                   ; allocate shadow space for decref
  mov rdx, qword ptr [rsp + 048h]                                ; arg #2: type of potential string
  mov rcx, qword ptr [rsp + 050h]                                ; arg #1: value of potential string
  call intrinsic$decref                                          ; call decref
  add rsp, 20h                                                   ; free shadow space for decref
  jmp func$bottles$epilog                                        ; return
  func$bottles$epilog: 
  mov rax, qword ptr [rbp + 030h]                                ; report address of return value
  ; Epilog
  add rsp, 040h                                                  ; free space for stack
  pop r14                                                        ; restore non-volatile registers
  pop r13                                                        ; restore non-volatile registers
  pop r12                                                        ; restore non-volatile registers
  pop rbp                                                        ; restore non-volatile registers
  pop rdi                                                        ; restore non-volatile registers
  pop rsi                                                        ; restore non-volatile registers
  pop rbx                                                        ; restore non-volatile registers
  pop r15                                                        ; restore non-volatile registers
  ret                                                            ; return from subroutine

; wall
func$wall:
  ; Prolog
  push r15                                                       ; save non-volatile registers
  push rbx                                                       ; save non-volatile registers
  push rsi                                                       ; save non-volatile registers
  push rdi                                                       ; save non-volatile registers
  push rbp                                                       ; save non-volatile registers
  push r12                                                       ; save non-volatile registers
  push r13                                                       ; save non-volatile registers
  push r14                                                       ; save non-volatile registers
  sub rsp, 030h                                                  ; allocate space for stack
  lea rbp, qword ptr [rsp + 070h]                                ; set up frame pointer
  ; Check parameter count
  cmp rcx, 001h                                                  ; compare parameter count of wall to 1 (integer)
  je func$wall$parameterCountCheck$continuation                  ; check number of parameters is as expected
    ; Error handling block for parameter count
    ;  - print(parameterCountCheckFailureMessage)
    ; Call __print with 1 arguments
    mov r10, offset parameterCountCheckFailureMessage            ; reading parameterCountCheckFailureMessage for push
    push r10                                                     ; value of argument #1 (parameterCountCheckFailureMessage)
    push 016h                                                    ; type of argument #1 (String'22)
    lea rax, qword ptr [rsp + 030h]                              ; load address of return value's value
    push rax                                                     ; internal argument 6: pointer to return value slot's value
    lea rax, qword ptr [rsp + 030h]                              ; load address of return value's type
    push rax                                                     ; internal argument 5: pointer to return value slot's type
    sub rsp, 020h                                                ; allocate shadow space
    mov r9, 000h                                                 ; internal argument 4: "this" pointer
    mov r8, 000h                                                 ; internal argument 3: "this" pointer type
    mov rdx, 000h                                                ; internal argument 2: closure pointer
    mov qword ptr [rsp + 050h], rcx                              ; move parameter count of wall value out of rcx
    mov rcx, 001h                                                ; internal argument 1: number of actual arguments
    call func$__print                                            ; jump to subroutine
    add rsp, 040h                                                ; release shadow space and arguments (result in stack pointer)
    ;  - exit(1)
    ; Call exit with 1 arguments
    push 001h                                                    ; value of argument #1 (1 (integer))
    push 015h                                                    ; type of argument #1 (Integer'21)
    lea rbx, qword ptr [rsp + 030h]                              ; load address of return value's value
    push rbx                                                     ; internal argument 6: pointer to return value slot's value
    lea rbx, qword ptr [rsp + 030h]                              ; load address of return value's type
    push rbx                                                     ; internal argument 5: pointer to return value slot's type
    sub rsp, 020h                                                ; allocate shadow space
    mov r9, 000h                                                 ; internal argument 4: "this" pointer
    mov r8, 000h                                                 ; internal argument 3: "this" pointer type
    mov rdx, 000h                                                ; internal argument 2: closure pointer
    mov rcx, 001h                                                ; internal argument 1: number of actual arguments
    call func$exit                                               ; jump to subroutine
    add rsp, 040h                                                ; release shadow space and arguments (result in stack pointer)
    mov rcx, qword ptr [rsp + 010h]                              ; restoring slots to previous scope state
  func$wall$parameterCountCheck$continuation:                    ; end of parameter count check
  ; Check type of parameter 0, count (expecting Integer)
  mov rsi, qword ptr [rbp + 038h]                                ; move type of count to testByte
  mov rax, rsi                                                   ; move testByte to testByte
  mov rdi, 001h                                                  ; read operand of mul (type table width in bytes) 
  mul rdi                                                        ; adjust to the relative start of that type's entry in the type table
  add rax, 000h                                                  ; adjust to the byte containing the bit to check against (result in testByte)
  mov r12, offset typeTable                                      ; read second operand of + (type table pointer)
  add rax, r12                                                   ; finally offset all of that by the start of the type table itself (result in testByte)
  bt qword ptr [rax], 002h                                       ; check that count is Integer
  jc func$wall$count$TypeMatch                                   ; skip next block if the type matches
    ; Error handling block for count
    ;  - print(parameterTypeCheckFailureMessage)
    ; Call __print with 1 arguments
    mov r13, offset parameterTypeCheckFailureMessage             ; reading parameterTypeCheckFailureMessage for push
    push r13                                                     ; value of argument #1 (parameterTypeCheckFailureMessage)
    push 016h                                                    ; type of argument #1 (String'22)
    lea r14, qword ptr [rsp + 030h]                              ; load address of return value's value
    push r14                                                     ; internal argument 6: pointer to return value slot's value
    lea r14, qword ptr [rsp + 030h]                              ; load address of return value's type
    push r14                                                     ; internal argument 5: pointer to return value slot's type
    sub rsp, 020h                                                ; allocate shadow space
    mov r9, 000h                                                 ; internal argument 4: "this" pointer
    mov r8, 000h                                                 ; internal argument 3: "this" pointer type
    mov rdx, 000h                                                ; internal argument 2: closure pointer
    mov qword ptr [rsp + 050h], rcx                              ; move parameter count of wall value out of rcx
    mov rcx, 001h                                                ; internal argument 1: number of actual arguments
    call func$__print                                            ; jump to subroutine
    add rsp, 040h                                                ; release shadow space and arguments (result in stack pointer)
    ;  - exit(1)
    ; Call exit with 1 arguments
    push 001h                                                    ; value of argument #1 (1 (integer))
    push 015h                                                    ; type of argument #1 (Integer'21)
    lea r15, qword ptr [rsp + 030h]                              ; load address of return value's value
    push r15                                                     ; internal argument 6: pointer to return value slot's value
    lea r15, qword ptr [rsp + 030h]                              ; load address of return value's type
    push r15                                                     ; internal argument 5: pointer to return value slot's type
    sub rsp, 020h                                                ; allocate shadow space
    mov r9, 000h                                                 ; internal argument 4: "this" pointer
    mov r8, 000h                                                 ; internal argument 3: "this" pointer type
    mov rdx, 000h                                                ; internal argument 2: closure pointer
    mov rcx, 001h                                                ; internal argument 1: number of actual arguments
    call func$exit                                               ; jump to subroutine
    add rsp, 040h                                                ; release shadow space and arguments (result in stack pointer)
    mov rcx, qword ptr [rsp + 010h]                              ; restoring slots to previous scope state
  func$wall$count$TypeMatch:                                     ; after block
  ; Line 16: return concat(bottles(count), ' on the wall');
  ; Call bottles with 1 arguments
  push qword ptr [rbp + 040h]                                    ; value of argument #1 (count)
  push qword ptr [rbp + 038h]                                    ; type of argument #1
  lea r10, qword ptr [rsp + 030h]                                ; load address of return value's value
  push r10                                                       ; internal argument 6: pointer to return value slot's value
  lea r10, qword ptr [rsp + 030h]                                ; load address of return value's type
  push r10                                                       ; internal argument 5: pointer to return value slot's type
  sub rsp, 020h                                                  ; allocate shadow space
  mov r9, 000h                                                   ; internal argument 4: "this" pointer
  mov r8, 000h                                                   ; internal argument 3: "this" pointer type
  mov rdx, 000h                                                  ; internal argument 2: closure pointer
  mov qword ptr [rsp + 050h], rcx                                ; move parameter count of wall value out of rcx
  mov rcx, 001h                                                  ; internal argument 1: number of actual arguments
  call func$bottles                                              ; jump to subroutine
  add rsp, 040h                                                  ; release shadow space and arguments (result in stack pointer)
  ; Call concat with 2 arguments
  mov rbx, offset string$25                                      ; reading string for push
  push rbx                                                       ; value of argument #2 (string)
  push 016h                                                      ; type of argument #2 (String'22)
  push qword ptr [rsp + 030h]                                    ; value of argument #1 (bottles return value)
  push qword ptr [rsp + 030h]                                    ; type of argument #1
  lea rsi, qword ptr [rsp + 028h]                                ; load address of return value's value
  push rsi                                                       ; internal argument 6: pointer to return value slot's value
  lea rsi, qword ptr [rsp + 028h]                                ; load address of return value's type
  push rsi                                                       ; internal argument 5: pointer to return value slot's type
  sub rsp, 020h                                                  ; allocate shadow space
  mov r9, 000h                                                   ; internal argument 4: "this" pointer
  mov r8, 000h                                                   ; internal argument 3: "this" pointer type
  mov rdx, 000h                                                  ; internal argument 2: closure pointer
  mov rcx, 002h                                                  ; internal argument 1: number of actual arguments
  call func$concat                                               ; jump to subroutine
  add rsp, 050h                                                  ; release shadow space and arguments (result in stack pointer)
  mov rax, qword ptr [rsp + 008h]                                ; read second operand of mov (concat return value) for MoveToDerefInstruction
  mov rdi, qword ptr [rbp + 030h]                                ; get pointer to return value of wall into register to dereference it
  mov qword ptr [rdi], rax                                       ; wall return value
  mov r12, qword ptr [rsp + 000h]                                ; reading type of concat return value
  mov r13, qword ptr [rbp + 028h]                                ; get pointer to return value type of wall into register to dereference it
  mov qword ptr [r13], r12                                       ; type of wall return value
  ; increment reference count for concat return value if necessary
  cmp r12, 016h                                                  ; if not a string, skip incref
  jne func$wall$AfterIncref
  mov r14, qword ptr [rax]                                       ; dereference string to get to ref count
  cmp r14, 0                                                     ; compare string refcount temporary to 0
  js func$wall$AfterIncref                                       ; if ref count is negative (constant strings), skip incref
  add r14, 001h                                                  ; increment ref count (result in string refcount temporary)
  mov qword ptr [rax], r14                                       ; put it back in the string
  func$wall$AfterIncref:                                         ; after incref
  ; Calling decref on bottles return value (static type: String'22)
  sub rsp, 20h                                                   ; allocate shadow space for decref
  mov rdx, qword ptr [rsp + 038h]                                ; arg #2: type of potential string
  mov rcx, qword ptr [rsp + 040h]                                ; arg #1: value of potential string
  mov qword ptr [rsp + 028h], rax                                ; move concat return value value out of rax
  call intrinsic$decref                                          ; call decref
  add rsp, 20h                                                   ; free shadow space for decref
  ; Calling decref on concat return value (static type: String'22)
  sub rsp, 20h                                                   ; allocate shadow space for decref
  mov rdx, r12                                                   ; arg #2: type of potential string
  mov rcx, qword ptr [rsp + 028h]                                ; arg #1: value of potential string
  call intrinsic$decref                                          ; call decref
  add rsp, 20h                                                   ; free shadow space for decref
  jmp func$wall$epilog                                           ; return
  func$wall$epilog: 
  mov rax, qword ptr [rbp + 030h]                                ; report address of return value
  ; Epilog
  add rsp, 030h                                                  ; free space for stack
  pop r14                                                        ; restore non-volatile registers
  pop r13                                                        ; restore non-volatile registers
  pop r12                                                        ; restore non-volatile registers
  pop rbp                                                        ; restore non-volatile registers
  pop rdi                                                        ; restore non-volatile registers
  pop rsi                                                        ; restore non-volatile registers
  pop rbx                                                        ; restore non-volatile registers
  pop r15                                                        ; restore non-volatile registers
  ret                                                            ; return from subroutine

; stanza
func$stanza:
  ; Prolog
  push r15                                                       ; save non-volatile registers
  push rbx                                                       ; save non-volatile registers
  push rsi                                                       ; save non-volatile registers
  push rdi                                                       ; save non-volatile registers
  push rbp                                                       ; save non-volatile registers
  push r12                                                       ; save non-volatile registers
  push r13                                                       ; save non-volatile registers
  push r14                                                       ; save non-volatile registers
  sub rsp, 050h                                                  ; allocate space for stack
  lea rbp, qword ptr [rsp + 090h]                                ; set up frame pointer
  ; Check parameter count
  cmp rcx, 001h                                                  ; compare parameter count of stanza to 1 (integer)
  je func$stanza$parameterCountCheck$continuation                ; check number of parameters is as expected
    ; Error handling block for parameter count
    ;  - print(parameterCountCheckFailureMessage)
    ; Call __print with 1 arguments
    mov r10, offset parameterCountCheckFailureMessage            ; reading parameterCountCheckFailureMessage for push
    push r10                                                     ; value of argument #1 (parameterCountCheckFailureMessage)
    push 016h                                                    ; type of argument #1 (String'22)
    lea rax, qword ptr [rsp + 050h]                              ; load address of return value's value
    push rax                                                     ; internal argument 6: pointer to return value slot's value
    lea rax, qword ptr [rsp + 050h]                              ; load address of return value's type
    push rax                                                     ; internal argument 5: pointer to return value slot's type
    sub rsp, 020h                                                ; allocate shadow space
    mov r9, 000h                                                 ; internal argument 4: "this" pointer
    mov r8, 000h                                                 ; internal argument 3: "this" pointer type
    mov rdx, 000h                                                ; internal argument 2: closure pointer
    mov qword ptr [rsp + 070h], rcx                              ; move parameter count of stanza value out of rcx
    mov rcx, 001h                                                ; internal argument 1: number of actual arguments
    call func$__print                                            ; jump to subroutine
    add rsp, 040h                                                ; release shadow space and arguments (result in stack pointer)
    ;  - exit(1)
    ; Call exit with 1 arguments
    push 001h                                                    ; value of argument #1 (1 (integer))
    push 015h                                                    ; type of argument #1 (Integer'21)
    lea rbx, qword ptr [rsp + 050h]                              ; load address of return value's value
    push rbx                                                     ; internal argument 6: pointer to return value slot's value
    lea rbx, qword ptr [rsp + 050h]                              ; load address of return value's type
    push rbx                                                     ; internal argument 5: pointer to return value slot's type
    sub rsp, 020h                                                ; allocate shadow space
    mov r9, 000h                                                 ; internal argument 4: "this" pointer
    mov r8, 000h                                                 ; internal argument 3: "this" pointer type
    mov rdx, 000h                                                ; internal argument 2: closure pointer
    mov rcx, 001h                                                ; internal argument 1: number of actual arguments
    call func$exit                                               ; jump to subroutine
    add rsp, 040h                                                ; release shadow space and arguments (result in stack pointer)
    mov rcx, qword ptr [rsp + 030h]                              ; restoring slots to previous scope state
  func$stanza$parameterCountCheck$continuation:                  ; end of parameter count check
  ; Check type of parameter 0, count (expecting Integer)
  mov rsi, qword ptr [rbp + 038h]                                ; move type of count to testByte
  mov rax, rsi                                                   ; move testByte to testByte
  mov rdi, 001h                                                  ; read operand of mul (type table width in bytes) 
  mul rdi                                                        ; adjust to the relative start of that type's entry in the type table
  add rax, 000h                                                  ; adjust to the byte containing the bit to check against (result in testByte)
  mov r12, offset typeTable                                      ; read second operand of + (type table pointer)
  add rax, r12                                                   ; finally offset all of that by the start of the type table itself (result in testByte)
  bt qword ptr [rax], 002h                                       ; check that count is Integer
  jc func$stanza$count$TypeMatch                                 ; skip next block if the type matches
    ; Error handling block for count
    ;  - print(parameterTypeCheckFailureMessage)
    ; Call __print with 1 arguments
    mov r13, offset parameterTypeCheckFailureMessage             ; reading parameterTypeCheckFailureMessage for push
    push r13                                                     ; value of argument #1 (parameterTypeCheckFailureMessage)
    push 016h                                                    ; type of argument #1 (String'22)
    lea r14, qword ptr [rsp + 050h]                              ; load address of return value's value
    push r14                                                     ; internal argument 6: pointer to return value slot's value
    lea r14, qword ptr [rsp + 050h]                              ; load address of return value's type
    push r14                                                     ; internal argument 5: pointer to return value slot's type
    sub rsp, 020h                                                ; allocate shadow space
    mov r9, 000h                                                 ; internal argument 4: "this" pointer
    mov r8, 000h                                                 ; internal argument 3: "this" pointer type
    mov rdx, 000h                                                ; internal argument 2: closure pointer
    mov qword ptr [rsp + 070h], rcx                              ; move parameter count of stanza value out of rcx
    mov rcx, 001h                                                ; internal argument 1: number of actual arguments
    call func$__print                                            ; jump to subroutine
    add rsp, 040h                                                ; release shadow space and arguments (result in stack pointer)
    ;  - exit(1)
    ; Call exit with 1 arguments
    push 001h                                                    ; value of argument #1 (1 (integer))
    push 015h                                                    ; type of argument #1 (Integer'21)
    lea r15, qword ptr [rsp + 050h]                              ; load address of return value's value
    push r15                                                     ; internal argument 6: pointer to return value slot's value
    lea r15, qword ptr [rsp + 050h]                              ; load address of return value's type
    push r15                                                     ; internal argument 5: pointer to return value slot's type
    sub rsp, 020h                                                ; allocate shadow space
    mov r9, 000h                                                 ; internal argument 4: "this" pointer
    mov r8, 000h                                                 ; internal argument 3: "this" pointer type
    mov rdx, 000h                                                ; internal argument 2: closure pointer
    mov rcx, 001h                                                ; internal argument 1: number of actual arguments
    call func$exit                                               ; jump to subroutine
    add rsp, 040h                                                ; release shadow space and arguments (result in stack pointer)
    mov rcx, qword ptr [rsp + 030h]                              ; restoring slots to previous scope state
  func$stanza$count$TypeMatch:                                   ; after block
  ; Line 20: println(wall(count));
  ; Call wall with 1 arguments
  push qword ptr [rbp + 040h]                                    ; value of argument #1 (count)
  push qword ptr [rbp + 038h]                                    ; type of argument #1
  lea r10, qword ptr [rsp + 050h]                                ; load address of return value's value
  push r10                                                       ; internal argument 6: pointer to return value slot's value
  lea r10, qword ptr [rsp + 050h]                                ; load address of return value's type
  push r10                                                       ; internal argument 5: pointer to return value slot's type
  sub rsp, 020h                                                  ; allocate shadow space
  mov r9, 000h                                                   ; internal argument 4: "this" pointer
  mov r8, 000h                                                   ; internal argument 3: "this" pointer type
  mov rdx, 000h                                                  ; internal argument 2: closure pointer
  mov qword ptr [rsp + 070h], rcx                                ; move parameter count of stanza value out of rcx
  mov rcx, 001h                                                  ; internal argument 1: number of actual arguments
  call func$wall                                                 ; jump to subroutine
  add rsp, 040h                                                  ; release shadow space and arguments (result in stack pointer)
  ; Call println with 1 arguments
  push qword ptr [rsp + 040h]                                    ; value of argument #1 (wall return value)
  push qword ptr [rsp + 040h]                                    ; type of argument #1
  lea rbx, qword ptr [rsp + 038h]                                ; load address of return value's value
  push rbx                                                       ; internal argument 6: pointer to return value slot's value
  lea rbx, qword ptr [rsp + 038h]                                ; load address of return value's type
  push rbx                                                       ; internal argument 5: pointer to return value slot's type
  sub rsp, 020h                                                  ; allocate shadow space
  mov r9, 000h                                                   ; internal argument 4: "this" pointer
  mov r8, 000h                                                   ; internal argument 3: "this" pointer type
  mov rdx, 000h                                                  ; internal argument 2: closure pointer
  mov rcx, 001h                                                  ; internal argument 1: number of actual arguments
  call func$println                                              ; jump to subroutine
  add rsp, 040h                                                  ; release shadow space and arguments (result in stack pointer)
  ; Line 21: println(bottles(count));
  ; Call bottles with 1 arguments
  push qword ptr [rbp + 040h]                                    ; value of argument #1 (count)
  push qword ptr [rbp + 038h]                                    ; type of argument #1
  lea rsi, qword ptr [rsp + 038h]                                ; load address of return value's value
  push rsi                                                       ; internal argument 6: pointer to return value slot's value
  lea rsi, qword ptr [rsp + 038h]                                ; load address of return value's type
  push rsi                                                       ; internal argument 5: pointer to return value slot's type
  sub rsp, 020h                                                  ; allocate shadow space
  mov r9, 000h                                                   ; internal argument 4: "this" pointer
  mov r8, 000h                                                   ; internal argument 3: "this" pointer type
  mov rdx, 000h                                                  ; internal argument 2: closure pointer
  mov rcx, 001h                                                  ; internal argument 1: number of actual arguments
  call func$bottles                                              ; jump to subroutine
  add rsp, 040h                                                  ; release shadow space and arguments (result in stack pointer)
  ; Call println with 1 arguments
  push qword ptr [rsp + 028h]                                    ; value of argument #1 (bottles return value)
  push qword ptr [rsp + 028h]                                    ; type of argument #1
  lea rax, qword ptr [rsp + 028h]                                ; load address of return value's value
  push rax                                                       ; internal argument 6: pointer to return value slot's value
  lea rax, qword ptr [rsp + 028h]                                ; load address of return value's type
  push rax                                                       ; internal argument 5: pointer to return value slot's type
  sub rsp, 020h                                                  ; allocate shadow space
  mov r9, 000h                                                   ; internal argument 4: "this" pointer
  mov r8, 000h                                                   ; internal argument 3: "this" pointer type
  mov rdx, 000h                                                  ; internal argument 2: closure pointer
  mov rcx, 001h                                                  ; internal argument 1: number of actual arguments
  call func$println                                              ; jump to subroutine
  add rsp, 040h                                                  ; release shadow space and arguments (result in stack pointer)
  ; Line 22: if (count == 1) { ...
  xor rdi, rdi                                                   ; zero value result of == (testing count and 1) to put the boolean in
  cmp qword ptr [rbp + 040h], 001h                               ; values equal?
  sete dil                                                       ; put result in value result of == (testing count and 1)
  mov r12, 014h                                                  ; value result of == (testing count and 1) is a Boolean'20
  xor r13, r13                                                   ; zero type result of == (testing count and 1) to put the boolean in
  cmp qword ptr [rbp + 038h], 015h                               ; types equal?
  sete r13b                                                      ; put result in type result of == (testing count and 1)
  mov r14, 014h                                                  ; type result of == (testing count and 1) is a Boolean'20
  mov r15, rdi                                                   ; assign value of value result of == (testing count and 1) to value of == operator result
  and r15, r13                                                   ; && type temp and value temp
  mov r10, 014h                                                  ; == operator result is of type Boolean'20
  cmp r15, 000h                                                  ; compare == operator result to false
  je func$stanza$if$else                                         ; count == 1
    ; Line 23: println('Take it down, pass it around');
    ; Call println with 1 arguments
    mov rbx, offset string$26                                    ; reading string for push
    push rbx                                                     ; value of argument #1 (string)
    push 016h                                                    ; type of argument #1 (String'22)
    lea rsi, qword ptr [rsp + 028h]                              ; load address of return value's value
    push rsi                                                     ; internal argument 6: pointer to return value slot's value
    lea rsi, qword ptr [rsp + 028h]                              ; load address of return value's type
    push rsi                                                     ; internal argument 5: pointer to return value slot's type
    sub rsp, 020h                                                ; allocate shadow space
    mov r9, 000h                                                 ; internal argument 4: "this" pointer
    mov r8, 000h                                                 ; internal argument 3: "this" pointer type
    mov rdx, 000h                                                ; internal argument 2: closure pointer
    mov rcx, 001h                                                ; internal argument 1: number of actual arguments
    call func$println                                            ; jump to subroutine
    add rsp, 040h                                                ; release shadow space and arguments (result in stack pointer)
  jmp func$stanza$if$continuation                                ; jump past else part of if
  func$stanza$if$else:                                           ; else of if
    ; Line 25: println('Take one down, pass it around');
    ; Call println with 1 arguments
    mov rax, offset string$27                                    ; reading string for push
    push rax                                                     ; value of argument #1 (string)
    push 016h                                                    ; type of argument #1 (String'22)
    lea rdi, qword ptr [rsp + 028h]                              ; load address of return value's value
    push rdi                                                     ; internal argument 6: pointer to return value slot's value
    lea rdi, qword ptr [rsp + 028h]                              ; load address of return value's type
    push rdi                                                     ; internal argument 5: pointer to return value slot's type
    sub rsp, 020h                                                ; allocate shadow space
    mov r9, 000h                                                 ; internal argument 4: "this" pointer
    mov r8, 000h                                                 ; internal argument 3: "this" pointer type
    mov rdx, 000h                                                ; internal argument 2: closure pointer
    mov rcx, 001h                                                ; internal argument 1: number of actual arguments
    call func$println                                            ; jump to subroutine
    add rsp, 040h                                                ; release shadow space and arguments (result in stack pointer)
  func$stanza$if$continuation:                                   ; end of if
  ; Line 27: println(wall(count - 1));
  mov r12, qword ptr [rbp + 040h]                                ; assign value of count to value of - operator result
  sub r12, 001h                                                  ; compute (count) - (1)
  mov r13, 015h                                                  ; - operator result is of type Integer'21
  ; Call wall with 1 arguments
  push r12                                                       ; value of argument #1 (- operator result)
  push r13                                                       ; type of argument #1
  lea r14, qword ptr [rsp + 028h]                                ; load address of return value's value
  push r14                                                       ; internal argument 6: pointer to return value slot's value
  lea r14, qword ptr [rsp + 028h]                                ; load address of return value's type
  push r14                                                       ; internal argument 5: pointer to return value slot's type
  sub rsp, 020h                                                  ; allocate shadow space
  mov r9, 000h                                                   ; internal argument 4: "this" pointer
  mov r8, 000h                                                   ; internal argument 3: "this" pointer type
  mov rdx, 000h                                                  ; internal argument 2: closure pointer
  mov rcx, 001h                                                  ; internal argument 1: number of actual arguments
  call func$wall                                                 ; jump to subroutine
  add rsp, 040h                                                  ; release shadow space and arguments (result in stack pointer)
  ; Call println with 1 arguments
  push qword ptr [rsp + 018h]                                    ; value of argument #1 (wall return value)
  push qword ptr [rsp + 018h]                                    ; type of argument #1
  lea r15, qword ptr [rsp + 018h]                                ; load address of return value's value
  push r15                                                       ; internal argument 6: pointer to return value slot's value
  lea r15, qword ptr [rsp + 018h]                                ; load address of return value's type
  push r15                                                       ; internal argument 5: pointer to return value slot's type
  sub rsp, 020h                                                  ; allocate shadow space
  mov r9, 000h                                                   ; internal argument 4: "this" pointer
  mov r8, 000h                                                   ; internal argument 3: "this" pointer type
  mov rdx, 000h                                                  ; internal argument 2: closure pointer
  mov rcx, 001h                                                  ; internal argument 1: number of actual arguments
  call func$println                                              ; jump to subroutine
  add rsp, 040h                                                  ; release shadow space and arguments (result in stack pointer)
  ; Implicit return from stanza
  mov r10, qword ptr [rbp + 030h]                                ; get pointer to return value of stanza into register to dereference it
  mov qword ptr [r10], 000h                                      ; stanza return value
  mov rbx, qword ptr [rbp + 028h]                                ; get pointer to return value type of stanza into register to dereference it
  mov qword ptr [rbx], 013h                                      ; type of stanza return value (Null'19)
  ; Calling decref on bottles return value (static type: String'22)
  sub rsp, 20h                                                   ; allocate shadow space for decref
  mov rdx, qword ptr [rsp + 040h]                                ; arg #2: type of potential string
  mov rcx, qword ptr [rsp + 048h]                                ; arg #1: value of potential string
  call intrinsic$decref                                          ; call decref
  add rsp, 20h                                                   ; free shadow space for decref
  ; Calling decref on wall return value (static type: String'22)
  sub rsp, 20h                                                   ; allocate shadow space for decref
  mov rdx, qword ptr [rsp + 058h]                                ; arg #2: type of potential string
  mov rcx, qword ptr [rsp + 060h]                                ; arg #1: value of potential string
  call intrinsic$decref                                          ; call decref
  add rsp, 20h                                                   ; free shadow space for decref
  ; Calling decref on wall return value (static type: String'22)
  sub rsp, 20h                                                   ; allocate shadow space for decref
  mov rdx, qword ptr [rsp + 030h]                                ; arg #2: type of potential string
  mov rcx, qword ptr [rsp + 038h]                                ; arg #1: value of potential string
  call intrinsic$decref                                          ; call decref
  add rsp, 20h                                                   ; free shadow space for decref
  jmp func$stanza$epilog                                         ; return
  func$stanza$epilog: 
  mov rax, qword ptr [rbp + 030h]                                ; report address of return value
  ; Epilog
  add rsp, 050h                                                  ; free space for stack
  pop r14                                                        ; restore non-volatile registers
  pop r13                                                        ; restore non-volatile registers
  pop r12                                                        ; restore non-volatile registers
  pop rbp                                                        ; restore non-volatile registers
  pop rdi                                                        ; restore non-volatile registers
  pop rsi                                                        ; restore non-volatile registers
  pop rbx                                                        ; restore non-volatile registers
  pop r15                                                        ; restore non-volatile registers
  ret                                                            ; return from subroutine

; allBottles
func$allBottles:
  ; Prolog
  push r15                                                       ; save non-volatile registers
  push rbx                                                       ; save non-volatile registers
  push rsi                                                       ; save non-volatile registers
  push rdi                                                       ; save non-volatile registers
  push rbp                                                       ; save non-volatile registers
  push r12                                                       ; save non-volatile registers
  push r13                                                       ; save non-volatile registers
  push r14                                                       ; save non-volatile registers
  sub rsp, 028h                                                  ; allocate space for stack
  lea rbp, qword ptr [rsp + 068h]                                ; set up frame pointer
  ; Check parameter count
  cmp rcx, 000h                                                  ; compare parameter count of allBottles to 0 (integer)
  je func$allBottles$parameterCountCheck$continuation            ; check number of parameters is as expected
    ; Error handling block for parameter count
    ;  - print(parameterCountCheckFailureMessage)
    ; Call __print with 1 arguments
    mov r10, offset parameterCountCheckFailureMessage            ; reading parameterCountCheckFailureMessage for push
    push r10                                                     ; value of argument #1 (parameterCountCheckFailureMessage)
    push 016h                                                    ; type of argument #1 (String'22)
    lea rax, qword ptr [rsp + 028h]                              ; load address of return value's value
    push rax                                                     ; internal argument 6: pointer to return value slot's value
    lea rax, qword ptr [rsp + 028h]                              ; load address of return value's type
    push rax                                                     ; internal argument 5: pointer to return value slot's type
    sub rsp, 020h                                                ; allocate shadow space
    mov r9, 000h                                                 ; internal argument 4: "this" pointer
    mov r8, 000h                                                 ; internal argument 3: "this" pointer type
    mov rdx, 000h                                                ; internal argument 2: closure pointer
    mov qword ptr [rsp + 048h], rcx                              ; move parameter count of allBottles value out of rcx
    mov rcx, 001h                                                ; internal argument 1: number of actual arguments
    call func$__print                                            ; jump to subroutine
    add rsp, 040h                                                ; release shadow space and arguments (result in stack pointer)
    ;  - exit(1)
    ; Call exit with 1 arguments
    push 001h                                                    ; value of argument #1 (1 (integer))
    push 015h                                                    ; type of argument #1 (Integer'21)
    lea rbx, qword ptr [rsp + 028h]                              ; load address of return value's value
    push rbx                                                     ; internal argument 6: pointer to return value slot's value
    lea rbx, qword ptr [rsp + 028h]                              ; load address of return value's type
    push rbx                                                     ; internal argument 5: pointer to return value slot's type
    sub rsp, 020h                                                ; allocate shadow space
    mov r9, 000h                                                 ; internal argument 4: "this" pointer
    mov r8, 000h                                                 ; internal argument 3: "this" pointer type
    mov rdx, 000h                                                ; internal argument 2: closure pointer
    mov rcx, 001h                                                ; internal argument 1: number of actual arguments
    call func$exit                                               ; jump to subroutine
    add rsp, 040h                                                ; release shadow space and arguments (result in stack pointer)
    mov rcx, qword ptr [rsp + 008h]                              ; restoring slots to previous scope state
  func$allBottles$parameterCountCheck$continuation:              ; end of parameter count check
  ; Line 31: Integer count = 99 /* 0x63 */;
  mov rsi, 063h                                                  ; value initialization of variable declaration for count variable (99 /* 0x63 */)
  mov rdi, 015h                                                  ; type initialization of variable declaration for count variable (Integer'21)
  func$allBottles$while$top:                                     ; top of while
    xor r12, r12                                                 ; clear > operator result
    cmp rsi, 000h                                                ; compare count variable with 0
    setg r12b                                                    ; store result in > operator result
    mov r13, 014h                                                ; > operator result is of type Boolean'20
    cmp r12, 000h                                                ; compare > operator result to false
    jne func$allBottles$while$body                               ; while condition
    jmp func$allBottles$while$bottom                             ; break out of while
    func$allBottles$while$body:                                  ; start of while
    ; Line 33: stanza(count);
    ; Call stanza with 1 arguments
    push rsi                                                     ; value of argument #1 (count variable)
    push rdi                                                     ; type of argument #1
    lea r14, qword ptr [rsp + 028h]                              ; load address of return value's value
    push r14                                                     ; internal argument 6: pointer to return value slot's value
    lea r14, qword ptr [rsp + 028h]                              ; load address of return value's type
    push r14                                                     ; internal argument 5: pointer to return value slot's type
    sub rsp, 020h                                                ; allocate shadow space
    mov r9, 000h                                                 ; internal argument 4: "this" pointer
    mov r8, 000h                                                 ; internal argument 3: "this" pointer type
    mov rdx, 000h                                                ; internal argument 2: closure pointer
    mov qword ptr [rsp + 048h], rcx                              ; move parameter count of allBottles value out of rcx
    mov rcx, 001h                                                ; internal argument 1: number of actual arguments
    call func$stanza                                             ; jump to subroutine
    add rsp, 040h                                                ; release shadow space and arguments (result in stack pointer)
    ; Line 34: count -= 1;
    mov r15, rsi                                                 ; assign value of count variable to value of -= operator result
    sub r15, 001h                                                ; -= operator
    mov r10, 015h                                                ; -= operator result is of type Integer'21
    mov rsi, r15                                                 ; store value
    mov rdi, r10                                                 ; store type
    ; Line 35: if (count > 0) { ...
    xor rax, rax                                                 ; clear > operator result
    cmp rsi, 000h                                                ; compare count variable with 0
    setg al                                                      ; store result in > operator result
    mov rbx, 014h                                                ; > operator result is of type Boolean'20
    cmp rax, 000h                                                ; compare > operator result to false
    je func$allBottles$while$if$continuation                     ; count > 0
      ; Line 36: println();
      ; Call println with 0 arguments
      mov qword ptr [rsp + 010h], rsi                            ; move count variable value out of rsi
      lea rsi, qword ptr [rsp + 018h]                            ; load address of return value's value
      push rsi                                                   ; internal argument 6: pointer to return value slot's value
      lea rsi, qword ptr [rsp + 008h]                            ; load address of return value's type
      push rsi                                                   ; internal argument 5: pointer to return value slot's type
      sub rsp, 020h                                              ; allocate shadow space
      mov r9, 000h                                               ; internal argument 4: "this" pointer
      mov r8, 000h                                               ; internal argument 3: "this" pointer type
      mov rdx, 000h                                              ; internal argument 2: closure pointer
      mov rcx, 000h                                              ; internal argument 1: number of actual arguments
      call func$println                                          ; jump to subroutine
      add rsp, 030h                                              ; release shadow space and arguments (result in stack pointer)
      mov rsi, qword ptr [rsp + 010h]                            ; restoring slots to previous scope state
    func$allBottles$while$if$continuation:                       ; end of if
    mov rcx, qword ptr [rsp + 008h]                              ; restoring slots to previous scope state
    jmp func$allBottles$while$top                                ; return to top of while
  func$allBottles$while$bottom:                                  ; bottom of while
  ; Implicit return from allBottles
  mov rdi, qword ptr [rbp + 030h]                                ; get pointer to return value of allBottles into register to dereference it
  mov qword ptr [rdi], 000h                                      ; allBottles return value
  mov r12, qword ptr [rbp + 028h]                                ; get pointer to return value type of allBottles into register to dereference it
  mov qword ptr [r12], 013h                                      ; type of allBottles return value (Null'19)
  jmp func$allBottles$epilog                                     ; return
  func$allBottles$epilog: 
  mov rax, qword ptr [rbp + 030h]                                ; report address of return value
  ; Epilog
  add rsp, 028h                                                  ; free space for stack
  pop r14                                                        ; restore non-volatile registers
  pop r13                                                        ; restore non-volatile registers
  pop r12                                                        ; restore non-volatile registers
  pop rbp                                                        ; restore non-volatile registers
  pop rdi                                                        ; restore non-volatile registers
  pop rsi                                                        ; restore non-volatile registers
  pop rbx                                                        ; restore non-volatile registers
  pop r15                                                        ; restore non-volatile registers
  ret                                                            ; return from subroutine
end

