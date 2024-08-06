Static.module("tech.sprite")
local sprite = Static {}

sprite.image_mt = Static {
  __serialize = function(self)
    local data = self.data:getString()
    local w, h = self.data:getDimensions()
    return function()
      return sprite.image(love.image.newImageData(w, h, "rgba8", data))
    end
  end
}

sprite.text_mt = Static {
  __serialize = function(self)
    local text = self.text
    local size = self._size
    return function()
      return sprite.text(text, size)
    end
  end
}

sprite.image = function(base, anchor)
  if type(base) == "string" then
    base = love.image.newImageData(base)
  end

  return setmetatable({
    image = love.graphics.newImage(base),
    data = base,
    color = Common.get_color(base),
    anchor = anchor,
  }, sprite.image_mt)
end

local font_cache = {}

sprite.text = function(text, size)
  if not font_cache[size] then
    font_cache[size] = love.graphics.newFont("assets/fonts/joystix.monospace-regular.otf", size)
  end

  return setmetatable({
    text = text,
    font = font_cache[size],
    _size = size,
  }, sprite.text_mt)
end

return sprite
