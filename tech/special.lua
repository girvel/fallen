local random = require("utils.random")


local module = {}

local damage_font = love.graphics.newFont("assets/fonts/joystix.monospace-regular.otf", 14)

module.floating_damage = function(number, position)
  return {
    off_grid_position = (position - Vector({1, 1})) * 16
      + Vector({random.d(12) - 6, random.d(12) - 6}),  -- TODO fix magic number
    drift = Vector({0, -6}),
    layer = "sfx",
    sprite = {
      text = number,
      font = damage_font,
      color = Common.hex_color("e64e4b"),  -- TODO join w/ text as {color, text}
    },
    life_time = 3,
  }
end

local line_font = love.graphics.newFont("assets/fonts/joystix.monospace-regular.otf", 10)

module.floating_line = function(text, position)
  return {
    off_grid_position = (position - Vector({1, 1.5})) * 16,
    layer = "sfx",
    sprite = {
      text = text,
      font = line_font,
      color = Common.hex_color("ededed"),  -- TODO join w/ text as {color, text}
    },
    life_time = 10,
  }
end

module.text = function(text, font, position)
  return {
    gui_position = position,
    layer = "gui",
    sprite = {
      text = text,
      font = font,
    },
  }
end

return module
