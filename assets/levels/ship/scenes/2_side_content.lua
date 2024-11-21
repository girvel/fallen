local sound = require("tech.sound")
local fx = require("tech.fx")
local gui = require("tech.gui")
local attacking = require("mech.attacking")
local items = require("library.palette.items")
local item = require("tech.item")
local pipes = require("library.palette.pipes")
local shaders = require("tech.shaders")
local api = require("tech.railing").api
local health = require("mech.health")


return function()
  return {
    {
      name = "1. Leaky ventilation",
      enabled = true,
      start_predicate = function(self, rails, dt)
        return State.player.position == rails.positions.leaky_vent_check
      end,

      run = function(self, rails)
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

      run = function(self, rails)
        self.enabled = false
        api.message.positional("Кровати плохо заправлены, будто это делали в одно движение.")
      end,
    },

    {
      name = "4. World map",
      enabled = true,
      start_predicate = function(self, rails, dt)
        return State.player.position == rails.positions.world_map_message
      end,

      run = function(self, rails)
        self.enabled = false
        api.message.positional("На стене висит старая мировая карта; тяжело различить хоть какой-то текст или даже очертания границ.")
      end,
    },

    {
      name = "5. Scratched table",
      enabled = true,
      start_predicate = function(self, rails, dt)
        return State.player.position == rails.positions.scratched_table_message
      end,

      run = function(self, rails)
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

      run = function(self, rails)
        self.enabled = false
        api.message.positional("Толстый слой пыли, отсутствие матраса и постельного белья. В этой комнате никто не живёт, очень давно.")
      end,
    },

    {
      name = "7. Sign",
      enabled = true,
      start_predicate = function(self, rails, dt)
        return State.player.position == rails.positions.sign_message
      end,

      run = function(self, rails)
        self.enabled = false
        State.player:rotate("up")
        api.message.positional("Старый выцветший указатель. Налево — “столовая”, направо “-к*ю*-*омп*н*я”.")
      end,
    },

    {
      name = "8. A pipe",
      enabled = true,
      start_predicate = function(self, rails, dt)
        return rails.entities.colored_pipe.interacted_by == State.player
      end,

      run = function(self, rails)
        rails.entities.colored_pipe.interacted_by = nil
        State.player.ai.in_cutscene = true

        api.narration("Эта труба звучит как-то по-иному.")

        if api.options({
            "[Ловкость рук] *Обследовать подозрительную трубу*",
            "*уйти*",
          }) == 1
        then
          if api.ability_check("sleight_of_hand", 12) then
            api.narration("Ты аккуратно заводишь пальцы за звенящий участок трубы и достаешь застрявший острый предмет.", {check = {"sleight_of_hand", true}})
            -- item.drop(State.player, "main_hand")
            item.give(State.player, State:add(items.knife()))
            api.narration("Это пыльный наточенный нож, кто-то из прошлого спрятал его здесь.")
            api.narration("Зачем?")
          else
            api.narration("Ты несколько раз постукиваешь по трубе, пытаясь понять природу искаженного звука.", {check = {"sleight_of_hand", false}})
            pipes.burst_with_steam(rails.entities.colored_pipe)
            api.narration("Вдруг резкий поток пара бьёт тебя прямо в лицо.")
            api.narration("Да, не стоит лишний раз совать пальцы куда попало.")
          end
          rails.entities.colored_pipe.interact = nil
        end

        State.player.ai.in_cutscene = false
      end,
    },

    {
      name = "9. The mouse",
      enabled = true,
      start_predicate = function(self, rails, dt)
        return State.player.position == rails.positions.mouse_check
      end,

      run = function(self, rails)
        self.enabled = false
        State.player:rotate("up")
        api.narration("Здесь повесилась мышь. Забавно.")
        api.ability_check_message("nature", 14,
          "Животные ощущают наш мир лучше, чем люди. Мышь, должно быть, предчувствовала что-то ужасное. Может, мне тоже начать бояться?",
          "У меня нет объяснений этому явлению."
        )
      end,
    },

    {
      name = "10. Latrine - warning",
      enabled = true,
      start_predicate = function(self, rails, dt)
        return State.player.position == rails.positions.exit_latrine
      end,

      run = function(self, rails)
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

      run = function(self, rails)
        self.enabled = false
        rails.tolerates_latrine = api.saving_throw("con", 14)
        if rails.tolerates_latrine then
          rails.scenes.enter_latrine.enabled = true
          rails.scenes.exit_latrine.enabled = true
          api.narration("Ты победил.")
          api.narration("Из глаз идут слёзы, в голове жужжание сотен несуществующих мух.")
          api.narration("И нос никогда тебя не простит.")
          api.narration("Но ты прошел это испытание; можешь собой гордиться.")
        else
          api.narration("Это было ошибкой.")
          rails.scenes.enter_latrine.enabled = true
          rails.scenes.exit_latrine.enabled = true
        end
      end,
    },

    enter_latrine = {
      name = "Enter latrine",
      enabled = false,
      start_predicate = function(self, rails, dt)
        return not State.shader
          and State.player.fov_radius ~= 1
          and State.player.position == rails.positions.enter_latrine
      end,

      run = function(self, rails)
        if rails.tolerates_latrine then
          rails.last_player_fov = State.player.fov_radius
          State.player.fov_radius = 1
        else
          State.shader = shaders.latrine
          rails:stop_scene("exit_latrine")
        end
      end,
    },

    exit_latrine = {
      name = "Exit latrine",
      enabled = false,
      start_predicate = function(self, rails, dt)
        return not rails:is_running("exit_latrine")
          and (State.shader or State.player.fov_radius == 1)
          and State.player.position == rails.positions.exit_latrine
      end,

      run = function(self, rails)
        if rails.tolerates_latrine then
          State.player.fov_radius = rails.last_player_fov
          return
        end

        if not rails.been_to_latrine then
          State.player.ai.in_cutscene = true
          State.shader = nil

          api.narration("Ты не можешь контролировать свой желудок...")
          api.narration("И выпускаешь его содержимое наружу.")
        end

        health.damage(State.player, 1)

        if not rails.been_to_latrine then
          api.narration("В слезах и желчи, ты выбегаешь из фекального ада и клянешься никогда туда не возвращаться.")
          api.narration("Но ужасное состояние не уходит.")

          rails.been_to_latrine = true
          State.player.ai.in_cutscene = false
          State.shader = shaders.latrine
        end

        api.wait_seconds(10)
        State.shader = nil
      end,
    },

    {
      name = "11. Dirty magazine",
      enabled = true,
      start_predicate = function(self, rails, dt)
        return rails.tolerates_latrine and State.player.position == rails.positions.dirty_magazine
      end,

      run = function(self, rails)
        self.enabled = false
        api.narration("На обложке цветной газеты красуется очень реалистичное изображение накачанных мужчин.")
        api.narration("Их физическая форма впечатляет, но они зачем-то оделись в нелепые тесные костюмы.")
        api.ability_check_message("religion", 8,
          "Закрепленное белое нечто за спинами мужчин очень уж напоминает крылья. А эти подвязки... Да эти атлеты без сомнений изображают ангелов! М-да, безвкусица.",
          "Интересно, через какие тренировки прошли эти атлеты? Такое упорство внушает уважение!"
        )
      end,
    },

    {
      name = "12. The kitchen",
      enabled = true,
      start_predicate = function(self, rails, dt)
        return (State.player.position - rails.positions.kitchen_bucket):abs() == 1
      end,

      run = function(self, rails)
        self.enabled = false
        api.narration("Десятки вскрытых металлических банок грудой навалены в мусорное ведро.")
        api.narration("Внутренняя поверхность каждой полностью вычищена, крысам ничего не достанется.")
        if api.ability_check("history", 10) then
          api.narration("Взгляд останавливается на выбитых в металле знаках: “Упаковано в 221 году З.Э. город Сент-Целест”.", {check = {"history", true}})
          api.narration("Эта банка встречала Мировую Войну.")
        else
          api.narration("Взгляд останавливается на этикетке с изображением пышногрудой воительницы.", {check = {"history", false}})
          api.narration("Как оно связано с содержанием консервы?")
        end
      end,
    },

    {
      name = "13. Strange soup",
      enabled = true,
      start_predicate = function(self, rails, dt)
        return rails.entities.cook.interacted_by == State.player
      end,

      run = function(self, rails)
        self.enabled = false
        rails.entities.cook.interact = nil

        api.narration("С недюжим усердием коренастый старик перемешивает рагу в казане.")
        api.narration("Запах тысячи специй мигом забивает рецепторы.")
        api.narration("Сладкое, острое, соленое, доброе, цветное — в этом вареве есть всё.")

        rails.entities.cook:rotate("right")
        api.narration("Старик оборачивается, замечая твой взгляд:")
        api.line(rails.entities.cook, "Ещё не готово, подходи к обеду")

        if api.ability_check("cha", 14) then
          api.narration("Твоё нутро издаёт громкий голодный звук.", {check = {"cha", true}})
          api.narration("После этого старик берёт с полки металлическую кружку и зачерпывает в неё рагу.")
          api.line(rails.entities.cook, "Держи, грешно оставлять голодную душу")

          -- TODO as temporary effect
          local d = math.max(1, State.player:get_modifier("con"))
          State.player.hp = State.player.hp + d
          State:add(gui.floating_damage("+" .. d, State.player.position, Colors.green))

          rails.entities.cook:rotate("up")
          api.narration("Аккуратный глоток.")
          api.narration("На вкус оно так же невероятно, как и на запах.")
          api.narration("Ещё глоток.")
          api.narration("Ты удивленно моргаешь, смотря на пустую кружку.")
          api.narration("Всё приятное так быстро кончается.")
        else
          rails.entities.cook:rotate("up")
          api.narration("Старик отворачивается и продолжает перемешивать кулинарную амальгаму.", {check = {"cha", false}})
          api.narration("Такую подозрительную.")
          api.narration("И такую манящую.")
        end
      end,
    },

    {
      name = "Interacting with cauldron after the old guy is dead",
      enabled = true,

      characters = {
        soup_cauldron = {},
      },

      _popup = {},

      start_predicate = function(self, rails, dt, c)
        return c.soup_cauldron.interacted_by == State.player
      end,

      run = function(self, rails, c)
        c.soup_cauldron.interacted_by = nil
        if not State:exists(self._popup[1]) then
          self._popup = api.message.temporal("Кажется, у меня пропал аппетит", {source = c.soup_cauldron})
        end
      end,
    },

    sees_possessed = {
      name = "14. Disappearing dude",
      enabled = true,
      start_predicate = function(self, rails, dt)
        return rails.entities.dining_room_door_1.is_open
          or rails.entities.dining_room_door_2.is_open
      end,

      run = function(self, rails)
        self.enabled = false
        State:add(fx("assets/sprites/fx/disappearing_dude", "fx", rails.positions.possessed_image))
        sound.play("assets/sounds/creepy", .1)
      end,
    },

    {
      name = "Player gets damaged",
      enabled = true,
      start_predicate = function(self, rails, dt)
        return State.player.hp < State.player:get_max_hp()
          and State.mode:get() == State.mode.free
          and not State.player.ai.in_cutscene
      end,

      run = function(self, rails)
        self.enabled = false

        Log.trace(1)
        State.gui.hint.override = "Нажмите [H] чтобы перевязать раны"
        local old_hp = State.player.hp
        while not Common.period(15, self) and State.player.hp == old_hp do
          coroutine.yield()
        end
        State.gui.hint.override = nil
      end,
    },
  }
end
