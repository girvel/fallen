local actions = require("mech.creature.actions")


local ai = {api = {}}

ai.async = function(fun, works_outside_of_combat)
  return function(self, event)
    if
      not works_outside_of_combat
      and not -Query(State.move_order):contains(self)
    then return end

    local dt = unpack(event)
    if not Common.period(self, .25, dt) then return end
    if not self._ai_coroutine then
      self._ai_coroutine = coroutine.create(fun)
    end

    Common.resume_logged(self._ai_coroutine, self, dt)

    if coroutine.status(self._ai_coroutine) == "dead" then
      self._ai_coroutine = nil
      return self:act(actions.finish_turn)
    end
  end
end

ai.api.move = function(entity, direction)
  entity:rotate(Vector.name_from_direction(direction:normalized()))
  return entity:act(actions.move)
end

ai.api.travel = function(entity, destination)
  Log.debug("Moving to " .. tostring(destination))
  if entity.position == destination then return end
  local path = State.grids.solids:find_path(entity.position, destination)
  Log.trace(#path, path)
  if State.grids.solids[path[#path]] then table.remove(path) end

  for _, position in ipairs(path) do
    if entity.turn_resources.movement <= 0 then
      if entity.turn_resources.actions > 0 then
        entity:act(actions.dash)
      else
        break
      end
    end

    if not ai.api.move(entity, position - entity.position) then return end
    coroutine.yield()
  end
end

return ai
