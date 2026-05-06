INCLUDE include\master.inc

EXTERNDEF   GMB_Current         :QWORD
EXTERNDEF   GameModeBase_New    :PROC

GMB_Teams           EQU 000h
GMB_OnPlayerJoined  EQU 020h

.const

szPlaylist_50v50    DB "FortPlaylistAthena Playlist_5x20.Playlist_5x20", 0

.code

; GameMode50v50_OnPlayerJoined
; In: RCX = AFortPlayerControllerAthena* (PC)
;
; Frame: 1 push + sub 20h = 40; N=1(odd) -> RSP=0
GameMode50v50_OnPlayerJoined PROC
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
GameMode50v50_OnPlayerJoined ENDP


; GameMode50v50_Initialize
; In: none
; Out: RAX = GMB*
;
; maxTeamSize = -2 -> round-robin between 2 teams
; Frame: 0 pushes + sub 28h = 40; RSP=0
GameMode50v50_Initialize PROC
    sub     rsp, 28h

    lea     rcx, [szPlaylist_50v50]
    xor     dl, dl                              ; bRespawnEnabled = false
    mov     r8d, 0FFFFFFFEh                     ; maxTeamSize = -2 (signed DWORD)
    xor     r9b, r9b                            ; bRegenEnabled = false
    mov     BYTE PTR [rsp + 20h], 0             ; bRejoinEnabled = false
    call    GameModeBase_New
    test    rax, rax
    jz      @@done
    lea     rcx, [GameMode50v50_OnPlayerJoined]
    mov     QWORD PTR [rax + GMB_OnPlayerJoined], rcx

@@done:
    add     rsp, 28h
    ret
GameMode50v50_Initialize ENDP

END