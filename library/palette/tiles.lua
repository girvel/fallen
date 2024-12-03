local factoring = require("tech.factoring")
local sound = require("tech.sound")


local tiles, module_mt, static = Module("library.palette.tiles")

local metal_move = sound.multiple("assets/sounds/move_metal", 0.2)

local move_sounds = {
  planks = sound.multiple("assets/sounds/move_planks", 0.1),
  walkway = sound.multiple("assets/sounds/move_walkway", 0.1),
  steel_barred = metal_move,
  steel_barred_damaged = metal_move,
  steel_floor = metal_move,
  steel_damaged = metal_move,
}

factoring.from_atlas(tiles, "assets/sprites/atlases/tiles.png",
  function(name) return {
    view = "scene",
    layer = "tiles",
    sounds = {move = move_sounds[name]},
  } end,
  {
    "walkway", "planks", "steel_barred", "steel_barred_damaged",
    "steel_floor", "steel_damaged",
  }
)

return tiles
