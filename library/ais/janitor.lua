local tcod = require("tech.tcod")
local ai = require("tech.ai")
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

      entity:rotate(Random.choice({"up", "down"}))
      for _ = 1, math.random(5, 10) do
        entity:animate("main_hand_attack")
        api.wait_seconds(.8)
      end
    end, true),
  }
end

return janitor
