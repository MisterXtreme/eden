-- eden/hud.lua

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
    on_step = function(self, player)
      local def = eden.get_gamemode_def(eden.get_gamemode(player))
      if def.damage == false then
        self:hide()
      else
        self:show()
      end
    end,
  })
end)

-- [statbar] Breath
minetest.register_on_joinplayer(function(player)
  local name = player:get_player_name()

  hudlib.add_statbar(name, "breath", {
    show = false,
    replace = "breath",
    position = { x = 0.5, y = 1 },
    size = { x = 24, y = 24 },
    offset = { x = 20, y = -(48+24+17)},
    texture = "bubble.png",
    background = "bubble_bg.png",
    min = 0,
    max = 20,
    events = {
      breath = function(self, player)
        local bg  = hudlib.get_statbar(name, "breath_background")
        local air = player:get_breath()
        local def = eden.get_gamemode_def(eden.get_gamemode(player))

        if air < 11 and def.breath == false then
          self:hide()
          player:set_breath(11)
          return
        end

        if air > 10 then
          self:hide()
        else
          self:show()
        end

        self:set_status(air * 2)
      end,
    },
  })
end)
