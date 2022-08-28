SWEP.PrintName = "P90"
SWEP.Base = "weapon_ace_base"
SWEP.Spawnable = true
SWEP.Purpose = "Rush B"
SWEP.Category = "ACE - SMGs"

SWEP.Slot = 2
SWEP.SlotPos = 1

SWEP.ViewModelFlip = true
SWEP.ViewModel = "models/weapons/v_smg_p90.mdl"
SWEP.WorldModel = "models/weapons/w_smg_p90.mdl"
SWEP.HoldType = "ar2"
SWEP.CSMuzzleFlashes = true

SWEP.FireRate = 14

SWEP.Primary.ClipSize = 50
SWEP.Primary.DefaultClip = 150
SWEP.Primary.Ammo = "smg1"
SWEP.Primary.Sound = "ace_weapons/sweps/multi_sound/p90_multi.mp3"

SWEP.ReloadSound = "Weapon_Pistol.Reload"

SWEP.HasScope = false
SWEP.ZoomFOV = 60

SWEP.ViewPunchAmount = 0.5
SWEP.HeatPerShot = 7
SWEP.HeatMax = 40
SWEP.HeadReductionRate = 100
SWEP.RecoilSideBias = 0.1
SWEP.ZoomRecoilBonus = 0.35
SWEP.BaseSpread = 0.2
SWEP.MaxSpread = 3.5

function SWEP:InitBulletData()
    self.BulletData = {}
    self.BulletData.Id = "7.62mmMG"
    self.BulletData.Type = "AP"
    self.BulletData.Id = 1
    self.BulletData.Caliber = 0.57
    self.BulletData.PropLength = 40 --Volume of the case as a cylinder * Powder density converted from g to kg		
    self.BulletData.ProjLength = 8 --Volume of the projectile as a cylinder * streamline factor (Data5) * density of steel
    self.BulletData.Data5 = 0 --He Filler or Flechette count
    self.BulletData.Data6 = 0 --HEAT ConeAng or Flechette Spread
    self.BulletData.Data7 = 0
    self.BulletData.Data8 = 0
    self.BulletData.Data9 = 0
    self.BulletData.Data10 = 1 -- Tracer
    self.BulletData.Colour = Color(255, 0, 0)
    --
    self.BulletData.Data13 = 0 --THEAT ConeAng2
    self.BulletData.Data14 = 0 --THEAT HE Allocation
    self.BulletData.Data15 = 0
    self.BulletData.AmmoType = self.BulletData.Type
    self.BulletData.FrAera = 3.1416 * (self.BulletData.Caliber / 2) ^ 2
    self.BulletData.ProjMass = self.BulletData.FrAera * (self.BulletData.ProjLength * 7.9 / 1000)
    self.BulletData.PropMass = self.BulletData.FrAera * (self.BulletData.PropLength * ACF.PDensity / 1000) --Volume of the case as a cylinder * Powder density converted from g to kg
    self.BulletData.DragCoef = 0.025 --Alternatively manually set it
    --Don't touch below here
    self.BulletData.MuzzleVel = ACF_MuzzleVelocity(self.BulletData.PropMass, self.BulletData.ProjMass, self.BulletData.Caliber)
    self.BulletData.ShovePower = 0.2
    self.BulletData.KETransfert = 0.3
    self.BulletData.PenAera = self.BulletData.FrAera ^ ACF.PenAreaMod * 2.5
    self.BulletData.Pos = Vector(0, 0, 0)
    self.BulletData.LimitVel = 800
    self.BulletData.Ricochet = 60
    self.BulletData.Flight = Vector(0, 0, 0)
    self.BulletData.BoomPower = self.BulletData.PropMass
    --For Fake Crate
    self.Type = self.BulletData.Type
    self.BulletData.Tracer = self.BulletData.Data10
    self.Tracer = self.BulletData.Tracer
    self.Caliber = self.BulletData.Caliber
    self.ProjMass = self.BulletData.ProjMass
    self.FillerMass = self.BulletData.Data5
    self.DragCoef = self.BulletData.DragCoef
    self.Colour = self.BulletData.Colour
end