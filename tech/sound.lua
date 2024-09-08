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
    local looping = self.source:isLooping()
    local relative, x, y, rolloff, ref, max
    if self.source:getChannelCount() == 1 then
      relative = self.source:isRelative()
      x, y = self.source:getPosition()
      rolloff = self.source:getRolloff()
      ref, max = self.source:getAttenuationDistances()
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

sound.multiple = Memoize(function(path_beginning, volume)
  local _, _, directory = path_beginning:find("^(.*)/[^/]*$")
  return Fun.iter(love.filesystem.getDirectoryItems(directory))
    :map(function(filename) return directory .. "/" .. filename end)
    :filter(function(path) return path:starts_with(path_beginning) end)
    :map(function(path) return sound(path, volume or 1) end)
    :totable()
end)


module_mt.__call = Memoize(function(_, path, volume)
  local source = love.audio.newSource(path, "static")
  if volume then source:setVolume(volume) end
  return setmetatable({
    source = source,
    _path = path,
  }, sound.mt)
end)

sound.sizes = static .. {
  small = {
    1, 10,
  },
  medium = {
    7, 20,
  },
  large = {
    15, 30,
  },
}

sound.play = function(head, ...)
  local sounds, volume, position, size
  if type(head) == "string" then
    volume, position, size = ...
    sounds = sound.multiple(head, volume)
  else
    position, size = ...
    sounds = head
  end
  assert(#sounds > 0, "Empty sound collection")
  local this_sound = Random.choice(sounds):clone()

  if position then
    local limits = assert(
      sound.sizes[size or "small"],
      "Incorrect sound size %s; sounds can be small, medium or large" % tostring(size)
    )

    this_sound.source:setPosition(unpack(position))
    this_sound.source:setAttenuationDistances(unpack(limits))
    this_sound.source:setRolloff(2)
  elseif this_sound.source:getChannelCount() == 1 then
    this_sound.source:setRelative(true)
  end

  this_sound.source:play()
end

return sound
