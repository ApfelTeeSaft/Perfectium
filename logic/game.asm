INCLUDE include\master.inc

; UWorld field offsets
UWORLD_NetDriver            EQU 038h
UWORLD_AuthorityGameMode    EQU 140h
UWORLD_GameState            EQU 148h
UWORLD_OwningGameInstance   EQU 190h

UGAMEINST_LocalPlayers      EQU 038h    ; TArray<ULocalPlayer*> Data ptr
UPLAYER_PlayerController    EQU 030h    ; UPlayer::PlayerController

; AGameMode / AFortGameModeAthena offsets
AGAMEMODE_MatchState            EQU 03B8h
AGAMEMODE_MinRespawnDelay       EQU 03D0h
AFGM_bEnableReplicationGraph    EQU 0491h
AFGMA_bDisableGCOnServer        EQU 08E8h
AFGMA_bAllowSpectateAfterDeath  EQU 0B68h

; AFortGameStateAthena offsets
AFGSA_WarmupCntdwnEnd           EQU 14F4h
AFGSA_AircraftStartTime         EQU 14F8h
AFGSA_GamePhase                 EQU 1B98h
AFGSA_bSkipAircraft             EQU 1BA8h

; AGameStateBase
AGSB_bReplHasBegunPlay          EQU 0340h

; EDeathCause values
EDC_Unspecified     EQU 0
EDC_Shotgun         EQU 1
EDC_Rifle           EQU 2
EDC_Sniper          EQU 3
EDC_Pistol          EQU 4
EDC_Grenade         EQU 5
EDC_SMG             EQU 6
EDC_Melee           EQU 7
EDC_FallDamage      EQU 8
EDC_RocketLauncher  EQU 9
EDC_GrenadeLauncher EQU 10
EDC_Trap            EQU 11
EDC_OutsideSafeZone EQU 12
EDC_Minigun         EQU 13
EDC_Bow             EQU 14

; UFunction field offsets
UFUNCTION_FLAGS_OFFSET  EQU 088h    ; UFunction::FunctionFlags (int32) - after UStruct(0x88)
FUNC_NATIVE             EQU 0400h   ; FUNC_Native flag

.const

; Console command for ExecuteConsoleCommand: "open Athena_Terrain?game=..."
szOpenAthena    DW 'o','p','e','n',' '
                DW 'A','t','h','e','n','a','_','T','e','r','r','a','i','n','?'
                DW 'g','a','m','e','=','/','G','a','m','e','/','A','t','h','e'
                DW 'n','a','/','A','t','h','e','n','a','_','G','a','m','e','M'
                DW 'o','d','e','.','A','t','h','e','n','a','_','G','a','m','e'

szInProgress DW 'I','n','P','r','o','g','r','e','s','s', 0

; UFunction paths
szFn_ExecCmd            DB "KismetSystemLibrary.ExecuteConsoleCommand", 0
szFn_ConvToName         DB "KismetStringLibrary.Conv_StringToName", 0
szFn_K2SetMatchState    DB "GameMode.K2_OnSetMatchState", 0
szFn_StartPlay          DB "GameMode.StartPlay", 0
szFn_StartMatch         DB "GameMode.StartMatch", 0
szFn_OnRepHasBegun      DB "GameStateBase.OnRep_ReplicatedHasBegunPlay", 0
szFn_OnRepGamePhase     DB "FortGameStateAthena.OnRep_GamePhase", 0
szClass_KismetStr       DB "KismetStringLibrary", 0

; Death cause tags
szTag_Shotgun    DB "weapon.ranged.shotgun", 0
szTag_Rifle      DB "weapon.ranged.assault", 0
szTag_Fall       DB "Gameplay.Damage.Environment.Falling", 0
szTag_Sniper     DB "weapon.ranged.sniper", 0
szTag_SMG        DB "Weapon.Ranged.SMG", 0
szTag_Rocket     DB "weapon.ranged.heavy.rocket_launcher", 0
szTag_GrenadeL   DB "weapon.ranged.heavy.grenade_launcher", 0
szTag_Grenade    DB "Weapon.ranged.heavy.grenade", 0
szTag_Minigun    DB "Weapon.Ranged.Heavy.Minigun", 0
szTag_Bow        DB "Weapon.Ranged.Crossbow", 0
szTag_Trap       DB "trap.floor", 0
szTag_Pistol     DB "weapon.ranged.pistol", 0
szTag_SafeZone   DB "Gameplay.Damage.OutsideSafeZone", 0
szTag_Melee      DB "Weapon.Melee.Impact.Pickaxe", 0

szLogMatch DB "[GAME] Initializing match!", 0
szLogMode  DB "[GAME] Solos game mode active.", 0
szLogStart DB "[GAME] Game::Start - traveling to Athena_Terrain.", 0

szDbgPCFound    DB "[GAME] PlayerController found.", 0
szDbgPCNull     DB "[GAME] PlayerController is NULL - aborting travel!", 0
szDbgECFound    DB "[GAME] ExecuteConsoleCommand UFunction found.", 0
szDbgECNull     DB "[GAME] ExecuteConsoleCommand NOT found in GObjects!", 0
szDbgCallingEC  DB "[GAME] Calling ExecuteConsoleCommand 'open Athena_Terrain'...", 0
szDbgTraveled   DB "[GAME] bTraveled set to 1.", 0

.data?

pFn_ExecCmd         QWORD ?
pFn_ConvToName      QWORD ?
pFn_K2SetMatchState QWORD ?
pFn_StartPlay       QWORD ?
pFn_StartMatch      QWORD ?
pFn_OnRepHasBegun   QWORD ?
pFn_OnRepGamePhase  QWORD ?
pClass_KismetStr    QWORD ?

Game_Mode           QWORD ?     ; current game mode ptr (Solos = AuthorityGameMode)

.code

; Internal helper: load cached UFunction*.
; Inputs:  RSI = &cache_qword, RDI = &szFunctionPath
; Output:  RAX = UFunction* (0 if not found)
; Trashes: RCX
Game__LoadFn PROC
    mov     rax, QWORD PTR [rsi]
    test    rax, rax
    jnz     @@done
    mov     rcx, rdi
    call    SDK_FindObject
    mov     QWORD PTR [rsi], rax
@@done:
    ret
Game__LoadFn ENDP

; QWORD Game__GetWorld_AuthMode() -> RAX
Game__GetWorld_AuthMode PROC
    call    SDK_GetWorld
    test    rax, rax
    jz      @@null
    mov     rax, QWORD PTR [rax + UWORLD_AuthorityGameMode]
    ret
@@null:
    xor     eax, eax
    ret
Game__GetWorld_AuthMode ENDP

; QWORD Game__GetWorld_GameState() -> RAX
Game__GetWorld_GameState PROC
    call    SDK_GetWorld
    test    rax, rax
    jz      @@null
    mov     rax, QWORD PTR [rax + UWORLD_GameState]
    ret
@@null:
    xor     eax, eax
    ret
Game__GetWorld_GameState ENDP

; QWORD Game_GetPlayerController() -> RAX
; Exported so ufunctionhooks can use it.
Game_GetPlayerController PROC
    call    SDK_GetWorld
    test    rax, rax
    jz      @@null
    mov     rax, QWORD PTR [rax + UWORLD_OwningGameInstance]
    test    rax, rax
    jz      @@null
    mov     rax, QWORD PTR [rax + UGAMEINST_LocalPlayers]  ; LocalPlayers.Data
    test    rax, rax
    jz      @@null
    mov     rax, QWORD PTR [rax]                           ; [0] = ULocalPlayer*
    test    rax, rax
    jz      @@null
    mov     rax, QWORD PTR [rax + UPLAYER_PlayerController]
    ret
@@null:
    xor     eax, eax
    ret
Game_GetPlayerController ENDP

; Internal: call ProcessEvent with no meaningful params.
; RCX = UObject*, RDX = UFunction*, R8 = scratch buf on caller stack.
Game__CallPE_NoParams PROC
    call    QWORD PTR [ProcessEvent]
    ret
Game__CallPE_NoParams ENDP

; void Game_Start()
; Frame: 4 pushes (rbp,rbx,rsi,rdi) + sub 58h
;  After 4 pushes RSP=8; sub 58h(88=8) -> RSP=0 
;
; ExecuteConsoleCommand params struct at [rsp+32] (32 bytes total):
;  [rsp+32..39] = WorldContextObject: UObject* = PC
;  [rsp+40..55] = Command: FString (Data*8, Count4, Max4) = "open Athena_Terrain?..."
;  [rsp+56..63] = SpecificPlayer: APlayerController* = null
;  [rsp+64..67] = saved UFunction::FunctionFlags
Game_Start PROC
    push    rbp
    push    rbx
    push    rsi
    push    rdi
    sub     rsp, 58h

    lea     rcx, szLogStart
    call    Logger_LogInfo

    ; Get player controller
    call    Game_GetPlayerController
    test    rax, rax
    jz      @@pc_null
    mov     rbx, rax                        ; rbx = PlayerController* (callee-saved)
    lea     rcx, szDbgPCFound
    call    Logger_LogInfo
    jmp     @@pc_ok

@@pc_null:
    lea     rcx, szDbgPCNull
    call    Logger_LogInfo
    jmp     @@done

@@pc_ok:
    ; Load ExecuteConsoleCommand UFunction* (cached in pFn_ExecCmd).
    lea     rsi, pFn_ExecCmd
    lea     rdi, szFn_ExecCmd
    call    Game__LoadFn
    test    rax, rax
    jz      @@ec_null
    mov     rsi, rax                        ; rsi = fn ptr (callee-saved)

    lea     rcx, szDbgECFound
    call    Logger_LogInfo

    ; Build ExecuteConsoleCommand params at [rsp+32]:
    ;   [+0]  WorldContextObject = PC
    ;   [+8]  Command (FString)  = "open Athena_Terrain?game=..."
    ;   [+24] SpecificPlayer     = null
    mov     QWORD PTR [rsp+32], rbx         ; WorldContextObject = PC

    lea     rcx, [rsp+40]                   ; &Command FString
    lea     rdx, szOpenAthena
    call    FString_FromWideChar            ; fills [rsp+40..55]

    mov     QWORD PTR [rsp+56], 0           ; SpecificPlayer = null

    ; Save flags, set FUNC_Native
    mov     eax, DWORD PTR [rsi + UFUNCTION_FLAGS_OFFSET]
    mov     DWORD PTR [rsp+64], eax
    or      DWORD PTR [rsi + UFUNCTION_FLAGS_OFFSET], FUNC_NATIVE

    lea     rcx, szDbgCallingEC
    call    Logger_LogInfo

    ; ProcessEvent(fn, fn, &params) — static function; receiver is fn itself
    mov     rcx, rsi
    mov     rdx, rsi
    lea     r8,  [rsp+32]
    call    QWORD PTR [ProcessEvent]

    ; Restore flags, free Command FString
    mov     eax, DWORD PTR [rsp+64]
    mov     DWORD PTR [rsi + UFUNCTION_FLAGS_OFFSET], eax
    lea     rcx, [rsp+40]
    call    FString_Free
    jmp     @@set_traveled

@@ec_null:
    lea     rcx, szDbgECNull
    call    Logger_LogInfo

@@set_traveled:
    mov     BYTE PTR [bTraveled], 1
    lea     rcx, szDbgTraveled
    call    Logger_LogInfo

@@done:
    add     rsp, 58h
    pop     rdi
    pop     rsi
    pop     rbx
    pop     rbp
    ret
Game_Start ENDP

; void Game_OnReadyToStartMatch()
; Frame: 8 pushes (rbp,rbx,rsi,rdi,r12,r13,r14,r15) + sub 88h
;  8 pushes from base 8 -> RSP=8; sub 88h(136)=8 -> 0 
;  [rsp+32..+47] = FString scratch / Conv_StringToName input FString
;  [rsp+48..+55] = FName output from Conv_StringToName
;  [rsp+56..+63] = OnRep_GamePhase params (BYTE OldPhase + 7 pad)
;  [rsp+64..+71] = K2_OnSetMatchState params (FName, 8 bytes)
;  [rsp+72..+79] = saved UFunction::FunctionFlags (Conv_StringToName)
Game_OnReadyToStartMatch PROC
    push    rbp
    push    rbx
    push    rsi
    push    rdi
    push    r12
    push    r13
    push    r14
    push    r15
    sub     rsp, 88h

    lea     rcx, szLogMatch
    call    Logger_LogInfo

    ; r12 = GameState, r13 = AuthorityGameMode
    call    Game__GetWorld_GameState
    test    rax, rax
    jz      @@done
    mov     r12, rax

    call    Game__GetWorld_AuthMode
    test    rax, rax
    jz      @@done
    mov     r13, rax

    ; GameState fields
    mov     BYTE PTR  [r12 + AFGSA_bSkipAircraft],  1
    mov     DWORD PTR [r12 + AFGSA_AircraftStartTime],  461C7EB8h  ; 9999.9f
    mov     DWORD PTR [r12 + AFGSA_WarmupCntdwnEnd],    47C34F80h  ; 99999.9f
    mov     BYTE PTR  [r12 + AFGSA_GamePhase], EAthenaGamePhase_Warmup

    ; OnRep_GamePhase(EAthenaGamePhase::None)
    lea     rsi, pFn_OnRepGamePhase
    lea     rdi, szFn_OnRepGamePhase
    call    Game__LoadFn
    test    rax, rax
    jz      @@skip_gp
    mov     BYTE PTR [rsp+56], EAthenaGamePhase_None
    mov     rcx, r12
    mov     rdx, rax
    lea     r8,  [rsp+56]
    call    QWORD PTR [ProcessEvent]
@@skip_gp:

    ; GameMode fields
    mov     BYTE PTR [r13 + AFGMA_bDisableGCOnServer],   1
    mov     BYTE PTR [r13 + AFGMA_bAllowSpectateAfterDeath], 1
    mov     BYTE PTR [r13 + AFGM_bEnableReplicationGraph],1

    ; Get FName("InProgress") via Conv_StringToName
    ; Build FString "InProgress" at [rsp+32]
    lea     rcx, [rsp+32]
    lea     rdx, szInProgress
    call    FString_FromWideChar

    ; Get Conv_StringToName fn (static function - use fn as its own receiver)
    lea     rsi, pFn_ConvToName
    lea     rdi, szFn_ConvToName
    call    Game__LoadFn
    mov     r15, rax                        ; r15 = fn (may be 0)

    ; Zero FName output slot
    xor     eax, eax
    mov     QWORD PTR [rsp+48], rax

    ; Call Conv_StringToName: static function, use fn as receiver.
    ; Set FUNC_Native so ProcessEvent routes to native implementation.
    ; Params: [rsp+32]=FString input, [rsp+48]=FName output
    test    r15, r15
    jz      @@skip_conv
    mov     eax, DWORD PTR [r15 + UFUNCTION_FLAGS_OFFSET]
    mov     DWORD PTR [rsp+72], eax         ; save FunctionFlags
    or      DWORD PTR [r15 + UFUNCTION_FLAGS_OFFSET], FUNC_NATIVE
    mov     rcx, r15                        ; fn as receiver
    mov     rdx, r15
    lea     r8,  [rsp+32]
    call    QWORD PTR [ProcessEvent]
    mov     eax, DWORD PTR [rsp+72]
    mov     DWORD PTR [r15 + UFUNCTION_FLAGS_OFFSET], eax
@@skip_conv:

    ; Free FString temp
    lea     rcx, [rsp+32]
    call    FString_Free

    ; MatchState = InProgress (FName at [rsp+48])
    mov     rax, QWORD PTR [rsp+48]
    mov     QWORD PTR [r13 + AGAMEMODE_MatchState], rax

    ; K2_OnSetMatchState(InProgress) - params: {FName NewState}
    lea     rsi, pFn_K2SetMatchState
    lea     rdi, szFn_K2SetMatchState
    call    Game__LoadFn
    test    rax, rax
    jz      @@skip_k2
    mov     rbx, QWORD PTR [rsp+48]
    mov     QWORD PTR [rsp+64], rbx         ; params.NewState
    mov     rcx, r13
    mov     rdx, rax
    lea     r8,  [rsp+64]
    call    QWORD PTR [ProcessEvent]
@@skip_k2:

    ; Store current game mode, can be changed
    mov     QWORD PTR [Game_Mode], r13

    lea     rcx, szLogMode
    call    Logger_LogInfo

    ; MinRespawnDelay = 5.0f
    mov     DWORD PTR [r13 + AGAMEMODE_MinRespawnDelay], 40A00000h   ; 5.0f

    ; StartPlay()
    lea     rsi, pFn_StartPlay
    lea     rdi, szFn_StartPlay
    call    Game__LoadFn
    test    rax, rax
    jz      @@skip_sp
    mov     rcx, r13
    mov     rdx, rax
    lea     r8, [rsp+32]
    call    QWORD PTR [ProcessEvent]
@@skip_sp:

    ; GameState->bReplicatedHasBegunPlay = true
    mov     BYTE PTR [r12 + AGSB_bReplHasBegunPlay], 1

    ; OnRep_ReplicatedHasBegunPlay()
    lea     rsi, pFn_OnRepHasBegun
    lea     rdi, szFn_OnRepHasBegun
    call    Game__LoadFn
    test    rax, rax
    jz      @@skip_rb
    mov     rcx, r12
    mov     rdx, rax
    lea     r8, [rsp+32]
    call    QWORD PTR [ProcessEvent]
@@skip_rb:

    ; StartMatch()
    lea     rsi, pFn_StartMatch
    lea     rdi, szFn_StartMatch
    call    Game__LoadFn
    test    rax, rax
    jz      @@done
    mov     rcx, r13
    mov     rdx, rax
    lea     r8, [rsp+32]
    call    QWORD PTR [ProcessEvent]

@@done:
    add     rsp, 88h
    pop     r15
    pop     r14
    pop     r13
    pop     r12
    pop     rdi
    pop     rsi
    pop     rbx
    pop     rbp
    ret
Game_OnReadyToStartMatch ENDP

; DWORD Game_GetDeathCause(FFortPlayerDeathReport* pReport)
; RCX = pReport.  Returns EDeathCause in EAX.
;
; FFortPlayerDeathReport::Tags (FGameplayTagContainer) at +0x30.
; FGameplayTagContainer::GameplayTags (TArray<FGameplayTag>) at +0x00.
; FGameplayTag::TagName (FName, 8 bytes).
; We FNameToString each tag name, narrow-convert, strcmp vs table.
;
; Frame: 5 pushes (rbp,rbx,rsi,rdi,r12) + sub 48h
;  5 pushes from base 8 -> RSP=8+5*8=48=0 mod16... wait:
;  entry 8 mod16, push->0, push->8, push->0, push->8, push->0 after 5 pushes = 0 mod16
;  sub 48h(72): 72 mod16=8 -> 0-8=-8=8 mod16.
AFPDR_Tags_Data  EQU 030h
AFPDR_Tags_Num   EQU 038h

Game_GetDeathCause PROC
    push    rbp
    push    rbx
    push    rsi
    push    rdi
    push    r12
    sub     rsp, 50h

    ; Default = Unspecified
    xor     r12d, r12d

    test    rcx, rcx
    jz      @@done
    mov     rbp, rcx                            ; rbp = pReport

    ; Load GameplayTags array
    mov     rsi, QWORD PTR [rbp + AFPDR_Tags_Data]  ; Tags.GameplayTags.Data
    mov     edi, DWORD PTR [rbp + AFPDR_Tags_Num]   ; Tags.GameplayTags.Num
    test    rsi, rsi
    jz      @@done
    test    edi, edi
    jz      @@done

    xor     ebx, ebx                            ; i = 0
@@loop:
    cmp     ebx, edi
    jge     @@done

    ; FName at rsi + i*8
    lea     rcx, [rsi + rbx*8]                  ; FName* in
    ; Zero FString at [rsp+32]
    xor     eax, eax
    mov     QWORD PTR [rsp+32], rax
    mov     QWORD PTR [rsp+40], rax
    lea     rdx, [rsp+32]                        ; FString& out
    call    QWORD PTR [FNameToString]

    ; Load FString.Data (wchar_t*)
    mov     rdi, QWORD PTR [rsp+32]
    test    rdi, rdi
    jz      @@next

    ; Narrow-convert wchar_t -> char in-place
    xor     ecx, ecx
@@narrow:
    movzx   eax, WORD PTR [rdi + rcx*2]
    test    eax, eax
    jz      @@narrow_done
    mov     BYTE PTR [rdi + rcx], al
    inc     ecx
    jmp     @@narrow
@@narrow_done:
    mov     BYTE PTR [rdi + rcx], 0

    ; Compare against tag table; first arg = rdi (our string), second = table entry
    ; We use a helper macro sequence:
    ; strcmp(s1=rdi, s2=tag) in x64: RCX=s1, RDX=s2
    mov     rcx, rdi
    lea     rdx, szTag_Shotgun
    call    strcmp
    test    eax, eax
    jnz     @@c2
    mov     r12d, EDC_Shotgun
    jmp     @@found
@@c2:
    mov     rcx, rdi
    lea     rdx, szTag_Rifle
    call    strcmp
    test    eax, eax
    jnz     @@c3
    mov     r12d, EDC_Rifle
    jmp     @@found
@@c3:
    mov     rcx, rdi
    lea     rdx, szTag_Fall
    call    strcmp
    test    eax, eax
    jnz     @@c4
    mov     r12d, EDC_FallDamage
    jmp     @@found
@@c4:
    mov     rcx, rdi
    lea     rdx, szTag_Sniper
    call    strcmp
    test    eax, eax
    jnz     @@c5
    mov     r12d, EDC_Sniper
    jmp     @@found
@@c5:
    mov     rcx, rdi
    lea     rdx, szTag_SMG
    call    strcmp
    test    eax, eax
    jnz     @@c6
    mov     r12d, EDC_SMG
    jmp     @@found
@@c6:
    mov     rcx, rdi
    lea     rdx, szTag_Rocket
    call    strcmp
    test    eax, eax
    jnz     @@c7
    mov     r12d, EDC_RocketLauncher
    jmp     @@found
@@c7:
    mov     rcx, rdi
    lea     rdx, szTag_GrenadeL
    call    strcmp
    test    eax, eax
    jnz     @@c8
    mov     r12d, EDC_GrenadeLauncher
    jmp     @@found
@@c8:
    mov     rcx, rdi
    lea     rdx, szTag_Grenade
    call    strcmp
    test    eax, eax
    jnz     @@c9
    mov     r12d, EDC_Grenade
    jmp     @@found
@@c9:
    mov     rcx, rdi
    lea     rdx, szTag_Minigun
    call    strcmp
    test    eax, eax
    jnz     @@c10
    mov     r12d, EDC_Minigun
    jmp     @@found
@@c10:
    mov     rcx, rdi
    lea     rdx, szTag_Bow
    call    strcmp
    test    eax, eax
    jnz     @@c11
    mov     r12d, EDC_Bow
    jmp     @@found
@@c11:
    mov     rcx, rdi
    lea     rdx, szTag_Trap
    call    strcmp
    test    eax, eax
    jnz     @@c12
    mov     r12d, EDC_Trap
    jmp     @@found
@@c12:
    mov     rcx, rdi
    lea     rdx, szTag_Pistol
    call    strcmp
    test    eax, eax
    jnz     @@c13
    mov     r12d, EDC_Pistol
    jmp     @@found
@@c13:
    mov     rcx, rdi
    lea     rdx, szTag_SafeZone
    call    strcmp
    test    eax, eax
    jnz     @@c14
    mov     r12d, EDC_OutsideSafeZone
    jmp     @@found
@@c14:
    mov     rcx, rdi
    lea     rdx, szTag_Melee
    call    strcmp
    test    eax, eax
    jnz     @@next
    mov     r12d, EDC_Melee
    jmp     @@found

@@found:
    lea     rcx, [rsp+32]
    call    FString_Free
    jmp     @@done

@@next:
    lea     rcx, [rsp+32]
    call    FString_Free
    inc     ebx
    jmp     @@loop

@@done:
    mov     eax, r12d
    add     rsp, 50h
    pop     r12
    pop     rdi
    pop     rsi
    pop     rbx
    pop     rbp
    ret
Game_GetDeathCause ENDP

END