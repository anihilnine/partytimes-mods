local modpath = '/mods/ui-plus'
local utils = import(modpath..'/modules/notificationUtils.lua')
local notificationUi = import(modpath..'/modules/notificationUi.lua')

local LayoutHelpers = import('/lua/maui/layouthelpers.lua')
local UIUtil = import('/lua/ui/uiutil.lua')
local Button = import('/lua/maui/button.lua').Button
local Bitmap = import('/lua/maui/bitmap.lua').Bitmap
local Checkbox = import('/lua/maui/checkbox.lua').Checkbox
local IntegerSlider = import('/lua/maui/slider.lua').IntegerSlider

local notificationPrefs = import(modpath..'/modules/notificationPrefs.lua')
local savedPrefs = nil
local curPrefs = nil

local uiPanel = {
	main = nil,
	okButton = nil,
	cancelButton = nil,
}

local uiPanelSettings = {
	height = 0,
	width = 600,
	additionalHeightTop = 50,
	additionalHeightOptions = 220,
	additionalHeightBottom = 40,
	options = {
		height = 15,
		distance = 4
	},
	textSize = {
		headline = 20,
		section = 16,
		option = 12,
	},
}


function createPrefsUi()
	if uiPanel.main then
		uiPanel.main:Destroy()
		uiPanel.main = nil
		return
	end

	-- copy configs to local, to not mess with the original ones until they should save
	savedPrefs = notificationPrefs.getPreferences()
	curPrefs = {
		global = {},
		notification = {}
	}
	for id, bool in savedPrefs.global do
		curPrefs.global[id] = bool
	end
	for id, t in savedPrefs.notification do
		curPrefs.notification[id] = {}
		for id2, bool in t do
			curPrefs.notification[id][id2] = bool
		end
	end
	
	-- make the ui	
	createMainPanel()
	curY = 0
	 klnbmb +
	LayoutHelpers.CenteredAbove(UIUtil.CreateText(uiPanel.main, "Preferences", uiPanelSettings.textSize.headline, UIUtil.bodyFont), uiPanel.main, -curY-30)
	
	curY = curY + uiPanelSettings.additionalHeightTop + 15
	
	LayoutHelpers.CenteredAbove(UIUtil.CreateText(uiPanel.main, "Global", uiPanelSettings.textSize.section, UIUtil.bodyFont), uiPanel.main, -curY)
	curY = curY + 15
	createOptions(curY)
	
	curY = curY + uiPanelSettings.additionalHeightOptions - 30
	
	LayoutHelpers.CenteredAbove(UIUtil.CreateText(uiPanel.main, "Notifications", uiPanelSettings.textSize.section, UIUtil.bodyFont), uiPanel.main, -curY+10)
	createNotificationList(curY)
	
	createOkCancelButtons()
end


---------------------------------------------------------------------


function createMainPanel()
	uiPanelSettings.height = (utils.countTableElements(savedPrefs.notification)/2) * (uiPanelSettings.options.height + uiPanelSettings.options.distance)+ uiPanelSettings.options.distance + uiPanelSettings.additionalHeightBottom + uiPanelSettings.additionalHeightTop + uiPanelSettings.additionalHeightOptions + 20
	posX = GetFrame(0).Width()/2 - uiPanelSettings.width/2
	posY = GetFrame(0).Height()/2 - uiPanelSettings.height/2
	
	uiPanel.main = Bitmap(GetFrame(0))
	uiPanel.main.Depth:Set(99)
	LayoutHelpers.AtLeftTopIn(uiPanel.main, GetFrame(0), posX, posY)
	uiPanel.main.Height:Set(uiPanelSettings.height)
	uiPanel.main.Width:Set(uiPanelSettings.width)
	uiPanel.main:SetTexture('/textures/ui/common/game/economic-overlay/econ_bmp_m.dds')
	uiPanel.main:Show()
end


function createOptions(posY)	
	---- left side options
	local curY = posY
	local curX = 0
	
	-- isDraggable
	LayoutHelpers.AtLeftTopIn(UIUtil.CreateText(uiPanel.main, "allow dragging", uiPanelSettings.textSize.option, UIUtil.bodyFont), uiPanel.main, curX+30, curY)
	createSettingCheckbox(curX+10, curY+2, 13, {"global", "isDraggable"})
	curY = curY + uiPanelSettings.options.height + uiPanelSettings.options.distance
	
	-- isMinimizable
	LayoutHelpers.AtLeftTopIn(UIUtil.CreateText(uiPanel.main, "allow quick minimizing", uiPanelSettings.textSize.option, UIUtil.bodyFont), uiPanel.main, curX+30, curY)
	createSettingCheckbox(curX+10, curY+2, 13, {"global", "isMinimizable"})
	curY = curY + uiPanelSettings.options.height + uiPanelSettings.options.distance

	-- isVisible
	LayoutHelpers.AtLeftTopIn(UIUtil.CreateText(uiPanel.main, "notifications are visible", uiPanelSettings.textSize.option, UIUtil.bodyFont), uiPanel.main, curX+30, curY)
	createSettingCheckbox(curX+10, curY+2, 13, {"global", "isVisible"})
	curY = curY + uiPanelSettings.options.height + uiPanelSettings.options.distance
	
	-- isButtonsSetLeft
	LayoutHelpers.AtLeftTopIn(UIUtil.CreateText(uiPanel.main, "buttons on left side", uiPanelSettings.textSize.option, UIUtil.bodyFont), uiPanel.main, curX+30, curY)
	createSettingCheckbox(curX+10, curY+2, 13, {"global", "isButtonsSetLeft"})
	curY = curY + uiPanelSettings.options.height + uiPanelSettings.options.distance	
	
	-- isNotificationsToPositiveX
	LayoutHelpers.AtLeftTopIn(UIUtil.CreateText(uiPanel.main, "notifications below buttons", uiPanelSettings.textSize.option, UIUtil.bodyFont), uiPanel.main, curX+30, curY)
	createSettingCheckbox(curX+10, curY+2, 13, {"global", "isNotificationsToPositiveX"})
	curY = curY + uiPanelSettings.options.height + uiPanelSettings.options.distance	

	-- isPlaySound
--	LayoutHelpers.AtLeftTopIn(UIUtil.CreateText(uiPanel.main, "allow sounds", uiPanelSettings.textSize.option, UIUtil.bodyFont), uiPanel.main, curX+30, curY)
--	createSettingCheckbox(curX+10, curY+2, 13, {"global", "isPlaySound"})
--	curY = curY + uiPanelSettings.options.height + uiPanelSettings.options.distance	
	
	-- isClickEvent
	LayoutHelpers.AtLeftTopIn(UIUtil.CreateText(uiPanel.main, "allow click events", uiPanelSettings.textSize.option, UIUtil.bodyFont), uiPanel.main, curX+30, curY)
	createSettingCheckbox(curX+10, curY+2, 13, {"global", "isClickEvent"})
	curY = curY + uiPanelSettings.options.height + uiPanelSettings.options.distance	
	
	---- right side options
	curY = posY
	curX = uiPanelSettings.width / 2
	
	createSettingsSliderWithText(curX, curY, "notification duration: ", uiPanelSettings.width/2, 1, 20, 1, {"global", "duration"})
	curY = curY + 2.5*(uiPanelSettings.options.height + uiPanelSettings.options.distance)
	
	createSettingsSliderWithText(curX, curY, "min retrigger delay: ", uiPanelSettings.width/2, 1, 24, 5, {"global", "minRetriggerDelay"})
	curY = curY + 2.5*(uiPanelSettings.options.height + uiPanelSettings.options.distance)
	
	createSettingsSliderWithText(curX, curY, "start delay (next game): ", uiPanelSettings.width/2, 1, 20, 30, {"global", "startDelay"})
	curY = curY + 2.5*(uiPanelSettings.options.height + uiPanelSettings.options.distance)
end


function createNotificationList(posY)
	count = 0
	local curX = 0
	local curY = posY
	for id, value in curPrefs.notification do
		local curId = id
		LayoutHelpers.AtLeftTopIn(UIUtil.CreateText(uiPanel.main, utils.getFilenameWithoutDir(id), uiPanelSettings.textSize.option, UIUtil.bodyFont), uiPanel.main, curX+30, curY)
		
		createSettingCheckbox(curX+10, curY+2, 13, {"notification", curId, "states", "isActive"})
		
		if(utils.modulo(count, 2) == 0) then
			curX = uiPanelSettings.width / 2
		else
			curX = 0
			curY = curY + uiPanelSettings.options.height + uiPanelSettings.options.distance
		end
		count = count+1
	end
end


function createOkCancelButtons()
	okCancelButtonHeight = uiPanelSettings.additionalHeightBottom-15
	
	uiPanel.okButton = Button(uiPanel.main, modpath.."/textures/checked_up.png", modpath.."/textures/checked_down.png", modpath.."/textures/checked_over.png", modpath.."/textures/checked_up.png")
	LayoutHelpers.AtLeftTopIn(uiPanel.okButton, uiPanel.main, uiPanelSettings.width-2*okCancelButtonHeight-15, uiPanelSettings.height-okCancelButtonHeight-10)
	uiPanel.okButton.Height:Set(okCancelButtonHeight)
	uiPanel.okButton.Width:Set(okCancelButtonHeight)
	uiPanel.okButton.OnClick = function(self)
		notificationPrefs.setAllNotificationStates(curPrefs.notification)
		notificationPrefs.setAllGlobalValues(curPrefs.global)
		notificationUi.reloadAndApplyGlobalConfigs()
		uiPanel.main:Destroy()
		uiPanel.main = nil
	end
	
	uiPanel.cancelButton = Button(uiPanel.main, modpath.."/textures/unchecked_up.png", modpath.."/textures/unchecked_down.png", modpath.."/textures/unchecked_over.png", modpath.."/textures/unchecked_up.png")
	LayoutHelpers.AtLeftTopIn(uiPanel.cancelButton, uiPanel.main, uiPanelSettings.width-okCancelButtonHeight-5, uiPanelSettings.height-okCancelButtonHeight-10)
	uiPanel.cancelButton.Height:Set(okCancelButtonHeight)
	uiPanel.cancelButton.Width:Set(okCancelButtonHeight)
	uiPanel.cancelButton.OnClick = function(self)
		uiPanel.main:Destroy()
		uiPanel.main = nil
	end
end


---------------------------------------------------------------------


function createSettingCheckbox(posX, posY, size, args)
	local value = curPrefs
	for _,v in args do
		value = value[v]
	end
	
	local argsCopy = args

	local box = UIUtil.CreateCheckbox(uiPanel.main,
		modpath.."/textures/checkbox_inactive_up.png",
		modpath.."/textures/checkbox_active_up.png",
		modpath.."/textures/checkbox_inactive_over.png",
		modpath.."/textures/checkbox_active_over.png",
		modpath.."/textures/checkbox_inactive_disabled.png",
		modpath.."/textures/checkbox_active_disabled.png",
		nil, nil
	)
	box.Height:Set(size)
	box.Width:Set(size)
	
	box:SetCheck(value, true)
	
	box.OnClick = function(self)
		if(box:IsChecked()) then
			setCurPrefByArgs(argsCopy, false)
			value = false
			box:SetCheck(false, true)
		else
			setCurPrefByArgs(argsCopy, true)
			value = true
			box:SetCheck(true, true)
		end
	end
	
	LayoutHelpers.AtLeftTopIn(box, uiPanel.main, posX, posY+1)
end


function createSettingsSliderWithText(posX, posY, text, size, minVal, maxVal, valMult, args)
	-- name
	LayoutHelpers.AtLeftTopIn(UIUtil.CreateText(uiPanel.main, text, uiPanelSettings.textSize.option, UIUtil.bodyFont), uiPanel.main, posX, posY)
	
	-- value
	local value = curPrefs
	for i, v in args do
		value = value[v]
	end
	if value < minVal*valMult then
		value = minVal*valMult
	elseif value > maxVal*valMult then
		value = maxVal*valMult
	end
	
	-- value text
	local valueText = UIUtil.CreateText(uiPanel.main, value, uiPanelSettings.textSize.option, UIUtil.bodyFont)
	LayoutHelpers.AtLeftTopIn(valueText, uiPanel.main, posX+(size/2), posY)
	
	local slider = IntegerSlider(uiPanel.main, false, minVal,maxVal, 1, UIUtil.SkinnableFile('/slider02/slider_btn_up.dds'), UIUtil.SkinnableFile('/slider02/slider_btn_over.dds'), UIUtil.SkinnableFile('/slider02/slider_btn_down.dds'), UIUtil.SkinnableFile('/slider02/slider-back_bmp.dds'))  
	LayoutHelpers.AtLeftTopIn(slider, uiPanel.main, posX, posY + uiPanelSettings.options.height + uiPanelSettings.options.distance)
	slider:SetValue(value/valMult)
	slider.OnValueChanged = function(self, newValue)
		valueText:SetText(newValue*valMult)
		setCurPrefByArgs(args, newValue*valMult)
	end
end


function setCurPrefByArgs(args, value)
	num = table.getn(args)
	if num==2 then
		curPrefs[args[1]][args[2]] = value
	end
	if num==3 then
		curPrefs[args[1]][args[2]][args[3]] = value
	end
	if num==4 then
		curPrefs[args[1]][args[2]][args[3]][args[4]] = value
	end
end