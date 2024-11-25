--- Factory module for serializing sounds plus some convenience methods
--- @overload fun(path: string, volume?: number): sound
local sound, module_mt, static = Module("tech.sound")

module_mt.__call = function(_, path, volume)
  local source = love.audio.newSource(path, "static")
  if volume then source:setVolume(volume) end
  if source:getChannelCount() == 1 then
    source:setRelative(true)
  end
  return setmetatable({
    source = source,
    _path = path,
  }, sound._mt)
end

--- @class sound
--- @field source love.Source
--- @field _path string
local sound_methods = {
  --- Creates a fully independent copy of the sound
  --- @param self sound
  --- @return sound
  clone = function(self)
    return setmetatable({
      source = self.source:clone(),
      _path = self._path,
    }, sound._mt)
  end,

  --- @generic T: sound
  --- @param self T
  --- @param position vector
  --- @param size? sound_size
  --- @return T
  place = function(self, position, size)
    --- @cast self sound
    local limits = assert(
      sound.sizes[size or "small"],
      "Incorrect sound size %s; sounds can be small, medium or large" % tostring(size)
    )

    self.source:setRelative(false)
    self.source:setPosition(unpack(position))
    self.source:setAttenuationDistances(unpack(limits))
    self.source:setRolloff(2)
    return self
  end,

  --- @generic T: sound
  --- @param self T
  --- @return T
  play = function(self)
    --- @cast self sound
    self.source:play()
    return self
  end,

  --- @generic T: sound
  --- @param self T
  --- @return T
  stop = function(self)
    --- @cast self sound
    self.source:stop()
    return self
  end,

  --- @generic T: sound
  --- @param self T
  --- @param value boolean
  --- @return T
  set_looping = function(self, value)
    --- @cast self sound
    self.source:setLooping(value)
    return self
  end,
}

sound._mt = static {
  __index = sound_methods,
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
        result.source:setPosition(x, y, 0)
        result.source:setRolloff(rolloff)
        result.source:setAttenuationDistances(ref, max)
      end
      return result
    end
  end,
}

--- Load all sounds with full path starting with given prefix
--- @param path_beginning string
--- @param volume? number
--- @return sound[]
sound.multiple = function(path_beginning, volume)
  local _, _, directory = path_beginning:find("^(.*)/[^/]*$")
  return Fun.iter(love.filesystem.getDirectoryItems(directory))
    :map(function(filename) return directory .. "/" .. filename end)
    :filter(function(path) return path:starts_with(path_beginning) end)
    :map(function(path) return sound(path, volume or 1) end)
    :totable()
end

--- @type fun(path: string, volume?: number): sound
sound.cached = Memoize(function(...) return module_mt.__call(nil, ...) end)
sound.multiple_cached = Memoize(sound.multiple)

--- @enum (key) sound_size
sound.sizes = {
  small = {1, 10},
  medium = {7, 20},
  large = {15, 30},
}

--- @deprecated
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

    this_sound.source:setRelative(false)
    this_sound.source:setPosition(unpack(position))
    this_sound.source:setAttenuationDistances(unpack(limits))
    this_sound.source:setRolloff(2)
  elseif this_sound.source:getChannelCount() == 1 then
    this_sound.source:setRelative(true)
  end

  this_sound.source:play()
end

return sound
