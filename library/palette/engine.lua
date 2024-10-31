local factoring = require("tech.factoring")
local shaders   = require("tech.shaders")


local engine, module_mt, static = Module("library.palette.engine")

factoring.from_atlas(engine, "assets/sprites/engine2.png", function(_, position)
  local mixin = {
    view = "scene",
    codename = "engine part " .. tostring(position),
  }
  if Table.contains({1, 4, 5, 6, 7}, position[2])
    or Table.contains({2, 3}, position[2]) and Table.contains({3, 4}, position[1])
  then
    mixin.layer = "solids"
  else
    mixin.layer = "on_solids"
  end

  if position[2] == 0 then
    mixin.perspective_flag = true
  else
    mixin.transparent_flag = true
  end

  if Table.contains({
    Vector {3, 7},
    Vector {4, 7},
    Vector {5, 7},
  }, position) then
    mixin.shader = shaders.reflective
    mixin.reflection_vector = Vector.down
  end

  return mixin
end, Fun.range(80):totable())

return engine
