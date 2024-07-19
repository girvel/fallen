local special = require("tech.special")


local module_mt = {}
local module = setmetatable({}, module_mt)

module.get_for = function(entity)
  return Fun.iter(pairs({
    State.grids.items[entity.position],
    State.grids.tiles[entity.position],
    State.grids.solids:safe_get(entity.position + Vector[entity.direction]),
  }))
    :filter(function(x) return x and x.interact end)
    :nth(1)
end

module_mt.__call = function(_, callback, disable_highlight)
  return {
    was_interacted_with = false,
    on_load = function(self)
      if not disable_highlight then
        self._highlight = State:add(Tablex.extend(special.highlight(), {position = self.position}))
        State:add_dependency(self, self._highlight)
      end
    end,
    interact = function(self, other)
      self.was_interacted_with = true
      if self._highlight then
        State:remove(self._highlight)
        self._highlight = nil
      end
      callback(self, other)
    end,
  }
end

return module
