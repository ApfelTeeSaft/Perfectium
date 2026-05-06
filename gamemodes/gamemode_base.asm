INCLUDE asm\include\master.inc

; GMB struct offsets
GMB_Teams               EQU 000h
GMB_maxHealth           EQU 008h
GMB_maxShield           EQU 00Ch
GMB_bRespawnEnabled     EQU 010h
GMB_bRegenEnabled       EQU 011h
GMB_bRejoinEnabled      EQU 012h
GMB_BasePlaylist        EQU 018h
GMB_OnPlayerJoined      EQU 020h
GMB_SIZEOF              EQU 028h

; UE4 field offsets
; AActor
AACTOR_Owner                EQU 0108h
AACTOR_bRepMove_byte        EQU 0080h   ; bit 3 = bReplicateMovement mask 0x08
AACTOR_bCanDamaged_byte     EQU 0081h   ; bit 7 = bCanBeDamaged mask 0x80
AACTOR_NetCullDistSq        EQU 0128h

; AController
ACTRL_PlayerState           EQU 0320h
ACTRL_Pawn                  EQU 0348h
ACTRL_Character             EQU 0358h

; APlayerController
APC_AcknowledgedPawn        EQU 0388h

; ACharacter
ACHAR_CharMoveComp          EQU 0380h

; AFortPlayerController
AFPC_bFlagsAt0698           EQU 0698h   ; byte: bit1=bIsDisconnecting, bit3=bHasInitiallySpawned
AFPC_bIsDisconnecting_mask  EQU 002h    ; bit 1
AFPC_bHasInitSpawned_mask   EQU 008h    ; bit 3
AFPC_bHasClientFinLoad      EQU 0738h   ; bool
AFPC_bHasServerFinLoad      EQU 0739h   ; bool

; AFortPlayerStatePvP
AFPS_bFlagsAt04E0           EQU 04E0h   ; byte: bit2=bHasFinishedLoading, bit3=bHasStartedPlaying
AFPS_bHasFinLoad_mask       EQU 004h
AFPS_bHasStartPlay_mask     EQU 008h
AFPS_HeroType               EQU 0528h
AFPS_CharacterParts         EQU 07F8h   ; UCustomCharacterPart*[6], each 8 bytes

; AFortPawn
AFPAWN_HealthSet            EQU 0C90h
AFPAWN_AbilitySystemComp    EQU 0CD8h
AFPAWN_HealthRegenDelayGE   EQU 0BE0h
AFPAWN_HealthRegenGE        EQU 0BE8h
AFPAWN_ShieldRegenDelayGE   EQU 0BF0h
AFPAWN_ShieldRegenGE        EQU 0BF8h

; UFortHealthSet (relative to HealthSet object base)
; FFortGameplayAttributeData Health at +0x0030; Minimum field at +0x0010 within it
FHEALTHSET_HealthMin        EQU 0040h   ; Health.Minimum
FHEALTHSET_ShieldMin        EQU 0080h   ; CurrentShield.Minimum

; UFortPlaylistAthena
FPAL_FriendlyFireType       EQU 0058h
FPAL_bNoDBNO                EQU 0060h
FPAL_PlaylistId             EQU 0180h
FPAL_RespawnType            EQU 019Eh
FPAL_RespawnLocation        EQU 019Fh

; AFortGameStateAthena
AFGSA_CurrentPlaylistId     EQU 1524h
AFGSA_CurrentPlaylistData   EQU 1BA0h

; UFortGameInstance
UGAMEINST_RegisteredPlayers EQU 06F8h   ; TArray<UFortRegisteredPlayerInfo*>

; UFortRegisteredPlayerInfo
UFRI_AthenaMenuHeroDef      EQU 0260h   ; UFortHero*

; UWorld (from game.asm EQUs)
UWORLD_GameState            EQU 0148h
UWORLD_OwningGameInstance   EQU 0190h

; Enum values
EFriendlyFireType_On        EQU 1
EAthenaRespawnLocation_Air  EQU 0
EAthenaRespawnType_Infinite EQU 1
MOVE_Custom                 EQU 6       ; EMovementMode::MOVE_Custom
EFortQuickBars_Primary      EQU 0

.const

; GameState OnRep paths
szFn_OnRep_PlaylistId   DB "Function FortniteGame.FortGameStateAthena.OnRep_CurrentPlaylistId", 0
szFn_OnRep_PlaylistData DB "Function FortniteGame.FortGameStateAthena.OnRep_CurrentPlaylistData", 0

; Actor / controller OnRep paths
szFn_OnRep_Owner        DB "Function Engine.Actor.OnRep_Owner", 0
szFn_OnRep_Pawn         DB "Function Engine.Controller.OnRep_Pawn", 0
szFn_Possess            DB "Function Engine.Controller.Possess", 0
szFn_OnRep_ServerFin    DB "Function FortniteGame.FortPlayerController.OnRep_bHasServerFinishedLoading", 0

; PlayerState OnRep paths
szFn_OnRep_StartPlay    DB "Function FortniteGame.FortPlayerState.OnRep_bHasStartedPlaying", 0
szFn_OnRep_HeroType     DB "Function FortniteGame.FortPlayerState.OnRep_HeroType", 0
szFn_OnRep_CharParts    DB "Function FortniteGame.FortPlayerState.OnRep_CharacterParts", 0

; Pawn paths
szFn_SetMaxHealth       DB "Function FortniteGame.FortPawn.SetMaxHealth", 0
szFn_SetMaxShield       DB "Function FortniteGame.FortPawn.SetMaxShield", 0
szFn_OnRep_RepMove      DB "Function Engine.Actor.OnRep_ReplicateMovement", 0

; Hero
szFn_GetHeroTypeBP      DB "Function FortniteGame.FortHero.GetHeroTypeBP", 0

; Inventory / abilities / drone
szFn_InitDrone          DB "Function BP_VictoryDrone.BP_VictoryDrone_C.InitDrone", 0
szFn_TriggerSpawnFX     DB "Function BP_VictoryDrone.BP_VictoryDrone_C.TriggerPlayerSpawnEffects", 0

; Respawn path
szFn_RespawnAfterDeath  DB "Function FortniteGame.FortPlayerControllerAthena.RespawnPlayerAfterDeath", 0
szFn_K2_TeleportTo      DB "Function Engine.Actor.K2_TeleportTo", 0
szFn_SetMovementMode    DB "Function Engine.CharacterMovementComponent.SetMovementMode", 0
szFn_K2_DestroyActor    DB "Function Engine.Actor.K2_DestroyActor", 0
szFn_K2_GetActorLoc     DB "Function Engine.Actor.K2_GetActorLocation", 0

; ActivateSlot for LoadKilledPlayer
szFn_ActivateSlot       DB "Function FortniteGame.FortPlayerController.ActivateSlot", 0

; SDK class/object search strings
szClass_PlayerPawn      DB "BlueprintGeneratedClass PlayerPawn_Athena.PlayerPawn_Athena_C", 0
szClass_VictoryDrone    DB "BlueprintGeneratedClass BP_VictoryDrone.BP_VictoryDrone_C", 0
szObj_HeadPart          DB "CustomCharacterPart F_Med_Head1.F_Med_Head1", 0
szObj_BodyPart          DB "CustomCharacterPart F_Med_Soldier_01.F_Med_Soldier_01", 0

; WID object search paths (FortWeaponRangedItemDefinition prefix, matching original C++ FindWID)
szWID_Pickaxe   DB "WID_Harvest_Pickaxe_Athena_C_T01.WID_Harvest_Pickaxe_Athena_C_T01", 0
szWID_Pump1     DB "WID_Shotgun_Standard_Athena_UC_Ore_T03.WID_Shotgun_Standard_Athena_UC_Ore_T03", 0
szWID_AR        DB "WID_Assault_AutoHigh_Athena_SR_Ore_T03.WID_Assault_AutoHigh_Athena_SR_Ore_T03", 0
szWID_Sniper    DB "WID_Sniper_BoltAction_Scope_Athena_R_Ore_T03.WID_Sniper_BoltAction_Scope_Athena_R_Ore_T03", 0
szWID_Shield    DB "Athena_Shields.Athena_Shields", 0

szLogNew        DB "[GAMEMODE] Creating new game mode", 0
szLogLoad       DB "[GAMEMODE] Player joined - initializing", 0
szLogInitPawn   DB "[GAMEMODE] InitPawn called", 0
szLogRespawn    DB "[GAMEMODE] Respawning player", 0
szLogDeath      DB "[GAMEMODE] Player killed", 0

.data?

; Globally exported current game mode struct pointer
GMB_Current             QWORD   ?

; UFunction caches
pFn_OnRep_PlaylistId    QWORD   ?
pFn_OnRep_PlaylistData  QWORD   ?
pFn_OnRep_Owner         QWORD   ?
pFn_OnRep_Pawn          QWORD   ?
pFn_Possess             QWORD   ?
pFn_OnRep_ServerFin     QWORD   ?
pFn_OnRep_StartPlay     QWORD   ?
pFn_OnRep_HeroType      QWORD   ?
pFn_OnRep_CharParts     QWORD   ?
pFn_SetMaxHealth        QWORD   ?
pFn_SetMaxShield        QWORD   ?
pFn_OnRep_RepMove       QWORD   ?
pFn_GetHeroTypeBP       QWORD   ?
pFn_InitDrone           QWORD   ?
pFn_TriggerSpawnFX      QWORD   ?
pFn_RespawnAfterDeath   QWORD   ?
pFn_K2_TeleportTo       QWORD   ?
pFn_SetMovementMode     QWORD   ?
pFn_ActivateSlot        QWORD   ?
pFn_K2_DestroyActor_GMB QWORD   ?
pFn_K2_GetActorLoc_GMB  QWORD   ?

; Class caches
pClass_PlayerPawn       QWORD   ?
pClass_VictoryDrone     QWORD   ?
pObj_HeadPart           QWORD   ?
pObj_BodyPart           QWORD   ?

; Static WID array (GetPlaylistLoadout result)
GMB_WIDs                QWORD   6 dup (?)   ; [Pickaxe, Pump, Pump, AR, Sniper, Shield]

.code

; Internal helper: GMB__LoadFn
;   RSI (caller's) = &cache QWORD
;   RDI (caller's) = &szPath
;   Returns: RAX = UFunction* (0 = not found)
; Stack alignment: entry RSP = 8; sub 28h -> RSP = 0 before call
GMB__LoadFn PROC
    mov     rax, QWORD PTR [rsi]
    test    rax, rax
    jnz     @@done
    sub     rsp, 28h
    mov     rcx, rdi
    call    SDK_FindObject
    add     rsp, 28h
    mov     QWORD PTR [rsi], rax
@@done:
    ret
GMB__LoadFn ENDP

; Internal macro-pattern for lazy fn-load without helper.
; Used inline where RSI/RDI are occupied.
; (inline the pattern directly in each caller)

; GameModeBase_OnPlayerJoined_Default - no-op base implementation
; In: RCX = PC (unused)
GameModeBase_OnPlayerJoined_Default PROC
    ret
GameModeBase_OnPlayerJoined_Default ENDP

; GameModeBase_isRespawnEnabled - return GMB_Current->bRespawnEnabled
; Out: AL = bool
GameModeBase_isRespawnEnabled PROC
    mov     rax, QWORD PTR [GMB_Current]
    test    rax, rax
    jz      @@false
    movzx   eax, BYTE PTR [rax + GMB_bRespawnEnabled]
    ret
@@false:
    xor     eax, eax
    ret
GameModeBase_isRespawnEnabled ENDP

; GameModeBase_StartMatch
GameModeBase_StartMatch PROC
    ret
GameModeBase_StartMatch ENDP

; GameModeBase_GetLoadout - return pointer to static 6-WID array
;
; Lazily initialises GMB_WIDs on first call.
; Out: RAX = QWORD* pointing to GMB_WIDs[0]
;
; Frame: 4 pushes (RBX,RBP,RSI,RDI) + sub 28h = 4*8+40=72 total
;   N=4(even): sub=8 -> sub 28h(40)
;   [0..1F]=shadow
GameModeBase_GetLoadout PROC
    push    rbx
    push    rbp
    push    rsi
    push    rdi
    sub     rsp, 28h

    ; Check if already initialised (Pickaxe != 0)
    mov     rax, QWORD PTR [GMB_WIDs + 0]
    test    rax, rax
    jnz     @@done

    ; WID[0] = Pickaxe
    lea     rcx, [szWID_Pickaxe]
    call    SDK_FindObject
    mov     QWORD PTR [GMB_WIDs + 0], rax

    ; WID[1] = Pump (slot 1)
    lea     rcx, [szWID_Pump1]
    call    SDK_FindObject
    mov     QWORD PTR [GMB_WIDs + 8], rax

    ; WID[2] = Pump (slot 2, same def)
    mov     QWORD PTR [GMB_WIDs + 16], rax

    ; WID[3] = Gold AR
    lea     rcx, [szWID_AR]
    call    SDK_FindObject
    mov     QWORD PTR [GMB_WIDs + 24], rax

    ; WID[4] = Bolt Sniper
    lea     rcx, [szWID_Sniper]
    call    SDK_FindObject
    mov     QWORD PTR [GMB_WIDs + 32], rax

    ; WID[5] = Big Shield
    lea     rcx, [szWID_Shield]
    call    SDK_FindObject
    mov     QWORD PTR [GMB_WIDs + 40], rax

@@done:
    lea     rax, [GMB_WIDs]
    add     rsp, 28h
    pop     rdi
    pop     rsi
    pop     rbp
    pop     rbx
    ret
GameModeBase_GetLoadout ENDP

; GameModeBase_New - constructor
;
; In:  RCX = PlaylistPath (const char*)
;      DL  = bRespawnEnabled (BYTE)
;      R8D = maxTeamSize (DWORD, signed; -2 = 50v50 round-robin)
;      R9B = bRegenEnabled (BYTE)
;      [rsp+28h] = bRejoinEnabled (BYTE) - 5th arg on caller's stack
; Out: RAX = GMB* (also stored in GMB_Current)
;
; Frame: 6 pushes (RBX,RBP,RSI,RDI,R12,R13) + sub 48h = 6*8+72=120
;   N=6(even): sub=8 -> sub 48h(72)  RSP_final=0
;   5th arg = [rsp + 120 + 28h] = [rsp + 0A0h]
;   [0..1F]=shadow, [20..27]=GameState*, [28..47]=PE param scratch
GameModeBase_New PROC
    push    rbx
    push    rbp
    push    rsi
    push    rdi
    push    r12
    push    r13
    sub     rsp, 48h

    ; Save arguments to callee-saved registers
    mov     rdi, rcx                                    ; RDI = PlaylistPath
    movzx   ebp, dl                                     ; RBP = bRespawnEnabled
    mov     esi, r8d                                    ; RSI = maxTeamSize
    movzx   r12d, r9b                                   ; R12 = bRegenEnabled
    movzx   r13d, BYTE PTR [rsp + 0A0h]                 ; R13 = bRejoinEnabled

    ; Allocate GMB struct
    mov     ecx, GMB_SIZEOF
    mov     edx, 8
    call    QWORD PTR [FMemory_Malloc]
    test    rax, rax
    jz      @@done
    mov     rbx, rax                                    ; RBX = GMB*

    ; Zero the allocation
    mov     rcx, rbx
    xor     edx, edx
    mov     r8d, GMB_SIZEOF
    call    memset

    ; Set defaults
    mov     DWORD PTR [rbx + GMB_maxHealth], 100
    mov     DWORD PTR [rbx + GMB_maxShield], 100
    mov     BYTE PTR  [rbx + GMB_bRespawnEnabled], bpl
    mov     BYTE PTR  [rbx + GMB_bRegenEnabled],   r12b
    mov     BYTE PTR  [rbx + GMB_bRejoinEnabled],  r13b

    ; Default OnPlayerJoined = base no-op
    lea     rax, [GameModeBase_OnPlayerJoined_Default]
    mov     QWORD PTR [rbx + GMB_OnPlayerJoined], rax

    ; Find UFortPlaylistAthena object
    mov     rcx, rdi
    call    SDK_FindObject
    test    rax, rax
    jz      @@setup_teams
    mov     QWORD PTR [rbx + GMB_BasePlaylist], rax     ; save playlist ptr

    ; playlist->bNoDBNO = (maxTeamSize > 1)
    xor     ecx, ecx
    cmp     esi, 1
    jle     @@set_nodbnomov
    mov     ecx, 1
@@set_nodbnomov:
    mov     BYTE PTR [rax + FPAL_bNoDBNO], cl

    ; If bRespawnEnabled: configure respawn playlist fields
    test    ebp, ebp
    jz      @@setup_gamestate
    mov     BYTE PTR [rax + FPAL_FriendlyFireType], EFriendlyFireType_On
    mov     BYTE PTR [rax + FPAL_RespawnLocation],  EAthenaRespawnLocation_Air
    mov     BYTE PTR [rax + FPAL_RespawnType],      EAthenaRespawnType_Infinite

@@setup_gamestate:
    ; Get World -> GameState
    call    SDK_GetWorld
    test    rax, rax
    jz      @@setup_teams
    mov     rax, QWORD PTR [rax + UWORLD_GameState]
    test    rax, rax
    jz      @@setup_teams
    mov     QWORD PTR [rsp + 20h], rax                  ; [rsp+20h] = GameState*

    ; GameState->CurrentPlaylistId = playlist->PlaylistId
    mov     rdx, QWORD PTR [rbx + GMB_BasePlaylist]
    test    rdx, rdx
    jz      @@skip_gs_playlist
    mov     ecx, DWORD PTR [rdx + FPAL_PlaylistId]
    mov     DWORD PTR [rax + AFGSA_CurrentPlaylistId], ecx
    mov     QWORD PTR [rax + AFGSA_CurrentPlaylistData], rdx

@@skip_gs_playlist:
    ; OnRep_CurrentPlaylistId
    mov     rax, QWORD PTR [pFn_OnRep_PlaylistId]
    test    rax, rax
    jnz     @@plid_ok
    lea     rcx, [szFn_OnRep_PlaylistId]
    call    SDK_FindObject
    mov     QWORD PTR [pFn_OnRep_PlaylistId], rax
@@plid_ok:
    test    rax, rax
    jz      @@skip_onrep_plid
    mov     QWORD PTR [rsp + 28h], 0
    mov     rcx, QWORD PTR [rsp + 20h]                  ; GameState
    mov     rdx, rax                                    ; UFunction*
    lea     r8, [rsp + 28h]                             ; empty params
    call    QWORD PTR [ProcessEvent]

@@skip_onrep_plid:
    ; OnRep_CurrentPlaylistData
    mov     rax, QWORD PTR [pFn_OnRep_PlaylistData]
    test    rax, rax
    jnz     @@pldata_ok
    lea     rcx, [szFn_OnRep_PlaylistData]
    call    SDK_FindObject
    mov     QWORD PTR [pFn_OnRep_PlaylistData], rax
@@pldata_ok:
    test    rax, rax
    jz      @@setup_teams
    mov     QWORD PTR [rsp + 28h], 0
    mov     rcx, QWORD PTR [rsp + 20h]
    mov     rdx, rax
    lea     r8, [rsp + 28h]
    call    QWORD PTR [ProcessEvent]

@@setup_teams:
    ; PlayerTeams_New(maxTeamSize)
    mov     ecx, esi
    call    PlayerTeams_New
    mov     QWORD PTR [rbx + GMB_Teams], rax

    ; Store in global and return
    mov     QWORD PTR [GMB_Current], rbx
    mov     rax, rbx

@@done:
    add     rsp, 48h
    pop     r13
    pop     r12
    pop     rdi
    pop     rsi
    pop     rbp
    pop     rbx
    ret
GameModeBase_New ENDP

; GameModeBase_InitPawn - spawn a new pawn and link it to PC
;
; In:  RCX = AFortPlayerControllerAthena* (PC)
;           (uses GMB_Current for maxHealth/maxShield/bRegen)
; Out: none
;
; Frame: 7 pushes (RBX,RBP,RSI,RDI,R12,R13,R14) + sub 40h = 7*8+64=120
;   N=7(odd): sub=0 -> sub 40h(64)  RSP_final=0
;   [0..1F]=shadow, [20..3F]=PE param scratch (32 bytes)
GameModeBase_InitPawn PROC
    push    rbx
    push    rbp
    push    rsi
    push    rdi
    push    r12
    push    r13
    push    r14
    sub     rsp, 40h

    mov     rbx, rcx                                    ; RBX = PC
    mov     r13, QWORD PTR [GMB_Current]                ; R13 = GMB* (may be 0)

    ; Find / cache APlayerPawn_Athena_C class
    mov     rax, QWORD PTR [pClass_PlayerPawn]
    test    rax, rax
    jnz     @@class_ok
    lea     rcx, [szClass_PlayerPawn]
    call    SDK_FindObject
    mov     QWORD PTR [pClass_PlayerPawn], rax
@@class_ok:
    test    rax, rax
    jz      @@done

    ; Spawn pawn at default location
    ; Default loc = {1250, 1818, 3284}
    ; Put FVector in [rsp+20h..+2B] for Spawners_SpawnActor
    mov     DWORD PTR [rsp + 20h], 449C4000h            ; X = 1250.0f
    mov     DWORD PTR [rsp + 24h], 44E36000h            ; Y = 1818.0f
    mov     DWORD PTR [rsp + 28h], 454D2000h            ; Z = 3284.0f

    mov     rcx, rax                                    ; actorClass
    lea     rdx, [rsp + 20h]                            ; &defaultLoc
    mov     r8, rbx                                     ; Owner = PC
    call    Spawners_SpawnActor
    test    rax, rax
    jz      @@done
    mov     rsi, rax                                    ; RSI = Pawn*

    ; Link pawn to controller
    mov     QWORD PTR [rsi + AACTOR_Owner], rbx         ; Pawn->Owner = PC
    mov     QWORD PTR [rbx + ACTRL_Pawn], rsi           ; PC->Pawn = Pawn
    mov     QWORD PTR [rbx + APC_AcknowledgedPawn], rsi ; PC->AcknowledgedPawn = Pawn

    ; OnRep_Owner (on Pawn)
    mov     rax, QWORD PTR [pFn_OnRep_Owner]
    test    rax, rax
    jnz     @@own_ok
    lea     rcx, [szFn_OnRep_Owner]
    call    SDK_FindObject
    mov     QWORD PTR [pFn_OnRep_Owner], rax
@@own_ok:
    test    rax, rax
    jz      @@skip_own
    mov     QWORD PTR [rsp + 20h], 0
    mov     rcx, rsi
    mov     rdx, rax
    lea     r8, [rsp + 20h]
    call    QWORD PTR [ProcessEvent]

@@skip_own:
    ; OnRep_Pawn (on Controller)
    mov     rax, QWORD PTR [pFn_OnRep_Pawn]
    test    rax, rax
    jnz     @@pawn_ok
    lea     rcx, [szFn_OnRep_Pawn]
    call    SDK_FindObject
    mov     QWORD PTR [pFn_OnRep_Pawn], rax
@@pawn_ok:
    test    rax, rax
    jz      @@skip_pawn
    mov     QWORD PTR [rsp + 20h], 0
    mov     rcx, rbx
    mov     rdx, rax
    lea     r8, [rsp + 20h]
    call    QWORD PTR [ProcessEvent]

@@skip_pawn:
    ; Possess(Pawn) - ProcessEvent on Controller with InPawn param
    mov     rax, QWORD PTR [pFn_Possess]
    test    rax, rax
    jnz     @@poss_ok
    lea     rcx, [szFn_Possess]
    call    SDK_FindObject
    mov     QWORD PTR [pFn_Possess], rax
@@poss_ok:
    test    rax, rax
    jz      @@skip_poss
    mov     QWORD PTR [rsp + 20h], rsi                  ; InPawn = Pawn
    mov     rcx, rbx
    mov     rdx, rax
    lea     r8, [rsp + 20h]
    call    QWORD PTR [ProcessEvent]

@@skip_poss:
    ; SetMaxHealth and SetMaxShield via ProcessEvent
    ; Default maxHealth/maxShield = 100 (from GMB or constant)
    mov     DWORD PTR [rsp + 20h], 42C80000h            ; 100.0f
    test    r13, r13
    jz      @@use_default_health
    cvtsi2ss xmm0, DWORD PTR [r13 + GMB_maxHealth]
    movss   DWORD PTR [rsp + 20h], xmm0

@@use_default_health:
    mov     rax, QWORD PTR [pFn_SetMaxHealth]
    test    rax, rax
    jnz     @@mh_ok
    lea     rcx, [szFn_SetMaxHealth]
    call    SDK_FindObject
    mov     QWORD PTR [pFn_SetMaxHealth], rax
@@mh_ok:
    test    rax, rax
    jz      @@skip_mh
    mov     rcx, rsi
    mov     rdx, rax
    lea     r8, [rsp + 20h]
    call    QWORD PTR [ProcessEvent]

@@skip_mh:
    mov     DWORD PTR [rsp + 20h], 42C80000h            ; 100.0f
    test    r13, r13
    jz      @@use_default_shield
    cvtsi2ss xmm0, DWORD PTR [r13 + GMB_maxShield]
    movss   DWORD PTR [rsp + 20h], xmm0

@@use_default_shield:
    mov     rax, QWORD PTR [pFn_SetMaxShield]
    test    rax, rax
    jnz     @@ms_ok
    lea     rcx, [szFn_SetMaxShield]
    call    SDK_FindObject
    mov     QWORD PTR [pFn_SetMaxShield], rax
@@ms_ok:
    test    rax, rax
    jz      @@skip_ms
    mov     rcx, rsi
    mov     rdx, rax
    lea     r8, [rsp + 20h]
    call    QWORD PTR [ProcessEvent]

@@skip_ms:
    ; Remove regen effects if !bRegenEnabled
    test    r13, r13
    jz      @@clear_regen                               ; no GMB -> assume not regen
    movzx   eax, BYTE PTR [r13 + GMB_bRegenEnabled]
    test    eax, eax
    jnz     @@set_minimums

@@clear_regen:
    ; Null out the 4 regen GameplayEffect class pointers on the Pawn
    xor     eax, eax
    mov     QWORD PTR [rsi + AFPAWN_HealthRegenDelayGE], rax
    mov     QWORD PTR [rsi + AFPAWN_HealthRegenGE],      rax
    mov     QWORD PTR [rsi + AFPAWN_ShieldRegenDelayGE], rax
    mov     QWORD PTR [rsi + AFPAWN_ShieldRegenGE],      rax

@@set_minimums:
    ; Set HealthSet minimums to 0 (disable spawn island protection)
    mov     rdi, QWORD PTR [rsi + AFPAWN_HealthSet]     ; RDI = HealthSet*
    test    rdi, rdi
    jz      @@set_replicate
    xor     eax, eax
    mov     DWORD PTR [rdi + FHEALTHSET_HealthMin], eax ; Health.Minimum = 0.0f
    mov     DWORD PTR [rdi + FHEALTHSET_ShieldMin], eax ; CurrentShield.Minimum = 0.0f

@@set_replicate:
    ; bReplicateMovement = true
    or      BYTE PTR [rsi + AACTOR_bRepMove_byte], 08h  ; set bit 3

    ; OnRep_ReplicateMovement (on Pawn)
    mov     rax, QWORD PTR [pFn_OnRep_RepMove]
    test    rax, rax
    jnz     @@repmo_ok
    lea     rcx, [szFn_OnRep_RepMove]
    call    SDK_FindObject
    mov     QWORD PTR [pFn_OnRep_RepMove], rax
@@repmo_ok:
    test    rax, rax
    jz      @@call_inv_update
    mov     QWORD PTR [rsp + 20h], 0
    mov     rcx, rsi
    mov     rdx, rax
    lea     r8, [rsp + 20h]
    call    QWORD PTR [ProcessEvent]

@@call_inv_update:
    ; Inventory_Update(PC)
    mov     rcx, rbx
    xor     edx, edx
    xor     r8d, r8d
    call    Inventory_Update

    ; Abilities_ApplyAbilities(Pawn)
    mov     rcx, rsi
    call    Abilities_ApplyAbilities

@@done:
    add     rsp, 40h
    pop     r14
    pop     r13
    pop     r12
    pop     rdi
    pop     rsi
    pop     rbp
    pop     rbx
    ret
GameModeBase_InitPawn ENDP

; GameModeBase_LoadPlayer - full player join initialisation
;
; In:  RCX = AFortPlayerControllerAthena* (PC)
; Out: none
;
; Frame: 7 pushes (RBX,RBP,RSI,RDI,R12,R13,R14) + sub 60h = 7*8+96=152
;   N=7(odd): sub=0 -> sub 60h(96)  RSP_final=0
;   [0..1F]=shadow, [20..5F]=PE param scratch (64 bytes)
GameModeBase_LoadPlayer PROC
    push    rbx
    push    rbp
    push    rsi
    push    rdi
    push    r12
    push    r13
    push    r14
    sub     rsp, 60h

    mov     rbx, rcx                                    ; RBX = PC
    mov     r14, QWORD PTR [GMB_Current]                ; R14 = GMB*

    ; Check bus-started + rejoin
    ; If bStartedBus && !bRejoinEnabled: return early (simplified: no kick)
    movzx   eax, BYTE PTR [bStartedBus]
    test    eax, eax
    jz      @@spawn_pawn                                ; bus not started, allow
    test    r14, r14
    jz      @@spawn_pawn
    movzx   eax, BYTE PTR [r14 + GMB_bRejoinEnabled]
    test    eax, eax
    jz      @@done                                      ; late join not allowed

@@spawn_pawn:
    ; Find / cache APlayerPawn_Athena_C class
    mov     rax, QWORD PTR [pClass_PlayerPawn]
    test    rax, rax
    jnz     @@have_pawn_class
    lea     rcx, [szClass_PlayerPawn]
    call    SDK_FindObject
    mov     QWORD PTR [pClass_PlayerPawn], rax
@@have_pawn_class:
    test    rax, rax
    jz      @@done

    ; Default spawn location {1250, 1818, 3284}
    mov     DWORD PTR [rsp + 20h], 449C4000h            ; X
    mov     DWORD PTR [rsp + 24h], 44E36000h            ; Y
    mov     DWORD PTR [rsp + 28h], 454D2000h            ; Z

    mov     rcx, rax
    lea     rdx, [rsp + 20h]
    mov     r8, rbx
    call    Spawners_SpawnActor
    test    rax, rax
    jz      @@done
    mov     rbp, rax                                    ; RBP = Pawn*

    ; Link Pawn to Controller
    mov     QWORD PTR [rbp + AACTOR_Owner], rbx
    mov     QWORD PTR [rbx + ACTRL_Pawn], rbp
    mov     QWORD PTR [rbx + APC_AcknowledgedPawn], rbp
    mov     DWORD PTR [rbp + AACTOR_NetCullDistSq], 0   ; NetCullDistanceSquared = 0.0f

    ; OnRep_Owner
    mov     rax, QWORD PTR [pFn_OnRep_Owner]
    test    rax, rax
    jnz     @@own2_ok
    lea     rcx, [szFn_OnRep_Owner]
    call    SDK_FindObject
    mov     QWORD PTR [pFn_OnRep_Owner], rax
@@own2_ok:
    test    rax, rax
    jz      @@skip_own2
    mov     QWORD PTR [rsp + 30h], 0
    mov     rcx, rbp
    mov     rdx, rax
    lea     r8, [rsp + 30h]
    call    QWORD PTR [ProcessEvent]

@@skip_own2:
    ; OnRep_Pawn
    mov     rax, QWORD PTR [pFn_OnRep_Pawn]
    test    rax, rax
    jnz     @@pawn2_ok
    lea     rcx, [szFn_OnRep_Pawn]
    call    SDK_FindObject
    mov     QWORD PTR [pFn_OnRep_Pawn], rax
@@pawn2_ok:
    test    rax, rax
    jz      @@skip_pawn2
    mov     QWORD PTR [rsp + 30h], 0
    mov     rcx, rbx
    mov     rdx, rax
    lea     r8, [rsp + 30h]
    call    QWORD PTR [ProcessEvent]

@@skip_pawn2:
    ; Possess(Pawn)
    mov     rax, QWORD PTR [pFn_Possess]
    test    rax, rax
    jnz     @@poss2_ok
    lea     rcx, [szFn_Possess]
    call    SDK_FindObject
    mov     QWORD PTR [pFn_Possess], rax
@@poss2_ok:
    test    rax, rax
    jz      @@skip_poss2
    mov     QWORD PTR [rsp + 30h], rbp                  ; InPawn = Pawn
    mov     rcx, rbx
    mov     rdx, rax
    lea     r8, [rsp + 30h]
    call    QWORD PTR [ProcessEvent]

@@skip_poss2:
    ; --- Set HealthSet minimums ---
    mov     rdi, QWORD PTR [rbp + AFPAWN_HealthSet]
    test    rdi, rdi
    jz      @@set_maxhp
    xor     eax, eax
    mov     DWORD PTR [rdi + FHEALTHSET_HealthMin], eax
    mov     DWORD PTR [rdi + FHEALTHSET_ShieldMin], eax

@@set_maxhp:
    ; SetMaxHealth
    mov     DWORD PTR [rsp + 30h], 42C80000h            ; 100.0f default
    test    r14, r14
    jz      @@use_def_mh
    cvtsi2ss xmm0, DWORD PTR [r14 + GMB_maxHealth]
    movss   DWORD PTR [rsp + 30h], xmm0
@@use_def_mh:
    mov     rax, QWORD PTR [pFn_SetMaxHealth]
    test    rax, rax
    jnz     @@mh2_ok
    lea     rcx, [szFn_SetMaxHealth]
    call    SDK_FindObject
    mov     QWORD PTR [pFn_SetMaxHealth], rax
@@mh2_ok:
    test    rax, rax
    jz      @@set_maxsh
    mov     rcx, rbp
    mov     rdx, rax
    lea     r8, [rsp + 30h]
    call    QWORD PTR [ProcessEvent]

@@set_maxsh:
    ; SetMaxShield
    mov     DWORD PTR [rsp + 30h], 42C80000h
    test    r14, r14
    jz      @@use_def_ms
    cvtsi2ss xmm0, DWORD PTR [r14 + GMB_maxShield]
    movss   DWORD PTR [rsp + 30h], xmm0
@@use_def_ms:
    mov     rax, QWORD PTR [pFn_SetMaxShield]
    test    rax, rax
    jnz     @@ms2_ok
    lea     rcx, [szFn_SetMaxShield]
    call    SDK_FindObject
    mov     QWORD PTR [pFn_SetMaxShield], rax
@@ms2_ok:
    test    rax, rax
    jz      @@set_can_damage
    mov     rcx, rbp
    mov     rdx, rax
    lea     r8, [rsp + 30h]
    call    QWORD PTR [ProcessEvent]

@@set_can_damage:
    ; bCanBeDamaged = bStartedBus (bit 7 of byte at 0x0081)
    movzx   eax, BYTE PTR [bStartedBus]
    test    eax, eax
    jz      @@can_clear
    or      BYTE PTR [rbp + AACTOR_bCanDamaged_byte], 80h
    jmp     @@set_ctrl_flags
@@can_clear:
    and     BYTE PTR [rbp + AACTOR_bCanDamaged_byte], 7Fh

@@set_ctrl_flags:
    ; bIsDisconnecting = false (clear bit 1 at 0x0698)
    and     BYTE PTR [rbx + AFPC_bFlagsAt0698], NOT AFPC_bIsDisconnecting_mask
    ; bHasInitiallySpawned = true (set bit 3 at 0x0698)
    or      BYTE PTR [rbx + AFPC_bFlagsAt0698], AFPC_bHasInitSpawned_mask
    ; bHasClientFinishedLoading = true
    mov     BYTE PTR [rbx + AFPC_bHasClientFinLoad], 1
    ; bHasServerFinishedLoading = true
    mov     BYTE PTR [rbx + AFPC_bHasServerFinLoad], 1

    ; OnRep_bHasServerFinishedLoading
    mov     rax, QWORD PTR [pFn_OnRep_ServerFin]
    test    rax, rax
    jnz     @@sfin_ok
    lea     rcx, [szFn_OnRep_ServerFin]
    call    SDK_FindObject
    mov     QWORD PTR [pFn_OnRep_ServerFin], rax
@@sfin_ok:
    test    rax, rax
    jz      @@set_ps_flags
    mov     QWORD PTR [rsp + 30h], 0
    mov     rcx, rbx
    mov     rdx, rax
    lea     r8, [rsp + 30h]
    call    QWORD PTR [ProcessEvent]

@@set_ps_flags:
    ; PlayerState flags
    mov     rsi, QWORD PTR [rbx + ACTRL_PlayerState]    ; RSI = PlayerState*
    test    rsi, rsi
    jz      @@load_hero_info

    ; bHasFinishedLoading = true (bit 2 at 0x04E0)
    or      BYTE PTR [rsi + AFPS_bFlagsAt04E0], AFPS_bHasFinLoad_mask
    ; bHasStartedPlaying = true (bit 3 at 0x04E0)
    or      BYTE PTR [rsi + AFPS_bFlagsAt04E0], AFPS_bHasStartPlay_mask

    ; OnRep_bHasStartedPlaying
    mov     rax, QWORD PTR [pFn_OnRep_StartPlay]
    test    rax, rax
    jnz     @@sp_ok
    lea     rcx, [szFn_OnRep_StartPlay]
    call    SDK_FindObject
    mov     QWORD PTR [pFn_OnRep_StartPlay], rax
@@sp_ok:
    test    rax, rax
    jz      @@load_hero_info
    mov     QWORD PTR [rsp + 30h], 0
    mov     rcx, rsi
    mov     rdx, rax
    lea     r8, [rsp + 30h]
    call    QWORD PTR [ProcessEvent]

@@load_hero_info:
    ; Load FortRegisteredPlayerInfo -> Hero -> HeroType + CharacterParts
    call    SDK_GetWorld
    test    rax, rax
    jz      @@init_inventory
    mov     rax, QWORD PTR [rax + UWORLD_OwningGameInstance]
    test    rax, rax
    jz      @@init_inventory

    ; RegisteredPlayers TArray: Data ptr at [GameInstance + 0x06F8]
    mov     r12, QWORD PTR [rax + UGAMEINST_RegisteredPlayers]  ; R12 = TArray.Data*
    test    r12, r12
    jz      @@init_inventory
    mov     r12, QWORD PTR [r12]                        ; R12 = RegisteredPlayers[0]
    test    r12, r12
    jz      @@init_inventory

    ; Hero = RegisteredPlayers[0]->AthenaMenuHeroDef
    mov     r13, QWORD PTR [r12 + UFRI_AthenaMenuHeroDef]  ; R13 = Hero*
    test    r13, r13
    jz      @@init_inventory

    ; GetHeroTypeBP: ProcessEvent(Hero, fn, &{ReturnValue})
    mov     rax, QWORD PTR [pFn_GetHeroTypeBP]
    test    rax, rax
    jnz     @@herotp_ok
    lea     rcx, [szFn_GetHeroTypeBP]
    call    SDK_FindObject
    mov     QWORD PTR [pFn_GetHeroTypeBP], rax
@@herotp_ok:
    test    rax, rax
    jz      @@init_inventory
    mov     QWORD PTR [rsp + 30h], 0                    ; ReturnValue = null
    mov     rcx, r13
    mov     rdx, rax
    lea     r8, [rsp + 30h]
    call    QWORD PTR [ProcessEvent]
    mov     rax, QWORD PTR [rsp + 30h]                  ; HeroType* (or null)

    ; Set PlayerState->HeroType if valid
    test    rsi, rsi
    jz      @@set_char_parts
    test    rax, rax
    jz      @@set_char_parts
    mov     QWORD PTR [rsi + AFPS_HeroType], rax

    ; OnRep_HeroType
    mov     rax, QWORD PTR [pFn_OnRep_HeroType]
    test    rax, rax
    jnz     @@ht_ok
    lea     rcx, [szFn_OnRep_HeroType]
    call    SDK_FindObject
    mov     QWORD PTR [pFn_OnRep_HeroType], rax
@@ht_ok:
    test    rax, rax
    jz      @@set_char_parts
    mov     QWORD PTR [rsp + 30h], 0
    mov     rcx, rsi
    mov     rdx, rax
    lea     r8, [rsp + 30h]
    call    QWORD PTR [ProcessEvent]

@@set_char_parts:
    test    rsi, rsi
    jz      @@init_inventory

    ; Cache Head part
    mov     rax, QWORD PTR [pObj_HeadPart]
    test    rax, rax
    jnz     @@have_head
    lea     rcx, [szObj_HeadPart]
    call    SDK_FindObject
    mov     QWORD PTR [pObj_HeadPart], rax
@@have_head:
    test    rax, rax
    jz      @@try_body
    mov     QWORD PTR [rsi + AFPS_CharacterParts + 0], rax   ; Head (index 0)

@@try_body:
    ; Cache Body part
    mov     rax, QWORD PTR [pObj_BodyPart]
    test    rax, rax
    jnz     @@have_body
    lea     rcx, [szObj_BodyPart]
    call    SDK_FindObject
    mov     QWORD PTR [pObj_BodyPart], rax
@@have_body:
    test    rax, rax
    jz      @@onrep_charparts
    mov     QWORD PTR [rsi + AFPS_CharacterParts + 8], rax   ; Body (index 1)

@@onrep_charparts:
    ; OnRep_CharacterParts
    mov     rax, QWORD PTR [pFn_OnRep_CharParts]
    test    rax, rax
    jnz     @@cp_ok
    lea     rcx, [szFn_OnRep_CharParts]
    call    SDK_FindObject
    mov     QWORD PTR [pFn_OnRep_CharParts], rax
@@cp_ok:
    test    rax, rax
    jz      @@init_inventory
    mov     QWORD PTR [rsp + 30h], 0
    mov     rcx, rsi
    mov     rdx, rax
    lea     r8, [rsp + 30h]
    call    QWORD PTR [ProcessEvent]

@@init_inventory:
    ; Inventory_Init(PC)
    mov     rcx, rbx
    call    Inventory_Init

    ; Inventory_EquipLoadout(PC, WIDs)
    call    GameModeBase_GetLoadout                     ; RAX = WIDs*
    mov     rcx, rbx
    mov     rdx, rax
    call    Inventory_EquipLoadout

    ; Abilities_ApplyAbilities(Pawn)
    mov     rcx, rbp
    call    Abilities_ApplyAbilities

    ; Spawn VictoryDrone
    ; Cache VictoryDrone class
    mov     rax, QWORD PTR [pClass_VictoryDrone]
    test    rax, rax
    jnz     @@have_drone_class
    lea     rcx, [szClass_VictoryDrone]
    call    SDK_FindObject
    mov     QWORD PTR [pClass_VictoryDrone], rax
@@have_drone_class:
    test    rax, rax
    jz      @@call_joined

    ; Use default spawn location (same as pawn spawn)
    mov     DWORD PTR [rsp + 30h], 449C4000h
    mov     DWORD PTR [rsp + 34h], 44E36000h
    mov     DWORD PTR [rsp + 38h], 454D2000h

    mov     rcx, rax
    lea     rdx, [rsp + 30h]
    mov     r8, rbx                                     ; Owner = PC
    call    Spawners_SpawnActor
    test    rax, rax
    jz      @@call_joined
    mov     r12, rax                                    ; R12 = Drone*

    ; InitDrone
    mov     rax, QWORD PTR [pFn_InitDrone]
    test    rax, rax
    jnz     @@drone_init_ok
    lea     rcx, [szFn_InitDrone]
    call    SDK_FindObject
    mov     QWORD PTR [pFn_InitDrone], rax
@@drone_init_ok:
    test    rax, rax
    jz      @@trigger_fx
    mov     QWORD PTR [rsp + 30h], 0
    mov     rcx, r12
    mov     rdx, rax
    lea     r8, [rsp + 30h]
    call    QWORD PTR [ProcessEvent]

@@trigger_fx:
    ; TriggerPlayerSpawnEffects
    mov     rax, QWORD PTR [pFn_TriggerSpawnFX]
    test    rax, rax
    jnz     @@trig_ok
    lea     rcx, [szFn_TriggerSpawnFX]
    call    SDK_FindObject
    mov     QWORD PTR [pFn_TriggerSpawnFX], rax
@@trig_ok:
    test    rax, rax
    jz      @@call_joined
    mov     QWORD PTR [rsp + 30h], 0
    mov     rcx, r12
    mov     rdx, rax
    lea     r8, [rsp + 30h]
    call    QWORD PTR [ProcessEvent]

@@call_joined:
    ; Call OnPlayerJoined virtual (via GMB function pointer)
    test    r14, r14
    jz      @@done
    mov     rax, QWORD PTR [r14 + GMB_OnPlayerJoined]
    test    rax, rax
    jz      @@done
    mov     rcx, rbx                                    ; PC
    call    rax

@@done:
    add     rsp, 60h
    pop     r14
    pop     r13
    pop     r12
    pop     rdi
    pop     rsi
    pop     rbp
    pop     rbx
    ret
GameModeBase_LoadPlayer ENDP

; GameModeBase_Respawn - respawn a killed player (LoadKilledPlayer)
;
; In:  RCX = AFortPlayerControllerAthena* (PC)
;      RDX = FVector* RespawnPos (or NULL for default)
; Out: none
;
; Frame: 4 pushes (RBX,RBP,RSI,RDI) + sub 28h = 4*8+40=72
;   N=4(even): sub=8 -> sub 28h(40)
;   [0..1F]=shadow, [20..27]=scratch
GameModeBase_Respawn PROC
    push    rbx
    push    rbp
    push    rsi
    push    rdi
    sub     rsp, 28h

    mov     rbx, rcx                                    ; RBX = PC
    mov     rbp, rdx                                    ; RBP = RespawnPos* (may be 0)

    ; Check bRespawnEnabled
    mov     rax, QWORD PTR [GMB_Current]
    test    rax, rax
    jz      @@done_resp
    movzx   esi, BYTE PTR [rax + GMB_bRespawnEnabled]   ; RSI = bRespawnEnabled
    test    esi, esi
    jz      @@done_resp

    ; Destroy current pawn (if exists) via K2_DestroyActor ProcessEvent
    mov     rdi, QWORD PTR [rbx + ACTRL_Pawn]      ; RDI = old Pawn* (may be 0)
    test    rdi, rdi
    jz      @@no_old_pawn

    mov     rax, QWORD PTR [pFn_K2_DestroyActor_GMB]
    test    rax, rax
    jnz     @@have_destroy
    lea     rcx, [szFn_K2_DestroyActor]
    call    SDK_FindObject
    mov     QWORD PTR [pFn_K2_DestroyActor_GMB], rax
@@have_destroy:
    test    rax, rax
    jz      @@no_old_pawn
    ; K2_DestroyActor has no params - pass NULL params ptr
    mov     rcx, rdi
    mov     rdx, rax
    xor     r8d, r8d
    call    QWORD PTR [ProcessEvent]

@@no_old_pawn:
    ; Call InitPawn(PC) to spawn a new pawn
    mov     rcx, rbx
    call    GameModeBase_InitPawn

    ; ActivateSlot(PC, EFortQuickBars::Primary=0, Slot=0, Delay=0, bUpdate=true)
    mov     rax, QWORD PTR [pFn_ActivateSlot]
    test    rax, rax
    jnz     @@slot_ok
    lea     rcx, [szFn_ActivateSlot]
    call    SDK_FindObject
    mov     QWORD PTR [pFn_ActivateSlot], rax
@@slot_ok:
    test    rax, rax
    jz      @@equip_pickaxe

    ; ActivateSlot params: {EFortQuickBars(1), pad(3), Slot(4), Delay(4), bUpdate(1)}
    xor     edi, edi
    mov     QWORD PTR [rsp + 20h], rdi                  ; InQuickBar=0, pad=0, Slot=0 cleared
    mov     DWORD PTR [rsp + 24h], edi                  ; ActivateDelay = 0.0f
    mov     BYTE PTR [rsp + 28h], 0
    ; byte [20]=QuickBar(0), [21..23]=pad, [24..27]=Slot(0), [28..2B]=Delay(0), [2C]=bUpdate(1)
    xor     eax, eax
    mov     QWORD PTR [rsp + 20h], rax
    mov     QWORD PTR [rsp + 28h], rax
    mov     BYTE PTR [rsp + 2Ch], 1                     ; bUpdatePreviousFocusedSlot = true
    mov     rcx, rbx
    mov     rdx, rax                                    ; RAX still 0 from mov above? No need separate
    mov     rdx, QWORD PTR [pFn_ActivateSlot]
    lea     r8, [rsp + 20h]
    call    QWORD PTR [ProcessEvent]

@@equip_pickaxe:
    ; Find pickaxe in inventory and equip it
    ; Inventory_FindItemInInventory(PC, UFortWeaponMeleeItemDefinition class, &bFound)
    mov     rcx, rbx
    xor     edx, edx
    xor     r8d, r8d
    xor     r9d, r9d
    call    Inventory_GetEntryInSlot
    test    rax, rax
    jz      @@done_resp

    ; Equip the item at slot 0 (pickaxe): Inventory_EquipInventoryItem(PC, &Guid)
    lea     rdx, [rax + 050h]                           ; +0x50 = ItemGuid within FFortItemEntry
    mov     rcx, rbx
    call    Inventory_EquipInventoryItem

@@done_resp:
    add     rsp, 28h
    pop     rdi
    pop     rsi
    pop     rbp
    pop     rbx
    ret
GameModeBase_Respawn ENDP

; GameModeBase_OnPlayerDeath - handle player kill event
;
; In:  RCX = AFortPlayerControllerAthena* (PC)
; Out: none
;
; Frame: 6 pushes (RBX,RBP,RSI,RDI,R12,R13) + sub 48h = 6*8+72=120
;   N=6(even): sub=8 -> sub 48h(72)
;   [0..1F]=shadow, [20..47]=K2_TeleportTo params + SetMovementMode params
GameModeBase_OnPlayerDeath PROC
    push    rbx
    push    rbp
    push    rsi
    push    rdi
    push    r12
    push    r13
    sub     rsp, 48h

    mov     rbx, rcx                                    ; RBX = PC

    ; Get GMB; check bRespawnEnabled
    mov     rsi, QWORD PTR [GMB_Current]                ; RSI = GMB*
    test    rsi, rsi
    jz      @@done_death
    movzx   eax, BYTE PTR [rsi + GMB_bRespawnEnabled]
    test    eax, eax
    jz      @@done_death

    ; Check IsCurrentlyDisconnecting: read bIsDisconnecting bit from PC
    movzx   eax, BYTE PTR [rbx + AFPC_bFlagsAt0698]
    test    al, AFPC_bIsDisconnecting_mask
    jnz     @@done_death                                ; disconnecting - skip respawn

    ; Get Pawn for respawn position
    mov     rbp, QWORD PTR [rbx + ACTRL_Pawn]          ; RBP = Pawn* (may be 0)

    ; Compute RespawnPos = Pawn->Location + {0,0,3000}
    ; Use default if no pawn
    mov     DWORD PTR [rsp + 20h], 449C4000h            ; X = 1250.0f (default)
    mov     DWORD PTR [rsp + 24h], 44E36000h            ; Y = 1818.0f
    mov     DWORD PTR [rsp + 28h], 47BA8000h            ; Z = 95000.0f (default high)

    test    rbp, rbp
    jz      @@do_respawn

    ; Get Pawn location via K2_GetActorLocation ProcessEvent
    ; K2_GetActorLocation params: {FVector ReturnValue (12 bytes)} at [rsp+20h]
    mov     rax, QWORD PTR [pFn_K2_GetActorLoc_GMB]
    test    rax, rax
    jnz     @@have_getloc
    mov     QWORD PTR [rsp + 30h], rbx                  ; save PC across FindObject
    mov     QWORD PTR [rsp + 38h], rbp                  ; save old Pawn
    lea     rcx, [szFn_K2_GetActorLoc]
    call    SDK_FindObject
    mov     QWORD PTR [pFn_K2_GetActorLoc_GMB], rax
    mov     rbx, QWORD PTR [rsp + 30h]                  ; restore PC
    mov     rbp, QWORD PTR [rsp + 38h]                  ; restore old Pawn
@@have_getloc:
    test    rax, rax
    jz      @@use_default_loc
    ; Zero out the ReturnValue buffer then call ProcessEvent
    xor     r13d, r13d
    mov     DWORD PTR [rsp + 20h], r13d
    mov     DWORD PTR [rsp + 24h], r13d
    mov     DWORD PTR [rsp + 28h], r13d
    mov     rcx, rbp                                    ; Pawn
    mov     rdx, rax
    lea     r8, [rsp + 20h]
    call    QWORD PTR [ProcessEvent]
    ; Add 3000.0f to Z component (0x453B8000)
    mov     eax, DWORD PTR [rsp + 28h]                  ; current Z (float bits)
    ; Use float addition: load to XMM, add 3000.0f, store back
    movd    xmm0, eax
    mov     eax, 453B8000h                              ; 3000.0f
    movd    xmm1, eax
    addss   xmm0, xmm1
    movd    eax, xmm0
    mov     DWORD PTR [rsp + 28h], eax
    jmp     @@do_respawn

@@use_default_loc:
    mov     DWORD PTR [rsp + 20h], 449C4000h            ; X = 1250.0f
    mov     DWORD PTR [rsp + 24h], 44E36000h            ; Y = 1818.0f
    mov     DWORD PTR [rsp + 28h], 47BA8000h            ; Z = 95000.0f

@@do_respawn:
    ; LoadKilledPlayer: call GameModeBase_Respawn(PC, &RespawnPos)
    lea     rdx, [rsp + 20h]                            ; &RespawnPos
    mov     rcx, rbx
    call    GameModeBase_Respawn

    ; RespawnPlayerAfterDeath (ProcessEvent on PC)
    mov     rax, QWORD PTR [pFn_RespawnAfterDeath]
    test    rax, rax
    jnz     @@resp_ok
    lea     rcx, [szFn_RespawnAfterDeath]
    call    SDK_FindObject
    mov     QWORD PTR [pFn_RespawnAfterDeath], rax
@@resp_ok:
    test    rax, rax
    jz      @@do_teleport
    mov     QWORD PTR [rsp + 30h], 0
    mov     rcx, rbx
    mov     rdx, rax
    lea     r8, [rsp + 30h]
    call    QWORD PTR [ProcessEvent]

@@do_teleport:
    ; K2_TeleportTo(RespawnPos, {0,0,0}) on Pawn
    ; Get new Pawn (was re-spawned by InitPawn in Respawn)
    mov     r12, QWORD PTR [rbx + ACTRL_Pawn]          ; R12 = new Pawn
    test    r12, r12
    jz      @@done_death

    mov     rax, QWORD PTR [pFn_K2_TeleportTo]
    test    rax, rax
    jnz     @@tp_ok
    lea     rcx, [szFn_K2_TeleportTo]
    call    SDK_FindObject
    mov     QWORD PTR [pFn_K2_TeleportTo], rax
@@tp_ok:
    test    rax, rax
    jz      @@set_move_mode

    ; K2_TeleportTo params: {FVector DestLocation(12), FRotator DestRotation(12), bool ReturnValue(1)}
    ; Layout: [20]=X, [24]=Y, [28]=Z, [2C]=Pitch, [30]=Yaw, [34]=Roll, [38]=ReturnValue
    mov     r13d, DWORD PTR [rsp + 20h]                 ; save RespawnX
    mov     DWORD PTR [rsp + 20h], r13d                 ; DestLocation.X = RespawnPos.X
    ; Y and Z already in place from earlier setup
    xor     r13d, r13d
    mov     DWORD PTR [rsp + 2Ch], r13d                 ; Pitch = 0
    mov     DWORD PTR [rsp + 30h], r13d                 ; Yaw = 0
    mov     DWORD PTR [rsp + 34h], r13d                 ; Roll = 0
    mov     BYTE PTR  [rsp + 38h], r13b                 ; ReturnValue = 0 (out)
    mov     rcx, r12                                    ; Pawn
    mov     rdx, rax
    lea     r8, [rsp + 20h]
    call    QWORD PTR [ProcessEvent]

@@set_move_mode:
    ; SetMovementMode(CharacterMovement, MOVE_Custom=6, CustomMode=4)
    mov     rax, QWORD PTR [pFn_SetMovementMode]
    test    rax, rax
    jnz     @@smm_ok
    lea     rcx, [szFn_SetMovementMode]
    call    SDK_FindObject
    mov     QWORD PTR [pFn_SetMovementMode], rax
@@smm_ok:
    test    rax, rax
    jz      @@done_death

    ; Get CharacterMovement from Pawn (ACharacter::CharacterMovement at 0x0380)
    mov     rcx, QWORD PTR [r12 + ACHAR_CharMoveComp]
    test    rcx, rcx
    jz      @@done_death

    ; SetMovementMode params: {uint8 NewMovementMode, uint8 NewCustomMode}
    mov     BYTE PTR [rsp + 20h], MOVE_Custom           ; = 6
    mov     BYTE PTR [rsp + 21h], 4                     ; CustomMode = 4
    mov     WORD PTR [rsp + 22h], 0                     ; pad
    mov     rdx, rax
    lea     r8, [rsp + 20h]
    call    QWORD PTR [ProcessEvent]

@@done_death:
    add     rsp, 48h
    pop     r13
    pop     r12
    pop     rdi
    pop     rsi
    pop     rbp
    pop     rbx
    ret
GameModeBase_OnPlayerDeath ENDP

END