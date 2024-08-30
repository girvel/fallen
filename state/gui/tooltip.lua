local texting = require("tech.texting")
local tooltip, module_mt, static = Module("state.gui.tooltip")

module_mt.__call = function(_, gui)
  return {
    _entities = nil,
    _content = nil,
    styles = Table.extend(gui.styles, {
      h1 = {
        font_size = 14,
      },
    }),
    position = Vector.zero,
    show = function(self, position, content)
      if not self._entities or self._content ~= content then
        State:remove_multiple(self._entities or {})
        self._entities = State:add_multiple(texting.popup(
          Vector.zero, "below", "tooltip", content, State.gui.tooltip.styles, 500
        ))
      end
      self.position = Vector.use(
        math.min,
        position + Vector.down * 16, Vector({love.graphics.getDimensions()}) - self._entities[1].size
      )
    end,
    hide = function(self)
      if not self._entities then return end
      State:remove_multiple(self._entities)
      self._entities = nil
    end,
  }
end

return tooltip
