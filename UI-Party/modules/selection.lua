function SelectSimilarOnscreenUnits()
	LOG("here")
	local units = GetSelectedUnits()
	if (units ~= nil) then 
		local blueprints = from(units).select(function(k, u) return u:GetBlueprint(); end).distinct()
		local str = ''
		blueprints.foreach(function(k,v)
			str = str .. "+inview " .. v.BlueprintId .. ","
		end)
		ConExecute("Ui_SelectByCategory " .. str .. "SOMETHINGUNPOSSIBLE") -- dodgy hack at the end there to 
	end
end