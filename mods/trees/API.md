Trees API
=========

`trees.register(name, def)`

* Register a new tree along with all its nodes
* `name`: Name of tree (as in a node's itemstring)
* `def`: See [#Tree definition]

`trees.can_grow(pos)`

* Returns `true` if the sapling can grow
* `pos`: Position of sapling

`trees.place(name, pos)`

* Place a tree
* `name`: Name of tree (as in a node's itemstring)
* `pos`: Position at which to place the tree

`trees.grow(pos)`

* Grow a tree from any of the tree's child nodes
* Same as `trees.place` but requires that the target node be related to the tree and only executes if `trees.can_grow` returns `true`
* If the tree cannot be grown, it will retry later
* `pos`: Position of the tree's child node (e.g. sapling, leaf, trunk)

#### Tree definition
```lua
{
  basename = "Oak", -- Name to be concatenated for other nodes
  center = "trees_oak_log.png", -- Center (top/bottom) texture
  sides = "trees_oak_log_sides.png", -- Side texture
  plank = "trees_oak_plank.png", -- Plank texture
  sapling = "trees_oak_sapling.png", -- Sapling texture
  leaf = "trees_oak_leaf.png", -- Leaf texture
  offset = { x = -3, y = -1, z = -3}, -- Placement offset (x and z typically half the width and depth of the tree, y typically -1)
  schematic = "oak_tree.mts", -- Tree schematic file
  -- Mapgen definitions (minus those mentioned above - i.e. schematic)
  mapgen = {
    place_on = {"soil:dirt_with_grass"},
    fill_ratio = 0.05,
    biomes = {"eden:grassland"},
    y_min = 1,
    y_max = 200,
  },
}
```