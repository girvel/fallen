local tcod = require("tech.tcod")
local ai = require("tech.ai")
local api = ai.api


local markiss, module_mt, static = Module("library.ais.markiss")

module_mt.__call = function(_, travel_points)
  assert(#travel_points > 1)

  return {
    initialize = nil,  -- TODO ai.initialize

    _travel_points = nil,
    _last_path = nil,
    _next_path_i = 1,

    run = ai.async(function(entity, dt)
      if State.combat then return end
      local self = entity.ai

      if not self._travel_points then
        self._travel_points = Fun.iter(travel_points)
          :map(function(p) return assert(State.rails.positions[p]) end)
          :totable()
      end

      local target = self._travel_points[1]
      if not self._last_path then
        self._last_path = tcod.snapshot():find_path(entity.position, target)
      end

      if self._next_path_i > #self._last_path then
        return
      end

      if not api.move(entity, self._last_path[self._next_path_i] - entity.position) then
        return
      end
      self._next_path_i = self._next_path_i + 1
    end, true),
  }
end

return markiss
