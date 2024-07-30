local view = require("utils.view")


return function()
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
  }

  result.font:setLineHeight(1.2)

  result.wiki = require("state.gui.wiki")()
  result.sidebar = require("state.gui.sidebar")()
  result.dialogue = require("state.gui.dialogue")()
  result.character_creator = require("state.gui.character_creator")()

  return result
end
