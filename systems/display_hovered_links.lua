return Tiny.processingSystem({
  base_callback = "draw",
  filter = Tiny.requireAll("position", "sprite", "link_flag"),

  process = function(_, entity)
    local offset_position = State.gui.views[entity.view]:apply(entity.position)
    local start = offset_position + Vector.down * entity.size[2]
    local finish = offset_position + entity.size
    local mouse_position = Vector({love.mouse.getPosition()})
    if not (mouse_position >= offset_position and mouse_position < finish) then return end

    if type(entity.sprite.text) == "table" then
      love.graphics.setColor(entity.sprite.text[1])
    end
    love.graphics.line(start[1], start[2], unpack(finish))
    love.graphics.setColor({1, 1, 1})
  end,
})
