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
      do return end  -- TODO! RM
      if State.combat then return end

      local ffi = require("ffi")
      local self = entity.ai

      if not self._travel_points then
        self._travel_points = Fun.iter(travel_points)
          :map(function(p) return assert(State.rails.positions[p]) end)
          :totable()
      end

      local target = self._travel_points[1]
      if entity.position == target then
        return
      end

      if not self._last_path then
        local w, h = unpack(State.grids.solids.size)
        local map = Tcod.TCOD_map_new(w, h)
        for x = 1, w do
          for y = 1, h do
            local e = State.grids.solids:fast_get(x, y)
            Tcod.TCOD_map_set_properties(
              map, x - 1, y - 1, Common.bool(not e or e.transparent_flag), not e
            )
          end
        end
        local raw_path = Tcod.TCOD_path_new_using_map(map, 0)
        local ox, oy = unpack(entity.position - Vector.one)
        local dx, dy = unpack(target - Vector.one)
        Tcod.TCOD_path_compute(raw_path, ox, oy, dx, dy)

        self._last_path = {}
        for i = 0, Tcod.TCOD_path_size(raw_path) - 1 do
          local xp = ffi.new("int[1]")
          local yp = ffi.new("int[1]")
          Tcod.TCOD_path_get(raw_path, i, xp, yp)
          table.insert(self._last_path, Vector {xp[0], yp[0]} + Vector.one)
        end
      end

      if not api.move(entity, self._last_path[self._next_path_i] - entity.position) then
        return
      end
      self._next_path_i = self._next_path_i + 1
    end, true),
  }
end

return markiss
