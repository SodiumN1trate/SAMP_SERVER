// This is a comment
// uncomment the line below if you want to write a filterscript
//#define FILTERSCRIPT


// Includes
#include <a_samp>
#include <sscanf2>
#include <zcmd>
#include <a_mysql>
#include <foreach>

// Colors
#define COLOR_GREY 0xAFAFAFAA
#define COLOR_GREEN 0x33AA33AA
#define COLOR_RED 0xAA3333AA
#define COLOR_YELLOW 0xFFFF00AA
#define COLOR_WHITE 0xFFFFFFAA
#define COLOR_BLUE 0x428af5AA

// Dialog's
#define DIALOG_LOGIN 0
#define DIALOG_REGISTER 1
#define DIALOG_EXIT 2
#define DIALOG_ENTER 3



//pickups
new BenefitPickup;

new MySQL:db_handle;

// Player info
enum pInfo {
	pName[MAX_PLAYER_NAME + 1],
 	pPassword[65],
	pMoney,
	pSkinId,
	pBenefitStatus,
	pInInteriorId,
}

new playerInfo[MAX_PLAYERS][pInfo];


// Houses
enum hInfo {
	hId,
	hPickup,
	hExitPickup,
	Float:hExitX,
	Float:hExitY,
	Float:hExitZ,
	hClass,
	hPrice,
	hOwner[MAX_PLAYER_NAME + 1]
}

new houseInfo[100][hInfo];

new HouseCount;

// Message
stock message(playerid, color, pmessage[100], Float:range)
{
	new Float:x, Float:y, Flaot:z;
	GetPlayerPos(playerid, x, y, z);
	foreach(Player, i)
	{
	 	if(IsPlayerInRangeOfPoint(playerid, range, x, y, z))
 		{
 	    	SendClientMessage(playerid, color, pmessage);
 		}
	}
}



#if defined FILTERSCRIPT

public OnFilterScriptInit()
{
	print("\n--------------------------------------");
	print(" Blank Filterscript by your name here");
	print("--------------------------------------\n");
	return 1;
}

public OnFilterScriptExit()
{
	return 1;
}

#else

main()
{
	print("\n----------------------------------");
	print("                SONI");
	print("----------------------------------\n");
}

#endif


public OnGameModeInit()
{
	EnableStuntBonusForAll(0);
	ShowPlayerMarkers(2);
	DisableInteriorEnterExits();
	SetGameModeText("SONI");
	LimitPlayerMarkerRadius(100.0);
	db_handle = mysql_connect_file("mysql.ini");
	mysql_log(ALL);
	
	if(mysql_errno(db_handle) != 0)
    {
        printf("** [MySQL] Couldn't connect to the database (%d).", mysql_errno(db_handle));
    }
    else
    {
        printf("** [MySQL] Connected to the database successfully (%d).", _:db_handle);
    }
	
    BenefitPickup = CreatePickup(1274, 1, 1770.4867,-1889.2371,13.5607, -1);
    
    
    new Cache:result, Float:x, Float:y, Float:z, row, column, tests;
    row = 0;
    column = 0;
    result = mysql_query(db_handle, "SELECT COUNT(*) FROM `houses`");
    cache_get_value_index_int(0, 0, HouseCount);
	result = mysql_query(db_handle, "SELECT * FROM `houses`");
	for(new i = 0; i < HouseCount; i++)
	{
		printf("%i", row);
	    cache_get_value_index_float(row, column + 1, x);
	    cache_get_value_index_float(row, column + 2, y);
	    cache_get_value_index_float(row, column + 3, z);
	    houseInfo[i][hPickup] = CreatePickup(1273, 1, x, y, z, -1);
    	houseInfo[i][hExitX] = x;
    	houseInfo[i][hExitY] = y;
    	houseInfo[i][hExitZ] = z;
        cache_get_value_index_int(row, column + 4,  houseInfo[i][hClass]);
        cache_get_value_index_int(row, column + 4,  tests);
        cache_get_value_index_int(row, column + 5,  houseInfo[i][hPrice]);
        cache_get_value_index(row, column + 6,  houseInfo[i][hOwner]);
        houseInfo[i][hExitPickup] = CreatePickup(19197, 1, 266.4985,305.0623,999.1484, i);
   	    row = row + 1;
	}
	cache_delete(result);
	return 1;
}

public OnGameModeExit()
{
	return 1;
}

public OnPlayerRequestClass(playerid, classid)
{
    SetPlayerPos(playerid, 1825.1129, -1312.3657, 122.2873);
	SetPlayerCameraPos(playerid, 1825.2332, -1313.6414, 121.1312);
	SetPlayerCameraLookAt(playerid, 1825.2385, -1314.6379, 120.8848);
	return 1;
}

public OnPlayerConnect(playerid)
{
    new msg[80], Cache:result, PlayerName[MAX_PLAYER_NAME + 1] ;
    GetPlayerName(playerid, PlayerName, sizeof(PlayerName));
    playerInfo[playerid][pName] = PlayerName;
    format(msg, sizeof(msg), "SELECT `username` FROM `users` WHERE `username` = '%s'", playerInfo[playerid][pName]);
    result = mysql_query(db_handle, msg);
	if(cache_num_rows() == 0)
	{
	    UserRegister(playerid);
	}
	else
	{
	    UserLogin(playerid);
	}
	cache_delete(result);
    return 1;
}

// If user is regsitred
UserLogin(playerid)
{
	ShowPlayerDialog(playerid, DIALOG_LOGIN, DIALOG_STYLE_PASSWORD, "Ieiet", "Lûdzu ievadiet paroli ar kuru reìistrçjâties!", "Ieiet", "Iziet");
}

// If user isn't regsitred
UserRegister(playerid)
{
    ShowPlayerDialog(playerid, DIALOG_REGISTER, DIALOG_STYLE_PASSWORD, "Reìistrçties", "Lûdzu ievadiet reìistrâcijas paroli!", "Reìistrçties", "Iziet");
}



public OnPlayerDisconnect(playerid, reason)
{
	new query[150];
	playerInfo[playerid][pMoney] = GetPlayerMoney(playerid);
    mysql_format(db_handle, query, sizeof(query), "UPDATE `users` SET `money` = '%i', `skin_id` = '%i', `benefit` = '%i' WHERE `username` = '%s'", playerInfo[playerid][pMoney], playerInfo[playerid][pSkinId], playerInfo[playerid][pBenefitStatus], playerInfo[playerid][pName]);
	mysql_query(db_handle, query);
	return 1;
}

public OnPlayerSpawn(playerid)
{
	SetPlayerColor(playerid, COLOR_WHITE);
	GivePlayerMoney(playerid, playerInfo[playerid][pMoney]);
	SetPlayerSkin(playerid, playerInfo[playerid][pSkinId]);
    SetPlayerPos(playerid, 1760.4478,-1899.2943,13.5631);
    
    if(playerInfo[playerid][pBenefitStatus] == 0)
	{
        SetTimerEx("benefitTimer", 10000, false, "i", playerid);
    }
	return 1;
}

public OnPlayerDeath(playerid, killerid, reason)
{
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
  	new pmessage[100];
 	format(pmessage, sizeof(pmessage), "%s: %s", playerInfo[playerid][pName], text);
 	message(playerid, -1, pmessage, 20.0);
 	return 0;
}

public OnPlayerCommandText(playerid, cmdtext[])
{
	return 1;
}

public OnPlayerEnterVehicle(playerid, vehicleid, ispassenger)
{
	SendClientMessage(playerid, -1, "Brauc uzmanîgi!");
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

public OnPlayerEnterRaceCheckpoint(playerid)
{
	return 1;
}

public OnPlayerLeaveRaceCheckpoint(playerid)
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


forward benefitTimer(playerid);
public OnPlayerPickUpPickup(playerid, pickupid)
{
	if(BenefitPickup == pickupid)
	{
	    if(playerInfo[playerid][pBenefitStatus] == 1)
		{
	    
	     	SendClientMessage(playerid, COLOR_BLUE, "Pabalsts 1000$!");
	     	GivePlayerMoney(playerid, 1000);
	     	playerInfo[playerid][pBenefitStatus] = 0;
	     	SetTimerEx("benefitTimer", 10000, false, "i", playerid);
     	}
     	else
	 	{
	 	    SendClientMessage(playerid, COLOR_RED, "Pabalstu var òemt katras 10 sekundes!");
     	}
	}
	
	else if(houseInfo[playerInfo[playerid][pInInteriorId]][hExitPickup] == pickupid)
	{
 		ShowPlayerDialog(playerid, DIALOG_EXIT, DIALOG_STYLE_MSGBOX, "Iziet", "Vai vçlaties iziet no mâjokïa?", "Piekrist", "Atcelt");
	}
	for(new i; i < HouseCount; i++)
	{
 		if(houseInfo[i][hPickup] == pickupid)
		{
		    if(houseInfo[i][hClass] == 3)
		    {
		        ShowPlayerDialog(playerid, DIALOG_ENTER, DIALOG_STYLE_MSGBOX, "Ieiet", "Vai vçlaties ieiet mâjoklî?", "Piekrist", "Atcelt");
		        playerInfo[playerid][pInInteriorId] = i;
			}
		 	
		}
	}

	
	return 1;
}

public benefitTimer(playerid){
    playerInfo[playerid][pBenefitStatus] = 1;
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
	return 1;
}

public OnRconLoginAttempt(ip[], password[], success)
{
	return 1;
}

public OnPlayerUpdate(playerid)
{
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
 	if(dialogid == DIALOG_LOGIN)
	{
		if(response)
		{
		    new query[80], userPassword[60], Cache:result;
	 		mysql_format(db_handle, query, sizeof(query), "SELECT * FROM `users` WHERE `username` = '%s';", playerInfo[playerid][pName]);
	 		result = mysql_query(db_handle, query);
 		 	cache_get_value_index(0, 2, userPassword);
 		 	if(!strcmp(userPassword[0], inputtext[0]))
 		 	{
 		 	    SendClientMessage(playerid, -1, "Laipni lûgti \"Snjus RP\"(JK)!");
 		 	    cache_get_value_index(0, 2, playerInfo[playerid][pPassword]);
 		 	    cache_get_value_index_int(0, 3, playerInfo[playerid][pMoney]);
     			cache_get_value_index_int(0, 4, playerInfo[playerid][pSkinId]);
     			cache_get_value_index_int(0, 5, playerInfo[playerid][pBenefitStatus]);
 		 	}
 		 	else
 		 	{
 		 	    SendClientMessage(playerid, COLOR_RED, "Nepareiza parole!");
 		 	    UserLogin(playerid);
 		 	}
 		 	cache_delete(result);
		}
		else
		{
	 		Kick(playerid);
  		}
		return 1;
	}
	if(dialogid == DIALOG_REGISTER)
	{
		if(response)
		{
		    new query[120], PlayerName[MAX_PLAYER_NAME + 1], Cache:result;
    		GetPlayerName(playerid, PlayerName, sizeof(PlayerName));
   			mysql_format(db_handle, query, sizeof(query), "INSERT INTO `users` (`username`, `password`, `skin_id`) VALUES ('%s', '%s', '%i')", PlayerName, inputtext, random(300));
   			mysql_query(db_handle, query);
   			SendClientMessage(playerid, -1, "Jûs veiksmîgi reìistrçjâties!");
   			SendClientMessage(playerid, -1, "Patîkamu spçlçðanu \"Snjus RP\"(JK)");
			mysql_format(db_handle, query, sizeof(query), "SELECT * FROM `users` WHERE `username` = '%s';", playerInfo[playerid][pName]);
	 		result = mysql_query(db_handle, query);
 	    	cache_get_value_index(0, 2, playerInfo[playerid][pPassword]);
	 	    cache_get_value_index_int(0, 3, playerInfo[playerid][pMoney]);
   			cache_get_value_index_int(0, 4, playerInfo[playerid][pSkinId]);
   			cache_delete(result);
		}
		else
		{
  			Kick(playerid);
  		}
		return 1;
	}
	if(dialogid == DIALOG_EXIT)
	{
	    if(response)
	    {
	        SetPlayerPos(playerid, houseInfo[playerInfo[playerid][pInInteriorId]][hExitX] + 2, houseInfo[playerInfo[playerid][pInInteriorId]][hExitY], houseInfo[playerInfo[playerid][pInInteriorId]][hExitZ] + 2);
			SetPlayerInterior(playerid, 0);
 			SetPlayerVirtualWorld(playerid, 0);
 			playerInfo[playerid][pInInteriorId] = 0;
		}
	    return 1;
	}
	if(dialogid == DIALOG_ENTER)
	{
		if(response)
		{
	 		SetPlayerInterior(playerid, 2);
	 		SetPlayerVirtualWorld(playerid, playerInfo[playerid][pInInteriorId]);
	 		SetPlayerPos(playerid,268.5076,304.9388,999.1484);

		}
		return 1;
	}
 	
	return 1;
}

public OnPlayerClickPlayer(playerid, clickedplayerid, source)
{
	return 1;
}

CMD:pay(playerid, params[])
{
    new TargetId, Money;
	new TargetMessage[128];
	if(sscanf(params,"rd", TargetId, Money))
	{
     	return SendClientMessage(playerid, COLOR_RED, "/pay [id] [summa]");
	}
	else
	{

    	if(TargetId != INVALID_PLAYER_ID)
 		{
 	    	if(GetPlayerMoney(playerid) < Money || Money <= 0)
	 		{
 	        	SendClientMessage(playerid, COLOR_RED, "Jûs to nevarat izdarît!");
 	    	}
 	    	else
		 	{
  				GivePlayerMoney(TargetId, Money);
  				format(TargetMessage, sizeof(TargetMessage), "Jums %s iedeva %i$", playerInfo[playerid][pName], Money);
  				SendClientMessage(TargetId, COLOR_BLUE, TargetMessage);
  				GivePlayerMoney(playerid, - Money);
  				format(TargetMessage, sizeof(TargetMessage), "Jûs %s iedevât %i$", playerInfo[TargetId][pName], Money);
  				SendClientMessage(playerid, COLOR_BLUE, TargetMessage);
  			}
		}
		else
		{
	    	 SendClientMessage(playerid, COLOR_RED, "Ðâds lietotâjs neeksistç");
		}

	}
    return 1;
}

CMD:setmoney(playerid, params[])
{

	if(!IsPlayerAdmin(playerid))
	{
	
		return 1;

	}
	else
	{
	    new Money;
	    new Message[100];
	    if(sscanf(params, "d", Money))
		{
			return SendClientMessage(playerid, COLOR_RED, "/setmoney [summa]");
		}
		else
		{
		    if(Money > 1000000)
			{
		    	SendClientMessage(playerid, COLOR_RED, "Nevar tik daudz vienlaicîgi òemt");
			}
			else
			{
	  			format(Message, sizeof(Message), "Jûs sev izsniedzât %i$", Money);
  				SendClientMessage(playerid, COLOR_BLUE, Message);
  				GivePlayerMoney(playerid, Money);
			}
		}
	    
	}

	return 1;

}

CMD:weapon(playerid, params[])
{
    new Weapon, Bullets;
	if(sscanf(params,"dd", Weapon, Bullets))
	{
     	return SendClientMessage(playerid, COLOR_RED, "/weapon [id] [lodes]");
	}
	else
	{
		SendClientMessage(playerid, COLOR_BLUE, "Jûs sev iedevat ieroci");
		GivePlayerWeapon(playerid, Weapon, Bullets);
	}
    return 1;
}

CMD:vehicle(playerid, params[])
{
    new vehId, Float:x, Float:y, Float:z;
	if(sscanf(params,"d", vehId))
	{
     	return SendClientMessage(playerid, COLOR_RED, "/vehicle [id]");
	}
	else
	{
	    SendClientMessage(playerid, COLOR_BLUE, "Jûs uzspawnojât sev auto!");
	    GetPlayerPos(playerid, x, y, z);
		CreateVehicle(vehId, x+1, y+1, z+1, 82.2873, 0, 0, 10);
	}
    return 1;
}

CMD:repair(playerid, params[])
{
    new vehId;
	if(sscanf(params,"", vehId))
	{
     	return SendClientMessage(playerid, COLOR_RED, "/repair");
	}
	else
	{
	    SendClientMessage(playerid, COLOR_BLUE, "Jûs salabojât savu auto!");
  		RepairVehicle(GetPlayerVehicleID(playerid));
	}
    return 1;
}

CMD:goto(playerid, params[])
{
    new TargetId, Float:x, Float:y, Float:z;
    new TargetName[MAX_PLAYER_NAME + 1];
    new msg[80];
	if(sscanf(params,"r", TargetId))
	{
     	return SendClientMessage(playerid, COLOR_RED, "/goto [id]");
	}
	else
	{
		if(TargetId != INVALID_PLAYER_ID)
		{
	    	GetPlayerName(playerid, TargetName, sizeof(TargetName));
	    	GetPlayerPos(TargetId, x, y, z);
	    	SetPlayerPos(playerid, x+1, y+1, z+1);
	    	format(msg, sizeof(msg), "Jûs teleportçjâties pie %s!", TargetName);
	    	SendClientMessage(playerid, COLOR_BLUE, msg);
	    }
	    else
	    {
	        return SendClientMessage(playerid, COLOR_RED, "Lietotâjs nav tieðsaistç!");
	 	}
	}
    return 1;
}

CMD:comehere(playerid, params[])
{
    new TargetId, Float:x, Float:y, Float:z;
    new TargetName[MAX_PLAYER_NAME + 1], PlayerName[MAX_PLAYER_NAME + 1];
    new msg[80];
    new msg1[80];
	if(sscanf(params,"r", TargetId))
	{
     	return SendClientMessage(playerid, COLOR_RED, "/comehere [id]");
	}
	else
	{
		if(TargetId != INVALID_PLAYER_ID)
		{
	    	GetPlayerName(playerid, TargetName, sizeof(TargetName));
	    	GetPlayerName(playerid, PlayerName, sizeof(PlayerName));
	    	GetPlayerPos(playerid, x, y, z);
	    	SetPlayerPos(TargetId, x+1, y+1, z+1);
	    	format(msg, sizeof(msg), "Jûs %s administrators teleportçjâties pie sevis!", PlayerName);
	    	SendClientMessage(playerid, COLOR_BLUE, msg);
	    	format(msg1, sizeof(msg1), "Jûs teleportçjât pie sevis %s!", TargetName);
	    	SendClientMessage(TargetId, COLOR_BLUE, msg1);
		}
		else
	    {
	        return SendClientMessage(playerid, COLOR_RED, "Lietotâjs nav tieðsaistç!");
	 	}
	}
    return 1;
}



CMD:sethouse(playerid, params[])
{

	new query[250], Float:x, Float:y, Float:z, Class, Price;
	if(!sscanf(params,"dd", Class, Price))
	{
		GetPlayerPos(playerid, x, y, z);
		printf("('%f', '%f', '%f', '%i', '%i')", x, y, z, Class, Price);
		mysql_format(db_handle, query, sizeof(query), "INSERT INTO `houses` (`x`, `y`, `z`, `class`, `price`) VALUES ('%f', '%f', '%f', '%i', '%i')", x, y, z, Class, Price);
		mysql_query(db_handle, query);
		SendClientMessage(playerid, COLOR_BLUE, "Jûs uzstâdijât mâju");
	}
	return 1;
}

CMD:do(playerid, params[])
{
    new pmessage[100];
 	format(pmessage, sizeof(pmessage), "%s ((%s))", params, playerInfo[playerid][pName]);
 	message(playerid, 0xC2A2DAAA, pmessage, 20.0);
 	return 1;
}
CMD:me(playerid, params[])
{
    new pmessage[100];
 	format(pmessage, sizeof(pmessage), "%s %s", playerInfo[playerid][pName], params);
 	message(playerid, 0xC2A2DAAA, pmessage, 20.0);
 	return 1;
}

