local colors, module_mt, static = Module("lib.colors")

local hex = {
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
}

module_mt.__index = function(_, k)
  if k == "hex" then return hex end
  return Common.hex_color(hex[k])
end

return colors
