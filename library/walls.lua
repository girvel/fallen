local factoring = require("tech.factoring")


local walls, module_mt, static = Module("library.walls")

Tablex.extend(walls, factoring.from_atlas("assets/sprites/atlases/walls.png", {
  layer = "solids",
  view = "scene",
}, {
  "steel", "steel_variant", "steel_with_mirror"
}))

return walls
