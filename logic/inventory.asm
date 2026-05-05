INCLUDE asm\include\master.inc

; AFortPlayerController offsets
PC_WorldInventory       EQU 1ED8h
PC_QuickBars            EQU 1C38h

; AFortInventory offsets
AFI_Inventory           EQU 0328h
AFI_bRequiresLocalUpdate EQU 0498h

; Within AFortInventory: FFortItemList field absolutes
AFI_ReplicatedEntries   EQU 03D8h   ; AFI+0x0328+0x00B0
AFI_ItemInstances       EQU 0438h   ; AFI+0x0328+0x0110

; AFortQuickBars offsets
QB_PrimarySlots         EQU 0328h   ; PrimaryQuickBar(+0x0318)+Slots(+0x10)
QB_SecondarySlots       EQU 0448h   ; SecondaryQuickBar(+0x0438)+Slots(+0x10)
QB_PriFocusedSlot       EQU 0318h   ; PrimaryQuickBar.CurrentFocusedSlot (int32)

; FQuickBarSlot size
QBSLOT_SIZE             EQU 018h
QBSLOT_Items            EQU 000h    ; TArray<FGuid> within slot

; UFortWorldItem offsets
UWI_OwnerInventory      EQU 01D8h
UWI_ItemEntry           EQU 01E0h   ; FFortItemEntry base
UWI_ItemEntry_Count     EQU 01ECh   ; +0x0C
UWI_ItemEntry_ItemDef   EQU 01F8h   ; +0x18
UWI_ItemEntry_LoadedAmmo EQU 0208h  ; +0x28
UWI_ItemEntry_ItemGuid  EQU 0230h   ; +0x50

; FFortItemEntry size
FITEM_SIZEOF            EQU 0C8h

; FGuid size
FGUID_SIZE              EQU 010h

; AFortWeapon offsets
FW_WeaponData           EQU 0368h
FW_ItemEntryGuid        EQU 0988h
FW_AmmoCount            EQU 099Ch

; EFortQuickBars enum values
QB_PRIMARY              EQU 0
QB_SECONDARY            EQU 1

; AController::PlayerState offset (for controller chain access)
ACTRL_Pawn              EQU 0260h

.const

; UFunction paths
sz_HandleInvLocalUpdate     BYTE "Function FortniteGame.FortInventory.HandleInventoryLocalUpdate",0
sz_ForceNetUpdate           BYTE "Function Engine.Actor.ForceNetUpdate",0
sz_HandleWorldInvLocalUpdate BYTE "Function FortniteGame.FortPlayerController.HandleWorldInventoryLocalUpdate",0
sz_OnRep_PrimaryQB          BYTE "Function FortniteGame.FortQuickBars.OnRep_PrimaryQuickBar",0
sz_OnRep_SecondaryQB        BYTE "Function FortniteGame.FortQuickBars.OnRep_SecondaryQuickBar",0
sz_ForceUpdateQB            BYTE "Function FortniteGame.FortPlayerController.ForceUpdateQuickbar",0
sz_ServerAddItemInternal    BYTE "Function FortniteGame.FortQuickBars.ServerAddItemInternal",0
sz_ServerRemoveItemInternal BYTE "Function FortniteGame.FortQuickBars.ServerRemoveItemInternal",0
sz_EmptySlot                BYTE "Function FortniteGame.FortQuickBars.EmptySlot",0
sz_ServerActivateSlotInt    BYTE "Function FortniteGame.FortQuickBars.ServerActivateSlotInternal",0
sz_OnRep_QuickBar           BYTE "Function FortniteGame.FortPlayerController.OnRep_QuickBar",0
sz_CreateTempItemBP         BYTE "Function FortniteGame.FortItemDefinition.CreateTemporaryItemInstanceBP",0
sz_SetOwningController      BYTE "Function FortniteGame.FortItem.SetOwningControllerForTemporaryItem",0
sz_EquipWeaponDef           BYTE "Function FortniteGame.FortPawn.EquipWeaponDefinition",0
sz_OnRep_WeaponData         BYTE "Function FortniteGame.FortWeapon.OnRep_ReplicatedWeaponData",0
sz_OnRep_AmmoCount          BYTE "Function FortniteGame.FortWeapon.OnRep_AmmoCount",0
sz_ClientGivenTo            BYTE "Function FortniteGame.FortWeapon.ClientGivenTo",0
sz_ClientInternalEquipWeapon BYTE "Function FortniteGame.FortPawn.ClientInternalEquipWeapon",0
sz_OnRep_CurrentWeapon      BYTE "Function FortniteGame.FortPawn.OnRep_CurrentWeapon",0
sz_SetOwner                 BYTE "Function Engine.Actor.SetOwner",0

; Class names for Init
sz_FortQuickBarsClass       BYTE "Class FortniteGame.FortQuickBars",0
sz_WallDef      BYTE "FortBuildingItemDefinition BuildingItemData_Wall.BuildingItemData_Wall",0
sz_FloorDef     BYTE "FortBuildingItemDefinition BuildingItemData_Floor.BuildingItemData_Floor",0
sz_StairDef     BYTE "FortBuildingItemDefinition BuildingItemData_Stair_W.BuildingItemData_Stair_W",0
sz_RoofDef      BYTE "FortBuildingItemDefinition BuildingItemData_RoofS.BuildingItemData_RoofS",0
sz_LaunchPad    BYTE "FortTrapItemDefinition TID_Floor_Player_Launch_Pad_Athena.TID_Floor_Player_Launch_Pad_Athena",0
sz_WallElectric BYTE "FortTrapItemDefinition TID_Wall_Electric_Athena_R_T03.TID_Wall_Electric_Athena_R_T03",0
sz_FloorSpikes  BYTE "FortTrapItemDefinition TID_Floor_Spikes_Athena_R_T03.TID_Floor_Spikes_Athena_R_T03",0
sz_Campfire     BYTE "FortTrapItemDefinition TID_Floor_Player_Campfire_Athena.TID_Floor_Player_Campfire_Athena",0
sz_Wood         BYTE "FortResourceItemDefinition WoodItemData.WoodItemData",0
sz_Stone        BYTE "FortResourceItemDefinition StoneItemData.StoneItemData",0
sz_Metal        BYTE "FortResourceItemDefinition MetalItemData.MetalItemData",0
sz_AmmoShells   BYTE "FortAmmoItemDefinition AthenaAmmoDataShells.AthenaAmmoDataShells",0
sz_AmmoEnergy   BYTE "FortAmmoItemDefinition AthenaAmmoDataEnergyCell.AthenaAmmoDataEnergyCell",0
sz_AmmoBulletsMedium BYTE "FortAmmoItemDefinition AthenaAmmoDataBulletsMedium.AthenaAmmoDataBulletsMedium",0
sz_AmmoBulletsLight  BYTE "FortAmmoItemDefinition AthenaAmmoDataBulletsLight.AthenaAmmoDataBulletsLight",0
sz_AmmoBulletsHeavy  BYTE "FortAmmoItemDefinition AthenaAmmoDataBulletsHeavy.AthenaAmmoDataBulletsHeavy",0
sz_AmmoRockets  BYTE "FortAmmoItemDefinition AmmoDataRockets.AmmoDataRockets",0
sz_EditTool     BYTE "FortEditToolItemDefinition EditTool.EditTool",0

.data?

; Cached UFunction pointers
fn_HandleInvLocalUpdate     QWORD ?
fn_ForceNetUpdate           QWORD ?
fn_HandleWorldInvLocalUpdate QWORD ?
fn_OnRep_PrimaryQB          QWORD ?
fn_OnRep_SecondaryQB        QWORD ?
fn_ForceUpdateQB            QWORD ?
fn_ServerAddItemInternal    QWORD ?
fn_ServerRemoveItemInternal QWORD ?
fn_EmptySlot                QWORD ?
fn_ServerActivateSlotInt    QWORD ?
fn_OnRep_QuickBar           QWORD ?
fn_CreateTempItemBP         QWORD ?
fn_SetOwningController      QWORD ?
fn_EquipWeaponDef           QWORD ?
fn_OnRep_WeaponData         QWORD ?
fn_OnRep_AmmoCount          QWORD ?
fn_ClientGivenTo            QWORD ?
fn_ClientInternalEquipWeapon QWORD ?
fn_OnRep_CurrentWeapon      QWORD ?
fn_SetOwner                 QWORD ?

; Cached item definitions for Init
def_Wall            QWORD ?
def_Floor           QWORD ?
def_Stair           QWORD ?
def_Roof            QWORD ?
def_LaunchPad       QWORD ?
def_WallElectric    QWORD ?
def_FloorSpikes     QWORD ?
def_Campfire        QWORD ?
def_Wood            QWORD ?
def_Stone           QWORD ?
def_Metal           QWORD ?
def_AmmoShells      QWORD ?
def_AmmoEnergy      QWORD ?
def_AmmoBullMedium  QWORD ?
def_AmmoBullLight   QWORD ?
def_AmmoBullHeavy   QWORD ?
def_AmmoRockets     QWORD ?
def_EditTool        QWORD ?

.code

; Internal helper: Inventory__LoadFn
; In : RSI = &cache QWORD
;      RDI = szPath (BYTE*)
; Out: RAX = UFunction* (may be NULL on lookup failure)
; Allocates shadow for SDK_FindObject call (entry RSP=8 -> CALL->0 ).
Inventory__LoadFn PROC
    mov     rax, QWORD PTR [rsi]
    test    rax, rax
    jnz     @ILF_done
    sub     rsp, 20h
    mov     rcx, rdi
    call    SDK_FindObject
    add     rsp, 20h
    mov     QWORD PTR [rsi], rax
@ILF_done:
    ret
Inventory__LoadFn ENDP


; Inventory_Update
; In : RCX = AFortPlayerControllerAthena*
;      EDX = Dirty (int, 0 = no mark-item-dirty)
;      R8B = bRemovedItem (bool)
;
; Fires replication notifications on inventory and quickbar.
;
; Stack: 5 pushes (40) + sub 80h (128) = 168; 8-168=-160=0 
;
; Frame:
;   [+00..+1F] shadow
;   [+20..+27] arg5 slot
;   [+28..+2F] zero-param scratch (empty ProcessEvent params)
;   [+30..+33] ForceUpdateQuickbar params (EFortQuickBars, BYTE->padded)
Inventory_Update PROC
    push    rbx
    push    rbp
    push    rsi
    push    rdi
    push    r12
    sub     rsp, 80h

    ; Save parameters in stable callee-saved registers
    mov     r12, rcx                    ; R12 = PC (callee-saved)
    mov     ebx, edx                    ; EBX = Dirty
    movzx   ebp, r8b                    ; EBP = bRemovedItem

    ; RSI/RDI will be used transiently for Inventory__LoadFn args;
    ; R12 persists across calls since r12 is callee-saved.

    mov     rdi, QWORD PTR [r12 + PC_WorldInventory]  ; WorldInventory
    test    rdi, rdi
    jz      @IU2_done

    ; bRequiresLocalUpdate = true
    mov     BYTE PTR [rdi + AFI_bRequiresLocalUpdate], 1

    ; HandleInventoryLocalUpdate
    lea     rsi, [fn_HandleInvLocalUpdate]
    lea     rdi, [sz_HandleInvLocalUpdate]
    call    Inventory__LoadFn
    mov     rdi, QWORD PTR [r12 + PC_WorldInventory]   ; reload after call
    test    rax, rax
    jz      @IU2_fnu
    xor     r8d, r8d
    mov     QWORD PTR [rsp + 28h], r8
    mov     rcx, rdi
    mov     rdx, rax
    lea     r8, [rsp + 28h]
    call    QWORD PTR [ProcessEvent]

@IU2_fnu:
    ; ForceNetUpdate on WorldInventory
    lea     rsi, [fn_ForceNetUpdate]
    lea     rdi, [sz_ForceNetUpdate]
    call    Inventory__LoadFn
    mov     rdi, QWORD PTR [r12 + PC_WorldInventory]
    test    rax, rax
    jz      @IU2_hwilu
    xor     r8d, r8d
    mov     QWORD PTR [rsp + 28h], r8
    mov     rcx, rdi
    mov     rdx, rax
    lea     r8, [rsp + 28h]
    call    QWORD PTR [ProcessEvent]

@IU2_hwilu:
    ; HandleWorldInventoryLocalUpdate on PC
    lea     rsi, [fn_HandleWorldInvLocalUpdate]
    lea     rdi, [sz_HandleWorldInvLocalUpdate]
    call    Inventory__LoadFn
    test    rax, rax
    jz      @IU2_priqb
    xor     r8d, r8d
    mov     QWORD PTR [rsp + 28h], r8
    mov     rcx, r12
    mov     rdx, rax
    lea     r8, [rsp + 28h]
    call    QWORD PTR [ProcessEvent]

@IU2_priqb:
    ; Get QuickBars
    mov     rdi, QWORD PTR [r12 + PC_QuickBars]
    test    rdi, rdi
    jz      @IU2_done

    ; OnRep_PrimaryQuickBar
    lea     rsi, [fn_OnRep_PrimaryQB]
    lea     rdi, [sz_OnRep_PrimaryQB]
    call    Inventory__LoadFn
    mov     rdi, QWORD PTR [r12 + PC_QuickBars]
    test    rax, rax
    jz      @IU2_secqb
    xor     r8d, r8d
    mov     QWORD PTR [rsp + 28h], r8
    mov     rcx, rdi
    mov     rdx, rax
    lea     r8, [rsp + 28h]
    call    QWORD PTR [ProcessEvent]

@IU2_secqb:
    ; OnRep_SecondaryQuickBar
    lea     rsi, [fn_OnRep_SecondaryQB]
    lea     rdi, [sz_OnRep_SecondaryQB]
    call    Inventory__LoadFn
    mov     rdi, QWORD PTR [r12 + PC_QuickBars]
    test    rax, rax
    jz      @IU2_fnu_qb
    xor     r8d, r8d
    mov     QWORD PTR [rsp + 28h], r8
    mov     rcx, rdi
    mov     rdx, rax
    lea     r8, [rsp + 28h]
    call    QWORD PTR [ProcessEvent]

@IU2_fnu_qb:
    ; ForceNetUpdate on QuickBars
    lea     rsi, [fn_ForceNetUpdate]
    lea     rdi, [sz_ForceNetUpdate]
    call    Inventory__LoadFn
    mov     rdi, QWORD PTR [r12 + PC_QuickBars]
    test    rax, rax
    jz      @IU2_fuqb_pri
    xor     r8d, r8d
    mov     QWORD PTR [rsp + 28h], r8
    mov     rcx, rdi
    mov     rdx, rax
    lea     r8, [rsp + 28h]
    call    QWORD PTR [ProcessEvent]

@IU2_fuqb_pri:
    ; ForceUpdateQuickbar(Primary=0)
    lea     rsi, [fn_ForceUpdateQB]
    lea     rdi, [sz_ForceUpdateQB]
    call    Inventory__LoadFn
    test    rax, rax
    jz      @IU2_fuqb_sec
    xor     r8d, r8d
    mov     DWORD PTR [rsp + 30h], r8d  ; EFortQuickBars = Primary = 0
    mov     rcx, r12
    mov     rdx, rax
    lea     r8, [rsp + 30h]
    call    QWORD PTR [ProcessEvent]

@IU2_fuqb_sec:
    ; ForceUpdateQuickbar(Secondary=1)
    lea     rsi, [fn_ForceUpdateQB]
    lea     rdi, [sz_ForceUpdateQB]
    call    Inventory__LoadFn
    test    rax, rax
    jz      @IU2_done
    mov     DWORD PTR [rsp + 30h], 1    ; EFortQuickBars = Secondary = 1
    mov     rcx, r12
    mov     rdx, rax
    lea     r8, [rsp + 30h]
    call    QWORD PTR [ProcessEvent]

@IU2_done:
    add     rsp, 80h
    pop     r12
    pop     rdi
    pop     rsi
    pop     rbp
    pop     rbx
    ret
Inventory_Update ENDP


; Inventory_IsGuidInInventory
; In : RCX = AFortPlayerControllerAthena*
;      RDX = FGuid* (16-byte guid to search for)
; Out: AL = 1 if found, 0 if not
;
; Searches PrimaryQuickBar.Slots for a matching guid.
;
; Stack: push rbx push rbp push rsi push rdi = 4 pushes (no CALL sites)
Inventory_IsGuidInInventory PROC
    push    rbx
    push    rbp
    push    rsi
    push    rdi

    mov     rbx, rcx                    ; RBX = PC
    mov     rsi, rdx                    ; RSI = &Guid to find

    ; QuickBars
    mov     rcx, QWORD PTR [rbx + PC_QuickBars]
    test    rcx, rcx
    jz      @IGII_false

    ; PrimaryQuickBar.Slots TArray: Data at [QB+QB_PrimarySlots], Num at [QB+QB_PrimarySlots+8]
    mov     rbp, QWORD PTR [rcx + QB_PrimarySlots]         ; Slots.Data
    mov     edi, DWORD PTR [rcx + QB_PrimarySlots + 8]      ; Slots.Num
    test    rbp, rbp
    jz      @IGII_false
    test    edi, edi
    jz      @IGII_false

    xor     ebx, ebx                    ; slot index = 0
@IGII_slot_loop:
    cmp     ebx, edi
    jge     @IGII_false

    ; slot = Slots.Data + ebx * QBSLOT_SIZE
    imul    rax, rbx, QBSLOT_SIZE
    add     rax, rbp                    ; &Slots[slot]

    ; Items.Data at [rax + QBSLOT_Items]
    mov     rcx, QWORD PTR [rax + QBSLOT_Items]      ; Items.Data
    mov     edx, DWORD PTR [rax + QBSLOT_Items + 8]  ; Items.Num
    test    rcx, rcx
    jz      @IGII_slot_next
    test    edx, edx
    jz      @IGII_slot_next

    xor     r8d, r8d                    ; item index = 0
@IGII_item_loop:
    cmp     r8d, edx
    jge     @IGII_slot_next

    ; &Items[i] = rcx + i*16
    imul    r9, r8, FGUID_SIZE
    add     r9, rcx                     ; &Guid[i]

    ; Compare 16-byte GUIDs (two QWORD comparisons)
    mov     r10, QWORD PTR [r9]
    mov     r11, QWORD PTR [rsi]
    cmp     r10, r11
    jne     @IGII_item_next
    mov     r10, QWORD PTR [r9 + 8]
    mov     r11, QWORD PTR [rsi + 8]
    cmp     r10, r11
    je      @IGII_true

@IGII_item_next:
    inc     r8d
    jmp     @IGII_item_loop

@IGII_slot_next:
    inc     ebx
    jmp     @IGII_slot_loop

@IGII_false:
    xor     eax, eax
    pop     rdi
    pop     rsi
    pop     rbp
    pop     rbx
    ret

@IGII_true:
    mov     eax, 1
    pop     rdi
    pop     rsi
    pop     rbp
    pop     rbx
    ret
Inventory_IsGuidInInventory ENDP

; IsValidGuid is the same logic
Inventory_IsValidGuid PROC
    jmp     Inventory_IsGuidInInventory
Inventory_IsValidGuid ENDP


; Inventory_GetEntryInSlot
; In : RCX = AFortPlayerControllerAthena*
;      EDX = Slot (int)
;      R8D = Item (int, index within slot)
;      R9D = Bars (EFortQuickBars: 0=Primary, 1=Secondary)
; Out: RAX = &FFortItemEntry (within UFortWorldItem) or NULL
;
; Stack: push rbx push rbp push rsi push rdi push r12 = 5 (no CALL sites)
Inventory_GetEntryInSlot PROC
    push    rbx
    push    rbp
    push    rsi
    push    rdi
    push    r12

    mov     rbx, rcx                    ; RBX = PC
    mov     ebp, edx                    ; EBP = Slot
    mov     esi, r8d                    ; ESI = Item
    mov     r12d, r9d                   ; R12D = Bars

    ; Get QuickBars
    mov     rcx, QWORD PTR [rbx + PC_QuickBars]
    test    rcx, rcx
    jz      @IGETS_null

    ; Get Slots TArray based on Bars
    test    r12d, r12d
    jnz     @IGETS_secondary
    mov     rdi, QWORD PTR [rcx + QB_PrimarySlots]         ; Primary.Slots.Data
    mov     edx, DWORD PTR [rcx + QB_PrimarySlots + 8]
    jmp     @IGETS_slots_ok
@IGETS_secondary:
    mov     rdi, QWORD PTR [rcx + QB_SecondarySlots]
    mov     edx, DWORD PTR [rcx + QB_SecondarySlots + 8]

@IGETS_slots_ok:
    test    rdi, rdi
    jz      @IGETS_null
    cmp     ebp, edx
    jge     @IGETS_null                 ; slot out of range

    ; &Slots[Slot]
    imul    rax, rbp, QBSLOT_SIZE
    add     rax, rdi
    ; Items.Data
    mov     rcx, QWORD PTR [rax + QBSLOT_Items]
    mov     edx, DWORD PTR [rax + QBSLOT_Items + 8]
    test    rcx, rcx
    jz      @IGETS_null
    cmp     esi, edx
    jge     @IGETS_null
    ; ToFindGuid = &Items[Item]
    imul    rax, rsi, FGUID_SIZE
    add     rax, rcx                    ; RAX = &FGuid to find

    ; Search ItemInstances for matching guid
    mov     rdi, QWORD PTR [rbx + PC_WorldInventory]
    test    rdi, rdi
    jz      @IGETS_null
    mov     rcx, QWORD PTR [rdi + AFI_ItemInstances]         ; ItemInstances.Data
    mov     r8d, DWORD PTR [rdi + AFI_ItemInstances + 8]     ; ItemInstances.Num
    test    rcx, rcx
    jz      @IGETS_null

    xor     r9d, r9d                    ; j = 0
@IGETS_inst_loop:
    cmp     r9d, r8d
    jge     @IGETS_null
    mov     r10, QWORD PTR [rcx + r9*8]     ; ItemInstances[j] (UFortWorldItem*)
    test    r10, r10
    jz      @IGETS_inst_next
    ; Compare guid at [r10 + UWI_ItemEntry_ItemGuid] with [rax]
    mov     r11, QWORD PTR [r10 + UWI_ItemEntry_ItemGuid]
    mov     rbp, QWORD PTR [rax]
    cmp     r11, rbp
    jne     @IGETS_inst_next
    mov     r11, QWORD PTR [r10 + UWI_ItemEntry_ItemGuid + 8]
    mov     rbp, QWORD PTR [rax + 8]
    cmp     r11, rbp
    je      @IGETS_found
@IGETS_inst_next:
    inc     r9d
    jmp     @IGETS_inst_loop

@IGETS_found:
    ; Return &ItemInstance->ItemEntry
    lea     rax, [r10 + UWI_ItemEntry]
    pop     r12
    pop     rdi
    pop     rsi
    pop     rbp
    pop     rbx
    ret

@IGETS_null:
    xor     eax, eax
    pop     r12
    pop     rdi
    pop     rsi
    pop     rbp
    pop     rbx
    ret
Inventory_GetEntryInSlot ENDP


; Inventory_AddItemToSlot
; In : RCX = AFortPlayerControllerAthena*
;      RDX = UFortWorldItemDefinition* (Definition)
;      R8D = Slot (int)
;      R9D = Bars (EFortQuickBars)
;      [rsp+40] = Count (int, arg5)
; Out: RAX = &FFortItemEntry (within world item) or NULL
;
; Stack: 5 pushes (40) + sub 0A0h (160) = 200; 8-200=-192=0 
;
; Frame:
;   [+00..+1F] shadow
;   [+20..+2F] CreateTemporaryItemInstanceBP params (Count/Level/RetVal)
;   [+30..+37] SetOwningController params (InController QWORD)
;   [+40..+57] ServerAddItemInternal params (FGuid16 + QB1 + pad3 + Slot4)
;   [+60..+7F] locals: Count/PC/Def/Slot/Bars
Inventory_AddItemToSlot PROC
    push    rbx
    push    rbp
    push    rsi
    push    rdi
    push    r12
    sub     rsp, 0A0h   ; 5 pushes(40)+0xA0(160)=200; 8-200=-192=0 

    ; arg5 at entry_rsp+40 -> current_rsp+200+40 = rsp+0xE8
    mov     eax, DWORD PTR [rsp + 0E8h]
    mov     DWORD PTR [rsp + 60h], eax      ; [+60] = Count

    ; Save all params to locals (frame)
    mov     QWORD PTR [rsp + 68h], rcx      ; [+68] = PC
    mov     QWORD PTR [rsp + 70h], rdx      ; [+70] = Definition
    mov     DWORD PTR [rsp + 78h], r8d      ; [+78] = Slot
    mov     DWORD PTR [rsp + 7Ch], r9d      ; [+7C] = Bars

    ; Clamp slot
    test    r9d, r9d
    jnz     @IAITS3_nc
    cmp     r8d, 6
    jl      @IAITS3_nc
    mov     DWORD PTR [rsp + 78h], 5
@IAITS3_nc:
    cmp     DWORD PTR [rsp + 78h], 0
    jns     @IAITS3_sk
    mov     DWORD PTR [rsp + 78h], 1
@IAITS3_sk:

    ; CreateTemporaryItemInstanceBP params at [+20]: Count(4)+Level(4)+RetVal(8)
    mov     eax, DWORD PTR [rsp + 60h]
    mov     DWORD PTR [rsp + 20h], eax      ; Count
    mov     DWORD PTR [rsp + 24h], 1         ; Level = 1
    mov     QWORD PTR [rsp + 28h], 0         ; RetValue init

    lea     rsi, [fn_CreateTempItemBP]
    lea     rdi, [sz_CreateTempItemBP]
    call    Inventory__LoadFn

    test    rax, rax
    jz      @IAITS3_null
    mov     rcx, QWORD PTR [rsp + 70h]      ; Definition
    mov     rdx, rax                         ; fn
    lea     r8, [rsp + 20h]
    call    QWORD PTR [ProcessEvent]

    mov     rbp, QWORD PTR [rsp + 28h]      ; TempItemInstance
    test    rbp, rbp
    jz      @IAITS3_null

    ; SetOwningControllerForTemporaryItem(TempItem, PC)
    ; Params: InController(QWORD at +0)
    mov     rax, QWORD PTR [rsp + 68h]      ; PC
    mov     QWORD PTR [rsp + 30h], rax
    lea     rsi, [fn_SetOwningController]
    lea     rdi, [sz_SetOwningController]
    call    Inventory__LoadFn
    test    rax, rax
    jz      @IAITS3_skip_soc
    mov     rcx, rbp                         ; TempItem
    mov     rdx, rax
    lea     r8, [rsp + 30h]
    call    QWORD PTR [ProcessEvent]
@IAITS3_skip_soc:

    ; TempItem->ItemEntry.Count = Count
    mov     eax, DWORD PTR [rsp + 60h]
    mov     DWORD PTR [rbp + UWI_ItemEntry_Count], eax

    ; TempItem->OwnerInventory = PC->WorldInventory
    mov     rcx, QWORD PTR [rsp + 68h]
    mov     rdx, QWORD PTR [rcx + PC_WorldInventory]
    mov     QWORD PTR [rbp + UWI_OwnerInventory], rdx

    ; TArray_Add(WorldInventory->Inventory.ReplicatedEntries, &TempItem->ItemEntry, FITEM_SIZEOF)
    test    rdx, rdx
    jz      @IAITS3_null
    mov     rbx, rdx                         ; RBX = WorldInventory
    lea     rcx, [rbx + AFI_ReplicatedEntries]  ; &TArrayHeader
    lea     rdx, [rbp + UWI_ItemEntry]          ; &ItemEntry
    mov     r8d, FITEM_SIZEOF
    call    TArray_Add
    ; EAX = index _Idx

    mov     r12d, eax                        ; R12D = _Idx

    ; TArray_Add(WorldInventory->Inventory.ItemInstances, &TempItem, 8)
    push    rbp                              ; push TempItem ptr onto stack
    lea     rcx, [rbx + AFI_ItemInstances]
    lea     rdx, [rsp]                       ; &TempItem on stack
    mov     r8d, 8
    call    TArray_Add
    add     rsp, 8

    ; ServerAddItemInternal(QuickBars, ItemGuid, Bars, Slot)
    ; Params: FGuid(+0,16) + EFortQuickBars(+10,1,3pad) + Slot(+14,4) = 0x18
    mov     rcx, QWORD PTR [rsp + 68h]      ; PC
    mov     rcx, QWORD PTR [rcx + PC_QuickBars]
    test    rcx, rcx
    jz      @IAITS3_skip_sai
    ; Copy Guid from TempItem->ItemEntry.ItemGuid (at RBP+UWI_ItemEntry_ItemGuid)
    mov     rax, QWORD PTR [rbp + UWI_ItemEntry_ItemGuid]
    mov     rdx, QWORD PTR [rbp + UWI_ItemEntry_ItemGuid + 8]
    mov     QWORD PTR [rsp + 40h], rax
    mov     QWORD PTR [rsp + 48h], rdx
    mov     eax, DWORD PTR [rsp + 7Ch]      ; Bars
    mov     BYTE PTR [rsp + 50h], al         ; EFortQuickBars (BYTE + 3pad)
    mov     DWORD PTR [rsp + 51h], 0         ; padding
    mov     eax, DWORD PTR [rsp + 78h]       ; Slot
    mov     DWORD PTR [rsp + 54h], eax
    ; Load fn
    push    rcx                              ; save QuickBars
    lea     rsi, [fn_ServerAddItemInternal]
    lea     rdi, [sz_ServerAddItemInternal]
    call    Inventory__LoadFn
    pop     rcx                              ; restore QuickBars
    test    rax, rax
    jz      @IAITS3_skip_sai
    mov     rdx, rax
    lea     r8, [rsp + 40h]
    call    QWORD PTR [ProcessEvent]

@IAITS3_skip_sai:
    ; Inventory_Update(PC, _Idx, false)
    mov     rcx, QWORD PTR [rsp + 68h]
    mov     edx, r12d
    xor     r8d, r8d
    call    Inventory_Update

    ; Return &TempItem->ItemEntry
    lea     rax, [rbp + UWI_ItemEntry]
    add     rsp, 0A0h
    pop     r12
    pop     rdi
    pop     rsi
    pop     rbp
    pop     rbx
    ret

@IAITS3_null:
    xor     eax, eax
    add     rsp, 0A0h
    pop     r12
    pop     rdi
    pop     rsi
    pop     rbp
    pop     rbx
    ret
Inventory_AddItemToSlot ENDP


; Inventory_RemoveItemFromSlot
; In : RCX = AFortPlayerControllerAthena*
;      EDX = Slot (int)
;      R8D = Bars (EFortQuickBars)
;      R9D = Amount (int, -1 = all items in slot)
;
; Stack: 5 pushes (40) + sub 0C0h (192) = 232; 8-232=-224=0 
;
; Frame: [+00..+1F] shadow; [+20..] locals
Inventory_RemoveItemFromSlot PROC
    push    rbx
    push    rbp
    push    rsi
    push    rdi
    push    r12
    sub     rsp, 0C0h

    mov     QWORD PTR [rsp + 60h], rcx      ; [+60] = PC
    mov     DWORD PTR [rsp + 68h], edx      ; [+68] = Slot
    mov     DWORD PTR [rsp + 6Ch], r8d      ; [+6C] = Bars
    mov     DWORD PTR [rsp + 70h], r9d      ; [+70] = Amount

    ; Get QuickBars
    mov     rbx, QWORD PTR [rcx + PC_QuickBars]
    test    rbx, rbx
    jz      @IRIFS_null

    ; Get WorldInventory
    mov     rdi, QWORD PTR [rcx + PC_WorldInventory]
    test    rdi, rdi
    jz      @IRIFS_null

    ; Determine slots TArray and slot ptr
    mov     eax, DWORD PTR [rsp + 6Ch]      ; Bars
    test    eax, eax
    jnz     @IRIFS_secondary

    ; Primary: Slots.Data and Num at QB+QB_PrimarySlots
    mov     rsi, QWORD PTR [rbx + QB_PrimarySlots]
    mov     r12d, DWORD PTR [rbx + QB_PrimarySlots + 8]
    jmp     @IRIFS_slots_ok
@IRIFS_secondary:
    mov     rsi, QWORD PTR [rbx + QB_SecondarySlots]
    mov     r12d, DWORD PTR [rbx + QB_SecondarySlots + 8]

@IRIFS_slots_ok:
    test    rsi, rsi
    jz      @IRIFS_null
    mov     eax, DWORD PTR [rsp + 68h]      ; Slot
    cmp     eax, r12d
    jge     @IRIFS_null

    ; &Slots[Slot]
    imul    rax, rax, QBSLOT_SIZE
    add     rax, rsi                         ; RAX = &Slots[Slot]

    ; If Amount == -1: use Items.Num
    mov     ebp, DWORD PTR [rsp + 70h]
    cmp     ebp, -1
    jne     @IRIFS_amount_ok
    mov     ebp, DWORD PTR [rax + QBSLOT_Items + 8]  ; Items.Num
@IRIFS_amount_ok:
    mov     DWORD PTR [rsp + 74h], ebp      ; save Amount to local

    ; Save &Slots[Slot] to local
    mov     QWORD PTR [rsp + 78h], rax      ; [+78] = &Slots[Slot]

    ; bWasSuccessful = false
    mov     BYTE PTR [rsp + 80h], 0

    ; Loop i = 0..Amount
    xor     r12d, r12d                       ; R12D = i
@IRIFS_item_loop:
    cmp     r12d, DWORD PTR [rsp + 74h]
    jge     @IRIFS_check_success

    ; ToRemoveGuid = &Slots[Slot].Items[i]
    mov     rax, QWORD PTR [rsp + 78h]       ; &Slots[Slot]
    mov     rcx, QWORD PTR [rax + QBSLOT_Items]      ; Items.Data
    test    rcx, rcx
    jz      @IRIFS_skip_item
    imul    rbp, r12, FGUID_SIZE
    add     rbp, rcx                         ; RBP = &ToRemoveGuid

    ; Remove from ItemInstances
    mov     rcx, QWORD PTR [rdi + AFI_ItemInstances]
    mov     edx, DWORD PTR [rdi + AFI_ItemInstances + 8]
    test    rcx, rcx
    jz      @IRIFS_skip_inst

    xor     r9d, r9d
@IRIFS_inst_loop:
    cmp     r9d, edx
    jge     @IRIFS_skip_inst
    mov     rax, QWORD PTR [rcx + r9*8]
    test    rax, rax
    jz      @IRIFS_inst_next

    ; Compare guid at rax+UWI_ItemEntry_ItemGuid with [RBP]
    mov     r10, QWORD PTR [rax + UWI_ItemEntry_ItemGuid]
    mov     r11, QWORD PTR [rbp]
    cmp     r10, r11
    jne     @IRIFS_inst_next
    mov     r10, QWORD PTR [rax + UWI_ItemEntry_ItemGuid + 8]
    mov     r11, QWORD PTR [rbp + 8]
    cmp     r10, r11
    jne     @IRIFS_inst_next

    ; TArray_RemoveAt(ItemInstances, j, 8)
    push    rbp                             ; save RBP
    push    rdi                             ; save WorldInventory
    push    rcx                             ; save Items.Data (before RemoveAt)
    push    rdx                             ; save Num
    lea     rcx, [rdi + AFI_ItemInstances]
    mov     edx, r9d
    mov     r8d, 8
    call    TArray_RemoveAt
    pop     rdx
    pop     rcx
    pop     rdi
    pop     rbp
    mov     BYTE PTR [rsp + 80h], 1         ; bWasSuccessful = true

    ; Reload after RemoveAt (array may have moved)
    mov     rcx, QWORD PTR [rdi + AFI_ItemInstances]
    mov     edx, DWORD PTR [rdi + AFI_ItemInstances + 8]
    ; Don't increment r9d since RemoveAt shifts elements down
    jmp     @IRIFS_inst_loop

@IRIFS_inst_next:
    inc     r9d
    jmp     @IRIFS_inst_loop

@IRIFS_skip_inst:
    ; Remove from ReplicatedEntries
    mov     rcx, QWORD PTR [rdi + AFI_ReplicatedEntries]
    mov     edx, DWORD PTR [rdi + AFI_ReplicatedEntries + 8]
    test    rcx, rcx
    jz      @IRIFS_skip_rep

    xor     r9d, r9d
@IRIFS_rep_loop:
    cmp     r9d, edx
    jge     @IRIFS_skip_rep
    ; &ReplicatedEntries[x] = rcx + x * FITEM_SIZEOF
    imul    rax, r9, FITEM_SIZEOF
    add     rax, rcx
    ; Compare ItemGuid at rax+0x50
    mov     r10, QWORD PTR [rax + 050h]
    mov     r11, QWORD PTR [rbp]
    cmp     r10, r11
    jne     @IRIFS_rep_next
    mov     r10, QWORD PTR [rax + 050h + 8]
    mov     r11, QWORD PTR [rbp + 8]
    cmp     r10, r11
    jne     @IRIFS_rep_next

    ; TArray_RemoveAt(ReplicatedEntries, x, FITEM_SIZEOF)
    push    rbp
    push    rdi
    push    rcx
    push    rdx
    lea     rcx, [rdi + AFI_ReplicatedEntries]
    mov     edx, r9d
    mov     r8d, FITEM_SIZEOF
    call    TArray_RemoveAt
    pop     rdx
    pop     rcx
    pop     rdi
    pop     rbp
    mov     BYTE PTR [rsp + 80h], 1

    mov     rcx, QWORD PTR [rdi + AFI_ReplicatedEntries]
    mov     edx, DWORD PTR [rdi + AFI_ReplicatedEntries + 8]
    jmp     @IRIFS_rep_loop

@IRIFS_rep_next:
    inc     r9d
    jmp     @IRIFS_rep_loop

@IRIFS_skip_rep:
    ; ServerRemoveItemInternal(QuickBars, Guid, false, true)
    ; Params: FGuid(16) + bFindReplacement(1) + bForce(1) = 18, pad to 24
    mov     rax, QWORD PTR [rbp]
    mov     rdx, QWORD PTR [rbp + 8]
    mov     QWORD PTR [rsp + 38h], rax
    mov     QWORD PTR [rsp + 40h], rdx
    mov     BYTE PTR [rsp + 48h], 0         ; bFindReplacement = false
    mov     BYTE PTR [rsp + 49h], 1         ; bForce = true
    push    rbx
    push    rbp
    lea     rsi, [fn_ServerRemoveItemInternal]
    lea     rdi, [sz_ServerRemoveItemInternal]
    call    Inventory__LoadFn
    pop     rbp
    pop     rbx
    test    rax, rax
    jz      @IRIFS_skip_sri
    mov     rcx, rbx
    mov     rdx, rax
    lea     r8, [rsp + 38h]
    call    QWORD PTR [ProcessEvent]
@IRIFS_skip_sri:

    ; Zero out ToRemoveGuid (Reset)
    xor     eax, eax
    mov     QWORD PTR [rbp], rax
    mov     QWORD PTR [rbp + 8], rax

@IRIFS_skip_item:
    inc     r12d
    jmp     @IRIFS_item_loop

@IRIFS_check_success:
    cmp     BYTE PTR [rsp + 80h], 0
    je      @IRIFS_call_update

    ; EmptySlot(QuickBars, Bars, Slot)
    mov     eax, DWORD PTR [rsp + 6Ch]
    mov     edx, DWORD PTR [rsp + 68h]
    mov     DWORD PTR [rsp + 38h], eax      ; EFortQuickBars (BYTE)
    mov     DWORD PTR [rsp + 3Ch], edx      ; SlotIndex (int)
    push    rbx
    lea     rsi, [fn_EmptySlot]
    lea     rdi, [sz_EmptySlot]
    call    Inventory__LoadFn
    pop     rbx
    test    rax, rax
    jz      @IRIFS_skip_es
    mov     rcx, rbx
    mov     rdx, rax
    lea     r8, [rsp + 38h]
    call    QWORD PTR [ProcessEvent]
@IRIFS_skip_es:

    ; FreeArray on Slots[Slot].Items
    mov     rax, QWORD PTR [rsp + 78h]      ; &Slots[Slot]
    lea     rcx, [rax + QBSLOT_Items]
    call    TArray_FreeArray

@IRIFS_call_update:
    ; Inventory_Update(PC, 0, true)
    mov     rcx, QWORD PTR [rsp + 60h]
    xor     edx, edx
    mov     r8d, 1
    call    Inventory_Update

    movzx   eax, BYTE PTR [rsp + 80h]       ; return bWasSuccessful
    add     rsp, 0C0h
    pop     r12
    pop     rdi
    pop     rsi
    pop     rbp
    pop     rbx
    ret

@IRIFS_null:
    xor     eax, eax
    add     rsp, 0C0h
    pop     r12
    pop     rdi
    pop     rsi
    pop     rbp
    pop     rbx
    ret
Inventory_RemoveItemFromSlot ENDP


; Inventory_EquipWeaponDefinition
; In : RCX = APawn* (pawn)
;      RDX = UFortWeaponItemDefinition*
;      R8  = FGuid* (16-byte)
;
; Stack: 5 pushes (40) + sub 80h (128) = 168; 8-168=-160=0 
;
; Frame:
;   [+00..+1F] shadow
;   [+20..+3F] EquipWeaponDefinition params (WeaponData+Guid+RetVal = 0x20)
;   [+40..+47] ProcessEvent null-params scratch / SetOwner params
;   [+60..+67] Weapon (saved after EquipWeaponDefinition call)
;   [+70..+7F] Guid copy
Inventory_EquipWeaponDefinition PROC
    push    rbx
    push    rbp
    push    rsi
    push    rdi
    push    r12
    sub     rsp, 80h

    mov     r12, rcx                        ; R12 = Pawn
    mov     rbx, rdx                        ; RBX = Definition
    mov     rax, QWORD PTR [r8]
    mov     QWORD PTR [rsp + 70h], rax
    mov     rax, QWORD PTR [r8 + 8]
    mov     QWORD PTR [rsp + 78h], rax

    ; Get Controller
    mov     rbp, QWORD PTR [r12 + 0228h]
    test    rbp, rbp
    jz      @IEWD3_done

    ; IsGuidInInventory check
    mov     rcx, rbp
    lea     rdx, [rsp + 70h]
    call    Inventory_IsGuidInInventory
    test    al, al
    jz      @IEWD3_done

    ; EquipWeaponDefinition via ProcessEvent
    mov     QWORD PTR [rsp + 20h], rbx
    mov     rax, QWORD PTR [rsp + 70h]
    mov     QWORD PTR [rsp + 28h], rax
    mov     rax, QWORD PTR [rsp + 78h]
    mov     QWORD PTR [rsp + 30h], rax
    mov     QWORD PTR [rsp + 38h], 0

    lea     rsi, [fn_EquipWeaponDef]
    lea     rdi, [sz_EquipWeaponDef]
    call    Inventory__LoadFn
    test    rax, rax
    jz      @IEWD3_done
    mov     rcx, r12
    mov     rdx, rax
    lea     r8, [rsp + 20h]
    call    QWORD PTR [ProcessEvent]

    mov     rbp, QWORD PTR [rsp + 38h]      ; Weapon
    test    rbp, rbp
    jz      @IEWD3_done
    mov     QWORD PTR [rsp + 60h], rbp      ; save Weapon to local

    ; Weapon->WeaponData = Definition
    mov     QWORD PTR [rbp + FW_WeaponData], rbx
    ; Weapon->ItemEntryGuid = Guid
    mov     rax, QWORD PTR [rsp + 70h]
    mov     QWORD PTR [rbp + FW_ItemEntryGuid], rax
    mov     rax, QWORD PTR [rsp + 78h]
    mov     QWORD PTR [rbp + FW_ItemEntryGuid + 8], rax

    ; SetOwner(Weapon, Pawn)
    mov     QWORD PTR [rsp + 40h], r12
    lea     rsi, [fn_SetOwner]
    lea     rdi, [sz_SetOwner]
    call    Inventory__LoadFn
    test    rax, rax
    jz      @IEWD3_skip_so
    mov     rcx, QWORD PTR [rsp + 60h]      ; Weapon
    mov     rdx, rax
    lea     r8, [rsp + 40h]
    call    QWORD PTR [ProcessEvent]
@IEWD3_skip_so:

    ; OnRep_ReplicatedWeaponData(Weapon)
    lea     rsi, [fn_OnRep_WeaponData]
    lea     rdi, [sz_OnRep_WeaponData]
    call    Inventory__LoadFn
    test    rax, rax
    jz      @IEWD3_skip_rrwd
    xor     r8d, r8d
    mov     QWORD PTR [rsp + 40h], r8
    mov     rcx, QWORD PTR [rsp + 60h]
    mov     rdx, rax
    lea     r8, [rsp + 40h]
    call    QWORD PTR [ProcessEvent]
@IEWD3_skip_rrwd:

    ; OnRep_AmmoCount(Weapon)
    lea     rsi, [fn_OnRep_AmmoCount]
    lea     rdi, [sz_OnRep_AmmoCount]
    call    Inventory__LoadFn
    test    rax, rax
    jz      @IEWD3_skip_rac
    xor     r8d, r8d
    mov     QWORD PTR [rsp + 40h], r8
    mov     rcx, QWORD PTR [rsp + 60h]
    mov     rdx, rax
    lea     r8, [rsp + 40h]
    call    QWORD PTR [ProcessEvent]
@IEWD3_skip_rac:

    ; ClientGivenTo(Weapon, Pawn)
    mov     QWORD PTR [rsp + 40h], r12
    lea     rsi, [fn_ClientGivenTo]
    lea     rdi, [sz_ClientGivenTo]
    call    Inventory__LoadFn
    test    rax, rax
    jz      @IEWD3_skip_cgt
    mov     rcx, QWORD PTR [rsp + 60h]
    mov     rdx, rax
    lea     r8, [rsp + 40h]
    call    QWORD PTR [ProcessEvent]
@IEWD3_skip_cgt:

    ; ClientInternalEquipWeapon(Pawn, Weapon)
    mov     rax, QWORD PTR [rsp + 60h]
    mov     QWORD PTR [rsp + 40h], rax
    lea     rsi, [fn_ClientInternalEquipWeapon]
    lea     rdi, [sz_ClientInternalEquipWeapon]
    call    Inventory__LoadFn
    test    rax, rax
    jz      @IEWD3_skip_ciew
    mov     rcx, r12
    mov     rdx, rax
    lea     r8, [rsp + 40h]
    call    QWORD PTR [ProcessEvent]
@IEWD3_skip_ciew:

    ; OnRep_CurrentWeapon(Pawn)
    lea     rsi, [fn_OnRep_CurrentWeapon]
    lea     rdi, [sz_OnRep_CurrentWeapon]
    call    Inventory__LoadFn
    test    rax, rax
    jz      @IEWD3_done
    xor     r8d, r8d
    mov     QWORD PTR [rsp + 40h], r8
    mov     rcx, r12
    mov     rdx, rax
    lea     r8, [rsp + 40h]
    call    QWORD PTR [ProcessEvent]

@IEWD3_done:
    add     rsp, 80h
    pop     r12
    pop     rdi
    pop     rsi
    pop     rbp
    pop     rbx
    ret
Inventory_EquipWeaponDefinition ENDP


; Inventory_OnDrop
; In : RCX = AFortPlayerControllerAthena*
;      RDX = AFortPlayerController_ServerAttemptInventoryDrop_Params*
;              (FGuid ItemGuid at [RDX+0])
; Out: AL = 1 if successful
;
; Stack: 5 pushes (40) + sub 70h (112) = 152; 8-152=-144=0 
Inventory_OnDrop PROC
    push    rbx
    push    rbp
    push    rsi
    push    rdi
    push    r12
    sub     rsp, 70h

    mov     r12, rcx                        ; R12 = PC
    mov     rbp, rdx                        ; RBP = Params

    ; bWasSuccessful = 0
    xor     ebx, ebx

    ; Get QuickBars
    mov     rsi, QWORD PTR [r12 + PC_QuickBars]
    test    rsi, rsi
    jz      @IOD_done

    ; Iterate PrimaryQuickBar.Slots[1..Num] looking for ItemGuid
    mov     rdi, QWORD PTR [rsi + QB_PrimarySlots]
    mov     r8d, DWORD PTR [rsi + QB_PrimarySlots + 8]
    test    rdi, rdi
    jz      @IOD_check_secondary
    test    r8d, r8d
    jz      @IOD_check_secondary

    mov     r9d, 1                          ; start at slot 1 (skip pickaxe slot 0)
@IOD_pri_slot_loop:
    cmp     r9d, r8d
    jge     @IOD_check_secondary

    imul    rax, r9, QBSLOT_SIZE
    add     rax, rdi                        ; &Slots[i]
    mov     rcx, QWORD PTR [rax + QBSLOT_Items]
    test    rcx, rcx
    jz      @IOD_pri_slot_next
    mov     edx, DWORD PTR [rax + QBSLOT_Items + 8]
    test    edx, edx
    jz      @IOD_pri_slot_next

    ; For each item in slot
    xor     r10d, r10d
@IOD_pri_item_loop:
    cmp     r10d, edx
    jge     @IOD_pri_slot_next
    imul    r11, r10, FGUID_SIZE
    add     r11, rcx                        ; &Items[j]
    ; Compare with Params->ItemGuid at [RBP+0]
    mov     rax, QWORD PTR [r11]
    mov     rdx, QWORD PTR [rbp]
    cmp     rax, rdx
    jne     @IOD_pri_item_next
    mov     rax, QWORD PTR [r11 + 8]
    mov     rdx, QWORD PTR [rbp + 8]
    cmp     rax, rdx
    jne     @IOD_pri_item_next

    ; Found! RemoveItemFromSlot(PC, slot, Primary, j+1) -> spawn pickup
    mov     rcx, r12
    mov     edx, r9d
    xor     r8d, r8d                        ; Primary = 0
    mov     r9d, r10d
    inc     r9d                             ; Amount = j+1
    call    Inventory_RemoveItemFromSlot
    test    al, al
    jz      @IOD_done

    ; Spawn pickup: SummonPickup(Pawn, ItemDef, 1, PawnLocation)
    ; ItemDef comes from the ItemInstance we need to find
    mov     ebx, 1
    jmp     @IOD_done

@IOD_pri_item_next:
    inc     r10d
    jmp     @IOD_pri_item_loop

@IOD_pri_slot_next:
    inc     r9d
    jmp     @IOD_pri_slot_loop

@IOD_check_secondary:

@IOD_done:
    ; Select pickaxe (slot 0)
    mov     rax, QWORD PTR [r12 + PC_QuickBars]
    test    rax, rax
    jz      @IOD_return
    mov     rcx, QWORD PTR [rax + QB_PrimarySlots]
    test    rcx, rcx
    jz      @IOD_return
    mov     rcx, QWORD PTR [rcx]             ; Slots[0].Items.Data
    test    rcx, rcx
    jz      @IOD_return
    ; EquipInventoryItem using guid from slot 0
    lea     rdx, [rcx]                       ; pointer to guid at Slots[0].Items[0]
    mov     rcx, r12
    call    Inventory_EquipWeaponDefinition   ; partial call, but we don't have def here
    ; TODO: use proper EquipInventoryItem

@IOD_return:
    movzx   eax, bl
    add     rsp, 70h
    pop     r12
    pop     rdi
    pop     rsi
    pop     rbp
    pop     rbx
    ret
Inventory_OnDrop ENDP


; Inventory_OnPickup
; In : RCX = AFortPlayerControllerAthena*
;      RDX = AFortPlayerPawn_ServerHandlePickup_Params*
;              Pickup* at [RDX+0]
;
; Stack: 5 pushes (40) + sub 70h (112) = 152; 8-152=-144=0 
Inventory_OnPickup PROC
    push    rbx
    push    rbp
    push    rsi
    push    rdi
    push    r12
    sub     rsp, 70h

    mov     r12, rcx                        ; R12 = PC
    mov     rbp, rdx                        ; RBP = Params

    ; Params->Pickup = [RBP + 0]
    mov     rbx, QWORD PTR [rbp]            ; Pickup (AFortPickup*)
    test    rbx, rbx
    jz      @IOP_done

    ; ItemDef = Pickup->PrimaryPickupItemEntry.ItemDefinition (at AFortPickup+0x0368)
    mov     rsi, QWORD PTR [rbx + 0368h]    ; ItemDefinition
    test    rsi, rsi
    jz      @IOP_done

    ; Count = Pickup->PrimaryPickupItemEntry.Count (at AFortPickup+0x035C)
    mov     edi, DWORD PTR [rbx + 035Ch]

    ; Find empty slot in PrimaryQuickBar.Slots[1..6]
    mov     rax, QWORD PTR [r12 + PC_QuickBars]
    test    rax, rax
    jz      @IOP_done
    mov     rcx, QWORD PTR [rax + QB_PrimarySlots]
    mov     edx, DWORD PTR [rax + QB_PrimarySlots + 8]
    test    rcx, rcx
    jz      @IOP_done

    mov     r9d, 1
@IOP_pri_slot_loop:
    cmp     r9d, 6
    jge     @IOP_done
    cmp     r9d, edx
    jge     @IOP_done

    imul    r10, r9, QBSLOT_SIZE
    add     r10, rcx
    ; Check if slot is empty: Items.Data == NULL
    mov     r11, QWORD PTR [r10 + QBSLOT_Items]
    test    r11, r11
    jz      @IOP_slot_found

    inc     r9d
    jmp     @IOP_pri_slot_loop

@IOP_slot_found:
    ; AddItemToSlot(PC, ItemDef, slot, Primary, Count)
    mov     rcx, r12
    mov     rdx, rsi                         ; ItemDef
    mov     r8d, r9d                         ; Slot
    xor     r9d, r9d                         ; Primary = 0
    mov     DWORD PTR [rsp + 20h], edi       ; Count (arg5)
    call    Inventory_AddItemToSlot
    test    rax, rax
    jz      @IOP_done
    mov     r8, rax                          ; &ItemEntry returned

    ; Set Pickup->PickupLocationData.PickupTarget = Pawn
    ; PickupLocationData at AFortPickup+0x0428; PickupTarget at +0x00 within = AFortPickup+0x0428
    mov     rcx, QWORD PTR [r12 + ACTRL_Pawn]
    test    rcx, rcx
    jz      @IOP_skip_pldata
    mov     rax, QWORD PTR [r12 + ACTRL_Pawn]
    mov     rax, QWORD PTR [r12 + 0260h]        ; Pawn
    mov     QWORD PTR [rbx + 0428h], rax         ; PickupTarget
    mov     QWORD PTR [rbx + 0438h], rax         ; ItemOwner

    ; FlyTime = 0.4f
    mov     DWORD PTR [rbx + 0458h], 3ECCCCCDh   ; 0.4f IEEE

    ; TODO: OnRep_PickupLocationData

@IOP_skip_pldata:
    ; bPickedUp = true
    mov     BYTE PTR [rbx + 04C0h], 1

    ; TODO: OnRep_bPickedUp

    ; LoadedAmmo from pickup to instance
    mov     eax, DWORD PTR [rbx + 0378h]
    mov     DWORD PTR [r8 + 028h], eax

    ; Update inventory
    mov     rcx, r12
    xor     edx, edx
    xor     r8d, r8d
    call    Inventory_Update

@IOP_done:
    add     rsp, 70h
    pop     r12
    pop     rdi
    pop     rsi
    pop     rbp
    pop     rbx
    ret
Inventory_OnPickup ENDP


; Inventory_Init
; In : RCX = AFortPlayerControllerAthena*
; Spawns QuickBars, adds default items (buildings, traps, resources, ammo, edit tool).
;
; Stack: 5 pushes (40) + sub 80h (128) = 168; 8-168=-160=0 
Inventory_Init PROC
    push    rbx
    push    rbp
    push    rsi
    push    rdi
    push    r12
    sub     rsp, 80h

    mov     r12, rcx                        ; R12 = PC

    ; Spawn QuickBars
    lea     rcx, [sz_FortQuickBarsClass]
    call    SDK_FindClass
    test    rax, rax
    jz      @II_no_qb
    ; SpawnActor at { -280, 400, 3000 }
    ; Build FVector on stack
    mov     DWORD PTR [rsp + 30h], 0C38C0000h  ; -280.0f
    mov     DWORD PTR [rsp + 34h], 43C80000h    ; 400.0f
    mov     DWORD PTR [rsp + 38h], 453B8000h    ; 3000.0f
    mov     rcx, rax                            ; QuickBars class
    lea     rdx, [rsp + 30h]                    ; &FVector
    mov     r8, r12                             ; owner = PC
    call    Spawners_SpawnActor
    test    rax, rax
    jz      @II_no_qb

    ; PC->QuickBars = spawned QuickBars
    mov     QWORD PTR [r12 + PC_QuickBars], rax
    mov     rbp, rax                            ; RBP = QuickBars

    ; OnRep_QuickBar on PC
    lea     rsi, [fn_OnRep_QuickBar]
    lea     rdi, [sz_OnRep_QuickBar]
    call    Inventory__LoadFn
    test    rax, rax
    jz      @II_no_qb
    xor     r8d, r8d
    mov     QWORD PTR [rsp + 40h], r8
    mov     rcx, r12
    mov     rdx, rax
    lea     r8, [rsp + 40h]
    call    QWORD PTR [ProcessEvent]

@II_no_qb:

    ; EBX = secondary slot counter (0-7)
    xor     ebx, ebx

    ; Helper: finds object if not cached, adds to secondary slot
    ; ITEM_DEFINE loads item def into RDI, then calls AddItemToSlot

    ; Wall
    mov     rdi, QWORD PTR [def_Wall]
    test    rdi, rdi
    jnz     @II_wall_ok
    lea     rcx, [sz_WallDef]
    call    SDK_FindObject
    mov     QWORD PTR [def_Wall], rax
    mov     rdi, rax
@II_wall_ok:
    test    rdi, rdi
    jz      @II_floor
    mov     rcx, r12
    mov     rdx, rdi
    mov     r8d, ebx
    mov     r9d, QB_SECONDARY
    mov     DWORD PTR [rsp + 20h], 1
    call    Inventory_AddItemToSlot
    inc     ebx

@II_floor:
    mov     rdi, QWORD PTR [def_Floor]
    test    rdi, rdi
    jnz     @II_floor_ok
    lea     rcx, [sz_FloorDef]
    call    SDK_FindObject
    mov     QWORD PTR [def_Floor], rax
    mov     rdi, rax
@II_floor_ok:
    test    rdi, rdi
    jz      @II_stair
    mov     rcx, r12
    mov     rdx, rdi
    mov     r8d, ebx
    mov     r9d, QB_SECONDARY
    mov     DWORD PTR [rsp + 20h], 1
    call    Inventory_AddItemToSlot
    inc     ebx

@II_stair:
    mov     rdi, QWORD PTR [def_Stair]
    test    rdi, rdi
    jnz     @II_stair_ok
    lea     rcx, [sz_StairDef]
    call    SDK_FindObject
    mov     QWORD PTR [def_Stair], rax
    mov     rdi, rax
@II_stair_ok:
    test    rdi, rdi
    jz      @II_roof
    mov     rcx, r12
    mov     rdx, rdi
    mov     r8d, ebx
    mov     r9d, QB_SECONDARY
    mov     DWORD PTR [rsp + 20h], 1
    call    Inventory_AddItemToSlot
    inc     ebx

@II_roof:
    mov     rdi, QWORD PTR [def_Roof]
    test    rdi, rdi
    jnz     @II_roof_ok
    lea     rcx, [sz_RoofDef]
    call    SDK_FindObject
    mov     QWORD PTR [def_Roof], rax
    mov     rdi, rax
@II_roof_ok:
    test    rdi, rdi
    jz      @II_launchpad
    mov     rcx, r12
    mov     rdx, rdi
    mov     r8d, ebx
    mov     r9d, QB_SECONDARY
    mov     DWORD PTR [rsp + 20h], 1
    call    Inventory_AddItemToSlot
    inc     ebx

@II_launchpad:
    mov     rdi, QWORD PTR [def_LaunchPad]
    test    rdi, rdi
    jnz     @II_lp_ok
    lea     rcx, [sz_LaunchPad]
    call    SDK_FindObject
    mov     QWORD PTR [def_LaunchPad], rax
    mov     rdi, rax
@II_lp_ok:
    test    rdi, rdi
    jz      @II_wallelectric
    mov     rcx, r12
    mov     rdx, rdi
    mov     r8d, ebx
    mov     r9d, QB_SECONDARY
    mov     DWORD PTR [rsp + 20h], 1
    call    Inventory_AddItemToSlot
    inc     ebx

@II_wallelectric:
    mov     rdi, QWORD PTR [def_WallElectric]
    test    rdi, rdi
    jnz     @II_we_ok
    lea     rcx, [sz_WallElectric]
    call    SDK_FindObject
    mov     QWORD PTR [def_WallElectric], rax
    mov     rdi, rax
@II_we_ok:
    test    rdi, rdi
    jz      @II_floorspikes
    mov     rcx, r12
    mov     rdx, rdi
    mov     r8d, ebx
    mov     r9d, QB_SECONDARY
    mov     DWORD PTR [rsp + 20h], 1
    call    Inventory_AddItemToSlot
    inc     ebx

@II_floorspikes:
    mov     rdi, QWORD PTR [def_FloorSpikes]
    test    rdi, rdi
    jnz     @II_fs_ok
    lea     rcx, [sz_FloorSpikes]
    call    SDK_FindObject
    mov     QWORD PTR [def_FloorSpikes], rax
    mov     rdi, rax
@II_fs_ok:
    test    rdi, rdi
    jz      @II_campfire
    mov     rcx, r12
    mov     rdx, rdi
    mov     r8d, ebx
    mov     r9d, QB_SECONDARY
    mov     DWORD PTR [rsp + 20h], 1
    call    Inventory_AddItemToSlot
    inc     ebx

@II_campfire:
    mov     rdi, QWORD PTR [def_Campfire]
    test    rdi, rdi
    jnz     @II_cf_ok
    lea     rcx, [sz_Campfire]
    call    SDK_FindObject
    mov     QWORD PTR [def_Campfire], rax
    mov     rdi, rax
@II_cf_ok:
    test    rdi, rdi
    jz      @II_resources
    mov     rcx, r12
    mov     rdx, rdi
    mov     r8d, ebx
    mov     r9d, QB_SECONDARY
    mov     DWORD PTR [rsp + 20h], 1
    call    Inventory_AddItemToSlot

    ; Resources and ammo: slot 0, count 999
@II_resources:
    ; Wood
    mov     rdi, QWORD PTR [def_Wood]
    test    rdi, rdi
    jnz     @II_wood_ok
    lea     rcx, [sz_Wood]
    call    SDK_FindObject
    mov     QWORD PTR [def_Wood], rax
    mov     rdi, rax
@II_wood_ok:
    test    rdi, rdi
    jz      @II_stone
    mov     rcx, r12
    mov     rdx, rdi
    xor     r8d, r8d
    mov     r9d, QB_SECONDARY
    mov     DWORD PTR [rsp + 20h], 999
    call    Inventory_AddItemToSlot

@II_stone:
    mov     rdi, QWORD PTR [def_Stone]
    test    rdi, rdi
    jnz     @II_stone_ok
    lea     rcx, [sz_Stone]
    call    SDK_FindObject
    mov     QWORD PTR [def_Stone], rax
    mov     rdi, rax
@II_stone_ok:
    test    rdi, rdi
    jz      @II_metal
    mov     rcx, r12
    mov     rdx, rdi
    xor     r8d, r8d
    mov     r9d, QB_SECONDARY
    mov     DWORD PTR [rsp + 20h], 999
    call    Inventory_AddItemToSlot

@II_metal:
    mov     rdi, QWORD PTR [def_Metal]
    test    rdi, rdi
    jnz     @II_metal_ok
    lea     rcx, [sz_Metal]
    call    SDK_FindObject
    mov     QWORD PTR [def_Metal], rax
    mov     rdi, rax
@II_metal_ok:
    test    rdi, rdi
    jz      @II_ammo
    mov     rcx, r12
    mov     rdx, rdi
    xor     r8d, r8d
    mov     r9d, QB_SECONDARY
    mov     DWORD PTR [rsp + 20h], 999
    call    Inventory_AddItemToSlot

@II_ammo:
    ; Ammo items (all slot 0 secondary, count 999)
    ; AmmoShells
    mov     rdi, QWORD PTR [def_AmmoShells]
    test    rdi, rdi
    jnz     @II_ash_ok
    lea     rcx, [sz_AmmoShells]
    call    SDK_FindObject
    mov     QWORD PTR [def_AmmoShells], rax
    mov     rdi, rax
@II_ash_ok:
    test    rdi, rdi
    jz      @II_aenergy
    mov     rcx, r12
    mov     rdx, rdi
    xor     r8d, r8d
    mov     r9d, QB_SECONDARY
    mov     DWORD PTR [rsp + 20h], 999
    call    Inventory_AddItemToSlot

@II_aenergy:
    mov     rdi, QWORD PTR [def_AmmoEnergy]
    test    rdi, rdi
    jnz     @II_ae_ok
    lea     rcx, [sz_AmmoEnergy]
    call    SDK_FindObject
    mov     QWORD PTR [def_AmmoEnergy], rax
    mov     rdi, rax
@II_ae_ok:
    test    rdi, rdi
    jz      @II_abm
    mov     rcx, r12
    mov     rdx, rdi
    xor     r8d, r8d
    mov     r9d, QB_SECONDARY
    mov     DWORD PTR [rsp + 20h], 999
    call    Inventory_AddItemToSlot

@II_abm:
    mov     rdi, QWORD PTR [def_AmmoBullMedium]
    test    rdi, rdi
    jnz     @II_abm_ok
    lea     rcx, [sz_AmmoBulletsMedium]
    call    SDK_FindObject
    mov     QWORD PTR [def_AmmoBullMedium], rax
    mov     rdi, rax
@II_abm_ok:
    test    rdi, rdi
    jz      @II_abl
    mov     rcx, r12
    mov     rdx, rdi
    xor     r8d, r8d
    mov     r9d, QB_SECONDARY
    mov     DWORD PTR [rsp + 20h], 999
    call    Inventory_AddItemToSlot

@II_abl:
    mov     rdi, QWORD PTR [def_AmmoBullLight]
    test    rdi, rdi
    jnz     @II_abl_ok
    lea     rcx, [sz_AmmoBulletsLight]
    call    SDK_FindObject
    mov     QWORD PTR [def_AmmoBullLight], rax
    mov     rdi, rax
@II_abl_ok:
    test    rdi, rdi
    jz      @II_abh
    mov     rcx, r12
    mov     rdx, rdi
    xor     r8d, r8d
    mov     r9d, QB_SECONDARY
    mov     DWORD PTR [rsp + 20h], 999
    call    Inventory_AddItemToSlot

@II_abh:
    mov     rdi, QWORD PTR [def_AmmoBullHeavy]
    test    rdi, rdi
    jnz     @II_abh_ok
    lea     rcx, [sz_AmmoBulletsHeavy]
    call    SDK_FindObject
    mov     QWORD PTR [def_AmmoBullHeavy], rax
    mov     rdi, rax
@II_abh_ok:
    test    rdi, rdi
    jz      @II_arockets
    mov     rcx, r12
    mov     rdx, rdi
    xor     r8d, r8d
    mov     r9d, QB_SECONDARY
    mov     DWORD PTR [rsp + 20h], 999
    call    Inventory_AddItemToSlot

@II_arockets:
    mov     rdi, QWORD PTR [def_AmmoRockets]
    test    rdi, rdi
    jnz     @II_ar_ok
    lea     rcx, [sz_AmmoRockets]
    call    SDK_FindObject
    mov     QWORD PTR [def_AmmoRockets], rax
    mov     rdi, rax
@II_ar_ok:
    test    rdi, rdi
    jz      @II_edittool
    mov     rcx, r12
    mov     rdx, rdi
    xor     r8d, r8d
    mov     r9d, QB_SECONDARY
    mov     DWORD PTR [rsp + 20h], 999
    call    Inventory_AddItemToSlot

@II_edittool:
    ; EditTool: Primary slot 0, count 1
    mov     rdi, QWORD PTR [def_EditTool]
    test    rdi, rdi
    jnz     @II_et_ok
    lea     rcx, [sz_EditTool]
    call    SDK_FindObject
    mov     QWORD PTR [def_EditTool], rax
    mov     rdi, rax
@II_et_ok:
    test    rdi, rdi
    jz      @II_activate
    mov     rcx, r12
    mov     rdx, rdi
    xor     r8d, r8d                        ; Slot = 0
    xor     r9d, r9d                        ; Primary = 0
    mov     DWORD PTR [rsp + 20h], 1
    call    Inventory_AddItemToSlot

@II_activate:
    ; ServerActivateSlotInternal(QuickBars, Primary, 0, 0.0f, false)
    mov     rax, QWORD PTR [r12 + PC_QuickBars]
    test    rax, rax
    jz      @II_done
    ; Params: InQuickBar(1B,3pad) + Slot(4) + ActivateDelay(4f) + bUpdate(1B) = 0x10
    xor     edx, edx
    mov     DWORD PTR [rsp + 38h], edx      ; InQuickBar = Primary = 0
    mov     DWORD PTR [rsp + 3Ch], edx      ; Slot = 0
    mov     DWORD PTR [rsp + 40h], edx      ; ActivateDelay = 0.0f
    mov     BYTE PTR [rsp + 44h], 0          ; bUpdatePreviousFocusedSlot = false
    push    rax                             ; save QuickBars
    lea     rsi, [fn_ServerActivateSlotInt]
    lea     rdi, [sz_ServerActivateSlotInt]
    call    Inventory__LoadFn
    pop     rcx                             ; QuickBars
    test    rax, rax
    jz      @II_done
    mov     rdx, rax
    lea     r8, [rsp + 38h]
    call    QWORD PTR [ProcessEvent]

@II_done:
    add     rsp, 80h
    pop     r12
    pop     rdi
    pop     rsi
    pop     rbp
    pop     rbx
    ret
Inventory_Init ENDP

; Inventory_GetDefinitionInSlot
; In : RCX = AFortPlayerControllerAthena*
;      EDX = Slot, R8D = Item, R9D = Bars
; Out: RAX = UFortWorldItemDefinition* or NULL
;
; Thin wrapper: GetEntryInSlot then return entry->ItemDefinition.
; Stack: 0 pushes + sub 28h = 40; X=8; 40 mod 16=8; 8-8=0
Inventory_GetDefinitionInSlot PROC
    sub     rsp, 28h
    call    Inventory_GetEntryInSlot
    test    rax, rax
    jz      @IGDS_null
    mov     rax, QWORD PTR [rax + 018h]     ; entry->ItemDefinition (+0x18)
    add     rsp, 28h
    ret
@IGDS_null:
    xor     eax, eax
    add     rsp, 28h
    ret
Inventory_GetDefinitionInSlot ENDP


; Inventory_GetInstanceFromGuid
; In : RCX = AFortPlayerControllerAthena*
;      RDX = FGuid* (16-byte GUID to search for)
; Out: RAX = UFortWorldItem* or NULL
;
; Scans WorldInventory->Inventory.ItemInstances for matching GUID.
; Stack: 4 pushes (no CALL sites) - no alignment needed at call sites.
Inventory_GetInstanceFromGuid PROC
    push    rbx
    push    rbp
    push    rsi
    push    rdi

    mov     rbx, rcx                        ; RBX = PC
    mov     rsi, rdx                        ; RSI = &Guid

    mov     rdi, QWORD PTR [rbx + PC_WorldInventory]
    test    rdi, rdi
    jz      @IGIG_null

    mov     rcx, QWORD PTR [rdi + AFI_ItemInstances]
    mov     edx, DWORD PTR [rdi + AFI_ItemInstances + 8]
    test    rcx, rcx
    jz      @IGIG_null

    xor     ebp, ebp                        ; i = 0
@IGIG_loop:
    cmp     ebp, edx
    jge     @IGIG_null
    mov     rax, QWORD PTR [rcx + rbp*8]   ; Items[i] (UFortWorldItem*)
    test    rax, rax
    jz      @IGIG_next
    ; Compare [rax + UWI_ItemEntry_ItemGuid] with [rsi]
    mov     r8, QWORD PTR [rax + UWI_ItemEntry_ItemGuid]
    mov     r9, QWORD PTR [rsi]
    cmp     r8, r9
    jne     @IGIG_next
    mov     r8, QWORD PTR [rax + UWI_ItemEntry_ItemGuid + 8]
    mov     r9, QWORD PTR [rsi + 8]
    cmp     r8, r9
    je      @IGIG_found
@IGIG_next:
    inc     ebp
    jmp     @IGIG_loop

@IGIG_found:
    pop     rdi
    pop     rsi
    pop     rbp
    pop     rbx
    ret

@IGIG_null:
    xor     eax, eax
    pop     rdi
    pop     rsi
    pop     rbp
    pop     rbx
    ret
Inventory_GetInstanceFromGuid ENDP


; Inventory_EquipInventoryItem
; In : RCX = AFortPlayerControllerAthena*
;      RDX = FGuid* (item to equip)
;
; Scans ItemInstances for matching GUID, then calls EquipWeaponDefinition.
;
; Stack: 5 pushes (40) + sub 60h (96) = 136; 8-136=0
; Frame: [+00..+1F] shadow; [+20..+2F] spare; [+40..+4F] FGuid copy
Inventory_EquipInventoryItem PROC
    push    rbx
    push    rbp
    push    rsi
    push    rdi
    push    r12
    sub     rsp, 60h

    mov     r12, rcx                        ; R12 = PC
    ; Copy FGuid to frame
    mov     rax, QWORD PTR [rdx]
    mov     QWORD PTR [rsp + 40h], rax
    mov     rax, QWORD PTR [rdx + 8]
    mov     QWORD PTR [rsp + 48h], rax

    ; Pawn = PC->Pawn
    mov     rbx, QWORD PTR [r12 + ACTRL_Pawn]
    test    rbx, rbx
    jz      @IEII_done

    ; WorldInventory
    mov     rdi, QWORD PTR [r12 + PC_WorldInventory]
    test    rdi, rdi
    jz      @IEII_done

    ; ItemInstances
    mov     rsi, QWORD PTR [rdi + AFI_ItemInstances]     ; Data
    mov     edi, DWORD PTR [rdi + AFI_ItemInstances + 8]  ; Num (zero-extends RDI)
    test    rsi, rsi
    jz      @IEII_done

    xor     ebp, ebp                        ; i = 0
@IEII_loop:
    cmp     ebp, edi
    jge     @IEII_done
    mov     rcx, QWORD PTR [rsi + rbp*8]   ; Items[i]
    test    rcx, rcx
    jz      @IEII_next
    ; Compare GUID
    mov     rax, QWORD PTR [rcx + UWI_ItemEntry_ItemGuid]
    cmp     rax, QWORD PTR [rsp + 40h]
    jne     @IEII_next
    mov     rax, QWORD PTR [rcx + UWI_ItemEntry_ItemGuid + 8]
    cmp     rax, QWORD PTR [rsp + 48h]
    jne     @IEII_next

    ; Found - get ItemDef
    mov     rax, QWORD PTR [rcx + UWI_ItemEntry_ItemDef]
    test    rax, rax
    jz      @IEII_next

    ; EquipWeaponDefinition(Pawn, ItemDef, &Guid)
    mov     rcx, rbx
    mov     rdx, rax
    lea     r8, [rsp + 40h]
    call    Inventory_EquipWeaponDefinition
    jmp     @IEII_done

@IEII_next:
    inc     ebp
    jmp     @IEII_loop

@IEII_done:
    add     rsp, 60h
    pop     r12
    pop     rdi
    pop     rsi
    pop     rbp
    pop     rbx
    ret
Inventory_EquipInventoryItem ENDP


; Inventory_EquipLoadout
; In : RCX = AFortPlayerControllerAthena*
;      RDX = UFortWorldItemDefinition*[6] (array of 6 def pointers)
;
; Adds items to primary slots 0-5, then equips slot 0 (pickaxe).
;
; Stack: 5 pushes (40) + sub 60h (96) = 136; 8-136=0
; Frame: [+00..+1F] shadow; [+20..+27] arg5(Count=1 for AddItemToSlot)
Inventory_EquipLoadout PROC
    push    rbx
    push    rbp
    push    rsi
    push    rdi
    push    r12
    sub     rsp, 60h

    mov     r12, rcx                        ; R12 = PC
    mov     rsi, rdx                        ; RSI = WIDS array

    xor     ebx, ebx                        ; i = 0
@IEL_loop:
    cmp     ebx, 6
    jge     @IEL_equip_slot0

    mov     rdi, QWORD PTR [rsi + rbx*8]   ; WIDS[i]
    test    rdi, rdi
    jz      @IEL_next

    ; AddItemToSlot(PC, Definition, Slot=i, Bars=Primary=0, Count=1)
    mov     rcx, r12
    mov     rdx, rdi
    mov     r8d, ebx                        ; Slot
    xor     r9d, r9d                        ; Bars = Primary = 0
    mov     DWORD PTR [rsp + 20h], 1        ; Count (arg5)
    call    Inventory_AddItemToSlot
@IEL_next:
    inc     ebx
    jmp     @IEL_loop

@IEL_equip_slot0:
    ; GetEntryInSlot(PC, Slot=0, Item=0, Bars=Primary=0)
    mov     rcx, r12
    xor     edx, edx
    xor     r8d, r8d
    xor     r9d, r9d
    call    Inventory_GetEntryInSlot
    test    rax, rax
    jz      @IEL_done

    ; EquipInventoryItem(PC, &entry->ItemGuid)
    mov     rcx, r12
    lea     rdx, [rax + 050h]              ; &entry->ItemGuid (+0x50 within FFortItemEntry)
    call    Inventory_EquipInventoryItem

@IEL_done:
    add     rsp, 60h
    pop     r12
    pop     rdi
    pop     rsi
    pop     rbp
    pop     rbx
    ret
Inventory_EquipLoadout ENDP


; Inventory_FindItemInInventory
; In : RCX = AFortPlayerControllerAthena*
;      RDX = UClass* (target class - matched against def->ClassPrivate)
;      R8  = BYTE* bFound (output, may be NULL)
; Out: RAX = &FFortItemEntry (within UFortWorldItem) or NULL
;
; Scans ItemInstances; returns first entry whose definition's ClassPrivate
; exactly equals the target UClass*.  (UObject::ClassPrivate = UObject+0x10)
;
; Stack: 5 pushes (40) + sub 60h (96) = 136; 8-136≡0
; Frame: [+00..+1F] shadow; [+50..+57] bFound ptr save
Inventory_FindItemInInventory PROC
    push    rbx
    push    rbp
    push    rsi
    push    rdi
    push    r12
    sub     rsp, 60h

    mov     r12, rcx                        ; R12 = PC
    mov     rdi, rdx                        ; RDI = target UClass*
    mov     QWORD PTR [rsp + 50h], r8       ; save bFound ptr

    ; bFound = false
    test    r8, r8
    jz      @IFII_scan
    mov     BYTE PTR [r8], 0

@IFII_scan:
    mov     rbx, QWORD PTR [r12 + PC_WorldInventory]
    test    rbx, rbx
    jz      @IFII_null

    mov     rsi, QWORD PTR [rbx + AFI_ItemInstances]    ; Data
    mov     ebp, DWORD PTR [rbx + AFI_ItemInstances + 8] ; Num
    test    rsi, rsi
    jz      @IFII_null

    xor     ebx, ebx                        ; i = 0 (reuse RBX as counter)
@IFII_loop:
    cmp     ebx, ebp
    jge     @IFII_null
    mov     rax, QWORD PTR [rsi + rbx*8]   ; Items[i]
    test    rax, rax
    jz      @IFII_next
    ; def = entry->ItemDefinition
    mov     rcx, QWORD PTR [rax + UWI_ItemEntry_ItemDef]
    test    rcx, rcx
    jz      @IFII_next
    ; def->ClassPrivate at UObject+0x10
    mov     rcx, QWORD PTR [rcx + 010h]
    cmp     rcx, rdi
    jne     @IFII_next

    ; Found - set bFound
    mov     rcx, QWORD PTR [rsp + 50h]
    test    rcx, rcx
    jz      @IFII_found_ptr
    mov     BYTE PTR [rcx], 1
@IFII_found_ptr:
    lea     rax, [rax + UWI_ItemEntry]      ; return &FFortItemEntry
    add     rsp, 60h
    pop     r12
    pop     rdi
    pop     rsi
    pop     rbp
    pop     rbx
    ret

@IFII_next:
    inc     ebx
    jmp     @IFII_loop

@IFII_null:
    xor     eax, eax
    add     rsp, 60h
    pop     r12
    pop     rdi
    pop     rsi
    pop     rbp
    pop     rbx
    ret
Inventory_FindItemInInventory ENDP

END