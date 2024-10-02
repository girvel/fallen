local animated = require("tech.animated")
local view = require("tech.view")


local gui, module_mt, static = Module("state.gui")

local produce_views = function(matrix)
  local views = {}
  local views_order = {}
  local views_offset_functions = {}

  for _, v in ipairs(matrix) do
    local name, scale, cell_size, f = unpack(v)
    views[name] = view(Vector.zero, scale, cell_size)
    table.insert(views_order, name)
    views_offset_functions[name] = f
  end

  return views, views_order, views_offset_functions
end

local PORTRAIT_SPACE = Vector({360, 190})

module_mt.__call = function(_)
  local result = {
    TEXT_MAX_SIZE = Vector({1000, 800}),
    font_size = 12,
    show_fps = nil,  -- set from main.lua
    disable_ui = false,
    pressed_scancodes = {},

    styles = {
      default = {
        font_size = 12,
        color = Colors.white(),
      },
      a = {
        color = Colors.from_hex("3f5d92"),
      },
      hate = {
        color = Colors.red(),
        delay = 0.1,
        appearance_time = .4,
      },
      h1_prefix = {
        color = Colors.dark_red(),
      },
      h2_prefix = {
        color = Colors.dark_red(),
      },
      b = {
        color = Colors.dark_yellow(),
      }
    },

    _update_views = function(self)
      for key, f in pairs(self.views_offset_functions) do
        State.gui.views[key].offset = f()
      end
    end,

    initialize = function(self)
      for _, k in ipairs({
        "sidebar",
        "notifier",
      }) do
        self[k]:initialize()
      end
    end,

    update = function(self, dt)
      self:_update_views()
      for _, k in ipairs({
        "sidebar",
        "notifier",
      }) do
        self[k]:update(dt)
      end
    end,
  }

  result.views, result.views_order, result.views_offset_functions = produce_views({
    {"scene", 4, 16, gui.offsets.scene},
    {"scene_fx", 1, 1, gui.offsets.scene},
    {"sidebar_background", 2, 1, gui.offsets.sidebar},
    {"actions", 3, 1, gui.offsets.actions},
    {"action_keys", 3, 1, gui.offsets.actions},
    {"action_frames", 3, 1, gui.offsets.actions},
    {"sidebar", 2, 1, gui.offsets.sidebar},
    {"sidebar_text", 1, 1, gui.offsets.sidebar},
    {"notification", 1, 1, gui.offsets.notification},
    {"notification_fx", 2, 1, gui.offsets.notification},
    {"dialogue_background", 1, 1, nil},
    {"dialogue_portrait", 2, 1, gui.offsets.portrait},
    {"dialogue_text", 1, 1, gui.offsets.dialogue},
    {"wiki", 1, 1, gui.offsets.full_screen_text},
    {"creator_text", 1, 1, gui.offsets.creator_text},
    {"scene_popup_background", 1, 1, gui.offsets.scene},
    {"scene_popup", 1, 1, gui.offsets.scene},
    {"tooltip_background", 1, 1, gui.offsets.tooltip},
    {"tooltip", 1, 1, gui.offsets.tooltip},
  })

  result.wiki = require("state.gui.wiki")(result)
  result.sidebar = require("state.gui.sidebar")()
  result.dialogue = require("state.gui.dialogue")()
  result.creator = require("state.gui.creator")(result)
  result.text_input = require("state.gui.text_input")()
  result.tooltip = require("state.gui.tooltip")(result)
  result.hint = require("state.gui.hint")()
  result.notifier = require("state.gui.notifier")()

  return result
end

gui.offsets = static {}

gui.offsets.scene = static .. function()
  local scene_k = State.gui.views.scene:get_multiplier()
  local window_size = Vector({love.graphics.getDimensions()})
  local border_size = (window_size / 2 - Vector.one * scene_k):map(math.floor)
  local player_position = animated.get_render_position(State.player) * scene_k
  --local grid_size = State.grids.solids.size * scene_k

  local prev = State.gui.views.scene_fx.offset
  local target = -Vector.use(Math.median,
    --Vector.zero,
    player_position - window_size + border_size,
    -prev,
    player_position - border_size
    --grid_size - window_size
  )

  local d = target - prev
  local length = d:abs()
  return prev + (d:fully_normalized() * Math.median(3, length / 20, length)):map(math.floor)
end

gui.offsets.dialogue = static .. function()
  local window_w = love.graphics.getWidth()
  local window_h = love.graphics.getHeight()
  local dialogue_w = math.min(window_w - 15, State.gui.TEXT_MAX_SIZE[1] + PORTRAIT_SPACE[1])

  return Vector({math.ceil((window_w - dialogue_w) / 2 + PORTRAIT_SPACE[1]), window_h - 115})
end

gui.offsets.portrait = static .. function()
  return gui.offsets.dialogue() - PORTRAIT_SPACE
end

gui.offsets.full_screen_text = static .. function()
  local w, h = love.graphics.getDimensions()
  local sx, sy = unpack(State.gui.TEXT_MAX_SIZE)
  return (Vector({math.max(30, w - sx), math.max(30, h - sy)}) / 2):ceil()
end

gui.offsets.creator_text = static .. function()
  -- TODO! reimplement scroll
  local w, h = love.graphics.getDimensions()
  local tw, th = unpack(State.gui.TEXT_MAX_SIZE)
  local marginx = math.ceil(math.max(30, w - tw) / 2)
  local marginy = math.ceil(math.max(30, h - th) / 2)
  return Vector {
    marginx,
    Math.median(
      marginy,
      w / 3 + State.gui.creator.scroll,
      State.gui.creator.size[2] + marginy * 2 - h
    ),
  }
end

gui.offsets.actions = static .. function()
  return Vector({love.graphics.getWidth() - State.gui.sidebar.W + 16, 64 + 15})
end

gui.offsets.sidebar = static .. function()
  return Vector({love.graphics.getWidth() - State.gui.sidebar.W, 0})
end

gui.offsets.notification = static .. function()
  return gui.offsets.dialogue() + Vector.up * 70
end

gui.offsets.tooltip = function()
  return State.gui.tooltip.position
end

return gui
