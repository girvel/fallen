local animated = require("tech.animated")
local common = require("utils.common")


local module = {}

local highlight_pack = animated.load_pack("assets/sprites/highlight")

module.highlight = function()
  return common.extend(animated(highlight_pack), {layer = "sfx"})
end

return module
