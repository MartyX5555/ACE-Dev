
local ClassName = "Radar"


ACF = ACF or {}
ACF.Guidance = ACF.Guidance or {}

local this = ACF.Guidance[ClassName] or inherit.NewSubOf(ACF.Guidance.Wire)
ACF.Guidance[ClassName] = this

this.Name = ClassName

--Currently acquired target.
this.Target = nil

-- Cone to acquire targets within.
this.SeekCone = 20

-- Cone to retain targets within.
this.ViewCone = 25

-- This instance must wait this long between target seeks.
this.SeekDelay = 0.5 -- Re-seek drastically reduced cost so we can re-seek

-- Minimum distance for a target to be considered
this.MinimumDistance = 393.7	--10m

this.desc = "This guidance package detects radar signatures infront of itself, and guides the munition towards it."

function this:Init()
	self.LastSeek = CurTime() - self.SeekDelay - 0.000001
	self.LastTargetPos = Vector()
end

function this:Configure(missile)
    
    self.ViewCone = ACF_GetGunValue(missile.BulletData, "viewcone") or this.ViewCone
	self.ViewConeCos = math.cos(math.rad(self.ViewCone))
    self.SeekCone = ACF_GetGunValue(missile.BulletData, "seekcone") or this.SeekCone
    
end

--TODO: still a bit messy, refactor this so we can check if a flare exits the viewcone too.
function this:GetGuidance(missile)

	self:CheckTarget(missile)
	
	if not IsValid(self.Target) then return {} end

	local missilePos 		= missile:GetPos()
	local missileForward 	= missile:GetForward()
	local targetPhysObj 	= self.Target:GetPhysicsObject()
	local targetPos 		= self.Target:WorldSpaceCenter()

	local mfo       		= missile:GetForward()
	local mdir      		= (targetPos - missilePos):GetNormalized()
	local dot       		= mfo:Dot(mdir)
	
	if dot < self.ViewConeCos then
		self.Target = nil
		return {}
	else
        self.TargetPos = targetPos
		return {TargetPos = targetPos, ViewCone = self.ViewCone}
	end
	
end

function this:CheckTarget(missile)

	local target = self:AcquireLock(missile)

	if IsValid(target) then 
		self.Target = target
	end
end

 --Gets all valid targets, does not check angle
function this:GetWhitelistedEntsInCone(missile)

	local missilePos 	= missile:GetPos()
	local DPLRFAC 		= 65 - ( (self.SeekCone)/2 )
	local foundAnim 	= {}

	local ScanArray = ACE.contraptionEnts

	for k, scanEnt in pairs(ScanArray) do

		-- skip any invalid entity
		if not ACF_Check( scanEnt )then goto cont end 
		
		local entpos 	= scanEnt:GetPos()
		local difpos 	= entpos - missilePos
		local dist 		= difpos:Length()

		-- skip any ent outside of minimun distance
		if dist < self.MinimumDistance then goto cont end 

		local LOSData = {}
        LOSData.start  = thisPos
        LOSData.endpos = entpos
        LOSData.mask   = MASK_SOLID_BRUSHONLY

        local LOStr = util.TraceLine( LOSData ) --Hits anything in the world.		

		--Trace did not hit world
		if not LOStr.Hit then 

			local ang 		= missile:WorldToLocalAngles((entpos - missilePos):Angle())	-- Used for testing if inrange
			local absang 	= Angle(math.abs(ang.p),math.abs(ang.y),0)					-- Since I like ABS so much

			--Entity is within missile cone
			if (absang.p < self.SeekCone and absang.y < self.SeekCone) then

				local ConeInducedGCTRSize = dist/100 --2 meter wide tracehull for every 100m distance

                --Hits anything in the world.
                local GroundData = {}
                GroundData.start   = entpos
                GroundData.endpos  = entpos + difpos:GetNormalized() * 2000
                GroundData.mask    = MASK_SOLID_BRUSHONLY
                GroundData.mins    = Vector( -ConeInducedGCTRSize, -ConeInducedGCTRSize, -ConeInducedGCTRSize )
                GroundData.maxs    = -GroundData.mins

                local GroundTr = util.TraceHull(GroundData)

				if not GroundTr.Hit or GroundTr.HitSky then

					--Doppler testing fun
					local Velocity 	= ACF_GetPhysicalParent( scanEnt ):GetVelocity()
					local DPLR 		= missile:WorldToLocal(missilePos + Velocity * 2)
					local Speed 	= Velocity:Length()
					
					local DopplerY 	= math.min(math.abs( Speed / math.max(math.abs(DPLR.Y),0.01) )*100,10000) print("DY: "..DopplerY)
					local DopplerZ 	= math.min(math.abs( Speed / math.max(math.abs(DPLR.Z),0.01) )*100,10000) print("DZ: "..DopplerZ)

					--Qualifies as radar target, if a target is moving towards the radar at 30 mph the radar will also classify the target.
					if DopplerY < DPLRFAC or DopplerZ < DPLRFAC or ( math.abs(DPLR.X) > 880 ) or math.abs( DPLR.X / Speed ) > 0.3 then 

						print(DPLRFAC)

	                    debugoverlay.Cross(scanEnt:GetPos(), 10, 10, Color( 255, 255, 255 ), true )
						table.insert( foundAnim, scanEnt )

					end
				end
			end
		end

        ::cont::
	end
    
    return foundAnim
end

-- Return the first entity found within the seek-tolerance, or the entity within the seek-cone closest to the seek-tolerance.
function this:AcquireLock(missile)

	local curTime = CurTime()
    
    --We make sure that its seeking between the defined delay
	if self.LastSeek + self.SeekDelay > curTime then return nil end

	self.LastSeek = curTime

	-- Part 1: get all whitelisted entities in seek-cone.
	local found = self:GetWhitelistedEntsInCone(missile)
    	
	-- Part 2: get a good seek target
    local missilePos = missile:GetPos()

	local bestsignal 	 = 0
	local bestent 		 = nil
	local Signature 	 = 0
	local DistSignalLoss = 0
	local AngSignature   = 0

	for k, classifyent in pairs(found) do

		local entpos 	= classifyent:GetPos()
		local dist 		= (entpos - missilePos):Length()	
		local ang 		= missile:WorldToLocalAngles((entpos - missilePos):Angle())	--Used for testing if inrange
		local absang 	= Angle(math.abs(ang.p),math.abs(ang.y),0)--Since I like ABS so much

		local AvgDiff = math.max(absang.p, absang.y) 

		DistSignalLoss = ( dist/800 )^4
		PropSignature  = (( classifyent.ACF.Area or 100)/6) --Assuming we are seeing only 1 face of a cube
		AngSignature   = math.max( PropSignature + (360 - ( AvgDiff ))*10 - DistSignalLoss,0.1)							
		
		debugoverlay.Text(entpos - Vector(0,0,80), ("Final Signal: "..AngSignature), 10 ) print("Final Signal: "..AngSignature)

		--Sorts targets as closest to being directly in front of radar
		if AngSignature > bestsignal then 

			bestsignal 	= AngSignature
			bestent 	= classifyent
				
		end
	end

	if not bestent then return nil end

	return bestent
end

--Another Stupid Workaround. Since guidance degrees are not loaded when ammo is created
function this:GetDisplayConfig(Type)

	local seekCone = ACF.Weapons.Guns[Type].seekcone * 2 or 0
	local ViewCone = ACF.Weapons.Guns[Type].viewcone * 2 or 0

	return 
	{
		["Seeking"] = math.Round(seekCone, 1) .. " deg",
		["Tracking"] = math.Round(ViewCone, 1) .. " deg"
	}
end
