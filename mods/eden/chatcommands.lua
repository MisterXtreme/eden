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
