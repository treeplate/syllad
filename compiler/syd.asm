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
   ; 0 0   IntegerFunction()'5
   ; 1 0   Integer'6
   ; 0 1   String'7

  parameterCountCheckFailureMessage dq -01h                      ; String constant (reference count)
               dq 88                                             ; Length
               db "error: function call received the wrong number of parameters (expected %d, received %d)", 0ah ; line 1328 column 25 in file syd-compiler.syd
  parameterTypeCheckFailureMessage dq -01h                       ; String constant (reference count)
               dq 71                                             ; Length
               db "error: type mismatch for function %s parameter %d, expected %s, got %s", 0ah ; line 1333 column 25 in file syd-compiler.syd
  returnValueTypeCheckFailureMessage dq -01h                     ; String constant (reference count)
               dq 68                                             ; Length
               db "error: type mismatch for function return value, expected %s, got %s", 0ah ; line 1338 column 25 in file syd-compiler.syd
  string       dq -01h                                           ; String constant (reference count)
               dq 5                                              ; Length
               db "FAIL", 0ah                                    ; line 6 column 19 in file temp.syd
  string$2     dq -01h                                           ; String constant (reference count)
               dq 7                                              ; Length
               db "Line 2", 0ah                                  ; line 18 column 14 in file temp.syd
  string$1     dq -01h                                           ; String constant (reference count)
               dq 7                                              ; Length
               db "Line 1", 0ah                                  ; line 11 column 20 in file temp.syd

.data


_BSS segment
  global0Value dq ?                                              ; a
  global0Type dq ?                                               ; dynamic type of a
  global1Value dq ?                                              ; b
  global1Type dq ?                                               ; dynamic type of b
  global2Value dq ?                                              ; c
  global2Type dq ?                                               ; dynamic type of c

.code

public main
main:
  ; rtl
  ; ===
  ; Prolog
  push rbp                                                       ; save volatile registers
  lea rbp, [rsp+000h]                                            ; set up frame pointer
  ; Epilog
  pop rbp                                                        ; restore volatile registers

  ; temp.syd
  ; ========
  ; Prolog
  push rbp                                                       ; save volatile registers
  sub rsp, 078h                                                  ; allocate space for stack
  lea rbp, [rsp+078h]                                            ; set up frame pointer
  ; Line 5: Integer a = 999 /* 0x3e7 */;
  mov qword ptr global0Value, 0000003e7h                         ; value of a
  mov qword ptr global0Type, 000000006h                          ; type of a
  ; Line 6: String b = 'FAIL\n';
  mov r11, offset string                                         ; value of b
  mov global1Value, r11                                          ; (indirect via r11 because string is an imm64)
  mov qword ptr global1Type, 000000007h                          ; type of b
  ; Line 7: Boolean c = false;
  mov qword ptr global2Value, 000000000h                         ; value of c
  mov qword ptr global2Type, 000000002h                          ; type of c
  ; Line 17: a = 3 /* 0x3 */;
  mov qword ptr global0Value, 000000003h                         ; value of a
  mov qword ptr global0Type, 000000006h                          ; type of a
  ; Line 18: b = 'Line 2\n';
  mov r11, offset string$2                                       ; value of b
  mov global1Value, r11                                          ; (indirect via r11 because string$2 is an imm64)
  mov qword ptr global1Type, 000000007h                          ; type of b
  ; Line 19: c = true;
  mov qword ptr global2Value, 000000001h                         ; value of c
  mov qword ptr global2Type, 000000002h                          ; type of c
  ; Line 21: exit(test());
  mov qword ptr [rbp-008h], 0h                                   ; value of this pointer for function call (placeholder)
  mov qword ptr [rbp-010h], 000000000h                           ; type of this pointer for function call (placeholder)
  mov qword ptr [rbp-018h], 0h                                   ; value of closure pointer for function call (placeholder)
  lea r11, [rbp-020h]                                            ; pointer to return value (and type, 8 bytes earlier)
  push r11                                                       ; (that pointer is the last value pushed to the stack)
  lea r9, [rbp-008h]                                             ; pointer to this
  mov r8, [rbp-010h]                                             ; type of this
  lea rdx, [rbp-018h]                                            ; pointer to closure
  mov rcx, 0                                                     ; number of arguments
  sub rsp, 20h                                                   ; allocate shadow space
  call func$test                                                 ; jump to subroutine
  add rsp, 028h                                                  ; release shadow space and arguments
  mov qword ptr [rbp-030h], 0h                                   ; value of this pointer for function call (placeholder)
  mov qword ptr [rbp-038h], 000000000h                           ; type of this pointer for function call (placeholder)
  mov qword ptr [rbp-040h], 0h                                   ; value of closure pointer for function call (placeholder)
  push [rbp-020h]                                                ; value of argument #1
  push [rbp-028h]                                                ; type of argument #1
  lea r11, [rbp-048h]                                            ; pointer to return value (and type, 8 bytes earlier)
  push r11                                                       ; (that pointer is the last value pushed to the stack)
  lea r9, [rbp-030h]                                             ; pointer to this
  mov r8, [rbp-038h]                                             ; type of this
  lea rdx, [rbp-040h]                                            ; pointer to closure
  mov rcx, 1                                                     ; number of arguments
  sub rsp, 20h                                                   ; allocate shadow space
  call func$exit                                                 ; jump to subroutine
  add rsp, 038h                                                  ; release shadow space and arguments
  mov qword ptr [rbp-058h], 0h                                   ; value of this pointer for function call (placeholder)
  mov qword ptr [rbp-060h], 000000000h                           ; type of this pointer for function call (placeholder)
  mov qword ptr [rbp-068h], 0h                                   ; value of closure pointer for function call (placeholder)
  push 000000000h                                                ; value of argument #1
  push 000000006h                                                ; type of argument #1
  lea r11, [rbp-070h]                                            ; pointer to return value (and type, 8 bytes earlier)
  push r11                                                       ; (that pointer is the last value pushed to the stack)
  lea r9, [rbp-058h]                                             ; pointer to this
  mov r8, [rbp-060h]                                             ; type of this
  lea rdx, [rbp-068h]                                            ; pointer to closure
  mov rcx, 1                                                     ; number of arguments
  sub rsp, 20h                                                   ; allocate shadow space
  call func$exit                                                 ; jump to subroutine
  add rsp, 038h                                                  ; release shadow space and arguments
  ; Epilog
  add rsp, 078h                                                  ; free space for stack
  pop rbp                                                        ; restore volatile registers
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
    call func$print                                              ; jump to subroutine
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
    call func$exit                                               ; jump to subroutine
    add rsp, 038h                                                ; release shadow space and arguments
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
    call func$print                                              ; jump to subroutine
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
    call func$exit                                               ; jump to subroutine
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
    call func$print                                              ; jump to subroutine
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
    call func$exit                                               ; jump to subroutine
    add rsp, 038h                                                ; release shadow space and arguments
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
    call func$print                                              ; jump to subroutine
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
    call func$exit                                               ; jump to subroutine
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

; test
func$test:
  ; Prolog
  push rbp                                                       ; save volatile registers
  push r15                                                       ; save volatile registers
  sub rsp, 0f0h                                                  ; allocate space for stack
  lea rbp, [rsp+0f0h]                                            ; set up frame pointer
  mov r15, [rbp+038h]                                            ; prepare return value
  ; Check parameter count
  cmp qword ptr rcx, 000000000h                                  ; check number of parameters is as expected
  je func$test$parameterCount$continuation                       ; jump if they are equal
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
    call func$print                                              ; jump to subroutine
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
    call func$exit                                               ; jump to subroutine
    add rsp, 038h                                                ; release shadow space and arguments
  func$test$parameterCount$continuation:                         ; end of parameter count
  ; Line 10: if (c) { ...
  cmp qword ptr global2Value, 000000000h                         ; c
  je func$test$if$continuation                                   ; jump if they are equal
    ; Line 11: print('Line 1\n');
    mov qword ptr [rbp-058h], 0h                                 ; value of this pointer for function call (placeholder)
    mov qword ptr [rbp-060h], 000000000h                         ; type of this pointer for function call (placeholder)
    mov qword ptr [rbp-068h], 0h                                 ; value of closure pointer for function call (placeholder)
    mov r11, offset string$1                                     ; value of argument #1
    push r11                                                     ; (indirect via r11 because "string$1" is an imm64)
    push 000000007h                                              ; type of argument #1
    lea r11, [rbp-070h]                                          ; pointer to return value (and type, 8 bytes earlier)
    push r11                                                     ; (that pointer is the last value pushed to the stack)
    lea r9, [rbp-058h]                                           ; pointer to this
    mov r8, [rbp-060h]                                           ; type of this
    lea rdx, [rbp-068h]                                          ; pointer to closure
    mov rcx, 1                                                   ; number of arguments
    sub rsp, 20h                                                 ; allocate shadow space
    call func$print                                              ; jump to subroutine
    add rsp, 038h                                                ; release shadow space and arguments
  func$test$if$continuation:                                     ; end of if
  ; Line 13: print(b);
  mov qword ptr [rbp-080h], 0h                                   ; value of this pointer for function call (placeholder)
  mov qword ptr [rbp-088h], 000000000h                           ; type of this pointer for function call (placeholder)
  mov qword ptr [rbp-090h], 0h                                   ; value of closure pointer for function call (placeholder)
  push global1Value                                              ; value of argument #1
  push global1Type                                               ; type of argument #1
  lea r11, [rbp-098h]                                            ; pointer to return value (and type, 8 bytes earlier)
  push r11                                                       ; (that pointer is the last value pushed to the stack)
  lea r9, [rbp-080h]                                             ; pointer to this
  mov r8, [rbp-088h]                                             ; type of this
  lea rdx, [rbp-090h]                                            ; pointer to closure
  mov rcx, 1                                                     ; number of arguments
  sub rsp, 20h                                                   ; allocate shadow space
  call func$print                                                ; jump to subroutine
  add rsp, 038h                                                  ; release shadow space and arguments
  ; Line 14: return a;
  mov rax, global0Type                                           ; load the dynamic type of return value of test into rax
  lea r10, typeTable                                             ; move type table offset into r10
  add rax, r10                                                   ; adjust rax to point to the type table
  bt qword ptr [rax], 0                                          ; check that return value of test is Integer'6
  jc func$test$returnValueOfTest$TypeMatch                       ; skip next block if the type matches
    ; Error handling block for return value of test
    ;  - print(returnValueTypeCheckFailureMessage)
    mov qword ptr [rbp-0a8h], 0h                                 ; value of this pointer for function call (placeholder)
    mov qword ptr [rbp-0b0h], 000000000h                         ; type of this pointer for function call (placeholder)
    mov qword ptr [rbp-0b8h], 0h                                 ; value of closure pointer for function call (placeholder)
    mov r11, offset returnValueTypeCheckFailureMessage           ; value of argument #1
    push r11                                                     ; (indirect via r11 because "returnValueTypeCheckFailureMessage" is an imm64)
    push 000000007h                                              ; type of argument #1
    lea r11, [rbp-0c0h]                                          ; pointer to return value (and type, 8 bytes earlier)
    push r11                                                     ; (that pointer is the last value pushed to the stack)
    lea r9, [rbp-0a8h]                                           ; pointer to this
    mov r8, [rbp-0b0h]                                           ; type of this
    lea rdx, [rbp-0b8h]                                          ; pointer to closure
    mov rcx, 1                                                   ; number of arguments
    sub rsp, 20h                                                 ; allocate shadow space
    call func$print                                              ; jump to subroutine
    add rsp, 038h                                                ; release shadow space and arguments
    ;  - exit(1)
    mov qword ptr [rbp-0d0h], 0h                                 ; value of this pointer for function call (placeholder)
    mov qword ptr [rbp-0d8h], 000000000h                         ; type of this pointer for function call (placeholder)
    mov qword ptr [rbp-0e0h], 0h                                 ; value of closure pointer for function call (placeholder)
    push 000000001h                                              ; value of argument #1
    push 000000006h                                              ; type of argument #1
    lea r11, [rbp-0e8h]                                          ; pointer to return value (and type, 8 bytes earlier)
    push r11                                                     ; (that pointer is the last value pushed to the stack)
    lea r9, [rbp-0d0h]                                           ; pointer to this
    mov r8, [rbp-0d8h]                                           ; type of this
    lea rdx, [rbp-0e0h]                                          ; pointer to closure
    mov rcx, 1                                                   ; number of arguments
    sub rsp, 20h                                                 ; allocate shadow space
    call func$exit                                               ; jump to subroutine
    add rsp, 038h                                                ; release shadow space and arguments
  func$test$returnValueOfTest$TypeMatch:
  mov r11, global0Value                                          ; value of return value
  mov [r15], r11                                                 ; (indirect via r11 because mov can't do memory-to-memory)
  mov r11, global0Type                                           ; type of return value
  mov [r15-08h], r11                                             ; (indirect via r11 because mov can't do memory-to-memory)
  jmp func$test$epilog                                           ; return
  func$test$epilog:
  mov rax, r15                                                   ; report address of return value
  ; Epilog
  add rsp, 0f0h                                                  ; free space for stack
  pop r15                                                        ; restore volatile registers
  pop rbp                                                        ; restore volatile registers
  ret                                                            ; return from subroutine


end

