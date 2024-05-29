local ui_font = love.graphics.newFont("assets/fonts/BigBlueTerm437NerdFontMono-Regular.ttf", 12)

return Tiny.processingSystem({
  filter = Tiny.requireAll("player_flag"),
  base_callback = "draw",

  process = function(_, entity)
    for i, line in ipairs({
      "Movement: " .. entity.turn_resources.movement .. "/" .. entity.turn_resources.movement_max,
    }) do
      love.graphics.print(line, ui_font, 600, 10 + i * 10)
    end
  end,
})
