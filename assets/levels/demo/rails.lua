local sfx = require("library.sfx")
local turn_order = require("tech.turn_order")
local core = require("core")


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
      name = "Introduction",
      enabled = true,
      start_predicate = function() return true end,

      run = function(self, rails)
        self.enabled = false
        center_camera()
        narration("Ты оказываешься в потусторонне-мрачной комнате.")
        narration("Ты не совсем уверен, что такое “ты” и как именно ты здесь оказался.")
        narration("Вроде бы у тебя была какая-то цель.")
      end,
    },
    {
      name = "Player comes to the door",
      enabled = true,

      start_predicate = function(self, rails)
        return not rails.entities.door.is_open and State.player.position == Vector({20, 13})
      end,

      run = function(self, rails)
        self.enabled = false
        narration("Тяжёлая дубовая дверь заперта.")
      end,
    },
    {
      name = "Player comes to the scripture",
      enabled = true,

      start_predicate = function(self, rails)
        return State.player.position == Vector({17, 12})
      end,

      run = function(self, rails)
        self.enabled = false
        narration("Надпись на полу как будто бы выжжена в дереве.")
        narration("Почерк выглядит знакомым.")
      end,
    },
    {
      name = "Player comes to the levers",
      enabled = true,

      start_predicate = function(self, rails)
        return Fun.iter(rails.entities.levers)
          :any(function(l) return (l.position - State.player.position):abs() == 1 end)
      end,

      run = function(self, rails)
        self.enabled = false
        narration("Древний механизм из каменных рычагов и шестерней.")
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
        Fun.iter(rails.entities.levers):each(function(l)
          if l._highlight then
            State:remove(l._highlight)
            l._highlight = nil
          end
        end)
      end,
    },
    outside_the_room = {
      name = "Player left the room -- testing point",
      enabled = false,

      start_predicate = function() return true end,
      run = function(self, rails)
        self.enabled = false
        State.player.position = Vector({23, 13})
      end
    },
    {
      name = "Player leaves the starting room",
      enabled = true,

      start_predicate = function(self, rails)
        return State.player.position == Vector({22, 13})
      end,

      run = function(self, rails)
        self.enabled = false
        narration("Ты стоишь посреди бескрайнего тёмного пространства.")
        narration("Здесь нет ни неба, ни земли, ни горизонта.")
        narration("Тусклый пурпурный свет равномерно покрывает твоё тело.")
        narration("Здесь не темно; здесь просто ничего нет.")
        line(State.player, "Ну, по крайней мере я знаю, что я не в реальности.")
        narration("Единственный новый объект посреди черноты — ещё одно здание на некотором " ..
          "расстоянии впереди."
        )
      end,
    },
    {
      name = "Player encounters the edge of the world",
      enabled = true,

      start_predicate = function(self, rails)
        return (
             State.player.position[1] == 1
          or State.player.position[2] == 1
          or State.player.position[1] == State.grids.solids.size[1]
          or State.player.position[2] == State.grids.solids.size[2]
        )
      end,

      run = function(self, rails)
        self.enabled = false
        narration("У тёмного мира всё-таки есть граница; она невидима, неосязаема и даже в какой-то степени непостижима.")
        narration("Единственный признак того, что она существует — движение в эту сторону перестало иметь любой эффект; можно переставлять ноги сколько угодно, но все видимые объекты остаются ровно на той же дистанции.")
        narration("С другой стороны, ты точно выяснил что-то новое: границы этого места кажутся прямоугольными.")
        narration("Может быть, оно рукотворно?")
      end,
    },
    {
      name = "Gymnasium's yard",
      enabled = true,

      start_predicate = function(self, rails)
        return State.player.position[1] == 47
      end,

      run = function(self, rails)
        self.enabled = false
        narration("Внутренний двор гимназии.")
        narration("Шепчущаяся толпа кадетов выстроилась вокруг небольшой песчаной дорожки.")
        line(rails.entities.teacher, "Пара — на позиции!")
        rails.entities.gym_key_point = State:add(Tablex.extend(sfx.highlight(), {position = Vector({57, 13})}))
      end,
    },
    {
      name = "Start the fight",
      enabled = true,

      start_predicate = function(self, rails)
        return (
          rails.entities.gym_key_point
          and State.player.position == rails.entities.gym_key_point.position
        )
      end,

      run = function(self, rails)
        self.enabled = false
        State:remove(rails.entities.gym_key_point)
        narration("Горячий песок.")
        narration("Дрожь в коленях.")
        narration("Тяжесть клинка.")
        line(rails.entities.first, "Тебе конец.")
        line(rails.entities.teacher, "Ан гард!")

        local initiative_rolls = Fun.iter({State.player, rails.entities.first})
          :map(function(e) return {e, (D(20) + core.get_modifier(e.abilities.dexterity)):roll()} end)
          :totable()

        table.sort(
          initiative_rolls,
          function(a, b) return a[2] > b[2] end
        )

        local pure_order = Fun.iter(initiative_rolls)
          :map(function(x) return x[1] end)
          :totable()

        State.move_order = turn_order(pure_order)

        rails.scenes.yard_fight_bounds.enabled = true
      end,
    },
    yard_fight_bounds = {
      name = "Player goes out of bounds",
      enabled = false,

      start_predicate = function(self, rails)
        return (
             State.player.position[1] < 56
          or State.player.position[1] > 64
          or State.player.position[2] < 12
          or State.player.position[2] > 14
        )
      end,

      run = function(self, rails)
        State.move_order = nil
        self.enabled = false
        narration("Твой оппонент довольно ухмыляется.")
        line(rails.entities.teacher, "Выход за пределы поля, победил Первый.")
        narration("“Первый” это странное имя.")
        rails.scenes.yard_ending.enabled = true
      end,
    },
    player_wins_yard_fight = {
      name = "Player wins the yard fight",
      enabled = true,

      start_predicate = function(self, rails)
        return rails.entities.first.hp <= 0
      end,

      run = function(self, rails)
        State.move_order = nil
        self.enabled = false
        rails.scenes.player_loses_yard_fight.enabled = false
        rails.scenes.yard_fight_bounds.enabled = false
        rails.entities.first:animate("defeat")
        rails.entities.first.animation.paused = true
        line(rails.entities.first, "Ты никому не нравишься.")
        line(rails.entities.teacher, "Капитуляция, победил Марвин.")
        narration("Ты почти уверен, что тебя зовут не Марвин.")
        rails.scenes.yard_ending.enabled = true
      end,
    },
    player_loses_yard_fight = {
      name = "Player loses the yard fight",
      enabled = true,

      start_predicate = function(self, rails)
        return State.player.hp <= 0
      end,

      run = function(self, rails)
        State.move_order = nil
        self.enabled = false
        rails.scenes.player_wins_yard_fight.enabled = false
        rails.scenes.yard_fight_bounds.enabled = false
        line(rails.entities.first, "Это было жалко.")
        line(rails.entities.teacher, "Капитуляция, победил Первый.")
        narration("“Первый” это странное имя.")
        rails.scenes.yard_ending.enabled = true
      end,
    },
    yard_ending = {
      name = "Yard ending",
      enabled = false,
      start_predicate = function() return true end,

      run = function(self, rails)
        self.enabled = false
        rails.entities.first.animation.paused = false
        Fun.chain(rails.entities.kids, {rails.entities.first, rails.entities.teacher})
          :each(function(e)
            e:animate("disappear")
            e:when_animation_ends(function()
              State:remove(e)
            end)
          end)

        wait_seconds(3)
        narration("Необычно.")
        narration("Было похоже на сцену, разыгранную специально для тебя.")

        wait_seconds(5)
        narration("~КОНЕЦ КОНТЕНТА В ОСНОВНОЙ КВЕСТОВОЙ ЦЕПОЧКЕ~")
      end,
    },
  },

  active_coroutines = {},

  initialize = function(self)
    self.entities = {
      door = State.grids.solids[Vector({21, 13})],
      levers = Fun.iter({15, 16, 17, 18})
        :map(function(x) return State.grids.solids[Vector({x, 17})] end)
        :totable(),
      kids = Fun.iter(pairs(State.grids.solids._inner_array))
        :filter(function(k) return k.code_name == "kid" end)
        :totable(),
      first = Fun.iter(pairs(State.grids.solids._inner_array))
        :filter(function(k) return k.code_name == "first" end)
        :nth(1),
      teacher = Fun.iter(pairs(State.grids.solids._inner_array))
        :filter(function(k) return k.code_name == "teacher" end)
        :nth(1),
    }

    Fun.iter(self.entities.kids)
      :filter(function(k) return k.position[2] > 13 end)
      :each(function(k) k.direction = "up" end)
  end,

  update = function(self, event)
    self.active_coroutines = Fun.iter(self.active_coroutines)
      :chain(Fun.iter(pairs(self.scenes))
        :filter(function(s) return s.enabled and s:start_predicate(self) end)
        :map(function(s)
          Log.info("Scene `" .. s.name .. "` starts")
          return coroutine.create(function()
            s:run(self)
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
