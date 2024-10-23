local tcod = require("tech.tcod")
local actions = require("mech.creature.actions")


local ai, _, static = Module("tech.ai")
ai.api = static {}

local coroutine_cache = {}

ai.async = function(fun, works_outside_of_combat)  -- TODO remove last argument
  return Dump.ignore_upvalue_size .. function(self, entity, dt)
    -- TODO support WORLD_TURN (which is 1 frame only btw)
    if
      not works_outside_of_combat
      and not Table.contains(-Query(State.combat).list or {}, entity)
    then return end

    if Common.period(.25, ai.async, entity) then
      coroutine_cache[fun] = coroutine_cache[fun] or coroutine.create(function(...)
        return Debug.call(fun, ...)
      end)

      Common.resume_logged(coroutine_cache[fun], self, entity, dt)

      if coroutine.status(coroutine_cache[fun]) == "dead" then
        coroutine_cache[fun] = nil
        return entity:act(actions.finish_turn)
      end
    end
  end
end

ai.api.move = function(entity, direction)
  entity:rotate(Vector.name_from_direction(direction:normalized()))
  return entity:act(actions.move)
end

ai.api.travel = function(entity, destination)
  -- Log.debug("%s moving to %s" % {Entity.name(entity), destination})
  if entity.position == destination then return end
  local path = State.grids.solids:find_path(entity.position, destination, 25)
  if #path == 0 then return end
  if State.grids.solids[path[#path]] then table.remove(path) end

  for _, position in ipairs(path) do
    if entity.resources.movement <= 0 then
      if entity.resources.actions > 0 then
        entity:act(actions.dash)
      else
        break
      end
    end

    local i = 0
    while true do
      i = i + 1
      if i == 10 then return end
      coroutine.yield()
      if ai.api.move(entity, position - entity.position) then break end
    end
  end
end

ai.api.tcod_travel = function(entity, destination)
  -- Log.debug("%s moving to %s" % {Entity.name(entity), destination})
  if entity.position == destination then return end
  local path
  for _, d in ipairs(Table.concat({Vector.zero}, Vector.extended_directions)) do
    path = tcod.snapshot():find_path(entity.position, destination + d)
    if #path > 0 then break end
  end

  for _, position in ipairs(path) do
    if entity.resources.movement <= 0 then
      if entity.resources.actions > 0 then
        entity:act(actions.dash)
      else
        break
      end
    end

    coroutine.yield()
    if Random.chance(.1) then coroutine.yield() end
    if not ai.api.move(entity, position - entity.position) then break end
  end
end

ai.api.try_attacking = function(entity, target)
  local direction = target.position - entity.position
  if direction:abs() ~= 1 then return end

  Log.debug("Attempt at attacking %s" % Entity.name(target))
  entity:rotate(Vector.name_from_direction(direction))
  if entity.resources.actions <= 0 then return end  -- TODO RM after multiattacks
  while entity:act(actions.hand_attack) or entity:act(actions.other_hand_attack) do
    while not entity.animation.current.codename:starts_with("idle") do
      coroutine.yield()
    end
  end
end

ai.api.in_combat = function(entity)
  return Table.contains(-Query(State.combat).list or {}, entity)
end

ai.api.aggregate_aggression = function(t, entity)
  return Table.concat(t, Fun.iter(State.aggression_log)
    :filter(function(pair) return pair[2] == entity end)
    :map(function(pair) return pair[1] end)
    :totable())
end

return ai
