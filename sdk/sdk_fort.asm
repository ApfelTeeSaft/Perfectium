INCLUDE include\master.inc

.data?

pCachedEngine   QWORD   ?   ; UFortEngine* (cached after first call)

; UFunction pointers needed for CreateConsole (found via FindObject)
pFn_SpawnObject QWORD   ?   ; UFunction* for GameplayStatics.STATIC_SpawnObject

.const

; Used to locate the UFortEngine singleton
szFortEngineKey     DB  "FortEngine_", 0

; Used to locate static classes needed for CreateConsole
szUConsoleClass     DB  "Class Engine.Console", 0
szGameViewportClass DB  "Class Engine.GameViewportClient", 0
szSpawnObjectFn     DB  "Function Engine.GameplayStatics.SpawnObject", 0

.code

; SDK_GetEngine() -> RAX:QWORD (UFortEngine*)
; Returns the global UFortEngine singleton.
; Caches the result in pCachedEngine after the first successful lookup.
; Mirrors UE4.h: GetEngine() { static auto engine = FindObject<UFortEngine>("FortEngine_"); }
SDK_GetEngine PROC
    push    rbp
    push    rbx
    sub     rsp, 40                 ; 2 pushes (entry 8->0->8); sub 40(=8) -> 0 

    ; Return cached pointer if already resolved
    mov     rax, QWORD PTR [pCachedEngine]
    test    rax, rax
    jnz     @@done

    ; FindObject("FortEngine_")
    lea     rcx, szFortEngineKey
    call    SDK_FindObject
    test    rax, rax
    jz      @@done

    mov     QWORD PTR [pCachedEngine], rax  ; cache it

@@done:
    add     rsp, 40
    pop     rbx
    pop     rbp
    ret
SDK_GetEngine ENDP

; SDK_GetWorld() -> RAX:QWORD (UWorld*)
; Returns GetEngine()->GameViewport->World.
; UEngine::GameViewport at [Engine + 0x0728]
; UGameViewportClient::World at [GameViewport + 0x0088]
SDK_GetWorld PROC
    push    rbp
    push    rbx
    sub     rsp, 40

    call    SDK_GetEngine
    test    rax, rax
    jz      @@null

    mov     rax, QWORD PTR [rax + 0728h]    ; GameViewport (UGameViewportClient*)
    test    rax, rax
    jz      @@null

    mov     rax, QWORD PTR [rax + 0088h]    ; World (UWorld*)
    jmp     @@done

@@null:
    xor     eax, eax

@@done:
    add     rsp, 40
    pop     rbx
    pop     rbp
    ret
SDK_GetWorld ENDP

; SDK_CreateConsole()
; Spawns a UConsole object and attaches it to GameViewport.
; Stack: push rbp rbx rsi rdi r12 (5 pushes) + sub 72 = 0 mod 16
; 5 pushes: entry 8 -> 0->8->0->8->0 (after 5 pushes = 0 mod 16... wait)
; Actually: push×5 subtracts 40. entry RSP 8; 8-40=8-40... in terms of mod:
; 8 mod 16 - 5×8 mod 16 = 8 - 40 mod 16 = 8 - 8 = 0 mod 16.
; sub 72 (72=8): 0-8 = 8 ✗. Need sub 64 (64=0): 0-0 = 0 .
SDK_CreateConsole PROC
    push    rbp
    push    rbx
    push    rsi
    push    rdi
    push    r12
    sub     rsp, 64                 ; 5 pushes (RSP = 0 mod 16); sub 64(=0) -> 0 
                                    ; [rsp+32..63] = SpawnObject params struct (32 bytes)

    ; Get Engine and GameViewport
    call    SDK_GetEngine
    test    rax, rax
    jz      @@done
    mov     rbx, rax                ; rbx = Engine

    mov     rsi, QWORD PTR [rbx + 0728h]    ; rsi = GameViewport
    test    rsi, rsi
    jz      @@done

    ; Get UConsole::StaticClass
    lea     rcx, szUConsoleClass
    call    SDK_FindClass
    test    rax, rax
    jz      @@done
    mov     r12, rax                ; r12 = UConsoleClass

    ; Find SpawnObject UFunction
    mov     rdi, QWORD PTR [pFn_SpawnObject]
    test    rdi, rdi
    jnz     @@have_fn

    lea     rcx, szSpawnObjectFn
    call    SDK_FindObject
    test    rax, rax
    jz      @@done
    mov     rdi, rax
    mov     QWORD PTR [pFn_SpawnObject], rdi

@@have_fn:
    ; Build params struct for STATIC_SpawnObject on stack
    ; STATIC_SpawnObject(ObjectClass:UClass*, Outer:UObject*) -> UObject*
    ; Params layout (ProcessEvent param block):
    ;   [+0x00] ObjectClass: QWORD (UClass*)
    ;   [+0x08] Outer:       QWORD (UObject*)
    ;   [+0x10] ReturnValue: QWORD (UObject*)  <- filled by ProcessEvent
    mov     QWORD PTR [rsp + 32],      r12    ; ObjectClass = UConsoleClass
    mov     QWORD PTR [rsp + 32 + 8],  rsi    ; Outer = GameViewport
    mov     QWORD PTR [rsp + 32 + 16], 0      ; ReturnValue = null (filled by fn)

    ; Call ProcessEvent on GameplayStatics static class
    mov     rcx, rsi                    ; RCX = 'this' (GameViewport = outer)
    mov     rdx, rdi                    ; RDX = UFunction* SpawnObject
    lea     r8,  [rsp + 32]             ; R8  = params struct
    call    ProcessEvent_Call

    ; Store result in GameViewport->ViewportConsole
    mov     rax, QWORD PTR [rsp + 32 + 16]  ; ReturnValue = UConsole*
    test    rax, rax
    jz      @@done
    mov     QWORD PTR [rsi + 0040h], rax     ; GameViewport->ViewportConsole = console

@@done:
    add     rsp, 64
    pop     r12
    pop     rdi
    pop     rsi
    pop     rbx
    pop     rbp
    ret
SDK_CreateConsole ENDP

; FortHelper_GetAbilitySystemComponent(pawn:QWORD) -> RAX:QWORD
; Returns the UAbilitySystemComponent* from a pawn.
; AbilitySystemComponent is at pawn+0x0280 (ACharacter field).
FortHelper_GetAbilitySystemComponent PROC
    ; RCX = APlayerPawn_Athena_C* pawn
    test    rcx, rcx
    jz      @@null
    mov     rax, QWORD PTR [rcx + 0280h]    ; AbilitySystemComponent at +0x0280
    ret
@@null:
    xor     eax, eax
    ret
FortHelper_GetAbilitySystemComponent ENDP

; FortHelper_GetWorldInventory(pc:QWORD) -> RAX:QWORD
; Returns AFortInventory* from a player controller.
; AFortPlayerControllerAthena::WorldInventory = AFPC_WorldInventory = 0x1ED8
FortHelper_GetWorldInventory PROC
    ; RCX = AFortPlayerControllerAthena* pc
    test    rcx, rcx
    jz      @@null
    mov     rax, QWORD PTR [rcx + AFPC_WorldInventory]   ; +0x1ED8
    ret
@@null:
    xor     eax, eax
    ret
FortHelper_GetWorldInventory ENDP

; FortHelper_GetQuickBars(pc:QWORD) -> RAX:QWORD
; Returns AFortQuickBars* from a player controller.
; AFortPlayerControllerAthena::QuickBars = AFPC_QuickBars = 0x1C38
FortHelper_GetQuickBars PROC
    ; RCX = AFortPlayerControllerAthena* pc
    test    rcx, rcx
    jz      @@null
    mov     rax, QWORD PTR [rcx + AFPC_QuickBars]        ; +0x1C38
    ret
@@null:
    xor     eax, eax
    ret
FortHelper_GetQuickBars ENDP

END