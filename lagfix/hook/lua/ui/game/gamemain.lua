local RegisterChatFunc = import('/lua/ui/game/gamemain.lua').RegisterChatFunc

local originalCreateUI = CreateUI
function CreateUI(isReplay, parent)
    local retval = originalCreateUI(isReplay)
    import('/mods/lagfix/lagfix.lua').init(isReplay, import('/lua/ui/game/borders.lua').GetMapGroup())
end