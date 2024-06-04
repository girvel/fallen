local animation_methods = {
  animate = function(self, animation_name)
    if animation_name ~= "idle" then Log.trace(self, animation_name) end
    self.animation.current = animation_name .. "_" .. (self.direction or "")
    if not self.animation.pack[self.animation.current] then
      self.animation.current = animation_name
    end
    self.animation.frame = 1
  end,

  when_ends = function(self, callback)
    self._on_end = callback
  end,
}

local animation_mt = {__index = animation_methods}

return function(pack)
  local result = setmetatable({
    animation = {
      pack = pack,
    },
    sprite = {},
    _on_end = nil,
  }, animation_mt)

  result:animate("idle")
  return result
end
