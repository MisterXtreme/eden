-- soil/init.lua

soil = {}

---
--- API
---

-- [function] Register soil
function soil.register(name, def)
	if not def.groups then def.groups = {} end
	def.groups.crumbly = def.groups.crumbly or 3
	def.groups.soil = def.groups.soil or 1
	def.is_ground_content = true
	def.drop = def.drop or "soil:"..name

	minetest.register_node("soil:"..name, def)
end

---
--- Registrations
---

-- [soil] Dirt
soil.register("dirt", {
	description = "Dirt",
	tiles ={"soil_dirt.png"},
})

-- [soil] Dirt with grass
soil.register("dirt_with_grass", {
	description = "Dirt with grass",
	tiles ={"soil_grass.png", "soil_dirt.png",
		{name = "soil_dirt.png^soil_grass_side.png",
		tileable_vertical = false}},
	groups = {crumbly=3, soil=1},
	drop = "soil:dirt",
})

-- [soil] Sand
soil.register("sand", {
	description = "Sand",
	tiles = {"soil_sand.png"},
	groups = {soil=0, sand=1, falling_node=1},
})
