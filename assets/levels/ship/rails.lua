local item = require("tech.item")
local interactive = require("tech.interactive")
local level = require("state.level")
local railing = require("tech.railing")
local decorations = require("library.palette.decorations")
local items       = require("library.palette.items")
local cue         = require("tech.cue")
local shaders     = require("tech.shaders")
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
      require("assets.levels.ship.scenes.4_ship")(),
      require("assets.levels.ship.scenes.4_son_mary")(),
      {
        checkpoint_0 = {
          name = "Checkpoint -- captain's deck",
          enabled = false,
          start_predicate = function(self, rails, dt)
            return true
          end,

          run = function(self, rails)
            rails:remove_scene("checkpoint_0")
            level.move(State.player, rails.positions.checkpoint_0)
            rails.entities.captain_door:open()
          end,
        },
      }
    ),

    initialize = function(self)
      self.entities.neighbour:rotate("up")
      decorations.lie(self.entities.neighbour, self.entities.upper_bunk.position, "upper")

      self.old_hp = Fun.range(4)
        :map(function(i) return self.entities["engineer_" .. i].hp end)
        :totable()

      self.entities.gloves = self.entities.engineer_3.inventory.gloves

      self.entities.engineer_1:animate("holding")
      self.entities.engineer_1:animation_set_paused(true)

      State:refresh(self.entities.mirage_block, interactive.detector())
      State:refresh(self.entities.alcohol_crate, interactive.detector(true), {name = "ящик"})
      cue.set(self.entities.alcohol_crate, "highlight", true)

      self.entities.razor = State:add(items.razor())
      self.entities.dorm_halfling.inventory[1] = self.entities.razor

      self.entities.captain_door_note.interact = nil
      cue.set(self.entities.captain_door_note, "highlight", false)
      cue.set(self.entities.captain_door, "highlight", true)

      State:remove(self.entities.guard_2.inventory.other_hand)
      self.entities.guard_2.inventory.other_hand = nil
      self.entities.captain_door_valve = State:add(items.large_valve())
      item.give(self.entities.guard_2, self.entities.captain_door_valve)

      self.entities.gas_key = self.entities.engineer_1.inventory.main_hand
    end,

    been_to_latrine = false,
    tolerates_latrine = nil,
    dreamers_talked_to = {},
    bottles_taken = 0,
    has_valve = false,
    met_son_mary = false,
    resists_son_mary = false,

    give_valve_to_player = function(self)
      self.has_valve = true
      State:remove(self.entities.captain_door_valve)
      self.entities.guard_2.inventory.other_hand = nil
    end,
  })
end
