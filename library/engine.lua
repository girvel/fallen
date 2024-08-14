local constants = require("tech.constants")
local sprite = require("tech.sprite")


local engine, module_mt, static = Module("library.engine")

engine.char = "e"

local anchor = nil
local atlas = "assets/sprites/engine2.png"
local W = love.image.newImageData(atlas):getWidth() / constants.CELL_DISPLAY_SIZE

engine.complex_factory = function(grid, position)
  anchor = anchor or position
  local relative_position = position - anchor + Vector.one

  local mixin
  if Tablex.contains({1, 2, 5, 6, 7, 8}, relative_position[2])
    or Tablex.contains({3, 4}, relative_position[2]) and Tablex.contains({4, 5}, relative_position[1])
  then
    mixin = {
      layer = "solids",
    }
  else
    mixin = {
      layer = "above_solids",
    }
  end

  if not (
    relative_position[2] == 1
    or Tablex.contains({5, 6, 7}, relative_position[2])
      and Tablex.contains({3, 4, 5}, relative_position[1])
  ) then
    Tablex.extend(mixin, {
      transparent_flag = true,
    })
  end

  return function()
    return Tablex.extend({
      view = "scene",
      sprite = sprite.from_atlas(atlas, (relative_position[2] - 1) * W + relative_position[1]),
      codename = "engine part " .. tostring(relative_position),
    }, mixin)
  end
end

return engine
