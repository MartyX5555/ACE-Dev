
   
 /*--------------------------------------------------------- 
    Initializes the effect. The data is a table of data  
    which was passed from the server. 
 ---------------------------------------------------------*/ 
 function EFFECT:Init( data ) 
	
	self.Ent = data:GetEntity()
	self.Caliber = self.Ent:GetNWFloat( "Caliber", 10 )
	self.Origin = data:GetOrigin()
	self.DirVec = data:GetNormal() 
	self.Velocity = data:GetScale() --Mass of the projectile in kg
	self.Mass = data:GetMagnitude() --Velocity of the projectile in gmod units
	self.Emitter = ParticleEmitter( self.Origin )
	
	self.Scale = math.max(self.Mass * (self.Velocity/39.37)/100,1)^0.3

	local Tr = {}
	Tr.start = self.Origin - self.DirVec*10
	Tr.endpos = self.Origin + self.DirVec*10
	local SurfaceTr = util.TraceLine( Tr )

	util.Decal("Impact.Concrete", SurfaceTr.StartPos, self.Origin + self.DirVec*10 )

	--debugoverlay.Cross( SurfaceTr.StartPos, 10, 3, Color(math.random(100,255),0,0) )
	--debugoverlay.Line( SurfaceTr.StartPos, self.Origin + self.DirVec*10, 2 , Color(math.random(100,255),0,0) )

	--the dust is for non-explosive rounds, so lets skip this
	local TypeIgnore = {
		APHE = true,
		APHECBC = true,
		HE = true,
		HEFS = true,
		HESH = true,
		HEAT = true,
		HEATFS = true,
		THEAT = true,
		THEATFS = true
	}

 	--do this if we are dealing with non-explosive rounds. nil types are being created by HEAT, so skip it too
	if not TypeIgnore[self.Ent.RoundType] and self.Ent.RoundType ~= nil then

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

	local BulletEffect = {}
		BulletEffect.Num = 1
		BulletEffect.Src = self.Origin - self.DirVec
		BulletEffect.Dir = self.DirVec
		BulletEffect.Spread = Vector(0,0,0)
		BulletEffect.Tracer = 0
		BulletEffect.Force = 0
		BulletEffect.Damage = 0	 
	LocalPlayer():FireBullets(BulletEffect) 
	
	if self.Emitter then self.Emitter:Finish() end
 end   

function EFFECT:Dust( SmokeColor )

	local PMul = self.ParticleMul
	local Vel = self.Velocity/2500
	local Mass = self.Mass

	--KE main formula
	local Energy = math.max(((Mass*(Vel^2))/2)*0.005,2)

	for i=0, math.max(self.Caliber/3,1) do

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

 