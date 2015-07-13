
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "cl_effects.lua" )
AddCSLuaFile( "player_hud.lua" )
AddCSLuaFile( "shared.lua" )
AddCSLuaFile("player_meta.lua")
AddCSLuaFile("main_menu.lua")

include( 'shared.lua' )

Msg("WASTEMOD: Resources loaded!")

// Serverside only stuff goes here

//VARIABLES
INITIAL_SCRAP_ON_INITIAL_SPAWN = 10000

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
	
	pl:Give( "proto_pistol" )
	pl:Give( "wm_scrapminer_placer" )
	
end

/*---------------------------------------------------------
   Name: wm_playerdeath_hook(ply, inflictor, attacker)
   Desc: Add score, effects and drop weapons
---------------------------------------------------------*/
function wm_playerdeath_hook( ply, inflictor, attacker )
	--Drop guns
	ply:SetScrap(INITIAL_SCRAP_ON_INITIAL_SPAWN)
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
hook.Add( "PlayerNoClip", "wm_disablenoclip", DisableNoclip )

/*---------------------------------------------------------
   Name: KeyPress( )
   Desc: Called whenever a player pressed a key included within the IN keys.
   http://wiki.garrysmod.com/page/Enums/IN
---------------------------------------------------------*/
function GM:KeyPress( ply, key )

end