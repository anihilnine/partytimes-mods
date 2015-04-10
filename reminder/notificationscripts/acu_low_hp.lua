local modpath = "/mods/reminder"
local selectHelper = import(modpath..'/modules/selectHelper.lua')

local fixedConfig = {
	retriggerDelay = 60
}
local runtimeConfig = {
	text = "Low ACU hp",
	subtext = "your ACU has low health!",
	icon = 'acus/uef.png',
}
function getFixedConfig()
	return fixedConfig
end
function getRuntimeConfig()
	return runtimeConfig
end

local acu = nil


function init()
	for _,u in selectHelper.getAllUnits() do
		if(u:IsInCategory("COMMAND") )then
			acu = u
			if u:IsInCategory("AEON") then
				runtimeConfig.icon = 'acus/aeon.png'
			elseif u:IsInCategory("CYBRAN") then
				runtimeConfig.icon = 'acus/cybran.png'
			elseif u:IsInCategory("SERAPHIM") then
				runtimeConfig.icon = 'acus/seraphim.png'
			end
		end
	end
end


function triggerNotification()
	if(acu == nil) then
		return false
	end
	
	if( acu:GetHealth() < acu:GetMaxHealth()*0.25 ) then
		alreadyCounting = 0
		return true
	end
	
	return false
end


function onRetriggerDelay()
end


function onClick()
	SelectUnits({acu})
end