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
  -- Add/update wielditem entity
	for _, player in pairs(minetest.get_connected_players()) do
		local name  = player:get_player_name()
		local wield = player_wielding[name] or {}
		local stack = player:get_wielded_item()
		local item  = stack:get_name() or ""
		local index = player:get_wield_index()

		if wield.index == index then
			if wield.item == item or wield.item == "" and item == "" then
				return
			end
		end

		if wield.object then
			wield.index = index
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
	end
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
