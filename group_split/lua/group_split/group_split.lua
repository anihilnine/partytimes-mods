--*****************************************************************************
--* File: lua/modules/ui/game/controlgroups.lua
--*
--* Copyright © 2006 Gas Powered Games, Inc.  All rights reserved.
--*****************************************************************************

local UIUtil = import('/lua/ui/uiutil.lua')
local LayoutHelpers = import('/lua/maui/layouthelpers.lua')
local GameMain = import('/lua/ui/game/gamemain.lua')
local Group = import('/lua/maui/group.lua').Group
local Button = import('/lua/maui/button.lua').Button
local Checkbox = import('/lua/maui/checkbox.lua').Checkbox
local Movie = import('/lua/maui/movie.lua').Movie
local Bitmap = import('/lua/maui/bitmap.lua').Bitmap
local GameCommon = import('/lua/ui/game/gamecommon.lua')
local Announcement = import('/lua/ui/game/announcement.lua').CreateAnnouncement
local Selection = import('/lua/ui/game/selection.lua')
local Tooltip = import('/lua/ui/game/tooltip.lua')
local lastSetIndex = 0
local controlGroupCount = 0

controls = {
    groups = {},
}

validGroups = {
    ['11'] = true,
    ['12'] = true,
    ['13'] = true,
    ['14'] = true,
    ['15'] = true,
    ['16'] = true,
    ['17'] = true,
    ['18'] = true,
    ['19'] = true,
    ['20'] = true,
}

groupOrder = {'11','12','13','14','15','16','17','18','19','20'}

function vIn(v, b)
	for kb,vb in b do
		if v == vb then return true end
	end

	return false 
end


function areSame(lastSet, currentSelection)
	if lastSet == nil then return false end
	if currentSelection == nil then return false end


	for k,v in lastSet do
		if not vIn(v, currentSelection) then return end
	end	

	for k,v in currentSelection do
		if not vIn(v, lastSet) then return end
	end	
	
	return true
end


local logEnabled = false
function Log(msg)
	if logEnabled then
		LOG(msg)
	end
end


function SmartSplitL()
	Log("last index was " .. lastSetIndex)
	local lastSet = Selection.selectionSets[lastSetIndex]
	local currentSelection = GetSelectedUnits()
	if currentSelection == nil then return end
	local same = areSame(lastSet, currentSelection)
	Log("same was", same)
	if same then
		lastSetIndex = lastSetIndex + 1
		if lastSetIndex == 11+controlGroupCount then 
			lastSetIndex = lastSetIndex - 1
		end
		SelectSplitGroup(lastSetIndex)
	else
		SplitUnitsIntoGroups(100)
	end
end
function SmartSplitR()
	Log("last index was " .. lastSetIndex)
	local lastSet = Selection.selectionSets[lastSetIndex]
	local currentSelection = GetSelectedUnits()
	if currentSelection == nil then return end
	local same = areSame(lastSet, currentSelection)
	Log("same was", same)
	if same then
		lastSetIndex = lastSetIndex - 1
		if lastSetIndex == 10 then 
			lastSetIndex = 11
		end
		SelectSplitGroup(lastSetIndex)
	else
		SplitUnitsIntoGroups(100)
	end
end


function CreateUI(mapGroup)
    controls.parent = mapGroup
    
    controls.container = Group(controls.parent)
    controls.container.Depth:Set(100)
    
    controls.bgTop = Bitmap(controls.container)
    controls.bgBottom = Bitmap(controls.container)
    controls.bgStretch = Bitmap(controls.container)
    controls.collapseArrow = Checkbox(controls.parent)
    controls.collapseArrow.OnCheck = function(self, checked)
        ToggleControlGroups(checked)
    end
    Tooltip.AddCheckboxTooltip(controls.collapseArrow, 'control_collapse')
	controls.collapseArrow:Hide()
    
    controls.container:DisableHitTest(true)
    
    Selection.RegisterSelectionSetCallback(OnSelectionGroupSetChanged)
    
    ForkThread(CheckGroups)
    
    controls.container:Hide()
	
    SetLayout()
	
    for i, v in validGroups do
        import('/lua/ui/game/selection.lua').ApplySelectionSet(tostring(i))
    end
end

function CheckGroups()
    while controls.container do
        for i, v in controls.groups do
            v:UpdateGroup()
        end
        WaitSeconds(1)
    end
end

function SetLayout()
    import('/mods/group_split/lua/group_split/layouts/group_split_mini.lua').SetLayout()
end

function OnSelectionGroupSetChanged(name, units, applied)
	name = tostring(name)
    if not validGroups[name] then return end
	
    local function CreateGroup(units, label)
        local bg = Bitmap(controls.container, UIUtil.SkinnableFile('/game/avatar/avatar-control-group_bmp.dds'))
        
        bg.icon = Bitmap(bg)
        bg.icon.Width:Set(28)
        bg.icon.Height:Set(20)
        LayoutHelpers.AtCenterIn(bg.icon, bg, 0, -4)
        
        bg.label = UIUtil.CreateText(bg.icon, label, 18, UIUtil.bodyFont)
        bg.label:SetColor('ffffffff')
        bg.label:SetDropShadow(true)
        LayoutHelpers.AtRightIn(bg.label, bg.icon)
        LayoutHelpers.AtBottomIn(bg.label, bg, 5)
        
        bg.icon:DisableHitTest()
        bg.label:DisableHitTest()
        
        bg.units = units
		bg.numofunits = UIUtil.CreateText(bg.icon, 'omg', 14, UIUtil.bodyFont)
		bg.numofunits:DisableHitTest()
		LayoutHelpers.AtCenterIn(bg.numofunits, bg.icon, 0, 31)
		bg.numofunits:SetDropShadow(true)
        bg.numofunits:SetColor('ffff7f00')
        
        bg.UpdateGroup = function(self)
            self.units = ValidateUnitsList(self.units)
			
            if table.getsize(self.units) > 0 then
				self.numofunits:SetText(table.getsize(self.units))
                local sortedUnits = {}
                sortedUnits[1] = EntityCategoryFilterDown(categories.COMMAND + categories.SUBCOMMANDER, self.units)
                sortedUnits[2] = EntityCategoryFilterDown(categories.EXPERIMENTAL, self.units)
                sortedUnits[3] = EntityCategoryFilterDown(categories.TECH3 - categories.FACTORY, self.units)
                sortedUnits[4] = EntityCategoryFilterDown(categories.TECH2 - categories.FACTORY, self.units)
                sortedUnits[5] = EntityCategoryFilterDown(categories.TECH1 - categories.FACTORY, self.units)
                sortedUnits[6] = EntityCategoryFilterDown(categories.FACTORY, self.units)
                
                local iconID = ''
                for _, unitTable in sortedUnits do
                    if table.getn(unitTable) > 0 then
                        iconID = unitTable[1]:GetBlueprint().BlueprintId
                        break
                    end
                end
                
                if iconID != '' and DiskGetFileInfo(UIUtil.UIFile('/icons/units/'..iconID..'_icon.dds')) then
                    self.icon:SetTexture(UIUtil.UIFile('/icons/units/'..iconID..'_icon.dds'))
                else
                    self.icon:SetTexture(UIUtil.UIFile('/icons/units/default_icon.dds'))
                end
            else
                self:Destroy()
                controls.groups[self.name] = nil
            end
        end
		
        bg.name = tonumber(label)
        
		bg.HandleEvent = function(self,event)
            if event.Type == 'ButtonPress' or event.Type == 'ButtonDClick' then
                if event.Modifiers.Shift and event.Modifiers.Ctrl then
                    Selection.FactoryGroupSelection(self.name)
                elseif event.Modifiers.Shift then
					AddSelectionToGroup(self.name)
				elseif event.Modifiers.Alt then
					if event.Modifiers.Left then
						AddUnitsToGroup(self.name, GetSelectedUnits())
					elseif event.Modifiers.Right then
						RemoveUnitsFromGroup(self.name, GetSelectedUnits())
					end
                else
					if event.Modifiers.Left then
						Selection.ApplyGroupSet(self.name, false)
					elseif event.Modifiers.Right then
						Selection.ApplyGroupSet(self.name, true)
					end
                end
            end
        end
        
        bg:UpdateGroup()
        
        return bg
    end
	
    if not controls.groups[name] and units then
        PlaySound(Sound({Bank = 'Interface', Cue = 'UI_Economy_Click'}))
        controls.groups[name] = CreateGroup(units, name)
        local unitIDs = {}
        for _, unit in units do
            table.insert(unitIDs, unit:GetEntityId())
        end
        SimCallback({Func = 'OnControlGroupAssign', Args = unitIDs})
    elseif controls.groups[name] and not units then
        controls.groups[name]:Destroy()
        controls.groups[name] = nil
    elseif controls.groups[name] then
        controls.groups[name].units = units
        controls.groups[name]:UpdateGroup()
        local unitIDs = {}
        for _, unit in units do
            table.insert(unitIDs, unit:GetEntityId())
        end        
        SimCallback({Func = 'OnControlGroupAssign', Args = unitIDs})
    end
	
    import('/mods/group_split/lua/group_split/layouts/group_split_mini.lua').LayoutGroups()
end


function UpdateSelectionTables()

	for i, i in controls.groups do
		if table.getsize(i.units) == 0 then
			CleanSelectionGroup(i)
		end
	end	

	import('/mods/group_split/lua/group_split/layouts/group_split_mini.lua').LayoutGroups()
end

function AddSelectionToGroup(GroupName)
	if GroupName then
		local selectedunits = ValidateUnitsList(GetSelectedUnits())

		for id, unit in selectedunits do
			local UnitGroup = tostring(unit.GroupName)		
			if UnitGroup then
				RemoveUnitFromGroup(UnitGroup, unit)
			end
		end
			
		Selection.AppendSetToGroup(GroupName)
	end
end

function AddUnitsToGroup(groupName, Units)
	Units = ValidateUnitsList(Units)
	groupName = tostring(groupName)
	if Units and table.getn(Units) > 0 then
		for id, unit in Units do
			local UnitGroup = tostring(unit.GroupName)
			if UnitGroup then
				RemoveUnitFromGroup(UnitGroup, unit)
			end
			
			if groupName then
				AddUnitToGroup(groupName, unit)
			end
		end		
	end
end

function AddUnitToGroup(groupName, unit)
	groupName = tostring(groupName)
	if groupName and unit then
		if controls.groups[groupName].units then
			if not table.find(controls.groups[groupName].units, unit) then
				table.insert(controls.groups[groupName].units, unit)
				Selection.AddUnitToGroupSet(groupName, unit)
			end
		end
	end
end

function DisbandSelection()
	local selectedunits = ValidateUnitsList(GetSelectedUnits())		
	if selectedunits and table.getn(selectedunits) > 0 then
		DisbandUnits(selectedunits)
	end
end

function DisbandUnits(Units)
	Units = ValidateUnitsList(Units)	
	if Units and table.getn(Units) > 0 then
		for id, unit in Units do
			local UnitGroup = tostring(unit.GroupName)
			if UnitGroup then
				RemoveUnitFromGroup(UnitGroup, unit)
			end
		end		
	end
end

function RemoveUnitsFromGroup(GroupName, units)
	units = ValidateUnitsList(units)	
	if units and table.getn(units) > 0 and GroupName then
		for id, unit in units do
			RemoveUnitFromGroup(tostring(GroupName), unit)
		end		
	end
end

function RemoveUnitFromGroup(groupName, unit)
	if groupName and unit and controls.groups[groupName].units then
		if table.find(controls.groups[groupName].units, unit) then
			table.removeByValue(controls.groups[groupName].units, unit)
			Selection.RemoveUnitFromGroupSet(groupName, unit)			
			UpdateSelectionTables()
		end
	end
end

function RemoveCurrentGroups()

	local lastGroupIndex = 11+controlGroupCount-1
	Log(lastGroupIndex)
	for i = 11, lastGroupIndex do
		Log(i)

		local unitArray = Selection.selectionSets[i]
		if unitArray then
			for index, unit in unitArray do
				local unitGroup = unit.GroupName
				if unitGroup then
					Selection.RemoveUnitFromGroupSet(i, unit)
				end
			end
		end
	end

	controlGroupCount = 0

	
end


function SplitUnitsIntoGroups(NumOfGroups)
	if type(NumOfGroups) == 'number' then
		RemoveCurrentGroups()
		CleanSelectionGroups()
		
		if NumOfGroups <= 0 then
			NumOfGroups = 10
		end
		

		local selectedunits = ValidateUnitsList(GetSelectedUnits())
			
		table.sort(selectedunits, 
			function(unit1, unit2)
				bpid1 = unit1:GetBlueprint().BlueprintId
				bpid2 = unit2:GetBlueprint().BlueprintId
			return bpid1<bpid2
		end)
		
		local sortedUnits = { Command = {}, Experimental = {}, Tech1 = {}, Tech2 = {}, Tech3 = {}, Factory = {}, }
		local Groups = {}
		
		if table.getsize(selectedunits) > 0 then
			sortedUnits['Command'] = EntityCategoryFilterDown(categories.COMMAND, selectedunits)
			sortedUnits['Experimental'] = EntityCategoryFilterDown(categories.EXPERIMENTAL, selectedunits)
			sortedUnits['Tech3'] = EntityCategoryFilterDown(categories.TECH3 - categories.FACTORY, selectedunits)
			sortedUnits['Tech2'] = EntityCategoryFilterDown(categories.TECH2 - categories.FACTORY, selectedunits)
			sortedUnits['Tech1'] = EntityCategoryFilterDown(categories.TECH1 - categories.FACTORY, selectedunits)
			sortedUnits['Factory'] = EntityCategoryFilterDown(categories.FACTORY, selectedunits)
			
			local index = 1
			for unittype, units in sortedUnits do
				if table.getn(units) > 0 then
					for id, unit in units do
					
						if not Groups[index] then
							Groups[index] = {}
						end

						table.insert(Groups[index], unit)
					
						if index >= NumOfGroups then
							index = 1
						else
							index = index + 1
						end
					end
				end
			end

			controlGroupCount = table.getn(Groups)
			Log("actual groups " ..controlGroupCount )
			

			if table.getn(Groups) > 0 then		
				for GroupNum, units in Groups do
					Selection.AddGroupSet(GroupNum +10, units)
				end
			end
		else
			Selection.AddGroupSet(NumOfGroups +10 , nil)
		end

		lastSetIndex = 11
		SelectSplitGroup(lastSetIndex)
	end
end

function CleanSelectionGroups()
	for i, v in controls.groups do
		if table.getsize(v.units) > 0 then
			DisbandUnits(v.units)
		end
		v:Destroy()
		controls.groups[i] = nil
	end

	import('/mods/group_split/lua/group_split/layouts/group_split_mini.lua').LayoutGroups()
end

function CleanSelectionGroup(GroupName)
	local SelectionGroup = controls.groups[GroupName]
	
	if SelectionGroup then
		if table.getsize(SelectionGroup.units) > 0 then
			DisbandUnits(SelectionGroup.units)
		end
		
		SelectionGroup:Destroy()
		controls.groups[GroupName] = nil
		
		import('/mods/group_split/lua/group_split/layouts/group_split_mini.lua').LayoutGroups()
	end
end

function SelectSplitGroup(GroupNumber)
	lastSetIndex = GroupNumber
	Selection.ApplyGroupSet(GroupNumber)
end

function SelectSquadGroups()
	local selectedunits = ValidateUnitsList(GetSelectedUnits())
	
	if table.getn(selectedunits) > 0 then
		local GroupIds = {}
		for id, unit in selectedunits do
			local UnitGroup = unit.GroupName
			if UnitGroup then
				if not GroupIds[UnitGroup] then
					GroupIds[UnitGroup] = true
				end
			end
		end

		if table.getsize(GroupIds) > 0 then
			Selection.ApplySquadSets(GroupIds)
		end	
	end
end

function ToggleControlGroups(state)
    # disable when in Screen Capture mode
    if import('/lua/ui/game/gamemain.lua').gameUIHidden then
        return
    end
    
    if UIUtil.GetAnimationPrefs() then
        if controls.container:IsHidden() then
            PlaySound(Sound({Cue = "UI_Score_Window_Open", Bank = "Interface"}))
            controls.collapseArrow:SetCheck(false, true)
            controls.container:Show()
            controls.container:SetNeedsFrameUpdate(true)
			
			controls.container.OnFrame = function(self, delta)
                local newLeft = self.Left() + (1000*delta)
                if newLeft > controls.parent.Left()+13 then
                    newLeft = controls.parent.Left()+13
                    self:SetNeedsFrameUpdate(false)
                end
                self.Left:Set(newLeft)
            end
        else
            PlaySound(Sound({Cue = "UI_Score_Window_Close", Bank = "Interface"}))
            controls.container:SetNeedsFrameUpdate(true)
			
			controls.container.OnFrame = function(self, delta)
                local newLeft = self.Left() - (1000*delta)
                if newLeft < controls.parent.Left()-self.Width() - 13 then
                    newLeft = controls.parent.Left()-self.Width() - 13
                    self:SetNeedsFrameUpdate(false)
                    self:Hide()
                end
                self.Left:Set(newLeft)
            end
            controls.collapseArrow:SetCheck(true, true)
        end
    else
        if state or controls.container:IsHidden() then
            controls.container:Show()
            controls.collapseArrow:SetCheck(true, true)
        else
            controls.container:Hide()
            controls.collapseArrow:SetCheck(false, true)
        end
    end
end

function Contract()
    controls.container:Hide()
    controls.collapseArrow:Hide()
end

function Expand()
    if table.getsize(controls.groups) > 0 then
        controls.container:Show()
        controls.collapseArrow:Show()
    end
end

function InitialAnimation()
    controls.container.Left:Set(controls.parent.Left()-controls.container.Width())
    controls.container:SetNeedsFrameUpdate(true)
    controls.container.OnFrame = function(self, delta)
		local newLeft = self.Left() - (1000*delta)
		if newLeft < controls.parent.Left()-self.Width() - 13 then
			newLeft = controls.parent.Left()-self.Width() - 13
			self:SetNeedsFrameUpdate(false)
			self:Hide()
		end
		self.Left:Set(newLeft)
	end
    controls.collapseArrow:SetCheck(false, true)
end