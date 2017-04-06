-- eden/nodes.lua

WATER_ALPHA = 160
WATER_VISC = 1
LAVA_VISC = 7
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

-- [register] Dirt
minetest.register_node("eden:dirt", {
	description = "Dirt",
	tiles ={"eden_dirt.png"},
	groups = {crumbly=3, soil=1},
})

-- [register] Dirt with grass
minetest.register_node("eden:dirt_with_grass", {
	description = "Dirt with grass",
	tiles ={"eden_grass.png", "eden_dirt.png",
		{name = "eden_dirt.png^eden_grass_side.png",
		tileable_vertical = false}},
	groups = {crumbly=3, soil=1},
	drop = "eden:dirt",
})

-- [register] Sand
minetest.register_node("eden:sand", {
	description = "Sand",
	tiles ={"eden_sand.png"},
	groups = {crumbly=3, falling_node=1},
})
