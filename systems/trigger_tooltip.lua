local trigger_tooltip, module_mt, static = Module("systems.trigger_tooltip")

trigger_tooltip.system = static .. Tiny.processingSystem {
  base_callback = "update",
  filter = Tiny.requireAll("tooltip", "position", "size"),
  codename = "trigger_tooltip",

  preProcess = function(self, dt)
    self.is_tooltip_visible = false
  end,
  process = function(self, entity, dt)
    local mouse_position = Vector({love.mouse.getPosition()})
    local relative_mouse_position = State.gui.views[entity.view]:inverse(mouse_position)
    if not Common.is_over(relative_mouse_position, entity) then return end

    self.is_tooltip_visible = true
    State.gui.tooltip:show(mouse_position, entity.tooltip)
  end,
  postProcess = function(self, dt)
    if not self.is_tooltip_visible then
      State.gui.tooltip:hide()
    end
  end,
}

return trigger_tooltip
