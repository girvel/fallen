local sound, module_mt, static = Module("tech.sound")

sound.methods = static {
  clone = function(self)
    return sound(self._path, self.source:getVolume())
  end,
}

sound.mt = static {
  __index = sound.methods,
  __serialize = function(self)
    local path = self._path
    local volume = self.source:getVolume()
    local relative, x, y, rolloff, ref, max, looping
    if self.source:getChannelCount() == 1 then
      relative = self.source:isRelative()
      x, y = self.source:getPosition()
      rolloff = self.source:getRolloff()
      ref, max = self.source:getAttenuationDistances()
      looping = self.source:isLooping()
    end

    return function()
      local result = sound(path, volume)
      result.source:setLooping(looping or false)
      if result.source:getChannelCount() == 1 then
        result.source:setRelative(relative)
        result.source:setPosition(x, y)
        result.source:setRolloff(rolloff)
        result.source:setAttenuationDistances(ref, max)
      end
      return result
    end
  end,
}

sound.multiple = function(path_beginning, volume)
  local _, _, directory = path_beginning:find("^(.*)/[^/]*$")
  return Fun.iter(love.filesystem.getDirectoryItems(directory))
    :map(function(filename) return directory .. "/" .. filename end)
    :filter(function(path) return path:startsWith(path_beginning) end)
    :map(function(path) return sound(path, volume or 1) end)
    :totable()
end


module_mt.__call = function(_, path, volume)
  local source = love.audio.newSource(path, "static")
  if volume then source:setVolume(volume) end
  return setmetatable({
    source = source,
    _path = path,
  }, sound.mt)
end

return sound
