return Tiny.processingSystem({
  base_callback = "draw",
  filter = Tiny.requireAll("gui_position", "sprite", "link"),

  preProcess = function()
    love.graphics.setColor(State.gui.LINK_COLOR)
  end,

  process = function(_, entity)
    local start = entity.gui_position + Vector.down * entity.sprite.font:getHeight()
    local finish = start + Vector.right * entity.sprite.font:getWidth(entity.sprite.text)
    local mouse_position = Vector({love.mouse.getPosition()})
    if not (mouse_position >= entity.gui_position and mouse_position < finish) then return end
    love.graphics.line(start[1], start[2], unpack(finish))
  end,

  postProcess = function()
    love.graphics.setColor({1, 1, 1})
  end,
})
