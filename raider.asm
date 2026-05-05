INCLUDE include\master.inc

; printf from the MSVC CRT (needed for the formatted base-address log line)
EXTRN   printf              :PROC

.const

szWelcome       DB  "Welcome to Raider!", 0
szInitHooks     DB  "Initializing hooks!", 0
szFailNetDebug  DB  "Failed to find NetDebug", 0
szBaseAddrFmt   DB  "[INFO]  Base Address: 0x%I64X", 0Ah, 0

.data


.code

; Main — worker thread entry point
;   RCX = lpParam (hModule passed from DllMain; not used inside Main)
;
; Stack frame layout (after prologue):
;   [rbp+ 0] = saved rbp
;   ---- 48 bytes sub rsp ----
;   [rbp-  8] = local: NetDebug function pointer (8 bytes)
;   [rbp- 16] = alignment pad   (8 bytes)
;   [rbp- 48] … [rbp-17] = 32-byte shadow space for callees ([rsp+0..31])
Main PROC
    push    rbp
    mov     rbp, rsp
    sub     rsp, 48                         ; shadow(32) + local_NetDebug(8) + pad(8)

    ; initialise local NetDebug function pointer to NULL
    mov     QWORD PTR [rbp - 8], 0

    call    AllocConsole

    call    Logger_Initialize

    lea     rcx, szWelcome
    call    Logger_LogInfo

    lea     rcx, szInitHooks
    call    Logger_LogInfo

    call    Native_InitializeAll

    call    UFunctionHooks_Initialize

    call    DetourTransactionBegin

    call    GetCurrentThread
    mov     rcx, rax
    call    DetourUpdateThread

    lea     rcx, Native_NetDriver_TickFlush
    lea     rdx, Hooks_TickFlush
    call    DetourAttach

    lea     rcx, Native_LocalPlayer_SpawnPlayActor
    lea     rdx, Hooks_LocalPlayerSpawnPlayActor
    call    DetourAttach

    lea     rcx, Pat_NetDebug
    xor     edx, edx                        ; bRelative = false
    xor     r8d, r8d                        ; offset = 0
    call    Utils_FindPattern

    test    rax, rax
    jnz     @@netdebug_found

    lea     rcx, szFailNetDebug
    call    Logger_LogError
    xor     eax, eax                        ; return 0 (thread exit)
    jmp     @@main_exit

@@netdebug_found:
    ; NetDebug = (void*(*)(void*))Address
    mov     QWORD PTR [rbp - 8], rax

    lea     rcx, QWORD PTR [rbp - 8]
    lea     rdx, Hooks_NetDebug
    call    DetourAttach

    lea     rcx, ProcessEvent
    lea     rdx, Hooks_ProcessEventHook
    call    DetourAttach

    lea     rcx, Native_PlayerController_GetPlayerViewPoint
    lea     rdx, Hooks_GetPlayerViewPoint
    call    DetourAttach

    call    DetourTransactionCommit

    lea     rcx, szBaseAddrFmt
    mov     rdx, QWORD PTR [Imagebase]
    call    printf

    call    SDK_CreateConsole

    xor     eax, eax                        ; return 0 (DWORD thread exit code)

@@main_exit:
    mov     rsp, rbp
    pop     rbp
    ret
Main ENDP

; DllMain — DLL entry point
;   RCX = hModule (HMODULE)
;   EDX = dwReason (DWORD)
;   R8  = lpReserved (LPVOID)
;
; Stack frame layout (after prologue):
;   [rsp+48] = return address           <- above frame
;   [rsp+40] = saved rbx
;   [rsp+32] = saved rbp                <- standard frame base
;   [rsp+ 0] = our frame (56 bytes total):
;       [rsp+48] = CreateThread arg6 (lpThreadId = NULL)
;       [rsp+40] = CreateThread arg5 (dwCreationFlags = 0)
;       [rsp+ 0]..[rsp+31] = shadow space for callees
DllMain PROC
    push    rbp
    push    rbx                             ; callee-saved; corrects alignment
    sub     rsp, 56                         ; shadow(32) + arg5(8) + arg6(8) + pad(8)

    ; save hModule (RCX) for use as CreateThread lpParameter
    mov     rbx, rcx                        ; rbx = hModule, preserved across calls

    cmp     edx, DLL_PROCESS_ATTACH
    jne     @@dllmain_done

    ; CreateThread(NULL, 0, Main, hModule, 0, NULL)
    ;   arg1 RCX  = lpThreadAttributes = NULL
    ;   arg2 RDX  = dwStackSize        = 0
    ;   arg3 R8   = lpStartAddress     = Main
    ;   arg4 R9   = lpParameter        = hModule
    ;   arg5 [rsp+32] = dwCreationFlags  = 0
    ;   arg6 [rsp+40] = lpThreadId       = NULL
    xor     ecx, ecx                        ; NULL
    xor     edx, edx                        ; 0
    lea     r8,  Main                       ; Main thread proc
    mov     r9,  rbx                        ; hModule as lpParam
    xor     eax, eax
    mov     QWORD PTR [rsp + 32], rax       ; dwCreationFlags = 0
    mov     QWORD PTR [rsp + 40], rax       ; lpThreadId = NULL
    call    CreateThread

@@dllmain_done:
    mov     eax, 1                          ; return TRUE

    add     rsp, 56
    pop     rbx
    pop     rbp
    ret
DllMain ENDP

END