return function(canvas, index)
  local size = State.CELL_DISPLAY_SIZE
  local image_data = canvas:newImageData(nil, nil, (index - 1) * size, 0, size, size)

  return {
    sprite = {
      image = love.graphics.newImage(image_data),
      color = Common.get_color(image_data),
    }
  }
end
