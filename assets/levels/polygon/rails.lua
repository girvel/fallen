local railing = require("tech.railing")
local api = railing.api


local lorem = "Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book."

return function()
  return railing({
    scenes = {
      {
        name = "Testing",
        enabled = true,
        start_predicate = function(self, rails, dt) return true end,

        run = function(self, rails, dt)
          self.enabled = false
          api.narration("hi")
        end,
      },
    },

    initialize = function(self)
      self.entities = {
        mannequin = State.grids.solids[Vector({9, 7})],
      }

      self.last_mannequin_hp = self.entities.mannequin.hp
    end,
  })
end
