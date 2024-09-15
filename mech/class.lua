local experience = require("mech.experience")
local action = require("tech.action")
local abilities = require("mech.abilities")
local healing = require("mech.healing")


local class, _, static = Module("mech.class")

class.choice = static .. Type .. function(options)
  return {
    options = options,
  }
end

class.provide_action = static .. function(self, entity, base)
  table.insert(base, self.action)
  return base
end

class.hit_dice = static {
  codename = "hit_dice",

  action = static .. action {
    get_healing_roll = function(self, entity)
      return D(entity.class.hp_die) + abilities.get_modifier(entity.abilities.con)
    end,
    cost = {
      hit_dice = 1,
    },
    _get_availability = function(self, entity)
      return entity.hp < entity:get_max_hp()
    end,
    _run = function(self, entity)
      healing.heal(entity, self:get_healing_roll(entity):roll())
    end,
  },

  modify_resources = function(self, entity, base, rest_type)
    if rest_type == "long" then
      base.hit_dice = entity.level
    end
    return base
  end,

  modify_actions = class.provide_action,
}

class.save_proficiency = function(...)
  return {
    _abilities = Common.set {...},
    codename = "save_proficiency",
    modify_saving_throw = function(self, entity, roll, ability)
      if self._abilities[ability] then
        roll = roll + experience.get_proficiency_modifier(entity.level)
      end
      return roll
    end
  }
end

return class
