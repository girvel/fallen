local animated = require("tech.animated")
local anchors = require("mech.humanoid.anchors")


return Static.module("mech.humanoid.pack",
  animated.load_atlas_pack("assets/sprites/humanoid", anchors)
)
