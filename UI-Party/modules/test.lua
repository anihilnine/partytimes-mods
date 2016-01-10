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

function safeLog(o)
	if o == nil then
		LOG("nil")
		return
	end

	for k, v in o do
		LOG(k, v)
	end

end

function LogUnit(o)
	if o == nil then
		LOG("nil")
		return
	end

	LOG(o:GetEntityId())
	LOG(o:GetBlueprint().Description)
end

function VECTOR3(x, y, z)
	return { x, y, z, type = 'VECTOR3' }
end


		
-- eg: ArmyAnnounce(1, 'Holy snake balls batmap', 'xxx')
function ArmyAnnounce(armyID, text, textDesc)
	local textFull = text .. ' ' ..(textDesc or '')

	local Group = import('/lua/maui/group.lua').Group

	local LayoutHelpers = import('/lua/maui/layouthelpers.lua')

	local group = Group(GetFrame(0))
	group.Depth:Set(99)
	LayoutHelpers.AtLeftTopIn(group, GetFrame(0), 0, 0)
	group.Height:Set(100)
	group.Width:Set(100)

	import('/lua/ui/game/announcement.lua').CreateAnnouncement(LOC(text), group, textDesc)
end

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
		if selectedUnitType ~= nil then
			selectedUnitType.typeUi.uiRoot:InternalSetSolidColor('aa000000')
		end
		selectedUnitType = unitType
		SelectUnits(unitType.units)
	end

	if hoverUnitType ~= nil then 
		hoverUnitType.typeUi.uiRoot:InternalSetSolidColor('aa660000')
	end
	if selectedUnitType~= nil then 
		UIP.test.ui.textLabel:SetText(selectedUnitType.name)
		selectedUnitType.typeUi.uiRoot:InternalSetSolidColor('ff660000')
	end
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
		unitType.units = { }
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
			isMaint = true
			-- consType = CONSTRUCTION
			-- workProgressOnUnit[unit:GetFocus():GetEntityId()] = unit:GetWorkProgress() --it should be only set in the context of the "name" generated"
		else
			-- prefix = ""
			unitToGetDataFrom = unit
			isMaint = false
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
					rType.usage = rType.usage + usage
					unitTypeUsage.usage = unitTypeUsage.usage + usage
				else
					rType.maintUsage = rType.maintUsage + usage
					unitTypeUsage.maintUsage = unitTypeUsage.maintUsage + usage
				end
				unitHasUsage = true
			end

			-- 		if (usage ~= 0) then
			-- 			LOG(unitType.name, usage, rType.name)	
			-- 		end

		end )

		if unitHasUsage then
			table.insert(unitType.units, unit)
		end
	end )

	-- update ui
	local relayoutRequired = false
	unitTypes.foreach( function(k, unitType)
		resourceTypes.foreach( function(k, rType)
			local unitTypeUsage = unitType.usage[rType.name]
			local rTypeUsageTotal = rType.usage + rType.maintUsage
			if rTypeUsageTotal == 0 then
				unitTypeUsage.bar.Width:Set(0)
				unitTypeUsage.maintBar.Width:Set(0)
				unitTypeUsage.text:SetText("")
				unitTypeUsage.maintText:SetText("")
				unitTypeUsage.square:SetAlpha(0)
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
					relayoutRequired = true
					LOG("Y")
				end

				unitTypeUsage.bar.Width:Set(bv)
				unitTypeUsage.maintBar.Width:Set(bmv)
				local r = unitTypeUsage.bar.Right() + 1
				if bv == 0 then r = unitTypeUsage.bar.Left() end
				unitTypeUsage.maintBar.Left:Set(r)
				-- 		unitTypeUsage.text:SetText(string.format("%4.0f", unitTypeUsage.usage))

				local str = unitTypeUsage.usage
				if (str == 0) then str = "" else str = string.format("%10.3f", str) end
				unitTypeUsage.text:SetText(str)

				local str = unitTypeUsage.maintUsage
				if (str == 0) then str = "" else str = string.format("%10.3f", str) end
				unitTypeUsage.maintText:SetText(str)

				unitTypeUsage.square:SetAlpha((bv+bmv)/100)

			end
		end )
	end )

	if relayoutRequired then
		LOG("hi")
		--UIP.test.ui.Left:Set(UIP.test.ui.Left()+10)
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
			{ name = "ACU", category = categories.SUBCOMMANDER, icon = "icon_commander_generic", spacer = 0 },
			{ name = "Engineers", category = categories.ENGINEER, icon = "icon_land_engineer", spacer = 20 },

			{ name = "Everything", category = categories.ALLUNITS, icon = "strat_attack_ping", spacer = 0 },
		} )

		unitTypes.foreach( function(k, unitType)
			unitType.usage = { }
		end )

		
		local col2 = 45
		local col3 = col2+100
		local col4 = col3+45
		local col5 = col4+45
		local col6 = col5+45
		local col7 = col6+45

		local uiRoot = Bitmap(GetFrame(0))
		UIP.test.ui = uiRoot
		uiRoot.Width:Set(42)
		uiRoot.Width:Set(330)
		uiRoot.Height:Set(100)
		uiRoot.Left:Set(170)
		uiRoot.Top:Set(110)
		uiRoot.Depth:Set(99)
		uiRoot:DisableHitTest()
		--uiRoot:InternalSetSolidColor('aa000000')
		
		uiRoot.textLabel = UIUtil.CreateText(uiRoot, 'Eco Demo Thing', 15, UIUtil.bodyFont)
		uiRoot.textLabel.Width:Set(10)
		uiRoot.textLabel.Height:Set(9)
		uiRoot.textLabel:SetNewColor('gray')
		uiRoot.textLabel:DisableHitTest()
		LayoutHelpers.AtLeftIn(uiRoot.textLabel, uiRoot, 0)
		LayoutHelpers.AtTopIn(uiRoot.textLabel, uiRoot, -25)

		--uiRoot.SetAlpha(0.9)
		local rightBar = Bitmap(uiRoot)
		rightBar.Width:Set(2)
		rightBar:InternalSetSolidColor('33ffffff')
		rightBar:DisableHitTest()
		LayoutHelpers.AtLeftIn(rightBar, uiRoot, 145)
		LayoutHelpers.AtTopIn(rightBar, uiRoot, 0)
		LayoutHelpers.AtBottomIn(rightBar, uiRoot, 0)

		unitTypes.foreach( function(k, unitType)

			local typeUi = { }
			unitType.typeUi = typeUi

			typeUi.uiRoot = Bitmap(uiRoot)
			typeUi.uiRoot.HandleEvent = function(self, event) OnClick(self, event, unitType) end
			typeUi.uiRoot.Width:Set(col7)
			typeUi.uiRoot.Height:Set(22)
			typeUi.uiRoot:InternalSetSolidColor('aa000000')
			typeUi.uiRoot:Hide()
			LayoutHelpers.AtLeftIn(typeUi.uiRoot, uiRoot, 0)
			LayoutHelpers.AtTopIn(typeUi.uiRoot, uiRoot, 0)

			-- local buttonBackgroundName = UIUtil.SkinnableFile('/game/avatar-factory-panel/avatar-s-e-f_bmp.dds')
			typeUi.stratIcon = Bitmap(typeUi.uiRoot)
			iconName = '/textures/ui/common/game/strategicicons/' .. unitType.icon .. '_rest.dds'
			typeUi.stratIcon:SetTexture(iconName)
			typeUi.stratIcon.Height:Set(typeUi.stratIcon.BitmapHeight)
			typeUi.stratIcon.Width:Set(typeUi.stratIcon.BitmapWidth)			
			LayoutHelpers.AtLeftIn(typeUi.stratIcon, typeUi.uiRoot, (20-typeUi.stratIcon.Width())/2)
			LayoutHelpers.AtVerticalCenterIn(typeUi.stratIcon, typeUi.uiRoot, 0)
			--typeUi.uiRoot.Height:Set(typeUi.stratIcon.Height())
								
			typeUi.massSquare = Bitmap(typeUi.uiRoot)
			typeUi.massSquare.Width:Set(8)
			typeUi.massSquare.Height:Set(8)
			typeUi.massSquare:InternalSetSolidColor('lime')
			typeUi.massSquare:DisableHitTest()
			LayoutHelpers.AtLeftIn(typeUi.massSquare, typeUi.uiRoot, 20)
			LayoutHelpers.AtVerticalCenterIn(typeUi.massSquare, typeUi.uiRoot, 0)

			typeUi.massBar = Bitmap(typeUi.uiRoot)
			typeUi.massBar.Width:Set(10)
			typeUi.massBar.Height:Set(1)
			typeUi.massBar:InternalSetSolidColor('lime')
			typeUi.massBar:DisableHitTest()
			LayoutHelpers.AtLeftIn(typeUi.massBar, typeUi.uiRoot, col2)
			LayoutHelpers.AtTopIn(typeUi.massBar, typeUi.uiRoot, 6)

			typeUi.massMaintBar = Bitmap(typeUi.uiRoot)
			typeUi.massMaintBar.Width:Set(10)
			typeUi.massMaintBar.Height:Set(1)
			typeUi.massMaintBar:InternalSetSolidColor('cyan')
			typeUi.massMaintBar:DisableHitTest()
			LayoutHelpers.AtLeftIn(typeUi.massMaintBar, typeUi.uiRoot, col2)
			LayoutHelpers.AtTopIn(typeUi.massMaintBar, typeUi.uiRoot, 6)

			typeUi.massText = UIUtil.CreateText(typeUi.uiRoot, 'M', 9, UIUtil.bodyFont)
			typeUi.massText.Width:Set(10)
			typeUi.massText.Height:Set(9)
			typeUi.massText:SetNewColor('lime')
			typeUi.massText:DisableHitTest()
			LayoutHelpers.AtLeftIn(typeUi.massText, typeUi.uiRoot, col3)
			LayoutHelpers.AtVerticalCenterIn(typeUi.massText, typeUi.uiRoot)

			typeUi.massMaintText = UIUtil.CreateText(typeUi.uiRoot, 'M', 9, UIUtil.bodyFont)
			typeUi.massMaintText.Width:Set(10)
			typeUi.massMaintText.Height:Set(9)
			typeUi.massMaintText:SetNewColor('cyan')
			typeUi.massMaintText:DisableHitTest()			
			LayoutHelpers.AtLeftIn(typeUi.massMaintText, typeUi.uiRoot, col4)
			LayoutHelpers.AtVerticalCenterIn(typeUi.massMaintText, typeUi.uiRoot)

			typeUi.energySquare = Bitmap(typeUi.uiRoot)
			typeUi.energySquare.Width:Set(8)
			typeUi.energySquare.Height:Set(8)
			typeUi.energySquare:InternalSetSolidColor('yellow')
			typeUi.energySquare:DisableHitTest()
			LayoutHelpers.AtLeftIn(typeUi.energySquare, typeUi.uiRoot, 30)
			LayoutHelpers.AtVerticalCenterIn(typeUi.energySquare, typeUi.uiRoot, 0)

			typeUi.energyBar = Bitmap(typeUi.uiRoot)
			typeUi.energyBar.Width:Set(10)
			typeUi.energyBar.Height:Set(1)
			typeUi.energyBar:InternalSetSolidColor('yellow')
			typeUi.energyBar:DisableHitTest()			
			LayoutHelpers.AtLeftIn(typeUi.energyBar, typeUi.uiRoot, col2)
			LayoutHelpers.AtTopIn(typeUi.energyBar, typeUi.uiRoot, 8)

			typeUi.energyMaintBar = Bitmap(typeUi.uiRoot)
			typeUi.energyMaintBar.Width:Set(10)
			typeUi.energyMaintBar.Height:Set(1)
			typeUi.energyMaintBar:InternalSetSolidColor('orange')
			typeUi.energyMaintBar:DisableHitTest()
			LayoutHelpers.AtLeftIn(typeUi.energyMaintBar, typeUi.uiRoot, col2)
			LayoutHelpers.AtTopIn(typeUi.energyMaintBar, typeUi.uiRoot, 8)

			typeUi.energyText = UIUtil.CreateText(typeUi.uiRoot, 'E', 9, UIUtil.bodyFont)
			typeUi.energyText.Width:Set(10)
			typeUi.energyText.Height:Set(9)
			typeUi.energyText:SetNewColor('yellow')
			typeUi.energyText:DisableHitTest()			
			LayoutHelpers.AtLeftIn(typeUi.energyText, typeUi.uiRoot, col5)
			LayoutHelpers.AtVerticalCenterIn(typeUi.energyText, typeUi.uiRoot)

			typeUi.energyMaintText = UIUtil.CreateText(typeUi.uiRoot, 'E', 9, UIUtil.bodyFont)
			typeUi.energyMaintText.Width:Set(10)
			typeUi.energyMaintText.Height:Set(9)
			typeUi.energyMaintText:SetNewColor('orange')
			typeUi.energyMaintText:DisableHitTest()
			LayoutHelpers.AtLeftIn(typeUi.energyMaintText, typeUi.uiRoot, col6)
			LayoutHelpers.AtVerticalCenterIn(typeUi.energyMaintText, typeUi.uiRoot)

			unitType.usage["Mass"] = {
				bar = typeUi.massBar,
				maintBar = typeUi.massMaintBar,
				text = typeUi.massText,
				maintText = typeUi.massMaintText,
				square = typeUi.massSquare
			}

			unitType.usage["Energy"] = {
				bar = typeUi.energyBar,
				maintBar = typeUi.energyMaintBar,
				text = typeUi.energyText,
				maintText = typeUi.energyMaintText,
				square = typeUi.energySquare
			}

			typeUi.massBar:Hide()
			typeUi.massMaintBar:Hide()
			typeUi.energyBar:Hide()
			typeUi.energyMaintBar:Hide()
			typeUi.massText:Hide()
			typeUi.energyText:Hide()
			typeUi.massMaintText:Hide()
			typeUi.energyMaintText:Hide()

			


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


			local wv = import('/lua/ui/game/worldview.lua').GetWorldViews()["WorldCamera"];
			local posA = wv:Project(fu:GetPosition())


			local UserDecal = import('/lua/user/UserDecal.lua').UserDecal
			local s = UserDecal { }
			local t2 = '/mods/ui-party/textures/entry.png'
			--local t2 = '/mods/ui-party/textures/entry7.png'
			s:SetTexture(t2)
			s:SetPositionByScreen(posA)
			local w = 15
			s:SetScale(VECTOR3(w, 0.5, w))


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

