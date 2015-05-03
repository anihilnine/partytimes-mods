--*****************************************************************************
--* File: lua/ui/game/helptext.lua
--* Author: Ted Snook
--* Summary: Help Text Popup
--*
--* Copyright © 2005 Gas Powered Games, Inc.  All rights reserved.
--*****************************************************************************

local UIUtil = import('/lua/ui/uiutil.lua')
local initDefaultKeyMap = import('/mods/hot/lua/hotbuild.lua').initDefaultKeyMap

local originalResetKeyMap = ResetKeyMap

function initDefaultKeyMap_de()
  initDefaultKeyMap('de')
end

function initDefaultKeyMap_en()
  initDefaultKeyMap('en')
end

function initDefaultKeyMap_select()
  UIUtil.QuickDialog(panel, "Which keyboard layout do you have?",
           "German", initDefaultKeyMap_de,
            "EN/US", initDefaultKeyMap_en,
            nil, nil,
            true, 
            {escapeButton = 2, enterButton = 1, worldCover = false})
end

function ResetKeyMap()
  originalResetKeyMap()
  UIUtil.QuickDialog(panel, "Do you want to to reset to the default hotbuild keymapping by Zulan(Progaming/Vault54). This might require a restart.",
           "<LOC _Yes>", initDefaultKeyMap_select,
            "<LOC _No>", nil,
            nil, nil,
            true, 
            {escapeButton = 2, enterButton = 1, worldCover = false})
end
