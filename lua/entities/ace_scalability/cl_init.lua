include("shared.lua")

function ENT:Initialize()

	net.Start("ACE_Scalable_Network")
		net.WriteEntity( self )
	net.SendToServer()

end

function ENT:Draw() 
	
	self:DrawModel()
	
end

--Brought from ACF3. Fixes the physgun grabbing beam glitch
function ENT:CalcAbsolutePosition() -- Faking sync
	local PhysObj  = self:GetPhysicsObject()
	local Position = self:GetPos()
	local Angles   = self:GetAngles()

	if IsValid(PhysObj) then
		PhysObj:SetPos(Position)
		PhysObj:SetAngles(Angles)
		PhysObj:EnableMotion(false) -- Disable prediction
		PhysObj:Sleep()
	end

	return Position, Angles
end

--Creates a temporal physic object for the real build.
local function BuildFakePhysics( entity )

	entity:PhysicsInit(SOLID_VPHYSICS)
    entity:SetMoveType( MOVETYPE_VPHYSICS )       
    entity:SetSolid( SOLID_VPHYSICS )

	local PhysObj = entity:GetPhysicsObject()

	if IsValid(PhysObj) then
		entity.PhysicsObj = PhysObj
		PhysObj:EnableMotion(false)
		PhysObj:Sleep()
	end
end

--Creates the real physic object for the scalable.
local function BuildRealPhysics( entity, Scale )

	local Model 	= entity:GetModel()
	local ModelData = ACE.ModelData
	local Mesh 		= ModelData[Model].CustomMesh or entity.PhysicsObj:GetMeshConvexes()

	if entity.ConvertMeshToScale then
		Mesh = entity:ConvertMeshToScale(Mesh, Scale)
	end

	entity:PhysicsInitMultiConvex(Mesh)
	entity:EnableCustomCollisions(true)
	entity:SetRenderBounds(entity:GetCollisionBounds())
	entity:DrawShadow(false)

	local PhysObj = entity:GetPhysicsObject()

	if IsValid(PhysObj) then
		entity.PhysicsObj = PhysObj
		PhysObj:EnableMotion(false)
		PhysObj:Sleep()
	end
end

net.Receive("ACE_Scalable_Network", function()

	local x = net.ReadFloat() 
	local y = net.ReadFloat() 
	local z = net.ReadFloat() 

	local entity = net.ReadEntity()

	if IsValid(entity) then 

		BuildFakePhysics( entity )

		local Scale = Vector(x,y,z)
		entity.Matrix = Matrix()
		entity.Matrix:Scale(Scale)
		entity:EnableMatrix("RenderMultiply", entity.Matrix)
	
		BuildRealPhysics( entity, Scale )

	end
end)

do -- Dealing with visual clip's bullshit
	local EntMeta = FindMetaTable("Entity")

	function ENT:EnableMatrix(Type, Value, ...)

		if Type == "RenderMultiply" and self.Matrix then
			local Current = self.Matrix:GetScale()
			local Scale   = Value:GetScale()

			-- Visual clip provides a scale of 0, 0, 0
			-- So we just update it with our actual scale
			if Current ~= Scale then
				Value:SetScale(Current)
			end
		end

		return EntMeta.EnableMatrix(self, Type, Value, ...)
	end

	function ENT:DisableMatrix(Type, ...)
		if Type == "RenderMultiply" and self.Matrix then
			-- Visual clip will attempt to disable the matrix
			-- We don't want that to happen with scalable entities
			self:EnableMatrix(Type, self.Matrix)

			return
		end

		return EntMeta.DisableMatrix(self, Type, ...)
	end
end
