SWEP.PrintName = "Glock"
SWEP.Base = "weapon_ace_base"
SWEP.Category = "ACE Weapons"
SWEP.SubCategory = "Pistols"
SWEP.Purpose = "AP Pistol"
SWEP.Spawnable = true
SWEP.Slot = 1 --Which inventory column the weapon appears in
SWEP.SlotPos = 1 --Priority in which the weapon appears, 1 tries to put it at the top


--Main settings--
SWEP.FireRate = 10 --Rounds per second

SWEP.Primary.ClipSize = 13
SWEP.Primary.DefaultClip = 39
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "pistol"
SWEP.Primary.Sound = "ace_weapons/sweps/multi_sound/glock_multi.mp3"
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
SWEP.HeatReductionRate = 75 --Heat loss per second when not firing
--SWEP.HeatReductionDelay = 0.3 --Delay after firing before beginning to reduce heat
SWEP.HeatPerShot = 5 --Heat generated per shot
SWEP.HeatMax = 15 --Maximum heat - determines max rate at which recoil is applied to eye angles
                --Also determines point at which random spread is at its highest intensity
                --HeatMax divided by HeatPerShot gives you how many shots until you reach MaxSpread

SWEP.RecoilSideBias = 0.025 --How much the recoil is biased to one side proportional to vertical recoil
                        --Positive numbers bias to the right, negative to the left

SWEP.ZoomRecoilBonus = 0.5 --Reduce recoil by this amount when zoomed or scoped
SWEP.CrouchRecoilBonus = 0.5 --Reduce recoil by this amount when crouching
SWEP.ViewPunchAmount = 1 --Degrees to punch the view upwards each shot - does not actually move crosshair, just a visual effect


--Spread (aimcone) settings--
SWEP.BaseSpread = 0.5 --First-shot random spread, in degrees
SWEP.MaxSpread = 4 --Maximum added random spread from heat value, in degrees
                    --If HeatMax is 0 this will be ignored and only BaseSpread will be taken into account (AT4 for example)
SWEP.MovementSpread = 5 --Increase aimcone to this many degrees when sprinting at full speed
SWEP.UnscopedSpread = 5 --Spread, in degrees, when unscoped with a scoped weapon


--Model settings--
SWEP.ViewModelFlip = true
SWEP.ViewModel = "models/weapons/v_pist_glock18.mdl"
SWEP.WorldModel = "models/weapons/w_pist_glock18.mdl"
SWEP.HoldType = "pistol"
SWEP.DeployDelay = 1 --Time before you can fire after deploying the weapon
SWEP.CSMuzzleFlashes = true


function SWEP:InitBulletData()

    local PlayerData = {}   --what a mess
    
    -- Player ammo config. Like if you were editing it from ammo config.
    PlayerData.Type         = "AP"
    PlayerData.PropLength   = 1.2        --Volume of the case as a cylinder * Powder density converted from g to kg   
    PlayerData.ProjLength   = 1.25       --Volume of the projectile as a cylinder * streamline factor (Data5) * density of steel
    PlayerData.Data5        = 0         --HE Filler or Flechette count
    PlayerData.Data6        = 0         --HEAT ConeAng or Flechette Spread
    PlayerData.Data7        = 0
    PlayerData.Data8        = 0
    PlayerData.Data9        = 0
    PlayerData.Data10       = 1
    PlayerData.Data11       = 0 
    PlayerData.Data12       = 0
    PlayerData.Data13       = 0 
    PlayerData.Data14       = 0
    PlayerData.Data15       = 0

    -- Create this section if you will use a custom gun with custom caliber. The following values will be required.
    --If you add this, remove PlayerData.Id, since that becomes unnecessary.
    PlayerData.Custom = {} 
    PlayerData.Custom.caliber    = 1.15
    PlayerData.Custom.maxlength  = PlayerData.PropLength + PlayerData.ProjLength
    PlayerData.Custom.propweight = PlayerData.ProjLength

    self.ConvertData        = ACF.RoundTypes[PlayerData.Type].convert
    self.BulletData         = self:ConvertData( PlayerData )

    self.BulletData.Colour  = Color(255, 0, 0)

    self:NetworkSWEPData( PlayerData )

end