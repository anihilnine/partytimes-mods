local GetAllUnits = import('/mods/YoricksMod/modules/allunits.lua').GetAllUnits
local randomOffset = math.floor(Random(0,10))
local names = {
	'Kalvirox',
	'AlphaWolf-666',
	'AFK_',
	'Sheeo',
	'Man_of_action',
	'Bl4ck_Cr0w',
	'Ceneraii',
	'Cyko',
	'Molotow',
	'Totaltuna',
	'StefanD',
	'Grasz',
	'Golol',
	'The_Imp',
	'Timie',
	'TotalChewie',
	'KnightSolaire',
	'White_Death',
	'Ravin',
	'Gareth',
	'Hadouken',
	'Morax',
	'Palermo',
	'Mr_Death',
	'Snake',
	'Apofenas'
}
local numNames = table.getn(names)

local idlePrefixes = {
	'Bored',
	'Dancing',
	'Thinking',
	'Derping'
}
local numIdle = table.getn(idlePrefixes)

local stunnedPrefixes = {
	"KO'd",
	'Shocked',
	'Unconscious'
}
local numStunned = table.getn(stunnedPrefixes)

local healthPrefixes = {
	'Happy',
	'Annoyed',
	'Angry',
	'Raging'
}
local numHealthPrefixes = table.getn(healthPrefixes)

function modulo(a,b)
	return a - math.floor(a/b)*b
end

function GetHealthPrefix(percent)
	if percent > 0.8 then
		return 'Happy'
	end
	if percent > 0.6 then
		return 'Annoyed'
	end
	if percent > 0.3 then
		return 'Angry'
	end
	return 'Raging'
end

function NameUnits()
  while true do
	  WaitSeconds(1)
	  local i = 0
	  --print("tick")
	  --for _,u in GetAllUnits() do
	  ---[[
	  for _,u in GetAllUnits() do
	  ---[[
		  if not u:IsInCategory("STRUCTURE") and not u:IsInCategory("COMMAND") then
			  local entityId = tonumber(u:GetEntityId()) + randomOffset
			  local name = names[modulo(entityId, numNames) + 1]
			  local healthPercent = 1
			  if u:GetMaxHealth() != 0 then
				  healthPercent = u:GetHealth() / u:GetMaxHealth()
			  end

			  if u:IsIdle() then
				  name = idlePrefixes[modulo(entityId, numIdle) + 1] .. " " .. name
			  end

			  if u:IsStunned() then
				  name = stunnedPrefixes[modulo(entityId, numStunned) + 1] .. " " .. name
			  end

			  name = GetHealthPrefix(healthPercent) .. " " .. name

			  if name != nil and u:GetCustomName(nil) != name then
				  u:SetCustomName(name)
			  end
		  end
		  --]]
		  
		  --if u:IsInCategory("MOBILE") then
			--local name = ""  u:GetCustomName(nil)
				--[[if  u:GetCustomName(nil) ~= "mobile" then
					print(jeay)
				  u:SetCustomName("mobile")
				end--]]
		  --end
		  print("atleast i tried")
		  i = i + 1
	  end
	  print(i, "units in Set")
	  --]]
	  local ii = 0
	  for _,_ in GetAllUnits() do
		ii = ii +1
	  end
	  --print(ii)
  end
  
  
end
