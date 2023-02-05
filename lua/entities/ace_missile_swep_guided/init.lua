AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")


function ENT:Initialize()
	self:SetModel( "models/hunter/blocks/cube025x025x025.mdl" )

	self:SetSolid( SOLID_BBOX )
	self:SetCollisionBounds( Vector( -2 , -2 , -2 ) , Vector( 2 , 2 , 2 ) )
	self:SetMoveType(MOVETYPE_FLYGRAVITY)
	self:PhysicsInit(MOVECOLLIDE_FLY_CUSTOM)
	self:SetUseType(SIMPLE_USE)

	self.MissileThrust = 1000
	self.MissileAgilityMul = 1
	self.MissileBurnTime = 15
	self.EnergyRetention = 0.95
	self.MaxTurnRate = 30

	self.Gravity = 0
	self.lastTravelTime = 50000000

	self.FuseTime = 10
	self.LastTime = CurTime()
	self.HeightOffset = Vector()

	local phys = self:GetPhysicsObject()
	self.phys = phys

	if IsValid( phys ) then
		phys:EnableMotion( true )
		phys:SetMass(20)
		phys:Wake()
		phys:SetBuoyancyRatio( 5 )
		phys:SetDragCoefficient( 0 )
		phys:SetDamping( 0, 0 )
		phys:SetMaterial( "grenade" )
		phys:EnableGravity(false)
	end

	self:EmitSound( "acf_extra/airfx/tow2.wav", 100, 100, 2, CHAN_AUTO )
end

local function GetRootVelocity(ent)
	local parent = ent:GetParent()

	if IsValid(parent) then
		return GetRootVelocity(parent)
	else
		return ent:GetVelocity()
	end
end

function ENT:Detonate()
	self.FuseTime = -1
	self:Remove()

	local HEWeight = 4
	local Radius = HEWeight ^ 0.33 * 8 * 39.37

	--ACF_HE( self:GetPos() + Vector(0,0,8) , Vector(0,0,1) , HEWeight , HEWeight*0.5 , self:GetOwner(), nil, self) --0.5 is standard antipersonal mine

	self.FakeCrate = ents.Create("acf_fakecrate2")
	self.FakeCrate:RegisterTo(self.Bulletdata)
	self.Bulletdata["Crate"] = self.FakeCrate:EntIndex()
	self:DeleteOnRemove(self.FakeCrate)

	self.Bulletdata["Flight"] = self:GetForward():GetNormalized() * self.Bulletdata["MuzzleVel"] * 39.37

	self.Bulletdata.Pos = self:GetPos() + self:GetForward() * 2

	self.CreateShell = ACF.RoundTypes[self.Bulletdata.Type].create
	self:CreateShell( self.Bulletdata )


	local Flash = EffectData()
	Flash:SetOrigin(self:GetPos() + Vector(0, 0, 8))
	Flash:SetNormal(Vector(0, 0, -1))
	Flash:SetRadius(math.max(Radius, 1))
	util.Effect( "ACF_Scaled_Explosion", Flash )
end

function ENT:PhysicsCollide()
	if self.FuseTime < 0 then return end

	self:Detonate()
end

function ENT:Think()
	local curtime = CurTime()
	local DelTime = curtime-self.LastTime

	local pos = self:GetPos()

	self.FuseTime = self.FuseTime - DelTime
	self.MissileBurnTime = self.MissileBurnTime - DelTime
	self.LastTime = curtime

	if self.IsJavelin and not self.StartDist and IsValid(self.tarent) then
		local posDiff = (self.tarent:GetPos() - pos)
		self.StartDist = Vector(posDiff.x, posDiff.y, 0):Length()
	end

	if not self.LastPos then
		self.LastPos = pos
	end

	local tr = util.QuickTrace(pos + self:GetForward() * -30, self:GetVelocity() * DelTime * 1.25, {self})

	if tr.Hit then
		debugoverlay.Cross(tr.StartPos, 10, 10, Color(255, 0, 0))
		debugoverlay.Cross(tr.HitPos, 10, 10, Color(0, 255, 0))

		self:SetPos(tr.HitPos + self:GetForward() * -18)
		self.FuseTime = -1
	else
		if self.MissileBurnTime < 0 then
			if self.MissileBurnTime > -1 then
				self:StopParticles()
			end

			self.MissileThrust = self.MissileThrust * self.EnergyRetention
			self.Gravity = 9.8 * 39.37 * DelTime
		end

		self.phys:ApplyForceCenter(20 * (self:GetForward() * self.MissileThrust + Vector(0, 0, -self.Gravity)))

		debugoverlay.Line(self.LastPos, pos, 10, Color(0, 0, 255))

		self.LastPos = pos
	end


	if IsValid( self.tarent ) then
		local posDiff = (self.tarent:GetPos() - pos)
		local dist = posDiff:Length()
		local distXY = Vector(posDiff.x, posDiff.y, 0):Length()
		local travelTime = dist / self:GetVelocity():Length()
		local TPos = (self.tarent:GetPos() + GetRootVelocity(self.tarent) * travelTime * (self.LeadMul or 1))

		if self.IsJavelin then
			-- 5000 = 125 meters or so
			-- Increase attack angle with distance, or, if within 125 meters, direct attack
			if self.StartDist > 5000 and math.deg(math.acos(distXY / dist)) < self.StartDist / 8000 then
				self.HeightOffset = Vector(0, 0, self.StartDist)
			else
				self.HeightOffset = Vector()
			end
		end

		local d = (TPos + self.HeightOffset) - pos

		if self.RadioDist and d:Length() < self.RadioDist then
			self.FuseTime = -1
		end

		local deltaTravelTime = self.lastTravelTime - travelTime
		self.lastTravelTime = travelTime

		if deltaTravelTime > 0 then -- Missile is moving away from target
			local AngAdjust = self:WorldToLocalAngles((d):Angle())
			local adjustedrate = self.MaxTurnRate * DelTime
			AngAdjust = self:LocalToWorldAngles(Angle(math.Clamp(AngAdjust.pitch, -adjustedrate, adjustedrate), math.Clamp(AngAdjust.yaw, -adjustedrate, adjustedrate), math.Clamp(AngAdjust.roll, -adjustedrate, adjustedrate)))

			self:SetAngles(AngAdjust)
		else
			self.FuseTime = self.FuseTime * 0.5
		end
	else
		self.FuseTime = -1
	end

	if self.FuseTime < 0 then
		self:Detonate()
	end
end