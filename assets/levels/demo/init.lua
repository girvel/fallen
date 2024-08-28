local level = require("state.level")
local constants = require("tech.constants")


local base_path = "assets.levels.demo"
local ldtk, module_mt, static = Module(base_path)
base_path = base_path:gsub("%.", "/")

local get_identifier = function(node)
  return node.__identifier:lower()
end

local get_field = function(instance, field_name)
  return Fun.iter(instance.fieldInstances)
    :filter(function(f) return get_identifier(f) == field_name end)
    :nth(1)
end

local layer_handlers = {
  tiles = function(layer, palette, captured_entities, to_capture)
    local layer_id = get_identifier(layer)
    local layer_palette = palette[layer_id]
    return Fun.iter(layer.gridTiles)
      :map(function(instance)
        local result = Table.extend(layer_palette[instance.t + 1](), {
          position = Vector(instance.px) / constants.CELL_DISPLAY_SIZE,
        })
        local rails_name = -Query(to_capture)[layer_id][result.position]
        if rails_name then
          captured_entities[rails_name] = result
        end
        return result
      end)
      :totable()
  end,

  entities = function(layer, palette, captured_entities, to_capture)
    local layer_id = get_identifier(layer)
    if layer_id == "positions" then return {} end

    local layer_palette = palette[layer_id]
    return Fun.iter(layer.entityInstances)
      :map(function(instance)
        local result = Table.extend(layer_palette[get_identifier(instance)](), {
          position = Vector(instance.__grid),
        })

        local rails_name = -Query(get_field(instance, "rails_name")).__value:lower()
          or -Query(to_capture)[layer_id][result.position]
        if rails_name then
          captured_entities[rails_name] = result
        end

        return result
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
  local size = Vector({raw.pxWid, raw.pxHei}) / constants.CELL_DISPLAY_SIZE

  local positions_layer = Fun.iter(raw.layerInstances)
    :filter(function(layer) return get_identifier(layer) == "positions" end)
    :nth(1)

  local to_capture = Fun.iter(raw.layerInstances):map(function(l) return get_identifier(l), Grid(size) end):tomap()
  local positions = Fun.iter(positions_layer.entityInstances)
    :map(function(instance)
      if get_identifier(instance) == "entity_capture" then
        to_capture
          [get_field(instance, "layer").__value:lower()]
          [Vector(instance.__grid)]
          = get_field(instance, "rails_name").__value:lower()
        return
      end
      return instance.fieldInstances[1].__value:lower(), Vector(instance.__grid)
    end)
    :filter(Fun.op.truth)
    :tomap()

  local captured_entities = {}

  local entities = Fun.iter(raw.layerInstances)
    :map(function(layer) return layer_handlers[layer.__type:lower()](layer, palette, captured_entities, to_capture) end)
    :reduce(Table.concat, {})

  Log.trace(captured_entities)

  return {
    size = size,
    entities = entities,
    background_image = Common.resolve_path(base_path .. "/" .. raw.bgRelPath),
    rails = require(base_path .. "/rails")(positions, captured_entities),
  }
end

return ldtk
