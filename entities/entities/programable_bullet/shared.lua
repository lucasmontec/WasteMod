 	
ENT.Type 		= "anim"
ENT.Base = "base_entity" 

ENT.PrintName	= ""
ENT.Author		= ""
ENT.Contact		= ""

ENT.Spawnable			= true
ENT.AdminSpawnable		= true
ENT.RenderGroup 		= RENDERGROUP_OPAQUE

AddCSLuaFile( "shared.lua" )
AddCSLuaFile('cl_init.lua')

/*
	Bullet explosiveness
*/
ENT.explosive = false
ENT.explode_sensor = false
ENT.explode_sensor_distance = 1000
ENT.explode_timer = false
ENT.explode_timer_time = 0.3

/*
	Bullet shrapnel
*/
ENT.shrapnel = false
ENT.shrapnel_count = 10

/*
	Bullet ricochet
*/
ENT.bounce = false
ENT.bounce_count = 4
ENT.bounce_factor = 1.5 //Energy loss/gain on bounce

function ENT:Explode()
	if IsValid(self) then
		local effectdata = EffectData()
				effectdata:SetOrigin( self:GetPos() )
				effectdata:SetRadius( 200 )
				effectdata:SetScale( 20 )
				effectdata:SetNormal( self:GetForward() )
				util.Effect( "scalable_explosion", effectdata )
				util.BlastDamage( self, self:GetOwner(), self:GetPos(), 70, math.random(15, 25) )
		
		self:EmitSound( "ambient/explosions/explode_4.wav" , 80, math.random(160,200))
		
		if SERVER then
		
			if self.shrapnel then
				for C=1, self.shrapnel_count do
					local shrp = ents.Create( "shrapnel" )
						shrp:SetPos(self:GetPos())
						shrp:Spawn()
						shrp:Activate()
						shrp:SetOwner(self:GetOwner())
						shrp:SetAngles(self:GetAngles())

					local bPhys = shrp:GetPhysicsObject()
					local Force = Vector(0,0,0)
					if self:GetVelocity():Length() > 0 then
						Force = self:GetVelocity():GetNormalized() * 2500 + Vector( math.random(-1,1), math.random(-1,1), math.random(-1,1) ) * 100
					else
						Force = Vector(math.random(-1,1), math.random(-1,1), math.random(-1,1)) * 10000
					end
					bPhys:ApplyForceCenter(Force)
				end
			end
		
			self:Remove()
		end
	end
end

/*---------------------------------------------------------
   Name: Initialize
---------------------------------------------------------*/
function ENT:Initialize()
	self:SetModel(Model("models/items/ar2_grenade.mdl"))
	self:SetModelScale( 0.5 , 0 )
	self:SetRenderMode( RENDERMODE_NORMAL )
	self:PhysicsInit( SOLID_VPHYSICS )   
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS ) 
	//self:SetCollisionGroup( COLLISION_GROUP_INTERACTIVE )
	
	//Explosive timer
	if self.explode_timer and self.explosive then
		timer.Create( "BulletExpTimer_"..CurTime()..math.Rand(0,10000), self.explode_timer_time, 1, function() if IsValid(self) then self:Explode() end end )
	end
	
	//Self remove
	timer.Create( "BulletRemTimer_"..CurTime()..math.Rand(0,10000), 20, 1, function() if IsValid(self) and SERVER then self:Remove() end end )
end

function ENT:Think()
	if self.explosive and self.explode_sensor then
		local tr = util.TraceLine( {
			start = self:GetPos(),
			endpos = self:GetPos() + self:GetForward() * self.explode_sensor_distance,
			filter = function( ent ) if ( ent ~= self ) then return true end end
		} ) 
		
		if tr.Hit then
			self:Explode()
		end
	end
	
	self:NextThink( CurTime()  )
	return true
end

function ENT:Touch( entity )
	//Kill entities
	if not entity:IsPlayer() then
		entity:TakeDamage( math.random(10,50), self:GetOwner(), self )
		self:Remove()		
	end
	
	//Kill players
	if entity:IsPlayer() and not self.explode then
		entity:TakeDamage( math.random(10,20), self:GetOwner(), self )
		self:Remove()		
	end
end

function ENT:PhysicsCollide( data, phys )
	if ( data.Speed > 60 ) then
		self:EmitSound( Sound( "Flashbang.Bounce" ) )
	end
	
	//Explosive behavior
	
	if self.explosive then
		if (self.bounce and self.bounce_count <= 0) or (not self.bounce) then
			self:Explode()
		end
	end
	
		//Bounce behavior
	
	if self.bounce then
		if self.bounce_count > 0 then
			self.bounce_count = self.bounce_count - 1
			local LastSpeed = math.max( data.OurOldVelocity:Length(), data.Speed )
			local NewVelocity = phys:GetVelocity()
			NewVelocity:Normalize()
			
			LastSpeed = math.max( NewVelocity:Length(), LastSpeed )
			
			local TargetVelocity = NewVelocity * LastSpeed * self.bounce_factor
			
			phys:SetVelocity( TargetVelocity )
		end
	end
end