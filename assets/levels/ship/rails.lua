local quest = require("tech.quest")
local item = require("tech.item")
local interactive = require("tech.interactive")
local level = require("state.level")
local railing = require("tech.railing")
local decorations = require("library.palette.decorations")
local items       = require("library.palette.items")
local cue         = require("tech.cue")
local sound       = require("tech.sound")
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
            rails.scenes.open_left_megadoor.enabled = true

            -- rails.scenes.son_mary_meeting.enabled = false
            -- rails.scenes.son_mary_curses.enabled = false
            -- api.update_quest({alcohol = 1})
            -- rails.bottles_taken = 1
            -- rails.source_of_first_alcohol = "storage"
          end,
        },
      }
    ),

    _sounds = {},

    initialize = function(self)
      -- sounds --
      if not State.ambient.disabled then
        self._sounds = {
          sound("assets/sounds/ship_engine.mp3", 1)
            :set_looping(true)
            :place(self.positions.engine_sound, "medium")
            :play(),

          sound("assets/sounds/bow_wave.mp3", .7)
            :set_looping(true)
            :place(self.positions.bow_wave_sound, "medium")
            :play(),
        }
      end

      -- entities --
      self.entities.neighbour:rotate("up")
      decorations.lie(self.entities.neighbour, self.entities.upper_bunk.position, "upper")

      self.old_hp = Fun.range(4)
        :map(function(i) return self.entities["engineer_" .. i].hp end)
        :totable()

      self.entities.gloves = self.entities.engineer_3.inventory.gloves

      self.entities.engineer_1:animate("holding")
      self.entities.engineer_1:animation_set_paused(true)

      State:refresh(self.entities.mirage_block, interactive.detector())
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

      State:refresh(self.entities.soup_cauldron, interactive.detector(), {name = "кастрюля"})
    end,

    been_to_latrine = false,
    tolerates_latrine = nil,
    dreamers_talked_to = {},
    bottles_taken = 0,
    has_valve = false,
    resists_son_mary = false,
    source_of_first_alcohol = false,
    has_sigi = false,
    seen_water = false,
    met_son_mary = false,

    give_valve_to_player = function(self)
      self.has_valve = true
      State:remove(self.entities.captain_door_valve)
      self.entities.guard_2.inventory.other_hand = nil
      cue.set(self.entities.captain_door, "highlight", true)
    end,

    -- maybe it can be coupled with quests into a state machine
    -- or at least all grouped somewhere
    rront_runs_away = function(self)
      State:remove(self.entities.engineer_3)
      api.notification("Задача выполнена неудовлетворительно", true)
      api.update_quest({detective = quest.FAILED})
      self:lunch_starts()
    end,

    notice_flask = function(self)
      local e = self.entities.flask_dreamer
      if State:exists(e) then
        cue.set(e, "highlight", true)
      end
    end,

    --- @param state "found" | "needed"
    sigi_update = function(self, state)
      if state == "found" then
        self.has_sigi = true
      else
        api.update_quest({sigi = 1})
      end

      if self.has_sigi and api.get_quest("sigi") == 1 then
        api.update_quest({sigi = 2})
        self.scenes.markiss:activate_option(7)
      end
    end,

    lunch_starts = function(self)
      self.scenes.cauldron_before.enabled = false
      self.scenes.cauldron_after.enabled = true
      cue.set(self.entities.soup_cauldron, "highlight", true)
    end,
  })
end
