function OnBeat()
	local a, b = pcall(function()

		LOG2("UI-OnBeat")

	end)

	if not a then LOG2("UI-OnBeat RESULT: ", a, b) end
end

-- requires /enablediskwatch flag to work, therefore is handy during development but dont expect this to work more than once in a real game
function OnChangeDetected()
	local a, b = pcall(function()

		LOG2("UI-OnChangeDetected")
		Sample1();

	end)

	if not a then LOG2("UI-OnChangeDetected RESULT: ", a, b) end
end

function Sample1()
	Sample1TearDown()
	Sample1Setup()
end

function Sample1TearDown()
	if rawget(_G, "sample1") ~= nil then -- need to use rawget to bypass restriction of using undeclared global variables (which you need to do to test if it is declared)
		LOG2("tearing down sample1")
		if _G.sample1.beat then import('/lua/ui/game/gamemain.lua').RemoveBeatFunction(_G.sample1.beat) end -- stop updating last instance of sample1
		if _G.sample1.uiBox then _G.sample1.uiBox:Destroy() end -- destroy ui of sample1 - destroys child ui as well (uiText)
		_G.sample1 = nil
	end
end

function Sample1Setup()
	LOG2("setting up sample1")

	local uiBox = import('/lua/maui/Bitmap.lua').Bitmap(GetFrame(0)) -- getFrame(0) is the first monitor
	uiBox.Width:Set(100)
	uiBox.Height:Set(40)
	uiBox.Left:Set(500)
	uiBox.Top:Set(500)
	uiBox.Depth:Set(99)
	uiBox:DisableHitTest() -- allow click through
	uiBox:InternalSetSolidColor('aa000000')

	local uiText = import('/lua/ui/uiutil.lua').CreateText(uiBox, "text", 12, import('/lua/ui/uiutil.lua').bodyFont) -- by setting the parent to uiBox, it affects the z-order (draw order) and destroys child when parent is destroyed
	uiText.Width:Set(10)
	uiText.Height:Set(10)
	uiText:SetNewColor('red') -- you could make a change here to see old ui getting torn down
	uiText:DisableHitTest()		
	import('/lua/maui/layouthelpers.lua').AtLeftIn(uiText, uiBox, 5) -- these two calls are dynamic and relative so if you change the position/width of uiBox, that will change the position of child uiText as well
	import('/lua/maui/layouthelpers.lua').AtVerticalCenterIn(uiText, uiBox)	

	_G.sample1 = { }
	_G.sample1.uiBox = uiBox
	_G.sample1.uiText = uiText
	_G.sample1.beat = Sample1OnBeat

	import('/lua/ui/game/gamemain.lua').AddBeatFunction(Sample1OnBeat) -- constantly run code to update the ui
end

local lastUnit = nil
function Sample1OnBeat()
	local units = GetSelectedUnits()
	if (units ~= nil) then -- never is a zero length table
		local u = units[1]
		_G.sample1.uiText:SetText("Unit Id: " .. u:GetEntityId())
		if u ~= lastUnit then
			_G.LogTable(u); -- this logs without drama
			-- LOG(repr(u)) -- this hangs the game irrecoverably
		end
		lastUnit = u
	else
		_G.sample1.uiText:SetText("Nothing Selected")
	end

end

OnChangeDetected()

