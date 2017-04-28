minetest.register_tool("tools:pick_diamond", {
	description = "Diamond Pickaxe",
	inventory_image = "tools_diamond_pick.png",
	tool_capabilities = {
		full_punch_interval = 0.9,
		max_drop_level=3,
		groupcaps={
			cracky = {times={[1]=2.0, [2]=1.0, [3]=0.50}, uses=30, maxlevel=3},
		},
		damage_groups = {fleshy=5},
	},
	--sound = {breaks = "default_tool_breaks"},
})
