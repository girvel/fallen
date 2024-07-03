return Tiny.processingSystem({
  base_callback = "mousepressed",
  filter = Tiny.requireAll("link", "gui_position", "size"),
  process = function(_, entity)
    local relative_mouse_position = Vector({love.mouse.getPosition()}) - State.gui.anchors[entity.gui_anchor]
    if not (
      relative_mouse_position > entity.gui_position
      and relative_mouse_position < entity.gui_position + entity.size
    ) then
      return
    end

    State.gui:show_page(entity.link)
  end,
})
