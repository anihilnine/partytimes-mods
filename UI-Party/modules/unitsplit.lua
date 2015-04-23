
function first(t)
	for k,v in t do
		return v	
	end
end

function any(t, selectClause)
	for k,v in t do
		return project(v, selectClause)
	end
	return false
end

function valueIn(t, vToFind)
	for k,v in t do
		if v == vToFind then return true end
	end
	return false
end


function containAllSameValues(lastSet, currentSelection)
	if lastSet == nil then return false end
	if currentSelection == nil then return false end

	for k,v in lastSet do
		if not valueIn(currentSelection, v) then return false end
	end	

	for k,v in currentSelection do
		if not valueIn(lastSet, v) then return false end
	end	
	
	return true
end



function project(v, selectClause)
	if selectClause == nil then return v end
	return selectClause(v)
end

function max(t, selectClause)
	local best = nil
	local r = {}
	for k,v in t do
		v = project(v, selectClause)
		if v > best then best = v end
	end
	return best
end

function select(t, selectClause)
	local r = {}
	for k,v in t do
		table.insert(r, project(v, selectClause))
	end
	return r
end

function where(t, whereClause)
	local r = {}
	for k,v in t do
		if whereClause(v) then
			table.insert(r, v)
		end
	end
	return r
end

function selectMany(t, selectClause)
	local r = {}
	for k,v in t do
		local t2 = selectClause(v)
		for kv,v2 in t2 do
			table.insert(r, v2)
		end
	end
	return r
end

function count(t)
	return table.getn(t)
end

function sum(t, selectClause)
	local s = 0
	for k,v in t do
		s = s + project(v, selectClause)
	end
	return s
end

function avg(t, selectClause)
	return sum(t, selectClause) / count(t)
end

function copy(t)
	local r = {}
	for k,v in t do
		r[k] = v
	end
	return r
end

function remove(t, toRemove)
	for k, v in t do
		if v == toRemove then
			table.remove(t, k)
			return
		end
	end
end

function foreach(t, a)
	for k, v in t do a(k, v) end
end

function GetAveragePoint(units)
	
	local count = count(units)
	local x = avg(units, function(v) return v:GetPosition()[1] end)
	local y = avg(units, function(v) return v:GetPosition()[2] end)
	local z = avg(units, function(v) return v:GetPosition()[3] end)
	local pos = { x, y, z}
	return pos
end

function GetPriorityUnits(ungroupedUnits)
	local maxVal = max(ungroupedUnits, function(v) return v:GetBlueprint().Economy.BuildCostMass end)
	return where(ungroupedUnits, function(v) return v:GetBlueprint().Economy.BuildCostMass == maxVal end)
end

function FindUnitFurtherestFromAllPoints(units, avoidancePoints)
	local bestD = -1
	local bestU
	for uk, uv in units do
		local thisUnitClosestPoint = 10000
		for pk, pv in avoidancePoints do
			local d = VDist3(uv:GetPosition(), pv)
			if d < thisUnitClosestPoint then
				thisUnitClosestPoint = d
			end
		end

		if thisUnitClosestPoint > bestD then
			bestD = thisUnitClosestPoint
			bestU = uv
		end
	end

	return bestU;
end

 function FindNearestToGroup(units, groups)
	local bestD = 10000
	local bestU
	local bestG
	for uk, uv in units do
		for gk, gv in groups do
			local d = VDist3(uv:GetPosition(), gv.Center)
			if d < bestD then
				bestD = d
				bestU = uv
				bestG = gv
			end
		end
	end
	local result = {Unit = bestU, Group = bestG}
	return result
end

function FindNearestToPos(groups, pos)
	local bestD = 10000
	local bestG
	for gk, gv in groups do
		local d = VDist3(gv.Center, pos)
		if d < bestD then
			bestD = d
			bestG = gv
		end
	end
	return bestG
end

local groups = {}
function SplitGroups(desiredGroups)


	local ungroupedUnits = GetSelectedUnits()
	if ungroupedUnits == nil then return end

	local avg = GetAveragePoint(ungroupedUnits)
	groups = {}
		
	-- START A GROUP
	local priorityUnits = {}
	while count(groups) < desiredGroups do
		if not any(priorityUnits) then priorityUnits = GetPriorityUnits(ungroupedUnits) end
		if not any(priorityUnits) then 
			UipLog("Not enough units to make another group'")
			break
		end
	
		local avoidancePoints = { avg }
		if any(groups) then 
			avoidancePoints = select(groups, function(v) return v.Center end)
		end
	
		local unit = FindUnitFurtherestFromAllPoints(priorityUnits, avoidancePoints)
		remove(ungroupedUnits, unit)
		remove(priorityUnits, unit)
	
		local group = {}
		group.Name = count(groups)+1
		group.Center = unit:GetPosition()
		group.Units = { unit  }
		table.insert(groups, group);
	end

	-- SHUNK UNITS INTO GROUPS
	while any(ungroupedUnits) do
	
		local nextGroups = copy(groups)

		while any(ungroupedUnits) and any(nextGroups) do
		
			if not any(priorityUnits) then priorityUnits = GetPriorityUnits(ungroupedUnits) end
			local t = FindNearestToGroup(priorityUnits, nextGroups)
			remove(nextGroups, t.Group)
			remove(ungroupedUnits, t.Unit)
			remove(priorityUnits, t.Unit)
			--t.Unit:SetCustomName(t.Group.Name)

			table.insert(t.Group.Units, t.Unit)
			t.Group.Center = GetAveragePoint(t.Group.Units);
		end
	end

	-- REORDER GROUPS TO BE NEAR MOUSE (annoying bug here where very different position if you slightly move mouse before/after end-drag)
	local sortedGroups = {}
	local mpos = GetMouseWorldPos()
	while any(groups) do
		local best = FindNearestToPos(groups, mpos)
		remove(groups, best)
		table.insert(sortedGroups, best)
	end
	groups = sortedGroups
	local gnum = 1
	foreach(groups, function(gk, gv)
		gv.Name = gnum
		gnum = gnum + 1
	end)

	SelectGroup(from(groups).first().Name)

	
end


local selectionsClearGroupCycle = true
local lastSelectedGroup
function SelectGroup(name)	
	if name > count(groups) then name = 1 end
	if name < 1 then name = count(groups) end

	local group = groups[name]
	lastSelectedGroup = group

	selectionsClearGroupCycle = false
	SelectUnits(group.Units)
	selectionsClearGroupCycle = true
end


function SelectNextGroup()	
	if lastSelectedGroup ~= nil then
		SelectGroup(lastSelectedGroup.Name + 1)
	else
		SplitGroups(100)
	end
end

function SelectPrevGroup()
	if lastSelectedGroup ~= nil then
		SelectGroup(lastSelectedGroup.Name - 1)
	else
		SplitGroups(100)
	end	
end

function SelectionChanged()
	if selectionsClearGroupCycle then 
		lastSelectedGroup = nil
	end
end
