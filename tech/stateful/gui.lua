local wrapping = require("tech.stateful.wrapping")


return {
  LINK_COLOR = Common.hex_color("60b37e"),
  TEXT_MAX_W = 1000,
  font = love.graphics.newFont("assets/fonts/joystix.monospace-regular.otf", 12),

  show_page = function(self, path)
    self.text_entities = Fun.iter(wrapping.generate_wiki_page(
      love.filesystem.read(path), self.font, State.gui.TEXT_MAX_W
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
