
function EFFECT:Init( data )
	
	local emitter = ParticleEmitter(data:GetOrigin())
		//Smoke
		for i=0, data:GetScale() do
			local particle = emitter:Add( "particle/particle_smokegrenade", data:GetOrigin() )
			if particle then
				//particle:SetAngles( AngleRand() )
				particle:SetVelocity( Vector( math.Rand(-1, 1), math.Rand(-1, 1), math.Rand(-1, 1) ) * data:GetNormal() * data:GetRadius() )
				v = math.Rand(20, 100)
				particle:SetColor( v, v, v )
				particle:SetLifeTime( 0 )
				particle:SetRoll( 0.2 ) 
				particle:SetDieTime( 0.2 )
				particle:SetStartAlpha( math.Rand(100, 200) )
				particle:SetEndAlpha( 0 )
				particle:SetStartSize( 20 )
				//particle:SetStartLength( 1 )
				particle:SetEndSize( 2 )
				//particle:SetEndLength( 4 )
			end
		end
	
		//Fire
		for i=0, data:GetScale() do
			local particle = emitter:Add( "effects/fire_cloud"..math.random(1, 2), data:GetOrigin() )
			if particle then
				//particle:SetAngles( AngleRand() )
				particle:SetVelocity( Vector( math.Rand(-2, 2), math.Rand(-2, 2), math.Rand(-2, 2) ) * data:GetNormal() * data:GetRadius() )
				v = math.Rand(80, 230)
				particle:SetColor( v, v, v )
				particle:SetLifeTime( 0 )
				particle:SetRoll( 0.2 ) 
				particle:SetAirResistance(0.5)
				particle:SetDieTime( 0.2 )
				particle:SetStartAlpha( math.Rand(100, 200) )
				particle:SetEndAlpha( 0 )
				particle:SetStartSize( 8 )
				particle:SetEndSize( 1 )
			end
		end
	emitter:Finish()
end

function EFFECT:Think()
	return false
end

function EFFECT:Render()
	return false
end