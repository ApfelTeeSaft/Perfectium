; Primitive Math Structs

FVector STRUCT
    X   REAL4   ?
    Y   REAL4   ?
    Z   REAL4   ?
FVector ENDS                    ; 0x0C bytes

FVector2D STRUCT
    X   REAL4   ?
    Y   REAL4   ?
FVector2D ENDS                  ; 0x08 bytes

FRotator STRUCT
    Pitch   REAL4   ?
    Yaw     REAL4   ?
    Roll    REAL4   ?
FRotator ENDS                   ; 0x0C bytes

; FQuat is 16-byte aligned in UE4 (alignas(16))
FQuat STRUCT 16
    X   REAL4   ?
    Y   REAL4   ?
    Z   REAL4   ?
    W   REAL4   ?
FQuat ENDS                      ; 0x10 bytes

; FTransform: FQuat(0x10) + FVector(0x0C) + pad4 + FVector(0x0C) + pad4 = 0x30
FTransform STRUCT 16
    Rotation    FQuat   <>
    Translation FVector <>
    _pad0       DWORD   ?
    Scale3D     FVector <>
    _pad1       DWORD   ?
FTransform ENDS                 ; 0x30 bytes

; Core UE4 Structs

FName STRUCT
    ComparisonIndex DWORD   ?
    Number          DWORD   ?
FName ENDS                      ; 0x08 bytes

FGuid STRUCT
    A   DWORD   ?
    B   DWORD   ?
    C   DWORD   ?
    D   DWORD   ?
FGuid ENDS                      ; 0x10 bytes

; Generic TArray header
TArrayHeader STRUCT
    Data    QWORD   ?   ; T* pointer
    Num     DWORD   ?   ; element count
    Max     DWORD   ?   ; allocated capacity
TArrayHeader ENDS               ; 0x10 bytes

; FString = TArray<wchar_t>
FString STRUCT
    Data    QWORD   ?   ; wchar_t* pointer
    Num     DWORD   ?   ; character count (includes null)
    Max     DWORD   ?   ; allocated capacity
FString ENDS                    ; 0x10 bytes

; FText: opaque 0x18 bytes (shared data pointer internally)
FText STRUCT
    _opaque BYTE    24 DUP (?)
FText ENDS                      ; 0x18 bytes

FWeakObjectPtr STRUCT
    ObjectIndex         DWORD   ?
    ObjectSerialNumber  DWORD   ?
FWeakObjectPtr ENDS             ; 0x08 bytes

; FObjectKey has identical layout to FWeakObjectPtr
FObjectKey STRUCT
    ObjectIndex         DWORD   ?
    ObjectSerialNumber  DWORD   ?
FObjectKey ENDS                 ; 0x08 bytes

; Gameplay Tags

FGameplayTag STRUCT
    TagName FName   <>
FGameplayTag ENDS               ; 0x08 bytes

FGameplayTagContainer STRUCT
    GameplayTags    TArrayHeader    <>  ; TArray<FGameplayTag> +0x00
    ParentTags      TArrayHeader    <>  ; TArray<FGameplayTag> +0x10
FGameplayTagContainer ENDS      ; 0x20 bytes

; Network Structs

; FURL: total 0x70
FURL STRUCT
    Protocol    FString         <>  ; +0x00
    Host        FString         <>  ; +0x10
    Port        DWORD           ?   ; +0x20
    _pad0       DWORD           ?   ; +0x24
    Map         FString         <>  ; +0x28
    RedirectUrl FString         <>  ; +0x38
    Op          TArrayHeader    <>  ; +0x48  TArray<FString>
    Portal      FString         <>  ; +0x58
    Valid       DWORD           ?   ; +0x68
    _pad1       DWORD           ?   ; +0x6C
FURL ENDS                       ; 0x70 bytes

; FUniqueNetIdRepl: total 0x28
FUniqueNetIdRepl STRUCT
    _wrapper_opaque     BYTE            24 DUP (?)  ; +0x00  (base+unknown 0x18 bytes)
    ReplicationBytes    TArrayHeader    <>           ; +0x18  TArray<BYTE>
FUniqueNetIdRepl ENDS           ; 0x28 bytes

; Gameplay Ability System Structs

FGameplayAbilitySpecHandle STRUCT
    Handle  DWORD   ?
FGameplayAbilitySpecHandle ENDS ; 0x04 bytes

; FPredictionKey: total 0x18
FPredictionKey STRUCT
    Current             WORD    ?           ; +0x00
    Base                WORD    ?           ; +0x02
    _pad0               DWORD   ?           ; +0x04
    PackageMap          QWORD   ?           ; +0x08  UPackageMap*
    bIsStale            BYTE    ?           ; +0x10
    bIsServerInitiated  BYTE    ?           ; +0x11
    _pad1               BYTE    6 DUP (?)  ; +0x12
FPredictionKey ENDS             ; 0x18 bytes

; FGameplayAbilityActivationInfo: total 0x20
FGameplayAbilityActivationInfo STRUCT
    ActivationMode  BYTE            ?           ; +0x00
    _bitfield       BYTE            ?           ; +0x01
    _pad            BYTE            6 DUP (?)  ; +0x02
    PredKey         FPredictionKey  <>          ; +0x08
FGameplayAbilityActivationInfo ENDS ; 0x20 bytes

; FGameplayAbilitySpec: total 0xC8 (base FFastArraySerializerItem=0x0C)
FGameplayAbilitySpec STRUCT
    _base               BYTE                            12 DUP (?)  ; +0x00  FFastArraySerializerItem
    Handle              FGameplayAbilitySpecHandle      <>           ; +0x0C
    Ability             QWORD                           ?            ; +0x10  UGameplayAbility*
    Level               DWORD                           ?            ; +0x18
    InputID             DWORD                           ?            ; +0x1C
    SourceObject        QWORD                           ?            ; +0x20  UObject*
    ActiveCount         BYTE                            ?            ; +0x28
    _bitfield           BYTE                            ?            ; +0x29 (InputPressed etc.)
    _pad0               BYTE                            6 DUP (?)   ; +0x2A
    ActivationInfo      FGameplayAbilityActivationInfo  <>           ; +0x30
    NonReplInstances    TArrayHeader                    <>           ; +0x50
    ReplInstances       TArrayHeader                    <>           ; +0x60
    GEHandle            QWORD                           ?            ; +0x70 (FActiveGameplayEffectHandle partial)
    _tail               BYTE                            80 DUP (?)  ; +0x78
FGameplayAbilitySpec ENDS       ; 0xC8 bytes

; FGameplayAbilityRepAnimMontage: total 0x30
FGameplayAbilityRepAnimMontage STRUCT
    AnimMontage     QWORD           ?           ; +0x00  UAnimMontage*
    PlayRate        REAL4           ?           ; +0x08
    Position        REAL4           ?           ; +0x0C
    BlendTime       REAL4           ?           ; +0x10
    NextSectionID   BYTE            ?           ; +0x14
    _bitfield       BYTE            ?           ; +0x15  IsStopped/ForcePlayBit/SkipPos
    _pad            WORD            ?           ; +0x16
    PredictionKey   FPredictionKey  <>          ; +0x18
FGameplayAbilityRepAnimMontage ENDS ; 0x30 bytes

; FGameplayAbilityLocalAnimMontage: total 0x30
FGameplayAbilityLocalAnimMontage STRUCT
    AnimMontage     QWORD           ?           ; +0x00  UAnimMontage*
    PlayBit         BYTE            ?           ; +0x08
    _pad            BYTE            7 DUP (?)  ; +0x09
    PredictionKey   FPredictionKey  <>          ; +0x10
    AnimatingAbility QWORD          ?           ; +0x28  UGameplayAbility*
FGameplayAbilityLocalAnimMontage ENDS ; 0x30 bytes

; FGameplayEventData: total 0xA8
FGameplayEventData STRUCT
    EventTag        FGameplayTag        <>          ; +0x00
    Instigator      QWORD               ?           ; +0x08  AActor*
    Target          QWORD               ?           ; +0x10  AActor*
    OptionalObject  QWORD               ?           ; +0x18  UObject*
    OptionalObject2 QWORD               ?           ; +0x20  UObject*
    ContextHandle   BYTE                24 DUP (?)  ; +0x28  FGameplayEffectContextHandle (opaque)
    InstigatorTags  FGameplayTagContainer <>         ; +0x40
    TargetTags      FGameplayTagContainer <>         ; +0x60
    EventMagnitude  REAL4               ?           ; +0x80
    _pad            DWORD               ?           ; +0x84
    TargetData      BYTE                32 DUP (?)  ; +0x88  FGameplayAbilityTargetDataHandle (opaque)
FGameplayEventData ENDS         ; 0xA8 bytes

; Fortnite-Specific Structs

; FDeathInfo: total 0x20
FDeathInfo STRUCT
    FinisherOrDowner    QWORD   ?           ; +0x00  AFortPlayerStateAthena*
    bDBNO               BYTE    ?           ; +0x08
    DeathCause          BYTE    ?           ; +0x09  EDeathCause
    _pad0               WORD    ?           ; +0x0A
    Distance            REAL4   ?           ; +0x0C
    DeathLocation       FVector <>          ; +0x10
    _pad1               DWORD   ?           ; +0x1C
FDeathInfo ENDS                 ; 0x20 bytes

; FFortPlayerDeathReport: total 0x50
FFortPlayerDeathReport STRUCT
    ServerTimeForRespawn    REAL4               ?           ; +0x00
    ServerTimeForResurrect  REAL4               ?           ; +0x04
    LethalDamage            REAL4               ?           ; +0x08
    _pad                    DWORD               ?           ; +0x0C
    KillerPlayerState       QWORD               ?           ; +0x10  AFortPlayerState*
    KillerPawn              QWORD               ?           ; +0x18  AFortPawn*
    DamageCauser            QWORD               ?           ; +0x20  AActor*
    _bitfield               BYTE                ?           ; +0x28  bDropped/bNotifyUI
    _pad2                   BYTE                7 DUP (?)  ; +0x29
    Tags                    FGameplayTagContainer <>         ; +0x30
FFortPlayerDeathReport ENDS     ; 0x50 bytes

; FAircraftFlightInfo / FFlightInfo: total 0x28
FAircraftFlightInfo STRUCT
    FlightStartLocation BYTE    12 DUP (?)  ; +0x00  FVector_NetQuantize100 (same as FVector layout)
    FlightStartRotation FRotator <>         ; +0x0C
    FlightSpeed         REAL4   ?           ; +0x18
    TimeTillFlightEnd   REAL4   ?           ; +0x1C
    TimeTillDropStart   REAL4   ?           ; +0x20
    TimeTillDropEnd     REAL4   ?           ; +0x24
FAircraftFlightInfo ENDS        ; 0x28 bytes

; FQuickBarSlot: total 0x18
FQuickBarSlot STRUCT
    Items       TArrayHeader    <>          ; +0x00  TArray<FGuid>
    bEnabled    BYTE            ?           ; +0x10
    _pad        BYTE            7 DUP (?)  ; +0x11
FQuickBarSlot ENDS              ; 0x18 bytes

; FQuickBar: total 0x90
FQuickBar STRUCT
    CurrentFocusedSlot      DWORD           ?           ; +0x00
    PreviousFocusedSlot     DWORD           ?           ; +0x04
    SecondaryFocusedSlot    DWORD           ?           ; +0x08
    _pad                    DWORD           ?           ; +0x0C
    Slots                   TArrayHeader    <>          ; +0x10  TArray<FQuickBarSlot>
    DataDefinition          BYTE            16 DUP (?)  ; +0x20  FQuickBarData (opaque 0x10)
    _unknown                BYTE            80 DUP (?)  ; +0x30  EquippedItemDefinitions set
    SharedVisibleSlotIdx    TArrayHeader    <>          ; +0x80  TArray<int>
FQuickBar ENDS                  ; 0x90 bytes

; FFortItemEntry: total 0xC8 (base FFastArraySerializerItem=0x0C)
FFortItemEntry STRUCT
    _base               BYTE            12 DUP (?)  ; +0x00  FFastArraySerializerItem
    Count               DWORD           ?           ; +0x0C
    PreviousCount       DWORD           ?           ; +0x10
    _pad0               DWORD           ?           ; +0x14
    ItemDefinition      QWORD           ?           ; +0x18  UFortItemDefinition*
    Durability          REAL4           ?           ; +0x20
    Level               DWORD           ?           ; +0x24
    LoadedAmmo          DWORD           ?           ; +0x28
    _pad1               DWORD           ?           ; +0x2C
    AlterationDefinitions TArrayHeader  <>          ; +0x30
    ItemSource          FString         <>          ; +0x40
    ItemGuid            FGuid           <>          ; +0x50
    _bool0              BYTE            ?           ; +0x60  inventory_overflow_date
    bIsReplicatedCopy   BYTE            ?           ; +0x61
    bIsDirty            BYTE            ?           ; +0x62
    _pad2               BYTE            5 DUP (?)  ; +0x63
    GiftingInfo         BYTE            40 DUP (?)  ; +0x68  FFortGiftingInfo (opaque 0x28)
    StateValues         TArrayHeader    <>          ; +0x90
    ParentInventory     FWeakObjectPtr  <>          ; +0xA0
    GASpecHandle        DWORD           ?           ; +0xA8  FGameplayAbilitySpecHandle
    _pad3               DWORD           ?           ; +0xAC
    AlterationInstances TArrayHeader    <>          ; +0xB0
    GenericAttrValue    REAL4           ?           ; +0xC0
    _pad4               DWORD           ?           ; +0xC4
FFortItemEntry ENDS             ; 0xC8 bytes

; FFortItemList: total 0x170 (base FFastArraySerializer=0xB0)
FFortItemList STRUCT
    _base               BYTE            176 DUP (?)  ; +0x00  FFastArraySerializer (0xB0)
    ReplicatedEntries   TArrayHeader    <>            ; +0xB0  TArray<FFortItemEntry>
    _unknown0           BYTE            80 DUP (?)   ; +0xC0
    ItemInstances       TArrayHeader    <>            ; +0x110 TArray<UFortWorldItem*>
    _unknown1           BYTE            80 DUP (?)   ; +0x120
FFortItemList ENDS              ; 0x170 bytes

; Field Offset Constants

; UObject field offsets (base 0x0028 already past vtable)
UOBJECT_Flags           EQU 00Ch    ; int32  (from UObject base +0x0C, but struct starts at 0 here)
UOBJECT_InternalIndex   EQU 010h
UOBJECT_Class           EQU 018h
UOBJECT_Name            EQU 020h    ; FName
UOBJECT_Outer           EQU 028h

; UFunction field offsets (UObject base = 0x28 → UField 0x30 → UStruct 0x80 → UFunction 0x70 more)
UFUNC_FunctionFlags     EQU 0D0h
UFUNC_NumParms          EQU 0D6h
UFUNC_ParmsSize         EQU 0D8h
UFUNC_Func              EQU 0B0h    ; native func ptr at UFunction+0xB0 (0x28 obj + 0x88 struct header)

; TUObjectArray offsets
TUOBJECTARRAY_Objects   EQU 000h    ; uint8* flat array
TUOBJECTARRAY_MaxElem   EQU 008h    ; uint32
TUOBJECTARRAY_NumElem   EQU 00Ch    ; uint32
TUOBJECTARRAY_STRIDE    EQU 024     ; 24 bytes per slot

; UNetDriver offsets
UNETDRIVER_ServerConn   EQU 078h
UNETDRIVER_ClientConns  EQU 080h    ; TArray<UNetConnection*>
UNETDRIVER_World        EQU 0B8h
UNETDRIVER_ReplDriver   EQU 500h

; UNetConnection offsets
UNETCONN_Driver         EQU 058h
UNETCONN_ViewTarget     EQU 090h
UNETCONN_OwningActor    EQU 098h

; AActor offsets
AACTOR_RemoteRole       EQU 085h
AACTOR_RepMovement      EQU 088h
AACTOR_Owner            EQU 108h
AACTOR_Role             EQU 118h
AACTOR_Instigator       EQU 140h
AACTOR_Children         EQU 148h    ; TArray<AActor*>
AACTOR_RootComponent    EQU 158h

; AFortPlayerControllerAthena offsets (in parent chain)
AFPC_QuickBars          EQU 1C38h
AFPC_WorldInventory     EQU 1ED8h
AFPC_OutpostInventory   EQU 1EE0h
AFPCA_bClientNotifiedOfWin EQU 2BE4h
AFPCA_WarmupPlayerStart EQU 3198h

; AFortPlayerState offsets
AFPS_bHasFinishedLoading EQU 4E0h   ; bit2 in uint8
AFPS_bHasStartedPlaying  EQU 4E0h   ; bit3 in uint8
AFPS_HeroType           EQU 528h
AFPS_CharacterGender    EQU 7F0h
AFPS_CharacterBodyType  EQU 7F1h
AFPS_CharacterParts     EQU 7F8h    ; UCustomCharacterPart*[6] = 0x30 bytes
AFPS_PlayerTeam         EQU 8F0h
AFPS_AbilitySysComp     EQU 0B88h

; AFortPlayerStateAthena offsets
AFPSA_DeathInfo         EQU 0F40h
AFPSA_TeamIndex         EQU 0F60h
AFPSA_KillScore         EQU 0F68h
AFPSA_TeamKillScore     EQU 0F6Ch
AFPSA_SquadId           EQU 10F0h
AFPSA_bIsDisconnected   EQU 1674h

; AFortGameModeAthena offsets
AFGMA_bAlwaysDBNO       EQU 8E0h
AFGMA_bSafeZoneActive   EQU 0B04h
AFGMA_bSafeZonePaused   EQU 0B05h
AFGMA_SafeZonePhase     EQU 0B20h
AFGMA_SafeZoneIndicator EQU 0B28h
AFGMA_SafeZoneLocations EQU 0B30h   ; TArray<FVector>
AFGMA_bAllowSpectate    EQU 0B68h
AFGMA_AlivePlayers      EQU 950h    ; TArray<AFortPlayerControllerAthena*>

; AFortGameStateAthena offsets
AFGSA_WarmupCDStart     EQU 14F0h
AFGSA_WarmupCDEnd       EQU 14F4h
AFGSA_AircraftStartTime EQU 14F8h
AFGSA_SafeZoneStartTime EQU 14FCh
AFGSA_TotalPlayers      EQU 1508h
AFGSA_PlayersLeft       EQU 150Ch
AFGSA_WinningPlayerName EQU 1588h
AFGSA_SafeZoneIndicator EQU 15F0h
AFGSA_GamePhase         EQU 1B98h
AFGSA_CurrentPlaylist   EQU 1BA0h
AFGSA_bSkipAircraft     EQU 1BA8h
AFGSA_SafeZonePhase     EQU 1BA9h
AFGSA_Aircrafts         EQU 1BB8h   ; TArray<AFortAthenaAircraft*>

; AFortInventory offsets
AFINV_InventoryType     EQU 320h
AFINV_Inventory         EQU 328h    ; FFortItemList
AFINV_bRequiresLocalUpdate EQU 498h
AFINV_PendingInstances  EQU 4B0h

; AFortQuickBars offsets
AFQB_PrimaryQuickBar    EQU 318h    ; FQuickBar (0x90)
AFQB_SecondaryQuickBar  EQU 438h    ; FQuickBar (0x90)

; UFortWorldItem offsets
UFWI_bIsTemporaryItem   EQU 1D0h
UFWI_OwnerInventory     EQU 1D8h
UFWI_ItemEntry          EQU 1E0h    ; FFortItemEntry (0xC8)

; AFortPickup offsets
AFPU_bRandomRotation    EQU 348h
AFPU_PrimaryPickupItemEntry EQU 350h  ; FFortItemEntry
AFPU_bPickedUp          EQU 4C0h
AFPU_PawnWhoDroppedPickup EQU 4C8h

; AFortAthenaAircraft offsets
AFAA_ExitLocation       EQU 384h    ; FVector
AFAA_FlightInfo         EQU 390h    ; FAircraftFlightInfo (0x28)
AFAA_FlightStartTime    EQU 3B8h

; UAbilitySystemComponent offsets
UASC_ActivatableAbilities EQU 470h  ; FGameplayAbilitySpecContainer
UASC_AllReplInstAbils     EQU 588h  ; TArray<UGameplayAbility*>
UASC_RepAnimMontageInfo   EQU 0AF0h ; FGameplayAbilityRepAnimMontage
UASC_LocalAnimMontageInfo EQU 0B28h ; FGameplayAbilityLocalAnimMontage

; FGameplayAbilitySpecContainer: Items TArray at +0xB0 (base FFastArraySerializer=0xB0)
GASC_Items              EQU 0B0h

; ClassRepNodePolicies raw offset on UReplicationDriver
REPDRIVER_ClassRepPolicies EQU 3B8h ; TMap<FObjectKey, EClassRepNodeMapping>
