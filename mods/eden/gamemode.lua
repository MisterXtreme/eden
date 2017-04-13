-- eden/gamemode.lua

local gamemodes = {}
local creative  = minetest.setting_getbool("creative_mode")

-- [register] On join set gamemode
minetest.register_on_joinplayer(function(player)
  eden.set_gamemode(player, eden.get_gamemode(player))
end)

-- [register] On place node
minetest.register_on_placenode(function(pos, newnode, player, oldnode, itemstack)
  local mode = gamemodes[eden.get_gamemode(player)]
  return mode.stack_unlimited
end)

---
--- API
---

-- [function] Register gamemode
function eden.register_gamemode(name, def)
  def.tool_capabilities = def.hand_capabilities or def.tool_capabilities
  def.range             = def.hand_range or def.range

  gamemodes[name] = def

  -- Register hand
  if def.hand then
    def.hand = "eden:gamehand_"..name

    minetest.register_item(def.hand, {
      type = "none",
      wield_image = def.wield_image or "wieldhand.png",
      wield_scale = {x = 1, y = 1, z = 2.5},
      range = def.range,
      tool_capabilities = def.tool_capabilities,
    })
  end
end

-- [function] Set player gamemode
function eden.set_gamemode(player, gamemode)
  if gamemodes[gamemode] then
    -- Update cache
    player:set_attribute("gamemode", gamemode)

    local gm = gamemodes[gamemode]
    -- Update formspec
    if gm.tab_group then
      gui.set_tab_group(player, gm.tab_group)
    end

    -- Update hand
    if gm.hand then
      player:get_inventory():set_stack("hand", 1, gm.hand)
    end

    return true
  end
end

-- [function] Get player gamemode
function eden.get_gamemode(player)
  if type(player) == "string" then
    player = minetest.get_player_by_name(player)
  end

  local gm = player:get_attribute("gamemode")
  if not gm or gm == "" then
    if creative then gm = "creative"
    else gm = "survival" end
  end

  return gm
end

-- [function] Get gamemode definition
function eden.get_gamemode_def(name)
  if gamemodes[name] then
    return gamemodes[name]
  end
end

---
--- Registrations
---

-- [gamemode] Survival
eden.register_gamemode("survival", {
  tab_group = "survival",
  hand = true,
  hand_capabilities = {
		full_punch_interval = 1.0,
		max_drop_level = 0,
		groupcaps = {
			fleshy = {times={[2]=2.00, [3]=1.00}, uses=0, maxlevel=1},
			crumbly = {times={[2]=3.00, [3]=0.70}, uses=0, maxlevel=1},
			snappy = {times={[3]=0.40}, uses=0, maxlevel=1},
			oddly_breakable_by_hand = {times={[1]=7.00,[2]=4.00,[3]=1.40}, uses=0, maxlevel=3},
		},
		damage_groups = {fleshy=1},
	},
})

local digtime = 0
local caps = {times = {digtime, digtime, digtime}, uses = 0, maxlevel = 256}

eden.register_gamemode("creative", {
  tab_group = "creative",
  hand = true,
  range = 10,
  stack_unlimited = true,
  item_drops = "auto",
  hand_capabilities = {
		full_punch_interval = 0.5,
		max_drop_level = 3,
		groupcaps = {
			crumbly = caps,
			cracky  = caps,
			snappy  = caps,
			choppy  = caps,
			oddly_breakable_by_hand = caps,
		},
		damage_groups = {fleshy = 10},
	}
})
