INCLUDE include\master.inc

ACONTROLLER_Pawn            EQU 0260h   ; AController::Pawn (APawn*)
ACONTROLLER_PlayerState     EQU 0248h   ; AController::PlayerState (APlayerState*)
APAWN_Controller            EQU 0228h   ; APawn::Controller (AController*)
APAWN_PlayerState           EQU 0258h   ; APawn::PlayerState
AFPCA_bIsDisconnecting      EQU 1674h   ; AFortPlayerControllerAthena::bIsDisconnecting (bool)
AOBH_ListenPort             EQU 0208h   ; AOnlineBeaconHost::ListenPort (int32)
AOBH_NetDriver              EQU 0220h   ; AOnlineBeaconHost::Driver (UNetDriver*)
ABSMA_EditingPlayer         EQU 0480h   ; ABuildingSMActor::EditingPlayer
UWORLD_NetDriver            EQU 038h    ; UWorld::NetDriver (UNetDriver*)
UWORLD_AuthorityGameMode    EQU 0140h   ; UWorld::AuthorityGameMode (AGameMode*)
FURL_Port                   EQU 020h    ; FURL::Port (DWORD, per structs.inc)
VTABLE_ServerReplicateActors EQU (083h * 8)  ; vtable byte offset for slot 0x53

MAX_PEHOOKS                 EQU 32      ; capacity of the hook arrays

.data?

; Public pointers consumed by Hooks_ProcessEventHook
UFunctionHooks_ToHook_Data  QWORD   ?   ; -> _ToHook_Storage (set in Initialize)
UFunctionHooks_ToHook_Num   DWORD   ?
                            DWORD   ?   ; pad to QWORD
UFunctionHooks_ToCall_Data  QWORD   ?   ; -> _ToCall_Storage (set in Initialize)

; Internal flat arrays (MAX_PEHOOKS elements each)
_ToHook_Storage QWORD   MAX_PEHOOKS DUP (?)
_ToCall_Storage QWORD   MAX_PEHOOKS DUP (?)

; Lazily-resolved UFunction* cache (used by handlers)
pFn_K2_DestroyActor             QWORD   ?
pFn_ClientOnPawnRevived         QWORD   ?
pFn_ForceNetUpdate              QWORD   ?
pFn_OnRep_ReplicatedAnimMontage QWORD   ?
pFn_InitKismetBuildingActor     QWORD   ?
pFn_SilentDie                   QWORD   ?
pFn_OnRep_EditingPlayer         QWORD   ?
pFn_OnRep_EditActor             QWORD   ?
pFn_K2_GetActorLocation         QWORD   ?

; Cached class pointers (used by ReadyToStartMatch)
pClass_FortOnlineBeaconHost     QWORD   ?

.const

szFn_ServerTryActivateAbility       DB "Function GameplayAbilities.AbilitySystemComponent.ServerTryActivateAbility", 0
szFn_ServerTryActivateWithEventData DB "Function GameplayAbilities.AbilitySystemComponent.ServerTryActivateAbilityWithEventData", 0
szFn_ServerAbilityRPCBatch          DB "Function FortniteGame.FortAbilitySystemComponent.ServerAbilityRPCBatch", 0
szFn_ServerHandlePickup             DB "Function FortniteGame.FortPlayerPawn.ServerHandlePickup", 0
szFn_CheatScript                    DB "Function FortniteGame.FortGameModeAthena.CheatScript", 0
szFn_OnDeathServer                  DB "Function FortniteGame.BuildingSMActor.OnDeathServer", 0
szFn_ServerCreateBuildingActor      DB "Function FortniteGame.BuildingSMActor.ServerCreateBuildingActor", 0
szFn_ServerBeginEditingBuilding     DB "Function FortniteGame.BuildingSMActor.ServerBeginEditingBuildingActor", 0
szFn_ServerSpawnDeco                DB "Function FortniteGame.FortDecoTool.ServerSpawnDeco", 0
szFn_ServerEditBuildingActor        DB "Function FortniteGame.BuildingSMActor.ServerEditBuildingActor", 0
szFn_ClientOnPawnDied               DB "Function FortniteGame.FortPlayerController.ClientOnPawnDied", 0
szFn_ServerEndEditingBuilding       DB "Function FortniteGame.BuildingSMActor.ServerEndEditingBuildingActor", 0
szFn_ServerRepairBuildingActor      DB "Function FortniteGame.BuildingSMActor.ServerRepairBuildingActor", 0
szFn_ServerAttemptAircraftJump      DB "Function FortniteGame.FortPlayerPawn.ServerAttemptAircraftJump", 0
szFn_ServerReviveFromDBNO           DB "Function FortniteGame.FortPlayerPawn.ServerReviveFromDBNO", 0
szFn_ServerAttemptInteract          DB "Function FortniteGame.FortPlayerPawn.ServerAttemptInteract", 0
szFn_ServerPlayEmoteItem            DB "Function FortniteGame.FortPlayerPawn.ServerPlayEmoteItem", 0
szFn_ServerAttemptInventoryDrop     DB "Function FortniteGame.FortPlayerPawn.ServerAttemptInventoryDrop", 0
szFn_OnSpawnOutAnimEnded            DB "Function FortniteGame.AthenaVictoryDrone.OnSpawnOutAnimEnded", 0
szFn_ServerExecuteInventoryItem     DB "Function FortniteGame.FortPlayerController.ServerExecuteInventoryItem", 0
szFn_ServerReturnToMainMenu         DB "Function FortniteGame.FortPlayerController.ServerReturnToMainMenu", 0
szFn_ServerLoadingScreenDropped     DB "Function FortniteGame.FortPlayerController.ServerLoadingScreenDropped", 0
szFn_ServerChoosePart               DB "Function FortniteGame.FortPlayerControllerCommon.ServerChoosePart", 0
szFn_ReadyToStartMatch              DB "Function FortniteGame.FortGameModeAthena.ReadyToStartMatch", 0
szFn_OnAircraftExitedDropZone       DB "Function FortniteGame.FortAthenaAircraft.OnAircraftExitedDropZone", 0
szFn_ServerCheatAll                 DB "Function FortniteGame.FortGameModeAthena.ServerCheatAll", 0
szFn_Logout                         DB "Function FortniteGame.FortGameModeAthena.Logout", 0

szFn_K2_DestroyActor                DB "Function Engine.Actor.K2_DestroyActor", 0
szFn_ClientOnPawnRevived            DB "Function FortniteGame.FortPlayerPawn.ClientOnPawnRevived", 0
szFn_ForceNetUpdate                 DB "Function Engine.Actor.ForceNetUpdate", 0
szFn_OnRepRepAnimMontage            DB "Function GameplayAbilities.AbilitySystemComponent.OnRep_ReplicatedAnimMontageForMesh", 0
szFn_InitKismetBuildingActor        DB "Function FortniteGame.BuildingSMActor.InitializeKismetSpawnedBuildingActor", 0
szFn_SilentDie                      DB "Function FortniteGame.BuildingActor.SilentDie", 0
szFn_OnRep_EditingPlayer            DB "Function FortniteGame.BuildingSMActor.OnRep_EditingPlayer", 0
szFn_OnRep_EditActor                DB "Function FortniteGame.FortWeap_EditingTool.OnRep_EditActor", 0
szFn_K2_GetActorLocation            DB "Function Engine.Actor.K2_GetActorLocation", 0

szClass_FortOnlineBeaconHost        DB "Class FortniteGame.FortOnlineBeaconHost", 0

szHookCount DB "[UFHOOKS] Registered %d UFunction hooks", 0Ah, 0

.code


PEHOOK_CheatScript PROC
    xor     al, al          ; return 0
    ret
PEHOOK_CheatScript ENDP

PEHOOK_ServerCheatAll PROC
    mov     al, 1           ; return 1
    ret
PEHOOK_ServerCheatAll ENDP

PEHOOK_ServerChoosePart PROC
    mov     al, 1           ; return 1
    ret
PEHOOK_ServerChoosePart ENDP

; PEHOOK_Logout - set bIsDisconnecting on the leaving controller
; RCX = AFortGameModeAthena* (GameMode)
; RDX = Params: { AController* Exiting; }  ([RDX+0])
PEHOOK_Logout PROC
    mov     rax, QWORD PTR [rdx]    ; Exiting controller
    test    rax, rax
    jz      @@done
    mov     BYTE PTR [rax + AFPCA_bIsDisconnecting], 1
@@done:
    xor     al, al
    ret
PEHOOK_Logout ENDP

; PEHOOK_OnSpawnOutAnimEnded - destroy the VictoryDrone actor
; RCX = AthenaVictoryDrone* (the drone that finished its exit anim)
; RDX = void* Params (empty)
;
; Calls K2_DestroyActor on the drone via ProcessEvent (lazy lookup).
;
; Stack: push rbp + push rbx = 2 pushes; sub 40 -> 0 
PEHOOK_OnSpawnOutAnimEnded PROC
    push    rbp
    push    rbx
    sub     rsp, 40                 ; 2 pushes: RSP=8; sub40 -> 0 

    mov     rbx, rcx                ; save drone actor*

    ; Lazy-resolve K2_DestroyActor UFunction
    mov     rax, QWORD PTR [pFn_K2_DestroyActor]
    test    rax, rax
    jnz     @@have_fn
    lea     rcx, szFn_K2_DestroyActor
    call    SDK_FindObject
    mov     QWORD PTR [pFn_K2_DestroyActor], rax
@@have_fn:
    test    rax, rax
    jz      @@done

    ; ProcessEvent(Drone, K2_DestroyActor, NULL)
    mov     rcx, rbx
    mov     rdx, rax
    xor     r8d, r8d
    call    QWORD PTR [ProcessEvent]

@@done:
    add     rsp, 40
    pop     rbx
    pop     rbp
    xor     al, al
    ret
PEHOOK_OnSpawnOutAnimEnded ENDP

; PEHOOK_ServerLoadingScreenDropped - apply abilities to pawn
; RCX = AFortPlayerController*
; Gets Pawn from PC, calls Abilities_ApplyAbilities(Pawn).
;
; Stack: push rbp + push rbx = 2 pushes; sub 40 -> 0 
PEHOOK_ServerLoadingScreenDropped PROC
    push    rbp
    push    rbx
    sub     rsp, 40

    mov     rbx, rcx                ; PC
    ; Pawn = PC->Pawn (AController::Pawn at +ACONTROLLER_Pawn)
    mov     rax, QWORD PTR [rbx + ACONTROLLER_Pawn]
    test    rax, rax
    jz      @@done

    mov     rcx, rax
    call    Abilities_ApplyAbilities

@@done:
    add     rsp, 40
    pop     rbx
    pop     rbp
    xor     al, al
    ret
PEHOOK_ServerLoadingScreenDropped ENDP

; PEHOOK_ServerAttemptInventoryDrop
; RCX = AFortPlayerPawn* (the pawn dropping)
; RDX = Params: { FGuid ItemGuid; int Count; }
; Gets PC from Pawn, calls Inventory_OnDrop(PC, Params).
;
; Stack: push rbp + push rbx + push rsi = 3 pushes (RSP=0); sub 32 -> 0 
PEHOOK_ServerAttemptInventoryDrop PROC
    push    rbp
    push    rbx
    push    rsi
    sub     rsp, 32                 ; 3 pushes: RSP=0; sub32 -> 0 

    mov     rbx, rcx                ; Pawn
    mov     rsi, rdx                ; Params

    ; Controller = Pawn->Controller
    mov     rax, QWORD PTR [rbx + APAWN_Controller]
    test    rax, rax
    jz      @@done

    mov     rcx, rax
    mov     rdx, rsi
    call    Inventory_OnDrop

@@done:
    add     rsp, 32
    pop     rsi
    pop     rbx
    pop     rbp
    xor     al, al
    ret
PEHOOK_ServerAttemptInventoryDrop ENDP

; PEHOOK_ServerHandlePickup
; RCX = AFortPlayerPawn* (the picking-up pawn)
; RDX = Params: { AFortPickup* Pickup; float FlyTime; FVector StartDir; bool bPlaySound; }
;
; Stack: push rbp + push rbx + push rsi = 3 pushes; sub 32 -> 0 
PEHOOK_ServerHandlePickup PROC
    push    rbp
    push    rbx
    push    rsi
    sub     rsp, 32

    mov     rbx, rcx                ; Pawn
    mov     rsi, rdx                ; Params

    mov     rax, QWORD PTR [rbx + APAWN_Controller]
    test    rax, rax
    jz      @@done

    mov     rcx, rax                ; PC
    mov     rdx, rsi                ; Params
    call    Inventory_OnPickup

@@done:
    add     rsp, 32
    pop     rsi
    pop     rbx
    pop     rbp
    xor     al, al
    ret
PEHOOK_ServerHandlePickup ENDP

; PEHOOK_ServerExecuteInventoryItem
; RCX = AFortPlayerController*
; RDX = Params: { FGuid ItemGuid; }  ([RDX+0])
;
; Stack: push rbp + push rbx = 2 pushes; sub 40 -> 0 
PEHOOK_ServerExecuteInventoryItem PROC
    push    rbp
    push    rbx
    sub     rsp, 40

    mov     rbx, rcx                ; PC
    ; Guid at [RDX+0] - pass rdx as-is (Inventory_EquipInventoryItem takes (PC, Guid*))
    mov     rcx, rbx
    ; rdx = Params (Guid is at offset 0, so Params == &Guid)
    call    Inventory_EquipWeaponDefinition  ; TODO: Inventory_EquipInventoryItem(PC, Guid*)

    add     rsp, 40
    pop     rbx
    pop     rbp
    xor     al, al
    ret
PEHOOK_ServerExecuteInventoryItem ENDP

; PEHOOK_ServerReturnToMainMenu
; RCX = AFortPlayerController*  - set bIsDisconnecting + return true
PEHOOK_ServerReturnToMainMenu PROC
    test    rcx, rcx
    jz      @@done
    mov     BYTE PTR [rcx + AFPCA_bIsDisconnecting], 1
@@done:
    mov     al, 1
    ret
PEHOOK_ServerReturnToMainMenu ENDP

; PEHOOK_OnDeathServer - remove dying building from ExistingBuildings
; RCX = ABuildingSMActor* (dying actor)
; Scans ExistingBuildings array; on match, swaps with last and decrements Num.
;
; Stack: push rbp + push rbx + push rsi + push rdi = 4 pushes (RSP=8); sub 40 -> 0 
PEHOOK_OnDeathServer PROC
    push    rbp
    push    rbx
    push    rsi
    push    rdi
    sub     rsp, 40                 ; 4 pushes: RSP=8; sub40 -> 0 

    mov     rbx, rcx                ; dying actor

    ; Load ExistingBuildings array
    mov     rsi, QWORD PTR [ExistingBuildings]  ; Data ptr (QWORD**)
    mov     edi, DWORD PTR [ExistingBuildingsNum]; Num

    test    rsi, rsi
    jz      @@done
    test    edi, edi
    jle     @@done

    xor     ebp, ebp                ; i = 0
@@scan_loop:
    cmp     ebp, edi
    jge     @@done

    mov     rax, QWORD PTR [rsi + rbp * 8]  ; ExistingBuildings[i]
    cmp     rax, rbx
    jne     @@next

    ; Found at index i - swap with last element (unordered remove)
    dec     edi                     ; new Num = Num-1
    cmp     ebp, edi                ; if i == new Num, no swap needed
    je      @@erase
    mov     rax, QWORD PTR [rsi + rdi * 8]  ; last element
    mov     QWORD PTR [rsi + rbp * 8], rax  ; [i] = last
@@erase:
    mov     DWORD PTR [ExistingBuildingsNum], edi
    jmp     @@done

@@next:
    inc     ebp
    jmp     @@scan_loop

@@done:
    add     rsp, 40
    pop     rdi
    pop     rsi
    pop     rbx
    pop     rbp
    xor     al, al
    ret
PEHOOK_OnDeathServer ENDP

; PEHOOK_ServerEndEditingBuildingActor
; RCX = ABuildingSMActor* (building being released)
; Clears EditingPlayer field on the building.
;
; TODO: also clear EditTool->EditActor if we have AFortDecoTool offset.
PEHOOK_ServerEndEditingBuildingActor PROC
    test    rcx, rcx
    jz      @@done
    mov     QWORD PTR [rcx + ABSMA_EditingPlayer], 0
@@done:
    xor     al, al
    ret
PEHOOK_ServerEndEditingBuildingActor ENDP

; PEHOOK_ServerRepairBuildingActor
; RCX = AFortPlayerPawn* (pawn issuing repair)
; RDX = Params: { ABuildingSMActor* BuildingActorToRepair; }
;
; Calls RepairBuilding (amount 50) via ProcessEvent on the target building.
; Stack: push rbp + push rbx + push rsi = 3 pushes; sub 32 -> 0 
PEHOOK_ServerRepairBuildingActor PROC
    push    rbp
    push    rbx
    push    rsi
    sub     rsp, 32

    mov     rbx, rcx                ; Pawn (unused for repair call itself)
    mov     rsi, QWORD PTR [rdx]    ; Params->BuildingActorToRepair (QWORD at [RDX+0])
    test    rsi, rsi
    jz      @@done

    ; TODO : call RepairBuilding via ProcessEvent(Building, RepairFn, &AmountParams)
    ; For now: ForceNetUpdate to signal changes
    mov     rcx, rsi
    call    QWORD PTR [ProcessEvent]    ; placeholder

@@done:
    add     rsp, 32
    pop     rsi
    pop     rbx
    pop     rbp
    xor     al, al
    ret
PEHOOK_ServerRepairBuildingActor ENDP

; PEHOOK_ServerReviveFromDBNO
; RCX = AFortPlayerPawn* (the DBNO pawn being revived)
; RDX = Params: { AController* EventInstigator; }
;
; Simplified: call ClientOnPawnRevived via ProcessEvent.
; Full bIsDBNO clear + health restore implemented via the revive UFunction.
;
; Stack: push rbp + push rbx = 2 pushes; sub 40 -> 0 
PEHOOK_ServerReviveFromDBNO PROC
    push    rbp
    push    rbx
    sub     rsp, 40

    mov     rbx, rcx                ; Pawn

    ; Lazy-resolve ClientOnPawnRevived UFunction
    mov     rax, QWORD PTR [pFn_ClientOnPawnRevived]
    test    rax, rax
    jnz     @@have_revive
    lea     rcx, szFn_ClientOnPawnRevived
    call    SDK_FindObject
    mov     QWORD PTR [pFn_ClientOnPawnRevived], rax
@@have_revive:
    test    rax, rax
    jz      @@done

    ; ProcessEvent(Pawn, ClientOnPawnRevived, NULL)
    mov     rcx, rbx
    mov     rdx, rax
    xor     r8d, r8d
    call    QWORD PTR [ProcessEvent]

@@done:
    add     rsp, 40
    pop     rbx
    pop     rbp
    xor     al, al
    ret
PEHOOK_ServerReviveFromDBNO ENDP

; PEHOOK_ServerAttemptInteract
; RCX = AFortPlayerPawn* (interacting pawn)
; RDX = Params: { AActor* ReceivingActor; }
;
; If ReceivingActor is a pawn: call PEHOOK_ServerReviveFromDBNO logic.
; Otherwise (container etc.): stub for (bAlreadySearched).
;
; Stack: push rbp + push rbx + push rsi = 3 pushes; sub 32 -> 0 
PEHOOK_ServerAttemptInteract PROC
    push    rbp
    push    rbx
    push    rsi
    sub     rsp, 32

    mov     rbx, rcx                ; interacting Pawn
    mov     rsi, QWORD PTR [rdx]    ; ReceivingActor ([Params+0])
    test    rsi, rsi
    jz      @@done

    ; Check if ReceivingActor is a Pawn (non-null Controller means it's a player pawn)
    mov     rax, QWORD PTR [rsi + APAWN_Controller]
    test    rax, rax
    jz      @@container_case

    ; Pawn case - revive from DBNO
    mov     rcx, rsi                ; the pawn to revive
    xor     edx, edx
    call    PEHOOK_ServerReviveFromDBNO
    jmp     @@done

@@container_case:
    ; Container case - TODO: set bAlreadySearched + OnRep

@@done:
    add     rsp, 32
    pop     rsi
    pop     rbx
    pop     rbp
    xor     al, al
    ret
PEHOOK_ServerAttemptInteract ENDP

; PEHOOK_ServerPlayEmoteItem
; RCX = APlayerPawn_Athena_C* (the pawn emoting)
; RDX = Params: { UFortMontageItemDefinitionBase* EmoteAsset; }
;
; Sets RepAnimMontageInfo on the AbilitySystemComponent so the emote
; is replicated to all clients.
;
; Stack: push rbp + push rbx + push rsi = 3 pushes; sub 32 -> 0 
PEHOOK_ServerPlayEmoteItem PROC
    push    rbp
    push    rbx
    push    rsi
    sub     rsp, 32

    mov     rbx, rcx                ; Pawn
    mov     rsi, QWORD PTR [rdx]    ; EmoteAsset ([Params+0])
    test    rsi, rsi
    jz      @@done

    ; Get AbilitySystemComponent from pawn
    mov     rcx, rbx
    call    FortHelper_GetAbilitySystemComponent
    test    rax, rax
    jz      @@done

    ; Write to RepAnimMontageInfo (FGameplayAbilityRepAnimMontage at ASC+0xAF0)
    ; Layout: AnimMontage(+0), PlayRate(+8), Position(+C), BlendTime(+10),
    ;          NextSectionID(+14), bitfield(+15)
    ; We store the EmoteAsset as the AnimMontage and set PlayRate=1.0
    mov     QWORD PTR [rax + UASC_RepAnimMontageInfo + 000h], rsi ; AnimMontage = EmoteAsset
    mov     DWORD PTR [rax + UASC_RepAnimMontageInfo + 008h], 3F800000h ; PlayRate = 1.0f
    mov     DWORD PTR [rax + UASC_RepAnimMontageInfo + 00Ch], 0          ; Position = 0.0f
    mov     DWORD PTR [rax + UASC_RepAnimMontageInfo + 010h], 0          ; BlendTime = 0.0f
    mov     BYTE PTR  [rax + UASC_RepAnimMontageInfo + 014h], 0          ; NextSectionID = 0
    mov     BYTE PTR  [rax + UASC_RepAnimMontageInfo + 015h], 2          ; ForcePlayBit set (bit1)

    ; ForceNetUpdate on the pawn to push replication
    mov     rcx, rbx
    mov     rdx, QWORD PTR [pFn_ForceNetUpdate]
    test    rdx, rdx
    jz      @@done
    xor     r8d, r8d
    call    QWORD PTR [ProcessEvent]

@@done:
    add     rsp, 32
    pop     rsi
    pop     rbx
    pop     rbp
    xor     al, al
    ret
PEHOOK_ServerPlayEmoteItem ENDP

; PEHOOK_ServerSpawnDeco
; RCX = AFortDecoTool* (the deco tool actor)
; RDX = Params: { FVector WorldPosition; FRotator Rotation; ABuildingSMActor* AttachedTo; }
;   WorldPos at [RDX+0], Rotation at [RDX+C], AttachedTo at [RDX+18] (after FRotator)
;
; Stack: push rbp + push rbx + push rsi = 3 pushes; sub 32 -> 0 
PEHOOK_ServerSpawnDeco PROC
    push    rbp
    push    rbx
    push    rsi
    sub     rsp, 32

    mov     rbx, rcx                ; DecoTool
    mov     rsi, rdx                ; Params

    mov     rcx, rbx
    mov     rdx, rsi
    call    Spawners_SpawnDeco      ; Spawners_SpawnDeco(Tool, Params)

    add     rsp, 32
    pop     rsi
    pop     rbx
    pop     rbp
    xor     al, al
    ret
PEHOOK_ServerSpawnDeco ENDP

; PEHOOK_ServerTryActivateAbility
; RCX = UAbilitySystemComponent* (ASC)
; RDX = Params: { FGameplayAbilitySpecHandle Handle(+0,4B); bool InputPressed(+8,1B);
;                 FPredictionKey PredKey(+10,0x18B); }
;
; Stack: push rbp + push rbx + push rsi = 3 pushes; sub 32 -> 0 
PEHOOK_ServerTryActivateAbility PROC
    push    rbp
    push    rbx
    push    rsi
    sub     rsp, 32

    mov     rbx, rcx                ; ASC
    mov     rsi, rdx                ; Params

    ; Abilities_TryActivateAbility(ASC, Handle*, InputPressed, PredKey*, null)
    mov     rcx, rbx
    lea     rdx, [rsi]              ; &Params->Handle (at offset 0)
    movzx   r8d, BYTE PTR [rsi + 8] ; InputPressed (bool at +8)
    lea     r9, [rsi + 10h]         ; &Params->PredictionKey (at +0x10)
    call    Abilities_TryActivateAbility

    add     rsp, 32
    pop     rsi
    pop     rbx
    pop     rbp
    xor     al, al
    ret
PEHOOK_ServerTryActivateAbility ENDP

; PEHOOK_ServerTryActivateAbilityWithEventData - includes FGameplayEventData
; Same as above but Params also has FGameplayEventData after PredKey (at +0x28).
; We forward the EventData pointer as the 5th arg.
;
; Stack: push rbp + push rbx + push rsi = 3 pushes; sub 32 -> 0 
PEHOOK_ServerTryActivateAbilityWithEventData PROC
    push    rbp
    push    rbx
    push    rsi
    sub     rsp, 32

    mov     rbx, rcx
    mov     rsi, rdx

    mov     rcx, rbx
    lea     rdx, [rsi]
    movzx   r8d, BYTE PTR [rsi + 8]
    lea     r9, [rsi + 10h]
    ; 5th arg: &EventData at [rsi + 28h]
    lea     rax, [rsi + 28h]
    mov     QWORD PTR [rsp + 32], rax
    call    Abilities_TryActivateAbility

    add     rsp, 32
    pop     rsi
    pop     rbx
    pop     rbp
    xor     al, al
    ret
PEHOOK_ServerTryActivateAbilityWithEventData ENDP

; PEHOOK_ServerAbilityRPCBatch - parse batch and call TryActivate per entry
; Stub: delegates to TryActivateAbility for the first batch entry.
;
; Stack: push rbp + push rbx + push rsi = 3 pushes; sub 32 -> 0 
PEHOOK_ServerAbilityRPCBatch PROC
    push    rbp
    push    rbx
    push    rsi
    sub     rsp, 32

    mov     rbx, rcx                ; ASC
    mov     rsi, rdx                ; Params (FServerAbilityRPCBatch)

    ; BatchInfo[0].AbilitySpecHandle at [Params+0], PredKey at [Params+8]
    ; InputPressed flag at batch entry - assume true (batch implies activation
    mov     rcx, rbx
    lea     rdx, [rsi]
    mov     r8d, 1                  ; InputPressed = true
    lea     r9, [rsi + 8]
    call    Abilities_TryActivateAbility

    add     rsp, 32
    pop     rsi
    pop     rbx
    pop     rbp
    xor     al, al
    ret
PEHOOK_ServerAbilityRPCBatch ENDP

; PEHOOK_ClientOnPawnDied - handle death: update state, check win condition
; RCX = AFortPlayerController* (dead player's PC)
; RDX = Params: { FFortPlayerDeathReport DeathReport; }  ([RDX+0..+0x4F])
;
; Simplified implementation: updates DeathInfo on PlayerState, decrements
; PlayersLeft on GameState, calls Game mode's OnPlayerKilled.
;
; Stack: push rbp,rbx,rsi,rdi,r12,r13 = 6 pushes (RSP=8); sub 40 -> 0 
PEHOOK_ClientOnPawnDied PROC
    push    rbp
    push    rbx
    push    rsi
    push    rdi
    push    r12
    push    r13
    sub     rsp, 40                 ; 6 pushes: RSP=8; sub40 -> 0 

    mov     rbx, rcx                ; PC (dead player's controller)
    mov     r12, rdx                ; Params = &FFortPlayerDeathReport

    ; PlayerState = PC->PlayerState
    mov     rsi, QWORD PTR [rbx + ACONTROLLER_PlayerState]
    test    rsi, rsi
    jz      @@done

    ; Copy FDeathInfo from DeathReport into PlayerState->DeathInfo
    ; FDeathInfo at AFPSA_DeathInfo offset on PlayerState (0xF40)
    ; DeathReport.KillerPlayerState at [Params+0x10] -> DeathInfo.FinisherOrDowner
    ; DeathReport.bDBNO flags etc.
    mov     rax, QWORD PTR [r12 + 010h]                   ; KillerPlayerState
    mov     QWORD PTR [rsi + AFPSA_DeathInfo + 000h], rax ; FinisherOrDowner

    ; DeathCause: call Game_GetDeathCause(DeathReport) to compute
    mov     rcx, r12
    call    Game_GetDeathCause                             ; returns DWORD in EAX
    mov     BYTE PTR [rsi + AFPSA_DeathInfo + 009h], al   ; DeathCause byte

    ; GameState->PlayersLeft--
    call    SDK_GetWorld
    test    rax, rax
    jz      @@done
    ; AuthorityGameMode is on World
    mov     r13, QWORD PTR [rax + UWORLD_AuthorityGameMode]

    ; TODO: full spectate, victory drone, EndMatch check

@@done:
    add     rsp, 40
    pop     r13
    pop     r12
    pop     rdi
    pop     rsi
    pop     rbx
    pop     rbp
    xor     al, al
    ret
PEHOOK_ClientOnPawnDied ENDP

; PEHOOK_ServerAttemptAircraftJump - jump from battle bus
; RCX = APlayerPawn_Athena_C* (pawn on aircraft)
; RDX = Params: { FRotator ClientRotation; }  ([RDX+0])
;
; Calls GameModeBase_InitPawn to initialise the pawn for landing.
; Stack: push rbp + push rbx + push rsi = 3 pushes; sub 32 -> 0 
PEHOOK_ServerAttemptAircraftJump PROC
    push    rbp
    push    rbx
    push    rsi
    sub     rsp, 32

    mov     rbx, rcx                ; Pawn
    mov     rsi, rdx                ; Params

    ; Get controller from pawn
    mov     rax, QWORD PTR [rbx + APAWN_Controller]
    test    rax, rax
    jz      @@done

    ; GameModeBase_InitPawn(PC) - sets up pawn for first touch-down
    mov     rcx, rax
    call    GameModeBase_InitPawn

@@done:
    add     rsp, 32
    pop     rsi
    pop     rbx
    pop     rbp
    xor     al, al
    ret
PEHOOK_ServerAttemptAircraftJump ENDP

; PEHOOK_OnAircraftExitedDropZone - auto-jump remaining passengers
; RCX = AFortAthenaAircraft* (the aircraft)
; Iterates passengers and forces ServerAttemptAircraftJump on each.
PEHOOK_OnAircraftExitedDropZone PROC
    push    rbx
    push    rbp
    push    rsi
    sub     rsp, 20h

    ; HostBeacon->NetDriver (AOBH_NetDriver = 0x220)
    mov     rbx, QWORD PTR [HostBeacon]
    test    rbx, rbx
    jz      @OAEDZ_done
    mov     rbx, QWORD PTR [rbx + AOBH_NetDriver]
    test    rbx, rbx
    jz      @OAEDZ_done

    ; ClientConnections TArray at UNetDriver+0x80
    mov     rsi, QWORD PTR [rbx + 080h]    ; Connections.Data
    test    rsi, rsi
    jz      @OAEDZ_done
    mov     ebp, DWORD PTR [rbx + 088h]    ; Connections.Num
    test    ebp, ebp
    jz      @OAEDZ_done

    xor     ebx, ebx                       ; i = 0
@OAEDZ_loop:
    cmp     ebx, ebp
    jge     @OAEDZ_done
    mov     rcx, QWORD PTR [rsi + rbx*8]   ; Connections[i] (UNetConnection*)
    test    rcx, rcx
    jz      @OAEDZ_next
    mov     rcx, QWORD PTR [rcx + 030h]    ; PlayerController
    test    rcx, rcx
    jz      @OAEDZ_next
    call    GameModeBase_InitPawn           ; (PC in RCX)
@OAEDZ_next:
    inc     ebx
    jmp     @OAEDZ_loop

@OAEDZ_done:
    add     rsp, 20h
    pop     rsi
    pop     rbp
    pop     rbx
    xor     al, al
    ret
PEHOOK_OnAircraftExitedDropZone ENDP

; PEHOOK_ServerCreateBuildingActor - spawn a building piece
PEHOOK_ServerCreateBuildingActor PROC
    push    rbx
    push    rbp
    push    rsi
    push    rdi
    sub     rsp, 48h

    mov     rdi, rcx                        ; RDI = PC
    mov     rsi, rdx                        ; RSI = Params

    test    rdi, rdi
    jz      @SCBA_done
    test    rsi, rsi
    jz      @SCBA_done

    ; BuildingClass = Params->BuildingClassData.BuildingClass
    mov     rbx, QWORD PTR [rsi]
    test    rbx, rbx
    jz      @SCBA_done

    ; SpawnActor(BuildingClass, &BuildLoc, PC)
    mov     rcx, rbx
    lea     rdx, [rsi + 010h]               ; &BuildLoc
    mov     r8, rdi
    call    Spawners_SpawnActor
    mov     rbp, rax                        ; RBP = BuildingActor
    test    rbp, rbp
    jz      @SCBA_done

    ; DynamicBuildingPlacementType = 2 (DestroyAnythingThatCollides)
    mov     BYTE PTR [rbp + 04B0h], 2

    ; BuildingActor->Team = PC->PlayerState->TeamIndex
    mov     rax, QWORD PTR [rdi + 0248h]    ; PlayerState
    test    rax, rax
    jz      @SCBA_init
    movzx   ecx, BYTE PTR [rax + 0F60h]    ; TeamIndex
    mov     BYTE PTR [rbp + 04C5h], cl

@SCBA_init:
    ; InitializeKismetSpawnedBuildingActor(BuildingActor, BuildingOwner=self, PC)
    ; Params: BuildingOwner(8) + SpawningController(8) = 0x10 at [rsp+20h]
    mov     rax, QWORD PTR [pFn_InitKismetBuildingActor]
    test    rax, rax
    jnz     @SCBA_have_init
    lea     rcx, [szFn_InitKismetBuildingActor]
    call    SDK_FindObject
    mov     QWORD PTR [pFn_InitKismetBuildingActor], rax
@SCBA_have_init:
    test    rax, rax
    jz      @SCBA_done
    mov     QWORD PTR [rsp + 20h], rbp      ; BuildingOwner = BuildingActor
    mov     QWORD PTR [rsp + 28h], rdi      ; SpawningController = PC
    mov     rcx, rbp
    mov     rdx, rax
    lea     r8, [rsp + 20h]
    call    QWORD PTR [ProcessEvent]

@SCBA_done:
    add     rsp, 48h
    pop     rdi
    pop     rsi
    pop     rbp
    pop     rbx
    xor     al, al
    ret
PEHOOK_ServerCreateBuildingActor ENDP

; PEHOOK_ServerBeginEditingBuildingActor - start building edit mode
PEHOOK_ServerBeginEditingBuildingActor PROC
    push    rbx
    push    rbp
    push    rsi
    push    rdi
    push    r12
    sub     rsp, 60h

    mov     r12, rcx                        ; R12 = PC
    ; BuildingActorToEdit = Params[+0]
    mov     rax, QWORD PTR [rdx]
    mov     QWORD PTR [rsp + 30h], rax      ; save BuildingActorToEdit

    test    r12, r12
    jz      @SBEBA_done
    test    rax, rax
    jz      @SBEBA_done

    ; Pawn = PC->Pawn
    mov     rbx, QWORD PTR [r12 + ACONTROLLER_Pawn]
    test    rbx, rbx
    jz      @SBEBA_done

    ; GetEntryInSlot(PC, Slot=0, Item=0, Bars=Primary=0)
    mov     rcx, r12
    xor     edx, edx
    xor     r8d, r8d
    xor     r9d, r9d
    call    Inventory_GetEntryInSlot
    test    rax, rax
    jz      @SBEBA_done
    mov     rbp, rax                        ; RBP = &FFortItemEntry for edit tool

    ; ItemDef = entry[+0x18]
    mov     rdi, QWORD PTR [rbp + 018h]
    test    rdi, rdi
    jz      @SBEBA_done

    ; Copy FGuid from entry[+0x50]
    mov     rax, QWORD PTR [rbp + 050h]
    mov     QWORD PTR [rsp + 40h], rax
    mov     rax, QWORD PTR [rbp + 058h]
    mov     QWORD PTR [rsp + 48h], rax

    ; EquipWeaponDefinition(Pawn, ItemDef, &Guid)
    mov     rcx, rbx
    mov     rdx, rdi
    lea     r8, [rsp + 40h]
    call    Inventory_EquipWeaponDefinition

    ; EditTool = Pawn->CurrentWeapon
    mov     rsi, QWORD PTR [rbx + 07D0h]   ; AFortPawn::CurrentWeapon
    test    rsi, rsi
    jz      @SBEBA_done

    ; EditTool->EditActor = BuildingActorToEdit
    mov     rax, QWORD PTR [rsp + 30h]
    mov     QWORD PTR [rsi + 0AB0h], rax    ; AFortWeap_EditingTool::EditActor

    ; OnRep_EditActor(EditTool)
    mov     rax, QWORD PTR [pFn_OnRep_EditActor]
    test    rax, rax
    jnz     @SBEBA_have_ea
    lea     rcx, [szFn_OnRep_EditActor]
    call    SDK_FindObject
    mov     QWORD PTR [pFn_OnRep_EditActor], rax
@SBEBA_have_ea:
    test    rax, rax
    jz      @SBEBA_editing_player
    xor     r8d, r8d
    mov     QWORD PTR [rsp + 20h], r8
    mov     rcx, rsi
    mov     rdx, rax
    lea     r8, [rsp + 20h]
    call    QWORD PTR [ProcessEvent]

@SBEBA_editing_player:
    ; BuildingActorToEdit->EditingPlayer = Pawn->PlayerState
    mov     rcx, QWORD PTR [rsp + 30h]     ; BuildingActorToEdit
    test    rcx, rcx
    jz      @SBEBA_done
    mov     rax, QWORD PTR [rbx + APAWN_PlayerState]
    mov     QWORD PTR [rcx + 0C70h], rax   ; ABuildingSMActor::EditingPlayer

    ; OnRep_EditingPlayer(BuildingActorToEdit)
    mov     rax, QWORD PTR [pFn_OnRep_EditingPlayer]
    test    rax, rax
    jnz     @SBEBA_have_ep
    lea     rcx, [szFn_OnRep_EditingPlayer]
    call    SDK_FindObject
    mov     QWORD PTR [pFn_OnRep_EditingPlayer], rax
@SBEBA_have_ep:
    test    rax, rax
    jz      @SBEBA_done
    mov     rcx, QWORD PTR [rsp + 30h]
    xor     r8d, r8d
    mov     QWORD PTR [rsp + 20h], r8
    mov     rdx, rax
    lea     r8, [rsp + 20h]
    call    QWORD PTR [ProcessEvent]

@SBEBA_done:
    add     rsp, 60h
    pop     r12
    pop     rdi
    pop     rsi
    pop     rbp
    pop     rbx
    xor     al, al
    ret
PEHOOK_ServerBeginEditingBuildingActor ENDP

; PEHOOK_ServerEditBuildingActor - apply edit and re-spawn building
PEHOOK_ServerEditBuildingActor PROC
    push    rbx
    push    rbp
    push    rsi
    push    rdi
    push    r12
    sub     rsp, 70h

    mov     r12, rcx                        ; R12 = PC
    mov     rbx, QWORD PTR [rdx]            ; RBX = BuildingActorToEdit
    mov     rdi, QWORD PTR [rdx + 008h]     ; RDI = NewBuildingClass

    test    r12, r12
    jz      @SEBA_done
    test    rbx, rbx
    jz      @SEBA_done
    test    rdi, rdi
    jz      @SEBA_done

    ; K2_GetActorLocation(BuildingActor) -> RetValue FVector at [rsp+20h]
    mov     rax, QWORD PTR [pFn_K2_GetActorLocation]
    test    rax, rax
    jnz     @SEBA_have_loc
    lea     rcx, [szFn_K2_GetActorLocation]
    call    SDK_FindObject
    mov     QWORD PTR [pFn_K2_GetActorLocation], rax
@SEBA_have_loc:
    xor     esi, esi
    test    rax, rax
    jz      @SEBA_no_loc
    xor     esi, esi
    mov     DWORD PTR [rsp + 20h], esi      ; X = 0
    mov     DWORD PTR [rsp + 24h], esi      ; Y = 0
    mov     DWORD PTR [rsp + 28h], esi      ; Z = 0
    mov     rcx, rbx
    mov     rdx, rax
    lea     r8, [rsp + 20h]
    call    QWORD PTR [ProcessEvent]

@SEBA_no_loc:
    ; SilentDie(BuildingActor)
    mov     rax, QWORD PTR [pFn_SilentDie]
    test    rax, rax
    jnz     @SEBA_have_sd
    lea     rcx, [szFn_SilentDie]
    call    SDK_FindObject
    mov     QWORD PTR [pFn_SilentDie], rax
@SEBA_have_sd:
    test    rax, rax
    jz      @SEBA_spawn
    xor     esi, esi
    mov     QWORD PTR [rsp + 30h], rsi
    mov     rcx, rbx
    mov     rdx, rax
    lea     r8, [rsp + 30h]
    call    QWORD PTR [ProcessEvent]

@SEBA_spawn:
    ; SpawnActor(NewBuildingClass, &Location, PC)
    mov     rcx, rdi                        ; NewBuildingClass
    lea     rdx, [rsp + 20h]                ; &FVector (location)
    mov     r8, r12                         ; PC
    call    Spawners_SpawnActor
    mov     rbp, rax                        ; RBP = NewBuildingActor
    test    rbp, rbp
    jz      @SEBA_done

    ; DynamicBuildingPlacementType = 2
    mov     BYTE PTR [rbp + 04B0h], 2

    ; NewBuilding->Team = PC->PlayerState->TeamIndex
    mov     rax, QWORD PTR [r12 + 0248h]
    test    rax, rax
    jz      @SEBA_init
    movzx   ecx, BYTE PTR [rax + 0F60h]
    mov     BYTE PTR [rbp + 04C5h], cl

@SEBA_init:
    ; InitializeKismetSpawnedBuildingActor
    mov     rax, QWORD PTR [pFn_InitKismetBuildingActor]
    test    rax, rax
    jnz     @SEBA_have_init
    lea     rcx, [szFn_InitKismetBuildingActor]
    call    SDK_FindObject
    mov     QWORD PTR [pFn_InitKismetBuildingActor], rax
@SEBA_have_init:
    test    rax, rax
    jz      @SEBA_done
    mov     QWORD PTR [rsp + 38h], rbp      ; BuildingOwner = NewBuilding
    mov     QWORD PTR [rsp + 40h], r12      ; SpawningController = PC
    mov     rcx, rbp
    mov     rdx, rax
    lea     r8, [rsp + 38h]
    call    QWORD PTR [ProcessEvent]

@SEBA_done:
    add     rsp, 70h
    pop     r12
    pop     rdi
    pop     rsi
    pop     rbp
    pop     rbx
    xor     al, al
    ret
PEHOOK_ServerEditBuildingActor ENDP

; PEHOOK_ReadyToStartMatch - set up full listen-server infrastructure
; RCX = AFortGameModeAthena* (GameMode)
;
; Sequence:
;   1. Guard bListening - skip if already listening
;   2. Game_OnReadyToStartMatch()
;   3. Spawn AFortOnlineBeaconHost -> HostBeacon
;   4. Set ListenPort=7776 + InitHost
;   5. Init World NetDriver on port 7777
;   6. Resolve ServerReplicateActors from vtable slot 0x53
;   7. MaxPlayers=100, PauseBeaconRequests(false), bListening=true
;
; Stack: push rbp,rbx,rsi,rdi,r12,r13,r14 = 7 pushes (RSP=0); sub 80 -> 0 
;   [rsp+0..31]  = shadow
;   [rsp+32..79] = FURL struct (0x70 = 112 bytes)... actually needs sub 128 = 0 
;   With 7 pushes: RSP=0; sub 128(=0) -> 0 
;   FURL at [rsp+32..143]
PEHOOK_ReadyToStartMatch PROC
    push    rbp
    push    rbx
    push    rsi
    push    rdi
    push    r12
    push    r13
    push    r14
    sub     rsp, 128                ; 7 pushes: RSP=0; sub128(=0) -> 0 
                                    ; [rsp+32..143] = FURL local

    mov     rbx, rcx                ; GameMode

    ; Guard: already listening?
    movzx   eax, BYTE PTR [bListening]
    test    al, al
    jnz     @@done

    ; Game setup
    call    Game_OnReadyToStartMatch

    ; Spawn AFortOnlineBeaconHost
    mov     rax, QWORD PTR [pClass_FortOnlineBeaconHost]
    test    rax, rax
    jnz     @@have_beacon_class
    lea     rcx, szClass_FortOnlineBeaconHost
    call    SDK_FindClass
    mov     QWORD PTR [pClass_FortOnlineBeaconHost], rax
@@have_beacon_class:
    test    rax, rax
    jz      @@net_setup

    ; SpawnActor - use world + class + null transform + default flags
    call    SDK_GetWorld
    test    rax, rax
    jz      @@net_setup
    mov     r12, rax                ; World

    mov     rcx, QWORD PTR [pClass_FortOnlineBeaconHost]
    xor     edx, edx                ; Location = null (use zero)
    xor     r8d, r8d                ; Owner = null
    call    Spawners_SpawnActor

    test    rax, rax
    jz      @@net_setup
    mov     r13, rax                ; r13 = HostBeacon
    mov     QWORD PTR [HostBeacon], r13

    ; Set ListenPort = 7776
    mov     DWORD PTR [r13 + AOBH_ListenPort], LISTEN_BEACON_PORT

    ; InitHost(HostBeacon)
    mov     rcx, r13
    call    QWORD PTR [Native_OnlineBeaconHost_InitHost]

@@net_setup:
    ; Init World NetDriver on port 7777
    ; Build minimal FURL on stack: zero-init [rsp+32..143], set Port=7777
    lea     rcx, [rsp + 32]
    xor     edx, edx
    mov     r8d, 112                ; sizeof(FURL) = 0x70
    call    RtlZeroMemory
    mov     DWORD PTR [rsp + 32 + FURL_Port], LISTEN_GAME_PORT  ; FURL::Port at +0x20

    ; Native_NetDriver_InitListen(World?, ??, &FURL, false, &ErrorStr)

    ; Resolve ServerReplicateActors from ReplicationDriver vtable[0x53]
    call    SDK_GetWorld
    test    rax, rax
    jz      @@final_setup
    mov     rax, QWORD PTR [rax + UWORLD_NetDriver]        ; World->NetDriver
    test    rax, rax
    jz      @@final_setup
    mov     rax, QWORD PTR [rax + UNETDRIVER_ReplDriver]   ; NetDriver->ReplicationDriver
    test    rax, rax
    jz      @@final_setup

    mov     r14, rax                ; r14 = ReplicationDriver
    mov     rax, QWORD PTR [r14]    ; vtable ptr
    mov     rax, QWORD PTR [rax + VTABLE_ServerReplicateActors]  ; slot 0x53
    mov     QWORD PTR [Native_ReplicationDriver_ServerReplicateActors], rax

@@final_setup:
    ; PauseBeaconRequests(false) if beacon was spawned
    mov     rax, QWORD PTR [HostBeacon]
    test    rax, rax
    jz      @@set_listening
    mov     rcx, rax
    xor     edx, edx                ; false = don't pause
    call    QWORD PTR [Native_OnlineBeacon_PauseBeaconRequests]

@@set_listening:
    mov     BYTE PTR [bListening], 1

@@done:
    add     rsp, 128
    pop     r14
    pop     r13
    pop     r12
    pop     rdi
    pop     rsi
    pop     rbx
    pop     rbp
    xor     al, al
    ret
PEHOOK_ReadyToStartMatch ENDP

; UFunctionHooks_Initialize
; Resolves all 27 UFunction* pointers and fills the ToHook + ToCall arrays.
; Called once from UFunctionHooks_Initialize (triggered before Detours in Main).
;
; Uses rbp as the insertion index (callee-saved, pushed/popped correctly).
; Uses rsi = &_ToHook_Storage[0]
;     rdi = &_ToCall_Storage[0]
;
; Stack: push rbp,rbx,rsi,rdi,r12 = 5 pushes (RSP=8); sub 40(=8) -> 0 

; Helper macro-equivalent - inline for each registration:
; REGISTER rcx=szFnName, handler_label
;   lea  rcx, szFn_X
;   call SDK_FindObject
;   test rax,rax / jz skip
;   mov  [rsi + rbp*8], rax
;   lea  rax, HANDLER
;   mov  [rdi + rbp*8], rax
;   inc  ebp
; skip:

UFunctionHooks_Initialize PROC
    push    rbp
    push    rbx
    push    rsi
    push    rdi
    push    r12
    sub     rsp, 40                 ; 5 pushes: RSP=8; sub40 -> 0 

    ; Set public pointers to internal storage
    lea     rax, _ToHook_Storage
    mov     QWORD PTR [UFunctionHooks_ToHook_Data], rax
    lea     rax, _ToCall_Storage
    mov     QWORD PTR [UFunctionHooks_ToCall_Data], rax

    lea     rsi, _ToHook_Storage    ; hook fn ptr array base
    lea     rdi, _ToCall_Storage    ; handler fn ptr array base

    xor     ebp, ebp                ; index = 0

    ; ServerTryActivateAbility
    lea     rcx, szFn_ServerTryActivateAbility
    call    SDK_FindObject
    test    rax, rax
    jz      @@r1
    mov     QWORD PTR [rsi + rbp * 8], rax
    lea     rax, PEHOOK_ServerTryActivateAbility
    mov     QWORD PTR [rdi + rbp * 8], rax
    inc     ebp
@@r1:
    ; ServerTryActivateAbilityWithEventData
    lea     rcx, szFn_ServerTryActivateWithEventData
    call    SDK_FindObject
    test    rax, rax
    jz      @@r2
    mov     QWORD PTR [rsi + rbp * 8], rax
    lea     rax, PEHOOK_ServerTryActivateAbilityWithEventData
    mov     QWORD PTR [rdi + rbp * 8], rax
    inc     ebp
@@r2:
    ; ServerAbilityRPCBatch
    lea     rcx, szFn_ServerAbilityRPCBatch
    call    SDK_FindObject
    test    rax, rax
    jz      @@r3
    mov     QWORD PTR [rsi + rbp * 8], rax
    lea     rax, PEHOOK_ServerAbilityRPCBatch
    mov     QWORD PTR [rdi + rbp * 8], rax
    inc     ebp
@@r3:
    ; ServerHandlePickup
    lea     rcx, szFn_ServerHandlePickup
    call    SDK_FindObject
    test    rax, rax
    jz      @@r4
    mov     QWORD PTR [rsi + rbp * 8], rax
    lea     rax, PEHOOK_ServerHandlePickup
    mov     QWORD PTR [rdi + rbp * 8], rax
    inc     ebp
@@r4:
    ; CheatScript
    lea     rcx, szFn_CheatScript
    call    SDK_FindObject
    test    rax, rax
    jz      @@r5
    mov     QWORD PTR [rsi + rbp * 8], rax
    lea     rax, PEHOOK_CheatScript
    mov     QWORD PTR [rdi + rbp * 8], rax
    inc     ebp
@@r5:
    ; OnDeathServer
    lea     rcx, szFn_OnDeathServer
    call    SDK_FindObject
    test    rax, rax
    jz      @@r6
    mov     QWORD PTR [rsi + rbp * 8], rax
    lea     rax, PEHOOK_OnDeathServer
    mov     QWORD PTR [rdi + rbp * 8], rax
    inc     ebp
@@r6:
    ; ServerCreateBuildingActor
    lea     rcx, szFn_ServerCreateBuildingActor
    call    SDK_FindObject
    test    rax, rax
    jz      @@r7
    mov     QWORD PTR [rsi + rbp * 8], rax
    lea     rax, PEHOOK_ServerCreateBuildingActor
    mov     QWORD PTR [rdi + rbp * 8], rax
    inc     ebp
@@r7:
    ; ServerBeginEditingBuildingActor
    lea     rcx, szFn_ServerBeginEditingBuilding
    call    SDK_FindObject
    test    rax, rax
    jz      @@r8
    mov     QWORD PTR [rsi + rbp * 8], rax
    lea     rax, PEHOOK_ServerBeginEditingBuildingActor
    mov     QWORD PTR [rdi + rbp * 8], rax
    inc     ebp
@@r8:
    ; ServerSpawnDeco
    lea     rcx, szFn_ServerSpawnDeco
    call    SDK_FindObject
    test    rax, rax
    jz      @@r9
    mov     QWORD PTR [rsi + rbp * 8], rax
    lea     rax, PEHOOK_ServerSpawnDeco
    mov     QWORD PTR [rdi + rbp * 8], rax
    inc     ebp
@@r9:
    ; ServerEditBuildingActor
    lea     rcx, szFn_ServerEditBuildingActor
    call    SDK_FindObject
    test    rax, rax
    jz      @@r10
    mov     QWORD PTR [rsi + rbp * 8], rax
    lea     rax, PEHOOK_ServerEditBuildingActor
    mov     QWORD PTR [rdi + rbp * 8], rax
    inc     ebp
@@r10:
    ; ClientOnPawnDied
    lea     rcx, szFn_ClientOnPawnDied
    call    SDK_FindObject
    test    rax, rax
    jz      @@r11
    mov     QWORD PTR [rsi + rbp * 8], rax
    lea     rax, PEHOOK_ClientOnPawnDied
    mov     QWORD PTR [rdi + rbp * 8], rax
    inc     ebp
@@r11:
    ; ServerEndEditingBuildingActor
    lea     rcx, szFn_ServerEndEditingBuilding
    call    SDK_FindObject
    test    rax, rax
    jz      @@r12
    mov     QWORD PTR [rsi + rbp * 8], rax
    lea     rax, PEHOOK_ServerEndEditingBuildingActor
    mov     QWORD PTR [rdi + rbp * 8], rax
    inc     ebp
@@r12:
    ; ServerRepairBuildingActor
    lea     rcx, szFn_ServerRepairBuildingActor
    call    SDK_FindObject
    test    rax, rax
    jz      @@r13
    mov     QWORD PTR [rsi + rbp * 8], rax
    lea     rax, PEHOOK_ServerRepairBuildingActor
    mov     QWORD PTR [rdi + rbp * 8], rax
    inc     ebp
@@r13:
    ; ServerAttemptAircraftJump
    lea     rcx, szFn_ServerAttemptAircraftJump
    call    SDK_FindObject
    test    rax, rax
    jz      @@r14
    mov     QWORD PTR [rsi + rbp * 8], rax
    lea     rax, PEHOOK_ServerAttemptAircraftJump
    mov     QWORD PTR [rdi + rbp * 8], rax
    inc     ebp
@@r14:
    ; ServerReviveFromDBNO
    lea     rcx, szFn_ServerReviveFromDBNO
    call    SDK_FindObject
    test    rax, rax
    jz      @@r15
    mov     QWORD PTR [rsi + rbp * 8], rax
    lea     rax, PEHOOK_ServerReviveFromDBNO
    mov     QWORD PTR [rdi + rbp * 8], rax
    inc     ebp
@@r15:
    ; ServerAttemptInteract
    lea     rcx, szFn_ServerAttemptInteract
    call    SDK_FindObject
    test    rax, rax
    jz      @@r16
    mov     QWORD PTR [rsi + rbp * 8], rax
    lea     rax, PEHOOK_ServerAttemptInteract
    mov     QWORD PTR [rdi + rbp * 8], rax
    inc     ebp
@@r16:
    ; ServerPlayEmoteItem
    lea     rcx, szFn_ServerPlayEmoteItem
    call    SDK_FindObject
    test    rax, rax
    jz      @@r17
    mov     QWORD PTR [rsi + rbp * 8], rax
    lea     rax, PEHOOK_ServerPlayEmoteItem
    mov     QWORD PTR [rdi + rbp * 8], rax
    inc     ebp
@@r17:
    ; ServerAttemptInventoryDrop
    lea     rcx, szFn_ServerAttemptInventoryDrop
    call    SDK_FindObject
    test    rax, rax
    jz      @@r18
    mov     QWORD PTR [rsi + rbp * 8], rax
    lea     rax, PEHOOK_ServerAttemptInventoryDrop
    mov     QWORD PTR [rdi + rbp * 8], rax
    inc     ebp
@@r18:
    ; OnSpawnOutAnimEnded
    lea     rcx, szFn_OnSpawnOutAnimEnded
    call    SDK_FindObject
    test    rax, rax
    jz      @@r19
    mov     QWORD PTR [rsi + rbp * 8], rax
    lea     rax, PEHOOK_OnSpawnOutAnimEnded
    mov     QWORD PTR [rdi + rbp * 8], rax
    inc     ebp
@@r19:
    ; ServerExecuteInventoryItem
    lea     rcx, szFn_ServerExecuteInventoryItem
    call    SDK_FindObject
    test    rax, rax
    jz      @@r20
    mov     QWORD PTR [rsi + rbp * 8], rax
    lea     rax, PEHOOK_ServerExecuteInventoryItem
    mov     QWORD PTR [rdi + rbp * 8], rax
    inc     ebp
@@r20:
    ; ServerReturnToMainMenu
    lea     rcx, szFn_ServerReturnToMainMenu
    call    SDK_FindObject
    test    rax, rax
    jz      @@r21
    mov     QWORD PTR [rsi + rbp * 8], rax
    lea     rax, PEHOOK_ServerReturnToMainMenu
    mov     QWORD PTR [rdi + rbp * 8], rax
    inc     ebp
@@r21:
    ; ServerLoadingScreenDropped
    lea     rcx, szFn_ServerLoadingScreenDropped
    call    SDK_FindObject
    test    rax, rax
    jz      @@r22
    mov     QWORD PTR [rsi + rbp * 8], rax
    lea     rax, PEHOOK_ServerLoadingScreenDropped
    mov     QWORD PTR [rdi + rbp * 8], rax
    inc     ebp
@@r22:
    ; ServerChoosePart
    lea     rcx, szFn_ServerChoosePart
    call    SDK_FindObject
    test    rax, rax
    jz      @@r23
    mov     QWORD PTR [rsi + rbp * 8], rax
    lea     rax, PEHOOK_ServerChoosePart
    mov     QWORD PTR [rdi + rbp * 8], rax
    inc     ebp
@@r23:
    ; ReadyToStartMatch
    lea     rcx, szFn_ReadyToStartMatch
    call    SDK_FindObject
    test    rax, rax
    jz      @@r24
    mov     QWORD PTR [rsi + rbp * 8], rax
    lea     rax, PEHOOK_ReadyToStartMatch
    mov     QWORD PTR [rdi + rbp * 8], rax
    inc     ebp
@@r24:
    ; OnAircraftExitedDropZone
    lea     rcx, szFn_OnAircraftExitedDropZone
    call    SDK_FindObject
    test    rax, rax
    jz      @@r25
    mov     QWORD PTR [rsi + rbp * 8], rax
    lea     rax, PEHOOK_OnAircraftExitedDropZone
    mov     QWORD PTR [rdi + rbp * 8], rax
    inc     ebp
@@r25:
    ; ServerCheatAll
    lea     rcx, szFn_ServerCheatAll
    call    SDK_FindObject
    test    rax, rax
    jz      @@r26
    mov     QWORD PTR [rsi + rbp * 8], rax
    lea     rax, PEHOOK_ServerCheatAll
    mov     QWORD PTR [rdi + rbp * 8], rax
    inc     ebp
@@r26:
    ; Logout
    lea     rcx, szFn_Logout
    call    SDK_FindObject
    test    rax, rax
    jz      @@r27
    mov     QWORD PTR [rsi + rbp * 8], rax
    lea     rax, PEHOOK_Logout
    mov     QWORD PTR [rdi + rbp * 8], rax
    inc     ebp
@@r27:

    ; Store final count
    mov     DWORD PTR [UFunctionHooks_ToHook_Num], ebp

    ; Also lazily prime the ForceNetUpdate UFunction pointer
    lea     rcx, szFn_ForceNetUpdate
    call    SDK_FindObject
    mov     QWORD PTR [pFn_ForceNetUpdate], rax

    ; Log registration count
    lea     rcx, szHookCount
    mov     edx, ebp
    call    Logger_LogInfoFmt

    add     rsp, 40
    pop     r12
    pop     rdi
    pop     rsi
    pop     rbx
    pop     rbp
    ret
UFunctionHooks_Initialize ENDP

END