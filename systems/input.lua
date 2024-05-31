return Tiny.system({
  base_callback = "keypressed",
  update = function(_, state, event)
    state.player.last_pressed_key = event[2]
  end,
})
