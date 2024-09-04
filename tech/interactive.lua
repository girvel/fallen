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

module_mt.__call = function(_, callback, params)
  params = params or {}
  return {
    was_interacted_with = false,
    on_add = function(self)
      if params.highlight then
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
    on_click = function(self)
      local d = self.position - State.player.position
      if d:abs() > 1 then return end

      local actions = require("mech.creature.actions")
      table.insert(State.player.action_factories, {
        pre_action = function()
          if d:abs() == 0 then return end
          State.player:rotate(Vector.name_from_direction(d))
        end,
        action = actions.interact
      })
    end,
    size = Vector.one,
  }
end

module.detector = function(disable_highlight)
  return module(function(self, other)
    self.interacted_by = other
    Log.debug("%s interacts with %s" % {Common.get_name(other), Common.get_name(self)})
  end, {highlight = not disable_highlight})
end

return module
