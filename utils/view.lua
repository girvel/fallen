return function(offset, scale)
  return {
    offset = offset,
    scale = scale,
    apply = function(self, v)
      return self.offset + v * self.scale
    end,
    apply_inverse = function(self, v)
      return (v - self.offset) / self.scale
    end,
  }
end
