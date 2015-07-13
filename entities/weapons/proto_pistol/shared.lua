AddCSLuaFile( "shared.lua" )

SWEP.Author			= "Zombie"
SWEP.Contact		= ""
SWEP.Purpose		= ""
SWEP.Instructions	= "Mouse left to fire, mouse right to program."
SWEP.PrintName  = "PROTO Pistol"

SWEP.ViewModelFOV	= 62
SWEP.ViewModelFlip	= false
SWEP.ViewModel		= "models/weapons/v_Pistol.mdl"
SWEP.WorldModel		= "models/weapons/w_Pistol.mdl"
SWEP.AnimPrefix		= "pistol"

SWEP.Spawnable			= false
SWEP.AdminSpawnable		= false

SWEP.Primary.ClipSize		= 10				// Size of a clip
SWEP.Primary.DefaultClip	= 0				// Default number of bullets in a clip
SWEP.Primary.Automatic		= false				// Automatic/Semi Auto
SWEP.Primary.Ammo			= "Pistol"

SWEP.Secondary.ClipSize		= 0					// Size of a clip
SWEP.Secondary.DefaultClip	= 0				// Default number of bullets in a clip
SWEP.Secondary.Automatic	= false				// Automatic/Semi Auto
SWEP.Secondary.Ammo			= "none"

SWEP.window = nil
SWEP.wactive = false
SWEP.timeLabel = nil

local prices = {
	["Explosive"] = 100,
	["ExplodeSensor"] = 200,
	["ExplodeTimer"] = 450,
	["Shrapnel"] = 600,
	["BBounce"] = 200
}

function SWEP:SetupDataTables()
	self:NetworkVar( "Bool", 0, "Explosive" )
	self:NetworkVar( "Bool", 1, "ExplodeSensor" )
	self:NetworkVar( "Bool", 2, "ExplodeTimer" )
	self:NetworkVar( "Bool", 3, "Shrapnel" )
	self:NetworkVar( "Bool", 4, "BBounce" )
	
	self:NetworkVar( "Float", 0, "ExplodeTimerTime" )
end

function SWEP:UpdateTimeLabel(v)
	if not self.timeLabel == nil then
		self.timeLabel:SetText( self:GetExplodeTimerTime().."s" )
	end
end

/*---------------------------------------------------------
	Initialize
---------------------------------------------------------*/
function SWEP:Initialize()
	if SERVER then
		util.AddNetworkString( "gunCustomize" ) 
	end
	self:SetExplodeTimerTime(0.3)
end


/*---------------------------------------------------------
	Reload
---------------------------------------------------------*/
function SWEP:Reload()
	self:DefaultReload( ACT_VM_RELOAD );
end


/*---------------------------------------------------------
   Think does nothing
---------------------------------------------------------*/
function SWEP:Think()
end


/*---------------------------------------------------------
	PrimaryAttack
---------------------------------------------------------*/
function SWEP:PrimaryAttack()

	// Make sure we can shoot first
	if ( !self:CanPrimaryAttack() ) then return end

	// Play shoot sound
	self:EmitSound("Weapon_AR2.Single")
	
	//Shot a programable bullet
	if(SERVER) then
		local ply = self.Owner
		local bullet = ents.Create( "programable_bullet" )
			bullet:SetPos(ply:EyePos() + ply:GetForward()*40)
			bullet:Spawn()
			bullet:Activate()
			bullet:SetOwner(ply)
			bullet:SetAngles(self.Owner:GetAngles())

		//Set bullet props
		bullet.explosive = self:GetExplosive()
		bullet.explode_sensor = self:GetExplodeSensor()
		bullet.explode_timer = self:GetExplodeTimer()
		bullet.explode_timer_time = self:GetExplodeTimerTime()
		bullet.shrapnel = self:GetShrapnel()
		bullet.bounce = self:GetBBounce()
		bullet:Set()
		
		local bPhys = bullet:GetPhysicsObject()
		local Force = ply:GetAimVector() * 10000
		bPhys:ApplyForceCenter(Force)
	end
	
	// Remove 1 bullet from our clip
	//self:TakePrimaryAmmo( 1 )
	self.BaseClass.ShootEffects( self )
	
	// Punch the player's view
	self.Owner:ViewPunch( Angle( -1, 0, 0 ) )
	
end

/*---------------------------------------------------------
	SecondaryAttack
---------------------------------------------------------*/
function SWEP:SecondaryAttack()

	//if not self:CanSecondaryAttack() then return end
	if CLIENT then
		if not self.wactive then
			self.wactive = true
			self.window = vgui.Create( "DFrame" )
			self.window:SetPos( 5, 5 )
			self.window:SetSize( 220, 240 )
			self.window:SetTitle( "Weapon customization" )
			self.window:SetVisible( true )
			self.window:SetDraggable( true )
			self.window:ShowCloseButton( true )
			self.window:SetDeleteOnClose( true )
			self.window:Center()
			self.window:MakePopup()
			self.window.OnClose = function()
				self.window = nil
				self.wactive = false
			end
			self.window.Paint = function( self, w, h )
				draw.RoundedBox( 0, 0, 0, w, h, Color( 0, 0, 0, 180 ) )
			end
			
			local currY = 40
			
			//Explosive
			
			local variable = "Explosive"
			
			local Btn = vgui.Create( "DButton", self.window )
			if self:GetExplosive() then
				Btn:SetText( "Remove "..variable )
				Btn.Paint = function( self, w, h )
					draw.RoundedBox( 0, 0, 0, w, h, Color( 41, 185, 41, 250 ) )
				end
			else
				Btn:SetText( "Install "..variable.." ("..prices[variable].." scrp)" )
				Btn.Paint = function( self, w, h )
					draw.RoundedBox( 0, 0, 0, w, h, Color( 185, 41, 41, 250 ) )
				end
			end
			Btn:SetTextColor( Color( 255, 255, 255 ) )
			Btn:SetPos( 15, currY )
			Btn:SetSize( 190, 30 )
			
			Btn.DoClick = function()
				if self:GetExplosive() then
					Btn:SetText( "Install "..variable.." ("..prices[variable].." scrp)" )
					net.Start( "gunCustomize", false )
					net.WriteString(variable)
					net.WriteBool(false)
					net.SendToServer()
					notification.AddLegacy( "+"..prices[variable].." scrap.", NOTIFY_GENERIC , 1 )
					Btn.Paint = function( self, w, h )
						draw.RoundedBox( 0, 0, 0, w, h, Color( 185, 41, 41, 250 ) )
					end
				else
					if(self:GetOwner():CanPayScrap(prices[variable])) then
						Btn:SetText( "Remove "..variable )
						net.Start( "gunCustomize", false )
						net.WriteString(variable)
						net.WriteBool(true)
						net.SendToServer()
						notification.AddLegacy( "-"..prices[variable].." scrap.", NOTIFY_GENERIC , 1 )
						Btn.Paint = function( self, w, h )
							draw.RoundedBox( 0, 0, 0, w, h, Color( 41, 185, 41, 250 ) )
						end
					else
						notification.AddLegacy( "Can't pay that upgrade!", NOTIFY_ERROR , 1 )
					end
				end
			end
			currY = currY + 30
			
			//Explosive Sensor
			
			local variable = "ExplodeSensor"
			
			local Btn = vgui.Create( "DButton", self.window )
			if self:GetExplodeSensor() then
				Btn:SetText( "Remove "..variable )
				Btn.Paint = function( self, w, h )
					draw.RoundedBox( 0, 0, 0, w, h, Color( 41, 185, 41, 250 ) )
				end
			else
				Btn:SetText( "Install "..variable.." ("..prices[variable].." scrp)" )
				Btn.Paint = function( self, w, h )
					draw.RoundedBox( 0, 0, 0, w, h, Color( 185, 41, 41, 250 ) )
				end
			end
			Btn:SetTextColor( Color( 255, 255, 255 ) )
			Btn:SetPos( 15, currY+5 )
			Btn:SetSize( 190, 30 )
			
			Btn.DoClick = function()
				if self:GetExplodeSensor() then
					Btn:SetText( "Install "..variable.." ("..prices[variable].." scrp)" )
					net.Start( "gunCustomize", false )
					net.WriteString(variable)
					net.WriteBool(false)
					net.SendToServer()
					notification.AddLegacy( "+"..prices[variable].." scrap.", NOTIFY_GENERIC , 1 )
					Btn.Paint = function( self, w, h )
						draw.RoundedBox( 0, 0, 0, w, h, Color( 185, 41, 41, 250 ) )
					end
				else
					if(self:GetOwner():CanPayScrap(prices[variable])) then
						Btn:SetText( "Remove "..variable )
						net.Start( "gunCustomize", false )
						net.WriteString(variable)
						net.WriteBool(true)
						net.SendToServer()
						notification.AddLegacy( "-"..prices[variable].." scrap.", NOTIFY_GENERIC , 1 )
						Btn.Paint = function( self, w, h )
							draw.RoundedBox( 0, 0, 0, w, h, Color( 41, 185, 41, 250 ) )
						end
					else
						notification.AddLegacy( "Can't pay that upgrade!", NOTIFY_ERROR , 1 )
					end
				end
			end
			currY = currY + 30
			
			//Explosive timer
			
			local variable = "ExplodeTimer"
			local price = 100
			local addAmt = 0.1
			local currentTime = self:GetExplodeTimerTime()
			
			local etBtn = vgui.Create( "DButton", self.window )
			local ltBtn = vgui.Create( "DButton", self.window ) //less Time <
			local mtBtn = vgui.Create( "DButton", self.window ) //more Time >
			self.timeLabel = vgui.Create( "DLabel", self.window )
			
			if self:GetExplodeTimer() then
				etBtn:SetText( "Remove "..variable )
				etBtn:SetSize( 190, 18 )
				ltBtn:Show()
				mtBtn:Show()
				self.timeLabel:SetText( string.format("%.1f", currentTime).."s" )
				etBtn.Paint = function( self, w, h )
					draw.RoundedBox( 0, 0, 0, w, h, Color( 41, 185, 41, 250 ) )
				end
			else
				etBtn:SetText( "Install "..variable.." ("..price.." scrp)" )
				etBtn:SetSize( 190, 30 )
				ltBtn:Hide()
				mtBtn:Hide()
				self.timeLabel:SetText( "" )
				etBtn.Paint = function( self, w, h )
					draw.RoundedBox( 0, 0, 0, w, h, Color( 185, 41, 41, 250 ) )
				end
			end
			etBtn:SetTextColor( Color( 255, 255, 255 ) )
			etBtn:SetPos( 15, currY + 10 )
			
			etBtn.DoClick = function()
				if self:GetExplodeTimer() then
					etBtn:SetText( "Install "..variable.." ("..price.." scrp)" )
					etBtn:SetSize( 190, 30 )
					net.Start( "gunCustomize", false )
					net.WriteString(variable)
					net.WriteBool(false)
					net.SendToServer()
					ltBtn:Hide()
					mtBtn:Hide()
					self.timeLabel:SetText( "" )
					notification.AddLegacy( "+"..price.." scrap.", NOTIFY_GENERIC, 1 )
					etBtn.Paint = function( self, w, h )
						draw.RoundedBox( 0, 0, 0, w, h, Color( 185, 41, 41, 250 ) )
					end
				else
					if(self:GetOwner():CanPayScrap(price)) then
						etBtn:SetText( "Remove "..variable )
						etBtn:SetSize( 190, 18 )
						net.Start( "gunCustomize", false )
						net.WriteString(variable)
						net.WriteBool(true)
						net.SendToServer()
						ltBtn:Show()
						mtBtn:Show()
						self.timeLabel:SetText( string.format("%.1f", currentTime).."s" )
						notification.AddLegacy( "-"..price.." scrap.", NOTIFY_GENERIC, 1 )
						etBtn.Paint = function( self, w, h )
							draw.RoundedBox( 0, 0, 0, w, h, Color( 41, 185, 41, 250 ) )
						end
					else
						notification.AddLegacy( "Can't pay that upgrade!", NOTIFY_ERROR, 1 )
					end
					
				end
			end
			
			self.timeLabel:SetPos( 95, currY+25 )
			
			ltBtn:SetText( "<" )
			ltBtn:SetSize( 20, 10 )
			ltBtn:SetTextColor( Color( 255, 255, 255 ) )
			ltBtn:SetPos( 15, currY+30 )
			ltBtn.Paint = function( self, w, h )
				draw.RoundedBox( 0, 0, 0, w, h, Color( 41, 128, 185, 250 ) )
			end
			ltBtn.DoClick = function()
				if self:GetExplodeTimerTime() - addAmt > 0.1 && currentTime - addAmt > 0.1 then
					net.Start( "gunCustomize", false )
					net.WriteString("ExplodeTimerTime")
					net.WriteFloat(self:GetExplodeTimerTime() - addAmt)
					net.SendToServer()
					currentTime = currentTime - addAmt
					self.timeLabel:SetText( string.format("%.1f", currentTime).."s" )
				end
			end
			
			mtBtn:SetText( ">" )
			mtBtn:SetSize( 20, 10 )
			mtBtn:SetTextColor( Color( 255, 255, 255 ) )
			mtBtn:SetPos( 185, currY+30 )
			mtBtn.Paint = function( self, w, h )
				draw.RoundedBox( 0, 0, 0, w, h, Color( 41, 128, 185, 250 ) )
			end
			mtBtn.DoClick = function()
				if self:GetExplodeTimerTime() + addAmt < 10 then
					net.Start( "gunCustomize", false )
					net.WriteString("ExplodeTimerTime")
					net.WriteFloat(self:GetExplodeTimerTime() + addAmt)
					net.SendToServer()
					currentTime = currentTime + addAmt
					self.timeLabel:SetText( string.format("%.1f", currentTime).."s" )
				end
			end
			currY = currY + 40
			
			//Explosive Shrapnel
			
			local variable = "Shrapnel"
			
			local Btn = vgui.Create( "DButton", self.window )
			if self:GetShrapnel() then
				Btn:SetText( "Remove "..variable )
				Btn.Paint = function( self, w, h )
					draw.RoundedBox( 0, 0, 0, w, h, Color( 41, 185, 41, 250 ) )
				end
			else
				Btn:SetText( "Install "..variable.." ("..prices[variable].." scrp)" )
				Btn.Paint = function( self, w, h )
					draw.RoundedBox( 0, 0, 0, w, h, Color( 185, 41, 41, 250 ) )
				end
			end
			Btn:SetTextColor( Color( 255, 255, 255 ) )
			Btn:SetPos( 15, currY+5 )
			Btn:SetSize( 190, 30 )
			
			Btn.DoClick = function()
				if self:GetShrapnel() then
					Btn:SetText( "Install "..variable.." ("..prices[variable].." scrp)" )
					net.Start( "gunCustomize", false )
					net.WriteString(variable)
					net.WriteBool(false)
					net.SendToServer()
					notification.AddLegacy( "+"..prices[variable].." scrap.", NOTIFY_GENERIC , 1 )
					Btn.Paint = function( self, w, h )
						draw.RoundedBox( 0, 0, 0, w, h, Color( 185, 41, 41, 250 ) )
					end
				else
					if(self:GetOwner():CanPayScrap(prices[variable])) then
						Btn:SetText( "Remove "..variable )
						net.Start( "gunCustomize", false )
						net.WriteString(variable)
						net.WriteBool(true)
						net.SendToServer()
						notification.AddLegacy( "-"..prices[variable].." scrap.", NOTIFY_GENERIC , 1 )
						Btn.Paint = function( self, w, h )
							draw.RoundedBox( 0, 0, 0, w, h, Color( 41, 185, 41, 250 ) )
						end
					else
						notification.AddLegacy( "Can't pay that upgrade!", NOTIFY_ERROR , 1 )
					end
				end
			end
			currY = currY + 30
			
			//Explosive Bounce
			
			local variable = "BBounce"
			
			local Btn = vgui.Create( "DButton", self.window )
			if self:GetBBounce() then
				Btn:SetText( "Remove "..variable )
				Btn.Paint = function( self, w, h )
					draw.RoundedBox( 0, 0, 0, w, h, Color( 41, 185, 41, 250 ) )
				end
			else
				Btn:SetText( "Install "..variable.." ("..prices[variable].." scrp)" )
				Btn.Paint = function( self, w, h )
					draw.RoundedBox( 0, 0, 0, w, h, Color( 185, 41, 41, 250 ) )
				end
			end
			Btn:SetTextColor( Color( 255, 255, 255 ) )
			Btn:SetPos( 15, currY+10 )
			Btn:SetSize( 190, 30 )
			
			Btn.DoClick = function()
				if self:GetBBounce() then
					Btn:SetText( "Install "..variable.." ("..prices[variable].." scrp)" )
					net.Start( "gunCustomize", false )
					net.WriteString(variable)
					net.WriteBool(false)
					net.SendToServer()
					notification.AddLegacy( "+"..prices[variable].." scrap.", NOTIFY_GENERIC , 1 )
					Btn.Paint = function( self, w, h )
						draw.RoundedBox( 0, 0, 0, w, h, Color( 185, 41, 41, 250 ) )
					end
				else
					if(self:GetOwner():CanPayScrap(prices[variable])) then
						Btn:SetText( "Remove "..variable )
						net.Start( "gunCustomize", false )
						net.WriteString(variable)
						net.WriteBool(true)
						net.SendToServer()
						notification.AddLegacy( "-"..prices[variable].." scrap.", NOTIFY_GENERIC , 1 )
						Btn.Paint = function( self, w, h )
							draw.RoundedBox( 0, 0, 0, w, h, Color( 41, 185, 41, 250 ) )
						end
					else
						notification.AddLegacy( "Can't pay that upgrade!", NOTIFY_ERROR , 1 )
					end
				end
			end
			//currY = currY + 30
			
		end
	end

	self.Weapon:SetNextSecondaryFire( CurTime() + 0.5 )
	return true
end

net.Receive( "gunCustomize", function( len, pl )
	//Read what to change
	local property = net.ReadString()
	
	//Read the value to change
	
	//Booleans
	if(property == "Explosive") then
		local val = net.ReadBool()
		if val then //pay money
			pl:RemoveScrap(prices[property])
		else //return money
			pl:AddScrap(prices[property])
		end
		pl:GetWeapon("proto_pistol"):SetExplosive(val)
	end
	
	if(property == "ExplodeSensor") then
		local val = net.ReadBool()
		if val then //pay money
			pl:RemoveScrap(prices[property])
		else //return money
			pl:AddScrap(prices[property])
		end
		pl:GetWeapon("proto_pistol"):SetExplodeSensor(val)
	end
	
	if(property == "ExplodeTimer") then
		local val = net.ReadBool()
		if val then //pay money
			pl:RemoveScrap(prices[property])
		else //return money
			pl:AddScrap(prices[property])
		end
		pl:GetWeapon("proto_pistol"):SetExplodeTimer(val)
	end
	
	if(property == "Shrapnel") then
		local val = net.ReadBool()
		if val then //pay money
			pl:RemoveScrap(prices[property])
		else //return money
			pl:AddScrap(prices[property])
		end
		pl:GetWeapon("proto_pistol"):SetShrapnel(val)
	end
	
	if(property == "BBounce") then
		local val = net.ReadBool()
		if val then //pay money
			pl:RemoveScrap(prices[property])
		else //return money
			pl:AddScrap(prices[property])
		end
		pl:GetWeapon("proto_pistol"):SetBBounce(val)
	end
	
	//Floats
	if(property == "ExplodeTimerTime") then
		local v = net.ReadFloat()
		pl:GetWeapon("proto_pistol"):SetExplodeTimerTime(v)
	end
	
end )