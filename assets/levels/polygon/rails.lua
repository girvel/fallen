local experience = require("mech.experience")
local railing = require("tech.railing")
local api = railing.api


return function()
  return railing({
    scenes = {
      {
        name = "Checkpoint",
        enabled = true,
        start_predicate = function(self, rails, dt)
          return true
        end,

        run = function(self, rails)
          self.enabled = false

          State.player.experience = experience.for_level[3]
          State.gui.creator:refresh()
          --State.gui.creator:submit()
        end,
      },
    },

    initialize = function(self)
      
    end,
  })
end
