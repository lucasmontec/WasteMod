/*
---------------Efeitos de damage---------------
*/
function DamageEffect()
	
    if LocalPlayer():Health() >= 100 then return end
	
	local tab = {}
	tab[ "$pp_colour_addr" ] = 0
	tab[ "$pp_colour_addg" ] = -0.24 * (100-LocalPlayer():Health())/100
	tab[ "$pp_colour_addb" ] = -0.24 * (100-LocalPlayer():Health())/100
	tab[ "$pp_colour_brightness" ] = 0
	tab[ "$pp_colour_contrast" ] = 1
	tab[ "$pp_colour_colour" ] = 1
	tab[ "$pp_colour_mulr" ] = 0.15 + (0.15 * math.sin(CurTime()*((100-LocalPlayer():Health())/20)))
	tab[ "$pp_colour_mulg" ] = 0
	tab[ "$pp_colour_mulb" ] = 0

	DrawColorModify( tab )
    --DrawMotionBlur( 0.1, 0.65, 0.02 )
end
hook.Add( "RenderScreenspaceEffects", "wm_damage_effect", DamageEffect )