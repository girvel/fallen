local module = {}

module.GRID_LAYERS = {"tiles", "solids", "sfx", "gui"}

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

module.load_entities = function(text_representation, arguments, palette)
  local level_lines = text_representation:strip():split("\n")
  local level_size = Vector({#level_lines[1], #level_lines})

  local grid_of_args = Grid(level_size)
  for k, v in pairs(arguments) do
    grid_of_args[Vector(k)] = v
  end

  local result = {}

  for _, layer in ipairs(module.GRID_LAYERS) do
    for y, line in ipairs(level_lines) do
      for _, x, character in Fun.iter(line):enumerate() do
        local factory = (palette.factories[layer] or {})[character]
        if factory then
          local position = Vector({x, y})
          table.insert(result, Tablex.extend(
            factory(unpack(grid_of_args[position] or {})),
            {position = position, layer = layer}
          ))
        end
      end
    end
  end

  for y, line in ipairs(level_lines) do
    for _, x, character in Fun.iter(line):enumerate() do
      if palette.transparents[character] then
        local position = Vector({x, y})
        local tiles_around = Fun.iter(Vector.directions)
          :map(function(d)
            local p = position + d;
            return (level_lines[p[2]] or {})[p[1]]
          end)
          :filter(function(c) return palette.factories.tiles[c] end)
          :totable()

        if #tiles_around >= 1 then
          local tiles_around_ns = Fun.iter(tiles_around)
            :reduce(function(acc, c)
              acc[c] = (acc[c] or 0) + 1
              return acc
            end, {})

          local most_frequent_tile = Fun.iter(tiles_around_ns)
            :max_by(function(c, n) return n end)

          table.insert(result, Tablex.extend(
            palette.factories.tiles[most_frequent_tile](),
            {position = position, layer = "tiles"}
          ))
        end
      end
    end
  end

  return level_size, result
end

return module
