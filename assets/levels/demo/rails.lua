local level = require("state.level")
local railing = require("tech.railing")
local api = railing.api


return function(positions, entities)
  return railing({
    positions = positions,
    entities = entities,

    scenes = Table.join(
      require("assets.levels.demo.scenes.1_introduction")(),
      -- require("assets.levels.demo.scenes.2_tutorial")(),
      -- require("assets.levels.demo.scenes.2_side_content")(),
      require("assets.levels.demo.scenes.3_detective")(),
      -- require("assets.levels.demo.scenes.3_fight")(),
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
      -- self.positions = {
      --   [2] = {20, 53},
      --   exit = {22, 56},
      --   detective_notification_activation = {23, 56},
      --   player_room_exit = {15, 75},
      --   leaky_vent_check = {11, 79},
      --   enter_latrine = {28, 104},
      --   exit_latrine = {28, 103},
      --   beds_check = {11, 73},
      --   world_map_message = {11, 91},
      --   scratched_table_message = {45, 92},
      --   empty_dorm_message = {22, 68},
      --   sign_message = {27, 91},
      --   mouse_check = {28, 85},
      --   dirty_magazine = {24, 105},
      --   kitchen_bucket = {22, 101},
      --   officer_room_enter = {31, 97},
      --   detective_exit_warning = {20, 56},
      -- }

      -- self.positions = Fun.pairs(self.positions)
      --   :map(function(k, v) return k, Vector(v) end)
      --   :tomap()

      -- self.entities = self:initialize_entities()

      self.been_to_latrine = false
      self.tolerates_latrine = nil

      self.entities.neighbour:rotate("up")
      self.entities.upper_bunk:lie(self.entities.neighbour)

      self.dreamers_talked_to = {}
      self.old_hp = Fun.range(4)
        :map(function(i) return self.entities["engineer_" .. i].hp end)
        :totable()
    end,

    -- initialize_entities = Dump.ignore_upvalue_size .. function(self)
    --   local result = Fun.pairs({
    --     {22, 54},
    --     self.positions[2],
    --     {20, 48},
    --     {23, 48},
    --     leaking_valve = {22, 55},
    --     device_panel = {21, 48},
    --     neighbour = {20, 77},
    --     upper_bunk = {20, 74},
    --     dining_room_door_1 = {24, 100},
    --     dining_room_door_2 = {26, 97},
    --     mannequin = {37, 95},
    --     bird_food = {33, 102},
    --     bird_cage = {32, 102},
    --   })
    --     :map(function(k, v) return k, State.grids.solids[Vector(v)] end)
    --     :tomap()

    --   result.note = State:add(
    --     note({colleague_note = true}),
    --     {position = Vector({19, 78})}
    --   )

    --   result.detective_door = State:add(
    --     live.black_door({locked = true}),
    --     {position = Vector({21, 56})}
    --   )

    --   result.gloves = result[3].inventory.gloves

    --   result[1]:animate("holding")
    --   result[1]:animation_set_paused(true)

    --   result.neighbour:rotate("up")
    --   result.upper_bunk:lie(result.neighbour)

    --   State:add(walls.steel_with_map(), {position = Vector({10, 90})})
    --   State:add(decorations.scratched_table(), {position = Vector({45, 91})})
    --   State:add(decorations.empty_bed(), {position = Vector({23, 67})})
    --   State:add(walls.steel_with_sign(), {position = Vector({27, 90})})
    --   result.colored_pipe = State:add(Table.extend(
    --     pipes.colored(),
    --     {position = Vector({27, 95})}
    --   ))
    --   State:add(things.magazine(), {position = self.positions.dirty_magazine})
    --   result.cook = State:add(
    --     mobs.old_dreamer(), interactive.detector(true), {position = Vector({19, 102})}
    --   )

    --   State:add(note({fighting_guide = true}), {position = Vector({32, 96})})
    --   result.mirage_block = State:add(
    --     decorations.mirage_block(),
    --     interactive.detector(true),
    --     {position = Vector({37, 101})}
    --   )

    --   return result
    -- end
  })
end
