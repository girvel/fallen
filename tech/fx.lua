local animated = require("tech.animated")


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
