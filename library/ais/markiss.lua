local tcod = require("tech.tcod")
local ai = require("tech.ai")
local railing = require("tech.railing")
local api = ai.api


local markiss, module_mt, static = Module("library.ais.markiss")

markiss.mode = Enum {
  paused = {"duration"},
  looping = {},
}

module_mt.__call = function(_, travel_points)
  assert(#travel_points > 1)

  return {
    _mode = markiss.mode.looping(),

    _travel_points = nil,
    _last_path = nil,
    _next_path_i = 1,

    initialize = function(entity)
      local self = entity.ai

      self._travel_points = Fun.iter(travel_points)
        :map(function(p) return assert(State.rails.positions[p]) end)
        :totable()
    end,

    run = ai.async(function(entity, dt)
      if State.combat then return end
      local self = entity.ai
      return self._modal_behaviours[self._mode.codename](entity)
    end, true),

    _modal_behaviours = {
      looping = function(entity)
        local self = entity.ai

        if not self._last_path then
          self._last_path = tcod.snapshot():find_path(entity.position, self._travel_points[1])
          Log.trace(entity.position, self._last_path)
        end

        if self._next_path_i > #self._last_path then
          return
        end

        if not api.move(entity, self._last_path[self._next_path_i] - entity.position) then
          self._last_path = nil
          self._next_path_i = 1
          self._mode = markiss.mode.paused(1)
          return
        end
        self._next_path_i = self._next_path_i + 1

        if Random.chance(.05) then
          self._mode = markiss.mode.paused(math.random(1, 5))
        end
      end,

      paused = function(entity)
        local self = entity.ai
        railing.api.wait_seconds(self._mode.duration)
        self._mode = markiss.mode.looping()
      end,
    },
  }
end

return markiss
