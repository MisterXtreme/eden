Player Model API
================
The player model API allows you to get or set the player animation, model, and textures.

`player.register_model(name, def)`

* Register new model
* `name`: Name for model
* `def`: See [#Model definition]

`player.get_animation(player)`

* Returns a table containing fields `model`, `textures` and `animation`.
* Any of the fields of the returned table may be nil.
* `player`: PlayerRef

`player.set_model(player, model_name)`

* Change a player's model
* `player`: PlayerRef
* `model_name`: model registered with player_register_model()

`player.set_textures(player, textures)`

* Sets player textures
* `player`: PlayerRef
* `textures`: array of textures, If `textures` is nil, the default textures from the model def are used

`player.set_animation(player, anim_name, speed)`

* Sets player textures
* `player`: PlayerRef
* `textures`: array of textures, If `textures` is nil, the default textures from the model def are used

#### Model definition
```lua
{
  animation_speed = 30, -- Animation speed
  textures = {"character.png"}, -- Textures file
  animations = {
    -- Standard animations
    stand = { x=  0, y= 79, },
    ...
  }
}
```