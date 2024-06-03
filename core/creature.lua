local common = require("utils.common")


local module = {}
local module_mt = {}
setmetatable(module, module_mt)

module_mt.__call = function(_, animation_pack, object)
  local result = common.extend({
    animation = {
      pack = animation_pack,
    },
    sprite = {},
    abilities = {
      strength = 10,
      dexterity = 10,
      constitution = 10,
    },
    direction = "right",
    proficiency_bonus = 2,
    inventory = {
      bag = {},
    },

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
        bonus_actions = 1,
        reactions = 1,
        has_advantage = false,
      }
    end,

    get_max_hp = function(self)
      assert(self.max_hp or self.class)
      if self.max_hp then return self.max_hp end
      local con_bonus = module.get_modifier(self.abilities.constitution)
      return self.class.hp_die + con_bonus
        + (self.level - 1) * (self.class.hp_die / 2 + 1 + con_bonus)
      end,
  }, object or {})

  result.hp = result:get_max_hp()
  result.turn_resources = result:get_turn_resources()
  result:animate("idle")

  return result
end

module.get_modifier = function(ability_score)
  return math.floor((ability_score - 10) / 2)
end

return module
