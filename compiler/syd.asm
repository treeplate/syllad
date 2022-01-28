_drectve segment info alias(".drectve")
  db ' /ENTRY:main '
_drectve ends
option casemap:none

; includes
includelib kernel32.lib

; externs
extern GetStdHandle : proc
extern WriteConsoleA : proc

.data
  string       dq -01h                                             ; <Object@0>
               dq 7
               db "Hello", 0dh, 0ah
  string$1     dq -01h                                             ; <Object@1>
               dq 7
               db "World", 0dh, 0ah
  string$2     dq -01h                                             ; <Object@2>
               dq 14
               db "How are you?", 0dh, 0ah

.code

public main
main:
  ; rtl
  ; Prolog
  push rbp                                                         ; save volatile registers
  mov rbp, rsp                                                     ; set up frame pointer
  ; Epilog
  pop rbp                                                          ; restore volatile registers
  ; temp.syd
  ; Prolog
  push rbp                                                         ; save volatile registers
  sub rsp, 0c0h                                                    ; allocate space for stack
  mov rbp, rsp                                                     ; set up frame pointer
  mov dword ptr [rbp+010h], 0h                                     ; value of this pointer
  mov dword ptr [rbp+018h], 000000001h                             ; type of this pointer
  mov dword ptr [rbp+020h], 0h                                     ; value of closure pointer
  mov dword ptr [rbp+028h], 000000002h                             ; type of closure pointer
  ; Calling println with 1 arguments
  mov r11, offset string                                           ; value of argument #1
  push r11                                                         ; (indirect via r11 because "offset string" cannot be used with push)
  push 000000007h                                                  ; type of argument #1
  lea r11, [rbp+030h]                                              ; pointer to return value (and type, 8 bytes later)
  push r11                                                         ; (that pointer is the last value pushed to the stack)
  lea r9, [rbp+010h]                                               ; pointer to this
  mov r8, [rbp+018h]                                               ; type of this
  lea rdx, [rbp+020h]                                              ; pointer to closure
  mov rcx, 1                                                       ; number of arguments
  sub rsp, 20h                                                     ; allocate shadow space
  call println                                                     ; jump to subroutine
  add rsp, 038h                                                    ; release shadow space and arguments
  mov dword ptr [rbp+040h], 0h                                     ; value of this pointer
  mov dword ptr [rbp+048h], 000000001h                             ; type of this pointer
  mov dword ptr [rbp+050h], 0h                                     ; value of closure pointer
  mov dword ptr [rbp+058h], 000000002h                             ; type of closure pointer
  ; Calling println with 1 arguments
  mov r11, offset string$1                                         ; value of argument #1
  push r11                                                         ; (indirect via r11 because "offset string$1" cannot be used with push)
  push 000000007h                                                  ; type of argument #1
  lea r11, [rbp+060h]                                              ; pointer to return value (and type, 8 bytes later)
  push r11                                                         ; (that pointer is the last value pushed to the stack)
  lea r9, [rbp+040h]                                               ; pointer to this
  mov r8, [rbp+048h]                                               ; type of this
  lea rdx, [rbp+050h]                                              ; pointer to closure
  mov rcx, 1                                                       ; number of arguments
  sub rsp, 20h                                                     ; allocate shadow space
  call println                                                     ; jump to subroutine
  add rsp, 038h                                                    ; release shadow space and arguments
  mov dword ptr [rbp+070h], 0h                                     ; value of this pointer
  mov dword ptr [rbp+078h], 000000001h                             ; type of this pointer
  mov dword ptr [rbp+080h], 0h                                     ; value of closure pointer
  mov dword ptr [rbp+088h], 000000002h                             ; type of closure pointer
  ; Calling println with 1 arguments
  mov r11, offset string$2                                         ; value of argument #1
  push r11                                                         ; (indirect via r11 because "offset string$2" cannot be used with push)
  push 000000007h                                                  ; type of argument #1
  lea r11, [rbp+090h]                                              ; pointer to return value (and type, 8 bytes later)
  push r11                                                         ; (that pointer is the last value pushed to the stack)
  lea r9, [rbp+070h]                                               ; pointer to this
  mov r8, [rbp+078h]                                               ; type of this
  lea rdx, [rbp+080h]                                              ; pointer to closure
  mov rcx, 1                                                       ; number of arguments
  sub rsp, 20h                                                     ; allocate shadow space
  call println                                                     ; jump to subroutine
  add rsp, 038h                                                    ; release shadow space and arguments
  mov dword ptr [rbp+0a0h], 0h                                     ; value of this pointer
  mov dword ptr [rbp+0a8h], 000000001h                             ; type of this pointer
  mov dword ptr [rbp+0b0h], 0h                                     ; value of closure pointer
  mov dword ptr [rbp+0b8h], 000000002h                             ; type of closure pointer
  ; Calling println with 1 arguments
  push 000000003h                                                  ; value of argument #1
  push 000000006h                                                  ; type of argument #1
  lea r11, [rbp+0c0h]                                              ; pointer to return value (and type, 8 bytes later)
  push r11                                                         ; (that pointer is the last value pushed to the stack)
  lea r9, [rbp+0a0h]                                               ; pointer to this
  mov r8, [rbp+0a8h]                                               ; type of this
  lea rdx, [rbp+0b0h]                                              ; pointer to closure
  mov rcx, 1                                                       ; number of arguments
  sub rsp, 20h                                                     ; allocate shadow space
  call println                                                     ; jump to subroutine
  add rsp, 038h                                                    ; release shadow space and arguments
  ; Epilog
  add rsp, 0c0h                                                    ; free space for stack
  pop rbp                                                          ; restore volatile registers

println:
  ; Prolog
  push rbp                                                         ; save volatile register
  sub rsp, 08h                                                     ; space for lpNumberOfCharsWritten, out param of WriteConsoleA
  mov rbp, rsp                                                     ; set up frame pointer
  ; Calling GetStdHandle
  mov rcx, -11                                                     ; argument #1: STD_OUTPUT_HANDLE
  call GetStdHandle                                                ; handle returned in rax
  ; Calling WriteConsoleA
  push 0                                                           ; argument #5: Reserved, must be NULL (lpReserved)
  lea r9, [rbp]                                                    ; argument #4: Number of characters written (lpNumberOfCharsWritten)
  mov r10, [rbp+48h]                                               ; get address of string structure
  mov r8, [r10+08h]                                                ; argument #3: Length of buffer (nNumberOfCharsToWrite), from string structure
  lea rdx, [r10+10h]                                               ; argument #2: Pointer to buffer to write (*lpBuffer)
  mov rcx, rax                                                     ; argument #1: Handle from GetStdHandle (hConsoleOutput)
  sub rsp, 20h                                                     ; allocate shadow space
  call WriteConsoleA                                               ; returns boolean representing success in rax
  ; Epilog
  add rsp, 30h                                                     ; release shadow space, arguments, and local variables
  pop rbp                                                          ; restore volatile registers
  ret                                                              ; return from subroutine


end

