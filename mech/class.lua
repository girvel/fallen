local action = require("tech.action")
local perk = require("mech.perk")
local abilities = require("mech.abilities")
local healing = require("mech.healing")


local class, _, static = Module("mech.class")

class.get_choices = function(progression_table, level)
  return Fun.iter(progression_table)
    :take_n(level)
    :map(function(perks)
      return Fun.iter(perks)
        :filter(function(p) return p.enum_variant == perk.choice end)
        :totable()
    end)
    :reduce(Table.concat, {})
end

class.hit_dice_action = static .. action {
  codename = "hit_dice_action",
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
    healing.heal(entity, self:get_healing_roll():roll())
  end,
}

class.mixin = function()
  return {
    get_actions = function(self, level)
      return Fun.iter(self.progression_table)
        :take_n(level)
        :map(function(perks)
          return Fun.iter(perks)
            :filter(function(p) return p.enum_variant == perk.action end)
            :map(function(p) return p.action end)
            :totable()
        end)
        :reduce(Table.concat, {class.hit_dice_action})
    end,

    get_effects = function(self, level, build)
      return Fun.iter(self.progression_table)
        :take_n(level)
        :map(function(perks)
          return Fun.iter(perks)
            :map(function(p)
              if p.enum_variant == perk.effect then
                return p.modifier
              end
              if p.enum_variant == perk.choice then
                return p.options[build[p]]
              end
            end)
            :filter(Fun.op.truth)
            :totable()
        end)
        :reduce(Table.concat, {})
    end,

    get_resources = function(self, level, rest_type)
      local base = {
        move = {},
        short = {},
        long = {hit_dice = level},
      }

      return Fun.iter(self.progression_table)
        :take_n(level)
        :map(function(perks)
          return Fun.iter(perks)
            :filter(function(p)
              return p.enum_variant == perk.resource
                and p.rest_type == rest_type
            end)
            :map(function(p) return p.codename, p.amount end)
            :tomap()
        end)
        :reduce(Table.extend, base[rest_type])
    end,
  }
end

return class
