local collect_scancodes, _, static = Module("systems.collect_scancodes")

-- TODO REF unsplit input systems
collect_scancodes.system = static(Tiny.system({
  codename = "collect_scancodes",
  base_callback = "custom_keypressed",
  scancode_conversion = {
    ["return"] = "enter",
    escape = "esc",
    rshift = "shift",
    lshift = "shift",
    rctrl = "ctrl",
    lctrl = "ctrl",
    ralt = "alt",
    lalt = "alt",

    [1] = "lmb",
    [2] = "rmb",
    [3] = "mmb",
    [4] = "backmb",
    [5] = "forwardmb",
  },
  update = function(self, scancode)
    scancode = self.scancode_conversion[scancode] or scancode

    local modifier = ""
    if scancode ~= "shift" and love.keyboard.isDown("rshift", "lshift") then
      modifier = "Shift+" .. modifier
    end

    if scancode ~= "alt" and love.keyboard.isDown("ralt", "lalt") then
      modifier = "Alt+" .. modifier
    end

    if scancode ~= "ctrl" and love.keyboard.isDown("rctrl", "lctrl") then
      modifier = "Ctrl+" .. modifier
    end

    table.insert(State.gui.pressed_scancodes, scancode)
    if #modifier > 0 then table.insert(State.gui.pressed_scancodes, modifier .. scancode) end
  end,
}))

return collect_scancodes
