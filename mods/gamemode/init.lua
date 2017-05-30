-- gamemode/init.lua

gamemode = {}

local gamemodes = {}
local aliases   = {}
local creative  = minetest.setting_getbool("creative_mode")

---
--- Callbacks
---

-- [register] On join set gamemode
minetest.register_on_joinplayer(function(player)
  gamemode.set(player, gamemode.get(player))
end)

-- [register] On place node
minetest.register_on_placenode(function(pos, newnode, player, oldnode, itemstack)
  local mode = gamemode.def(gamemode.get(player))
	local name = player:get_player_name()

	if not gamemode.can_interact(player) then
		minetest.remove_node(pos)
		minetest.chat_send_player(name, minetest.colorize("red", "WARNING")..
				" You cannot place nodes in "..mode.name.." mode")
		return true
	end

  return mode.stack_unlimited
end)

-- [register] On dig node
minetest.register_on_dignode(function(pos, node, player)
	local mode = gamemode.def(gamemode.get(player))
	local name = player:get_player_name()
	if not gamemode.can_interact(player) then
		minetest.set_node(pos, {name = node.name})
		minetest.chat_send_player(name, minetest.colorize("red", "WARNING")..
				" You cannot dig nodes in "..mode.name.." mode")
		return true
	end
end)

-- [register] On hp change
minetest.register_on_player_hpchange(function(player, hp_change)
  local def = gamemode.def(gamemode.get(player))
  if def.damage == false then
    return 0
  else
    return hp_change
  end
end, true)

---
--- Redefinitions
---

local rotate_node = minetest.rotate_node
function minetest.rotate_node(itemstack, placer, pointed_thing)
  itemstack = rotate_node(itemstack, placer, pointed_thing)

  local mode = gamemode.def(gamemode.get(placer))
  if not mode.stack_unlimited then
    itemstack:take_item(1)
  end

  return itemstack
end

---
--- API
---

-- [function] Register gamemode
function gamemode.register(name, def)
  -- Register hand
  if def.hand then
    minetest.register_item("gamemode:"..name, {
      type = "none",
      wield_image = def.hand.wield_image or "wieldhand.png",
      wield_scale = {x = 1, y = 1, z = 2.5},
      range = def.hand.range,
      tool_capabilities = def.hand,
			on_use = def.hand.on_use,
    })

		def.hand = "gamemode:"..name
  end

	-- Save aliases
	if def.aliases then
		for _, a in pairs(def.aliases) do
			aliases[a] = name
		end
	end

	def.name = name
	gamemodes[name] = def
end

-- [function] Get gamemode definition
function gamemode.def(name)
  if gamemodes[name] then
    return gamemodes[name]
	else
		if aliases[name] then
			return gamemodes[aliases[name]]
		end
  end
end

-- [function] Set player gamemode
function gamemode.set(player, gm_name)
	local gm = gamemode.def(gm_name)
  if gm then
    local name = player:get_player_name()
		local privs = minetest.get_player_privs(name)

    local old_gm = gamemode.def(gamemode.get(player))
    -- Revert HUD flags
    if old_gm.hud_flags then
      local flags = table.copy(old_gm.hud_flags)
      for _, f in pairs(flags) do
        flags[_] = not f
      end
      player:hud_set_flags(flags)
    end
		-- Revert privileges
    if old_gm.privileges then
      for _, i in pairs(old_gm.privileges) do
        privs[_] = not old_gm.privileges[_] or nil
      end
    end
    -- Check for on disable
    if old_gm.on_disable then
      old_gm.on_disable(player)
    end

    -- Update cache
    player:set_attribute("gamemode", gm_name)
    -- Update formspec
    if gm.tab_group then
      gui.set_tab_group(player, gm.tab_group)
    end
    -- Update HUD flags
    if gm.hud_flags then
      player:hud_set_flags(gm.hud_flags)
    end
    -- Check for on enable
    if gm.on_enable then
      gm.on_enable(player)
    end
    -- Update privileges
    if gm.privileges then
      for _, i in pairs(gm.privileges) do
        privs[_] = gm.privileges[_] or nil
      end
    end
    -- Update hand
    if gm.hand then
      player:get_inventory():set_stack("hand", 1, gm.hand)
		else -- else, Reset hand
			player:get_inventory():set_stack("hand", 1, "")
    end

		minetest.set_player_privs(name, privs)

    return true
  end
end

-- [function] Get player gamemode
function gamemode.get(player)
  if type(player) == "string" then
    player = minetest.get_player_by_name(player)
  end

  local gm = player:get_attribute("gamemode")
  if not gm or gm == "" then
    if creative then gm = "creative"
    else gm = "survival" end
  end

	if not gamemode.def(gm) then
		return "survival"
	end

  return gm
end

-- [function] Can interact
function gamemode.can_interact(player)
	local mode = gamemode.def(gamemode.get(player))
	if mode.privileges and mode.privileges.interact == false then
		return false
	end

	return true
end

---
--- Chatcommand
---

-- [privelege] Gamemode
minetest.register_privilege("gamemode", "Ability to use /gamemode")

-- [command] Gamemode - /gamemode <mode>
minetest.register_chatcommand("gamemode", {
  description = "Change gamemode",
  params = "<gamemode> / <name> <gamemode>",
  privs = {gamemode=true},
  func = function(name, param)
		local params = param:split(" ")
		local player = minetest.get_player_by_name(name)
		local newgm

		if params and #params == 1 then
			newgm = params[1]
		elseif params and #params == 2 then
			player = minetest.get_player_by_name(params[1])
			newgm  = params[2]
		else
			return false, "Invalid usage (see /help gamemode)"
		end

		if not player then
			return false, "Invalid player "..dump(params[1])
		end

		-- Set gamemode
		if newgm and gamemode.set(player, newgm) then
			local gm_name = gamemode.def(newgm).name
	    return true, "Set "..player:get_player_name().."'s gamemode to "..gm_name
		else -- else, Return invalid gamemode
			return false, "Invalid gamemode "..dump(newgm)
		end
  end,
})

---
--- Load Gamemodes
---

dofile(minetest.get_modpath("gamemode").."/modes.lua")
