local isEnabled = true
local logEnabled = true

function Init() 

	local KeyMapper = import('/lua/keymap/keymapper.lua')
	KeyMapper.SetUserKeyAction('Disable UI-Plus', {action = "UI_Lua import('/mods/UI-Plus/modules/UI-Plus.lua').ToggleEnabled()", category = 'Mods', order = 1,})

	_G.UipLog = function(a)
		if (logEnabled) then 
			LOG(a)
		end
	end
end

function ToggleEnabled()
	
	isEnabled = not isEnabled

	if isEnabled then
		print("UI-Plus - ENABLED")
	else
		print("UI-Plus - DISABLED")
	end

	UipLog("UIP.Enabled " .. tostring(isEnabled))
end



function IsDisabled()
	return not isEnabled
end

