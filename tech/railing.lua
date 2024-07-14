local railing = {api = {}}

railing.api.narration = function(text)
  State.player.hears = text
  while State.player.hears == text do coroutine.yield() end
end

railing.api.line = function(entity, text)
  railing.api.narration({entity.sprite.color, (entity.name or "?") .. ": ", {1, 1, 1}, text})
end

railing.api.wait_seconds = function(s)
  local t = love.timer.getTime()
  while love.timer.getTime() - t < s do coroutine.yield() end
end

railing.api.center_camera = function()
  State.camera.position = (
    State.player.position * State.CELL_DISPLAY_SIZE
    - Vector({love.graphics.getWidth(), love.graphics.getHeight()}) / 2 / State.SCALING_FACTOR
  )
end

railing.mixin = function()
  return {
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
          Common.resume_logged(c)
          return coroutine.status(c) ~= "dead"
        end)
        :totable()
    end,
  }
end

return railing
