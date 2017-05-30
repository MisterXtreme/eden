Gamemode API
============

`gamemode.register(name, def)`

* Register a new gamemode for use with `/gamemode` chatcommand
* `name`: Name for gamemode
* `def`: See [#Gamemode definition]

`gamemode.set(player, gamemode)`

* Set the gamemode of a player
* Returns `true` if successful, otherwise, gamemode does not exist
* `player`: PlayerRef
* `gamemode`: Name of gamemode

`gamemode.get(player)`

* Get the gamemode of a player
* If the player has no gamemode set, it will be automatically set depending on the `creative_enabled` setting in `minetest.conf`
* `player`: PlayerRef or username

`gamemode.def(name)`

* Get gamemode definition
* `name`: Name of gamemode

`gamemode.can_interact(player)`

* Returns `true` if the player can interact with objects in the world
* `player`: PlayerRef or username

#### Gamemode definition
```lua
{
  tab_group = "creative", -- Group of tabs to be shown in inventory
  aliases = {"c", "1"}, -- Aliases that refer to the gamemode

  -- Gamemode-specific hand definition
  hand = {
    range = 10 -- Custom range
    on_use = function() ... end, -- Custom on_use
    full_punch_interval = 1.0,
		max_drop_level = 0,
		groupcaps = {
			fleshy = {times={[2]=2.00, [3]=1.00}, uses=0, maxlevel=1},
			crumbly = {times={[2]=3.00, [3]=0.70}, uses=0, maxlevel=1},
			snappy = {times={[3]=0.40}, uses=0, maxlevel=1},
			oddly_breakable_by_hand = {times={[1]=7.00,[2]=4.00,[3]=1.40},
	         uses=0, maxlevel=3},
	   },
    damage_groups = {fleshy=1},
  },

  stack_unlimited = true, -- Whether the player can place an infinite amount of blocks from a single itemstack
  item_drops = "auto", -- Automatically pick up item if not in inventory (used by creative), else drop item
  hud_flags = { hotbar = false }, -- Change HUD flags for gamemode
  privileges = { interact = false }, -- Enable/disable privileges for gamemode
  on_enable = function(player)
    -- Called when the gamemode is enabled for a player
  end,
  on_disable = function(player)
    -- Called when the player changes to another gamemode
  end,
}
```
