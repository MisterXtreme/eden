-- gui/hud.lua

-- [statbar] Health
minetest.register_on_joinplayer(function(player)
  local name = player:get_player_name()

  hudlib.add_statbar(name, "health", {
    replace = "health",
    position = { x = 0.5, y = 1 },
    size = { x = 24, y = 24 },
    offset = { x = (-10*24)-20, y = -(48+24+16)},
    texture = "heart.png",
    background = "heart_bg.png",
    min = 0,
    max = 20,
    start = player:get_hp(),
    events = {
      damage = function(self, player)
        self:set_status(player:get_hp())
      end,
    },
  })
end)
