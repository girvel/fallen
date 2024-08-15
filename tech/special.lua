local random = require("utils.random")
local animated = require("tech.animated")
local sprite = require("tech.sprite")


local module, _, static = Module("tech.special")

module.floating_damage = function(number, scene_position, color)
  number = tostring(number)
  return {
    boring_flag = true,
    codename = "floating_damage",
    position = State.gui.views.scene:apply_multiplier(scene_position)
      + Vector({random.d(12) - 6, random.d(12) - 6}),
    view = "scene_fx",
    drift = Vector({0, -24}),
    sprite = sprite.text({color or Colors.red, number}, 14),
    life_time = 3,
  }
end

module.text = function(text, font_size, position)
  return {
    boring_flag = true,
    codename = "text",
    position = position,
    sprite = sprite.text(text, font_size),
  }
end

local highlight_pack = animated.load_pack("assets/sprites/highlight")

-- TODO figure out highlight behaviour structure
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
    sprite = sprite.text("", 20),
  }
end

module.notification = function()
  return {
    codename = "notification",
    view = "notification",
    position = Vector.zero,
    sprite = sprite.text({Colors.white, ""}, 18),
  }
end

module.notification_fx = function()
  return Tablex.extend(
    animated("assets/sprites/notification_fx"),
    {
      codename = "notification_fx",
      view = "notification",
      --position = Vector({-117, 4})
      position = Vector.zero,
    }
  )
end

module.gui_background = function()
  return {
    codename = "sidebar_background",
    view = "sidebar_background",
    position = Vector.zero,
    sprite = sprite.image("assets/sprites/hp_background.png"),
  }
end

-- TODO replace w/ rect
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

module.rect = function(position, view, size, color)
  return {
    boring_flag = true,
    codename = "rect",
    view = view,
    position = position,
    size = size,
    sprite = {
      rect_color = color,
    },
  }
end

module.portrait = function(this_sprite)
  return {
    boring_flag = true,
    codename = "portrait",
    view = "dialogue_portrait",
    position = Vector.zero,
    size = Vector({this_sprite.image:getDimensions()}),
    sprite = this_sprite,
  }
end

return module
