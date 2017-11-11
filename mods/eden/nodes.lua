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
minetest.register_craftitem("eden:flint", {
    description = "Flint",
    inventory_image = "eden_flint.png"
})
minetest.register_craftitem("eden:rock", {
    description = "Rock",
    inventory_image = "eden_rock.png"
})
-- [Register] Gravel
minetest.register_node("eden:gravel", {
	description = "Gravel",
	tiles = {"eden_gravel.png"},
	groups = {crumbly = 2, falling_node = 1},
	drop = {
		max_items = 1,
		items = {
			{items = {'eden:flint'}, rarity = 16},
			{items = {'eden:rock'}, rarity = 16},
			{items = {'eden:gravel'}, rarity = 1}
		}
	}
})
