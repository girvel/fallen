local level = require("tech.level")


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
  }
end
