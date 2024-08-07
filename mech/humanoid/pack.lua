local animated = require("tech.animated")
local anchors = require("mech.humanoid.anchors")


return Module("mech.humanoid.pack",
  animated.load_atlas_pack("assets/sprites/humanoid", anchors)
)
