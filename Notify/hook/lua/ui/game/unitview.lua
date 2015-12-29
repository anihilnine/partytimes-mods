local EnhanceCommon = import('/lua/enhancementcommon.lua')
local Bitmap = import('/lua/maui/bitmap.lua').Bitmap
local UIUtil = import('/lua/ui/uiutil.lua')
local GetEnhancementPrefix = import('/lua/ui/game/construction.lua').GetEnhancementPrefix

local oldCreateUI = CreateUI
function CreateUI()
	oldCreateUI()
	
	controls.enhancements = {}
	controls.enhancements['RCH'] = Bitmap(controls.bg)
	LayoutHelpers.AtLeftTopIn(controls.enhancements['RCH'], controls.bg, 10, -30)
	controls.enhancements['Back'] = Bitmap(controls.bg)
	LayoutHelpers.AtLeftTopIn(controls.enhancements['Back'], controls.bg, 42, -30)
	controls.enhancements['LCH'] = Bitmap(controls.bg)
	LayoutHelpers.AtLeftTopIn(controls.enhancements['LCH'], controls.bg, 74, -30)
end

local oldUpdateWindow = UpdateWindow
function UpdateWindow(info)
	oldUpdateWindow(info)
	
	local existingEnhancements
	if info.userUnit ~= nil then
		existingEnhancements = EnhanceCommon.GetEnhancements(info.userUnit:GetEntityId())
	end
	
	for slot, enhancement in controls.enhancements do
		if info.userUnit == nil or (not info.userUnit:IsInCategory('COMMAND') and not info.userUnit:IsInCategory('SUBCOMMANDER')) or
		   existingEnhancements == nil or existingEnhancements[slot] == nil then
			enhancement:Hide()
			continue
		end
		
		local blueprint = info.userUnit:GetBlueprint()
		local bpId = blueprint.BlueprintId
		local enhancementBp = blueprint.Enhancements[existingEnhancements[slot]]
		local texture = GetEnhancementPrefix(bpId, enhancementBp.Icon) .. '_btn_up.dds'
		
		enhancement:Show()
		enhancement:SetTexture(UIUtil.UIFile(texture))
		enhancement.Width:Set(30)
		enhancement.Height:Set(30)
	end
	
end
