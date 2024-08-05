local experiments = {}

experiments.serialization = function()
  local serpent = require("lib.serpent")

  -- test function serialization
  local f = function(x)
    Log.info(x)
  end
  loadstring(serpent.dump(f))()("Serialization works!")

  -- test LOVE2D data serialization
  local image = love.graphics.newImage("assets/sprites/bushes.png")
  -- Log.trace(loadstring(serpent.dump(image))():getDimensions())
  -- DOES NOT WORK

  -- test dump size
  local state_dump = serpent.dump(State)
  Log.info("Serialized state is %.2f KB" % (#state_dump / 1024))
end

return experiments
