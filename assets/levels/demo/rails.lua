local actions = require("core.actions")
local railing = require("tech.railing")
local api = railing.api


return Tablex.extend(railing.mixin(), {
  scenes = {
    {
      name = "Second rotates the valve",
      enabled = true,
      start_predicate = function(self, _, dt) return Common.period(self, 30, dt) end,

      run = function(self, rails, dt)
        if not State:exists(rails.entities[2])
          or rails.entities[2].position ~= rails.positions[2]
        then
          self.enabled = false
          return
        end

        rails.entities[2].direction = "down"
        actions.interact(rails.entities[2])
      end,
    },
    {
      name = "Talking to the first",
      enabled = true,
      start_predicate = function(self, rails, dt)
        return rails.entities[1].talking_to == State.player
      end,

      run = function(self, rails, dt)
        rails.entities[1].talking_to = nil
        api.line(rails.entities[1], "Hi!")
      end,
    }
  },

  active_coroutines = {},

  initialize = function(self)
    self.positions = {
      [2] = Vector({5, 8})
    }

    self.entities = {
      State.grids.solids[Vector({7, 9})],
      State.grids.solids[self.positions[2]],
    }

    self.entities[1]:animate("holding")
    self.entities[1].animation.paused = true
  end,
})
