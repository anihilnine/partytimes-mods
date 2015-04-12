local modpath = "/mods/reminder"
local selectHelper = import(modpath..'/modules/selectHelper.lua')

local fixedConfig = {
	retriggerDelay = 0,
}
local runtimeConfig = {
	text = "",
	subtext = "",
	icon = 'gearwheels/gearwheels_yellow.png',
}
function getFixedConfig()
	return fixedConfig
end
function getRuntimeConfig()
	return runtimeConfig
end


local prevSmds = 0
local prevOmnis = 0


function init()
end


function triggerNotification()
	local smds = 0
	local omnis = 0
	local notificationIsReady = false
	
	-- smds
	for _,u in selectHelper.getAllUnits() do
		if(u:IsInCategory("ANTIMISSILE") and u:IsInCategory("TECH3") and u:IsInCategory("STRUCTURE"))then
			smds = smds +1
		end	
	end
	if smds < prevSmds then
		notificationIsReady = true
		runtimeConfig.text = "Nuke Defense Lost!"
		runtimeConfig.subtext = "Lost "..prevSmds-smds.." nuke defense!"
		runtimeConfig.icon = 'nuke/smd.png'
	end
	prevSmds = smds
	if notificationIsReady then
		return true
	end
	
	-- t3 radar
	for _,u in selectHelper.getAllUnits() do
		if(u:IsInCategory("OMNI") and u:IsInCategory("STRUCTURE") )then
			omnis = omnis +1
		end	
	end
	if omnis < prevOmnis then
		notificationIsReady = true
		runtimeConfig.text = "Omni Sensor Lost!"
		runtimeConfig.subtext = "Lost "..prevOmnis-omnis.." omni sensor!"
		runtimeConfig.icon = 'intel/uef_omni.png'
	end
	prevOmnis = omnis
	if notificationIsReady then
		return true
	end
	
	return false
end


function onRetriggerDelay()
end


function onClick()
end