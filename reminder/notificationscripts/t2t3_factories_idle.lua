local modpath = "/mods/reminder"
local selectHelper = import(modpath..'/modules/selectHelper.lua')

local fixedConfig = {
	retriggerDelay = 0,
}
local runtimeConfig = {
	text = "Idle Factory",
	subtext = "",
	icon = 'gearwheels/gearwheels_yellow.png',
}
function getFixedConfig()
	return fixedConfig
end
function getRuntimeConfig()
	return runtimeConfig
end


local unitsToSelect = nil
local cats = { T3 = "TECH3", T2 = "TECH2"}


function init()
end


function triggerNotification()
	unitsToSelect = {}
	
	for catName, catValue in cats do
		for _,u in selectHelper.getAllUnits() do
			if(u:IsInCategory("FACTORY") and u:IsInCategory(catValue))then
				if(u:IsIdle() and not selectHelper.isUnitUpgrading(u) )then
					table.insert(unitsToSelect, u)
				end
			end	
		end
		
		num = table.getn(unitsToSelect)
		if num > 0 then
			amountText = "factory"
			if(num > 1) then 
				amountText = "factories"
			end
			runtimeConfig.subtext = num.." idle "..catName.." "..amountText
			return true
		end
	end
	
	return false
end


function onRetriggerDelay()
end


function onClick()
	SelectUnits(unitsToSelect)
end