local modpath = '/mods/ui-party'
local notificationPrefs = import(modpath..'/modules/notificationPrefs.lua')
local notificationUtils = import(modpath..'/modules/notificationUtils.lua')

local LayoutHelpers = import('/lua/maui/layouthelpers.lua')
local UIUtil = import('/lua/ui/uiutil.lua')
local Group = import('/lua/maui/group.lua').Group
local Button = import('/lua/maui/button.lua').Button
local Bitmap = import('/lua/maui/bitmap.lua').Bitmap
local Dragger = import('/lua/maui/dragger.lua').Dragger


local savedPrefs = nil
local isVisible = nil
local isNotificationsToPositiveX = nil
local mainPanel = nil
local notifications = {}

local notificationPanelValues = {
	height = 60,
	width = 300,
	distance = 4,
	buttonSize = 15,
	buttonDistance = 6,
	buttonXOffset = 0
}

local buttons = {
	dragButton = nil,
	configButton = nil
}


function init()
	-- settings
	savedPrefs = notificationPrefs.getPreferences()
	isNotificationsToPositiveX = savedPrefs.global.isNotificationsToPositiveX
	isVisible = savedPrefs.global.isVisible
	
	mainPanel = Bitmap(GetFrame(0))
	mainPanel.Depth:Set(99)
	LayoutHelpers.AtLeftTopIn(mainPanel, GetFrame(0), savedPrefs.global.xOffset, savedPrefs.global.yOffset)
	mainPanel.Height:Set(notificationPanelValues.buttonSize)
	mainPanel.Width:Set(notificationPanelValues.buttonSize)
	
	addMainpanelButtons()
end


-----------------------------------------------------------------------


function reloadAndApplyGlobalConfigs()
	savedPrefs = notificationPrefs.getPreferences()
	
	isNotificationsToPositiveX = savedPrefs.global.isNotificationsToPositiveX
	resetPosY()
	
	if(savedPrefs.global.isButtonsSetLeft) then
		moveMainpanelButtons("left")
	else
		moveMainpanelButtons("right")
	end
end


function addMainpanelButtons()
	buttons.dragButton = Button(mainPanel, modpath..'/textures/drag_up.dds', modpath..'/textures/drag_down.dds', modpath..'/textures/drag_over.dds', modpath..'/textures/drag_up.dds')
	LayoutHelpers.AtLeftTopIn(buttons.dragButton, mainPanel, notificationPanelValues.buttonXOffset, 0)
	

	
	buttons.configButton = Button(mainPanel, modpath..'/textures/options_up.dds', modpath..'/textures/options_down.dds', modpath..'/textures/options_over.dds', modpath..'/textures/options_up.dds')
	LayoutHelpers.AtLeftTopIn(buttons.configButton, mainPanel, notificationPanelValues.buttonXOffset + (notificationPanelValues.buttonSize+notificationPanelValues.buttonDistance)*1, 0)
	
	buttons.dragButton.HandleEvent = function(self, event)
		if event.Type == 'ButtonPress' then
			local drag = Dragger()
			local offX = event.MouseX - self.Left()
			local offY = event.MouseY - self.Top()
			drag.OnMove = function(dragself, x, y)
				mainPanel.Left:Set(x - offX + (mainPanel.Left() - buttons.dragButton.Left()))
				mainPanel.Top:Set(y - offY)
				GetCursor():SetTexture(UIUtil.GetCursor('MOVE_WINDOW'))
			end
			drag.OnRelease = function(dragself)
				notificationPrefs.setXYvalues(self.Left(), self.Top())
				GetCursor():Reset()
				drag:Destroy()
			end
			PostDragger(self:GetRootFrame(), event.KeyCode, drag)
		end
	end

	buttons.configButton:EnableHitTest(true)
	buttons.configButton.OnClick = function(self, event)
		import(modpath..'/modules/notificationPrefsUi.lua').createPrefsUi()
	end	
	
	if not ( savedPrefs.global.isButtonsSetLeft ) then
		moveMainpanelButtons("right")
	end
end


function moveMainpanelButtons(s)
	helpDistance = notificationPanelValues.buttonSize + notificationPanelValues.buttonDistance
	helpOffsetX = 0
	
	if s == "right" then
		helpOffsetX = notificationPanelValues.width - 3*helpDistance + notificationPanelValues.buttonDistance
	end
	
	LayoutHelpers.AtLeftTopIn(buttons.dragButton, mainPanel, helpOffsetX + helpDistance*0, 0)
	LayoutHelpers.AtLeftTopIn(buttons.configButton, mainPanel, helpOffsetX + helpDistance*1, 0)
end





function setNotificationsTowardsPositiveX(bool)
	if ( isNotificationsToPositiveX == bool ) then
		return
	end
	isNotificationsToPositiveX = bool
end


-----------------------------------------------------------------------


function createNotification(data)
	if not notifications[data.id] == nil then
		removeNotification(data.id)
	end

	posY = nil
	if isNotificationsToPositiveX then
		posY  = notificationUtils.countTableElements(notifications) * (notificationPanelValues.distance + notificationPanelValues.height) + 20
	else
		posY  = (notificationUtils.countTableElements(notifications)+1) * (notificationPanelValues.distance + notificationPanelValues.height) * (-1)
	end
	
	if(notifications[data.id].clickButton) then
		notifications[data.id].clickButton:Destroy()
	end
	notifications[data.id] = getNotificationUI(data.text, data.subtext, data.icon, data.clickFunction, posY)
end


function getNotificationUI(text, subtext, icon, clickFunction, posY)
	notificationPanel = {}
	
	-- notification body
	notificationPanel.main = Bitmap(mainPanel)
	notificationPanel.main.Depth:Set(99)
	LayoutHelpers.AtLeftTopIn(notificationPanel.main, mainPanel, 0, posY)
	notificationPanel.main.Height:Set(notificationPanelValues.height)
	notificationPanel.main.Width:Set(notificationPanelValues.width)	
	notificationPanel.main:DisableHitTest(true)
	notificationPanel.main:SetTexture('/textures/ui/common/game/economic-overlay/econ_bmp_m.dds')
	
	-- icon
	notificationPanel.iconPanel = Bitmap(mainPanel)
	LayoutHelpers.AtLeftTopIn(notificationPanel.iconPanel, notificationPanel.main, 2, 2)
	notificationPanel.iconPanel.Height:Set(notificationPanelValues.height-4)
	notificationPanel.iconPanel.Width:Set(notificationPanelValues.height-4)
	notificationPanel.iconPanel:DisableHitTest(true)
	notificationPanel.iconPanel:SetTexture(icon)
	
	-- text
	notificationPanel.text = UIUtil.CreateText(notificationPanel.main, text, 20, UIUtil.bodyFont)
	notificationPanel.subtext = UIUtil.CreateText(notificationPanel.main, subtext, 14, UIUtil.bodyFont)
	LayoutHelpers.AtLeftTopIn(notificationPanel.text, notificationPanel.main, notificationPanelValues.height+10, 10)
	LayoutHelpers.AtLeftTopIn(notificationPanel.subtext, notificationPanel.main, notificationPanelValues.height+10, 35)
	notificationPanel.text:DisableHitTest(true)
	notificationPanel.subtext:DisableHitTest(true)
	
	-- click function button
	notificationPanel.clickButton = Button(mainPanel, modpath..'/textures/transparent.png', modpath..'/textures/transparent.png', modpath..'/textures/transparent.png', modpath..'/textures/transparent.png')
	LayoutHelpers.AtLeftTopIn(notificationPanel.clickButton, notificationPanel.main, 0, 0)
	notificationPanel.clickButton.Height:Set(notificationPanelValues.height)
	notificationPanel.clickButton.Width:Set(notificationPanelValues.width)
	
	notificationPanel.clickButton.OnClick = function(self, event)
		if(savedPrefs.global.isClickEvent and clickFunction and notificationPanel.clickButton) then
			clickFunction()
		end
	end
	
	if(isVisible == false) then
		notificationPanel.main:Hide()
		notificationPanel.iconPanel:Hide()
		notificationPanel.clickButton:Hide()
	else
		notificationPanel.main:Show()
		notificationPanel.iconPanel:Show()
		notificationPanel.clickButton:Show()
	end
	
	return notificationPanel
end


function removeNotification(id)
	if notifications[id] == nil then
		return
	end
	
	notifications[id].clickButton.Height:Set(0)
	notifications[id].clickButton.Width:Set(0)
	
	notifications[id].main:Destroy()
	notifications[id].iconPanel:Destroy()
	notifications[id] = nil
	resetPosY()
end


function resetPosY()
	local posY = 20
	local add = notificationPanelValues.distance + notificationPanelValues.height
	if not isNotificationsToPositiveX then
		posY = 0 - notificationPanelValues.distance - notificationPanelValues.height
		add = add * (-1)
	end
	
	for _,panel in notifications do
		LayoutHelpers.AtLeftTopIn(panel.main, mainPanel, 0, posY)
		posY = posY + add
	end
end


function showPanels(isVisible)
	for _,panel in notifications do
		if(isVisible == false) then
			panel.main:Hide()
			panel.iconPanel:Hide()
			panel.clickButton:Hide()
		else
			panel.main:Show()
			panel.iconPanel:Show()
			panel.clickButton:Show()
		end
	end
end