return Module("tech.view", function(offset, scale, cell_size)
  return {
    offset = offset,
    scale = scale,
    cell_size = cell_size,
    apply = function(self, v)
      return self.offset + v * self.scale * self.cell_size
    end,
    apply_scalar = function(self, x, y)
      return
        self.offset[1] + x * self.scale * self.cell_size,
        self.offset[2] + y * self.scale * self.cell_size
    end,
    inverse = function(self, v)
      return (v - self.offset) / self.scale / self.cell_size
    end,
    get_multiplier = function(self)
      return self.scale * self.cell_size
    end,
  }
end)
