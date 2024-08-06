-- TODO move to tech.sprite

local tech_constants = require("tech.constants")
local sprite = require("tech.sprite")


local module_mt = {}
local module = setmetatable({}, module_mt)

module._atlases_cache = {}

local atlas = function(path)
  local base_image = love.graphics.newImage(path)
  local canvas = love.graphics.newCanvas(base_image:getDimensions())
  love.graphics.setCanvas(canvas)
  love.graphics.draw(base_image)
  love.graphics.setCanvas()
  return canvas
end

module_mt.__call = function(self, path, index, anchor)
  if not module._atlases_cache[path] then
    module._atlases_cache[path] = atlas(path)
  end
  local canvas = module._atlases_cache[path]

  local size = tech_constants.CELL_DISPLAY_SIZE
  local w = canvas:getWidth()
  index = (index - 1) * size
  local image_data = canvas:newImageData(nil, nil, index % w, math.floor(index / w) * size, size, size)

  return {
    sprite = sprite.image(image_data, anchor)
  }
end

return module
