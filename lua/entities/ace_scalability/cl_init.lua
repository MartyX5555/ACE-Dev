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

net.Receive("ACE_Scalable_Network", function()

	local x = net.ReadFloat() 
	local y = net.ReadFloat() 
	local z = net.ReadFloat() 

	local entity = net.ReadEntity()
	local Scale = Vector(x,y,z)

	BuildFakePhysics( entity )

	local mat = Matrix()
	mat:Scale(Scale)

	entity:EnableMatrix("RenderMultiply", mat)

	local Mesh = ACE.ModelData[entity:GetModel()].CustomMesh or entity.PhysicsObj:GetMeshConvexes()

	Mesh = entity:ConvertMeshToScale(Mesh,Scale)

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