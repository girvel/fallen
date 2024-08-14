local interactive = require("tech.interactive")
local mobs = require("library.mobs")
local level = require("state.level")
local api = require("tech.railing").api
local shaders = require("tech.shaders")


return function()
  return {
    checkpoint_2 = {
      name = "Checkpoint (2)",
      enabled = false,
      start_predicate = function(self, rails, dt) return true end,

      run = function(self, rails, dt)
        self.enabled = false
        level.move(State.player, Vector({28, 97}))
        State.player.hp = 20
      end,
    },

    {
      name = "Player leaves his room",
      enabled = true,
      start_predicate = function(self, rails, dt)
        return (State.player.position - rails.positions.player_room_exit):abs() > 7
      end,

      run = function(self, rails, dt)
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

      run = function(self, rails, dt)
        self.enabled = false
        if not State.player.inventory.main_hand then
          api.notification("Найди себе подходящее оружие", true)
          api.update_quest({warmup = 3})
        end
        rails.scenes.warmup.enabled = true
      end,
    },

    warmup = {
      name = "Warmup itself",
      enabled = false,
      start_predicate = function(self, rails, dt)
        return State.player.inventory.main_hand
      end,

      run = function(self, rails, dt)
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
            if rails.entities.mannequin.hp < old_hp then
              old_hp = rails.entities.mannequin.hp
              api.notification(remark, true)
              break
            end
            if not miss_remarked
              and State:check_aggression(State.player, rails.entities.mannequin)
            then
              api.notification("Целься лучше, в настоящем бою они будут ещё и двигаться", true)
              miss_remarked = true
            end
            coroutine.yield()
          end
        end

        api.notification("Методичка на столе", true)
        api.notification("Запусти блок миража, чтобы перейти к демонстрации", true)
        api.update_quest({warmup = 5})
      end,
    },

    {
      name = "Phantom fight",
      enabled = true,
      start_predicate = function(self, rails, dt)
        return rails.entities.mirage_block.interacted_by == State.player
      end,

      run = function(self, rails, dt)
        self.enabled = false
        rails.entities.mirage_block.interact = nil
        rails.scenes.warmup.enabled = false

        api.narration("Это небольшой, размером с тумбочку, черно-желтый куб; на его верхней грани размещено стекло.")
        api.narration("В нижней части стекла расположены три кнопки: два треугольника, смотрящие в разные стороны, и круг.")
        api.narration("За стеклом лежит пергамент с схемой человеческого организма; рисунок ёмко подписан:")
        api.line(State.player, "”Самое страшное животное - Человек”")

        local options = {
          "Нажать на один из треугольников",
          "Нажать на круг",
        }

        local e
        while true do
          if api.options(options, true) == 1 then
            api.narration("После нажатия, пергамент исчезает в глубине блока, а потом снова всплывает с противоположной стороны")
          else
            api.narration("Блок громко жужжит, после чего выпускает из левой грани множество потоков световых лучей.")
            api.narration("В конце комнаты свет формирует призрачную фигуру рыцаря.")

            e = State:add(mobs.phantom_knight(), {position = Vector({31, 97})})
            if api.ability_check("arcana", 10) then
              api.narration("Это обыкновенная иллюзия, она не может причинять вряд.")
              api.narration("Должно быть, машина создает фантом на основе схемы.")
            else
              api.narration("Машина призвала воителя из былых времён.")
              api.narration("Ты должен показать ему, на что способен.")
            end
            break
          end
        end

        State:start_combat({State.player, e})
        api.notification("Твой ход.", true)

        local popup = {}
        while State.combat do
          if State.combat:get_current() ~= State.player then break end
          if State.player.resources.movement == 0 then
            popup = api.message("Больше двигаться ты не сможешь, время передать ход")
            break
          end
          coroutine.yield()
        end

        if State.combat then
          api.wait_while(function() return State.combat:get_current() == State.player end)
          api.wait_while(function() return State.combat:get_current() ~= State.player end)
          State:remove_multiple(popup)
          api.message("Это всего лишь иллюзия.")
          api.wait_seconds(2)
          api.notification("Добей иллюзию", true)
        end

        api.wait_while(function() return State.combat end)
        api.notification("Покорми птицу в клетке", true)
        api.update_quest({warmup = 6})

        Tablex.extend(rails.entities.bird_food, interactive.detector(), {name = "ящик"})
        Tablex.extend(rails.entities.bird_cage, interactive.detector(), {name = "клетка"})
      end,
    },

    {
      name = "Look in the crate",
      enabled = true,
      start_predicate = function(self, rails, dt)
        return rails.entities.bird_food.interacted_by == State.player
      end,

      run = function(self, rails, dt)
        rails.entities.bird_food.interacted_by = nil

        api.narration("В ящике лежит небольшое ведёрко.")
        api.narration("Внутри — приятно пахнущие зёрна.")

        if api.options({
          "*Взять горсть*",
          "*Закрыть ящик*",
        }) == 1 then
          rails.entities.bird_food.interact = nil
          rails.has_bird_food = true
        end
      end,
    },

    {
      name = "Look in the cage",
      enabled = true,
      start_predicate = function(self, rails, dt)
        return rails.entities.bird_cage.interacted_by == State.player
      end,

      run = function(self, rails, dt)
        rails.entities.bird_cage.interacted_by = nil

        api.narration("Это птичья клетка")
        api.narration("Без птицы")
        api.narration("Хотя здесь есть много помёта")
        api.narration("И немного перьев")

        local options = {
          "*уйти*",
        }

        if rails.has_bird_food then
          table.insert(options, 1, "*положить корм в клетку*")
        end

        if api.options(options) ~= #options then
          rails.entities.bird_cage.interact = nil
          rails.has_bird_food = false

          api.update_quest({warmup = 7, detective = 1})
          rails.entities.detective_door.locked = false
          api.notification("Разминка окончена")
          api.wait_seconds(5)
          api.notification("Направляйся к комнате с черной дверью.", true)
        end
      end,
    },
  }
end
