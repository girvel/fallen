local module, _, static = Module("tech.level")

module.GRID_LAYERS = {"tiles", "items", "fx_behind", "solids", "above_solids", "fx"}

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

local throw_tiles_under = function(level_lines, palette, result)
  for y, line in ipairs(level_lines) do
    for _, x, character in Fun.iter(line):enumerate() do
      if palette.transparents[character] then
        local position = Vector({x, y})
        local tiles_around = Fun.iter(Vector.extended_directions)
          :map(function(d)
            local p = position + d;
            return (level_lines[p[2]] or {})[p[1]]
          end)
          :filter(function(c) return palette.throwables[c] end)
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
            palette.factories[most_frequent_tile](),
            {position = position, layer = "tiles", view = "scene"}
          ))
        end
      end
    end
  end
end

local get_factory = function(grid, position, palette)
  local character = grid[position]
  local complex_factory = palette.complex_factories[character]
  if complex_factory then
    local f = complex_factory(grid, position)
    if f then return f end
  end
  return palette.factories[character]
end

module.load_entities = function(text_representation, arguments, palette)
  local level_lines = text_representation:strip():split("\n")
  local level_size = Vector({#level_lines[1], #level_lines})

  local grid_of_args = Grid(level_size)
  for k, v in pairs(arguments) do
    k = Vector(k)
    assert(
      grid_of_args:can_fit(k),
      "Grid arguments %s, %s do not fit level size %s" % {
        k, Inspect(v), level_size
      }
    )
    grid_of_args[k] = v
  end

  local character_grid = Grid(level_size)
  for y, line in ipairs(level_lines) do
    for _, x, character in Fun.iter(line):enumerate() do
      character_grid[Vector({x, y})] = character
    end
  end

  local result = {}
  local player_anchor = {}

  for y, line in ipairs(level_lines) do
    for _, x, character in Fun.iter(line):enumerate() do
      local position = Vector({x, y})
      local factory = get_factory(character_grid, position, palette)
      if factory then
        table.insert(result, Tablex.extend(
          factory(unpack(grid_of_args[position] or {})),
          {position = position}
        ))
      end
      if character == "@" then
        player_anchor = position
      end
    end
  end

  throw_tiles_under(level_lines, palette, result)

  return level_size, result, player_anchor
end

return module
