INCLUDE include\master.inc

; CRT printf
EXTRN   printf  :PROC

.const

szFmtInfo       DB  "[INFO]  %s", 0Ah, 0
szFmtWarn       DB  "[WARN]  %s", 0Ah, 0
szFmtError      DB  "[ERROR] %s", 0Ah, 0

.code

; Logger_Initialize()
; Sets up the logger.  With printf-based output the console is
; already usable after AllocConsole(); nothing extra is required.
; Kept as a callable stub so call sites from raider.asm compile.
Logger_Initialize PROC
    ret
Logger_Initialize ENDP

Logger_LogInfo PROC
    ; Entry: RSP = 8 mod 16  (return address pushed on aligned stack)
    push    rbp
    mov     rbp, rsp
    sub     rsp, 32             ; shadow space; push rbp -> RSP = 0 mod 16; sub 32 -> 0 

    ; printf(szFmtInfo, msg)
    mov     rdx, rcx            ; arg2 = msg
    lea     rcx, szFmtInfo      ; arg1 = format
    call    printf

    mov     rsp, rbp
    pop     rbp
    ret
Logger_LogInfo ENDP

Logger_LogWarn PROC
    push    rbp
    mov     rbp, rsp
    sub     rsp, 32

    mov     rdx, rcx
    lea     rcx, szFmtWarn
    call    printf

    mov     rsp, rbp
    pop     rbp
    ret
Logger_LogWarn ENDP

Logger_LogError PROC
    push    rbp
    mov     rbp, rsp
    sub     rsp, 32

    mov     rdx, rcx
    lea     rcx, szFmtError
    call    printf

    mov     rsp, rbp
    pop     rbp
    ret
Logger_LogError ENDP

Logger_LogInfoFmt PROC
    push    rbp
    mov     rbp, rsp
    sub     rsp, 32
    ; RCX, RDX, R8, R9 pass through as-is to printf
    call    printf
    mov     rsp, rbp
    pop     rbp
    ret
Logger_LogInfoFmt ENDP

END