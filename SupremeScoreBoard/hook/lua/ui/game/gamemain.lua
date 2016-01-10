local modPathIE = '/mods/XCOM_ScoreTable'

local baseCreateUI = CreateUI
function CreateUI(isReplay, parent)
    baseCreateUI(isReplay)
    --AddBeatFunction(import(modPathIE .. '/modules/allunits.lua').UpdateAllUnits)
    --import(modPathIE .. "/modules/init.lua").init(isReplay, import('/lua/ui/game/borders.lua').GetMapGroup())

	--LOG("*MT DEBUG: " .. " createUI forking thread scoreStats.lua - syncStats... "  )
	
	--ForkThread(import('/mods/XCOM_ScoreTable/modules/scoreStats.lua').syncStats)
	
end
