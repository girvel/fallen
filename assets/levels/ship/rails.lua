local interactive = require("tech.interactive")
local level = require("state.level")
local railing = require("tech.railing")
local decorations = require("library.palette.decorations")
local api = railing.api


return function(positions, entities)
  return railing({
    positions = positions,
    entities = entities,

    scenes = Table.join(
      require("assets.levels.ship.scenes.1_introduction")(),
      require("assets.levels.ship.scenes.2_tutorial")(),
      require("assets.levels.ship.scenes.2_side_content")(),
      require("assets.levels.ship.scenes.3_detective")(),
      require("assets.levels.ship.scenes.3_fight")(),
      require("assets.levels.ship.scenes.3_dwarf")(),
      require("assets.levels.ship.scenes.4_markiss")(),
      {
        checkpoint_0 = {
          name = "Checkpoint -- captain's deck",
          enabled = false,
          start_predicate = function(self, rails, dt)
            return true
          end,

          run = function(self, rails, dt)
            rails:remove_scene("checkpoint_0")
            level.move(State.player, rails.positions.checkpoint_0)
          end,
        },
      }
    ),

    initialize = function(self)
      self.entities.neighbour:rotate("up")
      decorations.lie(self.entities.neighbour, self.entities.upper_bunk)

      self.old_hp = Fun.range(4)
        :map(function(i) return self.entities["engineer_" .. i].hp end)
        :totable()

      self.entities.gloves = self.entities.engineer_3.inventory.gloves

      self.entities.engineer_1:animate("holding")
      self.entities.engineer_1:animation_set_paused(true)

      State:refresh(self.entities.mirage_block, interactive.detector(true))
    end,

    been_to_latrine = false,
    tolerates_latrine = nil,
    dreamers_talked_to = {},
  })
end
