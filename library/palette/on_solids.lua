local factoring = require("tech.factoring")


local on_solids, module_mt, static = Module("library.palette.on_solids")

factoring.from_atlas(on_solids, "assets/sprites/atlases/on_solids.png", {
  layer = "on_solids",
  view = "scene",
}, {
  "mirror", "dirt", "airway", "map", "sign", false, false, "cauldron",
  "vines", false, false, false, false, false, false, "cauldron",
})

return on_solids
