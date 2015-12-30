local SelectHelper = import('/mods/ui-party/modules/selectHelper.lua')
local UnitHelper = import('/mods/ui-party/modules/unitHelper.lua')

function safeLog(o)
	if o == nil then
		LOG("nil")
		return
	end
	
	for k,v in o do
		LOG(k,v)
	end

end

function LogUnit(o)
	if o == nil then
		LOG("nil")
		return
	end

	LOG(o:GetEntityId())
	LOG(o:GetBlueprint().Description)
end

function VECTOR3(x,y,z)
	return { x, y, z, type = 'VECTOR3' }
end


		
-- eg: ArmyAnnounce(1, 'Holy snake balls batmap', 'xxx')
function ArmyAnnounce(armyID, text, textDesc)
	local textFull = text..' '..(textDesc or '')
    
	local Group	= import('/lua/maui/group.lua').Group
		
	local LayoutHelpers = import('/lua/maui/layouthelpers.lua')

	local group = Group(GetFrame(0))
	group.Depth:Set(99)
	LayoutHelpers.AtLeftTopIn(group, GetFrame(0), 0,0)
	group.Height:Set(100)
	group.Width:Set(100)
	
	import('/lua/ui/game/announcement.lua').CreateAnnouncement(LOC(text),group , textDesc)
end

local a, b = pcall(function()
                    --PlaySound(Sound({Bank = 'Interface', Cue = 'X_Main_Menu_On'})) --!!
   -- PlaySound(Sound({Bank = 'Interface', Cue = 'UI_Announcement_Open'}))
             --   PlaySound(Sound({Bank = 'Interface', Cue = 'UI_END_Game_Victory'}))
    --PlaySound(Sound({Bank = 'Interface', Cue = 'UI_Economy_Rollover'}))
        --PlaySound(Sound({Bank = 'Interface', Cue = 'UI_MFD_checklist'})) 
                 --  PlaySound(Sound({Bank = 'Interface', Cue = 'UI_Opt_Mini_Button_Over'}))
                  --  PlaySound(Sound({Bank = 'Interface', Cue = 'UI_Opt_Mini_Button_Click'}))
--                PlaySound(Sound({Bank = 'Interface', Cue = 'UI_IG_Camera_Move'}))
                -- PlaySound(Sound({Bank = 'Interface', Cue = 'UI_Diplomacy_Open'})) --!!
           -- PlaySound(Sound({Cue = "UI_Score_Window_Open", Bank = "Interface"}))
           -- PlaySound(Sound({Cue = "UI_Score_Window_Close", Bank = "Interface"}))
	--PlaySound(Sound({Cue = "AMB_SER_OP_Briefing", Bank = "AmbientTest",}))
                       -- PlaySound(Sound({Cue = "UI_Tab_Rollover_01", Bank = "Interface",}))
                        --PlaySound(Sound({Cue = "UI_Tab_Click_01", Bank = "Interface",}))

--	    local sound = Sound({Cue = 'UI_Menu_Error_01', Bank = 'Interface',})
--		PlaySound(sound)
--            PlaySound(Sound({Bank = 'Interface', Cue = 'UI_Tab_Rollover_01'}))
		local u = GetSelectedUnits()[1]	
--		print(UnitHelper.GetUnitName(u) .. " complete")

--		ArmyAnnounce(1, 'Holy snake balls batmap', 'xxx')
end)




LOG("UI PARTY RESULT: ", a, b)   
