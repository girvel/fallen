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
          while true do
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
  }
end
