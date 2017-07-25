
--[[

Torch mod - formerly mod "Torches"
==============================

(c) Copyright BlockMen (2013-2015)
(C) Copyright sofar <sofar@foo-projects.org> (2016)
(C) Copyright octacian (2017)

This mod changes the default torch drawtype from "torchlike" to "mesh",
giving the torch a three dimensional appearance. The mesh contains the
proper pixel mapping to make the animation appear as a particle above
the torch, while in fact the animation is just the texture of the mesh.

The "torch" mod (as mentioned above) has been modified by octacian for use
in Eden.


License:
~~~~~~~~
(c) Copyright BlockMen (2013-2015)

Textures and Meshes/Models:
CC-BY 3.0 BlockMen
Note that the models were entirely done from scratch by sofar.

Code:
Licensed under the GNU LGPL version 2.1 or higher.
You can redistribute it and/or modify it under
the terms of the GNU Lesser General Public License
as published by the Free Software Foundation;

You should have received a copy of the GNU Lesser General Public
License along with this library; if not, write to the Free Software
Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA

See LICENSE.txt and http://www.gnu.org/licenses/lgpl-2.1.txt

--]]

local PARTICLES = minetest.settings:get("eden_torch_particles")

if PARTICLES == "false" then
	PARTICLES = false
else
	PARTICLES = true
end

---
--- Functions
---

-- [function] Add particlespawner
local function add(pos)
	if PARTICLES then
		local meta = minetest.get_meta(pos)
		if meta then
			local id = minetest.add_particlespawner({
				time = 0,
				minpos = {x = pos.x - 0.3, y = pos.y + 0.2, z = pos.z - 0.3},
				maxpos = {x = pos.x + 0.3, y = pos.y + 0.3, z = pos.z + 0.3},
				minvel = {x = 0, y = 0.2, z = 0},
				maxvel = {x = 0, y = 1, z = 0},
				minexptime = 1,
				maxexptime = 2,
				minsize = 0.5,
				maxsize = 2,
				collisiondetection = true,
				collision_removal = true,
				vertical = false,
				texture = "eden_item_smoke.png",
			})
			meta:set_int("particle_id", id)
		end
	end
end

-- [function] Remove particlespawner
local function remove(pos)
	if PARTICLES then
		local meta = minetest.get_meta(pos)
		if meta then
			minetest.delete_particlespawner(meta:get_int("particle_id"))
		end
	end
end

---
--- Registrations
---

minetest.register_node("eden:torch", {
	description = "Torch",
	drawtype = "mesh",
	mesh = "torch_floor.obj",
	inventory_image = "eden_torch.png",
	wield_image = "eden_torch.png",
	tiles = {"eden_torch.png"},
	paramtype = "light",
	paramtype2 = "wallmounted",
	sunlight_propagates = true,
	walkable = false,
	liquids_pointable = false,
	light_source = 12,
	groups = {choppy=2, dig_immediate=3, flammable=1, attached_node=1},
	drop = "eden:torch",
	selection_box = {
		type = "wallmounted",
		wall_bottom = {-1/8, -1/2, -1/8, 1/8, 2/16, 1/8},
	},
	on_place = function(itemstack, placer, pointed_thing)
		local under = pointed_thing.under
		local node = minetest.get_node(under)
		local def = minetest.registered_nodes[node.name]
		if def and def.on_rightclick and
			((not placer) or (placer and not placer:get_player_control().sneak)) then
			return def.on_rightclick(under, node, placer, itemstack,
				pointed_thing) or itemstack
		end

		local above = pointed_thing.above
		local wdir = minetest.dir_to_wallmounted(vector.subtract(under, above))
		local fakestack = itemstack
		if wdir == 0 then
			return
		elseif wdir == 1 then
			fakestack:set_name("eden:torch")
		else
			fakestack:set_name("eden:torch_wall")
		end

		itemstack = minetest.item_place(fakestack, placer, pointed_thing, wdir)
		itemstack:set_name("eden:torch")

		-- Add particles
		add(pointed_thing.above)

		return itemstack
	end,
	on_destruct = function(pos)
		remove(pos)
	end,
})

minetest.register_node("eden:torch_wall", {
	drawtype = "mesh",
	mesh = "torch_wall.obj",
	tiles = {"eden_torch.png"},
	paramtype = "light",
	paramtype2 = "wallmounted",
	sunlight_propagates = true,
	walkable = false,
	light_source = 12,
	groups = {choppy=2, dig_immediate=3, flammable=1, not_in_creative_inventory=1, attached_node=1},
	drop = "eden:torch",
	selection_box = {
		type = "wallmounted",
		wall_side = {-1/2, -1/2, -1/8, -1/8, 1/8, 1/8},
	},
	on_destruct = function(pos)
		remove(pos)
	end,
})

if PARTICLES then
	minetest.register_lbm({
		label = "Add particles to torches",
		name = "eden:torch_particle",
		nodenames = {"eden:torch", "eden:torch_wall"},
		run_at_every_load = true,
		action = function(pos, node)
			-- Add particles
			add(pos)
		end,
	})
end
