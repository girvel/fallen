return function(path)
  local image_data = love.image.newImageData(path)

  return {
    sprite = {
      image = love.graphics.newImage(image_data),
      image_data = image_data,
      color = Common.get_color(image_data),
    }
  }
end

