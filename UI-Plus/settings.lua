
local settings = {

	enabled = true,
	logEnabled = false,

	overrideZoomPop = true,

	moveAvatarsToLeftSplitScreen = true,
	moveMainMenuToRight = true,
	hideMenusOnStart = true,

	startSplitScreen = false,

	rearrangeBottomPanes = true
}




















function GetSetting(key)
	return settings[key]
end

function SetSetting(key, value)
	settings[key] = value
end