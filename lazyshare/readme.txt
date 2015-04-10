LazyShare UI-Mod by SvartfaR.

With LazyShare you can share your units and ressources quick and easy only
by using your Keyboard.

LazyShare supports three teammembers and i will explain it on the default keys
(Take note: Of course you can change the keys by pressing F1 if you using a mod
which makes it possible. For example GAZ_UI or GUI):
If you have teammates you will see numbers (ID's) behind their names in the
ingame scorescreen. With this number you know which keys are for this mate.

Defaultsettings are,

for ID=1:
NUM1: Gives selected unit(s) to teammate with ID=1.
NUM4: Gives 50% of the mass in your storage to teammate with ID=1.
NUM7: Gives 50% of the energy in your storage to teammate with ID=1.
CTRL-NUM1: Emergency Button with ID=1 *

for ID=2:
NUM2: Gives selected unit(s) to teammate with ID=2.
NUM5: Gives 50% of the mass in your storage to teammate with ID=2.
NUM8: Gives 50% of the energy in your storage to teammate with ID=2.
CTRL-NUM2: Emergency Button with ID=2 *

for ID=3:
NUM3: Gives selected unit(s) to teammate with ID=3.
NUM6: Gives 50% of the mass in your storage to teammate with ID=3.
NUM9: Gives 50% of the energy in your storage to teammate with ID=3.
CTRL-NUM3: Emergency Button with ID=3 *

* This will select all your units (like CTRL-X) and give all units and ressources
to the teammate you had chosen. If this teammate can't take all of your units or 
ressources (unitcap) this function gives all the rest to the other teammates.

You see, every column is for one teammate.

If you have more than three teammates you have to share with the mates without an
ID on the classic way. ID's can change during a match when a teammate will defeated,
a teammate leaves the game or one joined your team.

IMPORTANT:
LazyShare will save the keysettings into the game.prefs. I recomment you to make a
backup of this file if you changed the default keysettings of FA or using another
mod which is using keys.

---
I have to thank all members of the VoW-Clan who had supported me with this mod
(LazyShare is excluded from mimc, my personal UI-Mod, so it's not wirtten
yesterday...) and used it to test it. Special thanks are going to Zulan who had
helped me with some LUA problems. He also had the idea to share the ressources
by the emergency button and to give the rest to the other teammates if the first
can't take all.

Thank you VoW, thank you Zulan.
---

You can load LazyShare from the vault (remember, my GPGnet nick is SvartfaR,
do not search for an author called svart ;) ). So, try it out and I hope you will
enjoy it.

---

Changelog:

Lazyshare v2.0 (20th May 2009)
- ID's are now left from the Playername.
- Focused player has a '*' in the id-column.
- Teammates are now orange in the scoreboard.
- Score will represented with K when it is higher than 999.
  For example 1500 Points are now shown as 1.5K.
- Added functions to get other modders the chance to get infos about the ID's.
  (also added support for AutoGive by falcontx)
- If the Emergencybutton was pressed and an ID was choosen that's not a valid ID
  and we have at least one Teammate it will be given all to this one.
