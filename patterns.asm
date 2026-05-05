.const

; Core UE4 globals
Pat_FNameToString       DB "48 89 5C 24 ? 57 48 83 EC 40 83 79 04 00 48 8B DA 48 8B F9", 0
Pat_GObjects            DB "48 8B 05 ? ? ? ? 48 8D 1C C8 81 4B ? ? ? ? ? 49 63 76 30", 0

; FMemory
Pat_Free                DB "48 85 C9 74 1D 4C 8B 05 ? ? ? ? 4D 85 C0 0F 84 ? ? ? ? 49 8B 00 48 8B D1 49 8B C8 48 FF 60 20 C3", 0
Pat_Malloc              DB "4C 8B C9 48 8B 0D ? ? ? ? 48 85 C9 75 08 49 8B C9 E9 ? ? ? ?", 0
Pat_Realloc             DB "4C 8B D1 48 8B 0D ? ? ? ? 48 85 C9 75 08 49 8B CA E9 ? ? ? ? 48 8B 01 45 8B C8 4C 8B C2 49 8B D2 48 FF 60 18", 0

; Net connection helpers
Pat_ReceiveFString      DB "40 55 53 56 57 41 56 48 8D 6C 24 ? 48 81 EC ? ? ? ? 48 8B 05 ? ? ? ? 48 33 C4 48 89 45 27 0F B6 41 28", 0
Pat_ReceiveUniqueIdRepl DB "48 89 5C 24 ? 55 56 57 48 8B EC 48 83 EC 40 F6 41 28 40 48 8B FA 48 8B D9 0F 84 ? ? ? ? F6 41 2B 02", 0

; NetDriver / Beacon
Pat_TickFlush           DB "4C 8B DC 55 49 8D AB ? ? ? ? 48 81 EC ? ? ? ? 48 8B 05 ? ? ? ? 48 33 C4 48 89 85 ? ? ? ? 49 89 5B 18 48 8D 05 ? ? ? ? 49 89 7B E8 48 8B F9 4D 89 63 E0 45 33 E4", 0
Pat_PauseBeaconRequests DB "40 53 48 83 EC 30 48 8B D9 84 D2 74 68 80 3D ? ? ? ? ? 72 2C 48 8B 05 ? ? ? ? 4C 8D 44 24 ? 48 89 44 24 ?", 0
Pat_BeaconNotifyAccept  DB "48 83 EC 48 48 8B 41 10 48 83 78 ? ?", 0
Pat_InitHost            DB "48 8B C4 48 81 EC ? ? ? ? 48 89 58 18 4C 8D 05 ? ? ? ?", 0
Pat_BeaconNotifyCtrl    DB "40 55 53 56 57 41 54 41 56 41 57 48 8D AC 24 ? ? ? ? 48 81 EC ? ? ? ? 48 8B 05 ? ? ? ? 48 33 C4 48 89 85 ? ? ? ? 33 FF 48 89 4C 24 ? 89 7C 24 60 49 8B F1 48 8B 41 10 45 0F B6 E0 4C 8B F2 48 8B D9 44 8B FF 48 39 78 78 0F 85 ? ? ? ? 80 3D ? ? ? ? ?", 0

; World / Engine
Pat_WelcomePlayer       DB "48 8B C4 55 48 8D A8 ? ? ? ? 48 81 EC ? ? ? ? 48 89 70 20", 0
Pat_WorldNotifyCtrl     DB "40 55 53 56 57 41 54 41 55 41 56 41 57 48 8D AC 24 ? ? ? ? 48 81 EC ? ? ? ? 48 8B 05 ? ? ? ? 48 33 C4 48 89 85 ? ? ? ? 45 33 F6 49 8B D9 44 89 74 24 ? 45 8B E6 48 8B 41 10 45 0F B6 F8 48 8B FA 4C 8B E9 4C 39 60 78", 0
Pat_SpawnPlayActor      DB "44 89 44 24 ? 48 89 54 24 ? 48 89 4C 24 ? 55 53 56 57 41 54 41 55 41 56 41 57 48 8D 6C 24 ? 48 81 EC ? ? ? ? 33 F6 48 8D 05 ? ? ? ? 89 75 67 4D 8B E9 4C 8B 65 77 49 39 04 24 74 2A 41 89 74 24 ? 41 39 74 24 ?", 0
Pat_WorldNotifyAccept   DB "40 55 48 83 EC 50 48 8B 41 10 48 8B E9 48 83 78 ? ? 74 45 80 3D ? ? ? ? ? 72 34 48 8B 05 ? ? ? ? 4C 8D 44 24 ? 48 89 44 24 ? 48 8D 0D ? ? ? ? 48 8D 05 ? ? ? ? 41 B9 ? ? ? ? BA ? ? ? ? 48 89 44 24 ?", 0
Pat_GetNetMode          DB "48 89 5C 24 ? 57 48 83 EC 20 48 8B 01 48 8B D9 FF 90 ? ? ? ? 4C 8B 83 ? ? ? ? 48 8B F8 33 C0 48 C7 44 24", 0

; Ability System
Pat_GiveAbility         DB "48 89 5C 24 ? 56 57 41 56 48 83 EC 20 83 B9 ? ? ? ? ? 49 8B F0 4C 8B F2 48 8B D9 7E 61", 0
Pat_InternalTryActivate DB "4C 89 4C 24 ? 4C 89 44 24 ? 89 54 24 10 55 53 56 57 41 54 41 57 48 8D AC 24", 0
Pat_MarkAbilitySpecDirty DB "48 89 5C 24 ? 57 48 83 EC 20 80 B9 ? ? ? ? ? 48 8B FA 48 8B D9 75 4A C6 81", 0

; Player
Pat_LocalPlayerSpawnPA  DB "40 55 53 56 57 41 56 41 57 48 8D 6C 24 ? 48 81 EC ? ? ? ? 48 8B 05 ? ? ? ? 48 33 C4 48 89 45 40 48 8B D9 4D 8B F1 49 8B C9 4D 8B F8 48 8B F2", 0
Pat_GetPlayerViewPoint  DB "48 89 5C 24 ? 48 89 74 24 ? 55 41 56 41 57 48 8B EC 48 83 EC 50 48 8B F2 48 C7 45 ? ? ? ? ? 48 8B 55 D0 4D 8B F0 48 8B D9 45 33 FF E8 ? ? ? ? 84 C0 74 4A 80 BB ? ? ? ? ? 75 41", 0
Pat_KickPlayer          DB "48 89 5C 24 ? 48 89 74 24 ? 57 48 83 EC 20 49 8B F0 48 8B DA 48 85 D2 74 ? 48 8B BA ? ? ? ? 48", 0

; Misc
Pat_InitListen          DB "48 89 5C 24 ? 48 89 74 24 ? 57 48 83 EC 50 48 8B BC 24 ? ? ? ? 49 8B F0", 0
Pat_PostRender          DB "48 89 74 24 ? 57 48 81 EC ? ? ? ? 80 B9 ? ? ? ? ? 48 8B F2", 0
Pat_CollectGarbage      DB "E8 ? ? ? ? EB 26 40 38 3D ? ? ? ?", 0

; Hook-specific patterns
Pat_NetDebug            DB "40 55 56 41 56 48 8D AC 24 ? ? ? ? 48 81 EC ? ? ? ? 48 8B 05 ? ? ? ? 48 33 C4 48 89 85 ? ? ? ? 48 8B 01 48 8B F1 FF 90 ? ? ? ? 4C 8B F0 48 85 C0 0F", 0

END