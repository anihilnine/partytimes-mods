name = "UI Party"
version = 10
copyright = "nah"
description = "Various UI Enhancements. With contributions from many."
author = "Anihilnine, with contributions (technical help / ideas / I stole their code) from Zock, Domino, Myxir, yorick, Sir Prize, Crotalus, Coding Squirrel, Morax, Speed2, Hotbuild, camelCase, HUSAR_PL, MaCielPL, tatsu"
url = ""
uid = "022E3DB4-9C00-5ED7-9876-4866D316E010"
exclusive = false
ui_only = true
conflicts = {  }
after = { 

}

-- ### todo

--  enable mod doesnt effect econtrol
--  remove having to reselect for upgrades
--  submerge adornment fix
--	econtrol tooltip
--	better uiparty button
--	use common (with check that is running and give to myx)
--	remove reclaim from income in eco window (how to do team overspil)
--	show reclaim graph
--	only run test when in dev mode
--	a million silo problems
--	arty power usage problems
--	get rounding fix integrated

-- ### history

-- v10
--	added key - Select similar onscreen units
--	added key - Undo last queue order - works for engies and factories
--	update beep/message for finished structure/acu upgrades.
--	upgrade adornment for structures
--	upgrade adorment for acu upgrades - this feature requires notify mod, doesnt work in replay
--	fix - shows double adornments when upgrading fac
--	adornments - greater emphasis on idle master facs
--	new: Econtrol ui
--	performance improvements

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
