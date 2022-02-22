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
  typeTable    db 01fh, 010h, 010h, 010h, 011h, 012h, 014h, 018h ; Type table
   ; Columns: Null'4 Boolean'5 Integer'6 String'7 Anything'8
   ; 1 1 1 1 1   <sentinel>'0
   ; 0 0 0 0 1   NullFunction(String)'1
   ; 0 0 0 0 1   NullFunction(Integer)'2
   ; 0 0 0 0 1   StringFunction(Anything)'3
   ; 1 0 0 0 1   Null'4
   ; 0 1 0 0 1   Boolean'5
   ; 0 0 1 0 1   Integer'6
   ; 0 0 0 1 1   String'7

  parameterCountCheckFailureMessage dq -01h                      ; String constant (reference count)
               dq 88                                             ; Length
               db "error: function call received the wrong number of parameters (expected %d, received %d)", 0ah ; line 1374 column 25 in file syd-compiler.syd
  parameterTypeCheckFailureMessage dq -01h                       ; String constant (reference count)
               dq 71                                             ; Length
               db "error: type mismatch for function %s parameter %d, expected %s, got %s", 0ah ; line 1379 column 25 in file syd-compiler.syd
  returnValueTypeCheckFailureMessage dq -01h                     ; String constant (reference count)
               dq 68                                             ; Length
               db "error: type mismatch for function return value, expected %s, got %s", 0ah ; line 1384 column 25 in file syd-compiler.syd
  operandTypeCheckFailureMessage dq -01h                         ; String constant (reference count)
               dq 54                                             ; Length
               db "error: type mismatch for operand, expected %s, got %s", 0ah ; line 1389 column 25 in file syd-compiler.syd
  string       dq -01h                                           ; String constant (reference count)
               dq 4                                              ; Length
               db "true"                                         ; line 23 column 19 in file runtime library
  string$1     dq -01h                                           ; String constant (reference count)
               dq 5                                              ; Length
               db "false"                                        ; line 25 column 18 in file runtime library
  string$2     dq -01h                                           ; String constant (reference count)
               dq 4                                              ; Length
               db "null"                                         ; line 28 column 17 in file runtime library
  string$3     dq -01h                                           ; String constant (reference count)
               dq 25                                             ; Length
               db "Cannot stringify a value", 0ah                ; line 33 column 36 in file runtime library

.data


_BSS segment


.code

public main
main:
  ; intrinsics
  ; ==========
  ; Prolog
  push rbp                                                       ; save volatile registers
  lea rbp, [rsp+000h]                                            ; set up frame pointer
  ; Epilog
  pop rbp                                                        ; restore volatile registers

  ; runtime library
  ; ===============
  ; Prolog
  push rbp                                                       ; save volatile registers
  lea rbp, [rsp+000h]                                            ; set up frame pointer
  ; Epilog
  pop rbp                                                        ; restore volatile registers

  ; temp.syd
  ; ========
  ; Prolog
  push rbp                                                       ; save volatile registers
  sub rsp, 0310h                                                 ; allocate space for stack
  lea rbp, [rsp+0310h]                                           ; set up frame pointer
  ; Line 3: Integer c = a + b;
  mov qword ptr r11, 000000005h                                  ; add mutates first operand, so indirect via register
  add r11, 000000007h                                            ; + operator
  mov [rbp-0a8h], r11                                            ; store result
  mov qword ptr [rbp-0b0h], 000000006h                           ; store type
  ; Line 4: Integer d = a + b + c + 11 /* 0xb */;
  mov qword ptr r11, 000000005h                                  ; add mutates first operand, so indirect via register
  add r11, 000000007h                                            ; + operator
  mov [rbp-0158h], r11                                           ; store result
  mov qword ptr [rbp-0160h], 000000006h                          ; store type
  mov rax, [rbp-0160h]                                           ; load the dynamic type of a + b into rax
  lea r10, typeTable                                             ; move type table offset into r10
  add rax, r10                                                   ; adjust rax to point to the type table
  bt qword ptr [rax], 2                                          ; check that a + b is Integer'6
  jc tempSyd$aB$TypeMatch                                        ; skip next block if the type matches
    ; Error handling block for a + b
    ;  - print(operandTypeCheckFailureMessage)
    mov qword ptr [rbp-0168h], 0h                                ; value of this pointer for function call (placeholder)
    mov qword ptr [rbp-0170h], 000000000h                        ; type of this pointer for function call (placeholder)
    mov qword ptr [rbp-0178h], 0h                                ; value of closure pointer for function call (placeholder)
    mov r11, offset operandTypeCheckFailureMessage               ; value of argument #1
    push r11                                                     ; (indirect via r11 because "operandTypeCheckFailureMessage" is an imm64)
    push 000000007h                                              ; type of argument #1
    lea r11, [rbp-0180h]                                         ; pointer to return value (and type, 8 bytes earlier)
    push r11                                                     ; (that pointer is the last value pushed to the stack)
    lea r9, [rbp-0168h]                                          ; pointer to this
    mov r8, [rbp-0170h]                                          ; type of this
    lea rdx, [rbp-0178h]                                         ; pointer to closure
    mov rcx, 1                                                   ; number of arguments
    sub rsp, 20h                                                 ; allocate shadow space
    call offset func$print                                       ; jump to subroutine
    add rsp, 038h                                                ; release shadow space and arguments
    ;  - exit(1)
    mov qword ptr [rbp-0190h], 0h                                ; value of this pointer for function call (placeholder)
    mov qword ptr [rbp-0198h], 000000000h                        ; type of this pointer for function call (placeholder)
    mov qword ptr [rbp-01a0h], 0h                                ; value of closure pointer for function call (placeholder)
    push 000000001h                                              ; value of argument #1
    push 000000006h                                              ; type of argument #1
    lea r11, [rbp-01a8h]                                         ; pointer to return value (and type, 8 bytes earlier)
    push r11                                                     ; (that pointer is the last value pushed to the stack)
    lea r9, [rbp-0190h]                                          ; pointer to this
    mov r8, [rbp-0198h]                                          ; type of this
    lea rdx, [rbp-01a0h]                                         ; pointer to closure
    mov rcx, 1                                                   ; number of arguments
    sub rsp, 20h                                                 ; allocate shadow space
    call offset func$exit                                        ; jump to subroutine
    add rsp, 038h                                                ; release shadow space and arguments
  tempSyd$aB$TypeMatch:
  mov rax, [rbp-0b0h]                                            ; load the dynamic type of c into rax
  lea r10, typeTable                                             ; move type table offset into r10
  add rax, r10                                                   ; adjust rax to point to the type table
  bt qword ptr [rax], 2                                          ; check that c is Integer'6
  jc tempSyd$c$TypeMatch                                         ; skip next block if the type matches
    ; Error handling block for c
    ;  - print(operandTypeCheckFailureMessage)
    mov qword ptr [rbp-01b8h], 0h                                ; value of this pointer for function call (placeholder)
    mov qword ptr [rbp-01c0h], 000000000h                        ; type of this pointer for function call (placeholder)
    mov qword ptr [rbp-01c8h], 0h                                ; value of closure pointer for function call (placeholder)
    mov r11, offset operandTypeCheckFailureMessage               ; value of argument #1
    push r11                                                     ; (indirect via r11 because "operandTypeCheckFailureMessage" is an imm64)
    push 000000007h                                              ; type of argument #1
    lea r11, [rbp-01d0h]                                         ; pointer to return value (and type, 8 bytes earlier)
    push r11                                                     ; (that pointer is the last value pushed to the stack)
    lea r9, [rbp-01b8h]                                          ; pointer to this
    mov r8, [rbp-01c0h]                                          ; type of this
    lea rdx, [rbp-01c8h]                                         ; pointer to closure
    mov rcx, 1                                                   ; number of arguments
    sub rsp, 20h                                                 ; allocate shadow space
    call offset func$print                                       ; jump to subroutine
    add rsp, 038h                                                ; release shadow space and arguments
    ;  - exit(1)
    mov qword ptr [rbp-01e0h], 0h                                ; value of this pointer for function call (placeholder)
    mov qword ptr [rbp-01e8h], 000000000h                        ; type of this pointer for function call (placeholder)
    mov qword ptr [rbp-01f0h], 0h                                ; value of closure pointer for function call (placeholder)
    push 000000001h                                              ; value of argument #1
    push 000000006h                                              ; type of argument #1
    lea r11, [rbp-01f8h]                                         ; pointer to return value (and type, 8 bytes earlier)
    push r11                                                     ; (that pointer is the last value pushed to the stack)
    lea r9, [rbp-01e0h]                                          ; pointer to this
    mov r8, [rbp-01e8h]                                          ; type of this
    lea rdx, [rbp-01f0h]                                         ; pointer to closure
    mov rcx, 1                                                   ; number of arguments
    sub rsp, 20h                                                 ; allocate shadow space
    call offset func$exit                                        ; jump to subroutine
    add rsp, 038h                                                ; release shadow space and arguments
  tempSyd$c$TypeMatch:
  mov r11, [rbp-0158h]                                           ; add mutates first operand, so indirect via register
  add r11, [rbp-0a8h]                                            ; + operator
  mov [rbp-0208h], r11                                           ; store result
  mov qword ptr [rbp-0210h], 000000006h                          ; store type
  mov rax, [rbp-0210h]                                           ; load the dynamic type of a + b + c into rax
  lea r10, typeTable                                             ; move type table offset into r10
  add rax, r10                                                   ; adjust rax to point to the type table
  bt qword ptr [rax], 2                                          ; check that a + b + c is Integer'6
  jc tempSyd$aBC$TypeMatch                                       ; skip next block if the type matches
    ; Error handling block for a + b + c
    ;  - print(operandTypeCheckFailureMessage)
    mov qword ptr [rbp-0218h], 0h                                ; value of this pointer for function call (placeholder)
    mov qword ptr [rbp-0220h], 000000000h                        ; type of this pointer for function call (placeholder)
    mov qword ptr [rbp-0228h], 0h                                ; value of closure pointer for function call (placeholder)
    mov r11, offset operandTypeCheckFailureMessage               ; value of argument #1
    push r11                                                     ; (indirect via r11 because "operandTypeCheckFailureMessage" is an imm64)
    push 000000007h                                              ; type of argument #1
    lea r11, [rbp-0230h]                                         ; pointer to return value (and type, 8 bytes earlier)
    push r11                                                     ; (that pointer is the last value pushed to the stack)
    lea r9, [rbp-0218h]                                          ; pointer to this
    mov r8, [rbp-0220h]                                          ; type of this
    lea rdx, [rbp-0228h]                                         ; pointer to closure
    mov rcx, 1                                                   ; number of arguments
    sub rsp, 20h                                                 ; allocate shadow space
    call offset func$print                                       ; jump to subroutine
    add rsp, 038h                                                ; release shadow space and arguments
    ;  - exit(1)
    mov qword ptr [rbp-0240h], 0h                                ; value of this pointer for function call (placeholder)
    mov qword ptr [rbp-0248h], 000000000h                        ; type of this pointer for function call (placeholder)
    mov qword ptr [rbp-0250h], 0h                                ; value of closure pointer for function call (placeholder)
    push 000000001h                                              ; value of argument #1
    push 000000006h                                              ; type of argument #1
    lea r11, [rbp-0258h]                                         ; pointer to return value (and type, 8 bytes earlier)
    push r11                                                     ; (that pointer is the last value pushed to the stack)
    lea r9, [rbp-0240h]                                          ; pointer to this
    mov r8, [rbp-0248h]                                          ; type of this
    lea rdx, [rbp-0250h]                                         ; pointer to closure
    mov rcx, 1                                                   ; number of arguments
    sub rsp, 20h                                                 ; allocate shadow space
    call offset func$exit                                        ; jump to subroutine
    add rsp, 038h                                                ; release shadow space and arguments
  tempSyd$aBC$TypeMatch:
  mov r11, [rbp-0208h]                                           ; add mutates first operand, so indirect via register
  add r11, 00000000bh                                            ; + operator
  mov [rbp-02b8h], r11                                           ; store result
  mov qword ptr [rbp-02c0h], 000000006h                          ; store type
  ; Line 6: exit(d);
  mov qword ptr [rbp-02c8h], 0h                                  ; value of this pointer for function call (placeholder)
  mov qword ptr [rbp-02d0h], 000000000h                          ; type of this pointer for function call (placeholder)
  mov qword ptr [rbp-02d8h], 0h                                  ; value of closure pointer for function call (placeholder)
  push [rbp-02b8h]                                               ; value of argument #1
  push [rbp-02c0h]                                               ; type of argument #1
  lea r11, [rbp-02e0h]                                           ; pointer to return value (and type, 8 bytes earlier)
  push r11                                                       ; (that pointer is the last value pushed to the stack)
  lea r9, [rbp-02c8h]                                            ; pointer to this
  mov r8, [rbp-02d0h]                                            ; type of this
  lea rdx, [rbp-02d8h]                                           ; pointer to closure
  mov rcx, 1                                                     ; number of arguments
  sub rsp, 20h                                                   ; allocate shadow space
  call offset func$exit                                          ; jump to subroutine
  add rsp, 038h                                                  ; release shadow space and arguments
  ; Terminate application - call exit(0)
  mov qword ptr [rbp-02f0h], 0h                                  ; value of this pointer for function call (placeholder)
  mov qword ptr [rbp-02f8h], 000000000h                          ; type of this pointer for function call (placeholder)
  mov qword ptr [rbp-0300h], 0h                                  ; value of closure pointer for function call (placeholder)
  push 000000000h                                                ; value of argument #1
  push 000000006h                                                ; type of argument #1
  lea r11, [rbp-0308h]                                           ; pointer to return value (and type, 8 bytes earlier)
  push r11                                                       ; (that pointer is the last value pushed to the stack)
  lea r9, [rbp-02f0h]                                            ; pointer to this
  mov r8, [rbp-02f8h]                                            ; type of this
  lea rdx, [rbp-0300h]                                           ; pointer to closure
  mov rcx, 1                                                     ; number of arguments
  sub rsp, 20h                                                   ; allocate shadow space
  call offset func$exit                                          ; jump to subroutine
  add rsp, 038h                                                  ; release shadow space and arguments
  ; Epilog
  add rsp, 0310h                                                 ; free space for stack
  pop rbp                                                        ; restore volatile registers
  ; End of global scope
  ret                                                            ; exit application

; print
func$print:
  ; Prolog
  push rbp                                                       ; save volatile registers
  push r15                                                       ; save volatile registers
  sub rsp, 0a8h                                                  ; allocate space for stack
  lea rbp, [rsp+0a8h]                                            ; set up frame pointer
  mov r15, [rbp+038h]                                            ; prepare return value
  ; Check parameter count
  cmp qword ptr rcx, 000000001h                                  ; check number of parameters is as expected
  je func$print$parameterCount$continuation                      ; jump if they are equal
    ; Error handling block for parameter count
    ;  - print(parameterCountCheckFailureMessage)
    mov qword ptr [rbp-010h], 0h                                 ; value of this pointer for function call (placeholder)
    mov qword ptr [rbp-018h], 000000000h                         ; type of this pointer for function call (placeholder)
    mov qword ptr [rbp-020h], 0h                                 ; value of closure pointer for function call (placeholder)
    mov r11, offset parameterCountCheckFailureMessage            ; value of argument #1
    push r11                                                     ; (indirect via r11 because "parameterCountCheckFailureMessage" is an imm64)
    push 000000007h                                              ; type of argument #1
    lea r11, [rbp-028h]                                          ; pointer to return value (and type, 8 bytes earlier)
    push r11                                                     ; (that pointer is the last value pushed to the stack)
    lea r9, [rbp-010h]                                           ; pointer to this
    mov r8, [rbp-018h]                                           ; type of this
    lea rdx, [rbp-020h]                                          ; pointer to closure
    mov rcx, 1                                                   ; number of arguments
    sub rsp, 20h                                                 ; allocate shadow space
    call offset func$print                                       ; jump to subroutine
    add rsp, 038h                                                ; release shadow space and arguments
    ;  - exit(1)
    mov qword ptr [rbp-038h], 0h                                 ; value of this pointer for function call (placeholder)
    mov qword ptr [rbp-040h], 000000000h                         ; type of this pointer for function call (placeholder)
    mov qword ptr [rbp-048h], 0h                                 ; value of closure pointer for function call (placeholder)
    push 000000001h                                              ; value of argument #1
    push 000000006h                                              ; type of argument #1
    lea r11, [rbp-050h]                                          ; pointer to return value (and type, 8 bytes earlier)
    push r11                                                     ; (that pointer is the last value pushed to the stack)
    lea r9, [rbp-038h]                                           ; pointer to this
    mov r8, [rbp-040h]                                           ; type of this
    lea rdx, [rbp-048h]                                          ; pointer to closure
    mov rcx, 1                                                   ; number of arguments
    sub rsp, 20h                                                 ; allocate shadow space
    call offset func$exit                                        ; jump to subroutine
    add rsp, 038h                                                ; release shadow space and arguments
  func$print$parameterCount$continuation:                        ; end of parameter count
  ; Check type of parameter 0, message to print to console (expecting String)
  mov rax, [rbp+040h]                                            ; load the dynamic type of message to print to console into rax
  lea r10, typeTable                                             ; move type table offset into r10
  add rax, r10                                                   ; adjust rax to point to the type table
  bt qword ptr [rax], 3                                          ; check that message to print to console is String'7
  jc func$print$messageToPrintToConsole$TypeMatch                ; skip next block if the type matches
    ; Error handling block for message to print to console
    ;  - print(parameterTypeCheckFailureMessage)
    mov qword ptr [rbp-060h], 0h                                 ; value of this pointer for function call (placeholder)
    mov qword ptr [rbp-068h], 000000000h                         ; type of this pointer for function call (placeholder)
    mov qword ptr [rbp-070h], 0h                                 ; value of closure pointer for function call (placeholder)
    mov r11, offset parameterTypeCheckFailureMessage             ; value of argument #1
    push r11                                                     ; (indirect via r11 because "parameterTypeCheckFailureMessage" is an imm64)
    push 000000007h                                              ; type of argument #1
    lea r11, [rbp-078h]                                          ; pointer to return value (and type, 8 bytes earlier)
    push r11                                                     ; (that pointer is the last value pushed to the stack)
    lea r9, [rbp-060h]                                           ; pointer to this
    mov r8, [rbp-068h]                                           ; type of this
    lea rdx, [rbp-070h]                                          ; pointer to closure
    mov rcx, 1                                                   ; number of arguments
    sub rsp, 20h                                                 ; allocate shadow space
    call offset func$print                                       ; jump to subroutine
    add rsp, 038h                                                ; release shadow space and arguments
    ;  - exit(1)
    mov qword ptr [rbp-088h], 0h                                 ; value of this pointer for function call (placeholder)
    mov qword ptr [rbp-090h], 000000000h                         ; type of this pointer for function call (placeholder)
    mov qword ptr [rbp-098h], 0h                                 ; value of closure pointer for function call (placeholder)
    push 000000001h                                              ; value of argument #1
    push 000000006h                                              ; type of argument #1
    lea r11, [rbp-0a0h]                                          ; pointer to return value (and type, 8 bytes earlier)
    push r11                                                     ; (that pointer is the last value pushed to the stack)
    lea r9, [rbp-088h]                                           ; pointer to this
    mov r8, [rbp-090h]                                           ; type of this
    lea rdx, [rbp-098h]                                          ; pointer to closure
    mov rcx, 1                                                   ; number of arguments
    sub rsp, 20h                                                 ; allocate shadow space
    call offset func$exit                                        ; jump to subroutine
    add rsp, 038h                                                ; release shadow space and arguments
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
  pop r15                                                        ; restore volatile registers
  pop rbp                                                        ; restore volatile registers
  ret                                                            ; return from subroutine

; exit
func$exit:
  ; Prolog
  push rbp                                                       ; save volatile registers
  push r15                                                       ; save volatile registers
  sub rsp, 0a0h                                                  ; allocate space for stack
  lea rbp, [rsp+0a0h]                                            ; set up frame pointer
  mov r15, [rbp+038h]                                            ; prepare return value
  ; Check parameter count
  cmp qword ptr rcx, 000000001h                                  ; check number of parameters is as expected
  je func$exit$parameterCount$continuation                       ; jump if they are equal
    ; Error handling block for parameter count
    ;  - print(parameterCountCheckFailureMessage)
    mov qword ptr [rbp-008h], 0h                                 ; value of this pointer for function call (placeholder)
    mov qword ptr [rbp-010h], 000000000h                         ; type of this pointer for function call (placeholder)
    mov qword ptr [rbp-018h], 0h                                 ; value of closure pointer for function call (placeholder)
    mov r11, offset parameterCountCheckFailureMessage            ; value of argument #1
    push r11                                                     ; (indirect via r11 because "parameterCountCheckFailureMessage" is an imm64)
    push 000000007h                                              ; type of argument #1
    lea r11, [rbp-020h]                                          ; pointer to return value (and type, 8 bytes earlier)
    push r11                                                     ; (that pointer is the last value pushed to the stack)
    lea r9, [rbp-008h]                                           ; pointer to this
    mov r8, [rbp-010h]                                           ; type of this
    lea rdx, [rbp-018h]                                          ; pointer to closure
    mov rcx, 1                                                   ; number of arguments
    sub rsp, 20h                                                 ; allocate shadow space
    call offset func$print                                       ; jump to subroutine
    add rsp, 038h                                                ; release shadow space and arguments
    ;  - exit(1)
    mov qword ptr [rbp-030h], 0h                                 ; value of this pointer for function call (placeholder)
    mov qword ptr [rbp-038h], 000000000h                         ; type of this pointer for function call (placeholder)
    mov qword ptr [rbp-040h], 0h                                 ; value of closure pointer for function call (placeholder)
    push 000000001h                                              ; value of argument #1
    push 000000006h                                              ; type of argument #1
    lea r11, [rbp-048h]                                          ; pointer to return value (and type, 8 bytes earlier)
    push r11                                                     ; (that pointer is the last value pushed to the stack)
    lea r9, [rbp-030h]                                           ; pointer to this
    mov r8, [rbp-038h]                                           ; type of this
    lea rdx, [rbp-040h]                                          ; pointer to closure
    mov rcx, 1                                                   ; number of arguments
    sub rsp, 20h                                                 ; allocate shadow space
    call offset func$exit                                        ; jump to subroutine
    add rsp, 038h                                                ; release shadow space and arguments
  func$exit$parameterCount$continuation:                         ; end of parameter count
  ; Check type of parameter 0, exit code parameter (expecting Integer)
  mov rax, [rbp+040h]                                            ; load the dynamic type of exit code parameter into rax
  lea r10, typeTable                                             ; move type table offset into r10
  add rax, r10                                                   ; adjust rax to point to the type table
  bt qword ptr [rax], 2                                          ; check that exit code parameter is Integer'6
  jc func$exit$exitCodeParameter$TypeMatch                       ; skip next block if the type matches
    ; Error handling block for exit code parameter
    ;  - print(parameterTypeCheckFailureMessage)
    mov qword ptr [rbp-058h], 0h                                 ; value of this pointer for function call (placeholder)
    mov qword ptr [rbp-060h], 000000000h                         ; type of this pointer for function call (placeholder)
    mov qword ptr [rbp-068h], 0h                                 ; value of closure pointer for function call (placeholder)
    mov r11, offset parameterTypeCheckFailureMessage             ; value of argument #1
    push r11                                                     ; (indirect via r11 because "parameterTypeCheckFailureMessage" is an imm64)
    push 000000007h                                              ; type of argument #1
    lea r11, [rbp-070h]                                          ; pointer to return value (and type, 8 bytes earlier)
    push r11                                                     ; (that pointer is the last value pushed to the stack)
    lea r9, [rbp-058h]                                           ; pointer to this
    mov r8, [rbp-060h]                                           ; type of this
    lea rdx, [rbp-068h]                                          ; pointer to closure
    mov rcx, 1                                                   ; number of arguments
    sub rsp, 20h                                                 ; allocate shadow space
    call offset func$print                                       ; jump to subroutine
    add rsp, 038h                                                ; release shadow space and arguments
    ;  - exit(1)
    mov qword ptr [rbp-080h], 0h                                 ; value of this pointer for function call (placeholder)
    mov qword ptr [rbp-088h], 000000000h                         ; type of this pointer for function call (placeholder)
    mov qword ptr [rbp-090h], 0h                                 ; value of closure pointer for function call (placeholder)
    push 000000001h                                              ; value of argument #1
    push 000000006h                                              ; type of argument #1
    lea r11, [rbp-098h]                                          ; pointer to return value (and type, 8 bytes earlier)
    push r11                                                     ; (that pointer is the last value pushed to the stack)
    lea r9, [rbp-080h]                                           ; pointer to this
    mov r8, [rbp-088h]                                           ; type of this
    lea rdx, [rbp-090h]                                          ; pointer to closure
    mov rcx, 1                                                   ; number of arguments
    sub rsp, 20h                                                 ; allocate shadow space
    call offset func$exit                                        ; jump to subroutine
    add rsp, 038h                                                ; release shadow space and arguments
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
  pop r15                                                        ; restore volatile registers
  pop rbp                                                        ; restore volatile registers
  ret                                                            ; return from subroutine

; stringify
func$stringify:
  ; Prolog
  push rbp                                                       ; save volatile registers
  push r15                                                       ; save volatile registers
  sub rsp, 0270h                                                 ; allocate space for stack
  lea rbp, [rsp+0270h]                                           ; set up frame pointer
  mov r15, [rbp+038h]                                            ; prepare return value
  ; Check parameter count
  cmp qword ptr rcx, 000000001h                                  ; check number of parameters is as expected
  je func$stringify$parameterCount$continuation                  ; jump if they are equal
    ; Error handling block for parameter count
    ;  - print(parameterCountCheckFailureMessage)
    mov qword ptr [rbp-008h], 0h                                 ; value of this pointer for function call (placeholder)
    mov qword ptr [rbp-010h], 000000000h                         ; type of this pointer for function call (placeholder)
    mov qword ptr [rbp-018h], 0h                                 ; value of closure pointer for function call (placeholder)
    mov r11, offset parameterCountCheckFailureMessage            ; value of argument #1
    push r11                                                     ; (indirect via r11 because "parameterCountCheckFailureMessage" is an imm64)
    push 000000007h                                              ; type of argument #1
    lea r11, [rbp-020h]                                          ; pointer to return value (and type, 8 bytes earlier)
    push r11                                                     ; (that pointer is the last value pushed to the stack)
    lea r9, [rbp-008h]                                           ; pointer to this
    mov r8, [rbp-010h]                                           ; type of this
    lea rdx, [rbp-018h]                                          ; pointer to closure
    mov rcx, 1                                                   ; number of arguments
    sub rsp, 20h                                                 ; allocate shadow space
    call offset func$print                                       ; jump to subroutine
    add rsp, 038h                                                ; release shadow space and arguments
    ;  - exit(1)
    mov qword ptr [rbp-030h], 0h                                 ; value of this pointer for function call (placeholder)
    mov qword ptr [rbp-038h], 000000000h                         ; type of this pointer for function call (placeholder)
    mov qword ptr [rbp-040h], 0h                                 ; value of closure pointer for function call (placeholder)
    push 000000001h                                              ; value of argument #1
    push 000000006h                                              ; type of argument #1
    lea r11, [rbp-048h]                                          ; pointer to return value (and type, 8 bytes earlier)
    push r11                                                     ; (that pointer is the last value pushed to the stack)
    lea r9, [rbp-030h]                                           ; pointer to this
    mov r8, [rbp-038h]                                           ; type of this
    lea rdx, [rbp-040h]                                          ; pointer to closure
    mov rcx, 1                                                   ; number of arguments
    sub rsp, 20h                                                 ; allocate shadow space
    call offset func$exit                                        ; jump to subroutine
    add rsp, 038h                                                ; release shadow space and arguments
  func$stringify$parameterCount$continuation:                    ; end of parameter count
  ; Check type of parameter 0, arg (expecting Anything)
  mov rax, [rbp+040h]                                            ; load the dynamic type of arg into rax
  lea r10, typeTable                                             ; move type table offset into r10
  add rax, r10                                                   ; adjust rax to point to the type table
  bt qword ptr [rax], 4                                          ; check that arg is Anything'8
  jc func$stringify$arg$TypeMatch                                ; skip next block if the type matches
    ; Error handling block for arg
    ;  - print(parameterTypeCheckFailureMessage)
    mov qword ptr [rbp-058h], 0h                                 ; value of this pointer for function call (placeholder)
    mov qword ptr [rbp-060h], 000000000h                         ; type of this pointer for function call (placeholder)
    mov qword ptr [rbp-068h], 0h                                 ; value of closure pointer for function call (placeholder)
    mov r11, offset parameterTypeCheckFailureMessage             ; value of argument #1
    push r11                                                     ; (indirect via r11 because "parameterTypeCheckFailureMessage" is an imm64)
    push 000000007h                                              ; type of argument #1
    lea r11, [rbp-070h]                                          ; pointer to return value (and type, 8 bytes earlier)
    push r11                                                     ; (that pointer is the last value pushed to the stack)
    lea r9, [rbp-058h]                                           ; pointer to this
    mov r8, [rbp-060h]                                           ; type of this
    lea rdx, [rbp-068h]                                          ; pointer to closure
    mov rcx, 1                                                   ; number of arguments
    sub rsp, 20h                                                 ; allocate shadow space
    call offset func$print                                       ; jump to subroutine
    add rsp, 038h                                                ; release shadow space and arguments
    ;  - exit(1)
    mov qword ptr [rbp-080h], 0h                                 ; value of this pointer for function call (placeholder)
    mov qword ptr [rbp-088h], 000000000h                         ; type of this pointer for function call (placeholder)
    mov qword ptr [rbp-090h], 0h                                 ; value of closure pointer for function call (placeholder)
    push 000000001h                                              ; value of argument #1
    push 000000006h                                              ; type of argument #1
    lea r11, [rbp-098h]                                          ; pointer to return value (and type, 8 bytes earlier)
    push r11                                                     ; (that pointer is the last value pushed to the stack)
    lea r9, [rbp-080h]                                           ; pointer to this
    mov r8, [rbp-088h]                                           ; type of this
    lea rdx, [rbp-090h]                                          ; pointer to closure
    mov rcx, 1                                                   ; number of arguments
    sub rsp, 20h                                                 ; allocate shadow space
    call offset func$exit                                        ; jump to subroutine
    add rsp, 038h                                                ; release shadow space and arguments
  func$stringify$arg$TypeMatch:
  ; Line 18: if (arg is String) { ...
  mov rax, [rbp+040h]                                            ; load the dynamic type of arg into rax
  lea r10, typeTable                                             ; move type table offset into r10
  add rax, r10                                                   ; adjust rax to point to the type table
  bt qword ptr [rax], 3                                          ; check that arg is String'7
  mov qword ptr [rbp-0a8h], 000000000h                           ; clear is expression result
  setc byte ptr [rbp-0a8h]                                       ; store result in is expression result
  mov qword ptr [rbp-0b0h], 000000005h                           ; is expression result is a Boolean
  cmp qword ptr [rbp-0a8h], 000000000h                           ; arg is String
  je func$stringify$if$continuation                              ; jump if they are equal
    ; Line 19: return arg;
    mov rax, [rbp+040h]                                          ; load the dynamic type of return value of stringify into rax
    lea r10, typeTable                                           ; move type table offset into r10
    add rax, r10                                                 ; adjust rax to point to the type table
    bt qword ptr [rax], 3                                        ; check that return value of stringify is String'7
    jc func$stringify$stringify$if$block$returnValueOfStringify$TypeMatch ; skip next block if the type matches
      ; Error handling block for return value of stringify
      ;  - print(returnValueTypeCheckFailureMessage)
      mov qword ptr [rbp-0b8h], 0h                               ; value of this pointer for function call (placeholder)
      mov qword ptr [rbp-0c0h], 000000000h                       ; type of this pointer for function call (placeholder)
      mov qword ptr [rbp-0c8h], 0h                               ; value of closure pointer for function call (placeholder)
      mov r11, offset returnValueTypeCheckFailureMessage         ; value of argument #1
      push r11                                                   ; (indirect via r11 because "returnValueTypeCheckFailureMessage" is an imm64)
      push 000000007h                                            ; type of argument #1
      lea r11, [rbp-0d0h]                                        ; pointer to return value (and type, 8 bytes earlier)
      push r11                                                   ; (that pointer is the last value pushed to the stack)
      lea r9, [rbp-0b8h]                                         ; pointer to this
      mov r8, [rbp-0c0h]                                         ; type of this
      lea rdx, [rbp-0c8h]                                        ; pointer to closure
      mov rcx, 1                                                 ; number of arguments
      sub rsp, 20h                                               ; allocate shadow space
      call offset func$print                                     ; jump to subroutine
      add rsp, 038h                                              ; release shadow space and arguments
      ;  - exit(1)
      mov qword ptr [rbp-0e0h], 0h                               ; value of this pointer for function call (placeholder)
      mov qword ptr [rbp-0e8h], 000000000h                       ; type of this pointer for function call (placeholder)
      mov qword ptr [rbp-0f0h], 0h                               ; value of closure pointer for function call (placeholder)
      push 000000001h                                            ; value of argument #1
      push 000000006h                                            ; type of argument #1
      lea r11, [rbp-0f8h]                                        ; pointer to return value (and type, 8 bytes earlier)
      push r11                                                   ; (that pointer is the last value pushed to the stack)
      lea r9, [rbp-0e0h]                                         ; pointer to this
      mov r8, [rbp-0e8h]                                         ; type of this
      lea rdx, [rbp-0f0h]                                        ; pointer to closure
      mov rcx, 1                                                 ; number of arguments
      sub rsp, 20h                                               ; allocate shadow space
      call offset func$exit                                      ; jump to subroutine
      add rsp, 038h                                              ; release shadow space and arguments
    func$stringify$stringify$if$block$returnValueOfStringify$TypeMatch:
    mov r11, [rbp+048h]                                          ; value of return value
    mov [r15], r11                                               ; (indirect via r11 because mov can't do memory-to-memory)
    mov r11, [rbp+040h]                                          ; type of return value
    mov [r15-08h], r11                                           ; (indirect via r11 because mov can't do memory-to-memory)
    jmp func$stringify$epilog                                    ; return
  func$stringify$if$continuation:                                ; end of if
  ; Line 21: if (arg is Boolean) { ...
  mov rax, [rbp+040h]                                            ; load the dynamic type of arg into rax
  lea r10, typeTable                                             ; move type table offset into r10
  add rax, r10                                                   ; adjust rax to point to the type table
  bt qword ptr [rax], 1                                          ; check that arg is Boolean'5
  mov qword ptr [rbp-0108h], 000000000h                          ; clear is expression result
  setc byte ptr [rbp-0108h]                                      ; store result in is expression result
  mov qword ptr [rbp-0110h], 000000005h                          ; is expression result is a Boolean
  cmp qword ptr [rbp-0108h], 000000000h                          ; arg is Boolean
  je func$stringify$if$continuation$1                            ; jump if they are equal
    ; Line 22: if (arg) { ...
    cmp qword ptr [rbp+048h], 000000000h                         ; arg
    je func$stringify$stringify$if$block$1$if$continuation       ; jump if they are equal
      ; Line 23: return 'true';
      mov r11, offset string                                     ; value of return value
      mov [r15], r11                                             ; (indirect via r11 because "string" is an imm64)
      mov qword ptr [r15-08h], 000000007h                        ; type of return value
      jmp func$stringify$epilog                                  ; return
    func$stringify$stringify$if$block$1$if$continuation:         ; end of if
    ; Line 25: return 'false';
    mov r11, offset string$1                                     ; value of return value
    mov [r15], r11                                               ; (indirect via r11 because "string$1" is an imm64)
    mov qword ptr [r15-08h], 000000007h                          ; type of return value
    jmp func$stringify$epilog                                    ; return
  func$stringify$if$continuation$1:                              ; end of if
  ; Line 27: if (arg is Null) { ...
  mov rax, [rbp+040h]                                            ; load the dynamic type of arg into rax
  lea r10, typeTable                                             ; move type table offset into r10
  add rax, r10                                                   ; adjust rax to point to the type table
  bt qword ptr [rax], 0                                          ; check that arg is Null'4
  mov qword ptr [rbp-01b8h], 000000000h                          ; clear is expression result
  setc byte ptr [rbp-01b8h]                                      ; store result in is expression result
  mov qword ptr [rbp-01c0h], 000000005h                          ; is expression result is a Boolean
  cmp qword ptr [rbp-01b8h], 000000000h                          ; arg is Null
  je func$stringify$if$continuation$2                            ; jump if they are equal
    ; Line 28: return 'null';
    mov r11, offset string$2                                     ; value of return value
    mov [r15], r11                                               ; (indirect via r11 because "string$2" is an imm64)
    mov qword ptr [r15-08h], 000000007h                          ; type of return value
    jmp func$stringify$epilog                                    ; return
  func$stringify$if$continuation$2:                              ; end of if
  ; Line 30: if (arg is Integer) {}...
  mov rax, [rbp+040h]                                            ; load the dynamic type of arg into rax
  lea r10, typeTable                                             ; move type table offset into r10
  add rax, r10                                                   ; adjust rax to point to the type table
  bt qword ptr [rax], 2                                          ; check that arg is Integer'6
  mov qword ptr [rbp-0218h], 000000000h                          ; clear is expression result
  setc byte ptr [rbp-0218h]                                      ; store result in is expression result
  mov qword ptr [rbp-0220h], 000000005h                          ; is expression result is a Boolean
  cmp qword ptr [rbp-0218h], 000000000h                          ; arg is Integer
  je func$stringify$if$continuation$3                            ; jump if they are equal
  func$stringify$if$continuation$3:                              ; end of if
  ; Line 33: print('Cannot stringify a value\n');
  mov qword ptr [rbp-0228h], 0h                                  ; value of this pointer for function call (placeholder)
  mov qword ptr [rbp-0230h], 000000000h                          ; type of this pointer for function call (placeholder)
  mov qword ptr [rbp-0238h], 0h                                  ; value of closure pointer for function call (placeholder)
  mov r11, offset string$3                                       ; value of argument #1
  push r11                                                       ; (indirect via r11 because "string$3" is an imm64)
  push 000000007h                                                ; type of argument #1
  lea r11, [rbp-0240h]                                           ; pointer to return value (and type, 8 bytes earlier)
  push r11                                                       ; (that pointer is the last value pushed to the stack)
  lea r9, [rbp-0228h]                                            ; pointer to this
  mov r8, [rbp-0230h]                                            ; type of this
  lea rdx, [rbp-0238h]                                           ; pointer to closure
  mov rcx, 1                                                     ; number of arguments
  sub rsp, 20h                                                   ; allocate shadow space
  call offset func$print                                         ; jump to subroutine
  add rsp, 038h                                                  ; release shadow space and arguments
  ; Line 34: exit(1 /* 0x1 */);
  mov qword ptr [rbp-0250h], 0h                                  ; value of this pointer for function call (placeholder)
  mov qword ptr [rbp-0258h], 000000000h                          ; type of this pointer for function call (placeholder)
  mov qword ptr [rbp-0260h], 0h                                  ; value of closure pointer for function call (placeholder)
  push 000000001h                                                ; value of argument #1
  push 000000006h                                                ; type of argument #1
  lea r11, [rbp-0268h]                                           ; pointer to return value (and type, 8 bytes earlier)
  push r11                                                       ; (that pointer is the last value pushed to the stack)
  lea r9, [rbp-0250h]                                            ; pointer to this
  mov r8, [rbp-0258h]                                            ; type of this
  lea rdx, [rbp-0260h]                                           ; pointer to closure
  mov rcx, 1                                                     ; number of arguments
  sub rsp, 20h                                                   ; allocate shadow space
  call offset func$exit                                          ; jump to subroutine
  add rsp, 038h                                                  ; release shadow space and arguments
  func$stringify$epilog:
  mov rax, r15                                                   ; report address of return value
  ; Epilog
  add rsp, 0270h                                                 ; free space for stack
  pop r15                                                        ; restore volatile registers
  pop rbp                                                        ; restore volatile registers
  ret                                                            ; return from subroutine


end

