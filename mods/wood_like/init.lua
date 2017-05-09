minetest.register_node("wood_like:oak_plank", {
	description = "Oak Planks",
	tiles = {"wood_like_oak_planks.png"},
	groups = {oddly_breakable_by_hand=1}, {choppy=2}
})

minetest.register_craft({
	type = "shapeless",
	output = "wood_like:oak_plank 4",
	recipe = {"trees:oak_large"}
})


minetest.register_craftitem("wood_like:stick", {
	description = "Stick",
	inventory_image = "wood_like_stick.png"
})

minetest.register_craft({
	type = "shapeless",
	output = "wood_like:stick 4",
	recipe = {"wood_like:oak_plank", "wood_like:oak_plank"}
})
