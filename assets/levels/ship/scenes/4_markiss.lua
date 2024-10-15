local api = require("tech.railing").api
local level = require("state.level")
local item = require("tech.item")
local experience = require("mech.experience")
local quest = require("tech.quest")
local items = require("library.palette.items")


return function()
  return {
    open_left_megadoor = {
      name = "Open left megadoor",
      enabled = false,
      start_predicate = function(self, rails, dt)
        return true
      end,

      run = function(self, rails)
        self.enabled = false

        rails.entities.megadoor11:open()
        rails.entities.megadoor12:open()
        rails.entities.megadoor13:open()
      end,
    },

    checkpoint_4 = {
      name = "Checkpoint (4)",
      enabled = false,
      start_predicate = function(self, rails, dt)
        return true
      end,

      run = function(self, rails, dt)
        self.enabled = false
        api.checkpoint_base()

        level.move(State.player, rails.positions.checkpoint_4)
        api.update_quest({warmup = quest.COMPLETED})
        rails.scenes.player_leaves_his_room.enabled = false
        rails.scenes.open_left_megadoor.enabled = true
        rails.entities.detective_door.locked = false

        State.player.experience = experience.for_level[3]
        State.gui.creator:refresh()
        State.gui.creator:submit()

        item.give(State.player, State:add(items.pole()))
        api.center_camera()
      end,
    },

    {
      name = "Markiss dialogue",
      enabled = true,
      start_predicate = function(self, rails, dt)
        return rails.entities.markiss.interacted_by == State.player
      end,

      _furry_recognized = nil,
      -- extended from other scenes
      top_level_options = {
        "Ты - Кот.",
        "Ты не похож на остальных рабочих.",
        "Расскажи подробнее, чем ты занимаешься?",
      },

      run = function(self, rails)
        rails.entities.markiss.interacted_by = nil

        if rails._furry_recognized == nil then
          api.line(rails.entities.markiss, "Пропустите-с, несу уголь в кош-тельную")
          api.line(State.player, "(Это… Кот?)")

          self._furry_recognized = api.ability_check("nature", 18)
          if self._furry_recognized then
            api.narration(
              "Он представитель расы зверолюдей с западного континента; их аномальная природа влияет на эмбрион в момент созревания, в результате дети рождаются с чертами разных зверей.",
              {check = {"nature", true}}
            )
          else
            api.narration("Определенно. Кот.", {check = {"nature", false}})
          end
        end

        while true do
          local chosen_option_1 = api.options(self.top_level_options, true)

          if chosen_option_1 == 1 then
            api.line(rails.entities.markiss, "Действительно, друг? А я думаю, почему-c так хочется охотиться на мышей")

            local chosen_option_2 = api.options({
              "Ты мне — не друг!",
              "Почему ты назвал меня другом?",
            })

            if chosen_option_2 == 1 then
              api.line(rails.entities.markiss, "Ошибаешься, друг. Все мы связаны общими делами-с. Все заперты в одной кле-точ-ке.")
            else
              api.line(rails.entities.markiss, "Потому что ты мой друг-с. Мы связаны общим делом. Сидим в одной клеточке.")
            end

            local chosen_option_3 = api.options({
              "Нет у нас ничего общего, запомни это.",
              "Общее дело? Клеточка? Что ты имеешь в виду?",
            })

            if chosen_option_3 == 1 then
              api.line(rails.entities.markiss, "Хорошо, друг.")
            else
              api.line(rails.entities.markiss, "Ты спрашиваешь, хоть и знаешь? Это почти как молчать, если не знаешь.")

              local chosen_option_4 = api.options({
                "[Убеждение] *убедить его рассказать больше*",
                "Поменьше кури эту дрянь, не будут клеточки мерещиться.",
              })

              if chosen_option_4 == 1 then
                if api.ability_check("persuasion", 12) then
                  api.line(State.player, "(Такая речь запутает многих, но не меня. Поиграем по твоим правилам, кот)", {check = {"persuasion", true}})
                  api.line(State.player, "Конечно. Друг, кле-точ-ка, общее дело. А, не напомнишь, где ключик или дверка у этой клеточки?")
                  api.narration("Кот серьёзно задумывается, даже перестаёт дымить.")
                  api.line(rails.entities.markiss, "Мне кажется, все двери в твоей голове. А ключи стоит искать в сердце")
                  api.narration("Ты определенно переоценил свой уровень адаптации к абстрактной беседе.")
                else
                  api.narration("Он явно не понял с первого раза, нужно повторить вопрос несколько раз.", {check = {"persuasion", false}})
                  api.line(State.player, "Что за клеточка? Что за общее дело? Почему ты кот? О чем ты говоришь?")
                  api.narration("Кот лениво выдыхает дым.")
                  api.line(rails.entities.markiss, "Су-е-та…")
                  api.narration("Терминальный случай, тут ответа не добиться.")
                end
              else
                api.line(rails.entities.markiss, "Клеточка не исчезнет, даже если закрыть глаза")
                api.narration("Этот разговор начинает сводить тебя с ума, лучше сделать перерыв.")
              end
            end

          elseif chosen_option_1 == 2 then
            api.line(rails.entities.markiss, "Разве-с? Я чем-то выделяюсь, помимо ушек и шерсти-с?")

            local chosen_option_2 = api.options({
              "Если так подумать, то ничем...",
              "[Религия] *Может, в нём есть что-то потустороннее?*",
              "[Проницательность] *Может, есть что-то необычное в его поведении?*",
            })

            if chosen_option_2 == 1 then
              api.line(rails.entities.markiss, "Мудрая мыслишка, все мы разной породы, но суть внутри одна-с")

              local chosen_option_3 = api.options({
                "Меня начал утомлять этот разговор. Ты же не вызовешь никаких проблем тут?",
                "У нас с тобой и суть, и порода разные.",
              })

              if chosen_option_3 == 1 then
                api.line(rails.entities.markiss, "Никаких проблем-с, начальник!")
              else
                api.line(rails.entities.markiss, "Как скажешь, начальник!")
                api.line(rails.entities.markiss, "Но вот мне так не кажется, а я в корень смотрю, глаз намётан")
                api.narration("Кот игриво показывает на свой левый глаз.")
                api.line(rails.entities.markiss, "Сам посмотри")

                if api.ability_check("wis", 14) then
                  api.line(State.player, "Не буду я в твои глаза смотреть, есть дела поважнее.", {check = {"wis", true}})
                else
                  api.narration("Это существо - твой хороший друг.", {check = {"wis", false}})
                  api.narration("Были ли у тебя друзья ранее? Неважно.")
                  api.narration("Он станет первым.")
                  api.line(rails.entities.markiss, "Мы одной сути, друг-с")
                  api.narration("Внезапно он выпускает клубок густого дыма тебе в лицо.")
                  api.narration("Наваждение проходит.")
                  api.line(State.player, "Что за черт?! Как ты это сделал?")
                  api.line(rails.entities.markiss, "Магия-с, друг. Магия-с.")
                  api.narration("В голову приходит осознание - ты не сможешь ему навредить. Никак.")
                  api.narration("Придётся жить в этом проклятом мире.")
                end
              end

            else  -- chosen_option_2 == 2
              local success, check
              if chosen_option_2 == 2 then
                success = self._furry_recognized or api.ability_check("religion", 10)
                check = "religion"
              elseif chosen_option_2 == 3 then
                success = self._furry_recognized or api.ability_check("insight", 12)
                check = "insight"
              else
                error()
              end

              if success then
                api.narration("Жук попал в муравейник. Но почему-то не разоряет его.", {check = {check, true}})
                api.narration("Он таскает листочки и веточки с муравьями-рабочими.")
                api.line(State.player, "Зачем тебе всё это? Ты не один из них.")
                api.narration("Кот от удивления громко кашляет, глотая сигарету.")
                api.line(rails.entities.markiss, "Это-с. Черт-с. Ахх-с.")
                api.narration("Наконец он восстанавливает дыхание и достаёт новую сигарету.")
                api.line(rails.entities.markiss, "Это, черт, я не ожидал-с таки услышать, начальник!")
                api.line(rails.entities.markiss, "Я своего рода исследователь, токмо без лицензии-с")
                api.line(rails.entities.markiss, "Исследую-с куда глаза глядят")
                api.line(rails.entities.markiss, "Так и здесь оказался-с, и вот исследую-с!")

                local options = {
                  "Может, наисследовал что полезное?",
                  "Может ты находил *выход*?",
                  "Ладно, всё с тобой ясно, бродяга.",
                }

                while true do
                  local chosen_option_3 = api.options(options, true)

                  if chosen_option_3 == 1 then
                    api.line(rails.entities.markiss, "Да! И рад поделиться-с, начальник!")
                    api.line(rails.entities.markiss, "Двери-с тут кое-где хлипкие, кто сильный ударит, токмо так развалятся!")
                    api.line(State.player, "А ты пробовал?")
                    api.line(rails.entities.markiss, "Нет. У меня лапки")
                  elseif chosen_option_3 == 2 then
                    api.line(rails.entities.markiss, "Выход, начальник?")
                    api.line(rails.entities.markiss, "Выход есть всегда, иногда даже не один")
                    api.line(rails.entities.markiss, "У нас на родине есть примета.")
                    api.line(rails.entities.markiss, "Если потерялся, если стоишь не перепутье")
                    api.line(rails.entities.markiss, "Не иди прямо — там-с смерть тебя дожидается")
                    api.line(rails.entities.markiss, "А назад идти резона-с нет  — так снова на перепутье окажешься")
                    api.line(rails.entities.markiss, "И... Как же там дальше было-с")
                    api.line(rails.entities.markiss, "Пойдёшь направо — точно что-то про жену...")
                    api.line(rails.entities.markiss, "Налево — что-то про коня, хотя-с логичнее было бы про мужа...")
                    api.line(rails.entities.markiss, "Про что мы говорили?")
                    api.line(State.player, "Про выход")
                    api.line(rails.entities.markiss, "Не знаю я выхода, начальник! Ситуация безвыходная!")
                    api.line(rails.entities.markiss, "Хотя как говорится, выйдешь из клетки — окажешься в клетке побольше.")
                    api.line(rails.entities.markiss, "А этом случае и двери, и стенки клетки теряют всякий смысл.")

                    local chosen_option_4 = api.options({
                      "Может, я сошёл с ума от общения с тобой, но в этом и правда что-то есть.",
                      "Если на твоей родине все такие дурные - мне вас очень жаль.",
                    })

                    if chosen_option_4 == 1 then
                      api.line(rails.entities.markiss, "Спасибо, э, как я там тебя называл?")
                      api.line(State.player, "Начальник, хотя зовут меня — %s" % State.player.inner_name)
                      api.line(rails.entities.markiss, "Не подходит тебе это имя, своё поищи")
                      api.line(State.player, "А имя должно как-то подходить? Вот допустим твоё?")
                      api.line(rails.entities.markiss, "Я - Маркисс")
                      rails.entities.markiss.name = "Маркисс"
                      api.line(State.player, "Вопросов больше не имею")
                    else  -- chosen_option_4 == 2
                      api.line(rails.entities.markiss, "Не все! Я один такой-сякой")
                    end
                  else  -- chosen_option_3 == 3
                    break
                  end
                end

              else  -- religion/insight check failed
                api.narration("Теневые коты, точно! Ты многое слышал о них.", {check = {check, false}})
                api.narration("Это опаснейшие суперхищники, контролирующие разум своих жертв.")
                api.narration("Тенекоты увлекают их разговором, заставляют потерять внимание...")
                api.narration("А потом жестоко расправляются одним ударом бритвенно-острого хвоста.")

                if api.ability_check("nature", 10) then
                  api.narration("И неважно, что их истребили 600 лет назад.", {check = {"nature", true}})
                end

                api.narration("Без сомнений - перед тобой один из Теневых котов.")
                api.line(State.player, "Понятно, я, пожалуй, пойду")
                api.line(rails.entities.markiss, "До встречи, начальник-с!")
              end
            end  -- (2)
          else -- chosen_option_1 == 3
            api.line(rails.entities.markiss, "Я-то? Сначала-с беру угля, да побольше, в хранилище")
            api.line(rails.entities.markiss, "Потом несу-тащу его в кош-тельную")
            api.line(rails.entities.markiss, "Эта работа требует большой воли и мастерства-с")
            api.line(rails.entities.markiss, "Иногда, можно не туда-с свернуть или забыть взять уголь")
            api.line(rails.entities.markiss, "Бывает, думаешь, как разойтись с другим рабочим-очим или, вот, мысль приходит.")
            -- TODO horror SFX
            api.line(rails.entities.markiss, "Зачем вообще всё это нужно.")
            api.line(rails.entities.markiss, "Оно когда-нибудь закончится?")
            -- TODO horror SFX
            api.line(rails.entities.markiss, "Но потом-с ты берёшь ещё одну порцию угля и снова всё хорошо.")
          end  -- (1)
        end  -- main dialogue loop
      end,
    },
  }
end
