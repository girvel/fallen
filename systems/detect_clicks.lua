local detect_clicks, _, static = Module("systems.detect_clicks")

detect_clicks.system = static(Tiny.processingSystem({
  codename = "detect_clicks",
  base_callback = "mousepressed",
  filter = Tiny.requireAll("on_click", "position", "size"),
  process = function(_, entity)
    local relative_mouse_position = State.gui.views[entity.view]:inverse(Vector({love.mouse.getPosition()}))
    if not (
      relative_mouse_position > entity.position
      and relative_mouse_position < entity.position + entity.size
    ) then
      return
    end

    entity:on_click(State.player)
  end,
}))

return detect_clicks
