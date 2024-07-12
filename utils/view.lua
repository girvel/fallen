return function(offset, scale, cell_size)
  return {
    offset = offset,
    scale = scale,
    cell_size = cell_size,
    apply = function(self, v)
      return self.offset + v * self.scale * self.cell_size
    end,
    apply_inverse = function(self, v)
      return (v - self.offset) / self.scale / self.cell_size
    end,
    apply_scale = function(self, v)
      return v * self.scale * self.cell_size
    end,
  }
end
