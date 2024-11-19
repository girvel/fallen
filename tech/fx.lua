local animated = require("tech.animated")


--- Create an entity from animation that exists as long as the animation is playing
--- @param pack string | table
--- @param layer layer
--- @param position vector
--- @return entity
return function(pack, layer, position)
  local result = Table.extend(
    animated(pack),
    {
      boring_flag = true,
      codename = "fx",
      layer = layer,
      position = position,
      view = "scene",
    }
  )

  result:animate():next(function()
    State:remove(result)
  end)

  return result
end
