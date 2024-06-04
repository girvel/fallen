local animation_methods = {
  animate = function(self, animation_name)
    self.animation.current = animation_name .. "_" .. (self.direction or "")
    if not self.animation.pack[self.animation.current] then
      self.animation.current = animation_name
    end
    self.animation.frame = 1
  end,

  when_animation_ends = function(self, callback)
    self._on_animation_end = callback
  end,
}

local animation_mt = {__index = animation_methods}

return function(pack)
  local result = setmetatable({
    animation = {
      pack = pack,
    },
    sprite = {},
    _on_animation_end = nil,
  }, animation_mt)

  result:animate("idle")
  return result
end
