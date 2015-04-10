local oldSelection = nil
local isAutoSelection = false
local allUnits = {}
local upgradingUnits = {}
local lastFocusedArmy = 0


function SelectBegin()
	oldSelection = GetSelectedUnits() or {}
	isAutoSelection = true
end
function SelectEnd()
	SelectUnits(oldSelection)
	isAutoSelection = false
end


function getAllUnits()
	return allUnits
end


function AddSelection()
	for _, unit in (GetSelectedUnits() or {}) do
		allUnits[unit:GetEntityId()] = unit
	end
end


function UpdateAllUnits()
	if GetFocusArmy() != lastFocusedArmy then
		Reset()
		lastFocusedArmy = GetFocusArmy()
	end

	AddSelection()
	
	-- Add focused (building or assisting), remove dead
	for entityid, unit in allUnits do
		if unit:IsDead() then
			allUnits[entityid] = nil
			upgradingUnits[entityid] = nil
		elseif unit:GetFocus() and not unit:GetFocus():IsDead() then
			allUnits[unit:GetFocus():GetEntityId()] = unit:GetFocus()
		end
	end
end


function Reset()
	local currentlySelected = GetSelectedUnits() or {}
	isAutoSelection = true
	UISelectionByCategory("ALLUNITS", false, false, false, false)
	AddSelection()
	SelectUnits(currentlySelected)
	isAutoSelection = false
end


function IsAutoSelection()
	return isAutoSelection
end


function addUpgradingUnit(u)
	upgradingUnits[u:GetEntityId()] = u
end


function removeUpgradingUnit(u)
	upgradingUnits[u:GetEntityId()] = nil
end


function isUnitUpgrading(u)
	targetId = u:GetEntityId()
	for id2,u2 in upgradingUnits do
		if(u:GetPosition()[1] == u2:GetPosition()[1]) and (u:GetPosition()[3] == u2:GetPosition()[3]) then
			return true
		end
	end
	return false
end
