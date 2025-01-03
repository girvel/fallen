local sound = require("tech.sound")
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

gui.notification = function(i)
  return {
    codename = "notification",
    view = "notification",
    position = Vector.zero + Vector.up * 35 * (i - 1),
    sprite = sprite.text({Colors.white, ""}, 18),
    display_time = 0,
  }
end

gui.notification_fx = function()
  return Table.extend(
    animated("assets/sprites/notification_fx"),
    {
      codename = "notification_fx",
      view = "notification_fx",
      position = Vector({0, -6}),
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
      rect_color = Colors.from_hex("31222c"),
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

local icon_indexes = Fun.iter({
  "zero", "up", "down", "left", "right", "open_codex", "open_journal", "open_creator",
  "submit", "exit", false, false, false, false, false, false,
  "finish_turn", "dash", "interact", "disengage", "hit_dice", "hand_attack", "other_hand_attack", false,
  "second_wind", "action_surge", "fighting_spirit", false, false, false, false, false,
  "toggle_gwm", false, false, false, false, false, false, false,
  "brutal_attack", "aim",
})
  :enumerate()
  :map(function(k, v) return v, k end)
  :tomap()

gui.action_icon = function(hotkey_data, index, frame)
  index = index - 1
  return {
    hotkey_data = hotkey_data,
    get_tooltip = function(self)
      local header = self.hotkey_data.name
      local description =
        -Query(self.hotkey_data):get_description() or
        -Query(self.hotkey_data.action):get_description(State.player)

      if not header and not description then return end
      return Html.span {
        header and Html.h1 {header} or "",
        description or "",
      }
    end,
    _frame = frame,

    sprite = sprite.from_atlas(
      "assets/sprites/atlases/icons.png",
      icon_indexes[hotkey_data.codename]
    ),
    view = "actions",
    position = Vector({index % 5, math.floor(index / 5)}) * ACTION_CELL_SIZE,
    size = Vector.one * 16,

    codename = "action_icon",
    boring_flag = true,

    is_active = function(self)
      return (State.player:can_act() or not self.hotkey_data.action)
        and (not self.hotkey_data.get_availability or self.hotkey_data:get_availability())
        and (not self.hotkey_data.action or self.hotkey_data.action:get_availability(State.player))
    end,

    on_hover = function(self)
      State.gui.sidebar.hovered_icon = self
      if not self:is_active() then
        return
      end
      if self._frame.sprite ~= self._frame.sprites.active then
        sound.play(sounds.click)
      end
      self._frame.sprite = self._frame.sprites.active
    end,

    on_hover_end = function(self)
      State.gui.sidebar.hovered_icon = nil
    end,

    on_click = function(self)
      table.insert(State.player.action_factories, self.hotkey_data)
    end,

    changes_cursor = function(self)
      return self:is_active()
    end,

    ai = {
      observe = function(self, entity)
        if State.gui.sidebar.hovered_icon ~= entity then
          entity._frame.sprite = entity._frame.sprites[
            -Query(entity.hotkey_data):is_passive_enabled() and "passive" or "inactive"
          ]
        end
        entity.shader = not entity:is_active()
          and shaders.grayscale
          or nil
      end,
    }
  }
end

local frame_sprites = {
  active = sprite.image("assets/sprites/frame/active.png"),
  inactive = sprite.image("assets/sprites/frame/inactive.png"),
  passive = sprite.image("assets/sprites/frame/passive.png"),
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
