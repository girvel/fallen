local module_mt = {}
local module = setmetatable({}, module_mt)

module.atlas = function(path)
  local base_image = love.graphics.newImage(path)
  local canvas = love.graphics.newCanvas(base_image:getDimensions())
  love.graphics.setCanvas(canvas)
  love.graphics.draw(base_image)
  love.graphics.setCanvas()
  return canvas
end

module_mt.__call = function(self, canvas, index)
  local size = State.CELL_DISPLAY_SIZE
  local w = canvas:getWidth()
  index = (index - 1) * size
  local image_data = canvas:newImageData(nil, nil, index % w, math.floor(index / w) * size, size, size)

  return {
    sprite = {
      image = love.graphics.newImage(image_data),
      image_data = image_data,
      color = Common.get_color(image_data),
    }
  }
end

return module
