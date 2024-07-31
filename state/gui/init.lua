local view = require("utils.view")
local tech_constants = require("tech.constants")


local get_scene_offset, get_dialogue_offset, get_full_screen_text_offset

local gui = function()
  local result = {
    TEXT_MAX_SIZE = Vector({1000, 800}),
    font = love.graphics.newFont("assets/fonts/joystix.monospace-regular.otf", 12),

    views = {
      scene = view(Vector.zero, 4, 16),
      scene_fx = view(Vector.zero, 1, 1),
      sidebar_background = view(Vector.zero, 2, 1),
      actions = view(Vector.zero, 2, 24),
      sidebar = view(Vector.zero, 2, 1),
      sidebar_text = view(Vector.zero, 1, 1),
      dialogue_background = view(Vector.zero, 1, 1),
      dialogue_text = view(Vector.zero, 1, 1),
      wiki = view(Vector.zero, 1, 1),
      character_creator = view(Vector.zero, 1, 1),
    },

    views_order = {
      "scene", "scene_fx",
      "sidebar_background", "actions", "sidebar", "sidebar_text",
      "dialogue_background", "dialogue_text", "wiki", "character_creator",
    },

    update_views = function(self)
      for key, value in pairs({
        scene_fx = get_scene_offset(),
        scene = get_scene_offset(),
        actions = Vector({love.graphics.getWidth() - State.gui.sidebar.W + 16, 64 + 15}),
        sidebar_background = Vector({love.graphics.getWidth() - State.gui.sidebar.W, 0}),
        sidebar = Vector({love.graphics.getWidth() - State.gui.sidebar.W, 0}),
        sidebar_text = Vector({love.graphics.getWidth() - State.gui.sidebar.W, 0}),
        dialogue_background = Vector.zero,
        dialogue_text = get_dialogue_offset(),
        wiki = get_full_screen_text_offset(),
        character_creator = get_full_screen_text_offset(),
      }) do
        State.gui.views[key].offset = value
      end
    end,
  }

  result.font:setLineHeight(1.2)

  result.wiki = require("state.gui.wiki")()
  result.sidebar = require("state.gui.sidebar")()
  result.dialogue = require("state.gui.dialogue")()
  result.character_creator = require("state.gui.character_creator")()

  return result
end

get_scene_offset = function()
  if not State.player then return Vector.zero end
  local window_w = love.graphics.getWidth()
  local window_h = love.graphics.getHeight()
  local border_w = math.floor(window_w / 3)
  local border_h = math.floor(window_h / 3)
  local player_x, player_y = unpack(State.player.position * tech_constants.CELL_DISPLAY_SIZE * State.SCALING_FACTOR)
  local grid_w, grid_h = unpack(State.grids.solids.size * tech_constants.CELL_DISPLAY_SIZE * State.SCALING_FACTOR)

  local result = -Vector({
    Mathx.median(
      0,
      player_x - window_w + border_w,
      -State.gui.views.scene_fx.offset[1],
      player_x - border_w,
      grid_w - window_w
    ),
    Mathx.median(
      0,
      player_y - window_h + border_h,
      -State.gui.views.scene_fx.offset[2],
      player_y - border_h,
      grid_h - window_h
    )
  })

  return result
end

get_dialogue_offset = function()
  local window_w = love.graphics.getWidth()
  local window_h = love.graphics.getHeight()
  local text_w = math.min(window_w - 40, State.gui.TEXT_MAX_SIZE[1])

  return Vector({math.ceil((window_w - text_w) / 2), window_h - 115})
end

get_full_screen_text_offset = function()
  local w, h = love.graphics.getDimensions()
  local sx, sy = unpack(State.gui.TEXT_MAX_SIZE)
  return (Vector({math.max(30, w - sx), math.max(30, h - sy)}) / 2):ceil()
end

return gui
