INCLUDE include\master.inc

EXTRN   printf      :PROC
EXTRN   GetLocalTime :PROC   ; VOID WINAPI GetLocalTime(LPSYSTEMTIME)

; SYSTEMTIME field byte offsets
ST_wHour            EQU 8
ST_wMinute          EQU 0Ah
ST_wSecond          EQU 0Ch
ST_wMilliseconds    EQU 0Eh

.const

; Printf format strings - [LEVEL] [HH:MM:SS.mmm] message\n
; 5 integer placeholders: H(%02d), M(%02d), S(%02d), ms(%03d), msg(%s)
szFmtInfo   DB "[INFO]  [%02d:%02d:%02d.%03d] %s", 0Ah, 0
szFmtWarn   DB "[WARN]  [%02d:%02d:%02d.%03d] %s", 0Ah, 0
szFmtError  DB "[ERROR] [%02d:%02d:%02d.%03d] %s", 0Ah, 0
szFmtFatal  DB "[FATAL] [%02d:%02d:%02d.%03d] %s", 0Ah, 0

.code

; Logger_Initialize()
; No-op: the console is already open after AllocConsole() in Main.
Logger_Initialize PROC
    ret
Logger_Initialize ENDP


; Logger_Shutdown()
; No-op: nothing to clean up in a printf-based logger.
Logger_Shutdown PROC
    ret
Logger_Shutdown ENDP


; Logger__Print  (internal)
; Reads current local time and calls printf with the log line.
;
; In:  RCX = format string* (szFmtInfo / szFmtWarn / ...)
;      RDX = message string* (const char*)
;
; Frame: 0 pushes + sub 58h -> RSP = 8-88 = -80 = 0 
;   [rsp+0..+1F]    = shadow for GetLocalTime / printf
;   [rsp+20h..+27h] = 5th printf arg: ms (DWORD in QWORD slot)
;   [rsp+28h..+2Fh] = 6th printf arg: msg* (QWORD)
;   [rsp+30h..+3Fh] = SYSTEMTIME struct (16 bytes)
;   [rsp+40h..+47h] = saved msg*
;   [rsp+48h..+4Fh] = saved fmt*
;   [rsp+50h..+57h] = spare
Logger__Print PROC
    sub     rsp, 58h

    mov     QWORD PTR [rsp+40h], rdx    ; save msg*
    mov     QWORD PTR [rsp+48h], rcx    ; save fmt*

    ; GetLocalTime(&SYSTEMTIME at [rsp+30h])
    lea     rcx, [rsp+30h]
    call    GetLocalTime

    ; Restore fmt* -> RCX for printf
    mov     rcx, QWORD PTR [rsp+48h]

    ; Extract time fields: H->RDX, M->R8, S->R9, ms->[rsp+20h]
    movzx   edx, WORD PTR [rsp+30h + ST_wHour]
    movzx   r8d, WORD PTR [rsp+30h + ST_wMinute]
    movzx   r9d, WORD PTR [rsp+30h + ST_wSecond]
    movzx   eax, WORD PTR [rsp+30h + ST_wMilliseconds]
    mov     DWORD PTR [rsp+20h], eax    ; 5th arg: ms

    ; msg* -> [rsp+28h]
    mov     rax, QWORD PTR [rsp+40h]
    mov     QWORD PTR [rsp+28h], rax    ; 6th arg: msg*

    call    printf

    add     rsp, 58h
    ret
Logger__Print ENDP


; Logger_LogInfo(RCX=msg*)
; Frame: 0 pushes + sub 28h -> RSP = 8-40 = -32 = 0 
Logger_LogInfo PROC
    sub     rsp, 28h
    mov     rdx, rcx                    ; rdx = msg*
    lea     rcx, [szFmtInfo]
    call    Logger__Print
    add     rsp, 28h
    ret
Logger_LogInfo ENDP


; Logger_LogWarn(RCX=msg*)
Logger_LogWarn PROC
    sub     rsp, 28h
    mov     rdx, rcx
    lea     rcx, [szFmtWarn]
    call    Logger__Print
    add     rsp, 28h
    ret
Logger_LogWarn ENDP


; Logger_LogError(RCX=msg*)
Logger_LogError PROC
    sub     rsp, 28h
    mov     rdx, rcx
    lea     rcx, [szFmtError]
    call    Logger__Print
    add     rsp, 28h
    ret
Logger_LogError ENDP


; Logger_LogFatal(RCX=msg*)
Logger_LogFatal PROC
    sub     rsp, 28h
    mov     rdx, rcx
    lea     rcx, [szFmtFatal]
    call    Logger__Print
    add     rsp, 28h
    ret
Logger_LogFatal ENDP


; Logger_LogInfoFmt(RCX=fmt*, RDX/R8/R9/[rsp+20h+]=args)
; Direct printf passthrough.  The caller provides the format
; string (including any level prefix) and all format arguments.
; RCX/RDX/R8/R9 and stack args pass through unchanged.
;
; Frame: 0 pushes + sub 28h -> RSP = 0 
Logger_LogInfoFmt PROC
    sub     rsp, 28h
    call    printf
    add     rsp, 28h
    ret
Logger_LogInfoFmt ENDP

END