-- gui/formspec.lua

---
--- Tabs
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
			"listring[current_player;main]" ..
			"listring[current_player;craft]" ..
			gui.make_inv(6.25, 2, 1, 1, "current_player", "craftpreview", false) ..
			gui.make_inv(0.25, 4.7, 9, 4, "current_player", "main")
	end,
	handle = function(name, fields)
		if fields.quit then
			local player = minetest.get_player_by_name(name)
			local inv = player:get_inventory()

			if not inv:is_empty("craft") then
				local list = inv:get_list("craft")
				for _, i in pairs(list) do
					if i:is_known() and not i:is_empty() then
						minetest.item_drop(i, player, player:get_pos())
					end
				end

				inv:set_list("craft", {})
			end
		end
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
		local inv = gui.creative_inventory[name]
		local start_i = inv.start_i or 0
		local pagenum = math.floor(start_i / (6*9) + 1)
		local pagemax = math.ceil(inv.size / (6*9))
		return
			"label[7.48,6.7;" .. minetest.colorize("#FFFF00", tostring(pagenum)) .. " / " .. tostring(pagemax) .. "]" ..
			gui.make_inv(0.25, 7.7, 9, 1, "current_player", "main") ..
			gui.make_inv(5.25, 6.5, 1, 1, "detached:trash", "main", false) ..
			"listring[]" ..
			"listring[current_player;main]" ..
			"listring[detached:creative_" .. name .. ";main]" ..
			gui.make_inv(0.25, 0.25, 9, 6, "detached:creative_" .. name, "main", false, tostring(start_i), true) ..
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
		local inv    = gui.creative_inventory[name]
		assert(inv)

		if fields.creative_clear then
			inv.start_i = 0
			inv.filter = ""
			gui.update_creative_inv(name, items)
		elseif fields.creative_search or
				fields.key_enter_field == "creative_filter" then
			inv.start_i = 0
			inv.filter = fields.creative_filter:lower()
			gui.update_creative_inv(name, items)
		elseif not fields.quit then
			local start_i = inv.start_i or 0

			if fields.creative_prev then
				start_i = start_i - 6*9
				if start_i < 0 then
					start_i = inv.size - (inv.size % (6*9))
					if inv.size == start_i then
						start_i = math.max(0, inv.size - (6*9))
					end
				end
			elseif fields.creative_next then
				start_i = start_i + 6*9
				if start_i >= inv.size then
					start_i = 0
				end
			end

			inv.start_i = start_i
		end
	end,
})
