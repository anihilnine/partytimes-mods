local lastFocusedArmy = 0

local allSelens  = {}
local selectedUnits = {}


function main()
	if GetFocusArmy() != lastFocusedArmy then
		--Reset() -- TODO
		lastFocusedArmy = GetFocusArmy()
	end
	--local curr = GetSelectedUnits()
	UpdateSelectedUnits()
	UpdateAllSelens()
	
	RemoveSelensFromSelected()
	
	
	--[[
	local i = 0
	for _,__ in selectedUnits do
		i = i+1
	end
	print(i .. " units selected before")
	--]]
	
	--SelectUnits(selectedUnits)
end
--[[
	TODO:
		- in Selens Objekte nach EntityID speichern, Objekte mit 1. Key für selectedUnits ( aus GetSelected())
			und 2. unit ? ??? für selen == selected unit


--]]	




function UpdateSelectedUnits()
	selectedUnits = {} --TODO unit.isselected ? 
	--print("tick")
	local j = 0
	
	for i, unit in (GetSelectedUnits() or {} ) do
		selectedUnits[i] = unit
	end
	--print("tick tick")
	--[
	for _,_ in selectedUnits do
		j = j+1
	end
	print(j .. " units selected")
	--]]
end
function UpdateAllSelens()
	-- Add Scouts
	for entityid, unit in ( GetSelectedUnits() or{} ) do
		if unit:IsInCategory("SCOUT") then
			unit:SetCustomName("Scout")
			--allSelens[unit:GetEntityId()] = unit
			allSelens[entityid] = unit
		end
		
	end
	--Remove dead Scouts
	for entityid, unit in allSelens do
		if unit:IsDead() then
			allSelens[entityid] = nil
		end
	end
	
	--[
	local i = 0
	for _,__ in allSelens do
		i = i + 1
	end
	print(i .. " units in allSelens")
	--]]
end

function RemoveSelensFromSelected()
	for entityid, selen in (allSelens or {}) do
		selectedUnits[entityid] = nil
		print(entityid)
		if not selectedUnits[entityid]:IsInCategory("SCOUT") then
			print("wtf " .. entityid)
		end
	end
	
	--[
	local i = 0
	for _,_ in selectedUnits do
		i = i+1
	end
	print(i .. " units selected after removing")
	--]]
end