// This is a comment
// uncomment the line below if you want to write a filterscript
//#define FILTERSCRIPT


// Includes
#include <a_samp>
#include <sscanf2>
#include <zcmd>
#include <a_mysql>

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



new BenefitPickup;

new MySQL:db_handle;

// Player info
enum pInfo {
	pName[MAX_PLAYER_NAME + 1],
 	pPassword[65],
	pMoney,
	pSkinId,
	pBenefitStatus
}

new playerInfo[MAX_PLAYERS][pInfo];




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
	ShowPlayerDialog(playerid, DIALOG_LOGIN, DIALOG_STYLE_INPUT, "Ieiet", "Lûdzu ievadiet paroli ar kuru reìistrçjâties!", "Ieiet", "Iziet");
}

// If user isn't regsitred
UserRegister(playerid)
{
    ShowPlayerDialog(playerid, DIALOG_REGISTER, DIALOG_STYLE_INPUT, "Reìistrçties", "Lûdzu ievadiet reìistrâcijas paroli!", "Reìistrçties", "Iziet");
}



public OnPlayerDisconnect(playerid, reason)
{
	return 1;
}

public OnPlayerSpawn(playerid)
{
	SetPlayerColor(playerid, COLOR_WHITE);
	GivePlayerMoney(playerid, playerInfo[playerid][pMoney]);
	SetPlayerSkin(playerid, playerInfo[playerid][pSkinId]);
    SetPlayerPos(playerid, 1760.4478,-1899.2943,13.5631);
    printf("%i", playerInfo[playerid][pBenefitStatus]);
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
	return 1;
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
 		 	if(userPassword[0] == inputtext[0])
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
	new SenderName[MAX_PLAYER_NAME + 1];
	new ReceivereName[MAX_PLAYER_NAME + 1];
	GetPlayerName(playerid, SenderName, sizeof(SenderName));
	GetPlayerName(TargetId, ReceivereName, sizeof(ReceivereName));
	if(sscanf(params,"rd", TargetId, Money))
	{
     	return SendClientMessage(playerid, COLOR_RED, "/pay [id] [summa]");
	}
	else
	{

    	if(TargetId != INVALID_PLAYER_ID)
 		{
 	    	if(GetPlayerMoney(playerid) < Money)
	 		{
 	        	SendClientMessage(playerid, COLOR_RED, "Jums nepietiek naudas!");
 	    	}
 	    	else
		 	{
  				GivePlayerMoney(TargetId, Money);
  				format(TargetMessage, sizeof(TargetMessage), "Jums %s iedeva %i$", SenderName, Money);
  				SendClientMessage(TargetId, COLOR_BLUE, TargetMessage);
  				GivePlayerMoney(playerid, - Money);
  				format(TargetMessage, sizeof(TargetMessage), "Jûs %s iedevat %i$", ReceivereName, Money);
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
	    GetPlayerName(playerid, TargetName, sizeof(TargetName));
	    GetPlayerPos(TargetId, x, y, z);
	    SetPlayerPos(playerid, x+1, y+1, z+1);
	    format(msg, sizeof(msg), "Jûs teleportçjâties pie %s!", TargetName);
	    SendClientMessage(playerid, COLOR_BLUE, msg);
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
	    GetPlayerName(playerid, TargetName, sizeof(TargetName));
	    GetPlayerName(playerid, PlayerName, sizeof(PlayerName));
	    GetPlayerPos(playerid, x, y, z);
	    SetPlayerPos(TargetId, x+1, y+1, z+1);
	    format(msg, sizeof(msg), "Jûs %s administrators teleportçjâties pie!", PlayerName);
	    SendClientMessage(playerid, COLOR_BLUE, msg);
	    format(msg1, sizeof(msg1), "Jûs teleportçjât pie sevis %s!", TargetName);
	    SendClientMessage(TargetId, COLOR_BLUE, msg1);
	}
    return 1;
}



CMD:welcome(playerid, params[])
{

	SetPlayerPos(playerid, 1825.55859, -1314.19348, 120.33050);

	return 1;
}

