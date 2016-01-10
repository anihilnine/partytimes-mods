
local oldBeginSession = BeginSession
function BeginSession()
    oldBeginSession()

    ForkThread(function() 
		while true do
			import('/mods/ModBootstrap/modules/global-invoke.lua')
			import('/mods/ModBootstrap/modules/sim-invoke.lua').OnTick()
			WaitTicks(1)
		end
	end)
end
