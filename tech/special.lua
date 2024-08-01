local random = require("utils.random")
local animated = require("tech.animated")
local static_sprite = require("tech.static_sprite")
local tech_constants = require("tech.constants")


local module = {}

local damage_font = love.graphics.newFont("assets/fonts/joystix.monospace-regular.otf", 14)

module.floating_damage = function(number, scene_position)
  number = tostring(number)
  return {
    boring_flag = true,
    codename = "floating_damage",
    position = scene_position * tech_constants.CELL_DISPLAY_SIZE * State.SCALING_FACTOR
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

local line_font = love.graphics.newFont("assets/fonts/joystix.monospace-regular.otf", 14)

module.floating_line = function(text, position)
  return {
    codename = "floating_line",
    position = (position - Vector({0, 0.5}))
      * tech_constants.CELL_DISPLAY_SIZE * State.SCALING_FACTOR
      + Vector.left * line_font:getWidth(text) / 2,
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
    boring_flag = true,
    codename = "text",
    position = position,
    sprite = {
      text = text,
      font = font,
      is_underlined = decorations.underline or nil
    },
  }
end

local highlight_pack = animated.load_pack("assets/sprites/highlight")

module.highlight = function()
  return Tablex.extend(animated(highlight_pack), {layer = "fx", view = "scene"})
end

module.hp_bar = function()
  return Tablex.extend(
    animated("assets/sprites/hp_bar"),
    {
      codename = "hp_bar",
      view = "sidebar",
      position = Vector({9, 9}),
    }
  )
end

module.hp_text = function()
  return {
    codename = "hp_text",
    view = "sidebar_text",
    position = Vector.zero,
    sprite = {
      text = "",
      font = love.graphics.newFont("assets/fonts/joystix.monospace-regular.otf", 20),
    },
  }
end

module.notification = function()
  return {
    codename = "notification",
    view = "sidebar_text",
    position = Vector.zero,
    sprite = {
      text = {{1, 1, 1}, ""},
      font = love.graphics.newFont("assets/fonts/joystix.monospace-regular.otf", 18),
    },
  }
end

module.notification_fx = function()
  return Tablex.extend(
    animated("assets/sprites/notification_fx"),
    {
      codename = "notification_fx",
      view = "sidebar",
      position = Vector({-117, 4})
    }
  )
end

module.gui_background = function()
  return Tablex.extend(
    static_sprite("assets/sprites/hp_background.png"),
    {
      codename = "sidebar_background",
      view = "sidebar_background",
      position = Vector.zero,
    }
  )
end

module.dialogue_background = function()
  local window_w, window_h = love.graphics.getDimensions()
  return {
    boring_flag = true,
    codename = "dialogue_background",
    view = "dialogue_background",
    position = Vector({0, window_h - 140}),
    size = Vector({window_w, 140}),
    sprite = {
      rect_color = Common.hex_color("31222c"),
    },
  }
end

return module
