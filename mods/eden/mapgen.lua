-- eden/mapgen.lua

--
-- Aliases for map generator outputs
--


minetest.register_alias("mapgen_stone", "eden:stone")
minetest.register_alias("mapgen_dirt", "eden:dirt")
minetest.register_alias("mapgen_dirt_with_grass", "eden:dirt_with_grass")
minetest.register_alias("mapgen_sand", "eden:sand")
minetest.register_alias("mapgen_water_source", "eden:water_source")
minetest.register_alias("mapgen_river_water_source", "eden:river_water_source")
minetest.register_alias("mapgen_lava_source", "eden:lava_source")
minetest.register_alias("mapgen_cobble", "eden:cobble")


--
-- Register biomes for biome API
--


minetest.clear_registered_biomes()
minetest.clear_registered_decorations()

minetest.register_biome({
	name = "eden:grassland",
	--node_dust = "",
	node_top = "eden:dirt_with_grass",
	depth_top = 1,
	node_filler = "eden:dirt",
	depth_filler = 1,
	--node_stone = "",
	--node_water_top = "",
	--depth_water_top = ,
	--node_water = "",
	y_min = 5,
	y_max = 31000,
	heat_point = 50,
	humidity_point = 50,
})

minetest.register_biome({
	name = "eden:grassland_ocean",
	--node_dust = "",
	node_top = "eden:sand",
	depth_top = 1,
	node_filler = "eden:sand",
	depth_filler = 2,
	--node_stone = "",
	--node_water_top = "",
	--depth_water_top = ,
	--node_water = "",
	y_min = -31000,
	y_max = 4,
	heat_point = 50,
	humidity_point = 50,
})
