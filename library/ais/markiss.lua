local ai = require("tech.ai")
local api = ai.api


local markiss, module_mt, static = Module("library.ais.markiss")

markiss.mode = Enum {
  looping = {},
  paused = {},
}

module_mt.__call = function(_, travel_points)
  assert(#travel_points > 1)

  return {
    _points = nil,

    _mode = markiss.mode.looping(),

    _next_point_i = 1,
    _path = nil,

    initialize = nil,  -- TODO ai.initialize

    run = ai.async(function(entity, dt)
      -- local self = entity.ai

      -- if not self._points then
      --   self._points = Fun.iter(travel_points)
      --     :map(function(p) return assert(State.rails.positions[p]) end)
      --     :totable()
      -- end
      -- if State.combat then return end

      -- return self._modes[self._mode.codename](entity, dt)
    end, true),

    _pause_id = {},

    _modes = {
      looping = function(entity)
        local self = entity.ai

        if self._points[self._next_point_i] == self._position then
          self._next_point_i = self._next_point_i % #self._points + 1
          self._path = nil
        end

        if not self._path then
          self._path = State.grids.solids:find_path(
            entity.position, self._points[self._next_point_i], 100
          )
          self._path_i = 0
        end

        if self._path_i >= #self._path then
          self._path = nil
          Log.trace("PAUSED")
          self._mode = markiss.mode.paused()
          return
        end

        if api.move(entity, self._path[self._path_i + 1] - entity.position) then
          self._path_i = self._path_i + 1
        else
          self._path = nil
        end
      end,

      paused = function(entity)
        if Common.period(1, entity.ai._pause_id) then
          Log.trace("LOOPING")
          entity.ai._mode = markiss.mode.looping()
        end
      end,
    }
  }
end

return markiss
