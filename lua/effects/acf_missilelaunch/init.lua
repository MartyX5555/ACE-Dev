--[[---------------------------------------------------------
Initializes the effect. The data is a table of data
which was passed from the server.
-----------------------------------------------------------]]
function EFFECT:Init( data )

	local Missile    = data:GetEntity()
	local Rack       = Missile:GetNWEntity( "Launcher", NULL )

	if IsValid(Rack) then
		local Sound        = Rack:GetNWString( "Sound", "" )
		local SoundPitch   = Rack:GetNWInt( "SoundPitch", 100 )

		if not IsValidSound( Sound ) then
			Sound = "acf_extra/airfx/rocket_fire2.wav"
		end

		ACE_EmitSound( Sound, Missile:WorldSpaceCenter(), 140, SoundPitch, 1 )
	end
end


--[[---------------------------------------------------------
	THINK
-----------------------------------------------------------]]
function EFFECT:Think( )
	return false
end

--[[---------------------------------------------------------
	Draw the effect
-----------------------------------------------------------]]
function EFFECT:Render()
end
