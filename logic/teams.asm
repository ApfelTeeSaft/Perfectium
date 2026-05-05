INCLUDE asm\include\master.inc

; Team struct offsets
TEAM_maxTeamSize    EQU 000h
TEAM_TeamPosition   EQU 004h
TEAM_Members_Data   EQU 008h
TEAM_Members_Num    EQU 010h
TEAM_Members_Max    EQU 014h
TEAM_SIZEOF         EQU 018h

; PlayerTeams struct offsets
PT_maxTeamSize      EQU 000h
PT_lastAssigned     EQU 004h
PT_Teams_Data       EQU 008h
PT_Teams_Num        EQU 010h
PT_Teams_Max        EQU 014h
PT_SIZEOF           EQU 018h

; AController::PlayerState
ACTRL_PlayerState   EQU 0248h

; AFortPlayerStateAthena field offsets
PS_PlayerTeam       EQU 08F0h   ; AFortTeamInfo*
PS_TeamIndex        EQU 0F60h   ; byte (EFortTeam)
PS_SquadId          EQU 10F0h   ; byte

; AFortTeamInfo field offsets
FTI_TeamMembers     EQU 0320h   ; TArray<AController*>
FTI_Team            EQU 0330h   ; byte (EFortTeam)

.const

sz_OnRep_SquadId    BYTE "Function FortniteGame.FortPlayerStateAthena.OnRep_SquadId",0
sz_OnRep_PlayerTeam BYTE "Function FortniteGame.FortPlayerState.OnRep_PlayerTeam",0

.data?

fn_OnRep_SquadId    QWORD ?
fn_OnRep_PlayerTeam QWORD ?

.code

; Team_New
; In : ECX = TeamPosition (EFortTeam, DWORD)
;      EDX = maxTeamSize (DWORD)
; Out: RAX = Team* (heap-allocated)
;
; Stack: push rbx push rbp + sub 28h -> 2+2*8=32; 8-32=8; sub28h=40; 8-40=0 
Team_New PROC
    push    rbx
    push    rbp
    sub     rsp, 28h

    mov     ebx, ecx                ; EBX = TeamPosition
    mov     ebp, edx                ; EBP = maxTeamSize

    mov     ecx, TEAM_SIZEOF
    mov     edx, 8                  ; alignment = 8
    call    QWORD PTR [FMemory_Malloc]
    test    rax, rax
    jz      @TN_done

    ; Zero the allocation
    push    rax
    mov     rcx, rax
    xor     edx, edx
    mov     r8d, TEAM_SIZEOF
    call    memset
    pop     rax

    mov     DWORD PTR [rax + TEAM_maxTeamSize], ebp
    mov     DWORD PTR [rax + TEAM_TeamPosition], ebx

@TN_done:
    add     rsp, 28h
    pop     rbp
    pop     rbx
    ret
Team_New ENDP


; Team_Num
; In : RCX = Team*
; Out: EAX = member count
Team_Num PROC
    mov     eax, DWORD PTR [rcx + TEAM_Members_Num]
    ret
Team_Num ENDP


; Team_AddPlayer
; In : RCX = Team*
;      RDX = AFortPlayerController* (pc)
;
; Stack: push rbx push rbp + sub 28h -> 0  (same as Team_New)
Team_AddPlayer PROC
    push    rbx
    push    rbp
    sub     rsp, 28h

    mov     rbx, rcx                ; RBX = Team*
    mov     rbp, rdx                ; RBP = pc

    ; if Num() == maxTeamSize, return
    mov     eax, DWORD PTR [rbx + TEAM_Members_Num]
    cmp     eax, DWORD PTR [rbx + TEAM_maxTeamSize]
    jge     @TAP_done

    ; TArray_Add(&Members, &pc, 8)
    lea     rcx, [rbx + TEAM_Members_Data]  ; ptr to TArrayHeader (Data QWORD at start)
    lea     rdx, QWORD PTR [rbp]
    push    rbp
    mov     r8d, 8
    ; TArray_Add expects (TArrayHeader*, elem*, elem_size)
    ; need to pass address of pc on stack
    lea     rdx, [rsp]              ; &pc on stack (rbp was pushed to [rsp])
    call    TArray_Add
    add     rsp, 8                  ; pop the pushed rbp value

    ; InitializePlayer(Team*, pc)
    mov     rcx, rbx
    mov     rdx, rbp
    call    Team_InitializePlayer

@TAP_done:
    add     rsp, 28h
    pop     rbp
    pop     rbx
    ret
Team_AddPlayer ENDP


; Team_Kick
; In : RCX = Team*
Team_Kick PROC
    ret
Team_Kick ENDP


; Team_InitializePlayer
; In : RCX = Team*
;      RDX = AFortPlayerController* (pc)
;
; Sets TeamIndex, PlayerTeam->Team, SquadId on the player state,
; appends pc to PlayerTeam->TeamMembers, fires OnRep_SquadId and OnRep_PlayerTeam.
;
; Stack: 5 pushes (40) + sub 60h (96) = 136; 8-136=-128=0 
;
; Frame:
;   [+00..+1F] shadow
;   [+20..+27] arg5 slot
;   [+28..+2F] zero params scratch (for zero-arg ProcessEvent calls)
Team_InitializePlayer PROC
    push    rbx
    push    rbp
    push    rsi
    push    rdi
    push    r12
    sub     rsp, 60h

    mov     rbx, rcx                ; RBX = Team*
    mov     rdi, rdx                ; RDI = pc

    ; PlayerState = pc->PlayerState (AController+0x248)
    mov     rsi, QWORD PTR [rdi + ACTRL_PlayerState]
    test    rsi, rsi
    jz      @TIP_done

    ; EBP = TeamPosition
    mov     ebp, DWORD PTR [rbx + TEAM_TeamPosition]

    ; PlayerState->TeamIndex = TeamPosition
    mov     BYTE PTR [rsi + PS_TeamIndex], bpl

    ; PlayerState->PlayerTeam->Team = TeamPosition
    mov     r12, QWORD PTR [rsi + PS_PlayerTeam]
    test    r12, r12
    jz      @TIP_skip_team_set
    mov     BYTE PTR [r12 + FTI_Team], bpl

    ; PlayerState->PlayerTeam->TeamMembers.Add(pc)
    ; TArray_Add(&TeamMembers, &pc, 8)
    push    rdi                             ; push pc value onto stack
    lea     rcx, [r12 + FTI_TeamMembers]    ; &TArrayHeader
    lea     rdx, [rsp]                      ; &pc value on stack
    mov     r8d, 8
    call    TArray_Add
    add     rsp, 8                          ; pop pc value

@TIP_skip_team_set:
    ; PlayerState->SquadId = (TeamPosition - 2) + 1 = TeamPosition - 1
    mov     eax, ebp
    sub     eax, 1
    mov     BYTE PTR [rsi + PS_SquadId], al

    ; Lazy-load OnRep_SquadId
    mov     rax, QWORD PTR [fn_OnRep_SquadId]
    test    rax, rax
    jnz     @TIP_sq_ok
    lea     rcx, [sz_OnRep_SquadId]
    call    SDK_FindObject
    mov     QWORD PTR [fn_OnRep_SquadId], rax
@TIP_sq_ok:
    test    rax, rax
    jz      @TIP_skip_sq
    ; ProcessEvent(PlayerState, fn, NULL_params)
    xor     r8d, r8d
    mov     QWORD PTR [rsp + 28h], 0    ; zero params scratch
    mov     rcx, rsi
    mov     rdx, rax
    lea     r8, [rsp + 28h]
    call    QWORD PTR [ProcessEvent]

@TIP_skip_sq:
    ; Lazy-load OnRep_PlayerTeam
    mov     rax, QWORD PTR [fn_OnRep_PlayerTeam]
    test    rax, rax
    jnz     @TIP_pt_ok
    lea     rcx, [sz_OnRep_PlayerTeam]
    call    SDK_FindObject
    mov     QWORD PTR [fn_OnRep_PlayerTeam], rax
@TIP_pt_ok:
    test    rax, rax
    jz      @TIP_done
    xor     r8d, r8d
    mov     QWORD PTR [rsp + 28h], 0
    mov     rcx, rsi
    mov     rdx, rax
    lea     r8, [rsp + 28h]
    call    QWORD PTR [ProcessEvent]

@TIP_done:
    add     rsp, 60h
    pop     r12
    pop     rdi
    pop     rsi
    pop     rbp
    pop     rbx
    ret
Team_InitializePlayer ENDP


; PlayerTeams_New
; In : ECX = maxTeamSize (DWORD)
; Out: RAX = PlayerTeams* (heap-allocated)
;
; Stack: push rbx + sub 28h -> 1+8=16; 8-16=8; sub28h: 8-40=0 
PlayerTeams_New PROC
    push    rbx
    sub     rsp, 28h

    mov     ebx, ecx                ; EBX = maxTeamSize

    mov     ecx, PT_SIZEOF
    mov     edx, 8
    call    QWORD PTR [FMemory_Malloc]
    test    rax, rax
    jz      @PTN_done

    push    rax
    mov     rcx, rax
    xor     edx, edx
    mov     r8d, PT_SIZEOF
    call    memset
    pop     rax

    mov     DWORD PTR [rax + PT_maxTeamSize], ebx
    ; lastAssignedIndex = 0, Teams array = zero (already zeroed)

@PTN_done:
    add     rsp, 28h
    pop     rbx
    ret
PlayerTeams_New ENDP


; PlayerTeams_GetNextSlot
; In : RCX = PlayerTeams*
; Out: EAX = EFortTeam value = Teams.Num + 2
PlayerTeams_GetNextSlot PROC
    mov     eax, DWORD PTR [rcx + PT_Teams_Num]
    add     eax, 2
    ret
PlayerTeams_GetNextSlot ENDP


; PlayerTeams_FindAvailableSpot
; In : RCX = PlayerTeams*
; Out: RAX = Team* or NULL
;
; If maxTeamSize > 0: find first team with Num < maxTeamSize.
; If maxTeamSize < 0 (round-robin): abs(maxTeamSize) teams must exist;
;   returns Teams[lastAssigned] and increments lastAssigned.
;
; Stack: push rbx push rbp + sub 28h -> 0 
PlayerTeams_FindAvailableSpot PROC
    push    rbx
    push    rbp
    sub     rsp, 28h

    mov     rbx, rcx                ; RBX = PlayerTeams*

    mov     ebp, DWORD PTR [rbx + PT_maxTeamSize]
    test    ebp, ebp
    js      @PFas_roundrobin

    ; maxTeamSize >= 0: linear scan for available slot
    mov     ecx, DWORD PTR [rbx + PT_Teams_Num]
    test    ecx, ecx
    jz      @PFas_null
    mov     rdx, QWORD PTR [rbx + PT_Teams_Data]
    test    rdx, rdx
    jz      @PFas_null

    xor     eax, eax                ; i = 0
@PFas_linear:
    cmp     eax, ecx
    jge     @PFas_null
    mov     r8, QWORD PTR [rdx + rax*8]  ; Teams[i] (Team*)
    test    r8, r8
    jz      @PFas_linear_next
    mov     r9d, DWORD PTR [r8 + TEAM_Members_Num]
    cmp     r9d, ebp
    jl      @PFas_found              ; Num < maxTeamSize -> available
@PFas_linear_next:
    inc     eax
    jmp     @PFas_linear

@PFas_roundrobin:
    ; abs(maxTeamSize) teams must exist
    neg     ebp
    mov     ecx, DWORD PTR [rbx + PT_Teams_Num]
    cmp     ecx, ebp
    jl      @PFas_null               ; not enough teams yet

    mov     eax, DWORD PTR [rbx + PT_lastAssigned]
    mov     rdx, QWORD PTR [rbx + PT_Teams_Data]
    test    rdx, rdx
    jz      @PFas_null
    mov     rax, QWORD PTR [rdx + rax*8]  ; Teams[lastAssigned]

    ; Increment lastAssigned (wrap at Teams.Num-1)
    mov     ecx, DWORD PTR [rbx + PT_lastAssigned]
    inc     ecx
    mov     edx, DWORD PTR [rbx + PT_Teams_Num]
    cmp     ecx, edx
    jl      @PFas_rr_nowrap
    xor     ecx, ecx
@PFas_rr_nowrap:
    mov     DWORD PTR [rbx + PT_lastAssigned], ecx
    jmp     @PFas_found

@PFas_found:
    add     rsp, 28h
    pop     rbp
    pop     rbx
    ret

@PFas_null:
    xor     eax, eax
    add     rsp, 28h
    pop     rbp
    pop     rbx
    ret
PlayerTeams_FindAvailableSpot ENDP


; PlayerTeams_AddPlayerToRandomTeam
; In : RCX = PlayerTeams*
;      RDX = AFortPlayerController* (pc)
;
; Finds or creates a team with space, then adds the player.
;
; Stack: 4 pushes (32) + sub 38h (56) = 88; 8-88=-80=0 
PlayerTeams_AddPlayerToRandomTeam PROC
    push    rbx
    push    rbp
    push    rsi
    push    rdi
    sub     rsp, 38h

    mov     rbx, rcx                ; RBX = PlayerTeams*
    mov     rdi, rdx                ; RDI = pc

    ; Try FindAvailableSpot
    mov     rcx, rbx
    call    PlayerTeams_FindAvailableSpot
    test    rax, rax
    jz      @PTAPART_new_team

    ; Available: add player to existing team
    mov     rcx, rax
    mov     rdx, rdi
    call    Team_AddPlayer
    jmp     @PTAPART_done

@PTAPART_new_team:
    ; No spot: create a new Team and add to PlayerTeams.Teams array
    mov     rcx, rbx
    call    PlayerTeams_GetNextSlot     ; EAX = new TeamPosition
    mov     esi, eax                    ; ESI = TeamPosition

    ; Team_New(TeamPosition, maxTeamSize)
    mov     ecx, esi
    mov     edx, DWORD PTR [rbx + PT_maxTeamSize]
    call    Team_New
    test    rax, rax
    jz      @PTAPART_done
    mov     rbp, rax                    ; RBP = new Team*

    ; TArray_Add(&Teams, &newTeam, 8)
    push    rbp                         ; push Team* onto stack
    lea     rcx, [rbx + PT_Teams_Data]  ; &TArrayHeader for Teams
    lea     rdx, [rsp]                  ; &(Team* on stack)
    mov     r8d, 8
    call    TArray_Add
    add     rsp, 8

    ; Team_AddPlayer(newTeam, pc)
    mov     rcx, rbp
    mov     rdx, rdi
    call    Team_AddPlayer

@PTAPART_done:
    add     rsp, 38h
    pop     rdi
    pop     rsi
    pop     rbp
    pop     rbx
    ret
PlayerTeams_AddPlayerToRandomTeam ENDP


; PlayerTeams_AddPlayerToTeam - alias for AddPlayerToRandomTeam
PlayerTeams_AddPlayerToTeam PROC
    jmp     PlayerTeams_AddPlayerToRandomTeam
PlayerTeams_AddPlayerToTeam ENDP

END