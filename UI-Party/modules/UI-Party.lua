local settings = import('/mods/UI-Party/settings.lua')

function Init() 

	local KeyMapper = import('/lua/keymap/keymapper.lua')
	KeyMapper.SetUserKeyAction('Disable UI-Party', {action = "UI_Lua import('/mods/UI-Party/modules/UI-Party.lua').ToggleEnabled()", category = 'Mods', order = 1,})

	_G.UipLog = function(a)
		if (GetSetting("logEnabled")) then 
			LOG(a)
		end
	end
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

function GetSetting(key)
	return settings.GetSetting(key)
end

function SetSetting(key, value)
	return settings.SetSetting(key, value)
end

function Enabled()
	return GetSetting("enabled")
end

