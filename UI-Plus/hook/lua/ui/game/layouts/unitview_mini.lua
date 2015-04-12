
local LayoutHelpers = import('/lua/maui/layouthelpers.lua')

local oldPositionWindow = PositionWindow
function PositionWindow()
	oldPositionWindow()

    local controls = import('/lua/ui/game/unitview.lua').controls
    LayoutHelpers.AtBottomIn(controls.bg, controls.parent)
    controls.abilities.Bottom:Set(function() return controls.bg.Bottom() - 24 end)
    LayoutHelpers.AtLeftIn(controls.bg, controls.parent, 17)
end
