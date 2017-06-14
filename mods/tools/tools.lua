-- tools/tools.lua

tools.register("Diamond", "diamond", {
	material = "ores:diamond",
	pick = {"tools_diamond_pick.png", {
		full_punch_interval = 0.9,
		max_drop_level=3,
		groupcaps={
			cracky = {times={[1]=2.0, [2]=1.0, [3]=0.50}, uses=30, maxlevel=3},
		},
		damage_groups = {fleshy=5},
	}},
	axe = {"tools_diamond_axe.png", {
		full_punch_interval = 0.9,
		max_drop_level=1,
		groupcaps={
			choppy={times={[1]=2.10, [2]=0.90, [3]=0.50}, uses=30, maxlevel=2},
		},
		damage_groups = {fleshy=7},
	}},
	shovel = {"tools_diamond_shovel.png", {
		full_punch_interval = 1.0,
		max_drop_level=1,
		groupcaps={
			crumbly = {times={[1]=1.10, [2]=0.50, [3]=0.30}, uses=30, maxlevel=3},
		},
		damage_groups = {fleshy=4},
	}},
})

tools.register("Wooden", "wood", {
	material = "group:plank",
	pick = {"tools_wood_pick.png", {
		full_punch_interval = 0.9,
		max_drop_level=3,
		groupcaps={
			cracky = {times={[1]=2.0, [2]=4.0, [3]=6.0}, uses=30, maxlevel=3},
		},
		damage_groups = {fleshy=2},
	}},
	axe = {"tools_wood_axe.png", {
		full_punch_interval = 0.9,
		max_drop_level=1,
		groupcaps={
			choppy={times={[1]=2.10, [2]=0.90, [3]=0.50}, uses=30, maxlevel=2},
		},
		damage_groups = {fleshy=7},
	}},
})
