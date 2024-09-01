local game_save = Module("state.game_save")

local path = "last_save.fallen_save"
game_save.write = function()
  Log.info("Saving the game to %s" % path)
  love.filesystem.write(path, love.data.compress("string", "gzip", Dump(State)))
  Fun.iter(Dump.get_warnings()):each(Log.warn)
  Log.info("Game saved")
end

game_save.read = function()
  Log.info("Loading the game from %s" % path)
  State = assert(loadstring(love.data.decompress(
    "string", "gzip", love.filesystem.read(path)
  ), "last_save")())
  Log.info("Game loaded")
end

return game_save
