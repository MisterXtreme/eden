-- trees/trees.lua

---
--- Tree Registrations
---

-- Oak
trees.register("oak", {
	basename = "Oak",
	center = "trees_oak_log.png",
	sides = "trees_oak_log_sides.png",
	plank = "trees_oak_plank.png",
	sapling = "trees_oak_sapling.png",
	leaf = "trees_oak_leaf.png",
	offset = { x = -3, y = -1, z = -3},
	schematic = "oak_tree.mts",
	mapgen = {
		place_on = {"soil:dirt_with_grass"},
		fill_ratio = 0.01,
		biomes = {"eden:grassland"},
		y_min = 1,
		y_max = 200,
	},
})

-- Lupuna
trees.register("lupuna", {
	basename = "Lupuna",
	center = "trees_lupuna_log.png",
	sides = "trees_lupuna_log_sides.png",
	plank = "trees_lupuna_planks.png",
	sapling = "trees_lupuna_sapling.png",
	leaf = "trees_lupuna_leaf.png",
	offset = { x = -6, y = 0, z = -6},
	schematic = "lupuna_tree.mts",
	mapgen = {
		place_on = {"soil:dirt_with_grass"},
		fill_ratio = 0.01,
		biomes = {"eden:jungle"},
		y_min = 1,
		y_max = 200,
	},
})
