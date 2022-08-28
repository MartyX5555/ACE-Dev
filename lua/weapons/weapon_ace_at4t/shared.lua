SWEP.PrintName = "AT-4 Proto"
SWEP.Base = "weapon_ace_base"
SWEP.Spawnable = true
SWEP.Purpose = "Clear Backblast!"
SWEP.Category = "ACE - Rockets"

SWEP.Slot = 4
SWEP.SlotPos = 3

SWEP.ViewModelFlip = false
SWEP.ViewModel = "models/weapons/v_RPG.mdl"
SWEP.WorldModel = "models/weapons/w_rocket_launcher.mdl"
SWEP.HoldType = "rpg"
SWEP.CSMuzzleFlashes = true

SWEP.FireRate = 0.15

SWEP.Primary.ClipSize = 1
SWEP.Primary.DefaultClip = 8
SWEP.Primary.Ammo = "RPG_Round"
SWEP.Primary.Sound = "ace_weapons/sweps/multi_sound/at4p_multi.mp3"

SWEP.ReloadSound = "Weapon_Pistol.Reload"

SWEP.HasScope = false
SWEP.ZoomFOV = 60

SWEP.ViewPunchAmount = 10
SWEP.HeatPerShot = 20
SWEP.HeatReductionDelay = 0.3

SWEP.BaseSpread = 0.6

function SWEP:InitBulletData()
    self.BulletData = {}
    self.BulletData.Id = "75mmHW"
    self.BulletData.Type = "THEAT"
    self.BulletData.Id = 2
    self.BulletData.Caliber = 12.0
    self.BulletData.PropLength = 2 --Volume of the case as a cylinder * Powder density converted from g to kg		
    self.BulletData.ProjLength = 60 --Volume of the projectile as a cylinder * streamline factor (Data5) * density of steel
    self.BulletData.Data5 = 12000 --He Filler or Flechette count
    self.BulletData.Data6 = 60 --HEAT ConeAng or Flechette Spread
    self.BulletData.Data7 = 0
    self.BulletData.Data8 = 0
    self.BulletData.Data9 = 0
    self.BulletData.Data10 = 1 -- Tracer
    self.BulletData.Colour = Color(255, 110, 0)
    --
    self.BulletData.Data13 = 57 --THEAT ConeAng2
    self.BulletData.Data14 = 0.85 --THEAT HE Allocation
    self.BulletData.Data15 = 0
    self.BulletData.AmmoType = self.BulletData.Type
    self.BulletData.FrAera = 3.1416 * (self.BulletData.Caliber / 2) ^ 2
    self.BulletData.ProjMass = self.BulletData.FrAera * (self.BulletData.ProjLength * 7.9 / 1000)
    self.BulletData.PropMass = self.BulletData.FrAera * (self.BulletData.PropLength * ACF.PDensity / 1000) --Volume of the case as a cylinder * Powder density converted from g to kg
    self.BulletData.FillerVol = self.BulletData.Data5
    self.BulletData.FillerMass = self.BulletData.FillerVol * ACF.HEDensity / 1000
    self.BulletData.BoomFillerMass = self.BulletData.FillerMass / 250
    local ConeAera = 3.1416 * self.BulletData.Caliber / 2 * ((self.BulletData.Caliber / 2) ^ 2 + self.BulletData.ProjLength ^ 2) ^ 0.5
    local ConeThick = self.BulletData.Caliber / 50
    local ConeVol = ConeAera * ConeThick
    self.BulletData.SlugMass = ConeVol * 7.9 / 1000
    self.BulletData.SlugMass2 = ConeVol * 7.9 / 1000
    local Rad = math.rad(self.BulletData.Data6 / 2)
    self.BulletData.HEAllocation = self.BulletData.Data14
    self.BulletData.SlugCaliber = self.BulletData.Caliber - self.BulletData.Caliber * (math.sin(Rad) * 0.5 + math.cos(Rad) * 1.5) / 2
    self.BulletData.SlugMV = (self.BulletData.FillerMass / 2 * (1 - self.BulletData.HEAllocation) * ACF.HEPower * math.sin(math.rad(10 + self.BulletData.Data6) / 2) / self.BulletData.SlugMass) ^ ACF.HEATMVScale
    self.BulletData.SlugCaliber2 = self.BulletData.Caliber - self.BulletData.Caliber * (math.sin(Rad) * 0.5 + math.cos(Rad) * 1.5) / 2
    self.BulletData.SlugMV2 = (self.BulletData.FillerMass / 2 * self.BulletData.HEAllocation * ACF.HEPower * math.sin(math.rad(10 + self.BulletData.Data6) / 2) / self.BulletData.SlugMass) ^ ACF.HEATMVScale
    --		print("SlugMV: "..self.BulletData.SlugMV)
    --		print("SlugMV2: "..self.BulletData.SlugMV2)
    self.BulletData.Detonated = 0
    local SlugFrAera = 3.1416 * (self.BulletData.SlugCaliber / 2) ^ 2
    local SlugFrAera2 = 3.1416 * (self.BulletData.SlugCaliber2 / 2) ^ 2
    self.BulletData.SlugPenAera = SlugFrAera ^ ACF.PenAreaMod
    self.BulletData.SlugPenAera2 = SlugFrAera ^ ACF.PenAreaMod
    self.BulletData.SlugDragCoef = ((SlugFrAera / 10000) / self.BulletData.SlugMass) * 1000
    self.BulletData.SlugDragCoef2 = ((SlugFrAera2 / 10000) / self.BulletData.SlugMass2) * 1000
    self.BulletData.SlugRicochet = 500 --Base ricochet angle (The HEAT slug shouldn't ricochet at all)
    self.BulletData.SlugRicochet2 = 500 --Base ricochet angle (The HEAT slug shouldn't ricochet at all)
    self.BulletData.CasingMass = self.BulletData.ProjMass - self.BulletData.FillerMass - ConeVol * 7.9 / 1000
    self.BulletData.Fragments = math.max(math.floor((self.BulletData.BoomFillerMass / self.BulletData.CasingMass) * ACF.HEFrag), 2)
    self.BulletData.FragMass = self.BulletData.CasingMass / self.BulletData.Fragments
    --		self.BulletData.DragCoef  = 0 --Alternatively manually set it
    self.BulletData.DragCoef = ((self.BulletData.FrAera / 10000) / self.BulletData.ProjMass)
    --Don't touch below here
    self.BulletData.MuzzleVel = ACF_MuzzleVelocity(self.BulletData.PropMass, self.BulletData.ProjMass, self.BulletData.Caliber)
    self.BulletData.ShovePower = 0.2
    self.BulletData.KETransfert = 0.3
    self.BulletData.PenAera = self.BulletData.FrAera ^ ACF.PenAreaMod
    self.BulletData.Pos = Vector(0, 0, 0)
    self.BulletData.LimitVel = 800
    self.BulletData.Ricochet = 999
    self.BulletData.Flight = Vector(0, 0, 0)
    self.BulletData.BoomPower = self.BulletData.PropMass + self.BulletData.FillerMass
    --		local SlugEnergy = ACF_Kinetic( self.BulletData.MuzzleVel*39.37 + self.BulletData.SlugMV*39.37 , self.BulletData.SlugMass, 999999 )
    local SlugEnergy = ACF_Kinetic(self.BulletData.SlugMV * 39.37, self.BulletData.SlugMass, 999999)
    self.BulletData.MaxPen = (SlugEnergy.Penetration / self.BulletData.SlugPenAera) * ACF.KEtoRHA
    --		print("SlugPen: "..self.BulletData.MaxPen)
    local SlugEnergy = ACF_Kinetic(self.BulletData.SlugMV2 * 39.37, self.BulletData.SlugMass2, 999999)
    self.BulletData.MaxPen = (SlugEnergy.Penetration / self.BulletData.SlugPenAera2) * ACF.KEtoRHA
    --		print("SlugPen2: "..self.BulletData.MaxPen)		
    --For Fake Crate
    self.BoomFillerMass = self.BulletData.BoomFillerMass
    self.Type = self.BulletData.Type
    self.BulletData.Tracer = self.BulletData.Data10
    self.Tracer = self.BulletData.Tracer
    self.Caliber = self.BulletData.Caliber
    self.ProjMass = self.BulletData.ProjMass
    self.FillerMass = self.BulletData.FillerMass
    self.DragCoef = self.BulletData.DragCoef
    self.Colour = self.BulletData.Colour
    self.DetonatorAngle = 80
end