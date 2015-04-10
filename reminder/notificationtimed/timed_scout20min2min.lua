local modpath = "/mods/reminder"
local selectHelper = import(modpath..'/modules/selectHelper.lua')

function getFixedConfig()
	return {
		triggerAtSeconds = 1200,
		retriggerDelay = 120,
	}
end
function getRuntimeConfig()
	return {
		text = "Scout!",
		subtext = "scouting saves lives",
		icon = 't3scout.png'
	}
end


function onClick()
	unitsToSelect = {}
	for _,u in selectHelper.getAllUnits() do
		if(u:IsInCategory("AIR") and u:IsInCategory("INTELLIGENCE") )then
			if(u:IsIdle())then
				table.insert(unitsToSelect, u)
			end
		end	
	end
	SelectUnits(unitsToSelect)
end