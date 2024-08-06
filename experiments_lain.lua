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
  local world_dump = Dump(State.world)
  Log.info("Serialized state is %.2f KB" % (#world_dump / 1024))
end

return experiments
