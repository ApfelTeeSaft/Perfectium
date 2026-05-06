INCLUDE include\master.inc

; AFortPickup field offsets
AFPICKUP_bReplicates            EQU 0082h   ; AActor::bReplicates bitfield (byte bit6)
AFPICKUP_PrimaryPickupItemEntry EQU 0350h   ; FFortItemEntry base
  FITE_Count                    EQU 000Ch   ; +0C within FFortItemEntry
  FITE_ItemDefinition           EQU 0018h   ; +18
  FITE_LoadedAmmo               EQU 0028h   ; +28
AFPICKUP_PickupLocationData     EQU 0428h   ; FFortPickupLocationData
  FPLD_PickupTarget             EQU 0000h   ; +00 within PickupLocationData
  FPLD_ItemOwner                EQU 0010h   ; +10
  FPLD_FlyTime                  EQU 0030h   ; +30 (float)
AFPICKUP_bPickedUp              EQU 04C0h   ; bool (Net)
AFPICKUP_bTossedFromContainer   EQU 0349h   ; bool (net, after bRandomRotation)

; ABuildingTrap offsets
ABTRAP_TrapData                 EQU 0580h   ; UFortTrapItemDefinition*
ABTRAP_AttachedTo               EQU 0570h   ; ABuildingActor*
ABTRAP_Team                     EQU 04C5h   ; EFortTeam (1 byte) - from ABuildingActor

; UFortAbilitySet::GameplayAbilities TArray at +0x38
UFAS_GameplayAbilities          EQU 0038h

.const

szFn_BeginDeferredSpawn DB "Function Engine.GameplayStatics.BeginDeferredActorSpawnFromClass", 0
szFn_FinishSpawning     DB "Function Engine.GameplayStatics.FinishSpawningActor", 0
szFn_SpawnBuildingGA    DB "Function FortniteGame.FortKismetLibrary.STATIC_SpawnBuildingGameplayActor", 0
szFn_TossPickup         DB "Function FortniteGame.FortPickup.TossPickup", 0
szFn_OnRep_PrimaryPE    DB "Function FortniteGame.FortPickup.OnRep_PrimaryPickupItemEntry", 0
szFn_OnRep_bPickedUp    DB "Function FortniteGame.FortPickup.OnRep_bPickedUp", 0
szFn_OnRep_TossedFrCont DB "Function FortniteGame.FortPickup.OnRep_TossedFromContainer", 0
szFn_OnRep_PickupLocDat DB "Function FortniteGame.FortPickup.OnRep_PickupLocationData", 0
szFn_InitKismetBuilding DB "Function FortniteGame.BuildingActor.InitializeKismetSpawnedBuildingActor", 0
szFn_OnRep_AttachedTo   DB "Function FortniteGame.BuildingActor.OnRep_AttachedTo", 0
szFn_GetBlueprintClass  DB "Function FortniteGame.FortTrapItemDefinition.GetBlueprintClass", 0

szClass_GameplayStatics DB "Class Engine.GameplayStatics", 0
szClass_FortKismet      DB "Class FortniteGame.FortKismetLibrary", 0
szClass_AFortPickup     DB "Class FortniteGame.FortPickup", 0

szLogSpawnNull  DB "[SPAWNERS] SpawnActor returned null!", 0
szLogDecoNull   DB "[SPAWNERS] SpawnDeco: null tool or params.", 0

.data?

pFn_BeginDeferredSpawn  QWORD ?
pFn_FinishSpawning      QWORD ?
pFn_SpawnBuildingGA     QWORD ?
pFn_TossPickup          QWORD ?
pFn_OnRep_PrimaryPE     QWORD ?
pFn_OnRep_bPickedUp     QWORD ?
pFn_OnRep_TossedFrCont  QWORD ?
pFn_OnRep_PickupLocDat  QWORD ?
pFn_InitKismetBuilding  QWORD ?
pFn_OnRep_AttachedTo    QWORD ?
pFn_GetBlueprintClass   QWORD ?

pClass_GameplayStatics  QWORD ?
pClass_FortKismet       QWORD ?
pClass_AFortPickup_C    QWORD ?

.code

; Internal: lazy-load cached UFunction*.
;  RCX = &cache_var (QWORD*), RDX = szFunctionPath (PTR BYTE)
;  Returns UFunction* in RAX.
Spawners__LoadFn PROC
    mov     rax, QWORD PTR [rcx]
    test    rax, rax
    jnz     @@done
    push    rcx                             ; save cache ptr
    sub     rsp, 32
    ; rcx already is the cache ptr - need path in rcx for SDK_FindObject
    mov     rcx, rdx
    call    SDK_FindObject
    add     rsp, 32
    pop     rcx
    mov     QWORD PTR [rcx], rax
@@done:
    ret
Spawners__LoadFn ENDP

; Internal: lazy-load cached UClass*.
;  RCX = &cache_var, RDX = szClassName
Spawners__LoadClass PROC
    mov     rax, QWORD PTR [rcx]
    test    rax, rax
    jnz     @@done
    push    rcx
    sub     rsp, 32
    mov     rcx, rdx
    call    SDK_FindClass
    add     rsp, 32
    pop     rcx
    mov     QWORD PTR [rcx], rax
@@done:
    ret
Spawners__LoadClass ENDP

; AActor* Spawners_SpawnActor(UClass* ActorClass,
;                             FVector* pLocation,
;                             AActor* Owner)
; RCX = ActorClass, RDX = FVector* location (may be NULL -> {0,0,0}),
; R8  = AActor* Owner (may be NULL)
;
; Calls STATIC_BeginDeferredActorSpawnFromClass then FinishSpawningActor.
;
; BeginDeferredActorSpawnFromClass params (at [rsp+X]):
;   +00: UObject* WorldContextObject  (8)
;   +08: UClass* ActorClass           (8)
;   +10: FTransform SpawnTransform    (0x30 = 48 bytes)
;   +40: BYTE CollisionHandlingOverride (ESpawnActorCollisionHandlingMethod)
;   +41..+47: 7 pad bytes
;   +48: AActor* Owner                (8)
;   +50: AActor* ReturnValue          (8 OUT)
; Total params = 0x58 bytes.
;
; FinishSpawningActor params:
;   +00: AActor* Actor    (8)
;   +08: FTransform       (0x30)
;   +38: AActor* ReturnValue (8 OUT)
; Total = 0x40 bytes.

; Offsets within BeginDeferred params (relative to rsp+32)
BDS_WorldCtx    EQU 000h
BDS_Class       EQU 008h
BDS_Transform   EQU 010h   ; FTransform (0x30 bytes)
BDS_Collision   EQU 040h   ; BYTE (collision method)
BDS_Owner       EQU 048h
BDS_RetVal      EQU 050h   ; OUT AActor*

; Offsets within FinishSpawning params (relative to rsp+120)
FS_Actor        EQU 000h
FS_Transform    EQU 008h
FS_RetVal       EQU 038h

; FTransform layout (0x30 bytes):
; +00: FQuat Rotation (16 bytes: X,Y,Z,W)
; +10: FVector Translation (12 bytes: X,Y,Z)
; +1C: pad (4)
; +20: FVector Scale3D (12 bytes: X,Y,Z)
; +2C: pad (4)
; Identity FTransform: Rotation=(0,0,0,1), Translation=(0,0,0), Scale=(1,1,1)
fIdentityQuat_W     REAL4   1.0
fScale_One          REAL4   1.0

Spawners_SpawnActor PROC
    push    rbp
    push    rbx
    push    rsi
    push    rdi
    push    r12
    sub     rsp, 0C0h

    mov     rbx, rcx                        ; rbx = ActorClass
    mov     rsi, rdx                        ; rsi = FVector* location (may be 0)
    mov     rdi, r8                         ; rdi = Owner

    test    rbx, rbx
    jz      @@done_null

    ; Get/cache GameplayStatics class
    lea     rcx, pClass_GameplayStatics
    lea     rdx, szClass_GameplayStatics
    call    Spawners__LoadClass
    mov     r12, rax                        ; r12 = GameplayStatics class
    test    r12, r12
    jz      @@done_null

    ; Get/cache BeginDeferredActorSpawnFromClass fn
    lea     rcx, pFn_BeginDeferredSpawn
    lea     rdx, szFn_BeginDeferredSpawn
    call    Spawners__LoadFn
    test    rax, rax
    jz      @@done_null

    ; Zero params block
    lea     rcx, [rsp+32]
    xor     edx, edx
    mov     r8d, 058h                       ; sizeof params
    call    memset

    ; Fill BeginDeferred params
    call    SDK_GetWorld
    mov     QWORD PTR [rsp + 32 + BDS_WorldCtx], rax
    mov     QWORD PTR [rsp + 32 + BDS_Class],    rbx

    ; FTransform at [rsp+32+BDS_Transform]:
    ;   Rotation.W = 1.0 (identity quat)
    mov     eax, 3F800000h                  ; 1.0f
    mov     DWORD PTR [rsp + 32 + BDS_Transform + 0Ch], eax   ; Rotation.W
    ;   Scale3D = (1,1,1)
    mov     DWORD PTR [rsp + 32 + BDS_Transform + 20h], eax   ; Scale3D.X
    mov     DWORD PTR [rsp + 32 + BDS_Transform + 24h], eax   ; Scale3D.Y
    mov     DWORD PTR [rsp + 32 + BDS_Transform + 28h], eax   ; Scale3D.Z

    ; If location provided, copy XYZ into Translation
    test    rsi, rsi
    jz      @@default_loc
    mov     eax, DWORD PTR [rsi]
    mov     DWORD PTR [rsp + 32 + BDS_Transform + 10h], eax   ; X
    mov     eax, DWORD PTR [rsi + 4]
    mov     DWORD PTR [rsp + 32 + BDS_Transform + 14h], eax   ; Y
    mov     eax, DWORD PTR [rsi + 8]
    mov     DWORD PTR [rsp + 32 + BDS_Transform + 18h], eax   ; Z
@@default_loc:

    ; Collision = ESpawnCollision_AdjustIfPossibleButAlwaysSpawn (2)
    mov     BYTE PTR [rsp + 32 + BDS_Collision], ESpawnCollision_AdjustIfPossibleButAlwaysSpawn
    mov     QWORD PTR [rsp + 32 + BDS_Owner], rdi

    ; Load BeginDeferred fn (already in rax from LoadFn call above - lost)
    ; Need to reload from cache
    mov     rax, QWORD PTR [pFn_BeginDeferredSpawn]
    mov     rcx, r12
    mov     rdx, rax
    lea     r8, [rsp+32]
    call    QWORD PTR [ProcessEvent]

    ; FirstActor = params.ReturnValue
    mov     rbp, QWORD PTR [rsp + 32 + BDS_RetVal]
    test    rbp, rbp
    jz      @@done_null

    ; Get FinishSpawningActor fn
    lea     rcx, pFn_FinishSpawning
    lea     rdx, szFn_FinishSpawning
    call    Spawners__LoadFn
    test    rax, rax
    jz      @@done_null

    ; Fill FinishSpawning params at [rsp+120]
    lea     rcx, [rsp+120]
    xor     edx, edx
    mov     r8d, 040h
    call    memset

    mov     QWORD PTR [rsp + 120 + FS_Actor], rbp

    ; Copy FTransform from BeginDeferred params
    lea     rcx, [rsp + 120 + FS_Transform]
    lea     rdx, [rsp + 32 + BDS_Transform]
    mov     r8d, 030h
    call    memcpy

    mov     rax, QWORD PTR [pFn_FinishSpawning]
    mov     rcx, r12
    mov     rdx, rax
    lea     r8, [rsp+120]
    call    QWORD PTR [ProcessEvent]

    mov     rax, QWORD PTR [rsp + 120 + FS_RetVal]
    jmp     @@done

@@done_null:
    xor     eax, eax
@@done:
    add     rsp, 0C0h
    pop     r12
    pop     rdi
    pop     rsi
    pop     rbx
    pop     rbp
    ret
Spawners_SpawnActor ENDP

; AActor* Spawners_SpawnBuilding(UClass* BGAClass,
;                                FTransform* pTransform,
;                                APlayerPawn_Athena_C* Pawn)
; RCX = BGAClass, RDX = FTransform*, R8 = Pawn
;
; Calls STATIC_SpawnBuildingGameplayActor via FortKismetLibrary.
;
; Params layout:
;   +00: UClass* BGAClass        (8)
;   +08: FTransform (0x30 bytes) (48)
;   +38: AFortPawn* Instigator   (8)
;   +40: ABuildingGameplayActor* ReturnValue (8 OUT)
; Total = 0x48
;
; Frame: 4 pushes (rbp,rbx,rsi,rdi) + sub 58h
;  4 pushes: RSP=8; sub 58h(88)=8 -> 0 
;  [rsp+32..+31+0x48=79] = params (0x48 = 72 bytes)
Spawners_SpawnBuilding PROC
    push    rbp
    push    rbx
    push    rsi
    push    rdi
    sub     rsp, 58h

    mov     rbx, rcx                        ; rbx = BGAClass
    mov     rsi, rdx                        ; rsi = FTransform*
    mov     rdi, r8                         ; rdi = Pawn

    test    rbx, rbx
    jz      @@null
    test    rsi, rsi
    jz      @@null

    ; Get FortKismetLibrary class
    lea     rcx, pClass_FortKismet
    lea     rdx, szClass_FortKismet
    call    Spawners__LoadClass
    mov     rbp, rax
    test    rbp, rbp
    jz      @@null

    ; Get STATIC_SpawnBuildingGameplayActor fn
    lea     rcx, pFn_SpawnBuildingGA
    lea     rdx, szFn_SpawnBuildingGA
    call    Spawners__LoadFn
    test    rax, rax
    jz      @@null

    ; Zero params at [rsp+32]
    lea     rcx, [rsp+32]
    xor     edx, edx
    mov     r8d, 048h
    call    memset

    ; Fill params
    mov     QWORD PTR [rsp+32], rbx         ; BGAClass
    lea     rcx, [rsp + 32 + 8]            ; dest = &params.Transform
    mov     rdx, rsi                        ; src = FTransform*
    mov     r8d, 030h
    call    memcpy
    mov     QWORD PTR [rsp + 32 + 38h], rdi ; Instigator = Pawn

    mov     rax, QWORD PTR [pFn_SpawnBuildingGA]
    mov     rcx, rbp
    mov     rdx, rax
    lea     r8, [rsp+32]
    call    QWORD PTR [ProcessEvent]

    mov     rax, QWORD PTR [rsp + 32 + 40h]
    jmp     @@done
@@null:
    xor     eax, eax
@@done:
    add     rsp, 58h
    pop     rdi
    pop     rsi
    pop     rbx
    pop     rbp
    ret
Spawners_SpawnBuilding ENDP

; AFortPickup* Spawners_SummonPickup(AFortPlayerPawn* Pawn,
;                                    UFortWorldItemDefinition* ItemDef,
;                                    DWORD Count,
;                                    FVector* pLocation)
; RCX = Pawn, RDX = ItemDef, R8D = Count, R9 = FVector*
;
; Frame: 5 pushes (rbp,rbx,rsi,rdi,r12) + sub 50h
;  5 pushes -> RSP=0 mod16; sub 50h(80) mod16=0 
;  [rsp+32..+47] = scratch / TossPickup params setup

; TossPickup params:
;   +00: FVector FinalLocation   (0x0C)
;   +0C: 4 pad (for AActor* alignment)
;   +10: AFortPawn* ItemOwner    (8)
;   +18: int OverrideMaxStackCount (4)
;   +1C: bool bToss              (1)
;   +1D: 3 pad
; Total: 0x20

Spawners_SummonPickup PROC
    push    rbp
    push    rbx
    push    rsi
    push    rdi
    push    r12
    sub     rsp, 50h

    mov     rbx, rcx                        ; rbx = Pawn
    mov     rsi, rdx                        ; rsi = ItemDef
    mov     edi, r8d                        ; edi = Count
    mov     r12, r9                         ; r12 = FVector* location

    ; SpawnActor<AFortPickup>(Location, Pawn)
    ; Get AFortPickup class
    mov     rax, QWORD PTR [pClass_AFortPickup_C]
    test    rax, rax
    jnz     @@have_cls
    lea     rcx, szClass_AFortPickup
    call    SDK_FindClass
    mov     QWORD PTR [pClass_AFortPickup_C], rax
@@have_cls:
    test    rax, rax
    jz      @@null

    mov     rcx, rax                        ; ActorClass = AFortPickup
    mov     rdx, r12                        ; pLocation
    mov     r8, rbx                         ; Owner = Pawn
    call    Spawners_SpawnActor
    test    rax, rax
    jz      @@null
    mov     rbp, rax                        ; rbp = FortPickup*

    ; Set bReplicates = true (bitfield: byte at 0x82, bit 6 = 0x40)
    or      BYTE PTR [rbp + 082h], 040h

    ; PrimaryPickupItemEntry.Count = Count
    mov     DWORD PTR [rbp + AFPICKUP_PrimaryPickupItemEntry + FITE_Count], edi

    ; PrimaryPickupItemEntry.ItemDefinition = ItemDef
    mov     QWORD PTR [rbp + AFPICKUP_PrimaryPickupItemEntry + FITE_ItemDefinition], rsi

    ; OnRep_PrimaryPickupItemEntry()
    mov     rax, QWORD PTR [pFn_OnRep_PrimaryPE]
    test    rax, rax
    jnz     @@have_onrep_pe
    lea     rcx, pFn_OnRep_PrimaryPE
    lea     rdx, szFn_OnRep_PrimaryPE
    call    Spawners__LoadFn
@@have_onrep_pe:
    test    rax, rax
    jz      @@skip_onrep_pe
    mov     rcx, rbp
    mov     rdx, rax
    lea     r8, [rsp+32]
    call    QWORD PTR [ProcessEvent]
@@skip_onrep_pe:

    ; TossPickup(Location, Pawn, 6, true)
    mov     rax, QWORD PTR [pFn_TossPickup]
    test    rax, rax
    jnz     @@have_toss
    lea     rcx, pFn_TossPickup
    lea     rdx, szFn_TossPickup
    call    Spawners__LoadFn
@@have_toss:
    test    rax, rax
    jz      @@skip_toss

    ; Build TossPickup params on stack at [rsp+32] (0x20 bytes)
    xor     ecx, ecx
    mov     QWORD PTR [rsp+32],    rcx
    mov     QWORD PTR [rsp+40],    rcx
    mov     QWORD PTR [rsp+48],    rcx

    ; FVector FinalLocation = *pLocation (or 0,0,0 if null)
    test    r12, r12
    jz      @@toss_zero_loc
    mov     ecx, DWORD PTR [r12]
    mov     DWORD PTR [rsp+32], ecx         ; X
    mov     ecx, DWORD PTR [r12+4]
    mov     DWORD PTR [rsp+36], ecx         ; Y
    mov     ecx, DWORD PTR [r12+8]
    mov     DWORD PTR [rsp+40], ecx         ; Z
@@toss_zero_loc:
    ; Pad at [rsp+44] = 0 already
    mov     QWORD PTR [rsp+48], rbx         ; ItemOwner = Pawn (at +0x10)
    ; +0x0C = 4 pad bytes = rsp+44..rsp+47
    ; +0x10 = AFortPawn* ItemOwner = rsp+48..rsp+55  <- stored above 
    mov     DWORD PTR [rsp+56], 6           ; OverrideMaxStackCount = 6 (at +0x18)
    mov     BYTE PTR  [rsp+60], 1           ; bToss = true (at +0x1C)

    mov     rdx, rax                        ; fn
    mov     rcx, rbp                        ; this = FortPickup
    lea     r8, [rsp+32]
    call    QWORD PTR [ProcessEvent]
@@skip_toss:

    mov     rax, rbp
    jmp     @@done
@@null:
    xor     eax, eax
@@done:
    add     rsp, 50h
    pop     r12
    pop     rdi
    pop     rsi
    pop     rbx
    pop     rbp
    ret
Spawners_SummonPickup ENDP

; void Spawners_SummonPickupFromChest(UFortWorldItemDefinition* ItemDef,
;                                     DWORD Count, FVector* pLocation)
; RCX = ItemDef, RDX = Count, R8 = FVector* location
; Frame: 4 pushes + sub 38h -> 8 mod16 
Spawners_SummonPickupFromChest PROC
    push    rbp
    push    rbx
    push    rsi
    push    rdi
    sub     rsp, 38h

    mov     rbx, rcx                        ; ItemDef
    mov     esi, edx                        ; Count
    mov     rdi, r8                         ; FVector*

    ; Get AFortPickup class
    mov     rax, QWORD PTR [pClass_AFortPickup_C]
    test    rax, rax
    jnz     @@have_cls
    lea     rcx, szClass_AFortPickup
    call    SDK_FindClass
    mov     QWORD PTR [pClass_AFortPickup_C], rax
@@have_cls:
    test    rax, rax
    jz      @@done

    mov     rcx, rax
    mov     rdx, rdi                        ; location
    xor     r8, r8                          ; Owner = null
    call    Spawners_SpawnActor
    test    rax, rax
    jz      @@done
    mov     rbp, rax                        ; FortPickup*

    ; bReplicates = true
    or      BYTE PTR [rbp + 082h], 040h

    ; bTossedFromContainer = true
    mov     BYTE PTR [rbp + AFPICKUP_bTossedFromContainer], 1

    ; PrimaryPickupItemEntry.Count, ItemDefinition
    mov     DWORD PTR [rbp + AFPICKUP_PrimaryPickupItemEntry + FITE_Count], esi
    mov     QWORD PTR [rbp + AFPICKUP_PrimaryPickupItemEntry + FITE_ItemDefinition], rbx

    ; OnRep_PrimaryPickupItemEntry()
    mov     rax, QWORD PTR [pFn_OnRep_PrimaryPE]
    test    rax, rax
    jz      @@skip_pe
    lea     rcx, [rsp+32]
    ; rcx should be FortPickup
    mov     rcx, rbp
    mov     rdx, rax
    lea     r8, [rsp+32]
    call    QWORD PTR [ProcessEvent]
@@skip_pe:

    ; OnRep_TossedFromContainer()
    mov     rax, QWORD PTR [pFn_OnRep_TossedFrCont]
    test    rax, rax
    jnz     @@have_tc
    lea     rcx, pFn_OnRep_TossedFrCont
    lea     rdx, szFn_OnRep_TossedFrCont
    call    Spawners__LoadFn
@@have_tc:
    test    rax, rax
    jz      @@done
    mov     rcx, rbp
    mov     rdx, rax
    lea     r8, [rsp+32]
    call    QWORD PTR [ProcessEvent]

@@done:
    add     rsp, 38h
    pop     rdi
    pop     rsi
    pop     rbx
    pop     rbp
    ret
Spawners_SummonPickupFromChest ENDP

; void Spawners_SpawnPickupFromFloor(UFortWorldItemDefinition* ItemDef,
;                                    DWORD Count, FVector* pLocation)
; Frame: 4 pushes + sub 38h
Spawners_SpawnPickupFromFloor PROC
    push    rbp
    push    rbx
    push    rsi
    push    rdi
    sub     rsp, 38h

    mov     rbx, rcx
    mov     esi, edx
    mov     rdi, r8

    mov     rax, QWORD PTR [pClass_AFortPickup_C]
    test    rax, rax
    jnz     @@have_cls
    lea     rcx, szClass_AFortPickup
    call    SDK_FindClass
    mov     QWORD PTR [pClass_AFortPickup_C], rax
@@have_cls:
    test    rax, rax
    jz      @@done

    mov     rcx, rax
    mov     rdx, rdi
    xor     r8, r8
    call    Spawners_SpawnActor
    test    rax, rax
    jz      @@done
    mov     rbp, rax

    or      BYTE PTR [rbp + 082h], 040h
    mov     DWORD PTR [rbp + AFPICKUP_PrimaryPickupItemEntry + FITE_Count], esi
    mov     QWORD PTR [rbp + AFPICKUP_PrimaryPickupItemEntry + FITE_ItemDefinition], rbx

    mov     rax, QWORD PTR [pFn_OnRep_PrimaryPE]
    test    rax, rax
    jz      @@done
    mov     rcx, rbp
    mov     rdx, rax
    lea     r8, [rsp+32]
    call    QWORD PTR [ProcessEvent]

@@done:
    add     rsp, 38h
    pop     rdi
    pop     rsi
    pop     rbx
    pop     rbp
    ret
Spawners_SpawnPickupFromFloor ENDP

; void Spawners_SpawnDeco(AFortDecoTool* Tool,
;                         AFortDecoTool_ServerSpawnDeco_Params* pParams)
; RCX = Tool, RDX = pParams
;
; Source: Spawners.h::SpawnDeco()
;
; pParams layout (AFortDecoTool_ServerSpawnDeco_Params):
;   +00: FRotator Rotation  (12 bytes)
;   +0C: 4 pad
;   +10: FVector Location   (12 bytes)
;   +1C: 4 pad
;   +20: ABuildingActor* AttachedActor (8 bytes)

; AFortDecoTool_ServerSpawnDeco_Params offsets
DECO_Rotation       EQU 000h   ; FRotator (12 bytes)
DECO_Location       EQU 010h   ; FVector (12 bytes) - after 4 pad
DECO_AttachedActor  EQU 020h   ; ABuildingActor*

; AFortDecoTool::ItemDefinition offset
ADECOTOOL_ItemDef   EQU 04E8h

; UFortTrapItemDefinition::GetBlueprintClass params: {UClass* ReturnValue}
; GetBlueprintClass params size = 8

; ABuildingTrap fields
ABTRAP_AbilitySet_offset EQU 0E20h   ; from Phase 2 findings (FN_FortniteGame_classes.hpp)
; Note: The C++ calls Trap->AbilitySet->GameplayAbilities[i]
; ABuildingActor::AbilitySet at 0x0E20, UFortAbilitySet::GameplayAbilities TArray at +0x38

Spawners_SpawnDeco PROC
    push    rbp
    push    rbx
    push    rsi
    push    rdi
    push    r12
    push    r13
    push    r14
    sub     rsp, 70h

    test    rcx, rcx
    jz      @@done
    test    rdx, rdx
    jz      @@done

    mov     r12, rcx                        ; r12 = Tool (AFortDecoTool*)
    mov     r13, rdx                        ; r13 = pParams

    ; ItemDef = Tool->ItemDefinition (UFortTrapItemDefinition*)
    mov     r14, QWORD PTR [r12 + ADECOTOOL_ItemDef]
    test    r14, r14
    jz      @@done

    ; Build FTransform from Params:
    ;  Rotation (FQuat via RotToQuat) + Translation (Location) + Scale (1,1,1)
    ; FTransform at [rsp+32] (0x30 bytes):
    lea     rcx, [rsp+32]                   ; &FQuat output (first 16 bytes of transform)
    lea     rdx, [r13 + DECO_Rotation]      ; &FRotator input
    call    Utils_RotToQuat

    ; Translation = Location
    mov     eax, DWORD PTR [r13 + DECO_Location]
    mov     DWORD PTR [rsp + 32 + 10h], eax  ; X
    mov     eax, DWORD PTR [r13 + DECO_Location + 4]
    mov     DWORD PTR [rsp + 32 + 14h], eax  ; Y
    mov     eax, DWORD PTR [r13 + DECO_Location + 8]
    mov     DWORD PTR [rsp + 32 + 18h], eax  ; Z

    ; Scale3D = (1,1,1)
    mov     eax, 3F800000h
    mov     DWORD PTR [rsp + 32 + 20h], eax
    mov     DWORD PTR [rsp + 32 + 24h], eax
    mov     DWORD PTR [rsp + 32 + 28h], eax

    ; Get blueprint class from TrapItemDefinition
    ; Call GetBlueprintClass via ProcessEvent
    mov     rax, QWORD PTR [pFn_GetBlueprintClass]
    test    rax, rax
    jnz     @@have_gbc
    lea     rcx, pFn_GetBlueprintClass
    lea     rdx, szFn_GetBlueprintClass
    call    Spawners__LoadFn
@@have_gbc:
    test    rax, rax
    jz      @@done

    ; GetBlueprintClass params: {UClass* ReturnValue} (8 bytes at [rsp+80])
    xor     rbp, rbp
    mov     QWORD PTR [rsp+80], rbp         ; ReturnValue = null
    mov     rcx, r14                        ; this = TrapItemDef
    mov     rdx, rax
    lea     r8, [rsp+80]
    call    QWORD PTR [ProcessEvent]

    mov     rbx, QWORD PTR [rsp+80]         ; rbx = Trap UClass*
    test    rbx, rbx
    jz      @@done

    ; SpawnActor(TrapClass, FTransform{rsp+32})
    mov     rcx, rbx                        ; ActorClass
    lea     rdx, [rsp + 32 + 10h]           ; Location = Translation part of transform
    xor     r8, r8
    call    Spawners_SpawnActor
    test    rax, rax
    jz      @@done
    mov     rbp, rax                        ; rbp = Trap (ABuildingTrap*)

    ; Trap->TrapData = TrapDef
    mov     QWORD PTR [rbp + ABTRAP_TrapData], r14

    ; Get Pawn = Tool->Owner
    mov     rbx, QWORD PTR [r12 + 0108h]   ; AActor::Owner at 0x108

    ; Trap->InitializeKismetSpawnedBuildingActor(Trap, PC)
    ; PC = Pawn->Controller
    mov     rsi, QWORD PTR [rbx + 0228h]   ; Pawn->Controller (AController*)
    ; PC = cast to AFortPlayerController

    mov     rax, QWORD PTR [pFn_InitKismetBuilding]
    test    rax, rax
    jnz     @@have_ikb
    lea     rcx, pFn_InitKismetBuilding
    lea     rdx, szFn_InitKismetBuilding
    call    Spawners__LoadFn
@@have_ikb:
    test    rax, rax
    jz      @@skip_init

    ; Params: {ABuildingActor* BuildingOwner, AFortPlayerController* SpawningController}
    mov     QWORD PTR [rsp+32], rbp         ; BuildingOwner = Trap itself
    mov     QWORD PTR [rsp+40], rsi         ; SpawningController
    mov     rcx, rbp
    mov     rdx, rax
    lea     r8, [rsp+32]
    call    QWORD PTR [ProcessEvent]
@@skip_init:

    ; Trap->AttachedTo = pParams->AttachedActor
    mov     rax, QWORD PTR [r13 + DECO_AttachedActor]
    mov     QWORD PTR [rbp + ABTRAP_AttachedTo], rax

    ; OnRep_AttachedTo()
    mov     rax, QWORD PTR [pFn_OnRep_AttachedTo]
    test    rax, rax
    jnz     @@have_rat
    lea     rcx, pFn_OnRep_AttachedTo
    lea     rdx, szFn_OnRep_AttachedTo
    call    Spawners__LoadFn
@@have_rat:
    test    rax, rax
    jz      @@skip_rat
    mov     rcx, rbp
    mov     rdx, rax
    lea     r8, [rsp+32]
    call    QWORD PTR [ProcessEvent]
@@skip_rat:

    ; Trap->Team = PlayerState->TeamIndex
    ; PlayerState at Controller + 0x248 (ACONTROLLER_PlayerState)
    mov     rdi, QWORD PTR [rsi + 0248h]   ; PlayerState
    test    rdi, rdi
    jz      @@skip_team
    movzx   eax, BYTE PTR [rdi + 0F60h]    ; AFortPlayerStateAthena::TeamIndex
    mov     BYTE PTR [rbp + ABTRAP_Team], al
@@skip_team:

    ; Apply abilities from AbilitySet
    ; Trap->AbilitySet at ABTRAP_AbilitySet_offset = 0x0E20
    mov     r14, QWORD PTR [rbp + ABTRAP_AbilitySet_offset]
    test    r14, r14
    jz      @@done

    ; AbilitySet->GameplayAbilities (TArray<UClass*>) at +0x38
    mov     rsi, QWORD PTR [r14 + UFAS_GameplayAbilities]      ; Data
    mov     edi, DWORD PTR [r14 + UFAS_GameplayAbilities + 8]  ; Num
    test    rsi, rsi
    jz      @@done
    xor     r13d, r13d                      ; i = 0
@@ability_loop:
    cmp     r13d, edi
    jge     @@done
    mov     rax, QWORD PTR [rsi + r13*8]
    test    rax, rax
    jz      @@next_ability
    ; Pawn = rbx
    mov     rcx, rbx
    mov     rdx, rax
    call    Abilities_GrantGameplayAbility
@@next_ability:
    inc     r13d
    jmp     @@ability_loop

@@done:
    add     rsp, 70h
    pop     r14
    pop     r13
    pop     r12
    pop     rdi
    pop     rsi
    pop     rbx
    pop     rbp
    ret
Spawners_SpawnDeco ENDP

; Spawners_SpawnActor_ByLocation
; In : RCX = UClass* (actor class)
;      RDX = FVector* (location)
;      R8  = FRotator* (rotation - ignored; identity used)
;      R9  = AActor* (owner)
; Out: RAX = spawned AActor* or NULL
;
; Thin wrapper: moves Owner from R9 to R8, calls Spawners_SpawnActor.
Spawners_SpawnActor_ByLocation PROC
    mov     r8, r9
    jmp     Spawners_SpawnActor
Spawners_SpawnActor_ByLocation ENDP


END