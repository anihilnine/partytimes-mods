local modPath = '/mods/idleEngineers/'
--local boolstr = import(modPath .. 'modules/utils.lua').boolstr
local addListener = import(modPath .. 'modules/init.lua').addListener
local GetAllUnits = import(modPath .. 'modules/allunits.lua').GetAllUnits

local units = {}

function updateUnits()
	local new_units = {}
	--print "updateUnits"
	for id, u in GetAllUnits() do
		table.insert(new_units, u)
	end

	units = new_units

end

function getUnits()
	return cleanUnitList(units)
end

function cleanUnitList(units)
	for i, u in units do
		if u:IsDead() then
			units[i] = nil
		end
	end

	return units
end

function init()
	updateUnits()
	addListener(updateUnits, 1)
end
