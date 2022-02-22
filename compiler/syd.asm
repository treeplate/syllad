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
  typeTable    db 003h, 000h, 000h, 000h, 000h, 001h, 002h       ; Type table
   ; Columns: Integer'5 String'6
   ; 1 1   <sentinel>'0
   ; 0 0   Null'1
   ; 0 0   Boolean'2
   ; 0 0   NullFunction(String)'3
   ; 0 0   NullFunction(Integer)'4
   ; 1 0   Integer'5
   ; 0 1   String'6

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
               dq 6                                              ; Length
               db "Hello", 0ah                                   ; line 1 column 15 in file temp.syd

.data


_BSS segment


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
  ; Line 1: print('Hello\n');
  mov qword ptr [rbp-008h], 0h                                   ; value of this pointer for function call (placeholder)
  mov qword ptr [rbp-010h], 000000000h                           ; type of this pointer for function call (placeholder)
  mov qword ptr [rbp-018h], 0h                                   ; value of closure pointer for function call (placeholder)
  mov r11, offset string                                         ; value of argument #1
  push r11                                                       ; (indirect via r11 because "string" is an imm64)
  push 000000006h                                                ; type of argument #1
  lea r11, [rbp-020h]                                            ; pointer to return value (and type, 8 bytes earlier)
  push r11                                                       ; (that pointer is the last value pushed to the stack)
  lea r9, [rbp-008h]                                             ; pointer to this
  mov r8, [rbp-010h]                                             ; type of this
  lea rdx, [rbp-018h]                                            ; pointer to closure
  mov rcx, 1                                                     ; number of arguments
  sub rsp, 20h                                                   ; allocate shadow space
  call func$print                                                ; jump to subroutine
  add rsp, 038h                                                  ; release shadow space and arguments
  ; Line 2: print(exit);
  mov qword ptr [rbp-030h], 0h                                   ; value of this pointer for function call (placeholder)
  mov qword ptr [rbp-038h], 000000000h                           ; type of this pointer for function call (placeholder)
  mov qword ptr [rbp-040h], 0h                                   ; value of closure pointer for function call (placeholder)
  mov r11, offset func$exit                                      ; value of argument #1
  push r11                                                       ; (indirect via r11 because "func$exit" is an imm64)
  push 000000004h                                                ; type of argument #1
  lea r11, [rbp-048h]                                            ; pointer to return value (and type, 8 bytes earlier)
  push r11                                                       ; (that pointer is the last value pushed to the stack)
  lea r9, [rbp-030h]                                             ; pointer to this
  mov r8, [rbp-038h]                                             ; type of this
  lea rdx, [rbp-040h]                                            ; pointer to closure
  mov rcx, 1                                                     ; number of arguments
  sub rsp, 20h                                                   ; allocate shadow space
  call func$print                                                ; jump to subroutine
  add rsp, 038h                                                  ; release shadow space and arguments
  mov qword ptr [rbp-058h], 0h                                   ; value of this pointer for function call (placeholder)
  mov qword ptr [rbp-060h], 000000000h                           ; type of this pointer for function call (placeholder)
  mov qword ptr [rbp-068h], 0h                                   ; value of closure pointer for function call (placeholder)
  push 000000000h                                                ; value of argument #1
  push 000000005h                                                ; type of argument #1
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
    push 000000006h                                              ; type of argument #1
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
    push 000000005h                                              ; type of argument #1
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
  bt qword ptr [rax], 1                                          ; check that message to print to console is String'6
  jc func$print$messageToPrintToConsole$TypeMatch                ; skip next block if the type matches
    ; Error handling block for message to print to console
    ;  - print(parameterTypeCheckFailureMessage)
    mov qword ptr [rbp-060h], 0h                                 ; value of this pointer for function call (placeholder)
    mov qword ptr [rbp-068h], 000000000h                         ; type of this pointer for function call (placeholder)
    mov qword ptr [rbp-070h], 0h                                 ; value of closure pointer for function call (placeholder)
    mov r11, offset parameterTypeCheckFailureMessage             ; value of argument #1
    push r11                                                     ; (indirect via r11 because "parameterTypeCheckFailureMessage" is an imm64)
    push 000000006h                                              ; type of argument #1
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
    push 000000005h                                              ; type of argument #1
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
    push 000000006h                                              ; type of argument #1
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
    push 000000005h                                              ; type of argument #1
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
  bt qword ptr [rax], 0                                          ; check that exit code parameter is Integer'5
  jc func$exit$exitCodeParameter$TypeMatch                       ; skip next block if the type matches
    ; Error handling block for exit code parameter
    ;  - print(parameterTypeCheckFailureMessage)
    mov qword ptr [rbp-058h], 0h                                 ; value of this pointer for function call (placeholder)
    mov qword ptr [rbp-060h], 000000000h                         ; type of this pointer for function call (placeholder)
    mov qword ptr [rbp-068h], 0h                                 ; value of closure pointer for function call (placeholder)
    mov r11, offset parameterTypeCheckFailureMessage             ; value of argument #1
    push r11                                                     ; (indirect via r11 because "parameterTypeCheckFailureMessage" is an imm64)
    push 000000006h                                              ; type of argument #1
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
    push 000000005h                                              ; type of argument #1
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


end

