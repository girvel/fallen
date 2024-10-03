local trigger_tooltip, module_mt, static = Module("systems.trigger_tooltip")

-- TODO maybe join with detect_hover system?
trigger_tooltip.system = static .. Tiny.processingSystem {
  base_callback = "update",
  filter = Tiny.requireAll("get_tooltip", "position", "size"),
  codename = "trigger_tooltip",

  preProcess = function(self, dt)
    self.is_tooltip_visible = false
  end,
  process = function(self, entity, dt)
    local mouse_position = Vector({love.mouse.getPosition()})
    local relative_mouse_position = State.gui.views[entity.view]:inverse(mouse_position)
    if not Entity.is_over(relative_mouse_position, entity) then return end

    local tooltip = entity:get_tooltip()
    if tooltip then
      self.is_tooltip_visible = true
      State.gui.tooltip:show(mouse_position, tooltip)
    end
  end,
  postProcess = function(self, dt)
    if not self.is_tooltip_visible then
      State.gui.tooltip:hide()
    end
  end,
}

return trigger_tooltip
