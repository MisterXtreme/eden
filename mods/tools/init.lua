-- tools/init.lua

tools = {}

---
--- API
---

-- [function] Register tool set
function tools.register(basename, basestack, def)
	if def.pick then
		minetest.register_tool("tools:"..basestack.."_pick", {
			description = basename.." Pickaxe",
			inventory_image = def.pick[1],
			tool_capabilities = def.pick[2],
		})

		minetest.register_craft({
			output = "tools:"..basestack.."_pick",
			recipe = {
				{def.material, def.material, def.material},
				{"", "trees:stick", ""},
				{"", "trees:stick", ""},
			},
		})
	end

	if def.axe then
		minetest.register_tool("tools:"..basestack.."_axe", {
			description = basename.." Axe",
			inventory_image = def.axe[1],
			tool_capabilities = def.axe[2],
		})

		minetest.register_craft({
			output = "tools:"..basestack.."_axe",
			recipe = {
				{def.material, def.material, ""},
				{def.material, "trees:stick", ""},
				{"", "trees:stick", ""},
			},
		})

		minetest.register_craft({
			output = "tools:"..basestack.."_axe",
			recipe = {
				{"", def.material, def.material},
				{"", "trees:stick", def.material},
				{"", "trees:stick", ""},
			},
		})
	end

	if def.hatchet then
		minetest.register_tool("tools:"..basestack.."_hatchet", {
			description = basename.." Hatchet",
			inventory_image = def.hatchet[1],
			tool_capabilities = def.hatchet[2],
		})

		minetest.register_craft({
			output = "tools:"..basestack.."_hatchet",
			recipe = {
				{def.material, def.material, ""},
				{def.material, "trees:stick", ""},
			},
		})

		minetest.register_craft({
			output = "tools:"..basestack.."_hatchet",
			recipe = {
				{"", def.material, def.material},
				{"", "trees:stick", def.material},
			},
		})
	end

	if def.shovel then
		minetest.register_tool("tools:"..basestack.."_shovel", {
			description = basename.." Shovel",
			inventory_image = def.shovel[1],
			wield_image = def.shovel[1].."^[transformR90",
			tool_capabilities = def.shovel[2],
		})

		minetest.register_craft({
			output = "tools:"..basestack.."_shovel",
			recipe = {
				{"", def.material, ""},
				{"", "trees:stick", ""},
				{"", "trees:stick", ""},
			},
		})
	end

	if def.spade then
		minetest.register_tool("tools:"..basestack.."_spade", {
			description = basename.." Spade",
			inventory_image = def.spade[1],
			wield_image = def.spade[1].."^[transformR90",
			tool_capabilities = def.spade[2],
		})

		minetest.register_craft({
			output = "tools:"..basestack.."_spade",
			recipe = {
				{"", def.material, ""},
				{"", "trees:stick", ""},
			},
		})
	end

	if def.hoe then
		minetest.register_tool("tools:"..basestack.."_hoe", {
			description = basename.." Hoe",
			inventory_image = def.hoe[1],
			tool_capabilities = def.hoe[2],
		})

		minetest.register_craft({
			output = "tools:"..basestack.."_hoe",
			recipe = {
				{def.material, def.material, ""},
				{"", "trees:stick", ""},
				{"", "trees:stick", ""},
			},
		})

		minetest.register_craft({
			output = "tools:"..basestack.."_",
			recipe = {
				{"", def.material, def.material},
				{"", "trees:stick", ""},
				{"", "trees:stick", ""},
			},
		})
	end

	if def.sword then
		minetest.register_tool("tools:"..basestack.."_sword", {
			description = basename.." Sword",
			inventory_image = def.sword[1],
			tool_capabilities = def.sword[2],
		})

		minetest.register_craft({
			output = "tools:"..basestack.."_sword",
			recipe = {
				{def.material},
				{def.material},
				{"trees:stick"},
			}
		})
	end

	if def.knife then
		minetest.register_tool("tools:"..basestack.."_knife", {
			description = basename.." Knife",
			inventory_image = def.knife[1],
			tool_capabilities = def.knife[2],
		})

		minetest.register_craft({
			output = "tools:"..basestack.."_knife",
			recipe = {
				{def.material},
				{"trees:stick"},
			}
		})
	end
end

---
--- Load Registrations
---

dofile(minetest.get_modpath("tools").."/tools.lua")
