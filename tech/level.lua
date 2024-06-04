local module = {}

module.put = function(grid, entity)
  if not grid:can_fit(entity.position) or grid[entity.position] then return false end
  grid[entity.position] = entity
  return true
end

module.move = function(grid, entity, position)
  if not grid:can_fit(position) or grid[position] then return false end
  grid[entity.position] = nil
  grid[position] = entity
  entity.position = position
  return true
end

return module
