-- with heavy inspiration from Idle Engineers by camelCase
local GameMain = import('/lua/ui/game/gamemain.lua')
local SelectHelper = import('/mods/ui-party/modules/selectHelper.lua')
local UIP = import('/mods/UI-Party/modules/UI-Party.lua')
local Group = import('/lua/maui/group.lua').Group
local Bitmap = import('/lua/maui/bitmap.lua').Bitmap
local LayoutHelpers = import('/lua/maui/layouthelpers.lua')
local UnitHelper = import('/mods/ui-party/modules/unitHelper.lua')
local trackers = {}
local enhancementQueue = {}
local hasNotify = exists('/mods/Notify/modules/notify.lua')
local notify = nil
if hasNotify then notify = import('/mods/Notify/modules/notify.lua') end

function Init()
	trackers = {
		{
			name="idle",
			testFn= function(u) 
				if (u:IsInCategory("FACTORY") or u:IsInCategory("ENGINEER")) and u:IsIdle() and u:GetWorkProgress() == 0 then
					if u:IsInCategory("FACTORY") then 
						if (u.assistedByF) then 
							-- idle master fac is terrible
							return { val=16, img='/mods/ui-party/textures/idle_icon.dds', width=16, height=16 } 
						elseif (u.assistedByE) then 
							-- idle assistedByEng fac is bad
							return { val=14, img='/mods/ui-party/textures/idle_icon.dds', width=14, height=14 } 
						else
							-- idle solo fac is bad
							return { val=12, img='/mods/ui-party/textures/idle_icon.dds', width=12, height=12 } 
						end
					else
						-- idle engie is not bad
						return { val=8, img='/mods/ui-party/textures/idle_icon_small.dds', width=8, height=8 }
					end					
				end
				return { val = false }
			end
		},
		{
			name="submerged",
			testFn= function(u) 
				if u:IsInCategory("SUBMERSIBLE") then					
					if u:IsInCategory("DESTROYER") then
						if GetIsSubmerged({u}) == -1 then
							-- submerged destroyer
							return { val=16, img='/mods/ui-party/textures/down.dds', width=12, height=14 } 
						end
					else
						if GetIsSubmerged({u}) == 1 then
							-- surfaced sub
							return { val=16, img='/mods/ui-party/textures/up.dds', width=12, height=14 } 
						end
					end
				end
				return { val = false }
			end
		},
		{
			name="loaded",
			testFn= function(u) 
				if u:IsInCategory("SILO") then		
				
					local mi = u:GetMissileInfo()
					if (mi) then 
						if (mi.nukeSiloStorageCount > 0) then 		
							return { val=16, img='/mods/ui-party/textures/loaded1.dds', width=16, height=24 } 
						end
						if (mi.tacticalSiloStorageCount > 0) then 		
							return { val=16, img='/mods/ui-party/textures/loaded1.dds', width=8, height=12 } 
						end
					end

				end
				return { val = false }
			end
		},
		{
			name="locked",
			testFn= function(u) 
				if u.locked then 
					if u:IsInCategory("FACTORY") then return { val=12, img='/mods/ui-party/textures/lock_icon.dds', width=12, height=12 } end
					return { val=8, img='/mods/ui-party/textures/lock_icon_small.dds', width=8, height=8 }
				end
				return { val = false }
			end,
			
		},
		{
			name="upgrade",
			testFn= function(u) 				
				if (u:IsInCategory("STRUCTURE")) then
					local queue = SetCurrentFactoryForQueueDisplay(u);
					if (queue ~= nil) then
						local firstItem = queue[1]
						local firstBp = __blueprints[firstItem.id]
						local firstIsStruct = from(firstBp.Categories).contains("STRUCTURE")
						if (firstIsStruct) then 
							if GetIsPaused({ u }) then 
								return { val=7, img='/mods/ui-party/textures/upgrade.dds', width=8, height=8 }
							else
								return { val=8, img='/mods/ui-party/textures/upgrade.dds', width=12, height=12 }
							end
						end
					end
				end
				return { val = false }
			end
		},
		{
			name="assisted",
			testFn= function(u) 				
				if (not u:IsInCategory("FACTORY")) then
					if u.assistedByE then return { val=8, img='/mods/ui-party/textures/crown_icon_small.dds', width=8, height=8 }
					elseif u.assistedByU then return { val=8, img='/mods/ui-party/textures/crown_icon_small_grey.dds', width=8, height=8 }
					end
				end
				return { val = false }
			end
		},
		{
			name="masterFactory",
			testFn= function(u) 

				local repeating_master = { val=1, img='/mods/ui-party/textures/repeating_master_fac.dds', width=12, height=16 }
				local master = { val=2, img='/mods/ui-party/textures/master_fac.dds', width=12, height=16 }
				local repeating_solo = { val=3, img='/mods/ui-party/textures/repeating_solo_fac.dds', width=12, height=16 }
				local solo = { val=4, img='/mods/ui-party/textures/solo_fac.dds', width=12, height=16 }
				
				if (u:IsInCategory("FACTORY")) then
					local isGuarding = u:GetGuardedEntity() ~= nil
					local isRepeating = u:IsRepeatQueue()
					local hasQueue = SetCurrentFactoryForQueueDisplay(u) ~= nil
					local isMaster = u.assistedByF

					if (u.assistedByF) then

						if (isGuarding) then 
							isMaster = hasQueue
						end
					
					end

					if (isMaster) then

						if isRepeating then 
							return repeating_master
						else
							return master
						end

					else  

						if hasQueue then 
							-- its a solo

							if isRepeating then
								return repeating_solo
							else
								return solo
							end
						end

					end
				end		
				return { val = false }
			end
		}
	}

	if (hasNotify) then

		enhancementQueue = notify.getEnhancementQueue()

		table.insert(trackers, 
			{
				name="enhance",
				testFn= function(u) 	

					if (u.isEnhancing) then 
						return { val=8, img='/mods/ui-party/textures/upgrade.dds', width=12, height=12 }
					end
					return { val = false }
				end
			});

	end
end

local adornmentsVisible = false

function OnBeat()

	if UIP.Enabled() then

		local selectedUnits = GetSelectedUnits()

		local units = SelectHelper.getAllUnits()

		from(units).foreach(function(k,v)
			if v.uip == nil then
				v.uip = true
				UnitFound(v)
			end

			v.lastIsUpgradee = v.isUpgradee
			v.lastIsEnhancing = v.isEnhancing

			v.assistedByF = false
			v.assistedByE = false
			v.assistedByU = false
			v.isUpgradee = false
			v.isUpgrader = false
			v.upgradingTo = nil
			v.upgradingFrom = nil

			if hasNotify then
				local unitQueue = enhancementQueue[v:GetEntityId()];
				v.isEnhancing = unitQueue ~= nil and table.getn(unitQueue) > 0
			end

		end)
		
		from(units).foreach(function(k,v)
			local e = v:GetGuardedEntity()
			if e ~= nil then
				if v:IsInCategory("FACTORY") then e.assistedByF = true
				elseif v:IsInCategory("ENGINEER") then e.assistedByE = true
				else e.assistedByU = true 
				end
			end

			if v:IsInCategory("STRUCTURE") then
				local f = v:GetFocus()
				if f ~= nil and f:IsInCategory("STRUCTURE") then
				v.isUpgrader = true
				v.upgradingTo = f;
				f.isUpgradee = true
				f.upgradingFrom = v;
				end
			end
		end)
		
		if (UIP.GetSetting("alertUpgradeFinished")) then 
			from(units).foreach(function(k,v)
				if v.lastIsUpgradee and not v.isUpgradee and not v:IsDead() then
					PlaySound(Sound({Bank = 'Interface', Cue = 'UI_Opt_Mini_Button_Over'}))
					print(UnitHelper.GetUnitName(v) .. " complete")
				end
				if v.lastIsEnhancing and not v.isEnhancing and not v:IsDead() then
					PlaySound(Sound({Bank = 'Interface', Cue = 'UI_Opt_Mini_Button_Over'}))
					print(UnitHelper.GetUnitName(v) .. " no longer upgrading") -- too hard to work out if complete/cancelled, we only know if there is an upgrade in the queue at al
				end
			end)
		end

		local newadornmentsVisible = UIP.GetSetting("showAdornments")
		if adornmentsVisible and not newadornmentsVisible then
			from(units).foreach(function(k,v)
				RemoveAllAdornments(v)
			end)
		end
		adornmentsVisible = newadornmentsVisible

		if adornmentsVisible then
			from(units).foreach(function(k,v)
				if not v.isUpgradee then -- the old fac is overlayed by new fac unit - we dont want to draw icons for new fac until old one dies
					UpdateUnit(v)
				end
			end)
		end

		if selectedUnits and table.getn(selectedUnits) == 1 then
			-- return the queue back the way it was. For some reasons this throws errors (without harm) until you deselect and reselect your acu
			SetCurrentFactoryForQueueDisplay(selectedUnits[1])
		else
			ClearCurrentFactoryForQueueDisplay()
		end

	end

end

function Shutdown()
	local units = SelectHelper.getAllUnits()
	from(units).foreach(function(k,v)
		RemoveAllAdornments(v)
	end)
end

function RemoveAllAdornments(u)
	local st = u.StateTracker	
	from(trackers).foreach(function(k,v)
		local entry = st[v.name]
		if entry.overlay ~= nil then
			entry.overlay:Hide()
			entry.overlay:Destroy()
			entry.overlay = nil
		end
		entry.value = false
	end)

end


function UnitFound(u)
	if UIP.GetSetting("setGroundFireOnAttack") then
		ToggleFireState({ u }, 1)
	end
	if UIP.GetSetting("factoriesStartWithRepeatOn") then
		u:ProcessInfo('SetRepeatQueue', 'true')
	end

	if u.StateTracker == nil then

		local st = {}

		from(trackers).foreach(function(k,v)
			st[v.name] = { value = false }
		end)

		u.StateTracker = st
		st.group = Group(GetFrame(0))
		st.group.Width:Set(10)
		st.group.Height:Set(10)				
		st.group.Top:Set(15)
		st.group.Left:Set(15)		
		st.group:SetNeedsFrameUpdate(true)
		st.group.OnFrame = function(self, delta)
			UpdateUnitPos(u)
		end

	end

end

function UpdateUnit(u)
	local st = u.StateTracker	
	local relayoutRequired = false

	from(trackers).foreach(function(k,v)
		local result = v.testFn(u)
		if result == nil then result = { val=false } end

		local entry = st[v.name]
		local changed = entry.value ~= result.val

		if changed then
			relayoutRequired = true
			entry.value = result.val

			if entry.overlay ~= nil then
				entry.overlay:Hide()
				entry.overlay:Destroy()
				entry.overlay = nil
			end

			if result.val ~= false then
				entry.overlay = Bitmap(st.group)
				--entry.overlay:SetAlpha(0.5, true)
				entry.overlay:SetTexture(result.img, 0)
				entry.overlay.Width:Set(result.width)
				entry.overlay.Height:Set(result.height)
			end	
		end 
	end)

	if relayoutRequired then
		local offset = 0
		from(trackers).foreach(function(k,v)
			local entry = st[v.name]
			if entry.value ~= false then
				LayoutHelpers.AtLeftTopIn(entry.overlay, st.group, offset, 0)
				offset = offset + entry.overlay.Width()
			end 
		end)
	end
	
end

function UpdateUnitPos(u)
	local st = u.StateTracker	
	if(not u:IsDead()) then
		local worldView = import('/lua/ui/game/worldview.lua').viewLeft
		local pos1 = u:GetPosition() 
		local posA = worldView:Project(pos1)
		LayoutHelpers.AtLeftTopIn(st.group, worldView, posA.x + 3, posA.y)
	else
		DestroyTracker(u, st)
	end
end

function DestroyTracker(u, st)
	from(trackers).foreach(function(k,v)
		local entry = st[v.name]
		if entry.value then
			entry.overlay:Destroy()
		end 
	end)
	st.group:Destroy()
end