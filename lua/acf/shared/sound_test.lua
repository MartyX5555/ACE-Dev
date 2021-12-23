--Table Main concept. function for all sounds needs to be function ACE_Sound(HitPos ,Energy ,HitWorld ,HitWater, Type). This will cover:
	--Explosions
	--Penetrations
	--Ricochets
	--Impacts (if added)
--Where:
	--Hitpos: The pos where effect was created
	--Energy: Common value to be used to calculate pitch/volume. Each effect has different values to calculate this
	--HitWorld: Boolean if the effect hit world
	--HitWater: Boolean if the effect hit water
	--Type: Type of effect. Here will define if its a blast, penetration, etc....
--Due to different values, a GunFire sound function will be required by separated, as caliber is required there.
	--Rack Missile need this another function too. Since they are weapons as guns
--This concept must be stored in the same way as rest of shared files if used manually. Otherwise, using a file discovery system is better


--Blasts. This will store all sounds related to blasts, includes underwater sounds
ACE.Sounds.Blasts = {
	tiny = {
		close = {},
		mid = {},
		far = {}		
	},
	small = {
		close = {},
		mid = {},
		far = {}		
	},
	medium = {
		close = {},
		mid = {},
		far = {}		
	},
	large = {
		close = {},
		mid = {},
		far = {}		
	},
	underwater = {
		close = {}
	}
}

-- Debris. They will not follow the main concept, but this will be called alongside blasts, so doesnt conflict with the main one
ACE.Sounds.Debris = {
	low = {

	},
	high = {

	}
}

--Penetrations. Note that it has underwater table as blast one.
ACE.Sounds.Penetrations = {
	tiny = {
		close = {}
	},
	small = {
		close = {}
	},
	medium = {
		close = {}	
	},
	large = {
		close = {}
	},
	underwater = {
		close = {}
	}
}

--Ricochets. Same format than pen table
ACE.Sounds.Ricochets = {
	tiny = {
		close = {}	
	},
	small = {
		close = {}		
	},
	medium = {
		close = {}
	},
	large = {
		close = {}
	},
	underwater = {
		close = {}
	}
}

--Cracks. Same format atm
ACE.Sounds.Cracks = {
	tiny = {
		close = {}		
	},
	small = {
		close = {}		
	},
	medium = {
		close = {}
	},
	large = {
		close = {}
	},
	underwater = {
		close = {}
	}
}