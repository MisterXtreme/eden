-- eden/item_entity.lua

-- If item_entity_ttl is not set, enity will have default life time
-- Setting it to -1 disables the feature
local time_to_live = tonumber(minetest.settings:get("item_entity_ttl"))
if not time_to_live then
	time_to_live = 900
end

---
--- Water flow functions by QwertyMine3 (MIT)
--- Edited by TenPlus1, Rewritten by octacian
---

local function to_unit_vector(dir_vector)
	local inv_roots = {
		[0] = 1,
		[1] = 1,
		[2] = 0.70710678118655,
		[4] = 0.5,
		[5] = 0.44721359549996,
		[8] = 0.35355339059327
	}

	local sum = dir_vector.x * dir_vector.x + dir_vector.z * dir_vector.z
	return {
		x = dir_vector.x * inv_roots[sum],
		y = dir_vector.y,
		z = dir_vector.z * inv_roots[sum]
	}
end

local function node_ok(pos)
	local node = minetest.get_node_or_nil(pos)
	if minetest.registered_nodes[node.name] then
		return node
	end
end

local function is_liquid(node)
	local def = minetest.registered_nodes[node.name]
	if def.liquidtype == "flowing" or def.liquidtype == "source" then
		return true
	end
end

local function quick_flow_logic(node, pos_testing, direction)
	local def = minetest.registered_nodes[node.name]
	if def.liquidtype == "flowing" then
		local node_testing = node_ok(pos_testing)
		if not is_liquid(node_testing) then
			return 0
		end

		local param2_testing = node_testing.param2
		if param2_testing < node.param2 then
			if (node.param2 - param2_testing) > 6 then
				return -direction
			else
				return direction
			end
		elseif param2_testing > node.param2 then
			if (param2_testing - node.param2) > 6 then
				return direction
			else
				return -direction
			end
		end
	end

	return 0
end

local function quick_flow(pos, node)
	local x, z = 0, 0
	if not minetest.registered_nodes[node.name].groups.liquid then
		return {x = 0, y = 0, z = 0}
	end

	x = x + quick_flow_logic(node, {x = pos.x - 1, y = pos.y, z = pos.z},-1)
	x = x + quick_flow_logic(node, {x = pos.x + 1, y = pos.y, z = pos.z}, 1)
	z = z + quick_flow_logic(node, {x = pos.x, y = pos.y, z = pos.z - 1},-1)
	z = z + quick_flow_logic(node, {x = pos.x, y = pos.y, z = pos.z + 1}, 1)

	return to_unit_vector({x = x, y = 0, z = z})
end

---
--- END Water Flow
---

local builtin_item = minetest.registered_entities["__builtin:item"]

local item = {
	initial_properties = {
		hp_max = 1,
		physical = true,
		collide_with_objects = false,
		collisionbox = {-0.3, -0.3, -0.3, 0.3, 0.3, 0.3},
		visual = "wielditem",
		visual_size = {x = 0.4, y = 0.4},
		textures = {""},
		spritediv = {x = 1, y = 1},
		initial_sprite_basepos = {x = 0, y = 0},
		is_visible = false,
	},

	on_punch = function() end,

	set_item = function(self, itemstring)
		self.itemstring = itemstring
		local stack = ItemStack(itemstring)
		local count = stack:get_count()
		local max_count = stack:get_stack_max()
		if count > max_count then
			count = max_count
			self.itemstring = stack:get_name().." "..max_count
		end
		local s = 0.2 + 0.1 * (count / max_count)
		local c = s - 0.05
		local itemtable = stack:to_table()
		local itemname = nil
		if itemtable then
			itemname = stack:to_table().name
		end
		self.object:set_properties({
			is_visible = true,
			visual = "wielditem",
			textures = {itemname},
			visual_size = {x = s, y = s},
			collisionbox = {-c, -c, -c, c, c, c},
			wield_item = itemstring,
		})

		local itemdef = minetest.registered_items[stack:get_name()]
		if itemdef and itemdef.groups.flammable ~= 0 then
			self.flammable = itemdef.groups.flammable
		end

		--[[ NOTE: This has not yet been implemented in Minetest engine
		if itemdef and itemdef.type == "tool" or itemdef.type == "craft" then
			self.object:set_pitch(90)
		end
		]]--

		-- Set ID
		self.id = string.format("%04x%04x%04x%04x",
				math.random(2^16) - 1, math.random(2^16) - 1,
				math.random(2^16) - 1, math.random(2^16) - 1)
	end,

	burn_up = function(self)
		self.object:remove()
		local p = self.object:getpos()
		minetest.sound_play("eden_item_burn", {
			pos = p,
			max_hear_distance = 8,
			gain = math.random(0.5, 2)
		})
		minetest.add_particlespawner({
			amount = 3,
			time = 0.1,
			minpos = {x = p.x - 0.1, y = p.y + 0.1, z = p.z - 0.1 },
			maxpos = {x = p.x + 0.1, y = p.y + 0.2, z = p.z + 0.1 },
			minvel = {x = 0, y = 2.5, z = 0},
			maxvel = {x = 0, y = 2.5, z = 0},
			minacc = {x = -0.15, y = -0.02, z = -0.15},
			maxacc = {x = 0.15, y = -0.01, z = 0.15},
			minexptime = 4,
			maxexptime = 6,
			minsize = 5,
			maxsize = 5,
			collisiondetection = true,
			texture = "eden_item_smoke.png"
		})
	end,

	on_step = function(self, dtime)
		local object     = self.object
		local itemstring = self.itemstring
		local pos        = object:getpos()
		local node       = minetest.get_node_or_nil(pos)

		if not itemstring or itemstring == "" then
			object:remove()
			return
		end

		self.age = self.age + dtime
		if time_to_live > 0 and self.age > time_to_live then
			self.object:remove()
			return
		end
		local p = vector.new(pos)
		p.y = p.y - 0.5
		local tnode = minetest.get_node_or_nil(p)
		local nn = tnode.name
		-- If node is not registered or node is walkably solid and resting on nodebox
		local v = object:get_velocity()
		if not minetest.registered_nodes[nn] or minetest.registered_nodes[nn].walkable and v.y == 0 then
			local own_stack = ItemStack(self.itemstring)
			-- Merge with close entities of the same item
			for _, object in ipairs(minetest.get_objects_inside_radius(p, 0.8)) do
				local obj = object:get_luaentity()
				if obj and obj.name == "__builtin:item"
						 and self.id ~= obj.id then
					if self:try_merge_with(own_stack, object, obj) then
						return
					end
				end
			end
			object:set_velocity({x = 0, y = 0, z = 0})
			object:set_acceleration({x = 0, y = 0, z = 0})
		else
			if v.y == 0 then
				object:set_velocity({x = 0, y = 0, z = 0})
				object:set_acceleration({x = 0, y = -10, z = 0})
			end
		end

		-- Environment-based interactions
		if node and node.name ~= "air" then
			local def = minetest.registered_nodes[node.name]

			-- Burning
			if minetest.get_item_group(node.name, "lava") > 0 then
				if self.flammable then
					self:burn_up()
					return
				else -- else, Ignite after a maximum of 10 seconds
					self.ignite_timer = (self.ignite_timer or 0) + dtime

					if self.ignite_timer > math.random(2, 10) then
						self.ignite_timer = 0
						self:burn_up()
						return
					end
				end
			elseif self.flammable then
				-- Otherwise there'll be a chance based on its igniter value
				local burn_chance = self.flammable
					* minetest.get_item_group(node.name, "igniter")
				if burn_chance > 0 and math.random(0, burn_chance) ~= 0 then
					self:burn_up()
					return
				end
			end

			-- Move in flowing liquids
			if def.liquidtype == "flowing" then
				local vec = quick_flow(pos, node)
				if vec then
					object:set_velocity(vec)
					self.flowing = true
				end
			end

			-- Droplift
			if def.liquidtype == "none" and def.drawtype == "normal" then
				local new_pos = minetest.find_node_near(object:get_pos(), 1,  "air")
				if new_pos then
					object:move_to(new_pos)
				else
					object:remove()
					return
				end
			end
		end

		-- Stop water flow
		if self.flowing and node then
			local def = minetest.registered_nodes[node.name]
			if def.liquidtype ~= "flowing" then
				local def = minetest.registered_nodes[node.name]
				object:setvelocity({x = 0, y = 0, z = 0})
				object:move_to(vector.round(pos))
				self.flowing = false
			end
		end

		-- Collection
		if self.age > 1 then
			local radius_magnet   = 2 -- Magnet radius (minimum: 1.7)
			local radius_collect  = 0.2 -- Collection radius
			local liquid_modifier = 2

			for _, player in ipairs(minetest.get_objects_inside_radius(pos, radius_magnet)) do
				if player:is_player() then
					if not gamemode.can_interact(player) then
						return
					end

					local inv  = player:get_inventory()
					if inv and inv:room_for_item("main", ItemStack(itemstring)) then
						local ppos = player:getpos()
						ppos.y = ppos.y + 1.3

						if node then
							local def = minetest.registered_nodes[node.name]
							if def.liquidtype == "flowing" or def.liquidtype == "source" then
								radius_magnet = radius_magnet / liquid_modifier
								radius_collect = radius_collect / liquid_modifier
							end
						end

						if vector.distance(pos, ppos) <= radius_collect then
							inv:add_item("main", ItemStack(itemstring))
							minetest.sound_play("eden_item_pickup", {
								pos = ppos,
								max_hear_distance = 8,
							})
							object:remove()
						elseif math.floor(vector.distance(pos, ppos)) <= radius_magnet then
							local ok, blocker = minetest.line_of_sight(ppos, pos)
							if not ok and blocker then
								local node = minetest.get_node_or_nil(blocker)
								if node and node.name then
									local def = minetest.registered_nodes[node.name]
									if (def.walkable ~= nil and def.walkable == false) or
											(def.sunlight_propagates) or (def.drawtype == "nodebox") then
										ok = true
									end
								end
							end

							if ok then
								local vec = vector.subtract(ppos, pos)
								vec = vector.add(pos, vector.divide(vec, 2))
								object:moveto(vec)
							end
						end
					end
				end
			end
		end
	end,
}

function minetest.handle_node_drops(pos, drops, digger)
	if not digger or not digger:is_player() then
		return
	end

	if not gamemode.can_interact(digger) then
		return
	end

	local inv  = digger:get_inventory()
	local mode = gamemode.def(gamemode.get(digger))

	for _, item in ipairs(drops) do
		local count, name
		if type(item) == "string" then
			count = 1
			name = item
		else
			count = item:get_count()
			name = item:get_name()
		end

		if mode.item_drops == "auto" then
			item = ItemStack(item):get_name()
			if not inv:contains_item("main", item) then
				inv:add_item("main", item)
			end
		else
			for i=1, count do
				if ItemStack(name):is_known() then
					local obj = minetest.add_item(pos, name)
					if obj then
						obj:get_luaentity().age = 0.5
					end
				end
			end
		end
	end
end

function minetest.item_drop(itemstack, player, pos)
	-- Use modified item drop only if dropped by a player
	if player and player:is_player() then
		if not gamemode.can_interact(player) then
			return
		end

		local v = player:get_look_dir()
		local vel = player:get_player_velocity()
		local cs = itemstack:get_count()
		pos.y = pos.y + 1.3

		if player:get_player_control().sneak then
			cs = 1
		end
		local item = itemstack:take_item(cs)
		local obj  = minetest.add_item(pos, item)
		if obj then
			v.x = (v.x*5)+vel.x
			v.y = ((v.y*5)+2)+vel.y
			v.z = (v.z*5)+vel.z
			obj:setvelocity(v)
			obj:get_luaentity().dropped_by = player:get_player_name()
			obj:set_yaw(player:get_look_horizontal())

			return itemstack
		end
	else -- else, Machine - use default item drop
		if minetest.add_item(pos, itemstack) then
			return itemstack
		end
	end
end

-- set defined item as new __builtin:item, with the old one as fallback table
setmetatable(item, builtin_item)
minetest.register_entity(":__builtin:item", item)
