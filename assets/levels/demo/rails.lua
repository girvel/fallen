local actions = require("core.actions")
local railing = require("tech.railing")


return Tablex.extend(railing.mixin(), {
  scenes = {
    {
      name = "Second rotates the valve",
      enabled = true,
      start_predicate = function(self, _, dt) return Common.period(self, 30, dt) end,

      run = function(self, rails, dt)
        if not State:exists(rails.entities.second)
          or rails.entities.second.position ~= rails.positions.second
        then
          self.enabled = false
          return
        end

        rails.entities.second.direction = "down"
        actions.interact(rails.entities.second)
      end,
    },
  },

  active_coroutines = {},

  initialize = function(self)
    self.positions = {
      second = Vector({5, 8})
    }

    self.entities = {
      first = State.grids.solids[Vector({7, 9})],
      second = State.grids.solids[self.positions.second],
    }

    self.entities.first:animate("holding")
    self.entities.first.animation.paused = true
  end,
})
