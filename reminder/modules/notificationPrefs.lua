local Prefs = import('/lua/user/prefs.lua')
local savedPrefs = Prefs.GetFromCurrentProfile("reminder_settings")


function init()
	-- settings
	if not savedPrefs then
		savedPrefs = {}
	end
	
	if not savedPrefs.global then
		savedPrefs.global = {
			xOffset = 2,
			yOffset = 156,
			startDelay = 60,
			duration = 5,
			minRetriggerDelay = 15,
			isVisible = true,
			isMinimizable = true,
			isDraggable = true,
			isButtonsSetLeft = true,
			isNotificationsToPositiveX = true,
			isPlaySound = false,
			isClickEvent = true,
		}
	end
	
	if savedPrefs.notification == nil then
		savedPrefs.notification = {}
	end
	
	-- correct x/y if outside the window
	if (savedPrefs.global.xOffset < 0 or savedPrefs.global.xOffset > GetFrame(0).Width()) then
		savedPrefs.global.xOffset = GetFrame(0).Width()/2
	end
	if (savedPrefs.global.yOffset < 0 or savedPrefs.global.yOffset > GetFrame(0).Height()) then
		savedPrefs.global.yOffset = GetFrame(0).Height()/2
	end
	
	--removing old stuff
	savedPrefs.notificationIsActive = nil
	savedPrefs.xOffset = nil
	savedPrefs.yOffset = nil
	savedPrefs.isVisible = nil
	
	savePreferences()
end


function removeNotificationsNotInTables(t1, t2)
	for id,value in savedPrefs.notification do
		if not (isInTable(id, t1) or isInTable(id, t2)) then
			LOG('Notification Mod: '..id..' not found anymore, is removed from game.prefs')
			savedPrefs.notification[id] = nil
		end
	end
	Prefs.SavePreferences()
end


function isInTable(id, t)
	for id2,_ in t do
		if(id == id2) then
			return true
		end
	end
	return false
end


function savePreferences()
	Prefs.SetToCurrentProfile("reminder_settings", savedPrefs)
	Prefs.SavePreferences()
end


---------


function getPreferences()
	return savedPrefs
end


function setIsVisible(bool)
	savedPrefs.global.isVisible = bool
	savePreferences()
end


function setAllGlobalValues(t)
	for id, value in t do
		savedPrefs.global[id] = value
	end
	savePreferences()
end


function setXYvalues(posX, posY)
	savedPrefs.global.xOffset = posX
	savedPrefs.global.yOffset = posY
	savePreferences()
end


function setNotificationState(configId, t)
	if not savedPrefs.notification[configId] then
		savedPrefs.notification[configId] = {}
	end
	if not savedPrefs.notification[configId].states then
		savedPrefs.notification[configId].states = {}
	end
	for id, value in t do
		savedPrefs.notification[configId].states[id] = value
	end
	savePreferences()
end


function setAllNotificationStates(t)
	for id,subT in t do
		setNotificationState(id, subT.states)
	end
end