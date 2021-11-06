
   
--[[--------------------------------------------------------- 
    Initializes the effect. The data is a table of data  
    which was passed from the server. 
]]-----------------------------------------------------------
 function EFFECT:Init( data ) 
	
	local Gun = data:GetEntity()
	if not IsValid(Gun) then return end
	
	local Sound = Gun:GetNWString( "Sound" )
	local Propellant = data:GetScale()
	local ReloadTime = data:GetMagnitude()
	
	local Class = Gun:GetNWString( "Class" )

	local ClassData = list.Get("ACFClasses").GunClass[Class] or {}
	
--[[	

	longbarrel = {
		index = 2, 
		submodel = 4, 
		newpos = "muzzle2"
	}

]]--
	
	local Attachment = "muzzle"
	local longbarrel = ClassData.longbarrel or nil
	
	if longbarrel ~= nil then
		if Gun:GetBodygroup( longbarrel.index ) == longbarrel.submodel then
			Attachment = longbarrel.newpos
		end
	end
	
	local nosound = (Sound == "")
	if( CLIENT and not IsValidSound( Sound ) ) then
		Sound = ClassData["sound"]
	end
		
	if Gun:IsValid() then

		if Propellant > 0 then

			if not nosound then
				ACE_SGunFire( Gun:GetPos(), Sound ,Class, Propellant )
			end
			
			local Muzzle = Gun:GetAttachment( Gun:LookupAttachment(Attachment)) or { Pos = Gun:GetPos(), Ang = Gun:GetAngles() }
			local Flash = ClassData["muzzleflash"] or '120mm_muzzleflash_noscale'

			ParticleEffect( Flash , Muzzle.Pos, Muzzle.Ang, Gun )
			Gun:Animate( Class, ReloadTime, false )
		else
			Gun:Animate( Class, ReloadTime, true )
		end
	end
	
 end 
   
   
/*---------------------------------------------------------
   THINK
---------------------------------------------------------*/
function EFFECT:Think( )
	return false
end

/*---------------------------------------------------------
   Draw the effect
---------------------------------------------------------*/
function EFFECT:Render()
end