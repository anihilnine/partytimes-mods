local UIP = import('/mods/UI-Party/modules/UI-Party.lua')
local CommonUnits = import('/mods/common/units.lua')
local ignoreLocks = false

function IgnoreLocksWhile(a)
	ignoreLocks = true
	a()
	ignoreLocks = false
end

function SelectAllLockedUnits()
	local units = from(CommonUnits.Get()).where(function(k,v) return v.locked end).toArray()
	SelectUnits(units)
end

function ToggleSelectedUnitsLock()
	
	local units = GetSelectedUnits()
	if units == nil then return end
	
	local anyLocked = from(units).any(function(k,v) return v.locked end)
	local newLockState = not anyLocked
	from(units).foreach(function(k,v)
		v.locked = newLockState;
	end)

end

local dblClickStart = false
local dblClickId = false
local dblClickUnit = nil
local dblClickEnd = false
function isDoubleclick(newSelection)
	-- a double click is if 
	--   the first click is just one unit
	--   and the second click contains the same unit
	if dblClickStart then 
		dblClickEnd = newSelection[dblClickId] ~= nil
		UipLog("end?: " .. tostring(dblClickEnd))
		if dblClickEnd then 
			UipLog("***** double click")
			return true
		end
	end

	dblClickStart = table.getn(newSelection) == 1
	if dblClickStart then
		for entityid, unit in ipairs(newSelection) do
			dblClickId = entityid
			dblClickUnit = newSelection[dblClickId]
		end
	end
	UipLog("start?: " .. tostring(dblClickStart))

	--local diffTime = curTime - lastSelectionTime
	--if newSelection == lastSelection then
	--	if diffTime < 1.0 then
		--UipLog(curTime .. " -- " .. lastSelectionTime)
		--	UipLog("double tap detected")
		--end
	--end

	return false
end


local suppress = false
function OnSelectionChanged(oldSelection, newSelection, added, removed)

	if IsKeyDown('Shift') then
		return false
	end

	-- prevent inifite recursion
	if suppress then 
		return false
	end

	local tobeSelected = {}
	local changesMade = false

	if not ignoreLocks and UIP.GetSetting("doubleClickSelectsSimilarAssisters") then 

		-- if its a double click on an assister, select all fellow assisters
		if isDoubleclick(newSelection) then
			UipLog("-- double click detected")

			local dblClickGuardedUnit = dblClickUnit:GetGuardedEntity() 
			local dblClickLocked = dblClickUnit.locked

			for entityid, unit in ipairs(newSelection) do
		
				local isSame = unit:GetGuardedEntity() == dblClickGuardedUnit and unit.locked == dblClickUnit.locked
				if isSame then
					UipLog("found a brother")
					table.insert(tobeSelected,unit)
					changesMade = true
				else
					UipLog("didnt find brother")
				end
			end
			
		end
	end

	if not ignoreLocks and UIP.GetSetting("enableUnitLock") then 

		-- if double click didnt happen then select everything except assisters
		if not changesMade then
			if newSelection then
	
				local newSelectionCount = table.getn(newSelection)
				local reduceSelection = newSelectionCount > 1
	
				if reduceSelection then
		
					for entityid, unit in ipairs(newSelection) do
		
						if unit.locked then
							changesMade = true
						else
							table.insert(tobeSelected,unit)
						end
	
					end
				end	
			end
		end
	end

	if changesMade then 
		ForkThread(function() 
			suppress = true
			UipLog("--changing")
			SelectUnits(tobeSelected)
			suppress = false
		end)	
	end

	return changesMade

end
