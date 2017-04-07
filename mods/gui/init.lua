-- gui/init.lua

gui = {}

-- [on join] Configure hotbar
minetest.register_on_joinplayer(function(player)
  player:hud_set_hotbar_itemcount(9)
  player:hud_set_hotbar_image("gui_hotbar_bg.png")
  player:hud_set_hotbar_selected_image("gui_hotbar_selected.png")
end)
