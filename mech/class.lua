local class = {}

class.perk = Enum({
  action = {"action"},
  resource = {"rest_type", "codename", "amount"},
})

class.mixin = function()
  return {
    get_actions = function(self, level)
      return Fun.iter(self.progression_table)
        :take_n(level)
        :map(function(perks)
          return Fun.iter(perks)
            :filter(function(perk) return perk.enum_variant == class.perk.action end)
            :map(function(perk) return perk.action end)
            :totable()
        end)
        :reduce(Tablex.concat, {})
    end,
    get_resources = function(self, level, rest_type)
      return Fun.iter(self.progression_table)
        :take_n(level)
        :map(function(perks)
          return Fun.iter(perks)
            :filter(function(perk)
              return perk.enum_variant == class.perk.resource
                and perk.rest_type == rest_type
            end)
            :map(function(perk) return perk.codename, perk.amount end)
            :tomap()
        end)
        :reduce(Tablex.extend, {})
    end,
  }
end

return class
