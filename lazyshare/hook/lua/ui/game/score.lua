	--This file is changed alot to fit the new FAF Score UI.
if SessionIsReplay() then
	--Added to dont change the UI if watching a replay. It may course Errors in other files of the mod. Check the log and might solve.
	--All the other "if SessionIsReplay()" as well as the following commands gone
else

	-- Multiple changes for Beta3
	-- Shows Rank names if playing GW
	-- Cleaned up the file from a lot of commented lines


local ranks = {}
ranks[0] = {"Private", "Corporal", "Sergeant", "Captain", "Major", "Colonel", "General", "Supreme Commander"}
ranks[1] = {"Paladin", "Legate", "Priest", "Centurion", "Crusader", "Evaluator", "Avatar-of-War", "Champion"}
ranks[2] = {"Drone", "Node", "Ensign", "Agent", "Inspector", "Starshina", "Commandarm" ,"Elite Commander"}
ranks[3] = {"Su", "Sou", "Soth", "Ithem", "YthiIs", "Ythilsthe", "YthiThuum", "Suythel Cosethuum"}


function SetupPlayerLines()
    local function CreateArmyLine(data, armyIndex)
        local group = Group(controls.bgStretch)
        local sw = 42
        
	        group.faction = Bitmap(group)
	        if armyIndex != 0 then
	            group.faction:SetTexture(UIUtil.UIFile(UIUtil.GetFactionIcon(data.faction)))



	        else
	            group.faction:SetTexture(UIUtil.UIFile('/widgets/faction-icons-alpha_bmp/observer_ico.dds'))

	        end
	        group.faction.Height:Set(14)

	        group.faction.Width:Set(14)
	        group.faction:DisableHitTest()
	        LayoutHelpers.AtLeftTopIn(group.faction, group)
	        
	        group.color = Bitmap(group.faction)
	        group.color:SetSolidColor(data.color)
	        group.color.Depth:Set(function() return group.faction.Depth() - 1 end)
	        group.color:DisableHitTest()
	        LayoutHelpers.FillParent(group.color, group.faction)

            local playerName1 = data.nickname
            local playerRank = sessionInfo.Options.Ranks[playerName1]
				if (playerRank) then
					playerName1 = ranks[data.faction][playerRank+1] .. " " .. "(" .. playerRank+1 .. ")" .. " " .. data.nickname
				end
					--new ID-Column
			if GetFocusArmy() ~= -1 then
				group.id = UIUtil.CreateText(group, import('/mods/lazyshare/mimc_diplomacy.lua').mimc_getID(armyIndex), 12, UIUtil.bodyFont)
			else
				group.id = UIUtil.CreateText(group, ' ', 12, UIUtil.bodyFont)
			end
			group.id:DisableHitTest()
			group.id.Width:Set(20)
			LayoutHelpers.AtLeftIn(group.id, group, 20)
			LayoutHelpers.AtVerticalCenterIn(group.id, group)
			group.id:SetColor('ffffffff')		
					--new

					
	        group.name = UIUtil.CreateText(group, playerName1, 12, UIUtil.bodyFont)
--	        group.name = UIUtil.CreateText(group, data.nickname, 12, UIUtil.bodyFont)
	        group.name:DisableHitTest()
            LayoutHelpers.AtLeftIn(group.name, group, 34)
	        LayoutHelpers.AtVerticalCenterIn(group.name, group)
	        group.name:SetColor('ffffffff')
	        
	        group.score = UIUtil.CreateText(group, '', 12, UIUtil.bodyFont)
	        group.score:DisableHitTest()
	        LayoutHelpers.AtRightIn(group.score, group)
	        LayoutHelpers.AtVerticalCenterIn(group.score, group)
	        group.score:SetColor('ffffffff')
	        
	        group.name.Right:Set(group.score.Left)
	        group.name:SetClipToWidth(true)
    
        group.Height:Set(group.faction.Height)
        group.Width:Set(262)
        group.armyID = armyIndex

            group:DisableHitTest()

        
        return group
    end
    local index = 1
    for armyIndex, armyData in GetArmiesTable().armiesTable do
        if armyData.civilian or not armyData.showScore then continue end
        if not controls.armyLines then 
            controls.armyLines = {}
        end
        controls.armyLines[index] = CreateArmyLine(armyData, armyIndex)
        index = index + 1
    end
	

	local function CreateMapNameLine(data, armyIndex)
		local group = Group(controls.bgStretch)	
		        
		local mapnamesize = string.len(data.mapname)
		local mapoffset = 131 - (mapnamesize * 2.7)
		if (sessionInfo.Options.Ranked) then
			mapoffset = mapoffset + 10
		end
		group.name = UIUtil.CreateText(group, data.mapname, 10, UIUtil.bodyFont)
		group.name:DisableHitTest()
		LayoutHelpers.AtLeftIn(group.name, group, mapoffset)
		LayoutHelpers.AtVerticalCenterIn(group.name, group, 1)
		group.name:SetColor('ffffffff')
		
		if (sessionInfo.Options.Ranked) then
			group.faction = Bitmap(group)
			group.faction:SetTexture("/textures/ui/powerlobby/rankedscore.dds")        
			group.faction.Height:Set(14)
			group.faction.Width:Set(14)
			group.faction:DisableHitTest()
			LayoutHelpers.AtLeftTopIn(group.faction, group.name, -15)
		end
		
		group.score = UIUtil.CreateText(group, '', 10, UIUtil.bodyFont)
		group.score:DisableHitTest()
		LayoutHelpers.AtRightIn(group.score, group)
		LayoutHelpers.AtVerticalCenterIn(group.score, group)
		group.score:SetColor('ffffffff')
		
		group.name.Right:Set(group.score.Left)
		group.name:SetClipToWidth(true)
		
		group.Height:Set(18)
		group.Width:Set(262)        
		
		group:DisableHitTest()
		
		return group
	end

	for _, line in controls.armyLines do
		local playerName = line.name:GetText()        
		local playerRating = sessionInfo.Options.Ratings[playerName]
		if (playerRating) then
			playerNameLine = playerName..' ['..math.floor(playerRating+0.5)..']'
			line.name:SetText(playerNameLine)
		end
	end
	
	mapData = {}	
	mapData.mapname = LOCF("<LOC gamesel_0002>Map: %s", sessionInfo.name)
	controls.armyLines[index] = CreateMapNameLine(mapData, 0)
end
	function _OnBeat()

		controls.time:SetText(string.format("%s (%+d / %+d)", GetGameTime(), gameSpeed, GetSimRate() ))        






		if sessionInfo.Options.NoRushOption and sessionInfo.Options.NoRushOption != 'Off' then
			if tonumber(sessionInfo.Options.NoRushOption) * 60 > GetGameTimeSeconds() then
				local time = (tonumber(sessionInfo.Options.NoRushOption) * 60) - GetGameTimeSeconds()
				controls.time:SetText(LOCF('%02d:%02d:%02d', math.floor(time / 3600), math.floor(time/60), math.mod(time, 60)))
			end
			if not issuedNoRushWarning and tonumber(sessionInfo.Options.NoRushOption) * 60 == math.floor(GetGameTimeSeconds()) then
				import('/lua/ui/game/announcement.lua').CreateAnnouncement('<LOC score_0001>No Rush Time Elapsed', controls.time)
				issuedNoRushWarning = true
			end
		end
		local armiesInfo = GetArmiesTable().armiesTable
		if currentScores then
			for index, scoreData in currentScores do
				for _, line in controls.armyLines do
					if line.armyID == index then
										--MIMC-Stuff
						if GetFocusArmy() ~= -1 then                
							line.id:SetText(import('/mods/lazyshare/mimc_diplomacy.lua').mimc_getID(index))
							line.scoreNumber = scoreData.general.score
						end
										--MIMC-Stuff end
						if line.OOG then break end

						if scoreData.general.score == -1 then
							line.score:SetText(LOC("<LOC _Playing>Playing"))
							line.scoreNumber = -1
						else
							line.score:SetText(fmtnum(scoreData.general.score))



							line.scoreNumber = scoreData.general.score
							
						end



						if GetFocusArmy() == index then

							line.id:SetText('*')


							line.name:SetColor('ffff7f00')
							line.score:SetColor('ffff7f00')
							line.name:SetFont('Arial Bold', 12)
							line.id:SetFont('Arial Bold', 12)
							line.id:SetColor('ffff7f00')

							line.score:SetFont('Arial Bold', 12)
							if scoreData.general.currentcap.count > 0 then
								SetUnitText(scoreData.general.currentunits.count, scoreData.general.currentcap.count)
							end
						-- Give allies an other color. (Orange)
						elseif GetFocusArmy() ~= -1 and IsAlly(GetFocusArmy(), index) then
							line.name:SetColor('ffff7f00')
							line.score:SetColor('ffff7f00')
							line.id:SetColor('ffff7f00')
							line.id:SetFont(UIUtil.bodyFont, 12)
							line.name:SetFont(UIUtil.bodyFont, 12)
							line.score:SetFont(UIUtil.bodyFont, 12)

						else
							line.id:SetText('')
							line.name:SetColor('ffffffff')
							line.score:SetColor('ffffffff')
							line.name:SetFont(UIUtil.bodyFont, 12)
							line.score:SetFont(UIUtil.bodyFont, 12)
						end
						if armiesInfo[index].outOfGame then
						        	--MIMC-Stuff
							line.name:SetText(armiesInfo[index].nickname)
									--
							if scoreData.general.score == -1 then
								line.score:SetText(LOC("<LOC _Defeated>Defeated"))
								line.scoreNumber = -1
							end

							line.OOG = true
							line.faction:SetTexture(UIUtil.UIFile('/game/unit-over/icon-skull_bmp.dds'))
							line.color:SetSolidColor('ff000000')
							line.name:SetColor('ffa0a0a0')
							line.score:SetColor('ffa0a0a0')
							
						end
						break
					end
				end
			end
		end
		if observerLine then
			if GetFocusArmy() == -1 then
				observerLine.name:SetColor('ffff7f00')
				observerLine.name:SetFont('Arial Bold', 14)
			else
				observerLine.name:SetColor('ffffffff')
				observerLine.name:SetFont(UIUtil.bodyFont, 14)
			end
		end
		table.sort(controls.armyLines, function(a,b)
			if a.armyID == 0 or b.armyID == 0 then
				return a.armyID >= b.armyID
			else
				if tonumber(a.scoreNumber) == tonumber(b.scoreNumber) then

					return a.name:GetText() < b.name:GetText()
				else
					return tonumber(a.scoreNumber) > tonumber(b.scoreNumber)

				end
			end
		end)
		import(UIUtil.GetLayoutFilename('score')).LayoutArmyLines()
end
end