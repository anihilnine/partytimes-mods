--------------------------------------------------------------------------------------
name = "Supreme Score Board v1.1"
--------------------------------------------------------------------------------------
uid = "HUSAR-PL-a1e2-c4t4-scfa-ssbmod-v1100"
version = 1.1
author = "HUSAR_PL"
copyright = "HUSAR_PL, free to re-use code as long as you credit me in your mod"
description = "Improves score board and replays by adding more columns, team stats, players sorting, filtering units by type, kill/lose ratio, fixed UI updates lags! (HUSAR_PL)"
icon = "/mods/SupremeScoreBoard/mod_icon.png"
url  = "http://forums.faforever.com/forums/viewtopic.php?f=41&t=10887"
selectable  = true
enabled     = true
ui_only     = true
exclusive   = false
requiresNames = { }
requires    = { }
-- this mod will conflict with all mods that modify score.lua file:
conflicts   = { 
    "9B5F858A-163C-4AF1-B846-A884572E61A5", -- lazyshare
    "c31fafc0-8199-11dd-ad8b-0866200c9a68", -- coloured allies in score
    "0faf3333-1122-633s-ya-VX0000001000",   -- eco info - sharing among your team
    "89BF1572-9EA8-11DC-1313-635F56D89591",
    "f8d8c95a-71e7-4978-921e-8765beb328e8",
    }
before = { }
after = { }
--------------------------------------------------------------------------------------
-- MOD HISTORY
--[[ v1.1 BY HUSAR_PL - October 5, 2015
--------------------------------------------------------------------------------------
- fixed info about active mods in replay session
- fixed status of game raking
- fixed tooltip about game quality/balance
- added coloring of player names based on team color 
- thanks to testers: Petricpwnz, Anihilnine
--]]
--------------------------------------------------------------------------------------
--[[ v1.0 BY HUSAR_PL - September 25, 2015
--------------------------------------------------------------------------------------
FEATURES:
--------------------------------------------------------------------------------------
- added team lines that sums up stats for allied players
- added column with filters to show count of air/land/navy/base units  
- added column for total mass of collected/killed/lost
- added column for players rating to prevent clipping by score values
- added toggle to show and sort players by their army rating
- added toggle to show and sort players by total mass collected
- added toggle to show and sort players by total mass reclaimed*
- added toggle to show and sort players by total energy reclaimed*
- added toggle to show and sort players by total energy collected
- added toggle to show and sort players by their clan tags
- added toggle to show and sort players by Kills-to-Loses Ratio
- added toggle to show and sort players by Kills-to-Built Ratio
- added toggle to sort players by current mass income
- added toggle to sort players by current energy income
- added toggle to sort players by current score value
- added toggle to sort players by their army name
- added toggle to sort players by their clan tag
- added toggle to sort players by their team id
- added sorting by two columns when value in the first sorting are equal, e.g. sorting by team ID and then by mass income
- added team status showing alive/maximum players 
- added rendering players names with red/green when in players view to show allies/enemies 
- added calculation of AI rating based on AI type and AI cheat modifiers
- added field showing game quality based on network connection between players
- added tooltips for all new UI elements in the score panel
- added info about map size
- added icons with improved quality for mass, energy, units
- added icons with info about game restrictions
- added icons with info about active mods
- added icons with info about unit sharing
- added icons with info about victory conditions
- added icons with info about AI multipliers
- added notifications about 1st experimental unit built by a player
- changed game time/speed fields into two fields   
- changed unit counter to show unit count of all armies (in observer view) or just player's units (in player view) 

*Pending FAF patch that will actually add reclaim values to score data and thus enable them to show in score panel 

--------------------------------------------------------------------------------------
FIXES:
--------------------------------------------------------------------------------------
- fixed missing tooltip for game speed slider
- fixed performance in updating score panel by limiting number of for loops (n*n-times to n-times)
- fixed issues with performing operations on uninitialized values of score data
- fixed redundant function calls to GetArmiesTable().armiesTable
- fixed redundant function calls to GetFocusArmy()
- fixed redundant function calls to SessionIsReplay()
- fixed redundant function calls to SessionGetScenarioInfo()
- fixed redundant imports of some LUA scripts (e.g. announcement.LUA)
--]]
--------------------------------------------------------------------------------------
--[[ TODO
- design better icons 
- add configuration window for hiding columns, changing font size, background opacity
--]] 
--------------------------------------------------------------------------------------
--[[ TEST NOTES:
-- maps big:    Seton's Clutch, The Dark Heart, Seraphim Glaciers, Twin Rivers
-- maps small:  Balvery Mountains Diversity
-- players:     Lainelas, Blackheart, Blackdeath, Foley, BRNKoINSANITY 
-- ai           Neptune, EntropicVoid on The Dark Heart
-- max teams    Fractal Cancer, Seraphim Glaciers, White Fire 
-- clans        SGI Nequilich e VoR
                
                
logs line =  line# in this file + # of lines in original score.LUA (620) 630

--]]  
--------------------------------------------------------------------------------------