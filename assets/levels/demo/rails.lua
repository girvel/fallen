local railing = require("tech.railing")


return function()
  return Tablex.extend(railing.mixin(), {
    scenes = Tablex.join(
      require("assets.levels.demo.scenes.detective")(),
      require("assets.levels.demo.scenes.fight")()
    ),

    active_coroutines = {},

    initialize = function(self)
      self.positions = {
        [2] = Vector({5, 8}),
        exit = Vector({7, 11}),
      }

      self.entities = {
        State.grids.solids[Vector({7, 9})],
        State.grids.solids[self.positions[2]],
        State.grids.solids[Vector({5, 3})],
        State.grids.solids[Vector({8, 3})],
        leaking_valve = State.grids.solids[Vector({7, 10})],
      }

      self.entities.gloves = self.entities[3].inventory.gloves

      self.entities[1]:animate("holding")
      self.entities[1].animation.paused = true

      self.dreamers_talked_to = 0
      self.old_hp = Fun.range(4)
        :map(function(i) return self.entities[i].hp end)
        :totable()
    end,
  })
end
