local modPath = '/mods/idleEngineers/'
local addListener = import(modPath .. 'modules/init.lua').addListener
local getUnits = import(modPath .. 'modules/units.lua').getUnits
--local unitData = import(modPath ..'modules/units.lua').unitData

local LayoutHelpers = import('/lua/maui/layouthelpers.lua')
local Bitmap = import('/lua/maui/bitmap.lua').Bitmap
local ItemList = import('/lua/maui/itemlist.lua').ItemList
local Group = import('/lua/maui/group.lua').Group
local UIUtil = import('/lua/ui/uiutil.lua')

local overlays = {}

function CreateOverlay(unit)
	local overlay = Bitmap(GetFrame(0))
	local id = unit:GetEntityId()
	
	--print "creating overlay"

	overlay:SetSolidColor('black')
	overlay.Width:Set(10)
	overlay.Height:Set(10)
	
	overlay:SetNeedsFrameUpdate(true)
	overlay.OnFrame = function(self, delta)
		if(not unit:IsDead()) then
			local worldView = import('/lua/ui/game/worldview.lua').viewLeft
			local pos = worldView:Project(unit:GetPosition())
			LayoutHelpers.AtLeftTopIn(overlay, worldView, pos.x - overlay.Width() / 2, pos.y - overlay.Height() / 2 + 1)
		else
			overlay.destroy = true
			overlay:Hide()
		end
	end
		
	overlay.id = unit:GetEntityId()
	overlay.destroy = false
	overlay.text = UIUtil.CreateText(overlay, '0', 10, UIUtil.bodyFont)
	overlay.text:SetColor('green')
	overlay.text:SetDropShadow(true)
	LayoutHelpers.AtCenterIn(overlay.text, overlay, 0, 0)

	return overlay
end

function UpdateOverlay(e)
	local id = e:GetEntityId()
--	local data = unitData(e)
	local tech = 0
	local color = 'green'
	
	if e:IsIdle() then
		--print "is idle"
		if(not overlays[id] and e:IsIdle()) then
			overlays[id] = CreateOverlay(e)
		end
		overlays[id].text:SetColor('red')
		overlays[id].text:SetText("E")
	else
		if (overlays[id]) then
			--print "Bye bye overlay"
			overlays[id].destroy = true
			overlays[id]:Hide()
		end
	end
end

function engineerOverlay()
	--print "Hello"
	local engineers = EntityCategoryFilterDown(categories.ENGINEER, getUnits())
	for _, e in engineers do
		--print "Whats up doc!"
		--LOG("e", repr(e))
		if not e:IsDead() then
			UpdateOverlay(e)
		end
	end
	for id, overlay in overlays do
		if(not overlay or overlay.destroy) then
			--print "Bye bye overlay 2"
			overlay:Destroy()
			overlays[id] = nil
		end
	end
end

function init(isReplay, parent)
	addListener(engineerOverlay, 1)
end
