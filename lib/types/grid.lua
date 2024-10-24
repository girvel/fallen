--- indexing starts from 1


local grid, module_mt, static = Module("lib.types.grid")

grid._grid_mt = static {}

module_mt.__call = function(_, size, factory)
  assert(size)
  return setmetatable({
    size = size,
    _inner_array = factory
      and Fun.range(1, size[1] * size[2]):map(factory):totable()
      or {},
  }, grid._grid_mt)
end

grid.from_matrix = function(matrix, size)
  local result = grid(size)
  for x = 1, size[1] do
    for y = 1, size[2] do
      result._inner_array[result:_get_inner_index(x, y)] = matrix[y][x]
    end
  end
  return result
end

grid._grid_methods = {
  can_fit = function(self, v)
    return Vector.zero < v and self.size >= v
  end,

  safe_get = function(self, v, default)
    if not self:can_fit(v) then return default end
    return self[v]
  end,

  fast_get = function(self, x, y)
    return self._inner_array[self:_get_inner_index(x, y)]
  end,

  iter = function(self)
    return Fun.iter(pairs(self._inner_array))
  end,

  find_path = function(self, start, finish, max_distance)
    if start == finish then return {} end

    local distance_to = grid(self.size)
    local way_back = grid(self.size)
    local visited_vertices = grid(self.size)
    local visited_vertices_list = {}
    local vertices_to_visit = {start}  -- TODO OPT use sorted list
    distance_to[start] = 0

    local reconstruct_from = function(last)
      local result = {}
      local current = last
      for i = distance_to[last], 1, -1 do
        result[i] = current
        current = way_back[current]
      end
      return result
    end

    local current_vertex_i = 1
    local current_vertex = start
    local current_distance = 0
    while true do
      for _, direction in ipairs(Vector.directions) do
        local neighbour = current_vertex + direction

        if neighbour == finish then
          distance_to[finish] = current_distance + 1
          way_back[finish] = current_vertex
          return reconstruct_from(finish)
        end

        if
          not self:safe_get(neighbour, true)
          and not visited_vertices:safe_get(neighbour)
          and self:can_fit(neighbour)
          and (distance_to[neighbour] or math.huge) > current_distance
        then
          distance_to[neighbour] = current_distance + 1
          way_back[neighbour] = current_vertex
          table.insert(vertices_to_visit, neighbour)
        end
      end

      Table.remove_breaking_at(vertices_to_visit, current_vertex_i)
      visited_vertices[current_vertex] = true
      table.insert(visited_vertices_list, current_vertex)

      current_distance = math.huge
      for i, vertex in ipairs(vertices_to_visit) do
        local new_distance = distance_to[vertex]
        if new_distance < current_distance then
          current_vertex = vertex
          current_vertex_i = i
          current_distance = new_distance
        end
      end

      if #vertices_to_visit == 0 or current_distance > (max_distance or math.huge) then
        local next_best_finish = Fun.iter(visited_vertices_list)
          :min_by(function(a, b)
            return (a - finish):abs() < (b - finish):abs() and a or b
          end)
        return reconstruct_from(next_best_finish)
      end
    end
  end,

  _get_inner_index = function(self, x, y)
    return x + (y - 1) * self.size[1]
  end,
}

grid._grid_mt.__index = function(self, v)
  local method = grid._grid_methods[v]
  if method then return method end

  assert(
    getmetatable(v) == Vector.mt,
    "Attempt to index grid with %s which is neither vector nor a method name" % {v}
  )
  assert(self:can_fit(v))
  return self._inner_array[self:_get_inner_index(unpack(v))]
end

grid._grid_mt.__newindex = function(self, v, value)
  assert(self:can_fit(v), tostring(v) .. " does not fit into grid size " .. tostring(self.size))
  self._inner_array[self:_get_inner_index(unpack(v))] = value
end

return grid
