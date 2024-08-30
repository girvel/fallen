local factoring = require("tech.factoring")


local pipes_under, module_mt, static = Module("library.palette.pipes_under")

factoring.from_atlas(pipes_under, "assets/sprites/atlases/pipes.png", {
  layer = "under_tiles",
  view = "scene",
}, {
  "horizontal", "horizontal_braced", "vertical", "vertical_braced",
  "left_back", "forward_left", "right_forward", "back_right",
  "left_down", "forward_down", "right_down", "back_down",
  "T_up", "T_left", "T_down", "T_right",
  "x", false, false, false,
  "colored", "leaking_left_down",
})

return pipes_under
