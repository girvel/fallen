local sprite = require("tech.sprite")


return Module("state.gui.text_input", function()
  return {
    text = "",
    font_size = 30,
    active = false,

    display = function(self)
      love.graphics.print(
        self.text, sprite.get_font(self.font_size),
        unpack(
          Vector({love.graphics.getDimensions()}) / 2
          + Vector.left * sprite.get_font(self.font_size):getWidth(self.text) / 2
        ))
    end,
  }
end)
