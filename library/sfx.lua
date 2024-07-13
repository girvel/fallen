local animated = require("tech.animated")


local module = {}

local highlight_pack = animated.load_pack("assets/sprites/highlight")

module.highlight = function()
  return Tablex.extend(animated(highlight_pack), {layer = "sfx", view = "scene"})
end

local steam_pack = animated.load_pack("assets/sprites/steam")

module.steam = function(direction)
  assert(direction)

  local result = Tablex.extend(
    animated(steam_pack),
    {
      layer = "sfx",
      view = "scene",
      direction = direction,
      debug_flag = true,
    }
  )

  result:animate()
  result:when_animation_ends(function(self)
    State:remove(self)
  end)

  return result
end

return module
