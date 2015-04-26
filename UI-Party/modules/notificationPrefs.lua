local Prefs = import('/lua/user/prefs.lua')
local savedPrefs = Prefs.GetFromCurrentProfile("Party-UI Settings")
local settingDescriptions

function getSettingDescriptions()
	return settingDescriptions
end

function init()
	-- settings
	if not savedPrefs then
		savedPrefs = {}
	end
	
	settingDescriptions = {
		{ name = "Zoompop", settings = {
			{ key="zoomPopOverride", type="bool", default=true, name="Zoompop override", description="Makes the pop more accurate" },
			{ key="zoomPopSpeed", type="number", default=0.08, name="Zoompop speed", description="Zoom pop speed", min=0, max=10, valMult=0.01  },

		}},
		{ name = "Windows", settings = {
			{ key="rearrangeBottomPanes", type="bool", default=true, name="Move bottom panes", description="Move bottom panes" },
			{ key="hideMenusOnStart", type="bool", default=true, name="Hide misc menus", descrption="On startup, collapse the multifunction (pings) and tabs (main menu)" },
			
		}},
		{ name = "Orders", settings = {
			{ key="setGroundFireOnAttack", type="bool", default=true, name="Attack sets ground firing mode", description="" },
		}},
		{ name = "Hidden", settings = {
			{ key="xOffset", default=345 },
			{ key="yOffset", default=50 },
		}},
		{ name = "Split Screen", settings = {
			{ key="startSplitScreen", type="bool", default=true, name="Start Split Screen", description="startSplitScreen" },
			{ key="smallerContructionTabWhenSplitScreen", type="bool", default=true, name="Construction to left", description="Construction menu just spans left screen (not both)" },
			{ key="moveAvatarsToLeftSplitScreen", type="bool", default=true, name="Avatars to left", description="Move the avatars (idle engies pane) to the left screen." },
			{ key="moveMainMenuToRight", type="bool", default=true, name="Main menu to right", description="Move the tabs (main menu) to the right screen." },
			{ key="t2estxxx1x1x2", type="bool", default="1233fa", name="Main menu to right", description="Move the tabs (main menu) to the right screen." },
		}},
		
		
	} 

	if not savedPrefs.global then
		savedPrefs.global = {}
	end
	
	-- make defaults
	local keys = from({})
	from(settingDescriptions).foreach(function(gk, kv) 
		from(kv.settings).foreach(function(sk, sv) 
	
			keys.addValue(sv.key)
			if savedPrefs.global[sv.key] == nil then
				UipLog("setting default " .. sv.key)
				savedPrefs.global[sv.key] = sv.default
			end
			
		end)
	end)

	-- clear old stuff
	local g = from(savedPrefs.global)
	g.foreach(function(gk, gv)
		if not keys.contains(gk) then
			UipLog("removing old key " .. gk)
			g.removeKey(gk)
		end
	end)



	if savedPrefs.notification == nil then
		savedPrefs.notification = {}
	end
	
	-- correct x/y if outside the window
	if (savedPrefs.global.xOffset < 0 or savedPrefs.global.xOffset > GetFrame(0).Width()) then
		UipLog("!!!!", GetFrame(0).Width())
		savedPrefs.global.xOffset = GetFrame(0).Width()/2
	end
	if (savedPrefs.global.yOffset < 0 or savedPrefs.global.yOffset > GetFrame(0).Height()) then
		savedPrefs.global.yOffset = GetFrame(0).Height()/2
	end
	
	savePreferences()
end

function savePreferences()
	Prefs.SetToCurrentProfile("Party-UI Settings", savedPrefs)
	Prefs.SavePreferences()
end

function getPreferences()
	return savedPrefs
end

function setAllGlobalValues(t)
	for id, value in t do
		savedPrefs.global[id] = value
	end
	savePreferences()
end

function setXYvalues(posX, posY)
	savedPrefs.global.xOffset = posX
	savedPrefs.global.yOffset = posY
	savePreferences()
end

