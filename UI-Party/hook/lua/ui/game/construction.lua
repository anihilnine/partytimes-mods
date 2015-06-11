function StopAllExceptCurrentProduction()
	-- stolen from hotbuild
    if (currentCommandQueue) then
      for index = table.getn(currentCommandQueue), 1, -1  do
        local count = currentCommandQueue[index].count
        if (index == 1) then
          count = count - 1
        end
        DecreaseBuildCountInQueue(index, count)
      end
    end

end

