local modpath = "/mods/reminder"
local alreadyCounting = 0

local fixedConfig = {
	retriggerDelay = 15,
}
local runtimeConfig = {
	text = "Spend Energy",
	subtext = "you are overflowing energy!",
	icon = 'eco/energyIcon.png',
}
function getFixedConfig()
	return fixedConfig
end
function getRuntimeConfig()
	return runtimeConfig
end

function init()
end

function triggerNotification()
	econData = GetEconomyTotals()
	
	if( ((econData["stored"]["ENERGY"] + 1) > econData["maxStorage"]["ENERGY"])
		and (econData["income"]["ENERGY"] > (econData["lastUseRequested"]["ENERGY"]*1.2)) ) then
		alreadyCounting = alreadyCounting + 0.1
		
		if(alreadyCounting > 10) then
			alreadyCounting = 0
			return true
		end
	else
		alreadyCounting = 0
	end
	return false
end


function onRetriggerDelay()
end


function onClick()
end