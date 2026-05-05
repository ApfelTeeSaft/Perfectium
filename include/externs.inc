; sdk_globals.asm - Global UE4 runtime pointers and GObjects
EXTERNDEF   Imagebase               :QWORD  ; base address of FortniteClient-Win64-Shipping.exe
EXTERNDEF   ProcessEvent            :QWORD  ; void (*)(UObject*, UFunction*, void*)
EXTERNDEF   FMemory_Malloc          :QWORD  ; void* (*)(int32 size, int32 alignment)
EXTERNDEF   FMemory_Realloc         :QWORD  ; void* (*)(void* original, int64 count, uint32 alignment)
EXTERNDEF   FMemory_Free            :QWORD  ; void (*)(void* original)
EXTERNDEF   FNameToString           :QWORD  ; void (*)(FName* name, FString& out)
EXTERNDEF   GObjects                :QWORD  ; TUObjectArray* (the global UObject array)

; sdk_globals.asm - Global mutable state
EXTERNDEF   bTraveled               :BYTE   ; bool - has the server traveled yet?
EXTERNDEF   bPlayButton             :BYTE   ; bool - play button clicked?
EXTERNDEF   bListening              :BYTE   ; bool - server is listening?
EXTERNDEF   bStartedBus             :BYTE   ; bool - battle bus launched?
EXTERNDEF   bSpawnedFloorLoot       :BYTE   ; bool - floor loot spawned?
EXTERNDEF   HostBeacon              :QWORD  ; AFortOnlineBeaconHost*
EXTERNDEF   ExistingBuildings       :QWORD  ; pointer to TArray<ABuildingActor*> head (Data ptr)
EXTERNDEF   ExistingBuildingsNum    :DWORD  ; current Num of ExistingBuildings array
EXTERNDEF   ExistingBuildingsMax    :DWORD  ; current Max of ExistingBuildings array

; native.asm - Native:: function-pointer table
; Native::Actor
EXTERNDEF   Native_Actor_GetNetMode             :QWORD
; Native::PlayerController
EXTERNDEF   Native_PlayerController_GetPlayerViewPoint  :QWORD
EXTERNDEF   Native_PlayerController_GetPlayerName       :QWORD
; Native::LocalPlayer
EXTERNDEF   Native_LocalPlayer_SpawnPlayActor           :QWORD
; Native::GC
EXTERNDEF   Native_GC_CollectGarbage                    :QWORD
; Native::AbilitySystemComponent
EXTERNDEF   Native_AbilitySystemComponent_GiveAbility           :QWORD
EXTERNDEF   Native_AbilitySystemComponent_FindAbilitySpecFromHandle :QWORD
EXTERNDEF   Native_AbilitySystemComponent_InternalTryActivateAbility :QWORD
; Native::NetDriver
EXTERNDEF   Native_NetDriver_TickFlush                  :QWORD
; Native::ReplicationDriver
EXTERNDEF   Native_ReplicationDriver_ServerReplicateActors :QWORD
; Native::NetConnection
EXTERNDEF   Native_NetConnection_ReceiveNetGUIDBunch     :QWORD
; Native::OnlineSession
EXTERNDEF   Native_OnlineSession_KickPlayer             :QWORD
; Native::OnlineBeacon
EXTERNDEF   Native_OnlineBeacon_NotifyAcceptingConnection :QWORD
; Native::OnlineBeaconHost
EXTERNDEF   Native_OnlineBeaconHost_NotifyAcceptingConnection :QWORD
EXTERNDEF   Native_OnlineBeaconHost_InitHost            :QWORD
EXTERNDEF   Native_OnlineBeaconHost_PauseBeaconRequests :QWORD
; Native::World
EXTERNDEF   Native_World_NotifyControlMessage           :QWORD
EXTERNDEF   Native_World_WelcomePlayer                  :QWORD
EXTERNDEF   Native_World_SpawnActor                     :QWORD
EXTERNDEF   Native_World_SpawnPlayActor                 :QWORD
EXTERNDEF   Native_World_NotifyAcceptingConnection      :QWORD
EXTERNDEF   Native_World_RemoveNetworkActor             :QWORD
; Native::Engine
EXTERNDEF   Native_Engine_SeamlessTravelHandlerForWorld :QWORD
; Native::GameViewportClient
EXTERNDEF   Native_GameViewportClient_PostRender        :QWORD

; native.asm - InitializeAll entry point
EXTERNDEF   Native_InitializeAll                        :PROC

; patterns.asm - Pattern byte arrays and mask strings (.const)
EXTERNDEF   Pat_FNameToString       :BYTE
EXTERNDEF   Pat_GObjects            :BYTE
EXTERNDEF   Pat_Free                :BYTE
EXTERNDEF   Pat_Malloc              :BYTE
EXTERNDEF   Pat_Realloc             :BYTE
EXTERNDEF   Pat_ReceiveFString      :BYTE
EXTERNDEF   Pat_ReceiveUniqueIdRepl :BYTE
EXTERNDEF   Pat_TickFlush           :BYTE
EXTERNDEF   Pat_PauseBeaconRequests :BYTE
EXTERNDEF   Pat_BeaconNotifyAccept  :BYTE
EXTERNDEF   Pat_InitHost            :BYTE
EXTERNDEF   Pat_BeaconNotifyCtrl    :BYTE
EXTERNDEF   Pat_WelcomePlayer       :BYTE
EXTERNDEF   Pat_WorldNotifyCtrl     :BYTE
EXTERNDEF   Pat_SpawnPlayActor      :BYTE
EXTERNDEF   Pat_WorldNotifyAccept   :BYTE
EXTERNDEF   Pat_GetNetMode          :BYTE
EXTERNDEF   Pat_GiveAbility         :BYTE
EXTERNDEF   Pat_InternalTryActivate :BYTE
EXTERNDEF   Pat_MarkAbilitySpecDirty:BYTE
EXTERNDEF   Pat_LocalPlayerSpawnPA  :BYTE
EXTERNDEF   Pat_GetPlayerViewPoint  :BYTE
EXTERNDEF   Pat_KickPlayer          :BYTE
EXTERNDEF   Pat_InitListen          :BYTE
EXTERNDEF   Pat_PostRender          :BYTE
EXTERNDEF   Pat_CollectGarbage      :BYTE
EXTERNDEF   Pat_NetDebug            :BYTE

; util.asm - Utility functions
EXTERNDEF   Utils_FindPattern       :PROC   ; (RCX=pszPattern, EDX=bRelative, R8D=offset) -> RAX:QWORD (address or 0)
EXTERNDEF   Utils_Sin               :PROC   ; (angle:REAL4) -> REAL4 (result in XMM0)
EXTERNDEF   Utils_Cos               :PROC   ; (angle:REAL4) -> REAL4 (result in XMM0)
EXTERNDEF   Utils_RotToQuat         :PROC   ; (rot:PTR FRotator, out_quat:PTR FQuat)
EXTERNDEF   Utils_VecToRot          :PROC   ; (vec:PTR FVector, out_rot:PTR FRotator)
EXTERNDEF   Utils_RandomIntInRange  :PROC   ; (min:DWORD, max:DWORD) -> DWORD

; logger.asm - switched to sprintf
EXTERNDEF   Logger_Initialize       :PROC   ; ()
EXTERNDEF   Logger_LogInfo          :PROC   ; (RCX=msg:PTR BYTE)
EXTERNDEF   Logger_LogWarn          :PROC   ; (RCX=msg:PTR BYTE)
EXTERNDEF   Logger_LogError         :PROC   ; (RCX=msg:PTR BYTE)
EXTERNDEF   Logger_LogInfoFmt       :PROC   ; (RCX=fmt:PTR BYTE, RDX/R8/R9=args) - printf passthrough

; hooks.asm - All hook implementations
EXTERNDEF   Hooks_TickFlush                         :PROC
EXTERNDEF   Hooks_ProcessEventHook                  :PROC
EXTERNDEF   Hooks_LocalPlayerSpawnPlayActor         :PROC
EXTERNDEF   Hooks_SpawnPlayActor                    :PROC
EXTERNDEF   Hooks_NetDebug                          :PROC
EXTERNDEF   Hooks_GetPlayerViewPoint                :PROC
EXTERNDEF   Hooks_CollectGarbage                    :PROC
EXTERNDEF   Hooks_GetNetMode                        :PROC
EXTERNDEF   Hooks_SeamlessTravelHandlerForWorld     :PROC
EXTERNDEF   Hooks_WelcomePlayer                     :PROC
EXTERNDEF   Hooks_KickPlayer                        :PROC
EXTERNDEF   Hooks_World_NotifyControlMessage        :PROC
EXTERNDEF   Hooks_Beacon_NotifyAcceptingConnection  :PROC
EXTERNDEF   Hooks_Beacon_NotifyControlMessage       :PROC
EXTERNDEF   Hooks_PostRender                        :PROC
EXTERNDEF   Hooks_InitNetworkHooks                  :PROC

; ufunctionhooks.asm - UFunction dispatch hooks
EXTERNDEF   UFunctionHooks_Initialize   :PROC
EXTERNDEF   UFunctionHooks_ToHook_Data  :QWORD  ; base of UFunction* array
EXTERNDEF   UFunctionHooks_ToHook_Num   :DWORD  ; count of registered hooks
EXTERNDEF   UFunctionHooks_ToCall_Data  :QWORD  ; base of handler QWORD* array (BYTE (*)(UObject*,void*))

; sdk/sdk_classes.asm - UObject / GObjects accessors
EXTERNDEF   SDK_GetObjectByIndex    :PROC   ; (index:DWORD) -> QWORD (UObject*)
EXTERNDEF   SDK_FindObject          :PROC   ; (name:PTR BYTE) -> QWORD (UObject*)
EXTERNDEF   SDK_FindClass           :PROC   ; (name:PTR BYTE) -> QWORD (UClass*)
EXTERNDEF   SDK_GetWorld            :PROC   ; () -> QWORD (UWorld*)
EXTERNDEF   SDK_GetEngine           :PROC   ; () -> QWORD (UFortEngine*)

; sdk/sdk_classes.asm - TArray helpers (element-size-agnostic)
EXTERNDEF   TArray_Num              :PROC   ; (arr:PTR TArrayHeader) -> DWORD
EXTERNDEF   TArray_GetByIndex       :PROC   ; (arr:PTR TArrayHeader, idx:DWORD, elem_size:DWORD) -> QWORD
EXTERNDEF   TArray_Add              :PROC   ; (arr:PTR TArrayHeader, elem:PTR BYTE, elem_size:DWORD) -> DWORD
EXTERNDEF   TArray_RemoveAt         :PROC   ; (arr:PTR TArrayHeader, idx:DWORD, elem_size:DWORD)
EXTERNDEF   TArray_RemoveSingle     :PROC   ; (arr:PTR TArrayHeader, elem:PTR BYTE, elem_size:DWORD) -> BYTE
EXTERNDEF   TArray_FreeArray        :PROC   ; (arr:PTR TArrayHeader)

; sdk/sdk_classes.asm - FString helpers
EXTERNDEF   FString_FromWideChar    :PROC   ; (out:PTR TArrayHeader, wstr:PTR WORD)
EXTERNDEF   FString_Free            :PROC   ; (str:PTR TArrayHeader)

; sdk/sdk_fort.asm - Fortnite-specific helpers
EXTERNDEF   FortHelper_GetAbilitySystemComponent :PROC  ; (pawn:QWORD) -> QWORD
EXTERNDEF   FortHelper_GetWorldInventory         :PROC  ; (pc:QWORD) -> QWORD
EXTERNDEF   FortHelper_GetQuickBars              :PROC  ; (pc:QWORD) -> QWORD
EXTERNDEF   SDK_CreateConsole                    :PROC  ; () - spawns UConsole on GameViewport

; logic/game.asm
EXTERNDEF   Game_Start                  :PROC
EXTERNDEF   Game_OnReadyToStartMatch    :PROC
EXTERNDEF   Game_GetDeathCause          :PROC   ; (report:PTR FFortPlayerDeathReport) -> DWORD (EDeathCause)

; logic/inventory.asm
EXTERNDEF   Inventory_Update                :PROC   ; (pc:QWORD, dirty:DWORD, bRemovedItem:BYTE)
EXTERNDEF   Inventory_IsValidGuid           :PROC   ; (pc:QWORD, guid:PTR FGuid) -> BYTE
EXTERNDEF   Inventory_IsGuidInInventory     :PROC   ; (pc:QWORD, guid:PTR FGuid) -> BYTE
EXTERNDEF   Inventory_GetEntryInSlot        :PROC   ; (pc:QWORD, slot:DWORD, item:DWORD, bars:DWORD) -> PTR FFortItemEntry
EXTERNDEF   Inventory_GetDefinitionInSlot   :PROC   ; (pc:QWORD, slot:DWORD, item:DWORD, bars:DWORD) -> PTR UFortWorldItemDefinition
EXTERNDEF   Inventory_GetInstanceFromGuid   :PROC   ; (pc:QWORD, guid:PTR FGuid) -> PTR UFortWorldItem
EXTERNDEF   Inventory_FindItemInInventory   :PROC   ; (pc:QWORD, class:QWORD, bFound:PTR BYTE) -> PTR FFortItemEntry
EXTERNDEF   Inventory_AddItemToSlot         :PROC   ; (pc:QWORD, def:QWORD, slot:DWORD, bars:DWORD, count:DWORD) -> PTR FFortItemEntry
EXTERNDEF   Inventory_RemoveItemFromSlot    :PROC   ; (pc:QWORD, slot:DWORD, bars:DWORD, amount:DWORD)
EXTERNDEF   Inventory_IsGuidInInventory     :PROC   ; (pc:QWORD, guid:PTR FGuid) -> BYTE
EXTERNDEF   Inventory_EquipWeaponDefinition :PROC   ; (pawn:QWORD, def:QWORD, guid:PTR FGuid)
EXTERNDEF   Inventory_EquipInventoryItem    :PROC   ; (pc:QWORD, guid:PTR FGuid)
EXTERNDEF   Inventory_EquipLoadout          :PROC   ; (pc:QWORD, wids:PTR QWORD[6])
EXTERNDEF   Inventory_OnDrop                :PROC   ; (pc:QWORD, params:PTR) -> BYTE
EXTERNDEF   Inventory_OnPickup              :PROC   ; (pc:QWORD, params:PTR)
EXTERNDEF   Inventory_Init                  :PROC   ; (pc:QWORD)

; logic/abilities.asm
EXTERNDEF   Abilities_TryActivateAbility        :PROC
EXTERNDEF   Abilities_GrantGameplayAbility      :PROC   ; (pawn:QWORD, abilityClass:QWORD)
EXTERNDEF   Abilities_ApplyAbilities            :PROC   ; (pawn:QWORD)
EXTERNDEF   Abilities_ConsumeAllReplicatedData  :PROC

; logic/spawners.asm
EXTERNDEF   Spawners_SpawnActor             :PROC   ; (actorClass:QWORD, location:PTR FVector, owner:QWORD) -> QWORD
EXTERNDEF   Spawners_SpawnActor_ByLocation  :PROC   ; (actorClass:QWORD, location:PTR FVector, rotation:PTR FRotator, owner:QWORD) -> QWORD
EXTERNDEF   Spawners_SummonPickup           :PROC   ; (pawn:QWORD, itemDef:QWORD, count:DWORD, loc:PTR FVector) -> QWORD
EXTERNDEF   Spawners_SummonPickupFromChest  :PROC   ; (itemDef:QWORD, count:DWORD, loc:PTR FVector)
EXTERNDEF   Spawners_SpawnPickupFromFloor   :PROC   ; (itemDef:QWORD, count:DWORD, loc:PTR FVector)
EXTERNDEF   Spawners_SpawnDeco              :PROC   ; (tool:QWORD, params:QWORD)
EXTERNDEF   Spawners_SpawnBuilding          :PROC   ; (buildClass:QWORD, transform:PTR FTransform, owner:QWORD) -> QWORD

; logic/teams.asm
EXTERNDEF   Team_New                    :PROC   ; (teamPos:DWORD, maxSize:DWORD) -> QWORD (Team*)
EXTERNDEF   Team_AddPlayer              :PROC   ; (team:QWORD, pc:QWORD)
EXTERNDEF   Team_Kick                   :PROC   ; (team:QWORD)
EXTERNDEF   Team_Num                    :PROC   ; (team:QWORD) -> DWORD
EXTERNDEF   Team_InitializePlayer       :PROC   ; (team:QWORD, pc:QWORD)
EXTERNDEF   PlayerTeams_New             :PROC   ; (maxTeamSize:DWORD) -> QWORD
EXTERNDEF   PlayerTeams_GetNextSlot     :PROC   ; (pt:QWORD) -> DWORD
EXTERNDEF   PlayerTeams_FindAvailableSpot :PROC ; (pt:QWORD) -> QWORD (Team*)
EXTERNDEF   PlayerTeams_AddPlayerToTeam :PROC   ; (pt:QWORD, pc:QWORD)
EXTERNDEF   PlayerTeams_AddPlayerToRandomTeam :PROC

; gamemodes/gamemode_base.asm
EXTERNDEF   GameModeBase_InitPawn           :PROC
EXTERNDEF   GameModeBase_LoadPlayer         :PROC
EXTERNDEF   GameModeBase_Respawn            :PROC
EXTERNDEF   GameModeBase_OnPlayerDeath      :PROC
EXTERNDEF   GameModeBase_StartMatch         :PROC

; gamemodes/gamemode_solos.asm
EXTERNDEF   GameModeSolos_Initialize    :PROC

; gamemodes/gamemode_duos.asm
EXTERNDEF   GameModeDuos_Initialize     :PROC

; gamemodes/gamemode_50v50.asm
EXTERNDEF   GameMode50v50_Initialize    :PROC

; gamemodes/gamemode_playground.asm
EXTERNDEF   GameModePlayground_Initialize :PROC

; gamemodes/gamemode_lategame.asm
EXTERNDEF   GameModeLateGame_Initialize :PROC

; gui.asm / zerogui.asm / zeroinput.asm
EXTERNDEF   GUI_Tick                :PROC
EXTERNDEF   ZeroGUI_SetupCanvas     :PROC
EXTERNDEF   ZeroGUI_Begin           :PROC
EXTERNDEF   ZeroGUI_End             :PROC
EXTERNDEF   ZeroInput_Update        :PROC

; Windows API
EXTRN   AllocConsole                :PROC
EXTRN   CreateThread                :PROC
EXTRN   GetModuleHandleA            :PROC
EXTRN   GetCurrentThread            :PROC
EXTRN   IsBadReadPtr                :PROC
EXTRN   GetAsyncKeyState            :PROC
EXTRN   Sleep                       :PROC
EXTRN   ExitThread                  :PROC
EXTRN   RtlZeroMemory               :PROC

; Microsoft Detours
EXTRN   DetourTransactionBegin      :PROC
EXTRN   DetourTransactionCommit     :PROC
EXTRN   DetourTransactionAbort      :PROC
EXTRN   DetourUpdateThread          :PROC
EXTRN   DetourAttach                :PROC
EXTRN   DetourDetach                :PROC

; C runtime helpers
EXTRN   memcpy                      :PROC
EXTRN   memmove                     :PROC
EXTRN   memset                      :PROC
EXTRN   memcmp                      :PROC
EXTRN   strcmp                      :PROC