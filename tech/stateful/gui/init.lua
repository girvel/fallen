local wrapping = require("tech.stateful.gui.wrapping")
local view = require("utils.view")


return function()
  local result = {
    TEXT_MAX_SIZE = Vector({1000, 800}),
    font = love.graphics.newFont("assets/fonts/joystix.monospace-regular.otf", 12),
    anchors = {},

    line_entities = nil, -- TODO use single storage table?

    views = {
      scene = view(Vector.zero, 4, 16),
      scene_fx = view(Vector.zero, 1, 1),
      actions = view(Vector.zero, 2, 24),
      gui_background = view(Vector.zero, 2, 1),
      gui = view(Vector.zero, 2, 1),
      gui_text = view(Vector.zero, 1, 1),
      dialogue_text = view(Vector.zero, 1, 1),
      wiki = view(Vector.zero, 1, 1),
    },

    views_order = {
      "scene", "scene_fx",
      "actions", "gui_background", "gui", "gui_text",
      "dialogue_text", "wiki",
    },

    show_line = function(self, line)
      self.line_entities = State:add_multiple(wrapping.generate_page(
        line, self.font, math.min(love.graphics.getWidth() - 40, self.TEXT_MAX_SIZE[1]),
        "dialogue_text"
      ))
    end,

    skip_line = function(self)
      State:remove_multiple(self.line_entities)
      self.line_entities = nil
    end,
  }

  result.wiki = require("tech.stateful.gui.wiki")(result)
  result.sidebar = require("tech.stateful.gui.sidebar")()

  return result
end
