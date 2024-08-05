local ffi = require("ffi")
local serpent = require("lib.serpent")


local experiments = {}

experiments.tcod = function()
  local libtcod = ffi.load("lib/libtcod")
end

experiments.serialization = function()
  -- test function serialization
  local f = function(x)
    Log.trace(x)
  end
  loadstring(serpent.dump(f))()("Serialization works!")

  -- test LOVE2D data serialization
  local image = love.graphics.newImage("assets/sprites/bushes.png")
  -- Log.trace(loadstring(serpent.dump(image))():getDimensions())
  -- DOES NOT WORK

  -- test dump size
  local state_dump = serpent.dump(State)
  Log.trace("Serialized state is %.2f KB" % (#state_dump / 1024))
end

return experiments
