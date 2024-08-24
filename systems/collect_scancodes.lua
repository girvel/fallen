local input, _, static = Module("systems.collect_scancodes")

input.system = static(Tiny.system({
  codename = "collect_scancodes",
  base_callback = "custom_keypressed",
  update = function(_, event)
    local scancode = unpack(event)

    if scancode == "return" then
      scancode = "enter"
    elseif scancode:endsWith("shift") then
      scancode = "shift"
    elseif scancode:endsWith("ctrl") then
      scancode = "ctrl"
    elseif scancode:endsWith("alt") then
      scancode = "alt"
    end

    local modifier = ""
    if scancode ~= "shift"
      and (love.keyboard.isDown("rshift") or love.keyboard.isDown("lshift"))
    then
      modifier = "Shift+" .. modifier
    end

    if scancode ~= "alt"
      and (love.keyboard.isDown("ralt") or love.keyboard.isDown("lalt"))
    then
      modifier = "Alt+" .. modifier
    end
    if scancode ~= "ctrl"
      and (love.keyboard.isDown("rctrl") or love.keyboard.isDown("lctrl"))
    then
      modifier = "Ctrl+" .. modifier
    end

    table.insert(State.gui.pressed_scancodes, scancode)
    if #modifier > 0 then table.insert(State.gui.pressed_scancodes, modifier .. scancode) end
  end,
}))

return input