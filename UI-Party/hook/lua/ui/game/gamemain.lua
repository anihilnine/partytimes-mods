local UIP = import('/mods/UI-Party/modules/UI-Party.lua')
local UnitSplit = import('/mods/UI-Party/modules/UnitSplit.lua')

UIP.Init()

local oldCreateUI = CreateUI
function CreateUI(isReplay)

	oldCreateUI(isReplay)

	if UIP.Enabled() then 

		ForkThread(function() 
			
			local tabs = import('/lua/ui/game/tabs.lua')
			local mf = import('/lua/ui/game/multifunction.lua')

			if UIP.GetSetting("moveMainMenuToRight") then 
				tabs.controls.parent.Left:Set(function() return GetFrame(0).Width()-600 end)
			end

			WaitSeconds(4)

			if UIP.GetSetting("hideMenusOnStart") then 
				tabs.ToggleTabDisplay(false)
				mf.ToggleMFDPanel(false)
			end

		end)
	end

end 

local oldOnFirstUpdate = OnFirstUpdate 
function OnFirstUpdate()

	if not UIP.GetSetting("startSplitScreen") or not UIP.Enabled() then 
		oldOnFirstUpdate()

					
		if UIP.Enabled() and UIP.GetSetting("overrideZoomPop") then 
			ForkThread(function()
				import('/modules/zoompopper.lua').Init()
				local cam = GetCamera('WorldCamera')
				cam:Reset()
			end)
		end

		return
	end

	import('/modules/hotbuild.lua').init()
	EnableWorldSounds()
	local avatars = GetArmyAvatars()
	if avatars and avatars[1]:IsInCategory("COMMAND") then
		local armiesInfo = GetArmiesTable()
		local focusArmy = armiesInfo.focusArmy
		local playerName = armiesInfo.armiesTable[focusArmy].nickname
		avatars[1]:SetCustomName(playerName)
	end
	import('/lua/UserMusic.lua').StartPeaceMusic()
	if not import('/lua/ui/campaign/campaignmanager.lua').campaignMode then
		import('/lua/ui/game/score.lua').CreateScoreUI()
	end

	PlaySound( Sound { Bank='AmbientTest', Cue='AMB_Planet_Rumble_zoom'} )

	ForkThread(function()
		
		if not IsNISMode() then
			import('/lua/ui/game/worldview.lua').UnlockInput()
		end

		-- split screen
		local Borders = import('/lua/ui/game/borders.lua')
		Borders.SplitMapGroup(true, true)
		import('/lua/ui/game/worldview.lua').Expand() -- required to initialize something else there is a crash
			
		if UIP.GetSetting("overrideZoomPop") then 
			WaitSeconds(0)
			import('/modules/zoompopper.lua').Init()
		end

		-- select acu & start placing fac
		AddSelectUnits(avatars)
		import('/modules/hotbuild.lua').buildAction('Builders')

		-- both cams zoom out
		local cam1 = GetCamera("WorldCamera")
		local cam2 = GetCamera("WorldCamera2")
		cam1:SetZoom(cam1:GetMaxZoom() * 1.9,0)
		cam2:SetZoom(cam2:GetMaxZoom() * 1.9,0)

		-- need to wait before ui can hide, so slip in artistic camera transition
		WaitSeconds(1)
		-- left cam glides towards acu
		UIZoomTo(avatars, 1.2)
			
		WaitSeconds(1)
		cam1:SetZoom(import('/modules/zoompopper.lua').GetPopLevel(),0.1) -- different zoom level to usual, not as close
		WaitSeconds(0)
		cam1:RevertRotation() -- UIZoomTo does something funny

	end)

	if Prefs.GetOption('skin_change_on_start') != 'no' then
		local focusarmy = GetFocusArmy()
		local armyInfo = GetArmiesTable()
		if focusarmy >= 1 then
			local factions = import('/lua/factions.lua').Factions
			if factions[armyInfo.armiesTable[focusarmy].faction+1].DefaultSkin then
				UIUtil.SetCurrentSkin(factions[armyInfo.armiesTable[focusarmy].faction+1].DefaultSkin)
			end
		end
	end

end


local oldOnSelectionChanged = OnSelectionChanged
function OnSelectionChanged(oldSelection, newSelection, added, removed)
	UnitSplit.SelectionChanged()
	oldOnSelectionChanged(oldSelection, newSelection, added, removed)
end
