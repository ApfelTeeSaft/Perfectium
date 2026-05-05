SHADOW_SPACE    EQU     32      ; 4 * 8 bytes

STACK_ALIGN_SIZE EQU    16

PROC_ENTER MACRO local_bytes:=<0>
    push    rbp
    mov     rbp, rsp
    ; Compute sub rsp amount:  round_up(local_bytes + SHADOW_SPACE, 16)
    ; If (local_bytes + SHADOW_SPACE) mod 16 == 0, already aligned
    ; (push rbp above biased by 8; a further sub rsp of a multiple of 16
    ;  keeps alignment correct because entry RSP was already 8-mod-16).
    LOCAL _lsz
    _lsz = local_bytes + SHADOW_SPACE
    IF (_lsz MOD 16) NE 0
        _lsz = _lsz + (16 - (_lsz MOD 16))
    ENDIF
    sub     rsp, _lsz
ENDM

;  Restores RSP from RBP, pops RBP, returns.
;  Caller must pop any callee-saved registers BEFORE invoking this.
PROC_LEAVE MACRO
    mov     rsp, rbp
    pop     rbp
    ret
ENDM

PROC_ENTER_REGS MACRO regs:VARARG
    FOR reg, <regs>
        push    reg
    ENDM
ENDM

PROC_LEAVE_REGS MACRO regs:VARARG
    FOR reg, <regs>
        pop     reg
    ENDM
ENDM

CALL_SETUP MACRO extra_stack_qwords:=<0>
    LOCAL _extra
    _extra = extra_stack_qwords * 8
    IF (_extra MOD 16) NE 0
        _extra = _extra + 8     ; pad to 16-byte alignment
    ENDIF
    sub     rsp, SHADOW_SPACE + _extra
ENDM

; Restore RSP after a call that used CALL_SETUP.
CALL_TEARDOWN MACRO extra_stack_qwords:=<0>
    LOCAL _extra
    _extra = extra_stack_qwords * 8
    IF (_extra MOD 16) NE 0
        _extra = _extra + 8
    ENDIF
    add     rsp, SHADOW_SPACE + _extra
ENDM

NULL_CHECK MACRO reg, label
    test    reg, reg
    jz      label
ENDM

CheckNullFatal_M MACRO reg, msg_reg, fatal_label
    test    reg, reg
    jnz     @F
    lea     msg_reg, [fatal_label&_str]   ; caller defines label&_str in .const
    jmp     fatal_label
    @@:
ENDM

CheckNullFatalStr_M MACRO reg, str_sym, fatal_label
    test    reg, reg
    jnz     @F
    lea     rcx, str_sym
    jmp     fatal_label
    @@:
ENDM

DETOUR_START_M MACRO
    sub     rsp, SHADOW_SPACE
    call    DetourTransactionBegin
    ; ignore return value (always S_OK in normal use)
    mov     rcx, DETOUR_ALL_THREADS   ; -1 = all threads
    call    DetourUpdateThread
    add     rsp, SHADOW_SPACE
ENDM

; sentinel for "all threads" passed to DetourUpdateThread
DETOUR_ALL_THREADS EQU -1

DETOUR_END_M MACRO
    sub     rsp, SHADOW_SPACE
    call    DetourTransactionCommit
    add     rsp, SHADOW_SPACE
ENDM

DetourAttachM MACRO ppOriginal, pHook
    sub     rsp, SHADOW_SPACE
    lea     rcx, ppOriginal
    lea     rdx, pHook
    call    DetourAttach
    add     rsp, SHADOW_SPACE
ENDM

DetourDetachM MACRO ppOriginal, pHook
    sub     rsp, SHADOW_SPACE
    lea     rcx, ppOriginal
    lea     rdx, pHook
    call    DetourDetach
    add     rsp, SHADOW_SPACE
ENDM

AddressToFunction_M MACRO result_reg, base_reg, offset
    mov     result_reg, base_reg
    add     result_reg, offset
ENDM

VtableCall_M MACRO obj_reg, slot, scratch_reg
    mov     scratch_reg, [obj_reg]          ; vtable ptr
    call    QWORD PTR [scratch_reg + (slot)*8]
ENDM

LOG_INFO_M MACRO fmt_sym
    sub     rsp, SHADOW_SPACE
    lea     rcx, fmt_sym
    call    Logger_LogInfo
    add     rsp, SHADOW_SPACE
ENDM

LOG_WARN_M MACRO fmt_sym
    sub     rsp, SHADOW_SPACE
    lea     rcx, fmt_sym
    call    Logger_LogWarn
    add     rsp, SHADOW_SPACE
ENDM

LOG_ERROR_M MACRO fmt_sym
    sub     rsp, SHADOW_SPACE
    lea     rcx, fmt_sym
    call    Logger_LogError
    add     rsp, SHADOW_SPACE
ENDM

FIND_PATTERN_M MACRO result_reg, pattern_sym, bRelative, offset_val
    lea     rcx, pattern_sym
    mov     edx, bRelative
    mov     r8d, offset_val
    call    Utils_FindPattern
    mov     result_reg, rax
ENDM

RESOLVE_RIP_M MACRO result_reg, addr_reg
    movsxd  result_reg, DWORD PTR [addr_reg + 1]   ; sign-extend rel32
    add     result_reg, addr_reg
    add     result_reg, 5                            ; + size of call instruction
ENDM

SAVE_NONVOL_4 MACRO r0, r1, r2, r3
    push    r0
    push    r1
    push    r2
    push    r3
ENDM

RESTORE_NONVOL_4 MACRO r3, r2, r1, r0
    pop     r3
    pop     r2
    pop     r1
    pop     r0
ENDM

STORE_ARG_RCX MACRO
    mov     [rsp + 8],  rcx
ENDM
STORE_ARG_RDX MACRO
    mov     [rsp + 16], rdx
ENDM
STORE_ARG_R8 MACRO
    mov     [rsp + 24], r8
ENDM
STORE_ARG_R9 MACRO
    mov     [rsp + 32], r9
ENDM

BOOL_TRUE MACRO
    mov     eax, 1
ENDM
BOOL_FALSE MACRO
    xor     eax, eax
ENDM

ZERO_REG MACRO reg
    xor     reg, reg
ENDM

LOAD_QWORD_PTR MACRO dst, sym
    mov     dst, QWORD PTR [sym]
ENDM

STORE_QWORD_PTR MACRO sym, src
    mov     QWORD PTR [sym], src
ENDM

DEFINE_PEHOOK_M MACRO hook_name, ufunction_sym
    hook_name LABEL NEAR
    ; RCX = UObject* (caller object)
    ; RDX = UFunction*
    ; R8  = void* (params struct)
ENDM
