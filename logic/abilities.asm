INCLUDE include\master.inc

; UAbilitySystemComponent: ActivatableAbilities(+0x470) + Items TArray (+0xB0)
ASC_ITEMS_DATA  EQU 0520h
ASC_ITEMS_NUM   EQU 0528h

; FGameplayAbilitySpec field offsets (from spec base)
SPEC_HANDLE     EQU 00Ch    ; Handle.Handle (DWORD)
SPEC_ABILITY    EQU 010h    ; Ability (QWORD)
SPEC_LEVEL      EQU 018h    ; Level (DWORD)
SPEC_INPUTID    EQU 01Ch    ; InputID (DWORD)
SPEC_INPRESSED  EQU 029h    ; InputPressed (BYTE bit 0)
SPEC_SIZEOF     EQU 0C8h

; FPredictionKey.Current = int16 at +0
FPREDKEY_CURRENT EQU 000h

; UClass::vtable[101] = CreateDefaultObject
VFUNC_CDO_OFS   EQU 0328h   ; 101 * 8

.const

sz_ClientActFailed BYTE "Function GameplayAbilities.AbilitySystemComponent.ClientActivateAbilityFailed",0
sz_Sprint         BYTE "Class FortniteGame.FortGameplayAbility_Sprint",0
sz_Reload         BYTE "Class FortniteGame.FortGameplayAbility_Reload",0
sz_Ranged         BYTE "Class FortniteGame.FortGameplayAbility_RangedWeapon",0
sz_Jump           BYTE "Class FortniteGame.FortGameplayAbility_Jump",0
sz_Death          BYTE "BlueprintGeneratedClass GA_DefaultPlayer_Death.GA_DefaultPlayer_Death_C",0
sz_InteractUse    BYTE "BlueprintGeneratedClass GA_DefaultPlayer_InteractUse.GA_DefaultPlayer_InteractUse_C",0
sz_InteractSearch BYTE "BlueprintGeneratedClass GA_DefaultPlayer_InteractSearch.GA_DefaultPlayer_InteractSearch_C",0
sz_Emote          BYTE "BlueprintGeneratedClass GAB_Emote_Generic.GAB_Emote_Generic_C",0
sz_Trap           BYTE "BlueprintGeneratedClass GA_TrapBuildGeneric.GA_TrapBuildGeneric_C",0
sz_DanceGrenade   BYTE "BlueprintGeneratedClass GA_DanceGrenade_Stun.GA_DanceGrenade_Stun_C",0

.data?

fn_ClientActFailed      QWORD ?

AbilityClass_Sprint         QWORD ?
AbilityClass_Reload         QWORD ?
AbilityClass_Ranged         QWORD ?
AbilityClass_Jump           QWORD ?
AbilityClass_Death          QWORD ?
AbilityClass_InteractUse    QWORD ?
AbilityClass_InteractSearch QWORD ?
AbilityClass_Emote          QWORD ?
AbilityClass_Trap           QWORD ?
AbilityClass_DanceGrenade   QWORD ?

.code

; Abilities_FindAbilitySpecFromHandle
; In : RCX = UAbilitySystemComponent*
;      RDX = FGameplayAbilitySpecHandle* (int Handle at [RDX+0])
; Out: RAX = &FGameplayAbilitySpec or NULL
; No CALL sites -> no shadow/alignment needed; push/pop only.
Abilities_FindAbilitySpecFromHandle PROC
    push    rbx
    push    rbp
    push    rsi

    mov     rsi, rcx
    mov     ebx, DWORD PTR [rdx]            ; target Handle.Handle value

    mov     rcx, QWORD PTR [rsi + ASC_ITEMS_DATA]
    mov     edx, DWORD PTR [rsi + ASC_ITEMS_NUM]
    test    rcx, rcx
    jz      @FASFH_miss
    test    edx, edx
    jz      @FASFH_miss

    xor     ebp, ebp                        ; i = 0
@FASFH_loop:
    cmp     ebp, edx
    jge     @FASFH_miss
    imul    rax, rbp, SPEC_SIZEOF
    add     rax, rcx
    cmp     DWORD PTR [rax + SPEC_HANDLE], ebx
    je      @FASFH_found
    inc     ebp
    jmp     @FASFH_loop

@FASFH_miss:
    xor     eax, eax
@FASFH_found:
    pop     rsi
    pop     rbp
    pop     rbx
    ret
Abilities_FindAbilitySpecFromHandle ENDP


; Abilities_ConsumeAllReplicatedData
Abilities_ConsumeAllReplicatedData PROC
    ret
Abilities_ConsumeAllReplicatedData ENDP


; Abilities_TryActivateAbility
; In : RCX = UAbilitySystemComponent*
;      RDX = FGameplayAbilitySpecHandle* (Handle.Handle at [RDX+0])
;      R8B = InputPressed (bool)
;      R9  = FPredictionKey*
;      [caller rsp+32+8] = arg5: FGameplayEventData* TriggerEventData
;
; Stack: 5 callee-saved pushes (40) + sub 70h (112) = 152
;        Entry RSP=8; 5 pushes: 8-40=-32=0; sub 70h: 0-112=0 
;
; Frame slots (after prolog, relative to current RSP):
;   [+00..+1F] shadow (32 B)
;   [+20..+27] arg5 slot for 6-arg calls
;   [+28..+2F] arg6 slot
;   [+30..+37] OutInstancedAbility QWORD
;   [+38..+3B] handle DWORD copy (for FindAbilitySpec pointer arg)
;   [+40..+47] CAF params: Handle(4) + PredKey(2) + pad(2)
Abilities_TryActivateAbility PROC
    push    rbx
    push    rbp
    push    rsi
    push    rdi
    push    r12
    sub     rsp, 70h

    mov     rsi, rcx
    mov     ebx, DWORD PTR [rdx]            ; EBX = Handle.Handle
    movzx   r12d, r8b                       ; R12D = InputPressed (unused directly)
    mov     rdi, r9                         ; RDI = FPredictionKey*
    ; arg5 (TriggerEventData*) at entry_rsp+40 = current_rsp+152+40 = rsp+0xC0
    mov     rbp, QWORD PTR [rsp + 0C0h]

    ; Find spec
    mov     DWORD PTR [rsp + 38h], ebx
    mov     rcx, rsi
    lea     rdx, [rsp + 38h]
    call    Abilities_FindAbilitySpecFromHandle
    test    rax, rax
    jz      @TAA_do_caf

    ; Set InputPressed = 1
    or      BYTE PTR [rax + SPEC_INPRESSED], 1

    ; InternalTryActivateAbility(ASC, Handle, PredKey*, &OutGA, NULL, TriggerEventData)
    xor     eax, eax
    mov     QWORD PTR [rsp + 30h], rax
    mov     rcx, rsi
    mov     edx, ebx
    mov     r8, rdi
    lea     r9, [rsp + 30h]
    mov     QWORD PTR [rsp + 20h], rax
    mov     QWORD PTR [rsp + 28h], rbp
    call    QWORD PTR [Native_AbilitySystemComponent_InternalTryActivateAbility]
    test    al, al
    jz      @TAA_activate_failed

    ; Success: MarkAbilitySpecDirty
    mov     DWORD PTR [rsp + 38h], ebx
    mov     rcx, rsi
    lea     rdx, [rsp + 38h]
    call    Abilities_FindAbilitySpecFromHandle
    test    rax, rax
    jz      @TAA_done
    mov     rcx, rsi
    mov     rdx, rax
    call    QWORD PTR [Native_AbilitySystemComponent_MarkAbilitySpecDirty]
    jmp     @TAA_done

@TAA_activate_failed:
    ; Clear InputPressed
    mov     DWORD PTR [rsp + 38h], ebx
    mov     rcx, rsi
    lea     rdx, [rsp + 38h]
    call    Abilities_FindAbilitySpecFromHandle
    test    rax, rax
    jz      @TAA_do_caf
    and     BYTE PTR [rax + SPEC_INPRESSED], 0FEh

@TAA_do_caf:
    ; Lazy-load ClientActivateAbilityFailed fn
    mov     rax, QWORD PTR [fn_ClientActFailed]
    test    rax, rax
    jnz     @TAA_caf_call
    lea     rcx, [sz_ClientActFailed]
    call    SDK_FindObject
    mov     QWORD PTR [fn_ClientActFailed], rax
@TAA_caf_call:
    test    rax, rax
    jz      @TAA_done
    ; Params: Handle(4) at +0, PredictionKey.Current(int16) at +4
    mov     DWORD PTR [rsp + 40h], ebx
    movsx   ecx, WORD PTR [rdi + FPREDKEY_CURRENT]
    mov     WORD PTR [rsp + 44h], cx
    mov     rcx, rsi
    mov     rdx, rax
    lea     r8, [rsp + 40h]
    call    QWORD PTR [ProcessEvent]

@TAA_done:
    add     rsp, 70h
    pop     r12
    pop     rdi
    pop     rsi
    pop     rbp
    pop     rbx
    ret
Abilities_TryActivateAbility ENDP


; Abilities_GrantGameplayAbility
; In : RCX = APlayerPawn_Athena_C* (pawn)
;      RDX = UClass* (abilityClass)
;
; Stack: 5 callee-saved pushes (40) + sub 100h (256) = 296
;        Entry RSP=8; 5 pushes: 8-40=0; sub 100h: 0=0 
;
; Frame:
;   [+00..+1F] shadow
;   [+20..+27] arg5 slot
;   [+28..+2F] OutHandle QWORD (for GiveAbility result)
;   [+30..+F7] FGameplayAbilitySpec copy (0xC8 bytes)
Abilities_GrantGameplayAbility PROC
    push    rbx
    push    rbp
    push    rsi
    push    rdi
    push    r12
    sub     rsp, 100h

    mov     rbp, rcx                        ; RBP = pawn
    mov     rsi, rdx                        ; RSI = abilityClass

    ; ASC = FortHelper_GetAbilitySystemComponent(pawn)
    mov     rcx, rbp
    call    FortHelper_GetAbilitySystemComponent
    test    rax, rax
    jz      @GAA_done
    mov     rbx, rax                        ; RBX = ASC

    ; CDO = abilityClass->vtable[101](abilityClass)
    mov     rcx, rsi
    mov     rax, QWORD PTR [rcx]
    call    QWORD PTR [rax + VFUNC_CDO_OFS]
    test    rax, rax
    jz      @GAA_done
    mov     rdi, rax                        ; RDI = CDO

    ; Duplicate check: scan ActivatableAbilities.Items for same Ability ptr
    mov     r12, QWORD PTR [rbx + ASC_ITEMS_DATA]
    mov     ebp, DWORD PTR [rbx + ASC_ITEMS_NUM]
    test    ebp, ebp
    jz      @GAA_add
    test    r12, r12
    jz      @GAA_add
    xor     ecx, ecx                        ; i = 0
@GAA_dup_loop:
    cmp     ecx, ebp
    jge     @GAA_add
    imul    rax, rcx, SPEC_SIZEOF
    add     rax, r12
    cmp     QWORD PTR [rax + SPEC_ABILITY], rdi
    je      @GAA_done                       ; duplicate, skip
    inc     ecx
    jmp     @GAA_dup_loop

@GAA_add:
    ; Zero out spec buffer at [rsp+30h]
    lea     rcx, [rsp + 30h]
    xor     edx, edx
    mov     r8d, SPEC_SIZEOF
    call    memset

    ; FFastArraySerializerItem: ReplicationID/Key/MostRecentKey = -1
    mov     DWORD PTR [rsp + 30h + 000h], 0FFFFFFFFh
    mov     DWORD PTR [rsp + 30h + 004h], 0FFFFFFFFh
    mov     DWORD PTR [rsp + 30h + 008h], 0FFFFFFFFh

    ; Handle.Handle = lower 32 bits of CDO ptr | 1 (ensure non-zero and pseudo-unique)
    mov     eax, edi
    or      eax, 1
    mov     DWORD PTR [rsp + 30h + SPEC_HANDLE], eax

    ; Ability = CDO
    mov     QWORD PTR [rsp + 30h + SPEC_ABILITY], rdi

    ; Level = 1
    mov     DWORD PTR [rsp + 30h + SPEC_LEVEL], 1

    ; InputID = -1
    mov     DWORD PTR [rsp + 30h + SPEC_INPUTID], 0FFFFFFFFh

    ; GiveAbility(ASC, &OutHandle, &Spec)
    mov     rcx, rbx
    lea     rdx, [rsp + 28h]
    lea     r8, [rsp + 30h]
    call    QWORD PTR [Native_AbilitySystemComponent_GiveAbility]

@GAA_done:
    add     rsp, 100h
    pop     r12
    pop     rdi
    pop     rsi
    pop     rbp
    pop     rbx
    ret
Abilities_GrantGameplayAbility ENDP


; Abilities_ApplyAbilities
; In : RCX = APlayerPawn_Athena_C* (pawn)
; Grants 10 standard gameplay abilities. Lazily caches class ptrs.
;
; Stack: 2 pushes (16) + sub 28h (40) = 56
;        Entry RSP=8; 2 pushes: 8-16=8; sub 28h: 8-40=0 
Abilities_ApplyAbilities PROC
    push    rbx
    push    rdi
    sub     rsp, 28h

    mov     rbx, rcx                        ; RBX = pawn

    ; Macro-like: load class pointer (lazily) then call GrantGameplayAbility
    ; Sprint
    mov     rdi, QWORD PTR [AbilityClass_Sprint]
    test    rdi, rdi
    jnz     @AAA_sprint_ok
    lea     rcx, [sz_Sprint]
    call    SDK_FindClass
    mov     QWORD PTR [AbilityClass_Sprint], rax
    mov     rdi, rax
@AAA_sprint_ok:
    test    rdi, rdi
    jz      @AAA_reload
    mov     rcx, rbx
    mov     rdx, rdi
    call    Abilities_GrantGameplayAbility

@AAA_reload:
    mov     rdi, QWORD PTR [AbilityClass_Reload]
    test    rdi, rdi
    jnz     @AAA_reload_ok
    lea     rcx, [sz_Reload]
    call    SDK_FindClass
    mov     QWORD PTR [AbilityClass_Reload], rax
    mov     rdi, rax
@AAA_reload_ok:
    test    rdi, rdi
    jz      @AAA_ranged
    mov     rcx, rbx
    mov     rdx, rdi
    call    Abilities_GrantGameplayAbility

@AAA_ranged:
    mov     rdi, QWORD PTR [AbilityClass_Ranged]
    test    rdi, rdi
    jnz     @AAA_ranged_ok
    lea     rcx, [sz_Ranged]
    call    SDK_FindClass
    mov     QWORD PTR [AbilityClass_Ranged], rax
    mov     rdi, rax
@AAA_ranged_ok:
    test    rdi, rdi
    jz      @AAA_jump
    mov     rcx, rbx
    mov     rdx, rdi
    call    Abilities_GrantGameplayAbility

@AAA_jump:
    mov     rdi, QWORD PTR [AbilityClass_Jump]
    test    rdi, rdi
    jnz     @AAA_jump_ok
    lea     rcx, [sz_Jump]
    call    SDK_FindClass
    mov     QWORD PTR [AbilityClass_Jump], rax
    mov     rdi, rax
@AAA_jump_ok:
    test    rdi, rdi
    jz      @AAA_death
    mov     rcx, rbx
    mov     rdx, rdi
    call    Abilities_GrantGameplayAbility

@AAA_death:
    mov     rdi, QWORD PTR [AbilityClass_Death]
    test    rdi, rdi
    jnz     @AAA_death_ok
    lea     rcx, [sz_Death]
    call    SDK_FindClass
    mov     QWORD PTR [AbilityClass_Death], rax
    mov     rdi, rax
@AAA_death_ok:
    test    rdi, rdi
    jz      @AAA_iuse
    mov     rcx, rbx
    mov     rdx, rdi
    call    Abilities_GrantGameplayAbility

@AAA_iuse:
    mov     rdi, QWORD PTR [AbilityClass_InteractUse]
    test    rdi, rdi
    jnz     @AAA_iuse_ok
    lea     rcx, [sz_InteractUse]
    call    SDK_FindClass
    mov     QWORD PTR [AbilityClass_InteractUse], rax
    mov     rdi, rax
@AAA_iuse_ok:
    test    rdi, rdi
    jz      @AAA_isearch
    mov     rcx, rbx
    mov     rdx, rdi
    call    Abilities_GrantGameplayAbility

@AAA_isearch:
    mov     rdi, QWORD PTR [AbilityClass_InteractSearch]
    test    rdi, rdi
    jnz     @AAA_isearch_ok
    lea     rcx, [sz_InteractSearch]
    call    SDK_FindClass
    mov     QWORD PTR [AbilityClass_InteractSearch], rax
    mov     rdi, rax
@AAA_isearch_ok:
    test    rdi, rdi
    jz      @AAA_emote
    mov     rcx, rbx
    mov     rdx, rdi
    call    Abilities_GrantGameplayAbility

@AAA_emote:
    mov     rdi, QWORD PTR [AbilityClass_Emote]
    test    rdi, rdi
    jnz     @AAA_emote_ok
    lea     rcx, [sz_Emote]
    call    SDK_FindClass
    mov     QWORD PTR [AbilityClass_Emote], rax
    mov     rdi, rax
@AAA_emote_ok:
    test    rdi, rdi
    jz      @AAA_trap
    mov     rcx, rbx
    mov     rdx, rdi
    call    Abilities_GrantGameplayAbility

@AAA_trap:
    mov     rdi, QWORD PTR [AbilityClass_Trap]
    test    rdi, rdi
    jnz     @AAA_trap_ok
    lea     rcx, [sz_Trap]
    call    SDK_FindClass
    mov     QWORD PTR [AbilityClass_Trap], rax
    mov     rdi, rax
@AAA_trap_ok:
    test    rdi, rdi
    jz      @AAA_dance
    mov     rcx, rbx
    mov     rdx, rdi
    call    Abilities_GrantGameplayAbility

@AAA_dance:
    mov     rdi, QWORD PTR [AbilityClass_DanceGrenade]
    test    rdi, rdi
    jnz     @AAA_dance_ok
    lea     rcx, [sz_DanceGrenade]
    call    SDK_FindClass
    mov     QWORD PTR [AbilityClass_DanceGrenade], rax
    mov     rdi, rax
@AAA_dance_ok:
    test    rdi, rdi
    jz      @AAA_done
    mov     rcx, rbx
    mov     rdx, rdi
    call    Abilities_GrantGameplayAbility

@AAA_done:
    add     rsp, 28h
    pop     rdi
    pop     rbx
    ret
Abilities_ApplyAbilities ENDP

END