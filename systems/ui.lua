local ui_font = love.graphics.newFont("assets/fonts/BigBlueTerm437NerdFontMono-Regular.ttf", 12)

return Tiny.processingSystem({
  filter = Tiny.requireAll("player_flag"),
  base_callback = "draw",
  process = function(_, entity)
    love.graphics.print(
      "Movement: " .. entity.turn_resources.movement .. "/" .. entity.turn_resources.movement_max,
      ui_font, 600, 20
    )
  end,
})
