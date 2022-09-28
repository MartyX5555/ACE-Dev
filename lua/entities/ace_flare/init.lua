AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:Initialize()

    self:SetModel( "models/Items/AR2_Grenade.mdl" )
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)

    self.Heat       = self.Heat or 1
    self.Life       = self.Life or 0.1
    self.Owner      = self:GetOwner()

    self.HeatLoss = math.Round( (self.Heat - ACE.AmbientTemp) / self.Life,1)

    local phys = IsValid(self.PhysObj) and self.PhysObj or self:GetPhysicsObject()
    phys:SetMass(2)
    phys:EnableDrag( true )
    phys:SetDragCoefficient( 45 )
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

    --Timer with the purpose to reset the mark done by the findClutter. For a new cycle.
    local Iden = "Flare_"..self:EntIndex()
    timer.Create(Iden, 0.25, 0, function()
        if not IsValid(self) then timer.Stop( Iden ) timer.Remove(Iden) return end

        self.Marked = false

    end)

    if IsValid( phys ) then 
        phys:Wake() 
    end

end

do

    -- Look for flares around of one of them. The first one which catch them, will mark the rest not to do it. This resets when passes 0.5 seconds
    local function FindClutter( self )

        self.fflares    = {}
        self.HeatPos    = self:GetPos()
        self.TotalHeat  = self.Heat

        if self.Marked then return end

        local origin = self.HeatPos
        local Radius = self.Heat * 7.5

        debugoverlay.Sphere(origin, Radius, 0.1, Color(255,100,0,25), false)

        -- Get all the flares around
        do

            local nflares = ents.FindInSphere(origin, Radius)

            for k, flare in ipairs(nflares) do
                if not IsValid(flare) then goto cont end                    --skips invalid ents
                if flare:GetClass() ~= "ace_flare" then goto cont end       --skips any other class
                if flare:EntIndex() == self:EntIndex() then goto cont end   --skips the own flare

                flare.Marked = true

                self.TotalHeat = self.TotalHeat + flare.Heat

                table.insert( self.fflares, flare)

                debugoverlay.Sphere(flare:GetPos(), 100, 0.1, Color(255,0,0,25), false)

                ::cont::
            end

        end

        -- Calculates average position among the group
        do

            local sumpos = vector_origin

            for k, cflare in ipairs(self.fflares) do

                local pos = cflare:GetPos()

                sumpos = sumpos + pos

            end

            self.HeatPos = sumpos / #self.fflares

        end

        debugoverlay.Cross(self.HeatPos, 100, 0.1, Color(0,255,0), true )

    end

    function ENT:Think() 

        --kills the flare in contact with water
        if self:WaterLevel() == 3 then
            self.Heat = 0
            self:StopParticles()

            return false
        end

        self.Heat = self.Heat - (self.HeatLoss/10)

        FindClutter( self , self.Heat )

        self:NextThink( CurTime() + 0.1 )
        return true
    end

end

--Used to ignite players and npcs this flare touchs
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