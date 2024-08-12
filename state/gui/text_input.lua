local sprite = require("tech.sprite")


return Module("state.gui.text_input", function()
  return {
    text = "",
    font_size = 30,
    active = false,

    display = function(self)
      love.graphics.print(self.text, sprite.get_font(self.font_size), unpack(State.gui.views.text_input.offset))
    end,
  }
end)
