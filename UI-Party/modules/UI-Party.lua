local settings = import('/mods/UI-Party/settings.lua')

function Init() 

	import('/mods/UI-Party/modules/linq.lua')

	InitKeys()

	_G.UipLog = function(a)
		if (GetSetting("logEnabled")) then 
			LOG("UIP:", a)
		end
	end
end

function CreateUI(isReplay)

	import('/mods/UI-Party/modules/notificationPrefs.lua').init()
	import('/mods/UI-Party/modules/notificationUi.lua').init()

end




function InitKeys()
	local KeyMapper = import('/lua/keymap/keymapper.lua')
	local order = 1
	local cat = "UI Party"
	KeyMapper.SetUserKeyAction('Disable UI-Party', {action = "UI_Lua import('/mods/UI-Party/modules/UI-Party.lua').ToggleEnabled()", category = cat, order = order,})
	
	range(2,10).foreach(function(k,v)
		order = order + 1		
		KeyMapper.SetUserKeyAction('Split selection into ' .. v .. ' groups', {action = "UI_Lua import('/mods/UI-Party/modules/unitsplit.lua').SplitGroups(" .. v .. ")", category = cat, order = order,})
	end)	

	range(1,10).foreach(function(k,v)
		order = order + 1
		KeyMapper.SetUserKeyAction('Select split group ' .. v, {action = "UI_Lua import('/mods/UI-Party/modules/unitsplit.lua').SelectGroup(" .. v .. ")", category = cat, order = order,})
	end)

	order = order + 1
	KeyMapper.SetUserKeyAction('Select next split group', {action = "UI_Lua import('/mods/UI-Party/modules/unitsplit.lua').SelectNextGroup()", category = cat, order = order,})
	order = order + 1
	KeyMapper.SetUserKeyAction('Select prev split group', {action = "UI_Lua import('/mods/UI-Party/modules/unitsplit.lua').SelectPrevGroup()", category = cat, order = order,})
	order = order + 1
	KeyMapper.SetUserKeyAction('Select next split group (shift)', {action = "UI_Lua import('/mods/UI-Party/modules/unitsplit.lua').SelectNextGroup()", category = cat, order = order,})
	order = order + 1
	KeyMapper.SetUserKeyAction('Select prev split group (shift)', {action = "UI_Lua import('/mods/UI-Party/modules/unitsplit.lua').SelectPrevGroup()", category = cat, order = order,})
end




function ToggleEnabled()
	SetSetting("enabled", not GetSetting("enabled"))

	if GetSetting("enabled") then
		print("UI-Party - ENABLED")
	else
		print("UI-Party - DISABLED")
	end

	UipLog("UIP.Enabled " .. tostring(GetSetting("enabled")))
end

function GetSettings()
	local notificationPrefs = import('/mods/UI-Party/modules/notificationPrefs.lua')
	local prefs = notificationPrefs.getPreferences()
	return prefs
end

function GetSetting(key)
	if key == "overrideZoomPop" then
		return GetSettings().global.zoomPopOverride
	end
	return settings.GetSetting(key)
end

function SetSetting(key, value)
	return settings.SetSetting(key, value)
end

function Enabled()
	return GetSetting("enabled")
end

