-- flora/init.lua

flora = {}

---
--- API
---

-- [function] Register flora
function flora.register(name, def)
	def.node.is_ground_content = false

	minetest.register_node("flora:"..name, def.node)
	minetest.register_decoration(def.decoration)
end

---
--- Registrations
---

flora.register("cactus", {
	node = {
		description = "Cactus",
		tiles = {{name = "flora_cactus.png", backface_culling = true}},
		drawtype = "mesh",
		paramtype = "light",
		mesh = "flora_cactus.b3d",
		groups = {choppy = 3, flammable = 2, oddly_breakable_by_hand = 1},

		selection_box = {
			type = "fixed",
			fixed = {-0.4375, -0.5, -0.4375, 0.4375, 0.5, 0.4375},
		},
		collision_box = {
			type = "fixed",
			fixed = {-0.4375, -0.5, -0.4375, 0.4375, 0.5, 0.4375},
		},
	},
	decoration = {
		deco_type = "simple",
		place_on = "soil:sand",
		decoration = {"flora:cactus"},
		sidelen = 8,
		fill_ratio = 0.004,
		height = 3,
		y_max = 4,
	},
})
