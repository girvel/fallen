local player = require("state.player")
local constants = require("tech.constants")


local ldtk, module_mt, static = Module("assets.levels.ldtk")

local get_identifier = function(node)
  return node.__identifier:lower()
end

local layer_handlers = {
  tiles = function(layer, palette)
    local layer_palette = palette[get_identifier(layer)]
    return Fun.iter(layer.gridTiles)
      :map(function(instance)
        Log.trace(layer_palette, instance)
        return Table.extend(layer_palette[instance.t + 1](), {
          position = Vector(instance.px) / constants.CELL_DISPLAY_SIZE,
        })
      end)
      :totable()
  end,

  entities = function(layer, palette)
    local layer_palette = palette[get_identifier(layer)]
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
  local raw = Json.decode(love.filesystem.read("assets/levels/ldtk/level.ldtk")).levels[1]
  local palette = load_palette("library/palette")

  return {
    size = Vector({raw.pxWid, raw.pxHei}) / constants.CELL_DISPLAY_SIZE,
    entities = Fun.iter(raw.layerInstances)
      :map(function(layer) return layer_handlers[layer.__type:lower()](layer, palette) end)
      :reduce(Table.concat, {}),
    rails = nil,
  }
end

return ldtk
