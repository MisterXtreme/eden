-- eden/nodes.lua

LIGHT_MAX = 14

-- [register] Stone
minetest.register_node("eden:stone", {
	description = "Stone",
	tiles ={"eden_stone.png"},
	groups = {cracky=3},
	drop = "eden:cobble",
	legacy_mineral = true,
})

-- [register] Cobble
minetest.register_node("eden:cobble", {
	description = "Cobble",
	tiles ={"eden_cobble.png"},
	is_ground_content = false,
	groups = {cracky=3},
})
