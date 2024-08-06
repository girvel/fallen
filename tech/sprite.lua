Static.module("tech.sprite")
local sprite = Static {}

sprite.mt = Static {
  __serialize = function(self)
    local data = self.data:getString()
    local w, h = self.data:getDimensions()
    return function()
      return sprite.image(love.image.newImageData(w, h, "rgba8", data))
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
  }, sprite.mt)
end

return sprite
