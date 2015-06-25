local modPath = '/mods/Notify/'
local ignoreSelection = false

local originalCreateUI = CreateUI

function CreateUI(isReplay, parent)
    originalCreateUI(isReplay)
    import(modPath .. "modules/notify.lua").init(isReplay, import('/lua/ui/game/borders.lua').GetMapGroup())
end

function SetIgnoreSelection(ignore)
	ignoreSelection = ignore
	import('/lua/ui/game/commandmode.lua').SetIgnoreSelection(ignore)
end

local oldOnSelectionChanged = OnSelectionChanged
function OnSelectionChanged(oldSelection, newSelection, added, removed)
	if ignoreSelection == false then
		oldOnSelectionChanged(oldSelection, newSelection, added, removed)
	end
end