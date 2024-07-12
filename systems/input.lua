return Tiny.system({
  base_callback = "keypressed",
  update = function(_, event)
    local _, scancode = unpack(event)
    if love.keyboard.isDown("rshift") or love.keyboard.isDown("lshift") then
      scancode = "S-" .. scancode
    end
    if love.keyboard.isDown("ralt") or love.keyboard.isDown("lalt") then
      scancode = "M-" .. scancode
    end
    if love.keyboard.isDown("rctrl") or love.keyboard.isDown("lctrl") then
      scancode = "C-" .. scancode
    end
    State.player.last_pressed_key = scancode
  end,
})
