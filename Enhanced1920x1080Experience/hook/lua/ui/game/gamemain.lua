
function OnFirstUpdate()
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

    ForkThread( 
        function()

		    	if not IsNISMode() then
                		import('/lua/ui/game/worldview.lua').UnlockInput()
            		end

			-- split screen
			local Borders = import('/lua/ui/game/borders.lua')
		    	Borders.SplitMapGroup(true, true)
            		import('/lua/ui/game/worldview.lua').Expand() -- required to initialize something else there is a crash
			
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
		    	cam1:SetZoom(100,0.1) -- different zoom level to usual, not as close
			cam1:RevertRotation() -- UIZoomTo does something funny
			WaitSeconds(1)
			-- left cam shoots to acu

	        	-- hide windows 
			WaitSeconds(1)
			import('/lua/ui/game/multifunction.lua').ToggleMFDPanel(false)
			import('/lua/ui/game/tabs.lua').ToggleTabDisplay(false)
			local c = import('/lua/ui/game/avatars.lua').controls

			-- reposition the avatars pane
			LayoutHelpers.AtRightTopIn(c.avatarGroup, c.parent, 1920, 0)
	end
    )

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
