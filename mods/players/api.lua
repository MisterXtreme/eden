-- players/api.lua

players = {}

-- Player animation blending
-- Note: This is currently broken due to a bug in Irrlicht, leave at 0
local animation_blend = 0

players.registered_models = {}

-- Local for speed.
local models = players.registered_models

-- [function] Register model
function players.register_model(name, def)
	models[name] = def

	if def.default_model then
		players.default_model = name
	end
end

-- Player stats and animations
local player_model = {}
local player_textures = {}
local player_anim = {}
local player_sneak = {}
players.attached = {}

-- [function] Get player animation
function players.get_animation(player)
	local name = player:get_player_name()
	return {
		model = player_model[name],
		textures = player_textures[name],
		animation = player_anim[name],
	}
end

-- [function] Set player model
function players.set_model(player, model_name)
	local name = player:get_player_name()
	local model = models[model_name]
	if model then
		if player_model[name] == model_name then
			return
		end
		player:set_properties({
			mesh = model_name,
			textures = player_textures[name] or model.textures,
			visual = "mesh",
			visual_size = model.visual_size or {x=1, y=1},
		})
		players.set_animation(player, "stand")
	else
		player:set_properties({
			textures = { "players.png", "player_back.png", },
			visual = "upright_sprite",
		})
	end
	player_model[name] = model_name
end

-- [function] Set player textures (skin)
function players.set_textures(player, textures)
	local name = player:get_player_name()
	player_textures[name] = textures
	player:set_properties({textures = textures,})
end

-- [function] Set player animation
function players.set_animation(player, anim_name, speed)
	local name = player:get_player_name()
	if player_anim[name] == anim_name then
		return
	end
	local model = player_model[name] and models[player_model[name]]
	if not (model and model.animations[anim_name]) then
		return
	end
	local anim = model.animations[anim_name]
	player_anim[name] = anim_name
	player:set_animation(anim, speed or model.animation_speed, animation_blend)
end

-- [function] Set nametag colour
function players.set_nametag_colour(player, colour)
	colour = colour or {}
	colour.a = colour.a or 255
	colour.r = colour.r or 255
	colour.g = colour.g or 255
	colour.b = colour.b or 255

	player:set_nametag_attributes({color = colour})
end

-- [on joinplayer] Update appearance/physics
minetest.register_on_joinplayer(function(player)
	if not players.default_model then
		return
	end

	players.attached[player:get_player_name()] = false
	players.set_model(player, players.default_model)
	player:set_local_animation({x=0, y=79}, {x=168, y=187}, {x=189, y=198}, {x=200, y=219}, 30)

	-- Disable sneak glitch
	player:set_physics_override({sneak_glitch = false})
end)

-- [on leaveplayer] Remove from tables
minetest.register_on_leaveplayer(function(player)
	local name = player:get_player_name()
	player_model[name] = nil
	player_anim[name] = nil
	player_textures[name] = nil
end)

-- Localize for better performance.
local set_animation = players.set_animation
local attached = players.attached

-- [globalstep] Check each player and apply animations
minetest.register_globalstep(function(dtime)
	for _, player in pairs(minetest.get_connected_players()) do
		local name = player:get_player_name()
		local model_name = player_model[name]
		local model = model_name and models[model_name]
		if model and not attached[name] then
			local controls = player:get_player_control()
			local walking = false
			local animation_speed_mod = model.animation_speed or 30

			-- Determine if the player is walking
			if controls.up or controls.down or controls.left or controls.right then
				walking = true
			end

			-- Determine if the player is sneaking, and reduce animation speed if so
			if controls.sneak then
				animation_speed_mod = animation_speed_mod / 2
			end

			-- Determine if player sneak status has changed
			if player_sneak[name] ~= controls.sneak then
				if controls.sneak then
					players.set_nametag_colour(player, {a = 0}) -- Update nametag
				else
					players.set_nametag_colour(player) -- Update nametag
				end
			end

			-- Apply animations based on what the player is doing
			if player:get_hp() == 0 then
				set_animation(player, "lay")
			elseif walking then
				if player_sneak[name] ~= controls.sneak then
					player_anim[name] = nil
					player_sneak[name] = controls.sneak
				end
				if controls.LMB then
					set_animation(player, "walk_mine", animation_speed_mod)
				else
					set_animation(player, "walk", animation_speed_mod)
				end
			elseif controls.LMB then
				set_animation(player, "mine")
			else
				set_animation(player, "stand", animation_speed_mod)
			end
		end
	end
end)
