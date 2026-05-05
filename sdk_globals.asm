INCLUDE include\master.inc

.data?

; Core UE4 runtime function pointers
ProcessEvent            QWORD   ?   ; void (*)(UObject*, UFunction*, void*)
Imagebase               QWORD   ?   ; uintptr_t — base of game .exe module

FMemory_Malloc          QWORD   ?   ; void* (*)(int32 size, int32 alignment)
FMemory_Realloc         QWORD   ?   ; void* (*)(void* mem, int64 newSize, uint32 align)
FMemory_Free            QWORD   ?   ; void  (*)(void* mem)
FNameToString           QWORD   ?   ; void  (*)(FName* this, FString& out)
GObjects                QWORD   ?   ; TUObjectArray* — global UObject table

; Native:: function pointers
; Actor
Native_Actor_GetNetMode                         QWORD   ?

; PlayerController
Native_PlayerController_GetPlayerViewPoint      QWORD   ?

; LocalPlayer
Native_LocalPlayer_SpawnPlayActor               QWORD   ?

; Garbage collection
Native_GC_CollectGarbage                        QWORD   ?

; AbilitySystemComponent
Native_AbilitySystemComponent_GiveAbility               QWORD   ?
Native_AbilitySystemComponent_InternalTryActivateAbility QWORD  ?
Native_AbilitySystemComponent_MarkAbilitySpecDirty      QWORD   ?
Native_AbilitySystemComponent_FindAbilitySpecFromHandle QWORD   ?

; NetDriver
Native_NetDriver_TickFlush                      QWORD   ?
Native_NetDriver_InitListen                     QWORD   ?

; ReplicationDriver
Native_ReplicationDriver_ServerReplicateActors  QWORD   ?

; NetConnection
Native_NetConnection_ReceiveFString             QWORD   ?
Native_NetConnection_ReceiveUniqueIdRepl        QWORD   ?

; OnlineSession
Native_OnlineSession_KickPlayer                 QWORD   ?

; OnlineBeacon
Native_OnlineBeacon_PauseBeaconRequests         QWORD   ?
Native_OnlineBeacon_NotifyAcceptingConnection   QWORD   ?

; OnlineBeaconHost
Native_OnlineBeaconHost_InitHost                QWORD   ?
Native_OnlineBeaconHost_NotifyControlMessage    QWORD   ?
Native_OnlineBeaconHost_NotifyAcceptingConnection QWORD ?
Native_OnlineBeaconHost_PauseBeaconRequests     QWORD   ?

; World
Native_World_RemoveNetworkActor                 QWORD   ?
Native_World_WelcomePlayer                      QWORD   ?
Native_World_NotifyControlMessage               QWORD   ?
Native_World_SpawnActor                         QWORD   ?
Native_World_SpawnPlayActor                     QWORD   ?
Native_World_NotifyAcceptingConnection          QWORD   ?

; Engine
Native_Engine_SeamlessTravelHandlerForWorld     QWORD   ?

; GameViewportClient
Native_GameViewportClient_PostRender            QWORD   ?

; Game state globals
bTraveled               BYTE    ?   ; bool — server has traveled to map
bPlayButton             BYTE    ?   ; bool — play button clicked
bListening              BYTE    ?   ; bool — server is listening for connections
bStartedBus             BYTE    ?   ; bool — battle bus has launched
bSpawnedFloorLoot       BYTE    ?   ; bool — floor loot has been spawned
                        BYTE    3 DUP (?)   ; pad to QWORD boundary

; Pointer globals
HostBeacon              QWORD   ?   ; AFortOnlineBeaconHost*

; ExistingBuildings — std::vector<ABuildingActor*> represented as TArrayHeader
; Layout matches TArrayHeader: Data(QWORD), Count(DWORD), Max(DWORD)
ExistingBuildings       QWORD   ?   ; Data: ABuildingActor** array ptr
ExistingBuildingsNum    DWORD   ?   ; Count
ExistingBuildingsMax    DWORD   ?   ; Max

END