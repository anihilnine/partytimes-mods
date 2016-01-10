local modifiedCommandQueue = {}
local previousModifiedCommandQueue = {}
local lastDisplayType
local watchingUnit

function watchForQueueChange(unit)
	if watchingUnit == unit then
		return
	end
	
	updateQueue = false
	watchingUnit = unit
	ForkThread(function()
		local threadWatchingUnit = watchingUnit
		while unit:GetCommandQueue()[1].type ~= 'Script' do
			WaitSeconds(0.2)
		end
		
		local selection = GetSelectedUnits() or {}
		if lastDisplayType and table.getn(selection) == 1 and threadWatchingUnit == watchingUnit and selection[1] == threadWatchingUnit then
			SetSecondaryDisplay(lastDisplayType)
		end
		watchingUnit = nil
	end)
end

function checkBadClean(unit)
	local enhancementQueue = import('/mods/Notify/modules/notify.lua').getEnhancementQueue()
	return (previousModifiedCommandQueue[1].type == 'enhancementqueue' and enhancementQueue[unit:GetEntityId()][1] and not string.find(enhancementQueue[unit:GetEntityId()][1].ID, 'Remove'))
end

function OrderEnhancement(item, clean, destroy)
	local units = sortedOptions.selection
	local enhancementQueue = import('/mods/Notify/modules/notify.lua').getEnhancementQueue()

	import('/lua/ui/game/gamemain.lua').SetIgnoreSelection(true)
    for _, u in units do
		local orders = {}
		local cleanOrder = clean
		local existingEnhancements = EnhanceCommon.GetEnhancements(u:GetEntityId())
		
		SelectUnits({u})
		
		if clean and not import('/mods/Notify/modules/notify.lua').currentlyUpgrading(u) then
			enhancementQueue[u:GetEntityId()] = {}
		end
		
		local doOrder = true
		local prereqAlreadyOrdered = false
		local removeAlreadyOrdered = false
		for _, enhancement in enhancementQueue[u:GetEntityId()] or {} do
			if enhancement.Slot == item.enhTable.Slot then
				if string.find(enhancement.ID, 'Remove') and enhancement.ID == (existingEnhancements[item.enhTable.Slot] .. 'Remove') then
					removeAlreadyOrdered = true
				elseif enhancement.ID == item.enhTable.ID or enhancement.ID ~= item.enhTable.Prerequisite then
					doOrder = false
					break
				elseif enhancement.ID == item.enhTable.Prerequisite then
					prereqAlreadyOrdered = true
				end
			end
		end
		
		if existingEnhancements[item.enhTable.Slot] == item.enhTable.ID then
			doOrder = false
		end
		
		if doOrder == false then
			continue
		end

		if not removeAlreadyOrdered and existingEnhancements[item.enhTable.Slot] and existingEnhancements[item.enhTable.Slot] ~= item.enhTable.Prerequisite then
			if not destroy then
				continue
			end
			
			table.insert(orders, existingEnhancements[item.enhTable.Slot]..'Remove')
		end

        if(cleanOrder and not u:IsIdle()) then
            local cmdqueue = u:GetCommandQueue()
            if(cmdqueue and cmdqueue[1] and cmdqueue[1].type == 'Script') then
                cleanOrder = false
            end
        end

		if(item.enhTable.Prerequisite and item.enhTable.Prerequisite ~= existingEnhancements[item.enhTable.Slot] and not prereqAlreadyOrdered) then
			table.insert(orders, item.enhTable.Prerequisite)
		end

		table.insert(orders, item.id)

		local first_order = true
		for _, o in orders do
			order = {TaskName='EnhanceTask', Enhancement=o}
			IssueCommand("UNITCOMMAND_Script", order, cleanOrder)
			if(first_order and cleanOrder) then
				cleanOrder = false
				first_order = false
			end
		end
		
		if(u:IsInCategory('COMMAND')) then
			local availableOrders, availableToggles, buildableCategories = GetUnitCommandData({u})
			OnSelection(buildableCategories, {u}, true)
		end
	end
		
	SelectUnits(units)
	import('/lua/ui/game/gamemain.lua').SetIgnoreSelection(false)
	
	controls.choices:Refresh(FormatData(sortedOptions[item.enhTable.Slot], item.enhTable.Slot))
end

local oldCommonLogic = CommonLogic
function CommonLogic()
	local retval = oldCommonLogic()
	local oldControl = controls.secondaryChoices.SetControlToType

	controls.secondaryChoices.SetControlToType = function(control, type)
		if type == 'enhancementqueue' then
            --local up, down, over, dis = GetEnhancementTextures(control.Data.unitID, control.Data.icon)
            local _,down,over,_,up = GetEnhancementTextures(control.Data.unitID, control.Data.icon)
            control:SetSolidColor('00000000')
            control.Icon:SetSolidColor('00000000')
            control.tooltipID = control.Data.name
            --control:SetNewTextures(up, down, over, dis)
            control:SetNewTextures(GetEnhancementTextures(control.Data.unitID, control.Data.icon))
            control.Height:Set(48)
            control.Width:Set(48)
            control.Icon.Width:Set(48)
            control.Icon.Height:Set(48)
			control.StratIcon:SetSolidColor('00000000')
			control.Count:SetText('')
            
            -- Maintaining backward compatibility
            if control.SetOverrideTexture then
                control:SetOverrideTexture(up)
            else
                control:SetUpAltButtons(up, up, up, up)
            end
            
            control:Disable()
            control.Height:Set(48)
            control.Width:Set(48)
            control.Icon:Show()
            control:Enable()
        end

        return oldControl(control, type)
	end

    return retval
end

local oldOnClickHandler = OnClickHandler
function OnClickHandler(button, modifiers)
	local item = button.Data

	if item.type == 'enhancement' then
		local doOrder = true
		local clean = not modifiers.Shift
		local enhancementQueue = import('/mods/Notify/modules/notify.lua').getEnhancementQueue()
		
		for _, unit in sortedOptions.selection do
			local existingEnhancements = EnhanceCommon.GetEnhancements(unit:GetEntityId())

			if existingEnhancements[item.enhTable.Slot] and existingEnhancements[item.enhTable.Slot] ~= item.enhTable.Prerequisite then
				local alreadyWarned = false
				for _, enhancement in enhancementQueue[unit:GetEntityId()] or {} do
					if enhancement.ID == (existingEnhancements[item.enhTable.Slot] .. 'Remove') then
						alreadyWarned = true
						break
					end
				end
				
				if not alreadyWarned and existingEnhancements[item.enhTable.Slot] ~= item.id then
					UIUtil.QuickDialog(GetFrame(0), "<LOC enhancedlg_0000>Choosing this enhancement will destroy the existing enhancement in this slot.  Are you sure?", 
						"<LOC _Yes>",
						function()
							OrderEnhancement(item, clean, true)
						end,
						"<LOC _No>",
						function()
							OrderEnhancement(item, clean, false)
						end,
						nil, nil,
						true,  {worldCover = true, enterButton = 1, escapeButton = 2})
							
					doOrder = false
					break
				end
			end
		end

		if(doOrder) then
			OrderEnhancement(item, clean, false)
		end

		button.Data.type = 'nil' -- prevent trigger in oldOnClickHandler
	end

	return oldOnClickHandler(button, modifiers)
end

function HandleIntegrationIssue()
	modifiedCommandQueue = table.copy(currentCommandQueue or {})
	
	local splitStack = nil
	local currCount = 1
	for _, command in previousModifiedCommandQueue do
		if command.type == 'enhancementqueue' then
			table.insert(modifiedCommandQueue, currCount, command)
			currCount = currCount + 1
		else
			if modifiedCommandQueue[currCount] and modifiedCommandQueue[currCount].displayCount then
				modifiedCommandQueue[currCount].displayCount = nil
			end
				
			if splitStack and splitStack.id == command.id then
				table.insert(modifiedCommandQueue, currCount, splitStack)
				splitStack = nil
			end
			if modifiedCommandQueue[currCount] and modifiedCommandQueue[currCount].id == command.id then
				if command.displayCount and modifiedCommandQueue[currCount].count > command.displayCount then
					splitStack = { id = command.id, count = modifiedCommandQueue[currCount].count - command.displayCount }
					modifiedCommandQueue[currCount].displayCount = command.displayCount
				end
				currCount = currCount + 1
			end
		end
	end
end

function IntegrateEnhancements()
	local uid = sortedOptions.selection[1]:GetEntityId()
	local fullCommandQueue = sortedOptions.selection[1]:GetCommandQueue()
	local enhancementQueue = import('/mods/Notify/modules/notify.lua').getEnhancementQueue()
	local found = {}
	local currCount = 1
	local currEnh = 1
	local skip = 0
	local skippingCommand = nil
	
	local currentEnhancements = EnhanceCommon.GetEnhancements(uid)
	if(currentEnhancements) then
		for _, enhancement in currentEnhancements do
			found[enhancement] = true
		end
	end
	
	for _, command in fullCommandQueue do
		if command.type == 'Script' then
			if skip > 0 then
				local splitCommand = { id = skippingCommand.id, count = skip }
				table.insert(modifiedCommandQueue, currCount, splitCommand)
				skippingCommand.displayCount = skippingCommand.count - skip
				skip = 0
			end
		
			local enhancement = enhancementQueue[uid][currEnh]
			
			if not enhancement then
				HandleIntegrationIssue()
				return
			end
			
			local newCommand = { icon = enhancement.Icon, id = enhancement.UnitID, type = 'enhancementqueue', name = enhancement.Name }
			
			if not found[enhancement.ID] and not string.find(enhancement.ID, 'Remove') then
				table.insert(modifiedCommandQueue, currCount, newCommand)
				currCount = currCount + 1
			end
			
			found[enhancement.ID] = true
			
			currEnh = currEnh + 1
		elseif command.type == 'BuildMobile' then
			if skip > 0 then
				skip = skip - 1
			else
				if not modifiedCommandQueue[currCount] then
					HandleIntegrationIssue()
					return
				end
				
				skip = modifiedCommandQueue[currCount].count - 1
				skippingCommand = modifiedCommandQueue[currCount]
				skippingCommand.displayCount = nil
				currCount = currCount + 1
			end
		end
	end
	
	local size = table.getn(enhancementQueue[uid] or {})
	if enhancementQueue[uid] and currEnh < size + 1 then
		while currEnh < (size + 1) do
			import('/mods/Notify/modules/notify.lua').removeEnhancement(sortedOptions.selection[1])
			size = size - 1
		end
		SetSecondaryDisplay('buildQueue')
	end
	
	previousModifiedCommandQueue = modifiedCommandQueue
end
	

function SetSecondaryDisplay(type)
	lastDisplayType = type
    if updateQueue then --don't update the queue the tick after a buttonreleasecallback
        local data = {}
        if type == 'buildQueue' then
			for _, unit in sortedOptions.selection do
				if unit:IsIdle() then
					import('/mods/Notify/modules/notify.lua').clearEnhancements({unit})
				end
			end
			modifiedCommandQueue = table.copy(currentCommandQueue or {})
			if table.getn(sortedOptions.selection) == 1 then
				IntegrateEnhancements()
			end
			previousModifiedCommandQueue = modifiedCommandQueue
            if modifiedCommandQueue and table.getn(modifiedCommandQueue) > 0 then
				local index = 1
				local newStack = nil
				local lastStack = nil
                for _, item in modifiedCommandQueue do
					if item.type == 'enhancementqueue' then
						table.insert(data, {type = 'enhancementqueue', unitID = item.id, icon = item.icon, name = item.name})
					else
						newStack = {type = 'queuestack', id = item.id, count = item.displayCount or item.count, position = index}
						if lastStack and lastStack.id == newStack.id then
							newStack.position = index - 1
						else
							index = index + 1
							lastStack = newStack
						end
						table.insert(data, newStack)
					end
                end
            end
            if table.getn(sortedOptions.selection) == 1 and table.getn(data) > 0 then
                controls.secondaryProgress:SetNeedsFrameUpdate(true)
            else
                controls.secondaryProgress:SetNeedsFrameUpdate(false)
                controls.secondaryProgress:SetAlpha(0, true)
            end
        elseif type == 'attached' then
            local attachedUnits = EntityCategoryFilterDown(categories.MOBILE, GetAttachedUnitsList(sortedOptions.selection))
            if attachedUnits and table.getn(attachedUnits) > 0 then
                for _, v in attachedUnits do
                    table.insert(data, {type = 'attachedunit', id = v:GetBlueprint().BlueprintId, unit = v})
                end
            end
            controls.secondaryProgress:SetAlpha(0, true)
        end
        controls.secondaryChoices:Refresh(data)
    else
        updateQueue = true
    end
end

function updateCommandQueue()
	OnQueueChanged(currentCommandQueue)
end

local oldFormatData = FormatData
function FormatData(unitData, type)
	if type == 'RCH' or type == 'Back' or type == 'LCH' then
		local retData = oldFormatData(unitData, type)
		local enhancementQueue = import('/mods/Notify/modules/notify.lua').getEnhancementQueue()
		for _, iconData in retData do
			iconData.Disabled = false
			
			if table.getn(sortedOptions.selection) == 1 then
				for _, enhancement in (enhancementQueue[sortedOptions.selection[1]:GetEntityId()] or {}) do
					if enhancement.Slot == iconData.enhTable.Slot and enhancement.ID ~= iconData.enhTable.Prerequisite and not string.find(enhancement.ID, 'Remove') then
						iconData.Disabled = true
						break
					end
				end
			else
				iconData.Selected = false
			end
		end
		
		SetSecondaryDisplay('buildQueue')
		
		return retData
	end
	local data = oldFormatData(unitData, type)
    return oldFormatData(unitData, type)
end

function ModifyBuildablesForACU(originalBuildables, selection)
	local newBuildableCategories
	local upgradingACUFound = false
	local faction
	for unitIndex, unit in selection do
		local currentBuildableCategories
		if unit:IsInCategory('COMMAND') then
			local techUpgrading = 0
			local enhancementQueue = import('/mods/Notify/modules/notify.lua').getEnhancementQueue()
			for _, enhancement in (enhancementQueue[unit:GetEntityId()] or {}) do
				if enhancement.ID == 'AdvancedEngineering' and techUpgrading < 2 then
					techUpgrading = 2
				elseif enhancement.ID == 'T3Engineering' then
					techUpgrading = 3
				end
			end
			currentBuildableCategories = ParseEntityCategory(unit:GetBlueprint().Economy.BuildableCategory[1])
			if techUpgrading >= 2 then
				currentBuildableCategories = currentBuildableCategories + ParseEntityCategory(unit:GetBlueprint().Economy.BuildableCategory[2])
				faction = string.upper(unit:GetBlueprint().General.FactionName)
				upgradingACUFound = true
			end
			if techUpgrading == 3 then
				currentBuildableCategories = currentBuildableCategories + ParseEntityCategory(unit:GetBlueprint().Economy.BuildableCategory[3])
			end
		else
			for categoryIndex, category in unit:GetBlueprint().Economy.BuildableCategory do
				if categoryIndex == 1 then
					currentBuildableCategories = ParseEntityCategory(category)
				else
					currentBuildableCategories = currentBuildableCategories + ParseEntityCategory(category)
				end
			end
		end
		if unitIndex == 1 then
			newBuildableCategories = currentBuildableCategories
		elseif currentBuildableCategories and newBuildableCategories then
			newBuildableCategories = newBuildableCategories * currentBuildableCategories
		else
			upgradingACUFound = false
			break
		end
	end
	
	if upgradingACUFound == false then
		newBuildableCategories = originalBuildables
	else
		local restrictedUnits = import('/lua/ui/lobby/restrictedUnitsData.lua').restrictedUnits
		for _, generalCategory in SessionGetScenarioInfo().Options.RestrictedCategories or {} do
			for _, category in restrictedUnits[generalCategory].categories or {} do
				newBuildableCategories = newBuildableCategories - ParseEntityCategory(category)
			end
		end
		
		local factionCategory = ParseEntityCategory(faction)
		
		import('/lua/ui/game/gamemain.lua').SetIgnoreSelection(true)
		UISelectionByCategory('LAND RESEARCH TECH3 ' .. faction, false, false, false, false)
		if not GetSelectedUnits() then
			newBuildableCategories = newBuildableCategories - (categories.LAND * categories.SUPPORTFACTORY * categories.TECH3 * factionCategory)
			UISelectionByCategory('LAND RESEARCH TECH2 ' .. faction, false, false, false, false)
			if not GetSelectedUnits() then
				newBuildableCategories = newBuildableCategories - (categories.LAND * categories.SUPPORTFACTORY * categories.TECH2 * factionCategory)
			end
		end
		UISelectionByCategory('AIR RESEARCH TECH3 ' .. faction, false, false, false, false)
		if not GetSelectedUnits() then
			newBuildableCategories = newBuildableCategories - (categories.AIR * categories.SUPPORTFACTORY * categories.TECH3 * factionCategory)
			UISelectionByCategory('AIR RESEARCH TECH2 ' .. faction, false, false, false, false)
			if not GetSelectedUnits() then
				newBuildableCategories = newBuildableCategories - (categories.AIR * categories.SUPPORTFACTORY * categories.TECH2 * factionCategory)
			end
		end
		UISelectionByCategory('NAVAL RESEARCH TECH3 ' .. faction, false, false, false, false)
		if not GetSelectedUnits() then
			newBuildableCategories = newBuildableCategories - (categories.NAVAL * categories.SUPPORTFACTORY * categories.TECH3 * factionCategory)
			UISelectionByCategory('NAVAL RESEARCH TECH2 ' .. faction, false, false, false, false)
			if not GetSelectedUnits() then
				newBuildableCategories = newBuildableCategories - (categories.NAVAL * categories.SUPPORTFACTORY * categories.TECH2 * factionCategory)
			end
		end
		
		SelectUnits(selection)
		import('/lua/ui/game/gamemain.lua').SetIgnoreSelection(false)
	end
	
	return newBuildableCategories
end

local oldOnSelection = OnSelection
function OnSelection(buildableCategories, selection, isOldSelection)
	local newBuildableCategories = ModifyBuildablesForACU(buildableCategories, selection)
		
	oldOnSelection(newBuildableCategories, selection, isOldSelection)
end