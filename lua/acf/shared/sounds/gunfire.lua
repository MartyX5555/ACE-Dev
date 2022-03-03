--Little desc for every value here:

--ACE_DefineGunFireSound( id, data )

--id: this will be the sound patch which this content is associated to. Make sure that every id is unique so we dont have colliding data
--data: here we will have 3 tables, which each one will edit the sounds to be played PER distance. So we will have main sounds (those you hear normally when standing close to the gun), mid sounds and far sounds.
--Each table contains this same structure:
----Volume (0-1): Adjust the volume of this section. This applies to all sounds for this section and always consider to amplify sounds via programs if they are too quiet as this will not solve that entirely.
----Pitch (0-255): You can set the desired Pitch for the sounds of this section. Leave as 100 if you dont want to mess with it, but if you want more control over your sounds.... use it.
----Package (table): This is the area where you insert your sounds. Flood this table to your liking as long as you put their paths correctly. The gun will switch between these sounds when being used. Recommended to put the id here too.
----NOTE about Package: sounds are played IN order according to the table. So if you want that x sound is played before another, put that first sound first in the list (from above)

--These sound packages will work for both sounds placed via sound replacer or generic ones, so feel free to create your own scripted sounds. Only works with GUNs.

--Generic Rifled cannon gunfire
ACE_DefineGunFireSound( "weapons/acf_gun/cannon_new.wav", 
	{
		main = {
			Volume 	= 1,
			Pitch 	= 100,
			Package = {
				"weapons/acf_gun/cannon_new.wav"			
			}
		},
		mid = {
			Volume 	= 100,
			Pitch 	= 100,
			Package = {
				"acf_other/gunfire/cannon/cannon_mid_far1.wav",
				"acf_other/gunfire/cannon/cannon_mid_far2.wav",
				"acf_other/gunfire/cannon/cannon_mid_far3.wav",
				"acf_other/gunfire/cannon/cannon_mid_far4.wav"		
			}

		},
		far = {
			Volume 	= 100,
			Pitch 	= 100,
			Package = {
				"acf_other/gunfire/cannon/cannon_mid_far1.wav",
				"acf_other/gunfire/cannon/cannon_mid_far2.wav",
				"acf_other/gunfire/cannon/cannon_mid_far3.wav",
				"acf_other/gunfire/cannon/cannon_mid_far4.wav"			
			}
		}
	}
 )

--Generic Smoothbore cannon gunfire
ACE_DefineGunFireSound( "acf_extra/ace/weapons/cannon/125mm_1.wav", 
	{
		main = {
			Volume 	= 1,
			Pitch 	= 100,
			Package = {
				"acf_extra/ace/weapons/cannon/125mm_1.wav",
				"acf_extra/ace/weapons/cannon/125mm_2.wav",
				"acf_extra/ace/weapons/cannon/125mm_3.wav"			
			}
		},
		mid = {
			Volume 	= 100,
			Pitch 	= 100,
			Package = {
				"acf_other/gunfire/cannon/cannon_mid_far1.wav",
				"acf_other/gunfire/cannon/cannon_mid_far2.wav",
				"acf_other/gunfire/cannon/cannon_mid_far3.wav",
				"acf_other/gunfire/cannon/cannon_mid_far4.wav"		
			}

		},
		far = {
			Volume 	= 100,
			Pitch 	= 100,
			Package = {
				"acf_other/gunfire/cannon/cannon_mid_far1.wav",
				"acf_other/gunfire/cannon/cannon_mid_far2.wav",
				"acf_other/gunfire/cannon/cannon_mid_far3.wav",
				"acf_other/gunfire/cannon/cannon_mid_far4.wav"			
			}
		}
	}
 )

--Generic Autoloader gunfire
ACE_DefineGunFireSound( "weapons/acf_gun/autoloader.wav", 
	{
		main = {
			Volume 	= 1,
			Pitch 	= 100,
			Package = {
				"weapons/acf_gun/autoloader.wav"			
			}
		},
		mid = {
			Volume 	= 100,
			Pitch 	= 100,
			Package = {
				"acf_other/gunfire/cannon/cannon_mid_far1.wav",
				"acf_other/gunfire/cannon/cannon_mid_far2.wav",
				"acf_other/gunfire/cannon/cannon_mid_far3.wav",
				"acf_other/gunfire/cannon/cannon_mid_far4.wav"		
			}

		},
		far = {
			Volume 	= 100,
			Pitch 	= 100,
			Package = {
				"acf_other/gunfire/cannon/cannon_mid_far1.wav",
				"acf_other/gunfire/cannon/cannon_mid_far2.wav",
				"acf_other/gunfire/cannon/cannon_mid_far3.wav",
				"acf_other/gunfire/cannon/cannon_mid_far4.wav"			
			}
		}
	}
 )

--Generic Howitzer gunfire
ACE_DefineGunFireSound( "weapons/acf_gun/howitzer_new2.wav", 
	{
		main = {
			Volume 	= 1,
			Pitch 	= 100,
			Package = {
				"weapons/acf_gun/howitzer_new2.wav"			
			}

		},
		mid = {
			Volume 	= 100,
			Pitch 	= 100,
			Package = {
				"acf_other/gunfire/cannon/cannon_mid_far1.wav",
				"acf_other/gunfire/cannon/cannon_mid_far2.wav",
				"acf_other/gunfire/cannon/cannon_mid_far3.wav",
				"acf_other/gunfire/cannon/cannon_mid_far4.wav"			
			}

		},
		far = {
			Volume 	= 100,
			Pitch 	= 100,
			Package = {
				"acf_other/gunfire/cannon/cannon_mid_far1.wav",
				"acf_other/gunfire/cannon/cannon_mid_far2.wav",
				"acf_other/gunfire/cannon/cannon_mid_far3.wav",
				"acf_other/gunfire/cannon/cannon_mid_far4.wav"			
			}
		}
	}
 )

--Generic Mortar gunfire. Ik its empty, the structure is here just to avoid recreate it in the future.
ACE_DefineGunFireSound( "weapons/ACF_Gun/mortar_new.wav", 
	{
		main = {
			Volume 	= 1,
			Pitch 	= 100,
			Package = {
				"weapons/ACF_Gun/mortar_new.wav"			
			}
		},
		mid = {
			Volume 	= 1,
			Pitch 	= 100,
			Package = {
				"weapons/ACF_Gun/mortar_new.wav"	
			}

		},
		far = {
			Volume 	= 1,
			Pitch 	= 100,
			Package = {
				"weapons/ACF_Gun/mortar_new.wav"		
			}
		}
	}
 )

--Generic AT Rifle gunfire
ACE_DefineGunFireSound( "acf_extra/tankfx/gnomefather/7mm1.wav", 
	{
		main = {
			Volume 	= 1,
			Pitch 	= 100,
			Package = {
				"acf_extra/tankfx/gnomefather/7mm1.wav"			
			}
		},
		mid = {
			Volume 	= 100,
			Pitch 	= 100,
			Package = {
				"acf_other/gunfire/autocannon/autocannon_mid_far1.wav",
				"acf_other/gunfire/autocannon/autocannon_mid_far2.wav",
				"acf_other/gunfire/autocannon/autocannon_mid_far3.wav",
				"acf_other/gunfire/autocannon/autocannon_mid_far4.wav"		
			}

		},
		far = {
			Volume 	= 100,
			Pitch 	= 100,
			Package = {
				"acf_other/gunfire/autocannon/autocannon_mid_far1.wav",
				"acf_other/gunfire/autocannon/autocannon_mid_far2.wav",
				"acf_other/gunfire/autocannon/autocannon_mid_far3.wav",
				"acf_other/gunfire/autocannon/autocannon_mid_far4.wav"			
			}
		}
	}
 )

--Generic Autocannon gunfire
ACE_DefineGunFireSound( "weapons/acf_gun/ac_fire4.wav", 
	{
		main = {
			Volume 	= 1,
			Pitch 	= 100,
			Package = {
				"weapons/acf_gun/ac_fire4.wav"			
			}

		},
		mid = {
			Volume 	= 100,
			Pitch 	= 100,
			Package = {
				"acf_other/gunfire/cannon/cannon_mid_far1.wav",
				"acf_other/gunfire/cannon/cannon_mid_far2.wav",
				"acf_other/gunfire/cannon/cannon_mid_far3.wav",
				"acf_other/gunfire/cannon/cannon_mid_far4.wav"			
			}
		},
		far = {
			Volume 	= 100,
			Pitch 	= 100,
			Package = {
				"acf_other/gunfire/cannon/cannon_mid_far1.wav",
				"acf_other/gunfire/cannon/cannon_mid_far2.wav",
				"acf_other/gunfire/cannon/cannon_mid_far3.wav",
				"acf_other/gunfire/cannon/cannon_mid_far4.wav"			
			}
		}
	}
 )

--Generic Semi-Autocannon gunfire
ACE_DefineGunFireSound( "acf_extra/tankfx/gnomefather/25mm1.wav", 
	{
		main = {
			Volume 	= 1,
			Pitch 	= 100,
			Package = {
				"acf_extra/tankfx/gnomefather/25mm1.wav"		
			}

		},
		mid = {
			Volume 	= 100,
			Pitch 	= 100,
			Package = {
				"acf_other/gunfire/cannon/cannon_mid_far1.wav",
				"acf_other/gunfire/cannon/cannon_mid_far2.wav",
				"acf_other/gunfire/cannon/cannon_mid_far3.wav",
				"acf_other/gunfire/cannon/cannon_mid_far4.wav"			
			}
		},
		far = {
			Volume 	= 100,
			Pitch 	= 100,
			Package = {
				"acf_other/gunfire/cannon/cannon_mid_far1.wav",
				"acf_other/gunfire/cannon/cannon_mid_far2.wav",
				"acf_other/gunfire/cannon/cannon_mid_far3.wav",
				"acf_other/gunfire/cannon/cannon_mid_far4.wav"			
			}
		}
	}
 )

--generic rotary autocannon gunfire
ACE_DefineGunFireSound( "weapons/acf_gun/mg_fire2.wav", 
	{
		main = {
			Volume 	= 0.9,
			Pitch 	= 90,
			Package = {
				"weapons/acf_gun/mg_fire2.wav"			
			}
		},
		mid = {
			Volume 	= 2,
			Pitch 	= 100,
			Package = {
				"acf_other/gunfire/rotaryautocannon/rac_mid_far1.wav",
				"acf_other/gunfire/rotaryautocannon/rac_mid_far2.wav",
				"acf_other/gunfire/rotaryautocannon/rac_mid_far3.wav",
				"acf_other/gunfire/rotaryautocannon/rac_mid_far4.wav"		
			}

		},
		far = {
			Volume 	= 2,
			Pitch 	= 100,
			Package = {
				"acf_other/gunfire/rotaryautocannon/rac_mid_far1.wav",
				"acf_other/gunfire/rotaryautocannon/rac_mid_far2.wav",
				"acf_other/gunfire/rotaryautocannon/rac_mid_far3.wav",
				"acf_other/gunfire/rotaryautocannon/rac_mid_far4.wav"			
			}
		}
	}
 )

--generic heavy machinegun gunfire
ACE_DefineGunFireSound( "weapons/acf_gun/mg_fire3.wav", 
	{
		main = {
			Volume 	= 1,
			Pitch 	= 100,
			Package = {
				"weapons/acf_gun/mg_fire3.wav"			
			}
		},
		mid = {
			Volume 	= 1.75,
			Pitch 	= 100,
			Package = {
				"acf_other/gunfire/rotaryautocannon/rac_mid_far1.wav",
				"acf_other/gunfire/rotaryautocannon/rac_mid_far2.wav",
				"acf_other/gunfire/rotaryautocannon/rac_mid_far3.wav",
				"acf_other/gunfire/rotaryautocannon/rac_mid_far4.wav"		
			}

		},
		far = {
			Volume 	= 2,
			Pitch 	= 100,
			Package = {
				"acf_other/gunfire/rotaryautocannon/rac_mid_far1.wav",
				"acf_other/gunfire/rotaryautocannon/rac_mid_far2.wav",
				"acf_other/gunfire/rotaryautocannon/rac_mid_far3.wav",
				"acf_other/gunfire/rotaryautocannon/rac_mid_far4.wav"			
			}
		}
	}
 )

--Generic Machinegun gunfire
ACE_DefineGunFireSound( "weapons/ACF_Gun/mg_fire4.wav", 
	{
		main = {
			Volume 	= 1,
			Pitch 	= 100,
			Package = {
				"weapons/ACF_Gun/mg_fire4.wav"			
			}
		},
		mid = {
			Volume 	= 1.5,
			Pitch 	= 100,
			Package = {
				"acf_other/gunfire/machinegun/machinegun_mid1.wav",
				"acf_other/gunfire/machinegun/machinegun_mid2.wav",
				"acf_other/gunfire/machinegun/machinegun_mid3.wav",
				"acf_other/gunfire/machinegun/machinegun_mid4.wav"		
			}

		},
		far = {
			Volume 	= 1.5,
			Pitch 	= 100,
			Package = {
				"acf_other/gunfire/machinegun/machinegun_far1.wav",
				"acf_other/gunfire/machinegun/machinegun_far2.wav",
				"acf_other/gunfire/machinegun/machinegun_far3.wav",
				"acf_other/gunfire/machinegun/machinegun_far4.wav"			
			}
		}
	}
 )

--Generic GL gunfire
ACE_DefineGunFireSound( "weapons/acf_gun/grenadelauncher.wav", 
	{
		main = {
			Volume 	= 1,
			Pitch 	= 100,
			Package = {
				"weapons/acf_gun/grenadelauncher.wav"			
			}
		},
		mid = {
			Volume 	= 0.5,
			Pitch 	= 100,
			Package = {
				"weapons/acf_gun/grenadelauncher.wav"		
			}

		},
		far = {
			Volume 	= 0.5,
			Pitch 	= 100,
			Package = {
				"weapons/acf_gun/grenadelauncher.wav"		
			}
		}
	}
 )

--Generic SL gunfire
ACE_DefineGunFireSound( "weapons/acf_gun/smoke_launch.wav", 
	{
		main = {
			Volume 	= 1,
			Pitch 	= 100,
			Package = {
				"weapons/acf_gun/smoke_launch.wav"			
			}
		},
		mid = {
			Volume 	= 0.1,
			Pitch 	= 100,
			Package = {
				"weapons/acf_gun/smoke_launch.wav"		
			}

		},
		far = {
			Volume 	= 0.1,
			Pitch 	= 100,
			Package = {
				"weapons/acf_gun/smoke_launch.wav"		
			}
		}
	}
 )

--Generic FGL gunfire
ACE_DefineGunFireSound( "acf_extra/tankfx/flare_launch.wav", 
	{
		main = {
			Volume 	= 1,
			Pitch 	= 100,
			Package = {
				"acf_extra/tankfx/flare_launch.wav"			
			}
		},
		mid = {
			Volume 	= 0.1,
			Pitch 	= 100,
			Package = {
				"acf_extra/tankfx/flare_launch.wav"		
			}

		},
		far = {
			Volume 	= 0.1,
			Pitch 	= 100,
			Package = {
				"acf_extra/tankfx/flare_launch.wav"		
			}
		}
	}
 )


--[[
--Test sound definition. Meant to see if the core works as intended.
ACE_DefineGunFireSound( "physics/metal/bts5_panels_impact_lg_01.wav", 
	{
		main = {
			Volume 	= 1,
			Pitch 	= 100,
			Package = {
				"physics/metal/bts5_panels_impact_lg_01.wav",
				"physics/metal/bts5_panels_impact_lg_02.wav",
				"physics/metal/bts5_panels_impact_lg_03.wav",
				"physics/metal/bts5_panels_impact_lg_04.wav",
				"physics/metal/bts5_panels_impact_lg_05.wav",
				"physics/metal/bts5_panels_impact_lg_06.wav",
				"physics/metal/bts5_panels_impact_lg_07.wav",
				"physics/metal/bts5_panels_impact_lg_08.wav",
				"physics/metal/bts5_panels_impact_lg_09.wav"			
			}
		},
		mid = {
			Volume 	= 1,
			Pitch 	= 50,
			Package = {
				"physics/metal/bts5_panels_impact_lg_01.wav",
				"physics/metal/bts5_panels_impact_lg_02.wav",
				"physics/metal/bts5_panels_impact_lg_03.wav",
				"physics/metal/bts5_panels_impact_lg_04.wav",
				"physics/metal/bts5_panels_impact_lg_05.wav",
				"physics/metal/bts5_panels_impact_lg_06.wav",
				"physics/metal/bts5_panels_impact_lg_07.wav",
				"physics/metal/bts5_panels_impact_lg_08.wav",
				"physics/metal/bts5_panels_impact_lg_09.wav"		
			}

		},
		far = {
			Volume 	= 1,
			Pitch 	= 25,
			Package = {
				"physics/metal/bts5_panels_impact_lg_01.wav",
				"physics/metal/bts5_panels_impact_lg_02.wav",
				"physics/metal/bts5_panels_impact_lg_03.wav",
				"physics/metal/bts5_panels_impact_lg_04.wav",
				"physics/metal/bts5_panels_impact_lg_05.wav",
				"physics/metal/bts5_panels_impact_lg_06.wav",
				"physics/metal/bts5_panels_impact_lg_07.wav",
				"physics/metal/bts5_panels_impact_lg_08.wav",
				"physics/metal/bts5_panels_impact_lg_09.wav"	
			}
		}
	}
 )
 ]]