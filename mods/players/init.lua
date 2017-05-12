-- Eden mod: players
-- Adapted from Minetest 0.4 mod: players
-- See README.txt for licensing and other information.

-- Load API
dofile(minetest.get_modpath("players").."/api.lua")

-- [register] Default players appearance
players.register_model("character.b3d", {
	animation_speed = 30,
	textures = {"character.png"},
	animations = {
		-- Standard animations.
		stand     = { x=  0, y= 79, },
		lay       = { x=162, y=166, },
		walk      = { x=168, y=187, },
		mine      = { x=189, y=198, },
		walk_mine = { x=200, y=219, },
		sit       = { x= 81, y=160, },
	},
	default_model = true,
})
