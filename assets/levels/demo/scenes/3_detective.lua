local api = require("tech.railing").api
local actions = require("mech.creature.actions")
local random = require("utils.random")
local level = require("tech.level")


return function()
  return {
    checkpoint_3 = {
      name = "Checkpoint (3)",
      enabled = false,
      start_predicate = function(self, rails, dt)
        return true
      end,

      run = function(self, rails, dt)
        self.enabled = false
        level.move(State.grids.solids, State.player, Vector({20, 56}))
        State.gui.wiki.quests_states.detective = 1
      end,
    },
    {
      name = "Player enters the detective room",
      enabled = true,
      start_predicate = function(self, rails, dt)
        return State.player.position == rails.positions.exit
      end,

      run = function(self, rails, dt)
        self.enabled = false
        rails.entities.leaking_valve.paused = true
        api.center_camera()
        State.player.in_cutscene = true

        api.narration("Резкий запах мазута, керосина и ржавчины заставляет зажмуриться.")
        api.narration("Помещение забито трубами и приборами непонятного назначения.")
        api.narration("Три фигуры в защитных спецовках резко оборачиваются в твою сторону и так же быстро возвращаются к работе.")
        api.narration("А вот ближайший к тебе рабочий - полуэльф, похоже не замечает твоего присутствия")
        api.narration("Он лишь пялится на непонятные устройства и раз в несколько секунд выкрикивает странный набор звуков и чисел.")
        api.line(State.player, "(Диверсант - один из четырёх рабочих)")
        api.line(State.player, "(Я смогу вычислить его из показаний остальных)")
        api.line(State.player, "(Надо начать с допроса)")
        api.line(State.player, "(Надеюсь, они видели или слышали что-то необычное)")

        rails.entities.leaking_valve.paused = false
        rails.entities.leaking_valve:burst_with_steam()
        api.narration("Мощный поток горячего пара от ближайшей трубы прерывает твои мысли")
        State.player.in_cutscene = false
      end,
    },
    {
      name = "Player gets notification after entering detective room",
      enabled = true,
      start_predicate = function(self, rails, dt)
        return State.player.position == rails.positions.detective_notification_activation
      end,

      run = function(self, rails, dt)
        self.enabled = false
        api.notification("вычисли и устрани диверсанта", true)
        State.gui.wiki.quests_states.detective = 2
      end,
    },
    second_rotates_valve = {
      name = "Second rotates the valve",
      enabled = true,
      start_predicate = function(self, _, dt) return Common.relative_period(30, dt, self) end,

      run = function(self, rails, dt)
        if not State:exists(rails.entities[2])
          or rails.entities[2].position ~= rails.positions[2]
        then
          self.enabled = false
          return
        end

        rails.entities[2]:rotate("down")
        rails.entities[2]:act(actions.interact)
      end,
    },
    {
      name = "Lead engineer shouts",
      enabled = true,
      start_predicate = function(self, rails, dt)
        return Common.relative_period(40, dt, self)
      end,

      run = function(self, rails, dt)
        self.enabled = false
        State.gui.popup:show(
          rails.entities[1].position, "above",
          random.choice({
            "УКС " .. math.random(15, 27) / 10,
            "ДО " .. math.random(40, 80),
            "МПА " .. math.random(26, 52) / 10,
            "ТМ " .. math.random(197, 310),
            "К 3, СПК",
          })
        )
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

        State.player.in_cutscene = true
        api.narration("Когда ты подходишь ближе, измазанный сажей полуэльф всё так же не оборачивается.")
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
        rails.dreamers_talked_to[1] = true
        State.player.in_cutscene = false
      end,
    },
    {
      name = "Talking to the second",
      enabled = true,
      start_predicate = function(self, rails, dt)
        return rails.entities[2].talking_to == State.player
      end,

      run = function(self, rails, dt)
        rails.entities[2].talking_to = nil
        local old_direction = rails.entities[2].direction
        rails.entities[2]:rotate(Vector.name_from_direction(
          State.player.position - rails.entities[2].position
        ))
        rails.entities[2]:animate()

        State.player.in_cutscene = true
        api.narration("Уродливый полурослик с перевязанным лицом делает один оборот массивного красного вентиля.")
        api.narration("А спустя 10 секунд - ещё один.")
        api.narration("И снова.")
        api.narration("Похоже, свежие ожоги от пара не стимулируют его остановиться.")
        api.narration("Некоторое время он, кажется, не замечает твоего приближения, но вскоре слегка оборачивается.")

        while true do
          local picked_option = api.options({
            "Какую работу ты выполняешь?",
            "Наблюдал что-то необычное в последнее время?",
            "Подозреваешь кого-то в этой комнате?",
            "*Уйти*",
          })
          if picked_option == 1 then
            api.line(rails.entities[2], "Инженер")
            api.line(rails.entities[2], "Моя работа - обслуживание оборудования")
            api.line(rails.entities[2], "В данный момент спускаю давление")
          elseif picked_option == 2 then
            api.line(rails.entities[2], "Наблюдаю больше давления")
            api.line(rails.entities[2], "Стало больше пара")
            api.line(rails.entities[2], "Уши плохо слышат")
            api.line(rails.entities[2], "Тело плохо отвечает")
          elseif picked_option == 3 then
            api.line(rails.entities[2], "Я не знаю")
          elseif picked_option == 4 then
            break
          end
        end
        rails.dreamers_talked_to[2] = true
        rails.entities[2]:rotate(old_direction)
        State.player.in_cutscene = false
      end,
    },
    {
      name = "Talking to the third",
      enabled = true,
      start_predicate = function(self, rails, dt)
        return rails.entities[3].talking_to == State.player
      end,

      run = function(self, rails, dt)
        rails.entities[3].talking_to = nil

        State.player.in_cutscene = true
        api.narration("Сутулый полуорк в ярко-жёлтых огнеупорных перчатках работает с незнакомым тебе устройством.")
        api.narration("Панель с множеством непонятных кнопок, рычагов и приборов серьёзно повреждена.")
        api.narration("Сталь вмята в нескольких местах, будто от сильных ударов, а счётчики скачут, как бесы на сковородке.")
        api.narration("Полуорк, не замечая повреждений, продолжает работать с неисправной машиной.")
        api.narration("С пустым взглядом он дергает за отсутствующие рычаги и нажимает на выбитые кнопки.")

        while true do
          local picked_option = api.options({
            "Какую работу ты выполняешь?",
            "Наблюдал что-то необычное в последнее время?",
            "Подозреваешь кого-то в этой комнате?",
            "*Уйти*",
          })
          if picked_option == 1 then
            api.line(rails.entities[3], "Инженер.")
            api.line(rails.entities[3], "Моя работа - обслуживать оборудование")
            api.line(rails.entities[3], "В данный момент работаю с машиной")
          elseif picked_option == 2 then
            api.line(rails.entities[3], "Был громкий шум")
            api.line(rails.entities[3], "Потом кто-то ударил")
            api.line(rails.entities[3], "Всё")
          elseif picked_option == 3 then
            api.line(rails.entities[3], "Не знаю")
          elseif picked_option == 4 then
            break
          end
        end
        rails.dreamers_talked_to[3] = true
        State.player.in_cutscene = false
      end,
    },
    {
      name = "Talking to the fourth",
      enabled = true,
      start_predicate = function(self, rails, dt)
        return rails.entities[4].talking_to == State.player
      end,

      run = function(self, rails, dt)
        rails.entities[4].talking_to = nil
        local old_direction = rails.entities[4].direction
        rails.entities[4]:rotate(Vector.name_from_direction(
          State.player.position - rails.entities[4].position
        ))
        rails.entities[4]:animate()

        State.player.in_cutscene = true
        api.narration("Дварфийка покрытыми волдырями руками засовывает вглубь небольшой печи очередную порцию чего-то, похожего на чёрную смолу.")
        api.narration("Ты замечаешь, что её пальцы совсем не могут двигаться.")
        api.narration("Она слегка оборачивается при твоем приближении, продолжая работать.")

        while true do
          local options = {
            "Какую работу ты выполняешь?",
            "Наблюдал что-то необычное в последнее время?",
            "Подозреваешь кого-то в этой комнате?",
            "*Уйти*",
          }

          if State.player.inventory.gloves == rails.entities.gloves then
            table.insert(options, 4, "*отдать перчатки*")
          end

          local picked_option = api.options(options)
          if picked_option == 1 then
            api.line(rails.entities[4], "Инженер")
            api.line(rails.entities[4], "Моя работа - обслуживать печь")
            api.line(rails.entities[4], "В данный момент добавляю больше топлива")
          elseif picked_option == 2 then
            api.line(rails.entities[4], "Стало горячо рукам")
            api.line(rails.entities[4], "Потом шум, но не настолько как горячо рукам")
          elseif picked_option == 3 then
            api.line(rails.entities[4], "Я не знаю")
          elseif picked_option == #options then
            break
          elseif picked_option == 4 then
            local gloves = State.player.inventory.gloves
            rails.entities[4].inventory.gloves = gloves
            State.player.inventory.gloves = nil

            api.narration("Дварфийка с пустым взглядом надевает перчатки на обожженные руки")
            api.line(rails.entities[4], "Благодарю")
            api.line(rails.entities[4], "Теперь смогу проработать дольше")
          end
        end
        rails.entities[4]:rotate(old_direction)
        rails.dreamers_talked_to[4] = true
        State.player.in_cutscene = false
      end,
    },

    talked_to_everybody = {
      name = "Player talked to all dreamers",
      enabled = true,
      start_predicate = function(self, rails)
        return Fun.range(4)
          :filter(function(i) return State:exists(rails.entities[i]) end)
          :all(function(i) return rails.dreamers_talked_to[i] end)
      end,
      run = function(self, rails)
        self.enabled = false
        api.discover_wiki({talked_to_dreamers = true})
      end,
    },
  }
end
