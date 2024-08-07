local mobs = require("library.mobs")
local player = require("state.player")


local experiments = {}

experiments.serialization_old = function()
  -- test function serialization
  local f = function(x)
    Log.info(x)
  end
  loadstring(Dump(f))()("Serialization works!")

  -- test LOVE2D data serialization
  local image = love.graphics.newImage("assets/sprites/bushes.png")
  -- Log.trace(loadstring(serpent.dump(image))():getDimensions())
  -- DOES NOT WORK

  -- test dump size
  Log.info("Serialized mob is %.2f KB" % (#Dump(mobs[1]()) / 1024))
  Log.info("Serialized world is %.2f KB" % (#Dump(State.world) / 1024))
  Log.info("Serialized state is %.2f KB" % (#Dump(State) / 1024))
  Log.info("Compressed serialized state is %.2f KB" % (#love.data.compress("string", "gzip", Dump(State)) / 1024))
end

return experiments
