INCLUDE include\master.inc

IFDEF DEBUG

EXTRN   printf              :PROC
EXTRN   GetLocalTime        :PROC
EXTRN   GetModuleFileNameA  :PROC
EXTRN   CreateFileA         :PROC
EXTRN   WriteFile           :PROC
EXTRN   CloseHandle         :PROC
EXTRN   FlushFileBuffers    :PROC
EXTRN   wsprintfA           :PROC

; Win32 constants
GENERIC_WRITE           EQU 40000000h
FILE_SHARE_READ         EQU 00000001h
CREATE_ALWAYS           EQU 00000002h
FILE_ATTRIBUTE_NORMAL   EQU 00000080h

; SYSTEMTIME field byte offsets
ST_wHour            EQU 8
ST_wMinute          EQU 0Ah
ST_wSecond          EQU 0Ch
ST_wMilliseconds    EQU 0Eh

.const

szFmtInfo   DB "[INFO]  [%02d:%02d:%02d.%03d] %s", 0Ah, 0
szFmtWarn   DB "[WARN]  [%02d:%02d:%02d.%03d] %s", 0Ah, 0
szFmtError  DB "[ERROR] [%02d:%02d:%02d.%03d] %s", 0Ah, 0
szFmtFatal  DB "[FATAL] [%02d:%02d:%02d.%03d] %s", 0Ah, 0

.data?

Logger_hFile    QWORD   ?

.code

; Logger_Initialize
; Builds a log path by taking the host EXE directory (via
; GetModuleFileNameA(NULL,...)) and appending "raider_debug.txt",
; then opens that file with CREATE_ALWAYS.  Using the EXE directory
;
; Frame: 0 pushes + sub 148h = 328; 328 mod 16 = 8; RSP = 0 
;   [rsp+000..+01F] shadow (32)
;   [rsp+020..+027] CreateFileA 5th arg: dwCreationDisposition
;   [rsp+028..+02F] CreateFileA 6th arg: dwFlagsAndAttributes
;   [rsp+030..+037] CreateFileA 7th arg: hTemplateFile
;   [rsp+038..+13B] path buffer  (260 bytes, MAX_PATH)
;   [rsp+13C..+147] padding      (12 bytes)
Logger_Initialize PROC
    sub     rsp, 148h

    ; GetModuleFileNameA(NULL, &path, MAX_PATH) → EAX = length
    xor     ecx, ecx                        ; hModule = NULL → host EXE
    lea     rdx, [rsp+38h]                  ; path buffer
    mov     r8d, 104h                       ; MAX_PATH = 260
    call    GetModuleFileNameA
    test    eax, eax
    jz      @@done                          ; failed, skip file logging

    ; Scan backward from end of path to find last '\'
    lea     rcx, [rsp+38h]                  ; rcx = buf start
    add     rax, rcx                        ; rax = &buf[len] (null terminator)
@@find_slash:
    dec     rax
    cmp     rax, rcx
    jb      @@done                          ; no backslash found, give up
    cmp     BYTE PTR [rax], '\'
    jne     @@find_slash

    ; rax = pointer to last '\'; write filename starting at rax+1
    inc     rax
    mov     BYTE PTR [rax+ 0], 'r'
    mov     BYTE PTR [rax+ 1], 'a'
    mov     BYTE PTR [rax+ 2], 'i'
    mov     BYTE PTR [rax+ 3], 'd'
    mov     BYTE PTR [rax+ 4], 'e'
    mov     BYTE PTR [rax+ 5], 'r'
    mov     BYTE PTR [rax+ 6], '_'
    mov     BYTE PTR [rax+ 7], 'd'
    mov     BYTE PTR [rax+ 8], 'e'
    mov     BYTE PTR [rax+ 9], 'b'
    mov     BYTE PTR [rax+10], 'u'
    mov     BYTE PTR [rax+11], 'g'
    mov     BYTE PTR [rax+12], '.'
    mov     BYTE PTR [rax+13], 't'
    mov     BYTE PTR [rax+14], 'x'
    mov     BYTE PTR [rax+15], 't'
    mov     BYTE PTR [rax+16], 0

    ; CreateFileA(&path, GENERIC_WRITE, FILE_SHARE_READ, NULL,
    ;             CREATE_ALWAYS, FILE_ATTRIBUTE_NORMAL, NULL)
    lea     rcx, [rsp+38h]
    mov     edx, GENERIC_WRITE
    mov     r8d, FILE_SHARE_READ
    xor     r9d, r9d                        ; lpSecurityAttributes = NULL
    mov     DWORD PTR [rsp+20h], CREATE_ALWAYS
    mov     DWORD PTR [rsp+28h], FILE_ATTRIBUTE_NORMAL
    mov     QWORD PTR [rsp+30h], 0          ; hTemplateFile = NULL
    call    CreateFileA
    mov     QWORD PTR [Logger_hFile], rax   ; INVALID_HANDLE_VALUE if open failed

@@done:
    add     rsp, 148h
    ret
Logger_Initialize ENDP


; Logger_Shutdown
; Closes the log file handle.
;
; Frame: 0 pushes + sub 28h = 40; 40 mod 16 = 8; RSP = 0 
Logger_Shutdown PROC
    sub     rsp, 28h

    mov     rcx, QWORD PTR [Logger_hFile]
    test    rcx, rcx
    jz      @@done
    cmp     rcx, -1                         ; INVALID_HANDLE_VALUE
    je      @@done
    call    CloseHandle
    mov     QWORD PTR [Logger_hFile], 0

@@done:
    add     rsp, 28h
    ret
Logger_Shutdown ENDP


; Logger__Print  (internal)
; Writes a timestamped log line to the console (printf) and,
; if the file handle is valid, also to raider_debug.txt with
; an immediate FlushFileBuffers so no data is lost on crash.
;
; In:  RCX = format string*  (one of szFmtInfo/Warn/Error/Fatal)
;      RDX = message string*
;
; Frame: 0 pushes + sub 268h = 616; 616 mod 16 = 8; RSP = 0 
;
;   [rsp+000..+01F]  shadow space (32)
;   [rsp+020..+027]  printf/wsprintfA 5th arg slot  (ms / S)
;   [rsp+028..+02F]  printf/wsprintfA 6th arg slot  (msg* / ms)
;   [rsp+030..+03F]  SYSTEMTIME struct (16); later reused as wsprintfA 7th arg
;   [rsp+040..+047]  saved msg*
;   [rsp+048..+04F]  saved fmt*
;   [rsp+050..+05F]  spare (16)
;   [rsp+060..+25F]  szLine[512] - wsprintfA output buffer
;   [rsp+260..+263]  dwWritten (DWORD for WriteFile)
;   [rsp+264..+267]  pad
Logger__Print PROC
    sub     rsp, 268h

    mov     QWORD PTR [rsp+40h], rdx        ; save msg*
    mov     QWORD PTR [rsp+48h], rcx        ; save fmt*

    ; GetLocalTime
    lea     rcx, [rsp+30h]
    call    GetLocalTime

    ; Console: printf(fmt, H, M, S, ms, msg)
    mov     rcx, QWORD PTR [rsp+48h]
    movzx   edx, WORD PTR [rsp+30h + ST_wHour]
    movzx   r8d, WORD PTR [rsp+30h + ST_wMinute]
    movzx   r9d, WORD PTR [rsp+30h + ST_wSecond]
    movzx   eax, WORD PTR [rsp+30h + ST_wMilliseconds]
    mov     DWORD PTR [rsp+20h], eax        ; 5th arg: ms
    mov     rax, QWORD PTR [rsp+40h]
    mov     QWORD PTR [rsp+28h], rax        ; 6th arg: msg*
    call    printf

    ; File: skip if handle invalid
    mov     rcx, QWORD PTR [Logger_hFile]
    test    rcx, rcx
    jz      @@skip_file
    cmp     rcx, -1                         ; INVALID_HANDLE_VALUE
    je      @@skip_file

    ; wsprintfA(szLine, fmt, H, M, S, ms, msg)
    ; SYSTEMTIME is still valid at [rsp+30h]; fmt* and msg* saved above.
    lea     rcx, [rsp+60h]                  ; arg1: dest buffer
    mov     rdx, QWORD PTR [rsp+48h]        ; arg2: fmt*
    movzx   r8d, WORD PTR [rsp+30h + ST_wHour]   ; arg3: H
    movzx   r9d, WORD PTR [rsp+30h + ST_wMinute]  ; arg4: M
    movzx   eax, WORD PTR [rsp+30h + ST_wSecond]
    mov     QWORD PTR [rsp+20h], rax        ; arg5: S
    movzx   eax, WORD PTR [rsp+30h + ST_wMilliseconds]
    mov     QWORD PTR [rsp+28h], rax        ; arg6: ms
    mov     rax, QWORD PTR [rsp+40h]
    mov     QWORD PTR [rsp+30h], rax        ; arg7: msg* (overwrites SYSTEMTIME - done with it)
    call    wsprintfA                       ; EAX = chars written
    test    eax, eax
    jle     @@skip_file

    ; WriteFile(hFile, szLine, chars, &dwWritten, NULL)
    mov     r10d, eax                       ; save char count
    mov     rcx, QWORD PTR [Logger_hFile]
    lea     rdx, [rsp+60h]                  ; szLine buffer
    mov     r8d, r10d                       ; byte count
    lea     r9, [rsp+260h]                  ; &dwWritten
    mov     QWORD PTR [rsp+20h], 0          ; lpOverlapped = NULL
    call    WriteFile

    ; FlushFileBuffers - ensures data reaches disk before any crash
    mov     rcx, QWORD PTR [Logger_hFile]
    call    FlushFileBuffers

@@skip_file:
    add     rsp, 268h
    ret
Logger__Print ENDP


; Logger_LogInfo / LogWarn / LogError / LogFatal
; Frame: 0 pushes + sub 28h = 40; RSP = 0 
Logger_LogInfo PROC
    sub     rsp, 28h
    mov     rdx, rcx
    lea     rcx, [szFmtInfo]
    call    Logger__Print
    add     rsp, 28h
    ret
Logger_LogInfo ENDP

Logger_LogWarn PROC
    sub     rsp, 28h
    mov     rdx, rcx
    lea     rcx, [szFmtWarn]
    call    Logger__Print
    add     rsp, 28h
    ret
Logger_LogWarn ENDP

Logger_LogError PROC
    sub     rsp, 28h
    mov     rdx, rcx
    lea     rcx, [szFmtError]
    call    Logger__Print
    add     rsp, 28h
    ret
Logger_LogError ENDP

Logger_LogFatal PROC
    sub     rsp, 28h
    mov     rdx, rcx
    lea     rcx, [szFmtFatal]
    call    Logger__Print
    add     rsp, 28h
    ret
Logger_LogFatal ENDP


; Logger_LogInfoFmt(RCX=fmt*, RDX/R8/R9/stack=args)
; Console-only printf passthrough (variadic - can't redirect to file).
; Frame: 0 pushes + sub 28h; RSP = 0 
Logger_LogInfoFmt PROC
    sub     rsp, 28h
    call    printf
    add     rsp, 28h
    ret
Logger_LogInfoFmt ENDP

ELSE    ; Release build - all logger functions are single-instruction stubs

.code

Logger_Initialize PROC
    ret
Logger_Initialize ENDP

Logger_Shutdown PROC
    ret
Logger_Shutdown ENDP

Logger_LogInfo PROC
    ret
Logger_LogInfo ENDP

Logger_LogWarn PROC
    ret
Logger_LogWarn ENDP

Logger_LogError PROC
    ret
Logger_LogError ENDP

Logger_LogFatal PROC
    ret
Logger_LogFatal ENDP

Logger_LogInfoFmt PROC
    ret
Logger_LogInfoFmt ENDP

ENDIF

END