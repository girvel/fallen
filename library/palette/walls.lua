local factoring = require("tech.factoring")


local walls, module_mt, static = Module("library.palette.walls")

factoring.from_atlas(walls, "assets/sprites/atlases/walls.png", {
  layer = "solids",
  view = "scene",
}, {
  "steel", "steel", "steel", "steel", "steel", "steel", false, false,
  false, false, "steel", "steel", "steel", "steel", false, false,
  false, false, false, false, "steel", "steel", false, false,
  false, false, false, false, "steel", "steel",
})

return walls
