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
      name = "Markis dialogue",
      enabled = true,
      start_predicate = function(self, rails, dt)
        return rails.entities.markis.interacted_by == State.player
      end,

      _furry_recognized = nil,
      -- extended from other scenes
      top_level_options = {
        "Ты - Кот.",
      },

      run = function(self, rails)
        rails.entities.markis.interacted_by = nil

        if rails._furry_recognized == nil then
          api.line(rails.entities.markis, "Пропустите-с, несу уголь в кош-тельную")
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
            api.line(rails.entities.markis, "Действительно, друг? А я думаю, почему-c так хочется охотиться на мышей")

            local chosen_option_2 = api.options({
              "Ты мне — не друг!",
              "Почему ты назвал меня другом?",
            })

            if chosen_option_2 == 1 then
              api.line(rails.entities.markis, "Ошибаешься, друг. Все мы связаны общими делами-с. Все заперты в одной кле-точ-ке.")
            else
              api.line(rails.entities.markis, "Потому что ты мой друг-с. Мы связаны общим делом. Сидим в одной клеточке.")
            end

            local chosen_option_3 = api.options({
              "Нет у нас ничего общего, запомни это.",
              "Общее дело? Клеточка? Что ты имеешь ввиду?",
            })

            if chosen_option_3 == 1 then
              api.line(rails.entities.markis, "Хорошо, друг.")
            else
              api.line(rails.entities.markis, "Ты спрашиваешь, хоть и знаешь? Это почти как молчать, если не знаешь.")

              local chosen_option_4 = api.options({
                "[Убеждение] *убедить его рассказать больше*",
                "Поменьше кури эту дрянь, не будут клеточки мерещиться.",
              })

              if chosen_option_4 == 1 then
                if api.ability_check("persuasion", 12) then
                  api.line(State.player, "(Такая речь запутает многих, но не меня. Поиграем по твоим правилам, кот)", {check = {"persuasion", true}})
                  api.line(State.player, "Конечно. Друг, кле-точ-ка, общее дело. А, не напомнишь, где ключик или дверка у этой клеточки?")
                  api.narration("Кот серьёзно задумывается, даже перестаёт дымить.")
                  api.line(rails.entities.markis, "Мне кажется, все двери в твоей голове. А ключи стоит искать в сердце")
                  api.narration("Ты определенно переоценил свой уровень адаптации к абстрактной беседе.")
                else
                  api.narration("Он явно не понял с первого раза, нужно повторить вопрос несколько раз.", {check = {"persuasion", false}})
                  api.line(State.player, "Что за клеточка? Что за общее дело? Почему ты кот? О чем ты говоришь?")
                  api.narration("Кот лениво выдыхает дым.")
                  api.line(rails.entities.markis, "Су-е-та…")
                  api.narration("Терминальный случай, тут ответа не добиться.")
                end
              else
                api.line(rails.entities.markis, "Клеточка не исчезнет, даже если закрыть глаза")
                api.narration("Этот разговор начинает сводить тебя с ума, лучше сделать перерыв.")
              end
            end
          end
        end
      end,
    },
  }
end
