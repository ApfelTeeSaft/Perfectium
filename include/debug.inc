IFDEF DEBUG

EXTERNDEF Logger_LogInfo  :PROC
EXTERNDEF Logger_LogWarn  :PROC
EXTERNDEF Logger_LogError :PROC

LOG_DBG MACRO sym
    lea     rcx, sym
    call    Logger_LogInfo
ENDM

LOG_WARN MACRO sym
    lea     rcx, sym
    call    Logger_LogWarn
ENDM

LOG_ERR MACRO sym
    lea     rcx, sym
    call    Logger_LogError
ENDM

ELSE    ; Release - all macros are empty

LOG_DBG  MACRO sym
ENDM

LOG_WARN MACRO sym
ENDM

LOG_ERR  MACRO sym
ENDM

ENDIF