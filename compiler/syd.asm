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
  typeTable    db 000h, 000h, 050h, 000h, 050h, 000h, 050h, 000h ; Type table
               db 050h, 000h, 050h, 000h, 050h, 000h, 050h, 000h ; ...
               db 050h, 000h, 050h, 000h, 050h, 000h, 050h, 000h ; ...
               db 050h, 000h, 050h, 000h, 050h, 000h, 050h, 000h ; ...
               db 050h, 000h, 050h, 000h, 050h, 000h, 030h, 000h ; ...
               db 050h, 000h, 050h, 000h, 030h, 000h, 011h, 000h ; ...
               db 012h, 000h, 014h, 000h, 018h, 000h, 000h, 000h ; ...
   ; Columns: Null'23 Boolean'24 Integer'25 String'26 Anything'27 WhateverReadOnlyList'28 AnythingFunction'29 WhateverList'30 StringList'31
   ; 0 0 0 0 0 0 0 0 : 0   <sentinel>'0
   ; 0 0 0 0 1 0 1 0 : 0   NullFunction(String)'1
   ; 0 0 0 0 1 0 1 0 : 0   NullFunction(Integer)'2
   ; 0 0 0 0 1 0 1 0 : 0   IntegerFunction(WhateverReadOnlyList)'3
   ; 0 0 0 0 1 0 1 0 : 0   NullFunction()'4
   ; 0 0 0 0 1 0 1 0 : 0   IntegerFunction(Integer)'5
   ; 0 0 0 0 1 0 1 0 : 0   NullFunction(Integer, Integer)'6
   ; 0 0 0 0 1 0 1 0 : 0   NullFunction(Boolean, String)'7
   ; 0 0 0 0 1 0 1 0 : 0   IntegerFunction()'8
   ; 0 0 0 0 1 0 1 0 : 0   IntegerFunction(Integer, Integer, Integer)'9
   ; 0 0 0 0 1 0 1 0 : 0   NullFunction(WhateverList, Anything)'10
   ; 0 0 0 0 1 0 1 0 : 0   StringFunction(Integer)'11
   ; 0 0 0 0 1 0 1 0 : 0   StringFunction(StringList)'12
   ; 0 0 0 0 1 0 1 0 : 0   StringFunction(String, Integer)'13
   ; 0 0 0 0 1 0 1 0 : 0   StringListFunction(String)'14
   ; 0 0 0 0 1 0 1 0 : 0   StringFunction(String)'15
   ; 0 0 0 0 1 0 1 0 : 0   NullFunction(Integer, Integer, Integer)'16
   ; 0 0 0 0 1 0 1 0 : 0   IntegerFunction(String)'17
   ; 0 0 0 0 1 0 1 0 : 0   StringFunction(String...)'18
   ; 0 0 0 0 1 1 0 0 : 0   StringReadOnlyList'19
   ; 0 0 0 0 1 0 1 0 : 0   StringFunction(Anything)'20
   ; 0 0 0 0 1 0 1 0 : 0   NullFunction(Anything...)'21
   ; 0 0 0 0 1 1 0 0 : 0   AnythingReadOnlyList'22
   ; 1 0 0 0 1 0 0 0 : 0   Null'23
   ; 0 1 0 0 1 0 0 0 : 0   Boolean'24
   ; 0 0 1 0 1 0 0 0 : 0   Integer'25
   ; 0 0 0 1 1 0 0 0 : 0   String'26

  func$__print$annotation dq -01h                                ; String constant (reference count)
               dq 7                                              ; Length
               db "__print"                                      ; line 1087 column 111 in file syd-compiler.syd
               db 00h                                            ; padding to align to 8-byte boundary
  func$exit$annotation dq -01h                                   ; String constant (reference count)
               dq 4                                              ; Length
               db "exit"                                         ; line 1087 column 111 in file syd-compiler.syd
               db 00h, 00h, 00h, 00h                             ; padding to align to 8-byte boundary
  func$len$annotation dq -01h                                    ; String constant (reference count)
               dq 3                                              ; Length
               db "len"                                          ; line 1087 column 111 in file syd-compiler.syd
               db 00h, 00h, 00h, 00h, 00h                        ; padding to align to 8-byte boundary
  func$__debugger$annotation dq -01h                             ; String constant (reference count)
               dq 10                                             ; Length
               db "__debugger"                                   ; line 1087 column 111 in file syd-compiler.syd
               db 00h, 00h, 00h, 00h, 00h, 00h                   ; padding to align to 8-byte boundary
  func$__readFromAddress$annotation dq -01h                      ; String constant (reference count)
               dq 17                                             ; Length
               db "__readFromAddress"                            ; line 1087 column 111 in file syd-compiler.syd
               db 00h, 00h, 00h, 00h, 00h, 00h, 00h              ; padding to align to 8-byte boundary
  func$__writeToAddress$annotation dq -01h                       ; String constant (reference count)
               dq 16                                             ; Length
               db "__writeToAddress"                             ; line 1087 column 111 in file syd-compiler.syd
               db 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h         ; padding to align to 8-byte boundary
  parameterCountCheckFailureMessage dq -01h                      ; String constant (reference count)
               dq 88                                             ; Length
               db "error: function call received the wrong number of parameters (expected %d, received %d)", 0ah ; line 1664 column 25 in file syd-compiler.syd
               db 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h         ; padding to align to 8-byte boundary
  parameterTypeCheckFailureMessage dq -01h                       ; String constant (reference count)
               dq 71                                             ; Length
               db "error: type mismatch for function %s parameter %d, expected %s, got %s", 0ah ; line 1669 column 25 in file syd-compiler.syd
               db 00h                                            ; padding to align to 8-byte boundary
  returnValueTypeCheckFailureMessage dq -01h                     ; String constant (reference count)
               dq 68                                             ; Length
               db "error: type mismatch for function return value, expected %s, got %s", 0ah ; line 1674 column 25 in file syd-compiler.syd
               db 00h, 00h, 00h, 00h                             ; padding to align to 8-byte boundary
  operandTypeCheckFailureMessage dq -01h                         ; String constant (reference count)
               dq 54                                             ; Length
               db "error: type mismatch for operand, expected %s, got %s", 0ah ; line 1679 column 25 in file syd-compiler.syd
               db 00h, 00h                                       ; padding to align to 8-byte boundary
  asOperatorFailureMessage dq -01h                               ; String constant (reference count)
               dq 58                                             ; Length
               db "error: type mismatch for as operator, expected %s, got %s", 0ah ; line 1684 column 25 in file syd-compiler.syd
               db 00h, 00h, 00h, 00h, 00h, 00h                   ; padding to align to 8-byte boundary
  boundsFailureMessage dq -01h                                   ; String constant (reference count)
               dq 64                                             ; Length
               db "error: subscript index out of range (%d is not in range %d..%d)", 0ah ; line 1689 column 25 in file syd-compiler.syd
               db 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h         ; padding to align to 8-byte boundary
  func$assert$annotation dq -01h                                 ; String constant (reference count)
               dq 6                                              ; Length
               db "assert"                                       ; line 1087 column 111 in file syd-compiler.syd
               db 00h, 00h                                       ; padding to align to 8-byte boundary
  string       dq -01h                                           ; String constant (reference count)
               dq 1                                              ; Length
               db 0ah                                            ; line 8 column 16 in file runtime library
               db 00h, 00h, 00h, 00h, 00h, 00h, 00h              ; padding to align to 8-byte boundary
  func$throw$annotation dq -01h                                  ; String constant (reference count)
               dq 5                                              ; Length
               db "throw"                                        ; line 1087 column 111 in file syd-compiler.syd
               db 00h, 00h, 00h                                  ; padding to align to 8-byte boundary
  func$__getLastError$annotation dq -01h                         ; String constant (reference count)
               dq 14                                             ; Length
               db "__getLastError"                               ; line 1087 column 111 in file syd-compiler.syd
               db 00h, 00h                                       ; padding to align to 8-byte boundary
  func$__getProcessHeap$annotation dq -01h                       ; String constant (reference count)
               dq 16                                             ; Length
               db "__getProcessHeap"                             ; line 1087 column 111 in file syd-compiler.syd
               db 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h         ; padding to align to 8-byte boundary
  func$__heapAlloc$annotation dq -01h                            ; String constant (reference count)
               dq 11                                             ; Length
               db "__heapAlloc"                                  ; line 1087 column 111 in file syd-compiler.syd
               db 00h, 00h, 00h, 00h, 00h                        ; padding to align to 8-byte boundary
  func$_alloc$annotation dq -01h                                 ; String constant (reference count)
               dq 6                                              ; Length
               db "_alloc"                                       ; line 1087 column 111 in file syd-compiler.syd
               db 00h, 00h                                       ; padding to align to 8-byte boundary
  func$__heapFree$annotation dq -01h                             ; String constant (reference count)
               dq 10                                             ; Length
               db "__heapFree"                                   ; line 1087 column 111 in file syd-compiler.syd
               db 00h, 00h, 00h, 00h, 00h, 00h                   ; padding to align to 8-byte boundary
  func$_free$annotation dq -01h                                  ; String constant (reference count)
               dq 5                                              ; Length
               db "_free"                                        ; line 1087 column 111 in file syd-compiler.syd
               db 00h, 00h, 00h                                  ; padding to align to 8-byte boundary
  func$append$annotation dq -01h                                 ; String constant (reference count)
               dq 6                                              ; Length
               db "append"                                       ; line 1087 column 111 in file syd-compiler.syd
               db 00h, 00h                                       ; padding to align to 8-byte boundary
  string$1     dq -01h                                           ; String constant (reference count)
               dq 26                                             ; Length
               db "append is not implemented", 0ah               ; line 51 column 39 in file runtime library
               db 00h, 00h, 00h, 00h, 00h, 00h                   ; padding to align to 8-byte boundary
  func$chr$annotation dq -01h                                    ; String constant (reference count)
               dq 3                                              ; Length
               db "chr"                                          ; line 1087 column 111 in file syd-compiler.syd
               db 00h, 00h, 00h, 00h, 00h                        ; padding to align to 8-byte boundary
  string$2     dq -01h                                           ; String constant (reference count)
               dq 23                                             ; Length
               db "chr is not implemented", 0ah                  ; line 57 column 36 in file runtime library
               db 00h                                            ; padding to align to 8-byte boundary
  func$joinList$annotation dq -01h                               ; String constant (reference count)
               dq 8                                              ; Length
               db "joinList"                                     ; line 1087 column 111 in file syd-compiler.syd
               db 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h         ; padding to align to 8-byte boundary
  string$3     dq -01h                                           ; String constant (reference count)
               dq 28                                             ; Length
               db "joinList is not implemented", 0ah             ; line 63 column 41 in file runtime library
               db 00h, 00h, 00h, 00h                             ; padding to align to 8-byte boundary
  func$stringTimes$annotation dq -01h                            ; String constant (reference count)
               dq 11                                             ; Length
               db "stringTimes"                                  ; line 1087 column 111 in file syd-compiler.syd
               db 00h, 00h, 00h, 00h, 00h                        ; padding to align to 8-byte boundary
  string$4     dq -01h                                           ; String constant (reference count)
               dq 31                                             ; Length
               db "stringTimes is not implemented", 0ah          ; line 69 column 44 in file runtime library
               db 00h                                            ; padding to align to 8-byte boundary
  func$charsOf$annotation dq -01h                                ; String constant (reference count)
               dq 7                                              ; Length
               db "charsOf"                                      ; line 1087 column 111 in file syd-compiler.syd
               db 00h                                            ; padding to align to 8-byte boundary
  string$5     dq -01h                                           ; String constant (reference count)
               dq 27                                             ; Length
               db "charsOf is not implemented", 0ah              ; line 75 column 40 in file runtime library
               db 00h, 00h, 00h, 00h, 00h                        ; padding to align to 8-byte boundary
  func$scalarValues$annotation dq -01h                           ; String constant (reference count)
               dq 12                                             ; Length
               db "scalarValues"                                 ; line 1087 column 111 in file syd-compiler.syd
               db 00h, 00h, 00h, 00h                             ; padding to align to 8-byte boundary
  string$6     dq -01h                                           ; String constant (reference count)
               dq 32                                             ; Length
               db "scalarValues is not implemented", 0ah         ; line 81 column 45 in file runtime library
               db 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h         ; padding to align to 8-byte boundary
  func$hex$annotation dq -01h                                    ; String constant (reference count)
               dq 3                                              ; Length
               db "hex"                                          ; line 1087 column 111 in file syd-compiler.syd
               db 00h, 00h, 00h, 00h, 00h                        ; padding to align to 8-byte boundary
  string$7     dq -01h                                           ; String constant (reference count)
               dq 23                                             ; Length
               db "hex is not implemented", 0ah                  ; line 87 column 36 in file runtime library
               db 00h                                            ; padding to align to 8-byte boundary
  func$readFile$annotation dq -01h                               ; String constant (reference count)
               dq 8                                              ; Length
               db "readFile"                                     ; line 1087 column 111 in file syd-compiler.syd
               db 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h         ; padding to align to 8-byte boundary
  string$8     dq -01h                                           ; String constant (reference count)
               dq 28                                             ; Length
               db "readFile is not implemented", 0ah             ; line 93 column 41 in file runtime library
               db 00h, 00h, 00h, 00h                             ; padding to align to 8-byte boundary
  func$stderr$annotation dq -01h                                 ; String constant (reference count)
               dq 6                                              ; Length
               db "stderr"                                       ; line 1087 column 111 in file syd-compiler.syd
               db 00h, 00h                                       ; padding to align to 8-byte boundary
  string$9     dq -01h                                           ; String constant (reference count)
               dq 26                                             ; Length
               db "stderr is not implemented", 0ah               ; line 99 column 39 in file runtime library
               db 00h, 00h, 00h, 00h, 00h, 00h                   ; padding to align to 8-byte boundary
  func$_moveBytes$annotation dq -01h                             ; String constant (reference count)
               dq 10                                             ; Length
               db "_moveBytes"                                   ; line 1087 column 111 in file syd-compiler.syd
               db 00h, 00h, 00h, 00h, 00h, 00h                   ; padding to align to 8-byte boundary
  string$10    dq -01h                                           ; String constant (reference count)
               dq 51                                             ; Length
               db "_moveBytes expects positive number of bytes to copy" ; line 106 column 74 in file runtime library
               db 00h, 00h, 00h, 00h, 00h                        ; padding to align to 8-byte boundary
  string$11    dq -01h                                           ; String constant (reference count)
               dq 61                                             ; Length
               db "internal error: zero extra bytes but fromCursor is before end" ; line 125 column 90 in file runtime library
               db 00h, 00h, 00h                                  ; padding to align to 8-byte boundary
  string$12    dq -01h                                           ; String constant (reference count)
               dq 39                                             ; Length
               db "internal error: more than 7 extra bytes"      ; line 126 column 68 in file runtime library
               db 00h                                            ; padding to align to 8-byte boundary
  func$_stringByteLength$annotation dq -01h                      ; String constant (reference count)
               dq 17                                             ; Length
               db "_stringByteLength"                            ; line 1087 column 111 in file syd-compiler.syd
               db 00h, 00h, 00h, 00h, 00h, 00h, 00h              ; padding to align to 8-byte boundary
  func$concat$annotation dq -01h                                 ; String constant (reference count)
               dq 6                                              ; Length
               db "concat"                                       ; line 1087 column 111 in file syd-compiler.syd
               db 00h, 00h                                       ; padding to align to 8-byte boundary
  func$digitToStr$annotation dq -01h                             ; String constant (reference count)
               dq 10                                             ; Length
               db "digitToStr"                                   ; line 1087 column 111 in file syd-compiler.syd
               db 00h, 00h, 00h, 00h, 00h, 00h                   ; padding to align to 8-byte boundary
  string$13    dq -01h                                           ; String constant (reference count)
               dq 1                                              ; Length
               db "0"                                            ; line 171 column 14 in file runtime library
               db 00h, 00h, 00h, 00h, 00h, 00h, 00h              ; padding to align to 8-byte boundary
  string$14    dq -01h                                           ; String constant (reference count)
               dq 1                                              ; Length
               db "1"                                            ; line 174 column 14 in file runtime library
               db 00h, 00h, 00h, 00h, 00h, 00h, 00h              ; padding to align to 8-byte boundary
  string$15    dq -01h                                           ; String constant (reference count)
               dq 1                                              ; Length
               db "2"                                            ; line 177 column 14 in file runtime library
               db 00h, 00h, 00h, 00h, 00h, 00h, 00h              ; padding to align to 8-byte boundary
  string$16    dq -01h                                           ; String constant (reference count)
               dq 1                                              ; Length
               db "3"                                            ; line 180 column 14 in file runtime library
               db 00h, 00h, 00h, 00h, 00h, 00h, 00h              ; padding to align to 8-byte boundary
  string$17    dq -01h                                           ; String constant (reference count)
               dq 1                                              ; Length
               db "4"                                            ; line 183 column 14 in file runtime library
               db 00h, 00h, 00h, 00h, 00h, 00h, 00h              ; padding to align to 8-byte boundary
  string$18    dq -01h                                           ; String constant (reference count)
               dq 1                                              ; Length
               db "5"                                            ; line 186 column 14 in file runtime library
               db 00h, 00h, 00h, 00h, 00h, 00h, 00h              ; padding to align to 8-byte boundary
  string$19    dq -01h                                           ; String constant (reference count)
               dq 1                                              ; Length
               db "6"                                            ; line 189 column 14 in file runtime library
               db 00h, 00h, 00h, 00h, 00h, 00h, 00h              ; padding to align to 8-byte boundary
  string$20    dq -01h                                           ; String constant (reference count)
               dq 1                                              ; Length
               db "7"                                            ; line 192 column 14 in file runtime library
               db 00h, 00h, 00h, 00h, 00h, 00h, 00h              ; padding to align to 8-byte boundary
  string$21    dq -01h                                           ; String constant (reference count)
               dq 1                                              ; Length
               db "8"                                            ; line 195 column 14 in file runtime library
               db 00h, 00h, 00h, 00h, 00h, 00h, 00h              ; padding to align to 8-byte boundary
  string$22    dq -01h                                           ; String constant (reference count)
               dq 1                                              ; Length
               db "9"                                            ; line 198 column 14 in file runtime library
               db 00h, 00h, 00h, 00h, 00h, 00h, 00h              ; padding to align to 8-byte boundary
  string$23    dq -01h                                           ; String constant (reference count)
               dq 56                                             ; Length
               db "Invalid digit passed to digitToStr (digit as exit code)", 0ah ; line 200 column 69 in file runtime library
               db 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h         ; padding to align to 8-byte boundary
  func$intToStr$annotation dq -01h                               ; String constant (reference count)
               dq 8                                              ; Length
               db "intToStr"                                     ; line 1087 column 111 in file syd-compiler.syd
               db 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h         ; padding to align to 8-byte boundary
  string$24    dq -01h                                           ; String constant (reference count)
               dq 0                                              ; Length
  func$_stringify$annotation dq -01h                             ; String constant (reference count)
               dq 10                                             ; Length
               db "_stringify"                                   ; line 1087 column 111 in file syd-compiler.syd
               db 00h, 00h, 00h, 00h, 00h, 00h                   ; padding to align to 8-byte boundary
  string$25    dq -01h                                           ; String constant (reference count)
               dq 4                                              ; Length
               db "true"                                         ; line 224 column 19 in file runtime library
               db 00h, 00h, 00h, 00h                             ; padding to align to 8-byte boundary
  string$26    dq -01h                                           ; String constant (reference count)
               dq 5                                              ; Length
               db "false"                                        ; line 226 column 18 in file runtime library
               db 00h, 00h, 00h                                  ; padding to align to 8-byte boundary
  string$27    dq -01h                                           ; String constant (reference count)
               dq 4                                              ; Length
               db "null"                                         ; line 229 column 17 in file runtime library
               db 00h, 00h, 00h, 00h                             ; padding to align to 8-byte boundary
  string$28    dq -01h                                           ; String constant (reference count)
               dq 11                                             ; Length
               db "<function ("                                  ; line 237 column 31 in file runtime library
               db 00h, 00h, 00h, 00h, 00h                        ; padding to align to 8-byte boundary
  string$29    dq -01h                                           ; String constant (reference count)
               dq 2                                              ; Length
               db ")>"                                           ; line 237 column 63 in file runtime library
               db 00h, 00h, 00h, 00h, 00h, 00h                   ; padding to align to 8-byte boundary
  string$30    dq -01h                                           ; String constant (reference count)
               dq 28                                             ; Length
               db "value cannot be stringified", 0ah             ; line 239 column 41 in file runtime library
               db 00h, 00h, 00h, 00h                             ; padding to align to 8-byte boundary
  func$print$annotation dq -01h                                  ; String constant (reference count)
               dq 5                                              ; Length
               db "print"                                        ; line 1087 column 111 in file syd-compiler.syd
               db 00h, 00h, 00h                                  ; padding to align to 8-byte boundary
  string$31    dq -01h                                           ; String constant (reference count)
               dq 1                                              ; Length
               db " "                                            ; line 248 column 17 in file runtime library
               db 00h, 00h, 00h, 00h, 00h, 00h, 00h              ; padding to align to 8-byte boundary
  func$println$annotation dq -01h                                ; String constant (reference count)
               dq 7                                              ; Length
               db "println"                                      ; line 1087 column 111 in file syd-compiler.syd
               db 00h                                            ; padding to align to 8-byte boundary
  func$foo$annotation dq -01h                                    ; String constant (reference count)
               dq 3                                              ; Length
               db "foo"                                          ; line 1087 column 111 in file syd-compiler.syd
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
  cmp rdx, 26                                                    ; verify that the variable is a string
  jne intrinsic$decref$end                                       ; if not, abort
  ; check reference count is not negative
  cmp qword ptr [rcx], 0                                         ; if the refcount is negative then this is a constant, not reference counted
  js intrinsic$decref$end                                        ; ...so abort
  dec qword ptr [rcx]                                            ; decrement the reference count
  jnz intrinsic$decref$end                                       ; if we did not reach zero, then the string is still in use; abort
  ; String reached zero reference count, so we must free it.
  push rcx                                                       ; argument #1 value: pointer to block we want to free.
  push 25                                                        ; argument #1 type: integer
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
  ; Line 23: Integer _heapHandle = __getProcessHeap();
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
  ; Line 27: Integer _blockCount = 0;
  mov qword ptr _blockCountValue, 000h                           ; value initialization of variable declaration for _blockCount variable (0)
  mov qword ptr _blockCountType, 019h                            ; type initialization of variable declaration for _blockCount variable (Integer'25)
  ; Epilog
  add rsp, 018h                                                  ; free space for stack
  pop rbp                                                        ; restore non-volatile registers

  ; temp.syd
  ; ========
  ; Prolog
  push rbp                                                       ; save non-volatile registers
  push rbx                                                       ; save non-volatile registers
  sub rsp, 018h                                                  ; allocate space for stack
  lea rbp, qword ptr [rsp + 028h]                                ; set up frame pointer
  ; Line 4: println(foo);
  ; Call println with 1 arguments
  mov r10, func$foo                                              ; reading foo for push
  push r10                                                       ; value of argument #1 (foo)
  push 004h                                                      ; type of argument #1 (NullFunction()'4)
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
  ; Terminate application - call exit(0)
  ; Call exit with 1 arguments
  push 000h                                                      ; value of argument #1 (0 (integer))
  push 019h                                                      ; type of argument #1 (Integer'25)
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
  ; Epilog
  add rsp, 018h                                                  ; free space for stack
  pop rbx                                                        ; restore non-volatile registers
  pop rbp                                                        ; restore non-volatile registers

  ; End of global scope
  ret                                                            ; exit application

; __print
dq func$__print$annotation
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
  sub rsp, 028h                                                  ; allocate space for stack
  lea rbp, qword ptr [rsp + 068h]                                ; set up frame pointer
  ; Check parameter count
  cmp rcx, 001h                                                  ; compare parameter count of __print to 1 (integer)
  je func$__print$parameterCountCheck$continuation               ; check number of parameters is as expected
    ; Error handling block for parameter count
    ;  - print(parameterCountCheckFailureMessage)
    ; Call __print with 1 arguments
    mov r10, offset parameterCountCheckFailureMessage            ; reading parameterCountCheckFailureMessage for push
    push r10                                                     ; value of argument #1 (parameterCountCheckFailureMessage)
    push 01ah                                                    ; type of argument #1 (String'26)
    lea rax, qword ptr [rsp + 028h]                              ; load address of return value's value
    push rax                                                     ; internal argument 6: pointer to return value slot's value
    lea rax, qword ptr [rsp + 028h]                              ; load address of return value's type
    push rax                                                     ; internal argument 5: pointer to return value slot's type
    sub rsp, 020h                                                ; allocate shadow space
    mov r9, 000h                                                 ; internal argument 4: "this" pointer
    mov r8, 000h                                                 ; internal argument 3: "this" pointer type
    mov rdx, 000h                                                ; internal argument 2: closure pointer
    mov qword ptr [rsp + 048h], rcx                              ; move parameter count of __print value out of rcx
    mov rcx, 001h                                                ; internal argument 1: number of actual arguments
    call func$__print                                            ; jump to subroutine
    add rsp, 040h                                                ; release shadow space and arguments (result in stack pointer)
    ;  - exit(1)
    ; Call exit with 1 arguments
    push 001h                                                    ; value of argument #1 (1 (integer))
    push 019h                                                    ; type of argument #1 (Integer'25)
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
  func$__print$parameterCountCheck$continuation:                 ; end of parameter count check
  ; Check type of parameter 0, message to print to console (expecting String)
  mov rsi, qword ptr [rbp + 038h]                                ; move type of message to print to console to testByte
  mov rax, rsi                                                   ; move testByte to testByte
  mov rdi, 002h                                                  ; read operand of mul (type table width in bytes) 
  mul rdi                                                        ; adjust to the relative start of that type's entry in the type table
  mov r12, offset typeTable                                      ; read second operand of + (type table pointer)
  add rax, r12                                                   ; finally offset all of that by the start of the type table itself (result in testByte)
  bt qword ptr [rax], 003h                                       ; check that message to print to console is String
  jc func$__print$messageToPrintToConsole$TypeMatch              ; skip next block if the type matches
    ; Error handling block for message to print to console
    ;  - print(parameterTypeCheckFailureMessage)
    ; Call __print with 1 arguments
    mov r13, offset parameterTypeCheckFailureMessage             ; reading parameterTypeCheckFailureMessage for push
    push r13                                                     ; value of argument #1 (parameterTypeCheckFailureMessage)
    push 01ah                                                    ; type of argument #1 (String'26)
    lea r14, qword ptr [rsp + 028h]                              ; load address of return value's value
    push r14                                                     ; internal argument 6: pointer to return value slot's value
    lea r14, qword ptr [rsp + 028h]                              ; load address of return value's type
    push r14                                                     ; internal argument 5: pointer to return value slot's type
    sub rsp, 020h                                                ; allocate shadow space
    mov r9, 000h                                                 ; internal argument 4: "this" pointer
    mov r8, 000h                                                 ; internal argument 3: "this" pointer type
    mov rdx, 000h                                                ; internal argument 2: closure pointer
    mov qword ptr [rsp + 048h], rcx                              ; move parameter count of __print value out of rcx
    mov rcx, 001h                                                ; internal argument 1: number of actual arguments
    call func$__print                                            ; jump to subroutine
    add rsp, 040h                                                ; release shadow space and arguments (result in stack pointer)
    ;  - exit(1)
    ; Call exit with 1 arguments
    push 001h                                                    ; value of argument #1 (1 (integer))
    push 019h                                                    ; type of argument #1 (Integer'25)
    lea r15, qword ptr [rsp + 028h]                              ; load address of return value's value
    push r15                                                     ; internal argument 6: pointer to return value slot's value
    lea r15, qword ptr [rsp + 028h]                              ; load address of return value's type
    push r15                                                     ; internal argument 5: pointer to return value slot's type
    sub rsp, 020h                                                ; allocate shadow space
    mov r9, 000h                                                 ; internal argument 4: "this" pointer
    mov r8, 000h                                                 ; internal argument 3: "this" pointer type
    mov rdx, 000h                                                ; internal argument 2: closure pointer
    mov rcx, 001h                                                ; internal argument 1: number of actual arguments
    call func$exit                                               ; jump to subroutine
    add rsp, 040h                                                ; release shadow space and arguments (result in stack pointer)
    mov rcx, qword ptr [rsp + 008h]                              ; restoring slots to previous scope state
  func$__print$messageToPrintToConsole$TypeMatch:                ; after block
  ; Calling GetStdHandle
  sub rsp, 020h                                                  ; allocate shadow space
  mov qword ptr [rsp + 018h], rcx                                ; move parameter count of __print value out of rcx
  mov rcx, -00bh                                                 ; argument #1: STD_OUTPUT_HANDLE
  call GetStdHandle                                              ; handle returned in rax
  add rsp, 020h                                                  ; release shadow space (result in stack pointer)
  ; Calling WriteConsoleA
  push 000h                                                      ; argument #5: Reserved, must be NULL (lpReserved)
  sub rsp, 020h                                                  ; allocate shadow space
  lea r9, qword ptr [rsp + 038h]                                 ; argument #4: Number of characters written (lpNumberOfCharsWritten)
  mov r10, qword ptr [rbp + 040h]                                ; get message to print to console into register to dereference it
  mov r8, qword ptr [r10 + 008h]                                 ; argument #3: Length of buffer (nNumberOfCharsToWrite), from string structure
  mov rdx, qword ptr [rbp + 040h]                                ; assign value of message to print to console to value of x64 calling convention arg #2
  add rdx, 010h                                                  ; argument #2: Pointer to buffer to write (*lpBuffer) (result in x64 calling convention arg #2)
  mov rcx, rax                                                   ; argument #1: Handle from GetStdHandle (hConsoleOutput)
  call WriteConsoleA                                             ; returns boolean representing success in rax
  add rsp, 028h                                                  ; release shadow space (result in stack pointer)
  ; Implicit return from __print
  mov r12, qword ptr [rbp + 030h]                                ; get pointer to return value of __print into register to dereference it
  mov qword ptr [r12], 000h                                      ; __print return value
  mov r13, qword ptr [rbp + 028h]                                ; get pointer to return value type of __print into register to dereference it
  mov qword ptr [r13], 017h                                      ; type of __print return value (Null'23)
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

; exit
dq func$exit$annotation
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
    push 01ah                                                    ; type of argument #1 (String'26)
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
    push 019h                                                    ; type of argument #1 (Integer'25)
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
  mov rdi, 002h                                                  ; read operand of mul (type table width in bytes) 
  mul rdi                                                        ; adjust to the relative start of that type's entry in the type table
  mov r12, offset typeTable                                      ; read second operand of + (type table pointer)
  add rax, r12                                                   ; finally offset all of that by the start of the type table itself (result in testByte)
  bt qword ptr [rax], 002h                                       ; check that exit code parameter is Integer
  jc func$exit$exitCodeParameter$TypeMatch                       ; skip next block if the type matches
    ; Error handling block for exit code parameter
    ;  - print(parameterTypeCheckFailureMessage)
    ; Call __print with 1 arguments
    mov r13, offset parameterTypeCheckFailureMessage             ; reading parameterTypeCheckFailureMessage for push
    push r13                                                     ; value of argument #1 (parameterTypeCheckFailureMessage)
    push 01ah                                                    ; type of argument #1 (String'26)
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
    push 019h                                                    ; type of argument #1 (Integer'25)
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
  mov rax, qword ptr [rbp + 030h]                                ; get pointer to return value of exit into register to dereference it
  mov qword ptr [rax], 000h                                      ; exit return value
  mov rdi, qword ptr [rbp + 028h]                                ; get pointer to return value type of exit into register to dereference it
  mov qword ptr [rdi], 017h                                      ; type of exit return value (Null'23)
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
dq func$len$annotation
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
    push 01ah                                                    ; type of argument #1 (String'26)
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
    push 019h                                                    ; type of argument #1 (Integer'25)
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
  mov rdi, 002h                                                  ; read operand of mul (type table width in bytes) 
  mul rdi                                                        ; adjust to the relative start of that type's entry in the type table
  mov r12, offset typeTable                                      ; read second operand of + (type table pointer)
  add rax, r12                                                   ; finally offset all of that by the start of the type table itself (result in testByte)
  bt qword ptr [rax], 005h                                       ; check that list is WhateverReadOnlyList
  jc func$len$list$TypeMatch                                     ; skip next block if the type matches
    ; Error handling block for list
    ;  - print(parameterTypeCheckFailureMessage)
    ; Call __print with 1 arguments
    mov r13, offset parameterTypeCheckFailureMessage             ; reading parameterTypeCheckFailureMessage for push
    push r13                                                     ; value of argument #1 (parameterTypeCheckFailureMessage)
    push 01ah                                                    ; type of argument #1 (String'26)
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
    push 019h                                                    ; type of argument #1 (Integer'25)
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
  mov r10, 017h                                                  ; move type of null to testByte
  mov rax, r10                                                   ; move testByte to testByte
  mov rbx, 002h                                                  ; read operand of mul (type table width in bytes) 
  mul rbx                                                        ; adjust to the relative start of that type's entry in the type table
  mov rsi, offset typeTable                                      ; read second operand of + (type table pointer)
  add rax, rsi                                                   ; finally offset all of that by the start of the type table itself (result in testByte)
  bt qword ptr [rax], 002h                                       ; check that len return value is Integer
  jc func$len$lenReturnValue$TypeMatch                           ; skip next block if the type matches
    ; Error handling block for len return value
    ;  - print(returnValueTypeCheckFailureMessage)
    ; Call __print with 1 arguments
    mov rdi, offset returnValueTypeCheckFailureMessage           ; reading returnValueTypeCheckFailureMessage for push
    push rdi                                                     ; value of argument #1 (returnValueTypeCheckFailureMessage)
    push 01ah                                                    ; type of argument #1 (String'26)
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
    push 019h                                                    ; type of argument #1 (Integer'25)
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
  mov qword ptr [r15], 017h                                      ; type of len return value (Null'23)
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
dq func$__debugger$annotation
func$__debugger:
  ; Prolog
  push r14                                                       ; save non-volatile registers
  push rbx                                                       ; save non-volatile registers
  push rsi                                                       ; save non-volatile registers
  push rdi                                                       ; save non-volatile registers
  push r12                                                       ; save non-volatile registers
  push rbp                                                       ; save non-volatile registers
  push r13                                                       ; save non-volatile registers
  sub rsp, 020h                                                  ; allocate space for stack
  lea rbp, qword ptr [rsp + 058h]                                ; set up frame pointer
  ; Check parameter count
  cmp rcx, 000h                                                  ; compare parameter count of __debugger to 0 (integer)
  je func$__debugger$parameterCountCheck$continuation            ; check number of parameters is as expected
    ; Error handling block for parameter count
    ;  - print(parameterCountCheckFailureMessage)
    ; Call __print with 1 arguments
    mov r10, offset parameterCountCheckFailureMessage            ; reading parameterCountCheckFailureMessage for push
    push r10                                                     ; value of argument #1 (parameterCountCheckFailureMessage)
    push 01ah                                                    ; type of argument #1 (String'26)
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
    push 019h                                                    ; type of argument #1 (Integer'25)
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
  int 3                                                          ; call debugger
  ; Implicit return from __debugger
  mov r13, qword ptr [rbp + 030h]                                ; get pointer to return value of __debugger into register to dereference it
  mov qword ptr [r13], 000h                                      ; __debugger return value
  mov r14, qword ptr [rbp + 028h]                                ; get pointer to return value type of __debugger into register to dereference it
  mov qword ptr [r14], 017h                                      ; type of __debugger return value (Null'23)
  mov rax, qword ptr [rbp + 030h]                                ; report address of return value
  ; Epilog
  add rsp, 020h                                                  ; free space for stack
  pop r13                                                        ; restore non-volatile registers
  pop rbp                                                        ; restore non-volatile registers
  pop r12                                                        ; restore non-volatile registers
  pop rdi                                                        ; restore non-volatile registers
  pop rsi                                                        ; restore non-volatile registers
  pop rbx                                                        ; restore non-volatile registers
  pop r14                                                        ; restore non-volatile registers
  ret                                                            ; return from subroutine

; __readFromAddress
dq func$__readFromAddress$annotation
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
    push 01ah                                                    ; type of argument #1 (String'26)
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
    push 019h                                                    ; type of argument #1 (Integer'25)
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
  mov rdi, 002h                                                  ; read operand of mul (type table width in bytes) 
  mul rdi                                                        ; adjust to the relative start of that type's entry in the type table
  mov r12, offset typeTable                                      ; read second operand of + (type table pointer)
  add rax, r12                                                   ; finally offset all of that by the start of the type table itself (result in testByte)
  bt qword ptr [rax], 002h                                       ; check that address is Integer
  jc func$__readFromAddress$address$TypeMatch                    ; skip next block if the type matches
    ; Error handling block for address
    ;  - print(parameterTypeCheckFailureMessage)
    ; Call __print with 1 arguments
    mov r13, offset parameterTypeCheckFailureMessage             ; reading parameterTypeCheckFailureMessage for push
    push r13                                                     ; value of argument #1 (parameterTypeCheckFailureMessage)
    push 01ah                                                    ; type of argument #1 (String'26)
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
    push 019h                                                    ; type of argument #1 (Integer'25)
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
  mov r10, 017h                                                  ; move type of null to testByte
  mov rax, r10                                                   ; move testByte to testByte
  mov rbx, 002h                                                  ; read operand of mul (type table width in bytes) 
  mul rbx                                                        ; adjust to the relative start of that type's entry in the type table
  mov rsi, offset typeTable                                      ; read second operand of + (type table pointer)
  add rax, rsi                                                   ; finally offset all of that by the start of the type table itself (result in testByte)
  bt qword ptr [rax], 002h                                       ; check that __readFromAddress return value is Integer
  jc func$__readFromAddress$ReadfromaddressReturnValue$TypeMatch ; skip next block if the type matches
    ; Error handling block for __readFromAddress return value
    ;  - print(returnValueTypeCheckFailureMessage)
    ; Call __print with 1 arguments
    mov rdi, offset returnValueTypeCheckFailureMessage           ; reading returnValueTypeCheckFailureMessage for push
    push rdi                                                     ; value of argument #1 (returnValueTypeCheckFailureMessage)
    push 01ah                                                    ; type of argument #1 (String'26)
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
    push 019h                                                    ; type of argument #1 (Integer'25)
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
  mov qword ptr [r15], 017h                                      ; type of __readFromAddress return value (Null'23)
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
dq func$__writeToAddress$annotation
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
    push 01ah                                                    ; type of argument #1 (String'26)
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
    push 019h                                                    ; type of argument #1 (Integer'25)
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
  mov rdi, 002h                                                  ; read operand of mul (type table width in bytes) 
  mul rdi                                                        ; adjust to the relative start of that type's entry in the type table
  mov r12, offset typeTable                                      ; read second operand of + (type table pointer)
  add rax, r12                                                   ; finally offset all of that by the start of the type table itself (result in testByte)
  bt qword ptr [rax], 002h                                       ; check that address is Integer
  jc func$__writeToAddress$address$TypeMatch                     ; skip next block if the type matches
    ; Error handling block for address
    ;  - print(parameterTypeCheckFailureMessage)
    ; Call __print with 1 arguments
    mov r13, offset parameterTypeCheckFailureMessage             ; reading parameterTypeCheckFailureMessage for push
    push r13                                                     ; value of argument #1 (parameterTypeCheckFailureMessage)
    push 01ah                                                    ; type of argument #1 (String'26)
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
    push 019h                                                    ; type of argument #1 (Integer'25)
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
  mov rbx, 002h                                                  ; read operand of mul (type table width in bytes) 
  mul rbx                                                        ; adjust to the relative start of that type's entry in the type table
  mov rsi, offset typeTable                                      ; read second operand of + (type table pointer)
  add rax, rsi                                                   ; finally offset all of that by the start of the type table itself (result in testByte)
  bt qword ptr [rax], 002h                                       ; check that value is Integer
  jc func$__writeToAddress$value$TypeMatch                       ; skip next block if the type matches
    ; Error handling block for value
    ;  - print(parameterTypeCheckFailureMessage)
    ; Call __print with 1 arguments
    mov rdi, offset parameterTypeCheckFailureMessage             ; reading parameterTypeCheckFailureMessage for push
    push rdi                                                     ; value of argument #1 (parameterTypeCheckFailureMessage)
    push 01ah                                                    ; type of argument #1 (String'26)
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
    push 019h                                                    ; type of argument #1 (Integer'25)
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
  mov rax, qword ptr [rbp + 030h]                                ; get pointer to return value of __writeToAddress into register to dereference it
  mov qword ptr [rax], 000h                                      ; __writeToAddress return value
  mov rbx, qword ptr [rbp + 028h]                                ; get pointer to return value type of __writeToAddress into register to dereference it
  mov qword ptr [rbx], 017h                                      ; type of __writeToAddress return value (Null'23)
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
dq func$assert$annotation
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
    push 01ah                                                    ; type of argument #1 (String'26)
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
    push 019h                                                    ; type of argument #1 (Integer'25)
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
  mov rdi, 002h                                                  ; read operand of mul (type table width in bytes) 
  mul rdi                                                        ; adjust to the relative start of that type's entry in the type table
  mov r12, offset typeTable                                      ; read second operand of + (type table pointer)
  add rax, r12                                                   ; finally offset all of that by the start of the type table itself (result in testByte)
  bt qword ptr [rax], 001h                                       ; check that condition is Boolean
  jc func$assert$condition$TypeMatch                             ; skip next block if the type matches
    ; Error handling block for condition
    ;  - print(parameterTypeCheckFailureMessage)
    ; Call __print with 1 arguments
    mov r13, offset parameterTypeCheckFailureMessage             ; reading parameterTypeCheckFailureMessage for push
    push r13                                                     ; value of argument #1 (parameterTypeCheckFailureMessage)
    push 01ah                                                    ; type of argument #1 (String'26)
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
    push 019h                                                    ; type of argument #1 (Integer'25)
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
  mov rbx, 002h                                                  ; read operand of mul (type table width in bytes) 
  mul rbx                                                        ; adjust to the relative start of that type's entry in the type table
  mov rsi, offset typeTable                                      ; read second operand of + (type table pointer)
  add rax, rsi                                                   ; finally offset all of that by the start of the type table itself (result in testByte)
  bt qword ptr [rax], 003h                                       ; check that message is String
  jc func$assert$message$TypeMatch                               ; skip next block if the type matches
    ; Error handling block for message
    ;  - print(parameterTypeCheckFailureMessage)
    ; Call __print with 1 arguments
    mov rdi, offset parameterTypeCheckFailureMessage             ; reading parameterTypeCheckFailureMessage for push
    push rdi                                                     ; value of argument #1 (parameterTypeCheckFailureMessage)
    push 01ah                                                    ; type of argument #1 (String'26)
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
    push 019h                                                    ; type of argument #1 (Integer'25)
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
  cmp qword ptr [rbp + 038h], 000h                               ; compare type of condition to <sentinel>
  jne func$assert$condition$TypeMatch$1                          ; skip next block if condition is not sentinel
    ; Error handling block for condition
    ;  - print(operandTypeCheckFailureMessage)
    ; Call __print with 1 arguments
    mov r14, offset operandTypeCheckFailureMessage               ; reading operandTypeCheckFailureMessage for push
    push r14                                                     ; value of argument #1 (operandTypeCheckFailureMessage)
    push 01ah                                                    ; type of argument #1 (String'26)
    lea r15, qword ptr [rsp + 020h]                              ; load address of return value's value
    push r15                                                     ; internal argument 6: pointer to return value slot's value
    lea r15, qword ptr [rsp + 020h]                              ; load address of return value's type
    push r15                                                     ; internal argument 5: pointer to return value slot's type
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
    push 019h                                                    ; type of argument #1 (Integer'25)
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
    mov rcx, qword ptr [rsp + 000h]                              ; restoring slots to previous scope state
  func$assert$condition$TypeMatch$1:                             ; after block
  xor rax, rax                                                   ; zero ! unary operator result to put the boolean in
  cmp qword ptr [rbp + 040h], 000h                               ; ! unary operator
  sete al                                                        ; put result in ! unary operator result
  mov rbx, 018h                                                  ; ! unary operator result is a Boolean'24
  mov rbx, 018h                                                  ; ! unary operator result is of type Boolean'24
  cmp rax, 000h                                                  ; compare ! unary operator result to false
  je func$assert$if$continuation                                 ; !condition
    ; Line 7: __print(message);
    ; Call __print with 1 arguments
    push qword ptr [rbp + 050h]                                  ; value of argument #1 (message)
    push qword ptr [rbp + 048h]                                  ; type of argument #1
    lea rsi, qword ptr [rsp + 020h]                              ; load address of return value's value
    push rsi                                                     ; internal argument 6: pointer to return value slot's value
    lea rsi, qword ptr [rsp + 020h]                              ; load address of return value's type
    push rsi                                                     ; internal argument 5: pointer to return value slot's type
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
    mov rdi, offset string                                       ; reading string for push
    push rdi                                                     ; value of argument #1 (string)
    push 01ah                                                    ; type of argument #1 (String'26)
    lea r12, qword ptr [rsp + 020h]                              ; load address of return value's value
    push r12                                                     ; internal argument 6: pointer to return value slot's value
    lea r12, qword ptr [rsp + 020h]                              ; load address of return value's type
    push r12                                                     ; internal argument 5: pointer to return value slot's type
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
    push 019h                                                    ; type of argument #1 (Integer'25)
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
  func$assert$if$continuation:                                   ; end of if
  ; Implicit return from assert
  mov rax, qword ptr [rbp + 030h]                                ; get pointer to return value of assert into register to dereference it
  mov qword ptr [rax], 000h                                      ; assert return value
  mov rbx, qword ptr [rbp + 028h]                                ; get pointer to return value type of assert into register to dereference it
  mov qword ptr [rbx], 017h                                      ; type of assert return value (Null'23)
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

; throw
dq func$throw$annotation
func$throw:
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
  cmp rcx, 001h                                                  ; compare parameter count of throw to 1 (integer)
  je func$throw$parameterCountCheck$continuation                 ; check number of parameters is as expected
    ; Error handling block for parameter count
    ;  - print(parameterCountCheckFailureMessage)
    ; Call __print with 1 arguments
    mov r10, offset parameterCountCheckFailureMessage            ; reading parameterCountCheckFailureMessage for push
    push r10                                                     ; value of argument #1 (parameterCountCheckFailureMessage)
    push 01ah                                                    ; type of argument #1 (String'26)
    lea rax, qword ptr [rsp + 020h]                              ; load address of return value's value
    push rax                                                     ; internal argument 6: pointer to return value slot's value
    lea rax, qword ptr [rsp + 020h]                              ; load address of return value's type
    push rax                                                     ; internal argument 5: pointer to return value slot's type
    sub rsp, 020h                                                ; allocate shadow space
    mov r9, 000h                                                 ; internal argument 4: "this" pointer
    mov r8, 000h                                                 ; internal argument 3: "this" pointer type
    mov rdx, 000h                                                ; internal argument 2: closure pointer
    mov qword ptr [rsp + 040h], rcx                              ; move parameter count of throw value out of rcx
    mov rcx, 001h                                                ; internal argument 1: number of actual arguments
    call func$__print                                            ; jump to subroutine
    add rsp, 040h                                                ; release shadow space and arguments (result in stack pointer)
    ;  - exit(1)
    ; Call exit with 1 arguments
    push 001h                                                    ; value of argument #1 (1 (integer))
    push 019h                                                    ; type of argument #1 (Integer'25)
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
  func$throw$parameterCountCheck$continuation:                   ; end of parameter count check
  ; Check type of parameter 0, message (expecting String)
  mov rsi, qword ptr [rbp + 038h]                                ; move type of message to testByte
  mov rax, rsi                                                   ; move testByte to testByte
  mov rdi, 002h                                                  ; read operand of mul (type table width in bytes) 
  mul rdi                                                        ; adjust to the relative start of that type's entry in the type table
  mov r12, offset typeTable                                      ; read second operand of + (type table pointer)
  add rax, r12                                                   ; finally offset all of that by the start of the type table itself (result in testByte)
  bt qword ptr [rax], 003h                                       ; check that message is String
  jc func$throw$message$TypeMatch                                ; skip next block if the type matches
    ; Error handling block for message
    ;  - print(parameterTypeCheckFailureMessage)
    ; Call __print with 1 arguments
    mov r13, offset parameterTypeCheckFailureMessage             ; reading parameterTypeCheckFailureMessage for push
    push r13                                                     ; value of argument #1 (parameterTypeCheckFailureMessage)
    push 01ah                                                    ; type of argument #1 (String'26)
    lea r14, qword ptr [rsp + 020h]                              ; load address of return value's value
    push r14                                                     ; internal argument 6: pointer to return value slot's value
    lea r14, qword ptr [rsp + 020h]                              ; load address of return value's type
    push r14                                                     ; internal argument 5: pointer to return value slot's type
    sub rsp, 020h                                                ; allocate shadow space
    mov r9, 000h                                                 ; internal argument 4: "this" pointer
    mov r8, 000h                                                 ; internal argument 3: "this" pointer type
    mov rdx, 000h                                                ; internal argument 2: closure pointer
    mov qword ptr [rsp + 040h], rcx                              ; move parameter count of throw value out of rcx
    mov rcx, 001h                                                ; internal argument 1: number of actual arguments
    call func$__print                                            ; jump to subroutine
    add rsp, 040h                                                ; release shadow space and arguments (result in stack pointer)
    ;  - exit(1)
    ; Call exit with 1 arguments
    push 001h                                                    ; value of argument #1 (1 (integer))
    push 019h                                                    ; type of argument #1 (Integer'25)
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
  func$throw$message$TypeMatch:                                  ; after block
  ; Line 14: __print(message);
  ; Call __print with 1 arguments
  push qword ptr [rbp + 040h]                                    ; value of argument #1 (message)
  push qword ptr [rbp + 038h]                                    ; type of argument #1
  lea r10, qword ptr [rsp + 020h]                                ; load address of return value's value
  push r10                                                       ; internal argument 6: pointer to return value slot's value
  lea r10, qword ptr [rsp + 020h]                                ; load address of return value's type
  push r10                                                       ; internal argument 5: pointer to return value slot's type
  sub rsp, 020h                                                  ; allocate shadow space
  mov r9, 000h                                                   ; internal argument 4: "this" pointer
  mov r8, 000h                                                   ; internal argument 3: "this" pointer type
  mov rdx, 000h                                                  ; internal argument 2: closure pointer
  mov qword ptr [rsp + 040h], rcx                                ; move parameter count of throw value out of rcx
  mov rcx, 001h                                                  ; internal argument 1: number of actual arguments
  call func$__print                                              ; jump to subroutine
  add rsp, 040h                                                  ; release shadow space and arguments (result in stack pointer)
  ; Line 15: __print('\n');
  ; Call __print with 1 arguments
  mov rbx, offset string                                         ; reading string for push
  push rbx                                                       ; value of argument #1 (string)
  push 01ah                                                      ; type of argument #1 (String'26)
  lea rsi, qword ptr [rsp + 020h]                                ; load address of return value's value
  push rsi                                                       ; internal argument 6: pointer to return value slot's value
  lea rsi, qword ptr [rsp + 020h]                                ; load address of return value's type
  push rsi                                                       ; internal argument 5: pointer to return value slot's type
  sub rsp, 020h                                                  ; allocate shadow space
  mov r9, 000h                                                   ; internal argument 4: "this" pointer
  mov r8, 000h                                                   ; internal argument 3: "this" pointer type
  mov rdx, 000h                                                  ; internal argument 2: closure pointer
  mov rcx, 001h                                                  ; internal argument 1: number of actual arguments
  call func$__print                                              ; jump to subroutine
  add rsp, 040h                                                  ; release shadow space and arguments (result in stack pointer)
  ; Line 16: exit(1);
  ; Call exit with 1 arguments
  push 001h                                                      ; value of argument #1 (1)
  push 019h                                                      ; type of argument #1 (Integer'25)
  lea rax, qword ptr [rsp + 020h]                                ; load address of return value's value
  push rax                                                       ; internal argument 6: pointer to return value slot's value
  lea rax, qword ptr [rsp + 020h]                                ; load address of return value's type
  push rax                                                       ; internal argument 5: pointer to return value slot's type
  sub rsp, 020h                                                  ; allocate shadow space
  mov r9, 000h                                                   ; internal argument 4: "this" pointer
  mov r8, 000h                                                   ; internal argument 3: "this" pointer type
  mov rdx, 000h                                                  ; internal argument 2: closure pointer
  mov rcx, 001h                                                  ; internal argument 1: number of actual arguments
  call func$exit                                                 ; jump to subroutine
  add rsp, 040h                                                  ; release shadow space and arguments (result in stack pointer)
  ; Implicit return from throw
  mov r14, qword ptr [rbp + 030h]                                ; get pointer to return value of throw into register to dereference it
  mov qword ptr [r14], 000h                                      ; throw return value
  mov r15, qword ptr [rbp + 028h]                                ; get pointer to return value type of throw into register to dereference it
  mov qword ptr [r15], 017h                                      ; type of throw return value (Null'23)
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
dq func$__getLastError$annotation
func$__getLastError:
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
  cmp rcx, 000h                                                  ; compare parameter count of __getLastError to 0 (integer)
  je func$__getLastError$parameterCountCheck$continuation        ; check number of parameters is as expected
    ; Error handling block for parameter count
    ;  - print(parameterCountCheckFailureMessage)
    ; Call __print with 1 arguments
    mov r10, offset parameterCountCheckFailureMessage            ; reading parameterCountCheckFailureMessage for push
    push r10                                                     ; value of argument #1 (parameterCountCheckFailureMessage)
    push 01ah                                                    ; type of argument #1 (String'26)
    lea rax, qword ptr [rsp + 028h]                              ; load address of return value's value
    push rax                                                     ; internal argument 6: pointer to return value slot's value
    lea rax, qword ptr [rsp + 028h]                              ; load address of return value's type
    push rax                                                     ; internal argument 5: pointer to return value slot's type
    sub rsp, 020h                                                ; allocate shadow space
    mov r9, 000h                                                 ; internal argument 4: "this" pointer
    mov r8, 000h                                                 ; internal argument 3: "this" pointer type
    mov rdx, 000h                                                ; internal argument 2: closure pointer
    mov qword ptr [rsp + 048h], rcx                              ; move parameter count of __getLastError value out of rcx
    mov rcx, 001h                                                ; internal argument 1: number of actual arguments
    call func$__print                                            ; jump to subroutine
    add rsp, 040h                                                ; release shadow space and arguments (result in stack pointer)
    ;  - exit(1)
    ; Call exit with 1 arguments
    push 001h                                                    ; value of argument #1 (1 (integer))
    push 019h                                                    ; type of argument #1 (Integer'25)
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
  func$__getLastError$parameterCountCheck$continuation:          ; end of parameter count check
  ; Calling GetLastError
  sub rsp, 020h                                                  ; allocate shadow space
  mov qword ptr [rsp + 038h], rcx                                ; move parameter count of __getLastError value out of rcx
  call GetLastError                                              ; calls GetLastError from kernel32.lib
  mov rsi, 019h                                                  ; return value of GetLastError system call is of type Integer'25
  add rsp, 020h                                                  ; release shadow space and arguments if there were more than four (result in stack pointer)
  cmp rsi, 000h                                                  ; compare type of return value of GetLastError system call to <sentinel>
  jne func$__getLastError$GetlasterrorReturnValue$TypeMatch      ; skip next block if return value of GetLastError system call is not sentinel
    ; Error handling block for __getLastError return value
    ;  - print(returnValueTypeCheckFailureMessage)
    ; Call __print with 1 arguments
    mov rdi, offset returnValueTypeCheckFailureMessage           ; reading returnValueTypeCheckFailureMessage for push
    push rdi                                                     ; value of argument #1 (returnValueTypeCheckFailureMessage)
    push 01ah                                                    ; type of argument #1 (String'26)
    lea r12, qword ptr [rsp + 020h]                              ; load address of return value's value
    push r12                                                     ; internal argument 6: pointer to return value slot's value
    lea r12, qword ptr [rsp + 020h]                              ; load address of return value's type
    push r12                                                     ; internal argument 5: pointer to return value slot's type
    sub rsp, 020h                                                ; allocate shadow space
    mov r9, 000h                                                 ; internal argument 4: "this" pointer
    mov r8, 000h                                                 ; internal argument 3: "this" pointer type
    mov rdx, 000h                                                ; internal argument 2: closure pointer
    mov rcx, 001h                                                ; internal argument 1: number of actual arguments
    mov qword ptr [rsp + 040h], rax                              ; move return value of GetLastError system call value out of rax
    call func$__print                                            ; jump to subroutine
    add rsp, 040h                                                ; release shadow space and arguments (result in stack pointer)
    ;  - exit(1)
    ; Call exit with 1 arguments
    push 001h                                                    ; value of argument #1 (1 (integer))
    push 019h                                                    ; type of argument #1 (Integer'25)
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
    mov rax, qword ptr [rsp + 000h]                              ; restoring slots to previous scope state
  func$__getLastError$GetlasterrorReturnValue$TypeMatch:         ; after block
  mov r14, qword ptr [rbp + 030h]                                ; get pointer to return value of __getLastError into register to dereference it
  mov qword ptr [r14], rax                                       ; __getLastError return value
  mov r15, qword ptr [rbp + 028h]                                ; get pointer to return value type of __getLastError into register to dereference it
  mov qword ptr [r15], rsi                                       ; type of __getLastError return value
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

; __getProcessHeap
dq func$__getProcessHeap$annotation
func$__getProcessHeap:
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
  cmp rcx, 000h                                                  ; compare parameter count of __getProcessHeap to 0 (integer)
  je func$__getProcessHeap$parameterCountCheck$continuation      ; check number of parameters is as expected
    ; Error handling block for parameter count
    ;  - print(parameterCountCheckFailureMessage)
    ; Call __print with 1 arguments
    mov r10, offset parameterCountCheckFailureMessage            ; reading parameterCountCheckFailureMessage for push
    push r10                                                     ; value of argument #1 (parameterCountCheckFailureMessage)
    push 01ah                                                    ; type of argument #1 (String'26)
    lea rax, qword ptr [rsp + 028h]                              ; load address of return value's value
    push rax                                                     ; internal argument 6: pointer to return value slot's value
    lea rax, qword ptr [rsp + 028h]                              ; load address of return value's type
    push rax                                                     ; internal argument 5: pointer to return value slot's type
    sub rsp, 020h                                                ; allocate shadow space
    mov r9, 000h                                                 ; internal argument 4: "this" pointer
    mov r8, 000h                                                 ; internal argument 3: "this" pointer type
    mov rdx, 000h                                                ; internal argument 2: closure pointer
    mov qword ptr [rsp + 048h], rcx                              ; move parameter count of __getProcessHeap value out of rcx
    mov rcx, 001h                                                ; internal argument 1: number of actual arguments
    call func$__print                                            ; jump to subroutine
    add rsp, 040h                                                ; release shadow space and arguments (result in stack pointer)
    ;  - exit(1)
    ; Call exit with 1 arguments
    push 001h                                                    ; value of argument #1 (1 (integer))
    push 019h                                                    ; type of argument #1 (Integer'25)
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
  func$__getProcessHeap$parameterCountCheck$continuation:        ; end of parameter count check
  ; Calling GetProcessHeap
  sub rsp, 020h                                                  ; allocate shadow space
  mov qword ptr [rsp + 038h], rcx                                ; move parameter count of __getProcessHeap value out of rcx
  call GetProcessHeap                                            ; calls GetProcessHeap from kernel32.lib
  mov rsi, 019h                                                  ; return value of GetProcessHeap system call is of type Integer'25
  add rsp, 020h                                                  ; release shadow space and arguments if there were more than four (result in stack pointer)
  cmp rsi, 000h                                                  ; compare type of return value of GetProcessHeap system call to <sentinel>
  jne func$__getProcessHeap$GetprocessheapReturnValue$TypeMatch  ; skip next block if return value of GetProcessHeap system call is not sentinel
    ; Error handling block for __getProcessHeap return value
    ;  - print(returnValueTypeCheckFailureMessage)
    ; Call __print with 1 arguments
    mov rdi, offset returnValueTypeCheckFailureMessage           ; reading returnValueTypeCheckFailureMessage for push
    push rdi                                                     ; value of argument #1 (returnValueTypeCheckFailureMessage)
    push 01ah                                                    ; type of argument #1 (String'26)
    lea r12, qword ptr [rsp + 020h]                              ; load address of return value's value
    push r12                                                     ; internal argument 6: pointer to return value slot's value
    lea r12, qword ptr [rsp + 020h]                              ; load address of return value's type
    push r12                                                     ; internal argument 5: pointer to return value slot's type
    sub rsp, 020h                                                ; allocate shadow space
    mov r9, 000h                                                 ; internal argument 4: "this" pointer
    mov r8, 000h                                                 ; internal argument 3: "this" pointer type
    mov rdx, 000h                                                ; internal argument 2: closure pointer
    mov rcx, 001h                                                ; internal argument 1: number of actual arguments
    mov qword ptr [rsp + 040h], rax                              ; move return value of GetProcessHeap system call value out of rax
    call func$__print                                            ; jump to subroutine
    add rsp, 040h                                                ; release shadow space and arguments (result in stack pointer)
    ;  - exit(1)
    ; Call exit with 1 arguments
    push 001h                                                    ; value of argument #1 (1 (integer))
    push 019h                                                    ; type of argument #1 (Integer'25)
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
    mov rax, qword ptr [rsp + 000h]                              ; restoring slots to previous scope state
  func$__getProcessHeap$GetprocessheapReturnValue$TypeMatch:     ; after block
  mov r14, qword ptr [rbp + 030h]                                ; get pointer to return value of __getProcessHeap into register to dereference it
  mov qword ptr [r14], rax                                       ; __getProcessHeap return value
  mov r15, qword ptr [rbp + 028h]                                ; get pointer to return value type of __getProcessHeap into register to dereference it
  mov qword ptr [r15], rsi                                       ; type of __getProcessHeap return value
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

; __heapAlloc
dq func$__heapAlloc$annotation
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
  sub rsp, 028h                                                  ; allocate space for stack
  lea rbp, qword ptr [rsp + 068h]                                ; set up frame pointer
  ; Check parameter count
  cmp rcx, 003h                                                  ; compare parameter count of __heapAlloc to 3 (integer)
  je func$__heapAlloc$parameterCountCheck$continuation           ; check number of parameters is as expected
    ; Error handling block for parameter count
    ;  - print(parameterCountCheckFailureMessage)
    ; Call __print with 1 arguments
    mov r10, offset parameterCountCheckFailureMessage            ; reading parameterCountCheckFailureMessage for push
    push r10                                                     ; value of argument #1 (parameterCountCheckFailureMessage)
    push 01ah                                                    ; type of argument #1 (String'26)
    lea rax, qword ptr [rsp + 028h]                              ; load address of return value's value
    push rax                                                     ; internal argument 6: pointer to return value slot's value
    lea rax, qword ptr [rsp + 028h]                              ; load address of return value's type
    push rax                                                     ; internal argument 5: pointer to return value slot's type
    sub rsp, 020h                                                ; allocate shadow space
    mov r9, 000h                                                 ; internal argument 4: "this" pointer
    mov r8, 000h                                                 ; internal argument 3: "this" pointer type
    mov rdx, 000h                                                ; internal argument 2: closure pointer
    mov qword ptr [rsp + 048h], rcx                              ; move parameter count of __heapAlloc value out of rcx
    mov rcx, 001h                                                ; internal argument 1: number of actual arguments
    call func$__print                                            ; jump to subroutine
    add rsp, 040h                                                ; release shadow space and arguments (result in stack pointer)
    ;  - exit(1)
    ; Call exit with 1 arguments
    push 001h                                                    ; value of argument #1 (1 (integer))
    push 019h                                                    ; type of argument #1 (Integer'25)
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
  func$__heapAlloc$parameterCountCheck$continuation:             ; end of parameter count check
  ; Check type of parameter 0, hHeap (expecting Integer)
  mov rsi, qword ptr [rbp + 038h]                                ; move type of hHeap to testByte
  mov rax, rsi                                                   ; move testByte to testByte
  mov rdi, 002h                                                  ; read operand of mul (type table width in bytes) 
  mul rdi                                                        ; adjust to the relative start of that type's entry in the type table
  mov r12, offset typeTable                                      ; read second operand of + (type table pointer)
  add rax, r12                                                   ; finally offset all of that by the start of the type table itself (result in testByte)
  bt qword ptr [rax], 002h                                       ; check that hHeap is Integer
  jc func$__heapAlloc$hheap$TypeMatch                            ; skip next block if the type matches
    ; Error handling block for hHeap
    ;  - print(parameterTypeCheckFailureMessage)
    ; Call __print with 1 arguments
    mov r13, offset parameterTypeCheckFailureMessage             ; reading parameterTypeCheckFailureMessage for push
    push r13                                                     ; value of argument #1 (parameterTypeCheckFailureMessage)
    push 01ah                                                    ; type of argument #1 (String'26)
    lea r14, qword ptr [rsp + 028h]                              ; load address of return value's value
    push r14                                                     ; internal argument 6: pointer to return value slot's value
    lea r14, qword ptr [rsp + 028h]                              ; load address of return value's type
    push r14                                                     ; internal argument 5: pointer to return value slot's type
    sub rsp, 020h                                                ; allocate shadow space
    mov r9, 000h                                                 ; internal argument 4: "this" pointer
    mov r8, 000h                                                 ; internal argument 3: "this" pointer type
    mov rdx, 000h                                                ; internal argument 2: closure pointer
    mov qword ptr [rsp + 048h], rcx                              ; move parameter count of __heapAlloc value out of rcx
    mov rcx, 001h                                                ; internal argument 1: number of actual arguments
    call func$__print                                            ; jump to subroutine
    add rsp, 040h                                                ; release shadow space and arguments (result in stack pointer)
    ;  - exit(1)
    ; Call exit with 1 arguments
    push 001h                                                    ; value of argument #1 (1 (integer))
    push 019h                                                    ; type of argument #1 (Integer'25)
    lea r15, qword ptr [rsp + 028h]                              ; load address of return value's value
    push r15                                                     ; internal argument 6: pointer to return value slot's value
    lea r15, qword ptr [rsp + 028h]                              ; load address of return value's type
    push r15                                                     ; internal argument 5: pointer to return value slot's type
    sub rsp, 020h                                                ; allocate shadow space
    mov r9, 000h                                                 ; internal argument 4: "this" pointer
    mov r8, 000h                                                 ; internal argument 3: "this" pointer type
    mov rdx, 000h                                                ; internal argument 2: closure pointer
    mov rcx, 001h                                                ; internal argument 1: number of actual arguments
    call func$exit                                               ; jump to subroutine
    add rsp, 040h                                                ; release shadow space and arguments (result in stack pointer)
    mov rcx, qword ptr [rsp + 008h]                              ; restoring slots to previous scope state
  func$__heapAlloc$hheap$TypeMatch:                              ; after block
  ; Check type of parameter 1, dwFlags (expecting Integer)
  mov r10, qword ptr [rbp + 048h]                                ; move type of dwFlags to testByte
  mov rax, r10                                                   ; move testByte to testByte
  mov rbx, 002h                                                  ; read operand of mul (type table width in bytes) 
  mul rbx                                                        ; adjust to the relative start of that type's entry in the type table
  mov rsi, offset typeTable                                      ; read second operand of + (type table pointer)
  add rax, rsi                                                   ; finally offset all of that by the start of the type table itself (result in testByte)
  bt qword ptr [rax], 002h                                       ; check that dwFlags is Integer
  jc func$__heapAlloc$dwflags$TypeMatch                          ; skip next block if the type matches
    ; Error handling block for dwFlags
    ;  - print(parameterTypeCheckFailureMessage)
    ; Call __print with 1 arguments
    mov rdi, offset parameterTypeCheckFailureMessage             ; reading parameterTypeCheckFailureMessage for push
    push rdi                                                     ; value of argument #1 (parameterTypeCheckFailureMessage)
    push 01ah                                                    ; type of argument #1 (String'26)
    lea r12, qword ptr [rsp + 028h]                              ; load address of return value's value
    push r12                                                     ; internal argument 6: pointer to return value slot's value
    lea r12, qword ptr [rsp + 028h]                              ; load address of return value's type
    push r12                                                     ; internal argument 5: pointer to return value slot's type
    sub rsp, 020h                                                ; allocate shadow space
    mov r9, 000h                                                 ; internal argument 4: "this" pointer
    mov r8, 000h                                                 ; internal argument 3: "this" pointer type
    mov rdx, 000h                                                ; internal argument 2: closure pointer
    mov qword ptr [rsp + 048h], rcx                              ; move parameter count of __heapAlloc value out of rcx
    mov rcx, 001h                                                ; internal argument 1: number of actual arguments
    call func$__print                                            ; jump to subroutine
    add rsp, 040h                                                ; release shadow space and arguments (result in stack pointer)
    ;  - exit(1)
    ; Call exit with 1 arguments
    push 001h                                                    ; value of argument #1 (1 (integer))
    push 019h                                                    ; type of argument #1 (Integer'25)
    lea r13, qword ptr [rsp + 028h]                              ; load address of return value's value
    push r13                                                     ; internal argument 6: pointer to return value slot's value
    lea r13, qword ptr [rsp + 028h]                              ; load address of return value's type
    push r13                                                     ; internal argument 5: pointer to return value slot's type
    sub rsp, 020h                                                ; allocate shadow space
    mov r9, 000h                                                 ; internal argument 4: "this" pointer
    mov r8, 000h                                                 ; internal argument 3: "this" pointer type
    mov rdx, 000h                                                ; internal argument 2: closure pointer
    mov rcx, 001h                                                ; internal argument 1: number of actual arguments
    call func$exit                                               ; jump to subroutine
    add rsp, 040h                                                ; release shadow space and arguments (result in stack pointer)
    mov rcx, qword ptr [rsp + 008h]                              ; restoring slots to previous scope state
  func$__heapAlloc$dwflags$TypeMatch:                            ; after block
  ; Check type of parameter 2, dwBytes (expecting Integer)
  mov r14, qword ptr [rbp + 058h]                                ; move type of dwBytes to testByte
  mov rax, r14                                                   ; move testByte to testByte
  mov r15, 002h                                                  ; read operand of mul (type table width in bytes) 
  mul r15                                                        ; adjust to the relative start of that type's entry in the type table
  mov r10, offset typeTable                                      ; read second operand of + (type table pointer)
  add rax, r10                                                   ; finally offset all of that by the start of the type table itself (result in testByte)
  bt qword ptr [rax], 002h                                       ; check that dwBytes is Integer
  jc func$__heapAlloc$dwbytes$TypeMatch                          ; skip next block if the type matches
    ; Error handling block for dwBytes
    ;  - print(parameterTypeCheckFailureMessage)
    ; Call __print with 1 arguments
    mov rbx, offset parameterTypeCheckFailureMessage             ; reading parameterTypeCheckFailureMessage for push
    push rbx                                                     ; value of argument #1 (parameterTypeCheckFailureMessage)
    push 01ah                                                    ; type of argument #1 (String'26)
    lea rsi, qword ptr [rsp + 028h]                              ; load address of return value's value
    push rsi                                                     ; internal argument 6: pointer to return value slot's value
    lea rsi, qword ptr [rsp + 028h]                              ; load address of return value's type
    push rsi                                                     ; internal argument 5: pointer to return value slot's type
    sub rsp, 020h                                                ; allocate shadow space
    mov r9, 000h                                                 ; internal argument 4: "this" pointer
    mov r8, 000h                                                 ; internal argument 3: "this" pointer type
    mov rdx, 000h                                                ; internal argument 2: closure pointer
    mov qword ptr [rsp + 048h], rcx                              ; move parameter count of __heapAlloc value out of rcx
    mov rcx, 001h                                                ; internal argument 1: number of actual arguments
    call func$__print                                            ; jump to subroutine
    add rsp, 040h                                                ; release shadow space and arguments (result in stack pointer)
    ;  - exit(1)
    ; Call exit with 1 arguments
    push 001h                                                    ; value of argument #1 (1 (integer))
    push 019h                                                    ; type of argument #1 (Integer'25)
    lea rdi, qword ptr [rsp + 028h]                              ; load address of return value's value
    push rdi                                                     ; internal argument 6: pointer to return value slot's value
    lea rdi, qword ptr [rsp + 028h]                              ; load address of return value's type
    push rdi                                                     ; internal argument 5: pointer to return value slot's type
    sub rsp, 020h                                                ; allocate shadow space
    mov r9, 000h                                                 ; internal argument 4: "this" pointer
    mov r8, 000h                                                 ; internal argument 3: "this" pointer type
    mov rdx, 000h                                                ; internal argument 2: closure pointer
    mov rcx, 001h                                                ; internal argument 1: number of actual arguments
    call func$exit                                               ; jump to subroutine
    add rsp, 040h                                                ; release shadow space and arguments (result in stack pointer)
    mov rcx, qword ptr [rsp + 008h]                              ; restoring slots to previous scope state
  func$__heapAlloc$dwbytes$TypeMatch:                            ; after block
  ; Calling HeapAlloc
  sub rsp, 020h                                                  ; allocate shadow space
  mov r8, qword ptr [rbp + 060h]                                 ; argument #3
  mov rdx, qword ptr [rbp + 050h]                                ; argument #2
  mov qword ptr [rsp + 038h], rcx                                ; move parameter count of __heapAlloc value out of rcx
  mov rcx, qword ptr [rbp + 040h]                                ; argument #1
  call HeapAlloc                                                 ; calls HeapAlloc from kernel32.lib
  mov r12, 019h                                                  ; return value of HeapAlloc system call is of type Integer'25
  add rsp, 020h                                                  ; release shadow space and arguments if there were more than four (result in stack pointer)
  cmp r12, 000h                                                  ; compare type of return value of HeapAlloc system call to <sentinel>
  jne func$__heapAlloc$HeapallocReturnValue$TypeMatch            ; skip next block if return value of HeapAlloc system call is not sentinel
    ; Error handling block for __heapAlloc return value
    ;  - print(returnValueTypeCheckFailureMessage)
    ; Call __print with 1 arguments
    mov r13, offset returnValueTypeCheckFailureMessage           ; reading returnValueTypeCheckFailureMessage for push
    push r13                                                     ; value of argument #1 (returnValueTypeCheckFailureMessage)
    push 01ah                                                    ; type of argument #1 (String'26)
    lea r14, qword ptr [rsp + 020h]                              ; load address of return value's value
    push r14                                                     ; internal argument 6: pointer to return value slot's value
    lea r14, qword ptr [rsp + 020h]                              ; load address of return value's type
    push r14                                                     ; internal argument 5: pointer to return value slot's type
    sub rsp, 020h                                                ; allocate shadow space
    mov r9, 000h                                                 ; internal argument 4: "this" pointer
    mov r8, 000h                                                 ; internal argument 3: "this" pointer type
    mov rdx, 000h                                                ; internal argument 2: closure pointer
    mov rcx, 001h                                                ; internal argument 1: number of actual arguments
    mov qword ptr [rsp + 040h], rax                              ; move return value of HeapAlloc system call value out of rax
    call func$__print                                            ; jump to subroutine
    add rsp, 040h                                                ; release shadow space and arguments (result in stack pointer)
    ;  - exit(1)
    ; Call exit with 1 arguments
    push 001h                                                    ; value of argument #1 (1 (integer))
    push 019h                                                    ; type of argument #1 (Integer'25)
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
    mov rax, qword ptr [rsp + 000h]                              ; restoring slots to previous scope state
  func$__heapAlloc$HeapallocReturnValue$TypeMatch:               ; after block
  mov r10, qword ptr [rbp + 030h]                                ; get pointer to return value of __heapAlloc into register to dereference it
  mov qword ptr [r10], rax                                       ; __heapAlloc return value
  mov rbx, qword ptr [rbp + 028h]                                ; get pointer to return value type of __heapAlloc into register to dereference it
  mov qword ptr [rbx], r12                                       ; type of __heapAlloc return value
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

; _alloc
dq func$_alloc$annotation
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
  sub rsp, 030h                                                  ; allocate space for stack
  lea rbp, qword ptr [rsp + 070h]                                ; set up frame pointer
  ; Check parameter count
  cmp rcx, 001h                                                  ; compare parameter count of _alloc to 1 (integer)
  je func$_alloc$parameterCountCheck$continuation                ; check number of parameters is as expected
    ; Error handling block for parameter count
    ;  - print(parameterCountCheckFailureMessage)
    ; Call __print with 1 arguments
    mov r10, offset parameterCountCheckFailureMessage            ; reading parameterCountCheckFailureMessage for push
    push r10                                                     ; value of argument #1 (parameterCountCheckFailureMessage)
    push 01ah                                                    ; type of argument #1 (String'26)
    lea rax, qword ptr [rsp + 030h]                              ; load address of return value's value
    push rax                                                     ; internal argument 6: pointer to return value slot's value
    lea rax, qword ptr [rsp + 030h]                              ; load address of return value's type
    push rax                                                     ; internal argument 5: pointer to return value slot's type
    sub rsp, 020h                                                ; allocate shadow space
    mov r9, 000h                                                 ; internal argument 4: "this" pointer
    mov r8, 000h                                                 ; internal argument 3: "this" pointer type
    mov rdx, 000h                                                ; internal argument 2: closure pointer
    mov qword ptr [rsp + 050h], rcx                              ; move parameter count of _alloc value out of rcx
    mov rcx, 001h                                                ; internal argument 1: number of actual arguments
    call func$__print                                            ; jump to subroutine
    add rsp, 040h                                                ; release shadow space and arguments (result in stack pointer)
    ;  - exit(1)
    ; Call exit with 1 arguments
    push 001h                                                    ; value of argument #1 (1 (integer))
    push 019h                                                    ; type of argument #1 (Integer'25)
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
  func$_alloc$parameterCountCheck$continuation:                  ; end of parameter count check
  ; Check type of parameter 0, size (expecting Integer)
  mov rsi, qword ptr [rbp + 038h]                                ; move type of size to testByte
  mov rax, rsi                                                   ; move testByte to testByte
  mov rdi, 002h                                                  ; read operand of mul (type table width in bytes) 
  mul rdi                                                        ; adjust to the relative start of that type's entry in the type table
  mov r12, offset typeTable                                      ; read second operand of + (type table pointer)
  add rax, r12                                                   ; finally offset all of that by the start of the type table itself (result in testByte)
  bt qword ptr [rax], 002h                                       ; check that size is Integer
  jc func$_alloc$size$TypeMatch                                  ; skip next block if the type matches
    ; Error handling block for size
    ;  - print(parameterTypeCheckFailureMessage)
    ; Call __print with 1 arguments
    mov r13, offset parameterTypeCheckFailureMessage             ; reading parameterTypeCheckFailureMessage for push
    push r13                                                     ; value of argument #1 (parameterTypeCheckFailureMessage)
    push 01ah                                                    ; type of argument #1 (String'26)
    lea r14, qword ptr [rsp + 030h]                              ; load address of return value's value
    push r14                                                     ; internal argument 6: pointer to return value slot's value
    lea r14, qword ptr [rsp + 030h]                              ; load address of return value's type
    push r14                                                     ; internal argument 5: pointer to return value slot's type
    sub rsp, 020h                                                ; allocate shadow space
    mov r9, 000h                                                 ; internal argument 4: "this" pointer
    mov r8, 000h                                                 ; internal argument 3: "this" pointer type
    mov rdx, 000h                                                ; internal argument 2: closure pointer
    mov qword ptr [rsp + 050h], rcx                              ; move parameter count of _alloc value out of rcx
    mov rcx, 001h                                                ; internal argument 1: number of actual arguments
    call func$__print                                            ; jump to subroutine
    add rsp, 040h                                                ; release shadow space and arguments (result in stack pointer)
    ;  - exit(1)
    ; Call exit with 1 arguments
    push 001h                                                    ; value of argument #1 (1 (integer))
    push 019h                                                    ; type of argument #1 (Integer'25)
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
  func$_alloc$size$TypeMatch:                                    ; after block
  ; Line 33: _blockCount += 1;
  cmp qword ptr _blockCountType, 000h                            ; compare type of _blockCount variable to <sentinel>
  jne func$_alloc$BlockcountVariable$TypeMatch                   ; skip next block if _blockCount variable is not sentinel
    ; Error handling block for _blockCount variable
    ;  - print(operandTypeCheckFailureMessage)
    ; Call __print with 1 arguments
    mov r10, offset operandTypeCheckFailureMessage               ; reading operandTypeCheckFailureMessage for push
    push r10                                                     ; value of argument #1 (operandTypeCheckFailureMessage)
    push 01ah                                                    ; type of argument #1 (String'26)
    lea rbx, qword ptr [rsp + 030h]                              ; load address of return value's value
    push rbx                                                     ; internal argument 6: pointer to return value slot's value
    lea rbx, qword ptr [rsp + 030h]                              ; load address of return value's type
    push rbx                                                     ; internal argument 5: pointer to return value slot's type
    sub rsp, 020h                                                ; allocate shadow space
    mov r9, 000h                                                 ; internal argument 4: "this" pointer
    mov r8, 000h                                                 ; internal argument 3: "this" pointer type
    mov rdx, 000h                                                ; internal argument 2: closure pointer
    mov qword ptr [rsp + 050h], rcx                              ; move parameter count of _alloc value out of rcx
    mov rcx, 001h                                                ; internal argument 1: number of actual arguments
    call func$__print                                            ; jump to subroutine
    add rsp, 040h                                                ; release shadow space and arguments (result in stack pointer)
    ;  - exit(1)
    ; Call exit with 1 arguments
    push 001h                                                    ; value of argument #1 (1 (integer))
    push 019h                                                    ; type of argument #1 (Integer'25)
    lea rsi, qword ptr [rsp + 030h]                              ; load address of return value's value
    push rsi                                                     ; internal argument 6: pointer to return value slot's value
    lea rsi, qword ptr [rsp + 030h]                              ; load address of return value's type
    push rsi                                                     ; internal argument 5: pointer to return value slot's type
    sub rsp, 020h                                                ; allocate shadow space
    mov r9, 000h                                                 ; internal argument 4: "this" pointer
    mov r8, 000h                                                 ; internal argument 3: "this" pointer type
    mov rdx, 000h                                                ; internal argument 2: closure pointer
    mov rcx, 001h                                                ; internal argument 1: number of actual arguments
    call func$exit                                               ; jump to subroutine
    add rsp, 040h                                                ; release shadow space and arguments (result in stack pointer)
    mov rcx, qword ptr [rsp + 010h]                              ; restoring slots to previous scope state
  func$_alloc$BlockcountVariable$TypeMatch:                      ; after block
  mov r13, qword ptr _blockCountValue                            ; assign value of _blockCount variable to value of += operator result
  add r13, 001h                                                  ; += operator
  mov r14, 019h                                                  ; += operator result is of type Integer'25
  mov qword ptr _blockCountValue, r13                            ; store value
  mov qword ptr _blockCountType, r14                             ; store type
  ; Line 34: return __heapAlloc(_heapHandle, 0, size);
  ; Call __heapAlloc with 3 arguments
  push qword ptr [rbp + 040h]                                    ; value of argument #3 (size)
  push qword ptr [rbp + 038h]                                    ; type of argument #3
  push 000h                                                      ; value of argument #2 (0)
  push 019h                                                      ; type of argument #2 (Integer'25)
  push qword ptr _heapHandleValue                                ; value of argument #1 (_heapHandle variable)
  push qword ptr _heapHandleType                                 ; type of argument #1
  lea r15, qword ptr [rsp + 050h]                                ; load address of return value's value
  push r15                                                       ; internal argument 6: pointer to return value slot's value
  lea r15, qword ptr [rsp + 050h]                                ; load address of return value's type
  push r15                                                       ; internal argument 5: pointer to return value slot's type
  sub rsp, 020h                                                  ; allocate shadow space
  mov r9, 000h                                                   ; internal argument 4: "this" pointer
  mov r8, 000h                                                   ; internal argument 3: "this" pointer type
  mov rdx, 000h                                                  ; internal argument 2: closure pointer
  mov qword ptr [rsp + 070h], rcx                                ; move parameter count of _alloc value out of rcx
  mov rcx, 003h                                                  ; internal argument 1: number of actual arguments
  call func$__heapAlloc                                          ; jump to subroutine
  add rsp, 060h                                                  ; release shadow space and arguments (result in stack pointer)
  cmp qword ptr [rsp + 018h], 000h                               ; compare type of __heapAlloc return value to <sentinel>
  jne func$_alloc$AllocReturnValue$TypeMatch                     ; skip next block if __heapAlloc return value is not sentinel
    ; Error handling block for _alloc return value
    ;  - print(returnValueTypeCheckFailureMessage)
    ; Call __print with 1 arguments
    mov r10, offset returnValueTypeCheckFailureMessage           ; reading returnValueTypeCheckFailureMessage for push
    push r10                                                     ; value of argument #1 (returnValueTypeCheckFailureMessage)
    push 01ah                                                    ; type of argument #1 (String'26)
    lea rbx, qword ptr [rsp + 018h]                              ; load address of return value's value
    push rbx                                                     ; internal argument 6: pointer to return value slot's value
    lea rbx, qword ptr [rsp + 018h]                              ; load address of return value's type
    push rbx                                                     ; internal argument 5: pointer to return value slot's type
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
    push 019h                                                    ; type of argument #1 (Integer'25)
    lea rsi, qword ptr [rsp + 018h]                              ; load address of return value's value
    push rsi                                                     ; internal argument 6: pointer to return value slot's value
    lea rsi, qword ptr [rsp + 018h]                              ; load address of return value's type
    push rsi                                                     ; internal argument 5: pointer to return value slot's type
    sub rsp, 020h                                                ; allocate shadow space
    mov r9, 000h                                                 ; internal argument 4: "this" pointer
    mov r8, 000h                                                 ; internal argument 3: "this" pointer type
    mov rdx, 000h                                                ; internal argument 2: closure pointer
    mov rcx, 001h                                                ; internal argument 1: number of actual arguments
    call func$exit                                               ; jump to subroutine
    add rsp, 040h                                                ; release shadow space and arguments (result in stack pointer)
  func$_alloc$AllocReturnValue$TypeMatch:                        ; after block
  mov rax, qword ptr [rsp + 020h]                                ; read second operand of mov (__heapAlloc return value) for MoveToDerefInstruction
  mov rdi, qword ptr [rbp + 030h]                                ; get pointer to return value of _alloc into register to dereference it
  mov qword ptr [rdi], rax                                       ; _alloc return value
  mov r12, qword ptr [rsp + 018h]                                ; reading type of __heapAlloc return value
  mov r13, qword ptr [rbp + 028h]                                ; get pointer to return value type of _alloc into register to dereference it
  mov qword ptr [r13], r12                                       ; type of _alloc return value
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

; __heapFree
dq func$__heapFree$annotation
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
  sub rsp, 028h                                                  ; allocate space for stack
  lea rbp, qword ptr [rsp + 068h]                                ; set up frame pointer
  ; Check parameter count
  cmp rcx, 003h                                                  ; compare parameter count of __heapFree to 3 (integer)
  je func$__heapFree$parameterCountCheck$continuation            ; check number of parameters is as expected
    ; Error handling block for parameter count
    ;  - print(parameterCountCheckFailureMessage)
    ; Call __print with 1 arguments
    mov r10, offset parameterCountCheckFailureMessage            ; reading parameterCountCheckFailureMessage for push
    push r10                                                     ; value of argument #1 (parameterCountCheckFailureMessage)
    push 01ah                                                    ; type of argument #1 (String'26)
    lea rax, qword ptr [rsp + 028h]                              ; load address of return value's value
    push rax                                                     ; internal argument 6: pointer to return value slot's value
    lea rax, qword ptr [rsp + 028h]                              ; load address of return value's type
    push rax                                                     ; internal argument 5: pointer to return value slot's type
    sub rsp, 020h                                                ; allocate shadow space
    mov r9, 000h                                                 ; internal argument 4: "this" pointer
    mov r8, 000h                                                 ; internal argument 3: "this" pointer type
    mov rdx, 000h                                                ; internal argument 2: closure pointer
    mov qword ptr [rsp + 048h], rcx                              ; move parameter count of __heapFree value out of rcx
    mov rcx, 001h                                                ; internal argument 1: number of actual arguments
    call func$__print                                            ; jump to subroutine
    add rsp, 040h                                                ; release shadow space and arguments (result in stack pointer)
    ;  - exit(1)
    ; Call exit with 1 arguments
    push 001h                                                    ; value of argument #1 (1 (integer))
    push 019h                                                    ; type of argument #1 (Integer'25)
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
  func$__heapFree$parameterCountCheck$continuation:              ; end of parameter count check
  ; Check type of parameter 0, hHeap (expecting Integer)
  mov rsi, qword ptr [rbp + 038h]                                ; move type of hHeap to testByte
  mov rax, rsi                                                   ; move testByte to testByte
  mov rdi, 002h                                                  ; read operand of mul (type table width in bytes) 
  mul rdi                                                        ; adjust to the relative start of that type's entry in the type table
  mov r12, offset typeTable                                      ; read second operand of + (type table pointer)
  add rax, r12                                                   ; finally offset all of that by the start of the type table itself (result in testByte)
  bt qword ptr [rax], 002h                                       ; check that hHeap is Integer
  jc func$__heapFree$hheap$TypeMatch                             ; skip next block if the type matches
    ; Error handling block for hHeap
    ;  - print(parameterTypeCheckFailureMessage)
    ; Call __print with 1 arguments
    mov r13, offset parameterTypeCheckFailureMessage             ; reading parameterTypeCheckFailureMessage for push
    push r13                                                     ; value of argument #1 (parameterTypeCheckFailureMessage)
    push 01ah                                                    ; type of argument #1 (String'26)
    lea r14, qword ptr [rsp + 028h]                              ; load address of return value's value
    push r14                                                     ; internal argument 6: pointer to return value slot's value
    lea r14, qword ptr [rsp + 028h]                              ; load address of return value's type
    push r14                                                     ; internal argument 5: pointer to return value slot's type
    sub rsp, 020h                                                ; allocate shadow space
    mov r9, 000h                                                 ; internal argument 4: "this" pointer
    mov r8, 000h                                                 ; internal argument 3: "this" pointer type
    mov rdx, 000h                                                ; internal argument 2: closure pointer
    mov qword ptr [rsp + 048h], rcx                              ; move parameter count of __heapFree value out of rcx
    mov rcx, 001h                                                ; internal argument 1: number of actual arguments
    call func$__print                                            ; jump to subroutine
    add rsp, 040h                                                ; release shadow space and arguments (result in stack pointer)
    ;  - exit(1)
    ; Call exit with 1 arguments
    push 001h                                                    ; value of argument #1 (1 (integer))
    push 019h                                                    ; type of argument #1 (Integer'25)
    lea r15, qword ptr [rsp + 028h]                              ; load address of return value's value
    push r15                                                     ; internal argument 6: pointer to return value slot's value
    lea r15, qword ptr [rsp + 028h]                              ; load address of return value's type
    push r15                                                     ; internal argument 5: pointer to return value slot's type
    sub rsp, 020h                                                ; allocate shadow space
    mov r9, 000h                                                 ; internal argument 4: "this" pointer
    mov r8, 000h                                                 ; internal argument 3: "this" pointer type
    mov rdx, 000h                                                ; internal argument 2: closure pointer
    mov rcx, 001h                                                ; internal argument 1: number of actual arguments
    call func$exit                                               ; jump to subroutine
    add rsp, 040h                                                ; release shadow space and arguments (result in stack pointer)
    mov rcx, qword ptr [rsp + 008h]                              ; restoring slots to previous scope state
  func$__heapFree$hheap$TypeMatch:                               ; after block
  ; Check type of parameter 1, dwFlags (expecting Integer)
  mov r10, qword ptr [rbp + 048h]                                ; move type of dwFlags to testByte
  mov rax, r10                                                   ; move testByte to testByte
  mov rbx, 002h                                                  ; read operand of mul (type table width in bytes) 
  mul rbx                                                        ; adjust to the relative start of that type's entry in the type table
  mov rsi, offset typeTable                                      ; read second operand of + (type table pointer)
  add rax, rsi                                                   ; finally offset all of that by the start of the type table itself (result in testByte)
  bt qword ptr [rax], 002h                                       ; check that dwFlags is Integer
  jc func$__heapFree$dwflags$TypeMatch                           ; skip next block if the type matches
    ; Error handling block for dwFlags
    ;  - print(parameterTypeCheckFailureMessage)
    ; Call __print with 1 arguments
    mov rdi, offset parameterTypeCheckFailureMessage             ; reading parameterTypeCheckFailureMessage for push
    push rdi                                                     ; value of argument #1 (parameterTypeCheckFailureMessage)
    push 01ah                                                    ; type of argument #1 (String'26)
    lea r12, qword ptr [rsp + 028h]                              ; load address of return value's value
    push r12                                                     ; internal argument 6: pointer to return value slot's value
    lea r12, qword ptr [rsp + 028h]                              ; load address of return value's type
    push r12                                                     ; internal argument 5: pointer to return value slot's type
    sub rsp, 020h                                                ; allocate shadow space
    mov r9, 000h                                                 ; internal argument 4: "this" pointer
    mov r8, 000h                                                 ; internal argument 3: "this" pointer type
    mov rdx, 000h                                                ; internal argument 2: closure pointer
    mov qword ptr [rsp + 048h], rcx                              ; move parameter count of __heapFree value out of rcx
    mov rcx, 001h                                                ; internal argument 1: number of actual arguments
    call func$__print                                            ; jump to subroutine
    add rsp, 040h                                                ; release shadow space and arguments (result in stack pointer)
    ;  - exit(1)
    ; Call exit with 1 arguments
    push 001h                                                    ; value of argument #1 (1 (integer))
    push 019h                                                    ; type of argument #1 (Integer'25)
    lea r13, qword ptr [rsp + 028h]                              ; load address of return value's value
    push r13                                                     ; internal argument 6: pointer to return value slot's value
    lea r13, qword ptr [rsp + 028h]                              ; load address of return value's type
    push r13                                                     ; internal argument 5: pointer to return value slot's type
    sub rsp, 020h                                                ; allocate shadow space
    mov r9, 000h                                                 ; internal argument 4: "this" pointer
    mov r8, 000h                                                 ; internal argument 3: "this" pointer type
    mov rdx, 000h                                                ; internal argument 2: closure pointer
    mov rcx, 001h                                                ; internal argument 1: number of actual arguments
    call func$exit                                               ; jump to subroutine
    add rsp, 040h                                                ; release shadow space and arguments (result in stack pointer)
    mov rcx, qword ptr [rsp + 008h]                              ; restoring slots to previous scope state
  func$__heapFree$dwflags$TypeMatch:                             ; after block
  ; Check type of parameter 2, lpMem (expecting Integer)
  mov r14, qword ptr [rbp + 058h]                                ; move type of lpMem to testByte
  mov rax, r14                                                   ; move testByte to testByte
  mov r15, 002h                                                  ; read operand of mul (type table width in bytes) 
  mul r15                                                        ; adjust to the relative start of that type's entry in the type table
  mov r10, offset typeTable                                      ; read second operand of + (type table pointer)
  add rax, r10                                                   ; finally offset all of that by the start of the type table itself (result in testByte)
  bt qword ptr [rax], 002h                                       ; check that lpMem is Integer
  jc func$__heapFree$lpmem$TypeMatch                             ; skip next block if the type matches
    ; Error handling block for lpMem
    ;  - print(parameterTypeCheckFailureMessage)
    ; Call __print with 1 arguments
    mov rbx, offset parameterTypeCheckFailureMessage             ; reading parameterTypeCheckFailureMessage for push
    push rbx                                                     ; value of argument #1 (parameterTypeCheckFailureMessage)
    push 01ah                                                    ; type of argument #1 (String'26)
    lea rsi, qword ptr [rsp + 028h]                              ; load address of return value's value
    push rsi                                                     ; internal argument 6: pointer to return value slot's value
    lea rsi, qword ptr [rsp + 028h]                              ; load address of return value's type
    push rsi                                                     ; internal argument 5: pointer to return value slot's type
    sub rsp, 020h                                                ; allocate shadow space
    mov r9, 000h                                                 ; internal argument 4: "this" pointer
    mov r8, 000h                                                 ; internal argument 3: "this" pointer type
    mov rdx, 000h                                                ; internal argument 2: closure pointer
    mov qword ptr [rsp + 048h], rcx                              ; move parameter count of __heapFree value out of rcx
    mov rcx, 001h                                                ; internal argument 1: number of actual arguments
    call func$__print                                            ; jump to subroutine
    add rsp, 040h                                                ; release shadow space and arguments (result in stack pointer)
    ;  - exit(1)
    ; Call exit with 1 arguments
    push 001h                                                    ; value of argument #1 (1 (integer))
    push 019h                                                    ; type of argument #1 (Integer'25)
    lea rdi, qword ptr [rsp + 028h]                              ; load address of return value's value
    push rdi                                                     ; internal argument 6: pointer to return value slot's value
    lea rdi, qword ptr [rsp + 028h]                              ; load address of return value's type
    push rdi                                                     ; internal argument 5: pointer to return value slot's type
    sub rsp, 020h                                                ; allocate shadow space
    mov r9, 000h                                                 ; internal argument 4: "this" pointer
    mov r8, 000h                                                 ; internal argument 3: "this" pointer type
    mov rdx, 000h                                                ; internal argument 2: closure pointer
    mov rcx, 001h                                                ; internal argument 1: number of actual arguments
    call func$exit                                               ; jump to subroutine
    add rsp, 040h                                                ; release shadow space and arguments (result in stack pointer)
    mov rcx, qword ptr [rsp + 008h]                              ; restoring slots to previous scope state
  func$__heapFree$lpmem$TypeMatch:                               ; after block
  ; Calling HeapFree
  sub rsp, 020h                                                  ; allocate shadow space
  mov r8, qword ptr [rbp + 060h]                                 ; argument #3
  mov rdx, qword ptr [rbp + 050h]                                ; argument #2
  mov qword ptr [rsp + 038h], rcx                                ; move parameter count of __heapFree value out of rcx
  mov rcx, qword ptr [rbp + 040h]                                ; argument #1
  call HeapFree                                                  ; calls HeapFree from kernel32.lib
  mov r12, 019h                                                  ; return value of HeapFree system call is of type Integer'25
  add rsp, 020h                                                  ; release shadow space and arguments if there were more than four (result in stack pointer)
  cmp r12, 000h                                                  ; compare type of return value of HeapFree system call to <sentinel>
  jne func$__heapFree$HeapfreeReturnValue$TypeMatch              ; skip next block if return value of HeapFree system call is not sentinel
    ; Error handling block for __heapFree return value
    ;  - print(returnValueTypeCheckFailureMessage)
    ; Call __print with 1 arguments
    mov r13, offset returnValueTypeCheckFailureMessage           ; reading returnValueTypeCheckFailureMessage for push
    push r13                                                     ; value of argument #1 (returnValueTypeCheckFailureMessage)
    push 01ah                                                    ; type of argument #1 (String'26)
    lea r14, qword ptr [rsp + 020h]                              ; load address of return value's value
    push r14                                                     ; internal argument 6: pointer to return value slot's value
    lea r14, qword ptr [rsp + 020h]                              ; load address of return value's type
    push r14                                                     ; internal argument 5: pointer to return value slot's type
    sub rsp, 020h                                                ; allocate shadow space
    mov r9, 000h                                                 ; internal argument 4: "this" pointer
    mov r8, 000h                                                 ; internal argument 3: "this" pointer type
    mov rdx, 000h                                                ; internal argument 2: closure pointer
    mov rcx, 001h                                                ; internal argument 1: number of actual arguments
    mov qword ptr [rsp + 040h], rax                              ; move return value of HeapFree system call value out of rax
    call func$__print                                            ; jump to subroutine
    add rsp, 040h                                                ; release shadow space and arguments (result in stack pointer)
    ;  - exit(1)
    ; Call exit with 1 arguments
    push 001h                                                    ; value of argument #1 (1 (integer))
    push 019h                                                    ; type of argument #1 (Integer'25)
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
    mov rax, qword ptr [rsp + 000h]                              ; restoring slots to previous scope state
  func$__heapFree$HeapfreeReturnValue$TypeMatch:                 ; after block
  mov r10, qword ptr [rbp + 030h]                                ; get pointer to return value of __heapFree into register to dereference it
  mov qword ptr [r10], rax                                       ; __heapFree return value
  mov rbx, qword ptr [rbp + 028h]                                ; get pointer to return value type of __heapFree into register to dereference it
  mov qword ptr [rbx], r12                                       ; type of __heapFree return value
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

; _free
dq func$_free$annotation
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
    push 01ah                                                    ; type of argument #1 (String'26)
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
    push 019h                                                    ; type of argument #1 (Integer'25)
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
  mov rdi, 002h                                                  ; read operand of mul (type table width in bytes) 
  mul rdi                                                        ; adjust to the relative start of that type's entry in the type table
  mov r12, offset typeTable                                      ; read second operand of + (type table pointer)
  add rax, r12                                                   ; finally offset all of that by the start of the type table itself (result in testByte)
  bt qword ptr [rax], 002h                                       ; check that pointer is Integer
  jc func$_free$pointer$TypeMatch                                ; skip next block if the type matches
    ; Error handling block for pointer
    ;  - print(parameterTypeCheckFailureMessage)
    ; Call __print with 1 arguments
    mov r13, offset parameterTypeCheckFailureMessage             ; reading parameterTypeCheckFailureMessage for push
    push r13                                                     ; value of argument #1 (parameterTypeCheckFailureMessage)
    push 01ah                                                    ; type of argument #1 (String'26)
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
    push 019h                                                    ; type of argument #1 (Integer'25)
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
  ; Line 42: _blockCount -= 1;
  cmp qword ptr _blockCountType, 000h                            ; compare type of _blockCount variable to <sentinel>
  jne func$_free$BlockcountVariable$TypeMatch                    ; skip next block if _blockCount variable is not sentinel
    ; Error handling block for _blockCount variable
    ;  - print(operandTypeCheckFailureMessage)
    ; Call __print with 1 arguments
    mov r10, offset operandTypeCheckFailureMessage               ; reading operandTypeCheckFailureMessage for push
    push r10                                                     ; value of argument #1 (operandTypeCheckFailureMessage)
    push 01ah                                                    ; type of argument #1 (String'26)
    lea rbx, qword ptr [rsp + 020h]                              ; load address of return value's value
    push rbx                                                     ; internal argument 6: pointer to return value slot's value
    lea rbx, qword ptr [rsp + 020h]                              ; load address of return value's type
    push rbx                                                     ; internal argument 5: pointer to return value slot's type
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
    push 019h                                                    ; type of argument #1 (Integer'25)
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
  func$_free$BlockcountVariable$TypeMatch:                       ; after block
  mov r13, qword ptr _blockCountValue                            ; assign value of _blockCount variable to value of -= operator result
  sub r13, 001h                                                  ; -= operator
  mov r14, 019h                                                  ; -= operator result is of type Integer'25
  mov qword ptr _blockCountValue, r13                            ; store value
  mov qword ptr _blockCountType, r14                             ; store type
  ; Line 43: if (__heapFree(_heapHandle, 0, pointer) == 0) { ...
  ; Call __heapFree with 3 arguments
  push qword ptr [rbp + 040h]                                    ; value of argument #3 (pointer)
  push qword ptr [rbp + 038h]                                    ; type of argument #3
  push 000h                                                      ; value of argument #2 (0)
  push 019h                                                      ; type of argument #2 (Integer'25)
  push qword ptr _heapHandleValue                                ; value of argument #1 (_heapHandle variable)
  push qword ptr _heapHandleType                                 ; type of argument #1
  lea r15, qword ptr [rsp + 040h]                                ; load address of return value's value
  push r15                                                       ; internal argument 6: pointer to return value slot's value
  lea r15, qword ptr [rsp + 040h]                                ; load address of return value's type
  push r15                                                       ; internal argument 5: pointer to return value slot's type
  sub rsp, 020h                                                  ; allocate shadow space
  mov r9, 000h                                                   ; internal argument 4: "this" pointer
  mov r8, 000h                                                   ; internal argument 3: "this" pointer type
  mov rdx, 000h                                                  ; internal argument 2: closure pointer
  mov qword ptr [rsp + 060h], rcx                                ; move parameter count of _free value out of rcx
  mov rcx, 003h                                                  ; internal argument 1: number of actual arguments
  call func$__heapFree                                           ; jump to subroutine
  add rsp, 060h                                                  ; release shadow space and arguments (result in stack pointer)
  xor r10, r10                                                   ; zero value result of == (testing __heapFree return value and 0) to put the boolean in
  cmp qword ptr [rsp + 010h], 000h                               ; values equal?
  sete r10b                                                      ; put result in value result of == (testing __heapFree return value and 0)
  mov rbx, 018h                                                  ; value result of == (testing __heapFree return value and 0) is a Boolean'24
  xor rsi, rsi                                                   ; zero type result of == (testing __heapFree return value and 0) to put the boolean in
  cmp qword ptr [rsp + 008h], 019h                               ; types equal?
  sete sil                                                       ; put result in type result of == (testing __heapFree return value and 0)
  mov rax, 018h                                                  ; type result of == (testing __heapFree return value and 0) is a Boolean'24
  mov rdi, r10                                                   ; assign value of value result of == (testing __heapFree return value and 0) to value of == operator result
  and rdi, rsi                                                   ; && type temp and value temp
  mov r12, 018h                                                  ; == operator result is of type Boolean'24
  cmp rdi, 000h                                                  ; compare == operator result to false
  je func$_free$if$continuation                                  ; __heapFree(_heapHandle, 0, pointer) == 0
    ; Line 45: exit(1);
    ; Call exit with 1 arguments
    push 001h                                                    ; value of argument #1 (1)
    push 019h                                                    ; type of argument #1 (Integer'25)
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
  func$_free$if$continuation:                                    ; end of if
  ; Implicit return from _free
  mov rbx, qword ptr [rbp + 030h]                                ; get pointer to return value of _free into register to dereference it
  mov qword ptr [rbx], 000h                                      ; _free return value
  mov rsi, qword ptr [rbp + 028h]                                ; get pointer to return value type of _free into register to dereference it
  mov qword ptr [rsi], 017h                                      ; type of _free return value (Null'23)
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

; append
dq func$append$annotation
func$append:
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
  cmp rcx, 002h                                                  ; compare parameter count of append to 2 (integer)
  je func$append$parameterCountCheck$continuation                ; check number of parameters is as expected
    ; Error handling block for parameter count
    ;  - print(parameterCountCheckFailureMessage)
    ; Call __print with 1 arguments
    mov r10, offset parameterCountCheckFailureMessage            ; reading parameterCountCheckFailureMessage for push
    push r10                                                     ; value of argument #1 (parameterCountCheckFailureMessage)
    push 01ah                                                    ; type of argument #1 (String'26)
    lea rax, qword ptr [rsp + 020h]                              ; load address of return value's value
    push rax                                                     ; internal argument 6: pointer to return value slot's value
    lea rax, qword ptr [rsp + 020h]                              ; load address of return value's type
    push rax                                                     ; internal argument 5: pointer to return value slot's type
    sub rsp, 020h                                                ; allocate shadow space
    mov r9, 000h                                                 ; internal argument 4: "this" pointer
    mov r8, 000h                                                 ; internal argument 3: "this" pointer type
    mov rdx, 000h                                                ; internal argument 2: closure pointer
    mov qword ptr [rsp + 040h], rcx                              ; move parameter count of append value out of rcx
    mov rcx, 001h                                                ; internal argument 1: number of actual arguments
    call func$__print                                            ; jump to subroutine
    add rsp, 040h                                                ; release shadow space and arguments (result in stack pointer)
    ;  - exit(1)
    ; Call exit with 1 arguments
    push 001h                                                    ; value of argument #1 (1 (integer))
    push 019h                                                    ; type of argument #1 (Integer'25)
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
  func$append$parameterCountCheck$continuation:                  ; end of parameter count check
  ; Check type of parameter 0, list (expecting WhateverList)
  mov rsi, qword ptr [rbp + 038h]                                ; move type of list to testByte
  mov rax, rsi                                                   ; move testByte to testByte
  mov rdi, 002h                                                  ; read operand of mul (type table width in bytes) 
  mul rdi                                                        ; adjust to the relative start of that type's entry in the type table
  mov r12, offset typeTable                                      ; read second operand of + (type table pointer)
  add rax, r12                                                   ; finally offset all of that by the start of the type table itself (result in testByte)
  bt qword ptr [rax], 007h                                       ; check that list is WhateverList
  jc func$append$list$TypeMatch                                  ; skip next block if the type matches
    ; Error handling block for list
    ;  - print(parameterTypeCheckFailureMessage)
    ; Call __print with 1 arguments
    mov r13, offset parameterTypeCheckFailureMessage             ; reading parameterTypeCheckFailureMessage for push
    push r13                                                     ; value of argument #1 (parameterTypeCheckFailureMessage)
    push 01ah                                                    ; type of argument #1 (String'26)
    lea r14, qword ptr [rsp + 020h]                              ; load address of return value's value
    push r14                                                     ; internal argument 6: pointer to return value slot's value
    lea r14, qword ptr [rsp + 020h]                              ; load address of return value's type
    push r14                                                     ; internal argument 5: pointer to return value slot's type
    sub rsp, 020h                                                ; allocate shadow space
    mov r9, 000h                                                 ; internal argument 4: "this" pointer
    mov r8, 000h                                                 ; internal argument 3: "this" pointer type
    mov rdx, 000h                                                ; internal argument 2: closure pointer
    mov qword ptr [rsp + 040h], rcx                              ; move parameter count of append value out of rcx
    mov rcx, 001h                                                ; internal argument 1: number of actual arguments
    call func$__print                                            ; jump to subroutine
    add rsp, 040h                                                ; release shadow space and arguments (result in stack pointer)
    ;  - exit(1)
    ; Call exit with 1 arguments
    push 001h                                                    ; value of argument #1 (1 (integer))
    push 019h                                                    ; type of argument #1 (Integer'25)
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
  func$append$list$TypeMatch:                                    ; after block
  ; Check type of parameter 1, element (expecting Anything)
  mov r10, qword ptr [rbp + 048h]                                ; move type of element to testByte
  mov rax, r10                                                   ; move testByte to testByte
  mov rbx, 002h                                                  ; read operand of mul (type table width in bytes) 
  mul rbx                                                        ; adjust to the relative start of that type's entry in the type table
  mov rsi, offset typeTable                                      ; read second operand of + (type table pointer)
  add rax, rsi                                                   ; finally offset all of that by the start of the type table itself (result in testByte)
  bt qword ptr [rax], 004h                                       ; check that element is Anything
  jc func$append$element$TypeMatch                               ; skip next block if the type matches
    ; Error handling block for element
    ;  - print(parameterTypeCheckFailureMessage)
    ; Call __print with 1 arguments
    mov rdi, offset parameterTypeCheckFailureMessage             ; reading parameterTypeCheckFailureMessage for push
    push rdi                                                     ; value of argument #1 (parameterTypeCheckFailureMessage)
    push 01ah                                                    ; type of argument #1 (String'26)
    lea r12, qword ptr [rsp + 020h]                              ; load address of return value's value
    push r12                                                     ; internal argument 6: pointer to return value slot's value
    lea r12, qword ptr [rsp + 020h]                              ; load address of return value's type
    push r12                                                     ; internal argument 5: pointer to return value slot's type
    sub rsp, 020h                                                ; allocate shadow space
    mov r9, 000h                                                 ; internal argument 4: "this" pointer
    mov r8, 000h                                                 ; internal argument 3: "this" pointer type
    mov rdx, 000h                                                ; internal argument 2: closure pointer
    mov qword ptr [rsp + 040h], rcx                              ; move parameter count of append value out of rcx
    mov rcx, 001h                                                ; internal argument 1: number of actual arguments
    call func$__print                                            ; jump to subroutine
    add rsp, 040h                                                ; release shadow space and arguments (result in stack pointer)
    ;  - exit(1)
    ; Call exit with 1 arguments
    push 001h                                                    ; value of argument #1 (1 (integer))
    push 019h                                                    ; type of argument #1 (Integer'25)
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
  func$append$element$TypeMatch:                                 ; after block
  ; Line 51: __print('append is not implemented\n');
  ; Call __print with 1 arguments
  mov r14, offset string$1                                       ; reading string for push
  push r14                                                       ; value of argument #1 (string)
  push 01ah                                                      ; type of argument #1 (String'26)
  lea r15, qword ptr [rsp + 020h]                                ; load address of return value's value
  push r15                                                       ; internal argument 6: pointer to return value slot's value
  lea r15, qword ptr [rsp + 020h]                                ; load address of return value's type
  push r15                                                       ; internal argument 5: pointer to return value slot's type
  sub rsp, 020h                                                  ; allocate shadow space
  mov r9, 000h                                                   ; internal argument 4: "this" pointer
  mov r8, 000h                                                   ; internal argument 3: "this" pointer type
  mov rdx, 000h                                                  ; internal argument 2: closure pointer
  mov qword ptr [rsp + 040h], rcx                                ; move parameter count of append value out of rcx
  mov rcx, 001h                                                  ; internal argument 1: number of actual arguments
  call func$__print                                              ; jump to subroutine
  add rsp, 040h                                                  ; release shadow space and arguments (result in stack pointer)
  ; Line 52: exit(1);
  ; Call exit with 1 arguments
  push 001h                                                      ; value of argument #1 (1)
  push 019h                                                      ; type of argument #1 (Integer'25)
  lea r10, qword ptr [rsp + 020h]                                ; load address of return value's value
  push r10                                                       ; internal argument 6: pointer to return value slot's value
  lea r10, qword ptr [rsp + 020h]                                ; load address of return value's type
  push r10                                                       ; internal argument 5: pointer to return value slot's type
  sub rsp, 020h                                                  ; allocate shadow space
  mov r9, 000h                                                   ; internal argument 4: "this" pointer
  mov r8, 000h                                                   ; internal argument 3: "this" pointer type
  mov rdx, 000h                                                  ; internal argument 2: closure pointer
  mov rcx, 001h                                                  ; internal argument 1: number of actual arguments
  call func$exit                                                 ; jump to subroutine
  add rsp, 040h                                                  ; release shadow space and arguments (result in stack pointer)
  ; Implicit return from append
  mov rdi, qword ptr [rbp + 030h]                                ; get pointer to return value of append into register to dereference it
  mov qword ptr [rdi], 000h                                      ; append return value
  mov r12, qword ptr [rbp + 028h]                                ; get pointer to return value type of append into register to dereference it
  mov qword ptr [r12], 017h                                      ; type of append return value (Null'23)
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

; chr
dq func$chr$annotation
func$chr:
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
  cmp rcx, 001h                                                  ; compare parameter count of chr to 1 (integer)
  je func$chr$parameterCountCheck$continuation                   ; check number of parameters is as expected
    ; Error handling block for parameter count
    ;  - print(parameterCountCheckFailureMessage)
    ; Call __print with 1 arguments
    mov r10, offset parameterCountCheckFailureMessage            ; reading parameterCountCheckFailureMessage for push
    push r10                                                     ; value of argument #1 (parameterCountCheckFailureMessage)
    push 01ah                                                    ; type of argument #1 (String'26)
    lea rax, qword ptr [rsp + 020h]                              ; load address of return value's value
    push rax                                                     ; internal argument 6: pointer to return value slot's value
    lea rax, qword ptr [rsp + 020h]                              ; load address of return value's type
    push rax                                                     ; internal argument 5: pointer to return value slot's type
    sub rsp, 020h                                                ; allocate shadow space
    mov r9, 000h                                                 ; internal argument 4: "this" pointer
    mov r8, 000h                                                 ; internal argument 3: "this" pointer type
    mov rdx, 000h                                                ; internal argument 2: closure pointer
    mov qword ptr [rsp + 040h], rcx                              ; move parameter count of chr value out of rcx
    mov rcx, 001h                                                ; internal argument 1: number of actual arguments
    call func$__print                                            ; jump to subroutine
    add rsp, 040h                                                ; release shadow space and arguments (result in stack pointer)
    ;  - exit(1)
    ; Call exit with 1 arguments
    push 001h                                                    ; value of argument #1 (1 (integer))
    push 019h                                                    ; type of argument #1 (Integer'25)
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
  func$chr$parameterCountCheck$continuation:                     ; end of parameter count check
  ; Check type of parameter 0, character (expecting Integer)
  mov rsi, qword ptr [rbp + 038h]                                ; move type of character to testByte
  mov rax, rsi                                                   ; move testByte to testByte
  mov rdi, 002h                                                  ; read operand of mul (type table width in bytes) 
  mul rdi                                                        ; adjust to the relative start of that type's entry in the type table
  mov r12, offset typeTable                                      ; read second operand of + (type table pointer)
  add rax, r12                                                   ; finally offset all of that by the start of the type table itself (result in testByte)
  bt qword ptr [rax], 002h                                       ; check that character is Integer
  jc func$chr$character$TypeMatch                                ; skip next block if the type matches
    ; Error handling block for character
    ;  - print(parameterTypeCheckFailureMessage)
    ; Call __print with 1 arguments
    mov r13, offset parameterTypeCheckFailureMessage             ; reading parameterTypeCheckFailureMessage for push
    push r13                                                     ; value of argument #1 (parameterTypeCheckFailureMessage)
    push 01ah                                                    ; type of argument #1 (String'26)
    lea r14, qword ptr [rsp + 020h]                              ; load address of return value's value
    push r14                                                     ; internal argument 6: pointer to return value slot's value
    lea r14, qword ptr [rsp + 020h]                              ; load address of return value's type
    push r14                                                     ; internal argument 5: pointer to return value slot's type
    sub rsp, 020h                                                ; allocate shadow space
    mov r9, 000h                                                 ; internal argument 4: "this" pointer
    mov r8, 000h                                                 ; internal argument 3: "this" pointer type
    mov rdx, 000h                                                ; internal argument 2: closure pointer
    mov qword ptr [rsp + 040h], rcx                              ; move parameter count of chr value out of rcx
    mov rcx, 001h                                                ; internal argument 1: number of actual arguments
    call func$__print                                            ; jump to subroutine
    add rsp, 040h                                                ; release shadow space and arguments (result in stack pointer)
    ;  - exit(1)
    ; Call exit with 1 arguments
    push 001h                                                    ; value of argument #1 (1 (integer))
    push 019h                                                    ; type of argument #1 (Integer'25)
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
  func$chr$character$TypeMatch:                                  ; after block
  ; Line 57: __print('chr is not implemented\n');
  ; Call __print with 1 arguments
  mov r10, offset string$2                                       ; reading string for push
  push r10                                                       ; value of argument #1 (string)
  push 01ah                                                      ; type of argument #1 (String'26)
  lea rbx, qword ptr [rsp + 020h]                                ; load address of return value's value
  push rbx                                                       ; internal argument 6: pointer to return value slot's value
  lea rbx, qword ptr [rsp + 020h]                                ; load address of return value's type
  push rbx                                                       ; internal argument 5: pointer to return value slot's type
  sub rsp, 020h                                                  ; allocate shadow space
  mov r9, 000h                                                   ; internal argument 4: "this" pointer
  mov r8, 000h                                                   ; internal argument 3: "this" pointer type
  mov rdx, 000h                                                  ; internal argument 2: closure pointer
  mov qword ptr [rsp + 040h], rcx                                ; move parameter count of chr value out of rcx
  mov rcx, 001h                                                  ; internal argument 1: number of actual arguments
  call func$__print                                              ; jump to subroutine
  add rsp, 040h                                                  ; release shadow space and arguments (result in stack pointer)
  ; Line 58: exit(1);
  ; Call exit with 1 arguments
  push 001h                                                      ; value of argument #1 (1)
  push 019h                                                      ; type of argument #1 (Integer'25)
  lea rsi, qword ptr [rsp + 020h]                                ; load address of return value's value
  push rsi                                                       ; internal argument 6: pointer to return value slot's value
  lea rsi, qword ptr [rsp + 020h]                                ; load address of return value's type
  push rsi                                                       ; internal argument 5: pointer to return value slot's type
  sub rsp, 020h                                                  ; allocate shadow space
  mov r9, 000h                                                   ; internal argument 4: "this" pointer
  mov r8, 000h                                                   ; internal argument 3: "this" pointer type
  mov rdx, 000h                                                  ; internal argument 2: closure pointer
  mov rcx, 001h                                                  ; internal argument 1: number of actual arguments
  call func$exit                                                 ; jump to subroutine
  add rsp, 040h                                                  ; release shadow space and arguments (result in stack pointer)
  ; Implicit return from chr
  mov rax, 017h                                                  ; move type of null to testByte
  mov rdi, 002h                                                  ; read operand of mul (type table width in bytes) 
  mul rdi                                                        ; adjust to the relative start of that type's entry in the type table
  mov r12, offset typeTable                                      ; read second operand of + (type table pointer)
  add rax, r12                                                   ; finally offset all of that by the start of the type table itself (result in testByte)
  bt qword ptr [rax], 003h                                       ; check that chr return value is String
  jc func$chr$chrReturnValue$TypeMatch                           ; skip next block if the type matches
    ; Error handling block for chr return value
    ;  - print(returnValueTypeCheckFailureMessage)
    ; Call __print with 1 arguments
    mov r13, offset returnValueTypeCheckFailureMessage           ; reading returnValueTypeCheckFailureMessage for push
    push r13                                                     ; value of argument #1 (returnValueTypeCheckFailureMessage)
    push 01ah                                                    ; type of argument #1 (String'26)
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
    push 019h                                                    ; type of argument #1 (Integer'25)
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
  func$chr$chrReturnValue$TypeMatch:                             ; after block
  mov r10, qword ptr [rbp + 030h]                                ; get pointer to return value of chr into register to dereference it
  mov qword ptr [r10], 000h                                      ; chr return value
  mov rbx, qword ptr [rbp + 028h]                                ; get pointer to return value type of chr into register to dereference it
  mov qword ptr [rbx], 017h                                      ; type of chr return value (Null'23)
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

; joinList
dq func$joinList$annotation
func$joinList:
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
  cmp rcx, 001h                                                  ; compare parameter count of joinList to 1 (integer)
  je func$joinList$parameterCountCheck$continuation              ; check number of parameters is as expected
    ; Error handling block for parameter count
    ;  - print(parameterCountCheckFailureMessage)
    ; Call __print with 1 arguments
    mov r10, offset parameterCountCheckFailureMessage            ; reading parameterCountCheckFailureMessage for push
    push r10                                                     ; value of argument #1 (parameterCountCheckFailureMessage)
    push 01ah                                                    ; type of argument #1 (String'26)
    lea rax, qword ptr [rsp + 020h]                              ; load address of return value's value
    push rax                                                     ; internal argument 6: pointer to return value slot's value
    lea rax, qword ptr [rsp + 020h]                              ; load address of return value's type
    push rax                                                     ; internal argument 5: pointer to return value slot's type
    sub rsp, 020h                                                ; allocate shadow space
    mov r9, 000h                                                 ; internal argument 4: "this" pointer
    mov r8, 000h                                                 ; internal argument 3: "this" pointer type
    mov rdx, 000h                                                ; internal argument 2: closure pointer
    mov qword ptr [rsp + 040h], rcx                              ; move parameter count of joinList value out of rcx
    mov rcx, 001h                                                ; internal argument 1: number of actual arguments
    call func$__print                                            ; jump to subroutine
    add rsp, 040h                                                ; release shadow space and arguments (result in stack pointer)
    ;  - exit(1)
    ; Call exit with 1 arguments
    push 001h                                                    ; value of argument #1 (1 (integer))
    push 019h                                                    ; type of argument #1 (Integer'25)
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
  func$joinList$parameterCountCheck$continuation:                ; end of parameter count check
  ; Check type of parameter 0, args (expecting StringList)
  mov rsi, qword ptr [rbp + 038h]                                ; move type of args to testByte
  mov rax, rsi                                                   ; move testByte to testByte
  mov rdi, 002h                                                  ; read operand of mul (type table width in bytes) 
  mul rdi                                                        ; adjust to the relative start of that type's entry in the type table
  add rax, 001h                                                  ; adjust to the byte containing the bit to check against (result in testByte)
  mov r12, offset typeTable                                      ; read second operand of + (type table pointer)
  add rax, r12                                                   ; finally offset all of that by the start of the type table itself (result in testByte)
  bt qword ptr [rax], 000h                                       ; check that args is StringList
  jc func$joinList$args$TypeMatch                                ; skip next block if the type matches
    ; Error handling block for args
    ;  - print(parameterTypeCheckFailureMessage)
    ; Call __print with 1 arguments
    mov r13, offset parameterTypeCheckFailureMessage             ; reading parameterTypeCheckFailureMessage for push
    push r13                                                     ; value of argument #1 (parameterTypeCheckFailureMessage)
    push 01ah                                                    ; type of argument #1 (String'26)
    lea r14, qword ptr [rsp + 020h]                              ; load address of return value's value
    push r14                                                     ; internal argument 6: pointer to return value slot's value
    lea r14, qword ptr [rsp + 020h]                              ; load address of return value's type
    push r14                                                     ; internal argument 5: pointer to return value slot's type
    sub rsp, 020h                                                ; allocate shadow space
    mov r9, 000h                                                 ; internal argument 4: "this" pointer
    mov r8, 000h                                                 ; internal argument 3: "this" pointer type
    mov rdx, 000h                                                ; internal argument 2: closure pointer
    mov qword ptr [rsp + 040h], rcx                              ; move parameter count of joinList value out of rcx
    mov rcx, 001h                                                ; internal argument 1: number of actual arguments
    call func$__print                                            ; jump to subroutine
    add rsp, 040h                                                ; release shadow space and arguments (result in stack pointer)
    ;  - exit(1)
    ; Call exit with 1 arguments
    push 001h                                                    ; value of argument #1 (1 (integer))
    push 019h                                                    ; type of argument #1 (Integer'25)
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
  func$joinList$args$TypeMatch:                                  ; after block
  ; Line 63: __print('joinList is not implemented\n');
  ; Call __print with 1 arguments
  mov r10, offset string$3                                       ; reading string for push
  push r10                                                       ; value of argument #1 (string)
  push 01ah                                                      ; type of argument #1 (String'26)
  lea rbx, qword ptr [rsp + 020h]                                ; load address of return value's value
  push rbx                                                       ; internal argument 6: pointer to return value slot's value
  lea rbx, qword ptr [rsp + 020h]                                ; load address of return value's type
  push rbx                                                       ; internal argument 5: pointer to return value slot's type
  sub rsp, 020h                                                  ; allocate shadow space
  mov r9, 000h                                                   ; internal argument 4: "this" pointer
  mov r8, 000h                                                   ; internal argument 3: "this" pointer type
  mov rdx, 000h                                                  ; internal argument 2: closure pointer
  mov qword ptr [rsp + 040h], rcx                                ; move parameter count of joinList value out of rcx
  mov rcx, 001h                                                  ; internal argument 1: number of actual arguments
  call func$__print                                              ; jump to subroutine
  add rsp, 040h                                                  ; release shadow space and arguments (result in stack pointer)
  ; Line 64: exit(1);
  ; Call exit with 1 arguments
  push 001h                                                      ; value of argument #1 (1)
  push 019h                                                      ; type of argument #1 (Integer'25)
  lea rsi, qword ptr [rsp + 020h]                                ; load address of return value's value
  push rsi                                                       ; internal argument 6: pointer to return value slot's value
  lea rsi, qword ptr [rsp + 020h]                                ; load address of return value's type
  push rsi                                                       ; internal argument 5: pointer to return value slot's type
  sub rsp, 020h                                                  ; allocate shadow space
  mov r9, 000h                                                   ; internal argument 4: "this" pointer
  mov r8, 000h                                                   ; internal argument 3: "this" pointer type
  mov rdx, 000h                                                  ; internal argument 2: closure pointer
  mov rcx, 001h                                                  ; internal argument 1: number of actual arguments
  call func$exit                                                 ; jump to subroutine
  add rsp, 040h                                                  ; release shadow space and arguments (result in stack pointer)
  ; Implicit return from joinList
  mov rax, 017h                                                  ; move type of null to testByte
  mov rdi, 002h                                                  ; read operand of mul (type table width in bytes) 
  mul rdi                                                        ; adjust to the relative start of that type's entry in the type table
  mov r12, offset typeTable                                      ; read second operand of + (type table pointer)
  add rax, r12                                                   ; finally offset all of that by the start of the type table itself (result in testByte)
  bt qword ptr [rax], 003h                                       ; check that joinList return value is String
  jc func$joinList$joinlistReturnValue$TypeMatch                 ; skip next block if the type matches
    ; Error handling block for joinList return value
    ;  - print(returnValueTypeCheckFailureMessage)
    ; Call __print with 1 arguments
    mov r13, offset returnValueTypeCheckFailureMessage           ; reading returnValueTypeCheckFailureMessage for push
    push r13                                                     ; value of argument #1 (returnValueTypeCheckFailureMessage)
    push 01ah                                                    ; type of argument #1 (String'26)
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
    push 019h                                                    ; type of argument #1 (Integer'25)
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
  func$joinList$joinlistReturnValue$TypeMatch:                   ; after block
  mov r10, qword ptr [rbp + 030h]                                ; get pointer to return value of joinList into register to dereference it
  mov qword ptr [r10], 000h                                      ; joinList return value
  mov rbx, qword ptr [rbp + 028h]                                ; get pointer to return value type of joinList into register to dereference it
  mov qword ptr [rbx], 017h                                      ; type of joinList return value (Null'23)
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

; stringTimes
dq func$stringTimes$annotation
func$stringTimes:
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
  cmp rcx, 002h                                                  ; compare parameter count of stringTimes to 2 (integer)
  je func$stringTimes$parameterCountCheck$continuation           ; check number of parameters is as expected
    ; Error handling block for parameter count
    ;  - print(parameterCountCheckFailureMessage)
    ; Call __print with 1 arguments
    mov r10, offset parameterCountCheckFailureMessage            ; reading parameterCountCheckFailureMessage for push
    push r10                                                     ; value of argument #1 (parameterCountCheckFailureMessage)
    push 01ah                                                    ; type of argument #1 (String'26)
    lea rax, qword ptr [rsp + 020h]                              ; load address of return value's value
    push rax                                                     ; internal argument 6: pointer to return value slot's value
    lea rax, qword ptr [rsp + 020h]                              ; load address of return value's type
    push rax                                                     ; internal argument 5: pointer to return value slot's type
    sub rsp, 020h                                                ; allocate shadow space
    mov r9, 000h                                                 ; internal argument 4: "this" pointer
    mov r8, 000h                                                 ; internal argument 3: "this" pointer type
    mov rdx, 000h                                                ; internal argument 2: closure pointer
    mov qword ptr [rsp + 040h], rcx                              ; move parameter count of stringTimes value out of rcx
    mov rcx, 001h                                                ; internal argument 1: number of actual arguments
    call func$__print                                            ; jump to subroutine
    add rsp, 040h                                                ; release shadow space and arguments (result in stack pointer)
    ;  - exit(1)
    ; Call exit with 1 arguments
    push 001h                                                    ; value of argument #1 (1 (integer))
    push 019h                                                    ; type of argument #1 (Integer'25)
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
  func$stringTimes$parameterCountCheck$continuation:             ; end of parameter count check
  ; Check type of parameter 0, str (expecting String)
  mov rsi, qword ptr [rbp + 038h]                                ; move type of str to testByte
  mov rax, rsi                                                   ; move testByte to testByte
  mov rdi, 002h                                                  ; read operand of mul (type table width in bytes) 
  mul rdi                                                        ; adjust to the relative start of that type's entry in the type table
  mov r12, offset typeTable                                      ; read second operand of + (type table pointer)
  add rax, r12                                                   ; finally offset all of that by the start of the type table itself (result in testByte)
  bt qword ptr [rax], 003h                                       ; check that str is String
  jc func$stringTimes$str$TypeMatch                              ; skip next block if the type matches
    ; Error handling block for str
    ;  - print(parameterTypeCheckFailureMessage)
    ; Call __print with 1 arguments
    mov r13, offset parameterTypeCheckFailureMessage             ; reading parameterTypeCheckFailureMessage for push
    push r13                                                     ; value of argument #1 (parameterTypeCheckFailureMessage)
    push 01ah                                                    ; type of argument #1 (String'26)
    lea r14, qword ptr [rsp + 020h]                              ; load address of return value's value
    push r14                                                     ; internal argument 6: pointer to return value slot's value
    lea r14, qword ptr [rsp + 020h]                              ; load address of return value's type
    push r14                                                     ; internal argument 5: pointer to return value slot's type
    sub rsp, 020h                                                ; allocate shadow space
    mov r9, 000h                                                 ; internal argument 4: "this" pointer
    mov r8, 000h                                                 ; internal argument 3: "this" pointer type
    mov rdx, 000h                                                ; internal argument 2: closure pointer
    mov qword ptr [rsp + 040h], rcx                              ; move parameter count of stringTimes value out of rcx
    mov rcx, 001h                                                ; internal argument 1: number of actual arguments
    call func$__print                                            ; jump to subroutine
    add rsp, 040h                                                ; release shadow space and arguments (result in stack pointer)
    ;  - exit(1)
    ; Call exit with 1 arguments
    push 001h                                                    ; value of argument #1 (1 (integer))
    push 019h                                                    ; type of argument #1 (Integer'25)
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
  func$stringTimes$str$TypeMatch:                                ; after block
  ; Check type of parameter 1, count (expecting Integer)
  mov r10, qword ptr [rbp + 048h]                                ; move type of count to testByte
  mov rax, r10                                                   ; move testByte to testByte
  mov rbx, 002h                                                  ; read operand of mul (type table width in bytes) 
  mul rbx                                                        ; adjust to the relative start of that type's entry in the type table
  mov rsi, offset typeTable                                      ; read second operand of + (type table pointer)
  add rax, rsi                                                   ; finally offset all of that by the start of the type table itself (result in testByte)
  bt qword ptr [rax], 002h                                       ; check that count is Integer
  jc func$stringTimes$count$TypeMatch                            ; skip next block if the type matches
    ; Error handling block for count
    ;  - print(parameterTypeCheckFailureMessage)
    ; Call __print with 1 arguments
    mov rdi, offset parameterTypeCheckFailureMessage             ; reading parameterTypeCheckFailureMessage for push
    push rdi                                                     ; value of argument #1 (parameterTypeCheckFailureMessage)
    push 01ah                                                    ; type of argument #1 (String'26)
    lea r12, qword ptr [rsp + 020h]                              ; load address of return value's value
    push r12                                                     ; internal argument 6: pointer to return value slot's value
    lea r12, qword ptr [rsp + 020h]                              ; load address of return value's type
    push r12                                                     ; internal argument 5: pointer to return value slot's type
    sub rsp, 020h                                                ; allocate shadow space
    mov r9, 000h                                                 ; internal argument 4: "this" pointer
    mov r8, 000h                                                 ; internal argument 3: "this" pointer type
    mov rdx, 000h                                                ; internal argument 2: closure pointer
    mov qword ptr [rsp + 040h], rcx                              ; move parameter count of stringTimes value out of rcx
    mov rcx, 001h                                                ; internal argument 1: number of actual arguments
    call func$__print                                            ; jump to subroutine
    add rsp, 040h                                                ; release shadow space and arguments (result in stack pointer)
    ;  - exit(1)
    ; Call exit with 1 arguments
    push 001h                                                    ; value of argument #1 (1 (integer))
    push 019h                                                    ; type of argument #1 (Integer'25)
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
  func$stringTimes$count$TypeMatch:                              ; after block
  ; Line 69: __print('stringTimes is not implemented\n');
  ; Call __print with 1 arguments
  mov r14, offset string$4                                       ; reading string for push
  push r14                                                       ; value of argument #1 (string)
  push 01ah                                                      ; type of argument #1 (String'26)
  lea r15, qword ptr [rsp + 020h]                                ; load address of return value's value
  push r15                                                       ; internal argument 6: pointer to return value slot's value
  lea r15, qword ptr [rsp + 020h]                                ; load address of return value's type
  push r15                                                       ; internal argument 5: pointer to return value slot's type
  sub rsp, 020h                                                  ; allocate shadow space
  mov r9, 000h                                                   ; internal argument 4: "this" pointer
  mov r8, 000h                                                   ; internal argument 3: "this" pointer type
  mov rdx, 000h                                                  ; internal argument 2: closure pointer
  mov qword ptr [rsp + 040h], rcx                                ; move parameter count of stringTimes value out of rcx
  mov rcx, 001h                                                  ; internal argument 1: number of actual arguments
  call func$__print                                              ; jump to subroutine
  add rsp, 040h                                                  ; release shadow space and arguments (result in stack pointer)
  ; Line 70: exit(1);
  ; Call exit with 1 arguments
  push 001h                                                      ; value of argument #1 (1)
  push 019h                                                      ; type of argument #1 (Integer'25)
  lea r10, qword ptr [rsp + 020h]                                ; load address of return value's value
  push r10                                                       ; internal argument 6: pointer to return value slot's value
  lea r10, qword ptr [rsp + 020h]                                ; load address of return value's type
  push r10                                                       ; internal argument 5: pointer to return value slot's type
  sub rsp, 020h                                                  ; allocate shadow space
  mov r9, 000h                                                   ; internal argument 4: "this" pointer
  mov r8, 000h                                                   ; internal argument 3: "this" pointer type
  mov rdx, 000h                                                  ; internal argument 2: closure pointer
  mov rcx, 001h                                                  ; internal argument 1: number of actual arguments
  call func$exit                                                 ; jump to subroutine
  add rsp, 040h                                                  ; release shadow space and arguments (result in stack pointer)
  ; Implicit return from stringTimes
  mov rax, 017h                                                  ; move type of null to testByte
  mov rbx, 002h                                                  ; read operand of mul (type table width in bytes) 
  mul rbx                                                        ; adjust to the relative start of that type's entry in the type table
  mov rsi, offset typeTable                                      ; read second operand of + (type table pointer)
  add rax, rsi                                                   ; finally offset all of that by the start of the type table itself (result in testByte)
  bt qword ptr [rax], 003h                                       ; check that stringTimes return value is String
  jc func$stringTimes$stringtimesReturnValue$TypeMatch           ; skip next block if the type matches
    ; Error handling block for stringTimes return value
    ;  - print(returnValueTypeCheckFailureMessage)
    ; Call __print with 1 arguments
    mov rdi, offset returnValueTypeCheckFailureMessage           ; reading returnValueTypeCheckFailureMessage for push
    push rdi                                                     ; value of argument #1 (returnValueTypeCheckFailureMessage)
    push 01ah                                                    ; type of argument #1 (String'26)
    lea r12, qword ptr [rsp + 020h]                              ; load address of return value's value
    push r12                                                     ; internal argument 6: pointer to return value slot's value
    lea r12, qword ptr [rsp + 020h]                              ; load address of return value's type
    push r12                                                     ; internal argument 5: pointer to return value slot's type
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
    push 019h                                                    ; type of argument #1 (Integer'25)
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
  func$stringTimes$stringtimesReturnValue$TypeMatch:             ; after block
  mov r14, qword ptr [rbp + 030h]                                ; get pointer to return value of stringTimes into register to dereference it
  mov qword ptr [r14], 000h                                      ; stringTimes return value
  mov r15, qword ptr [rbp + 028h]                                ; get pointer to return value type of stringTimes into register to dereference it
  mov qword ptr [r15], 017h                                      ; type of stringTimes return value (Null'23)
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

; charsOf
dq func$charsOf$annotation
func$charsOf:
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
  cmp rcx, 001h                                                  ; compare parameter count of charsOf to 1 (integer)
  je func$charsOf$parameterCountCheck$continuation               ; check number of parameters is as expected
    ; Error handling block for parameter count
    ;  - print(parameterCountCheckFailureMessage)
    ; Call __print with 1 arguments
    mov r10, offset parameterCountCheckFailureMessage            ; reading parameterCountCheckFailureMessage for push
    push r10                                                     ; value of argument #1 (parameterCountCheckFailureMessage)
    push 01ah                                                    ; type of argument #1 (String'26)
    lea rax, qword ptr [rsp + 020h]                              ; load address of return value's value
    push rax                                                     ; internal argument 6: pointer to return value slot's value
    lea rax, qword ptr [rsp + 020h]                              ; load address of return value's type
    push rax                                                     ; internal argument 5: pointer to return value slot's type
    sub rsp, 020h                                                ; allocate shadow space
    mov r9, 000h                                                 ; internal argument 4: "this" pointer
    mov r8, 000h                                                 ; internal argument 3: "this" pointer type
    mov rdx, 000h                                                ; internal argument 2: closure pointer
    mov qword ptr [rsp + 040h], rcx                              ; move parameter count of charsOf value out of rcx
    mov rcx, 001h                                                ; internal argument 1: number of actual arguments
    call func$__print                                            ; jump to subroutine
    add rsp, 040h                                                ; release shadow space and arguments (result in stack pointer)
    ;  - exit(1)
    ; Call exit with 1 arguments
    push 001h                                                    ; value of argument #1 (1 (integer))
    push 019h                                                    ; type of argument #1 (Integer'25)
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
  func$charsOf$parameterCountCheck$continuation:                 ; end of parameter count check
  ; Check type of parameter 0, str (expecting String)
  mov rsi, qword ptr [rbp + 038h]                                ; move type of str to testByte
  mov rax, rsi                                                   ; move testByte to testByte
  mov rdi, 002h                                                  ; read operand of mul (type table width in bytes) 
  mul rdi                                                        ; adjust to the relative start of that type's entry in the type table
  mov r12, offset typeTable                                      ; read second operand of + (type table pointer)
  add rax, r12                                                   ; finally offset all of that by the start of the type table itself (result in testByte)
  bt qword ptr [rax], 003h                                       ; check that str is String
  jc func$charsOf$str$TypeMatch                                  ; skip next block if the type matches
    ; Error handling block for str
    ;  - print(parameterTypeCheckFailureMessage)
    ; Call __print with 1 arguments
    mov r13, offset parameterTypeCheckFailureMessage             ; reading parameterTypeCheckFailureMessage for push
    push r13                                                     ; value of argument #1 (parameterTypeCheckFailureMessage)
    push 01ah                                                    ; type of argument #1 (String'26)
    lea r14, qword ptr [rsp + 020h]                              ; load address of return value's value
    push r14                                                     ; internal argument 6: pointer to return value slot's value
    lea r14, qword ptr [rsp + 020h]                              ; load address of return value's type
    push r14                                                     ; internal argument 5: pointer to return value slot's type
    sub rsp, 020h                                                ; allocate shadow space
    mov r9, 000h                                                 ; internal argument 4: "this" pointer
    mov r8, 000h                                                 ; internal argument 3: "this" pointer type
    mov rdx, 000h                                                ; internal argument 2: closure pointer
    mov qword ptr [rsp + 040h], rcx                              ; move parameter count of charsOf value out of rcx
    mov rcx, 001h                                                ; internal argument 1: number of actual arguments
    call func$__print                                            ; jump to subroutine
    add rsp, 040h                                                ; release shadow space and arguments (result in stack pointer)
    ;  - exit(1)
    ; Call exit with 1 arguments
    push 001h                                                    ; value of argument #1 (1 (integer))
    push 019h                                                    ; type of argument #1 (Integer'25)
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
  func$charsOf$str$TypeMatch:                                    ; after block
  ; Line 75: __print('charsOf is not implemented\n');
  ; Call __print with 1 arguments
  mov r10, offset string$5                                       ; reading string for push
  push r10                                                       ; value of argument #1 (string)
  push 01ah                                                      ; type of argument #1 (String'26)
  lea rbx, qword ptr [rsp + 020h]                                ; load address of return value's value
  push rbx                                                       ; internal argument 6: pointer to return value slot's value
  lea rbx, qword ptr [rsp + 020h]                                ; load address of return value's type
  push rbx                                                       ; internal argument 5: pointer to return value slot's type
  sub rsp, 020h                                                  ; allocate shadow space
  mov r9, 000h                                                   ; internal argument 4: "this" pointer
  mov r8, 000h                                                   ; internal argument 3: "this" pointer type
  mov rdx, 000h                                                  ; internal argument 2: closure pointer
  mov qword ptr [rsp + 040h], rcx                                ; move parameter count of charsOf value out of rcx
  mov rcx, 001h                                                  ; internal argument 1: number of actual arguments
  call func$__print                                              ; jump to subroutine
  add rsp, 040h                                                  ; release shadow space and arguments (result in stack pointer)
  ; Line 76: exit(1);
  ; Call exit with 1 arguments
  push 001h                                                      ; value of argument #1 (1)
  push 019h                                                      ; type of argument #1 (Integer'25)
  lea rsi, qword ptr [rsp + 020h]                                ; load address of return value's value
  push rsi                                                       ; internal argument 6: pointer to return value slot's value
  lea rsi, qword ptr [rsp + 020h]                                ; load address of return value's type
  push rsi                                                       ; internal argument 5: pointer to return value slot's type
  sub rsp, 020h                                                  ; allocate shadow space
  mov r9, 000h                                                   ; internal argument 4: "this" pointer
  mov r8, 000h                                                   ; internal argument 3: "this" pointer type
  mov rdx, 000h                                                  ; internal argument 2: closure pointer
  mov rcx, 001h                                                  ; internal argument 1: number of actual arguments
  call func$exit                                                 ; jump to subroutine
  add rsp, 040h                                                  ; release shadow space and arguments (result in stack pointer)
  ; Implicit return from charsOf
  mov rax, 017h                                                  ; move type of null to testByte
  mov rdi, 002h                                                  ; read operand of mul (type table width in bytes) 
  mul rdi                                                        ; adjust to the relative start of that type's entry in the type table
  add rax, 001h                                                  ; adjust to the byte containing the bit to check against (result in testByte)
  mov r12, offset typeTable                                      ; read second operand of + (type table pointer)
  add rax, r12                                                   ; finally offset all of that by the start of the type table itself (result in testByte)
  bt qword ptr [rax], 000h                                       ; check that charsOf return value is StringList
  jc func$charsOf$charsofReturnValue$TypeMatch                   ; skip next block if the type matches
    ; Error handling block for charsOf return value
    ;  - print(returnValueTypeCheckFailureMessage)
    ; Call __print with 1 arguments
    mov r13, offset returnValueTypeCheckFailureMessage           ; reading returnValueTypeCheckFailureMessage for push
    push r13                                                     ; value of argument #1 (returnValueTypeCheckFailureMessage)
    push 01ah                                                    ; type of argument #1 (String'26)
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
    push 019h                                                    ; type of argument #1 (Integer'25)
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
  func$charsOf$charsofReturnValue$TypeMatch:                     ; after block
  mov r10, qword ptr [rbp + 030h]                                ; get pointer to return value of charsOf into register to dereference it
  mov qword ptr [r10], 000h                                      ; charsOf return value
  mov rbx, qword ptr [rbp + 028h]                                ; get pointer to return value type of charsOf into register to dereference it
  mov qword ptr [rbx], 017h                                      ; type of charsOf return value (Null'23)
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

; scalarValues
dq func$scalarValues$annotation
func$scalarValues:
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
  cmp rcx, 001h                                                  ; compare parameter count of scalarValues to 1 (integer)
  je func$scalarValues$parameterCountCheck$continuation          ; check number of parameters is as expected
    ; Error handling block for parameter count
    ;  - print(parameterCountCheckFailureMessage)
    ; Call __print with 1 arguments
    mov r10, offset parameterCountCheckFailureMessage            ; reading parameterCountCheckFailureMessage for push
    push r10                                                     ; value of argument #1 (parameterCountCheckFailureMessage)
    push 01ah                                                    ; type of argument #1 (String'26)
    lea rax, qword ptr [rsp + 020h]                              ; load address of return value's value
    push rax                                                     ; internal argument 6: pointer to return value slot's value
    lea rax, qword ptr [rsp + 020h]                              ; load address of return value's type
    push rax                                                     ; internal argument 5: pointer to return value slot's type
    sub rsp, 020h                                                ; allocate shadow space
    mov r9, 000h                                                 ; internal argument 4: "this" pointer
    mov r8, 000h                                                 ; internal argument 3: "this" pointer type
    mov rdx, 000h                                                ; internal argument 2: closure pointer
    mov qword ptr [rsp + 040h], rcx                              ; move parameter count of scalarValues value out of rcx
    mov rcx, 001h                                                ; internal argument 1: number of actual arguments
    call func$__print                                            ; jump to subroutine
    add rsp, 040h                                                ; release shadow space and arguments (result in stack pointer)
    ;  - exit(1)
    ; Call exit with 1 arguments
    push 001h                                                    ; value of argument #1 (1 (integer))
    push 019h                                                    ; type of argument #1 (Integer'25)
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
  func$scalarValues$parameterCountCheck$continuation:            ; end of parameter count check
  ; Check type of parameter 0, str (expecting String)
  mov rsi, qword ptr [rbp + 038h]                                ; move type of str to testByte
  mov rax, rsi                                                   ; move testByte to testByte
  mov rdi, 002h                                                  ; read operand of mul (type table width in bytes) 
  mul rdi                                                        ; adjust to the relative start of that type's entry in the type table
  mov r12, offset typeTable                                      ; read second operand of + (type table pointer)
  add rax, r12                                                   ; finally offset all of that by the start of the type table itself (result in testByte)
  bt qword ptr [rax], 003h                                       ; check that str is String
  jc func$scalarValues$str$TypeMatch                             ; skip next block if the type matches
    ; Error handling block for str
    ;  - print(parameterTypeCheckFailureMessage)
    ; Call __print with 1 arguments
    mov r13, offset parameterTypeCheckFailureMessage             ; reading parameterTypeCheckFailureMessage for push
    push r13                                                     ; value of argument #1 (parameterTypeCheckFailureMessage)
    push 01ah                                                    ; type of argument #1 (String'26)
    lea r14, qword ptr [rsp + 020h]                              ; load address of return value's value
    push r14                                                     ; internal argument 6: pointer to return value slot's value
    lea r14, qword ptr [rsp + 020h]                              ; load address of return value's type
    push r14                                                     ; internal argument 5: pointer to return value slot's type
    sub rsp, 020h                                                ; allocate shadow space
    mov r9, 000h                                                 ; internal argument 4: "this" pointer
    mov r8, 000h                                                 ; internal argument 3: "this" pointer type
    mov rdx, 000h                                                ; internal argument 2: closure pointer
    mov qword ptr [rsp + 040h], rcx                              ; move parameter count of scalarValues value out of rcx
    mov rcx, 001h                                                ; internal argument 1: number of actual arguments
    call func$__print                                            ; jump to subroutine
    add rsp, 040h                                                ; release shadow space and arguments (result in stack pointer)
    ;  - exit(1)
    ; Call exit with 1 arguments
    push 001h                                                    ; value of argument #1 (1 (integer))
    push 019h                                                    ; type of argument #1 (Integer'25)
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
  func$scalarValues$str$TypeMatch:                               ; after block
  ; Line 81: __print('scalarValues is not implemented\n');
  ; Call __print with 1 arguments
  mov r10, offset string$6                                       ; reading string for push
  push r10                                                       ; value of argument #1 (string)
  push 01ah                                                      ; type of argument #1 (String'26)
  lea rbx, qword ptr [rsp + 020h]                                ; load address of return value's value
  push rbx                                                       ; internal argument 6: pointer to return value slot's value
  lea rbx, qword ptr [rsp + 020h]                                ; load address of return value's type
  push rbx                                                       ; internal argument 5: pointer to return value slot's type
  sub rsp, 020h                                                  ; allocate shadow space
  mov r9, 000h                                                   ; internal argument 4: "this" pointer
  mov r8, 000h                                                   ; internal argument 3: "this" pointer type
  mov rdx, 000h                                                  ; internal argument 2: closure pointer
  mov qword ptr [rsp + 040h], rcx                                ; move parameter count of scalarValues value out of rcx
  mov rcx, 001h                                                  ; internal argument 1: number of actual arguments
  call func$__print                                              ; jump to subroutine
  add rsp, 040h                                                  ; release shadow space and arguments (result in stack pointer)
  ; Line 82: exit(1);
  ; Call exit with 1 arguments
  push 001h                                                      ; value of argument #1 (1)
  push 019h                                                      ; type of argument #1 (Integer'25)
  lea rsi, qword ptr [rsp + 020h]                                ; load address of return value's value
  push rsi                                                       ; internal argument 6: pointer to return value slot's value
  lea rsi, qword ptr [rsp + 020h]                                ; load address of return value's type
  push rsi                                                       ; internal argument 5: pointer to return value slot's type
  sub rsp, 020h                                                  ; allocate shadow space
  mov r9, 000h                                                   ; internal argument 4: "this" pointer
  mov r8, 000h                                                   ; internal argument 3: "this" pointer type
  mov rdx, 000h                                                  ; internal argument 2: closure pointer
  mov rcx, 001h                                                  ; internal argument 1: number of actual arguments
  call func$exit                                                 ; jump to subroutine
  add rsp, 040h                                                  ; release shadow space and arguments (result in stack pointer)
  ; Implicit return from scalarValues
  mov rax, 017h                                                  ; move type of null to testByte
  mov rdi, 002h                                                  ; read operand of mul (type table width in bytes) 
  mul rdi                                                        ; adjust to the relative start of that type's entry in the type table
  add rax, 001h                                                  ; adjust to the byte containing the bit to check against (result in testByte)
  mov r12, offset typeTable                                      ; read second operand of + (type table pointer)
  add rax, r12                                                   ; finally offset all of that by the start of the type table itself (result in testByte)
  bt qword ptr [rax], 000h                                       ; check that scalarValues return value is StringList
  jc func$scalarValues$scalarvaluesReturnValue$TypeMatch         ; skip next block if the type matches
    ; Error handling block for scalarValues return value
    ;  - print(returnValueTypeCheckFailureMessage)
    ; Call __print with 1 arguments
    mov r13, offset returnValueTypeCheckFailureMessage           ; reading returnValueTypeCheckFailureMessage for push
    push r13                                                     ; value of argument #1 (returnValueTypeCheckFailureMessage)
    push 01ah                                                    ; type of argument #1 (String'26)
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
    push 019h                                                    ; type of argument #1 (Integer'25)
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
  func$scalarValues$scalarvaluesReturnValue$TypeMatch:           ; after block
  mov r10, qword ptr [rbp + 030h]                                ; get pointer to return value of scalarValues into register to dereference it
  mov qword ptr [r10], 000h                                      ; scalarValues return value
  mov rbx, qword ptr [rbp + 028h]                                ; get pointer to return value type of scalarValues into register to dereference it
  mov qword ptr [rbx], 017h                                      ; type of scalarValues return value (Null'23)
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

; hex
dq func$hex$annotation
func$hex:
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
  cmp rcx, 001h                                                  ; compare parameter count of hex to 1 (integer)
  je func$hex$parameterCountCheck$continuation                   ; check number of parameters is as expected
    ; Error handling block for parameter count
    ;  - print(parameterCountCheckFailureMessage)
    ; Call __print with 1 arguments
    mov r10, offset parameterCountCheckFailureMessage            ; reading parameterCountCheckFailureMessage for push
    push r10                                                     ; value of argument #1 (parameterCountCheckFailureMessage)
    push 01ah                                                    ; type of argument #1 (String'26)
    lea rax, qword ptr [rsp + 020h]                              ; load address of return value's value
    push rax                                                     ; internal argument 6: pointer to return value slot's value
    lea rax, qword ptr [rsp + 020h]                              ; load address of return value's type
    push rax                                                     ; internal argument 5: pointer to return value slot's type
    sub rsp, 020h                                                ; allocate shadow space
    mov r9, 000h                                                 ; internal argument 4: "this" pointer
    mov r8, 000h                                                 ; internal argument 3: "this" pointer type
    mov rdx, 000h                                                ; internal argument 2: closure pointer
    mov qword ptr [rsp + 040h], rcx                              ; move parameter count of hex value out of rcx
    mov rcx, 001h                                                ; internal argument 1: number of actual arguments
    call func$__print                                            ; jump to subroutine
    add rsp, 040h                                                ; release shadow space and arguments (result in stack pointer)
    ;  - exit(1)
    ; Call exit with 1 arguments
    push 001h                                                    ; value of argument #1 (1 (integer))
    push 019h                                                    ; type of argument #1 (Integer'25)
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
  func$hex$parameterCountCheck$continuation:                     ; end of parameter count check
  ; Check type of parameter 0, num (expecting Integer)
  mov rsi, qword ptr [rbp + 038h]                                ; move type of num to testByte
  mov rax, rsi                                                   ; move testByte to testByte
  mov rdi, 002h                                                  ; read operand of mul (type table width in bytes) 
  mul rdi                                                        ; adjust to the relative start of that type's entry in the type table
  mov r12, offset typeTable                                      ; read second operand of + (type table pointer)
  add rax, r12                                                   ; finally offset all of that by the start of the type table itself (result in testByte)
  bt qword ptr [rax], 002h                                       ; check that num is Integer
  jc func$hex$num$TypeMatch                                      ; skip next block if the type matches
    ; Error handling block for num
    ;  - print(parameterTypeCheckFailureMessage)
    ; Call __print with 1 arguments
    mov r13, offset parameterTypeCheckFailureMessage             ; reading parameterTypeCheckFailureMessage for push
    push r13                                                     ; value of argument #1 (parameterTypeCheckFailureMessage)
    push 01ah                                                    ; type of argument #1 (String'26)
    lea r14, qword ptr [rsp + 020h]                              ; load address of return value's value
    push r14                                                     ; internal argument 6: pointer to return value slot's value
    lea r14, qword ptr [rsp + 020h]                              ; load address of return value's type
    push r14                                                     ; internal argument 5: pointer to return value slot's type
    sub rsp, 020h                                                ; allocate shadow space
    mov r9, 000h                                                 ; internal argument 4: "this" pointer
    mov r8, 000h                                                 ; internal argument 3: "this" pointer type
    mov rdx, 000h                                                ; internal argument 2: closure pointer
    mov qword ptr [rsp + 040h], rcx                              ; move parameter count of hex value out of rcx
    mov rcx, 001h                                                ; internal argument 1: number of actual arguments
    call func$__print                                            ; jump to subroutine
    add rsp, 040h                                                ; release shadow space and arguments (result in stack pointer)
    ;  - exit(1)
    ; Call exit with 1 arguments
    push 001h                                                    ; value of argument #1 (1 (integer))
    push 019h                                                    ; type of argument #1 (Integer'25)
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
  func$hex$num$TypeMatch:                                        ; after block
  ; Line 87: __print('hex is not implemented\n');
  ; Call __print with 1 arguments
  mov r10, offset string$7                                       ; reading string for push
  push r10                                                       ; value of argument #1 (string)
  push 01ah                                                      ; type of argument #1 (String'26)
  lea rbx, qword ptr [rsp + 020h]                                ; load address of return value's value
  push rbx                                                       ; internal argument 6: pointer to return value slot's value
  lea rbx, qword ptr [rsp + 020h]                                ; load address of return value's type
  push rbx                                                       ; internal argument 5: pointer to return value slot's type
  sub rsp, 020h                                                  ; allocate shadow space
  mov r9, 000h                                                   ; internal argument 4: "this" pointer
  mov r8, 000h                                                   ; internal argument 3: "this" pointer type
  mov rdx, 000h                                                  ; internal argument 2: closure pointer
  mov qword ptr [rsp + 040h], rcx                                ; move parameter count of hex value out of rcx
  mov rcx, 001h                                                  ; internal argument 1: number of actual arguments
  call func$__print                                              ; jump to subroutine
  add rsp, 040h                                                  ; release shadow space and arguments (result in stack pointer)
  ; Line 88: exit(1);
  ; Call exit with 1 arguments
  push 001h                                                      ; value of argument #1 (1)
  push 019h                                                      ; type of argument #1 (Integer'25)
  lea rsi, qword ptr [rsp + 020h]                                ; load address of return value's value
  push rsi                                                       ; internal argument 6: pointer to return value slot's value
  lea rsi, qword ptr [rsp + 020h]                                ; load address of return value's type
  push rsi                                                       ; internal argument 5: pointer to return value slot's type
  sub rsp, 020h                                                  ; allocate shadow space
  mov r9, 000h                                                   ; internal argument 4: "this" pointer
  mov r8, 000h                                                   ; internal argument 3: "this" pointer type
  mov rdx, 000h                                                  ; internal argument 2: closure pointer
  mov rcx, 001h                                                  ; internal argument 1: number of actual arguments
  call func$exit                                                 ; jump to subroutine
  add rsp, 040h                                                  ; release shadow space and arguments (result in stack pointer)
  ; Implicit return from hex
  mov rax, 017h                                                  ; move type of null to testByte
  mov rdi, 002h                                                  ; read operand of mul (type table width in bytes) 
  mul rdi                                                        ; adjust to the relative start of that type's entry in the type table
  mov r12, offset typeTable                                      ; read second operand of + (type table pointer)
  add rax, r12                                                   ; finally offset all of that by the start of the type table itself (result in testByte)
  bt qword ptr [rax], 003h                                       ; check that hex return value is String
  jc func$hex$hexReturnValue$TypeMatch                           ; skip next block if the type matches
    ; Error handling block for hex return value
    ;  - print(returnValueTypeCheckFailureMessage)
    ; Call __print with 1 arguments
    mov r13, offset returnValueTypeCheckFailureMessage           ; reading returnValueTypeCheckFailureMessage for push
    push r13                                                     ; value of argument #1 (returnValueTypeCheckFailureMessage)
    push 01ah                                                    ; type of argument #1 (String'26)
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
    push 019h                                                    ; type of argument #1 (Integer'25)
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
  func$hex$hexReturnValue$TypeMatch:                             ; after block
  mov r10, qword ptr [rbp + 030h]                                ; get pointer to return value of hex into register to dereference it
  mov qword ptr [r10], 000h                                      ; hex return value
  mov rbx, qword ptr [rbp + 028h]                                ; get pointer to return value type of hex into register to dereference it
  mov qword ptr [rbx], 017h                                      ; type of hex return value (Null'23)
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

; readFile
dq func$readFile$annotation
func$readFile:
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
  cmp rcx, 001h                                                  ; compare parameter count of readFile to 1 (integer)
  je func$readFile$parameterCountCheck$continuation              ; check number of parameters is as expected
    ; Error handling block for parameter count
    ;  - print(parameterCountCheckFailureMessage)
    ; Call __print with 1 arguments
    mov r10, offset parameterCountCheckFailureMessage            ; reading parameterCountCheckFailureMessage for push
    push r10                                                     ; value of argument #1 (parameterCountCheckFailureMessage)
    push 01ah                                                    ; type of argument #1 (String'26)
    lea rax, qword ptr [rsp + 020h]                              ; load address of return value's value
    push rax                                                     ; internal argument 6: pointer to return value slot's value
    lea rax, qword ptr [rsp + 020h]                              ; load address of return value's type
    push rax                                                     ; internal argument 5: pointer to return value slot's type
    sub rsp, 020h                                                ; allocate shadow space
    mov r9, 000h                                                 ; internal argument 4: "this" pointer
    mov r8, 000h                                                 ; internal argument 3: "this" pointer type
    mov rdx, 000h                                                ; internal argument 2: closure pointer
    mov qword ptr [rsp + 040h], rcx                              ; move parameter count of readFile value out of rcx
    mov rcx, 001h                                                ; internal argument 1: number of actual arguments
    call func$__print                                            ; jump to subroutine
    add rsp, 040h                                                ; release shadow space and arguments (result in stack pointer)
    ;  - exit(1)
    ; Call exit with 1 arguments
    push 001h                                                    ; value of argument #1 (1 (integer))
    push 019h                                                    ; type of argument #1 (Integer'25)
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
  func$readFile$parameterCountCheck$continuation:                ; end of parameter count check
  ; Check type of parameter 0, file (expecting String)
  mov rsi, qword ptr [rbp + 038h]                                ; move type of file to testByte
  mov rax, rsi                                                   ; move testByte to testByte
  mov rdi, 002h                                                  ; read operand of mul (type table width in bytes) 
  mul rdi                                                        ; adjust to the relative start of that type's entry in the type table
  mov r12, offset typeTable                                      ; read second operand of + (type table pointer)
  add rax, r12                                                   ; finally offset all of that by the start of the type table itself (result in testByte)
  bt qword ptr [rax], 003h                                       ; check that file is String
  jc func$readFile$file$TypeMatch                                ; skip next block if the type matches
    ; Error handling block for file
    ;  - print(parameterTypeCheckFailureMessage)
    ; Call __print with 1 arguments
    mov r13, offset parameterTypeCheckFailureMessage             ; reading parameterTypeCheckFailureMessage for push
    push r13                                                     ; value of argument #1 (parameterTypeCheckFailureMessage)
    push 01ah                                                    ; type of argument #1 (String'26)
    lea r14, qword ptr [rsp + 020h]                              ; load address of return value's value
    push r14                                                     ; internal argument 6: pointer to return value slot's value
    lea r14, qword ptr [rsp + 020h]                              ; load address of return value's type
    push r14                                                     ; internal argument 5: pointer to return value slot's type
    sub rsp, 020h                                                ; allocate shadow space
    mov r9, 000h                                                 ; internal argument 4: "this" pointer
    mov r8, 000h                                                 ; internal argument 3: "this" pointer type
    mov rdx, 000h                                                ; internal argument 2: closure pointer
    mov qword ptr [rsp + 040h], rcx                              ; move parameter count of readFile value out of rcx
    mov rcx, 001h                                                ; internal argument 1: number of actual arguments
    call func$__print                                            ; jump to subroutine
    add rsp, 040h                                                ; release shadow space and arguments (result in stack pointer)
    ;  - exit(1)
    ; Call exit with 1 arguments
    push 001h                                                    ; value of argument #1 (1 (integer))
    push 019h                                                    ; type of argument #1 (Integer'25)
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
  func$readFile$file$TypeMatch:                                  ; after block
  ; Line 93: __print('readFile is not implemented\n');
  ; Call __print with 1 arguments
  mov r10, offset string$8                                       ; reading string for push
  push r10                                                       ; value of argument #1 (string)
  push 01ah                                                      ; type of argument #1 (String'26)
  lea rbx, qword ptr [rsp + 020h]                                ; load address of return value's value
  push rbx                                                       ; internal argument 6: pointer to return value slot's value
  lea rbx, qword ptr [rsp + 020h]                                ; load address of return value's type
  push rbx                                                       ; internal argument 5: pointer to return value slot's type
  sub rsp, 020h                                                  ; allocate shadow space
  mov r9, 000h                                                   ; internal argument 4: "this" pointer
  mov r8, 000h                                                   ; internal argument 3: "this" pointer type
  mov rdx, 000h                                                  ; internal argument 2: closure pointer
  mov qword ptr [rsp + 040h], rcx                                ; move parameter count of readFile value out of rcx
  mov rcx, 001h                                                  ; internal argument 1: number of actual arguments
  call func$__print                                              ; jump to subroutine
  add rsp, 040h                                                  ; release shadow space and arguments (result in stack pointer)
  ; Line 94: exit(1);
  ; Call exit with 1 arguments
  push 001h                                                      ; value of argument #1 (1)
  push 019h                                                      ; type of argument #1 (Integer'25)
  lea rsi, qword ptr [rsp + 020h]                                ; load address of return value's value
  push rsi                                                       ; internal argument 6: pointer to return value slot's value
  lea rsi, qword ptr [rsp + 020h]                                ; load address of return value's type
  push rsi                                                       ; internal argument 5: pointer to return value slot's type
  sub rsp, 020h                                                  ; allocate shadow space
  mov r9, 000h                                                   ; internal argument 4: "this" pointer
  mov r8, 000h                                                   ; internal argument 3: "this" pointer type
  mov rdx, 000h                                                  ; internal argument 2: closure pointer
  mov rcx, 001h                                                  ; internal argument 1: number of actual arguments
  call func$exit                                                 ; jump to subroutine
  add rsp, 040h                                                  ; release shadow space and arguments (result in stack pointer)
  ; Implicit return from readFile
  mov rax, 017h                                                  ; move type of null to testByte
  mov rdi, 002h                                                  ; read operand of mul (type table width in bytes) 
  mul rdi                                                        ; adjust to the relative start of that type's entry in the type table
  mov r12, offset typeTable                                      ; read second operand of + (type table pointer)
  add rax, r12                                                   ; finally offset all of that by the start of the type table itself (result in testByte)
  bt qword ptr [rax], 003h                                       ; check that readFile return value is String
  jc func$readFile$readfileReturnValue$TypeMatch                 ; skip next block if the type matches
    ; Error handling block for readFile return value
    ;  - print(returnValueTypeCheckFailureMessage)
    ; Call __print with 1 arguments
    mov r13, offset returnValueTypeCheckFailureMessage           ; reading returnValueTypeCheckFailureMessage for push
    push r13                                                     ; value of argument #1 (returnValueTypeCheckFailureMessage)
    push 01ah                                                    ; type of argument #1 (String'26)
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
    push 019h                                                    ; type of argument #1 (Integer'25)
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
  func$readFile$readfileReturnValue$TypeMatch:                   ; after block
  mov r10, qword ptr [rbp + 030h]                                ; get pointer to return value of readFile into register to dereference it
  mov qword ptr [r10], 000h                                      ; readFile return value
  mov rbx, qword ptr [rbp + 028h]                                ; get pointer to return value type of readFile into register to dereference it
  mov qword ptr [rbx], 017h                                      ; type of readFile return value (Null'23)
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

; stderr
dq func$stderr$annotation
func$stderr:
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
  cmp rcx, 001h                                                  ; compare parameter count of stderr to 1 (integer)
  je func$stderr$parameterCountCheck$continuation                ; check number of parameters is as expected
    ; Error handling block for parameter count
    ;  - print(parameterCountCheckFailureMessage)
    ; Call __print with 1 arguments
    mov r10, offset parameterCountCheckFailureMessage            ; reading parameterCountCheckFailureMessage for push
    push r10                                                     ; value of argument #1 (parameterCountCheckFailureMessage)
    push 01ah                                                    ; type of argument #1 (String'26)
    lea rax, qword ptr [rsp + 020h]                              ; load address of return value's value
    push rax                                                     ; internal argument 6: pointer to return value slot's value
    lea rax, qword ptr [rsp + 020h]                              ; load address of return value's type
    push rax                                                     ; internal argument 5: pointer to return value slot's type
    sub rsp, 020h                                                ; allocate shadow space
    mov r9, 000h                                                 ; internal argument 4: "this" pointer
    mov r8, 000h                                                 ; internal argument 3: "this" pointer type
    mov rdx, 000h                                                ; internal argument 2: closure pointer
    mov qword ptr [rsp + 040h], rcx                              ; move parameter count of stderr value out of rcx
    mov rcx, 001h                                                ; internal argument 1: number of actual arguments
    call func$__print                                            ; jump to subroutine
    add rsp, 040h                                                ; release shadow space and arguments (result in stack pointer)
    ;  - exit(1)
    ; Call exit with 1 arguments
    push 001h                                                    ; value of argument #1 (1 (integer))
    push 019h                                                    ; type of argument #1 (Integer'25)
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
  func$stderr$parameterCountCheck$continuation:                  ; end of parameter count check
  ; Check type of parameter 0, str (expecting String)
  mov rsi, qword ptr [rbp + 038h]                                ; move type of str to testByte
  mov rax, rsi                                                   ; move testByte to testByte
  mov rdi, 002h                                                  ; read operand of mul (type table width in bytes) 
  mul rdi                                                        ; adjust to the relative start of that type's entry in the type table
  mov r12, offset typeTable                                      ; read second operand of + (type table pointer)
  add rax, r12                                                   ; finally offset all of that by the start of the type table itself (result in testByte)
  bt qword ptr [rax], 003h                                       ; check that str is String
  jc func$stderr$str$TypeMatch                                   ; skip next block if the type matches
    ; Error handling block for str
    ;  - print(parameterTypeCheckFailureMessage)
    ; Call __print with 1 arguments
    mov r13, offset parameterTypeCheckFailureMessage             ; reading parameterTypeCheckFailureMessage for push
    push r13                                                     ; value of argument #1 (parameterTypeCheckFailureMessage)
    push 01ah                                                    ; type of argument #1 (String'26)
    lea r14, qword ptr [rsp + 020h]                              ; load address of return value's value
    push r14                                                     ; internal argument 6: pointer to return value slot's value
    lea r14, qword ptr [rsp + 020h]                              ; load address of return value's type
    push r14                                                     ; internal argument 5: pointer to return value slot's type
    sub rsp, 020h                                                ; allocate shadow space
    mov r9, 000h                                                 ; internal argument 4: "this" pointer
    mov r8, 000h                                                 ; internal argument 3: "this" pointer type
    mov rdx, 000h                                                ; internal argument 2: closure pointer
    mov qword ptr [rsp + 040h], rcx                              ; move parameter count of stderr value out of rcx
    mov rcx, 001h                                                ; internal argument 1: number of actual arguments
    call func$__print                                            ; jump to subroutine
    add rsp, 040h                                                ; release shadow space and arguments (result in stack pointer)
    ;  - exit(1)
    ; Call exit with 1 arguments
    push 001h                                                    ; value of argument #1 (1 (integer))
    push 019h                                                    ; type of argument #1 (Integer'25)
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
  func$stderr$str$TypeMatch:                                     ; after block
  ; Line 99: __print('stderr is not implemented\n');
  ; Call __print with 1 arguments
  mov r10, offset string$9                                       ; reading string for push
  push r10                                                       ; value of argument #1 (string)
  push 01ah                                                      ; type of argument #1 (String'26)
  lea rbx, qword ptr [rsp + 020h]                                ; load address of return value's value
  push rbx                                                       ; internal argument 6: pointer to return value slot's value
  lea rbx, qword ptr [rsp + 020h]                                ; load address of return value's type
  push rbx                                                       ; internal argument 5: pointer to return value slot's type
  sub rsp, 020h                                                  ; allocate shadow space
  mov r9, 000h                                                   ; internal argument 4: "this" pointer
  mov r8, 000h                                                   ; internal argument 3: "this" pointer type
  mov rdx, 000h                                                  ; internal argument 2: closure pointer
  mov qword ptr [rsp + 040h], rcx                                ; move parameter count of stderr value out of rcx
  mov rcx, 001h                                                  ; internal argument 1: number of actual arguments
  call func$__print                                              ; jump to subroutine
  add rsp, 040h                                                  ; release shadow space and arguments (result in stack pointer)
  ; Line 100: exit(1);
  ; Call exit with 1 arguments
  push 001h                                                      ; value of argument #1 (1)
  push 019h                                                      ; type of argument #1 (Integer'25)
  lea rsi, qword ptr [rsp + 020h]                                ; load address of return value's value
  push rsi                                                       ; internal argument 6: pointer to return value slot's value
  lea rsi, qword ptr [rsp + 020h]                                ; load address of return value's type
  push rsi                                                       ; internal argument 5: pointer to return value slot's type
  sub rsp, 020h                                                  ; allocate shadow space
  mov r9, 000h                                                   ; internal argument 4: "this" pointer
  mov r8, 000h                                                   ; internal argument 3: "this" pointer type
  mov rdx, 000h                                                  ; internal argument 2: closure pointer
  mov rcx, 001h                                                  ; internal argument 1: number of actual arguments
  call func$exit                                                 ; jump to subroutine
  add rsp, 040h                                                  ; release shadow space and arguments (result in stack pointer)
  ; Implicit return from stderr
  mov r13, qword ptr [rbp + 030h]                                ; get pointer to return value of stderr into register to dereference it
  mov qword ptr [r13], 000h                                      ; stderr return value
  mov r14, qword ptr [rbp + 028h]                                ; get pointer to return value type of stderr into register to dereference it
  mov qword ptr [r14], 017h                                      ; type of stderr return value (Null'23)
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
dq func$_moveBytes$annotation
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
  sub rsp, 080h                                                  ; allocate space for stack
  lea rbp, qword ptr [rsp + 0c0h]                                ; set up frame pointer
  ; Check parameter count
  cmp rcx, 003h                                                  ; compare parameter count of _moveBytes to 3 (integer)
  je func$_moveBytes$parameterCountCheck$continuation            ; check number of parameters is as expected
    ; Error handling block for parameter count
    ;  - print(parameterCountCheckFailureMessage)
    ; Call __print with 1 arguments
    mov r10, offset parameterCountCheckFailureMessage            ; reading parameterCountCheckFailureMessage for push
    push r10                                                     ; value of argument #1 (parameterCountCheckFailureMessage)
    push 01ah                                                    ; type of argument #1 (String'26)
    lea rax, qword ptr [rsp + 080h]                              ; load address of return value's value
    push rax                                                     ; internal argument 6: pointer to return value slot's value
    lea rax, qword ptr [rsp + 080h]                              ; load address of return value's type
    push rax                                                     ; internal argument 5: pointer to return value slot's type
    sub rsp, 020h                                                ; allocate shadow space
    mov r9, 000h                                                 ; internal argument 4: "this" pointer
    mov r8, 000h                                                 ; internal argument 3: "this" pointer type
    mov rdx, 000h                                                ; internal argument 2: closure pointer
    mov qword ptr [rsp + 0a0h], rcx                              ; move parameter count of _moveBytes value out of rcx
    mov rcx, 001h                                                ; internal argument 1: number of actual arguments
    call func$__print                                            ; jump to subroutine
    add rsp, 040h                                                ; release shadow space and arguments (result in stack pointer)
    ;  - exit(1)
    ; Call exit with 1 arguments
    push 001h                                                    ; value of argument #1 (1 (integer))
    push 019h                                                    ; type of argument #1 (Integer'25)
    lea rbx, qword ptr [rsp + 080h]                              ; load address of return value's value
    push rbx                                                     ; internal argument 6: pointer to return value slot's value
    lea rbx, qword ptr [rsp + 080h]                              ; load address of return value's type
    push rbx                                                     ; internal argument 5: pointer to return value slot's type
    sub rsp, 020h                                                ; allocate shadow space
    mov r9, 000h                                                 ; internal argument 4: "this" pointer
    mov r8, 000h                                                 ; internal argument 3: "this" pointer type
    mov rdx, 000h                                                ; internal argument 2: closure pointer
    mov rcx, 001h                                                ; internal argument 1: number of actual arguments
    call func$exit                                               ; jump to subroutine
    add rsp, 040h                                                ; release shadow space and arguments (result in stack pointer)
    mov rcx, qword ptr [rsp + 060h]                              ; restoring slots to previous scope state
  func$_moveBytes$parameterCountCheck$continuation:              ; end of parameter count check
  ; Check type of parameter 0, from (expecting Integer)
  mov rsi, qword ptr [rbp + 038h]                                ; move type of from to testByte
  mov rax, rsi                                                   ; move testByte to testByte
  mov rdi, 002h                                                  ; read operand of mul (type table width in bytes) 
  mul rdi                                                        ; adjust to the relative start of that type's entry in the type table
  mov r12, offset typeTable                                      ; read second operand of + (type table pointer)
  add rax, r12                                                   ; finally offset all of that by the start of the type table itself (result in testByte)
  bt qword ptr [rax], 002h                                       ; check that from is Integer
  jc func$_moveBytes$from$TypeMatch                              ; skip next block if the type matches
    ; Error handling block for from
    ;  - print(parameterTypeCheckFailureMessage)
    ; Call __print with 1 arguments
    mov r13, offset parameterTypeCheckFailureMessage             ; reading parameterTypeCheckFailureMessage for push
    push r13                                                     ; value of argument #1 (parameterTypeCheckFailureMessage)
    push 01ah                                                    ; type of argument #1 (String'26)
    lea r14, qword ptr [rsp + 080h]                              ; load address of return value's value
    push r14                                                     ; internal argument 6: pointer to return value slot's value
    lea r14, qword ptr [rsp + 080h]                              ; load address of return value's type
    push r14                                                     ; internal argument 5: pointer to return value slot's type
    sub rsp, 020h                                                ; allocate shadow space
    mov r9, 000h                                                 ; internal argument 4: "this" pointer
    mov r8, 000h                                                 ; internal argument 3: "this" pointer type
    mov rdx, 000h                                                ; internal argument 2: closure pointer
    mov qword ptr [rsp + 0a0h], rcx                              ; move parameter count of _moveBytes value out of rcx
    mov rcx, 001h                                                ; internal argument 1: number of actual arguments
    call func$__print                                            ; jump to subroutine
    add rsp, 040h                                                ; release shadow space and arguments (result in stack pointer)
    ;  - exit(1)
    ; Call exit with 1 arguments
    push 001h                                                    ; value of argument #1 (1 (integer))
    push 019h                                                    ; type of argument #1 (Integer'25)
    lea r15, qword ptr [rsp + 080h]                              ; load address of return value's value
    push r15                                                     ; internal argument 6: pointer to return value slot's value
    lea r15, qword ptr [rsp + 080h]                              ; load address of return value's type
    push r15                                                     ; internal argument 5: pointer to return value slot's type
    sub rsp, 020h                                                ; allocate shadow space
    mov r9, 000h                                                 ; internal argument 4: "this" pointer
    mov r8, 000h                                                 ; internal argument 3: "this" pointer type
    mov rdx, 000h                                                ; internal argument 2: closure pointer
    mov rcx, 001h                                                ; internal argument 1: number of actual arguments
    call func$exit                                               ; jump to subroutine
    add rsp, 040h                                                ; release shadow space and arguments (result in stack pointer)
    mov rcx, qword ptr [rsp + 060h]                              ; restoring slots to previous scope state
  func$_moveBytes$from$TypeMatch:                                ; after block
  ; Check type of parameter 1, to (expecting Integer)
  mov r10, qword ptr [rbp + 048h]                                ; move type of to to testByte
  mov rax, r10                                                   ; move testByte to testByte
  mov rbx, 002h                                                  ; read operand of mul (type table width in bytes) 
  mul rbx                                                        ; adjust to the relative start of that type's entry in the type table
  mov rsi, offset typeTable                                      ; read second operand of + (type table pointer)
  add rax, rsi                                                   ; finally offset all of that by the start of the type table itself (result in testByte)
  bt qword ptr [rax], 002h                                       ; check that to is Integer
  jc func$_moveBytes$to$TypeMatch                                ; skip next block if the type matches
    ; Error handling block for to
    ;  - print(parameterTypeCheckFailureMessage)
    ; Call __print with 1 arguments
    mov rdi, offset parameterTypeCheckFailureMessage             ; reading parameterTypeCheckFailureMessage for push
    push rdi                                                     ; value of argument #1 (parameterTypeCheckFailureMessage)
    push 01ah                                                    ; type of argument #1 (String'26)
    lea r12, qword ptr [rsp + 080h]                              ; load address of return value's value
    push r12                                                     ; internal argument 6: pointer to return value slot's value
    lea r12, qword ptr [rsp + 080h]                              ; load address of return value's type
    push r12                                                     ; internal argument 5: pointer to return value slot's type
    sub rsp, 020h                                                ; allocate shadow space
    mov r9, 000h                                                 ; internal argument 4: "this" pointer
    mov r8, 000h                                                 ; internal argument 3: "this" pointer type
    mov rdx, 000h                                                ; internal argument 2: closure pointer
    mov qword ptr [rsp + 0a0h], rcx                              ; move parameter count of _moveBytes value out of rcx
    mov rcx, 001h                                                ; internal argument 1: number of actual arguments
    call func$__print                                            ; jump to subroutine
    add rsp, 040h                                                ; release shadow space and arguments (result in stack pointer)
    ;  - exit(1)
    ; Call exit with 1 arguments
    push 001h                                                    ; value of argument #1 (1 (integer))
    push 019h                                                    ; type of argument #1 (Integer'25)
    lea r13, qword ptr [rsp + 080h]                              ; load address of return value's value
    push r13                                                     ; internal argument 6: pointer to return value slot's value
    lea r13, qword ptr [rsp + 080h]                              ; load address of return value's type
    push r13                                                     ; internal argument 5: pointer to return value slot's type
    sub rsp, 020h                                                ; allocate shadow space
    mov r9, 000h                                                 ; internal argument 4: "this" pointer
    mov r8, 000h                                                 ; internal argument 3: "this" pointer type
    mov rdx, 000h                                                ; internal argument 2: closure pointer
    mov rcx, 001h                                                ; internal argument 1: number of actual arguments
    call func$exit                                               ; jump to subroutine
    add rsp, 040h                                                ; release shadow space and arguments (result in stack pointer)
    mov rcx, qword ptr [rsp + 060h]                              ; restoring slots to previous scope state
  func$_moveBytes$to$TypeMatch:                                  ; after block
  ; Check type of parameter 2, length (expecting Integer)
  mov r14, qword ptr [rbp + 058h]                                ; move type of length to testByte
  mov rax, r14                                                   ; move testByte to testByte
  mov r15, 002h                                                  ; read operand of mul (type table width in bytes) 
  mul r15                                                        ; adjust to the relative start of that type's entry in the type table
  mov r10, offset typeTable                                      ; read second operand of + (type table pointer)
  add rax, r10                                                   ; finally offset all of that by the start of the type table itself (result in testByte)
  bt qword ptr [rax], 002h                                       ; check that length is Integer
  jc func$_moveBytes$length$TypeMatch                            ; skip next block if the type matches
    ; Error handling block for length
    ;  - print(parameterTypeCheckFailureMessage)
    ; Call __print with 1 arguments
    mov rbx, offset parameterTypeCheckFailureMessage             ; reading parameterTypeCheckFailureMessage for push
    push rbx                                                     ; value of argument #1 (parameterTypeCheckFailureMessage)
    push 01ah                                                    ; type of argument #1 (String'26)
    lea rsi, qword ptr [rsp + 080h]                              ; load address of return value's value
    push rsi                                                     ; internal argument 6: pointer to return value slot's value
    lea rsi, qword ptr [rsp + 080h]                              ; load address of return value's type
    push rsi                                                     ; internal argument 5: pointer to return value slot's type
    sub rsp, 020h                                                ; allocate shadow space
    mov r9, 000h                                                 ; internal argument 4: "this" pointer
    mov r8, 000h                                                 ; internal argument 3: "this" pointer type
    mov rdx, 000h                                                ; internal argument 2: closure pointer
    mov qword ptr [rsp + 0a0h], rcx                              ; move parameter count of _moveBytes value out of rcx
    mov rcx, 001h                                                ; internal argument 1: number of actual arguments
    call func$__print                                            ; jump to subroutine
    add rsp, 040h                                                ; release shadow space and arguments (result in stack pointer)
    ;  - exit(1)
    ; Call exit with 1 arguments
    push 001h                                                    ; value of argument #1 (1 (integer))
    push 019h                                                    ; type of argument #1 (Integer'25)
    lea rdi, qword ptr [rsp + 080h]                              ; load address of return value's value
    push rdi                                                     ; internal argument 6: pointer to return value slot's value
    lea rdi, qword ptr [rsp + 080h]                              ; load address of return value's type
    push rdi                                                     ; internal argument 5: pointer to return value slot's type
    sub rsp, 020h                                                ; allocate shadow space
    mov r9, 000h                                                 ; internal argument 4: "this" pointer
    mov r8, 000h                                                 ; internal argument 3: "this" pointer type
    mov rdx, 000h                                                ; internal argument 2: closure pointer
    mov rcx, 001h                                                ; internal argument 1: number of actual arguments
    call func$exit                                               ; jump to subroutine
    add rsp, 040h                                                ; release shadow space and arguments (result in stack pointer)
    mov rcx, qword ptr [rsp + 060h]                              ; restoring slots to previous scope state
  func$_moveBytes$length$TypeMatch:                              ; after block
  ; Line 106: assert(length > 0, '_moveBytes expects positive number of bytes ...
  cmp qword ptr [rbp + 058h], 000h                               ; compare type of length to <sentinel>
  jne func$_moveBytes$length$TypeMatch$1                         ; skip next block if length is not sentinel
    ; Error handling block for length
    ;  - print(operandTypeCheckFailureMessage)
    ; Call __print with 1 arguments
    mov r12, offset operandTypeCheckFailureMessage               ; reading operandTypeCheckFailureMessage for push
    push r12                                                     ; value of argument #1 (operandTypeCheckFailureMessage)
    push 01ah                                                    ; type of argument #1 (String'26)
    lea r13, qword ptr [rsp + 080h]                              ; load address of return value's value
    push r13                                                     ; internal argument 6: pointer to return value slot's value
    lea r13, qword ptr [rsp + 080h]                              ; load address of return value's type
    push r13                                                     ; internal argument 5: pointer to return value slot's type
    sub rsp, 020h                                                ; allocate shadow space
    mov r9, 000h                                                 ; internal argument 4: "this" pointer
    mov r8, 000h                                                 ; internal argument 3: "this" pointer type
    mov rdx, 000h                                                ; internal argument 2: closure pointer
    mov qword ptr [rsp + 0a0h], rcx                              ; move parameter count of _moveBytes value out of rcx
    mov rcx, 001h                                                ; internal argument 1: number of actual arguments
    call func$__print                                            ; jump to subroutine
    add rsp, 040h                                                ; release shadow space and arguments (result in stack pointer)
    ;  - exit(1)
    ; Call exit with 1 arguments
    push 001h                                                    ; value of argument #1 (1 (integer))
    push 019h                                                    ; type of argument #1 (Integer'25)
    lea r14, qword ptr [rsp + 080h]                              ; load address of return value's value
    push r14                                                     ; internal argument 6: pointer to return value slot's value
    lea r14, qword ptr [rsp + 080h]                              ; load address of return value's type
    push r14                                                     ; internal argument 5: pointer to return value slot's type
    sub rsp, 020h                                                ; allocate shadow space
    mov r9, 000h                                                 ; internal argument 4: "this" pointer
    mov r8, 000h                                                 ; internal argument 3: "this" pointer type
    mov rdx, 000h                                                ; internal argument 2: closure pointer
    mov rcx, 001h                                                ; internal argument 1: number of actual arguments
    call func$exit                                               ; jump to subroutine
    add rsp, 040h                                                ; release shadow space and arguments (result in stack pointer)
    mov rcx, qword ptr [rsp + 060h]                              ; restoring slots to previous scope state
  func$_moveBytes$length$TypeMatch$1:                            ; after block
  xor rbx, rbx                                                   ; clear > operator result
  cmp qword ptr [rbp + 060h], 000h                               ; compare length with 0
  setg bl                                                        ; store result in > operator result
  mov rsi, 018h                                                  ; > operator result is of type Boolean'24
  ; Call assert with 2 arguments
  mov rdi, offset string$10                                      ; reading string for push
  push rdi                                                       ; value of argument #2 (string)
  push 01ah                                                      ; type of argument #2 (String'26)
  push rbx                                                       ; value of argument #1 (> operator result)
  push rsi                                                       ; type of argument #1
  lea r12, qword ptr [rsp + 090h]                                ; load address of return value's value
  push r12                                                       ; internal argument 6: pointer to return value slot's value
  lea r12, qword ptr [rsp + 090h]                                ; load address of return value's type
  push r12                                                       ; internal argument 5: pointer to return value slot's type
  sub rsp, 020h                                                  ; allocate shadow space
  mov r9, 000h                                                   ; internal argument 4: "this" pointer
  mov r8, 000h                                                   ; internal argument 3: "this" pointer type
  mov rdx, 000h                                                  ; internal argument 2: closure pointer
  mov qword ptr [rsp + 0b0h], rcx                                ; move parameter count of _moveBytes value out of rcx
  mov rcx, 002h                                                  ; internal argument 1: number of actual arguments
  call func$assert                                               ; jump to subroutine
  add rsp, 050h                                                  ; release shadow space and arguments (result in stack pointer)
  ; Line 107: Integer fromCursor = from;
  mov r13, qword ptr [rbp + 040h]                                ; value initialization of variable declaration for fromCursor variable (from)
  mov r14, qword ptr [rbp + 038h]                                ; type initialization of variable declaration for fromCursor variable
  ; Line 108: Integer toCursor = to;
  mov rax, qword ptr [rbp + 050h]                                ; value initialization of variable declaration for toCursor variable (to)
  mov r15, qword ptr [rbp + 048h]                                ; type initialization of variable declaration for toCursor variable
  ; Line 109: Integer end = from + length / 8 * 8;
  cmp qword ptr [rbp + 058h], 000h                               ; compare type of length to <sentinel>
  jne func$_moveBytes$length$TypeMatch$2                         ; skip next block if length is not sentinel
    ; Error handling block for length
    ;  - print(operandTypeCheckFailureMessage)
    ; Call __print with 1 arguments
    mov r10, offset operandTypeCheckFailureMessage               ; reading operandTypeCheckFailureMessage for push
    push r10                                                     ; value of argument #1 (operandTypeCheckFailureMessage)
    push 01ah                                                    ; type of argument #1 (String'26)
    lea rbx, qword ptr [rsp + 080h]                              ; load address of return value's value
    push rbx                                                     ; internal argument 6: pointer to return value slot's value
    lea rbx, qword ptr [rsp + 080h]                              ; load address of return value's type
    push rbx                                                     ; internal argument 5: pointer to return value slot's type
    sub rsp, 020h                                                ; allocate shadow space
    mov r9, 000h                                                 ; internal argument 4: "this" pointer
    mov r8, 000h                                                 ; internal argument 3: "this" pointer type
    mov rdx, 000h                                                ; internal argument 2: closure pointer
    mov rcx, 001h                                                ; internal argument 1: number of actual arguments
    mov qword ptr [rsp + 098h], rax                              ; move toCursor variable value out of rax
    call func$__print                                            ; jump to subroutine
    add rsp, 040h                                                ; release shadow space and arguments (result in stack pointer)
    ;  - exit(1)
    ; Call exit with 1 arguments
    push 001h                                                    ; value of argument #1 (1 (integer))
    push 019h                                                    ; type of argument #1 (Integer'25)
    lea rsi, qword ptr [rsp + 080h]                              ; load address of return value's value
    push rsi                                                     ; internal argument 6: pointer to return value slot's value
    lea rsi, qword ptr [rsp + 080h]                              ; load address of return value's type
    push rsi                                                     ; internal argument 5: pointer to return value slot's type
    sub rsp, 020h                                                ; allocate shadow space
    mov r9, 000h                                                 ; internal argument 4: "this" pointer
    mov r8, 000h                                                 ; internal argument 3: "this" pointer type
    mov rdx, 000h                                                ; internal argument 2: closure pointer
    mov rcx, 001h                                                ; internal argument 1: number of actual arguments
    call func$exit                                               ; jump to subroutine
    add rsp, 040h                                                ; release shadow space and arguments (result in stack pointer)
    mov rax, qword ptr [rsp + 058h]                              ; restoring slots to previous scope state
  func$_moveBytes$length$TypeMatch$2:                            ; after block
  mov qword ptr [rsp + 070h], rax                                ; move toCursor variable value out of rax
  mov rax, qword ptr [rbp + 060h]                                ; assign value of length to value of / operator result
  cqo                                                            ; zero-extend dividend
  mov qword ptr [rsp + 068h], r14                                ; move fromCursor variable type out of r14
  mov r14, 008h                                                  ; read operand of div (8) 
  idiv r14                                                       ; compute (length) / (8) (result, / operator result, is in rax)
  mov qword ptr [rsp + 058h], r15                                ; move toCursor variable type out of r15
  mov r15, 019h                                                  ; / operator result is of type Integer'25
  cmp r15, 000h                                                  ; compare type of / operator result to <sentinel>
  jne func$_moveBytes$length8$TypeMatch                          ; skip next block if / operator result is not sentinel
    ; Error handling block for length / 8
    ;  - print(operandTypeCheckFailureMessage)
    ; Call __print with 1 arguments
    mov r10, offset operandTypeCheckFailureMessage               ; reading operandTypeCheckFailureMessage for push
    push r10                                                     ; value of argument #1 (operandTypeCheckFailureMessage)
    push 01ah                                                    ; type of argument #1 (String'26)
    lea rbx, qword ptr [rsp + 060h]                              ; load address of return value's value
    push rbx                                                     ; internal argument 6: pointer to return value slot's value
    lea rbx, qword ptr [rsp + 060h]                              ; load address of return value's type
    push rbx                                                     ; internal argument 5: pointer to return value slot's type
    sub rsp, 020h                                                ; allocate shadow space
    mov r9, 000h                                                 ; internal argument 4: "this" pointer
    mov r8, 000h                                                 ; internal argument 3: "this" pointer type
    mov rdx, 000h                                                ; internal argument 2: closure pointer
    mov rcx, 001h                                                ; internal argument 1: number of actual arguments
    mov qword ptr [rsp + 080h], rax                              ; move / operator result value out of rax
    call func$__print                                            ; jump to subroutine
    add rsp, 040h                                                ; release shadow space and arguments (result in stack pointer)
    ;  - exit(1)
    ; Call exit with 1 arguments
    push 001h                                                    ; value of argument #1 (1 (integer))
    push 019h                                                    ; type of argument #1 (Integer'25)
    lea rsi, qword ptr [rsp + 060h]                              ; load address of return value's value
    push rsi                                                     ; internal argument 6: pointer to return value slot's value
    lea rsi, qword ptr [rsp + 060h]                              ; load address of return value's type
    push rsi                                                     ; internal argument 5: pointer to return value slot's type
    sub rsp, 020h                                                ; allocate shadow space
    mov r9, 000h                                                 ; internal argument 4: "this" pointer
    mov r8, 000h                                                 ; internal argument 3: "this" pointer type
    mov rdx, 000h                                                ; internal argument 2: closure pointer
    mov rcx, 001h                                                ; internal argument 1: number of actual arguments
    call func$exit                                               ; jump to subroutine
    add rsp, 040h                                                ; release shadow space and arguments (result in stack pointer)
    mov rax, qword ptr [rsp + 040h]                              ; restoring slots to previous scope state
  func$_moveBytes$length8$TypeMatch:                             ; after block
  mov qword ptr [rsp + 050h], rax                                ; move / operator result value out of rax
  mov r14, qword ptr [rsp + 050h]                                ; read left hand side operand of imul (/ operator result)
  imul rax, r14, 008h                                            ; compute (/ operator result) * (8) (result in * operator result)
  mov r15, 019h                                                  ; * operator result is of type Integer'25
  cmp qword ptr [rbp + 038h], 000h                               ; compare type of from to <sentinel>
  jne func$_moveBytes$from$TypeMatch$1                           ; skip next block if from is not sentinel
    ; Error handling block for from
    ;  - print(operandTypeCheckFailureMessage)
    ; Call __print with 1 arguments
    mov r10, offset operandTypeCheckFailureMessage               ; reading operandTypeCheckFailureMessage for push
    push r10                                                     ; value of argument #1 (operandTypeCheckFailureMessage)
    push 01ah                                                    ; type of argument #1 (String'26)
    lea rbx, qword ptr [rsp + 060h]                              ; load address of return value's value
    push rbx                                                     ; internal argument 6: pointer to return value slot's value
    lea rbx, qword ptr [rsp + 060h]                              ; load address of return value's type
    push rbx                                                     ; internal argument 5: pointer to return value slot's type
    sub rsp, 020h                                                ; allocate shadow space
    mov r9, 000h                                                 ; internal argument 4: "this" pointer
    mov r8, 000h                                                 ; internal argument 3: "this" pointer type
    mov rdx, 000h                                                ; internal argument 2: closure pointer
    mov rcx, 001h                                                ; internal argument 1: number of actual arguments
    mov qword ptr [rsp + 080h], rax                              ; move * operator result value out of rax
    call func$__print                                            ; jump to subroutine
    add rsp, 040h                                                ; release shadow space and arguments (result in stack pointer)
    ;  - exit(1)
    ; Call exit with 1 arguments
    push 001h                                                    ; value of argument #1 (1 (integer))
    push 019h                                                    ; type of argument #1 (Integer'25)
    lea rsi, qword ptr [rsp + 060h]                              ; load address of return value's value
    push rsi                                                     ; internal argument 6: pointer to return value slot's value
    lea rsi, qword ptr [rsp + 060h]                              ; load address of return value's type
    push rsi                                                     ; internal argument 5: pointer to return value slot's type
    sub rsp, 020h                                                ; allocate shadow space
    mov r9, 000h                                                 ; internal argument 4: "this" pointer
    mov r8, 000h                                                 ; internal argument 3: "this" pointer type
    mov rdx, 000h                                                ; internal argument 2: closure pointer
    mov rcx, 001h                                                ; internal argument 1: number of actual arguments
    call func$exit                                               ; jump to subroutine
    add rsp, 040h                                                ; release shadow space and arguments (result in stack pointer)
    mov rax, qword ptr [rsp + 040h]                              ; restoring slots to previous scope state
  func$_moveBytes$from$TypeMatch$1:                              ; after block
  cmp r15, 000h                                                  ; compare type of * operator result to <sentinel>
  jne func$_moveBytes$length88$TypeMatch                         ; skip next block if * operator result is not sentinel
    ; Error handling block for length / 8 * 8
    ;  - print(operandTypeCheckFailureMessage)
    ; Call __print with 1 arguments
    mov rdi, offset operandTypeCheckFailureMessage               ; reading operandTypeCheckFailureMessage for push
    push rdi                                                     ; value of argument #1 (operandTypeCheckFailureMessage)
    push 01ah                                                    ; type of argument #1 (String'26)
    lea r12, qword ptr [rsp + 060h]                              ; load address of return value's value
    push r12                                                     ; internal argument 6: pointer to return value slot's value
    lea r12, qword ptr [rsp + 060h]                              ; load address of return value's type
    push r12                                                     ; internal argument 5: pointer to return value slot's type
    sub rsp, 020h                                                ; allocate shadow space
    mov r9, 000h                                                 ; internal argument 4: "this" pointer
    mov r8, 000h                                                 ; internal argument 3: "this" pointer type
    mov rdx, 000h                                                ; internal argument 2: closure pointer
    mov rcx, 001h                                                ; internal argument 1: number of actual arguments
    mov qword ptr [rsp + 080h], rax                              ; move * operator result value out of rax
    call func$__print                                            ; jump to subroutine
    add rsp, 040h                                                ; release shadow space and arguments (result in stack pointer)
    ;  - exit(1)
    ; Call exit with 1 arguments
    push 001h                                                    ; value of argument #1 (1 (integer))
    push 019h                                                    ; type of argument #1 (Integer'25)
    mov qword ptr [rsp + 058h], r13                              ; move fromCursor variable value out of r13
    lea r13, qword ptr [rsp + 060h]                              ; load address of return value's value
    push r13                                                     ; internal argument 6: pointer to return value slot's value
    lea r13, qword ptr [rsp + 050h]                              ; load address of return value's type
    push r13                                                     ; internal argument 5: pointer to return value slot's type
    sub rsp, 020h                                                ; allocate shadow space
    mov r9, 000h                                                 ; internal argument 4: "this" pointer
    mov r8, 000h                                                 ; internal argument 3: "this" pointer type
    mov rdx, 000h                                                ; internal argument 2: closure pointer
    mov rcx, 001h                                                ; internal argument 1: number of actual arguments
    call func$exit                                               ; jump to subroutine
    add rsp, 040h                                                ; release shadow space and arguments (result in stack pointer)
    mov rax, qword ptr [rsp + 040h]                              ; restoring slots to previous scope state
    mov r13, qword ptr [rsp + 048h]                              ; restoring slots to previous scope state
  func$_moveBytes$length88$TypeMatch:                            ; after block
  mov qword ptr [rsp + 050h], rax                                ; move * operator result value out of rax
  mov rax, qword ptr [rbp + 040h]                                ; assign value of from to value of + operator result
  add rax, qword ptr [rsp + 050h]                                ; compute (from) + (* operator result) (result in + operator result)
  mov r14, 019h                                                  ; + operator result is of type Integer'25
  mov r15, rax                                                   ; value initialization of variable declaration for end variable (+ operator result)
  mov r10, r14                                                   ; type initialization of variable declaration for end variable
  func$_moveBytes$while$top:                                     ; top of while
    cmp qword ptr [rsp + 068h], 000h                             ; compare type of fromCursor variable to <sentinel>
    jne func$_moveBytes$while$fromcursor$TypeMatch               ; skip next block if fromCursor variable is not sentinel
      ; Error handling block for fromCursor
      ;  - print(operandTypeCheckFailureMessage)
      ; Call __print with 1 arguments
      mov rbx, offset operandTypeCheckFailureMessage             ; reading operandTypeCheckFailureMessage for push
      push rbx                                                   ; value of argument #1 (operandTypeCheckFailureMessage)
      push 01ah                                                  ; type of argument #1 (String'26)
      lea rsi, qword ptr [rsp + 060h]                            ; load address of return value's value
      push rsi                                                   ; internal argument 6: pointer to return value slot's value
      lea rsi, qword ptr [rsp + 060h]                            ; load address of return value's type
      push rsi                                                   ; internal argument 5: pointer to return value slot's type
      sub rsp, 020h                                              ; allocate shadow space
      mov r9, 000h                                               ; internal argument 4: "this" pointer
      mov r8, 000h                                               ; internal argument 3: "this" pointer type
      mov rdx, 000h                                              ; internal argument 2: closure pointer
      mov rcx, 001h                                              ; internal argument 1: number of actual arguments
      mov qword ptr [rsp + 080h], r10                            ; move end variable type out of r10
      call func$__print                                          ; jump to subroutine
      add rsp, 040h                                              ; release shadow space and arguments (result in stack pointer)
      ;  - exit(1)
      ; Call exit with 1 arguments
      push 001h                                                  ; value of argument #1 (1 (integer))
      push 019h                                                  ; type of argument #1 (Integer'25)
      lea rdi, qword ptr [rsp + 060h]                            ; load address of return value's value
      push rdi                                                   ; internal argument 6: pointer to return value slot's value
      lea rdi, qword ptr [rsp + 060h]                            ; load address of return value's type
      push rdi                                                   ; internal argument 5: pointer to return value slot's type
      sub rsp, 020h                                              ; allocate shadow space
      mov r9, 000h                                               ; internal argument 4: "this" pointer
      mov r8, 000h                                               ; internal argument 3: "this" pointer type
      mov rdx, 000h                                              ; internal argument 2: closure pointer
      mov rcx, 001h                                              ; internal argument 1: number of actual arguments
      call func$exit                                             ; jump to subroutine
      add rsp, 040h                                              ; release shadow space and arguments (result in stack pointer)
      mov r10, qword ptr [rsp + 040h]                            ; restoring slots to previous scope state
    func$_moveBytes$while$fromcursor$TypeMatch:                  ; after block
    cmp r10, 000h                                                ; compare type of end variable to <sentinel>
    jne func$_moveBytes$while$end$TypeMatch                      ; skip next block if end variable is not sentinel
      ; Error handling block for end
      ;  - print(operandTypeCheckFailureMessage)
      ; Call __print with 1 arguments
      mov r12, offset operandTypeCheckFailureMessage             ; reading operandTypeCheckFailureMessage for push
      push r12                                                   ; value of argument #1 (operandTypeCheckFailureMessage)
      push 01ah                                                  ; type of argument #1 (String'26)
      mov qword ptr [rsp + 058h], r13                            ; move fromCursor variable value out of r13
      lea r13, qword ptr [rsp + 060h]                            ; load address of return value's value
      push r13                                                   ; internal argument 6: pointer to return value slot's value
      lea r13, qword ptr [rsp + 058h]                            ; load address of return value's type
      push r13                                                   ; internal argument 5: pointer to return value slot's type
      sub rsp, 020h                                              ; allocate shadow space
      mov r9, 000h                                               ; internal argument 4: "this" pointer
      mov r8, 000h                                               ; internal argument 3: "this" pointer type
      mov rdx, 000h                                              ; internal argument 2: closure pointer
      mov rcx, 001h                                              ; internal argument 1: number of actual arguments
      mov qword ptr [rsp + 078h], r10                            ; move end variable type out of r10
      call func$__print                                          ; jump to subroutine
      add rsp, 040h                                              ; release shadow space and arguments (result in stack pointer)
      ;  - exit(1)
      ; Call exit with 1 arguments
      push 001h                                                  ; value of argument #1 (1 (integer))
      push 019h                                                  ; type of argument #1 (Integer'25)
      lea rax, qword ptr [rsp + 060h]                            ; load address of return value's value
      push rax                                                   ; internal argument 6: pointer to return value slot's value
      lea rax, qword ptr [rsp + 058h]                            ; load address of return value's type
      push rax                                                   ; internal argument 5: pointer to return value slot's type
      sub rsp, 020h                                              ; allocate shadow space
      mov r9, 000h                                               ; internal argument 4: "this" pointer
      mov r8, 000h                                               ; internal argument 3: "this" pointer type
      mov rdx, 000h                                              ; internal argument 2: closure pointer
      mov rcx, 001h                                              ; internal argument 1: number of actual arguments
      call func$exit                                             ; jump to subroutine
      add rsp, 040h                                              ; release shadow space and arguments (result in stack pointer)
      mov r13, qword ptr [rsp + 048h]                            ; restoring slots to previous scope state
      mov r10, qword ptr [rsp + 038h]                            ; restoring slots to previous scope state
    func$_moveBytes$while$end$TypeMatch:                         ; after block
    xor r14, r14                                                 ; clear < operator result
    cmp r13, r15                                                 ; compare fromCursor variable with end variable
    setl r14b                                                    ; store result in < operator result
    mov qword ptr [rsp + 050h], r15                              ; move end variable value out of r15
    mov r15, 018h                                                ; < operator result is of type Boolean'24
    cmp r14, 000h                                                ; compare < operator result to false
    jne func$_moveBytes$while$body                               ; while condition
    mov r15, qword ptr [rsp + 050h]                              ; restoring slots to previous scope state
    jmp func$_moveBytes$while$bottom                             ; break out of while
    func$_moveBytes$while$body:                                  ; start of while
    ; Line 114: Integer value = __readFromAddress(fromCursor);
    ; Call __readFromAddress with 1 arguments
    mov qword ptr [rsp + 048h], r10                              ; move end variable type out of r10
    mov r10, qword ptr [r13]                                     ; dereference first argument of __readFromAddress
    mov rbx, 019h                                                ; dereferenced fromCursor variable is of type Integer'25
    mov rsi, r10                                                 ; value initialization of variable declaration for value variable (dereferenced fromCursor variable)
    mov rdi, rbx                                                 ; type initialization of variable declaration for value variable
    ; Line 115: __writeToAddress(toCursor, value);
    ; Call __writeToAddress with 2 arguments
    mov r12, qword ptr [rsp + 070h]                              ; get toCursor variable into register to dereference it
    mov qword ptr [r12], rsi                                     ; __writeToAddress
    ; Line 116: fromCursor += 8;
    cmp qword ptr [rsp + 068h], 000h                             ; compare type of fromCursor variable to <sentinel>
    jne func$_moveBytes$while$fromcursorVariable$TypeMatch       ; skip next block if fromCursor variable is not sentinel
      ; Error handling block for fromCursor variable
      ;  - print(operandTypeCheckFailureMessage)
      ; Call __print with 1 arguments
      mov qword ptr [rsp + 070h], r13                            ; move fromCursor variable value out of r13
      mov r13, offset operandTypeCheckFailureMessage             ; reading operandTypeCheckFailureMessage for push
      push r13                                                   ; value of argument #1 (operandTypeCheckFailureMessage)
      push 01ah                                                  ; type of argument #1 (String'26)
      lea rax, qword ptr [rsp + 050h]                            ; load address of return value's value
      push rax                                                   ; internal argument 6: pointer to return value slot's value
      lea rax, qword ptr [rsp + 050h]                            ; load address of return value's type
      push rax                                                   ; internal argument 5: pointer to return value slot's type
      sub rsp, 020h                                              ; allocate shadow space
      mov r9, 000h                                               ; internal argument 4: "this" pointer
      mov r8, 000h                                               ; internal argument 3: "this" pointer type
      mov rdx, 000h                                              ; internal argument 2: closure pointer
      mov rcx, 001h                                              ; internal argument 1: number of actual arguments
      call func$__print                                          ; jump to subroutine
      add rsp, 040h                                              ; release shadow space and arguments (result in stack pointer)
      ;  - exit(1)
      ; Call exit with 1 arguments
      push 001h                                                  ; value of argument #1 (1 (integer))
      push 019h                                                  ; type of argument #1 (Integer'25)
      lea r14, qword ptr [rsp + 050h]                            ; load address of return value's value
      push r14                                                   ; internal argument 6: pointer to return value slot's value
      lea r14, qword ptr [rsp + 050h]                            ; load address of return value's type
      push r14                                                   ; internal argument 5: pointer to return value slot's type
      sub rsp, 020h                                              ; allocate shadow space
      mov r9, 000h                                               ; internal argument 4: "this" pointer
      mov r8, 000h                                               ; internal argument 3: "this" pointer type
      mov rdx, 000h                                              ; internal argument 2: closure pointer
      mov rcx, 001h                                              ; internal argument 1: number of actual arguments
      call func$exit                                             ; jump to subroutine
      add rsp, 040h                                              ; release shadow space and arguments (result in stack pointer)
      mov r13, qword ptr [rsp + 070h]                            ; restoring slots to previous scope state
    func$_moveBytes$while$fromcursorVariable$TypeMatch:          ; after block
    mov rsi, r13                                                 ; assign value of fromCursor variable to value of += operator result
    add rsi, 008h                                                ; += operator
    mov rdi, 019h                                                ; += operator result is of type Integer'25
    mov r13, rsi                                                 ; store value
    mov qword ptr [rsp + 068h], rdi                              ; store type
    ; Line 117: toCursor += 8;
    cmp qword ptr [rsp + 058h], 000h                             ; compare type of toCursor variable to <sentinel>
    jne func$_moveBytes$while$tocursorVariable$TypeMatch         ; skip next block if toCursor variable is not sentinel
      ; Error handling block for toCursor variable
      ;  - print(operandTypeCheckFailureMessage)
      ; Call __print with 1 arguments
      mov qword ptr [rsp + 070h], r12                            ; move toCursor variable value out of r12
      mov r12, offset operandTypeCheckFailureMessage             ; reading operandTypeCheckFailureMessage for push
      push r12                                                   ; value of argument #1 (operandTypeCheckFailureMessage)
      push 01ah                                                  ; type of argument #1 (String'26)
      mov qword ptr [rsp + 048h], r13                            ; move fromCursor variable value out of r13
      lea r13, qword ptr [rsp + 050h]                            ; load address of return value's value
      push r13                                                   ; internal argument 6: pointer to return value slot's value
      lea r13, qword ptr [rsp + 048h]                            ; load address of return value's type
      push r13                                                   ; internal argument 5: pointer to return value slot's type
      sub rsp, 020h                                              ; allocate shadow space
      mov r9, 000h                                               ; internal argument 4: "this" pointer
      mov r8, 000h                                               ; internal argument 3: "this" pointer type
      mov rdx, 000h                                              ; internal argument 2: closure pointer
      mov rcx, 001h                                              ; internal argument 1: number of actual arguments
      call func$__print                                          ; jump to subroutine
      add rsp, 040h                                              ; release shadow space and arguments (result in stack pointer)
      ;  - exit(1)
      ; Call exit with 1 arguments
      push 001h                                                  ; value of argument #1 (1 (integer))
      push 019h                                                  ; type of argument #1 (Integer'25)
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
      mov r12, qword ptr [rsp + 070h]                            ; restoring slots to previous scope state
      mov r13, qword ptr [rsp + 038h]                            ; restoring slots to previous scope state
    func$_moveBytes$while$tocursorVariable$TypeMatch:            ; after block
    mov rbx, r12                                                 ; assign value of toCursor variable to value of += operator result
    add rbx, 008h                                                ; += operator
    mov rsi, 019h                                                ; += operator result is of type Integer'25
    mov r12, rbx                                                 ; store value
    mov qword ptr [rsp + 058h], rsi                              ; store type
    mov qword ptr [rsp + 070h], r12                              ; restoring slots to previous scope state
    mov r15, qword ptr [rsp + 050h]                              ; restoring slots to previous scope state
    mov r10, qword ptr [rsp + 048h]                              ; restoring slots to previous scope state
    jmp func$_moveBytes$while$top                                ; return to top of while
  func$_moveBytes$while$bottom:                                  ; bottom of while
  ; Line 119: end = from + length;
  cmp qword ptr [rbp + 038h], 000h                               ; compare type of from to <sentinel>
  jne func$_moveBytes$from$TypeMatch$2                           ; skip next block if from is not sentinel
    ; Error handling block for from
    ;  - print(operandTypeCheckFailureMessage)
    ; Call __print with 1 arguments
    mov rdi, offset operandTypeCheckFailureMessage               ; reading operandTypeCheckFailureMessage for push
    push rdi                                                     ; value of argument #1 (operandTypeCheckFailureMessage)
    push 01ah                                                    ; type of argument #1 (String'26)
    lea r12, qword ptr [rsp + 060h]                              ; load address of return value's value
    push r12                                                     ; internal argument 6: pointer to return value slot's value
    lea r12, qword ptr [rsp + 060h]                              ; load address of return value's type
    push r12                                                     ; internal argument 5: pointer to return value slot's type
    sub rsp, 020h                                                ; allocate shadow space
    mov r9, 000h                                                 ; internal argument 4: "this" pointer
    mov r8, 000h                                                 ; internal argument 3: "this" pointer type
    mov rdx, 000h                                                ; internal argument 2: closure pointer
    mov rcx, 001h                                                ; internal argument 1: number of actual arguments
    mov qword ptr [rsp + 080h], r10                              ; move end variable type out of r10
    call func$__print                                            ; jump to subroutine
    add rsp, 040h                                                ; release shadow space and arguments (result in stack pointer)
    ;  - exit(1)
    ; Call exit with 1 arguments
    push 001h                                                    ; value of argument #1 (1 (integer))
    push 019h                                                    ; type of argument #1 (Integer'25)
    mov qword ptr [rsp + 058h], r13                              ; move fromCursor variable value out of r13
    lea r13, qword ptr [rsp + 060h]                              ; load address of return value's value
    push r13                                                     ; internal argument 6: pointer to return value slot's value
    lea r13, qword ptr [rsp + 050h]                              ; load address of return value's type
    push r13                                                     ; internal argument 5: pointer to return value slot's type
    sub rsp, 020h                                                ; allocate shadow space
    mov r9, 000h                                                 ; internal argument 4: "this" pointer
    mov r8, 000h                                                 ; internal argument 3: "this" pointer type
    mov rdx, 000h                                                ; internal argument 2: closure pointer
    mov rcx, 001h                                                ; internal argument 1: number of actual arguments
    call func$exit                                               ; jump to subroutine
    add rsp, 040h                                                ; release shadow space and arguments (result in stack pointer)
    mov r13, qword ptr [rsp + 048h]                              ; restoring slots to previous scope state
    mov r10, qword ptr [rsp + 040h]                              ; restoring slots to previous scope state
  func$_moveBytes$from$TypeMatch$2:                              ; after block
  cmp qword ptr [rbp + 058h], 000h                               ; compare type of length to <sentinel>
  jne func$_moveBytes$length$TypeMatch$3                         ; skip next block if length is not sentinel
    ; Error handling block for length
    ;  - print(operandTypeCheckFailureMessage)
    ; Call __print with 1 arguments
    mov rax, offset operandTypeCheckFailureMessage               ; reading operandTypeCheckFailureMessage for push
    push rax                                                     ; value of argument #1 (operandTypeCheckFailureMessage)
    push 01ah                                                    ; type of argument #1 (String'26)
    lea r14, qword ptr [rsp + 060h]                              ; load address of return value's value
    push r14                                                     ; internal argument 6: pointer to return value slot's value
    lea r14, qword ptr [rsp + 060h]                              ; load address of return value's type
    push r14                                                     ; internal argument 5: pointer to return value slot's type
    sub rsp, 020h                                                ; allocate shadow space
    mov r9, 000h                                                 ; internal argument 4: "this" pointer
    mov r8, 000h                                                 ; internal argument 3: "this" pointer type
    mov rdx, 000h                                                ; internal argument 2: closure pointer
    mov rcx, 001h                                                ; internal argument 1: number of actual arguments
    mov qword ptr [rsp + 080h], r10                              ; move end variable type out of r10
    call func$__print                                            ; jump to subroutine
    add rsp, 040h                                                ; release shadow space and arguments (result in stack pointer)
    ;  - exit(1)
    ; Call exit with 1 arguments
    push 001h                                                    ; value of argument #1 (1 (integer))
    push 019h                                                    ; type of argument #1 (Integer'25)
    mov qword ptr [rsp + 058h], r15                              ; move end variable value out of r15
    lea r15, qword ptr [rsp + 060h]                              ; load address of return value's value
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
    mov r15, qword ptr [rsp + 048h]                              ; restoring slots to previous scope state
    mov r10, qword ptr [rsp + 040h]                              ; restoring slots to previous scope state
  func$_moveBytes$length$TypeMatch$3:                            ; after block
  mov qword ptr [rsp + 050h], r10                                ; move end variable type out of r10
  mov r10, qword ptr [rbp + 040h]                                ; assign value of from to value of + operator result
  add r10, qword ptr [rbp + 060h]                                ; compute (from) + (length) (result in + operator result)
  mov rbx, 019h                                                  ; + operator result is of type Integer'25
  mov r15, r10                                                   ; store value
  mov qword ptr [rsp + 050h], rbx                                ; store type
  ; Line 121: if (fromCursor < end) { ...
  cmp qword ptr [rsp + 068h], 000h                               ; compare type of fromCursor variable to <sentinel>
  jne func$_moveBytes$fromcursor$TypeMatch                       ; skip next block if fromCursor variable is not sentinel
    ; Error handling block for fromCursor
    ;  - print(operandTypeCheckFailureMessage)
    ; Call __print with 1 arguments
    mov rsi, offset operandTypeCheckFailureMessage               ; reading operandTypeCheckFailureMessage for push
    push rsi                                                     ; value of argument #1 (operandTypeCheckFailureMessage)
    push 01ah                                                    ; type of argument #1 (String'26)
    lea rdi, qword ptr [rsp + 058h]                              ; load address of return value's value
    push rdi                                                     ; internal argument 6: pointer to return value slot's value
    lea rdi, qword ptr [rsp + 058h]                              ; load address of return value's type
    push rdi                                                     ; internal argument 5: pointer to return value slot's type
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
    push 019h                                                    ; type of argument #1 (Integer'25)
    lea r12, qword ptr [rsp + 058h]                              ; load address of return value's value
    push r12                                                     ; internal argument 6: pointer to return value slot's value
    lea r12, qword ptr [rsp + 058h]                              ; load address of return value's type
    push r12                                                     ; internal argument 5: pointer to return value slot's type
    sub rsp, 020h                                                ; allocate shadow space
    mov r9, 000h                                                 ; internal argument 4: "this" pointer
    mov r8, 000h                                                 ; internal argument 3: "this" pointer type
    mov rdx, 000h                                                ; internal argument 2: closure pointer
    mov rcx, 001h                                                ; internal argument 1: number of actual arguments
    call func$exit                                               ; jump to subroutine
    add rsp, 040h                                                ; release shadow space and arguments (result in stack pointer)
  func$_moveBytes$fromcursor$TypeMatch:                          ; after block
  cmp qword ptr [rsp + 050h], 000h                               ; compare type of end variable to <sentinel>
  jne func$_moveBytes$end$TypeMatch                              ; skip next block if end variable is not sentinel
    ; Error handling block for end
    ;  - print(operandTypeCheckFailureMessage)
    ; Call __print with 1 arguments
    mov qword ptr [rsp + 048h], r13                              ; move fromCursor variable value out of r13
    mov r13, offset operandTypeCheckFailureMessage               ; reading operandTypeCheckFailureMessage for push
    push r13                                                     ; value of argument #1 (operandTypeCheckFailureMessage)
    push 01ah                                                    ; type of argument #1 (String'26)
    lea rax, qword ptr [rsp + 050h]                              ; load address of return value's value
    push rax                                                     ; internal argument 6: pointer to return value slot's value
    lea rax, qword ptr [rsp + 050h]                              ; load address of return value's type
    push rax                                                     ; internal argument 5: pointer to return value slot's type
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
    push 019h                                                    ; type of argument #1 (Integer'25)
    lea r14, qword ptr [rsp + 050h]                              ; load address of return value's value
    push r14                                                     ; internal argument 6: pointer to return value slot's value
    lea r14, qword ptr [rsp + 050h]                              ; load address of return value's type
    push r14                                                     ; internal argument 5: pointer to return value slot's type
    sub rsp, 020h                                                ; allocate shadow space
    mov r9, 000h                                                 ; internal argument 4: "this" pointer
    mov r8, 000h                                                 ; internal argument 3: "this" pointer type
    mov rdx, 000h                                                ; internal argument 2: closure pointer
    mov rcx, 001h                                                ; internal argument 1: number of actual arguments
    call func$exit                                               ; jump to subroutine
    add rsp, 040h                                                ; release shadow space and arguments (result in stack pointer)
    mov r13, qword ptr [rsp + 048h]                              ; restoring slots to previous scope state
  func$_moveBytes$end$TypeMatch:                                 ; after block
  xor r10, r10                                                   ; clear < operator result
  cmp r13, r15                                                   ; compare fromCursor variable with end variable
  setl r10b                                                      ; store result in < operator result
  mov qword ptr [rsp + 048h], r15                                ; move end variable value out of r15
  mov r15, 018h                                                  ; < operator result is of type Boolean'24
  cmp r10, 000h                                                  ; compare < operator result to false
  je func$_moveBytes$if$continuation                             ; fromCursor < end
    ; Line 122: Integer newValue = __readFromAddress(fromCursor);
    ; Call __readFromAddress with 1 arguments
    mov rbx, qword ptr [r13]                                     ; dereference first argument of __readFromAddress
    mov rsi, 019h                                                ; dereferenced fromCursor variable is of type Integer'25
    mov rdi, rbx                                                 ; value initialization of variable declaration for newValue variable (dereferenced fromCursor variable)
    mov r12, rsi                                                 ; type initialization of variable declaration for newValue variable
    ; Line 123: Integer oldValue = __readFromAddress(toCursor);
    ; Call __readFromAddress with 1 arguments
    mov qword ptr [rsp + 040h], r13                              ; move fromCursor variable value out of r13
    mov r13, qword ptr [rsp + 070h]                              ; get toCursor variable into register to dereference it
    mov rax, qword ptr [r13]                                     ; dereference first argument of __readFromAddress
    mov r14, 019h                                                ; dereferenced toCursor variable is of type Integer'25
    mov r9, rax                                                  ; value initialization of variable declaration for oldValue variable (dereferenced toCursor variable)
    mov r8, r14                                                  ; type initialization of variable declaration for oldValue variable
    ; Line 124: Integer extraBytes = end - fromCursor;
    cmp qword ptr [rsp + 050h], 000h                             ; compare type of end variable to <sentinel>
    jne func$_moveBytes$Movebytes$if$end$TypeMatch               ; skip next block if end variable is not sentinel
      ; Error handling block for end
      ;  - print(operandTypeCheckFailureMessage)
      ; Call __print with 1 arguments
      mov rdx, offset operandTypeCheckFailureMessage             ; reading operandTypeCheckFailureMessage for push
      push rdx                                                   ; value of argument #1 (operandTypeCheckFailureMessage)
      push 01ah                                                  ; type of argument #1 (String'26)
      lea rcx, qword ptr [rsp + 080h]                            ; load address of return value's value
      push rcx                                                   ; internal argument 6: pointer to return value slot's value
      lea rcx, qword ptr [rsp + 050h]                            ; load address of return value's type
      push rcx                                                   ; internal argument 5: pointer to return value slot's type
      sub rsp, 020h                                              ; allocate shadow space
      mov qword ptr [rsp + 070h], r9                             ; move oldValue variable value out of r9
      mov r9, 000h                                               ; internal argument 4: "this" pointer
      mov qword ptr [rsp + 068h], r8                             ; move oldValue variable type out of r8
      mov r8, 000h                                               ; internal argument 3: "this" pointer type
      mov rdx, 000h                                              ; internal argument 2: closure pointer
      mov rcx, 001h                                              ; internal argument 1: number of actual arguments
      call func$__print                                          ; jump to subroutine
      add rsp, 040h                                              ; release shadow space and arguments (result in stack pointer)
      ;  - exit(1)
      ; Call exit with 1 arguments
      push 001h                                                  ; value of argument #1 (1 (integer))
      push 019h                                                  ; type of argument #1 (Integer'25)
      lea r10, qword ptr [rsp + 080h]                            ; load address of return value's value
      push r10                                                   ; internal argument 6: pointer to return value slot's value
      lea r10, qword ptr [rsp + 050h]                            ; load address of return value's type
      push r10                                                   ; internal argument 5: pointer to return value slot's type
      sub rsp, 020h                                              ; allocate shadow space
      mov r9, 000h                                               ; internal argument 4: "this" pointer
      mov r8, 000h                                               ; internal argument 3: "this" pointer type
      mov rdx, 000h                                              ; internal argument 2: closure pointer
      mov rcx, 001h                                              ; internal argument 1: number of actual arguments
      call func$exit                                             ; jump to subroutine
      add rsp, 040h                                              ; release shadow space and arguments (result in stack pointer)
      mov r9, qword ptr [rsp + 030h]                             ; restoring slots to previous scope state
      mov r8, qword ptr [rsp + 028h]                             ; restoring slots to previous scope state
    func$_moveBytes$Movebytes$if$end$TypeMatch:                  ; after block
    cmp qword ptr [rsp + 068h], 000h                             ; compare type of fromCursor variable to <sentinel>
    jne func$_moveBytes$Movebytes$if$fromcursor$TypeMatch        ; skip next block if fromCursor variable is not sentinel
      ; Error handling block for fromCursor
      ;  - print(operandTypeCheckFailureMessage)
      ; Call __print with 1 arguments
      mov r15, offset operandTypeCheckFailureMessage             ; reading operandTypeCheckFailureMessage for push
      push r15                                                   ; value of argument #1 (operandTypeCheckFailureMessage)
      push 01ah                                                  ; type of argument #1 (String'26)
      lea rbx, qword ptr [rsp + 080h]                            ; load address of return value's value
      push rbx                                                   ; internal argument 6: pointer to return value slot's value
      lea rbx, qword ptr [rsp + 050h]                            ; load address of return value's type
      push rbx                                                   ; internal argument 5: pointer to return value slot's type
      sub rsp, 020h                                              ; allocate shadow space
      mov qword ptr [rsp + 070h], r9                             ; move oldValue variable value out of r9
      mov r9, 000h                                               ; internal argument 4: "this" pointer
      mov qword ptr [rsp + 068h], r8                             ; move oldValue variable type out of r8
      mov r8, 000h                                               ; internal argument 3: "this" pointer type
      mov rdx, 000h                                              ; internal argument 2: closure pointer
      mov rcx, 001h                                              ; internal argument 1: number of actual arguments
      call func$__print                                          ; jump to subroutine
      add rsp, 040h                                              ; release shadow space and arguments (result in stack pointer)
      ;  - exit(1)
      ; Call exit with 1 arguments
      push 001h                                                  ; value of argument #1 (1 (integer))
      push 019h                                                  ; type of argument #1 (Integer'25)
      lea rsi, qword ptr [rsp + 080h]                            ; load address of return value's value
      push rsi                                                   ; internal argument 6: pointer to return value slot's value
      lea rsi, qword ptr [rsp + 050h]                            ; load address of return value's type
      push rsi                                                   ; internal argument 5: pointer to return value slot's type
      sub rsp, 020h                                              ; allocate shadow space
      mov r9, 000h                                               ; internal argument 4: "this" pointer
      mov r8, 000h                                               ; internal argument 3: "this" pointer type
      mov rdx, 000h                                              ; internal argument 2: closure pointer
      mov rcx, 001h                                              ; internal argument 1: number of actual arguments
      call func$exit                                             ; jump to subroutine
      add rsp, 040h                                              ; release shadow space and arguments (result in stack pointer)
      mov r9, qword ptr [rsp + 030h]                             ; restoring slots to previous scope state
      mov r8, qword ptr [rsp + 028h]                             ; restoring slots to previous scope state
    func$_moveBytes$Movebytes$if$fromcursor$TypeMatch:           ; after block
    mov qword ptr [rsp + 070h], rdi                              ; move newValue variable value out of rdi
    mov rdi, qword ptr [rsp + 048h]                              ; assign value of end variable to value of - operator result
    sub rdi, qword ptr [rsp + 040h]                              ; compute (end variable) - (fromCursor variable)
    mov qword ptr [rsp + 038h], r12                              ; move newValue variable type out of r12
    mov r12, 019h                                                ; - operator result is of type Integer'25
    mov qword ptr [rsp + 030h], r13                              ; move toCursor variable value out of r13
    mov r13, rdi                                                 ; value initialization of variable declaration for extraBytes variable (- operator result)
    mov rax, r12                                                 ; type initialization of variable declaration for extraBytes variable
    ; Line 125: assert(extraBytes > 0, 'internal error: zero extra bytes but fro...
    cmp rax, 000h                                                ; compare type of extraBytes variable to <sentinel>
    jne func$_moveBytes$Movebytes$if$extrabytes$TypeMatch        ; skip next block if extraBytes variable is not sentinel
      ; Error handling block for extraBytes
      ;  - print(operandTypeCheckFailureMessage)
      ; Call __print with 1 arguments
      mov r14, offset operandTypeCheckFailureMessage             ; reading operandTypeCheckFailureMessage for push
      push r14                                                   ; value of argument #1 (operandTypeCheckFailureMessage)
      push 01ah                                                  ; type of argument #1 (String'26)
      lea r10, qword ptr [rsp + 038h]                            ; load address of return value's value
      push r10                                                   ; internal argument 6: pointer to return value slot's value
      lea r10, qword ptr [rsp + 038h]                            ; load address of return value's type
      push r10                                                   ; internal argument 5: pointer to return value slot's type
      sub rsp, 020h                                              ; allocate shadow space
      mov qword ptr [rsp + 058h], r9                             ; move oldValue variable value out of r9
      mov r9, 000h                                               ; internal argument 4: "this" pointer
      mov qword ptr [rsp + 050h], r8                             ; move oldValue variable type out of r8
      mov r8, 000h                                               ; internal argument 3: "this" pointer type
      mov rdx, 000h                                              ; internal argument 2: closure pointer
      mov rcx, 001h                                              ; internal argument 1: number of actual arguments
      mov qword ptr [rsp + 048h], rax                            ; move extraBytes variable type out of rax
      call func$__print                                          ; jump to subroutine
      add rsp, 040h                                              ; release shadow space and arguments (result in stack pointer)
      ;  - exit(1)
      ; Call exit with 1 arguments
      push 001h                                                  ; value of argument #1 (1 (integer))
      push 019h                                                  ; type of argument #1 (Integer'25)
      lea r15, qword ptr [rsp + 038h]                            ; load address of return value's value
      push r15                                                   ; internal argument 6: pointer to return value slot's value
      lea r15, qword ptr [rsp + 038h]                            ; load address of return value's type
      push r15                                                   ; internal argument 5: pointer to return value slot's type
      sub rsp, 020h                                              ; allocate shadow space
      mov r9, 000h                                               ; internal argument 4: "this" pointer
      mov r8, 000h                                               ; internal argument 3: "this" pointer type
      mov rdx, 000h                                              ; internal argument 2: closure pointer
      mov rcx, 001h                                              ; internal argument 1: number of actual arguments
      call func$exit                                             ; jump to subroutine
      add rsp, 040h                                              ; release shadow space and arguments (result in stack pointer)
      mov rax, qword ptr [rsp + 008h]                            ; restoring slots to previous scope state
      mov r8, qword ptr [rsp + 010h]                             ; restoring slots to previous scope state
      mov r9, qword ptr [rsp + 018h]                             ; restoring slots to previous scope state
    func$_moveBytes$Movebytes$if$extrabytes$TypeMatch:           ; after block
    xor r12, r12                                                 ; clear > operator result
    cmp r13, 000h                                                ; compare extraBytes variable with 0
    setg r12b                                                    ; store result in > operator result
    mov qword ptr [rsp + 028h], r13                              ; move extraBytes variable value out of r13
    mov r13, 018h                                                ; > operator result is of type Boolean'24
    ; Call assert with 2 arguments
    mov qword ptr [rsp + 020h], rax                              ; move extraBytes variable type out of rax
    mov rax, offset string$11                                    ; reading string for push
    push rax                                                     ; value of argument #2 (string)
    push 01ah                                                    ; type of argument #2 (String'26)
    push r12                                                     ; value of argument #1 (> operator result)
    push r13                                                     ; type of argument #1
    lea r14, qword ptr [rsp + 038h]                              ; load address of return value's value
    push r14                                                     ; internal argument 6: pointer to return value slot's value
    lea r14, qword ptr [rsp + 038h]                              ; load address of return value's type
    push r14                                                     ; internal argument 5: pointer to return value slot's type
    sub rsp, 020h                                                ; allocate shadow space
    mov qword ptr [rsp + 058h], r9                               ; move oldValue variable value out of r9
    mov r9, 000h                                                 ; internal argument 4: "this" pointer
    mov qword ptr [rsp + 050h], r8                               ; move oldValue variable type out of r8
    mov r8, 000h                                                 ; internal argument 3: "this" pointer type
    mov rdx, 000h                                                ; internal argument 2: closure pointer
    mov rcx, 002h                                                ; internal argument 1: number of actual arguments
    call func$assert                                             ; jump to subroutine
    add rsp, 050h                                                ; release shadow space and arguments (result in stack pointer)
    ; Line 126: assert(extraBytes < 8, 'internal error: more than 7 extra bytes'...
    cmp qword ptr [rsp + 020h], 000h                             ; compare type of extraBytes variable to <sentinel>
    jne func$_moveBytes$Movebytes$if$extrabytes$TypeMatch$1      ; skip next block if extraBytes variable is not sentinel
      ; Error handling block for extraBytes
      ;  - print(operandTypeCheckFailureMessage)
      ; Call __print with 1 arguments
      mov r10, offset operandTypeCheckFailureMessage             ; reading operandTypeCheckFailureMessage for push
      push r10                                                   ; value of argument #1 (operandTypeCheckFailureMessage)
      push 01ah                                                  ; type of argument #1 (String'26)
      lea r15, qword ptr [rsp + 028h]                            ; load address of return value's value
      push r15                                                   ; internal argument 6: pointer to return value slot's value
      lea r15, qword ptr [rsp + 028h]                            ; load address of return value's type
      push r15                                                   ; internal argument 5: pointer to return value slot's type
      sub rsp, 020h                                              ; allocate shadow space
      mov r9, 000h                                               ; internal argument 4: "this" pointer
      mov r8, 000h                                               ; internal argument 3: "this" pointer type
      mov rdx, 000h                                              ; internal argument 2: closure pointer
      mov rcx, 001h                                              ; internal argument 1: number of actual arguments
      call func$__print                                          ; jump to subroutine
      add rsp, 040h                                              ; release shadow space and arguments (result in stack pointer)
      ;  - exit(1)
      ; Call exit with 1 arguments
      push 001h                                                  ; value of argument #1 (1 (integer))
      push 019h                                                  ; type of argument #1 (Integer'25)
      lea rbx, qword ptr [rsp + 028h]                            ; load address of return value's value
      push rbx                                                   ; internal argument 6: pointer to return value slot's value
      lea rbx, qword ptr [rsp + 028h]                            ; load address of return value's type
      push rbx                                                   ; internal argument 5: pointer to return value slot's type
      sub rsp, 020h                                              ; allocate shadow space
      mov r9, 000h                                               ; internal argument 4: "this" pointer
      mov r8, 000h                                               ; internal argument 3: "this" pointer type
      mov rdx, 000h                                              ; internal argument 2: closure pointer
      mov rcx, 001h                                              ; internal argument 1: number of actual arguments
      call func$exit                                             ; jump to subroutine
      add rsp, 040h                                              ; release shadow space and arguments (result in stack pointer)
    func$_moveBytes$Movebytes$if$extrabytes$TypeMatch$1:         ; after block
    xor r13, r13                                                 ; clear < operator result
    cmp qword ptr [rsp + 028h], 008h                             ; compare extraBytes variable with 8
    setl r13b                                                    ; store result in < operator result
    mov rax, 018h                                                ; < operator result is of type Boolean'24
    ; Call assert with 2 arguments
    mov r14, offset string$12                                    ; reading string for push
    push r14                                                     ; value of argument #2 (string)
    push 01ah                                                    ; type of argument #2 (String'26)
    push r13                                                     ; value of argument #1 (< operator result)
    push rax                                                     ; type of argument #1
    lea r10, qword ptr [rsp + 038h]                              ; load address of return value's value
    push r10                                                     ; internal argument 6: pointer to return value slot's value
    lea r10, qword ptr [rsp + 038h]                              ; load address of return value's type
    push r10                                                     ; internal argument 5: pointer to return value slot's type
    sub rsp, 020h                                                ; allocate shadow space
    mov r9, 000h                                                 ; internal argument 4: "this" pointer
    mov r8, 000h                                                 ; internal argument 3: "this" pointer type
    mov rdx, 000h                                                ; internal argument 2: closure pointer
    mov rcx, 002h                                                ; internal argument 1: number of actual arguments
    call func$assert                                             ; jump to subroutine
    add rsp, 050h                                                ; release shadow space and arguments (result in stack pointer)
    ; Line 127: Integer mask = -1 << extraBytes * 8;
    cmp qword ptr [rsp + 020h], 000h                             ; compare type of extraBytes variable to <sentinel>
    jne func$_moveBytes$Movebytes$if$extrabytes$TypeMatch$2      ; skip next block if extraBytes variable is not sentinel
      ; Error handling block for extraBytes
      ;  - print(operandTypeCheckFailureMessage)
      ; Call __print with 1 arguments
      mov r15, offset operandTypeCheckFailureMessage             ; reading operandTypeCheckFailureMessage for push
      push r15                                                   ; value of argument #1 (operandTypeCheckFailureMessage)
      push 01ah                                                  ; type of argument #1 (String'26)
      lea rbx, qword ptr [rsp + 028h]                            ; load address of return value's value
      push rbx                                                   ; internal argument 6: pointer to return value slot's value
      lea rbx, qword ptr [rsp + 028h]                            ; load address of return value's type
      push rbx                                                   ; internal argument 5: pointer to return value slot's type
      sub rsp, 020h                                              ; allocate shadow space
      mov r9, 000h                                               ; internal argument 4: "this" pointer
      mov r8, 000h                                               ; internal argument 3: "this" pointer type
      mov rdx, 000h                                              ; internal argument 2: closure pointer
      mov rcx, 001h                                              ; internal argument 1: number of actual arguments
      call func$__print                                          ; jump to subroutine
      add rsp, 040h                                              ; release shadow space and arguments (result in stack pointer)
      ;  - exit(1)
      ; Call exit with 1 arguments
      push 001h                                                  ; value of argument #1 (1 (integer))
      push 019h                                                  ; type of argument #1 (Integer'25)
      lea rsi, qword ptr [rsp + 028h]                            ; load address of return value's value
      push rsi                                                   ; internal argument 6: pointer to return value slot's value
      lea rsi, qword ptr [rsp + 028h]                            ; load address of return value's type
      push rsi                                                   ; internal argument 5: pointer to return value slot's type
      sub rsp, 020h                                              ; allocate shadow space
      mov r9, 000h                                               ; internal argument 4: "this" pointer
      mov r8, 000h                                               ; internal argument 3: "this" pointer type
      mov rdx, 000h                                              ; internal argument 2: closure pointer
      mov rcx, 001h                                              ; internal argument 1: number of actual arguments
      call func$exit                                             ; jump to subroutine
      add rsp, 040h                                              ; release shadow space and arguments (result in stack pointer)
    func$_moveBytes$Movebytes$if$extrabytes$TypeMatch$2:         ; after block
    mov r14, qword ptr [rsp + 028h]                              ; read left hand side operand of imul (extraBytes variable)
    imul rax, r14, 008h                                          ; compute (extraBytes variable) * (8) (result in * operator result)
    mov r10, 019h                                                ; * operator result is of type Integer'25
    cmp r10, 000h                                                ; compare type of * operator result to <sentinel>
    jne func$_moveBytes$Movebytes$if$extrabytes8$TypeMatch       ; skip next block if * operator result is not sentinel
      ; Error handling block for extraBytes * 8
      ;  - print(operandTypeCheckFailureMessage)
      ; Call __print with 1 arguments
      mov rdi, offset operandTypeCheckFailureMessage             ; reading operandTypeCheckFailureMessage for push
      push rdi                                                   ; value of argument #1 (operandTypeCheckFailureMessage)
      push 01ah                                                  ; type of argument #1 (String'26)
      lea r12, qword ptr [rsp + 038h]                            ; load address of return value's value
      push r12                                                   ; internal argument 6: pointer to return value slot's value
      lea r12, qword ptr [rsp + 038h]                            ; load address of return value's type
      push r12                                                   ; internal argument 5: pointer to return value slot's type
      sub rsp, 020h                                              ; allocate shadow space
      mov r9, 000h                                               ; internal argument 4: "this" pointer
      mov r8, 000h                                               ; internal argument 3: "this" pointer type
      mov rdx, 000h                                              ; internal argument 2: closure pointer
      mov rcx, 001h                                              ; internal argument 1: number of actual arguments
      mov qword ptr [rsp + 058h], r10                            ; move * operator result type out of r10
      mov qword ptr [rsp + 050h], rax                            ; move * operator result value out of rax
      call func$__print                                          ; jump to subroutine
      add rsp, 040h                                              ; release shadow space and arguments (result in stack pointer)
      ;  - exit(1)
      ; Call exit with 1 arguments
      push 001h                                                  ; value of argument #1 (1 (integer))
      push 019h                                                  ; type of argument #1 (Integer'25)
      lea r13, qword ptr [rsp + 038h]                            ; load address of return value's value
      push r13                                                   ; internal argument 6: pointer to return value slot's value
      lea r13, qword ptr [rsp + 038h]                            ; load address of return value's type
      push r13                                                   ; internal argument 5: pointer to return value slot's type
      sub rsp, 020h                                              ; allocate shadow space
      mov r9, 000h                                               ; internal argument 4: "this" pointer
      mov r8, 000h                                               ; internal argument 3: "this" pointer type
      mov rdx, 000h                                              ; internal argument 2: closure pointer
      mov rcx, 001h                                              ; internal argument 1: number of actual arguments
      call func$exit                                             ; jump to subroutine
      add rsp, 040h                                              ; release shadow space and arguments (result in stack pointer)
      mov rax, qword ptr [rsp + 010h]                            ; restoring slots to previous scope state
      mov r10, qword ptr [rsp + 018h]                            ; restoring slots to previous scope state
    func$_moveBytes$Movebytes$if$extrabytes8$TypeMatch:          ; after block
    mov rcx, rax                                                 ; read <DynamicSlot:Integer'25 at [rax]/[r10] ("* operator result") (living: true)> into imm8 or cl forshl
    mov rax, -001h                                               ; assign value of -1 to value of << operator result
    shl rax, cl                                                  ; compute (-1) << (* operator result)
    mov r14, 019h                                                ; << operator result is of type Integer'25
    mov r10, rax                                                 ; value initialization of variable declaration for mask variable (<< operator result)
    mov r15, r14                                                 ; type initialization of variable declaration for mask variable
    ; Line 128: Integer finalValue = newValue & ~mask | oldValue & mask;
    cmp r15, 000h                                                ; compare type of mask variable to <sentinel>
    jne func$_moveBytes$Movebytes$if$mask$TypeMatch              ; skip next block if mask variable is not sentinel
      ; Error handling block for mask
      ;  - print(operandTypeCheckFailureMessage)
      ; Call __print with 1 arguments
      mov rbx, offset operandTypeCheckFailureMessage             ; reading operandTypeCheckFailureMessage for push
      push rbx                                                   ; value of argument #1 (operandTypeCheckFailureMessage)
      push 01ah                                                  ; type of argument #1 (String'26)
      lea rsi, qword ptr [rsp + 038h]                            ; load address of return value's value
      push rsi                                                   ; internal argument 6: pointer to return value slot's value
      lea rsi, qword ptr [rsp + 038h]                            ; load address of return value's type
      push rsi                                                   ; internal argument 5: pointer to return value slot's type
      sub rsp, 020h                                              ; allocate shadow space
      mov r9, 000h                                               ; internal argument 4: "this" pointer
      mov r8, 000h                                               ; internal argument 3: "this" pointer type
      mov rdx, 000h                                              ; internal argument 2: closure pointer
      mov rcx, 001h                                              ; internal argument 1: number of actual arguments
      mov qword ptr [rsp + 058h], r10                            ; move mask variable value out of r10
      call func$__print                                          ; jump to subroutine
      add rsp, 040h                                              ; release shadow space and arguments (result in stack pointer)
      ;  - exit(1)
      ; Call exit with 1 arguments
      push 001h                                                  ; value of argument #1 (1 (integer))
      push 019h                                                  ; type of argument #1 (Integer'25)
      lea rdi, qword ptr [rsp + 038h]                            ; load address of return value's value
      push rdi                                                   ; internal argument 6: pointer to return value slot's value
      lea rdi, qword ptr [rsp + 038h]                            ; load address of return value's type
      push rdi                                                   ; internal argument 5: pointer to return value slot's type
      sub rsp, 020h                                              ; allocate shadow space
      mov r9, 000h                                               ; internal argument 4: "this" pointer
      mov r8, 000h                                               ; internal argument 3: "this" pointer type
      mov rdx, 000h                                              ; internal argument 2: closure pointer
      mov rcx, 001h                                              ; internal argument 1: number of actual arguments
      call func$exit                                             ; jump to subroutine
      add rsp, 040h                                              ; release shadow space and arguments (result in stack pointer)
      mov r10, qword ptr [rsp + 018h]                            ; restoring slots to previous scope state
    func$_moveBytes$Movebytes$if$mask$TypeMatch:                 ; after block
    mov r12, r10                                                 ; assign value of mask variable to value of ~ unary operator result
    not r12                                                      ; ~ unary operator
    mov r13, 019h                                                ; ~ unary operator result is of type Integer'25
    cmp qword ptr [rsp + 038h], 000h                             ; compare type of newValue variable to <sentinel>
    jne func$_moveBytes$Movebytes$if$newvalue$TypeMatch          ; skip next block if newValue variable is not sentinel
      ; Error handling block for newValue
      ;  - print(operandTypeCheckFailureMessage)
      ; Call __print with 1 arguments
      mov rax, offset operandTypeCheckFailureMessage             ; reading operandTypeCheckFailureMessage for push
      push rax                                                   ; value of argument #1 (operandTypeCheckFailureMessage)
      push 01ah                                                  ; type of argument #1 (String'26)
      lea r14, qword ptr [rsp + 038h]                            ; load address of return value's value
      push r14                                                   ; internal argument 6: pointer to return value slot's value
      lea r14, qword ptr [rsp + 038h]                            ; load address of return value's type
      push r14                                                   ; internal argument 5: pointer to return value slot's type
      sub rsp, 020h                                              ; allocate shadow space
      mov r9, 000h                                               ; internal argument 4: "this" pointer
      mov r8, 000h                                               ; internal argument 3: "this" pointer type
      mov rdx, 000h                                              ; internal argument 2: closure pointer
      mov rcx, 001h                                              ; internal argument 1: number of actual arguments
      mov qword ptr [rsp + 058h], r10                            ; move mask variable value out of r10
      call func$__print                                          ; jump to subroutine
      add rsp, 040h                                              ; release shadow space and arguments (result in stack pointer)
      ;  - exit(1)
      ; Call exit with 1 arguments
      push 001h                                                  ; value of argument #1 (1 (integer))
      push 019h                                                  ; type of argument #1 (Integer'25)
      lea r10, qword ptr [rsp + 038h]                            ; load address of return value's value
      push r10                                                   ; internal argument 6: pointer to return value slot's value
      lea r10, qword ptr [rsp + 038h]                            ; load address of return value's type
      push r10                                                   ; internal argument 5: pointer to return value slot's type
      sub rsp, 020h                                              ; allocate shadow space
      mov r9, 000h                                               ; internal argument 4: "this" pointer
      mov r8, 000h                                               ; internal argument 3: "this" pointer type
      mov rdx, 000h                                              ; internal argument 2: closure pointer
      mov rcx, 001h                                              ; internal argument 1: number of actual arguments
      call func$exit                                             ; jump to subroutine
      add rsp, 040h                                              ; release shadow space and arguments (result in stack pointer)
      mov r10, qword ptr [rsp + 018h]                            ; restoring slots to previous scope state
    func$_moveBytes$Movebytes$if$newvalue$TypeMatch:             ; after block
    cmp r13, 000h                                                ; compare type of ~ unary operator result to <sentinel>
    jne func$_moveBytes$Movebytes$if$Mask$TypeMatch              ; skip next block if ~ unary operator result is not sentinel
      ; Error handling block for ~mask
      ;  - print(operandTypeCheckFailureMessage)
      ; Call __print with 1 arguments
      mov qword ptr [rsp + 028h], r15                            ; move mask variable type out of r15
      mov r15, offset operandTypeCheckFailureMessage             ; reading operandTypeCheckFailureMessage for push
      push r15                                                   ; value of argument #1 (operandTypeCheckFailureMessage)
      push 01ah                                                  ; type of argument #1 (String'26)
      lea rbx, qword ptr [rsp + 030h]                            ; load address of return value's value
      push rbx                                                   ; internal argument 6: pointer to return value slot's value
      lea rbx, qword ptr [rsp + 030h]                            ; load address of return value's type
      push rbx                                                   ; internal argument 5: pointer to return value slot's type
      sub rsp, 020h                                              ; allocate shadow space
      mov r9, 000h                                               ; internal argument 4: "this" pointer
      mov r8, 000h                                               ; internal argument 3: "this" pointer type
      mov rdx, 000h                                              ; internal argument 2: closure pointer
      mov rcx, 001h                                              ; internal argument 1: number of actual arguments
      mov qword ptr [rsp + 050h], r10                            ; move mask variable value out of r10
      call func$__print                                          ; jump to subroutine
      add rsp, 040h                                              ; release shadow space and arguments (result in stack pointer)
      ;  - exit(1)
      ; Call exit with 1 arguments
      push 001h                                                  ; value of argument #1 (1 (integer))
      push 019h                                                  ; type of argument #1 (Integer'25)
      lea rsi, qword ptr [rsp + 030h]                            ; load address of return value's value
      push rsi                                                   ; internal argument 6: pointer to return value slot's value
      lea rsi, qword ptr [rsp + 030h]                            ; load address of return value's type
      push rsi                                                   ; internal argument 5: pointer to return value slot's type
      sub rsp, 020h                                              ; allocate shadow space
      mov r9, 000h                                               ; internal argument 4: "this" pointer
      mov r8, 000h                                               ; internal argument 3: "this" pointer type
      mov rdx, 000h                                              ; internal argument 2: closure pointer
      mov rcx, 001h                                              ; internal argument 1: number of actual arguments
      call func$exit                                             ; jump to subroutine
      add rsp, 040h                                              ; release shadow space and arguments (result in stack pointer)
      mov r15, qword ptr [rsp + 028h]                            ; restoring slots to previous scope state
      mov r10, qword ptr [rsp + 010h]                            ; restoring slots to previous scope state
    func$_moveBytes$Movebytes$if$Mask$TypeMatch:                 ; after block
    mov rdi, qword ptr [rsp + 070h]                              ; assign value of newValue variable to value of & operator result
    and rdi, r12                                                 ; compute (newValue variable) & (~ unary operator result)
    mov r12, 019h                                                ; & operator result is of type Integer'25
    cmp qword ptr [rsp + 000h], 000h                             ; compare type of oldValue variable to <sentinel>
    jne func$_moveBytes$Movebytes$if$oldvalue$TypeMatch          ; skip next block if oldValue variable is not sentinel
      ; Error handling block for oldValue
      ;  - print(operandTypeCheckFailureMessage)
      ; Call __print with 1 arguments
      mov r13, offset operandTypeCheckFailureMessage             ; reading operandTypeCheckFailureMessage for push
      push r13                                                   ; value of argument #1 (operandTypeCheckFailureMessage)
      push 01ah                                                  ; type of argument #1 (String'26)
      lea rax, qword ptr [rsp + 080h]                            ; load address of return value's value
      push rax                                                   ; internal argument 6: pointer to return value slot's value
      lea rax, qword ptr [rsp + 050h]                            ; load address of return value's type
      push rax                                                   ; internal argument 5: pointer to return value slot's type
      sub rsp, 020h                                              ; allocate shadow space
      mov r9, 000h                                               ; internal argument 4: "this" pointer
      mov r8, 000h                                               ; internal argument 3: "this" pointer type
      mov rdx, 000h                                              ; internal argument 2: closure pointer
      mov rcx, 001h                                              ; internal argument 1: number of actual arguments
      mov qword ptr [rsp + 068h], r10                            ; move mask variable value out of r10
      call func$__print                                          ; jump to subroutine
      add rsp, 040h                                              ; release shadow space and arguments (result in stack pointer)
      ;  - exit(1)
      ; Call exit with 1 arguments
      push 001h                                                  ; value of argument #1 (1 (integer))
      push 019h                                                  ; type of argument #1 (Integer'25)
      lea r14, qword ptr [rsp + 080h]                            ; load address of return value's value
      push r14                                                   ; internal argument 6: pointer to return value slot's value
      lea r14, qword ptr [rsp + 050h]                            ; load address of return value's type
      push r14                                                   ; internal argument 5: pointer to return value slot's type
      sub rsp, 020h                                              ; allocate shadow space
      mov r9, 000h                                               ; internal argument 4: "this" pointer
      mov r8, 000h                                               ; internal argument 3: "this" pointer type
      mov rdx, 000h                                              ; internal argument 2: closure pointer
      mov rcx, 001h                                              ; internal argument 1: number of actual arguments
      call func$exit                                             ; jump to subroutine
      add rsp, 040h                                              ; release shadow space and arguments (result in stack pointer)
      mov r10, qword ptr [rsp + 028h]                            ; restoring slots to previous scope state
    func$_moveBytes$Movebytes$if$oldvalue$TypeMatch:             ; after block
    cmp r15, 000h                                                ; compare type of mask variable to <sentinel>
    jne func$_moveBytes$Movebytes$if$mask$TypeMatch$1            ; skip next block if mask variable is not sentinel
      ; Error handling block for mask
      ;  - print(operandTypeCheckFailureMessage)
      ; Call __print with 1 arguments
      mov qword ptr [rsp + 070h], r10                            ; move mask variable value out of r10
      mov r10, offset operandTypeCheckFailureMessage             ; reading operandTypeCheckFailureMessage for push
      push r10                                                   ; value of argument #1 (operandTypeCheckFailureMessage)
      push 01ah                                                  ; type of argument #1 (String'26)
      mov qword ptr [rsp + 038h], r15                            ; move mask variable type out of r15
      lea r15, qword ptr [rsp + 048h]                            ; load address of return value's value
      push r15                                                   ; internal argument 6: pointer to return value slot's value
      lea r15, qword ptr [rsp + 038h]                            ; load address of return value's type
      push r15                                                   ; internal argument 5: pointer to return value slot's type
      sub rsp, 020h                                              ; allocate shadow space
      mov r9, 000h                                               ; internal argument 4: "this" pointer
      mov r8, 000h                                               ; internal argument 3: "this" pointer type
      mov rdx, 000h                                              ; internal argument 2: closure pointer
      mov rcx, 001h                                              ; internal argument 1: number of actual arguments
      call func$__print                                          ; jump to subroutine
      add rsp, 040h                                              ; release shadow space and arguments (result in stack pointer)
      ;  - exit(1)
      ; Call exit with 1 arguments
      push 001h                                                  ; value of argument #1 (1 (integer))
      push 019h                                                  ; type of argument #1 (Integer'25)
      lea rbx, qword ptr [rsp + 048h]                            ; load address of return value's value
      push rbx                                                   ; internal argument 6: pointer to return value slot's value
      lea rbx, qword ptr [rsp + 038h]                            ; load address of return value's type
      push rbx                                                   ; internal argument 5: pointer to return value slot's type
      sub rsp, 020h                                              ; allocate shadow space
      mov r9, 000h                                               ; internal argument 4: "this" pointer
      mov r8, 000h                                               ; internal argument 3: "this" pointer type
      mov rdx, 000h                                              ; internal argument 2: closure pointer
      mov rcx, 001h                                              ; internal argument 1: number of actual arguments
      call func$exit                                             ; jump to subroutine
      add rsp, 040h                                              ; release shadow space and arguments (result in stack pointer)
      mov r15, qword ptr [rsp + 028h]                            ; restoring slots to previous scope state
      mov r10, qword ptr [rsp + 070h]                            ; restoring slots to previous scope state
    func$_moveBytes$Movebytes$if$mask$TypeMatch$1:               ; after block
    mov rsi, qword ptr [rsp + 008h]                              ; assign value of oldValue variable to value of & operator result
    and rsi, r10                                                 ; compute (oldValue variable) & (mask variable)
    mov qword ptr [rsp + 070h], rdi                              ; move & operator result value out of rdi
    mov rdi, 019h                                                ; & operator result is of type Integer'25
    cmp r12, 000h                                                ; compare type of & operator result to <sentinel>
    jne func$_moveBytes$Movebytes$if$newvalueMask$TypeMatch      ; skip next block if & operator result is not sentinel
      ; Error handling block for newValue & ~mask
      ;  - print(operandTypeCheckFailureMessage)
      ; Call __print with 1 arguments
      mov qword ptr [rsp + 038h], r12                            ; move & operator result type out of r12
      mov r12, offset operandTypeCheckFailureMessage             ; reading operandTypeCheckFailureMessage for push
      push r12                                                   ; value of argument #1 (operandTypeCheckFailureMessage)
      push 01ah                                                  ; type of argument #1 (String'26)
      lea r13, qword ptr [rsp + 038h]                            ; load address of return value's value
      push r13                                                   ; internal argument 6: pointer to return value slot's value
      lea r13, qword ptr [rsp + 038h]                            ; load address of return value's type
      push r13                                                   ; internal argument 5: pointer to return value slot's type
      sub rsp, 020h                                              ; allocate shadow space
      mov r9, 000h                                               ; internal argument 4: "this" pointer
      mov r8, 000h                                               ; internal argument 3: "this" pointer type
      mov rdx, 000h                                              ; internal argument 2: closure pointer
      mov rcx, 001h                                              ; internal argument 1: number of actual arguments
      call func$__print                                          ; jump to subroutine
      add rsp, 040h                                              ; release shadow space and arguments (result in stack pointer)
      ;  - exit(1)
      ; Call exit with 1 arguments
      push 001h                                                  ; value of argument #1 (1 (integer))
      push 019h                                                  ; type of argument #1 (Integer'25)
      lea rax, qword ptr [rsp + 038h]                            ; load address of return value's value
      push rax                                                   ; internal argument 6: pointer to return value slot's value
      lea rax, qword ptr [rsp + 038h]                            ; load address of return value's type
      push rax                                                   ; internal argument 5: pointer to return value slot's type
      sub rsp, 020h                                              ; allocate shadow space
      mov r9, 000h                                               ; internal argument 4: "this" pointer
      mov r8, 000h                                               ; internal argument 3: "this" pointer type
      mov rdx, 000h                                              ; internal argument 2: closure pointer
      mov rcx, 001h                                              ; internal argument 1: number of actual arguments
      call func$exit                                             ; jump to subroutine
      add rsp, 040h                                              ; release shadow space and arguments (result in stack pointer)
      mov r12, qword ptr [rsp + 038h]                            ; restoring slots to previous scope state
    func$_moveBytes$Movebytes$if$newvalueMask$TypeMatch:         ; after block
    cmp rdi, 000h                                                ; compare type of & operator result to <sentinel>
    jne func$_moveBytes$Movebytes$if$oldvalueMask$TypeMatch      ; skip next block if & operator result is not sentinel
      ; Error handling block for oldValue & mask
      ;  - print(operandTypeCheckFailureMessage)
      ; Call __print with 1 arguments
      mov r14, offset operandTypeCheckFailureMessage             ; reading operandTypeCheckFailureMessage for push
      push r14                                                   ; value of argument #1 (operandTypeCheckFailureMessage)
      push 01ah                                                  ; type of argument #1 (String'26)
      lea r10, qword ptr [rsp + 048h]                            ; load address of return value's value
      push r10                                                   ; internal argument 6: pointer to return value slot's value
      lea r10, qword ptr [rsp + 040h]                            ; load address of return value's type
      push r10                                                   ; internal argument 5: pointer to return value slot's type
      sub rsp, 020h                                              ; allocate shadow space
      mov r9, 000h                                               ; internal argument 4: "this" pointer
      mov r8, 000h                                               ; internal argument 3: "this" pointer type
      mov rdx, 000h                                              ; internal argument 2: closure pointer
      mov rcx, 001h                                              ; internal argument 1: number of actual arguments
      call func$__print                                          ; jump to subroutine
      add rsp, 040h                                              ; release shadow space and arguments (result in stack pointer)
      ;  - exit(1)
      ; Call exit with 1 arguments
      push 001h                                                  ; value of argument #1 (1 (integer))
      push 019h                                                  ; type of argument #1 (Integer'25)
      lea r15, qword ptr [rsp + 048h]                            ; load address of return value's value
      push r15                                                   ; internal argument 6: pointer to return value slot's value
      lea r15, qword ptr [rsp + 040h]                            ; load address of return value's type
      push r15                                                   ; internal argument 5: pointer to return value slot's type
      sub rsp, 020h                                              ; allocate shadow space
      mov r9, 000h                                               ; internal argument 4: "this" pointer
      mov r8, 000h                                               ; internal argument 3: "this" pointer type
      mov rdx, 000h                                              ; internal argument 2: closure pointer
      mov rcx, 001h                                              ; internal argument 1: number of actual arguments
      call func$exit                                             ; jump to subroutine
      add rsp, 040h                                              ; release shadow space and arguments (result in stack pointer)
    func$_moveBytes$Movebytes$if$oldvalueMask$TypeMatch:         ; after block
    mov rbx, qword ptr [rsp + 070h]                              ; assign value of & operator result to value of | operator result
    or rbx, rsi                                                  ; compute (& operator result) | (& operator result)
    mov rsi, 019h                                                ; | operator result is of type Integer'25
    mov rdi, rbx                                                 ; value initialization of variable declaration for finalValue variable (| operator result)
    mov r12, rsi                                                 ; type initialization of variable declaration for finalValue variable
    ; Line 129: __writeToAddress(toCursor, finalValue);
    ; Call __writeToAddress with 2 arguments
    mov r13, qword ptr [rsp + 030h]                              ; get toCursor variable into register to dereference it
    mov qword ptr [r13], rdi                                     ; __writeToAddress
    mov qword ptr [rsp + 070h], r13                              ; restoring slots to previous scope state
    mov r13, qword ptr [rsp + 040h]                              ; restoring slots to previous scope state
  func$_moveBytes$if$continuation:                               ; end of if
  ; Implicit return from _moveBytes
  mov r15, qword ptr [rbp + 030h]                                ; get pointer to return value of _moveBytes into register to dereference it
  mov qword ptr [r15], 000h                                      ; _moveBytes return value
  mov rbx, qword ptr [rbp + 028h]                                ; get pointer to return value type of _moveBytes into register to dereference it
  mov qword ptr [rbx], 017h                                      ; type of _moveBytes return value (Null'23)
  mov rax, qword ptr [rbp + 030h]                                ; report address of return value
  ; Epilog
  add rsp, 080h                                                  ; free space for stack
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
dq func$_stringByteLength$annotation
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
  sub rsp, 028h                                                  ; allocate space for stack
  lea rbp, qword ptr [rsp + 068h]                                ; set up frame pointer
  ; Check parameter count
  cmp rcx, 001h                                                  ; compare parameter count of _stringByteLength to 1 (integer)
  je func$_stringByteLength$parameterCountCheck$continuation     ; check number of parameters is as expected
    ; Error handling block for parameter count
    ;  - print(parameterCountCheckFailureMessage)
    ; Call __print with 1 arguments
    mov r10, offset parameterCountCheckFailureMessage            ; reading parameterCountCheckFailureMessage for push
    push r10                                                     ; value of argument #1 (parameterCountCheckFailureMessage)
    push 01ah                                                    ; type of argument #1 (String'26)
    lea rax, qword ptr [rsp + 028h]                              ; load address of return value's value
    push rax                                                     ; internal argument 6: pointer to return value slot's value
    lea rax, qword ptr [rsp + 028h]                              ; load address of return value's type
    push rax                                                     ; internal argument 5: pointer to return value slot's type
    sub rsp, 020h                                                ; allocate shadow space
    mov r9, 000h                                                 ; internal argument 4: "this" pointer
    mov r8, 000h                                                 ; internal argument 3: "this" pointer type
    mov rdx, 000h                                                ; internal argument 2: closure pointer
    mov qword ptr [rsp + 048h], rcx                              ; move parameter count of _stringByteLength value out of rcx
    mov rcx, 001h                                                ; internal argument 1: number of actual arguments
    call func$__print                                            ; jump to subroutine
    add rsp, 040h                                                ; release shadow space and arguments (result in stack pointer)
    ;  - exit(1)
    ; Call exit with 1 arguments
    push 001h                                                    ; value of argument #1 (1 (integer))
    push 019h                                                    ; type of argument #1 (Integer'25)
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
  func$_stringByteLength$parameterCountCheck$continuation:       ; end of parameter count check
  ; Check type of parameter 0, data (expecting String)
  mov rsi, qword ptr [rbp + 038h]                                ; move type of data to testByte
  mov rax, rsi                                                   ; move testByte to testByte
  mov rdi, 002h                                                  ; read operand of mul (type table width in bytes) 
  mul rdi                                                        ; adjust to the relative start of that type's entry in the type table
  mov r12, offset typeTable                                      ; read second operand of + (type table pointer)
  add rax, r12                                                   ; finally offset all of that by the start of the type table itself (result in testByte)
  bt qword ptr [rax], 003h                                       ; check that data is String
  jc func$_stringByteLength$data$TypeMatch                       ; skip next block if the type matches
    ; Error handling block for data
    ;  - print(parameterTypeCheckFailureMessage)
    ; Call __print with 1 arguments
    mov r13, offset parameterTypeCheckFailureMessage             ; reading parameterTypeCheckFailureMessage for push
    push r13                                                     ; value of argument #1 (parameterTypeCheckFailureMessage)
    push 01ah                                                    ; type of argument #1 (String'26)
    lea r14, qword ptr [rsp + 028h]                              ; load address of return value's value
    push r14                                                     ; internal argument 6: pointer to return value slot's value
    lea r14, qword ptr [rsp + 028h]                              ; load address of return value's type
    push r14                                                     ; internal argument 5: pointer to return value slot's type
    sub rsp, 020h                                                ; allocate shadow space
    mov r9, 000h                                                 ; internal argument 4: "this" pointer
    mov r8, 000h                                                 ; internal argument 3: "this" pointer type
    mov rdx, 000h                                                ; internal argument 2: closure pointer
    mov qword ptr [rsp + 048h], rcx                              ; move parameter count of _stringByteLength value out of rcx
    mov rcx, 001h                                                ; internal argument 1: number of actual arguments
    call func$__print                                            ; jump to subroutine
    add rsp, 040h                                                ; release shadow space and arguments (result in stack pointer)
    ;  - exit(1)
    ; Call exit with 1 arguments
    push 001h                                                    ; value of argument #1 (1 (integer))
    push 019h                                                    ; type of argument #1 (Integer'25)
    lea r15, qword ptr [rsp + 028h]                              ; load address of return value's value
    push r15                                                     ; internal argument 6: pointer to return value slot's value
    lea r15, qword ptr [rsp + 028h]                              ; load address of return value's type
    push r15                                                     ; internal argument 5: pointer to return value slot's type
    sub rsp, 020h                                                ; allocate shadow space
    mov r9, 000h                                                 ; internal argument 4: "this" pointer
    mov r8, 000h                                                 ; internal argument 3: "this" pointer type
    mov rdx, 000h                                                ; internal argument 2: closure pointer
    mov rcx, 001h                                                ; internal argument 1: number of actual arguments
    call func$exit                                               ; jump to subroutine
    add rsp, 040h                                                ; release shadow space and arguments (result in stack pointer)
    mov rcx, qword ptr [rsp + 008h]                              ; restoring slots to previous scope state
  func$_stringByteLength$data$TypeMatch:                         ; after block
  ; Line 134: Integer pointer = data __as__ Integer;
  mov r10, qword ptr [rbp + 040h]                                ; force cast of data to Integer
  mov rbx, 019h                                                  ; force cast of data to Integer is of type Integer'25
  mov rsi, r10                                                   ; value initialization of variable declaration for pointer variable (force cast of data to Integer)
  mov rax, rbx                                                   ; type initialization of variable declaration for pointer variable
  ; Line 135: return __readFromAddress(pointer + 8);
  cmp rax, 000h                                                  ; compare type of pointer variable to <sentinel>
  jne func$_stringByteLength$pointer$TypeMatch                   ; skip next block if pointer variable is not sentinel
    ; Error handling block for pointer
    ;  - print(operandTypeCheckFailureMessage)
    ; Call __print with 1 arguments
    mov rdi, offset operandTypeCheckFailureMessage               ; reading operandTypeCheckFailureMessage for push
    push rdi                                                     ; value of argument #1 (operandTypeCheckFailureMessage)
    push 01ah                                                    ; type of argument #1 (String'26)
    lea r12, qword ptr [rsp + 028h]                              ; load address of return value's value
    push r12                                                     ; internal argument 6: pointer to return value slot's value
    lea r12, qword ptr [rsp + 028h]                              ; load address of return value's type
    push r12                                                     ; internal argument 5: pointer to return value slot's type
    sub rsp, 020h                                                ; allocate shadow space
    mov r9, 000h                                                 ; internal argument 4: "this" pointer
    mov r8, 000h                                                 ; internal argument 3: "this" pointer type
    mov rdx, 000h                                                ; internal argument 2: closure pointer
    mov qword ptr [rsp + 048h], rcx                              ; move parameter count of _stringByteLength value out of rcx
    mov rcx, 001h                                                ; internal argument 1: number of actual arguments
    mov qword ptr [rsp + 040h], rax                              ; move pointer variable type out of rax
    call func$__print                                            ; jump to subroutine
    add rsp, 040h                                                ; release shadow space and arguments (result in stack pointer)
    ;  - exit(1)
    ; Call exit with 1 arguments
    push 001h                                                    ; value of argument #1 (1 (integer))
    push 019h                                                    ; type of argument #1 (Integer'25)
    lea r13, qword ptr [rsp + 028h]                              ; load address of return value's value
    push r13                                                     ; internal argument 6: pointer to return value slot's value
    lea r13, qword ptr [rsp + 028h]                              ; load address of return value's type
    push r13                                                     ; internal argument 5: pointer to return value slot's type
    sub rsp, 020h                                                ; allocate shadow space
    mov r9, 000h                                                 ; internal argument 4: "this" pointer
    mov r8, 000h                                                 ; internal argument 3: "this" pointer type
    mov rdx, 000h                                                ; internal argument 2: closure pointer
    mov rcx, 001h                                                ; internal argument 1: number of actual arguments
    call func$exit                                               ; jump to subroutine
    add rsp, 040h                                                ; release shadow space and arguments (result in stack pointer)
    mov rax, qword ptr [rsp + 000h]                              ; restoring slots to previous scope state
    mov rcx, qword ptr [rsp + 008h]                              ; restoring slots to previous scope state
  func$_stringByteLength$pointer$TypeMatch:                      ; after block
  mov rbx, rsi                                                   ; assign value of pointer variable to value of + operator result
  add rbx, 008h                                                  ; compute (pointer variable) + (8) (result in + operator result)
  mov rsi, 019h                                                  ; + operator result is of type Integer'25
  ; Call __readFromAddress with 1 arguments
  mov rax, qword ptr [rbx]                                       ; dereference first argument of __readFromAddress
  mov rdi, 019h                                                  ; dereferenced + operator result is of type Integer'25
  cmp rdi, 000h                                                  ; compare type of dereferenced + operator result to <sentinel>
  jne func$_stringByteLength$StringbytelengthReturnValue$TypeMatch ; skip next block if dereferenced + operator result is not sentinel
    ; Error handling block for _stringByteLength return value
    ;  - print(returnValueTypeCheckFailureMessage)
    ; Call __print with 1 arguments
    mov r12, offset returnValueTypeCheckFailureMessage           ; reading returnValueTypeCheckFailureMessage for push
    push r12                                                     ; value of argument #1 (returnValueTypeCheckFailureMessage)
    push 01ah                                                    ; type of argument #1 (String'26)
    lea r13, qword ptr [rsp + 028h]                              ; load address of return value's value
    push r13                                                     ; internal argument 6: pointer to return value slot's value
    lea r13, qword ptr [rsp + 028h]                              ; load address of return value's type
    push r13                                                     ; internal argument 5: pointer to return value slot's type
    sub rsp, 020h                                                ; allocate shadow space
    mov r9, 000h                                                 ; internal argument 4: "this" pointer
    mov r8, 000h                                                 ; internal argument 3: "this" pointer type
    mov rdx, 000h                                                ; internal argument 2: closure pointer
    mov qword ptr [rsp + 048h], rcx                              ; move parameter count of _stringByteLength value out of rcx
    mov rcx, 001h                                                ; internal argument 1: number of actual arguments
    mov qword ptr [rsp + 040h], rax                              ; move dereferenced + operator result value out of rax
    call func$__print                                            ; jump to subroutine
    add rsp, 040h                                                ; release shadow space and arguments (result in stack pointer)
    ;  - exit(1)
    ; Call exit with 1 arguments
    push 001h                                                    ; value of argument #1 (1 (integer))
    push 019h                                                    ; type of argument #1 (Integer'25)
    lea r14, qword ptr [rsp + 028h]                              ; load address of return value's value
    push r14                                                     ; internal argument 6: pointer to return value slot's value
    lea r14, qword ptr [rsp + 028h]                              ; load address of return value's type
    push r14                                                     ; internal argument 5: pointer to return value slot's type
    sub rsp, 020h                                                ; allocate shadow space
    mov r9, 000h                                                 ; internal argument 4: "this" pointer
    mov r8, 000h                                                 ; internal argument 3: "this" pointer type
    mov rdx, 000h                                                ; internal argument 2: closure pointer
    mov rcx, 001h                                                ; internal argument 1: number of actual arguments
    call func$exit                                               ; jump to subroutine
    add rsp, 040h                                                ; release shadow space and arguments (result in stack pointer)
    mov rax, qword ptr [rsp + 000h]                              ; restoring slots to previous scope state
    mov rcx, qword ptr [rsp + 008h]                              ; restoring slots to previous scope state
  func$_stringByteLength$StringbytelengthReturnValue$TypeMatch:  ; after block
  mov r15, qword ptr [rbp + 030h]                                ; get pointer to return value of _stringByteLength into register to dereference it
  mov qword ptr [r15], rax                                       ; _stringByteLength return value
  mov r10, qword ptr [rbp + 028h]                                ; get pointer to return value type of _stringByteLength into register to dereference it
  mov qword ptr [r10], rdi                                       ; type of _stringByteLength return value
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

; concat
dq func$concat$annotation
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
  sub rsp, 088h                                                  ; allocate space for stack
  lea rbp, qword ptr [rsp + 0c8h]                                ; set up frame pointer
  ; Varargs parameter type check; expecting parameters to be String
  lea r10, qword ptr [rbp + 040h]                                ; get base address of varargs, where loop will start
  mov rax, rcx                                                   ; assign value of parameter count of concat to value of pointer to last argument
  mov rbx, 010h                                                  ; read operand of mul (10 (integer)) 
  mul rbx                                                        ; end of loop is the number of arguments times the width of each argument (010h)...
  add rax, r10                                                   ; ...offset from the initial index (result in pointer to last argument)
  func$concat$varargTypeChecks$Loop:                             ; top of loop
    mov qword ptr [rsp + 078h], 000h                             ; move pointer to indexth argument type into a mutable location
    cmp r10, rax                                                 ; compare pointer to indexth argument to pointer to last argument
    je func$concat$varargTypeChecks$TypesAllMatch                ; we have type-checked all the arguments
    mov rsi, qword ptr [r10 - 008h]                              ; load type of indexth argument into indexth argument
    mov rdi, rsi                                                 ; move type of indexth argument to testByte
    mov qword ptr [rsp + 070h], rax                              ; move pointer to last argument value out of rax
    mov rax, rdi                                                 ; move testByte to testByte
    mov r12, 002h                                                ; read operand of mul (type table width in bytes) 
    mul r12                                                      ; adjust to the relative start of that type's entry in the type table
    mov r13, offset typeTable                                    ; read second operand of + (type table pointer)
    add rax, r13                                                 ; finally offset all of that by the start of the type table itself (result in testByte)
    bt qword ptr [rax], 003h                                     ; check that vararg types is String
    jc func$concat$varargTypeChecks$TypeMatch                    ; skip next block if the type matches
      ; Error handling block for vararg types
      ;  - print(parameterTypeCheckFailureMessage)
      ; Call __print with 1 arguments
      mov r14, offset parameterTypeCheckFailureMessage           ; reading parameterTypeCheckFailureMessage for push
      push r14                                                   ; value of argument #1 (parameterTypeCheckFailureMessage)
      push 01ah                                                  ; type of argument #1 (String'26)
      lea r15, qword ptr [rsp + 078h]                            ; load address of return value's value
      push r15                                                   ; internal argument 6: pointer to return value slot's value
      lea r15, qword ptr [rsp + 078h]                            ; load address of return value's type
      push r15                                                   ; internal argument 5: pointer to return value slot's type
      sub rsp, 020h                                              ; allocate shadow space
      mov r9, 000h                                               ; internal argument 4: "this" pointer
      mov r8, 000h                                               ; internal argument 3: "this" pointer type
      mov rdx, 000h                                              ; internal argument 2: closure pointer
      mov qword ptr [rsp + 098h], rcx                            ; move parameter count of concat value out of rcx
      mov rcx, 001h                                              ; internal argument 1: number of actual arguments
      mov qword ptr [rsp + 090h], r10                            ; move pointer to indexth argument value out of r10
      call func$__print                                          ; jump to subroutine
      add rsp, 040h                                              ; release shadow space and arguments (result in stack pointer)
      ;  - exit(1)
      ; Call exit with 1 arguments
      push 001h                                                  ; value of argument #1 (1 (integer))
      push 019h                                                  ; type of argument #1 (Integer'25)
      lea r10, qword ptr [rsp + 078h]                            ; load address of return value's value
      push r10                                                   ; internal argument 6: pointer to return value slot's value
      lea r10, qword ptr [rsp + 078h]                            ; load address of return value's type
      push r10                                                   ; internal argument 5: pointer to return value slot's type
      sub rsp, 020h                                              ; allocate shadow space
      mov r9, 000h                                               ; internal argument 4: "this" pointer
      mov r8, 000h                                               ; internal argument 3: "this" pointer type
      mov rdx, 000h                                              ; internal argument 2: closure pointer
      mov rcx, 001h                                              ; internal argument 1: number of actual arguments
      call func$exit                                             ; jump to subroutine
      add rsp, 040h                                              ; release shadow space and arguments (result in stack pointer)
      mov r10, qword ptr [rsp + 050h]                            ; restoring slots to previous scope state
      mov rcx, qword ptr [rsp + 058h]                            ; restoring slots to previous scope state
    func$concat$varargTypeChecks$TypeMatch:                      ; after block
    add r10, 010h                                                ; next argument (result in pointer to indexth argument)
    mov rax, qword ptr [rsp + 070h]                              ; restoring slots to previous scope state
    jmp func$concat$varargTypeChecks$Loop                        ; return to top of loop
    func$concat$varargTypeChecks$TypesAllMatch:                  ; after loop
    mov rax, qword ptr [rsp + 070h]                              ; restoring slots to previous scope state
  ; Line 139: Integer length = 0;
  mov rbx, 000h                                                  ; value initialization of variable declaration for length variable (0)
  mov rsi, 019h                                                  ; type initialization of variable declaration for length variable (Integer'25)
  ; Line 140: Integer index = 0;
  mov rdi, 000h                                                  ; value initialization of variable declaration for index variable (0)
  mov rax, 019h                                                  ; type initialization of variable declaration for index variable (Integer'25)
  func$concat$while$top:                                         ; top of while
    ; Call len with 1 arguments
    cmp rax, 000h                                                ; compare type of index variable to <sentinel>
    jne func$concat$while$index$TypeMatch                        ; skip next block if index variable is not sentinel
      ; Error handling block for index
      ;  - print(operandTypeCheckFailureMessage)
      ; Call __print with 1 arguments
      mov r12, offset operandTypeCheckFailureMessage             ; reading operandTypeCheckFailureMessage for push
      push r12                                                   ; value of argument #1 (operandTypeCheckFailureMessage)
      push 01ah                                                  ; type of argument #1 (String'26)
      lea r13, qword ptr [rsp + 088h]                            ; load address of return value's value
      push r13                                                   ; internal argument 6: pointer to return value slot's value
      lea r13, qword ptr [rsp + 088h]                            ; load address of return value's type
      push r13                                                   ; internal argument 5: pointer to return value slot's type
      sub rsp, 020h                                              ; allocate shadow space
      mov r9, 000h                                               ; internal argument 4: "this" pointer
      mov r8, 000h                                               ; internal argument 3: "this" pointer type
      mov rdx, 000h                                              ; internal argument 2: closure pointer
      mov qword ptr [rsp + 0a8h], rcx                            ; move parameter count of concat value out of rcx
      mov rcx, 001h                                              ; internal argument 1: number of actual arguments
      mov qword ptr [rsp + 0a0h], rax                            ; move index variable type out of rax
      call func$__print                                          ; jump to subroutine
      add rsp, 040h                                              ; release shadow space and arguments (result in stack pointer)
      ;  - exit(1)
      ; Call exit with 1 arguments
      push 001h                                                  ; value of argument #1 (1 (integer))
      push 019h                                                  ; type of argument #1 (Integer'25)
      lea r14, qword ptr [rsp + 088h]                            ; load address of return value's value
      push r14                                                   ; internal argument 6: pointer to return value slot's value
      lea r14, qword ptr [rsp + 088h]                            ; load address of return value's type
      push r14                                                   ; internal argument 5: pointer to return value slot's type
      sub rsp, 020h                                              ; allocate shadow space
      mov r9, 000h                                               ; internal argument 4: "this" pointer
      mov r8, 000h                                               ; internal argument 3: "this" pointer type
      mov rdx, 000h                                              ; internal argument 2: closure pointer
      mov rcx, 001h                                              ; internal argument 1: number of actual arguments
      call func$exit                                             ; jump to subroutine
      add rsp, 040h                                              ; release shadow space and arguments (result in stack pointer)
      mov rax, qword ptr [rsp + 060h]                            ; restoring slots to previous scope state
      mov rcx, qword ptr [rsp + 068h]                            ; restoring slots to previous scope state
    func$concat$while$index$TypeMatch:                           ; after block
    mov qword ptr [rsp + 078h], rsi                              ; move length variable type out of rsi
    xor rsi, rsi                                                 ; clear < operator result
    cmp rdi, rcx                                                 ; compare index variable with parameter count of concat
    setl sil                                                     ; store result in < operator result
    mov qword ptr [rsp + 070h], rdi                              ; move index variable value out of rdi
    mov rdi, 018h                                                ; < operator result is of type Boolean'24
    cmp rsi, 000h                                                ; compare < operator result to false
    jne func$concat$while$body                                   ; while condition
    mov rsi, qword ptr [rsp + 078h]                              ; restoring slots to previous scope state
    mov rdi, qword ptr [rsp + 070h]                              ; restoring slots to previous scope state
    jmp func$concat$while$bottom                                 ; break out of while
    func$concat$while$body:                                      ; start of while
    ; Line 142: length += _stringByteLength(arguments[index]);
    cmp qword ptr [rsp + 070h], rcx                              ; compare index variable to parameter count of concat
    jge func$concat$while$subscript$boundsError                  ; index out of range (too high)
    cmp qword ptr [rsp + 070h], 000h                             ; compare index variable to 0 (integer)
    jge func$concat$while$subscript$inBounds                     ; index not out of range (not negative)
    func$concat$while$subscript$boundsError:                     ; invalid index
      ; Error handling block for subscript bounds error
      ;  - print(boundsFailureMessage)
      ; Call __print with 1 arguments
      mov r14, offset boundsFailureMessage                       ; reading boundsFailureMessage for push
      push r14                                                   ; value of argument #1 (boundsFailureMessage)
      push 01ah                                                  ; type of argument #1 (String'26)
      lea r15, qword ptr [rsp + 078h]                            ; load address of return value's value
      push r15                                                   ; internal argument 6: pointer to return value slot's value
      lea r15, qword ptr [rsp + 078h]                            ; load address of return value's type
      push r15                                                   ; internal argument 5: pointer to return value slot's type
      sub rsp, 020h                                              ; allocate shadow space
      mov r9, 000h                                               ; internal argument 4: "this" pointer
      mov r8, 000h                                               ; internal argument 3: "this" pointer type
      mov rdx, 000h                                              ; internal argument 2: closure pointer
      mov qword ptr [rsp + 098h], rcx                            ; move parameter count of concat value out of rcx
      mov rcx, 001h                                              ; internal argument 1: number of actual arguments
      mov qword ptr [rsp + 090h], rax                            ; move index variable type out of rax
      call func$__print                                          ; jump to subroutine
      add rsp, 040h                                              ; release shadow space and arguments (result in stack pointer)
      ;  - exit(1)
      ; Call exit with 1 arguments
      push 001h                                                  ; value of argument #1 (1 (integer))
      push 019h                                                  ; type of argument #1 (Integer'25)
      lea r10, qword ptr [rsp + 078h]                            ; load address of return value's value
      push r10                                                   ; internal argument 6: pointer to return value slot's value
      lea r10, qword ptr [rsp + 078h]                            ; load address of return value's type
      push r10                                                   ; internal argument 5: pointer to return value slot's type
      sub rsp, 020h                                              ; allocate shadow space
      mov r9, 000h                                               ; internal argument 4: "this" pointer
      mov r8, 000h                                               ; internal argument 3: "this" pointer type
      mov rdx, 000h                                              ; internal argument 2: closure pointer
      mov rcx, 001h                                              ; internal argument 1: number of actual arguments
      call func$exit                                             ; jump to subroutine
      add rsp, 040h                                              ; release shadow space and arguments (result in stack pointer)
      mov rax, qword ptr [rsp + 050h]                            ; restoring slots to previous scope state
      mov rcx, qword ptr [rsp + 058h]                            ; restoring slots to previous scope state
    func$concat$while$subscript$inBounds:                        ; valid index
    mov qword ptr [rsp + 068h], rbx                              ; move length variable value out of rbx
    lea rbx, qword ptr [rbp + 040h]                              ; base address of varargs
    mov rsi, qword ptr [rsp + 070h]                              ; assign value of index variable to value of index into list * 16
    shl rsi, 004h                                                ; multiply by 8*2
    mov rdi, rbx                                                 ; assign value of base address of varargs to value of pointer to value (and type, later)
    add rdi, rsi                                                 ; get pointer to value (result in pointer to value (and type, later))
    mov qword ptr [rsp + 060h], rax                              ; move index variable type out of rax
    mov rax, qword ptr [rdi]                                     ; store value
    mov r12, qword ptr [rdi - 008h]                              ; store type
    ; increment reference count for arguments[index] if necessary
    cmp r12, 01ah                                                ; compare type of arguments[index] to String
    jne func$concat$while$AfterIncref                            ; if not a string, skip incref
    mov r13, qword ptr [rax]                                     ; dereference string to get to ref count
    cmp r13, 0                                                   ; compare string refcount temporary to 0
    js func$concat$while$AfterIncref                             ; if ref count is negative (constant strings), skip incref
    add r13, 001h                                                ; increment ref count (result in string refcount temporary)
    mov qword ptr [rax], r13                                     ; put it back in the string
    func$concat$while$AfterIncref:                               ; after incref
    ; Call _stringByteLength with 1 arguments
    push rax                                                     ; value of argument #1 (arguments[index])
    push r12                                                     ; type of argument #1
    lea r14, qword ptr [rsp + 068h]                              ; load address of return value's value
    push r14                                                     ; internal argument 6: pointer to return value slot's value
    lea r14, qword ptr [rsp + 068h]                              ; load address of return value's type
    push r14                                                     ; internal argument 5: pointer to return value slot's type
    sub rsp, 020h                                                ; allocate shadow space
    mov r9, 000h                                                 ; internal argument 4: "this" pointer
    mov r8, 000h                                                 ; internal argument 3: "this" pointer type
    mov rdx, 000h                                                ; internal argument 2: closure pointer
    mov qword ptr [rsp + 088h], rcx                              ; move parameter count of concat value out of rcx
    mov rcx, 001h                                                ; internal argument 1: number of actual arguments
    mov qword ptr [rsp + 080h], rax                              ; move arguments[index] value out of rax
    call func$_stringByteLength                                  ; jump to subroutine
    add rsp, 040h                                                ; release shadow space and arguments (result in stack pointer)
    cmp qword ptr [rsp + 078h], 000h                             ; compare type of length variable to <sentinel>
    jne func$concat$while$lengthVariable$TypeMatch               ; skip next block if length variable is not sentinel
      ; Error handling block for length variable
      ;  - print(operandTypeCheckFailureMessage)
      ; Call __print with 1 arguments
      mov r15, offset operandTypeCheckFailureMessage             ; reading operandTypeCheckFailureMessage for push
      push r15                                                   ; value of argument #1 (operandTypeCheckFailureMessage)
      push 01ah                                                  ; type of argument #1 (String'26)
      lea r10, qword ptr [rsp + 048h]                            ; load address of return value's value
      push r10                                                   ; internal argument 6: pointer to return value slot's value
      lea r10, qword ptr [rsp + 048h]                            ; load address of return value's type
      push r10                                                   ; internal argument 5: pointer to return value slot's type
      sub rsp, 020h                                              ; allocate shadow space
      mov r9, 000h                                               ; internal argument 4: "this" pointer
      mov r8, 000h                                               ; internal argument 3: "this" pointer type
      mov rdx, 000h                                              ; internal argument 2: closure pointer
      mov rcx, 001h                                              ; internal argument 1: number of actual arguments
      call func$__print                                          ; jump to subroutine
      add rsp, 040h                                              ; release shadow space and arguments (result in stack pointer)
      ;  - exit(1)
      ; Call exit with 1 arguments
      push 001h                                                  ; value of argument #1 (1 (integer))
      push 019h                                                  ; type of argument #1 (Integer'25)
      lea rbx, qword ptr [rsp + 048h]                            ; load address of return value's value
      push rbx                                                   ; internal argument 6: pointer to return value slot's value
      lea rbx, qword ptr [rsp + 048h]                            ; load address of return value's type
      push rbx                                                   ; internal argument 5: pointer to return value slot's type
      sub rsp, 020h                                              ; allocate shadow space
      mov r9, 000h                                               ; internal argument 4: "this" pointer
      mov r8, 000h                                               ; internal argument 3: "this" pointer type
      mov rdx, 000h                                              ; internal argument 2: closure pointer
      mov rcx, 001h                                              ; internal argument 1: number of actual arguments
      call func$exit                                             ; jump to subroutine
      add rsp, 040h                                              ; release shadow space and arguments (result in stack pointer)
    func$concat$while$lengthVariable$TypeMatch:                  ; after block
    cmp qword ptr [rsp + 050h], 000h                             ; compare type of _stringByteLength return value to <sentinel>
    jne func$concat$while$StringbytelengthReturnValue$TypeMatch  ; skip next block if _stringByteLength return value is not sentinel
      ; Error handling block for _stringByteLength return value
      ;  - print(operandTypeCheckFailureMessage)
      ; Call __print with 1 arguments
      mov rsi, offset operandTypeCheckFailureMessage             ; reading operandTypeCheckFailureMessage for push
      push rsi                                                   ; value of argument #1 (operandTypeCheckFailureMessage)
      push 01ah                                                  ; type of argument #1 (String'26)
      lea rdi, qword ptr [rsp + 048h]                            ; load address of return value's value
      push rdi                                                   ; internal argument 6: pointer to return value slot's value
      lea rdi, qword ptr [rsp + 048h]                            ; load address of return value's type
      push rdi                                                   ; internal argument 5: pointer to return value slot's type
      sub rsp, 020h                                              ; allocate shadow space
      mov r9, 000h                                               ; internal argument 4: "this" pointer
      mov r8, 000h                                               ; internal argument 3: "this" pointer type
      mov rdx, 000h                                              ; internal argument 2: closure pointer
      mov rcx, 001h                                              ; internal argument 1: number of actual arguments
      call func$__print                                          ; jump to subroutine
      add rsp, 040h                                              ; release shadow space and arguments (result in stack pointer)
      ;  - exit(1)
      ; Call exit with 1 arguments
      push 001h                                                  ; value of argument #1 (1 (integer))
      push 019h                                                  ; type of argument #1 (Integer'25)
      lea rax, qword ptr [rsp + 048h]                            ; load address of return value's value
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
    func$concat$while$StringbytelengthReturnValue$TypeMatch:     ; after block
    mov qword ptr [rsp + 038h], r12                              ; move arguments[index] type out of r12
    mov r12, qword ptr [rsp + 068h]                              ; assign value of length variable to value of += operator result
    add r12, qword ptr [rsp + 058h]                              ; += operator
    mov r13, 019h                                                ; += operator result is of type Integer'25
    mov qword ptr [rsp + 068h], r12                              ; store value
    mov qword ptr [rsp + 078h], r13                              ; store type
    ; Line 143: index += 1;
    cmp qword ptr [rsp + 060h], 000h                             ; compare type of index variable to <sentinel>
    jne func$concat$while$indexVariable$TypeMatch                ; skip next block if index variable is not sentinel
      ; Error handling block for index variable
      ;  - print(operandTypeCheckFailureMessage)
      ; Call __print with 1 arguments
      mov r14, offset operandTypeCheckFailureMessage             ; reading operandTypeCheckFailureMessage for push
      push r14                                                   ; value of argument #1 (operandTypeCheckFailureMessage)
      push 01ah                                                  ; type of argument #1 (String'26)
      lea r15, qword ptr [rsp + 068h]                            ; load address of return value's value
      push r15                                                   ; internal argument 6: pointer to return value slot's value
      lea r15, qword ptr [rsp + 068h]                            ; load address of return value's type
      push r15                                                   ; internal argument 5: pointer to return value slot's type
      sub rsp, 020h                                              ; allocate shadow space
      mov r9, 000h                                               ; internal argument 4: "this" pointer
      mov r8, 000h                                               ; internal argument 3: "this" pointer type
      mov rdx, 000h                                              ; internal argument 2: closure pointer
      mov rcx, 001h                                              ; internal argument 1: number of actual arguments
      call func$__print                                          ; jump to subroutine
      add rsp, 040h                                              ; release shadow space and arguments (result in stack pointer)
      ;  - exit(1)
      ; Call exit with 1 arguments
      push 001h                                                  ; value of argument #1 (1 (integer))
      push 019h                                                  ; type of argument #1 (Integer'25)
      lea r10, qword ptr [rsp + 068h]                            ; load address of return value's value
      push r10                                                   ; internal argument 6: pointer to return value slot's value
      lea r10, qword ptr [rsp + 068h]                            ; load address of return value's type
      push r10                                                   ; internal argument 5: pointer to return value slot's type
      sub rsp, 020h                                              ; allocate shadow space
      mov r9, 000h                                               ; internal argument 4: "this" pointer
      mov r8, 000h                                               ; internal argument 3: "this" pointer type
      mov rdx, 000h                                              ; internal argument 2: closure pointer
      mov rcx, 001h                                              ; internal argument 1: number of actual arguments
      call func$exit                                             ; jump to subroutine
      add rsp, 040h                                              ; release shadow space and arguments (result in stack pointer)
    func$concat$while$indexVariable$TypeMatch:                   ; after block
    mov rax, qword ptr [rsp + 070h]                              ; assign value of index variable to value of += operator result
    add rax, 001h                                                ; += operator
    mov r12, 019h                                                ; += operator result is of type Integer'25
    mov qword ptr [rsp + 070h], rax                              ; store value
    mov qword ptr [rsp + 060h], r12                              ; store type
    ; Calling decref on arguments[index] (static type: String'26)
    sub rsp, 20h                                                 ; allocate shadow space for decref
    mov rdx, qword ptr [rsp + 058h]                              ; arg #2: type of potential string
    mov rcx, qword ptr [rsp + 060h]                              ; arg #1: value of potential string
    call intrinsic$decref                                        ; call decref
    add rsp, 20h                                                 ; free shadow space for decref
    mov rax, qword ptr [rsp + 060h]                              ; restoring slots to previous scope state
    mov rbx, qword ptr [rsp + 068h]                              ; restoring slots to previous scope state
    mov rcx, qword ptr [rsp + 048h]                              ; restoring slots to previous scope state
    mov rsi, qword ptr [rsp + 078h]                              ; restoring slots to previous scope state
    mov rdi, qword ptr [rsp + 070h]                              ; restoring slots to previous scope state
    jmp func$concat$while$top                                    ; return to top of while
  func$concat$while$bottom:                                      ; bottom of while
  ; Line 145: Integer resultPointer = _alloc(16 /* 0x10 */ + length);
  cmp rsi, 000h                                                  ; compare type of length variable to <sentinel>
  jne func$concat$length$TypeMatch                               ; skip next block if length variable is not sentinel
    ; Error handling block for length
    ;  - print(operandTypeCheckFailureMessage)
    ; Call __print with 1 arguments
    mov r10, offset operandTypeCheckFailureMessage               ; reading operandTypeCheckFailureMessage for push
    push r10                                                     ; value of argument #1 (operandTypeCheckFailureMessage)
    push 01ah                                                    ; type of argument #1 (String'26)
    mov qword ptr [rsp + 080h], rbx                              ; move length variable value out of rbx
    lea rbx, qword ptr [rsp + 088h]                              ; load address of return value's value
    push rbx                                                     ; internal argument 6: pointer to return value slot's value
    lea rbx, qword ptr [rsp + 080h]                              ; load address of return value's type
    push rbx                                                     ; internal argument 5: pointer to return value slot's type
    sub rsp, 020h                                                ; allocate shadow space
    mov r9, 000h                                                 ; internal argument 4: "this" pointer
    mov r8, 000h                                                 ; internal argument 3: "this" pointer type
    mov rdx, 000h                                                ; internal argument 2: closure pointer
    mov qword ptr [rsp + 0a0h], rcx                              ; move parameter count of concat value out of rcx
    mov rcx, 001h                                                ; internal argument 1: number of actual arguments
    mov qword ptr [rsp + 098h], rax                              ; move index variable type out of rax
    call func$__print                                            ; jump to subroutine
    add rsp, 040h                                                ; release shadow space and arguments (result in stack pointer)
    ;  - exit(1)
    ; Call exit with 1 arguments
    push 001h                                                    ; value of argument #1 (1 (integer))
    push 019h                                                    ; type of argument #1 (Integer'25)
    mov qword ptr [rsp + 078h], rsi                              ; move length variable type out of rsi
    lea rsi, qword ptr [rsp + 088h]                              ; load address of return value's value
    push rsi                                                     ; internal argument 6: pointer to return value slot's value
    lea rsi, qword ptr [rsp + 068h]                              ; load address of return value's type
    push rsi                                                     ; internal argument 5: pointer to return value slot's type
    sub rsp, 020h                                                ; allocate shadow space
    mov r9, 000h                                                 ; internal argument 4: "this" pointer
    mov r8, 000h                                                 ; internal argument 3: "this" pointer type
    mov rdx, 000h                                                ; internal argument 2: closure pointer
    mov rcx, 001h                                                ; internal argument 1: number of actual arguments
    call func$exit                                               ; jump to subroutine
    add rsp, 040h                                                ; release shadow space and arguments (result in stack pointer)
    mov rax, qword ptr [rsp + 058h]                              ; restoring slots to previous scope state
    mov rbx, qword ptr [rsp + 070h]                              ; restoring slots to previous scope state
    mov rcx, qword ptr [rsp + 060h]                              ; restoring slots to previous scope state
    mov rsi, qword ptr [rsp + 068h]                              ; restoring slots to previous scope state
  func$concat$length$TypeMatch:                                  ; after block
  mov qword ptr [rsp + 078h], rdi                                ; move index variable value out of rdi
  mov rdi, 010h                                                  ; assign value of 16 /* 0x10 */ to value of + operator result
  add rdi, rbx                                                   ; compute (16 /* 0x10 */) + (length variable) (result in + operator result)
  mov qword ptr [rsp + 070h], rax                                ; move index variable type out of rax
  mov rax, 019h                                                  ; + operator result is of type Integer'25
  ; Call _alloc with 1 arguments
  push rdi                                                       ; value of argument #1 (+ operator result)
  push rax                                                       ; type of argument #1
  lea r12, qword ptr [rsp + 078h]                                ; load address of return value's value
  push r12                                                       ; internal argument 6: pointer to return value slot's value
  lea r12, qword ptr [rsp + 078h]                                ; load address of return value's type
  push r12                                                       ; internal argument 5: pointer to return value slot's type
  sub rsp, 020h                                                  ; allocate shadow space
  mov r9, 000h                                                   ; internal argument 4: "this" pointer
  mov r8, 000h                                                   ; internal argument 3: "this" pointer type
  mov rdx, 000h                                                  ; internal argument 2: closure pointer
  mov qword ptr [rsp + 098h], rcx                                ; move parameter count of concat value out of rcx
  mov rcx, 001h                                                  ; internal argument 1: number of actual arguments
  call func$_alloc                                               ; jump to subroutine
  add rsp, 040h                                                  ; release shadow space and arguments (result in stack pointer)
  mov r13, qword ptr [rsp + 068h]                                ; value initialization of variable declaration for resultPointer variable (_alloc return value)
  mov r14, qword ptr [rsp + 060h]                                ; type initialization of variable declaration for resultPointer variable
  ; Line 146: __writeToAddress(resultPointer, 1);
  ; Call __writeToAddress with 2 arguments
  mov qword ptr [r13], 001h                                      ; __writeToAddress
  ; Line 147: __writeToAddress(resultPointer + 8, length);
  cmp r14, 000h                                                  ; compare type of resultPointer variable to <sentinel>
  jne func$concat$resultpointer$TypeMatch                        ; skip next block if resultPointer variable is not sentinel
    ; Error handling block for resultPointer
    ;  - print(operandTypeCheckFailureMessage)
    ; Call __print with 1 arguments
    mov r15, offset operandTypeCheckFailureMessage               ; reading operandTypeCheckFailureMessage for push
    push r15                                                     ; value of argument #1 (operandTypeCheckFailureMessage)
    push 01ah                                                    ; type of argument #1 (String'26)
    lea r10, qword ptr [rsp + 078h]                              ; load address of return value's value
    push r10                                                     ; internal argument 6: pointer to return value slot's value
    lea r10, qword ptr [rsp + 078h]                              ; load address of return value's type
    push r10                                                     ; internal argument 5: pointer to return value slot's type
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
    push 019h                                                    ; type of argument #1 (Integer'25)
    mov qword ptr [rsp + 070h], rbx                              ; move length variable value out of rbx
    lea rbx, qword ptr [rsp + 078h]                              ; load address of return value's value
    push rbx                                                     ; internal argument 6: pointer to return value slot's value
    lea rbx, qword ptr [rsp + 068h]                              ; load address of return value's type
    push rbx                                                     ; internal argument 5: pointer to return value slot's type
    sub rsp, 020h                                                ; allocate shadow space
    mov r9, 000h                                                 ; internal argument 4: "this" pointer
    mov r8, 000h                                                 ; internal argument 3: "this" pointer type
    mov rdx, 000h                                                ; internal argument 2: closure pointer
    mov rcx, 001h                                                ; internal argument 1: number of actual arguments
    call func$exit                                               ; jump to subroutine
    add rsp, 040h                                                ; release shadow space and arguments (result in stack pointer)
    mov rbx, qword ptr [rsp + 060h]                              ; restoring slots to previous scope state
  func$concat$resultpointer$TypeMatch:                           ; after block
  mov r12, r13                                                   ; assign value of resultPointer variable to value of + operator result
  add r12, 008h                                                  ; compute (resultPointer variable) + (8) (result in + operator result)
  mov qword ptr [rsp + 068h], r13                                ; move resultPointer variable value out of r13
  mov r13, 019h                                                  ; + operator result is of type Integer'25
  ; Call __writeToAddress with 2 arguments
  mov qword ptr [r12], rbx                                       ; __writeToAddress
  ; Line 148: Integer cursor = resultPointer + 16 /* 0x10 */;
  cmp r14, 000h                                                  ; compare type of resultPointer variable to <sentinel>
  jne func$concat$resultpointer$TypeMatch$1                      ; skip next block if resultPointer variable is not sentinel
    ; Error handling block for resultPointer
    ;  - print(operandTypeCheckFailureMessage)
    ; Call __print with 1 arguments
    mov qword ptr [rsp + 060h], r14                              ; move resultPointer variable type out of r14
    mov r14, offset operandTypeCheckFailureMessage               ; reading operandTypeCheckFailureMessage for push
    push r14                                                     ; value of argument #1 (operandTypeCheckFailureMessage)
    push 01ah                                                    ; type of argument #1 (String'26)
    lea r15, qword ptr [rsp + 060h]                              ; load address of return value's value
    push r15                                                     ; internal argument 6: pointer to return value slot's value
    lea r15, qword ptr [rsp + 060h]                              ; load address of return value's type
    push r15                                                     ; internal argument 5: pointer to return value slot's type
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
    push 019h                                                    ; type of argument #1 (Integer'25)
    lea r10, qword ptr [rsp + 060h]                              ; load address of return value's value
    push r10                                                     ; internal argument 6: pointer to return value slot's value
    lea r10, qword ptr [rsp + 060h]                              ; load address of return value's type
    push r10                                                     ; internal argument 5: pointer to return value slot's type
    sub rsp, 020h                                                ; allocate shadow space
    mov r9, 000h                                                 ; internal argument 4: "this" pointer
    mov r8, 000h                                                 ; internal argument 3: "this" pointer type
    mov rdx, 000h                                                ; internal argument 2: closure pointer
    mov rcx, 001h                                                ; internal argument 1: number of actual arguments
    call func$exit                                               ; jump to subroutine
    add rsp, 040h                                                ; release shadow space and arguments (result in stack pointer)
    mov r14, qword ptr [rsp + 060h]                              ; restoring slots to previous scope state
  func$concat$resultpointer$TypeMatch$1:                         ; after block
  mov rax, qword ptr [rsp + 068h]                                ; assign value of resultPointer variable to value of + operator result
  add rax, 010h                                                  ; compute (resultPointer variable) + (16 /* 0x10 */) (result in + operator result)
  mov r12, 019h                                                  ; + operator result is of type Integer'25
  mov r13, rax                                                   ; value initialization of variable declaration for cursor variable (+ operator result)
  mov qword ptr [rsp + 060h], r14                                ; move resultPointer variable type out of r14
  mov r14, r12                                                   ; type initialization of variable declaration for cursor variable
  ; Line 149: index = 0;
  mov qword ptr [rsp + 078h], 000h                               ; store value
  mov qword ptr [rsp + 070h], 019h                               ; store type (Integer'25)
  func$concat$while$top$1:                                       ; top of while
    ; Call len with 1 arguments
    cmp qword ptr [rsp + 070h], 000h                             ; compare type of index variable to <sentinel>
    jne func$concat$while$index$TypeMatch$1                      ; skip next block if index variable is not sentinel
      ; Error handling block for index
      ;  - print(operandTypeCheckFailureMessage)
      ; Call __print with 1 arguments
      mov r15, offset operandTypeCheckFailureMessage             ; reading operandTypeCheckFailureMessage for push
      push r15                                                   ; value of argument #1 (operandTypeCheckFailureMessage)
      push 01ah                                                  ; type of argument #1 (String'26)
      lea r10, qword ptr [rsp + 060h]                            ; load address of return value's value
      push r10                                                   ; internal argument 6: pointer to return value slot's value
      lea r10, qword ptr [rsp + 060h]                            ; load address of return value's type
      push r10                                                   ; internal argument 5: pointer to return value slot's type
      sub rsp, 020h                                              ; allocate shadow space
      mov r9, 000h                                               ; internal argument 4: "this" pointer
      mov r8, 000h                                               ; internal argument 3: "this" pointer type
      mov rdx, 000h                                              ; internal argument 2: closure pointer
      mov rcx, 001h                                              ; internal argument 1: number of actual arguments
      call func$__print                                          ; jump to subroutine
      add rsp, 040h                                              ; release shadow space and arguments (result in stack pointer)
      ;  - exit(1)
      ; Call exit with 1 arguments
      push 001h                                                  ; value of argument #1 (1 (integer))
      push 019h                                                  ; type of argument #1 (Integer'25)
      lea rbx, qword ptr [rsp + 060h]                            ; load address of return value's value
      push rbx                                                   ; internal argument 6: pointer to return value slot's value
      lea rbx, qword ptr [rsp + 060h]                            ; load address of return value's type
      push rbx                                                   ; internal argument 5: pointer to return value slot's type
      sub rsp, 020h                                              ; allocate shadow space
      mov r9, 000h                                               ; internal argument 4: "this" pointer
      mov r8, 000h                                               ; internal argument 3: "this" pointer type
      mov rdx, 000h                                              ; internal argument 2: closure pointer
      mov rcx, 001h                                              ; internal argument 1: number of actual arguments
      call func$exit                                             ; jump to subroutine
      add rsp, 040h                                              ; release shadow space and arguments (result in stack pointer)
    func$concat$while$index$TypeMatch$1:                         ; after block
    mov r12, qword ptr [rsp + 058h]                              ; reading second value to compare (<DynamicSlot:Integer'25 at [rcx, stack operand #5, stack operand #5]/[019h, 019h, 019h] ("parameter count of concat") (living: true)>)
    mov qword ptr [rsp + 058h], r13                              ; move cursor variable value out of r13
    xor r13, r13                                                 ; clear < operator result
    cmp qword ptr [rsp + 078h], r12                              ; compare index variable with parameter count of concat
    setl r13b                                                    ; store result in < operator result
    mov qword ptr [rsp + 050h], r14                              ; move cursor variable type out of r14
    mov r14, 018h                                                ; < operator result is of type Boolean'24
    cmp r13, 000h                                                ; compare < operator result to false
    jne func$concat$while$body$1                                 ; while condition
    mov r14, qword ptr [rsp + 050h]                              ; restoring slots to previous scope state
    mov r13, qword ptr [rsp + 058h]                              ; restoring slots to previous scope state
    mov qword ptr [rsp + 058h], r12                              ; restoring slots to previous scope state
    jmp func$concat$while$bottom$1                               ; break out of while
    func$concat$while$body$1:                                    ; start of while
    ; Line 151: String segment = arguments[index];
    cmp qword ptr [rsp + 078h], r12                              ; compare index variable to parameter count of concat
    jge func$concat$while$subscript$boundsError$1                ; index out of range (too high)
    cmp qword ptr [rsp + 078h], 000h                             ; compare index variable to 0 (integer)
    jge func$concat$while$subscript$inBounds$1                   ; index not out of range (not negative)
    func$concat$while$subscript$boundsError$1:                   ; invalid index
      ; Error handling block for subscript bounds error
      ;  - print(boundsFailureMessage)
      ; Call __print with 1 arguments
      mov rsi, offset boundsFailureMessage                       ; reading boundsFailureMessage for push
      push rsi                                                   ; value of argument #1 (boundsFailureMessage)
      push 01ah                                                  ; type of argument #1 (String'26)
      lea rdi, qword ptr [rsp + 058h]                            ; load address of return value's value
      push rdi                                                   ; internal argument 6: pointer to return value slot's value
      lea rdi, qword ptr [rsp + 058h]                            ; load address of return value's type
      push rdi                                                   ; internal argument 5: pointer to return value slot's type
      sub rsp, 020h                                              ; allocate shadow space
      mov r9, 000h                                               ; internal argument 4: "this" pointer
      mov r8, 000h                                               ; internal argument 3: "this" pointer type
      mov rdx, 000h                                              ; internal argument 2: closure pointer
      mov rcx, 001h                                              ; internal argument 1: number of actual arguments
      call func$__print                                          ; jump to subroutine
      add rsp, 040h                                              ; release shadow space and arguments (result in stack pointer)
      ;  - exit(1)
      ; Call exit with 1 arguments
      push 001h                                                  ; value of argument #1 (1 (integer))
      push 019h                                                  ; type of argument #1 (Integer'25)
      lea rax, qword ptr [rsp + 058h]                            ; load address of return value's value
      push rax                                                   ; internal argument 6: pointer to return value slot's value
      lea rax, qword ptr [rsp + 058h]                            ; load address of return value's type
      push rax                                                   ; internal argument 5: pointer to return value slot's type
      sub rsp, 020h                                              ; allocate shadow space
      mov r9, 000h                                               ; internal argument 4: "this" pointer
      mov r8, 000h                                               ; internal argument 3: "this" pointer type
      mov rdx, 000h                                              ; internal argument 2: closure pointer
      mov rcx, 001h                                              ; internal argument 1: number of actual arguments
      call func$exit                                             ; jump to subroutine
      add rsp, 040h                                              ; release shadow space and arguments (result in stack pointer)
    func$concat$while$subscript$inBounds$1:                      ; valid index
    mov qword ptr [rsp + 048h], r12                              ; move parameter count of concat value out of r12
    lea r12, qword ptr [rbp + 040h]                              ; base address of varargs
    mov r13, qword ptr [rsp + 078h]                              ; assign value of index variable to value of index into list * 16
    shl r13, 004h                                                ; multiply by 8*2
    mov r14, r12                                                 ; assign value of base address of varargs to value of pointer to value (and type, later)
    add r14, r13                                                 ; get pointer to value (result in pointer to value (and type, later))
    mov r15, qword ptr [r14]                                     ; store value
    mov r10, qword ptr [r14 - 008h]                              ; store type
    ; increment reference count for arguments[index] if necessary
    cmp r10, 01ah                                                ; compare type of arguments[index] to String
    jne func$concat$while$AfterIncref$1                          ; if not a string, skip incref
    mov rbx, qword ptr [r15]                                     ; dereference string to get to ref count
    cmp rbx, 0                                                   ; compare string refcount temporary to 0
    js func$concat$while$AfterIncref$1                           ; if ref count is negative (constant strings), skip incref
    add rbx, 001h                                                ; increment ref count (result in string refcount temporary)
    mov qword ptr [r15], rbx                                     ; put it back in the string
    func$concat$while$AfterIncref$1:                             ; after incref
    mov rsi, r15                                                 ; value initialization of variable declaration for segment variable (arguments[index])
    mov rdi, r10                                                 ; type initialization of variable declaration for segment variable
    ; increment reference count for segment variable if necessary
    cmp rdi, 01ah                                                ; compare type of segment variable to String
    jne func$concat$while$AfterIncref$2                          ; if not a string, skip incref
    mov rax, qword ptr [rsi]                                     ; dereference string to get to ref count
    cmp rax, 0                                                   ; compare string refcount temporary to 0
    js func$concat$while$AfterIncref$2                           ; if ref count is negative (constant strings), skip incref
    add rax, 001h                                                ; increment ref count (result in string refcount temporary)
    mov qword ptr [rsi], rax                                     ; put it back in the string
    func$concat$while$AfterIncref$2:                             ; after incref
    ; Line 152: Integer segmentLength = _stringByteLength(segment);
    ; Call _stringByteLength with 1 arguments
    push rsi                                                     ; value of argument #1 (segment variable)
    push rdi                                                     ; type of argument #1
    lea r9, qword ptr [rsp + 050h]                               ; load address of return value's value
    push r9                                                      ; internal argument 6: pointer to return value slot's value
    lea r9, qword ptr [rsp + 050h]                               ; load address of return value's type
    push r9                                                      ; internal argument 5: pointer to return value slot's type
    sub rsp, 020h                                                ; allocate shadow space
    mov r9, 000h                                                 ; internal argument 4: "this" pointer
    mov r8, 000h                                                 ; internal argument 3: "this" pointer type
    mov rdx, 000h                                                ; internal argument 2: closure pointer
    mov rcx, 001h                                                ; internal argument 1: number of actual arguments
    mov qword ptr [rsp + 070h], r10                              ; move arguments[index] type out of r10
    call func$_stringByteLength                                  ; jump to subroutine
    add rsp, 040h                                                ; release shadow space and arguments (result in stack pointer)
    mov r12, qword ptr [rsp + 040h]                              ; value initialization of variable declaration for segmentLength variable (_stringByteLength return value)
    mov r13, qword ptr [rsp + 038h]                              ; type initialization of variable declaration for segmentLength variable
    ; Line 153: if (segmentLength > 0) { ...
    cmp r13, 000h                                                ; compare type of segmentLength variable to <sentinel>
    jne func$concat$while$segmentlength$TypeMatch                ; skip next block if segmentLength variable is not sentinel
      ; Error handling block for segmentLength
      ;  - print(operandTypeCheckFailureMessage)
      ; Call __print with 1 arguments
      mov r14, offset operandTypeCheckFailureMessage             ; reading operandTypeCheckFailureMessage for push
      push r14                                                   ; value of argument #1 (operandTypeCheckFailureMessage)
      push 01ah                                                  ; type of argument #1 (String'26)
      mov qword ptr [rsp + 048h], r15                            ; move arguments[index] value out of r15
      lea r15, qword ptr [rsp + 050h]                            ; load address of return value's value
      push r15                                                   ; internal argument 6: pointer to return value slot's value
      lea r15, qword ptr [rsp + 040h]                            ; load address of return value's type
      push r15                                                   ; internal argument 5: pointer to return value slot's type
      sub rsp, 020h                                              ; allocate shadow space
      mov r9, 000h                                               ; internal argument 4: "this" pointer
      mov r8, 000h                                               ; internal argument 3: "this" pointer type
      mov rdx, 000h                                              ; internal argument 2: closure pointer
      mov rcx, 001h                                              ; internal argument 1: number of actual arguments
      call func$__print                                          ; jump to subroutine
      add rsp, 040h                                              ; release shadow space and arguments (result in stack pointer)
      ;  - exit(1)
      ; Call exit with 1 arguments
      push 001h                                                  ; value of argument #1 (1 (integer))
      push 019h                                                  ; type of argument #1 (Integer'25)
      lea r10, qword ptr [rsp + 050h]                            ; load address of return value's value
      push r10                                                   ; internal argument 6: pointer to return value slot's value
      lea r10, qword ptr [rsp + 040h]                            ; load address of return value's type
      push r10                                                   ; internal argument 5: pointer to return value slot's type
      sub rsp, 020h                                              ; allocate shadow space
      mov r9, 000h                                               ; internal argument 4: "this" pointer
      mov r8, 000h                                               ; internal argument 3: "this" pointer type
      mov rdx, 000h                                              ; internal argument 2: closure pointer
      mov rcx, 001h                                              ; internal argument 1: number of actual arguments
      call func$exit                                             ; jump to subroutine
      add rsp, 040h                                              ; release shadow space and arguments (result in stack pointer)
      mov r15, qword ptr [rsp + 038h]                            ; restoring slots to previous scope state
    func$concat$while$segmentlength$TypeMatch:                   ; after block
    xor rax, rax                                                 ; clear > operator result
    cmp r12, 000h                                                ; compare segmentLength variable with 0
    setg al                                                      ; store result in > operator result
    mov qword ptr [rsp + 040h], r12                              ; move segmentLength variable value out of r12
    mov r12, 018h                                                ; > operator result is of type Boolean'24
    cmp rax, 000h                                                ; compare > operator result to false
    je func$concat$while$if$continuation                         ; segmentLength > 0
      ; Line 154: Integer segmentPointer = segment __as__ Integer;
      mov qword ptr [rsp + 038h], r13                            ; move segmentLength variable type out of r13
      mov r13, rsi                                               ; force cast of segment variable to Integer
      mov r14, 019h                                              ; force cast of segment variable to Integer is of type Integer'25
      mov qword ptr [rsp + 028h], r15                            ; move arguments[index] value out of r15
      mov r15, r13                                               ; value initialization of variable declaration for segmentPointer variable (force cast of segment variable to Integer)
      mov r10, r14                                               ; type initialization of variable declaration for segmentPointer variable
      ; Line 155: _moveBytes(segmentPointer + 16 /* 0x10 */, cursor, segmentLength...
      cmp r10, 000h                                              ; compare type of segmentPointer variable to <sentinel>
      jne func$concat$while$while$if$segmentpointer$TypeMatch    ; skip next block if segmentPointer variable is not sentinel
        ; Error handling block for segmentPointer
        ;  - print(operandTypeCheckFailureMessage)
        ; Call __print with 1 arguments
        mov rbx, offset operandTypeCheckFailureMessage           ; reading operandTypeCheckFailureMessage for push
        push rbx                                                 ; value of argument #1 (operandTypeCheckFailureMessage)
        push 01ah                                                ; type of argument #1 (String'26)
        mov qword ptr [rsp + 028h], rsi                          ; move segment variable value out of rsi
        lea rsi, qword ptr [rsp + 030h]                          ; load address of return value's value
        push rsi                                                 ; internal argument 6: pointer to return value slot's value
        lea rsi, qword ptr [rsp + 028h]                          ; load address of return value's type
        push rsi                                                 ; internal argument 5: pointer to return value slot's type
        sub rsp, 020h                                            ; allocate shadow space
        mov r9, 000h                                             ; internal argument 4: "this" pointer
        mov r8, 000h                                             ; internal argument 3: "this" pointer type
        mov rdx, 000h                                            ; internal argument 2: closure pointer
        mov rcx, 001h                                            ; internal argument 1: number of actual arguments
        mov qword ptr [rsp + 048h], r10                          ; move segmentPointer variable type out of r10
        call func$__print                                        ; jump to subroutine
        add rsp, 040h                                            ; release shadow space and arguments (result in stack pointer)
        ;  - exit(1)
        ; Call exit with 1 arguments
        push 001h                                                ; value of argument #1 (1 (integer))
        push 019h                                                ; type of argument #1 (Integer'25)
        mov qword ptr [rsp + 020h], rdi                          ; move segment variable type out of rdi
        lea rdi, qword ptr [rsp + 030h]                          ; load address of return value's value
        push rdi                                                 ; internal argument 6: pointer to return value slot's value
        lea rdi, qword ptr [rsp + 018h]                          ; load address of return value's type
        push rdi                                                 ; internal argument 5: pointer to return value slot's type
        sub rsp, 020h                                            ; allocate shadow space
        mov r9, 000h                                             ; internal argument 4: "this" pointer
        mov r8, 000h                                             ; internal argument 3: "this" pointer type
        mov rdx, 000h                                            ; internal argument 2: closure pointer
        mov rcx, 001h                                            ; internal argument 1: number of actual arguments
        call func$exit                                           ; jump to subroutine
        add rsp, 040h                                            ; release shadow space and arguments (result in stack pointer)
        mov r10, qword ptr [rsp + 008h]                          ; restoring slots to previous scope state
        mov rsi, qword ptr [rsp + 018h]                          ; restoring slots to previous scope state
        mov rdi, qword ptr [rsp + 010h]                          ; restoring slots to previous scope state
      func$concat$while$while$if$segmentpointer$TypeMatch:       ; after block
      mov r14, r15                                               ; assign value of segmentPointer variable to value of + operator result
      add r14, 010h                                              ; compute (segmentPointer variable) + (16 /* 0x10 */) (result in + operator result)
      mov r15, 019h                                              ; + operator result is of type Integer'25
      ; Call _moveBytes with 3 arguments
      push qword ptr [rsp + 040h]                                ; value of argument #3 (segmentLength variable)
      push qword ptr [rsp + 040h]                                ; type of argument #3
      push qword ptr [rsp + 068h]                                ; value of argument #2 (cursor variable)
      push qword ptr [rsp + 068h]                                ; type of argument #2
      push r14                                                   ; value of argument #1 (+ operator result)
      push r15                                                   ; type of argument #1
      lea r10, qword ptr [rsp + 050h]                            ; load address of return value's value
      push r10                                                   ; internal argument 6: pointer to return value slot's value
      lea r10, qword ptr [rsp + 050h]                            ; load address of return value's type
      push r10                                                   ; internal argument 5: pointer to return value slot's type
      sub rsp, 020h                                              ; allocate shadow space
      mov r9, 000h                                               ; internal argument 4: "this" pointer
      mov r8, 000h                                               ; internal argument 3: "this" pointer type
      mov rdx, 000h                                              ; internal argument 2: closure pointer
      mov rcx, 003h                                              ; internal argument 1: number of actual arguments
      call func$_moveBytes                                       ; jump to subroutine
      add rsp, 060h                                              ; release shadow space and arguments (result in stack pointer)
      ; Line 156: cursor += segmentLength;
      cmp qword ptr [rsp + 050h], 000h                           ; compare type of cursor variable to <sentinel>
      jne func$concat$while$while$if$cursorVariable$TypeMatch    ; skip next block if cursor variable is not sentinel
        ; Error handling block for cursor variable
        ;  - print(operandTypeCheckFailureMessage)
        ; Call __print with 1 arguments
        mov rbx, offset operandTypeCheckFailureMessage           ; reading operandTypeCheckFailureMessage for push
        push rbx                                                 ; value of argument #1 (operandTypeCheckFailureMessage)
        push 01ah                                                ; type of argument #1 (String'26)
        mov qword ptr [rsp + 028h], rsi                          ; move segment variable value out of rsi
        lea rsi, qword ptr [rsp + 030h]                          ; load address of return value's value
        push rsi                                                 ; internal argument 6: pointer to return value slot's value
        lea rsi, qword ptr [rsp + 028h]                          ; load address of return value's type
        push rsi                                                 ; internal argument 5: pointer to return value slot's type
        sub rsp, 020h                                            ; allocate shadow space
        mov r9, 000h                                             ; internal argument 4: "this" pointer
        mov r8, 000h                                             ; internal argument 3: "this" pointer type
        mov rdx, 000h                                            ; internal argument 2: closure pointer
        mov rcx, 001h                                            ; internal argument 1: number of actual arguments
        call func$__print                                        ; jump to subroutine
        add rsp, 040h                                            ; release shadow space and arguments (result in stack pointer)
        ;  - exit(1)
        ; Call exit with 1 arguments
        push 001h                                                ; value of argument #1 (1 (integer))
        push 019h                                                ; type of argument #1 (Integer'25)
        mov qword ptr [rsp + 020h], rdi                          ; move segment variable type out of rdi
        lea rdi, qword ptr [rsp + 030h]                          ; load address of return value's value
        push rdi                                                 ; internal argument 6: pointer to return value slot's value
        lea rdi, qword ptr [rsp + 020h]                          ; load address of return value's type
        push rdi                                                 ; internal argument 5: pointer to return value slot's type
        sub rsp, 020h                                            ; allocate shadow space
        mov r9, 000h                                             ; internal argument 4: "this" pointer
        mov r8, 000h                                             ; internal argument 3: "this" pointer type
        mov rdx, 000h                                            ; internal argument 2: closure pointer
        mov rcx, 001h                                            ; internal argument 1: number of actual arguments
        call func$exit                                           ; jump to subroutine
        add rsp, 040h                                            ; release shadow space and arguments (result in stack pointer)
        mov rsi, qword ptr [rsp + 018h]                          ; restoring slots to previous scope state
        mov rdi, qword ptr [rsp + 010h]                          ; restoring slots to previous scope state
      func$concat$while$while$if$cursorVariable$TypeMatch:       ; after block
      cmp qword ptr [rsp + 038h], 000h                           ; compare type of segmentLength variable to <sentinel>
      jne func$concat$while$while$if$segmentlengthVariable$TypeMatch ; skip next block if segmentLength variable is not sentinel
        ; Error handling block for segmentLength variable
        ;  - print(operandTypeCheckFailureMessage)
        ; Call __print with 1 arguments
        mov rax, offset operandTypeCheckFailureMessage           ; reading operandTypeCheckFailureMessage for push
        push rax                                                 ; value of argument #1 (operandTypeCheckFailureMessage)
        push 01ah                                                ; type of argument #1 (String'26)
        lea r12, qword ptr [rsp + 030h]                          ; load address of return value's value
        push r12                                                 ; internal argument 6: pointer to return value slot's value
        lea r12, qword ptr [rsp + 030h]                          ; load address of return value's type
        push r12                                                 ; internal argument 5: pointer to return value slot's type
        sub rsp, 020h                                            ; allocate shadow space
        mov r9, 000h                                             ; internal argument 4: "this" pointer
        mov r8, 000h                                             ; internal argument 3: "this" pointer type
        mov rdx, 000h                                            ; internal argument 2: closure pointer
        mov rcx, 001h                                            ; internal argument 1: number of actual arguments
        call func$__print                                        ; jump to subroutine
        add rsp, 040h                                            ; release shadow space and arguments (result in stack pointer)
        ;  - exit(1)
        ; Call exit with 1 arguments
        push 001h                                                ; value of argument #1 (1 (integer))
        push 019h                                                ; type of argument #1 (Integer'25)
        lea r13, qword ptr [rsp + 030h]                          ; load address of return value's value
        push r13                                                 ; internal argument 6: pointer to return value slot's value
        lea r13, qword ptr [rsp + 030h]                          ; load address of return value's type
        push r13                                                 ; internal argument 5: pointer to return value slot's type
        sub rsp, 020h                                            ; allocate shadow space
        mov r9, 000h                                             ; internal argument 4: "this" pointer
        mov r8, 000h                                             ; internal argument 3: "this" pointer type
        mov rdx, 000h                                            ; internal argument 2: closure pointer
        mov rcx, 001h                                            ; internal argument 1: number of actual arguments
        call func$exit                                           ; jump to subroutine
        add rsp, 040h                                            ; release shadow space and arguments (result in stack pointer)
      func$concat$while$while$if$segmentlengthVariable$TypeMatch:  ; after block
      mov r14, qword ptr [rsp + 058h]                            ; assign value of cursor variable to value of += operator result
      add r14, qword ptr [rsp + 040h]                            ; += operator
      mov r15, 019h                                              ; += operator result is of type Integer'25
      mov qword ptr [rsp + 058h], r14                            ; store value
      mov qword ptr [rsp + 050h], r15                            ; store type
      mov r15, qword ptr [rsp + 028h]                            ; restoring slots to previous scope state
      mov r13, qword ptr [rsp + 038h]                            ; restoring slots to previous scope state
    func$concat$while$if$continuation:                           ; end of if
    ; Line 158: index += 1;
    cmp qword ptr [rsp + 070h], 000h                             ; compare type of index variable to <sentinel>
    jne func$concat$while$indexVariable$TypeMatch$1              ; skip next block if index variable is not sentinel
      ; Error handling block for index variable
      ;  - print(operandTypeCheckFailureMessage)
      ; Call __print with 1 arguments
      mov r10, offset operandTypeCheckFailureMessage             ; reading operandTypeCheckFailureMessage for push
      push r10                                                   ; value of argument #1 (operandTypeCheckFailureMessage)
      push 01ah                                                  ; type of argument #1 (String'26)
      lea rbx, qword ptr [rsp + 050h]                            ; load address of return value's value
      push rbx                                                   ; internal argument 6: pointer to return value slot's value
      lea rbx, qword ptr [rsp + 050h]                            ; load address of return value's type
      push rbx                                                   ; internal argument 5: pointer to return value slot's type
      sub rsp, 020h                                              ; allocate shadow space
      mov r9, 000h                                               ; internal argument 4: "this" pointer
      mov r8, 000h                                               ; internal argument 3: "this" pointer type
      mov rdx, 000h                                              ; internal argument 2: closure pointer
      mov rcx, 001h                                              ; internal argument 1: number of actual arguments
      call func$__print                                          ; jump to subroutine
      add rsp, 040h                                              ; release shadow space and arguments (result in stack pointer)
      ;  - exit(1)
      ; Call exit with 1 arguments
      push 001h                                                  ; value of argument #1 (1 (integer))
      push 019h                                                  ; type of argument #1 (Integer'25)
      mov qword ptr [rsp + 048h], rsi                            ; move segment variable value out of rsi
      lea rsi, qword ptr [rsp + 050h]                            ; load address of return value's value
      push rsi                                                   ; internal argument 6: pointer to return value slot's value
      lea rsi, qword ptr [rsp + 040h]                            ; load address of return value's type
      push rsi                                                   ; internal argument 5: pointer to return value slot's type
      sub rsp, 020h                                              ; allocate shadow space
      mov r9, 000h                                               ; internal argument 4: "this" pointer
      mov r8, 000h                                               ; internal argument 3: "this" pointer type
      mov rdx, 000h                                              ; internal argument 2: closure pointer
      mov rcx, 001h                                              ; internal argument 1: number of actual arguments
      call func$exit                                             ; jump to subroutine
      add rsp, 040h                                              ; release shadow space and arguments (result in stack pointer)
      mov rsi, qword ptr [rsp + 038h]                            ; restoring slots to previous scope state
    func$concat$while$indexVariable$TypeMatch$1:                 ; after block
    mov r13, qword ptr [rsp + 078h]                              ; assign value of index variable to value of += operator result
    add r13, 001h                                                ; += operator
    mov r14, 019h                                                ; += operator result is of type Integer'25
    mov qword ptr [rsp + 078h], r13                              ; store value
    mov qword ptr [rsp + 070h], r14                              ; store type
    ; Calling decref on segment variable (static type: String'26)
    sub rsp, 20h                                                 ; allocate shadow space for decref
    mov rdx, rdi                                                 ; arg #2: type of potential string
    mov rcx, rsi                                                 ; arg #1: value of potential string
    call intrinsic$decref                                        ; call decref
    add rsp, 20h                                                 ; free shadow space for decref
    ; Calling decref on arguments[index] (static type: String'26)
    sub rsp, 20h                                                 ; allocate shadow space for decref
    mov rdx, qword ptr [rsp + 050h]                              ; arg #2: type of potential string
    mov rcx, r15                                                 ; arg #1: value of potential string
    call intrinsic$decref                                        ; call decref
    add rsp, 20h                                                 ; free shadow space for decref
    mov r14, qword ptr [rsp + 050h]                              ; restoring slots to previous scope state
    mov r13, qword ptr [rsp + 058h]                              ; restoring slots to previous scope state
    mov r11, qword ptr [rsp + 048h]                              ; indirect through r11 because operand pair (stack operand #5, stack operand #7) is not allowed with mov
    mov qword ptr [rsp + 058h], r11                              ; restoring slots to previous scope state
    jmp func$concat$while$top$1                                  ; return to top of while
  func$concat$while$bottom$1:                                    ; bottom of while
  ; Line 160: return resultPointer __as__ String;
  mov r15, qword ptr [rsp + 068h]                                ; force cast of resultPointer variable to String
  mov r10, 01ah                                                  ; force cast of resultPointer variable to String is of type String'26
  cmp r10, 000h                                                  ; compare type of force cast of resultPointer variable to String to <sentinel>
  jne func$concat$concatReturnValue$TypeMatch                    ; skip next block if force cast of resultPointer variable to String is not sentinel
    ; Error handling block for concat return value
    ;  - print(returnValueTypeCheckFailureMessage)
    ; Call __print with 1 arguments
    mov rbx, offset returnValueTypeCheckFailureMessage           ; reading returnValueTypeCheckFailureMessage for push
    push rbx                                                     ; value of argument #1 (returnValueTypeCheckFailureMessage)
    push 01ah                                                    ; type of argument #1 (String'26)
    lea rsi, qword ptr [rsp + 088h]                              ; load address of return value's value
    push rsi                                                     ; internal argument 6: pointer to return value slot's value
    lea rsi, qword ptr [rsp + 088h]                              ; load address of return value's type
    push rsi                                                     ; internal argument 5: pointer to return value slot's type
    sub rsp, 020h                                                ; allocate shadow space
    mov r9, 000h                                                 ; internal argument 4: "this" pointer
    mov r8, 000h                                                 ; internal argument 3: "this" pointer type
    mov rdx, 000h                                                ; internal argument 2: closure pointer
    mov rcx, 001h                                                ; internal argument 1: number of actual arguments
    mov qword ptr [rsp + 0a8h], r10                              ; move force cast of resultPointer variable to String type out of r10
    call func$__print                                            ; jump to subroutine
    add rsp, 040h                                                ; release shadow space and arguments (result in stack pointer)
    ;  - exit(1)
    ; Call exit with 1 arguments
    push 001h                                                    ; value of argument #1 (1 (integer))
    push 019h                                                    ; type of argument #1 (Integer'25)
    lea rdi, qword ptr [rsp + 088h]                              ; load address of return value's value
    push rdi                                                     ; internal argument 6: pointer to return value slot's value
    lea rdi, qword ptr [rsp + 088h]                              ; load address of return value's type
    push rdi                                                     ; internal argument 5: pointer to return value slot's type
    sub rsp, 020h                                                ; allocate shadow space
    mov r9, 000h                                                 ; internal argument 4: "this" pointer
    mov r8, 000h                                                 ; internal argument 3: "this" pointer type
    mov rdx, 000h                                                ; internal argument 2: closure pointer
    mov rcx, 001h                                                ; internal argument 1: number of actual arguments
    call func$exit                                               ; jump to subroutine
    add rsp, 040h                                                ; release shadow space and arguments (result in stack pointer)
    mov r10, qword ptr [rsp + 068h]                              ; restoring slots to previous scope state
  func$concat$concatReturnValue$TypeMatch:                       ; after block
  mov rax, qword ptr [rbp + 030h]                                ; get pointer to return value of concat into register to dereference it
  mov qword ptr [rax], r15                                       ; concat return value
  mov r12, qword ptr [rbp + 028h]                                ; get pointer to return value type of concat into register to dereference it
  mov qword ptr [r12], r10                                       ; type of concat return value
  ; increment reference count for force cast of resultPointer variable to String if necessary
  cmp r10, 01ah                                                  ; compare type of force cast of resultPointer variable to String to String
  jne func$concat$AfterIncref                                    ; if not a string, skip incref
  mov r13, qword ptr [r15]                                       ; dereference string to get to ref count
  cmp r13, 0                                                     ; compare string refcount temporary to 0
  js func$concat$AfterIncref                                     ; if ref count is negative (constant strings), skip incref
  add r13, 001h                                                  ; increment ref count (result in string refcount temporary)
  mov qword ptr [r15], r13                                       ; put it back in the string
  func$concat$AfterIncref:                                       ; after incref
  ; Calling decref on force cast of resultPointer variable to String (static type: String'26)
  sub rsp, 20h                                                   ; allocate shadow space for decref
  mov rdx, r10                                                   ; arg #2: type of potential string
  mov rcx, r15                                                   ; arg #1: value of potential string
  mov r14, rdx                                                   ; save type of potential string
  call intrinsic$decref                                          ; call decref
  add rsp, 20h                                                   ; free shadow space for decref
  mov rax, qword ptr [rbp + 030h]                                ; report address of return value
  ; Epilog
  add rsp, 088h                                                  ; free space for stack
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
dq func$digitToStr$annotation
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
    push 01ah                                                    ; type of argument #1 (String'26)
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
    push 019h                                                    ; type of argument #1 (Integer'25)
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
  mov rdi, 002h                                                  ; read operand of mul (type table width in bytes) 
  mul rdi                                                        ; adjust to the relative start of that type's entry in the type table
  mov r12, offset typeTable                                      ; read second operand of + (type table pointer)
  add rax, r12                                                   ; finally offset all of that by the start of the type table itself (result in testByte)
  bt qword ptr [rax], 002h                                       ; check that digit is Integer
  jc func$digitToStr$digit$TypeMatch                             ; skip next block if the type matches
    ; Error handling block for digit
    ;  - print(parameterTypeCheckFailureMessage)
    ; Call __print with 1 arguments
    mov r13, offset parameterTypeCheckFailureMessage             ; reading parameterTypeCheckFailureMessage for push
    push r13                                                     ; value of argument #1 (parameterTypeCheckFailureMessage)
    push 01ah                                                    ; type of argument #1 (String'26)
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
    push 019h                                                    ; type of argument #1 (Integer'25)
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
  ; Line 170: if (digit == 0) { ...
  xor r10, r10                                                   ; zero value result of == (testing digit and 0) to put the boolean in
  cmp qword ptr [rbp + 040h], 000h                               ; values equal?
  sete r10b                                                      ; put result in value result of == (testing digit and 0)
  mov rbx, 018h                                                  ; value result of == (testing digit and 0) is a Boolean'24
  xor rsi, rsi                                                   ; zero type result of == (testing digit and 0) to put the boolean in
  cmp qword ptr [rbp + 038h], 019h                               ; types equal?
  sete sil                                                       ; put result in type result of == (testing digit and 0)
  mov rax, 018h                                                  ; type result of == (testing digit and 0) is a Boolean'24
  mov rdi, r10                                                   ; assign value of value result of == (testing digit and 0) to value of == operator result
  and rdi, rsi                                                   ; && type temp and value temp
  mov r12, 018h                                                  ; == operator result is of type Boolean'24
  cmp rdi, 000h                                                  ; compare == operator result to false
  je func$digitToStr$if$continuation                             ; digit == 0
    ; Line 171: return '0';
    mov r10, offset string$13                                    ; read second operand of mov (string) for MoveToDerefInstruction
    mov rbx, qword ptr [rbp + 030h]                              ; get pointer to return value of digitToStr into register to dereference it
    mov qword ptr [rbx], r10                                     ; digitToStr return value
    mov rsi, qword ptr [rbp + 028h]                              ; get pointer to return value type of digitToStr into register to dereference it
    mov qword ptr [rsi], 01ah                                    ; type of digitToStr return value (String'26)
    jmp func$digitToStr$epilog                                   ; return
  func$digitToStr$if$continuation:                               ; end of if
  ; Line 173: if (digit == 1) { ...
  xor rax, rax                                                   ; zero value result of == (testing digit and 1) to put the boolean in
  cmp qword ptr [rbp + 040h], 001h                               ; values equal?
  sete al                                                        ; put result in value result of == (testing digit and 1)
  mov rdi, 018h                                                  ; value result of == (testing digit and 1) is a Boolean'24
  xor r12, r12                                                   ; zero type result of == (testing digit and 1) to put the boolean in
  cmp qword ptr [rbp + 038h], 019h                               ; types equal?
  sete r12b                                                      ; put result in type result of == (testing digit and 1)
  mov r13, 018h                                                  ; type result of == (testing digit and 1) is a Boolean'24
  mov r14, rax                                                   ; assign value of value result of == (testing digit and 1) to value of == operator result
  and r14, r12                                                   ; && type temp and value temp
  mov r15, 018h                                                  ; == operator result is of type Boolean'24
  cmp r14, 000h                                                  ; compare == operator result to false
  je func$digitToStr$if$continuation$1                           ; digit == 1
    ; Line 174: return '1';
    mov rbx, offset string$14                                    ; read second operand of mov (string) for MoveToDerefInstruction
    mov rsi, qword ptr [rbp + 030h]                              ; get pointer to return value of digitToStr into register to dereference it
    mov qword ptr [rsi], rbx                                     ; digitToStr return value
    mov rax, qword ptr [rbp + 028h]                              ; get pointer to return value type of digitToStr into register to dereference it
    mov qword ptr [rax], 01ah                                    ; type of digitToStr return value (String'26)
    jmp func$digitToStr$epilog                                   ; return
  func$digitToStr$if$continuation$1:                             ; end of if
  ; Line 176: if (digit == 2) { ...
  xor rdi, rdi                                                   ; zero value result of == (testing digit and 2) to put the boolean in
  cmp qword ptr [rbp + 040h], 002h                               ; values equal?
  sete dil                                                       ; put result in value result of == (testing digit and 2)
  mov r12, 018h                                                  ; value result of == (testing digit and 2) is a Boolean'24
  xor r13, r13                                                   ; zero type result of == (testing digit and 2) to put the boolean in
  cmp qword ptr [rbp + 038h], 019h                               ; types equal?
  sete r13b                                                      ; put result in type result of == (testing digit and 2)
  mov r14, 018h                                                  ; type result of == (testing digit and 2) is a Boolean'24
  mov r15, rdi                                                   ; assign value of value result of == (testing digit and 2) to value of == operator result
  and r15, r13                                                   ; && type temp and value temp
  mov r10, 018h                                                  ; == operator result is of type Boolean'24
  cmp r15, 000h                                                  ; compare == operator result to false
  je func$digitToStr$if$continuation$2                           ; digit == 2
    ; Line 177: return '2';
    mov rsi, offset string$15                                    ; read second operand of mov (string) for MoveToDerefInstruction
    mov rax, qword ptr [rbp + 030h]                              ; get pointer to return value of digitToStr into register to dereference it
    mov qword ptr [rax], rsi                                     ; digitToStr return value
    mov rdi, qword ptr [rbp + 028h]                              ; get pointer to return value type of digitToStr into register to dereference it
    mov qword ptr [rdi], 01ah                                    ; type of digitToStr return value (String'26)
    jmp func$digitToStr$epilog                                   ; return
  func$digitToStr$if$continuation$2:                             ; end of if
  ; Line 179: if (digit == 3) { ...
  xor r12, r12                                                   ; zero value result of == (testing digit and 3) to put the boolean in
  cmp qword ptr [rbp + 040h], 003h                               ; values equal?
  sete r12b                                                      ; put result in value result of == (testing digit and 3)
  mov r13, 018h                                                  ; value result of == (testing digit and 3) is a Boolean'24
  xor r14, r14                                                   ; zero type result of == (testing digit and 3) to put the boolean in
  cmp qword ptr [rbp + 038h], 019h                               ; types equal?
  sete r14b                                                      ; put result in type result of == (testing digit and 3)
  mov r15, 018h                                                  ; type result of == (testing digit and 3) is a Boolean'24
  mov r10, r12                                                   ; assign value of value result of == (testing digit and 3) to value of == operator result
  and r10, r14                                                   ; && type temp and value temp
  mov rbx, 018h                                                  ; == operator result is of type Boolean'24
  cmp r10, 000h                                                  ; compare == operator result to false
  je func$digitToStr$if$continuation$3                           ; digit == 3
    ; Line 180: return '3';
    mov rax, offset string$16                                    ; read second operand of mov (string) for MoveToDerefInstruction
    mov rdi, qword ptr [rbp + 030h]                              ; get pointer to return value of digitToStr into register to dereference it
    mov qword ptr [rdi], rax                                     ; digitToStr return value
    mov r12, qword ptr [rbp + 028h]                              ; get pointer to return value type of digitToStr into register to dereference it
    mov qword ptr [r12], 01ah                                    ; type of digitToStr return value (String'26)
    jmp func$digitToStr$epilog                                   ; return
  func$digitToStr$if$continuation$3:                             ; end of if
  ; Line 182: if (digit == 4) { ...
  xor r13, r13                                                   ; zero value result of == (testing digit and 4) to put the boolean in
  cmp qword ptr [rbp + 040h], 004h                               ; values equal?
  sete r13b                                                      ; put result in value result of == (testing digit and 4)
  mov r14, 018h                                                  ; value result of == (testing digit and 4) is a Boolean'24
  xor r15, r15                                                   ; zero type result of == (testing digit and 4) to put the boolean in
  cmp qword ptr [rbp + 038h], 019h                               ; types equal?
  sete r15b                                                      ; put result in type result of == (testing digit and 4)
  mov r10, 018h                                                  ; type result of == (testing digit and 4) is a Boolean'24
  mov rbx, r13                                                   ; assign value of value result of == (testing digit and 4) to value of == operator result
  and rbx, r15                                                   ; && type temp and value temp
  mov rsi, 018h                                                  ; == operator result is of type Boolean'24
  cmp rbx, 000h                                                  ; compare == operator result to false
  je func$digitToStr$if$continuation$4                           ; digit == 4
    ; Line 183: return '4';
    mov rdi, offset string$17                                    ; read second operand of mov (string) for MoveToDerefInstruction
    mov r12, qword ptr [rbp + 030h]                              ; get pointer to return value of digitToStr into register to dereference it
    mov qword ptr [r12], rdi                                     ; digitToStr return value
    mov r13, qword ptr [rbp + 028h]                              ; get pointer to return value type of digitToStr into register to dereference it
    mov qword ptr [r13], 01ah                                    ; type of digitToStr return value (String'26)
    jmp func$digitToStr$epilog                                   ; return
  func$digitToStr$if$continuation$4:                             ; end of if
  ; Line 185: if (digit == 5) { ...
  xor r14, r14                                                   ; zero value result of == (testing digit and 5) to put the boolean in
  cmp qword ptr [rbp + 040h], 005h                               ; values equal?
  sete r14b                                                      ; put result in value result of == (testing digit and 5)
  mov r15, 018h                                                  ; value result of == (testing digit and 5) is a Boolean'24
  xor r10, r10                                                   ; zero type result of == (testing digit and 5) to put the boolean in
  cmp qword ptr [rbp + 038h], 019h                               ; types equal?
  sete r10b                                                      ; put result in type result of == (testing digit and 5)
  mov rbx, 018h                                                  ; type result of == (testing digit and 5) is a Boolean'24
  mov rsi, r14                                                   ; assign value of value result of == (testing digit and 5) to value of == operator result
  and rsi, r10                                                   ; && type temp and value temp
  mov rax, 018h                                                  ; == operator result is of type Boolean'24
  cmp rsi, 000h                                                  ; compare == operator result to false
  je func$digitToStr$if$continuation$5                           ; digit == 5
    ; Line 186: return '5';
    mov r12, offset string$18                                    ; read second operand of mov (string) for MoveToDerefInstruction
    mov r13, qword ptr [rbp + 030h]                              ; get pointer to return value of digitToStr into register to dereference it
    mov qword ptr [r13], r12                                     ; digitToStr return value
    mov r14, qword ptr [rbp + 028h]                              ; get pointer to return value type of digitToStr into register to dereference it
    mov qword ptr [r14], 01ah                                    ; type of digitToStr return value (String'26)
    jmp func$digitToStr$epilog                                   ; return
  func$digitToStr$if$continuation$5:                             ; end of if
  ; Line 188: if (digit == 6) { ...
  xor r15, r15                                                   ; zero value result of == (testing digit and 6) to put the boolean in
  cmp qword ptr [rbp + 040h], 006h                               ; values equal?
  sete r15b                                                      ; put result in value result of == (testing digit and 6)
  mov r10, 018h                                                  ; value result of == (testing digit and 6) is a Boolean'24
  xor rbx, rbx                                                   ; zero type result of == (testing digit and 6) to put the boolean in
  cmp qword ptr [rbp + 038h], 019h                               ; types equal?
  sete bl                                                        ; put result in type result of == (testing digit and 6)
  mov rsi, 018h                                                  ; type result of == (testing digit and 6) is a Boolean'24
  mov rax, r15                                                   ; assign value of value result of == (testing digit and 6) to value of == operator result
  and rax, rbx                                                   ; && type temp and value temp
  mov rdi, 018h                                                  ; == operator result is of type Boolean'24
  cmp rax, 000h                                                  ; compare == operator result to false
  je func$digitToStr$if$continuation$6                           ; digit == 6
    ; Line 189: return '6';
    mov r13, offset string$19                                    ; read second operand of mov (string) for MoveToDerefInstruction
    mov r14, qword ptr [rbp + 030h]                              ; get pointer to return value of digitToStr into register to dereference it
    mov qword ptr [r14], r13                                     ; digitToStr return value
    mov r15, qword ptr [rbp + 028h]                              ; get pointer to return value type of digitToStr into register to dereference it
    mov qword ptr [r15], 01ah                                    ; type of digitToStr return value (String'26)
    jmp func$digitToStr$epilog                                   ; return
  func$digitToStr$if$continuation$6:                             ; end of if
  ; Line 191: if (digit == 7) { ...
  xor r10, r10                                                   ; zero value result of == (testing digit and 7) to put the boolean in
  cmp qword ptr [rbp + 040h], 007h                               ; values equal?
  sete r10b                                                      ; put result in value result of == (testing digit and 7)
  mov rbx, 018h                                                  ; value result of == (testing digit and 7) is a Boolean'24
  xor rsi, rsi                                                   ; zero type result of == (testing digit and 7) to put the boolean in
  cmp qword ptr [rbp + 038h], 019h                               ; types equal?
  sete sil                                                       ; put result in type result of == (testing digit and 7)
  mov rax, 018h                                                  ; type result of == (testing digit and 7) is a Boolean'24
  mov rdi, r10                                                   ; assign value of value result of == (testing digit and 7) to value of == operator result
  and rdi, rsi                                                   ; && type temp and value temp
  mov r12, 018h                                                  ; == operator result is of type Boolean'24
  cmp rdi, 000h                                                  ; compare == operator result to false
  je func$digitToStr$if$continuation$7                           ; digit == 7
    ; Line 192: return '7';
    mov r14, offset string$20                                    ; read second operand of mov (string) for MoveToDerefInstruction
    mov r15, qword ptr [rbp + 030h]                              ; get pointer to return value of digitToStr into register to dereference it
    mov qword ptr [r15], r14                                     ; digitToStr return value
    mov r10, qword ptr [rbp + 028h]                              ; get pointer to return value type of digitToStr into register to dereference it
    mov qword ptr [r10], 01ah                                    ; type of digitToStr return value (String'26)
    jmp func$digitToStr$epilog                                   ; return
  func$digitToStr$if$continuation$7:                             ; end of if
  ; Line 194: if (digit == 8) { ...
  xor rbx, rbx                                                   ; zero value result of == (testing digit and 8) to put the boolean in
  cmp qword ptr [rbp + 040h], 008h                               ; values equal?
  sete bl                                                        ; put result in value result of == (testing digit and 8)
  mov rsi, 018h                                                  ; value result of == (testing digit and 8) is a Boolean'24
  xor rax, rax                                                   ; zero type result of == (testing digit and 8) to put the boolean in
  cmp qword ptr [rbp + 038h], 019h                               ; types equal?
  sete al                                                        ; put result in type result of == (testing digit and 8)
  mov rdi, 018h                                                  ; type result of == (testing digit and 8) is a Boolean'24
  mov r12, rbx                                                   ; assign value of value result of == (testing digit and 8) to value of == operator result
  and r12, rax                                                   ; && type temp and value temp
  mov r13, 018h                                                  ; == operator result is of type Boolean'24
  cmp r12, 000h                                                  ; compare == operator result to false
  je func$digitToStr$if$continuation$8                           ; digit == 8
    ; Line 195: return '8';
    mov r15, offset string$21                                    ; read second operand of mov (string) for MoveToDerefInstruction
    mov r10, qword ptr [rbp + 030h]                              ; get pointer to return value of digitToStr into register to dereference it
    mov qword ptr [r10], r15                                     ; digitToStr return value
    mov rbx, qword ptr [rbp + 028h]                              ; get pointer to return value type of digitToStr into register to dereference it
    mov qword ptr [rbx], 01ah                                    ; type of digitToStr return value (String'26)
    jmp func$digitToStr$epilog                                   ; return
  func$digitToStr$if$continuation$8:                             ; end of if
  ; Line 197: if (digit == 9) { ...
  xor rsi, rsi                                                   ; zero value result of == (testing digit and 9) to put the boolean in
  cmp qword ptr [rbp + 040h], 009h                               ; values equal?
  sete sil                                                       ; put result in value result of == (testing digit and 9)
  mov rax, 018h                                                  ; value result of == (testing digit and 9) is a Boolean'24
  xor rdi, rdi                                                   ; zero type result of == (testing digit and 9) to put the boolean in
  cmp qword ptr [rbp + 038h], 019h                               ; types equal?
  sete dil                                                       ; put result in type result of == (testing digit and 9)
  mov r12, 018h                                                  ; type result of == (testing digit and 9) is a Boolean'24
  mov r13, rsi                                                   ; assign value of value result of == (testing digit and 9) to value of == operator result
  and r13, rdi                                                   ; && type temp and value temp
  mov r14, 018h                                                  ; == operator result is of type Boolean'24
  cmp r13, 000h                                                  ; compare == operator result to false
  je func$digitToStr$if$continuation$9                           ; digit == 9
    ; Line 198: return '9';
    mov r10, offset string$22                                    ; read second operand of mov (string) for MoveToDerefInstruction
    mov rbx, qword ptr [rbp + 030h]                              ; get pointer to return value of digitToStr into register to dereference it
    mov qword ptr [rbx], r10                                     ; digitToStr return value
    mov rsi, qword ptr [rbp + 028h]                              ; get pointer to return value type of digitToStr into register to dereference it
    mov qword ptr [rsi], 01ah                                    ; type of digitToStr return value (String'26)
    jmp func$digitToStr$epilog                                   ; return
  func$digitToStr$if$continuation$9:                             ; end of if
  ; Line 200: __print('Invalid digit passed to digitToStr (digit as exit code)...
  ; Call __print with 1 arguments
  mov rax, offset string$23                                      ; reading string for push
  push rax                                                       ; value of argument #1 (string)
  push 01ah                                                      ; type of argument #1 (String'26)
  lea rdi, qword ptr [rsp + 020h]                                ; load address of return value's value
  push rdi                                                       ; internal argument 6: pointer to return value slot's value
  lea rdi, qword ptr [rsp + 020h]                                ; load address of return value's type
  push rdi                                                       ; internal argument 5: pointer to return value slot's type
  sub rsp, 020h                                                  ; allocate shadow space
  mov r9, 000h                                                   ; internal argument 4: "this" pointer
  mov r8, 000h                                                   ; internal argument 3: "this" pointer type
  mov rdx, 000h                                                  ; internal argument 2: closure pointer
  mov qword ptr [rsp + 040h], rcx                                ; move parameter count of digitToStr value out of rcx
  mov rcx, 001h                                                  ; internal argument 1: number of actual arguments
  call func$__print                                              ; jump to subroutine
  add rsp, 040h                                                  ; release shadow space and arguments (result in stack pointer)
  ; Line 201: exit(digit);
  ; Call exit with 1 arguments
  push qword ptr [rbp + 040h]                                    ; value of argument #1 (digit)
  push qword ptr [rbp + 038h]                                    ; type of argument #1
  lea r12, qword ptr [rsp + 020h]                                ; load address of return value's value
  push r12                                                       ; internal argument 6: pointer to return value slot's value
  lea r12, qword ptr [rsp + 020h]                                ; load address of return value's type
  push r12                                                       ; internal argument 5: pointer to return value slot's type
  sub rsp, 020h                                                  ; allocate shadow space
  mov r9, 000h                                                   ; internal argument 4: "this" pointer
  mov r8, 000h                                                   ; internal argument 3: "this" pointer type
  mov rdx, 000h                                                  ; internal argument 2: closure pointer
  mov rcx, 001h                                                  ; internal argument 1: number of actual arguments
  call func$exit                                                 ; jump to subroutine
  add rsp, 040h                                                  ; release shadow space and arguments (result in stack pointer)
  ; Implicit return from digitToStr
  mov r13, 017h                                                  ; move type of null to testByte
  mov rax, r13                                                   ; move testByte to testByte
  mov r14, 002h                                                  ; read operand of mul (type table width in bytes) 
  mul r14                                                        ; adjust to the relative start of that type's entry in the type table
  mov r15, offset typeTable                                      ; read second operand of + (type table pointer)
  add rax, r15                                                   ; finally offset all of that by the start of the type table itself (result in testByte)
  bt qword ptr [rax], 003h                                       ; check that digitToStr return value is String
  jc func$digitToStr$digittostrReturnValue$TypeMatch             ; skip next block if the type matches
    ; Error handling block for digitToStr return value
    ;  - print(returnValueTypeCheckFailureMessage)
    ; Call __print with 1 arguments
    mov r10, offset returnValueTypeCheckFailureMessage           ; reading returnValueTypeCheckFailureMessage for push
    push r10                                                     ; value of argument #1 (returnValueTypeCheckFailureMessage)
    push 01ah                                                    ; type of argument #1 (String'26)
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
    ;  - exit(1)
    ; Call exit with 1 arguments
    push 001h                                                    ; value of argument #1 (1 (integer))
    push 019h                                                    ; type of argument #1 (Integer'25)
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
  func$digitToStr$digittostrReturnValue$TypeMatch:               ; after block
  mov rdi, qword ptr [rbp + 030h]                                ; get pointer to return value of digitToStr into register to dereference it
  mov qword ptr [rdi], 000h                                      ; digitToStr return value
  mov r12, qword ptr [rbp + 028h]                                ; get pointer to return value type of digitToStr into register to dereference it
  mov qword ptr [r12], 017h                                      ; type of digitToStr return value (Null'23)
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
dq func$intToStr$annotation
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
    push 01ah                                                    ; type of argument #1 (String'26)
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
    push 019h                                                    ; type of argument #1 (Integer'25)
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
  mov rdi, 002h                                                  ; read operand of mul (type table width in bytes) 
  mul rdi                                                        ; adjust to the relative start of that type's entry in the type table
  mov r12, offset typeTable                                      ; read second operand of + (type table pointer)
  add rax, r12                                                   ; finally offset all of that by the start of the type table itself (result in testByte)
  bt qword ptr [rax], 002h                                       ; check that value is Integer
  jc func$intToStr$value$TypeMatch                               ; skip next block if the type matches
    ; Error handling block for value
    ;  - print(parameterTypeCheckFailureMessage)
    ; Call __print with 1 arguments
    mov r13, offset parameterTypeCheckFailureMessage             ; reading parameterTypeCheckFailureMessage for push
    push r13                                                     ; value of argument #1 (parameterTypeCheckFailureMessage)
    push 01ah                                                    ; type of argument #1 (String'26)
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
    push 019h                                                    ; type of argument #1 (Integer'25)
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
  ; Line 205: if (value == 0) { ...
  xor r10, r10                                                   ; zero value result of == (testing value and 0) to put the boolean in
  cmp qword ptr [rbp + 040h], 000h                               ; values equal?
  sete r10b                                                      ; put result in value result of == (testing value and 0)
  mov rbx, 018h                                                  ; value result of == (testing value and 0) is a Boolean'24
  xor rsi, rsi                                                   ; zero type result of == (testing value and 0) to put the boolean in
  cmp qword ptr [rbp + 038h], 019h                               ; types equal?
  sete sil                                                       ; put result in type result of == (testing value and 0)
  mov rax, 018h                                                  ; type result of == (testing value and 0) is a Boolean'24
  mov rdi, r10                                                   ; assign value of value result of == (testing value and 0) to value of == operator result
  and rdi, rsi                                                   ; && type temp and value temp
  mov r12, 018h                                                  ; == operator result is of type Boolean'24
  cmp rdi, 000h                                                  ; compare == operator result to false
  je func$intToStr$if$continuation                               ; value == 0
    ; Line 206: return '0';
    mov r10, offset string$13                                    ; read second operand of mov (string) for MoveToDerefInstruction
    mov rbx, qword ptr [rbp + 030h]                              ; get pointer to return value of intToStr into register to dereference it
    mov qword ptr [rbx], r10                                     ; intToStr return value
    mov rsi, qword ptr [rbp + 028h]                              ; get pointer to return value type of intToStr into register to dereference it
    mov qword ptr [rsi], 01ah                                    ; type of intToStr return value (String'26)
    jmp func$intToStr$epilog                                     ; return
  func$intToStr$if$continuation:                                 ; end of if
  ; Line 208: String buffer = '';
  mov rax, offset string$24                                      ; value initialization of variable declaration for buffer variable (string)
  mov rdi, 01ah                                                  ; type initialization of variable declaration for buffer variable (String'26)
  ; increment reference count for buffer variable if necessary
  cmp rdi, 01ah                                                  ; compare type of buffer variable to String
  jne func$intToStr$AfterIncref                                  ; if not a string, skip incref
  mov r12, qword ptr [rax]                                       ; dereference string to get to ref count
  cmp r12, 0                                                     ; compare string refcount temporary to 0
  js func$intToStr$AfterIncref                                   ; if ref count is negative (constant strings), skip incref
  add r12, 001h                                                  ; increment ref count (result in string refcount temporary)
  mov qword ptr [rax], r12                                       ; put it back in the string
  func$intToStr$AfterIncref:                                     ; after incref
  ; Line 209: Integer newValue = value;
  mov r13, qword ptr [rbp + 040h]                                ; value initialization of variable declaration for newValue variable (value)
  mov r14, qword ptr [rbp + 038h]                                ; type initialization of variable declaration for newValue variable
  func$intToStr$while$top:                                       ; top of while
    cmp r14, 000h                                                ; compare type of newValue variable to <sentinel>
    jne func$intToStr$while$newvalue$TypeMatch                   ; skip next block if newValue variable is not sentinel
      ; Error handling block for newValue
      ;  - print(operandTypeCheckFailureMessage)
      ; Call __print with 1 arguments
      mov r15, offset operandTypeCheckFailureMessage             ; reading operandTypeCheckFailureMessage for push
      push r15                                                   ; value of argument #1 (operandTypeCheckFailureMessage)
      push 01ah                                                  ; type of argument #1 (String'26)
      lea r9, qword ptr [rsp + 050h]                             ; load address of return value's value
      push r9                                                    ; internal argument 6: pointer to return value slot's value
      lea r9, qword ptr [rsp + 050h]                             ; load address of return value's type
      push r9                                                    ; internal argument 5: pointer to return value slot's type
      sub rsp, 020h                                              ; allocate shadow space
      mov r9, 000h                                               ; internal argument 4: "this" pointer
      mov r8, 000h                                               ; internal argument 3: "this" pointer type
      mov rdx, 000h                                              ; internal argument 2: closure pointer
      mov qword ptr [rsp + 070h], rcx                            ; move parameter count of intToStr value out of rcx
      mov rcx, 001h                                              ; internal argument 1: number of actual arguments
      mov qword ptr [rsp + 068h], rax                            ; move buffer variable value out of rax
      call func$__print                                          ; jump to subroutine
      add rsp, 040h                                              ; release shadow space and arguments (result in stack pointer)
      ;  - exit(1)
      ; Call exit with 1 arguments
      push 001h                                                  ; value of argument #1 (1 (integer))
      push 019h                                                  ; type of argument #1 (Integer'25)
      lea r10, qword ptr [rsp + 050h]                            ; load address of return value's value
      push r10                                                   ; internal argument 6: pointer to return value slot's value
      lea r10, qword ptr [rsp + 050h]                            ; load address of return value's type
      push r10                                                   ; internal argument 5: pointer to return value slot's type
      sub rsp, 020h                                              ; allocate shadow space
      mov r9, 000h                                               ; internal argument 4: "this" pointer
      mov r8, 000h                                               ; internal argument 3: "this" pointer type
      mov rdx, 000h                                              ; internal argument 2: closure pointer
      mov rcx, 001h                                              ; internal argument 1: number of actual arguments
      call func$exit                                             ; jump to subroutine
      add rsp, 040h                                              ; release shadow space and arguments (result in stack pointer)
      mov rax, qword ptr [rsp + 028h]                            ; restoring slots to previous scope state
      mov rcx, qword ptr [rsp + 030h]                            ; restoring slots to previous scope state
    func$intToStr$while$newvalue$TypeMatch:                      ; after block
    mov qword ptr [rsp + 040h], rdi                              ; move buffer variable type out of rdi
    xor rdi, rdi                                                 ; clear > operator result
    cmp r13, 000h                                                ; compare newValue variable with 0
    setg dil                                                     ; store result in > operator result
    mov r12, 018h                                                ; > operator result is of type Boolean'24
    cmp rdi, 000h                                                ; compare > operator result to false
    jne func$intToStr$while$body                                 ; while condition
    mov rdi, qword ptr [rsp + 040h]                              ; restoring slots to previous scope state
    jmp func$intToStr$while$bottom                               ; break out of while
    func$intToStr$while$body:                                    ; start of while
    ; Line 211: Integer digit = newValue % 10 /* 0xa */;
    cmp r14, 000h                                                ; compare type of newValue variable to <sentinel>
    jne func$intToStr$while$newvalue$TypeMatch$1                 ; skip next block if newValue variable is not sentinel
      ; Error handling block for newValue
      ;  - print(operandTypeCheckFailureMessage)
      ; Call __print with 1 arguments
      mov qword ptr [rsp + 038h], r13                            ; move newValue variable value out of r13
      mov r13, offset operandTypeCheckFailureMessage             ; reading operandTypeCheckFailureMessage for push
      push r13                                                   ; value of argument #1 (operandTypeCheckFailureMessage)
      push 01ah                                                  ; type of argument #1 (String'26)
      mov qword ptr [rsp + 038h], r14                            ; move newValue variable type out of r14
      lea r14, qword ptr [rsp + 040h]                            ; load address of return value's value
      push r14                                                   ; internal argument 6: pointer to return value slot's value
      lea r14, qword ptr [rsp + 038h]                            ; load address of return value's type
      push r14                                                   ; internal argument 5: pointer to return value slot's type
      sub rsp, 020h                                              ; allocate shadow space
      mov r9, 000h                                               ; internal argument 4: "this" pointer
      mov r8, 000h                                               ; internal argument 3: "this" pointer type
      mov rdx, 000h                                              ; internal argument 2: closure pointer
      mov qword ptr [rsp + 058h], rcx                            ; move parameter count of intToStr value out of rcx
      mov rcx, 001h                                              ; internal argument 1: number of actual arguments
      mov qword ptr [rsp + 050h], rax                            ; move buffer variable value out of rax
      call func$__print                                          ; jump to subroutine
      add rsp, 040h                                              ; release shadow space and arguments (result in stack pointer)
      ;  - exit(1)
      ; Call exit with 1 arguments
      push 001h                                                  ; value of argument #1 (1 (integer))
      push 019h                                                  ; type of argument #1 (Integer'25)
      lea r15, qword ptr [rsp + 040h]                            ; load address of return value's value
      push r15                                                   ; internal argument 6: pointer to return value slot's value
      lea r15, qword ptr [rsp + 038h]                            ; load address of return value's type
      push r15                                                   ; internal argument 5: pointer to return value slot's type
      sub rsp, 020h                                              ; allocate shadow space
      mov r9, 000h                                               ; internal argument 4: "this" pointer
      mov r8, 000h                                               ; internal argument 3: "this" pointer type
      mov rdx, 000h                                              ; internal argument 2: closure pointer
      mov rcx, 001h                                              ; internal argument 1: number of actual arguments
      call func$exit                                             ; jump to subroutine
      add rsp, 040h                                              ; release shadow space and arguments (result in stack pointer)
      mov rax, qword ptr [rsp + 010h]                            ; restoring slots to previous scope state
      mov r14, qword ptr [rsp + 028h]                            ; restoring slots to previous scope state
      mov rcx, qword ptr [rsp + 018h]                            ; restoring slots to previous scope state
      mov r13, qword ptr [rsp + 038h]                            ; restoring slots to previous scope state
    func$intToStr$while$newvalue$TypeMatch$1:                    ; after block
    mov qword ptr [rsp + 038h], rax                              ; move buffer variable value out of rax
    mov rax, r13                                                 ; put lhs of rdx division (<DynamicSlot:Integer'25 at [r13, r13]/[r14, r14] ("newValue variable") (living: true)>) in rax
    mov qword ptr [rsp + 030h], rax                              ; move newValue variable value out of rax
    cqo                                                          ; zero-extend dividend (rax into rdx:rax)
    mov rdi, 00ah                                                ; read visible operand of div (<ImmediateIntegerSlot:Integer'25 ("10 /* 0xa */")>) 
    idiv rdi                                                     ; compute (newValue variable) % (10 /* 0xa */) (result, % operator result, ends up in rdx)
    mov r12, 019h                                                ; % operator result is of type Integer'25
    mov r13, rdx                                                 ; value initialization of variable declaration for digit variable (% operator result)
    mov qword ptr [rsp + 028h], r14                              ; move newValue variable type out of r14
    mov r14, r12                                                 ; type initialization of variable declaration for digit variable
    ; Line 212: newValue = newValue / 10 /* 0xa */;
    cmp qword ptr [rsp + 028h], 000h                             ; compare type of newValue variable to <sentinel>
    jne func$intToStr$while$newvalue$TypeMatch$2                 ; skip next block if newValue variable is not sentinel
      ; Error handling block for newValue
      ;  - print(operandTypeCheckFailureMessage)
      ; Call __print with 1 arguments
      mov r15, offset operandTypeCheckFailureMessage             ; reading operandTypeCheckFailureMessage for push
      push r15                                                   ; value of argument #1 (operandTypeCheckFailureMessage)
      push 01ah                                                  ; type of argument #1 (String'26)
      lea r10, qword ptr [rsp + 030h]                            ; load address of return value's value
      push r10                                                   ; internal argument 6: pointer to return value slot's value
      lea r10, qword ptr [rsp + 030h]                            ; load address of return value's type
      push r10                                                   ; internal argument 5: pointer to return value slot's type
      sub rsp, 020h                                              ; allocate shadow space
      mov r9, 000h                                               ; internal argument 4: "this" pointer
      mov r8, 000h                                               ; internal argument 3: "this" pointer type
      mov rdx, 000h                                              ; internal argument 2: closure pointer
      mov qword ptr [rsp + 050h], rcx                            ; move parameter count of intToStr value out of rcx
      mov rcx, 001h                                              ; internal argument 1: number of actual arguments
      call func$__print                                          ; jump to subroutine
      add rsp, 040h                                              ; release shadow space and arguments (result in stack pointer)
      ;  - exit(1)
      ; Call exit with 1 arguments
      push 001h                                                  ; value of argument #1 (1 (integer))
      push 019h                                                  ; type of argument #1 (Integer'25)
      lea rbx, qword ptr [rsp + 030h]                            ; load address of return value's value
      push rbx                                                   ; internal argument 6: pointer to return value slot's value
      lea rbx, qword ptr [rsp + 030h]                            ; load address of return value's type
      push rbx                                                   ; internal argument 5: pointer to return value slot's type
      sub rsp, 020h                                              ; allocate shadow space
      mov r9, 000h                                               ; internal argument 4: "this" pointer
      mov r8, 000h                                               ; internal argument 3: "this" pointer type
      mov rdx, 000h                                              ; internal argument 2: closure pointer
      mov rcx, 001h                                              ; internal argument 1: number of actual arguments
      call func$exit                                             ; jump to subroutine
      add rsp, 040h                                              ; release shadow space and arguments (result in stack pointer)
      mov rcx, qword ptr [rsp + 010h]                            ; restoring slots to previous scope state
    func$intToStr$while$newvalue$TypeMatch$2:                    ; after block
    mov rax, qword ptr [rsp + 030h]                              ; assign value of newValue variable to value of / operator result
    cqo                                                          ; zero-extend dividend
    mov r12, 00ah                                                ; read operand of div (10 /* 0xa */) 
    idiv r12                                                     ; compute (newValue variable) / (10 /* 0xa */) (result, / operator result, is in rax)
    mov qword ptr [rsp + 020h], r13                              ; move digit variable value out of r13
    mov r13, 019h                                                ; / operator result is of type Integer'25
    mov qword ptr [rsp + 030h], rax                              ; store value
    mov qword ptr [rsp + 028h], r13                              ; store type
    ; Line 213: buffer = concat(digitToStr(digit), buffer);
    ; Call digitToStr with 1 arguments
    push qword ptr [rsp + 020h]                                  ; value of argument #1 (digit variable)
    push r14                                                     ; type of argument #1
    lea r14, qword ptr [rsp + 030h]                              ; load address of return value's value
    push r14                                                     ; internal argument 6: pointer to return value slot's value
    lea r14, qword ptr [rsp + 030h]                              ; load address of return value's type
    push r14                                                     ; internal argument 5: pointer to return value slot's type
    sub rsp, 020h                                                ; allocate shadow space
    mov r9, 000h                                                 ; internal argument 4: "this" pointer
    mov r8, 000h                                                 ; internal argument 3: "this" pointer type
    mov rdx, 000h                                                ; internal argument 2: closure pointer
    mov qword ptr [rsp + 050h], rcx                              ; move parameter count of intToStr value out of rcx
    mov rcx, 001h                                                ; internal argument 1: number of actual arguments
    call func$digitToStr                                         ; jump to subroutine
    add rsp, 040h                                                ; release shadow space and arguments (result in stack pointer)
    ; Call concat with 2 arguments
    push qword ptr [rsp + 038h]                                  ; value of argument #2 (buffer variable)
    push qword ptr [rsp + 048h]                                  ; type of argument #2
    push qword ptr [rsp + 030h]                                  ; value of argument #1 (digitToStr return value)
    push qword ptr [rsp + 030h]                                  ; type of argument #1
    lea r15, qword ptr [rsp + 028h]                              ; load address of return value's value
    push r15                                                     ; internal argument 6: pointer to return value slot's value
    lea r15, qword ptr [rsp + 028h]                              ; load address of return value's type
    push r15                                                     ; internal argument 5: pointer to return value slot's type
    sub rsp, 020h                                                ; allocate shadow space
    mov r9, 000h                                                 ; internal argument 4: "this" pointer
    mov r8, 000h                                                 ; internal argument 3: "this" pointer type
    mov rdx, 000h                                                ; internal argument 2: closure pointer
    mov rcx, 002h                                                ; internal argument 1: number of actual arguments
    call func$concat                                             ; jump to subroutine
    add rsp, 050h                                                ; release shadow space and arguments (result in stack pointer)
    ; Calling decref on buffer variable (static type: String'26)
    sub rsp, 20h                                                 ; allocate shadow space for decref
    mov rdx, qword ptr [rsp + 060h]                              ; arg #2: type of potential string
    mov rcx, qword ptr [rsp + 058h]                              ; arg #1: value of potential string
    call intrinsic$decref                                        ; call decref
    add rsp, 20h                                                 ; free shadow space for decref
    mov r11, qword ptr [rsp + 008h]                              ; indirect through r11 because operand pair (stack operand #2, stack operand #8) is not allowed with mov
    mov qword ptr [rsp + 038h], r11                              ; store value
    mov r11, qword ptr [rsp + 000h]                              ; indirect through r11 because operand pair (stack operand #1, stack operand #9) is not allowed with mov
    mov qword ptr [rsp + 040h], r11                              ; store type
    ; increment reference count for buffer variable if necessary
    cmp qword ptr [rsp + 040h], 01ah                             ; compare type of buffer variable to String
    jne func$intToStr$while$AfterIncref                          ; if not a string, skip incref
    mov r10, qword ptr [rsp + 038h]                              ; get buffer variable into register to dereference it
    mov rbx, qword ptr [r10]                                     ; dereference string to get to ref count
    cmp rbx, 0                                                   ; compare string refcount temporary to 0
    js func$intToStr$while$AfterIncref                           ; if ref count is negative (constant strings), skip incref
    add rbx, 001h                                                ; increment ref count (result in string refcount temporary)
    mov qword ptr [r10], rbx                                     ; put it back in the string
    func$intToStr$while$AfterIncref:                             ; after incref
    ; Calling decref on digitToStr return value (static type: String'26)
    sub rsp, 20h                                                 ; allocate shadow space for decref
    mov rdx, qword ptr [rsp + 038h]                              ; arg #2: type of potential string
    mov rcx, qword ptr [rsp + 040h]                              ; arg #1: value of potential string
    mov qword ptr [rsp + 058h], r10                              ; move buffer variable value out of r10
    call intrinsic$decref                                        ; call decref
    add rsp, 20h                                                 ; free shadow space for decref
    ; Calling decref on concat return value (static type: String'26)
    sub rsp, 20h                                                 ; allocate shadow space for decref
    mov rdx, qword ptr [rsp + 020h]                              ; arg #2: type of potential string
    mov rcx, qword ptr [rsp + 028h]                              ; arg #1: value of potential string
    call intrinsic$decref                                        ; call decref
    add rsp, 20h                                                 ; free shadow space for decref
    mov rax, qword ptr [rsp + 038h]                              ; restoring slots to previous scope state
    mov rcx, qword ptr [rsp + 010h]                              ; restoring slots to previous scope state
    mov rdi, qword ptr [rsp + 040h]                              ; restoring slots to previous scope state
    mov r13, qword ptr [rsp + 030h]                              ; restoring slots to previous scope state
    mov r14, qword ptr [rsp + 028h]                              ; restoring slots to previous scope state
    jmp func$intToStr$while$top                                  ; return to top of while
  func$intToStr$while$bottom:                                    ; bottom of while
  ; Line 215: return buffer;
  cmp rdi, 000h                                                  ; compare type of buffer variable to <sentinel>
  jne func$intToStr$inttostrReturnValue$TypeMatch                ; skip next block if buffer variable is not sentinel
    ; Error handling block for intToStr return value
    ;  - print(returnValueTypeCheckFailureMessage)
    ; Call __print with 1 arguments
    mov rsi, offset returnValueTypeCheckFailureMessage           ; reading returnValueTypeCheckFailureMessage for push
    push rsi                                                     ; value of argument #1 (returnValueTypeCheckFailureMessage)
    push 01ah                                                    ; type of argument #1 (String'26)
    mov qword ptr [rsp + 048h], rdi                              ; move buffer variable type out of rdi
    lea rdi, qword ptr [rsp + 050h]                              ; load address of return value's value
    push rdi                                                     ; internal argument 6: pointer to return value slot's value
    lea rdi, qword ptr [rsp + 048h]                              ; load address of return value's type
    push rdi                                                     ; internal argument 5: pointer to return value slot's type
    sub rsp, 020h                                                ; allocate shadow space
    mov r9, 000h                                                 ; internal argument 4: "this" pointer
    mov r8, 000h                                                 ; internal argument 3: "this" pointer type
    mov rdx, 000h                                                ; internal argument 2: closure pointer
    mov qword ptr [rsp + 068h], rcx                              ; move parameter count of intToStr value out of rcx
    mov rcx, 001h                                                ; internal argument 1: number of actual arguments
    mov qword ptr [rsp + 060h], rax                              ; move buffer variable value out of rax
    call func$__print                                            ; jump to subroutine
    add rsp, 040h                                                ; release shadow space and arguments (result in stack pointer)
    ;  - exit(1)
    ; Call exit with 1 arguments
    push 001h                                                    ; value of argument #1 (1 (integer))
    push 019h                                                    ; type of argument #1 (Integer'25)
    lea rax, qword ptr [rsp + 050h]                              ; load address of return value's value
    push rax                                                     ; internal argument 6: pointer to return value slot's value
    lea rax, qword ptr [rsp + 048h]                              ; load address of return value's type
    push rax                                                     ; internal argument 5: pointer to return value slot's type
    sub rsp, 020h                                                ; allocate shadow space
    mov r9, 000h                                                 ; internal argument 4: "this" pointer
    mov r8, 000h                                                 ; internal argument 3: "this" pointer type
    mov rdx, 000h                                                ; internal argument 2: closure pointer
    mov rcx, 001h                                                ; internal argument 1: number of actual arguments
    call func$exit                                               ; jump to subroutine
    add rsp, 040h                                                ; release shadow space and arguments (result in stack pointer)
    mov rax, qword ptr [rsp + 020h]                              ; restoring slots to previous scope state
    mov rcx, qword ptr [rsp + 028h]                              ; restoring slots to previous scope state
    mov rdi, qword ptr [rsp + 038h]                              ; restoring slots to previous scope state
  func$intToStr$inttostrReturnValue$TypeMatch:                   ; after block
  mov r12, qword ptr [rbp + 030h]                                ; get pointer to return value of intToStr into register to dereference it
  mov qword ptr [r12], rax                                       ; intToStr return value
  mov r13, qword ptr [rbp + 028h]                                ; get pointer to return value type of intToStr into register to dereference it
  mov qword ptr [r13], rdi                                       ; type of intToStr return value
  ; increment reference count for buffer variable if necessary
  cmp rdi, 01ah                                                  ; compare type of buffer variable to String
  jne func$intToStr$AfterIncref$1                                ; if not a string, skip incref
  mov r14, qword ptr [rax]                                       ; dereference string to get to ref count
  cmp r14, 0                                                     ; compare string refcount temporary to 0
  js func$intToStr$AfterIncref$1                                 ; if ref count is negative (constant strings), skip incref
  add r14, 001h                                                  ; increment ref count (result in string refcount temporary)
  mov qword ptr [rax], r14                                       ; put it back in the string
  func$intToStr$AfterIncref$1:                                   ; after incref
  ; Calling decref on buffer variable (static type: String'26)
  sub rsp, 20h                                                   ; allocate shadow space for decref
  mov rdx, rdi                                                   ; arg #2: type of potential string
  mov qword ptr [rsp + 060h], rcx                                ; move parameter count of intToStr value out of rcx
  mov rcx, rax                                                   ; arg #1: value of potential string
  mov r15, rcx                                                   ; save value of potential string
  call intrinsic$decref                                          ; call decref
  add rsp, 20h                                                   ; free shadow space for decref
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
dq func$_stringify$annotation
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
  sub rsp, 038h                                                  ; allocate space for stack
  lea rbp, qword ptr [rsp + 078h]                                ; set up frame pointer
  ; Check parameter count
  cmp rcx, 001h                                                  ; compare parameter count of _stringify to 1 (integer)
  je func$_stringify$parameterCountCheck$continuation            ; check number of parameters is as expected
    ; Error handling block for parameter count
    ;  - print(parameterCountCheckFailureMessage)
    ; Call __print with 1 arguments
    mov r10, offset parameterCountCheckFailureMessage            ; reading parameterCountCheckFailureMessage for push
    push r10                                                     ; value of argument #1 (parameterCountCheckFailureMessage)
    push 01ah                                                    ; type of argument #1 (String'26)
    lea rax, qword ptr [rsp + 038h]                              ; load address of return value's value
    push rax                                                     ; internal argument 6: pointer to return value slot's value
    lea rax, qword ptr [rsp + 038h]                              ; load address of return value's type
    push rax                                                     ; internal argument 5: pointer to return value slot's type
    sub rsp, 020h                                                ; allocate shadow space
    mov r9, 000h                                                 ; internal argument 4: "this" pointer
    mov r8, 000h                                                 ; internal argument 3: "this" pointer type
    mov rdx, 000h                                                ; internal argument 2: closure pointer
    mov qword ptr [rsp + 058h], rcx                              ; move parameter count of _stringify value out of rcx
    mov rcx, 001h                                                ; internal argument 1: number of actual arguments
    call func$__print                                            ; jump to subroutine
    add rsp, 040h                                                ; release shadow space and arguments (result in stack pointer)
    ;  - exit(1)
    ; Call exit with 1 arguments
    push 001h                                                    ; value of argument #1 (1 (integer))
    push 019h                                                    ; type of argument #1 (Integer'25)
    lea rbx, qword ptr [rsp + 038h]                              ; load address of return value's value
    push rbx                                                     ; internal argument 6: pointer to return value slot's value
    lea rbx, qword ptr [rsp + 038h]                              ; load address of return value's type
    push rbx                                                     ; internal argument 5: pointer to return value slot's type
    sub rsp, 020h                                                ; allocate shadow space
    mov r9, 000h                                                 ; internal argument 4: "this" pointer
    mov r8, 000h                                                 ; internal argument 3: "this" pointer type
    mov rdx, 000h                                                ; internal argument 2: closure pointer
    mov rcx, 001h                                                ; internal argument 1: number of actual arguments
    call func$exit                                               ; jump to subroutine
    add rsp, 040h                                                ; release shadow space and arguments (result in stack pointer)
    mov rcx, qword ptr [rsp + 018h]                              ; restoring slots to previous scope state
  func$_stringify$parameterCountCheck$continuation:              ; end of parameter count check
  ; Check type of parameter 0, arg (expecting Anything)
  mov rsi, qword ptr [rbp + 038h]                                ; move type of arg to testByte
  mov rax, rsi                                                   ; move testByte to testByte
  mov rdi, 002h                                                  ; read operand of mul (type table width in bytes) 
  mul rdi                                                        ; adjust to the relative start of that type's entry in the type table
  mov r12, offset typeTable                                      ; read second operand of + (type table pointer)
  add rax, r12                                                   ; finally offset all of that by the start of the type table itself (result in testByte)
  bt qword ptr [rax], 004h                                       ; check that arg is Anything
  jc func$_stringify$arg$TypeMatch                               ; skip next block if the type matches
    ; Error handling block for arg
    ;  - print(parameterTypeCheckFailureMessage)
    ; Call __print with 1 arguments
    mov r13, offset parameterTypeCheckFailureMessage             ; reading parameterTypeCheckFailureMessage for push
    push r13                                                     ; value of argument #1 (parameterTypeCheckFailureMessage)
    push 01ah                                                    ; type of argument #1 (String'26)
    lea r14, qword ptr [rsp + 038h]                              ; load address of return value's value
    push r14                                                     ; internal argument 6: pointer to return value slot's value
    lea r14, qword ptr [rsp + 038h]                              ; load address of return value's type
    push r14                                                     ; internal argument 5: pointer to return value slot's type
    sub rsp, 020h                                                ; allocate shadow space
    mov r9, 000h                                                 ; internal argument 4: "this" pointer
    mov r8, 000h                                                 ; internal argument 3: "this" pointer type
    mov rdx, 000h                                                ; internal argument 2: closure pointer
    mov qword ptr [rsp + 058h], rcx                              ; move parameter count of _stringify value out of rcx
    mov rcx, 001h                                                ; internal argument 1: number of actual arguments
    call func$__print                                            ; jump to subroutine
    add rsp, 040h                                                ; release shadow space and arguments (result in stack pointer)
    ;  - exit(1)
    ; Call exit with 1 arguments
    push 001h                                                    ; value of argument #1 (1 (integer))
    push 019h                                                    ; type of argument #1 (Integer'25)
    lea r15, qword ptr [rsp + 038h]                              ; load address of return value's value
    push r15                                                     ; internal argument 6: pointer to return value slot's value
    lea r15, qword ptr [rsp + 038h]                              ; load address of return value's type
    push r15                                                     ; internal argument 5: pointer to return value slot's type
    sub rsp, 020h                                                ; allocate shadow space
    mov r9, 000h                                                 ; internal argument 4: "this" pointer
    mov r8, 000h                                                 ; internal argument 3: "this" pointer type
    mov rdx, 000h                                                ; internal argument 2: closure pointer
    mov rcx, 001h                                                ; internal argument 1: number of actual arguments
    call func$exit                                               ; jump to subroutine
    add rsp, 040h                                                ; release shadow space and arguments (result in stack pointer)
    mov rcx, qword ptr [rsp + 018h]                              ; restoring slots to previous scope state
  func$_stringify$arg$TypeMatch:                                 ; after block
  ; Line 219: if (arg is String) { ...
  mov r10, qword ptr [rbp + 038h]                                ; move type of arg to testByte
  mov rax, r10                                                   ; move testByte to testByte
  mov rbx, 002h                                                  ; read operand of mul (type table width in bytes) 
  mul rbx                                                        ; adjust to the relative start of that type's entry in the type table
  mov rsi, offset typeTable                                      ; read second operand of + (type table pointer)
  add rax, rsi                                                   ; finally offset all of that by the start of the type table itself (result in testByte)
  bt qword ptr [rax], 003h                                       ; check that arg is String
  mov rdi, 000h                                                  ; clear is expression result
  setc dil                                                       ; store result in is expression result
  mov r12, 018h                                                  ; is expression result is of type Boolean'24
  cmp rdi, 000h                                                  ; compare is expression result to false
  je func$_stringify$if$continuation                             ; arg is String
    ; Line 220: return arg;
    mov r13, qword ptr [rbp + 038h]                              ; move type of arg to testByte
    mov rax, r13                                                 ; move testByte to testByte
    mov r14, 002h                                                ; read operand of mul (type table width in bytes) 
    mul r14                                                      ; adjust to the relative start of that type's entry in the type table
    mov r15, offset typeTable                                    ; read second operand of + (type table pointer)
    add rax, r15                                                 ; finally offset all of that by the start of the type table itself (result in testByte)
    bt qword ptr [rax], 003h                                     ; check that _stringify return value is String
    jc func$_stringify$Stringify$if$StringifyReturnValue$TypeMatch ; skip next block if the type matches
      ; Error handling block for _stringify return value
      ;  - print(returnValueTypeCheckFailureMessage)
      ; Call __print with 1 arguments
      mov r9, offset returnValueTypeCheckFailureMessage          ; reading returnValueTypeCheckFailureMessage for push
      push r9                                                    ; value of argument #1 (returnValueTypeCheckFailureMessage)
      push 01ah                                                  ; type of argument #1 (String'26)
      lea r8, qword ptr [rsp + 038h]                             ; load address of return value's value
      push r8                                                    ; internal argument 6: pointer to return value slot's value
      lea r8, qword ptr [rsp + 038h]                             ; load address of return value's type
      push r8                                                    ; internal argument 5: pointer to return value slot's type
      sub rsp, 020h                                              ; allocate shadow space
      mov r9, 000h                                               ; internal argument 4: "this" pointer
      mov r8, 000h                                               ; internal argument 3: "this" pointer type
      mov rdx, 000h                                              ; internal argument 2: closure pointer
      mov qword ptr [rsp + 058h], rcx                            ; move parameter count of _stringify value out of rcx
      mov rcx, 001h                                              ; internal argument 1: number of actual arguments
      call func$__print                                          ; jump to subroutine
      add rsp, 040h                                              ; release shadow space and arguments (result in stack pointer)
      ;  - exit(1)
      ; Call exit with 1 arguments
      push 001h                                                  ; value of argument #1 (1 (integer))
      push 019h                                                  ; type of argument #1 (Integer'25)
      lea r10, qword ptr [rsp + 038h]                            ; load address of return value's value
      push r10                                                   ; internal argument 6: pointer to return value slot's value
      lea r10, qword ptr [rsp + 038h]                            ; load address of return value's type
      push r10                                                   ; internal argument 5: pointer to return value slot's type
      sub rsp, 020h                                              ; allocate shadow space
      mov r9, 000h                                               ; internal argument 4: "this" pointer
      mov r8, 000h                                               ; internal argument 3: "this" pointer type
      mov rdx, 000h                                              ; internal argument 2: closure pointer
      mov rcx, 001h                                              ; internal argument 1: number of actual arguments
      call func$exit                                             ; jump to subroutine
      add rsp, 040h                                              ; release shadow space and arguments (result in stack pointer)
      mov rcx, qword ptr [rsp + 018h]                            ; restoring slots to previous scope state
    func$_stringify$Stringify$if$StringifyReturnValue$TypeMatch:  ; after block
    mov rbx, qword ptr [rbp + 040h]                              ; read second operand of mov (arg) for MoveToDerefInstruction
    mov rsi, qword ptr [rbp + 030h]                              ; get pointer to return value of _stringify into register to dereference it
    mov qword ptr [rsi], rbx                                     ; _stringify return value
    mov rdi, qword ptr [rbp + 038h]                              ; reading type of arg
    mov r12, qword ptr [rbp + 028h]                              ; get pointer to return value type of _stringify into register to dereference it
    mov qword ptr [r12], rdi                                     ; type of _stringify return value
    ; increment reference count for arg if necessary
    cmp qword ptr [rbp + 038h], 01ah                             ; compare type of arg to String
    jne func$_stringify$Stringify$if$AfterIncref                 ; if not a string, skip incref
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
  ; Line 222: if (arg is Boolean) { ...
  mov r15, qword ptr [rbp + 038h]                                ; move type of arg to testByte
  mov rax, r15                                                   ; move testByte to testByte
  mov r10, 002h                                                  ; read operand of mul (type table width in bytes) 
  mul r10                                                        ; adjust to the relative start of that type's entry in the type table
  mov r9, offset typeTable                                       ; read second operand of + (type table pointer)
  add rax, r9                                                    ; finally offset all of that by the start of the type table itself (result in testByte)
  bt qword ptr [rax], 001h                                       ; check that arg is Boolean
  mov r8, 000h                                                   ; clear is expression result
  setc r8b                                                       ; store result in is expression result
  mov rdx, 018h                                                  ; is expression result is of type Boolean'24
  cmp r8, 000h                                                   ; compare is expression result to false
  je func$_stringify$if$continuation$1                           ; arg is Boolean
    ; Line 223: if (arg) { ...
    cmp qword ptr [rbp + 040h], 000h                             ; compare arg to false
    je func$_stringify$Stringify$if$1$if$continuation            ; arg
      ; Line 224: return 'true';
      mov rdi, offset string$25                                  ; read second operand of mov (string) for MoveToDerefInstruction
      mov r12, qword ptr [rbp + 030h]                            ; get pointer to return value of _stringify into register to dereference it
      mov qword ptr [r12], rdi                                   ; _stringify return value
      mov r13, qword ptr [rbp + 028h]                            ; get pointer to return value type of _stringify into register to dereference it
      mov qword ptr [r13], 01ah                                  ; type of _stringify return value (String'26)
      jmp func$_stringify$epilog                                 ; return
    func$_stringify$Stringify$if$1$if$continuation:              ; end of if
    ; Line 226: return 'false';
    mov r10, offset string$26                                    ; read second operand of mov (string) for MoveToDerefInstruction
    mov rbx, qword ptr [rbp + 030h]                              ; get pointer to return value of _stringify into register to dereference it
    mov qword ptr [rbx], r10                                     ; _stringify return value
    mov rsi, qword ptr [rbp + 028h]                              ; get pointer to return value type of _stringify into register to dereference it
    mov qword ptr [rsi], 01ah                                    ; type of _stringify return value (String'26)
    jmp func$_stringify$epilog                                   ; return
  func$_stringify$if$continuation$1:                             ; end of if
  ; Line 228: if (arg is Null) { ...
  mov rdi, qword ptr [rbp + 038h]                                ; move type of arg to testByte
  mov rax, rdi                                                   ; move testByte to testByte
  mov r12, 002h                                                  ; read operand of mul (type table width in bytes) 
  mul r12                                                        ; adjust to the relative start of that type's entry in the type table
  mov r13, offset typeTable                                      ; read second operand of + (type table pointer)
  add rax, r13                                                   ; finally offset all of that by the start of the type table itself (result in testByte)
  bt qword ptr [rax], 000h                                       ; check that arg is Null
  mov r14, 000h                                                  ; clear is expression result
  setc r14b                                                      ; store result in is expression result
  mov r15, 018h                                                  ; is expression result is of type Boolean'24
  cmp r14, 000h                                                  ; compare is expression result to false
  je func$_stringify$if$continuation$2                           ; arg is Null
    ; Line 229: return 'null';
    mov rbx, offset string$27                                    ; read second operand of mov (string) for MoveToDerefInstruction
    mov rsi, qword ptr [rbp + 030h]                              ; get pointer to return value of _stringify into register to dereference it
    mov qword ptr [rsi], rbx                                     ; _stringify return value
    mov rdi, qword ptr [rbp + 028h]                              ; get pointer to return value type of _stringify into register to dereference it
    mov qword ptr [rdi], 01ah                                    ; type of _stringify return value (String'26)
    jmp func$_stringify$epilog                                   ; return
  func$_stringify$if$continuation$2:                             ; end of if
  ; Line 231: if (arg is Integer) { ...
  mov rax, qword ptr [rbp + 038h]                                ; move type of arg to testByte
  mov r12, 002h                                                  ; read operand of mul (type table width in bytes) 
  mul r12                                                        ; adjust to the relative start of that type's entry in the type table
  mov r13, offset typeTable                                      ; read second operand of + (type table pointer)
  add rax, r13                                                   ; finally offset all of that by the start of the type table itself (result in testByte)
  bt qword ptr [rax], 002h                                       ; check that arg is Integer
  mov r14, 000h                                                  ; clear is expression result
  setc r14b                                                      ; store result in is expression result
  mov r15, 018h                                                  ; is expression result is of type Boolean'24
  cmp r14, 000h                                                  ; compare is expression result to false
  je func$_stringify$if$continuation$3                           ; arg is Integer
    ; Line 232: return intToStr(arg as Integer);
    mov r10, qword ptr [rbp + 038h]                              ; move type of arg to testByte
    mov rax, r10                                                 ; move testByte to testByte
    mov r9, 002h                                                 ; read operand of mul (type table width in bytes) 
    mul r9                                                       ; adjust to the relative start of that type's entry in the type table
    mov r8, offset typeTable                                     ; read second operand of + (type table pointer)
    add rax, r8                                                  ; finally offset all of that by the start of the type table itself (result in testByte)
    bt qword ptr [rax], 002h                                     ; check that arg as Integer is Integer
    jc func$_stringify$Stringify$if$3$argAsINteger$TypeMatch     ; skip next block if the type matches
      ; Error handling block for arg as Integer
      ;  - print(asOperatorFailureMessage)
      ; Call __print with 1 arguments
      mov rdx, offset asOperatorFailureMessage                   ; reading asOperatorFailureMessage for push
      push rdx                                                   ; value of argument #1 (asOperatorFailureMessage)
      push 01ah                                                  ; type of argument #1 (String'26)
      mov qword ptr [rsp + 030h], rcx                            ; move parameter count of _stringify value out of rcx
      lea rcx, qword ptr [rsp + 038h]                            ; load address of return value's value
      push rcx                                                   ; internal argument 6: pointer to return value slot's value
      lea rcx, qword ptr [rsp + 030h]                            ; load address of return value's type
      push rcx                                                   ; internal argument 5: pointer to return value slot's type
      sub rsp, 020h                                              ; allocate shadow space
      mov r9, 000h                                               ; internal argument 4: "this" pointer
      mov r8, 000h                                               ; internal argument 3: "this" pointer type
      mov rdx, 000h                                              ; internal argument 2: closure pointer
      mov rcx, 001h                                              ; internal argument 1: number of actual arguments
      call func$__print                                          ; jump to subroutine
      add rsp, 040h                                              ; release shadow space and arguments (result in stack pointer)
      ;  - exit(1)
      ; Call exit with 1 arguments
      push 001h                                                  ; value of argument #1 (1 (integer))
      push 019h                                                  ; type of argument #1 (Integer'25)
      lea rbx, qword ptr [rsp + 038h]                            ; load address of return value's value
      push rbx                                                   ; internal argument 6: pointer to return value slot's value
      lea rbx, qword ptr [rsp + 030h]                            ; load address of return value's type
      push rbx                                                   ; internal argument 5: pointer to return value slot's type
      sub rsp, 020h                                              ; allocate shadow space
      mov r9, 000h                                               ; internal argument 4: "this" pointer
      mov r8, 000h                                               ; internal argument 3: "this" pointer type
      mov rdx, 000h                                              ; internal argument 2: closure pointer
      mov rcx, 001h                                              ; internal argument 1: number of actual arguments
      call func$exit                                             ; jump to subroutine
      add rsp, 040h                                              ; release shadow space and arguments (result in stack pointer)
      mov rcx, qword ptr [rsp + 020h]                            ; restoring slots to previous scope state
    func$_stringify$Stringify$if$3$argAsINteger$TypeMatch:       ; after block
    ; Call intToStr with 1 arguments
    push qword ptr [rbp + 040h]                                  ; value of argument #1 (arg)
    push qword ptr [rbp + 038h]                                  ; type of argument #1
    lea rsi, qword ptr [rsp + 038h]                              ; load address of return value's value
    push rsi                                                     ; internal argument 6: pointer to return value slot's value
    lea rsi, qword ptr [rsp + 038h]                              ; load address of return value's type
    push rsi                                                     ; internal argument 5: pointer to return value slot's type
    sub rsp, 020h                                                ; allocate shadow space
    mov r9, 000h                                                 ; internal argument 4: "this" pointer
    mov r8, 000h                                                 ; internal argument 3: "this" pointer type
    mov rdx, 000h                                                ; internal argument 2: closure pointer
    mov qword ptr [rsp + 058h], rcx                              ; move parameter count of _stringify value out of rcx
    mov rcx, 001h                                                ; internal argument 1: number of actual arguments
    call func$intToStr                                           ; jump to subroutine
    add rsp, 040h                                                ; release shadow space and arguments (result in stack pointer)
    cmp qword ptr [rsp + 020h], 000h                             ; compare type of intToStr return value to <sentinel>
    jne func$_stringify$Stringify$if$3$StringifyReturnValue$TypeMatch ; skip next block if intToStr return value is not sentinel
      ; Error handling block for _stringify return value
      ;  - print(returnValueTypeCheckFailureMessage)
      ; Call __print with 1 arguments
      mov rdi, offset returnValueTypeCheckFailureMessage         ; reading returnValueTypeCheckFailureMessage for push
      push rdi                                                   ; value of argument #1 (returnValueTypeCheckFailureMessage)
      push 01ah                                                  ; type of argument #1 (String'26)
      lea r12, qword ptr [rsp + 020h]                            ; load address of return value's value
      push r12                                                   ; internal argument 6: pointer to return value slot's value
      lea r12, qword ptr [rsp + 020h]                            ; load address of return value's type
      push r12                                                   ; internal argument 5: pointer to return value slot's type
      sub rsp, 020h                                              ; allocate shadow space
      mov r9, 000h                                               ; internal argument 4: "this" pointer
      mov r8, 000h                                               ; internal argument 3: "this" pointer type
      mov rdx, 000h                                              ; internal argument 2: closure pointer
      mov rcx, 001h                                              ; internal argument 1: number of actual arguments
      call func$__print                                          ; jump to subroutine
      add rsp, 040h                                              ; release shadow space and arguments (result in stack pointer)
      ;  - exit(1)
      ; Call exit with 1 arguments
      push 001h                                                  ; value of argument #1 (1 (integer))
      push 019h                                                  ; type of argument #1 (Integer'25)
      lea r13, qword ptr [rsp + 020h]                            ; load address of return value's value
      push r13                                                   ; internal argument 6: pointer to return value slot's value
      lea r13, qword ptr [rsp + 020h]                            ; load address of return value's type
      push r13                                                   ; internal argument 5: pointer to return value slot's type
      sub rsp, 020h                                              ; allocate shadow space
      mov r9, 000h                                               ; internal argument 4: "this" pointer
      mov r8, 000h                                               ; internal argument 3: "this" pointer type
      mov rdx, 000h                                              ; internal argument 2: closure pointer
      mov rcx, 001h                                              ; internal argument 1: number of actual arguments
      call func$exit                                             ; jump to subroutine
      add rsp, 040h                                              ; release shadow space and arguments (result in stack pointer)
    func$_stringify$Stringify$if$3$StringifyReturnValue$TypeMatch:  ; after block
    mov r14, qword ptr [rsp + 028h]                              ; read second operand of mov (intToStr return value) for MoveToDerefInstruction
    mov r15, qword ptr [rbp + 030h]                              ; get pointer to return value of _stringify into register to dereference it
    mov qword ptr [r15], r14                                     ; _stringify return value
    mov r10, qword ptr [rsp + 020h]                              ; reading type of intToStr return value
    mov rax, qword ptr [rbp + 028h]                              ; get pointer to return value type of _stringify into register to dereference it
    mov qword ptr [rax], r10                                     ; type of _stringify return value
    ; increment reference count for intToStr return value if necessary
    cmp r10, 01ah                                                ; compare type of intToStr return value to String
    jne func$_stringify$Stringify$if$3$AfterIncref               ; if not a string, skip incref
    mov rbx, qword ptr [r14]                                     ; dereference string to get to ref count
    cmp rbx, 0                                                   ; compare string refcount temporary to 0
    js func$_stringify$Stringify$if$3$AfterIncref                ; if ref count is negative (constant strings), skip incref
    add rbx, 001h                                                ; increment ref count (result in string refcount temporary)
    mov qword ptr [r14], rbx                                     ; put it back in the string
    func$_stringify$Stringify$if$3$AfterIncref:                  ; after incref
    ; Calling decref on intToStr return value (static type: String'26)
    sub rsp, 20h                                                 ; allocate shadow space for decref
    mov rdx, r10                                                 ; arg #2: type of potential string
    mov rcx, r14                                                 ; arg #1: value of potential string
    mov rsi, rdx                                                 ; save type of potential string
    call intrinsic$decref                                        ; call decref
    add rsp, 20h                                                 ; free shadow space for decref
    jmp func$_stringify$epilog                                   ; return
  func$_stringify$if$continuation$3:                             ; end of if
  ; Line 234: if (arg is AnythingFunction) { ...
  mov rdi, qword ptr [rbp + 038h]                                ; move type of arg to testByte
  mov rax, rdi                                                   ; move testByte to testByte
  mov r12, 002h                                                  ; read operand of mul (type table width in bytes) 
  mul r12                                                        ; adjust to the relative start of that type's entry in the type table
  mov r13, offset typeTable                                      ; read second operand of + (type table pointer)
  add rax, r13                                                   ; finally offset all of that by the start of the type table itself (result in testByte)
  bt qword ptr [rax], 006h                                       ; check that arg is AnythingFunction
  mov r9, 000h                                                   ; clear is expression result
  setc r9b                                                       ; store result in is expression result
  mov r8, 018h                                                   ; is expression result is of type Boolean'24
  cmp r9, 000h                                                   ; compare is expression result to false
  je func$_stringify$if$continuation$4                           ; arg is AnythingFunction
    ; Line 235: Integer func = arg __as__ Integer;
    mov rdx, qword ptr [rbp + 040h]                              ; force cast of arg to Integer
    mov qword ptr [rsp + 028h], rcx                              ; move parameter count of _stringify value out of rcx
    mov rcx, 019h                                                ; force cast of arg to Integer is of type Integer'25
    mov r14, rdx                                                 ; value initialization of variable declaration for func variable (force cast of arg to Integer)
    mov r15, rcx                                                 ; type initialization of variable declaration for func variable
    ; Line 236: Integer annotation = __readFromAddress(func - 8);
    cmp r15, 000h                                                ; compare type of func variable to <sentinel>
    jne func$_stringify$Stringify$if$4$func$TypeMatch            ; skip next block if func variable is not sentinel
      ; Error handling block for func
      ;  - print(operandTypeCheckFailureMessage)
      ; Call __print with 1 arguments
      mov r10, offset operandTypeCheckFailureMessage             ; reading operandTypeCheckFailureMessage for push
      push r10                                                   ; value of argument #1 (operandTypeCheckFailureMessage)
      push 01ah                                                  ; type of argument #1 (String'26)
      lea rbx, qword ptr [rsp + 030h]                            ; load address of return value's value
      push rbx                                                   ; internal argument 6: pointer to return value slot's value
      lea rbx, qword ptr [rsp + 030h]                            ; load address of return value's type
      push rbx                                                   ; internal argument 5: pointer to return value slot's type
      sub rsp, 020h                                              ; allocate shadow space
      mov r9, 000h                                               ; internal argument 4: "this" pointer
      mov r8, 000h                                               ; internal argument 3: "this" pointer type
      mov rdx, 000h                                              ; internal argument 2: closure pointer
      mov rcx, 001h                                              ; internal argument 1: number of actual arguments
      call func$__print                                          ; jump to subroutine
      add rsp, 040h                                              ; release shadow space and arguments (result in stack pointer)
      ;  - exit(1)
      ; Call exit with 1 arguments
      push 001h                                                  ; value of argument #1 (1 (integer))
      push 019h                                                  ; type of argument #1 (Integer'25)
      lea rsi, qword ptr [rsp + 030h]                            ; load address of return value's value
      push rsi                                                   ; internal argument 6: pointer to return value slot's value
      lea rsi, qword ptr [rsp + 030h]                            ; load address of return value's type
      push rsi                                                   ; internal argument 5: pointer to return value slot's type
      sub rsp, 020h                                              ; allocate shadow space
      mov r9, 000h                                               ; internal argument 4: "this" pointer
      mov r8, 000h                                               ; internal argument 3: "this" pointer type
      mov rdx, 000h                                              ; internal argument 2: closure pointer
      mov rcx, 001h                                              ; internal argument 1: number of actual arguments
      call func$exit                                             ; jump to subroutine
      add rsp, 040h                                              ; release shadow space and arguments (result in stack pointer)
    func$_stringify$Stringify$if$4$func$TypeMatch:               ; after block
    mov r13, r14                                                 ; assign value of func variable to value of - operator result
    sub r13, 008h                                                ; compute (func variable) - (8)
    mov r14, 019h                                                ; - operator result is of type Integer'25
    ; Call __readFromAddress with 1 arguments
    mov r15, qword ptr [r13]                                     ; dereference first argument of __readFromAddress
    mov r10, 019h                                                ; dereferenced - operator result is of type Integer'25
    mov rbx, r15                                                 ; value initialization of variable declaration for annotation variable (dereferenced - operator result)
    mov rsi, r10                                                 ; type initialization of variable declaration for annotation variable
    ; Line 237: return concat('<function (', annotation __as__ String, ')>');
    mov rdi, rbx                                                 ; force cast of annotation variable to String
    mov rax, 01ah                                                ; force cast of annotation variable to String is of type String'26
    ; Call concat with 3 arguments
    mov r12, offset string$29                                    ; reading string for push
    push r12                                                     ; value of argument #3 (string)
    push 01ah                                                    ; type of argument #3 (String'26)
    push rdi                                                     ; value of argument #2 (force cast of annotation variable to String)
    push rax                                                     ; type of argument #2
    mov r9, offset string$28                                     ; reading string for push
    push r9                                                      ; value of argument #1 (string)
    push 01ah                                                    ; type of argument #1 (String'26)
    lea r8, qword ptr [rsp + 050h]                               ; load address of return value's value
    push r8                                                      ; internal argument 6: pointer to return value slot's value
    lea r8, qword ptr [rsp + 050h]                               ; load address of return value's type
    push r8                                                      ; internal argument 5: pointer to return value slot's type
    sub rsp, 020h                                                ; allocate shadow space
    mov r9, 000h                                                 ; internal argument 4: "this" pointer
    mov r8, 000h                                                 ; internal argument 3: "this" pointer type
    mov rdx, 000h                                                ; internal argument 2: closure pointer
    mov rcx, 003h                                                ; internal argument 1: number of actual arguments
    mov qword ptr [rsp + 070h], rax                              ; move force cast of annotation variable to String type out of rax
    call func$concat                                             ; jump to subroutine
    add rsp, 060h                                                ; release shadow space and arguments (result in stack pointer)
    cmp qword ptr [rsp + 018h], 000h                             ; compare type of concat return value to <sentinel>
    jne func$_stringify$Stringify$if$4$StringifyReturnValue$TypeMatch ; skip next block if concat return value is not sentinel
      ; Error handling block for _stringify return value
      ;  - print(returnValueTypeCheckFailureMessage)
      ; Call __print with 1 arguments
      mov r13, offset returnValueTypeCheckFailureMessage         ; reading returnValueTypeCheckFailureMessage for push
      push r13                                                   ; value of argument #1 (returnValueTypeCheckFailureMessage)
      push 01ah                                                  ; type of argument #1 (String'26)
      lea r14, qword ptr [rsp + 018h]                            ; load address of return value's value
      push r14                                                   ; internal argument 6: pointer to return value slot's value
      lea r14, qword ptr [rsp + 018h]                            ; load address of return value's type
      push r14                                                   ; internal argument 5: pointer to return value slot's type
      sub rsp, 020h                                              ; allocate shadow space
      mov r9, 000h                                               ; internal argument 4: "this" pointer
      mov r8, 000h                                               ; internal argument 3: "this" pointer type
      mov rdx, 000h                                              ; internal argument 2: closure pointer
      mov rcx, 001h                                              ; internal argument 1: number of actual arguments
      call func$__print                                          ; jump to subroutine
      add rsp, 040h                                              ; release shadow space and arguments (result in stack pointer)
      ;  - exit(1)
      ; Call exit with 1 arguments
      push 001h                                                  ; value of argument #1 (1 (integer))
      push 019h                                                  ; type of argument #1 (Integer'25)
      lea r15, qword ptr [rsp + 018h]                            ; load address of return value's value
      push r15                                                   ; internal argument 6: pointer to return value slot's value
      lea r15, qword ptr [rsp + 018h]                            ; load address of return value's type
      push r15                                                   ; internal argument 5: pointer to return value slot's type
      sub rsp, 020h                                              ; allocate shadow space
      mov r9, 000h                                               ; internal argument 4: "this" pointer
      mov r8, 000h                                               ; internal argument 3: "this" pointer type
      mov rdx, 000h                                              ; internal argument 2: closure pointer
      mov rcx, 001h                                              ; internal argument 1: number of actual arguments
      call func$exit                                             ; jump to subroutine
      add rsp, 040h                                              ; release shadow space and arguments (result in stack pointer)
    func$_stringify$Stringify$if$4$StringifyReturnValue$TypeMatch:  ; after block
    mov r10, qword ptr [rsp + 020h]                              ; read second operand of mov (concat return value) for MoveToDerefInstruction
    mov rbx, qword ptr [rbp + 030h]                              ; get pointer to return value of _stringify into register to dereference it
    mov qword ptr [rbx], r10                                     ; _stringify return value
    mov rsi, qword ptr [rsp + 018h]                              ; reading type of concat return value
    mov qword ptr [rsp + 020h], rdi                              ; move force cast of annotation variable to String value out of rdi
    mov rdi, qword ptr [rbp + 028h]                              ; get pointer to return value type of _stringify into register to dereference it
    mov qword ptr [rdi], rsi                                     ; type of _stringify return value
    ; increment reference count for concat return value if necessary
    cmp rsi, 01ah                                                ; compare type of concat return value to String
    jne func$_stringify$Stringify$if$4$AfterIncref               ; if not a string, skip incref
    mov rax, qword ptr [r10]                                     ; dereference string to get to ref count
    cmp rax, 0                                                   ; compare string refcount temporary to 0
    js func$_stringify$Stringify$if$4$AfterIncref                ; if ref count is negative (constant strings), skip incref
    add rax, 001h                                                ; increment ref count (result in string refcount temporary)
    mov qword ptr [r10], rax                                     ; put it back in the string
    func$_stringify$Stringify$if$4$AfterIncref:                  ; after incref
    ; Calling decref on concat return value (static type: String'26)
    sub rsp, 20h                                                 ; allocate shadow space for decref
    mov rdx, rsi                                                 ; arg #2: type of potential string
    mov rcx, r10                                                 ; arg #1: value of potential string
    mov r12, rcx                                                 ; save value of potential string
    call intrinsic$decref                                        ; call decref
    add rsp, 20h                                                 ; free shadow space for decref
    ; Calling decref on force cast of annotation variable to String (static type: String'26)
    sub rsp, 20h                                                 ; allocate shadow space for decref
    mov rdx, qword ptr [rsp + 030h]                              ; arg #2: type of potential string
    mov rcx, qword ptr [rsp + 040h]                              ; arg #1: value of potential string
    call intrinsic$decref                                        ; call decref
    add rsp, 20h                                                 ; free shadow space for decref
    jmp func$_stringify$epilog                                   ; return
  func$_stringify$if$continuation$4:                             ; end of if
  ; Line 239: __print('value cannot be stringified\n');
  ; Call __print with 1 arguments
  mov r13, offset string$30                                      ; reading string for push
  push r13                                                       ; value of argument #1 (string)
  push 01ah                                                      ; type of argument #1 (String'26)
  lea r14, qword ptr [rsp + 038h]                                ; load address of return value's value
  push r14                                                       ; internal argument 6: pointer to return value slot's value
  lea r14, qword ptr [rsp + 038h]                                ; load address of return value's type
  push r14                                                       ; internal argument 5: pointer to return value slot's type
  sub rsp, 020h                                                  ; allocate shadow space
  mov r9, 000h                                                   ; internal argument 4: "this" pointer
  mov r8, 000h                                                   ; internal argument 3: "this" pointer type
  mov rdx, 000h                                                  ; internal argument 2: closure pointer
  mov qword ptr [rsp + 058h], rcx                                ; move parameter count of _stringify value out of rcx
  mov rcx, 001h                                                  ; internal argument 1: number of actual arguments
  call func$__print                                              ; jump to subroutine
  add rsp, 040h                                                  ; release shadow space and arguments (result in stack pointer)
  ; Line 240: exit(1);
  ; Call exit with 1 arguments
  push 001h                                                      ; value of argument #1 (1)
  push 019h                                                      ; type of argument #1 (Integer'25)
  lea r15, qword ptr [rsp + 038h]                                ; load address of return value's value
  push r15                                                       ; internal argument 6: pointer to return value slot's value
  lea r15, qword ptr [rsp + 038h]                                ; load address of return value's type
  push r15                                                       ; internal argument 5: pointer to return value slot's type
  sub rsp, 020h                                                  ; allocate shadow space
  mov r9, 000h                                                   ; internal argument 4: "this" pointer
  mov r8, 000h                                                   ; internal argument 3: "this" pointer type
  mov rdx, 000h                                                  ; internal argument 2: closure pointer
  mov rcx, 001h                                                  ; internal argument 1: number of actual arguments
  call func$exit                                                 ; jump to subroutine
  add rsp, 040h                                                  ; release shadow space and arguments (result in stack pointer)
  ; Implicit return from _stringify
  mov r10, 017h                                                  ; move type of null to testByte
  mov rax, r10                                                   ; move testByte to testByte
  mov rbx, 002h                                                  ; read operand of mul (type table width in bytes) 
  mul rbx                                                        ; adjust to the relative start of that type's entry in the type table
  mov rsi, offset typeTable                                      ; read second operand of + (type table pointer)
  add rax, rsi                                                   ; finally offset all of that by the start of the type table itself (result in testByte)
  bt qword ptr [rax], 003h                                       ; check that _stringify return value is String
  jc func$_stringify$StringifyReturnValue$TypeMatch              ; skip next block if the type matches
    ; Error handling block for _stringify return value
    ;  - print(returnValueTypeCheckFailureMessage)
    ; Call __print with 1 arguments
    mov rdi, offset returnValueTypeCheckFailureMessage           ; reading returnValueTypeCheckFailureMessage for push
    push rdi                                                     ; value of argument #1 (returnValueTypeCheckFailureMessage)
    push 01ah                                                    ; type of argument #1 (String'26)
    lea r12, qword ptr [rsp + 038h]                              ; load address of return value's value
    push r12                                                     ; internal argument 6: pointer to return value slot's value
    lea r12, qword ptr [rsp + 038h]                              ; load address of return value's type
    push r12                                                     ; internal argument 5: pointer to return value slot's type
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
    push 019h                                                    ; type of argument #1 (Integer'25)
    lea r13, qword ptr [rsp + 038h]                              ; load address of return value's value
    push r13                                                     ; internal argument 6: pointer to return value slot's value
    lea r13, qword ptr [rsp + 038h]                              ; load address of return value's type
    push r13                                                     ; internal argument 5: pointer to return value slot's type
    sub rsp, 020h                                                ; allocate shadow space
    mov r9, 000h                                                 ; internal argument 4: "this" pointer
    mov r8, 000h                                                 ; internal argument 3: "this" pointer type
    mov rdx, 000h                                                ; internal argument 2: closure pointer
    mov rcx, 001h                                                ; internal argument 1: number of actual arguments
    call func$exit                                               ; jump to subroutine
    add rsp, 040h                                                ; release shadow space and arguments (result in stack pointer)
  func$_stringify$StringifyReturnValue$TypeMatch:                ; after block
  mov r14, qword ptr [rbp + 030h]                                ; get pointer to return value of _stringify into register to dereference it
  mov qword ptr [r14], 000h                                      ; _stringify return value
  mov r15, qword ptr [rbp + 028h]                                ; get pointer to return value type of _stringify into register to dereference it
  mov qword ptr [r15], 017h                                      ; type of _stringify return value (Null'23)
  func$_stringify$epilog: 
  mov rax, qword ptr [rbp + 030h]                                ; report address of return value
  ; Epilog
  add rsp, 038h                                                  ; free space for stack
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
dq func$print$annotation
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
  sub rsp, 060h                                                  ; allocate space for stack
  lea rbp, qword ptr [rsp + 0a0h]                                ; set up frame pointer
  ; Varargs parameter type check; expecting parameters to be Anything
  lea r10, qword ptr [rbp + 040h]                                ; get base address of varargs, where loop will start
  mov rax, rcx                                                   ; assign value of parameter count of print to value of pointer to last argument
  mov rbx, 010h                                                  ; read operand of mul (10 (integer)) 
  mul rbx                                                        ; end of loop is the number of arguments times the width of each argument (010h)...
  add rax, r10                                                   ; ...offset from the initial index (result in pointer to last argument)
  func$print$varargTypeChecks$Loop:                              ; top of loop
    mov qword ptr [rsp + 050h], 000h                             ; move pointer to indexth argument type into a mutable location
    cmp r10, rax                                                 ; compare pointer to indexth argument to pointer to last argument
    je func$print$varargTypeChecks$TypesAllMatch                 ; we have type-checked all the arguments
    mov rsi, qword ptr [r10 - 008h]                              ; load type of indexth argument into indexth argument
    mov rdi, rsi                                                 ; move type of indexth argument to testByte
    mov qword ptr [rsp + 048h], rax                              ; move pointer to last argument value out of rax
    mov rax, rdi                                                 ; move testByte to testByte
    mov r12, 002h                                                ; read operand of mul (type table width in bytes) 
    mul r12                                                      ; adjust to the relative start of that type's entry in the type table
    mov r13, offset typeTable                                    ; read second operand of + (type table pointer)
    add rax, r13                                                 ; finally offset all of that by the start of the type table itself (result in testByte)
    bt qword ptr [rax], 004h                                     ; check that vararg types is Anything
    jc func$print$varargTypeChecks$TypeMatch                     ; skip next block if the type matches
      ; Error handling block for vararg types
      ;  - print(parameterTypeCheckFailureMessage)
      ; Call __print with 1 arguments
      mov r14, offset parameterTypeCheckFailureMessage           ; reading parameterTypeCheckFailureMessage for push
      push r14                                                   ; value of argument #1 (parameterTypeCheckFailureMessage)
      push 01ah                                                  ; type of argument #1 (String'26)
      lea r15, qword ptr [rsp + 050h]                            ; load address of return value's value
      push r15                                                   ; internal argument 6: pointer to return value slot's value
      lea r15, qword ptr [rsp + 050h]                            ; load address of return value's type
      push r15                                                   ; internal argument 5: pointer to return value slot's type
      sub rsp, 020h                                              ; allocate shadow space
      mov r9, 000h                                               ; internal argument 4: "this" pointer
      mov r8, 000h                                               ; internal argument 3: "this" pointer type
      mov rdx, 000h                                              ; internal argument 2: closure pointer
      mov qword ptr [rsp + 070h], rcx                            ; move parameter count of print value out of rcx
      mov rcx, 001h                                              ; internal argument 1: number of actual arguments
      mov qword ptr [rsp + 068h], r10                            ; move pointer to indexth argument value out of r10
      call func$__print                                          ; jump to subroutine
      add rsp, 040h                                              ; release shadow space and arguments (result in stack pointer)
      ;  - exit(1)
      ; Call exit with 1 arguments
      push 001h                                                  ; value of argument #1 (1 (integer))
      push 019h                                                  ; type of argument #1 (Integer'25)
      lea r10, qword ptr [rsp + 050h]                            ; load address of return value's value
      push r10                                                   ; internal argument 6: pointer to return value slot's value
      lea r10, qword ptr [rsp + 050h]                            ; load address of return value's type
      push r10                                                   ; internal argument 5: pointer to return value slot's type
      sub rsp, 020h                                              ; allocate shadow space
      mov r9, 000h                                               ; internal argument 4: "this" pointer
      mov r8, 000h                                               ; internal argument 3: "this" pointer type
      mov rdx, 000h                                              ; internal argument 2: closure pointer
      mov rcx, 001h                                              ; internal argument 1: number of actual arguments
      call func$exit                                             ; jump to subroutine
      add rsp, 040h                                              ; release shadow space and arguments (result in stack pointer)
      mov r10, qword ptr [rsp + 028h]                            ; restoring slots to previous scope state
      mov rcx, qword ptr [rsp + 030h]                            ; restoring slots to previous scope state
    func$print$varargTypeChecks$TypeMatch:                       ; after block
    add r10, 010h                                                ; next argument (result in pointer to indexth argument)
    mov rax, qword ptr [rsp + 048h]                              ; restoring slots to previous scope state
    jmp func$print$varargTypeChecks$Loop                         ; return to top of loop
    func$print$varargTypeChecks$TypesAllMatch:                   ; after loop
    mov rax, qword ptr [rsp + 048h]                              ; restoring slots to previous scope state
  ; Line 244: Boolean first = true;
  mov rbx, 001h                                                  ; value initialization of variable declaration for first variable (true)
  mov rsi, 018h                                                  ; type initialization of variable declaration for first variable (Boolean'24)
  ; Line 245: Integer index = 0;
  mov rdi, 000h                                                  ; value initialization of variable declaration for index variable (0)
  mov rax, 019h                                                  ; type initialization of variable declaration for index variable (Integer'25)
  func$print$while$top:                                          ; top of while
    ; Call len with 1 arguments
    cmp rax, 000h                                                ; compare type of index variable to <sentinel>
    jne func$print$while$index$TypeMatch                         ; skip next block if index variable is not sentinel
      ; Error handling block for index
      ;  - print(operandTypeCheckFailureMessage)
      ; Call __print with 1 arguments
      mov r12, offset operandTypeCheckFailureMessage             ; reading operandTypeCheckFailureMessage for push
      push r12                                                   ; value of argument #1 (operandTypeCheckFailureMessage)
      push 01ah                                                  ; type of argument #1 (String'26)
      lea r13, qword ptr [rsp + 060h]                            ; load address of return value's value
      push r13                                                   ; internal argument 6: pointer to return value slot's value
      lea r13, qword ptr [rsp + 060h]                            ; load address of return value's type
      push r13                                                   ; internal argument 5: pointer to return value slot's type
      sub rsp, 020h                                              ; allocate shadow space
      mov r9, 000h                                               ; internal argument 4: "this" pointer
      mov r8, 000h                                               ; internal argument 3: "this" pointer type
      mov rdx, 000h                                              ; internal argument 2: closure pointer
      mov qword ptr [rsp + 080h], rcx                            ; move parameter count of print value out of rcx
      mov rcx, 001h                                              ; internal argument 1: number of actual arguments
      mov qword ptr [rsp + 078h], rax                            ; move index variable type out of rax
      call func$__print                                          ; jump to subroutine
      add rsp, 040h                                              ; release shadow space and arguments (result in stack pointer)
      ;  - exit(1)
      ; Call exit with 1 arguments
      push 001h                                                  ; value of argument #1 (1 (integer))
      push 019h                                                  ; type of argument #1 (Integer'25)
      lea r14, qword ptr [rsp + 060h]                            ; load address of return value's value
      push r14                                                   ; internal argument 6: pointer to return value slot's value
      lea r14, qword ptr [rsp + 060h]                            ; load address of return value's type
      push r14                                                   ; internal argument 5: pointer to return value slot's type
      sub rsp, 020h                                              ; allocate shadow space
      mov r9, 000h                                               ; internal argument 4: "this" pointer
      mov r8, 000h                                               ; internal argument 3: "this" pointer type
      mov rdx, 000h                                              ; internal argument 2: closure pointer
      mov rcx, 001h                                              ; internal argument 1: number of actual arguments
      call func$exit                                             ; jump to subroutine
      add rsp, 040h                                              ; release shadow space and arguments (result in stack pointer)
      mov rax, qword ptr [rsp + 038h]                            ; restoring slots to previous scope state
      mov rcx, qword ptr [rsp + 040h]                            ; restoring slots to previous scope state
    func$print$while$index$TypeMatch:                            ; after block
    mov qword ptr [rsp + 050h], rsi                              ; move first variable type out of rsi
    xor rsi, rsi                                                 ; clear < operator result
    cmp rdi, rcx                                                 ; compare index variable with parameter count of print
    setl sil                                                     ; store result in < operator result
    mov qword ptr [rsp + 048h], rdi                              ; move index variable value out of rdi
    mov rdi, 018h                                                ; < operator result is of type Boolean'24
    cmp rsi, 000h                                                ; compare < operator result to false
    jne func$print$while$body                                    ; while condition
    mov rsi, qword ptr [rsp + 050h]                              ; restoring slots to previous scope state
    mov rdi, qword ptr [rsp + 048h]                              ; restoring slots to previous scope state
    jmp func$print$while$bottom                                  ; break out of while
    func$print$while$body:                                       ; start of while
    ; Line 247: if (first == false) { ...
    mov qword ptr [rsp + 040h], rax                              ; move index variable type out of rax
    xor rax, rax                                                 ; zero value result of == (testing first variable and false) to put the boolean in
    cmp rbx, 000h                                                ; values equal?
    sete al                                                      ; put result in value result of == (testing first variable and false)
    mov r12, 018h                                                ; value result of == (testing first variable and false) is a Boolean'24
    xor r13, r13                                                 ; zero type result of == (testing first variable and false) to put the boolean in
    cmp qword ptr [rsp + 050h], 018h                             ; types equal?
    sete r13b                                                    ; put result in type result of == (testing first variable and false)
    mov r14, 018h                                                ; type result of == (testing first variable and false) is a Boolean'24
    mov r15, rax                                                 ; assign value of value result of == (testing first variable and false) to value of == operator result
    and r15, r13                                                 ; && type temp and value temp
    mov r10, 018h                                                ; == operator result is of type Boolean'24
    cmp r15, 000h                                                ; compare == operator result to false
    je func$print$while$if$continuation                          ; first == false
      ; Line 248: __print(' ');
      ; Call __print with 1 arguments
      mov qword ptr [rsp + 038h], rbx                            ; move first variable value out of rbx
      mov rbx, offset string$31                                  ; reading string for push
      push rbx                                                   ; value of argument #1 (string)
      push 01ah                                                  ; type of argument #1 (String'26)
      lea r9, qword ptr [rsp + 040h]                             ; load address of return value's value
      push r9                                                    ; internal argument 6: pointer to return value slot's value
      lea r9, qword ptr [rsp + 040h]                             ; load address of return value's type
      push r9                                                    ; internal argument 5: pointer to return value slot's type
      sub rsp, 020h                                              ; allocate shadow space
      mov r9, 000h                                               ; internal argument 4: "this" pointer
      mov r8, 000h                                               ; internal argument 3: "this" pointer type
      mov rdx, 000h                                              ; internal argument 2: closure pointer
      mov qword ptr [rsp + 060h], rcx                            ; move parameter count of print value out of rcx
      mov rcx, 001h                                              ; internal argument 1: number of actual arguments
      call func$__print                                          ; jump to subroutine
      add rsp, 040h                                              ; release shadow space and arguments (result in stack pointer)
      mov rbx, qword ptr [rsp + 038h]                            ; restoring slots to previous scope state
      mov rcx, qword ptr [rsp + 020h]                            ; restoring slots to previous scope state
    func$print$while$if$continuation:                            ; end of if
    ; Line 250: __print(_stringify(parts[index]));
    cmp qword ptr [rsp + 048h], rcx                              ; compare index variable to parameter count of print
    jge func$print$while$subscript$boundsError                   ; index out of range (too high)
    cmp qword ptr [rsp + 048h], 000h                             ; compare index variable to 0 (integer)
    jge func$print$while$subscript$inBounds                      ; index not out of range (not negative)
    func$print$while$subscript$boundsError:                      ; invalid index
      ; Error handling block for subscript bounds error
      ;  - print(boundsFailureMessage)
      ; Call __print with 1 arguments
      mov r12, offset boundsFailureMessage                       ; reading boundsFailureMessage for push
      push r12                                                   ; value of argument #1 (boundsFailureMessage)
      push 01ah                                                  ; type of argument #1 (String'26)
      lea r13, qword ptr [rsp + 048h]                            ; load address of return value's value
      push r13                                                   ; internal argument 6: pointer to return value slot's value
      lea r13, qword ptr [rsp + 048h]                            ; load address of return value's type
      push r13                                                   ; internal argument 5: pointer to return value slot's type
      sub rsp, 020h                                              ; allocate shadow space
      mov r9, 000h                                               ; internal argument 4: "this" pointer
      mov r8, 000h                                               ; internal argument 3: "this" pointer type
      mov rdx, 000h                                              ; internal argument 2: closure pointer
      mov qword ptr [rsp + 068h], rcx                            ; move parameter count of print value out of rcx
      mov rcx, 001h                                              ; internal argument 1: number of actual arguments
      call func$__print                                          ; jump to subroutine
      add rsp, 040h                                              ; release shadow space and arguments (result in stack pointer)
      ;  - exit(1)
      ; Call exit with 1 arguments
      push 001h                                                  ; value of argument #1 (1 (integer))
      push 019h                                                  ; type of argument #1 (Integer'25)
      lea r14, qword ptr [rsp + 048h]                            ; load address of return value's value
      push r14                                                   ; internal argument 6: pointer to return value slot's value
      lea r14, qword ptr [rsp + 048h]                            ; load address of return value's type
      push r14                                                   ; internal argument 5: pointer to return value slot's type
      sub rsp, 020h                                              ; allocate shadow space
      mov r9, 000h                                               ; internal argument 4: "this" pointer
      mov r8, 000h                                               ; internal argument 3: "this" pointer type
      mov rdx, 000h                                              ; internal argument 2: closure pointer
      mov rcx, 001h                                              ; internal argument 1: number of actual arguments
      call func$exit                                             ; jump to subroutine
      add rsp, 040h                                              ; release shadow space and arguments (result in stack pointer)
      mov rcx, qword ptr [rsp + 028h]                            ; restoring slots to previous scope state
    func$print$while$subscript$inBounds:                         ; valid index
    lea r15, qword ptr [rbp + 040h]                              ; base address of varargs
    mov r10, qword ptr [rsp + 048h]                              ; assign value of index variable to value of index into list * 16
    shl r10, 004h                                                ; multiply by 8*2
    mov qword ptr [rsp + 038h], rbx                              ; move first variable value out of rbx
    mov rbx, r15                                                 ; assign value of base address of varargs to value of pointer to value (and type, later)
    add rbx, r10                                                 ; get pointer to value (result in pointer to value (and type, later))
    mov rsi, qword ptr [rbx]                                     ; store value
    mov rdi, qword ptr [rbx - 008h]                              ; store type
    ; increment reference count for parts[index] if necessary
    cmp rdi, 01ah                                                ; compare type of parts[index] to String
    jne func$print$while$AfterIncref                             ; if not a string, skip incref
    mov rax, qword ptr [rsi]                                     ; dereference string to get to ref count
    cmp rax, 0                                                   ; compare string refcount temporary to 0
    js func$print$while$AfterIncref                              ; if ref count is negative (constant strings), skip incref
    add rax, 001h                                                ; increment ref count (result in string refcount temporary)
    mov qword ptr [rsi], rax                                     ; put it back in the string
    func$print$while$AfterIncref:                                ; after incref
    ; Call _stringify with 1 arguments
    push rsi                                                     ; value of argument #1 (parts[index])
    push rdi                                                     ; type of argument #1
    lea r12, qword ptr [rsp + 040h]                              ; load address of return value's value
    push r12                                                     ; internal argument 6: pointer to return value slot's value
    lea r12, qword ptr [rsp + 040h]                              ; load address of return value's type
    push r12                                                     ; internal argument 5: pointer to return value slot's type
    sub rsp, 020h                                                ; allocate shadow space
    mov r9, 000h                                                 ; internal argument 4: "this" pointer
    mov r8, 000h                                                 ; internal argument 3: "this" pointer type
    mov rdx, 000h                                                ; internal argument 2: closure pointer
    mov qword ptr [rsp + 060h], rcx                              ; move parameter count of print value out of rcx
    mov rcx, 001h                                                ; internal argument 1: number of actual arguments
    call func$_stringify                                         ; jump to subroutine
    add rsp, 040h                                                ; release shadow space and arguments (result in stack pointer)
    ; Call __print with 1 arguments
    push qword ptr [rsp + 030h]                                  ; value of argument #1 (_stringify return value)
    push qword ptr [rsp + 030h]                                  ; type of argument #1
    lea r13, qword ptr [rsp + 028h]                              ; load address of return value's value
    push r13                                                     ; internal argument 6: pointer to return value slot's value
    lea r13, qword ptr [rsp + 028h]                              ; load address of return value's type
    push r13                                                     ; internal argument 5: pointer to return value slot's type
    sub rsp, 020h                                                ; allocate shadow space
    mov r9, 000h                                                 ; internal argument 4: "this" pointer
    mov r8, 000h                                                 ; internal argument 3: "this" pointer type
    mov rdx, 000h                                                ; internal argument 2: closure pointer
    mov rcx, 001h                                                ; internal argument 1: number of actual arguments
    call func$__print                                            ; jump to subroutine
    add rsp, 040h                                                ; release shadow space and arguments (result in stack pointer)
    ; Line 251: first = false;
    mov qword ptr [rsp + 038h], 000h                             ; store value
    mov qword ptr [rsp + 050h], 018h                             ; store type (Boolean'24)
    ; Line 252: index += 1;
    cmp qword ptr [rsp + 040h], 000h                             ; compare type of index variable to <sentinel>
    jne func$print$while$indexVariable$TypeMatch                 ; skip next block if index variable is not sentinel
      ; Error handling block for index variable
      ;  - print(operandTypeCheckFailureMessage)
      ; Call __print with 1 arguments
      mov r14, offset operandTypeCheckFailureMessage             ; reading operandTypeCheckFailureMessage for push
      push r14                                                   ; value of argument #1 (operandTypeCheckFailureMessage)
      push 01ah                                                  ; type of argument #1 (String'26)
      lea r15, qword ptr [rsp + 028h]                            ; load address of return value's value
      push r15                                                   ; internal argument 6: pointer to return value slot's value
      lea r15, qword ptr [rsp + 028h]                            ; load address of return value's type
      push r15                                                   ; internal argument 5: pointer to return value slot's type
      sub rsp, 020h                                              ; allocate shadow space
      mov r9, 000h                                               ; internal argument 4: "this" pointer
      mov r8, 000h                                               ; internal argument 3: "this" pointer type
      mov rdx, 000h                                              ; internal argument 2: closure pointer
      mov rcx, 001h                                              ; internal argument 1: number of actual arguments
      call func$__print                                          ; jump to subroutine
      add rsp, 040h                                              ; release shadow space and arguments (result in stack pointer)
      ;  - exit(1)
      ; Call exit with 1 arguments
      push 001h                                                  ; value of argument #1 (1 (integer))
      push 019h                                                  ; type of argument #1 (Integer'25)
      lea r10, qword ptr [rsp + 028h]                            ; load address of return value's value
      push r10                                                   ; internal argument 6: pointer to return value slot's value
      lea r10, qword ptr [rsp + 028h]                            ; load address of return value's type
      push r10                                                   ; internal argument 5: pointer to return value slot's type
      sub rsp, 020h                                              ; allocate shadow space
      mov r9, 000h                                               ; internal argument 4: "this" pointer
      mov r8, 000h                                               ; internal argument 3: "this" pointer type
      mov rdx, 000h                                              ; internal argument 2: closure pointer
      mov rcx, 001h                                              ; internal argument 1: number of actual arguments
      call func$exit                                             ; jump to subroutine
      add rsp, 040h                                              ; release shadow space and arguments (result in stack pointer)
    func$print$while$indexVariable$TypeMatch:                    ; after block
    mov rax, qword ptr [rsp + 048h]                              ; assign value of index variable to value of += operator result
    add rax, 001h                                                ; += operator
    mov r12, 019h                                                ; += operator result is of type Integer'25
    mov qword ptr [rsp + 048h], rax                              ; store value
    mov qword ptr [rsp + 040h], r12                              ; store type
    ; Calling decref on parts[index] (static type: Anything'27)
    sub rsp, 20h                                                 ; allocate shadow space for decref
    mov rdx, rdi                                                 ; arg #2: type of potential string
    mov rcx, rsi                                                 ; arg #1: value of potential string
    call intrinsic$decref                                        ; call decref
    add rsp, 20h                                                 ; free shadow space for decref
    ; Calling decref on _stringify return value (static type: String'26)
    sub rsp, 20h                                                 ; allocate shadow space for decref
    mov rdx, qword ptr [rsp + 048h]                              ; arg #2: type of potential string
    mov rcx, qword ptr [rsp + 050h]                              ; arg #1: value of potential string
    call intrinsic$decref                                        ; call decref
    add rsp, 20h                                                 ; free shadow space for decref
    mov rax, qword ptr [rsp + 040h]                              ; restoring slots to previous scope state
    mov rbx, qword ptr [rsp + 038h]                              ; restoring slots to previous scope state
    mov rcx, qword ptr [rsp + 020h]                              ; restoring slots to previous scope state
    mov rsi, qword ptr [rsp + 050h]                              ; restoring slots to previous scope state
    mov rdi, qword ptr [rsp + 048h]                              ; restoring slots to previous scope state
    jmp func$print$while$top                                     ; return to top of while
  func$print$while$bottom:                                       ; bottom of while
  ; Implicit return from print
  mov r10, qword ptr [rbp + 030h]                                ; get pointer to return value of print into register to dereference it
  mov qword ptr [r10], 000h                                      ; print return value
  mov rbx, qword ptr [rbp + 028h]                                ; get pointer to return value type of print into register to dereference it
  mov qword ptr [rbx], 017h                                      ; type of print return value (Null'23)
  mov rax, qword ptr [rbp + 030h]                                ; report address of return value
  ; Epilog
  add rsp, 060h                                                  ; free space for stack
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
dq func$println$annotation
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
  sub rsp, 060h                                                  ; allocate space for stack
  lea rbp, qword ptr [rsp + 0a0h]                                ; set up frame pointer
  ; Varargs parameter type check; expecting parameters to be Anything
  lea r10, qword ptr [rbp + 040h]                                ; get base address of varargs, where loop will start
  mov rax, rcx                                                   ; assign value of parameter count of println to value of pointer to last argument
  mov rbx, 010h                                                  ; read operand of mul (10 (integer)) 
  mul rbx                                                        ; end of loop is the number of arguments times the width of each argument (010h)...
  add rax, r10                                                   ; ...offset from the initial index (result in pointer to last argument)
  func$println$varargTypeChecks$Loop:                            ; top of loop
    mov qword ptr [rsp + 050h], 000h                             ; move pointer to indexth argument type into a mutable location
    cmp r10, rax                                                 ; compare pointer to indexth argument to pointer to last argument
    je func$println$varargTypeChecks$TypesAllMatch               ; we have type-checked all the arguments
    mov rsi, qword ptr [r10 - 008h]                              ; load type of indexth argument into indexth argument
    mov rdi, rsi                                                 ; move type of indexth argument to testByte
    mov qword ptr [rsp + 048h], rax                              ; move pointer to last argument value out of rax
    mov rax, rdi                                                 ; move testByte to testByte
    mov r12, 002h                                                ; read operand of mul (type table width in bytes) 
    mul r12                                                      ; adjust to the relative start of that type's entry in the type table
    mov r13, offset typeTable                                    ; read second operand of + (type table pointer)
    add rax, r13                                                 ; finally offset all of that by the start of the type table itself (result in testByte)
    bt qword ptr [rax], 004h                                     ; check that vararg types is Anything
    jc func$println$varargTypeChecks$TypeMatch                   ; skip next block if the type matches
      ; Error handling block for vararg types
      ;  - print(parameterTypeCheckFailureMessage)
      ; Call __print with 1 arguments
      mov r14, offset parameterTypeCheckFailureMessage           ; reading parameterTypeCheckFailureMessage for push
      push r14                                                   ; value of argument #1 (parameterTypeCheckFailureMessage)
      push 01ah                                                  ; type of argument #1 (String'26)
      lea r15, qword ptr [rsp + 050h]                            ; load address of return value's value
      push r15                                                   ; internal argument 6: pointer to return value slot's value
      lea r15, qword ptr [rsp + 050h]                            ; load address of return value's type
      push r15                                                   ; internal argument 5: pointer to return value slot's type
      sub rsp, 020h                                              ; allocate shadow space
      mov r9, 000h                                               ; internal argument 4: "this" pointer
      mov r8, 000h                                               ; internal argument 3: "this" pointer type
      mov rdx, 000h                                              ; internal argument 2: closure pointer
      mov qword ptr [rsp + 070h], rcx                            ; move parameter count of println value out of rcx
      mov rcx, 001h                                              ; internal argument 1: number of actual arguments
      mov qword ptr [rsp + 068h], r10                            ; move pointer to indexth argument value out of r10
      call func$__print                                          ; jump to subroutine
      add rsp, 040h                                              ; release shadow space and arguments (result in stack pointer)
      ;  - exit(1)
      ; Call exit with 1 arguments
      push 001h                                                  ; value of argument #1 (1 (integer))
      push 019h                                                  ; type of argument #1 (Integer'25)
      lea r10, qword ptr [rsp + 050h]                            ; load address of return value's value
      push r10                                                   ; internal argument 6: pointer to return value slot's value
      lea r10, qword ptr [rsp + 050h]                            ; load address of return value's type
      push r10                                                   ; internal argument 5: pointer to return value slot's type
      sub rsp, 020h                                              ; allocate shadow space
      mov r9, 000h                                               ; internal argument 4: "this" pointer
      mov r8, 000h                                               ; internal argument 3: "this" pointer type
      mov rdx, 000h                                              ; internal argument 2: closure pointer
      mov rcx, 001h                                              ; internal argument 1: number of actual arguments
      call func$exit                                             ; jump to subroutine
      add rsp, 040h                                              ; release shadow space and arguments (result in stack pointer)
      mov r10, qword ptr [rsp + 028h]                            ; restoring slots to previous scope state
      mov rcx, qword ptr [rsp + 030h]                            ; restoring slots to previous scope state
    func$println$varargTypeChecks$TypeMatch:                     ; after block
    add r10, 010h                                                ; next argument (result in pointer to indexth argument)
    mov rax, qword ptr [rsp + 048h]                              ; restoring slots to previous scope state
    jmp func$println$varargTypeChecks$Loop                       ; return to top of loop
    func$println$varargTypeChecks$TypesAllMatch:                 ; after loop
    mov rax, qword ptr [rsp + 048h]                              ; restoring slots to previous scope state
  ; Line 257: Boolean first = true;
  mov rbx, 001h                                                  ; value initialization of variable declaration for first variable (true)
  mov rsi, 018h                                                  ; type initialization of variable declaration for first variable (Boolean'24)
  ; Line 258: Integer index = 0;
  mov rdi, 000h                                                  ; value initialization of variable declaration for index variable (0)
  mov rax, 019h                                                  ; type initialization of variable declaration for index variable (Integer'25)
  func$println$while$top:                                        ; top of while
    ; Call len with 1 arguments
    cmp rax, 000h                                                ; compare type of index variable to <sentinel>
    jne func$println$while$index$TypeMatch                       ; skip next block if index variable is not sentinel
      ; Error handling block for index
      ;  - print(operandTypeCheckFailureMessage)
      ; Call __print with 1 arguments
      mov r12, offset operandTypeCheckFailureMessage             ; reading operandTypeCheckFailureMessage for push
      push r12                                                   ; value of argument #1 (operandTypeCheckFailureMessage)
      push 01ah                                                  ; type of argument #1 (String'26)
      lea r13, qword ptr [rsp + 060h]                            ; load address of return value's value
      push r13                                                   ; internal argument 6: pointer to return value slot's value
      lea r13, qword ptr [rsp + 060h]                            ; load address of return value's type
      push r13                                                   ; internal argument 5: pointer to return value slot's type
      sub rsp, 020h                                              ; allocate shadow space
      mov r9, 000h                                               ; internal argument 4: "this" pointer
      mov r8, 000h                                               ; internal argument 3: "this" pointer type
      mov rdx, 000h                                              ; internal argument 2: closure pointer
      mov qword ptr [rsp + 080h], rcx                            ; move parameter count of println value out of rcx
      mov rcx, 001h                                              ; internal argument 1: number of actual arguments
      mov qword ptr [rsp + 078h], rax                            ; move index variable type out of rax
      call func$__print                                          ; jump to subroutine
      add rsp, 040h                                              ; release shadow space and arguments (result in stack pointer)
      ;  - exit(1)
      ; Call exit with 1 arguments
      push 001h                                                  ; value of argument #1 (1 (integer))
      push 019h                                                  ; type of argument #1 (Integer'25)
      lea r14, qword ptr [rsp + 060h]                            ; load address of return value's value
      push r14                                                   ; internal argument 6: pointer to return value slot's value
      lea r14, qword ptr [rsp + 060h]                            ; load address of return value's type
      push r14                                                   ; internal argument 5: pointer to return value slot's type
      sub rsp, 020h                                              ; allocate shadow space
      mov r9, 000h                                               ; internal argument 4: "this" pointer
      mov r8, 000h                                               ; internal argument 3: "this" pointer type
      mov rdx, 000h                                              ; internal argument 2: closure pointer
      mov rcx, 001h                                              ; internal argument 1: number of actual arguments
      call func$exit                                             ; jump to subroutine
      add rsp, 040h                                              ; release shadow space and arguments (result in stack pointer)
      mov rax, qword ptr [rsp + 038h]                            ; restoring slots to previous scope state
      mov rcx, qword ptr [rsp + 040h]                            ; restoring slots to previous scope state
    func$println$while$index$TypeMatch:                          ; after block
    mov qword ptr [rsp + 050h], rsi                              ; move first variable type out of rsi
    xor rsi, rsi                                                 ; clear < operator result
    cmp rdi, rcx                                                 ; compare index variable with parameter count of println
    setl sil                                                     ; store result in < operator result
    mov qword ptr [rsp + 048h], rdi                              ; move index variable value out of rdi
    mov rdi, 018h                                                ; < operator result is of type Boolean'24
    cmp rsi, 000h                                                ; compare < operator result to false
    jne func$println$while$body                                  ; while condition
    mov rsi, qword ptr [rsp + 050h]                              ; restoring slots to previous scope state
    mov rdi, qword ptr [rsp + 048h]                              ; restoring slots to previous scope state
    jmp func$println$while$bottom                                ; break out of while
    func$println$while$body:                                     ; start of while
    ; Line 260: if (first == false) { ...
    mov qword ptr [rsp + 040h], rax                              ; move index variable type out of rax
    xor rax, rax                                                 ; zero value result of == (testing first variable and false) to put the boolean in
    cmp rbx, 000h                                                ; values equal?
    sete al                                                      ; put result in value result of == (testing first variable and false)
    mov r12, 018h                                                ; value result of == (testing first variable and false) is a Boolean'24
    xor r13, r13                                                 ; zero type result of == (testing first variable and false) to put the boolean in
    cmp qword ptr [rsp + 050h], 018h                             ; types equal?
    sete r13b                                                    ; put result in type result of == (testing first variable and false)
    mov r14, 018h                                                ; type result of == (testing first variable and false) is a Boolean'24
    mov r15, rax                                                 ; assign value of value result of == (testing first variable and false) to value of == operator result
    and r15, r13                                                 ; && type temp and value temp
    mov r10, 018h                                                ; == operator result is of type Boolean'24
    cmp r15, 000h                                                ; compare == operator result to false
    je func$println$while$if$continuation                        ; first == false
      ; Line 261: __print(' ');
      ; Call __print with 1 arguments
      mov qword ptr [rsp + 038h], rbx                            ; move first variable value out of rbx
      mov rbx, offset string$31                                  ; reading string for push
      push rbx                                                   ; value of argument #1 (string)
      push 01ah                                                  ; type of argument #1 (String'26)
      lea r9, qword ptr [rsp + 040h]                             ; load address of return value's value
      push r9                                                    ; internal argument 6: pointer to return value slot's value
      lea r9, qword ptr [rsp + 040h]                             ; load address of return value's type
      push r9                                                    ; internal argument 5: pointer to return value slot's type
      sub rsp, 020h                                              ; allocate shadow space
      mov r9, 000h                                               ; internal argument 4: "this" pointer
      mov r8, 000h                                               ; internal argument 3: "this" pointer type
      mov rdx, 000h                                              ; internal argument 2: closure pointer
      mov qword ptr [rsp + 060h], rcx                            ; move parameter count of println value out of rcx
      mov rcx, 001h                                              ; internal argument 1: number of actual arguments
      call func$__print                                          ; jump to subroutine
      add rsp, 040h                                              ; release shadow space and arguments (result in stack pointer)
      mov rbx, qword ptr [rsp + 038h]                            ; restoring slots to previous scope state
      mov rcx, qword ptr [rsp + 020h]                            ; restoring slots to previous scope state
    func$println$while$if$continuation:                          ; end of if
    ; Line 263: __print(_stringify(parts[index]));
    cmp qword ptr [rsp + 048h], rcx                              ; compare index variable to parameter count of println
    jge func$println$while$subscript$boundsError                 ; index out of range (too high)
    cmp qword ptr [rsp + 048h], 000h                             ; compare index variable to 0 (integer)
    jge func$println$while$subscript$inBounds                    ; index not out of range (not negative)
    func$println$while$subscript$boundsError:                    ; invalid index
      ; Error handling block for subscript bounds error
      ;  - print(boundsFailureMessage)
      ; Call __print with 1 arguments
      mov r12, offset boundsFailureMessage                       ; reading boundsFailureMessage for push
      push r12                                                   ; value of argument #1 (boundsFailureMessage)
      push 01ah                                                  ; type of argument #1 (String'26)
      lea r13, qword ptr [rsp + 048h]                            ; load address of return value's value
      push r13                                                   ; internal argument 6: pointer to return value slot's value
      lea r13, qword ptr [rsp + 048h]                            ; load address of return value's type
      push r13                                                   ; internal argument 5: pointer to return value slot's type
      sub rsp, 020h                                              ; allocate shadow space
      mov r9, 000h                                               ; internal argument 4: "this" pointer
      mov r8, 000h                                               ; internal argument 3: "this" pointer type
      mov rdx, 000h                                              ; internal argument 2: closure pointer
      mov qword ptr [rsp + 068h], rcx                            ; move parameter count of println value out of rcx
      mov rcx, 001h                                              ; internal argument 1: number of actual arguments
      call func$__print                                          ; jump to subroutine
      add rsp, 040h                                              ; release shadow space and arguments (result in stack pointer)
      ;  - exit(1)
      ; Call exit with 1 arguments
      push 001h                                                  ; value of argument #1 (1 (integer))
      push 019h                                                  ; type of argument #1 (Integer'25)
      lea r14, qword ptr [rsp + 048h]                            ; load address of return value's value
      push r14                                                   ; internal argument 6: pointer to return value slot's value
      lea r14, qword ptr [rsp + 048h]                            ; load address of return value's type
      push r14                                                   ; internal argument 5: pointer to return value slot's type
      sub rsp, 020h                                              ; allocate shadow space
      mov r9, 000h                                               ; internal argument 4: "this" pointer
      mov r8, 000h                                               ; internal argument 3: "this" pointer type
      mov rdx, 000h                                              ; internal argument 2: closure pointer
      mov rcx, 001h                                              ; internal argument 1: number of actual arguments
      call func$exit                                             ; jump to subroutine
      add rsp, 040h                                              ; release shadow space and arguments (result in stack pointer)
      mov rcx, qword ptr [rsp + 028h]                            ; restoring slots to previous scope state
    func$println$while$subscript$inBounds:                       ; valid index
    lea r15, qword ptr [rbp + 040h]                              ; base address of varargs
    mov r10, qword ptr [rsp + 048h]                              ; assign value of index variable to value of index into list * 16
    shl r10, 004h                                                ; multiply by 8*2
    mov qword ptr [rsp + 038h], rbx                              ; move first variable value out of rbx
    mov rbx, r15                                                 ; assign value of base address of varargs to value of pointer to value (and type, later)
    add rbx, r10                                                 ; get pointer to value (result in pointer to value (and type, later))
    mov rsi, qword ptr [rbx]                                     ; store value
    mov rdi, qword ptr [rbx - 008h]                              ; store type
    ; increment reference count for parts[index] if necessary
    cmp rdi, 01ah                                                ; compare type of parts[index] to String
    jne func$println$while$AfterIncref                           ; if not a string, skip incref
    mov rax, qword ptr [rsi]                                     ; dereference string to get to ref count
    cmp rax, 0                                                   ; compare string refcount temporary to 0
    js func$println$while$AfterIncref                            ; if ref count is negative (constant strings), skip incref
    add rax, 001h                                                ; increment ref count (result in string refcount temporary)
    mov qword ptr [rsi], rax                                     ; put it back in the string
    func$println$while$AfterIncref:                              ; after incref
    ; Call _stringify with 1 arguments
    push rsi                                                     ; value of argument #1 (parts[index])
    push rdi                                                     ; type of argument #1
    lea r12, qword ptr [rsp + 040h]                              ; load address of return value's value
    push r12                                                     ; internal argument 6: pointer to return value slot's value
    lea r12, qword ptr [rsp + 040h]                              ; load address of return value's type
    push r12                                                     ; internal argument 5: pointer to return value slot's type
    sub rsp, 020h                                                ; allocate shadow space
    mov r9, 000h                                                 ; internal argument 4: "this" pointer
    mov r8, 000h                                                 ; internal argument 3: "this" pointer type
    mov rdx, 000h                                                ; internal argument 2: closure pointer
    mov qword ptr [rsp + 060h], rcx                              ; move parameter count of println value out of rcx
    mov rcx, 001h                                                ; internal argument 1: number of actual arguments
    call func$_stringify                                         ; jump to subroutine
    add rsp, 040h                                                ; release shadow space and arguments (result in stack pointer)
    ; Call __print with 1 arguments
    push qword ptr [rsp + 030h]                                  ; value of argument #1 (_stringify return value)
    push qword ptr [rsp + 030h]                                  ; type of argument #1
    lea r13, qword ptr [rsp + 028h]                              ; load address of return value's value
    push r13                                                     ; internal argument 6: pointer to return value slot's value
    lea r13, qword ptr [rsp + 028h]                              ; load address of return value's type
    push r13                                                     ; internal argument 5: pointer to return value slot's type
    sub rsp, 020h                                                ; allocate shadow space
    mov r9, 000h                                                 ; internal argument 4: "this" pointer
    mov r8, 000h                                                 ; internal argument 3: "this" pointer type
    mov rdx, 000h                                                ; internal argument 2: closure pointer
    mov rcx, 001h                                                ; internal argument 1: number of actual arguments
    call func$__print                                            ; jump to subroutine
    add rsp, 040h                                                ; release shadow space and arguments (result in stack pointer)
    ; Line 264: first = false;
    mov qword ptr [rsp + 038h], 000h                             ; store value
    mov qword ptr [rsp + 050h], 018h                             ; store type (Boolean'24)
    ; Line 265: index += 1;
    cmp qword ptr [rsp + 040h], 000h                             ; compare type of index variable to <sentinel>
    jne func$println$while$indexVariable$TypeMatch               ; skip next block if index variable is not sentinel
      ; Error handling block for index variable
      ;  - print(operandTypeCheckFailureMessage)
      ; Call __print with 1 arguments
      mov r14, offset operandTypeCheckFailureMessage             ; reading operandTypeCheckFailureMessage for push
      push r14                                                   ; value of argument #1 (operandTypeCheckFailureMessage)
      push 01ah                                                  ; type of argument #1 (String'26)
      lea r15, qword ptr [rsp + 028h]                            ; load address of return value's value
      push r15                                                   ; internal argument 6: pointer to return value slot's value
      lea r15, qword ptr [rsp + 028h]                            ; load address of return value's type
      push r15                                                   ; internal argument 5: pointer to return value slot's type
      sub rsp, 020h                                              ; allocate shadow space
      mov r9, 000h                                               ; internal argument 4: "this" pointer
      mov r8, 000h                                               ; internal argument 3: "this" pointer type
      mov rdx, 000h                                              ; internal argument 2: closure pointer
      mov rcx, 001h                                              ; internal argument 1: number of actual arguments
      call func$__print                                          ; jump to subroutine
      add rsp, 040h                                              ; release shadow space and arguments (result in stack pointer)
      ;  - exit(1)
      ; Call exit with 1 arguments
      push 001h                                                  ; value of argument #1 (1 (integer))
      push 019h                                                  ; type of argument #1 (Integer'25)
      lea r10, qword ptr [rsp + 028h]                            ; load address of return value's value
      push r10                                                   ; internal argument 6: pointer to return value slot's value
      lea r10, qword ptr [rsp + 028h]                            ; load address of return value's type
      push r10                                                   ; internal argument 5: pointer to return value slot's type
      sub rsp, 020h                                              ; allocate shadow space
      mov r9, 000h                                               ; internal argument 4: "this" pointer
      mov r8, 000h                                               ; internal argument 3: "this" pointer type
      mov rdx, 000h                                              ; internal argument 2: closure pointer
      mov rcx, 001h                                              ; internal argument 1: number of actual arguments
      call func$exit                                             ; jump to subroutine
      add rsp, 040h                                              ; release shadow space and arguments (result in stack pointer)
    func$println$while$indexVariable$TypeMatch:                  ; after block
    mov rax, qword ptr [rsp + 048h]                              ; assign value of index variable to value of += operator result
    add rax, 001h                                                ; += operator
    mov r12, 019h                                                ; += operator result is of type Integer'25
    mov qword ptr [rsp + 048h], rax                              ; store value
    mov qword ptr [rsp + 040h], r12                              ; store type
    ; Calling decref on parts[index] (static type: Anything'27)
    sub rsp, 20h                                                 ; allocate shadow space for decref
    mov rdx, rdi                                                 ; arg #2: type of potential string
    mov rcx, rsi                                                 ; arg #1: value of potential string
    call intrinsic$decref                                        ; call decref
    add rsp, 20h                                                 ; free shadow space for decref
    ; Calling decref on _stringify return value (static type: String'26)
    sub rsp, 20h                                                 ; allocate shadow space for decref
    mov rdx, qword ptr [rsp + 048h]                              ; arg #2: type of potential string
    mov rcx, qword ptr [rsp + 050h]                              ; arg #1: value of potential string
    call intrinsic$decref                                        ; call decref
    add rsp, 20h                                                 ; free shadow space for decref
    mov rax, qword ptr [rsp + 040h]                              ; restoring slots to previous scope state
    mov rbx, qword ptr [rsp + 038h]                              ; restoring slots to previous scope state
    mov rcx, qword ptr [rsp + 020h]                              ; restoring slots to previous scope state
    mov rsi, qword ptr [rsp + 050h]                              ; restoring slots to previous scope state
    mov rdi, qword ptr [rsp + 048h]                              ; restoring slots to previous scope state
    jmp func$println$while$top                                   ; return to top of while
  func$println$while$bottom:                                     ; bottom of while
  ; Line 267: __print('\n');
  ; Call __print with 1 arguments
  mov r13, offset string                                         ; reading string for push
  push r13                                                       ; value of argument #1 (string)
  push 01ah                                                      ; type of argument #1 (String'26)
  lea r14, qword ptr [rsp + 060h]                                ; load address of return value's value
  push r14                                                       ; internal argument 6: pointer to return value slot's value
  lea r14, qword ptr [rsp + 060h]                                ; load address of return value's type
  push r14                                                       ; internal argument 5: pointer to return value slot's type
  sub rsp, 020h                                                  ; allocate shadow space
  mov r9, 000h                                                   ; internal argument 4: "this" pointer
  mov r8, 000h                                                   ; internal argument 3: "this" pointer type
  mov rdx, 000h                                                  ; internal argument 2: closure pointer
  mov qword ptr [rsp + 080h], rcx                                ; move parameter count of println value out of rcx
  mov rcx, 001h                                                  ; internal argument 1: number of actual arguments
  call func$__print                                              ; jump to subroutine
  add rsp, 040h                                                  ; release shadow space and arguments (result in stack pointer)
  ; Implicit return from println
  mov rsi, qword ptr [rbp + 030h]                                ; get pointer to return value of println into register to dereference it
  mov qword ptr [rsi], 000h                                      ; println return value
  mov rdi, qword ptr [rbp + 028h]                                ; get pointer to return value type of println into register to dereference it
  mov qword ptr [rdi], 017h                                      ; type of println return value (Null'23)
  mov rax, qword ptr [rbp + 030h]                                ; report address of return value
  ; Epilog
  add rsp, 060h                                                  ; free space for stack
  pop r14                                                        ; restore non-volatile registers
  pop r13                                                        ; restore non-volatile registers
  pop r12                                                        ; restore non-volatile registers
  pop rbp                                                        ; restore non-volatile registers
  pop rdi                                                        ; restore non-volatile registers
  pop rsi                                                        ; restore non-volatile registers
  pop rbx                                                        ; restore non-volatile registers
  pop r15                                                        ; restore non-volatile registers
  ret                                                            ; return from subroutine

; foo
dq func$foo$annotation
func$foo:
  ; Prolog
  push r14                                                       ; save non-volatile registers
  push rbx                                                       ; save non-volatile registers
  push rsi                                                       ; save non-volatile registers
  push rdi                                                       ; save non-volatile registers
  push r12                                                       ; save non-volatile registers
  push rbp                                                       ; save non-volatile registers
  push r13                                                       ; save non-volatile registers
  sub rsp, 020h                                                  ; allocate space for stack
  lea rbp, qword ptr [rsp + 058h]                                ; set up frame pointer
  ; Check parameter count
  cmp rcx, 000h                                                  ; compare parameter count of foo to 0 (integer)
  je func$foo$parameterCountCheck$continuation                   ; check number of parameters is as expected
    ; Error handling block for parameter count
    ;  - print(parameterCountCheckFailureMessage)
    ; Call __print with 1 arguments
    mov r10, offset parameterCountCheckFailureMessage            ; reading parameterCountCheckFailureMessage for push
    push r10                                                     ; value of argument #1 (parameterCountCheckFailureMessage)
    push 01ah                                                    ; type of argument #1 (String'26)
    lea rax, qword ptr [rsp + 020h]                              ; load address of return value's value
    push rax                                                     ; internal argument 6: pointer to return value slot's value
    lea rax, qword ptr [rsp + 020h]                              ; load address of return value's type
    push rax                                                     ; internal argument 5: pointer to return value slot's type
    sub rsp, 020h                                                ; allocate shadow space
    mov r9, 000h                                                 ; internal argument 4: "this" pointer
    mov r8, 000h                                                 ; internal argument 3: "this" pointer type
    mov rdx, 000h                                                ; internal argument 2: closure pointer
    mov qword ptr [rsp + 040h], rcx                              ; move parameter count of foo value out of rcx
    mov rcx, 001h                                                ; internal argument 1: number of actual arguments
    call func$__print                                            ; jump to subroutine
    add rsp, 040h                                                ; release shadow space and arguments (result in stack pointer)
    ;  - exit(1)
    ; Call exit with 1 arguments
    push 001h                                                    ; value of argument #1 (1 (integer))
    push 019h                                                    ; type of argument #1 (Integer'25)
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
  func$foo$parameterCountCheck$continuation:                     ; end of parameter count check
  ; Implicit return from foo
  mov r13, qword ptr [rbp + 030h]                                ; get pointer to return value of foo into register to dereference it
  mov qword ptr [r13], 000h                                      ; foo return value
  mov r14, qword ptr [rbp + 028h]                                ; get pointer to return value type of foo into register to dereference it
  mov qword ptr [r14], 017h                                      ; type of foo return value (Null'23)
  mov rax, qword ptr [rbp + 030h]                                ; report address of return value
  ; Epilog
  add rsp, 020h                                                  ; free space for stack
  pop r13                                                        ; restore non-volatile registers
  pop rbp                                                        ; restore non-volatile registers
  pop r12                                                        ; restore non-volatile registers
  pop rdi                                                        ; restore non-volatile registers
  pop rsi                                                        ; restore non-volatile registers
  pop rbx                                                        ; restore non-volatile registers
  pop r14                                                        ; restore non-volatile registers
  ret                                                            ; return from subroutine
end

