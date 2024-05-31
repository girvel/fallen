local ui_font = love.graphics.newFont("assets/fonts/BigBlueTerm437NerdFontMono-Regular.ttf", 12)

return Tiny.system({
  base_callback = "draw",

  update = function(_, state)
    for i, line in ipairs({
      "Resources:",
      "  Movement: " .. state.player.turn_resources.movement .. "/?",
      "  Actions: " .. state.player.turn_resources.actions,
    }) do
      love.graphics.print(line, ui_font, 600, i * 15)
    end
  end,
})
