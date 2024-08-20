local input, _, static = Module("systems.input")

input.system = static(Tiny.system({
  codename = "input",
  base_callback = "keypressed",
  update = function(_, event)
    local _, scancode = unpack(event)

    if scancode == "return" then
      scancode = "enter"
    elseif scancode:endsWith("shift") then
      scancode = "shift"
    elseif scancode:endsWith("ctrl") then
      scancode = "ctrl"
    elseif scancode:endsWith("alt") then
      scancode = "alt"
    end

    if scancode ~= "shift"
      and (love.keyboard.isDown("rshift") or love.keyboard.isDown("lshift"))
    then
      scancode = "Shift+" .. scancode
    end

    if scancode ~= "alt"
      and (love.keyboard.isDown("ralt") or love.keyboard.isDown("lalt"))
    then
      scancode = "Alt+" .. scancode
    end
    if scancode ~= "ctrl"
      and (love.keyboard.isDown("rctrl") or love.keyboard.isDown("lctrl"))
    then
      scancode = "Ctrl+" .. scancode
    end

    Log.trace(scancode)
    local data = -Query(State.hotkeys)[State:get_mode()][scancode]
    if not data then return end
    Query(data).pre_action()
    Query(State.player).next_action = data.action
  end,
}))

return input
