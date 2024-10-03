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

          api.checkpoint_base()
          State.player.experience = experience.for_level[2]
          State.gui.creator:refresh()
          State.gui.creator:submit()

          api.discover_wiki({colleague_note = true})
          api.update_quest({warmup = 3})
        end,
      },
    },

    initialize = function(self)
      
    end,
  })
end
