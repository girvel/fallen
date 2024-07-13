local animated = require("tech.animated")
local mech = require("core.mech")


local module = {}

local steam_pack = animated.load_pack("assets/sprites/steam")

module.steam = function(direction)
  assert(direction)

  local result = Tablex.extend(
    animated(steam_pack),
    {
      layer = "sfx",
      view = "scene",
      direction = direction,

      harmed_entities = {},
      ai = function(self, event)
        local target = State.grids.solids[self.position + Vector[self.direction]]
        if target and not self.harmed_entities[target] then
          mech.damage(target, 1)
          self.harmed_entities[target] = true
        end
      end,
    }
  )

  result:animate()
  result:when_animation_ends(function(self)
    State:remove(self)
  end)

  return result
end

return module
