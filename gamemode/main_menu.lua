
--UI variables
local mainmenu

/*
	Make a model panel for a item list
*/
function makeModelPanel()
	local AdjustableModelPanel = vgui.Create( "DPanel" )
	/*AdjustableModelPanel:SetPos( 10, 10 )
	AdjustableModelPanel:SetSize( 100, 100 )
	AdjustableModelPanel:SetLookAt( Vector( 0, 0, 0 ) )
	AdjustableModelPanel:SetModel( "models/props_borealis/bluebarrel001.mdl" )*/
	return AdjustableModelPanel
end

/*
	Systemm system
*/
function makeList()
	local Scroll = vgui.Create( "DScrollPanel", mainmenu ) //Create the Scroll panel
	Scroll:Dock(FILL)
	
	local List = vgui.Create( "DIconLayout" )
	Scroll:AddItem( List ) //List should be parented to the Scroll Panel's canvas by doing this.
	Scroll:Dock(FILL)
	List:SetSpaceY( 5 ) //Sets the space inbetween the panels on the X Axis by 5
	List:SetSpaceX( 5 ) //Sets the space inbetween the panels on the Y Axis by 5
	List:Dock(FILL)
	
	for i = 1, 35 do //Make a loop to create a bunch of panels inside of the DIconLayout
	local ListItem = List:Add( makeModelPanel() )
	//You dont need to set the position, that is done automaticly.
	end
	
end

/*
	Creates the main menu
*/
function makeMenu()
	mainmenu = vgui.Create( "DFrame" )
	mainmenu:SetTitle( "Main" )
	mainmenu:SetSize( ScrW()*0.25, ScrH()*0.25 )
	mainmenu:Center()
	mainmenu:ShowCloseButton( false )
	mainmenu:SetDraggable( false )
	makeList()
	mainmenu:SetVisible( true )
	mainmenu:MakePopup()
end

--UI methods Calling

/*
	Display the mains menu to the player
*/
function openMainMenu()
	if !IsValid(mainmenu) then
		makeMenu()
	else
		mainmenu:SetVisible( true )
	end
end
concommand.Add("+wm_openmainmenu",openMainMenu)

/*
	Shuts the main menu to the player
*/
function closeMainMenu()
	if IsValid(mainmenu) then
		mainmenu:Remove()
		mainmenu:SetVisible( false )
	end
end
concommand.Add("-wm_openmainmenu",closeMainMenu)

/*---------------------------------------------------------
   Name: CheckCustomKeys( )
   Desc: Check for custom keys not in the in key enum
---------------------------------------------------------*/
function CheckCustomKeys()
	if input.IsKeyDown( KEY_Q ) then
		LocalPlayer():ConCommand("+wm_openmainmenu")
	else
		LocalPlayer():ConCommand("-wm_openmainmenu")
	end
end
hook.Add( "Think", "wm_custom_keys_check", CheckCustomKeys )

MsgN("Wastemod: Mains loaded!")