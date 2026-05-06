INCLUDE asm\include\master.inc

GMB_Teams           EQU 000h
GMB_OnPlayerJoined  EQU 020h

.const

szPlaylist_PG       DB "FortPlaylistAthena Playlist_Playground.Playlist_Playground", 0

.code

; GameModePlayground_OnPlayerJoined
; In: RCX = AFortPlayerControllerAthena* (PC)
;
; Frame: 1 push + sub 20h = 40; N=1(odd) -> RSP=0
GameModePlayground_OnPlayerJoined PROC
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
GameModePlayground_OnPlayerJoined ENDP


; GameModePlayground_Initialize
; In: none
; Out: RAX = GMB*
;
; bRespawnEnabled=true, maxTeamSize=1, bRegenEnabled=false, bRejoinEnabled=true
; Frame: 0 pushes + sub 28h = 40; RSP=0
GameModePlayground_Initialize PROC
    sub     rsp, 28h

    lea     rcx, [szPlaylist_PG]
    mov     dl, 1                               ; bRespawnEnabled = true
    mov     r8d, 1                              ; maxTeamSize = 1
    xor     r9b, r9b                            ; bRegenEnabled = false
    mov     BYTE PTR [rsp + 20h], 1             ; bRejoinEnabled = true (5th arg)
    call    GameModeBase_New
    test    rax, rax
    jz      @@done
    lea     rcx, [GameModePlayground_OnPlayerJoined]
    mov     QWORD PTR [rax + GMB_OnPlayerJoined], rcx

@@done:
    add     rsp, 28h
    ret
GameModePlayground_Initialize ENDP

END