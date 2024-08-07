local mobs = require("library.mobs")


local experiments = {}

experiments.serialization_old = function()
  -- test function serialization
  local f = function(x)
    Log.info(x)
  end
  loadstring(Dump(f))()("Serialization works!")

  -- test dump size
  local test = function(name, x)
    local dump = Dump(mobs[1]())
    Log.info("Serialized %s is %.2f KB" % {name, #dump / 1024})
    Log.info("Deserialized: %s" % {pcall(loadstring(dump))})
  end

  test("mob", mobs[1]())
  test("world", State.world)
  test("state", State)

  require("last_save")
  Log.info(loadstring(love.filesystem.read("last_save.lua"))())

  Log.info("Compressed serialized state is %.2f KB" % (#love.data.compress("string", "gzip", Dump(State)) / 1024))
end

return experiments
