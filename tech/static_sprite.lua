return function(path, rotations_n)
  rotations_n = rotations_n or 0
  local image_data = love.image.newImageData(path)

  for _ = 1, rotations_n do
    local w, h = image_data:getDimensions()
    local new_image_data = love.image.newImageData(h, w)
    for x = 0, w - 1 do
      for y = 0, h - 1 do
        new_image_data:setPixel(y, w - x - 1, image_data:getPixel(x, y))
      end
    end

    image_data = new_image_data
  end

  return {
    sprite = {
      image = love.graphics.newImage(image_data),
      color = Common.get_color(image_data),
    }
  }
end

