AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")
--[[
function ENT:Initialize()

    --Use the half value of the final scale lenght. To define the real lenght in the final result 
    --XYZ scale config should depend on what entity we are scaling, since ammos should scale as shown below, guns by caliber, fuels in the same way as ammo, etc...

    local Mode = math.random(1,2)

    local XScale
    local YScale
    local ZScale

    local DefaultSize
    local ModelPath

    local EntityScale

    local id

    if Mode == 1 then -- This will be used by ammocrates and fueltanks

        id = "models/holograms/rcube_thin.mdl" --This will be given depending on the entity class

        XScale = math.random(10,100)
        YScale = math.random(10,100)
        ZScale = math.random(10,100)
    
        DefaultSize = ACE.ModelData[id].DefaultSize
        EntityScale = Vector(XScale / DefaultSize, YScale / DefaultSize, ZScale / DefaultSize) 

        self:SetMaterial("models/props_pipes/GutterMetal01a")

    elseif Mode == 2 then -- Adjust size by caliber.

        id = "models/tankgun/tankgun_100mm.mdl" --This will be given depending on the entity class

        local Caliber = 37--math.random(37,170)

        DefaultSize = ACE.ModelData[id].DefaultSize
        EntityScale = Vector(Caliber / DefaultSize, Caliber / DefaultSize, Caliber / DefaultSize) 

    end

    ModelPath   = ACE.ModelData[id].Model

    self:SetModel( ModelPath ) --Make it compatible with ACF-3
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType( MOVETYPE_VPHYSICS )       
    self:SetSolid( SOLID_VPHYSICS )

    self.PhysicsObj = self:GetPhysicsObject()
    self.IsScalable = true

    do

        local Phys = self.PhysicsObj

        if IsValid(Phys) then
            Phys:Wake()
            Phys:SetMass(1000)

            local Mesh = ACE.ModelData[id].CustomMesh or Phys:GetMeshConvexes()

            self.ScaleData = {
                Mesh = Mesh,
                Scale = EntityScale,
                Size = DefaultSize
            }

            self:ACE_SetScale( self.ScaleData )

        end 
    end
end
]]
do

    local function NetworkNewScale( Ent, Scale )

        net.Start("ACE_Scalable_Network")
            net.WriteFloat(Scale.x)
            net.WriteFloat(Scale.y)
            net.WriteFloat(Scale.z)
            net.WriteEntity( Ent )
        net.Broadcast()

    end

    function ENT:ACE_SetScale( ScaleData )

        local MeshData = ScaleData.Mesh
        local Scale = ScaleData.Scale
        local Size = ScaleData.Size

        MeshData = self:ConvertMeshToScale( MeshData, Scale )

        self:PhysicsInitMultiConvex( MeshData )
		self:SetMoveType(MOVETYPE_VPHYSICS)
		self:SetSolid(SOLID_VPHYSICS)
		self:EnableCustomCollisions(true)
		self:DrawShadow(false)

        self.PhysicsObj = self:GetPhysicsObject()

        local Phys = self.PhysicsObj
        if IsValid(Phys) then
            Phys:Wake()
            Phys:SetMass(1000)
        end 

       --NetworkNewScale( self, Scale )

    end

    net.Receive("ACE_Scalable_Network", function()

        print("Sending Size to client...")

        local Ent = net.ReadEntity()

        if not IsValid(Ent) then return end
        if not Ent.IsScalable then return end

        local ScaleData = Ent.ScaleData 
        
        NetworkNewScale( Ent, ScaleData.Scale )

    end)

end


