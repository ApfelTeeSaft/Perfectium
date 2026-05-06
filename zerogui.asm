INCLUDE include\master.inc

; DrawList field offsets
DL_type         EQU 000h
DL_pos_X        EQU 004h
DL_pos_Y        EQU 008h
DL_size_X       EQU 00Ch
DL_size_Y       EQU 010h
DL_color_R      EQU 014h
DL_color_G      EQU 018h
DL_color_B      EQU 01Ch
DL_color_A      EQU 020h
DL_name         EQU 028h
DL_outline      EQU 030h
DL_from_X       EQU 034h
DL_from_Y       EQU 038h
DL_to_X         EQU 03Ch
DL_to_Y         EQU 040h
DL_thickness    EQU 044h
DL_SIZE         EQU 048h   ; 72 bytes per entry

DRAWLIST_COUNT  EQU 128

; K2_DrawLine params offsets within [rsp+20h] block
KDL_A_X         EQU 000h   ; +0x20 in frame
KDL_A_Y         EQU 004h
KDL_B_X         EQU 008h
KDL_B_Y         EQU 00Ch
KDL_THICK       EQU 010h
KDL_COLOR_R     EQU 014h
KDL_COLOR_G     EQU 018h
KDL_COLOR_B     EQU 01Ch
KDL_COLOR_A     EQU 020h   ; total = 0x24 bytes

; K2_DrawText params offsets within [rsp+20h] block
KDT_FONT        EQU 000h   ; UFont* (8)
KDT_STR_DATA    EQU 008h   ; FString.Data (8)
KDT_STR_NUM     EQU 010h   ; FString.Num  (4)
KDT_STR_MAX     EQU 014h   ; FString.Max  (4)
KDT_POS_X       EQU 018h
KDT_POS_Y       EQU 01Ch
KDT_CLR_R       EQU 020h
KDT_CLR_G       EQU 024h
KDT_CLR_B       EQU 028h
KDT_CLR_A       EQU 02Ch
KDT_KERNING     EQU 030h   ; float = 0.0f
KDT_SHADOW_R    EQU 034h   ; 4xfloat zeros
KDT_SHADOW_G    EQU 038h
KDT_SHADOW_B    EQU 03Ch
KDT_SHADOW_A    EQU 040h
KDT_SOFF_X      EQU 044h   ; ShadowOffset.X = posX+1.0f
KDT_SOFF_Y      EQU 048h   ; ShadowOffset.Y = posY+1.0f
KDT_CENTREX     EQU 04Ch   ; bool
KDT_CENTREY     EQU 04Dh   ; bool = 1
KDT_OUTLINED    EQU 04Eh   ; bool
KDT_PAD         EQU 04Fh
KDT_OUT_CLR_R   EQU 050h
KDT_OUT_CLR_G   EQU 054h
KDT_OUT_CLR_B   EQU 058h
KDT_OUT_CLR_A   EQU 05Ch   ; = 0.30f
; total: 0x60 bytes

; Immediate float constants (IEEE 754)
F_0_0       EQU 000000000h  ; 0.0f
F_1_0       EQU 03F800000h  ; 1.0f
F_5_0       EQU 040A00000h  ; 5.0f
F_10_0      EQU 041200000h  ; 10.0f
F_12_5      EQU 041480000h  ; 12.5f
F_0_30      EQU 03E99999Ah  ; 0.30f (outline alpha)

.const

; FLinearColor blocks (R, G, B, A as REAL4)
clr_Win_Bg      REAL4  0.009, 0.009, 0.009, 1.0   ; Window background
clr_Win_Hdr     REAL4  0.10,  0.15,  0.84,  1.0   ; Window header
clr_Btn_Idle    REAL4  0.10,  0.15,  0.84,  1.0   ; Button idle
clr_Btn_Hover   REAL4  0.15,  0.20,  0.89,  1.0   ; Button hovered
clr_Btn_Active  REAL4  0.20,  0.25,  0.94,  1.0   ; ButtonTab active
clr_White       REAL4  1.0,   1.0,   1.0,   1.0   ; Text colour
clr_Outline     REAL4  0.0,   0.0,   0.0,   0.30  ; Text outline

; Float scalars
f_0_5   REAL4  0.5
f_25_0  REAL4  25.0

szFn_K2DrawLineA    DB "Function Engine.Canvas.K2_DrawLine", 0
szFn_K2DrawTextA    DB "Function Engine.Canvas.K2_DrawText", 0
szObj_FontRoboto    DB "Font Roboto.Roboto", 0

; Wide HWND search strings
szWC_UnrealWindow   DB 'U',0,'n',0,'r',0,'e',0,'a',0,'l',0,'W',0,'i',0,'n',0,'d',0,'o',0,'w',0, 0,0
szWC_Fortnite       DB 'F',0,'o',0,'r',0,'t',0,'n',0,'i',0,'t',0,'e',0,' ',0,' ',0, 0,0

.data?

; Canvas pointer (set by ZeroGUI_SetupCanvas)
ZG_canvas           QWORD   ?

; GUI state
ZG_hover_element    BYTE    ?   ; bool: any element currently hovered
ZG_menu_pos_X       REAL4   ?   ; window top-left X
ZG_menu_pos_Y       REAL4   ?   ; window top-left Y
ZG_offset_x         REAL4   ?   ; column offset
ZG_offset_y         REAL4   ?   ; row offset (advances after each element)
ZG_first_elem_X     REAL4   ?   ; first element position X
ZG_first_elem_Y     REAL4   ?   ; first element position Y
ZG_last_elem_X      REAL4   ?   ; last element position X
ZG_last_elem_Y      REAL4   ?   ; last element position Y
ZG_last_size_X      REAL4   ?   ; last element size X
ZG_last_size_Y      REAL4   ?   ; last element size Y
ZG_curr_elem        SDWORD  ?   ; current active drag element (-1 = none)
ZG_elem_count       DWORD   ?   ; elements rendered this frame
ZG_sameLine         BYTE    ?   ; next element on same row
ZG_pushY            BYTE    ?   ; next element Y is overridden
ZG_pushYvalue       REAL4   ?   ; override Y value
ZG_dragPos_X        REAL4   ?   ; drag anchor offset X
ZG_dragPos_Y        REAL4   ?   ; drag anchor offset Y

; Cached UObject / UFunction pointers
ZG_pFn_K2DrawLine   QWORD   ?
ZG_pFn_K2DrawText   QWORD   ?
ZG_pFont            QWORD   ?
ZG_hWndFortnite     QWORD   ?   ; FindWindow result (cached)

; PostRenderer draw list: 128 x 72 bytes
ZG_drawlist         BYTE  (128 * 72) DUP(?)

.code

; ZeroGUI__CursorPos   (internal)
; Fills a caller-provided FVector2D with screen cursor position.
; In:  RCX = FVector2D* (out) - pointer to {X:REAL4, Y:REAL4}
; Frame: 0 pushes + sub 38h -> RSP = 8-56 = -48 = 0 
;   [rsp+20h..+23h] = POINT.x
;   [rsp+24h..+27h] = POINT.y
;   [rsp+28h..+2Fh] = saved out*
ZeroGUI__CursorPos PROC
    sub     rsp, 38h

    mov     QWORD PTR [rsp+28h], rcx    ; save out*

    ; GetCursorPos(&POINT)
    lea     rcx, [rsp+20h]
    call    GetCursorPos

    ; GetActiveWindow() -> HWND
    call    GetActiveWindow

    ; ScreenToClient(HWND, &POINT)
    mov     rcx, rax
    lea     rdx, [rsp+20h]
    call    ScreenToClient

    ; Convert LONG -> float, store in *out
    mov     rcx, QWORD PTR [rsp+28h]
    cvtsi2ss xmm0, DWORD PTR [rsp+20h]  ; x
    movss   DWORD PTR [rcx+0], xmm0
    cvtsi2ss xmm0, DWORD PTR [rsp+24h]  ; y
    movss   DWORD PTR [rcx+4], xmm0

    add     rsp, 38h
    ret
ZeroGUI__CursorPos ENDP


; ZeroGUI__MouseInZone  (internal)
; In:  ECX=posX_bits, EDX=posY_bits, R8D=sizeX_bits, R9D=sizeY_bits
; Out: AL = 1 if cursor inside zone, 0 otherwise
; Frame: 0 pushes + sub 58h -> RSP = 8-88 = -80 = 0 
;   [rsp+20h..+27h] = FVector2D cursor_pos output
;   [rsp+28h..+2Bh] = saved posX bits
;   [rsp+2Ch..+2Fh] = saved posY bits
;   [rsp+30h..+33h] = saved sizeX bits
;   [rsp+34h..+37h] = saved sizeY bits
ZeroGUI__MouseInZone PROC
    sub     rsp, 58h

    mov     DWORD PTR [rsp+28h], ecx
    mov     DWORD PTR [rsp+2Ch], edx
    mov     DWORD PTR [rsp+30h], r8d
    mov     DWORD PTR [rsp+34h], r9d

    lea     rcx, [rsp+20h]
    call    ZeroGUI__CursorPos          ; fills [rsp+20h] = {curX, curY}

    ; Load all values into XMM for comparison
    movss   xmm0, DWORD PTR [rsp+20h]  ; curX
    movss   xmm1, DWORD PTR [rsp+24h]  ; curY
    movss   xmm2, DWORD PTR [rsp+28h]  ; posX
    movss   xmm3, DWORD PTR [rsp+2Ch]  ; posY
    movss   xmm4, DWORD PTR [rsp+30h]  ; sizeX
    movss   xmm5, DWORD PTR [rsp+34h]  ; sizeY

    comiss  xmm0, xmm2                 ; curX > posX?
    jbe     @@false
    comiss  xmm1, xmm3                 ; curY > posY?
    jbe     @@false
    addss   xmm4, xmm2                 ; posX + sizeX
    comiss  xmm0, xmm4                 ; curX < posX+sizeX?
    jae     @@false
    addss   xmm5, xmm3                 ; posY + sizeY
    comiss  xmm1, xmm5                 ; curY < posY+sizeY?
    jae     @@false

    mov     al, 1
    jmp     @@done
@@false:
    xor     al, al
@@done:
    add     rsp, 58h
    ret
ZeroGUI__MouseInZone ENDP


; ZeroGUI__DrawFilledRect  (internal)
; Calls K2_DrawLine for each scanline (y from 0 to h-1).
; In:  ECX=posX_bits, EDX=posY_bits, R8D=w_bits, R9D=h_bits
;      [rsp+20h] = FLinearColor* (color - 4xREAL4 R,G,B,A)
; Out: none
;
; Frame: 2 pushes (RBX=canvas, RSI=fn) + sub 68h -> RSP = 8-16-104 = -112 = 0 
;   [rsp+0..+1F]    = shadow
;   [rsp+20h..+43h] = K2_DrawLine params (0x24 bytes)
;     [rsp+20h] A.X, [rsp+24h] A.Y, [rsp+28h] B.X, [rsp+2Ch] B.Y
;     [rsp+30h] Thickness, [rsp+34h..+43h] FLinearColor
;   [rsp+44h..+47h] = pad
;   [rsp+48h..+4Bh] = saved posX
;   [rsp+4Ch..+4Fh] = saved posY
;   [rsp+50h..+53h] = saved w
;   [rsp+54h..+57h] = saved h
;   [rsp+58h..+5Bh] = loop var i
;   [rsp+5Ch..+5Fh] = pad
;   [rsp+60h..+67h] = saved color*
;   5th arg (color*) from caller at [rsp+0A0h]:
;     RSP_current = RSP_entry - 16 - 104 = RSP_entry - 120
;     5th arg at RSP_entry+20h = RSP_current + 120 + 32 = RSP_current + 0xA0
ZeroGUI__DrawFilledRect PROC
    push    rbx
    push    rsi
    sub     rsp, 68h

    ; Save inputs
    mov     DWORD PTR [rsp+48h], ecx
    mov     DWORD PTR [rsp+4Ch], edx
    mov     DWORD PTR [rsp+50h], r8d
    mov     DWORD PTR [rsp+54h], r9d
    ; Retrieve color* (5th arg from caller's [rsp+20h])
    mov     rax, QWORD PTR [rsp+0A0h]
    mov     QWORD PTR [rsp+60h], rax

    ; Init loop var i = 0.0f
    xor     eax, eax
    mov     DWORD PTR [rsp+58h], eax

    ; Load canvas
    mov     rbx, QWORD PTR [ZG_canvas]
    test    rbx, rbx
    jz      @@done

    ; Lazy-load K2_DrawLine UFunction*
    mov     rsi, QWORD PTR [ZG_pFn_K2DrawLine]
    test    rsi, rsi
    jnz     @@fn_ready
    lea     rcx, [szFn_K2DrawLineA]
    call    SDK_FindObject
    mov     QWORD PTR [ZG_pFn_K2DrawLine], rax
    mov     rsi, rax
    test    rsi, rsi
    jz      @@done
@@fn_ready:

    ; Set Thickness = 1.0f in params
    mov     DWORD PTR [rsp+30h], F_1_0

    ; Copy FLinearColor from color* into params at [rsp+34h]
    mov     rax, QWORD PTR [rsp+60h]
    mov     ecx, DWORD PTR [rax+0]
    mov     DWORD PTR [rsp+34h], ecx   ; R
    mov     ecx, DWORD PTR [rax+4]
    mov     DWORD PTR [rsp+38h], ecx   ; G
    mov     ecx, DWORD PTR [rax+8]
    mov     DWORD PTR [rsp+3Ch], ecx   ; B
    mov     ecx, DWORD PTR [rax+12]
    mov     DWORD PTR [rsp+40h], ecx   ; A

@@loop:
    movss   xmm0, DWORD PTR [rsp+58h]  ; i
    movss   xmm1, DWORD PTR [rsp+54h]  ; h
    comiss  xmm0, xmm1
    jae     @@done                     ; i >= h -> exit

    ; A = { posX, posY + i }
    movss   xmm2, DWORD PTR [rsp+48h]  ; posX
    movss   xmm3, DWORD PTR [rsp+4Ch]  ; posY
    addss   xmm3, xmm0                 ; posY + i
    movss   DWORD PTR [rsp+20h], xmm2  ; A.X
    movss   DWORD PTR [rsp+24h], xmm3  ; A.Y

    ; B = { posX + w, posY + i }
    movss   xmm4, DWORD PTR [rsp+50h]  ; w
    addss   xmm4, xmm2
    movss   DWORD PTR [rsp+28h], xmm4  ; B.X
    movss   DWORD PTR [rsp+2Ch], xmm3  ; B.Y

    ; ProcessEvent(canvas, K2_DrawLine, &params)
    mov     rcx, rbx
    mov     rdx, rsi
    lea     r8, [rsp+20h]
    call    QWORD PTR [ProcessEvent]

    ; i += 1.0f
    movss   xmm0, DWORD PTR [rsp+58h]
    mov     eax, F_1_0
    movd    xmm1, eax
    addss   xmm0, xmm1
    movss   DWORD PTR [rsp+58h], xmm0
    jmp     @@loop

@@done:
    add     rsp, 68h
    pop     rsi
    pop     rbx
    ret
ZeroGUI__DrawFilledRect ENDP


; ZeroGUI__DrawText  (internal)
; Calls K2_DrawText via ProcessEvent.
; In:  RCX = name (wchar_t*)
;      EDX = posX bits (REAL4)
;      R8D = posY bits (REAL4)
;      R9  = FLinearColor* (render color)
;      [rsp+20h] = bCentreX (BYTE, 0=left, 1=center)
;      [rsp+28h] = bOutlined (BYTE)
;
; Frame: 4 pushes (RBX=name*, RBP=posX, RSI=posY, RDI=color*)
;        + sub 0A8h (168) -> RSP = 8-32-168 = -192 = 0 
;   [rsp+0..+1F]    = shadow
;   [rsp+20h..+7Fh] = K2_DrawText params (0x60 bytes)
;   [rsp+80h..+87h] = saved UFunction* for ProcessEvent
;   [rsp+88h]       = bCentreX (saved from 5th arg)
;   [rsp+89h]       = bOutlined (saved from 6th arg)
;   5th arg bCentreX at entry_RSP+0x28 = current_RSP+0xF0
;   6th arg bOutlined at entry_RSP+0x30 = current_RSP+0xF8
;     (prologue=200 bytes; 200+0x28=0xF0, 200+0x30=0xF8)
ZeroGUI__DrawText PROC
    push    rbx
    push    rbp
    push    rsi
    push    rdi
    sub     rsp, 0A8h

    mov     rbx, rcx                    ; name*
    mov     ebp, edx                    ; posX bits
    mov     esi, r8d                    ; posY bits
    mov     rdi, r9                     ; color*

    ; Save bCentreX and bOutlined from caller args
    ; prologue=200 bytes; 5th arg at entry_RSP+0x28 = current_RSP+0xF0
    movzx   eax, BYTE PTR [rsp+0F0h]
    mov     BYTE PTR [rsp+88h], al
    movzx   eax, BYTE PTR [rsp+0F8h]
    mov     BYTE PTR [rsp+89h], al

    ; Lazy-load UFont*
    mov     rax, QWORD PTR [ZG_pFont]
    test    rax, rax
    jnz     @@font_ready
    lea     rcx, [szObj_FontRoboto]
    call    SDK_FindObject
    mov     QWORD PTR [ZG_pFont], rax
@@font_ready:
    mov     QWORD PTR [rsp+20h + KDT_FONT], rax

    ; Lazy-load K2_DrawText UFunction*
    mov     rax, QWORD PTR [ZG_pFn_K2DrawText]
    test    rax, rax
    jnz     @@fn_ready
    lea     rcx, [szFn_K2DrawTextA]
    call    SDK_FindObject
    mov     QWORD PTR [ZG_pFn_K2DrawText], rax
@@fn_ready:
    mov     QWORD PTR [rsp+80h], rax

    ; Build FString from wchar_t* name
    lea     rcx, [rsp+20h + KDT_STR_DATA]
    mov     rdx, rbx                    ; wchar_t*
    call    FString_FromWideChar

    ; Fill remaining params
    ; ScreenPos
    mov     DWORD PTR [rsp+20h + KDT_POS_X], ebp
    mov     DWORD PTR [rsp+20h + KDT_POS_Y], esi

    ; RenderColor (copy 16 bytes from color*)
    mov     eax, DWORD PTR [rdi+0]
    mov     DWORD PTR [rsp+20h + KDT_CLR_R], eax
    mov     eax, DWORD PTR [rdi+4]
    mov     DWORD PTR [rsp+20h + KDT_CLR_G], eax
    mov     eax, DWORD PTR [rdi+8]
    mov     DWORD PTR [rsp+20h + KDT_CLR_B], eax
    mov     eax, DWORD PTR [rdi+12]
    mov     DWORD PTR [rsp+20h + KDT_CLR_A], eax

    ; Kerning = 0.0f
    mov     DWORD PTR [rsp+20h + KDT_KERNING], 0

    ; ShadowColor = {0,0,0,0}
    mov     DWORD PTR [rsp+20h + KDT_SHADOW_R], 0
    mov     DWORD PTR [rsp+20h + KDT_SHADOW_G], 0
    mov     DWORD PTR [rsp+20h + KDT_SHADOW_B], 0
    mov     DWORD PTR [rsp+20h + KDT_SHADOW_A], 0

    ; ShadowOffset = {posX+1.0f, posY+1.0f}
    movss   xmm0, DWORD PTR [rsp+20h + KDT_POS_X]
    mov     eax, F_1_0
    movd    xmm1, eax
    addss   xmm0, xmm1
    movss   DWORD PTR [rsp+20h + KDT_SOFF_X], xmm0
    movss   xmm0, DWORD PTR [rsp+20h + KDT_POS_Y]
    addss   xmm0, xmm1
    movss   DWORD PTR [rsp+20h + KDT_SOFF_Y], xmm0

    ; bCentreX, bCentreY=1, bOutlined
    movzx   eax, BYTE PTR [rsp+88h]
    mov     BYTE PTR [rsp+20h + KDT_CENTREX], al
    mov     BYTE PTR [rsp+20h + KDT_CENTREY], 1
    movzx   eax, BYTE PTR [rsp+89h]
    mov     BYTE PTR [rsp+20h + KDT_OUTLINED], al
    mov     BYTE PTR [rsp+20h + KDT_PAD], 0

    ; OutlineColor = {0, 0, 0, 0.30f}
    mov     DWORD PTR [rsp+20h + KDT_OUT_CLR_R], 0
    mov     DWORD PTR [rsp+20h + KDT_OUT_CLR_G], 0
    mov     DWORD PTR [rsp+20h + KDT_OUT_CLR_B], 0
    mov     eax, F_0_30
    mov     DWORD PTR [rsp+20h + KDT_OUT_CLR_A], eax

    ; ProcessEvent(canvas, K2_DrawText, &params)
    mov     rax, QWORD PTR [rsp+80h]
    test    rax, rax
    jz      @@cleanup
    mov     rcx, QWORD PTR [ZG_canvas]
    test    rcx, rcx
    jz      @@cleanup
    mov     rdx, rax
    lea     r8, [rsp+20h]
    call    QWORD PTR [ProcessEvent]

@@cleanup:
    ; Free FString buffer
    lea     rcx, [rsp+20h + KDT_STR_DATA]
    call    FString_Free

    add     rsp, 0A8h
    pop     rdi
    pop     rsi
    pop     rbp
    pop     rbx
    ret
ZeroGUI__DrawText ENDP


; ZeroGUI__CalcPos  (internal helper)
; Computes element position from GUI state.
; In:  EAX = padding.X bits (REAL4), ECX = padding.Y bits (REAL4)
; Out: XMM0 = posX (REAL4), XMM1 = posY (REAL4)
; Uses XMM2-XMM5 (all volatile).
; No frame allocation - leaf-like, no CALLs. RSP must be = 0 before CALL.
ZeroGUI__CalcPos PROC
    ; posX = menu_pos.X + padX + offset_x
    movss   xmm0, DWORD PTR [ZG_menu_pos_X]
    movd    xmm2, eax                   ; padX
    addss   xmm0, xmm2
    addss   xmm0, DWORD PTR [ZG_offset_x]

    ; posY = menu_pos.Y + padY + offset_y
    movss   xmm1, DWORD PTR [ZG_menu_pos_Y]
    movd    xmm3, ecx                   ; padY
    addss   xmm1, xmm3
    addss   xmm1, DWORD PTR [ZG_offset_y]

    ; if sameLine:
    movzx   eax, BYTE PTR [ZG_sameLine]
    test    al, al
    jz      @@no_sameline
    movss   xmm0, DWORD PTR [ZG_last_elem_X]
    addss   xmm0, DWORD PTR [ZG_last_size_X]
    addss   xmm0, xmm2                  ; + padX
    movss   xmm1, DWORD PTR [ZG_last_elem_Y]
@@no_sameline:

    ; if pushY:
    movzx   eax, BYTE PTR [ZG_pushY]
    test    al, al
    jz      @@no_pushY
    movss   xmm1, DWORD PTR [ZG_pushYvalue]
    mov     BYTE PTR [ZG_pushY], 0
    xor     eax, eax
    mov     DWORD PTR [ZG_pushYvalue], eax
    ; offset_y = posY - menu_pos.Y
    movss   xmm4, xmm1
    subss   xmm4, DWORD PTR [ZG_menu_pos_Y]
    movss   DWORD PTR [ZG_offset_y], xmm4
@@no_pushY:

    ret
ZeroGUI__CalcPos ENDP


; ZeroGUI_SetupCanvas
; In: RCX = UCanvas*
ZeroGUI_SetupCanvas PROC
    mov     QWORD PTR [ZG_canvas], rcx
    ret
ZeroGUI_SetupCanvas ENDP


; ZeroGUI_Begin  (= ZeroGUI::Window)
; In:  RCX = title (wchar_t*)
;      RDX = pos (FVector2D* = &{X:REAL4, Y:REAL4})
;      R8D = sizeX bits (REAL4)
;      R9D = sizeY bits (REAL4)
;      [rsp+20h] = isOpen (BYTE)
; Out: AL = bool (true -> render children)
;
; Frame: 4 pushes (RBX=title*, RBP=pos*, RSI=sizeX, RDI=sizeY)
;        + sub 48h (72) -> RSP = 8-32-72 = -96 = 0 
;   [rsp+0..+1F]    = shadow
;   [rsp+20h..+27h] = 5th/6th arg slots (for sub-calls: DrawFilledRect, DrawText)
;   [rsp+28h]       = isOpen (BYTE, saved)
;   [rsp+29..+2Bh]  = pad
;   [rsp+2Ch]       = isHovered (BYTE)
;   [rsp+2D..+2Fh]  = pad
;   [rsp+30h..+37h] = scratch (hWndFortnite save slot, cursor_pos FVector2D)
;   [rsp+38h..+47h] = spare
;   5th arg isOpen at entry_RSP+0x28 = current_RSP+0x90
;     (prologue=104 bytes; 104+0x28=0x90)
ZeroGUI_Begin PROC
    push    rbx
    push    rbp
    push    rsi
    push    rdi
    sub     rsp, 48h

    mov     rbx, rcx                    ; title*
    mov     rbp, rdx                    ; pos*
    mov     esi, r8d                    ; sizeX bits
    mov     edi, r9d                    ; sizeY bits

    ; Reset elements_count = 0
    mov     DWORD PTR [ZG_elem_count], 0

    ; Read isOpen from 5th arg - prologue=104 bytes; at entry_RSP+0x28 = current_RSP+0x90
    movzx   eax, BYTE PTR [rsp+90h]
    mov     BYTE PTR [rsp+28h], al

    ; Return false if !isOpen
    test    al, al
    jz      @@return_false

    ; FindWindow check (lazy-init HWND cache)
    mov     rax, QWORD PTR [ZG_hWndFortnite]
    test    rax, rax
    jnz     @@hwnd_ready
    lea     rcx, [szWC_UnrealWindow]
    lea     rdx, [szWC_Fortnite]
    call    FindWindowW
    mov     QWORD PTR [ZG_hWndFortnite], rax
@@hwnd_ready:

    ; GetActiveWindow() - must match Fortnite window
    mov     QWORD PTR [rsp+30h], rax    ; save hWndFortnite in local slot (no push tho)
    call    GetActiveWindow
    mov     rcx, QWORD PTR [rsp+30h]    ; restore hWndFortnite
    cmp     rax, rcx
    jne     @@return_false              ; wrong window focused

    ; Drop current drag element if mouse released
    mov     eax, DWORD PTR [ZG_curr_elem]
    cmp     eax, -1
    je      @@skip_drop
    mov     ecx, 1
    call    GetAsyncKeyState
    test    ax, ax
    jnz     @@skip_drop
    mov     DWORD PTR [ZG_curr_elem], -1
@@skip_drop:

    ; isHovered = MouseInZone(pos, size)
    mov     ecx, DWORD PTR [rbp+0]      ; pos->X bits
    mov     edx, DWORD PTR [rbp+4]      ; pos->Y bits
    mov     r8d, esi                    ; sizeX bits
    mov     r9d, edi                    ; sizeY bits
    call    ZeroGUI__MouseInZone
    mov     BYTE PTR [rsp+2Ch], al      ; isHovered

    ; Drag logic
    movzx   eax, BYTE PTR [ZG_hover_element]
    test    al, al
    jz      @@drag_no_hover

    ; hover_element is set: check if mouse pressed
    mov     ecx, 1
    call    GetAsyncKeyState
    test    ax, ax
    jnz     @@drag_done                 ; hover element handles drag, skip
    mov     BYTE PTR [ZG_hover_element], 0
    jmp     @@drag_done

@@drag_no_hover:
    ; !hover_element: check if isHovered or dragPos.X != 0
    movzx   eax, BYTE PTR [rsp+2Ch]    ; isHovered
    test    al, al
    jnz     @@check_drag
    movss   xmm0, DWORD PTR [ZG_dragPos_X]
    xorps   xmm1, xmm1
    comiss  xmm0, xmm1
    je      @@drag_done                 ; dragPos.X == 0 and !isHovered: skip drag

@@check_drag:
    ; IsMouseClicked(button=0, element_id=0, repeat=true)
    xor     ecx, ecx                    ; button = 0
    xor     edx, edx                    ; element_id = 0
    mov     r8b, 1                      ; repeat = true
    call    ZeroInput_IsMouseClicked
    test    al, al
    jz      @@drag_release              ; not clicked: clear dragPos

    ; GetCursorPos -> [rsp+38h] (FVector2D scratch)
    lea     rcx, [rsp+38h]
    call    ZeroGUI__CursorPos

    movss   xmm0, DWORD PTR [rsp+38h]  ; curX
    movss   xmm1, DWORD PTR [rsp+3Ch]  ; curY

    ; if dragPos.X == 0: init dragPos
    movss   xmm4, DWORD PTR [ZG_dragPos_X]
    xorps   xmm5, xmm5
    comiss  xmm4, xmm5
    jne     @@drag_update               ; already initialized

    ; dragPos.X = cursorX - pos->X; dragPos.Y = cursorY - pos->Y
    movss   xmm5, xmm0
    subss   xmm5, DWORD PTR [rbp+0]    ; cursorX - pos->X
    movss   DWORD PTR [ZG_dragPos_X], xmm5
    movss   xmm5, xmm1
    subss   xmm5, DWORD PTR [rbp+4]    ; cursorY - pos->Y
    movss   DWORD PTR [ZG_dragPos_Y], xmm5

@@drag_update:
    ; pos->X = cursorX - dragPos.X; pos->Y = cursorY - dragPos.Y
    movss   xmm4, xmm0
    subss   xmm4, DWORD PTR [ZG_dragPos_X]
    movss   DWORD PTR [rbp+0], xmm4
    movss   xmm4, xmm1
    subss   xmm4, DWORD PTR [ZG_dragPos_Y]
    movss   DWORD PTR [rbp+4], xmm4
    jmp     @@drag_done

@@drag_release:
    ; Mouse not held: clear dragPos
    xor     eax, eax
    mov     DWORD PTR [ZG_dragPos_X], eax
    mov     DWORD PTR [ZG_dragPos_Y], eax

@@drag_done:

    ; Reset state
    xor     eax, eax
    mov     DWORD PTR [ZG_offset_x], eax
    mov     DWORD PTR [ZG_offset_y], eax
    ; menu_pos = *pos
    mov     eax, DWORD PTR [rbp+0]
    mov     DWORD PTR [ZG_menu_pos_X], eax
    mov     eax, DWORD PTR [rbp+4]
    mov     DWORD PTR [ZG_menu_pos_Y], eax
    ; first_element_pos = {0,0}
    xor     eax, eax
    mov     DWORD PTR [ZG_first_elem_X], eax
    mov     DWORD PTR [ZG_first_elem_Y], eax

    ; Draw background
    mov     ecx, DWORD PTR [rbp+0]     ; posX bits
    mov     edx, DWORD PTR [rbp+4]     ; posY bits
    mov     r8d, esi                    ; sizeX bits
    mov     r9d, edi                    ; sizeY bits
    lea     rax, [clr_Win_Bg]
    mov     QWORD PTR [rsp+20h], rax   ; 5th arg = color*
    call    ZeroGUI__DrawFilledRect

    ; Draw header
    mov     ecx, DWORD PTR [rbp+0]
    mov     edx, DWORD PTR [rbp+4]
    mov     r8d, esi
    mov     r9d, 041C80000h             ; h = 25.0f
    lea     rax, [clr_Win_Hdr]
    mov     QWORD PTR [rsp+20h], rax
    call    ZeroGUI__DrawFilledRect

    ; offset_y += 25.0f
    movss   xmm0, DWORD PTR [ZG_offset_y]
    movd    xmm1, DWORD PTR [f_25_0]
    addss   xmm0, xmm1
    movss   DWORD PTR [ZG_offset_y], xmm0

    ; Draw title (TextCenter)
    ; titlePos = { pos->X + sizeX/2, pos->Y + 12.5f }
    movss   xmm0, DWORD PTR [rbp+0]    ; pos->X
    movd    xmm1, esi                   ; sizeX bits -> float
    movss   xmm2, DWORD PTR [f_0_5]
    mulss   xmm1, xmm2                 ; sizeX * 0.5
    addss   xmm0, xmm1                 ; pos->X + sizeX/2
    movd    edx, xmm0                  ; posX bits -> EDX

    movss   xmm0, DWORD PTR [rbp+4]    ; pos->Y
    mov     eax, F_12_5
    movd    xmm1, eax
    addss   xmm0, xmm1                 ; pos->Y + 12.5f
    movd    r8d, xmm0                  ; posY bits -> R8D

    mov     rcx, rbx                    ; title*
    lea     r9, [clr_White]            ; color*
    mov     BYTE PTR [rsp+20h], 1      ; bCentreX = true
    mov     BYTE PTR [rsp+28h], 0      ; bOutlined = false
    call    ZeroGUI__DrawText

    ; Return true
    mov     al, 1
    jmp     @@done

@@return_false:
    xor     al, al
@@done:
    add     rsp, 48h
    pop     rdi
    pop     rsi
    pop     rbp
    pop     rbx
    ret
ZeroGUI_Begin ENDP


; ZeroGUI_Button
; In:  RCX = name (wchar_t*)
;      EDX = sizeX bits (REAL4)
;      R8D = sizeY bits (REAL4)
; Out: AL = bool (true if clicked)
;
; Frame: 4 pushes (RBX=name*, RBP=sizeX, RSI=sizeY, RDI=spare)
;        + sub 48h (72) -> RSP = 8-32-72 = -96 = 0 
;   [rsp+0..+1F]    = shadow
;   [rsp+20h..+27h] = 5th/6th arg slots for sub-calls
;   [rsp+28h..+2Fh] = spare
;   [rsp+30h..+33h] = posX bits
;   [rsp+34h..+37h] = posY bits
;   [rsp+38h]       = isHovered (BYTE)
;   [rsp+39..+47h]  = spare
ZeroGUI_Button PROC
    push    rbx
    push    rbp
    push    rsi
    push    rdi
    sub     rsp, 48h

    mov     rbx, rcx                    ; name*
    mov     ebp, edx                    ; sizeX bits
    mov     esi, r8d                    ; sizeY bits

    ; elements_count++
    inc     DWORD PTR [ZG_elem_count]

    ; Compute pos = { menu_pos.X+5+offset_x, menu_pos.Y+10+offset_y }
    mov     eax, F_5_0
    mov     ecx, F_10_0
    call    ZeroGUI__CalcPos            ; XMM0=posX, XMM1=posY
    movd    DWORD PTR [rsp+30h], xmm0   ; save posX - safe above arg slots
    movd    DWORD PTR [rsp+34h], xmm1   ; save posY

    ; isHovered = MouseInZone(posX, posY, sizeX, sizeY)
    movd    ecx, xmm0
    movd    edx, xmm1
    mov     r8d, ebp
    mov     r9d, esi
    call    ZeroGUI__MouseInZone
    mov     BYTE PTR [rsp+38h], al

    ; Draw background - reload ecx/edx from saved slots (MouseInZone clobbered xmm0/1)
    mov     ecx, DWORD PTR [rsp+30h]
    mov     edx, DWORD PTR [rsp+34h]
    mov     r8d, ebp
    mov     r9d, esi

    test    BYTE PTR [rsp+38h], 1       ; isHovered?
    jz      @@draw_idle
    lea     rax, [clr_Btn_Hover]
    mov     QWORD PTR [rsp+20h], rax    ; 5th arg - correct slot
    call    ZeroGUI__DrawFilledRect
    mov     BYTE PTR [ZG_hover_element], 1
    jmp     ZGB_draw_text
@@draw_idle:
    lea     rax, [clr_Btn_Idle]
    mov     QWORD PTR [rsp+20h], rax    ; 5th arg - correct slot
    call    ZeroGUI__DrawFilledRect

ZGB_draw_text:
    ; if !sameLine: offset_y += sizeY + 10
    movzx   eax, BYTE PTR [ZG_sameLine]
    test    al, al
    jnz     @@skip_adv_y
    movss   xmm0, DWORD PTR [ZG_offset_y]
    movd    xmm1, esi                   ; sizeY
    mov     eax, F_10_0
    movd    xmm2, eax
    addss   xmm0, xmm1
    addss   xmm0, xmm2
    movss   DWORD PTR [ZG_offset_y], xmm0
@@skip_adv_y:

    ; TextCenter(name, {posX+sizeX/2, posY+sizeY/2}, white, center=true, outline=false)
    movss   xmm0, DWORD PTR [rsp+30h]  ; posX
    movd    xmm1, ebp                   ; sizeX
    movss   xmm2, DWORD PTR [f_0_5]
    mulss   xmm1, xmm2
    addss   xmm0, xmm1
    movd    edx, xmm0                  ; textX

    movss   xmm0, DWORD PTR [rsp+34h]  ; posY
    movd    xmm1, esi                   ; sizeY
    mulss   xmm1, xmm2                 ; xmm2 still = 0.5
    addss   xmm0, xmm1
    movd    r8d, xmm0                  ; textY

    mov     rcx, rbx
    lea     r9, [clr_White]
    mov     BYTE PTR [rsp+20h], 1      ; bCentreX = true  (5th arg)
    mov     BYTE PTR [rsp+28h], 0      ; bOutlined = false (6th arg)
    call    ZeroGUI__DrawText

    ; Update state
    mov     BYTE PTR [ZG_sameLine], 0
    mov     eax, DWORD PTR [rsp+30h]
    mov     DWORD PTR [ZG_last_elem_X], eax
    mov     eax, DWORD PTR [rsp+34h]
    mov     DWORD PTR [ZG_last_elem_Y], eax
    mov     DWORD PTR [ZG_last_size_X], ebp
    mov     DWORD PTR [ZG_last_size_Y], esi

    ; Set first_element_pos if not yet set (first_elem_X == 0.0f)
    movss   xmm0, DWORD PTR [ZG_first_elem_X]
    xorps   xmm1, xmm1
    comiss  xmm0, xmm1
    jne     @@first_done
    mov     eax, DWORD PTR [rsp+30h]
    mov     DWORD PTR [ZG_first_elem_X], eax
    mov     eax, DWORD PTR [rsp+34h]
    mov     DWORD PTR [ZG_first_elem_Y], eax
@@first_done:

    ; Return: isHovered && IsMouseClicked(0, elements_count, false)
    movzx   eax, BYTE PTR [rsp+38h]
    test    al, al
    jz      @@ret_false

    xor     ecx, ecx
    mov     edx, DWORD PTR [ZG_elem_count]
    xor     r8b, r8b
    call    ZeroInput_IsMouseClicked
    jmp     @@done

@@ret_false:
    xor     al, al
@@done:
    add     rsp, 48h
    pop     rdi
    pop     rsi
    pop     rbp
    pop     rbx
    ret
ZeroGUI_Button ENDP


; ZeroGUI_ButtonTab
; In:  RCX = name (wchar_t*)
;      EDX = sizeX bits (REAL4)
;      R8D = sizeY bits (REAL4)
;      R9B = active (bool)
; Out: AL = bool (true if clicked)
;
; Like Button but uses clr_Btn_Active when active=true.
; Frame: 4 pushes + sub 48h -> RSP = 0   (same layout as Button)
ZeroGUI_ButtonTab PROC
    push    rbx
    push    rbp
    push    rsi
    push    rdi
    sub     rsp, 48h

    mov     rbx, rcx
    mov     ebp, edx
    mov     esi, r8d
    movzx   edi, r9b                    ; active bool

    inc     DWORD PTR [ZG_elem_count]

    mov     eax, F_5_0
    mov     ecx, F_10_0
    call    ZeroGUI__CalcPos
    movd    DWORD PTR [rsp+30h], xmm0
    movd    DWORD PTR [rsp+34h], xmm1

    movd    ecx, xmm0
    movd    edx, xmm1
    mov     r8d, ebp
    mov     r9d, esi
    call    ZeroGUI__MouseInZone
    mov     BYTE PTR [rsp+38h], al

    ; Choose color: active -> Active, hovered -> Hovered, else -> Idle
    mov     ecx, DWORD PTR [rsp+30h]
    mov     edx, DWORD PTR [rsp+34h]
    mov     r8d, ebp
    mov     r9d, esi

    test    edi, edi
    jz      @@tab_not_active
    lea     rax, [clr_Btn_Active]
    mov     QWORD PTR [rsp+20h], rax    ; 5th arg
    call    ZeroGUI__DrawFilledRect
    jmp     @@tab_text
@@tab_not_active:
    test    BYTE PTR [rsp+38h], 1
    jz      ZGBTab_idle
    lea     rax, [clr_Btn_Hover]
    mov     QWORD PTR [rsp+20h], rax    ; 5th arg
    call    ZeroGUI__DrawFilledRect
    mov     BYTE PTR [ZG_hover_element], 1
    jmp     @@tab_text
ZGBTab_idle:
    lea     rax, [clr_Btn_Idle]
    mov     QWORD PTR [rsp+20h], rax    ; 5th arg
    call    ZeroGUI__DrawFilledRect

@@tab_text:
    movzx   eax, BYTE PTR [ZG_sameLine]
    test    al, al
    jnz     @@tab_skip_adv
    movss   xmm0, DWORD PTR [ZG_offset_y]
    movd    xmm1, esi
    mov     eax, F_10_0
    movd    xmm2, eax
    addss   xmm0, xmm1
    addss   xmm0, xmm2
    movss   DWORD PTR [ZG_offset_y], xmm0
@@tab_skip_adv:

    movss   xmm0, DWORD PTR [rsp+30h]
    movd    xmm1, ebp
    movss   xmm2, DWORD PTR [f_0_5]
    mulss   xmm1, xmm2
    addss   xmm0, xmm1
    movd    edx, xmm0

    movss   xmm0, DWORD PTR [rsp+34h]
    movd    xmm1, esi
    mulss   xmm1, xmm2
    addss   xmm0, xmm1
    movd    r8d, xmm0

    mov     rcx, rbx
    lea     r9, [clr_White]
    mov     BYTE PTR [rsp+20h], 1      ; bCentreX = true  (5th arg)
    mov     BYTE PTR [rsp+28h], 0      ; bOutlined = false (6th arg)
    call    ZeroGUI__DrawText

    mov     BYTE PTR [ZG_sameLine], 0
    mov     eax, DWORD PTR [rsp+30h]
    mov     DWORD PTR [ZG_last_elem_X], eax
    mov     eax, DWORD PTR [rsp+34h]
    mov     DWORD PTR [ZG_last_elem_Y], eax
    mov     DWORD PTR [ZG_last_size_X], ebp
    mov     DWORD PTR [ZG_last_size_Y], esi

    movss   xmm0, DWORD PTR [ZG_first_elem_X]
    xorps   xmm1, xmm1
    comiss  xmm0, xmm1
    jne     @@tab_first_done
    mov     eax, DWORD PTR [rsp+30h]
    mov     DWORD PTR [ZG_first_elem_X], eax
    mov     eax, DWORD PTR [rsp+34h]
    mov     DWORD PTR [ZG_first_elem_Y], eax
@@tab_first_done:

    movzx   eax, BYTE PTR [rsp+38h]
    test    al, al
    jz      @@tab_ret_false
    xor     ecx, ecx
    mov     edx, DWORD PTR [ZG_elem_count]
    xor     r8b, r8b
    call    ZeroInput_IsMouseClicked
    jmp     @@tab_done

@@tab_ret_false:
    xor     al, al
@@tab_done:
    add     rsp, 48h
    pop     rdi
    pop     rsi
    pop     rbp
    pop     rbx
    ret
ZeroGUI_ButtonTab ENDP


; ZeroGUI_Text
; In:  RCX = text (wchar_t*)
;      DL  = center (bool)
;      R8B = outline (bool)
; Out: none
;
; Frame: 4 pushes (RBX=text, RBP=center, RSI=outline, RDI=spare)
;        + sub 48h -> RSP = 0   (same layout as Button)
; size implicit=25px, padding={10,10}
ZeroGUI_Text PROC
    push    rbx
    push    rbp
    push    rsi
    push    rdi
    sub     rsp, 48h

    mov     rbx, rcx
    movzx   ebp, dl
    movzx   esi, r8b

    inc     DWORD PTR [ZG_elem_count]

    mov     eax, F_10_0
    mov     ecx, F_10_0
    call    ZeroGUI__CalcPos
    movd    DWORD PTR [rsp+30h], xmm0   ; posX
    movd    DWORD PTR [rsp+34h], xmm1   ; posY

    ; if !sameLine: offset_y += 25 + 10 = 35
    movzx   eax, BYTE PTR [ZG_sameLine]
    test    al, al
    jnz     @@text_skip_adv
    movss   xmm0, DWORD PTR [ZG_offset_y]
    mov     eax, 041C80000h             ; 25.0f
    movd    xmm1, eax
    mov     eax, F_10_0
    movd    xmm2, eax
    addss   xmm0, xmm1
    addss   xmm0, xmm2
    movss   DWORD PTR [ZG_offset_y], xmm0
@@text_skip_adv:

    ; textPos = { posX + 5, posY + 12.5 }
    movss   xmm0, DWORD PTR [rsp+30h]
    mov     eax, F_5_0
    movd    xmm1, eax
    addss   xmm0, xmm1
    movd    edx, xmm0

    movss   xmm0, DWORD PTR [rsp+34h]
    mov     eax, F_12_5
    movd    xmm1, eax
    addss   xmm0, xmm1
    movd    r8d, xmm0

    mov     rcx, rbx
    lea     r9, [clr_White]
    mov     BYTE PTR [rsp+20h], bpl     ; bCentreX = center  (5th arg)
    mov     BYTE PTR [rsp+28h], sil     ; bOutlined          (6th arg)
    call    ZeroGUI__DrawText

    mov     BYTE PTR [ZG_sameLine], 0
    mov     eax, DWORD PTR [rsp+30h]
    mov     DWORD PTR [ZG_last_elem_X], eax
    mov     eax, DWORD PTR [rsp+34h]
    mov     DWORD PTR [ZG_last_elem_Y], eax

    movss   xmm0, DWORD PTR [ZG_first_elem_X]
    xorps   xmm1, xmm1
    comiss  xmm0, xmm1
    jne     @@text_first_done
    mov     eax, DWORD PTR [rsp+30h]
    mov     DWORD PTR [ZG_first_elem_X], eax
    mov     eax, DWORD PTR [rsp+34h]
    mov     DWORD PTR [ZG_first_elem_Y], eax
@@text_first_done:

    add     rsp, 48h
    pop     rdi
    pop     rsi
    pop     rbp
    pop     rbx
    ret
ZeroGUI_Text ENDP


; ZeroGUI_NextColumn
; In: XMM0 = x (REAL4 float)
; Out: none
;
; Sets offset_x = x
; Sets pushY = true, pushYvalue = first_elem_Y
;
; Frame: 0 pushes + sub 28h -> RSP = 8-40 = -32 = 0 
ZeroGUI_NextColumn PROC
    sub     rsp, 28h

    movss   DWORD PTR [ZG_offset_x], xmm0

    mov     BYTE PTR [ZG_pushY], 1
    mov     eax, DWORD PTR [ZG_first_elem_Y]
    mov     DWORD PTR [ZG_pushYvalue], eax

    add     rsp, 28h
    ret
ZeroGUI_NextColumn ENDP


; ZeroGUI_End  (= ZeroGUI::Render)
; Flushes the PostRenderer drawlist.
; Each non-empty slot is dispatched to direct draw, then reset.
;
; Frame: 2 pushes (RBX=loop_idx*72, RSI=drawlist_base) + sub 58h (88)
;   2 pushes (16) + 88 = 104; RSP = 8-104 = -96 = 0 
;   [rsp+0..+1F]    = shadow
;   [rsp+20h..+43h] = K2_DrawLine params (0x24 bytes) - safe above shadow
;   [rsp+44h..+57h] = spare
ZeroGUI_End PROC
    push    rbx
    push    rsi
    sub     rsp, 58h

    lea     rsi, [ZG_drawlist]          ; base of drawlist
    xor     rbx, rbx                    ; entry byte offset = 0

@@render_loop:
    cmp     rbx, (DRAWLIST_COUNT * DL_SIZE)
    jae     @@render_done

    ; Check if entry type != -1
    mov     eax, DWORD PTR [rsi + rbx + DL_type]
    cmp     eax, -1
    je      @@next_entry

    ; Dispatch by type
    cmp     eax, 1
    je      @@type_rect
    cmp     eax, 2
    je      @@type_text_left
    cmp     eax, 3
    je      @@type_text_center
    cmp     eax, 4
    je      @@type_line
    jmp     @@reset_entry              ; unknown type: reset

@@type_rect:
    ; drawFilledRect(pos.X, pos.Y, size.X, size.Y, &color)
    mov     ecx, DWORD PTR [rsi + rbx + DL_pos_X]
    mov     edx, DWORD PTR [rsi + rbx + DL_pos_Y]
    mov     r8d, DWORD PTR [rsi + rbx + DL_size_X]
    mov     r9d, DWORD PTR [rsi + rbx + DL_size_Y]
    lea     rax, [rsi + rbx + DL_color_R]
    mov     QWORD PTR [rsp+20h], rax    ; 5th arg - correct slot
    call    ZeroGUI__DrawFilledRect
    jmp     @@reset_entry

@@type_text_left:
    mov     rcx, QWORD PTR [rsi + rbx + DL_name]
    mov     edx, DWORD PTR [rsi + rbx + DL_pos_X]
    mov     r8d, DWORD PTR [rsi + rbx + DL_pos_Y]
    lea     r9, [rsi + rbx + DL_color_R]
    mov     al, BYTE PTR [rsi + rbx + DL_outline]
    mov     BYTE PTR [rsp+20h], 0       ; bCentreX = false (5th arg)
    mov     BYTE PTR [rsp+28h], al      ; bOutlined        (6th arg)
    call    ZeroGUI__DrawText
    jmp     @@reset_entry

@@type_text_center:
    mov     rcx, QWORD PTR [rsi + rbx + DL_name]
    mov     edx, DWORD PTR [rsi + rbx + DL_pos_X]
    mov     r8d, DWORD PTR [rsi + rbx + DL_pos_Y]
    lea     r9, [rsi + rbx + DL_color_R]
    mov     al, BYTE PTR [rsi + rbx + DL_outline]
    mov     BYTE PTR [rsp+20h], 1       ; bCentreX = true  (5th arg)
    mov     BYTE PTR [rsp+28h], al      ;                  (6th arg)
    call    ZeroGUI__DrawText
    jmp     @@reset_entry

@@type_line:
    ; Build K2_DrawLine params at [rsp+20h..+43h] - above shadow, safe across CALL
    mov     eax, DWORD PTR [rsi + rbx + DL_from_X]
    mov     DWORD PTR [rsp+20h], eax    ; params.A.X
    mov     eax, DWORD PTR [rsi + rbx + DL_from_Y]
    mov     DWORD PTR [rsp+24h], eax    ; params.A.Y
    mov     eax, DWORD PTR [rsi + rbx + DL_to_X]
    mov     DWORD PTR [rsp+28h], eax    ; params.B.X
    mov     eax, DWORD PTR [rsi + rbx + DL_to_Y]
    mov     DWORD PTR [rsp+2Ch], eax    ; params.B.Y
    cvtsi2ss xmm0, DWORD PTR [rsi + rbx + DL_thickness]
    movss   DWORD PTR [rsp+30h], xmm0  ; params.Thickness
    mov     eax, DWORD PTR [rsi + rbx + DL_color_R]
    mov     DWORD PTR [rsp+34h], eax    ; params.Color.R
    mov     eax, DWORD PTR [rsi + rbx + DL_color_G]
    mov     DWORD PTR [rsp+38h], eax    ; params.Color.G
    mov     eax, DWORD PTR [rsi + rbx + DL_color_B]
    mov     DWORD PTR [rsp+3Ch], eax    ; params.Color.B
    mov     eax, DWORD PTR [rsi + rbx + DL_color_A]
    mov     DWORD PTR [rsp+40h], eax    ; params.Color.A
    ; ProcessEvent(canvas, K2_DrawLine, &params)
    mov     rcx, QWORD PTR [ZG_canvas]
    test    rcx, rcx
    jz      @@reset_entry
    mov     rdx, QWORD PTR [ZG_pFn_K2DrawLine]
    test    rdx, rdx
    jz      @@reset_entry
    lea     r8, [rsp+20h]               ; pointer to params - above shadow
    call    QWORD PTR [ProcessEvent]
    jmp     @@reset_entry

@@reset_entry:
    mov     DWORD PTR [rsi + rbx + DL_type], -1

@@next_entry:
    add     rbx, DL_SIZE
    jmp     @@render_loop

@@render_done:
    add     rsp, 58h
    pop     rsi
    pop     rbx
    ret
ZeroGUI_End ENDP

END