local fixedConfig = {
	retriggerDelay = 15,
}
local runtimeConfig = {
	text = "Spend Mass",
	subtext = "you have alot mass in storage!",
	icon = 'eco/massIcon.png',
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
	
	if( (econData["stored"]["MASS"] > (econData["maxStorage"]["MASS"] * 0.5))
		or (econData["stored"]["MASS"] > 5000)) then
		
		return true
	end
	return false
end


function onRetriggerDelay()
end


function onClick()
end