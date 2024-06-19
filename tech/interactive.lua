local sfx = require("library.sfx")


local module_mt = {}
local module = setmetatable({}, module_mt)

module.get_for = function(entity)
  return Fun.iter(pairs({
    State.grids.tiles[entity.position],
    State.grids.solids:safe_get(entity.position + Vector[entity.direction]),
  }))
    :filter(function(x) return x and x.interact end)
    :nth(1)
end

module_mt.__call = function(_, callback)
  return {
    was_interacted_with = false,
    on_load = function(self)
      self._highlight = State:add(Tablex.extend(sfx.highlight(), {position = self.position}))
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
