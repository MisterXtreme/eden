-- eden/chatcommands.lua

-- [privelege] Heal
minetest.register_privilege("heal", "Ability to use /heal")

-- [command] Heal - /heal param
minetest.register_chatcommand("heal", {
	description = "Heal yourself or another player",
  params = "<player>",
	privs = {heal=true},
	func = function(name, param)
    local player = minetest.get_player_by_name(name)
    if param and minetest.get_player_by_name(param) then
      player = minetest.get_player_by_name(param)
    elseif param ~= "" then
      return true, "Player \""..param.."\" doesn't exist"
    end

    -- Set HP
    player:set_hp(20)
    -- Return message
    return true, player:get_player_name().." had been healed"
  end,
})

-- [privelege] Gamemode
minetest.register_privilege("gamemode", "Ability to use /gamemode")

-- [command] Gamemode - /gamemode <mode>
minetest.register_chatcommand("gamemode", {
  description = "Change gamemode",
  params = "<gamemode> | <name> <gamemode>",
  privs = {gamemode=true},
  func = function(name, param)
		local params = param:split(" ")
		local player = minetest.get_player_by_name(name)
		local newgm

		if params and #params == 1 then
			newgm = params[1]
		elseif params and #params == 2 then
			if minetest.get_player_by_name(params[1]) then
				player = minetest.get_player_by_name(params[1])
				newgm  = params[2]
			end
		else
			return false, "Invalid usage (see /help gamemode)"
		end

		-- Set gamemode
		if eden.set_gamemode(player, newgm) then			
	    return true, "Set "..player:get_player_name().."'s gamemode to "..param
		else -- else, Return invalid gamemode
			return false, "Invalid gamemode: "..newgm
		end
  end,
})
