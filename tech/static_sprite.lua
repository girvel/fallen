return function(path)
  return {
    sprite = {
      image = love.graphics.newImage(path),
      color = Common.get_color(love.image.newImageData(path)),
    }
  }
end

