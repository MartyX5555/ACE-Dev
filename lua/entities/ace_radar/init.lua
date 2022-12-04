AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

DEFINE_BASECLASS( "base_wire_entity" )

function ENT:Initialize()

    self.Interval = 0.1

    self.Cone = 10 -- the half part of the total cone. 30 means 60 degrees in total
    self.InacCoef = 10  -- How much imprecise the target position will be. In units.
    self.MinDistance = 1000 -- Min distance which target will be considered. In units.
    self.clutterdistance = 4000 --Distance which clutter will affect the target. In units.
    self.ratiotolerance = 0.5 -- Defines how much tolerance it will have the radar to keep considering a valid target. Radar cannot see targets below this value.

    self.Detected   = 0
    self.Positions  = {}
    self.Velocities = {}
    self.Angles     = {}

    self:BuildPhysics()

    self.Inputs = WireLib.CreateInputs( self, { "Active" } )
    self.Outputs = WireLib.CreateOutputs( self, { "Detected", "Position [ARRAY]", "Velocity [ARRAY]", "Angle [ARRAY]" } )

end

function ENT:BuildPhysics(mdl)

    local mdl = "models/missiles/radar_big.mdl"
    
    self:SetModel( mdl )    
    self.Model = mdl
    
    self:PhysicsInit( SOLID_VPHYSICS )          
    self:SetMoveType( MOVETYPE_VPHYSICS )       
    self:SetSolid( SOLID_VPHYSICS )
    
    local phys = self:GetPhysicsObject()    
    if IsValid(phys) then 
        phys:SetMass(1000)
    end     
    
end

function ENT:TriggerInput( inp, value )

    if inp == "Active" then
        self.Active = true
    end

end

--Gathers all the ents in Cone and cache the used data for further operations like Distance.
function ENT:GetEntitiesInCone(  )

    local entitiesData = {}
    local radarpos      = self.CurPos
    local Cone          = self.Cone
    local MinDist       = self.MinDistance

    for k, ent in ipairs(ACE.contraptionEnts) do

        local entpos = ent:WorldSpaceCenter() 
        local diffpos = entpos - radarpos
        local AngDiff = diffpos:Angle()
        local CAngle = self:WorldToLocalAngles( AngDiff)
        local XAng = math.abs( CAngle.p )
        local YAng = math.abs( CAngle.y )

        if XAng < Cone and YAng < Cone then

            local trdata = {}
            trdata.start = radarpos
            trdata.endpos = entpos
            trdata.mask = MASK_SOLID_BRUSHONLY
            local tr = util.TraceLine(trdata)

            if not tr.Hit then

                local dist = diffpos:Length()

                if dist > MinDist then

                    local data = {}
                    data.Entity = ent
                    data.Position = entpos
                    data.Distance = dist
                    data.Angle = CAngle

                    debugoverlay.Cross(entpos, 10, 0.5, Color( 0, 255, 0 ), true)
                    table.insert(entitiesData, data )

                else
                    debugoverlay.Cross(entpos, 10, 0.5, Color( 255, 0, 0 ), true)
                end
            end
        end
    end

    return entitiesData
end


-- returns the the pos where clutter takes place. returns nil if it hits sky
function ENT:GetClutterPos()

    local radarpos = self.CurPos
    local clutterperf = 0.1--self.clutterperformance

    local trdata = {}
    trdata.start = radarpos
    trdata.endpos = radarpos + self:GetForward() * 99999
    trdata.mask = MASK_SOLID_BRUSHONLY
    trdata.mins = -Vector(self.Cone,self.Cone,self.Cone) * 10
    trdata.maxs = -trdata.mins
    local tr = util.TraceHull(trdata)

    debugoverlay.Box(tr.HitPos, trdata.mins, trdata.maxs, 0.5, Color( 255, 100, 0, 10 ) )

    if tr.HitSky then return Vector() end

    return tr.HitPos
end

function ENT:ResolveTargets()

    local radarpos  = self.CurPos
    local data      = self:GetEntitiesInCone()
    local GCpos     = self:GetClutterPos()
    local LGCpos    = self:WorldToLocal( GCpos )
    local clutterdist = self.clutterdistance
    local ratiotolerance = self.ratiotolerance

    for k, entdata in pairs(data) do

        local ent       = entdata.Entity
        local entpos    = entdata.Position
        local dist      = entdata.Distance
        local AngDiff   = entdata.Angle

        --Calculates Ground Clutter effect ratio.
        if GCpos ~= Vector() then
            local Lentpos = self:WorldToLocal( entpos )
            local GCDist = math.abs( ( Lentpos - LGCpos ):Length() ) 
            local ratio = math.min( GCDist / clutterdist, 1 )

            if ratio < ratiotolerance then
                table.remove(entdata, k)
                goto cont
            end

            debugoverlay.Text(entpos , "Ground Clutter Ratio Effect "..ratio, 0.2 )
            debugoverlay.Text(entpos + Vector(0,0,20) , "Distance to the Ground Clutter: "..GCDist, 0.2 )

        end

        local finalposition = entpos + VectorRand(-self.InacCoef, self.InacCoef) * (dist/7500)
        local finalVelocity = ent:GetVelocity()
        local finalAngle = AngDiff

        table.insert(self.Positions, finalposition)
        table.insert(self.Velocities, finalVelocity)
        table.insert(self.Angles, finalAngle)

        debugoverlay.Cross(finalposition, 10, 0.5, Color( 255, 255, 0 ), true)

        ::cont::
    end

    self.Detected = table.Count(data)

end

function ENT:UpdateOutputs()

    if self.Detected > 0 then

        WireLib.TriggerOutput( self, "Detected", self.Detected )
        WireLib.TriggerOutput( self, "Position", self.Positions )
        WireLib.TriggerOutput( self, "Velocity", self.Velocities )
        WireLib.TriggerOutput( self, "Angle", self.Angles )

        return
    end

    --WireLib.TriggerOutput( self, "Detected", 0 )
   -- WireLib.TriggerOutput( self, "Position", {} )
    --WireLib.TriggerOutput( self, "Velocity", {} )    

end

function ENT:Think()
    local Time =  CurTime()

    self.Detected   = 0
    self.Positions  = {}
    self.Velocities = {}
    self.Angles     = {}

    self.CurPos = self:WorldSpaceCenter()

    self:ResolveTargets()

    self:UpdateOutputs()

    self:NextThink( Time + self.Interval )
    return true
end

