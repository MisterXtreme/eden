-- players/sprint.lua

local sprinting       = {}
local secondary       = {}
local SPEED           = minetest.settings:get("sprint_speed")        or 1.5
local PRIMARY         = minetest.settings:get("sprint_primary")      or "aux1"
local SECOND          = minetest.settings:get("sprint_second")       or "up"
local PARTICLE_NUM    = minetest.settings:get("sprint_particle_num") or 1
local ALLOW_SEC       = minetest.settings:get("sprint_enable_second")
local ALLOW_PARTICLES = minetest.settings:get("sprint_particles")

---
--- Functions
---

local function start_sprint(player, name, trigger)
	player:set_physics_override({speed = SPEED})
	sprinting[name] = {is = true, trigger = trigger}
end

local function stop_sprint(player, name)
	player:set_physics_override({speed = 1})
	sprinting[name] = {is = false}
end

---
--- Registrations
---

minetest.register_globalstep(function(dtime)
	for _, player in pairs(minetest.get_connected_players()) do
		local name = player:get_player_name()
		local ctrl = player:get_player_control()

		if not sprinting[name] then
			sprinting[name] = {is = false}
		end

		local spr  = sprinting[name]

		-- Primary Key
		if ctrl[PRIMARY] and ctrl.up and not spr.is then
			start_sprint(player, name, "primary")
		elseif ((not ctrl[PRIMARY] and spr.is) or
		 		(ctrl[PRIMARY] and not ctrl.up and spr.is))
						and spr.trigger == "primary" then
			stop_sprint(player, name)
		end

		-- Secondary Key
		if ALLOW_SEC ~= "false" and SECOND and SECOND ~= "" and spr.trigger ~= "primary" then
			if not secondary[name] then
				secondary[name] = {count = 0, time = 0, last = false}
			end

			if ctrl[SECOND] ~= secondary[name].last then
				if secondary[name].time > 0.3 and not spr.is and
				 		secondary[name].count > 0 and secondary[name].count < 3 then
					secondary[name] = {count = 0, time = 0, last = false}
					return
				end

				if secondary[name].count < 3 and ctrl[SECOND] ~= secondary[name].last then
					secondary[name].count = secondary[name].count + 1
					secondary[name].last  = ctrl[SECOND]
				end

				if (secondary[name].count == 3 and ctrl[SECOND]) and ctrl.up and not spr.is then
					start_sprint(player, name, "secondary")
				elseif ((secondary[name].count > 3 or not ctrl[SECOND]) or not ctrl.up) and
						spr.is then
					stop_sprint(player, name)
					secondary[name] = {count = 0, time = 0, last = false}
				end
			end

			if not spr.is and secondary[name].count ~= 0 then
				secondary[name].time = secondary[name].time + dtime
			end
		end

		-- Particles
		if ALLOW_PARTICLES ~= "false" and spr.is then
			local pos = player:get_pos()
			pos.y = pos.y - 1

			local node = minetest.get_node_or_nil(pos)
			if node and node.name ~= "air" and node.name ~= "ignore" then
				local def = minetest.registered_nodes[node.name]
				local tile = def.tiles[1] or def.inventory_image or ""
				if type(tile) == "string" and PARTICLE_NUM ~= 0 then
					minetest.add_particlespawner({
						time = 0.5,
						amount = PARTICLE_NUM,
						minpos = {x = pos.x - 0.5, y = pos.y + 1.1, z = pos.z - 0.5},
						maxpos = {x = pos.x + 0.5, y = pos.y + 1.1, z = pos.z + 0.5},
						minvel = {x = 0, y = 3, z = 0},
						maxvel = {x = 0, y = 5, z = 0},
						minacc = {x = 0, y = -10, z = 0},
						maxacc = {x = 0, y = -13, z = 0},
						minexptime = 0.5,
						maxexptime = 1,
						minsize = 0.5,
						maxsize = 2,
						collisiondetection = true,
						vertical = false,
						texture = tile,
					})
				end
			end
		end
	end
end)
