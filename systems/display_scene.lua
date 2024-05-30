local CELL_DISPLAY_SIZE = 16
local main_font = love.graphics.newFont("assets/fonts/BigBlueTerm437NerdFontMono-Regular.ttf", 16)

return Tiny.processingSystem({
  filter = Tiny.requireAll("position", "sprite"),
  base_callback = "draw",
  process = function(_, entity)
    if entity.sprite.character then
      love.graphics.print(entity.sprite.character, main_font, unpack(entity.position * CELL_DISPLAY_SIZE))
    else
      love.graphics.draw(entity.sprite.image, unpack(entity.position * CELL_DISPLAY_SIZE))
    end
  end,
})
