local UIP = import('/mods/UI-Party/modules/UI-Party.lua')

local oldStartCommandMode = StartCommandMode
function StartCommandMode(newCommandMode, data)
	
	if UIP.Enabled() and UIP.GetSetting("setGroundFireOnAttack") then
		if newCommandMode == "order" and data.name=="RULEUCC_Attack" then
			import("/lua/ui/game/orders.lua").SetCurrentSelectionToGroundFireMode()
			oldStartCommandMode(newCommandMode, data)			
			return
		end	
	end

	oldStartCommandMode(newCommandMode, data)

end
