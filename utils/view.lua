return Module("utils.view", function(offset, scale, cell_size)
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
    get_multiplier = function(self)
      return self.scale * self.cell_size
    end,
  }
end)
