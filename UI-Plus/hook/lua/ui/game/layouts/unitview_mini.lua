
local UIP = import('/mods/UI-Plus/modules/UI-Plus.lua')
local LayoutHelpers = import('/lua/maui/layouthelpers.lua')

local oldPositionWindow = PositionWindow
function PositionWindow()
	oldPositionWindow()

	if UIP.GetSetting("rearrangeBottomPanes") then 

		local controls = import('/lua/ui/game/unitview.lua').controls
		LayoutHelpers.AtBottomIn(controls.bg, controls.parent)
		controls.abilities.Bottom:Set(function() return controls.bg.Bottom() - 24 end)
		LayoutHelpers.AtLeftIn(controls.bg, controls.parent, 17)

	end
end
