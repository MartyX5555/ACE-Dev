AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")


function ENT:Initialize()

	self:SetModel( "models/Items/AR2_Grenade.mdl" )
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)

	self.Heat 		= self.Heat or 1
	self.Life 		= self.Life or 0.1

	self.Owner 		= self:GetOwner()

	local phys = self:GetPhysicsObject()
	phys:SetMass(2)
	phys:EnableDrag( true )
	phys:SetDragCoefficient( 50 )
	phys:SetBuoyancyRatio( 2 )

	self:SetGravity( 0.01 )

	timer.Simple(0.1,function() 
		if not IsValid(self) then return end

		table.insert( ACE.contraptionEnts, self )

		ParticleEffectAttach("ACFM_Flare",4, self,1)  
	end)

	timer.Simple(self.Life, function()
		if IsValid(self) then
			self:Remove()
		end
	end)

	if ( IsValid( phys ) ) then phys:Wake() end

end

function ENT:Think() 

	if self:WaterLevel() == 3 then
		self.Heat = 0
		self:StopParticles()

		return false
	end

	self:NextThink( CurTime() + 0.1 )
	return true
end

function ENT:PhysicsCollide( Table , PhysObj )

	local HitEnt = Table.HitEntity

	if not IsValid(HitEnt) then return end

	if HitEnt:IsNPC() or (HitEnt:IsPlayer() and not HitEnt:HasGodMode()) then
		HitEnt:Ignite( self.Heat, 1 )
	end
end

function ENT:CanTool()
	return false
end