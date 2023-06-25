
AddCSLuaFile()

ACF.AmmoBlacklist.FLR = { "AC", "AL", "C", "HMG", "HW", "MG", "MO", "RAC", "SA", "SC", "SAM", "AAM", "ASM", "BOMB", "FFAR", "UAR", "GBU", "ECM" , "GL", "RM", "AR", "SBC", "ATR", "SL", "ATGM", "ARTY"}

local Round = {}

Round.type = "Ammo" --Tells the spawn menu what entity to spawn
Round.name = "[FLR] - " .. ACFTranslation.ShellFLR[1] --Human readable name
Round.model = "models/munitions/round_100mm_shot.mdl" --Shell flight model
Round.desc  = ACFTranslation.ShellFLR[2]
Round.netid = 11 --Unique ammotype ID for network transmission

function Round.create( Gun, BulletData )

	local flare = ents.Create( "ace_flare" )

	if not IsValid( flare ) then return end

		flare:SetPos( BulletData.Pos )
		flare:SetAngles( BulletData.Flight:Angle() )

		flare.Heat = (BulletData.FillerMass or 1) * 500
		flare.Life = (BulletData.FillerMass or 1) / (0.3 * ACFM.FlareBurnMultiplier)

		flare:Spawn()
		flare:SetOwner( Gun )

		if CPPI then
			flare:CPPISetOwner( Gun.Owner)
		end

		flare.PhysObj = flare:GetPhysicsObject()
		flare.PhysObj:SetVelocity( BulletData.Flight )



end

-- Function to convert the player's slider data into the complete round data
function Round.convert( _, PlayerData )

	local Data          = {}
	local ServerData    = {}
	local GUIData       = {}

	PlayerData.PropLength   =  PlayerData.PropLength    or 0
	PlayerData.ProjLength   =  PlayerData.ProjLength    or 0
	PlayerData.Tracer       =  PlayerData.Tracer        or 0
	PlayerData.TwoPiece     =  PlayerData.TwoPiece      or 0
	if not PlayerData.Data5 then PlayerData.Data5 = 0 end


	PlayerData, Data, ServerData, GUIData = ACF_RoundBaseGunpowder( PlayerData, Data, ServerData, GUIData )

	--Shell sturdiness calcs
	Data.ProjMass           = math.max(GUIData.ProjVolume-PlayerData.Data5,0) * 7.9 / 1000 + math.min(PlayerData.Data5,GUIData.ProjVolume) * ACF.HEDensity / 1000--Volume of the projectile as a cylinder - Volume of the filler * density of steel + Volume of the filler * density of TNT
	Data.MuzzleVel          = ACF_MuzzleVelocity( Data.PropMass, Data.ProjMass, Data.Caliber )

	local Energy            = ACF_Kinetic( Data.MuzzleVel * 39.37 , Data.ProjMass, Data.LimitVel )
	local MaxVol            = ACF_RoundShellCapacity( Energy.Momentum, Data.FrArea, Data.Caliber, Data.ProjLength )

	GUIData.MinFillerVol    = 0
	GUIData.MaxFillerVol    = math.min(GUIData.ProjVolume, MaxVol * 0.9)
	GUIData.FillerVol       = math.min(PlayerData.Data5,GUIData.MaxFillerVol)
	Data.FillerMass         = GUIData.FillerVol * ACF.HEDensity / 200

	Data.ProjMass           = math.max(GUIData.ProjVolume-GUIData.FillerVol,0) * 7.9 / 1000 + Data.FillerMass
	Data.MuzzleVel          = ACF_MuzzleVelocity( Data.PropMass, Data.ProjMass, Data.Caliber )

	--Random bullshit left
	Data.ShovePower         = 0.1
	Data.PenAera            = Data.FrArea^ACF.PenAreaMod
	Data.DragCoef           = ((Data.FrArea / 375) / Data.ProjMass)
	Data.LimitVel           = 700                                       --Most efficient penetration speed in m/s
	Data.KETransfert        = 0.1                                   --Kinetic energy transfert to the target for movement purposes
	Data.Ricochet           = 75                                        --Base ricochet angle

	Data.BurnRate           = 0.4 * ACFM.FlareBurnMultiplier
	Data.BurnTime           = Data.FillerMass / Data.BurnRate

	Data.BoomPower          = Data.PropMass + Data.FillerMass

	if SERVER then --Only the crates need this part
		ServerData.Id   = PlayerData.Id
		ServerData.Type = PlayerData.Type
		return table.Merge(Data,ServerData)
	end

	if CLIENT then --Only tthe GUI needs this part
		GUIData = table.Merge(GUIData, Round.getDisplayData(Data))
		return table.Merge(Data,GUIData)
	end

end


function Round.getDisplayData(Data)
	local GUIData = {}

	GUIData.MaxPen = 0

	GUIData.BurnRate = Data.BurnRate
	GUIData.BurnTime = Data.BurnTime

	return GUIData
end


function Round.network( Crate, BulletData )

	Crate:SetNWString( "AmmoType", "FLR" )
	Crate:SetNWString( "AmmoID", BulletData.Id )
	Crate:SetNWFloat( "Caliber", BulletData.Caliber )
	Crate:SetNWFloat( "ProjMass", BulletData.ProjMass )
	Crate:SetNWFloat( "FillerMass", BulletData.FillerMass )
	Crate:SetNWFloat( "PropMass", BulletData.PropMass )
	Crate:SetNWFloat( "DragCoef", BulletData.DragCoef )
	Crate:SetNWFloat( "MuzzleVel", BulletData.MuzzleVel )
	Crate:SetNWFloat( "Tracer", BulletData.Tracer )

end

function Round.cratetxt( BulletData )

	local DData = Round.getDisplayData(BulletData)

	local str =
	{
		"Muzzle Velocity: ", math.Round(BulletData.MuzzleVel, 1), " m/s\n",
		"Burn Rate: ", math.Round(DData.BurnRate, 1), " kg/s\n",
		"Burn Duration: ", math.Round(DData.BurnTime, 1), " s\n"--,
	}

	return table.concat(str)

end

function Round.guicreate( Panel, Table )

	acfmenupanel:AmmoSelect( ACF.AmmoBlacklist.FLR )

	acfmenupanel:CPanelText("CrateInfoBold", "Crate information:", "DermaDefaultBold")

	acfmenupanel:CPanelText("BonusDisplay", "")

	acfmenupanel:CPanelText("Desc", "")	--Description (Name, Desc)
	acfmenupanel:CPanelText("BoldAmmoStats", "Round information: ", "DermaDefaultBold")
	acfmenupanel:CPanelText("LengthDisplay", "")	--Total round length (Name, Desc)
	acfmenupanel:CPanelText("VelocityDisplay", "")	--Proj muzzle velocity (Name, Desc)

	acfmenupanel:AmmoSlider("PropLength",0,0,1000,3, "Propellant Length", "")	--Propellant Length Slider (Name, Value, Min, Max, Decimals, Title, Desc)
	acfmenupanel:AmmoSlider("ProjLength",0,0,1000,3, "Projectile Length", "")	--Projectile Length Slider (Name, Value, Min, Max, Decimals, Title, Desc)
	acfmenupanel:AmmoSlider("FillerVol",0,0,1000,3, "Dual Spectrum Filler", "") --Hollow Point Cavity Slider (Name, Value, Min, Max, Decimals, Title, Desc)

	acfmenupanel:CPanelText("VelocityDisplay", "")	--Proj muzzle velocity (Name, Desc)
	acfmenupanel:CPanelText("BurnRateDisplay", "")	--Proj muzzle penetration (Name, Desc)
	acfmenupanel:CPanelText("BurnDurationDisplay", "")	--HE Blast data (Name, Desc)
	--acfmenupanel:CPanelText("DistractChanceDisplay", "")	--HE Fragmentation data (Name, Desc)

	Round.guiupdate( Panel, Table )

end

function Round.guiupdate( Panel )

	local PlayerData = {}
		PlayerData.Id = acfmenupanel.AmmoData.Data.id			--AmmoSelect GUI
		PlayerData.Type = "FLR"										--Hardcoded, match ACFRoundTypes table index
		PlayerData.PropLength = acfmenupanel.AmmoData.PropLength	--PropLength slider
		PlayerData.ProjLength = acfmenupanel.AmmoData.ProjLength	--ProjLength slider
		PlayerData.Data5 = acfmenupanel.AmmoData.FillerVol
		PlayerData.Tracer	= acfmenupanel.AmmoData.Tracer
		PlayerData.TwoPiece	= acfmenupanel.AmmoData.TwoPiece

	local Data = Round.convert( Panel, PlayerData )

	RunConsoleCommand( "acfmenu_data1", acfmenupanel.AmmoData.Data.id )
	RunConsoleCommand( "acfmenu_data2", PlayerData.Type )
	RunConsoleCommand( "acfmenu_data3", Data.PropLength )		--For Gun ammo, Data3 should always be Propellant
	RunConsoleCommand( "acfmenu_data4", Data.ProjLength )		--And Data4 total round mass
	RunConsoleCommand( "acfmenu_data5", Data.FillerVol )
	RunConsoleCommand( "acfmenu_data10", Data.Tracer )
	RunConsoleCommand( "acfmenu_data11", Data.TwoPiece )

	---------------------------Ammo Capacity-------------------------------------
	ACE_AmmoCapacityDisplay( Data )
	-------------------------------------------------------------------------------
	acfmenupanel:AmmoSlider("PropLength",Data.PropLength,Data.MinPropLength,Data.MaxTotalLength,3, "Propellant Length", "Propellant Mass : " .. (math.floor(Data.PropMass * 1000)) .. " g" )	--Propellant Length Slider (Name, Min, Max, Decimals, Title, Desc)
	acfmenupanel:AmmoSlider("ProjLength",Data.ProjLength,Data.MinProjLength,Data.MaxTotalLength,3, "Projectile Length", "Projectile Mass : " .. (math.floor(Data.ProjMass * 1000)) .. " g")	--Projectile Length Slider (Name, Min, Max, Decimals, Title, Desc)
	acfmenupanel:AmmoSlider("FillerVol",Data.FillerVol,Data.MinFillerVol,Data.MaxFillerVol,3, "Dual Spectrum Filler", "Filler Mass : " .. (math.floor(Data.FillerMass * 1000)) .. " g")	--HE Filler Slider (Name, Min, Max, Decimals, Title, Desc)

	acfmenupanel:CPanelText("Desc", ACF.RoundTypes[PlayerData.Type].desc)	--Description (Name, Desc)
	acfmenupanel:CPanelText("LengthDisplay", "Round Length : " .. (math.floor((Data.PropLength + Data.ProjLength + Data.Tracer) * 100) / 100) .. "/" .. Data.MaxTotalLength .. " cm")	--Total round length (Name, Desc)
	acfmenupanel:CPanelText("VelocityDisplay", "Muzzle Velocity : " .. math.floor(Data.MuzzleVel * ACF.VelScale) .. " m/s")	--Proj muzzle velocity (Name, Desc)

	acfmenupanel:CPanelText("BurnRateDisplay", "Burn Rate : " .. math.Round(Data.BurnRate, 1) .. " kg/s")
	acfmenupanel:CPanelText("BurnDurationDisplay", "Burn Duration : " .. math.Round(Data.BurnTime, 1) .. " s")

end

list.Set( "SPECSRoundTypes", "FLR", Round )
list.Set( "ACFRoundTypes", "FLR", Round )  --Set the round properties
list.Set( "ACFIdRounds", Round.netid, "FLR" ) --Index must equal the ID entry in the table above, Data must equal the index of the table above

ACF.RoundTypes  = list.Get("ACFRoundTypes")
ACF.IdRounds	= list.Get("ACFIdRounds")
