local modPathIE = '/mods/idleEngineers/'

local originalCreateUIidleEngineers = CreateUI
function CreateUI(isReplay, parent)
    originalCreateUIidleEngineers(isReplay)
    AddBeatFunction(import(modPathIE .. 'modules/allunits.lua').UpdateAllUnits)
    import(modPathIE .. "modules/init.lua").init(isReplay, import('/lua/ui/game/borders.lua').GetMapGroup())
end
