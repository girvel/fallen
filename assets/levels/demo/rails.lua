local railing = require("tech.railing")


return function()
  return Tablex.extend(railing.mixin(), {
    scenes = Tablex.join(
      require("assets.levels.demo.scenes.1_tutorial")(),
      require("assets.levels.demo.scenes.3_detective")(),
      require("assets.levels.demo.scenes.3_fight")()
    ),

    initialize = function(self)
      self.positions = {
        [2] = Vector({20, 53}),
        exit = Vector({22, 56}),
        intro_activation = Vector({23, 56}),
      }

      self.entities = {
        State.grids.solids[Vector({22, 54})],
        State.grids.solids[self.positions[2]],
        State.grids.solids[Vector({20, 48})],
        State.grids.solids[Vector({23, 48})],
        leaking_valve = State.grids.solids[Vector({22, 55})],
      }

      self.entities.gloves = self.entities[3].inventory.gloves

      self.entities[1]:animate("holding")
      self.entities[1]:animation_set_paused(true)

      self.dreamers_talked_to = {}
      self.old_hp = Fun.range(4)
        :map(function(i) return self.entities[i].hp end)
        :totable()
    end,
  })
end
