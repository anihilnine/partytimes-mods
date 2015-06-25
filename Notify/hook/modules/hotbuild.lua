-- Some of the work here is redundant when cycle_preview is disabled
function buildActionBuilding(name, modifier)
  --LOG("BAB " .. name)
  local options = Prefs.GetFromCurrentProfile('options')
  local allValues = buildingTab[name]
  --LOG(repr(allValues))
  local effectiveValues = {}
  
 if (table.find(allValues, "_templates")) then
    return buildActionTemplate(modifier)
  end
  
  -- Reset everything that could be fading or running  
  hideCycleMap()

  -- filter the values
  local selection=GetSelectedUnits()
  local availableOrders,  availableToggles, buildableCategories = GetUnitCommandData(selection)
  local newBuildableCategories = import('/lua/ui/game/construction.lua').ModifyBuildablesForACU(buildableCategories, selection)
  local buildable = EntityCategoryGetUnitList(newBuildableCategories)
  
  for i1, value in allValues do
    for i2, buildableValue in buildable do
      if value == buildableValue then
        table.insert(effectiveValues, value)
      end
    end
  end
  
  local maxPos = table.getsize(effectiveValues)
  if (maxPos == 0) then
    return
  end
  
  -- Check if the selection/key has changed
  if ((cycleLastName == name) and (cycleLastMaxPos == maxPos)) then
    cyclePos = cyclePos + 1
    if(cyclePos > maxPos) then
      cyclePos = 1
    end
  else
    initCycleButtons(effectiveValues)
    cyclePos = 1
    cycleLastName = name
    cycleLastMaxPos = maxPos
  end
  
  if (options.hotbuild_cycle_preview == 1) then
    -- Highlight the active button
    for i, button in cycleButtons do
      if (i == cyclePos) then
        button:SetAlpha(1, true)
      else
        button:SetAlpha(0.4, true)
      end
    end
  
    cycleMap:Show()
    -- Start the fading thread  
    cycleThread = ForkThread(function()
		stayTime = options.hotbuild_cycle_reset_time / 2000.0;
		fadeTime = options.hotbuild_cycle_reset_time / 2000.0;
		
        WaitSeconds(stayTime)
        if (not cycleMap:IsHidden()) then
          Effect.FadeOut(cycleMap, fadeTime, 0.6, 0.1)
        end
        WaitSeconds(fadeTime)
        cyclePos = 0
      end)
  else
      cycleThread = ForkThread(function()
		WaitSeconds(options.hotbuild_cycle_reset_time / 1000.0);
        cyclePos = 0
      end)
  end
    
  local cmd = effectiveValues[cyclePos]
  -- LOG("StartCommandMode:" .. cmd)
  ClearBuildTemplates()
  CommandMode.StartCommandMode("build", {name = cmd})
end