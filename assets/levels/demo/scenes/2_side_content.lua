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
