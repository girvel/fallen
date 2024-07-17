local wrapping = require("tech.stateful.gui.wrapping")
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
    },

    views_order = {
      "scene", "scene_fx",
      "sidebar_background", "actions", "sidebar", "sidebar_text",
      "dialogue_background", "dialogue_text", "wiki",
    },
  }

  result.wiki = require("tech.stateful.gui.wiki")()
  result.sidebar = require("tech.stateful.gui.sidebar")()
  result.dialogue = require("tech.stateful.gui.dialogue")()

  return result
end
