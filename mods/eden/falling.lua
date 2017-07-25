-- eden/falling.lua

minetest.register_entity(":__builtin:falling_node", {
	initial_properties = {
		visual = "wielditem",
		visual_size = {x = 0.667, y = 0.667},
		textures = {},
		physical = true,
		is_visible = false,
		collide_with_objects = false,
		collisionbox = {-0.5, -0.5, -0.5, 0.5, 0.5, 0.5},
	},

	node = {},
	meta = {},

	set_node = function(self, node, meta)
		self.node = node
		self.meta = meta or {}
		self.object:set_properties({
			is_visible = true,
			textures = {node.name},
		})
	end,

	get_staticdata = function(self)
		local ds = {
			node = self.node,
			meta = self.meta,
		}
		return minetest.serialize(ds)
	end,

	on_activate = function(self, staticdata)
		self.object:set_armor_groups({immortal = 1})

		local ds = minetest.deserialize(staticdata)
		if ds and ds.node then
			self:set_node(ds.node, ds.meta)
		elseif ds then
			self:set_node(ds)
		elseif staticdata ~= "" then
			self:set_node({name = staticdata})
		end
	end,

	on_step = function(self, dtime)
		-- Check falling node existence
		if not minetest.registered_nodes[self.node.name] then
			self.object:remove()
			return
		end

		-- Set gravity
		local acceleration = self.object:getacceleration()
		if not vector.equals(acceleration, {x = 0, y = -10, z = 0}) then
			self.object:set_acceleration({x = 0, y = -10, z = 0})
		end
		-- Turn to actual node when colliding with ground, or continue to move
		local pos = self.object:get_pos()
		-- Position of bottom center point
		local bcp = {x = pos.x, y = pos.y - 0.7, z = pos.z}
		-- Avoid bugs caused by an unloaded node below
		local bcn = minetest.get_node_or_nil(bcp)
		local bcd = bcn and minetest.registered_nodes[bcn.name]
		if bcn and (not bcd or bcd.walkable or
				(minetest.get_item_group(self.node.name, "float") ~= 0 and
				bcd.liquidtype ~= "none")) then
			if bcd and bcd.leveled and bcn.name == self.node.name then
				local addlevel = self.node.level
				if not addlevel or addlevel <= 0 then
					addlevel = bcd.leveled
				end
				if minetest.add_node_level(bcp, addlevel) == 0 then
					self.object:remove()
					return
				end
			elseif bcd and bcd.buildable_to and
					(minetest.get_item_group(self.node.name, "float") == 0 or
					bcd.liquidtype == "none") then
				minetest.remove_node(bcp)
				return
			end
			local np = {x = bcp.x, y = bcp.y + 1, z = bcp.z}
			-- Check what's here
			local n2 = minetest.get_node(np)
			local nd = minetest.registered_nodes[n2.name]
			-- If it's not air or liquid, drop falling node
			if n2.name ~= "air" and (not nd or nd.liquidtype == "none") then
				local def = minetest.registered_nodes[self.node.name]
				-- Add dropped items
				local drops = minetest.get_node_drops(self.node.name, "")
				for _, dropped_item in pairs(drops) do
					minetest.add_item(np, dropped_item)
				end
				self.object:remove()
				return
			else
				-- Create node and remove entity
				minetest.add_node(np, self.node)
				if self.meta then
					local meta = minetest.get_meta(np)
					meta:from_table(self.meta)
				end
				self.object:remove()
				minetest.check_for_falling(np)
				return
			end
		end
		local vel = self.object:get_velocity()
		if vector.equals(vel, {x = 0, y = 0, z = 0}) then
			local npos = self.object:get_pos()
			self.object:setpos(vector.round(npos))
		end
	end,
})

---
--- Function Redefinitions
---

local function check_attached_node(p, n)
	local def = minetest.registered_nodes[n.name]
	local d = {x = 0, y = 0, z = 0}
	if def.paramtype2 == "wallmounted" or
			def.paramtype2 == "colorwallmounted" then
		-- The fallback vector here is in case 'wallmounted to dir' is nil due
		-- to voxelmanip placing a wallmounted node without resetting a
		-- pre-existing param2 value that is out-of-range for wallmounted.
		-- The fallback vector corresponds to param2 = 0.
		d = minetest.wallmounted_to_dir(n.param2) or {x = 0, y = 1, z = 0}
	else
		d.y = -1
	end
	local p2 = vector.add(p, d)
	local nn = minetest.get_node(p2).name
	local def2 = minetest.registered_nodes[nn]
	if def2 and not def2.walkable then
		return false
	end
	return true
end

local function spawn_falling_node(p, node, meta)
	local obj = minetest.add_entity(p, "__builtin:falling_node")
	if obj then
		obj:get_luaentity():set_node(node, meta)
	end
end

local function drop_attached_node(p)
	local n = minetest.get_node(p)
	minetest.remove_node(p)
	for _, item in pairs(minetest.get_node_drops(n, "")) do
		local pos = {
			x = p.x + math.random() / 2 - 0.25,
			y = p.y + math.random() / 2 - 0.25,
			z = p.z + math.random() / 2 - 0.25,
		}
		minetest.add_item(pos, item)
	end

	local def = minetest.registered_nodes[n.name]
	if def and def.on_destruct then
		def.on_destruct(p)
	end
end

-- [function] Check single position for falling node
function minetest.check_single_for_falling(p)
	local n = minetest.get_node(p)
	if minetest.get_item_group(n.name, "falling_node") ~= 0 then
		local p_bottom = {x = p.x, y = p.y - 1, z = p.z}
		-- Only spawn falling node if node below is loaded
		local n_bottom = minetest.get_node_or_nil(p_bottom)
		local d_bottom = n_bottom and minetest.registered_nodes[n_bottom.name]
		if d_bottom and

				(minetest.get_item_group(n.name, "float") == 0 or
				d_bottom.liquidtype == "none") and

				(n.name ~= n_bottom.name or (d_bottom.leveled and
				minetest.get_node_level(p_bottom) <
				minetest.get_node_max_level(p_bottom))) and

				(not d_bottom.walkable or d_bottom.buildable_to) then
			n.level = minetest.get_node_level(p)
			local meta = minetest.get_meta(p)
			local metatable = {}
			if meta ~= nil then
				metatable = meta:to_table()
			end
			minetest.remove_node(p)
			spawn_falling_node(p, n, metatable)
			return true
		end
	end

	if minetest.get_item_group(n.name, "attached_node") ~= 0 then
		if not check_attached_node(p, n) then
			drop_attached_node(p)
			return true
		end
	end

	return false
end
