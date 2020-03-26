/*Libraries*/
#include <a_samp>
#include <crashdetect>
#include <streamer>
#include <sscanf2>
#include <colandreas>
#include <a_mysql>
#include <easyDialog>
#include <Pawn.CMD>
#include <foreach>
#include <FCNPC>
#include <mapandreas>
#include <PathFinder>
#include <YSI\y_timers>


#define TRYG3D_COLANDREAS
#define ENABLE_3D_TRYG_YSI_SUPPORT
#include <3DTryg>

/*Undefinitions*/
#if defined MAX_PLAYERS
    #undef MAX_PLAYERS
#endif

/*Definitions*/
#define strcpy(%0,%1,%2) strcat((%0[0] = '\0', %0), %1, %2)
#define RandomEx(%0,%1) (random(%1 - %0) + %0)
#define MAX_PLAYERS         (500)

#define DEFAULT_DISTANCE    20.0
#define DROP_FISH           100
#define DROP_CRAFT          100
#define DROP_TALENT         50
#define RED_ZONE_TIMER		15 // Minutes
#define RED_ZONE_MISSILE_TIMER 1 // Minutes

#define SERVER_NAME         "WORKS IN PROGRESS."
#define SERVER_WEB          "WORKS IN PROGRESS."
#define SERVER_MAP          "Pandemonium"
#define SERVER_LANG         "Turkish"
#define SERVER_VERSION      "v0.0.2"

#define MYSQL_HOST          "localhost"
#define MYSQL_USER          "root"
#define MYSQL_PASSWORD      ""
#define MYSQL_DATABASE      "apocalypse"

#define SECONDS_TO_LOGIN    (45)
#define MIN_PASSCHAR		(6)
#define MAX_PASSCHAR		(24)
#define MAX_LATTEMPT        (3)
#define DEFAULT_CHARSLOT    (3)
#define MAX_CHARSLOT        (6)
#define LIMIT_TALENT        (100)
#define MAX_AIRDROP			(25)
#define MAX_LPLACE          (50)
#define MAX_GAS_PUMPS       (78)
#define MAX_TENT            (250)
#define LEVEL_EXP			(4)

/*Default spawn point: Las Venturas(The High Roller)*/
#define DEFAULT_POS_X                   1958.3783
#define DEFAULT_POS_Y                   1343.1572
#define DEFAULT_POS_Z                   15.3746
#define DEFAULT_POS_A                   270.0
#define DEFAULT_INTERIOR                (0)
#define DEFAULT_VW                      (0)

#define ROLEPLAY_NAME_FALSE            (0)
#define ROLEPLAY_NAME_TRUE             (1)
#define ROLEPLAY_NAME_UNCAPPED         (2)
#define ROLEPLAY_NAME_CONTAINS_NUMBERS (3)

#define GENDER_MALE   (1)
#define GENDER_FEMALE (2)

#define MIN_AGE (18)
#define MAX_AGE (75)
#define MAX_INVENTORY_SLOT (50)

#define JOB_SOLDIER  (0)
#define JOB_POLICE   (1)
#define JOB_MECHANIC (2)
#define JOB_DOCTOR   (3)
#define JOB_NURSE    (4)
#define JOB_CHEF     (5)
#define JOB_ARTISAN  (6)
#define JOB_ENGINEER (7)

#define PLAYER    (0)
#define TESTER1   (1)
#define TESTER2   (2)
#define TESTER3   (3)
#define GADMIN1   (4)
#define GADMIN2   (5)
#define GADMIN3   (6)
#define DEVELOPER (7)
#define LEADADMIN (8)
#define FOUNDER   (9)

#define MAX_NPC_NAME	(32)
#define MAX_DYNAMIC_NPC	(500)

#define NPC_BITES		(0)
#define NPC_NOT_BITES	(1)

#define	TICK_RATE_ATTACK_AFTER_DAM	(300)

#define HERD_EMPTY			(0)
#define HERD_WALKING		(1)
#define HERD_STOPPED		(2)

#define COLOR_GREEN         (0x33AA3300)
#define COLOR_LIGHTRED      (0xFF8282FF)
#define COLOR_GREY          (0xAFAFAFFF)
#define COLOR_PURPLE        (0xD0AEEBFF)
#define COLOR_CLIENT        (0xAAC4E5FF)
#define COLOR_WHITE         (0xFFFFFFFF)
#define COLOR_YELLOW        (0xFFFF00AA)
#define COLOR_LIMEYELLOW    (0xFFFF90FF)

#define     RANGE_NPC_START_CHASE       (12.0)
#define     RANGE_NPC_LOOSE_PLAYER      (25.0)
#define		NPC_RUN_OFFSET				(0.9)

#define		PATHFINDER_Z_DIFF	    	(1.1)
#define		PATHFINDER_STEP_SIZE    	(1)
#define		PATHFINDER_STEP_LIMIT	    (-1)
#define		PATHFINDER_MAX_STEPS	    (50)

#define SwapInt(%0,%1) (((%0) ^= (%1)), ((%1) ^= (%0)), ((%0) ^= (%1)))

#define SendServerMessage(%0,%1) \
	SendClientMessageEx(%0, 0x03fc39FF, "[Z]{C8C8C8} "%1)

#define SendSyntaxMessage(%0,%1) \
	SendClientMessageEx(%0, 0xfcad00FF, "[Z]{C8C8C8} "%1)

#define SendErrorMessage(%0,%1) \
	SendClientMessageEx(%0, 0xff0000FF, "[Z]{C8C8C8} "%1)

/*Veriables*/
new MySQL: SQL_Handle;
new SQL_RaceCheck[MAX_PLAYERS];
new BlockMap;
new Text:Blind;
new Text:Blind2;

/*Enums*/
enum Enum_Accounts
{
	Account_SQL,
	Cache:Account_CacheID,

	Account_Name[MAX_PLAYER_NAME],
	Account_Password[129],

	Account_AvailableSlots,
	Account_ActiveSlots,
	Account_Staff,
	
	Settings_Pm,
	Settings_OOC,

	Account_LoginAttempts,
	Account_LoginTimer,
	Account_KickTimer,
	bool:Account_IsLogged,
	bool:Account_IsPlaying
};
new Account[MAX_PLAYERS][Enum_Accounts];

enum Enum_Characters
{
	Character_SQL,
	Character_AccountSQL,
	Character_Name[MAX_PLAYER_NAME],
	Character_Configured,
	Float:Character_PosX,
	Float:Character_PosY,
	Float:Character_PosZ,
	Float:Character_PosA,
	Character_VirtualWorld,
	Character_Interior,
	Character_Gender,
	Character_Age,
	Character_Job,
	Talent_Mechanic,
	Talent_Fishing,
	Talent_Aim,
	Talent_Crafting,
	Talent_FirstAid,
	Talent_Cooking,
	Character_Backpack,
	Float:Character_Carry,
	Character_Tirst,
	Character_Hunger,
	Character_Level,
	Character_EXP,
	Character_PaydayTime,
	Character_TalentPoint,
	Character_Weapons[5],
	Character_Ammo[5],
	
	bool:Character_StaffDuty,
	Character_LastPm,
	Character_LastAirdrop,
	
	Character_FishingTimer,
	Character_CraftTimer,
	Character_LootTimer,
	Character_FillTimer,
	Character_BoxTimer,
	Character_TentTimer,
	
	Character_CraftingTable,
	Character_EditingTable,
	Character_EditingTent,
	
	Character_Area,
	Character_AreaType,
	
	Character_Picklock,
	Character_PicklockCode[5],
	Character_PicklockCodeCount,
	Character_PicklockCodeTime,
	Character_PicklockTimer,
	
	Character_HitCount,
	Character_RadioSlot,
	
	bool:Box_Show,
	PlayerText:InfoBox
};
new Character[MAX_PLAYERS][Enum_Characters];

enum Enum_Inventory
{
	bool:Inventory_Exists,
	Inventory_ID,
	Inventory_Item,
	Inventory_Amount
};
new Inventory[MAX_PLAYERS][MAX_INVENTORY_SLOT][Enum_Inventory];

enum(<<=1)
{
    CMD_PLAYER = 1,
    CMD_TESTER1,
    CMD_TESTER2,
    CMD_TESTER3,
    CMD_GADMIN1,
    CMD_GADMIN2,
   	CMD_GADMIN3,
    CMD_DEVELOPER,
    CMD_LEADADMIN,
    CMD_FOUNDER
};

enum enum_droppeditems
{
	DroppedItem_ID,
	Text3D:DroppedItem_Text,
	Float:DroppedItem_PosX,
	Float:DroppedItem_PosY,
	Float:DroppedItem_PosZ,
	DroppedItem_Interior,
	DroppedItem_VirtualWorld,
	DroppedItem_Item,
	DroppedItem_Amount,
	DroppedItem_Object,
	DroppedItem_Owned,
	DroppedItem_SpawnTime
};

enum Enum_Airdrops
{
	bool:Airdrop_Exists,
	Float:AirdropX,
	Float:AirdropY,
	Float:AirdropZ,
	Airdrop_Object,
	Airdrop_Items[5],
	Airdrop_Timer
};
new Airdrop[MAX_AIRDROP][Enum_Airdrops];

enum Enum_Items
{
	Item_ID,
	Item_ObjectID,
	Item_Name[15],
	Float:Item_Weight
};

enum Enum_Server
{
	RedZoneID,
	RedZoneTimer,
	RedZoneMissileTimer,
	RedZone
};
new Server[Enum_Server];

enum Weapon_Settings
{
    Float:Position[6],
    Bone,
    Hidden
}
new WeaponSettings[MAX_PLAYERS][17][Weapon_Settings], WeaponTick[MAX_PLAYERS], EditingWeapon[MAX_PLAYERS];

enum enum_campfire // -10
{
	areaID,
	bool:fireExists,
	Float:fireX,
	Float:fireY,
	Float:fireZ,
	fireTimer,
	CookingFish,
	Text3D:CookingText,
	fireObject,
	CookedFish,
	CookingTimer
};

enum enum_tables // -30
{
	areaID,
	tableID,
	bool:tableExists,
	Float:tableX,
	Float:tableY,
	Float:tableZ,
	tableInterior,
	tableVirtualWorld,
	Text3D:tableText,
	tableType,
	tableObject,
	tableObjectID,
	tableUsing
}

enum enum_safe // -20
{
	areaID,
	safeID,
	safeOwner,
	safeLock, // 0 - unlocked, 1 - locked but inactive, 2- locked
	bool:safeExists,
	Float:safeX,
	Float:safeY,
	Float:safeZ,
	safeInterior,
	safeWorld,
	safePassword[30],
	safeItems[10],
	safeAmounts[10],
	safeObject,
	bool:picklock
}

enum Enum_LootPlaces
{
	LP_ID,

	Float:LP_X,
	Float:LP_Y,
	Float:LP_Z,
	LP_Interior,
	LP_World,

	Float:LP_InX,
	Float:LP_InY,
	Float:LP_InZ,
	LP_InInterior,
	LP_InWorld,

	Text3D:LP_Text,
	LP_Pickup,

	LP_Type
}
new LootPlace[MAX_LPLACE][Enum_LootPlaces],
	Iterator:lootplace<MAX_LPLACE>;

enum E_NPCs {
	NPC_database_id,
	NPC_game_id,
	Float:NPC_x,
	Float:NPC_y,
	Float:NPC_z,
	NPC_name[32],
	NPC_skin,
	Float:NPC_health,
	Float:NPC_armour,
	NPC_damage,
	NPC_walk_speed,
	NPC_bite,
	NPC_herd_id,
	NPC_MovePath,
	NPC_chaseID,
	NPC_status,
	NPC_area,
	Timer:NPC_timer,
	npcTick
}

new NPCInfo[MAX_DYNAMIC_NPC][E_NPCs];

#define NPC_Idle (0)
#define NPC_Chase (1)
#define NPC_Attack (2)
#define NPC_Death (3)

new Float:RedZones[][] = { // MinX, MinY, MaxX, MaxY, Z
	{2220.8574, 1370.7687, 2064.7710, 1187.6703, 10.7408}
};

new Items[][Enum_Items] =
{
	{0, 1484, "Bo� �i�e", 0.050},
	{1, 19570, "Dolu su �i�esi", 0.300},
	{2, 18632, "Olta", 1.000},
	{3, 1600, "�i� bal�k", 2.500},
	{4, 19630, "Pi�mi� bal�k", 1.200},
	{5, 11747, "Bandaj", 0.200},
	{6, 11736, "�lkyard�m kiti", 1.00},
	{7, 19567, "Konserve", 0.500},
	{8, 354, "��aret fi�e�i", 1.500},
	{9, 333, "Golf sopas�", 5.000},
	{10, 334, "Jop", 2.500},
	{11, 335, "B��ak", 0.500},
	{12, 336, "Beyzbol sopas�", 1.500},
	{13, 337, "K�rek", 2.700},
	{14, 338, "Istaka", 2.000},
	{15, 339, "Katana", 2.000},
	{16, 341, "Testere", 5.000},
	{17, 342, "Bomba", 2.500},
	{18, 343, "Gaz bombas�", 2.000},
	{19, 346, "Glock", 5.000},
	{20, 347, "S-Glock", 5.200},
	{21, 348, "Desert Eagle", 6.000},
	{22, 349, "Shotgun", 8.000},
	{23, 352, "Uzi", 7.000},
	{24, 353, "MP5", 7.200},
	{25, 355, "AK-47", 8.000},
	{26, 356, "M4A1", 8.250},
	{27, 358, "Sniper t�fe�i", 10.000},
	{28, 2040, "5.56 mermisi", 0.0050},
	{29, 19832, "7.62 mermisi", 0.0075},
	{30, 3016, "9mm mermisi", 0.0025},
	{31, 2358, "Gauge mermisi", 0.0100},
	{32, 19290, "May�n", 0.500},
	{33, 2115, "�retim masas�", 10.000},
	{34, 1463, "Tahta par�as�", 0.250},
	{35, 3930, "Metal par�as�", 0.500},
	{36, 2819, "Kuma�", 0.050},
	{37, 19632, "Kamp ate�i", 1.000},
	{38, 2332, "Kasa", 10.000},
	{39, 11716, "Maymuncuk", 0.030},
	{40, 3111, "�ehir haritas�", 0.010},
	{41, 19998, "�akmak", 0.050},
	{42, 2856, "Yem", 0.010},
	{43, 19040, "Kol saati", 0.500},
	{44, 19942, "Telsiz", 1.500},
	{45, 1650, "Bo� bidon", 1.000},
	{46, 19621, "Dolu bidon", 2.500},
	{47, 19804, "Kilit", 0.400},
	{48, 19793, "Odun", 0.200},
	{49, 1579, "�ad�r", 5.000}
};

enum Enum_Craft
{
	Craft_ID,
	Craft_Item,
	Craft_ItemX,
	Craft_XAmount,
	Craft_ItemY,
	Craft_YAmount,
	Craft_ItemZ,
	Craft_ZAmount,
	bool:Craft_TableRequired,
	bool:Use_Item
};

new CraftData[][Enum_Craft] =
{
	{0, 33, 34, 5, 35, 2, -1, 0, false, true},
	{1, 37, 48, 3, 41, 1, -1, 0, false, true},
	{2, 38, 35, 5, -1, 0, -1, 0, true, true},
	{3, 39, 35, 3, -1, 0, -1, 0, true, false},
	{4, 5, 36, 5, -1, 0, -1, 0, false, false},
	{5, 2, 34, 1, 35, 1, 36, 1, false, false},
	{6, 47, 35, 5, -1, -1, -1, -1, true, false},
	{7, 49, 36, 20, 35, 5, -1, -1, true, false}
};

enum e_pump
{
    Float: pumpX,
    Float: pumpY,
    Float: pumpZ
}

new
    Float: PumpData[MAX_GAS_PUMPS][e_pump] = {
        {-85.2422, -1165.0312, 2.6328},
        {-90.1406, -1176.6250, 2.6328},
        {-92.1016, -1161.7891, 2.9609},
        {-97.0703, -1173.7500, 3.0312},
        {1941.6562, -1767.2891, 14.1406},
        {1941.6562, -1771.3438, 14.1406},
        {1941.6562, -1774.3125, 14.1406},
        {1941.6562, -1778.4531, 14.1406},
        {-1327.0312, 2685.5938, 49.4531},
        {-1327.7969, 2680.1250, 49.4531},
        {-1328.5859, 2674.7109, 49.4531},
        {-1329.2031, 2669.2812, 49.4531},
        {-1464.9375, 1860.5625, 31.8203},
        {-1465.4766, 1868.2734, 31.8203},
        {-1477.6562, 1859.7344, 31.8203},
        {-1477.8516, 1867.3125, 31.8203},
        {-1600.6719, -2707.8047, 47.9297},
        {-1603.9922, -2712.2031, 47.9297},
        {-1607.3047, -2716.6016, 47.9297},
        {-1610.6172, -2721.0000, 47.9297},
        {-1665.5234, 416.9141, 6.3828},
        {-1669.9062, 412.5312, 6.3828},
        {-1672.1328, 423.5000, 6.3828},
        {-1675.2188, 407.1953, 6.3828},
        {-1676.5156, 419.1172, 6.3828},
        {-1679.3594, 403.0547, 6.3828},
        {-1681.8281, 413.7812, 6.3828},
        {-1685.9688, 409.6406, 6.3828},
        {-2241.7188, -2562.2891, 31.0625},
        {-2246.7031, -2559.7109, 31.0625},
        {-2410.8047, 970.8516, 44.4844},
        {-2410.8047, 976.1875, 44.4844},
        {-2410.8047, 981.5234, 44.4844},
        {1378.9609, 461.0391, 19.3281},
        {1380.6328, 460.2734, 19.3281},
        {1383.3984, 459.0703, 19.3281},
        {1385.0781, 458.2969, 19.3281},
        {603.4844, 1707.2344, 6.1797},
        {606.8984, 1702.2188, 6.1797},
        {610.2500, 1697.2656, 6.1797},
        {613.7188, 1692.2656, 6.1797},
        {617.1250, 1687.4531, 6.1797},
        {620.5312, 1682.4609, 6.1797},
        {624.0469, 1677.6016, 6.1797},
        {655.6641, -558.9297, 15.3594},
        {655.6641, -560.5469, 15.3594},
        {655.6641, -569.6016, 15.3594},
        {655.6641, -571.2109, 15.3594},
        {1590.3516, 2193.7109, 11.3125},
        {1590.3516, 2204.5000, 11.3125},
        {1596.1328, 2193.7109, 11.3125},
        {1596.1328, 2204.5000, 11.3125},
        {1602.0000, 2193.7109, 11.3125},
        {1602.0000, 2204.5000, 11.3125},
        {2109.0469, 914.7188, 11.2578},
        {2109.0469, 925.5078, 11.2578},
        {2114.9062, 914.7188, 11.2578},
        {2114.9062, 925.5078, 11.2578},
        {2120.8203, 914.7188, 11.2578},
        {2120.8203, 925.5078, 11.2578},
        {2141.6719, 2742.5234, 11.2734},
        {2141.6719, 2753.3203, 11.2734},
        {2147.5312, 2742.5234, 11.2734},
        {2147.5312, 2753.3203, 11.2734},
        {2153.3125, 2742.5234, 11.2734},
        {2153.3125, 2753.3203, 11.2734},
        {2196.8984, 2470.2500, 11.3125},
        {2196.8984, 2474.6875, 11.3125},
        {2196.8984, 2480.3281, 11.3125},
        {2207.6953, 2470.2500, 11.3125},
        {2207.6953, 2474.6875, 11.3125},
        {2207.6953, 2480.3281, 11.3125},
        {2634.6406, 1100.9453, 11.2500},
        {2634.6406, 1111.7500, 11.2500},
        {2639.8750, 1100.9609, 11.2500},
        {2639.8750, 1111.7500, 11.2500},
        {2645.2500, 1100.9609, 11.2500},
        {2645.2500, 1111.7500, 11.2500}
};

enum e_trees
{
	Float:treeX,
	Float:treeY,
	Float:treeZ,
	treeStatus,
	treeLogs,
	treeObject,
	Text3D:treeLabel,
	treeMinutes
}

new TreeData[][e_trees] = {
	{2220.8574, 1370.7687, 10.7408}
};

enum Enum_Tents
{
	Tent_ID,
	
	Float:Tent_X,
	Float:Tent_Y,
	Float:Tent_Z,
	Float:Tent_rX,
	Float:Tent_rY,
	Float:Tent_rZ,
	Tent_Interior,
	Tent_World,
	
	Float:Tent_InX,
	Float:Tent_InY,
	Float:Tent_InZ,
	Tent_InInterior,
	Tent_InWorld,
	
	Tent_Lock, // 0 - unlock, 1 - locked.
	Tent_Owner,
	
	Tent_Object,
	Text3D:Tent_Text
};
new Tent[MAX_TENT][Enum_Tents],
    Iterator:tent<MAX_TENT>;

main() {

}

public OnGameModeInit()
{
	CA_Init();
	MapAndreas_Init(MAP_ANDREAS_MODE_FULL);
	PathFinder_Init(MapAndreas_GetAddress());

	SetMySQLConnection();
	SetServerDefinitions();
	SetServerSettings();
	SetRedZone();
	CreateGlobalTextdraws();

	mysql_tquery(SQL_Handle, "SELECT * FROM `npcs`", "OnLoadNPCData");
	
	new label[90];
	for(new i; i < sizeof(TreeData); i++)
	{
		TreeData[i][treeLogs] = TreeData[i][treeMinutes] = TreeData[i][treeStatus] = 0;
		TreeData[i][treeObject] = CreateDynamicObject(657, TreeData[i][treeX], TreeData[i][treeY], TreeData[i][treeZ] - 1, 0.0, 0.0, 0.0);
		format(label, sizeof(label), "A�a� (#%d)\n\n{FFFFFF}Kesmek i�in {F1C40F}/agac kes{FFFFFF} komutunu kullanabilirsin.", i);
		TreeData[i][treeLabel] = CreateDynamic3DTextLabel(label, 0x2ECC71FF, TreeData[i][treeX], TreeData[i][treeY], TreeData[i][treeZ] + 1.5, 5.0);
	}

	// ** Timers ** //
	SetTimer("MinuteUpdate", 60000, true);
	return 1;
}
public OnGameModeExit()
{
	foreach(new npcid : FCNPC)
	{
		if(FCNPC_IsSpawned(npcid))
		{
			NPC_Save(npcid);
		}
	}
	mysql_close(SQL_Handle);
	HideGlobalTextdraws();
	return 1;
}

public OnPlayerRequestClass(playerid, classid)
{
	TogglePlayerSpectating(playerid, true);
	SetPlayerWeather(playerid, 8);
	return 1;
}

public OnPlayerConnect(playerid)
{
	Character[playerid][Character_Picklock] = -1;
	Character[playerid][Character_CraftingTable] = -1;
	SetPVarInt(playerid, "TreeID", -1);
	ResetAccountStats(playerid);
	ResetCharacterStats(playerid);
	CreatePlayerTextdraws(playerid);

	GetPlayerName(playerid, Account[playerid][Account_Name], MAX_PLAYER_NAME);

	new query[90];
	mysql_format(SQL_Handle, query, sizeof query, "SELECT * FROM `accounts` WHERE `account_name` = '%e' LIMIT 1", Account[playerid][Account_Name]);
	mysql_tquery(SQL_Handle, query, "OnAccountDataLoaded", "dd", playerid, SQL_RaceCheck[playerid]);
	return 1;
}

public OnPlayerDisconnect(playerid, reason)
{
	if(Account[playerid][Account_IsPlaying])
	{
		UpdateCharacter(playerid);
		ResetCharacterStats(playerid);
	}
	
	if(Account[playerid][Account_IsLogged]) UpdateAccount(playerid);
	ResetAccountStats(playerid);
	return 1;
}

public OnPlayerSpawn(playerid)
{
	if(!Account[playerid][Account_IsPlaying])
	{
	    SendErrorMessage(playerid, "Bir sorun olu�tu, tekrar giri� yap�n.");
		return KickEx(playerid);
	}
	SetPlayerInterior(playerid, Character[playerid][Character_Interior]);
	SetPlayerVirtualWorld(playerid, Character[playerid][Character_VirtualWorld]);
	for(new i; i < 11; i++)
	{
		if(i < 5) GivePlayerWeapon(playerid, Character[playerid][Character_Weapons][i], Character[playerid][Character_Ammo][i]);
		SetPlayerSkillLevel(playerid, i, Character[playerid][Talent_Aim] * 10);
	}
	return 1;
}

public OnPlayerDeath(playerid, killerid, reason)
{
    if(Account[playerid][Account_IsPlaying])
    {
		GetPlayerPos(playerid, Character[playerid][Character_PosX], Character[playerid][Character_PosY], Character[playerid][Character_PosZ]);
	    GetPlayerFacingAngle(playerid, Character[playerid][Character_PosA]);
	}
	else
	{
	    SendErrorMessage(playerid, "Bir sorun olu�tu, tekrar giri� yap�n.");
		KickEx(playerid);
	}
	return 1;
}

public OnVehicleSpawn(vehicleid)
{
	return 1;
}

public OnVehicleDeath(vehicleid, killerid)
{
	return 1;
}

public OnPlayerText(playerid, text[])
{
	if(Character[playerid][Character_Picklock] != -1)
	{
		if(!strcmp(text, Character[playerid][Character_PicklockCode], true))
		{
			if(Character[playerid][Character_PicklockCodeCount] > 0)
			{
				strcpy(Character[playerid][Character_PicklockCode], GetRandomCode(), 5);
				Character[playerid][Character_PicklockCodeCount]--;
				Character[playerid][Character_PicklockCodeTime] = 5;
			}
			else
			{
				Character[playerid][Character_PicklockCode][0] = EOS;
				Character[playerid][Character_PicklockCodeCount] = 0;
			}
		}
		return 0;
	}
    SendNearbyMessage(playerid, 20.0, COLOR_WHITE, "%s: %s", ReturnName(playerid), text);
	return 0;
}

public OnPlayerEnterVehicle(playerid, vehicleid, ispassenger)
{
	return 1;
}

public OnPlayerExitVehicle(playerid, vehicleid)
{
	return 1;
}

public OnPlayerStateChange(playerid, newstate, oldstate)
{
	return 1;
}

public OnPlayerEnterCheckpoint(playerid)
{
	return 1;
}

public OnPlayerLeaveCheckpoint(playerid)
{
	return 1;
}

public OnRconCommand(cmd[])
{
	return 1;
}

public OnPlayerRequestSpawn(playerid)
{
	return 1;
}

public OnObjectMoved(objectid)
{
	return 1;
}

public OnPlayerObjectMoved(playerid, objectid)
{
	return 1;
}

public OnPlayerPickUpPickup(playerid, pickupid)
{
	return 1;
}

public OnVehicleMod(playerid, vehicleid, componentid)
{
	return 1;
}

public OnVehiclePaintjob(playerid, vehicleid, paintjobid)
{
	return 1;
}

public OnVehicleRespray(playerid, vehicleid, color1, color2)
{
	return 1;
}

public OnPlayerSelectedMenuRow(playerid, row)
{
	return 1;
}

public OnPlayerExitedMenu(playerid)
{
	return 1;
}

public OnPlayerInteriorChange(playerid, newinteriorid, oldinteriorid)
{
	return 1;
}

public OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	if(newkeys & KEY_NO)
	{
		if(!IsPlayerInAnyVehicle(playerid))
			return DroppedItems_List(playerid);
	}
	else if(newkeys & KEY_JUMP)
	{
		if(Character[playerid][Character_Picklock] != -1)
		{
			if(IsValidDynamicArea(Character[playerid][Character_Picklock]))
			{
				new data[enum_safe];
				Streamer_GetArrayData(STREAMER_TYPE_AREA, Character[playerid][Character_Picklock], E_STREAMER_EXTRA_ID, data);
				data[picklock] = false;
				Streamer_SetArrayData(STREAMER_TYPE_AREA, Character[playerid][Character_Picklock], E_STREAMER_EXTRA_ID, data);
			}
			Character[playerid][Character_Picklock] = -1;
			Character[playerid][Character_PicklockCode][0] = EOS;
			Character[playerid][Character_PicklockCodeCount] = 0;
			Character[playerid][Character_PicklockCodeTime] = 0;
			KillTimer(Character[playerid][Character_PicklockTimer]);
			Character[playerid][Character_PicklockTimer] = -1;
			SendServerMessage(playerid, "Kasa a�ma i�lemi iptal edildi.");
		}
		return 1;
	}
	return 1;
}

public OnRconLoginAttempt(ip[], password[], success)
{
	return 1;
}

public OnPlayerUpdate(playerid)
{
    if (NetStats_GetConnectedTime(playerid) - WeaponTick[playerid] >= 250)
    {
        new weaponid, ammo, objectslot, count, index;

        for(new i = 2; i <= 7; i++) //Loop only through the slots that may contain the wearable weapons.
        {
            GetPlayerWeaponData(playerid, i, weaponid, ammo);
            index = weaponid - 22;

            if(weaponid && ammo && !WeaponSettings[playerid][index][Hidden] && IsWeaponWearable(weaponid) && EditingWeapon[playerid] != weaponid)
            {
                objectslot = GetWeaponObjectSlot(weaponid);

                if(GetPlayerWeapon(playerid) != weaponid)
                    SetPlayerAttachedObject(playerid, objectslot, GetWeaponModel(weaponid), WeaponSettings[playerid][index][Bone], WeaponSettings[playerid][index][Position][0], WeaponSettings[playerid][index][Position][1], WeaponSettings[playerid][index][Position][2], WeaponSettings[playerid][index][Position][3], WeaponSettings[playerid][index][Position][4], WeaponSettings[playerid][index][Position][5], 1.0, 1.0, 1.0);

                else if(IsPlayerAttachedObjectSlotUsed(playerid, objectslot)) RemovePlayerAttachedObject(playerid, objectslot);
            }
        }
        
        for(new i; i <= 5; i++) if (IsPlayerAttachedObjectSlotUsed(playerid, i))
        {
            count = 0;

            for(new j = 22; j <= 38; j++) if (PlayerHasWeapon(playerid, j) && GetWeaponObjectSlot(j) == i)
                count++;

            if(!count) RemovePlayerAttachedObject(playerid, i);
        }
        
        WeaponTick[playerid] = NetStats_GetConnectedTime(playerid);
    }
    return 1;
}

public OnPlayerStreamIn(playerid, forplayerid)
{
	return 1;
}

public OnPlayerStreamOut(playerid, forplayerid)
{
	return 1;
}

public OnVehicleStreamIn(vehicleid, forplayerid)
{
	return 1;
}

public OnVehicleStreamOut(vehicleid, forplayerid)
{
	return 1;
}

public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
	return 1;
}

public OnPlayerClickPlayer(playerid, clickedplayerid, source)
{
	return 1;
}
public OnPlayerClickMap(playerid, Float:fX, Float:fY, Float:fZ)
{
    SetPlayerPosFindZ(playerid, fX, fY, fZ); 
    return 1;
}
public OnPlayerCommandReceived(playerid, cmd[], params[], flags)
{
    if(!Account[playerid][Account_IsPlaying])
    {
    	SendErrorMessage(playerid, "Giri� yapmadan komut kullanamazs�n�z.");
    	return 0;
    }
	switch(flags)
	{
	    case CMD_TESTER1: if(Account[playerid][Account_Staff] < TESTER1)
	    {
	        return 0;
	    }
	    case CMD_TESTER2: if(Account[playerid][Account_Staff] < TESTER2)
	    {
	        return 0;
	    }
	    case CMD_TESTER3: if(Account[playerid][Account_Staff] < TESTER3)
	    {
	        return 0;
	    }
	    case CMD_GADMIN1: if(Account[playerid][Account_Staff] < GADMIN1)
	    {
	        return 0;
	    }
	    case CMD_GADMIN2: if(Account[playerid][Account_Staff] < GADMIN2)
	    {
	        return 0;
	    }
	    case CMD_GADMIN3: if(Account[playerid][Account_Staff] < GADMIN3)
	    {
	        return 0;
	    }
	    case CMD_DEVELOPER: if(Account[playerid][Account_Staff] < DEVELOPER)
	    {
	        return 0;
	    }
	    case CMD_LEADADMIN: if(Account[playerid][Account_Staff] < LEADADMIN)
	    {
	        return 0;
	    }
	    case CMD_FOUNDER: if(Account[playerid][Account_Staff] < FOUNDER)
	    {
	        return 0;
	    }
	    default: return 1;
	}
    return 1;
}

public OnPlayerCommandPerformed(playerid, cmd[], params[], result, flags)
{
    if(result == -1)
    {
        SendErrorMessage(playerid, "Girilen \"%s\" komutu ge�ersiz.", cmd);
        return 0;
    }
    return 1;
}
public OnPlayerGiveDamage(playerid, damagedid, Float:amount, weaponid, bodypart)
{
	if(damagedid != INVALID_PLAYER_ID && (weaponid >= 22 && weaponid <= 34))
	{
		Character[playerid][Character_HitCount]++;
		if(Character[playerid][Character_HitCount] >= 30)
		{
			Character[playerid][Character_HitCount] = 0;
			GiveRandomTalentPoint(playerid, 2, 1);
		}
	}
	return 1;
}
public OnPlayerWeaponShot(playerid, weaponid, hittype, hitid, Float:fX, Float:fY, Float:fZ)
{
    if(GetPlayerWeaponState(playerid) == WEAPONSTATE_LAST_BULLET && GetPlayerAmmo(playerid) == 1)
    {
		switch(weaponid)
		{
		    case 22:
			{
			    RemovePlayerWeapon(playerid, 22);
			    
			    if(!IsCharacterCanGetThisItem(playerid, 19, 1))
				{
					DroppedItem_Create(playerid, 19, 1, 1);
					return SendErrorMessage(playerid, "Glock silah�n�z, envanterinizde yer olmad��� i�in yere at�ld�.");
				}

				Inventory_AddItem(playerid, 19, 1);
			}
		    case 23:
			{
			    RemovePlayerWeapon(playerid, 23);

			    if(!IsCharacterCanGetThisItem(playerid, 20, 1)) {
				
					DroppedItem_Create(playerid, 20, 1, 1);
					return SendErrorMessage(playerid, "S-Glock silah�n�z, envanterinizde yer olmad��� i�in yere at�ld�.");
				}

				Inventory_AddItem(playerid, 20, 1);
			}
		    case 24:
			{
			    RemovePlayerWeapon(playerid, 24);

			    if(!IsCharacterCanGetThisItem(playerid, 21, 1)) {
				
					DroppedItem_Create(playerid, 21, 1, 1);
					return SendErrorMessage(playerid, "Desert Eagle silah�n�z, envanterinizde yer olmad��� i�in yere at�ld�.");
				}

				Inventory_AddItem(playerid, 21, 1);
			}
		    case 25:
			{
			    RemovePlayerWeapon(playerid, 25);

			    if(!IsCharacterCanGetThisItem(playerid, 22, 1)) {
				
					DroppedItem_Create(playerid, 22, 1, 1);
					return SendErrorMessage(playerid, "Shotgun silah�n�z, envanterinizde yer olmad��� i�in yere at�ld�.");
				}

				Inventory_AddItem(playerid, 22, 1);
			}
		    case 28:
			{
			    RemovePlayerWeapon(playerid, 28);

			    if(!IsCharacterCanGetThisItem(playerid, 23, 1)) {
				
					DroppedItem_Create(playerid, 23, 1, 1);
					return SendErrorMessage(playerid, "Uzi silah�n�z, envanterinizde yer olmad��� i�in yere at�ld�.");
				}

				Inventory_AddItem(playerid, 23, 1);
			}
		    case 29:
			{
			    RemovePlayerWeapon(playerid, 29);

			    if(!IsCharacterCanGetThisItem(playerid, 24, 1)) {
				
					DroppedItem_Create(playerid, 24, 1, 1);
					return SendErrorMessage(playerid, "MP5 silah�n�z, envanterinizde yer olmad��� i�in yere at�ld�.");
				}

				Inventory_AddItem(playerid, 24, 1);
			}
		    case 30:
			{
			    RemovePlayerWeapon(playerid, 30);

			    if(!IsCharacterCanGetThisItem(playerid, 25, 1)) {
				
					DroppedItem_Create(playerid, 25, 1, 1);
					return SendErrorMessage(playerid, "AK-47 silah�n�z, envanterinizde yer olmad��� i�in yere at�ld�.");
				}

				Inventory_AddItem(playerid, 25, 1);
			}
		    case 31:
			{
			    RemovePlayerWeapon(playerid, 31);

			    if(!IsCharacterCanGetThisItem(playerid, 26, 1)) {
				
					DroppedItem_Create(playerid, 26, 1, 1);
					return SendErrorMessage(playerid, "M4A1 silah�n�z, envanterinizde yer olmad��� i�in yere at�ld�.");
				}

				Inventory_AddItem(playerid, 26, 1);
			}
		    case 34:
			{
			    RemovePlayerWeapon(playerid, 34);

			    if(!IsCharacterCanGetThisItem(playerid, 27, 1)) {
				
					DroppedItem_Create(playerid, 27, 1, 1);
					return SendErrorMessage(playerid, "Sniper t�fe�iniz, envanterinizde yer olmad��� i�in yere at�ld�.");
				}

				Inventory_AddItem(playerid, 27, 1);
			}
			default: return 1;
		}
    }
	return 1;
}

public OnPlayerEditAttachedObject(playerid, response, index, modelid, boneid, Float:fOffsetX, Float:fOffsetY, Float:fOffsetZ, Float:fRotX, Float:fRotY, Float:fRotZ, Float:fScaleX, Float:fScaleY, Float:fScaleZ)
{
    new weaponid = EditingWeapon[playerid];

    if(weaponid)
    {
        if(response)
        {
            new enum_index = weaponid - 22, weaponname[18], string[340];

            GetWeaponName(weaponid, weaponname, sizeof(weaponname));

            WeaponSettings[playerid][enum_index][Position][0] = fOffsetX;
            WeaponSettings[playerid][enum_index][Position][1] = fOffsetY;
            WeaponSettings[playerid][enum_index][Position][2] = fOffsetZ;
            WeaponSettings[playerid][enum_index][Position][3] = fRotX;
            WeaponSettings[playerid][enum_index][Position][4] = fRotY;
            WeaponSettings[playerid][enum_index][Position][5] = fRotZ;

            RemovePlayerAttachedObject(playerid, GetWeaponObjectSlot(weaponid));
            SetPlayerAttachedObject(playerid, GetWeaponObjectSlot(weaponid), GetWeaponModel(weaponid), WeaponSettings[playerid][enum_index][Bone], fOffsetX, fOffsetY, fOffsetZ, fRotX, fRotY, fRotZ, 1.0, 1.0, 1.0);

            SendServerMessage(playerid, "%s silah�n�n pozisyonunu de�i�tirdiniz.", weaponname);

            mysql_format(SQL_Handle, string, sizeof(string), "INSERT INTO weaponsettings (Owner, WeaponID, PosX, PosY, PosZ, RotX, RotY, RotZ) VALUES ('%d', %d, %.3f, %.3f, %.3f, %.3f, %.3f, %.3f) ON DUPLICATE KEY UPDATE PosX = VALUES(PosX), PosY = VALUES(PosY), PosZ = VALUES(PosZ), RotX = VALUES(RotX), RotY = VALUES(RotY), RotZ = VALUES(RotZ)", Character[playerid][Character_SQL], weaponid, fOffsetX, fOffsetY, fOffsetZ, fRotX, fRotY, fRotZ);
            mysql_tquery(SQL_Handle, string);
        }
        
        EditingWeapon[playerid] = 0;
    }
    return 1;
}
public OnPlayerLeaveDynamicArea(playerid, areaid)
{
	Character[playerid][Character_Area] = -1;
	Character[playerid][Character_AreaType] = 0;
	return 1;
}
public OnPlayerEnterDynamicArea(playerid, areaid)
{
	if(GetDynamicAreaType(areaid) == STREAMER_AREA_TYPE_SPHERE)
	{
		if(Streamer_IsInArrayData(STREAMER_TYPE_AREA, areaid, E_STREAMER_EXTRA_ID, -5))
		{
			new data[3];
			Streamer_GetArrayData(STREAMER_TYPE_AREA, areaid, E_STREAMER_EXTRA_ID, data);
			if(data[1] != Character[playerid][Character_SQL])
			{
				new Float:x, Float:y, Float:z;
				GetPlayerPos(playerid, x, y, z);
				CreateExplosion(x, y, z, 6, 50);
				DestroyDynamicObject(data[2]);
				DestroyDynamicArea(areaid);
				SendServerMessage(playerid, "May�na bast�n�z.");
			}
		}
		else if(Streamer_IsInArrayData(STREAMER_TYPE_AREA, areaid, E_STREAMER_EXTRA_ID, -10))
		{
			MessageBox(playerid, "Kamp atesinde isinabilir ve balik pisirebilirsiniz. (/balik)", 1);
			Character[playerid][Character_Area] = areaid;
			Character[playerid][Character_AreaType] = 1;
		}
		else if(Streamer_IsInArrayData(STREAMER_TYPE_AREA, areaid, E_STREAMER_EXTRA_ID, -20))
		{
			MessageBox(playerid, "/kasa", 1);
			Character[playerid][Character_Area] = areaid;
			Character[playerid][Character_AreaType] = 2;
		}
		else if(Streamer_IsInArrayData(STREAMER_TYPE_AREA, areaid, E_STREAMER_EXTRA_ID, -30))
		{
			MessageBox(playerid, "/craft", 1);
			Character[playerid][Character_Area] = areaid;
			Character[playerid][Character_AreaType] = 3;
		}
	}
	return 1;
}

public OnPlayerEditDynamicObject(playerid, objectid, response, Float:x, Float:y, Float:z, Float:rx, Float:ry, Float:rz)
{
	if(Character[playerid][Character_EditingTable] != -1)
	{
    	if(response == EDIT_RESPONSE_CANCEL)
    	{
    	    new data[enum_tables];

    	    Streamer_GetArrayData(STREAMER_TYPE_AREA, Character[playerid][Character_EditingTable], E_STREAMER_EXTRA_ID, data);
    	    SetDynamicObjectPos(data[tableObjectID], data[tableX], data[tableY], data[tableZ]);
    	    
			Character[playerid][Character_EditingTable] = -1;
    		SendServerMessage(playerid, "Masa d�zenlemeyi iptal ettiniz. /masaduzenle komutuyla tekrar bu i�lemi yapabilirsiniz.");
    		TogglePlayerControllable(playerid, true);
		}
    	else if(response == EDIT_RESPONSE_FINAL)
    	{
    		SetDynamicObjectPos(objectid, x, y, z);
    		SetDynamicObjectRot(objectid, 0.0, 0.0, 0.0);

    		new data[enum_tables];

    		Streamer_GetArrayData(STREAMER_TYPE_AREA, Character[playerid][Character_EditingTable], E_STREAMER_EXTRA_ID, data);

    		data[tableX] = x, data[tableY] = y, data[tableZ] = z;

    		Streamer_SetArrayData(STREAMER_TYPE_AREA, Character[playerid][Character_EditingTable], E_STREAMER_EXTRA_ID, data);
			Streamer_SetFloatData(STREAMER_TYPE_AREA, Character[playerid][Character_EditingTable], E_STREAMER_X, x);
			Streamer_SetFloatData(STREAMER_TYPE_AREA, Character[playerid][Character_EditingTable], E_STREAMER_Y, y);
			Streamer_SetFloatData(STREAMER_TYPE_AREA, Character[playerid][Character_EditingTable], E_STREAMER_Z, z);
    		
    		Tables_Save(Character[playerid][Character_EditingTable]);
    		Character[playerid][Character_EditingTable] = -1;
    		SendServerMessage(playerid, "Masa d�zenlendi, tekrar d�zenlemek isterseniz /masaduzenle komutunu kullanabilirsiniz.");
    		TogglePlayerControllable(playerid, true);
    	}
	}
	else if(Character[playerid][Character_EditingTent] != -1)
	{
		if(response == EDIT_RESPONSE_CANCEL)
		{
			SendServerMessage(playerid, "�ad�r d�zenlemeyi iptal ettiniz. /cadir duzenle komutuyla tekrar bu i�lemi yapabilirsiniz.");
			TogglePlayerControllable(playerid, true);

    		SetDynamicObjectPos(objectid, Tent[Character[playerid][Character_EditingTent]][Tent_X], Tent[Character[playerid][Character_EditingTent]][Tent_Y], Tent[Character[playerid][Character_EditingTent]][Tent_Z]);
    		SetDynamicObjectRot(objectid, Tent[Character[playerid][Character_EditingTent]][Tent_rX], Tent[Character[playerid][Character_EditingTent]][Tent_rY], Tent[Character[playerid][Character_EditingTent]][Tent_rZ]);
    		
    		Character[playerid][Character_EditingTable] = -1;
		}
		else if(response == EDIT_RESPONSE_FINAL)
		{
    		SetDynamicObjectPos(objectid, x, y, z);
    		SetDynamicObjectRot(objectid, rx, ry, rz);

    		Tent[Character[playerid][Character_EditingTent]][Tent_X] = x;
    		Tent[Character[playerid][Character_EditingTent]][Tent_rX] = rx;
    		Tent[Character[playerid][Character_EditingTent]][Tent_Y] = y;
    		Tent[Character[playerid][Character_EditingTent]][Tent_rY] = ry;
    		Tent[Character[playerid][Character_EditingTent]][Tent_Z] = z;
    		Tent[Character[playerid][Character_EditingTent]][Tent_rZ] = rz;

    		Tent_Save(Character[playerid][Character_EditingTent], true);
    		Character[playerid][Character_EditingTent] = -1;
    		SendServerMessage(playerid, "�ad�r d�zenlendi. Tekrar d�zenlemek isterseniz /cadir duzenle komutunu kullanabilirsiniz.");
    		TogglePlayerControllable(playerid, true);
		}
	}
	return 1;
}

/*Stock Functions*/
stock ChangeHerdNextPoint(herd_id, point_id, Float:x, Float:y, Float:z)
{
	for(new a = 0; a < MAX_DYNAMIC_NPC; a++)
	{
		if(NPCInfo[a][NPC_database_id] > 0)
		{
			if(NPCInfo[a][NPC_herd_id] == herd_id)
			{
				NPCInfo[a][NPC_MovePath] = FCNPC_CreateMovePath();
				FCNPC_GetPosition(NPCInfo[a][NPC_game_id], NPCInfo[a][NPC_x], NPCInfo[a][NPC_y], NPCInfo[a][NPC_z]);
				if(FCNPC_IsValidMovePath(NPCInfo[a][NPC_MovePath]))
				{
					FCNPC_AddPointToMovePath(NPCInfo[a][NPC_MovePath], x, y, z);

					FCNPC_GoByMovePath(NPCInfo[a][NPC_game_id], NPCInfo[a][NPC_MovePath], FCNPC_GetNumberMovePathPoint(NPCInfo[a][NPC_MovePath]), FCNPC_MOVE_TYPE_RUN, FCNPC_MOVE_TYPE_RUN, FCNPC_MOVE_MODE_COLANDREAS, FCNPC_MOVE_PATHFINDING_RAYCAST);
				}
			}
		}
	}

	new query[300];

	mysql_format(SQL_Handle, query, sizeof(query), "UPDATE `npcs_herds` SET `herd_next_point_id` = '%d', `herd_next_x` = '%f', `herd_next_y` = '%f', `herd_next_z` = '%f' WHERE `herd_id` = '%d'", 
		point_id, 
		x, 
		y, 
		z,
		herd_id
	);
	mysql_query(SQL_Handle, query);
	return 1;
}

stock CreateHerd(creator[], name[])
{
	new Cache: insert, query[300];
	mysql_format(SQL_Handle, query, sizeof(query), "INSERT INTO `npcs_herds` (`herd_name`, `herd_created_date`, `herd_created_by`, `herd_next_point_id`, `herd_next_x`, `herd_next_y`, `herd_next_z`, `herd_mode`) VALUES('%s', '%d', '%s', '0', '0', '0', '0', '0')",
		name,
		gettime(),
		creator
	);

	insert = mysql_query(SQL_Handle, query);
	
	cache_delete(insert);

	return 1;
}


stock FindLocation(Float:fX, Float:fY, Float:fZ)
{
    enum bolgeBilgi
	{
     	bolgeAdi[32 char],
     	Float:bolgePos[6]
	};
	new const bolgelerBilgi[][bolgeBilgi] =
	{
		{!"The Big Ear", 	              {-410.00, 1403.30, -3.00, -137.90, 1681.20, 200.00}},
		{!"Aldea Malvada",                {-1372.10, 2498.50, 0.00, -1277.50, 2615.30, 200.00}},
		{!"Angel Pine",                   {-2324.90, -2584.20, -6.10, -1964.20, -2212.10, 200.00}},
		{!"Arco del Oeste",               {-901.10, 2221.80, 0.00, -592.00, 2571.90, 200.00}},
		{!"Avispa Country Club",          {-2646.40, -355.40, 0.00, -2270.00, -222.50, 200.00}},
		{!"Avispa Country Club",          {-2831.80, -430.20, -6.10, -2646.40, -222.50, 200.00}},
		{!"Avispa Country Club",          {-2361.50, -417.10, 0.00, -2270.00, -355.40, 200.00}},
		{!"Avispa Country Club",          {-2667.80, -302.10, -28.80, -2646.40, -262.30, 71.10}},
		{!"Avispa Country Club",          {-2470.00, -355.40, 0.00, -2270.00, -318.40, 46.10}},
		{!"Avispa Country Club",          {-2550.00, -355.40, 0.00, -2470.00, -318.40, 39.70}},
		{!"Back o Beyond",                {-1166.90, -2641.10, 0.00, -321.70, -1856.00, 200.00}},
		{!"Battery Point",                {-2741.00, 1268.40, -4.50, -2533.00, 1490.40, 200.00}},
		{!"Bayside",                      {-2741.00, 2175.10, 0.00, -2353.10, 2722.70, 200.00}},
		{!"Bayside Marina",               {-2353.10, 2275.70, 0.00, -2153.10, 2475.70, 200.00}},
		{!"Beacon Hill",                  {-399.60, -1075.50, -1.40, -319.00, -977.50, 198.50}},
		{!"Blackfield",                   {964.30, 1203.20, -89.00, 1197.30, 1403.20, 110.90}},
		{!"Blackfield",                   {964.30, 1403.20, -89.00, 1197.30, 1726.20, 110.90}},
		{!"Blackfield Chapel",            {1375.60, 596.30, -89.00, 1558.00, 823.20, 110.90}},
		{!"Blackfield Chapel",            {1325.60, 596.30, -89.00, 1375.60, 795.00, 110.90}},
		{!"Blackfield Intersection",      {1197.30, 1044.60, -89.00, 1277.00, 1163.30, 110.90}},
		{!"Blackfield Intersection",      {1166.50, 795.00, -89.00, 1375.60, 1044.60, 110.90}},
		{!"Blackfield Intersection",      {1277.00, 1044.60, -89.00, 1315.30, 1087.60, 110.90}},
		{!"Blackfield Intersection",      {1375.60, 823.20, -89.00, 1457.30, 919.40, 110.90}},
		{!"Blueberry",                    {104.50, -220.10, 2.30, 349.60, 152.20, 200.00}},
		{!"Blueberry",                    {19.60, -404.10, 3.80, 349.60, -220.10, 200.00}},
		{!"Blueberry Acres",              {-319.60, -220.10, 0.00, 104.50, 293.30, 200.00}},
		{!"Caligula's Palace",            {2087.30, 1543.20, -89.00, 2437.30, 1703.20, 110.90}},
		{!"Caligula's Palace",            {2137.40, 1703.20, -89.00, 2437.30, 1783.20, 110.90}},
		{!"Calton Heights",               {-2274.10, 744.10, -6.10, -1982.30, 1358.90, 200.00}},
		{!"Chinatown",                    {-2274.10, 578.30, -7.60, -2078.60, 744.10, 200.00}},
		{!"City Hall",                    {-2867.80, 277.40, -9.10, -2593.40, 458.40, 200.00}},
		{!"Come-A-Lot",                   {2087.30, 943.20, -89.00, 2623.10, 1203.20, 110.90}},
		{!"Commerce",                     {1323.90, -1842.20, -89.00, 1701.90, -1722.20, 110.90}},
		{!"Commerce",                     {1323.90, -1722.20, -89.00, 1440.90, -1577.50, 110.90}},
		{!"Commerce",                     {1370.80, -1577.50, -89.00, 1463.90, -1384.90, 110.90}},
		{!"Commerce",                     {1463.90, -1577.50, -89.00, 1667.90, -1430.80, 110.90}},
		{!"Commerce",                     {1583.50, -1722.20, -89.00, 1758.90, -1577.50, 110.90}},
		{!"Commerce",                     {1667.90, -1577.50, -89.00, 1812.60, -1430.80, 110.90}},
		{!"Conference Center",            {1046.10, -1804.20, -89.00, 1323.90, -1722.20, 110.90}},
		{!"Conference Center",            {1073.20, -1842.20, -89.00, 1323.90, -1804.20, 110.90}},
		{!"Cranberry Station",            {-2007.80, 56.30, 0.00, -1922.00, 224.70, 100.00}},
		{!"Creek",                        {2749.90, 1937.20, -89.00, 2921.60, 2669.70, 110.90}},
		{!"Dillimore",                    {580.70, -674.80, -9.50, 861.00, -404.70, 200.00}},
		{!"Doherty",                      {-2270.00, -324.10, -0.00, -1794.90, -222.50, 200.00}},
		{!"Doherty",                      {-2173.00, -222.50, -0.00, -1794.90, 265.20, 200.00}},
		{!"Downtown",                     {-1982.30, 744.10, -6.10, -1871.70, 1274.20, 200.00}},
		{!"Downtown",                     {-1871.70, 1176.40, -4.50, -1620.30, 1274.20, 200.00}},
		{!"Downtown",                     {-1700.00, 744.20, -6.10, -1580.00, 1176.50, 200.00}},
		{!"Downtown",                     {-1580.00, 744.20, -6.10, -1499.80, 1025.90, 200.00}},
		{!"Downtown",                     {-2078.60, 578.30, -7.60, -1499.80, 744.20, 200.00}},
		{!"Downtown",                     {-1993.20, 265.20, -9.10, -1794.90, 578.30, 200.00}},
		{!"Downtown Los Santos",          {1463.90, -1430.80, -89.00, 1724.70, -1290.80, 110.90}},
		{!"Downtown Los Santos",          {1724.70, -1430.80, -89.00, 1812.60, -1250.90, 110.90}},
		{!"Downtown Los Santos",          {1463.90, -1290.80, -89.00, 1724.70, -1150.80, 110.90}},
		{!"Downtown Los Santos",          {1370.80, -1384.90, -89.00, 1463.90, -1170.80, 110.90}},
		{!"Downtown Los Santos",          {1724.70, -1250.90, -89.00, 1812.60, -1150.80, 110.90}},
		{!"Downtown Los Santos",          {1370.80, -1170.80, -89.00, 1463.90, -1130.80, 110.90}},
		{!"Downtown Los Santos",          {1378.30, -1130.80, -89.00, 1463.90, -1026.30, 110.90}},
		{!"Downtown Los Santos",          {1391.00, -1026.30, -89.00, 1463.90, -926.90, 110.90}},
		{!"Downtown Los Santos",          {1507.50, -1385.20, 110.90, 1582.50, -1325.30, 335.90}},
		{!"East Beach",                   {2632.80, -1852.80, -89.00, 2959.30, -1668.10, 110.90}},
		{!"East Beach",                   {2632.80, -1668.10, -89.00, 2747.70, -1393.40, 110.90}},
		{!"East Beach",                   {2747.70, -1668.10, -89.00, 2959.30, -1498.60, 110.90}},
		{!"East Beach",                   {2747.70, -1498.60, -89.00, 2959.30, -1120.00, 110.90}},
		{!"East Los Santos",              {2421.00, -1628.50, -89.00, 2632.80, -1454.30, 110.90}},
		{!"East Los Santos",              {2222.50, -1628.50, -89.00, 2421.00, -1494.00, 110.90}},
		{!"East Los Santos",              {2266.20, -1494.00, -89.00, 2381.60, -1372.00, 110.90}},
		{!"East Los Santos",              {2381.60, -1494.00, -89.00, 2421.00, -1454.30, 110.90}},
		{!"East Los Santos",              {2281.40, -1372.00, -89.00, 2381.60, -1135.00, 110.90}},
		{!"East Los Santos",              {2381.60, -1454.30, -89.00, 2462.10, -1135.00, 110.90}},
		{!"East Los Santos",              {2462.10, -1454.30, -89.00, 2581.70, -1135.00, 110.90}},
		{!"Easter Basin",                 {-1794.90, 249.90, -9.10, -1242.90, 578.30, 200.00}},
		{!"Easter Basin",                 {-1794.90, -50.00, -0.00, -1499.80, 249.90, 200.00}},
		{!"Easter Bay Airport",           {-1499.80, -50.00, -0.00, -1242.90, 249.90, 200.00}},
		{!"Easter Bay Airport",           {-1794.90, -730.10, -3.00, -1213.90, -50.00, 200.00}},
		{!"Easter Bay Airport",           {-1213.90, -730.10, 0.00, -1132.80, -50.00, 200.00}},
		{!"Easter Bay Airport",           {-1242.90, -50.00, 0.00, -1213.90, 578.30, 200.00}},
		{!"Easter Bay Airport",           {-1213.90, -50.00, -4.50, -947.90, 578.30, 200.00}},
		{!"Easter Bay Airport",           {-1315.40, -405.30, 15.40, -1264.40, -209.50, 25.40}},
		{!"Easter Bay Airport",           {-1354.30, -287.30, 15.40, -1315.40, -209.50, 25.40}},
		{!"Easter Bay Airport",           {-1490.30, -209.50, 15.40, -1264.40, -148.30, 25.40}},
		{!"Easter Bay Chemicals",         {-1132.80, -768.00, 0.00, -956.40, -578.10, 200.00}},
		{!"Easter Bay Chemicals",         {-1132.80, -787.30, 0.00, -956.40, -768.00, 200.00}},
		{!"El Castillo del Diablo",       {-464.50, 2217.60, 0.00, -208.50, 2580.30, 200.00}},
		{!"El Castillo del Diablo",       {-208.50, 2123.00, -7.60, 114.00, 2337.10, 200.00}},
		{!"El Castillo del Diablo",       {-208.50, 2337.10, 0.00, 8.40, 2487.10, 200.00}},
		{!"El Corona",                    {1812.60, -2179.20, -89.00, 1970.60, -1852.80, 110.90}},
		{!"El Corona",                    {1692.60, -2179.20, -89.00, 1812.60, -1842.20, 110.90}},
		{!"El Quebrados",                 {-1645.20, 2498.50, 0.00, -1372.10, 2777.80, 200.00}},
		{!"Esplanade East",               {-1620.30, 1176.50, -4.50, -1580.00, 1274.20, 200.00}},
		{!"Esplanade East",               {-1580.00, 1025.90, -6.10, -1499.80, 1274.20, 200.00}},
		{!"Esplanade East",               {-1499.80, 578.30, -79.60, -1339.80, 1274.20, 20.30}},
		{!"Esplanade North",              {-2533.00, 1358.90, -4.50, -1996.60, 1501.20, 200.00}},
		{!"Esplanade North",              {-1996.60, 1358.90, -4.50, -1524.20, 1592.50, 200.00}},
		{!"Esplanade North",              {-1982.30, 1274.20, -4.50, -1524.20, 1358.90, 200.00}},
		{!"Fallen Tree",                  {-792.20, -698.50, -5.30, -452.40, -380.00, 200.00}},
		{!"Fallow Bridge",                {434.30, 366.50, 0.00, 603.00, 555.60, 200.00}},
		{!"Fern Ridge",                   {508.10, -139.20, 0.00, 1306.60, 119.50, 200.00}},
		{!"Financial",                    {-1871.70, 744.10, -6.10, -1701.30, 1176.40, 300.00}},
		{!"Fisher's Lagoon",              {1916.90, -233.30, -100.00, 2131.70, 13.80, 200.00}},
		{!"Flint Intersection",           {-187.70, -1596.70, -89.00, 17.00, -1276.60, 110.90}},
		{!"Flint Range",                  {-594.10, -1648.50, 0.00, -187.70, -1276.60, 200.00}},
		{!"Fort Carson",                  {-376.20, 826.30, -3.00, 123.70, 1220.40, 200.00}},
		{!"Foster Valley",                {-2270.00, -430.20, -0.00, -2178.60, -324.10, 200.00}},
		{!"Foster Valley",                {-2178.60, -599.80, -0.00, -1794.90, -324.10, 200.00}},
		{!"Foster Valley",                {-2178.60, -1115.50, 0.00, -1794.90, -599.80, 200.00}},
		{!"Foster Valley",                {-2178.60, -1250.90, 0.00, -1794.90, -1115.50, 200.00}},
		{!"Frederick Bridge",             {2759.20, 296.50, 0.00, 2774.20, 594.70, 200.00}},
		{!"Gant Bridge",                  {-2741.40, 1659.60, -6.10, -2616.40, 2175.10, 200.00}},
		{!"Gant Bridge",                  {-2741.00, 1490.40, -6.10, -2616.40, 1659.60, 200.00}},
		{!"Ganton",                       {2222.50, -1852.80, -89.00, 2632.80, -1722.30, 110.90}},
		{!"Ganton",                       {2222.50, -1722.30, -89.00, 2632.80, -1628.50, 110.90}},
		{!"Garcia",                       {-2411.20, -222.50, -0.00, -2173.00, 265.20, 200.00}},
		{!"Garcia",                       {-2395.10, -222.50, -5.30, -2354.00, -204.70, 200.00}},
		{!"Garver Bridge",                {-1339.80, 828.10, -89.00, -1213.90, 1057.00, 110.90}},
		{!"Garver Bridge",                {-1213.90, 950.00, -89.00, -1087.90, 1178.90, 110.90}},
		{!"Garver Bridge",                {-1499.80, 696.40, -179.60, -1339.80, 925.30, 20.30}},
		{!"Glen Park",                    {1812.60, -1449.60, -89.00, 1996.90, -1350.70, 110.90}},
		{!"Glen Park",                    {1812.60, -1100.80, -89.00, 1994.30, -973.30, 110.90}},
		{!"Glen Park",                    {1812.60, -1350.70, -89.00, 2056.80, -1100.80, 110.90}},
		{!"Green Palms",                  {176.50, 1305.40, -3.00, 338.60, 1520.70, 200.00}},
		{!"Greenglass College",           {964.30, 1044.60, -89.00, 1197.30, 1203.20, 110.90}},
		{!"Greenglass College",           {964.30, 930.80, -89.00, 1166.50, 1044.60, 110.90}},
		{!"Hampton Barns",                {603.00, 264.30, 0.00, 761.90, 366.50, 200.00}},
		{!"Hankypanky Point",             {2576.90, 62.10, 0.00, 2759.20, 385.50, 200.00}},
		{!"Harry Gold Parkway",           {1777.30, 863.20, -89.00, 1817.30, 2342.80, 110.90}},
		{!"Hashbury",                     {-2593.40, -222.50, -0.00, -2411.20, 54.70, 200.00}},
		{!"Hilltop Farm",                 {967.30, -450.30, -3.00, 1176.70, -217.90, 200.00}},
		{!"Hunter Quarry",                {337.20, 710.80, -115.20, 860.50, 1031.70, 203.70}},
		{!"Idlewood",                     {1812.60, -1852.80, -89.00, 1971.60, -1742.30, 110.90}},
		{!"Idlewood",                     {1812.60, -1742.30, -89.00, 1951.60, -1602.30, 110.90}},
		{!"Idlewood",                     {1951.60, -1742.30, -89.00, 2124.60, -1602.30, 110.90}},
		{!"Idlewood",                     {1812.60, -1602.30, -89.00, 2124.60, -1449.60, 110.90}},
		{!"Idlewood",                     {2124.60, -1742.30, -89.00, 2222.50, -1494.00, 110.90}},
		{!"Idlewood",                     {1971.60, -1852.80, -89.00, 2222.50, -1742.30, 110.90}},
		{!"Jefferson",                    {1996.90, -1449.60, -89.00, 2056.80, -1350.70, 110.90}},
		{!"Jefferson",                    {2124.60, -1494.00, -89.00, 2266.20, -1449.60, 110.90}},
		{!"Jefferson",                    {2056.80, -1372.00, -89.00, 2281.40, -1210.70, 110.90}},
		{!"Jefferson",                    {2056.80, -1210.70, -89.00, 2185.30, -1126.30, 110.90}},
		{!"Jefferson",                    {2185.30, -1210.70, -89.00, 2281.40, -1154.50, 110.90}},
		{!"Jefferson",                    {2056.80, -1449.60, -89.00, 2266.20, -1372.00, 110.90}},
		{!"Julius Thruway East",          {2623.10, 943.20, -89.00, 2749.90, 1055.90, 110.90}},
		{!"Julius Thruway East",          {2685.10, 1055.90, -89.00, 2749.90, 2626.50, 110.90}},
		{!"Julius Thruway East",          {2536.40, 2442.50, -89.00, 2685.10, 2542.50, 110.90}},
		{!"Julius Thruway East",          {2625.10, 2202.70, -89.00, 2685.10, 2442.50, 110.90}},
		{!"Julius Thruway North",         {2498.20, 2542.50, -89.00, 2685.10, 2626.50, 110.90}},
		{!"Julius Thruway North",         {2237.40, 2542.50, -89.00, 2498.20, 2663.10, 110.90}},
		{!"Julius Thruway North",         {2121.40, 2508.20, -89.00, 2237.40, 2663.10, 110.90}},
		{!"Julius Thruway North",         {1938.80, 2508.20, -89.00, 2121.40, 2624.20, 110.90}},
		{!"Julius Thruway North",         {1534.50, 2433.20, -89.00, 1848.40, 2583.20, 110.90}},
		{!"Julius Thruway North",         {1848.40, 2478.40, -89.00, 1938.80, 2553.40, 110.90}},
		{!"Julius Thruway North",         {1704.50, 2342.80, -89.00, 1848.40, 2433.20, 110.90}},
		{!"Julius Thruway North",         {1377.30, 2433.20, -89.00, 1534.50, 2507.20, 110.90}},
		{!"Julius Thruway South",         {1457.30, 823.20, -89.00, 2377.30, 863.20, 110.90}},
		{!"Julius Thruway South",         {2377.30, 788.80, -89.00, 2537.30, 897.90, 110.90}},
		{!"Julius Thruway West",          {1197.30, 1163.30, -89.00, 1236.60, 2243.20, 110.90}},
		{!"Julius Thruway West",          {1236.60, 2142.80, -89.00, 1297.40, 2243.20, 110.90}},
		{!"Juniper Hill",                 {-2533.00, 578.30, -7.60, -2274.10, 968.30, 200.00}},
		{!"Juniper Hollow",               {-2533.00, 968.30, -6.10, -2274.10, 1358.90, 200.00}},
		{!"K.A.C.C. Military Fuels",      {2498.20, 2626.50, -89.00, 2749.90, 2861.50, 110.90}},
		{!"Kincaid Bridge",               {-1339.80, 599.20, -89.00, -1213.90, 828.10, 110.90}},
		{!"Kincaid Bridge",               {-1213.90, 721.10, -89.00, -1087.90, 950.00, 110.90}},
		{!"Kincaid Bridge",               {-1087.90, 855.30, -89.00, -961.90, 986.20, 110.90}},
		{!"King's",                       {-2329.30, 458.40, -7.60, -1993.20, 578.30, 200.00}},
		{!"King's",                       {-2411.20, 265.20, -9.10, -1993.20, 373.50, 200.00}},
		{!"King's",                       {-2253.50, 373.50, -9.10, -1993.20, 458.40, 200.00}},
		{!"LVA Freight Depot",            {1457.30, 863.20, -89.00, 1777.40, 1143.20, 110.90}},
		{!"LVA Freight Depot",            {1375.60, 919.40, -89.00, 1457.30, 1203.20, 110.90}},
		{!"LVA Freight Depot",            {1277.00, 1087.60, -89.00, 1375.60, 1203.20, 110.90}},
		{!"LVA Freight Depot",            {1315.30, 1044.60, -89.00, 1375.60, 1087.60, 110.90}},
		{!"LVA Freight Depot",            {1236.60, 1163.40, -89.00, 1277.00, 1203.20, 110.90}},
		{!"Las Barrancas",                {-926.10, 1398.70, -3.00, -719.20, 1634.60, 200.00}},
		{!"Las Brujas",                   {-365.10, 2123.00, -3.00, -208.50, 2217.60, 200.00}},
		{!"Las Colinas",                  {1994.30, -1100.80, -89.00, 2056.80, -920.80, 110.90}},
		{!"Las Colinas",                  {2056.80, -1126.30, -89.00, 2126.80, -920.80, 110.90}},
		{!"Las Colinas",                  {2185.30, -1154.50, -89.00, 2281.40, -934.40, 110.90}},
		{!"Las Colinas",                  {2126.80, -1126.30, -89.00, 2185.30, -934.40, 110.90}},
		{!"Las Colinas",                  {2747.70, -1120.00, -89.00, 2959.30, -945.00, 110.90}},
		{!"Las Colinas",                  {2632.70, -1135.00, -89.00, 2747.70, -945.00, 110.90}},
		{!"Las Colinas",                  {2281.40, -1135.00, -89.00, 2632.70, -945.00, 110.90}},
		{!"Las Payasadas",                {-354.30, 2580.30, 2.00, -133.60, 2816.80, 200.00}},
		{!"Las Venturas Airport",         {1236.60, 1203.20, -89.00, 1457.30, 1883.10, 110.90}},
		{!"Las Venturas Airport",         {1457.30, 1203.20, -89.00, 1777.30, 1883.10, 110.90}},
		{!"Las Venturas Airport",         {1457.30, 1143.20, -89.00, 1777.40, 1203.20, 110.90}},
		{!"Las Venturas Airport",         {1515.80, 1586.40, -12.50, 1729.90, 1714.50, 87.50}},
		{!"Last Dime Motel",              {1823.00, 596.30, -89.00, 1997.20, 823.20, 110.90}},
		{!"Leafy Hollow",                 {-1166.90, -1856.00, 0.00, -815.60, -1602.00, 200.00}},
		{!"Liberty City",                 {-1000.00, 400.00, 1300.00, -700.00, 600.00, 1400.00}},
		{!"Lil' Probe Inn",               {-90.20, 1286.80, -3.00, 153.80, 1554.10, 200.00}},
		{!"Linden Side",                  {2749.90, 943.20, -89.00, 2923.30, 1198.90, 110.90}},
		{!"Linden Station",               {2749.90, 1198.90, -89.00, 2923.30, 1548.90, 110.90}},
		{!"Linden Station",               {2811.20, 1229.50, -39.50, 2861.20, 1407.50, 60.40}},
		{!"Little Mexico",                {1701.90, -1842.20, -89.00, 1812.60, -1722.20, 110.90}},
		{!"Little Mexico",                {1758.90, -1722.20, -89.00, 1812.60, -1577.50, 110.90}},
		{!"Los Flores",                   {2581.70, -1454.30, -89.00, 2632.80, -1393.40, 110.90}},
		{!"Los Flores",                   {2581.70, -1393.40, -89.00, 2747.70, -1135.00, 110.90}},
		{!"Los Santos International",     {1249.60, -2394.30, -89.00, 1852.00, -2179.20, 110.90}},
		{!"Los Santos International",     {1852.00, -2394.30, -89.00, 2089.00, -2179.20, 110.90}},
		{!"Los Santos International",     {1382.70, -2730.80, -89.00, 2201.80, -2394.30, 110.90}},
		{!"Los Santos International",     {1974.60, -2394.30, -39.00, 2089.00, -2256.50, 60.90}},
		{!"Los Santos International",     {1400.90, -2669.20, -39.00, 2189.80, -2597.20, 60.90}},
		{!"Los Santos International",     {2051.60, -2597.20, -39.00, 2152.40, -2394.30, 60.90}},
		{!"Marina",                       {647.70, -1804.20, -89.00, 851.40, -1577.50, 110.90}},
		{!"Marina",                       {647.70, -1577.50, -89.00, 807.90, -1416.20, 110.90}},
		{!"Marina",                       {807.90, -1577.50, -89.00, 926.90, -1416.20, 110.90}},
		{!"Market",                       {787.40, -1416.20, -89.00, 1072.60, -1310.20, 110.90}},
		{!"Market",                       {952.60, -1310.20, -89.00, 1072.60, -1130.80, 110.90}},
		{!"Market",                       {1072.60, -1416.20, -89.00, 1370.80, -1130.80, 110.90}},
		{!"Market",                       {926.90, -1577.50, -89.00, 1370.80, -1416.20, 110.90}},
		{!"Market Station",               {787.40, -1410.90, -34.10, 866.00, -1310.20, 65.80}},
		{!"Martin Bridge",                {-222.10, 293.30, 0.00, -122.10, 476.40, 200.00}},
		{!"Missionary Hill",              {-2994.40, -811.20, 0.00, -2178.60, -430.20, 200.00}},
		{!"Montgomery",                   {1119.50, 119.50, -3.00, 1451.40, 493.30, 200.00}},
		{!"Montgomery",                   {1451.40, 347.40, -6.10, 1582.40, 420.80, 200.00}},
		{!"Montgomery Intersection",      {1546.60, 208.10, 0.00, 1745.80, 347.40, 200.00}},
		{!"Montgomery Intersection",      {1582.40, 347.40, 0.00, 1664.60, 401.70, 200.00}},
		{!"Mulholland",                   {1414.00, -768.00, -89.00, 1667.60, -452.40, 110.90}},
		{!"Mulholland",                   {1281.10, -452.40, -89.00, 1641.10, -290.90, 110.90}},
		{!"Mulholland",                   {1269.10, -768.00, -89.00, 1414.00, -452.40, 110.90}},
		{!"Mulholland",                   {1357.00, -926.90, -89.00, 1463.90, -768.00, 110.90}},
		{!"Mulholland",                   {1318.10, -910.10, -89.00, 1357.00, -768.00, 110.90}},
		{!"Mulholland",                   {1169.10, -910.10, -89.00, 1318.10, -768.00, 110.90}},
		{!"Mulholland",                   {768.60, -954.60, -89.00, 952.60, -860.60, 110.90}},
		{!"Mulholland",                   {687.80, -860.60, -89.00, 911.80, -768.00, 110.90}},
		{!"Mulholland",                   {737.50, -768.00, -89.00, 1142.20, -674.80, 110.90}},
		{!"Mulholland",                   {1096.40, -910.10, -89.00, 1169.10, -768.00, 110.90}},
		{!"Mulholland",                   {952.60, -937.10, -89.00, 1096.40, -860.60, 110.90}},
		{!"Mulholland",                   {911.80, -860.60, -89.00, 1096.40, -768.00, 110.90}},
		{!"Mulholland",                   {861.00, -674.80, -89.00, 1156.50, -600.80, 110.90}},
		{!"Mulholland Intersection",      {1463.90, -1150.80, -89.00, 1812.60, -768.00, 110.90}},
		{!"North Rock",                   {2285.30, -768.00, 0.00, 2770.50, -269.70, 200.00}},
		{!"Ocean Docks",                  {2373.70, -2697.00, -89.00, 2809.20, -2330.40, 110.90}},
		{!"Ocean Docks",                  {2201.80, -2418.30, -89.00, 2324.00, -2095.00, 110.90}},
		{!"Ocean Docks",                  {2324.00, -2302.30, -89.00, 2703.50, -2145.10, 110.90}},
		{!"Ocean Docks",                  {2089.00, -2394.30, -89.00, 2201.80, -2235.80, 110.90}},
		{!"Ocean Docks",                  {2201.80, -2730.80, -89.00, 2324.00, -2418.30, 110.90}},
		{!"Ocean Docks",                  {2703.50, -2302.30, -89.00, 2959.30, -2126.90, 110.90}},
		{!"Ocean Docks",                  {2324.00, -2145.10, -89.00, 2703.50, -2059.20, 110.90}},
		{!"Ocean Flats",                  {-2994.40, 277.40, -9.10, -2867.80, 458.40, 200.00}},
		{!"Ocean Flats",                  {-2994.40, -222.50, -0.00, -2593.40, 277.40, 200.00}},
		{!"Ocean Flats",                  {-2994.40, -430.20, -0.00, -2831.80, -222.50, 200.00}},
		{!"Octane Springs",               {338.60, 1228.50, 0.00, 664.30, 1655.00, 200.00}},
		{!"Old Venturas Strip",           {2162.30, 2012.10, -89.00, 2685.10, 2202.70, 110.90}},
		{!"Palisades",                    {-2994.40, 458.40, -6.10, -2741.00, 1339.60, 200.00}},
		{!"Palomino Creek",               {2160.20, -149.00, 0.00, 2576.90, 228.30, 200.00}},
		{!"Paradiso",                     {-2741.00, 793.40, -6.10, -2533.00, 1268.40, 200.00}},
		{!"Pershing Square",              {1440.90, -1722.20, -89.00, 1583.50, -1577.50, 110.90}},
		{!"Pilgrim",                      {2437.30, 1383.20, -89.00, 2624.40, 1783.20, 110.90}},
		{!"Pilgrim",                      {2624.40, 1383.20, -89.00, 2685.10, 1783.20, 110.90}},
		{!"Pilson Intersection",          {1098.30, 2243.20, -89.00, 1377.30, 2507.20, 110.90}},
		{!"Pirates in Men's Pants",       {1817.30, 1469.20, -89.00, 2027.40, 1703.20, 110.90}},
		{!"Playa del Seville",            {2703.50, -2126.90, -89.00, 2959.30, -1852.80, 110.90}},
		{!"Prickle Pine",                 {1534.50, 2583.20, -89.00, 1848.40, 2863.20, 110.90}},
		{!"Prickle Pine",                 {1117.40, 2507.20, -89.00, 1534.50, 2723.20, 110.90}},
		{!"Prickle Pine",                 {1848.40, 2553.40, -89.00, 1938.80, 2863.20, 110.90}},
		{!"Prickle Pine",                 {1938.80, 2624.20, -89.00, 2121.40, 2861.50, 110.90}},
		{!"Queens",                       {-2533.00, 458.40, 0.00, -2329.30, 578.30, 200.00}},
		{!"Queens",                       {-2593.40, 54.70, 0.00, -2411.20, 458.40, 200.00}},
		{!"Queens",                       {-2411.20, 373.50, 0.00, -2253.50, 458.40, 200.00}},
		{!"Randolph Industrial Estate",   {1558.00, 596.30, -89.00, 1823.00, 823.20, 110.90}},
		{!"Redsands East",                {1817.30, 2011.80, -89.00, 2106.70, 2202.70, 110.90}},
		{!"Redsands East",                {1817.30, 2202.70, -89.00, 2011.90, 2342.80, 110.90}},
		{!"Redsands East",                {1848.40, 2342.80, -89.00, 2011.90, 2478.40, 110.90}},
		{!"Redsands West",                {1236.60, 1883.10, -89.00, 1777.30, 2142.80, 110.90}},
		{!"Redsands West",                {1297.40, 2142.80, -89.00, 1777.30, 2243.20, 110.90}},
		{!"Redsands West",                {1377.30, 2243.20, -89.00, 1704.50, 2433.20, 110.90}},
		{!"Redsands West",                {1704.50, 2243.20, -89.00, 1777.30, 2342.80, 110.90}},
		{!"Regular Tom",                  {-405.70, 1712.80, -3.00, -276.70, 1892.70, 200.00}},
		{!"Richman",                      {647.50, -1118.20, -89.00, 787.40, -954.60, 110.90}},
		{!"Richman",                      {647.50, -954.60, -89.00, 768.60, -860.60, 110.90}},
		{!"Richman",                      {225.10, -1369.60, -89.00, 334.50, -1292.00, 110.90}},
		{!"Richman",                      {225.10, -1292.00, -89.00, 466.20, -1235.00, 110.90}},
		{!"Richman",                      {72.60, -1404.90, -89.00, 225.10, -1235.00, 110.90}},
		{!"Richman",                      {72.60, -1235.00, -89.00, 321.30, -1008.10, 110.90}},
		{!"Richman",                      {321.30, -1235.00, -89.00, 647.50, -1044.00, 110.90}},
		{!"Richman",                      {321.30, -1044.00, -89.00, 647.50, -860.60, 110.90}},
		{!"Richman",                      {321.30, -860.60, -89.00, 687.80, -768.00, 110.90}},
		{!"Richman",                      {321.30, -768.00, -89.00, 700.70, -674.80, 110.90}},
		{!"Robada Intersection",          {-1119.00, 1178.90, -89.00, -862.00, 1351.40, 110.90}},
		{!"Roca Escalante",               {2237.40, 2202.70, -89.00, 2536.40, 2542.50, 110.90}},
		{!"Roca Escalante",               {2536.40, 2202.70, -89.00, 2625.10, 2442.50, 110.90}},
		{!"Rockshore East",               {2537.30, 676.50, -89.00, 2902.30, 943.20, 110.90}},
		{!"Rockshore West",               {1997.20, 596.30, -89.00, 2377.30, 823.20, 110.90}},
		{!"Rockshore West",               {2377.30, 596.30, -89.00, 2537.30, 788.80, 110.90}},
		{!"Rodeo",                        {72.60, -1684.60, -89.00, 225.10, -1544.10, 110.90}},
		{!"Rodeo",                        {72.60, -1544.10, -89.00, 225.10, -1404.90, 110.90}},
		{!"Rodeo",                        {225.10, -1684.60, -89.00, 312.80, -1501.90, 110.90}},
		{!"Rodeo",                        {225.10, -1501.90, -89.00, 334.50, -1369.60, 110.90}},
		{!"Rodeo",                        {334.50, -1501.90, -89.00, 422.60, -1406.00, 110.90}},
		{!"Rodeo",                        {312.80, -1684.60, -89.00, 422.60, -1501.90, 110.90}},
		{!"Rodeo",                        {422.60, -1684.60, -89.00, 558.00, -1570.20, 110.90}},
		{!"Rodeo",                        {558.00, -1684.60, -89.00, 647.50, -1384.90, 110.90}},
		{!"Rodeo",                        {466.20, -1570.20, -89.00, 558.00, -1385.00, 110.90}},
		{!"Rodeo",                        {422.60, -1570.20, -89.00, 466.20, -1406.00, 110.90}},
		{!"Rodeo",                        {466.20, -1385.00, -89.00, 647.50, -1235.00, 110.90}},
		{!"Rodeo",                        {334.50, -1406.00, -89.00, 466.20, -1292.00, 110.90}},
		{!"Royal Casino",                 {2087.30, 1383.20, -89.00, 2437.30, 1543.20, 110.90}},
		{!"San Andreas Sound",            {2450.30, 385.50, -100.00, 2759.20, 562.30, 200.00}},
		{!"Santa Flora",                  {-2741.00, 458.40, -7.60, -2533.00, 793.40, 200.00}},
		{!"Santa Maria Beach",            {342.60, -2173.20, -89.00, 647.70, -1684.60, 110.90}},
		{!"Santa Maria Beach",            {72.60, -2173.20, -89.00, 342.60, -1684.60, 110.90}},
		{!"Shady Cabin",                  {-1632.80, -2263.40, -3.00, -1601.30, -2231.70, 200.00}},
		{!"Shady Creeks",                 {-1820.60, -2643.60, -8.00, -1226.70, -1771.60, 200.00}},
		{!"Shady Creeks",                 {-2030.10, -2174.80, -6.10, -1820.60, -1771.60, 200.00}},
		{!"Sobell Rail Yards",            {2749.90, 1548.90, -89.00, 2923.30, 1937.20, 110.90}},
		{!"Spinybed",                     {2121.40, 2663.10, -89.00, 2498.20, 2861.50, 110.90}},
		{!"Starfish Casino",              {2437.30, 1783.20, -89.00, 2685.10, 2012.10, 110.90}},
		{!"Starfish Casino",              {2437.30, 1858.10, -39.00, 2495.00, 1970.80, 60.90}},
		{!"Starfish Casino",              {2162.30, 1883.20, -89.00, 2437.30, 2012.10, 110.90}},
		{!"Temple",                       {1252.30, -1130.80, -89.00, 1378.30, -1026.30, 110.90}},
		{!"Temple",                       {1252.30, -1026.30, -89.00, 1391.00, -926.90, 110.90}},
		{!"Temple",                       {1252.30, -926.90, -89.00, 1357.00, -910.10, 110.90}},
		{!"Temple",                       {952.60, -1130.80, -89.00, 1096.40, -937.10, 110.90}},
		{!"Temple",                       {1096.40, -1130.80, -89.00, 1252.30, -1026.30, 110.90}},
		{!"Temple",                       {1096.40, -1026.30, -89.00, 1252.30, -910.10, 110.90}},
		{!"The Camel's Toe",              {2087.30, 1203.20, -89.00, 2640.40, 1383.20, 110.90}},
		{!"The Clown's Pocket",           {2162.30, 1783.20, -89.00, 2437.30, 1883.20, 110.90}},
		{!"The Emerald Isle",             {2011.90, 2202.70, -89.00, 2237.40, 2508.20, 110.90}},
		{!"The Farm",                     {-1209.60, -1317.10, 114.90, -908.10, -787.30, 251.90}},
		{!"The Four Dragons Casino",      {1817.30, 863.20, -89.00, 2027.30, 1083.20, 110.90}},
		{!"The High Roller",              {1817.30, 1283.20, -89.00, 2027.30, 1469.20, 110.90}},
		{!"The Mako Span",                {1664.60, 401.70, 0.00, 1785.10, 567.20, 200.00}},
		{!"The Panopticon",               {-947.90, -304.30, -1.10, -319.60, 327.00, 200.00}},
		{!"The Pink Swan",                {1817.30, 1083.20, -89.00, 2027.30, 1283.20, 110.90}},
		{!"The Sherman Dam",              {-968.70, 1929.40, -3.00, -481.10, 2155.20, 200.00}},
		{!"The Strip",                    {2027.40, 863.20, -89.00, 2087.30, 1703.20, 110.90}},
		{!"The Strip",                    {2106.70, 1863.20, -89.00, 2162.30, 2202.70, 110.90}},
		{!"The Strip",                    {2027.40, 1783.20, -89.00, 2162.30, 1863.20, 110.90}},
		{!"The Strip",                    {2027.40, 1703.20, -89.00, 2137.40, 1783.20, 110.90}},
		{!"The Visage",                   {1817.30, 1863.20, -89.00, 2106.70, 2011.80, 110.90}},
		{!"The Visage",                   {1817.30, 1703.20, -89.00, 2027.40, 1863.20, 110.90}},
		{!"Unity Station",                {1692.60, -1971.80, -20.40, 1812.60, -1932.80, 79.50}},
		{!"Valle Ocultado",               {-936.60, 2611.40, 2.00, -715.90, 2847.90, 200.00}},
		{!"Verdant Bluffs",               {930.20, -2488.40, -89.00, 1249.60, -2006.70, 110.90}},
		{!"Verdant Bluffs",               {1073.20, -2006.70, -89.00, 1249.60, -1842.20, 110.90}},
		{!"Verdant Bluffs",               {1249.60, -2179.20, -89.00, 1692.60, -1842.20, 110.90}},
		{!"Verdant Meadows",              {37.00, 2337.10, -3.00, 435.90, 2677.90, 200.00}},
		{!"Verona Beach",                 {647.70, -2173.20, -89.00, 930.20, -1804.20, 110.90}},
		{!"Verona Beach",                 {930.20, -2006.70, -89.00, 1073.20, -1804.20, 110.90}},
		{!"Verona Beach",                 {851.40, -1804.20, -89.00, 1046.10, -1577.50, 110.90}},
		{!"Verona Beach",                 {1161.50, -1722.20, -89.00, 1323.90, -1577.50, 110.90}},
		{!"Verona Beach",                 {1046.10, -1722.20, -89.00, 1161.50, -1577.50, 110.90}},
		{!"Vinewood",                     {787.40, -1310.20, -89.00, 952.60, -1130.80, 110.90}},
		{!"Vinewood",                     {787.40, -1130.80, -89.00, 952.60, -954.60, 110.90}},
		{!"Vinewood",                     {647.50, -1227.20, -89.00, 787.40, -1118.20, 110.90}},
		{!"Vinewood",                     {647.70, -1416.20, -89.00, 787.40, -1227.20, 110.90}},
		{!"Whitewood Estates",            {883.30, 1726.20, -89.00, 1098.30, 2507.20, 110.90}},
		{!"Whitewood Estates",            {1098.30, 1726.20, -89.00, 1197.30, 2243.20, 110.90}},
		{!"Willowfield",                  {1970.60, -2179.20, -89.00, 2089.00, -1852.80, 110.90}},
		{!"Willowfield",                  {2089.00, -2235.80, -89.00, 2201.80, -1989.90, 110.90}},
		{!"Willowfield",                  {2089.00, -1989.90, -89.00, 2324.00, -1852.80, 110.90}},
		{!"Willowfield",                  {2201.80, -2095.00, -89.00, 2324.00, -1989.90, 110.90}},
		{!"Willowfield",                  {2541.70, -1941.40, -89.00, 2703.50, -1852.80, 110.90}},
		{!"Willowfield",                  {2324.00, -2059.20, -89.00, 2541.70, -1852.80, 110.90}},
		{!"Willowfield",                  {2541.70, -2059.20, -89.00, 2703.50, -1941.40, 110.90}},
		{!"Yellow Bell Station",          {1377.40, 2600.40, -21.90, 1492.40, 2687.30, 78.00}},
		{!"Los Santos",                   {44.60, -2892.90, -242.90, 2997.00, -768.00, 900.00}},
		{!"Las Venturas",                 {869.40, 596.30, -242.90, 2997.00, 2993.80, 900.00}},
		{!"Bone County",                  {-480.50, 596.30, -242.90, 869.40, 2993.80, 900.00}},
		{!"Tierra Robada",                {-2997.40, 1659.60, -242.90, -480.50, 2993.80, 900.00}},
		{!"Tierra Robada",                {-1213.90, 596.30, -242.90, -480.50, 1659.60, 900.00}},
		{!"San Fierro",                   {-2997.40, -1115.50, -242.90, -1213.90, 1659.60, 900.00}},
		{!"Red County",                   {-1213.90, -768.00, -242.90, 2997.00, 596.30, 900.00}},
		{!"Flint County",                 {-1213.90, -2892.90, -242.90, 44.60, -768.00, 900.00}},
		{!"Whetstone",                    {-2997.40, -2892.90, -242.90, -1213.90, -1115.50, 900.00}}
	};
	static isim[32] = "San Andreas";

	for (new i = 0; i != sizeof(bolgelerBilgi); i ++) if((fX >= bolgelerBilgi[i][bolgePos][0] && fX <= bolgelerBilgi[i][bolgePos][3]) && (fY >= bolgelerBilgi[i][bolgePos][1] && fY <= bolgelerBilgi[i][bolgePos][4]) && (fZ >= bolgelerBilgi[i][bolgePos][2] && fZ <= bolgelerBilgi[i][bolgePos][5])) {
		strunpack(isim, bolgelerBilgi[i][bolgeAdi]);
		break;
	}
	return isim;
}

CreateNPCEx(herd_id, skin = 1, Float: health = 100.0, Float: armour = 0.0, damage = 5, walk_speed = 3, Float:x, Float:y, Float:z)
{
	new id = -1;
	new query[400];

	for(new i = 0; i < MAX_DYNAMIC_NPC; i++) if(NPCInfo[i][NPC_database_id] < 1)
	{
		id = i;

		NPCInfo[id][NPC_x] = x;
		NPCInfo[id][NPC_y] = y;
		NPCInfo[id][NPC_z] = z;

		NPCInfo[id][NPC_health] = health;
		NPCInfo[id][NPC_armour] = armour;

		NPCInfo[id][NPC_skin] = skin;
		NPCInfo[id][NPC_damage] = damage;
		NPCInfo[id][NPC_walk_speed] = walk_speed;
		NPCInfo[id][NPC_bite] = NPC_BITES;

		NPCInfo[id][NPC_herd_id] = herd_id;

		mysql_format(SQL_Handle, query, sizeof(query), "INSERT INTO `npcs` (`npc_skin`, `npc_health`, `npc_armour`, `npc_damage`, `npc_walk_speed`, `npc_bite`, `npc_herd_id`, `npc_x`, `npc_y`, `npc_z`) VALUES('%d', '%f', '%f', '%d', '%d', '%d', '%d', '%f', '%f', '%f')", NPCInfo[id][NPC_skin], NPCInfo[id][NPC_health], NPCInfo[id][NPC_armour], NPCInfo[id][NPC_damage], NPCInfo[id][NPC_walk_speed], NPCInfo[id][NPC_bite], NPCInfo[id][NPC_herd_id], NPCInfo[id][NPC_x], NPCInfo[id][NPC_y], NPCInfo[id][NPC_z]);
		mysql_tquery(SQL_Handle, query, "OnNPCCreated", "d", id);
		break;
	}

	return id;
}

stock NPC_Delete(id)
{
	new query[64];
	
	mysql_format(SQL_Handle, query, sizeof(query), "DELETE FROM `npcs` WHERE `npc_id` = '%d'", NPCInfo[id][NPC_database_id]);
	mysql_tquery(SQL_Handle, query);

	NPCInfo[id][NPC_database_id] = 0;
	FCNPC_Destroy(NPCInfo[id][NPC_game_id]);
	return 1;
}

stock NPC_Spawn(id)
{
	// amper yap lan amc�k
	// not: NPCInfo[id][NPC_game_id] = FCNPC_spawn.... �eklinde yapman gerekiyor

	new str[MAX_PLAYER_NAME];
	format(str, sizeof(str), "Zombi_%d", id);
	NPCInfo[id][NPC_game_id] = FCNPC_Create(str);

	FCNPC_Spawn(NPCInfo[id][NPC_game_id], NPCInfo[id][NPC_skin], NPCInfo[id][NPC_x], NPCInfo[id][NPC_y], NPCInfo[id][NPC_z]);
	FCNPC_SetHealth(NPCInfo[id][NPC_game_id], NPCInfo[id][NPC_health]);
	FCNPC_SetArmour(NPCInfo[id][NPC_game_id], NPCInfo[id][NPC_armour]);

	NPCInfo[id][NPC_area] = CreateDynamicCircle(NPCInfo[id][NPC_x], NPCInfo[id][NPC_y], 5.0);
	NPCInfo[id][NPC_timer] = repeat FCNPC_OnInfectedUpdate(id);
	NPCInfo[id][NPC_status] = NPC_Idle;

	NPC_Save(NPCInfo[id][NPC_game_id]);
	return 1;
}

stock NPC_Save(id)
{
	id = FindNPCArrayID(id);

	if(id == -1 || NPCInfo[id][NPC_database_id] < 1)
		return 0;

	if(FCNPC_IsValid(NPCInfo[id][NPC_game_id]))
	{
		NPCInfo[id][NPC_health] = FCNPC_GetHealth(NPCInfo[id][NPC_game_id]);
		NPCInfo[id][NPC_armour] = FCNPC_GetArmour(NPCInfo[id][NPC_game_id]);

		FCNPC_GetPosition(NPCInfo[id][NPC_game_id], NPCInfo[id][NPC_x], NPCInfo[id][NPC_y], NPCInfo[id][NPC_z]);
	}

	new query[512];
	format(query, sizeof(query), "UPDATE `npcs` SET `npc_skin` = '%d', `npc_health` = '%f', `npc_armour` = '%f', `npc_damage` = '%d', `npc_walk_speed` = '%d', `npc_bite` = '%d', `npc_herd_id` = '%d', `npc_x` = '%f', `npc_y` = '%f', `npc_z` = '%f' WHERE `npc_id` = '%d'",
		NPCInfo[id][NPC_name],
		NPCInfo[id][NPC_skin],
		NPCInfo[id][NPC_health],
		NPCInfo[id][NPC_armour],
		NPCInfo[id][NPC_damage],
		NPCInfo[id][NPC_walk_speed],
		NPCInfo[id][NPC_bite],
		NPCInfo[id][NPC_herd_id],
		NPCInfo[id][NPC_x],
		NPCInfo[id][NPC_y],
		NPCInfo[id][NPC_z],
		NPCInfo[id][NPC_database_id]
	);

	mysql_tquery(SQL_Handle, query);
	return 1;
}

stock FindNPCArrayID(npcid)
{
	new id = -1;

	if(FCNPC_IsValid(npcid))
	{
		for(new i = 0; i < MAX_PLAYERS; i++)
		{
			if(NPCInfo[i][NPC_game_id] == npcid)
			{
				id = i;
				return id;
			}
		}
	}
	return id;
}

SetMySQLConnection()
{
	new MySQLOpt: option_id = mysql_init_options();

	mysql_set_option(option_id, AUTO_RECONNECT, true);

	SQL_Handle = mysql_connect(MYSQL_HOST, MYSQL_USER, MYSQL_PASSWORD, MYSQL_DATABASE, option_id);

	if(SQL_Handle == MYSQL_INVALID_HANDLE || mysql_errno(SQL_Handle) != 0)
	{
		print("Server: MySQL Connection failed. Server is shutting down.");
		SendRconCommand("exit");
		return 1;
	}else{
		print("Server: MySQL Connection is successful.");
	}

	mysql_log(ERROR | WARNING);
	mysql_tquery(SQL_Handle, "SET NAMES `latin5`");
	mysql_tquery(SQL_Handle, "SET CHARACTER SET `latin5`");
	mysql_tquery(SQL_Handle, "SET COLLATION_CONNECTION = `latin5_turkish_ci`");
	
	LoadDynamicSystems();
	return 1;
}

SetServerDefinitions()
{
	print("Server: Definitions are being integrated...");
	SendRconCommand("hostname "SERVER_NAME""), printf("[Integrated] Server name: %s", SERVER_NAME);
	SendRconCommand("weburl "SERVER_WEB""), printf("[Integrated] Server website: %s", SERVER_WEB);
	SendRconCommand("mapname "SERVER_MAP""), printf("[Integrated] Server map name: %s", SERVER_MAP);
	SendRconCommand("language "SERVER_LANG""), printf("[Integrated] Server language: %s", SERVER_LANG);
	SetGameModeText(SERVER_VERSION), printf("[Integrated] Server gamemode version: %s", SERVER_VERSION);
	print("Server: The definitions were integrated.");
	return 1;
}

SetServerSettings()
{
	print("Server: Settings are being integrated...");
	DisableInteriorEnterExits(), EnableStuntBonusForAll(0), SetNameTagDrawDistance(0.0), ShowNameTags(0), ShowPlayerMarkers(0);
	print("Server: Settings were integrated.");
	return 1;
}

ResetAccountStats(playerid)
{
	SQL_RaceCheck[playerid]++;

	Account[playerid][Account_SQL] = -1;

	if(cache_is_valid(Account[playerid][Account_CacheID]))
	{
		cache_delete(Account[playerid][Account_CacheID]);
		Account[playerid][Account_CacheID] = MYSQL_INVALID_CACHE;
	}
    Account[playerid][Account_Name][0] = EOS;
    Account[playerid][Account_Password][0] = EOS;

	Account[playerid][Account_AvailableSlots] = 0;
	Account[playerid][Account_ActiveSlots] = 0;
	Account[playerid][Account_Staff] = 0;
	
	Account[playerid][Settings_Pm] = 0;
	Account[playerid][Settings_OOC] = 0;

	Account[playerid][Account_LoginAttempts] = 0;
	Account[playerid][Account_IsLogged] = false;
	Account[playerid][Account_IsPlaying] = false;

	KillTimer(Account[playerid][Account_LoginTimer]);
	Account[playerid][Account_LoginTimer] = -1;

	KillTimer(Account[playerid][Account_KickTimer]);
	Account[playerid][Account_KickTimer] = -1;
	return 1;
}

KickEx(playerid) return Account[playerid][Account_KickTimer] = SetTimerEx("DelayedKick", 300, false, "d", playerid);

UpdateAccount(playerid)
{
	if(!Account[playerid][Account_IsLogged]) return 1;

	new query[200];
	mysql_format(SQL_Handle, query, sizeof(query), "UPDATE `accounts` SET `account_availableslots` = '%d', `account_activeslots` = '%d', `account_staff` = '%d', `settings_pm` = '%d', `settings_ooc` = '%d' WHERE `account_sql` = '%d'",
		Account[playerid][Account_AvailableSlots],
		Account[playerid][Account_ActiveSlots],
		Account[playerid][Account_Staff],
		Account[playerid][Settings_Pm],
		Account[playerid][Settings_OOC],
		Account[playerid][Account_SQL]
	);

	mysql_tquery(SQL_Handle, query);
	return 1;
}

GetAccountData(playerid)
{
	cache_get_value_int(0, "account_sql", Account[playerid][Account_SQL]);
	cache_get_value_int(0, "account_availableslots", Account[playerid][Account_AvailableSlots]);
	cache_get_value_int(0, "account_activeslots", Account[playerid][Account_ActiveSlots]);
	cache_get_value_int(0, "account_staff", Account[playerid][Account_Staff]);
	cache_get_value_int(0, "settings_pm", Account[playerid][Settings_Pm]);
	cache_get_value_int(0, "settings_ooc", Account[playerid][Settings_OOC]);
	return 1;
}

Date()
{
	new date[36];
	getdate(date[2], date[1], date[0]);
	gettime(date[3], date[4], date[5]);

	format(date, sizeof(date), "%02d:%02d %02d/%02d/%d", date[3], date[4], date[0], date[1], date[2]);
	return date;
}

ShowAccountStats(playerid, target)
{
	new networkstats[401], ip[22];

	GetPlayerNetworkStats(target, networkstats, sizeof(networkstats));
	NetStats_GetIpPort(target, ip, sizeof(ip));

	Dialog_Show(playerid, DIALOG_ACCSTATS, DIALOG_STYLE_MSGBOX,
	"Zombieland Role Play",
	"{CC9966}Hesap bilgileri\n\n{FFFFFF}Kullan�c� ad�: %s\nKullan�lan karakter slotu: %d/%d\n\n{CC9966}Network bilgileri\n\n{FFFFFF}%sIP ve port: %s\n\n{CC9966}Bu bilgiler %s tarihinde listelenmi�tir.",
	"geri", "",
	Account[target][Account_Name],
	Account[target][Account_ActiveSlots],
	Account[target][Account_AvailableSlots]+Account[target][Account_ActiveSlots],
	networkstats,
	ip,
	Date()
	);
	return 1;
}

ListAccountCharacters(playerid)
{
	new query[70];
	mysql_format(SQL_Handle, query, sizeof(query), "SELECT * FROM `characters` WHERE `char_accountsql` = '%d'", Account[playerid][Account_SQL]);
	mysql_tquery(SQL_Handle, query, "OnPlayerListCharacters", "d", playerid);
	return 1;
}

CheckPlayerCharacters(playerid, name[], bool:check = false)
{
	new Cache:query_characters, query[140];

	mysql_format(SQL_Handle, query, sizeof query, "SELECT * FROM `characters` WHERE `char_name` = '%e' AND `char_accountsql` = '%d' LIMIT 1", name, Account[playerid][Account_SQL]);

	query_characters = mysql_query(SQL_Handle, query);

	new rows = cache_num_rows();

	if(rows) check = true;
	else if(!rows) check = false;
	
	cache_delete(query_characters);
	return check;
}

ShowAccountMainMenu(playerid)
	return Dialog_Show(playerid, DIALOG_MAIN, DIALOG_STYLE_LIST, "��lem se�in:", "> Hesap bilgimi g�r�nt�le.\n> Karakterlerimi listele.\n> Yeni karakter olu�tur.", "se�", "��k��");

CreateCharacter(playerid)
{
	if(Account[playerid][Account_AvailableSlots] == 0)
	{
	    SendErrorMessage(playerid, "Karakter olu�turma hakk�n�z kalmam��, (/donate) komutuyla elde edebilirsiniz.");
	    return ShowAccountMainMenu(playerid);
	}

	Dialog_Show(playerid, DIALOG_CHARACTERS_CREATE, DIALOG_STYLE_INPUT, "Zombieland Role Play", "Olu�turmak istedi�iniz karakterin ad�n� girin.\nBu isim en fazla 24 karakter i�erebilir ve Role Play ad format�na uygun olmal�d�r. {CC9966}(�sim_Soyisim)", "�leri", "Vazge�");
	return 1;
}

IsRoleplayName(player_name[])
{
    for(new i = 0, j = strlen(player_name); i < j; i++)
    {
        switch(player_name[i])
        {
            case '0'..'9':
                return ROLEPLAY_NAME_CONTAINS_NUMBERS;
        }
    }

    if(65 <= player_name[0] <= 90)
    {
        new underscore_1 = strfind(player_name, "_");
        if(underscore_1 >= 3)
        {
            if(65 <= player_name[underscore_1 + 1] <= 90)
            {
                if(strfind(player_name, "_", false, (underscore_1 + 1)) == -1)
                {
                    if(((strlen(player_name) - underscore_1) - 1) >= 3)
                        return ROLEPLAY_NAME_TRUE;
                }
            }else{
                if(((strlen(player_name) - underscore_1) - 1) <= 2)
                    return ROLEPLAY_NAME_FALSE;
                else
                    return ROLEPLAY_NAME_UNCAPPED;
            }
        }
    }else{
        if(strfind(player_name, "_") <= 3)
            return ROLEPLAY_NAME_FALSE;
        else
            return ROLEPLAY_NAME_UNCAPPED;
    }
    return ROLEPLAY_NAME_FALSE;
}

UpdateCharacter(playerid)
{
	new weaponid = 0, ammo = 0;
	Character[playerid][Character_Weapons][0] = Character[playerid][Character_Weapons][1] = Character[playerid][Character_Weapons][2] = Character[playerid][Character_Weapons][3] = Character[playerid][Character_Weapons][4] = 0;
	Character[playerid][Character_Ammo][0] = Character[playerid][Character_Ammo][1] = Character[playerid][Character_Ammo][2] = Character[playerid][Character_Ammo][3] = Character[playerid][Character_Ammo][4] = 0;
	for(new i; i < 13; i++)
	{
		GetPlayerWeaponData(playerid, i, weaponid, ammo);
		if(weaponid > 0)
		{
			for(new j = 0; j < 5; j++)
			{
				if(Character[playerid][Character_Weapons][j] <= 0)
				{
					Character[playerid][Character_Weapons][j] = weaponid;
					Character[playerid][Character_Ammo][j] = ammo;
					break;
				}
			}
		}
	}
	if(!Account[playerid][Account_IsLogged]) return 1;
	GetPlayerPos(playerid, Character[playerid][Character_PosX], Character[playerid][Character_PosY], Character[playerid][Character_PosZ]);
	GetPlayerFacingAngle(playerid, Character[playerid][Character_PosA]);
	new query[650];
	mysql_format(SQL_Handle, query, sizeof(query),
	"UPDATE `characters` SET `char_posx` = '%.4f', `char_posy` = '%.4f', `char_posz` = '%.4f', `char_posa` = '%.4f', `char_vw` = '%d', `char_int` = '%d', `char_configured` = '%d', `char_gender` = '%d', `char_job` = '%d', `talent_mechanic` = '%d', `talent_fishing` = '%d', `talent_aim` = '%d', `talent_crafting` = '%d', `talent_firstaid` = '%d', `talent_cooking` = '%d', `char_age` = '%d',\
	`char_backpack` = '%d', `char_carry` = '%f', `char_level` = '%d', `char_exp` = '%d', `char_paydaytime` = '%d', `char_talentpoint` = '%d', `char_weapons` = '%d|%d|%d|%d|%d', `char_ammo` = '%d|%d|%d|%d|%d' WHERE `char_sql` = '%d'",
		Character[playerid][Character_PosX],
		Character[playerid][Character_PosY],
		Character[playerid][Character_PosZ],
		Character[playerid][Character_PosA],
		GetPlayerVirtualWorld(playerid),
		GetPlayerInterior(playerid),
		Character[playerid][Character_Configured],
		Character[playerid][Character_Gender],
		Character[playerid][Character_Job],
		Character[playerid][Talent_Mechanic],
		Character[playerid][Talent_Fishing],
		Character[playerid][Talent_Aim],
		Character[playerid][Talent_Crafting],
		Character[playerid][Talent_FirstAid],
		Character[playerid][Talent_Cooking],
		Character[playerid][Character_Age],
		Character[playerid][Character_Backpack],
		Character[playerid][Character_Carry],
		Character[playerid][Character_Level],
		Character[playerid][Character_EXP],
		Character[playerid][Character_PaydayTime],
		Character[playerid][Character_TalentPoint],
		Character[playerid][Character_Weapons][0],
		Character[playerid][Character_Weapons][1],
		Character[playerid][Character_Weapons][2],
		Character[playerid][Character_Weapons][3],
		Character[playerid][Character_Weapons][4],
		Character[playerid][Character_Ammo][0],
		Character[playerid][Character_Ammo][1],
		Character[playerid][Character_Ammo][2],
		Character[playerid][Character_Ammo][3],
		Character[playerid][Character_Ammo][4],
		Character[playerid][Character_SQL]
	);
	mysql_tquery(SQL_Handle, query);
	return 1;
}

Inventory_Save(playerid, id)
{
	new query[124];
	format(query, sizeof(query), "UPDATE `inventory` SET `inv_item` = '%d', `inv_amount` = '%d' WHERE `inv_sql` = '%d' AND `inv_id` = '%d'", Inventory[playerid][id][Inventory_Item], Inventory[playerid][id][Inventory_Amount], Character[playerid][Character_SQL], Inventory[playerid][id][Inventory_ID]);
	mysql_tquery(SQL_Handle, query); 
	return 1;
}

ResetCharacterStats(playerid)
{
	Character[playerid][Character_SQL] = Character[playerid][Character_AccountSQL] = Character[playerid][Character_Area] = -1;
	Character[playerid][Character_Name][0] = EOS;
	Character[playerid][Character_Configured] = Character[playerid][Character_Gender] = Character[playerid][Character_Job] = Character[playerid][Character_Age] = Character[playerid][Talent_Mechanic] = Character[playerid][Talent_Fishing] = Character[playerid][Talent_Aim] = Character[playerid][Talent_Crafting] = Character[playerid][Talent_FirstAid] = 0;
	Character[playerid][Character_PosX] = Character[playerid][Character_PosY] = Character[playerid][Character_PosZ] = Character[playerid][Character_PosA] = Character[playerid][Character_Carry] = 0.0;
	Character[playerid][Talent_Cooking] = Character[playerid][Character_Backpack] = Character[playerid][Character_LastAirdrop] = Character[playerid][Character_EXP] = Character[playerid][Character_PaydayTime] = Character[playerid][Character_TalentPoint] = Character[playerid][Character_AreaType] = Character[playerid][Character_HitCount] = Character[playerid][Character_Interior] = Character[playerid][Character_VirtualWorld] = 0;
	Character[playerid][Character_Level] = 1;
	Character[playerid][Character_StaffDuty] = false;
	Character[playerid][Character_LastPm] = INVALID_PLAYER_ID;
	for(new i; i < 5; i++) Character[playerid][Character_Weapons][i] = Character[playerid][Character_Ammo][i] = 0;
	
	for(new i; i < MAX_INVENTORY_SLOT; i++) {
		Inventory[playerid][i][Inventory_Exists] = false;
		Inventory[playerid][i][Inventory_ID] = 0;
		Inventory[playerid][i][Inventory_Item] = -1;
		Inventory[playerid][i][Inventory_Amount] = 0;
	}

	KillTimer(Character[playerid][Character_FishingTimer]);
	Character[playerid][Character_FishingTimer] = -1;
	
	KillTimer(Character[playerid][Character_BoxTimer]);
	Character[playerid][Character_BoxTimer] = -1;
	
	KillTimer(Character[playerid][Character_TentTimer]);
	Character[playerid][Character_TentTimer] = -1;
	
	if(GetPVarInt(playerid, "TreeID") != -1)
	{
		TreeData[GetPVarInt(playerid, "TreeID")][treeStatus] = 0;
		KillTimer(GetPVarInt(playerid, "TreeTimer"));
		SetPVarInt(playerid, "TreeID", -1);
	}

	if(Character[playerid][Character_Picklock] != -1)
	{
		if(IsValidDynamicArea(Character[playerid][Character_Picklock]))
		{
			new data[enum_safe];
			Streamer_GetArrayData(STREAMER_TYPE_AREA, Character[playerid][Character_Picklock], E_STREAMER_EXTRA_ID, data);
			data[picklock] = false;
			Streamer_SetArrayData(STREAMER_TYPE_AREA, Character[playerid][Character_Picklock], E_STREAMER_EXTRA_ID, data);
		}

		Character[playerid][Character_Picklock] = -1;
		Character[playerid][Character_PicklockCode][0] = EOS;
		Character[playerid][Character_PicklockCodeCount] = 0;
		Character[playerid][Character_PicklockCodeTime] = 0;
		KillTimer(Character[playerid][Character_PicklockTimer]);
		Character[playerid][Character_PicklockTimer] = -1;
	}

	if(Character[playerid][Character_CraftingTable] != -1)
	{
		new data[enum_tables];

	    Streamer_GetArrayData(STREAMER_TYPE_AREA, Character[playerid][Character_CraftingTable], E_STREAMER_EXTRA_ID, data);

	    data[tableUsing] = 0;
	    if(IsValidDynamic3DTextLabel(data[tableText])) DestroyDynamic3DTextLabel(data[tableText]);

	    Streamer_SetArrayData(STREAMER_TYPE_AREA, Character[playerid][Character_CraftingTable], E_STREAMER_EXTRA_ID, data);

	    Character[playerid][Character_CraftingTable] = -1;
	}

	Character[playerid][Character_EditingTable] = -1;
	Character[playerid][Character_EditingTent] = -1;

	KillTimer(Character[playerid][Character_CraftTimer]);
	Character[playerid][Character_CraftTimer] = -1;
	
	KillTimer(Character[playerid][Character_LootTimer]);
	Character[playerid][Character_LootTimer] = -1;
	
	GangZoneHideForPlayer(playerid, Server[RedZone]);
	GangZoneShowForPlayer(playerid, Server[RedZone], 0xff3333FF);

   	for(new i; i < 17; i++)
    {
        WeaponSettings[playerid][i][Position][0] = -0.116;
        WeaponSettings[playerid][i][Position][1] = 0.189;
        WeaponSettings[playerid][i][Position][2] = 0.088;
        WeaponSettings[playerid][i][Position][3] = 0.0;
        WeaponSettings[playerid][i][Position][4] = 44.5;
        WeaponSettings[playerid][i][Position][5] = 0.0;
        WeaponSettings[playerid][i][Bone] = 1;
        WeaponSettings[playerid][i][Hidden] = false;
    }
    
    WeaponTick[playerid] = 0;
    EditingWeapon[playerid] = 0;
    
    Character[playerid][Character_RadioSlot] = -1;
    
    KillTimer(Character[playerid][Character_FillTimer]);
    Character[playerid][Character_FillTimer] = -1;
    
    Character[playerid][Box_Show] = false;
	return 1;
}

LoadCharacterData(playerid, name[])
{
	strcpy(Character[playerid][Character_Name], name, MAX_PLAYER_NAME);

	new query[103];
	mysql_format(SQL_Handle, query, sizeof query, "SELECT * FROM `characters` WHERE `char_name` = '%e' AND `char_accountsql` = '%d' LIMIT 1", name, Account[playerid][Account_SQL]);
	mysql_tquery(SQL_Handle, query, "OnCharacterDataLoaded", "d", playerid);
	return 1;
}

SpawnCharacter(playerid, bool:firstspawn = false)
{
	if(firstspawn)
	{
		new welcome[48];
		format(welcome, sizeof(welcome), "~w~Hos geldiniz,~n~ ~y~%s~w~.", Character[playerid][Character_Name]);
		GameTextForPlayer(playerid, welcome, 3000, 1);
		SetPlayerName(playerid, Character[playerid][Character_Name]);
		SetPlayerScore(playerid, Character[playerid][Character_Level]);
		Account[playerid][Account_IsPlaying] = true;

		ClearChat(playerid, 20);
	}

	TogglePlayerSpectating(playerid, false);
    SetSpawnInfo(playerid, NO_TEAM, 108, Character[playerid][Character_PosX], Character[playerid][Character_PosY], Character[playerid][Character_PosZ], Character[playerid][Character_PosA], 0, 0, 0, 0, 0, 0);
	SpawnPlayer(playerid);
	return 1;
}

GetGender(playerid)
{
	new gender[6];
	switch(Character[playerid][Character_Gender])
	{
		case GENDER_MALE: gender = "Erkek";
		case GENDER_FEMALE: gender = "Kad�n";
		default: gender = "NULL";
	}
	return gender;
}

GetJob(playerid)
{
	new job[10];
	switch(Character[playerid][Character_Job])
	{
	    case JOB_SOLDIER: job = "Asker";
	    case JOB_POLICE: job = "Polis";
	    case JOB_MECHANIC: job = "Mekanik";
	    case JOB_DOCTOR: job = "Doktor";
	    case JOB_NURSE: job = "Hem�ire";
	    case JOB_CHEF: job = "A���";
	    case JOB_ARTISAN: job = "Zanaatkar";
	    case JOB_ENGINEER: job = "M�hendis";
	    default: job = "NULL";
	}
	return job;
}

SendClientMessageEx(playerid, color, const text[], {Float, _}:...)
{
	static
	    args,
	    str[144];

	if ((args = numargs()) == 3)
	{
	    SendClientMessage(playerid, color, text);
	}
	else
	{
		while (--args >= 3)
		{
			#emit LCTRL 5
			#emit LOAD.alt args
			#emit SHL.C.alt 2
			#emit ADD.C 12
			#emit ADD
			#emit LOAD.I
			#emit PUSH.pri
		}
		#emit PUSH.S text
		#emit PUSH.C 144
		#emit PUSH.C str
		#emit PUSH.S 8
		#emit SYSREQ.C format
		#emit LCTRL 5
		#emit SCTRL 4

		SendClientMessage(playerid, color, str);

		#emit RETN
	}
	return 1;
}

stock SendClientMessageToAllEx(color, const text[], {Float, _}:...)
{
	static
	    args,
	    str[144];

	if ((args = numargs()) == 2)
	{
	    SendClientMessageToAll(color, text);
	}
	else
	{
		while (--args >= 2)
		{
			#emit LCTRL 5
			#emit LOAD.alt args
			#emit SHL.C.alt 2
			#emit ADD.C 12
			#emit ADD
			#emit LOAD.I
			#emit PUSH.pri
		}
		#emit PUSH.S text
		#emit PUSH.C 144
		#emit PUSH.C str
		#emit LOAD.S.pri 8
		#emit ADD.C 4
		#emit PUSH.pri
		#emit SYSREQ.C format
		#emit LCTRL 5
		#emit SCTRL 4

		SendClientMessageToAll(color, str);

		#emit RETN
	}
	return 1;
}

GetAdminLevel(playerid)
{
	new admin[15];
	switch(Account[playerid][Account_Staff])
	{
		case PLAYER: admin = "Oyuncu";
		case TESTER1: admin = "Tester I";
		case TESTER2: admin = "Tester II";
		case TESTER3: admin = "Tester III";
		case GADMIN1: admin = "Game Admin I";
		case GADMIN2: admin = "Game Admin II";
		case GADMIN3: admin = "Game Admin III";
		case DEVELOPER: admin = "Developer";
		case LEADADMIN: admin = "Lead Admin";
		case FOUNDER: admin = "Founder";
		default: admin = "NULL";
	}
	return admin;
}

IsPlayerNearPlayer(playerid, target, Float:distance)
{
	GetPlayerPos(playerid, Character[playerid][Character_PosX], Character[playerid][Character_PosY], Character[playerid][Character_PosZ]);

    if(IsPlayerInRangeOfPoint(target, distance, Character[playerid][Character_PosX], Character[playerid][Character_PosY], Character[playerid][Character_PosZ]))
    {
        if(GetPlayerInterior(playerid) == GetPlayerInterior(target) && GetPlayerVirtualWorld(playerid) == GetPlayerVirtualWorld(target))
            return 1;
	}
	return 0;
}

SendNearbyMessage(playerid, Float:radius, color, const str[], {Float,_}:...)
{
	static
	    args,
	    start,
	    end,
	    string[144]
	;
	#emit LOAD.S.pri 8
	#emit STOR.pri args

	if (args > 16)
	{
		#emit ADDR.pri str
		#emit STOR.pri start

	    for (end = start + (args - 16); end > start; end -= 4)
		{
	        #emit LREF.pri end
	        #emit PUSH.pri
		}
		#emit PUSH.S str
		#emit PUSH.C 144
		#emit PUSH.C string

		#emit LOAD.S.pri 8
		#emit CONST.alt 4
		#emit SUB
		#emit PUSH.pri

		#emit SYSREQ.C format
		#emit LCTRL 5
		#emit SCTRL 4

        foreach (new i : Player)
		{
			if(IsPlayerNearPlayer(i, playerid, radius))
				SendClientMessage(i, color, string);
		}
		return 1;
	}

 	foreach(new i : Player)
		if(IsPlayerNearPlayer(i, playerid, radius)) SendClientMessage(i, color, str);
	return 1;
}

strreplace(string[], find, replace)
{
    for(new i = 0; string[i]; i++)
    {
        if(string[i] == find) string[i] = replace;
    }
    return 1;
}

ReturnName(playerid)
{
	new name[24];
	
	strcpy(name, Character[playerid][Character_Name], MAX_PLAYER_NAME);
	strreplace(name, '_', ' ');
    return name;
}

ClearChat(playerid, integer)
{
	for(new i = 0; i < integer; i++)
	    SendClientMessage(playerid, COLOR_WHITE, "");
	return 1;
}

SendOOCMessage(playerid, Float:distance, message[])
{
	foreach(new i: Player)
	{
	    if(Account[i][Account_IsPlaying])
	    {
			if(IsPlayerNearPlayer(playerid, i, distance))
			{
				if(Account[i][Settings_OOC] == 1)
					SendClientMessageEx(i, COLOR_WHITE, "(( %s: %s ))", ReturnName(playerid), message);
			}
		}
	}
	return 1;
}

PlayerPlaySoundEx(playerid, sound)
{
	GetPlayerPos(playerid, Character[playerid][Character_PosX], Character[playerid][Character_PosY], Character[playerid][Character_PosZ]);
	
	PlayerPlaySound(playerid, sound, Character[playerid][Character_PosX], Character[playerid][Character_PosY], Character[playerid][Character_PosZ]);
	return 1;
}

LoadDynamicSystems()
{
    mysql_tquery(SQL_Handle, "SELECT * FROM `dropped_items`", "DroppedItems_Load");
    mysql_tquery(SQL_Handle, "SELECT * FROM `tables`", "Tables_Load");
	mysql_tquery(SQL_Handle, "SELECT * FROM `safes`", "Safes_Load");
	mysql_tquery(SQL_Handle, "SELECT * FROM `lootplaces`", "LootPlaces_Load");
	mysql_tquery(SQL_Handle, "SELECT * FROM `tents`", "Tents_Load");
	return 1;
}

DroppedItem_Delete(id)
{
	new data[enum_droppeditems], found = false;
	for(new i, maxval = Streamer_GetUpperBound(STREAMER_TYPE_RACE_CP); i <= maxval; ++i)
	{
		if(!IsValidDynamicRaceCP(i)) continue;
		Streamer_GetArrayData(STREAMER_TYPE_RACE_CP, i, E_STREAMER_EXTRA_ID, data);
		if(data[DroppedItem_ID] == id)
		{
			DestroyDynamicObject(data[DroppedItem_Object]);
			DestroyDynamic3DTextLabel(data[DroppedItem_Text]);
			DestroyDynamicRaceCP(i);
			data[DroppedItem_ID] = 0;
			data[DroppedItem_Item] = 0;
			data[DroppedItem_Amount] = 0;
			found = true;
			break;
		}
		
	}
	if(found)
	{
		new query[80];
		format(query, sizeof(query), "DELETE FROM dropped_items WHERE `ditem_id` = '%d'", id);
		mysql_tquery(SQL_Handle, query);
		return 1;
	}
	return 0;
}

DroppedItems_List(playerid)
{
	new Float:x, Float:y, Float:z, Float:objx, Float:objy, Float:objz, string[300] = "ID\tE�ya\tMiktar\n", count;
	GetPlayerPos(playerid, x, y, z);
	
	if(Character[playerid][Character_Area] != -1 && Character[playerid][Character_AreaType] == 1)
	{
		new data[enum_campfire], area = Character[playerid][Character_Area];
		Streamer_GetArrayData(STREAMER_TYPE_AREA, area, E_STREAMER_EXTRA_ID, data);
		if(data[fireExists] == true && data[fireTimer] > 0 && data[CookedFish] > 0)
		{
			if(gettime() - data[CookedFish] > 30)
			{
				data[CookedFish] = 0;
				data[CookingTimer] = -1;
				DestroyDynamic3DTextLabel(data[CookingText]);
				SendErrorMessage(playerid, "Bal��� ge� ald���n�z i�in bal�k yanm��.");
				GiveRandomTalentPoint(playerid, 5, 1);
				Streamer_SetArrayData(STREAMER_TYPE_AREA, area, E_STREAMER_EXTRA_ID, data);
			}
			else
			{
				data[CookedFish] = 0;
				data[CookingTimer] = -1;
				DestroyDynamic3DTextLabel(data[CookingText]);
				Inventory_AddItem(playerid, 4, 1);
				SendServerMessage(playerid, "Pi�mi� bal�k envanterinize eklendi.");
				GiveRandomTalentPoint(playerid, 5, 1);
				Streamer_SetArrayData(STREAMER_TYPE_AREA, area, E_STREAMER_EXTRA_ID, data);
			}
			return 1;
		}
	}
	new data[enum_droppeditems];
	for(new i, maxval = Streamer_GetUpperBound(STREAMER_TYPE_RACE_CP); i <= maxval; ++i)
	{
		if(!IsValidDynamicRaceCP(i)) continue;
		Streamer_GetArrayData(STREAMER_TYPE_RACE_CP, i, E_STREAMER_EXTRA_ID, data);
		if(data[DroppedItem_ID] > 0)
		{
			if(!data[DroppedItem_SpawnTime])
			{
				GetDynamicObjectPos(data[DroppedItem_Object], objx, objy, objz);
				if(IsPlayerInRangeOfPoint(playerid, 3.0, objx, objy, objz))
				{
					format(string, sizeof(string), "%s{FFFFFF}%d\t%s\t%d\n", string, i, Items[data[DroppedItem_Item]][Item_Name], data[DroppedItem_Amount]);
					count++;
				}
			}
		}
	}
	if(count)
	{
		Dialog_Show(playerid, DIALOG_DROPPEDITEMS, DIALOG_STYLE_TABLIST_HEADERS, "E�yalar", string, "Al", "");
	}
	return 1;
}

DroppedItem_Create(playerid, item, amount, owned = 0)
{	
	new Float:x, Float:y, Float:z, interior = GetPlayerInterior(playerid), world = GetPlayerVirtualWorld(playerid), cpid;
	GetPlayerPos(playerid, x, y, z);
	new query[500];
	format(query, sizeof(query), "INSERT INTO `dropped_items` (`ditem_x`, `ditem_y`, `ditem_z`, `ditem_int`, `ditem_vw`, `ditem_item`, `ditem_amount`) VALUES ('%.4f', '%.4f', '%.4f', '%d', '%d', '%d', '%d')",
	x, y, z, interior, world, item, amount);
	new Cache:add = mysql_query(SQL_Handle, query), data[enum_droppeditems];
	data[DroppedItem_Object] = CreateDynamicObject(Items[item][Item_ObjectID], x, y, z - 1, 0.0, 0.0, 0.0, interior, world);
	data[DroppedItem_ID] = cache_insert_id();
	data[DroppedItem_PosX] = x;
	data[DroppedItem_PosY] = y;
	data[DroppedItem_PosZ] = x;
	data[DroppedItem_Interior] = interior;
	data[DroppedItem_VirtualWorld] = world;
	data[DroppedItem_Item] = item;
	data[DroppedItem_Amount] = amount;
	data[DroppedItem_Owned] = owned;
	data[DroppedItem_SpawnTime] = 0;
	format(query, sizeof(query), "(#%d) %s (%d adet)", data[DroppedItem_ID], Items[item][Item_Name], amount);
	data[DroppedItem_Text] = CreateDynamic3DTextLabel(query, COLOR_CLIENT, x, y, z - 1, DEFAULT_DISTANCE, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 0, interior, world);
	cpid = CreateDynamicRaceCP(2, x, y, z, 0.0, 0.0, 0.0, 1.0, 800, 0);  
	Streamer_SetArrayData(STREAMER_TYPE_RACE_CP, cpid, E_STREAMER_EXTRA_ID, data);
	cache_delete(add);
	return 1;
}

IsCharacterCanGetThisItem(playerid, item, amount)
{
	if(Items[item][Item_Weight] * float(amount) + Character[playerid][Character_Carry] > float(BackpackLimits(Character[playerid][Character_Backpack]))) return 0;
	return 1;
}

BackpackLimits(type)
{
	new limit = 0;

	switch(type)
	{
	    case 0: limit = 10;
	    case 1: limit = 25;
	    case 2: limit = 50;
	    case 3: limit = 75;
	}
	return limit;
}

Inventory_GetItemSlot(playerid, itemid)
{
	for(new i = 0; i < MAX_INVENTORY_SLOT; i++)
	    if(Inventory[playerid][i][Inventory_Exists] && Inventory[playerid][i][Inventory_Item] == itemid) return i;
	return -1;
}

Inventory_GetFreeID(playerid)
{
	for (new i = 0; i < MAX_INVENTORY_SLOT; i ++)
	{
	    if (!Inventory[playerid][i][Inventory_Exists])
	        return i;
	}
	return -1;
}

Inventory_Remove(playerid, item, amount = 1)
{
	new
		itemid = Inventory_GetItemSlot(playerid, item),
		string[128];

	if (itemid != -1)
	{
	    if (amount != -1 && Inventory[playerid][itemid][Inventory_Amount] > 0)
	    {
			Character[playerid][Character_Carry] -= Items[item][Item_Weight] * amount;
	        Inventory[playerid][itemid][Inventory_Amount] -= amount;
		}
		if(amount == -1 || Inventory[playerid][itemid][Inventory_Amount] < 1)
		{
			Character[playerid][Character_Carry] -= Items[item][Item_Weight] * Inventory[playerid][itemid][Inventory_Amount];
		    Inventory[playerid][itemid][Inventory_Exists] = false;
		    Inventory[playerid][itemid][Inventory_Item] = 0;
		    Inventory[playerid][itemid][Inventory_Amount] = 0;

		    format(string, sizeof(string), "DELETE FROM `inventory` WHERE `inv_sql` = '%d' AND `inv_id` = '%d'", Character[playerid][Character_SQL], Inventory[playerid][itemid][Inventory_ID]);
	        mysql_tquery(SQL_Handle, string);
		}
		if(amount != -1 && Inventory[playerid][itemid][Inventory_Amount] > 0)
		{
			Inventory_Save(playerid, itemid);
		}
		return 1;
	}

	if(item == 40 && Inventory_GetItemAmount(playerid, 40) < 1) // map item
		GangZoneShowForPlayer(playerid, BlockMap, 0x000000FF);
	return 0;
}

Inventory_Clear(playerid)
{
	new
	    string[64];

	for (new i = 0; i < MAX_INVENTORY_SLOT; i ++)
	{
	    if(Inventory[playerid][i][Inventory_Exists])
	    {
	        Inventory[playerid][i][Inventory_Exists] = false;
	        Inventory[playerid][i][Inventory_Item] = 0;
	        Inventory[playerid][i][Inventory_Amount] = 0;
		}
	}
	Character[playerid][Character_Carry] = 0.0;
	format(string, sizeof(string), "DELETE FROM `inventory` WHERE `inv_sql` = '%d'", Character[playerid][Character_SQL]);
	mysql_tquery(SQL_Handle, string);

	GangZoneShowForPlayer(playerid, BlockMap, 0x000000FF);
	return 1;
}

Inventory_AddItem(playerid, item, amount)
{
	if(item == 40 && Inventory_GetItemAmount(playerid, 40) < 1) // map item
		GangZoneHideForPlayer(playerid, BlockMap);

	new
		itemid = Inventory_GetItemSlot(playerid, item),
		string[128];

	if (itemid == -1)
	{
	    itemid = Inventory_GetFreeID(playerid);

	    if (itemid != -1)
	    {
	        Inventory[playerid][itemid][Inventory_Exists] = true;
	        Inventory[playerid][itemid][Inventory_Item] = item;
	        Inventory[playerid][itemid][Inventory_Amount] = amount;
			Character[playerid][Character_Carry] += Items[item][Item_Weight] * amount;
			format(string, sizeof(string), "INSERT INTO `inventory` (`inv_sql`, `inv_item`, `inv_amount`) VALUES('%d', '%d', '%d')", Character[playerid][Character_SQL], item, amount);
			mysql_tquery(SQL_Handle, string, "OnInventoryAdd", "dd", playerid, itemid);
	        return itemid;
		}
		return -1;
	}
	else
	{
	    Inventory[playerid][itemid][Inventory_Amount] += amount;
		Character[playerid][Character_Carry] += Items[item][Item_Weight] * amount;
		Inventory_Save(playerid, itemid);
	}
	return itemid;
}

Airdrop_List(playerid)
{
	new Float:x, Float:y, Float:z, string[200], item_count;
	GetPlayerPos(playerid, x, y, z);
	for(new i; i < MAX_AIRDROP; i++)
	{
		if(Airdrop[i][Airdrop_Exists])
		{
			if(!IsDynamicObjectMoving(Airdrop[i][Airdrop_Object]) && IsPlayerInRangeOfPoint(playerid, 3.0, Airdrop[i][AirdropX], Airdrop[i][AirdropY], Airdrop[i][AirdropZ]))
			{
				for(new item; item < 5; item++)
				{
					if(Airdrop[i][Airdrop_Items][item] != -1) format(string, sizeof(string), "%s{FFFFFF}%s\n", string, Items[Airdrop[i][Airdrop_Items][item]][Item_Name]), item_count++;
					else strcat(string, "{AFAFAF}Bo�\n");
				}
				if(!item_count) return SendErrorMessage(playerid, "Airdrop'ta e�ya kalmad�."), Airdrop_Delete(i);
				SetPVarInt(playerid, "AirdropID", i);
				Dialog_Show(playerid, DIALOG_AIRDROP, DIALOG_STYLE_LIST, "Airdrop", string, "al", "");
				break;
			}
		}
	}
	return 1;
}

Airdrop_Delete(id)
{
	Airdrop[id][Airdrop_Exists] = false;
	Airdrop[id][AirdropX] = Airdrop[id][AirdropY] = Airdrop[id][AirdropZ] = 0.0;
	DestroyDynamicObject(Airdrop[id][Airdrop_Object]);
	if(Airdrop[id][Airdrop_Timer] != -1) KillTimer(Airdrop[id][Airdrop_Timer]);
	Airdrop[id][Airdrop_Timer] = -1;
	for(new i; i < 5; i++) Airdrop[id][Airdrop_Items][i] = -1;
	return 1;
}

Inventory_List(playerid)
{
	if(Character[playerid][Character_CraftTimer] != -1) return SendErrorMessage(playerid, "E�ya �retirken envanterinizi a�amazs�n�z.");
	new string[MAX_INVENTORY_SLOT * 15] = "Slot\tE�ya\tMiktar\n", amount = 0, header[30];
	for(new i; i < MAX_INVENTORY_SLOT; i++)
	{
		if(Inventory[playerid][i][Inventory_Exists])
		{
			format(string, sizeof(string), "%s%d\t%s\t%d\n", string, i, Items[Inventory[playerid][i][Inventory_Item]][Item_Name], Inventory[playerid][i][Inventory_Amount]);
			amount++;
		}
	}
	if(!amount) return SendErrorMessage(playerid, "Envanterinizde e�ya yok.");
	format(header, sizeof(header), "Envanter: %.3f / %.3f", Character[playerid][Character_Carry], float(BackpackLimits(Character[playerid][Character_Backpack])));
	Dialog_Show(playerid, DIALOG_INVENTORY, DIALOG_STYLE_TABLIST_HEADERS, header, string, "Se�", "");
	return 1;
}

UseItem(playerid, id, bool:a = false)
{
	new item;
	
	if(!a) item = Inventory[playerid][id][Inventory_Item];
	else item = id;

	switch(item)
	{
	    case 0:
	    {
	        if(!CA_IsPlayerNearWater(playerid)) return SendErrorMessage(playerid, "�i�enizi suyla doldurmak i�in denize yak�n olmal�s�n�z.");

            ApplyAnimation(playerid, "BOMBER", "BOM_Plant", 4.0, 0, 0, 0, 0, 2000, 1);
	        pc_cmd_ame(playerid, "e�ilir ve elindeki �i�eye su doldurur.");
	        PlayerPlaySoundEx(playerid, 174);

	        Inventory_Remove(playerid, 0, 1);
	        Inventory_AddItem(playerid, 1, 1);
	    }
	    case 1:
	    {
			if(Character[playerid][Character_Tirst] >= 90) return SendErrorMessage(playerid, "Susuz de�ilsiniz.");
			
	    	pc_cmd_ame(playerid, "su �i�esinin kapa��n� a�ar ve i�meye ba�lar.");
	    	PlayerPlaySoundEx(playerid, 174);
	        
	        Inventory_Remove(playerid, 1, 1);
	        Inventory_AddItem(playerid, 0, 1);
	        
	        Character[playerid][Character_Tirst] = (Character[playerid][Character_Tirst] + 20 > 100) ? (100) : (Character[playerid][Character_Tirst] + 20);
	    }
	    case 2:
	    {
	        if(!IsCharacterCanGetThisItem(playerid, 3, 1)) return SendErrorMessage(playerid, "Envanteriniz dolu oldu�u i�in bal�k tutamazs�n�z.");
	        if(IsPlayerSwimming(playerid)) return SendErrorMessage(playerid, "Y�zerken bal�k tutamazs�n�z.");
	        if(!CA_IsPlayerNearWater(playerid)) return SendErrorMessage(playerid, "Bal�k tutmak i�in denize yak�n olmal�s�n�z.");
	        if(Inventory_GetItemAmount(playerid, 42) < 1) return SendErrorMessage(playerid, "Yeminiz yok.");

			if(Character[playerid][Character_FishingTimer] != -1)
			{
				KillTimer(Character[playerid][Character_FishingTimer]);
				Character[playerid][Character_FishingTimer] = -1;
				
			    SendServerMessage(playerid, "Bal�k tutma i�lemini iptal ettiniz.");
			    pc_cmd_ame(playerid, "oltas�n� kendine do�ru �eker.");
			    ClearAnimations(playerid);
			    TogglePlayerControllable(playerid, true);
			    DeleteInfoBox(playerid);
			    return 1;
			}

	        ClearAnimations(playerid);
	        SetPlayerArmedWeapon(playerid, 0);
	        TogglePlayerControllable(playerid, false);
			ApplyAnimation(playerid, "SAMP", "FishingIdle", 4.1, 0, 1, 1, 1, 0);
        	pc_cmd_ame(playerid, "oltas�n� denize do�ru sallar.");
        	
        	new seconds = RandomEx(5, 10);
        	
        	MessageBox(playerid, "Balik tutuluyor.", seconds);
        	Character[playerid][Character_FishingTimer] = SetTimerEx("OnCharacterEndFishing", seconds*1000, false, "i", playerid);
        	Inventory_Remove(playerid, 42, 1);
	    }
		case 3:
		{
			if(IsPlayerInAnyVehicle(playerid)) return SendErrorMessage(playerid, "Ara�ta bal�k pi�iremezsiniz.");
			new area = Character[playerid][Character_Area];
			if(area == -1 || Character[playerid][Character_AreaType] != 1) return SendErrorMessage(playerid, "�i� bal��� pi�irebilmek i�in kamp ate�ine yak�n olmal�s�n�z.");
			new data[enum_campfire];
			Streamer_GetArrayData(STREAMER_TYPE_AREA, area, E_STREAMER_EXTRA_ID, data);
			if(data[fireExists] == false) return SendErrorMessage(playerid, "�i� bal��� pi�irebilmek i�in kamp ate�ine yak�n olmal�s�n�z.");
			if(gettime() >= data[fireTimer] - 70) return SendErrorMessage(playerid, "Bu kamp ate�i s�nmek �zere, bal�k pi�iremezsiniz.");
			if(data[CookingFish] > 0 || data[CookedFish] > 0) return SendErrorMessage(playerid, "Zaten bal�k pi�iriliyor, l�tfen bitmesini bekleyin.");
			Inventory_Remove(playerid, 3, 1);
			switch(Character[playerid][Talent_Cooking])
			{
				case 0..10: data[CookingFish] = 60;
				case 11..20: data[CookingFish] = 50;
				case 21..30: data[CookingFish] = 40;
				case 31..40: data[CookingFish] = 35;
				case 41..50: data[CookingFish] = 30;
				case 51..60: data[CookingFish] = 25;
				case 61..70: data[CookingFish] = 20;
				case 71..80: data[CookingFish] = 15;
				case 81..90: data[CookingFish] = 10;
				case 91..100: data[CookingFish] = 5;
			}
			data[CookedFish] = 0;
			data[CookingText] = CreateDynamic3DTextLabel("* Bal�k pi�iyor...", 0x66a832FF, data[fireX], data[fireY], data[fireZ], 5.0, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 1, GetPlayerVirtualWorld(playerid), GetPlayerInterior(playerid));
			data[CookingTimer] = SetTimerEx("OnCookingEnd", data[CookingFish] * 1000, false, "i", area);
			Streamer_SetArrayData(STREAMER_TYPE_AREA, area, E_STREAMER_EXTRA_ID, data);
			pc_cmd_ame(playerid, "bal��� kamp ate�inin �st�ne do�ru b�rak�r ve pi�mesini bekler.");
			SendServerMessage(playerid, "Bal��� pi�mesi i�in kamp ate�ine b�rakt�n�z, pi�me s�resi yetene�inize g�re de�i�kenlik g�sterebilir.");
			SendServerMessage(playerid, "E�er bal�k pi�tikten sonra hemen almazsan�z bal�k yanar.");
		}
		case 4:
		{
			if(Character[playerid][Character_Hunger] >= 80) return SendErrorMessage(playerid, "A� de�ilsiniz.");
			Character[playerid][Character_Hunger] = (Character[playerid][Character_Hunger] + 40 > 100) ? (100) : (Character[playerid][Character_Hunger] + 40);
			ApplyAnimation(playerid, "FOOD", "EAT_Burger", 4.1, 0, 1, 1, 0, 0);
			pc_cmd_ame(playerid, "pi�mi� bal��� yemeye ba�lar.");
			Inventory_Remove(playerid, 4, 1);
		}
		case 5:
		{
			new Float:h;
			
			GetPlayerHealth(playerid, h);
			
			if(h >= 100) return SendErrorMessage(playerid, "Bandaja ihtiyac�n�z yok.");
			if(h <= 40) return SendErrorMessage(playerid, "A��r yaral�s�n�z ve kanaman�z var, ilkyard�m kiti kullanman�z gerekiyor.");
			SetPlayerHealth(playerid, (h + 40.0 > 100) ? (100.0) : (h + 40.0));
			pc_cmd_ame(playerid, "bandaj ile yaralar�n� sarar.");
			Inventory_Remove(playerid, 5, 1);
		}
		case 6:
		{
			new Float:h;
			GetPlayerHealth(playerid, h);
			if(h >= 100) return SendErrorMessage(playerid, "�lkyard�m kitine ihtiyac�n�z yok.");
			SetPlayerHealth(playerid, 100);
			pc_cmd_ame(playerid, "ilkyard�m kitini kullan�r.");
			Inventory_Remove(playerid, 6, 1);
		}
		case 7:
		{
			if(Character[playerid][Character_Hunger] >= 90) return SendErrorMessage(playerid, "A� de�ilsiniz.");
			Character[playerid][Character_Hunger] = (Character[playerid][Character_Hunger] + 20 > 100) ? (100) : (Character[playerid][Character_Hunger] + 20);
			ApplyAnimation(playerid, "FOOD", "EAT_Burger", 4.1, 0, 1, 1, 0, 0);
			pc_cmd_ame(playerid, "konservenin kapa��n� a�ar ve yemeye ba�lar.");
			Inventory_Remove(playerid, 7, 1);
		}
		case 8:
		{
			if(IsPlayerInAnyVehicle(playerid)) return SendErrorMessage(playerid, "Ara�ta i�aret fi�e�i kullanamazs�n�z.");
			if(GetPlayerInterior(playerid) > 0 || GetPlayerVirtualWorld(playerid) > 0) return SendErrorMessage(playerid, "�nterior i�erisinde i�aret fi�e�i kullanamazs�n�z.");
			if(gettime() - Character[playerid][Character_LastAirdrop] < 300) return SendErrorMessage(playerid, "Tekrar airdrop �a��rmak i�in 5 dakika beklemelisiniz.");

			for(new i; i < MAX_AIRDROP; i++)
			{
				if(!Airdrop[i][Airdrop_Exists])
				{
					Airdrop[i][Airdrop_Exists] = true;
					GetPlayerPos(playerid, Airdrop[i][AirdropX],  Airdrop[i][AirdropY], Airdrop[i][AirdropZ]);
					Airdrop[i][Airdrop_Items][0] = RandomAirdropItem();
					Airdrop[i][Airdrop_Items][1] = RandomAirdropItem();
					Airdrop[i][Airdrop_Items][2] = RandomAirdropItem();
					Airdrop[i][Airdrop_Items][3] = RandomAirdropItem();
					Airdrop[i][Airdrop_Items][4] = RandomAirdropItem();
					Airdrop[i][Airdrop_Object] = CreateDynamicObject(18849,  Airdrop[i][AirdropX],  Airdrop[i][AirdropY], Airdrop[i][AirdropZ] + 300.0, 0.0, 0.0, 0.0);
					MoveDynamicObject(Airdrop[i][Airdrop_Object], Airdrop[i][AirdropX] + 1,  Airdrop[i][AirdropY] + 1, Airdrop[i][AirdropZ] + 6.5, 5.0);
					Airdrop[i][Airdrop_Timer] = SetTimerEx("AirdropDelete", 180000, false, "i", i);
					Character[playerid][Character_LastAirdrop] = gettime();
					Inventory_Remove(playerid, 8, 1);
					SendServerMessage(playerid, "Airdrop �a��rd�n�z, birazdan yan�n�za do�ru inecektir. (/airdrop)");
					return 1;
				}
			}
			SendErrorMessage(playerid, "�u anda airdrop �a��ramazs�n�z, l�tfen daha sonra tekrar deneyin.");
		}
		case 9..27:
		{
            new weaponID = GetWeaponIDFromModel(Items[item][Item_ObjectID]);
			new slot = GetWeaponSlot(weaponID), x;
			GetPlayerWeaponData(playerid, slot, x, x);
			
			if(x > 0) return SendErrorMessage(playerid, "�u anda bu silah� elinize alamazs�n�z.");
			
			new guntype = GetAmmoTypeFromWeapon(item);
			
			switch(guntype)
			{
				case 0: return SendErrorMessage(playerid, "Bir sorun olu�tu, e�yay� kullanmay� tekrar deneyin.");
				case 1:
				{
					GivePlayerWeapon(playerid, weaponID, 1);
					Inventory_Remove(playerid, item, 1);
				}
				case 2:
				{
					GivePlayerWeapon(playerid, weaponID, Inventory_GetItemAmount(playerid, item));
					Inventory_Remove(playerid, item, -1);
				}
				case 3:
				{
					new amount = Inventory_GetItemAmount(playerid, 30);
					if(amount < 1) return SendErrorMessage(playerid, "9mm merminiz yok.");

					GivePlayerWeapon(playerid, weaponID, amount);
					Inventory_Remove(playerid, item, 1);
					Inventory_Remove(playerid, 30, -1);
				}
				case 4:
				{
					new amount = Inventory_GetItemAmount(playerid, 31);
					if(amount < 1) return SendErrorMessage(playerid, "Gauge merminiz yok.");

					GivePlayerWeapon(playerid, weaponID, amount);
					Inventory_Remove(playerid, item, 1);
					Inventory_Remove(playerid, 31, -1);
				}
				case 5:
				{
					new amount = Inventory_GetItemAmount(playerid, 29);
					if(amount < 1) return SendErrorMessage(playerid, "7.62 merminiz yok.");

					GivePlayerWeapon(playerid, weaponID, amount);
					Inventory_Remove(playerid, item, 1);
					Inventory_Remove(playerid, 29, -1);
				}
				case 6:
				{
					new amount = Inventory_GetItemAmount(playerid, 28);
					if(amount < 1) return SendErrorMessage(playerid, "5.56 merminiz yok.");

					GivePlayerWeapon(playerid, weaponID, amount);
					Inventory_Remove(playerid, item, 1);
					Inventory_Remove(playerid, 28, -1);
				}
				
			}
		}
		case 28, 29, 30, 31, 33, 34, 35, 36, 37, 38, 40, 41, 42:
		{
		    pc_cmd_envanter(playerid);
		}
		case 32:
		{
			new Float:x, Float:y, Float:z, area, data[3];
			GetPlayerPos(playerid, x, y, z);
			data[0] = -5;
			data[1] = Character[playerid][Character_SQL];
			data[2] = CreateDynamicObject(19290, x, y, z - 1, 0.0, 0.0, 0.0, GetPlayerVirtualWorld(playerid), GetPlayerInterior(playerid));
			area = CreateDynamicSphere(x, y, z, 1.5, GetPlayerVirtualWorld(playerid), GetPlayerInterior(playerid));
			Streamer_SetArrayData(STREAMER_TYPE_AREA, area, E_STREAMER_EXTRA_ID, data);
			Inventory_Remove(playerid, 32, 1);
			SendServerMessage(playerid, "May�n yerle�tirdiniz.");
		}
		case 39:
		{
			if(IsPlayerInAnyVehicle(playerid)) return SendErrorMessage(playerid, "Ara�ta bunu yapamazs�n�z.");
			new area = Character[playerid][Character_Area];
			if(area == -1 || Character[playerid][Character_AreaType] != 2) return SendErrorMessage(playerid, "Herhangi bir kasaya yak�n de�ilsiniz.");
			new data[enum_safe];
			Streamer_GetArrayData(STREAMER_TYPE_AREA, area, E_STREAMER_EXTRA_ID, data);
			if(data[safeExists] == false) return SendErrorMessage(playerid, "Herhangi bir kasaya yak�n de�ilsiniz.");
			if(data[safeLock] == 2) return SendErrorMessage(playerid, "Bu kasada kilit var, maymuncuk i�e yaramaz.");
			if(data[picklock] == true) return SendErrorMessage(playerid, "Bu kasa zaten a��lmaya �al���l�yor.");
			if(isnull(data[safePassword])) return SendErrorMessage(playerid, "Bu kasa a��k.");
			data[picklock] = true;
			ApplyAnimation(playerid, "BOMBER", "BOM_Plant", 4.0, 1, 0, 0, 0, 0);
			Character[playerid][Character_Picklock] = area;
			strcpy(Character[playerid][Character_PicklockCode], GetRandomCode(), 5);
			Character[playerid][Character_PicklockCodeCount] = RandomEx(10, 20);
			Character[playerid][Character_PicklockCodeTime] = 7;
			SendServerMessage(playerid, "Kasa a�ma i�lemi ba�lad�, ekrana gelen kodlar� verilen s�re i�erisinde chate yaz�p g�ndermeniz gerekiyor.");
			Character[playerid][Character_PicklockTimer] = SetTimerEx("Picklock", 1000, true, "i", playerid);
			Inventory_Remove(playerid, 39, 1);
		}
		case 43:
		{
			if(Character[playerid][Character_Gender] == GENDER_MALE)
				pc_cmd_ame(playerid, "sol kolundaki saate bakar.");
			else
				pc_cmd_ame(playerid, "sa� kolundaki saate bakar.");

			GameTextForPlayer(playerid, Date(), 3 * 1000, 3);
		}
		case 44:
		{
		    pc_cmd_telsiz(playerid, "");
		}
		case 45:
		{
			if(Character[playerid][Character_FillTimer] != -1)
			{
				KillTimer(Character[playerid][Character_FillTimer]);
				Character[playerid][Character_FillTimer] = -1;

			    SendServerMessage(playerid, "Benzin doldurma i�lemini iptal ettiniz.");
			    ClearAnimations(playerid);
			    TogglePlayerControllable(playerid, true);
			    DeleteInfoBox(playerid);
			    return 1;
			}

		    if(IsPlayerInAnyVehicle(playerid)) return SendErrorMessage(playerid, "Ara� i�erisinde bo� bidona benzin dolduramazs�n.");

			new pump = Pump_Closest(playerid);
			
        	if(pump == -1) return SendErrorMessage(playerid, "Herhangi bir benzin pompas�na yak�n de�ilsin.");
        	
        	pc_cmd_ame(playerid, "bo� bidonun a�z�n� benzin pompas�na yerle�tirir.");
        	
        	TogglePlayerControllable(playerid, false);
        	ApplyAnimation(playerid, "BOMBER", "BOM_Plant", 4.0, 1, 0, 0, 0, 0);

			new seconds = RandomEx(5, 10);
			
            MessageBox(playerid, "Benzin dolduruluyor.", seconds);
			Character[playerid][Character_FillTimer] = SetTimerEx("FillingCan", seconds*1000, false, "i", playerid);
		}
		case 47:
		{
			if(IsPlayerInAnyVehicle(playerid)) return SendErrorMessage(playerid, "Ara�ta bunu yapamazs�n�z.");
			new area = Character[playerid][Character_Area];
			if(area == -1 || Character[playerid][Character_AreaType] != 2) return SendErrorMessage(playerid, "Herhangi bir kasaya yak�n de�ilsiniz.");
			new data[enum_safe];
			Streamer_GetArrayData(STREAMER_TYPE_AREA, area, E_STREAMER_EXTRA_ID, data);
			if(data[safeExists] == false) return SendErrorMessage(playerid, "Herhangi bir kasaya yak�n de�ilsiniz.");
			if(data[safeOwner] != Character[playerid][Character_SQL]) return SendErrorMessage(playerid, "Sadece sahibi oldu�unuz kasalara kilit takabilirsiniz.");
			if(data[safeLock]) return SendErrorMessage(playerid, "Bu kasan�n zaten kilidi var.");
			data[safeLock] = 1;
			Streamer_SetArrayData(STREAMER_TYPE_AREA, area, E_STREAMER_EXTRA_ID, data);
			Safe_Save(area);
			Inventory_Remove(playerid, 47, 1);
			SendServerMessage(playerid, "Kasaya kilit takt�n�z, (/kasa kilit) komutunu kullanarak kilidi aktif veya pasif hale getirebilirsiniz.");
			
		}
		case 49:
		{
		    if(Character[playerid][Character_TentTimer] != -1) return SendErrorMessage(playerid, "�u anda zaten �ad�r kuruyorsunuz.");

	        new tid = IsCharPlaceTent(playerid);
	        
	        if(tid != -1)
	        {
	            SendErrorMessage(playerid, "Zaten �ad�r kurmu�sunuz. Kurdu�unuz �ad�ra %0.2f metre uzakl�ktas�n�z.", GetPlayerDistanceFromPoint(playerid, Tent[tid][Tent_X], Tent[tid][Tent_Y], Tent[tid][Tent_Z]));
	            return 1;
	        }
	        
	        TogglePlayerControllable(playerid, 0);
	        ApplyAnimation(playerid, "BOMBER", "BOM_Plant", 4.1, 1, 0, 0, 1, 0, 1);
	        
	        new seconds = RandomEx(10, 15);

	        MessageBox(playerid, "~g~Cadir ~w~kuruluyor.", seconds);

	        Character[playerid][Character_TentTimer] = SetTimerEx("PlaceTent", seconds*1000, false, "i", playerid);
		}
		default: return 1;
	}
	return 1;
}

GetRandomCode()
{
	new string[5];
	static const Data[ ] = "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ";
	for(new i = 0; i < 5; i++)
	{
		string[i] = Data[random(sizeof(Data))];
	}
	return string;
}

GetAmmoTypeFromWeapon(itemid)
{
	new type = 0;

	switch(itemid)
	{
	    case 10..16: type = 1; /*Close fight weapons*/
	    case 17, 18: type = 2; /*Bombs*/
	    case 19, 20, 21, 23, 24: type = 3; /*9mm*/
	    case 22: type = 4; /*Gauge*/
	    case 25, 27: type = 5; /*7.62*/
	    case 26: type = 6; /*5.56*/
	}
	return type;
}

GetWeaponIDFromModel(model)
{
	new weaponid;
	switch(model)
	{
		case 331: weaponid = 1;
		case 333: weaponid = 2;
		case 334: weaponid = 3;
		case 335: weaponid = 4;
		case 336: weaponid = 5;
		case 337: weaponid = 6;
		case 338: weaponid = 7;
		case 339: weaponid = 8;
		case 341: weaponid = 9;
		case 342: weaponid = 16;
		case 343: weaponid = 17;
		case 344: weaponid = 18;
		case 346: weaponid = 22;
		case 347: weaponid = 23;
		case 348: weaponid = 24;
		case 349: weaponid = 25;
		case 350: weaponid = 26;
		case 351: weaponid = 27;
		case 352: weaponid = 28;
		case 353: weaponid = 29;
		case 355: weaponid = 30;
		case 356: weaponid = 31;
		case 372: weaponid = 32;
		case 357: weaponid = 33;
		case 358: weaponid = 34;	
	}
	return weaponid;
}

GetWeaponSlot(weaponid)
{
	new slot;

	switch(weaponid)
	{
		case 0,1: slot = 0;
		case 2 .. 9: slot = 1;
		case 10 .. 15: slot = 10;
		case 16 .. 18, 39: slot = 8;
		case 22 .. 24: slot =2;
		case 25 .. 27: slot = 3;
		case 28, 29, 32: slot = 4;
		case 30, 31: slot = 5;
		case 33, 34: slot = 6;
		case 35 .. 38: slot = 7;
		case 40: slot = 12;
		case 41 .. 43: slot = 9;
		case 44 .. 46: slot = 11;
	}
	return slot;
}

Talents(talent)
{
	new name[14] = "NULL";

	switch(talent)
	{
	    case 0: name = "Mekanik";
	    case 1: name = "Bal�k��l�k";
	    case 2: name = "Ni�anc�l�k";
	    case 3: name = "�retim";
	    case 4: name = "�lkyard�m";
	    case 5: name = "A���l�k";
	}
	return name;
}

GiveRandomTalentPoint(playerid, talent, point)
{
	new luck = random(100);

	if(random(DROP_TALENT) < luck)
	{
		switch(talent)
		{
			case 0: if(LIMIT_TALENT >= point + Character[playerid][Talent_Mechanic])
			    Character[playerid][Talent_Mechanic] += point;
			case 1: if(LIMIT_TALENT >= point + Character[playerid][Talent_Fishing])
			    Character[playerid][Talent_Fishing] += point;
			case 2:
			{
				if(LIMIT_TALENT >= point + Character[playerid][Talent_Aim])
				{
					Character[playerid][Talent_Aim] += point;
					for(new i; i < 11; i++) SetPlayerSkillLevel(playerid, i, Character[playerid][Talent_Aim] * 10);
				}
			}
			case 3: if(LIMIT_TALENT >= point + Character[playerid][Talent_Crafting])
			    Character[playerid][Talent_Crafting] += point;
			case 4: if(LIMIT_TALENT >= point + Character[playerid][Talent_FirstAid])
			    Character[playerid][Talent_FirstAid] += point;
			case 5: if(LIMIT_TALENT >= point + Character[playerid][Talent_Cooking])
			    Character[playerid][Talent_Cooking] += point;
			default: return 1;
		}
		SendServerMessage(playerid, "%s yetene�iniz %d puan geli�ti.", Talents(talent), point);
	}
	return 1;
}

RandomAirdropItem()
{
	new item[5] = {6, 15, 32, 26, 27}, rand = random(5);
	return item[rand];
}

RandomLootItem(type)
{
	new item[20] = {-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1},
		find_item = -1;

	switch(type)
	{
	    case 0: return 1;
	    case 1:
	    {
	    	item[0] = 1, item[1] = 2, item[2] = 7, item[3] = 12, item[4] = 40;
	    	item[5] = 41, item[6] = 36, item[7] = 34, item[8] = 14, item[9] = 5;
	    	item[10] = 42;
	    }
	    case 2:
	    {
	    	item[0] = 43, item[1] = 40, item[2] = 44;
	    }
	    case 3:
	    {
	    	item[0] = 10, item[1] = 5, item[2] = 6, item[3] = 19, item[4] = 40;
	    	item[5] = 30, item[6] = 18;
	    }
	    case 4:
	    {
	    	item[0] = 40, item[1] = 5, item[2] = 6;
	    }
	    default: return 1;
	}

	find_item = item[random(20)];
	return find_item;
}

LootItemAmount(item)
{
	new amount = 1;

	switch(item)
	{
		case 1, 2, 7, 12, 40, 41, 34, 14, 10, 6, 18, 19, 44: amount = 1;
		case 5, 36: amount = 3;
		case 30: amount = 14;
		case 42: amount = 10;
		default: amount = 1;
	}
	return amount;
}

Inventory_GetItemAmount(playerid, item)
{
	new itemid = Inventory_GetItemSlot(playerid, item);

	if (itemid != -1)
	    return Inventory[playerid][itemid][Inventory_Amount];
	return 0;
}

IsPlayerSwimming(playerid)
{
    new animlib[32], animname[32];
    
    GetAnimationName(GetPlayerAnimationIndex(playerid), animlib, 32, animname, 32);
    if(!strcmp(animlib, "SWIM")) return 1;
    return 0;
}

SetRedZone()
{
	GangZoneHideForAll(Server[RedZone]);
	GangZoneDestroy(Server[RedZone]);
	new randzone = random(sizeof(RedZones));
	Server[RedZoneID] = randzone;
	Server[RedZone] = GangZoneCreate(RedZones[randzone][0], RedZones[randzone][1], RedZones[randzone][2], RedZones[randzone][3]);
	Server[RedZoneTimer] = RED_ZONE_TIMER;
	Server[RedZoneMissileTimer] = RED_ZONE_MISSILE_TIMER;
	GangZoneShowForAll(Server[RedZone], 0xff3333FF);
	return 1;
}

RemovePlayerWeapon(playerid, weaponid)
{
    if(!IsPlayerConnected(playerid) || weaponid < 0 || weaponid > 50)
        return;

    new saveweapon[13], saveammo[13];
    for(new slot = 0; slot < 13; slot++)
        GetPlayerWeaponData(playerid, slot, saveweapon[slot], saveammo[slot]);
    ResetPlayerWeapons(playerid);
    for(new slot; slot < 13; slot++)
    {
        if(saveweapon[slot] == weaponid || saveammo[slot] == 0)
            continue;
        GivePlayerWeapon(playerid, saveweapon[slot], saveammo[slot]);
    }
}

GetWeaponObjectSlot(weaponid)
{
    new objectslot;

    switch(weaponid)
    {
        case 22..24: objectslot = 0;
        case 25..27: objectslot = 1;
        case 28, 29, 32: objectslot = 2;
        case 30, 31: objectslot = 3;
        case 33, 34: objectslot = 4;
        case 35..38: objectslot = 5;
    }
    return objectslot;
}

PlayerHasWeapon(playerid, weaponid)
{
    new weapon, ammo;

    for (new i; i < 13; i++)
    {
        GetPlayerWeaponData(playerid, i, weapon, ammo);
        if (weapon == weaponid && ammo) return 1;
    }
    return 0;
}

IsWeaponWearable(weaponid)
    return (weaponid >= 22 && weaponid <= 38);

IsWeaponHideable(weaponid)
    return (weaponid >= 22 && weaponid <= 24 || weaponid == 28 || weaponid == 32);
    
GetWeaponModel(weaponid)
{
    new model;

    switch(weaponid)
    {
        case 22..29: model = 324 + weaponid;
        case 30: model = 355;
        case 31: model = 356;
        case 32: model = 372;
        case 33..38: model = 324 + weaponid;
    }
    return model;
}

IsCharNearCraftTable(playerid)
{
	new area = Character[playerid][Character_Area];
	if(area != -1 && Character[playerid][Character_AreaType] == 3)
	{
		new data[enum_tables];
		Streamer_GetArrayData(STREAMER_TYPE_AREA, area, E_STREAMER_EXTRA_ID, data);
		if(data[tableID] > 0 && data[tableExists] == true && !data[tableUsing] && data[tableType] > 0) return area;
	}
	return -1;
}

Tables_Create(playerid, type, object)
{
	new Float:x, Float:y, Float:z, interior = GetPlayerInterior(playerid), world = GetPlayerVirtualWorld(playerid), areaid;
	
	GetPlayerPos(playerid, x, y, z);
	
	new query[500];
	format(query, sizeof(query), "INSERT INTO `tables` (`table_x`, `table_y`, `table_z`, `table_int`, `table_vw`, `table_object`, `table_type`) VALUES ('%.4f', '%.4f', '%.4f', '%d', '%d', '%d', '%d')",
	x, y, z, interior, world, object, type);
	
	new Cache:add = mysql_query(SQL_Handle, query), data[enum_tables];
	
	data[tableID] = cache_insert_id();
	data[tableX] = x;
	data[tableY] = y;
	data[tableZ] = x;
	data[tableInterior] = interior;
	data[tableVirtualWorld] = world;
	data[tableType] = type;
	data[tableUsing] = 0;
	data[tableObject] = object;
	data[tableExists] = true;
	data[areaID] = -30;
	data[tableObjectID] = CreateDynamicObject(object, x, y, z, 0.0, 0.0, interior, world);
	areaid = CreateDynamicSphere(x, y, z, 3.0, interior, world);
	Streamer_SetArrayData(STREAMER_TYPE_AREA, areaid, E_STREAMER_EXTRA_ID, data);

	cache_delete(add);
	
	TogglePlayerControllable(playerid, false);
	
	SendServerMessage(playerid, "�retim masas� kurdunuz, masan�n yerini belirleyin. SPACE tu�una bas�l� tutarak ekran� hareket ettirebilirsiniz.");
	Character[playerid][Character_EditingTable] = areaid;
	EditDynamicObject(playerid, data[tableObjectID]);
	return 1;
}

Tables_Save(areaid)
{
	new data[enum_tables];
	
	Streamer_GetArrayData(STREAMER_TYPE_AREA, areaid, E_STREAMER_EXTRA_ID, data);
	
	new query[220];
	mysql_format(SQL_Handle, query, sizeof(query), "UPDATE `tables` SET `table_x` = '%f', `table_y` = '%f', `table_z` = '%f', `table_int` = '%d', `table_vw` = '%d', `table_object` = '%d', `table_type` = '%d' WHERE `table_id` = '%d'",
	    data[tableX],
	    data[tableY],
	    data[tableZ],
	    data[tableInterior],
	    data[tableVirtualWorld],
		data[tableObject],
		data[tableType],
		data[tableID]
	);
	mysql_tquery(SQL_Handle, query);
	return 1;
}

Safe_Items(playerid, area)
{
	if(!IsValidDynamicArea(area)) return SendErrorMessage(playerid, "Bu kasa art�k yok.");
	new data[enum_safe];
	Streamer_GetArrayData(STREAMER_TYPE_AREA, area, E_STREAMER_EXTRA_ID, data);
	new string[200];
	for(new i; i < 10; i++)
	{
		if(data[safeItems][i] != -1) format(string, sizeof(string), "%s{FFFFFF}%s (%d adet)\n", string, Items[data[safeItems][i]][Item_Name], data[safeAmounts][i]);
		else strcat(string, "{AFAFAF}Bo�\n");
	}
	Dialog_Show(playerid, DIALOG_SAFE, DIALOG_STYLE_LIST, "Kasa", string, "Se�", "Kapat");
	return 1;
}

Safe_Save(area)
{
	new data[enum_safe];
	Streamer_GetArrayData(STREAMER_TYPE_AREA, area, E_STREAMER_EXTRA_ID, data);
	new query[400];
	mysql_format(SQL_Handle, query, sizeof(query), "UPDATE safes SET `safe_password` = '%e', `safe_lock` = '%d', `safe_items` = '%d|%d|%d|%d|%d|%d|%d|%d|%d|%d', `safe_amounts` = '%d|%d|%d|%d|%d|%d|%d|%d|%d|%d' WHERE `safe_id` = '%d'",
	data[safePassword],
	data[safeLock],
	data[safeItems][0],
	data[safeItems][1],
	data[safeItems][2],
	data[safeItems][3],
	data[safeItems][4],
	data[safeItems][5],
	data[safeItems][6],
	data[safeItems][7],
	data[safeItems][8],
	data[safeItems][9],
	data[safeAmounts][0],
	data[safeAmounts][1],
	data[safeAmounts][2],
	data[safeAmounts][3],
	data[safeAmounts][4],
	data[safeAmounts][5],
	data[safeAmounts][6],
	data[safeAmounts][7],
	data[safeAmounts][8],
	data[safeAmounts][9],
	data[safeID]);
	mysql_tquery(SQL_Handle, query);
	return 1;
}

CreateGlobalTextdraws()
{
	BlockMap = GangZoneCreate(-2994, -2994, 3000, 3006);


	Blind = TextDrawCreate(641.199951, 1.500000, "NULL");

	TextDrawLetterSize(Blind, 0.000000, 49.378147);
	TextDrawAlignment(Blind, 3);
	TextDrawUseBox(Blind, true);
	TextDrawBoxColor(Blind, 255);

	Blind2 = TextDrawCreate(641.199951, 1.500000, "NULL");

	TextDrawLetterSize(Blind2, 0.000000, 49.378147);
	TextDrawAlignment(Blind2, 3);
	TextDrawUseBox(Blind2, true);
	TextDrawBoxColor(Blind2, 0x2F221AFF);
	return 1;
}

HideGlobalTextdraws()
{
    GangZoneDestroy(BlockMap);
	return 1;
}

CreatePlayerTextdraws(playerid)
{
	Character[playerid][InfoBox] = CreatePlayerTextDraw(playerid, 23.000000, 180.000000, "NULL");
	PlayerTextDrawUseBox(playerid, Character[playerid][InfoBox], 1);
	PlayerTextDrawBoxColor(playerid, Character[playerid][InfoBox], 0x00000033);
	PlayerTextDrawTextSize(playerid, Character[playerid][InfoBox], 180.000000, 5.000000);
	PlayerTextDrawAlignment(playerid, Character[playerid][InfoBox], 0);
	PlayerTextDrawBackgroundColor(playerid, Character[playerid][InfoBox], 0x000000ff);
	PlayerTextDrawFont(playerid, Character[playerid][InfoBox], 2);
	PlayerTextDrawLetterSize(playerid, Character[playerid][InfoBox], 0.250000, 1.099999);
	PlayerTextDrawColor(playerid, Character[playerid][InfoBox], 0xffffffff);
	PlayerTextDrawSetOutline(playerid, Character[playerid][InfoBox], 1);
	PlayerTextDrawSetProportional(playerid, Character[playerid][InfoBox], 1);
	PlayerTextDrawSetShadow(playerid, Character[playerid][InfoBox], 1);
	return 1;
}

MessageBox(playerid, text[], seconds)
{
	if(Character[playerid][Box_Show]) PlayerTextDrawHide(playerid, Character[playerid][InfoBox]);
	
	PlayerTextDrawSetString(playerid, Character[playerid][InfoBox], text);
	PlayerTextDrawShow(playerid, Character[playerid][InfoBox]);

	Character[playerid][Character_BoxTimer] = SetTimerEx("DeleteInfoBox", seconds*1000, false, "d", playerid);
	Character[playerid][Box_Show] = true;
	return 1;
}

CreateLootPlaceText(id)
{
	new string[11];

	if(LootPlace[id][LP_Type] == 1) string = "market";
	else if(LootPlace[id][LP_Type] == 2) string = "elektronik";
	else if(LootPlace[id][LP_Type] == 3) string = "lspd";
	else if(LootPlace[id][LP_Type] == 4) string = "lsmd";

	if(IsValidDynamic3DTextLabel(LootPlace[id][LP_Text])) DestroyDynamic3DTextLabel(LootPlace[id][LP_Text]);
	
	format(string, sizeof(string), "%s #%d", string, id);

	LootPlace[id][LP_Text] = CreateDynamic3DTextLabel(string, COLOR_WHITE, LootPlace[id][LP_X], LootPlace[id][LP_Y], LootPlace[id][LP_Z], DEFAULT_DISTANCE, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 0, LootPlace[id][LP_World], LootPlace[id][LP_Interior]);
	return 1;
}

CreateLootPlacePickup(id)
{
	if(IsValidDynamicPickup(LootPlace[id][LP_Pickup])) DestroyDynamicPickup(LootPlace[id][LP_Pickup]);

	LootPlace[id][LP_Pickup] = CreateDynamicPickup(1239, 1, LootPlace[id][LP_X], LootPlace[id][LP_Y], LootPlace[id][LP_Z], LootPlace[id][LP_World], LootPlace[id][LP_Interior]);
	return 1;
}

LootPlaces_Save(id)
{
	if(!Iter_Contains(lootplace, id)) return 1;

	new query[300];

	mysql_format(SQL_Handle, query, sizeof(query), "UPDATE `lootplaces` SET `lp_x` = '%f', `lp_y` = '%f', `lp_z` = '%f', `lp_int` = '%d', `lp_vw` = '%d', `lp_inx` = '%f', `lp_iny` = '%f', `lp_inz` = '%f', `lp_inint` = '%d', `lp_invw` = '%d', `lp_type` = '%d' WHERE `lp_id` = '%d'",
		LootPlace[id][LP_X],
		LootPlace[id][LP_Y],
		LootPlace[id][LP_Z],
		LootPlace[id][LP_Interior],
		LootPlace[id][LP_World],
		LootPlace[id][LP_InX],
		LootPlace[id][LP_InY],
		LootPlace[id][LP_InZ],
		LootPlace[id][LP_InInterior],
		LootPlace[id][LP_InWorld],
		LootPlace[id][LP_Type],
		id
	);
	mysql_tquery(SQL_Handle, query);

	CreateLootPlaceText(id);
	CreateLootPlacePickup(id);
	return 1;
}

LootPlaces_Delete(id)
{
	if(!Iter_Contains(lootplace, id)) return 1;

	LootPlace[id][LP_X] = LootPlace[id][LP_Y] = LootPlace[id][LP_Z] = 0.0;
	LootPlace[id][LP_Interior] = LootPlace[id][LP_World] = -1;
	LootPlace[id][LP_InX] = LootPlace[id][LP_InY] = LootPlace[id][LP_InZ] = 0.0;
	LootPlace[id][LP_InInterior] = LootPlace[id][LP_InWorld] = LootPlace[id][LP_Type] = LootPlace[id][LP_ID] = -1;

	Iter_Remove(lootplace, id);

	new query[64];

	mysql_format(SQL_Handle, query, sizeof query, "DELETE FROM `lootplaces` WHERE `lp_id` = '%d'", id);
	mysql_tquery(SQL_Handle, query);
	
	DestroyDynamic3DTextLabel(LootPlace[id][LP_Text]);
	DestroyDynamicPickup(LootPlace[id][LP_Pickup]);
	return 1;
}

IsCharNearLootPlaceOut(playerid)
{
	foreach(new id: lootplace)
	{
	    if(IsPlayerInRangeOfPoint(playerid, 3.0, LootPlace[id][LP_X], LootPlace[id][LP_Y], LootPlace[id][LP_Z]))
	    {
	        if(GetPlayerInterior(playerid) == LootPlace[id][LP_Interior] && GetPlayerVirtualWorld(playerid) == LootPlace[id][LP_World])
	            return id;
	    }
	}
	return -1;
}

IsCharNearLootPlaceIn(playerid, Float:distance = 3.0)
{
	foreach(new id: lootplace)
	{
	    if(IsPlayerInRangeOfPoint(playerid, distance, LootPlace[id][LP_InX], LootPlace[id][LP_InY], LootPlace[id][LP_InZ]))
	    {
	        if(GetPlayerInterior(playerid) == LootPlace[id][LP_InInterior] && GetPlayerVirtualWorld(playerid) == LootPlace[id][LP_InWorld])
	            return id;
	    }
	}
	return -1;
}

Pump_Closest(playerid, Float: range = 6.0)
{
    new id = -1, Float: dist = range, Float: tempdist;
    for(new i; i < MAX_GAS_PUMPS; i++)
    {
        tempdist = GetPlayerDistanceFromPoint(playerid, PumpData[i][pumpX], PumpData[i][pumpY], PumpData[i][pumpZ]);

        if(tempdist > range) continue;
        if(tempdist <= dist)
        {
            dist = tempdist;
            id = i;
        }
    }
    return id;
}

UpdateTree(id)
{
	new label[90];
	if(!TreeData[id][treeStatus])
	{
		if(IsValidDynamicObject(TreeData[id][treeObject])) DestroyDynamicObject(TreeData[id][treeObject]);
		TreeData[id][treeObject] = CreateDynamicObject(657, TreeData[id][treeX], TreeData[id][treeY], TreeData[id][treeZ] - 1, 0.0, 0.0, 0.0);
		format(label, sizeof(label), "A�a� (#%d)\n\n{FFFFFF}Kesmek i�in {F1C40F}/agac kes{FFFFFF} komutunu kullanabilirsin.", id);
		UpdateDynamic3DTextLabelText(TreeData[id][treeLabel], 0x2ECC71FF, label);
	}
	else if(TreeData[id][treeStatus] == 2)
	{
		format(label, sizeof(label), "A�a� (#%d)\n\n{FFFFFF}A�a�ta %d odun var. (/agac al)", id, TreeData[id][treeLogs]);
		UpdateDynamic3DTextLabelText(TreeData[id][treeLabel], 0x2ECC71FF, label);
	}
	return 1;
}

GetClosestTree(playerid, Float: range = 2.0)
{
	new id = -1, Float:dist = range, Float: tempdist;
	for(new i = 0; i < sizeof(TreeData); i++)
	{
	    tempdist = GetPlayerDistanceFromPoint(playerid, TreeData[i][treeX], TreeData[i][treeY], TreeData[i][treeZ]);

	    if(tempdist > range) continue;
		if(tempdist <= dist)
		{
			dist = tempdist;
			id = i;
		}
	}

	return id;
}

Tent_Objects(id)
{
	if(IsValidDynamic3DTextLabel(Tent[id][Tent_Text])) DestroyDynamic3DTextLabel(Tent[id][Tent_Text]);

	new string[14];

	format(string, sizeof(string), "�ad�r [#%d]", id);

	Tent[id][Tent_Text] = CreateDynamic3DTextLabel(string, COLOR_GREEN, Tent[id][Tent_X], Tent[id][Tent_Y], Tent[id][Tent_Z], DEFAULT_DISTANCE, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 0, Tent[id][Tent_World], Tent[id][Tent_Interior]);

	if(IsValidDynamicObject(Tent[id][Tent_Object])) DestroyDynamicObject(Tent[id][Tent_Object]);

 	Tent[id][Tent_Object] = CreateDynamicObject(3243, Tent[id][Tent_X], Tent[id][Tent_Y], Tent[id][Tent_Z], Tent[id][Tent_rX], Tent[id][Tent_rY], Tent[id][Tent_rZ], Tent[id][Tent_Interior], Tent[id][Tent_World]);
	return 1;
}

IsCharPlaceTent(playerid)
{
	foreach(new i: tent)
	{
	    if(Tent[i][Tent_Owner] == Character[playerid][Character_SQL])
	        return i;
	}
	return -1;
}

Tent_Create(playerid)
{
	new id = Iter_Free(tent);

	if(id == -1) return SendErrorMessage(playerid, "�ad�r kurma limitine ula��lm��. (/rapor)");

	GetPlayerPos(playerid, Tent[id][Tent_X], Tent[id][Tent_Y], Tent[id][Tent_Z]);
	
	Tent[id][Tent_Y] = Tent[id][Tent_Y] + 2.0;
	Tent[id][Tent_Z] = Tent[id][Tent_Z] - 1.0;
	Tent[id][Tent_rX] = Tent[id][Tent_rY] = Tent[id][Tent_rZ] = 0.0;
	Tent[id][Tent_Interior] = GetPlayerInterior(playerid);
	Tent[id][Tent_World] = GetPlayerVirtualWorld(playerid);

	Tent[id][Tent_InX] = -221.059051;
	Tent[id][Tent_InY] = 1408.984008;
	Tent[id][Tent_InZ] = 27.773437;
	Tent[id][Tent_InInterior] = 18;
	Tent[id][Tent_InWorld] = id + 2000;
	Tent[id][Tent_Lock] = 0;
	Tent[id][Tent_Owner] = Character[playerid][Character_SQL];

	Iter_Add(tent, id);

	new query[400];
    mysql_format(SQL_Handle, query, sizeof(query), "INSERT INTO `tents` (`tent_id`, `tent_x`, `tent_y`, `tent_z`, `tent_int`, `tent_vw`, `tent_inx`, `tent_iny`, `tent_inz`, `tent_inint`, `tent_invw`, `tent_lock`, `tent_owner`, `tent_rx`, `tent_ry`, `tent_rz`) VALUES ('%d', '%f', '%f', '%f', '%d', '%d', '%f', '%f', '%f', '%d', '%d', '%d', '%d', '%f', '%f', '%f')",
		id,
		Tent[id][Tent_X],
		Tent[id][Tent_Y],
		Tent[id][Tent_Z],
		Tent[id][Tent_Interior],
		Tent[id][Tent_World],
		Tent[id][Tent_InX],
		Tent[id][Tent_InY],
		Tent[id][Tent_InZ],
		Tent[id][Tent_InInterior],
		Tent[id][Tent_InWorld],
		Tent[id][Tent_Lock],
		Tent[id][Tent_Owner],
		Tent[id][Tent_rX],
		Tent[id][Tent_rY],
		Tent[id][Tent_rZ]
	);
    mysql_tquery(SQL_Handle, query);
    
    Tent_Save(id, true);
    
    SendServerMessage(playerid, "�ad�r kuruldu.");
    SetPlayerPos(playerid, Tent[id][Tent_X]+3.0, Tent[id][Tent_Y], Tent[id][Tent_Z]);

	Character[playerid][Character_EditingTent] = id;
	EditDynamicObject(playerid, Tent[id][Tent_Object]);
	return 1;
}

Tent_Delete(id)
{
	if(!Iter_Contains(tent, id)) return 1;

	Tent[id][Tent_X] = Tent[id][Tent_Y] = Tent[id][Tent_Z] = 0.0;
	Tent[id][Tent_Interior] = Tent[id][Tent_World] = -1;
	Tent[id][Tent_InX] = Tent[id][Tent_InY] = Tent[id][Tent_InZ] = 0.0;
	Tent[id][Tent_InInterior] = Tent[id][Tent_InWorld] = Tent[id][Tent_Owner] = Tent[id][Tent_ID] = -1;
	Tent[id][Tent_Lock] = 1;

	Iter_Remove(tent, id);

	new query[64];

	mysql_format(SQL_Handle, query, sizeof query, "DELETE FROM `tents` WHERE `tent_id` = '%d'", id);
	mysql_tquery(SQL_Handle, query);

	DestroyDynamic3DTextLabel(Tent[id][Tent_Text]);
	DestroyDynamicObject(Tent[id][Tent_Object]);
	return 1;
}

IsCharNearTent(playerid)
{
	foreach(new i: tent)
	{
		if(Tent[i][Tent_Interior] == GetPlayerInterior(playerid) && Tent[i][Tent_World] == GetPlayerVirtualWorld(playerid))
		{
			if(IsPlayerInRangeOfPoint(playerid, 6.0, Tent[i][Tent_X], Tent[i][Tent_Y], Tent[i][Tent_Z]))
				return i;
		}
	}
	return -1;
}

IsCharNearInTent(playerid)
{
	foreach(new i: tent)
	{
		if(Tent[i][Tent_InInterior] == GetPlayerInterior(playerid) && Tent[i][Tent_InWorld] == GetPlayerVirtualWorld(playerid))
		{
			if(IsPlayerInRangeOfPoint(playerid, 3.0, Tent[i][Tent_InX], Tent[i][Tent_InY], Tent[i][Tent_InZ]))
				return i;
		}
	}
	return -1;
}

/*Functions*/

forward OnLookupNPCHerdPoints(playerid);
public OnLookupNPCHerdPoints(playerid)
{
	new rows = cache_num_rows();

	if(!rows)
		return SendErrorMessage(playerid, "S�r� noktas� bulunamad�.");

	new str[2048], point_id, Float:x, Float:y, Float:z;

	str = "Nokta numaras�\tNokta koordinat\n";

	for(new i = 0; i < rows; i++)
	{
		cache_get_value_name_int(i, "point_id", point_id);

		cache_get_value_name_float(i, "point_x", x);
		cache_get_value_name_float(i, "point_y", y);
		cache_get_value_name_float(i, "point_z", z);

		format(str, sizeof(str), "%s%d\tX: %.3f, Y: %.3f, Z: %.3f\n", str, point_id, x, y, z);
	}

	Dialog_Show(playerid, 0, DIALOG_STYLE_TABLIST_HEADERS, "S�r� Noktalar�", str, "Kapat", "");
	return 1;
}


forward OnLookupNPCHerds(playerid);
public OnLookupNPCHerds(playerid)
{
	new rows = cache_num_rows();

	if(!rows)
		return SendErrorMessage(playerid, "S�r� bulunamad�.");

	new str[2048], herd_name[32], herd_created_by[MAX_PLAYER_NAME], Float:x, Float:y, Float:z, npc_count, herd_id;

	str = "S�r� numaras�\tNPC say�s�\tS�r� ad�\tS�r� olu�turan\n";

	for(new i = 0; i < rows; i++)
	{
		cache_get_value_name_int(i, "herd_id", herd_id);
		
		for(new a = 0; a < MAX_DYNAMIC_NPC; a++)
		{
			if(NPCInfo[a][NPC_database_id] > 0)
			{
				if(NPCInfo[a][NPC_herd_id] == herd_id)
				{
					npc_count++;
				}
			}
		}

		cache_get_value_name_int(i, "herd_id", herd_id);

		cache_get_value_name(i, "herd_name", herd_name);
		cache_get_value_name(i, "herd_created_by", herd_created_by);

		cache_get_value_name_float(i, "herd_next_x", x);
		cache_get_value_name_float(i, "herd_next_y", y);
		cache_get_value_name_float(i, "herd_next_z", z);

		format(str, sizeof(str), "%s%d\t%d adet\t%s\t%s\n", str, herd_id, npc_count, herd_name, herd_created_by);
	}

	Dialog_Show(playerid, 0, DIALOG_STYLE_TABLIST_HEADERS, "S�r� Listesi", str, "Kapat", "");
	return 1;
}

forward OnLoadNPCData();
public OnLoadNPCData()
{
	new rows = cache_num_rows();

	if(rows > 0)
	{
		for(new i = 0; i < rows; i++)
		{
			cache_get_value_name_int(i, "npc_id", NPCInfo[i][NPC_database_id]);

			cache_get_value_name_float(i, "npc_x", NPCInfo[i][NPC_x]);
			cache_get_value_name_float(i, "npc_y", NPCInfo[i][NPC_y]);
			cache_get_value_name_float(i, "npc_z", NPCInfo[i][NPC_z]);

			cache_get_value_name_float(i, "npc_health", NPCInfo[i][NPC_health]);
			cache_get_value_name_float(i, "npc_armour", NPCInfo[i][NPC_armour]);

			cache_get_value_name_int(i, "npc_skin", NPCInfo[i][NPC_skin]);

			cache_get_value_name_int(i, "npc_damage", NPCInfo[i][NPC_damage]);
			cache_get_value_name_int(i, "npc_walk_speed", NPCInfo[i][NPC_walk_speed]);
			cache_get_value_name_int(i, "npc_bite", NPCInfo[i][NPC_bite]);
			cache_get_value_name_int(i, "npc_herd_id", NPCInfo[i][NPC_herd_id]);

			NPC_Spawn(i);
		}

		printf("[NPCS] Loaded %d npcs.", rows);
	}
	else
	{
		printf("[NPCS] No content found to upload.");
	}
	return 1;
}

forward OnNPCCreated(id);
public OnNPCCreated(id)
{
	if(id == -1)
		return 0;

	NPCInfo[id][NPC_database_id] = cache_insert_id();
	
	NPC_Spawn(id);
	return 1;
}

forward CutTree(playerid); public CutTree(playerid)
{
	new id = GetPVarInt(playerid, "TreeID");
	if(id != -1)
	{
		MoveDynamicObject(TreeData[id][treeObject], TreeData[id][treeX], TreeData[id][treeY], TreeData[id][treeZ] - 1, 0.001, 0.0, -80.0, 0.0);
		TreeData[id][treeStatus] = 2;
		TreeData[id][treeLogs] = RandomEx(3, 6);
		TreeData[id][treeMinutes] = 10;
		UpdateTree(id);
		ClearAnimations(playerid);
		TogglePlayerControllable(playerid, 1);
		SetPVarInt(playerid, "TreeID", -1);
		DeleteInfoBox(playerid);
	}
	return 1;
}

forward Picklock(playerid); public Picklock(playerid)
{
	new area = Character[playerid][Character_Area];
	if(area == -1)
	{
		if(IsValidDynamicArea(Character[playerid][Character_Picklock]))
		{
			new data[enum_safe];
			Streamer_GetArrayData(STREAMER_TYPE_AREA, Character[playerid][Character_Picklock], E_STREAMER_EXTRA_ID, data);
			data[picklock] = false;
			Streamer_SetArrayData(STREAMER_TYPE_AREA, Character[playerid][Character_Picklock], E_STREAMER_EXTRA_ID, data);
		}
		Character[playerid][Character_Picklock] = -1;
		Character[playerid][Character_PicklockCode][0] = EOS;
		Character[playerid][Character_PicklockCodeCount] = 0;
		KillTimer(Character[playerid][Character_PicklockTimer]);
		Character[playerid][Character_PicklockTimer] = -1;
		SendErrorMessage(playerid, "Kasadan uzakla�t���n�z i�in kasa a�ma i�lemi iptal edildi.");
		ClearAnimations(playerid);
		return 1;
	}
	new str[50];
	format(str, sizeof(str), "~b~Kod: ~w~%s~n~~b~Zaman: ~w~%d", Character[playerid][Character_PicklockCode], Character[playerid][Character_PicklockCodeTime]);
	GameTextForPlayer(playerid, str, 1500, 3);
	if(!isnull(Character[playerid][Character_PicklockCode]))
	{
		Character[playerid][Character_PicklockCodeTime]--;
		if(Character[playerid][Character_PicklockCodeTime] <= 0)
		{
			if(IsValidDynamicArea(Character[playerid][Character_Picklock]))
			{
				new data[enum_safe];
				Streamer_GetArrayData(STREAMER_TYPE_AREA, Character[playerid][Character_Picklock], E_STREAMER_EXTRA_ID, data);
				data[picklock] = false;
				Streamer_SetArrayData(STREAMER_TYPE_AREA, Character[playerid][Character_Picklock], E_STREAMER_EXTRA_ID, data);
			}
			Character[playerid][Character_Picklock] = -1;
			Character[playerid][Character_PicklockCode][0] = EOS;
			Character[playerid][Character_PicklockCodeCount] = 0;
			KillTimer(Character[playerid][Character_PicklockTimer]);
			Character[playerid][Character_PicklockTimer] = -1;
			SendErrorMessage(playerid, "Kodu verilen s�rede yazamad���n�z i�in kasa a�ma i�lemi ba�ar�s�z.");
			ClearAnimations(playerid);
			return 1;
		}
	}
	if(isnull(Character[playerid][Character_PicklockCode]) && Character[playerid][Character_PicklockCodeCount] <= 0)
	{
		if(IsValidDynamicArea(Character[playerid][Character_Picklock]))
		{
			new data[enum_safe];
			Streamer_GetArrayData(STREAMER_TYPE_AREA, Character[playerid][Character_Picklock], E_STREAMER_EXTRA_ID, data);
			data[picklock] = false;
			data[safePassword][0] = EOS;
			Streamer_SetArrayData(STREAMER_TYPE_AREA, Character[playerid][Character_Picklock], E_STREAMER_EXTRA_ID, data);
			Safe_Save(Character[playerid][Character_Picklock]);
		}
		Character[playerid][Character_Picklock] = -1;
		Character[playerid][Character_PicklockCode][0] = EOS;
		Character[playerid][Character_PicklockCodeCount] = 0;
		KillTimer(Character[playerid][Character_PicklockTimer]);
		Character[playerid][Character_PicklockTimer] = -1;
		SendServerMessage(playerid, "Kasa a�ma i�lemi ba�ar�l�.");
		ClearAnimations(playerid);
		callcmd::kasa(playerid, "al");
		return 1;
	}
	return 1;
}

forward OnInventoryAdd(playerid, itemid); public OnInventoryAdd(playerid, itemid)
{
	Inventory[playerid][itemid][Inventory_ID] = cache_insert_id();
	return 1;
}

forward MinuteUpdate(); public MinuteUpdate()
{
	foreach(new i: Player)
	{
		if(Account[i][Account_IsPlaying])
		{
			Character[i][Character_PaydayTime]++;
			if(Character[i][Character_PaydayTime] >= 60)
			{
			    SendClientMessage(i, COLOR_GREEN, "[+] {FFFFFF}Saatlik kazan�:");
				new levelexp = (Character[i][Character_Level] + 1) * LEVEL_EXP;
				Character[i][Character_PaydayTime] = 0;
				Character[i][Character_EXP]++;
				Character[i][Character_TalentPoint]++;
				SendServerMessage(i, "Oyunda 1 saatinizi doldurdu�unuz i�in 1 tecr�be ve 1 yetenek puan� kazand�n�z.");
				if(Character[i][Character_EXP] >= levelexp)
				{
					Character[i][Character_EXP] -= levelexp;
					Character[i][Character_Level]++;
					SetPlayerScore(i, Character[i][Character_Level]);
					SendServerMessage(i, "Seviye atlad�n�z.");
				}
			}
		}
	}

	Server[RedZoneTimer]--;
	Server[RedZoneMissileTimer]--;

	if(Server[RedZoneTimer] <= 0)
		SetRedZone();

	if(Server[RedZoneMissileTimer] <= 0)
	{
		new distance, Float:x, Float:y;
		for(new i; i < 20; i++)
		{
			distance = RandomEx(10, 300);
			x = RedZones[Server[RedZoneID]][0] - distance;
			y = RedZones[Server[RedZoneID]][1] - distance;
			CreateExplosion(x, y, RedZones[Server[RedZoneID]][4], 6, 50 + distance);
		}
		Server[RedZoneMissileTimer] = RED_ZONE_MISSILE_TIMER;
	}
	for(new i; i < sizeof(TreeData); i++)
	{
		if(TreeData[i][treeStatus] == 2)
		{
			TreeData[i][treeMinutes]--;
			if(TreeData[i][treeMinutes] <= 0)
			{
				TreeData[i][treeStatus] = 0;
				TreeData[i][treeLogs] = 0;
				TreeData[i][treeMinutes] = 0;
				SetDynamicObjectPos(TreeData[i][treeObject], TreeData[i][treeX], TreeData[i][treeY], TreeData[i][treeZ] - 1);
				SetDynamicObjectRot(TreeData[i][treeObject], 0.0, 0.0, 0.0);
				UpdateTree(i);
			}
		}
	}
	new data[enum_droppeditems], data2[enum_campfire];
	for(new i, maxval = Streamer_GetUpperBound(STREAMER_TYPE_RACE_CP); i <= maxval; ++i)
	{
		if(!IsValidDynamicRaceCP(i)) continue;
		Streamer_GetArrayData(STREAMER_TYPE_RACE_CP, i, E_STREAMER_EXTRA_ID, data);
		if(data[DroppedItem_ID] > 0)
		{
			if(!data[DroppedItem_Owned] && data[DroppedItem_SpawnTime] > 0)
			{
				if(gettime() >= data[DroppedItem_SpawnTime])
				{
					data[DroppedItem_SpawnTime] = 0;
					Streamer_SetIntData(STREAMER_TYPE_OBJECT, data[DroppedItem_Object], E_STREAMER_WORLD_ID, 0);
					Streamer_SetIntData(STREAMER_TYPE_3D_TEXT_LABEL, data[DroppedItem_Text], E_STREAMER_WORLD_ID, 0);
					Streamer_SetArrayData(STREAMER_TYPE_RACE_CP, i, E_STREAMER_EXTRA_ID, data);
				}
			}
		}
	}
	for(new i, maxval = Streamer_GetUpperBound(STREAMER_TYPE_AREA); i <= maxval; ++i)
	{
		if(!IsValidDynamicArea(i)) continue;
		Streamer_GetArrayData(STREAMER_TYPE_AREA, i, E_STREAMER_EXTRA_ID, data2);
		if(data2[fireExists] == true)
		{
			if(Streamer_IsInArrayData(STREAMER_TYPE_AREA, i, E_STREAMER_EXTRA_ID, -10))
			{
				if(gettime() >= data2[fireTimer])
				{
					DestroyDynamicObject(data2[fireObject]);
					DestroyDynamicArea(i);
					if(IsValidDynamic3DTextLabel(data2[CookingText])) DestroyDynamic3DTextLabel(data2[CookingText]);
					if(data2[CookingTimer] != -1) KillTimer(data2[CookingTimer]);
				}
			}
		}
	}
	return 1;
}

forward AirdropDelete(id); public AirdropDelete(id) return Airdrop_Delete(id);

forward DelayedKick(playerid); public DelayedKick(playerid) return Kick(playerid);

forward OnAccountDataLoaded(playerid, race_check); public OnAccountDataLoaded(playerid, race_check)
{
	if(race_check != SQL_RaceCheck[playerid]) return Kick(playerid);

	if(cache_num_rows() > 0)
	{
		cache_get_value(0, "account_password", Account[playerid][Account_Password], 129);

		Account[playerid][Account_CacheID] = cache_save();

		Dialog_Show(playerid, DIALOG_LOGIN, DIALOG_STYLE_PASSWORD, "Zombieland Role Play", "{FFFFFF}Tekrardan ho� geldiniz, {CC9966}%s{FFFFFF}.\nVeritaban�nda kay�tl� hesab�n�z bulundu, �ifrenizi kutucu�a yaz�n ve giri� yap�n. Giri� yapmak i�in {CC9966}%d saniye{FFFFFF}niz var.", "giri�", "��k��", Account[playerid][Account_Name], SECONDS_TO_LOGIN);

		Account[playerid][Account_LoginTimer] = SetTimerEx("OnLoginTimeout", SECONDS_TO_LOGIN * 1000, false, "d", playerid);
	}else{
		Dialog_Show(playerid, DIALOG_REGISTER, DIALOG_STYLE_PASSWORD, "Zombieland Role Play", "{FFFFFF}Ho� geldiniz, {CC9966}%s{FFFFFF}.\nVeritaban�nda kay�tl� hesab�n�z bulunamad�, �ifrenizi kutucu�a girerek hesap olu�turabilirsiniz.", "kay�t", "��k��", Account[playerid][Account_Name]);
	}
	return 1;
}

forward OnLoginTimeout(playerid); public OnLoginTimeout(playerid)
{
	Account[playerid][Account_KickTimer] = -1;
	
	Dialog_Show(playerid, DIALOG_UNUSED, DIALOG_STYLE_MSGBOX, "Zombieland Role Play", "{CC9966}%d saniye {FFFFFF}boyunca giri� yapmad���n�z i�in oyundan uzakla�t�r�ld�n�z.", "X", "", SECONDS_TO_LOGIN);
	KickEx(playerid);
	return 1;
}

forward OnAccountRegister(playerid); public OnAccountRegister(playerid)
{
	Account[playerid][Account_SQL] = cache_insert_id();
	Account[playerid][Account_AvailableSlots] = DEFAULT_CHARSLOT;
	Account[playerid][Account_ActiveSlots] = Account[playerid][Account_Staff] = 0;
	Account[playerid][Settings_Pm] = Account[playerid][Settings_OOC] = 1;
	Account[playerid][Account_IsLogged] = true;

	UpdateAccount(playerid);

	SendServerMessage(playerid, "Ba�ar�yla kay�t oldunuz.");
	ShowAccountMainMenu(playerid);
	return 1;
}

forward OnPlayerListCharacters(playerid); public OnPlayerListCharacters(playerid)
{
	new rows;

	cache_get_row_count(rows);

	if(rows)
	{
		new string[24 * MAX_CHARSLOT + MAX_CHARSLOT],
			header[24];

	    for(new i = 0, j = rows; i < j; i++)
	    {
	    	cache_get_value(i, "char_name", Character[playerid][Character_Name], MAX_PLAYER_NAME);
	    	format(string, sizeof(string), "%s%s\n", string, Character[playerid][Character_Name]);
	    }

	    format(header, sizeof(header), "%s (%d/%d)", Account[playerid][Account_Name], Account[playerid][Account_ActiveSlots], Account[playerid][Account_AvailableSlots]+Account[playerid][Account_ActiveSlots]);

	    Dialog_Show(playerid, DIALOG_CHARACTERS, DIALOG_STYLE_LIST, header, string, "Giri�", "Geri");
	}else{
		SendErrorMessage(playerid, "Veritaban�nda karakteriniz bulunamad�, yeni bir karakter olu�turabilirsiniz.");
		ShowAccountMainMenu(playerid);
	}
	return 1;
}

forward OnCharacterRegister(playerid); public OnCharacterRegister(playerid)
{
	Character[playerid][Character_SQL] = cache_insert_id();
	Character[playerid][Character_AccountSQL] = Account[playerid][Account_SQL];
	Character[playerid][Character_PosX] = DEFAULT_POS_X;
	Character[playerid][Character_PosY] = DEFAULT_POS_Y;
	Character[playerid][Character_PosZ] = DEFAULT_POS_Z;
	Character[playerid][Character_PosA] = DEFAULT_POS_A;
	Character[playerid][Character_Level] = 1;
	
	UpdateCharacter(playerid);

	Account[playerid][Account_AvailableSlots]--;
	Account[playerid][Account_ActiveSlots]++;

	UpdateAccount(playerid);

	SendServerMessage(playerid, "Yeni karakter ba�ar�yla olu�turuldu. {FFFFFF}(Karakterlerimi listele > giri�)");
	ShowAccountMainMenu(playerid);
	return 1;
}

forward OnCharacterDataLoaded(playerid); public OnCharacterDataLoaded(playerid)
{
	if(cache_num_rows() > 0)
	{
		cache_get_value_int(0, "char_sql", Character[playerid][Character_SQL]);
		cache_get_value_int(0, "char_configured", Character[playerid][Character_Configured]);

		if(Character[playerid][Character_Configured])
		{	
			new weapon[20], ammo[30];
			cache_get_value_float(0, "char_posx", Character[playerid][Character_PosX]);
			cache_get_value_float(0, "char_posy", Character[playerid][Character_PosY]);
			cache_get_value_float(0, "char_posz", Character[playerid][Character_PosZ]);
			cache_get_value_float(0, "char_posa", Character[playerid][Character_PosA]);
			cache_get_value_int(0, "char_vw", Character[playerid][Character_VirtualWorld]);
			cache_get_value_int(0, "char_int", Character[playerid][Character_Interior]);
			cache_get_value_int(0, "char_gender", Character[playerid][Character_Gender]);
			cache_get_value_int(0, "char_job", Character[playerid][Character_Job]);
			cache_get_value_int(0, "char_age", Character[playerid][Character_Age]);
			cache_get_value_int(0, "talent_mechanic", Character[playerid][Talent_Mechanic]);
			cache_get_value_int(0, "talent_fishing", Character[playerid][Talent_Fishing]);
			cache_get_value_int(0, "talent_aim", Character[playerid][Talent_Aim]);
			cache_get_value_int(0, "talent_crafting", Character[playerid][Talent_Crafting]);
			cache_get_value_int(0, "talent_firstaid", Character[playerid][Talent_FirstAid]);
			cache_get_value_int(0, "talent_cooking", Character[playerid][Talent_Cooking]);
			cache_get_value_int(0, "char_backpack", Character[playerid][Character_Backpack]);
			cache_get_value_float(0, "char_carry", Character[playerid][Character_Carry]);
			cache_get_value_int(0, "char_level", Character[playerid][Character_Level]);
			cache_get_value_int(0, "char_exp", Character[playerid][Character_EXP]);
			cache_get_value_int(0, "char_paydaytime", Character[playerid][Character_PaydayTime]);
			cache_get_value_int(0, "char_talentpoint", Character[playerid][Character_TalentPoint]);
			cache_get_value_name(0, "char_weapons", weapon, 20);
			sscanf(weapon, "p<|>iiiii", Character[playerid][Character_Weapons][0], Character[playerid][Character_Weapons][1], Character[playerid][Character_Weapons][2], Character[playerid][Character_Weapons][3], Character[playerid][Character_Weapons][4]);
			cache_get_value_name(0, "char_ammo", ammo, 30);
			sscanf(ammo, "p<|>iiiii", Character[playerid][Character_Ammo][0], Character[playerid][Character_Ammo][1], Character[playerid][Character_Ammo][2], Character[playerid][Character_Ammo][3], Character[playerid][Character_Ammo][4]);
		
			new query[70];
			mysql_format(SQL_Handle, query, sizeof(query), "SELECT * FROM inventory WHERE `inv_sql` = '%d'", Character[playerid][Character_SQL]);
			mysql_tquery(SQL_Handle, query, "LoadInventory", "i", playerid);
			
   			mysql_format(SQL_Handle, query, sizeof(query), "SELECT * FROM weaponsettings WHERE Owner = '%d'", Character[playerid][Character_SQL]);
    		mysql_tquery(SQL_Handle, query, "OnWeaponsLoaded", "d", playerid);

			SpawnCharacter(playerid, true);
		}else{
			Dialog_Show(playerid, DIALOG_GENDER, DIALOG_STYLE_MSGBOX, "Zombieland Roleplay", "{FFFFFF}Karakterinizin yap�land�r�lmas� tamamlanmam�� {CC9966}%s (%s){FFFFFF}, karakterinizin cinsiyetini se�in.", "Erkek", "Kad�n", Character[playerid][Character_Name], Account[playerid][Account_Name]);
		}
	}else{
		SendErrorMessage(playerid, "Bilinmedik bir sorun olu�tu, l�tfen karakterinize tekrar giri� yapmay� deneyin.");
		Account[playerid][Account_IsPlaying] = false;
		ListAccountCharacters(playerid);
	}
	return 1;
}

forward LoadInventory(playerid); public LoadInventory(playerid)
{
	new rows = cache_num_rows();
	for(new i; i < rows; i++)
	{
		Inventory[playerid][i][Inventory_Exists] = true;
		cache_get_value_int(i, "inv_id", Inventory[playerid][i][Inventory_ID]);
		cache_get_value_int(i, "inv_item", Inventory[playerid][i][Inventory_Item]);
		cache_get_value_int(i, "inv_amount", Inventory[playerid][i][Inventory_Amount]);
	}

	if(Inventory_GetItemAmount(playerid, 40) < 1) // map item
		GangZoneShowForPlayer(playerid, BlockMap, 0x000000FF);
	return 1;
}

forward DroppedItems_Load(); public DroppedItems_Load()
{
	new rows = cache_num_rows();
	
	if(rows)
	{
	    new string[40], id, data[enum_droppeditems];
	    
	    for(new i; i < rows; i++)
		{
		    cache_get_value_int(i, "ditem_id", data[DroppedItem_ID]);
		    
		    cache_get_value_float(i, "ditem_x", data[DroppedItem_PosX]);
			cache_get_value_float(i, "ditem_y", data[DroppedItem_PosY]);
			cache_get_value_float(i, "ditem_z", data[DroppedItem_PosZ]);
			
			cache_get_value_int(i, "ditem_int", data[DroppedItem_Interior]);
			cache_get_value_int(i, "ditem_vw", data[DroppedItem_VirtualWorld]);
			
			cache_get_value_int(i, "ditem_item", data[DroppedItem_Item]);
			cache_get_value_int(i, "ditem_amount", data[DroppedItem_Amount]);
			cache_get_value_int(i, "ditem_owned", data[DroppedItem_Owned]);
			data[DroppedItem_SpawnTime] = 0;
			
			format(string, sizeof(string), "(#%d) %s (%d adet)", data[DroppedItem_ID], Items[data[DroppedItem_Item]][Item_Name], data[DroppedItem_Amount]);

			data[DroppedItem_Text] = CreateDynamic3DTextLabel(string, COLOR_CLIENT, data[DroppedItem_PosX], data[DroppedItem_PosY], data[DroppedItem_PosZ] - 1, 5.0, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 0, data[DroppedItem_Interior], data[DroppedItem_VirtualWorld]);
			data[DroppedItem_Object] = CreateDynamicObject(Items[data[DroppedItem_Item]][Item_ObjectID], data[DroppedItem_PosX], data[DroppedItem_PosY], data[DroppedItem_PosZ] - 1, 0.0, 0.0, 0.0, data[DroppedItem_Interior], data[DroppedItem_VirtualWorld]);
			id = CreateDynamicRaceCP(2, data[DroppedItem_PosX], data[DroppedItem_PosY], data[DroppedItem_PosZ] - 1, 0.0, 0.0, 0.0, 1.0, 800, 0); 
			Streamer_SetArrayData(STREAMER_TYPE_RACE_CP, id, E_STREAMER_EXTRA_ID, data);
		}
		printf("[Dropped items] Loaded %d items.", rows);
	}
	else print("[Dropped items] No content found to upload.");
	return 1;
}

forward OnCookingEnd(id); public OnCookingEnd(id)
{
	if(IsValidDynamicArea(id))
	{
		new data[enum_campfire];
		Streamer_GetArrayData(STREAMER_TYPE_AREA, id, E_STREAMER_EXTRA_ID, data);
		data[CookingFish] = 0;
		data[CookedFish] = gettime();
		data[CookingTimer] = -1;
		UpdateDynamic3DTextLabelText(data[CookingText], COLOR_LIMEYELLOW, "* Bal�k pi�ti!\n(( N tu�u ile alabilirsiniz. ))");
		Streamer_SetArrayData(STREAMER_TYPE_AREA, id, E_STREAMER_EXTRA_ID, data);
	}
	return 1;
}

forward OnCharacterEndFishing(playerid); public OnCharacterEndFishing(playerid)
{
	Character[playerid][Character_FishingTimer] = -1;

	if(random(DROP_FISH) < Character[playerid][Talent_Fishing])
	{
		SendNearbyMessage(playerid, 20.0, COLOR_GREEN, "* Oltas�na bir adet bal�k tak�ld�. (( %s ))", ReturnName(playerid));
		Inventory_AddItem(playerid, 3, 1);
	}else{
	    SendNearbyMessage(playerid, 20.0, COLOR_LIMEYELLOW, "* Oltas�na hi�bir �ey tak�lmad�. (( %s ))", ReturnName(playerid));
	}

    GiveRandomTalentPoint(playerid, 1, 1);
	pc_cmd_ame(playerid, "oltas�n� kendine do�ru �eker.");
	ClearAnimations(playerid);
	TogglePlayerControllable(playerid, true);
	return 1;
}

forward OnWeaponsLoaded(playerid); public OnWeaponsLoaded(playerid)
{
    new rows, weaponid, index;

    cache_get_row_count(rows);

    for (new i; i < rows; i++)
    {
        cache_get_value_name_int(i, "WeaponID", weaponid);
        index = weaponid - 22;

        cache_get_value_name_float(i, "PosX", WeaponSettings[playerid][index][Position][0]);
        cache_get_value_name_float(i, "PosY", WeaponSettings[playerid][index][Position][1]);
        cache_get_value_name_float(i, "PosZ", WeaponSettings[playerid][index][Position][2]);

        cache_get_value_name_float(i, "RotX", WeaponSettings[playerid][index][Position][3]);
        cache_get_value_name_float(i, "RotY", WeaponSettings[playerid][index][Position][4]);
        cache_get_value_name_float(i, "RotZ", WeaponSettings[playerid][index][Position][5]);

        cache_get_value_name_int(i, "Bone", WeaponSettings[playerid][index][Bone]);
        cache_get_value_name_int(i, "Hidden", WeaponSettings[playerid][index][Hidden]);
    }
}
forward OnCharacterEndCrafting(playerid, item, found); public OnCharacterEndCrafting(playerid, item, found)
{
	Character[playerid][Character_CraftTimer] = -1;

	if(random(DROP_CRAFT) < Character[playerid][Talent_Crafting])
	{
		SendNearbyMessage(playerid, 20.0, COLOR_GREEN, "* %s e�yas�n� ba�ar�yla �retti. (( %s ))", Items[CraftData[item][Craft_Item]][Item_Name], ReturnName(playerid));

		if(CraftData[item][Use_Item] == false)
		{
			Inventory_AddItem(playerid, CraftData[item][Craft_Item], 1);
		}
		else
		{
			switch(CraftData[item][Craft_Item])
			{
				case 33:
				{
					Tables_Create(playerid, 1, 2115);
				}
				case 37:
				{
					new data[enum_campfire], area, interior = GetPlayerInterior(playerid), vw = GetPlayerVirtualWorld(playerid);
					GetPlayerPos(playerid, data[fireX], data[fireY], data[fireZ]);
					data[CookingFish] = 0;
					data[CookedFish] = 0;
					data[CookingTimer] = -1;
					data[fireTimer] = gettime() + 360;
					data[fireExists] = true;
					data[areaID] = -10;
					data[fireObject] = CreateDynamicObject(19632, data[fireX], data[fireY], data[fireZ] - 1, 0.0, 0.0, 0.0, interior, vw);
					area = CreateDynamicSphere(data[fireX], data[fireY], data[fireZ], 3.0, interior, vw);
					Streamer_SetArrayData(STREAMER_TYPE_AREA, area, E_STREAMER_EXTRA_ID, data);
					SetPlayerPos(playerid, data[fireX], data[fireY], data[fireZ] + 1.5);
					SendServerMessage(playerid, "Kamp ate�i kurdunuz, art�k �s�nabilir ve bal�k pi�irebilirsiniz.");
				}
				case 38:
				{
					new data[enum_safe], areaid;
					data[safeInterior] = GetPlayerInterior(playerid), data[safeWorld] = GetPlayerVirtualWorld(playerid);
					data[safeOwner] = Character[playerid][Character_SQL];
					data[safeLock] = 0;
					for(new i; i < 10; i++)
					{
						data[safeItems][i] = -1;
						data[safeAmounts][i] = 0;
					}
					data[areaID] = -20;
					data[picklock] = false;
					data[safeExists] = true;
					GetPlayerPos(playerid, data[safeX], data[safeY], data[safeZ]);
					data[safeObject] = CreateDynamicObject(2332, data[safeX], data[safeY], data[safeZ] - 0.5, 0.0, 0.0, 0.0, data[safeInterior], data[safeWorld]);
					areaid = CreateDynamicSphere(data[safeX], data[safeY], data[safeZ], 2.0, data[safeInterior], data[safeWorld]);
					Streamer_SetArrayData(STREAMER_TYPE_AREA, areaid, E_STREAMER_EXTRA_ID, data);
					SetPlayerPos(playerid, data[safeX], data[safeY], data[safeZ] + 1.5);
					new query[300];
					mysql_format(SQL_Handle, query, sizeof(query), "INSERT INTO `safes` (`safe_owner`, `safe_x`, `safe_y`, `safe_z`, `safe_interior`, `safe_world`) VALUES ('%d', '%f', '%f', '%f', '%d', '%d')", data[safeOwner], data[safeX], data[safeY], data[safeZ], data[safeInterior], data[safeWorld]);
					mysql_tquery(SQL_Handle, query, "OnSafeCreated", "ii", areaid, data);
					SendServerMessage(playerid, "Kasa �rettiniz, (/kasa) komutu ile ayarlara eri�ebilirsiniz.");
				}
			}
		}
	}else{
	    SendNearbyMessage(playerid, 20.0, COLOR_LIMEYELLOW, "* %s e�yas�n� �retemedi. (( %s ))", Items[CraftData[item][Craft_Item]][Item_Name], ReturnName(playerid));
	}

    if(CraftData[item][Craft_ItemX] != -1 && CraftData[item][Craft_XAmount] != 0) Inventory_Remove(playerid, CraftData[item][Craft_ItemX], CraftData[item][Craft_XAmount]);
    if(CraftData[item][Craft_ItemY] != -1 && CraftData[item][Craft_YAmount] != 0) Inventory_Remove(playerid, CraftData[item][Craft_ItemY], CraftData[item][Craft_YAmount]);
    if(CraftData[item][Craft_ItemZ] != -1 && CraftData[item][Craft_ZAmount] != 0) Inventory_Remove(playerid, CraftData[item][Craft_ItemZ], CraftData[item][Craft_ZAmount]);

	GiveRandomTalentPoint(playerid, 3, 1);
	TogglePlayerControllable(playerid, true);

	if(found != -1)
	{
		new data[enum_tables];

	    Streamer_GetArrayData(STREAMER_TYPE_AREA, found, E_STREAMER_EXTRA_ID, data);

	    data[tableUsing] = 0;
	    if(IsValidDynamic3DTextLabel(data[tableText])) DestroyDynamic3DTextLabel(data[tableText]);

	    Streamer_SetArrayData(STREAMER_TYPE_AREA, found, E_STREAMER_EXTRA_ID, data);
	    
	    Character[playerid][Character_CraftingTable] = -1;
	}
	return 1;
}

forward OnSafeCreated(area, data[]); public OnSafeCreated(area)
{
	new data[enum_safe];
	Streamer_GetArrayData(STREAMER_TYPE_AREA, area, E_STREAMER_EXTRA_ID, data);
	data[safeID] = cache_insert_id();
	Streamer_SetArrayData(STREAMER_TYPE_AREA, area, E_STREAMER_EXTRA_ID, data);
	return 1;
}

forward Safes_Load(); public Safes_Load()
{
	new rows = cache_num_rows();
	if(rows)
	{
		new id, data[enum_safe], items[100];
		for(new i; i < rows; i++)
		{
			cache_get_value_int(i, "safe_id", data[safeID]);
			cache_get_value_int(i, "safe_owner", data[safeOwner]);
			cache_get_value_float(i, "safe_x", data[safeX]);
			cache_get_value_float(i, "safe_y", data[safeY]);
			cache_get_value_float(i, "safe_z", data[safeZ]);
			cache_get_value_int(i, "safe_interior", data[safeInterior]);
			cache_get_value_int(i, "safe_world", data[safeWorld]);
			cache_get_value_name(i, "safe_password", data[safePassword], 30);
			cache_get_value_int(i, "safe_lock", data[safeLock]);
			cache_get_value_name(i, "safe_items", items, 50);
			data[picklock] = false;
			data[safeExists] = true;
			data[areaID] = -20;
			sscanf(items, "p<|>iiiiiiiiii", data[safeItems][0], data[safeItems][1], data[safeItems][2], data[safeItems][3], data[safeItems][4], data[safeItems][5], data[safeItems][6], data[safeItems][7], data[safeItems][8], data[safeItems][9]);
			cache_get_value_name(i, "safe_amounts", items, 100);
			sscanf(items, "p<|>iiiiiiiiii", data[safeAmounts][0], data[safeAmounts][1], data[safeAmounts][2], data[safeAmounts][3], data[safeAmounts][4], data[safeAmounts][5], data[safeAmounts][6], data[safeAmounts][7], data[safeAmounts][8], data[safeAmounts][9]);
			
			data[safeObject] = CreateDynamicObject(2332, data[safeX], data[safeY], data[safeZ] - 0.5, 0.0, 0.0, 0.0, data[safeInterior], data[safeWorld]);
			id = CreateDynamicSphere(data[safeX], data[safeY], data[safeZ], 2.0, data[safeInterior], data[safeWorld]);
			Streamer_SetArrayData(STREAMER_TYPE_AREA, id, E_STREAMER_EXTRA_ID, data);
		}
		printf("[Safes] Loaded %d safes.", rows);
	}
	else print("[Safes] No content found to upload.");
	return 1;
}

forward Tables_Load(); public Tables_Load()
{
	new rows = cache_num_rows();

	if(rows)
	{
	    new id, data[enum_tables];

	    for(new i; i < rows; i++)
		{
		    cache_get_value_int(i, "table_id", data[tableID]);

		    cache_get_value_float(i, "table_x", data[tableX]);
			cache_get_value_float(i, "table_y", data[tableY]);
			cache_get_value_float(i, "table_z", data[tableZ]);

			cache_get_value_int(i, "table_int", data[tableInterior]);
			cache_get_value_int(i, "table_vw", data[tableVirtualWorld]);

            cache_get_value_int(i, "table_object", data[tableObject]);
			cache_get_value_int(i, "table_type", data[tableType]);

			data[tableUsing] = 0;
			data[tableExists] = true;
			data[areaID] = -30;
			data[tableObjectID] = CreateDynamicObject(data[tableObject], data[tableX], data[tableY], data[tableZ], 0.0, 0.0, 0.0, data[tableInterior], data[tableVirtualWorld]);
			id = CreateDynamicSphere(data[tableX], data[tableY], data[tableZ], 3.0, data[tableInterior], data[tableVirtualWorld]);
			Streamer_SetArrayData(STREAMER_TYPE_AREA, id, E_STREAMER_EXTRA_ID, data);
		}
		printf("[Tables] Loaded %d craft tables.", rows);
	}
	else print("[Tables] No content found to upload.");
	return 1;
}

forward LootPlaces_Load(); public LootPlaces_Load()
{
	new rows = cache_num_rows();

	if(rows)
	{
		new id;

		for(new i = 0; i < rows; i++)
		{
			cache_get_value_int(i, "lp_id", id), LootPlace[id][LP_ID] = id;

			cache_get_value_float(i, "lp_x", LootPlace[id][LP_X]);
			cache_get_value_float(i, "lp_y", LootPlace[id][LP_Y]);
			cache_get_value_float(i, "lp_z", LootPlace[id][LP_Z]);
			cache_get_value_int(i, "lp_int", LootPlace[id][LP_Interior]);
			cache_get_value_int(i, "lp_vw", LootPlace[id][LP_World]);

			cache_get_value_float(i, "lp_inx", LootPlace[id][LP_InX]);
			cache_get_value_float(i, "lp_iny", LootPlace[id][LP_InY]);
			cache_get_value_float(i, "lp_inz", LootPlace[id][LP_InZ]);
			cache_get_value_int(i, "lp_inint", LootPlace[id][LP_InInterior]);
			cache_get_value_int(i, "lp_invw", LootPlace[id][LP_InWorld]);

			cache_get_value_int(i, "lp_type", LootPlace[id][LP_Type]);

			CreateLootPlaceText(id);
			CreateLootPlacePickup(id);

			Iter_Add(lootplace, id);
		}
		printf("[Loot places] Loaded %d loot places.", rows);
	}
	else print("[Loot places] No content found to upload.");
	return 1;
}

forward LootPlaces_Create(playerid, type); public LootPlaces_Create(playerid, type)
{
	new id = Iter_Free(lootplace);

	if(id == -1) return SendErrorMessage(playerid, "Maksimum loot b�lgesine ula��lm��, yenisi olu�turulamaz.");

	GetPlayerPos(playerid, LootPlace[id][LP_X], LootPlace[id][LP_Y], LootPlace[id][LP_Z]);

	LootPlace[id][LP_Interior] = GetPlayerInterior(playerid);
	LootPlace[id][LP_World] = GetPlayerVirtualWorld(playerid);
	LootPlace[id][LP_InX] = LootPlace[id][LP_InY] = LootPlace[id][LP_InZ] = 0.0;
	LootPlace[id][LP_InInterior] = 1;
	LootPlace[id][LP_InWorld] = id + 1000;
	LootPlace[id][LP_Type] = type;
	LootPlace[id][LP_ID] = id;

	Iter_Add(lootplace, id);

	new query[300];
    mysql_format(SQL_Handle, query, sizeof(query), "INSERT INTO `lootplaces` (`lp_id`, `lp_x`, `lp_y`, `lp_z`, `lp_int`, `lp_vw`, `lp_inx`, `lp_iny`, `lp_inz`, `lp_inint`, `lp_invw`, `lp_type`) VALUES ('%d', '%f', '%f', '%f', '%d', '%d', '%f', '%f', '%f', '%d', '%d', '%d')",
		id,
		LootPlace[id][LP_X],
		LootPlace[id][LP_Y],
		LootPlace[id][LP_Z],
		LootPlace[id][LP_Interior],
		LootPlace[id][LP_World],
		LootPlace[id][LP_InX],
		LootPlace[id][LP_InY],
		LootPlace[id][LP_InZ],
		LootPlace[id][LP_InInterior],
		LootPlace[id][LP_InWorld],
		LootPlace[id][LP_Type]
	);
    mysql_tquery(SQL_Handle, query);
    
    LootPlaces_Save(id);
    
    SendServerMessage(playerid, "%d numaral� loot b�lgesi olu�turuldu.", id);
	return 1;
}

forward OnCharacterEndLooting(playerid, type); public OnCharacterEndLooting(playerid, type)
{
    TogglePlayerControllable(playerid, true);
    Character[playerid][Character_LootTimer] = -1;
    ClearAnimations(playerid);

    new item = RandomLootItem(type);

    if(item != -1)
    {
    	new amount = LootItemAmount(item);
    	
    	SendNearbyMessage(playerid, 20.0, COLOR_GREEN, "* %s e�yas�ndan %d adet buldu. (( %s ))", Items[item][Item_Name], amount, ReturnName(playerid));
    	
    	if(!IsCharacterCanGetThisItem(playerid, item, amount))
    	{
			DroppedItem_Create(playerid, item, amount, 0);
			return SendErrorMessage(playerid, "Envanterinizde yer olmad��� i�in e�ya yere at�ld�.");
    	}

		Inventory_AddItem(playerid, item, amount);
	}else{
	    SendNearbyMessage(playerid, 20.0, COLOR_LIMEYELLOW, "* Hi�bir �ey bulamad�. (( %s ))", ReturnName(playerid));
	}
	return 1;
}

forward FillingCan(playerid); public FillingCan(playerid)
{
	TogglePlayerControllable(playerid, true);
	ClearAnimations(playerid);

	Inventory_Remove(playerid, 45, 1);
	Character[playerid][Character_FillTimer] = -1;

    if(!IsCharacterCanGetThisItem(playerid, 46, 1))
    {
		DroppedItem_Create(playerid, 46, 1, 0);
		return SendErrorMessage(playerid, "Envanterinizde yer olmad��� i�in dolu benzin bidonu yere at�ld�.");
  	}

	Inventory_AddItem(playerid, 46, 1);
	SendServerMessage(playerid, "Benzin, bidona dolduruldu. (/envanter)");
	return 1;
}

forward DeleteInfoBox(playerid); public DeleteInfoBox(playerid)
{
	PlayerTextDrawHide(playerid, Character[playerid][InfoBox]);

	Character[playerid][Box_Show] = false;
	Character[playerid][Character_BoxTimer] = -1;
	return 1;
}

forward Tents_Load(); public Tents_Load()
{
	new rows = cache_num_rows();

	if(rows)
	{
		new id;

		for(new i = 0; i < rows; i++)
		{
			cache_get_value_int(i, "tent_id", id), Tent[id][Tent_ID] = id;

			cache_get_value_float(i, "tent_x", Tent[id][Tent_X]);
			cache_get_value_float(i, "tent_y", Tent[id][Tent_Y]);
			cache_get_value_float(i, "tent_z", Tent[id][Tent_Z]);
			cache_get_value_float(i, "tent_rx", Tent[id][Tent_rX]);
			cache_get_value_float(i, "tent_ry", Tent[id][Tent_rY]);
			cache_get_value_float(i, "tent_rz", Tent[id][Tent_rZ]);
			cache_get_value_int(i, "tent_int", Tent[id][Tent_Interior]);
			cache_get_value_int(i, "tent_vw", Tent[id][Tent_World]);

			cache_get_value_float(i, "tent_inx", Tent[id][Tent_InX]);
			cache_get_value_float(i, "tent_iny", Tent[id][Tent_InY]);
			cache_get_value_float(i, "tent_inz", Tent[id][Tent_InZ]);
			cache_get_value_int(i, "tent_inint", Tent[id][Tent_InInterior]);
			cache_get_value_int(i, "tent_invw", Tent[id][Tent_InWorld]);
			
			cache_get_value_int(i, "tent_lock", Tent[id][Tent_Lock]);
			cache_get_value_int(i, "tent_owner", Tent[id][Tent_Owner]);
			
			Tent_Objects(id);

			Iter_Add(tent, id);
		}
		printf("[Tents] Loaded %d tents.", rows);
	}
	else print("[Tents] No content found to upload.");
	return 1;
}

forward PlaceTent(playerid); public PlaceTent(playerid)
{
    Character[playerid][Character_TentTimer] = -1;
    ClearAnimations(playerid);
    
    Inventory_Remove(playerid, 49, 1);

    Tent_Create(playerid);
	return 1;
}

Tent_Save(id, bool:obj = false)
{
	if(!Iter_Contains(tent, id)) return 1;

	new query[400];

	mysql_format(SQL_Handle, query, sizeof(query), "UPDATE `tents` SET `tent_x` = '%f', `tent_y` = '%f', `tent_z` = '%f', `tent_int` = '%d', `tent_vw` = '%d', `tent_inx` = '%f', `tent_iny` = '%f', `tent_inz` = '%f', `tent_inint` = '%d', `tent_invw` = '%d', `tent_lock` = '%d', `tent_owner` = '%d', `tent_rx` = '%f', `tent_ry` = '%f', `tent_rz` = '%f' WHERE `tent_id` = '%d'",
		Tent[id][Tent_X],
		Tent[id][Tent_Y],
		Tent[id][Tent_Z],
		Tent[id][Tent_Interior],
		Tent[id][Tent_World],
		Tent[id][Tent_InX],
		Tent[id][Tent_InY],
		Tent[id][Tent_InZ],
		Tent[id][Tent_InInterior],
		Tent[id][Tent_InWorld],
		Tent[id][Tent_Lock],
		Tent[id][Tent_Owner],
		Tent[id][Tent_rX],
		Tent[id][Tent_rY],
		Tent[id][Tent_rZ],
		id
	);
	mysql_tquery(SQL_Handle, query);

	if(obj) Tent_Objects(id);
	return 1;
}

/*Dialogs*/
Dialog:DIALOG_UNUSED(playerid, response, listitem, inputtext[]) return 1;

Dialog:DIALOG_REGISTER(playerid, response, listitem, inputtext[])
{
	if(!response) return Kick(playerid);
	if(response)
	{
		if(strlen(inputtext) < MIN_PASSCHAR || strlen(inputtext) > MAX_PASSCHAR)
			return Dialog_Show(playerid, DIALOG_REGISTER, DIALOG_STYLE_PASSWORD, "Zombieland Role Play", "{FFFFFF}%s, {CC9966}�ifreniz %d karakterden az, %d karakterden fazla olamaz. {FFFFFF}L�tfen ge�erli bir �ifre olu�turun.", "Kay�t", "��k��", Account[playerid][Account_Name], MIN_PASSCHAR, MAX_PASSCHAR);
	
		strcpy(Account[playerid][Account_Password], inputtext, 128);

		new query[234];
		mysql_format(SQL_Handle, query, sizeof(query), "INSERT INTO `accounts` (`account_name`, `account_password`) VALUES ('%e', '%e')", Account[playerid][Account_Name], Account[playerid][Account_Password]);
		mysql_tquery(SQL_Handle, query, "OnAccountRegister", "d", playerid);
	}
	return 1;
}

Dialog:DIALOG_LOGIN(playerid, response, listitem, inputtext[])
{
	if(!response) return Kick(playerid);
	if(response)
	{
		if(strcmp(inputtext, Account[playerid][Account_Password]) == 0 && strlen(inputtext) == strlen(Account[playerid][Account_Password]))
		{
			KillTimer(Account[playerid][Account_LoginTimer]);
			Account[playerid][Account_LoginTimer] = -1;

			cache_set_active(Account[playerid][Account_CacheID]);
			
			GetAccountData(playerid);
			
			cache_delete(Account[playerid][Account_CacheID]);
			Account[playerid][Account_CacheID] = MYSQL_INVALID_CACHE;

			Account[playerid][Account_IsLogged] = true;
			SendServerMessage(playerid, "Ba�ar�yla giri� yapt�n�z.");
			ShowAccountMainMenu(playerid);
			
			if(Account[playerid][Account_Staff] > 0) SendClientMessageEx(playerid, COLOR_CLIENT, "Y�netici yetkiniz %s(%d) olarak tan�mland�.", GetAdminLevel(playerid), Account[playerid][Account_Staff]);
		}else{
		    Account[playerid][Account_LoginAttempts]++;
		    if(Account[playerid][Account_LoginAttempts] == MAX_LATTEMPT)
		    {
		        Dialog_Show(playerid, DIALOG_UNUSED, DIALOG_STYLE_MSGBOX, "Zombieland Role Play", "{FFFFFF}�ifrenizi {CC9966}%d kez {FFFFFF}yanl�� girdi�iniz i�in sunucudan uzakla�t�r�ld�n�z.", "x", "", MAX_LATTEMPT);
				KickEx(playerid);
			}else{
			    Dialog_Show(playerid, DIALOG_LOGIN, DIALOG_STYLE_PASSWORD, "Zombieland Role Play", "{FFFFFF}Hatal� �ifre girdiniz, {CC9966}%s{FFFFFF}.\nL�tfen do�ru �ifreyi kutucu�a yaz�n ve giri� yap�n. {CC9966}%d giri� yapma hakk�n�z {FFFFFF}kald�.", "giri�", "��k��", Account[playerid][Account_Name], MAX_LATTEMPT-Account[playerid][Account_LoginAttempts]);
			}
		}	
	}
	return 1;
}

Dialog:DIALOG_MAIN(playerid, response, listitem, inputtext[])
{
	if(!response) return Kick(playerid);
	if(response)
	{
		if(!strcmp(inputtext, "> Hesap bilgimi g�r�nt�le.", true))
			return ShowAccountStats(playerid, playerid);
		else if(!strcmp(inputtext, "> Karakterlerimi listele.", true))
			return ListAccountCharacters(playerid);
		else if(!strcmp(inputtext, "> Yeni karakter olu�tur.", true))
			return CreateCharacter(playerid);
	}
	return 1;
}

Dialog:DIALOG_ACCSTATS(playerid, response, listitem, inputtext[])
{
	if(!Account[playerid][Account_IsPlaying])
		ShowAccountMainMenu(playerid);
	else
	    pc_cmd_hesap(playerid);
	return 1;
}

Dialog:DIALOG_CHARACTERS(playerid, response, listitem, inputtext[])
{
	if(!response) return ShowAccountMainMenu(playerid);
	if(response) return LoadCharacterData(playerid, inputtext);
	return 1;
}

Dialog:DIALOG_CHARACTERS_CREATE(playerid, response, listitem, inputtext[])
{
	if(!response) return ShowAccountMainMenu(playerid);
	if(response)
	{
		if(isnull(inputtext)) return CreateCharacter(playerid);
		if(strlen(inputtext) > 24) return CreateCharacter(playerid);

		switch(IsRoleplayName(inputtext))
		{
	        case ROLEPLAY_NAME_FALSE:
	        	return CreateCharacter(playerid);
	        case ROLEPLAY_NAME_TRUE:
	        {
				if(CheckPlayerCharacters(playerid, inputtext))
				{
				    SendErrorMessage(playerid, "Daha �nce bu isimde bir karakter olu�turmu�sunuz.");
				    Dialog_Show(playerid, DIALOG_CHARACTERS_CREATE, DIALOG_STYLE_INPUT, "Zombieland Role Play", "Olu�turmak istedi�iniz karakterin ad�n� girin.\nBu isim en fazla 24 karakter i�erebilir ve Role Play ad format�na uygun olmal�d�r. {CC9966}(�sim_Soyisim)", "ileri", "vazge�");
				    return 1;
				}

				new query[120];
				mysql_format(SQL_Handle, query, sizeof(query), "INSERT INTO `characters` (`char_name`, `char_accountsql`) VALUES ('%e', '%d')", inputtext, Account[playerid][Account_SQL]);
				mysql_tquery(SQL_Handle, query, "OnCharacterRegister", "d", playerid);
	        }
	        case ROLEPLAY_NAME_UNCAPPED:
				return CreateCharacter(playerid);
	        case ROLEPLAY_NAME_CONTAINS_NUMBERS:
				return CreateCharacter(playerid);		
		}
	}
	return 1;
}

Dialog:DIALOG_GENDER(playerid, response, listitem, inputtext[])
{
	Character[playerid][Character_Gender] = (!response) ? GENDER_FEMALE : GENDER_MALE;
	Dialog_Show(playerid, DIALOG_AGE, DIALOG_STYLE_INPUT, "Zombieland Roleplay", "{FFFFFF}Karakterinizin cinsiyeti {CC9966}%s {FFFFFF}olarak belirlendi.\nKarakterinizin ya��n� belirleyin.\n{CC9966}Girilen ya� de�eri minimum %d, maksimum %d olabilir.", "ileri", "��k��", GetGender(playerid), MIN_AGE, MAX_AGE);
	return 1;
}

Dialog:DIALOG_AGE(playerid, response, listitem, inputtext[])
{
	if(!response) return Kick(playerid);
	if(response)
	{
		if(isnull(inputtext)) return Dialog_Show(playerid, DIALOG_AGE, DIALOG_STYLE_INPUT, "Zombieland Roleplay", "{FFFFFF}Karakterinizin cinsiyeti {CC9966}%s {FFFFFF}olarak belirlendi.\nKarakterinizin ya��n� belirleyin.\n{CC9966}Girilen ya� de�eri minimum %d, maksimum %d olabilir.", "ileri", "��k��", GetGender(playerid), MIN_AGE, MAX_AGE);

		new age = strval(inputtext);

		if(age < MIN_AGE || age > MAX_AGE) return Dialog_Show(playerid, DIALOG_AGE, DIALOG_STYLE_INPUT, "Zombieland Roleplay", "{FFFFFF}Karakterinizin cinsiyeti {CC9966}%s {FFFFFF}olarak belirlendi.\nKarakterinizin ya��n� belirleyin.\n{CC9966}Girilen ya� de�eri minimum %d, maksimum %d olabilir.", "ileri", "��k��", GetGender(playerid), MIN_AGE, MAX_AGE);

		Character[playerid][Character_Age] = age;
		SendServerMessage(playerid, "Karakterinizin ya�� %d olarak belirlendi. Karakterinizin mesle�ini se�in.", age);
		
		Dialog_Show(playerid, DIALOG_JOB, DIALOG_STYLE_LIST, "{CC9966}Mesle�inizi se�in:", "Asker\nPolis\nMekanik\nDoktor\nHem�ire\nA���\nZanaatkar\nM�hendis", "ileri", "��k��");
	}
	return 1;
}

Dialog:DIALOG_JOB(playerid, response, listitem, inputtext[])
{
    if(!response) return Kick(playerid);
    if(response)
    {
        if(listitem == JOB_SOLDIER || listitem == JOB_POLICE || listitem == JOB_DOCTOR || listitem == JOB_NURSE || listitem == JOB_ENGINEER)
        {
            if(Character[playerid][Character_Age] < 22)
            {
                SendErrorMessage(playerid, "Bu mesle�i se�mek i�in 22 ya� veya �zerinde olmal�s�n�z.");
                Dialog_Show(playerid, DIALOG_JOB, DIALOG_STYLE_LIST, "{CC9966}Mesle�inizi se�in:", "Asker\nPolis\nMekanik\nDoktor\nHem�ire\nA���\nZanaatkar\nM�hendis", "�leri", "��k��");
                return 1;
            }
        }
        
		Character[playerid][Character_Job] = listitem;

		switch(listitem)
		{
			case JOB_SOLDIER: Character[playerid][Talent_Aim] += 30;
			case JOB_POLICE: Character[playerid][Talent_Aim] += 25;
			case JOB_MECHANIC: Character[playerid][Talent_Mechanic] += 30;
			case JOB_DOCTOR: Character[playerid][Talent_FirstAid] += 30;
			case JOB_NURSE: Character[playerid][Talent_FirstAid] += 20;
			case JOB_CHEF: Character[playerid][Talent_Cooking] += 30;
			case JOB_ARTISAN: Character[playerid][Talent_Crafting] += 25;
			case JOB_ENGINEER: Character[playerid][Talent_Crafting] += 30;
		}
		SendServerMessage(playerid, "Karakterinizin ge�mi� mesle�i %s olarak belirlendi.", GetJob(playerid));
		Dialog_Show(playerid, DIALOG_ACTIVITY, DIALOG_STYLE_LIST, "{CC9966}Aktivite se�in:", "Bal�k tutmak\nAvc�l�k\nAirsoft\n�zcilik\nTreking\nEl sanatlar�\nTamirat\nOk�uluk\nAraba restorasyonu", "�leri", "��k��");
    }
	return 1;
}

Dialog:DIALOG_ACTIVITY(playerid, response, listitem, inputtext[])
{
    if(!response) return Kick(playerid);
    if(response)
    {
		switch(listitem)
		{
			case 0:
			{
				Character[playerid][Talent_Fishing] += 30;
				Character[playerid][Talent_Cooking] += 10;
			}
			case 1:
			{
				Character[playerid][Talent_Aim] += 20;
				Character[playerid][Talent_Cooking] += 10;
			}
			case 2:
			{
				Character[playerid][Talent_Aim] += 25;
			}
			case 3:
			{
				Character[playerid][Talent_Cooking] += 20;
				Character[playerid][Talent_FirstAid] += 15;
				Character[playerid][Talent_Crafting] += 15;
			}
			case 4:
			{
				Character[playerid][Talent_FirstAid] += 10;
				Character[playerid][Talent_Cooking] += 10;
				Character[playerid][Talent_Crafting] += 10;
			}
			case 5:
			{
				Character[playerid][Talent_Crafting] += 25;
			}
			case 6:
			{
				Character[playerid][Talent_Crafting] += 15;
				Character[playerid][Talent_Mechanic] += 15;
			}
			case 7:
			{
				Character[playerid][Talent_Aim] += 25;
			}
			case 8:
			{
				Character[playerid][Talent_Mechanic] += 25;
			}
		}
		Character[playerid][Character_Configured] = 1;
		UpdateCharacter(playerid);
		
		Dialog_Show(playerid, DIALOG_CHARACTER_FINAL, DIALOG_STYLE_MSGBOX, "Zombieland Roleplay",
		"Karakter yap�land�r�lmas� tamamland�.\n\n{CC9966}Karakter ad�: {FFFFFF}%s\n{CC9966}Cinsiyet: {FFFFFF}%s\n{CC9966}Ya�: {FFFFFF}%d\n{CC9966}Meslek: {FFFFFF}%s\n\n{CC9966}Yetenek d�zeyi:\n\n{9999FF}Mekanik: {FFFFFF}%d/%d\n{9999FF}Bal�k��l�k: {FFFFFF}%d/%d\n{9999FF}Ni�anc�l�k: {FFFFFF}%d/%d\n{9999FF}�retim: {FFFFFF}%d/%d\n{9999FF}�lkyard�m: {FFFFFF}%d/%d\n{9999FF}Yemek pi�irme: {FFFFFF}%d/%d\n\n{FFFFFF}> Karakterinize giri� yapabilirsiniz.",
		"giri�", "",
			Character[playerid][Character_Name],
			GetGender(playerid),
			Character[playerid][Character_Age],
			GetJob(playerid),
			Character[playerid][Talent_Mechanic], LIMIT_TALENT,
			Character[playerid][Talent_Fishing], LIMIT_TALENT,
			Character[playerid][Talent_Aim], LIMIT_TALENT,
			Character[playerid][Talent_Crafting], LIMIT_TALENT,
			Character[playerid][Talent_FirstAid], LIMIT_TALENT,
			Character[playerid][Talent_Cooking], LIMIT_TALENT
		);
    }
	return 1;
}

Dialog:DIALOG_CHARACTER_FINAL(playerid, response, listitem, inputtext[]) return LoadCharacterData(playerid, Character[playerid][Character_Name]);

Dialog:DIALOG_SETTINGS(playerid, response, listitem, inputtext[])
{
	if(response)
	{
	    if(listitem == 0)
	    {
			if(Account[playerid][Settings_Pm] == 0)
			    Account[playerid][Settings_Pm] = 1;
			else
			    Account[playerid][Settings_Pm] = 0;
	    }
	    else if(listitem == 1)
	    {
			if(Account[playerid][Settings_OOC] == 0)
			    Account[playerid][Settings_OOC] = 1;
			else
			    Account[playerid][Settings_OOC] = 0;
	    }
	    
	    UpdateAccount(playerid);
	    pc_cmd_ayarlar(playerid);
	}
	return 1;
}

Dialog:DIALOG_ACCOUNT(playerid, response, listitem, inputtext[])
{
	if(response)
	{
		if(listitem == 0)
			return ShowAccountStats(playerid, playerid);
		else if(listitem == 1)
			Dialog_Show(playerid, DIALOG_CHANGEPASS, DIALOG_STYLE_PASSWORD, "�ifre de�i�tir", "�ifrenizi de�i�tirmek i�in mevcut �ifrenizi girin:", "ileri", "vazge�");
	}
	return 1;
}

Dialog:DIALOG_CHANGEPASS(playerid, response, listitem, inputtext[])
{
	if(!response) return pc_cmd_hesap(playerid);
	if(response)
	{
		if(strcmp(inputtext, Account[playerid][Account_Password]) == 0 && strlen(inputtext) == strlen(Account[playerid][Account_Password]))
			Dialog_Show(playerid, DIALOG_CHANGEPASS2, DIALOG_STYLE_INPUT, "�ifre de�i�tir", "Yeni �ifrenizi giriniz:", "ileri", "vazge�");
		else
			Dialog_Show(playerid, DIALOG_CHANGEPASS, DIALOG_STYLE_INPUT, "�ifre de�i�tir", "Hatal� �ifre girdiniz!\n�ifrenizi de�i�tirmek i�in mevcut �ifrenizi giriniz:", "ileri", "vazge�");
	}
	return 1;
}

Dialog:DIALOG_CHANGEPASS2(playerid, response, listitem, inputtext[])
{
	if(!response) return pc_cmd_hesap(playerid);
	if(response)
	{
		if(strlen(inputtext) < MIN_PASSCHAR || strlen(inputtext) > MAX_PASSCHAR)
			return Dialog_Show(playerid, DIALOG_CHANGEPASS2, DIALOG_STYLE_INPUT, "�ifre de�i�tir", "{FFFFFF}%s, {CC9966}�ifreniz %d karakterden az, %d karakterden fazla olamaz. {FFFFFF}L�tfen ge�erli bir �ifre giriniz:", "ileri", "vazge�", Account[playerid][Account_Name], MIN_PASSCHAR, MAX_PASSCHAR);

        if(strcmp(inputtext, Account[playerid][Account_Password]) == 0 && strlen(inputtext) == strlen(Account[playerid][Account_Password]))
            return Dialog_Show(playerid, DIALOG_CHANGEPASS2, DIALOG_STYLE_INPUT, "�ifre de�i�tir", "{FFFFFF}%s, {CC9966}�ifreniz eskisiyle ayn� olamaz. {FFFFFF}L�tfen ge�erli bir �ifre giriniz:", "ileri", "vazge�", Account[playerid][Account_Name]);
	
		strcpy(Account[playerid][Account_Password], inputtext, 128);

		new query[220];
		mysql_format(SQL_Handle, query, sizeof(query), "UPDATE `accounts` SET `account_password` = '%e' WHERE `account_sql` = '%d'",
            Account[playerid][Account_Password],
			Account[playerid][Account_SQL]
		);

		mysql_tquery(SQL_Handle, query);
		SendServerMessage(playerid, "�ifreniz ba�ar�yla de�i�tirildi.");
	}
	return 1;
}

Dialog:DIALOG_INVENTORY(playerid, response, listitem, inputtext[])
{
	if(response)
	{
		new slot = strval(inputtext);
		SetPVarInt(playerid, "InvSlot", slot);
		new header[40];
		format(header, sizeof(header), "E�ya: %s (%d adet)", Items[Inventory[playerid][slot][Inventory_Item]][Item_Name], Inventory[playerid][slot][Inventory_Amount]);
		Dialog_Show(playerid, DIALOG_INVENTORY_OPTION, DIALOG_STYLE_LIST, header, "> Kullan.\n> Ver.\n> Yere b�rak.", "Se�", "Geri");
	}
	return 1;
}

Dialog:DIALOG_INVENTORY_OPTION(playerid, response, listitem, inputtext[])
{
	if(response)
	{
		switch(listitem)
		{
			case 0:
			{
				UseItem(playerid, GetPVarInt(playerid, "InvSlot"));
				DeletePVar(playerid, "InvSlot");
			}
			case 1:
				Dialog_Show(playerid, DIALOG_INVENTORY_GIVE, DIALOG_STYLE_INPUT, "E�ya Ver", "{FFFFFF}L�tfen vermek istedi�iniz miktar� girin:", "�leri", "Geri");
			case 2:
				Dialog_Show(playerid, DIALOG_INVENTORY_PUT, DIALOG_STYLE_INPUT, "Yere b�rak", "{FFFFFF}L�tfen yere atmak istedi�iniz miktar� girin:", "At", "Geri");
		}
	}else{
		DeletePVar(playerid, "InvSlot");
		pc_cmd_envanter(playerid);
	}
	return 1;
}

Dialog:DIALOG_INVENTORY_PUT(playerid, response, listitem, inputtext[])
{
	if(response)
	{
		new amount = strval(inputtext), slot = GetPVarInt(playerid, "InvSlot");
		if(amount <= 0 || amount > Inventory[playerid][slot][Inventory_Amount]) return Dialog_Show(playerid, DIALOG_INVENTORY_PUT, DIALOG_STYLE_INPUT, "Yere b�rak", "{ff0000}Ge�ersiz miktar girdiniz.\n \n{FFFFFF}L�tfen yere atmak istedi�iniz miktar� girin:", "At", "Geri");
		
		new item = Inventory[playerid][slot][Inventory_Item];
		new area = Character[playerid][Character_Area];
		if(area != -1 && Character[playerid][Character_AreaType] == 2)
		{
			new data[enum_safe], found = false;
			Streamer_GetArrayData(STREAMER_TYPE_AREA, area, E_STREAMER_EXTRA_ID, data);
			if(data[safeID] > 0 && data[safeExists] == true && data[safeLock] != 2)
			{
				for(new i; i < 10; i++)
				{
					if(data[safeItems][i] == -1)
					{
							data[safeItems][i] = item;
							data[safeAmounts][i] = amount;
							found = true;
							break;
					}
				}
				if(found)
				{
						Streamer_SetArrayData(STREAMER_TYPE_AREA, area, E_STREAMER_EXTRA_ID, data);
						Inventory_Remove(playerid, item, amount);
						SendServerMessage(playerid, "%s adl� e�yay� kasaya b�rakt�n�z.", Items[item][Item_Name]);
						return Safe_Save(area);
				}
				else return SendErrorMessage(playerid, "Kasada yer yok.");
			}
		}
		
		Inventory_Remove(playerid, item, amount);
		DroppedItem_Create(playerid, item, amount, 1);
		SendServerMessage(playerid, "%s adl� e�yay� yere b�rakt�n�z.", Items[item][Item_Name]);
		DeletePVar(playerid, "InvSlot");
	}
	else Dialog_Show(playerid, DIALOG_INVENTORY_OPTION, DIALOG_STYLE_LIST, "E�ya", "> Kullan.\n> Ver.\n> Yere b�rak.", "Se�", "Geri");
	return 1;
}

Dialog:DIALOG_INVENTORY_GIVE(playerid, response, listitem, inputtext[])
{
	if(response)
	{
		if(isnull(inputtext)) return Dialog_Show(playerid, DIALOG_INVENTORY_GIVE, DIALOG_STYLE_INPUT, "E�ya Ver", "{FFFFFF}L�tfen vermek istedi�iniz miktar� girin:", "�leri", "Geri");
		new amount = strval(inputtext), slot = GetPVarInt(playerid, "InvSlot");
		if(amount < 1 || amount > Inventory[playerid][slot][Inventory_Amount]) return Dialog_Show(playerid, DIALOG_INVENTORY_GIVE, DIALOG_STYLE_INPUT, "E�ya Ver", "{ff0000}Ge�ersiz miktar girdiniz.\n \n{FFFFFF}L�tfen vermek istedi�iniz miktar� girin:", "�leri", "Geri");

		SetPVarInt(playerid, "InvAmount", amount);
		Dialog_Show(playerid, DIALOG_INVENTORY_GIVET, DIALOG_STYLE_INPUT, "E�ya Ver", "{FFFFFF}L�tfen e�yay� vermek istedi�iniz ki�inin ID'sini girin:", "�leri", "Geri");
		}else{
		Dialog_Show(playerid, DIALOG_INVENTORY_OPTION, DIALOG_STYLE_LIST, "E�ya", "> Kullan.\n> Ver.\n> Yere b�rak.", "Se�", "Geri");
	}
	return 1;
}

Dialog:DIALOG_INVENTORY_GIVET(playerid, response, listitem, inputtext[])
{
	if(response)
	{
		if(isnull(inputtext)) return Dialog_Show(playerid, DIALOG_INVENTORY_GIVET, DIALOG_STYLE_INPUT, "E�ya Ver", "{FFFFFF}L�tfen e�yay� vermek istedi�iniz ki�inin ID'sini girin:", "�leri", "Geri");
		new target = strval(inputtext);
		if(target == playerid) return Dialog_Show(playerid, DIALOG_INVENTORY_GIVET, DIALOG_STYLE_INPUT, "E�ya Ver", "{ff0000}Kendine e�ya veremezsin.\n \n{FFFFFF}L�tfen e�yay� vermek istedi�iniz ki�inin ID'sini girin:", "�leri", "Geri");
		if(!IsPlayerConnected(target)) return Dialog_Show(playerid, DIALOG_INVENTORY_GIVET, DIALOG_STYLE_INPUT, "E�ya Ver", "{ff0000}Ge�ersiz ID girdiniz.\n \n{FFFFFF}L�tfen e�yay� vermek istedi�iniz ki�inin ID'sini girin:", "�leri", "Geri");
		if(!Account[target][Account_IsPlaying])	return Dialog_Show(playerid, DIALOG_INVENTORY_GIVET, DIALOG_STYLE_INPUT, "E�ya Ver", "{ff0000}Ki�i giri� yapmam��.\n \n{FFFFFF}L�tfen e�yay� vermek istedi�iniz ki�inin ID'sini girin:", "�leri", "Geri");
		if(!IsPlayerNearPlayer(playerid, target, 5.0)) return Dialog_Show(playerid, DIALOG_INVENTORY_GIVET, DIALOG_STYLE_INPUT, "E�ya Ver", "{ff0000}Ki�iye yeterince yak�n de�ilsiniz.\n \n{FFFFFF}L�tfen e�yay� vermek istedi�iniz ki�inin ID'sini girin:", "�leri", "Geri");
		new slot = GetPVarInt(playerid, "InvSlot"), amount = GetPVarInt(playerid, "InvAmount");
		if(!IsCharacterCanGetThisItem(target, Inventory[playerid][slot][Inventory_Item], amount)) return Dialog_Show(playerid, DIALOG_INVENTORY_GIVET, DIALOG_STYLE_INPUT, "E�ya Ver", "{ff0000}Ki�inin envanteri dolu, daha fazla e�ya alamaz.\n \n{FFFFFF}L�tfen e�yay� vermek istedi�iniz ki�inin ID'sini girin:", "�leri", "Geri");
		Inventory_AddItem(target, Inventory[playerid][slot][Inventory_Item], amount);
		Inventory_Remove(playerid, Inventory[playerid][slot][Inventory_Item], amount);
		
		new string[90];
		format(string, sizeof(string), "%s adl� ki�iye %d adet %s verir.", ReturnName(target), amount, Items[Inventory[playerid][slot][Inventory_Item]][Item_Name]);
		pc_cmd_ame(playerid, string);
	}
	else
	{
		DeletePVar(playerid, "InvAmount");
		Dialog_Show(playerid, DIALOG_INVENTORY_GIVE, DIALOG_STYLE_INPUT, "E�ya Ver", "{FFFFFF}L�tfen vermek istedi�iniz miktar� girin:", "�leri", "Geri");
	}
	return 1;
}

Dialog:DIALOG_DROPPEDITEMS(playerid, response, listitem, inputtext[])
{
	if(response)
	{
		new id = strval(inputtext), data[enum_droppeditems];
		if(!IsValidDynamicRaceCP(id)) return SendErrorMessage(playerid, "Bu e�ya art�k yok.");
		Streamer_GetArrayData(STREAMER_TYPE_RACE_CP, id, E_STREAMER_EXTRA_ID, data);
		if(IsCharacterCanGetThisItem(playerid, data[DroppedItem_Item], data[DroppedItem_Amount]))
		{	
			new query[60];
			Inventory_AddItem(playerid, data[DroppedItem_Item], data[DroppedItem_Amount]);
			SendServerMessage(playerid, "%s adl� e�yay� ald�n�z.", Items[data[DroppedItem_Item]][Item_Name]);
			if(!data[DroppedItem_Owned])
			{
				data[DroppedItem_SpawnTime] = gettime() + 3600;
				Streamer_SetIntData(STREAMER_TYPE_OBJECT, data[DroppedItem_Object], E_STREAMER_WORLD_ID, 100);
				Streamer_SetIntData(STREAMER_TYPE_3D_TEXT_LABEL, data[DroppedItem_Text], E_STREAMER_WORLD_ID, 100);
				Streamer_SetArrayData(STREAMER_TYPE_RACE_CP, id, E_STREAMER_EXTRA_ID, data);
			}
			else
			{
				DestroyDynamicObject(data[DroppedItem_Object]);
				DestroyDynamic3DTextLabel(data[DroppedItem_Text]);
				DestroyDynamicRaceCP(id);
				format(query, sizeof(query), "DELETE FROM dropped_items WHERE ditem_id = %d", data[DroppedItem_ID]);
				mysql_tquery(SQL_Handle, query);
				data[DroppedItem_ID] = 0;
				data[DroppedItem_Item] = 0;
				data[DroppedItem_Amount] = 0;
			}
		}
		else SendErrorMessage(playerid, "Envanteriniz dolu, e�yay� alamazs�n�z.");
		
	}
	return 1;
}

Dialog:DIALOG_AIRDROP(playerid, response, listitem, inputtext[])
{
	if(response)
	{
		new id = GetPVarInt(playerid, "AirdropID");
		if(!Airdrop[id][Airdrop_Exists]) return 1;
		new item = Airdrop[id][Airdrop_Items][listitem];
		if(item == -1) return SendErrorMessage(playerid, "Bu e�ya ba�kas� taraf�ndan al�nd�."), Airdrop_List(playerid);
		if(!IsCharacterCanGetThisItem(playerid, item, 1)) return SendErrorMessage(playerid, "Envanteriniz dolu, bu e�yay� alamazs�n�z."), DeletePVar(playerid, "AirdropID");
		Airdrop[id][Airdrop_Items][listitem] = -1;
		Inventory_AddItem(playerid, item, 1);
		SendServerMessage(playerid, "%s adl� e�yay� ald�n�z.", Items[item][Item_Name]);
		DeletePVar(playerid, "AirdropID");
		Airdrop_List(playerid);
	}
	return 1;
}

Dialog:DIALOG_EDIT_BONE(playerid, response, listitem, inputtext[])
{
	if(response)
    {
    	new weaponid = EditingWeapon[playerid], weaponname[18], string[150];

        GetWeaponName(weaponid, weaponname, sizeof(weaponname));

        WeaponSettings[playerid][weaponid - 22][Bone] = listitem + 1;

        SendServerMessage(playerid, "%s silah�n�n kemik yap�s�n� de�i�tirdiniz.", weaponname);

        mysql_format(SQL_Handle, string, sizeof(string), "INSERT INTO weaponsettings (Owner, WeaponID, Bone) VALUES ('%d', %d, %d) ON DUPLICATE KEY UPDATE Bone = VALUES(Bone)", Character[playerid][Character_SQL], weaponid, listitem + 1);
        mysql_tquery(SQL_Handle, string);
	}
	
 	EditingWeapon[playerid] = 0;
	return 1;
}

Dialog:DIALOG_SAFE(playerid, response, listitem, inputtext[])
{
	if(response)
	{
		new area = Character[playerid][Character_Area];
		if(area == -1) return 1;
		new data[enum_safe];
		Streamer_GetArrayData(STREAMER_TYPE_AREA, area, E_STREAMER_EXTRA_ID, data);
		if(data[safeItems][listitem] == -1) return SendErrorMessage(playerid, "Bu slot bo�."), Safe_Items(playerid, area);
		if(!IsCharacterCanGetThisItem(playerid, data[safeItems][listitem], data[safeAmounts][listitem])) return SendErrorMessage(playerid, "Envanteriniz dolu, bu e�yay� alamazs�n�z."), Safe_Items(playerid, area);
		SendServerMessage(playerid, "%s adl� e�yay� kasadan ald�n�z.", Items[data[safeItems][listitem]][Item_Name]);
		Inventory_AddItem(playerid, data[safeItems][listitem], data[safeAmounts][listitem]);
		data[safeItems][listitem] = -1;
		data[safeAmounts][listitem] = 0;
		Streamer_SetArrayData(STREAMER_TYPE_AREA, area, E_STREAMER_EXTRA_ID, data);
		Safe_Save(area);
		Safe_Items(playerid, area);
	}
	return 1;
}

Dialog:DIALOG_SAFE_SET_PASSWORD(playerid, response, listitem, inputtext[])
{
	if(response)
	{
		new area = Character[playerid][Character_Area];
		if(area == -1) return 1;
		new data[enum_safe];
		Streamer_GetArrayData(STREAMER_TYPE_AREA, area, E_STREAMER_EXTRA_ID, data); 
		strcpy(data[safePassword], inputtext, 30);
		Streamer_SetArrayData(STREAMER_TYPE_AREA, area, E_STREAMER_EXTRA_ID, data);
		Safe_Save(area);
		SendServerMessage(playerid, "Kasan�n �ifresi de�i�tirildi.");
	}
	return 1;
}

Dialog:DIALOG_SAFE_PASSWORD(playerid, response, listitem, inputtext[])
{
	if(response)
	{
		new area = Character[playerid][Character_Area];
		if(area == -1) return 1;
		if(isnull(inputtext)) return Dialog_Show(playerid, DIALOG_SAFE_PASSWORD, DIALOG_STYLE_INPUT, "�ifre", "{FFFFFF}Bu kasa i�in �ifre belirlenmi�, �ifreyi giriniz:", "Devam", "Kapat");
		new data[enum_safe];
		Streamer_GetArrayData(STREAMER_TYPE_AREA, area, E_STREAMER_EXTRA_ID, data); 
		if(!strcmp(inputtext, data[safePassword], false))
		{
			Safe_Items(playerid, area);
		}
		else
		{
			SendErrorMessage(playerid, "Ge�ersiz �ifre girdiniz.");
			Dialog_Show(playerid, DIALOG_SAFE_PASSWORD, DIALOG_STYLE_INPUT, "�ifre", "{FFFFFF}Bu kasa i�in �ifre belirlenmi�, �ifreyi giriniz:", "Devam", "Kapat");
		}
	}
	return 1;
}

Dialog:DIALOG_CRAFT(playerid, response, listitem, inputtext[])
{
	if(response)
	{
	    new item = strval(inputtext);

	    if(item == -1) return SendErrorMessage(playerid, "Bir sorun olu�tu, l�tfen tekrar e�ya �retmeyi deneyin.");
	    
	    if(CraftData[item][Use_Item] == false && !IsCharacterCanGetThisItem(playerid, CraftData[item][Craft_Item], 1)) return SendErrorMessage(playerid, "Envanteriniz dolu, bu e�yay� �retemezsiniz.");

	    if(CraftData[item][Craft_TableRequired])
	    {
	    	new check = IsCharNearCraftTable(playerid);

	    	if(check == -1)
	    	{
	    		SendErrorMessage(playerid, "Bu e�yay� �retmek i�in �retim masas�na yak�n olmal�s�n�z. Yak�nsan�z, masadaki �retimin bitmesini bekleyin.");
	    		return 1;
	    	}

	    	new data[enum_tables];

	    	Streamer_GetArrayData(STREAMER_TYPE_AREA, check, E_STREAMER_EXTRA_ID, data);

	    	data[tableUsing] = 1;
	    	
	    	if(IsValidDynamic3DTextLabel(data[tableText])) DestroyDynamic3DTextLabel(data[tableText]);

	    	data[tableText] = CreateDynamic3DTextLabel("* �retim yap�l�yor...", 0x66a832FF, data[tableX], data[tableY], data[tableZ], 5.0, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 1, GetPlayerVirtualWorld(playerid), GetPlayerInterior(playerid));

	    	Streamer_SetArrayData(STREAMER_TYPE_AREA, check, E_STREAMER_EXTRA_ID, data);
	    	
	    	new seconds = RandomEx(3, 5);
	    	
	    	MessageBox(playerid, "Uretim yapiliyor.", seconds);
	    	
	    	Character[playerid][Character_CraftTimer] = SetTimerEx("OnCharacterEndCrafting", seconds*1000, false, "iii", playerid, item, check);
	    	TogglePlayerControllable(playerid, false);
	    	
	    	Character[playerid][Character_CraftingTable] = check;
	    	return 1;
	    }

		new seconds = RandomEx(3, 5);

	    MessageBox(playerid, "Uretim yapiliyor.", seconds);

        Character[playerid][Character_CraftTimer] = SetTimerEx("OnCharacterEndCrafting", seconds*1000, false, "iii", playerid, item, -1);
        TogglePlayerControllable(playerid, false);
	}
	return 1;
}

Dialog:DIALOG_TALENT(playerid, response, listitem, inputtext[])
{
	if(response)
	{
		if(!strcmp(inputtext, "> Yeteneklerimi listele.", true))
			return Dialog_Show(playerid, DIALOG_TALENT_SHOW, DIALOG_STYLE_MSGBOX, ReturnName(playerid), "{CC9966}Yetenek d�zeyi:\n\n{9999FF}Mekanik: {FFFFFF}%d/%d\n{9999FF}Bal�k��l�k: {FFFFFF}%d/%d\n{9999FF}Ni�anc�l�k: {FFFFFF}%d/%d\n{9999FF}�retim: {FFFFFF}%d/%d\n{9999FF}�lkyard�m: {FFFFFF}%d/%d\n{9999FF}Yemek pi�irme: {FFFFFF}%d/%d", "geri", "",
			Character[playerid][Talent_Mechanic], LIMIT_TALENT,
			Character[playerid][Talent_Fishing], LIMIT_TALENT,
			Character[playerid][Talent_Aim], LIMIT_TALENT,
			Character[playerid][Talent_Crafting], LIMIT_TALENT,
			Character[playerid][Talent_FirstAid], LIMIT_TALENT,
			Character[playerid][Talent_Cooking], LIMIT_TALENT);

		else if(!strcmp(inputtext, "> Yetenek geli�tir.", true))
		{
		    if(Character[playerid][Character_TalentPoint] == 0)
		    {
		        pc_cmd_yetenek(playerid);
		        return SendErrorMessage(playerid, "Yetenek puan�n�z yok.");
		    }

		    Dialog_Show(playerid, DIALOG_TALENT_GIVE, DIALOG_STYLE_INPUT, "Yetenek geli�tir:", "{FFFFFF}�u anda {CC9966}%d {FFFFFF}yetenek puan�n�z var. Geli�tirmek istedi�iniz yetene�in ad�n� kutucu�a yaz�n. Yetenekler:\n\n{CC9966}mekanik, bal�k��l�k, ni�anc�l�k, �retim, ilkyard�m, yemek pi�irme", "ileri", "vazge�", Character[playerid][Character_TalentPoint]);
		}
	}
	return 1;
}

Dialog:DIALOG_TALENT_GIVE(playerid, response, listitem, inputtext[])
{
	if(!response) return pc_cmd_yetenek(playerid);
	if(response)
	{
	    if(!strcmp(inputtext, "mekanik", true))
		{
		    if(Character[playerid][Talent_Mechanic] >= LIMIT_TALENT) return SendErrorMessage(playerid, "Bu yetenek daha fazla geli�tirilemez.");
			Character[playerid][Talent_Mechanic]++;
		}
	    else if(!strcmp(inputtext, "bal�k��l�k", true))
		{
		    if(Character[playerid][Talent_Fishing] >= LIMIT_TALENT) return SendErrorMessage(playerid, "Bu yetenek daha fazla geli�tirilemez.");
			Character[playerid][Talent_Fishing]++;
		}
	    else if(!strcmp(inputtext, "ni�anc�l�k", true))
		{
		    if(Character[playerid][Talent_Fishing] >= LIMIT_TALENT) return SendErrorMessage(playerid, "Bu yetenek daha fazla geli�tirilemez.");
			Character[playerid][Talent_Aim]++;
		}
	    else if(!strcmp(inputtext, "�retim", true))
		{
		    if(Character[playerid][Talent_Crafting] >= LIMIT_TALENT) return SendErrorMessage(playerid, "Bu yetenek daha fazla geli�tirilemez.");
			Character[playerid][Talent_Crafting]++;
		}
	    else if(!strcmp(inputtext, "ilkyard�m", true))
		{
		    if(Character[playerid][Talent_FirstAid] >= LIMIT_TALENT) return SendErrorMessage(playerid, "Bu yetenek daha fazla geli�tirilemez.");
			Character[playerid][Talent_FirstAid]++;
		}
	    else if(!strcmp(inputtext, "yemek pi�irme", true))
		{
		    if(Character[playerid][Talent_Cooking] >= LIMIT_TALENT) return SendErrorMessage(playerid, "Bu yetenek daha fazla geli�tirilemez.");
			Character[playerid][Talent_Cooking]++;
		}else{
	        Dialog_Show(playerid, DIALOG_TALENT_GIVE, DIALOG_STYLE_INPUT, "Yetenek geli�tir:", "{FFFFFF}�u anda {CC9966}%d {FFFFFF}yetenek puan�n�z var. Geli�tirmek istedi�iniz yetene�in ad�n� kutucu�a yaz�n. Yetenekler:\n\n{CC9966}mekanik, bal�k��l�k, ni�anc�l�k, �retim, ilkyard�m, yemek pi�irme", "ileri", "vazge�", Character[playerid][Character_TalentPoint]);
	        return SendErrorMessage(playerid, "Ge�ersiz yetenek girdiniz. �rnek kullan�m: mekanik");
	    }

	    Character[playerid][Character_TalentPoint]--;
	    UpdateCharacter(playerid);

	    SendServerMessage(playerid, "%s yetene�iniz 1 puan geli�ti.", inputtext);

	    if(Character[playerid][Character_TalentPoint] > 0)
	    	Dialog_Show(playerid, DIALOG_TALENT_GIVE, DIALOG_STYLE_INPUT, "Yetenek geli�tir:", "{FFFFFF}�u anda {CC9966}%d {FFFFFF}yetenek puan�n�z var. Geli�tirmek istedi�iniz yetene�in ad�n� kutucu�a yaz�n. Yetenekler:\n\n{CC9966}mekanik, bal�k��l�k, ni�anc�l�k, �retim, ilkyard�m, yemek pi�irme", "ileri", "vazge�", Character[playerid][Character_TalentPoint]);
		else
			pc_cmd_yetenek(playerid);
	}
	return 1;
}

Dialog:DIALOG_TALENT_SHOW(playerid, response, listitem, inputtext[]) return pc_cmd_yetenek(playerid);

/*Flags*/
flags:me(CMD_PLAYER);
flags:do(CMD_PLAYER);
flags:ame(CMD_PLAYER);
flags:ado(CMD_PLAYER);
flags:s(CMD_PLAYER);
flags:shout(CMD_PLAYER);
flags:l(CMD_PLAYER);
flags:low(CMD_PLAYER);
flags:b(CMD_PLAYER);
flags:w(CMD_PLAYER);
flags:whisper(CMD_PLAYER);
flags:cw(CMD_PLAYER);
flags:pm(CMD_PLAYER);
flags:re(CMD_PLAYER);
flags:chattemizle(CMD_PLAYER);
flags:ayarlar(CMD_PLAYER);
flags:id(CMD_PLAYER);
flags:hesap(CMD_PLAYER);
flags:envanter(CMD_PLAYER);
flags:balik(CMD_PLAYER);
flags:airdrop(CMD_PLAYER);
flags:silah(CMD_PLAYER);
flags:craft(CMD_PLAYER);
flags:masaduzenle(CMD_PLAYER);
flags:kasa(CMD_PLAYER);
flags:gir(CMD_PLAYER);
flags:cik(CMD_PLAYER);
flags:loot(CMD_PLAYER);
flags:ssmod(CMD_PLAYER);
flags:saat(CMD_PLAYER);
flags:telsiz(CMD_PLAYER);
flags:t(CMD_PLAYER);
flags:slot(CMD_PLAYER);
flags:slotaktif(CMD_PLAYER);
flags:agac(CMD_PLAYER);
flags:yetenek(CMD_PLAYER);

flags:duty(CMD_TESTER1);

flags:deletetable(CMD_DEVELOPER);
flags:createloot(CMD_DEVELOPER);
flags:deleteloot(CMD_DEVELOPER);
flags:editloot(CMD_DEVELOPER);
flags:gotoloot(CMD_DEVELOPER);

flags:editherd(CMD_DEVELOPER);
flags:editherdpoint(CMD_DEVELOPER);
flags:gotoherdpoint(CMD_DEVELOPER);
flags:listherdpoints(CMD_DEVELOPER);
flags:createherdpoint(CMD_DEVELOPER);
flags:createherd(CMD_DEVELOPER);
flags:deleteherd(CMD_DEVELOPER);
flags:listherds(CMD_DEVELOPER);
flags:createnpc(CMD_DEVELOPER);
flags:deletenpc(CMD_DEVELOPER);
flags:editnpc(CMD_DEVELOPER);
flags:gotonpc(CMD_DEVELOPER);
flags:getnpc(CMD_DEVELOPER);

flags:additem(CMD_FOUNDER);
flags:deleteitem(CMD_FOUNDER);
flags:deleteallitems(CMD_FOUNDER);
flags:createditem(CMD_FOUNDER);
flags:deleteditem(CMD_FOUNDER);
flags:deletesafe(CMD_FOUNDER);

/*Player Commands*/
CMD:me(playerid, params[])
{
	if(isnull(params))
	    return SendSyntaxMessage(playerid, "/me [yaz�]");

	new action[256];

    strdel(action, 0, 256);
	strcat(action, params);

    if(strfind(action, "\"", true, 1) != -1)
	{
			new ditto = strfind(action, "\"", true, 1), ditto2 = strfind(action, "\"", true, ditto+1);

			strins(action, "{FFFFFF}", ditto);
			strins(action, "{C2A2DA}", ditto2+9);
	}
	if(strlen(action) > 120)
	{
 	    SendNearbyMessage(playerid, DEFAULT_DISTANCE, COLOR_PURPLE, "* %s %.120s", ReturnName(playerid), action);
	    SendNearbyMessage(playerid, DEFAULT_DISTANCE, COLOR_PURPLE, "...%s", action[120]);
	}else{
	    SendNearbyMessage(playerid, DEFAULT_DISTANCE, COLOR_PURPLE, "* %s %s", ReturnName(playerid), action);
	}
	return 1;
}

CMD:do(playerid, params[])
{
	if(isnull(params))
	    return SendSyntaxMessage(playerid, "/do [yaz�]");

	if(strlen(params) > 120)
	{
	    SendNearbyMessage(playerid, DEFAULT_DISTANCE, COLOR_PURPLE, "* %.120s", params);
	    SendNearbyMessage(playerid, DEFAULT_DISTANCE, COLOR_PURPLE, "...%s (( %s ))", params[120], ReturnName(playerid));
	}else{
	    SendNearbyMessage(playerid, DEFAULT_DISTANCE, COLOR_PURPLE, "* %s (( %s ))", params, ReturnName(playerid));
	}
	return 1;
}

CMD:ame(playerid, params[])
{
	if(isnull(params))
	    return SendSyntaxMessage(playerid, "/ame [yaz�]");

    new string[128];

	format(string, sizeof(string), "> %s %s", ReturnName(playerid), params);
 	SetPlayerChatBubble(playerid, string, COLOR_LIGHTRED, DEFAULT_DISTANCE, 10000);

 	SendClientMessageEx(playerid, COLOR_LIGHTRED, "> %s %s", ReturnName(playerid), params);
	return 1;
}

CMD:ado(playerid, params[])
{
	if(isnull(params))
	    return SendSyntaxMessage(playerid, "/ado [yaz�]");

    new string[128];

	format(string, sizeof(string), "> %s (( %s ))", params, ReturnName(playerid));
 	SetPlayerChatBubble(playerid, string, COLOR_LIGHTRED, DEFAULT_DISTANCE, 10000);

 	SendClientMessageEx(playerid, COLOR_LIGHTRED, "> %s (( %s ))", params, ReturnName(playerid));
	return 1;
}

CMD:s(playerid, params[])
{
	if(isnull(params))
	    return SendSyntaxMessage(playerid, "/s [yaz�]");

	if(strlen(params) > 64)
	{
	    SendNearbyMessage(playerid, 30.0, COLOR_WHITE, "%s ba��r�r: %.64s", ReturnName(playerid), params);
	    SendNearbyMessage(playerid, 30.0, COLOR_WHITE, "...%s", params[64]);
	}else{
	    SendNearbyMessage(playerid, 30.0, COLOR_WHITE, "%s ba��r�r: %s", ReturnName(playerid), params);
	}
	return 1;
}
CMD:shout(playerid, params[]) return pc_cmd_s(playerid, params);

CMD:l(playerid, params[])
{
	if(isnull(params))
	    return SendSyntaxMessage(playerid, "/l [yaz�]");

	if(strlen(params) > 64)
	{
	    SendNearbyMessage(playerid, 5.0, COLOR_WHITE, "%s, k�s�k sesle s�yler: %.64s", ReturnName(playerid), params);
	    SendNearbyMessage(playerid, 5.0, COLOR_WHITE, "...%s", params[64]);
	}else{
	    SendNearbyMessage(playerid, 5.0, COLOR_WHITE, "%s, k�s�k sesle s�yler: %s", ReturnName(playerid), params);
	}
	return 1;
}
CMD:low(playerid, params[]) return pc_cmd_l(playerid, params);

CMD:b(playerid, params[])
{
	if(Account[playerid][Settings_OOC] == 0)
		return SendErrorMessage(playerid, "OOC kanal�n kapal�yken bu komutu kullanamazs�n. (/ayarlar)");

	if(isnull(params))
	    return SendSyntaxMessage(playerid, "/b [yaz�]");

	if(strlen(params) > 64)
	{
	    if(Character[playerid][Character_StaffDuty])
	    {
	        SendNearbyMessage(playerid, DEFAULT_DISTANCE, COLOR_WHITE, "(( {3399FF}%s{FFFFFF}[%d]: %.64s", ReturnName(playerid), playerid, params);
	    	SendNearbyMessage(playerid, DEFAULT_DISTANCE, COLOR_WHITE, "...%s ))", params[64]);
	        return 1;
		}

		SendOOCMessage(playerid, DEFAULT_DISTANCE, params);
	}else{
	    if(Character[playerid][Character_StaffDuty])
	    {
	        SendNearbyMessage(playerid, DEFAULT_DISTANCE, COLOR_WHITE, "(( {3399FF}%s{FFFFFF}[%d]: %s ))", ReturnName(playerid), playerid, params);
			return 1;
		}

	    SendOOCMessage(playerid, DEFAULT_DISTANCE, params);
	}
	return 1;
}

CMD:w(playerid, params[])
{
	new userid, text[128];

    if (sscanf(params, "us[128]", userid, text))
	    return SendSyntaxMessage(playerid, "/(w)hisper [id/isim] [yaz�]");

	if (!IsPlayerConnected(userid) || !IsPlayerNearPlayer(playerid, userid, 5.0))
	    return SendErrorMessage(playerid, "Ki�i oyunda de�il veya size uzak.");

	if (userid == playerid)
		return SendErrorMessage(playerid, "Kendinize f�s�ldayamazs�n�z.");

	if(GetPlayerState(userid) == PLAYER_STATE_SPECTATING)
	    return SendErrorMessage(playerid, "Ki�i oyunda de�il veya size uzak.");

    if (strlen(text) > 64) {
	    SendClientMessageEx(userid, COLOR_YELLOW, "** %s f�s�ldad� (%d): %.64s", ReturnName(playerid), playerid, text);
	    SendClientMessageEx(userid, COLOR_YELLOW, "...%s **", text[64]);

	    SendClientMessageEx(playerid, COLOR_YELLOW, "** %s'a f�s�ldad�n (%d): %.64s", ReturnName(userid), userid, text);
	    SendClientMessageEx(playerid, COLOR_YELLOW, "...%s **", text[64]);
	}
	else {
	    SendClientMessageEx(userid, COLOR_YELLOW, "** %s f�s�ldad� (%d): %s **", ReturnName(playerid), playerid, text);
	    SendClientMessageEx(playerid, COLOR_YELLOW, "** %s'a f�s�ldad�n (%d): %s **", ReturnName(userid), userid, text);
	}
	SendNearbyMessage(playerid, 20.0, COLOR_PURPLE, "** %s, %s'�n kula��na yakla��r ve f�s�ldar.", ReturnName(playerid), ReturnName(userid));
	return 1;
}
CMD:whisper(playerid, params[]) return pc_cmd_w(playerid, params);

CMD:cw(playerid, params[])
{
    if(!IsPlayerInAnyVehicle(playerid)) return SendErrorMessage(playerid, "Bu komutu sadece ara� i�erisinde kullanabilirsiniz.");

	new str[128];
	
	if(sscanf(params, "s[128]", str)) return SendSyntaxMessage(playerid, "/cw [yaz�]");

	format(str, sizeof(str), "[Ara� i�i] {FFFFFF}%s: %s", ReturnName(playerid), str);
	
	new vehicle = GetPlayerVehicleID(playerid);

	foreach(new i: Player)
	{
		if(Account[i][Account_IsPlaying] && IsPlayerInAnyVehicle(i))
		{
			if(GetPlayerVehicleID(i) == vehicle)
        		SendClientMessageEx(i, COLOR_CLIENT, str);
		}
	}
	return 1;
}

CMD:pm(playerid, params[])
{
	new target, str[128];
	
	if(sscanf(params, "us[128]", target, str)) return SendSyntaxMessage(playerid, "/pm [id/isim] [yaz�]");
	
	if(playerid == target) return SendErrorMessage(playerid, "Kendinize �zel mesaj g�nderemezsiniz.");
    if(!IsPlayerConnected(target)) return SendErrorMessage(playerid, "Ki�i oyunda de�il.");
    if(!Account[target][Account_IsPlaying]) return SendErrorMessage(playerid, "Ki�i giri� yapmam��.");
	if(Account[playerid][Account_Staff] < GADMIN1 && Account[target][Settings_Pm] == 0) return SendErrorMessage(playerid, "Ki�inin �zel mesaj kanal� kapal�.");
	
	SendClientMessageEx(playerid, COLOR_YELLOW, "[Giden PM > %s(%d)] %s", ReturnName(target), target, str);
	SendClientMessageEx(target, COLOR_YELLOW, "[Gelen PM > %s(%d)] %s", ReturnName(playerid), playerid, str);
	
	Character[target][Character_LastPm] = playerid;
	return 1;
}

CMD:re(playerid, params[])
{
	if(Character[playerid][Character_LastPm] == INVALID_PLAYER_ID) return SendErrorMessage(playerid, "Kimse size �zel mesaj g�ndermemi�.");

	if(!IsPlayerConnected(Character[playerid][Character_LastPm]))
	{
	    SendServerMessage(playerid, "Size �zel mesaj g�nderen ki�i oyundan ��k�� yapm��.");
	    Character[playerid][Character_LastPm] = INVALID_PLAYER_ID;
	    return 1;
	}

	new str[128];
	
	if(sscanf(params, "s[128]", str)) return SendSyntaxMessage(playerid, "/re [yaz�]");
	
	SendClientMessageEx(playerid, COLOR_YELLOW, "[Giden PM > %s(%d)] %s", ReturnName(Character[playerid][Character_LastPm]), Character[playerid][Character_LastPm], str);
	SendClientMessageEx(Character[playerid][Character_LastPm], COLOR_YELLOW, "[Gelen PM > %s(%d)] %s", ReturnName(playerid), playerid, str);
	
	Character[Character[playerid][Character_LastPm]][Character_LastPm] = playerid;
	return 1;
}

CMD:chattemizle(playerid, params[])
{
	new integer;
	if(sscanf(params, "d", integer))
		return SendSyntaxMessage(playerid, "/chattemizle [say�]");

	if(integer > 20 || integer < 1) return SendErrorMessage(playerid, "Girdi 20'den fazla, 1'den k���k olamaz.");

	ClearChat(playerid, integer);
	return 1;
}

CMD:id(playerid, params[])
{
	if(isnull(params))
	    return SendSyntaxMessage(playerid, "/id [isim]");

	if(strlen(params) < 3)
		return SendErrorMessage(playerid, "Girilen isim en az 3 karakter i�ermelidir.");

	new count;

	count = 0;

	foreach(new i : Player)
	{
	    if(strfind(ReturnName(i), params, true) != -1)
	    {
	        SendClientMessageEx(playerid, COLOR_CLIENT, "Oyuncu bulundu: {FFFFFF}%s(%d)", ReturnName(i), i);
	        count++;
		}
	}
	
	if(!count)
		return SendErrorMessage(playerid, "\"%s\" ad�nda herhangi bir oyuncu bulunamad�.", params);
	return 1;
}

CMD:ayarlar(playerid)
{
	Dialog_Show(playerid, DIALOG_SETTINGS, DIALOG_STYLE_LIST, "Hesap Ayarlar�", "> PM kanal�n� %s.\n> OOC kanal�n� %s.", "se�", "��k��",
    	(Account[playerid][Settings_Pm] == 0) ? ("a�") : ("kapat"),
    	(Account[playerid][Settings_OOC] == 0) ? ("a�") : ("kapat")
	);
	return 1;
}

CMD:hesap(playerid)
	return Dialog_Show(playerid, DIALOG_ACCOUNT, DIALOG_STYLE_LIST, Account[playerid][Account_Name], "> Hesap bilgilerimi g�r�nt�le.\n> Hesap �ifremi de�i�tir.", "Se�", "Vazge�");

CMD:envanter(playerid)
	return Inventory_List(playerid);
	
CMD:balik(playerid, params[])
{
	if(IsPlayerInAnyVehicle(playerid)) return SendErrorMessage(playerid, "Ara�ta bu komutu kullanamazs�n�z.");

    if(isnull(params)) return SendSyntaxMessage(playerid, "/balik [tut/pisir]");

    if(!strcmp(params, "tut", true))
    {
		if(Inventory_GetItemAmount(playerid, 2) <= 0) return SendErrorMessage(playerid, "Oltan�z yok.");

		UseItem(playerid, 2, true);
		return 1;
	}
	if(!strcmp(params, "pisir", true))
	{
		if(Inventory_GetItemAmount(playerid, 3) <= 0) return SendErrorMessage(playerid, "Envanterinizde �i� bal���n�z yok.");
	    UseItem(playerid, 3, true);
	    return 1;
	}
	
	pc_cmd_balik(playerid, "");
	return 1;
}

CMD:airdrop(playerid)
{
	if(IsPlayerInAnyVehicle(playerid)) return SendErrorMessage(playerid, "Ara�ta bu komutu kullanamazs�n�z.");
	if(GetPlayerInterior(playerid) > 0 || GetPlayerVirtualWorld(playerid) > 0) return SendErrorMessage(playerid, "Interior i�erisinde bu komutu kullanamazs�n�z.");

	Airdrop_List(playerid);
	return 1;
}

CMD:silah(playerid, params[])
{
    if(EditingWeapon[playerid]) return SendErrorMessage(playerid, "�u anda zaten silah d�zenliyorsun.");

	new weaponid = GetPlayerWeapon(playerid);

    if(!weaponid) return SendErrorMessage(playerid, "Elinizde silah yok.");

    if(!IsWeaponWearable(weaponid)) return SendErrorMessage(playerid, "Bu silah d�zenlenemez.");

    if(isnull(params)) return SendSyntaxMessage(playerid, "/silah [pozisyon/kemik/gizle]");

    if(!strcmp(params, "pozisyon", true))
    {

    	if(WeaponSettings[playerid][weaponid - 22][Hidden]) return SendErrorMessage(playerid, "Gizlenmi� bir silah�n pozisyonunu d�zenleyemezsin.");

        new index = weaponid - 22;

        SetPlayerArmedWeapon(playerid, 0);

        SetPlayerAttachedObject(playerid, GetWeaponObjectSlot(weaponid), GetWeaponModel(weaponid), WeaponSettings[playerid][index][Bone], WeaponSettings[playerid][index][Position][0], WeaponSettings[playerid][index][Position][1], WeaponSettings[playerid][index][Position][2], WeaponSettings[playerid][index][Position][3], WeaponSettings[playerid][index][Position][4], WeaponSettings[playerid][index][Position][5], 1.0, 1.0, 1.0);
        EditAttachedObject(playerid, GetWeaponObjectSlot(weaponid));

        EditingWeapon[playerid] = weaponid;
        return 1;
    }

    else if(!strcmp(params, "kemik", true))
    {
		Dialog_Show(playerid, DIALOG_EDIT_BONE, DIALOG_STYLE_LIST, "Kemik:", "Omurga\nKafa\nSol �st kol\nSa� �st kol\nSol kol\nSa� kol\nSol uyluk\nSa� uyluk\nSol ayak\nSa� ayak\nSa� bald�r\nSol bald�r\nSol �n kol\nSa� �n kol\nSol omuz\nSa� omuz\nBoyun\n�ene", "se�", "vazge�");
  		EditingWeapon[playerid] = weaponid;
  		return 1;
	}
	else if(!strcmp(params, "gizle", true))
	{
 		if(!IsWeaponHideable(weaponid)) return SendErrorMessage(playerid, "Bu silah gizlenemez.");

        new index = weaponid - 22, weaponname[18], string[48];

        GetWeaponName(weaponid, weaponname, sizeof(weaponname));

        if(WeaponSettings[playerid][index][Hidden])
        {
			SendServerMessage(playerid, "%s silah� art�k �zerinizde g�r�necek.", weaponname);
            WeaponSettings[playerid][index][Hidden] = false;
        }else{
            if(IsPlayerAttachedObjectSlotUsed(playerid, GetWeaponObjectSlot(weaponid))) RemovePlayerAttachedObject(playerid, GetWeaponObjectSlot(weaponid));

            SendServerMessage(playerid, "%s silah�n� gizlediniz.", weaponname);
            WeaponSettings[playerid][index][Hidden] = true;
        }

		mysql_format(SQL_Handle, string, sizeof(string), "INSERT INTO weaponsettings (OWNER, WeaponID, Hidden) VALUES ('%d', %d, %d) ON DUPLICATE KEY UPDATE Hidden = VALUES(Hidden)", Character[playerid][Character_SQL], weaponid, WeaponSettings[playerid][index][Hidden]);
        mysql_tquery(SQL_Handle, string);
	    return 1;
	}
	
	pc_cmd_silah(playerid, "");
	return 1;
}

CMD:craft(playerid)
{
	if(IsPlayerInAnyVehicle(playerid)) return SendErrorMessage(playerid, "Ara�ta �retim yapamazs�n�z.");

	if(Character[playerid][Talent_Crafting] < 20) return SendErrorMessage(playerid, "�retim yetene�iniz belirli bir seviyenin alt�ndayken bu komutu kullanamazs�n�z.");

	if(Character[playerid][Character_CraftTimer] != -1) return SendErrorMessage(playerid, "�u anda zaten e�ya �retiyorsunuz.");

	new string[sizeof(CraftData) * 100] = "craft id\te�ya\tgereken\n", count = 0;
	for(new i = 0; i < sizeof(CraftData); i++)
	{
	    if(CraftData[i][Craft_ItemX] != -1 && CraftData[i][Craft_XAmount] != 0)
	    {
	        if(Inventory_GetItemAmount(playerid, CraftData[i][Craft_ItemX]) >= CraftData[i][Craft_XAmount])
	        {
	            if(CraftData[i][Craft_ItemY] != -1 && CraftData[i][Craft_YAmount] != 0)
	            {
	                if(Inventory_GetItemAmount(playerid, CraftData[i][Craft_ItemY]) >= CraftData[i][Craft_YAmount])
					{
	                    if(CraftData[i][Craft_ItemZ] != -1 && CraftData[i][Craft_ZAmount] != 0)
	                    {
	                        if(Inventory_GetItemAmount(playerid, CraftData[i][Craft_ItemZ]) >= CraftData[i][Craft_ZAmount])
	                        {
	                            format(string, sizeof(string), "%s%d\t%s\t%s(%d) - %s(%d) - %s(%d)\n", string, i, Items[CraftData[i][Craft_Item]][Item_Name], Items[CraftData[i][Craft_ItemX]][Item_Name], CraftData[i][Craft_XAmount], Items[CraftData[i][Craft_ItemY]][Item_Name], CraftData[i][Craft_YAmount], Items[CraftData[i][Craft_ItemZ]][Item_Name], CraftData[i][Craft_ZAmount]);
	                            count++;
	                        }
	                    }else{
	                        format(string, sizeof(string), "%s%d\t%s\t%s(%d) - %s(%d)\n", string, i, Items[CraftData[i][Craft_Item]][Item_Name], Items[CraftData[i][Craft_ItemX]][Item_Name], CraftData[i][Craft_XAmount], Items[CraftData[i][Craft_ItemY]][Item_Name], CraftData[i][Craft_YAmount]);
	                        count++;
	                    }
	                }
	            }else{
	                format(string, sizeof(string), "%s%d\t%s\t%s(%d)\n", string, i, Items[CraftData[i][Craft_Item]][Item_Name], Items[CraftData[i][Craft_ItemX]][Item_Name], CraftData[i][Craft_XAmount]);
	                count++;
	            }
	        }
	    }
	}
	
	if(count == 0) return SendErrorMessage(playerid, "�retebilece�iniz bir e�ya bulunamad�.");
	
	Dialog_Show(playerid, DIALOG_CRAFT, DIALOG_STYLE_TABLIST_HEADERS, "�retebilece�iniz e�yalar:", string, "�ret", "Vazge�");
	return 1;
}

CMD:masaduzenle(playerid)
{
	new id = IsCharNearCraftTable(playerid);

	if(id == -1) return SendErrorMessage(playerid, "Herhangi bir �retim masas�n�n yak�n�nda de�ilsiniz veya bu masa �u anda kullan�l�yor.");
	new data[enum_tables];
	Streamer_GetArrayData(STREAMER_TYPE_AREA, id, E_STREAMER_EXTRA_ID, data);
	Character[playerid][Character_EditingTable] = id;
	EditDynamicObject(playerid, data[tableObjectID]);
	return 1;
}

CMD:kasa(playerid, params[])
{
	new area = Character[playerid][Character_Area];
	if(area == -1 || Character[playerid][Character_AreaType] != 2) return SendErrorMessage(playerid, "Herhangi bir kasaya yak�n de�ilsiniz.");
	if(isnull(params)) return SendSyntaxMessage(playerid, "/kasa [al/sifre/maymuncuk/kilit]");
	
	if(!strcmp(params, "al", true))
	{
		new data[enum_safe];
		Streamer_GetArrayData(STREAMER_TYPE_AREA, area, E_STREAMER_EXTRA_ID, data);
		if(data[safeLock] == 2) return SendErrorMessage(playerid, "Bu kasa kilit ile korunmaktad�r.");
		if(isnull(data[safePassword]))
		{
			Safe_Items(playerid, area);
		}
		else
		{
			Dialog_Show(playerid, DIALOG_SAFE_PASSWORD, DIALOG_STYLE_INPUT, "�ifre", "{FFFFFF}Bu kasa i�in �ifre belirlenmi�, �ifreyi giriniz:", "Devam", "Kapat");
		}
		return 1;
	}
	else if(!strcmp(params, "sifre", true))
	{
		new data[enum_safe];
		Streamer_GetArrayData(STREAMER_TYPE_AREA, area, E_STREAMER_EXTRA_ID, data);
		if(data[safeOwner] != Character[playerid][Character_SQL]) return SendErrorMessage(playerid, "Kasan�n �ifresini sadece kasan�n sahibi de�i�tirebilir.");
		Dialog_Show(playerid, DIALOG_SAFE_SET_PASSWORD, DIALOG_STYLE_INPUT, "Kasa �ifre", "{FFFFFF}L�tfen kasan�z i�in yeni bir �ifre belirleyin:", "Devam", "Kapat");
		return 1;
	}
	else if(!strcmp(params, "maymuncuk", true))
	{
		if(Inventory_GetItemAmount(playerid, 39) <= 0) return SendErrorMessage(playerid, "Maymuncuk adl� e�yan�z yok.");
		UseItem(playerid, 39, true);
		return 1;
	}
	else if(!strcmp(params, "kilit", true))
	{
		new data[enum_safe];
		Streamer_GetArrayData(STREAMER_TYPE_AREA, area, E_STREAMER_EXTRA_ID, data);
		switch(data[safeLock])
		{
			case 0:
			{
				if(Inventory_GetItemAmount(playerid, 47) <= 0) return SendErrorMessage(playerid, "Kilit adl� e�yan�z yok, kilidi 5 metal par�as� temin ederek �retebilirsiniz. (/craft)");
				UseItem(playerid, 47, true);
			}
			case 1:
			{
				data[safeLock] = 2;
				Streamer_SetArrayData(STREAMER_TYPE_AREA, area, E_STREAMER_EXTRA_ID, data);
				Safe_Save(area);
				SendServerMessage(playerid, "Kasan�n kilit durumunu aktif hale getirdiniz.");
			}
			case 2:
			{
				data[safeLock] = 1;
				Streamer_SetArrayData(STREAMER_TYPE_AREA, area, E_STREAMER_EXTRA_ID, data);
				Safe_Save(area);
				SendServerMessage(playerid, "Kasan�n kilit durumunu pasif hale getirdiniz.");
			}
		}
	}
	pc_cmd_kasa(playerid, "");
	return 1;
}

CMD:gir(playerid)
{
	new id = IsCharNearLootPlaceOut(playerid);

	if(id != -1)
	{
	    if(LootPlace[id][LP_InX] == 0.0 && LootPlace[id][LP_InY] == 0.0 && LootPlace[id][LP_InZ] == 0.0)
	        return SendErrorMessage(playerid, "Kap� kilitli.");

		SetPlayerInterior(playerid, LootPlace[id][LP_InInterior]);
		SetPlayerVirtualWorld(playerid, LootPlace[id][LP_InWorld]);
		SetPlayerPos(playerid, LootPlace[id][LP_InX], LootPlace[id][LP_InY], LootPlace[id][LP_InZ]);
		SetCameraBehindPlayer(playerid);
		
		SendClientMessage(playerid, COLOR_LIMEYELLOW, "Loot b�lgesine giri� yapt�n. /loot komutuyla �evreyi ya�malayabilirsin.");
		return 1;
	}
	
	id = IsCharNearTent(playerid);
	
	if(id != -1)
	{
	    if(Tent[id][Tent_Lock] == 1) return SendErrorMessage(playerid, "Bu �ad�r�n fermuar� kapal�.");
		SetPlayerInterior(playerid, Tent[id][Tent_InInterior]);
		SetPlayerVirtualWorld(playerid, Tent[id][Tent_InWorld]);
		SetPlayerPos(playerid, Tent[id][Tent_InX], Tent[id][Tent_InY], Tent[id][Tent_InZ]);
		SetCameraBehindPlayer(playerid);
		return 1;
	}
	return 1;
}

CMD:cik(playerid)
{
	new id = IsCharNearLootPlaceIn(playerid);
	if(id != -1)
	{
		SetPlayerInterior(playerid, LootPlace[id][LP_Interior]);
		SetPlayerVirtualWorld(playerid, LootPlace[id][LP_World]);
		SetPlayerPos(playerid, LootPlace[id][LP_X], LootPlace[id][LP_Y], LootPlace[id][LP_Z]);
		SetCameraBehindPlayer(playerid);
		return 1;
	}
	
	id = IsCharNearInTent(playerid);
	
	if(id != -1)
	{
		SetPlayerInterior(playerid, Tent[id][Tent_Interior]);
		SetPlayerVirtualWorld(playerid, Tent[id][Tent_World]);
		
		new Float:x, Float:y, Float:z;
		GetDynamicObjectPos(Tent[id][Tent_Object], x, y, z);
		SetPlayerPos(playerid, x, y+2.0, z);
		SetCameraBehindPlayer(playerid);
	    return 1;
	}
	return 1;
}

CMD:loot(playerid)
{
    if(Character[playerid][Character_LootTimer] != -1)
    {
		KillTimer(Character[playerid][Character_LootTimer]);
		Character[playerid][Character_LootTimer] = -1;

		SendServerMessage(playerid, "Ya�ma i�lemini iptal ettiniz.");
		ClearAnimations(playerid);
		TogglePlayerControllable(playerid, true);
		DeleteInfoBox(playerid);
        return 1;
	}

    new id = IsCharNearLootPlaceIn(playerid, 50.0);
    
    if(id == -1) return SendErrorMessage(playerid, "Herhangi bir loot b�lgesinde de�ilsiniz.");
    
    TogglePlayerControllable(playerid, false);
    ApplyAnimation(playerid, "BOMBER", "BOM_Plant", 4.0, 1, 0, 0, 0, 0);

	new seconds = RandomEx(5, 10);

	MessageBox(playerid, "Loot yapiliyor.", seconds);

    Character[playerid][Character_LootTimer] = SetTimerEx("OnCharacterEndLooting", seconds*1000, false, "ii", playerid, LootPlace[id][LP_Type]);
	return 1;
}

CMD:ssmod(playerid, params[])
{
	new option;

	if(sscanf(params, "d", option))
	{
		SendSyntaxMessage(playerid, "/ssmod [0-1-2]");
		return SendServerMessage(playerid, "0 de�eriyle arkaplan�n�z normale d�ner, 1 de�eriyle siyah ve 2 de�eriyle kahverengi olur.");
	}

	switch(option)
	{
		case 0:
		{
			TextDrawHideForPlayer(playerid, Blind);
			TextDrawHideForPlayer(playerid, Blind2);
		}
		
		case 1:
		{
		    TextDrawHideForPlayer(playerid, Blind2);
			TextDrawShowForPlayer(playerid, Blind);
		}
		case 2:
		{
		    TextDrawHideForPlayer(playerid, Blind);
			TextDrawShowForPlayer(playerid, Blind2);
		}
		
		default: SendErrorMessage(playerid, "Ge�ersiz i�lem girdiniz.");
	}
	return 1;
}

CMD:saat(playerid)
{
	if(Inventory_GetItemAmount(playerid, 43) < 1) return SendErrorMessage(playerid, "Kol saatiniz yok.");

	if(Character[playerid][Character_Gender] == GENDER_MALE)
		pc_cmd_ame(playerid, "sol kolundaki saate bakar.");
	else
		pc_cmd_ame(playerid, "sa� kolundaki saate bakar.");

	GameTextForPlayer(playerid, Date(), 3 * 1000, 3);
	return 1;
}

CMD:telsiz(playerid, params[])
{
    if(Inventory_GetItemAmount(playerid, 44) < 1) return SendErrorMessage(playerid, "Telsizin yok.");
	if(Character[playerid][Character_RadioSlot] == -1) return SendErrorMessage(playerid, "Telsiz slotunuz ayarlanmam��. (/slot)");
	
	if(isnull(params)) return SendSyntaxMessage(playerid, "/(t)elsiz [yaz�]");
	
	foreach(new i: Player)
	{
	    if(IsPlayerConnected(i) && Account[i][Account_IsPlaying])
	    {
	        if(Character[i][Character_RadioSlot] == Character[playerid][Character_RadioSlot])
	            SendClientMessageEx(i, COLOR_CLIENT, "[S: %d] {FFFFFF}%s: %s", Character[playerid][Character_RadioSlot], ReturnName(playerid), params);
	    }
	}
	
	pc_cmd_ame(playerid, "telsizini a�z�na g�t�r�r ve bir �eyler s�yler.");
	pc_cmd_low(playerid, params);
	return 1;
}
CMD:t(playerid, params[]) return pc_cmd_telsiz(playerid, params);

CMD:slot(playerid, params[])
{
    if(Inventory_GetItemAmount(playerid, 44) < 1) return SendErrorMessage(playerid, "Telsizin yok.");

	new slot;
	if(sscanf(params, "i", slot)) return SendSyntaxMessage(playerid, "/slot [0-1000]");

    if(slot == Character[playerid][Character_RadioSlot]) return SendErrorMessage(playerid, "Zaten telsiziniz bu slota ayarl�.");
	if(slot < 0 || slot > 1000) return SendErrorMessage(playerid, "Girilen slot de�eri 0-1000 aras� olabilir.");

	Character[playerid][Character_RadioSlot] = slot;

	SendServerMessage(playerid, "Telsizinizin slotunu %d olarak ayarlad�n�z.", Character[playerid][Character_RadioSlot]);
	return 1;
}

CMD:slotaktif(playerid)
{
    if(Inventory_GetItemAmount(playerid, 44) < 1) return SendErrorMessage(playerid, "Telsizin yok.");
    if(Character[playerid][Character_RadioSlot] == -1) return SendErrorMessage(playerid, "Telsiz slotunuz ayarlanmam��. (/slot)");

	new count;
	foreach(new i: Player)
	{
	    if(IsPlayerConnected(i) && Account[i][Account_IsPlaying])
	    {
	        if(Character[i][Character_RadioSlot] == Character[playerid][Character_RadioSlot])
	            count++;
		}
	}
	SendServerMessage(playerid, "�u anda bu slotta %d ayr� sinyal var.", count);
	return 1;
}

CMD:agac(playerid, params[])
{
	if(IsPlayerInAnyVehicle(playerid)) return SendErrorMessage(playerid, "Ara�ta bu komutu kullanamazs�n�z.");
	if(GetPVarInt(playerid, "TreeID") != -1) return SendErrorMessage(playerid, "A�a� keserken bu komutu kullanamazs�n�z.");
	if(isnull(params)) return SendSyntaxMessage(playerid, "/agac [kes/al]");
	
	if(!strcmp(params, "kes"))
	{
		if(GetPlayerWeapon(playerid) != WEAPON_CHAINSAW) return SendErrorMessage(playerid, "Elinizde testere yok.");
		new id = GetClosestTree(playerid);
		if(id == -1) return SendErrorMessage(playerid, "Herhangi bir a�aca yak�n de�ilsiniz.");
		if(TreeData[id][treeStatus] != 0) return SendErrorMessage(playerid, "Bu a�a� kesildi veya kesiliyor.");
		TogglePlayerControllable(playerid, 0);
		TreeData[id][treeStatus] = 1;
		SetPVarInt(playerid, "TreeID", id);
		SetPVarInt(playerid, "TreeTimer", SetTimerEx("CutTree", 5000, false, "i", playerid));
		ApplyAnimation(playerid, "CHAINSAW", "WEAPON_csaw", 4.1, 1, 0, 0, 1, 0, 1);
		pc_cmd_ame(playerid, "elindeki testere ile a�ac� kesmeye ba�lar.");
		MessageBox(playerid, "Agac kesiliyor.", 5);
		return 1;
	}
	else if(!strcmp(params, "al"))
	{
		new id = GetClosestTree(playerid);
		if(id == -1) return SendErrorMessage(playerid, "Herhangi bir a�aca yak�n de�ilsiniz.");
		if(TreeData[id][treeStatus] != 2) return SendErrorMessage(playerid, "Bu a�a� kesilmemi�.");
		if(TreeData[id][treeLogs] < 1) return SendErrorMessage(playerid, "Bu a�a�ta odun kalmam��.");
		if(!IsCharacterCanGetThisItem(playerid, 48, 1)) return SendErrorMessage(playerid, "Envanterinizde yer yok.");
		Inventory_AddItem(playerid, 48, 1);
		TreeData[id][treeLogs]--;
		UpdateTree(id);
		SendServerMessage(playerid, "1 adet odun envanterinize eklendi.");
		return 1;
	}

	pc_cmd_agac(playerid, "");
	return 1;
}

CMD:yetenek(playerid) return Dialog_Show(playerid, DIALOG_TALENT, DIALOG_STYLE_LIST, "Yetenek men�s�:", "> Yeteneklerimi listele.\n> Yetenek geli�tir.", "se�", "��k��");

CMD:cadir(playerid, params[])
{
    if(IsPlayerInAnyVehicle(playerid)) return SendErrorMessage(playerid, "Ara�ta bu komutu kullanamazs�n�z.");
    if(isnull(params)) return SendSyntaxMessage(playerid, "/cadir [kur/duzenle/fermuar/kaldir]");

    if(!strcmp(params, "kur"))
	{
	    if(Inventory_GetItemAmount(playerid, 49) <= 0) return SendErrorMessage(playerid, "�ad�r�n�z yok.");
		UseItem(playerid, 49, true);
		return 1;
	}

    else if(!strcmp(params, "duzenle"))
    {
        new id = IsCharNearTent(playerid);

		if(id == -1) return SendErrorMessage(playerid, "Herhangi bir �ad�r�n yak�n�nda de�ilsiniz.");
		if(Tent[id][Tent_Owner] != Character[playerid][Character_SQL]) return SendErrorMessage(playerid, "Bu �ad�r size ait de�il, d�zenleyemezsiniz.");

		Character[playerid][Character_EditingTent] = id;
		EditDynamicObject(playerid, Tent[id][Tent_Object]);
		return 1;
    }

    else if(!strcmp(params, "fermuar"))
    {
        new id = IsCharNearTent(playerid);

    	if(id == -1) return SendErrorMessage(playerid, "Herhangi bir �ad�r�n yak�n�nda de�ilsiniz.");

    	if(Tent[id][Tent_Lock] == 0)
    		Tent[id][Tent_Lock] = 1, MessageBox(playerid, "Cadirin fermuari cekildi.", 2);
    	else
    		Tent[id][Tent_Lock] = 0, MessageBox(playerid, "Cadirin fermuari acildi.", 2);

    	Tent_Save(id);
    	return 1;
    }
    else if(!strcmp(params, "kaldir"))
    {
        if(!IsCharacterCanGetThisItem(playerid, 49, 1)) return SendErrorMessage(playerid, "Envanterinizde �ad�r i�in yer yok.");
        
        new id = IsCharNearTent(playerid);
        
        if(id == -1) return SendErrorMessage(playerid, "Herhangi bir �ad�r�n yak�n�nda de�ilsiniz.");
        if(Tent[id][Tent_Owner] != Character[playerid][Character_SQL]) return SendErrorMessage(playerid, "Bu �ad�r size ait de�il, kald�ramazs�n�z.");
        
        Inventory_AddItem(playerid, 49, 1);

        Tent_Delete(id);
        SendServerMessage(playerid, "�ad�r kald�r�ld�.");
        return 1;
    }

    pc_cmd_cadir(playerid, "");
	return 1;
}

/*Admin Commands*/
CMD:duty(playerid)
{
    if(Character[playerid][Character_StaffDuty])
    {
        Character[playerid][Character_StaffDuty] = false;
        SendServerMessage(playerid, "Me�gul duruma ge�tiniz.");
    }else{
        Character[playerid][Character_StaffDuty] = true;
        SendServerMessage(playerid, "M�sait duruma ge�tiniz.");
	}
	return 1;
}

CMD:editherd(playerid, params[])
{
	new herd_id, point_id;
	if(sscanf(params, "dd", herd_id, point_id))
		return SendSyntaxMessage(playerid, "/editherd [s�r� ID] [s�r� nokta ID]");

	new Cache:search, query[64];

	mysql_format(SQL_Handle, query, sizeof(query), "SELECT * FROM `npcs_herds` WHERE `herd_id` = '%d'", herd_id);
	search = mysql_query(SQL_Handle, query);

	new rows = cache_num_rows();

	if(!rows)
	{
		SendErrorMessage(playerid, "S�r� bulunamad�.");
		cache_delete(search);
		return 1;
	}

	new herd_name[32];

	cache_delete(search);

	mysql_format(SQL_Handle, query, sizeof(query), "SELECT * FROM `npcs_herds_points` WHERE `point_id` = '%d'", point_id);
	search = mysql_query(SQL_Handle, query);

	rows = cache_num_rows();

	if(!rows)
	{
		SendErrorMessage(playerid, "S�r� noktas� bulunamad�.");
		cache_delete(search);
		return 1;
	}

	new Float:x, Float:y, Float:z;

	cache_get_value_name_float(0, "point_x", x);
	cache_get_value_name_float(0, "point_y", y);
	cache_get_value_name_float(0, "point_z", z);

	cache_delete(search);

	SendServerMessage(playerid, "%s(%d) s�r�s�n� %d numaral� noktaya y�nlendirdin.", herd_name, herd_id, point_id);
	ChangeHerdNextPoint(herd_id, point_id, x, y, z);
	return 1;
}

CMD:editherdpoint(playerid, params[])
{
	new id;
	if(sscanf(params, "d", id))
		return SendSyntaxMessage(playerid, "/editherdpoint [pozisyonu d�zenlenecek s�r� noktas�]");

	new Cache:search, query[200];

	mysql_format(SQL_Handle, query, sizeof(query), "SELECT * FROM `npcs_herds_points` WHERE `point_id` = '%d'", id);
	search = mysql_query(SQL_Handle, query);

	new rows = cache_num_rows();

	if(!rows)
	{
		SendErrorMessage(playerid, "S�r� noktas� bulunamad�.");
		cache_delete(search);
		return 1;
	}

	cache_delete(search);

	GetPlayerPos(playerid, Character[playerid][Character_PosX], Character[playerid][Character_PosY], Character[playerid][Character_PosZ]);
	
	mysql_format(SQL_Handle, query, sizeof(query), "UPDATE `npcs_herds_point` SET `point_x` = '%f', `point_y` = '%f', `point_z` = '%f' WHERE `point_id` = '%d'",
		Character[playerid][Character_PosX], 
		Character[playerid][Character_PosY], 
		Character[playerid][Character_PosZ],
		id
	);
	mysql_query(SQL_Handle, query);

	SendServerMessage(playerid, "%d numaral� s�r� noktas�n�n pozisyonu de�i�tirildi. (mevcut s�r�lerin hedefi etkilenmedi)");
	return 1;
}

CMD:gotoherdpoint(playerid, params[])
{
	new id;
	if(sscanf(params, "d", id))
		return SendSyntaxMessage(playerid, "/gotoherdpoint [nokta numaras�]");

	new Cache:search, query[64];

	mysql_format(SQL_Handle, query, sizeof(query), "SELECT * FROM `npcs_herds_points` WHERE `point_id` = '%d'", id);
	search = mysql_query(SQL_Handle, query);

	new rows = cache_num_rows();

	if(!rows)
	{
		SendErrorMessage(playerid, "S�r� noktas� bulunamad�.");
		cache_delete(search);
		return 1;
	}

	new Float:x, Float:y, Float:z;

	cache_get_value_name_float(0, "point_x", x);
	cache_get_value_name_float(0, "point_y", y);
	cache_get_value_name_float(0, "point_z", z);

	cache_delete(search);
	
	SetPlayerPos(playerid, x, y, z);

	SendServerMessage(playerid, "%d numaral� s�r� noktas�na ���nland�n.", id);
	return 1;
}

CMD:listherdpoints(playerid)
	return mysql_tquery(SQL_Handle, "SELECT * FROM `npcs_herds_points`", "OnLookupNPCHerdPoints", "d", playerid);


CMD:createherdpoint(playerid)
	return Dialog_Show(playerid, CONFIRM_CH_POINT, DIALOG_STYLE_MSGBOX, "S�r� noktas�", "Bulundu�un noktay� s�r� hedefi haline getirmek istedi�inden emin misin?", "Evet", "Bo�ver");

Dialog:CONFIRM_CH_POINT(playerid, response, listitem, inputtext[])
{
	if(response)
	{
		GetPlayerPos(playerid, Character[playerid][Character_PosX], Character[playerid][Character_PosY], Character[playerid][Character_PosZ]);
	
		new query[256];
		
		mysql_format(SQL_Handle, query, sizeof(query), "INSERT INTO `npcs_herds_points` (`point_x`, `point_y`, `point_z`) VALUES('%f', '%f', '%f')",
			Character[playerid][Character_PosX],
			Character[playerid][Character_PosY],
			Character[playerid][Character_PosZ]
		);

		mysql_tquery(SQL_Handle, query);

		SendServerMessage(playerid, "Bulundu�un b�lge s�r� hedefi haline getirildi.");
	}
	return 1;
}

CMD:createherd(playerid, params[])
{
	new name[32];
	if(sscanf(params, "s[32]", name))
		return SendSyntaxMessage(playerid, "/createherd [s�r� ad�]");

	new Cache: search, query[64];

	mysql_format(SQL_Handle, query, sizeof(query), "SELECT * FROM `npcs_herds` WHERE `herd_name` = '%s'", name);
	search = mysql_query(SQL_Handle, query);

	new rows = cache_num_rows();

	if(rows)
	{
		SendErrorMessage(playerid, "Bu s�r� ad� kullan�l�yor.");
		cache_delete(search);
		return 1;
	}

	cache_delete(search);

	CreateHerd(ReturnName(playerid), name);
	
	SendServerMessage(playerid, "Yeni s�r� olu�turdun. (isim: %s)", name);
	return 1;
}

CMD:deleteherd(playerid, params[])
{
	new id;
	if(sscanf(params, "d", id))
		return SendSyntaxMessage(playerid, "/deleteherd [s�r� ID]");

	new Cache: search, query[64];

	mysql_format(SQL_Handle, query, sizeof(query), "SELECT * FROM `npcs_herds` WHERE `herd_id` = '%d'", id);
	search = mysql_query(SQL_Handle, query);

	new rows = cache_num_rows();

	if(!rows)
	{
		SendErrorMessage(playerid, "S�r� bulunamad�. </listherds>");
		cache_delete(search);
		return 1;
	}

	cache_delete(search);

	new herd_name[32];

	cache_get_value_name(0, "herd_name", herd_name);
	cache_delete(search);

	mysql_format(SQL_Handle, query, sizeof(query), "DELETE FROM `npcs_herds` WHERE `herd_id` = '%d'", id);
	mysql_tquery(SQL_Handle, query);

	mysql_format(SQL_Handle, query, sizeof(query), "UPDATE `npcs` SET `npc_herd_id` = '0' WHERE `npc_herd_id` = '%d'", id);
	mysql_tquery(SQL_Handle, query);

	for(new i = 0; i < MAX_DYNAMIC_NPC; i++)
	{
		if(NPCInfo[i][NPC_database_id] > 0)
		{
			if(NPCInfo[i][NPC_herd_id] == id)
			{
				NPCInfo[i][NPC_herd_id] = 0;
			}
		}
	}

	SendServerMessage(playerid, "%s(%d) numaral� s�r�y� sildin.", herd_name, id);
	return 1;
}


CMD:listherds(playerid)
	return mysql_tquery(SQL_Handle, "SELECT * FROM `npcs_herds`", "OnLookupNPCHerds", "d", playerid);

CMD:getnpc(playerid, params[])
{
	new id;
	if(sscanf(params, "d", id))
		return SendSyntaxMessage(playerid, "/gotonpc [npc ID]");

	if(!FCNPC_IsValid(NPCInfo[id][NPC_game_id]))
		return SendErrorMessage(playerid, "NPC bulunamad�.");

	new int, vw;

	int = GetPlayerInterior(playerid);
	vw = GetPlayerVirtualWorld(playerid);
	GetPlayerPos(playerid, Character[playerid][Character_PosX], Character[playerid][Character_PosY], Character[playerid][Character_PosZ]);

	FCNPC_SetInterior(NPCInfo[id][NPC_game_id], int);
	FCNPC_SetVirtualWorld(NPCInfo[id][NPC_game_id], vw);
	FCNPC_SetPosition(NPCInfo[id][NPC_game_id], Character[playerid][Character_PosX]+2, Character[playerid][Character_PosY], Character[playerid][Character_PosZ]);

	SendServerMessage(playerid, "%d numaral� NPC'yi yan�na getirdin.", id);
	return 1;
}

CMD:gotonpc(playerid, params[])
{
	new id;
	if(sscanf(params, "d", id))
		return SendSyntaxMessage(playerid, "/gotonpc [npc ID]");

	if(!FCNPC_IsValid(NPCInfo[id][NPC_game_id]))
		return SendErrorMessage(playerid, "NPC bulunamad�.");

	new int, vw, Float:x, Float:y, Float:z;

	int = FCNPC_GetInterior(NPCInfo[id][NPC_game_id]);
	vw = FCNPC_GetVirtualWorld(NPCInfo[id][NPC_game_id]);
	FCNPC_GetPosition(NPCInfo[id][NPC_game_id], x, y, z);

	SetPlayerPos(playerid, x+2, y, z);
	SetPlayerInterior(playerid, int);
	SetPlayerVirtualWorld(playerid, vw);

	SendServerMessage(playerid, "%d numaral� NPC'nin yan�na gittin.", id);
	return 1;
}

CMD:editnpc(playerid, params[])
{
	new id, option[32], str[64];
	if(sscanf(params, "ds[32]S()[64]", id, option, str))
	{
		SendSyntaxMessage(playerid, "/editnpc [npc ID] [se�enek]");
		SendSyntaxMessage(playerid, "can, zirh, kiyafet, hasar, yurumehizi, kesikagiz, suruid");
		return 1;
	}

	if(!FCNPC_IsValid(NPCInfo[id][NPC_game_id]))
		return SendErrorMessage(playerid, "NPC bulunamad�.");

	if(id == -1)
		return SendErrorMessage(playerid, "NPC verileri al�n�rken bir sorun meydana geldi.");

	new npc_name[32];
	format(npc_name, sizeof(npc_name), "Zombi");

	if(!strcmp(option, "can", true))
	{
		new Float: health;
		if(sscanf(str, "f", health))
			return SendSyntaxMessage(playerid, "/editnpc <npc ID> <can> [can de�eri]");

		if(health < 1)
			return SendErrorMessage(playerid, "Ge�ersiz can de�eri.");

		new Float: oldHealth = FCNPC_GetHealth(NPCInfo[id][NPC_game_id]);
		FCNPC_SetHealth(NPCInfo[id][NPC_game_id], health);

		NPCInfo[id][NPC_health] = health;
		SendServerMessage(playerid, "%s(%d) NPC can�n� de�i�tirdin. (eski: %f | yeni: %f)", npc_name, id, oldHealth, health);
	}

	else if(!strcmp(option, "zirh", true))
	{
		new Float: armour;
		if(sscanf(str, "f", armour))
			return SendSyntaxMessage(playerid, "/editnpc <npc ID> <z�rh> [z�rh de�eri]");

		if(armour < 1)
			return SendErrorMessage(playerid, "Ge�ersiz z�rh de�eri.");

		new Float: oldArmour = FCNPC_GetArmour(NPCInfo[id][NPC_game_id]);
		FCNPC_SetArmour(NPCInfo[id][NPC_game_id], armour);

		NPCInfo[id][NPC_armour] = armour;
		SendServerMessage(playerid, "%s(%d) NPC z�rh�n� de�i�tirdin. (eski: %f | yeni: %f)", npc_name, id, oldArmour, armour);
	}

	else if(!strcmp(option, "kiyafet", true))
	{
		new skin;
		if(sscanf(str, "d", skin))
		{
			SendSyntaxMessage(playerid, "/editnpc <npc ID> <kiyafet> [k�yafet ID]");
			SendSyntaxMessage(playerid, "K�yafetini de�i�tirdi�in NPC tekrar spawnlanacak.");
			return 1;
		}

		if(skin < 1)
			return SendErrorMessage(playerid, "Hatal� k�yafet.");

		new oldSkin = FCNPC_GetSkin(NPCInfo[id][NPC_game_id]);
		FCNPC_SetSkin(NPCInfo[id][NPC_game_id], skin);

		NPCInfo[id][NPC_skin] = skin;
		SendServerMessage(playerid, "%s(%d) NPC k�yafetini de�i�tirdin. (eski: %d | yeni: %d)", npc_name, id, oldSkin, skin);
	}

	else if(!strcmp(option, "hasar", true))
	{
		new damage;
		if(sscanf(str, "d", damage))
			return SendSyntaxMessage(playerid, "/editnpc <npc ID> <hasar> [yeni hasar]");

		if(damage < 1 || damage > 10)
			return SendErrorMessage(playerid, "Ge�ersiz hasar.");

		new oldDamage = NPCInfo[id][NPC_damage];

		NPCInfo[id][NPC_damage] = damage;
		SendServerMessage(playerid, "%s(%d) NPC hasar�n� de�i�tirdin. (eski: %d | yeni: %d)", npc_name, id, oldDamage, damage);
	}

	else if(!strcmp(option, "yurumehizi", true))
	{
		new walk_speed;
		if(sscanf(str, "d", walk_speed))
			return SendSyntaxMessage(playerid, "/editnpc <npc ID> <yurumehizi> [yeni yurume hizi]");

		if(walk_speed < 1 || walk_speed > 10)
			return SendErrorMessage(playerid, "Ge�ersiz y�r�me h�z�.");

		new old_walk_speed = NPCInfo[id][NPC_walk_speed];
		
		NPCInfo[id][NPC_walk_speed] = walk_speed;
	 	SendServerMessage(playerid, "%s(%d) NPC y�r�me h�z�n� de�i�tirdin. (eski: %d | yeni: %d)", npc_name, id, old_walk_speed, walk_speed);
	}

	else if(!strcmp(option, "kesikagiz", true))
	{
		new biteMode = NPCInfo[id][NPC_bite];

		switch(biteMode)
		{
			case NPC_BITES:
			{
				NPCInfo[id][NPC_bite] = NPC_NOT_BITES;
				SendServerMessage(playerid, "%s(%d) NPC art�k �s�rm�yor.", npc_name, id);
			}

			case NPC_NOT_BITES:
			{
				NPCInfo[id][NPC_bite] = NPC_BITES;
				SendServerMessage(playerid, "%s(%d) NPC art�k �s�r�yor.", npc_name, id);
			}
		}
	}

	else if(!strcmp(option, "suruid", true))
	{
		new herd_id;
		if(sscanf(str, "d", herd_id))
			return SendSyntaxMessage(playerid, "/editnpc <npc ID> <suruid> [yeni suru id]");

		new Cache: search, query[64];

		mysql_format(SQL_Handle, query, sizeof(query), "SELECT * FROM `npcs_herds` WHERE `herd_id` = '%d'", herd_id);
		search = mysql_query(SQL_Handle, query);

		new rows = cache_num_rows();

		if(!rows)
		{
			SendErrorMessage(playerid, "S�r� numaras� bulunamad�.");
			cache_delete(search);
			return 1;
		}

		cache_delete(search);

		new old_herd_id = NPCInfo[id][NPC_herd_id];
		NPCInfo[id][NPC_herd_id] = herd_id;

		SendServerMessage(playerid, "%s(%d) NPC s�r�s�n� de�i�tirdin. (eski: %d | yeni: %d)", npc_name, id, old_herd_id, herd_id);
	}

	NPC_Save(id);
	return 1;
}

CMD:createnpc(playerid, params[])
{
	new npc_skin, Float:npc_health, Float:npc_armour, npc_damage, npc_walk_speed, npc_herd_id;

	if(sscanf(params, "dffddd", npc_skin, npc_health, npc_armour, npc_damage, npc_walk_speed, npc_herd_id))
		return SendSyntaxMessage(playerid, "/createnpc [k�yafet id] [can] [z�rh] [hasar] [y�r�me h�z�] [s�r� id(-1 yok)]");

	if(npc_skin < 1)
		return SendErrorMessage(playerid, "Ge�ersiz k�yafet.");

	if(npc_health < 1)
		return SendErrorMessage(playerid, "Ge�ersiz can.");

	if(npc_armour < 1)
		return SendErrorMessage(playerid, "Ge�ersiz z�rh.");

	if(npc_damage < 1)
		return SendErrorMessage(playerid, "Ge�ersiz hasar.");

	if(npc_walk_speed < 1 || npc_walk_speed > 10)
		return SendErrorMessage(playerid, "Ge�ersiz y�r�me h�z�.");
	
	if(npc_herd_id != -1)
	{
		new Cache: search, query[64];
	
		mysql_format(SQL_Handle, query, sizeof(query), "SELECT * FROM `npcs_herds` WHERE `herd_id` = '%d'", npc_herd_id);
		search = mysql_query(SQL_Handle, query);
		
		new rows = cache_num_rows();

		if(!rows)
		{
			SendErrorMessage(playerid, "S�r� numaras� bulunamad�. </listherds>");
			cache_delete(search);
			return 1; 
		}

		cache_delete(search);
	}

	GetPlayerPos(playerid, Character[playerid][Character_PosX], Character[playerid][Character_PosY], Character[playerid][Character_PosZ]);
	new id = CreateNPCEx(npc_herd_id, npc_skin, npc_health, npc_armour, npc_damage, npc_walk_speed, Character[playerid][Character_PosX], Character[playerid][Character_PosY], Character[playerid][Character_PosZ]);

	if(id == -1)
		return SendErrorMessage(playerid, "NPC olu�turulamad�.");

	SendServerMessage(playerid, "NPC ba�ar�yla olu�turuldu. (NPC ID: %d)", id);
	return 1;
}

CMD:deletenpc(playerid, params[])
{
	new npc_id;
	if(sscanf(params, "d", npc_id))
		return SendSyntaxMessage(playerid, "/deletenpc [NPC ID]");

	npc_id = FindNPCArrayID(npc_id);

	if(NPCInfo[npc_id][NPC_database_id] < 1)
		return SendErrorMessage(playerid, "B�yle bir NPC yok yada verilerine ula��lam�yor.");

	SendServerMessage(playerid, "%s(%d) isimli NPC silindi. (s�r� ID: %d)", NPCInfo[npc_id][NPC_name], npc_id, NPCInfo[npc_id][NPC_herd_id]);
	NPC_Delete(npc_id);
	return 1;
}


CMD:deletetable(playerid)
{
	new id = IsCharNearCraftTable(playerid);

	if(id == -1) return SendErrorMessage(playerid, "Herhangi bir �retim masas�n�n yak�n�nda de�ilsiniz veya bu masa �u anda kullan�l�yor.");

	if(!IsValidDynamicArea(id)) return SendErrorMessage(playerid, "Bu masa art�k yok.");

	new data[enum_tables];

	Streamer_GetArrayData(STREAMER_TYPE_AREA, id, E_STREAMER_EXTRA_ID, data);

	DestroyDynamicObject(data[tableObjectID]);
	DestroyDynamicArea(id);
	if(IsValidDynamic3DTextLabel(data[tableText])) DestroyDynamic3DTextLabel(data[tableText]);

	new query[54];

	format(query, sizeof(query), "DELETE FROM tables WHERE table_id = %d", data[tableID]);
	mysql_tquery(SQL_Handle, query);

	data[tableType] = 0;
	data[tableUsing] = 1;

	SendServerMessage(playerid, "Masa silindi.");
	return 1;
}

CMD:createloot(playerid, params[])
{
	new type;
	
	if(sscanf(params, "i", type))
	{
		SendSyntaxMessage(playerid, "/createloot [tip]");
		SendClientMessageEx(playerid, COLOR_CLIENT, "Tipler: market(1), elektronik(2), polis departman�(3), medikal(4)");
		return 1;
	}
	
	if(type < 1 || type > 4) return SendClientMessageEx(playerid, COLOR_CLIENT, "Tipler: market(1), elektronik(2), polis departman�(3), medikal(4)");
	
	LootPlaces_Create(playerid, type);
	return 1;
}

CMD:deleteloot(playerid, params[])
{
	new id;
	
	if(sscanf(params, "d", id)) return SendSyntaxMessage(playerid, "/deleteloot [id]");
	
	if(!Iter_Contains(lootplace, id)) return SendErrorMessage(playerid, "Belirtilen ID'de loot b�lgesi yok.");
	
    LootPlaces_Delete(id);

    SendServerMessage(playerid, "%d id'li loot b�lgesi silindi.", id);
	return 1;
}

CMD:editloot(playerid, params[])
{
	new id, operation[8], str[16];

	if(sscanf(params, "ds[8]S()[16]", id, operation, str)) return SendSyntaxMessage(playerid, "/editloot [id] [dispos/icpos/tip]");
	
	if(!Iter_Contains(lootplace, id)) return SendErrorMessage(playerid, "Belirtilen ID'de loot b�lgesi yok.");
	
	if(!strcmp(operation, "dispos", true))
	{
	    GetPlayerPos(playerid, Character[playerid][Character_PosX], Character[playerid][Character_PosY], Character[playerid][Character_PosZ]);

 		LootPlace[id][LP_Interior] = GetPlayerInterior(playerid);
    	LootPlace[id][LP_World] = GetPlayerVirtualWorld(playerid);

    	LootPlace[id][LP_X] = Character[playerid][Character_PosX];
    	LootPlace[id][LP_Y] = Character[playerid][Character_PosY];
    	LootPlace[id][LP_Z] = Character[playerid][Character_PosZ];
    	
    	SendServerMessage(playerid, "%d id'sine tan�ml� loot b�lgesinin d�� pozisyonu g�ncellendi.", id);
	}
	else if(!strcmp(operation, "icpos", true))
	{
	    GetPlayerPos(playerid, Character[playerid][Character_PosX], Character[playerid][Character_PosY], Character[playerid][Character_PosZ]);

 		LootPlace[id][LP_InInterior] = GetPlayerInterior(playerid);

 	    LootPlace[id][LP_InX] = Character[playerid][Character_PosX];
    	LootPlace[id][LP_InY] = Character[playerid][Character_PosY];
    	LootPlace[id][LP_InZ] = Character[playerid][Character_PosZ];
 		
 		SendServerMessage(playerid, "%d id'sine tan�ml� loot b�lgesinin i� pozisyonu g�ncellendi.", id);
	}
	else if(!strcmp(operation, "tip", true))
	{
		new type;
		if(sscanf(str, "i", type))
		{
			SendSyntaxMessage(playerid, "/editloot [%d] [tip]", id);
			return SendClientMessageEx(playerid, COLOR_CLIENT, "Tipler: market(1), elektronik(2), polis departman�(3), medikal(4)");
		}
		
		if(type < 1 || type > 4) return SendClientMessageEx(playerid, COLOR_CLIENT, "Tipler: market(1), elektronik(2), polis departman�(3), medikal(4)");
		
		if(type == LootPlace[id][LP_Type]) return SendErrorMessage(playerid, "Loot b�lgesi zaten bu tipe tan�ml�.");
		
		LootPlace[id][LP_Type] = type;
		SendServerMessage(playerid, "%d id'sine tan�ml� loot b�lgesinin tipi g�ncellendi.", id);
	}
	
	LootPlaces_Save(id);
	return 1;
}

CMD:gotoloot(playerid, params[])
{
	new id;

	if(sscanf(params, "d", id)) return SendSyntaxMessage(playerid, "/gotoloot [id]");

	if(!Iter_Contains(lootplace, id)) return SendErrorMessage(playerid, "Belirtilen ID'de loot b�lgesi yok.");

	SetPlayerInterior(playerid, LootPlace[id][LP_Interior]);
	SetPlayerVirtualWorld(playerid, LootPlace[id][LP_World]);
	SetPlayerPos(playerid, LootPlace[id][LP_X], LootPlace[id][LP_Y], LootPlace[id][LP_Z]);
	SetCameraBehindPlayer(playerid);
	return 1;
}

CMD:createditem(playerid, params[])
{
	new item, amount;
	if(sscanf(params, "ii", item, amount)) return SendSyntaxMessage(playerid, "/createditem [e�ya numaras�] [miktar]");
	if(amount < 1) return SendErrorMessage(playerid, "Girilen miktar 1'den k���k olamaz.");
	
	if(item < 0 || item > sizeof(Items)-1)
	{
	    SendErrorMessage(playerid, "Girilen e�ya numaras� 0 say�s�ndan k���k, %d say�s�ndan b�y�k olamaz.", sizeof(Items)-1);
	    return 1;
	}
	
	DroppedItem_Create(playerid, item, amount);
	SendServerMessage(playerid, "%s adl� e�ya eklendi.", Items[item][Item_Name]);
	return 1;
}

CMD:deleteditem(playerid, params[])
{
	if(isnull(params)) return SendSyntaxMessage(playerid, "/deleteditem [id]");
	
	new id = strval(params);
	
	if(id <= 0) return SendErrorMessage(playerid, "Ge�ersiz ID girdiniz.");
	
	if(DroppedItem_Delete(id)) SendServerMessage(playerid, "E�ya ID %d silindi.", id);
	else SendErrorMessage(playerid, "Ge�ersiz ID girdiniz.");
	return 1;
}

CMD:additem(playerid, params[])
{
	new target, item, amount;

	if(sscanf(params, "udd", target, item, amount)) return SendSyntaxMessage(playerid, "/additem [id/isim] [e�ya numaras�] [miktar]");

    if(!IsPlayerConnected(target)) return SendErrorMessage(playerid, "Ki�i oyunda de�il.");
    if(!Account[target][Account_IsPlaying]) return SendErrorMessage(playerid, "Ki�i giri� yapmam��.");

    if(amount < 1) return SendErrorMessage(playerid, "Girilen miktar 1'den k���k olamaz.");

	if(item < 0 || item > sizeof(Items)-1)
	{
	    SendErrorMessage(playerid, "Girilen e�ya numaras� 0 say�s�ndan k���k, %d say�s�ndan b�y�k olamaz.", sizeof(Items)-1);
	    return 1;
	}
	
	if(!IsCharacterCanGetThisItem(target, item, amount)) return SendServerMessage(playerid, "Ki�inin envanteri dolu, bu e�yay� alamaz.");
	
	Inventory_AddItem(target, item, amount);
	
	SendServerMessage(playerid, "%s adl� ki�iye %s e�yas�ndan %d adet verdin.", ReturnName(target), Items[item][Item_Name], amount);
	SendServerMessage(target, "Yetkili %s, size %s e�yas�ndan %d adet verdi.", Account[playerid][Account_Name], Items[item][Item_Name], amount);
	return 1;
}

CMD:deleteitem(playerid, params[])
{
	new target, item, amount;

	if(sscanf(params, "udd", target, item, amount)) return SendSyntaxMessage(playerid, "/deleteitem [id/isim] [e�ya numaras�] [miktar (-1 girerseniz e�ya tamamen silinir)] ");
	
    if(!IsPlayerConnected(target)) return SendErrorMessage(playerid, "Ki�i oyunda de�il.");
    if(!Account[target][Account_IsPlaying]) return SendErrorMessage(playerid, "Ki�i giri� yapmam��.");

	if(item < 0 || item > sizeof(Items)-1)
	{
	    SendErrorMessage(playerid, "Girilen e�ya numaras� 0 say�s�ndan k���k, %d say�s�ndan b�y�k olamaz.", sizeof(Items)-1);
	    return 1;
	}

	Inventory_Remove(target, item, amount);
	
	SendServerMessage(playerid, "%s adl� ki�inin %d miktar %s e�yas�n� sildiniz.", ReturnName(target), amount, Items[item][Item_Name]);
	SendServerMessage(target, "Yetkili %s, %d adet %s e�yan�z� sildi.", Account[playerid][Account_Name], amount, Items[item][Item_Name]);
	return 1;
}

CMD:deleteallitems(playerid, params[])
{
	new target;
	
	if(sscanf(params, "u", target)) return SendSyntaxMessage(playerid, "/deleteallitems [id/isim]");
    if(!IsPlayerConnected(target)) return SendErrorMessage(playerid, "Ki�i oyunda de�il.");
    if(!Account[target][Account_IsPlaying]) return SendErrorMessage(playerid, "Ki�i giri� yapmam��.");

	Inventory_Clear(target);
	
	SendServerMessage(playerid, "%s adl� ki�inin envanterini temizlediniz.", ReturnName(target));
	SendServerMessage(target, "Yetkili %s envanterinizi temizledi.", Account[playerid][Account_Name]);
	return 1;
}

CMD:deletesafe(playerid)
{
	new area = Character[playerid][Character_Area];
	if(area == -1 || Character[playerid][Character_AreaType] != 2) return SendErrorMessage(playerid, "Herhangi bir kasaya yak�n de�ilsiniz.");
	new data[enum_safe];
	Streamer_GetArrayData(STREAMER_TYPE_AREA, area, E_STREAMER_EXTRA_ID, data);
	DestroyDynamicObject(data[safeObject]);
	DestroyDynamicArea(area);
	new query[80];
	mysql_format(SQL_Handle, query, sizeof(query), "DELETE FROM `safes` WHERE `safe_id` = '%d'", data[safeID]);
	mysql_tquery(SQL_Handle, query);
	SendServerMessage(playerid, "Kasa silindi. (ID: %d)", data[safeID]);
	return 1;
}

bool:FCNPC_ValidateChasingPlayer(npcid, playerid)
{
	new Float:nX, Float:nY, Float:nZ;
	FCNPC_GetPosition(npcid, nX, nY, nZ);

	new Float:pX, Float:pY, Float:pZ;
	GetPlayerPos(playerid, pX, pY, pZ);

	/*static Float:climbing = 15.0;
	if(GetDistanceBetweenPoints1D(nZ, pZ) > climbing)
	{
		pZ = nZ;
		return false;
	}*/
	return true;
}

forward FCNPC_OnIdle(npcid);
public FCNPC_OnIdle(npcid)
{
	if(NPCInfo[npcid][NPC_status] == NPC_Death)
	{
		print("test");
	}
	else
	{
		new bool:check = CheckChase(npcid);
		if(check == false)
		{
			print("idle yap�l�yor");
			NPCInfo[npcid][NPC_status] = NPC_Idle;
			FCNPC_PlayIdleActions(npcid);
		}
	}
	return 1;
}

forward bool:CheckChase(npcid);
bool:CheckChase(npcid)
{
	new bool:checkattack;
	foreach(new playerid : Player)
	{
		checkattack = CheckAttack(npcid, playerid);

		if(checkattack == true)
		{
			return true;
		}

		if(checkattack == false)
		{
			if(GetDistanceBetweenPlayersEx(playerid, NPCInfo[npcid][NPC_game_id]) < 25.0 && NPCInfo[npcid][NPC_status] != NPC_Death)
			{
				new bool:calculationSuccess = FCNPC_CalculatePathToPlayer(npcid, playerid);
				if(!calculationSuccess && NPCInfo[npcid][NPC_MovePath] == FCNPC_INVALID_MOVEPATH_ID)
				{
					return false;
				}

				if(FCNPC_ValidateChasingPlayer(npcid, playerid))
				{
					FCNPC_DestroyRoamArea(npcid);
					FCNPC_StopAttack(NPCInfo[npcid][NPC_game_id]);

					NPCInfo[npcid][NPC_chaseID] = playerid;
					NPCInfo[npcid][NPC_status] = NPC_Chase;
					FCNPC_GoToPlayerOnGroundColEx(npcid, playerid, FCNPC_MOVE_TYPE_RUN);
					return true;
				}
			}
		}
	}

	return false;
}

forward bool:CheckAttack(npcid, playerid);
bool:CheckAttack(npcid, playerid)
{
	if(GetDistanceBetweenPlayersEx(playerid, NPCInfo[npcid][NPC_game_id]) < 1.0 && (GetTickCount() - NPCInfo[npcid][npcTick]) > TICK_RATE_ATTACK_AFTER_DAM)
	{
		if(!IsPlayerNPC(playerid))
		{
			if(NPCInfo[npcid][NPC_status] == NPC_Death)
				return false;

			NPCInfo[npcid][NPC_status] = NPC_Attack;

			FCNPC_AimAtPlayer(NPCInfo[npcid][NPC_game_id], playerid);
			printf("%d", GetDistanceBetweenPlayersEx(playerid, NPCInfo[npcid][NPC_game_id]));
			FCNPC_MeleeAttack(NPCInfo[npcid][NPC_game_id]);
			return true;
		}
	}
	return false;
}

FCNPC_DestroyRoamArea(npcid)
{
	if(NPCInfo[npcid][NPC_area] != INVALID_STREAMER_ID)
	{
		DestroyDynamicArea(NPCInfo[npcid][NPC_area]);
		NPCInfo[npcid][NPC_area] = INVALID_STREAMER_ID;
	}
}

public FCNPC_OnGiveDamage(npcid, damagedid, Float:amount, weaponid, bodypart)
{
	if(IsPlayerConnected(damagedid))
	{
		new Float:hp;

		GetPlayerHealth(damagedid, hp);
		ApplyAnimation(damagedid, "PED", \
	        (random(2) == 0) ? ("HIT_BACK") : ("HIT_BEHIND"), \
	            4.1, 0, 1, 1, 0, 0);
		return SetPlayerHealth(damagedid, hp - 3.5);
	}
	return 1;
}

public FCNPC_OnTakeDamage(npcid, issuerid, Float:amount, weaponid, bodypart)
{
	new npc = FindNPCArrayID(npcid);
	if(issuerid != INVALID_PLAYER_ID)
	{
		if(NPCInfo[npc][NPC_status] != NPC_Death)
		{
			if(bodypart == 9) // kafa
			{
				NPCInfo[npc][NPC_status] = NPC_Death;
				FCNPC_StopAttack(npcid);
				FCNPC_Stop(npcid);
				FCNPC_ApplyAnimation(npcid, "PED", "KO_shot_stom", 4.1, 0, 1, 1, 1, 1);
				SetTimerEx("DestroyNPC", 5000, false, "dd", npcid, issuerid);
			}

			if(bodypart == 6 || bodypart == 5)
			{
				FCNPC_Stop(npcid);
				FCNPC_ApplyAnimation(npcid, "PED", \
		        (random(2) == 0) ? ("HIT_BACK") : ("HIT_BEHIND"), \
		            4.1, 0, 1, 1, 0, 0);
			}

			if(bodypart == 8 || bodypart == 7)
			{
				FCNPC_Stop(npcid);
				FCNPC_ApplyAnimation(npcid, "PED","FALL_collapse",4.1,0,0,0,1,0);
			}
		}
	}
	return 0;
}

forward DestroyNPC(npcid, issuerid);
public DestroyNPC(npcid, issuerid)
{
	new Float:x, Float:y, Float:z, Float:r, skinid;
	r = FCNPC_GetAngle(npcid);
	skinid = FCNPC_GetSkin(npcid);
	FCNPC_GetPosition(npcid, x, y, z);

	NPC_Delete(FindNPCArrayID(npcid));
	new actor;

	actor = CreateDynamicActor(skinid, x, y, z, r);
	ApplyDynamicActorAnimation(actor, "PED", "KO_shot_stom", 4.1, 0, 1, 1, 1, 1);
	return 1;
}

timer FCNPC_OnInfectedUpdate[200](npcid)
{
	FCNPC_OnIdle(npcid);
	return 0;
}

FCNPC_PlayIdleActions(npcid)
{
	if(!FCNPC_IsMoving(NPCInfo[npcid][NPC_game_id]) || NPCInfo[npcid][NPC_status] != NPC_Death)
	{
		if(NPCInfo[npcid][NPC_area] == INVALID_STREAMER_ID)
		{
			FCNPC_StopAim(NPCInfo[npcid][NPC_game_id]);
			FCNPC_StopAttack(NPCInfo[npcid][NPC_game_id]);
			FCNPC_GetPosition(NPCInfo[npcid][NPC_game_id], NPCInfo[npcid][NPC_x], NPCInfo[npcid][NPC_y], NPCInfo[npcid][NPC_z]);
			NPCInfo[npcid][NPC_area] = CreateDynamicCircle(NPCInfo[npcid][NPC_x], NPCInfo[npcid][NPC_y], 5.0);
		}

		switch(RandomEx(0, 12))
		{
		    case 4, 8: FCNPC_RandomMoveInDynamicAreaEx(npcid);
		    default: FCNPC_Stop(NPCInfo[npcid][NPC_game_id]);
		}
	}
	return 1;
}

forward Float:GetDistanceBetweenPlayersEx(playerid, targetplayerid);
Float:GetDistanceBetweenPlayersEx(playerid, targetplayerid)
{
    if(!IsPlayerConnected(playerid) || !IsPlayerConnected(targetplayerid)) 
	{
        return -1.00;
    }

	new Float:x, Float:y, Float:z;
	if(IsPlayerNPC(targetplayerid)) FCNPC_GetPosition(targetplayerid, x, y, z);
	else GetPlayerPos(targetplayerid, x, y, z);

	return GetPlayerDistanceFromPoint(playerid, x, y, z);
}

FCNPC_RandomMoveInDynamicAreaEx(npcid, type = FCNPC_MOVE_TYPE_AUTO, mode = FCNPC_MOVE_MODE_AUTO, bool:set_angle = true, stopdelay = 250)
{
	new areaid = NPCInfo[npcid][NPC_area];
	if(areaid == INVALID_STREAMER_ID)
	{
		return false;
	}

	static Float:radius = NPC_RUN_OFFSET;
	static pathfinding = FCNPC_MOVE_PATHFINDING_NONE;
	static Float:min_distance = 0.5;
	static Float:climbing = 2.0;

	new Float:speed = 0.15444;

	new 
		Float:tX, Float:tY, Float:tZ,
		Float:tmp, 
		count = 0;

	new Float:nX, Float:nY, Float:nZ;
	FCNPC_GetPosition(NPCInfo[npcid][NPC_game_id], nX, nY, nZ);

	do 
	{
		if(count >= 100)
		{
			return 0;
		}

		Random_PointInDynamicArea(areaid, tX, tY, tZ);
		CA_FindZ_For2DCoord(tX, tY, tZ);
		tZ += 1.0;
		count++;
	} 
	while 
	(
		IsPointInWater(tX, tY) 
		|| CA_RayCastLine(nX, nY, nZ, tX, tY, tZ, tmp, tmp, tmp) 
		|| GetDistanceBetweenPoints1D(tZ, nZ) > climbing 
		|| !IsPointInDynamicArea(areaid, tX, tY, tZ)
	);

	return FCNPC_GoTo(NPCInfo[npcid][NPC_game_id], tX, tY, tZ, type, speed, mode, pathfinding, radius, set_angle, min_distance, stopdelay);
}

Random_PointInDynamicArea(areaid, &Float:tx, &Float:ty, &Float:tz)
{
	switch(GetDynamicAreaType(areaid))
	{
		case STREAMER_AREA_TYPE_CIRCLE: 
		{
			new Float:areaX, Float:areaY, Float:areaZ, Float:areaSize;
			Streamer_GetItemPos(STREAMER_TYPE_AREA, areaid, areaX, areaY, areaZ);
			Streamer_GetFloatData(STREAMER_TYPE_AREA, areaid, E_STREAMER_SIZE, areaSize);
			Random_PointInCircle(areaX, areaY, areaSize, tx, ty);
			tz = FLOAT_INFINITY;
		}
	}
}

Random_PointInCircle(Float:x, Float:y, Float:radius, &Float:tx, &Float:ty)
{
	new Float:alfa = float(random(1000000) + 1) / 1000000.0, Float:beta = float(random(1000000) + 1) / 1000000.0;
	if(beta < alfa)
	{
		SwapInt(alfa, beta);
	}

	tx = x + (beta * radius * floatcos(2.0 * FLOAT_PI * alfa / beta));
	ty = y + (beta * radius * floatsin(2.0 * FLOAT_PI * alfa / beta));
}

forward Float:CompressRotation(Float:rotation);
Float:CompressRotation(Float:rotation)
{
	return (rotation - floatround(rotation / 360.0, floatround_floor) * 360.0);
}

MovePointColCutLineExX(Float:sX, Float:sY, Float:sZ, Float:eX, Float:eY, Float:eZ, &Float:x, &Float:y, &Float:z, Float:cut_size = 0.0, bool:npcChasingPlayer = false)
{
	new Float:radius, Float:rx, Float:rz;
	x = y = z = 0.0;
	CA_RayCastLine(sX, sY, sZ, eX, eY, eZ, x, y, z);

	if(x == 0.0) x = eX;
	if(y == 0.0) y = eY;
	if(z == 0.0) z = eZ;

	if((radius = GetDistanceBetweenPoints3D(sX, sY, sZ, x, y, z)) <= 0.0) 
	{
		return false;
	}

	rx = CompressRotation(-(acos((z-sZ) / radius) - 90.0));
	rz = CompressRotation((atan2(y - sY, x - sX) - 90.0));

	if((radius-cut_size > cut_size) && (radius-cut_size > 0.0))
	{
		radius -= cut_size;
	} 
	else // reached some place like fence in front of him or anything like it.
	{
		radius = FLOAT_DEFECT;

		if(npcChasingPlayer)
		{
			return false;
		}
	}

	GetPointInFront3D(sX, sY, sZ, rx, rz, radius, x, y, z);
	return true;
}

FCNPC_GoToPlayerOnGroundColEx(npcid, playerid, type = FCNPC_MOVE_TYPE_AUTO, mode = FCNPC_MOVE_MODE_AUTO, bool:set_angle = true, stopdelay = 250)
{
	new Float:speed = 0.25444;

	static Float:radius = NPC_RUN_OFFSET;
	static pathfinding = FCNPC_MOVE_PATHFINDING_NONE;
	static Float:min_distance = 0.0;
	static Float:cut_size = 1.0;

	new 
		Float:pX, Float:pY, Float:pZ,
		Float:nX, Float:nY, Float:nZ;

	GetPlayerPos(playerid, pX, pY, pZ);
	FCNPC_GetPosition(NPCInfo[npcid][NPC_game_id], nX, nY, nZ);

	new Float:tX, Float:tY, Float:tZ;
	if(MovePointColCutLineExX(nX, nY, nZ, pX, pY, pZ, tX, tY, tZ, cut_size, true))
    {
		FCNPC_GoTo(NPCInfo[npcid][NPC_game_id], tX, tY, tZ, type, speed, mode, pathfinding, radius, set_angle, min_distance, stopdelay);
		FCNPC_ApplyAnimation(NPCInfo[npcid][NPC_game_id], "PED", "WALK_drunk");
	}
}

forward bool:FCNPC_CalculatePathToPlayer(npcid, playerid);
bool:FCNPC_CalculatePathToPlayer(npcid, playerid)
{
	if(NPCInfo[npcid][NPC_MovePath] != FCNPC_INVALID_MOVEPATH_ID && NPCInfo[npcid][NPC_status] == NPC_Attack)
	{
		return false;
	}

	new Float:npcPosX, Float:npcPosY, Float:npcPosZ;
	FCNPC_GetPosition(NPCInfo[npcid][NPC_game_id], npcPosX, npcPosY, npcPosZ);

	if(!IsPlayerInRangeOfPoint(playerid, RANGE_NPC_START_CHASE + 20.0, npcPosX, npcPosY, npcPosZ))
	{
		return false;
	}
	
	static Float:z;
	new Float:chasePosX, Float:chasePosY;
	GetPlayerPos(playerid, chasePosX, chasePosY, z);

	PathFinder_FindWay(NPCInfo[npcid][NPC_game_id], npcPosX, npcPosY, chasePosX, chasePosY, PATHFINDER_Z_DIFF, PATHFINDER_STEP_SIZE, PATHFINDER_STEP_LIMIT, PATHFINDER_MAX_STEPS);
	return true;
}

FCNPC_IsBlockedByCollision(npcid)
{
	new Float:nX, Float:nY, Float:nZ;
	FCNPC_GetPosition(npcid, nX, nY, nZ);

	new Float:pX, Float:pY, Float:pZ;
	GetPlayerPos(NPCInfo[npcid][NPC_chaseID], pX, pY, pZ);

	static Float:cut_size = 1.0;
	new Float:tX, Float:tY, Float:tZ;
	if(!MovePointColCutLineEx(nX, nY, nZ, pX, pY, pZ, tX, tY, tZ, cut_size))
	{
		return true;
	}
	return false;
}

FCNPC_CalcAndAddPathNodes(npcid, Float:nodesX[], Float:nodesY[], Float:nodesZ[], nodesSize)
{
	new 
		i,
		Last_i = -1;

	new 
		Float:Last_A = -1,
		Float:Last_Z = -1;

	while(i < nodesSize)
	{
		if(i == 0)
		{
			Last_i = i;
			Last_A = floatabs(270.0 - atan2(nodesX[i+1]-nodesX[i], nodesY[i+1]-nodesY[i]));
			Last_Z = (nodesZ[i+1]-nodesZ[i]);
			i++;
		}
		else if(i < nodesSize-1)
		{
			if(Last_A == floatabs(270.0 - atan2(nodesX[i+1]-nodesX[i], nodesY[i+1]-nodesY[i])) && CompareZ(Last_Z, (nodesZ[i+1] - nodesZ[i]), 0.3))
			{
				i++;
			}
			else
			{
				Last_A = floatabs(270.0 - atan2(nodesX[i+1]-nodesX[i], nodesY[i+1]-nodesY[i]));
				Last_Z = (nodesZ[i+1]-nodesZ[i]);

				FCNPC_AddPointToMovePath(NPCInfo[npcid][NPC_MovePath], nodesX[i+1], nodesY[i+1], nodesZ[i+1]+1.0);
				Last_i = i+1;
				i++;
			}
		}
		else
		{
			if(Last_i != nodesSize-1)
			{
				FCNPC_AddPointToMovePath(NPCInfo[npcid][NPC_MovePath], nodesX[nodesSize-1], nodesY[nodesSize-1], nodesZ[nodesSize-1]+1.0);
			}
			i++;
		}
	}
	
	FCNPC_AddPointToMovePath(NPCInfo[npcid][NPC_MovePath], nodesX[nodesSize-1] + 5.0, nodesY[nodesSize-1] + 5.0, nodesZ[nodesSize-1]+1.0);
}

CompareZ(Float:fZ, Float:fZ2, Float:difference)
{
	new Float:zdiff = floatabs(fZ - fZ2);
	if(zdiff == 0.0) return 1;
	else if(fZ < 0 && fZ2 < 0)
	{
		if(zdiff <= difference) return 1;
		return 0;
	}
	else if(fZ > 0 && fZ2 > 0)
	{
		if(zdiff <= difference) return 1;
		return 0;
	}
	return 0;
}

public OnPathCalculated(routeid, success, Float:nodesX[], Float:nodesY[], Float:nodesZ[], nodesSize)
{

	NPCInfo[routeid][NPC_MovePath] = FCNPC_CreateMovePath();
	
	FCNPC_CalcAndAddPathNodes(routeid, nodesX, nodesY, nodesZ, nodesSize);
	FCNPC_GoByMovePath(NPCInfo[routeid][NPC_game_id], NPCInfo[routeid][NPC_MovePath], .speed = 0.25444);
	return 1;
}