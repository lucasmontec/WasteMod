
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
