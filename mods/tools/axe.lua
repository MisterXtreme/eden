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
