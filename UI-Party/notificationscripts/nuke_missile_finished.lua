local modpath = '/mods/ui-party'
local selectHelper = import(modpath..'/modules/selectHelper.lua')

local fixedConfig = {
	retriggerDelay = 0,
}
local runtimeConfig = {
	text = "Nuke is ready",
	subtext = "",
	icon = 'gearwheel.png',
}
function getFixedConfig()
	return fixedConfig
end
function getRuntimeConfig()
	return runtimeConfig
end


local missileCountStationary = 0
local missileCountMobile = 0
local unitsToSelect = nil


function init()
end


function triggerNotification()
	local currentMissilesStationary = 0
	local currentMissilesMobile = 0
	unitsToSelect = {}
	
	for _,u in selectHelper.getAllUnits() do
		if(u:IsInCategory("NUKE") )then
			info = u:GetMissileInfo()
			if(u:IsInCategory("STRUCTURE") )then
				currentMissilesStationary = currentMissilesStationary + info.nukeSiloStorageCount
			else
				currentMissilesMobile = currentMissilesMobile + info.nukeSiloStorageCount
			end
			
			if( info.nukeSiloStorageCount > 0 ) then
				table.insert(unitsToSelect, u)
			end
		end
	end
	
	if(currentMissilesStationary > missileCountStationary) then
		missileCountStationary = currentMissilesStationary
		runtimeConfig.icon = "nuke/uef_stationary.png"
		runtimeConfig.subtext = "a stationary nuke is ready"
		return true
	end
	missileCountStationary = currentMissilesStationary
	
	if(currentMissilesMobile > missileCountMobile) then
		missileCountMobile = currentMissilesMobile
		runtimeConfig.icon = "nuke/uef_mobile.png"
		runtimeConfig.subtext = "a mobile nuke is ready"
		return true
	end
	missileCountMobile = currentMissilesMobile
	
	return false
end


function onRetriggerDelay()
end


function onClick()
	SelectUnits(unitsToSelect)
end