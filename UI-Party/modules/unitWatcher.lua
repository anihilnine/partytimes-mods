local GameMain = import('/lua/ui/game/gamemain.lua')
local SelectHelper = import('/mods/ui-party/modules/selectHelper.lua')
local UIP = import('/mods/UI-Party/modules/UI-Party.lua')


function Init()

end

function OnBeat()

	if UIP.Enabled() then

		local units = SelectHelper.getAllUnits()
		from(units).foreach(function(k,v)
			if v.uip == nil then
				v.uip = true
				UnitFound(v)
			end
		end)

	end

end

function UnitFound(u)
	if UIP.GetSetting("setGroundFireOnAttack") then
		ToggleFireState({ u }, 1)
	end
	if UIP.GetSetting("factoriesStartWithRepeatOn") then
		u:ProcessInfo('SetRepeatQueue', 'true')
	end
end

