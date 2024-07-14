local actions = require("core.actions")


local narration = function(text)
  State.player.hears = text
  while State.player.hears == text do coroutine.yield() end
end

local line = function(entity, text)
  narration({entity.sprite.color, (entity.name or "?") .. ": ", {1, 1, 1}, text})
end

local wait_seconds = function(s)
  local t = love.timer.getTime()
  while love.timer.getTime() - t < s do coroutine.yield() end
end

local center_camera = function()
  State.camera.position = (
    State.player.position * State.CELL_DISPLAY_SIZE
    - Vector({love.graphics.getWidth(), love.graphics.getHeight()}) / 2 / State.SCALING_FACTOR
  )
end

return {
  scenes = {
    {
      name = "Second rotates the valve",
      enabled = true,
      start_predicate = function(self, _, dt) return Common.period(self, 30, dt) end,

      run = function(self, rails, dt)
        rails.entities.second.direction = "down"
        actions.interact(rails.entities.second)
      end,
    },
  },

  active_coroutines = {},

  initialize = function(self)
    self.entities = {
      second = State.grids.solids[Vector({5, 8})],
    }
  end,

  update = function(self, event)
    local dt = event[1]
    self.active_coroutines = Fun.iter(self.active_coroutines)
      :chain(Fun.iter(pairs(self.scenes))
        :filter(function(s) return s.enabled and s:start_predicate(self, dt) end)
        :map(function(s)
          Log.info("Scene `" .. s.name .. "` starts")
          return coroutine.create(function()
            s:run(self, dt)
            Log.info("Scene `" .. s.name .. "` ends")
          end)
        end)
      )
      :filter(function(c)
        local success, message = coroutine.resume(c)
        if not success then
          Log.error("Coroutine error: " .. message .. "\n" .. debug.traceback(c))
        end
        return coroutine.status(c) ~= "dead"
      end)
      :totable()
  end,
}
