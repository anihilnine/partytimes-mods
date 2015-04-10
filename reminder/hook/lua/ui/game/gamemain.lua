local modpath = "/mods/reminder"
local selectHelper = import(modpath..'/modules/selectHelper.lua')

local originalCreateUI = CreateUI 
local originalOnSelectionChanged = OnSelectionChanged


function OnSelectionChanged(oldSelection, newSelection, added, removed)
	if not selectHelper.IsAutoSelection() then
		originalOnSelectionChanged(oldSelection, newSelection, added, removed)
	end
end


function CreateUI(isReplay) 
	originalCreateUI(isReplay)
	if not isReplay then
		import(modpath..'/modules/notificationPrefs.lua').init()
		import(modpath..'/modules/notificationUi.lua').init()
		AddBeatFunction(selectHelper.UpdateAllUnits)
		ForkThread(import(modpath..'/modules/checkAndNotify.lua').init)
	end
end