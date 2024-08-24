local detect_hover, _, static = Module("systems.detect_hover")

detect_hover.system = static(Tiny.processingSystem({
  codename = "detect_hover",
  base_callback = "update",
  filter = Tiny.requireAll(Tiny.requireAny("on_hover", "on_hover_end"), "position", "size"),

  _previously_hovered = {},
  _now_hovered = {},

  process = function(self, entity)
    local relative_mouse_position = State.gui.views[entity.view]:inverse(Vector({love.mouse.getPosition()}))
    if not (
      relative_mouse_position > entity.position
      and relative_mouse_position < entity.position + entity.size
    ) then
      return
    end

    Query(entity):on_hover()
    self._now_hovered[entity] = true
  end,

  postProcess = function(self)
    for e in pairs(self._previously_hovered) do
      if not self._now_hovered[e] then
        Query(e):on_hover_end()
      end
    end
    self._previously_hovered = self._now_hovered
    self._now_hovered = {}
  end
}))

return detect_hover
