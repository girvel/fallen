local wrapping = require("tech.stateful.gui.wrapping")
local view = require("utils.view")
local special = require("tech.special")


return function() 
  local result = {
    TEXT_MAX_SIZE = Vector({1000, 800}),
    font = love.graphics.newFont("assets/fonts/joystix.monospace-regular.otf", 12),
    anchors = {},

    action_entities = {},
    hp_bar = nil,

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

    ACTION_GRID_W = 5,

    update_action_grid = function(self)
      Fun.iter(self.action_entities):each(function(a)
        State:remove(a)
      end)

      self.action_entities = Fun.iter(State.player:get_actions())
        :enumerate()
        :map(function(i, action)
          State:add(Tablex.extend({
            position = Vector({
              (i - 1) % self.ACTION_GRID_W,
              math.floor(i / self.ACTION_GRID_W)
            }),
            view = "actions",
          }, action))
        end)
        :totable()
    end,

    create_gui_entities = function(self)
      State:add(special.gui_background())
      self.hp_bar = State:add(special.hp_bar())
      self.hp_text = State:add(special.hp_text())
    end,
  }

  result.wiki = require("tech.stateful.gui.wiki")(result)

  return result
end
