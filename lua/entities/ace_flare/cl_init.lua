include("shared.lua")




function ENT:Initialize()

	self.LightUpdate = CurTime() + 0.05	

end

function ENT:Draw()

	self:DrawModel() 

	if GetConVar("ACFM_MissileLights"):GetFloat() == 1 then
		if CurTime() > self.LightUpdate then
			self.LightUpdate = CurTime() + 0.05	
			ACF_RenderLight(self:EntIndex(), 1000, Color(255, 128, 48), self:GetPos())
		end
	end
end



