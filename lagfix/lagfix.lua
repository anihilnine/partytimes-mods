local RegisterChatFunc = import('/lua/ui/game/gamemain.lua').RegisterChatFunc

local enabled = true

function LagfixEnabled()
	return enabled
end

function processCommand(sender, cmd)
	enabled = not enabled
	if(enabled) then
		print "Lagfix enabled"
	else
		print "Lagfix disabled"
	end
end

function sendCommand(cmd)
	msg = {text = cmd, lagfix=true}
	SessionSendChatMessage(msg)
end

function ToggleLagfix()
	sendCommand('toggle')
end

function init(isReplay, parent) 
	RegisterChatFunc(processCommand, "lagfix")
	IN_AddKeyMapTable({['Ctrl-Shift-Backspace'] = {action =  'ui_lua import("/mods/lagfix/lagfix.lua").ToggleLagfix()'},})
end
