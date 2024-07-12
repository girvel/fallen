local ffi = require("ffi")


return function(path, rotations_n)
  local image_data = love.image.newImageData(path)

  if rotations_n then
    local w, h = image_data:getDimensions()
    local new_image_data = love.image.newImageData(w, h)
    local pointer = ffi.cast("uint8_t*", new_image_data:getFFIPointer())
    local old_pointer = ffi.cast("uint8_t*", image_data:getFFIPointer())
    for i = 1, 4*w*h, 4 do
      local j = math.floor(i / w) - (i % w) * w
      pointer[i] = old_pointer[j]
      pointer[i + 1] = old_pointer[j + 1]
      pointer[i + 2] = old_pointer[j + 2]
      pointer[i + 3] = old_pointer[j + 3]
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

