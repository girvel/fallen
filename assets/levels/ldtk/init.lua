local player = require("state.player")
local constants = require("tech.constants")


local ldtk, module_mt, static = Module("assets.levels.ldtk")

local get_identifier = function(node)
  return node.__identifier:lower()
end

ldtk.load = function()
  local raw = Json.decode(love.filesystem.read("assets/levels/ldtk/level.ldtk")).levels[1]
  local palette = {
    mobs = {
      player = player,
    },
  }

  return {
    size = Vector({raw.pxWid, raw.pxHei}) / constants.CELL_DISPLAY_SIZE,
    entities = Fun.iter(raw.layerInstances)
      :map(function(layer)
        local layer_palette = palette[get_identifier(layer)]
        return Fun.iter(layer.entityInstances)
          :map(function(instance)
            return Table.extend(layer_palette[get_identifier(instance)](), {
              position = Vector(Log.trace(instance.__grid)),
            })
          end)
          :totable()
      end)
      :reduce(Table.concat, {}),
    rails = nil,
  }
end

return ldtk
