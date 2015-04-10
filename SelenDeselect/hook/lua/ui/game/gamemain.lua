local originalCreateUI = CreateUI 

local UpdateAllUnits = import('/mods/SelenDeselect/modules/selenDeselect.lua').main


function CreateUI(isReplay) 
  originalCreateUI(isReplay) 
  if not isReplay then 
	AddBeatFunction(UpdateAllUnits)
  end
	
end
