
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "cl_effects.lua" )
AddCSLuaFile( "player_hud.lua" )
AddCSLuaFile( "shared.lua" )
AddCSLuaFile("player_meta.lua")

--Fa:s
AddCSLuaFile( "fas2_misc.lua" )
AddCSLuaFile( "fas2_unoffrifles_sounds.lua" )
AddCSLuaFile("fas2_shared.lua")
AddCSLuaFile("client/fas2_clientmenu.lua")
include( 'fas2_misc.lua' )
include( 'fas2_unoffrifles_sounds.lua' )
include( 'fas2_shared.lua' )

include( 'shared.lua' )

Msg("WASTEMOD: Resources loaded!")

// Serverside only stuff goes here

//VARIABLES
INITIAL_SCRAP_ON_INITIAL_SPAWN = 100

/*---------------------------------------------------------
   Name: gamemode:PlayerLoadout( )
   Desc: Give the player the default spawning weapons/ammo
---------------------------------------------------------*/
function GM:PlayerInitialSpawn( pl )
	
	pl:SetScrap(INITIAL_SCRAP_ON_INITIAL_SPAWN)
	
end

/*---------------------------------------------------------
   Name: gamemode:PlayerLoadout( )
   Desc: Give the player the default spawning weapons/ammo
---------------------------------------------------------*/
function GM:PlayerLoadout( pl )
	
	pl:Give( "fas2_machete" )
	pl:Give( "fas2_m1911" )
	pl:Give( "wm_scrapminer_placer" )
	
end

/*---------------------------------------------------------
   Name: wm_playerdeath_hook(ply, inflictor, attacker)
   Desc: Add score, effects and drop weapons
---------------------------------------------------------*/
function wm_playerdeath_hook( ply, inflictor, attacker )
	--Drop guns
end
hook.Add( "PlayerDeath", "wm_pdeath_hook", wm_playerdeath_hook );


/*---------------------------------------------------------
   Name: Init_Gamemode( )
   Desc: A hook to the gamemode initialization
---------------------------------------------------------*/
function wm_init_hook()

end
hook.Add( "Initialize", "wm_ini_hook",wm_init_hook );

/*---------------------------------------------------------
   Name: DisableNoclip( )
   Desc: A hook to the gamemode initialization
---------------------------------------------------------*/
local function DisableNoclip( ply )
	return false
end
hook.Add( "PlayerNoClip", "DisableNoclip", DisableNoclip )

/*---------------------------------------------------------
   Name: PlayerGiveSWEP( )
   Desc: Called when a player attempts to give themselves 
			a weapon from the Q menu. ( Left mouse clicks on an icon )
---------------------------------------------------------*/
function GM:PlayerGiveSWEP( ply, class, swep )
	if ply:GetScrap() > 50 then
		ply:RemoveScrap(50)
		return true
	end
	 return false
end

/*---------------------------------------------------------
   Name: CanDrive( )
   Desc: Called when a player attempts to drive a prop via Prop Drive
---------------------------------------------------------*/
function GM:CanDrive( ply, ent )
	return false
end

/*---------------------------------------------------------
   Name: CanProperty( )
   Desc: Controls if a property can be used or not.
---------------------------------------------------------*/
function GM:CanProperty( ply, property, ent )
	return false
end

/*---------------------------------------------------------
   Name: PlayerSpawnEffect( )
   Desc: Called to ask if player allowed to spawn a particular effect or not.
---------------------------------------------------------*/
function GM:PlayerSpawnEffect( ply, model )
	return false
end

/*---------------------------------------------------------
   Name: PlayerSpawnNPC( )
   Desc: Called to ask if player allowed to spawn a particular NPC or not.
---------------------------------------------------------*/
function GM:PlayerSpawnNPC( ply, npc_type, weapon )
	return false
end

/*---------------------------------------------------------
   Name: PlayerSpawnObject( )
   Desc: Called to ask whether player is allowed to spawn any objects.
---------------------------------------------------------*/
function GM:PlayerSpawnObject( ply, model, skin )
	--Return false to disallow him spawning anything
	if ply:GetScrap() > 25 then
		ply:RemoveScrap(25)
		return true
	end
	return false
end

/*---------------------------------------------------------
   Name: PlayerSpawnSENT( )
   Desc: Called when a player attempts to spawn an Entity from the Q menu.
---------------------------------------------------------*/
function GM:PlayerSpawnSENT( ply, class )
	--TODO Scrap and valid entities check
	if ply:GetScrap() > 80 then
		ply:RemoveScrap(80)
		return true
	end
	return false
end

/*---------------------------------------------------------
   Name: PlayerSpawnSENT( )
   Desc: Called when a player attempts to spawn an Entity from the Q menu.
---------------------------------------------------------*/
function GM:PlayerSpawnVehicle( ply, model, name, tt )
	--TODO Scrap and valid vehicles check
	return false
end