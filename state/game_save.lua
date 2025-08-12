local game_save = Module("state.game_save")

game_save.write = function(filepath)
  Log.info("Saving the game to %s" % filepath)
  love.filesystem.write(filepath, love.data.compress("string", "gzip", Dump(State)))
  Fun.iter(Dump.get_warnings()):each(Log.warn)
  Log.info("Game saved")
end

game_save.read = function(filepath)
  Log.info("Loading the game from %s" % filepath)
  State = assert(loadstring(love.data.decompress(
    "string", "gzip", love.filesystem.read(filepath)
  ) --[[@as string]], filepath)())
  Log.info("Game loaded")
end

return game_save
