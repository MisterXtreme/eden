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

-- Load gamemode API
dofile(modpath.."/gamemode.lua")
-- Load item entity
dofile(modpath.."/item_entity.lua")
-- Load nodes
dofile(modpath.."/nodes.lua")
-- Load mapgen
dofile(modpath.."/mapgen.lua")
-- Load chatcommands
dofile(modpath.."/chatcommands.lua")
-- Load wield view
dofile(modpath.."/wield.lua")
