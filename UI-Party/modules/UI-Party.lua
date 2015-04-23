local settings = import('/mods/UI-Party/settings.lua')

function Init() 

	import('/mods/UI-Party/modules/linq.lua')

	InitKeys()

	_G.UipLog = function(a)
		if (GetSetting("logEnabled")) then 
			LOG(a)
		end
	end
end


function InitKeys()
	local KeyMapper = import('/lua/keymap/keymapper.lua')
	local order = 1
	KeyMapper.SetUserKeyAction('Disable UI-Party', {action = "UI_Lua import('/mods/UI-Party/modules/UI-Party.lua').ToggleEnabled()", category = 'Mods', order = order,})
	order = order + 1
	KeyMapper.SetUserKeyAction('Split selection into 2 groups', {action = "UI_Lua import('/mods/UI-Party/modules/unitsplit.lua').SplitGroups(2)", category = 'Mods', order = order,})
	order = order + 1		 
	KeyMapper.SetUserKeyAction('Split selection into 3 groups', {action = "UI_Lua import('/mods/UI-Party/modules/unitsplit.lua').SplitGroups(3)", category = 'Mods', order = order,})
	order = order + 1			
	KeyMapper.SetUserKeyAction('Split selection into 4 groups', {action = "UI_Lua import('/mods/UI-Party/modules/unitsplit.lua').SplitGroups(4)", category = 'Mods', order = order,})
	order = order + 1
	KeyMapper.SetUserKeyAction('Select next split group', {action = "UI_Lua import('/mods/UI-Party/modules/unitsplit.lua').SelectNextGroup()", category = 'Mods', order = order,})
	order = order + 1
	KeyMapper.SetUserKeyAction('Select prev split group', {action = "UI_Lua import('/mods/UI-Party/modules/unitsplit.lua').SelectPrevGroup()", category = 'Mods', order = order,})
	order = order + 1
	KeyMapper.SetUserKeyAction('Select split group 1', {action = "UI_Lua import('/mods/UI-Party/modules/unitsplit.lua').SelectGroup(1)", category = 'Mods', order = order,})
	order = order + 1
	KeyMapper.SetUserKeyAction('Select split group 2', {action = "UI_Lua import('/mods/UI-Party/modules/unitsplit.lua').SelectGroup(2)", category = 'Mods', order = order,})
	order = order + 1
	KeyMapper.SetUserKeyAction('Select split group 3', {action = "UI_Lua import('/mods/UI-Party/modules/unitsplit.lua').SelectGroup(3)", category = 'Mods', order = order,})
	order = order + 1
	KeyMapper.SetUserKeyAction('Select split group 4', {action = "UI_Lua import('/mods/UI-Party/modules/unitsplit.lua').SelectGroup(4)", category = 'Mods', order = order,})
	order = order + 1
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

