-- gui/formspec.lua

gui.colors = "listcolors[#00000000;#00000010;#00000000;#68B259;#FFF]"
gui.bg     = "bgcolor[#00000000;false]"

local forms = {}

---
--- Helpers
---

-- [local function] Preprocess
local function pre(player, name, form, group)
  form = "size[9.5,9]"..form..gui.colors..gui.bg.."background[0,0;9.5,9;gui_formspec_bg.png]"

  local tab  = gui.get_tab(name)
  local tabs = forms
  local group = group or gui.get_inv_group(player)
  if group then
    tabs = gui.get_tabs_by_group(group)
  end

  local x, y = -0.9, 0.5
  -- Generate tabs
  for _, f in pairs(tabs) do
    local icon = f.icon or "gui_null.png"
    local tooltip = f.tooltip or ""
    local shifted_icon = "[combine:16x16:0,0=gui_tab_active.png:0,1="..icon

    form = form .. "image_button["..x..","..y..";1,1;gui_tab_inactive.png^"..icon
      ..";".."tab_"..f.name..";;true;false;"..minetest.formspec_escape(shifted_icon).."]"
      .."tooltip[tab_"..f.name..";"..tooltip.."]"

    y = y + 0.82
  end

  return form
end

---
--- Callbacks
---

-- [register] On join
minetest.register_on_joinplayer(function(player)
  -- Set inventory size
  player:get_inventory():set_size("main", 9 * 3)
end)

-- [register] On receive fields
minetest.register_on_player_receive_fields(function(player, formname, fields)
  if formname == "" then
    formname = player:get_attribute("inv_form") or "gui:inventory"
  end

  formname = formname:split(":")

  if formname[1] == "gui" and gui.get_tab(formname[2]) then
    -- Check for tab clicks
    for _, f in pairs(forms) do
      if fields["tab_"..f.name] then
        gui.set_current_tab(player, f.name)
        return
      end
    end

    local handle = gui.get_tab(formname[2]).handle
    if handle then
      handle(player:get_player_name(), fields)
    end
  end
end)

---
--- API
---

-- [function] Register tab
function gui.register_tab(name, def)
  def.name = name
  forms[#forms + 1] = def
end

-- [function] Get tab
function gui.get_tab(name)
  for _, f in pairs(forms) do
    if f.name == name then
      return f
    end
  end
end

-- [function] Get tabs by group
function gui.get_tabs_by_group(group)
  local tabs = {}
  for _, f in pairs(forms) do
    if f.groups[group] then
      tabs[#tabs + 1] = f
    end
  end
  return tabs
end

-- [function] Get group default tab
function gui.get_group_default(group)
  local tabs = gui.get_tabs_by_group(group)
  if tabs then
    for _, f in pairs(tabs) do
      if f.default then
        return f
      end
    end
  end
end

-- [function] Set current tab
function gui.set_current_tab(player, formname)
  if type(player) == "string" then
    player = minetest.get_player_by_name(player)
  end
  local name = player:get_player_name()

  if gui.get_tab(formname) then
    local f = gui.get_tab(formname)

    player:set_inventory_formspec(pre(player, f.name, f.get(name)))
    player:set_attribute("inv_form", "gui:"..f.name)
  end
end

-- [function] Get player inventory group
function gui.get_inv_group(player)
  if type(player) == "string" then
    player = minetest.get_player_by_name(player)
  end

  local attr = player:get_attribute("inv_tab_group")
  if attr and attr ~= "" then
    return attr
  end
end

-- [function] Set tab group
function gui.set_tab_group(player, group)
  if type(player) == "string" then
    player = minetest.get_player_by_name(player)
  end
  local name = player:get_player_name()

  -- Set attribute
  player:set_attribute("inv_tab_group", group)

  local default = gui.get_group_default(group)
  if default then
    player:set_inventory_formspec(pre(player, default.name, default.get(name), group))
    player:set_attribute("inv_form", "gui:"..default.name)
  end
end

-- [function] Get itemslot background
function gui.get_itemslot_bg(x, y, w, h)
   local out = ""
   for i = 0, w - 1, 1 do
      for j = 0, h - 1, 1 do
	       out = out .."image["..x+i..","..y+j..";1,1;gui_itemslot.png]"
      end
   end
   return out
end

-- [function] Get hotbar itemslot background
function gui.get_hotbar_itemslot_bg(x, y, w, h)
   local out = ""
   for i = 0, w - 1, 1 do
      for j = 0, h - 1, 1 do
	       out = out .."image["..x+i..","..y+j..";1,1;gui_itemslot.png^gui_itemslot_dark.png]"
      end
   end
   return out
end

-- [function] Make inventory
function gui.make_inv(x, y, w, h, location, name, hotbar, start)
  start = start or ""

  if hotbar ~= false then
    hotbar = gui.get_hotbar_itemslot_bg(x, y, w, 1)
  else
    hotbar = ""
  end

  return "list["..location..";"..name..";"..x..","..y..";"..w..","..h..";"..start.."]"
    ..hotbar..gui.get_itemslot_bg(x, y, w, h)
end

-- [function] Make button
function gui.make_button(x, y, w, h, name, label, noclip, exit)
  local nc = tostring(noclip) or "false"

  local type = "image_button"
  if exit == true then
    type = "image_button_exit"
  end

  if w == 1 then
    return type.."["..x..","..y..";"..w..","..h..";gui_button_1w_inactive.png;"
      ..name..";"..label..";"..nc..";false;gui_button_1w_active.png]"
  elseif w == 2 then
    return type.."["..x..","..y..";"..w..","..h..";gui_button_2w_inactive.png;"
      ..name..";"..label..";"..nc..";false;gui_button_2w_active.png]"
  else
    return type.."["..x..","..y..";"..w..","..h..";gui_button_3w_inactive.png;"
      ..name..";"..label..";"..nc..";false;gui_button_3w_active.png]"
  end
end

---
--- Creative inventory
---

-- Code adapted from Minetest Game.

local player_inventory = {}

-- [function] Initialize creative inventory
function gui.init_creative_inv(player)
	local player_name = player:get_player_name()
	player_inventory[player_name] = {
		size = 0,
		filter = "",
		start_i = 0
	}

	minetest.create_detached_inventory("creative_" .. player_name, {
		allow_move = function(inv, from_list, from_index, to_list, to_index, count, player2)
			if not to_list == "main" then
				return count
			else
				return 0
			end
		end,
		allow_put = function(inv, listname, index, stack, player2)
			return 0
		end,
		allow_take = function(inv, listname, index, stack, player2)
			return -1
		end,
		on_move = function(inv, from_list, from_index, to_list, to_index, count, player2)
		end,
		on_put = function(inv, listname, index, stack, player2)
		end,
		on_take = function(inv, listname, index, stack, player2)
			if stack and stack:get_count() > 0 then
				minetest.log("action", player_name .. " takes " .. stack:get_name().. " from creative inventory")
			end
		end,
	}, player_name)

	gui.update_creative_inv(player_name, minetest.registered_items)
end

-- [function] Update creative inventory
function gui.update_creative_inv(player_name, content)
	local creative_list = {}
	local player_inv = minetest.get_inventory({type = "detached", name = "creative_" .. player_name})
	local inv = player_inventory[player_name]
	if not inv then
		gui.init_creative_inv(minetest.get_player_by_name(player_name))
	end

	for name, def in pairs(content) do
		if not (def.groups.not_in_creative_inventory == 1) and
				def.description and def.description ~= "" and
				(def.name:find(inv.filter, 1, true) or
					def.description:lower():find(inv.filter, 1, true)) then
			creative_list[#creative_list+1] = name
		end
	end

	table.sort(creative_list)
	player_inv:set_size("main", #creative_list)
	player_inv:set_list("main", creative_list)
	inv.size = #creative_list
end

-- Create the trash field
local trash = minetest.create_detached_inventory("trash", {
	-- Allow the stack to be placed and remove it in on_put()
	-- This allows the creative inventory to restore the stack
	allow_put = function(inv, listname, index, stack, player)
		return stack:get_count()
	end,
	on_put = function(inv, listname)
		inv:set_list(listname, {})
	end,
})
trash:set_size("main", 1)

-- [register] On join initialize creative inventory for player
minetest.register_on_joinplayer(function(player)
	gui.init_creative_inv(player)
end)


---
--- Registrations
---

-- [register] Inventory tab
gui.register_tab("inventory", {
  icon = "gui_icon_inventory.png",
  tooltip = "Inventory",
  default = true,
  groups = {survival = true, creative = true},
  get = function(name)
    return
      gui.make_inv(2.3, 1, 3, 3, "current_player", "craft", false) ..
      "image[5.25,2;1,1;gui_arrow_bg.png^[transformR270]" ..
      gui.make_inv(6.25, 2, 1, 1, "current_player", "craftpreview", false) ..
      gui.make_inv(0.25, 4.7, 9, 4, "current_player", "main")
  end,
})

local items = minetest.registered_items

-- [register] Creative inventory tab
gui.register_tab("creative", {
	icon = "gui_icon_creative.png",
  tooltip = "Creative inventory",
  groups = {creative = true},
  get = function(name)
    gui.update_creative_inv(name, items)
    local inv = player_inventory[name]
    local start_i = inv.start_i or 0
    local pagenum = math.floor(start_i / (3*8) + 1)
    local pagemax = math.ceil(inv.size / (3*8))
    return
      "label[7.48,6.7;" .. minetest.colorize("#FFFF00", tostring(pagenum)) .. " / " .. tostring(pagemax) .. "]" ..
      gui.make_inv(0.25, 7.7, 9, 1, "current_player", "main") ..
      gui.make_inv(5.25, 6.5, 1, 1, "detached:trash", "main", false) ..
      "listring[]" ..
      "listring[current_player;main]" ..
      "listring[detached:creative_" .. name .. ";main]" ..
      gui.make_inv(0.25, 0.25, 9, 6, "detached:creative_" .. name, "main", false, tostring(start_i)) ..
      "field[0.55,6.89;3.2,1;creative_filter;;" .. minetest.formspec_escape(inv.filter) .. "]" ..
      gui.make_button(6.65, 6.55, 1, 1, "creative_prev", "<") ..
      gui.make_button(8.34, 6.55, 1, 1, "creative_next", ">") ..
      gui.make_button(3.35, 6.55, 1, 1, "creative_search", "?") ..
      gui.make_button(4, 6.55, 1, 1, "creative_clear", "X") ..
      [[
        image[5.33,6.6;0.8,0.8;gui_icon_trash.png]
        tooltip[creative_search;Search]
        tooltip[creative_clear;Reset]
        listring[current_player;main]
        listring[current_player;main]
        field_close_on_enter[creative_filter;false]
      ]]
  end,
  handle = function(name, fields)
    local player = minetest.get_player_by_name(name)
    local inv    = player_inventory[name]
    assert(inv)

    if fields.creative_clear then
      inv.start_i = 0
      inv.filter = ""
      gui.update_creative_inv(name, items)
      gui.set_current_tab(player, "creative")
    elseif fields.creative_search or
        fields.key_enter_field == "creative_filter" then
      inv.start_i = 0
      inv.filter = fields.creative_filter:lower()
      gui.update_creative_inv(name, items)
      gui.set_current_tab(player, "creative")
    elseif not fields.quit then
      local start_i = inv.start_i or 0

      if fields.creative_prev then
        start_i = start_i - 3*8
        if start_i < 0 then
          start_i = inv.size - (inv.size % (3*8))
          if inv.size == start_i then
            start_i = math.max(0, inv.size - (3*8))
          end
        end
      elseif fields.creative_next then
        start_i = start_i + 3*8
        if start_i >= inv.size then
          start_i = 0
        end
      end

      inv.start_i = start_i
      gui.set_current_tab(player, "creative")
    end
  end,
})
