local perk = require("mech.perk")


local class = {}

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
        :reduce(Tablex.concat, {})
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
        :reduce(Tablex.extend, {})
    end,
  }
end

return class
