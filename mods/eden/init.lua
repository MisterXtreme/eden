-- eden/init.lua

eden = {}

local modpath = minetest.get_modpath("eden")

-- [function] Get subgame version information
function eden.get_version()
  return {
    version = "0.1",
    type = "dev",
    core = "0.4.15",
    core_type = "dev",
  }
end

-- [register] On join send message
minetest.register_on_joinplayer(function(player)
  minetest.after(0, function()
    minetest.chat_send_player(player:get_player_name(), "This is Eden, a highly"
      .." work-in-progress Minetest subgame.")
  end)
end)

-- [register item] The hand
minetest.register_item(":", {
	type = "none",
	wield_image = "wieldhand.png",
	wield_scale = {x=1,y=1,z=2.5},
	tool_capabilities = {
		full_punch_interval = 1.0,
		max_drop_level = 0,
		groupcaps = {
			fleshy = {times={[2]=2.00, [3]=1.00}, uses=0, maxlevel=1},
			crumbly = {times={[2]=3.00, [3]=0.70}, uses=0, maxlevel=1},
			snappy = {times={[3]=0.40}, uses=0, maxlevel=1},
			oddly_breakable_by_hand = {times={[1]=7.00,[2]=4.00,[3]=1.40}, uses=0, maxlevel=3},
		},
		damage_groups = {fleshy=1},
	}
})

-- Load nodes
dofile(modpath.."/nodes.lua")
-- Load liquids
dofile(modpath.."/liquids.lua")
-- Load mapgen
dofile(modpath.."/mapgen.lua")
