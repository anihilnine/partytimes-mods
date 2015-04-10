

--function FilterOutSelens( )
function main()
	local tobeSelected = {}
	local logstring = ""
	local num_scouts, num_units = 0,0
	local units = GetSelectedUnits()
	
	for entityid, unit in ipairs( units or {}) do
		num_units = num_units +1
		if unit:IsInCategory("xsl0101") and unit:IsIdle() and GetFireState({unit}) == 1 then
			num_scouts = num_scouts + 1
			--logstring = logstring .. "S" .. num_units .. " "
			logstring = logstring .. "S" .. entityid .. "/" .. unit:GetEntityId() .. " "
		else
			--unit:SetCustomName("no scout")
			table.insert(tobeSelected,unit)
			
			logstring = logstring .. "O" .. entityid .. "/" .. unit:GetEntityId() .. " "
		end
		
	end
	LOG(repr(tobeSelected))
	if num_scouts~=0 and num_units > 1 then
		LOG( "SELENDESELECT: " .. num_scouts .. "/" .. num_units .. " - - " .. logstring )
		--print("test")
		SelectUnits(tobeSelected)
		--return tobeSelected
	else
		LOG("only 1 unit or no Selens")
		--return units
	end
end