--Functions
processed_blocks = {}

--[[
--register general nodes
function processed_blocks.register_node(node_def)
  --If no texture name is supplied, fall back to proccessed_blocks_<node_name>.png
  if node_def.texture == nil then
    texture = {"processed_blocks_" .. node_def.node_name .. ".png"}
  end
  --If no description is supplied, fall back to "Proccessed block"
  if node_def.desc == nil then
    desc = "Proccessed block"
  end
  --If a keyword (stone, or wood) is passed as the node groups, set the node's groups as the same as those nodes
  if node_def.harvest_groups == "stone" or "Stone" then
    node_groups = {cracky = 3, stone = 1}
  elseif node_def.harvest_groups == "wood" or "Wood" then
    node_groups = {choppy = 2, oddly_breakable_by_hand = 2, flammable = 2, wood = 1}
  elseif node_def.harvest_groups == "glass" or "Glass" then
    node_groups = {cracky = 3, oddly_breakable_by_hand = 3}
  end
  --register the node
  minetest.register_node("processed_blocks:" .. node_def.node_name, {
    description = desc,
    tiles = texture,
    groups = node_groups
  })
end

--Register treated wood planks
function processed_blocks.register_treated_plank(wood_name)
  processed_blocks.register_node(wood_name .. "_plank", "Treated " .. wood_name .. " planks", "wood", wood_name .. "_plank")
end


--Register treated wood planks

processed_blocks.register_treated_plank("oak")

--Register bricks

processed_blocks.register_node("stone_bricks_plain", "Plain stone bricks", "stone")

--Register misc nodes

--Wattle will be made with mud (wet dirt), clay, sand & straw
processed_blocks.register_node("wattle", "Wattle & Duab", {choppy = 2, oddly_breakable_by_hand = 2, flammable = 2, wood = 1})
--]]
minetest.register_node("processed_blocks:wattle", {
  description = "Wattle & Duab",
  tiles = {"processed_blocks_wattle.png"},
  groups = {cracky=3}
})

minetest.register_node("processed_blocks:oak_planks", {
  description = "processed oak planks",
  tiles = {"processed_blocks_oak_plank.png"},
  groups = {cracky=3}
})

minetest.register_node("processed_blocks:glass", {
  description = "Glass",
  use_texture_alpha = true,
  drawtype = "glasslike_framed",
  tiles = {"processed_blocks_glass_block.png", "processed_blocks_glass_block_detail.png"},
  groups = {cracky=3}
})


minetest.register_node("processed_blocks:sponge", {
  description = "Sponge",
  tiles = {"processed_blocks_sponge.png"},
  groups = {cracky=3}
})

minetest.register_node("processed_blocks:ladder_wood", {
    drawtype = "signlike",
    description = "Wood Ladder",
    tiles = {"processed_blocks_ladder_wood.png"},
    wield_image = "processed_blocks_ladder_wood.png",
    inventory_image = "processed_blocks_ladder_wood.png",
    paramtype = "light",
    paramtype2 = "wallmounted",
    sunlight_propagates = true,
    walkable = false,
    climbable = true,
  	is_ground_content = false,
    selection_box = {
        type = "wallmounted",
    },
    groups = {choppy = 2, oddly_breakable_by_hand = 3, flammable = 2}
})
--]]
