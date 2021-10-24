
   
 /*--------------------------------------------------------- 
    Initializes the effect. The data is a table of data  
    which was passed from the server. 
 ---------------------------------------------------------*/ 
 function EFFECT:Init( data ) 
	
	self.Origin = data:GetOrigin()
	self.DirVec = data:GetNormal() 
	self.Velocity = data:GetScale() --Velocity of the projectile in gmod units
	self.Mass = data:GetMagnitude() --Mass of the projectile in kg
	self.Emitter = ParticleEmitter( self.Origin )
	self.Entity = data:GetEntity() -- the Ammocrate entity
	self.Scale = math.max(self.Mass * (self.Velocity/39.37)/100,1)^0.3
	self.ParticleMul = tonumber( LocalPlayer():GetInfo("acf_cl_particlemul") ) or 1

	local Tr = {}
	Tr.start = self.Origin + self.DirVec
	Tr.endpos = self.Origin - self.DirVec*12000
	local SurfaceTr = util.TraceLine( Tr )

	util.Decal("Impact.Concrete", self.Origin + self.DirVec*10, self.Origin - self.DirVec*10 )

	--debugoverlay.Cross( SurfaceTr.StartPos, 10, 3, Color(math.random(100,255),0,0) )
	--debugoverlay.Line( SurfaceTr.StartPos, self.Origin - self.DirVec*2000, 2 , Color(math.random(100,255),0,0) )

	self.Cal = self.Entity:GetNWString("Caliber", 2 )
	ACEE_SRico( self.Origin, self.Cal, self.Velocity, SurfaceTr.HitWorld )

	--the dust is for non-explosive rounds, so lets skip this. Note that APHE variants still require it in case of rico vs ground.
	local TypeIgnore = {
		HE = true,
		HEFS = true,
		HESH = true,
		HEAT = true,
		HEATFS = true,
		THEAT = true,
		THEATFS = true
	}

	 --do this if we are dealing with non-explosive rounds
	if not TypeIgnore[self.Entity.RoundType] then

		local Mat = SurfaceTr.MatType

		--concrete
		local SmokeColor = Vector(100,100,100)

		-- Dirt
		if Mat == 68 or Mat == 79 or Mat == 85 then 
			SmokeColor = Vector(117,101,70)

		-- Sand
		elseif Mat == 78 then 
			SmokeColor = Vector(200,180,116)
 
		end
	
		self:Dust( SmokeColor )

	end

	if IsValid(self.Emitter) then self.Emitter:Finish() end
end   

function EFFECT:Dust( SmokeColor )

	local PMul = self.ParticleMul
	local Vel = self.Velocity/2500
	local Mass = self.Mass

	--KE main formula
	local Energy = math.max(((Mass*(Vel^2))/2)*0.005,2)

	for i=0, math.max(self.Cal/3,1) do

		local Dust = self.Emitter:Add( "particle/smokesprites_000"..math.random(1,9), self.Origin )
		if (Dust) then
			Dust:SetVelocity(VectorRand() * math.random( 25,35*Energy) )
			Dust:SetLifeTime( 0 )
			Dust:SetDieTime( math.Rand( 0.1 , 3 )*math.max(Energy,2)/3  )
			Dust:SetStartAlpha( math.Rand( 125, 150 ) )
			Dust:SetEndAlpha( 0 )
			Dust:SetStartSize( 20*Energy )
			Dust:SetEndSize( 30*Energy )
			Dust:SetRoll( math.Rand(150, 360) )
			Dust:SetRollDelta( math.Rand(-0.2, 0.2) )			
			Dust:SetAirResistance( 100 ) 			 
			Dust:SetGravity( Vector( math.random(-5,5)*Energy, math.random(-5,5)*Energy, -70 ) )

			Dust:SetColor( SmokeColor.r,SmokeColor.g,SmokeColor.b )		
		end
	end

end

/*---------------------------------------------------------
   THINK
---------------------------------------------------------*/
function EFFECT:Think( )
	return false
end

/*---------------------------------------------------------
   Draw the effect
---------------------------------------------------------*/
function EFFECT:Render()
end

 