local factoring = require("tech.factoring")
local sound = require("tech.sound")


local tiles, module_mt, static = Module("library.tiles")

local move_sounds = {
  planks = sound.multiple("assets/sounds/move_planks", 0.1),
  walkway = sound.multiple("assets/sounds/move_walkway", 0.1),
}

Tablex.extend(tiles, factoring.from_atlas("assets/sprites/atlases/tiles.png",
  function(name) return {
    view = "scene",
    layer = "tiles",
    sounds = {move = move_sounds[name]},
  } end,
  {
    "steel_floor", "walkway", "planks", "toilet",
    "steel_floor_dirty",
  }
))

return tiles
