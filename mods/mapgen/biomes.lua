-- mapgen/biomes.lua

minetest.clear_registered_biomes()
minetest.clear_registered_decorations()

---
--- Register Biomes
---

minetest.register_biome({
	name = "eden:grassland",
	node_top = "soil:dirt_with_grass",
	depth_top = 1,
	node_filler = "soil:dirt",
	depth_filler = 1,
	y_min = 5,
	y_max = 31000,
	heat_point = 50,
	humidity_point = 50,
})

minetest.register_biome({
	name = "eden:grassland_ocean",
	node_top = "soil:sand",
	depth_top = 1,
	node_filler = "soil:sand",
	depth_filler = 2,
	y_min = -31000,
	y_max = 4,
	heat_point = 50,
	humidity_point = 50,
})

minetest.register_biome({
	name = "eden:jungle",
	node_top = "soil:dirt_with_grass",
	depth_top = 1,
	depth_filler = "default:dirt",
	depth_filler = 3,
	node_riverbed = "soil:sand",
	depth_riverbed = 2,
	y_min = 1,
	y_max = 31000,
	heat_point = 86,
	humidity_point = 65,
})
