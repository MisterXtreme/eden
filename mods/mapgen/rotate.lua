-- mapgen/rotate.lua

local rotate = {}

---
--- Rotate Textures
---

local nodes = {
	"soil:dirt",
	"soil:dirt_with_grass",
	"soil:sand",
}

-- Override nodes
for _, node_name in ipairs(nodes) do
	rotate[node_name] = true

	minetest.override_item(node_name, {
		paramtype2 = "facedir",
		after_place_node = function(pos)
			local facedir = math.random(0, 3)
			minetest.set_node(pos, {name = node_name, param2 = facedir})
		end
	})
end

-- Check on generated
minetest.register_on_generated(function(minp, maxp, seed)
	for z = minp.z, maxp.z, 1 do
		for x = minp.x, maxp.x, 1 do
			-- Find ground level (0...15)
			local ground_y
			for y = maxp.y, minp.y, -1 do
				local node = minetest.get_node_or_nil({x = x, y = y, z = z})
				if node and node.name ~= "air" and node.name ~= "ignore" then
					local is_leaf = minetest.registered_nodes[node.name].groups.leaf
					if not is_leaf or is_leaf == 0 then
						ground_y = y
						break
					end
				end
			end

			if not ground_y then break end

			local p = {x = x, y = ground_y, z = z}
			local n = minetest.get_node_or_nil(p)
			if n and rotate[n.name] then
				local facedir = math.random(0, 3)
				minetest.set_node(p, {name = n.name, param2 = facedir})
			end
		end
	end
end)
