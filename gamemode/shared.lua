
GM.Name 	= "WasteMod"
GM.Author 	= "Zombie"
GM.Email 	= "N/A"
GM.Website 	= "N/A"

include( 'player_meta.lua' )

--Lets derive from sanbox
DeriveGamemode( "sandbox" )

--Default team
function GM:CreateTeams( )
	team.SetUp( 1, "Free man", Color( 230, 230, 230 ), false )
end

function wm_somehook(ply,cmd)

end
hook.Add( "PlayerTick", "wm_somehook", wm_somehook );