local common = require("utils.common")


local line = function(state, line)
  state.player.hears = line
  while state.player.hears == line do coroutine.yield() end
end

local center_camera = function(state)
  state.camera.position = (
    state.player.position * state.CELL_DISPLAY_SIZE
    - Vector({love.graphics.getWidth(), love.graphics.getHeight()}) / 2 / state.SCALING_FACTOR
  )
end

return {
  scenes = {
    {
      name = "Introduction",
      enabled = true,
      start_predicate = function() return true end,

      run = function(self, rails, state)
        self.enabled = false
        center_camera(state)
        line(state, "Ты оказываешься в потусторонне-мрачной комнате.")
        line(state, "Ты не совсем уверен, что такое “ты” и как именно ты здесь оказался.")
        line(state, "Вроде бы у тебя была какая-то цель.")
      end,
    },
    {
      name = "Player comes to the door",
      enabled = true,

      start_predicate = function(self, rails, state)
        return not rails.entities.door.is_open and state.player.position == Vector({20, 13})
      end,

      run = function(self, rails, state)
        self.enabled = false
        line(state, "Тяжёлая дубовая дверь заперта.")
      end,
    },
    {
      name = "Player comes to the scripture",
      enabled = true,

      start_predicate = function(self, rails, state)
        return state.player.position == Vector({17, 12})
      end,

      run = function(self, rails, state)
        self.enabled = false
        line(state, "Надпись на полу как будто бы выжжена в камне.")
        line(state, "Почерк выглядит знакомым.")
      end,
    },
    {
      name = "Player comes to the levers",
      enabled = true,

      start_predicate = function(self, rails, state)
        return Fun.iter(rails.entities.levers)
          :any(function(l) return (l.position - state.player.position):abs() == 1 end)
      end,

      run = function(self, rails, state)
        self.enabled = false
        line(state, "Древний механизм из каменных рычагов и шестерней.")
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
    outside_the_room = {
      name = "Player left the room -- testing point",
      enabled = false,

      start_predicate = function() return true end,
      run = function(self, rails, state)
        self.enabled = false
        state.player.position = Vector({23, 13})
      end
    },
    {
      name = "Player leaves the starting room",
      enabled = true,

      start_predicate = function(self, rails, state)
        return state.player.position == Vector({22, 13})
      end,

      run = function(self, rails, state)
        self.enabled = false
        line(state, "Ты стоишь посреди бескрайнего тёмного пространства.")
        line(state, "Здесь нет ни неба, ни земли, ни горизонта.")
        line(state, "Здесь не темно — тусклый пурпурный свет равномерно покрывает твоё тело — здесь просто ничего нет.")
        line(state, {
          common.hex_color("c0edef"), "Протагонист: ",
          {1, 1, 1}, "Ну, по крайней мере я знаю, что я не в реальности.",
        })
        line(state,
          "Единственный новый объект посреди черноты — ещё одно разрушенное здание на некотором " ..
          "расстоянии впереди."
        )
      end,
    },
    {
      name = "Player encounters the edge of the world",
      enabled = true,

      start_predicate = function(self, rails, state)
        return (
             state.player.position[1] == 1
          or state.player.position[2] == 1
          or state.player.position[1] == state.grids.solids.size[1]
          or state.player.position[2] == state.grids.solids.size[2]
        )
      end,

      run = function(self, rails, state)
        self.enabled = false
        line(state, "У тёмного мира есть граница; она невидима, неосязаема и даже в какой-то степени непостижима.")
        line(state, "Единственный признак того, что она существует — движение в эту сторону перестало иметь любой эффект; можно переставлять ноги сколько угодно, но все видимые объекты остаются ровно на той же дистанции.")
        line(state, "С другой стороны, ты точно выяснил что-то новое: границы этого места кажутся прямоугольными.")
        line(state, "Может быть, оно рукотворно?")
      end,
    },
  },

  active_coroutines = {},

  initialize = function(self, state)
    self.entities = {
      door = state.grids.solids[Vector({21, 13})],
      levers = Fun.iter({15, 16, 17, 18})
        :map(function(x) return state.grids.solids[Vector({x, 17})] end)
        :totable(),
      kids = Fun.iter(pairs(state.grids.solids._inner_array))
        :filter(function(k) return k.name == "ребёнок" end)
        :totable(),
    }

    Fun.iter(self.entities.kids)
      :filter(function(k) return k.position[2] > 13 end)
      :each(function(k) k.direction = "up" end)
  end,

  update = function(self, state, event)
    self.active_coroutines = Fun.iter(self.active_coroutines)
      :chain(Fun.iter(pairs(self.scenes))
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
