local item = require("tech.item")
local items = require("library.palette.items")
local railing = require("tech.railing")
local ai = require("tech.ai")
local api = ai.api


local hauler, module_mt, static = Module("library.ais.hauler")

local travel_points = {"coal_pickup", "coal_dropoff"}

hauler.get_point = function(i)
  assert(i == 1 or i == 2)
  return State.rails.positions[travel_points[i]]
end

module_mt.__call = function(_)
  return {
    point_i = 1,

    run = ai.async(function(self, entity)
      if entity.position == hauler.get_point(self.point_i) then
        railing.api.wait_seconds(3)
        self.point_i = 3 - self.point_i
        if self.point_i == 2 then
          item.give(entity, State:add(items.coal()))
        else
          State:remove(entity.inventory.underhand)
          entity.inventory.underhand = nil
        end
      end

      api.tcod_travel(entity, hauler.get_point(self.point_i))
    end)
  }
end

return hauler
