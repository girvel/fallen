local tech_constants = require("tech.constants")


local sprite, _, static = Module("tech.sprite")

sprite.image_mt = static {
  __serialize = function(self)
    local data = self.data:getString()
    local w, h = self.data:getDimensions()
    local anchor = self.anchor
    local paint_color = self._paint_color
    return function()
      return sprite.image(love.image.newImageData(w, h, "rgba8", data), anchor, paint_color)
    end
  end
}

sprite.text_mt = static {
  __serialize = function(self)
    local text = self.text
    local size = self._size
    return function()
      return sprite.text(text, size)
    end
  end
}

sprite.image = function(base, anchor, paint_color)
  if type(base) == "string" then
    base = love.image.newImageData(base)
  end

  if paint_color then
    base:mapPixel(function(_, _, r, g, b, a)
      if a == 0 then return 0, 0, 0, 0 end
      if r == 0 and g == 0 and b == 0 then return 0, 0, 0, 1 end
      return unpack(paint_color)
    end)
  end

  return setmetatable({
    image = love.graphics.newImage(base),
    data = base,
    color = Common.get_color(base),
    anchor = anchor,
    _paint_color = paint_color,
  }, sprite.image_mt)
end

local _atlases_cache = {}

local atlas = function(path)
  local base_image = love.graphics.newImage(path)
  local canvas = love.graphics.newCanvas(base_image:getDimensions())
  love.graphics.setCanvas(canvas)
  love.graphics.draw(base_image)
  love.graphics.setCanvas()
  return canvas
end

sprite.from_atlas = function(path, index, anchor)
  if not _atlases_cache[path] then
    _atlases_cache[path] = atlas(path)
  end
  local canvas = _atlases_cache[path]

  local size = tech_constants.CELL_DISPLAY_SIZE
  local w = canvas:getWidth()
  index = (index - 1) * size
  local image_data = canvas:newImageData(nil, nil, index % w, math.floor(index / w) * size, size, size)

  return sprite.image(image_data, anchor)
end

sprite.get_atlas_position = function(path, index)
  if not _atlases_cache[path] then
    _atlases_cache[path] = atlas(path)
  end
  local canvas = _atlases_cache[path]
  local w = canvas:getWidth() / tech_constants.CELL_DISPLAY_SIZE
  index = index - 1
  return Vector({index % w, math.floor(index / w)})
end

local font_cache = {}

sprite.get_font = function(size)
  if not font_cache[size] then
    font_cache[size] = love.graphics.newFont("assets/fonts/joystix.monospace-regular.otf", size)
  end
  return font_cache[size]
end

sprite.text = function(text, size)
  return setmetatable({
    text = text,
    font = sprite.get_font(size),
    _size = size,
  }, sprite.text_mt)
end

return sprite
