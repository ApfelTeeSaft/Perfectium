INCLUDE include\master.inc

; Local offset supplements
APLAYER_CurrentNetSpeed         EQU 038h
UNETCONN_InternalAck            EQU 0C8h    ; bool
AFPCA_OverriddenBackpackSize    EQU 0720h

.data?

pFn_PlayButton      QWORD   ?   ; cached UFunction* for ReadyToStartMatch
pFn_ServerCheat     QWORD   ?   ; unused in non-CHEATS build; kept for ABI compat

.const

szPlayButtonFn  DB "Function FortniteGame.FortGameModeAthena.ReadyToStartMatch", 0

.code

; Hooks_NetDebug(UObject* self) -> UObject* (always nullptr)
; Replaces the debug logging function; returns null to suppress output.
Hooks_NetDebug PROC
    xor     eax, eax
    ret
Hooks_NetDebug ENDP

; Hooks_CollectGarbage(__int64 a1) -> __int64
; Suppresses GC during match to prevent actor deletion bugs.
Hooks_CollectGarbage PROC
    xor     eax, eax
    ret
Hooks_CollectGarbage ENDP

; Hooks_GetNetMode(UWorld* World) -> int (ENetMode)
; Returns NM_ListenServer (2) so the engine treats this as a listen server.
Hooks_GetNetMode PROC
    mov     eax, ENetMode_ListenServer  ; 2
    ret
Hooks_GetNetMode ENDP

; Hooks_KickPlayer(__int64 Session, __int64 PC, __int64 Reason) -> char
; Blocks all kick requests (returns 0 = no-op).
Hooks_KickPlayer PROC
    xor     eax, eax
    ret
Hooks_KickPlayer ENDP

; Hooks_LocalPlayerSpawnPlayActor - tail-call or early return
; void* Hooks_LocalPlayerSpawnPlayActor(ULocalPlayer*, FString*, FString*, UWorld*)
; If not yet traveled: tail-call original (all regs untouched).
; If already traveled: return 1 (suppress duplicate actor spawns).
;
; Stack: no frame - either ret-1 or jmp to original (tail call).
Hooks_LocalPlayerSpawnPlayActor PROC
    movzx   eax, BYTE PTR [bTraveled]
    test    al, al
    jnz     @@already_traveled

    ; Not traveled yet - forward all args unchanged via tail call
    jmp     QWORD PTR [Native_LocalPlayer_SpawnPlayActor]

@@already_traveled:
    mov     eax, 1
    ret
Hooks_LocalPlayerSpawnPlayActor ENDP

; Hooks_WelcomePlayer(UWorld*, UNetConnection*)
; Redirects to GetWorld() + Native call.
; Args: RCX=UWorld* (ignored), RDX=UNetConnection*
;
; Stack: push rbp + push rbx = 2 pushes (RSP=8->RSP=8 after 2×8); sub 40(=8) -> 0 
Hooks_WelcomePlayer PROC
    push    rbp
    push    rbx
    sub     rsp, 40                 ; 2 pushes: RSP=8; sub40(=8) -> 0 

    mov     rbx, rdx                ; rbx = Connection

    call    SDK_GetWorld
    test    rax, rax
    jz      @@done

    mov     rcx, rax                ; World
    mov     rdx, rbx                ; Connection
    call    QWORD PTR [Native_World_WelcomePlayer]

@@done:
    add     rsp, 40
    pop     rbx
    pop     rbp
    ret
Hooks_WelcomePlayer ENDP

; Hooks_World_NotifyControlMessage(UWorld*, UNetConnection*, uint8, void*)
; Replaces world arg with GetWorld(); passes remaining args through.
; Args: RCX=UWorld*, RDX=Connection, R8B=MsgType, R9=Bunch
;
; Stack: push rbp,rbx,rsi,rdi = 4 pushes (RSP=8->RSP=8after4x8);
;        sub 40(=8) -> 0 
Hooks_World_NotifyControlMessage PROC
    push    rbp
    push    rbx
    push    rsi
    push    rdi
    sub     rsp, 40                 ; 4 pushes: RSP=8; sub40 -> 0 

    mov     rbx, rdx                ; Connection
    movzx   esi, r8b                ; MsgType (zero-extended)
    mov     rdi, r9                 ; Bunch

    call    SDK_GetWorld
    test    rax, rax
    jz      @@done

    mov     rcx, rax
    mov     rdx, rbx
    mov     r8d, esi
    mov     r9, rdi
    call    QWORD PTR [Native_World_NotifyControlMessage]

@@done:
    add     rsp, 40
    pop     rdi
    pop     rsi
    pop     rbx
    pop     rbp
    ret
Hooks_World_NotifyControlMessage ENDP

; Hooks_Beacon_NotifyAcceptingConnection(AOnlineBeacon*) -> uint8
; Beacon is accepting a new peer - forward to World's handler.
; Args: RCX = AOnlineBeacon*
;
; Stack: push rbp + push rbx = 2 pushes; sub 40 -> 0 
Hooks_Beacon_NotifyAcceptingConnection PROC
    push    rbp
    push    rbx
    sub     rsp, 40                 ; 2 pushes: RSP=8; sub40 -> 0 

    call    SDK_GetWorld
    test    rax, rax
    jz      @@ret_zero

    mov     rcx, rax
    call    QWORD PTR [Native_World_NotifyAcceptingConnection]
    jmp     @@done

@@ret_zero:
    xor     eax, eax

@@done:
    add     rsp, 40
    pop     rbx
    pop     rbp
    ret
Hooks_Beacon_NotifyAcceptingConnection ENDP

; Hooks_SeamlessTravelHandlerForWorld(UEngine*, UWorld*)
; Args: RCX=Engine, RDX=UWorld* (ignored - use GetWorld())
;
; Stack: push rbp + push rbx = 2 pushes; sub 40 -> 0 
Hooks_SeamlessTravelHandlerForWorld PROC
    push    rbp
    push    rbx
    sub     rsp, 40                 ; 2 pushes; sub 40 -> 0 

    mov     rbx, rcx                ; Engine

    call    SDK_GetWorld
    test    rax, rax
    jz      @@done

    mov     rcx, rbx
    mov     rdx, rax
    call    QWORD PTR [Native_Engine_SeamlessTravelHandlerForWorld]

@@done:
    add     rsp, 40
    pop     rbx
    pop     rbp
    ret
Hooks_SeamlessTravelHandlerForWorld ENDP

; Hooks_PostRender(UGameViewportClient*, UCanvas*)
; Runs GUI overlay, then calls original PostRender.
; Args: RCX=GVC, RDX=Canvas
;
; Stack: push rbp,rbx,rsi = 3 pushes (RSP=0 after 3×8);
;        sub 32(=0) -> 0 
Hooks_PostRender PROC
    push    rbp
    push    rbx
    push    rsi
    sub     rsp, 32                 ; 3 pushes: RSP=0; sub32(=0) -> 0 

    mov     rbx, rcx                ; GVC
    mov     rsi, rdx                ; Canvas

    ; ZeroGUI_SetupCanvas(Canvas)
    mov     rcx, rsi
    call    ZeroGUI_SetupCanvas

    ; GUI_Tick()
    call    GUI_Tick

    ; Original PostRender(GVC, Canvas)
    mov     rcx, rbx
    mov     rdx, rsi
    call    QWORD PTR [Native_GameViewportClient_PostRender]

    add     rsp, 32
    pop     rsi
    pop     rbx
    pop     rbp
    ret
Hooks_PostRender ENDP

; Hooks_TickFlush(UNetDriver*, float DeltaSeconds)
; If the server has active client connections and a replication driver,
; calls ServerReplicateActors before the original TickFlush.
;
; Args: RCX=NetDriver, XMM1=DeltaSeconds (float)
;
; Stack: push rbp,rbx = 2 pushes (RSP=8 after 2×8); sub 40(=8) -> 0 
;   [rsp+32] - spill slot for DeltaSeconds (REAL4)
Hooks_TickFlush PROC
    push    rbp
    push    rbx
    sub     rsp, 40                 ; 2 pushes: RSP=8; sub 40 -> 0 

    mov     rbx, rcx                ; NetDriver*
    movd    DWORD PTR [rsp + 32], xmm1 ; spill DeltaSeconds

    ; Auto-initialize server each tick until bListening is set.
    ; Server_Initialize performs an Athena type check and returns
    ; without setting bListening if still in lobby context.
    movzx   eax, BYTE PTR [bListening]
    test    al, al
    jnz     @@check_netdriver
    call    Server_Initialize
@@check_netdriver:
    ; NetDriver null check
    test    rbx, rbx
    jz      @@call_orig

    ; ClientConnections.Num() (TArray at +UNETDRIVER_ClientConns)
    ; TArray layout: [Data QWORD][Num DWORD][Max DWORD]
    ; Num is at base+8
    mov     eax, DWORD PTR [rbx + UNETDRIVER_ClientConns + 8]
    test    eax, eax
    jle     @@call_orig

    ; ClientConnections[0] - dereference Data ptr
    mov     rax, QWORD PTR [rbx + UNETDRIVER_ClientConns]
    mov     rax, QWORD PTR [rax]    ; first element
    test    rax, rax
    jz      @@call_orig

    ; InternalAck == false means a real player (not a loopback)
    movzx   ecx, BYTE PTR [rax + UNETCONN_InternalAck]
    test    cl, cl
    jnz     @@call_orig

    ; ReplicationDriver present?
    mov     rax, QWORD PTR [rbx + UNETDRIVER_ReplDriver]
    test    rax, rax
    jz      @@call_orig

    ; ServerReplicateActors(ReplicationDriver)
    mov     rcx, rax
    call    QWORD PTR [Native_ReplicationDriver_ServerReplicateActors]

@@call_orig:
    mov     rcx, rbx
    movd    xmm1, DWORD PTR [rsp + 32]
    call    QWORD PTR [Native_NetDriver_TickFlush]

    add     rsp, 40
    pop     rbx
    pop     rbp
    ret
Hooks_TickFlush ENDP

; Hooks_GetPlayerViewPoint(APlayerController*, FVector*, FRotator*)
; ------------------------------------------------------------
; On listen-server with active clients: copy pawn's location/rotation
; to the output pointers so the server-side camera tracks the pawn.
; Falls back to the original in all other cases.
;
; Args: RCX=PC, RDX=FVector* OutLoc, R8=FRotator* OutRot
;
; Stack: push rbp,rbx,rsi,rdi = 4 pushes (RSP=8 after 4×8); sub 40(=8) -> 0 
Hooks_GetPlayerViewPoint PROC
    push    rbp
    push    rbx
    push    rsi
    push    rdi
    sub     rsp, 40                 ; 4 pushes: RSP=8; sub 40 -> 0 

    mov     rbx, rcx                ; PC
    mov     rsi, rdx                ; OutLoc
    mov     rdi, r8                 ; OutRot

    ; PC must be valid
    test    rbx, rbx
    jz      @@call_orig

    ; HostBeacon must be set (server is live)
    cmp     QWORD PTR [HostBeacon], 0
    je      @@call_orig

    ; ClientConnections.Num() > 0 on World's NetDriver

@@call_orig:
    mov     rcx, rbx
    mov     rdx, rsi
    mov     r8, rdi
    call    QWORD PTR [Native_PlayerController_GetPlayerViewPoint]

    add     rsp, 40
    pop     rdi
    pop     rsi
    pop     rbx
    pop     rbp
    ret
Hooks_GetPlayerViewPoint ENDP

; Hooks_SpawnPlayActor - spawn and set up new player controller
; Original: APlayerController* (*)(UWorld*, UPlayer*, ENetRole, FURL&, void*, FString&, uint8)
; We replace UWorld* with GetWorld() and wire up the resulting PC.
;
; Arg layout at hook entry (before any pushes):
; RCX  = UWorld*  (replaced with GetWorld())
; RDX  = UPlayer* NewPlayer
; R8   = ENetRole
; R9   = FURL*
; [RSP+40] = void* UniqueId   (5th arg - see note)
; [RSP+48] = FString* Error   (6th arg)
; [RSP+56] = uint8 NetIdx     (7th arg)
;
; Note on stack-arg offsets: at entry RSP points to return addr.
; Caller placed arg5 at [caller_RSP+32] = [RSP+8+32] = [RSP+40].
;
; Stack: push rbp,rbx,rsi,rdi,r12,r13,r14 = 7 pushes (RSP=0 after 7×8).
;        sub 64(=0) -> 0 
;   [rsp+0..31]  = shadow for callees
;   [rsp+32]     = arg5 (UniqueId) for SpawnPlayActor call
;   [rsp+40]     = arg6 (Error)
;   [rsp+48]     = arg7 (NetIdx byte)
Hooks_SpawnPlayActor PROC
    push    rbp
    push    rbx
    push    rsi
    push    rdi
    push    r12
    push    r13
    push    r14
    sub     rsp, 64                 ; 7 pushes: RSP=0; sub64(=0) -> 0 

    ; Save register args (RCX=world ignored)
    mov     rbx, rdx                ; NewPlayer (UPlayer*)
    mov     r12d, r8d               ; ENetRole (32-bit enum)
    mov     r13, r9                 ; FURL*

    ; At this point: return addr at [RSP + 7*8 + 64] = [RSP+120]
    ; Caller's arg5 at [RSP + 120 + 8 + 32] = [RSP + 160]
    ; Caller's arg6 at [RSP + 168]
    ; Caller's arg7 at [RSP + 176]
    mov     rax, QWORD PTR [rsp + 160]   ; UniqueId (void*)
    mov     QWORD PTR [rsp + 32], rax
    mov     rax, QWORD PTR [rsp + 168]   ; Error (FString*)
    mov     QWORD PTR [rsp + 40], rax
    movzx   eax, BYTE PTR  [rsp + 176]   ; NetPlayerIndex (uint8)
    mov     BYTE PTR  [rsp + 48], al

    ; Get the authoritative world
    call    SDK_GetWorld
    test    rax, rax
    jz      @@done

    mov     r14, rax                ; World

    ; Call Native_World_SpawnPlayActor(World, NewPlayer, NetRole, FURL, UniqueId, Error, Idx)
    mov     rcx, r14
    mov     rdx, rbx
    mov     r8d, r12d
    mov     r9, r13
    ; [rsp+32..48] already set up above
    call    QWORD PTR [Native_World_SpawnPlayActor]

    test    rax, rax
    jz      @@done

    mov     rdi, rax                ; rdi = resulting APlayerController*

    ; NewPlayer->PlayerController = result  (UPlayer::PlayerController at +0x030)
    mov     QWORD PTR [rbx + 030h], rdi

    ; Game_Mode->LoadJoiningPlayer(PlayerController)
    mov     rcx, rdi
    call    GameModeBase_LoadPlayer

    ; PlayerController->OverriddenBackpackSize = 100
    mov     DWORD PTR [rdi + AFPCA_OverriddenBackpackSize], BACKPACK_SIZE

    mov     rax, rdi                ; return PC

@@done:
    add     rsp, 64
    pop     r14
    pop     r13
    pop     r12
    pop     rdi
    pop     rsi
    pop     rbx
    pop     rbp
    ret
Hooks_SpawnPlayActor ENDP

; Hooks_Beacon_NotifyControlMessage
; AOnlineBeaconHost* beacon, UNetConnection* Connection,
; uint8 MessageType, FBitReader* Bunch
;
; Dispatch by MessageType:
;   4  (NMT_Netspeed) - set Connection->CurrentNetSpeed = 30000
;   5  (NMT_Login)    - receive FStrings + UniqueId, then WelcomePlayer
;   15 (NMT_PCSwap)   - call original Beacon_NotifyControlMessage
;   default           - call Native_World_NotifyControlMessage(GetWorld(), ...)
;
; Stack: push rbp,rbx,rsi = 3 pushes (RSP=0 after 3×8).
;        sub 112(=0) -> 0 .
;   [rsp+0..31]   = shadow for callees
;   [rsp+32..47]  = FString OnlinePlatformName (16 bytes)
;   [rsp+48..63]  = FString ClientResponse     (16 bytes)
;   [rsp+64..103] = FUniqueNetIdRepl UniqueId  (40 bytes)
;   [rsp+104..111]= spare / align
Hooks_Beacon_NotifyControlMessage PROC
    push    rbp
    push    rbx
    push    rsi
    sub     rsp, 112                ; 3 pushes: RSP=0; sub112(=0) -> 0 

    ; Save args
    ; RCX = Beacon (not needed after dispatch setup)
    mov     rbx, rdx                ; Connection
    movzx   ebp, r8b                ; MessageType (0..255)
    mov     rsi, r9                 ; Bunch (FBitReader*)

    ; dispatch on MessageType
    cmp     ebp, NMT_Netspeed       ; 4
    je      @@case_netspeed
    cmp     ebp, NMT_Login          ; 5
    je      @@case_login
    cmp     ebp, NMT_PCSwap         ; 15
    je      @@case_pcswap

    ; Default: World::NotifyControlMessage(GetWorld(), Connection, Type, Bunch)
    call    SDK_GetWorld
    test    rax, rax
    jz      @@done
    mov     rcx, rax
    mov     rdx, rbx
    mov     r8d, ebp
    mov     r9, rsi
    call    QWORD PTR [Native_World_NotifyControlMessage]
    jmp     @@done

@@case_netspeed:
    ; Connection->CurrentNetSpeed = DEFAULT_NETSPEED (30000)
    mov     DWORD PTR [rbx + APLAYER_CurrentNetSpeed], DEFAULT_NETSPEED
    jmp     @@done

@@case_login:
    ; Zero-initialise the local FString and FUniqueNetIdRepl structs
    ; FString str1 at [rsp+32..47]
    xor     eax, eax
    mov     QWORD PTR [rsp + 32], rax
    mov     QWORD PTR [rsp + 40], rax
    ; FString str2 at [rsp+48..63]
    mov     QWORD PTR [rsp + 48], rax
    mov     QWORD PTR [rsp + 56], rax
    ; FUniqueNetIdRepl at [rsp+64..103] - 40 bytes (5 QWORDs)
    mov     QWORD PTR [rsp + 64], rax
    mov     QWORD PTR [rsp + 72], rax
    mov     QWORD PTR [rsp + 80], rax
    mov     QWORD PTR [rsp + 88], rax
    mov     QWORD PTR [rsp + 96], rax

    ; ReceiveFString(Bunch, &OnlinePlatformName)
    mov     rcx, rsi
    lea     rdx, [rsp + 32]
    call    QWORD PTR [Native_NetConnection_ReceiveFString]

    ; ReceiveFString(Bunch, &ClientResponse)
    mov     rcx, rsi
    lea     rdx, [rsp + 48]
    call    QWORD PTR [Native_NetConnection_ReceiveFString]

    ; ReceiveUniqueIdRepl(Bunch, &UniqueId)
    mov     rcx, rsi
    lea     rdx, [rsp + 64]
    call    QWORD PTR [Native_NetConnection_ReceiveUniqueIdRepl]

    ; WelcomePlayer(GetWorld(), Connection)
    call    SDK_GetWorld
    test    rax, rax
    jz      @@done
    mov     rcx, rax
    mov     rdx, rbx
    call    QWORD PTR [Native_World_WelcomePlayer]
    jmp     @@done

@@case_pcswap:

@@done:
    add     rsp, 112
    pop     rsi
    pop     rbx
    pop     rbp
    ret
Hooks_Beacon_NotifyControlMessage ENDP

; Hooks_ProcessEventHook(UObject*, UFunction*, void* Params)
; Intercepts all UFunction dispatches on this process.
;
; Flow:
;   1. If !bPlayButton: check if Function == ReadyToStartMatch;
;      if match -> Game_Start + InitNetworkHooks.
;   2. If bTraveled: scan UFunctionHooks_ToHook_Data for a matching
;      UFunction*; if found, call the corresponding ToCall handler.
;   3. Always call original ProcessEvent(Object, Function, Params).
;
; Args: RCX=Object, RDX=Function, R8=Params
;
; Stack: push rbp,rbx,rsi,rdi,r12,r13,r14 = 7 pushes (RSP=0 after 7×8).
;        sub 32(=0) -> 0 .
Hooks_ProcessEventHook PROC
    push    rbp
    push    rbx
    push    rsi
    push    rdi
    push    r12
    push    r13
    push    r14
    sub     rsp, 32                 ; 7 pushes: RSP=0; sub32(=0) -> 0

    mov     rbx, rcx                ; Object
    mov     rsi, rdx                ; Function
    mov     rdi, r8                 ; Params

    movzx   eax, BYTE PTR [bPlayButton]
    test    al, al
    jnz     @@check_traveled

    mov     BYTE PTR [bPlayButton], 1
    call    Game_Start
    call    Hooks_InitNetworkHooks

    ; UFunctionHooks dispatch (once bTraveled is true)
@@check_traveled:
    movzx   eax, BYTE PTR [bTraveled]
    test    al, al
    jz      @@call_orig

    mov     r13d, DWORD PTR [UFunctionHooks_ToHook_Num]
    test    r13d, r13d
    jle     @@call_orig

    mov     r14, QWORD PTR [UFunctionHooks_ToHook_Data]
    test    r14, r14
    jz      @@call_orig

    xor     ebp, ebp                ; loop index i = 0

@@dispatch_loop:
    cmp     ebp, r13d
    jge     @@call_orig

    mov     rax, QWORD PTR [r14 + rbp * 8]   ; ToHook[i]
    cmp     rax, rsi                          ; == current Function?
    jne     @@dispatch_next

    ; Call ToCall[i](Object, Params)
    mov     rax, QWORD PTR [UFunctionHooks_ToCall_Data]
    test    rax, rax
    jz      @@dispatch_next
    mov     rax, QWORD PTR [rax + rbp * 8]   ; handler ptr
    test    rax, rax
    jz      @@dispatch_next
    mov     rcx, rbx                ; Object
    mov     rdx, rdi                ; Params
    call    rax

@@dispatch_next:
    inc     ebp
    jmp     @@dispatch_loop

    ; Always call original ProcessEvent
@@call_orig:
    mov     rcx, rbx
    mov     rdx, rsi
    mov     r8, rdi
    call    QWORD PTR [ProcessEvent]

    add     rsp, 32
    pop     r14
    pop     r13
    pop     r12
    pop     rdi
    pop     rsi
    pop     rbx
    pop     rbp
    ret
Hooks_ProcessEventHook ENDP

; Hooks_InitNetworkHooks()
; Called from Hooks_ProcessEventHook when bPlayButton fires.
; Installs the 8 network-phase Detour hooks using DETOUR_START/END.
;
; DetourAttach(&TargetVariable, HookProc):
;   RCX = address of the QWORD holding the original fn ptr
;   RDX = address of the hook procedure
;
; Stack: push rbp + push rbx = 2 pushes (RSP=8); sub 40(=8) -> 0
Hooks_InitNetworkHooks PROC
    push    rbp
    push    rbx
    sub     rsp, 40                 ; 2 pushes: RSP=8; sub40 -> 0 

    ; DETOUR_START
    call    DetourTransactionBegin
    call    GetCurrentThread
    mov     rcx, rax
    call    DetourUpdateThread

    ; WelcomePlayer
    lea     rcx, Native_World_WelcomePlayer
    lea     rdx, Hooks_WelcomePlayer
    call    DetourAttach

    ; World::NotifyControlMessage
    lea     rcx, Native_World_NotifyControlMessage
    lea     rdx, Hooks_World_NotifyControlMessage
    call    DetourAttach

    ; OnlineBeacon::NotifyAcceptingConnection
    lea     rcx, Native_OnlineBeacon_NotifyAcceptingConnection
    lea     rdx, Hooks_Beacon_NotifyAcceptingConnection
    call    DetourAttach

    ; OnlineBeaconHost::NotifyControlMessage
    lea     rcx, Native_OnlineBeaconHost_NotifyControlMessage
    lea     rdx, Hooks_Beacon_NotifyControlMessage
    call    DetourAttach

    ; Engine::SeamlessTravelHandlerForWorld
    lea     rcx, Native_Engine_SeamlessTravelHandlerForWorld
    lea     rdx, Hooks_SeamlessTravelHandlerForWorld
    call    DetourAttach

    ; OnlineSession::KickPlayer
    lea     rcx, Native_OnlineSession_KickPlayer
    lea     rdx, Hooks_KickPlayer
    call    DetourAttach

    ; Actor::GetNetMode
    lea     rcx, Native_Actor_GetNetMode
    lea     rdx, Hooks_GetNetMode
    call    DetourAttach

    ; GameViewportClient::PostRender
    lea     rcx, Native_GameViewportClient_PostRender
    lea     rdx, Hooks_PostRender
    call    DetourAttach

    ; DETOUR_END
    call    DetourTransactionCommit

    add     rsp, 40
    pop     rbx
    pop     rbp
    ret
Hooks_InitNetworkHooks ENDP

END