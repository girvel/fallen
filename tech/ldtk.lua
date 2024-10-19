local constants = require("tech.constants")


local ldtk, module_mt, static = Module("tech.ldtk")

local get_identifier, get_field, layer_handlers, load_palette

ldtk.load = function(world_filepath, level_id, params)
  params = params or {}

  local raw = Fun.iter(Json.decode(love.filesystem.read(world_filepath)).levels)
    :filter(function(l) return l.identifier == level_id end)
    :nth(1)

  local palette = load_palette("library/palette")
  local size = Vector({raw.pxWid, raw.pxHei}) / constants.CELL_DISPLAY_SIZE

  local positions_layer = Fun.iter(raw.layerInstances)
    :filter(function(layer) return get_identifier(layer) == "positions" end)
    :nth(1)

  local to_capture = Fun.iter(raw.layerInstances)
    :map(function(l) return get_identifier(l), Grid(size) end)
    :tomap()

  local positions = {}
  for _, instance in ipairs(positions_layer.entityInstances) do
    if get_identifier(instance) == "entity_capture" then
      to_capture
        [get_field(instance, "layer").__value:lower()]
        [Vector(instance.__grid) + Vector.one]
        = get_field(instance, "rails_name").__value:lower()
    else
      positions[instance.fieldInstances[1].__value:lower()] = Vector(instance.__grid) + Vector.one
    end
  end

  local captured_entities = {}

  local entities = Fun.iter(raw.layerInstances)
    :map(function(layer)
      return layer_handlers[layer.__type:lower()](layer, palette, captured_entities, to_capture)
    end)
    :reduce(Table.concat, {})

  return {
    size = size,
    entities = entities,
    rails = params.rails
      and require(params.rails)(positions, captured_entities)
      or nil,
  }
end

get_identifier = function(node)
  return node.__identifier:lower()
end

get_field = function(instance, field_name)
  return Fun.iter(instance.fieldInstances)
    :filter(function(f) return get_identifier(f) == field_name end)
    :nth(1)
end

layer_handlers = {
  tiles = function(layer, palette, captured_entities, to_capture)
    local layer_id = get_identifier(layer)
    local layer_palette = palette[layer_id]
    return Fun.iter(layer.gridTiles)
      :map(function(instance)
        local result = Table.extend(layer_palette[instance.t + 1](), {
          position = Vector(instance.px) / constants.CELL_DISPLAY_SIZE + Vector.one,
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
        local get_args = assert(loadstring(
          "return " .. (-Query(get_field(instance, "args")).__value or "")
        ))

        local factory = assert(
          layer_palette[get_identifier(instance)],
          "Entity factory %s is not defined for layer %s" % {get_identifier(instance), layer_id}
        )

        local result = Table.extend(factory(get_args()), {
          position = Vector(instance.__grid) + Vector.one,
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

load_palette = function(path)
  return Fun.iter(love.filesystem.getDirectoryItems(path))
    :map(function(item)
      item = item:sub(1, #item - 4)
      return item, require(path .. "/" .. item)
    end)
    :tomap()
end

return ldtk
