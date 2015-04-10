local modpath = "/mods/reminder"
local selectHelper = import(modpath..'/modules/selectHelper.lua')

local fixedConfig = {
	retriggerDelay = 10,
}
local runtimeConfig = {
	text = "ACU loses hp",
	subtext = "your ACU takes damage!",
	icon = 'acus/uef.png',
}
function getFixedConfig()
	return fixedConfig
end
function getRuntimeConfig()
	return runtimeConfig
end

local acu = nil
local avg1s = 0
local previousHp = 0
local curPrevHp = 0

function init()
	for _,u in selectHelper.getAllUnits() do
		if(u:IsInCategory("COMMAND") )then
			acu = u
			previousHp = acu:GetHealth()
			curPrevHp = previousHp
			if u:IsInCategory("AEON") then
				runtimeConfig.icon = 'acus/aeon.png'
			elseif u:IsInCategory("CYBRAN") then
				runtimeConfig.icon = 'acus/cybran.png'
			elseif u:IsInCategory("SERAPHIM") then
				runtimeConfig.icon = 'acus/seraphim.png'
			end
		end
	end
end


function triggerNotification()
	if(acu == nil) then
		return false
	end
	
	curPrevHp = previousHp
	previousHp = acu:GetHealth()
	
	avg1s = avg1s*0.9 - (previousHp-curPrevHp)*0.1
	
	if( (acu:GetHealth()+0.03*acu:GetMaxHealth()) < curPrevHp) then
		avg1s = 0
		runtimeConfig.subtext = math.floor(acu:GetHealth()).." hp remaining"
		return true
	end
	
	if (acu:GetMaxHealth()*0.001 < avg1s) then
		avg1s = 0
		runtimeConfig.subtext = math.floor(acu:GetHealth()).." hp remaining"
		return true
	end
	
	return false
end


function onRetriggerDelay()
	if acu then
		avg1s = 0
		previousHp = acu:GetHealth()
		curPrevHp = previousHp
	end
end


function onClick()
	SelectUnits({acu})
end