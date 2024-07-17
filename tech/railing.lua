local railing = {api = {}}

railing.api.narration = function(text)
  State.gui.dialogue:show(text)
  while State:get_mode() == "dialogue" do coroutine.yield() end
end

railing.api.line = function(entity, text)
  -- TODO get color back
  railing.api.narration(Common.get_name(entity) .. ": " .. text)
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

railing.api.options = function(options)
  State.player.selected_option_i = nil
  State.player.dialogue_options = Tablex.extend({current_i = 1}, options)
  while not State.player.selected_option_i do coroutine.yield() end
  return State.player.selected_option_i
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
