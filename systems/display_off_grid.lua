local default_font = love.graphics.newFont("assets/fonts/joystix.monospace-regular.otf", 7)

return Tiny.processingSystem({
  filter = Tiny.requireAll("sprite", "off_grid_position"),
  base_callback = "draw",

  process = function(_, entity, state)
    local position = Vector({state.transform:transformPoint(unpack(entity.off_grid_position))})
      + Vector({
        state.CELL_DISPLAY_SIZE - default_font:getWidth(entity.sprite.text),
        state.CELL_DISPLAY_SIZE - default_font:getHeight(),
      }) / 2

    love.graphics.print(
      {entity.sprite.color, entity.sprite.text},
      entity.sprite.font or default_font,
      unpack(position)
    )
  end,
})
