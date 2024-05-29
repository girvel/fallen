local movement_hotkeys = {
  w = Vector({0, -1}),
  a = Vector({-1, 0}),
  s = Vector({0, 1}),
  d = Vector({1, 0}),
}
local turn_skip_hotkey = "space"

return Tiny.processingSystem({
  filter = Tiny.requireAll("player_flag"),
  base_callback = "keypressed",
  process = function(_, entity, _, event)
    local _, scancode = unpack(event)

    if scancode == turn_skip_hotkey then
      entity.turn_resources.movement = entity.turn_resources.movement_max
      return
    end

    local movement = movement_hotkeys[scancode]
    if movement == nil or entity.turn_resources.movement <= 0 then return end
    entity.position = entity.position + movement
    entity.turn_resources.movement = entity.turn_resources.movement - 1
  end,
})
