name = "Hotbuild"
uid = "f8785b7a-9e9e-4863-abb3-46aaf1caef80"
version = 11
description = "Zulans hot build mode (Nomads version), (Progaming Autohotkeys)"
author = "Zulan"
url = "http://scst.myvowclan.de/hotbuild"
icon = "/mods/hot/textures/mod_icon.dds"
selectable = true
enabled = true
exclusive = false
ui_only = true

requires = {
    '4f8b5ac3-346c-4d25-ac34-7b8ccc14eb0a', # GAZ UI mod, Nomads version 
}
requiresNames = {
    ['4f8b5ac3-346c-4d25-ac34-7b8ccc14eb0a'] = "GAZ UI (Nomads version)",
}
conflicts = {
	'98785b7a-9e9e-4863-abb3-46aaf1caef80',  # version 10
    'E0B71332-D055-11DC-8D93-9BEE55D89593',  # version 9
}
before = { }
after = {
  "4f8b5ac3-346c-4d25-ac34-7b8ccc14eb0a"
}
