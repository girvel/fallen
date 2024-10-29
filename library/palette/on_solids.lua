local interactive = require("tech.interactive")
local factoring = require("tech.factoring")


local on_solids, module_mt, static = Module("library.palette.on_solids")

local use_perspective = Common.set({
  "mirror", "airway", "map", "sign", "cauldron", "upper_bunk", "blood",
})

factoring.from_atlas(on_solids, "assets/sprites/atlases/on_solids.png",
  function(name) return {
    layer = "on_solids",
    view = "scene",
    perspective_flag = use_perspective[name],
  } end,
  {
    "mirror", "dirt", "airway", "map", "sign", "window", "upper_bunk", "cauldron",
    "vines", "vines", "vines", "vines", "vines", "son_mary1", "blood", "cauldron",
    false, "vines", "vines", "vines", "vines", "son_mary2", false, false,
    "megadoor1_open", "megadoor2_open", "megadoor3_open", "vines", "vines", false, false, false,
    false, false, false, "vines", "vines", false, false, false,
  }
)

factoring.extend(on_solids, "son_mary2",
  {sprite_offset = Vector.up * 0.5, name = "Голова в банке"},
  interactive.detector()
)

return on_solids
