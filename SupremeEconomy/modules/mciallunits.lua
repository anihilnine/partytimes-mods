local modFolder = 'SupremeEconomy'
local GetScore = import('/mods/' .. modFolder .. '/modules/mciscore.lua').GetScore

local oldSelection = nil
local isAutoSelection = false
local allUnits = {}
local lastFocusedArmy = 0

function SelectBegin()
	oldSelection = GetSelectedUnits() or {}
	isAutoSelection = true
end
function SelectEnd()
	SelectUnits(oldSelection)
	isAutoSelection = false
end

function AddSelection()
	for _, unit in (GetSelectedUnits() or {}) do
		allUnits[unit:GetEntityId()] = unit
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

local emergencyResetProcedureStarted = false
function EmergencyReset(targetUnitCount)
	WaitSeconds(3)
	local newTargetUnitCount = GetScore()[GetFocusArmy()].general.currentunits.count
	-- if after 10 seconds we are not loosing units and the unit count is still larger we have to do a reset
	if newTargetUnitCount >= targetUnitCount and newTargetUnitCount > table.getsize(allUnits)  then
		--print("Supreme Economy: New units detected, selecting units in 1 second!")
		WaitSeconds(0.5)
		Reset()
	end
	emergencyResetProcedureStarted = false
end

function UpdateAllUnits()
	if GetFocusArmy() != lastFocusedArmy then
		Reset()
		lastFocusedArmy = GetFocusArmy()
	end

	AddSelection()
	
	-- add focused (building or assisting)
	for _, unit in allUnits do
		if not unit:IsDead() and unit:GetFocus() and not unit:GetFocus():IsDead()then
			allUnits[unit:GetFocus():GetEntityId()] = unit:GetFocus()
		end
	end
	
	-- remove dead
	for entityid, unit in allUnits do
		if unit:IsDead() then
			allUnits[entityid] = nil
		end
	end
	
	-- emergency reset

	local targetNumOfUnits = GetScore()[GetFocusArmy()].general.currentunits.count
	
	if not emergencyResetProcedureStarted and (targetNumOfUnits > table.getsize(allUnits)) then
		emergencyResetProcedureStarted = true
		ForkThread(EmergencyReset, targetNumOfUnits)
	end
end
function GetAllUnits()
	return allUnits
end

function IsAutoSelection()
	return isAutoSelection
end
