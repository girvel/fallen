return Static.module("utils.view", function(offset, scale, cell_size)
  return {
    offset = offset,
    scale = scale,
    cell_size = cell_size,
    apply = function(self, v)
      return self.offset + v * self.scale * self.cell_size
    end,
    inverse = function(self, v)
      return (v - self.offset) / self.scale / self.cell_size
    end,
    apply_multiplier = function(self, v)
      return v * self.scale * self.cell_size
    end,
    inverse_multipler = function(self, v)
      return v / self.scale / self.cell_size
    end,
  }
end)
