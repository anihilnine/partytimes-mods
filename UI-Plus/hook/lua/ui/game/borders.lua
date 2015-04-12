local UIP = import('/mods/UI-Plus/modules/UI-Plus.lua')

local oldSplitMapGroup = SplitMapGroup
function SplitMapGroup(splitState, forceSplit)
	oldSplitMapGroup(splitState, forceSplit)

	if not UIP.GetSetting("moveAvatarsToLeftSplitScreen") or not UIP.Enabled() then 
		return
	end

	-- controls.mapGroupLeft
	local avatars = import('/lua/ui/game/avatars.lua')
	if splitState then

		LayoutHelpers.AtRightTopIn(avatars.controls.avatarGroup, avatars.controls.parent, controls.mapGroupLeft.Width() + 30, 0)
		LayoutHelpers.AtRightTopIn(avatars.controls.collapseArrow, avatars.controls.parent, controls.mapGroupLeft.Width() +30, 22)
    else
		LayoutHelpers.AtRightTopIn(avatars.controls.avatarGroup, avatars.controls.parent, 0, 200)
		LayoutHelpers.AtRightTopIn(avatars.controls.collapseArrow, avatars.controls.parent, 0, 222)
    end
end