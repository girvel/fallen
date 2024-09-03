local gui = require("tech.gui")


local module, module_mt, static = Module("tech.interactive")

module.get_for = function(entity)
  return Fun.iter(pairs({
    State.grids.items[entity.position],
    State.grids.tiles[entity.position],
    State.grids.solids:safe_get(entity.position + Vector[entity.direction]),
    State.grids.on_solids:safe_get(entity.position + Vector[entity.direction]),
  }))
    :filter(function(x) return x and x.interact end)
    :nth(1)
end

module_mt.__call = function(_, callback, disable_highlight)
  return {
    was_interacted_with = false,
    on_add = function(self)
      if not disable_highlight then
        self._highlight = State:add(gui.highlight(), {position = self.position})
        State:add_dependency(self, self._highlight)
      end
    end,
    interact = Dump.ignore_upvalue_size .. function(self, other)
      self.was_interacted_with = true
      if self._highlight then
        State:remove(self._highlight)
        self._highlight = nil
      end
      callback(self, other)
    end,
  }
end

module.detector = function(disable_highlight)
  return module(function(self, other)
    self.interacted_by = other
    Log.debug("%s interacts with %s" % {Common.get_name(other), Common.get_name(self)})
  end, disable_highlight)
end

return module
