--- @alias color [number, number, number, number?]

local colors, module_mt, static = Module("lib.colors")

--- @param str string
--- @return color
colors.from_hex = function(str)
  return Fun.range(#str / 2)
    :map(function(i) return tonumber(str:sub(i * 2 - 1, i * 2), 16) / 255 end)
    :totable()
end

--- @param color color
--- @return string
colors.to_hex = function(color)
  return Fun.iter(color)
    :map(function(v) return "%x" % (v * 255) end)
    :reduce(Fun.op.concat, "")
end

--- @param image_data love.ImageData
--- @return color
colors.get = function(image_data)
  for x = 0, image_data:getWidth() - 1 do
    for y = 0, image_data:getHeight() - 1 do
      local color = {image_data:getPixel(x, y)}
      if (color[1] > 0 or color[2] > 0 or color[3] > 0)
        and color[4] > 0
        and Fun.iter(colors.anchor)
          :all(function(_, a) return not colors.equal(color, a) end)
      then
        return color
      end
    end
  end

  return Colors.white
end

--- @param a color
--- @param b color
--- @return boolean
colors.equal = function(a, b)
  for i = 1, 4 do
    if math.abs((a[i] or 1) - (b[i] or 1)) > 1 / 256 then
      return false
    end
  end
  return true
end

--- @enum (key) color_name
colors.hex = static {
  absolute_white = "ffffff",
  absolute_black = "000000",

  white = "ededed",
  black = "000000",
  green = "60b37e",
  light_green = "b3daa3",
  red = "e64e4b",
  dark_red = "5d375a",
  gray = "8b7c99",
  dark_brown = "31222c",
  yellow = "f7e5b2",
  dark_yellow = "fcc48d",
}

for k, v in pairs(colors.hex) do
  colors[k] = colors.from_hex(v)
end

--- @enum (key) anchor
colors.anchor_hex = {
  parent = "ff0000",
  main_hand = "fb0000",
  other_hand = "f70000",
  head = "f30000",
}

--- @type {[anchor]: color}
colors.anchor = {}
for k, v in pairs(colors.anchor_hex) do
  colors.anchor[k] = colors.from_hex(v)
end

return colors
