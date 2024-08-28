local animated = require("tech.animated")
local view = require("utils.view")
local tech_constants = require("tech.constants")
local sprite = require("tech.sprite")


local gui, module_mt, static = Module("state.gui")

local PORTRAIT_SPACE = Vector({360, 190})

module_mt.__call = function()
  local result = {
    TEXT_MAX_SIZE = Vector({1000, 800}),
    font_size = 12,
    show_fps = nil,  -- set from main.lua
    disable_ui = false,
    pressed_scancodes = {},

    -- TODO unify views, views order and updating views?
    -- Vector.zero and duplicating the order suggest that
    views = {
      scene = view(Vector.zero, 4, 16),
      scene_fx = view(Vector.zero, 1, 1),
      sidebar_background = view(Vector.zero, 2, 1),
      actions = view(Vector.zero, 3, 1),
      action_keys = view(Vector.zero, 3, 1),
      action_frames = view(Vector.zero, 3, 1),
      sidebar = view(Vector.zero, 2, 1),
      sidebar_text = view(Vector.zero, 1, 1),
      notification = view(Vector.zero, 1, 1),
      notification_fx = view(Vector.zero, 3, 1),
      dialogue_background = view(Vector.zero, 1, 1),
      dialogue_portrait = view(Vector.zero, 2, 1),
      dialogue_text = view(Vector.zero, 1, 1),
      wiki = view(Vector.zero, 1, 1),
      character_creator = view(Vector.zero, 1, 1),
      scene_popup_background = view(Vector.zero, 1, 1),
      scene_popup_content = view(Vector.zero, 1, 1),
    },

    views_order = {
      "scene", "scene_fx",
      "sidebar_background", "actions", "action_frames", "action_keys", "sidebar", "sidebar_text",
      "notification", "notification_fx",
      "dialogue_background", "dialogue_portrait", "dialogue_text",
      "wiki", "character_creator",
      "scene_popup_background", "scene_popup_content",
    },

    update_views = function(self)
      for key, value in pairs({
        scene_fx = gui._get_scene_offset(),
        scene = gui._get_scene_offset(),
        actions = gui._get_actions_offset(),
        action_frames = gui._get_actions_offset(),
        action_keys = gui._get_actions_offset(),
        sidebar_background = Vector({love.graphics.getWidth() - State.gui.sidebar.W, 0}),
        sidebar = Vector({love.graphics.getWidth() - State.gui.sidebar.W, 0}),
        sidebar_text = Vector({love.graphics.getWidth() - State.gui.sidebar.W, 0}),
        notification = gui._get_dialogue_offset() + Vector.up * 70,
        notification_fx = gui._get_dialogue_offset() + Vector.up * 70,
        dialogue_background = Vector.zero,
        dialogue_portrait = gui._get_dialogue_offset() - PORTRAIT_SPACE,
        dialogue_text = gui._get_dialogue_offset(),
        wiki = gui._get_full_screen_text_offset(),
        character_creator = gui._get_creator_text_offset(),
        scene_popup_background = gui._get_scene_offset(),
        scene_popup_content = gui._get_scene_offset(),
      }) do
        State.gui.views[key].offset = value
      end
    end,
  }

  -- TODO maybe move this?
  result.wiki = require("state.gui.wiki")()
  result.sidebar = require("state.gui.sidebar")()
  result.dialogue = require("state.gui.dialogue")()
  result.character_creator = require("state.gui.character_creator")()
  result.text_input = require("state.gui.text_input")()

  return result
end

gui._get_scene_offset = function()
  local scene_k = State.gui.views.scene:get_multiplier()
  local window_size = Vector({love.graphics.getDimensions()})
  local border_size = (window_size / 2 - Vector.one * scene_k):map(math.floor)
  local player_position = animated.get_render_position(State.player) * scene_k
  local grid_size = State.grids.solids.size * scene_k

  local prev = State.gui.views.scene_fx.offset
  local target = -Vector.use(Math.median,
    Vector.zero,
    player_position - window_size + border_size,
    -prev,
    player_position - border_size,
    grid_size - window_size
  )

  local d = target - prev
  return prev + d / 20
end

gui._get_dialogue_offset = function()
  local window_w = love.graphics.getWidth()
  local window_h = love.graphics.getHeight()
  local dialogue_w = math.min(window_w - 15, State.gui.TEXT_MAX_SIZE[1] + PORTRAIT_SPACE[1])

  return Vector({math.ceil((window_w - dialogue_w) / 2 + PORTRAIT_SPACE[1]), window_h - 115})
end

gui._get_full_screen_text_offset = function()
  local w, h = love.graphics.getDimensions()
  local sx, sy = unpack(State.gui.TEXT_MAX_SIZE)
  return (Vector({math.max(30, w - sx), math.max(30, h - sy)}) / 2):ceil()
end

gui._get_creator_text_offset = function()
  local w, h = love.graphics.getDimensions()
  local sx, sy = unpack(State.gui.TEXT_MAX_SIZE)
  return (Vector({
    math.max(30, w - sx),
    math.max(30, h - sy) + State.gui.character_creator.parameters.scroll
  }) / 2):ceil()
end

gui._get_actions_offset = function()
  return Vector({love.graphics.getWidth() - State.gui.sidebar.W + 16, 64 + 15})
end

return gui
