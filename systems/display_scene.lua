local CELL_DISPLAY_SIZE = 20
local main_font = love.graphics.newFont("assets/fonts/BigBlueTerm437NerdFontMono-Regular.ttf", 24)

return Tiny.processingSystem({
  filter = Tiny.requireAll("position", "sprite"),
  base_callback = "draw",
  process = function(_, entity)
    love.graphics.print(entity.sprite.character, main_font, unpack(entity.position * CELL_DISPLAY_SIZE))
  end,
})
