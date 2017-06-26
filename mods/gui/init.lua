-- gui/init.lua

gui = {}

local modpath = minetest.get_modpath("gui")

-- [on join] Configure hotbar
minetest.register_on_joinplayer(function(player)
  player:hud_set_hotbar_itemcount(9)
  player:hud_set_hotbar_image("gui_hotbar_bg.png")
  player:hud_set_hotbar_selected_image("gui_hotbar_selected.png")
end)

-- Load API
dofile(modpath.."/api.lua")
-- Load formspecs
dofile(modpath.."/formspec.lua")
-- Load HUD
dofile(modpath.."/hud.lua")
