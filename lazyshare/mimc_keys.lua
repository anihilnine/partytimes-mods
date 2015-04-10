local KeyMapper = import('/lua/keymap/keymapper.lua')

function initUserKeyActions()
	KeyMapper.SetUserKeyAction('give_all_units_to_ally_1', {action = "UI_LUA import('/mods/lazyshare/mimc_diplomacy.lua').mimc_giveSelectedUnitsToAlly(true, 1)", category = "mimc", order = 660})
	KeyMapper.SetUserKeyAction('give_units_to_ally_1', {action = "UI_LUA import('/mods/lazyshare/mimc_diplomacy.lua').mimc_giveSelectedUnitsToAlly(false, 1)", category = "mimc", order = 661})
	KeyMapper.SetUserKeyAction('give_mass_to_ally_1', {action = "UI_LUA import('/mods/lazyshare/mimc_diplomacy.lua').mimc_giveRessToAlly(50.0, 0.0, 1)", category = "mimc", order = 662})
	KeyMapper.SetUserKeyAction('give_energy_to_ally_1', {action = "UI_LUA import('/mods/lazyshare/mimc_diplomacy.lua').mimc_giveRessToAlly(0.0, 50.0, 1)", category = "mimc", order = 663})	
	KeyMapper.SetUserKeyAction('give_all_units_to_ally_2', {action = "UI_LUA import('/mods/lazyshare/mimc_diplomacy.lua').mimc_giveSelectedUnitsToAlly(true, 2)", category = "mimc", order = 664})
	KeyMapper.SetUserKeyAction('give_units_to_ally_2', {action = "UI_LUA import('/mods/lazyshare/mimc_diplomacy.lua').mimc_giveSelectedUnitsToAlly(false, 2)", category = "mimc", order = 665})
	KeyMapper.SetUserKeyAction('give_mass_to_ally_2', {action = "UI_LUA import('/mods/lazyshare/mimc_diplomacy.lua').mimc_giveRessToAlly(50.0, 0.0, 2)", category = "mimc", order = 666})
	KeyMapper.SetUserKeyAction('give_energy_to_ally_2', {action = "UI_LUA import('/mods/lazyshare/mimc_diplomacy.lua').mimc_giveRessToAlly(0.0, 50.0, 2)", category = "mimc", order = 667})	
	KeyMapper.SetUserKeyAction('give_all_units_to_ally_3', {action = "UI_LUA import('/mods/lazyshare/mimc_diplomacy.lua').mimc_giveSelectedUnitsToAlly(true, 3)", category = "mimc", order = 668})	
	KeyMapper.SetUserKeyAction('give_units_to_ally_3', {action = "UI_LUA import('/mods/lazyshare/mimc_diplomacy.lua').mimc_giveSelectedUnitsToAlly(false, 3)", category = "mimc", order = 669})
	KeyMapper.SetUserKeyAction('give_mass_to_ally_3', {action = "UI_LUA import('/mods/lazyshare/mimc_diplomacy.lua').mimc_giveRessToAlly(50.0, 0.0, 3)", category = "mimc", order = 670})
	KeyMapper.SetUserKeyAction('give_energy_to_ally_3', {action = "UI_LUA import('/mods/lazyshare/mimc_diplomacy.lua').mimc_giveRessToAlly(0.0, 50.0, 3)", category = "mimc", order = 671})
end

function initDefaultKeyMap()
  --initUserKeyActions()
  --local defaultKeyMappings = import('/mods/lazyshare/defaultKeyMap.lua').mimcDefaultKeyMap
  --  for pattern, action in defaultKeyMappings do
   -- KeyMapper.SetUserKeyMapping(pattern, false, action)
  --end
end