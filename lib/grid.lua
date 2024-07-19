unpack = unpack or table.unpack

local vector = require("lib.vector")
local tablex = require("lib.tablex")
local fun = require("lib.fun")


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
    return vector.zero < v and self.size >= v
  end,

  safe_get = function(self, v, default)
    if not self:can_fit(v) then return default end
    return self[v]
  end,

  iter_table = function(self)
    return fun.iter(pairs(self._inner_array))
  end,

  find_path = function(self, start, finish)
    if start == finish then return {} end

    local distance_to = module(self.size)
    local way_back = module(self.size)
    local visited_vertices = module(self.size)
    local vertices_to_visit = {start}  -- TODO OPT use sorted list
    distance_to[start] = 0

    local current_vertex_i = 1
    local current_vertex = start
    local current_distance = 0
    while true do  -- TODO for
      for _, direction in ipairs(vector.directions) do
        local neighbour = current_vertex + direction

        if neighbour == finish then
          local result = {}
          local current = finish
          way_back[current] = current_vertex
          for i = current_distance + 1, 1, -1 do
            result[i] = current
            current = way_back[current]
          end
          return result
        end

        if
          not self:safe_get(neighbour, true)
          and not visited_vertices:safe_get(neighbour)
          and self:can_fit(neighbour)
          and (distance_to[neighbour] or 999999) > current_distance
        then
          distance_to[neighbour] = current_distance + 1
          way_back[neighbour] = current_vertex
          table.insert(vertices_to_visit, neighbour)
        end
      end

      tablex.remove_breaking_at(vertices_to_visit, current_vertex_i)
      visited_vertices[current_vertex] = true

      if #vertices_to_visit == 0 then return end

      current_distance = 999999
      for i, vertex in ipairs(vertices_to_visit) do
        local new_distance = distance_to[vertex]
        if new_distance < current_distance then
          current_vertex = vertex
          current_vertex_i = i
          current_distance = new_distance
        end
      end
    end
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
