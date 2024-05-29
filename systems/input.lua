local move = function(direction)
  return function(entity, state)
    if entity.turn_resources.movement <= 0 then return end
    local next_position = entity.position + direction
    if not state.grid:can_fit(next_position) or state.grid[next_position] ~= nil then return end

    state.grid[next_position] = entity
    state.grid[entity.position] = nil
    entity.position = next_position
    entity.turn_resources.movement = entity.turn_resources.movement - 1
  end
end

local hotkeys = {
  w = move(Vector({0, -1})),
  a = move(Vector({-1, 0})),
  s = move(Vector({0, 1})),
  d = move(Vector({1, 0})),

  space = function(entity)
    entity.turn_resources.movement = entity.turn_resources.movement_max
  end,
}

return Tiny.processingSystem({
  filter = Tiny.requireAll("player_flag"),
  base_callback = "keypressed",
  process = function(_, entity, state, event)
    local action = hotkeys[event[2]]
    if action ~= nil then return action(entity, state) end
  end,
})
