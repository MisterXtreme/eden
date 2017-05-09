minetest.register_tool("tools:axe_diamond", {
	description = "Diamond Axe",
	inventory_image = "tools_diamond_axe.png",
	tool_capabilities = {
		full_punch_interval = 0.9,
		max_drop_level=1,
		groupcaps={
			choppy={times={[1]=2.10, [2]=0.90, [3]=0.50}, uses=30, maxlevel=2},
		},
		damage_groups = {fleshy=7},
	},
	--sound = {breaks = "default_tool_breaks"},
})

minetest.register_tool("tools:axe_wood", {
	description = "Wood Axe",
	inventory_image = "tools_wood_axe.png",
	tool_capabilities = {
		full_punch_interval = 0.9,
		max_drop_level=1,
		groupcaps={
			choppy={times={[1]=2.10, [2]=0.90, [3]=0.50}, uses=30, maxlevel=2},
		},
		damage_groups = {fleshy=7},
	},
	--sound = {breaks = "default_tool_breaks"},
})

minetest.register_craft({
	output = "tools:axe_wood",
	recipe = {
		{"wood_like:oak_plank", "wood_like:oak_plank", ""},
		{"wood_like:oak_plank", "wood_like:stick", ""},
		{"", "wood_like:stick",  ""}
	}
})
