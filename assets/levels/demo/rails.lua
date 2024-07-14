local actions = require("core.actions")
local railing = require("tech.railing")
local api = railing.api


return Tablex.extend(railing.mixin(), {
  scenes = {
    {
      name = "Second rotates the valve",
      enabled = true,
      start_predicate = function(self, _, dt) return Common.period(self, 30, dt) end,

      run = function(self, rails, dt)
        if not State:exists(rails.entities[2])
          or rails.entities[2].position ~= rails.positions[2]
        then
          self.enabled = false
          return
        end

        rails.entities[2].direction = "down"
        actions.interact(rails.entities[2])
      end,
    },
    {
      name = "Talking to the first",
      enabled = true,
      start_predicate = function(self, rails, dt)
        return rails.entities[1].talking_to == State.player
      end,

      run = function(self, rails, dt)
        rails.entities[1].talking_to = nil

        api.narration("Когда вы подходите ближе, измазанный сажей полуэльф всё так же не оборачивается.")
        api.narration("Его глаза, не отрываясь, смотрят прямо на приборы.")
        api.narration("Полуповисшая рука мертвой хваткой сжимает газовый ключ.")
        while true do
          local picked_option = api.options({
            "Какую работу ты выполняешь?",
            "Наблюдал что-то необычное в последнее время?",
            "Подозреваешь кого-то в этой комнате?",
            "*Уйти*",
          })
          if picked_option == 1 then
            api.line(rails.entities[1], "Главный инженер")
            api.line(rails.entities[1], "Моя работа - наблюдать за приборами")
            api.line(rails.entities[1], "В данный момент слежу за показателями давления")
          elseif picked_option == 2 then
            api.line(rails.entities[1], "Наблюдать могу только оборудование")
            api.line(rails.entities[1], "Но слышал громкий звук удара по металлу")
            api.line(rails.entities[1], "Несколько раз")
            api.line(rails.entities[1], "Потом крик")
            api.line(rails.entities[1], "Ещё громкий звук пара")
            api.line(rails.entities[1], "Несколько раз")
          elseif picked_option == 3 then
            api.line(rails.entities[1], "Я не знаю")
          elseif picked_option == 4 then
            break
          end
        end
        Log.trace()
      end,
    }
  },

  active_coroutines = {},

  initialize = function(self)
    self.positions = {
      [2] = Vector({5, 8})
    }

    self.entities = {
      State.grids.solids[Vector({7, 9})],
      State.grids.solids[self.positions[2]],
    }

    self.entities[1]:animate("holding")
    self.entities[1].animation.paused = true
  end,
})
