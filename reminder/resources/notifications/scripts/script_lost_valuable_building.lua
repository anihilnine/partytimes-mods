local modpath = "/mods/reminder"
local utils = import(modpath..'/modules/notificationUtils.lua')
local units = import('/mods/common/units.lua')

local savedConfig = nil


function getDefaultConfig()
	return {
		[1] = {
			name = "Check nuke defense",
			path = "checkSMD",
			value = true,
		},
		[2] = {
			name = "Check omni sensor",
			path = "checkOmni",
			value = true,
		},
	}
end
local runtimeConfig = {
	text = "",
	subtext = "",
	icons = {[1] = {icon='land_up.dds', isModFile=false}},
	unitsToSelect = {},
	sound = false,
}
function getRuntimeConfig()
	return runtimeConfig
end

local omniIcon = nil
local smdIcon = nil

local prevSmds = 0
local prevOmnis = 0


function init()
	local faction = utils.getFaction()
	if faction == "UEF" then
		omniIcon = {icon='UEB3104_icon.dds', isModFile=false}
		smdIcon = {icon='UEB4302_icon.dds', isModFile=false}
	elseif faction == "AEON" then
		omniIcon = {icon='UAB3104_icon.dds', isModFile=false}
		smdIcon = {icon='UAB4302_icon.dds', isModFile=false}
	elseif faction == "CYBRAN" then
		omniIcon = {icon='URB3104_icon.dds', isModFile=false}
		smdIcon = {icon='URB4302_icon.dds', isModFile=false}
	else
		omniIcon = {icon='XSB3104_icon.dds', isModFile=false}
		smdIcon = {icon='xsb4302_icon.dds', isModFile=false}
	end
end


function triggerNotification()
	local smds = 0
	local omnis = 0
	local notificationIsReady = false
	
	-- smds
	if savedConfig.checkSMD == true then
		for _,u in units.Get() do
			if(u:IsInCategory("ANTIMISSILE") and u:IsInCategory("TECH3") and u:IsInCategory("STRUCTURE"))then
				smds = smds +1
			end	
		end
		if smds < prevSmds then
			notificationIsReady = true
			runtimeConfig.text = "Nuke Defense Lost!"
			runtimeConfig.subtext = "Lost "..prevSmds-smds.." nuke defense!"
			runtimeConfig.icons[2] = smdIcon
		end
		prevSmds = smds
		if notificationIsReady then
			return true
		end
	else
		prevSmds = 0
	end
	
	-- t3 radar
	if savedConfig.checkOmni == true then
		for _,u in units.Get() do
			if(u:IsInCategory("OMNI") and u:IsInCategory("STRUCTURE") )then
				omnis = omnis +1
			end	
		end
		if omnis < prevOmnis then
			notificationIsReady = true
			runtimeConfig.text = "Omni Sensor Lost!"
			runtimeConfig.subtext = "Lost "..prevOmnis-omnis.." omni sensor!"
			runtimeConfig.icons[2] = omniIcon
		end
		prevOmnis = omnis
		if notificationIsReady then
			return true
		end
	else
		prevOmnis = 0
	end
	
	return false
end


function onRetriggerDelay()
end


function onUpdatePreferences(savedConfig_)
	savedConfig = savedConfig_
end