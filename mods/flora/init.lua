-- flora/init.lua

flora = {}

---
--- API
---

-- [local function] Get connected nodes
local function get_connected_nodes(pos, nodenames, iterator)
	local ret = {}
	local nodes = {
		{x=pos.x + 1, y=pos.y,     z=pos.z},
		{x=pos.x - 1, y=pos.y,     z=pos.z},
		{x=pos.x,     y=pos.y + 1, z=pos.z},
		{x=pos.x,     y=pos.y - 1, z=pos.z},
		{x=pos.x,     y=pos.y,     z=pos.z + 1},
		{x=pos.x,     y=pos.y,     z=pos.z - 1},
	}

	for _, p in pairs(nodes) do
		local node = minetest.get_node_or_nil(p)

		if node then
			for _, n in pairs(nodenames) do
				if n == node.name then
					ret[#ret + 1] = p

					if iterator and type(iterator) == "function" then
						iterator(p)
					end
				end
			end
		end
	end

	return ret
end

-- [function] Register flora
function flora.register(name, def)
	def.node.is_ground_content = false

	if def.real_physics then
		local after_dig = def.node.after_dig_node
		def.node.after_dig_node = function(pos, node, meta, digger)
			if after_dig then
				after_dig(pos, node, meta, digger)
			end

			if digger then
				get_connected_nodes(pos, {"flora:"..name}, function(pos)
					local node = minetest.get_node_or_nil(pos)
					local node_under = minetest.get_node_or_nil({
						x = pos.x, y = pos.y - 1, z = pos.z
					})

					if node and node_under and node_under.name == "air" then
						minetest.node_dig(pos, node, digger)
					end
				end)
			end
		end
	end

	minetest.register_node("flora:"..name, def.node)
	minetest.register_decoration(def.decoration)
end

---
--- Registrations
---

flora.register("cactus", {
	real_physics = true,
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
