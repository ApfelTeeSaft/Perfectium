INCLUDE asm\include\master.inc

.data?

ZI_mouseDown        BYTE  5 DUP(?)    ; mouseDown[5]
ZI_mouseDownAlready BYTE  256 DUP(?)  ; mouseDownAlready[256]
ZI_keysDown         BYTE  256 DUP(?)  ; keysDown[256]
ZI_keysDownAlready  BYTE  256 DUP(?)  ; keysDownAlready[256]

.code

; ZeroInput_Update (= Input::Handle)
; Polls GetAsyncKeyState(0x01) and updates mouseDown[0].
;
; In:  none
; Out: none
; Frame: 0 pushes + sub 28h -> RSP = 8-40 = -32 = 0 
ZeroInput_Update PROC
    sub     rsp, 28h

    mov     ecx, 1                  ; VK_LBUTTON = 0x01
    call    GetAsyncKeyState
    test    ax, ax
    jz      @@mouse_up
    mov     BYTE PTR [ZI_mouseDown], 1
    jmp     @@done
@@mouse_up:
    mov     BYTE PTR [ZI_mouseDown], 0
@@done:
    add     rsp, 28h
    ret
ZeroInput_Update ENDP


; ZeroInput_IsMouseClicked
; In:  ECX = button index (0-4)
;      EDX = element_id (0-255)
;      R8B = repeat (bool)
; Out: AL  = 1 if clicked, 0 otherwise
;
; Logic:
;   if mouseDown[button] is set:
;     if !mouseDownAlready[element_id]: set it, return true
;     if repeat: return true
;   else:
;     clear mouseDownAlready[element_id]
;   return false
;
; Frame: 0 pushes + sub 28h -> RSP = 0 
ZeroInput_IsMouseClicked PROC
    sub     rsp, 28h

    ; Check mouseDown[button]
    movzx   rax, ecx                    ; button index (zero-extend to 64-bit)
    movzx   eax, BYTE PTR [ZI_mouseDown + rax]
    test    al, al
    jz      @@clear_already             ; not pressed -> clear + return false

    ; mouseDown[button] is set — check mouseDownAlready[element_id]
    movzx   rcx, edx                    ; element_id -> index (zero-extend)
    movzx   eax, BYTE PTR [ZI_mouseDownAlready + rcx]
    test    al, al
    jnz     @@check_repeat              ; already marked -> check repeat

    ; First press: set mouseDownAlready[element_id] = true, return true
    mov     BYTE PTR [ZI_mouseDownAlready + rcx], 1
    mov     al, 1
    jmp     @@done

@@check_repeat:
    ; Already pressed: return repeat flag
    movzx   eax, r8b                    ; AL = repeat
    jmp     @@done

@@clear_already:
    ; Mouse is not down: clear mouseDownAlready[element_id]
    movzx   rcx, edx
    mov     BYTE PTR [ZI_mouseDownAlready + rcx], 0
    xor     al, al
@@done:
    add     rsp, 28h
    ret
ZeroInput_IsMouseClicked ENDP


; ZeroInput_IsKeyPressed
; In:  ECX = key code (0-255)
;      DL  = repeat (bool)
; Out: AL  = 1 if pressed, 0 otherwise
;
; Frame: 0 pushes + sub 28h -> RSP = 0 
ZeroInput_IsKeyPressed PROC
    sub     rsp, 28h

    movzx   rax, ecx                    ; key index
    movzx   eax, BYTE PTR [ZI_keysDown + rax]
    test    al, al
    jz      @@clear_already

    movzx   rcx, ecx
    movzx   eax, BYTE PTR [ZI_keysDownAlready + rcx]
    test    al, al
    jnz     @@check_repeat

    mov     BYTE PTR [ZI_keysDownAlready + rcx], 1
    mov     al, 1
    jmp     @@done

@@check_repeat:
    movzx   eax, dl                     ; AL = repeat
    jmp     @@done

@@clear_already:
    movzx   rcx, ecx
    mov     BYTE PTR [ZI_keysDownAlready + rcx], 0
    xor     al, al
@@done:
    add     rsp, 28h
    ret
ZeroInput_IsKeyPressed ENDP

END