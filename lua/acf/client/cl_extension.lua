--Featuring functions which manage the current built in ace sound extension system
--TODO: Refactor all this, making ONE function for every sound event

--i would like to have a way of having realtime volume/pitch depending if approaching/going away, 
--as having a way to switch sounds between indoor & outdoor zones. They will sound fine, issue it would be when you pass from an area to another when the sound is being played


ACE = ACE or {}

--Defines the delay time caused by the distance between the explosion and you. Increasing it will increment the required time to hear a distant event
ACE.DelayMultipler = 1

--Defines the distance range for close, mid and far sounds. Incrementing it will increase the distances between sounds
ACE.DistanceMultipler = 1

--Handles Explosions
function ACEE_SBlast( HitPos, Radius, HitWater )

	--Don't start this without a player
	local ply = LocalPlayer()
	if not IsValid( ply ) then return end

	local count = 1
	local countToFinish = nil
	local Emitted = false --Was the sound played?
	local ide = 'ACEBoom#'..math.random(1,1000)
	--print('timer created! ID: '..ide)

	--Making sure that this timer is unique
	if timer.Exists( ide ) then
		ide = ide..math.random(1,1000)
		--print('Found timer with this identifier. Changed to: '..ide)
	end

	--Still it's possible to saturate this, prob you will need to be lucky to get the SAME id in both cases.
	if timer.Exists( ide ) then print('i would like to know: how did you saturate this? ooof') return end
	timer.Create( ide , 0.1, 0, function()

		count = count + 1

		local plyPos = ply:GetPos()
		--print(plyPos)

		local Dist = math.abs((plyPos - HitPos):Length())
		--print('distance from explosion: '..Dist)

		local Volume = ( 1/(Dist/500)*Radius*0.2 ) 
		--print('Vol: '..Volume)

		local Pitch =  math.Clamp(1000/Radius,25,130)
		--print('pitch: '..Pitch)

		local Delay = ( Dist/1500 ) * ACE.DelayMultipler
		--print('amount to match: '..Delay)

		if count > Delay then

			--done so we keep calculating for post-explosion effects (doppler, volume, etc)
			if not countToFinish then countToFinish = count*3 end

			--if its not already emitted
			if not Emitted then

				--print('timer has emitted the sound in the time: '..count)
				Emitted = true

				--Ground explosions
				if not HitWater then

					local Sound

					--This defines the distance between areas for close, mid and far sounds
					local CloseDist = Radius * 250 * ACE.DistanceMultipler

					--Medium dist will be 4.25x times of closedist. So if closedist is 1000 units, then medium dist will be until 4250 units
					local MediumDist = CloseDist*4.25 

					--this variable fixes the vol for a better volume scale. It's possible to change it depending of the sound area below
					local VolFix
					local PitchFix

					--Required radius to be considered a small explosion. Less than this the explosion will be considered tiny
					local SmallEx = 5 

					--Required radius to be considered a medium explosion
					local MediumEx = 10

					--Required radius to be considered a large explosion
					local LargeEx = 20

					--Required radius to be considered a huge explosion. IDK what thing could pass this, but there is it :)
					local HugeEx = 150

					--Close distance
					if Dist < CloseDist then
						--print('you are close')

						VolFix = 2
						PitchFix = 1
						Sound = "acf_other/explosions/ambient/tiny/close/close"..math.random(1,4)..".wav"

						if Radius >= SmallEx then
							VolFix = 2
							PitchFix = 1
							Sound = "acf_other/explosions/ambient/small/close/close"..math.random(1,4)..".wav"

							if Radius >= MediumEx then
								VolFix = 2
								PitchFix = 1
								Sound = "acf_other/explosions/ambient/medium/close/close"..math.random(1,4)..".wav"

								if Radius >= LargeEx then
									VolFix = 2
									PitchFix = 1
									Sound = "acf_other/explosions/ambient/large/close/close"..math.random(1,4)..".wav"

									if Radius >= HugeEx then
										VolFix = 2000000  -- rip your ears
										PitchFix = 3
										Sound = "acf_other/explosions/ambient/huge/bigboom.wav"
									end
								end
							end
						end

					--Medium distance
					elseif Dist >= CloseDist and Dist < MediumDist then
						--print('you are mid')

						VolFix = 2
						PitchFix = 1
						Sound = "acf_other/explosions/ambient/tiny/mid/mid"..math.random(1,4)..".wav"

						if Radius >= SmallEx then
							VolFix = 2
							PitchFix = 1
							Sound = "acf_other/explosions/ambient/small/mid/mid"..math.random(1,4)..".wav"

							if Radius >= MediumEx then
								VolFix = 2
								PitchFix = 1
								Sound = "acf_other/explosions/ambient/medium/mid/mid"..math.random(1,3)..".wav"

								if Radius >= LargeEx then
									VolFix = 2
									PitchFix = 1
									Sound = "acf_other/explosions/ambient/large/mid/mid"..math.random(1,4)..".wav"

								end
							end
						end

					--Far distance				
					elseif Dist >= MediumDist then
						--print('you are far')

						VolFix = 4.5
						PitchFix = 1
						Sound = "acf_other/explosions/ambient/tiny/far/far"..math.random(1,4)..".wav"

						if Radius >= SmallEx then
							VolFix = 4.5
							PitchFix = 1
							Sound = "acf_other/explosions/ambient/small/far/far"..math.random(1,4)..".wav"

							if Radius >= MediumEx then
								VolFix = 4.5
								PitchFix = 1
								Sound = "acf_other/explosions/ambient/medium/far/far"..math.random(1,3)..".wav"

								if Radius >= LargeEx then
									VolFix = 4.5
									PitchFix = 1
									Sound = "acf_other/explosions/ambient/large/far/far"..math.random(1,3)..".wav"

								end
							end
						end

					end

					--NOTE: For proper doppler effect where pitch/volume is dynamically changed, we need something like soundcreate() instead of ply:emitsound. 
					--Downside of this, that due to gmod limits, one scripted sound per entity can be used at once. Which idk if it would be good for us. 
					--We'll have more than one dynamic sound at once :/ weird


					ply:EmitSound( Sound, 75, Pitch * PitchFix, Volume * VolFix )

					--Underwater Explosions
				else
					ply:EmitSound( "ambient/water/water_splash"..math.random(1,3)..".wav", 75, Pitch * 0.75, Volume * 0.25)
					ply:EmitSound( "^weapons/underwater_explode3.wav", 75, Pitch * 0.75, Volume * 0.25)
				end
			end

			--its time has ended
			if count > countToFinish then
				--print('timer "'..ide..'"" has been repeated '..count..' times. stopping & removing it...')
				timer.Stop( ide )
				timer.Remove( ide )
			end
		end
	end )

end

function ACEE_SPen( HitPos, Velocity, Mass )

	--Don't start this without a player
	local ply = LocalPlayer()
	if not IsValid( ply ) then return end

	local count = 1
	local countToFinish = nil
	local Emitted = false --Was the sound played?
	local ide = 'ACEPen#'..math.random(1,1000)
	--print('timer created! ID: '..ide)

	--Making sure that this timer is unique
	if timer.Exists( ide ) then
		ide = ide..math.random(1,1000)
		--print('Found timer with this identifier. Changed to: '..ide)
	end

	--Still it's possible to saturate this, prob you will need to be lucky to get the SAME id in both cases.
	if timer.Exists( ide ) then print('i would like to know: how did you saturate this? ooof') return end
	timer.Create( ide , 0.1, 0, function()

		count = count + 1

		local plyPos = ply:GetPos()
		--print(plyPos)

		local Dist = math.abs((plyPos - HitPos):Length())
		--print('distance from explosion: '..Dist)

		--print('Mass: '..Mass)

		local Volume = ( 1/(Dist/500)*Mass/17.5 ) 
		--print('Vol: '..Volume)

		local Pitch =  math.Clamp(Velocity*1,90,150)

		local Delay = ( Dist/1500 ) * ACE.DelayMultipler
		--print('amount to match: '..Delay)

		if count > Delay then

			--done so we keep calculating for post explosion effects (doppler, volume, etc)
			if not countToFinish then countToFinish = count*3 end

			if not Emitted then
				--print('timer has emitted the sound in the time: '..count)
				Emitted = true

				--TODO: change this for soundCreate instead
				--ply:EmitSound( "/acf_other/penetratingshots/0000029"..math.random(2,4)..".wav", 75, Pitch, Volume )
				ply:EmitSound( "/acf_other/penetratingshots/pen"..math.random(1,6)..".wav", 75, Pitch, Volume )

			end

			--its time has ended
			if count > countToFinish then
				--print('timer "'..ide..'"" has been repeated '..count..' times. stopping & removing it...')
				timer.Stop( ide )
				timer.Remove( ide )
			end
		end
	end )
end

function ACEE_SRico( HitPos, Caliber, Velocity, HitWorld )

	--Don't start this without a player
	local ply = LocalPlayer()
	if not IsValid( ply ) then return end

	local count = 1
	local countToFinish = nil
	local Emitted = false --Was the sound played?
	local ide = 'ACERico#'..math.random(1,1000)
	--print('timer created! ID: '..ide)

	--Making sure that this timer is unique
	if timer.Exists( ide ) then
		ide = ide..math.random(1,1000)
		--print('Found timer with this identifier. Changed to: '..ide)
	end

	--Still it's possible to saturate this, prob you will need to be lucky to get the SAME id in both cases.
	if timer.Exists( ide ) then print('i would like to know: how did you saturate this? ooof') return end
	timer.Create( ide , 0.1, 0, function()

		count = count + 1

		local plyPos = ply:GetPos()
		--print(plyPos)

		local Dist = math.abs((plyPos - HitPos):Length())
		--print('distance from explosion: '..Dist)

		local Volume = ( 1/(Dist/500)*Velocity/130000 ) 
		--print('Vol: '..Volume)

		local Pitch =  math.Clamp(Velocity*0.001,90,150)
		--print('pitch: '..Pitch)

		local Delay = ( Dist/1500 ) * ACE.DelayMultipler
		--print('amount to match: '..Delay)

		if count > Delay then

			--done so we keep calculating for post explosion effects (doppler, volume, etc)
			if not countToFinish then countToFinish = count*3 end

			if not Emitted then
				--print('timer has emitted the sound in the time: '..count)
				Emitted = true

				if not HitWorld then
					local Sound =  "acf_other/ricochets/large/close/richo"..math.random(1,7)..".wav"
					local VolFix = 4

					if Caliber <= 5 then
						Sound = "acf_other/ricochets/medium/richo"..math.random(1,6)..".wav"
						VolFix = 1

						if Caliber <= 2 then
							Sound = "acf_other/ricochets/small/richo"..math.random(1,2)..".wav"
							VolFix = 1.25
						end
					end
					ply:EmitSound( Sound , 75, Pitch, Volume * VolFix )
				end
			end

			--its time has ended
			if count > countToFinish then
				--print('timer "'..ide..'"" has been repeated '..count..' times. stopping & removing it...')
				timer.Stop( ide )
				timer.Remove( ide )
			end
		end
	end )
end