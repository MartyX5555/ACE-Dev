AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:SpawnFunction( _, trace )

	if not trace.Hit then return end

	local SPos = (trace.HitPos + Vector(0,0,1))

	local ent = ents.Create( "ace_crewseat_loader" )
	ent:SetPos( SPos )
	ent:Spawn()
	ent:Activate()

	return ent
end

function ENT:Initialize()

	if self:GetModel() == "models/vehicles/pilot_seat.mdl" then
		self:SetPos(self:LocalToWorld(Vector(0, 15.3, -14)))
	end
	self:SetModel( "models/chairs_playerstart/sitpose.mdl" )
	self:SetMoveType(MOVETYPE_VPHYSICS);
	self:PhysicsInit(SOLID_VPHYSICS);
	self:SetUseType(SIMPLE_USE);
	self:SetSolid(SOLID_VPHYSICS);
	self:GetPhysicsObject():SetMass(60)

	self.Master = {}
	self.ACF = {}
	self.ACF.Health = 1
	self.ACF.MaxHealth = 1
	self.ACF.Armour = 1
	self.Stamina = 100 --initial stamina for crewseat
	self.LinkedGun = nil
	self.Name = "Crew Seat"

	-- List of rare names
	local rareNames = {"Mr.Marty", "RDC", "Cheezus", "KemGus", "Golem Man", "Arend", "Mac", "Firstgamerable", "kerbal cadet", "Psycho Dog", "Steve", "Ferv", "Twisted", "Red", "nrulz"}

	-- Generate a random number between 1 and 10
	local randomNum = math.random(1, 100)

	if randomNum <= 2 then
		-- Choose a rare name
		self.Name  = rareNames[math.random(1, #rareNames)]
	else
		-- Generate a random name
		local randomPrefixes = {"John", "Bob", "Sam", "Joe", "Ben", "Alex", "Chris", "David", "Eric", "Frank", "Antonio", "Ivan"}
		local randomSuffixes = {"Smith", "Johnson", "Dover", "Wang", "Kim", "Lee", "Brown", "Davis", "Evans", "Garcia", "", "Russel"}

		local randomPrefix = randomPrefixes[math.random(1, #randomPrefixes)]
		local randomSuffix = randomSuffixes[math.random(1, #randomSuffixes)]

		self.Name  = randomPrefix .. " " .. randomSuffix
	end
end

function ENT:DecreaseStamina()
	local linkedGun = self.LinkedGun
	--print("A")

	if IsValid(linkedGun) then
		local bulletWeight = 0
		local distanceToCrate = 0

		if linkedGun.BulletData then
			local ProjMass = linkedGun.BulletData.ProjMass
			local PropMass = linkedGun.BulletData.PropMass
			bulletWeight = ProjMass + PropMass -- in kgs
		end

		if IsValid(linkedGun.AmmoLink) then
			local CurAmmo = linkedGun.CurAmmo -- current key in the table
			distanceToCrate = linkedGun:GetPos():Distance(linkedGun.AmmoLink[CurAmmo]:GetPos()) -- in units
		end

		local distance_multiplier = 0.05
		local weight_multiplier = 0.95
		local staminaMultipliers = bulletWeight * weight_multiplier + distanceToCrate * distance_multiplier   --* distanceToCrate
		local staminaCost = 10 + staminaMultipliers -- take x points out of self.Stamina
		self.Stamina = math.Round(self.Stamina - staminaCost) -- Update the instance variable
		self.Stamina = math.max(self.Stamina, 20) -- so the gun doesn't take forever to reload, keep the second variable above 0 
		--print(self.Stamina)
	end
end

function ENT:IncreaseStamina()

	local staminaHeal = 0.4 -- adjust me
	self.Stamina = self.Stamina + staminaHeal -- Update the instance variable

	self.Stamina = math.Clamp(self.Stamina, 0, 100)

	return self.Stamina
end

function ENT:Think()
	if self.ACF.Health <= self.ACF.MaxHealth * 0.97 then
		ACF_HEKill(self, VectorRand(), 0)
		self:EmitSound("npc/combine_soldier/die" .. tostring(math.random(1, 3)) .. ".wav")
	end

	self:IncreaseStamina()

	self:UpdateOverlayText()
end


function ENT:OnRemove()

	for Key in pairs(self.Master) do
		if self.Master[Key] and self.Master[Key]:IsValid() then
			self.Master[Key]:Unlink( self )
		end
	end

end

function ENT:UpdateOverlayText()
	local hp = math.Round(self.ACF.Health / self.ACF.MaxHealth * 100)
	local stamina = math.Round(self.Stamina)

	local str = string.format("Health: %s%%\nStamina: %s%%\nName: %s", hp, stamina, self.Name )

	self:SetOverlayText(str)
end

