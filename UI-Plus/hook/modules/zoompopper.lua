--*****************************************************************************
--* File: lua/ui/game/zoompopper.lua
--* Author: III_Demon / Warma / PartyTime
--*****************************************************************************

## WITH INITIALIZE
## complication: changes to camera dont happen straight away so you have to forkThread(waitSeconds) before it will work
## complication: moving to a coords centers on that coord whereas we want to keep the mouse cursor in the same position after zooming. 
## complication: the first time there is a flicker whilst we work out the relationship between WS and SS coords at the (zoompop) zoom level. subsequent pops we can just reuse this ratio without flicker

local UIP = import('/mods/UI-Plus/modules/UI-Plus.lua')

local first = true
local wXperSx
local wYperSy 
local pitch
local heading
local wv
local cam
local oldToggleZoomPop = ToggleZoomPop


function Init()
	UipLog("First time zoom pop")

	cam = GetCamera('WorldCamera')
	wv = import('/lua/ui/game/worldview.lua').GetWorldViews()["WorldCamera"];

	local p1 = GetMouseWorldPos()
	local popZoom = GetPopLevel()
	
	local settings = cam:SaveSettings()
	pitch = settings.Pitch
	heading = settings.Heading

	local hpr = Vector(settings.Heading, settings.Pitch, 0)   
	cam:SnapTo(p1, hpr, popZoom)
	WaitSeconds(0)

	--3. measure the difference in ws to ss x/y
	local sp = GetMouseScreenPos()
	local p2 = UnProject(wv, sp)
	sp[1] = sp[1] + 1
	sp[2] = sp[2] + 1
	local p3 = UnProject(wv, sp)
	wXperSx = p3[1] - p2[1]
	wYperSy = p3[3] - p2[3]
	LOG(wXperSx)
	LOG(wYperSy)

end

function GetPopLevel()
	local popZoom = import('/lua/user/prefs.lua').GetFromCurrentProfile('options').gui_zoom_pop_distance
	if popZoom == nil then
		popZoom = 80
	end
	return popZoom
end

function ToggleZoomPop()
	
	if not UIP.GetSetting("overrideZoomPop") or not UIP.Enabled() then 
		oldToggleZoomPop()
		return 0
	end

	cam = GetCamera('WorldCamera')	
	wv = import('/lua/ui/game/worldview.lua').GetWorldViews()["WorldCamera"];

	local popZoom = GetPopLevel()

	if math.abs(cam:GetZoom() - popZoom) > 1 then
		Pop()
	else
		cam:Reset()
	end
end 

function Pop()

	local popZoom = GetPopLevel()

	local mp = GetMouseScreenPos()
	local center = { wv:Width()/2, wv:Height() /2 }
	local dstFromCenter = {  mp[1] - center[1], mp[2] -center[2]  }
	--LOG("mp", repr(mp))
	--LOG("ce", repr(center))
	--LOG("dstFromCenter", repr(dstFromCenter))

	local hpr = Vector(heading, pitch, 0)   
	local p1 = GetMouseWorldPos()
	--LOG("wPerS", wXperSx, wYperSy)
	--LOG("beforeFix", repr(p1))
	p1[1] = p1[1] - (wXperSx * dstFromCenter[1])
	p1[3] = p1[3] - (wYperSy * dstFromCenter[2])
	--LOG("afterFix", repr(p1))
	cam:MoveTo(p1, hpr, popZoom, 0.08)
	ForkThread(function() 
		WaitSeconds(0)
		cam:RevertRotation()
	end)

end 



--## other implementation attempts follow...



























--## MOVE TO
--function ToggleZoomPop()
--	local cam = GetCamera('WorldCamera')
--	local popZoom = import('/lua/user/prefs.lua').GetFromCurrentProfile('options').gui_zoom_pop_distance
--	if popZoom == nil then
--		popZoom = 80
--	end
--
--	if math.abs(cam:GetZoom() - popZoom) > 1 then
--
--		local settings = cam:SaveSettings()
--		local hpr = Vector(settings.Heading, settings.Pitch, 0)   
--		local p1 = GetMouseWorldPos()
--		cam:MoveTo(p1, hpr, popZoom, 0.08)
--		ForkThread(function() 
--			WaitSeconds(0)
--			cam:RevertRotation()
--		end)
--	else
--		cam:Reset()
--	end
--end 



--## SNAP TO AND CORRECT
--function ToggleZoomPop()
--   local cam = GetCamera('WorldCamera')
--   local zoomRatio = (cam:GetTargetZoom() / cam:GetMaxZoom())  
--
--   if zoomRatio > 0.4 then
--      local zoom = import('/lua/user/prefs.lua').GetFromCurrentProfile('options').gui_zoom_pop_distance
--      if zoom == nil then
--         zoom = 80
--      end
--      local hpr = Vector(-3.1415901184082, 1.0239499807358, 0)   
--      
--	  local p1 = GetMouseWorldPos()
--      cam:SnapTo(p1, hpr, zoom)
--
--
--	ForkThread(function() 
--		WaitSeconds(0)
--		FlushEvents()
--		local p2 = GetMouseWorldPos()
--		local p3 = VDiff(p1, p2)
--		local p4 = VAdd(p1, p3)
--		cam:SnapTo(p4, hpr, zoom)
--		cam:RevertRotation()
--	end)
--
--   else
--      cam:Reset()
--   end
--end 



----## SNAP TO AND CORRECT THEN MOVE ALL OVER AGAIN FROM ORIGIN
--function ToggleZoomPop()
--   local cam = GetCamera('WorldCamera')
--   local zoomRatio = (cam:GetTargetZoom() / cam:GetMaxZoom())  
--
--   if zoomRatio > 0.4 then
--      local zoom = import('/lua/user/prefs.lua').GetFromCurrentProfile('options').gui_zoom_pop_distance
--      if zoom == nil then
--         zoom = 80
--      end
--      local hpr = Vector(-3.1415901184082, 1.0239499807358, 0)   
--      
--	  local settings1 = cam:SaveSettings();
--
--	  -- jump to the mouse cursor (centered)
--	  local p1 = GetMouseWorldPos()
--      cam:SnapTo(p1, hpr, zoom)
--	  cam:RevertRotation()
--
--	ForkThread(function() 
--		WaitSeconds(0)
--		-- now move the cam so that what was under the mouse cursor - IS under the mouse cursor again.
--		local p2 = GetMouseWorldPos()
--		local p3 = VDiff(p1, p2)
--		local p4 = VAdd(p1, p3)
--
--		-- now move the cam back to the original position and softly glide to the corrected point
--		cam:RestoreSettings(settings1);
--		cam:MoveTo(p4,{ settings1.Heading, settings1.Pitch, 0},zoom,0.08)
--		ForkThread(function() 
--			WaitSeconds(0)
--			cam:RevertRotation()
--		end)
--	end)
--
--   else
--      cam:Reset()
--   end
--end 






----## USE TARGET ZOOM
--function ToggleZoomPop()
--   local cam = GetCamera('WorldCamera')
--   cam:EnableEaseInOut()
--   local zoomRatio = (cam:GetTargetZoom() / cam:GetMaxZoom())   -- 0.5 is a good level for 'zoomed most of the way out'
--
--   if zoomRatio > 0.4 then
--      local zoom = import('/lua/user/prefs.lua').GetFromCurrentProfile('options').gui_zoom_pop_distance
--      if zoom == nil then
--         zoom = 80
--      end
--		cam:SetTargetZoom(zoom);
--   else
--      cam:Reset()
--   end
--end 

