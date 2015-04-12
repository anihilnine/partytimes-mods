local UIP = import('/mods/UI-Plus/modules/UI-Plus.lua')

local oldSetLayout = SetLayout
function SetLayout()
	oldSetLayout()
	
	if UIP.GetSetting("rearrangeBottomPanes") then 
		local control = import('/lua/ui/game/unitviewDetail.lua').View
		LayoutHelpers.AtBottomIn(control, control:GetParent(), 0)
		LayoutHelpers.AtLeftIn(control, control:GetParent(), 0)
	end
end
