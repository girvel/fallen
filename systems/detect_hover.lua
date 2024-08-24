local detect_hover, _, static = Module("systems.detect_hover")

detect_hover.system = static(Tiny.processingSystem({
  codename = "detect_hover",
  base_callback = "update",
  filter = Tiny.requireAll("on_hover", "position", "size"),
  process = function(_, entity)
    local relative_mouse_position = entity.view:inverse(Vector({love.mouse.getPosition()}))
    if not (
      relative_mouse_position > entity.position
      and relative_mouse_position < entity.position + entity.size
    ) then
      return
    end

    entity:on_hover()
  end,
}))

return detect_hover
