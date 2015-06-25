-- with heavy inspiration from Idle Engineers by camelCase
local GameMain = import('/lua/ui/game/gamemain.lua')
local SelectHelper = import('/mods/ui-party/modules/selectHelper.lua')
local UIP = import('/mods/UI-Party/modules/UI-Party.lua')
local Group = import('/lua/maui/group.lua').Group
local Bitmap = import('/lua/maui/bitmap.lua').Bitmap
local LayoutHelpers = import('/lua/maui/layouthelpers.lua')
local trackers = {}

function Init()
	trackers = {
		{
			name="idle",
			testFn= function(u) 
				if (u:IsInCategory("FACTORY") or u:IsInCategory("ENGINEER")) and u:IsIdle() then
					if u:IsInCategory("FACTORY") then return { val=12, img='/mods/ui-party/textures/idle_icon.dds', width=12, height=12 } end
					return { val=8, img='/mods/ui-party/textures/idle_icon_small.dds', width=8, height=8 }
				end
				return { val = false }
			end,
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
			name="assisted",
			testFn= function(u) 				
				if u.assistedByF then return { val=12, img='/mods/ui-party/textures/crown_icon.dds', width=12, height=12 }
				elseif u.assistedByE then return { val=8, img='/mods/ui-party/textures/crown_icon_small.dds', width=8, height=8 }
				elseif u.assistedByU then return { val=8, img='/mods/ui-party/textures/crown_icon_small_grey.dds', width=8, height=8 }
				else return { val = false }
				end
			end
		},
		{
			name="repeatQueue",
			testFn= function(u) 				
				if u:IsRepeatQueue() then
					if u:IsInCategory("FACTORY") then
						return { val=12, img='/mods/ui-party/textures/repeat_icon_small.dds', width=8, height=8 }
					end
				end					
				return { val = false }
			end
		}
	}
end

local adornmentsVisible = false

function OnBeat()

	if UIP.Enabled() then

		local units = SelectHelper.getAllUnits()
		from(units).foreach(function(k,v)
			if v.uip == nil then
				v.uip = true
				UnitFound(v)
			end
			v.assistedByF = false
			v.assistedByE = false
			v.assistedByU = false
		end)
		from(units).foreach(function(k,v)
			local e = v:GetGuardedEntity()
			if e ~= nil then
				if v:IsInCategory("FACTORY") then e.assistedByF = true
				elseif v:IsInCategory("ENGINEER") then e.assistedByE = true
				else e.assistedByU = true 
				end
			end
		end)
		
		local newadornmentsVisible = UIP.GetSetting("showAdornments")
		if adornmentsVisible and not newadornmentsVisible then
			from(units).foreach(function(k,v)
				RemoveAllAdornments(v)
			end)
		end
		adornmentsVisible = newadornmentsVisible

		if adornmentsVisible then
			from(units).foreach(function(k,v)
				UpdateUnit(v)
			end)
		end

	end

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
		LayoutHelpers.AtLeftTopIn(st.group, worldView, posA.x, posA.y)
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