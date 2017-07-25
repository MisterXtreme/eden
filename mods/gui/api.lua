-- gui/api.lua

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

	local vx, vy = -0.91, 0.5
	local hx, hy = 0.5, -0.96
	-- Generate tabs
	for _, f in pairs(tabs) do
		local x, y, r = vx, vy, ""
		local style = f.style or "vertical"
		local icon = f.icon or "gui_null.png"
		local tooltip = f.tooltip or ""
		local tab = {
			active = "gui_tab_active.png",
			inactive = "gui_tab_inactive.png",
		}
		local shift = {
			active = {x = 1, y = 0},
			inactive = {x = 1, y = -1},
		}

		if style == "horizontal" then
			x, y = hx, hy
			tab = {
				active = "gui_tab_horizontal_active.png",
				inactive = "gui_tab_horizontal_inactive.png",
			}
			shift = {
				active = {x = 0, y = 2},
				inactive = {x = 0, y = 1},
			}
		end

		local shifted_icon = "[combine:16x16:0,0="..tab.active..":"..shift.active.x..","..shift.active.y.."="..icon
		icon = "[combine:16x16:0,0="..tab.inactive..":"..shift.inactive.x..","..shift.inactive.y.."="..icon

		form = form .. "image_button["..x..","..y..";1,1;"..minetest.formspec_escape(icon)
				..";".."tab_"..f.name..";;true;false;"..minetest.formspec_escape(shifted_icon).."]"
				.."tooltip[tab_"..f.name..";"..tooltip.."]"

		if style == "horizontal" then
			hx = x + 0.82
		elseif style == "vertical" then
			vy = y + 0.82
		end
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
	-- Initialize creative inventory
	gui.init_creative_inv(player)
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
function gui.get_itemslot_bg(x, y, w, h, count)
	local num = 0
	local out = ""

	for j = 0, h - 1, 1 do
		for i = 0, w - 1, 1 do
			out = out .."image["..x+i..","..y+j..";1,1;gui_itemslot.png]"
			num = num + 1
			if count and num >= count then
				return out
			end
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
function gui.make_inv(x, y, w, h, location, name, hotbar, start, strict_count)
	start = start or ""

	if hotbar ~= false then
		hotbar = gui.get_hotbar_itemslot_bg(x, y, w, 1)
	else
		hotbar = ""
	end

	local count
	if strict_count then
		local inv
		local split = location:split(":")
		if location == "context" then
			inv = minetest.get_inventory({type = "node", pos = strict_count})
		elseif location == "current_player" then
			if type(strict_count) == "userdata" then
				strict_count = strict_count:get_player_name()
			end

			inv = minetest.get_inventory({type = "player", name = strict_count})
		elseif split and split[1] == "player" and split[2] then
			inv = minetest.get_inventory({type = "player", name = split[2]})
		elseif split and split[1] == "nodemeta" and split[2] then
			local pos = minetest.string_to_pos(split[2])
			if pos then
				inv = minetest.get_inventory({type = "node", pos = pos})
			end
		elseif split and split[1] == "detached" and split[2] then
			inv = minetest.get_inventory({type = "detached", name = split[2]})
		end

		if inv then
			local size = 0
			local list = inv:get_list(name)
			for _, i in pairs(list) do
				if i:is_known() and not i:is_empty() then
					size = size + 1
				end
			end

			if size and size > 0 then
				count = size
			end
		end
	end

	return "list["..location..";"..name..";"..x..","..y..";"..w..","..h..";"..start.."]"
		..hotbar..gui.get_itemslot_bg(x, y, w, h, (count or nil))
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

gui.creative_inventory = {}

-- [function] Initialize creative inventory
function gui.init_creative_inv(player)
	local player_name = player:get_player_name()
	gui.creative_inventory[player_name] = {
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
	local inv = gui.creative_inventory[player_name]
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

-- Trash inventory
local trash = minetest.create_detached_inventory("trash", {
	allow_put = function(inv, listname, index, stack, player)
		return stack:get_count()
	end,
	on_put = function(inv, listname)
		inv:set_list(listname, {})
	end,
})
trash:set_size("main", 1)
