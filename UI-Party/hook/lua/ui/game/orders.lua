#*****************************************************************************
#* File: lua/modules/ui/game/orders.lua
#* Author: Chris Blackwell
#* Summary: Unit orders UI
#*
#* Copyright © 2005 Gas Powered Games, Inc.  All rights reserved.
#*****************************************************************************


function SetCurrentSelectionToGroundFireMode()
	ToggleFireState(currentSelection, 1)
end