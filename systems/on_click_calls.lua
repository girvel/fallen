return Tiny.processingSystem({
  base_callback = "mousepressed",
  filter = Tiny.requireAll("on_click", "gui_position", "size"),
  process = function(_, entity)
    local relative_mouse_position = State.gui.views[entity.view]:apply_inverse(Vector({love.mouse.getPosition()}))
    if not (
      relative_mouse_position > entity.gui_position
      and relative_mouse_position < entity.gui_position + entity.size
    ) then
      return
    end

    entity:on_click()
  end,
})
