local railing = require("tech.railing")
local items = require("library.items")


return function()
  return Tablex.extend(railing.mixin(), {
    scenes = Tablex.join(
      require("assets.levels.demo.scenes.1_introduction")(),
      require("assets.levels.demo.scenes.2_tutorial")(),
      require("assets.levels.demo.scenes.3_detective")(),
      require("assets.levels.demo.scenes.3_fight")()
    ),

    initialize = function(self)
      self.positions = {
        [2] = Vector({20, 53}),
        exit = Vector({22, 56}),
        detective_notification_activation = Vector({23, 56}),
        player_room_exit = Vector({15, 75}),
      }

      self.entities = {
        State.grids.solids[Vector({22, 54})],
        State.grids.solids[self.positions[2]],
        State.grids.solids[Vector({20, 48})],
        State.grids.solids[Vector({23, 48})],
        leaking_valve = State.grids.solids[Vector({22, 55})],
        note = State:add(Tablex.extend(
          items.note({colleague_note = true}),
          {position = Vector({19, 78})}
        )),
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
