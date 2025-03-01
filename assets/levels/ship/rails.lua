local abilities = require("mech.abilities")
local sprite = require("tech.sprite")
local on_tiles = require("library.palette.on_tiles")
local mobs = require("library.palette.mobs")
local health = require("mech.health")
local quest = require("tech.quest")
local item = require("tech.item")
local interactive = require("tech.interactive")
local level = require("tech.level")
local railing = require("tech.railing")
local decorations = require("library.palette.decorations")
local items       = require("library.palette.items")
local cue         = require("tech.cue")
local sound       = require("tech.sound")
local iteration   = require("tech.iteration")
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
        cp1 = {
          name = "Checkpoint Base",
          enabled = false,
          start_predicate = function(self, rails, dt)
            return true
          end,

          run = function(self, rails)
            self.enabled = false

            -- local INTRO_SCENES = {"intro", "character_created", "warning_leaving_player_room"}
            -- for _, s in ipairs(INTRO_SCENES) do
            --   rails:remove_scene(s)
            -- end

            State.gui.creator._ability_points = 0
            State.gui.creator._mixin.base_abilities = abilities(15, 15, 15, 8, 8, 8)
            State.gui.creator._choices.race = 2
            api.center_camera()
          end,
        },

        cp0 = {
          name = "Checkpoint -- captain's deck",
          enabled = false,
          start_predicate = function(self, rails, dt)
            return true
          end,

          run = function(self, rails)
            rails.scenes.cp1:run(rails)

            rails:remove_scene("cp0")
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

    initialize = function(self)
      -- sounds --
      if not State.ambient.disabled then
        sound("assets/sounds/ship_engine.mp3", 1)
          :set_looping(true)
          :place(self.positions.engine_sound, "medium")
          :play()

        sound("assets/sounds/engine_electricity.mp3", .2)
          :set_looping(true)
          :place(self.positions.engine_electricity, "medium")
          :play()

        sound("assets/sounds/bow_wave.mp3", .7)
          :set_looping(true)
          :place(self.positions.bow_wave_sound, "medium")
          :play()
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
      self.entities.dorm_halfling.inventory.inside = self.entities.razor

      self.entities.captain_door_note.interact = nil
      cue.set(self.entities.captain_door_note, "highlight", false)
      cue.set(self.entities.captain_door, "highlight", true)

      State:remove(self.entities.guard_2.inventory.other_hand)
      self.entities.guard_2.inventory.other_hand = nil
      self.entities.captain_door_valve = State:add(items.large_valve())
      item.give(self.entities.guard_2, self.entities.captain_door_valve)

      self.entities.gas_key = self.entities.engineer_1.inventory.main_hand

      State:refresh(self.entities.soup_cauldron, interactive.detector(), {name = "кастрюля"})

      self.entities.son_mary.sprite.color = Colors.from_hex("df529e")

      decorations.lie(self.entities.sleeping_dreamer_1, self.positions.bed_1, "lower")
      decorations.lie(self.entities.sleeping_dreamer_2, self.positions.bed_2, "upper")

      self.entities.bird_food.interact = nil
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
    flask_noticed = false,
    lunch_started = false,
    money = 0,
    has_bird_food = false,

    spawn_possessed = function(self)
      self.entities.dining_room_door_1:close()
      self.entities.dining_room_door_2:close()
      self.scenes.sees_possessed.enabled = false
      self.scenes.sees_possessed_again.enabled = true
      self.scenes.kills_possessed.enabled = true
      self.entities.possessed = State:add(mobs.possessed(), {
        position = self.positions.possessed_spawn
      })
      State:add(on_tiles.blood(), {position = self.positions.possessed_spawn})
    end,

    give_valve_to_player = function(self)
      self.has_valve = true
      State:remove(self.entities.captain_door_valve)
      self.entities.guard_2.inventory.other_hand = nil
      cue.set(self.entities.captain_door, "highlight", true)
    end,

    -- maybe it can be coupled with quests into a state machine
    -- or at least all grouped somewhere
    rront_runs_away = function(self)
      if not State:exists(self.entities.engineer_3) then return end
      State:remove(self.entities.engineer_3)
      api.notification("Задача выполнена неудовлетворительно", true)
      api.update_quest({detective = quest.FAILED})
      self:start_lunch()
      self.scenes.son_mary_ally:activate_people_option(3)
    end,

    notice_flask = function(self)
      local e = self.entities.canteen_dreamer_flask
      self.flask_noticed = true
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

    start_lunch = function(self)
      self.lunch_started = true

      -- cauldron shenanigans --
      self.scenes.cauldron_before.enabled = false
      self.scenes.cauldron_after.enabled = true
      cue.set(self.entities.soup_cauldron, "highlight", true)
      if State:exists(self.entities.cook) then
        level.move(self.entities.cook, self.positions.cook_chilling)
      end

      -- canteen killers --
      self.scenes.kills_possessed.enabled = false
      local did_dreamers_kill_possessed = State:exists(self.entities.possessed)
      if did_dreamers_kill_possessed then
        health.damage(self.entities.possessed, 1000)
      end

      local possessed_position = -Query(self.entities.possessed).position

      if
        not possessed_position
        or (possessed_position - self.positions.possessed_spawn):abs() > 10
      then
        possessed_position = self.positions.possessed_spawn
      end

      local killer_counter = 0
      for d in iteration.expanding_rhombus() do
        if d == Vector.zero then goto continue end
        local v = d + possessed_position
        if State.grids.solids:safe_get(v) then goto continue end

        killer_counter = killer_counter + 1
        if killer_counter == 3 and did_dreamers_kill_possessed then
          State:add(on_tiles.blood(), {position = v})
          break
        end

        self.entities["canteen_killer_" .. killer_counter] = State:add(
          mobs.dreamer({faction = "canteen_killers"}),
          {position = v, direction = Vector.name_from_direction(-d:normalized())}
        )

        if killer_counter == 3 and not did_dreamers_kill_possessed then break end
        ::continue::
      end

      -- canteen dreamers --
      for i = 1, 3 do
        local p = self.positions["canteen_dreamer_spawn_" .. i]
        for d in iteration.expanding_rhombus() do
          if not State.grids.solids:safe_get(p + d) then
            State:add(
              mobs.dreamer({faction = "canteen_dreamers"}),
              {position = p + d, direction = "left"}
            )
            break
          end
        end
      end

      -- flask dreamer --
      for d in iteration.expanding_rhombus() do
        local v = self.positions.canteen_dreamer_spawn_flask + d
        if not State.grids.solids:safe_get(v) then
          self.entities.canteen_dreamer_flask = State:add(
            mobs.dreamer({faction = "canteen_dreamers", race = "half_elf"}),
            {
              position = v,
              inventory = {right_pocket = items.flask()},
              portrait = sprite.image("assets/sprites/portraits/half_elf.png"),
            }
          )
          break
        end
      end

      if self.flask_noticed then
        cue.set(self.entities.canteen_dreamer_flask, "highlight", true)
      end
    end,
  })
end
