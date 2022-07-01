AddCSLuaFile("shared.lua")
SWEP.Base = "ace_basewep"

if (CLIENT) then
SWEP.PrintName		= "HEAT SUS WEAPON"
SWEP.Slot		    = 4
SWEP.SlotPos		= 3			
end

SWEP.Spawnable		= true	

--Visual
SWEP.ViewModelFlip 	= false
SWEP.ViewModel		= "models/weapons/v_RPG.mdl"	
SWEP.WorldModel		= "models/weapons/w_rocket_launcher.mdl"	
SWEP.ReloadSound	= "Weapon_Pistol.Reload"	
SWEP.HoldType		= "rpg"		
SWEP.CSMuzzleFlashes	= true


-- Other settings
SWEP.Weight			= 10						
 
-- Weapon info		
SWEP.Purpose		= "Clear Backblast!"	
SWEP.Instructions	= "Left mouse to shoot"		

-- Primary fire settings
SWEP.Primary.Sound			= "acf_extra/tankfx/gnomefather/2pdr2.wav"
SWEP.Primary.NumShots		= 1	
SWEP.Primary.Recoil			= 1	
SWEP.Primary.RecoilAngle	= 15		
SWEP.Primary.Cone			= 0.025		
SWEP.Primary.Delay			= 0.5
SWEP.Primary.ClipSize		= 1		
SWEP.Primary.DefaultClip	= 1			
SWEP.Primary.Automatic		= 0	
SWEP.Primary.Ammo		= "RPG_Round"	

SWEP.Secondary.Ammo		= "none"	
SWEP.Secondary.ClipSize		= -1		
SWEP.Secondary.DefaultClip	= -1

SWEP.ReloadSoundEnabled 	= 1

SWEP.Category 				= "ACE Sweps - RKT"

SWEP.AimOffset 				= Vector(0,0,0)
SWEP.InaccuracyAccumulation = 0
SWEP.lastFire 				= CurTime()

SWEP.MaxInaccuracyMult 			= 5
SWEP.InaccuracyAccumulationRate = 0.3
SWEP.InaccuracyDecayRate 		= 1

SWEP.IronSights 	= true
SWEP.IronSightsPos 	= Vector(-2, -15, 2.98)
SWEP.ZoomPos 		= Vector(2,-2,2)
SWEP.IronSightsAng 	= Angle(0.45, 0, 0)
SWEP.CarrySpeedMul 	= 0.6 --WalkSpeedMult when carrying the weapon

SWEP.ZoomAccuracyImprovement 	= 0.5 -- 0.3 means 0.7 the inaccuracy
SWEP.ZoomRecoilImprovement 		= 0.2 -- 0.3 means 0.7 the recoil movement

SWEP.CrouchAccuracyImprovement 	= 0.4 -- 0.3 means 0.7 the inaccuracy
SWEP.CrouchRecoilImprovement 	= 0.2 -- 0.3 means 0.7 the recoil movement

-- Missile fuse & guidance control. Default values, don't override!
SWEP.Guidance  			= "Infrared"  -- Guidance of this missile by default. Put "Dumb" if no guidance is intented to use
SWEP.FuseDetonation     = "Contact"   -- Fuse of this missile by default. Put "Contact" if no guidance is intented to use
SWEP.TrackDelay         = 0.25        -- Time missile will wait before it starts tracking (in seconds)
SWEP.MissileOffsetMult  = 8   		  -- Mutipler factor to define how distant the missile should appear next to the player.
SWEP.MissileSound 	 	= "acf_extra/airfx/tow2.wav" --Sound which the swep will use FOR the missile. You have to put a different one for the gun.

-- These can be overrided during the process. To override guidance and fuse, see self.BulletData.Data7 and self.BulletData.Data8 instead
SWEP.ETrackDelay         = SWEP.TrackDelay        
SWEP.EMissileOffsetMult  = SWEP.MissileOffsetMult  		  


function SWEP:InitBulletData()
	
	self.BulletData = {}

		self.BulletData.Id 				= "FGM-148 ASM"
		self.BulletData.Type 			= "HEAT"
		self.BulletData.Caliber 		= 8.4
		self.BulletData.PropLength 		= 1112 	-- Volume of the case as a cylinder * Powder density converted from g to kg		
		self.BulletData.ProjLength 		= 60 	-- Volume of the projectile as a cylinder * streamline factor (Data5) * density of steel
		self.BulletData.Data5 			= 5300  -- He Filler or Flechette count
		self.BulletData.Data6 			= 57 	-- HEAT ConeAng or Flechette Spread

		self.BulletData.Data7 			= self.Guidance   	 	-- Override Data7 to change guidance
		self.BulletData.Data8 			= self.FuseDetonation   -- Override Data8 to change fuse

		self.BulletData.Data9 			= 0
		self.BulletData.Data10 			= 0 	-- Tracer
		self.BulletData.Colour 			= Color(255, 255, 255) -- The Trace Color. Also the missile color

		self.BulletData.Data13 			= 0 	--THEAT ConeAng2
		self.BulletData.Data14 			= 0 	--THEAT HE Allocation
		self.BulletData.Data15 			= 0

		self.BulletData.AmmoType  		= self.BulletData.Type
		self.BulletData.FrAera    		= 3.1416 * (self.BulletData.Caliber/2)^2
		self.BulletData.ProjMass  		= self.BulletData.FrAera * (self.BulletData.ProjLength*7.9/1000)
		self.BulletData.PropMass  		= self.BulletData.FrAera * (self.BulletData.PropLength*ACF.PDensity/1000) --Volume of the case as a cylinder * Powder density converted from g to kg
		self.BulletData.FillerVol 		= self.BulletData.Data5
		self.BulletData.FillerMass 		= self.BulletData.FillerVol * ACF.HEDensity/1000
		self.BulletData.BoomFillerMass 	= self.BulletData.FillerMass / 130

		local ConeAera 					= 3.1416 * self.BulletData.Caliber/2 * ((self.BulletData.Caliber/2)^2 + self.BulletData.ProjLength^2)^0.5
		local ConeThick 				= self.BulletData.Caliber/50
		local ConeVol 					= ConeAera * ConeThick

		self.BulletData.SlugMass 		= ConeVol*7.9/1000

		local Rad 						= math.rad(self.BulletData.Data6/2)

		self.BulletData.SlugCaliber 	=  self.BulletData.Caliber - self.BulletData.Caliber * (math.sin(Rad)*0.5+math.cos(Rad)*1.5)/2
		self.BulletData.SlugMV 			= ( self.BulletData.FillerMass/2 * ACF.HEPower * math.sin(math.rad(10+self.BulletData.Data6)/2) /self.BulletData.SlugMass)^ACF.HEATMVScale

--		print("SlugMV: "..self.BulletData.SlugMV)
		local SlugFrAera 				= 3.1416 * (self.BulletData.SlugCaliber/2)^2

		self.BulletData.SlugPenAera 	= SlugFrAera^ACF.PenAreaMod
		self.BulletData.SlugDragCoef 	= ((SlugFrAera/10000)/self.BulletData.SlugMass)*1000
		self.BulletData.SlugRicochet 	= 	500									--Base ricochet angle (The HEAT slug shouldn't ricochet at all)
	
		self.BulletData.CasingMass 		= self.BulletData.ProjMass - self.BulletData.FillerMass - ConeVol*7.9/1000
		self.BulletData.Fragments 		= math.max(math.floor((self.BulletData.BoomFillerMass/self.BulletData.CasingMass)*ACF.HEFrag),2)
		self.BulletData.FragMass 		= self.BulletData.CasingMass/self.BulletData.Fragments

		self.BulletData.DragCoef  		= ((self.BulletData.FrAera/10000)/self.BulletData.ProjMass)	

		--Don't touch below here
		self.BulletData.MuzzleVel 		= ACF_MuzzleVelocity( self.BulletData.PropMass, self.BulletData.ProjMass, self.BulletData.Caliber )		
		self.BulletData.ShovePower 		= 0.2
		self.BulletData.KETransfert 	= 0.3
		self.BulletData.PenAera 		= self.BulletData.FrAera^ACF.PenAreaMod
		self.BulletData.Pos 			= Vector(0 , 0 , 0)
		self.BulletData.LimitVel 		= 800	
		self.BulletData.Ricochet 		= 999
		self.BulletData.Flight 			= Vector(0 , 0 , 0)
		self.BulletData.BoomPower 		= self.BulletData.PropMass + self.BulletData.FillerMass

		local SlugEnergy = ACF_Kinetic( self.BulletData.MuzzleVel*39.37 + self.BulletData.SlugMV*39.37 , self.BulletData.SlugMass, 999999 )
		self.BulletData.MaxPen = (SlugEnergy.Penetration/self.BulletData.SlugPenAera)*ACF.KEtoRHA
--		print("SlugPen: "..self.BulletData.MaxPen)
		
		--For Fake Crate
		self.BoomFillerMass 	= self.BulletData.BoomFillerMass
		self.Type 				= self.BulletData.Type
		self.BulletData.Tracer 	= self.BulletData.Data10
		self.Tracer 			= self.BulletData.Data10
		self.Caliber 			= self.BulletData.Caliber
		self.ProjMass 			= self.BulletData.ProjMass
		self.FillerMass 		= self.BulletData.FillerMass
		self.DragCoef 			= self.BulletData.DragCoef
		self.Colour 			= self.BulletData.Colour
		self.DetonatorAngle 	= 80
end	
		
function SWEP:PrimaryAttack()		

	if not self:CanPrimaryAttack() then return end		
	if self:Ammo1() == 0 and self:Clip1() == 0 then return end

	self:SetNextPrimaryFire( CurTime() + self.Primary.Delay )	
	self.Weapon:EmitSound(Sound(self.Primary.Sound), 100, 100, 1, CHAN_WEAPON )		

	if CLIENT then return end	

	self.BulletData.Owner 		= self.Owner
	self.BulletData.Gun 		= self	
	self.InaccuracyAccumulation = math.Clamp(self.InaccuracyAccumulation + self.InaccuracyAccumulationRate - self.InaccuracyDecayRate*(CurTime()-self.lastFire),1,self.MaxInaccuracyMult)
	
	if self.Owner:IsPlayer() then
		self.Owner:LagCompensation( true )
	end

	self:ACE_FireMissile( false, false )
	
	if self.Owner:IsPlayer() then
		self.Owner:LagCompensation( false )
	end


		
	self.lastFire=CurTime()

	self.Weapon:SendWeaponAnim( ACT_VM_PRIMARYATTACK )							
	self.Owner:SetAnimation( PLAYER_ATTACK1 )			
	self.Owner:ViewPunch(Angle( -self.Primary.Recoil + math.Rand(-self.Primary.RecoilAngleVer,self.Primary.RecoilAngleVer), math.Rand(-self.Primary.RecoilAngleHor,self.Primary.RecoilAngleHor), 0 )*(1+self.InaccuracyAccumulation))	
	
	if self:Ammo1() > 0 then
		self.Owner:RemoveAmmo( 1, "RPG_Round")
	else
		self:TakePrimaryAmmo(1)
	end

end

function SWEP:Reload()	

	self:DefaultReload(ACT_VM_RELOAD)
	self:Think()

	return true
end

function SWEP:ACE_FireMissile()
    
    local missile = ents.Create("acf_missile")
    missile.Owner           = self.Owner
    missile.Launcher        = self
    missile.ForceTdelay     = math.max( self.ETrackDelay, self.TrackDelay )

    missile:SetBulletData( self.BulletData )

    missile:Spawn()

    missile.Filter = { self.Owner, missile }

    missile.Launcher.acfphysparent 	= self.Owner

    missile.BulletData.Pos 			= self.Owner:EyePos() + (self.Owner:GetAimVector():Angle() - Angle(0,90,0)):Forward()*self.EMissileOffsetMult
    missile.BulletData.Flight 		= self.Owner:GetAimVector() * self.BulletData.MuzzleVel
    missile.BulletData.Sound 		= self.MissileSound or ""

	missile:DoFlight(missile.BulletData.Pos, missile.BulletData.Flight)
    missile:Launch()

    return missile
end

