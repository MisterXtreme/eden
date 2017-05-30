-- gamemode/modes.lua

---
--- Gamemode Registrations
---

-- [gamemode] Survival
gamemode.register("survival", {
	aliases = {"s", "0"},
  tab_group = "survival",
  hand = {
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
	privileges = {
    interact = true,
  },
})

local digtime = 25
local caps = {times = {digtime, digtime, digtime}, uses = 0, maxlevel = 256}
-- [gamemode] Creative
gamemode.register("creative", {
	aliases = {"c", "1"},
  tab_group = "creative",
  stack_unlimited = true,
  item_drops = "auto",
  damage = false,
  breath = false,
  hand = {
		range = 10,
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
	},
	privileges = {
    fly = true, fast = true,
  },
})
