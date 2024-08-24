local factoring = require("tech.factoring")


local things, module_mt, static = Module("library.things")

factoring.from_atlas(things, "assets/sprites/atlases/things.png", {
  view = State.gui.views.scene,
  layer = "items",
}, {
  "toilet", "magazine",
})

return things
