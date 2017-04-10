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
* `w`, `h`: Inventory width, height __Note:__ Only widths of `2` and `3` are supported
* `name`: Name of button as returned in fields
* `label`: Text shown on button
* `noclip=true`: Allow button to be shown outside the formspec
* `exit=true`: Exit formspec on button click

#### Tab definition
```lua
{
  icon = "tab_inventory.png",
  tooltip = "Inventory",
  default = true, -- Set tab to default
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