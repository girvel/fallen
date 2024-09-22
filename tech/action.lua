local translation = require("tech.translation")


local action, module_mt, static = Module("tech.action")

local get_periodization

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

      local cost = Table.extend({}, self.cost)
      if next(cost) then
        local postfix
        local unique_resource = cost[self.codename]
        if unique_resource then
          cost[self.codename] = nil
          postfix = get_periodization(entity, self.codename, unique_resource)
        end

        local cost_repr
        if next(cost) then
          cost_repr = table.concat(Fun.pairs(cost)
            :map(function(k, v) return "%s: %s" % {translation.resources[k], v} end)
            :totable(), ", ")
        end

        table.insert(result, Html.p {
          cost_repr or "",
          cost_repr and postfix and ", " or "",
          postfix or "",
        })
      end

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

local rest_kind_postfix = {
  move = "ход",
  short = "бой",
  long = "долгий отдых",
}

get_periodization = function(entity, resource_name, resource)
  for _, rest_kind in ipairs {"move", "short", "long"} do
    Log.trace(rest_kind)
    local resource_max = Log.trace(entity:get_resources(rest_kind))[resource_name]
    if resource_max then
      return "%s раз(а) за %s" % {
        math.floor(resource_max / resource), rest_kind_postfix[rest_kind]
      }
    end
  end
end

return action
