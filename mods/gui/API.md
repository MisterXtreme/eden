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