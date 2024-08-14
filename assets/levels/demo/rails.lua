local mobs = require("library.mobs")
local things = require("library.things")
local pipes = require("library.pipes")
local decorations = require("library.decorations")
local walls = require("library.walls")
local level = require("state.level")
local railing = require("tech.railing")
local api = railing.api
local live = require("library.live")
local interactive = require("tech.interactive")
local sprite = require("tech.sprite")


local note = function()
  return Tablex.extend(
    interactive(function(self, other)
      self.interacted_by = other
      State:remove(self)
    end),
    {
      sprite = sprite.image("assets/sprites/note.png"),
      codename = "note",
      layer = "above_solids",
      view = "scene",
      name = "записка",
    }
  )
end

return function()
  return Tablex.extend(railing.mixin(), {
    scenes = Tablex.join(
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
          end,
        },
      }
    ),

    initialize = function(self)
      self.positions = {
        [2] = {20, 53},
        exit = {22, 56},
        detective_notification_activation = {23, 56},
        player_room_exit = {15, 75},
        leaky_vent_check = {11, 79},
        enter_latrine = {28, 104},
        exit_latrine = {28, 103},
        beds_check = {11, 73},
        world_map_message = {11, 91},
        scratched_table_message = {45, 92},
        empty_dorm_message = {22, 68},
        sign_message = {27, 91},
        mouse_check = {28, 85},
        dirty_magazine = {24, 105},
        kitchen_check = {23, 102},
        officer_room_enter = {31, 97},
      }

      self.positions = Fun.pairs(self.positions)
        :map(function(k, v) return k, Vector(v) end)
        :tomap()

      self.entities = {
        {22, 54},
        self.positions[2],
        {20, 48},
        {23, 48},
        leaking_valve = {22, 55},
        neighbour = {20, 77},
        upper_bunk = {20, 74},
        dining_room_door_1 = {24, 100},
        dining_room_door_2 = {26, 97},
        mannequin = {37, 95},
      }

      self.entities = Fun.pairs(self.entities)
        :map(function(k, v) return k, State.grids.solids[Vector(v)] end)
        :tomap()

      self.entities.note = State:add(Tablex.extend(
        note(),
        {position = Vector({19, 78})}
      ))
      self.entities.detective_door = State:add(Tablex.extend(
        live.black_door({locked = true}),
        {position = Vector({21, 56})}
      ))

      self.been_to_latrine = false
      self.tolerates_latrine = nil

      self.entities.gloves = self.entities[3].inventory.gloves

      self.entities[1]:animate("holding")
      self.entities[1]:animation_set_paused(true)

      self.dreamers_talked_to = {}
      self.old_hp = Fun.range(4)
        :map(function(i) return self.entities[i].hp end)
        :totable()

      self.entities.neighbour:rotate("up")
      self.entities.upper_bunk:lie(self.entities.neighbour)

      State:add(walls.steel_with_map(), {position = Vector({10, 90})})
      State:add(decorations.scratched_table(), {position = Vector({45, 91})})
      State:add(decorations.empty_bed(), {position = Vector({23, 67})})
      State:add(walls.steel_with_sign(), {position = Vector({27, 90})})
      self.entities.colored_pipe = State:add(Tablex.extend(
        pipes.colored(),
        {position = Vector({27, 95})}
      ))
      State:add(things.magazine(), {position = self.positions.dirty_magazine})
      self.entities.cook = State:add(
        mobs.dreamer(), interactive.detector(true), {position = Vector({19, 102})}
      )
    end,
  })
end
