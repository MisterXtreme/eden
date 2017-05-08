-- tree/init.lua

trees = {}
trees.registered = {}

local path = minetest.get_modpath("trees").."/schematics"

---
--- API
---

-- [function] Register tree
function trees.register(name, def)
  -- Sapling
  minetest.register_node("trees:"..name, {
    basename = name,
    description = def.basename.." Sapling",
    drawtype = "plantlike",
    inventory_image = def.sapling,
    wield_image = def.sapling,
    tiles = {def.sapling},
    paramtype = "light",
    sunlight_propagates = true,
    walkable = false,
    on_timer = trees.grow,
    on_construct = function(pos)
      minetest.get_node_timer(pos):start(math.random(def.time.start_min, def.time.start_max))
    end,
    selection_box = {
      type = "fixed",
  		fixed = {-4 / 16, -0.5, -4 / 16, 4 / 16, 7 / 16, 4 / 16}
    },
    groups = {dig_immediate = 3, flammable = 2, sapling = 1},
  })

  -- Normal (large)
  minetest.register_node("trees:"..name.."_large", {
    basename = name,
    description = "Large "..def.basename.." Log",
    tiles = {def.center, def.sides},
    paramtype2 = "facedir",
    is_ground_content = false,
    groups = {choppy = 2, oddly_breakable_by_hand = 1, flammable = 2, log = 1},
    on_place = minetest.rotate_node,
  })

  -- Trunk
  minetest.register_node("trees:"..name.."_trunk", {
    basename = name,
    description = def.basename.." Trunk",
    tiles = {def.center, def.sides},
    paramtype2 = "facedir",
    is_ground_content = false,
    groups = {choppy = 2, oddly_breakable_by_hand = 1, flammable = 2, log = 1, not_in_creative_inventory = 1},
    drop = "trees:"..name.."_large",
    drawtype = "nodebox",
    node_box = {
      type = "fixed",
      fixed = {
  			{-0.25, -0.5, -0.25, 0.25, 0.5, 0.25}, -- Base
  			{-0.1875, -0.5, -0.375, 0.25, 0.375, -0.25}, -- NodeBox3
  			{0.25, -0.5, -0.1875, 0.375, 0.1875, 0.1875}, -- NodeBox4
  			{-0.375, -0.5, -0.25, -0.25, 0.25, 0.1875}, -- NodeBox5
  			{-0.1875, -0.5, 0.25, 0.1875, 0.4375, 0.375}, -- NodeBox6
  			{-0.0625, -0.5, 0.375, 0.125, 0, 0.4375}, -- NodeBox7
		  },
    },
  })

  -- Log
  minetest.register_node("trees:"..name.."_log", {
    basename = name,
    description = def.basename.." Log",
    tiles = {def.center, def.sides},
    paramtype2 = "facedir",
    is_ground_content = false,
    groups = {choppy = 2, oddly_breakable_by_hand = 1, flammable = 2, log = 1, not_in_creative_inventory = 1},
    drop = "trees:"..name.."_large",
    drawtype = "nodebox",
    node_box = {
      type = "connected",
      fixed         = {-0.25, -0.5, -0.25, 0.25, 0.5, 0.25},
      connect_front = {-0.125, -0.125, -0.5, 0.1875, 0.1875, -0.25},
      connect_back  = {-0.1875, -0.125, 0.1875, 0.1875, 0.1875, 0.5},
      connect_left  = {-0.5, -0.125, -0.125, -0.25, 0.1875, 0.125},
      connect_right = {0.25, -0.125, -0.125, 0.5, 0.1875, 0.1875},
    },
    connects_to = {"trees:"..name.."_leaf"},
  })

  -- Leaf
  minetest.register_node("trees:"..name.."_leaf", {
    basename = name,
    description = def.basename.." Leaf",
    tiles = {def.leaf},
    drawtype = "allfaces_optional",
    waving = 1,
    paramtype = "light",
    paramtype2 = "facedir",
    is_ground_content = false,
    groups = {snappy = 3, flammable = 2, leaves = 1},
  })

  -- Decoration
  local mapgen = def.mapgen
  mapgen.deco_type = "schematic"
  mapgen.sidelen = mapgen.sidelen or 16
  mapgen.flags = "place_center_x, place_center_z"
  mapgen.rotation = "random"
  mapgen.schematic = path.."/"..def.schematic
  minetest.register_decoration(mapgen)

  -- General
  def.name = name
  def.min_light = def.min_light or 13
  def.time = def.time or {
    start_min = 2400,
    start_max = 4800,
    retry_min = 240,
    retry_max = 600,
  }

  -- Add to table
  trees.registered[name] = def
end

-- [function] Can grow
function trees.can_grow(pos)
  local node  = minetest.get_node(pos)
  local def   = trees.registered[minetest.registered_nodes[node.name].basename]
  local light = def.min_light

  local node_under = minetest.get_node_or_nil({x = pos.x, y = pos.y - 1, z = pos.z})
  -- Check for node under
  if not node_under then
    return
  end

  local name_under = node_under.name
  -- Check if soil group
  if minetest.get_item_group(name_under, "soil") == 0 then
    return
  end

  local light_level = minetest.get_node_light(pos)
  if light and not light_level or light_level < light then
    return
  end

  return true
end

-- [function] Place tree
function trees.place(name, pos)
  if trees.registered[name] then
    local tree = trees.registered[name]
    if trees.schematic then
      if trees.offset then
        pos = vector.add(trees.offset, pos)
      end

      return minetest.place_schematic(pos, path.."/"..trees.schematic, "random",
          nil, false)
    end
  end
end

-- [function] Grow tree
function trees.grow(pos)
  local node = minetest.get_node(pos)
  local name = minetest.registered_nodes[node.name].basename
  local def  = trees.registered[name]

  if trees.can_grow(pos) then
    -- Log message
    minetest.log("action", "A "..def.basename.." sapling grows into a tree at "..
        minetest.pos_to_string(pos))
    -- Place tree
    trees.place(name, pos)
  else
    minetest.get_node_timer(pos):start(math.random(def.time.retry_min, def.time.retry_max))
  end
end

---
--- Chatcommands
---

-- [register chatcommand] Place tree
minetest.register_chatcommand("place_tree", {
  description = "[DEBUG] Place tree",
  params = "<tree name> <pos (x y z)>",
  privs = {debug=true},
  func = function(name, param)
    local tname, p = string.match(param, "^([^ ]+) *(.*)$")
		local pos     = minetest.string_to_pos(p)

    if not pos then
      pos = minetest.get_player_by_name(name):getpos()
    end

    return true, "Success: "..dump(trees.place(tname, pos))
  end
})

---
--- Registrations
---

trees.register("oak", {
  basename = "Oak",
  center = "trees_oak_log.png",
  sides = "trees_oak_log_sides.png",
  sapling = "trees_oak_sapling.png",
  leaf = "trees_oak_leaf.png",
  offset = { x = -3, y = -1, z = -3},
  schematic = "oak_tree.mts",
  mapgen = {
    place_on = {"soil:dirt_with_grass"},
    fill_ratio = 0.05,
    biomes = {"eden:grassland"},
    y_min = 1,
    y_max = 200,
  },
})
