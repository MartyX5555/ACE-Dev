SWEP.PrintName = "Flare Gun"
SWEP.Base = "weapon_ace_base"
SWEP.Spawnable = true
SWEP.Category = "ACE Weapons"
SWEP.SubCategory = "Special"

SWEP.Slot = 1
SWEP.SlotPos = 1

SWEP.ViewModel = "models/weapons/v_pistol.mdl"
SWEP.WorldModel = "models/weapons/w_pistol.mdl"
SWEP.HoldType = "pistol"

SWEP.Primary.ClipSize = 1
SWEP.Primary.DefaultClip = 8
SWEP.Primary.Ammo = "pistol"
SWEP.Primary.Sound = "weapons/flaregun/fire.wav"
SWEP.Primary.Automatic = false

SWEP.ReloadSound = "Weapon_Pistol.Reload"

SWEP.HasScope = false
SWEP.ZoomFOV = 60

function SWEP:PrimaryAttack()
	if self:Clip1() == 0 and self:Ammo1() > 0 then
		self:Reload()

		return
	end

	if not self:CanPrimaryAttack() then return end

	if IsFirstTimePredicted() or game.SinglePlayer() then
		self:GetOwner():ViewPunch(Angle(-1, 0, 0))
	end

	if SERVER then
		local ent = ents.Create( "ace_flare" )
		local owner = self:GetOwner()

		if ( IsValid( ent ) ) then

			ent:SetPos( owner:GetShootPos() )
			ent:SetAngles( owner:GetAimVector():Angle() )
			ent.Life = 1.25 / (0.4 * ACFM.FlareBurnMultiplier)
			ent:Spawn()
			ent:SetOwner( Gun )
			ent:GetPhysicsObject():SetDragCoefficient(10)
			timer.Simple(2, function()
				if not ent or not ent:IsValid() then return end

				ent:GetPhysicsObject():SetDragCoefficient(250)
			end)

			if CPPI then
				ent:CPPISetOwner(owner)
			end

			local phys = ent:GetPhysicsObject()
			phys:SetVelocity( owner:GetAimVector() * 3000 )
			ent.Heat = 150

		end

		self:TakePrimaryAmmo(1)
	end

	self:EmitSound(self.Primary.Sound)
	self:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
	self:GetOwner():SetAnimation(PLAYER_ATTACK1)
end

function SWEP:SecondaryAttack()
	return
end