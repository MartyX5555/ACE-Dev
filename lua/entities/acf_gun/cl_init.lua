
include("shared.lua")

local ACF_GunInfoWhileSeated = CreateClientConVar("ACF_GunInfoWhileSeated", 0, true, false)

function ENT:Initialize()

	self.BaseClass.Initialize( self )

	self.LastFire	= 0
	self.Reload	= 1
	self.CloseTime  = 1
	self.Rate	= 1
	self.RateScale  = 1
	self.FireAnim	= self:LookupSequence( "shoot" )
	self.CloseAnim  = self:LookupSequence( "load" )
	self.LastThink  = 0
end

-- copied from base_wire_entity: DoNormalDraw's notip arg isn't accessible from ENT:Draw defined there.
function ENT:Draw()

	local lply = LocalPlayer()
	local hideBubble = not ACF_GunInfoWhileSeated:GetBool() and IsValid(lply) and lply:InVehicle()

	self.BaseClass.DoNormalDraw(self, false, hideBubble)
	Wire_Render(self)

	if self.GetBeamLength and (not self.GetShowBeam or self:GetShowBeam()) then
		-- Every SENT that has GetBeamLength should draw a tracer. Some of them have the GetShowBeam boolean
		Wire_DrawTracerBeam( self, 1, self.GetBeamHighlight and self:GetBeamHighlight() or false )
	end

end

function ENT:Think()

	self.BaseClass.Think( self )

	local SinceFire = CurTime() - self.LastFire
	self:SetCycle( SinceFire * self.Rate / self.RateScale )
	if CurTime() > self.LastFire + self.CloseTime and self.CloseAnim then
		self:ResetSequence( self.CloseAnim )
		self:SetCycle( ( SinceFire - self.CloseTime ) * self.Rate / self.RateScale )
		self.Rate = 1 / ( self.Reload - self.CloseTime ) -- Base anim time is 1s, rate is in 1/10 of a second
		self:SetPlaybackRate( self.Rate )
	end

end

function ENT:Animate( _, ReloadTime, LoadOnly )

	if self.CloseAnim and self.CloseAnim > 0 then
		self.CloseTime = math.max(ReloadTime-0.75,ReloadTime * 0.75)
	else
		self.CloseTime = ReloadTime
		self.CloseAnim = nil
	end

	self:ResetSequence( self.FireAnim )
	self:SetCycle( 0 )
	self.RateScale = self:SequenceDuration()
	if LoadOnly then
		self.Rate = 1000000
	else
		self.Rate = 1 / math.Clamp(self.CloseTime,0.1,1.5)	--Base anim time is 1s, rate is in 1/10 of a second
	end
	self:SetPlaybackRate( self.Rate )
	self.LastFire = CurTime()
	self.Reload = ReloadTime

end

function ACFGunGUICreate( Table )

	acfmenupanel:CPanelText("Name", Table.name, "DermaDefaultBold")

	local GunDisplay = acfmenupanel.CData.DisplayModel

	GunDisplay = vgui.Create( "DModelPanel", acfmenupanel.CustomDisplay )
	GunDisplay:SetModel( Table.model )
	GunDisplay:SetCamPos( Vector( 250, 500, 250 ) )
	GunDisplay:SetLookAt( Vector( 0, 0, 0 ) )
	GunDisplay:SetFOV( 20 )
	GunDisplay:SetSize(acfmenupanel:GetWide(),acfmenupanel:GetWide())
	GunDisplay.LayoutEntity = function() end
	acfmenupanel.CustomDisplay:AddItem( GunDisplay )

	local GunClass = list.Get("ACFClasses").GunClass[Table.gunclass]
	acfmenupanel:CPanelText("ClassDesc", GunClass.desc)
	acfmenupanel:CPanelText("GunDesc", Table.desc)
	acfmenupanel:CPanelText("Caliber", "Caliber : " .. (Table.caliber * 10) .. "mm")
	acfmenupanel:CPanelText("Weight", "Weight : " .. Table.weight .. "kg")
	acfmenupanel:CPanelText("Year", "Year : " .. Table.year)

	if Table.rack then
		if Table.seekcone then acfmenupanel:CPanelText("SeekCone", "Seek Cone : " .. Table.seekcone .. " degrees") end
		if Table.viewcone then acfmenupanel:CPanelText("ViewCone", "View Cone : " .. Table.viewcone .. " degrees") end

		if Table.guidelay then acfmenupanel:CPanelText("GuiDelay", "Minimum delay to start maneuvers : " .. Table.guidelay .. " seconds")
		else acfmenupanel:CPanelText("GuiDelay", "With a guidance, this ordnance will start to do maneuvers with no delays") end


		if Table.guidance and #Table.guidance > 0 then

			local guitxt = ""
			for _, guidance in ipairs(Table.guidance) do
				if guidance ~= "Dumb" then
					guitxt = guitxt .. "- " .. guidance .. "\n"
				end
			end

			if guitxt ~= "" then
				acfmenupanel:CPanelText("Guidances", "\nAvailable guidances : \n" .. guitxt )
			end
		end

		if Table.fuses and #Table.fuses > 0 then

			local guitxt = ""
			for _, fuses in ipairs(Table.fuses) do
				guitxt = guitxt .. "- " .. fuses .. "\n"
			end

			acfmenupanel:CPanelText("Fuses", "Available fuses : \n" .. guitxt )
		end

	else
		local RoundVolume = 3.1416 * (Table.caliber / 2) ^ 2 * Table.round.maxlength
		local RoF = 60 / (((RoundVolume / 500 ) ^ 0.60 ) * GunClass.rofmod * (Table.rofmod or 1)) --class and per-gun use same var name
		acfmenupanel:CPanelText("Firerate", "RoF : " .. math.Round(RoF,1) .. " rounds/min")
		if Table.magsize then acfmenupanel:CPanelText("Magazine", "Magazine : " .. Table.magsize .. " rounds\nReload :	" .. Table.magreload .. " s") end
		acfmenupanel:CPanelText("Spread", "Spread : " .. (GunClass.spread * 1.5) .. " degrees")
		acfmenupanel:CPanelText("Spread_Gunner", "Spread with gunner : " .. GunClass.spread .. " degrees")

		--acfmenupanel:CPanelText("GunParentable", "\nThis weapon can be parented.\n", "DermaDefaultBold")
	end

	acfmenupanel.CustomDisplay:PerformLayout()

end
