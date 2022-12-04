AddCSLuaFile( "acf/shared/rounds/ace_roundfunctions.lua" )


do

	local Floor = math.floor
	local MaxValue = math.max
	local MinValue = math.min
	local PI = 3.1416

	function ACF_RoundBaseGunpowder( PlayerData, Data, ServerData, GUIData )

		local BulletMax = ACF.Weapons["Guns"][PlayerData["Id"]]["round"]
			
		GUIData.MaxTotalLength 	= BulletMax.maxlength * (Data.LengthAdj or 1)
			
		Data.Caliber			= ACF.Weapons["Guns"][PlayerData["Id"]]["caliber"]
		Data.FrArea 			= PI * (Data.Caliber/2)^2

		Data.Tracer 			= PlayerData.Tracer > 0 and math.min(Data.Caliber/5,3) or 0 --Tracer space calcs
		Data.TwoPiece 			= PlayerData.TwoPiece > 0 and 1 or 0
--[[
		print("\nData to check")
		print(PlayerData.Tracer)
		print(PlayerData.TwoPiece)
    	print("\nCreated Data")
    	print(Data.Tracer)
    	print(Data.TwoPiece)
]]
		--print('Prop Before: '..PlayerData["PropLength"])
		--print('Proj Before: '..PlayerData["ProjLength"])

		local Type = PlayerData.Type or ''

		-- created to adapt old ammos to the new heatfs speed
		if Type == 'HEATFS' or Type == 'THEATFS' then
			PlayerData.PropLength = math.max(0.01 + Data.Caliber * 3.9, PlayerData.PropLength )

			-- check if current lenght exceeds the max lenght available
			if PlayerData.PropLength + PlayerData.ProjLength > GUIData.MaxTotalLength then

				PlayerData.ProjLength = GUIData.MaxTotalLength - PlayerData.PropLength

			end

		-- same as above, but for hefs
		elseif Type == 'HEFS' then
			PlayerData.PropLength = math.max(0.01 + Data.Caliber * 4.5, PlayerData.PropLength )

			--check if current lenght exceeds the max lenght available
			if PlayerData.PropLength + PlayerData.ProjLength + 1 > GUIData.MaxTotalLength then

				PlayerData.ProjLength = GUIData.MaxTotalLength - PlayerData.PropLength

			end
		end

		--print('MaxLenght: '..GUIData["MaxTotalLength"])
		--print('Remain for Proj: '..GUIData["MaxTotalLength"] - PlayerData["PropLength"])
		--print('Prop After: '..PlayerData["PropLength"])
		--print('Proj After: '..PlayerData["ProjLength"])

		local PropMax = (BulletMax.propweight * 1000/ACF.PDensity) / Data.FrArea	--Current casing absolute max propellant capacity
		local CurLength = (PlayerData.ProjLength + math.min(PlayerData.PropLength,PropMax) + Data.Tracer )


		GUIData.MinPropLength = 0.01
		GUIData.MaxPropLength = math.max(math.min(GUIData.MaxTotalLength - CurLength + PlayerData.PropLength, PropMax), GUIData.MinPropLength) --Check if the desired prop lenght fits in the case and doesn't exceed the gun max
		
		GUIData.MinProjLength = Data.Caliber * 1.5
		GUIData.MaxProjLength = math.max(GUIData.MaxTotalLength - CurLength + PlayerData.ProjLength, GUIData.MinProjLength ) --Check if the desired proj lenght fits in the case
		
		--This is to check the current ratio between elements if i need to clamp it
		local Ratio 			= math.min( (GUIData.MaxTotalLength - Data.Tracer )/(PlayerData.ProjLength + math.min(PlayerData.PropLength,PropMax)) , 1 ) 
		
		Data.ProjLength 		= math.Clamp( PlayerData.ProjLength * Ratio, GUIData.MinProjLength, GUIData.MaxProjLength )
		Data.PropLength 		= math.Clamp( PlayerData.PropLength * Ratio, GUIData.MinPropLength, GUIData.MaxPropLength )
		
		Data.PropMass 		= Data.FrArea * (Data.PropLength * ACF.PDensity/1000) --Volume of the case as a cylinder * Powder density converted from g to kg
		GUIData.ProjVolume 	= Data.FrArea * Data.ProjLength
		Data.RoundVolume 	= Data.FrArea * (Data.ProjLength + Data.PropLength )
		
		return PlayerData, Data, ServerData, GUIData
	end

	function ACF_RoundShellCapacity( Momentum, FrArea, Caliber, ProjLength )

		local MinWall 	= 0.2+((Momentum/FrArea)^0.7)/50 --The minimal shell wall thickness required to survive firing at the current energy level	
		local Length 	= math.max(ProjLength-MinWall,0)
		local Radius 	= math.max((Caliber/2)-MinWall,0)
		local Volume 	= PI * Radius^2 * Length

		return  Volume, Length, Radius --Returning the cavity volume and the minimum wall thickness
	end

	function ACF_RicoProbability( Rico, Speed )
		
		local RicoAngle = math.Round(math.min(Rico -  (( (Speed-800) / 39.37 ) /5),89))
			
	    local None = math.max(RicoAngle-10,1) --0% chance to ricochet
		local Mean = math.max(RicoAngle,1)   --50% chance to ricochet
		local Max = math.max(RicoAngle+10,1)  --100% chance to ricochet
		
		return None, Mean, Max

	end

	--Formula from https://mathscinotes.wordpress.com/2013/10/03/parameter-determination-for-pejsa-velocity-model/
	--not terribly accurate for acf, particularly small caliber (7.62mm off by 120 m/s at 800m), but is good enough for quick indicator
	function ACF_PenRanging( MuzzleVel, DragCoef, ProjMass, PenArea, LimitVel, Range ) --range in m, vel is m/s

		local V0 = (MuzzleVel * 39.37 * ACF.VelScale) 	-- initial velocity
		local D0 = (DragCoef * V0^2 / ACF.DragDiv)		-- initial drag
		local K1 = ( D0 / (V0^(3/2)) )^-1				-- estimated drag coefficient

		local Vel = (  math.max( math.sqrt(V0) - ((Range*39.37) / (2 * K1)), 0)   )^2 
		local Pen = (ACF_Kinetic( Vel, ProjMass, LimitVel ).Penetration/PenArea)*ACF.KEtoRHA

		return (Vel*0.0254), Pen
	end

	--This function is a direct copy from acf_ammo code. So its expected that the result matches with the ammo count
	--TODO: Use this same function for Existent crates? Weird to have this same code in both places.
	function ACE_AmmoCapacity( Data )

		local GunId 	  = acfmenupanel.AmmoData.Data.id
		local AmmoGunData = ACF.Weapons.Guns[GunId]
		local GunClass    = AmmoGunData.gunclass
		local ClassData   = ACF.Classes.GunClass[GunClass] 

		local ProjLenght = Data.ProjLength
		local PropLenght = Data.PropLength
		local Caliber    = Data.Caliber

		local width, shellLength

		if ClassData.type == "missile" then
            width       = AmmoGunData.modeldiameter or AmmoGunData.caliber
            shellLength = AmmoGunData.length/ACF.AmmoLengthMul/3
		else
	    	width 		= (Caliber)/ACF.AmmoWidthMul/1.6
			shellLength = ((PropLenght or 0) + (ProjLenght or 0))/ACF.AmmoLengthMul/3
		end

		local Id 		 = acfmenupanel.AmmoData.Id
		local AmmoData   = ACF.Weapons.Ammo[Id]
	    local CrateVol   = AmmoData.volume
		local Dimensions = Vector(AmmoData.Lenght,AmmoData.Width,AmmoData.Height)

	    local cap1 = Floor(Dimensions.x/shellLength) * Floor(Dimensions.y/width) * Floor(Dimensions.z/width)
	    local cap2 = Floor(Dimensions.y/shellLength) * Floor(Dimensions.x/width) * Floor(Dimensions.z/width) 
	    local cap3 = Floor(Dimensions.z/shellLength) * Floor(Dimensions.x/width) * Floor(Dimensions.y/width) 

	    --Split the shell in 2, leave the other piece next to it.
	    local piececap1 = Floor(Dimensions.x/(shellLength/2)) * Floor(Dimensions.y/(width*2)) * Floor(Dimensions.z/width)
	    local piececap2 = Floor(Dimensions.y/(shellLength/2)) * Floor(Dimensions.x/(width*2)) * Floor(Dimensions.z/width)
	    local piececap3 = Floor(Dimensions.z/(shellLength/2)) * Floor(Dimensions.x/(width*2)) * Floor(Dimensions.z/width)

	    local Cap       = MaxValue(cap1,cap2,cap3)
	    local FpieceCap = MaxValue(piececap1,piececap2,piececap3)

	    local TwoPiece = false

	    --Why would you need the 2 piece for rounds below 50mm? Unless you want legos there....
	    if Data.Caliber >= 5 then 
		    if FpieceCap > Cap and Data.TwoPiece > 0 then  --only if the 2 piece system is allowed to be used
		        Cap 	 = FpieceCap
		        TwoPiece = true
		    end
		end

		local RoFNerf = TwoPiece and 30 or nil

	    return Cap, RoFNerf, TwoPiece
	end

	--General Ammo Capacity diplay shown on ammo config
	function ACE_AmmoCapacityDisplay(Data)

		local Cap, RoFNerf, TwoPiece = ACE_AmmoCapacity( Data )

		local plur = ""..Cap..' round'
		
		if Cap > 1 then
		    plur = ""..Cap..' rounds'
		end
		
		local bonustxt = "Storage: "..plur
		
		if TwoPiece then	
			bonustxt = bonustxt..". Uses 2 piece ammo. -"..RoFNerf.."% RoF"
		end
		acfmenupanel:CPanelText("BonusDisplay", bonustxt )
	end

	function ACE_AmmoRangeStats( MuzzleVel, DragCoef, ProjMass, PenArea, LimitVel )

	    local Range 	= {}
	    Range.Vel 		= {}
	    Range.Pen 		= {}
	    Range.Distance 	= {}
	    final_text		= {}

	    for i = 1, 4 do

	    	Range.Distance[i] = (2^(i-1))*100
	    	Range.Vel[i], Range.Pen[i] = ACF_PenRanging( MuzzleVel, DragCoef, ProjMass, PenArea, LimitVel, Range.Distance[i] ) 

	    	final_text[i] = "At "..Range.Distance[i].."m pen: "..Floor(Range.Pen[i]).."mm @ "..Floor(Range.Vel[i]).."m\\s\n"

	    end

	    local ftext = table.concat(final_text)

	    acfmenupanel:CPanelText("PenetrationDisplay", ftext.."\nThe range data is an approximation and may not be entirely accurate.\n") 

	end

	function ACE_AmmoStats(RoundLenght, MaxTotalLenght, MuzzleVel, MaxPen)
	   acfmenupanel:CPanelText("BoldAmmoStats", "Round information: ", "DermaDefaultBold")
	   acfmenupanel:CPanelText("AmmoStats", "Round Length: "..RoundLenght.."/"..MaxTotalLenght.." cms\nMuzzle Velocity: "..MuzzleVel.." m\\s\nMax penetration: "..MaxPen.." mm RHA") --Total round length (Name, Desc)
	   
	end

	do 

		function ACE_UpperCommonDataDisplay( Data, PlayerData )

			if not acfmenupanel then return end

			if not Data or not PlayerData then
				acfmenupanel:CPanelText("CrateInfoBold", "Crate information:", "DermaDefaultBold")

				acfmenupanel:CPanelText("BonusDisplay", "\n")
				acfmenupanel:CPanelText("Desc", "")
				ACE_AmmoStats( 0, 0, 0, 0 )

			else
				acfmenupanel:CPanelText("CrateInfoBold", "Crate information:", "DermaDefaultBold")

				ACE_AmmoCapacityDisplay( Data )
    			acfmenupanel:CPanelText("Desc", ACF.RoundTypes[PlayerData.Type].desc)
				ACE_AmmoStats( (Floor( ( Data.PropLength + Data.ProjLength + (Floor(Data.Tracer*5)/10))*100) /100), (Data.MaxTotalLength) ,Floor(Data.MuzzleVel*ACF.VelScale) , Floor(Data.MaxPen) )
			end

		end


		local TPtip = "Attempts to increase the ammo capacity by dividing the round in 2 pieces, at the cost of more reload time.\n\nWorks with rounds above 50mm and does nothing when the cap cannot be increased."
		local Trtip = "Adds a trail to the shell, which will be seen during the flight. \nUseful for cases when you want to correct trayectories.\n\nProTip: Apply a color to the crate to change the tracer color."

		function ACE_CommonDataDisplay( Data )

			if not acfmenupanel then return end

			if not Data then

			    acfmenupanel:AmmoCheckbox("Tracer", "Enable Tracer: ", "", Trtip)                           	--Tracer checkbox (Name, Title, Desc)
			    acfmenupanel:AmmoCheckbox("TwoPiece", "Enable Two Piece Storage", "", TPtip )
			    acfmenupanel:CPanelText("RicoDisplay", "")                                  		--estimated rico chance
			    acfmenupanel:CPanelText("PenetrationDisplay", "")                           		--Proj muzzle penetration (Name, Desc)
			else

			    acfmenupanel:AmmoCheckbox("Tracer", "Enable Tracer: "..(Floor(Data.Tracer*5)/10).."cm\n", "", Trtip )           --Tracer checkbox (Name, Title, Desc)
			    acfmenupanel:AmmoCheckbox("TwoPiece", "Enable Two Piece Storage", "", TPtip ) 

			    local None, Mean, Max = ACF_RicoProbability( Data.Ricochet, Data.MuzzleVel*ACF.VelScale )
			    acfmenupanel:CPanelText("RicoDisplay", '0% chance of ricochet at: '..None..'°\n50% chance of ricochet at: '..Mean..'°\n100% chance of ricochet at: '..Max..'°')

			    ACE_AmmoRangeStats( Data.MuzzleVel, Data.DragCoef, Data.ProjMass, Data.PenArea, Data.LimitVel )
			end
		end

		--Because HE/Shaped rounds are different. Intented not to be merged into main function above, as its temporal.
		function ACE_Checkboxes( Data )

			if not acfmenupanel then return end

			if not Data then
			    acfmenupanel:AmmoCheckbox("Tracer", "Enable Tracer: ", "", Trtip)                           	--Tracer checkbox (Name, Title, Desc)
			    acfmenupanel:AmmoCheckbox("TwoPiece", "Enable Two Piece Storage", "", TPtip )
			else
		    	acfmenupanel:AmmoCheckbox("Tracer", "Enable Tracer: "..(Floor(Data.Tracer*5)/10).."cm\n", "", Trtip )           --Tracer checkbox (Name, Title, Desc)
		    	acfmenupanel:AmmoCheckbox("TwoPiece", "Enable Two Piece Storage", "", TPtip ) 	
			end
		end
	end

	--=====================[ DEPRECATED FUNCTION ]=====================--

	--This function is not used by ACE anymore, but i´ll keep it just for those acf2 custom ammos dont break	
	function ACF_CalcCrateStats( CrateVol, RoundVol )
		return 0, 0, 0
	end

end