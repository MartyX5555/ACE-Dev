include("shared.lua")

function ENT:Initialize()
	self.SpawnTime = CurTime()
end

function ENT:Draw()
	self:DrawModel()

	if CurTime() - self.SpawnTime < 2.5 then
		return
	end

	local ent = self

	local startpos = self:LocalToWorld(Vector(-2.25, 1.4, 0))
	local dir = ent:GetUp()
	local len = 300

	local tr = util.TraceLine( {
		start = startpos,
		endpos = startpos + dir * len,
		filter = ent
	} )

	render.DrawLine( startpos, tr.HitPos, Color( 130, 0, 0, 25), true )
end