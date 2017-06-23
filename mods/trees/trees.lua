-- trees/trees.lua

---
--- Tree Registrations
---

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
