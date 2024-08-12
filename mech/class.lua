local perk = require("mech.perk")
local mech = require("mech")


local class, _, static = Module("mech.class")

class.get_choices = function(progression_table, level)
  return Fun.iter(progression_table)
    :take_n(level)
    :map(function(perks)
      return Fun.iter(perks)
        :filter(function(p) return p.enum_variant == perk.choice end)
        :totable()
    end)
    :reduce(Tablex.concat, {})
end

class.hit_dice_action = {
  codename = "hit_dice_action",
  get_availability = function(self, entity)
    return entity.hp < entity:get_max_hp()
      and entity.resources.hit_dice > 0
  end,
  _run = function(self, entity)
    entity.resources.hit_dice = entity.resources.hit_dice - 1
    entity.hp = math.min(
      entity:get_max_hp(),
      entity.hp + (D(entity.class.hp_die) + mech.get_modifier(entity.abilities.con)):roll()
    )
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
        :reduce(Tablex.concat, {class.hit_dice_action})
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
        :reduce(Tablex.concat, {})
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
        :reduce(Tablex.extend, base[rest_type])
    end,
  }
end

return class
