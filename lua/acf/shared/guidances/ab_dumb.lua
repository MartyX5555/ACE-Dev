
local ClassName = "Dumb"


ACF = ACF or {}
ACF.Guidance = ACF.Guidance or {}

local this = ACF.Guidance[ClassName] or inherit.NewBaseClass()
ACF.Guidance[ClassName] = this

---



this.Name = ClassName


this.desc = "This guidance package is empty and provides no control."


-- an object containing an obj:GetGuidanceOverride(missile, guidance) function
this.Override = nil


function this:Init()

end


function this:Configure()

end

function this:GetGuidance()
	return {}
end

function this:GetDisplayConfig()
	return {}
end
