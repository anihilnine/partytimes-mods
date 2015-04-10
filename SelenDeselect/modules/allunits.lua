local oldSelection = nil
local isAutoSelection = false
local allUnits = {}
local lastFocusedArmy = 0


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
	--print("Update start")
	if GetFocusArmy() != lastFocusedArmy then
		Reset()
		lastFocusedArmy = GetFocusArmy()
	end

	AddSelection()
	--RenameSelected()
	
	--local i = 0
	--for _, _ in allUnits do
	--	i = i +1
	--end
	--print(i, " units in allUnits -- at Update")	
	
	-- Add focused (building or assisting)
	--for _, unit in allUnits do
	local ii = 0
	for _, unit in allUnits do
		if not unit:IsDead() and unit:GetFocus() and not unit:GetFocus():IsDead() then
			allUnits[unit:GetFocus():GetEntityId()] = unit:GetFocus()
		end
		--ii  = ii + 1
		--print("another unit")
	end
	--print( ii, " units")
	
	-- Remove dead
	for entityid, unit in allUnits do
		if unit:IsDead() then
			allUnits[entityid] = nil
		end
	end
	--print(i, " units in allUnits -- at Update")
	
	
	tick_Counter  = tick_Counter +1
	if tick_Counter == 10 then
		tick_Counter = 0
		
		local i = 0
		for _, _ in allUnits do
			i = i +1
		end
		--print(i, " units in allUnits -- at Update")	
	end
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
