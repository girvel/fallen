local item = require("tech.item")
local tcod = require("tech.tcod")
local ai = require("tech.ai")
local decorations = require("library.palette.decorations")
local items       = require("library.palette.items")
local api = ai.api


local janitor, module_mt, static = Module("library.ais.janitor")

local TRAVEL_R = 8

module_mt.__call = function(_)
  return {
    run = ai.async(function(self, entity)
      local path
      while true do
        local destination = entity.position + Vector {
          math.random(-TRAVEL_R, TRAVEL_R),
          math.random(-TRAVEL_R, TRAVEL_R),
        }

        path = tcod.snapshot():find_path(entity.position, destination)
        if #path > 2 then break end
      end

      api.follow_path(entity, path)

      local bucket_position, rotation
      for _, direction_name in ipairs(Vector.direction_names) do
        bucket_position = entity.position + Vector[direction_name]
        if not State.grids.solids[bucket_position] then
          rotation = direction_name
          goto position_found
        end
      end
      do return end

      ::position_found::
      entity:rotate(rotation)
      coroutine.yield()

      State:remove(entity.inventory.other_hand)
      entity.inventory.other_hand = nil
      State:add(decorations.bucket(), {position = bucket_position})
      coroutine.yield()

      entity:rotate(Random.choice({"up", "down"}))
      for _ = 1, math.random(5, 10) do
        entity:animate("main_hand_attack")
        api.wait_seconds(.8)
      end

      local e = State.grids.solids[bucket_position]
      if e and (e.codename == "bucket" or e.codename == "bucketd") then
        e.on_remove = nil
        State:remove(e)
      end
      item.give(entity, items.bucket())
      coroutine.yield()
    end, true),
  }
end

return janitor
