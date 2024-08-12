local colors, module_mt, static = Module("lib.colors")

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
}

for k, v in pairs(colors.hex) do
  colors[k] = static(Common.hex_color(v))
end

return colors
