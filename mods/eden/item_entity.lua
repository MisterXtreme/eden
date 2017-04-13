-- eden/item_entity.lua

local builtin_item = minetest.registered_entities["__builtin:item"]

local item = {
	on_punch = function() end,

	set_item = function(self, itemstring)
		builtin_item.set_item(self, itemstring)

		local stack = ItemStack(itemstring)
		local itemdef = minetest.registered_items[stack:get_name()]
		if itemdef and itemdef.groups.flammable ~= 0 then
			self.flammable = itemdef.groups.flammable
		end
	end,

	burn_up = function(self)
		-- disappear in a smoke puff
		self.object:remove()
		local p = self.object:getpos()
		minetest.sound_play("default_item_smoke", {
			pos = p,
			max_hear_distance = 8,
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
			texture = "default_item_smoke.png"
		})
	end,

	on_step = function(self, dtime)
		builtin_item.on_step(self, dtime)

		local object     = self.object
		local lentity    = object:get_luaentity()
		local itemstring = lentity.itemstring

		-- Burning
		if self.flammable then
			-- flammable, check for igniters
			self.ignite_timer = (self.ignite_timer or 0) + dtime
			if self.ignite_timer > 10 then
				self.ignite_timer = 0

				local node = minetest.get_node_or_nil(self.object:getpos())
				if not node then
					return
				end

				-- Immediately burn up flammable items in lava
				if minetest.get_item_group(node.name, "lava") > 0 then
					self:burn_up()
				else
					--  otherwise there'll be a chance based on its igniter value
					local burn_chance = self.flammable
						* minetest.get_item_group(node.name, "igniter")
					if burn_chance > 0 and math.random(0, burn_chance) ~= 0 then
						self:burn_up()
					end
				end
			end
		end

		-- Pickup
		if not lentity.age then
			lentity.age = 0
		else
			if lentity.age > 2 then
				for _, player in ipairs(minetest.get_objects_inside_radius(object:getpos(), 1)) do
					if player:is_player() then
						local inv = player:get_inventory()

						if inv and inv:room_for_item("main", ItemStack(itemstring)) then
							inv:add_item("main", ItemStack(itemstring))
							if itemstring ~= "" then
								minetest.sound_play("eden_item_pickup", {
									to_player = player:get_player_name(),
									gain = 0.4,
								})
							end
							object:remove()
						end
					end
				end
			else
				lentity.age = lentity.age + dtime
			end
		end
	end,
}

function minetest.handle_node_drops(pos, drops, digger)
	if not digger or not digger:is_player() then
		return
	end

	local inv  = digger:get_inventory()
	local mode = eden.get_gamemode_def(eden.get_gamemode(digger))

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
			for i=1,count do
				minetest.add_item(pos, name)
			end
		end
	end
end

-- set defined item as new __builtin:item, with the old one as fallback table
setmetatable(item, builtin_item)
minetest.register_entity(":__builtin:item", item)
