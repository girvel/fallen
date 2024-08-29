local texting = require("tech.texting")
local popup, module_mt, static = Module("state.gui.popup")

module_mt.__call = function()
  return {
    _entities = nil,
    _content = nil,
    position = Vector.zero,
    show = function(self, position, content)
      self.position = position
      if not self._entities or self._content ~= content then
        State:remove_multiple(self._entities)
        self._entities = State:add_multiple(texting.popup(
          Vector.zero, "below", "tooltip", content
        ))
      end
    end,
    hide = function(self)
      State:remove_multiple(self._entities)
      self._entities = nil
    end,
  }
end

return popup
