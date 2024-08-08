local animated = require("tech.animated")


return function(pack, layer, position)
  Log.trace("FX", pack)
  local result = Tablex.extend(
    animated(pack),
    {
      boring_flag = true,
      codename = "fx",
      layer = layer,
      position = position,
      view = "scene",
    }
  )

  result:when_animation_ends(function()
    State:remove(result)
  end)
  return result
end
