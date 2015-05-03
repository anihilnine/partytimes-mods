local LagfixEnabled = import('/mods/lagfix/lagfix.lua').LagfixEnabled
local UIFileCache = {}

    --* given a path and name relative to the skin path, returns the full path based on the current skin
function UIFile(filespec)
    local skins = import('/lua/skins/skins.lua').skins
    local skin = currentSkin()
    local currentPath = skins[skin].texturesPath

    if skin == nil or currentPath == nil then
        return nil
    end

    if(not UIFileCache[skin][filespec] or not LagfixEnabled())  then
        local found = false

        if skin == 'default' then

            found = currentPath .. filespec
        else
            local nextSkin = skin

            while not found and nextSkin do
                local curFile = currentPath .. filespec

                if DiskGetFileInfo(curFile) then
                    found = curFile
                else
                    nextSkin = skins[nextSkin].default
                    if nextSkin then
                        currentPath = skins[nextSkin].texturesPath
                    end
                end
            end

            if not found then

                LOG("Warning: Unable to find file ", filespec)
                found = filespec
            end
        end

        if(not UIFileCache[skin]) then
            UIFileCache[skin] = {}
        end

        UIFileCache[skin][filespec] = found
    end

    return UIFileCache[skin][filespec]
end