do

-- add a unit to an existing selection set
function AddUnitToGroupSet(groupName, unit)
	if groupName and unit then
		groupName = tonumber(groupName)
		
		if not selectionSets[groupName] then
			selectionSets[groupName] = {}
		end
		
		if not table.find(selectionSets[groupName],unit) and unit.GroupName != groupName then 
			unit.GroupName = groupName
			table.insert(selectionSets[groupName],unit)
			unit:AddSelectionSet(groupName)
		end	
	end
end

-- remove a unit to an existing selection set
function RemoveUnitFromGroupSet(groupName, unit)
	if groupName and unit then
		groupName = tonumber(groupName)
		if selectionSets[groupName] then
			if table.find(selectionSets[groupName],unit) and unit.GroupName == groupName then
				unit.GroupName = nil
				table.removeByValue(selectionSets[groupName],unit)
				unit:RemoveSelectionSet(groupName)
			end
		end
	end
end

-- add a selection set based on an array of units
-- if selectedUnits is nil, clears the selection set
function AddGroupSet(GroupName, unitArray)

	if unitArray then
        for index, unit in unitArray do
			local unitGroup = unit.GroupName
			if unitGroup then
				RemoveUnitFromGroupSet(unitGroup, unit)
			end
        end
    end
	
    -- remove units from the selection set if it already exists
    if selectionSets[GroupName] then
        for index, unit in selectionSets[GroupName] do
			RemoveUnitFromGroupSet(GroupName, unit)
        end
    end	
    
    if unitArray then		
        for index, unit in unitArray do
			AddUnitToGroupSet(GroupName, unit)
        end
	else
		selectionSets[GroupName] = nil
    end
    
    for i,v in selectionSetCallbacks do
        v(GroupName, unitArray, false)
    end
end

function ApplySquadSets(GroupNames)
    if not GroupNames then return end
	
	local selection = {}
	local igroupNames = table.deepcopy(GroupNames)
	for groupName, param in igroupNames do
		selectionSets[groupName] = ValidateUnitsList(selectionSets[groupName])
				
		local validunits = EntityCategoryFilterDown(categories.ALLUNITS - (categories.FACTORY - categories.MOBILE) , selectionSets[groupName])
		
		if table.getn(validunits) == 0 then 
			validunits = EntityCategoryFilterDown(categories.FACTORY - categories.MOBILE, selectionSets[groupName])
			if table.getn(validunits) == 0 then
				AddGroupSet(groupName, nil)
				GroupNames[groupName] = nil
			else
				for k, v in validunits do
					table.insert(selection, v)
				end
			end
		else
			for k, v in validunits do
				table.insert(selection, v)
			end
		end
	end
	
    if table.getn(selection) > 0 then
		SelectUnits(selection)
        local unitIDs = {}
        for _, unit in selection do
            table.insert(unitIDs, unit:GetEntityId())
        end
        
		SimCallback({Func = 'OnControlGroupApply', Args = unitIDs})
                
		for gn,f in GroupNames do
			for i,v in selectionSetCallbacks do
				v(gn, selectionSets[gn], true)
			end
		end
	else
		for gn,f in GroupNames do
			selectionSets[gn] = nil
		end
	end
end

-- select a specified selection set in the session
function ApplyGroupSet(GroupName, ZoomTo)

    # get a filtered list of only valid units back from the function
    if not selectionSets[GroupName] then return end
    selectionSets[GroupName] = ValidateUnitsList(selectionSets[GroupName])
    local selection = EntityCategoryFilterDown(categories.ALLUNITS - (categories.FACTORY - categories.MOBILE) , selectionSets[GroupName])
    if table.getsize(selection) == 0 then 
        selection = EntityCategoryFilterDown(categories.FACTORY - categories.MOBILE, selectionSets[GroupName])
        if table.getsize(selection) == 0 then
            AddSelectionSet(GroupName, nil)
            return
        end
    end
    if table.getn(selection) > 0 then
        SelectUnits(selection)
		
		if ZoomTo then
			UIZoomTo(selection)
		end
		
        local unitIDs = {}
        for _, unit in selection do
            table.insert(unitIDs, unit:GetEntityId())
        end
        SimCallback({Func = 'OnControlGroupApply', Args = unitIDs})
    
        # Time the difference between the 2 selection application to
        # determine if this is a double tap selection
        local curTime = GetSystemTimeSeconds()
        local diffTime = curTime - lastSelectionTime
        if diffTime > 1.0 then
            lastSelectionName = nil
        end
        lastSelectionTime = curTime
    
        # If this is a double tap then we want to soom in onto the central unit of the group
        if GroupName == lastSelectionName then
            if selection then
                UIZoomTo(selection)
            end
            lastSelectionName = nil
        else
            lastSelectionName = GroupName
        end        
       
        # if we are out of units. just set our set to nil
        if table.getn(selection) == 0 then
            selectionSets[GroupName] = nil
        else        
            for i,v in selectionSetCallbacks do
                v(GroupName, selectionSets[GroupName], true)
            end
        end
    end
end

function AppendSetToGroup(GroupName)
    # get a filtered list of only valid units back from the function
    local setID = GroupName
    selectionSets[setID] = ValidateUnitsList(selectionSets[setID])
		
    local selectionSet = EntityCategoryFilterDown(categories.ALLUNITS - categories.FACTORY, selectionSets[setID])
    local curSelection = GetSelectedUnits()
    if curSelection and selectionSet then
	
        for i, unit in selectionSet do
            table.insert(curSelection, unit)
        end
		
		for index, unit in curSelection do
			local UnitGroup = unit.GroupName
			if UnitGroup then
				unit:RemoveSelectionSet(UnitGroup)
				table.removeByValue(selectionSets[UnitGroup], unit)
				unit.GroupName = nil
			end
        end
		
        SelectUnits(curSelection)
		AddGroupSet(GroupName, curSelection)
    
        # Time the difference between the 2 selection application to
        # determine if this is a double tap selection
        local curTime = GetSystemTimeSeconds()
        local diffTime = curTime - lastSelectionTime
        if diffTime > 1.0 then
            lastSelectionName = nil
        end
        lastSelectionTime = curTime
    
        # If this is a double tap then we want to soom in onto the central unit of the group
        if GroupName == lastSelectionName then
            UIZoomTo(curSelection)
            lastSelectionName = nil
        else
            lastSelectionName = GroupName
        end
		
		
    elseif selectionSet then
        ApplyGroupSet(setID)
    end
end

function FactoryGroupSelection(GroupName)
    # get a filtered list of only valid units back from the function
    local setID = tostring(GroupName)
    selectionSets[setID] = ValidateUnitsList(selectionSets[setID])
    local selectionSet = EntityCategoryFilterDown(categories.FACTORY, selectionSets[setID])
    
    SelectUnits(selectionSet)
    
    # Time the difference between the 2 selection application to
    # determine if this is a double tap selection
    local curTime = GetSystemTimeSeconds()
    local diffTime = curTime - lastSelectionTime
    if diffTime > 1.0 then
        lastSelectionName = nil
    end
    lastSelectionTime = curTime

    # If this is a double tap then we want to soom in onto the central unit of the group
    if GroupName == lastSelectionName then
        UIZoomTo(selectionSet)
        lastSelectionName = nil
    else
        lastSelectionName = GroupName
    end
end


end