
local settings = {

	enabled = true,
	logEnabled = true,

	overrideZoomPop = true,
	
	moveAvatarsToLeftSplitScreen = true,
	moveMainMenuToRight = true,
	hideMenusOnStart = true,
	smallerContructionTabWhenSplitScreen = true,
	rearrangeBottomPanes = true,
	startSplitScreen = true, -- split screen

	setGroundFireOnAttack = true
}




















function GetSetting(key)
	return settings[key]
end

function SetSetting(key, value)
	settings[key] = value
end