INCLUDE include\master.inc

EXTERNDEF   GMB_Current         :QWORD
EXTERNDEF   GameModeBase_New    :PROC

GMB_Teams           EQU 000h
GMB_OnPlayerJoined  EQU 020h

.const

szPlaylist_Duos     DB "FortPlaylistAthena Playlist_DefaultDuo.Playlist_DefaultDuo", 0

.code

; GameModeDuos_OnPlayerJoined
; In: RCX = AFortPlayerControllerAthena* (PC)
;
; Frame: 1 push + sub 20h = 40; N=1(odd) -> RSP=0
GameModeDuos_OnPlayerJoined PROC
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
GameModeDuos_OnPlayerJoined ENDP


; GameModeDuos_Initialize
; In: none
; Out: RAX = GMB*
;
; Frame: 0 pushes + sub 28h = 40; RSP=0
GameModeDuos_Initialize PROC
    sub     rsp, 28h

    lea     rcx, [szPlaylist_Duos]
    xor     dl, dl                              ; bRespawnEnabled = false
    mov     r8d, 2                              ; maxTeamSize = 2 (duos)
    xor     r9b, r9b                            ; bRegenEnabled = false
    mov     BYTE PTR [rsp + 20h], 0             ; bRejoinEnabled = false
    call    GameModeBase_New
    test    rax, rax
    jz      @@done
    lea     rcx, [GameModeDuos_OnPlayerJoined]
    mov     QWORD PTR [rax + GMB_OnPlayerJoined], rcx

@@done:
    add     rsp, 28h
    ret
GameModeDuos_Initialize ENDP

END