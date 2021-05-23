--Every funciton will return Heat. The only difference is how the Heat is created from

-----------------------------------[ HEAT PARAMETERS ]-----------------------------------


------Ambient Temperature. Engine Heat will not be lower than this. In Celcius.	
    ACE.AmbientTemp = 20  

------How much the distance affects Heat detection for IR seeker? Higher => Less Heat detected at distant targets - Def: 1
	ACE.HeatDistanceLoss = 0.5
	
--///////////////////////////////////////////////////////////////////////////////////////
--///////////////////////////////////////////////////////////////////////////////////////
--///////////////////////////////////FUNCTIONS BELOW/////////////////////////////////////
--///////////////////////////////////////////////////////////////////////////////////////

--[[-------------------------------------------------------------------------------------
    ACE_InfraredHeatFromProp( self, Target , dist )  --used mostly by infrared guidance
	
->	Input information:
	
	guidance - infrared guidance
	Target - Ent Target to track Heat
	dist - distance between the missile and the Target
	
]]---------------------------------------------------------------------------------------
function ACE_InfraredHeatFromProp( guidance, Target , dist ) 
    
	local Speed = Target:GetVelocity():Length()
    --local Heat = (  guidance.SeekSensitivity * ( Speed / dist * 0.001 / ACE.HeatDistanceLoss )  )  + ACE.AmbientTemp
	
	local Heat =  (( guidance.SeekSensitivity * Speed ) / dist*1000 / ACE.HeatDistanceLoss ) + ACE.AmbientTemp
	print(') Heat: '..Heat)

    return Heat
	
end

--[[-------------------------------------------------------------------------------------
    ACE_HeatFromGun( Gun, Heat, DeltaTime )  --used by Guns
	
->	Input information:
	
	Gun - The Gun Entity
	Heat - Current Heat of this gun
	DeltaTime - Delta time of this gun
	
]]---------------------------------------------------------------------------------------
function ACE_HeatFromGun( Gun , Heat, DeltaTime )

    local phys = Gun:GetPhysicsObject()
	local Mass = phys:GetMass()
	
	local Energyloss = ((42500*(-Heat))) * (1+(Mass^0.5)*2/75) * DeltaTime * 0.03	
    Heat = math.max(Heat +(Energyloss/(Mass^0.5)*2/743.2),0)

    return Heat
end

--[[-------------------------------------------------------------------------------------
    ACE_HeatFromEngine( Engine , Radiator )  --used mostly by engines
	
->	Input information:
	
    Engine - The Engine Entity
	Radiator - The Radiator Entity -> no required yet
	
]]---------------------------------------------------------------------------------------
function ACE_HeatFromEngine( Engine , Radiator )  --radiator?!? woooo
	
	local RPM  = 0
	
	if Engine.Active then
	    RPM = Engine.FlyRPM 
	end
	local Heat = 0.01 * RPM / 2500
	
	
	Engine.Heat = Engine.Heat + Heat * RPM * 0.01

-----------------------------------------------------------------------------------------
	--These parts need rewrite, since we dont have radiators yet
	local Phys = Engine:GetPhysicsObject()
	
	local Area = Phys:GetVolume()*2--3452*2 --+ 10000  --engine + radiator
    local Volume = Phys:GetVolume()*2 --+ 7000 --engine + radiator
	
	local Mul = Area / Volume 
-----------------------------------------------------------------------------------------
	
	local Diff = Engine.Heat - ACE.AmbientTemp
	
	Engine.Heat = Engine.Heat - Diff * Mul * 0.0025
	
    return Engine.Heat
	
end

--[[-------------------------------------------------------------------------------------
    ACE_HeatFromGearbox( Gearbox )  --used mostly by gearboxes
	
->	Input information:
	
    Gearbox - The Gearbox Entity
	
]]---------------------------------------------------------------------------------------
function ACE_HeatFromGearbox( Gearbox )


end