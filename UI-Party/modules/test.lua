local SelectHelper = import('/mods/ui-party/modules/selectHelper.lua')
local UnitHelper = import('/mods/ui-party/modules/unitHelper.lua')
local UIP = import('/mods/UI-Party/modules/UI-Party.lua')
local Bitmap = import('/lua/maui/bitmap.lua').Bitmap
local Group = import('/lua/maui/group.lua').Group
local Text = import('/lua/maui/text.lua').Text
local UIUtil = import('/lua/ui/uiutil.lua')
local GameMain = import('/lua/ui/game/gamemain.lua')
local LayoutHelpers = import('/lua/maui/layouthelpers.lua')
local AvatarsClickFunc = import('/lua/ui/game/avatars.lua').ClickFunc
		
		
local spendTypes = {
	PROD = "PROD",
	MAINT = "MAINT"
}

local workerTypes = {
	WORKING = "WORKING",
	PAUSED = "PAUSED"
}

local resourceTypes = from( {
	{ name = "Mass", econDataKey = "massConsumed" },
	{ name = "Energy", econDataKey = "energyConsumed" },
} )

local unitTypes;

function GetUnitType(unit)
	local unitType = unitTypes.first( function(k, unitType)
		return EntityCategoryContains(unitType.category, unit)
	end )

	if (unitType == nil) then
		unitType = unitTypes.last()
	end

	return unitType
end


function OnUnitBoxClick(self, event, unitBox)
	--LOG(unitBox.unitType.name, unitBox.spendType, unitBox.workerType)
	--unitBox.SetOn(true)
	if event.Type == 'ButtonPress' then

		if unitBox.workerType == workerTypes.WORKING then
			if event.Modifiers.Right then
				DisableWorkers(unitBox)
			else
				SelectWorkers(unitBox)
			end
		elseif unitBox.workerType == workerTypes.PAUSED then
			if event.Modifiers.Right then
				EnablePaused(unitBox)
			else
				SelectPaused(unitBox)
			end
		end

--		if event.Modifiers.Right then

--			DisableUnits(unitType)

--		else
--			if selectedUnitType ~= nil then
--				selectedUnitType.typeUi.uiRoot:InternalSetSolidColor('aa000000')
--			end
--			selectedUnitType = unitType
--			SelectUnits(unitType.prodUnits)

--		end

	end

end

function GetWorkers(unitBox)
	local unitType = unitBox.unitType
	local workers = nil
	if unitBox.spendType == spendTypes.PROD then
		workers = unitType.prodUnits
	elseif unitBox.spendType == spendTypes.MAINT then
		workers = unitType.maintUnits
	end
	return ValidateUnitsList(workers)
end

function DisableWorkers(unitBox)
	local unitType = unitBox.unitType
	local workers = GetWorkers(unitBox)
	if table.getn(workers) == 0 then

	else

		if unitBox.spendType == spendTypes.PROD then
			for k,v in unitType.prodUnits do
				table.insert(unitType.pausedProdUnits, v)
			end
			SetPaused(workers, true)
			--unitType.typeUi.prodPausedUnitsBox.SetOn(true)
		elseif unitBox.spendType == spendTypes.MAINT then
			for k,v in unitType.maintUnits do
				table.insert(unitType.pausedMaintUnits, v)
			end
			DisableUnitsAbility(workers)
			--unitType.typeUi.maintPausedUnitsBox.SetOn(true)
		end
	end
end

function SelectWorkers(unitBox)
	local unitType = unitBox.unitType
	local workers = GetWorkers(unitBox)
	SelectUnits(workers)
end

function GetPaused(unitBox)
	local unitType = unitBox.unitType
	local workers = nil
	if unitBox.spendType == spendTypes.PROD then
		workers = unitType.pausedProdUnits
	elseif unitBox.spendType == spendTypes.MAINT then
		workers = unitType.pausedMaintUnits
	end
	
	local stillPaused = {}
	for k,v in ValidateUnitsList(workers) do
		if GetIsPausedBySpendType({v}, unitBox.spendType) then
			table.insert(stillPaused, v)
		end
	end
	-- could check still working on same project here
	return stillPaused
end

function GetIsPausedBySpendType(units, spendType)
	if spendType == spendTypes.PROD then
		return GetIsPaused(units)
	elseif spendType == spendTypes.MAINT then
		return GetIsUnitAbilityEnabled(units)
	end
end


function EnablePaused(unitBox)
	local pauseUnits = GetPaused(unitBox)
	local unitType = unitBox.unitType
	if unitBox.spendType == spendTypes.PROD then
		SetPaused(pauseUnits, false)
		unitType.pausedProdUnits = {}
	elseif  unitBox.spendType == spendTypes.MAINT then
		EnableUnitsAbility(pauseUnits)
		unitType.pausedMaintUnits = {}
	end
	unitBox.SetOn(false)
end

function SelectPaused(unitBox)
	local pauseUnits = GetPaused(unitBox)
	local unitType = unitBox.unitType
	SelectUnits(pauseUnits)
end

--unitToggleRules = {
--    Shield =  0,
--    Weapon = 1, --?
--    Jamming = 2,
--    Intel = 3,
--    Production = 4, --?
--    Stealth = 5,
--    Generic = 6,
--    Special = 7,
--Cloak = 8,}

function GetOnValueForScriptBit(i)
	if i == 0 then return false end -- shield is weird and reversed... you need to set it to false to get it to turn off - unlike everything else
	return true
end

function DisableUnitsAbility(units)
    for i = 0,8 do
        ToggleScriptBit(units, i, not GetOnValueForScriptBit(i))
    end
end

function EnableUnitsAbility(units)
    for i = 0,8 do	
        ToggleScriptBit(units, i, GetOnValueForScriptBit(i))
    end
end

function GetIsUnitAbilityEnabled(units)
    
	for i = 0,8 do	
        if GetScriptBit(units, i) == GetOnValueForScriptBit(i) then
			return true
		end
    end
	return false
end


local hoverUnitType = nil
local selectedUnitType = nil

function OnClick(self, event, unitType)
	if event.Type == 'MouseExit' then
	if hoverUnitType ~= nil then
			hoverUnitType.typeUi.uiRoot:InternalSetSolidColor('aa000000')
		end
		hoverUnitType = nil
	end
	if event.Type == 'MouseEnter' then
		hoverUnitType = unitType
	end
	if event.Type == 'ButtonPress' then

--		if event.Modifiers.Right then

--			DisableUnits(unitType)

--		else
--			if selectedUnitType ~= nil then
--				selectedUnitType.typeUi.uiRoot:InternalSetSolidColor('aa000000')
--			end
--			selectedUnitType = unitType
--			SelectUnits(unitType.prodUnits)

--		end

	end

	if hoverUnitType ~= nil then 
		hoverUnitType.typeUi.uiRoot:InternalSetSolidColor('aa660000')
	end
	if selectedUnitType~= nil then 
		UIP.test.ui.textLabel:SetText(selectedUnitType.name)
		selectedUnitType.typeUi.uiRoot:InternalSetSolidColor('ff660000')
	end

	return true
end

function GetEconData(unit)
	local mi = unit:GetMissileInfo()
	if (mi.nukeSiloBuildCount > 0 or mi.tacticalSiloBuildCount > 0) then
		-- special favour to silo stuff
		return unit:GetEconData()
	end

	if Sync.FixedEcoData ~= nil then
		local data = FixedEcoData[unit:GetEntityId()]
		return data;
	else
		-- legacy broken way, works in ui mod
		return unit:GetEconData()
	end
end

function DoUpdate()

	local units = from(SelectHelper.getAllUnits())

	unitTypes.foreach( function(k, unitType)
		unitType.prodUnits = { }
		unitType.maintUnits = { }
	end )

	-- set unittype resource usages to 0
	resourceTypes.foreach( function(k, rType)
		rType.usage = 0
		rType.maintUsage = 0
		unitTypes.foreach( function(k, unitType)
			local unitTypeUsage = unitType.usage[rType.name]
			unitTypeUsage.usage = 0
			unitTypeUsage.maintUsage = 0
		end )
	end )

	-- fill unittype resources with real data
	units.foreach( function(k, unit)
		local econData = GetEconData(unit)
		local unitToGetDataFrom = nil
		local isMaint = false

		if (econData == nil) then
			return;
		end

		if unit:GetFocus() then
			-- prefix = "-CONSTR- "
			unitToGetDataFrom = unit:GetFocus()
			isMaint = false
			-- consType = CONSTRUCTION
			-- workProgressOnUnit[unit:GetFocus():GetEntityId()] = unit:GetWorkProgress() --it should be only set in the context of the "name" generated"
		else
			-- prefix = ""
			unitToGetDataFrom = unit
			isMaint = true
			-- consType = CONSUMPTION
			-- workProgressOnUnit[unit:GetEntityId()] = unit:GetWorkProgress() --it should be only set in the context of the "name" generated"
		end



		local unitType = GetUnitType(unitToGetDataFrom)

		local unitHasUsage = false
		resourceTypes.foreach( function(k, rType)
			local usage = econData[rType.econDataKey]

			if (usage > 0) then
				local unitTypeUsage = unitType.usage[rType.name]
				if (isMaint) then
					rType.maintUsage = rType.maintUsage + usage
					unitTypeUsage.maintUsage = unitTypeUsage.maintUsage + usage
				else
					rType.usage = rType.usage + usage
					unitTypeUsage.usage = unitTypeUsage.usage + usage
				end
				unitHasUsage = true
			end

			-- 		if (usage ~= 0) then
			-- 			LOG(unitType.name, usage, rType.name)	
			-- 		end

		end )

		if unitHasUsage then
			if (isMaint) then
				table.insert(unitType.maintUnits, unit)
			else
				table.insert(unitType.prodUnits, unit)
			end
		end
	end )

	-- update ui
	local relayoutRequired = false
	unitTypes.foreach( function(k, unitType)

		unitType.typeUi.maintPausedUnitsBox.SetOn(table.getn(unitType.pausedMaintUnits) > 0)
		unitType.typeUi.prodPausedUnitsBox.SetOn(table.getn(unitType.pausedProdUnits) > 0)

		resourceTypes.foreach( function(k, rType)
			local unitTypeUsage = unitType.usage[rType.name]
			local rTypeUsageTotal = rType.usage + rType.maintUsage
			if rTypeUsageTotal == 0 then
				unitTypeUsage.bar.Width:Set(0)
				unitTypeUsage.maintBar.Width:Set(0)
				--unitTypeUsage.text:SetText("")
				--unitTypeUsage.maintText:SetText("")
				unitType.typeUi.prodUnitsBox.SetOn(false)
				unitType.typeUi.maintUnitsBox.SetOn(false)
			else


				local bv = unitTypeUsage.usage
				local bmv = unitTypeUsage.maintUsage
				local percentify = true
				if (percentify) then
					bv = bv / rTypeUsageTotal * 100
					bmv = bmv / rTypeUsageTotal * 100
				end

				bv = math.ceil(bv)
				bmv = math.ceil(bmv)

				if (bv > 0 and bv < 1) then bv = 1 end
				if (bmv > 0 and bmv < 1) then bmv = 1 end

				local shouldShow = bv + bmv > 0
				if (shouldShow and unitType.typeUi.uiRoot:IsHidden()) then
					unitType.typeUi.uiRoot:Show()
					unitType.typeUi.Clear()
					relayoutRequired = true
				end

				unitTypeUsage.bar.Width:Set(bv)
				unitTypeUsage.maintBar.Width:Set(bmv)
				local r = unitTypeUsage.bar.Right() + 1
				if bv == 0 then r = unitTypeUsage.bar.Left() end
				unitTypeUsage.maintBar.Left:Set(r)

				unitType.typeUi.prodUnitsBox.SetOn(bv > 0)
				unitType.typeUi.maintUnitsBox.SetOn(bmv > 0)



				-- 		unitTypeUsage.text:SetText(string.format("%4.0f", unitTypeUsage.usage))

--				local str = unitTypeUsage.usage
--				if (str == 0) then str = "" else str = string.format("%10.3f", str) end
--				unitTypeUsage.text:SetText(str)

--				local str = unitTypeUsage.maintUsage
--				if (str == 0) then str = "" else str = string.format("%10.3f", str) end
--				unitTypeUsage.maintText:SetText(str)


			end
		end )
	end )

	if relayoutRequired then
		local y = 0
		unitTypes.foreach(function(k, unitType)
			if not unitType.typeUi.uiRoot:IsHidden() then
				unitType.typeUi.uiRoot:Top(y)
				LayoutHelpers.AtTopIn(unitType.typeUi.uiRoot, UIP.test.ui, y)
				y = y + unitType.typeUi.uiRoot:Height()
			end
		end)
		UIP.test.ui.Height:Set(y)

	end
end

function UnitBox(typeUi, unitType, spendType, workerType)
	
	local group = Group(typeUi.uiRoot);
	group.Width:Set(20)
	group.Height:Set(22)

	local buttonBackgroundName = UIUtil.SkinnableFile('/game/avatar-factory-panel/avatar-s-e-f_bmp.dds')
	local button = Bitmap(group, buttonBackgroundName)
	button.Width:Set(20)
	button.Height:Set(22)
	LayoutHelpers.AtLeftIn(button, group, 0)
	LayoutHelpers.AtVerticalCenterIn(button, group, 0)	
	

	local check = Bitmap(group, '/textures/ui/uef/game/temp_textures/checkmark.dds')
	check.Width:Set(8)
	check.Height:Set(8)
	LayoutHelpers.AtLeftIn(check, group, 6)
	LayoutHelpers.AtVerticalCenterIn(check, group, 0)


	local unitBox = {
		group = group,
		button = button,
		check = check,
		unitType = unitType,
		spendType = spendType,
		workerType = workerType,
	};

	unitBox.SetOn = function(val) 
		if val then
			check:Show()
		else
			check:Hide()
		end
	end

	unitBox.SetOn(false);
	group.HandleEvent = function(self, event) return OnUnitBoxClick(self, event, unitBox) end

	return unitBox

end

function Invoke()
	local a, b = pcall( function()

		if UIP.test ~= nil then
			if UIP.test.ui then UIP.test.ui:Destroy() end
			if UIP.test.beat then GameMain.RemoveBeatFunction(UIP.test.beat) end
			UIP.test = { }
		end

		unitTypes = from( {
			{ name = "T1 Land Units", category = categories.LAND * categories.BUILTBYTIER1FACTORY * categories.MOBILE - categories.ENGINEER, icon = "icon_land1_generic", spacer = 0 },
			{ name = "T2 Land Units", category = categories.LAND * categories.BUILTBYTIER2FACTORY * categories.MOBILE - categories.ENGINEER, icon = "icon_land2_generic", spacer = 0 },

			{ name = "T3 Land Units", category = categories.LAND * categories.BUILTBYTIER3FACTORY * categories.MOBILE - categories.ENGINEER, icon = "icon_land3_generic", spacer = 20 },
			{ name = "T1 Air Units", category = categories.AIR * categories.BUILTBYTIER1FACTORY * categories.MOBILE - categories.ENGINEER, icon = "icon_fighter1_generic", spacer = 0 },
			{ name = "T2 Air Units", category = categories.AIR * categories.BUILTBYTIER2FACTORY * categories.MOBILE - categories.ENGINEER, icon = "icon_fighter2_generic", spacer = 0 },

			{ name = "T3 Air Units", category = categories.AIR * categories.BUILTBYTIER3FACTORY * categories.MOBILE - categories.ENGINEER, icon = "icon_fighter3_generic", spacer = 20 },
			{ name = "T1 Naval Units", category = categories.NAVAL * categories.BUILTBYTIER1FACTORY * categories.MOBILE - categories.ENGINEER, icon = "icon_ship1_generic", spacer = 0 },
			{ name = "T2 Naval Units", category = categories.NAVAL * categories.BUILTBYTIER2FACTORY * categories.MOBILE - categories.ENGINEER, icon = "icon_ship2_generic", spacer = 0 },
			{ name = "T3 Naval Units", category = categories.NAVAL * categories.BUILTBYTIER3FACTORY * categories.MOBILE - categories.ENGINEER, icon = "icon_ship3_generic", spacer = 20 },

			{ name = "Shields", category = categories.STRUCTURE * categories.SHIELD, icon = "icon_structure_shield", spacer = 0 },
			{ name = "Radar Stations", category = categories.STRUCTURE * categories.RADAR + categories.STRUCTURE * categories.OMNI, icon = "icon_structure_intel", spacer = 0  },
			{ name = "Sonar", category = categories.STRUCTURE * categories.SONAR + categories.MOBILESONAR, icon = "icon_structure_intel", spacer = 0  },
			{ name = "Stealth", category = categories.STRUCTURE * categories.COUNTERINTELLIGENCE, icon = "icon_structure_intel", spacer = 20 },

			{ name = "Energy production", category = categories.STRUCTURE * categories.ENERGYPRODUCTION, icon = "icon_structure1_energy", spacer = 0 },
			{ name = "Mass extraction", category = categories.MASSEXTRACTION + categories.MASSSTORAGE, icon = "icon_structure1_mass", spacer = 0 },
			{ name = "Mass fabrication", category = categories.STRUCTURE * categories.MASSFABRICATION, icon = "icon_structure1_mass", spacer = 20 },

			{ name = "Silos", category = categories.SILO, icon = "icon_structure_missile", spacer = 0 },
			{ name = "Factories", category = categories.STRUCTURE * categories.FACTORY - categories.GATE, icon = "icon_factory_generic", spacer = 0 },
			{ name = "Military", category = categories.STRUCTURE * categories.DEFENSE + categories.STRUCTURE * categories.STRATEGIC, icon = "icon_structure_directfire", spacer = 0 },
			{ name = "Experimentals", category = categories.EXPERIMENTAL, icon = "icon_experimental_generic", spacer = 0 },
			{ name = "ACU", category = categories.COMMAND, icon = "icon_commander_generic", spacer = 0 },
			{ name = "SACU", category = categories.SUBCOMMANDER, icon = "icon_commander_generic", spacer = 0 },
			{ name = "Engineers", category = categories.ENGINEER, icon = "icon_land_engineer", spacer = 20 },

			{ name = "Everything", category = categories.ALLUNITS, icon = "strat_attack_ping", spacer = 0 },
		} )

		unitTypes.foreach( function(k, unitType)
			unitType.usage = { }
			unitType.pausedProdUnits = { }
			unitType.pausedMaintUnits = { }
		end )

		local col0 = 0
		local col1 = col0 + 20
		local col2 = col1 + 20
		local col3 = col2 + 20
		local col4 = col3 + 105 
		local col5 = col4 + 20
		local col6 = col5 + 20

		local uiRoot = Bitmap(GetFrame(0))
		UIP.test.ui = uiRoot
		uiRoot.Width:Set(42)
		uiRoot.Width:Set(0)
		uiRoot.Height:Set(100)
		uiRoot.Left:Set(170)
		uiRoot.Top:Set(110)
		uiRoot.Depth:Set(99)
		uiRoot:DisableHitTest()
		
		uiRoot.textLabel = UIUtil.CreateText(uiRoot, 'Reconomy', 15, UIUtil.bodyFont)
		uiRoot.textLabel.Width:Set(10)
		uiRoot.textLabel.Height:Set(9)
		uiRoot.textLabel:SetNewColor('white')
		uiRoot.textLabel:DisableHitTest()
		LayoutHelpers.AtLeftIn(uiRoot.textLabel, uiRoot, 5)
		LayoutHelpers.AtTopIn(uiRoot.textLabel, uiRoot, -31)

		function CreateText(text, x)

			local t = UIUtil.CreateText(uiRoot, text, 9, UIUtil.bodyFont)
			t.Width:Set(5)
			t.Height:Set(5)
			t:SetNewColor('white')
			t:DisableHitTest()
			LayoutHelpers.AtLeftIn(t, uiRoot, x)
			LayoutHelpers.AtTopIn(t, uiRoot, -12)
		end

		CreateText("P", col0+5)
		CreateText("M", col1+5)
		CreateText("C", col2+5)
		CreateText("Mass/Energy", col3)
		CreateText("PP", col4+5)
		CreateText("PM", col5+5)


		unitTypes.foreach( function(k, unitType)

			local typeUi = { }
			unitType.typeUi = typeUi

			typeUi.uiRoot = Bitmap(uiRoot)
			typeUi.uiRoot.HandleEvent = function(self, event) return OnClick(self, event, unitType) end
			typeUi.uiRoot.Width:Set(col6)
			typeUi.uiRoot.Height:Set(22)
			typeUi.uiRoot:InternalSetSolidColor('aa000000')
			typeUi.uiRoot:Hide()
			LayoutHelpers.AtLeftIn(typeUi.uiRoot, uiRoot, 0)
			LayoutHelpers.AtTopIn(typeUi.uiRoot, uiRoot, 0)

			typeUi.stratIcon = Bitmap(typeUi.uiRoot)
			iconName = '/textures/ui/common/game/strategicicons/' .. unitType.icon .. '_rest.dds'
			typeUi.stratIcon:SetTexture(iconName)
			typeUi.stratIcon.Height:Set(typeUi.stratIcon.BitmapHeight)
			typeUi.stratIcon.Width:Set(typeUi.stratIcon.BitmapWidth)			
			LayoutHelpers.AtLeftIn(typeUi.stratIcon, typeUi.uiRoot, col2 + (20-typeUi.stratIcon.Width())/2)
			LayoutHelpers.AtVerticalCenterIn(typeUi.stratIcon, typeUi.uiRoot, 0)

			typeUi.prodUnitsBox = UnitBox(typeUi, unitType, spendTypes.PROD, workerTypes.WORKING)
			LayoutHelpers.AtLeftIn(typeUi.prodUnitsBox.group, typeUi.uiRoot, col0)
			LayoutHelpers.AtVerticalCenterIn(typeUi.prodUnitsBox.group, typeUi.uiRoot, 0)

			typeUi.maintUnitsBox = UnitBox(typeUi, unitType, spendTypes.MAINT, workerTypes.WORKING)
			LayoutHelpers.AtLeftIn(typeUi.maintUnitsBox.group, typeUi.uiRoot, col1)
			LayoutHelpers.AtVerticalCenterIn(typeUi.maintUnitsBox.group, typeUi.uiRoot, 0)

			typeUi.prodPausedUnitsBox = UnitBox(typeUi, unitType, spendTypes.PROD, workerTypes.PAUSED)
			LayoutHelpers.AtLeftIn(typeUi.prodPausedUnitsBox.group, typeUi.uiRoot, col4)
			LayoutHelpers.AtVerticalCenterIn(typeUi.prodPausedUnitsBox.group, typeUi.uiRoot, 0)

			typeUi.maintPausedUnitsBox = UnitBox(typeUi, unitType, spendTypes.MAINT, workerTypes.PAUSED)
			LayoutHelpers.AtLeftIn(typeUi.maintPausedUnitsBox.group, typeUi.uiRoot, col5)
			LayoutHelpers.AtVerticalCenterIn(typeUi.maintPausedUnitsBox.group, typeUi.uiRoot, 0)

			typeUi.Clear = function() 
			
				typeUi.prodUnitsBox.check:Hide()
				typeUi.maintUnitsBox.check:Hide()
				typeUi.prodPausedUnitsBox.check:Hide()
				typeUi.maintPausedUnitsBox.check:Hide()

			end

			typeUi.massBar = Bitmap(typeUi.uiRoot)
			typeUi.massBar.Width:Set(10)
			typeUi.massBar.Height:Set(1)
			typeUi.massBar:InternalSetSolidColor('lime')
			typeUi.massBar:DisableHitTest()
			LayoutHelpers.AtLeftIn(typeUi.massBar, typeUi.uiRoot, col3)
			LayoutHelpers.AtTopIn(typeUi.massBar, typeUi.uiRoot, 6)

			typeUi.massMaintBar = Bitmap(typeUi.uiRoot)
			typeUi.massMaintBar.Width:Set(10)
			typeUi.massMaintBar.Height:Set(1)
			typeUi.massMaintBar:InternalSetSolidColor('cyan')
			typeUi.massMaintBar:DisableHitTest()
			LayoutHelpers.AtLeftIn(typeUi.massMaintBar, typeUi.uiRoot, col3)
			LayoutHelpers.AtTopIn(typeUi.massMaintBar, typeUi.uiRoot, 6)

--			typeUi.massText = UIUtil.CreateText(typeUi.uiRoot, 'M', 9, UIUtil.bodyFont)
--			typeUi.massText.Width:Set(10)
--			typeUi.massText.Height:Set(9)
--			typeUi.massText:SetNewColor('lime')
--			typeUi.massText:DisableHitTest()
--			LayoutHelpers.AtLeftIn(typeUi.massText, typeUi.uiRoot, col3)
--			LayoutHelpers.AtVerticalCenterIn(typeUi.massText, typeUi.uiRoot)

	

--			typeUi.massMaintText = UIUtil.CreateText(typeUi.uiRoot, 'M', 9, UIUtil.bodyFont)
--			typeUi.massMaintText.Width:Set(10)
--			typeUi.massMaintText.Height:Set(9)
--			typeUi.massMaintText:SetNewColor('cyan')
--			typeUi.massMaintText:DisableHitTest()			
--			LayoutHelpers.AtLeftIn(typeUi.massMaintText, typeUi.uiRoot, col4)
--			LayoutHelpers.AtVerticalCenterIn(typeUi.massMaintText, typeUi.uiRoot)
		
			typeUi.energyBar = Bitmap(typeUi.uiRoot)
			typeUi.energyBar.Width:Set(10)
			typeUi.energyBar.Height:Set(1)
			typeUi.energyBar:InternalSetSolidColor('yellow')
			typeUi.energyBar:DisableHitTest()			
			LayoutHelpers.AtLeftIn(typeUi.energyBar, typeUi.uiRoot, col3)
			LayoutHelpers.AtTopIn(typeUi.energyBar, typeUi.uiRoot, 10)

			typeUi.energyMaintBar = Bitmap(typeUi.uiRoot)
			typeUi.energyMaintBar.Width:Set(10)
			typeUi.energyMaintBar.Height:Set(1)
			typeUi.energyMaintBar:InternalSetSolidColor('orange')
			typeUi.energyMaintBar:DisableHitTest()
			LayoutHelpers.AtLeftIn(typeUi.energyMaintBar, typeUi.uiRoot, col3)
			LayoutHelpers.AtTopIn(typeUi.energyMaintBar, typeUi.uiRoot, 10)

--			typeUi.energyText = UIUtil.CreateText(typeUi.uiRoot, 'E', 9, UIUtil.bodyFont)
--			typeUi.energyText.Width:Set(10)
--			typeUi.energyText.Height:Set(9)
--			typeUi.energyText:SetNewColor('yellow')
--			typeUi.energyText:DisableHitTest()			
--			LayoutHelpers.AtLeftIn(typeUi.energyText, typeUi.uiRoot, col5)
--			LayoutHelpers.AtVerticalCenterIn(typeUi.energyText, typeUi.uiRoot)

--			typeUi.energyMaintText = UIUtil.CreateText(typeUi.uiRoot, 'E', 9, UIUtil.bodyFont)
--			typeUi.energyMaintText.Width:Set(10)
--			typeUi.energyMaintText.Height:Set(9)
--			typeUi.energyMaintText:SetNewColor('orange')
--			typeUi.energyMaintText:DisableHitTest()
--			LayoutHelpers.AtLeftIn(typeUi.energyMaintText, typeUi.uiRoot, col6)
--			LayoutHelpers.AtVerticalCenterIn(typeUi.energyMaintText, typeUi.uiRoot)

			unitType.usage["Mass"] = {
				bar = typeUi.massBar,
				maintBar = typeUi.massMaintBar,
				text = typeUi.massText,
				maintText = typeUi.massMaintText,
			}

			unitType.usage["Energy"] = {
				bar = typeUi.energyBar,
				maintBar = typeUi.energyMaintBar,
				text = typeUi.energyText,
				maintText = typeUi.energyMaintText,
			}

			typeUi.massBar:Hide()
			typeUi.massMaintBar:Hide()
			typeUi.energyBar:Hide()
			typeUi.energyMaintBar:Hide()

			


		end )


		UIP.test.beat = DoUpdate
		GameMain.AddBeatFunction(UIP.test.beat)

		DoUpdate()
		local units = GetSelectedUnits()
		if (units ~= nil) then

			local fu = units[1]
			LOG(fu:GetEntityId())
--			fu.GetCustomName = function()
--				return "ABVC"
--			end
--			for i = 0,8 do
--				local val = true
--				--if i ~= 0 then val = false end
--				ToggleScriptBit(units, i, val)
--			end

			for i = 0,8 do
				ToggleScriptBit(units, i, true)
			end

--			local wv = import('/lua/ui/game/worldview.lua').GetWorldViews()["WorldCamera"];
--			local posA = wv:Project(fu:GetPosition())


--			local UserDecal = import('/lua/user/UserDecal.lua').UserDecal
--			local s = UserDecal { }
--			local t2 = '/mods/ui-party/textures/entry.png'
--			--local t2 = '/mods/ui-party/textures/entry7.png'
--			s:SetTexture(t2)
--			s:SetPositionByScreen(posA)
--			local w = 15
--			s:SetScale(VECTOR3(w, 0.5, w))



		end

		-- #### this is how you can replace a unit's implementation. Not sure exactly when to do it tho
		-- 	local oldGED = fu.GetEconData
		-- 	fu.GetEconData = function(self)
		-- 		local r = oldGED(self)
		-- 		r.massConsumed = 1200
		-- 		r.massRequested = 1200
		-- 		return r
		-- 	end
		-- 	LOG(repr(fu:GetEconData()))

		-- 	LOG(repr(fu:GetMissileInfo()))
		-- 	LOG(UserUnit)
		-- 	LOG(repr(from(units).first():GetEconData()))
		-- 	if (units ~= nil) then
		-- 		local blueprints = from(units).select(function(k, u) return u:GetBlueprint(); end).distinct()
		-- 		local str = ''
		-- 		blueprints.foreach(function(k,v)	
		-- 			str = str .. "+inview " .. v.BlueprintId .. ","
		-- 		end)
		-- 		LOG(str)
		-- 		ConExecute("Ui_SelectByCategory " .. str)
		-- 		--UI_SelectByCategory("+inview", "*")
		-- 	end

		-- PlaySound(Sound({Bank = 'Interface', Cue = 'X_Main_Menu_On'})) --!!
		-- PlaySound(Sound({Bank = 'Interface', Cue = 'UI_Announcement_Open'}))
		-- PlaySound(Sound({Bank = 'Interface', Cue = 'UI_END_Game_Victory'}))
		-- PlaySound(Sound({Bank = 'Interface', Cue = 'UI_Economy_Rollover'}))
		-- PlaySound(Sound({Bank = 'Interface', Cue = 'UI_MFD_checklist'}))
		-- PlaySound(Sound({Bank = 'Interface', Cue = 'UI_Opt_Mini_Button_Over'}))
		-- PlaySound(Sound({Bank = 'Interface', Cue = 'UI_Opt_Mini_Button_Click'}))
		-- PlaySound(Sound({Bank = 'Interface', Cue = 'UI_IG_Camera_Move'}))
		-- PlaySound(Sound({Bank = 'Interface', Cue = 'UI_Diplomacy_Open'})) --!!
		-- PlaySound(Sound({Cue = "UI_Score_Window_Open", Bank = "Interface"}))
		-- PlaySound(Sound({Cue = "UI_Score_Window_Close", Bank = "Interface"}))
		-- PlaySound(Sound({Cue = "AMB_SER_OP_Briefing", Bank = "AmbientTest",}))
		-- PlaySound(Sound({Cue = "UI_Tab_Rollover_01", Bank = "Interface",}))
		-- PlaySound(Sound({Cue = "UI_Tab_Click_01", Bank = "Interface",}))

		-- local sound = Sound({Cue = 'UI_Menu_Error_01', Bank = 'Interface',})
		-- PlaySound(sound)
		-- PlaySound(Sound({Bank = 'Interface', Cue = 'UI_Tab_Rollover_01'}))
		-- print(UnitHelper.GetUnitName(u) .. " complete")

	end )

	LOG("UI PARTY RESULT: ", a, b)
end

Invoke()

