local module = {}
local module_mt = {}
setmetatable(module, module_mt)

local grid_mt = {}

module_mt.__call = function(_, size)
  return setmetatable({
    size = size,
    _inner_array = {},
  }, grid_mt)
end

module.from_matrix = function(matrix, size)
  local result = module(size)
  for x = 1, size[1] do
    for y = 1, size[2] do
      result._inner_array[result:_get_inner_index(x, y)] = matrix[y][x]
    end
  end
  return result
end

local grid_methods = {
  can_fit = function(self, v)
    return Vector.zero < v and self.size >= v
  end,

  safe_get = function(self, v, default)
    if not self:can_fit(v) then return default end
    return self[v]
  end,

  iter_table = function(self)
    return Fun.iter(pairs(self._inner_array))
  end,

  find_path = function(self, start, finish)
    
  end,

  _get_inner_index = function(self, x, y)
    return x + (y - 1) * self.size[1]
  end,
}

grid_mt.__index = function(self, v)
  local method = grid_methods[v]
  if method then return method end

  assert(self:can_fit(v))
  return self._inner_array[self:_get_inner_index(unpack(v))]
end

grid_mt.__newindex = function(self, v, value)
  assert(self:can_fit(v), tostring(v) .. " does not fit into grid size " .. tostring(self.size))
  self._inner_array[self:_get_inner_index(unpack(v))] = value
end

return module
