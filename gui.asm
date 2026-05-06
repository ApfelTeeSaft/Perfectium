INCLUDE asm\include\master.inc

; SDK offsets - AFortGameStateAthena
AGSA_WarmupCountdownEndTime EQU 14F4h
AGSA_AircraftStartTime      EQU 14F8h
AGSA_GamePhase              EQU 1B98h   ; BYTE, EAthenaGamePhase
AGSA_bWillSkipAircraft      EQU 1BA8h  ; BYTE
AGSA_PlayerArray_Data       EQU 0330h  ; TArray<APlayerState*>.Data
AGSA_PlayerArray_Num        EQU 0338h  ; TArray<APlayerState*>.Num

; UWorld offsets
UWORLD_GameState            EQU 0148h
UWORLD_AuthorityGameMode    EQU 0140h

; AGameModeBase offsets
AGMB_GameSession            EQU 0370h  ; AGameSession*

; AActor offsets
AACTOR_Owner                EQU 0108h  ; AActor* (PlayerController for PlayerState)

; EAthenaGamePhase::Aircraft = 3
EGAMEPHASE_Aircraft         EQU 3

; FText size
FTEXT_SIZE                  EQU 18h    ; 24 bytes

; Window parameters
GUI_WINDOW_W_BITS   EQU 43FA0000h   ; 500.0f
GUI_WINDOW_H_BITS   EQU 444F0000h   ; 828.0f 
GUI_WINDOW_H_BITS2  EQU 44AF0000h   ; 700.0f (for header)

; Position of GUI window
; Menu pos: FVector2D starting at 200, 250
F_200_0             EQU 43480000h   ; 200.0f
F_250_0             EQU 437A0000h   ; 250.0f

.const

; Wide string constants for GUI text
szTitle_Raider      DW 'R','a','i','d','e','r', 0
szBtn_StartBus      DW 'S','t','a','r','t',' ','B','u','s', 0
szBtn_Back          DW '<', 0
szBtn_Kick          DW 'K','i','c','k', 0
szBtnTab_Game       DW 'G','a','m','e', 0
szBtnTab_Players    DW 'P','l','a','y','e','r','s', 0
szText_CurPlayer    DW 'C','u','r','r','e','n','t',' ','P','l','a','y','e','r',':', 0
szText_ConnPlayers  DW 'C','o','n','n','e','c','t','e','d',' ','P','l','a','y','e','r','s', 0

; Console command: "startaircraft"
szConsoleCmd_W      DW 's','t','a','r','t','a','i','r','c','r','a','f','t', 0

; UFunction / UClass paths for static calls
szFn_ExecConsoleCmd DB "Function Engine.KismetSystemLibrary.ExecuteConsoleCommand", 0
szClass_KismetSys   DB "Class Engine.KismetSystemLibrary", 0
szFn_GetPlayerName  DB "Function Engine.PlayerState.GetPlayerName", 0
szFn_ConvStrToText  DB "Function Engine.KismetTextLibrary.Conv_StringToText", 0
szClass_KismetText  DB "Class Engine.KismetTextLibrary", 0

; Kick reason wide string
szKickReason        DW 'Y','o','u',' ','h','a','v','e',' ','b','e','e','n',' ','k','i','c','k','e','d','.', 0

; Sizebit constants as REAL4
f_25_0      REAL4   25.0
f_100_0     REAL4   100.0
f_110_0     REAL4   110.0
f_60_0      REAL4   60.0
f_90_0      REAL4   90.0
f_130_0     REAL4   130.0
f_500_0     REAL4   500.0
f_700_0     REAL4   700.0
f_0_5_gui   REAL4   0.5

.data?

; Persistent menu state
GUI_menu_opened     BYTE    ?   ; bool: menu visible (toggled by F2)
GUI_initialized     BYTE    ?   ; one-time init done
GUI_tab             DWORD   ?   ; active tab (0=Game, 1=Players)
GUI_currentPlayer   QWORD   ?   ; APlayerState* selected for kick view (or 0)
GUI_pos_X           REAL4   ?   ; window position X (drag-persistent)
GUI_pos_Y           REAL4   ?   ; window position Y

; Cached UFunction* and UClass* pointers
GUI_pFn_ExecConsole QWORD   ?
GUI_pClass_KismetSys QWORD  ?
GUI_pFn_GetPlyName  QWORD   ?
GUI_pFn_ConvStr     QWORD   ?
GUI_pClass_TextLib  QWORD   ?

; Scratch buffer for player name FString (single-frame, reused per player)
GUI_nameFStr_Data   QWORD   ?   ; FString.Data (wchar_t*)
GUI_nameFStr_Num    DWORD   ?   ; FString.Num
GUI_nameFStr_Max    DWORD   ?   ; FString.Max

; Scratch buffer for kick reason FString
GUI_kickFStr_Data   QWORD   ?
GUI_kickFStr_Num    DWORD   ?
GUI_kickFStr_Max    DWORD   ?

.code

; GUI__GetPlayerName  (internal helper)
; Calls GetPlayerName UFunction on a PlayerState via ProcessEvent.
; Fills GUI_nameFStr_Data/Num/Max.
; In:  RCX = APlayerState* (PlayerState object)
; Out: RAX = wchar_t* (Data pointer, or 0 on failure)
;
; Frame: 2 pushes (RBX=PlayerState*) + sub 28h -> RSP = 0 
; GetPlayerName params at [rsp+20h..+2Fh]:
;   +0x00: FString ReturnValue (16 bytes)
GUI__GetPlayerName PROC
    push    rbx
    push    rsi
    sub     rsp, 28h

    mov     rbx, rcx                    ; PlayerState*

    ; Lazy-load GetPlayerName UFunction*
    mov     rsi, QWORD PTR [GUI_pFn_GetPlyName]
    test    rsi, rsi
    jnz     @@fn_ready
    lea     rcx, [szFn_GetPlayerName]
    call    SDK_FindObject
    mov     QWORD PTR [GUI_pFn_GetPlyName], rax
    mov     rsi, rax
    test    rsi, rsi
    jz      @@fail
@@fn_ready:

    ; Zero the ReturnValue FString at [rsp+20h]
    xor     eax, eax
    mov     QWORD PTR [rsp+20h], rax    ; Data = nullptr
    mov     QWORD PTR [rsp+28h], rax    ; Num=0, Max=0 - wait this overwrites our saved RSI

    mov     QWORD PTR [rsp+20h], 0      ; Data = 0
    mov     DWORD PTR [rsp+28h], 0      ; Num = 0 (this is fine - shadow can be written)
    mov     DWORD PTR [rsp+2Ch], 0      ; Max = 0

    ; ProcessEvent(PlayerState, GetPlayerName, &params)
    mov     rcx, rbx
    mov     rdx, rsi
    lea     r8, [rsp+20h]
    call    QWORD PTR [ProcessEvent]

    ; Return FString.Data (the wchar_t* pointer)
    mov     rax, QWORD PTR [rsp+20h]
    jmp     @@done
@@fail:
    xor     rax, rax
@@done:
    add     rsp, 28h
    pop     rsi
    pop     rbx
    ret
GUI__GetPlayerName ENDP


; GUI__KickController  (internal helper)
; Calls Native_OnlineSession_KickPlayer(Session, PC, &empty_FText).
; In:  RCX = APlayerController* (PC to kick)
; Out: none
;
; Frame: 2 pushes (RBX=PC) + sub 38h -> RSP = 8-16-56 = -64 = 0 
; [rsp+20h..+37h] = zeroed FText (0x18 = 24 bytes)
GUI__KickController PROC
    push    rbx
    push    rsi
    sub     rsp, 38h

    mov     rbx, rcx                    ; PC to kick
    test    rbx, rbx
    jz      @@done

    ; Get GameSession: World->AuthorityGameMode->GameSession
    call    SDK_GetWorld
    test    rax, rax
    jz      @@done
    mov     rsi, QWORD PTR [rax + UWORLD_AuthorityGameMode]
    test    rsi, rsi
    jz      @@done
    mov     rsi, QWORD PTR [rsi + AGMB_GameSession]
    test    rsi, rsi
    jz      @@done

    ; Zero FText at [rsp+20h] (24 bytes)
    xor     eax, eax
    mov     QWORD PTR [rsp+20h], rax
    mov     QWORD PTR [rsp+28h], rax
    mov     QWORD PTR [rsp+30h], rax

    ; Native_OnlineSession_KickPlayer(Session, PC, &FText)
    mov     rcx, rsi                    ; Session
    mov     rdx, rbx                    ; PC
    lea     r8, [rsp+20h]              ; &FText (empty)
    call    QWORD PTR [Native_OnlineSession_KickPlayer]

@@done:
    add     rsp, 38h
    pop     rsi
    pop     rbx
    ret
GUI__KickController ENDP


; GUI__StartBus  (internal helper)
; Sets GameState fields and fires "startaircraft" console command
; then calls GameModeLateGame_InitializeGameplay.
; In: none
; Frame: 4 pushes (RBX=GameState*,RBP=World*,RSI=KismetClass,RDI=fn)
;        + sub 48h -> RSP = 8-32-72 = -96 = 0 
; Params for ExecuteConsoleCommand at [rsp+20h]:
;   +0x00: WorldContextObject QWORD
;   +0x08: FString.Data QWORD
;   +0x10: FString.Num  DWORD
;   +0x14: FString.Max  DWORD
;   +0x18: SpecificPlayer QWORD = 0
; Total = 0x20 = 32 bytes (fits in shadow + [rsp+20h..+3Fh])
GUI__StartBus PROC
    push    rbx
    push    rbp
    push    rsi
    push    rdi
    sub     rsp, 48h

    ; Get World
    call    SDK_GetWorld
    test    rax, rax
    jz      @@done
    mov     rbp, rax                    ; World*

    ; Get GameState
    mov     rbx, QWORD PTR [rbp + UWORLD_GameState]
    test    rbx, rbx
    jz      @@done

    ; GameState->bGameModeWillSkipAircraft = false
    mov     BYTE PTR [rbx + AGSA_bWillSkipAircraft], 0

    ; GameState->AircraftStartTime = 0
    xor     eax, eax
    mov     DWORD PTR [rbx + AGSA_AircraftStartTime], eax

    ; GameState->WarmupCountdownEndTime = 0
    mov     DWORD PTR [rbx + AGSA_WarmupCountdownEndTime], eax

    ; ExecuteConsoleCommand via KismetSystemLibrary
    ; Lazy-load KismetSystemLibrary class
    mov     rsi, QWORD PTR [GUI_pClass_KismetSys]
    test    rsi, rsi
    jnz     @@kls_ready
    lea     rcx, [szClass_KismetSys]
    call    SDK_FindObject
    mov     QWORD PTR [GUI_pClass_KismetSys], rax
    mov     rsi, rax
    test    rsi, rsi
    jz      @@done
@@kls_ready:

    ; Lazy-load ExecuteConsoleCommand UFunction*
    mov     rdi, QWORD PTR [GUI_pFn_ExecConsole]
    test    rdi, rdi
    jnz     @@fn_ready
    lea     rcx, [szFn_ExecConsoleCmd]
    call    SDK_FindObject
    mov     QWORD PTR [GUI_pFn_ExecConsole], rax
    mov     rdi, rax
    test    rdi, rdi
    jz      @@done
@@fn_ready:

    ; Build FString for "startaircraft" command using FString_FromWideChar
    ; Temporarily store the FString at [rsp+30h] (3 slots: Data*, Num, Max = 16 bytes)
    lea     rcx, [rsp+30h]
    lea     rdx, [szConsoleCmd_W]
    call    FString_FromWideChar

    ; Build params block at [rsp+20h]:
    ;   [rsp+20h] = World* (WorldContextObject)
    ;   [rsp+28h] = FString.Data (wchar_t*)
    ;   [rsp+30h] = FString.Num  (DWORD)
    ;   [rsp+34h] = FString.Max  (DWORD)
    ;   [rsp+38h] = SpecificPlayer = 0
    mov     QWORD PTR [rsp+20h], rbp    ; World*
    mov     rax, QWORD PTR [rsp+30h]    ; FString.Data (was stored by FString_FromWideChar)
    mov     QWORD PTR [rsp+28h], rax

    mov     QWORD PTR [rsp+20h], rbp    ; WorldContextObject = World*
    lea     rcx, [rsp+28h]              ; out = &Command FString
    lea     rdx, [szConsoleCmd_W]
    call    FString_FromWideChar
    xor     rax, rax
    mov     QWORD PTR [rsp+38h], rax    ; SpecificPlayer = nullptr

    ; ProcessEvent(KismetSysClass, fn, &params)
    mov     rcx, rsi                    ; KismetSystemLibrary class object
    mov     rdx, rdi                    ; ExecuteConsoleCommand fn
    lea     r8, [rsp+20h]
    call    QWORD PTR [ProcessEvent]

    ; Free the command FString
    lea     rcx, [rsp+28h]
    call    FString_Free

    ; Call GameModeLateGame_InitializeGameplay
    call    GameModeLateGame_InitializeGameplay

    ; Set bStartedBus = true
    mov     BYTE PTR [bStartedBus], 1

@@done:
    add     rsp, 48h
    pop     rdi
    pop     rsi
    pop     rbp
    pop     rbx
    ret
GUI__StartBus ENDP


; GUI_Tick
; Called each frame from Hooks_PostRender.
; Frame: 4 pushes (RBX=World, RBP=GameState, RSI=playerState loop, RDI=spare)
;        + sub 68h (104) -> RSP = 8-32-104 = -128 = 0 
GUI_Tick PROC
    push    rbx
    push    rbp
    push    rsi
    push    rdi
    sub     rsp, 68h

    ; One-time initialization
    movzx   eax, BYTE PTR [GUI_initialized]
    test    al, al
    jnz     @@skip_init
    ; Set initial window position
    mov     DWORD PTR [GUI_pos_X], F_200_0
    mov     DWORD PTR [GUI_pos_Y], F_250_0
    ; menu_opened = true by default
    mov     BYTE PTR [GUI_menu_opened], 1
    ; tab = 0
    mov     DWORD PTR [GUI_tab], 0
    ; currentPlayer = nullptr
    xor     rax, rax
    mov     QWORD PTR [GUI_currentPlayer], rax
    mov     BYTE PTR [GUI_initialized], 1
@@skip_init:

    ; ZeroInput_Update (poll mouse state)
    call    ZeroInput_Update

    ; F2 toggle
    mov     ecx, 071h                   ; VK_F2 = 0x71
    call    GetAsyncKeyState
    test    ax, 1                       ; check lowest bit (just-pressed flag)
    jz      @@no_toggle
    movzx   eax, BYTE PTR [GUI_menu_opened]
    xor     al, 1
    mov     BYTE PTR [GUI_menu_opened], al
@@no_toggle:

    ; ZeroGUI_Begin (Window)
    lea     rcx, [szTitle_Raider]
    lea     rdx, [GUI_pos_X]            ; pos (FVector2D*) - persistent in .data?
    movss   xmm0, DWORD PTR [f_500_0]
    movd    r8d, xmm0                   ; sizeX bits
    movss   xmm0, DWORD PTR [f_700_0]
    movd    r9d, xmm0                   ; sizeY bits
    movzx   eax, BYTE PTR [GUI_menu_opened]
    mov     DWORD PTR [rsp+20h], eax    ; isOpen (5th arg)
    call    ZeroGUI_Begin
    test    al, al
    jz      @@end_gui                   ; window closed

    ; Inside window: only if bListening && HostBeacon
    movzx   eax, BYTE PTR [bListening]
    test    al, al
    jz      @@end_gui
    mov     rax, QWORD PTR [HostBeacon]
    test    rax, rax
    jz      @@end_gui

    ; Get World and GameState (used by both tabs)
    call    SDK_GetWorld
    test    rax, rax
    jz      @@end_gui
    mov     rbx, rax                    ; rbx = World*
    mov     rbp, QWORD PTR [rbx + UWORLD_GameState]
    test    rbp, rbp
    jz      @@end_gui
    ; rbp = GameState*

    ; currentPlayer != nullptr branch
    mov     rax, QWORD PTR [GUI_currentPlayer]
    test    rax, rax
    jz      @@show_tabs

    ; Back button
    lea     rcx, [szBtn_Back]
    movss   xmm0, DWORD PTR [f_25_0]
    movd    edx, xmm0                   ; sizeX = 25.0f
    movd    r8d, xmm0                   ; sizeY = 25.0f
    call    ZeroGUI_Button
    test    al, al
    jz      @@no_back
    ; Back pressed: clear currentPlayer
    xor     rax, rax
    mov     QWORD PTR [GUI_currentPlayer], rax
    jmp     @@end_gui                   ; redraw next frame

@@no_back:
    ; NextColumn(90.0f)
    movss   xmm0, DWORD PTR [f_90_0]
    call    ZeroGUI_NextColumn

    ; Text("Current Player:")
    lea     rcx, [szText_CurPlayer]
    xor     dl, dl                      ; center=false
    xor     r8b, r8b                    ; outline=false
    call    ZeroGUI_Text

    ; Kick button
    lea     rcx, [szBtn_Kick]
    movss   xmm0, DWORD PTR [f_60_0]
    movd    edx, xmm0
    movss   xmm0, DWORD PTR [f_25_0]
    movd    r8d, xmm0
    call    ZeroGUI_Button
    test    al, al
    jz      @@no_kick

    ; Kick pressed: KickController(currentPlayer->Owner, ...)
    mov     rax, QWORD PTR [GUI_currentPlayer]
    mov     rcx, QWORD PTR [rax + AACTOR_Owner]  ; Owner = PlayerController
    call    GUI__KickController
    ; Clear currentPlayer
    xor     rax, rax
    mov     QWORD PTR [GUI_currentPlayer], rax
    jmp     @@end_gui

@@no_kick:
    jmp     @@end_gui

; Tab bar
@@show_tabs:
    ; ButtonTab "Game" (110×25, active when tab==0)
    lea     rcx, [szBtnTab_Game]
    movss   xmm0, DWORD PTR [f_110_0]
    movd    edx, xmm0
    movss   xmm0, DWORD PTR [f_25_0]
    movd    r8d, xmm0
    xor     r9d, r9d
    cmp     DWORD PTR [GUI_tab], 0
    sete    r9b                         ; active = (tab == 0)
    call    ZeroGUI_ButtonTab
    test    al, al
    jz      @@no_tab0
    mov     DWORD PTR [GUI_tab], 0
@@no_tab0:

    ; ButtonTab "Players" (110×25, active when tab==1)
    lea     rcx, [szBtnTab_Players]
    movss   xmm0, DWORD PTR [f_110_0]
    movd    edx, xmm0
    movss   xmm0, DWORD PTR [f_25_0]
    movd    r8d, xmm0
    xor     r9d, r9d
    cmp     DWORD PTR [GUI_tab], 1
    sete    r9b
    call    ZeroGUI_ButtonTab
    test    al, al
    jz      @@no_tab1
    mov     DWORD PTR [GUI_tab], 1
@@no_tab1:

    ; NextColumn(130.0f)
    movss   xmm0, DWORD PTR [f_130_0]
    call    ZeroGUI_NextColumn

    ; Tab content
    mov     eax, DWORD PTR [GUI_tab]
    cmp     eax, 0
    je      @@tab_game
    cmp     eax, 1
    je      @@tab_players
    jmp     @@end_gui

; Tab 0: Game
@@tab_game:
    ; Only show "Start Bus" if !bStartedBus
    movzx   eax, BYTE PTR [bStartedBus]
    test    al, al
    jnz     @@end_gui

    lea     rcx, [szBtn_StartBus]
    movss   xmm0, DWORD PTR [f_100_0]
    movd    edx, xmm0
    movss   xmm0, DWORD PTR [f_25_0]
    movd    r8d, xmm0
    call    ZeroGUI_Button
    test    al, al
    jz      @@end_gui

    ; Start Bus clicked
    call    GUI__StartBus
    jmp     @@end_gui

; Tab 1: Players
@@tab_players:
    ; Text("Connected Players")
    lea     rcx, [szText_ConnPlayers]
    xor     dl, dl
    xor     r8b, r8b
    call    ZeroGUI_Text

    ; Iterate GameState->PlayerArray
    mov     esi, DWORD PTR [rbp + AGSA_PlayerArray_Num]
    test    esi, esi
    jz      @@end_gui
    mov     rdi, QWORD PTR [rbp + AGSA_PlayerArray_Data]
    test    rdi, rdi
    jz      @@end_gui

    xor     DWORD PTR [rsp+2Ch], 0      ; loop index = 0
    mov     DWORD PTR [rsp+2Ch], 0

@@player_loop:
    mov     eax, DWORD PTR [rsp+2Ch]
    cmp     eax, esi
    jae     @@end_gui                   ; done iterating

    ; Get PlayerState pointer = PlayerArray.Data[i] (array of pointers)
    movzx   rax, eax
    mov     rax, QWORD PTR [rdi + rax*8]
    test    rax, rax
    jz      @@player_next

    mov     QWORD PTR [rsp+30h], rax    ; save PlayerState*

    ; Get player name via ProcessEvent
    mov     rcx, rax
    call    GUI__GetPlayerName          ; RAX = wchar_t* (or 0)
    test    rax, rax
    jz      @@player_next

    ; Button with player name (100×25)
    mov     rcx, rax                    ; name = wchar_t*
    movss   xmm0, DWORD PTR [f_100_0]
    movd    edx, xmm0
    movss   xmm0, DWORD PTR [f_25_0]
    movd    r8d, xmm0
    call    ZeroGUI_Button
    test    al, al
    jz      @@player_next

    ; Button clicked: set currentPlayer = PlayerState
    mov     rax, QWORD PTR [rsp+30h]
    mov     QWORD PTR [GUI_currentPlayer], rax
    jmp     @@end_gui

@@player_next:
    inc     DWORD PTR [rsp+2Ch]
    jmp     @@player_loop

@@end_gui:
    ; ZeroGUI_End (flush drawlist)
    call    ZeroGUI_End

    add     rsp, 68h
    pop     rdi
    pop     rsi
    pop     rbp
    pop     rbx
    ret
GUI_Tick ENDP

END