-- gui/formspec.lua

gui.colors = "listcolors[#00000000;#00000010;#00000000;#68B259;#FFF]"
gui.bg     = "bgcolor[#00000000;false]"

local forms = {}

---
--- Helpers
---

-- [local function] Preprocess
local function pre(name, form)
  form = "size[8.5,9]"..form..gui.colors..gui.bg.."background[0,0;8.5,9;gui_formspec_bg.png]"

  local x, y = -0.9, 0.5
  -- Generate tabs
  for _, f in pairs(forms) do
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

  -- Get default formspec
  for _, f in pairs(forms) do
    if f.default then
      gui.set_current_tab(player, f.name)
    end
  end
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

-- [function] Set current tab
function gui.set_current_tab(player, formname)
  if type(player) == "string" then
    player = minetest.get_player_by_name(player)
  end
  local name = player:get_player_name()

  if gui.get_tab(formname) then
    local f = gui.get_tab(formname)

    player:set_inventory_formspec(pre(f.name, f.get(name)))
    player:set_attribute("inv_form", "gui:"..f.name)
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
function gui.make_inv(x, y, w, h, location, name, hotbar)
  if hotbar then
    hotbar = gui.get_hotbar_itemslot_bg(x, y, w, h)
  else
    hotbar = ""
  end

  return "list["..location..";"..name..";"..x..","..y..";"..w..","..h..";]"
    ..hotbar..gui.get_itemslot_bg(x, y, w, h)
end

-- [function] Make button
function gui.make_button(x, y, w, h, name, label, noclip, exit)
  local nc = tostring(noclip) or "false"

  local type = "image_button"
  if exit == true then
    type = "image_button_exit"
  end

  if w == 2 then
    return type.."["..x..","..y..";"..w..","..h..";gui_button_2w_inactive.png;"
      ..name..";"..label..";"..nc..";false;gui_button_2w_active.png]"
  else
    return type.."["..x..","..y..";"..w..","..h..";gui_button_3w_inactive.png;"
      ..name..";"..label..";"..nc..";false;gui_button_3w_active.png]"
  end
end
