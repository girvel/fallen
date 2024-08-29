local interactive = require("tech.interactive")
local level = require("state.level")
local railing = require("tech.railing")
local api = railing.api


return function(positions, entities)
  return railing({
    positions = positions,
    entities = entities,

    scenes = Table.join(
      require("assets.levels.demo.scenes.1_introduction")(),
      require("assets.levels.demo.scenes.2_tutorial")(),
      require("assets.levels.demo.scenes.2_side_content")(),
      require("assets.levels.demo.scenes.3_detective")(),
      require("assets.levels.demo.scenes.3_fight")(),
      {
        checkpoint_0 = {
          name = "Checkpoint -- captain's deck",
          enabled = false,
          start_predicate = function(self, rails, dt)
            return true
          end,

          run = function(self, rails, dt)
            self.enabled = false
            level.move(State.player, Vector({28, 9}))
            api.autosave()
          end,
        },
      }
    ),

    initialize = function(self)
      self.been_to_latrine = false
      self.tolerates_latrine = nil

      self.entities.neighbour:rotate("up")
      self.entities.upper_bunk:lie(self.entities.neighbour)

      self.dreamers_talked_to = {}
      self.old_hp = Fun.range(4)
        :map(function(i) return self.entities["engineer_" .. i].hp end)
        :totable()

      self.entities.gloves = self.entities.engineer_3.inventory.gloves

      self.entities.engineer_1:animate("holding")
      self.entities.engineer_1:animation_set_paused(true)

      State:refresh(self.entities.mirage_block, interactive.detector(true))
    end,
  })
end
