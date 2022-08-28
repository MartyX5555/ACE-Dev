AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

SWEP.AutoSwitchFrom = false
SWEP.AutoSwitchTo = false

function SWEP:UpdateFakeCrate(realcrate)
    if not IsValid(self.FakeCrate) then
        self.FakeCrate = ents.Create("acf_fakecrate2")
    end

    self.FakeCrate:RegisterTo(self)
    self.BulletData["Crate"] = self.FakeCrate:EntIndex()
end

function SWEP:ACEFireBullet(Position, Direction)
    self.BulletData.Pos = Position + Direction * 30
    self.BulletData.Flight = Direction * self.BulletData.MuzzleVel * 39.37

    self.BulletData.Owner = self:GetParent()
    self.BulletData.Gun = self
    self.BulletData.Crate = self.FakeCrate:EntIndex()

    if self.BeforeFire then
        self:BeforeFire()
    end

    ACE_SWEP_CreateBullet(self.BulletData)
end

function SWEP:OnRemove()
    if not IsValid(self.FakeCrate) then return end
    local crate = self.FakeCrate

    timer.Simple(15, function()
        if IsValid(crate) then
            crate:Remove()
        end
    end)
end

function SWEP:Initialize()
    self:SetHoldType(self.HoldType)

    self:InitBulletData()
    self:UpdateFakeCrate()
end