local module = {}
local module_mt = {}
setmetatable(module, module_mt)

module_mt.__call = function(_, animation_pack)
  local result = {
    animation = {
      pack = animation_pack,
    },
    sprite = {},
    abilities = {
      strength = 10,
      dexterity = 10,
    },
    direction = "right",

    animate = function(self, animation_name)
      self.animation.current = animation_name .. "_" .. self.direction
      if not self.animation.pack[self.animation.current] then
        self.animation.current = animation_name
      end
      self.animation.frame = 1
    end,

    get_armor = function(self)
      return 10 + module.get_modifier(self.abilities.dexterity)
    end,

    get_turn_resources = function(_)
      return {
        movement = 6,
        actions = 1,
      }
    end
  }

  result.turn_resources = result:get_turn_resources()
  result:animate("idle")

  return result
end

module.get_modifier = function(ability_score)
  return math.floor((ability_score - 10) / 2)
end

return module
