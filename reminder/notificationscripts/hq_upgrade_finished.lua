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


local unitsToSelect = nil


local hqsPrev = {
	T2 = {
		Land = 0,
		Air = 0,
		Naval = 0,
	},
	T3 = {
		Land = 0,
		Air = 0,
		Naval = 0,
	},
}


function init()
end


function triggerNotification()
	local hqs = {
		T2 = {
			Land = 0,
			Air = 0,
			Naval = 0,
		},
		T3 = {
			Land = 0,
			Air = 0,
			Naval = 0,
		},
	}

	for _,u in selectHelper.getAllUnits() do
		if(u:IsInCategory("FACTORY") )then
			if((not selectHelper.isUnitUpgrading(u)) and isHq(u)) then
				uTech = "T2"
				uKind = "Land"
			
				if(u:IsInCategory("TECH3") )then
					uTech = "T3"
				end
				if(u:IsInCategory("AIR") )then
					uKind = "Air"
				elseif(u:IsInCategory("NAVAL") )then
					uKind = "Naval"
				end
				hqs[uTech][uKind] = hqs[uTech][uKind]+1
			end
		end
	end
	
	notificationIsReady = false
	for iTech,vTech in hqs do
		for iKind,vKind in vTech do
			if(hqs[iTech][iKind] > hqsPrev[iTech][iKind]) then
				runtimeConfig.subtext = iTech..' '..iKind..' HQ finished!'
				prepareHqSelectList(iTech, iKind)
				notificationIsReady = true
			end
			hqsPrev[iTech][iKind] = hqs[iTech][iKind]
			
			if(notificationIsReady) then
				return true
			end
		end		
	end
	
	return false
end


function onRetriggerDelay()
end


function onClick()
	SelectUnits(unitsToSelect)
end


---------------------


function isHq(u)
	bp = u:GetBlueprint()
	return (isT2Hq(bp) or isT3Hq(bp))
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


function prepareHqSelectList(cat1, cat2)
	unitsToSelect = {}
	
	if(cat1 == "T2") then
		cat1 = "TECH2"
	elseif(cat1 == "T3") then
		cat1 = "TECH3"
	end
	
	for _,u in selectHelper.getAllUnits() do
		if( u:IsInCategory(cat1) and u:IsInCategory(string.upper(cat2)) ) then
			table.insert(unitsToSelect, u)
		end
	end
end