local factoring = require("tech.factoring")
local sound = require("tech.sound")


local tiles, module_mt, static = Module("library.tiles")

local move_sounds = {
  planks = sound.multiple("assets/sounds/move_planks", 0.1),
  walkway = sound.multiple("assets/sounds/move_walkway", 0.1),
}

factoring.from_atlas(tiles, "assets/sprites/atlases/tiles.png",
  function(name) return {
    view = State.gui.views.scene,
    layer = "tiles",
    sounds = {move = move_sounds[name]},
  } end,
  {
    "steel_floor", "walkway", "planks", "steel_floor_dirty",
    "steel_barred", "steel_damaged", "steel_barred_damaged",
  }
)

return tiles
