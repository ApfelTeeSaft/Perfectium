; EFortCustomPartType
EFortCustomPartType_Head        EQU 0
EFortCustomPartType_Body        EQU 1
EFortCustomPartType_Hat         EQU 2
EFortCustomPartType_Backpack    EQU 3
EFortCustomPartType_Charm       EQU 4
EFortCustomPartType_Face        EQU 5
EFortCustomPartType_NumTypes    EQU 6

; EFortTeam
EFortTeam_HumanCampaign         EQU 0
EFortTeam_Monster               EQU 1
EFortTeam_HumanPvP_Team1        EQU 2
EFortTeam_HumanPvP_Team2        EQU 3
EFortTeam_Spectator             EQU 103
EFortTeam_MAX                   EQU 104

; EAthenaGamePhase
EAthenaGamePhase_None           EQU 0
EAthenaGamePhase_Setup          EQU 1
EAthenaGamePhase_Warmup         EQU 2
EAthenaGamePhase_Aircraft       EQU 3
EAthenaGamePhase_SafeZones      EQU 4
EAthenaGamePhase_EndGame        EQU 5
EAthenaGamePhase_Count          EQU 6

; EClassRepNodeMapping
EClassRepNodeMapping_NotRouted              EQU 0
EClassRepNodeMapping_RelevantAllConnections EQU 1
EClassRepNodeMapping_Spatialize_Static      EQU 2
EClassRepNodeMapping_Spatialize_Dynamic     EQU 3
EClassRepNodeMapping_Spatialize_Dormancy    EQU 4

; ESpawnActorCollisionHandlingMethod
ESpawnCollision_Undefined                           EQU 0
ESpawnCollision_AlwaysSpawn                         EQU 1
ESpawnCollision_AdjustIfPossibleButAlwaysSpawn      EQU 2
ESpawnCollision_AdjustIfPossibleButDontSpawnIfColliding EQU 3
ESpawnCollision_DontSpawnIfColliding                EQU 4

; EDynamicBuildingPlacementType
EDynBuildPlace_CountsTowardsBounds          EQU 0
EDynBuildPlace_DestroyIfColliding           EQU 1
EDynBuildPlace_DestroyAnythingThatCollides  EQU 2

; EFortBuildingType
EFortBuildingType_Wall          EQU 0
EFortBuildingType_Floor         EQU 1
EFortBuildingType_Corner        EQU 2
EFortBuildingType_Deco          EQU 3
EFortBuildingType_Prop          EQU 4
EFortBuildingType_Stairs        EQU 5
EFortBuildingType_Roof          EQU 6
EFortBuildingType_Pillar        EQU 7
EFortBuildingType_SpawnedItem   EQU 8
EFortBuildingType_Container     EQU 9
EFortBuildingType_Trap          EQU 10
EFortBuildingType_None          EQU 12

; ETravelType
ETravelType_Absolute            EQU 0
ETravelType_Partial             EQU 1
ETravelType_Relative            EQU 2

; EMontagePlayReturnType
EMontagePlayReturnType_MontageLength    EQU 0
EMontagePlayReturnType_Duration         EQU 1

; EMovementMode
EMovementMode_None              EQU 0
EMovementMode_Walking           EQU 1
EMovementMode_NavWalking        EQU 2
EMovementMode_Falling           EQU 3
EMovementMode_Swimming          EQU 4
EMovementMode_Flying            EQU 5
EMovementMode_Custom            EQU 6
EMovementMode_MAX               EQU 7

MOVE_CUSTOM_SKYDIVE             EQU 4

; ENetRole
ENetRole_None                   EQU 0
ENetRole_SimulatedProxy         EQU 1
ENetRole_AutonomousProxy        EQU 2
ENetRole_Authority              EQU 3

; ENetMode
ENetMode_Standalone             EQU 0
ENetMode_DedicatedServer        EQU 1
ENetMode_ListenServer           EQU 2
ENetMode_Client                 EQU 3

; DLL reason codes
DLL_PROCESS_DETACH              EQU 0
DLL_PROCESS_ATTACH              EQU 1
DLL_THREAD_ATTACH               EQU 2
DLL_THREAD_DETACH               EQU 3

; Vtable slot indices
VTABLE_SLOT_ProcessEvent        EQU 40h  ; = 64 decimal
VTABLE_SLOT_ServerReplicateActors EQU 53h ; = 83 decimal - on UReplicationDriver

; Network message type codes (NMT_ values)
NMT_Netspeed                    EQU 4
NMT_Login                       EQU 5
NMT_PCSwap                      EQU 15

; EFortQuickBars
EFortQuickBars_Primary          EQU 0
EFortQuickBars_Secondary        EQU 1
EFortQuickBars_Count            EQU 2

; Misc numeric constants from source
MAXPLAYERS                      EQU 100
LISTEN_BEACON_PORT              EQU 7776
LISTEN_GAME_PORT                EQU 7777
REPAIR_AMOUNT                   EQU 50
BACKPACK_SIZE                   EQU 100
DEFAULT_NETSPEED                EQU 30000
MAX_HEALTH                      EQU 100
MAX_SHIELD                      EQU 100
RESPAWN_EXTRA_Z                 EQU 3000
