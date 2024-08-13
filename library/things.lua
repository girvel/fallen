local factoring = require("tech.factoring")


local things, module_mt, static = Module("library.things")

factoring.from_atlas(things, "assets/sprites/atlases/things.png", {
  view = "scene",
  layer = "items",
}, {
  "toilet", "magazine",
})

return things
