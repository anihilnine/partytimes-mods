
--*****************************************************************************
--* File: 
--* Author: Domino
--* Summary: 
--*
--* Copyright © 2005 Gas Powered Games, Inc.  All rights reserved.
--*****************************************************************************

do

local prevSetLayout = SetLayout
function SetLayout(layout)
	prevSetLayout(layout)
	import('/mods/group_split/lua/group_split/group_split.lua').SetLayout()
end

local prevCreateUI = CreateUI
function CreateUI(isReplay)
	prevCreateUI(isReplay)
	import('/mods/group_split/lua/group_split/group_split.lua').CreateUI(mapGroup)
end

local prevCreateUI = CreateUI
function CreateUI(isReplay)
	prevCreateUI(isReplay)
	
	local trackMap = {	
		---------
		--Create
		['Alt-Shift-1'] = {action =  'UI_Lua import("/mods/group_split/lua/group_split/group_split.lua").SplitUnitsIntoGroups(1)', category = 'Group Split', order = 1,},
		['Alt-Shift-2'] = {action =  'UI_Lua import("/mods/group_split/lua/group_split/group_split.lua").SplitUnitsIntoGroups(2)', category = 'Group Split', order = 2,},
		['Alt-Shift-3'] = {action =  'UI_Lua import("/mods/group_split/lua/group_split/group_split.lua").SplitUnitsIntoGroups(3)', category = 'Group Split', order = 3,},
		['Alt-Shift-4'] = {action =  'UI_Lua import("/mods/group_split/lua/group_split/group_split.lua").SplitUnitsIntoGroups(4)', category = 'Group Split', order = 4,},
		['Alt-Shift-5'] = {action =  'UI_Lua import("/mods/group_split/lua/group_split/group_split.lua").SplitUnitsIntoGroups(5)', category = 'Group Split', order = 5,},
		['Alt-Shift-6'] = {action =  'UI_Lua import("/mods/group_split/lua/group_split/group_split.lua").SplitUnitsIntoGroups(6)', category = 'Group Split', order = 6,},
		['Alt-Shift-7'] = {action =  'UI_Lua import("/mods/group_split/lua/group_split/group_split.lua").SplitUnitsIntoGroups(7)', category = 'Group Split', order = 7,},
		['Alt-Shift-8'] = {action =  'UI_Lua import("/mods/group_split/lua/group_split/group_split.lua").SplitUnitsIntoGroups(8)', category = 'Group Split', order = 8,},
		['Alt-Shift-9'] = {action =  'UI_Lua import("/mods/group_split/lua/group_split/group_split.lua").SplitUnitsIntoGroups(9)', category = 'Group Split', order = 9,},
		['Alt-Shift-0'] = {action =  'UI_Lua import("/mods/group_split/lua/group_split/group_split.lua").SplitUnitsIntoGroups(10)', category = 'Group Split', order = 10,},
				
		--------
		--Selection
		
		['Alt-1'] = {action =  'UI_Lua import("/mods/group_split/lua/group_split/group_split.lua").SelectSplitGroup(11)', category = 'Group Split', order = 11,},
		['Alt-2'] = {action =  'UI_Lua import("/mods/group_split/lua/group_split/group_split.lua").SelectSplitGroup(12)', category = 'Group Split', order = 12,},
		['Alt-3'] = {action =  'UI_Lua import("/mods/group_split/lua/group_split/group_split.lua").SelectSplitGroup(13)', category = 'Group Split', order = 13,},
		['Alt-4'] = {action =  'UI_Lua import("/mods/group_split/lua/group_split/group_split.lua").SelectSplitGroup(14)', category = 'Group Split', order = 14,},
		['Alt-5'] = {action =  'UI_Lua import("/mods/group_split/lua/group_split/group_split.lua").SelectSplitGroup(15)', category = 'Group Split', order = 15,},
		['Alt-6'] = {action =  'UI_Lua import("/mods/group_split/lua/group_split/group_split.lua").SelectSplitGroup(16)', category = 'Group Split', order = 16,},
		['Alt-7'] = {action =  'UI_Lua import("/mods/group_split/lua/group_split/group_split.lua").SelectSplitGroup(17)', category = 'Group Split', order = 17,},
		['Alt-8'] = {action =  'UI_Lua import("/mods/group_split/lua/group_split/group_split.lua").SelectSplitGroup(18)', category = 'Group Split', order = 18,},
		['Alt-9'] = {action =  'UI_Lua import("/mods/group_split/lua/group_split/group_split.lua").SelectSplitGroup(19)', category = 'Group Split', order = 19,},
		['Alt-0'] = {action =  'UI_Lua import("/mods/group_split/lua/group_split/group_split.lua").SelectSplitGroup(20)', category = 'Group Split', order = 20,},
		
		---------
		--Select Squad
		['Alt-S'] = {action =  'UI_Lua import("/mods/group_split/lua/group_split/group_split.lua").SelectSquadGroups()', category = 'Group Split', order = 21,},
		
		----
		--remove unit from group
		['Alt-C'] = {action =  'UI_Lua import("/mods/group_split/lua/group_split/group_split.lua").DisbandSelection()', category = 'Group Split', order = 22,},

		['V'] = {action =  'UI_Lua import("/mods/group_split/lua/group_split/group_split.lua").SmartSplitL()', category = 'Group Split', order = 23,},
		['B'] = {action =  'UI_Lua import("/mods/group_split/lua/group_split/group_split.lua").SmartSplitR()', category = 'Group Split', order = 23,},
		
	}
	IN_AddKeyMapTable(trackMap)

end

end

