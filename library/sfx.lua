local animated = require("tech.animated")
local mech = require("core.mech")
local special = require("tech.special")


local module = {}

local steam_pack = animated.load_pack("assets/sprites/steam")

module.steam = function(direction)
  assert(direction)

  local result = Tablex.extend(
    animated(steam_pack),
    {
      codename = "steam",
      layer = "sfx",
      view = "scene",
      direction = direction,

      harmed_entities = {},
      ai = function(self, event)
        local target = State.grids.solids[self.position + Vector[self.direction]]
        if target and target.hp and not self.harmed_entities[target] then
          mech.attack_save(target, "dexterity", 15, D.roll({}, 1))
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
