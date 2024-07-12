local random = require("utils.random")


local module = {}

local damage_font = love.graphics.newFont("assets/fonts/joystix.monospace-regular.otf", 14)

module.floating_damage = function(number, scene_position)
  number = tostring(number)
  return {
    position = scene_position * State.CELL_DISPLAY_SIZE * State.SCALING_FACTOR
      + Vector({random.d(12) - 6, random.d(12) - 6}),
    view = "scene_fx",
    drift = Vector({0, -24}),
    sprite = {
      text = {Common.hex_color("e64e4b"), number},
      font = damage_font,
    },
    life_time = 3,
  }
end

local line_font = love.graphics.newFont("assets/fonts/joystix.monospace-regular.otf", 10)

module.floating_line = function(text, position)
  return {
    position = (position - Vector({1, 1.5})) * 16,
    view = "scene_fx",
    sprite = {
      text = {Common.hex_color("ededed"), text},
      font = line_font,
    },
    life_time = 10,
  }
end

module.text = function(text, font, position, decorations)
  decorations = decorations or {}
  return {
    position = position,
    sprite = {
      text = text,
      font = font,
      is_underlined = decorations.underline or nil
    },
  }
end

return module
