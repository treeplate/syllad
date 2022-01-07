; to build:
; CALL "C:\Program Files\Microsoft Visual Studio\2022\Community\VC\Auxiliary\Build\vcvars64.bat"
; ML64 test.asm
; test

_DRECTVE SEGMENT INFO ALIAS(".drectve")
    db ' /ENTRY:main '
_DRECTVE ENDS

option casemap:none

includelib kernel32.lib
includelib user32.lib

extern MessageBoxA : proc
extern GetStdHandle : proc
extern WriteConsoleA : proc
extern ExitProcess : proc

.data

text       db 'Hello world!', 0
caption    db 'Hello x86-64', 0
msg        db 'BOOM. Not boom. Actually worked.', 0Dh, 0Ah, 0
msg_length dq $ - msg

.code

public main
main:
   ; Setup frame pointer
   mov rbp, rsp

   ; Local variables
   sub rsp, 8          ; space for lpNumberOfCharsWritten, out param of WriteConsoleA

   ; Calling GetStdHandle
   mov rcx, -11        ; argument 1: STD_OUTPUT_HANDLE
   call GetStdHandle   ; Handle returned in rax

   ; Calling WriteConsoleA
   push 0              ; argument 5: Reserved, must be NULL (lpReserved)
   lea r9, [rbp - 0]   ; argument 4: Number of characters written (lpNumberOfCharsWritten)
   mov r8, msg_length  ; argument 3: Length of buffer (nNumberOfCharsToWrite)
   lea rdx, [msg]      ; argument 2: Pointer to buffer to write (*lpBuffer)
   mov rcx, rax        ; argument 1: Handle from GetStdHandle (hConsoleOutput)
   sub rsp, 32         ; shadow space
   call WriteConsoleA  ; Returns boolean representing success in rax
   add rsp, 32         ; return shadow space
   add rsp, 8          ; pop argument 5, discard value

;   sub rsp, 28h        ; space for 4 arguments + 16byte aligned stack
;   xor r9d, r9d        ; 4. argument: r9d = uType = 0
;   lea r8, [caption]   ; 3. argument: r8  = caption
;   lea rdx, [text]     ; 2. argument: edx = window text
;   xor rcx, rcx        ; 1. argument: rcx = hWnd = NULL
;   call MessageBoxA

   xor rcx, rcx        ; argument 1: exit code
   sub rsp, 32         ; shadow space
   call ExitProcess    ; Does not return

subroutine:
  
  
  
end

; prologue:
;   ; save registers to home locations, e.g.:
;   mov    [rsp + 8], rcx
;   ; save non-volatile registers, e.g.:
;   push r14
;   push r13
;   ; allocate space for local variables, e.g.:
;   sub rsp, 32
;   ; (if we allocate more than one page, use __chkstk)

; epilogue:
;   ; return space for local variables, e.g.:
;   add rsp, 32
;   ; pop non-volative registers, e.g.:
;   pop r13
;   pop r14
;   ; return
;   ret
