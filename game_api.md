Eden API
========
GitHub Repo: https://github.com/RevDevGames/eden

The Eden subgame allows you to extend even further in addition to the Minetest engine's built-in API through many custom APIs. For information on the Minetest API, visit https://github.com/minetest/minetest/blob/master/doc/lua_api.txt

Please note:

* [XYZ] refers to a section the Minetest API
* [#ABC] refers to a section in this document
* [pos] refers to a position table `{x = -5, y = 0, z = 200}`

Eden API
--------
The Eden mod API allows you to get information about the current subgame version.

`eden.get_version()`

* Returns a table containing fields `version`, `type` (release type), `core` (corresponding Minetest core version), `core_type` (correspending release type of Minetest core).

Gamemode API
------------
The gamemode API allows registering new gamemodes to be used in-game.

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

GUI API
-------
The GUI API easily generates formstrings for custom elements and allows you to register extra inventory tabs/groups.

`gui.register_tab(name, def)`

* Register new tab
* `name`: Name for tab
* `def`: See [#Tab definition]

`gui.get_tab(name)`

* Get the definition of a tab
* `name`: Name of tab

`gui.set_current_tab(player, tabname)`

* Set/update the tab displayed when the player opens the inventory
* `player`: PlayerRef/Name of player
* `tabname`: Name of previously registered tab

`gui.get_itemslot_bg(x, y, w, h)`

* Get the itemslot background for inventories
* `x`, `y`: Placement on x and y axis
* `w`, `h`: Inventory width, height

`gui.get_hotbar_itemslot_bg(x, y, w, h)`

* Get background for hotbar row in inventories
* `x`, `y`: Placement on x and y axis
* `w`, `h`: Inventory width, height

`gui.make_inv(x, y, w, h, location, name, hotbar)`

* Generate formstring for an inventory
* `x`, `y`: Placement on x and y axis
* `w`, `h`: Inventory width, height
* `location`: Location of the inventory (e.g. `current_player`)
* `name`: Name of the inventory (e.g. `main`)
* `hotbar`: Boolean determinining whether the first row should be considered as connected to the hotbar

`gui.make_button(x, y, w, h, name, label, noclip, exit)`

* Generate formstring for a button
* `x`, `y`: Placement on x and y axis
* `w`, `h`: Inventory width, height __Note:__ Only widths of `1`, `2`, and `3` are supported
* `name`: Name of button as returned in fields
* `label`: Text shown on button
* `noclip=true`: Allow button to be shown outside the formspec
* `exit=true`: Exit formspec on button click

`gui.get_tabs_by_group(group)`

* Get all tabs with a specific group
* `group`: Group name

`gui.get_group_default(group)`

* Get default tab of a specific group
* `group`: Group name

`gui.set_tab_group(player, group)`

* Set the formspec tab group to be shown (allows player to choose between only tabs whose group matches rather than all tabs)
* `player`: PlayerRef (or player name)
* `group`: Group name

`gui.init_creative_inv(player)`

* Initialize detached creative inventory for a player
* `player`: PlayerRef

`gui.update_creative_inv(player_name, content)`

* Update creative inventory for a player
* `player_name`: Name of player
* `content`: Table containing a list of nodes/craftitems

#### Tab definition
```lua
{
  icon = "tab_inventory.png",
  tooltip = "Inventory",
  default = true, -- Set tab to default
  groups = { survival = true, creative = false}, -- Tab groups allow grouping multiple tabs together
  get = function(name) -- Get formspec string (must return a formstring)
    return [[
      label[0,0;Hello world!]
    ]]
  end,
  handle = function(name, fields)
    -- Handle submitted data
  end,
}
```

Players API
-----------
The players API allows getting or setting specifics related to the player including animation, model, nametag colour, and textures.

`players.register_model(name, def)`

* Register new model
* `name`: Name for model
* `def`: See [#Model definition]

`players.get_animation(player)`

* Returns a table containing fields `model`, `textures` and `animation`.
* Any of the fields of the returned table may be nil.
* `player`: PlayerRef

`players.set_model(player, model_name)`

* Change a player's model
* `player`: PlayerRef
* `model_name`: model registered with player_register_model()

`players.set_textures(player, textures)`

* Sets player textures
* `player`: PlayerRef
* `textures`: array of textures, If `textures` is nil, the default textures from the model def are used

`players.set_animation(player, anim_name, speed)`

* Sets player textures
* `player`: PlayerRef
* `textures`: array of textures, If `textures` is nil, the default textures from the model def are used

`players.set_nametag_colour(player, colour)`

* Sets nametag colour of a player
* `player`: PlayerRef
* `colour`: Table of colour attributes (`a`: alpha, `r`: red, `g`: green, `b`: blue)
* If a colour attribute is not provided, it defaults to `255`

#### Model definition
```lua
{
  animation_speed = 30, -- Animation speed
  textures = {"character.png"}, -- Textures file
  animations = {
    -- Standard animations
    stand = { x=  0, y= 79, },
    ...
  }
}
```

Soil API
--------
The soil API allows registering soils nodes (e.g grass/dirt).

`soil.register(name, def)`

* `name`: Name of soil (without modname)
* `def`: See [Node definition (`register_node`)]
    * Unless overriden in definition, groups `crumbly` and `soil`,
    * `is_ground_content`, and `drops` are automatically set.

Trees API
---------
The trees API allows registering, checking, placing, and growing trees.

`trees.register(name, def)`

* Register a new tree along with all its nodes
* `name`: Name of tree (as in a node's itemstring)
* `def`: See [#Tree definition]

`trees.get_name(pos)`

* Returns the tree name of a node at a position
* If the node at the position specified is not part of a valid tree, `nil` will be returned
* `pos`: Position of node related to tree

`trees.get_def(pos)`

* Returns the original tree definition of a node at a position
* If the node at the position specified is not part of a valid tree, `nil` will be returned
* `pos`: Position of node related to tree

`trees.can_grow(pos)`

* Returns `true` if the sapling can grow
* `pos`: Position of sapling

`trees.place(name, pos)`

* Place a tree
* `name`: Name of tree (as in a node's itemstring)
* `pos`: Position at which to place the tree

`trees.grow(pos)`

* Grow a tree from any of the tree's child nodes
* Same as `trees.place` but requires that the target node be related to the tree and only executes if `trees.can_grow` returns `true`
* If the tree cannot be grown, it will retry later
* `pos`: Position of the tree's child node (e.g. sapling, leaf, trunk)

#### Tree definition
```lua
{
  basename = "Oak", -- Name to be concatenated for other nodes
  center = "trees_oak_log.png", -- Center (top/bottom) texture
  sides = "trees_oak_log_sides.png", -- Side texture
  plank = "trees_oak_plank.png", -- Plank texture
  sapling = "trees_oak_sapling.png", -- Sapling texture
  leaf = "trees_oak_leaf.png", -- Leaf texture
  offset = { x = -3, y = -1, z = -3}, -- Placement offset (x and z typically half the width and depth of the tree, y typically -1)
  schematic = "oak_tree.mts", -- Tree schematic file
  -- Mapgen definitions (minus those mentioned above - i.e. schematic)
  mapgen = {
    place_on = {"soil:dirt_with_grass"},
    fill_ratio = 0.05,
    biomes = {"eden:grassland"},
    y_min = 1,
    y_max = 200,
  },
}
```

Tools API
---------
The tools API easily registers entire sets of tools.

`tools.register(basename, basestack, def)`

* Registers a set of tools depending on information provided
* `basename`: Readable name to be used in tooltip
* `basestack`: Name to be used in itemstack
* `def`: See [#Tool definition]

#### Tool Definition
```lua
tools.register("Diamond", "diamond", {
  material = "ores:diamond",
	pick = {"tools_diamond_pick.png", {
		-- Capabilities
	}},
	axe = {"tools_diamond_axe.png", {
		-- Capabilities
	}},
	shovel = {"tools_diamond_shovel.png", {
		-- Capabilities
	}},
	hoe = {"tools_diamond_hoe.png", {
		-- Capabilities
	}},
})
```