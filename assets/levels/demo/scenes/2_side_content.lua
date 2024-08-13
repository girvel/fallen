local attacking = require("mech.attacking")
local items = require("library.items")
local item = require("tech.item")
local pipes = require("library.pipes")
local shaders = require("tech.shaders")
local api = require("tech.railing").api


return function()
  return {
    {
      name = "1. Leaky ventilation",
      enabled = true,
      start_predicate = function(self, rails, dt)
        return State.player.position == rails.positions.leaky_vent_check
      end,

      run = function(self, rails, dt)
        self.enabled = false
        api.ability_check_message("investigation", 10,
          "Темные пятна на стенах и потолке могут указывать на проблемы с вентиляцией и серьезные утечки воды.",
          "Тёмные пятна на полу и потолке складываются в гротескные узоры."
        )
      end,
    },

    {
      name = "2. Beds in rooms",
      enabled = true,
      start_predicate = function(self, rails, dt)
        return State.player.position == rails.positions.beds_check
      end,

      run = function(self, rails, dt)
        self.enabled = false
        api.message("Кровати плохо заправлены, будто это делали в одно движение.")
      end,
    },

    {
      name = "4. World map",
      enabled = true,
      start_predicate = function(self, rails, dt)
        return State.player.position == rails.positions.world_map_message
      end,

      run = function(self, rails, dt)
        self.enabled = false
        api.message("На стене висит старая мировая карта. Тяжело различить хоть какой-то текст или даже очертания границ.")
      end,
    },

    {
      name = "5. Scratched table",
      enabled = true,
      start_predicate = function(self, rails, dt)
        return State.player.position == rails.positions.scratched_table_message
      end,

      run = function(self, rails, dt)
        self.enabled = false
        State.player:rotate("up")
        api.ability_check_message("investigation", 10,
          "Когда ты прищуриваешься, хаотичный узор из царапин на столе начинает напоминать тропический остров с пальмами, солнцем и счастливой семьей.",
          "Какой-то психопат порядочно поиздевался над столом."
        )
      end,
    },

    {
      name = "6. Empty dorm",
      enabled = true,
      start_predicate = function(self, rails, dt)
        return State.player.position == rails.positions.empty_dorm_message
      end,

      run = function(self, rails, dt)
        self.enabled = false
        api.message("Толстый слой пыли, отсутствие матраса и постельного белья. В этой комнате никто не живёт, очень давно.")
      end,
    },

    {
      name = "7. Sign",
      enabled = true,
      start_predicate = function(self, rails, dt)
        return State.player.position == rails.positions.sign_message
      end,

      run = function(self, rails, dt)
        self.enabled = false
        State.player:rotate("up")
        api.message("Старый выцветший указатель. Налево - столовая, направо - кают-компания.")
      end,
    },

    {
      name = "8. A pipe",
      enabled = true,
      start_predicate = function(self, rails, dt)
        return rails.entities.colored_pipe.interacted_by == State.player
      end,

      run = function(self, rails, dt)
        rails.entities.colored_pipe.interacted_by = nil
        State.player.in_cutscene = true

        api.narration("Эта труба звучит как-то по-иному.")

        if api.options({
            "[Ловкость рук] *Обследовать подозрительную трубу*",
            "*уйти*",
          }) == 1
        then
          if api.ability_check("sleight_of_hand", 12) then
            api.narration("Ты аккуратно заводишь пальцы за звенящий участок трубы и достаешь застрявший острый предмет.")
            item.drop(State.player, "main_hand")
            item.give(State.player, State:add(items.knife()))
            api.narration("Это пыльный наточенный нож, кто-то из прошлого спрятал его здесь.")
            api.narration("Зачем?")
          else
            api.narration("Ты несколько раз постукиваешь по трубе, пытаясь понять природу искаженного звука.")
            pipes.burst_with_steam(rails.entities.colored_pipe)
            api.narration("Вдруг резкий поток пара бьёт тебя прямо в лицо.")
            api.narration("Да, не стоит лишний раз совать пальцы куда попало.")
          end
          rails.entities.colored_pipe.interact = nil
        end

        State.player.in_cutscene = false
      end,
    },

    {
      name = "9. The mouse",
      enabled = true,
      start_predicate = function(self, rails, dt)
        return State.player.position == rails.positions.mouse_check
      end,

      run = function(self, rails, dt)
        self.enabled = false
        State.player:rotate("up")
        api.narration("Здесь повесилась мышь. Забавно.")
        api.ability_check_message("nature", 14,
          "Животные ощущают наш мир лучше, чем люди. Мышь, должно быть, предчувствовала что-то ужасное. Может мне тоже начать бояться?",
          "У меня нет объяснений этому явлению"
        )
      end,
    },

    {
      name = "10. Latrine - warning",
      enabled = true,
      start_predicate = function(self, rails, dt)
        return State.player.position == rails.positions.exit_latrine
      end,

      run = function(self, rails, dt)
        self.enabled = false
        api.narration("Неописуемая вонь бьёт по твоим ноздрям.")
        api.narration("Как будто фекальный дьявол начал великую тошнотворную войну, а это его омерзительный оплот.")
        api.narration("Ты можешь считать себя очень стойким, но из этого боя лучше отступить.")
      end,
    },

    {
      name = "10. Latrine - first time inside",
      enabled = true,
      start_predicate = function(self, rails, dt)
        return State.player.position == rails.positions.enter_latrine
      end,

      run = function(self, rails, dt)
        self.enabled = false
        rails.tolerates_latrine = State.player.saving_throws.con:roll() >= 14
        if rails.tolerates_latrine then
          api.narration("Ты победил.")
          api.narration("Из глаз идут слёзы, в голове жужжание сотен несуществующих мух.")
          api.narration("И нос никогда тебя не простит.")
          api.narration("Но ты прошел это испытание; можешь собой гордиться.")
        else
          api.narration("Это было ошибкой.")
        end
        rails.scenes.enter_latrine.enabled = true
        rails.scenes.exit_latrine.enabled = true
      end,
    },

    enter_latrine = {
      name = "Enter latrine",
      enabled = false,
      start_predicate = function(self, rails, dt)
        return not State.shader
          and not rails.tolerates_latrine
          and State.player.position == rails.positions.enter_latrine
      end,

      run = function(self, rails, dt)
        State:set_shader(shaders.latrine)
        rails:stop_scene("exit_latrine")
      end,
    },

    exit_latrine = {
      name = "Exit latrine",
      enabled = false,
      start_predicate = function(self, rails, dt)
        return not rails:is_running(self)
          and not rails.tolerates_latrine
          and State.player.position == rails.positions.exit_latrine
      end,

      run = function(self, rails, dt)
        if not rails.been_to_latrine then
          State.player.in_cutscene = true
          State:set_shader()
          self.enabled = false

          api.narration("Ты не можешь контролировать свой желудок…")
          api.narration("И выпускаешь его содержимое наружу.")
        end

        attacking.damage(State.player, 1)

        if not rails.been_to_latrine then
          api.narration("В слезах и желчи, ты выбегаешь из фекального ада и клянешься никогда туда не возвращаться.")
          api.narration("Но ужасное состояние никуда не уходит.")

          rails.been_to_latrine = true
          State.player.in_cutscene = false
          State:set_shader(shaders.latrine)
          self.enabled = true
        end

        api.wait_seconds(10)
        State:set_shader()
      end,
    },
  }
end
