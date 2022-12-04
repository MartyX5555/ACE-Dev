
AddCSLuaFile()

ACF.AmmoBlacklist.Chaff = { "AC", "AL", "C", "HMG", "HW", "MG", "MO", "RAC", "SA", "SC", "SAM", "AAM", "ASM", "BOMB", "FFAR", "UAR", "GBU", "ECM" , "GL", "RM", "AR", "SBC", "ATR", "SL", "ATGM", "ARTY"}

local Round = {}

Round.type  = "Ammo" --Tells the spawn menu what entity to spawn
Round.name  = "[Chaff] - "..ACFTranslation.ShellFLR[1] --Human readable name
Round.model = "models/munitions/round_100mm_shot.mdl" --Shell flight model
Round.desc  = ACFTranslation.ShellFLR[2]
Round.netid = 9 --Unique ammotype ID for network transmission

function Round.create( Gun, BulletData )

    local chaff = ents.Create( "ace_chaff" )
    
    if not IsValid( chaff ) then return end

        chaff:SetPos( BulletData.Pos )
        chaff:SetAngles( BulletData.Flight:Angle() )

        chaff.Heat = (BulletData.FillerMass or 1) * 500
        chaff.Life = (BulletData.FillerMass or 1)

        chaff:Spawn()
        chaff:SetOwner( Gun )

        if CPPI then
            chaff:CPPISetOwner( Gun.Owner)
        end

        chaff.PhysObj = chaff:GetPhysicsObject()
        chaff.PhysObj:SetVelocity( BulletData.Flight )



end

-- Function to convert the player's slider data into the complete round data
function Round.convert( Crate, PlayerData )
    
    local Data          = {}
    local ServerData    = {}
    local GUIData       = {}
    
    PlayerData.PropLength   = PlayerData.PropLength or 0
    PlayerData.ProjLength   = PlayerData.ProjLength or 0
    PlayerData.Data5        = PlayerData.Data5      or 0
    PlayerData.Data10       = PlayerData.Data10     or 0
    
    PlayerData, Data, ServerData, GUIData = ACF_RoundBaseGunpowder( PlayerData, Data, ServerData, GUIData )
    
    --Shell sturdiness calcs
    Data.ProjMass           = math.max(GUIData.ProjVolume-PlayerData.Data5,0)*7.9/1000 + math.min(PlayerData.Data5,GUIData.ProjVolume)*ACF.HEDensity/1000--Volume of the projectile as a cylinder - Volume of the filler * density of steel + Volume of the filler * density of TNT
    Data.MuzzleVel          = ACF_MuzzleVelocity( Data.PropMass, Data.ProjMass, Data.Caliber )

    local Energy            = ACF_Kinetic( Data.MuzzleVel*39.37 , Data.ProjMass, 700 )
    local MaxVol            = ACF_RoundShellCapacity( Energy.Momentum, Data.FrAera, Data.Caliber, Data.ProjLength )

    GUIData.MinFillerVol    = 0
    GUIData.MaxFillerVol    = math.min(GUIData.ProjVolume,MaxVol*0.9)
    GUIData.FillerVol       = math.min(PlayerData.Data5,GUIData.MaxFillerVol)
    Data.FillerMass         = GUIData.FillerVol * ACF.HEDensity/200
    
    Data.ProjMass           = math.max(GUIData.ProjVolume-GUIData.FillerVol,0)*7.9/1000 + Data.FillerMass
    Data.MuzzleVel          = ACF_MuzzleVelocity( Data.PropMass, Data.ProjMass, Data.Caliber )

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

    Crate:SetNWString( "AmmoType", "Chaff" )
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
    
    acfmenupanel:AmmoSelect( ACF.AmmoBlacklist.Chaff )
    
    acfmenupanel:CPanelText("BonusDisplay", "")

    acfmenupanel:CPanelText("Desc", "") --Description (Name, Desc)
    acfmenupanel:CPanelText("LengthDisplay", "")    --Total round length (Name, Desc)
    
    acfmenupanel:AmmoSlider("PropLength",0,0,1000,3, "Propellant Length", "")   --Propellant Length Slider (Name, Value, Min, Max, Decimals, Title, Desc)
    acfmenupanel:AmmoSlider("ProjLength",0,0,1000,3, "Projectile Length", "")   --Projectile Length Slider (Name, Value, Min, Max, Decimals, Title, Desc)
    acfmenupanel:AmmoSlider("FillerVol",0,0,1000,3, "Dual Spectrum Filler", "")--Hollow Point Cavity Slider (Name, Value, Min, Max, Decimals, Title, Desc)
    
    acfmenupanel:CPanelText("VelocityDisplay", "")  --Proj muzzle velocity (Name, Desc)
    acfmenupanel:CPanelText("BurnRateDisplay", "")  --Proj muzzle penetration (Name, Desc)
    acfmenupanel:CPanelText("BurnDurationDisplay", "")  --HE Blast data (Name, Desc)
    
    Round.guiupdate( Panel, Table )
    
end

function Round.guiupdate( Panel, Table )
    
    local PlayerData = {}
        PlayerData.Id           = acfmenupanel.AmmoData.Data.id         --AmmoSelect GUI
        PlayerData.Type         = "Chaff"                                 --Hardcoded, match ACFRoundTypes table index
        PlayerData.PropLength   = acfmenupanel.AmmoData.PropLength      --PropLength slider
        PlayerData.ProjLength   = acfmenupanel.AmmoData.ProjLength      --ProjLength slider
        PlayerData.Data5        = acfmenupanel.AmmoData.FillerVol
        PlayerData.Data10       = acfmenupanel.AmmoData.Tracer and 1 or 0
    
    local Data = Round.convert( Panel, PlayerData )
    
    RunConsoleCommand( "acfmenu_data1", acfmenupanel.AmmoData.Data.id )
    RunConsoleCommand( "acfmenu_data2", PlayerData.Type )
    RunConsoleCommand( "acfmenu_data3", Data.PropLength )       --For Gun ammo, Data3 should always be Propellant
    RunConsoleCommand( "acfmenu_data4", Data.ProjLength )       --And Data4 total round mass
    RunConsoleCommand( "acfmenu_data5", Data.FillerVol )
    RunConsoleCommand( "acfmenu_data10", Data.Tracer )
    
    ---------------------------Ammo Capacity-------------------------------------
    ACE_AmmoCapacityDisplay( Data )
    -------------------------------------------------------------------------------
    acfmenupanel:AmmoSlider("PropLength",Data.PropLength,Data.MinPropLength,Data.MaxTotalLength,3, "Propellant Length", "Propellant Mass : "..(math.floor(Data.PropMass*1000)).." g" )  --Propellant Length Slider (Name, Min, Max, Decimals, Title, Desc)
    acfmenupanel:AmmoSlider("ProjLength",Data.ProjLength,Data.MinProjLength,Data.MaxTotalLength,3, "Projectile Length", "Projectile Mass : "..(math.floor(Data.ProjMass*1000)).." g")   --Projectile Length Slider (Name, Min, Max, Decimals, Title, Desc)
    acfmenupanel:AmmoSlider("FillerVol",Data.FillerVol,Data.MinFillerVol,Data.MaxFillerVol,3, "Dual Spectrum Filler", "Filler Mass : "..(math.floor(Data.FillerMass*1000)).." g")   --HE Filler Slider (Name, Min, Max, Decimals, Title, Desc)

    acfmenupanel:CPanelText("Desc", ACF.RoundTypes[PlayerData.Type].desc)   --Description (Name, Desc)
    acfmenupanel:CPanelText("LengthDisplay", "Round Length : "..(math.floor((Data.PropLength+Data.ProjLength+Data.Tracer)*100)/100).."/"..(Data.MaxTotalLength).." cm") --Total round length (Name, Desc)
    acfmenupanel:CPanelText("VelocityDisplay", "Muzzle Velocity : "..math.floor(Data.MuzzleVel*ACF.VelScale).." m/s")   --Proj muzzle velocity (Name, Desc) 
    
    acfmenupanel:CPanelText("BurnRateDisplay", "Burn Rate : " .. math.Round(Data.BurnRate, 1) .. " kg/s")
    acfmenupanel:CPanelText("BurnDurationDisplay", "Burn Duration : " .. math.Round(Data.BurnTime, 1) .. " s")
    
end

list.Set( "SPECSRoundTypes", "Chaff", Round ) 
list.Set( "ACFRoundTypes", "Chaff", Round )  --Set the round properties
list.Set( "ACFIdRounds", Round.netid, "Chaff" ) --Index must equal the ID entry in the table above, Data must equal the index of the table above

ACF.RoundTypes  = list.Get("ACFRoundTypes")
ACF.IdRounds    = list.Get("ACFIdRounds")