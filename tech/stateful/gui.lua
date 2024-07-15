local wrapping = require("tech.stateful.wrapping")
local view = require("utils.view")
local special = require("tech.special")


local load_wiki = function(path)
  local pattern = "(.*)_(%d%d).md$"
  return Fun.iter(love.filesystem.getDirectoryItems(path))
    :filter(function(name) return name:find(pattern) end)
    :map(function(name)
      local _, _, id, index = name:find(pattern)
      return id, tonumber(index), love.filesystem.read(path .. "/" .. name)
    end)
    :reduce(function(acc, id, index, content)
      if not acc[id] then acc[id] = {} end
      acc[id][index] = content
      return acc
    end, {})
end

return {
  TEXT_MAX_SIZE = Vector({1000, 800}),
  font = love.graphics.newFont("assets/fonts/joystix.monospace-regular.otf", 12),
  anchors = {},

  wiki_pages = load_wiki("assets/wiki"),
  discovered_pages = {lorem = 1, angels = 1},
  history = {},
  current_history_index = 0,

  action_entities = {},
  hp_bar = nil,

  views = {
    scene = view(Vector.zero, 4, 16),
    scene_fx = view(Vector.zero, 1, 1),
    actions = view(Vector.zero, 2, 24),
    gui_background = view(Vector.zero, 2, 1),
    gui = view(Vector.zero, 2, 1),
    gui_text = view(Vector.zero, 1, 1),
    wiki = view(Vector.zero, 1, 1),
  },

  views_order = {
    "scene", "scene_fx", "actions", "gui_background", "gui", "gui_text", "wiki",
  },

  _render_current_page = function(self)
    self:_close_page()
    local id = self.history[self.current_history_index]

    local page = self.discovered_pages[id]
      and self.wiki_pages[id][self.discovered_pages[id]]
      or "~ Нет информации ~"

    self.text_entities = Fun.iter(wrapping.generate_wiki_page(
      page, self.font, State.gui.TEXT_MAX_SIZE[1]
    ))
      :map(function(e) return State:add(e) end)
      :totable()
  end,

  show_page = function(self, id)
    assert(self.wiki_pages[id], "Wiki page \"" .. id .. "\" does not exist")

    self.history = Fun.iter(self.history)
      :take_n(self.current_history_index)
      :chain({id})
      :totable()

    self.current_history_index = self.current_history_index + 1
    self:_render_current_page()
  end,

  _close_page = function(self)
    if not self.text_entities then return end
    for _, e in ipairs(self.text_entities) do
      State:remove(e)
    end
    self.text_entities = nil
  end,

  exit_wiki = function(self)
    self:_close_page()
    self.history = {}
    self.current_history_index = 0
  end,

  move_in_wiki_history = function(self, direction)
    assert(direction == -1 or direction == 1)

    if
      direction < 0 and self.current_history_index <= 1 or
      direction > 0 and self.current_history_index == #self.history
    then
      return
    end

    self.current_history_index = self.current_history_index + direction
    self:_render_current_page()
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
