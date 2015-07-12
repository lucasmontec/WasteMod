 	
ENT.Type 		= "anim"
ENT.Base 		= "base_entity"

ENT.PrintName	= "Shrapnel"
ENT.Author		= ""
ENT.Contact		= ""

ENT.Spawnable			= false
ENT.AdminSpawnable		= false
ENT.RenderGroup 		= RENDERGROUP_OPAQUE

AddCSLuaFile( "shared.lua" )
AddCSLuaFile('cl_init.lua')

Models = {
	Model("models/props_c17/canisterchunk01b.mdl"),
	Model("models/props_c17/canisterchunk01c.mdl"),
	Model("models/props_c17/canisterchunk01f.mdl"),
	Model("models/props_c17/canisterchunk01h.mdl"),
	Model("models/props_c17/canisterchunk01i.mdl")
}

/*---------------------------------------------------------
   Name: Initialize
---------------------------------------------------------*/
function ENT:Initialize()
	self:SetModel(table.Random(Models))
	self:SetModelScale( 0.4 , 0 )
	self:SetRenderMode( RENDERMODE_NORMAL )
	self:PhysicsInit( SOLID_VPHYSICS )   
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )
	self:SetCollisionGroup( COLLISION_GROUP_INTERACTIVE )

	timer.Create( "ShrapnelRemTimer_"..CurTime()..math.Rand(0,10000), 4, 1, function() if IsValid(self) and SERVER then self:Remove() end end )	
end

function ENT:Touch( entity )
	
	if entity:IsPlayer() and not (entity == self:GetOwner()) then
		entity:TakeDamage( math.random(1,6), self:GetOwner(), self )
		self:Remove()		
	end

end