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

    -- TODO unify views, views order and updating views?
    -- Vector.zero and duplicating the order suggest that
    views = {
      scene = view(Vector.zero, 4, 16),
      scene_fx = view(Vector.zero, 1, 1),
      sidebar_background = view(Vector.zero, 2, 1),
      actions = view(Vector.zero, 2, 24),
      sidebar = view(Vector.zero, 2, 1),
      sidebar_text = view(Vector.zero, 1, 1),
      notification = view(Vector.zero, 1, 1),
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
      "sidebar_background", "actions", "sidebar", "sidebar_text",
      "notification",
      "dialogue_background", "dialogue_portrait", "dialogue_text",
      "wiki", "character_creator",
      "scene_popup_background", "scene_popup_content",
    },

    update_views = function(self)
      for key, value in pairs({
        scene_fx = gui._get_scene_offset(),
        scene = gui._get_scene_offset(),
        actions = Vector({love.graphics.getWidth() - State.gui.sidebar.W + 16, 64 + 15}),
        sidebar_background = Vector({love.graphics.getWidth() - State.gui.sidebar.W, 0}),
        sidebar = Vector({love.graphics.getWidth() - State.gui.sidebar.W, 0}),
        sidebar_text = Vector({love.graphics.getWidth() - State.gui.sidebar.W, 0}),
        notification = gui._get_dialogue_offset() + Vector.up * 70,
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
  if not State.player then return Vector.zero end
  local window_w = love.graphics.getWidth()
  local window_h = love.graphics.getHeight()
  local border_w = math.floor(window_w / 2)
  local border_h = math.floor(window_h / 2)
  local player_x, player_y = unpack(State.player.position * tech_constants.CELL_DISPLAY_SIZE * State.SCALING_FACTOR)
  local grid_w, grid_h = unpack(State.grids.solids.size * tech_constants.CELL_DISPLAY_SIZE * State.SCALING_FACTOR)

  local result = -Vector({
    Mathx.median(
      player_x - window_w + border_w,
      -State.gui.views.scene_fx.offset[1],
      player_x - border_w
    ),
    Mathx.median(
      player_y - window_h + border_h,
      -State.gui.views.scene_fx.offset[2],
      player_y - border_h
    )
  })

  return result
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

return gui
