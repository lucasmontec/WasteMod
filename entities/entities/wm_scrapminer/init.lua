//baby! BABE!

AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( 'shared.lua' )

local alarm = Sound( "ambient/alarms/klaxon1.wav" )
local timerA = ""
local timerB = ""

local lastTimeAlarm = CurTime()
local alarmDelay = 5

local maxHealth = 250

function ENT:Initialize()
	self.Entity:SetModel( "models/props_combine/combinethumper002.mdl" )
    self.Entity:PhysicsInit(SOLID_VPHYSICS)
	self.Entity:SetMoveType(MOVETYPE_NONE)
	self.Entity:SetSolid(SOLID_VPHYSICS)
    self.Entity:SetName("Waste Miner")
	
	self.Entity:SetHealth(maxHealth)
	
	if (IsValid(self.Entity)) then
		local phys = self.Entity:GetPhysicsObject()
		if (phys:IsValid()) then
			phys:Wake()
		end
	end
	
	self.Owner = self.Entity:GetOwner()
	
	local placeSound = Sound( "physics/metal/metal_barrel_impact_hard1.wav" )
	local constSound = Sound( "ambient/machines/60hzhum.wav" )
	local scrapFound0 = Sound( "physics/concrete/concrete_break3.wav" )
	local scrapFound1 = Sound( "ambient/energy/newspark07.wav" )
	
	--self.Model:SetAnimation( AE_THUMPER_THUMP )
	self:EmitSound( placeSound, SNDLVL_100dB, 100, 1, CHAN_STATIC )
	
	--Constant sound
	self:EmitSound( constSound, SNDLVL_100dB, 100, 0.8, CHAN_STATIC )
	timerA="WM_MINER_"..CurTime().."_ID_"..self:EntIndex().."_SOUND_RESET"
	timer.Create( timerA, 60, 0, function()
		if !IsValid(self) then return end
		for k,v in pairs(player.GetAll() ) do
			if IsValid(v) then 
				if(v:GetPos():Distance(self:GetPos())<500) then
					v:ConCommand( "stopsound" )
				end
			end
			self:EmitSound( constSound, SNDLVL_75dB, 100, 0.8, CHAN_STATIC )
		end
	end)
	
	--Add owner scrap
	timerB="WM_MINER_"..CurTime().."_ID_"..self:EntIndex().."_SCRAP_COLLECT"
	timer.Create( timerB, 5, 0, function()
		if !IsValid(self) then return end
		if !IsValid(self.Owner) then return end
		self:EmitSound( scrapFound0, SNDLVL_75dB, 100, 0.5, CHAN_STATIC )
		self:EmitSound( scrapFound1, SNDLVL_75dB, 100, 1, CHAN_STATIC )
		self.Owner:AddScrap(25)
		--Place mine
		local effectdata = EffectData()
		effectdata:SetOrigin( self:GetPos() )
		effectdata:SetStart( self:GetPos() )
		effectdata:SetScale( 4 )
		util.Effect( "cball_explode", effectdata )
	end)
end

function ENT:OnTakeDamage( dmginfo )
	if self:Health() > 0 then
		self:SetHealth(self:Health()-dmginfo:GetDamage())
		local frag = 255*(self:Health()/maxHealth)
		self:SetColor(Color(frag,frag,frag))
		if CurTime()-lastTimeAlarm > alarmDelay then
			self:EmitSound( alarm, SNDLVL_75dB, 100, 0.4, CHAN_STATIC )
			lastTimeAlarm = CurTime()
		end
	else
		--Remove the miner
		local effectdata = EffectData()
		effectdata:SetOrigin( self:GetPos() + Vector(0,0,5))
		effectdata:SetStart( self:GetPos() + Vector(0,0,5))
		effectdata:SetScale( 1 )
		util.Effect( "Explosion", effectdata )
		util.BlastDamage( self, self, self:GetPos(), 60, 15 )
	
		--Stop sounds
		if !IsValid(self) then return end
		for k,v in pairs(player.GetAll() ) do
			if IsValid(v) then 
				if(v:GetPos():Distance(self:GetPos())<500) then
					v:ConCommand( "stopsound" )
				end
			end
		end
	
		timer.Remove(timerA)
		timer.Remove(timerB)
		self.Owner:SetScrapMiner(nil)
		self:Remove()
	end
end

function ENT:Touch( entidadeTocada )
 --nada
end

function ENT:Use(activator, caller)
	if (activator:IsPlayer() and activator == self.Owner) then
		local effectdata = EffectData()
		effectdata:SetOrigin( self:GetPos() + Vector(0,0,5))
		effectdata:SetStart( self:GetPos() + Vector(0,0,5))
		effectdata:SetScale( 1 )
		util.Effect( "Explosion", effectdata )
		
		if !IsValid(self) then return end
		for k,v in pairs(player.GetAll() ) do
			if IsValid(v) then 
				if(v:GetPos():Distance(self:GetPos())<500) then
					v:ConCommand( "stopsound" )
				end
			end
		end
		
		--self:EmitSound( Sound("physics/metal/metal_box_break1.wav"), SNDLVL_75dB, 100, 0.8, CHAN_STATIC )
		self:Remove()
	end
end