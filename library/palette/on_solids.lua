local factoring = require("tech.factoring")


local on_solids, module_mt, static = Module("library.palette.on_solids")

local use_perspective = Common.set({
  "mirror", "airway", "map", "sign", "cauldron"
})

factoring.from_atlas(on_solids, "assets/sprites/atlases/on_solids.png",
  function(name) return {
    layer = "on_solids",
    view = "scene",
    perspective_flag = use_perspective[name],
  } end,
  {
    "mirror", "dirt", "airway", "map", "sign", "window", false, "cauldron",
    "vines", "vines", "vines", "vines", "vines", false, false, "cauldron",
    false, "vines", "vines", "vines", "vines", false, false, false,
    false, false, false, "vines", "vines", false, false, false,
    false, false, false, "vines", "vines", false, false, false,
  }
)

return on_solids
