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

function SWEP:SetupDataTables()
	self:NetworkVar( "Bool", 0, "Explosive" )
	self:NetworkVar( "Bool", 1, "ExplodeSensor" )
	self:NetworkVar( "Bool", 2, "ExplodeTimer" )
	self:NetworkVar( "Bool", 3, "Shrapnel" )
	self:NetworkVar( "Bool", 4, "BBounce" )
	
	self:NetworkVar( "Float", 0, "ExplodeTimerTime" )
end

/*---------------------------------------------------------
	Initialize
---------------------------------------------------------*/
function SWEP:Initialize()
	util.AddNetworkString( "gun" ) 
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
			self.window:SetSize( 300, 150 )
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
			
			//Explosive
			
			local Btn = vgui.Create( "DButton", self.window )
			if self:GetExplosive() then
				Btn:SetText( "Remove explosive" )
			else
				Btn:SetText( "Install explosive" )
			end
			Btn:SetTextColor( Color( 255, 255, 255 ) )
			Btn:SetPos( 100, 100 )
			Btn:SetSize( 100, 30 )
			Btn.Paint = function( self, w, h )
				draw.RoundedBox( 0, 0, 0, w, h, Color( 41, 128, 185, 250 ) )
			end
			
			Btn.DoClick = function()
				if self:GetExplosive() then
					Btn:SetText( "Install explosive" )
					net.Start( "gun", false )
					net.WriteBool(false)
					net.SendToServer()
				else
					Btn:SetText( "Remove explosive" )
					net.Start( "gun", false )
					net.WriteBool(true)
					net.SendToServer()
				end
			end
		end
	end

	self.Weapon:SetNextSecondaryFire( CurTime() + 0.5 )
	return true
end

net.Receive( "gun", function( len, pl )
	self:SetExplosive(net.ReadBool())
end )