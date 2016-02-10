name = "UI Party"
version = 9
copyright = "nah"
description = "Various UI Enhancements. With contributions from many."
author = "Anihilnine, with contributions (technical help / ideas / I stole their code) from Zock, Domino, Myxir, yorick, Sir Prize, Crotalus, Coding Squirrel, Morax, Speed2, Hotbuild, camelCase, HUSAR_PL, MaCielPL"
url = ""
uid = "022E3DB4-9C00-4ED7-9876-4866D316E009"
exclusive = false
ui_only = true
conflicts = {  }
after = { 
	"a0714870-3f5e-4b60-970e-1b02341990ec",     -- Supreme Economy 2.1 (nolag)
}

-- ### upcoming features

-- building mexes
-- hover over descriptions
-- pause engies when toggle via mex buttons
-- github


-- better uiparty button
-- use common (with check that is running and give to myx)
-- remove reclaim from income in eco window (how to do team overspil)
-- show reclaim graph
-- only run test when in dev mode
-- a million silo problems`
-- arty power usage problems
-- clicking on mexes to see what is upgrading selects all including maintenance, which is all. do we need to split repair/upgrade/maint/build/etc
-- econtrol needs switch, mex option, integrate github

-- ### history

-- v10
--	new: Econ-trol ui
--	added key - Select similar onscreen units
--	added key - Undo last queue order - works for engies and factories
--	update beep/message for finished structure/acu upgrades.
--	upgrade adornment for structures
--	upgrade adorment for acu upgrades - this feature requires notify mod, doesnt work in replay
--	fix - shows double adornments when upgrading fac
--	adornments - greater emphasis on idle master facs

-- v9
--	Compatibility with FAF 3642

-- v8
--	Clear queue except for current production - now works for multiple units at once. Also clears the first item if it hasnt been started yet (because another unit is still walking off factory)
--	Adornments - better icons for factories

-- v7
--	manual unit lock
--	adornments
--	double click assister selects similar assisters
--	added key - Reselect Split Units
--	added key - Reselect Ordered Split Units

-- v6
--	bug fix : commandmode doesnt cancel

-- v5
--	added key - clear queue except for current - works for (factory work queue) and (engineer work queue)
--	added option - Factories repeat always

-- v4 
--	unit split
--	settings ui
--	fix ui layout bugs during replay
--	all units start ground fire

-- v3 and earlier
--	units ground fire on attack
--	bug fixes
--	zoom pop override and speed
--	rearrange bottom panes
--	hide menus on start
--	start split screen
--	move and rearrange windows
--	switch to disable mod
