local tech_constants = require("tech.constants")


local sprite, _, static = Module("tech.sprite")

sprite.image_mt = static {
  __serialize = function(self)
    local data = self.data:getString()
    local w, h = self.data:getDimensions()
    local anchors = self.anchors
    return function()
      return sprite.image(love.image.newImageData(w, h, "rgba8", data), nil, anchors)
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

sprite.image = Memoize(function(base, paint_color, anchors)
  -- TODO FFI
  if type(base) == "string" then
    base = love.image.newImageData(base)
  end
  base = base:clone()

  local main_color = paint_color or Colors.get(base)
  if paint_color or not anchors then
    anchors = anchors or {}
    base:mapPixel(function(x, y, r, g, b, a)
      local anchor_name = Fun.iter(Colors.anchor)
        :filter(function(name, this_anchor)
          return Colors.equal(this_anchor(), {r, g, b})
        end)
        :nth(1)

      if anchor_name then
        anchors[anchor_name] = Vector({x, y})
        return unpack(main_color)
      end

      if a == 0 then return 0, 0, 0, 0 end
      if r == 0 and g == 0 and b == 0 then return 0, 0, 0, 1 end
      if paint_color then
        return unpack(paint_color)
      else
        return r, g, b, a
      end
    end)
  end

  return setmetatable({
    image = love.graphics.newImage(base  --[[@as love.ImageData]]),
    data = base,
    color = main_color,
    anchors = anchors,
  }, sprite.image_mt)
end)

local _atlases_cache = {}

local atlas = function(path)
  local base_image = love.graphics.newImage(path)
  local canvas = love.graphics.newCanvas(base_image:getDimensions())
  love.graphics.setCanvas(canvas)
  love.graphics.draw(base_image)
  love.graphics.setCanvas()
  return canvas
end

sprite.from_atlas = Memoize(function(path, index)
  if not _atlases_cache[path] then
    _atlases_cache[path] = atlas(path)
  end
  local canvas = _atlases_cache[path]

  local size = tech_constants.CELL_DISPLAY_SIZE
  local w = canvas:getWidth()
  index = (index - 1) * size
  local image_data = canvas:newImageData(nil, nil, index % w, math.floor(index / w) * size, size, size)

  return sprite.image(image_data)
end)

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
