SWEP.PrintName = "USP"
SWEP.Base = "weapon_ace_base"
SWEP.Spawnable = true
SWEP.Category = "ACE Weapons"
SWEP.SubCategory = "Pistols"

SWEP.Slot = 1
SWEP.SlotPos = 1

SWEP.ViewModelFlip = true
SWEP.ViewModel = "models/weapons/v_pist_usp.mdl"
SWEP.WorldModel = "models/weapons/w_pist_usp.mdl"
SWEP.HoldType = "pistol"
SWEP.CSMuzzleFlashes = true

SWEP.FireRate = 8

SWEP.Primary.ClipSize = 12
SWEP.Primary.DefaultClip = 36
SWEP.Primary.Ammo = "pistol"
SWEP.Primary.Sound = "ace_weapons/sweps/multi_sound/usp_multi.mp3"
SWEP.Primary.Automatic = false

SWEP.ReloadSound = "Weapon_Pistol.Reload"

SWEP.HasScope = false
SWEP.ZoomFOV = 60

SWEP.ViewPunchAmount = 0.5
SWEP.HeatPerShot = 4
SWEP.HeatMax = 16
SWEP.HeatReductionRate = 75
SWEP.BaseSpread = 0.07
SWEP.MaxSpread = 3.5
SWEP.RecoilSideBias = -0.1


function SWEP:InitBulletData()

    local PlayerData = {}   --what a mess

    -- Player ammo config. Like if you were editing it from ammo config.
    PlayerData.Type         = "AP"
    PlayerData.PropLength   = 2.2        --Volume of the case as a cylinder * Powder density converted from g to kg   
    PlayerData.ProjLength   = 1.3      --Volume of the projectile as a cylinder * streamline factor (Data5) * density of steel
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
    PlayerData.Custom.caliber    = 0.9
    PlayerData.Custom.maxlength  = PlayerData.PropLength + PlayerData.ProjLength
    PlayerData.Custom.propweight = PlayerData.ProjLength

    self.ConvertData        = ACF.RoundTypes[PlayerData.Type].convert
    self.BulletData         = self:ConvertData( PlayerData )

    self.BulletData.Colour  = Color(255, 0, 0)

    self:NetworkSWEPData( PlayerData )

end