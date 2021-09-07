#define FILTERSCRIPT
#include <a_samp>

#define SERVER_DATABASE "weapons.db"

new DB:server_database;
new DBResult:database_result;

new bool:FirstSpawn[MAX_PLAYERS];

stock SaveWeapons(playerid)
{
	new query[400], melee_data[2], handgun_data[2], shotgun_data[2], sub_data[2], assault_data[2], rifle_data[2];
	GetPlayerWeaponData(playerid, 1, melee_data[0], melee_data[1]);
	GetPlayerWeaponData(playerid, 2, handgun_data[0], handgun_data[1]);
	GetPlayerWeaponData(playerid, 3, shotgun_data[0], shotgun_data[1]);
	GetPlayerWeaponData(playerid, 4, sub_data[0], sub_data[1]);
	GetPlayerWeaponData(playerid, 5, assault_data[0], assault_data[1]);
	GetPlayerWeaponData(playerid, 6, rifle_data[0], rifle_data[1]);

	format(query, sizeof(query),
	"UPDATE `WEAPONS` SET MELEE = '%d', HANDGUN = '%d', HANDGUNAMMO = '%d', SHOTGUN = '%d', SHOTGUNAMMO = '%d', SUB = '%d', SUBAMMO = '%d', ASSAULT = '%d', ASSAULTAMMO = '%d', RIFLE = '%d', RIFLEAMMO = '%d' WHERE `NAME` = '%q' COLLATE NOCASE",
	melee_data[0], handgun_data[0], handgun_data[1], shotgun_data[0], shotgun_data[1], sub_data[0], sub_data[1], assault_data[0], assault_data[1], rifle_data[0], rifle_data[1], GetName(playerid));
	database_result = db_query(server_database, query);
	db_free_result(database_result);
	return 1;
}

stock LoadWeapons(playerid)
{
    new query[256], field[64], handgun, shotgun, sub, assault, rifle, ammo = 0;
	format(query, sizeof(query), "SELECT * FROM `WEAPONS` WHERE `NAME` = '%q' COLLATE NOCASE", GetName(playerid));
	database_result = db_query(server_database, query);
	if(db_num_rows(database_result))
	{
		db_get_field_assoc(database_result, "MELEE", field, sizeof(field));
		GivePlayerWeapon(playerid, strval(field), 1);

		db_get_field_assoc(database_result, "HANDGUN", field, sizeof(field));
		handgun = strval(field);

		db_get_field_assoc(database_result, "HANDGUNAMMO", field, sizeof(field));
		ammo = strval(field);
		GivePlayerWeapon(playerid, handgun, ammo);

		db_get_field_assoc(database_result, "SHOTGUN", field, sizeof(field));
		shotgun = strval(field);

		db_get_field_assoc(database_result, "SHOTGUNAMMO", field, sizeof(field));
		ammo = strval(field);
		GivePlayerWeapon(playerid, shotgun, ammo);

		db_get_field_assoc(database_result, "SUB", field, sizeof(field));
		sub = strval(field);

		db_get_field_assoc(database_result, "SUBAMMO", field, sizeof(field));
		ammo = strval(field);
		GivePlayerWeapon(playerid, sub, ammo);

		db_get_field_assoc(database_result, "ASSAULT", field, sizeof(field));
		assault = strval(field);

		db_get_field_assoc(database_result, "ASSAULTAMMO", field, sizeof(field));
		ammo = strval(field);
		GivePlayerWeapon(playerid, assault, ammo);

		db_get_field_assoc(database_result, "RIFLE", field, sizeof(field));
		rifle = strval(field);

		db_get_field_assoc(database_result, "RIFLEAMMO", field, sizeof(field));
		ammo = strval(field);
		GivePlayerWeapon(playerid, rifle, ammo);
	}
	db_free_result(database_result);
	return 1;
}

stock GetName(playerid)
{
	new name[MAX_PLAYER_NAME];
	GetPlayerName(playerid, name, sizeof(name));
	return name;
}

public OnFilterScriptInit()
{
    server_database = db_open(SERVER_DATABASE);
    
    db_query(server_database, "CREATE TABLE IF NOT EXISTS `WEAPONS` (`NAME`, `MELEE`, `HANDGUN`, `HANDGUNAMMO`, `SHOTGUN`, `SHOTGUNAMMO`, `SUB`, `SUBAMMO`, `ASSAULT`, `ASSAULTAMMO`, `RIFLE`, `RIFLEAMMO`)");
	return 1;
}

public OnFilterScriptExit()
{
    db_close(server_database);
	return 1;
}

public OnPlayerConnect(playerid)
{
    FirstSpawn[playerid] = true;
    
	new query[300];
	format(query, sizeof(query), "SELECT * FROM `WEAPONS` WHERE `NAME` = '%q' COLLATE NOCASE", GetName(playerid));
  	database_result = db_query(server_database, query);
  	if(!db_num_rows(database_result))
	{
	    FirstSpawn[playerid] = false;
	    
	    format(query, sizeof(query),
		"INSERT INTO `WEAPONS` (`NAME`, `MELEE`, `HANDGUN`, `HANDGUNAMMO`, `SHOTGUN`, `SHOTGUNAMMO`, `SUB`, `SUBAMMO`, `ASSAULT`, `ASSAULTAMMO`, `RIFLE`, `RIFLEAMMO`) VALUES ('%q', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0')", GetName(playerid));
		database_result = db_query(server_database, query);
	}
	db_free_result(database_result);
	return 1;
}

public OnPlayerDisconnect(playerid, reason)
{
	SaveWeapons(playerid);
	return 1;
}

public OnPlayerSpawn(playerid)
{
	if(FirstSpawn[playerid] == true)
	{
	    FirstSpawn[playerid] = false;
	    LoadWeapons(playerid);
 	}
	return 1;
}

