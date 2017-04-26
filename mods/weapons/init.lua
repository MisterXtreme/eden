-- [register Weapon] Iron Sword
minetest.register_tool("weapons:iron_sword", {
  description = "Iron Sword",
  inventory_image = "weapon_iron_sword.png",
  tool_capabilities = {
		full_punch_interval = 0.9,
		max_drop_level=3,
		groupcaps={
			choppy={times={[1]=2.00, [2]=0.80, [3]=0.40}, uses=300, maxlevel=4},
		},
		damage_groups = {fleshy=7},
	},
})
