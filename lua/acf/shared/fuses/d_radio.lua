
local ClassName = "Radio"


ACF = ACF or {}
ACF.Fuse = ACF.Fuse or {}

local this = ACF.Fuse[ClassName] or inherit.NewSubOf(ACF.Fuse.Contact)
ACF.Fuse[ClassName] = this

---



this.Name = ClassName

-- The entity to measure distance to.
this.Target = nil

-- the fuse may trigger at some point under this range - unless it's travelling so fast that it steps right on through.
this.Distance = 2000


this.desc = "This fuse tracks the guidance module's target and detonates when the distance becomes low enough. The minimum arm delay here is 0.25 secs to avoid undesired results.\nDistance in inches."


-- Configuration information for things like acfmenu.
this.Configurable = table.Copy(this:super().Configurable)

local configs = this.Configurable

configs[#configs + 1] = 
{
    Name = "Distance",          -- name of the variable to change
    DisplayName = "Distance",   -- name displayed to the user
    CommandName = "Ds",         -- shorthand name used in console commands
    
    Type = "number",            -- lua type of the configurable variable
    Min = 0,                    -- number specific: minimum value
    Max = 10000                 -- number specific: maximum value
    
    -- in future if needed: min/max getter function based on munition type.  useful for modifying radar cones?
}

do

    local whitelist = {
        prop_physics = true,
        primitive_shape = true,
    }

    local ignoredents = {}
    local StartsWith = string.StartWith

    local function FilterShit(ent)

        print(table.Count(ignoredents))

        local Class = ent:GetClass()

        --Skip blacklisted ents like world entities
        if not whitelist[Class] then 

            print(Class)

            if not StartsWith( Class, "acf_" ) or not StartsWith( Class, "ace_" ) or not StartsWith( Class, "gmod_" )   then
                return false 
            end

        end 

        --Skip ents that were told to be skipped
        if ignoredents[ent:EntIndex()] then 
            return false 
        end         

        return true 
    end

    --Question: Should radio fuze be limited to detect props in front of the missile only? Its weird it detonates by detecting something behind it.
    function this:GetDetonate(missile, guidance)
        
        --Legacy way until i figure to fix the new one.
        if not self:IsArmed() then return false end

        local MissilePos = missile:GetPos()
        local Dist = self.Distance

        ignoredents = {}

        local trace = {}
        trace.start       = MissilePos
        trace.endpos      = MissilePos + missile.LastVel * 0.5 --small compensation for incoming impacts.
        trace.filter      = FilterShit
        trace.mins        = Vector(-Dist, -Dist, -Dist)
        trace.maxs        = Vector(Dist, Dist, Dist)
        trace.ignoreworld = true

        local tr = util.TraceHull(trace)

        local retry = true

        local It = 0

        while retry do

            It = It + 1 --In case of total failure. Mostly to avoid shitting my game....
            if It > 100 then print("failed!") break end

            retry = false

            if tr.Hit then

                local HitEnt = tr.Entity

                if IsValid(HitEnt) then

                    local HitPos = HitEnt:GetPos()
                    local tolocal = missile:WorldToLocal(HitPos)

                    debugoverlay.Text(HitPos + VectorRand(-1, 1), "This Ent2: "..(HitEnt:GetClass()) , 5 )

                    if HitEnt:GetClass() == "acf_missile" or HitEnt:GetClass() == "acf_glatgm" then

                        ignoredents[HitEnt:EntIndex()] = true
                        tr = util.TraceHull(trace)

                        retry = true
                        goto cont
                    end



                    if tolocal.x < 0 then

                        ignoredents[HitEnt:EntIndex()] = true
                        tr = util.TraceHull(trace)

                        retry = true
                        goto cont
                    end
                end
            end
            ::cont::
        end

        if tr.Hit then

            debugoverlay.Box(MissilePos, trace.mins, trace.maxs, 1, Color(255,100,0,10))
            return true
        end

        return false
    end
end


function this:GetDisplayConfig()
    return 
    {
        ["Arming delay"] = math.Round(self.Primer, 3) .. " s",
        ["Distance"] = math.Round(self.Distance / 39.37, 1) .. " m"
    }
end