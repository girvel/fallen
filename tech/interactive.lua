local cue = require("tech.cue")


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
    size = Vector.one,

    on_add = function(self)
      if params.highlight then
        cue.set(self, "highlight", true)
      end
    end,

    interact = Dump.ignore_upvalue_size .. function(self, other)
      self.was_interacted_with = true
      cue.set(self, "highlight", false)
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
        action = actions.interact,
      })
    end,
  }
end

--- @param enable_highlight boolean?
--- @return table
module.detector = function(enable_highlight)
  return module(function(self, other)
    self.interacted_by = other
    Log.debug("%s interacts with %s" % {Entity.name(other), Entity.name(self)})
  end, {highlight = enable_highlight})
end

return module
