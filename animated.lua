return function(pack)
  local result = {
    animation = {
      pack = pack,
    },
    sprite = {},
    animate = function(self, animation_name)
      self.animation.current = animation_name .. "_" .. (self.direction or "")
      if not self.animation.pack[self.animation.current] then
        self.animation.current = animation_name
      end
      self.animation.frame = 1
    end,
  }

  result:animate("idle")
  return result
end
