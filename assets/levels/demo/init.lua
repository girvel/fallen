local constants = require("tech.constants")


local base_path = "assets.levels.demo"
local ldtk, module_mt, static = Module(base_path)
base_path = base_path:gsub("%.", "/")

local get_identifier = function(node)
  return node.__identifier:lower()
end

local layer_handlers = {
  tiles = function(layer, palette)
    local layer_palette = palette[get_identifier(layer)]
    return Fun.iter(layer.gridTiles)
      :map(function(instance)
        return Table.extend(layer_palette[instance.t + 1](), {
          position = Vector(instance.px) / constants.CELL_DISPLAY_SIZE,
        })
      end)
      :totable()
  end,

  entities = function(layer, palette)
    local identifier = get_identifier(layer)
    if identifier == "positions" then return {} end

    local layer_palette = palette[identifier]
    return Fun.iter(layer.entityInstances)
      :map(function(instance)
        return Table.extend(layer_palette[get_identifier(instance)](), {
          position = Vector(instance.__grid),
        })
      end)
      :totable()
  end,
}

local load_palette = function(path)
  return Fun.iter(love.filesystem.getDirectoryItems(path))
    :map(function(item)
      item = item:sub(1, #item - 4)
      return item, require(path .. "/" .. item)
    end)
    :tomap()
end

ldtk.load = function()
  local raw = Json.decode(love.filesystem.read(base_path .. "/level.ldtk")).levels[1]
  local palette = load_palette("library/palette")

  local positions_layer = Fun.iter(raw.layerInstances)
    :filter(function(layer) return get_identifier(layer) == "positions" end)
    :nth(1)

  return {
    size = Vector({raw.pxWid, raw.pxHei}) / constants.CELL_DISPLAY_SIZE,
    entities = Fun.iter(raw.layerInstances)
      :map(function(layer) return layer_handlers[layer.__type:lower()](layer, palette) end)
      :reduce(Table.concat, {}),
    background_image = Common.resolve_path(base_path .. "/" .. raw.bgRelPath),
    rails = require(base_path .. "/rails")(Fun.iter(positions_layer.entityInstances)
      :map(function(instance)
        return instance.fieldInstances[1].__value:lower(), Vector(instance.__grid)
      end)
      :tomap()
    ),
  }
end

return ldtk
