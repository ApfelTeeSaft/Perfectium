INCLUDE asm\include\master.inc

GMB_Teams           EQU 000h
GMB_OnPlayerJoined  EQU 020h

.const

szPlaylist_Solos    DB "FortPlaylistAthena Playlist_DefaultSolo.Playlist_DefaultSolo", 0

.code

; GameModeSolos_OnPlayerJoined
; In: RCX = AFortPlayerControllerAthena* (PC)
;
; Frame: 1 push (RBX) + sub 20h = 8+32=40
;   N=1(odd): RSP=0 after push; sub 20h(32) -> RSP=0
GameModeSolos_OnPlayerJoined PROC
    push    rbx
    sub     rsp, 20h

    mov     rbx, rcx                            ; RBX = PC

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
GameModeSolos_OnPlayerJoined ENDP


; GameModeSolos_Initialize
; In: none
; Out: RAX = GMB* (or 0 on failure)
;
; Frame: 0 pushes + sub 28h = 40
;   N=0(even): RSP=8; sub 28h(40) -> 8-40=-32=0
;   [rsp+0..+1F]=shadow, [rsp+20h]=5th arg (bRejoin=0)
GameModeSolos_Initialize PROC
    sub     rsp, 28h

    lea     rcx, [szPlaylist_Solos]
    xor     dl, dl                              ; bRespawnEnabled = false
    mov     r8d, 1                              ; maxTeamSize = 1
    xor     r9b, r9b                            ; bRegenEnabled = false
    mov     BYTE PTR [rsp + 20h], 0             ; bRejoinEnabled = false (5th arg)
    call    GameModeBase_New
    test    rax, rax
    jz      @@done
    lea     rcx, [GameModeSolos_OnPlayerJoined]
    mov     QWORD PTR [rax + GMB_OnPlayerJoined], rcx

@@done:
    add     rsp, 28h
    ret
GameModeSolos_Initialize ENDP

END