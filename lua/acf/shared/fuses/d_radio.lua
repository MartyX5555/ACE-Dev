
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

--We need to clamp the value to 0.25 since many ppl could complain about why their missiles are exploding once fired despite of they have not adjusted a proper arm delay...
function this:Configure(missile, guidance)
    self.TimeStarted = CurTime()
    self.Primer = math.max(self.Primer, 0.25)
end

do

    local blacklist = {
        player = true,
        acf_missile = true,
        acf_glatgm = true,
        ace_debris = true,
        ace_grenade = true,
        ace_smokegrenade = true,
        ace_flare = true,
        ace_antitankmine = true,
        ace_antipersonelmine = true,
        ace_boundingmine = true
    }

    --Question: Should radio fuze be limited to detect props in front of the missile only? Its weird it detonates by detecting something behind it.
    function this:GetDetonate(missile, guidance)
        
        if not self:IsArmed() then return false end
        
        local MissilePos = missile:GetPos()
        local Dist = self.Distance

        local trace = {}
        trace.start       = MissilePos
        trace.endpos      = MissilePos + missile.LastVel * 0.5 --small compensation for incoming impacts.
        trace.filter      = function(ent) if blacklist[ent:GetClass()] then return false end return true end 
        trace.mins        = Vector(-Dist, -Dist, -Dist)
        trace.maxs        = Vector(Dist, Dist, Dist)
        trace.ignoreworld = true

        local tr = util.TraceHull(trace)

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