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

module.change_layer = function(grids, entity, new_layer)
  if grids[new_layer][entity.position] then return false end
  grids[entity.layer][entity.position] = nil
  grids[new_layer][entity.position] = entity
  entity.layer = new_layer
  return true
end

return module
