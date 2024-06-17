local line = function(state, line)
  state.player.hears = line
  while state.player.hears == line do coroutine.yield() end
end

return {
  scenes = {
    {
      name = "Introduction",
      enabled = true,
      start_predicate = function() return true end,

      run = function(self, rails, state)
        self.enabled = false
        state.camera.position = Log.trace(state.player.position * state.CELL_DISPLAY_SIZE) - Log.trace(Vector({love.graphics.getWidth(), love.graphics.getHeight()}) / 2 / state.SCALING_FACTOR)
        line(state, "Ты оказываешься в потусторонне-мрачной комнате.")
        line(state, "Ты не совсем уверен, что такое “ты” и как именно ты здесь оказался.")
        line(state, "Вроде бы у тебя была какая-то цель.")
      end,
    },
    {
      name = "Door opens",
      enabled = true,

      start_predicate = function(self, rails)
        return not rails.entities.door.is_open and Fun.iter(rails.entities.levers)
          :enumerate()
          :map(function(i, lever) return lever.is_on and math.pow(2, 4 - i) or 0 end)
          :sum() == 13
      end,

      run = function(self, rails)
        self.enabled = false
        rails.entities.door:open()
      end,
    },
  },

  active_coroutines = {},

  initialize = function(self, state)
    self.entities = {
      door = state.grids.solids[Vector({21, 13})],
      levers = Fun.iter({15, 16, 17, 18})
        :map(function(x) return state.grids.solids[Vector({x, 17})] end)
        :totable()
    }
  end,

  update = function(self, state, event)
    self.active_coroutines = Fun.iter(self.active_coroutines)
      :chain(Fun.iter(self.scenes)
        :filter(function(s) return s.enabled and s:start_predicate(self, state) end)
        :map(function(s)
          Log.info("Scene `" .. s.name .. "` starts")
          return coroutine.create(function()
            s:run(self, state)
            Log.info("Scene `" .. s.name .. "` ends")
          end)
        end)
      )
      :filter(function(c)
        coroutine.resume(c)
        return coroutine.status(c) ~= "dead"
      end)
      :totable()
  end,
}
