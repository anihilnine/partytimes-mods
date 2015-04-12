local LayoutHelpers = import('/lua/maui/layouthelpers.lua')

local oldSetLayout = SetLayout
function SetLayout()
	oldSetLayout()
    local controlClusterGroup = import('/lua/ui/game/construction.lua').controlClusterGroup
    local controls = import('/lua/ui/game/construction.lua').controls
	local borderControls = import('/lua/ui/game/borders.lua').controls
    controls.constructionGroup.Right:Set(function() return borderControls.mapGroupLeft.Width()-20  end)
    local ordersControl = import('/lua/ui/game/orders.lua').controls.bg
	ordersControl.Left:Set(function() return 100 end)
end
