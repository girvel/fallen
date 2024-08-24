local factoring = require("tech.factoring")


local walls, module_mt, static = Module("library.walls")

factoring.from_atlas(walls, "assets/sprites/atlases/walls.png", {
  layer = "solids",
  view = State.gui.views.scene,
}, {
  "steel", "steel_variant", "steel_with_mirror", "steel_vined", "steel_dirty", "megadoor_left", "megadoor_middle", "megadoor_right",
  "steel_vented", "steel_behind_cauldron", "steel_with_map", "steel_with_sign",
})

return walls
