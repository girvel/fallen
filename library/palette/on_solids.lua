local factoring = require("tech.factoring")


local on_solids, module_mt, static = Module("library.palette.on_solids")

factoring.from_atlas(on_solids, "assets/sprites/atlases/on_solids.png", {
  layer = "on_solids",
  view = "scene",
  perspective_flag = true,
}, {
  "mirror", "dirt", "airway", "map", "sign", false, false, "cauldron",
  "vines", "vines", "vines", "vines", "vines", false, false, "cauldron",
  false, "vines", "vines", "vines", "vines", false, false, false,
  false, false, false, "vines", "vines", false, false, false,
  false, false, false, "vines", "vines", false, false, false,
})

return on_solids
