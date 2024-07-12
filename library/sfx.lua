local animated = require("tech.animated")


local module = {}

local highlight_pack = animated.load_pack("assets/sprites/highlight")

module.highlight = function()
  return Tablex.extend(animated(highlight_pack), {layer = "sfx", view = "scene"})
end

return module
