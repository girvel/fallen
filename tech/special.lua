local random = require("utils.random")


local module = {}

local damage_font = love.graphics.newFont("assets/fonts/joystix.monospace-regular.otf", 14)

module.floating_damage = function(number, scene_position)
  number = tostring(number)
  return {
    gui_position = (scene_position - Vector({1, 1})) * State.CELL_DISPLAY_SIZE * State.SCALING_FACTOR
      + Vector({random.d(12) - 6, random.d(12) - 6})
      + Vector({
        State.CELL_DISPLAY_SIZE - damage_font:getWidth(number),
        State.CELL_DISPLAY_SIZE - damage_font:getHeight(),
      }) / 2,  -- TODO fix magic number
    view = "scene_fx",
    -- drift = Vector({0, -24}),
    sprite = {
      text = number,
      font = damage_font,
      color = Common.hex_color("e64e4b"),  -- TODO join w/ text as {color, text}
    },
    -- life_time = 3,
  }
end

local line_font = love.graphics.newFont("assets/fonts/joystix.monospace-regular.otf", 10)

module.floating_line = function(text, position)
  return {
    off_grid_position = (position - Vector({1, 1.5})) * 16,
    sprite = {
      text = text,
      font = line_font,
      color = Common.hex_color("ededed"),  -- TODO join w/ text as {color, text}
    },
    life_time = 10,
  }
end

module.text = function(text, font, position, decorations)
  decorations = decorations or {}
  return {
    gui_position = position,
    sprite = {
      text = text,
      font = font,
      is_underlined = decorations.underline or nil
    },
  }
end

return module
