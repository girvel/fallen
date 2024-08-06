return Static.module("systems.input", Tiny.system({
  codename = "input",
  base_callback = "keypressed",
  update = function(_, event)
    local _, scancode = unpack(event)

    if scancode == "return" then
      scancode = "enter"
    end

    if love.keyboard.isDown("rshift") or love.keyboard.isDown("lshift") then
      scancode = "Shift+" .. scancode
    end
    if love.keyboard.isDown("ralt") or love.keyboard.isDown("lalt") then
      scancode = "Alt+" .. scancode
    end
    if love.keyboard.isDown("rctrl") or love.keyboard.isDown("lctrl") then
      scancode = "Ctrl+" .. scancode
    end

    local data = -Query(State.hotkeys)[State:get_mode()][scancode]
    if not data then return end
    Query(data).pre_action()
    Query(State.player).next_action = data.action
  end,
}))
