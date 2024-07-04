return function(offset, scale, tile_size)
  return {
    offset = offset,
    scale = scale,
    tile_size = tile_size,
    apply = function(self, v)
      return self.offset + v * self.scale * self.tile_size
    end,
    apply_inverse = function(self, v)
      return (v - self.offset) / self.scale / self.tile_size
    end,
  }
end
