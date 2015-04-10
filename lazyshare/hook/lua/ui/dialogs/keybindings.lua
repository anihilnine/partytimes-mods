--*****************************************************************************
--* File: lua/ui/game/helptext.lua
--* Author: Ted Snook
--* Summary: Help Text Popup
--*
--* Copyright © 2005 Gas Powered Games, Inc.  All rights reserved.
--*****************************************************************************

local UIUtil = import('/lua/ui/uiutil.lua')
local initDefaultKeyMap = import('/mods/lazyshare/mimc_keys.lua').initDefaultKeyMap()

local originalResetKeyMap = ResetKeyMap

function ResetKeyMap()
  originalResetKeyMap()
  UIUtil.QuickDialog(panel, "Do you want to to reset to the LazyShare-Keymappig? This might require a restart.",
           "<LOC _Yes>", initDefaultKeyMap,
            "<LOC _No>", nil,
            nil, nil,
            true, 
            {escapeButton = 2, enterButton = 1, worldCover = false})
end
