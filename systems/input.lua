local move = function(direction)
  return function(entity)
    if entity.turn_resources.movement <= 0 then return end
    entity.position = entity.position + direction
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
  process = function(_, entity, _, event)
    local action = hotkeys[event[2]]
    if action ~= nil then return action(entity) end
  end,
})
