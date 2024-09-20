local action, module_mt, static = Module("tech.action")

module_mt.__call = function(_, base_table)
  return Table.extend({
    get_availability = function(self, entity)
      return (not self._get_availability or self:_get_availability(entity))
        and Fun.iter(self.cost or {})
          :all(function(k, v) return (entity.resources[k] or 0) >= v end)
    end,

    run = function(self, entity)
      if not self:get_availability(entity) then return end
      for k, v in pairs(self.cost or {}) do
        entity.resources[k] = entity.resources[k] - v
      end
      return self:_run(entity)
    end,

    get_description = function(self, entity)
      local result = {}

      table.insert(result, -Query(self):_get_description(entity))
      -- TODO! cost

      if #result > 0 then
        return Html.span(Fun.iter(result)
          :map(function(e) return Html.p {e} end)
          :totable())
      end
    end
  }, base_table)
end

action.descriptions = {}

action.descriptions.healing = function(self)
  return Html.stats {
    "Восстанавливает ", self:get_healing_roll(State.player), " здоровья"
  }
end

return action
