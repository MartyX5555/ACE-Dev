SWEP.PrintName = "Anti Materiel Rifle"
SWEP.Base = "weapon_ace_base"
SWEP.Spawnable = true
SWEP.Purpose = "Oversized Tank Sniper"
SWEP.Category = "ACE - Special"

SWEP.Slot = 3
SWEP.SlotPos = 1

SWEP.ViewModelFlip = false
SWEP.ViewModel = "models/weapons/v_sniper.mdl"
SWEP.WorldModel = "models/weapons/w_sniper.mdl"

SWEP.FireRate = 5

SWEP.Primary.ClipSize = 1
SWEP.Primary.DefaultClip = 8
SWEP.Primary.Ammo = "XBowBolt"
SWEP.Primary.Sound = "ace_weapons/sweps/multi_sound/amr_multi.mp3"

SWEP.ReloadSound = "Weapon_Pistol.Reload"

SWEP.HasScope = true
SWEP.ZoomFOV = 20

SWEP.ViewPunchAmount = 5
SWEP.HeatPerShot = 0

function SWEP:InitBulletData()
    self.BulletData = {}
    self.BulletData.Id = "40mmMG"
    self.BulletData.Type = "HVAP"
    self.BulletData.Id = 1
    self.BulletData.Caliber = 4.0
    self.BulletData.PropLength = 11 --Volume of the case as a cylinder * Powder density converted from g to kg		
    self.BulletData.ProjLength = 12 --Volume of the projectile as a cylinder * streamline factor (Data5) * density of steel
    self.BulletData.Data5 = 0.2 --He Filler or Flechette count or subcaliber modifier
    self.BulletData.Data6 = 0 --HEAT ConeAng or Flechette Spread
    self.BulletData.Data7 = 0
    self.BulletData.Data8 = 0
    self.BulletData.Data9 = 0
    self.BulletData.Data10 = 1 -- Tracer
    self.BulletData.Colour = Color(0, 255, 0)
    --
    self.BulletData.Data13 = 0 --THEAT ConeAng2
    self.BulletData.Data14 = 0 --THEAT HE Allocation
    self.BulletData.Data15 = 0
    self.BulletData.AmmoType = self.BulletData.Type
    self.BulletData.FrAera = 3.1416 * (self.BulletData.Caliber / 2) ^ 2
    self.BulletData.SubFrAera = self.BulletData.FrAera * self.BulletData.Data5
    self.BulletData.PenAera = (1.2 * self.BulletData.SubFrAera) ^ ACF.PenAreaMod
    self.BulletData.ProjMass = (self.BulletData.SubFrAera * (self.BulletData.ProjLength * 7.9 / 1000) * 1.5 + (self.BulletData.FrAera - self.BulletData.SubFrAera) * (self.BulletData.ProjLength * 7.9 / 10000)) --(Tungsten Core Mass + Sabot Exterior Mass) * Mass modifier used for bad aerodynamics
    self.BulletData.PropMass = self.BulletData.FrAera * (self.BulletData.PropLength * ACF.PDensity / 1000) --Volume of the case as a cylinder * Powder density converted from g to kg
    --		self.BulletData.DragCoef  = 0 --Alternatively manually set it
    self.BulletData.DragCoef = ((self.BulletData.FrAera / 10000) / self.BulletData.ProjMass)
    --Don't touch below here
    self.BulletData.MuzzleVel = ACF_MuzzleVelocity(self.BulletData.PropMass, self.BulletData.ProjMass, self.BulletData.Caliber)
    self.BulletData.ShovePower = 0.2
    self.BulletData.KETransfert = 0.3
    self.BulletData.Pos = Vector(0, 0, 0)
    self.BulletData.LimitVel = 900
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