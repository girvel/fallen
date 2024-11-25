local item = require("tech.item")
local pipes = require("library.palette.pipes")
local api = require("tech.railing").api
local actions = require("mech.creature.actions")
local level = require("state.level")
local items = require("library.palette.items")
local experience = require("mech.experience")


return function()
  return {
    checkpoint_3 = {
      name = "Checkpoint (3)",
      enabled = false,
      start_predicate = function(self, rails, dt)
        return true
      end,

      run = function(self, rails)
        self.enabled = false
        api.checkpoint_base()

        level.move(State.player, rails.positions.detective_exit_warning)
        api.update_quest({detective = 1})
        rails.entities.detective_door.locked = false

        State.player.experience = experience.for_level[3]
        State.gui.creator:refresh()
        State.gui.creator:submit()

        item.give(State.player, State:add(items.pole()))
        api.center_camera()

        rails.scenes.open_left_megadoor.enabled = true
      end,
    },

    detective_notification = {
      name = "Player gets notification after entering detective room",
      enabled = true,
      start_predicate = function(self, rails, dt)
        return rails.entities.detective_door.is_open
      end,

      run = function(self, rails)
        self.enabled = false
        api.notification("вычисли и устрани диверсанта", true)
        api.update_quest({detective = 2})
      end,
    },

    detective_intro = {
      name = "Player enters the detective room",
      enabled = true,
      start_predicate = function(self, rails, dt)
        return State.player.position == rails.positions.detective_exit
      end,

      run = function(self, rails)
        self.enabled = false
        rails.entities.leaking_valve.paused = true
        State.player.ai.in_cutscene = true

        api.narration("Мазут, ржавчина, керосин — резкое сочетание бьёт по ноздрям и глазам.")
        api.narration("Помещение забито трубами и чужеродными приборами.")
        rails:run_task(function()
          rails.entities.engineer_3:rotate("down")
          rails.entities.engineer_4:rotate("down")
          api.wait_seconds(2)
          rails.entities.engineer_3:rotate("up")
          rails.entities.engineer_4:rotate("up")
        end)
        api.narration("Фигуры в защитных робах резко оборачиваются в твою сторону и так же быстро возвращаются к работе.")
        api.narration("Все, кроме полуэльфа.")
        api.narration("Остроухий не обращает внимания на твоё вторжение.")
        api.narration("Он лишь пялится на непонятные устройства и раз в несколько секунд выкрикивает странный набор букв и цифр.")
        api.line(State.player, "(Дверь была наглухо заперта, диверсант не мог выйти)")
        api.line(State.player, "(А если здесь есть диверсант — должна быть диверсия)")
        api.line(State.player, "(Допрос прояснит ситуацию; лжецы всегда ошибаются, а непричастный не будет врать)")

        rails.entities.leaking_valve.paused = false
        pipes.burst_with_steam(rails.entities.leaking_valve)
        api.narration("Мощный поток горячего пара прерывает твои мысли.")
        State.player.ai.in_cutscene = false
        api.autosave()
      end,
    },

    {
      name = "Experiment",
      enabled = true,
      start_predicate = function(self, rails, dt)
        return not State:exists(rails.entities.device_panel)
      end,

      run = function(self, rails)
        self.enabled = false
        rails.entities.engineer_3:rotate("down")
        api.wait_seconds(0.5)
        rails.entities.engineer_3:rotate("up")
      end,
    },

    second_rotates_valve = {
      name = "Second rotates the valve",
      enabled = true,
      start_predicate = function(self, rails, dt)
        return not rails:is_running("detective_intro") and Common.relative_period(30, dt, self)
      end,

      run = function(self, rails)
        if not State:exists(rails.entities.engineer_2)
          or rails.entities.engineer_2.position ~= rails.positions.engineer_2
        then
          self.enabled = false
          return
        end

        rails.entities.engineer_2:rotate("down")
        rails.entities.engineer_2:act(actions.interact)
      end,
    },

    first_shouts = {
      name = "Lead engineer shouts",
      enabled = true,
      start_predicate = function(self, rails, dt)
        return Common.relative_period(40, dt, self)
          and State:exists(rails.entities.engineer_1)
      end,

      run = function(self, rails)
        api.message.temporal(Random.choice({
          "УКС " .. math.random(15, 27) / 10,
          "ДО " .. math.random(40, 80),
          "МПА " .. math.random(26, 52) / 10,
          "ТМ " .. math.random(197, 310),
          "К 3, СПК",
        }), {source = rails.entities.engineer_1})
      end,
    },

    {
      name = "Talking to the first",
      enabled = true,
      start_predicate = function(self, rails, dt)
        return rails.entities.engineer_1.interacted_by == State.player
      end,

      run = function(self, rails)
        rails.entities.engineer_1.interacted_by = nil

        State.player.ai.in_cutscene = true
        api.narration("Когда ты подходишь ближе, полуэльф всё так же не оборачивается.")
        api.narration("Его глаза, не отрываясь, смотрят прямо на приборы.")
        api.narration("Повисшая рука мертвой хваткой сжимает газовый ключ.")
        while true do
          local picked_option = api.options({
            "Какую работу ты выполняешь?",
            "Наблюдал что-то необычное в последнее время?",
            "Подозреваешь кого-то в этой комнате?",
            "*Уйти*",
          })
          if picked_option == 1 then
            api.line(rails.entities.engineer_1, "Главный инженер")
            api.line(rails.entities.engineer_1, "Моя работа — наблюдать за приборами, оповещать инженеров об их состояниях")
            api.line(rails.entities.engineer_1, "В данный момент слежу за показателями давления")
          elseif picked_option == 2 then
            api.line(rails.entities.engineer_1, "Наблюдать могу только оборудование")
            api.line(rails.entities.engineer_1, "Но слышал громкий звук удара по металлу")
            api.line(rails.entities.engineer_1, "Несколько раз")
            api.line(rails.entities.engineer_1, "Потом крик")
            api.line(rails.entities.engineer_1, "Ещё громкий звук пара")
            api.line(rails.entities.engineer_1, "Несколько раз")
          elseif picked_option == 3 then
            api.line(rails.entities.engineer_1, "Я не знаю")
          elseif picked_option == 4 then
            break
          end
        end
        rails.dreamers_talked_to[1] = true
        State.player.ai.in_cutscene = false
      end,
    },

    {
      name = "Talking to the second",
      enabled = true,
      start_predicate = function(self, rails, dt)
        return rails.entities.engineer_2.interacted_by == State.player
      end,

      run = function(self, rails)
        rails.entities.engineer_2.interacted_by = nil
        local old_direction = rails.entities.engineer_2.direction
        api.rotate_to_player(rails.entities.engineer_2)
        rails.entities.engineer_2:animate()

        State.player.ai.in_cutscene = true
        api.narration("Кривой полурослик делает один оборот массивного красного вентиля.")
        api.narration("А спустя 10 секунд — ещё один.")
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
            api.line(rails.entities.engineer_2, "Инженер")
            api.line(rails.entities.engineer_2, "Моя работа — обслуживание оборудования")
            api.line(rails.entities.engineer_2, "В данный момент спускаю давление")
          elseif picked_option == 2 then
            api.line(rails.entities.engineer_2, "Наблюдаю больше давления")
            api.line(rails.entities.engineer_2, "Стало больше пара")
            api.line(rails.entities.engineer_2, "Уши плохо слышат")
            api.line(rails.entities.engineer_2, "Тело плохо отвечает")
          elseif picked_option == 3 then
            api.line(rails.entities.engineer_2, "Я не знаю")
          elseif picked_option == 4 then
            break
          end
        end
        rails.dreamers_talked_to[2] = true
        rails.entities.engineer_2:rotate(old_direction)
        State.player.ai.in_cutscene = false
      end,
    },

    {
      name = "Talking to the third",
      enabled = true,
      start_predicate = function(self, rails, dt)
        return rails.entities.engineer_3.interacted_by == State.player
      end,

      run = function(self, rails)
        rails.entities.engineer_3.interacted_by = nil

        State.player.ai.in_cutscene = true
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
            api.line(rails.entities.engineer_3, "Инженер.")
            api.line(rails.entities.engineer_3, "Моя работа — обслуживать оборудование")
            api.line(rails.entities.engineer_3, "В данный момент работаю с машиной")
          elseif picked_option == 2 then
            api.line(rails.entities.engineer_3, "Был громкий шум")
            api.line(rails.entities.engineer_3, "Потом кто-то ударил")
            api.line(rails.entities.engineer_3, "Всё")
          elseif picked_option == 3 then
            api.line(rails.entities.engineer_3, "Не знаю")
          elseif picked_option == 4 then
            break
          end
        end
        rails.dreamers_talked_to[3] = true
        State.player.ai.in_cutscene = false
      end,
    },

    engineer_4_normal_dialogue = {
      name = "Talking to the fourth",
      enabled = true,
      start_predicate = function(self, rails, dt)
        return rails.entities.engineer_4.interacted_by == State.player
      end,

      run = function(self, rails)
        rails.entities.engineer_4.interacted_by = nil
        local old_direction = rails.entities.engineer_4.direction
        api.rotate_to_player(rails.entities.engineer_4)
        rails.entities.engineer_4:animate()

        State.player.ai.in_cutscene = true
        api.narration("Дварфийка покрытыми волдырями руками засовывает вглубь небольшой печи очередную порцию чёрной вязкой смолы.")
        api.narration("Ты замечаешь, что её пальцы совсем не могут двигаться.")
        api.narration("При твоем приближении она слегка оборачивается, не прекращая работать")

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
            api.line(rails.entities.engineer_4, "Инженер")
            api.line(rails.entities.engineer_4, "Моя работа — обслуживать печь")
            api.line(rails.entities.engineer_4, "В данный момент добавляю больше топлива")
          elseif picked_option == 2 then
            api.line(rails.entities.engineer_4, "Стало горячо рукам")
            api.line(rails.entities.engineer_4, "Потом шум, но не настолько как горячо рукам")
          elseif picked_option == 3 then
            api.line(rails.entities.engineer_4, "Я не знаю")
          elseif picked_option == #options then
            break
          elseif picked_option == 4 then
            local gloves = State.player.inventory.gloves
            rails.entities.engineer_4.inventory.gloves = gloves
            State.player.inventory.gloves = nil

            api.narration("Дварфийка с пустым взглядом надевает перчатки на обожженные руки")
            api.line(rails.entities.engineer_4, "Благодарю")
            api.line(rails.entities.engineer_4, "Теперь смогу проработать дольше")

            self.enabled = false
            rails.scenes.dwarf_signals_talking.enabled = true
            rails.scenes.dwarf_talks_about_rront.enabled = true
          end
        end
        rails.entities.engineer_4:rotate(old_direction)
        rails.dreamers_talked_to[4] = true
        State.player.ai.in_cutscene = false
      end,
    },

    talked_to_everybody = {
      name = "Player talked to all dreamers",
      enabled = true,
      start_predicate = function(self, rails, dt)
        return Fun.range(4)
          :filter(function(i) return State:exists(rails.entities["engineer_" .. i]) end)
          :all(function(i) return rails.dreamers_talked_to[i] end)
      end,
      run = function(self, rails)
        self.enabled = false
        api.discover_wiki({talked_to_dreamers = true})
      end,
    },
  }
end
