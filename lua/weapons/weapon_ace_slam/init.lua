AddCSLuaFile ("cl_init.lua")
AddCSLuaFile ("shared.lua")

include ("shared.lua")

SWEP.DeployDelay = 6 --No more rocket 2 taps or sprinting lawnchairs

function SWEP:DoAmmoStatDisplay()


	local sendInfo = string.format( "S.L.A.M. (TRIPMINE)")

	sendInfo = sendInfo .. string.format("  -  %.1fm blast", 0.25 ^ 0.33 * 8) --4 taken from mine entity

	sendInfo = sendInfo .. "  -  468.5mm pen HEAT" --4 taken from mine entity



	self:GetOwner():SendLua(string.format("GAMEMODE:AddNotify(%q, \"NOTIFY_HINT\", 10)", sendInfo))
end

function SWEP:Equip()
	self:DoAmmoStatDisplay()
	self:SetNextPrimaryFire( CurTime() + self.DeployDelay )
    self.Owner:GiveAmmo( 30*self.Primary.ClipSize, self.Primary.Ammo , false )
end
