AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")






function SWEP:Equip()
    if not self.BulletData then return end

    self:DoAmmoStatDisplay()

    self.BulletData.Filter = {self:GetOwner()}

    self.Owner:GiveAmmo( 8*self.Primary.ClipSize, self.Primary.Ammo , false )
end


function SWEP:DoAmmoStatDisplay()
    if not self.BulletData then return end

    local bdata = self.BulletData
    local roundType = bdata.Type

	local sendInfo = string.format( "FIM-92 Stinger (IR) - ")

    sendInfo = sendInfo .. string.format("%.1fm blast", bdata.BoomFillerMass ^ 0.33 * 8)

    sendInfo = sendInfo .. ", Burn time: 0.5s"


	self:GetOwner():SendLua(string.format("GAMEMODE:AddNotify(%q, \"NOTIFY_HINT\", 10)", sendInfo))
end