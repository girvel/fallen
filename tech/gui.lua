local sounds = require("tech.sounds")
local shaders = require("tech.shaders")
local animated = require("tech.animated")
local sprite = require("tech.sprite")


local gui, _, static = Module("tech.gui")

gui.floating_damage = function(number, scene_position, color)
  number = tostring(number)
  return {
    boring_flag = true,
    codename = "floating_damage",
    position = scene_position * State.gui.views.scene:get_multiplier()
      + Vector({math.random(12) - 6, math.random(12) - 6}),
    view = "scene_fx",
    drift = Vector({0, -24}),
    sprite = sprite.text({color or Colors.red, number}, 14),
    life_time = 3,
  }
end

gui.text = function(text, font_size, position)
  return {
    boring_flag = true,
    codename = "text",
    position = position,
    sprite = sprite.text(text, font_size),
  }
end

-- TODO figure out highlight behaviour structure
gui.highlight = function()
  return Table.extend(animated("assets/sprites/animations/highlight"), {layer = "fx", view = "scene"})
end

gui.hp_bar = function()
  return Table.extend(
    animated("assets/sprites/hp_bar"),
    {
      codename = "hp_bar",
      view = "sidebar",
      position = Vector({9, 9}),
    }
  )
end

gui.hp_text = function()
  return {
    codename = "hp_text",
    view = "sidebar_text",
    position = Vector.zero,
    sprite = sprite.text("", 20),
  }
end

gui.notification = function()
  return {
    codename = "notification",
    view = "notification",
    position = Vector.zero,
    sprite = sprite.text({Colors.white, ""}, 18),
  }
end

gui.notification_fx = function()
  return Table.extend(
    animated("assets/sprites/notification_fx"),
    {
      codename = "notification_fx",
      view = "notification",
      --position = Vector({-117, 4})
      position = Vector.zero,
    }
  )
end

gui.gui_background = function()
  return {
    codename = "sidebar_background",
    view = "sidebar_background",
    position = Vector.zero,
    sprite = sprite.image("assets/sprites/hp_background.png"),
  }
end

-- TODO replace w/ rect
gui.dialogue_background = function()
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

gui.rect = function(position, view, size, color)
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

gui.portrait = function(this_sprite)
  return {
    boring_flag = true,
    codename = "portrait",
    view = "dialogue_portrait",
    position = Vector.zero,
    size = Vector({this_sprite.image:getDimensions()}),
    sprite = this_sprite,
  }
end

local ACTION_CELL_SIZE = 18

gui.action_icon = function(hotkey_data, index, frame)
  index = index - 1
  return {
    sprite = sprite.image("assets/sprites/icons/%s.png" % hotkey_data.codename),
    view = "actions",
    position = Vector({index % 5, math.floor(index / 5)}) * ACTION_CELL_SIZE,
    size = Vector.one * 16,

    codename = "action_icon",
    boring_flag = true,

    is_active = function(self)
      return (State.player:can_act() or not hotkey_data.action)
        and -Query(hotkey_data.action):get_availability(State.player)
    end,

    on_hover = function(self)
      if not self:is_active() then return end
      if frame.sprite ~= frame.sprites.active then
        State.audio:play_static(Random.choice(sounds.click))
      end
      frame.sprite = frame.sprites.active
    end,

    on_hover_end = function(self)
      frame.sprite = frame.sprites.inactive
    end,

    on_click = function(self)
      table.insert(State.player.action_factories, hotkey_data)
    end,

    changes_cursor = function(self)
      return self:is_active()
    end,

    ai = {
      observe = function(self)
        self.shader = not self:is_active()
          and shaders.grayscale
          or nil
      end,
    }
  }
end

local frame_sprites = {
  active = sprite.image("assets/sprites/frame/active.png"),
  inactive = sprite.image("assets/sprites/frame/inactive.png"),
}

gui.action_frame = function(index)
  index = index - 1
  return {
    sprites = frame_sprites,
    sprite = frame_sprites.inactive,
    view = "action_frames",
    position = Vector({index % 5, math.floor(index / 5)}) * ACTION_CELL_SIZE - Vector({1, 1}),

    codename = "action_icon",
    boring_flag = true,
  }
end

gui.action_hotkey = function(key, index)
  index = index - 1
  local font_size = 18 / (#key) ^ 0.5
  local font = sprite.get_font(font_size)
  local view_name = "action_keys"
  local view = State.gui.views[view_name]
  return {
    sprite = sprite.text(key, font_size),
    view = view_name,
    position = Vector({index % 5, math.floor(index / 5)}) * ACTION_CELL_SIZE + Vector({
      16 - font:getWidth(key) / view:get_multiplier(),
      16 - font:getHeight() / view:get_multiplier(),
    }),

    codename = "action_hotkey",
    boring_flag = true,
  }
end

return gui
