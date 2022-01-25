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
               dq 13
               db "Hello World", 0dh, 0ah

.code

public main
main:
  ; rtl
  mov rbp, rsp                                                     ; set up frame pointer
  ; temp.syd
  mov rbp, rsp                                                     ; set up frame pointer
  sub rsp, 30h                                                     ; allocate space for stack
  mov dword ptr [rsp+08h], 00000001h                               ; type of this pointer
  mov dword ptr [rsp+10h], 0h                                      ; value of this pointer
  mov dword ptr [rsp+18h], 00000002h                               ; type of closure pointer
  mov dword ptr [rsp+20h], 0h                                      ; value of closure pointer
  ; Calling println with 1 arguments
  push 00000007h                                                   ; type of argument #1
  push string                                                      ; value of argument #1
  lea r11, [rsp+30h]                                               ; pointer to return value
  push r11                                                         ; (that pointer is the last value pushed to the stack)
  lea r9, [rsp+10h]                                                ; pointer to this
  mov r8, [rsp+08h]                                                ; type of this
  lea rdx, [rsp+20h]                                               ; pointer to closure
  mov rcx, 1                                                       ; number of arguments
  sub rsp, 32                                                      ; allocate shadow space
  call println                                                     ; jump to subroutine
  add rsp, 56                                                      ; release shadow space and arguments
  add rsp, 30h                                                     ; free space for stack

println:
  int 3                                                            ; break into debugger
  ; Local variables
  sub rsp, 8                                                       ; space for lpNumberOfCharsWritten, out param of WriteConsoleA
  ; Calling GetStdHandle
  mov rcx, -11                                                     ; argument #1: STD_OUTPUT_HANDLE
  call GetStdHandle                                                ; handle returned in rax
  ; Calling WriteConsoleA
  push 0                                                           ; argument #5: Reserved, must be NULL (lpReserved)
  lea r9, [rbp]                                                    ; argument #4: Number of characters written (lpNumberOfCharsWritten)
  mov r10, [rsp-38h]                                               ; get address of string structure
  mov r8, [r10+08h]                                                ; argument #3: Length of buffer (nNumberOfCharsToWrite), from string structure
  lea rdx, [r10+10h]                                               ; argument #2: Pointer to buffer to write (*lpBuffer)
  mov rcx, rax                                                     ; argument #1: Handle from GetStdHandle (hConsoleOutput)
  sub rsp, 32                                                      ; allocate shadow space
  call WriteConsoleA                                               ; returns boolean representing success in rax
  add rsp, 40                                                      ; release shadow space and arguments
  ret                                                              ; return from subroutine


end

