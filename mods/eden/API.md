Eden Mod API
============
The Eden mod API provides a single function to get information about the current subgame version. The mod itself is only intended for the purpose of registering required features.

`eden.get_version()`

* Returns a table containing fields `version`, `type` (release type), `core` (corresponding Minetest core version), `core_type` (correspending release type of Minetest core).

`eden.register_gamemode(name, def)`

* Register a new gamemode for use with `/gamemode` chatcommand
* `name`: Name for gamemode
* `def`: See [#Gamemode definition]

`eden.set_gamemode(player, gamemode)`

* Set the gamemode of a player
* Returns `true` if successful, otherwise, gamemode does not exist
* `player`: PlayerRef
* `gamemode`: Name of gamemode

`eden.get_gamemode(player)`

* Get the gamemode of a player
* If the player has no gamemode set, it will be automatically set depending on the `creative_enabled` setting in `minetest.conf`
* `player`: PlayerRef (or player name)