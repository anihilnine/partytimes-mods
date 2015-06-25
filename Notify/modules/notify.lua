local modPath = '/mods/Notify/'
local EnhanceCommon = import('/lua/enhancementcommon.lua')
local FindClients = import('/lua/ui/game/chat.lua').FindClients
local RegisterChatFunc = import('/lua/ui/game/gamemain.lua').RegisterChatFunc
local addCommand = import(modPath .. 'modules/commands.lua').addCommand

local Bitmap = import('/lua/maui/bitmap.lua').Bitmap
local LayoutHelpers = import('/lua/maui/layouthelpers.lua')
local UIUtil = import('/lua/ui/uiutil.lua')

local Prefs = import('/lua/user/prefs.lua')
local chatDisabled
local overlayDisabled


local enhancementQueue = {}

local acu
local watch_enhancement = nil

local watchThread = nil

local chatChannel = 'Notify'

local overlays = {}

function init(isReplay, parent)
	RegisterChatFunc(processNotification, chatChannel)
	addCommand('enableNotify', disableNotify)
	addCommand('disableNotify', disableNotify)
	addCommand('enableNotifyChat', disableNotifyChat)
	addCommand('disableNotifyChat', disableNotifyChat)
	addCommand('enableNotifyOverlay', disableNotifyOverlay)
	addCommand('disableNotifyOverlay', disableNotifyOverlay)
	
	local notificationsDisabled = Prefs.GetFromCurrentProfile('Notify_Disabled')
	if notificationsDisabled ~= nil then
		chatDisabled = notificationsDisabled
		overlayDisabled = notificationsDisabled
		Prefs.SetToCurrentProfile('Notify_Disabled', nil)
		Prefs.SetToCurrentProfile('Notify_Chat_Disabled', notificationsDisabled)
		Prefs.SetToCurrentProfile('Notify_Overlay_Disabled', notificationsDisabled)
		Prefs.SavePreferences()
	else
		chatEnabled = Prefs.GetFromCurrentProfile('Notify_Chat_Disabled')
		overlayDisabled = Prefs.GetFromCurrentProfile('Notify_Overlay_Disabled')
	end
end

function disableNotify(args)
	if string.lower(args[1]) == string.lower('enableNotify') then
		chatDisabled = false
		overlayDisabled = false
		print 'Notify Enabled'
	else
		chatDisabled = true
		overlayDisabled = true
		print 'Notify Disabled'
	end
	
	if not args[2] or string.lower(args[2]) ~= 'once' then
		Prefs.SetToCurrentProfile('Notify_Chat_Disabled', chatDisabled)
		Prefs.SetToCurrentProfile('Notify_Overlay_Disabled', overlayDisabled)
		Prefs.SavePreferences()
	end
end

function disableNotifyChat(args)
	if string.lower(args[1]) == string.lower('enableNotifyChat') then
		chatDisabled = false
		print 'Notify Chat Enabled'
	else
		chatDisabled = true
		print 'Notify Chat Disabled'
	end
	
	if not args[2] or string.lower(args[2]) ~= 'once' then
		Prefs.SetToCurrentProfile('Notify_Chat_Disabled', chatDisabled)
		Prefs.SavePreferences()
	end
end

function disableNotifyOverlay(args)
	if string.lower(args[1]) == string.lower('enableNotifyOverlay') then
		overlayDisabled = false
		print 'Notify Overlay Enabled'
	else
		overlayDisabled = true
		print 'Notify Overlay Disabled'
	end
	
	if not args[2] or string.lower(args[2]) ~= 'once' then
		Prefs.SetToCurrentProfile('Notify_Overlay_Disabled', overlayDisabled)
		Prefs.SavePreferences()
	end
end

function createEnhancementOverlay(id, pos)
	local overlay = Bitmap(GetFrame(0))
	
	--overlay:SetSolidColor('black')
	overlay.Width:Set(100)
	overlay.Height:Set(50)
	overlay.id = id
	overlay.pos = pos
	overlay.lastUpdate = GetSystemTimeSeconds()
	
	overlay:SetNeedsFrameUpdate(true)
	overlay.OnFrame = function(self, delta)
		if(GetSystemTimeSeconds() - overlay.lastUpdate > 2) then
			overlays[id] = nil
			overlay:Destroy()
			return
		end

		local worldView = import('/lua/ui/game/worldview.lua').viewLeft
		local pos = worldView:Project(Vector(overlay.pos.x, overlay.pos.z, overlay.pos.y))

		LayoutHelpers.AtLeftTopIn(overlay, worldView, pos.x - overlay.Width() / 2, pos.y - overlay.Height() / 2 + 1)
	end
		
	overlay.progress = UIUtil.CreateText(overlay, '0%', 12, UIUtil.bodyFont)
	overlay.progress:SetColor('white')
    overlay.progress:SetDropShadow(true)
	LayoutHelpers.AtCenterIn(overlay.progress, overlay, 15, 0)
	

	overlay.eta = UIUtil.CreateText(overlay, 'ETA', 10, UIUtil.bodyFont)
	overlay.eta:SetColor('white')
    overlay.eta:SetDropShadow(true)
	LayoutHelpers.AtCenterIn(overlay.eta, overlay, -15, 0)


	return overlay
end

function updateEnhancementOverlay(args)
	local id = args[1]
	local progress = args[2]
	local eta = args[3]
	local paused = args[4]
	local pos = {x=args[5], z=args[6], y=args[7]}
		
	if(not overlays[id]) then
		ForkThread(function () 
			overlays[id] = createEnhancementOverlay(id, pos)
		end		
		)
		return
	end

	local overlay = overlays[id]
	
	if(overlay) then
		overlay.progress:SetText(progress .. "%")
		if(paused == 0) then
			eta = math.max(0, eta - GetGameTimeSeconds())
		end
		overlay.eta:SetText("ETA " .. string.format("%.2d:%.2d", eta / 60, math.mod(eta, 60)))
		overlay.pos = pos
		overlay.lastUpdate = GetSystemTimeSeconds()
	end
end


function processNotification(players, msg)
	local args = {}

	for w in string.gfind(msg.text, "%S+") do
		table.insert(args, w)
	end

	for _, k in {1,3,4,5,6,7} do
		args[k] = tonumber(args[k])
	end

	updateEnhancementOverlay(args)
end

function round(num, idp)
	if(not idp) then
		return tonumber(string.format("%." .. (idp or 0) .. "f", num))
	else
  		local mult = 10^(idp or 0)
		return math.floor(num * mult + 0.5) / mult
  	end
end

function getEnhancementQueue()
	return enhancementQueue
end

function enqueueEnhancement(units, enhancement)
    local enhancements = units[1]:GetBlueprint().Enhancements
	
	if(enhancements[enhancement]) then
        for _, u in units do
            local id = u:GetEntityId()
            if not enhancementQueue[id] then
                enhancementQueue[id] = {}
            end

            found = false

            if not found then
                table.insert(enhancementQueue[id], enhancements[enhancement])
				if(u:IsInCategory('COMMAND')) then
					StartWatchThread(u)
                end
            end
        end        
		import('/lua/ui/game/construction.lua').updateCommandQueue()
    end
end

function removeEnhancement(unit)
	local uid = unit:GetEntityId()
	if enhancementQueue[uid] and table.getn(enhancementQueue[uid]) > 0 then
		table.remove(enhancementQueue[uid], 1)
	end
end

function clearEnhancements(units)
	for _, unit in units do
		if enhancementQueue[unit:GetEntityId()] then
			enhancementQueue[unit:GetEntityId()] = {}
		end
	end		
end

function currentlyUpgrading(unit)
	local currentCommand = unit:GetCommandQueue()[1]
	return (currentCommand.type == 'Script' and enhancementQueue[unit:GetEntityId()][1] and not string.find(enhancementQueue[unit:GetEntityId()][1].ID, 'Remove'))
end

function SetACU(unit)
	acu = unit
end

function StartWatchThread(unit)
	acu = unit
	if not watchThread then
		watchThread = ForkThread(CheckEnhancement)
	end
end

function NotifyStartEnhancement(unit, enhancement)
	local valid = {
	ResourceAllocation = "RAS", 
	ResourceAllocationAdvanced = "ARAS", 
	AdvancedEngineering = "T2", 
	T3Engineering = "T3",
	Teleporter = "Teleporter",
	CrysalisBeam = "Gun (Range)",
	HeatSink = "Gun (Speed)",
	EnhancedSensors = "Sensors",
	CoolingUpgrade = "Gun (Speed&Range)",
	MicrowaveLaserGenerator = "Laser",
	HeavyAntiMatterCannon = "Gun (Damage&Range)",
	Missile = "Tactical Missile",
	TacticalMissile = "Tactical Missile",
	TacticalNukeMissile = "Tactical Nuke",
	BlastAttack = "Gun (Splash)",
	RateOfFire = "Gun (Speed&Range)",
	DamageStabilization = "Nano-Repair",
	DamageStabilizationAdvanced = "Advanced Nano-Repair",
	Shield = "Shield",
	ShieldGeneratorField = "Shield Field",
	ShieldHeavy = "Shield Heavy",
	LeftPod = "Left Drone",
	RightPod = "Right Drone",
	ChronoDampener = "Chrono Dampener",
	StealthGenerator = "Stealth",
	CloakingGenerator = "Cloaking",
	NaniteTorpedoTube = "Torpedo",
	RegenAura = "Regen Aura",
	AdvancedRegenAura = "Advanced Regen Aura"
	}

	if(valid[enhancement.ID]) then
		watch_enhancement = table.copy(enhancement)

		watch_enhancement.DisplayName = valid[watch_enhancement.ID]
		watch_enhancement.notified = false
	end
end

function CheckEnhancement() 
	local uid = acu:GetEntityId()
	local start = 0
	
	while(table.getsize(enhancementQueue[uid]) > 0 or watch_enhancement) do
		if(acu:IsDead()) then
			enhancementQueue[uid] = {}
			watch_enhancement = nil
		else 
			local enhancements = EnhanceCommon.GetEnhancements(uid)
			local currentCommand = acu:GetCommandQueue()[1]
			local eco = acu:GetEconData()
			
			if(watch_enhancement) then
				if(enhancements[watch_enhancement.Slot] == watch_enhancement.ID) then
					if not chatDisabled then
						msg = { to = 'allies', Chat = true, text = watch_enhancement.DisplayName .. " done! (" .. round(GetGameTimeSeconds()-start, 2) .. "s)"}
						SessionSendChatMessage(FindClients(), msg)
					end
					
					while (enhancementQueue[uid][1].ID == watch_enhancement.ID) do
						table.remove(enhancementQueue[uid], 1)
					end
					
					watch_enhancement = nil
				elseif(not enhancementQueue[uid] or table.getn(enhancementQueue[uid]) == 0 or enhancementQueue[uid][1].ID ~= watch_enhancement.ID) then
					if(watch_enhancement.notified and not chatDisabled) then
						msg = { to = 'allies', Chat = true, text = watch_enhancement.DisplayName .. ' cancelled'}
						SessionSendChatMessage(FindClients(), msg)
					end
					watch_enhancement = nil
				elseif(currentCommand.type == "Script") then
					if(not watch_enhancement.notified) then
						if not chatDisabled then
							msg = { to = 'allies', Chat = true, text = 'Upgrading ' .. watch_enhancement.DisplayName}
							SessionSendChatMessage(FindClients(), msg)
						end
						watch_enhancement.notified = true
						start = GetGameTimeSeconds()
					end

					if not overlayDisabled then
						local progress = acu:GetWorkProgress()
						local me = GetFocusArmy()
						local tick = GameTick()
						
						if(not watch_enhancement.eta) then
							watch_enhancement.eta = GetGameTimeSeconds() + (watch_enhancement.BuildTime / acu:GetBuildRate())
						end

						if(GetIsPaused({acu})) then
							if(watch_enhancement.last_tick ~= 0) then
								watch_enhancement.last_tick = 0
								watch_enhancement.last_progress = 0
								watch_enhancement.eta = math.max(0, watch_enhancement.eta - GetGameTimeSeconds())
							end
						elseif(not watch_enhancement.last_tick or tick - watch_enhancement.last_tick > 30) then
							if(watch_enhancement.last_tick == 0) then
								watch_enhancement.eta = watch_enhancement.eta + GetGameTimeSeconds()
							end
							if(watch_enhancement.last_progress and watch_enhancement.last_progress ~= 0) then
								watch_enhancement.eta = round(GetGameTimeSeconds() + ((tick - watch_enhancement.last_tick) / 10) * ((1 - progress) / (progress - watch_enhancement.last_progress)))
							end
							
							watch_enhancement.last_tick = tick
							watch_enhancement.last_progress = progress
						end

						progress = math.floor((progress * 100)+0.5)
						pos = acu:GetPosition()
						msg = { to = 'allies', Notify = true, text = me .. " " .. progress .. " " .. watch_enhancement.eta .. " " .. (GetIsPaused({acu}) and 1 or 0) .. " " .. pos[1] .. " " .. pos[2] ..  " " .. pos[3]}
						SessionSendChatMessage(FindClients(), msg)
					end
				end
			else
				while currentCommand.type == 'Script' and string.find(enhancementQueue[uid][1].ID, 'Remove') do
					table.remove(enhancementQueue[uid], 1)
				end
				NotifyStartEnhancement(acu, enhancementQueue[uid][1])
			end
		end

		WaitSeconds(0.2)
	end
	
	watch_enhancement = nil
	
	KillThread(watchThread)
	watchThread = nil
end

