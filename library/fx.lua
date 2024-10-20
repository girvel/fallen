local animated = require("tech.animated")
local attacking = require("mech.attacking")


local module, _, static = Module("library.fx")

local steam_pack = animated.load_pack("assets/sprites/steam")

module.steam = function(direction)
  assert(direction)

  local result = Table.extend(
    animated(steam_pack),
    {
      boring_flag = true,
      codename = "steam",
      layer = "fx",
      view = "scene",
      direction = direction,

      harmed_entities = {},
      ai = {run = function(self, entity, dt)
        local target = State.grids.solids[entity.position + Vector[entity.direction]]
        if target and target.hp and not entity.harmed_entities[target] then
          attacking.attack_save(target, "dex", 15, D.roll({}, 1))
          entity.harmed_entities[target] = true
        end
      end},
    }
  )

  result:animate():next(function(self)
    State:remove(self)
  end)

  return result
end

return module
