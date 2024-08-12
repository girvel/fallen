local level = require("tech.level")
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
        level.move(State.grids.solids, State.player, Vector({32, 97}))
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
      name = "Leaky ventilation",
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
      name = "Enter latrine",
      enabled = true,
      start_predicate = function(self, rails, dt)
        return not State.shader and State.player.position == rails.positions.enter_latrine
      end,

      run = function(self, rails, dt)
        State:set_shader(shaders.latrine)
      end,
    },

    {
      name = "Exit latrine",
      enabled = true,
      start_predicate = function(self, rails, dt)
        return State.shader and State.player.position == rails.positions.exit_latrine
      end,

      run = function(self, rails, dt)
        State:set_shader()
      end,
    },
  }
end
