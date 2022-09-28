AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")


function ENT:Initialize()
	self:SetModel( "models/weapons/w_eq_fraggrenade.mdl" )
	self:SetSolid( SOLID_BBOX )
	self:SetCollisionBounds( Vector( -2 , -2 , -2 ) , Vector( 2 , 2 , 2 ) )
	self:SetMoveType(MOVETYPE_FLYGRAVITY);
	self:PhysicsInit(MOVECOLLIDE_FLY_CUSTOM);
	self:SetUseType(SIMPLE_USE);

	
	local phys = self:GetPhysicsObject()
	phys:SetMass(5) --4.1 kg mine, round down.
	
	self.FuseTime = 4
	self.phys = phys
	self.LastTime = CurTime()
	if ( IsValid( phys ) ) then 
		phys:Wake() 
		phys:SetBuoyancyRatio( 5 ) 
		phys:SetDragCoefficient( 0 )
		phys:SetDamping( 0, 8 )
		phys:SetMaterial( "grenade" )
	end

	self:EmitSound( "npc/roller/blade_in.wav", 150, 100, 2, CHAN_AUTO )

end

function ENT:Think()

	local curtime = CurTime()
	self.FuseTime = self.FuseTime-(curtime-self.LastTime)
	self.LastTime = CurTime()

	if self.FuseTime < 0 then
		
		self:Remove()
		
		local HEWeight=4	
		local Radius = (HEWeight)^0.33*8*39.37

		ACF_HE( self:GetPos() + Vector(0,0,8) , Vector(0,0,1) , HEWeight , HEWeight*0.5 , self:GetOwner(), nil, self) --0.5 is standard antipersonal mine

		local Flash = EffectData()
		Flash:SetOrigin( self:GetPos() + Vector(0,0,8) )
		Flash:SetNormal( Vector(0,0,-1) )
		Flash:SetRadius( math.max( Radius, 1 ) )
		util.Effect( "ACF_Scaled_Explosion", Flash )
	end
end