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

.data
  typeTable    db 000h, 000h, 000h, 000h, 000h, 000h, 000h, 001h, 002h ; Type table
   ; Columns: Integer'7 String'8
   ; 0 0   <object>'0
   ; 0 0   <closure>'1
   ; 0 0   Null'2
   ; 0 0   Boolean'3
   ; 0 0   NullFunction(Anything...)'4
   ; 0 0   NullFunction(Integer)'5
   ; 0 0   IntegerFunction()'6
   ; 1 0   Integer'7
   ; 0 1   String'8

  parameterCountCheckFailureMessage dq -01h                        ; String constant (reference count)
               dq 88                                               ; Length
               db "error: function call received the wrong number of parameters (expected %d, received %d)", 0ah ; line 1215 column 25 in file syd-compiler.syd
  parameterTypeCheckFailureMessage dq -01h                         ; String constant (reference count)
               dq 71                                               ; Length
               db "error: type mismatch for function %s parameter %d, expected %s, got %s", 0ah ; line 1220 column 25 in file syd-compiler.syd

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
  sub rsp, 078h                                                    ; allocate space for stack
  lea rbp, [rsp+078h]                                              ; set up frame pointer
  ; Line 1: Integer three() { ...
  ; Line 5: exit(three());
  mov qword ptr [rbp-008h], 0h                                     ; value of this pointer
  mov qword ptr [rbp-010h], 000000000h                             ; type of this pointer
  mov qword ptr [rbp-018h], 0h                                     ; value of closure pointer
  ; Calling func$three with 0 arguments
  lea r11, [rbp-020h]                                              ; pointer to return value (and type, 8 bytes earlier)
  push r11                                                         ; (that pointer is the last value pushed to the stack)
  lea r9, [rbp-008h]                                               ; pointer to this
  mov r8, [rbp-010h]                                               ; type of this
  lea rdx, [rbp-018h]                                              ; pointer to closure
  mov rcx, 0                                                       ; number of arguments
  sub rsp, 20h                                                     ; allocate shadow space
  call func$three                                                  ; jump to subroutine
  add rsp, 028h                                                    ; release shadow space and arguments
  mov qword ptr [rbp-030h], 0h                                     ; value of this pointer
  mov qword ptr [rbp-038h], 000000000h                             ; type of this pointer
  mov qword ptr [rbp-040h], 0h                                     ; value of closure pointer
  ; Calling func$exit with 1 arguments
  push [rbp-020h]                                                  ; value of argument #1
  push [rbp-028h]                                                  ; type of argument #1
  lea r11, [rbp-048h]                                              ; pointer to return value (and type, 8 bytes earlier)
  push r11                                                         ; (that pointer is the last value pushed to the stack)
  lea r9, [rbp-030h]                                               ; pointer to this
  mov r8, [rbp-038h]                                               ; type of this
  lea rdx, [rbp-040h]                                              ; pointer to closure
  mov rcx, 1                                                       ; number of arguments
  sub rsp, 20h                                                     ; allocate shadow space
  call func$exit                                                   ; jump to subroutine
  add rsp, 038h                                                    ; release shadow space and arguments
  mov qword ptr [rbp-058h], 0h                                     ; value of this pointer
  mov qword ptr [rbp-060h], 000000000h                             ; type of this pointer
  mov qword ptr [rbp-068h], 0h                                     ; value of closure pointer
  ; Calling func$exit with 1 arguments
  push 000000000h                                                  ; value of argument #1
  push 000000007h                                                  ; type of argument #1
  lea r11, [rbp-070h]                                              ; pointer to return value (and type, 8 bytes earlier)
  push r11                                                         ; (that pointer is the last value pushed to the stack)
  lea r9, [rbp-058h]                                               ; pointer to this
  mov r8, [rbp-060h]                                               ; type of this
  lea rdx, [rbp-068h]                                              ; pointer to closure
  mov rcx, 1                                                       ; number of arguments
  sub rsp, 20h                                                     ; allocate shadow space
  call func$exit                                                   ; jump to subroutine
  add rsp, 038h                                                    ; release shadow space and arguments
  ; Epilog
  add rsp, 078h                                                    ; free space for stack
  pop rbp                                                          ; restore volatile registers
  ret                                                              ; exit application

; print
func$print:
  ; Prolog
  push rbp                                                         ; save volatile registers
  push r15                                                         ; save volatile registers
  sub rsp, 0a8h                                                    ; allocate space for stack
  lea rbp, [rsp+0a8h]                                              ; set up frame pointer
  mov r15, [rbp+038h]                                              ; prepare return value
  ; Check parameter count
  cmp rcx, 000000001h                                              ; check number of parameters is as expected
  je func$print$paramCountGood                                     ; skip next block if they are equal
    mov qword ptr [rbp-010h], 0h                                   ; value of this pointer
    mov qword ptr [rbp-018h], 000000000h                           ; type of this pointer
    mov qword ptr [rbp-020h], 0h                                   ; value of closure pointer
    ; Calling func$print with 1 arguments
    mov r11, offset parameterCountCheckFailureMessage              ; value of argument #1
    push r11                                                       ; (indirect via r11 because "offset parameterCountCheckFailureMessage" cannot be used with push)
    push 000000008h                                                ; type of argument #1
    lea r11, [rbp-028h]                                            ; pointer to return value (and type, 8 bytes earlier)
    push r11                                                       ; (that pointer is the last value pushed to the stack)
    lea r9, [rbp-010h]                                             ; pointer to this
    mov r8, [rbp-018h]                                             ; type of this
    lea rdx, [rbp-020h]                                            ; pointer to closure
    mov rcx, 1                                                     ; number of arguments
    sub rsp, 20h                                                   ; allocate shadow space
    call func$print                                                ; jump to subroutine
    add rsp, 038h                                                  ; release shadow space and arguments
    mov qword ptr [rbp-038h], 0h                                   ; value of this pointer
    mov qword ptr [rbp-040h], 000000000h                           ; type of this pointer
    mov qword ptr [rbp-048h], 0h                                   ; value of closure pointer
    ; Calling func$exit with 1 arguments
    push 000000001h                                                ; value of argument #1
    push 000000007h                                                ; type of argument #1
    lea r11, [rbp-050h]                                            ; pointer to return value (and type, 8 bytes earlier)
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
  mov rax, [rbp+040h]                                              ; load the dynamic type of message to print to console into rax
  lea r10, typeTable                                               ; move type table offset into r10
  add rax, r10                                                     ; adjust rax to point to the type table
  bt qword ptr [rax], 1                                            ; check that message to print to console is String'8
  jc func$print$param1$TypeGood                                    ; skip next block if the type matches
    mov qword ptr [rbp-060h], 0h                                   ; value of this pointer
    mov qword ptr [rbp-068h], 000000000h                           ; type of this pointer
    mov qword ptr [rbp-070h], 0h                                   ; value of closure pointer
    ; Calling func$print with 1 arguments
    mov r11, offset parameterTypeCheckFailureMessage               ; value of argument #1
    push r11                                                       ; (indirect via r11 because "offset parameterTypeCheckFailureMessage" cannot be used with push)
    push 000000008h                                                ; type of argument #1
    lea r11, [rbp-078h]                                            ; pointer to return value (and type, 8 bytes earlier)
    push r11                                                       ; (that pointer is the last value pushed to the stack)
    lea r9, [rbp-060h]                                             ; pointer to this
    mov r8, [rbp-068h]                                             ; type of this
    lea rdx, [rbp-070h]                                            ; pointer to closure
    mov rcx, 1                                                     ; number of arguments
    sub rsp, 20h                                                   ; allocate shadow space
    call func$print                                                ; jump to subroutine
    add rsp, 038h                                                  ; release shadow space and arguments
    mov qword ptr [rbp-088h], 0h                                   ; value of this pointer
    mov qword ptr [rbp-090h], 000000000h                           ; type of this pointer
    mov qword ptr [rbp-098h], 0h                                   ; value of closure pointer
    ; Calling func$exit with 1 arguments
    push 000000001h                                                ; value of argument #1
    push 000000007h                                                ; type of argument #1
    lea r11, [rbp-0a0h]                                            ; pointer to return value (and type, 8 bytes earlier)
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
  mov r10, [rbp+048h]                                              ; get address of string structure
  mov r8, [r10+08h]                                                ; argument #3: Length of buffer (nNumberOfCharsToWrite), from string structure
  lea rdx, [r10+10h]                                               ; argument #2: Pointer to buffer to write (*lpBuffer)
  mov rcx, rax                                                     ; argument #1: Handle from GetStdHandle (hConsoleOutput)
  sub rsp, 20h                                                     ; allocate shadow space
  call WriteConsoleA                                               ; returns boolean representing success in rax
  add rsp, 28h                                                     ; release shadow space and arguments
  func$print$epilog:
  mov rax, r15                                                     ; report address of return value
  ; Epilog
  add rsp, 0a8h                                                    ; free space for stack
  pop r15                                                          ; restore volatile registers
  pop rbp                                                          ; restore volatile registers
  ret                                                              ; return from subroutine

; exit
func$exit:
  ; Prolog
  push rbp                                                         ; save volatile registers
  push r15                                                         ; save volatile registers
  sub rsp, 0a0h                                                    ; allocate space for stack
  lea rbp, [rsp+0a0h]                                              ; set up frame pointer
  mov r15, [rbp+038h]                                              ; prepare return value
  ; Check parameter count
  cmp rcx, 000000001h                                              ; check number of parameters is as expected
  je func$exit$paramCountGood                                      ; skip next block if they are equal
    mov qword ptr [rbp-008h], 0h                                   ; value of this pointer
    mov qword ptr [rbp-010h], 000000000h                           ; type of this pointer
    mov qword ptr [rbp-018h], 0h                                   ; value of closure pointer
    ; Calling func$print with 1 arguments
    mov r11, offset parameterCountCheckFailureMessage              ; value of argument #1
    push r11                                                       ; (indirect via r11 because "offset parameterCountCheckFailureMessage" cannot be used with push)
    push 000000008h                                                ; type of argument #1
    lea r11, [rbp-020h]                                            ; pointer to return value (and type, 8 bytes earlier)
    push r11                                                       ; (that pointer is the last value pushed to the stack)
    lea r9, [rbp-008h]                                             ; pointer to this
    mov r8, [rbp-010h]                                             ; type of this
    lea rdx, [rbp-018h]                                            ; pointer to closure
    mov rcx, 1                                                     ; number of arguments
    sub rsp, 20h                                                   ; allocate shadow space
    call func$print                                                ; jump to subroutine
    add rsp, 038h                                                  ; release shadow space and arguments
    mov qword ptr [rbp-030h], 0h                                   ; value of this pointer
    mov qword ptr [rbp-038h], 000000000h                           ; type of this pointer
    mov qword ptr [rbp-040h], 0h                                   ; value of closure pointer
    ; Calling func$exit with 1 arguments
    push 000000001h                                                ; value of argument #1
    push 000000007h                                                ; type of argument #1
    lea r11, [rbp-048h]                                            ; pointer to return value (and type, 8 bytes earlier)
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
  mov rax, [rbp+040h]                                              ; load the dynamic type of exit code parameter into rax
  lea r10, typeTable                                               ; move type table offset into r10
  add rax, r10                                                     ; adjust rax to point to the type table
  bt qword ptr [rax], 0                                            ; check that exit code parameter is Integer'7
  jc func$exit$param1$TypeGood                                     ; skip next block if the type matches
    mov qword ptr [rbp-058h], 0h                                   ; value of this pointer
    mov qword ptr [rbp-060h], 000000000h                           ; type of this pointer
    mov qword ptr [rbp-068h], 0h                                   ; value of closure pointer
    ; Calling func$print with 1 arguments
    mov r11, offset parameterTypeCheckFailureMessage               ; value of argument #1
    push r11                                                       ; (indirect via r11 because "offset parameterTypeCheckFailureMessage" cannot be used with push)
    push 000000008h                                                ; type of argument #1
    lea r11, [rbp-070h]                                            ; pointer to return value (and type, 8 bytes earlier)
    push r11                                                       ; (that pointer is the last value pushed to the stack)
    lea r9, [rbp-058h]                                             ; pointer to this
    mov r8, [rbp-060h]                                             ; type of this
    lea rdx, [rbp-068h]                                            ; pointer to closure
    mov rcx, 1                                                     ; number of arguments
    sub rsp, 20h                                                   ; allocate shadow space
    call func$print                                                ; jump to subroutine
    add rsp, 038h                                                  ; release shadow space and arguments
    mov qword ptr [rbp-080h], 0h                                   ; value of this pointer
    mov qword ptr [rbp-088h], 000000000h                           ; type of this pointer
    mov qword ptr [rbp-090h], 0h                                   ; value of closure pointer
    ; Calling func$exit with 1 arguments
    push 000000001h                                                ; value of argument #1
    push 000000007h                                                ; type of argument #1
    lea r11, [rbp-098h]                                            ; pointer to return value (and type, 8 bytes earlier)
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
  mov rcx, [rbp+048h]                                              ; exit code
  sub rsp, 20h                                                     ; allocate shadow space
  call ExitProcess                                                 ; process should terminate at this point
  add rsp, 20h                                                     ; release shadow space
  func$exit$epilog:
  mov rax, r15                                                     ; report address of return value
  ; Epilog
  add rsp, 0a0h                                                    ; free space for stack
  pop r15                                                          ; restore volatile registers
  pop rbp                                                          ; restore volatile registers
  ret                                                              ; return from subroutine

; three
func$three:
  ; Prolog
  push rbp                                                         ; save volatile registers
  push r15                                                         ; save volatile registers
  sub rsp, 050h                                                    ; allocate space for stack
  lea rbp, [rsp+050h]                                              ; set up frame pointer
  mov r15, [rbp+038h]                                              ; prepare return value
  ; Check parameter count
  cmp rcx, 000000000h                                              ; check number of parameters is as expected
  je func$three$paramCountGood                                     ; skip next block if they are equal
    mov qword ptr [rbp-008h], 0h                                   ; value of this pointer
    mov qword ptr [rbp-010h], 000000000h                           ; type of this pointer
    mov qword ptr [rbp-018h], 0h                                   ; value of closure pointer
    ; Calling func$print with 1 arguments
    mov r11, offset parameterCountCheckFailureMessage              ; value of argument #1
    push r11                                                       ; (indirect via r11 because "offset parameterCountCheckFailureMessage" cannot be used with push)
    push 000000008h                                                ; type of argument #1
    lea r11, [rbp-020h]                                            ; pointer to return value (and type, 8 bytes earlier)
    push r11                                                       ; (that pointer is the last value pushed to the stack)
    lea r9, [rbp-008h]                                             ; pointer to this
    mov r8, [rbp-010h]                                             ; type of this
    lea rdx, [rbp-018h]                                            ; pointer to closure
    mov rcx, 1                                                     ; number of arguments
    sub rsp, 20h                                                   ; allocate shadow space
    call func$print                                                ; jump to subroutine
    add rsp, 038h                                                  ; release shadow space and arguments
    mov qword ptr [rbp-030h], 0h                                   ; value of this pointer
    mov qword ptr [rbp-038h], 000000000h                           ; type of this pointer
    mov qword ptr [rbp-040h], 0h                                   ; value of closure pointer
    ; Calling func$exit with 1 arguments
    push 000000001h                                                ; value of argument #1
    push 000000007h                                                ; type of argument #1
    lea r11, [rbp-048h]                                            ; pointer to return value (and type, 8 bytes earlier)
    push r11                                                       ; (that pointer is the last value pushed to the stack)
    lea r9, [rbp-030h]                                             ; pointer to this
    mov r8, [rbp-038h]                                             ; type of this
    lea rdx, [rbp-040h]                                            ; pointer to closure
    mov rcx, 1                                                     ; number of arguments
    sub rsp, 20h                                                   ; allocate shadow space
    call func$exit                                                 ; jump to subroutine
    add rsp, 038h                                                  ; release shadow space and arguments
  func$three$paramCountGood:
  ; Line 2: return 3 /* 0x3 */;
  mov qword ptr [r15], 000000003h                                  ; value of return value
  mov qword ptr [r15-08h], 000000007h                              ; type of return value
  jmp func$three$epilog                                            ; return
  func$three$epilog:
  mov rax, r15                                                     ; report address of return value
  ; Epilog
  add rsp, 050h                                                    ; free space for stack
  pop r15                                                          ; restore volatile registers
  pop rbp                                                          ; restore volatile registers
  ret                                                              ; return from subroutine


end

