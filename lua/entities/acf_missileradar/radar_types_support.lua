
ACFM.RadarBehaviour = ACFM.RadarBehaviour or {}
ACFM.DefaultRadarSound = ACFM.DefaultRadarSound or "buttons/button16.wav"

function ACFM_GetMissilesInCone(pos, dir, degs)

	local ret = {}
	
	for missile, _ in pairs(ACF_ActiveMissiles) do
		
		if not IsValid(missile) then goto cont end
		
		if ACFM_ConeContainsPos(pos, dir, degs, missile:GetPos()) then
			ret[#ret+1] = missile
		end
		
		::cont::
	end

	return ret
	
end

function ACFM_GetMissilesInSphere(pos, radius)

	local ret = {}
	
	local radSqr = radius ^ 2
	
	for missile, _ in pairs(ACF_ActiveMissiles) do
		
		if not IsValid(missile) then goto cont end
		
		if pos:DistToSqr(missile:GetPos()) <= radSqr then
			ret[#ret+1] = missile
		end
		
		::cont::
	end

	return ret
	
end

ACFM.RadarBehaviour["DIR-AM"] = 
{
	GetDetectedEnts = function(self)
		return ACFM_GetMissilesInCone(self:GetPos(), self:GetForward(), self.ConeDegs)
	end
}


ACFM.RadarBehaviour["OMNI-AM"] = 
{
	GetDetectedEnts = function(self)
		return ACFM_GetMissilesInSphere(self:GetPos(), self.Range)
	end
}