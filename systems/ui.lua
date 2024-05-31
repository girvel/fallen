local ui_font = love.graphics.newFont("assets/fonts/BigBlueTerm437NerdFontMono-Regular.ttf", 12)

return Tiny.system({
  base_callback = "draw",

  update = function(_, state)
    for i, line in ipairs({
      "Movement: " .. state.player.turn_resources.movement .. "/?",
    }) do
      love.graphics.print(line, ui_font, 600, 10 + i * 10)
    end
  end,
})
