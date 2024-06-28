local wrapping = require("tech.stateful.wrapping")


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
  LINK_COLOR = Common.hex_color("3f5d92"),
  TEXT_MAX_SIZE = Vector({1000, 800}),
  font = love.graphics.newFont("assets/fonts/joystix.monospace-regular.otf", 12),
  current_wiki_offset = Vector.zero,

  wiki_pages = Log.trace(load_wiki("assets/wiki")),
  discovered_pages = {lorem = 1, angels = 1},

  show_page = function(self, id)
    assert(self.wiki_pages[id], "Wiki page \"" .. id .. "\" does not exist")

    self:exit_wiki()

    local page = self.discovered_pages[id]
      and self.wiki_pages[id][self.discovered_pages[id]]
      or "~ Нет информации ~"

    self.text_entities = Fun.iter(wrapping.generate_wiki_page(
      page, self.font, State.gui.TEXT_MAX_SIZE[1]
    ))
      :map(function(e) return State:add(e) end)
      :totable()
  end,

  exit_wiki = function(self)
    if not self.text_entities then return end
    for _, e in ipairs(self.text_entities) do
      State:remove(e)
    end
    self.text_entities = nil
  end,
}
