local level, _, static = Module("state.level")

level.GRID_LAYERS = {"tiles", "items", "fx_behind", "solids", "above_solids", "fx"}
level.GRID_COMPLEX_LAYERS = {fx_behind = true, fx = true}

level.move = function(entity, position)
  local grid = State.grids[entity.layer]
  if not grid:can_fit(position) or grid[position] then return end
  if grid[position] then
    Log.warn("level.move: replacing %s with %s" % {Common.get_name(grid[position]), Common.get_name(entity)})
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
      entity.layer, entity.position, Common.get_name(entity), Common.get_name(grid[entity.position])
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

local get_factory = function(grid, position, character, palette)
  local complex_factory = palette.complex_factories[character]
  if complex_factory then
    local f = complex_factory(grid, position)
    if f then return f end
  end
  return palette.factories[character]
end

local throw_tiles_under = function(grid, palette, result)
  for y = 1, grid.size[2] do
    for x = 1, grid.size[1] do
      local character = grid:fast_get(x, y)
      if palette.transparents[character] then
        local position = Vector({x, y})
        local tiles_around = {}

        for r = 1, 5 do
          local new_tiles = Fun.chain(
            Fun.range(1 - r, r):map(function(i) return Vector({r, i}) end),
            Fun.range(1 - r, r):map(function(i) return Vector({-r, i}) end),
            Fun.range(1 - r, r):map(function(i) return Vector({i, r}) end),
            Fun.range(1 - r, r):map(function(i) return Vector({i, -r}) end)
          )
            :map(function(v) return grid:safe_get(position + v) end)
            :filter(function(c) return palette.throwables[c] end)
            :totable()
          Table.concat(tiles_around, new_tiles)
          if #tiles_around > 1 then break end
        end
        -- Fun.iter(Vector.extended_directions)
        --   :map(function(d) return grid:safe_get(position + d) end)
        --   :filter(function(c) return palette.throwables[c] end)
        --   :totable()

        if #tiles_around >= 1 then
          local tiles_around_ns = Fun.iter(tiles_around)
            :reduce(function(acc, c)
              acc[c] = (acc[c] or 0) + 1
              return acc
            end, {})

          local most_frequent_tile = Fun.iter(tiles_around_ns)
            :map(function(...) return {...} end)
            :max_by(function(a, b) return a[2] > b[2] and a or b end)[1]

          table.insert(result, Table.extend(
            get_factory(grid, position, most_frequent_tile, palette)(),
            {position = position, layer = "tiles", view = "scene"}
          ))
        end
      end
    end
  end
end

level.load_entities = function(text_representation, arguments, palette)
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
      local factory = get_factory(character_grid, position, character, palette)
      if factory then
        table.insert(result, Table.extend(
          factory(unpack(grid_of_args[position] or {})),
          {position = position}
        ))
      end
      if character == "@" then
        player_anchor = position
      end
    end
  end

  throw_tiles_under(character_grid, palette, result)

  return level_size, result, player_anchor
end

return level
