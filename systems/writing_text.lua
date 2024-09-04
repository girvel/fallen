local writing_text, module_mt, static = Module("systems.writing_text")

writing_text.system = static(Tiny.system({
  codename = "writing_text",
  base_callback = "textinput",
  update = function(self, text)
    if State.mode:get() ~= State.mode.text_input then return end
    local new_text = State.gui.text_input.text .. text
    if new_text:find("^%s*$") then return end
    State.gui.text_input.text = new_text
  end
}))

return writing_text
