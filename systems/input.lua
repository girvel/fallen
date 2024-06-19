return Tiny.system({
  base_callback = "keypressed",
  update = function(_, event)
    State.player.last_pressed_key = event[2]
  end,
})
