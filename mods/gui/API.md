Inventory Formspec API
======================
The Inventory Formspec API (also known as ifAPI) allows you to register inventory tabs to be shown on the left as well as make use of many custom "elements" in non-inventory formspecs. 

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