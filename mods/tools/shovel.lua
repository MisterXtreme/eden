minetest.register_tool("tools:shovel_diamond", {
	description = "Diamond Shovel",
	inventory_image = "tools_diamond_shovel.png",
	wield_image = "tools_diamond_shovel.png^[transformR90",
	tool_capabilities = {
		full_punch_interval = 1.0,
		max_drop_level=1,
		groupcaps={
			crumbly = {times={[1]=1.10, [2]=0.50, [3]=0.30}, uses=30, maxlevel=3},
		},
		damage_groups = {fleshy=4},
	},
	--sound = {breaks = "default_tool_breaks"},
})
