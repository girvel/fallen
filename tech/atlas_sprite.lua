return function(canvas, index)
  local size = State.CELL_DISPLAY_SIZE
  local w = canvas:getWidth()
  index = (index - 1) * size
  local image_data = canvas:newImageData(nil, nil, index % w, math.floor(index / w) * size, size, size)

  return {
    sprite = {
      image = love.graphics.newImage(image_data),
      color = Common.get_color(image_data),
    }
  }
end
