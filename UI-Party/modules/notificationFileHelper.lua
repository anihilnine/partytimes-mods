local modpath = '/mods/ui-party'
local notificationPrefs = import(modpath..'/modules/notificationPrefs.lua')

local prefs = notificationPrefs.getPreferences()


function getNotificationsInDir(dir)
	filesInDir = {}
	for i, file in DiskFindFiles(dir, "*") do
		LOG('Notification Mod: loading... '..file)
		table.insert(filesInDir, file)
	end
	return loadNotificationsFromFunctionAndDir(filesInDir, "")
end


function loadNotificationsFromFunctionAndDir(list, dir)
	local allNotifications = {}
	local allNotificationFiles = list
	local foundNotifications = {}
	
	prefs = notificationPrefs.getPreferences()
	
	for _,cur in allNotificationFiles do		
		conf = import(dir..cur).getFixedConfig()
		allNotifications[cur] = {}
		allNotifications[cur].filename = cur
		allNotifications[cur].id = cur
		allNotifications[cur].retriggerDelay = conf.retriggerDelay
		allNotifications[cur].blockedTimer = 0
		
		if(conf.triggerAtSeconds) then
			allNotifications[cur].triggerAtSeconds = conf.triggerAtSeconds
		end
		
		if prefs.notification[cur] == nil then
			prefs.notification[cur] = {}
		end
		if prefs.notification[cur].states == nil then
			allNotifications[cur].states = {}
			allNotifications[cur].states.isActive = true
			allNotifications[cur].states.isDisplay = true
			allNotifications[cur].states.isPlaySound = 0
			allNotifications[cur].states.isClickTriggersEvent = 0
			notificationPrefs.setNotificationState(cur, allNotifications[cur].states)
		else
			for id,_ in prefs.notification do
				allNotifications[cur][id] = prefs.notification[cur][id]
			end
		end
	end
	return allNotifications
end


function getDisabledFalseOrTrueValue(confId, defaultConf, f)
	if f then
		if defaultConf.states and defaultConf.states[confId] > 1 then
			return defaultConf.states[confId]
		end
		return 1
	end
	return 0
end


function getResource(resourceName, path)	
	--for i, file in DiskFindFiles(path, resourceName) do
	--	return file
	--end
	return path..resourceName
end



