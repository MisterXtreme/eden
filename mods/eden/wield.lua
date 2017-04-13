-- eden/wield.lua

-- Code adapted from https://github.com/stujones11/wield3d

--[[

Copyright (C) 2013 Stuart Jones
Copyright (C) 2017 Elijah Duffy

License: LGPL (relicensed)

--]]

---
--- API
---

local update_time = 0.3
local timer = 0
local player_wielding = {}
local location = {
	"Arm_Right",          -- default bone
	{x=0, y=5.5, z=3},    -- default position
	{x=-90, y=225, z=90}, -- default rotation
	{x=0.20, y=0.20},     -- default scale
}

-- [local function] Add wield entity
local function add_wield_entity(player)
	local name = player:get_player_name()
	local pos = player:getpos()
	if name and pos then
		pos.y = pos.y + 0.5
		local object = minetest.add_entity(pos, "eden:wield_entity")
		if object then
			object:set_attach(player, location[1], location[2], location[3])
			object:set_properties({
				textures = {"eden:wield_hand"},
				visual_size = location[4],
			})
			player_wielding[name] = {}
			player_wielding[name].item = ""
			player_wielding[name].object = object
			player_wielding[name].location = location
		end
	end
end

-- [register] Wield hand
minetest.register_item("eden:wield_hand", {
	type = "none",
	wield_image = "blank.png",
})

-- [register] Wield entity
minetest.register_entity("eden:wield_entity", {
	physical = false,
	collisionbox = {-0.125,-0.125,-0.125, 0.125,0.125,0.125},
	visual = "wielditem",
	on_activate = function(self, staticdata)
		if staticdata == "expired" then
			self.object:remove()
		end
	end,
	on_punch = function(self)
		self.object:remove()
	end,
	get_staticdata = function(self)
		return "expired"
	end,
})

-- [register] Globalstep
minetest.register_globalstep(function(dtime)
  -- Check timer
	timer = timer + dtime
	if timer < update_time then
		return
	end

	local active_players = {}
  -- Add/update wielditem entity
	for _, player in pairs(minetest.get_connected_players()) do
		local name = player:get_player_name()
		local wield = player_wielding[name]
		if wield and wield.object then
			local stack = player:get_wielded_item()
			local item = stack:get_name() or ""
			if item ~= wield.item then
				wield.item = item
				if item == "" then
					item = "eden:wield_hand"
				end
				wield.object:set_properties({
					textures = {item},
					visual_size = location[4],
				})
			end
		else
			add_wield_entity(player)
		end
		active_players[name] = true
	end

  -- Check if wield entity should be removed
	for name, wield in pairs(player_wielding) do
		if not active_players[name] then
			if wield.object then
				wield.object:remove()
			end
			player_wielding[name] = nil
		end
	end

  -- Reset timer
	timer = 0
end)

-- [register] On leave player remove object
minetest.register_on_leaveplayer(function(player)
	local name = player:get_player_name()
	if name then
		local wield = player_wielding[name] or {}
		if wield.object then
			wield.object:remove()
		end
		player_wielding[name] = nil
	end
end)
