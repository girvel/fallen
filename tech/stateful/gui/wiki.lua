local wrapping = require("tech.stateful.gui.wrapping")


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

return function()
  return {
    pages = load_wiki("assets/wiki"),
    discovered_pages = {lorem = 1, angels = 1},
    history = {},
    current_history_index = 0,
    text_entities = nil,

    show = function(self, id)
      assert(self.pages[id], "Wiki page \"" .. id .. "\" does not exist")

      self.history = Fun.iter(self.history)
        :take_n(self.current_history_index)
        :chain({id})
        :totable()

      self.current_history_index = self.current_history_index + 1
      self:_render_current_page()
    end,

    _render_current_page = function(self)
      self:_close_page()
      local id = self.history[self.current_history_index]

      local page = self.discovered_pages[id]
        and self.pages[id][self.discovered_pages[id]]
        or "~ Нет информации ~"

      self.text_entities = State:add_multiple(wrapping.generate_page(
        page, State.gui.font, State.gui.TEXT_MAX_SIZE[1], "wiki"
      ))
    end,

    _close_page = function(self)
      if not self.text_entities then return end
      State:remove_multiple(self.text_entities)
      self.text_entities = nil
    end,

    exit = function(self)
      self:_close_page()
      self.history = {}
      self.current_history_index = 0
    end,

    move_in_history = function(self, direction)
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
  }
end
