local sfx = require("library.sfx")


local module_mt = {}
local module = setmetatable({}, module_mt)

module.get_for = function(entity, state)
  return Fun.iter(pairs({
    state.grids.tiles[entity.position],
    state.grids.solids:safe_get(entity.position + Vector[entity.direction]),
  }))
    :filter(function(x) return x and x.interact end)
    :nth(1)
end

module_mt.__call = function(_, callback)
  return {
    was_interacted_with = false,
    on_load = function(self, state)
      self._highlight = state:add(Tablex.extend(sfx.highlight(), {position = self.position}))
    end,
    interact = function(self, other, state)
      self.was_interacted_with = true
      if self._highlight then
        state:remove(self._highlight)
        self._highlight = nil
      end
      callback(self, other, state)
    end,
  }
end

return module
