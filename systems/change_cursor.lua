local change_cursor, module_mt, static = Module("systems.change_cursor")

local cursors = {
  normal = love.mouse.newCursor("assets/sprites/cursor.png"),
  hand = love.mouse.getSystemCursor("hand"),  -- TODO draw our own
}

change_cursor.system = static(Tiny.processingSystem({
  codename = "change_cursor",
  base_callback = "update",
  filter = Tiny.requireAll(Tiny.requireAny("on_click", "changes_cursor"), "position", "size"),

  _detected = false,

  preProcess = function(self)
    self._detected = false
  end,

  process = function(self, entity)
    local relative_mouse_position = State.gui.views[entity.view]:inverse(Vector({love.mouse.getPosition()}))
    if not Entity.is_over(relative_mouse_position, entity)
      or entity.changes_cursor and not entity:changes_cursor()
    then
      return
    end

    self._detected = true
  end,

  postProcess = function(self)
    love.mouse.setCursor(self._detected and cursors.hand or cursors.normal)
  end,
}))

return change_cursor
