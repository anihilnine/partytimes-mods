local modpath = "/mods/reminder"
local selectHelper = import(modpath..'/modules/selectHelper.lua')

local oldOnCommandIssued = OnCommandIssued
function OnCommandIssued(command)
	oldOnCommandIssued(command)

	if(command.CommandType == "Upgrade") then
		for _, u in command.Units do
			selectHelper.addUpgradingUnit(u)
		end
	elseif(command.CommandType == "Stop") then
		for _, u in command.Units do
			selectHelper.removeUpgradingUnit(u)
		end
	end
end