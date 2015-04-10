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

function CreateSubOverlay(overlay, w, h, x, y)
	local overlay2 = Bitmap(overlay)
	overlay2:SetSolidColor('red')
	overlay2.Width:Set(w)
	overlay2.Height:Set(h)
	LayoutHelpers.AtLeftTopIn(overlay2, overlay, x, y)
end


function CreateOverlay(unit)
	local overlay = Bitmap(GetFrame(0))
	local id = unit:GetEntityId()
	
	--print "creating overlay"

	overlay:SetSolidColor('magenta')
	
	local w = 5
	local h = 1
	local t =2
	 
	if not unit:IsInCategory("FACTORY") then 
		--w = 20
		--h = 20
	end
	if unit:IsInCategory("TECH2") then h = 3 end
	if unit:IsInCategory("TECH3") then h = 6 end
	
	overlay.Width:Set(w)
	overlay.Height:Set(h)

	--CreateSubOverlay(overlay, w, t, 0, h-5)
	--CreateSubOverlay(overlay, w, t, 0, 0)
	--CreateSubOverlay(overlay, w, t, 0, h)
	--CreateSubOverlay(overlay, t, h, 0, 0)
	--CreateSubOverlay(overlay, t, h+t, w, 0)
	
	local isFirst = true
	overlay:SetNeedsFrameUpdate(true)
	overlay.OnFrame = function(self, delta)

		if(not unit:IsDead()) then
			local worldView = import('/lua/ui/game/worldview.lua').viewLeft
			local bp = unit:GetBlueprint()
			local unitW = bp.LifeBarSize / 2
			local unitH = bp.LifeBarOffset
			local pos1 = unit:GetPosition() 
			pos1.x = pos1.x + unitW
			pos1.z = pos1.z + unitH
			local pos2 = unit:GetPosition()
			pos2.x = pos2.x - unitW
			
			local posA = worldView:Project(pos1)
			local posB = worldView:Project(pos2)
			local w = posB.x - posA.x

			overlay.Width:Set(w)
			LayoutHelpers.AtLeftTopIn(overlay, worldView, posA.x, posA.y)
		else
			overlay.destroy = true
			overlay:Hide()
		end
	end
		
	overlay.id = unit:GetEntityId()
	overlay.destroy = false
	--overlay.text = UIUtil.CreateText(overlay, '0', 20, UIUtil.bodyFont)
	--overlay.text:SetColor('green')
	--overlay.text:SetDropShadow(true)
	--LayoutHelpers.AtCenterIn(overlay.text, overlay, 0, 0)


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
		--overlays[id].text:SetColor('magenta')
		--overlays[id].text:SetText("_")
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
	local engineers = EntityCategoryFilterDown(categories.ENGINEER + categories.FACTORY, getUnits())
	if engineers == nil then return end
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
