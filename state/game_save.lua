local game_save = Module("state.game_save")

game_save.write = function()
  love.filesystem.write("last_save.fallen_save", love.data.compress("string", "gzip", Dump(State)))
  Fun.iter(Dump.get_warnings()):each(Log.warn)
end

game_save.read = function()
  State = assert(loadstring(love.data.decompress(
    "string", "gzip", love.filesystem.read("last_save.fallen_save")
  ))())
end

return game_save
