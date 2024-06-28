return Tiny.processingSystem({
  base_callback = "draw",
  filter = Tiny.requireAll("gui_position", "sprite", "link"),

  preProcess = function()
    love.graphics.setColor(State.gui.LINK_COLOR)
  end,

  process = function(_, entity)
    local offset_position = entity.gui_position + State.gui.current_wiki_offset
    local start = offset_position + Vector.down * entity.size[2]
    local finish = offset_position + entity.size
    local mouse_position = Vector({love.mouse.getPosition()})
    if not (mouse_position >= offset_position and mouse_position < finish) then return end
    love.graphics.line(start[1], start[2], unpack(finish))
  end,

  postProcess = function()
    love.graphics.setColor({1, 1, 1})
  end,
})
