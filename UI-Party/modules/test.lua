local SelectHelper = import('/mods/ui-party/modules/selectHelper.lua')

function safeLog(o)
	if o == nil then
		LOG("nil")
		return
	end
	
	for k,v in o do
		LOG(k,v)
	end

end

function LogUnit(o)
	if o == nil then
		LOG("nil")
		return
	end

	LOG(o:GetEntityId())
	LOG(o:GetBlueprint().Description)
end

function VECTOR3(x,y,z)
	return { x, y, z, type = 'VECTOR3' }
end

local a, b = pcall(function()


--		local u = GetSelectedUnits()[1]
----		--LogUnit(u)
----		LogUnit(u:GetFocus())

--	wv = import('/lua/ui/game/worldview.lua').GetWorldViews()["WorldCamera"];  
--	local posA = wv:Project(u:GetPosition())


--	local UserDecal = import('/lua/user/UserDecal.lua').UserDecal
--	local s = UserDecal{}
--	local t1 = '/textures/ui/common/game/economic-overlay/econ_bmp_m.dds'
--	local t2 =  '/env/utility/decals/objective_debug_albedo.dds'
--	s:SetTexture(t2)
--	s:SetPositionByScreen(posA)
--	local w = 40
--	s:SetScale(VECTOR3(w,w,w))
--	--s:Show()

----	safeLog(s)

--	local objectiveDecal = '/env/utility/decals/objective_debug_albedo.dds'
--	local x = 10
--	local z = 10
--	local w = 100
--	local h = 100
--	local DecalLOD = 4000


end)



LOG("UI PARTY RESULT: ", a, b)   
