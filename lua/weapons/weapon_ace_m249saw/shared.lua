SWEP.PrintName = "M249 SAW"
SWEP.Base = "weapon_ace_base"
SWEP.Category = "ACE Weapons"
SWEP.SubCategory = "LMGs"
SWEP.Purpose = "Rambo by day, spray n' pray by night"
SWEP.Spawnable = true
SWEP.Slot = 2 --Which inventory column the weapon appears in
SWEP.SlotPos = 1 --Priority in which the weapon appears, 1 tries to put it at the top


--Main settings--
SWEP.FireRate = 11 --Rounds per second

SWEP.Primary.ClipSize = 200
SWEP.Primary.DefaultClip = 400
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "AR2"
SWEP.Primary.Sound = "ace_weapons/sweps/multi_sound/m249saw_multi.mp3"
SWEP.Primary.LightScale = 200 --Muzzleflash light radius
SWEP.Primary.BulletCount = 1 --Number of bullets to fire each shot, used for shotguns

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1

SWEP.ReloadSound = "Weapon_Pistol.Reload" --Sound other players hear when you reload - this is NOT your first-person sound
                                        --Most models have a built-in first-person reload sound

SWEP.ZoomFOV = 60
SWEP.HasScope = false --True if the weapon has a sniper-style scope


--Recoil (crosshair movement) settings--
--"Heat" is a number that represents how long you've been firing, affecting how quickly your crosshair moves upwards
SWEP.HeatReductionRate = 175 --Heat loss per second when not firing
--SWEP.HeatReductionDelay = 0.3 --Delay after firing before beginning to reduce heat
SWEP.HeatPerShot = 6 --Heat generated per shot
SWEP.HeatMax = 50 --Maximum heat - determines max rate at which recoil is applied to eye angles
                --Also determines point at which random spread is at its highest intensity
                --HeatMax divided by HeatPerShot gives you how many shots until you reach MaxSpread

SWEP.RecoilSideBias = 0.15 --How much the recoil is biased to one side proportional to vertical recoil
                        --Positive numbers bias to the right, negative to the left

SWEP.ZoomRecoilBonus = 0.6 --Reduce recoil by this amount when zoomed or scoped
SWEP.CrouchRecoilBonus = 0.1 --Reduce recoil by this amount when crouching
SWEP.ViewPunchAmount = 0.5 --Degrees to punch the view upwards each shot - does not actually move crosshair, just a visual effect


--Spread (aimcone) settings--
SWEP.BaseSpread = 0 --First-shot random spread, in degrees
SWEP.MaxSpread = 3 --Maximum added random spread from heat value, in degrees
                    --If HeatMax is 0 this will be ignored and only BaseSpread will be taken into account (AT4 for example)
SWEP.MovementSpread = 10 --Increase aimcone to this many degrees when sprinting at full speed
SWEP.UnscopedSpread = 5 --Spread, in degrees, when unscoped with a scoped weapon


--Model settings--
SWEP.ViewModelFlip = false
SWEP.ViewModel = "models/weapons/v_mach_m249para.mdl"
SWEP.WorldModel = "models/weapons/w_mach_m249para.mdl"
SWEP.HoldType = "ar2"
SWEP.DeployDelay = 1 --Time before you can fire after deploying the weapon
SWEP.CSMuzzleFlashes = true


function SWEP:InitBulletData()
    self.BulletData = {}
    self.BulletData.Id = "7.62mmMG"
    self.BulletData.Type = "AP"
    self.BulletData.Id = 1
    self.BulletData.Caliber = 0.556
    self.BulletData.PropLength = 22 --Volume of the case as a cylinder * Powder density converted from g to kg		
    self.BulletData.ProjLength = 4.4 --Volume of the projectile as a cylinder * streamline factor (Data5) * density of steel
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
    self.BulletData.DragCoef = 0.005 --Alternatively manually set it
    --		self.BulletData.DragCoef  = ((self.BulletData.FrAera/10000)/self.BulletData.ProjMass)	
    --Don't touch below here
    self.BulletData.MuzzleVel = ACF_MuzzleVelocity(self.BulletData.PropMass, self.BulletData.ProjMass, self.BulletData.Caliber)
    self.BulletData.ShovePower = 0.2
    self.BulletData.KETransfert = 0.3
    self.BulletData.PenAera = self.BulletData.FrAera ^ ACF.PenAreaMod * 1.5
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