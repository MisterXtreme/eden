-- mapgen/init.lua

local modpath = minetest.get_modpath("mapgen")

---
--- Aliases for map generator outputs
---

minetest.register_alias("mapgen_stone", "eden:stone")
minetest.register_alias("mapgen_dirt", "soil:dirt")
minetest.register_alias("mapgen_dirt_with_grass", "soil:dirt_with_grass")
minetest.register_alias("mapgen_sand", "soil:sand")
minetest.register_alias("mapgen_cobble", "eden:cobble")

---
--- Load Required Resources
---

dofile(modpath.."/biomes.lua")

---
--- Load Optional Resources
---

if minetest.settings:get("mapgen_rotate_textures") == "true" then
	dofile(modpath.."/rotate.lua")
end
