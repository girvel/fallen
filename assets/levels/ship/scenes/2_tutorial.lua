local fx = require("tech.fx")
local on_tiles = require("library.palette.on_tiles")
local cue = require("tech.cue")
local experience = require("mech.experience")
local sound = require("tech.sound")
local quest = require("tech.quest")
local interactive = require("tech.interactive")
local mobs = require("library.palette.mobs")
local level = require("state.level")
local api = require("tech.railing").api


return function()
  return {
    checkpoint_2 = {
      name = "Checkpoint (2)",
      enabled = false,
      start_predicate = function(self, rails, dt) return true end,

      run = function(self, rails)
        rails:remove_scene("checkpoint_2")
        api.checkpoint_base()
        level.move(State.player, rails.positions.checkpoint_2)
        State.player.experience = experience.for_level[2]
        State.gui.creator:refresh()
        State.gui.creator:submit()
        api.center_camera()
      end,
    },

    player_leaves_his_room = {
      name = "Player leaves his room",
      enabled = true,
      start_predicate = function(self, rails, dt)
        return (State.player.position - rails.positions.player_room_exit):abs() > 7
      end,

      run = function(self, rails)
        self.enabled = false
        api.notification("Отправляйся в тренировочную комнату вниз по коридору.", true)
        api.update_quest({warmup = 2})
      end,
    },

    {
      name = "Player enters the officer room",
      enabled = true,
      start_predicate = function(self, rails, dt)
        return State.player.position == rails.positions.officer_room_enter
      end,

      run = function(self, rails)
        self.enabled = false
        if (State.gui.wiki.quest_states.warmup or 0) >= 3 then return end
        if not State.player.inventory.main_hand then
          api.notification("Найди подходящее оружие", true)
          api.update_quest({warmup = 3})
        end
        rails.scenes.warmup.enabled = true
      end,
    },

    {
      name = "Hint near the mannequin",
      enabled = true,

      characters = {
        mannequin = {},
      },

      start_predicate = function(self, rails, dt, c)
        return (State.player.position - c.mannequin.position):abs() == 1
      end,

      run = function(self, rails, c)
        State.gui.hint.override = "Нажмите [1] чтобы атаковать"
        while self:start_predicate(rails, nil, c) do coroutine.yield() end
        State.gui.hint.override = nil
      end,
    },

    warmup = {
      name = "Warmup itself",
      enabled = false,
      start_predicate = function(self, rails, dt)
        return State.player.inventory.main_hand
      end,

      run = function(self, rails)
        self.enabled = false
        local old_hp = rails.entities.mannequin.hp

        api.notification("Атакуй чучело", true)
        api.update_quest({warmup = 4})

        local miss_remarked = false

        for _, remark in ipairs({
          "Ещё удар",
          "Отлично, продолжай",
          "Настоящий бой будет тяжелее."
        }) do
          while State:exists(rails.entities.mannequin) do
            coroutine.yield()
            if State:check_aggression(State.player, rails.entities.mannequin) then
              if rails.entities.mannequin.hp < old_hp then
                old_hp = rails.entities.mannequin.hp
                api.notification(remark, true)
                break
              elseif not miss_remarked then
                api.notification("Целься лучше", true)
                miss_remarked = true
              end
            end
          end
        end

        api.wait_seconds(3)
        api.notification("Запусти блок миража, чтобы перейти к демонстрации", true)
        api.update_quest({warmup = 5})
      end,
    },

    {
      name = "Phantom fight",
      enabled = true,

      characters = {
        mirage_block = {},
        player = {},
      },

      start_predicate = function(self, rails, dt, c)
        return c.mirage_block.interacted_by == State.player
      end,

      run = function(self, rails, c)
        rails.scenes.warmup.enabled = false
        c.mirage_block.interacted_by = nil

        api.narration("Это небольшой, размером с тумбочку, черно-желтый куб; на его верхней грани размещено стекло.")
        api.narration("В нижней части стекла расположены три кнопки: два треугольника, смотрящие в разные стороны, и круг.")
        api.narration("За стеклом лежит пергамент с схемой человеческого организма; рисунок ёмко подписан:")
        api.line(State.player, "”Самое страшное животное — Человек”")

        local options = {
          "Нажать на один из треугольников",
          "Нажать на круг",
          "*Уйти*",
        }

        local e
        while true do
          local o = api.options(options)
          if o == 1 then
            api.narration("После нажатия, пергамент исчезает в глубине блока, а потом снова всплывает с противоположной стороны.")
          elseif o == 2 then
            self.enabled = false
            c.mirage_block.interact = nil

            api.narration("Блок громко жужжит, после чего выпускает из левой грани множество световых лучей.")
            api.narration("В конце комнаты свет формирует призрачную фигуру рыцаря.")

            State:add(fx(
              "assets/sprites/fx/mirage_spawn", "fx_under", rails.positions.officer_room_enter
            ))
            api.wait_seconds(0.5)
            sound("assets/sounds/phantom_appearing.mp3"):play()
            e = State:add(mobs.phantom_knight(), {position = rails.positions.officer_room_enter})

            if api.ability_check("arcana", 10) then
              api.narration("Это обыкновенная иллюзия, она не может причинять вряд.", {check = {"arcana", true}})
              api.narration("Должно быть, машина создает фантом на основе схемы.")
            else
              api.narration("Машина призвала воителя из былых времён.", {check = {"arcana", false}})
              api.narration("Ты должен показать ему, на что способен.")
            end
            break
          else
            return
          end
        end

        State:start_combat({State.player, e})
        api.notification("Твой ход.", true)

        local popup = {}
        while State.combat do
          if State.combat:get_current() ~= State.player then break end
          if State.player.resources.movement == 0 then
            popup = api.message.temporal("Больше двигаться ты не сможешь, время передать ход")
            break
          end
          coroutine.yield()
        end

        if State.combat then
          while State.combat:get_current() == State.player do coroutine.yield() end
          while State.combat:get_current() ~= State.player do coroutine.yield() end
          State:remove_multiple(popup)
          api.message.temporal("Это всего лишь иллюзия.")
          api.wait_seconds(2)
          api.notification("Добей иллюзию", true)
        end

        while State.combat do coroutine.yield() end
        api.notification("Покорми птицу в клетке", true)
        api.update_quest({warmup = 6})

        Table.extend(rails.entities.bird_food, interactive.detector(), {name = "ящик"})
        Table.extend(rails.entities.bird_cage, interactive.detector(), {name = "клетка"})
      end,
    },

    {
      name = "Look in the crate",
      enabled = true,
      start_predicate = function(self, rails, dt)
        return rails.entities.bird_food.interacted_by == State.player
      end,

      run = function(self, rails)
        rails.entities.bird_food.interacted_by = nil

        api.narration("В ящике лежит небольшое ведёрко.")
        api.narration("Внутри — приятно пахнущие зёрна.")

        if api.options({
          "*Взять горсть*",
          "*Закрыть ящик*",
        }) == 1 then
          rails.entities.bird_food.interact = nil
          rails.has_bird_food = true
          self.enabled = false
        end
      end,
    },

    {
      name = "Look in the cage",
      enabled = true,
      start_predicate = function(self, rails, dt)
        return rails.entities.bird_cage.interacted_by == State.player
      end,

      run = function(self, rails)
        rails.entities.bird_cage.interacted_by = nil

        api.narration("Это птичья клетка.")
        api.narration("Без птицы.")
        api.narration("Хотя здесь есть много помёта.")
        api.narration("И немного перьев.")

        local options = {
          "*уйти*",
        }

        if rails.has_bird_food then
          table.insert(options, 1, "*положить корм в клетку*")
        end

        if api.options(options) == #options then return end

        self.enabled = false
        rails.entities.bird_cage.interact = nil
        rails.has_bird_food = false

        api.update_quest({warmup = quest.COMPLETED, detective = 1})
        rails.entities.detective_door.locked = false

        rails.entities.dining_room_door_1:close()
        rails.entities.dining_room_door_2:close()
        rails.scenes.sees_possessed.enabled = false
        rails.scenes.sees_possessed_again.enabled = true
        rails.scenes.kills_possessed.enabled = true
        rails.entities.possessed = State:add(mobs.possessed(), {
          position = rails.positions.possessed_spawn
        })
        State:add(on_tiles.blood(), {position = rails.positions.possessed_spawn})

        api.notification("Направляйся к комнате с черной дверью.", true)

        rails.scenes.open_left_megadoor.enabled = true

        api.wait_seconds(10)
      end,
    },

    sees_possessed_again = {
      name = "Player sees possessed again",
      enabled = false,
      start_predicate = function(self, rails, dt)
        return (State.player.position - rails.entities.possessed.position):abs() < 5
      end,

      run = function(self, rails)
        self.enabled = false

        api.narration("На стуле бледный мужчина с диким взглядом зубами — нет — пастью разрывает иволгу.")
        api.narration("Его одежда разорвана; всё вокруг покрыто кровью и перьями прекрасной птицы.")
        sound.play("assets/sounds/possessed_turns_around.mp3", .15)
        api.narration("Внезапно демон в человеческом обличье замечает тебя.")

        State:start_combat({State.player, rails.entities.possessed})
      end,
    },

    kills_possessed = {
      name = "Player kills possessed",
      enabled = false,
      start_predicate = function(self, rails, dt)
        return rails.entities.possessed.hp <= 0
      end,

      run = function(self, rails)
        self.enabled = false

        api.narration("Он мертв.")
        api.narration("Демон это заслужил.")
        api.narration("Прекрасная птица мертва.")
        api.narration("Она этой участи не заслужила.")

        local options = {
          "[Медицина] *Осмотреть труп*",
          "*Взять остатки птицы*",
          "*Уйти*"
        }

        while true do
          local o = api.options(options, true)

          if o == 1 then
            if api.ability_check("medicine", 12) then
              api.narration("Без сомнений, это был простой человек; он не выглядит больным или истощенным.", {check = {"medicine", true}})
              api.narration("И... Убивал он не из-за голода.")
            else
              api.narration("Люди способны на всякое; но мертвое существо неизвестной природы, несомненно, лишь приняло облик человека.", {check = {"medicine", false}})
            end
          elseif o == 2 then
            rails.scenes.return_bird_remains.enabled = true
            Table.extend(rails.entities.bird_cage, interactive.detector())
            cue.set(rails.entities.bird_cage, "highlight", true)
          else
            api.autosave()
            break
          end
        end
      end,
    },

    return_bird_remains = {
      name = "Returning bird remains",
      enabled = false,
      start_predicate = function(self, rails, dt)
        return rails.entities.bird_cage.interacted_by == State.player
      end,

      run = function(self, rails)
        self.enabled = false
        rails.entities.bird_cage.interacted_by = nil
        rails.entities.bird_cage.interact = nil
        api.narration("Останки птицы очень печально смотрятся в клетке.")
        api.narration("Может, однажды она переродится?")
      end,
    },
  }
end
