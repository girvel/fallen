local colors, module_mt, static = Module("lib.colors")

colors.from_hex = function(str)
  return Fun.range(#str / 2)
    :map(function(i) return tonumber(str:sub(i * 2 - 1, i * 2), 16) / 255 end)
    :totable()
end

colors.to_hex = function(color)
  return Fun.iter(color)
    :map(function(v) return "%x" % (v * 255) end)
    :reduce(Fun.op.concat, "")
end

colors.get = function(image_data)
  local color_ns = {}
  for x = 0, image_data:getWidth() - 1 do
    for y = 0, image_data:getHeight() - 1 do
      local color = {image_data:getPixel(x, y)}
      if (color[1] > 0 or color[2] > 0 or color[3] > 0)
        and color[4] > 0
        and Fun.iter(colors.anchor)
          :all(function(_, a) return not colors.equal(color, a()) end)
      then
        return color
      end
    end
  end
end

colors.equal = function(a, b)
  for i = 1, 4 do
    if math.abs((a[i] or 1) - (b[i] or 1)) > 1 / 256 then
      return false
    end
  end
  return true
end

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
  colors[k] = function()
    return colors.from_hex(v)
  end
end

colors.anchor = {}
for k, v in pairs({
  parent = "ff0000",
  main_hand = "fb0000",
  other_hand = "f70000",
  head = "f30000",
}) do
  colors.anchor[k] = function()
    return colors.from_hex(v)
  end
end

return colors
