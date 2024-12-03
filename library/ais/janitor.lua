local hostility = require("mech.hostility")
local item = require("tech.item")
local tcod = require("tech.tcod")
local ai = require("tech.ai")
local decorations = require("library.palette.decorations")
local items       = require("library.palette.items")
local railing     = require("tech.railing")
local combat      = require("library.ais.combat")
local api = ai.api


local janitor, module_mt, static = Module("library.ais.janitor")

local TRAVEL_R = 8

local peaceful_module = function()
  return {
    _current_line = 0,
    _lines = {
      "Ой.",
      "Опять пролилась.",
      "Пожалуйста, не делай этого.",
      "Ты это специально?",
      "Ещё раз и у тебя будут проблемы.",
      "Ну всё, я тебе покажу!",
    },
    _popup = {},

    run = ai.async(function(self, entity)
      -- 1. go to a new place --
      do
        local path
        for y = -TRAVEL_R, TRAVEL_R do
          for x = -TRAVEL_R, TRAVEL_R do
            local position = entity.position + Vector {x, y}
            local blood = State.grids.on_tiles:safe_get(position)
            if blood and blood.codename == "blood" then
              path = tcod.snapshot():find_path(entity.position, position)
              if #path > 0 then
                goto follow_path
              else
                path = nil
              end
            end
          end
        end

        while not path do
          local destination = entity.position + Vector {
            math.random(-TRAVEL_R, TRAVEL_R),
            math.random(-TRAVEL_R, TRAVEL_R),
          }

          path = tcod.snapshot():find_path(entity.position, destination)
          if #path <= 2 then path = nil end
          coroutine.yield()
        end

        ::follow_path::
        api.follow_path(entity, path)
      end

      -- 2. place the bucket --
      local bucket_position, bucket_direction_name
      for _, direction_name in ipairs(Vector.direction_names) do
        bucket_position = entity.position + Vector[direction_name]
        if not State.grids.solids[bucket_position] then
          bucket_direction_name = direction_name
          goto position_found
        end
      end
      do return end

      ::position_found::
      entity:rotate(bucket_direction_name)
      coroutine.yield()

      State:remove(entity.inventory.other_hand)
      entity.inventory.other_hand = nil
      State:add(decorations.bucket(), {position = bucket_position})
      coroutine.yield()

      -- 3. mop the floor --
      local washing_direction_name = Random.choice({"up", "down"})
      entity:rotate(washing_direction_name)
      for _ = 1, math.random(5, 10) do
        entity:animate("main_hand_attack")
        api.wait_seconds(.8)

        local current_bucket = State.grids.solids[bucket_position]
        if current_bucket.codename == "bucketd" then
          entity:rotate(bucket_direction_name)
          coroutine.yield()

          self._current_line = self._current_line + 1
          if State:exists(self._popup[1]) then
            State:remove_multiple(self._popup)
          end
          self._popup = railing.api.message.temporal(self._lines[self._current_line], {source = entity})
          coroutine.yield()

          if self._current_line == #self._lines then
            hostility.make_hostile(entity.faction)
            return
          end

          current_bucket.on_remove = function()
            State:add(decorations.bucket(), {position = current_bucket.position})
          end
          State:remove(current_bucket)
          coroutine.yield()

          entity:rotate(washing_direction_name)
        end
      end

      local blood = State.grids.on_tiles[entity.position]
      if -Query(blood).codename == "blood" then
        State:remove(blood)
      end

      -- 4. pick up the bucket --
      local e = State.grids.solids[bucket_position]
      if e and (e.codename == "bucket" or e.codename == "bucketd") then
        e.on_remove = nil
        State:remove(e)
      end
      item.give(entity, items.bucket())
      coroutine.yield()
    end),
  }
end

module_mt.__call = function(_)
  return {
    _combat_module = combat(),
    _peace_module = peaceful_module(),

    run = function(self, entity, dt)
      if hostility.are_hostile(entity, State.player) then
        return self._combat_module:run(entity, dt)
      else
        if not State.combat then
          return self._peace_module:run(entity, dt)
        end
      end
    end,

    observe = function(self, ...)
      return self._combat_module:observe(...)
    end,
  }
end

return janitor
