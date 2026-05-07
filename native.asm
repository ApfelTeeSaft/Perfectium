INCLUDE include\master.inc

.const

szNatErr_FNameToString  DB "[NATIVE] FNameToString not found", 0
szNatErr_GObjects       DB "[NATIVE] GObjects not found", 0
szNatErr_Malloc         DB "[NATIVE] FMemory::Malloc not found", 0
szNatErr_Realloc        DB "[NATIVE] FMemory::Realloc not found", 0
szNatErr_Free           DB "[NATIVE] FMemory::Free not found", 0
szNatErr_TickFlush      DB "[NATIVE] NetDriver::TickFlush not found", 0
szNatErr_SpawnPA        DB "[NATIVE] World::SpawnPlayActor not found", 0
szNatErr_WelcomePlayer  DB "[NATIVE] World::WelcomePlayer not found", 0
szNatErr_InitHost       DB "[NATIVE] OnlineBeaconHost::InitHost not found", 0
szNatErr_ProcessEvent   DB "[NATIVE] ProcessEvent vtable resolve failed (null engine)", 0
szNatOk                 DB "[NATIVE] InitializeAll complete", 0

IFDEF DEBUG
szNatDbg_Start          DB "[NATIVE] InitializeAll starting", 0
szNatDbg_FNameToString  DB "[NATIVE] FNameToString found", 0
szNatDbg_GObjects       DB "[NATIVE] GObjects found", 0
szNatDbg_Malloc         DB "[NATIVE] FMemory::Malloc found", 0
szNatDbg_TickFlush      DB "[NATIVE] NetDriver::TickFlush found", 0
szNatDbg_ProcessEvent   DB "[NATIVE] ProcessEvent resolved", 0
ENDIF

.code

; Native_InitializeAll()
; No arguments.  Called once from Main before hooks are installed.
; Returns nothing (void).
Native_InitializeAll PROC
    push    rbp
    push    rbx
    sub     rsp, 40                 ; shadow space; RSP ≡ 0 mod 16 at all CALLs

    LOG_DBG szNatDbg_Start

    xor     ecx, ecx               ; lpModuleName = NULL → returns base of .exe
    call    GetModuleHandleA
    mov     QWORD PTR [Imagebase], rax

    ; FNameToString  (direct, bRelative=0, offset=0)
    lea     rcx, Pat_FNameToString
    xor     edx, edx
    xor     r8d, r8d
    call    Utils_FindPattern
    mov     QWORD PTR [FNameToString], rax
    test    rax, rax
    jz      @@err_FNameToString
    LOG_DBG szNatDbg_FNameToString
    jmp     @@ok_FNameToString
@@err_FNameToString:
    lea     rcx, szNatErr_FNameToString
    call    Logger_LogError
@@ok_FNameToString:

    ; GObjects  (RIP-relative fixup: bRelative=1, offset=3)
    lea     rcx, Pat_GObjects
    mov     edx, 1
    mov     r8d, 3
    call    Utils_FindPattern
    mov     QWORD PTR [GObjects], rax
    test    rax, rax
    jz      @@err_GObjects
    LOG_DBG szNatDbg_GObjects
    jmp     @@ok_GObjects
@@err_GObjects:
    lea     rcx, szNatErr_GObjects
    call    Logger_LogError
@@ok_GObjects:

    ; FMemory::Malloc  (direct)
    lea     rcx, Pat_Malloc
    xor     edx, edx
    xor     r8d, r8d
    call    Utils_FindPattern
    mov     QWORD PTR [FMemory_Malloc], rax
    test    rax, rax
    jz      @@err_Malloc
    LOG_DBG szNatDbg_Malloc
    jmp     @@ok_Malloc
@@err_Malloc:
    lea     rcx, szNatErr_Malloc
    call    Logger_LogError
@@ok_Malloc:

    ; FMemory::Realloc  (direct)
    lea     rcx, Pat_Realloc
    xor     edx, edx
    xor     r8d, r8d
    call    Utils_FindPattern
    mov     QWORD PTR [FMemory_Realloc], rax
    test    rax, rax
    jnz     @@ok_Realloc
    lea     rcx, szNatErr_Realloc
    call    Logger_LogError
@@ok_Realloc:

    ; FMemory::Free  (direct)
    lea     rcx, Pat_Free
    xor     edx, edx
    xor     r8d, r8d
    call    Utils_FindPattern
    mov     QWORD PTR [FMemory_Free], rax
    test    rax, rax
    jnz     @@ok_Free
    lea     rcx, szNatErr_Free
    call    Logger_LogError
@@ok_Free:

    ; NetDriver::TickFlush  (direct)
    lea     rcx, Pat_TickFlush
    xor     edx, edx
    xor     r8d, r8d
    call    Utils_FindPattern
    mov     QWORD PTR [Native_NetDriver_TickFlush], rax
    test    rax, rax
    jz      @@err_TickFlush
    LOG_DBG szNatDbg_TickFlush
    jmp     @@ok_TickFlush
@@err_TickFlush:
    lea     rcx, szNatErr_TickFlush
    call    Logger_LogError
@@ok_TickFlush:

    ; NetDriver::InitListen  (direct)
    lea     rcx, Pat_InitListen
    xor     edx, edx
    xor     r8d, r8d
    call    Utils_FindPattern
    mov     QWORD PTR [Native_NetDriver_InitListen], rax

    ; NetConnection::ReceiveFString  (direct)
    lea     rcx, Pat_ReceiveFString
    xor     edx, edx
    xor     r8d, r8d
    call    Utils_FindPattern
    mov     QWORD PTR [Native_NetConnection_ReceiveFString], rax

    ; NetConnection::ReceiveUniqueIdRepl  (direct)
    lea     rcx, Pat_ReceiveUniqueIdRepl
    xor     edx, edx
    xor     r8d, r8d
    call    Utils_FindPattern
    mov     QWORD PTR [Native_NetConnection_ReceiveUniqueIdRepl], rax

    ; OnlineBeacon::PauseBeaconRequests  (direct)
    lea     rcx, Pat_PauseBeaconRequests
    xor     edx, edx
    xor     r8d, r8d
    call    Utils_FindPattern
    mov     QWORD PTR [Native_OnlineBeacon_PauseBeaconRequests], rax
    ; Also store in the host-specific slot — same function pointer
    mov     QWORD PTR [Native_OnlineBeaconHost_PauseBeaconRequests], rax

    ; OnlineBeacon::NotifyAcceptingConnection  (direct)
    lea     rcx, Pat_BeaconNotifyAccept
    xor     edx, edx
    xor     r8d, r8d
    call    Utils_FindPattern
    mov     QWORD PTR [Native_OnlineBeacon_NotifyAcceptingConnection], rax
    ; Copy into BeaconHost slot as well (same vtable function)
    mov     QWORD PTR [Native_OnlineBeaconHost_NotifyAcceptingConnection], rax

    ; OnlineBeaconHost::InitHost  (direct)
    lea     rcx, Pat_InitHost
    xor     edx, edx
    xor     r8d, r8d
    call    Utils_FindPattern
    mov     QWORD PTR [Native_OnlineBeaconHost_InitHost], rax
    test    rax, rax
    jnz     @@ok_InitHost
    lea     rcx, szNatErr_InitHost
    call    Logger_LogError
@@ok_InitHost:

    ; OnlineBeaconHost::NotifyControlMessage  (direct)
    lea     rcx, Pat_BeaconNotifyCtrl
    xor     edx, edx
    xor     r8d, r8d
    call    Utils_FindPattern
    mov     QWORD PTR [Native_OnlineBeaconHost_NotifyControlMessage], rax

    ; World::SpawnPlayActor  (direct)
    lea     rcx, Pat_SpawnPlayActor
    xor     edx, edx
    xor     r8d, r8d
    call    Utils_FindPattern
    mov     QWORD PTR [Native_World_SpawnPlayActor], rax
    test    rax, rax
    jnz     @@ok_SpawnPA
    lea     rcx, szNatErr_SpawnPA
    call    Logger_LogError
@@ok_SpawnPA:

    ; World::WelcomePlayer  (direct)
    lea     rcx, Pat_WelcomePlayer
    xor     edx, edx
    xor     r8d, r8d
    call    Utils_FindPattern
    mov     QWORD PTR [Native_World_WelcomePlayer], rax
    test    rax, rax
    jnz     @@ok_WelcomePlayer
    lea     rcx, szNatErr_WelcomePlayer
    call    Logger_LogError
@@ok_WelcomePlayer:

    ; World::NotifyControlMessage  (direct)
    lea     rcx, Pat_WorldNotifyCtrl
    xor     edx, edx
    xor     r8d, r8d
    call    Utils_FindPattern
    mov     QWORD PTR [Native_World_NotifyControlMessage], rax

    ; World::NotifyAcceptingConnection  (direct)
    lea     rcx, Pat_WorldNotifyAccept
    xor     edx, edx
    xor     r8d, r8d
    call    Utils_FindPattern
    mov     QWORD PTR [Native_World_NotifyAcceptingConnection], rax

    ; Actor::GetNetMode  (direct)
    lea     rcx, Pat_GetNetMode
    xor     edx, edx
    xor     r8d, r8d
    call    Utils_FindPattern
    mov     QWORD PTR [Native_Actor_GetNetMode], rax

    ; PlayerController::GetPlayerViewPoint  (direct)
    lea     rcx, Pat_GetPlayerViewPoint
    xor     edx, edx
    xor     r8d, r8d
    call    Utils_FindPattern
    mov     QWORD PTR [Native_PlayerController_GetPlayerViewPoint], rax

    ; LocalPlayer::SpawnPlayActor  (direct)
    lea     rcx, Pat_LocalPlayerSpawnPA
    xor     edx, edx
    xor     r8d, r8d
    call    Utils_FindPattern
    mov     QWORD PTR [Native_LocalPlayer_SpawnPlayActor], rax

    ; GiveAbility  (direct)
    lea     rcx, Pat_GiveAbility
    xor     edx, edx
    xor     r8d, r8d
    call    Utils_FindPattern
    mov     QWORD PTR [Native_AbilitySystemComponent_GiveAbility], rax

    ; InternalTryActivateAbility  (direct)
    lea     rcx, Pat_InternalTryActivate
    xor     edx, edx
    xor     r8d, r8d
    call    Utils_FindPattern
    mov     QWORD PTR [Native_AbilitySystemComponent_InternalTryActivateAbility], rax

    ; FindAbilitySpecFromHandle  (direct)
    lea     rcx, Pat_FindAbilitySpecFromHandle
    xor     edx, edx
    xor     r8d, r8d
    call    Utils_FindPattern
    mov     QWORD PTR [Native_AbilitySystemComponent_FindAbilitySpecFromHandle], rax

    ; MarkAbilitySpecDirty  (direct)
    lea     rcx, Pat_MarkAbilitySpecDirty
    xor     edx, edx
    xor     r8d, r8d
    call    Utils_FindPattern
    mov     QWORD PTR [Native_AbilitySystemComponent_MarkAbilitySpecDirty], rax

    ; OnlineSession::KickPlayer  (direct)
    lea     rcx, Pat_KickPlayer
    xor     edx, edx
    xor     r8d, r8d
    call    Utils_FindPattern
    mov     QWORD PTR [Native_OnlineSession_KickPlayer], rax

    ; GameViewportClient::PostRender  (direct)
    lea     rcx, Pat_PostRender
    xor     edx, edx
    xor     r8d, r8d
    call    Utils_FindPattern
    mov     QWORD PTR [Native_GameViewportClient_PostRender], rax

    ; GC::CollectGarbage  (RIP-relative fixup: bRelative=1, offset=1)
    lea     rcx, Pat_CollectGarbage
    mov     edx, 1
    mov     r8d, 1
    call    Utils_FindPattern
    mov     QWORD PTR [Native_GC_CollectGarbage], rax

    call    SDK_GetEngine
    test    rax, rax
    jz      @@err_PE

    mov     rax, QWORD PTR [rax]        ; load vtable pointer from engine object
    mov     rax, QWORD PTR [rax + 200h] ; slot 0x40 (64 * 8 = 0x200)
    mov     QWORD PTR [ProcessEvent], rax
    LOG_DBG szNatDbg_ProcessEvent
    jmp     @@pe_done

@@err_PE:
    lea     rcx, szNatErr_ProcessEvent
    call    Logger_LogError

@@pe_done:

    lea     rcx, szNatOk
    call    Logger_LogInfo

    add     rsp, 40
    pop     rbx
    pop     rbp
    ret
Native_InitializeAll ENDP

END