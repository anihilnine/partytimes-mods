
local LayoutHelpers = import('/lua/maui/layouthelpers.lua')


local oldSetLayout = SetLayout
function SetLayout()
	oldSetLayout()
    local controls = import('/lua/ui/game/orders.lua').controls
    LayoutHelpers.AtLeftIn(controls.bg, controls.controlClusterGroup, 350)
end
