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
