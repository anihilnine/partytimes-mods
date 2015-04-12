local modpath = "/mods/reminder"
local selectHelper = import(modpath..'/modules/selectHelper.lua')

local fixedConfig = {
	retriggerDelay = 0,
}
local runtimeConfig = {
	text = "HQ Finished",
	subtext = "Factory upgrade finished",
	icon = 'gearwheels/gearwheels_green.png',
}
function getFixedConfig()
	return fixedConfig
end
function getRuntimeConfig()
	return runtimeConfig
end


local allFactories = {}
local unitsToSelect = nil


function init()
end


function triggerNotification()
	local notificationIsReady = false

	-- add all new existing factories
	for _,u in selectHelper.getAllUnits() do
		if(u:IsInCategory("FACTORY") and u:IsInCategory("STRUCTURE"))then
			if(allFactories[u:GetEntityId()] == nil) then
				allFactories[u:GetEntityId()] = {unit = u, position = u:GetPosition()}
			end
		end
	end
	
	-- remove dead ones... or are they finished upgrading?
	for id,v in allFactories do
		if(v.unit:IsDead()) then
			-- same position as another unit? - upgrade done! - else dead
			local unitWithSamePosition = nil
			for id2, v2 in allFactories do
				if (id ~= id2) then
					if (v.position[1] == v2.position[1] and v.position[3] == v2.position[3]) then
						unitWithSamePosition = v2.unit
						break
					end
				end
			end
			
			if(unitWithSamePosition ~= nil) then
				if(setRuntimeConfig(unitWithSamePosition)) then
					unitsToSelect = {unitWithSamePosition}
					notificationIsReady = true
				end
			end
			
			allFactories[id] = nil
		end
	end
	
	return notificationIsReady
end


function onRetriggerDelay()
end


function onClick()
	SelectUnits(unitsToSelect)
end


---------------------


function setRuntimeConfig(u)
	local iKind = "Land"
	if(u:IsInCategory("AIR")) then
		iKind = "Air"
	elseif(u:IsInCategory("NAVAL")) then
		iKind = "Navy"
	end
	
	local iTech = ""
	if(isT2Hq(u:GetBlueprint())) then
		iTech = "T2"
	elseif(isT3Hq(u:GetBlueprint())) then
		iTech = "T3"
	else
		return false
	end
	runtimeConfig.subtext = iTech..' '..iKind..' HQ finished!'
	return true
end


function isT2Hq(bp)
	return cutBpId(bp.BlueprintId) == "020"
end
function isT3Hq(bp)
	return cutBpId(bp.BlueprintId) == "030"
end


function cutBpId(s)
   return string.sub(s, 4, 6)   
end