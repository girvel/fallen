local sfx = require("library.sfx")
local turn_order = require("tech.turn_order")
local creature = require("core.creature")


local line = function(state, line)
  state.player.hears = line
  while state.player.hears == line do coroutine.yield() end
end

local wait_seconds = function(s)
  local t = love.timer.getTime()
  while love.timer.getTime() - t < s do coroutine.yield() end
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
        line(state, "Надпись на полу как будто бы выжжена в дереве.")
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

      run = function(self, rails, state)
        self.enabled = false
        rails.entities.door:open()
        Fun.iter(rails.entities.levers):each(function(l)
          if l._highlight then
            state:remove(l._highlight)
            l._highlight = nil
          end
        end)
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
        line(state, "Тусклый пурпурный свет равномерно покрывает твоё тело.")
        line(state, "Здесь не темно; здесь просто ничего нет.")
        line(state, {
          Common.hex_color("c0edef"), "Протагонист: ",
          {1, 1, 1}, "Ну, по крайней мере я знаю, что я не в реальности.",
        })
        line(state,
          "Единственный новый объект посреди черноты — ещё одно здание на некотором " ..
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
        line(state, "У тёмного мира всё-таки есть граница; она невидима, неосязаема и даже в какой-то степени непостижима.")
        line(state, "Единственный признак того, что она существует — движение в эту сторону перестало иметь любой эффект; можно переставлять ноги сколько угодно, но все видимые объекты остаются ровно на той же дистанции.")
        line(state, "С другой стороны, ты точно выяснил что-то новое: границы этого места кажутся прямоугольными.")
        line(state, "Может быть, оно рукотворно?")
      end,
    },
    {
      name = "Gymnasium's yard",
      enabled = true,

      start_predicate = function(self, rails, state)
        return state.player.position[1] == 47
      end,

      run = function(self, rails, state)
        self.enabled = false
        line(state, "Внутренний двор гимназии.")
        line(state, "Шепчущаяся толпа кадетов выстроилась вокруг небольшой песчаной дорожки.")
        line(state, {Common.hex_color("60b37e"), "Тренер: ", {1, 1, 1}, "Пара — на позиции!"})
        rails.entities.gym_key_point = state:add(Tablex.extend(sfx.highlight(), {position = Vector({57, 13})}))
      end,
    },
    {
      name = "Start the fight",
      enabled = true,

      start_predicate = function(self, rails, state)
        return (
          rails.entities.gym_key_point
          and state.player.position == rails.entities.gym_key_point.position
        )
      end,

      run = function(self, rails, state)
        self.enabled = false
        state:remove(rails.entities.gym_key_point)
        line(state, "Горячий песок.")
        line(state, "Дрожь в коленях.")
        line(state, "Тяжесть клинка.")
        line(state, {Common.hex_color("e64e4b"), "Первый: ", {1, 1, 1}, "Тебе конец."})
        line(state, {Common.hex_color("60b37e"), "Тренер: ", {1, 1, 1}, "Ан гард!"})

        local initiative_rolls = Fun.iter({state.player, rails.entities.first})
          :map(function(e) return {e, (D(20) + creature.get_modifier(e.abilities.dexterity)):roll()} end)
          :totable()

        table.sort(
          initiative_rolls,
          function(a, b) return a[2] > b[2] end
        )

        local pure_order = Fun.iter(initiative_rolls)
          :map(function(x) return x[1] end)
          :totable()

        state.move_order = turn_order(pure_order)

        rails.scenes.yard_fight_bounds.enabled = true
      end,
    },
    yard_fight_bounds = {
      name = "Player goes out of bounds",
      enabled = false,

      start_predicate = function(self, rails, state)
        return (
             state.player.position[1] < 56
          or state.player.position[1] > 64
          or state.player.position[2] < 12
          or state.player.position[2] > 14
        )
      end,

      run = function(self, rails, state)
        state.move_order = nil
        self.enabled = false
        line(state, "Твой оппонент довольно ухмыляется.")
        line(state, {Common.hex_color("60b37e"), "Тренер: ", {1, 1, 1}, "Выход за пределы поля, победил Первый."})
        line(state, "“Первый” это странное имя.")
        rails.scenes.yard_ending.enabled = true
      end,
    },
    player_wins_yard_fight = {
      name = "Player wins the yard fight",
      enabled = true,

      start_predicate = function(self, rails, state)
        return rails.entities.first.hp <= 0
      end,

      run = function(self, rails, state)
        state.move_order = nil
        self.enabled = false
        rails.scenes.player_loses_yard_fight.enabled = false
        rails.scenes.yard_fight_bounds.enabled = false
        rails.entities.first:animate("defeat")
        rails.entities.first.animation.paused = true
        line(state, {Common.hex_color("e64e4b"), "Первый: ", {1, 1, 1}, "Ты никому не нравишься."})
        line(state, {Common.hex_color("60b37e"), "Тренер: ", {1, 1, 1}, "Капитуляция, победил Марвин."})
        line(state, "Ты почти уверен, что тебя зовут не Марвин.")
        rails.scenes.yard_ending.enabled = true
      end,
    },
    player_loses_yard_fight = {
      name = "Player loses the yard fight",
      enabled = true,

      start_predicate = function(self, rails, state)
        return state.player.hp <= 0
      end,

      run = function(self, rails, state)
        state.move_order = nil
        self.enabled = false
        rails.scenes.player_wins_yard_fight.enabled = false
        rails.scenes.yard_fight_bounds.enabled = false
        line(state, {Common.hex_color("e64e4b"), "Первый: ", {1, 1, 1}, "Это было жалко."})
        line(state, {Common.hex_color("60b37e"), "Тренер: ", {1, 1, 1}, "Капитуляция, победил Первый."})
        line(state, "“Первый” это странное имя.")
        rails.scenes.yard_ending.enabled = true
      end,
    },
    yard_ending = {
      name = "Yard ending",
      enabled = false,
      start_predicate = function() return true end,

      run = function(self, rails, state)
        self.enabled = false
        rails.entities.first.animation.paused = false
        Fun.chain(rails.entities.kids, {rails.entities.first, rails.entities.teacher})
          :each(function(e)
            e:animate("disappear")
            e:when_animation_ends(function()
              state:remove(e)
            end)
          end)

        wait_seconds(3)
        line(state, "Необычно.")
        line(state, "Было похоже на сцену, разыгранную специально для тебя.")

        wait_seconds(5)
        line(state, "~КОНЕЦ КОНТЕНТА В ОСНОВНОЙ КВЕСТОВОЙ ЦЕПОЧКЕ~")
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
        :filter(function(k) return k.code_name == "kid" end)
        :totable(),
      first = Fun.iter(pairs(state.grids.solids._inner_array))
        :filter(function(k) return k.code_name == "first" end)
        :nth(1),
      teacher = Fun.iter(pairs(state.grids.solids._inner_array))
        :filter(function(k) return k.code_name == "teacher" end)
        :nth(1),
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
        local success, message = coroutine.resume(c)
        if not success then
          Log.trace("Coroutine error: " .. message .. "\n" .. debug.traceback(c))
        end
        return coroutine.status(c) ~= "dead"
      end)
      :totable()
  end,
}
