AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

--[[

ACE_DefineMine( "Example-ID", {

	name               = "Im a Mine", --The full name of the mine.
	model              = "models/cyborgmatt/capacitor_small.mdl", -- The in-game model
	material           = "models/props_canal/canal_bridge_railing_01c", -- The material render. Don't add one if you prefer the default model texture.
	color              = Color(255,255,255), -- The color. Don't add one if you prefer the original color
	weight             = 4, -- The weight of this mine

	heweight           = 1, -- The HE filler mass
	fragmass           = 0.1, -- The HE frag mass
	armdelay           = 2, -- The time (in seconds) this mine needs to be ready to explode, since it was put on ground.

	setrange           = 10, -- The trace which detects the ground. Needed when the mine is looking for ground.

	triggermins        = Vector( -90, -90, -10 ), -- the trigger mins area
	triggermaxs        = Vector( 90, 90, 40 ), -- the same as above, but maxs

	digdepth           = 7.1, -- how much (in units) from the origin center of the model will be inserted into the ground?
	groundinverted     = true, -- If true, the model will be put upside down when its attached to the ground. Bounding-APL model requires it

	ignoreplayers      = false, -- Defines if the mine should be triggered by players or not. NPCs CAN DETONATE IT EVEN IF FALSE.
	shouldjump         = true, -- If true, the mine will "jump" off the ground.
	jumpforce          = 290, -- If the mine will jump, this will tell how much force will be put on it.
	detonationdelay    = 0.5, -- Same as above. How many seconds after the initial jump are required to explode

	customdetonation   = function( MineEntity ) print("a custom detonation") end, -- If needed, you can override the default detonation with this.

} )


]]


ACE_DefineMine( "APL", {

	name           = "Conventional Anti-Personnel Landmine",
	model          = "models/jaanus/wiretool/wiretool_range.mdl",
	material       = "models/props_canal/metalwall005b",
	color          = Color(255,255,255),
	weight         = 4,

	heweight       = 0.5,
	fragmass       = 0.1,
	armdelay       = 2,

	setrange       = 10,

	triggermins    = Vector( -60, -60, -10 ),
	triggermaxs    = Vector( 60, 60, 40 ),

	digdepth       = 1.05,

} )
ACE_DefineMine( "Bounding-APL", {

	name               = "Bounding Anti-Personnel Landmine",
	model              = "models/cyborgmatt/capacitor_small.mdl",
	material           = "models/props_canal/canal_bridge_railing_01c",
	color              = Color(255,255,255),
	weight             = 4,

	heweight           = 1,
	fragmass           = 0.1,
	armdelay           = 2,

	setrange           = 10,

	-- the trigger zone.
	triggermins        = Vector( -90, -90, -10 ), -- the trigger mins area,
	triggermaxs        = Vector( 90, 90, 40 ), -- the same as above, but maxs

	digdepth           = 7.1, -- how much (in units) from the origin center of the model will be inserted into the ground?
	groundinverted     = true, -- If true, the model will be put upside down when its attached to the ground. Bounding-APL model requires it

	ignoreplayers      = false, -- Defines if the mine should be triggered by players or not. NPCs CAN DETONATE IT EVEN IF FALSE.
	shouldjump         = true, -- If true, the mine will "jump" off the ground.
	jumpforce          = 290, -- If the mine will jump, this will tell how much force will be put on it.
	detonationdelay    = 0.5, -- Same as above. How many seconds after the initial jump are required to explode

} )
ACE_DefineMine( "ATL", {

	name           = "Conventional Anti-Tank Landmine",
	model          = "models/maxofs2d/button_02.mdl",
	material       = "models/props_canal/metalwall005b",
	color          = Color(255,255,255),
	weight         = 8,

	heweight       = 50,
	fragmass       = 50,
	armdelay       = 2,

	setrange       = 10,

	-- the trigger zone.
	triggermins    = Vector( -30, -30, -10 ),
	triggermaxs    = Vector( 30, 30, 40 ),

	digdepth       = 2.5,
	ignoreplayers  = true,

} )


function ENT:Initialize()

	self.Ready = false
	self.HasGround = false

end

local function ArmingMode( Mine )

	local GroundTr = {}
	GroundTr.start = Mine:GetPos() + Vector(0,0,5)
	GroundTr.endpos = Mine:GetPos() + Vector(0,0,-Mine.setrange)
	GroundTr.mask = MASK_NPCWORLDSTATIC

	local Trace = util.TraceLine(GroundTr)

	if Trace.Hit and Trace.HitWorld then

		if not Mine.HasGround then

			local Offset = Vector(0,0,Mine.digdepth)
			local Position = Trace.HitPos + (Mine.GroundInverted and Offset or -Offset )
			local Angles = Trace.HitNormal:Angle() + (Mine.GroundInverted and Angle(-90,0,0) or Angle(90,0,0) )

			Mine:SetPos( Position )
			Mine:SetAngles( Angles )
			Mine.physObj:EnableMotion(false)
			Mine.HasGround = true
		end

		timer.Simple(Mine.ArmingTime, function()
			if IsValid(Mine) then
				Mine.Ready = true
			end
		end)

	end
end

local function ActiveMode( Mine )

	local mins = Mine.triggermins
	local maxs = Mine.triggermaxs

	local TriggerData = {}
	TriggerData.start = Mine:WorldSpaceCenter()
	TriggerData.endpos = TriggerData.start
	TriggerData.ignoreworld  = true
	TriggerData.mins = mins
	TriggerData.maxs = maxs
	TriggerData.mask = MASK_SHOT_HULL
	TriggerData.filter = function( ent ) if ( ent:GetClass() ~= "ace_mine" ) then return true end end

	debugoverlay.Box(TriggerData.start, TriggerData.mins, TriggerData.maxs, 0.5, Color(255,100,0, 50))

	local TriggerTrace = util.TraceHull( TriggerData )

	if TriggerTrace.Hit and Mine.IsJumper then

		if not Mine.HasJumped then
			local FinalForce =  Mine:GetUp() * Mine.physObj:GetMass() * (Mine.GroundInverted and -Mine.JumpForce or Mine.JumpForce)

			Mine.physObj:EnableMotion(true)
			Mine.physObj:ApplyForceCenter( FinalForce )
			Mine:EmitSound("weapons/amr/sniper_fire.wav", 75, 190, 1, CHAN_WEAPON )

			Mine.HasJumped = true
		end

		timer.Simple(0.5, function()
			if IsValid(Mine) and IsValid(Mine.physObj) then
				Mine:Detonate()

			end
		end)

	elseif TriggerTrace.Hit then
		if not Mine.ignoreplayers or (Mine.ignoreplayers and not TriggerTrace.Entity:IsPlayer()) then
			Mine:Detonate()
		end
	end
end

function ENT:Think()

	--Mine will look for ground during the arming process
	if not self.Ready then
		ArmingMode( self )
	else
		ActiveMode( self )
	end
end

function ENT:Detonate()
	if self.CustomMineDetonation then self.CustomMineDetonation( self ) return end

	self:Remove()

	local HEWeight = self.HEWeight
	local FragMass = self.FragMass
	local Radius = ACE_CalculateHERadius( HEWeight )
	local ExplosionOrigin = self:LocalToWorld(Vector(0,0,5))

	ACF_HE( ExplosionOrigin, Vector(0,0,1), HEWeight, FragMass, self.DamageOwner, self, self) --0.5 is standard antipersonal mine

	local Flash = EffectData()
		Flash:SetOrigin( ExplosionOrigin )
		Flash:SetNormal( Vector(0,0,-1) )
		Flash:SetRadius( Radius )
	util.Effect( "ACF_Scaled_Explosion", Flash )

end

function ENT:CanTool(ply, _, toolname)
	if ((CPPI and self:CPPICanTool(ply, "remover")) or (not CPPI)) and toolname == "remover" then
		return true
	end

	return false
end

function ENT:CanProperty(ply, property)
	if ((CPPI and self:CPPICanTool(ply, "remover")) or (not CPPI)) and property == "remover" then
		return true
	end

	return false
end

-- Initialize the necessary data to cache the mine counter per player.
function InitializePlayerMineCounter( ply )
	ACE.MineOwners = ACE.MineOwners or {}
	ACE.MineOwners[ply] = {}
end
hook.Add( "PlayerInitialSpawn", "ACE_InitPlayerMineCounter", InitializePlayerMineCounter )

-- We dont need mines to stay on the map if the owner leaves.
function DeleteDisconnectPlayerMines( ply )
	if not ACE.MineOwners[ply] then return end
	for _, mine in ipairs(ACE.MineOwners[ply]) do
		mine:Remove()
	end
end
hook.Add( "PlayerDisconnected", "Playerleave", DeleteDisconnectPlayerMines )