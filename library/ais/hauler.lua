local hauler, module_mt, static = Module("library.ais.hauler")

local travel_points = {"coal_pickup", "coal_dropoff"}

hauler.get_point = function(i)
  assert(i == 1 or i == 2)
  return State.rails.positions[travel_points[i]]
end

module_mt.__call = function(_)
  return {
    run = function()
      
    end
  }
end

return hauler
