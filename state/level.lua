local level, _, static = Module("state.level")

level.GRID_LAYERS = {
  "under_tiles", "tiles",
  "items", "fx_under", "solids", "on_solids", "on_solids2", "fx"
}
level.GRID_COMPLEX_LAYERS = {fx_under = true, fx = true}

level.move = function(entity, position)
  local grid = State.grids[entity.layer]
  if not grid:can_fit(position) or grid[position] then return end
  if grid[position] then
    Log.warn("level.move: replacing %s with %s" % {Entity.name(grid[position]), Entity.name(entity)})
  end
  grid[entity.position] = nil
  grid[position] = entity
  entity.position = position
  return true
end

level.change_layer = function(entity, new_layer)
  local grids = State.grids
  if grids[new_layer][entity.position] then return false end
  grids[entity.layer][entity.position] = nil
  grids[new_layer][entity.position] = entity
  entity.layer = new_layer
  return true
end

level.put = function(entity)
  local grid = State.grids[entity.layer]

  if level.GRID_COMPLEX_LAYERS[entity.layer] then
    table.insert(grid[entity.position], entity)
    return
  end

  if grid[entity.position] then
    Log.warn("Grid collision at %s[%s]: %s replaces %s" % {
      entity.layer, entity.position, Entity.name(entity), Entity.name(grid[entity.position])
    })
  end
  grid[entity.position] = entity
end

level.remove = function(entity)
  local grid = State.grids[entity.layer]
  if level.GRID_COMPLEX_LAYERS[entity.layer] then
    return Table.remove(grid[entity.position], entity)
  end
  grid[entity.position] = nil
end

return level
