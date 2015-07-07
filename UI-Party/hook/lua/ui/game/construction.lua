local UnitLock = import('/mods/ui-party/modules/unitlock.lua')


function StopAllExceptCurrentProduction()

	local units = GetSelectedUnits()
	
	for k,v in units do
		local queue = SetCurrentFactoryForQueueDisplay(v)
		clearQueue(v, queue)
	end

end

function clearQueue(unit, queue)
	-- stolen from hotbuild
	if (queue) then
		for index = table.getn(queue), 1, -1  do
			local count = queue[index].count
			if index == 1 and unit:GetWorkProgress() > 0 then
				count = count - 1
			end
			DecreaseBuildCountInQueue(index, count)
		end
	end
end
