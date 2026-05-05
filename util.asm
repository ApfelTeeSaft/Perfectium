INCLUDE include\master.inc

EXTRN   GetModuleHandleA    :PROC
EXTRN   sinf                :PROC
EXTRN   cosf                :PROC
EXTRN   atan2f              :PROC
EXTRN   rand                :PROC
EXTRN   strtoul             :PROC

.const

; DIVIDE_BY_2 = PI / 360.0f  (used for Rotator.component * PI/360 in RotToQuat)
fDivBy2     REAL4   0.00872664625r       ; PI / (180 * 2)
fRadToDeg   REAL4   57.2957795r          ; 180 / PI
fRandMax    REAL4   32767.0r             ; RAND_MAX (MSVC)

.code

; Utils_FindPattern(RCX=pszPattern, EDX=bRelative, R8D=offset) -> RAX
;
; Frame: 7 callee-save pushes (rbp rbx rsi rdi r12 r13 r14) + sub 576 bytes.
;   After 7 pushes, RSP = 0 mod 16.  576 mod 16 = 0 -> RSP = 0 at every CALL.
;
; Frame layout (offsets from RSP after sub):
;   [rsp+  0 ..  31] shadow space for callees
;   [rsp+ 32 .. 543] pat_ints[128]  (512 bytes, int32 per element)
;   [rsp+544]        pat_len  DWORD
;   [rsp+548]        bRelative saved DWORD
;   [rsp+552]        offset_val saved DWORD
;   [rsp+556]        SizeOfImage saved DWORD
;   [rsp+560..567]   endptr QWORD  (for strtoul)
;   [rsp+568..575]   pad
Utils_FindPattern PROC
    push    rbp
    push    rbx
    push    rsi
    push    rdi
    push    r12
    push    r13
    push    r14
    sub     rsp, 576

    mov     r12, rcx                        ; r12 = pszPattern (parse cursor)
    mov     DWORD PTR [rsp + 548], edx      ; bRelative
    mov     DWORD PTR [rsp + 552], r8d      ; offset

    xor     ecx, ecx
    call    GetModuleHandleA                ; RAX = module base
    mov     r13, rax                        ; r13 = base address

    ; IMAGE_DOS_HEADER.e_lfanew is a DWORD at [base + 0x3C]
    movsx   rbx, DWORD PTR [r13 + 3Ch]     ; rbx = e_lfanew
    add     rbx, r13                        ; rbx = IMAGE_NT_HEADERS64*
    ; IMAGE_NT_HEADERS64: Signature(4) + FileHeader(20) = 0x18 to OptionalHeader
    ; IMAGE_OPTIONAL_HEADER64.SizeOfImage: DWORD at OptionalHeader+0x38 -> NtHdrs+0x50
    mov     edi, DWORD PTR [rbx + 50h]     ; edi = SizeOfImage
    mov     DWORD PTR [rsp + 556], edi      ; save SizeOfImage

    ; r12 = current char pointer into pszPattern
    ; rsi = write index (0-based, < 128)
    xor     esi, esi                        ; rsi = pattern element count

@@parse_top:
    movzx   eax, BYTE PTR [r12]
    test    al, al
    jz      @@parse_done                    ; end of string

    cmp     al, ' '                         ; skip spaces
    jne     @@parse_not_space
    inc     r12
    jmp     @@parse_top

@@parse_not_space:
    cmp     al, '?'                         ; wildcard?
    jne     @@parse_hex

    ; Wildcard: store -1
    mov     DWORD PTR [rsp + 32 + rsi*4], -1
    inc     esi
    inc     r12                             ; skip first '?'
    cmp     BYTE PTR [r12], '?'
    jne     @@parse_top
    inc     r12                             ; skip optional second '?'
    jmp     @@parse_top

@@parse_hex:
    ; Parse two hex digits via strtoul(r12, &endptr, 16)
    ; strtoul will consume "AB" and set *endptr to the char after
    mov     rcx, r12                        ; arg1: string ptr
    lea     rdx, [rsp + 560]                ; arg2: &endptr
    mov     r8d, 16                         ; arg3: base
    call    strtoul                         ; EAX = byte value
    movsx   r14, eax                        ; zero-extend byte to 64-bit (safe: 0..255)
    mov     DWORD PTR [rsp + 32 + rsi*4], r14d  ; pat_ints[rsi] = byte value
    inc     esi
    mov     r12, QWORD PTR [rsp + 560]      ; r12 = endptr (now points at space/end)
    jmp     @@parse_top

@@parse_done:
    mov     DWORD PTR [rsp + 544], esi      ; pat_len = esi

    ; Guard: if pat_len == 0, no scan
    test    esi, esi
    jz      @@not_found

    ; Outer loop: i from 0 to SizeOfImage - pat_len (inclusive)
    mov     r14d, DWORD PTR [rsp + 556]     ; r14d = SizeOfImage
    sub     r14d, esi                        ; r14d = SizeOfImage - pat_len
    js      @@not_found                      ; underflow -> image too small

    ; r12d = pat_len (repurpose r12 — pszPattern no longer needed)
    mov     r12d, esi                        ; r12d = pat_len
    xor     esi, esi                         ; esi = i (outer counter)
    ; rbx = &pat_ints[0] = rsp + 32
    lea     rbx, [rsp + 32]

@@outer_loop:
    cmp     esi, r14d                        ; i > SizeOfImage - pat_len?
    jg      @@not_found

    ; Inner loop: j from 0 to pat_len-1
    xor     r9d, r9d                         ; r9d = j

@@inner_loop:
    cmp     r9d, r12d                        ; j >= pat_len?
    jge     @@found                          ; all bytes matched

    ; Load pat_ints[j] (int32: -1 or byte 0..255)
    movsx   rdi, r9d
    mov     eax, DWORD PTR [rbx + rdi*4]    ; eax = pat_ints[j]
    cmp     eax, -1
    je      @@wildcard                       ; skip wildcard byte

    ; Compare scan byte: base[i+j] vs pat_ints[j]
    movsx   rdi, esi                         ; rdi = i
    add     rdi, r9                          ; rdi = i + j
    movzx   edx, BYTE PTR [r13 + rdi]       ; edx = scan byte
    cmp     edx, eax
    jne     @@mismatch

@@wildcard:
    inc     r9d
    jmp     @@inner_loop

@@mismatch:
    inc     esi
    jmp     @@outer_loop

@@found:
    ; Compute match address = base + i
    movsx   rax, esi
    add     rax, r13

    cmp     DWORD PTR [rsp + 548], 0
    je      @@done

    ; address = address + offset + 4 + *(int32*)(address + offset)
    movsx   rcx, DWORD PTR [rsp + 552]      ; rcx = offset
    movsx   rdx, DWORD PTR [rax + rcx]      ; rdx = *(int32*)(address + offset)
    lea     rax, [rax + rcx + 4]            ; rax = address + offset + 4
    add     rax, rdx                         ; rax += displacement
    jmp     @@done

@@not_found:
    xor     eax, eax                         ; return NULL

@@done:
    add     rsp, 576
    pop     r14
    pop     r13
    pop     r12
    pop     rdi
    pop     rsi
    pop     rbx
    pop     rbp
    ret
Utils_FindPattern ENDP

; Utils_sinCos(RCX=float* ScalarSin, RDX=float* ScalarCos, XMM2=float Value)
; Computes sin and cos of Value via CRT sinf/cosf.
; Stores results at *ScalarSin and *ScalarCos.
; Frame: push rbp rbx rsi + sub 48
; 3 pushes -> RSP = 0 mod 16.  sub 48 (48=0) -> 0
; Local [rsp+32]: saved Value REAL4 (XMM2 is volatile across calls)
Utils_sinCos PROC
    push    rbp
    push    rbx
    push    rsi
    sub     rsp, 48

    mov     rbx, rcx                        ; rbx = ScalarSin ptr
    mov     rsi, rdx                        ; rsi = ScalarCos ptr
    movss   DWORD PTR [rsp + 32], xmm2     ; save Value (XMM2 volatile across calls)

    ; sin(Value)
    movss   xmm0, DWORD PTR [rsp + 32]
    call    sinf                            ; XMM0 = sin(Value)
    movss   DWORD PTR [rbx], xmm0          ; *ScalarSin = sin

    ; cos(Value)
    movss   xmm0, DWORD PTR [rsp + 32]
    call    cosf                            ; XMM0 = cos(Value)
    movss   DWORD PTR [rsi], xmm0          ; *ScalarCos = cos

    add     rsp, 48
    pop     rsi
    pop     rbx
    pop     rbp
    ret
Utils_sinCos ENDP

; Utils_RotToQuat(RCX=FRotator* rot, RDX=FQuat* out_quat)
; Converts Pitch/Yaw/Roll (degrees) to quaternion X/Y/Z/W.
; FRotator layout: Pitch[+0] Yaw[+4] Roll[+8]   (all REAL4)
; FQuat    layout: X[+0]    Y[+4]   Z[+8]  W[+12] (all REAL4)
; Frame: push rbp rbx rsi + sub 64
; 3 pushes (RSP=0). sub 64 (64=0) -> 0
; Locals:
;     [rsp+32] SP  [rsp+36] CP  [rsp+40] SY
;     [rsp+44] CY  [rsp+48] SR  [rsp+52] CR
Utils_RotToQuat PROC
    push    rbp
    push    rbx
    push    rsi
    sub     rsp, 64

    mov     rbx, rcx                        ; rbx = FRotator*
    mov     rsi, rdx                        ; rsi = FQuat*

    ; sinCos(&SP, &CP, Pitch * DIVIDE_BY_2)
    lea     rcx, [rsp + 32]
    lea     rdx, [rsp + 36]
    movss   xmm2, DWORD PTR [rbx]
    mulss   xmm2, DWORD PTR [fDivBy2]
    call    Utils_sinCos

    ; sinCos(&SY, &CY, Yaw * DIVIDE_BY_2)
    lea     rcx, [rsp + 40]
    lea     rdx, [rsp + 44]
    movss   xmm2, DWORD PTR [rbx + 4]
    mulss   xmm2, DWORD PTR [fDivBy2]
    call    Utils_sinCos

    ; sinCos(&SR, &CR, Roll * DIVIDE_BY_2)
    lea     rcx, [rsp + 48]
    lea     rdx, [rsp + 52]
    movss   xmm2, DWORD PTR [rbx + 8]
    mulss   xmm2, DWORD PTR [fDivBy2]
    call    Utils_sinCos

    ; Reload locals: SP=rsp+32 CP=rsp+36 SY=rsp+40 CY=rsp+44 SR=rsp+48 CR=rsp+52

    ; X = CR*SP*SY - SR*CP*CY
    movss   xmm0, DWORD PTR [rsp + 52]     ; CR
    mulss   xmm0, DWORD PTR [rsp + 32]     ; * SP
    mulss   xmm0, DWORD PTR [rsp + 40]     ; * SY
    movss   xmm1, DWORD PTR [rsp + 48]     ; SR
    mulss   xmm1, DWORD PTR [rsp + 36]     ; * CP
    mulss   xmm1, DWORD PTR [rsp + 44]     ; * CY
    subss   xmm0, xmm1
    movss   DWORD PTR [rsi],      xmm0     ; out->X

    ; Y = -(CR*SP*CY + SR*CP*SY)
    movss   xmm0, DWORD PTR [rsp + 52]     ; CR
    mulss   xmm0, DWORD PTR [rsp + 32]     ; * SP
    mulss   xmm0, DWORD PTR [rsp + 44]     ; * CY
    movss   xmm1, DWORD PTR [rsp + 48]     ; SR
    mulss   xmm1, DWORD PTR [rsp + 36]     ; * CP
    mulss   xmm1, DWORD PTR [rsp + 40]     ; * SY
    addss   xmm0, xmm1
    xorps   xmm2, xmm2
    subss   xmm2, xmm0                     ; negate
    movss   DWORD PTR [rsi + 4],  xmm2     ; out->Y

    ; Z = CR*CP*SY - SR*SP*CY
    movss   xmm0, DWORD PTR [rsp + 52]     ; CR
    mulss   xmm0, DWORD PTR [rsp + 36]     ; * CP
    mulss   xmm0, DWORD PTR [rsp + 40]     ; * SY
    movss   xmm1, DWORD PTR [rsp + 48]     ; SR
    mulss   xmm1, DWORD PTR [rsp + 32]     ; * SP
    mulss   xmm1, DWORD PTR [rsp + 44]     ; * CY
    subss   xmm0, xmm1
    movss   DWORD PTR [rsi + 8],  xmm0     ; out->Z

    ; W = CR*CP*CY + SR*SP*SY
    movss   xmm0, DWORD PTR [rsp + 52]     ; CR
    mulss   xmm0, DWORD PTR [rsp + 36]     ; * CP
    mulss   xmm0, DWORD PTR [rsp + 44]     ; * CY
    movss   xmm1, DWORD PTR [rsp + 48]     ; SR
    mulss   xmm1, DWORD PTR [rsp + 32]     ; * SP
    mulss   xmm1, DWORD PTR [rsp + 40]     ; * SY
    addss   xmm0, xmm1
    movss   DWORD PTR [rsi + 12], xmm0     ; out->W

    add     rsp, 64
    pop     rsi
    pop     rbx
    pop     rbp
    ret
Utils_RotToQuat ENDP

; Utils_VecToRot(RCX=FVector* vec, RDX=FRotator* out_rot)
; FVector:  X[+0] Y[+4] Z[+8]
; FRotator: Pitch[+0] Yaw[+4] Roll[+8]
; Yaw   = atan2f(Y, X) * (180/PI)
; Pitch = atan2f(Z, sqrtf(X*X + Y*Y)) * (180/PI)
; Roll  = 0
; Frame: push rbp rbx rsi + sub 48  (3 pushes -> 0; sub 48 -> 0)
Utils_VecToRot PROC
    push    rbp
    push    rbx
    push    rsi
    sub     rsp, 48

    mov     rbx, rcx                        ; rbx = FVector*
    mov     rsi, rdx                        ; rsi = FRotator*

    ; Yaw = atan2f(Y, X) * (180/PI)
    movss   xmm0, DWORD PTR [rbx + 4]      ; xmm0 = Y (y argument to atan2)
    movss   xmm1, DWORD PTR [rbx]          ; xmm1 = X (x argument to atan2)
    call    atan2f                          ; XMM0 = atan2(Y, X) in radians
    mulss   xmm0, DWORD PTR [fRadToDeg]
    movss   DWORD PTR [rsi + 4], xmm0      ; out->Yaw

    ; Pitch = atan2f(Z, sqrtf(X*X + Y*Y)) * (180/PI)
    movss   xmm0, DWORD PTR [rbx]          ; X
    mulss   xmm0, xmm0                      ; X*X
    movss   xmm1, DWORD PTR [rbx + 4]      ; Y
    mulss   xmm1, xmm1                      ; Y*Y
    addss   xmm0, xmm1                      ; X*X + Y*Y
    sqrtss  xmm0, xmm0                      ; sqrtf(X*X + Y*Y)  [hardware SSE]
    movss   xmm1, xmm0                      ; xmm1 = sqrt (x arg)
    movss   xmm0, DWORD PTR [rbx + 8]      ; xmm0 = Z (y arg)
    call    atan2f                          ; XMM0 = atan2(Z, sqrt)
    mulss   xmm0, DWORD PTR [fRadToDeg]
    movss   DWORD PTR [rsi], xmm0           ; out->Pitch

    ; Roll = 0.0
    xorps   xmm0, xmm0
    movss   DWORD PTR [rsi + 8], xmm0      ; out->Roll

    add     rsp, 48
    pop     rsi
    pop     rbx
    pop     rbp
    ret
Utils_VecToRot ENDP

; Utils_FRand() -> XMM0 (float in [0.0, 1.0))
; Returns (float)rand() / 32767.0f
; Frame: push rbp + sub 32  (1 push -> 0; sub 32 -> 0)
Utils_FRand PROC
    push    rbp
    sub     rsp, 32

    call    rand                            ; EAX = random int [0, RAND_MAX]
    cvtsi2ss xmm0, eax                     ; convert to float
    divss   xmm0, DWORD PTR [fRandMax]     ; / 32767.0

    add     rsp, 32
    pop     rbp
    ret
Utils_FRand ENDP

; Utils_RandomIntInRange(ECX=min, EDX=max) -> EAX
; Returns a random integer in [min, max] inclusive.
; Uses: rand() % (max - min + 1) + min
; Frame: push rbp rbx rsi + sub 32  (3 pushes -> 0; sub 32 -> 0)
Utils_RandomIntInRange PROC
    push    rbp
    push    rbx
    push    rsi
    sub     rsp, 32

    mov     ebx, ecx                        ; ebx = min
    sub     edx, ecx                        ; edx = max - min
    inc     edx                             ; edx = range = max - min + 1
    mov     esi, edx                        ; esi = range

    call    rand                            ; EAX = rand value

    ; EAX % range: use unsigned div (xdiv) since values are non-negative
    xor     edx, edx
    test    esi, esi
    jle     @@zero_range                    ; guard: range <= 0 -> return min
    div     esi                             ; EDX = EAX % range
    add     edx, ebx                        ; result = remainder + min
    mov     eax, edx
    jmp     @@done

@@zero_range:
    mov     eax, ebx                        ; return min

@@done:
    add     rsp, 32
    pop     rsi
    pop     rbx
    pop     rbp
    ret
Utils_RandomIntInRange ENDP

END