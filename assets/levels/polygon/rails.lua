local decorations = require("library.palette.decorations")
local experience = require("mech.experience")
local railing = require("tech.railing")
local api = railing.api


return function(positions, entities)
  return railing {
    positions = positions,
    entities = entities,
    scenes = {
      {
        name = "Checkpoint",
        enabled = true,

        characters = {
          player = {},
          lyer = {},
        },

        start_predicate = function(self, rails, dt)
          return true
        end,

        run = function(self, rails, c)
          self.enabled = false

          api.checkpoint_base()
          State.player.experience = experience.for_level[2]
          State.gui.creator:refresh()

          api.discover_wiki({colleague_note = true})
          api.update_quest({warmup = 3})

          -- decorations.lie(rails.entities.lyer, rails.positions.lower_bunk, "lower")
          api.wait_seconds(1)
          api.line(c.lyer, "Oh hi Mark")
        end,
      },
    },

    initialize = function(self)
      
    end,
  }
end
