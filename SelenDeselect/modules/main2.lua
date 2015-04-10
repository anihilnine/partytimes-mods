local oldSelection = nil
local isAutoSelection = false
local allUnits = {}
local lastFocusedArmy = 0

local allSelens  = {}

local previousSelection = nil
local tick_Counter = 0

function SelectBegin()
	oldSelection = GetSelectedUnits() or {}
	isAutoSelection = true
end
function SelectEnd()
	SelectUnits(oldSelection)
	isAutoSelection = false
end

function AddSelection()
	local i = 0
	for _, unit in (GetSelectedUnits() or {}) do
		allUnits[unit:GetEntityId()] = unit
		--unit:SetCustomName("test")
		i = i+1
		--print("ID: ", unit:GetEntityId())
	end
	--print(i, " units selected")
	--previousSelection = allUnits
	--allUnits = UISelectionByCategory("LAND", false, false, false, false)
	
	--print(i, " # in allUnits" )
end

function RenameSelected()
	--print("Renaming Selected")
	previousSelection = allUnits
	allUnits = GetSelectedUnits() --UISelectionByCategory("LAND", false, false, false, false)
	
	for i, unit in previousSelection do
		unit:SetCustomName("")
	end
	for i, unit in allUnits do
		unit:SetCustomName(".")
	end
end

function Reset()
	local currentlySelected = GetSelectedUnits() or {}
	isAutoSelection = true
	UISelectionByCategory("MOBILE+LAND", false, false, false, false)
	--UISelectionByCategory("LAND", false, false, false, false)
	AddSelection()
	
	SelectUnits(currentlySelected)
	isAutoSelection = false
end

function UpdateAllUnits()
	
	if GetFocusArmy() != lastFocusedArmy then
		--Reset()
		lastFocusedArmy = GetFocusArmy()
	end
	--print("tick")
	local currentlySelected = GetSelectedUnits()
	--[[if tick_counter > 25 then
		--UISelectionByCategory("SCOUT",false,false,false,false)
		print("reselected")
	end
	tick_counter = tick_counter + 1 --]]
	
	-- Add Scouts
	for _, unit in ( GetSelectedUnits() or{} ) do
		if unit:IsInCategory("SCOUT") then
			--print("SCOUT added")
			unit:SetCustomName("Scout")
			allSelens[unit:GetEntityId()] = unit
		end
		
	end
	--Remove dead Scouts
	for entityid, unit in allSelens do
		if unit:IsDead() then
			allSelens[entityid] = nil
		end
	end
	
	--print("tick tick")
	
	local i = 0
	for _,_ in currentlySelected do
			i = i+1
	end
	print("prev " .. i)
	i = 0
	
	for _, selen in (allSelens or {} ) do
		print("check")
		--if currentlySelected[selen:GetEntityID()] ~= nil then
		if currentlySelected[selen:GetEntityID()] ~= nil then
		
			print("match found")
			currentlySelected[selen:GetEntityID()] = nil
			--i = i +1
		else
			print("wtf")
		end
			i=i+1
	end
	print(i .. "scouts removed")
	
	
	--[[
	for _, unit in currentlySelected do
		--[[if categoryCheck == categories.SCOUT  then --unit is Selen and idle, hold fire or smth
			--DeselectUnits(unit)
			print("there is a SCOUT")
		end
		
		if categoryCheck == categories.COMMAND  then --unit is Selen and idle, hold fire or smth
			--DeselectUnits(unit)
			print("there is a COMMAND unit")
		end--]]
		
		
		
		
		for _,selen in allSelens do 
			if unit:GetEntityId() == selen:GetEntityId() then
				currentlySelected[unit:GetEntityId()] = nil
				print("unit deselected")
			end
		end
		i = i+1
	end --]]
	--print(i .. "units selected")
	
	--
	--SelectUnits({})
	--(currentlySelected)
	SelectUnits(allSelens)


end






function GetAllUnits()
	local i = 0
	for _, _ in allUnits do
		i = i +1
	end
	print(i, " units in allUnits -- at GetAllUnits")	
	return allUnits
end

function IsAutoSelection()
	return isAutoSelection
end

--LOG(repr(unit:GetPosition()))
--EntityCategoryFilterDown(categories.SUBCOMMANDER, idleEngineers)