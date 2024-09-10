local action = require("tech.action")
local abilities = require("mech.abilities")
local healing = require("mech.healing")


local class, _, static = Module("mech.class")

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

  modify_actions = function(self, entity, base)
    table.insert(base, self.action)
    return base
  end,
}

class.choice = static .. setmetatable({}, {
  __call = function(self, options)
    return {
      options = options,
      __type = self,
    }
  end
})

class.get_progression = function(this_class, level)
  return Fun.iter(this_class.progression_table)
    :take_n(level)
    :reduce(Table.concat, {})
end

return class
