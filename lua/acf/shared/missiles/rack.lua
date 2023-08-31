--define the class
ACF_DefineRackClass("RK", {
	spread         = 1,
	name           = "Munitions Rack",
	desc           = "A lightweight rack for rockets and bombs which is vulnerable to shots and explosions.",
	muzzleflash    = "40mm_muzzleflash_noscale",
	rofmod         = 1,
	reloadmul      = 8,
} )

--add a gun to the class
ACF_DefineRack("1xRK", {
	name = "Single Universal Rack",
	desc = "A lightweight rack for rockets and bombs which is vulnerable to shots and explosions.",
	model	= "models/missiles/rkx1.mdl",
	gunclass = "RK",
	weight = 50,
	rofmod = 2,
	year = 1915,

	mountpoints = {
		missile1 = { pos = Vector(0, 0, 3.8), scaledir = Vector(0, 0, -1)}
	}
} )

--add a gun to the class
ACF_DefineRack("1xRK_small", {
	name = "Single Small Universal Rack",
	desc = "A lightweight rack for a single rocket or bomb which is vulnerable to shots and explosions.",
	model	= "models/missiles/rkx1_sml.mdl",
	gunclass = "RK",
	weight = 50,
	rofmod = 2,
	year = 1915,

	mountpoints = {
		missile1 = { pos = Vector(0, 0, 3.8), scaledir = Vector(0, 0, -1)}
	}
} )

ACF_DefineRack("2xRK", {
	name = "Dual Universal Rack",
	desc = "A lightweight rack for 2 rockets or bombs which is vulnerable to shots and explosions.",
	model	= "models/missiles/rack_double.mdl",
	gunclass = "RK",
	weight = 75,
	year = 1915,

	mountpoints = {
		missile1 = { pos = Vector(4,-12.5,-1.7), scaledir = Vector(0, -1, 0)},
		missile2 = { pos = Vector(4,12.5,-1.7),  scaledir = Vector(0, 1, 0)}
	}
} )

ACF_DefineRack("3xRK", {
	name = "BRU-42 Rack",
	desc = "A lightweight rack for 3 rockets or bombs which is vulnerable to shots and explosions.",
	model	= "models/missiles/bomb_3xrk.mdl",
	gunclass = "RK",
	weight = 100,
	year = 1936,

	magsize = 3,

	mountpoints = {
		missile1 = { pos = Vector(1.9,0,-7.5),	scaledir = Vector(0,0,-1)},
		missile2 = { pos = Vector(2.3,3,-2),	scaledir = Vector(-1,1,0)},
		missile3 = { pos = Vector(2.3,-3,-2),	scaledir = Vector(-1,-1,0)},
	}
} )

ACF_DefineRack("4xRK", {
	name = "Quad Universal Rack",
	desc = "A lightweight rack for 4 rockets or bombs which is vulnerable to shots and explosions.",
	model	= "models/missiles/rack_quad.mdl",
	gunclass = "RK",
	weight = 125,
	year = 1936,

	mountpoints =
	{
		missile1 = { pos = Vector(0,12.5,9), scaledir = Vector(0,1,0)},
		missile2 = { pos = Vector(0,-12.5,9), scaledir = Vector(0,-1,0)},
		missile3 = { pos = Vector(0,-12.5,-5), scaledir = Vector(0,0,-1)},
		missile4 = { pos = Vector(0,12.5,-5), scaledir = Vector(0,0,-1)}
	}
} )

ACF_DefineRack("2x AGM-114", {
	name = "Dual AGM-114 Rack",
	desc = "An AGM-114 rack designed to carry 2 missiles.",
	model	= "models/missiles/agm_114_2xrk.mdl",
	gunclass = "RK",
	weight = 50,
	year = 1984,
	caliber = 16,

	mountpoints =
	{
		missile1 = { pos = Vector(0,-7.9,5.5), scaledir = Vector(0,0,-1)},
		missile2 = { pos = Vector(0,7.9,5.5), scaledir = Vector(0,0,-1)},
	}
} )

ACF_DefineRack("4x AGM-114", {
	name = "Quad AGM-114 Rack",
	desc = "An AGM-114 rack designed to carry 4 missiles.",
	model	= "models/missiles/agm_114_4xrk.mdl",
	gunclass = "RK",
	weight = 100,
	year = 1984,
	caliber = 16,

	mountpoints =
	{
		missile1 = { pos = Vector(0,-7.9,5.5), scaledir = Vector(0,0,-1)},
		missile2 = { pos = Vector(0,7.9,5.5), scaledir = Vector(0,0,-1)},
		missile3 = { pos = Vector(0,-7.9,-12.2), scaledir = Vector(0,0,-1)},
		missile4 = { pos = Vector(0,7.9,-12.2), scaledir = Vector(0,0,-1)}
	}
} )

ACF_DefineRack("1xAT3RK", {
	name = "Single AT-3 Missile Rack",
	desc = "An AT-3 anti tank missile handheld rack",
	model	= "models/missiles/at3rk.mdl",
	gunclass = "RK",
	weight = 30,
	rofmod = 1.4,
	year = 1969,

	mountpoints =
	{
		missile1 = { pos = Vector(3.2,0,3.4), scaledir = Vector(0, 0, -1)}
	}
} )

ACF_DefineRack("1xAT3RKS", {
	name = "Single AT-3 Missile Rack designed for AFV",
	desc = "An AT-3 anti tank missile handheld rack",
	model	= "models/missiles/at3rs.mdl",
	gunclass = "RK",
	weight = 40,
	rofmod = 1,
	year = 1972,

	mountpoints =
	{
		missile1 = { pos = Vector(21,0,8.6), scaledir = Vector(0, 0, -1) }
	}
} )
