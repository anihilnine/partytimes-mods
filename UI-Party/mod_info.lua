name = "UI Party"
version = 9
copyright = "nah"
description = "Various UI Enhancements. With contributions from many."
author = "Anihilnine, with contributions (technical help / ideas / I stole their code) from Zock, Domino, Myxir, yorick, Sir Prize, Crotalus, Coding Squirrel, Morax, Speed2, Hotbuild, camelCase, HUSAR_PL"
url = ""
uid = "022E3DB4-9C00-4ED7-9876-4866D316E009"
exclusive = false
ui_only = true
conflicts = {  }

-- ### upcoming features

-- ######################### need maint labels, does not appear to get missiles properly, then stack the bars horiz
--	only run test when in dev mode
--	fix eco bar strat icons left
--	allow click incomplete stuff
--  sound fx
------------

-- pretty epic but all i can use GetWorkProgress() on silo to reverse engineer how much has been spent on this thing
-- then i need to not-count assisters twice. which I could do by looking at assisters and their build power etc and minusing it? doesn't sound right when its behaving eratically. 
-- I could just dump it all on the silo and mark the assisters as to be ignored

-- a million silo problems
-- arty power usage problems
-- clicking on mexes to see what is upgrading selects all including maintenance, which is all. do we need to split repair/upgrade/maint/build/etc

-- ### history

-- v10
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
