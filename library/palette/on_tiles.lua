local factoring = require("tech.factoring")


local on_tiles, module_mt, static = Module("library.palette.on_tiles")

factoring.from_atlas(on_tiles, "assets/sprites/atlases/on_tiles.png", {
  view = "scene",
  layer = "items",
}, {
  "toilet", "magazine",
})

return on_tiles
