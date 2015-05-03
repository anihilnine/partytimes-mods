-- describes the common set of actions that will be bound to keys
-- format is:
--  action - the console command to execute when the key is pressed
--  category - the category to list this action under in the key assign dialog
--  order - the sort order to list this action under its category

-- Add lines like these for each new category you add to
-- /modules/buildingtab.lua:

keyActions['newcat'] = {action = "UI_Lua import('/modules/hotbuild.lua').buildAction('NewCategory')", category = 'hotbuilding', order = 1101}
