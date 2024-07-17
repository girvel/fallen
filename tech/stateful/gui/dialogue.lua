local wrapping = require("tech.stateful.gui.wrapping")


return function()
  return {
    text_entities = nil,

    show = function(self, line)
      self.text_entities = State:add_multiple(wrapping.generate_page(
        line, State.gui.font, math.min(love.graphics.getWidth() - 40, State.gui.TEXT_MAX_SIZE[1]),
        "dialogue_text"
      ))
    end,

    skip = function(self)
      State:remove_multiple(self.text_entities)
      self.text_entities = nil
    end,
  }
end
