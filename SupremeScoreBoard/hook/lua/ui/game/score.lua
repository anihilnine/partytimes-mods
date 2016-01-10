--------------------------------------------------------------------------
--  File:    /LUA/modules/UI/game/score.LUA
--  Author:  Chris Blackwell, HUSAR_PL
--  Summary: Supreme Score Board in Game/Replay Sessions
--  Copyright � 2005 Gas Powered Games, Inc. All rights reserved.
--------------------------------------------------------------------------
--  NOTE:    Contact HUSAR_PL, in case you are trying to 
--           implement/port this mod to latest version of FAF patch
--------------------------------------------------------------------------
-- current score will contain the most recent score update from the sync
currentScores = false   -- 861

local modPath = '/mods/SupremeScoreBoard/'
local modTextures = modPath..'textures/'
local modScripts  = modPath..'modules/'
-- import local modules
local tab  = import(modScripts..'ext.tables.lua')
local str  = import(modScripts..'ext.strings.lua')
local num  = import(modScripts..'ext.numbers.lua')
local log  = import(modScripts..'ext.logging.lua')
 
local LayoutHelpers = import('/lua/maui/layouthelpers.lua')
local UIUtil        = import('/lua/ui/uiutil.lua')
local GameMain      = import('/lua/ui/game/gamemain.lua')
local Tooltip       = import('/lua/ui/game/tooltip.lua') 
local Group         = import('/lua/maui/group.lua').Group
local Bitmap        = import('/lua/maui/bitmap.lua').Bitmap
local Checkbox      = import('/lua/maui/checkbox.lua').Checkbox
local Text          = import('/lua/maui/text.lua').Text
local Grid          = import('/lua/maui/Grid.lua').Grid
local Slider        = import('/lua/maui/slider.lua').IntegerSlider
local Prefs         = import('/lua/user/prefs.lua')
local Announcement  = import('/lua/ui/game/announcement.lua')
--------------------------------------------------------------------------
-- Configuration Section
--------------------------------------------------------------------------
controls = {}
savedParent = false
local observerLine = false

-- session info should not changed during the game so getting it just once
local sessionReplay  = SessionIsReplay()    
local sessionInfo    = SessionGetScenarioInfo()   
local sessionOptions = sessionInfo.Options
  
-- added Stats to store info about players' armies and aggregated armies (teams)
local Stats = {}
  
log.IsEnabled = true        

local lastUnitWarning = false
local unitWarningUsed = false
local issuedNoRushWarning = false
local gameSpeed = 0
local needExpand = false
local contractOnCreate = false
 
-- added configuration variables 
local boardMargin = 20
local boardWidth = 270  -- original 262
local sw = 50           -- string width for displaying value in grid columns
local iconSize = 15     -- original 14
local lineSize = iconSize + 1
local teamNumber = 1

local fontDigital   = "Zeroes Three" 
local fontMono      = "Courier New"
local fontMonoBold  = "Courier New Bold"
local fontName = UIUtil.bodyFont    -- fontMono --UIUtil.bodyFont
local fontSize = 12                 -- original 12

local showRoundRating = true -- false -> actual rating (not rounded)

local textColorRating   = 'ffffffff'
local textColorNickname = 'ffffffff'
local textColorScore    = 'ffffffff'
local textColorMass     = 'ffb7e75f'
local textColorEngy     = 'fff7c70f'
local textColorUnits    = 'ffcfced0'
local textColorKills    = 'ffff2600'
local textColorLoses    = 'ffa0a0a0'

local armyColorDefeted  = 'ffa0a0a0' --'ff4e4e4e' -- 'ffa0a0a0'
local armyColorAllied   = 'ff9afc98'   
local armyColorEnemy    = 'fffcb4ab'
local armyColorObserver = 'ffffffff'

local cid = 1
-- TODO find a way to load army colors from the game instead of hard-coding them      
-- added table for matching bright text color with color of an army 
-- the order of items in this table determines priority for selecting team colors
local Colors = { }
Colors[cid] = {armyColor='ff40bf40',textColor='ff5cc95c'} cid=cid+1 -- mid green
Colors[cid] = {armyColor='ff436eee',textColor='ff70b5f3'} cid=cid+1 -- new blue 
Colors[cid] = {armyColor='fffafa00',textColor='ffffff42'} cid=cid+1 -- new yellow
Colors[cid] = {armyColor='ff9161ff',textColor='ffc67afe'} cid=cid+1 -- purple
Colors[cid] = {armyColor='ffe80a0a',textColor='ffff3f15'} cid=cid+1 -- Cybran red
Colors[cid] = {armyColor='ffff873e',textColor='ffff9859'} cid=cid+1 -- orange (Nomads)
Colors[cid] = {armyColor='ffffffff',textColor='ffffffff'} cid=cid+1 -- white
Colors[cid] = {armyColor='ff66ffcc',textColor='ff66ffcc'} cid=cid+1 -- aqua
Colors[cid] = {armyColor='ffff32ff',textColor='ffff6aff'} cid=cid+1 -- fuschia pink
Colors[cid] = {armyColor='ffff88ff',textColor='ffff88ff'} cid=cid+1 -- light pink
Colors[cid] = {armyColor='ffffbf80',textColor='ffffbf80'} cid=cid+1 -- light orange
Colors[cid] = {armyColor='ffb76518',textColor='ffe17d22'} cid=cid+1 -- new brown
Colors[cid] = {armyColor='ff2e8b57',textColor='ff3db874'} cid=cid+1 -- dark new green
Colors[cid] = {armyColor='ff131cd3',textColor='ff545bef'} cid=cid+1 -- dark UEF blue
Colors[cid] = {armyColor='ff901427',textColor='ffe12b46'} cid=cid+1 -- dark red
Colors[cid] = {armyColor='ff5f01a7',textColor='ff8501e7'} cid=cid+1 -- dark purple
Colors[cid] = {armyColor='ff2f4f4f',textColor='ff5a9898'} cid=cid+1 -- dark green (olive)
Colors[cid] = {armyColor='ff616d7e',textColor='ff99a3b0'} cid=cid+1 -- grey

-- initializes Stats to store info about players' armies and aggregated armies (teams)
function InitializeStats()
      
    log.Trace('InitializeStats()... '  )
    
    Stats.sortByColumnOld = 'armyID'                
    Stats.sortByColumnNew = 'score' 
    Stats.columnName  = 'nameshort'
    Stats.columnMass  = 'eco.massIncome'
    Stats.columnEngy  = 'eco.engyIncome'
    Stats.columnScore = 'score' --'score' -- 'ratio.killsToLoses'
    Stats.columnTotal = 'eco.massTotal'
    Stats.columnRating = 'rating.actual'
    Stats.columnUnits = 'units.total'
    --Stats.columnUnits = 'units.total|units.air|units.navy'
    
    Stats.filterUnits = {} --'units.total'
    Stats.filterUnits['units.air']  = true
    Stats.filterUnits['units.navy'] = true
    Stats.filterUnits['units.land'] = true
    Stats.filterUnits['units.base'] = true
    
    Stats.units  = GetArmyTableUnits() 
    Stats.armies = {} --GetArmiesTable().armiesTable
    Stats.teams  = {}
    Stats.teamsIDs = {}
    Stats.teamsActive = false 
    Stats.teamsCount = 1
    
    Stats.map = GetMapData(sessionInfo) 
    Stats.ai  = GetAiData(sessionInfo)
    
    local allArmies = GetArmiesTable().armiesTable
      
    --log.Table(allArmies, 'armies') 
    log.Table(sessionInfo, 'sessionInfo')
    -- find and show REPLAY ID:
    --log.Table(__active_mods, 'active_mods')
    --log.Table(sessionOptions, 'sessionOptions')
    
    -- first, collect info about all players
    for armyID,army in allArmies do 
        
        if (army.civilian) then 
            army.type = "civilian"  
        else --if (army.human) then
            army.type = "player"   
        --else
        --    army.type = "ai"  
        --    Stats.ai.active = true            
        end
               
        log.Trace('InitializeStats()... info armyID='..armyID..', type='..army.type..', name='..army.nickname)
        if army.civilian or not army.showScore then continue end
        
        if (army.human) then
            army.nameshort = army.nickname
            army.namefull  = GetArmyClan(army.nickname)..army.nickname 
        else
            army.nameshort = str.subs(army.nickname, "%(", "%)") or army.nickname
            army.namefull  = army.nickname
            Stats.ai.active = true
        end 
        --log.Table(army, 'army') 
        --log.Trace('InitializeStats()... saving armyID='..armyID)
        army.armyID = armyID
        army.eco    = GetArmyTableEco()
        army.kills  = GetArmyTableKills()
        army.loses  = GetArmyTableLoses()
        army.units  = GetArmyTableUnits()
        army.ratio  = GetArmyTableRatio()
        army.rating = GetArmyRating(armyID)
              
        army.announcements = {}
        army.announcements.exp   = 0
        army.announcements.arty  = 0
        army.announcements.nukes = 0
        army.announcements.tele  = 0
        
        Stats.armies[armyID] = army
    end
    
    -- deactivate team Stats if team option is unlocked 
    --if (sessionOptions.TeamLock == nil or 
    --    sessionOptions.TeamLock ~= 'locked') then 
    --    Stats.teamsActive = false
    --    return
    --end
    
    -- TODO combine below for loop with above for loop
    -- second, collect info about all teams
    for armyID,army in Stats.armies do 
        if army.civilian or not army.showScore then continue end
        
        local team = CreateTeam(armyID, allArmies) 
        local teamID = 0
        local teamName = ''
        
        if (Stats.teamsIDs[team.key] ~= nil) then
            teamID   = Stats.teamsIDs[team.key]
            team     = Stats.teams[teamID] 
        else
            -- use negative id for teams
            teamID = Stats.teamsCount * -1
            log.Trace('InitializeStats()... saving team='..teamID..' size='..team.members.count)
            
            team.armyID = teamID -- Stats.teamsCount * -1
            team.number = Stats.teamsCount --teamID * -1 --Stats.teamsCount  
            team.nickname = str.loc('team')..' '..Stats.teamsCount
            team.nameshort = team.nickname..team.status 
            team.namefull  = team.nickname..team.status 
            
            teamName = team.nickname
            
            -- save team if it does not exist yet
            Stats.teams[teamID] = team
            Stats.teamsIDs[team.key] = teamID
            Stats.teamsCount = Stats.teamsCount + 1
        end
        -- save team id for each player's army
        Stats.armies[armyID].teamID    = teamID
        Stats.armies[armyID].teamName  = team.nickname
        Stats.armies[armyID].txtColor  = team.txtColor
    end
    
    --log.Table(Stats.teams, 'teams') 
    Stats.armiesCount = table.getn(Stats.armies)
    Stats.teamsCount  = Stats.teamsCount - 1  
       
    -- activate teams only if we have at least one team with more than 1 player
    -- otherwise, it is redundant to show Stats about teams with just one player in a team
    -- because army lines will show this information 
    Stats.teamsActive = Stats.teamsCount != Stats.armiesCount
      
    local isActive = (Stats.teamsActive and "true" or "false")
    log.Trace('InitializeStats()... teamsActive = '..isActive..', teamsCount = '..Stats.teamsCount..', armiesCount = '..Stats.armiesCount)
 
end
--------------------------------------------------------------------------
-- UI functions
--------------------------------------------------------------------------
function CreateScoreUI(parent)
    savedParent = GetFrame(0)
    
    controls.bg = Group(savedParent)
    controls.bg.Depth:Set(10)
    
    controls.collapseArrow = Checkbox(savedParent)
    controls.collapseArrow.OnCheck = function(self, checked)
        ToggleScoreControl(not checked)
    end
    Tooltip.AddCheckboxTooltip(controls.collapseArrow, 'score_collapse')
    
    controls.bgTop = Bitmap(controls.bg)
    controls.bgBottom = Bitmap(controls.bg)
    controls.bgStretch = Bitmap(controls.bg)
    controls.armyGroup = Group(controls.bg)
    
    -- HUSAR: increased board width to show more columns
    if (sessionReplay) then
        boardWidth = 390 --340 -- 380  
    else 
        boardWidth = boardWidth + 20  --280
    end    
    controls.bgTop.Width:Set(boardWidth + boardMargin)
    controls.bgBottom.Width:Set(boardWidth + boardMargin)
	controls.bgStretch.Width:Set(boardWidth + boardMargin)
	
    controls.leftBracketMin = Bitmap(controls.bg)
    controls.leftBracketMax = Bitmap(controls.bg)
    controls.leftBracketMid = Bitmap(controls.bg)
    
    controls.rightBracketMin = Bitmap(controls.bg)
    controls.rightBracketMax = Bitmap(controls.bg)
    controls.rightBracketMid = Bitmap(controls.bg)
    
    controls.leftBracketMin:DisableHitTest()
    controls.leftBracketMax:DisableHitTest()
    controls.leftBracketMid:DisableHitTest()
    
    controls.rightBracketMin:DisableHitTest()
    controls.rightBracketMax:DisableHitTest()
    controls.rightBracketMid:DisableHitTest()
    
    controls.bg:DisableHitTest(true)
    controls.bgTop:DisableHitTest(true)
    controls.bgBottom:DisableHitTest(true)
    controls.bgStretch:DisableHitTest(true)
    
    SetupPlayerLines()
    
    controls.time = UIUtil.CreateText(controls.bgTop, '00:00:00', fontSize, fontMono)
    controls.time:SetColor('ff00dbff')
    controls.timeIcon = Bitmap(controls.bgTop)
    controls.timeIcon:SetTexture(modTextures..'game_timer.dds')
    Tooltip.AddControlTooltip(controls.time, str.tooltip('game_timer'))
    Tooltip.AddControlTooltip(controls.timeIcon, str.tooltip('game_timer'))
	
    controls.speed = UIUtil.CreateText(controls.bgTop, '(+0/+0)', fontSize, fontMono)
    controls.speed:SetColor('ff00dbff')
    controls.speedIcon = Bitmap(controls.bgTop)
    controls.speedIcon:SetTexture(modTextures..'game_speed.dds')
    Tooltip.AddControlTooltip(controls.speed, str.tooltip('game_speed'))
    Tooltip.AddControlTooltip(controls.speedIcon, str.tooltip('game_speed'))
	
    controls.quality = UIUtil.CreateText(controls.bgTop, '--%', fontSize, fontMono)
    controls.quality:SetColor('ff00dbff')
    controls.qualityIcon = Bitmap(controls.bgTop)
    controls.qualityIcon:SetTexture(modTextures..'game_quality.dds')
    Tooltip.AddControlTooltip(controls.quality, str.tooltip('game_quality'))
    Tooltip.AddControlTooltip(controls.qualityIcon, str.tooltip('game_quality'))
	
    controls.units = UIUtil.CreateText(controls.bgTop, '0/0', fontSize, fontMono)
    controls.units:SetColor('ffff9900')
    controls.unitIcon = Bitmap(controls.bgTop)
    controls.unitIcon:SetTexture(modTextures..'units.total.dds')
    Tooltip.AddControlTooltip(controls.units, str.tooltip('units_count'))
    Tooltip.AddControlTooltip(controls.unitIcon, str.tooltip('units_count'))
	
    --Tooltip.AddControlTooltip(controls.time, 'score_time')
    --Tooltip.AddControlTooltip(controls.timeIcon, 'score_time')
    --Tooltip.AddControlTooltip(controls.units, 'score_units')
    --Tooltip.AddControlTooltip(controls.unitIcon, 'score_units')
    
    SetLayout()
    
    controls.timeIcon.Height:Set(iconSize)
    controls.timeIcon.Width:Set(iconSize)
    
    controls.speedIcon.Height:Set(iconSize)
    controls.speedIcon.Width:Set(iconSize)
    
    controls.qualityIcon.Height:Set(iconSize)
    controls.qualityIcon.Width:Set(iconSize)
    
    controls.unitIcon.Height:Set(iconSize)
    controls.unitIcon.Width:Set(iconSize)
     
    controls.bgTop:SetTexture(modTextures..'score_top.dds')
    controls.bgBottom:SetTexture(modTextures..'score_bottom.dds')
    controls.bgStretch:SetTexture(modTextures..'score_strech.dds')
   
    GameMain.AddBeatFunction(_OnBeat)
    controls.bg.OnDestroy = function(self)
        GameMain.RemoveBeatFunction(_OnBeat)
    end
    
    if contractOnCreate then
        Contract()
    end
    
    controls.bg:SetNeedsFrameUpdate(true)
    controls.bg.OnFrame = function(self, delta)
        local newRight = self.Right() + (1000*delta)
        if newRight > savedParent.Right() + self.Width() then
            newRight = savedParent.Right() + self.Width()
            self:Hide()
            self:SetNeedsFrameUpdate(false)
        end
        self.Right:Set(newRight)
    end
    controls.collapseArrow:SetCheck(true, true)
    
end

function SetLayout()
    if controls.bg then
        import(UIUtil.GetLayoutFilename('score')).SetLayout()
    end
end

function SetupPlayerLines()
    
    InitializeStats()
    
    local index = 1 -- global counter of lines
       
    -- army lines always above team lines (armyId between 1 and 12+)
    for armyID, army in Stats.armies do
        if army.civilian or not army.showScore then continue end
        if not controls.armyLines then 
            controls.armyLines = {}
        end
        controls.armyLines[index] = CreateArmyLine(armyID, army)
        index = index + 1 
    end
       
    -- team lines are always below army lines (armyID between -1 and -12)
    if (Stats.teamsActive) then 
        for teamID, team in Stats.teams do
            if (team.key == nil or team.armyID == nil) then
                log.Warning('SetupPlayerLines cannot find team: '..teamID)
                continue 
            end
            controls.armyLines[index] = CreateArmyLine(team.armyID, team) 
            index = index + 1 
        end
    end
  
    -- create observer's controls
    if sessionReplay then
        local observer = {}
        observer.armyID = 0     -- <- will be between army lines (+IDs) and team lines (-IDs) 
        observer.type = 'observer'
        observer.faction = -1
        observer.color = 'ffffffff'
        observer.nickname = ' '..LOC("<LOC score_0003>Observer")
        observer.nameshort = observer.nickname
        observer.namefull  = observer.nickname
        
        observerLine = CreateArmyLine(observer.armyID, observer)
        observerLine.isObsLine = true
        observerLine.nameColumn.Top:Set(observerLine.Top)
        observerLine.Height:Set(iconSize * 3)
        observerLine.speedText = UIUtil.CreateText(controls.bgStretch, '', 15, UIUtil.bodyFont)
        observerLine.speedText:SetColor('ff00dbff')
        LayoutHelpers.AtRightIn(observerLine.speedText, observerLine, 5)
        observerLine.speedSlider = Slider(controls.bgStretch, false, -10, 10, 1, 
            UIUtil.SkinnableFile('/slider02/slider_btn_up.dds'), 
            UIUtil.SkinnableFile('/slider02/slider_btn_over.dds'), 
            UIUtil.SkinnableFile('/slider02/slider_btn_down.dds'), 
            UIUtil.SkinnableFile('/dialogs/options/slider-back_bmp.dds'))
        observerLine.speedSlider.Left:Set(function() return observerLine.Left() + 10 end)
        observerLine.speedSlider.Right:Set(function() return observerLine.Right() - 25 end)
        observerLine.speedSlider.Bottom:Set(function() return observerLine.Bottom() - 5 end)
        observerLine.speedSlider._background.Left:Set(observerLine.speedSlider.Left)
        observerLine.speedSlider._background.Right:Set(observerLine.speedSlider.Right)
        observerLine.speedSlider._background.Top:Set(observerLine.speedSlider.Top)
        observerLine.speedSlider._background.Bottom:Set(observerLine.speedSlider.Bottom) 
        observerLine.speedSlider._thumb.Depth:Set(function() return observerLine.Depth() + 5 end)
        observerLine.speedSlider._background.Depth:Set(function() return observerLine.speedSlider._thumb.Depth() - 1 end)
        observerLine.speedSlider.OnValueChanged = function(self, newValue)
            observerLine.speedText:SetText(string.format("%+d", math.floor(tostring(newValue))))
        end
        observerLine.speedSlider.OnValueSet = function(self, newValue)
            ConExecute("WLD_GameSpeed "..newValue)
        end
        observerLine.speedSlider:SetValue(gameSpeed)
        
        -- setting a new tooltip for game speed slider because "Lobby_Gen_GameSpeed" does not exist
        --Tooltip.AddControlTooltip(observerLine.speedSlider._thumb, 'Lobby_Gen_GameSpeed')
        Tooltip.AddControlTooltip(observerLine.speedSlider._thumb, str.tooltip('game_speed_slider'))
        Tooltip.AddControlTooltip(observerLine.speedSlider._background, str.tooltip('game_speed_slider'))

        LayoutHelpers.AtVerticalCenterIn(observerLine.speedText, observerLine.speedSlider)
        
        controls.armyLines[index] = observerLine 
        index = index + 1 
    end    
    
    controls.armyLines[index] = CreateSortLine(100)  
    index = index + 1 
        
    controls.armyLines[index] = CreateMapLine(-100)  
    controls.armyLines[index].isMapLine = true
    
    index = index + 1 
    controls.armyLines[index] = CreateInfoLine(-101)  
    controls.armyLines[index].isMapLine = true
    
end
  
function CreateArmyLine(armyID, army)
    local group = Group(controls.bgStretch)
    
    log.Trace('CreateArmyLine()...  armyID = '..armyID..',   color = '..army.color..', type='..army.type..', name = '..army.nickname)
    -- HUSAR: created players' score board using these columns:
    -- --------+---------+--------+------+--------+------------+--------------+--------------------------+
    -- session | icon    | number | text | number | number     | number       | number    | number       |
    -- --------+---------+--------+------+--------+------------+--------------+--------------------------+
    -- Game    | faction | rating | name | score  |            |              |           |              |
    -- Replay  | faction | rating | name | score  | massIncome | energyIncome | massTotal | unitsCount   |
    -- --------+---------+--------+------+--------+------------+--------------+--------------------------+
    
    -- HUSAR: re-arranged players' info that is shared between Game and Replay sessions so that it is defined only once  
    
    local position = 0 -- keep track of horizontal position of data columns
    -- players have positive index, teams have negative index, and zero is for observer
    local isPlayerArmy = army.type == 'player'  --armyID > 0
    local isTeamArmy = army.type == 'team'      --armyID < 0
    local isObserver = army.type == 'observer'  --armyID == 0
    
    local textColor = textColorNickname
    if isPlayerArmy then textColor = army.txtColor end
    if isTeamArmy   then textColor = army.txtColor end
      
    group.isArmyLine = isPlayerArmy
    group.isTeamLine = isTeamArmy
    group.armyID = armyID
    
    group.faction = Bitmap(group)
    group.faction:SetTexture(GetArmyIcon(army.faction))
    group.faction.Height:Set(iconSize)
    group.faction.Width:Set(iconSize)
    group.faction:DisableHitTest()
    LayoutHelpers.AtLeftTopIn(group.faction, group, position)
    
    group.color = Bitmap(group.faction)
    group.color:SetSolidColor(army.color)
    group.color.Depth:Set(function() return group.faction.Depth() - 1 end)
    group.color:DisableHitTest()
    LayoutHelpers.FillParent(group.color, group.faction)
    
    position = position + iconSize + 1
    -- create rating data column
    if (army.rating and (isPlayerArmy or isTeamArmy)) then
        -- HUSAR: added a new column to:
        -- show players' rating on the left side of players' names to make it more visible and to
        -- prevent clipping players' rating by score value
        
        local ratingValue = isPlayerArmy and army.rating.rounded or army.rating.actual
        
        --(showRoundRating and army.rating.rounded or army.rating.actual) 
        --if (isPlayerArmy) then ratingValue = army.rating.rounded and showRoundRating or army.rating.actual end
        --if (isTeamArmy) then ratingValue = army.rating.actual and showRoundRating end
        
        --group.sortBy.raiting = army.rating.actual
        
        local ratingStr = string.format("%4.0f", ratingValue)
        
        group.rating = UIUtil.CreateText(group, ratingStr, fontSize, fontMono)
        group.rating:DisableHitTest()
        group.rating:SetColor(textColor)
        LayoutHelpers.AtLeftIn(group.rating, group, position)
        LayoutHelpers.AtVerticalCenterIn(group.rating, group)
        position = position + sw - 18 -- offset for rating text 12
    end
            
    local armyName = army.nameshort -- army.namefull
    
    group.nameColumn = UIUtil.CreateText(group, armyName, fontSize, fontName)
    group.nameColumn:DisableHitTest()
    --group.nameColumn:SetColor(army.color)
    group.nameColumn:SetColor(textColor)
    LayoutHelpers.AtLeftIn(group.nameColumn, group, position)
    LayoutHelpers.AtVerticalCenterIn(group.nameColumn, group)
    
    -- create score data column
    if (isPlayerArmy or isTeamArmy) then
    
        position = (sw * 4)  
        group.scoreColumn = UIUtil.CreateText(group, '   0', fontSize, fontName)
        group.scoreColumn:DisableHitTest()
        group.scoreColumn:SetColor(textColorScore)
        
        if (sessionReplay) then
            -- offset player's score position in Replay session
            LayoutHelpers.AtRightIn(group.scoreColumn, group, position)
            LayoutHelpers.AtVerticalCenterIn(group.scoreColumn, group)
        else
            -- right-align player's score in Game session 
            LayoutHelpers.AtRightIn(group.scoreColumn, group)
            LayoutHelpers.AtVerticalCenterIn(group.scoreColumn, group)
        end
        
        -- clip player's name by left of score value   
        group.nameColumn.Right:Set(group.scoreColumn.Left)
        --group.nameColumn.Right:Set(position - sw)
        group.nameColumn:SetClipToWidth(true)
    end
    
    -- TODO figure out if it is possible to ACCESS and show info about allied players in Sim mod!
    -- show more player's info only in Replay session 
    if ((isPlayerArmy or isTeamArmy) and sessionReplay) then
        
        -- show player's mass icon
        position = (sw * 3)
        group.massIcon = Bitmap(group)
        group.massIcon:SetTexture(modTextures..'eco.massIncome.dds')
        LayoutHelpers.AtRightIn(group.massIcon, group, position)
        LayoutHelpers.AtVerticalCenterIn(group.massIcon, group)
        group.massIcon.Height:Set(iconSize)
        group.massIcon.Width:Set(iconSize)
        -- show player's mass column
        position = (sw * 3) + iconSize + 1
        group.massColumn = UIUtil.CreateText(group, '0', fontSize, fontName)
        group.massColumn:DisableHitTest()
        group.massColumn:SetColor(textColorMass)
        LayoutHelpers.AtRightIn(group.massColumn, group, position)
        LayoutHelpers.AtVerticalCenterIn(group.massColumn, group)
        
        -- show player's energy icon
        position = (sw * 2) 
        group.engyIcon = Bitmap(group)
        group.engyIcon:SetTexture(modTextures..'eco.engyIncome.dds')
        LayoutHelpers.AtRightIn(group.engyIcon, group, position)
        LayoutHelpers.AtVerticalCenterIn(group.engyIcon, group)
        group.engyIcon.Height:Set(iconSize)
        group.engyIcon.Width:Set(iconSize)
        -- show player's energy column
        position = (sw * 2) + iconSize + 1
        group.engyColumn = UIUtil.CreateText(group, '0', fontSize, fontName)
        group.engyColumn:DisableHitTest()
        group.engyColumn:SetColor(textColorEngy)
        LayoutHelpers.AtRightIn(group.engyColumn, group, position)
        LayoutHelpers.AtVerticalCenterIn(group.engyColumn, group)
            
        -- HUSAR: added a new column to: 
        -- show total produced mass by a player since that is better indicator than just mass reclaim
        -- besides mass reclaim is not synchronized in score data and it cannot be synchronized in UI mods! 
        -- synchronization of mass reclaim in score data would require a change in AIBrain.LUA (Game File)
        position = (sw * 1) 
        -- show player's mass total icon
        group.totalIcon = Bitmap(group)
        group.totalIcon:SetTexture(modTextures..'eco.massTotal.dds')
        LayoutHelpers.AtRightIn(group.totalIcon, group, position)
        LayoutHelpers.AtVerticalCenterIn(group.totalIcon, group)
        group.totalIcon.Height:Set(iconSize)
        group.totalIcon.Width:Set(iconSize)
        -- show player's mass total value
        position = (sw * 1) + iconSize + 1
        group.totalColumn = UIUtil.CreateText(group, '0', fontSize, fontName)
        group.totalColumn:DisableHitTest()
        group.totalColumn:SetColor(textColorMass)
        LayoutHelpers.AtRightIn(group.totalColumn, group, position)
        LayoutHelpers.AtVerticalCenterIn(group.totalColumn, group)
                
        -- HUSAR: added a new column to:
        -- show total units owned by a player since that is good indicator of army strength 
        -- also observer does not have to switch army view to see unit count of a player
        position = (sw * 0) 
        -- show player's units total icon 
        group.unitIcon = Bitmap(group)
        group.unitIcon:SetTexture(modTextures..'units.total.dds')
        LayoutHelpers.AtRightIn(group.unitIcon, group, position)
        LayoutHelpers.AtVerticalCenterIn(group.unitIcon, group)
        group.unitIcon.Height:Set(iconSize)
        group.unitIcon.Width:Set(iconSize)
        -- show player's units total value 
        position = (sw * 0) + iconSize + 1
        group.unitColumn = UIUtil.CreateText(group, '0', fontSize, fontName)
        group.unitColumn:DisableHitTest()
        group.unitColumn:SetColor(textColorUnits)
        LayoutHelpers.AtRightIn(group.unitColumn, group, position)
        LayoutHelpers.AtVerticalCenterIn(group.unitColumn, group)
    end
     
    --local groupHeight = iconSize + 2
    --if (isObserver) then groupHeight = groupHeight + 10 end
    
    group.Width:Set(boardWidth)
    group.Height:Set(lineSize)
    
    -- enable switching view to players' armies or observer 
    if ((isPlayerArmy or isObserver) and sessionReplay) then
    
        group.bg = Bitmap(group)
        group.bg:SetSolidColor('00000000')
        group.bg.Height:Set(group.faction.Height)
        group.bg.Left:Set(group.faction.Right)
        group.bg.Right:Set(group.Right)
        group.bg.Top:Set(group.faction.Top)
        group.bg:DisableHitTest()
        group.bg.Depth:Set(group.Depth)
        group.HandleEvent = function(self, event)
            if event.Type == 'MouseEnter' then
                group.bg:SetSolidColor('ff777777')
            elseif event.Type == 'MouseExit' then
                group.bg:SetSolidColor('00000000')
            elseif event.Type == 'ButtonPress' then
                ConExecute('SetFocusArmy '..tostring(self.armyID-1))
            end
        end
    else
        group:DisableHitTest()
    end
    
    return group
end
 
function CreateSortFilterForEco(group, ecoType)
    local iconPath = modTextures..'eco.'..ecoType..'.dds'
    local checkbox = Checkbox(group,
          iconPath, --'_btn_up.dds'),
          iconPath, --'_btn_over.dds'),
          iconPath, --'_btn_down.dds'),
          iconPath, --'_btn_down.dds'),
          iconPath, --'_btn_dis.dds'),
          iconPath, --'_btn_dis.dds'),
          'UI_Tab_Click_01', 'UI_Tab_Rollover_01')
    checkbox.Height:Set(iconSize)
    checkbox.Width:Set(iconSize)
    checkbox.ecoType = ecoType
    checkbox.OnCheck = function(self, checked)
        if (string.find(ecoType,"mass")) then
            Stats.columnMass = 'eco.'..ecoType
            SortArmyLinesBy(Stats.columnMass) 
        else
            Stats.columnEngy = 'eco.'..ecoType
            SortArmyLinesBy(Stats.columnEngy) 
        end  
    end
    return checkbox        
end
function CreateSortBoxForUnitsColumn(group, unitType)
    local iconPath = modTextures..'units.'..unitType --.. '.dds'
    local checkbox = Checkbox(group,
          iconPath..'_dis.dds',   --'up.dds'),
          iconPath..'.dds',       --'upsel.dds'),
          iconPath..'.dds',   --'over.dds'),          _dis
          iconPath..'_dis.dds',   --'oversel.dds'),
          iconPath..'_dis.dds',   --'dis.dds'),
          iconPath..'_dis.dds',   --'dissel.dds'),
          'UI_Tab_Click_01', 'UI_Tab_Rollover_01')
    checkbox.Height:Set(iconSize)
    checkbox.Width:Set(iconSize)
    checkbox.unitType = 'units.'..unitType
    checkbox:SetCheck(true)
	checkbox:UseAlphaHitTest(true)
    checkbox.OnCheck = function(self, checked)
        Stats.filterUnits['units.'..unitType] = checked
        Stats.columnUnits = ''
        filterAll = true
        -- combine unit filters in columnUnits
        for key,filter in pairs(Stats.filterUnits) do
            if (filter) then
                if (Stats.columnUnits ~= '') then
                    Stats.columnUnits = Stats.columnUnits..'|'
                end
                Stats.columnUnits = Stats.columnUnits ..key
            else
                filterAll = false
            end    
            --LOG('columnUnits ' ..Stats.columnUnits )
        end
        if (filterAll) then 
            Stats.columnUnits = 'units.total' 
        end 
        
        SortArmyLinesBy(Stats.columnUnits)  
    end
    return checkbox        
end
function CreateSortBoxForScoreColumn(group, column, icon, size)
    local iconPath = modTextures..icon
    local checkbox = Checkbox(group,
          iconPath, --'_btn_up.dds'),
          iconPath, --'_btn_over.dds'),
          iconPath, --'_btn_down.dds'),
          iconPath, --'_btn_down.dds'),
          iconPath, --'_btn_dis.dds'),
          iconPath, --'_btn_dis.dds'),
          'UI_Tab_Click_01', 'UI_Tab_Rollover_01')
    checkbox.Height:Set(size)
    checkbox.Width:Set(size) 
    checkbox.OnCheck = function(self, checked)
        Stats.columnScore = column
        SortArmyLinesBy(column) 
    end
    return checkbox
end
function CreateSortBoxForRatingColumn(group, column, icon, size)
    local iconPath = modTextures..icon
    local checkbox = Checkbox(group,
          iconPath, --'_btn_up.dds'),
          iconPath, --'_btn_over.dds'),
          iconPath, --'_btn_down.dds'),
          iconPath, --'_btn_down.dds'),
          iconPath, --'_btn_dis.dds'),
          iconPath, --'_btn_dis.dds'),
          'UI_Tab_Click_01', 'UI_Tab_Rollover_01')
    checkbox.Height:Set(size)
    checkbox.Width:Set(size) 
    checkbox.OnCheck = function(self, checked)
        Stats.columnRating = column
        SortArmyLinesBy(column) 
    end
    return checkbox
end
function CreateSortBoxForNameColumn(group, column, icon, size)
    local iconPath = modTextures..icon
    local checkbox = Checkbox(group,
          iconPath, --'_btn_up.dds'),
          iconPath, --'_btn_over.dds'),
          iconPath, --'_btn_down.dds'),
          iconPath, --'_btn_down.dds'),
          iconPath, --'_btn_dis.dds'),
          iconPath, --'_btn_dis.dds'),
          'UI_Tab_Click_01', 'UI_Tab_Rollover_01')
    checkbox.Height:Set(size)
    checkbox.Width:Set(size) 
    checkbox.OnCheck = function(self, checked)
        Stats.columnName = column
        SortArmyLinesBy(column) 
    end
    return checkbox
end
function CreateSortBoxForTotalColumn(group, column, icon, size)
    local iconPath = modTextures..icon
    local checkbox = Checkbox(group,
          iconPath, --'_btn_up.dds'),
          iconPath, --'_btn_over.dds'),
          iconPath, --'_btn_down.dds'),
          iconPath, --'_btn_down.dds'),
          iconPath, --'_btn_dis.dds'),
          iconPath, --'_btn_dis.dds'),
          'UI_Tab_Click_01', 'UI_Tab_Rollover_01')
    checkbox.Height:Set(size)
    checkbox.Width:Set(size) 
    checkbox.OnCheck = function(self, checked)
        Stats.columnTotal = column
        SortArmyLinesBy(column) 
    end
    return checkbox
end
function CreateSortBoxForGenericColumn(group, column, icon, size)
    local iconPath = modTextures..icon
    local checkbox = Checkbox(group,
          iconPath, --'_btn_up.dds'),
          iconPath, --'_btn_over.dds'),
          iconPath, --'_btn_down.dds'),
          iconPath, --'_btn_down.dds'),
          iconPath, --'_btn_dis.dds'),
          iconPath, --'_btn_dis.dds'),
          'UI_Tab_Click_01', 'UI_Tab_Rollover_01')
    checkbox.Height:Set(size)
    checkbox.Width:Set(size) 
    checkbox.OnCheck = function(self, checked)
        SortArmyLinesBy(column) 
    end
    return checkbox
end
function CreateSortLine(armyID)
     
    log.Trace('CreateSortLine()...  armyID = '..armyID )
    local sortby = Group(controls.bgStretch)
    sortby:DisableHitTest(true)
    sortby.armyID = armyID 
    sortby.isSortLine = true
    sortby.isArmyLine = false
    sortby.isTeamLine = false
    
    -- keep track of horizontal position of data columns
    local position = 0 
    
    sortby.teamID = CreateSortBoxForGenericColumn(sortby, 'teamID', 'army_teams.dds', iconSize)
    LayoutHelpers.AtLeftIn(sortby.teamID, sortby, position)
    LayoutHelpers.AtVerticalCenterIn(sortby.teamID, sortby)
    Tooltip.AddControlTooltip(sortby.teamID, str.tooltip('army_teams'))
	    
    position = position + iconSize + 8
    sortby.ratingR = CreateSortBoxForRatingColumn(sortby, 'rating.rounded', 'army_rating.rounded.dds', iconSize)
    LayoutHelpers.AtLeftIn(sortby.ratingR, sortby, position)
    LayoutHelpers.AtVerticalCenterIn(sortby.ratingR, sortby)
    Tooltip.AddControlTooltip(sortby.ratingR, str.tooltip('army_rating'))

    position = position + iconSize + 15 --sw -- offset for rating text 
    sortby.nameshort = CreateSortBoxForNameColumn(sortby, 'nameshort', 'army_nameshort.dds', iconSize)
    LayoutHelpers.AtLeftIn(sortby.nameshort, sortby, position)
    LayoutHelpers.AtVerticalCenterIn(sortby.nameshort, sortby)
    Tooltip.AddControlTooltip(sortby.nameshort, str.tooltip('army_nameshort'))
	
    position = position + iconSize + 1
    sortby.namefull = CreateSortBoxForNameColumn(sortby, 'namefull', 'army_namefull.dds', iconSize)
    LayoutHelpers.AtLeftIn(sortby.namefull, sortby, position)
    LayoutHelpers.AtVerticalCenterIn(sortby.namefull, sortby)
    Tooltip.AddControlTooltip(sortby.namefull, str.tooltip('army_namefull'))
 
    -- ================================================
    -- create sort boxes for score column
    -- ================================================
    position = (sw * 4)  
    sortby.score = CreateSortBoxForScoreColumn(sortby, 'score', 'score.dds', iconSize)
    LayoutHelpers.AtRightIn(sortby.score, sortby, position)
    LayoutHelpers.AtVerticalCenterIn(sortby.score, sortby)
    Tooltip.AddControlTooltip(sortby.score, str.tooltip('army_score'))
    -- ================================================
     
    -- show more player's info only in Replay session  
    if (sessionReplay) then 
     
        position = position + iconSize + 1
        sortby.killsToLoses = CreateSortBoxForScoreColumn(sortby, 'ratio.killsToLoses', 'ratio.killsToLoses.dds', iconSize)
        LayoutHelpers.AtRightIn(sortby.killsToLoses, sortby, position)
        LayoutHelpers.AtVerticalCenterIn(sortby.killsToLoses, sortby)
        Tooltip.AddControlTooltip(sortby.killsToLoses, str.tooltip('ratio.killsToLoses'))

        position = position + iconSize + 1
        sortby.killsToBuilt = CreateSortBoxForScoreColumn(sortby, 'ratio.killsToBuilt', 'ratio.killsToBuilt.dds', iconSize)
        LayoutHelpers.AtRightIn(sortby.killsToBuilt, sortby, position)
        LayoutHelpers.AtVerticalCenterIn(sortby.killsToBuilt, sortby)
        Tooltip.AddControlTooltip(sortby.killsToBuilt, str.tooltip('ratio.killsToBuilt'))
        
        -- ================================================
        -- create sort boxes for mass column
        -- ================================================
        position = (sw * 3) 
        sortby.massIncome = CreateSortFilterForEco(sortby,'massIncome')
        LayoutHelpers.AtRightIn(sortby.massIncome, sortby, position)
        LayoutHelpers.AtVerticalCenterIn(sortby.massIncome, sortby)
        Tooltip.AddControlTooltip(sortby.massIncome, str.tooltip('eco.massIncome'))
    
        position = position + iconSize + 1
        sortby.massReclaim = CreateSortFilterForEco(sortby,'massReclaim')
        LayoutHelpers.AtRightIn(sortby.massReclaim, sortby, position)
        LayoutHelpers.AtVerticalCenterIn(sortby.massReclaim, sortby)
        Tooltip.AddControlTooltip(sortby.massReclaim, str.tooltip('eco.massReclaim'))
   
        position = position + iconSize + 1
        sortby.massTotal = CreateSortFilterForEco(sortby,'massTotal')
        LayoutHelpers.AtRightIn(sortby.massTotal, sortby, position)
        LayoutHelpers.AtVerticalCenterIn(sortby.massTotal, sortby)
        Tooltip.AddControlTooltip(sortby.massTotal, str.tooltip('eco.massTotal'))
        -- ================================================
        -- create sort boxes for energy column
        -- ================================================
        position = (sw * 2) 
        sortby.engyIncome = CreateSortFilterForEco(sortby,'engyIncome')
        LayoutHelpers.AtRightIn(sortby.engyIncome, sortby, position)
        LayoutHelpers.AtVerticalCenterIn(sortby.engyIncome, sortby)
        Tooltip.AddControlTooltip(sortby.engyIncome, str.tooltip('eco.engyIncome'))
    
        position = position + iconSize + 1
        sortby.engyReclaim = CreateSortFilterForEco(sortby,'engyReclaim')
        LayoutHelpers.AtRightIn(sortby.engyReclaim, sortby, position)
        LayoutHelpers.AtVerticalCenterIn(sortby.engyReclaim, sortby)
        Tooltip.AddControlTooltip(sortby.engyReclaim, str.tooltip('eco.engyReclaim'))
    
        position = position + iconSize + 1
        sortby.engyTotal = CreateSortFilterForEco(sortby,'engyTotal')
        LayoutHelpers.AtRightIn(sortby.engyTotal, sortby, position)
        LayoutHelpers.AtVerticalCenterIn(sortby.engyTotal, sortby)
        Tooltip.AddControlTooltip(sortby.engyTotal, str.tooltip('eco.engyTotal'))
        -- ================================================
        -- create sort boxes for total column
        -- ================================================
        position = (sw * 1) 
        sortby.totalMass = CreateSortBoxForTotalColumn(sortby, 'eco.massTotal', 'eco.massTotal.dds', iconSize)
        LayoutHelpers.AtRightIn(sortby.totalMass, sortby, position)
        LayoutHelpers.AtVerticalCenterIn(sortby.totalMass, sortby)
        Tooltip.AddControlTooltip(sortby.totalMass, str.tooltip('eco.massTotal'))
    
        position = position + iconSize + 1
        sortby.totalMassKills = CreateSortBoxForTotalColumn(sortby, 'kills.mass', 'kills.mass.dds', iconSize)
        LayoutHelpers.AtRightIn(sortby.totalMassKills, sortby, position)
        LayoutHelpers.AtVerticalCenterIn(sortby.totalMassKills, sortby)
        Tooltip.AddControlTooltip(sortby.totalMassKills, str.tooltip('kills.mass'))
     
        position = position + iconSize + 1
        sortby.totalMassLoses = CreateSortBoxForTotalColumn(sortby, 'loses.mass', 'loses.mass.dds', iconSize)
        LayoutHelpers.AtRightIn(sortby.totalMassLoses, sortby, position)
        LayoutHelpers.AtVerticalCenterIn(sortby.totalMassLoses, sortby)
        Tooltip.AddControlTooltip(sortby.totalMassLoses, str.tooltip('loses.mass'))

        -- HUSAR: added a new column to:
        -- show total units owned by a player since that is good indicator of army strength 
        -- also observer does not have to switch army view to see unit count of a player
        -- ================================================
        -- create sort boxes for type of units column
        -- ================================================
        position = (sw * 0) 
        sortby.unitsNavy = CreateSortBoxForUnitsColumn(sortby,'base')
        LayoutHelpers.AtRightIn(sortby.unitsNavy, sortby, position)
        LayoutHelpers.AtVerticalCenterIn(sortby.unitsNavy, sortby)
        Tooltip.AddControlTooltip(sortby.unitsNavy, str.tooltip('units.base'))
     
        position = position + iconSize - 3
        sortby.unitsLand = CreateSortBoxForUnitsColumn(sortby,'air')
        LayoutHelpers.AtRightIn(sortby.unitsLand, sortby, position)
        LayoutHelpers.AtVerticalCenterIn(sortby.unitsLand, sortby)
        Tooltip.AddControlTooltip(sortby.unitsLand, str.tooltip('units.air'))
	 
        position = position + iconSize - 4
        sortby.unitsAir = CreateSortBoxForUnitsColumn(sortby,'land')
        LayoutHelpers.AtRightIn(sortby.unitsAir, sortby, position)
        LayoutHelpers.AtVerticalCenterIn(sortby.unitsAir, sortby)
        Tooltip.AddControlTooltip(sortby.unitsAir, str.tooltip('units.land'))
        
        position = position + iconSize - 4
        sortby.unitsNavy = CreateSortBoxForUnitsColumn(sortby,'navy')
        LayoutHelpers.AtRightIn(sortby.unitsNavy, sortby, position)
        LayoutHelpers.AtVerticalCenterIn(sortby.unitsNavy, sortby)
        Tooltip.AddControlTooltip(sortby.unitsNavy, str.tooltip('units.navy'))
	 
        end 
     
        sortby.Height:Set(iconSize + 5)
        sortby.Width:Set(boardWidth)
    
        return sortby
    end

function CreateMapLine(armyID)

    log.Trace('CreateMapLine()... ') 
    local group = Group(controls.bgStretch)    
    group.armyID = armyID
  
    local mapInfo = Stats.map.info 
     
    group.name = UIUtil.CreateText(group, mapInfo, fontSize, fontName)
    group.name:DisableHitTest()
    group.name:SetColor('ffffffff')
     
    LayoutHelpers.AtVerticalCenterIn(group.name, group, 1)
    LayoutHelpers.AtHorizontalCenterIn(group.name, group)
      
    group.Height:Set(lineSize+2)
    group.Width:Set(boardWidth)        
    
    group:DisableHitTest()
    
    return group
end

-- store parameters for ranked games
local Game = {}  

function CreateInfoLine(armyID)
    local logSource = 'CreateInfoLine()... '
    local group = Group(controls.bgStretch)    
    group.armyID = armyID
     
    log.Trace(logSource)
        
    Game.HasLockedTeams = str.lower(sessionOptions.TeamLock) == "locked"
    Game.HasNoCheating = str.lower(sessionOptions.CheatsEnabled) == "false"
    Game.HasNoPrebuilt = str.lower(sessionOptions.PrebuiltUnits) == "off"
    Game.HasNoRushOff = str.lower(sessionOptions.NoRushOption) == "off"
    Game.HasFogOfWar = str.lower(sessionOptions.FogOfWar) == "explored"
    
    -- TODO check if game is ranked with these options:
    --Game.HasNormalSpeed = str.lower(sessionOptions.GameSpeed) == "normal"
    --Game.HasLowTimeouts = str.lower(sessionOptions.Timeouts) == "3"
    
    if (not Game.HasLockedTeams) then
        log.Trace(logSource..'game is not ranked because teams are unlocked')
    end 
    if (not Game.HasNoCheating) then
        log.Trace(logSource..'game is not ranked because cheating is on')
    end 
    if (not Game.HasNoPrebuilt) then
        log.Trace(logSource..'game is not ranked because prebuilt is on')
    end 
    if (not Game.HasNoRushOff) then
        log.Trace(logSource..'game is not ranked because No Rush is on')
    end 
    --if (not Game.HasFogOfWar) then
    --    log.Trace(logSource..'game is not ranked because Fog of War is off')
    --end
    --if (not Game.HasLowTimeouts) then
    --    log.Trace(logSource..'game is not ranked because Timeouts is not set to three')
    --end 
    --if (not Game.HasNormalSpeed) then
    --    log.Trace(logSource..'game is not ranked because Game Speed is not normal')
    --end 
    
    local position = 0
        
    group.vc = CreateInfoIconVictory(group)
    LayoutHelpers.AtVerticalCenterIn(group.vc, group)
    LayoutHelpers.AtLeftIn(group.vc, group, position)
          
    position = position + iconSize + 3
    group.sc = CreateInfoIconSharing(group)
    LayoutHelpers.AtVerticalCenterIn(group.sc, group)
    LayoutHelpers.AtLeftIn(group.sc, group, position)
           
    position = position + iconSize + 3
    group.ur = CreateInfoIconRestrictions(group)
    LayoutHelpers.AtVerticalCenterIn(group.ur, group)
    LayoutHelpers.AtLeftIn(group.ur, group, position)
      
    position = position + iconSize + 3
    group.mods = CreateInfoIconMods(group)
    LayoutHelpers.AtVerticalCenterIn(group.mods, group)
    LayoutHelpers.AtLeftIn(group.mods, group, position)
         
    position = position + iconSize + 3
    group.ai = CreateInfoIconAI(group)
    LayoutHelpers.AtVerticalCenterIn(group.ai, group)
    LayoutHelpers.AtLeftIn(group.ai, group, position)
      
    position = position + iconSize + 3
    group.rank = CreateInfoIconRanked(group)
    LayoutHelpers.AtVerticalCenterIn(group.rank, group)
    LayoutHelpers.AtLeftIn(group.rank, group, position)
         
    position = position + iconSize + 3
    group.Height:Set(lineSize)
    --group.Width:Set(boardWidth)        
    group.Width:Set(position)        
    group:DisableHitTest()
    
    local center = Group(controls.bgStretch)    
    center.armyID = armyID
    center.Height:Set(lineSize)
    center.Width:Set(boardWidth)        
    center:DisableHitTest()
   
    LayoutHelpers.AtVerticalCenterIn(group, center)
    LayoutHelpers.AtHorizontalCenterIn(group, center)
    
    return center
end
function CreateInfoIcon(iconName, parent)
   local icon = Bitmap(parent)
   icon:SetTexture(modTextures..iconName)
   icon.Height:Set(iconSize)
   icon.Width:Set(iconSize)
   return icon
end
function CreateInfoIconVictory(parent)

    local vc = string.lower(sessionOptions.Victory)
    if (sessionOptions.Victory) then
        key = 'vc_'..vc
    else
        key = 'vc_unknown' 
    end
    local tooltipText = str.loc(key) 
    local tooltipBody = str.loc(key..'_info') 
    
    if (vc == 'demoralization') then
        Game.HasAssassination = true
    else
        Game.HasAssassination = false
    end
        
    local iconName = 'game_victory_' 
    iconName = iconName..(Game.HasAssassination and 'on.dds' or 'off.dds')
    
    local icon = CreateInfoIcon(iconName, parent)
    Tooltip.AddControlTooltip(icon, { text=tooltipText, body=tooltipBody})
    return icon
end
function CreateInfoIconRestrictions(parent)
    local restrictions = sessionOptions.RestrictedCategories
    local restrictionCount = 0
    local tooltipBody = ''
     
    if not restrictions then 
        Game.HasNoRestrictions = true
        tooltipBody = str.loc('ur_NONE')
    else
        Game.HasNoRestrictions = false
        log.Trace('CreateInfoIconRestrictions()... game not ranked because unit restrictions')
        restrictionCount = table.getn(restrictions)
        for _, category in restrictions do
            tooltipKey  = 'ur_'..category
            tooltipBody = '- '..str.loc(tooltipKey)..'\n '..tooltipBody
        end 
    end
    --log.Trace('restrictions='..tooltipBody)
    
    local tooltipText = str.loc('ur')..' ('..restrictionCount..')'
    
    local iconName = 'game_restrictions_' 
    iconName = iconName..(Game.HasNoRestrictions and 'off.dds' or 'on.dds')
    
    local icon = CreateInfoIcon(iconName, parent)
    Tooltip.AddControlTooltip(icon, { text=tooltipText, body=tooltipBody})
    return icon
end
function CreateInfoIconSharing(parent)
    local tooltipShare = ''
    local tooltipCap = ''
    
    if (sessionOptions.Share == nil or 
        sessionOptions.Share == "yes") then
        tooltipShare = str.loc('sc_yes') 
        --Game.HasShareUnits = true
    else -- full share
        tooltipShare = str.loc('sc_no')
        --Game.HasShareUnits = false
    end
     
    if (sessionOptions.ShareUnitCap == nil or 
        sessionOptions.ShareUnitCap == "none") then 
        tooltipCap = str.loc('suc_none') 
        --Game.HasShareCaps = true
    elseif (sessionOptions.ShareUnitCap == "allies") then
        tooltipCap = str.loc('suc_allies') 
        --Game.HasShareCaps = false
    elseif (sessionOptions.ShareUnitCap == "all") then
        tooltipCap = str.loc('suc_all')
        --Game.HasShareCaps = false
    end
    
    local isDefault = (Game.HasShareUnits and Game.HasShareCaps)
    
    local tooltipText = str.loc('sc')  
    local tooltipBody = '- '..tooltipCap..'\n - '..tooltipShare
     
    local iconName = 'game_share_' .. 'on.dds'
    --iconName = iconName..(isDefault and 'on.dds' or 'off.dds')
    
    local icon = CreateInfoIcon(iconName, parent) 
    Tooltip.AddControlTooltip(icon, { text=tooltipText, body=tooltipBody} )
    return icon
end 
function CreateInfoIconAI(parent)
    local tooltipText = str.loc('ai_info')..(Stats.ai.active and ' ON' or ' OFF')
    local tooltipBody = ''
    tooltipBody = '- Income: '..Stats.ai.info.income..'\n '..tooltipBody
    tooltipBody = '- Build:  '..Stats.ai.info.build..'\n '..tooltipBody  
    tooltipBody = '- Omni:   '..Stats.ai.info.omni..'\n '..tooltipBody
     
    if (Stats.ai.active) then
        Game.HasNoAI = false
    else
        Game.HasNoAI = true
    end
        
      
    local iconName = 'game_ai_' 
    iconName = iconName..(Game.HasNoAI and 'off.dds' or 'on.dds')
    
    local icon = CreateInfoIcon(iconName, parent)
    Tooltip.AddControlTooltip(icon, { text=tooltipText, body=tooltipBody} )
    return icon
end
function CreateInfoIconRanked(parent)

    local logSource = 'CreateInfoLine()... '
    local tooltipBody = str.loc('game_ranked_info') 
    local tooltipText = str.loc('game_ranked')
    
    -- game is ranked:
    -- if it is ladder game or
    -- if default game options are set
    
    local isGameRanked = true    
    -- check if the game is marked as ranked ladder game
    if (sessionOptions.Ranked) then
        isGameRanked = true
        tooltipBody = str.loc('game_ranked_ladder') 
    --elseif (sessionOptions.RankedGame) then
    --    if (string.lower(sessionOptions.RankedGame) ~= 'off') then
    --        isGameRanked = true
    --        tooltipBody = str.loc('game_ranked_ladder') 
    --    end
    else
        for key,condition in tab.GetPairs(Game) do
            if (not condition) then
                log.Trace(logSource ..'game not ranked because ' .. key .. ' = false')
                isGameRanked = false
                tooltipBody = tooltipBody..'\n -'
            else
                tooltipBody = tooltipBody..'\n +'
            end   
            tooltipBody = tooltipBody..str.loc('game_ranked_'..key)
        end
    end         
    
    tooltipText = tooltipText..(isGameRanked and ' ON' or ' OFF')
    
    local iconName = 'game_rank_' 
    iconName = iconName..(isGameRanked and 'on.dds' or 'off.dds')
     
    local icon = CreateInfoIcon(iconName, parent)
    Tooltip.AddControlTooltip(icon, { text=tooltipText, body=tooltipBody} )
    return icon
end
function CreateInfoIconMods(parent)
    local mods = GetActiveMods()
     
    local simModsCount = 0
    local uioModsCount = 0
    local simMods = ''
    local uioMods = ''
    for k, mod in mods do
		if mod.ui_only then 
		    uioMods = mod.type..' '..mod.name..'\n '..uioMods
			uioModsCount = uioModsCount + 1 
        else
            simMods = mod.type..' '..mod.name..'\n '..simMods
			simModsCount = simModsCount + 1 
        end
    end
     
    local tooltipBody = uioMods .. simMods
    local tooltipText = str.loc('game_mods')..' ('..simModsCount..'/'..uioModsCount..')'
    tooltipText = tooltipText..' '
    
    Game.HasNoSimMods = simModsCount == 0
    
    local iconName = 'game_mods_' 
    iconName = iconName..(Game.HasNoSimMods and 'off.dds' or 'on.dds')
    
    local icon = CreateInfoIcon(iconName, parent)
    Tooltip.AddControlTooltip(icon, { text=tooltipText, body=tooltipBody} )
    return icon
end
--------------------------------------------------------------------------
-- Data functions
--------------------------------------------------------------------------
-- gets player's name using its army index
function GetArmyName(armyIndex)
    local armyName = ''
    local armies = GetArmiesTable().armiesTable
    for armyID,army in armies do
        if armyID == armyIndex then
            armyName = army.nickname
        end
	end 
    return armyName
end
-- gets player's clan name using its army name
function GetArmyClan(armyName)
    --local armyName = GetArmyName(armyIndex)
    local clans = sessionOptions.ClanTags 
    if (clans == nil) then return "" end
    local tag = sessionOptions.ClanTags[armyName]
    if (tag == nil or tag == "") then return "" end
    return "["..tag.."] " 
end
-- gets army's rating using its army index or AI type/multipliers
function GetArmyRating(armyIndex)
    local armyName = GetArmyName(armyIndex)
    local rating = {}
    rating.actual = sessionOptions.Ratings[armyName]
    if (rating.actual == nil or string.find(armyName,"%(AI")) then
        rating.base = 0
        -- AI Base Rating
            if (string.find(armyName,"AIx")) then rating.base = 500 
        elseif (string.find(armyName,"AI"))  then rating.base = 100
        end   
        -- AI Specialization Bonus
            if (string.find(armyName,"Adaptive"))then rating.base = rating.base + 250 
        elseif (string.find(armyName,"Tech"))    then rating.base = rating.base + 250
        elseif (string.find(armyName,"Air"))     then rating.base = rating.base + 250
        elseif (string.find(armyName,"Water"))   then rating.base = rating.base + 200
        elseif (string.find(armyName,"Random"))  then rating.base = rating.base + 200
        elseif (string.find(armyName,"Rush"))    then rating.base = rating.base + 100
        elseif (string.find(armyName,"Turtle"))  then rating.base = rating.base +  50
        elseif (string.find(armyName,"Normal"))  then rating.base = rating.base +  25
        end 
        -- AI Sorian Bonus
        if (string.find(armyName,"Sorian"))      then rating.base = rating.base + 250  
        end   
       
        --TODO include AI omni setting in rating calculation
        
        -- AI multipliers Bonus as product of percentage of AI base rating and
        -- ratio of current AI multipliers and maximum AI multipliers
        rating.cheat = rating.base * 0.9 * (Stats.ai.cheat.income / 6.0) 
        rating.build = rating.base * 1.1 * (Stats.ai.cheat.build  / 6.0) 
        --log.Trace('rating = '..rating.base.."+"..rating.build.."+"..rating.cheat)
        
        -- AI actual rating as sum of AI base rating plus build and cheat ratings
        rating.actual = rating.base + rating.build + rating.cheat                      
        -- Maximum possible rating (3000) will have AIx Sorian Adaptive (1000) 
        -- with maximum build (6.0) and cheat (6.0) multipliers
        -- rating.cheat   = 1000 * 0.9 * (6.0 / 6.0) =  900     
        -- rating.build   = 1000 * 1.1 * (6.0 / 6.0) = 1100   
        -- rating.actual  = 1000 + 900 + 1100        = 3000  

    end
    rating.rounded = num.round100(rating.actual)
   
    return rating
end
function GetArmyTableKills()
    local kills = {}
    -- kills in units' value
    kills.mass  = 0
    kills.engy  = 0
    -- kills in units' count
    kills.acu   = 0
    kills.air   = 0
    kills.exp   = 0
    kills.navy  = 0
    kills.land  = 0
    kills.base  = 0
    kills.count = 0
    -- hold temp. ACU kills
    kills.tmp   = 0
    
    return kills
end
function GetArmyTableLoses()
    local loses = {}
    -- loses in units' value
    loses.mass = 0
    loses.engy = 0
    -- loses in units' count
    loses.acu   = 0
    loses.air   = 0
    loses.exp   = 0
    loses.navy  = 0
    loses.land  = 0
    loses.base  = 0
    loses.count = 0
    -- hold temp. ACU loses
    loses.tmp   = 0
    
    return loses
end
function GetArmyTableUnits()
    local units = {}
    -- units built by value
    units.mass  = 0
    units.engy  = 0
    -- units by type
    units.acu   = 0
    units.air   = 0
    units.exp   = 0
    units.navy  = 0
    units.land  = 0
    units.base  = 0
    -- units counter
    units.total = 0
    units.cap   = 0
    return units
end
function GetArmyTableEco()
    local eco = {}
    eco.massIncome  = 0
    eco.massTotal   = 0
    eco.massSpent   = 0
    eco.massReclaim = 0
     
    eco.engyIncome  = 0
    eco.engyTotal   = 0
    eco.engySpent   = 0
    eco.engyReclaim = 0
    return eco
end
function GetArmyTableRatio()
    local ratio = {}
    ratio.killsToBuilt = 0  
    ratio.killsToLoses = 0  
    ratio.builtToLoses = 0  
    return ratio
end
-- Gets HD icons for specified faction ID or defaults to standard icons if faction not found
function GetArmyIcon(factionID)
        if (factionID == 0)  then return modTextures..'faction_uef.dds'    
    elseif (factionID == 1)  then return modTextures..'faction_aeon.dds'
    elseif (factionID == 2)  then return modTextures..'faction_cybran.dds'
    elseif (factionID == 3)  then return modTextures..'faction_seraphim.dds'
    elseif (factionID == 4)  then return modTextures..'faction_nomad.dds'
    elseif (factionID == -1) then return modTextures..'faction_observer.dds'
    elseif (factionID == -2) then return modTextures..'faction_team.dds'
    else -- default to standard faction icons                    
        return UIUtil.UIFile(UIUtil.GetArmyIcon(factionID))
    end
end
function GetActiveUIMods()
    local mods = GetActiveMods()
    local uiMods = {}
    for _, mod in mods do
		if mod.ui_only then 
            uiMods[mod.uid] = mod 
		end 
	end
	return uiMods
end
function GetActiveSimMods()
    local mods = GetActiveMods()
    local gameMods = {}
    for _, mod in mods do
		if not mod.ui_only then 
            gameMods[mod.uid] = mod 
		end 
	end
	return gameMods
end
function GetActiveMods()
    local activeMods = {}
	--local mods = import('/lua/mods.lua') 
    -- get uID for selected mods
    --local selectedMods = mods.GetSelectedMods()
    --for _, mod in mods.AllMods() do
	--	if selectedMods[mod.uid] then
    --        mod.type = (mod.ui_only and 'UI' or 'SIM')
    --        log.Trace('GetActiveMods()... '..mod.type..' '..mod.name)
    --        activeMods[mod.uid] = mod 
	--	end
	--end
    for _, mod in __active_mods do  
		mod.type = (mod.ui_only and '(UI)' or '(SIM)')
        log.Trace('GetActiveMods()... '..mod.type..' '..mod.name)
		activeMods[mod.uid] = mod 
	end
	return activeMods
end
-- get army Stats using deep table search, column = Stats.'eco.massIncome'
function GetStatsForArmyID(armyID, column, useFormatting)
    -- default to army Stats with out formatting
    if (useFormatting == nil) then useFormatting = false end
   
    local army = {}
    if (armyID > 0) then
        army = Stats.armies[armyID] 
    else -- teams
        army = Stats.teams[armyID] 
    end
   
    return GetStatsForArmy(army, column, useFormatting) 
end
function GetStatsForArmy(army, column, useFormatting)
    -- default to army Stats with formatting
    if (useFormatting == nil) then useFormatting = true end
    
    if (army == nil) then
        log.Warning('GetStatsForArmy -> army is nil and column is '..column) 
        return -1
    end
     
    local val = tab.Get(army, column)
    -- don't format strings
    if (type(val) == "string") then
        useFormatting = false
    end
    
    if (not useFormatting) then
        return val
    else -- override formatting for these columns
        if (column == 'ratio.killsToBuilt' or 
            column == 'ratio.killsToLoses' or
            column == 'ratio.builtToLoses') then
            val = string.format("%01.2f", val) 
        elseif (column == 'rating.rounded' or 
                column == 'rating.actual') then
            val = string.format("%4.0f", val)  
        else
            val = num.frmt(val)
        end
        
        return val
    end
end
-- create team for index or player's army
function CreateTeam(armyIndex, armies)
    local team = {} 
    team.key = ''
    team.dead = false
    team.faction = -2 -- used for T symbol
    team.nickname  = "TEAM"
    team.nameshort = "TEAM"
    team.namefull  = "TEAM"
    team.type = "team"
    team.color = 'ffffffff'
    team.colors = {}
    
    team.score = 0 
    team.units = GetArmyTableUnits() 
    team.ratio = GetArmyTableRatio()
    team.kills = GetArmyTableKills() 
    team.loses = GetArmyTableLoses() 
    team.eco   = GetArmyTableEco() 
    team.rating = {}
    team.rating.actual = 0
    team.rating.rounded = 0
    
    team.number = 0
	team.members = {}
    team.members.alive = 0
    team.members.count = 0
    team.members.ids   = {}
    
	for armyID,army in armies do 
        --if army.civilian or armyID == armyIndex then continue end
        if army.civilian then continue end
        if IsAlly(armyID, armyIndex) then
			-- use first player's color as team's color 
            if (team.key == '') then team.color = army.color end
            
            -- build unique key for the team using id of allied players            
            team.key = team.key..armyID
            team.rating.actual = team.rating.actual + army.rating.actual
        
            table.insert(team.members.ids, armyID)
            table.insert(team.colors, army.color)
        end
	end
    
    -- assume all players are alive and these values will be updated later
    team.members.alive   = table.getn(team.members.ids)
    team.members.count   = table.getn(team.members.ids)
    
    team.rating.actual  = team.rating.actual / team.members.count
    team.rating.rounded = num.round100(team.rating.actual)
    
    --team.colorsCount = table.getn(team.colors)
   
    UpdateTeamStatus(team, armies) 
    UpdateTeamColor(team, armies)
    
	return team
end
function IsArmyAlive(armyID)
    local armies = GetArmiesTable().armiesTable 
    return IsArmyAlive(armyID, armies)
end
function IsArmyAlive(armyID, armies)
    local army = armies[armyID]
    return not army.outOfGame
end
function GetMapData(sessionInfo)
    local map = {}
    --map.name = LOCF("<LOC gamesel_0002>Map: %s", sessionInfo.name)
    map.name = LOCF("<LOC gamesel_0002>%s", sessionInfo.name)
    map.size = {}
    map.size.pixels = sessionInfo.size
    map.size.actual = {}
    map.size.actual.width  = (5 * math.floor(map.size.pixels[1] / 256))
    map.size.actual.height = (5 * math.floor(map.size.pixels[2] / 256))
    map.size.info = ' ('
    map.size.info = map.size.info..map.size.actual.width .." x " 
    map.size.info = map.size.info..map.size.actual.height.." km)" 
     
    map.info = map.name..' '..map.size.info
      
    return map
end
function GetAiData(sessionInfo)
    local options = sessionInfo.Options
    ai = {}
    -- activate AI when there is at least one AI player
    ai.active = false
    ai.cheat = {}
    ai.cheat.income = tonumber(options.CheatMult) or 0
    ai.cheat.build  = tonumber(options.BuildMult) or 0
    ai.cheat.omni = options.OmniCheat
   
    ai.info = {}
    ai.info.income = string.format("%01.1f", ai.cheat.income)
    ai.info.build  = string.format("%01.1f", ai.cheat.build)
    ai.info.omni   = (ai.cheat.omni and 'ON' or 'OFF')
         
    return ai
end
--------------------------------------------------------------------------
-- Update functions
--------------------------------------------------------------------------
function UpdateRatioFor(army)
     
    local skipAcuUpdates = 5.0
        
    local killsMass = army.kills.mass
    local killsEngy = army.kills.engy
    -- exclude ACU kills for more comparable ratio between players
    if (army.kills.acu > 0) then
        -- there is small delay in sync. between ACU kills and mass kill
        -- so skip a few updates of ACU kills to prevents temp. negative ratio
        if (army.kills.acu > army.kills.tmp) then
            army.kills.tmp = army.kills.tmp + (1.0 / skipAcuUpdates)
        else
            -- TODO look up cost of ACU instead of hard coding it here
            killsMass = killsMass - (army.kills.acu * 18000)
            killsEngy = killsEngy - (army.kills.acu * 5000000)
        end
    end
    
    local losesMass = army.loses.mass
    local losesEngy = army.loses.engy
    -- exclude ACU loses for more comparable ratio between players
    if (army.loses.acu > 0) then
        -- there is small delay in sync. between ACU loses and mass loses
        -- so skip a few updates of ACU loses to prevents temp. negative ratio
        if (army.loses.acu > army.loses.tmp) then
            army.loses.tmp = army.loses.tmp + (1.0 / skipAcuUpdates)
        else
            -- TODO look up cost of ACU instead of hard coding it here
            losesMass = losesMass + (army.loses.acu * 18000)
            losesEngy = losesEngy + (army.loses.acu * 5000000)
        end
    end
    -- use both mass and energy to calculate player's ratios
    local massBuiltRatio = num.div(killsMass, army.units.mass)
    local engyBuiltRatio = num.div(killsEngy, army.units.engy)
    army.ratio.killsToBuilt = (massBuiltRatio + engyBuiltRatio) / 2.0  
    
    local massLostRatio = num.div(killsMass, losesMass)
    local engyLostRatio = num.div(killsEngy, losesEngy)
    army.ratio.killsToLoses = (massLostRatio + engyLostRatio) / 2.0  
      
    local massRatio = num.div(army.units.mass, losesMass)
    local engyRatio = num.div(army.units.engy, losesEngy)
    army.ratio.builtToLoses = (massRatio + engyRatio) / 2.0  
 
end
-- update Stats of a player 
function UpdatePlayerStats(armyID, armies, scoreData)
    local player = Stats.armies[armyID]
    
    if (player == nil) then
        log.Warning('UpdatePlayerStats player is nill for armyID: '..armyID )
    end 
    
    -- get player's eco Stats from score data and initialize it to zero if nil score
    player.dead = armies[armyID].outOfGame
    
    if (not scoreData)               then log.Warning('UpdatePlayerStats scoreData is nil' ) end
    if (not scoreData.general)       then log.Warning('UpdatePlayerStats scoreData.general is nil' ) end
    if (not scoreData.general.score) then log.Warning('UpdatePlayerStats scoreData.general.score is nil' ) end
     
    -- for dead/alive players, get only some score info 
    player.score = num.init(scoreData.general.score)
    -- get player's eco Stats and initialize it to zero if nil score
    player.eco.massTotal  = num.init(scoreData.resources.massin.total)
    player.eco.massSpent  = num.init(scoreData.resources.massout.total)
    player.eco.engyTotal  = num.init(scoreData.resources.energyin.total)
    player.eco.engySpent  = num.init(scoreData.resources.energyout.total)
    -- assume FAF patch #### added reclaim values to score data
    player.eco.massReclaim  = num.init(scoreData.resources.massin.reclaim)
    player.eco.engyReclaim  = num.init(scoreData.resources.energyout.reclaim)
        
    -- get player's kills Stats from score data and initialize it to zero if they are nil
    player.kills.acu   = num.init(scoreData.units.cdr.kills)
    player.kills.exp   = num.init(scoreData.units.experimental.kills)
    player.kills.air   = num.init(scoreData.units.air.kills)
    player.kills.navy  = num.init(scoreData.units.naval.kills)
    player.kills.land  = num.init(scoreData.units.land.kills)
    player.kills.base  = num.init(scoreData.units.structures.kills)
    player.kills.count = num.init(scoreData.general.kills.count)
    player.kills.mass  = num.init(scoreData.general.kills.mass)
    player.kills.engy  = num.init(scoreData.general.kills.energy)
    -- get player's loses Stats from score data and initialize it to zero if they are nil
    player.loses.acu   = num.init(scoreData.units.cdr.lost)
    player.loses.exp   = num.init(scoreData.units.experimental.lost)
    player.loses.air   = num.init(scoreData.units.air.lost)
    player.loses.navy  = num.init(scoreData.units.naval.lost)
    player.loses.land  = num.init(scoreData.units.land.lost)
    player.loses.base  = num.init(scoreData.units.structures.lost)
    player.loses.count = num.init(scoreData.general.lost.count)
    player.loses.mass  = num.init(scoreData.general.lost.mass)
    player.loses.engy  = num.init(scoreData.general.lost.energy)
        
    player.units.mass  = num.init(scoreData.general.built.mass)
    player.units.engy  = num.init(scoreData.general.built.energy)
        
    -- dead players have not income and no units
    if (player.dead) then
        player.eco.massIncome = 0
        player.eco.engyIncome = 0
        
        player.units.total = 0
        player.units.cap   = 0
        player.units.acu   = 0
        player.units.exp   = 0
        player.units.air   = 0
        player.units.navy  = 0
        player.units.base  = 0
        player.units.land  = 0
    else
        player.eco.massIncome = num.init(scoreData.resources.massin.rate)   * 10 -- per game ticks
        player.eco.engyIncome = num.init(scoreData.resources.energyin.rate) * 10 -- per game ticks
        -- get player's units Stats from score data and initialize it to zero if nil score
        player.units.total = num.init(scoreData.general.currentunits.count)
        player.units.cap   = num.init(scoreData.general.currentcap.count)
        player.units.acu   = num.subt0(scoreData.units.cdr.built, scoreData.units.cdr.lost)
        player.units.exp   = num.subt0(scoreData.units.experimental.built, scoreData.units.experimental.lost)
        player.units.air   = num.subt0(scoreData.units.air.built, scoreData.units.air.lost)
        player.units.navy  = num.subt0(scoreData.units.naval.built, scoreData.units.naval.lost)
        player.units.base  = num.subt0(scoreData.units.structures.built, scoreData.units.structures.lost)
        player.units.land  = num.subt0(scoreData.units.land.built, scoreData.units.land.lost)
         
        --  
        if (player.announcements.exp < player.units.exp and 
            player.announcements.exp < 2) then
            player.announcements.exp = player.units.exp
            msgFrom = player.namefull..' - '..player.teamName..''
            msgInfo = 'HAS BUILT AN EXPERIMENTAL UNIT!'
            --msgInfo = msgInfo..' ('..player.units.exp..')'
            ArmyAnnounce(player.armyID, msgFrom, msgInfo)
        end
    end
 
    -- update Stats for all players that will be visible in observer view
    Stats.units.total  = Stats.units.total + player.units.total
    Stats.units.cap    = Stats.units.cap   + player.units.cap
    
    UpdateRatioFor(player) 
    
    local team = Stats.teams[player.teamID]
    if (team == nil) then
        log.Warning('UpdatePlayerStats cannot find a team for player: '..player.nickname )
    else
        UpdateTeamStats(team, player)
    end
    
    return player
end
-- update Stats a team that has the player
function UpdateTeamStats(team, player)
   
   if (Stats.teamsActive and team ~= nil) then
        --log.Trace('UpdatePlayerStats team.key  ='..team.teamID )
        --log.Trace('UpdatePlayerStats team.size='..team.size )
        --log.Trace('UpdatePlayerStats team.name='..team.nickname )
        team.score = team.score + player.score
        
        team.eco.massTotal   = team.eco.massTotal   + player.eco.massTotal
        team.eco.massSpent   = team.eco.massSpent   + player.eco.massSpent
        team.eco.engyTotal   = team.eco.engyTotal   + player.eco.engyTotal
        team.eco.engySpent   = team.eco.engySpent   + player.eco.engySpent
        team.eco.massReclaim = team.eco.massReclaim + player.eco.massReclaim
        team.eco.engyReclaim = team.eco.engyReclaim + player.eco.engyReclaim
        -- update team's kills Stats
        team.kills.acu   = team.kills.acu   + player.kills.acu
        team.kills.exp   = team.kills.exp   + player.kills.exp
        team.kills.air   = team.kills.air   + player.kills.air
        team.kills.navy  = team.kills.navy  + player.kills.navy
        team.kills.land  = team.kills.land  + player.kills.land
        team.kills.base  = team.kills.base  + player.kills.base
        team.kills.count = team.kills.count + player.kills.count
        team.kills.mass  = team.kills.mass  + player.kills.mass
        team.kills.engy  = team.kills.engy  + player.kills.engy
        -- update team's kills Stats
        team.loses.acu   = team.loses.acu   + player.loses.acu
        team.loses.exp   = team.loses.exp   + player.loses.exp
        team.loses.air   = team.loses.air   + player.loses.air
        team.loses.navy  = team.loses.navy  + player.loses.navy
        team.loses.land  = team.loses.land  + player.loses.land
        team.loses.base  = team.loses.base  + player.loses.base
        team.loses.count = team.loses.count + player.loses.count
        team.loses.mass  = team.loses.mass  + player.loses.mass
        team.loses.engy  = team.loses.engy  + player.loses.engy
        
        -- dead players have no income and no units
        if (not player.dead) then
            -- update team's eco
            team.eco.massIncome = team.eco.massIncome + player.eco.massIncome
            team.eco.engyIncome = team.eco.engyIncome + player.eco.engyIncome
            -- update team's units
            team.units.mass  = team.units.mass  + player.units.mass
            team.units.engy  = team.units.engy  + player.units.engy
            team.units.total = team.units.total + player.units.total
            team.units.cap   = team.units.cap   + player.units.cap
            team.units.acu   = team.units.acu   + player.units.acu
            team.units.exp   = team.units.exp   + player.units.exp
            team.units.air   = team.units.air   + player.units.air
            team.units.navy  = team.units.navy  + player.units.navy
            team.units.base  = team.units.base  + player.units.base
            team.units.land  = team.units.land  + player.units.land
        end
        -- sum team/player ratio values and then average them by alive players in OnBeat function
        team.ratio.killsToBuilt = team.ratio.killsToBuilt + player.ratio.killsToBuilt
        team.ratio.killsToLoses = team.ratio.killsToLoses + player.ratio.killsToLoses
          
    end
                                     
end
-- update team color based on alive members and prioritizing 'nice colors'
function UpdateTeamColor(team, armies)
    -- log.Trace('UpdateTeamColor  '..team.key)
    team.colorChanged = false
    
    -- TODO improve logic so that there is no need for color searching
    for _, item in Colors do 
        for _,armyID in team.members.ids do
      
            local army = armies[armyID]
            if (army.outOfGame) then continue end
      
            if army.color == item.armyColor then
                --log.Trace('UpdateTeamColor()... team.color= '..army.color)
                team.color    = item.armyColor
                team.txtColor = item.textColor
                team.colorChanged = true
                return 
            end
        end
    end 
    
end
function UpdateTeamStatus(team, armies)
    team.members.alive   = 0
    for _,armyID in team.members.ids do
    
        if (IsArmyAlive(armyID, armies)) then 
            team.members.alive = team.members.alive + 1
        end
    end
    -- TODO show team status using faction icons of the team's members
    team.status = ' ('..team.members.alive..'/'..team.members.count..')' 
    team.dead   = team.members.alive == 0
     
    team.nameshort = team.nickname..team.status 
    team.namefull  = team.nickname..team.status 
end

function UpdateTimer()
    -- HUSAR: optimized updates to the controls.time UI element, 
    -- HUSAR: added game speed info when no rush timer is counting down
    local sessionSpeed = string.format("%+d/%+d", gameSpeed, GetSimRate() )
    local sessionTimer = "00:00:00"
    if sessionOptions.NoRushOption and sessionOptions.NoRushOption != 'Off' then
        local rushTimeOut = tonumber(sessionOptions.NoRushOption) * 60
        if rushTimeOut > GetGameTimeSeconds() then
            local time = rushTimeOut - GetGameTimeSeconds()
            local timeHH =  math.floor(time / 3600)
            local timeMM =  math.floor(time / 60)
            local timeSS =  math.mod(time, 60)
            sessionTimer = string.format("%02d:%02d:%02d", timeHH, timeMM, timeSS ) 
        end
        local gameTimeElapsed = math.floor(GetGameTimeSeconds())
        if not issuedNoRushWarning and rushTimeOut == gameTimeElapsed then
            Announcement.CreateAnnouncement('<LOC score_0001>No Rush Time Elapsed', controls.time)
            sessionOptions.NoRushOption = 'Off'
            issuedNoRushWarning = true
        end
    else
        sessionTimer = GetGameTime()       
    end
    
    -- HUSAR: added info about game quality
    local sessionQuality = '--%'
    if (sessionOptions.Quality) then
        sessionQuality = string.format("%.0f%%", sessionOptions.Quality)
    end
    
    --controls.time:SetText(string.format("%s %s", sessionTimer, sessionSpeed ))        
    controls.time:SetText(string.format("%s", sessionTimer ))
    controls.speed:SetText(string.format("%s", sessionSpeed))
    controls.quality:SetText(string.format("%s", sessionQuality))
end
function UpdateUnitsInfo(current, cap)
    controls.units:SetText(num.frmt(current).. '/'..num.frmt(cap))
    -- HUSAR: added check to avoid displaying unit cap message for dead player
    if cap != 0 and cap == current then
        if (not lastUnitWarning or GameTime() - lastUnitWarning > 60) and not unitWarningUsed then
            --LOG('>>>> units: ', current, ' cap: ', cap)
            Announcement.CreateAnnouncement(LOC('<LOC score_0002>Unit Cap Reached'), controls.units)
            lastUnitWarning = GameTime()
            unitWarningUsed = true
        end
    else
        unitWarningUsed = false
    end
end
function UpdateArmyLines(column)
    
    if (not sessionReplay) then return end
    -- some column sorting does not require updating
    if (column == 'rating.actual' or
        column == 'rating.rounded' or
        column == 'teamID' or
        column == 'armyID') then return end
          
    for _, line in controls.armyLines do
        -- skip lines without players/teams
        if line.isObsLine or 
           line.isMapLine or 
           line.isSortLine then 
           continue
        end
         
        -- skip lines with alive players/teams 
        -- because they will be updated OnBeat()
        --if not line.dead then continue end
        --local useFormating = column ~= Stats.columnRating
        
        local value = GetStatsForArmyID(line.armyID, column, true)
        
        if (column == Stats.columnName) then
            line.nameColumn:SetText(value) 
            continue
        end
        
        if (column == Stats.columnMass) then
            line.massColumn:SetText(value)
            line.massIcon:SetTexture(modTextures..column..'.dds')
        end    
        if (column == Stats.columnEngy) then 
            line.engyColumn:SetText(value)
            line.engyIcon:SetTexture(modTextures..column..'.dds')
        end   
        if (column == Stats.columnRating) then 
            log.Trace('UpdateArmyLines '..column..' '..line.armyID..' = '..value)
            line.rating:SetText(value)
            --line.engyIcon:SetTexture(modTextures..column..'.dds')
        end   
                
        if (column == Stats.columnTotal) then 
            line.totalColumn:SetText(value)
            line.totalIcon:SetTexture(modTextures..column..'.dds')
            
            if (line.dead) then
                line.totalColumn:SetColor(armyColorDefeted)
            elseif (column == 'eco.massTotal') then
                line.totalColumn:SetColor(textColorMass)
            elseif (column == 'kills.mass') then
                line.totalColumn:SetColor(textColorKills)
            elseif (column == 'loses.mass') then
                line.totalColumn:SetColor(textColorLoses)
            end
            
            
        end    
        if (column == Stats.columnScore) then 
            line.scoreColumn:SetText(value)
            
            if (line.dead) then
                line.scoreColumn:SetColor(armyColorDefeted)
            elseif (column == 'score') then
                line.scoreColumn:SetColor(textColorScore)
            elseif (column == 'ratio.killsToLoses') then
                line.scoreColumn:SetColor(textColorKills)
            elseif (column == 'ratio.killsToBuilt') then
                line.scoreColumn:SetColor(textColorMass)
            end
        --TODO units and score columns
        --else        
            --log.Trace('UpdateArmyLines not supported for: '..column..' ...')
        end
    end
end
-- resets team Stats before updating teams with their team members
function ResetTeamStats()
    Stats.units  = GetArmyTableUnits() 
    
    for key,team in Stats.teams do  
        team.score = 0 
        team.eco   = GetArmyTableEco()
        team.kills = GetArmyTableKills()
        team.loses = GetArmyTableLoses()
        team.units = GetArmyTableUnits()
        team.ratio = GetArmyTableRatio() 
    end
end

function KillArmyLine(line)
    line.dead = true
                            
    -- gray out faction, score, name of dead player/team
    line.faction:SetTexture(modTextures..'army_dead.dds')
    line.color:SetSolidColor('ff000000')
    line.rating:SetColor(armyColorDefeted)
    line.scoreColumn:SetColor(armyColorDefeted)
    line.nameColumn:SetColor(armyColorDefeted)
    line.nameColumn:SetFont(fontName, fontSize)
                           
    if sessionReplay then
        line.totalColumn:SetColor(armyColorDefeted)
        line.massColumn:SetColor(armyColorDefeted)
        line.engyColumn:SetColor(armyColorDefeted)
        line.unitColumn:SetColor(armyColorDefeted) 
        line.unitColumn:SetText('0')
    end
end

local logArmyScore = false
 
function _OnBeat()

        -- HUSAR: moved code for updating timer to a new function
        UpdateTimer()
        -- HUSAR: added variables to keep tack of all units in the game (in observer view)
        ResetTeamStats()
        --log.Trace('OnBeat GetArmiesTable '  )

        if (logArmyScore) then
            logArmyScore = false
            log.Table(currentScores, 'scoreData') 
        end
  
        local focusedArmyID = GetFocusArmy()

        local armies = GetArmiesTable().armiesTable
        
        if currentScores and controls.armyLines then
            -- first update players' lines and show new score data
            for lineID, line in controls.armyLines do
            
                -- skip lines without players
                if not line.isArmyLine then continue end
                
                local armyID = line.armyID
                local scoreData = currentScores[armyID]
                
                --log.Trace('OnBeat updating army line: '..line.armyID..' '..armyID)
                      
                if (not scoreData) then continue end
                 
                -- Stats must be updated even for dead players so that team Stats are accurate 
                local player = UpdatePlayerStats(armyID, armies, scoreData)
                if line.dead then 
                    if sessionReplay and focusedArmyID == armyID then
                        UpdateUnitsInfo(0, 0) 
                    end 
                    continue
                end    
                
                if sessionReplay then
                    if (scoreData.resources.massin.rate) then
                        --TODO append * to text of line.name if player.kills.cdr > 0
                        line.totalColumn:SetText(GetStatsForArmy(player, Stats.columnTotal))
                        line.massColumn:SetText(GetStatsForArmy(player, Stats.columnMass))
                        line.engyColumn:SetText(GetStatsForArmy(player, Stats.columnEngy))
                        line.unitColumn:SetText(GetStatsForArmy(player, Stats.columnUnits))
                    end
                else
                    -- TODO show Stats of team-mates in game session!
                    -- this will require change in FAF sync/share files 
                    -- because these Stats are not shared at this moment in UI mods
                end
                
                -- update army's score
                if player.score == -1 then
                    line.scoreColumn:SetText(LOC("<LOC _Playing>Playing"))
                    line.scoreColumn:SetFont(UIUtil.bodyFont, fontSize)
                else
                    line.scoreColumn:SetText(' '..GetStatsForArmy(player, Stats.columnScore))
                end        
                
                if focusedArmyID == armyID then
                    --line.rating:SetFont(fontMonoBold, fontSize)
                    line.rating:SetColor(armyColorAllied) 
                    line.nameColumn:SetColor(armyColorAllied)
                    line.nameColumn:SetFont('Arial Bold', fontSize)
                    
                    UpdateUnitsInfo(player.units.total, player.units.cap)
                    --if (logArmyScore) then
                    --    logArmyScore = false
                    --    log.Table(scoreData,player.nickname..'.score')
                    --    --log.Table(armies[armyID],player.nickname..'.army')
                    --end
                elseif focusedArmyID != -1 then
                    -- color allies with green and enemies with red
                    line.nameColumn:SetFont(UIUtil.bodyFont, fontSize)
                    --line.rating:SetFont(fontMono, fontSize)
                    if IsAlly(focusedArmyID, armyID) then
                        line.nameColumn:SetColor(armyColorAllied) 
                        line.rating:SetColor(armyColorAllied) 
                    else
                        line.nameColumn:SetColor(armyColorEnemy)
                        line.rating:SetColor(armyColorEnemy)
                    end 
                else -- when observer is focused
                     -- show unit count in all armies
                    UpdateUnitsInfo(Stats.units.total, Stats.units.cap)
                    -- color army names with neutral color
                    line.rating:SetColor(player.txtColor)  
                    line.nameColumn:SetColor(player.txtColor)
                    --line.rating:SetColor(armyColorObserver)  
                    --line.nameColumn:SetColor(armyColorObserver)
                            
                    --line.rating:SetFont(fontMono, fontSize)
                    line.nameColumn:SetFont(UIUtil.bodyFont, fontSize)
                end
                
                if player.dead then
                   log.Trace('OnBeat player dead: '..player.nickname)
                   --ArmyAnnounce(player.armyID, player.nameshort..' has fallen!', 'Valar Morghulis')
                   
                   if scoreData.general.score == -1 then
                       line.scoreColumn:SetText(LOC("<LOC _Defeated>Defeated"))
                       line.scoreColumn:SetFont(UIUtil.bodyFont, fontSize)
                   end
                   if (sessionReplay and Stats.teamsActive) then 
                       local teamId = Stats.armies[armyID].teamID
                       local team = Stats.teams[teamId]
                       UpdateTeamStatus(team, armies)
                       team.statusChanged = true
                       -- check if team color needs to change
                       --if (team.color == player.color) then
                       --    team.colorChanged = true
                       --    UpdateTeamColor(team, armies)
                       --end
                   end
                   KillArmyLine(line)
                end
            end
            
            -- then update teams' lines and show score data for allied players
            for lineID, line in controls.armyLines do
                -- skip lines without teams
                if (not Stats.teamsActive or 
                    not line.isTeamLine) then 
                    continue 
                end
                local armyID = line.armyID
                local team = Stats.teams[armyID] 
                --log.Trace('OnBeat updating team line: '..line.armyID)
                    
                if (not team) then continue end
                
                if (sessionReplay) then
                    -- average ratio values for teams based on number of team members
                    team.ratio.killsToBuilt = (team.ratio.killsToBuilt / team.members.count)  
                    team.ratio.killsToLoses = (team.ratio.killsToLoses / team.members.count)  
           
                    line.totalColumn:SetText(GetStatsForArmy(team, Stats.columnTotal))
                    line.massColumn:SetText(GetStatsForArmy(team, Stats.columnMass))
                    line.engyColumn:SetText(GetStatsForArmy(team, Stats.columnEngy))
                    line.unitColumn:SetText(GetStatsForArmy(team, Stats.columnUnits))
                end 
                
                -- update army's score
                if (team.score <= -1) then
                    line.scoreColumn:SetText(LOC("<LOC _Playing>Playing"))
                    line.scoreColumn:SetFont(UIUtil.bodyFont, fontSize) 
                else
                    line.scoreColumn:SetText(' '..GetStatsForArmy(team, Stats.columnScore))
                end 
                
                -- update team color only for live team
                if (team.colorChanged and not team.dead) then
                    team.colorChanged = false
                    line.color:SetSolidColor(team.color)
                end
                
                if (team.dead and not line.dead) then
                    log.Trace('OnBeat() team dead: '..team.namefull)
                    KillArmyLine(line)
                    
                    ArmyAnnounce(team.armyID, team.nickname..' has fallen!', 'Valar Morghulis')
                end
                
                if (team.statusChanged) then
                    team.statusChanged = false
                    line.nameColumn:SetText(team.namefull) 
                end
                
            end
            
            SortArmyLines()
        end
        
        if observerLine then
            if focusedArmyID == -1 then
                --logArmyScore = true
                observerLine.nameColumn:SetColor('ffff7f00')
                observerLine.nameColumn:SetFont('Arial Bold', 12) -- 14
            else
                observerLine.nameColumn:SetColor('ffffffff')
                observerLine.nameColumn:SetFont(UIUtil.bodyFont, 12) -- 14
            end
        end
        
        --SortArmyLines()
        
        import(UIUtil.GetLayoutFilename('score')).LayoutArmyLines()
end
function SortArmyLinesBy(column)
    log.Trace('SortArmyLinesBy '..column..' ...')
    Stats.sortByColumnOld = Stats.sortByColumnNew
    Stats.sortByColumnNew = column
    --UpdateArmyIcons(column)
    UpdateArmyLines(column)
    SortArmyLines()
    
    msgFrom = 'FAKE PLAYER '.. ' - TEAM #' 
    msgInfo = ' built an experimental unit '
    --msgInfo = msgInfo..' ('.. 2 ..')'
            
    --ArmyAnnounce(1, msgFrom, msgInfo)
    --logArmyScore = true        
end
function SortArmyLines()
    --TODO sort army lines based on user selection 
    -- in   Game Session: rating, name, score
    -- in Replay Session: rating, name, score, massIn, energyIn, massTotal, units,  
    
    -- sortBy columns:
    --  team # (team icon)
    --  rating 
    --  name
    --  score       score, ratio.killsToBuilt, ratio.builtToLoses
    --  mass        eco.massIncome, eco.massTotal 
    --  energy      eco.engyIncome eco.engyTotal 
    --  total       eco.massTotal kills.mass 
    --  units       units.total units.air units.land units.navy 

    table.sort(controls.armyLines, function(lineA,lineB)
        -- sort only line of players/teams
        if lineA.isObsLine  or lineB.isObsLine or  
           lineA.isMapLine  or lineB.isMapLine or 
           lineA.isSortLine or lineB.isSortLine then 
            return lineA.armyID >= lineB.armyID
            
        -- sort player and team lines by their army ID 
        elseif (lineA.isArmyLine and lineB.isTeamLine) or 
               (lineA.isTeamLine and lineB.isArmyLine) then
            return lineA.armyID >= lineB.armyID
        else -- sorting two players lines or two teams lines    
             -- get sort values for current sort column
            local sortValueA = GetStatsForArmyID(lineA.armyID, Stats.sortByColumnNew, false)
            local sortValueB = GetStatsForArmyID(lineB.armyID, Stats.sortByColumnNew, false)
               
            local sortIndex = num.sort(sortValueA,sortValueB)
            -- if lines have the same values then use previous sort
            if (sortIndex == 0) then
                -- get old sort column and try to sort lines
                local oldSortValueA = GetStatsForArmyID(lineA.armyID, Stats.sortByColumnOld, false)
                local oldSortValueB = GetStatsForArmyID(lineB.armyID, Stats.sortByColumnOld, false)
                sortIndex = num.sort(oldSortValueA,oldSortValueB)
                -- if lines have the same values then default to sorting by army ID
                if (sortIndex == 0) then 
                    return lineA.armyID >= lineB.armyID 
                else
                    return sortIndex 
                end
            else
                return sortIndex 
            end
            
        end
    end)
end

function NoteGameSpeedChanged(newSpeed)
    gameSpeed = newSpeed
    if sessionOptions.GameSpeed and sessionOptions.GameSpeed == 'adjustable' and controls.time then
       controls.time:SetText(string.format("%s (%+d)", GetGameTime(), gameSpeed))
    end
    if observerLine then
       observerLine.speedSlider:SetValue(gameSpeed)
    end
end
--------------------------------------------------------------------------
-- Animation functions
--------------------------------------------------------------------------
function ToggleScoreControl(state)
    -- disable when in Screen Capture mode
    if import('/lua/ui/game/gamemain.lua').gameUIHidden then
        return
    end

    if not controls.bg then
        import('/lua/ui/game/objectives2.lua').ToggleObjectives()
        return
    end
    
    if UIUtil.GetAnimationPrefs() then
        if state or controls.bg:IsHidden() then
            Prefs.SetToCurrentProfile("scoreoverlay", true)
            local sound = Sound({Cue = "UI_Score_Window_Open", Bank = "Interface",})
            PlaySound(sound)
            controls.collapseArrow:SetCheck(false, true)
            controls.bg:Show()
            controls.bg:SetNeedsFrameUpdate(true)
            controls.bg.OnFrame = function(self, delta)
                local newRight = self.Right() - (1000*delta)
                if newRight < savedParent.Right() - 3 then
                    self.Right:Set(function() return savedParent.Right() - 18 end)
                    self:SetNeedsFrameUpdate(false)
                else
                    self.Right:Set(newRight)
                end
            end
        else
            Prefs.SetToCurrentProfile("scoreoverlay", false)
            local sound = Sound({Cue = "UI_Score_Window_Close", Bank = "Interface",})
            PlaySound(sound)
            controls.bg:SetNeedsFrameUpdate(true)
            controls.bg.OnFrame = function(self, delta)
                local newRight = self.Right() + (1000*delta)
                if newRight > savedParent.Right() + self.Width() then
                    self.Right:Set(function() return savedParent.Right() + self.Width() end)
                    self:Hide()
                    self:SetNeedsFrameUpdate(false)
                else
                    self.Right:Set(newRight)
                end
            end
            controls.collapseArrow:SetCheck(true, true)
        end
    else
        if state or controls.bg:IsHidden() then
            Prefs.SetToCurrentProfile("scoreoverlay", true)
            controls.bg:Show()
            local sound = Sound({Cue = "UI_Score_Window_Open", Bank = "Interface",})
            PlaySound(sound)
            controls.collapseArrow:SetCheck(false, true)
        else
            Prefs.SetToCurrentProfile("scoreoverlay", false)
            local sound = Sound({Cue = "UI_Score_Window_Close", Bank = "Interface",})
            PlaySound(sound)
            controls.bg:Hide()
            controls.collapseArrow:SetCheck(true, true)
        end
    end
end
function Expand()
    if needExpand then
        controls.bg:Show()
        controls.collapseArrow:Show()
        local sound = Sound({Cue = "UI_Score_Window_Open", Bank = "Interface",})
        PlaySound(sound)
        needExpand = false
    end
end
function Contract()
    if controls.bg then
        if not controls.bg:IsHidden() then
            local sound = Sound({Cue = "UI_Score_Window_Close", Bank = "Interface",})
            PlaySound(sound)
            controls.bg:Hide()
            controls.collapseArrow:Hide()
            needExpand = true
        else
            needExpand = false
        end
    else
        contractOnCreate = true
    end
end

function InitialAnimation(state)
    controls.bg.Right:Set(savedParent.Right() + controls.bg.Width())
    controls.bg:Hide()
    if Prefs.GetFromCurrentProfile("scoreoverlay") != false then
        controls.collapseArrow:SetCheck(false, true)
        controls.bg:Show()
        controls.bg:SetNeedsFrameUpdate(true)
        controls.bg.OnFrame = function(self, delta)
            local newRight = self.Right() - (1000*delta)
            if newRight < savedParent.Right() - 3 then
                self.Right:Set(function() return savedParent.Right() - 18 end)
                self:SetNeedsFrameUpdate(false)
            else
                self.Right:Set(newRight)
            end
        end
    end
end

function ArmyAnnounce(armyID, text, textDesc)
    local textFull = text..' '..(textDesc or '')
    --log.Trace('ArmyAnnounce armyID='..armyID..' says: '..textFull)
    if not controls.armyLines then
        return
    end
    --local armyLine = controls.armyLines[armyID]
    local armyLine = false
    for _, line in controls.armyLines do
        if line.armyID == armyID then
            armyLine = line
        end
    end
    
    if armyLine then
        --import('/lua/ui/game/announcement.lua').CreateAnnouncement(LOC(text), armyLine, textDesc)
        Announcement.CreateAnnouncement(LOC(text), armyLine, textDesc)
    end
end