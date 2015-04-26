local modpath = '/mods/ui-party'
local iconpath = modpath.."/notificationIcons/"
local soundpath = modpath.."/notificationSounds/"
local notificationScripts = modpath.."/notificationScripts/"
local notificationTimed = modpath.."/notificationTimed/"

local ui = import(modpath..'/modules/notificationUi.lua')

local notificationPrefs = import(modpath..'/modules/notificationPrefs.lua')
local savedPrefs = notificationPrefs.getPreferences()
local allNotifications = nil
local allTimedNotifications = nil


function init()
	WaitSeconds(1)
	
	loadNotifications()
	savedPrefs = notificationPrefs.getPreferences()
	
	WaitSeconds(savedPrefs.global.startDelay -1)

	for _,n in allNotifications do
		file = import(n.filename)
		if not (file.init == nil) then
			file.init()
		end
	end
	
	triggerNotificationChecks()
end


function loadNotifications()

	notificationPrefs.removeNotificationsNotInTables(allNotifications, allTimedNotifications)
end


function removeFaultyNotificationScripts(t)
	for i,_ in t do
		curScript = import(i)
		if not curScript then
			LOG('removed..'..i..' , script file missing')
			t[i] = nil
		end
	end
	return t
end

-- looping through all known notifactions and checking if it should trigger them
function triggerNotificationChecks()
	while(true) do
		WaitSeconds(0.1)
		savedPrefs = notificationPrefs.getPreferences()
		
		for _,n in allNotifications do
			if( savedPrefs.notification[n.id].states.isActive ) then
				n.blockedTimer = n.blockedTimer - 0.1
				if(n.blockedTimer < 0) then
					if(import(n.filename).triggerNotification()) then
						ForkThread(handleNotification, n)
						n.blockedTimer = math.max(n.retriggerDelay, savedPrefs.global.duration, savedPrefs.global.minRetriggerDelay)
					end
				else
					import(n.filename).onRetriggerDelay()
				end
			end
		end
		
		gameTime = GetGameTimeSeconds()
		for i,n in allTimedNotifications do
			if( savedPrefs.notification[n.id].states.isActive ) then
				if(n.triggerAtSeconds < gameTime) then
					ForkThread(handleNotification, n)
					if(n.retriggerDelay > 0) then
						n.triggerAtSeconds = n.triggerAtSeconds + n.retriggerDelay
					else
						allTimedNotifications[i] = nil
					end
				end
			end
		end
	end
end


function handleNotification(notification)
	notificationConfig = import(notification.filename).getRuntimeConfig()
	notification.text = notificationConfig.text
	notification.subtext = notificationConfig.subtext
	notification.clickFunction = import(notification.filename).onClick
	
--	if( savedPrefs.global.isPlaySound and notificationConfig.sound ) then
--	end

	ui.createNotification(notification)
	WaitSeconds(savedPrefs.global.duration)
	ui.removeNotification(notification.id)
end
