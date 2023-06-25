
-- Loads all files from shared folder
AddCSLuaFile()

ACF = ACF or {}

local GunClasses          = {}
local RackClasses         = {}
local RadarClasses        = {}

local GunTable            = {}
local RackTable           = {}
local Radars              = {}

local EngineTable         = {}
local GearboxTable        = {}
local FuelTankTable       = {}
local FuelTankSizeTable   = {}

local MobilityTable       = {}

local GSoundData          = {}
local ModelData           = {}

-- setup base classes
local gun_base = {
	ent    = "acf_gun",
	type   = "Guns"
}
local engine_base = {
	ent    = "acf_engine",
	type   = "Engines"
}
local gearbox_base = {
	ent    = "acf_gearbox",
	type   = "Gearboxes",
	sound  = "vehicles/junker/jnk_fourth_cruise_loop2.wav"
}
local fueltank_base = {
	ent    = "acf_fueltank",
	type   = "FuelTanks"
}
local rack_base = {
	ent    = "acf_rack",
	type   = "Racks"
}
local radar_base = {
	ent    = "acf_missileradar",
	type   = "Radars"
}
local trackradar_base = {
	ent    = "ace_trackingradar",
	type   = "Radars"
}
local irst_base = {
	ent    = "ace_irst",
	type   = "Radars"
}

-- add gui stuff to base classes if this is client
if CLIENT then
	gun_base.guicreate           = function( _, Table ) ACFGunGUICreate( Table )		end or nil
	gun_base.guiupdate           = function() return end

	engine_base.guicreate        = function( _, tbl ) ACE_EngineGUI_Update( tbl )		end or nil

	gearbox_base.guicreate       = function( _, tbl ) ACFGearboxGUICreate( tbl )		end or nil
	gearbox_base.guiupdate       = function() return end

	fueltank_base.guicreate      = function( _, tbl ) ACFFuelTankGUICreate( tbl )		end or nil
	fueltank_base.guiupdate      = function( _, tbl ) ACFFuelTankGUIUpdate( tbl )		end or nil

	radar_base.guicreate         = function( _, Table ) ACFRadarGUICreate( Table )	end
	radar_base.guiupdate         = function() return end

	trackradar_base.guicreate    = function( _, Table ) ACFTrackRadarGUICreate( Table )  end or nil
	trackradar_base.guiupdate    = function() return end

	irst_base.guicreate          = function( _, Table ) ACFIRSTGUICreate( Table )		end or nil
	irst_base.guiupdate          = function() return end
end

-- some factory functions for defining ents

--Gun class definition
function ACF_defineGunClass( id, data )
	if (data.year or 0) < ACF.Year then
		data.id = id
		GunClasses[ id ] = data
	end
end

-- Gun definition
function ACF_defineGun( id, data )
	if (data.year or 0) < ACF.Year then
		data.id = id
		data.round.id = id
		table.Inherit( data, gun_base )
		GunTable[ id ] = data
	end
end

-- Rack definition
function ACF_DefineRack( id, data )
	data.id = id
	table.Inherit( data, rack_base )
	RackTable[ id ] = data
end

-- Rack class definition
function ACF_DefineRackClass( id, data )
	data.id = id
	RackClasses[ id ] = data
end

--Engine definition
function ACF_DefineEngine( id, data )
	if (data.year or 0) < ACF.Year then
		local engineData = ACF_CalcEnginePerformanceData(data.torquecurve or ACF.GenericTorqueCurves[data.enginetype], data.torque, data.idlerpm, data.limitrpm)

		data.peaktqrpm    = engineData.peakTqRPM
		data.peakpower    = engineData.peakPower
		data.peakpowerrpm = engineData.peakPowerRPM
		data.peakminrpm   = engineData.powerbandMinRPM
		data.peakmaxrpm   = engineData.powerbandMaxRPM
		data.curvefactor  = (data.limitrpm - data.idlerpm) / data.limitrpm

		data.id = id
		table.Inherit( data, engine_base )
		EngineTable[ id ] = data
		MobilityTable[ id ] = data
	end
end

-- Gearbox definition
function ACF_DefineGearbox( id, data )
	data.id = id
	table.Inherit( data, gearbox_base )
	GearboxTable[ id ] = data
	MobilityTable[ id ] = data
end


-- fueltank definition
function ACF_DefineFuelTank( id, data )
	data.id = id
	table.Inherit( data, fueltank_base )
	FuelTankTable[ id ] = data
	MobilityTable[ id ] = data
end

-- fueltank size definition
function ACF_DefineFuelTankSize( id, data )
	data.id = id
	table.Inherit( data, fueltank_base )
	FuelTankSizeTable[ id ] = data
end


-- Radar definition
function ACF_DefineRadar( id, data )
	data.id = id
	table.Inherit( data, radar_base )
	Radars[ id ] = data
end

-- Radar Class definition
function ACF_DefineRadarClass( id, data )
	data.id = id
	RadarClasses[ id ] = data
end


-- Tracking Radar definition
function ACF_DefineTrackRadar( id, data )
	data.id = id
	table.Inherit( data, trackradar_base )
	Radars[ id ] = data
end

-- Tracking Radar Class definition
function ACF_DefineTrackRadarClass( id, data )
	data.id = id
	RadarClasses[ id ] = data
end


-- Tracking Radar definition
function ACF_DefineIRST( id, data )
	data.id = id
	table.Inherit( data, irst_base )
	Radars[ id ] = data
end

-- Tracking Radar Class definition
function ACF_DefineIRSTClass( id, data )
	data.id = id
	RadarClasses[ id ] = data
end

--Step 2: gather specialized sounds. Normally sounds that have associated sounds into it. Literally using the string path as id.
function ACE_DefineGunFireSound( id, data )
	data.id = id
	GSoundData[id] = data
end

function ACE_DefineModelData( id, data )
	data.id = id
	ModelData[id] = data
end

-- Getters for guidance names, for use in missile definitions.
local function GetAllInTableExcept(tbl, list)

	for k, name in ipairs(list) do
		list[name] = k
		list[k] = nil
	end
	local ret = {}
	for name, _ in pairs(tbl) do
		if not list[name] then
			ret[#ret + 1] = name
		end
	end
	return ret
end

function ACF_GetAllGuidanceNames()

	local ret = {}
	for name, _ in pairs(ACF.Guidance) do
		ret[#ret + 1] = name
	end
	return ret
end

function ACF_GetAllGuidanceNamesExcept(list)
	return GetAllInTableExcept(ACF.Guidance, list)
end

-- Getters for fuse names, for use in missile definitions.
function ACF_GetAllFuseNames()

	local ret = {}
	for name, _ in pairs(ACF.Fuse) do
		ret[#ret + 1] = name
	end
	return ret
end

function ACF_GetAllFuseNamesExcept(list)
	return GetAllInTableExcept(ACF.Fuse, list)
end

-- search for and load a bunch of files or whatever

do

	local Gpath = "acf/shared/"
	local folders = {
		"armor",
		"guns",
		"missiles",
		"radars",
		"ammocrates",
		"engines",
		"gearboxes",
		"guidances",
		"fueltanks",
		"fuses",
		"sounds"
	}

	for _, folder in ipairs(folders) do

		local folderData = file.Find( Gpath .. folder .. "/*.lua", "LUA" )
		for _, v in pairs( folderData ) do
			AddCSLuaFile( "acf/shared/" .. folder .. "/" .. v )
			include( "acf/shared/" .. folder .. "/" .. v )
		end

	end

end

ACF.RoundTypes = list.Get("ACFRoundTypes")
ACF.IdRounds = list.Get("ACFIdRounds")  --Lookup tables so i can get rounds classes from clientside with just an integer

-- now that the tables are populated, throw them in the acf ents list
list.Set( "ACFClasses"  , "GunClass"	, GunClasses	)
list.Set( "ACFClasses"  , "Rack"		, RackClasses	)
list.Set( "ACFClasses"  , "Radar"	, RadarClasses  )

list.Set( "ACFEnts"	, "Guns"		, GunTable	)
list.Set( "ACFEnts"	, "Racks"	, RackTable	)
list.Set( "ACFEnts"	, "Engines"	, EngineTable	)
list.Set( "ACFEnts"	, "Gearboxes"	, GearboxTable  )
list.Set( "ACFEnts"	, "FuelTanks"	, FuelTankTable )
list.Set( "ACFEnts"	, "FuelTanksSize", FuelTankSizeTable )
list.Set( "ACFEnts"	, "Radars"	, Radars		)

list.Set( "ACESounds"	, "GunFire"	, GSoundData	)

--Small remainder of Mobility table. Still being used in stuff like starfall/e2. This can change

list.Set( "ACFEnts"	, "Mobility"		, MobilityTable )

ACF.Weapons       = list.Get("ACFEnts")
ACF.Classes       = list.Get("ACFClasses")
ACF.RoundTypes    = list.Get("ACFRoundTypes")
ACF.IdRounds      = list.Get("ACFIdRounds")	--Lookup tables so i can get rounds classes from clientside with just an integer

ACE.Armors        = list.Get("ACE_MaterialTypes")
ACE.GSounds       = list.Get("ACESounds")
ACE.ModelData     = ModelData
