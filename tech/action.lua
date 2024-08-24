local action, module_mt, static = Module("tech.action")

module_mt.__call = function(_, base_table)
  return Table.extend(base_table, {
    get_availability = function(self, entity)
      return (not self._get_availability or self:_get_availability(entity))
        and Fun.iter(self.cost or {})
          :all(function(k, v) return entity.resources[k] >= v end)
    end,
    run = function(self, entity)
      if not self:get_availability(entity) then return end
      for k, v in pairs(self.cost or {}) do
        entity.resources[k] = entity.resources[k] - v
      end
      return self:_run(entity)
    end,
  })
end

return action
