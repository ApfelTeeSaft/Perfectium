INCLUDE include\master.inc

EXTERNDEF   GMB_Current         :QWORD
EXTERNDEF   GameModeBase_New    :PROC

; GMB struct offsets
GMB_Teams           EQU 000h
GMB_OnPlayerJoined  EQU 020h

; UWorld offsets
UWORLD_GameState        EQU 0148h
UWORLD_AuthorityGameMode EQU 0140h

; AFortGameModeAthena offsets
AGMA_bSafeZoneActive    EQU 0B04h   ; bool
AGMA_bSafeZonePaused    EQU 0B05h   ; bool

; AFortGameStateAthena offsets
AFGSA_SafeZonesStartTime EQU 14FCh  ; float
AFGSA_Aircrafts_Data     EQU 1BB8h  ; TArray<AFortAthenaAircraft*>.Data (QWORD)
AFGSA_Aircrafts_Num      EQU 1BC0h  ; TArray.Num (DWORD)

; AFortAthenaAircraft offsets
AIRCRAFT_ExitLocation           EQU 0384h   ; FVector (12 bytes)
AIRCRAFT_FlightInfo             EQU 0390h   ; FAircraftFlightInfo (0x28 bytes)
AFI_FlightStartLocation         EQU 0000h   ; FVector_NetQuantize100 relative to FlightInfo
AFI_FlightSpeed                 EQU 0018h   ; float relative to FlightInfo
AFI_TimeTillDropStart           EQU 0020h   ; float relative to FlightInfo

; Number of battle bus locations in the table
LG_LOCATION_COUNT   EQU 22

.const

szPlaylist_Solo     DB "FortPlaylistAthena Playlist_DefaultSolo.Playlist_DefaultSolo", 0
szFn_OnRep_Aircraft DB "Function FortniteGame.FortGameStateAthena.OnRep_Aircraft", 0

; Battle bus spawn locations (FVector X, Y, Z as REAL4)
BusBusLocations LABEL REAL4
    REAL4 24426.0,  37710.0,  17525.0   ; Retail Row
    REAL4 50018.0,  73844.0,  17525.0   ; Lonely Lodge
    REAL4 34278.0,    867.0,   9500.0   ; Dusty Depot
    REAL4 79710.0,  15677.0,  17525.0   ; Tomato Town
    REAL4 103901.0,-20203.0,  17525.0   ; Anarchy Acres
    REAL4 86766.0, -83071.0,  17525.0   ; Pleasant Park
    REAL4  2399.0, -96255.0,  17525.0   ; Greasy Grove
    REAL4-35037.0,   -463.0,  13242.0   ; Fatal Fields
    REAL4 83375.0,  50856.0,  17525.0   ; Wailing Woods
    REAL4 35000.0, -60121.0,  20525.0   ; Tilted Towers
    REAL4 40000.0,-127121.0,  17525.0   ; Snobby Shores
    REAL4  5000.0, -60121.0,  10748.0   ; Shifty Shafts
    REAL4 110088.0,-115332.0, 17525.0   ; Haunted Hills
    REAL4 119126.0, -86354.0, 17525.0   ; Junk Houses
    REAL4 130036.0,-105092.0, 17525.0   ; Junk Junction
    REAL4 39781.0,  61621.0,  17525.0   ; Moisty Mire
    REAL4-68000.0, -63521.0,  17525.0   ; Flush Factory
    REAL4  3502.0,  -9183.0,  10500.0   ; Salty Springs
    REAL4  7760.0,  76702.0,  17525.0   ; Race Track
    REAL4 38374.0, -94726.0,  17525.0   ; Soccer Field
    REAL4 70000.0, -40121.0,  17525.0   ; Loot Lake
    REAL4-123778.0,-112480.0, 17525.0   ; Spawn Island

.data?

pFn_OnRep_Aircraft  QWORD   ?

; Static cached battle bus location (picked once, reused)
LG_CachedLocX       REAL4   ?
LG_CachedLocY       REAL4   ?
LG_CachedLocZ       REAL4   ?
LG_LocInitialized   BYTE    ?

.code

; LG__GetRandomLocation (internal helper)
; Picks a random entry from BusBusLocations on first call,
; caches it, and returns pointer to the 3-float FVector.
;
; Out: RAX = &FVector (LG_CachedLocX/Y/Z)
;
; Frame: 0 pushes + sub 28h = 40; RSP=0
LG__GetRandomLocation PROC
    sub     rsp, 28h

    movzx   eax, BYTE PTR [LG_LocInitialized]
    test    eax, eax
    jnz     @@have_loc

    ; Pick random index in [0, LG_LOCATION_COUNT-1]
    mov     ecx, 0
    mov     edx, LG_LOCATION_COUNT - 1
    call    Utils_RandomIntInRange              ; EAX = 0..21

    ; Each entry = 3 REAL4 = 12 bytes; compute offset = idx * 12
    imul    eax, 12
    lea     rcx, [BusBusLocations]
    add     rcx, rax                            ; &entry

    ; Copy 12 bytes into cached location
    mov     eax, DWORD PTR [rcx + 0]
    mov     DWORD PTR [LG_CachedLocX], eax
    mov     eax, DWORD PTR [rcx + 4]
    mov     DWORD PTR [LG_CachedLocY], eax
    mov     eax, DWORD PTR [rcx + 8]
    mov     DWORD PTR [LG_CachedLocZ], eax
    mov     BYTE PTR [LG_LocInitialized], 1

@@have_loc:
    lea     rax, [LG_CachedLocX]
    add     rsp, 28h
    ret
LG__GetRandomLocation ENDP


; GameModeLateGame_OnPlayerJoined
; In: RCX = AFortPlayerControllerAthena* (PC)
;
; Frame: 1 push + sub 20h = 40; N=1(odd) -> RSP=0
GameModeLateGame_OnPlayerJoined PROC
    push    rbx
    sub     rsp, 20h

    mov     rbx, rcx

    mov     rax, QWORD PTR [GMB_Current]
    test    rax, rax
    jz      @@done
    mov     rcx, QWORD PTR [rax + GMB_Teams]
    test    rcx, rcx
    jz      @@done
    mov     rdx, rbx
    call    PlayerTeams_AddPlayerToRandomTeam

@@done:
    add     rsp, 20h
    pop     rbx
    ret
GameModeLateGame_OnPlayerJoined ENDP


; GameModeLateGame_Initialize
; In: none
; Out: RAX = GMB*
;
; After calling GameModeBase_New, sets:
;   GameMode->bSafeZoneActive  = true
;   GameMode->bSafeZonePaused  = false
;
; Frame: 1 push (RBX) + sub 28h = 48
;   N=1(odd): RSP=0 after push; sub 28h(40) -> RSP = -40 = 8 mod 16. WRONG.
;
; Use 0 pushes + sub 28h instead (save RBX to stack slot):
;   N=0: RSP=8; sub 28h(40) -> 8-40=-32=0 
;   [rsp+0..+1F]=shadow, [rsp+20h]=5th arg / scratch
GameModeLateGame_Initialize PROC
    sub     rsp, 28h

    lea     rcx, [szPlaylist_Solo]
    xor     dl, dl                              ; bRespawnEnabled = false
    mov     r8d, 1                              ; maxTeamSize = 1
    xor     r9b, r9b                            ; bRegenEnabled = false
    mov     BYTE PTR [rsp + 20h], 0             ; bRejoinEnabled = false
    call    GameModeBase_New
    test    rax, rax
    jz      @@done

    ; Set OnPlayerJoined
    mov     QWORD PTR [rsp + 20h], rax          ; save GMB*
    lea     rcx, [GameModeLateGame_OnPlayerJoined]
    mov     QWORD PTR [rax + GMB_OnPlayerJoined], rcx

    ; Set SafeZone flags on GameMode
    call    SDK_GetWorld
    test    rax, rax
    jz      @@restore_gmb
    mov     rax, QWORD PTR [rax + UWORLD_AuthorityGameMode]
    test    rax, rax
    jz      @@restore_gmb
    mov     BYTE PTR [rax + AGMA_bSafeZoneActive], 1
    mov     BYTE PTR [rax + AGMA_bSafeZonePaused], 0

@@restore_gmb:
    mov     rax, QWORD PTR [rsp + 20h]          ; restore GMB*

@@done:
    add     rsp, 28h
    ret
GameModeLateGame_Initialize ENDP


; GameModeLateGame_InitializeGameplay
; In: none
; Out: none
;
; Picks a random safe zone center location, configures the
; battle bus Aircraft at index 0 with zero FlightSpeed and
; zero TimeTillDropStart, then fires OnRep_Aircraft.
;
; Frame: 4 pushes (RBX,RBP,RSI,RDI) + sub 48h = 32+72=104
;   N=4(even): RSP=8 after pushes; sub 48h(72) -> 8-72=-64=0 
;   [rsp+0..+1F]=shadow
;   [rsp+20h..+27h]=GameState* (QWORD)
;   [rsp+28h..+2Fh]=Aircraft* (QWORD)
;   [rsp+30h..+3Bh]=SafeZoneCenter FVector (12 bytes)
;   [rsp+3C..+3F]=pad
;   [rsp+40h..+47h]=PE params scratch
GameModeLateGame_InitializeGameplay PROC
    push    rbx
    push    rbp
    push    rsi
    push    rdi
    sub     rsp, 48h

    ; Get World
    call    SDK_GetWorld
    test    rax, rax
    jz      @@done

    ; Get GameState
    mov     rbx, QWORD PTR [rax + UWORLD_GameState]  ; RBX = GameState*
    test    rbx, rbx
    jz      @@done

    ; Get GameMode
    mov     rsi, QWORD PTR [rax + UWORLD_AuthorityGameMode]  ; RSI = GameMode*

    ; Get random safe zone center (cached after first call)
    call    LG__GetRandomLocation               ; RAX = &FVector{X,Y,Z}
    ; Copy 12 bytes of FVector to local slot [rsp+30h]
    mov     ebp, DWORD PTR [rax + 0]
    mov     DWORD PTR [rsp + 30h], ebp          ; SafeZoneCenter.X
    mov     ebp, DWORD PTR [rax + 4]
    mov     DWORD PTR [rsp + 34h], ebp          ; SafeZoneCenter.Y
    mov     ebp, DWORD PTR [rax + 8]
    mov     DWORD PTR [rsp + 38h], ebp          ; SafeZoneCenter.Z

    ; Get Aircraft[0] from GameState->Aircrafts
    mov     rdi, QWORD PTR [rbx + AFGSA_Aircrafts_Data]  ; Aircrafts.Data*
    test    rdi, rdi
    jz      @@fire_onrep
    mov     ecx, DWORD PTR [rbx + AFGSA_Aircrafts_Num]
    test    ecx, ecx
    jz      @@fire_onrep
    mov     rbp, QWORD PTR [rdi]                ; Aircraft* = Aircrafts[0]
    test    rbp, rbp
    jz      @@fire_onrep

    ; GameState->SafeZonesStartTime = 5.0f
    mov     DWORD PTR [rbx + AFGSA_SafeZonesStartTime], 040A00000h  ; 5.0f

    ; Aircraft->FlightInfo.FlightSpeed = 0.0f
    xor     eax, eax
    mov     DWORD PTR [rbp + AIRCRAFT_FlightInfo + AFI_FlightSpeed], eax

    ; Aircraft->FlightInfo.TimeTillDropStart = 0.0f
    mov     DWORD PTR [rbp + AIRCRAFT_FlightInfo + AFI_TimeTillDropStart], eax

    ; Aircraft->FlightInfo.FlightStartLocation = SafeZoneCenter
    mov     ecx, DWORD PTR [rsp + 30h]
    mov     DWORD PTR [rbp + AIRCRAFT_FlightInfo + AFI_FlightStartLocation + 0], ecx
    mov     ecx, DWORD PTR [rsp + 34h]
    mov     DWORD PTR [rbp + AIRCRAFT_FlightInfo + AFI_FlightStartLocation + 4], ecx
    mov     ecx, DWORD PTR [rsp + 38h]
    mov     DWORD PTR [rbp + AIRCRAFT_FlightInfo + AFI_FlightStartLocation + 8], ecx

    ; Aircraft->ExitLocation = SafeZoneCenter
    mov     ecx, DWORD PTR [rsp + 30h]
    mov     DWORD PTR [rbp + AIRCRAFT_ExitLocation + 0], ecx
    mov     ecx, DWORD PTR [rsp + 34h]
    mov     DWORD PTR [rbp + AIRCRAFT_ExitLocation + 4], ecx
    mov     ecx, DWORD PTR [rsp + 38h]
    mov     DWORD PTR [rbp + AIRCRAFT_ExitLocation + 8], ecx

@@fire_onrep:
    ; GameState->OnRep_Aircraft()
    mov     rax, QWORD PTR [pFn_OnRep_Aircraft]
    test    rax, rax
    jnz     @@onrep_ok
    lea     rcx, [szFn_OnRep_Aircraft]
    call    SDK_FindObject
    mov     QWORD PTR [pFn_OnRep_Aircraft], rax
@@onrep_ok:
    test    rax, rax
    jz      @@done
    mov     QWORD PTR [rsp + 40h], 0            ; empty params
    mov     rcx, rbx                            ; GameState
    mov     rdx, rax                            ; UFunction*
    lea     r8, [rsp + 40h]
    call    QWORD PTR [ProcessEvent]

@@done:
    add     rsp, 48h
    pop     rdi
    pop     rsi
    pop     rbp
    pop     rbx
    ret
GameModeLateGame_InitializeGameplay ENDP

END