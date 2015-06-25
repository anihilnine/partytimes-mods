local oldOnCommandIssued = OnCommandIssued
local ignoreSelection = false

function SetIgnoreSelection(ignore)
	ignoreSelection = ignore
end

function OnCommandIssued(command)
	local checkBadClean = import('/lua/ui/game/construction.lua').checkBadClean
	if(command.Clear == true and command.CommandType ~= 'Stop' and table.getn(command.Units) == 1 and checkBadClean(command.Units[1])) then
		import('/lua/ui/game/construction.lua').watchForQueueChange(command.Units[1])
	end
	
	if(command.CommandType == 'Script' and command.LuaParams and command.LuaParams.Enhancement) then
		import('/mods/Notify/modules/notify.lua').enqueueEnhancement(command.Units, command.LuaParams.Enhancement)
	elseif(command.CommandType == 'Stop') then
		import('/mods/Notify/modules/notify.lua').clearEnhancements(command.Units)
	end
	
	oldOnCommandIssued(command)
end

local oldEndCommandMode = EndCommandMode
function EndCommandMode(isCancel)
	if ignoreSelection == false then
		oldEndCommandMode(isCancel)
	end
end