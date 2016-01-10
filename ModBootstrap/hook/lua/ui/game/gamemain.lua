local oldCreateUI = CreateUI
function CreateUI(isReplay)
	oldCreateUI(isReplay)

	AddBeatFunction(function() 
		import('/mods/ModBootstrap/modules/global-invoke.lua')
        import('/mods/ModBootstrap/modules/ui-invoke.lua').OnBeat()
    end)
end 
